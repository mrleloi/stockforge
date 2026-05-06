"""PumpDetection — aggregate for pump-and-dump pattern detection output (BC-7).

Invariants (D-032 § c):
- ticker must not be empty
- phase_confidence in [0, 1]
- contributing_signals must be non-empty
- status is one of: 'pending_review' | 'reviewed_approved' | 'reviewed_rejected'
- detected_at must not be in the future

Phase 1 human-review-first design (D-032 § a):
- All new detections start with status='pending_review'
- PumpPhaseDetected cross-BC event fires ONLY after status='reviewed_approved'

I-10: ZERO framework dependencies (pure stdlib).
I-S1: phase_confidence is Python-computed; never from LLM.
I-S2: detected_at provides provenance.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + § B.4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + c + f).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Literal

from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects.detection_id import DetectionId
from packages.domain.crowd.value_objects.pump_action import PumpAction
from packages.domain.crowd.value_objects.pump_phase import PumpPhase

__all__ = ["PumpDetection", "ReviewStatus"]

ReviewStatus = Literal["pending_review", "reviewed_approved", "reviewed_rejected"]

_VALID_STATUSES: frozenset[str] = frozenset(
    {"pending_review", "reviewed_approved", "reviewed_rejected"}
)


@dataclass(frozen=True)
class PumpDetection:
    """Aggregate representing a detected pump-and-dump pattern event.

    Immutable; status changes create new PumpDetection instances.
    Phase 1: always created with status='pending_review'.
    PumpPhaseDetected event fires only after human review approves.

    I-10: ZERO framework dependencies.
    I-S1: phase_confidence is Python-computed (not LLM output).
    """

    detection_id: DetectionId
    ticker: str
    detected_at: datetime
    phase: PumpPhase
    phase_confidence: float             # [0, 1] — deterministic Python score
    contributing_signals: tuple[SignalContribution, ...]  # non-empty signal audit trail
    historical_similar_cases: tuple[str, ...]             # analog descriptions
    recommended_action: PumpAction
    evidence_summary: str               # LLM-generated text (prose only; no LLM numbers)
    status: ReviewStatus                # Phase 1 human-review-first

    def __post_init__(self) -> None:
        if not self.ticker:
            raise ValueError("PumpDetection.ticker must not be empty")
        if not (0.0 <= self.phase_confidence <= 1.0):
            raise ValueError(
                f"PumpDetection.phase_confidence must be in [0, 1]; "
                f"got {self.phase_confidence!r}"
            )
        if not self.contributing_signals:
            raise ValueError("PumpDetection.contributing_signals must be non-empty")
        if self.status not in _VALID_STATUSES:
            raise ValueError(
                f"PumpDetection.status must be one of {sorted(_VALID_STATUSES)}; "
                f"got {self.status!r}"
            )
        now_utc = datetime.now(UTC)
        ts = self.detected_at
        ts_aware = ts if ts.tzinfo is not None else ts.replace(tzinfo=UTC)
        if ts_aware > now_utc:
            raise ValueError(
                f"PumpDetection.detected_at must not be in the future; "
                f"got {self.detected_at!r}"
            )
