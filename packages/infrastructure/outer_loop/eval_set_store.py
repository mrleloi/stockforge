"""EvalSetStore — filesystem-backed eval-item store with BR-2 holdout/training separation.

Phase 3 Track L deliverable per master-plan §S55. Year 2 EvalRunner reads
HOLDOUT items via iter_holdout(); prompt-refinement experiments read TRAINING
items via iter_training(). The two surfaces are deliberately distinct — there
is no `iter_all()` because BR-2 forbids mixing them.

Disk layout (mirrors spec 005 § B.5 with concrete partition subdirs):

    <root>/<kind_value>/<period_label>/<partition_value>/*.json

Example:
    eval-sets/thesis/2024-H1/holdout/hpg-2024-02-15.json
    eval-sets/kol_recommendation/2024-H1/training/rec-001.json

Each .json file describes one EvalSetItem:
    {
      "item_id": "hpg-2024-02-15",
      "as_of": "2024-02-15",
      "ticker": "HPG",                               // optional
      "known_outcome": { "return_3m": 0.12, ... },
      "metadata": { "labeled_by": "owner", ... }     // optional
    }

The kind + partition + period come from the directory path; the JSON itself
does not redundantly carry them (single source of truth = filesystem layout).
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterable
from datetime import date
from pathlib import Path

from packages.domain.outer_loop.models.eval_set_item import (
    EvalSetItem,
    InvariantViolation,
)
from packages.domain.outer_loop.value_objects.eval_kind import EvalKind
from packages.domain.outer_loop.value_objects.eval_partition import EvalPartition
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod

__all__ = ["EvalSetFormatError", "EvalSetStore"]


class EvalSetFormatError(ValueError):
    """Raised when an eval-set file or directory has invalid shape."""


# Period label format: 'YYYY-H1' / 'YYYY-H2' / 'YYYY-Q1'..'YYYY-Q4' / 'YYYY-MM-DD_to_YYYY-MM-DD'.
_HALF_RE = re.compile(r"^(\d{4})-H([12])$")
_QUARTER_RE = re.compile(r"^(\d{4})-Q([1-4])$")
_RANGE_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})_to_(\d{4}-\d{2}-\d{2})$")


def _parse_period_label(label: str) -> EvalPeriod:
    if m := _HALF_RE.match(label):
        year = int(m.group(1))
        half = int(m.group(2))
        if half == 1:
            return EvalPeriod(start=date(year, 1, 1), end=date(year, 6, 30))
        return EvalPeriod(start=date(year, 7, 1), end=date(year, 12, 31))
    if m := _QUARTER_RE.match(label):
        year = int(m.group(1))
        quarter = int(m.group(2))
        starts = [(1, 1), (4, 1), (7, 1), (10, 1)]
        ends = [(3, 31), (6, 30), (9, 30), (12, 31)]
        return EvalPeriod(
            start=date(year, *starts[quarter - 1]),
            end=date(year, *ends[quarter - 1]),
        )
    if m := _RANGE_RE.match(label):
        return EvalPeriod(
            start=date.fromisoformat(m.group(1)),
            end=date.fromisoformat(m.group(2)),
        )
    raise EvalSetFormatError(
        f"period label {label!r} not in 'YYYY-H1' | 'YYYY-Q1' | 'YYYY-MM-DD_to_YYYY-MM-DD'"
    )


class EvalSetStore:
    """Filesystem reader. Phase 3 read-only; Year 2 may add an `add_item` writer."""

    def __init__(self, root: Path | str):
        self._root = Path(root)

    @property
    def root(self) -> Path:
        return self._root

    def iter_holdout(
        self,
        kind: EvalKind,
        period: EvalPeriod | None = None,
    ) -> Iterable[EvalSetItem]:
        return self._iter(kind, EvalPartition.HOLDOUT, period)

    def iter_training(
        self,
        kind: EvalKind,
        period: EvalPeriod | None = None,
    ) -> Iterable[EvalSetItem]:
        return self._iter(kind, EvalPartition.TRAINING, period)

    def count(
        self,
        kind: EvalKind,
        partition: EvalPartition,
        period: EvalPeriod | None = None,
    ) -> int:
        return sum(1 for _ in self._iter(kind, partition, period))

    def _iter(
        self,
        kind: EvalKind,
        partition: EvalPartition,
        period: EvalPeriod | None,
    ) -> Iterable[EvalSetItem]:
        kind_dir = self._root / kind.value
        if not kind_dir.is_dir():
            return
        for period_dir in sorted(kind_dir.iterdir()):
            if not period_dir.is_dir():
                continue
            try:
                period_obj = _parse_period_label(period_dir.name)
            except EvalSetFormatError:
                continue
            if period is not None and (
                period_obj.start != period.start or period_obj.end != period.end
            ):
                continue
            partition_dir = period_dir / partition.value
            if not partition_dir.is_dir():
                continue
            for item_path in sorted(partition_dir.glob("*.json")):
                yield self._load_item(item_path, kind, partition, period_obj)

    @staticmethod
    def _load_item(
        path: Path,
        kind: EvalKind,
        partition: EvalPartition,
        period: EvalPeriod,
    ) -> EvalSetItem:
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise EvalSetFormatError(f"item JSON malformed at {path}: {exc}") from exc
        if not isinstance(payload, dict):
            raise EvalSetFormatError(f"item at {path} must be a JSON object")
        for required in ("item_id", "as_of", "known_outcome"):
            if required not in payload:
                raise EvalSetFormatError(
                    f"item at {path} missing required field {required!r}"
                )
        try:
            as_of = date.fromisoformat(str(payload["as_of"]))
        except ValueError as exc:
            raise EvalSetFormatError(
                f"item at {path}: as_of must be ISO date; got {payload['as_of']!r}"
            ) from exc
        known_outcome_raw = payload["known_outcome"]
        if not isinstance(known_outcome_raw, dict):
            raise EvalSetFormatError(f"item at {path}: known_outcome must be object")
        ticker_raw = payload.get("ticker")
        ticker = str(ticker_raw) if ticker_raw is not None else None
        metadata_raw = payload.get("metadata", {})
        if not isinstance(metadata_raw, dict):
            raise EvalSetFormatError(f"item at {path}: metadata must be object")
        try:
            return EvalSetItem(
                item_id=str(payload["item_id"]),
                kind=kind,
                partition=partition,
                period=period,
                as_of=as_of,
                ticker=ticker,
                known_outcome=dict(known_outcome_raw),
                metadata=dict(metadata_raw),
            )
        except InvariantViolation as exc:
            raise EvalSetFormatError(f"item at {path} invariant violation: {exc}") from exc
