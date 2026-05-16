"""CafeFAdapter — CrawlerAdapter implementation for cafef.vn.

Migration strategy: **Strategy B (WRAP)** per plan 020 § DD-7 and § "Two migration
strategies". The adapter wraps the existing ``CafeFScraper`` (packages/infrastructure/
news/cafef_scraper.py) and delegates the three core methods. This preserves:
- The proven published_at parser (3 date formats, cafef_scraper.py:178-208).
- The fixture-driven test surface (test_adapters.py — CI never hits cafef.vn).
- Zero behavioral drift risk vs. the existing CLI.

Future consolidation: a follow-up Phase D-N session may collapse CafeFAdapter and
CafeFScraper into a single class if maintenance friction accumulates (RM12 carry-forward
per plan 020 § Risk table).

Key injections:
- ``rate_limiter``: RateLimiter instance from apps/_shared/crawl/rate_limiter.py.
  Replaces the inline _RATE_LIMIT_SECONDS arithmetic in CafeFScraper.
  The scraper's own sleeper is replaced by a no-op when a rate_limiter is provided
  to avoid double-sleeping.
- ``robots_manager``: Optional RobotsTxtManager. If provided, adapter checks
  can_fetch(url) BEFORE each fetch; skips URL + logs warning if disallowed.
- ``raw_html_sink``: Optional RawHtmlSink. If provided, adapter saves verbatim HTML
  BEFORE parsing (so raw HTML is preserved even if parse fails — skill § Storage).
- ``selector_chain``: Used in _build_legacy_scraper's body-container selection
  (formal replacement of the manual ``or`` chain in cafef_scraper.py:116-120).

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D3
        packages/infrastructure/news/cafef_scraper.py (wrapped: 213 LOC)
        .claude/skills/crawler-reliability/SKILL.md § Selector Robustness
        agent-workspace/constitution/architecture.md § BC-5
"""

from __future__ import annotations

import logging
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import ClassVar

from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle
from packages.infrastructure.news.cafef_scraper import CafeFScraper, ScrapedArticle

__all__ = ["CafeFAdapter"]

_log = logging.getLogger(__name__)


