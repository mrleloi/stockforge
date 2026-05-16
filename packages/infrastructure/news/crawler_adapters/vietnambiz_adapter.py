"""VietnamBizAdapter — CrawlerAdapter implementation for VietnamBiz (vietnambiz.vn).

Strategy A (direct-subclass) per plan-027 § DD-3.
Third + FINAL consumer of SelectorChain[T] per plan-027 § DD-4
(after NDH at S344 + Vietstock at S354).

Site: vietnambiz.vn (canonical as of 2026-05-16 S357; verified STEP 0.1 below).
Note: plan-020 § E matrix line 354 listed URL as "vietstockfinance.vn" which
was a typo; correct URL is vietnambiz.vn per plan-027 STEP 0.1 verification.

STEP 0 live verification (2026-05-16 S357):
- Canonical host: vietnambiz.vn (status=200; www.vietnambiz.vn redirects to
  vietnambiz.vn; response bytes=243896)
- robots.txt: status=200; User-agent: * Allow: /; no Crawl-delay directive
  => default 3.0 s applies per plan-027 DD-5 (skill flag VietnamBiz less
  lenient than CafeF; conservative bump; Crawl-delay absent so 3.0s stands)
- ToS: robots.txt explicitly allows all paths; no automated-access prohibition
  found in robots.txt policy (only 23-byte file: User-agent: * / Allow: /)
- JS-rendering: PASS (static HTML; no __NEXT_DATA__ / window.__INITIAL_STATE__
  markers; article body is server-rendered)
- Article URL pattern: /<slug>-<YYYYMMDDHHMMSSXXX>.htm
  (e.g. /dragon-capital-dung-voi-goi-co-phieu-ho-vin-dang-o-vung-dinh-2026516161819153.htm)
  Structure: slug is lowercase hyphen-separated; ID is 15+ digit timestamp-based
  Regex: path matches /<slug>-<15+digits>.htm (and NOT -print.htm suffix)
- Headline: h1.vnbcb-title (primary) -> h1 (fallback) -> meta[og:title]
- Body: div.vnbcb-content (primary; text_len=5335 on sample article)
  -> div.post-body-content (fallback outer wrapper)
  -> article (generic fallback)
- Date: meta[article:published_time] ISO-8601 WITHOUT tz offset
  (e.g. '2026-05-16T16:33:00' — no +07:00; treat as UTC+7 / attach UTC)
  -> span.vnbcba-time format 'HH:MM | DD/MM/YYYY'

I-S34 compliance:
    NO import or use of patchright, playwright_stealth, fake-useragent,
    StealthyFetcher, or any Scrapling Cloudflare-solver path.
    Uses only httpx (via fetcher callable injection) -- D-061 item 4.

Rule 16 compliance:
    fetch_and_parse emits ScrapedArticle with ZERO numeric fields
    (url/title/body_html/body_text/published_at -- no float/Decimal beyond
    datetime). Rule 16 surface preserved by construction (plan-020/022/026/027
    Schema discipline).

D-059 compliance:
    R1 (datetime-no-tz): clock() returns tz-aware datetime; _parse_published_at
    always attaches tzinfo=UTC when absent.
    R2 (unseeded RNG): no RNG usage.
    R4 (time.time-in-domain): no time.time; clock injectable.

S345 F2-aware design (PROMOTED — n=2 day-one precedent established at Vietstock):
    _fetch_with_optional_chain accepts keyword-only store_raw: bool = True;
    discover() passes store_raw=False to avoid listing-page HTML contamination
    of data/raw/news/vietnambiz/ (architected from day 1; n=3 store_raw
    presence; n=2 day-one ship; L-S345-3 PROMOTE-NOW trigger condition).

Rate-limit posture (DD-5):
    base_delay = 3.0s default per plan-020 § E matrix line 354 + skill
    .claude/skills/crawler-reliability/SKILL.md § Rate Limiting
    "VietnamBiz less lenient than CafeF" -- conservative bump from
    CafeF/NDH/Vietstock 2.0s default. FIRST per-source rate-bump in BC-5 suite.
    STEP 0.2 confirmed no Crawl-delay directive; 3.0s default stands.

Source: plan 027-S356-phase-d-vietnambiz-adapter.md Sub-track D1
        STEP 0 live verification recorded in session log 2026-05-16-session-357.md
        apps/_shared/crawl/selector_chain.py (SelectorChain[T] primitive)
        packages/infrastructure/news/crawler_adapters/vietstock_adapter.py
        (sibling reference -- 2nd Strategy A; F2-day-one shape proven)
"""

