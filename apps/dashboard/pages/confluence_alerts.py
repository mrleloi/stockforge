"""Confluence Alerts page — UC-3 cross-cutting Streamlit view (BC-7 + BC-6).

Read-only inspection of recent pump detections + counter-narratives + cross-source
recommendation confluence.

NO LLM calls / NO LLM math (I-S1). Pump phase + narrative phase + recommendation
intent all come verbatim from deterministic upstream classifiers.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-3
        + specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-4 (confluence gate).
"""

from __future__ import annotations

import asyncio
import os
from datetime import UTC, datetime, timedelta
from pathlib import Path

import streamlit as st  # type: ignore[import-not-found]

_DEFAULT_DB = Path("data/stockforge.sqlite")
_DEFAULT_LOOKBACK_DAYS = 14
_DISCLAIMER_FOOTER = (
    "Research aid — not financial advice (I-S35). "
    "Pump alerts surface coordinated posting + suspicious phase transitions; "
    "human review required before any action."
)


def render() -> None:
    st.title("Confluence Alerts")
    st.caption(
        "Pump detections + counter-narratives + KOL recommendation cluster. "
        "Combines BC-7 crowd surveillance with BC-6 KOL flow."
    )

    db_path = Path(os.environ.get("STOCKFORGE_DB", str(_DEFAULT_DB)))
    if not db_path.exists():
        st.info(
            f"No database at `{db_path}`. Run BC-7 + BC-6 ingestion + classification first."
        )
        return

    lookback_days = st.slider(
        "Lookback (days)", min_value=1, max_value=60, value=_DEFAULT_LOOKBACK_DAYS
    )
    ticker_filter = st.text_input("Filter by ticker (optional)").strip().upper()

    if st.button("Load alerts"):
        _render_alerts(
            db_path=db_path,
            lookback_days=lookback_days,
            ticker_filter=ticker_filter or None,
        )


def _render_alerts(
    *,
    db_path: Path,
    lookback_days: int,
    ticker_filter: str | None,
) -> None:
    from packages.infrastructure.crowd.sqlite_pump_detection_repository import (  # noqa: PLC0415
        SqlitePumpDetectionRepository,
    )
    from packages.infrastructure.influence.sqlite_recommendation_repository import (  # noqa: PLC0415
        SqliteRecommendationRepository,
    )

    pump_repo = SqlitePumpDetectionRepository(db_path)
    rec_repo = SqliteRecommendationRepository(db_path)
    since = datetime.now(UTC) - timedelta(days=lookback_days)

    try:
        pending = pump_repo.get_pending_review()
        recent_recs = asyncio.run(rec_repo.find_recent(since=since))
    except Exception as exc:  # noqa: BLE001
        st.error(f"Database read failed: {exc}")
        return

    if ticker_filter:
        pending = [d for d in pending if d.ticker == ticker_filter]
        recent_recs = [r for r in recent_recs if r.ticker == ticker_filter]

    col_a, col_b = st.columns(2)
    col_a.metric("Pending pump reviews", len(pending))
    col_b.metric(f"KOL recs in last {lookback_days}d", len(recent_recs))

    st.subheader("Pump Detections (pending review)")
    if not pending:
        st.info("No pending pump detections.")
    else:
        pump_rows = [
            {
                "detection_id": str(d.detection_id)[:12] + "...",
                "ticker": d.ticker,
                "phase": d.pump_phase.value,
                "detected_at": d.detected_at.isoformat(),
                "evidence_count": len(d.evidence),
            }
            for d in pending
        ]
        st.dataframe(pump_rows, use_container_width=True, hide_index=True)

    st.subheader("KOL Recommendation Cluster")
    if not recent_recs:
        st.info("No KOL recommendations in the selected window.")
    else:
        from collections import Counter  # noqa: PLC0415

        ticker_counts = Counter(r.ticker for r in recent_recs)
        cluster_rows = [
            {"ticker": t, "kol_recs": c}
            for t, c in ticker_counts.most_common(20)
        ]
        st.dataframe(cluster_rows, use_container_width=True, hide_index=True)

    st.caption(_DISCLAIMER_FOOTER)
