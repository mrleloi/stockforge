"""Tests for NDHAdapter (plan-022 S344 DC-D3 -- >=12 test cases).

Strategy A direct-subclass; first SelectorChain[T] consumer (plan-022 DD-4).
Synthetic HTML fixtures only (DD-10 -- no committed scraped HTML).

STEP 0.4 verified 2026-05-16 selector observations are reflected in fixtures:
- Headline: h1.article__title (primary) -> h1 (fallback) -> meta[og:title]
- Body: div.article-content (primary) -> article (fallback)
- Date: meta[article:published_time] (ISO-8601+tz) -> meta[pubdate] -> time[datetime]
- URL pattern: /-{digits}.htm$ (e.g. /co-phieu-vhm-28729.htm)

Covers:
 1. NDHAdapter.source_id == "ndh"
 2. Adapter can be registered + retrieved from CrawlerRegistry
 3. discover returns expected URLs from synthetic listing HTML
 4. discover respects max_articles cap
 5. discover deduplicates repeat anchors
 6. fetch_and_parse happy path -- returns ScrapedArticle with correct fields
 7. fetch_and_parse uses SelectorChain fallback for headline (no article__title)
 8. fetch_and_parse uses SelectorChain fallback for body (no article-content)
 9. fetch_and_parse returns None when all body selectors fail
10. fetch_and_parse returns None when title missing
11. fetch_and_parse falls back to clock when no publish date
12. fetch_and_parse returns None on HTTP error (L-S28-1)
13. fetch_and_parse handles meta og:title as headline (2nd fallback)
14. to_news_article populates mentioned_tickers correctly
15. to_news_article caps body_excerpt at excerpt_chars
16. Adapter uses injected RateLimiter (wait_if_needed + report_response called)
17. Adapter skips URL when robots_manager disallows (raises RuntimeError -> None)
18. Adapter writes raw HTML to RawHtmlSink when provided
19. Adapter works WITHOUT any optional injections
20. CrawlerAdapter.__init_subclass__ raises TypeError for class without source_id
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
from packages.infrastructure.news.crawler_adapters.ndh_adapter import NDHAdapter

# ---------------------------------------------------------------------------
# Synthetic HTML fixtures (DD-10 -- license-clean; edge-case-controllable)
# ---------------------------------------------------------------------------

# STEP 0.4 verified structure: h1.article__title + div.article-content
# + meta[article:published_time] ISO-8601 with +07:00
_SYNTHETIC_NDH_ARTICLE_HTML = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="VHM du kien dat loi nhuan quy 1 on dinh" />
  <meta property="article:published_time" content="2026-05-15T10:30:00+07:00" />
  <meta name="pubdate" content="2026-05-15T10:30:00+07:00" />
</head>
<body>
  <h1 class="article__title cms-title">VHM du kien dat loi nhuan quy 1 on dinh</h1>
  <div class="article-content">
    <p>Cong ty co phan Vinhomes (VHM) cong bo ket qua kinh doanh quy 1.</p>
    <p>FPT cung duoc ky vong co tang truong tich cuc.</p>
  </div>
</body>
</html>"""

# No article__title class -- tests SelectorChain fallback to plain h1
_ARTICLE_HTML_NO_CLASS = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="article:published_time" content="2026-05-16T08:00:00+07:00" />
</head>
<body>
  <h1>FPT tang truong manh</h1>
  <div class="article-content">
    <p>FPT bao cao doanh thu tang 30 phan tram.</p>
  </div>
</body>
</html>"""

# No div.article-content -- tests SelectorChain fallback to article tag
_ARTICLE_HTML_ARTICLE_TAG = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="article:published_time" content="2026-05-16T09:00:00+07:00" />
</head>
<body>
  <h1 class="article__title">HPG du bao tang truong</h1>
  <article>
    <p>HPG Hoa Phat Group du bao tang san luong thep.</p>
  </article>
</body>
</html>"""

