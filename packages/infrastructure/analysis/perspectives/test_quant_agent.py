"""Unit tests for QuantPerspectiveAgent retry-validator path (ADR D-054 S242).

Tests cover:
  TC-quant-1:  _validate_quant_output: JSON parse fail → (False, reason)
  TC-quant-2:  _validate_quant_output: empty key_points list → (False, reason)
  TC-quant-3:  _validate_quant_output: missing 'category' field → (False, reason)
  TC-quant-4:  _validate_quant_output: missing 'as_of' field → (False, reason)
  TC-quant-5:  _validate_quant_output: valid output → (True, None)
  TC-quant-6:  _validate_quant_output: top-level not dict → (False, reason)
  TC-quant-7:  _analyze_with_retry: max 2 attempts (abbreviated vs bear 3)
  TC-quant-8:  _analyze_with_retry: double fail → empty PerspectiveAnalysis + exhausted log
  TC-quant-9:  _analyze_with_retry: LLM exception becomes validation_error (not propagated)
  TC-quant-10: role_timeout_override: quant transport configured with 180s timeout

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
from packages.infrastructure.analysis.perspectives.quant_agent import (  # noqa: PLC2701
    QuantPerspectiveAgent,
    _validate_quant_output,
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_valid_raw(num_points: int = 3) -> str:
    """Build a valid quant output JSON string with num_points key_points.

    Quant has NO >=3-distinct-cats gate (unlike bear). Any valid structural output passes.
    """
    cats = ["P/E", "P/B", "ROE", "D/E", "MARGIN_OF_SAFETY"]
    points = []
    for i in range(num_points):
        cat = cats[i % len(cats)]
        points.append({
            "text": f"Ratio {cat}: interpretation.",
            "category": cat,
            "as_of": "2026-05-01",
            "conviction": "moderate",
            "source_url": "-- query: SELECT pe FROM ratios WHERE ticker='FPT'",
            "source_excerpt": "pe=12.5 as of 2026-05-01",
            "key_phrases": [f"ratio_{i}"],
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
        self.call_count: int = 0

    async def call_llm(
        self,
        system_prompt: str,
        context: object,  # noqa: ARG002
        role: object,  # noqa: ARG002
    ) -> tuple[str, float, str, str]:
        self.captured_prompts.append(system_prompt)
        self.call_count += 1
        raw = self._responses[self._idx % len(self._responses)]
        self._idx += 1
        return (raw, 0.15, "claude-opus-4-7", "hash789")


class _ErrorAdapterStub:
    """Adapter stub that always raises an exception."""

    def __init__(self, exc: Exception) -> None:
        self._exc = exc
        self.call_count: int = 0
        self.captured_prompts: list[str] = []

    async def call_llm(
        self,
        system_prompt: str,
        context: object,  # noqa: ARG002
        role: object,  # noqa: ARG002
    ) -> tuple[str, float, str, str]:
        self.captured_prompts.append(system_prompt)
        self.call_count += 1
        raise self._exc


# ---------------------------------------------------------------------------
# TC-quant-1 through TC-quant-6: _validate_quant_output unit tests
# ---------------------------------------------------------------------------


def test_validate_quant_output_json_parse_fail() -> None:
    """TC-quant-1: Returns (False, reason) on JSON parse error."""
    valid, reason = _validate_quant_output("not valid json {{{")
    assert valid is False
    assert reason is not None
    assert "JSON parse error" in reason


def test_validate_quant_output_empty_key_points_fail() -> None:
    """TC-quant-2: Returns (False, reason) when key_points list is empty."""
    raw = json.dumps({"key_points": []})
    valid, reason = _validate_quant_output(raw)
    assert valid is False
    assert reason is not None
    assert "empty" in reason.lower()


def test_validate_quant_output_missing_category_fail() -> None:
    """TC-quant-3: Returns (False, reason) when a key_point is missing 'category'."""
    raw = json.dumps({
        "key_points": [
            {
                "text": "Ratio interpretation with no category.",
                "as_of": "2026-05-01",
                "conviction": "moderate",
                "source_url": "-- query: SELECT pe FROM ratios",
                "source_excerpt": "pe=12.5",
            }
        ]
    })
    valid, reason = _validate_quant_output(raw)
    assert valid is False
    assert reason is not None
    assert "category" in reason


def test_validate_quant_output_missing_as_of_fail() -> None:
    """TC-quant-4: Returns (False, reason) when a key_point is missing 'as_of'."""
    raw = json.dumps({
        "key_points": [
            {
                "text": "Ratio with no as_of.",
                "category": "P/E",
                "conviction": "moderate",
                "source_url": "-- query: SELECT pe FROM ratios",
                "source_excerpt": "pe=12.5",
            }
        ]
    })
    valid, reason = _validate_quant_output(raw)
    assert valid is False
    assert reason is not None
    assert "as_of" in reason


def test_validate_quant_output_valid_returns_true() -> None:
    """TC-quant-5: Returns (True, None) on valid output.

    NOTE: Quant has NO >=3-distinct-cats gate (bears the I-S10 gate, not quant).
    Even 1 valid point with category+as_of+text passes quant validation.
    """
    raw = _make_valid_raw(num_points=1)
    valid, reason = _validate_quant_output(raw)
    assert valid is True
    assert reason is None


def test_validate_quant_output_not_top_level_dict_fail() -> None:
    """TC-quant-6: Returns (False, reason) when top-level structure is not a dict."""
    raw = json.dumps([{"key_points": []}])
    valid, reason = _validate_quant_output(raw)
    assert valid is False
    assert reason is not None
    assert "dict" in reason


# ---------------------------------------------------------------------------
# TC-quant-7 through TC-quant-10: _analyze_with_retry integration tests
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_analyze_with_retry_max_2_attempts() -> None:
    """TC-quant-7: Quant retry budget is max 2 (abbreviated vs bear 3).

    On 1st fail + 2nd success, total calls = 2. Verifies abbreviated budget.
    """
    invalid_raw = json.dumps({"key_points": []})  # structural fail (empty list)
    valid_raw = _make_valid_raw(num_points=2)

    adapter = _AdapterStub([invalid_raw, valid_raw])
    agent = QuantPerspectiveAgent(adapter)
    ticker = Ticker("FPT")
    ctx = _CtxStub()

    result = await agent.analyze(ticker, ctx, PerspectiveRole.QUANT)

    # Exactly 2 calls made (1 fail + 1 success within 2-attempt budget)
    assert adapter.call_count == 2
    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 2
    # Cumulative cost: 2 attempts × $0.15
    assert result.cost_usd == Decimal("0.30")


@pytest.mark.asyncio
async def test_analyze_with_retry_double_fail_returns_empty_with_log(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-quant-8: Both attempts fail → empty PerspectiveAnalysis + quant_failure_mode log.

    Quant exhaustion at 2 attempts (not 3 — abbreviated budget per ADR D-054 B5).
    """
    invalid_raw = json.dumps({"key_points": []})

    adapter = _AdapterStub([invalid_raw])  # always returns bad response
    agent = QuantPerspectiveAgent(adapter)
    ticker = Ticker("BVH")
    ctx = _CtxStub()

    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.quant_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.QUANT)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    assert result.overall_conviction == Conviction.WEAK
    # Cumulative cost: 2 attempts × $0.15
    assert result.cost_usd == Decimal("0.30")
    # Only 2 calls total (not 3 — quant has 2-attempt budget)
    assert adapter.call_count == 2
    # Explicit warning with validation-exhausted marker
    exhausted_logs = [
        r for r in caplog.records if "validation-exhausted" in r.message.lower()
    ]
    assert len(exhausted_logs) >= 1
    # quant_failure_mode marker in the log message
    quant_mode_logs = [
        r for r in caplog.records if "quant_failure_mode" in r.message
    ]
    assert len(quant_mode_logs) >= 1


