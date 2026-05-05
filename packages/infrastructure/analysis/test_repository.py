"""Tests for SqliteThesisRepository — SQLite roundtrip and query correctness.

Coverage per sub-plan deliverable 25:
≥5 tests: SQLite roundtrip; thesis_id PK uniqueness; payload_json fidelity for
nested perspectives + synthesis; find_by_ticker filter.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 25.
"""

from __future__ import annotations

import asyncio
from datetime import UTC, date, datetime
from decimal import Decimal
from pathlib import Path

import pytest

from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import Confluence, Synthesis
from packages.domain.analysis.models.thesis import Thesis, ThesisStatus
from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.confidence_level import ConfidenceLevel
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.recommendation import Recommendation
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)
from packages.infrastructure.analysis.sqlite_thesis_repository import (
    SqliteThesisRepository,
)

_TODAY = date(2026, 5, 1)
_TICKER = Ticker("HPG")
_NOW = datetime(2026, 5, 1, 12, 0, 0, tzinfo=UTC)


@pytest.fixture
def repo(tmp_path: Path) -> SqliteThesisRepository:
    return SqliteThesisRepository(db_path=tmp_path / "test_theses.sqlite")


def _make_point(category: str = BearCategory.FUNDAMENTAL) -> GroundedPoint:
    return GroundedPoint(
        text="Test bear claim",
        source_url="https://example.com/filing.pdf",
        source_excerpt="Verbatim excerpt.",
        as_of=_TODAY,
        conviction=Conviction.STRONG,
        category=category,
    )


def _make_synthesis() -> Synthesis:
    matrix = TradeOffMatrix(
        scores={d: DimensionVerdict.NEUTRAL for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
        evidence={d: () for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
    )
    return Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=Confluence.MIXED,
        explicit_disagreements=(),
        catalysts=(),
        risks=(),
        reasoning_trace="test synthesis",
    )


def _make_thesis(
    thesis_id: str = "thesis-001",
    ticker: Ticker = _TICKER,
    as_of: date = _TODAY,
    status: ThesisStatus = ThesisStatus.SUBMITTED,
) -> Thesis:
    bear = PerspectiveAnalysis(
        role=PerspectiveRole.BEAR,
        key_points=(
            _make_point(BearCategory.FUNDAMENTAL),
            _make_point(BearCategory.VALUATION),
            _make_point(BearCategory.MACRO),
        ),
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="claude-sonnet-4-6",
        prompt_hash="abc123",
    )
    if status == ThesisStatus.INCOMPLETE:
        return Thesis(
            thesis_id=thesis_id,
            ticker=ticker,
            as_of=as_of,
            created_at=_NOW,
            status=ThesisStatus.INCOMPLETE,
            perspectives=(),
            synthesis=None,
            final_recommendation=None,
            confidence_level=None,
            cost_usd=Decimal("0"),
            gaps=("price_stale",),
        )
    return Thesis(
        thesis_id=thesis_id,
        ticker=ticker,
        as_of=as_of,
        created_at=_NOW,
        status=ThesisStatus.SUBMITTED,
        perspectives=(bear,),
        synthesis=_make_synthesis(),
        final_recommendation=Recommendation.WATCH,
        confidence_level=ConfidenceLevel.MEDIUM,
        cost_usd=Decimal("0.10"),
    )


def test_sqlite_roundtrip_basic(repo: SqliteThesisRepository) -> None:
    """Save a thesis and retrieve it by ID."""
    thesis = _make_thesis("rt-001")
    asyncio.run(repo.save(thesis))
    retrieved = asyncio.run(repo.get_by_id("rt-001"))
    assert retrieved is not None
    assert retrieved.thesis_id == "rt-001"
    assert retrieved.ticker.symbol == "HPG"
    assert retrieved.status == ThesisStatus.SUBMITTED


def test_sqlite_roundtrip_recommendation_preserved(repo: SqliteThesisRepository) -> None:
    """Recommendation and confidence_level round-trip correctly."""
    thesis = _make_thesis("rt-002")
    asyncio.run(repo.save(thesis))
    retrieved = asyncio.run(repo.get_by_id("rt-002"))
    assert retrieved is not None
    assert retrieved.final_recommendation == Recommendation.WATCH
    assert retrieved.confidence_level == ConfidenceLevel.MEDIUM


def test_thesis_id_pk_uniqueness_upsert(repo: SqliteThesisRepository) -> None:
    """Saving same thesis_id twice is idempotent (INSERT OR REPLACE)."""
    thesis1 = _make_thesis("pk-001")
    thesis2 = _make_thesis("pk-001")  # same ID, same data
    asyncio.run(repo.save(thesis1))
    asyncio.run(repo.save(thesis2))  # should not raise
    all_found = asyncio.run(repo.find_by_ticker(_TICKER, _TODAY))
    ids = [t.thesis_id for t in all_found]
    assert ids.count("pk-001") == 1


def test_payload_json_fidelity_perspectives(repo: SqliteThesisRepository) -> None:
    """PerspectiveAnalysis key_points survive JSON roundtrip."""
    thesis = _make_thesis("pj-001")
    asyncio.run(repo.save(thesis))
    retrieved = asyncio.run(repo.get_by_id("pj-001"))
    assert retrieved is not None
    bear = next(p for p in retrieved.perspectives if p.role == PerspectiveRole.BEAR)
    assert len(bear.key_points) == 3
    # Verify one point's source_url survived
    assert bear.key_points[0].source_url == "https://example.com/filing.pdf"


def test_find_by_ticker_filter(repo: SqliteThesisRepository) -> None:
    """find_by_ticker filters by ticker and as_of correctly."""
    t_hpg = _make_thesis("hpg-001", ticker=Ticker("HPG"), as_of=date(2026, 4, 1))
    t_fpt = _make_thesis("fpt-001", ticker=Ticker("FPT"), as_of=date(2026, 4, 1))
    t_hpg2 = _make_thesis("hpg-002", ticker=Ticker("HPG"), as_of=date(2026, 5, 1))
    for t in (t_hpg, t_fpt, t_hpg2):
        asyncio.run(repo.save(t))

    # Find HPG theses at or before 2026-05-01
    hpg_results = asyncio.run(repo.find_by_ticker(Ticker("HPG"), date(2026, 5, 1)))
    assert all(r.ticker.symbol == "HPG" for r in hpg_results)
    assert len(hpg_results) == 2

    # Find FPT theses
    fpt_results = asyncio.run(repo.find_by_ticker(Ticker("FPT"), date(2026, 5, 1)))
    assert len(fpt_results) == 1
    assert fpt_results[0].thesis_id == "fpt-001"


def test_get_by_id_returns_none_for_missing(repo: SqliteThesisRepository) -> None:
    """get_by_id returns None when thesis_id is not found."""
    result = asyncio.run(repo.get_by_id("nonexistent-id"))
    assert result is None


def test_incomplete_thesis_roundtrip(repo: SqliteThesisRepository) -> None:
    """INCOMPLETE thesis (no synthesis) survives roundtrip."""
    thesis = _make_thesis("inc-001", status=ThesisStatus.INCOMPLETE)
    asyncio.run(repo.save(thesis))
    retrieved = asyncio.run(repo.get_by_id("inc-001"))
    assert retrieved is not None
    assert retrieved.status == ThesisStatus.INCOMPLETE
    assert retrieved.synthesis is None
    assert retrieved.final_recommendation is None
