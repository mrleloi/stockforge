"""Subagent transport for BC-5 news claim extraction — claude CLI subprocess.

Drop-in replacement for the legacy `_default_transport` in
`ClaudeLlmExtractor`. Bills against Claude Code subscription (parent OAuth) —
no separate ANTHROPIC_API_KEY required.

Signature differs from `packages.infrastructure.analysis.subagent_transport`
because the news extractor's transport callable is `(system_prompt, body) → str`
(model + temperature are dataclass attributes, not call args). Per CLAUDE.md
hard rule "Cross-BC communication via contracts only", this module duplicates
the small `_unwrap_fence` helper rather than importing from BC-8 analysis.

Source: D-050 (anthropic→subagent SYSTEMIC) + D-051 (news-extractor refactor)
        + L-S227-1 (NO ANTHROPIC_API_KEY in production code).

Mechanism:
    subprocess.run([
        "claude", "-p",
        "--model", <model>,
        "--output-format", "json",
        "--disable-slash-commands",
        "--system-prompt", <system_prompt>,
    ], input=<body>, ...)

Returns the unwrapped JSON string from the CLI envelope's `result` field
(stripped of any ```json fence). The news extractor parses it as
`{"claims": [...]}`. CLI cost is logged at INFO; tests inject a stub.
"""

from __future__ import annotations

import json
import logging
import re
import subprocess

__all__ = [
    "SubagentSubstrateError",
    "claude_cli_news_transport",
    "make_claude_cli_news_transport",
]

log = logging.getLogger(__name__)

_INNER_FENCE_RE = re.compile(r"```(?:json)?\s*\n(.*?)\n```", re.DOTALL)
_DEFAULT_TIMEOUT_SEC = 300
_DEFAULT_MODEL = "claude-sonnet-4-6"


class SubagentSubstrateError(RuntimeError):
    """Raised when claude CLI subprocess substrate fails irrecoverably."""


def _unwrap_fence(text: str) -> str:
    """Extract JSON content from LLM response.

    Returns last fenced ```json block if any (LLMs often emit prose preamble
    + final fenced answer); else first balanced top-level {...}; else text
    as-is (downstream JSON parse will fail with diagnostic).
    """
    inner_matches = _INNER_FENCE_RE.findall(text)
    if inner_matches:
        return str(inner_matches[-1])
    obj = _extract_first_json_object(text)
    return obj if obj is not None else text


def _extract_first_json_object(text: str) -> str | None:
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


def claude_cli_news_transport(
    system_prompt: str,
    body: str,
    *,
    model: str = _DEFAULT_MODEL,
    timeout_sec: int = _DEFAULT_TIMEOUT_SEC,
) -> str:
    """Call claude CLI in print mode and return the unwrapped JSON string.

    Raises `SubagentSubstrateError` on subprocess failure, non-zero exit,
    non-JSON envelope, or `is_error=true` from the CLI.
    """
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
            input=body,
            capture_output=True,
            text=True,
            encoding="utf-8",
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

    cli_cost = envelope.get("total_cost_usd")
    log.info("claude_cli_news_transport: model=%s cli_cost_usd=%s", model, cli_cost)
    return _unwrap_fence(str(envelope.get("result", "")))


def make_claude_cli_news_transport(
    *,
    model: str = _DEFAULT_MODEL,
    timeout_sec: int = _DEFAULT_TIMEOUT_SEC,
):
    """Factory returning a closure with `(system_prompt, body) → str` signature
    suitable as `ClaudeLlmExtractor.transport`. Use when the caller needs to
    override model or timeout from defaults.
    """

    def _call(system_prompt: str, body: str) -> str:
        return claude_cli_news_transport(
            system_prompt, body, model=model, timeout_sec=timeout_sec
        )

    return _call
