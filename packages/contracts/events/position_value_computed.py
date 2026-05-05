"""PositionValueComputed — BC-9 (Portfolio) emits when re-pricing a Position.

Cross-BC contract event. BC-9 owns the emission; downstream consumers (BC-8
Analysis for thesis valuation, future dashboard for live PnL display) read
from the event without taking a domain dependency on Portfolio.

Per spec 000 § B.3 Domain Events Emitted (S25 architect output).

Frozen dataclass: equality + hashability + immutability come from the dataclass
decorator. No business logic — events are past-tense facts (architecture.md §
Event-Driven Rules), not behavior containers.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, datetime

from packages.contracts.types import BarId, Money, PositionId, Ticker

__all__ = ["PositionValueComputed"]


@dataclass(frozen=True, slots=True)
class PositionValueComputed:
    """Past-tense fact: a Position's value was computed from a specific Bar.

    Phase 1 invariants (validated in __post_init__):
    - computed_value uses Money — currency carried explicitly per Rule 5
    - source_bar_id is the cross-BC reference proving Bar provenance per Rule 4
    - as_of is the Bar's period_end (point-in-time integrity per Rule 1 / I-S2)
    - computed_at is wall-clock at emission time (audit-only; not used in
      backtest filtering)
    """

    ticker: Ticker
    position_id: PositionId
    computed_value: Money
    as_of: date
    source_bar_id: BarId
    computed_at: datetime

    def __post_init__(self) -> None:
        if not isinstance(self.ticker, Ticker):
            raise TypeError(
                f"ticker must be Ticker, got {type(self.ticker).__name__}"
            )
        if not isinstance(self.computed_value, Money):
            raise TypeError(
                f"computed_value must be Money, got {type(self.computed_value).__name__}"
            )
        if not isinstance(self.as_of, date):
            raise TypeError(
                f"as_of must be datetime.date, got {type(self.as_of).__name__}"
            )
        if not isinstance(self.computed_at, datetime):
            raise TypeError(
                f"computed_at must be datetime.datetime, got {type(self.computed_at).__name__}"
            )
