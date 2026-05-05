"""BC-2 value object tests (S34 Track C)."""

from __future__ import annotations

from datetime import date
from decimal import Decimal

import pytest

from packages.contracts import Ticker
from packages.domain.fundamental import (
    LineItemKey,
    Ratio,
    RatioName,
    StatementType,
    line_item_required_for_ratio,
)


def test_statement_type_serializes_lowercase() -> None:
    assert StatementType.IS.value == "is"
    assert StatementType.BS.value == "bs"
    assert StatementType.CF.value == "cf"


def test_line_item_required_for_ratio_table_complete() -> None:
    for ratio in ("PE", "PB", "ROE", "ROA", "DEBT_EQUITY", "NET_MARGIN"):
        keys = line_item_required_for_ratio(ratio)
        assert keys, f"{ratio} has no required keys"
        for k in keys:
            assert isinstance(k, LineItemKey)


def test_line_item_required_for_unknown_ratio_returns_empty() -> None:
    assert line_item_required_for_ratio("UNKNOWN") == ()


def test_ratio_constructs_with_all_fields() -> None:
    r = Ratio(
        name=RatioName.PE,
        value=Decimal("18.5"),
        ticker=Ticker("VHM"),
        period_end=date(2026, 3, 31),
        formula_audit="price_per_share / eps_ttm — Damodaran",
        computed_from=(StatementType.IS,),
    )
    assert r.value == Decimal("18.5")
    assert r.computed_from == (StatementType.IS,)


def test_ratio_rejects_empty_formula_audit() -> None:
    with pytest.raises(ValueError, match="formula_audit"):
        Ratio(
            name=RatioName.PE, value=Decimal("18"), ticker=Ticker("VHM"),
            period_end=date(2026, 3, 31), formula_audit="   ",
            computed_from=(StatementType.IS,),
        )


def test_ratio_rejects_empty_computed_from() -> None:
    with pytest.raises(ValueError, match="computed_from"):
        Ratio(
            name=RatioName.PE, value=Decimal("18"), ticker=Ticker("VHM"),
            period_end=date(2026, 3, 31), formula_audit="ok",
            computed_from=(),
        )


def test_ratio_value_coerced_to_decimal() -> None:
    r = Ratio(
        name=RatioName.ROE, value=Decimal("0.15"), ticker=Ticker("FPT"),
        period_end=date(2026, 3, 31),
        formula_audit="net_income_ttm / equity",
        computed_from=(StatementType.IS, StatementType.BS),
    )
    assert isinstance(r.value, Decimal)
