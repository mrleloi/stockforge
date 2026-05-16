"""Tests for CafeFAdapter (plan 020 DC-D3-5).

Covers (≥10 per spec):
1. Adapter declares source_id = "cafef".
2. Adapter can be registered to a fresh CrawlerRegistry.
3. discover returns expected URLs from fixture HTML.
4. fetch_and_parse returns ScrapedArticle from fixture URL.
5. fetch_and_parse returns None on parse failure.
6. to_news_article populates mentioned_tickers correctly.
7. Adapter uses injected RateLimiter (verify via mock — wait_if_needed called).
8. Adapter uses injected RobotsTxtManager (skip URL if disallowed).
9. Adapter saves to injected RawHtmlSink when provided.
10. Adapter works WITHOUT optional injections (default behavior).
"""

from __future__ import annotations

from datetime import UTC, datetime
from pathlib import Path

from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.application.news.ports.crawler_registry import CrawlerRegistry
from packages.contracts import Ticker
from packages.infrastructure.news.cafef_scraper import ScrapedArticle
from packages.infrastructure.news.crawler_adapters.cafef_adapter import CafeFAdapter

# --- Test fixtures -----------------------------------------------------------

_LISTING_HTML = """
<html><body>
<a href="/vhm-q1-2026.chn">VHM Q1 2026</a>
<a href="/fpt-doanh-thu.chn">FPT doanh thu</a>
<a href="/about.html">About</a>
</body></html>
"""

_ARTICLE_HTML = """
<html><body>
<h1>VHM công bố lãi quý 1 2026</h1>
<span class="pdate">01-05-2026 09:00:00</span>
<div class="detail-content">
<p>Vinhomes (mã VHM) báo lãi 5.000 tỷ đồng trong quý 1 năm 2026.</p>
</div>
</body></html>
"""

_NO_BODY_HTML = """
<html><body>
<h1>Title only</h1>
</body></html>
"""

_FROZEN_CLOCK = datetime(2026, 5, 16, 8, 0, tzinfo=UTC)


def _frozen_clock() -> datetime:
    return _FROZEN_CLOCK


def _make_adapter(
    pages: dict[str, str],
    *,
    rate_limiter: object = None,
    robots_manager: object = None,
    raw_html_sink: object = None,
) -> CafeFAdapter:
    def fetcher(url: str) -> str:
        for key, html in pages.items():
            if url.endswith(key) or url == key:
                return html
        raise RuntimeError(f"unexpected url: {url!r}")

    return CafeFAdapter(
        fetcher=fetcher,
        clock=_frozen_clock,
        rate_limiter=rate_limiter,
        robots_manager=robots_manager,
        raw_html_sink=raw_html_sink,
    )


# --- Test 1: source_id = "cafef" -------------------------------------------


def test_cafef_adapter_declares_cafef_source_id() -> None:
    """CafeFAdapter.source_id is 'cafef'."""
    assert CafeFAdapter.source_id == "cafef"


# --- Test 2: adapter registers to CrawlerRegistry --------------------------


def test_cafef_adapter_registers_to_fresh_registry() -> None:
    """CafeFAdapter can be registered to a fresh CrawlerRegistry."""
    adapter = _make_adapter({})
    registry = CrawlerRegistry()
    registry.register(adapter)
    result = registry.get("cafef")
    assert result is adapter


# --- Test 3: discover returns expected URLs ---------------------------------


def test_cafef_adapter_discover_returns_chn_urls() -> None:
    """discover returns .chn article URLs from fixture HTML."""
    adapter = _make_adapter({"/thi-truong.chn": _LISTING_HTML})
    urls = adapter.discover("/thi-truong.chn", max_articles=10)
    assert "https://cafef.vn/vhm-q1-2026.chn" in urls
    assert "https://cafef.vn/fpt-doanh-thu.chn" in urls
    # Non-.chn links excluded
    assert all(u.endswith(".chn") for u in urls)


# --- Test 4: fetch_and_parse returns ScrapedArticle ------------------------


def test_cafef_adapter_fetch_and_parse_returns_scraped_article() -> None:
    """fetch_and_parse returns a ScrapedArticle with title + body populated."""
    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML}
    )
    result = adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert result is not None
    assert isinstance(result, ScrapedArticle)
    assert "VHM" in result.title
    assert "Vinhomes" in result.body_text
    assert result.published_at == datetime(2026, 5, 1, 9, 0, tzinfo=UTC)


