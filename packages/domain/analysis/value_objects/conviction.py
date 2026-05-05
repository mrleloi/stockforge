"""Conviction — strength of an analytical point.

Used by GroundedPoint and PerspectiveAnalysis to declare how strongly
an analyst holds a position. Influences disagreement detection threshold
in Phase1Synthesizer.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["Conviction"]


class Conviction(StrEnum):
    """Conviction level for a GroundedPoint or PerspectiveAnalysis."""

    STRONG = "strong"
    MODERATE = "moderate"
    WEAK = "weak"
