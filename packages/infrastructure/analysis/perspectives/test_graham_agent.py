"""Unit tests for GrahamPerspectiveAgent retry-validator path (plan-035 F.2).

Tests cover:
  TC-graham-1:  _validate_graham_output: JSON parse fail -> (False, reason)
  TC-graham-2:  _validate_graham_output: empty key_points list -> (False, reason)
  TC-graham-3:  _validate_graham_output: missing 'category' field -> (False, reason)
  TC-graham-4:  _validate_graham_output: missing 'as_of' field -> (False, reason)
  TC-graham-5:  _validate_graham_output: <3 distinct categories -> (False, reason)
  TC-graham-6:  _validate_graham_output: valid output with >=3 distinct cats -> (True, None)
  TC-graham-7:  _validate_graham_output: top-level not dict -> (False, reason)
  TC-graham-8:  _validate_graham_output: category not in category_universe -> (False, reason)
  TC-graham-9:  _analyze_with_retry: 1st JSON parse fail then success -> returns valid output
  TC-graham-10: _analyze_with_retry: 1st structural fail then success -> returns valid output
  TC-graham-11: _analyze_with_retry: triple fail -> empty PerspectiveAnalysis + exhausted log
  TC-graham-12: _analyze_with_retry: re-prompt on attempt 2+ includes validation error excerpt
  TC-graham-13: _analyze_with_retry: LLM exception becomes validation_error (not propagated)

No subprocess, no network. All transport calls are stubs.
Mirrors test_bear_agent.py TC structure per DD-9 (plan-035).
"""

from __future__ import annotations

import json
import logging
from decimal import Decimal

import pytest

from packages.application.analysis.role_prompt_pack import RolePromptPack
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.infrastructure.analysis.perspectives.graham_agent import (  # noqa: PLC2701
    GrahamPerspectiveAgent,
    _validate_graham_output,
)

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

_GRAHAM_CATEGORIES = (
    "EARNINGS_STABILITY",
    "BALANCE_SHEET_STRENGTH",
    "DIVIDEND_RECORD",
    "MARGIN_OF_SAFETY",
    "NCAV",
    "GRAHAM_NUMBER",
)


def _make_graham_role_pack() -> RolePromptPack:
    """Minimal RolePromptPack for Graham persona tests."""
    return RolePromptPack(
        role_id="graham",
        persona_name="Benjamin Graham (deep value + margin of safety + balance sheet)",
        system_prompt_template="You are a GRAHAM analyst for {TICKER} as of {AS_OF}.",
        conviction_guidance=(
            "STRONG = clear margin of safety + current_ratio + earnings; "
            "MODERATE = partial; WEAK = no margin of safety. "
            "Pick categorical -- do NOT emit numeric percentage."
        ),
        citation_requirements="Every claim cites source_url + source_excerpt <=500 chars.",
        vietnam_notes=(
            "VN banking NCAV LIMITED. VN real estate complex balance sheets. "
            "Current ratio threshold relax to 1.5 with caveat."
        ),
        min_points=3,
        min_distinct_categories=3,
        category_universe=_GRAHAM_CATEGORIES,
        model_id_preference="claude-sonnet-4-6",
    )


def _make_valid_graham_raw(
    num_points: int = 3,
    distinct_cats: bool = True,
) -> str:
    """Build a valid Graham output JSON string with num_points key_points."""
    cats = list(_GRAHAM_CATEGORIES)
    points = []
    for i in range(num_points):
        cat = cats[i % len(cats)] if distinct_cats else cats[0]
        points.append({
            "text": f"Graham value signal {i + 1}: quantitative safety margin.",
            "category": cat,
            "as_of": "2026-05-17",
            "conviction": "moderate",
            "source_url": "https://example.com/filing",
            "source_excerpt": "Verbatim excerpt supporting the Graham analysis.",
            "key_phrases": [f"signal_{i}"],
        })
    return json.dumps({"key_points": points})


class _CtxStub:
    """Minimal SharedContext stub."""

    def __init__(self) -> None:
        self.as_of = "2026-05-17"
        self.ticker = type("T", (), {"symbol": "VCB"})()