@pytest.mark.asyncio
async def test_analyze_with_retry_handles_llm_exception_as_validation_error(
    caplog: pytest.LogCaptureFixture,
) -> None:
    """TC-quant-9: LLM exception (e.g. timeout) becomes validation_error; does NOT propagate.

    Quant timeout does NOT trip I-S10 (which governs bear only). Agent catches
    the exception inside the retry loop and returns empty PerspectiveAnalysis.
    This prevents asyncio.gather cascade (ADR D-054 root-cause fix).
    """
    from packages.infrastructure.analysis.subagent_transport import (
        SubagentSubstrateError,
    )

    exc = SubagentSubstrateError("claude CLI timeout after 180s")
    adapter = _ErrorAdapterStub(exc)
    agent = QuantPerspectiveAgent(adapter)
    ticker = Ticker("GAS")
    ctx = _CtxStub()

    # Must NOT raise — exception must be caught inside agent
    with caplog.at_level(
        logging.WARNING,
        logger="packages.infrastructure.analysis.perspectives.quant_agent",
    ):
        result = await agent.analyze(ticker, ctx, PerspectiveRole.QUANT)

    assert isinstance(result, PerspectiveAnalysis)
    assert len(result.key_points) == 0
    # Cost = 0 because all attempts raised before returning cost
    assert result.cost_usd == Decimal("0")
    # Only 2 calls attempted (abbreviated 2-attempt budget)
    assert adapter.call_count == 2
    # Validation-exhausted log emitted
    exhausted_logs = [
        r for r in caplog.records if "validation-exhausted" in r.message.lower()
    ]
    assert len(exhausted_logs) >= 1


def test_role_timeout_override_quant_uses_180s() -> None:
    """TC-quant-10: Subagent transport _ROLE_TIMEOUT_OVERRIDES has quant=180s (ADR D-054 B5).

    Verifies the per-role timeout config exists and is correctly set to 180s for quant.
    Bear and bull default to _DEFAULT_TIMEOUT_SEC (300s).
    """
    from packages.infrastructure.analysis.subagent_transport import (
        _DEFAULT_TIMEOUT_SEC,
        _ROLE_TIMEOUT_OVERRIDES,
    )

    # Quant should have a 180s override
    assert "quant" in _ROLE_TIMEOUT_OVERRIDES, (
        "quant role must have a per-role timeout override in _ROLE_TIMEOUT_OVERRIDES"
    )
    assert _ROLE_TIMEOUT_OVERRIDES["quant"] == 180, (
        f"quant timeout should be 180s; got {_ROLE_TIMEOUT_OVERRIDES['quant']}"
    )

    # Bear and bull should use the default timeout (not overridden)
    assert "bear" not in _ROLE_TIMEOUT_OVERRIDES, (
        "bear should use default timeout (300s); should NOT be in _ROLE_TIMEOUT_OVERRIDES"
    )
    assert "bull" not in _ROLE_TIMEOUT_OVERRIDES, (
        "bull should use default timeout (300s); should NOT be in _ROLE_TIMEOUT_OVERRIDES"
    )

    # Default timeout should be 300s
    assert _DEFAULT_TIMEOUT_SEC == 300, (
        f"default timeout should be 300s; got {_DEFAULT_TIMEOUT_SEC}"
    )
