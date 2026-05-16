"""Tests for VietstockAdapter (plan-026 S354 DC-D3 -- >=20 test cases).

Strategy A direct-subclass; second SelectorChain[T] consumer (plan-026 DD-4).
Synthetic HTML fixtures only (DD-10 -- no committed scraped HTML).

STEP 0.4 verified 2026-05-16 selector observations reflected in fixtures:
- Headline: h1.article-title (primary) -> h1 (fallback) -> meta[og:title]
- Body: div#vst_detail[itemprop=articleBody] (primary) -> div.article-content
- Date: meta[article:published_time] (ISO-8601+tz) -> meta[name=pubdate]
  -> span.datenew ('%d-%m-%Y %H:%M:%S%z')
- URL pattern: /YYYY/MM/<slug>-<cat_id>-<article_id>.htm

Covers:
 1. VietstockAdapter.source_id == "vietstock"
 2. Adapter can be registered + retrieved from CrawlerRegistry
 3. VietstockAdapter directly subclasses CrawlerAdapter (Strategy A; DD-3)
 4. discover returns expected URLs from synthetic listing HTML
 5. discover respects max_articles cap
 6. discover deduplicates repeat anchors
 7. discover does NOT persist listing-page HTML via RawHtmlSink (DD-7 F2-aware KEY TEST)
 8. fetch_and_parse happy path -- returns ScrapedArticle with correct fields
 9. fetch_and_parse returns None when title missing
10. fetch_and_parse returns None when body container missing
11. fetch_and_parse falls back to clock when no published date
12. fetch_and_parse returns None on HTTP error (L-S28-1)
13. fetch_and_parse uses SelectorChain fallback for headline (h1 no class)
14. fetch_and_parse returns None when all body selectors fail (SelectorChain WARNING)
15. to_news_article populates mentioned_tickers correctly
16. to_news_article caps body_excerpt at excerpt_chars
17. Adapter uses injected RateLimiter (wait_if_needed + report_response called)
18. Adapter skips URL when robots_manager disallows (returns None)
19. fetch_and_parse writes raw HTML via RawHtmlSink (DD-7 companion test)
20. Adapter works WITHOUT any optional injections
21. meta og:title used as headline when h1 missing (2nd SelectorChain fallback)
22. _parse_published_at handles span.datenew Vietstock-specific format
23. fetch_and_parse falls back to div.article-content when vst_detail absent
"""

from __future__ import annotations

import logging
from datetime import UTC, datetime
from unittest.mock import MagicMock

import pytest

from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.application.news.ports.crawler_registry import CrawlerRegistry
from packages.contracts import Ticker
from packages.infrastructure.news.cafef_scraper import ScrapedArticle
from packages.infrastructure.news.crawler_adapters.vietstock_adapter import (
    VietstockAdapter,
)

# ---------------------------------------------------------------------------
# Synthetic HTML fixtures (DD-10 -- license-clean; edge-case-controllable)
# STEP 0.4 verified 2026-05-16: actual Vietstock HTML structure
# ---------------------------------------------------------------------------

# Full happy-path article with all expected elements:
# h1.article-title + div#vst_detail[itemprop=articleBody]
# + meta[article:published_time] ISO-8601+tz
_SYNTHETIC_VIETSTOCK_ARTICLE_HTML = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="VHM du kien dat loi nhuan quy 1 on dinh | Vietstock" />
  <meta property="article:published_time" content="2026-05-15T10:30:00+07:00" />
  <meta name="pubdate" content="2026-05-15T10:30:00+07:00" />
</head>
<body>
  <div class="article-content" id="post-12345">
    <h1 class="article-title">VHM du kien dat loi nhuan quy 1 on dinh</h1>
    <div class="dateNewBlock"><span class="datenew">15-05-2026 10:30:00+07:00</span></div>
    <div id="vst_detail" itemprop="articleBody">
      <p class="pTitle">VHM du kien dat loi nhuan quy 1 on dinh</p>
      <p class="pHead">Cong ty co phan Vinhomes (VHM) cong bo ket qua kinh doanh quy 1.</p>
      <p>FPT cung duoc ky vong co tang truong tich cuc.</p>
    </div>
  </div>
