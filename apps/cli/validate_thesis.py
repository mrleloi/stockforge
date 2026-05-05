"""validate_thesis — CLI for running a 3-perspective thesis analysis.

Usage:
    python apps/cli/validate_thesis.py --ticker HPG --as-of 2026-04-29
    python apps/cli/validate_thesis.py --ticker HPG --mock-llm

On success (exit 0): thesis written to {output_dir}/{as_of}-{ticker}.md
On CostBudgetExceeded (exit 1): prints error + partial cost.
On BearCaseInvariantError / INCOMPLETE thesis (exit 2): prints error.
On live-LLM gate not resolved (exit 3): NotImplementedError printed.

HARD BINDING:
- --mock-llm injects MockLLMPerspectivePort (no Anthropic call; safe for CI).
- --no-mock-llm checks ANTHROPIC_API_KEY; absent → exit with helpful error (exit 4).
  ANTHROPIC_API_KEY present → NotImplementedError (S43a-DOGFOOD gate; exit 3).
- NEVER makes a live Anthropic call in S43a-CODE.

I-S35: every output markdown includes disclaimer footer.
UTF-8 everywhere; Vietnamese diacritics preserved.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.7 (UC-2)
"""

from __future__ import annotations

import asyncio
import sys
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path
from typing import TYPE_CHECKING

import click

from packages.application.analysis.ports.cost_tracker_port import CostBudgetExceeded
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import PerspectiveAnalysis
from packages.domain.analysis.models.thesis import BearCaseInvariantError, ThesisStatus

if TYPE_CHECKING:
    pass

# Internal type alias for perspective helper
_Perspective = PerspectiveAnalysis

_DISCLAIMER_MD = (
    "\n---\n\n"
    "> **Disclaimer (I-S35)**: This is a research aid, not financial advice. "
    "Decisions and responsibility are yours. "
    "Numbers come from deterministic code; narrative from LLM interpretation. "
    "Past performance does not predict future results. "
    "Calibration grade: D (Phase 2 — no calibration data yet, BR-7).\n"
)