from __future__ import annotations

import hashlib
import logging
import re
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime, timedelta, timezone
from typing import TYPE_CHECKING, ClassVar, cast

from apps._shared.crawl.selector_chain import SelectorChain
from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

if TYPE_CHECKING:
    from bs4 import Tag

# Reuse ScrapedArticle from cafef_scraper -- same pragmatic choice NDH + Vietstock
# made at ndh_adapter.py:68 + vietstock_adapter.py:78. Carry-forward note: future
# ADR may promote to packages/contracts/scraped_article.py (out-of-scope this
# bundle per plan-027 D1; at n=3 consumers the case strengthens but architect
# defers per RM12).
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

__all__ = ["VietnamBizAdapter"]

_log = logging.getLogger(__name__)

# Vietnam Standard Time: UTC+7 (no DST)
# Used when datetime strings from VietnamBiz have no timezone suffix.
# STEP 0.4 confirmed meta[article:published_time] is local VN time with no tz info
# (e.g. '2026-05-16T16:33:00' = 16:33 local = 09:33 UTC).
_TZ_VN = timezone(timedelta(hours=7))

# STEP 0.1 verified 2026-05-16: vietnambiz.vn is the canonical host.
# www.vietnambiz.vn redirects to vietnambiz.vn (both return 200 at final URL).
_DEFAULT_VIETNAMBIZ_BASE_URL = "https://vietnambiz.vn"
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)
# STEP 0.2 verified 2026-05-16: robots.txt present, User-agent: * Allow: /,
# no Crawl-delay directive. 3.0s default applies per plan-027 DD-5
# (skill flag: VietnamBiz less lenient than CafeF; conservative bump over 2.0s).
_DEFAULT_RATE_LIMIT_SECONDS = 3.0

# STEP 0.4 verified 2026-05-16: article URL pattern.
# Examples:
#   /dragon-capital-dung-voi-goi-co-phieu-ho-vin-dang-o-vung-dinh-2026516161819153.htm
#   /nhom-quy-quy-mo-gan-2-ty-usd-cua-dragon-capital-mua-tro-lai-co-phieu-ho-vin-20265159339901.htm
# Structure: /<lowercase-hyphen-slug>-<15+digit-timestamp-id>.htm
# Exclude: -print.htm suffix (printer-friendly variant)
_ARTICLE_URL_RE = re.compile(r"^/[a-z0-9-]+-\d{15,}\.htm$")


