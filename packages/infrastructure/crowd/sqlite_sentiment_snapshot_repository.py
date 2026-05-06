"""SqliteSentimentSnapshotRepository — SQLite-backed SentimentSnapshot persistence.

D-032 § (a): SQLite extension. Schema mirrors spec § B.5 SQLite-adapted:
  - TIMESTAMPTZ → TEXT ISO8601
  - JSONB → TEXT json-serialized
  - TEXT[] → TEXT json-array

Composite index: (ticker, captured_at DESC) for hypertable-emulation.
Phase 4: migration adds create_hypertable() call; TEXT → TIMESTAMPTZ columns.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: D-032 § (a) storage substrate.
"""

from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path

from packages.domain.crowd.sentiment_snapshot import SentimentSnapshot
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.snapshot_id import SnapshotId
from packages.domain.crowd.value_objects.window import Window

__all__ = ["SqliteSentimentSnapshotRepository"]

_CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS sentiment_snapshots (
    snapshot_id TEXT PRIMARY KEY NOT NULL,
    ticker TEXT NOT NULL,
    captured_at TEXT NOT NULL,               -- ISO8601 UTC
    window TEXT NOT NULL,
    mention_count INTEGER NOT NULL,
    sentiment_distribution TEXT NOT NULL,    -- JSON object: {sentiment_level: count}
    posting_velocity REAL NOT NULL,
    unique_posters INTEGER NOT NULL,
    coordinated_posting_score REAL NOT NULL,
    sources TEXT NOT NULL,                   -- JSON object: {platform: count}
    top_terms TEXT NOT NULL,                 -- JSON array of strings
    source_posts_sample TEXT NOT NULL        -- JSON array of post_ids (max 20)
);
CREATE INDEX IF NOT EXISTS idx_snapshots_ticker_time
    ON sentiment_snapshots (ticker, captured_at DESC);
"""


@dataclass
class SqliteSentimentSnapshotRepository:
    """SQLite-backed SentimentSnapshot repository.

    Args:
        db_path: Path to SQLite database file. ":memory:" for in-memory (tests).
    """

    db_path: str | Path = ":memory:"
    _conn: sqlite3.Connection = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._conn = sqlite3.connect(str(self.db_path), check_same_thread=False)
        self._conn.executescript(_CREATE_TABLE_SQL)
        self._conn.commit()

    def save(self, snapshot: SentimentSnapshot) -> None:
        """Persist snapshot. Upserts on snapshot_id conflict."""
        row = self._to_row(snapshot)
        self._conn.execute(
            """
            INSERT OR REPLACE INTO sentiment_snapshots
            (snapshot_id, ticker, captured_at, window, mention_count,
             sentiment_distribution, posting_velocity, unique_posters,
             coordinated_posting_score, sources, top_terms, source_posts_sample)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            row,
        )
        self._conn.commit()

    def get_recent(self, ticker: str, window: Window) -> list[SentimentSnapshot]:
        """Return snapshots for `ticker` within window.duration, newest first."""
        since = datetime.now(UTC) - window.duration
        cursor = self._conn.execute(
            """
            SELECT * FROM sentiment_snapshots
            WHERE ticker = ? AND captured_at >= ?
            ORDER BY captured_at DESC
            """,
            (ticker, since.isoformat()),
        )
        return [self._from_row(row) for row in cursor.fetchall()]

    def find_by_id(self, snapshot_id: SnapshotId) -> SentimentSnapshot | None:
        """Return snapshot by ID, or None."""
        cursor = self._conn.execute(
            "SELECT * FROM sentiment_snapshots WHERE snapshot_id = ?",
            (snapshot_id,),
        )
        row = cursor.fetchone()
        return self._from_row(row) if row else None

    @staticmethod
    def _to_row(s: SentimentSnapshot) -> tuple[object, ...]:
        """Serialize SentimentSnapshot to SQLite row tuple."""
        captured_at = (
            s.captured_at.isoformat()
            if s.captured_at.tzinfo is not None
            else s.captured_at.replace(tzinfo=UTC).isoformat()
        )
        return (
            s.snapshot_id,
            s.ticker,
            captured_at,
            s.window.value,
            s.mention_count,
            json.dumps({k.value: v for k, v in s.sentiment_distribution.items()}),
            s.posting_velocity,
            s.unique_posters,
            s.coordinated_posting_score,
            json.dumps(s.sources),
            json.dumps(list(s.top_terms)),
            json.dumps(list(s.source_posts_sample)),
        )

    @staticmethod
    def _from_row(row: tuple[object, ...]) -> SentimentSnapshot:
        """Deserialize SQLite row to SentimentSnapshot."""
        (
            snapshot_id, ticker, captured_at_str, window_val, mention_count,
            sentiment_dist_json, posting_velocity, unique_posters,
            coord_score, sources_json, top_terms_json, sample_json,
        ) = row

        captured_at = datetime.fromisoformat(str(captured_at_str))
        if captured_at.tzinfo is None:
            captured_at = captured_at.replace(tzinfo=UTC)

        dist_raw: dict[str, int] = json.loads(str(sentiment_dist_json))
        dist = {Sentiment(k): v for k, v in dist_raw.items()}
        sources: dict[str, int] = json.loads(str(sources_json))
        top_terms: list[str] = json.loads(str(top_terms_json))
        sample: list[str] = json.loads(str(sample_json))

        return SentimentSnapshot(
            snapshot_id=str(snapshot_id),
            ticker=str(ticker),
            captured_at=captured_at,
            window=Window(str(window_val)),
            mention_count=int(str(mention_count)),
            sentiment_distribution=dist,
            posting_velocity=float(str(posting_velocity)),
            unique_posters=int(str(unique_posters)),
            coordinated_posting_score=float(str(coord_score)),
            sources=sources,
            top_terms=tuple(top_terms),
            source_posts_sample=tuple(sample),
        )
