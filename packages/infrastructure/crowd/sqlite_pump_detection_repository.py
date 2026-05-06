"""SqlitePumpDetectionRepository — SQLite-backed PumpDetection aggregate persistence (BC-7).

D-032 § (a): SQLite extension. Schema mirrors spec § B.5 SQLite-adapted.
Phase 1 human-review-first: status field tracks 'pending_review' | 'reviewed_approved' | 'reviewed_rejected'.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + c + i).
"""

from __future__ import annotations

import json
import sqlite3
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import cast

from packages.domain.crowd.pump_detection import PumpDetection, ReviewStatus
from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects.detection_id import DetectionId
from packages.domain.crowd.value_objects.pump_action import PumpAction
from packages.domain.crowd.value_objects.pump_phase import PumpPhase

__all__ = ["SqlitePumpDetectionRepository"]

_CREATE_SQL = """
CREATE TABLE IF NOT EXISTS pump_detections (
    detection_id TEXT PRIMARY KEY NOT NULL,
    ticker TEXT NOT NULL,
    detected_at TEXT NOT NULL,               -- ISO8601 UTC
    phase TEXT NOT NULL,
    phase_confidence REAL NOT NULL,
    contributing_signals TEXT NOT NULL,       -- JSON array of signal dicts
    historical_similar_cases TEXT NOT NULL,   -- JSON array of strings
    recommended_action TEXT NOT NULL,
    evidence_summary TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending_review'
);
CREATE INDEX IF NOT EXISTS idx_pump_detections_ticker
    ON pump_detections (ticker, detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_pump_detections_status
    ON pump_detections (status);
"""


@dataclass
class SqlitePumpDetectionRepository:
    """SQLite-backed PumpDetection repository implementing PumpDetectionRepositoryPort.

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

    def save(self, detection: PumpDetection) -> None:
        """Persist or update a PumpDetection aggregate."""
        signals_json = json.dumps([self._signal_to_dict(s) for s in detection.contributing_signals])
        self._conn.execute(
            """
            INSERT INTO pump_detections (
                detection_id, ticker, detected_at, phase, phase_confidence,
                contributing_signals, historical_similar_cases, recommended_action,
                evidence_summary, status
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(detection_id) DO UPDATE SET
                status=excluded.status,
                evidence_summary=excluded.evidence_summary
            """,
            (
                str(detection.detection_id),
                detection.ticker,
                detection.detected_at.isoformat(),
                detection.phase.value,
                detection.phase_confidence,
                signals_json,
                json.dumps(list(detection.historical_similar_cases)),
                detection.recommended_action.value,
                detection.evidence_summary,
                detection.status,
            ),
        )
        self._conn.commit()

    def get_pending_review(self) -> list[PumpDetection]:
        """Return all PumpDetections with status='pending_review'."""
        rows = self._conn.execute(
            "SELECT * FROM pump_detections WHERE status='pending_review' ORDER BY detected_at DESC",
        ).fetchall()
        return [self._row_to_detection(r) for r in rows]

    def find_by_id(self, detection_id: DetectionId) -> PumpDetection | None:
        """Return PumpDetection by ID, or None if not found."""
        row = self._conn.execute(
            "SELECT * FROM pump_detections WHERE detection_id=?",
            (str(detection_id),),
        ).fetchone()
        return self._row_to_detection(row) if row else None

    def find_recent(self, ticker: str, since: datetime) -> list[PumpDetection]:
        """Return recent PumpDetections for a ticker after the given timestamp."""
        rows = self._conn.execute(
            "SELECT * FROM pump_detections WHERE ticker=? AND detected_at > ? ORDER BY detected_at DESC",
            (ticker, since.isoformat()),
        ).fetchall()
        return [self._row_to_detection(r) for r in rows]

    @staticmethod
    def _signal_to_dict(signal: object) -> dict[str, object]:
        """Serialize SignalContribution to dict."""
        return {
            "signal_name": getattr(signal, "signal_name", ""),
            "signal_value": getattr(signal, "signal_value", 0.0),
            "weight": getattr(signal, "weight", 0.0),
            "contribution": getattr(signal, "contribution", 0.0),
            "phase": getattr(getattr(signal, "phase", None), "value", "uncertain"),
        }

    @staticmethod
    def _dict_to_signal(d: dict[str, object]) -> SignalContribution:
        """Deserialize SignalContribution from dict."""
        return SignalContribution(
            signal_name=str(d.get("signal_name", "")),
            signal_value=float(str(d.get("signal_value", 0.0))),
            weight=float(str(d.get("weight", 0.0))),
            contribution=float(str(d.get("contribution", 0.0))),
            phase=PumpPhase(str(d.get("phase", "uncertain"))),
        )

    def _row_to_detection(self, row: sqlite3.Row) -> PumpDetection:
        """Deserialize a DB row to PumpDetection aggregate."""
        signals_raw: list[object] = json.loads(row["contributing_signals"])
        hist_raw: list[object] = json.loads(row["historical_similar_cases"])

        return PumpDetection(
            detection_id=DetectionId(row["detection_id"]),
            ticker=row["ticker"],
            detected_at=datetime.fromisoformat(row["detected_at"]).replace(tzinfo=UTC),
            phase=PumpPhase(row["phase"]),
            phase_confidence=float(row["phase_confidence"]),
            contributing_signals=tuple(
                self._dict_to_signal(s) for s in signals_raw  # type: ignore[arg-type]
            ),
            historical_similar_cases=tuple(str(h) for h in hist_raw),
            recommended_action=PumpAction(row["recommended_action"]),
            evidence_summary=row["evidence_summary"],
            status=cast(ReviewStatus, str(row["status"])),
        )