@click.command()
@click.option("--ticker", required=True, help="VN30 ticker symbol (e.g. HPG, VHM)")
@click.option(
    "--as-of",
    default=None,
    type=click.DateTime(formats=["%Y-%m-%d"]),
    help="Analysis date (YYYY-MM-DD; default = today)",
)
@click.option(
    "--db",
    default="data/stockforge.sqlite",
    show_default=True,
    type=click.Path(dir_okay=False, path_type=Path),
    help="SQLite database path",
)
@click.option(
    "--output-dir",
    default="agent-workspace/memory/thesis-log/",
    show_default=True,
    type=click.Path(file_okay=False, path_type=Path),
    help="Directory where thesis markdown is written",
)
@click.option(
    "--max-cost-usd",
    default="3.00",
    show_default=True,
    help="Hard cost cap per execution in USD (BR-6 / I-40)",
)
@click.option(
    "--mock-llm/--no-mock-llm",
    default=False,
    help="Use mock LLM returning canned PerspectiveAnalysis (for tests/CI)",
)
@click.option(
    "--transport",
    type=click.Choice(["anthropic", "subagent"], case_sensitive=False),
    default="anthropic",
    show_default=True,
    help="LLM substrate when --no-mock-llm: 'anthropic' (SDK; needs API key) or "
    "'subagent' (claude CLI subprocess; uses subscription, no key required; S43b)",
)
def main(
    ticker: str,
    as_of: datetime | None,
    db: Path,
    output_dir: Path,
    max_cost_usd: str,
    mock_llm: bool,
    transport: str,
) -> None:
    """Validate a thesis for TICKER and write markdown to OUTPUT_DIR."""
    _ensure_utf8()

    effective_as_of: date = as_of.date() if as_of is not None else date.today()
    max_cost = Decimal(max_cost_usd)
    ticker_upper = ticker.strip().upper()

    click.echo(
        f"[validate_thesis] ticker={ticker_upper} as_of={effective_as_of} "
        f"mock_llm={mock_llm} transport={transport} db={db} max_cost=${max_cost}"
    )

    from apps._shared.use_case_builder import BuildError, build_use_case  # noqa: PLC0415

    try:
        use_case = build_use_case(
            db_path=db,
            mock_llm=mock_llm,
            max_cost_usd=max_cost,
            transport=transport.lower(),
        )
    except BuildError as exc:
        click.echo(f"[validate_thesis] ERROR: {exc}", err=True)
        sys.exit(4)
    except NotImplementedError as exc:
        click.echo(f"[validate_thesis] ERROR (DOGFOOD gate): {exc}", err=True)
        sys.exit(3)

    try:
        thesis = asyncio.run(
            use_case.execute(Ticker(ticker_upper), effective_as_of)
        )
    except CostBudgetExceeded as exc:
        click.echo(
            f"[validate_thesis] COST CAP EXCEEDED: spent ${exc.spent:.4f} "
            f"> limit ${exc.limit:.4f}",
            err=True,
        )
        sys.exit(1)
    except BearCaseInvariantError as exc:
        click.echo(f"[validate_thesis] BEAR CASE INVARIANT FAILED: {exc}", err=True)
        sys.exit(2)

    # Write thesis to markdown
    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / f"{effective_as_of}-{ticker_upper}.md"
    md = _render_thesis_md(thesis)
    out_path.write_text(md, encoding="utf-8")

    click.echo(f"[validate_thesis] thesis written: {out_path}")

    if thesis.status == ThesisStatus.INCOMPLETE:
        gaps_list = list(thesis.gaps)
        click.echo(
            f"[validate_thesis] WARNING: thesis is INCOMPLETE — gaps: {gaps_list}",
            err=True,
        )
        # Cost exceeded path: use case caught CostBudgetExceeded internally and
        # returned Thesis.incomplete(gaps=["cost_budget_exceeded"]) (BR-6).
        if "cost_budget_exceeded" in thesis.gaps:
            click.echo(
                "[validate_thesis] COST CAP EXCEEDED — thesis not persisted (BR-6 / I-40).",
                err=True,
            )
            sys.exit(1)
        # Bear case invariant failed after retry (BR-1 / I-S10)
        if "bear_case_invariant_failed" in thesis.gaps or "bear_case_insufficient" in thesis.gaps:
            click.echo(
                "[validate_thesis] BEAR CASE INVARIANT FAILED — bear case <3 distinct points (I-S10).",
                err=True,
            )
            sys.exit(2)
        sys.exit(0)

    click.echo(
        f"[validate_thesis] OK — recommendation={thesis.final_recommendation} "
        f"confidence={thesis.confidence_level} cost=${thesis.cost_usd:.4f}"
    )
    sys.exit(0)


# ---------------------------------------------------------------------------
# Markdown rendering
# ---------------------------------------------------------------------------


