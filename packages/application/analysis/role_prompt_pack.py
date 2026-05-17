"""RolePromptPack — per-persona configuration data for BC-8 perspective agents.

Frozen + slotted dataclass shipping data only (no behavior). Consumed by
PersonaRegistry (lookup) and per-persona adapter classes (template rendering +
validator parameterization).

Per master plan-033 DD-7 + sub-plan 034 DD-1 + DD-7: data-driven persona
pattern; per-persona behavior (retry-validator + Jaccard distinctness + I-S10
strict gate) lives in adapter class, not here.

Rule 16 mode 1 categorical surrogate preserved: all numeric fields are integer
THRESHOLDS set at registration time (NOT LLM output). LLM output schema
unchanged per existing PerspectiveAnalysis contract.

Source: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md DD-7
"""

from __future__ import annotations

import re
from dataclasses import dataclass

__all__ = ["RolePromptPack", "RolePromptPackInvariantError"]

_ROLE_ID_RE = re.compile(r"^[a-z][a-z0-9_]*$")
_ALLOWED_MODELS = frozenset({"claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5"})


class RolePromptPackInvariantError(ValueError):
    """Raised when RolePromptPack invariant violated at __post_init__."""


@dataclass(frozen=True, slots=True)
class RolePromptPack:
    """Per-persona configuration data for BC-8 perspective agents.

    Fields per master plan-033 DD-7 + plan-034 DD-7 EXACT shape.

    All numeric fields (min_points, min_distinct_categories) are integer
    THRESHOLDS set at registration time — NOT emitted by the LLM.
    Conviction guidance is text-only rubric instructing LLM to pick categorical
    Conviction enum value (STRONG/MODERATE/WEAK) per Rule 16 mode 1.
    """

    role_id: str
    persona_name: str
    system_prompt_template: str
    conviction_guidance: str
    citation_requirements: str
    vietnam_notes: str
    min_points: int
    min_distinct_categories: int
    category_universe: tuple[str, ...]
    model_id_preference: str | None = None

    def __post_init__(self) -> None:
        if not self.role_id or not _ROLE_ID_RE.match(self.role_id):
            raise RolePromptPackInvariantError(
                f"role_id {self.role_id!r} must match ^[a-z][a-z0-9_]*$ "
                f"(lowercase identifier; use underscore not hyphen)"
            )
        if not self.persona_name:
            raise RolePromptPackInvariantError("persona_name must be non-empty")
        if not self.system_prompt_template:
            raise RolePromptPackInvariantError("system_prompt_template must be non-empty")
        if "{TICKER}" not in self.system_prompt_template:
            raise RolePromptPackInvariantError(
                "system_prompt_template must contain {TICKER} placeholder "
                "(matches existing BEAR/BULL/QUANT SYSTEM_PROMPT pattern at bear_agent.py:42)"
            )
        if not self.conviction_guidance:
            raise RolePromptPackInvariantError("conviction_guidance must be non-empty")
        if not self.citation_requirements:
            raise RolePromptPackInvariantError("citation_requirements must be non-empty")
        # vietnam_notes MAY be empty (some personas may lack VN-specific notes)
        if self.min_points < 1:
            raise RolePromptPackInvariantError(
                f"min_points {self.min_points} must be >= 1"
            )
        if self.min_distinct_categories < 1:
            raise RolePromptPackInvariantError(
                f"min_distinct_categories {self.min_distinct_categories} must be >= 1"
            )
        if not self.category_universe:
            raise RolePromptPackInvariantError("category_universe must be non-empty tuple")
        if self.min_distinct_categories > len(self.category_universe):
            raise RolePromptPackInvariantError(
                f"min_distinct_categories {self.min_distinct_categories} exceeds "
                f"category_universe size {len(self.category_universe)}"
            )
        if len(set(self.category_universe)) != len(self.category_universe):
            raise RolePromptPackInvariantError(
                f"category_universe {self.category_universe!r} contains duplicates"
            )
        if (
            self.model_id_preference is not None
            and self.model_id_preference not in _ALLOWED_MODELS
        ):
            raise RolePromptPackInvariantError(
                f"model_id_preference {self.model_id_preference!r} must be None "
                f"or one of {sorted(_ALLOWED_MODELS)}"
            )
