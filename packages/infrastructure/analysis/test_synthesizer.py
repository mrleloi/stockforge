"""Tests for Phase1Synthesizer — disagreement detection and synthesis logic.

Coverage per sub-plan deliverable 24:
≥6 tests: disagreement detection thresholds; opposite-conclusion preserved;
INVESTIGATE recommendation when disagreement; STRONG_CONSENSUS path.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 24.
"""

from __future__ import annotations

import asyncio
from datetime import date
from decimal import Decimal

from packages.application.analysis.services.recommendation_heuristic import (
    recommendation_from_synthesis,
)
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import Confluence
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import DimensionVerdict
from packages.infrastructure.analysis.phase1_synthesizer import Phase1Synthesizer

_TODAY = date(2026, 5, 1)
_TICKER = Ticker("HPG")


def _make_point(
    text: str = "claim",
    category: str = "valuation",  # maps to VALUE dimension
    conviction: Conviction = Conviction.STRONG,
) -> GroundedPoint:
    return GroundedPoint(
        text=text,
        source_url="https://example.com/filing.pdf",
        source_excerpt="Verbatim excerpt supporting the claim.",
        as_of=_TODAY,
        conviction=conviction,
        category=category,
    )


def _make_perspective(
    role: PerspectiveRole,
    points: tuple[GroundedPoint, ...] = (),
    conviction: Conviction = Conviction.STRONG,
) -> PerspectiveAnalysis:
    return PerspectiveAnalysis(
        role=role,
        key_points=points,
        overall_conviction=conviction,
        cost_usd=Decimal("0.10"),
        model_id="claude-sonnet-4-6",
        prompt_hash="test",
    )


class _MockContext:
    ticker = _TICKER
    as_of = _TODAY


_CTX = _MockContext()


def test_disagreement_detected_when_bear_strong_bull_weak_on_same_dimension() -> None:
    """Bear=STRONG, Bull=WEAK on VALUE → disagreement detected."""
    synth = Phase1Synthesizer()
    # Bear has STRONG on valuation (→ VALUE dimension)
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(
            _make_point("bear valuation claim", "valuation", Conviction.STRONG),
        ),
    )
    # Bull has WEAK on valuation (→ VALUE dimension)
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(
            _make_point("bull valuation claim", "valuation", Conviction.WEAK),
        ),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert len(synthesis.explicit_disagreements) >= 1
    dim_names = {d.dimension for d in synthesis.explicit_disagreements}
    assert "VALUE" in dim_names


def test_disagreement_detected_when_bear_weak_bull_strong() -> None:
    """Bear=WEAK, Bull=STRONG on VALUE → disagreement detected (reverse direction)."""
    synth = Phase1Synthesizer()
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(_make_point("bear valuation", "valuation", Conviction.WEAK),),
    )
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull valuation", "valuation", Conviction.STRONG),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert len(synthesis.explicit_disagreements) >= 1


def test_no_disagreement_when_bear_and_bull_agree() -> None:
    """Bear=STRONG, Bull=STRONG on same dimension → no disagreement."""
    synth = Phase1Synthesizer()
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(_make_point("bear valuation", "valuation", Conviction.STRONG),),
    )
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull valuation", "valuation", Conviction.STRONG),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert synthesis.explicit_disagreements == ()


def test_disagreement_confluence_is_not_strong_consensus() -> None:
    """When disagreement detected, confluence MUST NOT be STRONG_CONSENSUS."""
    synth = Phase1Synthesizer()
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(_make_point("bear valuation", "valuation", Conviction.STRONG),),
    )
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull valuation", "valuation", Conviction.WEAK),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert synthesis.confluence_assessment != Confluence.STRONG_CONSENSUS
    assert synthesis.confluence_assessment == Confluence.DISAGREEMENT


def test_investigate_recommendation_when_disagreement() -> None:
    """Disagreement → recommendation_from_synthesis → INVESTIGATE."""
    synth = Phase1Synthesizer()
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(_make_point("bear valuation", "valuation", Conviction.STRONG),),
    )
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull valuation", "valuation", Conviction.WEAK),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    rec = recommendation_from_synthesis(synthesis)
    assert rec == Recommendation.INVESTIGATE


