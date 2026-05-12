"""Unit tests for BearPerspectiveAgent retry-validator path (ADR D-054 S242).

Tests cover:
  TC-bear-1:  _validate_bear_output: JSON parse fail → (False, reason)
  TC-bear-2:  _validate_bear_output: empty key_points list → (False, reason)
  TC-bear-3:  _validate_bear_output: missing 'category' field → (False, reason)
  TC-bear-4:  _validate_bear_output: missing 'as_of' field → (False, reason)
  TC-bear-5:  _validate_bear_output: <3 distinct categories → (False, reason) [I-S10]
  TC-bear-6:  _validate_bear_output: valid output with >=3 distinct cats → (True, None)
  TC-bear-7:  _validate_bear_output: top-level not dict → (False, reason)
  TC-bear-8:  _analyze_with_retry: 1st JSON parse fail then success → returns valid output
  TC-bear-9:  _analyze_with_retry: 1st structural fail then success → returns valid output
  TC-bear-10: _analyze_with_retry: triple fail → empty PerspectiveAnalysis + exhausted log
  TC-bear-11: _analyze_with_retry: re-prompt on attempt 2+ includes validation error excerpt
  TC-bear-12: _analyze_with_retry: LLM exception becomes validation_error (not propagated)

No subprocess, no network. All transport calls are stubs.
"""

from __future__ import annotations

import json
import logging
from decimal import Decimal

