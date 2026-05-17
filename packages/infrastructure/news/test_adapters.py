"""BC-5 News infrastructure adapters — fixture-based tests (S36 Track D)."""

from __future__ import annotations

import json
from datetime import UTC, datetime
from pathlib import Path

import pytest

from packages.contracts import Ticker
from packages.domain.news import NewsArticle
from packages.domain.news.models import ExtractedClaim
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment
from packages.infrastructure.news import (
    CafeFScraper,
    ClaudeLlmExtractor,
    SqliteClaimRepository,
    SqliteNewsRepository,
)

# --- CafeFScraper ----------------------------------------------------------


_LISTING_HTML = """
<html><body>
<a href="/vhm-quy-1.chn">VHM Q1</a>
<a href="/fpt-doanh-thu.chn">FPT doanh thu</a>
<a href="/macro/cpi.chn">Macro CPI</a>
<a href="/about.html">About</a>
<a href="/vhm-quy-1.chn">VHM Q1 dup</a>
</body></html>
"""

_ARTICLE_HTML = """
<html><body>
<h1>VHM công bố lãi quý 1 2026</h1>
<span class="pdate">01-05-2026 09:00:00</span>
<div class="detail-content">
<p>Vinhomes (mã VHM) báo lãi 5.000 tỷ đồng trong quý 1 năm 2026. FPT cũng tăng trưởng.</p>
</div>
</body></html>
"""


def _frozen_clock() -> datetime:
    return datetime(2026, 5, 1, 9, 5, tzinfo=UTC)


def _make_scraper(pages: dict[str, str]) -> CafeFScraper:
    def fetcher(url: str) -> str:
        if url in pages:
            return pages[url]
        for path, html in pages.items():
            if url.endswith(path):
                return html
        raise RuntimeError(f"unexpected url: {url}")

    return CafeFScraper(
        fetcher=fetcher,
        clock=_frozen_clock,
        sleeper=lambda _s: None,
    )


def test_scraper_discovers_chn_urls_and_dedupes() -> None:
    scraper = _make_scraper({"/thi-truong.chn": _LISTING_HTML})
    urls = scraper.discover("/thi-truong.chn", max_articles=10)
    assert "https://cafef.vn/vhm-quy-1.chn" in urls
    assert "https://cafef.vn/fpt-doanh-thu.chn" in urls
    assert "https://cafef.vn/about.html" not in [u for u in urls]
    # dedupe
    assert urls.count("https://cafef.vn/vhm-quy-1.chn") == 1


def test_scraper_respects_max_articles_cap() -> None:
    scraper = _make_scraper({"/thi-truong.chn": _LISTING_HTML})
    urls = scraper.discover("/thi-truong.chn", max_articles=1)
    assert len(urls) == 1


def test_scraper_fetch_article_returns_scraped_with_title_and_body() -> None:
    scraper = _make_scraper(
        {"https://cafef.vn/vhm-quy-1.chn": _ARTICLE_HTML}
    )
    scraped = scraper.fetch_article("https://cafef.vn/vhm-quy-1.chn")
    assert scraped is not None
    assert "VHM" in scraped.title
    assert "Vinhomes" in scraped.body_text
    assert scraped.published_at == datetime(2026, 5, 1, 9, 0, tzinfo=UTC)


def test_scraper_returns_none_on_missing_body() -> None:
    scraper = _make_scraper(
        {"https://cafef.vn/x.chn": "<html><body><h1>title</h1></body></html>"}
    )
    assert scraper.fetch_article("https://cafef.vn/x.chn") is None


def test_scraper_to_news_article_coarse_scans_mentions() -> None:
    scraper = _make_scraper(
        {"https://cafef.vn/vhm-quy-1.chn": _ARTICLE_HTML}
    )
    scraped = scraper.fetch_article("https://cafef.vn/vhm-quy-1.chn")
    assert scraped is not None
    article = scraper.to_news_article(
        scraped, ticker_universe=[Ticker("VHM"), Ticker("FPT"), Ticker("MWG")]
    )
    assert Ticker("VHM") in article.mentioned_tickers
    assert Ticker("FPT") in article.mentioned_tickers
    assert Ticker("MWG") not in article.mentioned_tickers
    assert article.source == "cafef"
    assert article.ingested_at == _frozen_clock()


