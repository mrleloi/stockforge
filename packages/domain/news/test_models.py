"""BC-5 News entities — invariant tests (S36 Track D)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.contracts import Ticker
from packages.domain.news.models import (
    ExtractedClaim,
    ExtractedClaimInvariantError,
    NewsArticle,
    NewsArticleInvariantError,
)
from packages.domain.news.value_objects import ExtractorMetadata, Sentiment


def _article(**overrides: object) -> NewsArticle:
    base: dict[str, object] = dict(
        article_id="a1b2c3",
        source="cafef",
        source_url="https://cafef.vn/example.chn",
        title="VHM công bố lãi quý 1",
        body_excerpt="Vinhomes báo lãi 5.000 tỷ trong quý 1 năm 2026.",
        published_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 1, 9, 5, tzinfo=UTC),
        mentioned_tickers=(Ticker("VHM"),),
    )
    base.update(overrides)
    return NewsArticle(**base)  # type: ignore[arg-type]


def test_news_article_constructs_with_valid_fields() -> None:
    a = _article()
    assert a.article_id == "a1b2c3"
    assert a.source == "cafef"
    assert a.mentions(Ticker("VHM")) is True
    assert a.mentions(Ticker("FPT")) is False


def test_news_article_rejects_published_after_ingested() -> None:
    with pytest.raises(NewsArticleInvariantError, match="Rule 8"):
        _article(
            published_at=datetime(2026, 5, 1, 12, 0, tzinfo=UTC),
            ingested_at=datetime(2026, 5, 1, 11, 0, tzinfo=UTC),
        )


def test_news_article_rejects_empty_source_url() -> None:
    with pytest.raises(NewsArticleInvariantError, match="source_url"):
        _article(source_url="")


def test_news_article_rejects_empty_title() -> None:
    with pytest.raises(NewsArticleInvariantError, match="title"):
        _article(title="   ")


def _meta() -> ExtractorMetadata:
    return ExtractorMetadata(
        extractor_model="claude-sonnet-4-6",
        extractor_version="v0.1",
        extractor_prompt_hash="hash123",
        extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
        confidence_extracted=0.8,
    )


def _claim(**overrides: object) -> ExtractedClaim:
    base: dict[str, object] = dict(
        claim_id="a1b2c3:0",
        article_id="a1b2c3",
        source_url="https://cafef.vn/example.chn",
        source_text_excerpt="Vinhomes báo lãi 5.000 tỷ trong quý 1 năm 2026.",
        claim_text="VHM reported Q1 2026 net profit of 5,000 billion VND.",
        sentiment=Sentiment.BULLISH,
        extractor=_meta(),
        mentioned_tickers=(Ticker("VHM"),),
    )
    base.update(overrides)
    return ExtractedClaim(**base)  # type: ignore[arg-type]


def test_extracted_claim_constructs_with_valid_fields() -> None:
    c = _claim()
    assert c.claim_id == "a1b2c3:0"
    assert c.sentiment == Sentiment.BULLISH
    assert Ticker("VHM") in c.mentioned_tickers


def test_extracted_claim_rejects_empty_excerpt() -> None:
    with pytest.raises(ExtractedClaimInvariantError, match="source_text_excerpt"):
        _claim(source_text_excerpt="")


def test_extracted_claim_rejects_excerpt_over_500_chars() -> None:
    long_text = "x" * 501
    with pytest.raises(ExtractedClaimInvariantError, match="500"):
        _claim(source_text_excerpt=long_text)


def test_extracted_claim_requires_entity_grounding() -> None:
    with pytest.raises(
        ExtractedClaimInvariantError, match="ticker or sector"
    ):
        _claim(mentioned_tickers=(), mentioned_sectors=())


def test_extracted_claim_accepts_sector_only_grounding() -> None:
    c = _claim(mentioned_tickers=(), mentioned_sectors=("real_estate",))
    assert c.mentioned_sectors == ("real_estate",)


def test_extracted_claim_rejects_empty_source_url() -> None:
    with pytest.raises(ExtractedClaimInvariantError, match="source_url"):
        _claim(source_url="   ")
