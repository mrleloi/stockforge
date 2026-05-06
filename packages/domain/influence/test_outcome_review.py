"""Tests — OutcomeReview aggregate (status transitions + window offsets)."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.influence.models.outcome_review import (
    InvariantViolation,
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
    window_offset,
)
from packages.domain.influence.value_objects.recommendation_id import RecommendationId


def _build(*, status: OutcomeStatus = OutcomeStatus.PENDING) -> OutcomeReview:
    completed = datetime.now(UTC) if status != OutcomeStatus.PENDING else None
    return OutcomeReview(
        review_id="rec_X:one_month",
        recommendation_id=RecommendationId("rec_X"),
        review_window=ReviewWindow.ONE_MONTH,
        scheduled_at=datetime(2026, 6, 1, tzinfo=UTC),
        status=status,
        completed_at=completed,
    )


def test_constructs_with_pending_status() -> None:
    review = _build()
    assert review.is_pending() is True
    assert review.is_terminal() is False
    assert review.completed_at is None


def test_window_membership_is_4_values() -> None:
    assert {w.value for w in ReviewWindow} == {
        "one_month", "three_month", "six_month", "twelve_month",
    }


def test_window_offset_days() -> None:
    assert window_offset(ReviewWindow.ONE_MONTH) == timedelta(days=30)
    assert window_offset(ReviewWindow.THREE_MONTH) == timedelta(days=90)
    assert window_offset(ReviewWindow.SIX_MONTH) == timedelta(days=180)
    assert window_offset(ReviewWindow.TWELVE_MONTH) == timedelta(days=365)


def test_mark_evaluated_transitions_status() -> None:
    review = _build()
    review.mark_evaluated(
        status=OutcomeStatus.HIT,
        price_at_rec_vnd=24500.0,
        price_at_review_vnd=27000.0,
        return_pct=0.102,
        benchmark_return_pct=0.04,
        excess_return_pct=0.062,
    )
    assert review.status == OutcomeStatus.HIT
    assert review.is_terminal() is True
    assert review.completed_at is not None


def test_mark_evaluated_refuses_to_replace_terminal_state() -> None:
    review = _build()
    review.mark_evaluated(
        status=OutcomeStatus.HIT,
        price_at_rec_vnd=10.0, price_at_review_vnd=11.0,
        return_pct=0.1, benchmark_return_pct=0.0, excess_return_pct=0.1,
    )
    with pytest.raises(InvariantViolation, match="terminal"):
        review.mark_evaluated(
            status=OutcomeStatus.MISS,
            price_at_rec_vnd=10.0, price_at_review_vnd=9.0,
            return_pct=-0.1, benchmark_return_pct=0.0, excess_return_pct=-0.1,
        )


def test_mark_invalid_records_reason() -> None:
    review = _build()
    review.mark_invalid(reason="Condition never met during review period")
    assert review.status == OutcomeStatus.INVALID
    assert review.notes == "Condition never met during review period"
    assert review.is_terminal() is True


def test_is_due_when_pending_and_past_scheduled() -> None:
    review = _build()
    assert review.is_due(as_of=datetime(2026, 7, 1, tzinfo=UTC)) is True
    assert review.is_due(as_of=datetime(2026, 5, 1, tzinfo=UTC)) is False
