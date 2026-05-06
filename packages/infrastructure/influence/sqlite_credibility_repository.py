"""SqliteCredibilityRepository — SQLite-backed CredibilityScore persistence.

`sector_scores` + `timeframe_scores` are stored as TEXT json blobs (Postgres
migration would change them to JSONB; the Python code remains identical).
"""

from __future__ import annotations

import json
import sqlite3
from contextlib import closing
from datetime import datetime
from pathlib import Path

from packages.domain.influence.models.credibility_score import CredibilityScore
from packages.domain.influence.value_objects.kol_id import KolId
from packages.domain.influence.value_objects.sector_score import SectorScore
from packages.domain.influence.value_objects.timeframe import Timeframe
from packages.domain.influence.value_objects.timeframe_score import TimeframeScore

__all__ = ["SqliteCredibilityRepository"]


_SCHEMA = """
CREATE TABLE IF NOT EXISTS credibility_scores (
    kol_id              TEXT PRIMARY KEY,
    n_evaluated         INTEGER NOT NULL,
    n_hits              INTEGER NOT NULL,
    n_misses            INTEGER NOT NULL,
    n_partial           INTEGER NOT NULL,
    posterior_alpha     REAL NOT NULL,
    posterior_beta      REAL NOT NULL,
    bayesian_mean       REAL NOT NULL,
    bayesian_ci_low     REAL NOT NULL,
    bayesian_ci_high    REAL NOT NULL,
    sector_scores_json   TEXT NOT NULL DEFAULT '{}',
    timeframe_scores_json TEXT NOT NULL DEFAULT '{}',
    last_updated_at     TEXT NOT NULL
);
"""


class SqliteCredibilityRepository:
    """Concrete SQLite CredibilityRepositoryPort."""

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

    async def get(self, kol_id: KolId) -> CredibilityScore | None:
        with closing(self._connect()) as conn:
            row = conn.execute(
                "SELECT * FROM credibility_scores WHERE kol_id = ?", (str(kol_id),)
            ).fetchone()
        return self._row_to_score(row) if row is not None else None

    async def save(self, score: CredibilityScore) -> None:
        with closing(self._connect()) as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO credibility_scores (
                    kol_id, n_evaluated, n_hits, n_misses, n_partial,
                    posterior_alpha, posterior_beta,
                    bayesian_mean, bayesian_ci_low, bayesian_ci_high,
                    sector_scores_json, timeframe_scores_json, last_updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    str(score.kol_id),
                    score.n_evaluated,
                    score.n_hits,
                    score.n_misses,
                    score.n_partial,
                    score.posterior_alpha,
                    score.posterior_beta,
                    score.bayesian_mean,
                    score.bayesian_ci_low,
                    score.bayesian_ci_high,
                    json.dumps(
                        {
                            sector: {
                                "n_evaluated": s.n_evaluated,
                                "hit_rate_mean": s.hit_rate_mean,
                            }
                            for sector, s in score.sector_scores.items()
                        }
                    ),
                    json.dumps(
                        {
                            tf.value: {
                                "n_evaluated": ts.n_evaluated,
                                "hit_rate_mean": ts.hit_rate_mean,
                            }
                            for tf, ts in score.timeframe_scores.items()
                        }
                    ),
                    score.last_updated_at.isoformat(),
                ),
            )
            conn.commit()

    @staticmethod
    def _row_to_score(row: sqlite3.Row) -> CredibilityScore:
        sector_scores: dict[str, SectorScore] = {
            sector: SectorScore(
                sector=sector,
                n_evaluated=int(payload["n_evaluated"]),
                hit_rate_mean=float(payload["hit_rate_mean"]),
            )
            for sector, payload in json.loads(row["sector_scores_json"] or "{}").items()
        }
        timeframe_scores: dict[Timeframe, TimeframeScore] = {
            Timeframe(tf): TimeframeScore(
                timeframe=Timeframe(tf),
                n_evaluated=int(payload["n_evaluated"]),
                hit_rate_mean=float(payload["hit_rate_mean"]),
            )
            for tf, payload in json.loads(
                row["timeframe_scores_json"] or "{}"
            ).items()
        }
        return CredibilityScore(
            kol_id=KolId(row["kol_id"]),
            n_evaluated=int(row["n_evaluated"]),
            n_hits=int(row["n_hits"]),
            n_misses=int(row["n_misses"]),
            n_partial=int(row["n_partial"]),
            posterior_alpha=float(row["posterior_alpha"]),
            posterior_beta=float(row["posterior_beta"]),
            bayesian_mean=float(row["bayesian_mean"]),
            bayesian_ci_low=float(row["bayesian_ci_low"]),
            bayesian_ci_high=float(row["bayesian_ci_high"]),
            sector_scores=sector_scores,
            timeframe_scores=timeframe_scores,
            last_updated_at=datetime.fromisoformat(row["last_updated_at"]),
        )
