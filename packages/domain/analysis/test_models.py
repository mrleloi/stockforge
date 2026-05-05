"""Tests for BC-8 Analysis models: Thesis, Synthesis, PerspectiveAnalysis.

Coverage per sub-plan deliverable 23:
≥15 tests: Thesis bear-case enforcement [<3 points raises BearCaseInvariantError /
3 points same category raises / 3 distinct categories passes /
3 distinct categories AND distinct points passes]; Synthesis disagreement invariant
raises if confluence=STRONG_CONSENSUS but explicit_disagreements non-empty;
PerspectiveAnalysis frozen; Thesis.incomplete() classmethod returns INCOMPLETE status.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 22.
"""

from __future__ import annotations

from datetime import UTC, date, datetime
from decimal import Decimal

import pytest

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import (
    Confluence,
    Disagreement,
    Synthesis,
    SynthesisInvariantError,
)
from packages.domain.analysis.models.thesis import (
    BearCaseInvariantError,
    Thesis,
    ThesisStatus,
)
from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)

_TODAY = date(2026, 5, 1)
_TICKER = Ticker("HPG")
_NOW = datetime(2026, 5, 1, 12, 0, 0, tzinfo=UTC)


def _make_point(
    text: str = "claim",
    category: str = BearCategory.FUNDAMENTAL,
    conviction: Conviction = Conviction.STRONG,
) -> GroundedPoint:
    return GroundedPoint(
        text=text,
        source_url="https://example.com/filing.pdf",
        source_excerpt="Verbatim excerpt from filing.",
        as_of=_TODAY,
        conviction=conviction,
        category=category,
    )


def _make_bear_perspective(points: tuple[GroundedPoint, ...]) -> PerspectiveAnalysis:
    return PerspectiveAnalysis(
        role=PerspectiveRole.BEAR,
        key_points=points,
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="claude-sonnet-4-6",
        prompt_hash="abc123",
    )


def _make_bull_perspective(points: tuple[GroundedPoint, ...] = ()) -> PerspectiveAnalysis:
    return PerspectiveAnalysis(
        role=PerspectiveRole.BULL,
        key_points=points,
        overall_conviction=Conviction.WEAK,
        cost_usd=Decimal("0.10"),
        model_id="claude-sonnet-4-6",
        prompt_hash="def456",
    )


def _make_synthesis(
    confluence: Confluence = Confluence.MIXED,
    disagreements: tuple[Disagreement, ...] = (),
) -> Synthesis:
    matrix = TradeOffMatrix(
        scores={"VALUE": DimensionVerdict.NEUTRAL},
        evidence={"VALUE": ()},
    )
    return Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=confluence,
        explicit_disagreements=disagreements,
        catalysts=(),
        risks=(),
        reasoning_trace="test synthesis",
    )


def _make_submitted_thesis(bear: PerspectiveAnalysis) -> Thesis:
    return Thesis(
        thesis_id="test-thesis-id",
        ticker=_TICKER,
        as_of=_TODAY,
        created_at=_NOW,
        status=ThesisStatus.SUBMITTED,
        perspectives=(bear, _make_bull_perspective()),
        synthesis=_make_synthesis(),
        final_recommendation=Recommendation.WATCH,
        confidence_level=ConfidenceLevel.MEDIUM,
        cost_usd=Decimal("0.20"),
    )


# --- Thesis bear-case enforcement ---

def test_thesis_submitted_fewer_than_3_points_raises() -> None:
    """<3 bear points → BearCaseInvariantError."""
    bear = _make_bear_perspective(
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.VALUATION),
        )
    )
    with pytest.raises(BearCaseInvariantError, match="3 distinct bear points"):
        _make_submitted_thesis(bear)


def test_thesis_submitted_zero_points_raises() -> None:
    """0 bear points → BearCaseInvariantError."""
    bear = _make_bear_perspective(points=())
    with pytest.raises(BearCaseInvariantError):
        _make_submitted_thesis(bear)


def test_thesis_submitted_3_points_same_category_raises() -> None:
    """3 bear points but only 1 distinct category → BearCaseInvariantError."""
    bear = _make_bear_perspective(
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.FUNDAMENTAL),
            _make_point("claim3", BearCategory.FUNDAMENTAL),
        )
    )
    with pytest.raises(BearCaseInvariantError, match="distinct categor"):
        _make_submitted_thesis(bear)


def test_thesis_submitted_3_points_2_categories_raises() -> None:
    """3 bear points with only 2 distinct categories → BearCaseInvariantError."""
    bear = _make_bear_perspective(
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.FUNDAMENTAL),
            _make_point("claim3", BearCategory.VALUATION),
        )
    )
    with pytest.raises(BearCaseInvariantError, match="distinct categor"):
        _make_submitted_thesis(bear)


def test_thesis_submitted_3_distinct_categories_passes() -> None:
    """3 bear points with 3 distinct categories → no exception."""
    bear = _make_bear_perspective(
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.VALUATION),
            _make_point("claim3", BearCategory.MACRO),
        )
    )
    thesis = _make_submitted_thesis(bear)
    assert thesis.status == ThesisStatus.SUBMITTED


