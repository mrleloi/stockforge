"""BC-5 News value objects — invariant tests (S36 Track D)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.domain.news.value_objects import (
    ExtractorMetadata,
    ExtractorMetadataInvariantError,
    Sentiment,
)


def test_sentiment_is_categorical_5_class() -> None:
    labels = {s.value for s in Sentiment}
    assert labels == {
        "strongly_bullish",
        "bullish",
        "neutral",
        "bearish",
        "strongly_bearish",
    }


def test_sentiment_is_strenum_serializable() -> None:
    assert Sentiment.BULLISH.value == "bullish"
    assert str(Sentiment.STRONGLY_BEARISH) == "strongly_bearish"


def _meta(**overrides: object) -> ExtractorMetadata:
    base: dict[str, object] = dict(
        extractor_model="claude-sonnet-4-6",
        extractor_version="stockforge-news-extractor-0.1",
        extractor_prompt_hash="abc123def456",
        extracted_at=datetime(2026, 5, 1, 10, 0, tzinfo=UTC),
        confidence_extracted=0.85,
    )
    base.update(overrides)
    return ExtractorMetadata(**base)  # type: ignore[arg-type]


def test_metadata_constructs_with_valid_fields() -> None:
    m = _meta()
    assert m.extractor_model == "claude-sonnet-4-6"
    assert m.confidence_extracted == 0.85
    assert m.verified_by_human is False


def test_metadata_rejects_empty_model() -> None:
    with pytest.raises(ExtractorMetadataInvariantError, match="extractor_model"):
        _meta(extractor_model="")


def test_metadata_rejects_empty_version() -> None:
    with pytest.raises(ExtractorMetadataInvariantError, match="extractor_version"):
        _meta(extractor_version="  ")


def test_metadata_rejects_empty_prompt_hash() -> None:
    with pytest.raises(
        ExtractorMetadataInvariantError, match="extractor_prompt_hash"
    ):
        _meta(extractor_prompt_hash="")


def test_metadata_rejects_confidence_out_of_range() -> None:
    with pytest.raises(ExtractorMetadataInvariantError, match="confidence_extracted"):
        _meta(confidence_extracted=1.5)
    with pytest.raises(ExtractorMetadataInvariantError, match="confidence_extracted"):
        _meta(confidence_extracted=-0.1)


def test_metadata_is_frozen() -> None:
    m = _meta()
    with pytest.raises((AttributeError, TypeError)):
        m.confidence_extracted = 0.99  # type: ignore[misc]