class _AdapterStub:
    """Adapter stub that cycles through preset responses, capturing system prompts."""

    def __init__(self, responses: list[str]) -> None:
        self._responses = responses
        self._idx: int = 0
        self.captured_prompts: list[str] = []

    async def call_llm(
        self,
        system_prompt: str,
        context: object,  # noqa: ARG002
        role: object,  # noqa: ARG002
    ) -> tuple[str, float, str, str]:
        self.captured_prompts.append(system_prompt)
        raw = self._responses[self._idx % len(self._responses)]
        self._idx += 1
        return (raw, 0.10, "claude-sonnet-4-6", "hashGraham")


class _ErrorAdapterStub:
    """Adapter stub that raises an exception on every call."""

    def __init__(self, exc: Exception) -> None:
        self._exc = exc
        self.captured_prompts: list[str] = []

    async def call_llm(
        self,
        system_prompt: str,
        context: object,  # noqa: ARG002
        role: object,  # noqa: ARG002
    ) -> tuple[str, float, str, str]:
        self.captured_prompts.append(system_prompt)
        raise self._exc


# ---------------------------------------------------------------------------
# TC-graham-1 through TC-graham-8: _validate_graham_output unit tests
# ---------------------------------------------------------------------------


def test_validate_graham_output_json_parse_fail() -> None:
    """TC-graham-1: Returns (False, reason) on JSON parse error."""
    rp = _make_graham_role_pack()
    valid, reason = _validate_graham_output("not valid json {{{", rp)
    assert valid is False
    assert reason is not None
    assert "JSON parse error" in reason


def test_validate_graham_output_empty_key_points_fail() -> None:
    """TC-graham-2: Returns (False, reason) when key_points list is empty."""
    rp = _make_graham_role_pack()
    raw = json.dumps({"key_points": []})
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "empty" in reason.lower()


def test_validate_graham_output_missing_category_fail() -> None:
    """TC-graham-3: Returns (False, reason) when a key_point is missing 'category'."""
    rp = _make_graham_role_pack()
    raw = json.dumps({
        "key_points": [
            {
                "text": "Graham point with no category.",
                "as_of": "2026-05-17",
                "conviction": "moderate",
                "source_url": "https://example.com",
                "source_excerpt": "excerpt",
            }
        ]
    })
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "category" in reason


def test_validate_graham_output_missing_as_of_fail() -> None:
    """TC-graham-4: Returns (False, reason) when a key_point is missing 'as_of'."""
    rp = _make_graham_role_pack()
    raw = json.dumps({
        "key_points": [
            {
                "text": "Graham point with no as_of.",
                "category": "EARNINGS_STABILITY",
                "conviction": "moderate",
                "source_url": "https://example.com",
                "source_excerpt": "excerpt",
            }
        ]
    })
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "as_of" in reason