def _render_thesis_md(thesis: object) -> str:  # noqa: PLR0912
    """Render a Thesis to the thesis-log markdown format per _template.md schema."""
    from packages.domain.analysis.models.thesis import Thesis, ThesisStatus  # noqa: PLC0415

    assert isinstance(thesis, Thesis)

    is_incomplete = thesis.status == ThesisStatus.INCOMPLETE
    rec_str = str(thesis.final_recommendation) if thesis.final_recommendation else "incomplete"
    conf_str = str(thesis.confidence_level) if thesis.confidence_level else "n/a"

    lines: list[str] = [
        "---",
        f"thesis_id: {thesis.thesis_id}",
        f"ticker: {thesis.ticker.symbol}",
        f"as_of: {thesis.as_of.isoformat()}",
        f"created_at: {thesis.created_at.isoformat()}",
        f"status: {thesis.status}",
        f"recommendation: {rec_str}",
        f"confidence_level: {conf_str}",
        f"calibration_grade: {thesis.calibration_grade}",
        f"n_samples: {thesis.n_samples}",
        f"cost_usd: {thesis.cost_usd}",
        f"incomplete: {'true' if is_incomplete else 'false'}",
        f"gaps: {list(thesis.gaps)}",
        "real_thesis: false",
        "disclaimer_present: true",
        "---",
        "",
        f"# {thesis.ticker.symbol} — as of {thesis.as_of.isoformat()}",
        "",
        "> **Status**: "
        + rec_str.upper()
        + " — research aid only, not financial advice (I-S35).",
        "",
    ]

    if is_incomplete:
        lines += [
            "## INCOMPLETE",
            "",
            f"Data gaps prevented full analysis: {', '.join(thesis.gaps) or 'unknown'}.",
            "",
        ]
        lines.append(_DISCLAIMER_MD)
        return "\n".join(lines)

    # Bear case
    bear = _find_persp(thesis, "bear")
    bull = _find_persp(thesis, "bull")
    quant = _find_persp(thesis, "quant")

    lines += ["## Bear Case (I-S10 — ≥3 distinct points required)", ""]
    if bear:
        for i, pt in enumerate(bear.key_points, 1):
            lines.append(
                f"{i}. **{pt.text}** — source: [{pt.source_url}]({pt.source_url}), "
                f"as-of: {pt.as_of}, conviction: {pt.conviction}"
            )
            lines.append(f"   > {pt.source_excerpt}")
            lines.append("")
    else:
        lines.append("_No bear perspective available._\n")

    lines += ["## Bull Case", ""]
    if bull:
        for i, pt in enumerate(bull.key_points, 1):
            lines.append(
                f"{i}. **{pt.text}** — source: [{pt.source_url}]({pt.source_url}), "
                f"as-of: {pt.as_of}, conviction: {pt.conviction}"
            )
            lines.append("")
    else:
        lines.append("_No bull perspective available._\n")

    lines += ["## Quant Summary (numbers from code — I-S1 / BR-2)", ""]
    if quant:
        for pt in quant.key_points:
            lines.append(f"- {pt.text}")
        lines.append("")
    else:
        lines.append("_No quant perspective available._\n")

    # Trade-off matrix
    if thesis.synthesis:
        matrix = thesis.synthesis.trade_off_matrix
        lines += [
            "## Trade-Off Matrix",
            "",
            "| Dimension | Verdict | Evidence Points |",
            "|---|---|---|",
        ]
        from packages.domain.analysis.value_objects.trade_off_matrix import (
            DIMENSIONS,  # noqa: PLC0415
        )

        for dim in DIMENSIONS:
            verdict = matrix.scores.get(dim)
            ev_count = len(matrix.evidence.get(dim, ()))
            lines.append(f"| {dim} | {verdict or 'N/A'} | {ev_count} |")
        lines.append("")

        # Disagreements
        disags = thesis.synthesis.explicit_disagreements
        lines += ["## Explicit Disagreements (I-S12 — preserved, NOT collapsed)", ""]
        if disags:
            for d in disags:
                lines.append(
                    f"- **{d.dimension}**: bear says `{d.bear_verdict}`; "
                    f"bull says `{d.bull_verdict}`. {d.note}"
                )
        else:
            lines.append(
                "No explicit disagreements (per I-S12 detector). Perspectives align."
            )
        lines.append("")

        # Reasoning trace
        lines += [
            "## Reasoning Trace",
            "",
            thesis.synthesis.reasoning_trace,
            "",
        ]

    lines.append(_DISCLAIMER_MD)
    return "\n".join(lines)


def _find_persp(thesis: object, role: str) -> _Perspective | None:
    from packages.domain.analysis.models.perspective_analysis import (  # noqa: PLC0415
        PerspectiveAnalysis,
    )
    from packages.domain.analysis.models.thesis import Thesis  # noqa: PLC0415

    assert isinstance(thesis, Thesis)
    for p in thesis.perspectives:
        if str(p.role) == role and isinstance(p, PerspectiveAnalysis):
            return p
    return None


def _ensure_utf8() -> None:
    _reconfigure = getattr(sys.stdout, "reconfigure", None)
    if callable(_reconfigure):
        _reconfigure(encoding="utf-8")


if __name__ == "__main__":
    main()
