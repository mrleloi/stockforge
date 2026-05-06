"""DetectPumpPhaseUseCase — UC-3 per spec § B.3 (BC-7).

Phase 1 human-review-first design (D-032 § a):
- All PumpDetection aggregates created with status='pending_review'
- PumpPhaseDetected cross-BC event fires ONLY after status='reviewed_approved'
- This use case does NOT fire the event — it only creates + persists the detection

Verifier grep gate: grep -r "anthropic|openai" packages/application/crowd/use_cases/detect_pump_phase_use_case.py returns 0

I-S1: PumpPhaseClassifier is deterministic Python; no LLM in classification path.
BR-9: analog_finder injected; re-injects historical_similar_cases_count into TickerSignals.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-3 + § B.4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + f + h).
"""

from __future__ import annotations

import logging
import uuid
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.crowd.ports.historical_analog_finder_port import (
    HistoricalAnalog,
    HistoricalAnalogFinderPort,
)
from packages.application.crowd.ports.pump_detection_repository_port import (
    PumpDetectionRepositoryPort,
)
from packages.application.crowd.ports.pump_evidence_summarizer_port import (
    PumpEvidenceSummarizerPort,
)
from packages.domain.crowd.pump_detection import PumpDetection
from packages.domain.crowd.services.pump_phase_classifier import (
    PumpPhaseClassifier,
    TickerSignals,
)
from packages.domain.crowd.value_objects.detection_id import DetectionId
from packages.domain.crowd.value_objects.pump_action import PumpAction
from packages.domain.crowd.value_objects.pump_phase import PumpPhase

__all__ = ["DetectPumpPhaseUseCase", "PumpPhaseDetectedEvent"]

logger = logging.getLogger(__name__)

# Minimum confidence to persist a detection (below this → no detection saved)
_MIN_CONFIDENCE_TO_SAVE = 0.5


@dataclass(frozen=True)
class PumpPhaseDetectedEvent:
    """Event emitted ONLY after human review approves a detection.

    Phase 1: This event is NOT fired from DetectPumpPhaseUseCase.
    Fire from review workflow after status transitions to 'reviewed_approved'.
    """

    detection_id: str
    ticker: str
    phase: PumpPhase
    phase_confidence: float
    detected_at: datetime


@dataclass
class DetectPumpPhaseUseCase:
    """UC-3: Classify pump phase from TickerSignals and persist pending detection.

    Phase 1 human-review-first:
    - Creates PumpDetection with status='pending_review'
    - PumpPhaseDetectedEvent NOT fired (deferred to review workflow)

    Args:
        detection_repo:    Repository for PumpDetection aggregates.
        classifier:        PumpPhaseClassifier (injectable for testing).
        analog_finder:     HistoricalAnalogFinderPort for BR-9.
        evidence_summarizer: PumpEvidenceSummarizerPort for LLM text summary.
        clock:             Injectable clock.
    """

    detection_repo: PumpDetectionRepositoryPort
    classifier: PumpPhaseClassifier = field(default_factory=PumpPhaseClassifier)
    analog_finder: HistoricalAnalogFinderPort | None = None
    evidence_summarizer: PumpEvidenceSummarizerPort | None = None
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )

    def execute(
        self,
        ticker: str,
        signals: TickerSignals,
    ) -> PumpDetection | None:
        """Classify pump phase and persist detection if confidence threshold met.

        Returns PumpDetection (status='pending_review') or None if UNCERTAIN/low-confidence.
        BR-9: analog_finder result re-injected as historical_similar_cases_count.

        Args:
            ticker:  Stock ticker symbol.
            signals: TickerSignals (Python-computed; I-S1).
        """
        # Find historical analogs (BR-9)
        analogs: list[HistoricalAnalog] = []
        if self.analog_finder is not None:
            setup_description = f"ticker={ticker} pump_detection"
            analogs = self.analog_finder.find(
                ticker=ticker,
                setup_description=setup_description,
                top_k=5,
            )

        # Re-inject historical count into signals (BR-9 confidence cap)
        signals_with_count = TickerSignals(
            price_change_30d=signals.price_change_30d,
            price_5d_change=signals.price_5d_change,
            volume_30d_avg_rising=signals.volume_30d_avg_rising,
            volume_5d_avg_declining=signals.volume_5d_avg_declining,
            volume_5d_avg=signals.volume_5d_avg,
            volume_30d_avg=signals.volume_30d_avg,
            t2_news_silent=signals.t2_news_silent,
            t3_kol_mentions_rising=signals.t3_kol_mentions_rising,
            t3_kol_mentions_peak=signals.t3_kol_mentions_peak,
            t4_novice_post_share=signals.t4_novice_post_share,
            t4_coordination_score=signals.t4_coordination_score,
            historical_similar_cases_count=len(analogs),
        )

        phase, confidence, contributions = self.classifier.classify(signals_with_count)

        # Return None for UNCERTAIN or below minimum confidence
        if phase is PumpPhase.UNCERTAIN or confidence < _MIN_CONFIDENCE_TO_SAVE:
            logger.debug(
                "detect_pump_phase ticker=%s phase=%s confidence=%.2f — below threshold; skipping",
                ticker,
                phase,
                confidence,
            )
            return None

        # Generate LLM evidence summary (prose only; no numbers per I-S1)
        evidence_summary = ""
        if self.evidence_summarizer is not None:
            evidence_summary = self.evidence_summarizer.summarize_pump_evidence(
                ticker=ticker,
                signals=list(contributions),
                historical_matches=analogs,
            )

        # Phase 1: always 'pending_review'
        now = self.clock()
        detection = PumpDetection(
            detection_id=DetectionId(str(uuid.uuid4())),
            ticker=ticker,
            detected_at=now,
            phase=phase,
            phase_confidence=confidence,
            contributing_signals=tuple(contributions),
            historical_similar_cases=tuple(a.setup_description for a in analogs),
            recommended_action=PumpAction.WATCH,
            evidence_summary=evidence_summary,
            status="pending_review",
        )

        self.detection_repo.save(detection)

        logger.info(
            "detect_pump_phase ticker=%s phase=%s confidence=%.2f "
            "analogs=%d status=pending_review",
            ticker,
            phase,
            confidence,
            len(analogs),
        )

        return detection
