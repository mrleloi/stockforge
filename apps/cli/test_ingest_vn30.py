"""CLI smoke tests for `apps/cli/ingest_vn30.py` (S33 Track B).

NO live API calls — adapters are monkey-patched to return recorded Bar lists.
Verifies CLI orchestration: universe resolution, per-ticker fetch + reconcile,
SQLite write, summary markdown emission.
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

import pytest
from click.testing import CliRunner

from packages.contracts import (
    AdjustmentType,
    Currency,
    Money,
    SourceProvider,
    Ticker,
)
from packages.domain.market_data.models import Bar


def _bar(*, ticker: str, period_end: date, source: SourceProvider, close: str = "100000") -> Bar:
    return Bar(
        ticker=Ticker(ticker),
        period_end=period_end,
        filing_date=period_end,
        ingested_at=datetime(2026, 4, 30, 12, 0, tzinfo=UTC),
        open=Money(Decimal(close), Currency.VND),
        high=Money(Decimal(close) + Decimal("500"), Currency.VND),
        low=Money(Decimal(close) - Decimal("500"), Currency.VND),
        close=Money(Decimal(close), Currency.VND),
        volume=1_000_000,
        foreign_buy=0,
        foreign_sell=0,
        adjustment_type=AdjustmentType.BOTH,
        source_provider=source,
    )


@pytest.fixture()
def stub_adapters(monkeypatch: pytest.MonkeyPatch) -> None:
    """Monkey-patch VnstockAdapter + SsiAdapter to return canned Bar lists."""
    from packages.infrastructure.market_data import SsiAdapter, VnstockAdapter

    def vnstock_fetch(_self: object, ticker: Ticker, _start: date, _end: date) -> list[Bar]:
        return [_bar(ticker=ticker.symbol, period_end=date(2026, 4, 28), source=SourceProvider.VNSTOCK)]

    def ssi_fetch(_self: object, ticker: Ticker, _start: date, _end: date) -> list[Bar]:
        return [_bar(ticker=ticker.symbol, period_end=date(2026, 4, 28), source=SourceProvider.SSI, close="100200")]

    monkeypatch.setattr(VnstockAdapter, "fetch_daily", vnstock_fetch)
    monkeypatch.setattr(SsiAdapter, "fetch_daily", ssi_fetch)
    monkeypatch.setattr(VnstockAdapter, "__post_init__", lambda _self: None)
    monkeypatch.setattr(SsiAdapter, "__post_init__", lambda _self: None)


def test_subset_run_writes_per_ticker_rows(stub_adapters: None, tmp_path: Path) -> None:  # noqa: ARG001
    from apps.cli.ingest_vn30 import main
    runner = CliRunner()
    db = tmp_path / "vn30.sqlite"
    summary = tmp_path / "summary.md"
    result = runner.invoke(
        main,
        [
            "--start", "2026-04-01",
            "--end", "2026-04-29",
            "--output", str(db),
            "--summary", str(summary),
            "--rate-limit-rps", "1000",
            "--tickers", "VHM,VIC,FPT",
        ],
        standalone_mode=False,
    )
    assert result.exit_code == 0, result.output
    assert "vn30] OK" in result.output
    assert db.exists()
    assert summary.exists()


def test_subset_run_emits_summary_markdown(stub_adapters: None, tmp_path: Path) -> None:  # noqa: ARG001
    from apps.cli.ingest_vn30 import main
    runner = CliRunner()
    db = tmp_path / "vn30.sqlite"
    summary = tmp_path / "summary.md"
    runner.invoke(
        main,
        [
            "--start", "2026-04-01",
            "--end", "2026-04-29",
            "--output", str(db),
            "--summary", str(summary),
            "--rate-limit-rps", "1000",
            "--tickers", "VHM,VIC",
        ],
        standalone_mode=False,
    )
    body = summary.read_text(encoding="utf-8")
    assert "# VN30 Reconciliation Summary" in body
    assert "VHM" in body
    assert "VIC" in body
    assert "DUAL_SOURCE" in body  # both stub adapters return rows


def test_summary_reports_dual_source_when_both_adapters_return(stub_adapters: None, tmp_path: Path) -> None:  # noqa: ARG001
    from apps.cli.ingest_vn30 import main
    runner = CliRunner()
    summary = tmp_path / "summary.md"
    runner.invoke(
        main,
        [
            "--start", "2026-04-01",
            "--end", "2026-04-29",
            "--output", str(tmp_path / "vn30.sqlite"),
            "--summary", str(summary),
            "--rate-limit-rps", "1000",
            "--tickers", "VHM",
        ],
        standalone_mode=False,
    )
    body = summary.read_text(encoding="utf-8")
    # 100000 vs 100200 = 0.2% divergence → HIGH confidence dual
    assert "100.0%" in body or "Dual-source rows: 1 (100.0%)" in body


def test_invalid_ticker_subset_raises(stub_adapters: None, tmp_path: Path) -> None:  # noqa: ARG001
    from apps.cli.ingest_vn30 import main
    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--output", str(tmp_path / "vn30.sqlite"),
            "--tickers", "VHM,XXX",  # XXX not in VN30
        ],
        standalone_mode=False,
    )
    # UsageError surfaces as non-zero exit + message in result.exception
    assert result.exit_code != 0
    exc = result.exception
    assert exc is not None
    assert "non-VN30" in str(exc)


def test_default_universe_is_30_tickers() -> None:
    from packages.domain.market_data import vn30_tickers
    assert len(vn30_tickers()) == 30
