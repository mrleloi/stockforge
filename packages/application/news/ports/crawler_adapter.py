# Portions adapted from Crawl4AI (https://github.com/unclecode/crawl4ai),
# Apache-2.0 + Attribution Requirement; see NOTICE at repo root for full text.
# Source pattern: crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__ typecheck)
"""CrawlerAdapter — abstract port for per-source crawlers in BC-5 News Stream.

Architecture:
- Port (ABC) lives in the application layer (this file) per stockforge convention
  (architecture.md § BC-5: domain = pure, application = ports, infra = adapters).
- Concrete adapters live in packages/infrastructure/news/crawler_adapters/.
- The CLI dispatches via CrawlerRegistry.get(source_id).

Design decisions (plan 020 § DD-1 through DD-7):
- ABC over Protocol: runtime-enforced contract via __init_subclass__ (DD-3).
- SYNC interface: async deferred to Phase 3; CLI loop is synchronous (DD-2).
- source_id ClassVar enforced non-empty at class-definition time (DD-1 / DD-3).
- One subclass per news source for VN-specific HTML parsing (DD-4).
- Instance-scoped CrawlerRegistry refactors the crawl4ai global-state pattern (DD-5).

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md
        crawl4ai/hub.py:12-35 (BaseCrawler ABC + __init_subclass__)
        agent-workspace/constitution/architecture.md § BC-5
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Iterable
from typing import TYPE_CHECKING, ClassVar

from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

if TYPE_CHECKING:
    # Imported under TYPE_CHECKING to avoid the circular import:
    # application.ports.crawler_adapter → infra.cafef_scraper (via module path)
    # → infra.__init__ → infra.crawler_adapters.cafef_adapter → application.ports
    # At runtime, ScrapedArticle is resolved lazily; mypy sees the type correctly.
    from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["CrawlerAdapter"]


class CrawlerAdapter(ABC):
    """Abstract port for per-source crawlers in BC-5 News Stream.

    Subclasses MUST:
    - Declare a non-empty ``source_id`` ClassVar (e.g. ``source_id = "cafef"``).
      Violation raises TypeError at class-definition time (not at instantiation).
    - Implement the three abstract methods below.

    Subclasses MUST NOT:
    - Import patchright, playwright_stealth, fake-useragent, StealthyFetcher,
      or any Scrapling Cloudflare-solver path (I-S34 HARD REJECT / D-061 § Decision item 4).
    - Emit new LLM-numeric fields in fetch_and_parse or discover output
      (Rule 16 / D-065 binding — the crawler surface is numeric-free by construction).
    """

    source_id: ClassVar[str]  # enforced non-empty via __init_subclass__

    def __init_subclass__(cls, **kwargs: object) -> None:
        """Enforce non-empty source_id at subclass definition time.

        Pattern adapted from crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__
        typecheck). Unlike crawl4ai which checks async run() signature, this checks
        source_id ClassVar to ensure registry keying is safe at definition time rather
        than at instantiation or first use.

        Raises:
            TypeError: If the subclass does not declare a non-empty source_id ClassVar.
        """
        super().__init_subclass__(**kwargs)
        # Abstract base itself has no source_id — allow it; concrete subclasses must have one.
        if not getattr(cls, "source_id", "").strip():
            raise TypeError(
                f"{cls.__name__} must declare a non-empty source_id ClassVar "
                f"(e.g. source_id = \"cafef\"). "
                f"Pattern: crawl4ai/hub.py:24-35."
            )

    @abstractmethod
    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a listing page.

        Args:
            listing_path: Source-relative listing path, e.g. ``/thi-truong-chung-khoan.chn``.
            max_articles: Maximum URLs to return (deduplicated).

        Returns:
            List of absolute article URLs, length <= max_articles, deduplicated.

        Rate-limiting is applied internally; callers do not sleep.
        Per L-S28-1 vendor-drift doctrine: on fetch failure, raise (caller degrades gracefully).
        """

    @abstractmethod
    def fetch_and_parse(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single article URL.

        Args:
            url: Absolute URL to fetch.

        Returns:
            ScrapedArticle on success, None on graceful parse failure
            (L-S28-1 vendor-drift doctrine — degrade gracefully, never raise on parse).
            Raises on network failure so the CLI can log and continue.

        Rule 16 compliance: this method MUST NOT populate any LLM-emitted numeric
        field. The ScrapedArticle output is numeric-free (url/title/body_html/
        body_text/published_at — no float/Decimal beyond datetime).
        """

    @abstractmethod
    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
    ) -> NewsArticle:
        """Promote ScrapedArticle to NewsArticle (coarse-scan ticker mentions).

        Args:
            scraped: Raw scrape output (title + body + published_at).
            ticker_universe: VN ticker universe to scan against.

        Returns:
            NewsArticle with mentioned_tickers populated by coarse text scan.
            Sync, deterministic, no I/O, no LLM call.
        """
