"""VnstockAdapter — fetch DAILY Bars via vnstock library (VCI source).

Implements `BarProviderPort` (S28). Maps vnstock DataFrame rows to Bar entities
with full provenance per Rule 4 (source attribution): every emitted Bar has
`source_provider=SourceProvider.VNSTOCK`, `adjustment_type=AdjustmentType.BOTH`
(VCI returns adjusted prices by default; raw history is not exposed by the
library), `filing_date` set to `period_end` (EOD bars file same day they
represent), `ingested_at` set to wall-clock at fetch time.

vnstock 4.0.2 quote.history returns prices in **thousand VND** for VN equities
(e.g., 124.0 means 124,000 VND/share). This adapter multiplies by 1000 so Bar
carries plain VND, matching domain expectations and SQLite storage.

Rate limiting: vnstock has no documented limit per library README; agent-notes
prudence + Q-S28-2 → default `rate_limit_seconds=1.0` between calls when the
adapter is invoked in a loop. Single-ticker single-call patterns (the S28 thin
slice) do not loop, so the limit is informational.

Per IMPL-S28-1 (S28 entry decision): vnstock 4.0.2 deprecated TCBS as a source
of `Quote`. Two-source reconciliation pattern preserved by pairing this VCI
adapter with the direct-HTTP TcbsAdapter that calls TCBS's public REST API.
"""

from __future__ import annotations

import time
from collections.abc import Iterator
from dataclasses import dataclass
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import Protocol, cast

from packages.contracts import (
    AdjustmentType,
    Currency,
    Money,
    SourceProvider,
    Ticker,
)
from packages.domain.market_data.models import Bar

__all__ = ["VnstockAdapter", "VnstockAdapterError"]


_VND_THOUSANDS_MULTIPLIER = Decimal("1000")


class QuoteHistoryFn(Protocol):
    """Injectable history-fetch callable. Production = vnstock Quote.history."""

    def __call__(self, *, symbol: str, start: str, end: str, interval: str) -> object: ...


class _DataFrameLike(Protocol):
    """Subset of pandas.DataFrame that VnstockAdapter consumes."""

    columns: list[str]

    def iterrows(self) -> Iterator[tuple[int, dict[str, object]]]: ...


class VnstockAdapterError(RuntimeError):
    """Raised when vnstock returns an unexpected payload or transport fails."""


@dataclass
class VnstockAdapter:
    """Fetch DAILY OHLCV via vnstock VCI source. Implements BarProviderPort.

    `quote_history_fn` is injected for test isolation — production wiring uses
    the real `vnstock.api.quote.Quote(...).history`. Tests pass a lambda that
    returns a recorded DataFrame, enabling fixture-based testing with no
    network per architecture.md § Testing.
    """

    quote_history_fn: QuoteHistoryFn | None = None
    rate_limit_seconds: float = 1.0
    _last_call_at: float = 0.0

    def __post_init__(self) -> None:
        if self.quote_history_fn is None:
            try:
                from vnstock.api.quote import Quote  # type: ignore[import-untyped]
            except ImportError as exc:
                raise VnstockAdapterError(
                    "vnstock library not installed; pip install vnstock>=4.0.0"
                ) from exc

            def _fetch(*, symbol: str, start: str, end: str, interval: str) -> object:
                quote = Quote(symbol=symbol, source="VCI")
                return cast(object, quote.history(start=start, end=end, interval=interval))

            object.__setattr__(self, "quote_history_fn", _fetch)

    def fetch_daily(self, ticker: Ticker, start: date, end: date) -> list[Bar]:
        if start > end:
            raise ValueError(f"start {start} > end {end}")
        self._respect_rate_limit()
        assert self.quote_history_fn is not None  # __post_init__ wires default

        df = self.quote_history_fn(
            symbol=ticker.symbol,
            start=start.isoformat(),
            end=end.isoformat(),
            interval="1D",
        )

        ingested_at = datetime.now(UTC)
        bars: list[Bar] = []
        for row in self._iter_rows(df):
            period_end = self._coerce_date(row["time"])
            if period_end > date.today() or period_end > end or period_end < start:
                continue
            bars.append(
                Bar(
                    ticker=ticker,
                    period_end=period_end,
                    filing_date=period_end,
                    ingested_at=ingested_at,
                    open=self._money(row["open"]),
                    high=self._money(row["high"]),
                    low=self._money(row["low"]),
                    close=self._money(row["close"]),
                    volume=int(str(row["volume"])),
                    foreign_buy=0,
                    foreign_sell=0,
                    adjustment_type=AdjustmentType.BOTH,
                    source_provider=SourceProvider.VNSTOCK,
                )
            )
        bars.sort(key=lambda b: b.period_end)
        return bars

    def _respect_rate_limit(self) -> None:
        elapsed = time.monotonic() - self._last_call_at
        if 0 < elapsed < self.rate_limit_seconds:
            time.sleep(self.rate_limit_seconds - elapsed)
        object.__setattr__(self, "_last_call_at", time.monotonic())

    @staticmethod
    def _iter_rows(df: object) -> Iterator[dict[str, object]]:
        if hasattr(df, "iterrows"):
            df_typed = cast(_DataFrameLike, df)
            for _idx, row in df_typed.iterrows():
                yield {col: row[col] for col in df_typed.columns}
            return
        if isinstance(df, list):
            for row in df:
                yield cast(dict[str, object], row)
            return
        raise VnstockAdapterError(f"unexpected vnstock payload type {type(df).__name__}")

    @staticmethod
    def _coerce_date(value: object) -> date:
        if isinstance(value, date) and not isinstance(value, datetime):
            return value
        if isinstance(value, datetime):
            return value.date()
        if isinstance(value, str):
            return datetime.strptime(value[:10], "%Y-%m-%d").date()
        if hasattr(value, "to_pydatetime"):
            converted = value.to_pydatetime()
            return cast(datetime, converted).date()
        raise VnstockAdapterError(f"cannot coerce {value!r} to date")

    @staticmethod
    def _money(thousand_vnd: object) -> Money:
        amount = Decimal(str(thousand_vnd)) * _VND_THOUSANDS_MULTIPLIER
        return Money(amount, Currency.VND)
