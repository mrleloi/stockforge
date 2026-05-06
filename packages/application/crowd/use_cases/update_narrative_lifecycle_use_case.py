"""UpdateNarrativeLifecycleUseCase — UC-2 per spec § B.3 (BC-7).

Deterministic narrative phase transition use case.
Calls NarrativePhaseClassifier (pure-Python); no LLM.

Verifier grep gate: grep -r "anthropic|openai" packages/application/crowd/use_cases/update_narrative_lifecycle_use_case.py returns 0

I-S1: all computation is deterministic Python; NarrativePhaseClassifier is LLM-free.
I-S2: PhaseTransition timestamp provides provenance.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-2.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § e).
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.crowd.ports.narrative_repository_port import NarrativeRepositoryPort
from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.phase_transition import PhaseTransition
from packages.domain.crowd.services.narrative_phase_classifier import (
    NarrativeMetrics,
    NarrativePhaseClassifier,
)
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = ["NarrativePhaseChangedEvent", "UpdateNarrativeLifecycleUseCase"]

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class NarrativePhaseChangedEvent:
    """Event emitted when a Narrative transitions to a new phase."""

    narrative_id: str
    ticker: str
    from_phase: NarrativePhase
    to_phase: NarrativePhase
    transitioned_at: datetime


@dataclass
class UpdateNarrativeLifecycleUseCase:
    """UC-2: Update narrative phase based on current crowd metrics.

    Deterministic — NarrativePhaseClassifier is pure Python (no LLM).
    Emits NarrativePhaseChangedEvent when phase changes.

    Args:
        narrative_repo: Repository for Narrative aggregates.
        classifier:     NarrativePhaseClassifier (injectable for testing).
        event_publisher: Callable to publish events (injectable).
        clock:          Injectable clock.
    """

    narrative_repo: NarrativeRepositoryPort
    classifier: NarrativePhaseClassifier = field(
        default_factory=NarrativePhaseClassifier
    )
    event_publisher: Callable[[NarrativePhaseChangedEvent], None] = field(
        default_factory=lambda: lambda ev: None  # noqa: ARG005
    )
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )

    def execute(
        self,
        narrative_id: NarrativeId,
        metrics: NarrativeMetrics,
    ) -> Narrative | None:
        """Classify current metrics and update narrative phase if changed.

        Returns updated Narrative if phase changed, None if no change.

        Args:
            narrative_id: ID of the Narrative to update.
            metrics:      Current crowd metrics (Python-computed; I-S1).
        """
        narrative = self.narrative_repo.find_by_id(narrative_id)
        if narrative is None:
            logger.warning(
                "update_narrative_lifecycle narrative_id=%s not found; skipping",
                narrative_id,
            )
            return None

        new_phase = self.classifier.classify(metrics, narrative.current_phase)

        if new_phase == narrative.current_phase:
            logger.debug(
                "update_narrative_lifecycle narrative_id=%s ticker=%s phase=%s — no change",
                narrative_id,
                narrative.ticker,
                narrative.current_phase,
            )
            return None

        # Phase changed — create immutable new Narrative with updated phase
        now = self.clock()
        transition = PhaseTransition(
            from_phase=narrative.current_phase,
            to_phase=new_phase,
            transitioned_at=now,
            trigger_signals=(),
        )
        updated_narrative = Narrative(
            narrative_id=narrative.narrative_id,
            ticker=narrative.ticker,
            thematic_keywords=narrative.thematic_keywords,
            current_phase=new_phase,
            first_detected_at=narrative.first_detected_at,
            phase_history=(*narrative.phase_history, transition),
            counter_narrative_ids=narrative.counter_narrative_ids,
            related_narrative_ids=narrative.related_narrative_ids,
            affected_tickers=narrative.affected_tickers,
        )

        self.narrative_repo.save(updated_narrative)

        event = NarrativePhaseChangedEvent(
            narrative_id=str(narrative_id),
            ticker=narrative.ticker,
            from_phase=narrative.current_phase,
            to_phase=new_phase,
            transitioned_at=now,
        )
        self.event_publisher(event)

        logger.info(
            "update_narrative_lifecycle narrative_id=%s ticker=%s %s → %s",
            narrative_id,
            narrative.ticker,
            narrative.current_phase,
            new_phase,
        )

        return updated_narrative
