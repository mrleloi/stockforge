"""SqliteOutcomeReviewRepository — SQLite-backed OutcomeReview persistence.

UNIQUE(recommendation_id, review_window) guarantees scheduler idempotency.
get_due() returns PENDING reviews with scheduled_at <= as_of, ordered by
scheduled_at ascending so callers process the oldest backlog first.
"""

from __future__ import annotations

import sqlite3
from contextlib import closing
from datetime import datetime
from pathlib import Path

from packages.domain.influence.models.outcome_review import (
    OutcomeReview,
    OutcomeStatus,
    ReviewWindow,
)
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId

__all__ = ["SqliteOutcomeReviewRepository"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS outcome_reviews (
    review_id              TEXT PRIMARY KEY,
    recommendation_id      TEXT NOT NULL,
    review_window          TEXT NOT NULL CHECK (
        review_window IN ('one_month','three_month','six_month','twelve_month')
    ),
    scheduled_at           TEXT NOT NULL,
    completed_at           TEXT,
    status                 TEXT NOT NULL DEFAULT 'pending',
    price_at_rec_vnd       REAL,
    price_at_review_vnd    REAL,
    return_pct             REAL,
    benchmark_return_pct   REAL,
    excess_return_pct      REAL,
    notes                  TEXT,
    UNIQUE(recommendation_id, review_window)
);
CREATE INDEX IF NOT EXISTS idx_reviews_due ON outcome_reviews(scheduled_at, status);
"""


def _isofmt(value: datetime | None) -> str | None:
    return value.isoformat() if value is not None else None


class SqliteOutcomeReviewRepository:
    """Concrete SQLite OutcomeReviewRepositoryPort."""

    def __init__(self, db_path: Path) -> None:
        self._db_path = Path(db_path)
        self._init_schema()

    def _init_schema(self) -> None:
        with closing(sqlite3.connect(self._db_path)) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self._db_path)
        conn.row_factory = sqlite3.Row
        return conn

    async def get(self, review_id: str) -> OutcomeReview | None:
        with closing(self._connect()) as conn:
            row = conn.execute(
                "SELECT * FROM outcome_reviews WHERE review_id = ?", (review_id,)
            ).fetchone()
        return self._row_to_review(row) if row is not None else None

    async def save(self, review: OutcomeReview) -> None:
        with closing(self._connect()) as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO outcome_reviews (
                    review_id, recommendation_id, review_window, scheduled_at,
                    completed_at, status, price_at_rec_vnd, price_at_review_vnd,
                    return_pct, benchmark_return_pct, excess_return_pct, notes
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    review.review_id,
                    str(review.recommendation_id),
                    review.review_window.value,
                    review.scheduled_at.isoformat(),
                    _isofmt(review.completed_at),
                    review.status.value,
                    review.price_at_rec_vnd,
                    review.price_at_review_vnd,
                    review.return_pct,
                    review.benchmark_return_pct,
                    review.excess_return_pct,
                    review.notes,
                ),
            )
            conn.commit()

    async def get_due(self, *, as_of: datetime) -> list[OutcomeReview]:
        with closing(self._connect()) as conn:
            rows = conn.execute(
                """
                SELECT * FROM outcome_reviews
                WHERE status = 'pending' AND scheduled_at <= ?
                ORDER BY scheduled_at ASC
                """,
                (as_of.isoformat(),),
            ).fetchall()
        return [self._row_to_review(row) for row in rows]

    async def get_completed_for_kol(self, kol_id: KolId) -> list[OutcomeReview]:
        """Return all non-PENDING reviews whose Recommendation belongs to kol_id.

        Uses a JOIN against recommendations(kol_id) — assumes both tables live
        in the same SQLite file (typical Phase 3 deployment).
        """
        with closing(self._connect()) as conn:
            rows = conn.execute(
                """
                SELECT outcome_reviews.* FROM outcome_reviews
                JOIN recommendations
                    ON recommendations.recommendation_id = outcome_reviews.recommendation_id
                WHERE recommendations.kol_id = ?
                  AND outcome_reviews.status != 'pending'
                ORDER BY outcome_reviews.scheduled_at ASC
                """,
                (str(kol_id),),
            ).fetchall()
        return [self._row_to_review(row) for row in rows]

    @staticmethod
    def _row_to_review(row: sqlite3.Row) -> OutcomeReview:
        completed_at_raw = row["completed_at"]
        return OutcomeReview(
            review_id=row["review_id"],
            recommendation_id=RecommendationId(row["recommendation_id"]),
            review_window=ReviewWindow(row["review_window"]),
            scheduled_at=datetime.fromisoformat(row["scheduled_at"]),
            status=OutcomeStatus(row["status"]),
            completed_at=datetime.fromisoformat(completed_at_raw)
            if completed_at_raw
            else None,
            price_at_rec_vnd=row["price_at_rec_vnd"],
            price_at_review_vnd=row["price_at_review_vnd"],
            return_pct=row["return_pct"],
            benchmark_return_pct=row["benchmark_return_pct"],
            excess_return_pct=row["excess_return_pct"],
            notes=row["notes"],
        )
