"""Ticker Sentiment page — UC-2 cross-cutting Streamlit view (BC-7).

Read-only inspection of recent SentimentSnapshot rows + active narratives for a ticker.

NO LLM calls / NO LLM math (I-S1). Sentiment + posting velocity numbers come
verbatim from persisted SentimentSnapshot aggregates (deterministic computation
upstream).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-2.
"""

from __future__ import annotations

import os
from pathlib import Path

import streamlit as st  # type: ignore[import-not-found]

from packages.domain.crowd.value_objects.window import Window

_DEFAULT_DB = Path("data/stockforge.sqlite")
_DISCLAIMER_FOOTER = (
    "Research aid — not financial advice (I-S35). "
    "Sentiment is a signal, not a directive. Verify against fundamentals."
)


def render() -> None:
    st.title("Ticker Sentiment")
    st.caption(
        "Crowd sentiment snapshot + active narrative phase for a VN-listed ticker. "
        "Phase classifications come from BC-7 narrative_phase_classifier (deterministic)."
    )

    db_path = Path(os.environ.get("STOCKFORGE_DB", str(_DEFAULT_DB)))
    if not db_path.exists():
        st.info(
            f"No database at `{db_path}`. Ingest crowd content first via "
            "`python -m apps.cli.ingest_crowd_sentiment`."
        )
        return

    ticker_raw = st.text_input("Ticker", placeholder="e.g. HPG, FPT, VHM")
    window_label = st.selectbox(
        "Window",
        options=[w.value for w in Window],
        index=2,  # ONE_DAY
    )

    if st.button("Load sentiment"):
        ticker = ticker_raw.strip().upper()
        if not ticker:
            st.error("Please enter a ticker symbol.")
            return
        _render_sentiment(db_path=db_path, ticker=ticker, window=Window(window_label))


def _render_sentiment(*, db_path: Path, ticker: str, window: Window) -> None:
    from packages.infrastructure.crowd.sqlite_narrative_repository import (  # noqa: PLC0415
        SqliteNarrativeRepository,
    )
    from packages.infrastructure.crowd.sqlite_sentiment_snapshot_repository import (  # noqa: PLC0415
        SqliteSentimentSnapshotRepository,
    )

    snap_repo = SqliteSentimentSnapshotRepository(db_path)
    nar_repo = SqliteNarrativeRepository(db_path)

    try:
        snapshots = snap_repo.get_recent(ticker, window)
        narratives = nar_repo.get_active(ticker)
    except Exception as exc:  # noqa: BLE001
        st.error(f"Database read failed: {exc}")
        return

    if not snapshots:
        st.info(f"No sentiment snapshots for {ticker} in {window.value} window.")
    else:
        latest = snapshots[-1]
        col_a, col_b, col_c = st.columns(3)
        col_a.metric("Latest sentiment", f"{latest.aggregate_sentiment:.2f}")
        col_b.metric("Posting velocity", f"{latest.posting_velocity:.2f}/h")
        col_c.metric("Snapshot count", len(snapshots))

        rows = [
            {
                "captured_at": s.captured_at.isoformat(),
                "sentiment": f"{s.aggregate_sentiment:.2f}",
                "velocity_per_hour": f"{s.posting_velocity:.2f}",
                "post_count": s.post_count,
            }
            for s in snapshots
        ]
        st.dataframe(rows, use_container_width=True, hide_index=True)

    st.subheader("Active Narratives")
    if not narratives:
        st.info("No active narrative for this ticker.")
    else:
        narrative_rows = [
            {
                "narrative_id": str(n.narrative_id)[:12] + "...",
                "phase": n.phase.value,
                "first_seen": n.first_seen_at.isoformat(),
                "last_seen": n.last_seen_at.isoformat(),
            }
            for n in narratives
        ]
        st.dataframe(narrative_rows, use_container_width=True, hide_index=True)

    st.caption(_DISCLAIMER_FOOTER)
