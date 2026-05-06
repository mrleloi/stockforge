"""Tests — CredibilityScore aggregate (BR-2 + spec § B.1)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.domain.influence.models.credibility_score import (
    CredibilityScore,
    InvariantViolation,
)
from packages.domain.influence.value_objects.kol_id import KolId


def _now() -> datetime:
    return datetime.now(UTC)


def _build(
    *,
    bayesian_mean: float = 0.6,
    ci_low: float = 0.55,
    ci_high: float = 0.65,
    n_evaluated: int = 12,
    n_hits: int = 6,
    n_misses: int = 4,
    n_partial: int = 2,
) -> CredibilityScore:
    return CredibilityScore(
        kol_id=KolId("kol_alpha"),
        n_evaluated=n_evaluated,
        n_hits=n_hits,
        n_misses=n_misses,
        n_partial=n_partial,
        posterior_alpha=12.0,
        posterior_beta=10.0,
        bayesian_mean=bayesian_mean,
        bayesian_ci_low=ci_low,
        bayesian_ci_high=ci_high,
        last_updated_at=_now(),
    )


def test_constructs_with_valid_inputs() -> None:
    score = _build()
    assert score.kol_id.value == "kol_alpha"
    assert score.n_evaluated == 12
    assert score.bayesian_mean == 0.6


def test_buckets_cannot_exceed_n_evaluated() -> None:
    with pytest.raises(InvariantViolation, match="cannot exceed n_evaluated"):
        _build(n_evaluated=5, n_hits=4, n_misses=3, n_partial=0)


def test_alpha_beta_must_be_positive() -> None:
    with pytest.raises(InvariantViolation, match="must be >0"):
        CredibilityScore(
            kol_id=KolId("kol_a"),
            n_evaluated=0,
            n_hits=0, n_misses=0, n_partial=0,
            posterior_alpha=0.0, posterior_beta=10.0,
            bayesian_mean=0.5, bayesian_ci_low=0.4, bayesian_ci_high=0.6,
            last_updated_at=_now(),
        )


def test_ci_low_must_not_exceed_ci_high() -> None:
    with pytest.raises(InvariantViolation, match="must be <="):
        _build(ci_low=0.7, ci_high=0.4)


def test_is_statistically_meaningful_below_threshold_returns_true() -> None:
    """CI width 0.10 < 0.15 → meaningful."""
    score = _build(ci_low=0.50, ci_high=0.60)
    assert score.is_statistically_meaningful() is True


def test_is_statistically_meaningful_above_threshold_returns_false() -> None:
    """Cold-start wide CI → not meaningful yet."""
    score = _build(ci_low=0.20, ci_high=0.80)
    assert score.is_statistically_meaningful() is False


def test_is_high_credibility_requires_both_mean_and_meaningful() -> None:
    high_meaningful = _build(bayesian_mean=0.7, ci_low=0.65, ci_high=0.75)
    high_wide = _build(bayesian_mean=0.7, ci_low=0.30, ci_high=0.90)
    low_meaningful = _build(bayesian_mean=0.5, ci_low=0.45, ci_high=0.55)
    assert high_meaningful.is_high_credibility() is True
    assert high_wide.is_high_credibility() is False
    assert low_meaningful.is_high_credibility() is False
