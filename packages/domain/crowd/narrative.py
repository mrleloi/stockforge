"""Narrative — aggregate for stock ticker narrative lifecycle tracking (BC-7).

Invariants (D-032 § c):
- thematic_keywords must be non-empty
- current_phase must be a NarrativePhase enum value
- first_detected_at must not be in the future

Behaviors per spec § B.1:
- days_in_current_phase(): days since most recent phase transition (or first_detected_at)

I-10: ZERO framework dependencies (pure stdlib).
I-S1: numeric fields (mention counts, velocity) are Python-computed; LLM never outputs them.
I-S2: first_detected_at + phase_history timestamps provide provenance.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.1 + § B.3 UC-2.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § c + e).
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

from packages.domain.crowd.phase_transition import PhaseTransition
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = ["Narrative"]


@dataclass(frozen=True)
class Narrative:
    """Aggregate tracking the lifecycle of a stock narrative.

    Phase transitions are recorded in phase_history (immutable tuple of PhaseTransition).
    Mutable pattern: create new Narrative instance with updated fields.

    I-10: ZERO framework dependencies.
    """

    narrative_id: NarrativeId
    ticker: str
    thematic_keywords: tuple[str, ...]          # non-empty; key terms driving narrative
    current_phase: NarrativePhase
    first_detected_at: datetime
    phase_history: tuple[PhaseTransition, ...]  # immutable record of phase changes
    counter_narrative_ids: tuple[str, ...]      # IDs of CounterNarrative aggregates
    related_narrative_ids: tuple[str, ...]      # IDs of related Narrative aggregates
    affected_tickers: tuple[str, ...]           # tickers this narrative covers

    def __post_init__(self) -> None:
        if not self.thematic_keywords:
            raise ValueError("Narrative.thematic_keywords must be non-empty")
        if not self.ticker:
            raise ValueError("Narrative.ticker must not be empty")
        now_utc = datetime.now(UTC)
        ts = self.first_detected_at
        ts_aware = ts if ts.tzinfo is not None else ts.replace(tzinfo=UTC)
        if ts_aware > now_utc:
            raise ValueError(
                f"Narrative.first_detected_at must not be in the future; "
                f"got {self.first_detected_at!r}"
            )

    def days_in_current_phase(self, *, now: datetime | None = None) -> float:
        """Return days since the most recent phase transition (or first_detected_at).

        I-S1: pure Python arithmetic — no LLM involvement.

        Args:
            now: Override current time (injectable for tests). Defaults to datetime.now(UTC).
        """
        reference = now if now is not None else datetime.now(UTC)
        # Find most recent phase transition
        if self.phase_history:
            ts: datetime = self.phase_history[-1].transitioned_at
        else:
            ts = self.first_detected_at

        ts_aware = ts if ts.tzinfo is not None else ts.replace(tzinfo=UTC)
        ref_aware = reference if reference.tzinfo is not None else reference.replace(tzinfo=UTC)

        delta: timedelta = ref_aware - ts_aware
        return delta.total_seconds() / 86400.0
