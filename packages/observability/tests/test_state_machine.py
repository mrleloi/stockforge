"""Tests for packages/observability/state_machine.py — D-008 Track 9."""

from __future__ import annotations

import pytest

from packages.observability.state_machine import (
    VALID_TRANSITIONS,
    HookEvent,
    HookEventState,
    InvalidTransitionError,
    is_terminal,
    transition,
)


def make_event(name: str = "SessionStart") -> HookEvent:
    return HookEvent(hook_name=name, started_at="2026-04-29T15:00:00.000Z")


# ---- States enumeration ----


def test_four_canonical_states() -> None:
    assert {s.value for s in HookEventState} == {"active", "completed", "error", "abandoned"}


def test_state_str_value_is_lowercase_token() -> None:
    assert HookEventState.ACTIVE.value == "active"
    assert HookEventState.COMPLETED.value == "completed"


# ---- Valid transitions ----


def test_active_to_completed() -> None:
    e = make_event()
    transition(e, HookEventState.COMPLETED)
    assert e.current_state == HookEventState.COMPLETED


def test_active_to_error() -> None:
    e = make_event()
    transition(e, HookEventState.ERROR)
    assert e.current_state == HookEventState.ERROR


def test_active_to_abandoned() -> None:
    e = make_event()
    transition(e, HookEventState.ABANDONED)
    assert e.current_state == HookEventState.ABANDONED


def test_error_reactivation_to_active() -> None:
    e = make_event()
    transition(e, HookEventState.ERROR)
    transition(e, HookEventState.ACTIVE)
    assert e.current_state == HookEventState.ACTIVE


def test_abandoned_reactivation_to_active() -> None:
    e = make_event()
    transition(e, HookEventState.ABANDONED)
    transition(e, HookEventState.ACTIVE)
    assert e.current_state == HookEventState.ACTIVE


def test_full_retry_cycle_active_error_active_completed() -> None:
    e = make_event()
    transition(e, HookEventState.ERROR)
    transition(e, HookEventState.ACTIVE)
    transition(e, HookEventState.COMPLETED)
    assert e.current_state == HookEventState.COMPLETED
    assert len(e.transitions_log) == 3


# ---- Invalid transitions ----


def test_completed_is_terminal_no_further_transitions() -> None:
    e = make_event()
    transition(e, HookEventState.COMPLETED)
    with pytest.raises(InvalidTransitionError):
        transition(e, HookEventState.ACTIVE)


def test_active_to_active_rejected() -> None:
    e = make_event()
    with pytest.raises(InvalidTransitionError):
        transition(e, HookEventState.ACTIVE)


def test_error_to_completed_rejected_must_reactivate_first() -> None:
    e = make_event()
    transition(e, HookEventState.ERROR)
    with pytest.raises(InvalidTransitionError):
        transition(e, HookEventState.COMPLETED)


def test_abandoned_to_error_rejected() -> None:
    e = make_event()
    transition(e, HookEventState.ABANDONED)
    with pytest.raises(InvalidTransitionError):
        transition(e, HookEventState.ERROR)


def test_invalid_transition_error_carries_from_to_states() -> None:
    e = make_event()
    transition(e, HookEventState.COMPLETED)
    with pytest.raises(InvalidTransitionError) as ei:
        transition(e, HookEventState.ACTIVE)
    assert ei.value.from_state == HookEventState.COMPLETED
    assert ei.value.to_state == HookEventState.ACTIVE


# ---- Terminal predicate ----


def test_is_terminal_only_completed() -> None:
    assert is_terminal(HookEventState.COMPLETED) is True
    assert is_terminal(HookEventState.ACTIVE) is False
    assert is_terminal(HookEventState.ERROR) is False
    assert is_terminal(HookEventState.ABANDONED) is False


# ---- Transitions log ----


def test_transitions_log_records_each_step() -> None:
    e = make_event()
    transition(e, HookEventState.ERROR)
    transition(e, HookEventState.ACTIVE)
    transition(e, HookEventState.COMPLETED)
    assert len(e.transitions_log) == 3
    ts1, from1, to1 = e.transitions_log[0]
    assert from1 == HookEventState.ACTIVE
    assert to1 == HookEventState.ERROR
    assert ts1.endswith("Z")


def test_failed_transition_does_not_mutate_event() -> None:
    e = make_event()
    transition(e, HookEventState.COMPLETED)
    pre_log = list(e.transitions_log)
    with pytest.raises(InvalidTransitionError):
        transition(e, HookEventState.ACTIVE)
    assert e.transitions_log == pre_log
    assert e.current_state == HookEventState.COMPLETED


# ---- Identity / equality ----


def test_event_equality_by_name_and_started_at() -> None:
    a = HookEvent(hook_name="SessionStart", started_at="2026-04-29T15:00:00Z")
    b = HookEvent(hook_name="SessionStart", started_at="2026-04-29T15:00:00Z")
    transition(a, HookEventState.COMPLETED)
    assert a == b
    assert hash(a) == hash(b)


def test_event_inequality_with_different_hook_name() -> None:
    a = HookEvent(hook_name="SessionStart", started_at="2026-04-29T15:00:00Z")
    b = HookEvent(hook_name="Stop", started_at="2026-04-29T15:00:00Z")
    assert a != b


# ---- VALID_TRANSITIONS structural check ----


def test_valid_transitions_count_is_five() -> None:
    assert len(VALID_TRANSITIONS) == 5


def test_valid_transitions_includes_three_forward_and_two_reactivation() -> None:
    forward = {
        (HookEventState.ACTIVE, HookEventState.COMPLETED),
        (HookEventState.ACTIVE, HookEventState.ERROR),
        (HookEventState.ACTIVE, HookEventState.ABANDONED),
    }
    reactivation = {
        (HookEventState.ERROR, HookEventState.ACTIVE),
        (HookEventState.ABANDONED, HookEventState.ACTIVE),
    }
    assert forward | reactivation == set(VALID_TRANSITIONS)
