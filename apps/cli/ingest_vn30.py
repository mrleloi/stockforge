"""ingest_vn30 — Tier 1 nightly batch ingestion for the VN30 universe (S33).

Scales `apps/cli/ingest_vhm.py` (1 ticker thin slice) to all 30 VN30
constituents via VnstockAdapter (VCI source) + SsiAdapter (iBoard source)
per D-012 strategy A3. TcbsAdapter is intentionally NOT wired here:
S32 D-012 retired TCBS to graceful-fail archive only; including it in a
30-ticker loop adds 30 expected-failure round-trips with no signal value.

Per S32 carry-over guidance:
- VCI guest tier hard cap = 20 req/min (3 sec/req); default `--rate-limit-rps 0.3`
  with retry-once-after-30s on `Rate Limit Exceeded`
- SSI iBoard rate limit not advertised; observed clean at 0.3 RPS over 30
  tickers; same default RPS keeps the two paths in lockstep
- Per-ticker partial-failure tolerance: a bad ticker logs + continues; the
  reconciliation summary records per-ticker outcome

Run: `python apps/cli/ingest_vn30.py --start 2025-04-30 --end 2026-04-29 \
    --output ./data/vn30.sqlite --rate-limit-rps 0.3`
"""

from __future__ import annotations

import sys
import time
from collections.abc import Sequence
from datetime import date, timedelta
from pathlib import Path

import click

from packages.contracts import SourceProvider, Ticker
from packages.domain.market_data import VN30_UNIVERSE, vn30_tickers
from packages.domain.market_data.models import Bar
from packages.infrastructure.market_data import (
    ReconciledBar,
    ReconciliationConfidence,
    ReconciliationService,
    SqliteBarRepository,
    SsiAdapter,
    SsiApiError,
    VnstockAdapter,
    VnstockAdapterError,
)


def _ensure_utf8_stdout() -> None:
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


@click.command()
@click.option("--start", default=None, help="ISO date; default = end - 365 days")
@click.option("--end", default=None, help="ISO date; default = today")
@click.option(
    "--output",
    default="./data/vn30.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
)
@click.option(
    "--summary",
    default=None,
    type=click.Path(dir_okay=False, path_type=Path),
    help="Reconciliation summary markdown path; default = output sibling",
)
@click.option(
    "--rate-limit-rps",
    default=0.3,
    show_default=True,
    type=float,
    help="Requests per second per provider (VCI guest tier cap = ~0.33)",
)
@click.option(
    "--tickers",
    default=None,
    help="Comma-separated subset of VN30 to ingest (default = all 30)",
)
def main(
    start: str | None,
    end: str | None,
    output: Path,
    summary: Path | None,
    rate_limit_rps: float,
    tickers: str | None,
) -> int:
    _ensure_utf8_stdout()
    end_date = date.fromisoformat(end) if end else date.today()
    start_date = date.fromisoformat(start) if start else end_date - timedelta(days=365)
    summary_path = summary if summary is not None else output.with_name("vn30-reconciliation-summary.md")
    universe = _resolve_universe(tickers)
    interval = max(1.0 / rate_limit_rps, 0.0) if rate_limit_rps > 0 else 0.0

    click.echo(f"[ingest_vn30] window={start_date}..{end_date} tickers={len(universe)}")
    click.echo(f"[ingest_vn30] output={output} summary={summary_path} rate-limit={rate_limit_rps} req/sec")

    vnstock_adapter = VnstockAdapter(rate_limit_seconds=interval)
    ssi_adapter = SsiAdapter(rate_limit_seconds=interval)
    reconciler = ReconciliationService()
    repo = SqliteBarRepository(db_path=output)

    rows_per_ticker: dict[Ticker, list[ReconciledBar]] = {}
    bars_per_ticker: dict[Ticker, list[Bar]] = {}
    failures: list[tuple[Ticker, str, str]] = []

    for t in universe:
        vci = _fetch(vnstock_adapter, t, start_date, end_date, "vnstock", failures)
        ssi = _fetch(ssi_adapter, t, start_date, end_date, "ssi", failures)
        bars_per_ticker[t] = list(vci) + list(ssi)
        rows_per_ticker[t] = reconciler.reconcile(list(vci), list(ssi))
        click.echo(f"[ingest_vn30] {t.symbol}: vnstock={len(vci)} ssi={len(ssi)} reconciled={len(rows_per_ticker[t])}")

    written = repo.save_many_by_ticker(bars_per_ticker)
    total_written = sum(written.values())
    click.echo(f"[ingest_vn30] wrote {total_written} rows across {len(written)} tickers; total in db = {repo.count()}")

    _write_summary(summary_path, start_date, end_date, rows_per_ticker, written, failures)
    click.echo(f"[ingest_vn30] reconciliation summary written: {summary_path}")
    click.echo("[ingest_vn30] OK")
    return 0


