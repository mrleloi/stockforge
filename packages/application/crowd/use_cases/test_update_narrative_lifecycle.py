"""Tests for UpdateNarrativeLifecycleUseCase (BC-7 Track K).

Tests: phase change triggers event; no change returns None; classifier injected.

Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock

import pytest

from packages.application.crowd.use_cases.update_narrative_lifecycle_use_case import (
    NarrativePhaseChangedEvent,
    UpdateNarrativeLifecycleUseCase,
)
from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.services.narrative_phase_classifier import NarrativeMetrics
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

_NOW = datetime.now(UTC).replace(microsecond=0) - timedelta(seconds=5)


def _make_narrative(phase: NarrativePhase = NarrativePhase.INCUBATION) -> Narrative:
    return Narrative(
        narrative_id=NarrativeId("test-001"),
        ticker="VND",
        thematic_keywords=("tăng trưởng",),
        current_phase=phase,
        first_detected_at=_NOW - timedelta(days=10),
        phase_history=(),
        counter_narrative_ids=(),
        related_narrative_ids=(),
        affected_tickers=("VND",),
    )


def _make_metrics(**kwargs: object) -> NarrativeMetrics:
    defaults: dict[str, object] = dict(
        avg_mentions_per_day=10.0,
        unique_sources=5,
        velocity_trend="STABLE",
        major_source_share=0.1,
        kol_mention_count=1,
        bullish_ratio=0.5,
        new_unique_posters_trend="STABLE",
        velocity=5.0,
        counter_narrative_velocity=0.0,
    )
    defaults.update(kwargs)
    return NarrativeMetrics(**defaults)  # type: ignore[arg-type]


@pytest.mark.unit
class TestUpdateNarrativeLifecyclePhaseChange:
    def test_phase_change_emits_event_and_saves(self) -> None:
        """When classifier returns new phase, event emitted and narrative saved."""
        narrative = _make_narrative(NarrativePhase.INCUBATION)

        mock_repo = MagicMock()
        mock_repo.find_by_id.return_value = narrative

        events: list[NarrativePhaseChangedEvent] = []

        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = NarrativePhase.EMERGING

        uc = UpdateNarrativeLifecycleUseCase(
            narrative_repo=mock_repo,
            classifier=mock_classifier,
            event_publisher=events.append,
            clock=lambda: _NOW,
        )

        metrics = _make_metrics(velocity_trend="ACCELERATING", major_source_share=0.1)
        result = uc.execute(NarrativeId("test-001"), metrics)

        assert result is not None
        assert result.current_phase is NarrativePhase.EMERGING
        assert len(events) == 1
        assert events[0].from_phase is NarrativePhase.INCUBATION
        assert events[0].to_phase is NarrativePhase.EMERGING
        mock_repo.save.assert_called_once()

    def test_no_phase_change_returns_none(self) -> None:
        """When classifier returns same phase, no event and no save."""
        narrative = _make_narrative(NarrativePhase.INCUBATION)

        mock_repo = MagicMock()
        mock_repo.find_by_id.return_value = narrative

        events: list[NarrativePhaseChangedEvent] = []

        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = NarrativePhase.INCUBATION  # no change

        uc = UpdateNarrativeLifecycleUseCase(
            narrative_repo=mock_repo,
            classifier=mock_classifier,
            event_publisher=events.append,
        )

        result = uc.execute(NarrativeId("test-001"), _make_metrics())
        assert result is None
        assert len(events) == 0
        mock_repo.save.assert_not_called()

    def test_not_found_returns_none(self) -> None:
        """When narrative not found, returns None (no crash)."""
        mock_repo = MagicMock()
        mock_repo.find_by_id.return_value = None

        uc = UpdateNarrativeLifecycleUseCase(narrative_repo=mock_repo)
        result = uc.execute(NarrativeId("nonexistent"), _make_metrics())
        assert result is None

    def test_phase_history_appended(self) -> None:
        """Phase transition is appended to phase_history on the updated narrative."""
        narrative = _make_narrative(NarrativePhase.EMERGING)

        mock_repo = MagicMock()
        mock_repo.find_by_id.return_value = narrative

        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = NarrativePhase.MAINSTREAM

        uc = UpdateNarrativeLifecycleUseCase(
            narrative_repo=mock_repo,
            classifier=mock_classifier,
            clock=lambda: _NOW,
        )

        result = uc.execute(NarrativeId("test-001"), _make_metrics())
        assert result is not None
        assert len(result.phase_history) == 1
        assert result.phase_history[0].from_phase is NarrativePhase.EMERGING
        assert result.phase_history[0].to_phase is NarrativePhase.MAINSTREAM
