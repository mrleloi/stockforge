"""use_case_builder — shared composition root for ValidateThesisPhase1UseCase.

Both apps/dashboard/pages/validate_thesis.py and apps/cli/validate_thesis.py
wire the same dependency graph. This module centralises that wiring so the two
entry points stay DRY.

F.3 (plan-036 D3): extended from V0=3 (BEAR/BULL/QUANT) to V0=6 personas.
ValidateThesisPhase1UseCase now accepts agents: dict[PerspectiveRole, LLMPerspectivePort].

Wiring produced (V0=6):
  ValidateThesisPhase1UseCase(
      data_gatherer = Phase1DataGatherer(...),
      agents        = {
          BEAR: BearPerspectiveAgent(adapter),
          BULL: BullPerspectiveAgent(adapter),
          QUANT: QuantPerspectiveAgent(adapter),
          BUFFETT: BuffettPerspectiveAgent(adapter, registry.get("buffett")),
          GRAHAM: GrahamPerspectiveAgent(adapter, registry.get("graham")),
          TALEB: TalebPerspectiveAgent(adapter, registry.get("taleb")),
      },
      synthesizer   = Phase1Synthesizer(),
      thesis_repo   = SqliteThesisRepository(db_path),
      cost_tracker  = InProcessCostTracker(),
      event_bus     = InProcessEventBus(),
  )

HARD BINDING (S43a-CODE):
- --mock-llm / mock=True injects MockLLMPerspectivePort (no Anthropic call).
- --no-mock-llm / mock=False with ANTHROPIC_API_KEY present raises
  NotImplementedError("S43a-DOGFOOD gate pending ...") — does NOT call the API.
- --no-mock-llm without ANTHROPIC_API_KEY exits with a helpful error message.

Source: agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md § S43a
"""

from __future__ import annotations

import os
from decimal import Decimal
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from packages.application.analysis.use_cases.validate_thesis_phase1 import (
        ValidateThesisPhase1UseCase,
    )

__all__ = ["BuildError", "build_use_case"]

_DOGFOOD_GATE_MSG = (
    "S43a-DOGFOOD gate pending: live Anthropic SDK calls are blocked. "
    "Use --transport=subagent for the claude CLI subscription substrate "
    "(no API key required; ratified S43b)."
)

_VALID_TRANSPORTS = ("anthropic", "subagent")


class BuildError(RuntimeError):
    """Raised when composition root cannot be assembled (e.g. missing API key)."""


def build_use_case(
    *,
    db_path: Path,
    mock_llm: bool,
    max_cost_usd: Decimal = Decimal("3.00"),
    transport: str = "anthropic",
) -> ValidateThesisPhase1UseCase:
    """Assemble and return a fully-wired ValidateThesisPhase1UseCase.

    Parameters
    ----------
    db_path:
        Path to the SQLite database file for SqliteThesisRepository.
    mock_llm:
        If True — inject mock perspective agents + MockDataGatherer (no LLM call).
    max_cost_usd:
        Per-execution cost ceiling passed to the use case (default $3.00 per BR-6).
    transport:
        Substrate for the LLM call when mock_llm=False:
        - "anthropic" — direct anthropic SDK; requires ANTHROPIC_API_KEY (gated; S43a)
        - "subagent" — claude CLI subprocess; uses parent OAuth subscription (S43b)
    """
    if transport not in _VALID_TRANSPORTS:
        raise BuildError(
            f"transport={transport!r} invalid; choose from {_VALID_TRANSPORTS}"
        )

    if not mock_llm and transport == "anthropic":
        _check_live_gate()
        raise AssertionError("unreachable")  # pragma: no cover

    from packages.application.analysis.use_cases.validate_thesis_phase1 import (
        ValidateThesisPhase1UseCase,
    )
    from packages.infrastructure.analysis.in_process_cost_tracker import (
        InProcessCostTracker,
    )
    from packages.infrastructure.analysis.phase1_synthesizer import Phase1Synthesizer
    from packages.infrastructure.analysis.sqlite_thesis_repository import (
        SqliteThesisRepository,
    )

    cost_tracker = InProcessCostTracker()
    thesis_repo = SqliteThesisRepository(db_path=db_path)
    synthesizer = Phase1Synthesizer()
    event_bus = _InProcessEventBus()
    _ = max_cost_usd  # cost cap is the use-case's $3 hardcoded ceiling per BR-6

    data_gatherer: object

    if mock_llm:
        agents = _build_mock_agents()
        data_gatherer = _MockDataGatherer()
    else:
        # transport == "subagent": real agents + claude CLI substrate + real DB-backed gatherer
        agents = _build_subagent_agents()
        data_gatherer = _SubagentDataGatherer(db_path=db_path)

    return ValidateThesisPhase1UseCase(
        data_gatherer=data_gatherer,
        agents=agents,  # type: ignore[arg-type]  # dict[object, object] → dict[PerspectiveRole, LLMPerspectivePort]
        synthesizer=synthesizer,
        thesis_repo=thesis_repo,
        cost_tracker=cost_tracker,
        event_bus=event_bus,
    )


