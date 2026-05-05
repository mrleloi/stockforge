"""Tests for subagent_transport — claude CLI subprocess as LLM substrate.

Mocks `subprocess.run` so no real CLI invocation in CI.
"""

from __future__ import annotations

import json
import subprocess
from unittest.mock import patch

import pytest

from packages.infrastructure.analysis.subagent_transport import (
    SubagentSubstrateError,
    _aggregate_input_tokens,
    _unwrap_fence,
    claude_cli_transport,
)

_SAMPLE_USAGE = {
    "input_tokens": 10,
    "output_tokens": 754,
    "cache_creation_input_tokens": 30038,
    "cache_read_input_tokens": 0,
}

_SAMPLE_INNER_JSON = '{"key_points":[{"category":"VALUATION","statement":"x","severity":"HIGH"}]}'


def _make_envelope(
    *,
    result_text: str = _SAMPLE_INNER_JSON,
    is_error: bool = False,
    usage: dict[str, int] | None = None,
    total_cost_usd: float = 0.041,
) -> str:
    return json.dumps(
        {
            "type": "result",
            "subtype": "success",
            "is_error": is_error,
            "result": result_text,
            "usage": usage if usage is not None else _SAMPLE_USAGE,
            "total_cost_usd": total_cost_usd,
        }
    )


