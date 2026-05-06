"""RecommendationRepositoryPort — application Protocol for Recommendation persistence."""

from __future__ import annotations

from datetime import datetime
from typing import Protocol

from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId

__all__ = ["RecommendationRepositoryPort"]


class RecommendationRepositoryPort(Protocol):
    """Persistence boundary for the Recommendation aggregate."""

    async def get(self, recommendation_id: RecommendationId) -> Recommendation | None:
        """Load a Recommendation by id, or None if absent."""
        ...

    async def save(self, recommendation: Recommendation) -> None:
        """Insert or update a Recommendation (upsert)."""
        ...

    async def find_recent_for_kol_ticker(
        self,
        *,
        kol_id: KolId,
        ticker: str,
        lookback_days: int,
    ) -> Recommendation | None:
        """Return the most recent prior recommendation for KOL+ticker within lookback.

        Used by UC-1 flip detection. Returns None when no prior call exists.
        """
        ...

    async def find_recent(
        self,
        *,
        since: datetime,
        min_extraction_confidence: float = 0.7,
    ) -> list[Recommendation]:
        """Return recommendations published >= `since` with confidence >= floor.

        BR-6 default filter applied at the boundary so callers do not need to
        re-filter low-confidence rows that should be in the manual review queue.
        """
        ...