def test_validate_graham_output_lt_min_distinct_cats_fail() -> None:
    """TC-graham-5: Returns (False, reason) when <3 distinct categories."""
    rp = _make_graham_role_pack()
    # 3 points but only 2 distinct valid Graham categories
    raw = json.dumps({
        "key_points": [
            {"text": "Signal A", "category": "EARNINGS_STABILITY", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Signal B", "category": "EARNINGS_STABILITY", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Signal C", "category": "MARGIN_OF_SAFETY", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
        ]
    })
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "2" in reason  # 2 distinct cats found


def test_validate_graham_output_valid_returns_true() -> None:
    """TC-graham-6: Returns (True, None) on valid output with >=3 distinct categories."""
    rp = _make_graham_role_pack()
    raw = _make_valid_graham_raw(num_points=3, distinct_cats=True)
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is True
    assert reason is None


def test_validate_graham_output_not_top_level_dict_fail() -> None:
    """TC-graham-7: Returns (False, reason) when top-level structure is not a dict."""
    rp = _make_graham_role_pack()
    raw = json.dumps([{"key_points": []}])
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "dict" in reason


def test_validate_graham_output_category_not_in_universe_fail() -> None:
    """TC-graham-8: Returns (False, reason) when category not in Graham category_universe.

    NEW per-persona check (DD-8): category must be in role_pack.category_universe.
    """
    rp = _make_graham_role_pack()
    # MOAT is a Buffett category, not in Graham universe
    raw = json.dumps({
        "key_points": [
            {"text": "Moat signal.", "category": "MOAT", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Valuation signal.", "category": "VALUATION", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Growth signal.", "category": "GROWTH", "as_of": "2026-05-17",
             "source_url": "https://x.com", "source_excerpt": "e"},
        ]
    })
    valid, reason = _validate_graham_output(raw, rp)
    assert valid is False
    assert reason is not None
    assert "category_universe" in reason or "MOAT" in reason


# ---------------------------------------------------------------------------
# TC-graham-9 through TC-graham-13: _analyze_with_retry integration tests
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_analyze_with_retry_json_parse_fail_then_success() -> None:
    """TC-graham-9: Retries on 1st JSON parse failure, succeeds on retry."""
    rp = _make_graham_role_pack()
    invalid_raw = "not valid json {{{"
    valid_raw = _make_valid_graham_raw(num_points=3)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = GrahamPerspectiveAgent(adapter, rp)
    ticker = Ticker("VCB")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.GRAHAM)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 3
    assert result.cost_usd == Decimal("0.20")


@pytest.mark.asyncio
async def test_analyze_with_retry_structural_fail_then_success() -> None:
    """TC-graham-10: Retries on 1st structural validation failure, succeeds on retry."""
    rp = _make_graham_role_pack()
    invalid_raw = json.dumps({"key_points": []})
    valid_raw = _make_valid_graham_raw(num_points=3)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = GrahamPerspectiveAgent(adapter, rp)
    ticker = Ticker("BID")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.GRAHAM)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 3
    assert result.cost_usd == Decimal("0.20")


@pytest.mark.asyncio
async def test_analyze_with_retry_triple_fail_returns_empty_with_log(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-graham-11: All 3 attempts fail -> empty PerspectiveAnalysis + exhausted log."""
    rp = _make_graham_role_pack()
    # Always fails: only 1 distinct category
    invalid_raw = _make_valid_graham_raw(num_points=3, distinct_cats=False)

    adapter = _AdapterStub([invalid_raw])
    agent = GrahamPerspectiveAgent(adapter, rp)
    ticker = Ticker("KDH")
    ctx = _CtxStub()

    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.graham_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.GRAHAM)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    assert result.overall_conviction == Conviction.WEAK
    assert result.cost_usd == Decimal("0.30")
    exhausted_logs = [
        r for r in caplog.records if "validation-exhausted" in r.message.lower()
    ]
    assert len(exhausted_logs) >= 1


@pytest.mark.asyncio
async def test_analyze_with_retry_reprompt_includes_validation_error() -> None:
    """TC-graham-12: Re-prompt on attempt 2+ includes validation error excerpt."""
    rp = _make_graham_role_pack()
    invalid_raw = json.dumps({"key_points": []})
    valid_raw = _make_valid_graham_raw(num_points=3)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = GrahamPerspectiveAgent(adapter, rp)
    ticker = Ticker("NVL")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.GRAHAM)
    assert isinstance(result, PerspectiveAnalysis)

    assert len(adapter.captured_prompts) >= 2
    second_prompt = adapter.captured_prompts[1]
    assert "ATTEMPT 2 RETRY" in second_prompt
    assert "validation" in second_prompt.lower()


@pytest.mark.asyncio
async def test_analyze_with_retry_llm_exception_becomes_validation_error(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-graham-13: LLM exception becomes validation_error (not propagated)."""
    rp = _make_graham_role_pack()
    exc = RuntimeError("LLM call timed out")
    adapter = _ErrorAdapterStub(exc)
    agent = GrahamPerspectiveAgent(adapter, rp)
    ticker = Ticker("VHM")
    ctx = _CtxStub()

    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.graham_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.GRAHAM)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    error_logs = [
        r for r in caplog.records if "LLM call error" in r.message
    ]
    assert len(error_logs) >= 1
