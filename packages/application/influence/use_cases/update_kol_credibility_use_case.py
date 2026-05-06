"""UpdateKolCredibilityUseCase — orchestrates UC-3 (deterministic Bayesian recompute).

NO LLM imports — credibility is deterministic per Charter Principle 9 + I-S1.

Flow (spec § B.3 UC-3):
1. Load all completed OutcomeReviews for the KOL via review_repo.
2. Optionally load Recommendations + sector tags for disaggregation.
3. Delegate Bayesian compute to CalibrationService (domain).
4. Persist new CredibilityScore.
5. BR-2: when KOL.status == PROVISIONAL AND n_evaluated >= 10 →
   Kol.transition_to_active() and persist updated KOL.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-3 + § A.3 BR-2.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § e).
"""

from __future__ import annotations

from datetime import datetime
from typing import Protocol

from packages.application.influence.ports.credibility_repository_port import (
    CredibilityRepositoryPort,
)
from packages.application.influence.ports.kol_repository_port import KolRepositoryPort
from packages.application.influence.ports.outcome_review_repository_port import (
    OutcomeReviewRepositoryPort,
)
from packages.application.influence.ports.recommendation_repository_port import (
    RecommendationRepositoryPort,
)
from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.models.kol import Kol
from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.services.calibration_service import CalibrationService
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId

__all__ = ["SectorTagger", "UpdateKolCredibilityUseCase"]


class SectorTagger(Protocol):
    """Optional dependency that returns the sector for a ticker.

    Per BR-5 sector disaggregation. Implementations may consult the BC-2
    fundamental data BC; a stub may simply return None during Phase 3.
    """

    async def get_sector(self, ticker: str) -> str | None:
        """Return the sector code for a ticker, or None when unknown."""
        ...


class UpdateKolCredibilityUseCase:
    """Recompute credibility for one KOL from their outcome history.

    Pass `sector_tagger=None` to skip per-sector disaggregation entirely.
    """

    def __init__(
        self,
        *,
        kol_repo: KolRepositoryPort,
        recommendation_repo: RecommendationRepositoryPort,
        review_repo: OutcomeReviewRepositoryPort,
        credibility_repo: CredibilityRepositoryPort,
        calibration_service: CalibrationService,
        sector_tagger: SectorTagger | None = None,
    ) -> None:
        self._kol_repo = kol_repo
        self._recommendation_repo = recommendation_repo
        self._review_repo = review_repo
        self._credibility_repo = credibility_repo
        self._calibration_service = calibration_service
        self._sector_tagger = sector_tagger

    async def execute(
        self,
        kol_id: KolId,
        *,
        as_of: datetime | None = None,
    ) -> CredibilityScore:
        reviews = await self._review_repo.get_completed_for_kol(kol_id)

        recommendations_by_id: dict[RecommendationId, Recommendation] = {}
        sectors_by_recommendation: dict[RecommendationId, str] = {}
        for review in reviews:
            rec = await self._recommendation_repo.get(review.recommendation_id)
            if rec is None:
                continue
            recommendations_by_id[rec.recommendation_id] = rec
            if self._sector_tagger is not None:
                sector = await self._sector_tagger.get_sector(rec.ticker)
                if sector:
                    sectors_by_recommendation[rec.recommendation_id] = sector

        score = self._calibration_service.compute(
            kol_id=kol_id,
            reviews=reviews,
            recommendations_by_id=recommendations_by_id or None,
            sectors_by_recommendation=sectors_by_recommendation or None,
            as_of=as_of,
        )
        await self._credibility_repo.save(score)

        await self._maybe_transition_to_active(kol_id, score)
        return score

    async def _maybe_transition_to_active(
        self, kol_id: KolId, score: CredibilityScore
    ) -> None:
        """BR-2: PROVISIONAL→ACTIVE at n_evaluated >= 10."""
        kol: Kol | None = await self._kol_repo.get(kol_id)
        if kol is None or not kol.is_provisional:
            return
        if score.n_evaluated < 10:
            return
        kol.transition_to_active(score.n_evaluated)
        await self._kol_repo.save(kol)
