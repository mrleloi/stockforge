"""Calibration Inspection page — UC-4 cross-cutting Streamlit view (BC-6).

Read-only inspection of per-KOL CredibilityScore (Bayesian posterior + per-sector
+ per-timeframe disaggregations).

NO LLM calls / NO LLM math (I-S1). Posterior numbers come verbatim from
SqliteCredibilityRepository (CalibrationService deterministic computation upstream).

Source: specs/tier2-feature/002-influence-network-tracking.md § B.1 + § B.3 UC-3.
"""

from __future__ import annotations

import asyncio
import os
from pathlib import Path

import streamlit as st  # type: ignore[import-not-found]

_DEFAULT_DB = Path("data/stockforge.sqlite")
_DISCLAIMER_FOOTER = (
    "Research aid — not financial advice (I-S35). "
    "Posterior credibility uses Beta(5,5) skeptical prior; "
    "small samples cannot drive posterior to 1.0."
)


def render() -> None:
    st.title("Calibration Inspection")
    st.caption(
        "Per-KOL Bayesian credibility posterior. "
        "Mean + 90% CI + per-sector + per-timeframe scores."
    )

    db_path = Path(os.environ.get("STOCKFORGE_DB", str(_DEFAULT_DB)))
    if not db_path.exists():
        st.info(
            f"No database at `{db_path}`. Run BC-6 calibration via "
            "`python -m apps.cli.run_due_outcome_reviews` first."
        )
        return

    kol_id_raw = st.text_input("KOL id", placeholder="e.g. youtube-channel-abc123")

    if st.button("Load credibility"):
        kol_id = kol_id_raw.strip()
        if not kol_id:
            st.error("Please enter a KOL id.")
            return
        _render_credibility(db_path=db_path, kol_id=kol_id)


def _render_credibility(*, db_path: Path, kol_id: str) -> None:
    from packages.domain.influence.value_objects.kol_id import KolId  # noqa: PLC0415
    from packages.infrastructure.influence.sqlite_credibility_repository import (  # noqa: PLC0415
        SqliteCredibilityRepository,
    )

    cred_repo = SqliteCredibilityRepository(db_path)
    try:
        score = asyncio.run(cred_repo.get(KolId(kol_id)))
    except Exception as exc:  # noqa: BLE001
        st.error(f"Database read failed: {exc}")
        return

    if score is None:
        st.warning(f"No credibility score persisted for KOL `{kol_id}`.")
        return

    col_a, col_b, col_c = st.columns(3)
    col_a.metric("Posterior mean", f"{score.bayesian_mean:.3f}")
    col_b.metric("90% CI low", f"{score.bayesian_ci_low:.3f}")
    col_c.metric("90% CI high", f"{score.bayesian_ci_high:.3f}")

    st.metric("Reviews evaluated", score.n_evaluated)
    counts_col_a, counts_col_b, counts_col_c = st.columns(3)
    counts_col_a.metric("Hits", score.n_hits)
    counts_col_b.metric("Misses", score.n_misses)
    counts_col_c.metric("Partial", score.n_partial)

    st.write(
        f"**Statistically meaningful**: "
        f"`{score.is_statistically_meaningful()}` "
        f"(CI width = {score.ci_width:.3f}; threshold 0.15)"
    )
    st.write(
        f"**High credibility**: `{score.is_high_credibility()}` "
        "(mean ≥ 0.6 AND statistically meaningful)"
    )

    if score.sector_scores:
        st.subheader("Per-sector credibility")
        sector_rows = [
            {
                "sector": sec,
                "n_evaluated": s.n_evaluated,
                "hit_rate_mean": f"{s.hit_rate_mean:.3f}",
            }
            for sec, s in score.sector_scores.items()
        ]
        st.dataframe(sector_rows, use_container_width=True, hide_index=True)

    if score.timeframe_scores:
        st.subheader("Per-timeframe credibility")
        tf_rows = [
            {
                "timeframe": tf.value,
                "n_evaluated": ts.n_evaluated,
                "hit_rate_mean": f"{ts.hit_rate_mean:.3f}",
            }
            for tf, ts in score.timeframe_scores.items()
        ]
        st.dataframe(tf_rows, use_container_width=True, hide_index=True)

    st.caption(_DISCLAIMER_FOOTER)
