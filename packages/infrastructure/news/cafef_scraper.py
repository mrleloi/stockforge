"""CafeFScraper — fixture-friendly CafeF article scraper.

Phase 2 thin slice (S36 Track D). Two design constraints drive the shape:

1. **Fixture-driven CI**: tests inject recorded HTML via the `fetcher` callable
   so CI never hits cafef.vn. The default fetcher (`_httpx_fetcher`) uses
   httpx with a 1-req/2-sec rate limit per spec-T1-001 § B.9 (ToS-respecting).
2. **Robust selector failure**: CafeF mutates HTML quarterly; we extract via
   resilient BeautifulSoup queries and emit `ScrapedArticle` only when title +
   URL + body excerpt are non-empty. Failures degrade to skip-with-log, not
   raise (vendor drift L-S28-1 doctrine).

Source: agent-workspace/.claude/skills/crawler-reliability/SKILL.md;
specs/tier1-strategic/001-four-tier-signal-architecture.md § B.2 + § B.9;
agent-workspace/constitution/financial-data-protocol.md Rule 8.
"""

from __future__ import annotations

import hashlib
import time
from collections.abc import Callable, Iterable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import cast

from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle

__all__ = ["CafeFScraper", "ScrapedArticle"]


_RATE_LIMIT_SECONDS = 2.0
_DEFAULT_BASE_URL = "https://cafef.vn"
_DEFAULT_USER_AGENT = (
    "stockforge-research-bot/0.0.1 (+contact: nathanleewindy@gmail.com)"
)


@dataclass(frozen=True, slots=True)
class ScrapedArticle:
    """Raw scrape output before NewsArticle promotion. Holds the verbatim HTML
    body so the LLM extractor can quote source_text_excerpt grounded in the
    full body (Rule 6).
    """

    url: str
    title: str
    body_html: str
    body_text: str
    published_at: datetime


@dataclass
class CafeFScraper:
    """Scrape CafeF listing + article pages.

    `fetcher` signature: (url: str) -> str (HTML body). Default uses httpx
    with retries; tests inject a closure over a fixture dict.
    `clock` signature: () -> datetime; default returns `datetime.now(UTC)`.
    Tests pass a frozen clock for deterministic ingested_at.
    """

    fetcher: Callable[[str], str]
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )
    base_url: str = _DEFAULT_BASE_URL
    rate_limit_seconds: float = _RATE_LIMIT_SECONDS
    sleeper: Callable[[float], None] = time.sleep

    def __post_init__(self) -> None:
        self._last_fetch_at: float = 0.0

    def discover(self, listing_path: str, max_articles: int = 50) -> list[str]:
        """Return article URLs from a listing page.

        `listing_path` is e.g. "/thi-truong-chung-khoan.chn" — the section
        landing page. Discovery scrapes the listing for anchor hrefs ending
        ".chn" (CafeF convention) and returns absolute URLs deduped.
        """
        from bs4 import BeautifulSoup

        html = self._rate_limited_fetch(self._absolute(listing_path))
        soup = BeautifulSoup(html, "html.parser")
        urls: list[str] = []
        seen: set[str] = set()
        for anchor in soup.find_all("a", href=True):
            href = cast(str, anchor["href"])
            if not href.endswith(".chn"):
                continue
            absolute = self._absolute(href)
            if absolute in seen:
                continue
            seen.add(absolute)
            urls.append(absolute)
            if len(urls) >= max_articles:
                break
        return urls

    def fetch_article(self, url: str) -> ScrapedArticle | None:
        """Fetch + parse a single article. Returns None on parse failure
        (vendor drift L-S28-1 doctrine — degrade gracefully).
        """
        from bs4 import BeautifulSoup

        try:
            html = self._rate_limited_fetch(url)
        except Exception:
            return None
        soup = BeautifulSoup(html, "html.parser")
        title_tag = soup.find("h1")
        if title_tag is None or not title_tag.get_text(strip=True):
            return None
        title = title_tag.get_text(strip=True)
        body_container = (
            soup.find("div", class_="detail-content")
            or soup.find("div", class_="contentdetail")
            or soup.find("article")
        )
        if body_container is None:
            return None
        body_text = body_container.get_text(separator="\n", strip=True)
        if not body_text:
            return None
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
        """Promote a ScrapedArticle to a NewsArticle, attaching coarse-scan
        ticker mentions. The coarse scan looks for the symbol verbatim in
        title + body_text (case-sensitive — VN tickers are uppercase).
        """
        haystack = f"{scraped.title}\n{scraped.body_text}"
        mentioned = tuple(
            t for t in ticker_universe if t.symbol in haystack
        )
        article_id = self._article_id(scraped.url)
        return NewsArticle(
            article_id=article_id,
            source="cafef",
            source_url=scraped.url,
            title=scraped.title,
            body_excerpt=scraped.body_text[:excerpt_chars],
            published_at=scraped.published_at,
            ingested_at=self.clock(),
            mentioned_tickers=mentioned,
            language="vi",
        )

    def _rate_limited_fetch(self, url: str) -> str:
        elapsed = time.monotonic() - self._last_fetch_at
        if elapsed < self.rate_limit_seconds:
            self.sleeper(self.rate_limit_seconds - elapsed)
        try:
            return self.fetcher(url)
        finally:
            self._last_fetch_at = time.monotonic()

    def _absolute(self, href: str) -> str:
        if href.startswith("http://") or href.startswith("https://"):
            return href
        if href.startswith("/"):
            return f"{self.base_url}{href}"
        return f"{self.base_url}/{href}"

    @staticmethod
    def _parse_published_at(soup: object) -> datetime | None:
        """Best-effort `<span class="pdate">` or `<meta name="pubdate">` parse.
        Returns None when no recognised tag is found — the scraper falls back
        to the wall clock at ingest time.
        """
        from bs4 import BeautifulSoup, Tag

        if not isinstance(soup, BeautifulSoup):
            return None
        for tag_name, attr_key, attr_value in (
            ("span", "class", "pdate"),
            ("span", "class", "date"),
            ("meta", "name", "pubdate"),
        ):
            tag = soup.find(tag_name, {attr_key: attr_value})
            if not isinstance(tag, Tag):
                continue
            text = (
                cast(str, tag.get("content"))
                if tag.name == "meta"
                else tag.get_text(strip=True)
            )
            if not text:
                continue
            for fmt in ("%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%Y-%m-%d %H:%M:%S"):
                try:
                    return datetime.strptime(text, fmt).replace(tzinfo=UTC)
                except ValueError:
                    continue
        return None

    @staticmethod
    def _article_id(url: str) -> str:
        return hashlib.sha256(url.encode("utf-8")).hexdigest()[:16]
