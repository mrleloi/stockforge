"""Tests for PumpDetection and SignalContribution domain aggregates (BC-7 Track K).

Tests: construction, invariants, status values, SignalContribution constraints, frozen immutability.

Markers: unit
"""

from __future__ import annotations

from dataclasses import FrozenInstanceError
from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.crowd.pump_detection import PumpDetection, ReviewStatus
from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects.detection_id import DetectionId
from packages.domain.crowd.value_objects.pump_action import PumpAction
from packages.domain.crowd.value_objects.pump_phase import PumpPhase


def _make_signal(
    signal_name: str = "volume_price_spike",
    phase: PumpPhase = PumpPhase.PUMP,
) -> SignalContribution:
    return SignalContribution(
        signal_name=signal_name,
        signal_value=0.8,
        weight=0.4,
        contribution=0.4,
        phase=phase,
    )


def _make_detection(
    status: ReviewStatus = "pending_review",
) -> PumpDetection:
    return PumpDetection(
        detection_id=DetectionId("test-detection-001"),
        ticker="VND",
        detected_at=datetime.now(UTC) - timedelta(minutes=5),
        phase=PumpPhase.PUMP,
        phase_confidence=0.7,
        contributing_signals=(_make_signal(),),
        historical_similar_cases=("VND 2021 pump pattern",),
        recommended_action=PumpAction.WATCH,
        evidence_summary="Pattern detected: elevated volume signals without fundamental support.",
        status=status,
    )


@pytest.mark.unit
class TestPumpDetectionConstruction:
    def test_valid_construction(self) -> None:
        d = _make_detection()
        assert d.ticker == "VND"
        assert d.phase is PumpPhase.PUMP
        assert d.status == "pending_review"

    def test_empty_ticker_raises(self) -> None:
        with pytest.raises(ValueError, match="ticker must not be empty"):
            PumpDetection(
                detection_id=DetectionId("x"),
                ticker="",
                detected_at=datetime.now(UTC) - timedelta(minutes=1),
                phase=PumpPhase.PUMP,
                phase_confidence=0.7,
                contributing_signals=(_make_signal(),),
                historical_similar_cases=(),
                recommended_action=PumpAction.WATCH,
                evidence_summary="test",
                status="pending_review",
            )

    def test_invalid_confidence_raises(self) -> None:
        with pytest.raises(ValueError, match="phase_confidence must be in"):
            PumpDetection(
                detection_id=DetectionId("x"),
                ticker="VND",
                detected_at=datetime.now(UTC) - timedelta(minutes=1),
                phase=PumpPhase.PUMP,
                phase_confidence=1.5,
                contributing_signals=(_make_signal(),),
                historical_similar_cases=(),
                recommended_action=PumpAction.WATCH,
                evidence_summary="test",
                status="pending_review",
            )

    def test_empty_signals_raises(self) -> None:
        with pytest.raises(ValueError, match="contributing_signals must be non-empty"):
            PumpDetection(
                detection_id=DetectionId("x"),
                ticker="VND",
                detected_at=datetime.now(UTC) - timedelta(minutes=1),
                phase=PumpPhase.PUMP,
                phase_confidence=0.7,
                contributing_signals=(),
                historical_similar_cases=(),
                recommended_action=PumpAction.WATCH,
                evidence_summary="test",
                status="pending_review",
            )

    def test_invalid_status_raises(self) -> None:
        with pytest.raises(ValueError, match="status must be one of"):
            PumpDetection(
                detection_id=DetectionId("x"),
                ticker="VND",
                detected_at=datetime.now(UTC) - timedelta(minutes=1),
                phase=PumpPhase.PUMP,
                phase_confidence=0.7,
                contributing_signals=(_make_signal(),),
                historical_similar_cases=(),
                recommended_action=PumpAction.WATCH,
                evidence_summary="test",
                status="unknown",  # type: ignore[arg-type]
            )

    def test_reviewed_approved_status(self) -> None:
        d = _make_detection(status="reviewed_approved")
        assert d.status == "reviewed_approved"

    def test_reviewed_rejected_status(self) -> None:
        d = _make_detection(status="reviewed_rejected")
        assert d.status == "reviewed_rejected"

    def test_future_detected_at_raises(self) -> None:
        with pytest.raises(ValueError, match="must not be in the future"):
            PumpDetection(
                detection_id=DetectionId("x"),
                ticker="VND",
                detected_at=datetime.now(UTC) + timedelta(hours=1),
                phase=PumpPhase.PUMP,
                phase_confidence=0.7,
                contributing_signals=(_make_signal(),),
                historical_similar_cases=(),
                recommended_action=PumpAction.WATCH,
                evidence_summary="test",
                status="pending_review",
            )

    def test_frozen_immutable(self) -> None:
        d = _make_detection()
        with pytest.raises(FrozenInstanceError):
            d.status = "reviewed_approved"  # type: ignore[misc]


@pytest.mark.unit
class TestSignalContribution:
    def test_valid_construction(self) -> None:
        s = _make_signal()
        assert s.signal_name == "volume_price_spike"
        assert s.weight == pytest.approx(0.4)

    def test_empty_name_raises(self) -> None:
        with pytest.raises(ValueError, match="signal_name must not be empty"):
            SignalContribution(
                signal_name="",
                signal_value=0.8,
                weight=0.4,
                contribution=0.4,
                phase=PumpPhase.PUMP,
            )

    def test_weight_out_of_range_raises(self) -> None:
        with pytest.raises(ValueError, match="weight must be in"):
            SignalContribution(
                signal_name="test",
                signal_value=0.5,
                weight=1.5,
                contribution=0.5,
                phase=PumpPhase.PUMP,
            )

    def test_contribution_out_of_range_raises(self) -> None:
        with pytest.raises(ValueError, match="contribution must be in"):
            SignalContribution(
                signal_name="test",
                signal_value=0.5,
                weight=0.5,
                contribution=-0.1,
                phase=PumpPhase.PUMP,
            )
