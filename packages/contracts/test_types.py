"""Tests for shared-kernel value objects: Ticker, Money, Enums, Identifiers."""

from __future__ import annotations

from datetime import date
from decimal import Decimal

import pytest

from packages.contracts import (
    AdjustmentType,
    Currency,
    CurrencyMismatchError,
    InvalidTickerError,
    Money,
    PriceSnapshot,
    SourceProvider,
    Ticker,
    new_bar_id,
    new_position_id,
)


class TestTicker:
    def test_valid_3letter_uppercase(self) -> None:
        assert Ticker("VHM").symbol == "VHM"

    def test_valid_lowercase_normalizes_to_upper(self) -> None:
        assert Ticker("vhm").symbol == "VHM"

    def test_valid_alphanumeric_3char(self) -> None:
        assert Ticker("A32").symbol == "A32"

    def test_valid_numeric_3char(self) -> None:
        assert Ticker("322").symbol == "322"

    def test_invalid_too_short(self) -> None:
        with pytest.raises(InvalidTickerError):
            Ticker("AB")

    def test_invalid_too_long(self) -> None:
        with pytest.raises(InvalidTickerError):
            Ticker("VHMX")

    def test_invalid_special_char(self) -> None:
        with pytest.raises(InvalidTickerError):
            Ticker("V_M")

    def test_invalid_non_str(self) -> None:
        with pytest.raises(InvalidTickerError):
            Ticker(123)  # type: ignore[arg-type]

    def test_frozen_cannot_mutate(self) -> None:
        t = Ticker("VHM")
        with pytest.raises((AttributeError, Exception)):
            t.symbol = "VIC"  # type: ignore[misc]

    def test_str_returns_symbol(self) -> None:
        assert str(Ticker("VPB")) == "VPB"


class TestMoney:
    def test_default_currency_vnd(self) -> None:
        m = Money(Decimal("1000"))
        assert m.currency == Currency.VND

    def test_explicit_usd(self) -> None:
        m = Money(Decimal("100"), Currency.USD)
        assert m.currency == Currency.USD

    def test_amount_str_coerced_to_decimal(self) -> None:
        m = Money(1000)  # type: ignore[arg-type]
        assert m.amount == Decimal("1000")
        assert isinstance(m.amount, Decimal)

    def test_add_same_currency(self) -> None:
        result = Money(Decimal("100")) + Money(Decimal("50"))
        assert result.amount == Decimal("150")

    def test_add_mismatched_currency_raises(self) -> None:
        with pytest.raises(CurrencyMismatchError):
            _ = Money(Decimal("100"), Currency.VND) + Money(Decimal("100"), Currency.USD)

    def test_sub_mismatched_currency_raises(self) -> None:
        with pytest.raises(CurrencyMismatchError):
            _ = Money(Decimal("100"), Currency.VND) - Money(Decimal("100"), Currency.USD)

    def test_mul_scalar(self) -> None:
        result = Money(Decimal("100")) * 5
        assert result.amount == Decimal("500")

    def test_rmul_scalar(self) -> None:
        result = 5 * Money(Decimal("100"))
        assert result.amount == Decimal("500")

    def test_invalid_currency_type(self) -> None:
        with pytest.raises(TypeError):
            Money(Decimal("100"), "VND")  # type: ignore[arg-type]


class TestEnums:
    def test_adjustment_type_str_serialization(self) -> None:
        assert AdjustmentType.BOTH.value == "both"
        assert AdjustmentType.NONE.value == "none"

    def test_source_provider_includes_phase1_sources(self) -> None:
        assert SourceProvider.VNSTOCK.value == "vnstock"
        assert SourceProvider.TCBS.value == "tcbs"

    def test_currency_iso_codes(self) -> None:
        assert Currency.VND.value == "VND"


class TestIdentifiers:
    def test_new_bar_id_unique(self) -> None:
        assert new_bar_id() != new_bar_id()

    def test_new_position_id_unique(self) -> None:
        assert new_position_id() != new_position_id()

    def test_bar_id_is_str_runtime(self) -> None:
        assert isinstance(new_bar_id(), str)


class TestPriceSnapshot:
    def test_valid(self) -> None:
        snap = PriceSnapshot(
            ticker=Ticker("VHM"),
            close=Money(Decimal("120000")),
            as_of=date(2026, 4, 30),
            bar_id=new_bar_id(),
        )
        assert snap.ticker.symbol == "VHM"

    def test_invalid_ticker_type_rejected(self) -> None:
        with pytest.raises(TypeError):
            PriceSnapshot(
                ticker="VHM",  # type: ignore[arg-type]
                close=Money(Decimal("120000")),
                as_of=date(2026, 4, 30),
                bar_id=new_bar_id(),
            )

    def test_invalid_close_type_rejected(self) -> None:
        with pytest.raises(TypeError):
            PriceSnapshot(
                ticker=Ticker("VHM"),
                close=Decimal("120000"),  # type: ignore[arg-type]
                as_of=date(2026, 4, 30),
                bar_id=new_bar_id(),
            )

    def test_frozen(self) -> None:
        snap = PriceSnapshot(
            ticker=Ticker("VHM"),
            close=Money(Decimal("120000")),
            as_of=date(2026, 4, 30),
            bar_id=new_bar_id(),
        )
        with pytest.raises((AttributeError, Exception)):
            snap.close = Money(Decimal("125000"))  # type: ignore[misc]
