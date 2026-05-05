"""Tests for ClaudeLLMPerspectiveAdapter — model routing + per-role overrides.

S43b-BULL: validates the new `role_model_overrides` field added to fix
DEFER-S43b-3 (bull sonnet 300s timeout reproduces 2/2 dogfood runs).

Pure unit tests — transport is a stub; no subprocess + no network.
"""

from __future__ import annotations

import asyncio
from decimal import Decimal
from typing import Any

from packages.domain.analysis.models.perspective_analysis import PerspectiveRole
from packages.infrastructure.analysis.claude_llm_perspective_adapter import (
    ClaudeLLMPerspectiveAdapter,
    _compute_cost,
)

_VALID_INNER = '{"key_points":[]}'


def _make_stub_transport() -> tuple[list[tuple[str, str, str, float]], Any]:
    """Return (calls_log, transport_callable). transport returns canned tokens."""
    calls: list[tuple[str, str, str, float]] = []

    def _stub(model: str, system_prompt: str, user_message: str, temperature: float
    ) -> tuple[str, int, int]:
        calls.append((model, system_prompt, user_message, temperature))
        return (_VALID_INNER, 100, 50)

    return calls, _stub


class _CtxStub:
    """Minimal SharedContext-like stub for adapter._context_to_str."""

    def __init__(self) -> None:
        self.ticker = type("T", (), {"symbol": "FPT"})()
        self.as_of = "2026-05-01"
        self.quotes: list[Any] = []
        self.statements = None
        self.ratios_ttm: dict[str, Any] = {}
        self.recent_news: list[Any] = []
        self.recent_claims: list[Any] = []
        self.gaps: list[str] = []


def _run(coro: Any) -> Any:
    return asyncio.get_event_loop().run_until_complete(coro) if False else asyncio.run(coro)


def test_default_routing_bear_to_sonnet() -> None:
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(transport=stub)
    _, _, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BEAR))
    assert model_id == "claude-sonnet-4-6"
    assert calls[0][0] == "claude-sonnet-4-6"


def test_default_routing_bull_to_sonnet() -> None:
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(transport=stub)
    _, _, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BULL))
    assert model_id == "claude-sonnet-4-6"
    assert calls[0][0] == "claude-sonnet-4-6"


def test_default_routing_quant_to_opus() -> None:
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(transport=stub)
    _, _, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.QUANT))
    assert model_id == "claude-opus-4-7"
    assert calls[0][0] == "claude-opus-4-7"


def test_role_override_bull_to_haiku_leaves_bear_and_quant_intact() -> None:
    """S43b-BULL fix: BULL → haiku; BEAR and QUANT keep their default routing."""
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(
        transport=stub,
        role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"},
    )

    _, _, bear_model, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BEAR))
    _, _, bull_model, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BULL))
    _, _, quant_model, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.QUANT))

    assert bear_model == "claude-sonnet-4-6"
    assert bull_model == "claude-haiku-4-5"
    assert quant_model == "claude-opus-4-7"
    assert [c[0] for c in calls] == [
        "claude-sonnet-4-6",
        "claude-haiku-4-5",
        "claude-opus-4-7",
    ]


def test_global_model_override_beats_role_override() -> None:
    """If `model_override` is set it wins over per-role overrides (test-time hammer)."""
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(
        transport=stub,
        model_override="claude-opus-4-7",
        role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"},
    )
    _, _, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BULL))
    assert model_id == "claude-opus-4-7"


def test_haiku_cost_computation_uses_haiku_rates() -> None:
    """Haiku 4.5 = $1.00/MTok in + $5.00/MTok out (Anthropic public pricing)."""
    cost = _compute_cost("claude-haiku-4-5", input_tokens=1_000_000, output_tokens=200_000)
    # 1.00 * 1.0 + 5.00 * 0.2 = 2.00
    assert cost == Decimal("2.00")


def test_haiku_cost_returned_via_call_llm_path() -> None:
    """End-to-end: role override → haiku → adapter computes cost via haiku rates."""
    _, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(
        transport=stub,
        role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"},
    )
    _, cost_usd, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BULL))
    assert model_id == "claude-haiku-4-5"
    # 100 in * $1/MTok + 50 out * $5/MTok = 0.0001 + 0.00025 = 0.00035
    assert cost_usd == Decimal("0.00035")


def test_role_override_with_unknown_role_fallback() -> None:
    """role_model_overrides maps only declared roles; missing roles fall through default."""
    _, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(
        transport=stub,
        role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"},
    )
    _, _, bear_model, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BEAR))
    assert bear_model == "claude-sonnet-4-6"
