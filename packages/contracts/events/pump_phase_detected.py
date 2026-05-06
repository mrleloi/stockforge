"""PumpPhaseDetected — cross-BC event for confirmed pump pattern detection (BC-7).

Phase 1 design (D-032 § a): fires ONLY after human review approves detection.
NOT fired at detection creation — only after status transitions to 'reviewed_approved'.

Consumers: BC-4 (Portfolio/Risk — position reduction signal), BC-9 (Position Sizing),
           BC-3 (Company Intelligence — flag ticker for due diligence).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a + b).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["PumpPhaseDetected"]


@dataclass(frozen=True)
class PumpPhaseDetected:
    """Cross-BC event: a pump pattern has been detected and human-approved.

    Phase 1: only fires after status='reviewed_approved'.
    Consumers use this as a risk signal — do NOT auto-execute positions.
    """

    detection_id: str
    ticker: str
    phase: str             # PumpPhase value string
    phase_confidence: float  # [0, 1] — Python-computed
    detected_at: datetime
    reviewed_at: datetime  # when human review completed
