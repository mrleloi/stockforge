"""Tests for DetectPumpPhaseUseCase (BC-7 Track K).

Tests: Phase 1 pending_review status; event NOT fired at creation; UNCERTAIN returns None.

Markers: unit
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock

import pytest

from packages.application.crowd.use_cases.detect_pump_phase_use_case import (
    DetectPumpPhaseUseCase,
    PumpPhaseDetectedEvent,
)
from packages.domain.crowd.pump_detection import PumpDetection
from packages.domain.crowd.services.pump_phase_classifier import TickerSignals
from packages.domain.crowd.value_objects.pump_phase import PumpPhase

_NOW = datetime.now(UTC).replace(microsecond=0) - timedelta(seconds=5)


def _make_signals(**kwargs: object) -> TickerSignals:
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
class TestDetectPumpPhaseUseCasePhase1:
    def test_detection_created_as_pending_review(self) -> None:
        """Phase 1: all new detections must have status='pending_review'."""
        saved: list[PumpDetection] = []

        mock_repo = MagicMock()
        mock_repo.save.side_effect = saved.append

        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = (
            PumpPhase.PUMP,
            0.7,
            [MagicMock(phase=PumpPhase.PUMP)],
        )

        uc = DetectPumpPhaseUseCase(
            detection_repo=mock_repo,
            classifier=mock_classifier,
            clock=lambda: _NOW,
        )

        signals = _make_signals(price_5d_change=0.25, volume_5d_avg=4000000.0, volume_30d_avg=1000000.0)
        result = uc.execute(ticker="VND", signals=signals)

        assert result is not None
        assert result.status == "pending_review"
        assert len(saved) == 1
        assert saved[0].status == "pending_review"

    def test_pump_phase_detected_event_not_fired_at_creation(self) -> None:
        """Phase 1: PumpPhaseDetectedEvent must NOT fire at detection creation.

        Event fires only after human review approves (status='reviewed_approved').
        """
        events: list[PumpPhaseDetectedEvent] = []

        mock_repo = MagicMock()
        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = (PumpPhase.PUMP, 0.7, [MagicMock(phase=PumpPhase.PUMP)])

        uc = DetectPumpPhaseUseCase(
            detection_repo=mock_repo,
            classifier=mock_classifier,
        )

        signals = _make_signals()
        uc.execute(ticker="VND", signals=signals)

        # No event should be published from the use case itself
        assert len(events) == 0

    def test_uncertain_phase_returns_none(self) -> None:
        """UNCERTAIN classification → no detection saved, returns None."""
        mock_repo = MagicMock()
        mock_classifier = MagicMock()
        mock_classifier.classify.return_value = (PumpPhase.UNCERTAIN, 0.2, [])

        uc = DetectPumpPhaseUseCase(
            detection_repo=mock_repo,
            classifier=mock_classifier,
        )

        result = uc.execute(ticker="VND", signals=_make_signals())
        assert result is None
        mock_repo.save.assert_not_called()

    def test_low_confidence_returns_none(self) -> None:
        """Confidence < 0.5 → no detection saved, returns None."""
        mock_repo = MagicMock()
        mock_classifier = MagicMock()
        # Score below _MIN_CONFIDENCE_TO_SAVE (0.5)
        mock_classifier.classify.return_value = (PumpPhase.PRE_PUMP, 0.4, [MagicMock(phase=PumpPhase.PRE_PUMP)])

        uc = DetectPumpPhaseUseCase(
            detection_repo=mock_repo,
            classifier=mock_classifier,
        )

        result = uc.execute(ticker="VND", signals=_make_signals())
        assert result is None
        mock_repo.save.assert_not_called()
