"""BC-2 domain service tests (S34 Track C).

Ratio formula tests use **textbook reference values** per master-plan 005
§ S34 success criterion: "All ratio service tests PASS with textbook
reference values within ±0.01 tolerance".
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental import (
    FinancialStatement,
    LineItemKey,
    PeerService,
    PercentileService,
    Ratio,
    RatioComputationError,
    RatioName,
    RatioService,
    StatementType,
)
from packages.domain.market_data.value_objects import VN30_UNIVERSE  # composition layer pattern

_T = Ticker("VHM")
_PERIOD = date(2026, 3, 31)
_TOL = Decimal("0.01")


def _is_quarter(period_end: date, *, ni: str, revenue: str, eps: str = "1000") -> FinancialStatement:
    return FinancialStatement(
        ticker=_T,
        statement_type=StatementType.IS,
        period_end=period_end,
        filing_date=period_end,
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        line_items={
            LineItemKey.REVENUE.value: Money(Decimal(revenue), Currency.VND),
            LineItemKey.NET_INCOME.value: Money(Decimal(ni), Currency.VND),
            LineItemKey.EPS.value: Money(Decimal(eps), Currency.VND),
        },
        source_provider=SourceProvider.VNSTOCK,
    )


def _bs(period_end: date, *, equity: str, assets: str, liab: str, bvps: str) -> FinancialStatement:
    return FinancialStatement(
        ticker=_T,
        statement_type=StatementType.BS,
        period_end=period_end,
        filing_date=period_end,
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        line_items={
            LineItemKey.TOTAL_EQUITY.value: Money(Decimal(equity), Currency.VND),
            LineItemKey.TOTAL_ASSETS.value: Money(Decimal(assets), Currency.VND),
            LineItemKey.TOTAL_LIABILITIES.value: Money(Decimal(liab), Currency.VND),
            LineItemKey.BOOK_VALUE_PER_SHARE.value: Money(Decimal(bvps), Currency.VND),
        },
        source_provider=SourceProvider.VNSTOCK,
    )


def test_compute_pe_textbook_value() -> None:
    # Damodaran: price=100, EPS=5 → P/E = 20.0
    r = RatioService().compute_pe(
        eps_ttm=Decimal("5"),
        price_per_share=Money(Decimal("100"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("20.00")) <= _TOL
    assert r.name == RatioName.PE
    assert "Damodaran" in r.formula_audit


def test_compute_pe_zero_eps_raises() -> None:
    with pytest.raises(RatioComputationError):
        RatioService().compute_pe(
            eps_ttm=Decimal("0"), price_per_share=Money(Decimal("100"), Currency.VND),
            ticker=_T, period_end=_PERIOD,
        )


def test_compute_pb_textbook_value() -> None:
    # Penman: price=100, BVPS=50 → P/B = 2.0
    r = RatioService().compute_pb(
        book_value_per_share=Money(Decimal("50"), Currency.VND),
        price_per_share=Money(Decimal("100"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("2.00")) <= _TOL


def test_compute_roe_textbook_value() -> None:
    # Higgins: NI=100, equity=1000 → ROE = 0.10
    r = RatioService().compute_roe(
        net_income_ttm=Money(Decimal("100"), Currency.VND),
        total_equity=Money(Decimal("1000"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("0.10")) <= _TOL
    assert StatementType.BS in r.computed_from
    assert StatementType.IS in r.computed_from


def test_compute_roa_textbook_value() -> None:
    # Higgins: NI=100, assets=2000 → ROA = 0.05
    r = RatioService().compute_roa(
        net_income_ttm=Money(Decimal("100"), Currency.VND),
        total_assets=Money(Decimal("2000"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("0.05")) <= _TOL


def test_compute_debt_equity_textbook_value() -> None:
    # Brealey-Myers: liab=600, equity=400 → D/E = 1.5
    r = RatioService().compute_debt_equity(
        total_liabilities=Money(Decimal("600"), Currency.VND),
        total_equity=Money(Decimal("400"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("1.50")) <= _TOL


def test_compute_net_margin_textbook_value() -> None:
    # White-Sondhi-Fried: NI=100, revenue=1000 → NM = 0.10
    r = RatioService().compute_net_margin(
        net_income_ttm=Money(Decimal("100"), Currency.VND),
        revenue_ttm=Money(Decimal("1000"), Currency.VND),
        ticker=_T, period_end=_PERIOD,
    )
    assert abs(r.value - Decimal("0.10")) <= _TOL


def test_compute_ttm_ratios_aggregates_four_quarters() -> None:
    quarters = [
        _is_quarter(date(2025, 6, 30), ni="25", revenue="250", eps="500"),
        _is_quarter(date(2025, 9, 30), ni="25", revenue="250", eps="500"),
        _is_quarter(date(2025, 12, 31), ni="25", revenue="250", eps="500"),
        _is_quarter(date(2026, 3, 31), ni="25", revenue="250", eps="500"),
    ]
    bs = _bs(date(2026, 3, 31), equity="1000", assets="2000", liab="1500", bvps="50")
    out = RatioService().compute_ttm_ratios(
        ticker=_T, period_end=_PERIOD,
        income_statements=quarters,
        latest_balance_sheet=bs,
        price_per_share=Money(Decimal("100"), Currency.VND),
    )
    # 4 × 25 = 100 NI TTM; 4 × 250 = 1000 revenue TTM; equity 1000.
    assert abs(out[RatioName.ROE].value - Decimal("0.10")) <= _TOL
    assert abs(out[RatioName.ROA].value - Decimal("0.05")) <= _TOL
    assert abs(out[RatioName.NET_MARGIN].value - Decimal("0.10")) <= _TOL
    assert abs(out[RatioName.DEBT_EQUITY].value - Decimal("1.50")) <= _TOL
    assert abs(out[RatioName.PB].value - Decimal("2.00")) <= _TOL
    # P/E = 100 / (4 × 500) = 100 / 2000 = 0.05
    assert abs(out[RatioName.PE].value - Decimal("0.05")) <= _TOL


def test_compute_ttm_ratios_skips_when_inputs_missing() -> None:
    # Only revenue, no net income → only NET_MARGIN unavailable; nothing else either.
    quarters = [_is_quarter(date(2026, 3, 31), ni="25", revenue="250", eps="500")]
    out = RatioService().compute_ttm_ratios(
        ticker=_T, period_end=_PERIOD,
        income_statements=quarters,
        latest_balance_sheet=None,
        price_per_share=None,
    )
    assert RatioName.NET_MARGIN in out
    assert RatioName.ROE not in out
    assert RatioName.PE not in out


def test_required_line_items_via_service_facade() -> None:
    keys = RatioService.required_line_items(RatioName.ROE)
    assert LineItemKey.NET_INCOME in keys
    assert LineItemKey.TOTAL_EQUITY in keys


def test_peer_service_returns_same_sector_excludes_self() -> None:
    svc = PeerService.from_constituents(VN30_UNIVERSE)
    # Pick a ticker known to be in VN30
    anchor = VN30_UNIVERSE[0]
    peers = svc.get_comparables(anchor.ticker, sector_as_of=date(2026, 4, 30))
    assert anchor.ticker not in peers
    if peers:
        anchor_sector = anchor.sector
        for p in peers:
            sector_p = svc.get_sector(p)
            assert sector_p == anchor_sector


def test_peer_service_unknown_ticker_returns_empty() -> None:
    svc = PeerService.from_constituents(VN30_UNIVERSE)
    peers = svc.get_comparables(Ticker("ZZZ"), sector_as_of=date(2026, 4, 30))
    assert peers == ()


def test_peer_service_caps_at_max_peers() -> None:
    svc = PeerService.from_constituents(VN30_UNIVERSE, max_peers=2)
    anchor = VN30_UNIVERSE[0]
    peers = svc.get_comparables(anchor.ticker, sector_as_of=date(2026, 4, 30))
    assert len(peers) <= 2


def test_peer_service_all_sectors_distinct() -> None:
    svc = PeerService.from_constituents(VN30_UNIVERSE)
    sectors = list(svc.all_sectors())
    assert len(sectors) == len(set(sectors))


def test_peer_service_default_universe_is_empty() -> None:
    """Domain-pure default; composition layer must wire the universe."""
    svc = PeerService()
    assert svc.get_comparables(Ticker("VHM"), sector_as_of=date(2026, 4, 30)) == ()


def test_percentile_service_returns_none_when_below_minimum() -> None:
    svc = PercentileService(minimum_observations=8)
    ratios = [
        Ratio(
            name=RatioName.PE, value=Decimal(str(v)), ticker=_T, period_end=date(2026, 1, 1),
            formula_audit="x", computed_from=(StatementType.IS,),
        )
        for v in (10, 12, 14)
    ]
    assert svc.compute_historical_percentiles(
        ticker=_T, ratio_name=RatioName.PE, ratios=ratios,
    ) is None


def test_percentile_service_computes_quantiles_across_window() -> None:
    svc = PercentileService(minimum_observations=8)
    # 10 quarterly observations 2024-Q1..2026-Q2 with strictly increasing values
    base = date(2024, 3, 31)
    ratios = []
    for i in range(10):
        period = date(base.year + (base.month - 1 + i * 3) // 12, ((base.month - 1 + i * 3) % 12) + 1, 28)
        ratios.append(
            Ratio(
                name=RatioName.PE, value=Decimal(str(10 + i)), ticker=_T, period_end=period,
                formula_audit="x", computed_from=(StatementType.IS,),
            )
        )
    snap = svc.compute_historical_percentiles(
        ticker=_T, ratio_name=RatioName.PE, ratios=ratios, years=5,
        as_of=date(2026, 6, 30),
    )
    assert snap is not None
    assert snap.n_observations == 10
    assert snap.p10 < snap.p50 < snap.p90
    assert snap.current_value == Decimal("19")
    assert snap.current_percentile is not None and snap.current_percentile > Decimal("0.5")
