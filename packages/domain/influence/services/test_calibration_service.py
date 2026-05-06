"""Tests — CalibrationService (Bayesian skeptical prior + disaggregation)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.domain.influence.models.outcome_review import (
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
)
from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.services.calibration_service import CalibrationService
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

_KOL = KolId("kol_x")
_NOW = datetime.now(UTC)


def _review(
    review_id: str,
    recommendation_id: str,
    status: OutcomeStatus,
    *,
    window: ReviewWindow = ReviewWindow.THREE_MONTH,
) -> OutcomeReview:
    completed = _NOW if status != OutcomeStatus.PENDING else None
    return OutcomeReview(
        review_id=review_id,
        recommendation_id=RecommendationId(recommendation_id),
        review_window=window,
        scheduled_at=_NOW,
        status=status,
        completed_at=completed,
    )


def _rec(rec_id: str, ticker: str, timeframe: Timeframe) -> Recommendation:
    return Recommendation(
        recommendation_id=RecommendationId(rec_id),
        kol_id=_KOL,
        channel_id=ChannelId("ch_a"),
        ticker=ticker,
        intent=Intent.BUY,
        timeframe=timeframe,
        source_url="https://example.test/" + rec_id,
        transcript_excerpt="Mua " + ticker,
        extraction_confidence=0.95,
        extractor_model="claude-sonnet-4-6",
        extractor_version="1.0.0",
        extracted_at=_NOW,
        published_at=_NOW,
    )


def test_cold_start_returns_prior_mean_with_wide_ci() -> None:
    """0 reviews → posterior == prior == Beta(5,5); mean=0.5, CI width >> 0.15."""
    service = CalibrationService()
    score = service.compute(kol_id=_KOL, reviews=[])
    assert score.n_evaluated == 0
    assert score.posterior_alpha == pytest.approx(5.0)
    assert score.posterior_beta == pytest.approx(5.0)
    assert score.bayesian_mean == pytest.approx(0.5)
    assert score.is_statistically_meaningful() is False
    assert score.ci_width > 0.15


def test_skeptical_prior_dampens_3_hits_0_misses() -> None:
    """3 hits / 0 misses → posterior_mean ≈ 8/13 ≈ 0.615 (NOT 1.0)."""
    service = CalibrationService()
    reviews = [
        _review(f"r{i}", f"rec{i}", OutcomeStatus.HIT) for i in range(3)
    ]
    score = service.compute(kol_id=_KOL, reviews=reviews)
    assert score.bayesian_mean < 0.7
    assert score.bayesian_mean == pytest.approx(8.0 / 13.0, abs=1e-9)
    assert score.n_hits == 3
    assert score.n_misses == 0


def test_partial_weighted_as_half_success() -> None:
    """2 hits + 0 miss + 2 partial → success_weighted = 2 + 1 = 3 of 4 → posterior alpha=8 beta=6."""
    service = CalibrationService()
    reviews = (
        [_review(f"h{i}", f"hr{i}", OutcomeStatus.HIT) for i in range(2)]
        + [_review(f"p{i}", f"pr{i}", OutcomeStatus.PARTIAL) for i in range(2)]
    )
    score = service.compute(kol_id=_KOL, reviews=reviews)
    assert score.n_partial == 2
    assert score.posterior_alpha == pytest.approx(5.0 + 3.0)
    assert score.posterior_beta == pytest.approx(5.0 + 1.0)


def test_invalid_reviews_excluded_from_buckets_but_count_evaluated() -> None:
    service = CalibrationService()
    reviews = [
        _review("h1", "r1", OutcomeStatus.HIT),
        _review("inv1", "r2", OutcomeStatus.INVALID),
        _review("inc1", "r3", OutcomeStatus.INCONCLUSIVE),
    ]
    score = service.compute(kol_id=_KOL, reviews=reviews)
    assert score.n_evaluated == 3
    assert score.n_hits == 1
    assert score.n_misses == 0
    assert score.n_partial == 0
    assert score.posterior_alpha == pytest.approx(6.0)


def test_timeframe_disaggregation_groups_per_horizon() -> None:
    service = CalibrationService()
    rec_short = _rec("rs", "HPG", Timeframe.WEEKS)
    rec_long = _rec("rl", "VIC", Timeframe.LONG_TERM)
    reviews = [
        _review("rs:r1", "rs", OutcomeStatus.HIT),
        _review("rl:r1", "rl", OutcomeStatus.MISS),
        _review("rl:r2", "rl", OutcomeStatus.MISS),
    ]
    score = service.compute(
        kol_id=_KOL,
        reviews=reviews,
        recommendations_by_id={
            rec_short.recommendation_id: rec_short,
            rec_long.recommendation_id: rec_long,
        },
    )
    assert Timeframe.WEEKS in score.timeframe_scores
    assert Timeframe.LONG_TERM in score.timeframe_scores
    assert score.timeframe_scores[Timeframe.WEEKS].n_evaluated == 1
    assert score.timeframe_scores[Timeframe.LONG_TERM].n_evaluated == 2


def test_sector_disaggregation_groups_per_sector() -> None:
    service = CalibrationService()
    reviews = [
        _review("b1", "rec_a", OutcomeStatus.HIT),
        _review("b2", "rec_b", OutcomeStatus.MISS),
        _review("e1", "rec_c", OutcomeStatus.HIT),
    ]
    score = service.compute(
        kol_id=_KOL,
        reviews=reviews,
        sectors_by_recommendation={
            RecommendationId("rec_a"): "banking",
            RecommendationId("rec_b"): "banking",
            RecommendationId("rec_c"): "energy",
        },
    )
    assert "banking" in score.sector_scores
    assert "energy" in score.sector_scores
    assert score.sector_scores["banking"].n_evaluated == 2
    assert score.sector_scores["energy"].n_evaluated == 1


def test_ci_tightens_with_more_samples() -> None:
    # Empirical threshold: at 60% hit rate, Beta(5,5) prior needs n>=110 for
    # CI width <0.15 (spec § B.1). n=150 (90H/60M) → width=0.1274, comfortably
    # below the 0.15 statistically-meaningful threshold while remaining within
    # spec § C Month-6 envelope (200+ reviews → first 5 KOLs hit threshold).
    service = CalibrationService()
    small = service.compute(
        kol_id=_KOL,
        reviews=[_review(f"s{i}", f"sr{i}", OutcomeStatus.HIT) for i in range(3)],
    )
    large = service.compute(
        kol_id=_KOL,
        reviews=(
            [_review(f"h{i}", f"hr{i}", OutcomeStatus.HIT) for i in range(90)]
            + [_review(f"m{i}", f"mr{i}", OutcomeStatus.MISS) for i in range(60)]
        ),
    )
    assert large.ci_width < small.ci_width
    assert large.is_statistically_meaningful() is True
