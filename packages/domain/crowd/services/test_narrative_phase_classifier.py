"""Tests for NarrativePhaseClassifier (BC-7 Track K).

Deterministic 7-state machine per spec § B.3 UC-2 lines 301-333.
All tests use only Python inputs; NO LLM involved.

Markers: unit
"""

from __future__ import annotations

import pytest

from packages.domain.crowd.services.narrative_phase_classifier import (
    NarrativeMetrics,
    NarrativePhaseClassifier,
    NarrativePhaseClassifierConfig,
)
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase


def _metrics(**kwargs: object) -> NarrativeMetrics:
    """Build NarrativeMetrics with sensible defaults for testing."""
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
class TestNarrativePhaseClassifierIncubation:
    def test_incubation_low_mentions_few_sources(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(avg_mentions_per_day=2.0, unique_sources=2)
        result = classifier.classify(m, NarrativePhase.INCUBATION)
        assert result is NarrativePhase.INCUBATION

    def test_incubation_boundary_exactly_4_mentions(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(avg_mentions_per_day=4.9, unique_sources=2)
        result = classifier.classify(m, NarrativePhase.INCUBATION)
        assert result is NarrativePhase.INCUBATION


@pytest.mark.unit
class TestNarrativePhaseClassifierEmerging:
    def test_emerging_accelerating_low_source_share(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=8.0,
            unique_sources=5,
            velocity_trend="ACCELERATING",
            major_source_share=0.1,
        )
        result = classifier.classify(m, NarrativePhase.INCUBATION)
        assert result is NarrativePhase.EMERGING


@pytest.mark.unit
class TestNarrativePhaseClassifierMainstream:
    def test_mainstream_high_source_share_kol(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=15.0,
            unique_sources=10,
            major_source_share=0.35,
            kol_mention_count=5,
            bullish_ratio=0.6,
            new_unique_posters_trend="STABLE",
        )
        result = classifier.classify(m, NarrativePhase.EMERGING)
        assert result is NarrativePhase.MAINSTREAM

    def test_saturation_from_mainstream_context(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=18.0,
            unique_sources=12,
            major_source_share=0.4,
            kol_mention_count=6,
            bullish_ratio=0.85,
            new_unique_posters_trend="DECELERATING",
        )
        result = classifier.classify(m, NarrativePhase.MAINSTREAM)
        assert result is NarrativePhase.SATURATION


@pytest.mark.unit
class TestNarrativePhaseClassifierExhaustionReversal:
    def test_exhaustion_high_mentions_decelerating(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=25.0,
            unique_sources=5,
            velocity_trend="DECELERATING",
        )
        result = classifier.classify(m, NarrativePhase.SATURATION)
        assert result is NarrativePhase.EXHAUSTION

    def test_reversal_counter_velocity_dominates(self) -> None:
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=10.0,
            velocity=5.0,
            counter_narrative_velocity=2.0,  # 2.0 > 5.0 * 0.3 = 1.5
        )
        result = classifier.classify(m, NarrativePhase.SATURATION)
        assert result is NarrativePhase.REVERSAL


@pytest.mark.unit
class TestNarrativePhaseClassifierDead:
    def test_dead_very_low_mentions(self) -> None:
        classifier = NarrativePhaseClassifier()
        # unique_sources=5 bypasses INCUBATION rule (requires unique_sources < 3)
        # avg_mentions_per_day=0.5 < 1 triggers DEAD rule
        m = _metrics(avg_mentions_per_day=0.5, unique_sources=5)
        result = classifier.classify(m, NarrativePhase.EXHAUSTION)
        assert result is NarrativePhase.DEAD


@pytest.mark.unit
class TestNarrativePhaseClassifierDeterminism:
    def test_same_input_same_output_deterministic(self) -> None:
        """§ B.8 bootstrap test: same inputs → identical result."""
        classifier = NarrativePhaseClassifier()
        m = _metrics(
            avg_mentions_per_day=15.0,
            major_source_share=0.35,
            kol_mention_count=4,
        )
        result_1 = classifier.classify(m, NarrativePhase.EMERGING)
        result_2 = classifier.classify(m, NarrativePhase.EMERGING)
        assert result_1 == result_2

    def test_no_change_returns_current(self) -> None:
        """When no rule fires, current phase is returned (no change)."""
        classifier = NarrativePhaseClassifier()
        # Metrics that don't trigger any rule:
        # - avg_mentions=10, unique_sources=5 → not INCUBATION (sources>=3)
        # - velocity=STABLE → not EMERGING
        # - major_source_share=0.1 < 0.3 → not MAINSTREAM
        # - avg_mentions=10 < 20 → not EXHAUSTION
        # - counter_velocity=0.0 not > velocity*0.3 → not REVERSAL
        # - avg_mentions=10 >= 1 → not DEAD
        m = _metrics(
            avg_mentions_per_day=10.0,
            unique_sources=5,
            velocity_trend="STABLE",
            major_source_share=0.1,
            velocity=5.0,
            counter_narrative_velocity=0.0,
        )
        result = classifier.classify(m, NarrativePhase.EMERGING)
        assert result is NarrativePhase.EMERGING

    def test_threshold_tuning_round_trip(self) -> None:
        """Config thresholds tunable: custom config produces expected result."""
        cfg = NarrativePhaseClassifierConfig(incubation_max_mentions=10.0)
        classifier = NarrativePhaseClassifier(config=cfg)
        # avg=8 < custom threshold 10 → INCUBATION with custom config
        m = _metrics(avg_mentions_per_day=8.0, unique_sources=2)
        result = classifier.classify(m, NarrativePhase.EMERGING)
        assert result is NarrativePhase.INCUBATION
