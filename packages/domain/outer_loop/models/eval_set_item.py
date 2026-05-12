"""EvalSetItem — single eval-pipeline input + known outcome (per spec 005 § B.5).

Phase 3 stores items on filesystem partitioned by kind / period / partition.
EvalSetStore.iter_holdout / iter_training enforce BR-2 separation at the
infrastructure boundary.

Invariants:
- item_id non-empty
- known_outcome non-empty (otherwise the item cannot ground evaluation)
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import date

from packages.domain.outer_loop.value_objects.eval_kind import EvalKind
from packages.domain.outer_loop.value_objects.eval_partition import EvalPartition
from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod

__all__ = ["EvalSetItem", "InvariantViolation"]


class InvariantViolation(ValueError):
    """Raised when EvalSetItem construction violates a domain invariant."""


@dataclass(frozen=True, slots=True)
class EvalSetItem:
    item_id: str
    kind: EvalKind
    partition: EvalPartition
    period: EvalPeriod
    as_of: date
    known_outcome: dict[str, object]
    ticker: str | None = None
    metadata: dict[str, object] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if not self.item_id.strip():
            raise InvariantViolation("item_id must be non-empty")
        if not self.known_outcome:
            raise InvariantViolation(
                f"known_outcome must be populated (item_id={self.item_id})"
            )
        if not self.period.contains(self.as_of):
            raise InvariantViolation(
                f"as_of {self.as_of} must fall within period "
                f"[{self.period.start}, {self.period.end}] (item_id={self.item_id})"
            )
