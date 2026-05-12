"""BC-9 domain model invariants — EditableAsset, ScalarMetricSnapshot, EvalSetItem,
ActivationGateStatus."""

from __future__ import annotations

import math
from datetime import UTC, date, datetime

import pytest

from packages.domain.outer_loop.models.activation_gate_status import (
    ActivationGateStatus,
    InvariantViolation as GateInvariantViolation,
)
from packages.domain.outer_loop.models.editable_asset import (
    EditableAsset,
    InvariantViolation as AssetInvariantViolation,
)
from packages.domain.outer_loop.models.eval_set_item import (
    EvalSetItem,
    InvariantViolation as ItemInvariantViolation,
)
from packages.domain.outer_loop.models.scalar_metric_snapshot import (
    InvariantViolation as MetricInvariantViolation,
    ScalarMetricSnapshot,
)
from packages.domain.outer_loop.value_objects.asset_safety import AssetSafety
from packages.domain.outer_loop.value_objects.eval_kind import EvalKind
from packages.domain.outer_loop.value_objects.eval_partition import EvalPartition
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod


def _period_2024_h1() -> EvalPeriod:
    return EvalPeriod(start=date(2024, 1, 1), end=date(2024, 6, 30))


# ---------- EditableAsset ----------


def test_editable_asset_constructs_with_required_fields() -> None:
    a = EditableAsset(
        asset_id="confluence_weights",
        path="configs/signals/confluence-weights.yaml",
        description="Confluence weight tier shares",
        mutation_types=("numeric_range",),
        safety=AssetSafety.HIGH,
    )
    assert a.asset_id == "confluence_weights"
    assert not a.requires_line_review()


def test_editable_asset_line_review_when_declared() -> None:
    a = EditableAsset(
        asset_id="synthesizer_prompt",
        path="prompts/analysis/synthesizer.md",
        description="Synthesizer system prompt",
        mutation_types=("prompt_variant",),
        safety=AssetSafety.HIGH,
        human_review_required="line_by_line",
    )
    assert a.requires_line_review()


def test_editable_asset_rejects_empty_id() -> None:
    with pytest.raises(AssetInvariantViolation, match="asset_id"):
        EditableAsset(
            asset_id="   ",
            path="x.yaml",
            description="",
            mutation_types=("numeric_range",),
            safety=AssetSafety.LOW,
        )


def test_editable_asset_rejects_empty_mutation_types() -> None:
    with pytest.raises(AssetInvariantViolation, match="mutation_types"):
        EditableAsset(
            asset_id="x",
            path="x.yaml",
            description="x",
            mutation_types=(),
            safety=AssetSafety.LOW,
        )


# ---------- ScalarMetricSnapshot ----------


def test_scalar_metric_snapshot_constructs() -> None:
    s = ScalarMetricSnapshot(
        run_id="run-1",
        mutation_id="mut-1",
        asset_id="confluence_weights",
        period=_period_2024_h1(),
        metrics={"thesis_hit_rate": 0.55, "alert_precision": 0.8},
        composite=0.62,
        duration_ms=1500,
        ran_at=datetime(2026, 5, 9, tzinfo=UTC),
    )
    assert s.composite == 0.62
    assert s.metrics["thesis_hit_rate"] == 0.55


def test_scalar_metric_snapshot_rejects_nan_composite() -> None:
    with pytest.raises(MetricInvariantViolation, match="composite"):
        ScalarMetricSnapshot(
            run_id="r",
            mutation_id="m",
            asset_id="a",
            period=_period_2024_h1(),
            metrics={"x": 0.5},
            composite=math.nan,
            duration_ms=0,
            ran_at=datetime(2026, 5, 9, tzinfo=UTC),
        )


def test_scalar_metric_snapshot_rejects_inf_metric_value() -> None:
    with pytest.raises(MetricInvariantViolation, match="finite"):
        ScalarMetricSnapshot(
            run_id="r",
            mutation_id="m",
            asset_id="a",
            period=_period_2024_h1(),
            metrics={"x": math.inf},
            composite=0.5,
            duration_ms=0,
            ran_at=datetime(2026, 5, 9, tzinfo=UTC),
        )


def test_scalar_metric_snapshot_rejects_empty_metrics() -> None:
    with pytest.raises(MetricInvariantViolation, match="metrics"):
        ScalarMetricSnapshot(
            run_id="r",
            mutation_id="m",
            asset_id="a",
            period=_period_2024_h1(),
            metrics={},
            composite=0.5,
            duration_ms=0,
            ran_at=datetime(2026, 5, 9, tzinfo=UTC),
        )


# ---------- EvalSetItem ----------


def test_eval_set_item_constructs() -> None:
    item = EvalSetItem(
        item_id="hpg-2024-02-15",
        kind=EvalKind.THESIS,
        partition=EvalPartition.HOLDOUT,
        period=_period_2024_h1(),
        as_of=date(2024, 2, 15),
        known_outcome={"return_3m": 0.12},
        ticker="HPG",
    )
    assert item.partition == EvalPartition.HOLDOUT


def test_eval_set_item_rejects_as_of_outside_period() -> None:
    with pytest.raises(ItemInvariantViolation, match="as_of"):
        EvalSetItem(
            item_id="x",
            kind=EvalKind.THESIS,
            partition=EvalPartition.HOLDOUT,
            period=_period_2024_h1(),
            as_of=date(2024, 12, 1),
            known_outcome={"return_3m": 0.0},
        )


def test_eval_set_item_rejects_empty_outcome() -> None:
    with pytest.raises(ItemInvariantViolation, match="known_outcome"):
        EvalSetItem(
            item_id="x",
            kind=EvalKind.PUMP,
            partition=EvalPartition.HOLDOUT,
            period=_period_2024_h1(),
            as_of=date(2024, 2, 15),
            known_outcome={},
        )


# ---------- ActivationGateStatus ----------


def test_activation_gate_status_ready() -> None:
    s = ActivationGateStatus(ready=True, evaluated_at=datetime(2026, 5, 9, tzinfo=UTC))
    assert s.ready
    assert s.shortfalls == {}


def test_activation_gate_status_rejects_ready_with_shortfalls() -> None:
    with pytest.raises(GateInvariantViolation, match="ready=True"):
        ActivationGateStatus(
            ready=True,
            evaluated_at=datetime(2026, 5, 9, tzinfo=UTC),
            shortfalls={EvalKind.THESIS: (50, 100)},
        )


def test_activation_gate_status_rejects_not_ready_without_shortfalls() -> None:
    with pytest.raises(GateInvariantViolation, match="must list"):
        ActivationGateStatus(ready=False, evaluated_at=datetime(2026, 5, 9, tzinfo=UTC))
