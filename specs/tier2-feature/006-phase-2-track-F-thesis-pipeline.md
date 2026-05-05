---
spec_id: SPEC-2026-05-01-006-phase-2-track-F-thesis-pipeline
tier: 2
status: approved
version: 1.0
created: 2026-05-01
last_reviewed: 2026-05-01
authors: [Claude Opus 4.7 (S41 sandwich-architect subagent)]
bounded_contexts: [Analysis, Market Data, Fundamental, News Stream]
related_specs: [SPEC-2026-04-23-001, tier2-000-phase-1-thin-slice-VHM, SPEC-2026-04-23-T1-001]
ubiquitous_language_terms: [Thesis, PerspectiveAnalysis, Synthesis, GroundedPoint, TradeOffMatrix, Recommendation, ConfidenceLevel, BearAgent, BullAgent, QuantAgent, Phase1Synthesizer, ValidateThesisPhase1UseCase, CostTracker, ResearchAid]
produces_thesis_output: true
phase: 2
binding_master_plan: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md § S41-S43a
---

# SPEC: Phase 2 Track F — Thesis 3-Perspective Real Implementation

> Operational realisation of spec 001 § Phase 1 simplifications. Track F lifts BC-8 Analysis from "stub-only" (Phase 1) to "first real production thesis pipeline" using Tier 1+2 data already ingested by Tracks A-D.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

Phase 1 closed S30 with BC-8 Analysis empty (no entities, no use case) — the VHM exemplar thesis was hand-authored markdown demonstrating template fidelity, NOT machine-produced. Phase 2 Tracks A-D (S32-S36) shipped:

- **BC-1 Market Data** scaled VHM → VN30 (S33; 30 tickers, dual-source vnstock VCI × SSI iBoard, Rule 4 reconciliation operational)
- **BC-2 Fundamental** ingestion + ratio compute service (S34; financial statements + P/E + P/B + ROE + Debt/Equity + Damodaran-grade ratio formulas)
- **BC-5 News Stream** + CafeF scraper + Claude LLM claim extractor (S36; Sentiment 5-class StrEnum + ExtractedClaim with Rule 6 provenance)

Track F (S41-S43a) closes the loop: assemble Tier 1+2 context → run 3 perspective agents (Bear, Bull, Quant) in parallel → synthesise into trade-off matrix → emit thesis card per spec 001 § A.4. This is the **first production LLM call path inside BC-8** and the first Streamlit UI page.

**Why now**: Phase 1's hand-authored VHM exemplar proved the format works. The test for Phase 2 is whether the system, given a fresh ticker, produces output of comparable structure + grounding. If yes → 5-thesis dogfood (S43a) satisfies Charter Month-3 SC-3 + SC-4. If no → recovery loop before Phase 3.

## A.2 User & Use Cases

**Primary user**: project owner — self-use; small trusted circle later.

**UC-1: Validate one ticker via Streamlit**
As project owner, I open `streamlit run apps/dashboard/main.py`, navigate to "Validate Thesis", type `HPG`, click Validate, and within 5 minutes see a thesis card with bear case (≥3 grounded points), bull case, quant summary (numbers from code), trade-off matrix, and explicit-disagreement panel. Cost displayed at footer ≤$3.

**UC-2: Validate via CLI (offline-friendly fallback)**
`python apps/cli/validate_thesis.py --ticker HPG --as-of 2026-04-29` writes thesis to `agent-workspace/memory/thesis-log/2026-04-29-HPG.md` with `real_thesis: true` frontmatter. Same use case under the hood.

**UC-3: Reproducibility audit**
Re-running same `(ticker, as_of)` with same model + prompt hash produces same `thesis_id` + same content (per spec 001 AC-5). System hashes `(prompt_template, model_id, ticker, as_of, data_snapshot_md5)` → deterministic ID.

## A.3 Business Rules

- **BR-1 Bear Case Substantive (I-S10)**: `Thesis.submit()` raises `BearCaseInvariantError` if bear case has <3 distinct points. "Distinct" measured by category enum (FUNDAMENTAL / STRUCTURAL / VALUATION / COMPETITIVE / GOVERNANCE / MACRO) + key_phrase non-overlap. System retries Bear agent once with stronger prompt before raising.
- **BR-2 No LLM Math (I-S1)**: every numeric value in any output (Quant Summary, Trade-Off Matrix scores, Margin of Safety, ratio percentile) traces to a deterministic Python tool call. LLM agents see numbers in their context and interpret; LLM never produces a number in prose. Verifier S43 grep `r"approximately|around|roughly|~ \d+%"` returns 0 in production code path.
- **BR-3 Disagreement Preserved (I-S12)**: when Bear and Bull reach opposite conclusions on the same dimension with equal-or-higher conviction, `Synthesis.explicit_disagreements` is non-empty. The system NEVER vote-averages to "HOLD". `Phase1Synthesizer.synthesize()` invariant: `if any opposing-conclusion pair → explicit_disagreements ≠ []`.
- **BR-4 Every Claim Cited (I-1 + I-S5)**: every `GroundedPoint` carries `source_url: str`, `source_excerpt: str` (≤500 chars verbatim), and `as_of: date`. Aggregate validates non-empty in `__post_init__`.
- **BR-5 Research-Aid Framing (I-S35)**: every output includes "research aid, not financial advice" disclaimer footer. UI banner mandatory. No "buy", "sell", "recommend" verbs in user-facing copy — only "thesis exploration", "consideration", "investigate".
- **BR-6 Cost Cap Per Validation (I-40)**: `CostTrackerPort` enforces $3 hard cap per `execute()`. Per-perspective sub-budget $1; synthesizer $1. Breach raises `CostBudgetExceeded`. Target average $1.30-$2.00.
- **BR-7 Phase-1-Compatible Confidence (I-S7)**: Phase 2 has no calibration database yet (n_samples=0 across all signal types). `ConfidenceLevel` set heuristically per spec 001 § B.2 (HIGH = all 3 perspectives agree + strong / MEDIUM = mixed grounded / LOW = disagreement OR limited evidence). Frontmatter records `calibration_grade: D` (lowest) until Phase 3 calibration backfill.
- **BR-8 Multi-Perspective Phase-1 Exception (I-S11)**: Phase 2 ships 3 perspectives (Bear / Bull / Quant). Macro / Behavior / Manager perspectives are stubbed-out (return empty `PerspectiveAnalysis` with `phase: "deferred-3"`). Documented exception. Phase 3+ adds the other 3 to satisfy I-S11 ≥4-perspective threshold.

