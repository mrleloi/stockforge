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


# ---------------------------------------------------------------------------
# plan-034 D4 regression additions: D-052 § Implementation step 1 closure
# validates transport-flip + import anthropic removal + _default_transport removal
# ---------------------------------------------------------------------------


def test_default_transport_is_claude_cli_transport_post_d052_step1_closure() -> None:
    """plan-034 D4 TC-1: No-arg adapter uses claude_cli_transport (DD-5 transport-flip).

    Validates D-052 § Implementation step 1 final closure: transport default
    flipped from _default_transport to claude_cli_transport per plan-034 D3.
    """
    from packages.infrastructure.analysis.subagent_transport import claude_cli_transport

    adapter = ClaudeLLMPerspectiveAdapter()
    assert adapter.transport is claude_cli_transport, (
        f"Expected transport == claude_cli_transport after D-052 step 1 closure, "
        f"got {adapter.transport!r}"
    )


def test_no_anthropic_import_in_module_source() -> None:
    """plan-034 D4 TC-2: Zero 'import anthropic' / 'from anthropic' in adapter source.

    Grep-asserted per L-S227-1 + D-050 SYSTEMIC + D-052 § Implementation step 1.
    This IS the D-052 closure acceptance criterion for BC-8 surface.
    """
    import packages.infrastructure.analysis.claude_llm_perspective_adapter as mod

    source = open(mod.__file__, encoding="utf-8").read()  # noqa: SIM115, WPS515
    assert "import anthropic" not in source, (
        "import anthropic MUST NOT appear in claude_llm_perspective_adapter.py "
        "per D-050 SYSTEMIC + D-052 § Implementation step 1 + plan-034 DD-5"
    )
    assert "from anthropic" not in source, (
        "from anthropic MUST NOT appear in claude_llm_perspective_adapter.py "
        "per D-050 SYSTEMIC + D-052 § Implementation step 1 + plan-034 DD-5"
    )


def test_default_transport_function_removed_from_module() -> None:
    """plan-034 D4 TC-3: _default_transport symbol removed from adapter source.

    Validates DD-5: _default_transport function REMOVED per D-052 step 1.
    """
    import packages.infrastructure.analysis.claude_llm_perspective_adapter as mod

    source = open(mod.__file__, encoding="utf-8").read()  # noqa: SIM115, WPS515
    assert "_default_transport" not in source, (
        "_default_transport MUST be removed from claude_llm_perspective_adapter.py "
        "per plan-034 DD-5 + D-052 § Implementation step 1"
    )


def test_existing_stub_injection_still_works_post_flip() -> None:
    """plan-034 D4 TC-4: Existing _make_stub_transport() pattern works unchanged post-flip.

    Validates DD-9 backward-compat: transport=stub constructor kwarg overrides
    new default (claude_cli_transport). All existing test patterns unaffected.
    """
    calls, stub = _make_stub_transport()
    adapter = ClaudeLLMPerspectiveAdapter(transport=stub)

    # verify transport is the injected stub not claude_cli_transport
    from packages.infrastructure.analysis.subagent_transport import claude_cli_transport

    assert adapter.transport is not claude_cli_transport
    assert adapter.transport is stub

    # verify routing still works through stub
    _, _, model_id, _ = _run(adapter.call_llm("sys", _CtxStub(), PerspectiveRole.BEAR))
    assert model_id == "claude-sonnet-4-6"
    assert len(calls) == 1
