"""OutcomeReviewRepositoryPort — application Protocol for OutcomeReview persistence."""

from __future__ import annotations

from datetime import datetime
from typing import Protocol

from packages.domain.influence.models.outcome_review import OutcomeReview
from packages.domain.influence.value_objects.kol_id import KolId

__all__ = ["OutcomeReviewRepositoryPort"]


class OutcomeReviewRepositoryPort(Protocol):
    """Persistence boundary for OutcomeReview aggregate."""

    async def get(self, review_id: str) -> OutcomeReview | None:
        """Load an OutcomeReview by review_id, or None if absent."""
        ...

    async def save(self, review: OutcomeReview) -> None:
        """Insert or update an OutcomeReview (upsert)."""
        ...

    async def get_due(self, *, as_of: datetime) -> list[OutcomeReview]:
        """Return PENDING reviews with scheduled_at <= as_of (cron entry point)."""
        ...

    async def get_completed_for_kol(self, kol_id: KolId) -> list[OutcomeReview]:
        """Return all non-PENDING OutcomeReviews authored by KOL recommendations.

        Drives UC-3 calibration; returns reviews regardless of HIT/MISS/INVALID
        bucketing — the calibration service partitions internally.
        """
        ...