## A.4 Success Criteria

### Quantitative (Charter Month-3 mapping)

| # | Criterion | Phase 2 Track F mapping |
|---|---|---|
| 3 | First 5 thesis recorded with formal structure | S43a ships 5 REAL thesis files (`real_thesis: true`); Charter SC-3 satisfied |
| 4 | `/thesis-validate` <5 min end-to-end | S43a Streamlit + CLI both exit ≤5 min wall-clock per thesis |

### Acceptance Signals (V dimensions)

- VF-1: 5 thesis files at `agent-workspace/memory/thesis-log/2026-MM-DD-{TICKER}.md`; `real_thesis: true`; bear case ≥3 distinct points each; every number has `-- query: SQL` audit comment
- VF-2: Total Track F cost ≤$15 (5 × $3); average ≤$2/thesis target; verifier S43 spot-checks cost log
- VF-3: Reproducibility — re-run 1 of 5 produces identical `thesis_id` + identical content (AC-5)
- VF-4: Per-thesis bear case has at least 3 distinct categories (not 3 paraphrases of the same risk)
- VF-5: I-S12 disagreement enforced — at least 1 of 5 thesis exhibits explicit disagreement panel populated (kind="verdict" OR kind="narrative" per § A.11 P3 extension); OR documented detector-emptiness with bull-points=0 attributed to data-gap (Rule-7 honest-insufficient is acceptable substrate-not-bug signal per VF-5 calibration S43e — `agent-workspace/memory/observations/vf5-calibration-S43e.md`); reasoning preserved in session log if gap-attributed

### Qualitative

- User reads 5 thesis cards and reports ≥3 are "genuinely useful research aid" (subjective; recorded in S43a session log)
- LLM-math creep grep across `packages/{domain,application,infrastructure}/analysis/`: 0 hits

## A.5 Scope

### In Scope (Phase 2 Track F)

- BC-8 Analysis domain: `Thesis` aggregate + `PerspectiveAnalysis` + `Synthesis` entities; `TradeOffMatrix` + `GroundedPoint` + `Recommendation` enum + `ConfidenceLevel` enum value objects; `ThesisRepository` Protocol
- Application: `ValidateThesisPhase1UseCase` + `LLMPerspectivePort` + `CostTrackerPort` + `Phase1DataGatherer` orchestration
- Infrastructure: `BearPerspectiveAgent` / `BullPerspectiveAgent` / `QuantPerspectiveAgent` / `Phase1Synthesizer` / `ClaudeLLMPerspectiveAdapter` / `SqliteThesisRepository` / `InProcessCostTracker`
- Cross-BC contract: `ThesisRecorded` event
- UI: Streamlit page + CLI alternative
- 5 REAL thesis dogfood at S43a

### Explicitly Out of Scope

1. **Macro / Behavior / Manager perspectives** — Phase 3+ (I-S11 relaxed Phase 2; documented BR-8 exception)
2. **Counter-narrative integration** — Phase 3 (I-S13; requires BC-7 Crowd Sentiment + BC-6 KOL — both Phase 3+)
3. **Calibration-based confidence** — Phase 4 (requires ≥5 thesis post-mortem outcomes; Phase 2 ships Phase-1 heuristic per BR-7)
4. **Thesis-validate slash command full automation** — Phase 3 (S43a Streamlit + CLI is "manual end-to-end <5 min"; full slash-command wraps later)
5. **KOL signal integration in perspective agents** — Phase 3 (BC-6 deferred)
6. **Crowd sentiment / pump detection input to Bear agent** — Phase 3 (BC-7 deferred)
7. **Multi-ticker comparison thesis** — Phase 4+
8. **Outcome tracking + post-mortem auto-scheduling for thesis** — Phase 3 (I-S26 cron skeleton ships at Phase 2 close; live wire-in Phase 3)
9. **Live LLM in CI** — never; tests use `MockLLMPerspectivePort` fixtures

## A.6 Key Decisions & Tradeoffs

### A.6.1 Phase 1 Heuristic Recommendation Logic
Phase 1's heuristic from spec 001 § B.3 (`THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS`) is preserved verbatim. Track F does not introduce a new recommendation engine — that's Phase 4 calibration work. Trade-off: Phase 2 thesis output may default to `INVESTIGATE` more often than ideal because evidence is mixed (Phase 2 has no Tier 3-4 to break ties). Acceptable per Charter "honest insufficiency over false confidence".

### A.6.2 SQLite for ThesisRepository (vs Postgres)
SQLite continues per Phase 1 doctrine (Phase 1 thin-slice § A.6.2). Postgres deferred Phase 3. New table `theses(thesis_id PRIMARY KEY, ticker, as_of, created_at, status, recommendation, confidence_level, payload_json, prompt_hash, model_id, cost_usd)`. Migration path: `payload_json` stays portable; on Phase 3 Postgres swap, blob columns translate cleanly.

