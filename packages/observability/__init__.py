"""Stockforge session observability — L0/L1 memory extraction + hook event state.

Phase 0 deliverables:
- Track 8b (D-007): claude-sessions L0/L1 + cleanText + TranscriptCache library port.
- Track 9 (D-008): hook event state machine (4 states + reactivation).

No claude-CLI subprocess invocation, no auto-fire — caller composes L1 dispatch
and hook lifecycle integration.
"""

from .clean_text import clean_text
from .extract_l0 import (
    ChatMessage,
    L0Data,
    extract_commands,
    extract_errors,
    extract_failures,
    extract_file_paths,
    extract_l0_from_jsonl,
    extract_l0_from_messages,
    extract_next_step,
)
from .extract_l1 import (
    HEAD_COUNT,
    TAIL_COUNT,
    MemoryCandidate,
    MemoryCategory,
    build_extraction_prompt,
    extract_messages_from_jsonl,
    parse_llm_response,
)
from .state_machine import (
    VALID_TRANSITIONS,
    HookEvent,
    HookEventState,
    InvalidTransitionError,
    is_terminal,
    transition,
)
from .transcript_cache import TranscriptCache

__all__ = [
    "ChatMessage",
    "HEAD_COUNT",
    "HookEvent",
    "HookEventState",
    "InvalidTransitionError",
    "L0Data",
    "MemoryCandidate",
    "MemoryCategory",
    "TAIL_COUNT",
    "TranscriptCache",
    "VALID_TRANSITIONS",
    "build_extraction_prompt",
    "clean_text",
    "extract_commands",
    "extract_errors",
    "extract_failures",
    "extract_file_paths",
    "extract_l0_from_jsonl",
    "extract_l0_from_messages",
    "extract_messages_from_jsonl",
    "extract_next_step",
    "is_terminal",
    "parse_llm_response",
    "transition",
]
