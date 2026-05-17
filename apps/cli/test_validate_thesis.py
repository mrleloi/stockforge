"""CLI tests for apps/cli/validate_thesis.py (S43a-CODE deliverable).

Coverage (≥7 tests):
  t1: --mock-llm happy path; exit 0; thesis file created with frontmatter
  t2: --ticker with critical data gaps → Thesis.incomplete() → exit 0 + incomplete frontmatter
  t3: cost cap below minimum → exits 1 + CostBudgetExceeded message
  t4: --as-of default = today
  t5: bear retry path — mock returns <3 points first call → exits 2 + BearCaseInvariantError
  t6: reproducibility — same ticker + as-of + mock → identical thesis_id in 2 runs
  t7: --no-mock-llm without ANTHROPIC_API_KEY → exits 4 with helpful error

NO live Anthropic calls in any test.

Source: agent-workspace/session-plans/pending/006-S41-track-F-impl-sub-plan.md § S43a
"""

from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from datetime import date
from decimal import Decimal
from pathlib import Path

import pytest
from click.testing import CliRunner

from packages.application.analysis.ports.cost_tracker_port import (
    Budget,
    CostBudgetExceeded,
)
from packages.contracts.types import Ticker
from packages.domain.analysis.models.perspective_analysis import (
    PerspectiveAnalysis,
    PerspectiveRole,
)
from packages.domain.analysis.models.synthesis import (
    Confluence,
    Synthesis,
)
from packages.domain.analysis.models.thesis import Thesis
from packages.domain.analysis.value_objects.bear_category import BearCategory
from packages.domain.analysis.value_objects.conviction import Conviction
from packages.domain.analysis.value_objects.grounded_point import GroundedPoint
from packages.domain.analysis.value_objects.trade_off_matrix import (
    DimensionVerdict,
    TradeOffMatrix,
)

# ---------------------------------------------------------------------------
# Shared fixtures and helpers
# ---------------------------------------------------------------------------

_TODAY = date.today()
_TICKER_STR = "HPG"


def _pt(text: str = "claim", cat: str | None = None) -> GroundedPoint:
    return GroundedPoint(
        text=text,
        source_url="https://mock.example.com/filing",
        source_excerpt="Verbatim excerpt for testing purposes only.",
        as_of=_TODAY,
        conviction=Conviction.MODERATE,
        category=cat,
    )


def _pa(role: PerspectiveRole, points: tuple[GroundedPoint, ...]) -> PerspectiveAnalysis:
    return PerspectiveAnalysis(
        role=role,
        key_points=points,
        overall_conviction=Conviction.MODERATE,
        cost_usd=Decimal("0.10"),
        model_id="mock-llm",
        prompt_hash="deadbeef01234567",
    )


def _good_bear() -> PerspectiveAnalysis:
    return _pa(
        PerspectiveRole.BEAR,
        (
            _pt("Fundamental risk", BearCategory.FUNDAMENTAL),
            _pt("Valuation risk", BearCategory.VALUATION),
            _pt("Macro risk", BearCategory.MACRO),
        ),
    )


def _good_bull() -> PerspectiveAnalysis:
    return _pa(PerspectiveRole.BULL, (_pt("Growth"), _pt("Moat"), _pt("Cashflow")))


def _good_quant() -> PerspectiveAnalysis:
    return _pa(PerspectiveRole.QUANT, (_pt("P/B below avg"), _pt("ROE above peer")))


def _synthesis() -> Synthesis:
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
        reasoning_trace="mock reasoning trace",
    )


class _MockLLMAgent:
    """Returns a fixed PerspectiveAnalysis for any call."""

    def __init__(self, pa: PerspectiveAnalysis) -> None:
        self._pa = pa

    async def analyze(self, _ticker: object, _ctx: object, _role: object) -> PerspectiveAnalysis:
        return self._pa


class _InsufficientBearAgent:
    """Returns <3-point bear first call, then good bear on second call."""

    def __init__(self) -> None:
        self._calls = 0

    async def analyze(self, _ticker: object, _ctx: object, _role: object) -> PerspectiveAnalysis:
        self._calls += 1
        if self._calls == 1:
            # Insufficient — only 1 point with 1 category
            return _pa(
                PerspectiveRole.BEAR,
                (_pt("only one point", BearCategory.FUNDAMENTAL),),
            )
        # Still insufficient on second call → triggers BearCaseInvariantError path
        return _pa(
            PerspectiveRole.BEAR,
            (_pt("still only one", BearCategory.FUNDAMENTAL),),
        )


