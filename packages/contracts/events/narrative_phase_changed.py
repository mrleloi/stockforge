"""NarrativePhaseChanged — cross-BC event for narrative lifecycle transitions (BC-7).

Fired by UpdateNarrativeLifecycleUseCase after a Narrative phase change.
Consumers: BC-4 (Portfolio/Risk), BC-9 (Position Sizing), BC-3 (Company Intelligence).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-2.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § b).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

__all__ = ["NarrativePhaseChanged"]


@dataclass(frozen=True)
class NarrativePhaseChanged:
    """Cross-BC event: a Narrative has transitioned to a new phase.

    Consumers use this to update risk models, portfolio overlays, and advisory outputs.
    """

    narrative_id: str
    ticker: str
    from_phase: str    # NarrativePhase value string
    to_phase: str      # NarrativePhase value string
    transitioned_at: datetime
