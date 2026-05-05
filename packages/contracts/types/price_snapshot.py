"""PriceSnapshot — cross-BC price-quote value object.

Shared-kernel value object that lets BC-9 (Portfolio) consume BC-1 (Market
Data) closing prices without taking a domain dependency on BC-1's Bar
aggregate root. Per architecture.md § Cross-BC Rules: "Never direct import
between BCs. Cross-BC types live in packages/contracts/."

BC-1 maps Bar → PriceSnapshot (Bar.to_snapshot()). BC-9 calls
Position.current_value(snapshot) — it never sees Bar internals.

Per IMPL-S27-2 (S27 session log): introduced after the obvious-but-wrong
direct import of Bar by Position was detected at the cross-BC import grep.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date

from .identifiers import BarId
from .money import Money
from .ticker import Ticker

__all__ = ["PriceSnapshot"]


@dataclass(frozen=True, slots=True)
class PriceSnapshot:
    """Immutable price-quote crossing BC boundaries. Phase 1 = closing price only."""

    ticker: Ticker
    close: Money
    as_of: date
    bar_id: BarId

    def __post_init__(self) -> None:
        if not isinstance(self.ticker, Ticker):
            raise TypeError(
                f"ticker must be Ticker, got {type(self.ticker).__name__}"
            )
        if not isinstance(self.close, Money):
            raise TypeError(
                f"close must be Money, got {type(self.close).__name__}"
            )
        if not isinstance(self.as_of, date):
            raise TypeError(
                f"as_of must be datetime.date, got {type(self.as_of).__name__}"
            )