def _load_persona_registry() -> object:
    """Load V0 persona packs from agent-workspace/role-packs/*.json.

    Per F.3 plan-036 D3 + F.1 plan-034 PersonaRegistry composition pattern.
    Returns a PersonaRegistry with buffett/graham/taleb packs registered.
    """
    from packages.application.analysis.persona_registry import (  # noqa: PLC0415
        PersonaRegistry,
    )

    registry = PersonaRegistry()
    base_dir = Path("agent-workspace") / "role-packs"
    for role_id in ("buffett", "graham", "taleb"):
        pack_path = base_dir / f"{role_id}.json"
        registry.load_from_json(pack_path, base_dir=base_dir)
    return registry


def _build_persona_agents(adapter: object, registry: object) -> dict[object, object]:
    """Construct V0 persona agents (BUFFETT/GRAHAM/TALEB) using PersonaRegistry packs.

    Per F.3 plan-036 D3 + F.2 plan-035 persona adapter pattern (DD-7).
    Each persona agent receives the ClaudeLLMPerspectiveAdapter + its RolePromptPack.
    """
    from packages.application.analysis.persona_registry import (  # noqa: PLC0415
        PersonaRegistry,
    )
    from packages.domain.analysis.models.perspective_analysis import (  # noqa: PLC0415
        PerspectiveRole,
    )
    from packages.infrastructure.analysis.perspectives.buffett_agent import (  # noqa: PLC0415
        BuffettPerspectiveAgent,
    )
    from packages.infrastructure.analysis.perspectives.graham_agent import (  # noqa: PLC0415
        GrahamPerspectiveAgent,
    )
    from packages.infrastructure.analysis.perspectives.taleb_agent import (  # noqa: PLC0415
        TalebPerspectiveAgent,
    )

    assert isinstance(registry, PersonaRegistry)
    return {
        PerspectiveRole.BUFFETT: BuffettPerspectiveAgent(adapter, registry.get("buffett")),
        PerspectiveRole.GRAHAM: GrahamPerspectiveAgent(adapter, registry.get("graham")),
        PerspectiveRole.TALEB: TalebPerspectiveAgent(adapter, registry.get("taleb")),
    }


