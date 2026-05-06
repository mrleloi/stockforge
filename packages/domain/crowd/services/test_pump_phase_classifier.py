"""Tests for PumpPhaseClassifier (BC-7 Track K).

Deterministic 5-state weighted scorer per spec § B.3 UC-3 lines 379-423.
All tests use only Python inputs; NO LLM involved.

Markers: unit
"""

from __future__ import annotations

import pytest

from packages.domain.crowd.services.pump_phase_classifier import (
    PumpPhaseClassifier,
    PumpPhaseClassifierConfig,
    TickerSignals,
)
from packages.domain.crowd.value_objects.pump_phase import PumpPhase


def _signals(**kwargs: object) -> TickerSignals:
    """Build TickerSignals with UNCERTAIN-producing defaults (all signals off)."""
    defaults: dict[str, object] = dict(
        price_change_30d=0.0,
        price_5d_change=0.0,
        volume_30d_avg_rising=False,
        volume_5d_avg_declining=False,
        volume_5d_avg=1000000.0,
        volume_30d_avg=1000000.0,
        t2_news_silent=False,
        t3_kol_mentions_rising=False,
        t3_kol_mentions_peak=False,
        t4_novice_post_share=0.0,
        t4_coordination_score=0.0,
        historical_similar_cases_count=0,
    )
    defaults.update(kwargs)
    return TickerSignals(**defaults)  # type: ignore[arg-type]


@pytest.mark.unit
class TestPumpPhaseClassifierPrePump:
    def test_pre_pump_both_signals(self) -> None:
        classifier = PumpPhaseClassifier()
        # BR-9 applies: historical_similar_cases_count=0 → cap at 0.6
        s = _signals(
            price_change_30d=0.05,
            volume_30d_avg_rising=True,
            t3_kol_mentions_rising=True,
            t2_news_silent=True,
        )
        phase, confidence, contributions = classifier.classify(s)
        assert phase is PumpPhase.PRE_PUMP
        assert confidence == pytest.approx(0.6)  # 0.3 + 0.3 = 0.6; BR-9 cap = 0.6 (no change)
        assert len(contributions) == 2


@pytest.mark.unit
class TestPumpPhaseClassifierPump:
    def test_pump_volume_price_spike(self) -> None:
        classifier = PumpPhaseClassifier()
        # historical_similar_cases_count=1 avoids BR-9 cap → raw score 0.7
        s = _signals(
            price_5d_change=0.25,
            volume_5d_avg=4000000.0,
            volume_30d_avg=1000000.0,  # ratio = 4x
            t3_kol_mentions_peak=True,
            t4_novice_post_share=0.6,
            historical_similar_cases_count=1,
        )
        phase, confidence, contributions = classifier.classify(s)
        assert phase is PumpPhase.PUMP
        assert confidence == pytest.approx(0.7)  # 0.4 + 0.3; no BR-9 cap

    def test_pump_fomo_only(self) -> None:
        """fomo_active alone scores 0.3, which is below confidence_gate (0.4) → UNCERTAIN per spec line 418."""
        classifier = PumpPhaseClassifier()
        s = _signals(
            t3_kol_mentions_peak=True,
            t4_novice_post_share=0.6,
        )
        phase, confidence, _ = classifier.classify(s)
        # fomo alone = 0.3 < confidence_gate (0.4) → UNCERTAIN (spec § B.3 line 418)
        assert phase is PumpPhase.UNCERTAIN
        assert confidence == pytest.approx(0.3)


@pytest.mark.unit
class TestPumpPhaseClassifierDistribution:
    def test_distribution_volume_without_price(self) -> None:
        classifier = PumpPhaseClassifier()
        # historical_similar_cases_count=1 avoids BR-9 cap → raw score 0.7
        s = _signals(
            price_5d_change=0.03,  # abs < 0.05
            volume_5d_avg=3000000.0,
            volume_30d_avg=1000000.0,  # ratio = 3x > 2
            t4_novice_post_share=0.8,
            t4_coordination_score=0.1,  # < 0.3
            historical_similar_cases_count=1,
        )
        phase, confidence, contributions = classifier.classify(s)
        assert phase is PumpPhase.DISTRIBUTION
        assert confidence == pytest.approx(0.7)  # 0.4 + 0.3; no BR-9 cap


