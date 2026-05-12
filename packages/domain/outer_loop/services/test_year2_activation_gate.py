"""Year2ActivationGate — BR-10 readiness verdict tests."""

from __future__ import annotations

from datetime import UTC, datetime

from packages.domain.outer_loop.services.year2_activation_gate import (
    DEFAULT_MINIMUMS,
    Year2ActivationGate,
)
from packages.domain.outer_loop.value_objects.eval_kind import EvalKind


def test_gate_ready_when_all_minimums_met() -> None:
    gate = Year2ActivationGate()
    counts = {
        EvalKind.THESIS: 100,
        EvalKind.KOL_RECOMMENDATION: 500,
        EvalKind.PUMP: 20,
        EvalKind.NARRATIVE: 10,
    }
    status = gate.evaluate(counts, as_of=datetime(2026, 5, 9, tzinfo=UTC))
    assert status.ready
    assert status.shortfalls == {}


def test_gate_blocks_when_thesis_below_minimum() -> None:
    gate = Year2ActivationGate()
    status = gate.evaluate(
        {
            EvalKind.THESIS: 50,
            EvalKind.KOL_RECOMMENDATION: 500,
            EvalKind.PUMP: 20,
            EvalKind.NARRATIVE: 10,
        },
        as_of=datetime(2026, 5, 9, tzinfo=UTC),
    )
    assert not status.ready
    assert status.shortfalls == {EvalKind.THESIS: (50, 100)}


def test_gate_blocks_when_multiple_kinds_short() -> None:
    gate = Year2ActivationGate()
    status = gate.evaluate({}, as_of=datetime(2026, 5, 9, tzinfo=UTC))
    assert not status.ready
    assert set(status.shortfalls) == set(DEFAULT_MINIMUMS)
    for kind, (actual, required) in status.shortfalls.items():
        assert actual == 0
        assert required == DEFAULT_MINIMUMS[kind]


def test_gate_honors_custom_minimums() -> None:
    gate = Year2ActivationGate(minimums={EvalKind.THESIS: 10})
    status = gate.evaluate(
        {EvalKind.THESIS: 10, EvalKind.PUMP: 0},
        as_of=datetime(2026, 5, 9, tzinfo=UTC),
    )
    assert status.ready
    assert status.shortfalls == {}
