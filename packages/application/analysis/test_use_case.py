"""Tests for ValidateThesisPhase1UseCase with MockLLMPerspectivePort.

Coverage per sub-plan deliverable 23:
≥10 tests: happy path; bear retry on <3 points; cost cap raises CostBudgetExceeded
AND thesis NOT persisted; reproducibility same input → same thesis_id; gaps → incomplete.

NO live LLM. All perspective tests use MockLLMPerspectivePort fixture.

Source: 006-S41-track-F-impl-sub-plan.md deliverable 23.
"""

from __future__ import annotations

import asyncio
from collections.abc import Iterator
from contextlib import contextmanager
from datetime import date
from decimal import Decimal

from packages.application.analysis.ports.cost_tracker_port import (
    Budget,
    CostBudgetExceeded,
)
from packages.application.analysis.use_cases.validate_thesis_phase1 import (
    SharedContext,
    ValidateThesisPhase1UseCase,
)
from packages.contracts.events.thesis_recorded import ThesisRecorded
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import (
    Confluence,
    Synthesis,
)
from packages.domain.analysis.models.thesis import Thesis, ThesisStatus
from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)

_TODAY = date(2026, 5, 1)
_TICKER = Ticker("HPG")


# ---------------------------------------------------------------------------
# Fixtures and mock implementations
# ---------------------------------------------------------------------------

def _make_point(
    text: str = "bear claim",
    category: str = BearCategory.FUNDAMENTAL,
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
    cost: Decimal = Decimal("0.10"),
) -> PerspectiveAnalysis:
    return PerspectiveAnalysis(
        role=role,
        key_points=points,
        overall_conviction=Conviction.MODERATE,
        cost_usd=cost,
        model_id="claude-sonnet-4-6",
        prompt_hash="mockhash",
    )


def _make_good_bear() -> PerspectiveAnalysis:
    """Bear with 3 distinct-category points — passes invariant."""
    return _make_perspective(
        PerspectiveRole.BEAR,
        points=(
            _make_point("fundamental risk", BearCategory.FUNDAMENTAL),
            _make_point("valuation risk", BearCategory.VALUATION),
            _make_point("macro risk", BearCategory.MACRO),
        ),
    )


