"""ValidateThesisPhase1UseCase — BC-8 Analysis orchestration use case.

Implements the Phase 1 thesis validation pipeline per spec 006 § B.3:
1. Gather Tier 1+2 context (deterministic; no LLM)
2. Run N perspective agents in parallel (asyncio.gather; F.3 plan-036 generalization)
3. Synthesize perspectives (preserves disagreement per I-S12)
4. Apply heuristic recommendation + confidence (BR-7; no LLM math)
5. Build Thesis aggregate (enforces bear-case invariant I-S10)
6. Persist and emit ThesisRecorded event

SharedContext is a plain dataclass (no Pydantic) with:
- has_critical_gaps(): returns True if any gap prevents analysis
- data_snapshot_md5: deterministic hash of all gathered data for AC-5 reproducibility

thesis_id computation: sha256(model_id + prompt_hash + ticker.symbol + as_of.isoformat() + data_md5)
This makes the ID deterministic per (model, prompt, ticker, date, data) tuple.

Cost enforcement: the entire execute() runs inside scoped_budget(limit_usd=Decimal("3.00")).
CostBudgetExceeded → thesis NOT persisted → Thesis.incomplete() returned.

Bear retry: agent-level retry-validator (ADR D-054 B5). BearPerspectiveAgent
internally handles up to 3 attempts with re-prompt on validation failure.
The use-case-level _retry_bear_if_needed (band-aid BR-1) has been REMOVED —
it was a partial workaround for content insufficiency only and was bypassed
entirely when bear raised a timeout exception (asyncio.gather propagation).
BearCaseInvariantError is now caught at Thesis construction (line 5) as before.

Source: specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md § B.3.
"""

from __future__ import annotations

import asyncio
import hashlib
import logging
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from decimal import Decimal
from typing import TYPE_CHECKING, Protocol, runtime_checkable

from packages.application.analysis.ports.cost_tracker_port import (
    Budget,
    CostBudgetExceeded,
    CostTrackerPort,
)
from packages.application.analysis.ports.llm_perspective_port import LLMPerspectivePort
from packages.application.analysis.services.recommendation_heuristic import (
    confidence_from_synthesis,
    recommendation_from_synthesis,
)
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.thesis import (
    BearCaseInvariantError,
    Thesis,
    ThesisStatus,
)

if TYPE_CHECKING:
    from packages.domain.analysis.models.synthesis import Synthesis
    from packages.domain.analysis.repositories.thesis_repository import ThesisRepository

__all__ = ["SharedContext", "ValidateThesisPhase1UseCase"]

log = logging.getLogger(__name__)


@runtime_checkable
class _Phase1Synthesizer(Protocol):
    """Local Protocol for Phase1Synthesizer to avoid circular imports."""

    async def synthesize(
        self,
        ticker: Ticker,
        perspectives: tuple[PerspectiveAnalysis, ...],
        context: SharedContext,
    ) -> Synthesis: ...


@runtime_checkable
class _EventBus(Protocol):
    """Minimal in-process event bus Protocol."""

    async def publish(self, event: object) -> None: ...


@dataclass
class SharedContext:
    """Tier 1+2 data bundle assembled by Phase1DataGatherer.

    All fields are point-in-time per (ticker, as_of). Gaps are recorded
    as a list of string labels; has_critical_gaps() returns True if any
    gap would prevent meaningful analysis.

    data_snapshot_md5: deterministic md5 of the entire payload for AC-5
    reproducibility — same input data → same thesis_id.
    """

    ticker: Ticker
    as_of: date
    quotes: list[object] = field(default_factory=list)
    statements: object = None
    ratios_ttm: dict[str, object] = field(default_factory=dict)
    peer_comparables: list[object] = field(default_factory=list)
    percentiles: dict[str, object] = field(default_factory=dict)
    recent_news: list[object] = field(default_factory=list)
    recent_claims: list[object] = field(default_factory=list)
    ta_features: dict[str, object] = field(default_factory=dict)
    ta_audit: dict[str, str] = field(default_factory=dict)
    gaps: list[str] = field(default_factory=list)
    data_snapshot_md5: str = ""

    def has_critical_gaps(self) -> bool:
        """True if gaps prevent any meaningful analysis.

        Critical gaps: no price data AND no fundamentals. News-only data
        can still yield a partial bear case; price+fundamentals are both
        required for SUBMITTED thesis.
        """
        critical = {"price_stale", "fundamentals_stale"}
        return critical.issubset(set(self.gaps))