</body>
</html>"""

# No h1.article-title class -- tests SelectorChain fallback to plain h1
_ARTICLE_HTML_NO_CLASS = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="article:published_time" content="2026-05-16T08:00:00+07:00" />
</head>
<body>
  <h1>FPT tang truong manh</h1>
  <div id="vst_detail" itemprop="articleBody">
    <p>FPT bao cao doanh thu tang 30 phan tram.</p>
  </div>
</body>
</html>"""

# meta og:title as headline (both h1 variants missing)
_ARTICLE_HTML_META_TITLE = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="SSI thi truong chung khoan | Vietstock" />
  <meta property="article:published_time" content="2026-05-16T11:00:00+07:00" />
</head>
<body>
  <div id="vst_detail" itemprop="articleBody">
    <p>SSI Securities bao cao loi nhuan tang.</p>
  </div>
</body>
</html>"""

# No body container (no vst_detail, no article-content)
_ARTICLE_HTML_NO_BODY = """\
<!DOCTYPE html>
<html>
<body>
  <h1 class="article-title">Title present</h1>
  <div class="sidebar">sidebar content</div>
</body>
</html>"""

# No title at all (no h1, no og:title)
_ARTICLE_HTML_NO_TITLE = """\
<!DOCTYPE html>
<html>
<body>
  <div id="vst_detail" itemprop="articleBody">
    <p>Body without title.</p>
  </div>
</body>
</html>"""

# No publish date -- falls back to clock
_ARTICLE_HTML_NO_DATE = """\
<!DOCTYPE html>
<html>
<body>
  <h1 class="article-title">VNM no date article</h1>
  <div id="vst_detail" itemprop="articleBody">
    <p>VNM Vietnam Dairy Products bao cao.</p>
  </div>
</body>
</html>"""

# Article where div#vst_detail is missing; falls back to div.article-content
_ARTICLE_HTML_FALLBACK_BODY = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="article:published_time" content="2026-05-16T09:00:00+07:00" />
</head>
<body>
  <h1 class="article-title">HPG du bao tang truong</h1>
  <div class="article-content">
    <p>HPG Hoa Phat Group du bao tang san luong thep.</p>
  </div>
</body>
</html>"""

# Article with span.datenew date only (no meta date tags)
_ARTICLE_HTML_DATENEW = """\
<!DOCTYPE html>
<html>
<body>
  <h1 class="article-title">VCB ket qua kinh doanh</h1>
  <div class="dateNewBlock"><span class="datenew">14-05-2026 09:15:00+07:00</span></div>
  <div id="vst_detail" itemprop="articleBody">
    <p>VCB Vietcombank cong bo ket qua kinh doanh tot.</p>
  </div>
</body>
</html>"""

# Listing page with article URLs + non-article links
# STEP 0.4 verified URL pattern: /YYYY/MM/<slug>-<cat>-<id>.htm
_SYNTHETIC_VIETSTOCK_LISTING_HTML = """\
<!DOCTYPE html>
<html><body>
  <a href="/2026/05/vhm-loi-nhuan-quy-1-830-12345.htm">VHM Q1</a>
  <a href="/2026/05/fpt-tang-truong-830-12346.htm">FPT growth</a>
  <a href="/2026/05/hpg-quan-su-830-12347.htm">HPG news</a>
  <a href="/2026/05/vhm-loi-nhuan-quy-1-830-12345.htm">VHM Q1 (duplicate)</a>
  <a href="//finance.vietstock.vn/bo-loc-co-phieu.htm">Finance tools -- excluded</a>
  <a href="/chung-khoan.htm">Category link -- excluded</a>
  <a href="/Gioi-thieu.htm">Static page -- excluded</a>
  <a href="/bat-dong-san/">Directory -- excluded</a>
</body></html>"""

_FROZEN_CLOCK_DT = datetime(2026, 5, 16, 7, 0, tzinfo=UTC)


def _frozen_clock() -> datetime:
    return _FROZEN_CLOCK_DT