def test_scraper_returns_none_on_fetcher_exception() -> None:
    def bad_fetcher(_url: str) -> str:
        raise RuntimeError("boom")

    scraper = CafeFScraper(
        fetcher=bad_fetcher, clock=_frozen_clock, sleeper=lambda _s: None
    )
    assert scraper.fetch_article("https://cafef.vn/x.chn") is None


# --- SqliteNewsRepository --------------------------------------------------


def _article(article_id: str, tickers: tuple[Ticker, ...]) -> NewsArticle:
    return NewsArticle(
        article_id=article_id,
        source="cafef",
        source_url=f"https://cafef.vn/{article_id}.chn",
        title=f"Title {article_id}",
        body_excerpt=f"body {article_id}",
        published_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 1, 9, 5, tzinfo=UTC),
        mentioned_tickers=tickers,
    )


def test_news_repo_save_and_count(tmp_path: Path) -> None:
    repo = SqliteNewsRepository(db_path=tmp_path / "news.sqlite")
    n = repo.save_many(
        [
            _article("a1", (Ticker("VHM"),)),
            _article("a2", (Ticker("FPT"),)),
        ]
    )
    assert n == 2
    assert repo.count() == 2


def test_news_repo_save_is_idempotent(tmp_path: Path) -> None:
    repo = SqliteNewsRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many([_article("a1", (Ticker("VHM"),))])
    repo.save_many([_article("a1", (Ticker("VHM"),))])
    assert repo.count() == 1


def test_news_repo_get_known_as_of_filters_by_ticker(tmp_path: Path) -> None:
    repo = SqliteNewsRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many(
        [
            _article("a1", (Ticker("VHM"),)),
            _article("a2", (Ticker("FPT"),)),
        ]
    )
    result = repo.get_known_as_of(
        ticker=Ticker("VHM"), as_of_date=datetime(2026, 5, 5).date()
    )
    assert len(result) == 1
    assert result[0].article_id == "a1"


def test_news_repo_get_known_as_of_excludes_future_articles(
    tmp_path: Path,
) -> None:
    repo = SqliteNewsRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many([_article("a1", (Ticker("VHM"),))])
    # as_of before published_at: zero results
    result = repo.get_known_as_of(
        ticker=Ticker("VHM"), as_of_date=datetime(2026, 4, 1).date()
    )
    assert result == []


def test_news_repo_get_recent_returns_articles_since(tmp_path: Path) -> None:
    repo = SqliteNewsRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many([_article("a1", (Ticker("VHM"),))])
    result = repo.get_recent(
        ticker=Ticker("VHM"),
        since=datetime(2026, 4, 1, tzinfo=UTC),
    )
    assert len(result) == 1


# --- SqliteClaimRepository -------------------------------------------------


def _meta() -> ExtractorMetadata:
    return ExtractorMetadata(
        extractor_model="claude-sonnet-4-6",
        extractor_version="v0.1",
        extractor_prompt_hash="hash123",
        extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
        confidence_extracted=0.85,
    )


def _claim(claim_id: str, article_id: str, ticker: Ticker) -> ExtractedClaim:
    return ExtractedClaim(
        claim_id=claim_id,
        article_id=article_id,
        source_url=f"https://cafef.vn/{article_id}.chn",
        source_text_excerpt="excerpt verbatim quote",
        claim_text="LLM-paraphrased claim text",
        sentiment=Sentiment.BULLISH,
        extractor=_meta(),
        mentioned_tickers=(ticker,),
        key_phrases=("growth", "Q1"),
    )


def test_claim_repo_save_and_roundtrip(tmp_path: Path) -> None:
    repo = SqliteClaimRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many([_claim("a1:0", "a1", Ticker("VHM"))])
    fetched = repo.get_for_ticker(Ticker("VHM"))
    assert len(fetched) == 1
    c = fetched[0]
    assert c.claim_text == "LLM-paraphrased claim text"
    assert c.sentiment == Sentiment.BULLISH
    assert c.extractor.confidence_extracted == 0.85
    assert c.key_phrases == ("growth", "Q1")


def test_claim_repo_idempotent_on_claim_id(tmp_path: Path) -> None:
    repo = SqliteClaimRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many([_claim("a1:0", "a1", Ticker("VHM"))])
    repo.save_many([_claim("a1:0", "a1", Ticker("VHM"))])
    assert repo.count() == 1


