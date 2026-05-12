"""ActivationGateStatus — Year-2 activation readiness verdict (per spec 005 § A.2 + BR-10).

Year2ActivationGate.evaluate produces this. ready=True only when every required
EvalKind meets the documented minimum count. ready=False means the outer loop
MUST refuse to run (BR-10).

`shortfalls` maps EvalKind → (actual, required) for kinds that did NOT meet the
minimum. Empty when ready=True.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime

from packages.domain.outer_loop.value_objects.eval_kind import EvalKind

__all__ = ["ActivationGateStatus", "InvariantViolation"]


class InvariantViolation(ValueError):
    """Raised when ActivationGateStatus construction violates a domain invariant."""


@dataclass(frozen=True, slots=True)
class ActivationGateStatus:
    ready: bool
    evaluated_at: datetime
    shortfalls: dict[EvalKind, tuple[int, int]] = field(default_factory=dict)

    def __post_init__(self) -> None:
        if self.ready and self.shortfalls:
            raise InvariantViolation(
                f"ready=True must imply empty shortfalls; got {dict(self.shortfalls)!r}"
            )
        if not self.ready and not self.shortfalls:
            raise InvariantViolation(
                "ready=False must list at least one shortfall"
            )
        for kind, (actual, required) in self.shortfalls.items():
            if actual < 0 or required < 0:
                raise InvariantViolation(
                    f"shortfall counts must be >=0; got {kind}=({actual},{required})"
                )
            if actual >= required:
                raise InvariantViolation(
                    f"shortfall for {kind} must imply actual<required; "
                    f"got actual={actual} required={required}"
                )
