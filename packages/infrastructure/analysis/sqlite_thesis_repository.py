"""SqliteThesisRepository — SQLite implementation of ThesisRepository Protocol.

Table schema per spec § A.6.2:
  theses(thesis_id PK, ticker, as_of, created_at, status, recommendation,
         confidence_level, payload_json, prompt_hash, model_id, cost_usd)

payload_json stores the full Thesis as a JSON dict via dataclass-asdict.
All nested enums are serialized as their string values. Decimal is stored as str.

Migration path to Postgres (Phase 3): payload_json blob column is portable.
Only the schema DDL changes; the Python code remains the same.

Uses `INSERT OR REPLACE` (upsert by thesis_id PK) so idempotent re-runs converge.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § A.6.2.
"""

from __future__ import annotations

import dataclasses
import json
import logging
import sqlite3
from contextlib import closing
from dataclasses import dataclass
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import (
    Confluence,
    Disagreement,
    Synthesis,
)
from packages.domain.analysis.models.thesis import Thesis, ThesisStatus
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)

__all__ = ["SqliteThesisRepository"]

log = logging.getLogger(__name__)

_SCHEMA = """
CREATE TABLE IF NOT EXISTS theses (
    thesis_id        TEXT PRIMARY KEY,
    ticker           TEXT NOT NULL,
    as_of            TEXT NOT NULL,
    created_at       TEXT NOT NULL,
    status           TEXT NOT NULL,
    recommendation   TEXT,
    confidence_level TEXT,
    payload_json     TEXT NOT NULL,
    prompt_hash      TEXT NOT NULL DEFAULT '',
    model_id         TEXT NOT NULL DEFAULT '',
    cost_usd         TEXT NOT NULL DEFAULT '0'
);
CREATE INDEX IF NOT EXISTS idx_theses_ticker ON theses(ticker);
CREATE INDEX IF NOT EXISTS idx_theses_as_of ON theses(ticker, as_of);
"""


def _default(obj: object) -> object:
    """JSON serializer for non-standard types."""
    if isinstance(obj, Decimal):
        return str(obj)
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    if hasattr(obj, "symbol"):  # Ticker
        return obj.symbol
    if hasattr(obj, "value"):  # StrEnum
        return obj.value
    if dataclasses.is_dataclass(obj) and not isinstance(obj, type):
        return dataclasses.asdict(obj)
    raise TypeError(f"Cannot serialize {type(obj)}: {obj!r}")


def _thesis_to_dict(thesis: Thesis) -> dict[str, object]:
    """Convert a Thesis to a JSON-serializable dict."""
    result: dict[str, object] = dataclasses.asdict(thesis)
    return result


def _dict_to_thesis(row: dict[str, object]) -> Thesis:
    """Reconstruct a Thesis from a payload_json dict (deserialization)."""
    payload = json.loads(str(row["payload_json"]))
    if not isinstance(payload, dict):
        raise ValueError("payload_json is not a dict")
    return _rebuild_thesis(payload)


def _rebuild_grounded_point(d: dict[str, object]) -> GroundedPoint:
    as_of_raw = d["as_of"]
    as_of_val = date.fromisoformat(str(as_of_raw)) if isinstance(as_of_raw, str) else date.today()
    cat_raw = d.get("category")
    kp_raw = d.get("key_phrases", [])
    kp = tuple(str(k) for k in kp_raw) if isinstance(kp_raw, list) else ()
    return GroundedPoint(
        text=str(d["text"]),
        source_url=str(d["source_url"]),
        source_excerpt=str(d["source_excerpt"]),
        as_of=as_of_val,
        conviction=Conviction(str(d["conviction"])),
        category=str(cat_raw) if cat_raw is not None else None,
        key_phrases=kp,
    )


def _rebuild_perspective(d: dict[str, object]) -> PerspectiveAnalysis:
    kp_raw = d.get("key_points", [])
    key_points = tuple(
        _rebuild_grounded_point(p)
        for p in (kp_raw if isinstance(kp_raw, list) else [])
        if isinstance(p, dict)
    )
    return PerspectiveAnalysis(
        role=PerspectiveRole(str(d["role"])),
        key_points=key_points,
        overall_conviction=Conviction(str(d["overall_conviction"])),
        cost_usd=Decimal(str(d["cost_usd"])),
        model_id=str(d["model_id"]),
        prompt_hash=str(d["prompt_hash"]),
        deferred=bool(d.get("deferred", False)),
    )


def _rebuild_synthesis(d: dict[str, object] | None) -> Synthesis | None:
    if d is None:
        return None
    tom_raw = d.get("trade_off_matrix", {})
    tom: dict[str, object] = tom_raw if isinstance(tom_raw, dict) else {}
    scores_raw = tom.get("scores", {})
    evidence_raw = tom.get("evidence", {})
    scores = {
        str(k): DimensionVerdict(str(v))
        for k, v in (scores_raw.items() if isinstance(scores_raw, dict) else [])
    }
    evidence: dict[str, tuple[GroundedPoint, ...]] = {}
    if isinstance(evidence_raw, dict):
        for k, pts in evidence_raw.items():
            evidence[str(k)] = tuple(
                _rebuild_grounded_point(p)
                for p in (pts if isinstance(pts, list) else [])
                if isinstance(p, dict)
            )
    matrix = TradeOffMatrix(scores=scores, evidence=evidence)
    disag_raw = d.get("explicit_disagreements", [])
    disagreements = tuple(
        Disagreement(
            dimension=str(dd["dimension"]),
            bear_verdict=str(dd["bear_verdict"]),
            bull_verdict=str(dd["bull_verdict"]),
            note=str(dd.get("note", "")),
            kind=str(dd.get("kind", "verdict")),
        )
        for dd in (disag_raw if isinstance(disag_raw, list) else [])
        if isinstance(dd, dict)
    )
    cats_raw = d.get("catalysts", [])
    catalysts = tuple(
        _rebuild_grounded_point(p)
        for p in (cats_raw if isinstance(cats_raw, list) else [])
        if isinstance(p, dict)
    )
    risks_raw = d.get("risks", [])
    risks = tuple(
        _rebuild_grounded_point(p)
        for p in (risks_raw if isinstance(risks_raw, list) else [])
        if isinstance(p, dict)
    )
    return Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=Confluence(str(d["confluence_assessment"])),
        explicit_disagreements=disagreements,
        catalysts=catalysts,
        risks=risks,
        reasoning_trace=str(d.get("reasoning_trace", "")),
    )


