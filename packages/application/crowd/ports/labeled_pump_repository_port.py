"""LabeledPumpRepositoryPort — Protocol for LabeledPump aggregate persistence (BC-7).

Used for BR-5 backtest gate: holdout set retrieval.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5 + § B.7.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § i).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.domain.crowd.labeled_pump import LabeledPump

__all__ = ["LabeledPumpRepositoryPort"]


@runtime_checkable
class LabeledPumpRepositoryPort(Protocol):
    """Port for LabeledPump aggregate storage and retrieval."""

    def save(self, labeled_pump: LabeledPump) -> None:
        """Persist a LabeledPump aggregate."""
        ...

    def get_holdout_set(self, test_split: float = 0.3) -> list[LabeledPump]:
        """Return holdout subset for BR-5 backtest gate.

        Returns the last floor(total * test_split) records as holdout.
        I-S1: split computed in Python from record count.
        """
        ...

    def get_all(self) -> list[LabeledPump]:
        """Return all LabeledPump records (for backtest CLI)."""
        ...
