"""observation_lifecycle — 8-state FSM for subagent observation lifecycle.

Domain module: pure Python dataclasses + enums. Zero framework dependency.
Source: agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md §1.9
Plan: agent-workspace/session-plans/pending/012-S311-wave-0-W0-1-fsm-impl.md D1
"""

from packages.domain.observation_lifecycle.fsm import (
    LEGAL_TRANSITIONS,
    IllegalTransitionError,
    ObservationLifecycle,
    State,
)

__all__ = [
    "IllegalTransitionError",
    "ObservationLifecycle",
    "State",
    "LEGAL_TRANSITIONS",
]