# --- Test 5: fetch_and_parse returns None on parse failure -----------------


def test_cafef_adapter_fetch_and_parse_returns_none_on_parse_failure() -> None:
    """fetch_and_parse returns None when article body cannot be extracted."""
    adapter = _make_adapter(
        {"https://cafef.vn/x.chn": _NO_BODY_HTML}
    )
    result = adapter.fetch_and_parse("https://cafef.vn/x.chn")
    assert result is None


# --- Test 6: to_news_article populates mentioned_tickers -------------------


def test_cafef_adapter_to_news_article_populates_tickers() -> None:
    """to_news_article scans body text and title for ticker symbols."""
    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML}
    )
    scraped = adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert scraped is not None
    article = adapter.to_news_article(
        scraped, ticker_universe=[Ticker("VHM"), Ticker("FPT"), Ticker("MWG")]
    )
    assert Ticker("VHM") in article.mentioned_tickers
    assert Ticker("MWG") not in article.mentioned_tickers
    assert article.source == "cafef"


# --- Test 7: adapter uses injected RateLimiter -----------------------------


def test_cafef_adapter_uses_injected_rate_limiter() -> None:
    """When rate_limiter is provided, wait_if_needed is called before each fetch."""
    waited_domains: list[str] = []

    class _StubRateLimiter:
        def wait_if_needed(self, domain: str) -> None:
            waited_domains.append(domain)

        def report_response(self, _domain: str, _status_code: int) -> bool:
            return True

    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML},
        rate_limiter=_StubRateLimiter(),
    )
    adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert len(waited_domains) == 1  # wait_if_needed called once per fetch


# --- Test 8: adapter respects injected RobotsTxtManager -------------------


def test_cafef_adapter_skips_url_if_disallowed_by_robots() -> None:
    """When RobotsTxtManager.can_fetch returns False, adapter returns None."""

    class _DisallowAll:
        def can_fetch(self, _url: str) -> bool:
            return False

    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML},
        robots_manager=_DisallowAll(),
    )
    # fetch_and_parse catches the RuntimeError from robots disallow → returns None
    result = adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert result is None


# --- Test 9: adapter saves to injected RawHtmlSink -------------------------


def test_cafef_adapter_saves_to_raw_html_sink(tmp_path: Path) -> None:
    """When raw_html_sink is provided, write is called for each fetched URL."""
    written: list[tuple[str, str]] = []

    class _StubSink:
        def write(
            self,
            source_id: str,
            url: str,
            html: str,  # noqa: ARG002
            fetched_at: datetime,  # noqa: ARG002
        ) -> Path:
            written.append((source_id, url))
            return tmp_path / "stub.html"

    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML},
        raw_html_sink=_StubSink(),
    )
    adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert len(written) == 1
    source_id, url = written[0]
    assert source_id == "cafef"
    assert url == "https://cafef.vn/vhm-q1-2026.chn"


# --- Test 10: adapter works without optional injections --------------------


def test_cafef_adapter_works_without_optional_injections() -> None:
    """CafeFAdapter with no optional injections behaves like base CafeFScraper."""
    adapter = _make_adapter(
        {"https://cafef.vn/vhm-q1-2026.chn": _ARTICLE_HTML},
        rate_limiter=None,
        robots_manager=None,
        raw_html_sink=None,
    )
    result = adapter.fetch_and_parse("https://cafef.vn/vhm-q1-2026.chn")
    assert result is not None
    assert "VHM" in result.title


# --- Additional: adapter is a valid CrawlerAdapter subclass ----------------


def test_cafef_adapter_is_crawler_adapter_subclass() -> None:
    """CafeFAdapter is a subclass of CrawlerAdapter (ABC compliance)."""
    assert issubclass(CafeFAdapter, CrawlerAdapter)


# --- Additional: discover respects max_articles cap ------------------------


def test_cafef_adapter_discover_respects_max_articles() -> None:
    """discover never returns more than max_articles URLs."""
    adapter = _make_adapter({"/thi-truong.chn": _LISTING_HTML})
    urls = adapter.discover("/thi-truong.chn", max_articles=1)
    assert len(urls) == 1
