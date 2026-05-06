"""SqliteOutcomeScheduler — schedules 4 PENDING reviews per Recommendation (D-027 § f).

On every freshly-extracted Recommendation, write 4 OutcomeReview rows
(1m / 3m / 6m / 12m) with status PENDING + scheduled_at = published_at +
window_offset. Idempotent — UNIQUE(recommendation_id, review_window) guarantees
re-running schedule_for() on the same Recommendation produces zero new rows.

review_id is deterministic: f"{recommendation_id}:{window.value}". This avoids
collisions across reschedules and makes the row easy to look up by hand.
"""

from __future__ import annotations

import sqlite3
from contextlib import closing
from pathlib import Path

from packages.domain.influence.models.outcome_review import (
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
    window_offset,
)
from packages.domain.influence.models.recommendation import Recommendation

__all__ = ["SqliteOutcomeScheduler"]


_REVIEW_WINDOWS: tuple[ReviewWindow, ...] = (
    ReviewWindow.ONE_MONTH,
    ReviewWindow.THREE_MONTH,
    ReviewWindow.SIX_MONTH,
    ReviewWindow.TWELVE_MONTH,
)


class SqliteOutcomeScheduler:
    """Concrete OutcomeSchedulerPort backed by the same SQLite file as OutcomeReviewRepository."""

    def __init__(self, db_path: Path) -> None:
        self._db_path = Path(db_path)

    async def schedule_for(self, recommendation: Recommendation) -> int:
        """Insert 4 PENDING OutcomeReview rows; return count of NEW rows written."""
        new_rows = 0
        with closing(sqlite3.connect(self._db_path)) as conn:
            for window in _REVIEW_WINDOWS:
                review_id = self._review_id(recommendation, window)
                scheduled_at = recommendation.published_at + window_offset(window)
                review = OutcomeReview(
                    review_id=review_id,
                    recommendation_id=recommendation.recommendation_id,
                    review_window=window,
                    scheduled_at=scheduled_at,
                    status=OutcomeStatus.PENDING,
                )
                cur = conn.execute(
                    """
                    INSERT OR IGNORE INTO outcome_reviews (
                        review_id, recommendation_id, review_window,
                        scheduled_at, status
                    ) VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        review.review_id,
                        str(review.recommendation_id),
                        review.review_window.value,
                        review.scheduled_at.isoformat(),
                        review.status.value,
                    ),
                )
                if cur.rowcount > 0:
                    new_rows += 1
            conn.commit()
        return new_rows

    @staticmethod
    def _review_id(recommendation: Recommendation, window: ReviewWindow) -> str:
        return f"{recommendation.recommendation_id}:{window.value}"
