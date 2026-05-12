"""Subagent transport — claude CLI subprocess as zero-marginal-cost LLM substrate.

Drop-in replacement for the default `transport` callable in
`ClaudeLLMPerspectiveAdapter`. Bills against Claude Code subscription
(parent OAuth/keychain) — no separate ANTHROPIC_API_KEY required.

Source: agent-workspace/memory/checkpoints/latest.md § "User insight mid-S38"
        + L-S38-2 lesson candidate (subagent dispatch as LLM substrate)
        + S43b probe 2026-05-01 (research/r-2026-05-01-claude-cli-substrate.md)

Mechanism:
    subprocess.run([
        "claude", "-p",
        "--model", <model>,
        "--output-format", "json",
        "--disable-slash-commands",
        "--system-prompt", <system_prompt>,
    ], input=<user_message>, ...)

Returns CLI JSON envelope:
    {"result": "<model output (often wrapped in ```json fence)>",
     "total_cost_usd": <float>,
     "usage": {"input_tokens", "output_tokens",
               "cache_creation_input_tokens", "cache_read_input_tokens"},
     "is_error": <bool>, ...}

Adapter signature returns (text, input_tokens, output_tokens). We aggregate
input_tokens = input + cache_creation + cache_read (cache_read charged at
~10% but bundled approximation is sufficient for cost tracking; exact
total_cost_usd is logged separately for audit).

Trade-offs vs anthropic SDK direct:
- (+) No API key required; bills against subscription
- (+) Exact cost reported by CLI (logged at log.info)
- (-) No `temperature` control — CLI uses model defaults
- (-) Per-call latency 15-30s (subprocess overhead + CLAUDE.md cache creation)
- (-) Response often wrapped in ```json fence — stripped by `_unwrap_fence`
"""

from __future__ import annotations

import json
import logging
import re
import subprocess
from collections.abc import Mapping

__all__ = [
    "SubagentSubstrateError",
    "claude_cli_transport",
]

log = logging.getLogger(__name__)

_INNER_FENCE_RE = re.compile(r"```(?:json)?\s*\n(.*?)\n```", re.DOTALL)
_DEFAULT_TIMEOUT_SEC = 300

# Per-role timeout overrides (ADR D-054 B5 asymmetric budget).
# Quant uses 180s: interpretive-not-generative; tighter envelope keeps cost under cap.
# Bear/Bull default to _DEFAULT_TIMEOUT_SEC (300s).
# Keys are PerspectiveRole string values to avoid circular import from domain.
_ROLE_TIMEOUT_OVERRIDES: dict[str, int] = {
    "quant": 180,
}


class SubagentSubstrateError(RuntimeError):
    """Raised when claude CLI subprocess substrate fails irrecoverably."""


def _unwrap_fence(text: str) -> str:
    """Extract JSON content from LLM response.

    Order of attempts:
    1. Fenced block(s) anywhere in the text: ```json...``` — return LAST match
       (LLMs often add prose preamble + final answer in fence; sometimes
       multiple fences appear, the last one is typically the actual answer).
       This subsumes the whole-text-wrap case.
    2. First balanced top-level {...}: model emits prose then a JSON object
       without fence → extract via brace-depth scan.
    3. Return as-is (downstream JSON parse will fail with diagnostic).
    """
    inner_matches = _INNER_FENCE_RE.findall(text)
    if inner_matches:
        last_match = inner_matches[-1]
        return str(last_match)

    brace_match = _extract_first_json_object(text)
    if brace_match is not None:
        return brace_match

    return text


def _extract_first_json_object(text: str) -> str | None:
    """Scan for the first balanced top-level {...} block. None if not found.

    Naive brace-depth counter; ignores braces inside strings to avoid false
    positives. Sufficient for LLM JSON output which doesn't embed weird
    string-escape patterns.
    """
    depth = 0
    start = -1
    in_string = False
    escape = False
    for i, ch in enumerate(text):
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
            continue
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0 and start >= 0:
                return text[start : i + 1]
    return None


def _aggregate_input_tokens(usage: Mapping[str, object]) -> int:
    """Sum input + cache_creation + cache_read for cost-tracking parity.

    cache_read is charged at ~10% but conservative aggregation is fine:
    the adapter's CostTrackerPort uses these token counts for budget cap;
    over-estimating cost is safer than under-estimating.
    """

    def _i(k: str) -> int:
        v = usage.get(k, 0)
        return int(v) if isinstance(v, (int, float)) else 0

    return _i("input_tokens") + _i("cache_creation_input_tokens") + _i("cache_read_input_tokens")


def claude_cli_transport(
    model: str,
    system_prompt: str,
    user_message: str,
    temperature: float,  # noqa: ARG001 — accepted for signature compatibility
    role: str | None = None,
) -> tuple[str, int, int]:
    """Call claude CLI in print mode and return (text, input_tokens, output_tokens).

    `temperature` is accepted for signature compatibility but ignored — claude
    CLI does not expose a temperature flag (uses model defaults).

    `role` is the PerspectiveRole string value used to look up per-role timeout
    override from _ROLE_TIMEOUT_OVERRIDES (ADR D-054 B5 asymmetric budget).
    None defaults to _DEFAULT_TIMEOUT_SEC (300s).
    """
    timeout_sec = _ROLE_TIMEOUT_OVERRIDES.get(role or "", _DEFAULT_TIMEOUT_SEC)
    cmd = [
        "claude",
        "-p",
        "--model",
        model,
        "--output-format",
        "json",
        "--disable-slash-commands",
        "--system-prompt",
        system_prompt,
    ]
    try:
        proc = subprocess.run(
            cmd,
            input=user_message,
            capture_output=True,
            text=True,
            encoding="utf-8",  # Windows: avoid cp1252 default that crashes on UTF-8 bytes
            errors="replace",
            timeout=timeout_sec,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise SubagentSubstrateError(f"claude CLI timeout after {timeout_sec}s") from exc
    except FileNotFoundError as exc:
        raise SubagentSubstrateError("claude CLI not found on PATH") from exc

    if proc.returncode != 0:
        raise SubagentSubstrateError(
            f"claude CLI exit {proc.returncode}: {proc.stderr[:500]}"
        )

    try:
        envelope = json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise SubagentSubstrateError(
            f"claude CLI returned non-JSON: {proc.stdout[:500]}"
        ) from exc

    if envelope.get("is_error"):
        raise SubagentSubstrateError(
            f"claude CLI api_error_status={envelope.get('api_error_status')} "
            f"result={str(envelope.get('result'))[:200]}"
        )

    text = _unwrap_fence(str(envelope.get("result", "")))
    usage = envelope.get("usage") or {}
    if not isinstance(usage, dict):
        usage = {}

    in_tok = _aggregate_input_tokens(usage)
    out_tok_v = usage.get("output_tokens", 0)
    out_tok = int(out_tok_v) if isinstance(out_tok_v, (int, float)) else 0
    cli_cost = envelope.get("total_cost_usd")
    log.info(
        "subagent_transport: model=%s in_tok=%d out_tok=%d cli_cost_usd=%s",
        model,
        in_tok,
        out_tok,
        cli_cost,
    )
    return text, in_tok, out_tok
