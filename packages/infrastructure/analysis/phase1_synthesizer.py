"""Phase1Synthesizer — deterministic multi-perspective synthesis.

Aggregates BEAR / BULL / QUANT perspectives into a Synthesis entity:
1. Detects per-dimension disagreement (VALUE/QUALITY/GROWTH/RISK) per spec § A.11:
   - Disagreement = Bear=STRONG AND Bull=WEAK OR Bear=WEAK AND Bull=STRONG
   - Any disagreement → confluence=DISAGREEMENT, never STRONG_CONSENSUS (I-S12)
2. Builds TradeOffMatrix from Bear/Bull/Quant evidence per dimension
3. Computes confluence assessment:
   - Any disagreement → DISAGREEMENT
   - All dimensions STRONG (Bear weak across all dims, Bull strong) → STRONG_CONSENSUS
   - Otherwise → MIXED
4. Extracts catalysts from Bull key_points and risks from Bear key_points
5. Writes reasoning_trace for auditability

IMPORTANT: Phase1Synthesizer is PURE LOGIC — no LLM call. The synthesizer
does NOT call the Anthropic SDK. Synthesis is deterministic given the perspectives.
This is a deliberate simplification for Phase 2; Phase 3 may add an LLM-grade
synthesis step per spec § A.6.1.

Cost: Decimal("0") — no LLM billing here. The cost attributed to "synthesizer"
in spec § B.10 ($0.40 Opus) is for a future LLM synthesizer in Phase 3.
For Phase 2, synthesis is free (deterministic Python).

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.6 + § A.11.
"""

from __future__ import annotations

import logging

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import (
    Confluence,
    Disagreement,
    Synthesis,
)
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DIMENSIONS,
    DimensionVerdict,
    TradeOffMatrix,
)

__all__ = ["Phase1Synthesizer"]

log = logging.getLogger(__name__)

# Map conviction → dimension verdict for aggregation
_CONVICTION_TO_VERDICT = {
    Conviction.STRONG: DimensionVerdict.STRONG,
    Conviction.MODERATE: DimensionVerdict.NEUTRAL,
    Conviction.WEAK: DimensionVerdict.WEAK,
}

# Category → dimension mapping for trade-off matrix population
_CATEGORY_TO_DIMENSION: dict[str, str] = {
    # Bear categories
    "valuation": "VALUE",
    "fundamental": "QUALITY",
    "structural": "QUALITY",
    "competitive": "GROWTH",
    "governance": "QUALITY",
    "macro": "RISK",
    # Bull categories (bull uses same categories plus GROWTH/NARRATIVE/MACRO)
    "growth": "GROWTH",
    "narrative": "GROWTH",
}


def _points_to_verdict(points: list[GroundedPoint]) -> DimensionVerdict:
    """Aggregate a list of GroundedPoints into a single DimensionVerdict."""
    if not points:
        return DimensionVerdict.NEUTRAL
    counts = {v: 0 for v in DimensionVerdict}
    for p in points:
        counts[_CONVICTION_TO_VERDICT[p.conviction]] += 1
    if counts[DimensionVerdict.STRONG] > 0:
        return DimensionVerdict.STRONG
    if counts[DimensionVerdict.WEAK] > counts[DimensionVerdict.NEUTRAL]:
        return DimensionVerdict.WEAK
    return DimensionVerdict.NEUTRAL


def _build_dimension_buckets(
    perspective: PerspectiveAnalysis,
) -> dict[str, list[GroundedPoint]]:
    """Group a perspective's key_points into DIMENSIONS buckets."""
    buckets: dict[str, list[GroundedPoint]] = {d: [] for d in DIMENSIONS}
    for point in perspective.key_points:
        cat = (point.category or "").lower()
        dim = _CATEGORY_TO_DIMENSION.get(cat, "RISK")  # default unmapped → RISK
        if dim in buckets:
            buckets[dim].append(point)
    return buckets


