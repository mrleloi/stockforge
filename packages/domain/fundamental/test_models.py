"""FinancialStatement entity invariant tests (S34 Track C)."""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental import (
    FinancialStatement,
    FinancialStatementInvariantError,
    LineItemKey,
    StatementType,
)


def _line_items(currency: Currency = Currency.VND) -> dict[str, Money]:
    return {
        LineItemKey.REVENUE.value: Money(Decimal("1000000000"), currency),
        LineItemKey.NET_INCOME.value: Money(Decimal("100000000"), currency),
    }


def _stmt(**overrides: object) -> FinancialStatement:
    base: dict[str, object] = dict(
        ticker=Ticker("VHM"),
        statement_type=StatementType.IS,
        period_end=date(2026, 3, 31),
        filing_date=date(2026, 4, 30),
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        line_items=_line_items(),
        source_provider=SourceProvider.VNSTOCK,
    )
    base.update(overrides)
    return FinancialStatement(**base)  # type: ignore[arg-type]


def test_valid_statement_constructs_cleanly() -> None:
    s = _stmt()
    assert s.ticker.symbol == "VHM"
    assert s.statement_type == StatementType.IS
    assert s.currency == Currency.VND


def test_period_end_in_future_rejected() -> None:
    with pytest.raises(FinancialStatementInvariantError, match="look-ahead"):
        _stmt(period_end=date(2099, 1, 1), filing_date=date(2099, 1, 31))


def test_filing_date_before_period_end_rejected() -> None:
    with pytest.raises(FinancialStatementInvariantError, match="filing.*precede"):
        _stmt(filing_date=date(2026, 3, 1), period_end=date(2026, 3, 31))


def test_ingested_before_filing_date_rejected() -> None:
    with pytest.raises(FinancialStatementInvariantError, match="ingestion.*precede"):
        _stmt(ingested_at=datetime(2026, 4, 1, 12, 0, tzinfo=UTC))


def test_empty_line_items_rejected() -> None:
    with pytest.raises(FinancialStatementInvariantError, match="empty line_items"):
        _stmt(line_items={})


def test_mixed_currency_line_items_rejected() -> None:
    items = _line_items()
    items[LineItemKey.NET_INCOME.value] = Money(Decimal("1000"), Currency.USD)
    with pytest.raises(FinancialStatementInvariantError, match="currency mismatch"):
        _stmt(line_items=items)


def test_get_line_item_accepts_enum_or_string() -> None:
    s = _stmt()
    assert s.get_line_item(LineItemKey.REVENUE) == Money(Decimal("1000000000"), Currency.VND)
    assert s.get_line_item("revenue") == Money(Decimal("1000000000"), Currency.VND)
    assert s.get_line_item(LineItemKey.EPS) is None


def test_has_line_items_predicate() -> None:
    s = _stmt()
    assert s.has_line_items(LineItemKey.REVENUE, LineItemKey.NET_INCOME)
    assert not s.has_line_items(LineItemKey.EPS)


def test_balance_sheet_constructs_with_bs_line_items() -> None:
    s = _stmt(
        statement_type=StatementType.BS,
        line_items={
            LineItemKey.TOTAL_ASSETS.value: Money(Decimal("5000000000"), Currency.VND),
            LineItemKey.TOTAL_EQUITY.value: Money(Decimal("3000000000"), Currency.VND),
            LineItemKey.TOTAL_LIABILITIES.value: Money(Decimal("2000000000"), Currency.VND),
        },
    )
    assert s.statement_type == StatementType.BS
    assert s.has_line_items(LineItemKey.TOTAL_ASSETS, LineItemKey.TOTAL_EQUITY)
