"""StockForge Dashboard — Streamlit entry point.

Run:
    streamlit run apps/dashboard/main.py

Sidebar navigation currently exposes one page:
  - Validate Thesis (BC-8 Analysis)

I-S35 disclaimer banner is mandatory on every page load.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.7
"""

from __future__ import annotations

import streamlit as st  # type: ignore[import-not-found]

_DISCLAIMER = (
    "Research aid — not financial advice. "
    "All decisions and responsibility are yours."
)

_PAGES = {
    "Validate Thesis": "apps/dashboard/pages/validate_thesis.py",
}


def main() -> None:
    st.set_page_config(
        page_title="StockForge",
        page_icon=":chart_with_upwards_trend:",
        layout="wide",
    )

    # I-S35: mandatory disclaimer on every page load
    st.warning(_DISCLAIMER)

    st.sidebar.title("StockForge")
    page = st.sidebar.radio("Navigate", list(_PAGES.keys()), index=0)

    if page == "Validate Thesis":
        # Lazy import to avoid loading all pages at startup
        from apps.dashboard.pages.validate_thesis import render  # noqa: PLC0415

        render()
    else:
        st.info(f"Page '{page}' not yet implemented.")


if __name__ == "__main__":
    main()
