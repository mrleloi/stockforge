"""SsiAdapter — fetch DAILY Bars via SSI iBoard public chart API (httpx direct).

Implements `BarProviderPort` (S32 Track A R2 closure). Per D-012 (S32):
TCBS public `stock-insight` endpoint family returned 404 across all probed
URL variants throughout S32; vnstock 4.0.2 `Quote` source backends are
effectively VCI-only in practice (TCBS/SSI/DNSE/FMARKET fail on
construction; MSN unreachable). SSI's iBoard chart-history endpoint at
`https://iboard-api.ssi.com.vn/statistics/charts/history` is publicly
reachable and returned full 1-year OHLCV for 30/30 VN30 tickers (248 bars
each) during S32 coverage probe — restoring Rule 4 multi-source
reconciliation discipline previously broken by R2.

Endpoint shape (TradingView-style; `from`/`to` are unix epoch seconds):

    GET https://iboard-api.ssi.com.vn/statistics/charts/history
        ?symbol=VHM&resolution=D&from=1714435200&to=1745971200

    {
      "code": "SUCCESS",
      "message": "...",
      "data": {
        "t": [1714608000, 1714694400, ...],       # epoch seconds (UTC midnight)
        "o": [40.8, 40.5, ...],                    # open  (THOUSAND VND)
        "h": [41.25, 40.7, ...],                   # high  (THOUSAND VND)
        "l": [40.35, 40.1, ...],                   # low   (THOUSAND VND)
        "c": [41.15, 40.4, ...],                   # close (THOUSAND VND)
        "v": [4570000, 5102100, ...],              # volume (shares)
        "s": "ok",
        "nextTime": null
      }
    }

Prices are in **thousand VND** (close=41.15 means 41,150 VND/share),
matching the convention shared by VnstockAdapter so reconciliation does
not need a unit-conversion step.

Per Q-S28-3 + agent-notes "stale data must propagate": non-200 OR
unexpected payload → `SsiApiError`. The CLI orchestrator catches it and
logs single-source mode; never falls back silently. `http_get_fn` is
injected for test isolation per the same pattern as TcbsAdapter.
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

__all__ = ["SsiAdapter", "SsiApiError"]


_SSI_BASE_URL = "https://iboard-api.ssi.com.vn/statistics/charts/history"
_DEFAULT_TIMEOUT_SECONDS = 10.0
_VND_THOUSANDS_MULTIPLIER = Decimal("1000")

ParamValue = str | int


class HttpResponse(Protocol):
    """Minimal httpx.Response surface the adapter consumes."""

    status_code: int

    def json(self) -> object: ...


class HttpGetFn(Protocol):
    """Injectable HTTP GET. Production wraps httpx.get; tests pass fake."""

    def __call__(self, url: str, params: dict[str, ParamValue]) -> HttpResponse: ...


class SsiApiError(RuntimeError):
    """Raised when SSI iBoard API returns non-200 or unexpected payload shape."""


@dataclass
class SsiAdapter:
    """Fetch DAILY OHLCV via SSI iBoard public chart API.

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
                raise SsiApiError(
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

        from_epoch = int(datetime.combine(start, datetime.min.time()).timestamp())
        to_epoch = int(datetime.combine(end, datetime.min.time()).timestamp())
        params: dict[str, ParamValue] = {
            "symbol": ticker.symbol,
            "resolution": "D",
            "from": from_epoch,
            "to": to_epoch,
        }

        response = self.http_get_fn(_SSI_BASE_URL, params)
        status = getattr(response, "status_code", None)
        if status != 200:
            raise SsiApiError(
                f"SSI iBoard API returned status {status} for symbol={ticker.symbol}"
            )
        payload = response.json()
        if not isinstance(payload, dict) or "data" not in payload:
            raise SsiApiError(f"unexpected payload shape: {type(payload).__name__}")
        data = payload["data"]
        if not isinstance(data, dict):
            raise SsiApiError(f"unexpected data shape: {type(data).__name__}")

        times = data.get("t") or []
        opens = data.get("o") or []
        highs = data.get("h") or []
        lows = data.get("l") or []
        closes = data.get("c") or []
        volumes = data.get("v") or []
        if not isinstance(times, list):
            raise SsiApiError("data.t is not a list")
        n = len(times)
        if not all(isinstance(arr, list) and len(arr) == n for arr in (opens, highs, lows, closes, volumes)):
            raise SsiApiError("OHLCV arrays length mismatch")

        ingested_at = datetime.now(UTC)
        bars: list[Bar] = []
        for i in range(n):
            period_end = self._epoch_to_date(times[i])
            if period_end is None or period_end < start or period_end > end:
                continue
            try:
                bars.append(
                    Bar(
                        ticker=ticker,
                        period_end=period_end,
                        filing_date=period_end,
                        ingested_at=ingested_at,
                        open=self._money_thousand(opens[i]),
                        high=self._money_thousand(highs[i]),
                        low=self._money_thousand(lows[i]),
                        close=self._money_thousand(closes[i]),
                        volume=int(volumes[i]),
                        foreign_buy=0,
                        foreign_sell=0,
                        adjustment_type=AdjustmentType.BOTH,
                        source_provider=SourceProvider.SSI,
                    )
                )
            except (TypeError, ValueError) as exc:
                raise SsiApiError(f"row {i} malformed: {exc}") from exc
        bars.sort(key=lambda b: b.period_end)
        return bars

    def _respect_rate_limit(self) -> None:
        elapsed = time.monotonic() - self._last_call_at
        if 0 < elapsed < self.rate_limit_seconds:
            time.sleep(self.rate_limit_seconds - elapsed)
        object.__setattr__(self, "_last_call_at", time.monotonic())

    @staticmethod
    def _epoch_to_date(value: object) -> date | None:
        if value is None:
            return None
        if isinstance(value, int | float):
            return datetime.fromtimestamp(float(value), tz=UTC).date()
        return None

    @staticmethod
    def _money_thousand(thousand_vnd: object) -> Money:
        amount = Decimal(str(thousand_vnd)) * _VND_THOUSANDS_MULTIPLIER
        return Money(amount, Currency.VND)