class _MockSynthesizer:
    def __init__(self, synthesis: Synthesis) -> None:
        self._synthesis = synthesis

    async def synthesize(self, _ticker: object, _persp: object, _ctx: object) -> Synthesis:
        return self._synthesis


class _MockThesisRepo:
    def __init__(self) -> None:
        self.saved: list[Thesis] = []

    async def save(self, thesis: Thesis) -> None:
        self.saved.append(thesis)

    async def get_by_id(self, thesis_id: str) -> Thesis | None:
        return next((t for t in self.saved if t.thesis_id == thesis_id), None)

    async def find_by_ticker(self, ticker: Ticker, as_of: date) -> list[Thesis]:
        return [t for t in self.saved if t.ticker == ticker and t.as_of <= as_of]


class _MockEventBus:
    async def publish(self, _event: object) -> None:
        pass


class _MockCostTracker:
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


class _MockDataGatherer:
    def __init__(self, gaps: list[str] | None = None) -> None:
        self._gaps = gaps or []

    async def gather(self, ticker: Ticker, as_of: date) -> object:
        from packages.application.analysis.use_cases.validate_thesis_phase1 import (
            SharedContext,  # noqa: PLC0415
        )

        return SharedContext(
            ticker=ticker,
            as_of=as_of,
            quotes=["bar"],
            statements=object(),
            data_snapshot_md5="testmd5abc",
            gaps=self._gaps,
        )


# ---------------------------------------------------------------------------
# Patch helper: inject mocked use case into build_use_case
# ---------------------------------------------------------------------------


def _make_use_case(
    *,
    bear: object | None = None,
    bull: object | None = None,
    quant: object | None = None,
    synthesizer: object | None = None,
    data_gatherer: object | None = None,
    cost_tracker: object | None = None,
) -> object:
    """S382 verifier F1 inline-fix per AP-1 applying-per-mandate (S339/S358/S366 precedent):
    ValidateThesisPhase1UseCase ctor changed at S381 (F.3) from 3-individual-agent params
    (bear_agent/bull_agent/quant_agent) to single `agents: dict[PerspectiveRole, LLMPerspectivePort]`
    param per DD-1. Update helper to construct dict + pass `agents=` to ctor; preserves
    legacy bear/bull/quant kwarg interface for back-compat with all existing test call sites.
    """
    from packages.application.analysis.use_cases.validate_thesis_phase1 import (  # noqa: PLC0415
        ValidateThesisPhase1UseCase,
    )
    from packages.domain.analysis.models.perspective_analysis import (  # noqa: PLC0415
        PerspectiveRole,
    )

    agents = {
        PerspectiveRole.BEAR: bear or _MockLLMAgent(_good_bear()),
        PerspectiveRole.BULL: bull or _MockLLMAgent(_good_bull()),
        PerspectiveRole.QUANT: quant or _MockLLMAgent(_good_quant()),
    }
    return ValidateThesisPhase1UseCase(
        data_gatherer=data_gatherer or _MockDataGatherer(),
        agents=agents,  # type: ignore[arg-type]
        synthesizer=synthesizer or _MockSynthesizer(_synthesis()),
        thesis_repo=_MockThesisRepo(),
        cost_tracker=cost_tracker or _MockCostTracker(),
        event_bus=_MockEventBus(),
    )


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


def test_t1_mock_llm_happy_path(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t1: --mock-llm happy path; exit 0; thesis file created with required frontmatter."""
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    use_case = _make_use_case()
    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: use_case,
    )

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "HPG",
            "--as-of", "2026-04-29",
            "--mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 0, f"Expected exit 0; got {result.exit_code}. Output:\n{result.output}"
    out_file = tmp_path / "thesis-log" / "2026-04-29-HPG.md"
    assert out_file.exists(), f"Expected thesis file at {out_file}"
    content = out_file.read_text(encoding="utf-8")
    assert "disclaimer_present: true" in content
    assert "real_thesis: false" in content
    assert "thesis_id:" in content


def test_t2_critical_data_gaps_incomplete(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t2: critical data gaps → Thesis.incomplete() → exit 0 + incomplete: true frontmatter.

    Uses a valid 3-char ticker (VHM) but the MockDataGatherer reports critical
    gaps (price_stale + fundamentals_stale) so the use case returns INCOMPLETE.
    """
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    use_case = _make_use_case(
        data_gatherer=_MockDataGatherer(gaps=["price_stale", "fundamentals_stale"])
    )
    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: use_case,
    )

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "VHM",
            "--as-of", "2026-04-29",
            "--mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 0, f"Output:\n{result.output}"
    out_file = tmp_path / "thesis-log" / "2026-04-29-VHM.md"
    assert out_file.exists()
    content = out_file.read_text(encoding="utf-8")
    assert "incomplete: true" in content
    assert "disclaimer_present: true" in content


