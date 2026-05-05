"""thesis_card — pure Streamlit render function for a Thesis aggregate.

render_thesis_card(thesis) renders:
  - Header: ticker · as_of · recommendation badge (colour coded)
  - Tabs: Bear Case | Bull Case | Quant Summary | Trade-Off Matrix | Disagreements
  - Bear/Bull tabs: list each GroundedPoint with text + source link + excerpt + conviction
  - Quant Summary: key_points as table (ratio name / value / sector_avg / percentile / verdict)
  - Trade-Off Matrix: 4-row table (VALUE/QUALITY/GROWTH/RISK)
  - Disagreements: highlighted panel or "No explicit disagreements" notice
  - Footer: I-S35 disclaimer + calibration_grade=D notice

No "buy"/"sell"/"recommend" verbs in any user-facing copy (I-S35).
Vietnamese-aware: UTF-8; diacritics preserved.

Source: specs/tier2-feature/001-validate-investment-thesis.md § A.4
        specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § A.4
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import streamlit as st  # type: ignore[import-not-found]

if TYPE_CHECKING:
    from packages.domain.analysis.models.thesis import Thesis

__all__ = ["render_thesis_card"]

_DISCLAIMER = (
    "Research aid — not financial advice (I-S35). "
    "Calibration grade: D (Phase 2 heuristic — no calibration data yet, BR-7). "
    "Past performance does not predict future results."
)

# Recommendation → Streamlit badge colour mapping
_REC_COLOUR: dict[str, str] = {
    "pass": "red",
    "investigate": "orange",
    "watch": "blue",
    "thesis_candidate": "green",
}

# Conviction badge colours
_CONVICTION_COLOUR: dict[str, str] = {
    "strong": "green",
    "moderate": "orange",
    "weak": "red",
}

# DimensionVerdict → display text
_VERDICT_DISPLAY: dict[str, str] = {
    "strong": "STRONG",
    "neutral": "NEUTRAL",
    "weak": "WEAK",
}


def render_thesis_card(thesis: Thesis) -> None:
    """Render a Thesis as a Streamlit card.

    Handles both SUBMITTED and INCOMPLETE theses gracefully.
    """
    from packages.domain.analysis.models.thesis import ThesisStatus  # noqa: PLC0415

    _render_header(thesis)

    if thesis.status == ThesisStatus.INCOMPLETE:
        st.warning(
            f"Thesis is INCOMPLETE — data gaps prevented full analysis. "
            f"Gaps: {', '.join(thesis.gaps) or 'unknown'}."
        )
        return

    tab_bear, tab_bull, tab_quant, tab_matrix, tab_disagree = st.tabs(
        ["Bear Case", "Bull Case", "Quant Summary", "Trade-Off Matrix", "Disagreements"]
    )

    bear_persp = _get_perspective(thesis, "bear")
    bull_persp = _get_perspective(thesis, "bull")
    quant_persp = _get_perspective(thesis, "quant")

    with tab_bear:
        _render_perspective_tab("Bear Case", bear_persp)

    with tab_bull:
        _render_perspective_tab("Bull Case", bull_persp)

    with tab_quant:
        _render_quant_tab(quant_persp)

    with tab_matrix:
        _render_trade_off_matrix(thesis)

    with tab_disagree:
        _render_disagreements(thesis)

    st.divider()
    st.caption(_DISCLAIMER)


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------


def _render_header(thesis: Thesis) -> None:
    """Render ticker · as_of · recommendation badge."""
    rec_label = str(thesis.final_recommendation).upper() if thesis.final_recommendation else "INCOMPLETE"
    rec_value = str(thesis.final_recommendation) if thesis.final_recommendation else "incomplete"
    colour = _REC_COLOUR.get(rec_value, "grey")

    col1, col2, col3 = st.columns([2, 2, 3])
    with col1:
        st.metric("Ticker", thesis.ticker.symbol)
    with col2:
        st.metric("As of", thesis.as_of.isoformat())
    with col3:
        st.markdown(
            f"**Thesis Exploration**: :{colour}[{rec_label}]",
            help="Research-aid framing only. Not a buy/sell signal.",
        )


def _get_perspective(thesis: Thesis, role: str) -> object | None:
    """Return the perspective for the given role string, or None."""
    for p in thesis.perspectives:
        if str(p.role) == role:
            return p
    return None


def _render_perspective_tab(title: str, persp: object | None) -> None:
    """Render a single Bear or Bull tab."""
    if persp is None:
        st.info(f"No {title} perspective available.")
        return

    points = getattr(persp, "key_points", ())
    if not points:
        st.info(f"No {title} points available.")
        return

    for i, pt in enumerate(points, 1):
        conviction_val = str(getattr(pt, "conviction", "moderate"))
        colour = _CONVICTION_COLOUR.get(conviction_val, "grey")
        with st.container():
            st.markdown(
                f"**{i}.** {pt.text}  "
                f"— conviction: :{colour}[{conviction_val.upper()}]"
            )
            src = getattr(pt, "source_url", "")
            if src:
                st.markdown(f"Source: [{src}]({src})")
            excerpt = getattr(pt, "source_excerpt", "")
            if excerpt:
                st.markdown(f"> {excerpt}")
            st.divider()


def _render_quant_tab(quant_persp: object | None) -> None:
    """Render Quant Summary tab as a table."""
    if quant_persp is None:
        st.info("No Quant perspective available.")
        return

    points = getattr(quant_persp, "key_points", ())
    if not points:
        st.info("No quant data points available.")
        return

    rows = []
    for pt in points:
        rows.append(
            {
                "Point": pt.text,
                "Conviction": str(getattr(pt, "conviction", "")).upper(),
                "Source": str(getattr(pt, "source_url", "")),
                "As of": str(getattr(pt, "as_of", "")),
            }
        )
    st.table(rows)
    st.caption(
        "Numbers come from deterministic code — not LLM (I-S1 / BR-2). "
        "LLM only interprets; code computes."
    )


def _render_trade_off_matrix(thesis: Thesis) -> None:
    """Render the 4-dimension trade-off matrix."""
    if thesis.synthesis is None:
        st.info("No synthesis available (incomplete thesis).")
        return

    matrix = thesis.synthesis.trade_off_matrix
    from packages.domain.analysis.value_objects.trade_off_matrix import DIMENSIONS  # noqa: PLC0415

    rows = []
    for dim in DIMENSIONS:
        verdict_obj = matrix.scores.get(dim)
        verdict_str = _VERDICT_DISPLAY.get(str(verdict_obj), str(verdict_obj)) if verdict_obj else "N/A"
        evidence_pts = matrix.evidence.get(dim, ())
        evidence_count = len(evidence_pts)
        rows.append(
            {
                "Dimension": dim,
                "Verdict": verdict_str,
                "Evidence Points": evidence_count,
            }
        )
    st.table(rows)

    confluence = str(thesis.synthesis.confluence_assessment).replace("_", " ").title()
    st.info(f"Confluence: **{confluence}**")


def _render_disagreements(thesis: Thesis) -> None:
    """Render the disagreements panel (I-S12)."""
    if thesis.synthesis is None:
        st.info("No synthesis available (incomplete thesis).")
        return

    disagreements = thesis.synthesis.explicit_disagreements
    if not disagreements:
        st.success(
            "No explicit disagreements (per I-S12 detector). "
            "Perspectives broadly align."
        )
        return

    st.warning(
        f"**{len(disagreements)} explicit disagreement(s) detected (I-S12). "
        "These are preserved — NOT collapsed to a single consensus.**"
    )
    for d in disagreements:
        with st.expander(f"Dimension: {d.dimension}"):
            st.markdown(f"- **Bear verdict**: {d.bear_verdict}")
            st.markdown(f"- **Bull verdict**: {d.bull_verdict}")
            if d.note:
                st.markdown(f"- **Note**: {d.note}")
