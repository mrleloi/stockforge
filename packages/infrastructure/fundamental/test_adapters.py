"""BC-2 infrastructure tests (S34 Track C). Fixture-based — no live API."""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

import pytest

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental import (
    FinancialStatement,
    LineItemKey,
    StatementType,
)
from packages.infrastructure.fundamental import (
    SqliteFundamentalRepository,
    VnstockFundamentalAdapter,
    VnstockFundamentalAdapterError,
)


def _stmt(
    *,
    ticker: str = "VHM",
    statement_type: StatementType = StatementType.IS,
    period_end: date = date(2026, 3, 31),
    filing_date: date | None = None,
    line_items: dict[str, Money] | None = None,
    source: SourceProvider = SourceProvider.VNSTOCK,
) -> FinancialStatement:
    return FinancialStatement(
        ticker=Ticker(ticker),
        statement_type=statement_type,
        period_end=period_end,
        filing_date=filing_date or period_end,
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        line_items=line_items or {
            LineItemKey.REVENUE.value: Money(Decimal("1000000000"), Currency.VND),
            LineItemKey.NET_INCOME.value: Money(Decimal("100000000"), Currency.VND),
        },
        source_provider=source,
    )


class _FakeDataFrame:
    def __init__(self, rows: list[dict[str, object]]) -> None:
        self.rows = rows
        self.columns = list(rows[0].keys()) if rows else []

    def iterrows(self) -> object:
        return iter([(i, r) for i, r in enumerate(self.rows)])


# ---------------------------------------------------------------------------
# VnstockFundamentalAdapter


def test_vnstock_adapter_maps_canonical_line_items() -> None:
    rows: list[dict[str, object]] = [
        {
            "period_end": "2026-03-31",
            "Revenue": "1000000000",
            "Net Profit For the Year": "100000000",
            "EPS": "5000",
        }
    ]

    def fetch(*, symbol: str, statement: str, period: str) -> object:
        _ = (symbol, statement, period)
        return _FakeDataFrame(rows)

    adapter = VnstockFundamentalAdapter(finance_fetch_fn=fetch, rate_limit_seconds=0.0)
    out = adapter.fetch_statements(Ticker("VHM"), StatementType.IS)
    assert len(out) == 1
    assert out[0].get_line_item(LineItemKey.REVENUE) == Money(Decimal("1000000000"), Currency.VND)
    assert out[0].get_line_item(LineItemKey.NET_INCOME) == Money(Decimal("100000000"), Currency.VND)
    assert out[0].get_line_item(LineItemKey.EPS) == Money(Decimal("5000"), Currency.VND)


def test_vnstock_adapter_skips_future_period() -> None:
    rows: list[dict[str, object]] = [{"period_end": "2099-12-31", "Revenue": "100"}]

    def fetch(*, symbol: str, statement: str, period: str) -> object:
        _ = (symbol, statement, period)
        return _FakeDataFrame(rows)

    adapter = VnstockFundamentalAdapter(finance_fetch_fn=fetch, rate_limit_seconds=0.0)
    out = adapter.fetch_statements(Ticker("VHM"), StatementType.IS)
    assert out == []


def test_vnstock_adapter_skips_row_without_canonical_keys() -> None:
    rows: list[dict[str, object]] = [{"period_end": "2026-03-31", "OtherRandomField": "999"}]

    def fetch(*, symbol: str, statement: str, period: str) -> object:
        _ = (symbol, statement, period)
        return _FakeDataFrame(rows)

    adapter = VnstockFundamentalAdapter(finance_fetch_fn=fetch, rate_limit_seconds=0.0)
    out = adapter.fetch_statements(Ticker("VHM"), StatementType.IS)
    assert out == []


def test_vnstock_adapter_unexpected_payload_raises() -> None:
    def fetch(*, symbol: str, statement: str, period: str) -> object:
        _ = (symbol, statement, period)
        return 42

    adapter = VnstockFundamentalAdapter(finance_fetch_fn=fetch, rate_limit_seconds=0.0)
    with pytest.raises(VnstockFundamentalAdapterError, match="unexpected"):
        adapter.fetch_statements(Ticker("VHM"), StatementType.IS)