import pytest

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.infrastructure.analysis.perspectives.bear_agent import (  # noqa: PLC2701
    BearPerspectiveAgent,
    _validate_bear_output,
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_valid_raw(
    num_points: int = 3,
    distinct_cats: bool = True,
) -> str:
    """Build a valid bear output JSON string with num_points key_points.

    Distinct categories: FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, MACRO, GOVERNANCE.
    When distinct_cats=False, all points share FUNDAMENTAL (triggers I-S10 fail).
    """
    cats = [
        "FUNDAMENTAL",
        "STRUCTURAL",
        "VALUATION",
        "COMPETITIVE",
        "MACRO",
        "GOVERNANCE",
    ]
    points = []
    for i in range(num_points):
        cat = cats[i % len(cats)] if distinct_cats else cats[0]
        points.append({
            "text": f"Bear risk {i + 1}: credible downside signal.",
            "category": cat,
            "as_of": "2026-05-01",
            "conviction": "moderate",
            "source_url": "https://example.com/filing",
            "source_excerpt": "Verbatim excerpt supporting the bear thesis.",
            "key_phrases": [f"risk_{i}"],
        })
    return json.dumps({"key_points": points})


class _CtxStub:
    """Minimal SharedContext stub with as_of + ticker."""

    def __init__(self) -> None:
        self.as_of = "2026-05-01"
        self.ticker = type("T", (), {"symbol": "FPT"})()


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
        return (raw, 0.10, "claude-sonnet-4-6", "hash456")


class _ErrorAdapterStub:
    """Adapter stub that raises an exception on each call."""

    def __init__(self, exc: Exception, fallback_after: int = 0) -> None:
        """Raise exc for first `fallback_after` calls, then return valid JSON."""
        self._exc = exc
        self._fallback_after = fallback_after
        self._call_count: int = 0
        self.captured_prompts: list[str] = []

    async def call_llm(
        self,
        system_prompt: str,
        context: object,  # noqa: ARG002
        role: object,  # noqa: ARG002
    ) -> tuple[str, float, str, str]:
        self.captured_prompts.append(system_prompt)
        self._call_count += 1
        if self._call_count <= self._fallback_after or self._fallback_after == 0:
            raise self._exc
        return (_make_valid_raw(3), 0.10, "claude-sonnet-4-6", "hash456")


# ---------------------------------------------------------------------------
# TC-bear-1 through TC-bear-7: _validate_bear_output unit tests
# ---------------------------------------------------------------------------


def test_validate_bear_output_json_parse_fail() -> None:
    """TC-bear-1: Returns (False, reason) on JSON parse error."""
    valid, reason = _validate_bear_output("not valid json {{{")
    assert valid is False
    assert reason is not None
    assert "JSON parse error" in reason


def test_validate_bear_output_empty_key_points_fail() -> None:
    """TC-bear-2: Returns (False, reason) when key_points list is empty."""
    raw = json.dumps({"key_points": []})
    valid, reason = _validate_bear_output(raw)
    assert valid is False
    assert reason is not None
    assert "empty" in reason.lower()


def test_validate_bear_output_missing_category_fail() -> None:
    """TC-bear-3: Returns (False, reason) when a key_point is missing 'category'."""
    raw = json.dumps({
        "key_points": [
            {
                "text": "Bear point with no category.",
                "as_of": "2026-05-01",
                "conviction": "moderate",
                "source_url": "https://example.com",
                "source_excerpt": "excerpt",
            }
        ]
    })
    valid, reason = _validate_bear_output(raw)
    assert valid is False
    assert reason is not None
    assert "category" in reason


def test_validate_bear_output_missing_as_of_fail() -> None:
    """TC-bear-4: Returns (False, reason) when a key_point is missing 'as_of'."""
    raw = json.dumps({
        "key_points": [
            {
                "text": "Bear point with no as_of.",
                "category": "FUNDAMENTAL",
                "conviction": "moderate",
                "source_url": "https://example.com",
                "source_excerpt": "excerpt",
            }
        ]
    })
    valid, reason = _validate_bear_output(raw)
    assert valid is False
    assert reason is not None
    assert "as_of" in reason


def test_validate_bear_output_lt_3_distinct_cats_fail() -> None:
    """TC-bear-5: Returns (False, reason) when <3 distinct categories (I-S10 gate).

    This is the bear-specific check that does NOT exist for bull or quant.
    Even with multiple points, if they share categories, validation fails.
    """
    # 3 points but only 2 distinct categories
    raw = json.dumps({
        "key_points": [
            {"text": "Risk A", "category": "FUNDAMENTAL", "as_of": "2026-05-01",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Risk B", "category": "FUNDAMENTAL", "as_of": "2026-05-01",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Risk C", "category": "VALUATION", "as_of": "2026-05-01",
             "source_url": "https://x.com", "source_excerpt": "e"},
        ]
    })
    valid, reason = _validate_bear_output(raw)
    assert valid is False
    assert reason is not None
    assert "I-S10" in reason
    assert "2" in reason  # mentions count of distinct cats found


def test_validate_bear_output_valid_returns_true() -> None:
    """TC-bear-6: Returns (True, None) on valid output with >=3 distinct categories."""
    raw = _make_valid_raw(num_points=3, distinct_cats=True)
    valid, reason = _validate_bear_output(raw)
    assert valid is True
    assert reason is None


def test_validate_bear_output_not_top_level_dict_fail() -> None:
    """TC-bear-7: Returns (False, reason) when top-level structure is not a dict."""
    raw = json.dumps([{"key_points": []}])
    valid, reason = _validate_bear_output(raw)
    assert valid is False
    assert reason is not None
    assert "dict" in reason


# ---------------------------------------------------------------------------
# TC-bear-8 through TC-bear-12: _analyze_with_retry integration tests
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_analyze_with_retry_json_parse_fail_then_success() -> None:
    """TC-bear-8: Retries on 1st JSON parse failure, succeeds on retry → returns valid output."""
    invalid_raw = "not valid json {{{"
    valid_raw = _make_valid_raw(num_points=3)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = BearPerspectiveAgent(adapter)
    ticker = Ticker("FPT")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.BEAR)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 3
    # Cumulative cost: 2 attempts × $0.10
    assert result.cost_usd == Decimal("0.20")


