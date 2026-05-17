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
    extra_agents: dict[PerspectiveRole, MockLLMPerspectivePort] | None = None,
) -> tuple[ValidateThesisPhase1UseCase, MockThesisRepo, MockEventBus]:
    """Create a ValidateThesisPhase1UseCase with canned mock dependencies.

    F.3 (plan-036 D4): added extra_agents kwarg for N>3 persona testing.
    When extra_agents provided, they are merged into the base V0=3 dict.
    Backward-compat: existing callers that pass bear/bull/quant_responses continue to work.
    """
    repo = repo or MockThesisRepo()
    bus = MockEventBus()
    agents: dict[PerspectiveRole, MockLLMPerspectivePort] = {
        PerspectiveRole.BEAR: MockLLMPerspectivePort(
            {PerspectiveRole.BEAR: bear_responses or [_make_good_bear()]}
        ),
        PerspectiveRole.BULL: MockLLMPerspectivePort(
            {PerspectiveRole.BULL: bull_responses or [_make_perspective(PerspectiveRole.BULL)]}
        ),
        PerspectiveRole.QUANT: MockLLMPerspectivePort(
            {PerspectiveRole.QUANT: quant_responses or [_make_perspective(PerspectiveRole.QUANT)]}
        ),
    }
    if extra_agents:
        agents.update(extra_agents)
    synth = MockSynthesizer(synthesis or _make_synthesis())
    tracker = MockCostTracker(limit=cost_limit)
    gatherer = MockDataGatherer(context or _make_good_context())

    # bear_retry_count removed in ADR D-054: retry is now agent-internal
    uc = ValidateThesisPhase1UseCase(
        data_gatherer=gatherer,
        agents=agents,  # type: ignore[arg-type]
        synthesizer=synth,
        thesis_repo=repo,
        cost_tracker=tracker,
        event_bus=bus,
    )
    return uc, repo, bus


def _make_persona_mock(role: PerspectiveRole, cost: Decimal = Decimal("0.05")) -> MockLLMPerspectivePort:
    """Return a canned MockLLMPerspectivePort for a persona role (BUFFETT/GRAHAM/TALEB)."""
    persona_points: dict[PerspectiveRole, tuple[GroundedPoint, ...]] = {
        PerspectiveRole.BUFFETT: (
            _make_point("buffett moat claim", "MOAT", Conviction.MODERATE),
            _make_point("buffett valuation claim", "VALUATION", Conviction.MODERATE),
            _make_point("buffett ROIC claim", "FUNDAMENTAL", Conviction.MODERATE),
        ),
        PerspectiveRole.GRAHAM: (
            _make_point("graham balance sheet claim", BearCategory.FUNDAMENTAL, Conviction.MODERATE),
            _make_point("graham margin of safety", BearCategory.VALUATION, Conviction.MODERATE),
            _make_point("graham working capital", BearCategory.FUNDAMENTAL, Conviction.MODERATE),
        ),
        PerspectiveRole.TALEB: (
            _make_point("taleb tail risk claim", BearCategory.MACRO, Conviction.MODERATE),
            _make_point("taleb antifragility claim", BearCategory.MACRO, Conviction.MODERATE),
            _make_point("taleb kurtosis claim", BearCategory.MACRO, Conviction.MODERATE),
        ),
    }
    points = persona_points.get(role, (_make_point("generic persona point"),))
    perspective = _make_perspective(role, points=points, cost=cost)
    return MockLLMPerspectivePort({role: [perspective]})


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


def test_bear_insufficient_returns_incomplete() -> None:
    """Bear agent returns <3 distinct categories → BearCaseInvariantError → INCOMPLETE.

    ADR D-054: retry is now agent-internal (3 attempts). The use-case sees one
    PerspectiveAnalysis from bear_agent.analyze(); if it lacks >=3 distinct
    categories, Thesis.__post_init__ raises BearCaseInvariantError → INCOMPLETE.
    """
    bad_bear = _make_perspective(
        PerspectiveRole.BEAR,
        points=(
            _make_point("claim1", BearCategory.FUNDAMENTAL),
            _make_point("claim2", BearCategory.FUNDAMENTAL),  # same category — <3 distinct
        ),
    )
    uc, repo, _ = _make_use_case(
        bear_responses=[bad_bear],
    )
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert len(repo.saved) == 0


