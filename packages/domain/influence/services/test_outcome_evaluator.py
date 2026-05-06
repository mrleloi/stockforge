"""Tests — OutcomeEvaluator (intent × timeframe HIT/MISS/PARTIAL matrix)."""

from __future__ import annotations

import pytest

from packages.domain.influence.models.outcome_review import OutcomeStatus
from packages.domain.influence.services.outcome_evaluator import (
    EXCESS_RETURN_THRESHOLDS,
    OutcomeEvaluator,
)
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.timeframe import Timeframe


@pytest.fixture
def evaluator() -> OutcomeEvaluator:
    return OutcomeEvaluator()


def test_strong_buy_hit_at_threshold(evaluator: OutcomeEvaluator) -> None:
    threshold = EXCESS_RETURN_THRESHOLDS[Timeframe.MONTHS]  # 0.10
    assert evaluator.evaluate(
        intent=Intent.STRONG_BUY,
        timeframe=Timeframe.MONTHS,
        excess_return=threshold,
    ) == OutcomeStatus.HIT


def test_buy_partial_at_half_threshold(evaluator: OutcomeEvaluator) -> None:
    """BUY + excess >= threshold/2 = PARTIAL."""
    assert evaluator.evaluate(
        intent=Intent.BUY,
        timeframe=Timeframe.WEEKS,
        excess_return=0.025,  # threshold=0.05; half=0.025
    ) == OutcomeStatus.PARTIAL


def test_buy_miss_below_half_threshold(evaluator: OutcomeEvaluator) -> None:
    assert evaluator.evaluate(
        intent=Intent.BUY,
        timeframe=Timeframe.WEEKS,
        excess_return=0.01,
    ) == OutcomeStatus.MISS


def test_avoid_hit_when_excess_return_negative_enough(
    evaluator: OutcomeEvaluator,
) -> None:
    assert evaluator.evaluate(
        intent=Intent.AVOID,
        timeframe=Timeframe.MONTHS,
        excess_return=-0.12,
    ) == OutcomeStatus.HIT


def test_strong_avoid_partial_at_negative_half_threshold(
    evaluator: OutcomeEvaluator,
) -> None:
    assert evaluator.evaluate(
        intent=Intent.STRONG_AVOID,
        timeframe=Timeframe.MONTHS,
        excess_return=-0.06,  # half threshold
    ) == OutcomeStatus.PARTIAL


def test_neutral_hit_when_within_half_threshold(
    evaluator: OutcomeEvaluator,
) -> None:
    assert evaluator.evaluate(
        intent=Intent.NEUTRAL,
        timeframe=Timeframe.MONTHS,
        excess_return=0.04,  # |0.04| <= 0.05
    ) == OutcomeStatus.HIT


def test_watch_always_inconclusive(evaluator: OutcomeEvaluator) -> None:
    """WATCH is informational — never HIT/MISS."""
    assert evaluator.evaluate(
        intent=Intent.WATCH,
        timeframe=Timeframe.LONG_TERM,
        excess_return=0.50,
    ) == OutcomeStatus.INCONCLUSIVE
