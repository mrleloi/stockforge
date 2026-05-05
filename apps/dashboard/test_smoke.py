"""Smoke tests for the StockForge Streamlit dashboard (S43a-CODE).

Uses streamlit.testing.v1.AppTest for white-box UI testing without a browser.

Coverage (≥3 tests):
  t1: app loads without error; I-S35 disclaimer banner is present
  t2: validate_thesis page has text_input and date_input with default=today
  t3: clicking Validate button with mocked use_case shows result elements

NO live Anthropic calls. The dashboard reads STOCKFORGE_MOCK_LLM env var;
tests set it to "true" to ensure no live calls.

Source: agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md § S43a
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import Confluence, Synthesis
from packages.domain.analysis.models.thesis import Thesis, ThesisStatus
from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)

_TODAY = date.today()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _pt(text: str = "point", cat: str | None = None) -> GroundedPoint:
    return GroundedPoint(
        text=text,
        source_url="https://mock.example.com/filing",
        source_excerpt="Verbatim excerpt for dashboard smoke test.",
        as_of=_TODAY,
        conviction=Conviction.MODERATE,
        category=cat,
    )


def _make_submitted_thesis(ticker: str = "HPG") -> Thesis:
    bear = PerspectiveAnalysis(
        role=PerspectiveRole.BEAR,
        key_points=(
            _pt("Fundamental risk", BearCategory.FUNDAMENTAL),
            _pt("Valuation risk", BearCategory.VALUATION),
            _pt("Macro risk", BearCategory.MACRO),
        ),
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="mock-llm",
        prompt_hash="smoketest0123456",
    )
    bull = PerspectiveAnalysis(
        role=PerspectiveRole.BULL,
        key_points=(_pt("Growth"), _pt("Moat")),
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="mock-llm",
        prompt_hash="smoketest0123456",
    )
    quant = PerspectiveAnalysis(
        role=PerspectiveRole.QUANT,
        key_points=(_pt("P/B below avg"),),
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="mock-llm",
        prompt_hash="smoketest0123456",
    )
    matrix = TradeOffMatrix(
        scores={d: DimensionVerdict.NEUTRAL for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
        evidence={d: () for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
    )
    synthesis = Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=Confluence.MIXED,
        explicit_disagreements=(),
        catalysts=(),
        risks=(),
        reasoning_trace="smoke test synthesis trace",
    )
    from packages.domain.analysis.value_objects.confidence_level import (
        ConfidenceLevel,  # noqa: PLC0415
    )
    from packages.domain.analysis.value_objects.recommendation import (
        Recommendation,  # noqa: PLC0415
    )

    return Thesis(
        thesis_id="smoketestid" + "0" * 54,
        ticker=Ticker(ticker),
        as_of=_TODAY,
        created_at=datetime.now(UTC),
        status=ThesisStatus.SUBMITTED,
        perspectives=(bear, bull, quant),
        synthesis=synthesis,
        final_recommendation=Recommendation.INVESTIGATE,
        confidence_level=ConfidenceLevel.MEDIUM,
        cost_usd=Decimal("0.30"),
    )


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


def test_t1_app_loads_with_disclaimer(monkeypatch: pytest.MonkeyPatch) -> None:
    """t1: app loads without exception; I-S35 disclaimer warning is present."""
    try:
        from streamlit.testing.v1 import AppTest  # type: ignore[import-not-found]  # noqa: PLC0415
    except ImportError:
        pytest.skip("streamlit.testing.v1 not available in this environment")

    monkeypatch.setenv("STOCKFORGE_MOCK_LLM", "true")

    at = AppTest.from_file("apps/dashboard/main.py", default_timeout=30)
    at.run()

    assert not at.exception, f"App raised exception: {at.exception}"

    # I-S35: disclaimer warning must appear
    warning_texts = [w.value for w in at.warning]
    assert any(
        "research aid" in w.lower() or "not financial advice" in w.lower()
        for w in warning_texts
    ), f"Disclaimer not found in warnings: {warning_texts}"


def test_t2_validate_page_inputs_exist(monkeypatch: pytest.MonkeyPatch) -> None:
    """t2: validate_thesis page has text_input (Ticker) and date_input with default=today."""
    try:
        from streamlit.testing.v1 import AppTest  # noqa: PLC0415
    except ImportError:
        pytest.skip("streamlit.testing.v1 not available in this environment")

    monkeypatch.setenv("STOCKFORGE_MOCK_LLM", "true")

    at = AppTest.from_file("apps/dashboard/main.py", default_timeout=30)
    at.run()

    assert not at.exception, f"App raised exception: {at.exception}"

    # text_input for ticker should exist
    assert len(at.text_input) >= 1, "Expected at least one text_input (Ticker)"

    # date_input for as_of should default to today
    import datetime as _dt  # noqa: PLC0415
    assert len(at.date_input) >= 1, "Expected at least one date_input (As of)"
    date_input_val = at.date_input[0].value
    assert date_input_val == _dt.date.today(), (
        f"date_input default should be today ({_dt.date.today()}); got {date_input_val}"
    )


def test_t3_validate_button_with_mock_shows_result(monkeypatch: pytest.MonkeyPatch) -> None:
    """t3: clicking Validate with mocked use_case shows thesis content elements."""
    try:
        from streamlit.testing.v1 import AppTest  # noqa: PLC0415
    except ImportError:
        pytest.skip("streamlit.testing.v1 not available in this environment")

    monkeypatch.setenv("STOCKFORGE_MOCK_LLM", "true")

    fake_thesis = _make_submitted_thesis("HPG")

    # Patch build_use_case to return a use_case whose execute() returns fake_thesis
    class _FakeUseCase:
        async def execute(self, _ticker: object, _as_of: object) -> Thesis:
            return fake_thesis

    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: _FakeUseCase(),
    )

    at = AppTest.from_file("apps/dashboard/main.py", default_timeout=30)
    at.run()
    assert not at.exception

    # Set ticker and click Validate
    at.text_input[0].set_value("HPG")
    at.run()
    at.button[0].click()
    at.run()

    assert not at.exception, f"App raised exception after button click: {at.exception}"

    # After render, there should be tabs or content related to the thesis
    # At minimum, no error should be shown (not st.error)
    error_texts = [e.value for e in at.error]
    assert not error_texts, f"Unexpected errors after validation: {error_texts}"

    # Cost footer caption should include "thesis_id"
    caption_texts = [c.value for c in at.caption]
    assert any("thesis_id" in c for c in caption_texts), (
        f"Expected cost/thesis_id caption; got: {caption_texts}"
    )