### A.6.3 Sonnet for Bear/Bull, Opus for Quant + Synthesizer (recommended)
Per spec 001 § B.10:
- Bear agent: ~20K tokens × Sonnet ($3/MTok input + $15/MTok output) ≈ $0.10
- Bull agent: ~20K tokens × Sonnet ≈ $0.10
- Quant agent: ~25K tokens × Opus ($15/MTok input + $75/MTok output) ≈ $0.70 [reliability premium; numerical interpretation must not drift]
- Synthesizer: ~15K tokens × Opus ≈ $0.40
- Total target: ~$1.30 average; $3 hard cap per BR-6

**ALTERNATIVE pending user gate** (D-014 § Open Questions): Quant agent on Sonnet halves cost ($0.70 → $0.20) but risks numerical interpretation drift — Sonnet has historically shown lower discipline at "interpret these 12 ratios + state the verdict, do NOT recompute" tasks. Recommended: Opus default; user may downgrade SCOPE-tier.

### A.6.4 Streamlit (vs FastAPI for Phase 2)
Streamlit per spec 001 § B.7. FastAPI deferred Phase 4+ when public/peer-shared API needed. Trade-off: Streamlit is single-user; cannot expose to trusted-circle peers without auth. Acceptable Phase 2 (project owner self-use).

## A.7 Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| **Personal-risk-profile.md unfilled** (33 USER FILL placeholders as of S30 close) — Quant agent risk-sizing context defaults to charter-floor (15% max position / 30% sector cap) | HIGH | S41 surfaces P0 prerequisite; D-014 § Risks flags; default = proceed with charter-floor-only and document IMPL-S41-N deviation; user can re-fill mid-Phase 2 to upgrade thesis quality |
| Bear agent retry loop (<3 points → retry → still <3) blowing cost cap | MED | Hard retry cap 1× per agent; if still <3, raise `BearCaseInvariantError` → use case returns `Thesis.incomplete()`; cost stops accumulating |
| LLM hallucinates source_url for a claim | HIGH | `GroundedPoint` schema NOT NULL on `source_url` + `source_excerpt`; post-LLM validator strips claims without grounded excerpt; verifier S43 spot-checks |
| Disagreement detection too aggressive (every thesis shows disagreement) | LOW | Threshold tuning; default = "opposite verdict + both ≥MODERATE conviction"; calibrate at S43a dogfood |
| Disagreement detection too weak (no thesis shows disagreement = prompt drift) | MED | VF-5 acceptance signal: ≥1 of 5 dogfood thesis must exhibit disagreement; if 0, prompts get S43a iteration |
| Quant agent computes a number in prose despite system prompt | HIGH | Verifier S43 grep; agent prompt § "Forbidden phrases" lists "approximately", "around", "roughly", "~ X%"; tool-call schema forces structured numeric output |
| Streamlit Vietnamese rendering edge cases (Vietnamese diacritics in thesis card) | LOW | Test fixture includes Vietnamese ticker name + Vietnamese excerpt; UTF-8 default; pin Streamlit version |
| Re-run reproducibility violated by LLM non-determinism | MED | `temperature=0` on all 4 LLM calls; `prompt_hash` recorded; thesis_id = sha256(model_id + prompt_hash + ticker + as_of + data_snapshot_md5); audit at S43a |
| Cost tracker race condition (parallel agents) | LOW | `InProcessCostTracker` uses `asyncio.Lock`; per-call atomic add; total checked after each await point |

## A.8 Dependencies

### Upstream

- **Phase 1 closed**: BC-1 Bar entity + repository (S27); BC-9 RiskRule (S27); SQLite substrate (S28); `data/vhm.sqlite` exemplar (S28)
- **Phase 2 Track A closed**: VnstockAdapter + SsiAdapter dual-source (S32; D-012)
- **Phase 2 Track B closed**: VN30 universe + nightly batch ingestion (S33)
- **Phase 2 Track C closed**: BC-2 Fundamental aggregate + ratio service (S34); FinancialStatement + ratio formulas
- **Phase 2 Track D closed**: BC-5 News Stream + CafeF scraper + Claude LLM extractor (S36); ExtractedClaim with Rule 6 provenance
- `agent-workspace/memory/personal-risk-profile.md` — TEMPLATE (33 USER FILL placeholders unfilled as of S30 close); Quant agent risk-sizing context defaults to charter-floor if unfilled
- `agent-workspace/constitution/invariants.md` — I-1, I-S1, I-S5, I-S7, I-S10, I-S11, I-S12, I-S35, I-40 binding
- `specs/tier2-feature/001-validate-investment-thesis.md` — Phase 1 spec; this Phase 2 spec implements its `Phase1*` symbols

### Downstream

- Phase 3: 6-perspective expansion (adds Macro / Behavior / Manager); calibration-based confidence; counter-narrative integration; thesis post-mortem auto-scheduling
- Phase 4+: FastAPI public surface; multi-user auth; FiinPro paid data integration

### External

- `claude-sonnet-4-6` model (Bear / Bull) — pin in `claude_llm_perspective_adapter.py` config
- `claude-opus-4-7` model (Quant / Synthesizer) — pin same place
- Streamlit ≥1.32 — pin in `pyproject.toml`
- Existing Anthropic SDK already used in `claude_llm_extractor.py` (S36 BC-5)

## A.9 Glossary Check

All terms in `agent-workspace/ubiquitous-language/glossary.md` v1.0 (S25 seed). New Phase-2 terms added inline at S41:
- Thesis → glossary
- PerspectiveAnalysis → NEW (Phase 2; add at S42 entry via /drill-me incremental)
- Synthesis → NEW (Phase 2)
- GroundedPoint → NEW (Phase 2)
- TradeOffMatrix → NEW (Phase 2)
- Recommendation, ConfidenceLevel → NEW (Phase 2)

S42 dev runs `/drill-me` incremental for the 5 NEW terms before first entity ships.

