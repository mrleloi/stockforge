"""EvalSetStore — filesystem-backed eval-item store tests with BR-2 enforcement."""

from __future__ import annotations

import json
from datetime import date
from pathlib import Path

import pytest

from packages.domain.outer_loop.value_objects.eval_kind import EvalKind
from packages.domain.outer_loop.value_objects.eval_partition import EvalPartition
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod
from packages.infrastructure.outer_loop.eval_set_store import (
    EvalSetFormatError,
    EvalSetStore,
)


def _write_item(
    root: Path,
    kind: EvalKind,
    period_label: str,
    partition: EvalPartition,
    item_id: str,
    as_of: str,
    outcome: dict,
) -> None:
    path = root / kind.value / period_label / partition.value / f"{item_id}.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps({"item_id": item_id, "as_of": as_of, "known_outcome": outcome}),
        encoding="utf-8",
    )


def test_iter_holdout_returns_only_holdout_items(tmp_path: Path) -> None:
    _write_item(tmp_path, EvalKind.THESIS, "2024-H1", EvalPartition.HOLDOUT, "h1", "2024-02-15", {"r3m": 0.1})
    _write_item(tmp_path, EvalKind.THESIS, "2024-H1", EvalPartition.TRAINING, "t1", "2024-03-15", {"r3m": 0.2})
    _write_item(tmp_path, EvalKind.THESIS, "2024-H1", EvalPartition.HOLDOUT, "h2", "2024-05-15", {"r3m": 0.3})

    store = EvalSetStore(tmp_path)
    holdout = list(store.iter_holdout(EvalKind.THESIS))
    training = list(store.iter_training(EvalKind.THESIS))

    assert {i.item_id for i in holdout} == {"h1", "h2"}
    assert {i.item_id for i in training} == {"t1"}
    # BR-2: every holdout item carries HOLDOUT partition; no leak from training.
    assert all(i.partition == EvalPartition.HOLDOUT for i in holdout)
    assert all(i.partition == EvalPartition.TRAINING for i in training)


def test_count_by_partition(tmp_path: Path) -> None:
    _write_item(tmp_path, EvalKind.PUMP, "2023-H2", EvalPartition.HOLDOUT, "p1", "2023-09-01", {"label": "yes"})
    _write_item(tmp_path, EvalKind.PUMP, "2023-H2", EvalPartition.HOLDOUT, "p2", "2023-10-01", {"label": "no"})
    _write_item(tmp_path, EvalKind.PUMP, "2023-H2", EvalPartition.TRAINING, "p3", "2023-11-01", {"label": "yes"})

    store = EvalSetStore(tmp_path)
    assert store.count(EvalKind.PUMP, EvalPartition.HOLDOUT) == 2
    assert store.count(EvalKind.PUMP, EvalPartition.TRAINING) == 1
    assert store.count(EvalKind.THESIS, EvalPartition.HOLDOUT) == 0


def test_period_filter_only_returns_matching(tmp_path: Path) -> None:
    _write_item(tmp_path, EvalKind.NARRATIVE, "2024-H1", EvalPartition.HOLDOUT, "n1", "2024-02-15", {"phase": "EMERGING"})
    _write_item(tmp_path, EvalKind.NARRATIVE, "2024-H2", EvalPartition.HOLDOUT, "n2", "2024-09-15", {"phase": "MAINSTREAM"})

    store = EvalSetStore(tmp_path)
    h1 = list(
        store.iter_holdout(
            EvalKind.NARRATIVE,
            period=EvalPeriod(start=date(2024, 1, 1), end=date(2024, 6, 30)),
        )
    )
    assert [i.item_id for i in h1] == ["n1"]


def test_unrecognized_period_label_skipped(tmp_path: Path) -> None:
    bad = tmp_path / EvalKind.THESIS.value / "garbage-label" / EvalPartition.HOLDOUT.value
    bad.mkdir(parents=True)
    (bad / "x.json").write_text(
        json.dumps({"item_id": "x", "as_of": "2024-02-15", "known_outcome": {"r3m": 0.1}}),
        encoding="utf-8",
    )
    store = EvalSetStore(tmp_path)
    assert list(store.iter_holdout(EvalKind.THESIS)) == []


def test_malformed_item_raises(tmp_path: Path) -> None:
    bad_dir = tmp_path / EvalKind.THESIS.value / "2024-H1" / EvalPartition.HOLDOUT.value
    bad_dir.mkdir(parents=True)
    (bad_dir / "bad.json").write_text("{not valid", encoding="utf-8")
    store = EvalSetStore(tmp_path)
    with pytest.raises(EvalSetFormatError, match="malformed"):
        list(store.iter_holdout(EvalKind.THESIS))


def test_iter_against_empty_root_returns_nothing(tmp_path: Path) -> None:
    store = EvalSetStore(tmp_path)
    assert list(store.iter_holdout(EvalKind.THESIS)) == []
    assert store.count(EvalKind.PUMP, EvalPartition.TRAINING) == 0
