"""KOL Daily Digest page — UC-1 cross-cutting Streamlit view (BC-6).

Read-only inspection of recent KOL recommendations.
Wires SqliteKolRepository.list_all + SqliteRecommendationRepository.find_recent.

NO LLM calls / NO mutations / NO numbers computed by LLM (I-S1). Every recommendation
shown carries source_url + extracted_at + extraction_confidence (≥0.7 BR-6 floor)
verbatim from the persisted Recommendation aggregate.

Source: specs/tier2-feature/002-influence-network-tracking.md § B.3 UC-1.
Master-plan: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md §S57 (Track M).
"""

from __future__ import annotations

import asyncio
import os
from datetime import UTC, datetime, timedelta
from pathlib import Path

import streamlit as st  # type: ignore[import-not-found]

_DEFAULT_DB = Path("data/stockforge.sqlite")
_DEFAULT_LOOKBACK_DAYS = 7
_DISCLAIMER_FOOTER = (
    "Research aid — not financial advice (I-S35). "
    "KOL recommendations are extracted public statements; verify before acting."
)


def render() -> None:
    st.title("KOL Daily Digest")
    st.caption(
        "Recent KOL recommendations across the tracked roster. "
        "Filter by lookback window or KOL."
    )

    db_path = Path(os.environ.get("STOCKFORGE_DB", str(_DEFAULT_DB)))
    if not db_path.exists():
        st.info(
            f"No database at `{db_path}`. Ingest KOL channels first via "
            "`python -m apps.cli.ingest_kol_channels`."
        )
        return

    lookback_days = st.slider(
        "Lookback (days)", min_value=1, max_value=30, value=_DEFAULT_LOOKBACK_DAYS
    )

    if st.button("Load digest"):
        _render_digest(db_path=db_path, lookback_days=lookback_days)


def _render_digest(*, db_path: Path, lookback_days: int) -> None:
    from packages.infrastructure.influence.sqlite_kol_repository import (  # noqa: PLC0415
        SqliteKolRepository,
    )
    from packages.infrastructure.influence.sqlite_recommendation_repository import (  # noqa: PLC0415
        SqliteRecommendationRepository,
    )

    kol_repo = SqliteKolRepository(db_path)
    rec_repo = SqliteRecommendationRepository(db_path)
    since = datetime.now(UTC) - timedelta(days=lookback_days)

    try:
        kols = asyncio.run(kol_repo.list_all())
        recommendations = asyncio.run(rec_repo.find_recent(since=since))
    except Exception as exc:  # noqa: BLE001
        st.error(f"Database read failed: {exc}")
        return

    st.metric("Tracked KOLs", len(kols))
    st.metric(f"Recommendations in last {lookback_days}d", len(recommendations))

    if not recommendations:
        st.info("No recommendations in the selected window.")
        return

    rows = [
        {
            "kol_id": str(r.kol_id),
            "ticker": r.ticker,
            "intent": r.intent.value,
            "timeframe": r.timeframe.value,
            "confidence": f"{r.extraction_confidence:.2f}",
            "published_at": r.published_at.isoformat(),
            "source_url": r.source_url,
        }
        for r in recommendations
    ]
    st.dataframe(rows, use_container_width=True, hide_index=True)

    st.caption(_DISCLAIMER_FOOTER)