def _resolve_universe(subset: str | None) -> Sequence[Ticker]:
    if subset is None:
        return vn30_tickers()
    requested = [Ticker(s.strip()) for s in subset.split(",") if s.strip()]
    valid = {c.ticker.symbol for c in VN30_UNIVERSE}
    invalid = [t.symbol for t in requested if t.symbol not in valid]
    if invalid:
        raise click.UsageError(f"--tickers contains non-VN30 entries: {invalid}")
    return requested


def _fetch(
    adapter: VnstockAdapter | SsiAdapter,
    ticker: Ticker,
    start: date,
    end: date,
    label: str,
    failures: list[tuple[Ticker, str, str]],
) -> list[Bar]:
    try:
        return list(adapter.fetch_daily(ticker, start, end))
    except (VnstockAdapterError, SsiApiError) as exc:
        message = str(exc)
        if "rate limit" in message.lower() or "rate_limit" in message.lower():
            click.echo(f"[ingest_vn30] {label} rate-limited on {ticker.symbol}; sleeping 30s + retry once", err=True)
            time.sleep(30)
            try:
                return list(adapter.fetch_daily(ticker, start, end))
            except (VnstockAdapterError, SsiApiError) as exc2:
                message = str(exc2)
        click.echo(f"[ingest_vn30] {label} FAILED on {ticker.symbol}: {message}", err=True)
        failures.append((ticker, label, message))
        return []


def _write_summary(
    path: Path,
    start: date,
    end: date,
    rows_per_ticker: dict[Ticker, list[ReconciledBar]],
    written_per_ticker: dict[Ticker, int],
    failures: list[tuple[Ticker, str, str]],
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    total_rows = sum(len(r) for r in rows_per_ticker.values())
    dual = sum(
        1 for rows in rows_per_ticker.values() for r in rows
        if r.confidence in (ReconciliationConfidence.HIGH, ReconciliationConfidence.LOW)
    )
    dual_pct = (dual / total_rows * 100) if total_rows else 0.0

    lines: list[str] = [
        "# VN30 Reconciliation Summary",
        "",
        f"**Window**: {start} → {end}",
        f"**Tickers ingested**: {len(rows_per_ticker)} / 30",
        f"**Total reconciled rows**: {total_rows}",
        f"**Dual-source rows**: {dual} ({dual_pct:.1f}%)",
        "",
        "## Per-ticker outcome",
        "",
        "| Ticker | rows_written | vnstock_rows | ssi_rows | dual | low | single | confidence |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for ticker, rows in rows_per_ticker.items():
        n_dual = sum(1 for r in rows if r.confidence == ReconciliationConfidence.HIGH)
        n_low = sum(1 for r in rows if r.confidence == ReconciliationConfidence.LOW)
        n_single = sum(1 for r in rows if r.confidence == ReconciliationConfidence.SINGLE_SOURCE)
        vci_count = sum(1 for r in rows if SourceProvider.VNSTOCK in r.sources_present)
        ssi_count = sum(1 for r in rows if SourceProvider.SSI in r.sources_present)
        verdict = "DUAL_SOURCE" if (n_dual + n_low) >= n_single else "SINGLE_SOURCE"
        lines.append(
            f"| {ticker.symbol} | {written_per_ticker.get(ticker, 0)} | {vci_count} | {ssi_count} "
            f"| {n_dual} | {n_low} | {n_single} | {verdict} |"
        )
    if failures:
        lines += ["", "## Failures", ""]
        for t, lbl, msg in failures:
            lines.append(f"- **{t.symbol}** [{lbl}]: {msg}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main(standalone_mode=False) or 0)