# meta og:title as headline (both h1 variants missing)
_ARTICLE_HTML_META_TITLE = """\
<!DOCTYPE html>
<html>
<head>
  <meta property="og:title" content="SSI thi truong chung khoan" />
  <meta property="article:published_time" content="2026-05-16T11:00:00+07:00" />
</head>
<body>
  <div class="article-content">
    <p>SSI Securities bao cao loi nhuan tang.</p>
  </div>
</body>
</html>"""

# No body container (no div.article-content, no article tag)
_ARTICLE_HTML_NO_BODY = """\
<!DOCTYPE html>
<html>
<body>
  <h1 class="article__title">Title present</h1>
  <div class="sidebar">sidebar content</div>
</body>
</html>"""

# No title at all (no h1, no og:title)
_ARTICLE_HTML_NO_TITLE = """\
<!DOCTYPE html>
<html>
<body>
  <div class="article-content">
    <p>Body without title.</p>
  </div>
</body>
</html>"""

# No publish date -- falls back to clock
_ARTICLE_HTML_NO_DATE = """\
<!DOCTYPE html>
<html>
<body>
  <h1 class="article__title">VNM no date article</h1>
  <div class="article-content">
    <p>VNM Vietnam Dairy Products bao cao.</p>
  </div>
</body>
</html>"""

# Listing page with article URLs + non-article links
_SYNTHETIC_NDH_LISTING_HTML = """\
<!DOCTYPE html>
<html><body>
  <a href="/vhm-loi-nhuan-quy-1-28730.htm">VHM Q1</a>
  <a href="/fpt-tang-truong-28731.htm">FPT growth</a>
  <a href="/hpg-quan-su-28732.htm">HPG news</a>
  <a href="/vhm-loi-nhuan-quy-1-28730.htm">VHM Q1 (duplicate)</a>
  <a href="/hashtag/chung-khoan-9">Category link -- excluded</a>
  <a href="/cms/public-hashtag/view?id=1">CMS link -- excluded</a>
  <a href="/about-us">No numeric ID -- excluded</a>
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
) -> NDHAdapter:
    if fetcher is None:
        fetcher = lambda _url: _SYNTHETIC_NDH_ARTICLE_HTML  # noqa: E731
    if clock is None:
        clock = _frozen_clock
    return NDHAdapter(
        fetcher=fetcher,  # type: ignore[arg-type]
        rate_limiter=rate_limiter,
        robots_manager=robots_manager,
        raw_html_sink=raw_html_sink,
        clock=clock,  # type: ignore[arg-type]
    )


# ---------------------------------------------------------------------------
# Tests 1-3: identity + registry
# ---------------------------------------------------------------------------


def test_ndh_adapter_declares_source_id() -> None:
    """Test 1 -- NDHAdapter.source_id == 'ndh' (DC-IMPL-1)."""
    assert NDHAdapter.source_id == "ndh"


def test_ndh_adapter_can_be_registered() -> None:
    """Test 2 -- register + retrieve from CrawlerRegistry (DC-IMPL-1)."""
    registry = CrawlerRegistry()
    adapter = _make_adapter()
    registry.register(adapter)
    retrieved = registry.get("ndh")
    assert retrieved is adapter


def test_ndh_adapter_is_strategy_a_direct_subclass() -> None:
    """Test 3 -- NDHAdapter directly subclasses CrawlerAdapter (DD-3)."""
    assert issubclass(NDHAdapter, CrawlerAdapter)
    # NOT wrapping any legacy class -- no _scraper attribute
    adapter = _make_adapter()
    assert not hasattr(adapter, "_scraper")


# ---------------------------------------------------------------------------
# Tests 4-6: discover()
# ---------------------------------------------------------------------------


def test_discover_returns_expected_urls_from_fixture() -> None:
    """Test 4 -- discover returns 3 article URLs from synthetic listing HTML."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_NDH_LISTING_HTML,
    )
    urls = adapter.discover("/chung-khoan", max_articles=10)
    assert urls == [
        "https://nhipsongkinhdoanh.vn/vhm-loi-nhuan-quy-1-28730.htm",
        "https://nhipsongkinhdoanh.vn/fpt-tang-truong-28731.htm",
        "https://nhipsongkinhdoanh.vn/hpg-quan-su-28732.htm",
    ]