## A.10 Data Provenance

| Number / Metric | Value | Source | As-Of | Notes |
|---|---|---|---|---|
| Cost target average per thesis | $1.30-$2.00 | spec 001 § B.10 | 2026-04-23 | charter-anchored; verifier S43 measures actual |
| Cost hard cap per thesis | $3.00 | spec 001 § A.3 AC-1 + I-40 | 2026-04-23 | binding |
| Bear case minimum points | 3 | invariants.md I-S10 | 2026-04-23 | aggregate validates |
| Multi-perspective minimum (Phase 2 exception) | 3 | spec 001 § B.9 (Phase 1 relaxation) | 2026-04-23 | Phase 3 lifts to 4 per I-S11 |
| Source excerpt max chars | 500 | financial-data-protocol Rule 6 | 2026-04-23 | inherits from BC-5 ExtractedClaim |
| Default max position size | 0.15 | PROJECT_CHARTER.md § First Sub-Scope | 2026-04-30 | personal-risk-profile.md may tighten |
| Sector concentration cap | 0.30 | Charter implicit | 2026-04-30 | personal-risk-profile.md may tighten |
| Reconciliation tolerance | 1% | financial-data-protocol Rule 4 | 2026-04-23 | Phase 2 dual-source operational |
| LLM `temperature` per call | 0.0 | Reproducibility AC-5 | 2026-05-01 | pinned in adapter config |

LLM never generates these. Code computes / config holds defaults. Spec table is authoritative.

## A.11 Adversarial Check

### Bear Case Contract

A substantive bear case is `≥3 distinct points`, where "distinct" requires:
1. **Different category** drawn from `BearCategory` enum: FUNDAMENTAL | STRUCTURAL | VALUATION | COMPETITIVE | GOVERNANCE | MACRO
2. Each point is a `GroundedPoint(source_url, source_excerpt, as_of, conviction)` — non-empty fields
3. `key_phrases` overlap ratio between any two points <40% (Jaccard); enforced by post-LLM validator
4. Each point's `source_url` must reference data within `as_of - 365d` window (no stale-news bear case)

### Disagreement Handling

System detects disagreement per dimension (VALUE / QUALITY / GROWTH / RISK).
Each `Disagreement` carries a `kind` classifier:

**`kind="verdict"`** (original spec rule):
- Bear verdict ∈ {STRONG, NEUTRAL, WEAK}; Bull verdict ∈ {STRONG, NEUTRAL, WEAK}
- Fires when: (Bear=STRONG AND Bull=WEAK) OR (Bear=WEAK AND Bull=STRONG)

**`kind="narrative"`** (P3 extension, S43e VF-5 calibration):
- Fires when BOTH perspectives have ≥1 point on the dimension AND verdicts are
  asymmetric strength: (Bear=STRONG AND Bull=NEUTRAL) OR (Bear=NEUTRAL AND
  Bull=STRONG). Captures cases where both perspectives engaged on the dimension
  but with conviction mismatch — meaningful tension the verdict-only rule misses.
- Source: `observations/vf5-calibration-S43e.md` Path B / FPT-pattern.

**Common rules** (apply to both kinds):
- All disagreements land in `Synthesis.explicit_disagreements: list[Disagreement]`
- `Phase1Synthesizer` invariant: if any disagreement detected, `Synthesis.confluence_assessment` is NEVER `STRONG_CONSENSUS`
- Final recommendation when disagreement exists: `INVESTIGATE` (default) — never `THESIS_CANDIDATE`

**NOT detected as disagreement** (deferred to Phase 3 peer-comparable shipping
per § A.10 OR future SCOPE-tier amendment):
- Perspective-asymmetry: one perspective has 0 points on the dimension, the
  other has STRONG. This is a real signal but conflates "data-gap" with
  "conviction mismatch"; current detector treats this as substrate-not-bug
  (Rule-7 honest-insufficient on bull-side reflects data-gap attribution).

### Confidence Framing

Phase 2 = heuristic only (BR-7). Every output frontmatter records:
- `calibration_grade: D` (lowest by default; no calibration data yet)
- `n_samples: 0` (Phase 3 backfills)
- `hit_rate: null`
- `lookback_period: null`
- `phase_2_heuristic: HIGH | MEDIUM | LOW` (per BR-7 logic)

### Output Framing

Mandatory disclaimer footer per I-S35 in:
1. Streamlit thesis card render — `st.caption()` block
2. CLI markdown output — bottom of file
3. Thesis log file — yaml frontmatter `disclaimer_present: true` + body footer

Banned verbs in user-facing copy: "buy", "sell", "recommend", "should". Allowed: "thesis exploration", "consideration", "investigate", "research aid".

---

# PART B — AGENT CONTRACT

## B.1 Bounded Context Involvement

| BC | Role | What it provides |
|---|---|---|
| BC-1 Market Data | Input | Bar history (price/volume/foreign flow) via `BarRepository.get_range_as_of()` (point-in-time) |
| BC-2 Fundamental | Input | FinancialStatement + ratio compute (P/E, P/B, ROE, D/E, percentile) via `FundamentalRepository.get_as_of()` + `RatioService` |
| BC-5 News Stream | Input | NewsArticle + ExtractedClaim (Rule 6 provenance) via `NewsRepository.get_for_ticker()` + `ClaimRepository.get_for_ticker()` |
| BC-8 Analysis | **Orchestrator** | Thesis aggregate + Phase1DataGatherer + 3 perspective agents + synthesizer + use case + repository |
| BC-9 Portfolio | Read-only context | RiskRule constants + personal-risk-profile.md values (Quant agent context) |

## B.2 Domain Model (BC-8 Analysis)

