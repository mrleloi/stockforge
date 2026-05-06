"""SqliteRecommendationRepository — SQLite-backed Recommendation persistence.

Schema follows spec § B.6 adapted for SQLite (JSONB → TEXT json; TIMESTAMPTZ →
TEXT ISO8601). `find_recent_for_kol_ticker` powers UC-1 flip detection;
`find_recent` powers confluence + dashboards. Both apply the BR-6 confidence
floor (>=0.7) at the boundary so callers never have to re-filter.
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import closing
from datetime import UTC, datetime, timedelta
from pathlib import Path

from packages.domain.influence.models.recommendation import Recommendation
from packages.domain.influence.value_objects.channel_id import ChannelId
from packages.domain.influence.value_objects.intent import Intent
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.recommendation_id import RecommendationId
from packages.domain.influence.value_objects.timeframe import Timeframe

__all__ = ["SqliteRecommendationRepository"]


_BR6_CONFIDENCE_FLOOR = 0.7


_SCHEMA = """
CREATE TABLE IF NOT EXISTS recommendations (
    recommendation_id          TEXT PRIMARY KEY,
    kol_id                     TEXT NOT NULL,
    channel_id                 TEXT NOT NULL,
    ticker                     TEXT NOT NULL,
    intent                     TEXT NOT NULL,
    conditions_json            TEXT NOT NULL DEFAULT '[]',
    timeframe                  TEXT NOT NULL,
    source_url                 TEXT NOT NULL,
    timestamp_in_source        TEXT NOT NULL DEFAULT '',
    transcript_excerpt         TEXT NOT NULL CHECK (LENGTH(transcript_excerpt) <= 500),
    extraction_confidence      REAL NOT NULL CHECK (extraction_confidence BETWEEN 0 AND 1),
    extractor_model            TEXT NOT NULL,
    extractor_version          TEXT NOT NULL,
    published_at               TEXT NOT NULL,
    extracted_at               TEXT NOT NULL,
    requires_manual_review     INTEGER NOT NULL DEFAULT 0,
    flip_from_recommendation_id TEXT
);
CREATE INDEX IF NOT EXISTS idx_recs_ticker_published
    ON recommendations(ticker, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_recs_kol_published
    ON recommendations(kol_id, published_at DESC);
"""


class SqliteRecommendationRepository:
    """Concrete SQLite RecommendationRepositoryPort."""

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

    async def get(
        self, recommendation_id: RecommendationId
    ) -> Recommendation | None:
        with closing(self._connect()) as conn:
            row = conn.execute(
                "SELECT * FROM recommendations WHERE recommendation_id = ?",
                (str(recommendation_id),),
            ).fetchone()
        return self._row_to_rec(row) if row is not None else None

    async def save(self, recommendation: Recommendation) -> None:
        with closing(self._connect()) as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO recommendations (
                    recommendation_id, kol_id, channel_id, ticker, intent,
                    conditions_json, timeframe, source_url, timestamp_in_source,
                    transcript_excerpt, extraction_confidence,
                    extractor_model, extractor_version,
                    published_at, extracted_at, requires_manual_review,
                    flip_from_recommendation_id
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    str(recommendation.recommendation_id),
                    str(recommendation.kol_id),
                    str(recommendation.channel_id),
                    recommendation.ticker,
                    recommendation.intent.value,
                    json.dumps(list(recommendation.conditions)),
                    recommendation.timeframe.value,
                    recommendation.source_url,
                    recommendation.timestamp_in_source,
                    recommendation.transcript_excerpt,
                    recommendation.extraction_confidence,
                    recommendation.extractor_model,
                    recommendation.extractor_version,
                    recommendation.published_at.isoformat(),
                    recommendation.extracted_at.isoformat(),
                    1 if recommendation.requires_manual_review else 0,
                    str(recommendation.flip_from_recommendation_id)
                    if recommendation.flip_from_recommendation_id is not None
                    else None,
                ),
            )
            conn.commit()

    async def find_recent_for_kol_ticker(
        self,
        *,
        kol_id: KolId,
        ticker: str,
        lookback_days: int,
    ) -> Recommendation | None:
        cutoff = (datetime.now(UTC) - timedelta(days=lookback_days)).isoformat()
        with closing(self._connect()) as conn:
            row = conn.execute(
                """
                SELECT * FROM recommendations
                WHERE kol_id = ? AND ticker = ? AND published_at >= ?
                ORDER BY published_at DESC LIMIT 1
                """,
                (str(kol_id), ticker, cutoff),
            ).fetchone()
        return self._row_to_rec(row) if row is not None else None

    async def find_recent(
        self,
        *,
        since: datetime,
        min_extraction_confidence: float = _BR6_CONFIDENCE_FLOOR,
    ) -> list[Recommendation]:
        with closing(self._connect()) as conn:
            rows = conn.execute(
                """
                SELECT * FROM recommendations
                WHERE published_at >= ? AND extraction_confidence >= ?
                ORDER BY published_at DESC
                """,
                (since.isoformat(), min_extraction_confidence),
            ).fetchall()
        return [self._row_to_rec(row) for row in rows]

    @staticmethod
    def _row_to_rec(row: sqlite3.Row) -> Recommendation:
        flip_value = row["flip_from_recommendation_id"]
        flip = RecommendationId(flip_value) if flip_value else None
        return Recommendation(
            recommendation_id=RecommendationId(row["recommendation_id"]),
            kol_id=KolId(row["kol_id"]),
            channel_id=ChannelId(row["channel_id"]),
            ticker=row["ticker"],
            intent=Intent(row["intent"]),
            timeframe=Timeframe(row["timeframe"]),
            source_url=row["source_url"],
            transcript_excerpt=row["transcript_excerpt"],
            extraction_confidence=float(row["extraction_confidence"]),
            extractor_model=row["extractor_model"],
            extractor_version=row["extractor_version"],
            extracted_at=datetime.fromisoformat(row["extracted_at"]),
            published_at=datetime.fromisoformat(row["published_at"]),
            timestamp_in_source=row["timestamp_in_source"] or "",
            conditions=list(json.loads(row["conditions_json"] or "[]")),
            requires_manual_review=bool(row["requires_manual_review"]),
            flip_from_recommendation_id=flip,
        )