def test_discover_respects_max_articles_cap() -> None:
    """Test 5 -- discover caps at max_articles (DC-IMPL-5)."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_NDH_LISTING_HTML,
    )
    urls = adapter.discover("/chung-khoan", max_articles=2)
    assert len(urls) == 2


def test_discover_deduplicates_repeat_anchors() -> None:
    """Test 6 -- discover deduplicates identical hrefs."""
    adapter = _make_adapter(
        fetcher=lambda _url: _SYNTHETIC_NDH_LISTING_HTML,
    )
    # Listing has /vhm-loi-nhuan-quy-1-28730.htm twice; result should have it once
    urls = adapter.discover("/chung-khoan", max_articles=100)
    assert urls.count("https://nhipsongkinhdoanh.vn/vhm-loi-nhuan-quy-1-28730.htm") == 1


# ---------------------------------------------------------------------------
# Tests 7-13: fetch_and_parse()
# ---------------------------------------------------------------------------


def test_fetch_and_parse_happy_path() -> None:
    """Test 7 -- full happy path returns ScrapedArticle with correct fields."""
    adapter = _make_adapter()
    url = "https://nhipsongkinhdoanh.vn/vhm-loi-nhuan-28729.htm"
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


def test_fetch_and_parse_uses_selector_chain_fallback_headline() -> None:
    """Test 8 -- SelectorChain falls back to plain h1 when article__title absent."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_CLASS,
    )
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/fpt-28731.htm")
    assert result is not None
    assert "FPT" in result.title


def test_fetch_and_parse_uses_selector_chain_fallback_body() -> None:
    """Test 9 -- SelectorChain falls back to article tag when article-content absent."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_ARTICLE_TAG,
    )
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/hpg-28732.htm")
    assert result is not None
    assert "HPG" in result.body_text


def test_fetch_and_parse_returns_none_when_all_body_selectors_fail(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """Test 9b -- SelectorChain WARNING logged + returns None on body failure."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_BODY,
    )
    with caplog.at_level(logging.WARNING):
        result = adapter.fetch_and_parse(
            "https://nhipsongkinhdoanh.vn/no-body-28733.htm"
        )
    assert result is None
    # SelectorChain logs warning when all strategies fail
    assert any("ndh_body_container" in r.message for r in caplog.records)


def test_fetch_and_parse_returns_none_on_missing_title() -> None:
    """Test 10 -- returns None when no headline found."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_TITLE,
    )
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/no-title-28734.htm")
    assert result is None


def test_fetch_and_parse_falls_back_to_clock_when_no_date() -> None:
    """Test 11 -- published_at falls back to frozen clock when no date tag."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_NO_DATE,
    )
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/vnm-28735.htm")
    assert result is not None
    assert result.published_at == _FROZEN_CLOCK_DT


def test_fetch_and_parse_returns_none_on_http_error() -> None:
    """Test 12 -- returns None on network/HTTP error (L-S28-1 degrade gracefully)."""
    import httpx

    def failing_fetcher(_url: str) -> str:
        raise httpx.HTTPError("connection refused")

    adapter = _make_adapter(fetcher=failing_fetcher)
    result = adapter.fetch_and_parse(
        "https://nhipsongkinhdoanh.vn/unreachable-28736.htm"
    )
    assert result is None


def test_fetch_and_parse_handles_meta_og_title_as_headline() -> None:
    """Test 13 -- headline extracted from meta og:title (2nd SelectorChain fallback)."""
    adapter = _make_adapter(
        fetcher=lambda _url: _ARTICLE_HTML_META_TITLE,
    )
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/ssi-28737.htm")
    assert result is not None
    assert "SSI" in result.title


