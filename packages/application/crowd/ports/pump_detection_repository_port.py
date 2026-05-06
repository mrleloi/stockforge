"""PumpDetectionRepositoryPort — Protocol for PumpDetection aggregate persistence (BC-7).

Phase 1 human-review-first: get_pending_review() used by review dashboard.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.5.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § a).
"""

from __future__ import annotations

from datetime import datetime
from typing import Protocol, runtime_checkable

from packages.domain.crowd.pump_detection import PumpDetection
from packages.domain.crowd.value_objects.detection_id import DetectionId

__all__ = ["PumpDetectionRepositoryPort"]


@runtime_checkable
class PumpDetectionRepositoryPort(Protocol):
    """Port for PumpDetection aggregate storage and retrieval."""

    def save(self, detection: PumpDetection) -> None:
        """Persist or update a PumpDetection aggregate (upsert by detection_id)."""
        ...

    def get_pending_review(self) -> list[PumpDetection]:
        """Return all PumpDetections with status='pending_review' for human review."""
        ...

    def find_by_id(self, detection_id: DetectionId) -> PumpDetection | None:
        """Return PumpDetection by ID, or None if not found."""
        ...

    def find_recent(self, ticker: str, since: datetime) -> list[PumpDetection]:
        """Return recent PumpDetections for a ticker after the given timestamp."""
        ...