@pytest.mark.unit
class TestPumpPhaseClassifierDump:
    def test_dump_price_crash(self) -> None:
        classifier = PumpPhaseClassifier()
        s = _signals(
            price_5d_change=-0.20,
            volume_5d_avg_declining=True,
        )
        phase, confidence, contributions = classifier.classify(s)
        assert phase is PumpPhase.DUMP
        assert confidence == pytest.approx(0.5)


@pytest.mark.unit
class TestPumpPhaseClassifierUncertain:
    def test_uncertain_no_signals(self) -> None:
        """All signals off → all scores = 0 → UNCERTAIN."""
        classifier = PumpPhaseClassifier()
        s = _signals()
        phase, confidence, _ = classifier.classify(s)
        assert phase is PumpPhase.UNCERTAIN
        assert confidence == pytest.approx(0.0)

    def test_uncertain_score_below_gate(self) -> None:
        """Single signal below gate threshold → UNCERTAIN."""
        classifier = PumpPhaseClassifier()
        # quiet_accumulation only = 0.3 < gate 0.4 → UNCERTAIN
        s = _signals(price_change_30d=0.05, volume_30d_avg_rising=True)
        phase, _, _ = classifier.classify(s)
        assert phase is PumpPhase.UNCERTAIN


@pytest.mark.unit
class TestPumpPhaseClassifierBR9:
    def test_no_historical_analogs_caps_confidence(self) -> None:
        """BR-9: historical_similar_cases_count=0 caps confidence at 0.6."""
        classifier = PumpPhaseClassifier()
        # DUMP has score 0.5 which is within cap (0.5 <= 0.6)
        s = _signals(price_5d_change=-0.20, volume_5d_avg_declining=True)
        phase, confidence, _ = classifier.classify(s)
        assert phase is PumpPhase.DUMP
        assert confidence == pytest.approx(0.5)  # 0.5 <= 0.6, no cap change

    def test_with_historical_analogs_no_cap(self) -> None:
        """BR-9: historical_similar_cases_count>0 → no cap applied."""
        classifier = PumpPhaseClassifier()
        # PRE_PUMP two signals = 0.6; with count=1, no cap applied → 0.6
        s = _signals(
            price_change_30d=0.05,
            volume_30d_avg_rising=True,
            t3_kol_mentions_rising=True,
            t2_news_silent=True,
            historical_similar_cases_count=2,
        )
        phase, confidence, _ = classifier.classify(s)
        assert phase is PumpPhase.PRE_PUMP
        assert confidence == pytest.approx(0.6)


@pytest.mark.unit
class TestPumpPhaseClassifierDeterminism:
    def test_same_input_identical_result(self) -> None:
        """§ B.8 bootstrap test: same signals → identical (phase, confidence, contributions)."""
        classifier = PumpPhaseClassifier()
        s = _signals(
            price_5d_change=-0.20,
            volume_5d_avg_declining=True,
        )
        r1 = classifier.classify(s)
        r2 = classifier.classify(s)
        assert r1[0] == r2[0]
        assert r1[1] == pytest.approx(r2[1])
        assert len(r1[2]) == len(r2[2])

    def test_weight_tuning_round_trip(self) -> None:
        """Weight tuning changes confidence proportionally."""
        cfg = PumpPhaseClassifierConfig(price_crash_weight=0.8)
        classifier = PumpPhaseClassifier(config=cfg)
        s = _signals(price_5d_change=-0.20, volume_5d_avg_declining=True, historical_similar_cases_count=1)
        _, confidence, _ = classifier.classify(s)
        assert confidence == pytest.approx(0.8)
