"""Tests — SQLite repos + outcome scheduler (roundtrip + idempotency + get_due)."""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from pathlib import Path

import pytest

from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.models.kol import Kol
from packages.domain.influence.models.outcome_review import (
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
)
from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.sector_score import SectorScore
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.domain.influence.value_objects.timeframe_score import TimeframeScore
from packages.infrastructure.influence.outcome_scheduler import SqliteOutcomeScheduler
from packages.infrastructure.influence.sqlite_credibility_repository import (
    SqliteCredibilityRepository,
)
from packages.infrastructure.influence.sqlite_kol_repository import SqliteKolRepository
from packages.infrastructure.influence.sqlite_outcome_review_repository import (
    SqliteOutcomeReviewRepository,
)
from packages.infrastructure.influence.sqlite_recommendation_repository import (
    SqliteRecommendationRepository,
)

_NOW = datetime.now(UTC).replace(microsecond=0)


@pytest.fixture
def db_path(tmp_path: Path) -> Path:
    return tmp_path / "bc6.db"


def _kol() -> Kol:
    return Kol(
        kol_id=KolId("kol_a"),
        name="Test KOL",
        primary_channel_id=ChannelId("ch_yt_1"),
        style=KolStyle.FUNDAMENTAL,
        status=KolStatus.PROVISIONAL,
        sectors_covered=["banking"],
    )


def _rec(rec_id: str = "rec_a") -> Recommendation:
    return Recommendation(
        recommendation_id=RecommendationId(rec_id),
        kol_id=KolId("kol_a"),
        channel_id=ChannelId("ch_yt_1"),
        ticker="HPG",
        intent=Intent.BUY,
        timeframe=Timeframe.MONTHS,
        source_url="https://example.test/video1",
        transcript_excerpt="Mua HPG",
        extraction_confidence=0.92,
        extractor_model="claude-sonnet-4-6",
        extractor_version="1.0.0",
        extracted_at=_NOW,
        published_at=_NOW,
    )


@pytest.mark.asyncio
async def test_kol_roundtrip(db_path: Path) -> None:
    repo = SqliteKolRepository(db_path)
    kol = _kol()
    await repo.save(kol)
    loaded = await repo.get(KolId("kol_a"))
    assert loaded is not None
    assert loaded.name == "Test KOL"
    assert loaded.sectors_covered == ["banking"]
    assert loaded.status == KolStatus.PROVISIONAL


@pytest.mark.asyncio
async def test_recommendation_roundtrip_and_find_recent(db_path: Path) -> None:
    repo = SqliteRecommendationRepository(db_path)
    rec = _rec()
    await repo.save(rec)
    loaded = await repo.get(rec.recommendation_id)
    assert loaded is not None
    assert loaded.ticker == "HPG"
    assert loaded.intent == Intent.BUY

    found = await repo.find_recent(since=_NOW - timedelta(days=1))
    assert len(found) == 1


@pytest.mark.asyncio
async def test_outcome_scheduler_writes_4_rows_idempotent(db_path: Path) -> None:
    rec_repo = SqliteRecommendationRepository(db_path)
    review_repo = SqliteOutcomeReviewRepository(db_path)
    scheduler = SqliteOutcomeScheduler(db_path)
    rec = _rec()
    await rec_repo.save(rec)

    new1 = await scheduler.schedule_for(rec)
    new2 = await scheduler.schedule_for(rec)
    assert new1 == 4
    assert new2 == 0  # idempotent

    far_future = _NOW + timedelta(days=400)
    due = await review_repo.get_due(as_of=far_future)
    assert len(due) == 4
    assert {r.review_window for r in due} == {
        ReviewWindow.ONE_MONTH,
        ReviewWindow.THREE_MONTH,
        ReviewWindow.SIX_MONTH,
        ReviewWindow.TWELVE_MONTH,
    }


@pytest.mark.asyncio
async def test_get_due_filters_pending_and_past(db_path: Path) -> None:
    review_repo = SqliteOutcomeReviewRepository(db_path)
    pending_past = OutcomeReview(
        review_id="rv_past",
        recommendation_id=RecommendationId("rec_a"),
        review_window=ReviewWindow.ONE_MONTH,
        scheduled_at=_NOW - timedelta(days=10),
    )
    pending_future = OutcomeReview(
        review_id="rv_future",
        recommendation_id=RecommendationId("rec_b"),
        review_window=ReviewWindow.THREE_MONTH,
        scheduled_at=_NOW + timedelta(days=30),
    )
    completed_past = OutcomeReview(
        review_id="rv_done",
        recommendation_id=RecommendationId("rec_c"),
        review_window=ReviewWindow.ONE_MONTH,
        scheduled_at=_NOW - timedelta(days=10),
        status=OutcomeStatus.HIT,
        completed_at=_NOW,
    )
    for rev in (pending_past, pending_future, completed_past):
        await review_repo.save(rev)

    due = await review_repo.get_due(as_of=_NOW)
    due_ids = {r.review_id for r in due}
    assert due_ids == {"rv_past"}


@pytest.mark.asyncio
async def test_credibility_roundtrip_with_disaggregation(db_path: Path) -> None:
    repo = SqliteCredibilityRepository(db_path)
    score = CredibilityScore(
        kol_id=KolId("kol_a"),
        n_evaluated=12, n_hits=8, n_misses=2, n_partial=2,
        posterior_alpha=14.0, posterior_beta=8.0,
        bayesian_mean=14.0 / 22.0,
        bayesian_ci_low=0.50, bayesian_ci_high=0.78,
        sector_scores={
            "banking": SectorScore(sector="banking", n_evaluated=8, hit_rate_mean=0.7),
        },
        timeframe_scores={
            Timeframe.MONTHS: TimeframeScore(
                timeframe=Timeframe.MONTHS, n_evaluated=10, hit_rate_mean=0.65
            ),
        },
        last_updated_at=_NOW,
    )
    await repo.save(score)
    loaded = await repo.get(KolId("kol_a"))
    assert loaded is not None
    assert loaded.n_evaluated == 12
    assert "banking" in loaded.sector_scores
    assert loaded.sector_scores["banking"].hit_rate_mean == pytest.approx(0.7)
    assert Timeframe.MONTHS in loaded.timeframe_scores


@pytest.mark.asyncio
async def test_get_completed_for_kol_excludes_pending(db_path: Path) -> None:
    rec_repo = SqliteRecommendationRepository(db_path)
    review_repo = SqliteOutcomeReviewRepository(db_path)
    rec = _rec("rec_a")
    await rec_repo.save(rec)
    pending = OutcomeReview(
        review_id="rv_pend",
        recommendation_id=rec.recommendation_id,
        review_window=ReviewWindow.ONE_MONTH,
        scheduled_at=_NOW + timedelta(days=10),
    )
    completed = OutcomeReview(
        review_id="rv_done",
        recommendation_id=rec.recommendation_id,
        review_window=ReviewWindow.THREE_MONTH,
        scheduled_at=_NOW + timedelta(days=20),
        status=OutcomeStatus.HIT,
        completed_at=_NOW,
    )
    await review_repo.save(pending)
    await review_repo.save(completed)

    completed_list = await review_repo.get_completed_for_kol(KolId("kol_a"))
    ids = {r.review_id for r in completed_list}
    assert ids == {"rv_done"}
