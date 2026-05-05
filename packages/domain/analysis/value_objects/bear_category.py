"""BearCategory — taxonomy of bear-case risk categories.

Used by GroundedPoint.category to enforce category-distinctness in
Thesis._enforce_bear_case() (BR-1 / I-S10). The ≥3-distinct-category rule
prevents three rephrasings of the same risk passing as a bear case.

Categories per spec § A.11 adversarial check:
FUNDAMENTAL / STRUCTURAL / VALUATION / COMPETITIVE / GOVERNANCE / MACRO.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § A.11.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["BearCategory"]


class BearCategory(StrEnum):
    """Risk category taxonomy for bear-case GroundedPoints."""

    FUNDAMENTAL = "fundamental"
    STRUCTURAL = "structural"
    VALUATION = "valuation"
    COMPETITIVE = "competitive"
    GOVERNANCE = "governance"
    MACRO = "macro"
