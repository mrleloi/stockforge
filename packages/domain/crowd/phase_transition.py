"""PhaseTransition — value object for narrative phase state changes (BC-7).

Invariants (D-032 § c):
- from_phase != to_phase (must be an actual change)
- transitioned_at must not be in the future

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § c).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime

from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = ["PhaseTransition"]


@dataclass(frozen=True)
class PhaseTransition:
    """Immutable record of a narrative phase state change.

    I-10: ZERO framework dependencies (pure stdlib dataclasses only).
    I-S2: transitioned_at provides provenance timestamp.
    """

    from_phase: NarrativePhase
    to_phase: NarrativePhase
    transitioned_at: datetime
    trigger_signals: tuple[str, ...]  # names of signals that triggered transition

    def __post_init__(self) -> None:
        if self.from_phase == self.to_phase:
            raise ValueError(
                f"PhaseTransition requires actual phase change; "
                f"from_phase and to_phase are both {self.from_phase!r}"
            )
        now_utc = datetime.now(UTC)
        ts = self.transitioned_at
        ts_aware = ts if ts.tzinfo is not None else ts.replace(tzinfo=UTC)
        if ts_aware > now_utc:
            raise ValueError(
                f"transitioned_at must not be in the future; "
                f"got {self.transitioned_at!r}"
            )
