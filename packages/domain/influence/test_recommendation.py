"""Tests for Recommendation aggregate — BC-6 domain invariants.

Covers:
- BR-10: provenance fields all required (source_url, transcript_excerpt,
  extractor_model, extractor_version, extracted_at).
- BR-6: extraction_confidence < 0.7 requires requires_manual_review=True.
- BR-7: conditional flag round-trip (is_conditional() behaviour).
- transcript_excerpt > 500 chars raises.
- Intent + Timeframe enum validation.
- is_strong_directional(), is_auto_accepted() behaviour.

Source: specs/tier2-feature/002-influence-network-tracking.md § A.3 BR-6/7/10 + § B.1.
"""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.domain.influence.models.recommendation import InvariantViolation, Recommendation
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

# ---- Fixtures ---------------------------------------------------------------

_PUBLISHED_AT = datetime(2026, 5, 1, 10, 0, tzinfo=UTC)
_EXTRACTED_AT = datetime(2026, 5, 1, 11, 0, tzinfo=UTC)


def _make_recommendation(**overrides: object) -> Recommendation:
    """Build a valid Recommendation with sane defaults; override specific fields."""
    defaults: dict[str, object] = {
        "recommendation_id": RecommendationId("rec-001"),
        "kol_id": KolId("kol-abc"),
        "channel_id": ChannelId("channel-yt-001"),
        "ticker": "HPG",
        "intent": Intent.BUY,
        "timeframe": Timeframe.WEEKS,
        "source_url": "https://www.youtube.com/watch?v=abc123",
        "transcript_excerpt": "mạnh tay mua HPG ở vùng 26.000",
        "extraction_confidence": 0.85,
        "extractor_model": "claude-sonnet-4-6",
        "extractor_version": "1.0.0",
        "extracted_at": _EXTRACTED_AT,
        "published_at": _PUBLISHED_AT,
    }
    defaults.update(overrides)
    return Recommendation(**defaults)  # type: ignore[arg-type]


# ---- BR-10: provenance fields -----------------------------------------------


def test_missing_source_url_raises() -> None:
    """BR-10: source_url is mandatory; empty value raises InvariantViolation."""
    with pytest.raises(InvariantViolation, match="source_url"):
        _make_recommendation(source_url="")


def test_whitespace_source_url_raises() -> None:
    """BR-10: whitespace-only source_url is treated as missing."""
    with pytest.raises(InvariantViolation, match="source_url"):
        _make_recommendation(source_url="   ")


def test_missing_transcript_excerpt_raises() -> None:
    """BR-10: transcript_excerpt is mandatory."""
    with pytest.raises(InvariantViolation, match="transcript_excerpt"):
        _make_recommendation(transcript_excerpt="")


def test_missing_extractor_model_raises() -> None:
    """BR-10: extractor_model is mandatory."""
    with pytest.raises(InvariantViolation, match="extractor_model"):
        _make_recommendation(extractor_model="")


def test_missing_extractor_version_raises() -> None:
    """BR-10: extractor_version is mandatory."""
    with pytest.raises(InvariantViolation, match="extractor_version"):
        _make_recommendation(extractor_version="")


# ---- transcript_excerpt length cap ------------------------------------------


def test_transcript_excerpt_at_limit_ok() -> None:
    """Exactly 500 chars is accepted."""
    excerpt = "ổ" * 500
    rec = _make_recommendation(transcript_excerpt=excerpt)
    assert len(rec.transcript_excerpt) == 500


def test_transcript_excerpt_over_500_raises() -> None:
    """501 chars raises InvariantViolation per BR-10 + spec § B.6."""
    with pytest.raises(InvariantViolation, match="500 chars"):
        _make_recommendation(transcript_excerpt="ậ" * 501)


# ---- BR-6: confidence threshold ---------------------------------------------


def test_confidence_below_threshold_auto_accepted_false() -> None:
    """extraction_confidence < 0.7 + requires_manual_review=True → accepted."""
    rec = _make_recommendation(extraction_confidence=0.65, requires_manual_review=True)
    assert not rec.is_auto_accepted()
    assert rec.requires_manual_review is True


def test_confidence_below_threshold_no_manual_review_raises() -> None:
    """BR-6: confidence < 0.7 WITHOUT requires_manual_review=True → InvariantViolation."""
    with pytest.raises(InvariantViolation, match="BR-6"):
        _make_recommendation(extraction_confidence=0.5, requires_manual_review=False)


def test_confidence_at_threshold_auto_accepted() -> None:
    """Exactly 0.7 is accepted without manual review."""
    rec = _make_recommendation(extraction_confidence=0.7)
    assert rec.is_auto_accepted()


def test_confidence_above_threshold_auto_accepted() -> None:
    """Above 0.7 auto-accepted."""
    rec = _make_recommendation(extraction_confidence=0.9)
    assert rec.is_auto_accepted()


# ---- BR-7: conditional flag round-trip --------------------------------------


def test_conditional_flag_empty_conditions() -> None:
    """Empty conditions → is_conditional() returns False."""
    rec = _make_recommendation(conditions=[])
    assert not rec.is_conditional()


def test_conditional_flag_with_conditions() -> None:
    """Non-empty conditions → is_conditional() returns True (BR-7)."""
    rec = _make_recommendation(conditions=["if breaks 30k", "after VN-Index 1300"])
    assert rec.is_conditional()
    assert len(rec.conditions) == 2


def test_conditional_flag_round_trip() -> None:
    """Conditions list is stored and retrievable verbatim."""
    conds = ["nếu giá phá vỡ ngưỡng 45.000", "sau khi VN-Index vượt 1.300"]
    rec = _make_recommendation(conditions=conds)
    assert rec.conditions == conds


# ---- Intent + Timeframe validation ------------------------------------------


def test_strong_buy_is_strong_directional() -> None:
    """STRONG_BUY intent → is_strong_directional() is True."""
    rec = _make_recommendation(intent=Intent.STRONG_BUY)
    assert rec.is_strong_directional()


def test_strong_avoid_is_strong_directional() -> None:
    """STRONG_AVOID intent → is_strong_directional() is True."""
    rec = _make_recommendation(intent=Intent.STRONG_AVOID)
    assert rec.is_strong_directional()


def test_buy_not_strong_directional() -> None:
    """BUY intent is not strong directional."""
    rec = _make_recommendation(intent=Intent.BUY)
    assert not rec.is_strong_directional()


def test_all_intents_constructible() -> None:
    """Every Intent enum value can be used in a Recommendation."""
    for intent in Intent:
        rec = _make_recommendation(intent=intent)
        assert rec.intent == intent


def test_all_timeframes_constructible() -> None:
    """Every Timeframe enum value can be used in a Recommendation."""
    for timeframe in Timeframe:
        rec = _make_recommendation(timeframe=timeframe)
        assert rec.timeframe == timeframe


# ---- provenance_dict --------------------------------------------------------


def test_provenance_dict_contains_all_br10_fields() -> None:
    """provenance_dict() returns all required BR-10 fields."""
    rec = _make_recommendation()
    prov = rec.provenance_dict()
    required_keys = {
        "source_url",
        "timestamp_in_source",
        "transcript_excerpt",
        "extractor_model",
        "extractor_version",
        "extracted_at",
    }
    assert required_keys.issubset(prov.keys())


# ---- ticker validation -------------------------------------------------------


def test_empty_ticker_raises() -> None:
    """Empty ticker raises InvariantViolation."""
    with pytest.raises(InvariantViolation, match="ticker"):
        _make_recommendation(ticker="")