def _rebuild_thesis(d: dict[str, object]) -> Thesis:
    ticker_raw = d["ticker"]
    if isinstance(ticker_raw, dict):
        ticker_sym = str(dict(ticker_raw).get("symbol", ""))
    else:
        ticker_sym = str(ticker_raw)
    ticker = Ticker(ticker_sym)

    as_of_raw = d["as_of"]
    as_of = date.fromisoformat(str(as_of_raw)) if as_of_raw else date.today()

    created_raw = d["created_at"]
    created_at = (
        datetime.fromisoformat(str(created_raw))
        if isinstance(created_raw, str)
        else datetime.now(UTC)  # D-059 R1 fix: fallback must be tz-aware UTC
    )

    rec_raw = d.get("final_recommendation")
    rec = Recommendation(str(rec_raw)) if rec_raw else None
    conf_raw = d.get("confidence_level")
    conf = ConfidenceLevel(str(conf_raw)) if conf_raw else None

    persp_raw = d.get("perspectives", [])
    perspectives = tuple(
        _rebuild_perspective(dict(p))
        for p in (persp_raw if isinstance(persp_raw, list) else [])
        if isinstance(p, dict)
    )

    synth_raw = d.get("synthesis")
    synthesis = (
        _rebuild_synthesis(dict(synth_raw))
        if isinstance(synth_raw, dict)
        else None
    )

    gaps_raw = d.get("gaps", [])
    gaps = tuple(str(g) for g in gaps_raw) if isinstance(gaps_raw, list) else ()

    cal_raw = d.get("calibration_grade", "D")
    ns_raw = d.get("n_samples", 0)

    return Thesis(
        thesis_id=str(d["thesis_id"]),
        ticker=ticker,
        as_of=as_of,
        created_at=created_at,
        status=ThesisStatus(str(d["status"])),
        perspectives=perspectives,
        synthesis=synthesis,
        final_recommendation=rec,
        confidence_level=conf,
        cost_usd=Decimal(str(d.get("cost_usd", "0"))),
        calibration_grade=str(cal_raw) if cal_raw else "D",
        n_samples=int(str(ns_raw)) if ns_raw else 0,
        gaps=gaps,
    )


@dataclass
class SqliteThesisRepository:
    """SQLite-backed ThesisRepository. Thread-safe via per-call connection.

    db_path: path to the SQLite file. Creates file + schema on first use.
    """

    db_path: Path

    def __post_init__(self) -> None:
        self._ensure_schema()

    def _ensure_schema(self) -> None:
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.executescript(_SCHEMA)
            conn.commit()

    async def save(self, thesis: Thesis) -> None:
        """Upsert a Thesis by thesis_id PK."""
        payload = json.dumps(_thesis_to_dict(thesis), default=_default)
        prompt_hash = thesis.perspectives[0].prompt_hash if thesis.perspectives else ""
        model_id = thesis.perspectives[0].model_id if thesis.perspectives else ""
        rec_str = str(thesis.final_recommendation) if thesis.final_recommendation else ""
        conf_str = str(thesis.confidence_level) if thesis.confidence_level else ""
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO theses
                  (thesis_id, ticker, as_of, created_at, status, recommendation,
                   confidence_level, payload_json, prompt_hash, model_id, cost_usd)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    thesis.thesis_id,
                    thesis.ticker.symbol,
                    thesis.as_of.isoformat(),
                    thesis.created_at.isoformat(),
                    str(thesis.status),
                    rec_str,
                    conf_str,
                    payload,
                    prompt_hash,
                    model_id,
                    str(thesis.cost_usd),
                ),
            )
            conn.commit()

    async def get_by_id(self, thesis_id: str) -> Thesis | None:
        """Retrieve a Thesis by its ID, or None if not found."""
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(
                "SELECT * FROM theses WHERE thesis_id = ?", (thesis_id,)
            )
            row = cur.fetchone()
        if row is None:
            return None
        try:
            return _dict_to_thesis(dict(row))
        except Exception as exc:
            log.error("Failed to deserialize thesis %s: %s", thesis_id, exc)
            return None

    async def find_by_ticker(
        self, ticker: Ticker, as_of: date
    ) -> list[Thesis]:
        """Find theses for a ticker at or before as_of, most-recent first."""
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.row_factory = sqlite3.Row
            cur = conn.execute(
                """
                SELECT * FROM theses
                WHERE ticker = ? AND as_of <= ?
                ORDER BY as_of DESC, created_at DESC
                """,
                (ticker.symbol, as_of.isoformat()),
            )
            rows = cur.fetchall()
        out: list[Thesis] = []
        for row in rows:
            try:
                out.append(_dict_to_thesis(dict(row)))
            except Exception as exc:
                log.error("Failed to deserialize thesis row: %s", exc)
        return out
