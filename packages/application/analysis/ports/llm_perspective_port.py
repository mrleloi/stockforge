"""LLMPerspectivePort — application-layer Protocol for LLM perspective agents.

Concrete implementations live in packages.infrastructure.analysis.perspectives.*
The use case only depends on this Protocol — never the concrete class.

Dependency flow:
  ValidateThesisPhase1UseCase
    → LLMPerspectivePort (this Protocol)
      ← BearPerspectiveAgent | BullPerspectiveAgent | QuantPerspectiveAgent (infra)

analyze() accepts:
- ticker: the stock symbol under analysis
- context: SharedContext bundle (Tier 1+2 data gathered deterministically)
- role: which perspective this agent plays (BEAR/BULL/QUANT)

Returns a PerspectiveAnalysis with non-empty key_points (or raises on failure).
LLM calls inside analyze() MUST NOT produce numeric values in prose (I-S1).

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.4.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol, runtime_checkable

if TYPE_CHECKING:
    from packages.contracts.types import Ticker
    from packages.domain.analysis.models.perspective_analysis import (
        PerspectiveAnalysis,
        PerspectiveRole,
    )

__all__ = ["LLMPerspectivePort"]


@runtime_checkable
class LLMPerspectivePort(Protocol):
    """Protocol for a single-perspective LLM analyst agent."""

    async def analyze(
        self,
        ticker: Ticker,
        context: object,  # SharedContext — typed as object to avoid circular imports
        role: PerspectiveRole,
    ) -> PerspectiveAnalysis:
        """Run the perspective analysis and return a PerspectiveAnalysis.

        MUST NOT produce numeric values in prose (I-S1 / BR-2).
        MUST record cost_usd in Decimal (never float).
        MUST record model_id and prompt_hash for reproducibility (AC-5).
        """
        ...
