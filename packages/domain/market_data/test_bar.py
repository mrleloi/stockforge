"""Tests for Bar entity — invariants + methods."""

from __future__ import annotations

from datetime import UTC, date, datetime, timedelta
from decimal import Decimal

import pytest

from packages.contracts import AdjustmentType, Currency, Money, SourceProvider, Ticker
from packages.domain.market_data.models import Bar, BarInvariantError


def _today() -> date:
    return datetime.now(UTC).date()


def _vhm_bar(
    period_end: date | None = None,
    open_amt: str = "120000",
    high_amt: str = "121500",
    low_amt: str = "118000",
    close_amt: str = "120500",
    currency: Currency = Currency.VND,
    volume: int = 1_500_000,
    foreign_buy: int = 200_000,
    foreign_sell: int = 150_000,
    adjustment_type: AdjustmentType = AdjustmentType.BOTH,
    source_provider: SourceProvider = SourceProvider.VNSTOCK,
) -> Bar:
    pe = period_end or (_today() - timedelta(days=1))
    return Bar(
        ticker=Ticker("VHM"),
        period_end=pe,
        filing_date=pe,
        ingested_at=datetime.combine(pe, datetime.min.time(), tzinfo=UTC),
        open=Money(Decimal(open_amt), currency),
        high=Money(Decimal(high_amt), currency),
        low=Money(Decimal(low_amt), currency),
        close=Money(Decimal(close_amt), currency),
        volume=volume,
        foreign_buy=foreign_buy,
        foreign_sell=foreign_sell,
        adjustment_type=adjustment_type,
        source_provider=source_provider,
    )


class TestBarConstruction:
    def test_valid_default(self) -> None:
        bar = _vhm_bar()
        assert bar.ticker.symbol == "VHM"
        assert bar.adjustment_type == AdjustmentType.BOTH

    def test_period_end_in_future_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="look-ahead"):
            _vhm_bar(period_end=_today() + timedelta(days=1))

    def test_filing_date_after_ingested_raises(self) -> None:
        pe = _today() - timedelta(days=2)
        with pytest.raises(BarInvariantError, match="ingestion cannot precede filing"):
            Bar(
                ticker=Ticker("VHM"),
                period_end=pe,
                filing_date=pe + timedelta(days=10),
                ingested_at=datetime.combine(pe, datetime.min.time(), tzinfo=UTC),
                open=Money(Decimal("100")),
                high=Money(Decimal("110")),
                low=Money(Decimal("90")),
                close=Money(Decimal("105")),
                volume=1000,
                foreign_buy=0,
                foreign_sell=0,
                adjustment_type=AdjustmentType.BOTH,
                source_provider=SourceProvider.VNSTOCK,
            )

    def test_low_greater_than_high_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="low .* > high"):
            _vhm_bar(low_amt="125000", high_amt="120000")

    def test_open_outside_low_high_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="open"):
            _vhm_bar(open_amt="130000", high_amt="125000")

    def test_close_outside_low_high_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="close"):
            _vhm_bar(close_amt="115000", low_amt="118000")

    def test_currency_mismatch_in_ohlc_raises(self) -> None:
        pe = _today() - timedelta(days=1)
        with pytest.raises(BarInvariantError, match="OHLC currency mismatch"):
            Bar(
                ticker=Ticker("VHM"),
                period_end=pe,
                filing_date=pe,
                ingested_at=datetime.combine(pe, datetime.min.time(), tzinfo=UTC),
                open=Money(Decimal("100"), Currency.VND),
                high=Money(Decimal("110"), Currency.USD),
                low=Money(Decimal("90"), Currency.VND),
                close=Money(Decimal("105"), Currency.VND),
                volume=1000,
                foreign_buy=0,
                foreign_sell=0,
                adjustment_type=AdjustmentType.BOTH,
                source_provider=SourceProvider.VNSTOCK,
            )

    def test_negative_volume_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="negative quantity"):
            _vhm_bar(volume=-1)

    def test_negative_foreign_buy_raises(self) -> None:
        with pytest.raises(BarInvariantError, match="negative quantity"):
            _vhm_bar(foreign_buy=-1)

    def test_zero_quantities_allowed(self) -> None:
        bar = _vhm_bar(volume=0, foreign_buy=0, foreign_sell=0)
        assert bar.volume == 0


class TestBarProperties:
    def test_currency_property(self) -> None:
        assert _vhm_bar().currency == "VND"

    def test_foreign_net_positive(self) -> None:
        bar = _vhm_bar(foreign_buy=200_000, foreign_sell=150_000)
        assert bar.foreign_net == 50_000

    def test_foreign_net_negative(self) -> None:
        bar = _vhm_bar(foreign_buy=100_000, foreign_sell=200_000)
        assert bar.foreign_net == -100_000


class TestBarStaleness:
    def test_fresh_bar_not_stale(self) -> None:
        pe = _today() - timedelta(days=2)
        bar = _vhm_bar(period_end=pe)
        assert not bar.is_stale(_today())

    def test_old_bar_stale(self) -> None:
        pe = _today() - timedelta(days=30)
        bar = _vhm_bar(period_end=pe)
        assert bar.is_stale(_today())

    def test_stale_threshold_custom(self) -> None:
        pe = _today() - timedelta(days=3)
        bar = _vhm_bar(period_end=pe)
        assert bar.is_stale(_today(), stale_after_days=2)
        assert not bar.is_stale(_today(), stale_after_days=5)


class TestBarToSnapshot:
    def test_to_snapshot_carries_close_and_period(self) -> None:
        bar = _vhm_bar(close_amt="120500")
        snap = bar.to_snapshot()
        assert snap.ticker == bar.ticker
        assert snap.close == bar.close
        assert snap.as_of == bar.period_end
        assert snap.bar_id == bar.bar_id


class TestBarApplySplit:
    def test_split_halves_prices_doubles_volume(self) -> None:
        bar = _vhm_bar(adjustment_type=AdjustmentType.NONE, volume=1000)
        new_bar = bar.apply_split(Decimal("2"))
        assert new_bar.close.amount == bar.close.amount / 2
        assert new_bar.volume == bar.volume * 2
        assert new_bar.adjustment_type == AdjustmentType.SPLIT

    def test_split_on_dividend_adjusted_promotes_to_both(self) -> None:
        bar = _vhm_bar(adjustment_type=AdjustmentType.DIVIDEND)
        new_bar = bar.apply_split(Decimal("2"))
        assert new_bar.adjustment_type == AdjustmentType.BOTH

    def test_split_zero_or_negative_raises(self) -> None:
        bar = _vhm_bar()
        with pytest.raises(ValueError, match="split ratio"):
            bar.apply_split(Decimal("0"))
        with pytest.raises(ValueError, match="split ratio"):
            bar.apply_split(Decimal("-1"))

    def test_apply_split_does_not_mutate_original(self) -> None:
        bar = _vhm_bar(adjustment_type=AdjustmentType.NONE)
        original_close = bar.close.amount
        _ = bar.apply_split(Decimal("2"))
        assert bar.close.amount == original_close
        assert bar.adjustment_type == AdjustmentType.NONE