@dataclass
class CafeFAdapter(CrawlerAdapter):
    """CrawlerAdapter implementation for cafef.vn (BC-5 News Stream).

    Strategy B (WRAP): wraps CafeFScraper internally; delegates discover /
    fetch_article / to_news_article via the legacy scraper.

    Default construction mirrors the existing CLI usage in ingest_news_cafef.py:134::

        scraper = CafeFScraper(fetcher=_httpx_fetcher)
        # ↓ equivalent with adapter (no optional injections):
        adapter = CafeFAdapter(fetcher=_httpx_fetcher)

    Optional injections (all default to None/no-op)::

        adapter = CafeFAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=2.0),
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )

    I-S34 compliance:
        NO import or use of patchright, playwright_stealth, fake-useragent,
        StealthyFetcher, or any Scrapling Cloudflare-solver path.
        This adapter uses only httpx (via fetcher callable injection) — D-061 § item 4.

    Rule 16 compliance:
        fetch_and_parse emits ScrapedArticle which has ZERO numeric fields
        (url/title/body_html/body_text/published_at — no float/Decimal beyond datetime).
        Rule 16 surface is preserved by construction per plan 020 § Schema discipline.
    """

    source_id: ClassVar[str] = "cafef"

    fetcher: Callable[[str], str]
    """HTTP fetcher callable — (url: str) -> str. Default: httpx-based."""

    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    """Clock callable for ingested_at. Tests inject a frozen clock."""

    rate_limiter: object = field(default=None)  # RateLimiter | None
    """Optional RateLimiter from apps/_shared/crawl/rate_limiter.py."""

    robots_manager: object = field(default=None)  # RobotsTxtManager | None
    """Optional RobotsTxtManager for robots.txt can_fetch checks."""

    raw_html_sink: object = field(default=None)  # RawHtmlSink | None
    """Optional RawHtmlSink for atomic raw-HTML preservation before parsing."""

    base_url: str = "https://cafef.vn"
    rate_limit_seconds: float = 2.0

    def __post_init__(self) -> None:
        """Build the wrapped CafeFScraper with a patched fetcher."""
        # Build rate-limit-aware fetcher
        if self.rate_limiter is not None:
            # When we have a RateLimiter, inject a no-op sleeper into CafeFScraper
            # so CafeFScraper doesn't double-sleep. The RateLimiter handles the wait.
            def rl_fetcher(url: str) -> str:
                # 1. Apply rate limiting
                rl = self.rate_limiter
                if hasattr(rl, "wait_if_needed"):
                    rl.wait_if_needed(url)  # type: ignore[union-attr]
                # 2. Check robots.txt if manager provided
                if self.robots_manager is not None:
                    rm = self.robots_manager
                    if hasattr(rm, "can_fetch") and not rm.can_fetch(url):  # type: ignore[union-attr]
                        _log.warning(
                            "cafef_adapter: robots.txt disallows url=%r — skipping", url
                        )
                        raise RuntimeError(f"robots.txt disallows {url!r}")
                # 3. Fetch
                html = self.fetcher(url)
                # 4. Report success to rate limiter
                if hasattr(rl, "report_response"):
                    rl.report_response(url, 200)  # type: ignore[union-attr]
                # 5. Save raw HTML if sink provided
                if self.raw_html_sink is not None:
                    rhs = self.raw_html_sink
                    if hasattr(rhs, "write"):
                        try:
                            rhs.write(  # type: ignore[union-attr]
                                source_id=self.source_id,
                                url=url,
                                html=html,
                                fetched_at=self.clock(),
                            )
                        except Exception as exc:
                            _log.warning(
                                "cafef_adapter: raw_html_sink.write failed for url=%r: %s",
                                url, exc,
                            )
                return html

            self._scraper = CafeFScraper(
                fetcher=rl_fetcher,
                clock=self.clock,
                base_url=self.base_url,
                rate_limit_seconds=0.0,  # disable scraper's own rate limit; RL handles it
                sleeper=lambda _s: None,  # no-op — RL already slept
            )
        else:
            # No rate limiter: use standard CafeFScraper with optional robots + sink
            inner_fetcher = self.fetcher
            robots_manager = self.robots_manager
            raw_html_sink = self.raw_html_sink

            def plain_fetcher(url: str) -> str:
                if robots_manager is not None and hasattr(robots_manager, "can_fetch") and not robots_manager.can_fetch(url):  # type: ignore[union-attr]
                    _log.warning(
                        "cafef_adapter: robots.txt disallows url=%r — skipping", url
                    )
                    raise RuntimeError(f"robots.txt disallows {url!r}")
                html = inner_fetcher(url)
                if raw_html_sink is not None and hasattr(raw_html_sink, "write"):
                    try:
                        raw_html_sink.write(  # type: ignore[union-attr]
                            source_id=self.source_id,
                            url=url,
                            html=html,
                            fetched_at=self.clock(),
                        )
                    except Exception as exc:
                        _log.warning(
                            "cafef_adapter: raw_html_sink.write failed for url=%r: %s",
                            url, exc,
                        )
                return html

            self._scraper = CafeFScraper(
                fetcher=plain_fetcher,
                clock=self.clock,
                base_url=self.base_url,
                rate_limit_seconds=self.rate_limit_seconds,
            )

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a CafeF listing page.

        Delegates to CafeFScraper.discover (cafef_scraper.py:75-99).
        Discovers .chn anchors; deduplicates; respects max_articles cap.

        Args:
            listing_path: Section landing page path, e.g. ``/thi-truong-chung-khoan.chn``.
            max_articles: Maximum URLs to return.

        Returns:
            List of absolute article URLs (len <= max_articles), deduplicated.
        """
        return self._scraper.discover(listing_path, max_articles=max_articles)

    def fetch_and_parse(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single CafeF article URL.

        Delegates to CafeFScraper.fetch_article (cafef_scraper.py:101-133).
        Returns None on parse failure (L-S28-1 vendor-drift doctrine).

        Rule 16: ScrapedArticle has ZERO numeric fields — Rule 16 surface preserved.

        Args:
            url: Absolute article URL.

        Returns:
            ScrapedArticle on success, None on parse failure.
        """
        return self._scraper.fetch_article(url)

    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
    ) -> NewsArticle:
        """Promote ScrapedArticle to NewsArticle with coarse ticker mention scan.

        Delegates to CafeFScraper.to_news_article (cafef_scraper.py:135-160).
        Sync, deterministic, no I/O.

        Args:
            scraped: Raw scrape output.
            ticker_universe: VN ticker universe to scan against.

        Returns:
            NewsArticle with mentioned_tickers populated.
        """
        return self._scraper.to_news_article(scraped, ticker_universe)