def test_thesis_submitted_4_points_3_distinct_categories_passes() -> None:
    """4 bear points with 3 distinct categories → passes."""
    bear = _make_bear_perspective(
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.VALUATION),
            _make_point("claim3", BearCategory.MACRO),
            _make_point("claim4", BearCategory.COMPETITIVE),
        )
    )
    thesis = _make_submitted_thesis(bear)
    assert thesis.status == ThesisStatus.SUBMITTED


def test_thesis_no_bear_perspective_raises() -> None:
    """SUBMITTED thesis with no BEAR perspective → BearCaseInvariantError."""
    bull = _make_bull_perspective()
    with pytest.raises(BearCaseInvariantError, match="No BEAR perspective"):
        Thesis(
            thesis_id="x",
            ticker=_TICKER,
            as_of=_TODAY,
            created_at=_NOW,
            status=ThesisStatus.SUBMITTED,
            perspectives=(bull,),
            synthesis=_make_synthesis(),
            final_recommendation=Recommendation.WATCH,
            confidence_level=ConfidenceLevel.MEDIUM,
            cost_usd=Decimal("0.10"),
        )


def test_thesis_draft_status_no_bear_enforcement() -> None:
    """DRAFT status does not enforce bear-case invariant."""
    bear = _make_bear_perspective(points=())
    thesis = Thesis(
        thesis_id="draft-id",
        ticker=_TICKER,
        as_of=_TODAY,
        created_at=_NOW,
        status=ThesisStatus.DRAFT,
        perspectives=(bear,),
        synthesis=None,
        final_recommendation=None,
        confidence_level=None,
        cost_usd=Decimal("0"),
    )
    assert thesis.status == ThesisStatus.DRAFT


# --- Thesis.incomplete() classmethod ---

def test_thesis_incomplete_classmethod() -> None:
    """Thesis.incomplete() returns INCOMPLETE status with no synthesis."""
    thesis = Thesis.incomplete(_TICKER, _TODAY, gaps=["price_stale"])
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert thesis.synthesis is None
    assert thesis.final_recommendation is None
    assert thesis.confidence_level is None
    assert thesis.cost_usd == Decimal("0")
    assert "price_stale" in thesis.gaps


def test_thesis_incomplete_empty_gaps() -> None:
    """Thesis.incomplete() works with empty gaps list."""
    thesis = Thesis.incomplete(_TICKER, _TODAY, gaps=[])
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert thesis.gaps == ()


# --- Synthesis disagreement invariant ---

def test_synthesis_disagreements_with_strong_consensus_raises() -> None:
    """Synthesis with disagreements + STRONG_CONSENSUS → SynthesisInvariantError."""
    disagreement = Disagreement(
        dimension="VALUE",
        bear_verdict="strong",
        bull_verdict="weak",
    )
    matrix = TradeOffMatrix(scores={"VALUE": DimensionVerdict.NEUTRAL}, evidence={})
    with pytest.raises(SynthesisInvariantError):
        Synthesis(
            trade_off_matrix=matrix,
            confluence_assessment=Confluence.STRONG_CONSENSUS,
            explicit_disagreements=(disagreement,),
            catalysts=(),
            risks=(),
            reasoning_trace="test",
        )


def test_synthesis_disagreements_with_disagreement_confluence_passes() -> None:
    """Disagreements + confluence=DISAGREEMENT → valid Synthesis."""
    disagreement = Disagreement(
        dimension="VALUE",
        bear_verdict="strong",
        bull_verdict="weak",
    )
    matrix = TradeOffMatrix(scores={"VALUE": DimensionVerdict.NEUTRAL}, evidence={})
    synthesis = Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=Confluence.DISAGREEMENT,
        explicit_disagreements=(disagreement,),
        catalysts=(),
        risks=(),
        reasoning_trace="test",
    )
    assert synthesis.confluence_assessment == Confluence.DISAGREEMENT


def test_synthesis_no_disagreements_strong_consensus_passes() -> None:
    """No disagreements + STRONG_CONSENSUS → valid."""
    matrix = TradeOffMatrix(
        scores={"VALUE": DimensionVerdict.STRONG},
        evidence={"VALUE": ()},
    )
    synthesis = Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=Confluence.STRONG_CONSENSUS,
        explicit_disagreements=(),
        catalysts=(),
        risks=(),
        reasoning_trace="all agree",
    )
    assert synthesis.confluence_assessment == Confluence.STRONG_CONSENSUS


# --- PerspectiveAnalysis frozen ---

def test_perspective_analysis_is_frozen() -> None:
    perspective = PerspectiveAnalysis(
        role=PerspectiveRole.BEAR,
        key_points=(),
        overall_conviction=Conviction.WEAK,
        cost_usd=Decimal("0"),
        model_id="claude-sonnet-4-6",
        prompt_hash="abc",
    )
    with pytest.raises((AttributeError, TypeError)):
        perspective.model_id = "mutated"  # type: ignore[misc]