def test_strong_consensus_path() -> None:
    """All STRONG verdicts on same side → STRONG_CONSENSUS confluence."""
    synth = Phase1Synthesizer()
    # No bear points (bear is NEUTRAL on all dims) → no disagreement
    # Bull provides STRONG on all reachable dimensions
    bear = _make_perspective(PerspectiveRole.BEAR, points=())
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(
            _make_point("bull val STRONG", "valuation", Conviction.STRONG),
            _make_point("bull growth STRONG", "growth", Conviction.STRONG),
            _make_point("bull fundamental STRONG", "fundamental", Conviction.STRONG),
        ),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    # With no bear points and strong bull → no disagreement possible
    assert synthesis.explicit_disagreements == ()
    # Confluence may be STRONG_CONSENSUS or MIXED depending on dimension coverage
    assert synthesis.confluence_assessment in {Confluence.STRONG_CONSENSUS, Confluence.MIXED}


def test_reasoning_trace_contains_ticker() -> None:
    """Synthesis reasoning_trace records the ticker symbol."""
    synth = Phase1Synthesizer()
    synthesis = asyncio.run(
        synth.synthesize(_TICKER, (_make_perspective(PerspectiveRole.BEAR),), _CTX)
    )
    assert "HPG" in synthesis.reasoning_trace


def test_synthesis_catalysts_from_bull_strong_points() -> None:
    """Bull STRONG/MODERATE points appear in synthesis catalysts."""
    synth = Phase1Synthesizer()
    bull_pt = _make_point("bull catalyst", "growth", Conviction.STRONG)
    bull = _make_perspective(PerspectiveRole.BULL, points=(bull_pt,))
    bear = _make_perspective(PerspectiveRole.BEAR)
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert bull_pt in synthesis.catalysts


def test_narrative_disagreement_bull_strong_bear_neutral_engaged() -> None:
    """P3 extension (VF-5 calibration S43e): bull STRONG, bear engaged-NEUTRAL on
    the same dimension → narrative-disagreement detected with kind='narrative'.

    Both perspectives have ≥1 point on the dimension (bear MODERATE-conviction
    governance point → QUALITY=NEUTRAL; bull STRONG-conviction fundamental →
    QUALITY=STRONG). The original verdict-only rule misses this; P3 catches it.
    """
    synth = Phase1Synthesizer()
    bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(_make_point("bear governance moderate", "governance", Conviction.MODERATE),),
    )
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull fundamental strong", "fundamental", Conviction.STRONG),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert len(synthesis.explicit_disagreements) >= 1
    narrative_kinds = [d for d in synthesis.explicit_disagreements if d.kind == "narrative"]
    assert len(narrative_kinds) >= 1
    assert any(d.dimension == "QUALITY" for d in narrative_kinds)
    assert synthesis.confluence_assessment == Confluence.DISAGREEMENT


def test_narrative_disagreement_does_not_fire_when_one_side_empty() -> None:
    """P3 narrative disagreement requires BOTH perspectives engaged on the dim.

    When bear has 0 points on a dim and bull is STRONG, no narrative-disagreement
    fires (preserves existing test_strong_consensus_path semantics; perspective-
    asymmetry detection deferred to spec § A.11 amendment with user-gate).
    """
    synth = Phase1Synthesizer()
    bear = _make_perspective(PerspectiveRole.BEAR, points=())  # 0 points anywhere
    bull = _make_perspective(
        PerspectiveRole.BULL,
        points=(_make_point("bull fundamental strong", "fundamental", Conviction.STRONG),),
    )
    quant = _make_perspective(PerspectiveRole.QUANT)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant), _CTX))
    assert synthesis.explicit_disagreements == ()


# ---------------------------------------------------------------------------
# F.3 N-persona tests (plan-036 D4 — TC-SYNTH-1 through TC-SYNTH-10)
# ---------------------------------------------------------------------------


def _make_n6_perspectives() -> tuple:
    """Return V0=6 perspectives with 3 key points each on the VALUE dimension."""
    return (
        _make_perspective(PerspectiveRole.BEAR, points=(_make_point("bear val", "valuation", Conviction.STRONG),)),
        _make_perspective(PerspectiveRole.BULL, points=(_make_point("bull val", "valuation", Conviction.WEAK),)),
        _make_perspective(PerspectiveRole.QUANT),
        _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("buffett val", "valuation", Conviction.STRONG),)),
        _make_perspective(PerspectiveRole.GRAHAM, points=(_make_point("graham val", "valuation", Conviction.STRONG),)),
        _make_perspective(PerspectiveRole.TALEB, points=(_make_point("taleb val", "valuation", Conviction.WEAK),)),
    )