def _compute_thesis_id(
    model_id: str,
    prompt_hash: str,
    ticker: Ticker,
    as_of: date,
    data_md5: str,
) -> str:
    """Deterministic sha256 thesis ID per AC-5 reproducibility contract.

    Same inputs → same ID → same content (given temperature=0 on all LLM calls).
    """
    raw = f"{model_id}:{prompt_hash}:{ticker.symbol}:{as_of.isoformat()}:{data_md5}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


class ValidateThesisPhase1UseCase:
    """Orchestrates Phase 1 thesis validation.

    Constructor takes all dependencies as Protocol-typed parameters so the
    use case has zero infrastructure knowledge.

    Bear retry is now handled agent-internally (ADR D-054 B5 — 3 attempts
    with re-prompt). The use-case-level bear_retry_count parameter has been
    removed; callers that passed bear_retry_count=N should drop that argument.

    F.3 (plan-036 D1): agents parameter generalised from 3 individual params to
    dict[PerspectiveRole, LLMPerspectivePort] to support N≥4 personas (V0=6 default).
    Per DD-1: role-keyed dict matches existing _ROLE_TO_MODEL pattern; allows N>3
    personas without ctor signature churn; backward-compat at composition root.
    """

    def __init__(
        self,
        data_gatherer: object,  # Phase1DataGatherer Protocol
        agents: dict[PerspectiveRole, LLMPerspectivePort],
        synthesizer: object,  # Phase1Synthesizer Protocol
        thesis_repo: ThesisRepository,
        cost_tracker: CostTrackerPort,
        event_bus: object,  # EventBus Protocol
    ) -> None:
        self._data_gatherer = data_gatherer
        self._agents = agents
        self._synthesizer = synthesizer
        self._thesis_repo = thesis_repo
        self._cost_tracker = cost_tracker
        self._event_bus = event_bus

    async def execute(
        self, ticker: Ticker, as_of: date | None = None
    ) -> Thesis:
        """Run the Phase 1 thesis validation pipeline.

        Returns a Thesis with status=SUBMITTED on success.
        Returns Thesis.incomplete() if:
        - context has critical gaps
        - bear agent fails to produce >=3 distinct points after agent-level retry
        - CostBudgetExceeded is raised
        """
        effective_as_of = as_of or date.today()

        try:
            with self._cost_tracker.scoped_budget(
                # BR-6 cap raised $3.00 → $6.00 (D-081, 2026-05-17).
                # Empirical: S395 6-persona V0=6 run cost $4.24 > $3.00.
                # $6.00 gives headroom above observed max per user Q1=A auth.
                limit_usd=Decimal("6.00")
            ) as budget:
                return await self._run_pipeline(
                    ticker, effective_as_of, budget
                )
        except CostBudgetExceeded as exc:
            log.warning(
                "Cost budget exceeded for %s as_of=%s: %s",
                ticker.symbol,
                effective_as_of,
                exc,
            )
            return Thesis.incomplete(
                ticker,
                effective_as_of,
                gaps=["cost_budget_exceeded"],
            )

    async def _run_pipeline(
        self, ticker: Ticker, as_of: date, budget: Budget
    ) -> Thesis:
        # Step 1 — gather Tier 1+2 context (deterministic; free)
        context: SharedContext = await self._data_gatherer.gather(ticker, as_of)  # type: ignore[attr-defined]

        if context.has_critical_gaps():
            return Thesis.incomplete(ticker, as_of, context.gaps)

        # Step 2 — run N perspectives in parallel (I-S12 disagreement preserved across N pairs)
        # Per plan-036 D1 + master plan-033 DD-3 ISOLATED-THEN-AGGREGATE (asyncio.gather;
        # no inter-agent messaging). Agent-level retry-validator handles up to 3 attempts
        # per agent (ADR D-054); asyncio.gather receives one coroutine per role.
        tasks = [
            agent.analyze(ticker, context, role)
            for role, agent in self._agents.items()
        ]
        results = await asyncio.gather(*tasks)

        # Accumulate costs across all N personas (per plan-036 DD-6 sum comprehension).
        # start=Decimal("0") required for type correctness (sum default 0 → int + Decimal = Decimal).
        perspectives: tuple[PerspectiveAnalysis, ...] = tuple(results)
        budget.add(sum((p.cost_usd for p in perspectives), Decimal("0")))

        # Step 3 — synthesize
        synthesis = await self._synthesizer.synthesize(ticker, perspectives, context)  # type: ignore[attr-defined]
        # Note: synthesizer is deterministic Python in Phase 2; no LLM cost.

        # Step 4 — heuristic recommendation + confidence
        rec = recommendation_from_synthesis(synthesis)
        conf = confidence_from_synthesis(synthesis)

        # Compute thesis_id for AC-5 reproducibility
        # STABLE-SORTED-BY-ROLE: sort by PerspectiveRole.value (alphabetic) for
        # deterministic combined_prompt regardless of asyncio.gather completion order
        # or dict insertion order (per plan-036 DD-2; defense-in-depth vs D-059 R2).
        # For N=3 (BEAR/BULL/QUANT): sorted = ("bear","bull","quant") = same as prior
        # implicit dispatch order → existing thesis_id values UNCHANGED (AQ-7 confirmed).
        sorted_perspectives = sorted(perspectives, key=lambda p: p.role.value)
        combined_prompt = ":".join(p.prompt_hash for p in sorted_perspectives)
        # Use first-sorted-role model_id for deterministic thesis_id input.
        # For V0=6: sorted-first role = "bear" → same as prior bear_p.model_id.
        model_id = sorted_perspectives[0].model_id if sorted_perspectives else "unknown"
        thesis_id = _compute_thesis_id(
            model_id,
            combined_prompt,
            ticker,
            as_of,
            context.data_snapshot_md5,
        )

        # Step 5 — build thesis (aggregate enforces I-S10 bear-case invariant)
        try:
            thesis = Thesis(
                thesis_id=thesis_id,
                ticker=ticker,
                as_of=as_of,
                created_at=datetime.now(UTC),
                status=ThesisStatus.SUBMITTED,
                perspectives=perspectives,
                synthesis=synthesis,
                final_recommendation=rec,
                confidence_level=conf,
                cost_usd=budget.spent,
            )
        except BearCaseInvariantError:
            log.warning(
                "Bear case invariant failed for %s after retry; returning incomplete.",
                ticker.symbol,
            )
            return Thesis.incomplete(ticker, as_of, ["bear_case_invariant_failed"])

        # Step 6 — persist
        await self._thesis_repo.save(thesis)

        # Step 7 — emit ThesisRecorded event (in-process; Phase 2 synchronous)
        try:
            from packages.contracts.events.thesis_recorded import ThesisRecorded

            event = ThesisRecorded(
                thesis_id=thesis.thesis_id,
                ticker=ticker,
                as_of=as_of,
                recommendation=str(rec),
                confidence_level=str(conf),
                cost_usd=thesis.cost_usd,
                recorded_at=datetime.now(UTC),
            )
            await self._event_bus.publish(event)  # type: ignore[attr-defined]
        except Exception as exc:
            log.warning("Event bus publish failed (non-fatal): %s", exc)

        return thesis