class Phase1Synthesizer:
    """Deterministic Phase 1 synthesizer. No LLM — pure Python logic.

    Detects disagreement between Bear and Bull per-dimension and builds the
    TradeOffMatrix. Confluence=DISAGREEMENT if any dimension shows opposing
    conclusions; STRONG_CONSENSUS only if Bear is consistently WEAK and Bull
    consistently STRONG across all dimensions with evidence.
    """

    async def synthesize(
        self,
        ticker: Ticker,
        perspectives: tuple[PerspectiveAnalysis, ...],
        _context: object,
    ) -> Synthesis:
        """Produce Synthesis from the 3 perspective analyses.

        Preserves all disagreements (I-S12). Never collapses to HOLD.
        """
        bear = next((p for p in perspectives if p.role == PerspectiveRole.BEAR), None)
        bull = next((p for p in perspectives if p.role == PerspectiveRole.BULL), None)
        quant = next((p for p in perspectives if p.role == PerspectiveRole.QUANT), None)

        bear_buckets = _build_dimension_buckets(bear) if bear else {d: [] for d in DIMENSIONS}
        bull_buckets = _build_dimension_buckets(bull) if bull else {d: [] for d in DIMENSIONS}
        quant_buckets = _build_dimension_buckets(quant) if quant else {d: [] for d in DIMENSIONS}

        # Detect disagreements per dimension (§ A.11)
        explicit_disagreements: list[Disagreement] = []
        scores: dict[str, DimensionVerdict] = {}
        evidence: dict[str, tuple[GroundedPoint, ...]] = {}

        for dim in DIMENSIONS:
            bear_verdict = _points_to_verdict(bear_buckets[dim])
            bull_verdict = _points_to_verdict(bull_buckets[dim])
            quant_verdict = _points_to_verdict(quant_buckets[dim])

            # Disagreement detection — two kinds:
            #   verdict   = opposite STRONG/WEAK extremes (original spec § A.11 rule)
            #   narrative = asymmetric strength on engaged dimension (P3 extension
            #               per VF-5 calibration S43e — both perspectives have ≥1
            #               point on the dimension, but one verdict is STRONG and
            #               the other NEUTRAL → meaningful narrative tension that
            #               the original verdict-only rule misses)
            if (
                bear_verdict == DimensionVerdict.STRONG
                and bull_verdict == DimensionVerdict.WEAK
            ) or (
                bear_verdict == DimensionVerdict.WEAK
                and bull_verdict == DimensionVerdict.STRONG
            ):
                explicit_disagreements.append(
                    Disagreement(
                        dimension=dim,
                        bear_verdict=str(bear_verdict),
                        bull_verdict=str(bull_verdict),
                        note=(
                            f"Bear {bear_verdict} vs Bull {bull_verdict} on {dim} — "
                            "opposing conclusions; investigate further."
                        ),
                        kind="verdict",
                    )
                )
            elif bear_buckets[dim] and bull_buckets[dim] and (
                (
                    bear_verdict == DimensionVerdict.STRONG
                    and bull_verdict == DimensionVerdict.NEUTRAL
                )
                or (
                    bear_verdict == DimensionVerdict.NEUTRAL
                    and bull_verdict == DimensionVerdict.STRONG
                )
            ):
                explicit_disagreements.append(
                    Disagreement(
                        dimension=dim,
                        bear_verdict=str(bear_verdict),
                        bull_verdict=str(bull_verdict),
                        note=(
                            f"Bear {bear_verdict} vs Bull {bull_verdict} on {dim} — "
                            "asymmetric narrative strength; both perspectives engaged "
                            "but with conviction mismatch. Investigate further (P3)."
                        ),
                        kind="narrative",
                    )
                )

            # Synthesize dimension score: favour quant data if available
            dim_evidence: list[GroundedPoint] = (
                bear_buckets[dim] + bull_buckets[dim] + quant_buckets[dim]
            )
            if quant_buckets[dim]:
                scores[dim] = quant_verdict
            elif dim_evidence:
                # Average bear and bull
                both_verdicts = [bear_verdict, bull_verdict]
                strong_count = sum(1 for v in both_verdicts if v == DimensionVerdict.STRONG)
                weak_count = sum(1 for v in both_verdicts if v == DimensionVerdict.WEAK)
                if strong_count > weak_count:
                    scores[dim] = DimensionVerdict.STRONG
                elif weak_count > strong_count:
                    scores[dim] = DimensionVerdict.WEAK
                else:
                    scores[dim] = DimensionVerdict.NEUTRAL
            else:
                scores[dim] = DimensionVerdict.NEUTRAL

            evidence[dim] = tuple(dim_evidence)

        matrix = TradeOffMatrix(scores=dict(scores), evidence=dict(evidence))

        # Determine confluence
        if explicit_disagreements:
            confluence = Confluence.DISAGREEMENT
        elif all(v == DimensionVerdict.STRONG for v in scores.values()):
            confluence = Confluence.STRONG_CONSENSUS
        elif all(v == DimensionVerdict.WEAK for v in scores.values()):
            confluence = Confluence.MIXED  # weak across board = mixed/insufficient
        else:
            confluence = Confluence.MIXED

        # Catalysts from bull key_points (high conviction)
        catalysts = tuple(
            p for p in (bull.key_points if bull else ())
            if p.conviction in (Conviction.STRONG, Conviction.MODERATE)
        )[:5]  # top 5

        # Risks from bear key_points
        risks = tuple(
            p for p in (bear.key_points if bear else ())
            if p.conviction in (Conviction.STRONG, Conviction.MODERATE)
        )[:5]

        # Build reasoning trace
        dims_summary = "; ".join(
            f"{d}={scores.get(d, DimensionVerdict.NEUTRAL)}" for d in DIMENSIONS
        )
        disagreement_summary = (
            f"{len(explicit_disagreements)} dimension(s) with opposing conclusions"
            if explicit_disagreements
            else "no disagreements detected"
        )
        reasoning_trace = (
            f"Phase1Synthesizer | {ticker.symbol} | "
            f"Dimensions: {dims_summary} | "
            f"Confluence: {confluence} | "
            f"{disagreement_summary} | "
            f"Bear points: {len(bear.key_points) if bear else 0} | "
            f"Bull points: {len(bull.key_points) if bull else 0} | "
            f"Quant points: {len(quant.key_points) if quant else 0}"
        )

        return Synthesis(
            trade_off_matrix=matrix,
            confluence_assessment=confluence,
            explicit_disagreements=tuple(explicit_disagreements),
            catalysts=catalysts,
            risks=risks,
            reasoning_trace=reasoning_trace,
        )
