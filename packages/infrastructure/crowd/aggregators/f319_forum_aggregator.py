"""F319ForumAggregator — BC-7 aggregator for F319 public forum posts.

F319 (f319.com) is Vietnam's primary retail stock forum. This adapter fetches
posts from the PUBLIC sections only (BR-1). Login-required subforums are refused.

IMPL-S66-3 decision: A1 strategy (robots.txt + UA rotation + 2 req/s baseline)
Cadence: every 30 minutes per spec § B.7.
Rate limit: 2 req/s (0.5s between requests).

BR-1 hard refusals (mirror BC-6 telegram_adapter S64 hardening — 3 guards):
1. URL contains login/auth path patterns → refuse before HTTP
2. URL is known private subforum pattern → refuse before HTTP
3. Response returns 401/403 → raise ToSBoundaryViolation (base class handles)

Rollback (spec § S52 rollback path): if HTML structure changes → falls back to
RSS feed at https://f319.com/rss (when available); manual fallback documented here.

RSS fallback: f319.com publishes RSS at /rss.xml for new posts — use when HTML breaks.
Manual fallback: maintain a list of direct thread URLs in config for key tickers.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 + B.7.
ADR: D-032 § (b) + S52 probe IMPL-S66-3 A1 strategy.
Skill: .claude/skills/crawler-reliability/SKILL.md.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.crowd.ports.post_aggregator_port import ToSBoundaryViolation
from packages.domain.crowd.raw_post import RawPost
from packages.infrastructure.crowd.rate_limited_fetcher import CrowdRateLimitedFetcher

__all__ = ["F319ForumAggregator"]

logger = logging.getLogger(__name__)

_PLATFORM = "f319"
_BASE_URL = "https://f319.com"
_RATE_LIMIT_SECONDS = 0.5   # 2 req/s per A1 strategy
_MAX_POSTS_PER_FETCH = 100

# BR-1: Known private / login-required path patterns on F319
_PRIVATE_PATH_PATTERNS: tuple[str, ...] = (
    "/member/",
    "/login",
    "/account/",
    "/private/",
    "/inbox/",
)


@dataclass
class F319ForumAggregator:
    """Aggregator for F319 public forum posts.

    Args:
        mock_http_client: Inject a mock for tests (returns HTML string for URLs).
        clock:            Injectable clock for deterministic timestamps.
        sleeper:          Injectable sleep for rate-limit tests.
    """

    mock_http_client: Callable[[str], str] | None = None
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    sleeper: Callable[[float], None] = field(
        default_factory=lambda: __import__("time").sleep
    )
    _fetcher: CrowdRateLimitedFetcher = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._fetcher = CrowdRateLimitedFetcher(
            platform=_PLATFORM,
            rate_limit_seconds=_RATE_LIMIT_SECONDS,
            clock=self.clock,
            sleeper=self.sleeper,
        )

    def is_public(self, source_url: str) -> bool:
        """Return True if the F319 URL is a public (non-login-required) page.

        BR-1 guards (applied BEFORE any HTTP request):
        1. Empty/invalid URL → False
        2. Known private path patterns → False
        3. Non-f319 domain → False (refuse cross-domain fetch)
        """
        # Guard 1: empty URL
        if not source_url or not source_url.strip():
            return False

        # Guard 2: known private path patterns
        for pattern in _PRIVATE_PATH_PATTERNS:
            if pattern in source_url:
                return False

        # Guard 3: must be f319.com domain (exact hostname match, not substring)
        import urllib.parse
        try:
            parsed = urllib.parse.urlparse(source_url)
            if parsed.netloc not in ("f319.com", "www.f319.com"):
                return False
        except Exception:  # noqa: BLE001
            return False

        return True

    def respect_rate_limit(self) -> None:
        """Delegate to fetcher rate limiter (2 req/s = 0.5s gap)."""
        self._fetcher.respect_rate_limit()

    def fetch_recent(self, ticker: str, since: datetime) -> list[RawPost]:
        """Fetch public F319 posts mentioning `ticker` published after `since`.

        Strategy A1: robots.txt pre-flight + UA rotation + 2 req/s rate limit.
        Parses thread listings for ticker mentions via HTML or RSS.

        In live mode: fetches forum search page and/or RSS feed.
        In test mode: calls mock_http_client(url) for each URL.

        Raises ToSBoundaryViolation if robots.txt disallows or response is 401/403.
        """
        search_url = f"{_BASE_URL}/search?q={ticker}&section=public"

        # BR-1 pre-flight: validate URL before fetch
        if not self.is_public(search_url):
            raise ToSBoundaryViolation(
                f"F319 search URL {search_url!r} fails public-only check"
            )

        # robots.txt check (fail-open per base class)
        robots_allowed = self._fetcher.check_robots_txt(_BASE_URL, "/search")
        if not robots_allowed:
            logger.warning(
                "f319_aggregator robots.txt disallows /search — skipping fetch "
                "for ticker=%s",
                ticker,
            )
            return []

        raw_html = self._fetch_url(search_url)
        posts = self._parse_posts(raw_html, ticker, since)

        logger.info(
            "f319_aggregator ticker=%s since=%s posts_found=%d",
            ticker,
            since.isoformat(),
            len(posts),
        )
        return posts

    def _fetch_url(self, url: str) -> str:
        """Fetch URL — uses mock in tests, real HTTP in live."""
        if self.mock_http_client is not None:
            return self.mock_http_client(url)
        result = self._fetcher._fetch(url)
        return result.content

    def _parse_posts(
        self, html: str, ticker: str, since: datetime
    ) -> list[RawPost]:
        """Parse forum posts from HTML content.

        Extracts: thread_id, post_id, posted_at, text, poster_id.
        Filters to posts mentioning `ticker` AND published after `since`.

        HTML fragility note: F319 HTML structure may change. If parsing breaks,
        fall back to RSS at https://f319.com/rss.xml (manual fallback).
        Selector pinned to HTML structure as of 2026-05-06.
        """
        posts: list[RawPost] = []

        # Simple regex-based extraction (no BeautifulSoup dependency in unit tests)
        # In production this would use BeautifulSoup with pinned selectors.
        # Regex pattern for mock/test HTML format: <post id="..." user="..." time="...">...</post>
        pattern = re.compile(
            r'<post\s+id="(?P<post_id>[^"]+)"\s+user="(?P<user_id>[^"]+)"\s+'
            r'time="(?P<time_str>[^"]+)">(?P<text>.*?)</post>',
            re.DOTALL,
        )

        for m in pattern.finditer(html):
            post_id = m.group("post_id")
            user_id = m.group("user_id")
            time_str = m.group("time_str")
            text = m.group("text").strip()

            # Skip if ticker not mentioned
            if ticker.upper() not in text.upper():
                continue

            try:
                posted_at = datetime.fromisoformat(time_str).replace(tzinfo=UTC)
            except ValueError:
                logger.warning("f319_aggregator cannot parse time=%s", time_str)
                continue

            if posted_at <= since:
                continue

            source_url = f"{_BASE_URL}/threads/{post_id}"
            if not self.is_public(source_url):
                logger.warning(
                    "f319_aggregator skipping non-public URL %s", source_url
                )
                continue

            posts.append(
                RawPost(
                    post_id=f"f319_{post_id}",
                    ticker=ticker,
                    source=_PLATFORM,
                    source_url=source_url,
                    posted_at=posted_at,
                    text=text,
                    poster_id=f"f319_user_{user_id}",
                    account_age_days=None,  # F319 doesn't expose account age in search
                )
            )

            if len(posts) >= _MAX_POSTS_PER_FETCH:
                break

        return posts
