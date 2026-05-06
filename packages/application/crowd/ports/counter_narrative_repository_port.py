"""CounterNarrativeRepositoryPort — Protocol for CounterNarrative aggregate persistence (BC-7).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.domain.crowd.counter_narrative import CounterNarrative

__all__ = ["CounterNarrativeRepositoryPort"]


@runtime_checkable
class CounterNarrativeRepositoryPort(Protocol):
    """Port for CounterNarrative aggregate storage and retrieval."""

    def save(self, counter_narrative: CounterNarrative) -> None:
        """Persist a CounterNarrative aggregate."""
        ...

    def find_recent_for_ticker(self, ticker: str, limit: int = 5) -> list[CounterNarrative]:
        """Return most recent CounterNarratives for a ticker."""
        ...
