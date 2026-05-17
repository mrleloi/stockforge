"""Phase1Synthesizer — deterministic multi-perspective synthesis.

Aggregates N perspectives (V0=6: BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB) into a
Synthesis entity. F.3 plan-036 extends the original 3-persona logic to handle
N≥4 personas via role-aware dispatch + pairwise disagreement detection.

1. Detects per-dimension disagreement (VALUE/QUALITY/GROWTH/RISK) per spec § A.11:
   - Disagreement = any pair of personas with opposing STRONG/WEAK verdicts on dim
   - Any disagreement → confluence=DISAGREEMENT, never STRONG_CONSENSUS (I-S12)
   - Extended from BEAR-vs-BULL only to ALL-PAIRS via itertools.combinations (DD-5)
2. Builds TradeOffMatrix from N-persona evidence per dimension
3. Computes dimension scores: QUANT-favoured; else MAJORITY-CATEGORICAL across N (DD-3)
4. Computes confluence assessment:
   - Any disagreement → DISAGREEMENT
   - All dimensions STRONG → STRONG_CONSENSUS
   - Otherwise → MIXED
5. Extracts catalysts from Bull key_points and risks from Bear key_points
   (canonical attribution preserved per plan-036 DD-3 architect decision)
6. Writes reasoning_trace for auditability (includes all N-persona point counts)

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

import itertools
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

    F.3 (plan-036 D2): Extended from 3-persona (BEAR/BULL/QUANT) to N≥4 personas.
    Key changes:
    - by_role lookup replaces named BEAR/BULL/QUANT variables (handles any PerspectiveRole)
    - pairwise disagreement detection via itertools.combinations across ALL N personas (DD-5)
    - majority-categorical scoring when QUANT absent (DD-3); QUANT-favoured preserved
    - reasoning_trace logs all N-persona point counts (N-agnostic format)

    Confluence=DISAGREEMENT if any pairwise persona pair shows opposing conclusions;
    STRONG_CONSENSUS only if all dimension scores are STRONG with no disagreements.
    """

    async def synthesize(
        self,
        ticker: Ticker,
        perspectives: tuple[PerspectiveAnalysis, ...],
        _context: object,
    ) -> Synthesis:
        """Produce Synthesis from N perspective analyses.

        Preserves all pairwise disagreements across N personas (I-S12). Never collapses.
        """
        # N-perspective dispatch — group by role (handles V0=6: BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB)
        by_role: dict[PerspectiveRole, PerspectiveAnalysis] = {p.role: p for p in perspectives}
        bear = by_role.get(PerspectiveRole.BEAR)
        bull = by_role.get(PerspectiveRole.BULL)
        quant = by_role.get(PerspectiveRole.QUANT)

        # Build dimension buckets for ALL N personas (canonical BEAR/BULL/QUANT + additional)
        # Each entry: (perspective, its dimension buckets)
        all_with_buckets: list[tuple[PerspectiveAnalysis, dict[str, list[GroundedPoint]]]] = [
            (p, _build_dimension_buckets(p)) for p in perspectives
        ]
        quant_buckets: dict[str, list[GroundedPoint]] = (
            _build_dimension_buckets(quant) if quant else {d: [] for d in DIMENSIONS}
        )

        # Detect disagreements per dimension — pairwise across ALL N personas (DD-5)
        # Extends prior BEAR-vs-BULL-only pairwise to ALL-PAIRS via itertools.combinations.
        # Disagreement field names bear_verdict/bull_verdict RETAINED per plan-036 DD-5
        # (backward-compat; represent p1/p2 verdict respectively for any persona pair).
        # Disagreement.note clarifies pairwise semantics per DD-5 extension.
        explicit_disagreements: list[Disagreement] = []
        scores: dict[str, DimensionVerdict] = {}
        evidence: dict[str, tuple[GroundedPoint, ...]] = {}

        for dim in DIMENSIONS:
            dim_disagreements_added: set[tuple[str, str]] = set()  # deduplicate per pair

            # Pairwise disagreement detection across ALL N personas (per plan-036 DD-5)
            for (p1, b1), (p2, b2) in itertools.combinations(all_with_buckets, 2):
                v1 = _points_to_verdict(b1[dim])
                v2 = _points_to_verdict(b2[dim])
                pair_key = (p1.role.value, p2.role.value)

                # Verdict disagreement: opposing STRONG/WEAK extremes (original spec § A.11 rule)
                if (
                    pair_key not in dim_disagreements_added
                    and (
                        (v1 == DimensionVerdict.STRONG and v2 == DimensionVerdict.WEAK)
                        or (v1 == DimensionVerdict.WEAK and v2 == DimensionVerdict.STRONG)
                    )
                ):
                    dim_disagreements_added.add(pair_key)
                    explicit_disagreements.append(
                        Disagreement(
                            dimension=dim,
                            bear_verdict=str(v1),   # p1 verdict (field name retained DD-5)
                            bull_verdict=str(v2),   # p2 verdict (field name retained DD-5)
                            note=(
                                f"{p1.role} {v1} vs {p2.role} {v2} on {dim} — "
                                "opposing conclusions; investigate further."
                            ),
                            kind="verdict",
                        )
                    )
                # Narrative disagreement: asymmetric strength on engaged dimension (P3 extension
                # per VF-5 calibration S43e — both perspectives have ≥1 point on the dim,
                # but one verdict is STRONG and the other NEUTRAL).
                elif (
                    b1[dim]
                    and b2[dim]
                    and pair_key not in dim_disagreements_added
                    and (
                        (v1 == DimensionVerdict.STRONG and v2 == DimensionVerdict.NEUTRAL)
                        or (v1 == DimensionVerdict.NEUTRAL and v2 == DimensionVerdict.STRONG)
                    )
                ):
                    dim_disagreements_added.add(pair_key)
                    explicit_disagreements.append(
                        Disagreement(
                            dimension=dim,
                            bear_verdict=str(v1),   # p1 verdict
                            bull_verdict=str(v2),   # p2 verdict
                            note=(
                                f"{p1.role} {v1} vs {p2.role} {v2} on {dim} — "
                                "asymmetric narrative strength; both perspectives engaged "
                                "but with conviction mismatch. Investigate further (P3)."
                            ),
                            kind="narrative",
                        )
                    )

            # Dimension scoring: QUANT-favoured (per plan-036 DD-3 preserved);
            # else MAJORITY-CATEGORICAL across all N personas (DD-3 simplicity-first).
            dim_evidence: list[GroundedPoint] = []
            for _, buckets in all_with_buckets:
                dim_evidence.extend(buckets[dim])

            if quant_buckets[dim]:
                # QUANT verdict wins when QUANT has evidence on this dimension
                scores[dim] = _points_to_verdict(quant_buckets[dim])
            elif dim_evidence:
                # MAJORITY-CATEGORICAL: count STRONG vs WEAK across all N personas with evidence
                all_verdicts = [
                    _points_to_verdict(buckets[dim])
                    for _, buckets in all_with_buckets
                    if buckets[dim]  # only count personas engaged on this dim
                ]
                strong_n = sum(1 for v in all_verdicts if v == DimensionVerdict.STRONG)
                weak_n = sum(1 for v in all_verdicts if v == DimensionVerdict.WEAK)
                if strong_n > weak_n:
                    scores[dim] = DimensionVerdict.STRONG
                elif weak_n > strong_n:
                    scores[dim] = DimensionVerdict.WEAK
                else:
                    scores[dim] = DimensionVerdict.NEUTRAL  # tie defaults to NEUTRAL (DD-3)
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

        # Catalysts from bull key_points (high conviction) — canonical BULL attribution
        # preserved per plan-036 DD-3 architect decision; additional personas (BUFFETT/
        # GRAHAM/TALEB) contribute via TradeOffMatrix.evidence, not catalysts/risks.
        catalysts = tuple(
            p for p in (bull.key_points if bull else ())
            if p.conviction in (Conviction.STRONG, Conviction.MODERATE)
        )[:5]  # top 5

        # Risks from bear key_points — canonical BEAR attribution preserved per DD-3
        risks = tuple(
            p for p in (bear.key_points if bear else ())
            if p.conviction in (Conviction.STRONG, Conviction.MODERATE)
        )[:5]

        # Build reasoning trace — includes all N-persona point counts (N-agnostic format)
        dims_summary = "; ".join(
            f"{d}={scores.get(d, DimensionVerdict.NEUTRAL)}" for d in DIMENSIONS
        )
        disagreement_summary = (
            f"{len(explicit_disagreements)} dimension(s) with opposing conclusions"
            if explicit_disagreements
            else "no disagreements detected"
        )
        persona_count_summary = ", ".join(
            f"{p.role}: {len(p.key_points)} points"
            for p in sorted(perspectives, key=lambda p: p.role.value)
        )
        reasoning_trace = (
            f"Phase1Synthesizer | {ticker.symbol} | "
            f"Dimensions: {dims_summary} | "
            f"Confluence: {confluence} | "
            f"{disagreement_summary} | "
            f"Perspectives ({len(perspectives)}): {persona_count_summary}"
        )

        return Synthesis(
            trade_off_matrix=matrix,
            confluence_assessment=confluence,
            explicit_disagreements=tuple(explicit_disagreements),
            catalysts=catalysts,
            risks=risks,
            reasoning_trace=reasoning_trace,
        )
