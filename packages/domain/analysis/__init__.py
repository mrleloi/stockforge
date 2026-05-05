"""BC-8 Analysis — domain layer barrel export.

Phase 2 Track F: first production thesis pipeline for Vietnamese stock analysis.

Domain contains:
- value_objects: GroundedPoint, TradeOffMatrix, Recommendation, ConfidenceLevel,
                 Conviction, BearCategory, DimensionVerdict
- models: Thesis (aggregate root), PerspectiveAnalysis, Synthesis, Disagreement
- repositories: ThesisRepository (Protocol)

No framework imports. Pure Python: dataclasses + stdlib + StrEnum only.
Cross-BC types imported from packages.contracts only (never from other domain BCs).

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from .models import (
    BearCaseInvariantError,
    Confluence,
    Disagreement,
    PerspectiveAnalysis,
    PerspectiveRole,
    Synthesis,
    SynthesisInvariantError,
    Thesis,
    ThesisStatus,
)
from .repositories import ThesisRepository
from .value_objects import (
    DIMENSIONS,
    BearCategory,
    ConfidenceLevel,
    Conviction,
    DimensionVerdict,
    GroundedPoint,
    GroundedPointInvariantError,
    Recommendation,
    TradeOffMatrix,
)

__all__ = [
    "DIMENSIONS",
    "BearCaseInvariantError",
    "BearCategory",
    "Confluence",
    "ConfidenceLevel",
    "Conviction",
    "DimensionVerdict",
    "Disagreement",
    "GroundedPoint",
    "GroundedPointInvariantError",
    "PerspectiveAnalysis",
    "PerspectiveRole",
    "Recommendation",
    "Synthesis",
    "SynthesisInvariantError",
    "Thesis",
    "ThesisRepository",
    "ThesisStatus",
    "TradeOffMatrix",
]
