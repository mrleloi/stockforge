"""Tests — UpdateKolCredibilityUseCase (orchestration + BR-2 PROVISIONAL→ACTIVE)."""

from __future__ import annotations

from datetime import UTC, datetime

import pytest

from packages.application.influence.use_cases.update_kol_credibility_use_case import (
    UpdateKolCredibilityUseCase,
)
from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.models.kol import Kol
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
from packages.domain.influence.value_objects.kol_status import KolStatus
from packages.domain.influence.value_objects.kol_style import KolStyle
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

_NOW = datetime.now(UTC)


def _kol(status: KolStatus) -> Kol:
    return Kol(
        kol_id=KolId("kol_alpha"),
        name="Test KOL",
        primary_channel_id=ChannelId("ch_yt_1"),
        style=KolStyle.FUNDAMENTAL,
        status=status,
    )


def _rec(rec_id: str, ticker: str = "HPG") -> Recommendation:
    return Recommendation(
        recommendation_id=RecommendationId(rec_id),
        kol_id=KolId("kol_alpha"),
        channel_id=ChannelId("ch_yt_1"),
        ticker=ticker,
        intent=Intent.BUY,
        timeframe=Timeframe.MONTHS,
        source_url="https://example.test/" + rec_id,
        transcript_excerpt="Mua " + ticker,
        extraction_confidence=0.9,
        extractor_model="claude-sonnet-4-6",
        extractor_version="1.0.0",
        extracted_at=_NOW,
        published_at=_NOW,
    )


def _review(rev_id: str, rec_id: str, status: OutcomeStatus) -> OutcomeReview:
    return OutcomeReview(
        review_id=rev_id,
        recommendation_id=RecommendationId(rec_id),
        review_window=ReviewWindow.THREE_MONTH,
        scheduled_at=_NOW,
        status=status,
        completed_at=_NOW,
    )


class _InMemoryKolRepo:
    def __init__(self, kols: list[Kol]) -> None:
        self._store: dict[str, Kol] = {str(k.kol_id): k for k in kols}
        self.save_calls: list[Kol] = []

    async def get(self, kol_id: KolId) -> Kol | None:
        return self._store.get(str(kol_id))

    async def save(self, kol: Kol) -> None:
        self._store[str(kol.kol_id)] = kol
        self.save_calls.append(kol)

    async def list_all(self) -> list[Kol]:
        return list(self._store.values())


class _InMemoryRecRepo:
    def __init__(self, recs: list[Recommendation]) -> None:
        self._store = {str(r.recommendation_id): r for r in recs}

    async def get(self, recommendation_id: RecommendationId) -> Recommendation | None:
        return self._store.get(str(recommendation_id))

    async def save(self, recommendation: Recommendation) -> None:
        self._store[str(recommendation.recommendation_id)] = recommendation

    async def find_recent_for_kol_ticker(
        self, *, kol_id: KolId, ticker: str, lookback_days: int
    ) -> Recommendation | None:
        del kol_id, ticker, lookback_days
        return None

    async def find_recent(
        self, *, since: datetime, min_extraction_confidence: float = 0.7
    ) -> list[Recommendation]:
        del since, min_extraction_confidence
        return list(self._store.values())


class _InMemoryReviewRepo:
    def __init__(self, reviews: list[OutcomeReview]) -> None:
        self._store = {r.review_id: r for r in reviews}

    async def get(self, review_id: str) -> OutcomeReview | None:
        return self._store.get(review_id)

    async def save(self, review: OutcomeReview) -> None:
        self._store[review.review_id] = review

    async def get_due(self, *, as_of: datetime) -> list[OutcomeReview]:
        return [r for r in self._store.values() if r.is_due(as_of=as_of)]

    async def get_completed_for_kol(self, kol_id: KolId) -> list[OutcomeReview]:
        del kol_id
        return [r for r in self._store.values() if r.is_terminal()]


class _InMemoryCredibilityRepo:
    def __init__(self) -> None:
        self.saved: list[CredibilityScore] = []

    async def get(self, kol_id: KolId) -> CredibilityScore | None:
        del kol_id
        return self.saved[-1] if self.saved else None

    async def save(self, score: CredibilityScore) -> None:
        self.saved.append(score)


def _wire(
    *,
    kols: list[Kol],
    recs: list[Recommendation],
    reviews: list[OutcomeReview],
) -> tuple[UpdateKolCredibilityUseCase, _InMemoryKolRepo, _InMemoryCredibilityRepo]:
    kol_repo = _InMemoryKolRepo(kols)
    cred_repo = _InMemoryCredibilityRepo()
    use_case = UpdateKolCredibilityUseCase(
        kol_repo=kol_repo,
        recommendation_repo=_InMemoryRecRepo(recs),
        review_repo=_InMemoryReviewRepo(reviews),
        credibility_repo=cred_repo,
        calibration_service=CalibrationService(),
    )
    return use_case, kol_repo, cred_repo


@pytest.mark.asyncio
async def test_persists_credibility_score() -> None:
    use_case, _kol_repo, cred_repo = _wire(
        kols=[_kol(KolStatus.PROVISIONAL)],
        recs=[_rec("r1")],
        reviews=[_review("rv1", "r1", OutcomeStatus.HIT)],
    )
    score = await use_case.execute(KolId("kol_alpha"))
    assert score.n_evaluated == 1
    assert len(cred_repo.saved) == 1


@pytest.mark.asyncio
async def test_provisional_to_active_transitions_at_n_10() -> None:
    """BR-2: 10 evaluated reviews trigger PROVISIONAL→ACTIVE."""
    recs = [_rec(f"r{i}") for i in range(10)]
    reviews = [
        _review(f"rv{i}", f"r{i}", OutcomeStatus.HIT) for i in range(10)
    ]
    use_case, kol_repo, _ = _wire(
        kols=[_kol(KolStatus.PROVISIONAL)],
        recs=recs,
        reviews=reviews,
    )
    await use_case.execute(KolId("kol_alpha"))
    assert kol_repo.save_calls
    assert kol_repo.save_calls[-1].status == KolStatus.ACTIVE


@pytest.mark.asyncio
async def test_provisional_does_not_transition_below_threshold() -> None:
    """9 reviews stay PROVISIONAL."""
    recs = [_rec(f"r{i}") for i in range(9)]
    reviews = [_review(f"rv{i}", f"r{i}", OutcomeStatus.HIT) for i in range(9)]
    use_case, kol_repo, _ = _wire(
        kols=[_kol(KolStatus.PROVISIONAL)],
        recs=recs,
        reviews=reviews,
    )
    await use_case.execute(KolId("kol_alpha"))
    # Only the credibility save happens; KOL save is skipped while still PROVISIONAL
    assert kol_repo.save_calls == []


@pytest.mark.asyncio
async def test_active_kol_does_not_re_transition() -> None:
    use_case, kol_repo, _ = _wire(
        kols=[_kol(KolStatus.ACTIVE)],
        recs=[_rec(f"r{i}") for i in range(15)],
        reviews=[
            _review(f"rv{i}", f"r{i}", OutcomeStatus.HIT) for i in range(15)
        ],
    )
    await use_case.execute(KolId("kol_alpha"))
    assert kol_repo.save_calls == []  # already ACTIVE; transition is a no-op