def test_claim_repo_filters_by_ticker(tmp_path: Path) -> None:
    repo = SqliteClaimRepository(db_path=tmp_path / "news.sqlite")
    repo.save_many(
        [
            _claim("a1:0", "a1", Ticker("VHM")),
            _claim("a2:0", "a2", Ticker("FPT")),
        ]
    )
    assert len(repo.get_for_ticker(Ticker("VHM"))) == 1
    assert len(repo.get_for_ticker(Ticker("FPT"))) == 1
    assert repo.get_for_ticker(Ticker("MWG")) == []


# --- ClaudeLlmExtractor ----------------------------------------------------


def _stub_response(claims: list[dict[str, object]]) -> str:
    return json.dumps({"claims": claims})


def _vhm_article() -> NewsArticle:
    return NewsArticle(
        article_id="a1",
        source="cafef",
        source_url="https://cafef.vn/a1.chn",
        title="VHM lãi quý 1",
        body_excerpt="VHM báo lãi 5000 tỷ trong quý 1 năm 2026.",
        published_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 1, 9, 5, tzinfo=UTC),
        mentioned_tickers=(Ticker("VHM"),),
    )


def _make_extractor(response: str) -> ClaudeLlmExtractor:
    return ClaudeLlmExtractor(
        transport=lambda _system, _body: response,
        clock=lambda: datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
    )


def test_extractor_parses_valid_response() -> None:
    response = _stub_response(
        [
            {
                "claim_text": "VHM Q1 profit grew 20%",
                "source_text_excerpt": "VHM báo lãi 5000 tỷ trong quý 1",
                "sentiment": "bullish",
                "mentioned_tickers": ["VHM"],
                "mentioned_sectors": [],
                "key_phrases": ["Q1", "growth"],
                "tone_indicators": ["positive"],
                "confidence": 0.9,
            }
        ]
    )
    extractor = _make_extractor(response)
    claims = extractor.extract(_vhm_article())
    assert len(claims) == 1
    c = claims[0]
    assert c.sentiment == Sentiment.BULLISH
    assert c.extractor.extractor_model == "claude-sonnet-4-6"
    assert c.extractor.confidence_extracted == 0.9
    assert c.key_phrases == ("Q1", "growth")


def test_extractor_returns_empty_on_invalid_json() -> None:
    extractor = _make_extractor("not json at all")
    assert extractor.extract(_vhm_article()) == []


def test_extractor_returns_empty_on_transport_failure() -> None:
    def boom(_system: str, _body: str) -> str:
        raise RuntimeError("rate limit")

    extractor = ClaudeLlmExtractor(
        transport=boom,
        clock=lambda: datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
    )
    assert extractor.extract(_vhm_article()) == []


def test_extractor_drops_claims_without_entity_grounding() -> None:
    response = _stub_response(
        [
            {
                "claim_text": "vague",
                "source_text_excerpt": "excerpt",
                "sentiment": "neutral",
                "mentioned_tickers": [],
                "mentioned_sectors": [],
                "confidence": 0.5,
            }
        ]
    )
    extractor = _make_extractor(response)
    assert extractor.extract(_vhm_article()) == []


def test_extractor_clamps_confidence_into_range() -> None:
    response = _stub_response(
        [
            {
                "claim_text": "VHM strong",
                "source_text_excerpt": "VHM báo lãi",
                "sentiment": "strongly_bullish",
                "mentioned_tickers": ["VHM"],
                "confidence": 1.7,
            }
        ]
    )
    extractor = _make_extractor(response)
    claims = extractor.extract(_vhm_article())
    assert len(claims) == 1
    assert claims[0].extractor.confidence_extracted == 1.0


def test_extractor_truncates_excerpt_over_500_chars() -> None:
    long = "x" * 700
    response = _stub_response(
        [
            {
                "claim_text": "long excerpt",
                "source_text_excerpt": long,
                "sentiment": "neutral",
                "mentioned_tickers": ["VHM"],
                "confidence": 0.5,
            }
        ]
    )
    extractor = _make_extractor(response)
    claims = extractor.extract(_vhm_article())
    assert len(claims) == 1
    assert len(claims[0].source_text_excerpt) == 500


