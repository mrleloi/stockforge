"""ingest_fundamentals_vn30 — Tier 1 nightly batch BC-2 Fundamental ingestion.

Iterates VN30 universe via VnstockFundamentalAdapter (VCI source) for the 3
statement types (IS / BS / CF), persists FinancialStatements to a SQLite
file, emits FinancialStatementFiled events synchronously per architecture.md
§ Event Flow Phase 2.

Per S33 carry-over guidance: vnstock VCI guest tier hard cap = 20 req/min;
default `--rate-limit-rps 0.3` with retry-once-after-30s on rate-limit errors.
Per-ticker partial-failure tolerance: a bad ticker logs + continues.

Run:
  python apps/cli/ingest_fundamentals_vn30.py --start 2024-Q1 --end 2026-Q1 \
    --output ./data/vn30-fundamentals.sqlite --rate-limit-rps 0.3
"""

from __future__ import annotations

import sys
import time
from collections.abc import Sequence
from datetime import UTC, datetime
from pathlib import Path

import click

from packages.contracts import FinancialStatementFiled, Ticker
from packages.domain.fundamental import FinancialStatement, StatementType
from packages.domain.fundamental.services import PeerService
from packages.domain.market_data import VN30_UNIVERSE, vn30_tickers

# composition-layer wiring: app glues BC-1 universe → BC-2 PeerService per
# Charter cross-BC discipline.
from packages.infrastructure.fundamental import (
    SqliteFundamentalRepository,
    VnstockFundamentalAdapter,
    VnstockFundamentalAdapterError,
)


def _ensure_utf8_stdout() -> None:
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


@click.command()
@click.option("--start", default=None, help="Start period label (informational; unused)")
@click.option("--end", default=None, help="End period label (informational; unused)")
@click.option(
    "--output",
    default="./data/vn30-fundamentals.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
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
@click.option("--summary", default=None, type=click.Path(dir_okay=False, path_type=Path))
def main(
    start: str | None,
    end: str | None,
    output: Path,
    rate_limit_rps: float,
    tickers: str | None,
    summary: Path | None,
) -> int:
    _ensure_utf8_stdout()
    _ = (start, end)  # period filtering performed adapter-side; CLI args informational
    universe = _resolve_universe(tickers)
    interval = max(1.0 / rate_limit_rps, 0.0) if rate_limit_rps > 0 else 0.0
    summary_path = summary if summary is not None else output.with_name("vn30-fundamentals-summary.md")

    click.echo(f"[ingest_fundamentals_vn30] tickers={len(universe)} output={output} rate-limit={rate_limit_rps} req/sec")

    adapter = VnstockFundamentalAdapter(rate_limit_seconds=interval)
    repo = SqliteFundamentalRepository(db_path=output)
    peer = PeerService.from_constituents(VN30_UNIVERSE)

    statements_per_ticker: dict[Ticker, list[FinancialStatement]] = {}
    events: list[FinancialStatementFiled] = []
    failures: list[tuple[Ticker, str, str]] = []

    for t in universe:
        sector = peer.get_sector(t)
        all_for_ticker: list[FinancialStatement] = []
        for st in (StatementType.IS, StatementType.BS, StatementType.CF):
            fetched = _fetch(adapter, t, st, failures)
            for s in fetched:
                if sector is not None and s.sector is None:
                    s = _attach_sector(s, sector)
                all_for_ticker.append(s)
                events.append(_to_event(s))
        statements_per_ticker[t] = all_for_ticker
        click.echo(f"[ingest_fundamentals_vn30] {t.symbol}: {len(all_for_ticker)} statements")

    written = repo.save_many_by_ticker(statements_per_ticker)
    total = sum(written.values())
    click.echo(f"[ingest_fundamentals_vn30] wrote {total} rows; total in db = {repo.count()}")
    _write_summary(summary_path, written, failures, len(events))
    click.echo(f"[ingest_fundamentals_vn30] summary written: {summary_path}")
    click.echo("[ingest_fundamentals_vn30] OK")
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
    adapter: VnstockFundamentalAdapter,
    ticker: Ticker,
    statement_type: StatementType,
    failures: list[tuple[Ticker, str, str]],
) -> list[FinancialStatement]:
    try:
        return list(adapter.fetch_statements(ticker, statement_type))
    except VnstockFundamentalAdapterError as exc:
        message = str(exc)
        if "rate limit" in message.lower():
            click.echo(f"[ingest_fundamentals_vn30] rate-limited on {ticker.symbol}; sleeping 30s + retry once", err=True)
            time.sleep(30)
            try:
                return list(adapter.fetch_statements(ticker, statement_type))
            except VnstockFundamentalAdapterError as exc2:
                message = str(exc2)
        click.echo(f"[ingest_fundamentals_vn30] FAILED on {ticker.symbol}/{statement_type.value}: {message}", err=True)
        failures.append((ticker, statement_type.value, message))
        return []


def _attach_sector(statement: FinancialStatement, sector: str) -> FinancialStatement:
    return FinancialStatement(
        ticker=statement.ticker,
        statement_type=statement.statement_type,
        period_end=statement.period_end,
        filing_date=statement.filing_date,
        ingested_at=statement.ingested_at,
        line_items=statement.line_items,
        source_provider=statement.source_provider,
        sector=sector,
        restated_at=statement.restated_at,
        fiscal_period_label=statement.fiscal_period_label,
    )


def _to_event(s: FinancialStatement) -> FinancialStatementFiled:
    return FinancialStatementFiled(
        ticker=s.ticker,
        statement_type=s.statement_type.value,
        period_end=s.period_end,
        filing_date=s.filing_date,
        source_provider=s.source_provider,
        emitted_at=datetime.now(UTC),
    )


def _write_summary(
    path: Path,
    written: dict[Ticker, int],
    failures: list[tuple[Ticker, str, str]],
    event_count: int,
) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines: list[str] = [
        "# VN30 Fundamentals Ingestion Summary",
        "",
        f"**Tickers ingested**: {len(written)} / 30",
        f"**Total rows written**: {sum(written.values())}",
        f"**Events emitted**: {event_count}",
        "",
        "## Per-ticker outcome",
        "",
        "| Ticker | rows_written |",
        "|---|---|",
    ]
    for ticker, n in written.items():
        lines.append(f"| {ticker.symbol} | {n} |")
    if failures:
        lines += ["", "## Failures", ""]
        for t, st, msg in failures:
            lines.append(f"- **{t.symbol}** [{st}]: {msg}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main(standalone_mode=False) or 0)
