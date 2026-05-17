"""ingest_pdf_fundamentals — CLI for VHM annual-report PDF dogfood (Phase G.4).

Drives a PDF through the G.3 ClaudeVisionPdfTableExtractor + EchoValidator gate
→ deterministic cell-label→LineItemKey mapper → FinancialStatement construction
→ SqliteFundamentalRepository persistence → RatioService smoke → thesis-log artifact.

V0 scope (per plan-044 § A):
  - Single-adapter: claude-vision (G.3; G.2 BLOCKED per RM3)
  - Single-ticker: VHM (default)
  - Single-statement-type: IS (Income Statement)
  - ADDITIVE-ONLY schema posture (DD-3: ZERO FinancialStatement migration)

Exit codes (per validate_thesis.py:7-11 precedent):
  0 = success
  1 = CostBudgetExceeded (--cost-ceiling-usd hard cap)
  2 = EchoValidationError (Rule 16 mode #2 HARD ERROR)
  3 = PdfMapperError (RequiredCellMissingError or other mapper failure)
  4 = VisionExtractionError (claude CLI vision failure)

Usage:
    python apps/cli/ingest_pdf_fundamentals.py \\
        --ticker VHM \\
        --pdf-path tests/fixtures/pdf/vhm-2023-annual.pdf \\
        --filing-date 2024-03-31 \\
        --period-end 2023-12-31 \\
        --source-url https://ir.vinhomes.vn/bao-cao-thuong-nien/2023 \\
        --db data/stockforge.sqlite \\
        --output-dir agent-workspace/thesis-log/

I-S35: Every output markdown includes disclaimer footer.
D-050: ZERO import anthropic (uses G.3 claude_cli_transport substrate transitively).
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from datetime import UTC, datetime
from datetime import date as date_type
from decimal import Decimal
from pathlib import Path

import click

from apps.cli._pdf_cell_mapper import (
    PdfMapperError,
    RequiredCellMissingError,
    map_extracted_to_financial_statement,
)
from packages.application.fundamental.echo_validator import EchoValidationError
from packages.application.fundamental.pdf_source import PdfSource, PdfSourceInvariantError
from packages.contracts import SourceProvider, Ticker
from packages.domain.fundamental.models.financial_statement import FinancialStatement
from packages.domain.fundamental.services.ratio_service import (
    RatioComputationError,
    RatioService,
)
from packages.domain.fundamental.value_objects import StatementType

# Lazily import ClaudeVisionPdfTableExtractor to avoid import chain at module load
# (mirrors apps/cli/ingest_fundamentals_vn30.py lazy-import pattern)
from packages.infrastructure.fundamental.claude_vision_pdf_adapter import (
    ClaudeVisionPdfTableExtractor,
    CostBudgetExceeded,
    VisionExtractionError,
)
from packages.infrastructure.fundamental.sqlite_fundamental_repository import (
    SqliteFundamentalRepository,
)

_DISCLAIMER_MD = (
    "\n---\n\n"
    "> **Disclaimer (I-S35)**: This is a research aid, not financial advice. "
    "Decisions and responsibility are yours. "
    "Numbers come from deterministic code; narrative from LLM interpretation. "
    "Past performance does not predict future results. "
    "Calibration grade: D (Phase G-prime V0 — no calibration data yet; "
    "CODE-READY-DATA-PENDING per plan-044 § H.3).\n"
)


def _ensure_utf8() -> None:
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


@click.command()
@click.option("--ticker", default="VHM", show_default=True, help="VN stock ticker symbol")
@click.option(
    "--pdf-path",
    default="tests/fixtures/pdf/vhm-2023-annual.pdf",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
    help="Path to the annual-report PDF (D-064 path-safety validated)",
)
@click.option(
    "--statement-type",
    default="is",
    show_default=True,
    type=click.Choice(["is", "bs", "cf"], case_sensitive=False),
    help="Statement type: is (Income Statement), bs (Balance Sheet), cf (Cash Flow). V0=IS only.",
)
@click.option(
    "--filing-date",
    required=True,
    type=click.DateTime(formats=["%Y-%m-%d"]),
    help="Report filing date (YYYY-MM-DD; must be >= period-end per Rule 1)",
)
@click.option(
    "--period-end",
    required=True,
    type=click.DateTime(formats=["%Y-%m-%d"]),
    help="Financial period end date (YYYY-MM-DD; e.g. 2023-12-31)",
)
@click.option(
    "--source-url",
    required=True,
    help="Public HTTP(S) URL of the source PDF (I-S2 citation; I-S34 public sources only)",
)
@click.option(
    "--cost-ceiling-usd",
    default="0.50",
    show_default=True,
    help="Per-call cost ceiling in USD (DD-5; raises CostBudgetExceeded on exceed)",
)
@click.option(
    "--total-budget-usd",
    default="5.00",
    show_default=True,
    help="Total run budget in USD hard cap (covers IS V0; ~3-10 calls estimate)",
)
@click.option(
    "--db",
    default="data/stockforge.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
    help="SQLite database path (SqliteFundamentalRepository target)",
)
@click.option(
    "--output-dir",
    default="agent-workspace/thesis-log/",
    show_default=True,
    type=click.Path(file_okay=False, path_type=Path),
    help="Directory where thesis-log artifact is written (DD-7)",
)
@click.option(
    "--sector",
    default=None,
    help="Optional sector string (e.g. 'Real Estate'); populates FinancialStatement.sector",
)
def main(
    ticker: str,
    pdf_path: Path,
    statement_type: str,
    filing_date: datetime,
    period_end: datetime,
    source_url: str,
    cost_ceiling_usd: str,
    total_budget_usd: str,
    db: Path,
    output_dir: Path,
    sector: str | None,
) -> None:
    """Ingest a PDF annual-report through G.3 ClaudeVisionPdfTableExtractor into BC-2 SQLite."""
    _ensure_utf8()

    ticker_upper = ticker.strip().upper()
    filing_date_d: date_type = filing_date.date()
    period_end_d: date_type = period_end.date()
    cost_ceiling = Decimal(cost_ceiling_usd)
    total_budget = Decimal(total_budget_usd)
    stmt_type = StatementType(statement_type.lower())

    click.echo(
        f"[ingest_pdf_fundamentals] ticker={ticker_upper} "
        f"pdf={pdf_path} stmt_type={stmt_type.value} "
        f"period_end={period_end_d} filing_date={filing_date_d} "
        f"cost_ceiling=${cost_ceiling} total_budget=${total_budget} "
        f"db={db}"
    )

    # Pre-flight: total budget check (before any LLM call)
    if cost_ceiling > total_budget:
        click.echo(
            f"[ingest_pdf_fundamentals] ERROR: cost_ceiling ${cost_ceiling} > "
            f"total_budget ${total_budget} — adjust flags",
            err=True,
        )
        sys.exit(1)

    # Construct PdfSource (D-064 path-safety validated inside __post_init__)
    try:
        pdf_source = PdfSource(
            pdf_path=pdf_path.resolve(),
            source_url=source_url,
            ticker=Ticker(ticker_upper),
            statement_type=stmt_type,
            period_end=period_end_d,
            filing_date=filing_date_d,
        )
    except (PdfSourceInvariantError, ValueError) as exc:
        click.echo(f"[ingest_pdf_fundamentals] PdfSource error: {exc}", err=True)
        sys.exit(3)

    # Instantiate G.3 adapter (D-050 CHARTER: ZERO import anthropic; uses claude_cli_transport)
    adapter = ClaudeVisionPdfTableExtractor(cost_ceiling_usd=cost_ceiling)

    # STEP 1: Extract via G.3 ClaudeVisionPdfTableExtractor (includes EchoValidator gate DD-4)
    click.echo(f"[ingest_pdf_fundamentals] Extracting PDF via {adapter.name()} ...")
    try:
        extracted = adapter.extract(pdf_source)
    except CostBudgetExceeded as exc:
        click.echo(
            f"[ingest_pdf_fundamentals] COST CAP EXCEEDED: actual=${exc.actual_cost:.4f} "
            f"> ceiling=${exc.ceiling:.4f}",
            err=True,
        )
        sys.exit(1)
    except EchoValidationError as exc:
        click.echo(
            f"[ingest_pdf_fundamentals] ECHO VALIDATION ERROR (Rule 16 mode #2): {exc}",
            err=True,
        )
        sys.exit(2)
    except VisionExtractionError as exc:
        click.echo(f"[ingest_pdf_fundamentals] VISION EXTRACTION ERROR: {exc}", err=True)
        sys.exit(4)

    total_cost = sum((r.cost_usd for r in adapter.call_records), Decimal("0"))
    cells_extracted = len(extracted.raw_cells)
    click.echo(
        f"[ingest_pdf_fundamentals] Extracted {cells_extracted} cells, total_cost=${total_cost:.4f}"
    )

    # STEP 2: Map extracted cells → FinancialStatement (deterministic; no LLM math)
    click.echo("[ingest_pdf_fundamentals] Mapping cells to FinancialStatement ...")
    try:
        fs = map_extracted_to_financial_statement(
            extracted=extracted,
            ticker=Ticker(ticker_upper),
            filing_date=filing_date_d,
            sector=sector,
        )
    except RequiredCellMissingError as exc:
        click.echo(
            f"[ingest_pdf_fundamentals] REQUIRED CELL MISSING: {exc}",
            err=True,
        )
        sys.exit(3)
    except PdfMapperError as exc:
        click.echo(f"[ingest_pdf_fundamentals] MAPPER ERROR: {exc}", err=True)
        sys.exit(3)

    canonical_keys = list(fs.line_items.keys())
    click.echo(
        f"[ingest_pdf_fundamentals] Mapped {len(canonical_keys)} canonical keys: {canonical_keys}"
    )

    # STEP 3: Persist to SqliteFundamentalRepository (BC-2 substrate; DD-3 ADDITIVE-ONLY)
    click.echo(f"[ingest_pdf_fundamentals] Persisting to SQLite: {db} ...")
    repo = SqliteFundamentalRepository(db_path=db)
    n_saved = repo.save_many([fs])
    click.echo(f"[ingest_pdf_fundamentals] Saved {n_saved} FinancialStatement(s) to {db}")

    # STEP 4: RatioService smoke — compute NET_MARGIN (requires REVENUE + NET_INCOME)
    ratios_computed: dict[str, str] = {}
    ratio_svc = RatioService()
    net_income = fs.get_line_item("net_income")
    revenue = fs.get_line_item("revenue")
    if net_income is not None and revenue is not None:
        try:
            ratio_nm = ratio_svc.compute_net_margin(
                net_income_ttm=net_income,
                revenue_ttm=revenue,
                ticker=Ticker(ticker_upper),
                period_end=period_end_d,
            )
            ratios_computed["net_margin"] = str(ratio_nm.value)
            click.echo(
                f"[ingest_pdf_fundamentals] net_margin={ratio_nm.value:.4f} "
                f"({ratio_nm.formula_audit})"
            )
        except RatioComputationError as exc:
            click.echo(f"[ingest_pdf_fundamentals] net_margin computation error: {exc}", err=True)
    else:
        click.echo(
            "[ingest_pdf_fundamentals] Skipping net_margin: REVENUE or NET_INCOME missing",
            err=True,
        )

    # STEP 5: Write thesis-log artifact (DD-7)
    output_dir.mkdir(parents=True, exist_ok=True)
    artifact_path = output_dir / "2026-05-G4-VHM-fundamentals.md"
    _write_thesis_log(
        artifact_path=artifact_path,
        ticker_upper=ticker_upper,
        fs=fs,
        extracted_sha256=extracted.source_pdf_sha256,
        extraction_method=extracted.extraction_method,
        extractor_version=extracted.extractor_version,
        cells_extracted=cells_extracted,
        total_cost_usd=total_cost,
        call_records=adapter.call_records,
        ratios_computed=ratios_computed,
        source_url=source_url,
        period_end=period_end_d,
        filing_date=filing_date_d,
    )
    click.echo(f"[ingest_pdf_fundamentals] Thesis-log artifact: {artifact_path}")
    click.echo("[ingest_pdf_fundamentals] Done. Exit 0.")


def _write_thesis_log(
    *,
    artifact_path: Path,
    ticker_upper: str,
    fs: FinancialStatement,
    extracted_sha256: str,
    extraction_method: str,
    extractor_version: str,
    cells_extracted: int,
    total_cost_usd: Decimal,
    call_records: Sequence[object],
    ratios_computed: dict[str, str],
    source_url: str,
    period_end: date_type,
    filing_date: date_type,
) -> None:
    """Write the thesis-log artifact per DD-7 template structure."""
    now_utc = datetime.now(UTC)
    canonical_keys = sorted(fs.line_items.keys())

    cells_md_lines = []
    for key in canonical_keys:
        m = fs.line_items[key]
        cells_md_lines.append(f"| {key} | {m.amount} | {m.currency.value} |")
    cells_md = "\n".join(cells_md_lines) if cells_md_lines else "| (none mapped) | - | - |"

    ratios_md_lines = []
    for ratio_name, ratio_value in ratios_computed.items():
        ratios_md_lines.append(f"| {ratio_name} | {ratio_value} |")
    ratios_md = "\n".join(ratios_md_lines) if ratios_md_lines else "| (none computed) | - |"

    calls_md_lines = []
    for i, rec in enumerate(call_records):
        # _CallRecord is a dataclass; access via attribute
        calls_md_lines.append(
            f"| {i + 1} | {getattr(rec, 'cells_extracted', '?')} | "
            f"{getattr(rec, 'input_tokens', '?')} | "
            f"{getattr(rec, 'output_tokens', '?')} | "
            f"${getattr(rec, 'cost_usd', Decimal('0')):.4f} | "
            f"{getattr(rec, 'wall_ms', '?')}ms |"
        )
    calls_md = "\n".join(calls_md_lines) if calls_md_lines else "| - | - | - | - | - | - |"

    md = f"""---
