"""Cross-BC News event invariant tests (S36 Track D)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.contracts import (
    ExtractedClaimPublished,
    NewsArticleIngested,
    Ticker,
)


def _ingested(**overrides: object) -> NewsArticleIngested:
    base: dict[str, object] = dict(
        article_id="a1",
        source="cafef",
        source_url="https://cafef.vn/a1.chn",
        published_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        ingested_at=datetime(2026, 5, 1, 9, 5, tzinfo=UTC),
        mentioned_tickers=(Ticker("VHM"),),
        emitted_at=datetime(2026, 5, 1, 9, 6, tzinfo=UTC),
    )
    base.update(overrides)
    return NewsArticleIngested(**base)  # type: ignore[arg-type]


def test_news_ingested_constructs() -> None:
    e = _ingested()
    assert e.source == "cafef"
    assert Ticker("VHM") in e.mentioned_tickers


def test_news_ingested_rejects_published_after_ingested() -> None:
    with pytest.raises(ValueError, match="Rule 8"):
        _ingested(
            published_at=datetime(2026, 5, 1, 12, 0, tzinfo=UTC),
            ingested_at=datetime(2026, 5, 1, 9, 0, tzinfo=UTC),
        )


def test_news_ingested_rejects_empty_url() -> None:
    with pytest.raises(ValueError, match="source_url"):
        _ingested(source_url="")


def _published(**overrides: object) -> ExtractedClaimPublished:
    base: dict[str, object] = dict(
        claim_id="a1:0",
        article_id="a1",
        source_url="https://cafef.vn/a1.chn",
        sentiment="bullish",
        mentioned_tickers=(Ticker("VHM"),),
        mentioned_sectors=(),
        extractor_model="claude-sonnet-4-6",
        extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
        confidence_extracted=0.85,
        emitted_at=datetime(2026, 5, 1, 10, 1, tzinfo=UTC),
    )
    base.update(overrides)
    return ExtractedClaimPublished(**base)  # type: ignore[arg-type]


def test_claim_published_constructs() -> None:
    e = _published()
    assert e.sentiment == "bullish"


def test_claim_published_rejects_invalid_sentiment() -> None:
    with pytest.raises(ValueError, match="sentiment"):
        _published(sentiment="moonshot")


def test_claim_published_rejects_confidence_out_of_range() -> None:
    with pytest.raises(ValueError, match="confidence_extracted"):
        _published(confidence_extracted=1.5)


def test_claim_published_requires_entity_grounding() -> None:
    with pytest.raises(ValueError, match="ticker or sector"):
        _published(mentioned_tickers=(), mentioned_sectors=())


def test_claim_published_rejects_empty_extractor_model() -> None:
    with pytest.raises(ValueError, match="extractor_model"):
        _published(extractor_model="")
