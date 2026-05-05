"""Bar — atomic OHLCV time-series row for a single ticker + timeframe.

Phase 1 thin-slice scope: DAILY EOD bars only. Intraday (ATO/ATC, Mua chủ
động/Bán chủ động fields) deferred to Phase 2 per spec 000 § A.5.

Invariants enforced in __post_init__:
- BR-1 (spec 000): period_end ≤ today (no future bars)
- BR-1: filing_date ≤ ingested_at (ingestion cannot precede filing)
- BR-1 + I-S4: adjustment_type non-None (Enum guarantees)
- I-S5 + Rule 4: source_provider non-None (Enum guarantees)
- BR-3 + I-S6: open/high/low/close all share the same currency
- OHLC ordering: low ≤ open ≤ high; low ≤ close ≤ high; low ≤ high
- volume + foreign_buy + foreign_sell ≥ 0

Source: agent-workspace/constitution/architecture.md § BC-1 Market Data;
financial-data-protocol.md Rule 1 + Rule 3 + Rule 4 + Rule 5; invariants.md
I-S2 + I-S4 + I-S5 + I-S6; spec 000 § B.4.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, date, datetime, timedelta
from decimal import Decimal

from packages.contracts import (
    AdjustmentType,
    BarId,
    Money,
    PriceSnapshot,
    SourceProvider,
    Ticker,
    new_bar_id,
)

__all__ = ["Bar", "BarInvariantError"]


_DEFAULT_STALE_DAYS = 7


class BarInvariantError(ValueError):
    """Raised when a Bar is constructed with values violating BR-1 / I-S2 / I-S4 / I-S6."""


@dataclass(frozen=True, slots=True)
class Bar:
    """Immutable OHLCV bar. Rich entity per architecture.md § Domain Model Rules.

    Methods (`is_stale`, `apply_split`) preserve immutability — apply_split
    returns a NEW Bar rather than mutating; is_stale is pure read.
    """

    ticker: Ticker
    period_end: date
    filing_date: date
    ingested_at: datetime
    open: Money
    high: Money
    low: Money
    close: Money
    volume: int
    foreign_buy: int
    foreign_sell: int
    adjustment_type: AdjustmentType
    source_provider: SourceProvider
    bar_id: BarId = field(default_factory=new_bar_id)

    def __post_init__(self) -> None:
        today = datetime.now(UTC).date()
        if self.period_end > today:
            raise BarInvariantError(
                f"period_end {self.period_end} > today {today} (look-ahead bias; I-S2)"
            )
        if self.filing_date > self.ingested_at.date():
            raise BarInvariantError(
                f"filing_date {self.filing_date} > ingested_at {self.ingested_at.date()} "
                f"(ingestion cannot precede filing; Rule 1)"
            )
        currencies = {self.open.currency, self.high.currency, self.low.currency, self.close.currency}
        if len(currencies) > 1:
            raise BarInvariantError(
                f"OHLC currency mismatch {sorted(c.value for c in currencies)} (I-S6 + Rule 5)"
            )
        if self.low.amount > self.high.amount:
            raise BarInvariantError(
                f"low {self.low.amount} > high {self.high.amount}"
            )
        if not (self.low.amount <= self.open.amount <= self.high.amount):
            raise BarInvariantError(
                f"open {self.open.amount} outside [low {self.low.amount}, high {self.high.amount}]"
            )
        if not (self.low.amount <= self.close.amount <= self.high.amount):
            raise BarInvariantError(
                f"close {self.close.amount} outside [low {self.low.amount}, high {self.high.amount}]"
            )
        if self.volume < 0 or self.foreign_buy < 0 or self.foreign_sell < 0:
            raise BarInvariantError(
                f"negative quantity (volume={self.volume}, fb={self.foreign_buy}, fs={self.foreign_sell})"
            )

    @property
    def currency(self) -> str:
        return self.close.currency.value

    @property
    def foreign_net(self) -> int:
        return self.foreign_buy - self.foreign_sell

    def is_stale(self, as_of: date, stale_after_days: int = _DEFAULT_STALE_DAYS) -> bool:
        """True if `as_of` is more than stale_after_days past period_end."""
        return (as_of - self.period_end) > timedelta(days=stale_after_days)

    def to_snapshot(self) -> PriceSnapshot:
        """Project to the cross-BC PriceSnapshot value object.

        BC-9 (Portfolio) and BC-8 (Analysis) consume PriceSnapshot rather than
        importing Bar — preserves architecture.md cross-BC import discipline.
        """
        return PriceSnapshot(
            ticker=self.ticker,
            close=self.close,
            as_of=self.period_end,
            bar_id=self.bar_id,
        )

    def apply_split(self, ratio: Decimal) -> Bar:
        """Return a new Bar with OHLC / ratio and volume * ratio.

        adjustment_type promotes to SPLIT (or BOTH if already DIVIDEND-adjusted).
        Pure: original Bar unchanged.
        """
        if ratio <= 0:
            raise ValueError(f"split ratio must be positive, got {ratio}")
        new_adj = (
            AdjustmentType.BOTH
            if self.adjustment_type == AdjustmentType.DIVIDEND
            else AdjustmentType.SPLIT
        )
        return Bar(
            ticker=self.ticker,
            period_end=self.period_end,
            filing_date=self.filing_date,
            ingested_at=self.ingested_at,
            open=Money(self.open.amount / ratio, self.open.currency),
            high=Money(self.high.amount / ratio, self.high.currency),
            low=Money(self.low.amount / ratio, self.low.currency),
            close=Money(self.close.amount / ratio, self.close.currency),
            volume=int(Decimal(self.volume) * ratio),
            foreign_buy=int(Decimal(self.foreign_buy) * ratio),
            foreign_sell=int(Decimal(self.foreign_sell) * ratio),
            adjustment_type=new_adj,
            source_provider=self.source_provider,
        )