```python
# packages/domain/analysis/value_objects/recommendation.py
from enum import StrEnum

class Recommendation(StrEnum):
    THESIS_CANDIDATE = "thesis_candidate"
    INVESTIGATE = "investigate"
    WATCH = "watch"
    PASS = "pass"

# packages/domain/analysis/value_objects/confidence_level.py
class ConfidenceLevel(StrEnum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

# packages/domain/analysis/value_objects/grounded_point.py
@dataclass(frozen=True, slots=True)
class GroundedPoint:
    text: str                    # the claim
    source_url: str              # I-1 mandatory
    source_excerpt: str          # ≤500 chars (Rule 6 inherit)
    as_of: date
    conviction: Conviction       # STRONG | MODERATE | WEAK
    category: str | None = None  # BearCategory for bear points

    def __post_init__(self) -> None:
        if not self.source_url.strip():
            raise GroundedPointInvariantError("source_url required (I-1)")
        if not self.source_excerpt.strip():
            raise GroundedPointInvariantError("source_excerpt required (Rule 6)")
        if len(self.source_excerpt) > 500:
            raise GroundedPointInvariantError("excerpt > 500 chars")

# packages/domain/analysis/value_objects/trade_off_matrix.py
DIMENSIONS = ("VALUE", "QUALITY", "GROWTH", "RISK")

@dataclass(frozen=True, slots=True)
class TradeOffMatrix:
    scores: Mapping[str, DimensionVerdict]   # dim → STRONG | NEUTRAL | WEAK
    evidence: Mapping[str, tuple[GroundedPoint, ...]]

# packages/domain/analysis/models/perspective_analysis.py
class PerspectiveRole(StrEnum):
    BEAR = "bear"; BULL = "bull"; QUANT = "quant"
    MACRO = "macro"; BEHAVIOR = "behavior"; MANAGER = "manager"   # Phase 3 stubs

@dataclass(frozen=True, slots=True)
class PerspectiveAnalysis:
    role: PerspectiveRole
    key_points: tuple[GroundedPoint, ...]
    overall_conviction: Conviction
    cost_usd: Decimal
    model_id: str
    prompt_hash: str
    deferred: bool = False        # True for Phase 3 stubs

# packages/domain/analysis/models/synthesis.py
@dataclass(frozen=True, slots=True)
class Synthesis:
    trade_off_matrix: TradeOffMatrix
    confluence_assessment: Confluence    # STRONG_CONSENSUS | MIXED | DISAGREEMENT
    explicit_disagreements: tuple[Disagreement, ...]
    catalysts: tuple[GroundedPoint, ...]
    risks: tuple[GroundedPoint, ...]
    reasoning_trace: str

# packages/domain/analysis/models/thesis.py
class ThesisStatus(StrEnum):
    DRAFT = "draft"; SUBMITTED = "submitted"; INCOMPLETE = "incomplete"

@dataclass(frozen=True, slots=True)
class Thesis:
    thesis_id: str               # sha256(model_id + prompt_hash + ticker + as_of + data_md5)
    ticker: Ticker
    as_of: date
    created_at: datetime
    status: ThesisStatus
    perspectives: tuple[PerspectiveAnalysis, ...]
    synthesis: Synthesis | None  # None if INCOMPLETE
    final_recommendation: Recommendation | None
    confidence_level: ConfidenceLevel | None
    cost_usd: Decimal
    calibration_grade: str = "D"
    n_samples: int = 0

    def __post_init__(self) -> None:
        if self.status == ThesisStatus.SUBMITTED:
            self._enforce_bear_case()        # BR-1 / I-S10
            self._enforce_disagreement()     # BR-3 / I-S12

    def _enforce_bear_case(self) -> None:
        bear = next((p for p in self.perspectives if p.role == PerspectiveRole.BEAR), None)
        if bear is None or len(bear.key_points) < 3:
            raise BearCaseInvariantError("≥3 distinct bear points required (I-S10)")
        cats = {p.category for p in bear.key_points if p.category}
        if len(cats) < 3:
            raise BearCaseInvariantError("≥3 distinct categories required")
```

## B.3 Use Case

```python
# packages/application/analysis/use_cases/validate_thesis_phase1.py
class ValidateThesisPhase1UseCase:
    def __init__(
        self,
        data_gatherer: Phase1DataGatherer,
        bear_agent: LLMPerspectivePort,
        bull_agent: LLMPerspectivePort,
        quant_agent: LLMPerspectivePort,
        synthesizer: Phase1Synthesizer,
        thesis_repo: ThesisRepository,
        cost_tracker: CostTrackerPort,
        event_bus: EventBus,
    ): ...

    async def execute(self, ticker: Ticker, as_of: date | None = None) -> Thesis:
        as_of = as_of or date.today()
        with self.cost_tracker.scoped_budget(limit_usd=Decimal("3.00")) as budget:
            # Step 1 — gather Tier 1+2 (deterministic)
            context = await self.data_gatherer.gather(ticker, as_of)
            if context.has_critical_gaps():
                return Thesis.incomplete(ticker, as_of, context.gaps)

            # Step 2 — run 3 perspectives in parallel (Macro/Behavior/Manager = stub deferred)
            bear_t = self.bear_agent.analyze(ticker, context, role=PerspectiveRole.BEAR)
            bull_t = self.bull_agent.analyze(ticker, context, role=PerspectiveRole.BULL)
            quant_t = self.quant_agent.analyze(ticker, context, role=PerspectiveRole.QUANT)
            perspectives = await asyncio.gather(bear_t, bull_t, quant_t)

            # Step 3 — synthesize (preserves disagreement per I-S12)
            synthesis = await self.synthesizer.synthesize(ticker, perspectives, context)

            # Step 4 — heuristic recommendation + confidence (Phase 1 logic verbatim)
            rec = recommendation_from_synthesis(synthesis)
            conf = confidence_from_synthesis(synthesis)

            # Step 5 — build thesis (aggregate enforces I-S10 + I-S12)
            thesis_id = compute_thesis_id(model_id, prompt_hash, ticker, as_of, data_md5)
            thesis = Thesis(
                thesis_id=thesis_id, ticker=ticker, as_of=as_of,
                created_at=datetime.utcnow(), status=ThesisStatus.SUBMITTED,
                perspectives=tuple(perspectives), synthesis=synthesis,
                final_recommendation=rec, confidence_level=conf,
                cost_usd=budget.spent,
            )
            await self.thesis_repo.save(thesis)
            await self.event_bus.publish(ThesisRecorded(...))
            return thesis
```

