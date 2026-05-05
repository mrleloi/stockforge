"""CLI smoke tests for `apps/cli/ingest_fundamentals_vn30.py` (S34 Track C)."""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

import pytest
from click.testing import CliRunner

from packages.contracts import Currency, Money, SourceProvider, Ticker
from packages.domain.fundamental import FinancialStatement, LineItemKey, StatementType


def _stmt(*, ticker: str, statement_type: StatementType) -> FinancialStatement:
    return FinancialStatement(
        ticker=Ticker(ticker),
        statement_type=statement_type,
        period_end=date(2026, 3, 31),
        filing_date=date(2026, 4, 30),
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        line_items={LineItemKey.REVENUE.value: Money(Decimal("1000000000"), Currency.VND)},
        source_provider=SourceProvider.VNSTOCK,
    )


@pytest.fixture()
def stub_adapter(monkeypatch: pytest.MonkeyPatch) -> None:
    from packages.infrastructure.fundamental import VnstockFundamentalAdapter

    def fetch(_self: object, ticker: Ticker, statement_type: StatementType, period: str = "quarter") -> list[FinancialStatement]:
        _ = period
        return [_stmt(ticker=ticker.symbol, statement_type=statement_type)]

    monkeypatch.setattr(VnstockFundamentalAdapter, "fetch_statements", fetch)
    monkeypatch.setattr(VnstockFundamentalAdapter, "__post_init__", lambda _self: None)


def test_subset_run_writes_per_ticker_rows(tmp_path: Path, stub_adapter: None) -> None:
    _ = stub_adapter
    from apps.cli.ingest_fundamentals_vn30 import main
    runner = CliRunner()
    output = tmp_path / "fund.sqlite"
    summary = tmp_path / "summary.md"
    result = runner.invoke(
        main,
        ["--tickers", "VHM,FPT", "--output", str(output), "--summary", str(summary), "--rate-limit-rps", "0"],
        standalone_mode=False,
    )
    assert result.exit_code == 0, result.output
    # Each ticker × 3 statement types = 6 rows
    from packages.infrastructure.fundamental import SqliteFundamentalRepository
    repo = SqliteFundamentalRepository(db_path=output)
    assert repo.count() == 6
    assert summary.exists()


def test_invalid_ticker_subset_raises(tmp_path: Path, stub_adapter: None) -> None:
    _ = stub_adapter
    from apps.cli.ingest_fundamentals_vn30 import main
    runner = CliRunner()
    result = runner.invoke(
        main,
        ["--tickers", "ZZZ", "--output", str(tmp_path / "x.sqlite"), "--rate-limit-rps", "0"],
        standalone_mode=False,
    )
    # UsageError raised; CliRunner returns exit_code 2
    assert result.exit_code != 0


def test_default_universe_resolves_to_30(stub_adapter: None) -> None:
    _ = stub_adapter
    from apps.cli.ingest_fundamentals_vn30 import _resolve_universe
    universe = _resolve_universe(None)
    assert len(universe) == 30