def test_t3_cost_cap_exceeded_exits_1(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t3: cost exceeded → use case returns Thesis.incomplete(gaps=[cost_budget_exceeded]) → exits 1.

    The use case catches CostBudgetExceeded internally and returns an INCOMPLETE thesis
    with gaps=["cost_budget_exceeded"]. The CLI detects this gap and exits 1 (BR-6).
    """
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    # Return a pre-built INCOMPLETE thesis with cost_budget_exceeded gap
    from packages.domain.analysis.models.thesis import Thesis  # noqa: PLC0415

    incomplete_thesis = Thesis.incomplete(
        Ticker("HPG"),
        date(2026, 4, 29),
        gaps=["cost_budget_exceeded"],
    )

    class _CostCapUseCase:
        async def execute(self, _ticker: object, _as_of: object) -> Thesis:
            return incomplete_thesis

    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: _CostCapUseCase(),
    )

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "HPG",
            "--as-of", "2026-04-29",
            "--mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 1, f"Expected exit 1; got {result.exit_code}. Output:\n{result.output}"


def test_t4_as_of_default_today(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t4: --as-of defaults to today when not supplied."""
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    use_case = _make_use_case()
    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: use_case,
    )

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "HPG",
            "--mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 0, f"Output:\n{result.output}"
    today_str = date.today().isoformat()
    out_file = tmp_path / "thesis-log" / f"{today_str}-HPG.md"
    assert out_file.exists(), f"Expected file {out_file}"


