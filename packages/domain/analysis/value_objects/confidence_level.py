"""ConfidenceLevel — heuristic confidence in a thesis (Phase 1).

Phase 1 has no calibration database (n_samples=0). Confidence is set
heuristically per BR-7:
- HIGH: all 3 perspectives agree + STRONG verdicts
- MEDIUM: mixed grounded perspectives
- LOW: disagreement present OR limited evidence

Phase 3 will replace with calibration-backed confidence; until then every
thesis output records `calibration_grade: D`.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["ConfidenceLevel"]


class ConfidenceLevel(StrEnum):
    """Heuristic confidence level (Phase 1 only; calibration_grade D)."""

    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
