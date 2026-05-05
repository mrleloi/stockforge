"""TcbsAdapter — fetch DAILY Bars via TCBS public REST API (httpx direct).

> **DEPRECATED at S32 per D-012**: TCBS `apipubaws.tcbs.com.vn/stock-insight/`
> endpoint family returned 404 across all probed URL variants (v1 + v2,
> `bars-long-term` + `bars`) during S32 Track A archaeology. The adapter is
> preserved here for archive + graceful-fail wiring; production CLI now pairs
> VnstockAdapter (VCI) with SsiAdapter (SSI iBoard) per D-012 A3 strategy.
> Re-enable if TCBS publishes a working public endpoint in a future Phase.

Implements `BarProviderPort` (S28). Pairs with VnstockAdapter as the second
provider per Rule 4 (source attribution + reconciliation). Sets
`source_provider=SourceProvider.TCBS` on every emitted Bar.

Endpoint pattern: `https://apipubaws.tcbs.com.vn/stock-insight/v2/stock/
bars-long-term` with query params `(ticker, type=stock, resolution=D, to=<epoch>,
countBack=<n>)`. Response shape (when reachable):

    {
      "data": [
        {"open": 124000, "high": 124200, "low": 122500, "close": 123100,
         "volume": 2500900, "tradingDate": "2026-04-29T00:00:00.000Z"},
        ...
      ],
      "ticker": "VHM",
      "page": 0
    }

Per Q-S28-3 + agent-notes "stale data must propagate": if the endpoint returns
non-200 OR an unexpected payload shape, this adapter raises `TcbsApiError`.
The CLI orchestrator (apps/cli/ingest_vhm.py) catches it, logs the cause,
and continues in single-source (vnstock-only) mode — surfacing the gap on the
reconciliation report rather than silently falling back to a fake source.

httpx is used directly (not requests) because it shares pyproject deps with
the wider stockforge LLM transport stack and has cleaner timeout + retry
semantics. `http_client_fn` is injected for test isolation per the same
pattern as VnstockAdapter.
"""

from __future__ import annotations

import time
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

__all__ = ["TcbsAdapter", "TcbsApiError"]


_TCBS_BASE_URL = "https://apipubaws.tcbs.com.vn/stock-insight/v2/stock/bars-long-term"
_DEFAULT_TIMEOUT_SECONDS = 10.0

ParamValue = str | int


class HttpResponse(Protocol):
    """Minimal httpx.Response surface the adapter consumes."""

    status_code: int

    def json(self) -> object: ...


class HttpGetFn(Protocol):
    """Injectable HTTP GET. Production wraps httpx.get; tests pass fake."""

    def __call__(self, url: str, params: dict[str, ParamValue]) -> HttpResponse: ...


class TcbsApiError(RuntimeError):
    """Raised when TCBS public API returns non-200 or unexpected payload."""


@dataclass
class TcbsAdapter:
    """Fetch DAILY OHLCV via TCBS public REST API. Implements BarProviderPort.

    `http_get_fn` is an injectable hook returning an object with `.status_code`
    and `.json()` (httpx.Response shape). Production wiring constructs it from
    httpx; tests pass a lambda returning a fake response so no network is
    required per architecture.md § Testing fixture discipline.
    """

    http_get_fn: HttpGetFn | None = None
    timeout_seconds: float = _DEFAULT_TIMEOUT_SECONDS
    rate_limit_seconds: float = 1.0
    _last_call_at: float = 0.0

    def __post_init__(self) -> None:
        if self.http_get_fn is None:
            try:
                import httpx
            except ImportError as exc:
                raise TcbsApiError(
                    "httpx not installed; pip install httpx"
                ) from exc

            def _http_get(url: str, params: dict[str, ParamValue]) -> HttpResponse:
                return cast(
                    HttpResponse,
                    httpx.get(
                        url,
                        params=params,
                        timeout=self.timeout_seconds,
                        headers={"User-Agent": "Mozilla/5.0 stockforge"},
                    ),
                )

            object.__setattr__(self, "http_get_fn", _http_get)

    def fetch_daily(self, ticker: Ticker, start: date, end: date) -> list[Bar]:
        if start > end:
            raise ValueError(f"start {start} > end {end}")
        self._respect_rate_limit()
        assert self.http_get_fn is not None  # __post_init__ wires default

        end_epoch = int(datetime.combine(end, datetime.min.time()).timestamp())
        # countBack with margin so we cover trading days plus weekends in range
        count_back = (end - start).days + 5
        params: dict[str, ParamValue] = {
            "ticker": ticker.symbol,
            "type": "stock",
            "resolution": "D",
            "to": end_epoch,
            "countBack": count_back,
        }

        response = self.http_get_fn(_TCBS_BASE_URL, params)
        status = getattr(response, "status_code", None)
        if status != 200:
            raise TcbsApiError(
                f"TCBS API returned status {status} for ticker={ticker.symbol}"
            )
        payload = response.json()
        if not isinstance(payload, dict) or "data" not in payload:
            raise TcbsApiError(f"unexpected payload shape: {type(payload).__name__}")

        ingested_at = datetime.now(UTC)
        bars: list[Bar] = []
        for row in payload["data"]:
            period_end = self._parse_trading_date(row.get("tradingDate"))
            if period_end is None or period_end < start or period_end > end:
                continue
            try:
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
                        volume=int(row.get("volume", 0)),
                        foreign_buy=0,
                        foreign_sell=0,
                        adjustment_type=AdjustmentType.BOTH,
                        source_provider=SourceProvider.TCBS,
                    )
                )
            except (KeyError, TypeError) as exc:
                raise TcbsApiError(f"row missing required field: {exc}") from exc
        bars.sort(key=lambda b: b.period_end)
        return bars

    def _respect_rate_limit(self) -> None:
        elapsed = time.monotonic() - self._last_call_at
        if 0 < elapsed < self.rate_limit_seconds:
            time.sleep(self.rate_limit_seconds - elapsed)
        object.__setattr__(self, "_last_call_at", time.monotonic())

    @staticmethod
    def _parse_trading_date(value: object) -> date | None:
        if value is None:
            return None
        if isinstance(value, date) and not isinstance(value, datetime):
            return value
        if isinstance(value, datetime):
            return value.date()
        if isinstance(value, str):
            return datetime.strptime(value[:10], "%Y-%m-%d").date()
        return None

    @staticmethod
    def _money(raw_vnd: object) -> Money:
        return Money(Decimal(str(raw_vnd)), Currency.VND)