def test_vnstock_adapter_balance_sheet_maps_total_assets() -> None:
    rows: list[dict[str, object]] = [
        {
            "period_end": "2026-03-31",
            "Total Assets": "5000000000",
            "Total equity": "3000000000",
            "Total liabilities": "2000000000",
        }
    ]

    def fetch(*, symbol: str, statement: str, period: str) -> object:
        _ = (symbol, statement, period)
        return _FakeDataFrame(rows)

    adapter = VnstockFundamentalAdapter(finance_fetch_fn=fetch, rate_limit_seconds=0.0)
    out = adapter.fetch_statements(Ticker("VHM"), StatementType.BS)
    assert out[0].get_line_item(LineItemKey.TOTAL_ASSETS) == Money(Decimal("5000000000"), Currency.VND)


# ---------------------------------------------------------------------------
# SqliteFundamentalRepository


def test_sqlite_repo_save_and_get_latest(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    s = _stmt()
    n = repo.save_many([s])
    assert n == 1
    latest = repo.get_latest(Ticker("VHM"))
    assert latest is not None
    assert latest.ticker == Ticker("VHM")
    assert latest.statement_type == StatementType.IS
    assert latest.get_line_item(LineItemKey.REVENUE) == Money(Decimal("1000000000"), Currency.VND)


def test_sqlite_repo_get_as_of_filters_by_filing_date(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    s_old = _stmt(period_end=date(2025, 12, 31), filing_date=date(2026, 1, 31))
    s_new = _stmt(period_end=date(2026, 3, 31), filing_date=date(2026, 4, 30))
    repo.save_many([s_old, s_new])

    # As of 2026-02-01: only the older statement should be visible.
    visible = repo.get_as_of(Ticker("VHM"), date(2026, 2, 1))
    assert len(visible) == 1
    assert visible[0].period_end == date(2025, 12, 31)


def test_sqlite_repo_point_in_time_zero_lookahead(tmp_path: Path) -> None:
    """Critical: get_as_of(ticker, 2025-06-15) MUST exclude filings with
    filing_date > 2025-06-15. Master-plan 005 § S34 success criterion #3.
    """
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    repo.save_many([
        _stmt(period_end=date(2025, 3, 31), filing_date=date(2025, 4, 30)),
        _stmt(period_end=date(2025, 6, 30), filing_date=date(2025, 7, 30)),
    ])
    visible = repo.get_as_of(Ticker("VHM"), date(2025, 6, 15))
    assert all(s.filing_date <= date(2025, 6, 15) for s in visible)
    assert len(visible) == 1


def test_sqlite_repo_get_as_of_with_statement_type_filter(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    repo.save_many([
        _stmt(statement_type=StatementType.IS),
        _stmt(statement_type=StatementType.BS,
              line_items={LineItemKey.TOTAL_EQUITY.value: Money(Decimal("3000000000"), Currency.VND)}),
    ])
    only_is = repo.get_as_of(Ticker("VHM"), date(2026, 5, 31), statement_type=StatementType.IS)
    assert len(only_is) == 1
    assert only_is[0].statement_type == StatementType.IS


def test_sqlite_repo_save_many_by_ticker_partial_failure(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    by_ticker: dict[Ticker, list[FinancialStatement]] = {
        Ticker("VHM"): [_stmt(ticker="VHM")],
        Ticker("FPT"): [_stmt(ticker="FPT")],
    }
    out = repo.save_many_by_ticker(by_ticker)
    assert out[Ticker("VHM")] == 1
    assert out[Ticker("FPT")] == 1
    assert repo.count() == 2


def test_sqlite_repo_idempotent_replace(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    s = _stmt()
    repo.save_many([s])
    repo.save_many([s])
    assert repo.count() == 1


def test_sqlite_repo_count_for_ticker(tmp_path: Path) -> None:
    repo = SqliteFundamentalRepository(db_path=tmp_path / "f.sqlite")
    repo.save_many([
        _stmt(ticker="VHM"),
        _stmt(ticker="VHM", statement_type=StatementType.BS,
              line_items={LineItemKey.TOTAL_EQUITY.value: Money(Decimal("3"), Currency.VND)}),
        _stmt(ticker="FPT"),
    ])
    assert repo.count_for(Ticker("VHM")) == 2
    assert repo.count_for(Ticker("FPT")) == 1
