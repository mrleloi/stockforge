"""NDHAdapter — CrawlerAdapter implementation for NDH (Nhip Song Kinh Doanh).

Strategy A (direct-subclass) per plan-022 S343 DD-3.
First consumer of SelectorChain[T] per plan-022 DD-4 (closes plan-020 F2
carry-forward documented in ADR D-066 Out-of-scope item 12).

Site: nhipsongkinhdoanh.vn (canonical as of 2026-05-16; nhipsongdoanhnghiep.vn
redirects here; ndh.vn DNS did not resolve during STEP 0).

STEP 0 live verification (2026-05-16 S344):
- Canonical host: nhipsongkinhdoanh.vn (status 200; nhipsongdoanhnghiep.vn
  redirects; ndh.vn DNS-failed)
- robots.txt: status 200; User-agent: * Allow: /; Disallow: /misc/language;
  no Crawl-delay directive => use default 2.0 s
- ToS: no explicit automated-access prohibition found in footer links
- JS-rendering: PASS (static HTML; no __NEXT_DATA__ / window.__INITIAL_STATE__
  markers)
- Article URL pattern: /slug-{numeric_id}.htm (e.g. /co-phieu-28729.htm)
- Headline: h1[class contains article__title] -> h1 -> meta[og:title]
- Body: div.article-content -> article
- Date: meta[article:published_time] -> meta[pubdate] -> time[datetime]
  ISO-8601 with timezone offset observed: 2026-05-16T14:46:39+07:00

I-S34 compliance:
    NO import or use of patchright, playwright_stealth, fake-useragent,
    StealthyFetcher, or any Scrapling Cloudflare-solver path.
    Uses only httpx (via fetcher callable injection) -- D-061 item 4.

Rule 16 compliance:
    fetch_and_parse emits ScrapedArticle with ZERO numeric fields
    (url/title/body_html/body_text/published_at -- no float/Decimal beyond
    datetime). Rule 16 surface preserved by construction (plan-020 Schema
    discipline).

D-059 compliance:
    R1 (datetime-no-tz): clock() returns tz-aware datetime; _parse_published_at
    always attaches tzinfo=UTC when absent.
    R2 (unseeded RNG): no RNG usage.
    R4 (time.time-in-domain): no time.time; clock injectable.

Source: plan 022-S343-phase-d-ndh-adapter.md Sub-track D1
        STEP 0 live verification recorded in session log 2026-05-16-session-344.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/cafef_adapter.py (sibling)
"""

from __future__ import annotations

import hashlib
import logging
import re
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import TYPE_CHECKING, ClassVar, cast

from apps._shared.crawl.selector_chain import SelectorChain
from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

if TYPE_CHECKING:
    from bs4 import Tag

# Reuse ScrapedArticle from cafef_scraper -- identical shape; carry-forward
# note: future ADR may promote to packages/contracts/scraped_article.py for
# cleaner cross-adapter sharing (out-of-scope this bundle per plan-022 D1).
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["NDHAdapter"]

_log = logging.getLogger(__name__)

# STEP 0.1 verified 2026-05-16: nhipsongkinhdoanh.vn is the canonical host.
# nhipsongdoanhnghiep.vn redirects here; ndh.vn DNS-failed.
_DEFAULT_NDH_BASE_URL = "https://nhipsongkinhdoanh.vn"
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
# STEP 0.2 verified 2026-05-16: no Crawl-delay directive in robots.txt;
# default 2.0 s applies per plan-022 DD-5.
_DEFAULT_RATE_LIMIT_SECONDS = 2.0

# STEP 0.4 verified 2026-05-16: article URLs end with a numeric ID + .htm
# Pattern examples: /co-phieu-pow-28729.htm, /gia-xang-co-the-giam-28731.htm
# Regex: path ends with -{digits}.htm (numeric suffix before extension).
_ARTICLE_URL_RE = re.compile(r"-\d+\.htm$")