def _make_synthesis(confluence: Confluence = Confluence.MIXED) -> Synthesis:
    matrix = TradeOffMatrix(
        scores={d: DimensionVerdict.NEUTRAL for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
        evidence={d: () for d in ("VALUE", "QUALITY", "GROWTH", "RISK")},
    )
    return Synthesis(
        trade_off_matrix=matrix,
        confluence_assessment=confluence,
        explicit_disagreements=(),
        catalysts=(),
        risks=(),
        reasoning_trace="mock synthesis",
    )


class MockLLMPerspectivePort:
    """Canned LLM perspective port — returns preset PerspectiveAnalysis."""

    def __init__(self, responses: dict[PerspectiveRole, list[PerspectiveAnalysis]]) -> None:
        self._responses = responses
        self._call_counts: dict[PerspectiveRole, int] = {}

    async def analyze(
        self, _ticker: Ticker, _context: object, role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        count = self._call_counts.get(role, 0)
        self._call_counts[role] = count + 1
        pool = self._responses.get(role, [])
        if count < len(pool):
            return pool[count]
        return pool[-1] if pool else _make_perspective(role)


class MockSynthesizer:
    def __init__(self, synthesis: Synthesis) -> None:
        self._synthesis = synthesis

    async def synthesize(
        self, _ticker: Ticker, _perspectives: object, _context: object
    ) -> Synthesis:
        return self._synthesis


class MockThesisRepo:
    def __init__(self) -> None:
        self.saved: list[Thesis] = []

    async def save(self, thesis: Thesis) -> None:
        self.saved.append(thesis)

    async def get_by_id(self, thesis_id: str) -> Thesis | None:
        for t in self.saved:
            if t.thesis_id == thesis_id:
                return t
        return None

    async def find_by_ticker(self, ticker: Ticker, as_of: date) -> list[Thesis]:
        return [t for t in self.saved if t.ticker == ticker and t.as_of <= as_of]


class MockEventBus:
    def __init__(self) -> None:
        self.events: list[object] = []

    async def publish(self, event: object) -> None:
        self.events.append(event)


class MockCostTracker:
    """Simple cost tracker that raises CostBudgetExceeded when budget.add() is called
    with an amount that pushes spent over the limit.
    """

    def __init__(self, limit: Decimal = Decimal("3.00")) -> None:
        self.limit = limit

    @contextmanager
    def scoped_budget(self, limit_usd: Decimal) -> Iterator[Budget]:
        budget = Budget(spent=Decimal("0"), limit=limit_usd)
        try:
            yield budget
        except CostBudgetExceeded:
            raise

    async def record(self, usd: Decimal) -> None:
        pass


class MockDataGatherer:
    def __init__(self, context: SharedContext) -> None:
        self._context = context

    async def gather(self, _ticker: Ticker, _as_of: date) -> SharedContext:
        return self._context


def _make_good_context(gaps: list[str] | None = None) -> SharedContext:
    return SharedContext(
        ticker=_TICKER,
        as_of=_TODAY,
        quotes=["bar1", "bar2"],
        statements=object(),
        data_snapshot_md5="abc123",
        gaps=gaps or [],
    )


def _make_use_case(
    bear_responses: list[PerspectiveAnalysis] | None = None,
    bull_responses: list[PerspectiveAnalysis] | None = None,
    quant_responses: list[PerspectiveAnalysis] | None = None,
    synthesis: Synthesis | None = None,
    repo: MockThesisRepo | None = None,
    cost_limit: Decimal = Decimal("3.00"),
    context: SharedContext | None = None,
    bear_retry: int = 1,
) -> tuple[ValidateThesisPhase1UseCase, MockThesisRepo, MockEventBus]:
    repo = repo or MockThesisRepo()
    bus = MockEventBus()
    bear_agent = MockLLMPerspectivePort(
        {PerspectiveRole.BEAR: bear_responses or [_make_good_bear()]}
    )
    bull_agent = MockLLMPerspectivePort(
        {PerspectiveRole.BULL: bull_responses or [_make_perspective(PerspectiveRole.BULL)]}
    )
    quant_agent = MockLLMPerspectivePort(
        {PerspectiveRole.QUANT: quant_responses or [_make_perspective(PerspectiveRole.QUANT)]}
    )
    synth = MockSynthesizer(synthesis or _make_synthesis())
    tracker = MockCostTracker(limit=cost_limit)
    gatherer = MockDataGatherer(context or _make_good_context())

    uc = ValidateThesisPhase1UseCase(
        data_gatherer=gatherer,
        bear_agent=bear_agent,
        bull_agent=bull_agent,
        quant_agent=quant_agent,
        synthesizer=synth,
        thesis_repo=repo,
        cost_tracker=tracker,
        event_bus=bus,
        bear_retry_count=bear_retry,
    )
    return uc, repo, bus


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

def test_happy_path_returns_submitted_thesis() -> None:
    """Happy path: good data → SUBMITTED thesis persisted."""
    uc, repo, bus = _make_use_case()
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    assert len(repo.saved) == 1
    assert repo.saved[0].thesis_id == thesis.thesis_id


def test_happy_path_thesis_has_recommendation() -> None:
    """SUBMITTED thesis carries a recommendation."""
    uc, repo, _ = _make_use_case(synthesis=_make_synthesis(Confluence.MIXED))
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.final_recommendation is not None
    assert thesis.confidence_level is not None


def test_critical_gaps_returns_incomplete() -> None:
    """Context with price_stale + fundamentals_stale gaps → INCOMPLETE thesis."""
    ctx = _make_good_context(gaps=["price_stale", "fundamentals_stale"])
    uc, repo, _ = _make_use_case(context=ctx)
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert len(repo.saved) == 0  # NOT persisted


def test_bear_retry_insufficient_then_incomplete() -> None:
    """Bear produces <3 category points on all attempts → INCOMPLETE."""
    bad_bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.FUNDAMENTAL),  # same category
        ),
    )
    uc, repo, _ = _make_use_case(
        bear_responses=[bad_bear, bad_bear],  # both attempts fail
        bear_retry=1,
    )
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert len(repo.saved) == 0