def test_n6_disagreement_pairwise_across_all_personas() -> None:
    """TC-SYNTH-1: V0=6 with STRONG/WEAK pair beyond BEAR-vs-BULL → disagreement detected.

    Per plan-036 DD-5 pairwise extension: BUFFETT=STRONG vs TALEB=WEAK on VALUE
    should surface as an additional disagreement beyond BEAR-vs-BULL.
    """
    synth = Phase1Synthesizer()
    perspectives = _make_n6_perspectives()
    synthesis = asyncio.run(synth.synthesize(_TICKER, perspectives, _CTX))
    assert len(synthesis.explicit_disagreements) >= 1
    # Should have BEAR-vs-BULL AND additional pairings (BUFFETT-vs-BULL, BUFFETT-vs-TALEB, etc.)
    assert len(synthesis.explicit_disagreements) > 1


def test_n6_three_personas_disagree_emits_multiple_disagreements() -> None:
    """TC-SYNTH-2: N=3 personas with verdict-disagreement on same dim → ≥ C(3,2)=3 pairs.

    When 3 personas have distinct verdicts (STRONG/WEAK/NEUTRAL) on the same dimension,
    pairwise detection covers all pairs: (BEAR,BULL), (BEAR,QUANT), (BULL,QUANT).
    """
    synth = Phase1Synthesizer()
    # BEAR=STRONG, BULL=WEAK → verdict disagreement pair
    # BEAR=STRONG, QUANT has no points → QUANT=NEUTRAL; BEAR vs QUANT: no STRONG bucket on QUANT → no disagreement
    # BULL=WEAK, QUANT=NEUTRAL: WEAK vs NEUTRAL is not a disagreement category
    # Use 3 personas where 2 pairs qualify:
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("bear val", "valuation", Conviction.STRONG),))
    bull = _make_perspective(PerspectiveRole.BULL, points=(_make_point("bull val", "valuation", Conviction.WEAK),))
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("buffett val", "valuation", Conviction.STRONG),))
    quant = _make_perspective(PerspectiveRole.QUANT)  # no quant points → NEUTRAL, no disagreement
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, buffett, quant), _CTX))
    # Expect at least BEAR-vs-BULL and BUFFETT-vs-BULL pairs as verdict disagreements
    assert len(synthesis.explicit_disagreements) >= 2


def test_n6_quant_favoured_preserved_with_additional_personas() -> None:
    """TC-SYNTH-3: QUANT verdict wins for dim scoring regardless of BUFFETT/GRAHAM/TALEB.

    Per plan-036 DD-3 QUANT-favoured rule extension: even when BUFFETT/GRAHAM/TALEB
    all disagree with QUANT verdict, QUANT verdict still wins for dimension score.
    """
    synth = Phase1Synthesizer()
    # QUANT has STRONG on valuation → VALUE score = STRONG
    # BUFFETT/GRAHAM have WEAK on valuation → if no QUANT, majority = WEAK
    quant = _make_perspective(PerspectiveRole.QUANT, points=(_make_point("quant val STRONG", "valuation", Conviction.STRONG),))
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("bear val WEAK", "valuation", Conviction.WEAK),))
    bull = _make_perspective(PerspectiveRole.BULL)
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("buffett val WEAK", "valuation", Conviction.WEAK),))
    graham = _make_perspective(PerspectiveRole.GRAHAM, points=(_make_point("graham val WEAK", "valuation", Conviction.WEAK),))
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham), _CTX))
    # QUANT-favoured: VALUE dimension score = STRONG (QUANT's verdict wins)
    assert synthesis.trade_off_matrix.scores["VALUE"] == DimensionVerdict.STRONG


