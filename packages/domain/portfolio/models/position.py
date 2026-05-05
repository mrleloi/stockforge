"""Position — held quantity of a single ticker with cost basis + risk snapshot.

Rich entity per architecture.md § Domain Model Rules. Methods enforce:
- BR-2 (spec 000): is_violating_risk reads from immutable RiskRule snapshot
  — LLM cannot mutate the rule post-construction
- BR-3 + I-S6 + Rule 5: current_value matches PriceSnapshot currency to
  avg_cost currency; cross-currency raises via Money arithmetic
- I-S1: pnl_pct returns Decimal from code computation; no LLM math

Phase 1 cost-basis policy = weighted-average per Q-S27-3 resolution
(retail VN broker convention; FIFO/LIFO deferred Phase 2 tax accounting).

Position is mutable (events accumulate in _events) — not frozen, but the
identity (position_id) and risk_rule_snapshot are stable post-construction.

Per IMPL-S27-2: Position consumes the cross-BC PriceSnapshot value object
(packages/contracts/types/price_snapshot.py) rather than importing Bar
directly — preserves architecture.md § Cross-BC Rules ("Never direct import
between BCs"). Caller maps Bar → PriceSnapshot via Bar.to_snapshot() at the
BC boundary.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal

from packages.contracts import (
    Money,
    PositionId,
    PositionValueComputed,
    PriceSnapshot,
    Ticker,
    new_position_id,
)
from packages.domain.portfolio.value_objects import RiskRule

__all__ = ["Position", "PositionInvariantError"]


class PositionInvariantError(ValueError):
    """Raised when Position is constructed with invalid quantity / cost / dates."""


@dataclass(slots=True)
class Position:
    """Open position in a single ticker. Phase 1 = long-only, no derivatives."""

    ticker: Ticker
    quantity: int
    avg_cost: Money
    opened_at: date
    risk_rule_snapshot: RiskRule = field(default_factory=RiskRule)
    position_id: PositionId = field(default_factory=new_position_id)
    _events: list[PositionValueComputed] = field(default_factory=list)

    def __post_init__(self) -> None:
        if self.quantity <= 0:
            raise PositionInvariantError(
                f"quantity must be > 0 (long-only Phase 1), got {self.quantity}"
            )
        if self.avg_cost.amount <= 0:
            raise PositionInvariantError(
                f"avg_cost must be > 0, got {self.avg_cost.amount}"
            )
        today = datetime.now(UTC).date()
        if self.opened_at > today:
            raise PositionInvariantError(
                f"opened_at {self.opened_at} > today {today}"
            )

    @property
    def cost_basis(self) -> Money:
        """Total acquisition cost = avg_cost × quantity."""
        return self.avg_cost * self.quantity

    def current_value(self, snapshot: PriceSnapshot) -> Money:
        """Mark-to-market value at snapshot.close.

        Raises CurrencyMismatchError (via Money) if snapshot currency ≠
        avg_cost currency — protects against silent VND/USD confusion per
        Rule 5.
        """
        if snapshot.ticker != self.ticker:
            raise PositionInvariantError(
                f"snapshot.ticker {snapshot.ticker} != position.ticker {self.ticker}"
            )
        return snapshot.close * self.quantity

    def pnl_pct(self, snapshot: PriceSnapshot) -> Decimal:
        """Unrealized PnL as fraction (e.g., 0.05 = +5%). All-code computation per I-S1."""
        current = self.current_value(snapshot)
        cost = self.cost_basis
        if cost.amount == 0:
            raise PositionInvariantError("cost_basis amount is 0; pnl_pct undefined")
        return (current.amount - cost.amount) / cost.amount

    def is_violating_risk(self, portfolio_total: Money) -> bool:
        """True if current cost-basis fraction of portfolio exceeds RiskRule cap.

        Phase 1 uses cost-basis (deterministic, doesn't need a snapshot).
        Phase 2 switches to mark-to-market for live monitoring.
        """
        if portfolio_total.currency != self.cost_basis.currency:
            raise PositionInvariantError(
                f"portfolio currency {portfolio_total.currency.value} != "
                f"position currency {self.cost_basis.currency.value}"
            )
        if portfolio_total.amount <= 0:
            raise PositionInvariantError(
                f"portfolio_total must be > 0, got {portfolio_total.amount}"
            )
        position_pct = self.cost_basis.amount / portfolio_total.amount
        return position_pct > self.risk_rule_snapshot.max_position_pct

    def compute_value(self, snapshot: PriceSnapshot) -> PositionValueComputed:
        """Compute mark-to-market value AND append PositionValueComputed event.

        Returns the event for caller convenience (e.g., dispatch via in-process
        bus per architecture.md § Event Flow Phase 1).
        """
        value = self.current_value(snapshot)
        event = PositionValueComputed(
            ticker=self.ticker,
            position_id=self.position_id,
            computed_value=value,
            as_of=snapshot.as_of,
            source_bar_id=snapshot.bar_id,
            computed_at=datetime.now(UTC),
        )
        self._events.append(event)
        return event

    def pull_events(self) -> list[PositionValueComputed]:
        """Drain accumulated events. Aggregate-root pattern for event dispatch."""
        out = list(self._events)
        self._events.clear()
        return out
