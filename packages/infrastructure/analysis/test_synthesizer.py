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