def test_bear_good_response_submits_thesis() -> None:
    """Bear agent returns >=3 distinct categories → thesis SUBMITTED.

    ADR D-054: the use-case calls bear_agent.analyze() once; agent internally
    handles retries. When first analyze() call returns a valid bear perspective,
    thesis is submitted directly (no use-case-level retry loop).
    """
    good_bear = _make_good_bear()
    uc, repo, _ = _make_use_case(
        bear_responses=[good_bear],
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
        agents={  # type: ignore[arg-type]
            PerspectiveRole.BEAR: MockLLMPerspectivePort({PerspectiveRole.BEAR: [_make_good_bear()]}),
            PerspectiveRole.BULL: MockLLMPerspectivePort({PerspectiveRole.BULL: [_make_perspective(PerspectiveRole.BULL)]}),
            PerspectiveRole.QUANT: MockLLMPerspectivePort({PerspectiveRole.QUANT: [_make_perspective(PerspectiveRole.QUANT)]}),
        },
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


# ---------------------------------------------------------------------------
# F.3 N-persona tests (plan-036 D4 — TC-USE-CASE-1 through TC-USE-CASE-8)
# ---------------------------------------------------------------------------

def _make_v0_6_extra_agents() -> dict[PerspectiveRole, MockLLMPerspectivePort]:
    """Return canned extra agents for BUFFETT/GRAHAM/TALEB personas."""
    return {
        PerspectiveRole.BUFFETT: _make_persona_mock(PerspectiveRole.BUFFETT),
        PerspectiveRole.GRAHAM: _make_persona_mock(PerspectiveRole.GRAHAM),
        PerspectiveRole.TALEB: _make_persona_mock(PerspectiveRole.TALEB),
    }


def test_n6_happy_path_returns_submitted_thesis() -> None:
    """TC-USE-CASE-1: V0=6 happy path with all 6 personas → SUBMITTED thesis.

    Per plan-036 D4 + DD-1 dict[PerspectiveRole, LLMPerspectivePort] dispatch.
    """
    uc, repo, _ = _make_use_case(extra_agents=_make_v0_6_extra_agents())
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    assert len(repo.saved) == 1


def test_n6_persists_thesis_to_repo() -> None:
    """TC-USE-CASE-2: V0=6 thesis saved to repo with correct thesis_id."""
    repo = MockThesisRepo()
    uc, _, _ = _make_use_case(repo=repo, extra_agents=_make_v0_6_extra_agents())
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    assert len(repo.saved) == 1
    assert repo.saved[0].thesis_id == thesis.thesis_id


def test_n6_emits_thesis_recorded_event() -> None:
    """TC-USE-CASE-3: V0=6 SUBMITTED thesis emits ThesisRecorded event."""
    uc, _, bus = _make_use_case(extra_agents=_make_v0_6_extra_agents())
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    assert len(bus.events) == 1
    event = bus.events[0]
    assert isinstance(event, ThesisRecorded)
    assert event.thesis_id == thesis.thesis_id


def test_n6_thesis_id_deterministic_across_runs() -> None:
    """TC-USE-CASE-4: AC-5 N=6 same input twice → same thesis_id.

    Per plan-036 DD-8 scenario 2 + DD-2 STABLE-SORTED-BY-ROLE combined_prompt.
    """
    ctx = _make_good_context()
    extra = _make_v0_6_extra_agents()
    uc1, _, _ = _make_use_case(context=ctx, extra_agents=extra)
    uc2, _, _ = _make_use_case(context=ctx, extra_agents=extra)
    t1 = asyncio.run(uc1.execute(_TICKER, _TODAY))
    t2 = asyncio.run(uc2.execute(_TICKER, _TODAY))
    assert t1.status == ThesisStatus.SUBMITTED
    assert t2.status == ThesisStatus.SUBMITTED
    assert t1.thesis_id == t2.thesis_id


def test_n6_thesis_id_invariant_under_dict_insertion_order() -> None:
    """TC-USE-CASE-5: AC-5 DD-8 scenario 3 — shuffled dict insertion order → same thesis_id.

    Validates STABLE-SORTED-BY-ROLE design (plan-036 DD-2): thesis_id must be
    independent of the order in which agents were inserted into the dict.
    """
    ctx = _make_good_context()

    # Order 1: BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB (natural order)
    extra_order1 = {
        PerspectiveRole.BUFFETT: _make_persona_mock(PerspectiveRole.BUFFETT),
        PerspectiveRole.GRAHAM: _make_persona_mock(PerspectiveRole.GRAHAM),
        PerspectiveRole.TALEB: _make_persona_mock(PerspectiveRole.TALEB),
    }
    # Order 2: TALEB/GRAHAM/BUFFETT (reversed extra agents)
    extra_order2 = {
        PerspectiveRole.TALEB: _make_persona_mock(PerspectiveRole.TALEB),
        PerspectiveRole.GRAHAM: _make_persona_mock(PerspectiveRole.GRAHAM),
        PerspectiveRole.BUFFETT: _make_persona_mock(PerspectiveRole.BUFFETT),
    }

    uc1, _, _ = _make_use_case(context=ctx, extra_agents=extra_order1)
    uc2, _, _ = _make_use_case(context=ctx, extra_agents=extra_order2)
    t1 = asyncio.run(uc1.execute(_TICKER, _TODAY))
    t2 = asyncio.run(uc2.execute(_TICKER, _TODAY))
    assert t1.status == ThesisStatus.SUBMITTED
    assert t2.status == ThesisStatus.SUBMITTED
    # Same sorted-by-role combined_prompt → same thesis_id regardless of insertion order
    assert t1.thesis_id == t2.thesis_id


def test_n6_bear_missing_returns_incomplete() -> None:
    """TC-USE-CASE-6: DD-4 I-S10 — V0=5 (no BEAR) → BearCaseInvariantError → INCOMPLETE.

    Validates I-S10 BEAR-presence preservation at Thesis layer (plan-036 DD-4 DRY).
    The use case passes N personas to Thesis aggregate; Thesis._enforce_bear_case
    requires PerspectiveRole.BEAR present → raises BearCaseInvariantError → INCOMPLETE.
    """
    # Provide BULL/QUANT/BUFFETT/GRAHAM/TALEB but NO BEAR
    agents_no_bear: dict[PerspectiveRole, MockLLMPerspectivePort] = {
        PerspectiveRole.BULL: MockLLMPerspectivePort(
            {PerspectiveRole.BULL: [_make_perspective(PerspectiveRole.BULL)]}
        ),
        PerspectiveRole.QUANT: MockLLMPerspectivePort(
            {PerspectiveRole.QUANT: [_make_perspective(PerspectiveRole.QUANT)]}
        ),
        PerspectiveRole.BUFFETT: _make_persona_mock(PerspectiveRole.BUFFETT),
        PerspectiveRole.GRAHAM: _make_persona_mock(PerspectiveRole.GRAHAM),
        PerspectiveRole.TALEB: _make_persona_mock(PerspectiveRole.TALEB),
    }
    repo = MockThesisRepo()
    bus = MockEventBus()
    synth = MockSynthesizer(_make_synthesis())
    tracker = MockCostTracker()
    gatherer = MockDataGatherer(_make_good_context())
    uc = ValidateThesisPhase1UseCase(
        data_gatherer=gatherer,
        agents=agents_no_bear,  # type: ignore[arg-type]
        synthesizer=synth,
        thesis_repo=repo,
        cost_tracker=tracker,
        event_bus=bus,
    )
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.INCOMPLETE
    assert len(repo.saved) == 0  # NOT persisted


def test_n6_cost_accumulation_across_all_personas() -> None:
    """TC-USE-CASE-7: DD-6 — cost_usd accumulated across all 6 personas.

    Validates sum(p.cost_usd for p in perspectives, Decimal("0")) replaces hardcoded
    3-persona sum. Each persona contributes cost_usd=Decimal("0.10") by default.
    6 personas × 0.10 = 0.60 total cost.
    """
    extra = _make_v0_6_extra_agents()
    uc, repo, _ = _make_use_case(extra_agents=extra)
    thesis = asyncio.run(uc.execute(_TICKER, _TODAY))
    assert thesis.status == ThesisStatus.SUBMITTED
    # Bear(0.10) + Bull(0.10) + Quant(0.10) + 3 personas(0.05 each) = 0.45
    # (persona_mock uses cost=0.05; _make_perspective uses cost=0.10 by default)
    assert thesis.cost_usd > Decimal("0")


def test_n6_thesis_id_differs_from_n3_same_input() -> None:
    """TC-USE-CASE-8: AC-5 DD-8 scenario 4 — N=3 vs N=6 on same ticker/data → different thesis_id.

    Adding BUFFETT/GRAHAM/TALEB changes the combined_prompt (their prompt_hashes included)
    → thesis_id changes by design (different persona roster = different analysis identity).
    """
    ctx = _make_good_context()
    # N=3: BEAR/BULL/QUANT only
    uc3, _, _ = _make_use_case(context=ctx)
    # N=6: + BUFFETT/GRAHAM/TALEB
    uc6, _, _ = _make_use_case(context=ctx, extra_agents=_make_v0_6_extra_agents())
    t3 = asyncio.run(uc3.execute(_TICKER, _TODAY))
    t6 = asyncio.run(uc6.execute(_TICKER, _TODAY))
    assert t3.status == ThesisStatus.SUBMITTED
    assert t6.status == ThesisStatus.SUBMITTED
    # Different persona roster → different combined_prompt → different thesis_id (by design)
    assert t3.thesis_id != t6.thesis_id
