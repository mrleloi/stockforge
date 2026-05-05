"""Tests for ThesisRecorded cross-BC event.

Coverage per sub-plan deliverable 26:
≥3 tests: frozen, eq+hash, ValueError on empty thesis_id.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 26.
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts.events.thesis_recorded import ThesisRecorded
from packages.contracts.types import Ticker

_TODAY = date(2026, 5, 1)
_NOW = datetime(2026, 5, 1, 12, 0, 0, tzinfo=UTC)
_TICKER = Ticker("HPG")


def _make_event(**kwargs: object) -> ThesisRecorded:
    defaults: dict[str, object] = dict(
        thesis_id="thesis-abc123",
        ticker=_TICKER,
        as_of=_TODAY,
        recommendation="investigate",
        confidence_level="low",
        cost_usd=Decimal("0.30"),
        recorded_at=_NOW,
    )
    defaults.update(kwargs)
    return ThesisRecorded(**defaults)  # type: ignore[arg-type]


def test_thesis_recorded_valid_construction() -> None:
    event = _make_event()
    assert event.thesis_id == "thesis-abc123"
    assert event.recommendation == "investigate"
    assert event.confidence_level == "low"
    assert event.cost_usd == Decimal("0.30")


def test_thesis_recorded_is_frozen() -> None:
    event = _make_event()
    with pytest.raises((AttributeError, TypeError)):
        event.thesis_id = "mutated"  # type: ignore[misc]


def test_thesis_recorded_eq_and_hash() -> None:
    e1 = _make_event()
    e2 = _make_event()
    assert e1 == e2
    assert hash(e1) == hash(e2)


def test_thesis_recorded_empty_thesis_id_raises() -> None:
    with pytest.raises(ValueError, match="thesis_id is required"):
        _make_event(thesis_id="")


def test_thesis_recorded_invalid_recommendation_raises() -> None:
    with pytest.raises(ValueError, match="recommendation"):
        _make_event(recommendation="buy")


def test_thesis_recorded_invalid_confidence_level_raises() -> None:
    with pytest.raises(ValueError, match="confidence_level"):
        _make_event(confidence_level="very_high")


def test_thesis_recorded_negative_cost_raises() -> None:
    with pytest.raises(ValueError, match="negative"):
        _make_event(cost_usd=Decimal("-0.01"))


def test_thesis_recorded_all_valid_recommendations() -> None:
    for rec in ("thesis_candidate", "investigate", "watch", "pass"):
        event = _make_event(recommendation=rec)
        assert event.recommendation == rec


def test_thesis_recorded_all_valid_confidence_levels() -> None:
    for conf in ("high", "medium", "low"):
        event = _make_event(confidence_level=conf)
        assert event.confidence_level == conf
