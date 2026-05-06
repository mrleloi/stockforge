"""NarrativeRepositoryPort — Protocol for Narrative aggregate persistence (BC-7).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.value_objects.narrative_id import NarrativeId
from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = ["NarrativeRepositoryPort"]


@runtime_checkable
class NarrativeRepositoryPort(Protocol):
    """Port for Narrative aggregate storage and retrieval."""

    def save(self, narrative: Narrative) -> None:
        """Persist or update a Narrative aggregate (upsert by narrative_id)."""
        ...

    def get_active(self, ticker: str) -> list[Narrative]:
        """Return active narratives for a ticker (not in DEAD phase)."""
        ...

    def find_by_id(self, narrative_id: NarrativeId) -> Narrative | None:
        """Return Narrative by ID, or None if not found."""
        ...

    def get_bullish_points_for(self, ticker: str) -> list[str]:
        """Return aggregated bullish thematic keywords from active narratives.

        Used by GenerateCounterNarrativeUseCase (UC-4) to build bear-point context.
        Returns list of thematic_keyword strings from non-DEAD narratives.
        """
        ...

    def get_by_phase(self, phase: NarrativePhase) -> list[Narrative]:
        """Return all narratives currently in the given phase."""
        ...
