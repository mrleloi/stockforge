"""ingest_vhm — Tier 1 thin-slice ingestion driver for VHM (Phase 1 exemplar).

Orchestrates VnstockAdapter (VCI) + SsiAdapter (iBoard) via
ReconciliationService, persists the union of source Bars via
SqliteBarRepository, and emits a reconciliation report markdown.

Per S32 Track A R2 closure (D-012): TCBS public REST endpoints returned 404
across all probed variants; SSI iBoard chart-history is the primary alternate
source paired with VCI for Rule 4 multi-source reconciliation. TcbsAdapter
remains wired in graceful-fail mode for archive symmetry — invoked but
expected to raise; reconciliation simply ignores its empty output.

Run: `python apps/cli/ingest_vhm.py --start 2025-04-30 --end 2026-04-29`.
"""

from __future__ import annotations

import sys
from datetime import date, timedelta
from pathlib import Path

import click

from packages.contracts import Ticker
from packages.infrastructure.market_data import (
    ReconciledBar,
    ReconciliationConfidence,
    ReconciliationService,
    SqliteBarRepository,
    SsiAdapter,
    SsiApiError,
    TcbsAdapter,
    TcbsApiError,
    VnstockAdapter,
    VnstockAdapterError,
)


def _ensure_utf8_stdout() -> None:
    """Reconfigure stdout to UTF-8 so vnstock's Vietnamese banner does not
    UnicodeEncodeError under Windows cp1252. Called from `main` before the
    first VnstockAdapter construction (which lazily imports vnstock).
    """
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


@click.command()
@click.option("--ticker", default="VHM", show_default=True)
@click.option("--start", default=None, help="ISO date; default = end - 365 days")
@click.option("--end", default=None, help="ISO date; default = today")
@click.option(
    "--output",
    default="./data/vhm.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
)
@click.option("--report", default=None, type=click.Path(dir_okay=False, path_type=Path))
def main(ticker: str, start: str | None, end: str | None, output: Path, report: Path | None) -> int:
    """Ingest a year of VHM (default) DAILY bars; reconcile vnstock vs TCBS."""
    _ensure_utf8_stdout()
    end_date = date.fromisoformat(end) if end else date.today()
    start_date = date.fromisoformat(start) if start else end_date - timedelta(days=365)
    report_path = report if report is not None else output.with_name(output.stem + "-reconciliation.md")
    t = Ticker(ticker)

    click.echo(f"[ingest_vhm] ticker={t.symbol} window={start_date}..{end_date}")
    click.echo(f"[ingest_vhm] output={output} report={report_path}")

    vnstock_adapter = VnstockAdapter()
    ssi_adapter = SsiAdapter()
    tcbs_adapter = TcbsAdapter()
    reconciler = ReconciliationService()
    repo = SqliteBarRepository(db_path=output)

    try:
        vnstock_bars = vnstock_adapter.fetch_daily(t, start_date, end_date)
        click.echo(f"[ingest_vhm] vnstock returned {len(vnstock_bars)} bars")
    except VnstockAdapterError as exc:
        click.echo(f"[ingest_vhm] vnstock FAILED: {exc}", err=True)
        return 2

    try:
        ssi_bars = ssi_adapter.fetch_daily(t, start_date, end_date)
        click.echo(f"[ingest_vhm] ssi returned {len(ssi_bars)} bars")
    except SsiApiError as exc:
        click.echo(f"[ingest_vhm] ssi unavailable: {exc}", err=True)
        ssi_bars = []

    try:
        tcbs_bars = tcbs_adapter.fetch_daily(t, start_date, end_date)
        click.echo(f"[ingest_vhm] tcbs returned {len(tcbs_bars)} bars")
    except TcbsApiError as exc:
        click.echo(f"[ingest_vhm] tcbs unavailable (expected per D-012): {exc}", err=True)
        tcbs_bars = []

    written = repo.save_many(list(vnstock_bars) + list(ssi_bars) + list(tcbs_bars))
    click.echo(f"[ingest_vhm] wrote {written} rows; total in db = {repo.count()}")

    reconciled = reconciler.reconcile(vnstock_bars, ssi_bars)
    _write_report(report_path, t, start_date, end_date, reconciled)
    click.echo(f"[ingest_vhm] reconciliation report written: {report_path}")
    click.echo("[ingest_vhm] OK")
    return 0


def _write_report(
    path: Path,
    ticker: Ticker,
    start: date,
    end: date,
    rows: list[ReconciledBar],
) -> None:
    high = sum(1 for r in rows if r.confidence == ReconciliationConfidence.HIGH)
    low = sum(1 for r in rows if r.confidence == ReconciliationConfidence.LOW)
    single = sum(1 for r in rows if r.confidence == ReconciliationConfidence.SINGLE_SOURCE)
    path.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = [
        f"# Reconciliation Report — {ticker.symbol}",
        "",
        f"**Window**: {start} → {end}",
        f"**Total rows**: {len(rows)}",
        f"- HIGH (within 1%): {high}",
        f"- LOW (>1% divergence): {low}",
        f"- SINGLE_SOURCE: {single}",
        "",
        "## Sample divergences (LOW)",
        "",
    ]
    samples = [r for r in rows if r.confidence == ReconciliationConfidence.LOW][:5]
    if not samples:
        lines.append("(none)")
    else:
        for r in samples:
            closes = {k.value: str(v.amount) for k, v in r.close_by_source.items()}
            lines.append(f"- {r.period_end}: divergence={r.divergence_pct} closes={closes}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main(standalone_mode=False) or 0)