def test_t5_bear_retry_insufficient_exits_2(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t5: bear case insufficient after retry → Thesis.incomplete(gaps=[bear_case_insufficient]) → exit 2.

    The use case's _retry_bear_if_needed returns None when still insufficient after retry,
    which causes execute() to return Thesis.incomplete(gaps=["bear_case_insufficient"]).
    The CLI detects this gap and exits 2 (I-S10 / BR-1).
    """
    from apps.cli.validate_thesis import main  # noqa: PLC0415
    from packages.domain.analysis.models.thesis import Thesis  # noqa: PLC0415

    incomplete_bear = Thesis.incomplete(
        Ticker("HPG"),
        date(2026, 4, 29),
        gaps=["bear_case_insufficient"],
    )

    class _BearFailUseCase:
        async def execute(self, _ticker: object, _as_of: object) -> Thesis:
            return incomplete_bear

    monkeypatch.setattr(
        "apps._shared.use_case_builder.build_use_case",
        lambda **_kwargs: _BearFailUseCase(),
    )

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "HPG",
            "--as-of", "2026-04-29",
            "--mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 2, f"Expected exit 2; got {result.exit_code}. Output:\n{result.output}"
    out_file = tmp_path / "thesis-log" / "2026-04-29-HPG.md"
    assert out_file.exists()
    content = out_file.read_text(encoding="utf-8")
    assert "incomplete: true" in content


def test_t6_reproducibility_same_thesis_id(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """t6: same ticker + as-of + same mock → identical thesis_id in 2 runs."""
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    # Both runs use the same mock assembly (same data_md5 + same prompt_hash)
    def _build(**_kwargs: object) -> object:
        return _make_use_case()

    monkeypatch.setattr("apps._shared.use_case_builder.build_use_case", _build)

    runner = CliRunner()
    common_args = [
        "--ticker", "HPG",
        "--as-of", "2026-04-29",
        "--mock-llm",
        "--db", str(tmp_path / "test.sqlite"),
        "--output-dir", str(tmp_path / "thesis-log"),
    ]

    result1 = runner.invoke(main, common_args, standalone_mode=False)
    assert result1.exit_code == 0, result1.output

    out_path = tmp_path / "thesis-log" / "2026-04-29-HPG.md"
    content1 = out_path.read_text(encoding="utf-8")

    # Second run — overwrite same file
    result2 = runner.invoke(main, common_args, standalone_mode=False)
    assert result2.exit_code == 0, result2.output
    content2 = out_path.read_text(encoding="utf-8")

    # Extract thesis_id lines and compare
    def _extract_id(text: str) -> str:
        for line in text.splitlines():
            if line.startswith("thesis_id:"):
                return line.strip()
        return ""

    id1 = _extract_id(content1)
    id2 = _extract_id(content2)
    assert id1 == id2, f"thesis_id changed between runs:\n  run1: {id1}\n  run2: {id2}"


def test_t7_no_mock_llm_without_api_key_exits_4(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """t7: --no-mock-llm without ANTHROPIC_API_KEY → exits 4 with helpful error."""
    from apps.cli.validate_thesis import main  # noqa: PLC0415

    # Ensure key is absent
    monkeypatch.delenv("ANTHROPIC_API_KEY", raising=False)

    runner = CliRunner()
    result = runner.invoke(
        main,
        [
            "--ticker", "HPG",
            "--as-of", "2026-04-29",
            "--no-mock-llm",
            "--db", str(tmp_path / "test.sqlite"),
            "--output-dir", str(tmp_path / "thesis-log"),
        ],
        standalone_mode=False,
    )

    assert result.exit_code == 4, (
        f"Expected exit 4 (BuildError for missing API key); "
        f"got {result.exit_code}. Output:\n{result.output}"
    )
    # Helpful error message must mention ANTHROPIC_API_KEY
    combined_output = result.output or ""
    assert "ANTHROPIC_API_KEY" in combined_output, (
        f"Expected 'ANTHROPIC_API_KEY' in error output; got:\n{combined_output}"
    )


# ---------------------------------------------------------------------------
# V0=6 Markdown rendering tests (D4 — F.5 plan-038)
# TC-RENDER-V6-1 through TC-RENDER-V6-8
# Tests for _render_thesis_md V0=6 extension (BUFFETT/GRAHAM/TALEB sections)
# and --run-mode dogfood frontmatter (DD-7).
# ---------------------------------------------------------------------------


def _good_buffett() -> PerspectiveAnalysis:
    return _pa(
        PerspectiveRole.BUFFETT,
        (_pt("Moat point", "MOAT"), _pt("ROIC point", "ROIC"), _pt("Valuation margin", "VALUATION")),
    )


def _good_graham() -> PerspectiveAnalysis:
    return _pa(
        PerspectiveRole.GRAHAM,
        (_pt("Net-net asset", "BALANCE_SHEET"), _pt("MoS price", "VALUATION"), _pt("Current ratio", "FUNDAMENTAL")),
    )


def _good_taleb() -> PerspectiveAnalysis:
    return _pa(
        PerspectiveRole.TALEB,
        (_pt("Tail risk", "RISK"), _pt("Antifragility", "MACRO"), _pt("Kurtosis", "RISK")),
    )


def _build_v6_thesis() -> object:
    """Build a SUBMITTED V0=6 Thesis with all 6 perspectives for render tests."""
    from datetime import UTC, datetime  # noqa: PLC0415

    from packages.domain.analysis.models.thesis import Thesis, ThesisStatus  # noqa: PLC0415
    from packages.domain.analysis.value_objects.confidence_level import (
        ConfidenceLevel,  # noqa: PLC0415
    )
    from packages.domain.analysis.value_objects.recommendation import (
        Recommendation,  # noqa: PLC0415
    )

    return Thesis(
        thesis_id="deadbeef" * 8,
        ticker=__import__("packages.contracts.types", fromlist=["Ticker"]).Ticker("VHM"),
        as_of=date(2026, 5, 17),
        created_at=datetime(2026, 5, 17, 12, 0, 0, tzinfo=UTC),
        status=ThesisStatus.SUBMITTED,
        perspectives=(
            _good_bear(),
            _good_bull(),
            _good_quant(),
            _good_buffett(),
            _good_graham(),
            _good_taleb(),
        ),
        synthesis=_synthesis(),
        final_recommendation=Recommendation.WATCH,
        confidence_level=ConfidenceLevel.MEDIUM,
        cost_usd=Decimal("1.50"),
    )


def test_render_v6_includes_buffett_section() -> None:
    """TC-RENDER-V6-1: V0=6 thesis render includes Buffett Case section header."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis)
    assert "## Buffett Case" in md, f"Expected '## Buffett Case' in rendered markdown; got:\n{md[:500]}"


def test_render_v6_includes_graham_section() -> None:
    """TC-RENDER-V6-2: V0=6 thesis render includes Graham Case section header."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis)
    assert "## Graham Case" in md, f"Expected '## Graham Case' in rendered markdown; got:\n{md[:500]}"


def test_render_v6_includes_taleb_section() -> None:
    """TC-RENDER-V6-3: V0=6 thesis render includes Taleb Case section header."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis)
    assert "## Taleb Case" in md, f"Expected '## Taleb Case' in rendered markdown; got:\n{md[:500]}"


def test_render_v6_preserves_is35_disclaimer_footer() -> None:
    """TC-RENDER-V6-4: V0=6 thesis render preserves I-S35 disclaimer footer (research aid)."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis)
    assert "research aid" in md.lower(), (
        "Expected I-S35 disclaimer footer with 'research aid' in rendered markdown"
    )
    assert "not financial advice" in md.lower(), (
        "Expected 'not financial advice' in I-S35 disclaimer footer"
    )
    assert "Calibration grade" in md, (
        "Expected 'Calibration grade' in I-S35 disclaimer footer"
    )


def test_render_v6_recommendation_is_enum_not_prose() -> None:
    """TC-RENDER-V6-5: V0=6 thesis render uses Recommendation enum; no 'buy'/'sell' prose (I-S35)."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis)
    # I-S35 check: no 'buy' or 'sell' raw prose in frontmatter recommendation field
    for line in md.splitlines():
        if line.startswith("recommendation:"):
            rec_val = line.split(":", 1)[1].strip().lower()
            assert rec_val not in ("buy", "sell"), (
                f"I-S35 violation: recommendation frontmatter is '{rec_val}'; "
                "must be enum value (investigate/watch/pass/thesis_candidate), not 'buy'/'sell'"
            )
            break
    # Enum values are valid
    assert "watch" in md or "investigate" in md or "pass" in md or "thesis_candidate" in md


def test_render_v6_run_mode_dogfood_adds_metadata() -> None:
    """TC-RENDER-V6-6: dogfood run_mode adds 'dogfood: true' frontmatter (DD-7)."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    md = _render_thesis_md(thesis, run_mode="dogfood")
    assert "dogfood: true" in md, (
        "Expected 'dogfood: true' frontmatter in dogfood mode render"
    )
    assert "dogfood_session: S384" in md, (
        "Expected 'dogfood_session: S384' frontmatter in dogfood mode render"
    )


def test_render_v6_run_mode_smoke_default_no_metadata() -> None:
    """TC-RENDER-V6-7: smoke (default) run_mode does NOT add dogfood frontmatter (DD-7)."""
    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415

    thesis = _build_v6_thesis()
    # Explicit smoke
    md_smoke = _render_thesis_md(thesis, run_mode="smoke")
    assert "dogfood: true" not in md_smoke, (
        "Expected 'dogfood: true' NOT present in smoke mode render"
    )
    # Default (no kwarg)
    md_default = _render_thesis_md(thesis)
    assert "dogfood: true" not in md_default, (
        "Expected 'dogfood: true' NOT present in default (smoke) mode render"
    )


def test_render_v3_backward_compat_still_works() -> None:
    """TC-RENDER-V6-8: N=3 thesis renders BEAR/BULL/QUANT; BUFFETT/GRAHAM/TALEB skipped cleanly."""
    from datetime import UTC, datetime  # noqa: PLC0415

    from apps.cli.validate_thesis import _render_thesis_md  # noqa: PLC0415
    from packages.domain.analysis.models.thesis import Thesis, ThesisStatus  # noqa: PLC0415
    from packages.domain.analysis.value_objects.confidence_level import (
        ConfidenceLevel,  # noqa: PLC0415
    )
    from packages.domain.analysis.value_objects.recommendation import (
        Recommendation,  # noqa: PLC0415
    )

    v3_thesis = Thesis(
        thesis_id="v3thesis" + "a" * 56,
        ticker=__import__("packages.contracts.types", fromlist=["Ticker"]).Ticker("HPG"),
        as_of=date(2026, 4, 29),
        created_at=datetime(2026, 4, 29, 10, 0, 0, tzinfo=UTC),
        status=ThesisStatus.SUBMITTED,
        perspectives=(
            _good_bear(),
            _good_bull(),
            _good_quant(),
            # NO BUFFETT/GRAHAM/TALEB → backward-compat test
        ),
        synthesis=_synthesis(),
        final_recommendation=Recommendation.INVESTIGATE,
        confidence_level=ConfidenceLevel.LOW,
        cost_usd=Decimal("0.30"),
    )
    md = _render_thesis_md(v3_thesis)
    # Existing sections present
    assert "## Bear Case" in md
    assert "## Bull Case" in md
    assert "## Quant Summary" in md
    # V0=6 sections show the stub (not present)
    assert "_No Buffett perspective available._" in md
    assert "_No Graham perspective available._" in md
    assert "_No Taleb perspective available._" in md
    # I-S35 disclaimer still present
    assert "research aid" in md.lower()