ticker: {ticker_upper}
as_of: {now_utc.strftime("%Y-%m-%d")}
source_pdf_sha256: {extracted_sha256}
extraction_method: {extraction_method}
extractor_version: {extractor_version}
total_cost_usd: {total_cost_usd}
cells_extracted: {cells_extracted}
canonical_keys_present: {canonical_keys}
status: DOGFOOD-V0
---

# G.4 VHM PDF Fundamentals Dogfood — Thesis-Log Artifact

> **Research aid, not financial advice (I-S35).** See disclaimer footer.

## 1. Provenance

| Field | Value |
|---|---|
| Ticker | {ticker_upper} |
| Source PDF URL | {source_url} |
| Period End | {period_end} |
| Filing Date | {filing_date} |
| Source PDF SHA-256 | `{extracted_sha256}` |
| Extraction Method | {extraction_method} |
| Extractor Version | {extractor_version} |
| As-Of (extraction) | {now_utc.strftime("%Y-%m-%dT%H:%M:%SZ")} |
| SourceProvider | {SourceProvider.SCRAPED_OTHER.value} |

## 2. Extracted Canonical Cells

> Values from EchoValidator-validated raw_cells → deterministic mapper.
> D-050 CHARTER: ZERO LLM math — all amounts from deterministic code.

