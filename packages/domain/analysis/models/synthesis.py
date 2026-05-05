"""Synthesis — multi-perspective synthesis produced by Phase1Synthesizer.

Synthesis is the output of aggregating all perspective analyses. It MUST NOT
collapse disagreements — the invariant in __post_init__ raises
SynthesisInvariantError if confluence==STRONG_CONSENSUS but
explicit_disagreements is non-empty (BR-3 / I-S12).

Disagreement is detected per-dimension (VALUE/QUALITY/GROWTH/RISK):
- Bear=STRONG AND Bull=WEAK → disagreement on that dimension
- Bear=WEAK AND Bull=STRONG → disagreement on that dimension
Both are recorded in explicit_disagreements. The presence of any disagreement
forces confluence to DISAGREEMENT, never STRONG_CONSENSUS.

reasoning_trace is a human-readable audit string from the synthesizer
explaining how it reached the confluence assessment.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.2 + § A.11.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.trade_off_matrix import TradeOffMatrix

__all__ = ["Confluence", "Disagreement", "Synthesis", "SynthesisInvariantError"]


class Confluence(StrEnum):
    """Degree of agreement across perspective analyses."""

    STRONG_CONSENSUS = "strong_consensus"
    MIXED = "mixed"
    DISAGREEMENT = "disagreement"


class SynthesisInvariantError(ValueError):
    """Raised when Synthesis violates I-S12 disagreement-preservation invariant.

    Specifically: confluence=STRONG_CONSENSUS with non-empty explicit_disagreements
    is contradictory and indicates a bug in Phase1Synthesizer.
    """


@dataclass(frozen=True, slots=True)
class Disagreement:
    """One detected dimension-level disagreement between two perspectives.

    `dimension`: the trade-off dimension where the disagreement was detected
                 (one of VALUE / QUALITY / GROWTH / RISK).
    `bear_verdict`: the Bear perspective's DimensionVerdict for this dimension.
    `bull_verdict`: the Bull perspective's DimensionVerdict for this dimension.
    `note`: optional human-readable description of the disagreement.
    `kind`: classifier — `verdict` (opposite STRONG/WEAK extremes; original spec
            § A.11 rule) or `narrative` (asymmetric strength: one side STRONG,
            the other engaged but NEUTRAL on the same dimension; P3 extension
            per VF-5 calibration S43e). Default `verdict` for backward-compat.
    """

    dimension: str
    bear_verdict: str
    bull_verdict: str
    note: str = ""
    kind: str = "verdict"


@dataclass(frozen=True, slots=True)
class Synthesis:
    """Immutable multi-perspective synthesis.

    Invariant (I-S12 / BR-3): if explicit_disagreements is non-empty,
    confluence_assessment MUST NOT be STRONG_CONSENSUS — this would indicate
    the synthesizer incorrectly collapsed opposing conclusions.

    `catalysts`: GroundedPoints representing potential re-rating catalysts.
    `risks`: GroundedPoints representing key downside risks after synthesis.
    `reasoning_trace`: human-readable audit trail of synthesis logic.
    """

    trade_off_matrix: TradeOffMatrix
    confluence_assessment: Confluence
    explicit_disagreements: tuple[Disagreement, ...]
    catalysts: tuple[GroundedPoint, ...]
    risks: tuple[GroundedPoint, ...]
    reasoning_trace: str

    def __post_init__(self) -> None:
        # I-S12 / BR-3 invariant: disagreements NEVER silently collapsed
        if (
            self.explicit_disagreements
            and self.confluence_assessment == Confluence.STRONG_CONSENSUS
        ):
            raise SynthesisInvariantError(
                "Synthesis.confluence cannot be STRONG_CONSENSUS when "
                "explicit_disagreements is non-empty (I-S12 / BR-3). "
                "Phase1Synthesizer must set confluence=DISAGREEMENT when "
                "opposing conclusions are detected."
            )
