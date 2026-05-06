"""SqliteLabeledPumpRepository — SQLite-backed LabeledPump persistence (BC-7 BR-5 gate).

D-032 § (i): holdout set for BR-5 backtest gate.
get_holdout_set(test_split=0.3) returns last floor(N * test_split) records.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5 + § B.7.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § i).
"""

from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import cast

from packages.domain.crowd.labeled_pump import LabeledBy, LabeledPump

__all__ = ["SqliteLabeledPumpRepository"]

_CREATE_SQL = """
CREATE TABLE IF NOT EXISTS labeled_pumps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticker TEXT NOT NULL,
    period_start TEXT NOT NULL,          -- ISO8601 UTC
    period_end TEXT NOT NULL,            -- ISO8601 UTC
    phases TEXT NOT NULL,                -- JSON array of phase strings
    features_at_detection TEXT NOT NULL, -- JSON object of feature key->value
    subsequent_outcome TEXT,             -- nullable
    labeled_by TEXT NOT NULL             -- 'user' | 'agent_with_review'
);
"""


@dataclass
class SqliteLabeledPumpRepository:
    """SQLite-backed LabeledPump repository implementing LabeledPumpRepositoryPort.

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

    def save(self, labeled_pump: LabeledPump) -> None:
        """Persist a LabeledPump aggregate (insert)."""
        self._conn.execute(
            """
            INSERT INTO labeled_pumps (
                ticker, period_start, period_end, phases,
                features_at_detection, subsequent_outcome, labeled_by
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                labeled_pump.ticker,
                labeled_pump.period_start.isoformat(),
                labeled_pump.period_end.isoformat(),
                json.dumps(list(labeled_pump.phases)),
                json.dumps(labeled_pump.features_at_detection),
                labeled_pump.subsequent_outcome,
                labeled_pump.labeled_by,
            ),
        )
        self._conn.commit()

    def get_all(self) -> list[LabeledPump]:
        """Return all LabeledPump records ordered by insertion (ROWID ASC)."""
        rows = self._conn.execute(
            "SELECT * FROM labeled_pumps ORDER BY id ASC"
        ).fetchall()
        return [self._row_to_labeled_pump(r) for r in rows]

    def get_holdout_set(self, test_split: float = 0.3) -> list[LabeledPump]:
        """Return last floor(total * test_split) records as holdout set.

        I-S1: split computed in Python from record count (no LLM math).
        BR-5: used for backtest gate validation.
        """
        all_pumps = self.get_all()
        holdout_count = max(1, int(len(all_pumps) * test_split))
        return all_pumps[-holdout_count:]

    @staticmethod
    def _row_to_labeled_pump(row: sqlite3.Row) -> LabeledPump:
        """Deserialize a DB row to LabeledPump aggregate."""
        phases: list[object] = json.loads(row["phases"])
        features: dict[str, object] = json.loads(row["features_at_detection"])

        return LabeledPump(
            ticker=row["ticker"],
            period_start=datetime.fromisoformat(row["period_start"]).replace(tzinfo=UTC),
            period_end=datetime.fromisoformat(row["period_end"]).replace(tzinfo=UTC),
            phases=tuple(str(p) for p in phases),
            features_at_detection=features,
            subsequent_outcome=row["subsequent_outcome"],
            labeled_by=cast(LabeledBy, str(row["labeled_by"])),
        )
