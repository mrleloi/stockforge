"""ScalarMetricRecorder — sqlite-backed eval_runs table per spec 005 § B.6.

Phase 3 Track L deliverable per master-plan §S55. Persists ScalarMetricSnapshot
rows that Year 2 EvalRunner produces (mutation × period → metrics + composite).

Schema (subset of spec § B.6 eval_runs; full schema is Postgres for production,
sqlite acceptable for Phase 3 scaffolding + tests):

    CREATE TABLE eval_runs (
        run_id TEXT PRIMARY KEY,
        mutation_id TEXT NOT NULL,
        asset_id TEXT NOT NULL,
        period_start TEXT NOT NULL,    -- ISO date
        period_end TEXT NOT NULL,
        metrics_json TEXT NOT NULL,    -- JSON-encoded dict[str, float]
        composite REAL NOT NULL,
        duration_ms INTEGER NOT NULL,
        ran_at TEXT NOT NULL,          -- ISO timestamp
        extras_json TEXT NOT NULL DEFAULT '{}'
    );

NO LLM imports. composite is recorded verbatim from caller (deterministic input).
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import closing
from datetime import date, datetime
from pathlib import Path

from packages.domain.outer_loop.models.scalar_metric_snapshot import (
    ScalarMetricSnapshot,
)
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod

__all__ = ["ScalarMetricRecorder"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS eval_runs (
    run_id TEXT PRIMARY KEY,
    mutation_id TEXT NOT NULL,
    asset_id TEXT NOT NULL,
    period_start TEXT NOT NULL,
    period_end TEXT NOT NULL,
    metrics_json TEXT NOT NULL,
    composite REAL NOT NULL,
    duration_ms INTEGER NOT NULL,
    ran_at TEXT NOT NULL,
    extras_json TEXT NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS idx_eval_runs_asset_id ON eval_runs(asset_id);
CREATE INDEX IF NOT EXISTS idx_eval_runs_mutation_id ON eval_runs(mutation_id);
"""


class ScalarMetricRecorder:
    """Append-mostly recorder for ScalarMetricSnapshot. One sqlite file per recorder."""

    def __init__(self, db_path: Path | str):
        self._db_path = Path(db_path)
        self._db_path.parent.mkdir(parents=True, exist_ok=True)
        with closing(self._connect()) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    def _connect(self) -> sqlite3.Connection:
        return sqlite3.connect(self._db_path)

    def record(self, snapshot: ScalarMetricSnapshot) -> None:
        with closing(self._connect()) as conn:
            conn.execute(
                """
                INSERT INTO eval_runs (
                    run_id, mutation_id, asset_id, period_start, period_end,
                    metrics_json, composite, duration_ms, ran_at, extras_json
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    snapshot.run_id,
                    snapshot.mutation_id,
                    snapshot.asset_id,
                    snapshot.period.start.isoformat(),
                    snapshot.period.end.isoformat(),
                    json.dumps(snapshot.metrics),
                    snapshot.composite,
                    snapshot.duration_ms,
                    snapshot.ran_at.isoformat(),
                    json.dumps(snapshot.extras),
                ),
            )
            conn.commit()

    def get_by_run_id(self, run_id: str) -> ScalarMetricSnapshot | None:
        with closing(self._connect()) as conn:
            row = conn.execute(
                "SELECT run_id, mutation_id, asset_id, period_start, period_end, "
                "metrics_json, composite, duration_ms, ran_at, extras_json "
                "FROM eval_runs WHERE run_id = ?",
                (run_id,),
            ).fetchone()
        return self._row_to_snapshot(row) if row else None

    def query_by_asset(self, asset_id: str) -> list[ScalarMetricSnapshot]:
        with closing(self._connect()) as conn:
            rows = conn.execute(
                "SELECT run_id, mutation_id, asset_id, period_start, period_end, "
                "metrics_json, composite, duration_ms, ran_at, extras_json "
                "FROM eval_runs WHERE asset_id = ? ORDER BY ran_at ASC",
                (asset_id,),
            ).fetchall()
        return [self._row_to_snapshot(r) for r in rows]

    def query_by_mutation(self, mutation_id: str) -> list[ScalarMetricSnapshot]:
        with closing(self._connect()) as conn:
            rows = conn.execute(
                "SELECT run_id, mutation_id, asset_id, period_start, period_end, "
                "metrics_json, composite, duration_ms, ran_at, extras_json "
                "FROM eval_runs WHERE mutation_id = ? ORDER BY ran_at ASC",
                (mutation_id,),
            ).fetchall()
        return [self._row_to_snapshot(r) for r in rows]

    def count(self) -> int:
        with closing(self._connect()) as conn:
            (n,) = conn.execute("SELECT COUNT(*) FROM eval_runs").fetchone()
        return int(n)

    @staticmethod
    def _row_to_snapshot(row: tuple) -> ScalarMetricSnapshot:
        (
            run_id,
            mutation_id,
            asset_id,
            period_start,
            period_end,
            metrics_json,
            composite,
            duration_ms,
            ran_at,
            extras_json,
        ) = row
        return ScalarMetricSnapshot(
            run_id=run_id,
            mutation_id=mutation_id,
            asset_id=asset_id,
            period=EvalPeriod(
                start=date.fromisoformat(period_start),
                end=date.fromisoformat(period_end),
            ),
            metrics=json.loads(metrics_json),
            composite=float(composite),
            duration_ms=int(duration_ms),
            ran_at=datetime.fromisoformat(ran_at),
            extras=json.loads(extras_json) if extras_json else {},
        )
