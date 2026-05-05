"""Strip Claude Code harness chatter from transcript text.

Source: claude-sessions/src/memory/snapshot.ts:35-50 (9-pattern strip chain).
CRITICAL: without this, every memory extraction pollutes with system-reminder /
command-name / task-notification / context_window_protection harness boilerplate.
"""

from __future__ import annotations

import re

_HARNESS_TAGS = (
    "system-reminder",
    "local-command-caveat",
    "command-name",
    "command-message",
    "command-args",
    "local-command-stdout",
    "task-notification",
    "context_window_protection",
    "context_guidance",
)

_PATTERNS = tuple(
    re.compile(rf"<{tag}>.*?</{tag}>", re.DOTALL) for tag in _HARNESS_TAGS
)


def clean_text(text: str) -> str:
    """Strip 9 harness wrapper tags. Returns trimmed result."""
    if not text:
        return ""
    out = text
    for pat in _PATTERNS:
        out = pat.sub("", out)
    return out.strip()
