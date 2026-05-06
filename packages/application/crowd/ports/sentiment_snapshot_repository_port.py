"""SentimentSnapshotRepositoryPort — Protocol for SentimentSnapshot persistence.

Concrete implementation: SqliteSentimentSnapshotRepository in packages/infrastructure/crowd/.
Storage: SQLite per D-032 § (a) with composite index (ticker, captured_at DESC).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-1 + B.5.
ADR: D-032 § (a) + (c).
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

from packages.domain.crowd.sentiment_snapshot import SentimentSnapshot
from packages.domain.crowd.value_objects.snapshot_id import SnapshotId
from packages.domain.crowd.value_objects.window import Window

__all__ = ["SentimentSnapshotRepositoryPort"]


@runtime_checkable
class SentimentSnapshotRepositoryPort(Protocol):
    """Repository port for SentimentSnapshot aggregate persistence."""

    def save(self, snapshot: SentimentSnapshot) -> None:
        """Persist a SentimentSnapshot. Upserts on snapshot_id conflict."""
        ...

    def get_recent(self, ticker: str, window: Window) -> list[SentimentSnapshot]:
        """Return snapshots for `ticker` within the given window duration.

        Results are ordered by captured_at DESC (most recent first).
        Returns empty list if no snapshots exist.
        """
        ...

    def find_by_id(self, snapshot_id: SnapshotId) -> SentimentSnapshot | None:
        """Return snapshot by ID, or None if not found."""
        ...
