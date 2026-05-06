"""Unit tests for BC-7 domain value objects.

Coverage:
- Sentiment enum membership (5 levels)
- NarrativePhase enum membership (7 levels + DEAD)
- PumpPhase enum membership (5 levels)
- PumpAction enum membership (4 levels)
- Window enum membership (4 values) + hours + duration math

I-S1 note: these are pure enum/property tests; no LLM calls.
Markers: unit
"""

from __future__ import annotations

from datetime import timedelta

import pytest

from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase
from packages.domain.crowd.value_objects.pump_action import PumpAction
from packages.domain.crowd.value_objects.pump_phase import PumpPhase
from packages.domain.crowd.value_objects.sentiment import Sentiment
from packages.domain.crowd.value_objects.window import Window


@pytest.mark.unit
class TestSentiment:
    def test_all_five_levels_present(self) -> None:
        values = {s.value for s in Sentiment}
        assert values == {
            "strongly_bullish",
            "bullish",
            "neutral",
            "bearish",
            "strongly_bearish",
        }

    def test_str_enum_coercible(self) -> None:
        assert Sentiment("bullish") is Sentiment.BULLISH

    def test_str_representation(self) -> None:
        assert str(Sentiment.NEUTRAL) == "neutral"


@pytest.mark.unit
class TestNarrativePhase:
    def test_seven_phases_present(self) -> None:
        values = {p.value for p in NarrativePhase}
        assert values == {
            "incubation",
            "emerging",
            "mainstream",
            "saturation",
            "exhaustion",
            "reversal",
            "dead",
        }

    def test_dead_is_final_phase(self) -> None:
        assert NarrativePhase.DEAD.value == "dead"

    def test_str_enum_coercible(self) -> None:
        assert NarrativePhase("saturation") is NarrativePhase.SATURATION


@pytest.mark.unit
class TestPumpPhase:
    def test_five_phases_present(self) -> None:
        values = {p.value for p in PumpPhase}
        assert values == {
            "pre_pump",
            "pump",
            "distribution",
            "dump",
            "uncertain",
        }

    def test_uncertain_is_default_fallback(self) -> None:
        # UNCERTAIN phase represents confidence below threshold
        assert PumpPhase.UNCERTAIN.value == "uncertain"


@pytest.mark.unit
class TestPumpAction:
    def test_four_actions_present(self) -> None:
        values = {a.value for a in PumpAction}
        assert values == {"avoid", "exit_if_holding", "watch", "informational"}

    def test_actions_are_research_aid_framing(self) -> None:
        # Verify non-financial-advice framing per I-S35
        assert "buy" not in {a.value for a in PumpAction}
        assert "sell" not in {a.value for a in PumpAction}


@pytest.mark.unit
class TestWindow:
    def test_four_windows_present(self) -> None:
        values = {w.value for w in Window}
        assert values == {"1H", "4H", "1D", "1W"}

    def test_hours_property_one_hour(self) -> None:
        assert Window.ONE_HOUR.hours == 1.0

    def test_hours_property_four_hour(self) -> None:
        assert Window.FOUR_HOUR.hours == 4.0

    def test_hours_property_one_day(self) -> None:
        assert Window.ONE_DAY.hours == 24.0

    def test_hours_property_one_week(self) -> None:
        assert Window.ONE_WEEK.hours == 168.0

    def test_duration_property_one_hour(self) -> None:
        assert Window.ONE_HOUR.duration == timedelta(hours=1)

    def test_duration_property_one_week(self) -> None:
        assert Window.ONE_WEEK.duration == timedelta(days=7)

    def test_str_enum_coercible(self) -> None:
        assert Window("1D") is Window.ONE_DAY