## B.4 Ports (application layer)

```python
# packages/application/analysis/ports/llm_perspective_port.py
class LLMPerspectivePort(Protocol):
    async def analyze(
        self, ticker: Ticker, context: SharedContext, role: PerspectiveRole,
    ) -> PerspectiveAnalysis: ...

# packages/application/analysis/ports/cost_tracker_port.py
class CostTrackerPort(Protocol):
    def scoped_budget(self, limit_usd: Decimal) -> ContextManager[Budget]: ...
    async def record(self, usd: Decimal) -> None: ...
```

## B.5 System Prompts (verbatim ≥40 LOC each)

### B.5.1 BearAgent system prompt

```
You are a BEAR analyst for {TICKER} (Vietnamese stock market, HOSE/HNX/UPCoM).
Your role is ADVERSARIAL — not balanced. Your job is to find every credible reason
NOT to take a long position in this stock at the current price as of {AS_OF}.

You have read access to a SharedContext bundle containing:
- Bar history (last 365 days), TTM ratios computed by code (P/E, P/B, ROE, D/E)
- FinancialStatement (latest filed; point-in-time per as_of)
- Peer comparables across the same sector
- Recent news (last 90 days) with ExtractedClaim entries (sentiment + provenance)

HARD RULES (violations void your output):
1. NO LLM MATH. You NEVER produce a numeric value in your prose. If you need a
   ratio, percentage, growth rate, or any number — call the deterministic tool.
   Forbidden phrasings: "approximately X%", "around X%", "roughly X", "~X%",
   "about X%". The tool returns the exact number; you cite it verbatim.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT. No claim without grounding.
   The excerpt must be ≤500 chars verbatim from the context bundle.
3. MINIMUM 3 distinct bear points across at least 3 different categories chosen
   from {FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}.
   Three rephrasings of the same risk = one point, not three.
4. Each bear point declares conviction ∈ {STRONG, MODERATE, WEAK}.
5. Specific evidence only — no boilerplate ("real estate sector is cyclical" is
   boilerplate; "VHM Q4 net debt rose 18.3% sequentially per filing 2026-02-15" is
   specific).
6. Vietnamese-market-aware — Room ngoại saturation, Sàn-tier data quality,
   T+2.5 settlement, Đội lái pump signals — surface these when context warrants.
7. If after examining the context you cannot find ≥3 substantive bear points,
   state so explicitly. Do NOT manufacture boilerplate. "Insufficient bear case"
   is a valid honest output and triggers system PASS recommendation.

Output JSON matching PerspectiveAnalysis schema. Each key_point has:
  text, source_url, source_excerpt, as_of, conviction, category.

REMEMBER: this is a research aid, not financial advice. You are not predicting
prices. You are surfacing risks the user must investigate before any position.
```

### B.5.2 BullAgent system prompt

```
You are a BULL analyst for {TICKER} (Vietnamese stock market). Your role is
ADVOCACY — find every credible reason a long position might be reasonable at
the current price as of {AS_OF}, while remaining grounded.

You have read access to the same SharedContext bundle as the Bear analyst:
Bar history, TTM ratios from code, FinancialStatement point-in-time, peer
comparables, recent news + ExtractedClaim.

HARD RULES (violations void your output):
1. NO LLM MATH. NEVER produce a numeric value in prose. Call the deterministic
   tool for any number. Forbidden phrasings: "approximately X%", "around X%",
   "roughly X", "~X%", "about X%". Tool returns the exact value.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT (≤500 chars verbatim).
3. MINIMUM 3 bull points across categories chosen from {FUNDAMENTAL,
   GROWTH, VALUATION, COMPETITIVE, MACRO, NARRATIVE}. Distinct categories.
4. Conviction declared per point ∈ {STRONG, MODERATE, WEAK}.
5. Specific evidence — "company has good moat" is boilerplate; "company holds
   54% market share in segment X per FY2025 10-K p.42" is specific.
6. CATALYSTS section: list events that could trigger re-rating, with timeframe
   and likelihood. Each catalyst is a GroundedPoint.
7. Vietnamese-market-aware — surface foreign-flow trends, Room ngoại
   availability, sector tailwinds (credit cycle, regulatory) when present.
8. If you cannot find ≥3 substantive bull points (e.g., all data leans
   structurally negative), state so explicitly. Honest absence of bull case
   is acceptable and informs the synthesizer.
9. NEVER use "buy", "sell", "recommend", or "should". Frame as "consideration",
   "investigate further", "thesis exploration". You are not making a
   recommendation; you are surfacing reasons that warrant further investigation.

Output JSON matching PerspectiveAnalysis schema.

REMEMBER: research aid, not financial advice. Even a strong bull case is a
hypothesis to be falsified by the user, not a directive.
```

### B.5.3 QuantAgent system prompt

