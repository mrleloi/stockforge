"""Validate Thesis page — Streamlit BC-8 Analysis UI.

Composition root: builds ValidateThesisPhase1UseCase via shared use_case_builder.
Runs asyncio.run(use_case.execute(...)) inside button handler.
Renders thesis card via apps.dashboard.components.thesis_card.render_thesis_card.

Cost-aware:
- Catches CostBudgetExceeded → st.error with partial cost.
- Footer always shows thesis_id + cost_usd + confidence_level + I-S35 reminder.

Vietnamese-aware: UTF-8 throughout; diacritics preserved (no stripping).

HARD BINDING (S43a-CODE):
- mock_llm defaults True for development; set STOCKFORGE_MOCK_LLM=false + ANTHROPIC_API_KEY
  for dogfood (pending Q&A 2026-05-01-002 gate).

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.7
"""

from __future__ import annotations

import asyncio
import os
from datetime import date
from decimal import Decimal
from pathlib import Path

import streamlit as st  # type: ignore[import-not-found]

from packages.application.analysis.ports.cost_tracker_port import CostBudgetExceeded
from packages.contracts.types import Ticker

_DEFAULT_DB = Path("data/stockforge.sqlite")
_DEFAULT_MAX_COST = Decimal("3.00")
_DISCLAIMER_FOOTER = (
    "Research aid — not financial advice (I-S35). "
    "Calibration grade: D (Phase 2 heuristic; no calibration data yet)."
)


def render() -> None:
    """Render the Validate Thesis page."""
    st.title("Validate Thesis")
    st.caption("Run a 6-perspective analysis (Bear / Bull / Quant / Buffett / Graham / Taleb) on a VN30 ticker — V0 per Phase F.3 (D-076).")

    # --- Inputs ---
    ticker_raw = st.text_input("Ticker", placeholder="e.g. HPG, VHM, FPT")
    as_of_val: date = st.date_input("As of", value=date.today())

    mock_llm = os.environ.get("STOCKFORGE_MOCK_LLM", "true").lower() != "false"
    db_path = Path(os.environ.get("STOCKFORGE_DB", str(_DEFAULT_DB)))
    max_cost_usd = Decimal(os.environ.get("STOCKFORGE_MAX_COST_USD", str(_DEFAULT_MAX_COST)))

    if st.button("Validate"):
        ticker_str = ticker_raw.strip().upper()
        if not ticker_str:
            st.error("Please enter a ticker symbol.")
            return

        _run_validation(
            ticker_str=ticker_str,
            as_of=as_of_val,
            db_path=db_path,
            mock_llm=mock_llm,
            max_cost_usd=max_cost_usd,
        )


def _run_validation(
    *,
    ticker_str: str,
    as_of: date,
    db_path: Path,
    mock_llm: bool,
    max_cost_usd: Decimal,
) -> None:
    """Execute the use case and render results (or errors)."""
    from apps._shared.use_case_builder import BuildError, build_use_case  # noqa: PLC0415
    from apps.dashboard.components.thesis_card import render_thesis_card  # noqa: PLC0415

    with st.spinner(
        "Running thesis validation... cost cap $3 / time cap 5 min. Please wait."
    ):
        try:
            use_case = build_use_case(
                db_path=db_path,
                mock_llm=mock_llm,
                max_cost_usd=max_cost_usd,
            )
        except BuildError as exc:
            st.error(f"Configuration error: {exc}")
            return
        except NotImplementedError as exc:
            st.error(f"Live analysis gate not yet open: {exc}")
            return

        try:
            thesis = asyncio.run(
                use_case.execute(Ticker(ticker_str), as_of)
            )
        except CostBudgetExceeded as exc:
            st.error(
                f"Cost budget exceeded: spent ${exc.spent:.4f} "
                f"(limit ${exc.limit:.4f}). Partial results not saved."
            )
            return
        except Exception as exc:  # noqa: BLE001
            st.error(f"Unexpected error during thesis validation: {exc}")
            return

    render_thesis_card(thesis)

    # Footer
    cost_str = f"${thesis.cost_usd:.4f}"
    conf_str = str(thesis.confidence_level) if thesis.confidence_level else "n/a"
    st.caption(
        f"thesis_id: `{thesis.thesis_id[:16]}...` | "
        f"cost: {cost_str} | "
        f"confidence: {conf_str} | "
        f"{_DISCLAIMER_FOOTER}"
    )
