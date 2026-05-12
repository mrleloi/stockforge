"""EvalPeriod — closed-interval window for walk-forward validation.

Per spec 005 § B.2 metric_calculation: each mutation is evaluated across multiple
non-overlapping eval_periods. Period covers [start, end] inclusive.

Year 2 walk-forward (BR-5): mutation must improve in ≥2 of 3 periods to pass.
Phase 3 only persists the period boundaries; no period arithmetic yet.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date

__all__ = ["EvalPeriod"]


@dataclass(frozen=True, slots=True)
class EvalPeriod:
    start: date
    end: date

    def __post_init__(self) -> None:
        if self.start > self.end:
            raise ValueError(
                f"EvalPeriod.start ({self.start}) must be <= end ({self.end})"
            )

    def contains(self, when: date) -> bool:
        return self.start <= when <= self.end
