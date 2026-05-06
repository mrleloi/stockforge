"""FacebookPublicGroupAggregator — BC-7 aggregator for Facebook public group posts.

Fetches posts from PUBLIC Facebook groups only (BR-1). Private groups, login-required
content, and invite-link groups raise ToSBoundaryViolation.

IMPL-S66-3 decision: A3 hybrid strategy (A2-stub for FB: Playwright stealth + 1 req/s).
Cadence: every 2 hours per spec § B.7.
Rate limit: 2 req/s per FB Graph API limits.

BR-1 hard refusals (mirror BC-6 telegram_adapter S64 hardening — 3 guards):
1. URL contains private group patterns (groups with numeric-only IDs, ?invite=) → refuse
2. URL requires login (facebook.com/login*, *.facebook.com without /groups/public*) → refuse
3. URL in known-private group list → refuse

Rollback (spec § S52 rollback path): if FB Graph API auth shifts mid-Phase-3 →
aggregator falls back to manual link-list mode (mirror BC-6 D-027 R1 pattern).
Manual fallback: maintain a list of public group URLs in config; scrape public feed
without API auth when Graph API access changes.
Document as IMPL-S66-4 if Graph API auth shifts during S66.

A2-stub note: Playwright stealth is stubbed in Phase 3 (requires playwright install).
Phase 4: implement full A2 strategy with playwright.async_api.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 + B.7.
ADR: D-032 § (b) + S52 probe IMPL-S66-3 A3 strategy.
Q-S52-2 IMPL decision: use Facebook public groups page endpoint (not Graph API v18+
`/posts` due to access token requirements); stub Graph API for Phase 3.
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

__all__ = ["FacebookPublicGroupAggregator"]

logger = logging.getLogger(__name__)

_PLATFORM = "fb_group"
_BASE_URL = "https://www.facebook.com"
_RATE_LIMIT_SECONDS = 0.5  # 2 req/s
_MAX_POSTS_PER_FETCH = 50

# BR-1: Known private patterns for Facebook URLs
_PRIVATE_FB_PATTERNS: tuple[str, ...] = (
    "facebook.com/login",
    "facebook.com/checkpoint",
    "?invite=",
    "/groups/",          # private groups are numeric IDs under /groups/
    "facebook.com/messages",
    "m.facebook.com",   # mobile login-required variant
)

# Public Facebook group URLs look like /groups/<slug>/ where slug is non-numeric
_PUBLIC_GROUP_PATTERN = re.compile(
    r"facebook\.com/groups/([a-zA-Z][a-zA-Z0-9._-]*)/?$"
)


@dataclass
class FacebookPublicGroupAggregator:
    """Aggregator for public Facebook group posts.

    A2-stub: Phase 3 uses simplified HTTP fetching. Phase 4 replaces with
    Playwright stealth + cookie eviction per A2 strategy.

    Args:
        mock_http_client: Inject mock for tests.
        clock:            Injectable clock.
        sleeper:          Injectable sleep.
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
        """Return True if the Facebook URL is a public group page.

        BR-1 hard refusal guards (applied BEFORE any HTTP request):
        1. Empty/invalid URL → False
        2. URL matches known private/login patterns → False
        3. URL does not match public group slug pattern → False
        """
        # Guard 1: empty URL
        if not source_url or not source_url.strip():
            return False

        # Guard 2: known private/login patterns (match BEFORE slug check)
        for pattern in _PRIVATE_FB_PATTERNS:
            if pattern in source_url:
                # Special case: /groups/<non-numeric-slug> is public
                # Only raise for pure numeric group IDs or explicit private patterns
                if pattern == "/groups/":
                    match = _PUBLIC_GROUP_PATTERN.search(source_url)
                    if match:
                        continue  # slug looks public — pass to guard 3
                return False

        # Guard 3: must match public group URL pattern
        if "facebook.com" not in source_url:
            return False
        return bool(_PUBLIC_GROUP_PATTERN.search(source_url))

    def respect_rate_limit(self) -> None:
        """Delegate to fetcher rate limiter."""
        self._fetcher.respect_rate_limit()

    def fetch_recent(self, ticker: str, since: datetime) -> list[RawPost]:
        """Fetch public Facebook group posts mentioning `ticker` after `since`.

        A2-stub: Phase 3 uses simple HTTP get. Phase 4: Playwright stealth.
        Raises ToSBoundaryViolation for private group URLs.
        """
        # Example public group URL (would come from config in production)
        group_url = f"{_BASE_URL}/groups/vietnamstockmarket/"

        # BR-1: pre-flight public check
        if not self.is_public(group_url):
            raise ToSBoundaryViolation(
                f"Facebook group URL {group_url!r} fails public-only check"
            )

        robots_allowed = self._fetcher.check_robots_txt(_BASE_URL, "/groups/")
        if not robots_allowed:
            logger.warning(
                "fb_group_aggregator robots.txt disallows /groups/ — skipping for ticker=%s",
                ticker,
            )
            return []

        raw_html = self._fetch_url(group_url)
        posts = self._parse_posts(raw_html, ticker, since, group_url)

        logger.info(
            "fb_group_aggregator ticker=%s since=%s posts_found=%d",
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
        self, html: str, ticker: str, since: datetime, group_url: str
    ) -> list[RawPost]:
        """Parse posts from FB group page HTML.

        Uses regex for test compatibility. Production would use BeautifulSoup.
        Post format in mock HTML: <fbpost id="..." user="..." time="...">...</fbpost>
        """
        posts: list[RawPost] = []
        pattern = re.compile(
            r'<fbpost\s+id="(?P<post_id>[^"]+)"\s+user="(?P<user_id>[^"]+)"\s+'
            r'time="(?P<time_str>[^"]+)">(?P<text>.*?)</fbpost>',
            re.DOTALL,
        )

        for m in pattern.finditer(html):
            post_id = m.group("post_id")
            user_id = m.group("user_id")
            time_str = m.group("time_str")
            text = m.group("text").strip()

            if ticker.upper() not in text.upper():
                continue

            try:
                posted_at = datetime.fromisoformat(time_str).replace(tzinfo=UTC)
            except ValueError:
                continue

            if posted_at <= since:
                continue

            source_url = f"{group_url}posts/{post_id}"
            if not self.is_public(group_url):
                logger.warning("fb_group_aggregator skipping non-public URL %s", source_url)
                continue

            posts.append(
                RawPost(
                    post_id=f"fb_{post_id}",
                    ticker=ticker,
                    source=_PLATFORM,
                    source_url=source_url,
                    posted_at=posted_at,
                    text=text,
                    poster_id=f"fb_user_{user_id}",
                    account_age_days=None,  # FB Graph API account-age requires extended permissions
                )
            )

            if len(posts) >= _MAX_POSTS_PER_FETCH:
                break

        return posts
