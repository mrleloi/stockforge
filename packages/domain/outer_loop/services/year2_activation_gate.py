"""Year2ActivationGate — deterministic BR-10 minimum-eval-set check.

Per spec 005 § A.2 + BR-10: the outer loop refuses to run when eval set sizes
fall below documented minimums. Year 2 weekly_runner consults this gate before
candidate selection.

DETERMINISTIC — pure integer comparison; NO LLM imports (Charter Principle 9).

Default minimums (override per-call for tests):
- THESIS: 100 (spec § A.2)
- KOL_RECOMMENDATION: 500
- PUMP: 20
- NARRATIVE: 10
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime

from packages.domain.outer_loop.models.activation_gate_status import (
    ActivationGateStatus,
)
from packages.domain.outer_loop.value_objects.eval_kind import EvalKind

__all__ = ["DEFAULT_MINIMUMS", "Year2ActivationGate"]


# Spec 005 § A.2 — minimum eval set sizes before outer loop is meaningful.
DEFAULT_MINIMUMS: dict[EvalKind, int] = {
    EvalKind.THESIS: 100,
    EvalKind.KOL_RECOMMENDATION: 500,
    EvalKind.PUMP: 20,
    EvalKind.NARRATIVE: 10,
}


@dataclass(frozen=True, slots=True)
class Year2ActivationGate:
    minimums: dict[EvalKind, int] | None = None

    def evaluate(
        self,
        counts: dict[EvalKind, int],
        *,
        as_of: datetime | None = None,
    ) -> ActivationGateStatus:
        effective = self.minimums if self.minimums is not None else DEFAULT_MINIMUMS
        shortfalls: dict[EvalKind, tuple[int, int]] = {}
        for kind, required in effective.items():
            actual = counts.get(kind, 0)
            if actual < required:
                shortfalls[kind] = (actual, required)
        return ActivationGateStatus(
            ready=len(shortfalls) == 0,
            shortfalls=shortfalls,
            evaluated_at=as_of if as_of is not None else datetime.now(UTC),
        )
