"""SqliteNarrativeRepository — SQLite-backed Narrative aggregate persistence (BC-7).

D-032 § (a): SQLite extension. Phase history serialized as JSON array of dicts.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + c).
"""

from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path

from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.phase_transition import PhaseTransition
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = ["SqliteNarrativeRepository"]

_CREATE_SQL = """
CREATE TABLE IF NOT EXISTS narratives (
    narrative_id TEXT PRIMARY KEY NOT NULL,
    ticker TEXT NOT NULL,
    thematic_keywords TEXT NOT NULL,      -- JSON array of strings
    current_phase TEXT NOT NULL,
    first_detected_at TEXT NOT NULL,      -- ISO8601 UTC
    phase_history TEXT NOT NULL,          -- JSON array of phase transition dicts
    counter_narrative_ids TEXT NOT NULL,  -- JSON array of strings
    related_narrative_ids TEXT NOT NULL,  -- JSON array of strings
    affected_tickers TEXT NOT NULL        -- JSON array of strings
);
CREATE INDEX IF NOT EXISTS idx_narratives_ticker
    ON narratives (ticker, current_phase);
"""


@dataclass
class SqliteNarrativeRepository:
    """SQLite-backed Narrative repository implementing NarrativeRepositoryPort.

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

    def save(self, narrative: Narrative) -> None:
        """Persist or update a Narrative aggregate (upsert by narrative_id)."""
        phase_history_json = json.dumps([
            {
                "from_phase": t.from_phase.value,
                "to_phase": t.to_phase.value,
                "transitioned_at": t.transitioned_at.isoformat(),
                "trigger_signals": list(t.trigger_signals),
            }
            for t in narrative.phase_history
        ])
        self._conn.execute(
            """
            INSERT INTO narratives (
                narrative_id, ticker, thematic_keywords, current_phase,
                first_detected_at, phase_history, counter_narrative_ids,
                related_narrative_ids, affected_tickers
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(narrative_id) DO UPDATE SET
                current_phase=excluded.current_phase,
                phase_history=excluded.phase_history,
                counter_narrative_ids=excluded.counter_narrative_ids,
                related_narrative_ids=excluded.related_narrative_ids,
                affected_tickers=excluded.affected_tickers
            """,
            (
                str(narrative.narrative_id),
                narrative.ticker,
                json.dumps(list(narrative.thematic_keywords)),
                narrative.current_phase.value,
                narrative.first_detected_at.isoformat(),
                phase_history_json,
                json.dumps(list(narrative.counter_narrative_ids)),
                json.dumps(list(narrative.related_narrative_ids)),
                json.dumps(list(narrative.affected_tickers)),
            ),
        )
        self._conn.commit()

    def get_active(self, ticker: str) -> list[Narrative]:
        """Return active narratives for a ticker (not in DEAD phase)."""
        rows = self._conn.execute(
            "SELECT * FROM narratives WHERE ticker=? AND current_phase != 'dead'",
            (ticker,),
        ).fetchall()
        return [self._row_to_narrative(r) for r in rows]

    def find_by_id(self, narrative_id: NarrativeId) -> Narrative | None:
        """Return Narrative by ID, or None if not found."""
        row = self._conn.execute(
            "SELECT * FROM narratives WHERE narrative_id=?",
            (str(narrative_id),),
        ).fetchone()
        return self._row_to_narrative(row) if row else None

    def get_bullish_points_for(self, ticker: str) -> list[str]:
        """Return aggregated thematic keywords from active (non-DEAD) narratives."""
        rows = self._conn.execute(
            "SELECT thematic_keywords FROM narratives WHERE ticker=? AND current_phase != 'dead'",
            (ticker,),
        ).fetchall()
        keywords: list[str] = []
        for row in rows:
            kws: list[object] = json.loads(row["thematic_keywords"])
            keywords.extend(str(k) for k in kws)
        return keywords

    def get_by_phase(self, phase: NarrativePhase) -> list[Narrative]:
        """Return all narratives currently in the given phase."""
        rows = self._conn.execute(
            "SELECT * FROM narratives WHERE current_phase=?",
            (phase.value,),
        ).fetchall()
        return [self._row_to_narrative(r) for r in rows]

    def _row_to_narrative(self, row: sqlite3.Row) -> Narrative:
        """Deserialize a DB row to Narrative aggregate."""
        keywords: list[object] = json.loads(row["thematic_keywords"])
        phase_history_raw: list[object] = json.loads(row["phase_history"])
        counter_ids: list[object] = json.loads(row["counter_narrative_ids"])
        related_ids: list[object] = json.loads(row["related_narrative_ids"])
        affected: list[object] = json.loads(row["affected_tickers"])

        phase_history = tuple(
            PhaseTransition(
                from_phase=NarrativePhase(d["from_phase"]),  # type: ignore[index]
                to_phase=NarrativePhase(d["to_phase"]),  # type: ignore[index]
                transitioned_at=datetime.fromisoformat(d["transitioned_at"]).replace(tzinfo=UTC),  # type: ignore[index]
                trigger_signals=tuple(d["trigger_signals"]),  # type: ignore[index]
            )
            for d in phase_history_raw
        )

        return Narrative(
            narrative_id=NarrativeId(row["narrative_id"]),
            ticker=row["ticker"],
            thematic_keywords=tuple(str(k) for k in keywords),
            current_phase=NarrativePhase(row["current_phase"]),
            first_detected_at=datetime.fromisoformat(row["first_detected_at"]).replace(tzinfo=UTC),
            phase_history=phase_history,
            counter_narrative_ids=tuple(str(c) for c in counter_ids),
            related_narrative_ids=tuple(str(r) for r in related_ids),
            affected_tickers=tuple(str(a) for a in affected),
        )
