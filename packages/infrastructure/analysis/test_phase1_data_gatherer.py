"""Tests for Phase1DataGatherer — focuses on TA feature wiring (DEFER-S43b-5).

Repositories are stubbed via duck-typed Protocols; only behaviors that the
gatherer is responsible for are exercised here. Cross-BC repository contracts
are tested elsewhere.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from datetime import date, timedelta
from decimal import Decimal

from packages.contracts.types import Ticker
from packages.infrastructure.analysis.phase1_data_gatherer import Phase1DataGatherer


@dataclass(frozen=True)
class _Money:
    amount: Decimal


@dataclass(frozen=True)
class _Bar:
    bar_id: str
    period_end: date
    close: _Money


class _BarRepoStub:
    def __init__(self, bars: list[_Bar]) -> None:
        self._bars = bars

    async def get_range_as_of(
        self, _ticker: Ticker, _start: date, _end: date
    ) -> list[_Bar]:
        return list(self._bars)


class _EmptyRepoStub:
    async def get_as_of(self, _ticker: Ticker, _as_of: date) -> object:
        return None

    async def get_for_ticker(
        self, _ticker: Ticker, _start: date, _end: date
    ) -> list[object]:
        return []


class _RatioServiceStub:
    def compute_ttm_ratios(self, **_kwargs: object) -> dict[str, object]:
        return {}


def _bars(n: int, base: float = 100.0, step: float = 0.5) -> list[_Bar]:
    today = date(2026, 5, 1)
    out: list[_Bar] = []
    for i in range(n):
        d = today - timedelta(days=n - 1 - i)
        amt = Decimal(str(base + i * step))
        out.append(_Bar(bar_id=f"b{i}", period_end=d, close=_Money(amt)))
    return out


def _gatherer(bars: list[_Bar]) -> Phase1DataGatherer:
    return Phase1DataGatherer(
        bar_repo=_BarRepoStub(bars),
        fundamental_repo=_EmptyRepoStub(),
        ratio_service=_RatioServiceStub(),
        news_repo=_EmptyRepoStub(),
        claim_repo=_EmptyRepoStub(),
    )


def test_ta_features_populated_with_sufficient_history() -> None:
    ctx = asyncio.run(_gatherer(_bars(60)).gather(Ticker(symbol="FPT"), date(2026, 5, 1)))

    assert ctx.ta_features, "ta_features should be populated"
    assert "sma_20" in ctx.ta_features
    assert "bollinger_position" in ctx.ta_features
    assert ctx.ta_audit, "ta_audit should be populated"
    assert "ta_insufficient" not in ctx.gaps


def test_ta_insufficient_gap_when_no_quotes() -> None:
    ctx = asyncio.run(_gatherer([]).gather(Ticker(symbol="FPT"), date(2026, 5, 1)))

    assert not ctx.ta_features
    assert "ta_insufficient" in ctx.gaps


def test_ta_audit_carries_formula_strings() -> None:
    ctx = asyncio.run(_gatherer(_bars(60)).gather(Ticker(symbol="FPT"), date(2026, 5, 1)))

    assert "sma_N" in ctx.ta_audit
    assert "rsi_14" in ctx.ta_audit
    assert "Wilder" in ctx.ta_audit["rsi_14"]
