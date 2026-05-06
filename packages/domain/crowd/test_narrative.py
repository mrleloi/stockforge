"""Tests for Narrative and PhaseTransition domain aggregates (BC-7 Track K).

Tests: construction, invariants, days_in_current_phase, frozen immutability.

Markers: unit
"""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.phase_transition import PhaseTransition
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase


def _make_narrative(
    phase: NarrativePhase = NarrativePhase.INCUBATION,
    first_detected_at: datetime | None = None,
    phase_history: tuple[PhaseTransition, ...] = (),
) -> Narrative:
    if first_detected_at is None:
        first_detected_at = datetime.now(UTC) - timedelta(days=10)
    return Narrative(
        narrative_id=NarrativeId("test-narrative-001"),
        ticker="VND",
        thematic_keywords=("tăng trưởng", "ngân hàng"),
        current_phase=phase,
        first_detected_at=first_detected_at,
        phase_history=phase_history,
        counter_narrative_ids=(),
        related_narrative_ids=(),
        affected_tickers=("VND",),
    )


def _make_transition(
    from_phase: NarrativePhase = NarrativePhase.INCUBATION,
    to_phase: NarrativePhase = NarrativePhase.EMERGING,
    days_ago: int = 3,
) -> PhaseTransition:
    return PhaseTransition(
        from_phase=from_phase,
        to_phase=to_phase,
        transitioned_at=datetime.now(UTC) - timedelta(days=days_ago),
        trigger_signals=("velocity_accelerating",),
    )


@pytest.mark.unit
class TestNarrativeConstruction:
    def test_valid_construction(self) -> None:
        n = _make_narrative()
        assert n.ticker == "VND"
        assert n.current_phase is NarrativePhase.INCUBATION

    def test_empty_keywords_raises(self) -> None:
        with pytest.raises(ValueError, match="thematic_keywords must be non-empty"):
            Narrative(
                narrative_id=NarrativeId("x"),
                ticker="VND",
                thematic_keywords=(),
                current_phase=NarrativePhase.INCUBATION,
                first_detected_at=datetime.now(UTC) - timedelta(days=1),
                phase_history=(),
                counter_narrative_ids=(),
                related_narrative_ids=(),
                affected_tickers=(),
            )

    def test_future_first_detected_at_raises(self) -> None:
        with pytest.raises(ValueError, match="must not be in the future"):
            _make_narrative(first_detected_at=datetime.now(UTC) + timedelta(hours=1))

    def test_empty_ticker_raises(self) -> None:
        with pytest.raises(ValueError, match="ticker must not be empty"):
            Narrative(
                narrative_id=NarrativeId("x"),
                ticker="",
                thematic_keywords=("foo",),
                current_phase=NarrativePhase.INCUBATION,
                first_detected_at=datetime.now(UTC) - timedelta(days=1),
                phase_history=(),
                counter_narrative_ids=(),
                related_narrative_ids=(),
                affected_tickers=(),
            )


@pytest.mark.unit
class TestNarrativeDaysInCurrentPhase:
    def test_no_transitions_uses_first_detected(self) -> None:
        first = datetime.now(UTC) - timedelta(days=7)
        n = _make_narrative(first_detected_at=first)
        days = n.days_in_current_phase()
        assert 6.9 < days < 7.1

    def test_with_transition_uses_most_recent(self) -> None:
        t = _make_transition(days_ago=3)
        n = _make_narrative(phase_history=(t,))
        days = n.days_in_current_phase()
        assert 2.9 < days < 3.1

    def test_injectable_now(self) -> None:
        t = _make_transition(days_ago=5)
        n = _make_narrative(phase_history=(t,))
        fake_now = t.transitioned_at + timedelta(days=2)
        days = n.days_in_current_phase(now=fake_now)
        assert days == pytest.approx(2.0, abs=0.01)


@pytest.mark.unit
class TestPhaseTransitionImmutability:
    def test_same_phase_raises(self) -> None:
        with pytest.raises(ValueError, match="actual phase change"):
            PhaseTransition(
                from_phase=NarrativePhase.INCUBATION,
                to_phase=NarrativePhase.INCUBATION,
                transitioned_at=datetime.now(UTC) - timedelta(minutes=1),
                trigger_signals=(),
            )

    def test_future_transitioned_at_raises(self) -> None:
        future = datetime.now(UTC) + timedelta(hours=1)
        with pytest.raises(ValueError, match="must not be in the future"):
            PhaseTransition(
                from_phase=NarrativePhase.INCUBATION,
                to_phase=NarrativePhase.EMERGING,
                transitioned_at=future,
                trigger_signals=(),
            )

    def test_frozen(self) -> None:
        t = _make_transition()
        with pytest.raises(FrozenInstanceError):
            t.from_phase = NarrativePhase.DEAD  # type: ignore[misc]