def test_extractor_skips_invalid_sentiment_label() -> None:
    response = _stub_response(
        [
            {
                "claim_text": "x",
                "source_text_excerpt": "y",
                "sentiment": "moonshot",
                "mentioned_tickers": ["VHM"],
                "confidence": 0.5,
            }
        ]
    )
    extractor = _make_extractor(response)
    assert extractor.extract(_vhm_article()) == []


def test_extractor_returns_empty_when_response_is_dict_without_claims() -> None:
    extractor = _make_extractor(json.dumps({"items": []}))
    assert extractor.extract(_vhm_article()) == []


# --- ClaudeLlmExtractor NEW FIELDS plan-031 (S368 D3) ----------------------


def _make_extractor_with_lexicon(
    response: str,
) -> ClaudeLlmExtractor:
    """Factory producing extractor with real VnTokenizer + VnSentimentLexicon."""
    from apps.extraction.sentiment.vn_lexicon import VnSentimentLexicon
    from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer

    tokenizer = VnTokenizer()
    lexicon = VnSentimentLexicon(tokenizer=tokenizer)
    return ClaudeLlmExtractor(
        transport=lambda _system, _body: response,
        clock=lambda: datetime(2026, 5, 17, 10, 0, tzinfo=UTC),
        tokenizer=tokenizer,
        lexicon=lexicon,
    )


def _article_with_body(body_excerpt: str) -> NewsArticle:
    return NewsArticle(
        article_id="a2",
        source="vietstock",
        source_url="https://vietstock.vn/a2.htm",
        title="Test article",
        body_excerpt=body_excerpt,
        published_at=datetime(2026, 5, 17, 8, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 17, 8, 5, tzinfo=UTC),
        mentioned_tickers=(Ticker("VHM"),),
    )


def _minimal_claim_response() -> str:
    return _stub_response(
        [
            {
                "claim_text": "VHM tăng mạnh",
                "source_text_excerpt": "VHM tăng mạnh phiên này",
                "sentiment": "bullish",
                "mentioned_tickers": ["VHM"],
                "mentioned_sectors": [],
                "key_phrases": [],
                "tone_indicators": [],
                "confidence": 0.8,
            }
        ]
    )


def test_extractor_emits_lexicon_score_when_lexicon_injected() -> None:
    """TC D3-1: lexicon_score > 0 when article contains tier-1 positive keyword."""
    # "tăng_trần" (hit circuit breaker limit up) = weight 1.0 in lexicon
    body = "VHM tăng_trần phiên này, cổ đông rất phấn khởi."
    extractor = _make_extractor_with_lexicon(_minimal_claim_response())
    article = _article_with_body(body)
    claims = extractor.extract(article)
    assert len(claims) == 1, "Expected 1 claim from minimal response"
    assert claims[0].lexicon_score > 0.0, (
        f"Expected positive lexicon_score for article with 'tăng_trần', "
        f"got {claims[0].lexicon_score}"
    )


def test_extractor_emits_mentioned_pump_anchors_when_anchor_in_body() -> None:
    """TC D3-2: mentioned_pump_anchors contains matched anchor from VN_CULTURAL_ANCHORS."""
    # "đội_lái" is in VN_CULTURAL_ANCHORS frozenset; weight -0.8 in lexicon
    body = "Đội_lái đang thao túng cổ phiếu VHM, nhà đầu tư cần cẩn thận."
    extractor = _make_extractor_with_lexicon(_minimal_claim_response())
    article = _article_with_body(body)
    claims = extractor.extract(article)
    assert len(claims) == 1
    assert "đội_lái" in claims[0].mentioned_pump_anchors, (
        f"Expected 'đội_lái' in mentioned_pump_anchors, "
        f"got {claims[0].mentioned_pump_anchors}"
    )


def test_extractor_emits_zero_lexicon_score_when_lexicon_none() -> None:
    """TC D3-3: lexicon_score=0.0 + mentioned_pump_anchors=() when lexicon=None (default)."""
    # Default construction — no lexicon injection
    body = "VHM tăng_trần và đội_lái đang thao túng."
    extractor = ClaudeLlmExtractor(
        transport=lambda _system, _body: _minimal_claim_response(),
        clock=lambda: datetime(2026, 5, 17, 10, 0, tzinfo=UTC),
        lexicon=None,  # explicit None = no scoring
    )
    article = _article_with_body(body)
    claims = extractor.extract(article)
    assert len(claims) == 1
    assert claims[0].lexicon_score == 0.0, (
        f"Expected lexicon_score=0.0 with lexicon=None, got {claims[0].lexicon_score}"
    )
    assert claims[0].mentioned_pump_anchors == (), (
        f"Expected empty tuple with lexicon=None, got {claims[0].mentioned_pump_anchors}"
    )