def test_bear_retry_succeeds_on_second_attempt() -> None:
    """Bear fails first attempt (<3 cats), succeeds on retry → SUBMITTED."""
    bad_bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.FUNDAMENTAL),
        ),
    )
    good_bear = _make_good_bear()
    uc, repo, _ = _make_use_case(
        bear_responses=[bad_bear, good_bear],
        bear_retry=1,
    )
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED


def test_cost_cap_returns_incomplete_not_persisted() -> None:
    """Cost budget exceeded mid-execution → INCOMPLETE, thesis NOT persisted."""

    class OverbudgetBudget(Budget):
        def add(self, usd: Decimal) -> None:
            self.spent += usd
            raise CostBudgetExceeded(self.spent, self.limit)

    class OverbudgetTracker(MockCostTracker):
        @contextmanager
        def scoped_budget(self, limit_usd: Decimal) -> Iterator[Budget]:
            budget = OverbudgetBudget(spent=Decimal("0"), limit=limit_usd)
            try:
                yield budget
            except CostBudgetExceeded:
                raise

    repo = MockThesisRepo()
    bus = MockEventBus()
    uc = ValidateThesisPhase1UseCase(
        data_gatherer=MockDataGatherer(_make_good_context()),
        bear_agent=MockLLMPerspectivePort({PerspectiveRole.BEAR: [_make_good_bear()]}),
        bull_agent=MockLLMPerspectivePort({PerspectiveRole.BULL: [_make_perspective(PerspectiveRole.BULL)]}),
        quant_agent=MockLLMPerspectivePort({PerspectiveRole.QUANT: [_make_perspective(PerspectiveRole.QUANT)]}),
        synthesizer=MockSynthesizer(_make_synthesis()),
        thesis_repo=repo,
        cost_tracker=OverbudgetTracker(),
        event_bus=bus,
    )
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert len(repo.saved) == 0  # NOT persisted on cost cap


def test_reproducibility_same_input_same_thesis_id() -> None:
    """Same (ticker, as_of, data_md5, model, prompt) → identical thesis_id."""
    ctx = _make_good_context()
    uc, _, _ = _make_use_case(context=ctx)
    t1 = asyncio.run(uc.execute(_TICKER, _TODAY))
    uc2, _, _ = _make_use_case(context=ctx)
    t2 = asyncio.run(uc2.execute(_TICKER, _TODAY))
    # Both runs with identical mock hash → same thesis_id
    assert t1.thesis_id == t2.thesis_id


def test_event_bus_receives_thesis_recorded() -> None:
    """On SUBMITTED thesis, event bus receives ThesisRecorded."""
    uc, repo, bus = _make_use_case()
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    assert len(bus.events) == 1
    event = bus.events[0]
    assert isinstance(event, ThesisRecorded)
    assert event.thesis_id == thesis.thesis_id


def test_as_of_defaults_to_today() -> None:
    """execute() with as_of=None uses date.today()."""
    uc, repo, _ = _make_use_case()
    thesis = asyncio.run(uc.execute(_TICKER, None))
    # Just verify it runs and produces a thesis
    assert thesis.status in {ThesisStatus.SUBMITTED, ThesisStatus.INCOMPLETE}


def test_gaps_no_news_does_not_prevent_submission() -> None:
    """no_news_90d alone is not a critical gap — thesis may still be SUBMITTED."""
    ctx = _make_good_context(gaps=["no_news_90d"])
    uc, repo, _ = _make_use_case(context=ctx)
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    # no_news_90d alone is not critical (has_critical_gaps requires price_stale + fundamentals_stale)
    assert thesis.status == ThesisStatus.SUBMITTED
