"""ScalarMetricRecorder — sqlite eval_runs persistence tests."""

from __future__ import annotations

from datetime import UTC, date, datetime
from pathlib import Path

from packages.domain.outer_loop.models.scalar_metric_snapshot import (
    ScalarMetricSnapshot,
)
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod
from packages.infrastructure.outer_loop.scalar_metric_recorder import (
    ScalarMetricRecorder,
)


def _make_snapshot(run_id: str, asset_id: str, mutation_id: str) -> ScalarMetricSnapshot:
    return ScalarMetricSnapshot(
        run_id=run_id,
        mutation_id=mutation_id,
        asset_id=asset_id,
        period=EvalPeriod(start=date(2024, 1, 1), end=date(2024, 6, 30)),
        metrics={"thesis_hit_rate": 0.55, "alert_precision": 0.8},
        composite=0.62,
        duration_ms=1500,
        ran_at=datetime(2026, 5, 9, tzinfo=UTC),
        extras={"note": "smoke"},
    )


def test_record_and_get_round_trip(tmp_path: Path) -> None:
    rec = ScalarMetricRecorder(tmp_path / "metrics.db")
    snap = _make_snapshot("run-1", "confluence_weights", "mut-1")
    rec.record(snap)

    fetched = rec.get_by_run_id("run-1")
    assert fetched is not None
    assert fetched.run_id == "run-1"
    assert fetched.composite == 0.62
    assert fetched.metrics == {"thesis_hit_rate": 0.55, "alert_precision": 0.8}
    assert fetched.period.start == date(2024, 1, 1)
    assert fetched.extras == {"note": "smoke"}


def test_query_by_asset_returns_only_matching(tmp_path: Path) -> None:
    rec = ScalarMetricRecorder(tmp_path / "metrics.db")
    rec.record(_make_snapshot("r1", "asset-A", "mut-1"))
    rec.record(_make_snapshot("r2", "asset-A", "mut-2"))
    rec.record(_make_snapshot("r3", "asset-B", "mut-3"))

    asset_a_runs = rec.query_by_asset("asset-A")
    assert {r.run_id for r in asset_a_runs} == {"r1", "r2"}
    assert rec.count() == 3


def test_query_by_mutation(tmp_path: Path) -> None:
    rec = ScalarMetricRecorder(tmp_path / "metrics.db")
    rec.record(_make_snapshot("r1", "asset-A", "mut-1"))
    rec.record(_make_snapshot("r2", "asset-B", "mut-1"))
    rec.record(_make_snapshot("r3", "asset-A", "mut-2"))

    mut1_runs = rec.query_by_mutation("mut-1")
    assert {r.run_id for r in mut1_runs} == {"r1", "r2"}


def test_get_by_run_id_returns_none_for_missing(tmp_path: Path) -> None:
    rec = ScalarMetricRecorder(tmp_path / "metrics.db")
    assert rec.get_by_run_id("absent") is None
