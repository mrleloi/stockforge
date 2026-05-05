"""Hook event state machine — Phase 0 / Track 9 (D-008).

4-state lifecycle for harness hook events: active / completed / error / abandoned.
Reactivation supported from error and abandoned. completed is terminal.

Pure Python (dataclasses only). No framework dependency per
agent-workspace/CLAUDE.md § "Domain layer has ZERO framework dependency".

Source: D-002 REV-2 § B Track 9 row A-14 + D-008 § state_machine.py contract.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime
from enum import StrEnum

__all__ = [
    "HookEventState",
    "HookEvent",
    "InvalidTransitionError",
    "transition",
    "is_terminal",
    "VALID_TRANSITIONS",
]


class HookEventState(StrEnum):
    """Lifecycle states for a single hook-event invocation.

    `StrEnum` so JSON / TSV serialization renders the lowercase token
    instead of `HookEventState.ACTIVE`.
    """

    ACTIVE = "active"
    COMPLETED = "completed"
    ERROR = "error"
    ABANDONED = "abandoned"


# Canonical valid transitions — anything not in this set raises.
# Forward (3): active → {completed, error, abandoned}
# Reactivation (2): {error, abandoned} → active
VALID_TRANSITIONS: frozenset[tuple[HookEventState, HookEventState]] = frozenset(
    {
        (HookEventState.ACTIVE, HookEventState.COMPLETED),
        (HookEventState.ACTIVE, HookEventState.ERROR),
        (HookEventState.ACTIVE, HookEventState.ABANDONED),
        (HookEventState.ERROR, HookEventState.ACTIVE),
        (HookEventState.ABANDONED, HookEventState.ACTIVE),
    }
)


class InvalidTransitionError(ValueError):
    """Raised when transition() is called with an unsupported (from, to) pair."""

    def __init__(self, from_state: HookEventState, to_state: HookEventState) -> None:
        super().__init__(
            f"invalid transition {from_state.value} -> {to_state.value}; "
            f"allowed transitions from {from_state.value}: "
            f"{sorted(t.value for f, t in VALID_TRANSITIONS if f == from_state)}"
        )
        self.from_state = from_state
        self.to_state = to_state


@dataclass
class HookEvent:
    """One hook-event lifecycle record.

    `transitions_log` accumulates `(timestamp_iso, from_state, to_state)` triples
    for audit. `current_state` mirrors the latest entry's destination (or initial
    state if no transitions yet).

    Equality is by `(hook_name, started_at)` — two events are the same identity
    even if their transition logs diverge (e.g. one was retried, one wasn't).
    """

    hook_name: str
    started_at: str
    current_state: HookEventState = HookEventState.ACTIVE
    transitions_log: list[tuple[str, HookEventState, HookEventState]] = field(
        default_factory=list
    )

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, HookEvent):
            return NotImplemented
        return (
            self.hook_name == other.hook_name and self.started_at == other.started_at
        )

    def __hash__(self) -> int:
        return hash((self.hook_name, self.started_at))


def _utc_now_iso() -> str:
    """ISO-8601 UTC timestamp with millisecond precision (matches JSONL schema v2 `ts`)."""
    return datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%S.") + (
        f"{datetime.now(UTC).microsecond // 1000:03d}Z"
    )


def transition(event: HookEvent, new_state: HookEventState) -> HookEvent:
    """Validate + apply a state transition. Mutates `event` in place + returns it.

    Raises `InvalidTransitionError` if `(event.current_state, new_state)` not in
    `VALID_TRANSITIONS`.

    Reactivation (error/abandoned → active) clears no history — the prior
    transitions remain in `transitions_log` so the audit shows retry attempts.
    """
    if (event.current_state, new_state) not in VALID_TRANSITIONS:
        raise InvalidTransitionError(event.current_state, new_state)

    event.transitions_log.append((_utc_now_iso(), event.current_state, new_state))
    event.current_state = new_state
    return event


def is_terminal(state: HookEventState) -> bool:
    """True if `state` cannot transition further. Only `completed` is terminal.

    `error` and `abandoned` are NOT terminal — they support reactivation by design
    (caller may retry the hook). A truly-dead event lands in `completed`.
    """
    return state == HookEventState.COMPLETED
