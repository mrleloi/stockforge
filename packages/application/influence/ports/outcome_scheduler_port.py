"""OutcomeSchedulerPort — application Protocol for outcome review scheduling."""

from __future__ import annotations

from typing import Protocol

from packages.domain.influence.models.recommendation import Recommendation

__all__ = ["OutcomeSchedulerPort"]


class OutcomeSchedulerPort(Protocol):
    """Schedule the 4 outcome reviews for a freshly-persisted Recommendation.

    Implementations write 4 OutcomeReview rows (1m / 3m / 6m / 12m windows)
    with status=PENDING + scheduled_at = recommendation.published_at + offset.

    Idempotent: re-scheduling the same Recommendation must not produce
    duplicate review rows (UNIQUE(recommendation_id, review_window)).
    """

    async def schedule_for(self, recommendation: Recommendation) -> int:
        """Schedule the 4 reviews; return the count of NEW rows written."""
        ...