@dataclass
class NDHAdapter(CrawlerAdapter):
    """CrawlerAdapter for nhipsongkinhdoanh.vn (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for headline + body
    extraction. Date extraction uses a fmt-string fallback chain inside
    _parse_published_at. Uses BeautifulSoup for HTML parsing.

    Greenfield -- no legacy class to wrap (Strategy A per plan-022 DD-3).

    Default construction::

        adapter = NDHAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = NDHAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=2.0),
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "ndh"

    fetcher: Callable[[str], str]
    """HTTP fetcher callable -- (url: str) -> str."""

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

    base_url: str = _DEFAULT_NDH_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    # ------------------------------------------------------------------
    # CrawlerAdapter abstract method implementations
    # ------------------------------------------------------------------

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from an NDH listing or section page.

        Args:
            listing_path: Site-relative path, e.g. ``/hashtag/chung-khoan-9``
                or ``/thi-truong-chung-khoan``. Also accepts absolute URL.
            max_articles: Maximum article URLs to return (deduplicated).

        Returns:
            List of absolute article URLs, len <= max_articles, deduplicated.

        STEP 0.4 URL pattern (verified 2026-05-16):
            Article URLs match /-\\d+\\.htm$ (e.g. /co-phieu-pow-28729.htm).
            Listing-page anchors with /hashtag/ or /cms/ paths are excluded.
        """
        from bs4 import BeautifulSoup

        html = self._fetch_with_optional_chain(
            self._absolute(listing_path), store_raw=False
        )
        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        seen: set[str] = set()
        for anchor in soup.find_all("a", href=True):
            href = cast(str, anchor["href"])
            if not self._is_article_url(href):
                continue
            absolute = self._absolute(href)
            if absolute in seen:
                continue
            seen.add(absolute)
            urls.append(absolute)
            if len(urls) >= max_articles:
                break
        return urls

    def fetch_and_parse(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single NDH article URL.

        Per L-S28-1 vendor-drift doctrine: returns None on parse failure
        (degrade gracefully). Raises on network failure (caller logs + skips).

        SelectorChain[T] usage (DD-4 plan-022):
            Three SelectorChain[Tag] instances constructed per call (closure
            over soup). Cheap frozen-dataclass instantiation (~10 ns each).
            Headline and body chains use SelectorChain for instrumented
            fallback. Date uses fmt-string chain inside _parse_published_at.

        Rule 16: ScrapedArticle has ZERO numeric fields.
        """
        from bs4 import BeautifulSoup, Tag

        try:
            html = self._fetch_with_optional_chain(url)
        except Exception as exc:
            _log.warning("ndh_adapter: fetch failed for url=%r: %s", url, exc)
            return None

        soup = BeautifulSoup(html, "html.parser")

        # ---- Headline chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: h1 with class 'article__title' (observed on sample article)
        # Fallback 1: any h1 (generic)
        # Fallback 2: meta og:title (always present as meta)
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find(  # type: ignore[return-value]
                    "h1", class_="article__title"
                ),
                lambda: soup.find("h1"),  # type: ignore[return-value]
                lambda: soup.find(  # type: ignore[return-value]
                    "meta", attrs={"property": "og:title"}
                ),
            ],
            label="ndh_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            _log.warning("ndh_adapter: no headline found for url=%r", url)
            return None

        # Extract text: meta tags use 'content' attribute; element tags use text
        if isinstance(headline_tag, Tag) and headline_tag.name == "meta":
            title = cast(str, headline_tag.get("content", ""))
        else:
            title = headline_tag.get_text(strip=True)
        if not title:
            _log.warning("ndh_adapter: empty title for url=%r", url)
            return None

        # ---- Body container chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: div.article-content (observed on sample article; len=3439)
        # Fallback: article (semantic HTML fallback)
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find(  # type: ignore[return-value]
                    "div", class_="article-content"
                ),
                lambda: soup.find("article"),  # type: ignore[return-value]
            ],
            label="ndh_body_container",
        )
        body_container, _ = body_chain.apply()
        if body_container is None:
            _log.warning("ndh_adapter: no body container for url=%r", url)
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            _log.warning("ndh_adapter: empty body for url=%r", url)
            return None

        # ---- Date extraction (fmt-string chain in _parse_published_at) ----
        # Returns None on failure; caller falls back to clock() (ingested_at)
        published_at = self._parse_published_at(soup) or self.clock()

        return ScrapedArticle(
            url=url,
            title=title,
            body_html=str(body_container),
            body_text=body_text,
            published_at=published_at,
        )

    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
        excerpt_chars: int = 4000,
    ) -> NewsArticle:
        """Promote ScrapedArticle to NewsArticle with coarse ticker mention scan.

        Mirrors CafeFScraper.to_news_article (cafef_scraper.py:135-160):
        coarse case-sensitive symbol scan over title + body_text.

        Args:
            scraped: Raw scrape output.
            ticker_universe: VN ticker universe to scan against.
            excerpt_chars: Maximum body_excerpt length (default 4000).

        Returns:
            NewsArticle with mentioned_tickers populated.

        Rule 16: no LLM-emitted numeric field; mentioned_tickers is a tuple
        of Ticker value objects (strings), not numbers.
        """
        haystack = f"{scraped.title}\n{scraped.body_text}"
        mentioned = tuple(t for t in ticker_universe if t.symbol in haystack)
        article_id = hashlib.sha256(scraped.url.encode()).hexdigest()[:16]
        return NewsArticle(
            article_id=article_id,
            source="ndh",
            source_url=scraped.url,
            title=scraped.title,
            body_excerpt=scraped.body_text[:excerpt_chars],
            published_at=scraped.published_at,
            ingested_at=self.clock(),
            mentioned_tickers=mentioned,
            language="vi",
        )

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _fetch_with_optional_chain(self, url: str, *, store_raw: bool = True) -> str:
        """Fetch with rate-limit + robots-check + raw-html-sink chain (all optional).

        Pattern mirrors CafeFAdapter._fetch_with_optional_chain shape at
        cafef_adapter.py:112-146 (rl_fetcher path).

        Args:
            url: Absolute URL to fetch.
            store_raw: When True (default; article-fetch path), persist HTML via
                raw_html_sink if provided. When False (discover/listing path),
                skip the sink — listing-page HTML is not the unit of reprocessing
                and would pollute the article preservation dataset. F2 fix per
                S345 sandwich-verifier (data contamination defect).
        """
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)  # type: ignore[union-attr]

        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):  # type: ignore[union-attr]
            _log.warning(
                "ndh_adapter: robots.txt disallows url=%r -- skipping", url
            )
            raise RuntimeError(f"robots.txt disallows {url!r}")

        html = self.fetcher(url)

        if rl is not None and hasattr(rl, "report_response"):
            rl.report_response(url, 200)  # type: ignore[union-attr]

        if store_raw:
            rhs = self.raw_html_sink
            if rhs is not None and hasattr(rhs, "write"):
                try:
                    rhs.write(  # type: ignore[union-attr]
                        source_id=self.source_id,
                        url=url,
                        html=html,
                        fetched_at=self.clock(),
                    )
                except Exception as exc:
                    _log.warning(
                        "ndh_adapter: raw_html_sink.write failed for url=%r: %s",
                        url,
                        exc,
                    )

        return html

    def _absolute(self, href: str) -> str:
        """Make href absolute using base_url."""
        if href.startswith("http://") or href.startswith("https://"):
            return href
        if href.startswith("/"):
            return f"{self.base_url}{href}"
        return f"{self.base_url}/{href}"

    @staticmethod
    def _is_article_url(href: str) -> bool:
        """Return True if href looks like an NDH article URL.

        STEP 0.4 verified 2026-05-16: article URLs end with -{numeric_id}.htm
        (e.g. /co-phieu-pow-28729.htm). Exclude /hashtag/, /cms/, /misc/,
        anchors (javascript:), and listing/category paths.
        """
        if not href or not href.startswith("/"):
            return False
        # Exclude known non-article paths
        for prefix in ("/hashtag/", "/cms/", "/misc/", "javascript:"):
            if href.startswith(prefix):
                return False
        # Must match article URL pattern: ends with -{digits}.htm
        return bool(_ARTICLE_URL_RE.search(href))

    @staticmethod
    def _parse_published_at(soup: object) -> datetime | None:
        """Best-effort publish-date parse using tag candidates + fmt-string chain.

        Date tag priority (STEP 0.4 verified 2026-05-16):
        1. meta[property=article:published_time] -- content=ISO-8601+tz
        2. meta[name=pubdate] -- content=ISO-8601+tz
        3. time[datetime] -- attribute contains Vietnamese date string
           (e.g. "Thu bay, 16/05/2026 | 14:46")

        Format string fallback list (verified from sample HTML):
        - %Y-%m-%dT%H:%M:%S%z  (ISO-8601 with tz offset, e.g. +07:00)
        - %Y-%m-%dT%H:%M:%S    (ISO-8601 without tz -- attach UTC)
        - %d-%m-%Y %H:%M:%S    (legacy VN format)
        - %d-%m-%Y %H:%M       (legacy VN format short)
        - %Y-%m-%d %H:%M:%S    (ISO-date with time)

        Returns None when no tag/format matches; caller falls back to clock().
        D-059 R1 compliance: always returns tz-aware datetime (UTC attached when
        absent).
        """
        from bs4 import BeautifulSoup, Tag

        if not isinstance(soup, BeautifulSoup):
            return None

        # STEP 0.4: primary candidates are meta tags (most reliable; always
        # present even when JS rewrites display elements)
        for tag_name, attr_key, attr_value in (
            ("meta", "property", "article:published_time"),
            ("meta", "name", "pubdate"),
        ):
            tag = soup.find(tag_name, {attr_key: attr_value})
            if not isinstance(tag, Tag):
                continue
            text = cast(str, tag.get("content", ""))
            if not text:
                continue
            for fmt in (
                "%Y-%m-%dT%H:%M:%S%z",
                "%Y-%m-%dT%H:%M:%S",
                "%d-%m-%Y %H:%M:%S",
                "%d-%m-%Y %H:%M",
                "%Y-%m-%d %H:%M:%S",
            ):
                try:
                    parsed = datetime.strptime(text, fmt)
                    return (
                        parsed
                        if parsed.tzinfo is not None
                        else parsed.replace(tzinfo=UTC)
                    )
                except ValueError:
                    continue

        # Fallback: time[datetime] attribute (observed as Vietnamese text;
        # skipped if not parseable by any fmt -- caller falls back to clock())
        time_tag = soup.find("time", attrs={"datetime": True})
        if isinstance(time_tag, Tag):
            text = cast(str, time_tag.get("datetime", ""))
            for fmt in (
                "%Y-%m-%dT%H:%M:%S%z",
                "%Y-%m-%dT%H:%M:%S",
                "%d-%m-%Y %H:%M:%S",
                "%d-%m-%Y %H:%M",
            ):
                try:
                    parsed = datetime.strptime(text, fmt)
                    return (
                        parsed
                        if parsed.tzinfo is not None
                        else parsed.replace(tzinfo=UTC)
                    )
                except ValueError:
                    continue

        return None