```
You are a QUANT analyst for {TICKER} (Vietnamese stock market). Your role is
NUMERICAL INTERPRETATION — read the deterministic ratios computed by code and
explain what they mean in context. You are NOT a calculator and NOT a forecaster.

You have read access to:
- Bar history TTM (last 365 days)
- TTM ratios pre-computed by RatioService (P/E, P/B, ROE, D/E, ROA, EBIT margin,
  net margin, current ratio, quick ratio, debt-to-equity, asset turnover)
- 5-year historical percentiles for each ratio (own history)
- Sector / peer averages for each ratio
- Margin of Safety vs DCF / Graham / peer-multiple fair value bands

HARD RULES (violations void your output):
1. ABSOLUTE NO LLM MATH. You receive the numbers. You DO NOT compute. You DO NOT
   estimate. You DO NOT round in prose. Forbidden phrasings: "approximately",
   "around", "roughly", "~ X%", "about", "circa". If you need a number not in
   the context, call the tool. The tool returns exact; you cite verbatim.
2. EVERY CLAIM CITES SOURCE_URL + SOURCE_EXCERPT (or `-- query: SQL` audit
   comment when the source is a deterministic database query).
3. Output structured: for each ratio in {P/E, P/B, ROE, D/E, Margin of Safety},
   produce a GroundedPoint with: current_value, sector_avg, 5yr_own_percentile,
   verdict ∈ {STRONG, NEUTRAL, WEAK}, interpretation (≤200 chars).
4. NEVER predict price. NEVER produce price targets. The Charter forbids price
   targets — system "predicts narrative phase", not price.
5. Surface the Margin of Safety verbatim from code. If MoS computation fails (e.g.,
   negative earnings → P/E undefined), state INSUFFICIENT_DATA explicitly.
6. Vietnamese-market-aware — VN P/E bands differ from developed markets;
   sector-specific norms (banking ROE typically 18-22%, BĐS varies wildly with
   land-bank cycle). Cite peer-comparable when available.
7. NEVER use "buy", "sell", "recommend". Frame: "ratio X at percentile Y suggests
   investigation into Z", "valuation appears stretched relative to 5-year own
   percentile" — interpretive, not directive.

Output JSON matching PerspectiveAnalysis schema with role=QUANT. Each key_point
covers one ratio family.

REMEMBER: research aid, not financial advice. Numbers come from code; you
interpret. If you ever feel tempted to compute or estimate — STOP. Call the
tool. The audit trail demands code-traceable numbers.
```

## B.6 Phase1DataGatherer (deterministic; no LLM)

```python
# packages/infrastructure/analysis/phase1_data_gatherer.py
class Phase1DataGatherer:
    async def gather(self, ticker: Ticker, as_of: date) -> SharedContext:
        # All point-in-time per I-S2
        quotes = await self.quote_repo.get_range_as_of(ticker, as_of - 365d, as_of)
        statements = await self.fundamental_repo.get_as_of(ticker, as_of)   # BC-2 S34
        ratios_ttm = self.ratio_service.compute_ttm(statements, quotes)     # BC-2 S34
        peers = await self.peer_service.get_comparables(ticker, sector=statements.sector)
        percentiles = self.ratio_service.compute_5yr_percentiles(ticker, ratios_ttm)
        recent_news = await self.news_repo.get_for_ticker(ticker, as_of - 90d, as_of)
        recent_claims = await self.claim_repo.get_for_ticker(ticker, as_of - 90d, as_of)

        gaps = []
        if not quotes or quotes[-1].period_end < as_of - timedelta(days=3): gaps.append("price_stale")
        if not statements or statements.filing_date < as_of - timedelta(days=180): gaps.append("fundamentals_stale")
        if len(recent_news) == 0: gaps.append("no_news_90d")

        return SharedContext(
            ticker=ticker, as_of=as_of, quotes=quotes, statements=statements,
            ratios_ttm=ratios_ttm, peer_comparables=peers, percentiles=percentiles,
            recent_news=recent_news, recent_claims=recent_claims, gaps=gaps,
            data_snapshot_md5=md5_of_context_payload(...),
        )
```

## B.7 Streamlit UI (apps/dashboard/)

```python
# apps/dashboard/pages/validate_thesis.py
import streamlit as st

st.title("Validate Investment Thesis (research aid)")
st.warning("Research aid — not financial advice. Decisions and responsibility are yours.")  # I-S35

ticker = st.text_input("Ticker", placeholder="HPG").upper().strip()
as_of = st.date_input("As of", value=date.today())

if st.button("Validate"):
    with st.spinner(f"Running {ticker} thesis (≤5 min, ≤$3 cost cap)..."):
        thesis = run(validate_thesis_usecase.execute(Ticker(ticker), as_of))
    render_thesis_card(thesis)
    st.caption(f"thesis_id: {thesis.thesis_id} · cost: ${thesis.cost_usd:.3f} · confidence: {thesis.confidence_level}")
```

## B.8 Cross-BC Events

```python
# packages/contracts/events/thesis_recorded.py
@dataclass(frozen=True, slots=True)
class ThesisRecorded:
    thesis_id: str
    ticker: Ticker
    as_of: date
    recommendation: Recommendation
    confidence_level: ConfidenceLevel
    cost_usd: Decimal
    recorded_at: datetime
```

Phase 2 uses synchronous in-process EventBus per architecture.md Phase 1+2 doctrine.

## B.9 Test Pyramid

| Level | Coverage | Location | Min count |
|---|---|---|---|
| Unit | aggregate invariants, value object validation, synthesizer logic | `packages/domain/analysis/test_*.py` | ≥25 |
| Unit | use case orchestration with mock LLM | `packages/application/analysis/test_use_case.py` | ≥10 |
| Integration | adapters (SQLite repo, mock-LLM perspective adapter) | `packages/infrastructure/analysis/test_*.py` | ≥10 |
| Smoke | CLI Click smoke; Streamlit testapi | `apps/{cli,dashboard}/test_*.py` | ≥5 |