def _fake_run(
    *,
    returncode: int = 0,
    stdout: str = "",
    stderr: str = "",
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess(
        args=["claude"], returncode=returncode, stdout=stdout, stderr=stderr
    )


# ---------- _unwrap_fence ----------


def test_unwrap_fence_with_json_label() -> None:
    assert _unwrap_fence('```json\n{"a":1}\n```') == '{"a":1}'


def test_unwrap_fence_without_label() -> None:
    assert _unwrap_fence('```\n{"a":1}\n```') == '{"a":1}'


def test_unwrap_fence_no_fence_returns_as_is() -> None:
    assert _unwrap_fence('{"a":1}') == '{"a":1}'


def test_unwrap_fence_with_surrounding_whitespace() -> None:
    assert _unwrap_fence('  \n```json\n{"a":1}\n```\n  ') == '{"a":1}'


def test_unwrap_fence_with_prose_preamble_extracts_inner_fence() -> None:
    """LLM often adds prose preamble before the fenced JSON (real failure mode S43b)."""
    text = '## BEAR Analysis\n\nAfter examining ...\n\n```json\n{"key_points":[]}\n```\n'
    assert _unwrap_fence(text) == '{"key_points":[]}'


def test_unwrap_fence_with_prose_takes_last_inner_fence() -> None:
    """If multiple fenced blocks (rare), take the last — typically the answer."""
    text = '```json\n{"draft":1}\n```\n\nNow the final answer:\n\n```json\n{"final":2}\n```'
    assert _unwrap_fence(text) == '{"final":2}'


def test_unwrap_fence_no_fence_extracts_first_json_object() -> None:
    """LLM emits prose then bare JSON without fence."""
    text = 'Here is my analysis.\n{"key_points": [{"a": 1}]} And done.'
    assert _unwrap_fence(text) == '{"key_points": [{"a": 1}]}'


def test_unwrap_fence_handles_braces_inside_strings() -> None:
    """Brace-depth scanner must skip braces that appear inside string literals."""
    text = '{"text": "this has {curly} braces inside"}'
    assert _unwrap_fence(text) == '{"text": "this has {curly} braces inside"}'


def test_unwrap_fence_pure_prose_returns_as_is() -> None:
    """If no JSON anywhere, downstream parse will fail with a diagnostic — extractor
    returns text unchanged."""
    assert _unwrap_fence('not json at all') == 'not json at all'


# ---------- _aggregate_input_tokens ----------


def test_aggregate_input_tokens_sums_three_buckets() -> None:
    assert _aggregate_input_tokens(_SAMPLE_USAGE) == 30048  # 10 + 30038 + 0


def test_aggregate_input_tokens_handles_missing_keys() -> None:
    assert _aggregate_input_tokens({}) == 0


def test_aggregate_input_tokens_skips_non_numeric() -> None:
    assert _aggregate_input_tokens({"input_tokens": "bad", "output_tokens": 99}) == 0


# ---------- claude_cli_transport (mocked subprocess) ----------


def test_transport_happy_path_returns_unwrapped_text_and_tokens() -> None:
    fake = _fake_run(stdout=_make_envelope(result_text=f"```json\n{_SAMPLE_INNER_JSON}\n```"))
    with patch.object(subprocess, "run", return_value=fake) as run_mock:
        text, in_tok, out_tok = claude_cli_transport(
            model="claude-haiku-4-5-20251001",
            system_prompt="You are a Bear analyst.",
            user_message="Ticker BID. Latest close 12345.",
            temperature=0.0,
        )

    assert text == _SAMPLE_INNER_JSON
    assert in_tok == 30048  # aggregated
    assert out_tok == 754
    # Verify CLI flags wired correctly
    call_args = run_mock.call_args
    cmd = call_args.kwargs.get("args") or call_args.args[0]
    assert "claude" in cmd[0]
    assert "-p" in cmd
    assert "--model" in cmd
    assert "claude-haiku-4-5-20251001" in cmd
    assert "--output-format" in cmd
    assert "json" in cmd


def test_transport_raises_on_non_zero_exit() -> None:
    fake = _fake_run(returncode=4, stderr="auth required")
    with (
        patch.object(subprocess, "run", return_value=fake),
        pytest.raises(SubagentSubstrateError, match="exit 4"),
    ):
        claude_cli_transport("haiku", "sys", "user", 0.0)


def test_transport_raises_on_is_error_envelope() -> None:
    fake = _fake_run(stdout=_make_envelope(is_error=True, result_text="Not logged in"))
    with (
        patch.object(subprocess, "run", return_value=fake),
        pytest.raises(SubagentSubstrateError, match="api_error_status"),
    ):
        claude_cli_transport("haiku", "sys", "user", 0.0)


def test_transport_raises_on_non_json_stdout() -> None:
    fake = _fake_run(stdout="not json at all")
    with (
        patch.object(subprocess, "run", return_value=fake),
        pytest.raises(SubagentSubstrateError, match="non-JSON"),
    ):
        claude_cli_transport("haiku", "sys", "user", 0.0)


def test_transport_raises_on_timeout() -> None:
    def _raise_timeout(*_args: object, **_kwargs: object) -> None:
        raise subprocess.TimeoutExpired(cmd=["claude"], timeout=300)

    with (
        patch.object(subprocess, "run", side_effect=_raise_timeout),
        pytest.raises(SubagentSubstrateError, match="timeout"),
    ):
        claude_cli_transport("haiku", "sys", "user", 0.0)


def test_transport_raises_on_cli_not_found() -> None:
    with (
        patch.object(subprocess, "run", side_effect=FileNotFoundError("claude")),
        pytest.raises(SubagentSubstrateError, match="not found"),
    ):
        claude_cli_transport("haiku", "sys", "user", 0.0)


def test_transport_handles_missing_usage_field() -> None:
    envelope = json.dumps({"is_error": False, "result": _SAMPLE_INNER_JSON})
    fake = _fake_run(stdout=envelope)
    with patch.object(subprocess, "run", return_value=fake):
        text, in_tok, out_tok = claude_cli_transport("haiku", "sys", "user", 0.0)
    assert text == _SAMPLE_INNER_JSON
    assert in_tok == 0
    assert out_tok == 0


def test_transport_temperature_arg_accepted_but_unused() -> None:
    fake = _fake_run(stdout=_make_envelope())
    with patch.object(subprocess, "run", return_value=fake) as run_mock:
        claude_cli_transport("haiku", "sys", "user", temperature=0.7)
    cmd = run_mock.call_args.args[0]
    assert "--temperature" not in cmd  # CLI does not expose this flag