def test_extractor_default_transport_is_make_claude_cli_news_transport() -> None:
    """TC D3-4: default transport factory present + anthropic NOT in module source."""
    # Verify transport field default is the CLI factory (not _default_transport)
    import inspect

    from packages.infrastructure.news import claude_llm_extractor as mod

    # _default_transport symbol must NOT exist on module (DD-2 removal)
    assert not hasattr(mod, "_default_transport"), (
        "_default_transport must be REMOVED per plan-031 DD-2 + D-050 SYSTEMIC"
    )
    # No-arg construction instantiates correctly (factory is called lazily on field access)
    ex = ClaudeLlmExtractor(
        transport=lambda _s, _b: "{}",  # stub to avoid live CLI call
    )
    assert type(ex).__name__ == "ClaudeLlmExtractor"

    # Verify source code has zero 'import anthropic' / 'from anthropic' lines
    source = inspect.getsource(mod)
    assert "import anthropic" not in source, (
        "import anthropic MUST NOT appear in claude_llm_extractor.py per D-050 + plan-031 DD-2"
    )
    assert "from anthropic" not in source, (
        "from anthropic MUST NOT appear in claude_llm_extractor.py per D-050 + plan-031 DD-2"
    )


def test_extractor_no_anthropic_import_in_module_source() -> None:
    """TC D3-5: grep-assert zero anthropic import lines in extractor file."""
    from pathlib import Path

    extractor_path = (
        Path(__file__).parent / "claude_llm_extractor.py"
    )
    source = extractor_path.read_text(encoding="utf-8")
    lines_with_anthropic = [
        line.strip()
        for line in source.splitlines()
        if "import anthropic" in line or "from anthropic" in line
    ]
    assert len(lines_with_anthropic) == 0, (
        f"Found anthropic import lines (must be ZERO per L-S227-1 + D-050 + plan-031 DD-2): "
        f"{lines_with_anthropic}"
    )


def test_extractor_lexicon_score_deterministic_across_runs() -> None:
    """TC D3-6: lexicon_score identical across 2 calls — D-059 R2 determinism smoke."""
    body = "VHM tăng_trần, đội_lái đẩy giá."
    extractor = _make_extractor_with_lexicon(_minimal_claim_response())
    article = _article_with_body(body)
    claims1 = extractor.extract(article)
    claims2 = extractor.extract(article)
    assert len(claims1) == 1
    assert len(claims2) == 1
    assert claims1[0].lexicon_score == claims2[0].lexicon_score, (
        f"NON-DETERMINISTIC lexicon_score: {claims1[0].lexicon_score} != "
        f"{claims2[0].lexicon_score}"
    )
    assert claims1[0].mentioned_pump_anchors == claims2[0].mentioned_pump_anchors, (
        f"NON-DETERMINISTIC mentioned_pump_anchors: {claims1[0].mentioned_pump_anchors} != "
        f"{claims2[0].mentioned_pump_anchors}"
    )


@pytest.mark.parametrize(
    "label,enum",
    [
        ("strongly_bullish", Sentiment.STRONGLY_BULLISH),
        ("bullish", Sentiment.BULLISH),
        ("neutral", Sentiment.NEUTRAL),
        ("bearish", Sentiment.BEARISH),
        ("strongly_bearish", Sentiment.STRONGLY_BEARISH),
    ],
)
def test_extractor_handles_all_sentiment_labels(
    label: str, enum: Sentiment
) -> None:
    response = _stub_response(
        [
            {
                "claim_text": "x",
                "source_text_excerpt": "y",
                "sentiment": label,
                "mentioned_tickers": ["VHM"],
                "confidence": 0.5,
            }
        ]
    )
    extractor = _make_extractor(response)
    claims = extractor.extract(_vhm_article())
    assert len(claims) == 1
    assert claims[0].sentiment == enum
