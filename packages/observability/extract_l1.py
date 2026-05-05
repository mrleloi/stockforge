"""L1 extraction — prompt builder + parser + windowing helpers.

Source: claude-sessions/src/memory/extract-l1.ts:33-100. Phase 0 ships the deterministic
substrate only — no claude-CLI subprocess invocation, no auto-fire. Caller (Phase 1+
Anthropic SDK client) composes dispatch on top.

Public API:
    MemoryCategory   — Literal of 6 valid categories
    MemoryCandidate  — TypedDict shape returned by parse_llm_response
    HEAD_COUNT       — 15 (head window size)
    TAIL_COUNT       — 35 (tail window size)
    build_extraction_prompt(messages) -> str
    parse_llm_response(response) -> list[MemoryCandidate]
    extract_messages_from_jsonl(path) -> list[ChatMessage]
"""

from __future__ import annotations

import json
import re
from collections.abc import Sequence
from pathlib import Path
from typing import Literal, TypedDict

from .extract_l0 import ChatMessage, _content_to_text

MemoryCategory = Literal[
    "profile", "preferences", "entities", "events", "cases", "patterns"
]

_VALID_CATEGORIES: frozenset[str] = frozenset(
    ("profile", "preferences", "entities", "events", "cases", "patterns")
)

# extract-l1.ts:30-31 — HEAD + TAIL = 50 messages window for long sessions.
HEAD_COUNT = 15
TAIL_COUNT = 35

_USER_TRIM = 1000      # extract-l1.ts:132
_ASSISTANT_TRIM = 1500  # extract-l1.ts:142


class MemoryCandidate(TypedDict):
    category: MemoryCategory
    name: str
    content: str


def build_extraction_prompt(messages: Sequence[ChatMessage]) -> str:
    """Build the L1 extraction prompt verbatim from extract-l1.ts:33-64.

    Returns a string ready to feed to the LLM. Caller dispatches.
    """
    conversation = "\n\n".join(
        f"{m.get('role', '')}: {m.get('content', '')}" for m in messages
    )
    return (
        "Extract structured memories from this Claude Code session conversation.\n"
        "\n"
        "Return a JSON array of memories. Each memory:\n"
        "{\n"
        '  "category": one of: profile, preferences, entities, events, cases, patterns\n'
        '  "name": kebab-case identifier (e.g. "auth-token-fix")\n'
        '  "content": 1-3 sentences of useful information to remember\n'
        "}\n"
        "\n"
        "Categories:\n"
        "- profile: user role, expertise, responsibilities\n"
        "- preferences: coding style, tools, workflow\n"
        "- entities: projects, services, people, systems\n"
        "- events: incidents, deployments, decisions (with dates and reasoning)\n"
        "- cases: problem + solution pairs (IMPORTANT: also extract FAILED approaches "
        "— what was tried and why it didn't work, so future sessions don't repeat the "
        "same mistakes)\n"
        "- patterns: recurring approaches, anti-patterns\n"
        "\n"
        "Pay special attention to:\n"
        "1. FAILED APPROACHES — if something was tried and didn't work, extract it as "
        'a "cases" memory with clear explanation of WHY it failed. This prevents '
        "wasting time retrying.\n"
        "2. DECISIONS — architectural or technical decisions with reasoning (why X "
        "was chosen over Y).\n"
        "3. NEXT STEPS — if work is incomplete, what should be done next.\n"
        "\n"
        "Only extract information worth remembering in future sessions. Skip trivial "
        "exchanges.\n"
        "If nothing is worth remembering, return an empty array [].\n"
        "\n"
        "Conversation:\n"
        f"{conversation}\n"
        "\n"
        "JSON array:"
    )


_JSON_ARRAY_RE = re.compile(r"\[\s*\{[\s\S]*\]")


def parse_llm_response(response: str) -> list[MemoryCandidate]:
    """Parse an LLM L1-extraction response into validated memory candidates.

    Tolerates markdown wrapping, prose preamble. Returns [] on any parse failure.
    Validates: category in VALID_CATEGORIES; non-empty name + content strings.
    """
    if not response or not response.strip():
        return []
    match = _JSON_ARRAY_RE.search(response)
    if not match:
        return []
    try:
        parsed = json.loads(match.group(0))
    except json.JSONDecodeError:
        return []
    if not isinstance(parsed, list):
        return []
    out: list[MemoryCandidate] = []
    for item in parsed:
        if not isinstance(item, dict):
            continue
        cat = item.get("category")
        name = item.get("name")
        content = item.get("content")
        if not (
            isinstance(cat, str) and cat.strip()
            and isinstance(name, str) and name.strip()
            and isinstance(content, str) and content.strip()
        ):
            continue
        if cat not in _VALID_CATEGORIES:
            continue
        out.append({"category": cat, "name": name, "content": content})  # type: ignore[typeddict-item]
    return out


def extract_messages_from_jsonl(jsonl_path: str | Path) -> list[ChatMessage]:
    """Parse a Claude Code JSONL transcript and return HEAD+TAIL windowed messages.

    Trims user content to 1000 chars and assistant content to 1500 (matches
    extract-l1.ts:132, 142). If total <= HEAD+TAIL, returns all messages.
    """
    path = Path(jsonl_path)
    raw = path.read_text(encoding="utf-8")
    messages: list[ChatMessage] = []
    for line in raw.split("\n"):
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(event, dict):
            continue
        etype = event.get("type")
        message = event.get("message")
        if etype not in ("human", "user", "assistant"):
            continue
        if not isinstance(message, dict):
            continue
        text = _content_to_text(message.get("content"))
        if etype in ("human", "user"):
            messages.append({"role": "user", "content": text[:_USER_TRIM]})
        else:
            messages.append({"role": "assistant", "content": text[:_ASSISTANT_TRIM]})
    if len(messages) <= HEAD_COUNT + TAIL_COUNT:
        return messages
    return messages[:HEAD_COUNT] + messages[-TAIL_COUNT:]