def _make_adapter(
    fetcher: object = None,
    rate_limiter: object = None,
    robots_manager: object = None,
    raw_html_sink: object = None,
    clock: object = None,
) -> VietstockAdapter:
    if fetcher is None:
        fetcher = lambda _url: _SYNTHETIC_VIETSTOCK_ARTICLE_HTML  # noqa: E731
    if clock is None:
        clock = _frozen_clock
    return VietstockAdapter(
        fetcher=fetcher,  # type: ignore[arg-type]
        rate_limiter=rate_limiter,
        robots_manager=robots_manager,
        raw_html_sink=raw_html_sink,
        clock=clock,  # type: ignore[arg-type]
    )


# ---------------------------------------------------------------------------
# Tests 1-3: identity + registry
# ---------------------------------------------------------------------------


def test_vietstock_adapter_declares_source_id() -> None:
    """Test 1 -- VietstockAdapter.source_id == 'vietstock' (DC-IMPL-1)."""
    assert VietstockAdapter.source_id == "vietstock"


def test_vietstock_adapter_can_be_registered() -> None:
    """Test 2 -- register + retrieve from CrawlerRegistry."""
    registry = CrawlerRegistry()
    adapter = _make_adapter()
    registry.register(adapter)
    retrieved = registry.get("vietstock")
    assert retrieved is adapter


def test_vietstock_adapter_is_strategy_a_direct_subclass() -> None:
    """Test 3 -- VietstockAdapter directly subclasses CrawlerAdapter (DD-3)."""
    assert issubclass(VietstockAdapter, CrawlerAdapter)
    # NOT wrapping any legacy class -- no _scraper attribute
    adapter = _make_adapter()
    assert not hasattr(adapter, "_scraper")


# ---------------------------------------------------------------------------
# Tests 4-7: discover()
# ---------------------------------------------------------------------------


def test_discover_returns_expected_urls_from_fixture() -> None:
    """Test 4 -- discover returns 3 article URLs from synthetic listing HTML."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_VIETSTOCK_LISTING_HTML,
    )
    urls = adapter.discover("/chung-khoan.htm", max_articles=10)
    assert urls == [
        "https://vietstock.vn/2026/05/vhm-loi-nhuan-quy-1-830-12345.htm",
        "https://vietstock.vn/2026/05/fpt-tang-truong-830-12346.htm",
        "https://vietstock.vn/2026/05/hpg-quan-su-830-12347.htm",
    ]


def test_discover_respects_max_articles_cap() -> None:
    """Test 5 -- discover caps at max_articles."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_VIETSTOCK_LISTING_HTML,
    )
    urls = adapter.discover("/chung-khoan.htm", max_articles=2)
    assert len(urls) == 2


def test_discover_deduplicates_repeat_anchors() -> None:
    """Test 6 -- discover deduplicates identical hrefs."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_VIETSTOCK_LISTING_HTML,
    )
    urls = adapter.discover("/chung-khoan.htm", max_articles=100)
    assert urls.count(
        "https://vietstock.vn/2026/05/vhm-loi-nhuan-quy-1-830-12345.htm"
    ) == 1


def test_discover_does_not_persist_raw_html_via_sink() -> None:
    """Test 7 -- F2 regression guard (DD-7 F2-aware KEY ARCHITECTURAL TEST).

    discover() MUST NOT persist listing-page HTML via RawHtmlSink.
    Confirms store_raw=False propagates to the sink-guard in
    _fetch_with_optional_chain. Mirror of NDH test_21 (F2 regression guard).
    """
    mock_sink = MagicMock()
    mock_sink.write = MagicMock()
    adapter = _make_adapter(
        fetcher=lambda _: _SYNTHETIC_VIETSTOCK_LISTING_HTML,
        raw_html_sink=mock_sink,
    )
    urls = adapter.discover("/chung-khoan.htm")
    # discover succeeded
    assert len(urls) > 0
    # sink.write was NOT called for listing-page fetch (F2 fix architected day-1)
    mock_sink.write.assert_not_called()


# ---------------------------------------------------------------------------
# Tests 8-14: fetch_and_parse()
# ---------------------------------------------------------------------------


def test_fetch_and_parse_happy_path() -> None:
    """Test 8 -- full happy path returns ScrapedArticle with correct fields."""
    adapter = _make_adapter()
    url = "https://vietstock.vn/2026/05/vhm-loi-nhuan-quy-1-830-12345.htm"
    result = adapter.fetch_and_parse(url)
    assert result is not None
    assert isinstance(result, ScrapedArticle)
    assert result.url == url
    assert "VHM" in result.title
    assert "Vinhomes" in result.body_text
    # Date from meta[article:published_time] = 2026-05-15T10:30:00+07:00
    assert result.published_at.year == 2026
    assert result.published_at.month == 5
    assert result.published_at.tzinfo is not None


def test_fetch_and_parse_returns_none_on_missing_title() -> None:
    """Test 9 -- returns None when no headline found."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_TITLE,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/no-title-830-12348.htm"
    )
    assert result is None


