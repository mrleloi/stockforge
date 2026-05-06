"""SqliteCounterNarrativeRepository — SQLite-backed CounterNarrative persistence (BC-7).

D-032 § (a): SQLite extension. No single surrogate PK — uses rowid AUTOINCREMENT.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + g).
"""

from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path

from packages.domain.crowd.counter_narrative import CounterNarrative

__all__ = ["SqliteCounterNarrativeRepository"]

_CREATE_SQL = """
CREATE TABLE IF NOT EXISTS counter_narratives (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticker TEXT NOT NULL,
    generated_at TEXT NOT NULL,             -- ISO8601 UTC
    trigger TEXT NOT NULL,
    bear_points TEXT NOT NULL,              -- JSON array of strings
    historical_analogs TEXT NOT NULL,       -- JSON array of analog dicts
    failing_analog_details TEXT NOT NULL,   -- JSON array of analog dicts
    bullish_consensus_summary TEXT NOT NULL -- JSON array of strings
);
CREATE INDEX IF NOT EXISTS idx_counter_narratives_ticker
    ON counter_narratives (ticker, generated_at DESC);
"""


@dataclass
class SqliteCounterNarrativeRepository:
    """SQLite-backed CounterNarrative repository implementing CounterNarrativeRepositoryPort.

    Args:
        db_path: Path to SQLite database file. ":memory:" for in-memory (tests).
    """

    db_path: str | Path = ":memory:"
    _conn: sqlite3.Connection = field(init=False, repr=False)

    def __post_init__(self) -> None:
        self._conn = sqlite3.connect(str(self.db_path), check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self._conn.executescript(_CREATE_SQL)
        self._conn.commit()

    def save(self, counter_narrative: CounterNarrative) -> None:
        """Persist a CounterNarrative aggregate (insert only; immutable)."""

        def _analog_to_dict(a: object) -> dict[str, object]:
            return {
                "ticker": getattr(a, "ticker", ""),
                "period_start": getattr(a, "period_start", ""),
                "period_end": getattr(a, "period_end", ""),
                "setup_description": getattr(a, "setup_description", ""),
                "similarity_score": getattr(a, "similarity_score", 0.0),
                "subsequent_return_12m": getattr(a, "subsequent_return_12m", 0.0),
                "outcome_description": getattr(a, "outcome_description", ""),
            }

        self._conn.execute(
            """
            INSERT INTO counter_narratives (
                ticker, generated_at, trigger, bear_points,
                historical_analogs, failing_analog_details, bullish_consensus_summary
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                counter_narrative.ticker,
                counter_narrative.generated_at.isoformat(),
                counter_narrative.trigger,
                json.dumps(list(counter_narrative.bear_points)),
                json.dumps([_analog_to_dict(a) for a in counter_narrative.historical_analogs]),
                json.dumps([_analog_to_dict(a) for a in counter_narrative.failing_analog_details]),
                json.dumps(list(counter_narrative.bullish_consensus_summary)),
            ),
        )
        self._conn.commit()

    def find_recent_for_ticker(self, ticker: str, limit: int = 5) -> list[CounterNarrative]:
        """Return most recent CounterNarratives for a ticker."""
        rows = self._conn.execute(
            "SELECT * FROM counter_narratives WHERE ticker=? ORDER BY generated_at DESC LIMIT ?",
            (ticker, limit),
        ).fetchall()
        return [self._row_to_counter_narrative(r) for r in rows]

    @staticmethod
    def _row_to_counter_narrative(row: sqlite3.Row) -> CounterNarrative:
        """Deserialize a DB row to CounterNarrative aggregate."""
        bear_points: list[object] = json.loads(row["bear_points"])
        hist_raw: list[object] = json.loads(row["historical_analogs"])
        failing_raw: list[object] = json.loads(row["failing_analog_details"])
        bullish_raw: list[object] = json.loads(row["bullish_consensus_summary"])

        return CounterNarrative(
            ticker=row["ticker"],
            generated_at=datetime.fromisoformat(row["generated_at"]).replace(tzinfo=UTC),
            trigger=row["trigger"],
            bear_points=tuple(str(bp) for bp in bear_points),
            historical_analogs=tuple(hist_raw),
            failing_analog_details=tuple(failing_raw),
            bullish_consensus_summary=tuple(str(b) for b in bullish_raw),
        )