| Line Item Key | Amount | Currency |
|---|---|---|
{cells_md}

## 3. Computed Ratios (RatioService Smoke)

> Formula audit citations from packages/domain/fundamental/services/ratio_service.py.
> NET_MARGIN = net_income / revenue (White-Sondhi-Fried AUFS 3e §1.4).

| Ratio | Value |
|---|---|
{ratios_md}

## 4. Cost Breakdown (per-call)

| Call # | Cells | Input Tokens | Output Tokens | Cost USD | Wall ms |
|---|---|---|---|---|---|
{calls_md}
| **Total** | {cells_extracted} | - | - | **${total_cost_usd:.4f}** | - |

## 5. EchoValidator Pass-Rate

> EchoValidator gate invoked inside G.3 ClaudeVisionPdfTableExtractor.extract()
> for every numeric cell (Rule 16 mode #2 per DD-4). If this artifact was written,
> ALL cells passed (EchoValidationError exits with code 2 before artifact is written).

- Cells validated: {cells_extracted}
- EchoValidator mismatches: 0 (artifact written = all passed)

## 6. Calibration Grade

- Grade: D (V0 baseline — no historical hit-rate data; CODE-READY-DATA-PENDING per plan-044 § H.3)
- Revisit trigger: n≥20 extracted FS records + Charter Principle 8 calibration regime entry
{_DISCLAIMER_MD}"""

    artifact_path.write_text(md, encoding="utf-8")


if __name__ == "__main__":
    main()