Critical cases:
1. Bear case <3 points → `BearCaseInvariantError` raised at `Thesis.submit()`
2. Bear case 3 points but only 2 categories → `BearCaseInvariantError` raised
3. Disagreement detected → `Synthesis.explicit_disagreements` non-empty AND `final_recommendation == INVESTIGATE`
4. Cost cap $1 in test → `CostBudgetExceeded` raised mid-execution; partial Thesis NOT persisted
5. Reproducibility — re-run same `(ticker, as_of)` with same seed → identical `thesis_id` + identical `Thesis` payload
6. LLM-math grep `r"approximately|around|roughly|~ \d+%"` in `packages/{domain,application,infrastructure}/analysis/`: 0 hits

NO LIVE LLM IN CI. All perspective tests use `MockLLMPerspectivePort` returning fixture JSON per role.

## B.10 Cost Profile

Per validation (target):
- Bear (Sonnet, ~20K tokens): $0.10
- Bull (Sonnet, ~20K tokens): $0.10
- Quant (Opus, ~25K tokens): $0.70  ← SCOPE-tier user-gate; alternative Sonnet $0.20
- Synthesizer (Opus, ~15K tokens): $0.40
- DataGatherer: $0.00 (deterministic)
- **Target average: $0.90 per thesis (S42 actual measurement; was $1.30 estimated; amended D-S43c-Q9 2026-05-04)**
- **Hard cap: $3.00 per validation (I-40 + AC-1)**

> **Amendment 2026-05-04 (Q9=A)**: Phase1Synthesizer is fully deterministic per § A.6.1 (no LLM call → $0 contribution from synthesizer step). Actual S42 measurement = $0.90/thesis vs $1.30 estimate (~31% cheaper). Future Q9-style amendments may further drop toward "$0 marginal" as Q7=a SubagentLLMPerspectiveAdapter pivot lands per D-023 cost-substrate charter (subagent dispatch billed against Claude Code subscription).

Monthly at 20 validations = $18-60 (low-end revised). Within charter personal budget envelope.

5-thesis dogfood at S43a: ≤$10 total (revised; was $15); session hard-cap $20.

## B.11 Implementation Constraints

### MUST (hard binding)
- Domain layer (`packages/domain/analysis/`) zero framework imports — dataclasses + stdlib + Enum only
- Cross-BC types via `packages/contracts/` only (Ticker imported from contracts; PerspectiveAnalysis stays in BC-8 domain)
- Every `GroundedPoint` has non-empty `source_url` + `source_excerpt` + `as_of`
- Every numeric output traces to deterministic Python tool call (I-S1)
- `Thesis.submit()` enforces ≥3 distinct bear points (I-S10)
- `Synthesis` preserves disagreement; never collapses (I-S12)
- Output framing: research aid, not financial advice (I-S35)
- Cost tracker enforces $3 cap per execute() (I-40)
- LLM `temperature=0.0`; model_id + prompt_hash recorded in Thesis (AC-5 reproducibility)

### MUST NOT
- LLM call without budget cap
- Number in prose without tool-call provenance
- Direct cross-BC import (use packages/contracts/ shared kernel)
- Pydantic in domain layer (dataclasses only)
- Single scalar score output (multi-dimensional trade-off matrix only — I-S52)
- Vote-average to HOLD on disagreement (preserve per I-S12)
- "Buy" / "sell" / "recommend" verbs in user-facing output (I-S35)
- Live LLM in CI test suite

### SHOULD
- Prompt caching for stable system-prompt portion (Anthropic SDK feature) — saves ~30% on Bear/Bull
- Sonnet for Bear/Bull (cost); Opus for Quant + Synthesizer (reliability)
- Reuse BC-5 `claude_llm_extractor.py` patterns for `claude_llm_perspective_adapter.py` (S36 reference)

## B.12 Verification Checklist

- [ ] Part A reviewed
- [ ] All 7 ubiquitous_language_terms in glossary (S42 entry runs /drill-me incremental for 5 NEW terms)
- [ ] A.10 Data Provenance complete
- [ ] A.11 Adversarial Check complete (`produces_thesis_output: true`)
- [ ] VBW pre-flight before each NEW file write at S42 (per L-S30-1 / BP-S30-1)
- [ ] Unit tests green: `pytest packages/domain/analysis/ packages/application/analysis/ packages/infrastructure/analysis/`
- [ ] LLM-math grep 0 hits in production code
- [ ] Bear case ≥3 points + ≥3 categories enforced
- [ ] Disagreement preserved (test fixture reproduces opposing-conclusion case)
- [ ] Cost tracker enforced (test with $1 cap raises CostBudgetExceeded)
- [ ] Reproducibility (re-run same input → identical thesis_id)
- [ ] I-S35 disclaimer present in Streamlit + CLI + thesis-log file
- [ ] Personal-risk-profile.md prerequisite acknowledged (default = charter-floor if unfilled)

---

# PART C — PROVENANCE & REVIEW

## C.1 Authoring History

| Date | Author | Change | Rationale |
|---|---|---|---|
| 2026-05-01 | Claude Opus 4.7 (S41 sandwich-architect) | Initial v1.0 | Phase 2 Track F architect deliverable per master-plan 005 § S41 |

## C.2 Decision Provenance

- A.6.1 Phase 1 heuristic recommendation logic preserved → spec 001 § B.3
- A.6.2 SQLite for ThesisRepository → Phase 1 doctrine (000-phase-1-thin-slice-VHM § A.6.2)
- A.6.3 Sonnet/Opus mix → spec 001 § B.10 cost profile + D-014 § Open Questions Quant model gate
- A.6.4 Streamlit choice → spec 001 § B.7

## C.3 Reviews

| Date | Reviewer | Decision | Comments |
|---|---|---|---|
| 2026-05-01 | S41 sandwich-architect | DRAFT | Pending S42 dev consumption |
