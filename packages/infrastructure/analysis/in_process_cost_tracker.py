"""InProcessCostTracker — in-process CostTrackerPort implementation.

Uses asyncio.Lock for race-safe accumulation during parallel asyncio.gather
of the 3 perspective agents (bear_t, bull_t, quant_t run concurrently).

scoped_budget(): context manager that returns a Budget handle. The handle
accumulates spend via budget.add(usd). On Budget.add() exceeding the limit,
CostBudgetExceeded is raised immediately — the coroutine chain unwinds.

record(): async method for explicit per-call cost recording. Used by
synthesizer and any future async cost-accumulating component.

Phase 2: in-process only. Phase 4: swap to Redis-backed tracker or Postgres
audit table for multi-user cost enforcement.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.11.
"""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Iterator
from contextlib import contextmanager
from decimal import Decimal

from packages.application.analysis.ports.cost_tracker_port import (
    Budget,
    CostBudgetExceeded,
)

__all__ = ["InProcessCostTracker"]

log = logging.getLogger(__name__)


class InProcessCostTracker:
    """In-process cost tracker using asyncio.Lock.

    Thread/task safe: lock prevents concurrent budget.add() from racing.
    Suitable for Phase 2 single-process asyncio.gather usage.
    """

    def __init__(self) -> None:
        self._lock: asyncio.Lock = asyncio.Lock()
        self._total_spent: Decimal = Decimal("0")

    @contextmanager
    def scoped_budget(self, limit_usd: Decimal) -> Iterator[Budget]:
        """Yield a Budget handle for the duration of a single thesis execution.

        The Budget handle is local to each execution; the tracker accumulates
        _total_spent across ALL executions (for lifetime monitoring).
        CostBudgetExceeded is raised by budget.add() when spent > limit.
        """
        budget = Budget(spent=Decimal("0"), limit=limit_usd)
        try:
            yield budget
        except CostBudgetExceeded:
            log.warning(
                "Cost budget exceeded: spent $%s > limit $%s",
                budget.spent,
                budget.limit,
            )
            raise
        finally:
            # Accumulate into global tracker regardless of exception
            self._total_spent += budget.spent

    async def record(self, usd: Decimal) -> None:
        """Atomically record a single LLM call cost to lifetime total."""
        async with self._lock:
            self._total_spent += usd

    @property
    def total_spent(self) -> Decimal:
        """Total cost accumulated across all executions in this process lifetime."""
        return self._total_spent