@dataclass
class VietnamBizAdapter(CrawlerAdapter):
    """CrawlerAdapter for vietnambiz.vn (BC-5 News Stream).

    Strategy A (direct-subclass): implements discover / fetch_and_parse /
    to_news_article from scratch using SelectorChain[T] for headline + body
    extraction. Date extraction uses a fmt-string fallback chain inside
    _parse_published_at. Uses BeautifulSoup for HTML parsing.

    Greenfield -- no legacy class to wrap (Strategy A per plan-027 DD-3).
    Third + FINAL consumer of SelectorChain[T] (Phase D Theme L per-source
    rollout closes after this adapter; n=3 maturity threshold).

    Default construction::

        adapter = VietnamBizAdapter(fetcher=_httpx_fetcher)

    With full injections::

        adapter = VietnamBizAdapter(
            fetcher=_httpx_fetcher,
            rate_limiter=RateLimiter(base_delay=3.0),  # DD-5 conservative
            robots_manager=RobotsTxtManager(fetcher=robots_fetcher),
            raw_html_sink=RawHtmlSink(base_dir=Path("data/raw/news")),
            clock=lambda: datetime.now(UTC),
        )
    """

    source_id: ClassVar[str] = "vietnambiz"

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

    base_url: str = _DEFAULT_VIETNAMBIZ_BASE_URL
    rate_limit_seconds: float = _DEFAULT_RATE_LIMIT_SECONDS

    # ------------------------------------------------------------------
    # CrawlerAdapter abstract method implementations
    # ------------------------------------------------------------------

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a VietnamBiz listing or section page.

        Args:
            listing_path: Site-relative path, e.g. ``/chung-khoan.htm``
                or ``/co-phieu``. Also accepts absolute URL.
            max_articles: Maximum article URLs to return (deduplicated).

        Returns:
            List of absolute article URLs, len <= max_articles, deduplicated.

        STEP 0.4 URL pattern (verified 2026-05-16):
            Article URLs match /<slug>-<15+digit-id>.htm
            (e.g. /dragon-capital-...-2026516161819153.htm).
            Navigation, category, print-variant, and external links excluded.

        Note: per DD-7 F2-aware design, listing-page HTML is NOT persisted
        (store_raw=False) -- avoids contamination of data/raw/news/vietnambiz/.
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
        """Fetch + parse a single VietnamBiz article URL.

        Per L-S28-1 vendor-drift doctrine: returns None on parse failure
        (degrade gracefully). Raises on network failure (caller logs + skips).

        SelectorChain[T] usage (DD-4 plan-027):
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
            _log.warning("vietnambiz_adapter: fetch failed for url=%r: %s", url, exc)
            return None

        soup = BeautifulSoup(html, "html.parser")

        # ---- Headline chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: h1.vnbcb-title (observed on sample article; VietnamBiz brand class)
        # Fallback 1: any h1 (generic)
        # Fallback 2: meta og:title (always present; may include site-name suffix)
        headline_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("h1", class_="vnbcb-title"),
                lambda: soup.find("h1"),
                lambda: soup.find("meta", attrs={"property": "og:title"}),
            ],
            label="vietnambiz_headline",
        )
        headline_tag, _ = headline_chain.apply()
        if headline_tag is None:
            _log.warning("vietnambiz_adapter: no headline found for url=%r", url)
            return None

        # Extract text: meta tags use 'content' attribute; element tags use text
        if isinstance(headline_tag, Tag) and headline_tag.name == "meta":
            raw_title = cast(str, headline_tag.get("content", ""))
            # Strip any " | VietnamBiz" suffix (site-name suffix pattern) if present
            title = raw_title.split(" | ")[0].strip()
        else:
            title = headline_tag.get_text(strip=True)
        if not title:
            _log.warning("vietnambiz_adapter: empty title for url=%r", url)
            return None

        # ---- Body container chain (DD-4 / STEP 0.4 verified 2026-05-16) ----
        # Primary: div.vnbcb-content (STEP 0.4: brand-specific class; text_len=5335
        #   for sample article; contains article paragraphs)
        # Fallback 1: div.post-body-content (outer wrapper containing vnbcb-content)
        # Fallback 2: article (semantic HTML fallback)
        body_chain: SelectorChain[Tag] = SelectorChain(
            strategies=[
                lambda: soup.find("div", class_="vnbcb-content"),
                lambda: soup.find("div", class_="post-body-content"),
                lambda: soup.find("article"),
            ],
            label="vietnambiz_body_container",
        )
        body_container, _ = body_chain.apply()
        if body_container is None:
            _log.warning("vietnambiz_adapter: no body container for url=%r", url)
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            _log.warning("vietnambiz_adapter: empty body for url=%r", url)
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

        Mirrors VietstockAdapter.to_news_article (vietstock_adapter.py:281-316):
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
            source="vietnambiz",
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

        Pattern mirrors VietstockAdapter._fetch_with_optional_chain shape at
        vietstock_adapter.py:322-369 (day-one shape; not retrofit).

        Args:
            url: Absolute URL to fetch.
            store_raw: When True (default; article-fetch path), persist HTML via
                raw_html_sink if provided. When False (discover/listing path),
                skip the sink -- listing-page HTML is not the unit of reprocessing
                and would pollute the article preservation dataset. DD-7 F2-aware
                design architected from day 1 (n=2 day-one ship: Vietstock 1st +
                VietnamBiz 2nd; L-S345-3 PROMOTE-NOW trigger condition).
        """
        rl = self.rate_limiter
        if rl is not None and hasattr(rl, "wait_if_needed"):
            rl.wait_if_needed(url)  # type: ignore[union-attr]

        rm = self.robots_manager
        if rm is not None and hasattr(rm, "can_fetch") and not rm.can_fetch(url):  # type: ignore[union-attr]
            _log.warning(
                "vietnambiz_adapter: robots.txt disallows url=%r -- skipping", url
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
                        "vietnambiz_adapter: raw_html_sink.write failed for url=%r: %s",
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
        """Return True if href looks like a VietnamBiz article URL.

        STEP 0.4 verified 2026-05-16: article URLs follow the pattern
        /<slug>-<15+digit-timestamp-id>.htm
        (e.g. /dragon-capital-...-2026516161819153.htm).
        Excludes: external URLs, mailto: links, print variants (-print.htm),
        navigation/category pages (no long numeric ID).
        """
        if not href or not href.startswith("/"):
            return False
        # Exclude protocol-relative (//host/path) or external links
        if href.startswith("//"):
            return False
        # Exclude printer-friendly variant
        if href.endswith("-print.htm"):
            return False
        return bool(_ARTICLE_URL_RE.match(href))

    @staticmethod
    def _parse_published_at(soup: object) -> datetime | None:
        """Best-effort publish-date parse using tag candidates + fmt-string chain.

        Date tag priority (STEP 0.4 verified 2026-05-16):
        1. meta[property=article:published_time] -- content=ISO-8601 WITHOUT tz
           Observed: '2026-05-16T16:33:00' (no +07:00 offset unlike Vietstock)
           -> treat as Vietnam Standard Time (UTC+7); no DST in Vietnam.
           NOTE: attaching UTC would be wrong -- '16:33:00' is local VN time
           (16:33 VN = 09:33 UTC); we preserve Rule 8 (published_at <= ingested_at)
           by correctly interpreting VN local time as UTC+7.
        2. span.vnbcba-time -- text format 'HH:MM | DD/MM/YYYY'
           Observed: '16:33 | 16/05/2026'
        3. span.relate-time -- text format 'DD-MM-YYYY' (date only; less precise)

        Format string fallback list (verified from STEP 0.4 sample HTML):
        - %Y-%m-%dT%H:%M:%S%z  (ISO-8601 with tz; future-proof)
        - %Y-%m-%dT%H:%M:%S    (ISO-8601 without tz -- attach UTC+7)
        - %H:%M | %d/%m/%Y     (span.vnbcba-time format)
        - %d/%m/%Y             (date-only variant)
        - %d-%m-%Y             (span.relate-time date-only)

        Returns None when no tag/format matches; caller falls back to clock().
        D-059 R1 compliance: always returns tz-aware datetime (UTC+7 attached when
        absent -- Vietnam Standard Time; no DST).
        """
        from bs4 import BeautifulSoup, Tag

        if not isinstance(soup, BeautifulSoup):
            return None

        # Priority 1: meta[property=article:published_time]
        meta_pub = soup.find("meta", {"property": "article:published_time"})
        if isinstance(meta_pub, Tag):
            text = cast(str, meta_pub.get("content", ""))
            if text:
                for fmt in (
                    "%Y-%m-%dT%H:%M:%S%z",
                    "%Y-%m-%dT%H:%M:%S",
                ):
                    try:
                        parsed = datetime.strptime(text, fmt)
                        return (
                            parsed
                            if parsed.tzinfo is not None
                            else parsed.replace(tzinfo=_TZ_VN)  # VN local time
                        )
                    except ValueError:
                        continue

        # Priority 2: span.vnbcba-time -- 'HH:MM | DD/MM/YYYY'
        span_time = soup.find("span", class_="vnbcba-time")
        if isinstance(span_time, Tag):
            text = span_time.get_text(strip=True)
            # Format: '16:33 | 16/05/2026' -> parse with %H:%M | %d/%m/%Y
            for fmt in (
                "%H:%M | %d/%m/%Y",
                "%d/%m/%Y %H:%M",
                "%d/%m/%Y",
            ):
                try:
                    parsed = datetime.strptime(text, fmt)
                    return parsed.replace(tzinfo=_TZ_VN)  # VN local time
                except ValueError:
                    continue

        # Priority 3: span.relate-time -- 'DD-MM-YYYY'
        span_relate = soup.find("span", class_="relate-time")
        if isinstance(span_relate, Tag):
            text = span_relate.get_text(strip=True)
            for fmt in ("%d-%m-%Y", "%d/%m/%Y"):
                try:
                    parsed = datetime.strptime(text, fmt)
                    return parsed.replace(tzinfo=_TZ_VN)  # VN local time
                except ValueError:
                    continue

        return None
