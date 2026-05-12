"""ScalarMetricSnapshot — recorded eval-run output (per spec 005 § B.6 eval_runs).

Year 2 EvalRunner produces these; Phase 3 only defines the data contract + recorder.

Invariants:
- mutation_id + asset_id non-empty
- composite finite (no NaN / Inf)
- metrics dict non-empty (at least one sub-metric)
- duration_ms >= 0

DETERMINISTIC ONLY — composite is computed from deterministic code, NEVER from LLM
output (Charter Principle 9 + I-S1).
"""

from __future__ import annotations

import math
from dataclasses import dataclass, field
from datetime import datetime

from packages.domain.outer_loop.value_objects.eval_period import EvalPeriod

__all__ = ["InvariantViolation", "ScalarMetricSnapshot"]


class InvariantViolation(ValueError):
    """Raised when ScalarMetricSnapshot construction violates a domain invariant."""


@dataclass(frozen=True, slots=True)
class ScalarMetricSnapshot:
    run_id: str
    mutation_id: str
    asset_id: str
    period: EvalPeriod
    metrics: dict[str, float]
    composite: float
    duration_ms: int
    ran_at: datetime
    extras: dict[str, str] = field(default_factory=dict)

    def __post_init__(self) -> None:
        for label, value in (
            ("run_id", self.run_id),
            ("mutation_id", self.mutation_id),
            ("asset_id", self.asset_id),
        ):
            if not value.strip():
                raise InvariantViolation(f"{label} must be non-empty")
        if not self.metrics:
            raise InvariantViolation("metrics must contain ≥1 sub-metric")
        for k, v in self.metrics.items():
            if not isinstance(v, (int, float)) or math.isnan(v) or math.isinf(v):
                raise InvariantViolation(
                    f"metric {k!r} must be finite numeric; got {v!r}"
                )
        if math.isnan(self.composite) or math.isinf(self.composite):
            raise InvariantViolation(
                f"composite must be finite; got {self.composite!r}"
            )
        if self.duration_ms < 0:
            raise InvariantViolation(
                f"duration_ms must be >=0; got {self.duration_ms}"
            )