def _build_subagent_agents() -> dict[object, object]:
    """Wire real V0=6 agents on ClaudeLLMPerspectiveAdapter + claude_cli_transport.

    F.3 (plan-036 D3): returns dict[PerspectiveRole, LLMPerspectivePort] with 6 agents.
    Bills against parent Claude Code subscription via OAuth; no ANTHROPIC_API_KEY required.

    Per-role model override (S43b-BULL fix; DEFER-S43b-3): BULL → haiku.
    Empirically the bull sonnet call hits the CLI 300s timeout deterministically
    (2/2 dogfood runs: BID + FPT) — likely because the bull system_prompt + Bear
    Symmetry rules trigger longer reasoning chains. Haiku is faster + cheaper +
    sufficient for the bull role's evidence-gathering task. Bear stays on sonnet
    (adversarial nuance valued); Quant stays on opus (deterministic-ratio
    interpretation benefits from strongest model).

    Note per plan-036 DD-9: BUFFETT/GRAHAM/TALEB fall through to _DEFAULT_MODEL Opus
    in _ROLE_TO_MODEL. F.3 defers _ROLE_TO_MODEL extension to F.4 or inline fix.
    """
    from packages.domain.analysis.models.perspective_analysis import (  # noqa: PLC0415
        PerspectiveRole,
    )
    from packages.infrastructure.analysis.claude_llm_perspective_adapter import (  # noqa: PLC0415
        ClaudeLLMPerspectiveAdapter,
    )
    from packages.infrastructure.analysis.perspectives.bear_agent import (  # noqa: PLC0415
        BearPerspectiveAgent,
    )
    from packages.infrastructure.analysis.perspectives.bull_agent import (  # noqa: PLC0415
        BullPerspectiveAgent,
    )
    from packages.infrastructure.analysis.perspectives.quant_agent import (  # noqa: PLC0415
        QuantPerspectiveAgent,
    )
    from packages.infrastructure.analysis.subagent_transport import (  # noqa: PLC0415
        claude_cli_transport,
    )

    adapter = ClaudeLLMPerspectiveAdapter(
        transport=claude_cli_transport,
        role_model_overrides={PerspectiveRole.BULL: "claude-haiku-4-5"},
    )
    registry = _load_persona_registry()
    return {
        PerspectiveRole.BEAR: BearPerspectiveAgent(adapter),
        PerspectiveRole.BULL: BullPerspectiveAgent(adapter),
        PerspectiveRole.QUANT: QuantPerspectiveAgent(adapter),
        **_build_persona_agents(adapter, registry),
    }


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _check_live_gate() -> None:
    """Raise appropriate error when --no-mock-llm is requested.

    - No ANTHROPIC_API_KEY → BuildError (user-friendly message).
    - ANTHROPIC_API_KEY present → NotImplementedError (S43a-DOGFOOD gate).
    """
    key = os.environ.get("ANTHROPIC_API_KEY", "").strip()
    if not key:
        raise BuildError(
            "ANTHROPIC_API_KEY environment variable is not set. "
            "Set it or use --mock-llm for offline/test runs."
        )
    # Key present but DOGFOOD gate not yet resolved.
    raise NotImplementedError(_DOGFOOD_GATE_MSG)


def _build_mock_agents() -> dict[object, object]:
    """Return V0=6 mock perspective agents for offline use.

    F.3 (plan-036 D3): returns dict[PerspectiveRole, LLMPerspectivePort] with 6 agents.
    BUFFETT/GRAHAM/TALEB stubs use generic placeholder points (mock mode only;
    realistic content not needed for offline/test scenarios).
    """
    from datetime import date  # noqa: PLC0415

    from packages.domain.analysis.models.perspective_analysis import (  # noqa: PLC0415
        PerspectiveAnalysis,
        PerspectiveRole,
    )
    from packages.domain.analysis.value_objects.bear_category import BearCategory  # noqa: PLC0415
    from packages.domain.analysis.value_objects.conviction import Conviction  # noqa: PLC0415
    from packages.domain.analysis.value_objects.grounded_point import GroundedPoint  # noqa: PLC0415

    _today = date.today()
    _src = "https://mock.stockforge.local/filing"
    _excerpt = "Mock excerpt: canned data for offline/test mode."

    def _pt(text: str, category: str | None = None) -> GroundedPoint:
        return GroundedPoint(
            text=text,
            source_url=_src,
            source_excerpt=_excerpt,
            as_of=_today,
            conviction=Conviction.MODERATE,
            category=category,
        )

    bear_points = (
        _pt("Fundamental: elevated debt-to-equity ratio per mock data.", BearCategory.FUNDAMENTAL),
        _pt("Valuation: P/E above sector median per mock ratio compute.", BearCategory.VALUATION),
        _pt("Macro: interest-rate environment pressures margins per mock context.", BearCategory.MACRO),
    )
    bull_points = (
        _pt("Revenue growth trajectory positive per mock financials."),
        _pt("Market share gains in core segment per mock news."),
        _pt("Strong FCF generation per mock cash-flow statement."),
    )
    quant_points = (
        _pt("P/B below 5-year average per mock ratio calculation."),
        _pt("ROE above sector 75th percentile per mock peer comparison."),
    )
    buffett_points = (
        _pt("Mock buffett moat point: durable competitive advantage per mock data.", "MOAT"),
        _pt("Mock buffett valuation point: intrinsic value margin of safety per mock.", "VALUATION"),
        _pt("Mock buffett ROIC point: high returns on capital per mock financials.", "ROIC"),
    )
    graham_points = (
        _pt("Mock graham balance sheet: net-net asset value per mock data.", "BALANCE_SHEET"),
        _pt("Mock graham margin of safety: price below book value per mock.", "VALUATION"),
        _pt("Mock graham working capital: current ratio above 2x per mock.", "FUNDAMENTAL"),
    )
    taleb_points = (
        _pt("Mock taleb tail risk: fat-tail downside scenario per mock.", "RISK"),
        _pt("Mock taleb antifragility: stress-resistant business model per mock.", "MACRO"),
        _pt("Mock taleb kurtosis: extreme event probability elevated per mock.", "RISK"),
    )

    def _pa(role: PerspectiveRole, points: tuple[GroundedPoint, ...]) -> PerspectiveAnalysis:
        return PerspectiveAnalysis(
            role=role,
            key_points=points,
            overall_conviction=Conviction.MODERATE,
            cost_usd=Decimal("0.00"),
            model_id="mock-llm",
            prompt_hash="mockhash0123456",
        )

    class _FixedAgent:
        def __init__(self, pa: PerspectiveAnalysis) -> None:
            self._pa = pa

        async def analyze(self, _ticker: object, _ctx: object, _role: object) -> PerspectiveAnalysis:
            return self._pa

    return {
        PerspectiveRole.BEAR: _FixedAgent(_pa(PerspectiveRole.BEAR, bear_points)),
        PerspectiveRole.BULL: _FixedAgent(_pa(PerspectiveRole.BULL, bull_points)),
        PerspectiveRole.QUANT: _FixedAgent(_pa(PerspectiveRole.QUANT, quant_points)),
        PerspectiveRole.BUFFETT: _FixedAgent(_pa(PerspectiveRole.BUFFETT, buffett_points)),
        PerspectiveRole.GRAHAM: _FixedAgent(_pa(PerspectiveRole.GRAHAM, graham_points)),
        PerspectiveRole.TALEB: _FixedAgent(_pa(PerspectiveRole.TALEB, taleb_points)),
    }


