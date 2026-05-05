"""L0 extraction — quick metadata from a Claude Code session transcript.

Pure regex pass. No LLM. Source: claude-sessions/src/memory/extract-l0.ts:5-80.
Extended per D-002 REV-2 § A with Vietnamese failure phrases.

Public API:
    L0Data            — TypedDict shape returned by extract_l0_from_messages
    ChatMessage       — TypedDict shape consumed by aggregator
    extract_file_paths(text) -> list[str]
    extract_commands(text)   -> list[str]
    extract_errors(text)     -> list[str]
    extract_failures(text)   -> list[str]
    extract_next_step(messages) -> str | None
    extract_l0_from_messages(messages, project, agent_id=None) -> L0Data
    extract_l0_from_jsonl(lines, project) -> L0Data
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterable, Sequence
from time import time
from typing import TypedDict

# --- Type contracts ---------------------------------------------------------


class ChatMessage(TypedDict):
    role: str          # "user" | "assistant"
    content: str


class L0Data(TypedDict, total=False):
    summary: str
    project: str
    messageCount: int
    files: list[str]
    timestamp: int
    agent: str | None
    commands: list[str] | None
    errors: list[str] | None
    failures: list[str] | None
    next_step: str | None
    topics: list[str]


# --- Regex constants (port of extract-l0.ts:5-23) ---------------------------

_FILE_PATH_RE = re.compile(
    r"(?:^|[\s`\"'(])([.\w/-]+\.\w{1,10})(?=[\s`\"'),;:]|$)",
    re.MULTILINE,
)
_MAX_SUMMARY_LEN = 120

_TOOL_USE_RE = re.compile(r"```(?:bash|sh|shell)\s*([\s\S]*?)```", re.MULTILINE)
_BASH_CMD_RE = re.compile(r"\$\s+([\w./][\w./-]*(?:\s+[\w./-]+)*)", re.MULTILINE)

_ERROR_RE = re.compile(
    r"(?:Error|error|ERROR|exception|Exception|FATAL|fatal|failed|Failed|FAILED):\s*(.{10,120})",
    re.MULTILINE,
)

# FAILURE_PATTERNS: original 6 (RU + EN) + 5 NEW VN per D-002 REV-2 § A.
_FAILURE_PATTERNS: tuple[re.Pattern[str], ...] = tuple(
    re.compile(p, re.IGNORECASE | re.MULTILINE)
    for p in (
        # Russian (claude-sessions origin)
        r"(?:не сработал[оа]?|didn'?t work|not work|does not work)[^.]*[.!]",
        r"(?:откатил|reverted?|rolled? back)[^.]*[.!]",
        r"(?:не помогло|не решило|didn'?t help|didn'?t fix)[^.]*[.!]",
        r"(?:пробовал[аи]?\s+[^,.]+,?\s*но)[^.]*[.!]",
        r"(?:tried\s+[^,.]+,?\s*but)[^.]*[.!]",
        r"(?:approach\s+failed|подход\s+не\s+сработал)[^.]*[.!]",
        # Vietnamese (NEW per D-002 REV-2 § A — stockforge identity)
        r"(?:không hoạt động)[^.]*[.!]",
        r"(?:không hiệu quả)[^.]*[.!]",
        r"(?:đã thử nhưng)[^.]*[.!]",
        r"(?:không khả thi)[^.]*[.!]",
        r"(?:thất bại)[^.]*[.!]",
    )
)

_NEXT_STEP_PATTERNS: tuple[re.Pattern[str], ...] = (
    re.compile(
        r"(?:следующий шаг|next step|далее нужно|теперь нужно|осталось)[:\s]+(.{20,200})",
        re.IGNORECASE,
    ),
    re.compile(
        r"(?:TODO|FIXME|нужно доделать|остаётся)[:\s]+(.{20,200})",
        re.IGNORECASE,
    ),
)

_FIRST_SENTENCE_RE = re.compile(r"^[^.!?\n]{20,200}[.!?]")


# --- Extractors -------------------------------------------------------------


def extract_file_paths(text: str) -> list[str]:
    matches: set[str] = set()
    for m in _FILE_PATH_RE.finditer(text or ""):
        path = m.group(1)
        if path and ("/" in path or "." in path):
            matches.add(path)
    return [p for p in matches if not p.startswith("http") and not p.startswith("//")]


def extract_commands(text: str) -> list[str]:
    cmds: list[str] = []
    seen: set[str] = set()
    for m in _TOOL_USE_RE.finditer(text or ""):
        block = (m.group(1) or "").strip()
        if not block:
            continue
        first_line = block.split("\n", 1)[0].strip()
        if first_line and first_line not in seen:
            seen.add(first_line)
            cmds.append(first_line[:80])
    for m in _BASH_CMD_RE.finditer(text or ""):
        cmd = (m.group(1) or "").strip()
        if cmd and cmd not in seen:
            seen.add(cmd)
            cmds.append(cmd[:80])
    return cmds[:20]


def extract_errors(text: str) -> list[str]:
    errs: list[str] = []
    seen: set[str] = set()
    for m in _ERROR_RE.finditer(text or ""):
        msg = (m.group(1) or "").strip()
        if msg and msg not in seen:
            seen.add(msg)
            errs.append(msg[:120])
    return errs[:10]


def extract_failures(text: str) -> list[str]:
    fails: list[str] = []
    seen: set[str] = set()
    for pattern in _FAILURE_PATTERNS:
        for m in pattern.finditer(text or ""):
            msg = (m.group(0) or "").strip()
            if len(msg) > 15 and msg not in seen:
                seen.add(msg)
                fails.append(msg[:200])
    return fails[:10]


def extract_next_step(messages: Sequence[ChatMessage]) -> str | None:
    last_assistant: ChatMessage | None = None
    for msg in reversed(messages):
        if msg.get("role") == "assistant":
            last_assistant = msg
            break
    if last_assistant is None:
        return None
    text = last_assistant.get("content") or ""
    for pattern in _NEXT_STEP_PATTERNS:
        m = pattern.search(text)
        if m:
            return m.group(1).strip()[:200]
    m = _FIRST_SENTENCE_RE.search(text)
    if m:
        return m.group(0).strip()
    return None


# --- Aggregators ------------------------------------------------------------


def extract_l0_from_messages(
    messages: Sequence[ChatMessage],
    project: str,
    agent_id: str | None = None,
) -> L0Data:
    if not messages:
        return {
            "summary": "",
            "project": project,
            "messageCount": 0,
            "files": [],
            "topics": [],
            "agent": agent_id,
        }

    first_user = next((m for m in messages if m.get("role") == "user"), None)
    summary = ""
    if first_user:
        summary = (first_user.get("content") or "").replace("\n", " ").strip()[:_MAX_SUMMARY_LEN]

    files: set[str] = set()
    commands: set[str] = set()
    errors: set[str] = set()
    failures: set[str] = set()

    for msg in messages:
        text = msg.get("content") if isinstance(msg.get("content"), str) else ""
        for f in extract_file_paths(text):
            files.add(f)
        for c in extract_commands(text):
            commands.add(c)
        for e in extract_errors(text):
            errors.add(e)
        for fl in extract_failures(text):
            failures.add(fl)

    next_step = extract_next_step(messages)

    out: L0Data = {
        "summary": summary,
        "project": project,
        "messageCount": len(messages),
        "files": list(files)[:20],
        "timestamp": int(time() * 1000),
        "agent": agent_id,
        "topics": [],
    }
    if commands:
        out["commands"] = list(commands)
    if errors:
        out["errors"] = list(errors)
    if failures:
        out["failures"] = list(failures)
    if next_step is not None:
        out["next_step"] = next_step
    return out


def _content_to_text(content: object) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(str(block.get("text") or ""))
        return " ".join(parts)
    return ""


def extract_l0_from_jsonl(lines: Iterable[str], project: str) -> L0Data:
    messages: list[ChatMessage] = []
    for raw in lines:
        line = raw.strip()
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
        role = "user" if etype in ("human", "user") else "assistant"
        messages.append({"role": role, "content": text})
    return extract_l0_from_messages(messages, project)