def test_fetch_and_parse_returns_none_on_missing_body_container() -> None:
    """Test 10 -- returns None when no body container found."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_BODY,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/no-body-830-12349.htm"
    )
    assert result is None


def test_fetch_and_parse_falls_back_to_clock_when_no_published_date() -> None:
    """Test 11 -- published_at falls back to frozen clock when no date tag."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_DATE,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/vnm-no-date-830-12350.htm"
    )
    assert result is not None
    assert result.published_at == _FROZEN_CLOCK_DT


def test_fetch_and_parse_returns_none_on_http_error() -> None:
    """Test 12 -- returns None on network/HTTP error (L-S28-1 degrade gracefully)."""
    import httpx

    def failing_fetcher(_url: str) -> str:
        raise httpx.HTTPError("connection refused")

    adapter = _make_adapter(fetcher=failing_fetcher)
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/unreachable-830-12351.htm"
    )
    assert result is None


def test_fetch_and_parse_uses_selector_chain_fallback_headline() -> None:
    """Test 13 -- SelectorChain falls back to plain h1 when article-title class absent."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_CLASS,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/fpt-tang-truong-830-12352.htm"
    )
    assert result is not None
    assert "FPT" in result.title


def test_fetch_and_parse_returns_none_when_all_body_selectors_fail(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """Test 14 -- SelectorChain WARNING logged + returns None on body failure."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_BODY,
    )
    with caplog.at_level(logging.WARNING):
        result = adapter.fetch_and_parse(
            "https://vietstock.vn/2026/05/no-body-830-12353.htm"
        )
    assert result is None
    # SelectorChain logs warning when all strategies fail
    assert any("vietstock_body_container" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# Tests 15-16: to_news_article()
# ---------------------------------------------------------------------------


def test_to_news_article_populates_mentioned_tickers() -> None:
    """Test 15 -- mentioned_tickers populated by coarse symbol scan."""
    adapter = _make_adapter()
    scraped = ScrapedArticle(
        url="https://vietstock.vn/2026/05/vhm-fpt-830-12354.htm",
        title="VHM du kien dat loi nhuan on dinh",
        body_html="<p>FPT cung duoc ky vong tang truong.</p>",
        body_text="VHM du kien dat loi nhuan.\nFPT cung duoc ky vong tang truong.",
        published_at=_FROZEN_CLOCK_DT,
    )
    universe = [Ticker("VHM"), Ticker("FPT"), Ticker("HPG")]
    article = adapter.to_news_article(scraped, universe)
    assert Ticker("VHM") in article.mentioned_tickers
    assert Ticker("FPT") in article.mentioned_tickers
    assert Ticker("HPG") not in article.mentioned_tickers


def test_to_news_article_excerpt_caps_at_excerpt_chars() -> None:
    """Test 16 -- body_excerpt is capped at excerpt_chars (default 4000)."""
    adapter = _make_adapter()
    long_body = "x" * 10000
    scraped = ScrapedArticle(
        url="https://vietstock.vn/2026/05/long-article-830-12355.htm",
        title="Long article",
        body_html="<p>" + long_body + "</p>",
        body_text=long_body,
        published_at=_FROZEN_CLOCK_DT,
    )
    article = adapter.to_news_article(scraped, [], excerpt_chars=4000)
    assert len(article.body_excerpt) == 4000


# ---------------------------------------------------------------------------
# Tests 17-20: optional injection behavior
# ---------------------------------------------------------------------------


def test_adapter_uses_injected_rate_limiter() -> None:
    """Test 17 -- RateLimiter wait_if_needed + report_response called once each."""
    mock_rl = MagicMock()
    mock_rl.wait_if_needed = MagicMock()
    mock_rl.report_response = MagicMock()
    adapter = _make_adapter(rate_limiter=mock_rl)
    url = "https://vietstock.vn/2026/05/vhm-loi-nhuan-830-12345.htm"
    adapter.fetch_and_parse(url)
    mock_rl.wait_if_needed.assert_called_once_with(url)
    mock_rl.report_response.assert_called_once_with(url, 200)


def test_adapter_skips_url_when_robots_disallows() -> None:
    """Test 18 -- fetch_and_parse returns None when robots disallows."""
    mock_rm = MagicMock()
    mock_rm.can_fetch = MagicMock(return_value=False)
    adapter = _make_adapter(robots_manager=mock_rm)
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/blocked-830-12356.htm"
    )
    assert result is None


