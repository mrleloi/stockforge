"""PercentileService — historical-distribution percentile computation (S34).

Per master-plan 005 § S34 deliverable #3: `compute_historical_percentiles(
ticker, years=5)` returns a 5-year distribution. The actual time-series of
historical Ratios is supplied by the caller (typically the Phase1DataGatherer
which loads them from a future RatioRepository); this service is the pure
quantile arithmetic.

Phase 2 thin slice uses linear-interpolation quantile (numpy `linear` /
statistics `quantiles(method="exclusive")` equivalent — chosen to match
Penman "Financial Statement Analysis" 5e §13.6 illustration). Phase 3 may
extend with regime-aware percentiles (bull/bear partition) per Charter
calibration discipline.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal
from statistics import quantiles

from packages.contracts import Ticker
from packages.domain.fundamental.value_objects import Ratio, RatioName

__all__ = ["HistoricalPercentile", "PercentileService"]


@dataclass(frozen=True, slots=True)
class HistoricalPercentile:
    """5-point quantile snapshot for a Ratio time-series.

    p10..p90 are linear-interpolated quantiles. `current_percentile` is the
    rank of the most recent observed value within the historical distribution
    (0.0 = lowest, 1.0 = highest, 0.5 = median); a thesis output cites this
    to claim "current P/E is at 78th percentile of 5-yr history".
    """

    ticker: Ticker
    ratio_name: RatioName
    p10: Decimal
    p25: Decimal
    p50: Decimal
    p75: Decimal
    p90: Decimal
    n_observations: int
    window_start: date
    window_end: date
    current_value: Decimal | None = None
    current_percentile: Decimal | None = None


@dataclass
class PercentileService:
    """Pure stdlib quantile computer over Ratio time-series."""

    minimum_observations: int = 8

    def compute_historical_percentiles(
        self,
        *,
        ticker: Ticker,
        ratio_name: RatioName,
        ratios: Iterable[Ratio],
        years: int = 5,
        as_of: date | None = None,
    ) -> HistoricalPercentile | None:
        """Compute p10/p25/p50/p75/p90 for `ratio_name` over the past `years`.

        Returns None when fewer than `minimum_observations` ratios fall inside
        the window — better to surface "insufficient history" than emit an
        unstable distribution that downstream LLMs would over-interpret
        (calibration discipline; Charter Principle 8).
        """
        anchor = as_of if as_of is not None else date.today()
        window_start = anchor - timedelta(days=365 * years)
        in_window = [
            r for r in ratios
            if r.ticker == ticker
            and r.name == ratio_name
            and window_start <= r.period_end <= anchor
        ]
        in_window.sort(key=lambda r: r.period_end)
        if len(in_window) < self.minimum_observations:
            return None

        values = [r.value for r in in_window]
        # statistics.quantiles requires float; map to Decimal after for storage discipline.
        floats = [float(v) for v in values]
        qs = quantiles(floats, n=10, method="inclusive")  # 9 cut points: p10..p90 step 10
        p10, p25_lerp, p50, p75_lerp, p90 = qs[0], qs[1], qs[4], qs[6], qs[8]
        # statistics.quantiles n=10 yields p10/p20/p30/p40/p50/p60/p70/p80/p90
        # → p25 / p75 are NOT directly emitted; linear-interpolate from neighbours.
        p25 = qs[1] + (qs[2] - qs[1]) * 0.5  # midpoint of p20 and p30
        p75 = qs[6] + (qs[7] - qs[6]) * 0.5  # midpoint of p70 and p80
        _ = (p25_lerp, p75_lerp)  # explicit drop of pre-interpolation slots

        current = values[-1]
        below = sum(1 for v in values if v < current)
        rank = Decimal(str(below)) / Decimal(str(len(values)))

        return HistoricalPercentile(
            ticker=ticker,
            ratio_name=ratio_name,
            p10=Decimal(str(p10)),
            p25=Decimal(str(p25)),
            p50=Decimal(str(p50)),
            p75=Decimal(str(p75)),
            p90=Decimal(str(p90)),
            n_observations=len(in_window),
            window_start=in_window[0].period_end,
            window_end=in_window[-1].period_end,
            current_value=current,
            current_percentile=rank,
        )
