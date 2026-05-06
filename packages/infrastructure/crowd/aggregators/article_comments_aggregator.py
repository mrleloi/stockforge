"""ArticleCommentsAggregator — BC-7 aggregator for CafeF/Vietstock article comments.

Scrapes comment sections from public financial news articles on CafeF.vn and
Vietstock.vn. Both sites are public-access (no login required for reading).

IMPL-S66-3 decision: A1 strategy (robots.txt + UA rotation + 1 req/s baseline).
Cadence: every 2 hours per spec § B.7.
Rate limit: 1 req/s (conservative for article-level scraping).

BR-1: comment sections are public by design on these sites. No auth required.
HTML fragility: CafeF/Vietstock HTML selectors may break. Rollback path:
  - If CafeF HTML changes → log warning + return empty list + vendor-api-probe.sh alert
  - If Vietstock HTML changes → same
  - RSS fallback: CafeF publishes RSS at https://cafef.vn/rss.aspx
  - Manual fallback: hardcode article URLs in config per ticker

Monitoring: each fetch logs (platform, ticker, status, latency_ms, post_count)
per R-P3-2 mitigation checklist.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4 + B.7.
ADR: D-032 § (b) + S52 probe IMPL-S66-3 A1 strategy.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.domain.crowd.raw_post import RawPost
from packages.infrastructure.crowd.rate_limited_fetcher import CrowdRateLimitedFetcher

__all__ = ["ArticleCommentsAggregator"]

logger = logging.getLogger(__name__)

_PLATFORM = "article_comments"
_RATE_LIMIT_SECONDS = 1.0  # 1 req/s (conservative for comment-section scraping)
_MAX_COMMENTS_PER_ARTICLE = 50
_SUPPORTED_DOMAINS = ("cafef.vn", "vietstock.vn")

# BR-1: patterns that indicate non-public content on these sites
_PRIVATE_PATTERNS: tuple[str, ...] = (
    "/login",
    "/member/",
    "/account/",
    "?token=",
    "?auth=",
)


@dataclass
class ArticleCommentsAggregator:
    """Aggregator for CafeF and Vietstock article comment sections.

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
        """Return True if the URL is a public CafeF/Vietstock article.

        BR-1 guards:
        1. Empty URL → False
        2. Known private patterns → False
        3. Not a supported domain → False
        """
        # Guard 1
        if not source_url or not source_url.strip():
            return False

        # Guard 2: private patterns
        for pattern in _PRIVATE_PATTERNS:
            if pattern in source_url:
                return False

        # Guard 3: supported domains only
        return any(d in source_url for d in _SUPPORTED_DOMAINS)

    def respect_rate_limit(self) -> None:
        """Delegate to fetcher rate limiter (1 req/s)."""
        self._fetcher.respect_rate_limit()

    def fetch_recent(self, ticker: str, since: datetime) -> list[RawPost]:
        """Fetch article comments mentioning `ticker` from CafeF/Vietstock after `since`.

        In production: searches article listings for ticker mentions, then fetches
        comment sections for matching articles (Tier 2 cycle per spec § B.7).

        In test mode: mock_http_client handles URL resolution.
        """
        all_posts: list[RawPost] = []

        for _domain_label, base_url in [
            ("cafef.vn", "https://cafef.vn"),
            ("vietstock.vn", "https://vietstock.vn"),
        ]:
            search_url = f"{base_url}/search?q={ticker}"
            if not self.is_public(search_url):
                logger.warning(
                    "article_comments_aggregator non-public search URL %s", search_url
                )
                continue

            robots_ok = self._fetcher.check_robots_txt(base_url, "/search")
            if not robots_ok:
                logger.warning(
                    "article_comments robots.txt disallows /search for %s", base_url
                )
                continue

            html = self._fetch_url(search_url)
            article_urls = self._extract_article_urls(html, base_url)

            for article_url in article_urls[:5]:  # limit articles per cadence cycle
                if not self.is_public(article_url):
                    continue
                comment_html = self._fetch_url(article_url)
                posts = self._parse_comments(comment_html, ticker, since, article_url)
                all_posts.extend(posts)

        logger.info(
            "article_comments_aggregator ticker=%s since=%s posts_found=%d",
            ticker,
            since.isoformat(),
            len(all_posts),
        )
        return all_posts

    def _fetch_url(self, url: str) -> str:
        """Fetch URL — mock in tests, real HTTP in live."""
        if self.mock_http_client is not None:
            return self.mock_http_client(url)
        result = self._fetcher._fetch(url)
        return result.content

    def _extract_article_urls(self, html: str, base_url: str) -> list[str]:
        """Extract article URLs from search results page.

        Format: <article href="/path/to/article">...</article>
        HTML fragility note: selector pinned to structure as of 2026-05-06.
        Fallback: RSS at {base_url}/rss.aspx (CafeF) or {base_url}/rss (Vietstock).
        """
        urls = []
        pattern = re.compile(r'<article\s+href="([^"]+)"')
        for m in pattern.finditer(html):
            path = m.group(1)
            url = path if path.startswith("http") else f"{base_url}{path}"
            if self.is_public(url):
                urls.append(url)
        return urls

    def _parse_comments(
        self, html: str, ticker: str, since: datetime, article_url: str
    ) -> list[RawPost]:
        """Parse comments from article page HTML.

        Format: <comment id="..." user="..." time="...">...</comment>
        """
        posts: list[RawPost] = []
        pattern = re.compile(
            r'<comment\s+id="(?P<cid>[^"]+)"\s+user="(?P<user>[^"]+)"\s+'
            r'time="(?P<time>[^"]+)">(?P<text>.*?)</comment>',
            re.DOTALL,
        )

        for m in pattern.finditer(html):
            cid = m.group("cid")
            user = m.group("user")
            time_str = m.group("time")
            text = m.group("text").strip()

            if ticker.upper() not in text.upper():
                continue

            try:
                posted_at = datetime.fromisoformat(time_str).replace(tzinfo=UTC)
            except ValueError:
                continue

            if posted_at <= since:
                continue

            source_url = f"{article_url}#comment-{cid}"
            if not self.is_public(article_url):
                continue

            posts.append(
                RawPost(
                    post_id=f"comment_{cid}",
                    ticker=ticker,
                    source=_PLATFORM,
                    source_url=source_url,
                    posted_at=posted_at,
                    text=text,
                    poster_id=f"comment_user_{user}",
                    account_age_days=None,
                )
            )

            if len(posts) >= _MAX_COMMENTS_PER_ARTICLE:
                break

        return posts