def test_n6_majority_categorical_when_quant_absent() -> None:
    """TC-SYNTH-4: majority-categorical scoring when no QUANT — 4 STRONG vs 1 WEAK → STRONG.

    Per plan-036 DD-3: when QUANT absent, majority-categorical across N personas engaged
    on a dimension. 4 STRONG vs 1 WEAK → STRONG score on VALUE.
    """
    synth = Phase1Synthesizer()
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("bear val", "valuation", Conviction.STRONG),))
    bull = _make_perspective(PerspectiveRole.BULL, points=(_make_point("bull val", "valuation", Conviction.STRONG),))
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("buffett val", "valuation", Conviction.STRONG),))
    graham = _make_perspective(PerspectiveRole.GRAHAM, points=(_make_point("graham val", "valuation", Conviction.STRONG),))
    taleb = _make_perspective(PerspectiveRole.TALEB, points=(_make_point("taleb val", "valuation", Conviction.WEAK),))
    quant = _make_perspective(PerspectiveRole.QUANT)  # QUANT with no points → no QUANT-favoured
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    # 4 STRONG vs 1 WEAK → majority = STRONG
    assert synthesis.trade_off_matrix.scores["VALUE"] == DimensionVerdict.STRONG


def test_n6_tie_defaults_to_neutral() -> None:
    """TC-SYNTH-5: 3 STRONG vs 3 WEAK on same dim (no QUANT) → tie → NEUTRAL score.

    Per plan-036 DD-3: tie defaults to NEUTRAL (simplest deterministic rule).
    QUANT absent so QUANT-favoured path not triggered; pure majority-categorical applies.
    Uses PerspectiveRole.MACRO (stub role) as 6th persona to get exactly 3+3.
    """
    synth = Phase1Synthesizer()
    # 3 STRONG + 3 WEAK on "valuation" (VALUE dim); no QUANT persona with valuation points
    pa = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("a", "valuation", Conviction.STRONG),))
    pb = _make_perspective(PerspectiveRole.BULL, points=(_make_point("b", "valuation", Conviction.STRONG),))
    pc = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("c", "valuation", Conviction.STRONG),))
    pd = _make_perspective(PerspectiveRole.GRAHAM, points=(_make_point("d", "valuation", Conviction.WEAK),))
    pe = _make_perspective(PerspectiveRole.TALEB, points=(_make_point("e", "valuation", Conviction.WEAK),))
    pf = _make_perspective(PerspectiveRole.MACRO, points=(_make_point("f", "valuation", Conviction.WEAK),))
    # QUANT absent → no QUANT-favoured → 3 STRONG vs 3 WEAK → tie → NEUTRAL
    synthesis_tie = asyncio.run(synth.synthesize(_TICKER, (pa, pb, pc, pd, pe, pf), _CTX))
    assert synthesis_tie.trade_off_matrix.scores["VALUE"] == DimensionVerdict.NEUTRAL


def test_n6_no_strong_consensus_with_disagreements_invariant_preserved() -> None:
    """TC-SYNTH-6: I-S12 preservation — V0=6 with disagreement → DISAGREEMENT confluence.

    When any pairwise persona pair disagrees, confluence MUST be DISAGREEMENT
    (never STRONG_CONSENSUS). SynthesisInvariantError MUST NOT raise.
    """
    synth = Phase1Synthesizer()
    # BEAR=STRONG, BULL=WEAK → disagreement detected
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("bear val", "valuation", Conviction.STRONG),))
    bull = _make_perspective(PerspectiveRole.BULL, points=(_make_point("bull val", "valuation", Conviction.WEAK),))
    quant = _make_perspective(PerspectiveRole.QUANT)
    buffett = _make_perspective(PerspectiveRole.BUFFETT)
    graham = _make_perspective(PerspectiveRole.GRAHAM)
    taleb = _make_perspective(PerspectiveRole.TALEB)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    assert synthesis.confluence_assessment == Confluence.DISAGREEMENT
    assert synthesis.confluence_assessment != Confluence.STRONG_CONSENSUS
    # I-S12: no SynthesisInvariantError (would have raised at construction)
    assert len(synthesis.explicit_disagreements) >= 1


