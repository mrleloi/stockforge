"""Tests for BC-8 Analysis value objects.

Coverage per sub-plan deliverable 22:
≥10 tests: GroundedPoint validation [empty source_url raises / empty excerpt raises /
>500 chars raises / valid passes]; TradeOffMatrix scores membership;
4 StrEnum membership checks.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 21.
"""

from __future__ import annotations

from datetime import date

import pytest

from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import (
    GroundedPoint,
    GroundedPointInvariantError,
)
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DIMENSIONS,
    DimensionVerdict,
    TradeOffMatrix,
)

# --- GroundedPoint validation ---

_TODAY = date(2026, 5, 1)
def _make_valid_point() -> GroundedPoint:
    return GroundedPoint(
        text="HPG net debt rose per Q4 2025 filing",
        source_url="https://hsx.vn/filing/hpg-q4-2025.pdf",
        source_excerpt="Net debt increased to VND 52,000 billion as at 31 Dec 2025",
        as_of=_TODAY,
        conviction=Conviction.STRONG,
        category=BearCategory.FUNDAMENTAL,
    )


def test_grounded_point_valid_construction() -> None:
    point = _make_valid_point()
    assert point.source_url == "https://hsx.vn/filing/hpg-q4-2025.pdf"
    assert point.conviction == Conviction.STRONG


def test_grounded_point_empty_source_url_raises() -> None:
    with pytest.raises(GroundedPointInvariantError, match="source_url required"):
        GroundedPoint(
            text="some claim",
            source_url="",
            source_excerpt="some excerpt",
            as_of=_TODAY,
            conviction=Conviction.WEAK,
        )


def test_grounded_point_whitespace_source_url_raises() -> None:
    with pytest.raises(GroundedPointInvariantError, match="source_url required"):
        GroundedPoint(
            text="some claim",
            source_url="   ",
            source_excerpt="some excerpt",
            as_of=_TODAY,
            conviction=Conviction.WEAK,
        )


def test_grounded_point_empty_excerpt_raises() -> None:
    with pytest.raises(GroundedPointInvariantError, match="source_excerpt required"):
        GroundedPoint(
            text="some claim",
            source_url="https://example.com",
            source_excerpt="",
            as_of=_TODAY,
            conviction=Conviction.MODERATE,
        )


def test_grounded_point_excerpt_over_500_chars_raises() -> None:
    long_excerpt = "x" * 501
    with pytest.raises(GroundedPointInvariantError, match="exceeds 500 chars"):
        GroundedPoint(
            text="some claim",
            source_url="https://example.com",
            source_excerpt=long_excerpt,
            as_of=_TODAY,
            conviction=Conviction.WEAK,
        )


def test_grounded_point_exactly_500_chars_valid() -> None:
    excerpt = "x" * 500
    point = GroundedPoint(
        text="claim",
        source_url="https://example.com",
        source_excerpt=excerpt,
        as_of=_TODAY,
        conviction=Conviction.STRONG,
    )
    assert len(point.source_excerpt) == 500


def test_grounded_point_empty_text_raises() -> None:
    with pytest.raises(GroundedPointInvariantError, match="text required"):
        GroundedPoint(
            text="",
            source_url="https://example.com",
            source_excerpt="valid excerpt",
            as_of=_TODAY,
            conviction=Conviction.WEAK,
        )


def test_grounded_point_is_frozen() -> None:
    point = _make_valid_point()
    with pytest.raises((AttributeError, TypeError)):
        point.text = "mutated"  # type: ignore[misc]


# --- TradeOffMatrix ---

def test_trade_off_matrix_scores_membership() -> None:
    scores = {d: DimensionVerdict.NEUTRAL for d in DIMENSIONS}
    evidence = {d: () for d in DIMENSIONS}
    matrix = TradeOffMatrix(scores=scores, evidence=evidence)
    for dim in DIMENSIONS:
        assert dim in matrix.scores
        assert matrix.scores[dim] == DimensionVerdict.NEUTRAL


def test_trade_off_matrix_partial_is_allowed() -> None:
    """Matrix may have partial dimension coverage (data gaps)."""
    matrix = TradeOffMatrix(
        scores={"VALUE": DimensionVerdict.STRONG},
        evidence={"VALUE": ()},
    )
    assert "VALUE" in matrix.scores
    assert "GROWTH" not in matrix.scores


# --- StrEnum membership ---

def test_conviction_enum_values() -> None:
    assert set(Conviction) == {Conviction.STRONG, Conviction.MODERATE, Conviction.WEAK}


def test_recommendation_enum_values() -> None:
    assert Recommendation.THESIS_CANDIDATE.value == "thesis_candidate"
    assert Recommendation.INVESTIGATE.value == "investigate"
    assert Recommendation.WATCH.value == "watch"
    assert Recommendation.PASS.value == "pass"


def test_confidence_level_enum_values() -> None:
    assert ConfidenceLevel.HIGH.value == "high"
    assert ConfidenceLevel.MEDIUM.value == "medium"
    assert ConfidenceLevel.LOW.value == "low"


def test_bear_category_enum_values() -> None:
    expected = {"fundamental", "structural", "valuation", "competitive", "governance", "macro"}
    assert {c.value for c in BearCategory} == expected


def test_dimension_verdict_enum_values() -> None:
    assert DimensionVerdict.STRONG.value == "strong"
    assert DimensionVerdict.NEUTRAL.value == "neutral"
    assert DimensionVerdict.WEAK.value == "weak"