@pytest.mark.asyncio
async def test_analyze_with_retry_structural_fail_then_success() -> None:
    """TC-bear-9: Retries on 1st structural validation failure, succeeds on retry."""
    # Valid JSON but empty list — structural fail
    invalid_raw = json.dumps({"key_points": []})
    valid_raw = _make_valid_raw(num_points=3)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = BearPerspectiveAgent(adapter)
    ticker = Ticker("CTG")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.BEAR)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 3
    # Cumulative cost: 2 attempts × $0.10
    assert result.cost_usd == Decimal("0.20")


@pytest.mark.asyncio
async def test_analyze_with_retry_triple_fail_returns_empty_with_log(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-bear-10: All 3 attempts fail → empty PerspectiveAnalysis + bear_failure_mode log."""
    # Always fails: only 1 category across 3 points (I-S10 fail)
    invalid_raw = _make_valid_raw(num_points=3, distinct_cats=False)

    adapter = _AdapterStub([invalid_raw])  # cycles through same bad response
    agent = BearPerspectiveAgent(adapter)
    ticker = Ticker("BVH")
    ctx = _CtxStub()

    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.bear_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.BEAR)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    assert result.overall_conviction == Conviction.WEAK
    # Cumulative cost: 3 attempts × $0.10
    assert result.cost_usd == Decimal("0.30")
    # Explicit warning logged with validation-exhausted marker
    exhausted_logs = [
        r for r in caplog.records if "validation-exhausted" in r.message.lower()
    ]
    assert len(exhausted_logs) >= 1


@pytest.mark.asyncio
async def test_analyze_with_retry_reprompt_includes_error_excerpt() -> None:
    """TC-bear-11: Re-prompt on attempt 2+ includes the validation error from attempt 1."""
    # Valid JSON but only 2 distinct categories → I-S10 fail
    bad_raw = json.dumps({
        "key_points": [
            {"text": "Risk", "category": "FUNDAMENTAL", "as_of": "2026-05-01",
             "source_url": "https://x.com", "source_excerpt": "e"},
            {"text": "Risk 2", "category": "VALUATION", "as_of": "2026-05-01",
             "source_url": "https://x.com", "source_excerpt": "e"},
            # Only 2 distinct categories — I-S10 fail
        ]
    })
    valid_raw = _make_valid_raw(num_points=3)

    adapter = _AdapterStub([bad_raw, valid_raw])
    agent = BearPerspectiveAgent(adapter)
    ticker = Ticker("FPT")
    ctx = _CtxStub()

    await agent.analyze(ticker, ctx, PerspectiveRole.BEAR)

    # Should have made 2 calls
    assert len(adapter.captured_prompts) == 2
    # First prompt: no RETRY header
    assert "RETRY" not in adapter.captured_prompts[0]
    # Second prompt: must contain RETRY marker and I-S10 mention
    assert "RETRY" in adapter.captured_prompts[1]
    assert "I-S10" in adapter.captured_prompts[1]


@pytest.mark.asyncio
async def test_analyze_with_retry_handles_llm_exception_as_validation_error(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-bear-12: LLM exception (e.g. timeout) becomes validation_error; does NOT propagate.

    This is the key architectural fix per ADR D-054: exceptions from the LLM call
    are caught inside the retry loop (not propagated to asyncio.gather). The agent
    returns an empty PerspectiveAnalysis rather than raising.
    """
    from packages.infrastructure.analysis.subagent_transport import (
        SubagentSubstrateError,
    )

    exc = SubagentSubstrateError("claude CLI timeout after 300s")
    # All 3 attempts raise → validation-exhausted path
    adapter = _ErrorAdapterStub(exc, fallback_after=0)
    agent = BearPerspectiveAgent(adapter)
    ticker = Ticker("GAS")
    ctx = _CtxStub()

    # Must NOT raise — exception must be caught inside agent
    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.bear_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.BEAR)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    # Cost = 0 because all attempts raised before returning cost
    assert result.cost_usd == Decimal("0")
    # Validation-exhausted log emitted
    exhausted_logs = [
        r for r in caplog.records if "validation-exhausted" in r.message.lower()
    ]
    assert len(exhausted_logs) >= 1