# ---------------------------------------------------------------------------
# Tests 14-15: to_news_article()
# ---------------------------------------------------------------------------


def test_to_news_article_populates_mentioned_tickers() -> None:
    """Test 14 -- mentioned_tickers populated by coarse symbol scan."""
    adapter = _make_adapter()
    scraped = ScrapedArticle(
        url="https://nhipsongkinhdoanh.vn/vhm-fpt-28738.htm",
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
    """Test 15 -- body_excerpt is capped at excerpt_chars (default 4000)."""
    adapter = _make_adapter()
    long_body = "x" * 10000
    scraped = ScrapedArticle(
        url="https://nhipsongkinhdoanh.vn/long-28739.htm",
        title="Long article",
        body_html="<p>" + long_body + "</p>",
        body_text=long_body,
        published_at=_FROZEN_CLOCK_DT,
    )
    article = adapter.to_news_article(scraped, [], excerpt_chars=4000)
    assert len(article.body_excerpt) == 4000


# ---------------------------------------------------------------------------
# Tests 16-19: optional injection behavior
# ---------------------------------------------------------------------------


def test_adapter_uses_injected_rate_limiter() -> None:
    """Test 16 -- RateLimiter wait_if_needed + report_response called once each."""
    mock_rl = MagicMock()
    mock_rl.wait_if_needed = MagicMock()
    mock_rl.report_response = MagicMock()
    adapter = _make_adapter(rate_limiter=mock_rl)
    url = "https://nhipsongkinhdoanh.vn/vhm-28729.htm"
    adapter.fetch_and_parse(url)
    mock_rl.wait_if_needed.assert_called_once_with(url)
    mock_rl.report_response.assert_called_once_with(url, 200)


def test_adapter_skips_url_when_robots_disallows() -> None:
    """Test 17 -- fetch_and_parse returns None when robots disallows."""
    mock_rm = MagicMock()
    mock_rm.can_fetch = MagicMock(return_value=False)
    adapter = _make_adapter(robots_manager=mock_rm)
    result = adapter.fetch_and_parse(
        "https://nhipsongkinhdoanh.vn/blocked-28740.htm"
    )
    assert result is None


def test_adapter_writes_raw_html_when_sink_provided() -> None:
    """Test 18 -- RawHtmlSink.write called with correct args."""
    mock_sink = MagicMock()
    mock_sink.write = MagicMock()
    url = "https://nhipsongkinhdoanh.vn/vhm-28729.htm"
    adapter = _make_adapter(raw_html_sink=mock_sink)
    adapter.fetch_and_parse(url)
    mock_sink.write.assert_called_once()
    call_kwargs = mock_sink.write.call_args
    # Verify source_id="ndh", url=url, and fetched_at is tz-aware
    assert call_kwargs.kwargs["source_id"] == "ndh"
    assert call_kwargs.kwargs["url"] == url
    assert call_kwargs.kwargs["fetched_at"].tzinfo is not None


def test_adapter_default_no_injections_still_works() -> None:
    """Test 19 -- NDHAdapter(fetcher=...) with no optional injections works."""
    adapter = NDHAdapter(fetcher=lambda _: _SYNTHETIC_NDH_ARTICLE_HTML)
    result = adapter.fetch_and_parse("https://nhipsongkinhdoanh.vn/vhm-28729.htm")
    assert result is not None
    assert isinstance(result, ScrapedArticle)


# ---------------------------------------------------------------------------
# Test 20: CrawlerAdapter ABC contract enforcement
# ---------------------------------------------------------------------------


def test_subclass_missing_source_id_raises_at_class_creation() -> None:
    """Test 20 -- __init_subclass__ TypeError when source_id missing (D-066)."""
    with pytest.raises(TypeError, match="source_id"):
        type(
            "BadNDHAdapter",
            (CrawlerAdapter,),
            {
                "discover": lambda _self, _path, _max_articles=50: [],
                "fetch_and_parse": lambda _self, _url: None,
                "to_news_article": lambda _self, _s, _t: None,
            },
        )