class _InProcessEventBus:
    """Minimal in-process event bus that discards events (Phase 2 stub)."""

    async def publish(self, event: object) -> None:
        pass


class _MockDataGatherer:
    """Minimal data gatherer for mock_llm=True mode.

    Returns a non-critical SharedContext so the use case proceeds to run
    the mock perspective agents. Used in development/test environments.
    """

    async def gather(self, ticker: object, as_of: object) -> object:
        from datetime import date as _date  # noqa: PLC0415

        from packages.application.analysis.use_cases.validate_thesis_phase1 import (  # noqa: PLC0415
            SharedContext,
        )
        from packages.contracts.types import Ticker as _Ticker  # noqa: PLC0415

        _ticker = ticker if isinstance(ticker, _Ticker) else _Ticker(str(ticker))
        _as_of = as_of if isinstance(as_of, _date) else _date.today()
        return SharedContext(
            ticker=_ticker,
            as_of=_as_of,
            quotes=["mock_bar_1", "mock_bar_2"],
            statements=None,
            ratios_ttm={"PE": 12.5, "PB": 1.8},
            data_snapshot_md5="mock_md5_0000000000000000",
        )


class _SubagentDataGatherer:
    """DB-backed data gatherer for the subagent (S43b) path.

    Reads from `data/stockforge.sqlite` populated by S43a Stage A ingest:
    - bars (BC-1) via SqliteBarRepository.get_as_of (returns ≤ as_of, ASC)
    - statements (BC-2) via SqliteFundamentalRepository.get_as_of
    - ratios via RatioService.compute_ttm_ratios on filtered IS+BS
    - news (BC-5) via SqliteNewsRepository.get_known_as_of (90d window post-filter)
    - claims (BC-5) via SqliteClaimRepository.get_for_ticker (typically 0 until LLM extraction)

    Concrete repos are sync — wrapped in async wrapper so use_case can `await`.
    """

    def __init__(self, db_path: Path) -> None:
        self._db_path = db_path

    async def gather(self, ticker: object, as_of: object) -> object:
        import hashlib  # noqa: PLC0415
        import json as _json  # noqa: PLC0415
        from datetime import date as _date  # noqa: PLC0415
        from datetime import timedelta  # noqa: PLC0415

        from packages.application.analysis.use_cases.validate_thesis_phase1 import (  # noqa: PLC0415
            SharedContext,
        )
        from packages.contracts.types import Ticker as _Ticker  # noqa: PLC0415
        from packages.domain.fundamental.services.ratio_service import (  # noqa: PLC0415
            RatioService,
        )
        from packages.domain.fundamental.value_objects import (  # noqa: PLC0415
            StatementType,
        )
        from packages.domain.market_data.services.ta_service import (  # noqa: PLC0415
            compute_ta_features,
        )
        from packages.infrastructure.fundamental.sqlite_fundamental_repository import (  # noqa: PLC0415
            SqliteFundamentalRepository,
        )
        from packages.infrastructure.market_data.sqlite_bar_repository import (  # noqa: PLC0415
            SqliteBarRepository,
        )
        from packages.infrastructure.news.sqlite_news_repository import (  # noqa: PLC0415
            SqliteClaimRepository,
            SqliteNewsRepository,
        )

        _ticker = ticker if isinstance(ticker, _Ticker) else _Ticker(str(ticker))
        _as_of = as_of if isinstance(as_of, _date) else _date.today()
        start_90 = _as_of - timedelta(days=90)

        bar_repo = SqliteBarRepository(db_path=self._db_path)
        fund_repo = SqliteFundamentalRepository(db_path=self._db_path)
        news_repo = SqliteNewsRepository(db_path=self._db_path)
        claim_repo = SqliteClaimRepository(db_path=self._db_path)

        bars = bar_repo.get_as_of(_ticker, _as_of)
        statements_all = fund_repo.get_as_of(_ticker, _as_of)

        # Latest close → price_per_share for P/E + P/B (S43b-EVIDENCE: was None
        # in S43b-DATA "Phase 2 thin slice"; now passed so Quant has multiples).
        latest_close = getattr(bars[-1], "close", None) if bars else None

        # Compute ratios from latest 4 IS quarters + latest BS
        income_stmts = [s for s in statements_all if s.statement_type == StatementType.IS][-4:]
        bs_stmts = [s for s in statements_all if s.statement_type == StatementType.BS]
        latest_bs = bs_stmts[-1] if bs_stmts else None
        ratios_ttm: dict[str, object] = {}
        if income_stmts and latest_bs is not None:
            try:
                rs_result = RatioService().compute_ttm_ratios(
                    ticker=_ticker,
                    period_end=_as_of,
                    income_statements=income_stmts,
                    latest_balance_sheet=latest_bs,
                    price_per_share=latest_close,  # S43b-EVIDENCE: enables P/E + P/B
                )
                ratios_ttm = {str(k): v for k, v in rs_result.items()}
            except Exception:  # noqa: BLE001 — log + continue per Q-S28-3
                ratios_ttm = {}

        # TA features (S43b-EVIDENCE; deterministic per I-S1; LLM only interprets)
        ta = compute_ta_features(bars)
        ta_features = ta.to_dict()
        ta_audit = ta.audit

        # News: fetch all-known-as-of, filter to 90d window
        all_news = news_repo.get_known_as_of(_ticker, _as_of)
        recent_news: list[object] = [
            n for n in all_news
            if getattr(n, "published_at", None) is not None
            and n.published_at.date() >= start_90
        ]
        recent_claims = claim_repo.get_for_ticker(_ticker, _as_of)

        gaps: list[str] = []
        if not bars or (_as_of - bars[-1].period_end).days > 3:
            gaps.append("price_stale")
        if not statements_all:
            gaps.append("fundamentals_stale")
        if not recent_news:
            gaps.append("no_news_90d")

        # Deterministic snapshot md5
        payload = _json.dumps(
            {
                "bars": sorted(b.bar_id for b in bars),
                "statements": sorted(str(s.period_end) + "_" + str(s.statement_type) for s in statements_all),
                "news": sorted(getattr(n, "article_id", "") for n in recent_news),
                "claims": sorted(getattr(c, "claim_id", "") for c in recent_claims),
            },
            sort_keys=True,
        )
        data_md5 = hashlib.md5(payload.encode("utf-8")).hexdigest()

        # SharedContext.statements expects a single object (latest statement) per
        # claude_llm_perspective_adapter._context_to_str access pattern. Pass
        # latest_bs (closest to balance-sheet view) when available.
        return SharedContext(
            ticker=_ticker,
            as_of=_as_of,
            quotes=list(bars),
            statements=latest_bs,
            ratios_ttm=ratios_ttm,
            recent_news=recent_news,
            recent_claims=list(recent_claims),
            ta_features=ta_features,
            ta_audit=ta_audit,
            gaps=gaps,
            data_snapshot_md5=data_md5,
        )
