"""TradeOffMatrix — multi-dimensional trade-off evidence per thesis.

Dimensions: VALUE / QUALITY / GROWTH / RISK. Each maps to a DimensionVerdict
(STRONG | NEUTRAL | WEAK) and a tuple of GroundedPoints as evidence.

This enforces I-S52: no single scalar score output. The matrix is the only
valid output format for a synthesis conclusion.

DimensionVerdict is the per-dimension distillation — distinct from Conviction
(which is per-point). A dimension can be STRONG even if individual points
vary in conviction.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from enum import StrEnum

from packages.domain.analysis.value_objects.grounded_point import GroundedPoint

__all__ = ["DIMENSIONS", "DimensionVerdict", "TradeOffMatrix"]

DIMENSIONS: tuple[str, ...] = ("VALUE", "QUALITY", "GROWTH", "RISK")


class DimensionVerdict(StrEnum):
    """Overall verdict for a single trade-off dimension."""

    STRONG = "strong"
    NEUTRAL = "neutral"
    WEAK = "weak"


@dataclass(frozen=True, slots=True)
class TradeOffMatrix:
    """Immutable multi-dimensional trade-off evidence bundle.

    `scores`: maps dimension name → DimensionVerdict.
    `evidence`: maps dimension name → tuple of GroundedPoints backing the verdict.

    Both mappings may be partial (e.g. GROWTH evidence empty if data gaps exist).
    Consumers must not assume all DIMENSIONS keys are present.
    """

    scores: Mapping[str, DimensionVerdict]
    evidence: Mapping[str, tuple[GroundedPoint, ...]]