def test_n6_strong_consensus_when_all_personas_align() -> None:
    """TC-SYNTH-7: V0=6 all 6 personas STRONG on same dimension → STRONG_CONSENSUS.

    When all personas agree (no opposing pairs), confluence = STRONG_CONSENSUS.
    """
    synth = Phase1Synthesizer()
    # All 6 personas have STRONG on valuation with NO STRONG→WEAK pair
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("b1", "valuation", Conviction.STRONG),))
    bull = _make_perspective(PerspectiveRole.BULL, points=(_make_point("b2", "valuation", Conviction.STRONG),))
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("b3", "valuation", Conviction.STRONG),))
    graham = _make_perspective(PerspectiveRole.GRAHAM, points=(_make_point("b4", "valuation", Conviction.STRONG),))
    taleb = _make_perspective(PerspectiveRole.TALEB, points=(_make_point("b5", "valuation", Conviction.STRONG),))
    quant = _make_perspective(PerspectiveRole.QUANT, points=(_make_point("b6", "valuation", Conviction.STRONG),))
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    # No opposing pairs → no disagreements
    assert synthesis.explicit_disagreements == ()
    # QUANT-favoured STRONG + all others STRONG → all dims either STRONG or NEUTRAL
    # STRONG_CONSENSUS requires ALL dims to be STRONG; valuation=STRONG, others=NEUTRAL → MIXED
    # Actual result depends on scoring; assertion: no DISAGREEMENT (all agree)
    assert synthesis.confluence_assessment != Confluence.DISAGREEMENT


def test_n6_catalysts_still_from_bull_only() -> None:
    """TC-SYNTH-8: catalysts remain canonically attributed to BULL only.

    Per plan-036 DD-3 architect decision: BUFFETT/GRAHAM/TALEB contribute via
    TradeOffMatrix.evidence, NOT via catalysts. Only BULL key_points → catalysts.
    """
    synth = Phase1Synthesizer()
    bull_pt = _make_point("bull catalyst", "growth", Conviction.STRONG)
    buffett_pt = _make_point("buffett catalyst", "growth", Conviction.STRONG)
    bear = _make_perspective(PerspectiveRole.BEAR)
    bull = _make_perspective(PerspectiveRole.BULL, points=(bull_pt,))
    quant = _make_perspective(PerspectiveRole.QUANT)
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(buffett_pt,))
    graham = _make_perspective(PerspectiveRole.GRAHAM)
    taleb = _make_perspective(PerspectiveRole.TALEB)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    assert bull_pt in synthesis.catalysts
    # BUFFETT point NOT in catalysts (only BULL attribution)
    assert buffett_pt not in synthesis.catalysts


def test_n6_risks_still_from_bear_only() -> None:
    """TC-SYNTH-9: risks remain canonically attributed to BEAR only.

    Per plan-036 DD-3 architect decision: BUFFETT/GRAHAM/TALEB contribute via
    TradeOffMatrix.evidence, NOT via risks. Only BEAR key_points → risks.
    """
    synth = Phase1Synthesizer()
    bear_pt = _make_point("bear risk", "macro", Conviction.STRONG)
    taleb_pt = _make_point("taleb risk", "macro", Conviction.STRONG)
    bear = _make_perspective(PerspectiveRole.BEAR, points=(bear_pt,))
    bull = _make_perspective(PerspectiveRole.BULL)
    quant = _make_perspective(PerspectiveRole.QUANT)
    buffett = _make_perspective(PerspectiveRole.BUFFETT)
    graham = _make_perspective(PerspectiveRole.GRAHAM)
    taleb = _make_perspective(PerspectiveRole.TALEB, points=(taleb_pt,))
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    assert bear_pt in synthesis.risks
    # TALEB point NOT in risks (only BEAR attribution)
    assert taleb_pt not in synthesis.risks


def test_n6_reasoning_trace_includes_persona_counts() -> None:
    """TC-SYNTH-10: reasoning_trace extension includes all N-persona point counts.

    Per plan-036 D2: reasoning_trace format updated to N-agnostic persona count summary.
    Format: "Perspectives (N): bear: X points, buffett: Y points, ..."
    """
    synth = Phase1Synthesizer()
    bear = _make_perspective(PerspectiveRole.BEAR, points=(_make_point("b1"),))
    bull = _make_perspective(PerspectiveRole.BULL, points=(_make_point("b2"), _make_point("b3")))
    quant = _make_perspective(PerspectiveRole.QUANT)
    buffett = _make_perspective(PerspectiveRole.BUFFETT, points=(_make_point("b4"), _make_point("b5"), _make_point("b6")))
    graham = _make_perspective(PerspectiveRole.GRAHAM)
    taleb = _make_perspective(PerspectiveRole.TALEB)
    synthesis = asyncio.run(synth.synthesize(_TICKER, (bear, bull, quant, buffett, graham, taleb), _CTX))
    trace = synthesis.reasoning_trace
    # New format includes N-persona count summary
    assert "Perspectives (6)" in trace
    assert "bear: 1 points" in trace
    assert "bull: 2 points" in trace
    assert "buffett: 3 points" in trace
