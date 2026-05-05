"""Tests for Position entity + RiskRule value object."""

from __future__ import annotations

from datetime import UTC, date, datetime, timedelta
from decimal import Decimal

import pytest

from packages.contracts import (
    Currency,
    Money,
    PositionValueComputed,
    PriceSnapshot,
    Ticker,
    new_bar_id,
)
from packages.domain.portfolio.models import Position, PositionInvariantError
from packages.domain.portfolio.value_objects import (
    RiskRule,
    RiskRuleInvariantError,
)


def _today() -> date:
    return datetime.now(UTC).date()


def _vhm_snapshot(close_amount: str = "120000") -> PriceSnapshot:
    return PriceSnapshot(
        ticker=Ticker("VHM"),
        close=Money(Decimal(close_amount)),
        as_of=_today() - timedelta(days=1),
        bar_id=new_bar_id(),
    )


def _position(
    quantity: int = 1000,
    avg_cost: str = "115000",
    currency: Currency = Currency.VND,
) -> Position:
    return Position(
        ticker=Ticker("VHM"),
        quantity=quantity,
        avg_cost=Money(Decimal(avg_cost), currency),
        opened_at=_today() - timedelta(days=30),
    )


class TestRiskRule:
    def test_default_charter_values(self) -> None:
        rule = RiskRule()
        assert rule.max_position_pct == Decimal("0.15")
        assert rule.max_sector_concentration_pct == Decimal("0.30")
        assert rule.holding_period_min_months == 1
        assert rule.holding_period_pref_min_months == 6

    def test_max_position_above_one_raises(self) -> None:
        with pytest.raises(RiskRuleInvariantError):
            RiskRule(max_position_pct=Decimal("1.5"))

    def test_max_position_zero_raises(self) -> None:
        with pytest.raises(RiskRuleInvariantError):
            RiskRule(max_position_pct=Decimal("0"))

    def test_pref_below_min_raises(self) -> None:
        with pytest.raises(RiskRuleInvariantError):
            RiskRule(holding_period_min_months=12, holding_period_pref_min_months=6)

    def test_stop_loss_optional(self) -> None:
        rule = RiskRule(stop_loss_pct=Decimal("0.10"))
        assert rule.stop_loss_pct == Decimal("0.10")

    def test_invalid_max_position_type(self) -> None:
        with pytest.raises(RiskRuleInvariantError):
            RiskRule(max_position_pct=0.15)  # type: ignore[arg-type]

    def test_frozen(self) -> None:
        rule = RiskRule()
        with pytest.raises((AttributeError, Exception)):
            rule.max_position_pct = Decimal("0.20")  # type: ignore[misc]


class TestPositionConstruction:
    def test_valid(self) -> None:
        pos = _position()
        assert pos.ticker.symbol == "VHM"
        assert pos.quantity == 1000

    def test_zero_quantity_raises(self) -> None:
        with pytest.raises(PositionInvariantError, match="quantity"):
            _position(quantity=0)

    def test_negative_quantity_raises(self) -> None:
        with pytest.raises(PositionInvariantError, match="quantity"):
            _position(quantity=-100)

    def test_zero_avg_cost_raises(self) -> None:
        with pytest.raises(PositionInvariantError, match="avg_cost"):
            _position(avg_cost="0")

    def test_opened_at_in_future_raises(self) -> None:
        with pytest.raises(PositionInvariantError, match="opened_at"):
            Position(
                ticker=Ticker("VHM"),
                quantity=1000,
                avg_cost=Money(Decimal("115000")),
                opened_at=_today() + timedelta(days=1),
            )


class TestPositionValuation:
    def test_cost_basis(self) -> None:
        pos = _position(quantity=1000, avg_cost="115000")
        assert pos.cost_basis.amount == Decimal("115000000")

    def test_current_value_at_market(self) -> None:
        pos = _position(quantity=1000, avg_cost="115000")
        snap = _vhm_snapshot(close_amount="120500")
        assert pos.current_value(snap).amount == Decimal("120500000")

    def test_pnl_pct_positive(self) -> None:
        pos = _position(quantity=1000, avg_cost="100000")
        snap = _vhm_snapshot(close_amount="120000")
        assert pos.pnl_pct(snap) == Decimal("0.20")

    def test_pnl_pct_negative(self) -> None:
        pos = _position(quantity=1000, avg_cost="120000")
        snap = _vhm_snapshot(close_amount="100000")
        assert pos.pnl_pct(snap) < 0

    def test_ticker_mismatch_raises(self) -> None:
        pos = _position()
        vic_snap = PriceSnapshot(
            ticker=Ticker("VIC"),
            close=Money(Decimal("103000")),
            as_of=_today() - timedelta(days=1),
            bar_id=new_bar_id(),
        )
        with pytest.raises(PositionInvariantError, match="snapshot.ticker"):
            pos.current_value(vic_snap)


class TestPositionRiskCheck:
    def test_within_risk_returns_false(self) -> None:
        pos = _position(quantity=1000, avg_cost="100000")
        portfolio_total = Money(Decimal("10_000_000_000"))
        assert pos.is_violating_risk(portfolio_total) is False

    def test_exceeds_risk_returns_true(self) -> None:
        pos = _position(quantity=10_000, avg_cost="200_000")
        portfolio_total = Money(Decimal("3_000_000_000"))
        assert pos.is_violating_risk(portfolio_total) is True

    def test_currency_mismatch_raises(self) -> None:
        pos = _position(quantity=1000, avg_cost="100000", currency=Currency.VND)
        portfolio_usd = Money(Decimal("100000"), Currency.USD)
        with pytest.raises(PositionInvariantError, match="currency"):
            pos.is_violating_risk(portfolio_usd)


class TestPositionEvents:
    def test_compute_value_emits_event(self) -> None:
        pos = _position()
        snap = _vhm_snapshot()
        event = pos.compute_value(snap)
        assert isinstance(event, PositionValueComputed)
        assert event.ticker == pos.ticker
        assert event.position_id == pos.position_id
        assert event.source_bar_id == snap.bar_id

    def test_pull_events_drains(self) -> None:
        pos = _position()
        snap = _vhm_snapshot()
        pos.compute_value(snap)
        pos.compute_value(snap)
        events = pos.pull_events()
        assert len(events) == 2
        assert pos.pull_events() == []
