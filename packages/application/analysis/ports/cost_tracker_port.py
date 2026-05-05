"""CostTrackerPort — Protocol + supporting types for LLM cost enforcement.

CostTrackerPort enforces BR-6 / I-40: $3 hard cap per ValidateThesisPhase1UseCase
execute(). The use case wraps its entire execution in a scoped_budget context
manager. If any LLM call (perspective agent + synthesizer) causes spent > limit,
CostBudgetExceeded is raised and the thesis is NOT persisted.

Budget is a mutable record (dataclass NOT frozen) because scoped_budget returns
it as a live handle that accumulates spend across the execution.

InProcessCostTracker (infrastructure) implements this Protocol using asyncio.Lock
for race-safety during parallel asyncio.gather of 3 perspective agents.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.4.
"""

from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass, field
from decimal import Decimal
from typing import Protocol, runtime_checkable

__all__ = ["Budget", "CostBudgetExceeded", "CostTrackerPort"]


class CostBudgetExceeded(RuntimeError):
    """Raised when cumulative LLM cost exceeds the scoped_budget limit.

    Carries spent and limit for diagnostics. The use case catches this to
    return Thesis.incomplete() and log the overage without persisting.
    """

    def __init__(self, spent: Decimal, limit: Decimal) -> None:
        super().__init__(
            f"Cost budget exceeded: spent ${spent:.4f} > limit ${limit:.4f} (I-40 / BR-6)"
        )
        self.spent = spent
        self.limit = limit


@dataclass
class Budget:
    """Live budget handle returned by scoped_budget().

    `spent` accumulates as LLM calls complete. Callers check budget.spent
    at end of execution for cost reporting (stored on Thesis.cost_usd).
    `limit` is the $3 hard cap (or lower in tests).
    """

    spent: Decimal = field(default_factory=lambda: Decimal("0"))
    limit: Decimal = field(default_factory=lambda: Decimal("3.00"))

    def add(self, usd: Decimal) -> None:
        """Accumulate cost. Raise CostBudgetExceeded if limit breached."""
        self.spent += usd
        if self.spent > self.limit:
            raise CostBudgetExceeded(self.spent, self.limit)


@runtime_checkable
class CostTrackerPort(Protocol):
    """Protocol for cost enforcement during thesis execution."""

    @contextmanager
    def scoped_budget(self, limit_usd: Decimal) -> Iterator[Budget]:
        """Context manager that tracks cumulative LLM spend within a limit.

        Yields a Budget handle; raises CostBudgetExceeded if spent > limit_usd.
        On normal exit, budget.spent contains the total cost.
        """
        ...

    async def record(self, usd: Decimal) -> None:
        """Record a single LLM call cost atomically (thread/task safe)."""
        ...
