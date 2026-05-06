"""Tests for GenerateCounterNarrativeUseCase (BC-7 Track K).

Tests: BR-6 mandatory trigger; below-threshold skip; bear-point grounding;
CounterNarrative persistence.

Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock

import pytest

from packages.application.crowd.ports.historical_analog_finder_port import HistoricalAnalog
from packages.application.crowd.use_cases.generate_counter_narrative_use_case import (
    CounterNarrativeGeneratedEvent,
    GenerateCounterNarrativeUseCase,
)
from packages.domain.crowd.counter_narrative import CounterNarrative

_NOW = datetime.now(UTC).replace(microsecond=0) - timedelta(seconds=5)


def _make_analog() -> HistoricalAnalog:
    return HistoricalAnalog(
        ticker="VND",
        period_start="2022-01-01",
        period_end="2022-06-30",
        setup_description="high bullish sentiment pre-correction",
        similarity_score=0.85,
        subsequent_return_12m=-0.20,
        outcome_description="Correction followed over-bullish sentiment saturation",
    )


def _make_use_case(
    bear_points: list[str] | None = None,
    analogs: list[object] | None = None,
    bullish_points: list[str] | None = None,
    events: list[CounterNarrativeGeneratedEvent] | None = None,
) -> tuple[GenerateCounterNarrativeUseCase, list[CounterNarrative]]:
    if bear_points is None:
        bear_points = [
            "Historical patterns suggest correction risk after extreme bullish consensus.",
            "Groupthink risk may indicate overvaluation without fundamental support.",
        ]
    if analogs is None:
        # CounterNarrative invariant: historical_analogs must be non-empty
        analogs = [_make_analog()]
    if bullish_points is None:
        bullish_points = ["tăng trưởng mạnh", "kết quả kinh doanh tốt"]

    saved_narratives: list[CounterNarrative] = []

    mock_repo = MagicMock()
    mock_repo.save.side_effect = saved_narratives.append

    mock_narrative_repo = MagicMock()
    mock_narrative_repo.get_bullish_points_for.return_value = bullish_points

    mock_analog_finder = MagicMock()
    mock_analog_finder.find.return_value = analogs

    final_bear_points = bear_points

    mock_generator = MagicMock()
    mock_generator.generate.return_value = final_bear_points

    uc = GenerateCounterNarrativeUseCase(
        counter_narrative_repo=mock_repo,
        narrative_repo=mock_narrative_repo,
        analog_finder=mock_analog_finder,
        bear_point_generator=mock_generator,
        event_publisher=(events.append if events is not None else lambda ev: None),  # noqa: ARG005
        clock=lambda: _NOW,
    )
    return uc, saved_narratives


@pytest.mark.unit
class TestGenerateCounterNarrativeBR6Trigger:
    def test_br6_mandatory_trigger_above_threshold(self) -> None:
        """BR-6: bullish_ratio > 0.8 must trigger counter-narrative generation."""
        events: list[CounterNarrativeGeneratedEvent] = []
        uc, saved = _make_use_case(events=events)

        result = uc.execute(ticker="VND", bullish_ratio=0.85)
        assert result is not None
        assert len(saved) == 1
        assert len(events) == 1

    def test_below_threshold_returns_none(self) -> None:
        """BR-6: bullish_ratio <= 0.8 → no counter-narrative generated."""
        uc, saved = _make_use_case()
        result = uc.execute(ticker="VND", bullish_ratio=0.75)
        assert result is None
        assert len(saved) == 0

    def test_exactly_at_threshold_returns_none(self) -> None:
        """BR-6: bullish_ratio == 0.8 is NOT above threshold → no generation."""
        uc, saved = _make_use_case()
        result = uc.execute(ticker="VND", bullish_ratio=0.80)
        assert result is None


@pytest.mark.unit
class TestGenerateCounterNarrativeBearPoints:
    def test_bear_points_non_empty_in_result(self) -> None:
        """CounterNarrative invariant: non-empty bear_points."""
        uc, saved = _make_use_case()
        result = uc.execute(ticker="VND", bullish_ratio=0.85)
        assert result is not None
        assert len(result.bear_points) > 0

    def test_counter_narrative_persisted(self) -> None:
        """CounterNarrative must be saved to repository."""
        uc, saved = _make_use_case()
        uc.execute(ticker="VND", bullish_ratio=0.85)
        assert len(saved) == 1
        assert saved[0].ticker == "VND"
        assert saved[0].trigger == "bullish_ratio_threshold_crossed"


@pytest.mark.unit
class TestGenerateCounterNarrativeEvent:
    def test_event_carries_bear_points_count(self) -> None:
        events: list[CounterNarrativeGeneratedEvent] = []
        uc, _ = _make_use_case(
            events=events,
            bear_points=["Point 1.", "Point 2.", "Point 3."],
        )
        uc.execute(ticker="VND", bullish_ratio=0.85)
        assert events[0].bear_points_count == 3
        assert events[0].ticker == "VND"
