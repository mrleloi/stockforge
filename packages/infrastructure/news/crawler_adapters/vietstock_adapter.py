"""VietstockAdapter — CrawlerAdapter implementation for Vietstock (vietstock.vn).

Strategy A (direct-subclass) per plan-026 § DD-3.
Second consumer of SelectorChain[T] per plan-026 § DD-4 (after NDH at S344).

Site: vietstock.vn (canonical as of 2026-05-16 S354; finance.vietstock.vn is a
separate subdomain for financial tools — article news content lives on
vietstock.vn).

STEP 0 live verification (2026-05-16 S354):
- Canonical host: vietstock.vn (status=200; finance.vietstock.vn also 200 but
  is a separate financial-tools subdomain; article pages are on vietstock.vn)
- robots.txt: status=200; User-agent: * allows /; Disallow: /*.js /*.css
  /manager /export /cache; no Crawl-delay => default 2.0 s applies
- ToS: no explicit automated-access prohibition found at vietstock.vn footer
- JS-rendering: PASS (static HTML; no __NEXT_DATA__ / window.__INITIAL_STATE__
  markers; article body is server-rendered)
- Article URL pattern: /YYYY/MM/<slug>-<category_id>-<article_id>.htm
  (e.g. /2026/05/vn-index-tiep-tuc-lap-dinh-moi-830-1443435.htm)
- Headline: h1.article-title (primary) -> h1 (fallback) -> meta[og:title]
- Body: div#vst_detail[itemprop=articleBody] (primary) -> div.article-content
  (wide outer container fallback; less precise text)
- Date: meta[article:published_time] ISO-8601+tz -> meta[name=pubdate]
  ISO-8601+tz -> span.datenew format '%d-%m-%Y %H:%M:%S%z'
  Observed: '2026-05-16T21:02:00+07:00' (meta) + '16-05-2026 21:02:00+07:00'
  (span.datenew with explicit tz offset)

I-S34 compliance:
    NO import or use of patchright, playwright_stealth, fake-useragent,
    StealthyFetcher, or any Scrapling Cloudflare-solver path.
    Uses only httpx (via fetcher callable injection) -- D-061 item 4.

Rule 16 compliance:
    fetch_and_parse emits ScrapedArticle with ZERO numeric fields
    (url/title/body_html/body_text/published_at -- no float/Decimal beyond
    datetime). Rule 16 surface preserved by construction (plan-020/022/026
    Schema discipline).

D-059 compliance:
    R1 (datetime-no-tz): clock() returns tz-aware datetime; _parse_published_at
    always attaches tzinfo=UTC when absent.
    R2 (unseeded RNG): no RNG usage.
    R4 (time.time-in-domain): no time.time; clock injectable.

S345 F2-aware design (PROMOTED FROM NDH POST-FIX):
    _fetch_with_optional_chain accepts keyword-only store_raw: bool = True;
    discover() passes store_raw=False to avoid listing-page HTML contamination
    of data/raw/news/vietstock/ (architected from day 1; NOT post-S345 retrofit).

Source: plan 026-S353-phase-d-vietstock-adapter.md Sub-track D1
        STEP 0 live verification recorded in session log 2026-05-16-session-354.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/ndh_adapter.py (sibling
        reference -- same Strategy A shape; F2 fix already applied)
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

# Reuse ScrapedArticle from cafef_scraper -- same pragmatic choice NDH made at
# ndh_adapter.py:68. Carry-forward note: future ADR may promote to
# packages/contracts/scraped_article.py (out-of-scope this bundle per plan-026 D1).
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["VietstockAdapter"]

_log = logging.getLogger(__name__)

# STEP 0.1 verified 2026-05-16: vietstock.vn is the canonical host for
# article-level news content. finance.vietstock.vn is a financial-tools
# subdomain (screening, analysis) -- article pages live on vietstock.vn.
_DEFAULT_VIETSTOCK_BASE_URL = "https://vietstock.vn"
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
# STEP 0.2 verified 2026-05-16: no Crawl-delay directive in robots.txt;
# default 2.0 s applies per plan-026 DD-5.
_DEFAULT_RATE_LIMIT_SECONDS = 2.0

# STEP 0.4 verified 2026-05-16: article URL pattern
# Examples: /2026/05/vn-index-tiep-tuc-lap-dinh-moi-830-1443435.htm
#           /2026/05/chu-tich-dang-huynh-uc-my-muon-nang-so-huu-tai-agris-739-1443097.htm
# Structure: /YYYY/MM/<slug>-<category_id>-<article_id>.htm
# Regex: path contains /YYYY/MM/ prefix and ends with -<digits>-<digits>.htm
_ARTICLE_URL_RE = re.compile(r"/\d{4}/\d{2}/[a-z0-9-]+-\d+-\d+\.htm$")


@dataclass
class VietstockAdapter(CrawlerAdapter):
    """CrawlerAdapter for vietstock.vn (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for headline + body
    extraction. Date extraction uses a fmt-string fallback chain inside
    _parse_published_at. Uses BeautifulSoup for HTML parsing.

    Greenfield -- no legacy class to wrap (Strategy A per plan-026 DD-3).
    Second consumer of SelectorChain[T] after NDH (plan-022 S344).

    Default construction::

        adapter = VietstockAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = VietstockAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=2.0),
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "vietstock"

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

    base_url: str = _DEFAULT_VIETSTOCK_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    # ------------------------------------------------------------------
    # CrawlerAdapter abstract method implementations
    # ------------------------------------------------------------------

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a Vietstock listing or section page.

        Args:
            listing_path: Site-relative path, e.g. ``/chung-khoan.htm``
                or ``/tin-tuc``. Also accepts absolute URL.
            max_articles: Maximum article URLs to return (deduplicated).

        Returns:
            List of absolute article URLs, len <= max_articles, deduplicated.

        STEP 0.4 URL pattern (verified 2026-05-16):
            Article URLs match /YYYY/MM/<slug>-<cat>-<id>.htm
            (e.g. /2026/05/vn-index-tiep-tuc-lap-dinh-moi-830-1443435.htm).
            Navigation, category, and subdomain links are excluded.

        Note: per DD-7 F2-aware design, listing-page HTML is NOT persisted
        (store_raw=False) -- avoids contamination of data/raw/news/vietstock/.
        """
        from bs4 import BeautifulSoup

        html = self._fetch_with_optional_chain(
            self._absolute(listing_path), store_raw=False  # DD-7 F2-aware
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
        """Fetch + parse a single Vietstock article URL.

        Per L-S28-1 vendor-drift doctrine: returns None on parse failure
        (degrade gracefully). Raises on network failure (caller logs + skips).

        SelectorChain[T] usage (DD-4 plan-026):
            Two SelectorChain[Tag] instances constructed per call (closure
            over soup). Cheap frozen-dataclass instantiation (~10 ns each).
            Headline and body chains use SelectorChain for instrumented
            fallback. Date uses fmt-string chain inside _parse_published_at.

        Rule 16: ScrapedArticle has ZERO numeric fields.
        """
        from bs4 import BeautifulSoup, Tag

        try:
            html = self._fetch_with_optional_chain(url)  # default store_raw=True
        except Exception as exc:
            _log.warning("vietstock_adapter: fetch failed for url=%r: %s", url, exc)
            return None

        soup = BeautifulSoup(html, "html.parser")

        # ---- Headline chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: h1.article-title (observed on sample article)
        # Fallback 1: any h1 (generic)
        # Fallback 2: meta og:title (always present; strip " | Vietstock" suffix)
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("h1", class_="article-title"),
                lambda: soup.find("h1"),
                lambda: soup.find("meta", attrs={"property": "og:title"}),
            ],
            label="vietstock_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            _log.warning("vietstock_adapter: no headline found for url=%r", url)
            return None

        # Extract text: meta tags use 'content' attribute; element tags use text
        if isinstance(headline_tag, Tag) and headline_tag.name == "meta":
            raw_title = cast(str, headline_tag.get("content", ""))
            # Strip " | Vietstock" suffix from og:title if present
            title = raw_title.split(" | ")[0].strip()
        else:
            title = headline_tag.get_text(strip=True)
        if not title:
            _log.warning("vietstock_adapter: empty title for url=%r", url)
            return None

        # ---- Body container chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: div#vst_detail[itemprop=articleBody] (STEP 0.4: most precise;
        #   contains the actual article paragraphs; text_len=307 for sample)
        # Fallback: div.article-content (outer container; may include nav/social)
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("div", attrs={"id": "vst_detail", "itemprop": "articleBody"}),
                lambda: soup.find("div", id="vst_detail"),
                lambda: soup.find("div", class_="article-content"),
            ],
            label="vietstock_body_container",
        )
        body_container, _ = body_chain.apply()
        if body_container is None:
            _log.warning("vietstock_adapter: no body container for url=%r", url)
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            _log.warning("vietstock_adapter: empty body for url=%r", url)
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

        Mirrors NDHAdapter.to_news_article (ndh_adapter.py:265-300):
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
            source="vietstock",
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

        Pattern mirrors NDHAdapter._fetch_with_optional_chain shape at
        ndh_adapter.py:306-353 (post-S345 F2-fix shape).

        Args:
            url: Absolute URL to fetch.
            store_raw: When True (default; article-fetch path), persist HTML via
                raw_html_sink if provided. When False (discover/listing path),
                skip the sink -- listing-page HTML is not the unit of reprocessing
                and would pollute the article preservation dataset. DD-7 F2-aware
                design architected from day 1 (not post-S345 retrofit like NDH).
        """
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)  # type: ignore[union-attr]

        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):  # type: ignore[union-attr]
            _log.warning(
                "vietstock_adapter: robots.txt disallows url=%r -- skipping", url
            )
            raise RuntimeError(f"robots.txt disallows {url!r}")

        html = self.fetcher(url)

        if rl is not None and hasattr(rl, "report_response"):
            rl.report_response(url, 200)  # type: ignore[union-attr]

        if store_raw:  # DD-7: only article-fetch path persists raw HTML
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
                        "vietstock_adapter: raw_html_sink.write failed for url=%r: %s",
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
        """Return True if href looks like a Vietstock article URL.

        STEP 0.4 verified 2026-05-16: article URLs follow the pattern
        /YYYY/MM/<slug>-<category_id>-<article_id>.htm
        (e.g. /2026/05/vn-index-tiep-tuc-lap-dinh-moi-830-1443435.htm).
        Excludes navigation pages (/chung-khoan.htm, /bat-dong-san/),
        finance.vietstock.vn subdomain links (//finance.vietstock.vn/...),
        and static pages (/Gioi-thieu.htm, /Sitemap.htm).
        """
        if not href or not href.startswith("/"):
            return False
        # Exclude protocol-relative (//host/path) links to other subdomains
        if href.startswith("//"):
            return False
        return bool(_ARTICLE_URL_RE.search(href))

    @staticmethod
    def _parse_published_at(soup: object) -> datetime | None:
        """Best-effort publish-date parse using tag candidates + fmt-string chain.

        Date tag priority (STEP 0.4 verified 2026-05-16):
        1. meta[property=article:published_time] -- content=ISO-8601+tz
           Observed: '2026-05-16T21:02:00+07:00'
        2. meta[name=pubdate] -- content=ISO-8601+tz
           Observed: '2026-05-16T21:02:00+07:00'
        3. span.datenew -- text contains date string with tz offset
           Observed: '16-05-2026 21:02:00+07:00' (format: %d-%m-%Y %H:%M:%S%z)

        Format string fallback list (verified from STEP 0.4 sample HTML):
        - %Y-%m-%dT%H:%M:%S%z  (ISO-8601 with tz offset, e.g. +07:00)
        - %Y-%m-%dT%H:%M:%S    (ISO-8601 without tz -- attach UTC)
        - %d-%m-%Y %H:%M:%S%z  (Vietstock span.datenew format with tz)
        - %d-%m-%Y %H:%M:%S    (Vietstock span.datenew format without tz)
        - %d-%m-%Y %H:%M       (Vietstock short format)
        - %d/%m/%Y %H:%M       (Vietnamese locale alternative)

        Returns None when no tag/format matches; caller falls back to clock().
        D-059 R1 compliance: always returns tz-aware datetime (UTC attached when
        absent).
        """
        from bs4 import BeautifulSoup, Tag

        if not isinstance(soup, BeautifulSoup):
            return None

        # Priority 1 + 2: meta tags (most reliable; always present)
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
                "%d-%m-%Y %H:%M:%S%z",
                "%d-%m-%Y %H:%M:%S",
                "%d-%m-%Y %H:%M",
                "%d/%m/%Y %H:%M",
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

        # Priority 3: span.datenew (Vietstock-specific; text = 'DD-MM-YYYY HH:MM:SS+TZ')
        # Observed: '16-05-2026 21:02:00+07:00'
        datenew = soup.find("span", class_="datenew")
        if isinstance(datenew, Tag):
            text = datenew.get_text(strip=True)
            for fmt in (
                "%d-%m-%Y %H:%M:%S%z",
                "%d-%m-%Y %H:%M:%S",
                "%d-%m-%Y %H:%M",
                "%d/%m/%Y %H:%M",
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
