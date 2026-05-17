"""PerspectiveAnalysis — one analyst perspective within a thesis.

Phase 2 ships 3 active perspectives: BEAR / BULL / QUANT. The remaining
3 (MACRO / BEHAVIOR / MANAGER) are Phase 3 stubs — they exist in the enum
but their instances carry `deferred=True` and an empty key_points tuple.

Each PerspectiveAnalysis records:
- which LLM model was used (model_id)
- a sha256 hash of the prompt that produced it (prompt_hash) for AC-5 reproducibility
- the USD cost of the LLM call (cost_usd) — Decimal, never float
- the list of GroundedPoints constituting the analyst's case (key_points)

Frozen + slotted: immutable post-construction.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal
from enum import StrEnum

from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint

__all__ = ["PerspectiveAnalysis", "PerspectiveRole"]


class PerspectiveRole(StrEnum):
    """Which analytical stance this perspective adopts."""

    BEAR = "bear"
    BULL = "bull"
    QUANT = "quant"
    # Phase 3 stubs — deferred=True on their PerspectiveAnalysis instances
    MACRO = "macro"
    BEHAVIOR = "behavior"
    MANAGER = "manager"
    # F.2 plan-035 additions — active persona-pack adapters (RolePromptPack-driven)
    BUFFETT = "buffett"
    GRAHAM = "graham"
    TALEB = "taleb"


@dataclass(frozen=True, slots=True)
class PerspectiveAnalysis:
    """Immutable output of one LLM perspective agent.

    `role`: which agent produced this analysis.
    `key_points`: tuple of GroundedPoints supporting the perspective's case.
    `overall_conviction`: aggregate strength across all key_points.
    `cost_usd`: Decimal cost of the LLM call; Decimal("0") for deferred stubs.
    `model_id`: LLM model identifier (e.g. "claude-sonnet-4-6").
    `prompt_hash`: sha256[:16] of the system prompt (reproducibility AC-5).
    `deferred`: True for Phase 3 stubs; False for active Phase 2 perspectives.
    """

    role: PerspectiveRole
    key_points: tuple[GroundedPoint, ...]
    overall_conviction: Conviction
    cost_usd: Decimal
    model_id: str
    prompt_hash: str
    deferred: bool = False
