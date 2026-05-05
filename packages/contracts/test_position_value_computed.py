"""Tests for PositionValueComputed cross-BC event."""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts import (
    Money,
    PositionValueComputed,
    Ticker,
    new_bar_id,
    new_position_id,
)


def _valid_event() -> PositionValueComputed:
    return PositionValueComputed(
        ticker=Ticker("VHM"),
        position_id=new_position_id(),
        computed_value=Money(Decimal("1500000")),
        as_of=date(2026, 4, 30),
        source_bar_id=new_bar_id(),
        computed_at=datetime.now(UTC),
    )


def test_valid_construction() -> None:
    event = _valid_event()
    assert event.ticker.symbol == "VHM"
    assert event.computed_value.amount == Decimal("1500000")


def test_frozen_raises_on_mutation() -> None:
    event = _valid_event()
    with pytest.raises((AttributeError, Exception)):
        event.ticker = Ticker("VIC")  # type: ignore[misc]


def test_hashable() -> None:
    event = _valid_event()
    s = {event}
    assert event in s


def test_invalid_ticker_type_rejected() -> None:
    with pytest.raises(TypeError):
        PositionValueComputed(
            ticker="VHM",  # type: ignore[arg-type]
            position_id=new_position_id(),
            computed_value=Money(Decimal("1500000")),
            as_of=date(2026, 4, 30),
            source_bar_id=new_bar_id(),
            computed_at=datetime.now(UTC),
        )


def test_invalid_money_type_rejected() -> None:
    with pytest.raises(TypeError):
        PositionValueComputed(
            ticker=Ticker("VHM"),
            position_id=new_position_id(),
            computed_value=Decimal("1500000"),  # type: ignore[arg-type]
            as_of=date(2026, 4, 30),
            source_bar_id=new_bar_id(),
            computed_at=datetime.now(UTC),
        )


def test_invalid_as_of_type_rejected() -> None:
    with pytest.raises(TypeError):
        PositionValueComputed(
            ticker=Ticker("VHM"),
            position_id=new_position_id(),
            computed_value=Money(Decimal("1500000")),
            as_of="2026-04-30",  # type: ignore[arg-type]
            source_bar_id=new_bar_id(),
            computed_at=datetime.now(UTC),
        )


def test_invalid_computed_at_type_rejected() -> None:
    with pytest.raises(TypeError):
        PositionValueComputed(
            ticker=Ticker("VHM"),
            position_id=new_position_id(),
            computed_value=Money(Decimal("1500000")),
            as_of=date(2026, 4, 30),
            source_bar_id=new_bar_id(),
            computed_at=date(2026, 4, 30),  # type: ignore[arg-type]
        )