def test_fetch_and_parse_writes_raw_html_via_sink() -> None:
    """Test 19 -- RawHtmlSink.write called with correct args (DD-7 companion test).

    Confirms that fetch_and_parse (article path) DOES write raw HTML
    via the sink, with correct source_id, url, and tz-aware fetched_at.
    Companion to test 7 which asserts discover() does NOT call sink.write.
    """
    mock_sink = MagicMock()
    mock_sink.write = MagicMock()
    url = "https://vietstock.vn/2026/05/vhm-loi-nhuan-830-12345.htm"
    adapter = _make_adapter(raw_html_sink=mock_sink)
    adapter.fetch_and_parse(url)
    mock_sink.write.assert_called_once()
    call_kwargs = mock_sink.write.call_args
    assert call_kwargs.kwargs["source_id"] == "vietstock"
    assert call_kwargs.kwargs["url"] == url
    assert call_kwargs.kwargs["fetched_at"].tzinfo is not None


def test_adapter_default_no_injections_still_works() -> None:
    """Test 20 -- VietstockAdapter(fetcher=...) with no optional injections works."""
    adapter = VietstockAdapter(fetcher=lambda _: _SYNTHETIC_VIETSTOCK_ARTICLE_HTML)
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/vhm-loi-nhuan-830-12345.htm"
    )
    assert result is not None
    assert isinstance(result, ScrapedArticle)


# ---------------------------------------------------------------------------
# Tests 21-22: additional coverage
# ---------------------------------------------------------------------------


def test_fetch_and_parse_handles_meta_og_title_as_headline() -> None:
    """Test 21 -- headline extracted from meta og:title (2nd SelectorChain fallback).

    og:title stripped of ' | Vietstock' suffix if present.
    """
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_META_TITLE,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/ssi-chung-khoan-830-12357.htm"
    )
    assert result is not None
    assert "SSI" in result.title
    # Ensure the ' | Vietstock' suffix was stripped
    assert "Vietstock" not in result.title


def test_parse_published_at_handles_datenew_format() -> None:
    """Test 22 -- span.datenew Vietstock-specific date format parsed correctly."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_DATENEW,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/vcb-ket-qua-830-12358.htm"
    )
    assert result is not None
    # span.datenew: '14-05-2026 09:15:00+07:00'
    # Should parse successfully (not fall back to frozen clock)
    assert result.published_at != _FROZEN_CLOCK_DT
    assert result.published_at.day == 14
    assert result.published_at.month == 5
    assert result.published_at.tzinfo is not None


def test_fetch_and_parse_uses_fallback_body_container() -> None:
    """Test 23 -- body falls back to div.article-content when vst_detail absent."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_FALLBACK_BODY,
    )
    result = adapter.fetch_and_parse(
        "https://vietstock.vn/2026/05/hpg-tang-truong-830-12359.htm"
    )
    assert result is not None
    assert "HPG" in result.body_text
