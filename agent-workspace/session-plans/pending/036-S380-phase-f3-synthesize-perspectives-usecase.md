---
plan_id: 036-S380-phase-f3-synthesize-perspectives-usecase
target_session: S381 (sandwich-dev FOCUSED_IMPL; S382 sandwich-verifier AP-1 follows)
type: PLAN (sub-plan author = sandwich-architect; one of the 5 F-prime sub-plans per master plan-033 § E)
budget: ~150-200K Opus PLAN authoring envelope THIS session (architect); IMPL S381 100-150K FOCUSED_IMPL Opus (single session preferred; SPLIT to S381+S382 only if STEP 0.5 STOP-AND-ASK triggers — see § C.5); VERIFY S382 30-60K Opus AP-1 fresh-context
phase: F-prime sub-track F.3 (BC-8 N-Perspective Synthesizer + ValidateThesisPhase1UseCase Generalization)
track: Wave 1 Theme H — Multi-perspective adversarial extension (per master plan-033 § E.3)
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md § E.3
predecessor: 035-S377-phase-f2-personas-buffett-graham-taleb (F.2 SHIPPED — 3 persona adapters + 3 JSON role-packs + tests; PerspectiveRole +3 = BUFFETT/GRAHAM/TALEB; per S378 close-bookkeeping)
predecessor_2: 034-S374-phase-f1-rolepromptpack-and-transport-flip (F.1 SHIPPED — RolePromptPack + PersonaRegistry + BC-8 transport-flip; per S375 close-bookkeeping + ADR D-074 PROPOSED)
successor_candidates: 037-S383-phase-f4-v0-expansion (NON-BLOCKING; V0=6 default OR V0=9 ratified) + 038-S384-phase-f5-cli-dogfood (parallel-eligible with 037 per master plan § E.5+E.4)
architect: S380 sandwich-architect (background; THIS plan-authoring session)
dispatched_by: main session orchestrating Phase F-prime per master plan § E.3 sequencing (F.1 + F.2 both SHIPPED; F.3 now unblocked)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **n=2 multi-perspective-impl precedent declared** — see § L)
executing_agent: N/A this session (architect); S381 sandwich-dev executes per § E sub-tracks D1-D5
status: pending-execution (Phase F-prime § E.3 sub-plan; main session reviews + dispatches S381 sandwich-dev FOCUSED_IMPL after this plan ratified)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward)"

depends_on:
  - "F.1 SHIPPED (S375 + S376 verifier; ADR D-074 PROPOSED) — RolePromptPack frozen dataclass at packages/application/analysis/role_prompt_pack.py:33-103 + PersonaRegistry stdlib dict wrapper at packages/application/analysis/persona_registry.py:39-156 + BC-8 transport-flip default to claude_cli_transport per claude_llm_perspective_adapter.py (anthropic import REMOVED; D-052 § Implementation step 1 CLOSED for BC-8)"
  - "F.2 SHIPPED (S377 + S378 verifier; ADR D-075 PROPOSED) — 3 persona adapters at packages/infrastructure/analysis/perspectives/{buffett,graham,taleb}_agent.py (BuffettPerspectiveAgent + GrahamPerspectiveAgent + TalebPerspectiveAgent each ~250-310 LOC mirroring bear_agent retry-validator at lines 198-334) + 3 V0 JSON role-packs at agent-workspace/role-packs/{buffett,graham,taleb}.json + PerspectiveRole +3 (BUFFETT/GRAHAM/TALEB) at packages/domain/analysis/models/perspective_analysis.py:41-43"
  - "master plan-033 DD-10 (F.3 = EXTEND existing ValidateThesisPhase1UseCase NOT new use case) + DD-3 (V0 ISOLATED-THEN-AGGREGATE; parallel fan-out per asyncio.gather pattern) + DD-12 (per-persona model routing preserved)"
  - "Existing BC-8 pipeline at packages/application/analysis/use_cases/validate_thesis_phase1.py:142-289 (7-step pipeline; bear_agent+bull_agent+quant_agent hardcoded ctor params + asyncio.gather(bear_t, bull_t, quant_t) at :221 + perspectives tuple (bear_p, bull_p, quant_p) at :226 + budget.add(sum cost_usd) at :224)"
  - "Existing Phase1Synthesizer at packages/infrastructure/analysis/phase1_synthesizer.py:102-261 (deterministic Python aggregation; BEAR/BULL/QUANT-named lookup at :121-123 + per-dim disagreement detection at :134-187 + Confluence + Synthesis construction; NO LLM)"
  - "Existing recommendation_heuristic at packages/application/analysis/services/recommendation_heuristic.py:36-85 (pure-deterministic Synthesis→Recommendation+ConfidenceLevel pipeline; BR-7; ALREADY N-perspective-agnostic by-construction — consumes Synthesis not perspectives tuple)"
  - "Existing test_use_case.py at packages/application/analysis/test_use_case.py (≥10 tests per S43-deliverable-23; MockLLMPerspectivePort + MockSynthesizer + MockThesisRepo + MockCostTracker + happy-path/incomplete/bear-insufficient/reproducibility coverage)"
  - "Existing test_synthesizer.py at packages/infrastructure/analysis/test_synthesizer.py (≥6 tests per S43-deliverable-24; disagreement-detection + Confluence path coverage; key fixtures _make_point/_make_perspective)"
  - "Existing apps/_shared/use_case_builder.py composition root (build_use_case wires bear_agent+bull_agent+quant_agent into ValidateThesisPhase1UseCase; _build_subagent_agents + _build_mock_agents return 3-tuple; PRESERVED for backward-compat; F.3 EXTENDS not replaces)"
  - "I-S1 (NO LLM math — aggregation deterministic; per-persona LLM emits ONLY categorical+reasoning+GroundedPoint) + I-S1-1 Rule 16 mode 1 categorical surrogate via Conviction StrEnum + Rule 16 mode 2 deterministic-pipeline echo via recommendation_heuristic"
  - "I-S10 (bear case substantive ≥3 distinct points + ≥3 distinct categories — enforced at Thesis._enforce_bear_case at thesis.py:91-115; F.3 PRESERVES — N-persona path STILL requires PerspectiveRole.BEAR present in perspectives tuple)"
  - "I-S12 (Disagreement Surfaced, Not Resolved — enforced at Synthesis.__post_init__ at synthesis.py:89-100; F.3 PRESERVES — N-perspective disagreement detection extends pairwise without bypassing invariant)"
  - "I-S35 (research-aid framing — Recommendation enum INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE NOT buy/sell; F.3 PRESERVES — aggregate output unchanged)"
  - "AC-5 reproducibility (thesis_id = sha256(model_id + combined_prompt_hash + ticker + as_of + data_md5) at validate_thesis_phase1.py:127-139; combined_prompt = ':'.join(p.prompt_hash for p in perspectives) at :238 — ALREADY N-perspective-agnostic by-construction; F.3 PRESERVES + adds regression-test for N>3 deterministic-per-tuple validation)"
  - "D-054 (retry-validator pattern at agent-internal level — bear_agent + buffett_agent + graham_agent + taleb_agent all 3-attempt retry; F.3 PRESERVES — per-agent retry continues to live in adapter not use case)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain — BINDING for any new file in F.3)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for sub-plan dev commit boundary)"
  - "D-074 (BC-8 Transport Flip + RolePromptPack Foundation — F.1 ADR PROPOSED at S375; informational precedent for F.3 N-persona dispatch retains transport via adapter unchanged)"
  - "D-075 (BC-8 First 3 Personality-Pack Adapters — F.2 ADR PROPOSED at S378; F.3 CONSUMES these 3 personas as concrete LLMPerspectivePort instances)"
  - "DD-10 from F.2 plan-035 (pattern-port NOT code-port; 50+ char substring grep gate carries forward — F.3 architect MUST NOT copy verbatim from ai-hedge-fund portfolio_manager.py/risk_manager.py beyond pattern-port)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Aggregate pattern — Synthesis aggregate-root invariants; Repository pattern — ThesisRepository persists Thesis)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline; per-persona adapter dispatches via existing adapter unchanged in F.3)"

binding_decisions:
  - "EXTENSION NOT PARALLEL-CLASS — F.3 IMPL extends existing ValidateThesisPhase1UseCase (NOT new SynthesizePerspectivesUseCase class) per master plan-033 DD-10; alternate REJECTED per master plan DD-10 § Adversarial alternate (duplicate orchestration logic)"
  - "N-PERSONA DISPATCH SHAPE = dict[PerspectiveRole, LLMPerspectivePort] (NOT sequence-of-agents tuple) per § D DD-1 below — dict keyed by PerspectiveRole enum matches existing role-routing pattern at claude_llm_perspective_adapter.py:72-76 _ROLE_TO_MODEL; allows N>3 personas to be wired by adding dict entries without ctor signature churn"
  - "BACKWARD-COMPAT MANDATORY — composition root apps/_shared/use_case_builder.py at lines 100-135 CONTINUES to wire bear_agent+bull_agent+quant_agent into the use case (NEW signature accepts dict but `build_use_case` constructs dict {BEAR: bear, BULL: bull, QUANT: quant} internally); existing test_use_case.py tests still construct MockLLMPerspectivePort per role; ZERO regression at use_case_builder.py + test_use_case.py existing test count"
  - "PHASE1SYNTHESIZER ROLE-AWARE EXTENSION (NOT REWRITE) — Phase1Synthesizer.synthesize() at phase1_synthesizer.py:111-261 EXTENDED to handle N>3 personas; BEAR + BULL still required + present in detection logic; new persona roles (BUFFETT/GRAHAM/TALEB) treated as ADDITIONAL evidence-providers feeding the existing dimension-bucket aggregation; per § D DD-3 architect leans MAJORITY-CATEGORICAL aggregation for new personas (NOT weighted-by-conviction; F.3-V2 refinement)"
  - "I-S10 BEAR-PRESENCE INVARIANT PRESERVED — Thesis._enforce_bear_case at thesis.py:91-115 STILL requires PerspectiveRole.BEAR in perspectives; F.3 N-persona path validates this remains true; F.3 PLAN explicitly disallows the dev from removing BEAR-presence check"
  - "I-S12 DISAGREEMENT INVARIANT PRESERVED — Synthesis.__post_init__ at synthesis.py:89-100 untouched; F.3 N-perspective synthesizer respects STRONG_CONSENSUS + non-empty disagreements = bug invariant"
  - "AC-5 REPRODUCIBILITY MANDATORY — thesis_id at validate_thesis_phase1.py:127-139 uses combined_prompt = ':'.join(p.prompt_hash for p in perspectives) at :238 (sort-preserving by perspectives tuple order); F.3 N-persona path MUST preserve deterministic-per-tuple semantics; regression test asserts same input → same thesis_id across N=3 + N=4 + N=5 + N=6 paths"
  - "BUDGET ENVELOPE PRESERVED — scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:187-189 unchanged; per-persona cost.add() accumulation extended to sum across N personas (not 3 hardcoded); per-persona model routing per master plan-033 DD-12 (Sonnet for value-investors; Opus for QUANT) preserved at adapter layer"
  - "I-S1 BY-CONSTRUCTION POSTURE — per-persona LLM emits categorical + reasoning + GroundedPoint (existing PerspectiveAnalysis schema); Phase1Synthesizer aggregation = pure deterministic Python (existing pattern); recommendation_heuristic = pure deterministic Python; aggregate confidence_level = Rule 16 mode 2 deterministic-pipeline echo; NO LLM in any aggregation step"
  - "DD-10 from F.2 (pattern-port NOT code-port) CARRY-FORWARD — F.3 architect MUST NOT copy verbatim from ai-hedge-fund portfolio_manager.py:160-175 (50+ char substring grep gate); F.3 ADOPTS the PATTERN (aggregate-sees-only-{role: signal} table) but RE-IMPLEMENTS with stockforge primitives (PerspectiveRole + Conviction + GroundedPoint instead of agent_id + signal_str + confidence_int)"
  - "VBW protocol mandatory — every architect claim cites file:line; dev STEP 0 re-verifies before any edit (per master plan-033 hard_rules_acknowledged)"
  - "Karpathy P3 surgical-changes — Phase1Synthesizer extension adds ≤80 LOC delta (NOT >500 LOC rewrite); ValidateThesisPhase1UseCase ctor signature change ≤30 LOC delta (NEW agents dict param + backward-compat constructor); tests ≥15 NEW cases per § F DoD"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; architect tools: [Read, Glob, Grep, Write])"
  - "no commits in THIS plan-session by architect (sandwich-architect has no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching F.1/F.2 shipped files unless EXTENDING THEIR CALLERS — RolePromptPack/PersonaRegistry/buffett_agent/graham_agent/taleb_agent are LEAF dependencies; F.3 IMPL only modifies validate_thesis_phase1.py + phase1_synthesizer.py + their test files + composition-root use_case_builder.py"
  - "no harness/hook changes — F.3 ships product substrate (N-persona aggregation); surface any harness gaps in observation; do NOT fix here"
  - "no NEW HTTP fetcher — F.3 consumes existing SharedContext bundle gathered by existing Phase1DataGatherer (validate_thesis_phase1.py:210); I-S34 carry-forward N/A"
  - "no F.4/F.5 entry from THIS plan — F.4 dispatch (V0=6 default OR V0=9 ratified) + F.5 CLI dogfood are independent sub-plans 037/038 per master plan § E"
  - "no Charter amendment SHIP from THIS plan — IF F.3 IMPL surfaces a tie-breaker invariant gap OR confluence-calculation ambiguity, sub-plan 036 STEP 0 STOP-AND-ASK fires + master session dispatches ratification gate per master plan § K.2 (NOT this plan author)"
  - "every plan claim cites source file:line"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "ai-hedge-fund LICENSE-file caveat per A-01 § 6 + master plan DD-10 carry-forward — pattern-port NOT code-port (50+ char substring grep gate applies if architect writes example code)"
---

# S380 — Phase F.3 SynthesizePerspectivesUseCase + Composition Root Wiring (PLAN)

> **One-sentence intent**: Extend the existing `ValidateThesisPhase1UseCase` and `Phase1Synthesizer` to handle N≥4 personas (V0=6: BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB) via dict-typed agent param + role-aware aggregation, preserving I-S10/I-S12/AC-5 invariants + backward-compat with existing 3-persona pipeline + 3-persona composition root, without bundling F.4 expansion or F.5 CLI dogfood (separate sub-plans per master plan § E).

---

## A. Goal & Scope

### A.1 Goal

Ship the **N-perspective aggregation pipeline** that combines the V0=6 perspectives (BEAR/BULL/QUANT already shipped at S43 + BUFFETT/GRAHAM/TALEB shipped at S378 via F.2) into a single `Synthesis` aggregate + `Recommendation` + `ConfidenceLevel`, where:

- **Input**: `ValidateThesisPhase1UseCase` accepts `agents: dict[PerspectiveRole, LLMPerspectivePort]` (NEW; replaces 3 hardcoded ctor params) AND `synthesizer: Phase1Synthesizer` (existing; extended internally for N-perspective aggregation)
- **Process**: Parallel fan-out via `asyncio.gather(*[agent.analyze(...) for agent in agents.values()])` (per master plan-033 DD-3 ISOLATED-THEN-AGGREGATE; per A-01 § 5 third-bullet WAVE-1 DEFAULT pattern); per-persona retry-validator continues to live in adapter (unchanged); Phase1Synthesizer aggregates N perspectives into TradeOffMatrix + Confluence + Disagreements
- **Output**: `Synthesis` aggregate with non-empty trade_off_matrix + explicit_disagreements (≥1 if any pairwise persona disagreement on any dimension; preserves I-S12) + catalysts + risks; `Thesis` aggregate with `final_recommendation: Recommendation` enum + `confidence_level: ConfidenceLevel` enum (per Rule 16 mode 2 deterministic-pipeline echo via `recommendation_heuristic`)
- **Bear case I-S10**: bear perspective MUST be present + emit ≥3 distinct points + ≥3 distinct categories (existing invariant at `thesis.py:91-115` preserved; F.3 N-persona path validates BEAR-presence remains true)
- **AC-5 reproducibility**: `thesis_id = sha256(model_id + combined_prompt_hash + ticker + as_of + data_md5)` where `combined_prompt_hash = ':'.join(p.prompt_hash for p in perspectives)` preserved; same input + same N personas + same ordering → same thesis_id
- **Composition root wiring**: `apps/_shared/use_case_builder.py:55-135` extended to wire all V0=6 perspectives (3 existing + 3 new) into use_case via dict construction; backward-compat shim so existing callers that pass 3-persona args don't break (gracefully)

### A.2 In-scope (this sub-plan ships)

This sub-plan ships:

1. **D1 — ValidateThesisPhase1UseCase signature extension** (target: REFACTOR `packages/application/analysis/use_cases/validate_thesis_phase1.py:153-171` ctor + :206-229 `_run_pipeline`; ~30 LOC delta)
2. **D2 — Phase1Synthesizer role-aware N-perspective extension** (target: EDIT `packages/infrastructure/analysis/phase1_synthesizer.py:102-261` to dispatch on PerspectiveRole + accept N>3 perspectives; ~80 LOC delta)
3. **D3 — Composition root wiring** (target: EDIT `apps/_shared/use_case_builder.py:55-135` to construct V0=6 agents dict; ~50 LOC delta — adds `_build_persona_agents()` for 3 new personas + dict construction)
4. **D4 — Regression-focused test additions** (target: NEW tests in `packages/application/analysis/test_use_case.py` + `packages/infrastructure/analysis/test_synthesizer.py`; ≥18 NEW unit tests for N=4/5/6 paths + I-S10/I-S12/AC-5 regression; existing test count preserved)
5. **D5 — ADR D-076 PROPOSED at IMPL tier** (target: NEW `agent-workspace/memory/decisions/076-bc-8-n-perspective-synthesizer-and-use-case-generalization.md` ~200 LOC documenting N-persona dispatch shape + role-aware Phase1Synthesizer extension + AC-5 regression strategy + master plan DD-10 alignment)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| F.4 V0 expansion to V0=9 (Munger/Lynch/VN_DOMAIN_SPECIALIST personas) | Separate sub-plan 037 per master plan § E.4; NON-BLOCKING charter-tier gate (architect-recommended V0=6 default; V0=9 user-ratification optional) | Sub-plan 037 dispatch after THIS plan IMPL+VERIFY closes; Q-INT-2026-05-F-prime-1 user-pick OR architect-recommended V0=6 NO-OP default |
| F.5 CLI dogfood thesis on VHM (or alternate) | Separate sub-plan 038 per master plan § E.5; parallel-eligible with 037 post-F.3 ship | Sub-plan 038 dispatch after THIS plan IMPL+VERIFY closes; can dogfood with V0=6 immediately post-F.3 OR wait for V0=9 if ratified |
| Weighted-by-conviction confluence calculation (vs MAJORITY-CATEGORICAL) | F.3 V0 ships MAJORITY-CATEGORICAL aggregation per § D DD-3; weighted-by-conviction is F.3-V2 refinement per master plan § E.3 DD-10 | F.3-V2 trigger: V0 dogfood (F.5) reveals MAJORITY-CATEGORICAL produces empirically-poor confluence on 3+ different VN tickers (e.g. 3-3 tie collapses to MIXED when STRONG_CONSENSUS-with-1-dissenter would be more informative) |
| Per-persona calibration_grade in PerspectiveAnalysis | Charter Principle 8 calibration-over-confidence — per-persona calibration is post-MVP; V0 ships with calibration_grade='D' on Thesis aggregate (existing field at thesis.py:83) | Calibration trigger: n≥50 thesis outcomes per-persona across 3+ months wall-clock — post-MVP per master plan § A.3 row 2 |
| Debate-style rebuttal cycle between perspectives | Master plan DD-3 INVERTS H.3 supplement verdict for V0; ISOLATED-THEN-AGGREGATE is V0 default per A-01 § 5 third bullet + master plan AP-7 revisit trigger | Debate trigger: V0 dogfood produces shallow disagreement on 3+ tickers (per-persona verdicts converge artificially without rebuttal); revisit Phase F-prime-V2 |
| New `SynthesizePerspectivesUseCase` class parallel to ValidateThesisPhase1UseCase | Master plan DD-10 explicit: EXTEND existing use case NOT new class (duplicate orchestration logic; F.3 ships ONE use case handling 3+N personas via dict-typed agents param) | N/A — design rejected at master plan tier |
| Sequence-of-agents tuple param (vs dict[PerspectiveRole, LLMPerspectivePort]) | § D DD-1 below selects dict — role-keyed lookup matches existing _ROLE_TO_MODEL pattern; tuple-of-agents requires order convention that's brittle (agent positions ≠ role positions if user reorders) | Trigger: empirical evidence that dict adds friction (e.g. multi-instance same-role personas like "BUFFETT_VARIANT_1" + "BUFFETT_VARIANT_2") — F.3-V3 refinement |
| Streamlit dashboard surface for N-persona output | Phase H-prime work per master plan § 6.4.5; F.5 CLI dogfood is V0 sufficient | Streamlit trigger: Phase 2 dashboard work entry |
| Confluence calculation new I-S<N> invariant for tie-breaker rule | F.3 V0 confluence calculation extends per-dim disagreement detection symmetrically (pairwise across N personas); if 3-3 ties surface in dogfood, sub-plan 036 STEP 0 STOP-AND-ASK fires per master plan § K.2 | Master plan § K.2 — IF Phase1Synthesizer N-perspective surfaces ambiguity (3-3 tie across STRONG_CONSENSUS vote with mixed verdicts), CANDIDATE CHARTER-TIER FLAG; STOP-AND-ASK |
| New Synthesis aggregate field (e.g. `participating_personas: tuple[PerspectiveRole, ...]`) | Existing Synthesis fields at synthesis.py:69-87 are sufficient for V0 (TradeOffMatrix.evidence captures per-dim GroundedPoints across all personas) | Field-extension trigger: F.5 dogfood reveals need for per-persona attribution at aggregate level (e.g. "GRAHAM dissented on VALUE dimension"); F.3-V2 refinement |
| Async migration of Phase1Synthesizer.synthesize() | Already async (returns awaitable per use case `await self._synthesizer.synthesize(...)` at validate_thesis_phase1.py:229); no new async migration needed | N/A — pre-shipped |
| New event for N-persona thesis emission (vs ThesisRecorded existing) | ThesisRecorded event at validate_thesis_phase1.py:274-285 is N-persona-agnostic by-construction (records thesis_id + ticker + as_of + recommendation + confidence + cost); no new event needed for F.3 | Event-extension trigger: F.5+ dogfood demands per-persona event emission for audit; F.3-V2 |
| Per-persona timeout-budget override (vs use-case-level $3.00 scoped_budget) | Existing scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:187 is cumulative across N personas; per-persona timeout already at agent-internal retry-validator (D-054 3-attempt loop with adapter-side timeout) | Per-persona timeout trigger: F.5 dogfood reveals one slow persona starves remaining (e.g. TALEB tail-risk reasoning chain > 60s); F.3-V2 budget refinement |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; n=2 multi-perspective-impl precedent declared)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):
- `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (§ E.3 sub-plan 036 stub at :516-529 + § D DD-10 F.3 use case extension at :429-446 + § D DD-3 V0 ISOLATED-THEN-AGGREGATE at :305-321 + § D DD-1 PHASE-MASTER-PLAN rationale at :271-281 + § H 5-source-evidence + § J RM5 BC-8 test regression at :693-695 + § K.2 sub-plan 036 anticipated FLAGS at :770-771 + § L plan-vs-master-plan rationale at :799-825)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (full read 290 LOC; ValidateThesisPhase1UseCase ctor at :153-171 + execute() at :173-204 + _run_pipeline at :206-289; **3 hardcoded perspective ctor params + asyncio.gather(bear_t, bull_t, quant_t) at :218-221 + perspectives tuple (bear_p, bull_p, quant_p) at :226 + budget.add(bear_p.cost_usd + bull_p.cost_usd + quant_p.cost_usd) at :224 + combined_prompt = ':'.join(p.prompt_hash for p in perspectives) at :238 — N-persona refactor surface mapped**)
- `packages/infrastructure/analysis/phase1_synthesizer.py` (full read 261 LOC; Phase1Synthesizer.synthesize() at :111-261; **BEAR/BULL/QUANT-named lookup at :121-123 via `next((p for p in perspectives if p.role == PerspectiveRole.X), None)` — N-persona refactor surface mapped + per-dim disagreement detection at :134-187 verdict-vs-narrative both pairwise BEAR-vs-BULL only**)
- `packages/application/analysis/services/recommendation_heuristic.py` (full read 85 LOC; pure-deterministic Synthesis→Recommendation+ConfidenceLevel pipeline; **ALREADY N-persona-agnostic by-construction** — consumes Synthesis not perspectives tuple; no F.3 modification needed)
- `packages/domain/analysis/models/perspective_analysis.py` (full read 65 LOC; PerspectiveAnalysis dataclass + PerspectiveRole 9-value StrEnum — BEAR/BULL/QUANT/MACRO/BEHAVIOR/MANAGER + F.2 additions BUFFETT/GRAHAM/TALEB at :41-43)
- `packages/domain/analysis/models/synthesis.py` (full read 100 LOC; Synthesis aggregate + Confluence StrEnum + Disagreement dataclass + SynthesisInvariantError I-S12 invariant at :89-100)
- `packages/domain/analysis/models/thesis.py` (full read 146 LOC; Thesis aggregate root + BearCaseInvariantError + ThesisStatus + _enforce_bear_case I-S10 invariant at :91-115)
- `packages/domain/analysis/value_objects/grounded_point.py` (full read 71 LOC; GroundedPoint invariants source_url + source_excerpt + as_of + conviction + category)
- `packages/domain/analysis/value_objects/conviction.py` (full read 22 LOC; Conviction StrEnum STRONG/MODERATE/WEAK — categorical surrogate per Rule 16 mode 1)
- `packages/domain/analysis/value_objects/recommendation.py` (full read 26 LOC; Recommendation StrEnum INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE — I-S35 research-aid framing)
- `packages/domain/analysis/value_objects/trade_off_matrix.py` (full read 49 LOC; DIMENSIONS = (VALUE, QUALITY, GROWTH, RISK) + DimensionVerdict STRONG/NEUTRAL/WEAK + TradeOffMatrix scores + evidence dicts)
- `packages/application/analysis/ports/llm_perspective_port.py` (full read 52 LOC; LLMPerspectivePort Protocol — `async analyze(ticker, context, role) → PerspectiveAnalysis`; ALREADY N-persona-agnostic by-construction)
- `packages/application/analysis/role_prompt_pack.py` (full read 102 LOC; RolePromptPack frozen dataclass + 10 fields + 9 invariants — F.1 substrate consumed by F.2 adapters; F.3 does NOT directly consume but persona_registry indirectly enables N-persona)
- `packages/application/analysis/persona_registry.py` (full read 156 LOC; PersonaRegistry stdlib dict wrapper; F.1 substrate)
- `packages/infrastructure/analysis/perspectives/buffett_agent.py` (full read 308 LOC; F.2 SHIPPED — BuffettPerspectiveAgent mirroring bear_agent retry-validator + role_pack DI)
- `packages/infrastructure/analysis/perspectives/graham_agent.py` (read first 100 LOC; F.2 SHIPPED — same shape as buffett_agent)
- `packages/infrastructure/analysis/perspectives/bear_agent.py` (read offset 198-327; existing retry-validator pattern + SYSTEM_PROMPT inline)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (read offset 1-100; ClaudeLLMPerspectiveAdapter post-F.1 transport-flip; _ROLE_TO_MODEL routing at :72-76 BEAR/BULL/QUANT only — NOT YET extended with BUFFETT/GRAHAM/TALEB explicit entries; falls through to _DEFAULT_MODEL Opus per :77 — F.3 does NOT modify but architect FLAGS the asymmetry per § J RM3)
- `packages/application/analysis/test_use_case.py` (read first 290 LOC; existing ≥10 tests + MockLLMPerspectivePort + MockSynthesizer + MockThesisRepo + MockCostTracker + MockDataGatherer + _make_use_case ctor helper passes bear_agent+bull_agent+quant_agent — F.3 test fixture extension surface mapped)
- `packages/infrastructure/analysis/test_synthesizer.py` (read first 80 LOC; existing ≥6 tests + _make_point + _make_perspective + _MockContext + Phase1Synthesizer instantiation; F.3 N-persona test extension surface mapped)
- `apps/_shared/use_case_builder.py` (full read 428 LOC; build_use_case at :55-135 wires bear_agent+bull_agent+quant_agent into ValidateThesisPhase1UseCase + _build_subagent_agents at :138-176 + _build_mock_agents at :200-261 — F.3 composition root extension surface mapped)
- `agent-workspace/memory/.planner-stats.tsv` (header-only at S380 entry; planner-feedback-loop.sh infrastructure gap STILL not fixed — n=2 multi-perspective-impl precedent declared from sessions-rollup tracking; carry-forward of M-S360/M-S363/M-S366/L-S354-2/L-S366-4/L-S369-1 cascade per master plan-033 § A.4)
- `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (full read 104 LOC; § 2 LangGraph StateGraph + ANALYST_CONFIG dict + per-agent Pydantic + deterministic-then-LLM split + portfolio_manager pre-validated allowed-actions + risk_manager vol-adjusted limit; § 5 third bullet ISOLATED-THEN-AGGREGATE EMPIRICALLY CONFIRMED; § 6 LICENSE-file MISSING caveat)
- `.claude/agents/sandwich-architect.md` (full read; architect template L42-65 Phase 1b mandate + L207-210 observation mandate)
- `agent-workspace/memory/current-execution.md` (read first 200 LOC; recent context S375 F.1 IMPL + S378 F.2 IMPL close per master plan § E.1+E.2)

**Calibration parameters extracted**:

- **task_class**: `multi-perspective-impl` (NEW class established post-S378; n=2 declared per S375 F.1 IMPL DONE + S378 F.2 IMPL DONE — both shipped clean per S375 + S378 close-bookkeeping)
- **sample_size**: **2** (S375 F.1 + S378 F.2) — n=2 narrow precedent declared per dispatch brief
- **avg_wall_min observed** from precedent:
  - S375 F.1 IMPL: ~30-45 min wall-clock per master plan § E.1 estimate (actual: per S375 row "S375 sandwich-dev RETURN" wall-min not explicitly stated but plan-034 D1-D5 COMPLETE single session)
  - S378 F.2 IMPL: ~35-50 min wall-clock per master plan § E.2 estimate (actual: per S378 close-bookkeeping single session shipped 3 personas + 3 role-packs + tests)
  - Median ~40 min wall-clock per multi-perspective-impl sub-track
- **avg tokens_real** from precedent: n=2 sub-tracks both shipped within Sonnet/Opus FOCUSED_IMPL envelope 100-150K per CLAUDE.md § Session Types; F.3 expected SLIGHTLY HIGHER token usage due to (a) refactor surface 3 files vs F.1's 2-3 + F.2's 3-files-each-leaf, (b) AC-5 regression test design more complex than F.2's per-persona retry-validator tests, (c) backward-compat shim discipline at composition root
- **parallel_hit_rate**: N/A — F.3 sub-plan IMPL is single-track refactor (no parallel sub-tracks within F.3); cross-sub-plan parallel orchestration is master session decision (F.3 BLOCKS F.4+F.5 per master plan § E.3)
- **parallel_savings_avg**: N/A
- **failure_mode frequency**: n=2 precedent shows 0 IMPORTANT defects per cycle (S375 + S378 both PASS-OR-PASS-WITH-CONCERNS in verifier); for F.3 architect estimates HIGHER risk per RM5 BC-8 test regression in master plan + RM7 AC-5 regression — recommend SINGLE IMPL session unless STEP 0.5 STOP-AND-ASK fires (see § C.5)
- **Adjustment to default budget**: F.3 IMPL S381 = 100-150K Opus FOCUSED_IMPL (HIGH end of envelope per cold-start-on-F.3-specifically + regression-heavy nature); architect estimates ~120-140K real-tokens for IMPL based on n=2 precedent + complexity uplift
- **Cold-start?**: **NO** for task_class="multi-perspective-impl" (n=2 declared); **YES** for specific F.3 N-perspective synthesizer surface (no prior IMPL of role-aware Phase1Synthesizer extension; F.3 is the first) — architect flags this as "narrow cold-start within established task_class" per § L Calibration section below

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):
- THIS plan authoring (S380): **150-200K Opus PLAN target ceiling** per dispatch brief Budget "150-230K Opus PLAN per recalibrated CLAUDE.md"; ~12-15 min wall-clock target
- IMPL S381: 100-150K Opus FOCUSED_IMPL (architect leans 130-150K per regression-heavy nature)
- VERIFY S382: 30-60K Opus AP-1 fresh-context

**PARALLEL OPPORTUNITY** (architect declaration):
- F.3 IMPL is single-track refactor (no internal parallel sub-tracks; refactor surface coordinated across 3 production files + 2 test files + 1 composition root + 1 ADR file)
- Post-F.3 ship: F.4 + F.5 parallel-eligible per master plan § E.5+E.4 (architect-tier parallel-dispatch validated at 4-parallel S345); main session orchestrates
- Within F.3 IMPL: dev MAY parallelize test authoring (D4 sub-track) with production code (D1+D2+D3) per dev judgment if refactor pattern crystallizes early; architect leans **sequential D1→D2→D3→D4→D5** for ZERO regression risk (test_use_case.py + test_synthesizer.py are the regression-floor anchor)

---

## B. In-scope / Out-of-scope (sub-plan-level)

### IN-scope (this sub-plan ships across S380 PLAN + S381 IMPL + S382 VERIFY)

- **D1 — `ValidateThesisPhase1UseCase` signature extension**: REFACTOR ctor at validate_thesis_phase1.py:153-171 to accept `agents: dict[PerspectiveRole, LLMPerspectivePort]` (replaces bear_agent+bull_agent+quant_agent params); REFACTOR `_run_pipeline` at :206-289 to dispatch all agents via `asyncio.gather(*[a.analyze(ticker, context, role) for role, a in self._agents.items()])` (preserves parallel fan-out per master plan-033 DD-3); REFACTOR perspectives tuple construction at :226 from hardcoded `(bear_p, bull_p, quant_p)` to `tuple(results)` (order-preserved by dict iteration order — Python 3.7+ deterministic per D-059 R2); REFACTOR budget.add() at :224 from hardcoded 3-sum to `sum(p.cost_usd for p in results)`; REFACTOR combined_prompt at :238 from existing perspectives-tuple-iteration to STABLE-SORTED-BY-ROLE iteration for AC-5 reproducibility guarantee (`':'.join(p.prompt_hash for p in sorted(perspectives, key=lambda p: p.role.value))`); ~30 LOC delta in single file
- **D2 — `Phase1Synthesizer` role-aware N-perspective extension**: EDIT phase1_synthesizer.py:102-261 to extend BEAR/BULL/QUANT-named lookup at :121-123 to N-perspective dispatch via `_build_persona_dimension_buckets(perspectives) → dict[PerspectiveRole, dict[str, list[GroundedPoint]]]`; EXTEND per-dim disagreement detection at :134-187 from BEAR-vs-BULL only to PAIRWISE across N personas (per § D DD-3 architect-leans MAJORITY-CATEGORICAL); EXTEND scoring at :190-211 to consume N-perspective evidence (QUANT-favoured remains for QUANT-only-numeric path; new personas BUFFETT/GRAHAM/TALEB contribute to BEAR/BULL aggregation via deterministic categorical-majority); PRESERVE I-S12 invariant — any pairwise disagreement → DISAGREEMENT confluence; ~80 LOC delta
- **D3 — Composition root wiring**: EDIT `apps/_shared/use_case_builder.py:55-176` to construct V0=6 agents dict in `_build_subagent_agents` + `_build_mock_agents`; ADD `_build_persona_agents(adapter, persona_registry)` helper that constructs BuffettPerspectiveAgent + GrahamPerspectiveAgent + TalebPerspectiveAgent via PersonaRegistry.get() per role_id; ADD `_load_persona_registry()` helper that creates PersonaRegistry + loads `agent-workspace/role-packs/{buffett,graham,taleb}.json`; UPDATE return type of `_build_subagent_agents` from 3-tuple to dict[PerspectiveRole, LLMPerspectivePort]; UPDATE `_build_mock_agents` return shape accordingly; ~50 LOC delta
- **D4 — Test additions + regression coverage**: NEW tests in test_use_case.py + test_synthesizer.py; ≥18 NEW unit test cases per § F DoD covering N=4/5/6 paths + AC-5 deterministic-per-tuple + I-S10 BEAR-presence regression + I-S12 disagreement-preservation regression + per-persona cost.add() regression + role-keyed dict dispatch + sorted-by-role combined_prompt; UPDATE _make_use_case helper at test_use_case.py:204-239 to support dict-typed agents kwarg
- **D5 — ADR D-076 PROPOSED**: NEW `agent-workspace/memory/decisions/076-bc-8-n-perspective-synthesizer-and-use-case-generalization.md` ~200 LOC documenting N-persona dispatch shape (dict[PerspectiveRole, LLMPerspectivePort]) + role-aware Phase1Synthesizer extension + AC-5 regression strategy + master plan DD-10 alignment + 50+ char substring grep gate against ai-hedge-fund portfolio_manager.py
- **STEP 0 + dogfood smoke** (architect-internal at sub-plan PLAN tier completed inline per § C; dev STEP 0 re-verifies at S381 IMPL entry)

### OUT-of-scope (DEFERRED — explicit non-goals)

- **F.4 V0 expansion** (V0=6 → V0=9 with Munger/Lynch/VN_DOMAIN_SPECIALIST personas) — separate sub-plan 037
- **F.5 CLI dogfood** (`apps/cli/synthesize_vn_thesis.py` NEW + wall-clock thesis run on VHM) — separate sub-plan 038
- **Charter / constitution writes** (out of scope per CLAUDE.md hard rules)
- **Production code in THIS PLAN session** (S380; architect tools: [Read, Glob, Grep, Write] — Write only for plan + observation files, NOT production code per CLAUDE.md § Session Types)
- **Weighted-by-conviction confluence calculation** — V0 ships MAJORITY-CATEGORICAL per § D DD-3; F.3-V2 refinement
- **New `_ROLE_TO_MODEL` entries for BUFFETT/GRAHAM/TALEB** in claude_llm_perspective_adapter.py:72-76 — F.3 does NOT modify adapter; persona-model routing falls back to _DEFAULT_MODEL Opus per :77 (architect FLAGS asymmetry in § J RM3; cost-impact is BUFFETT/GRAHAM/TALEB run on Opus instead of Sonnet preference from role-pack JSON at `model_id_preference: 'claude-sonnet-4-6'`; F.3 dev MAY fix inline if STEP 0 verifies trivial OR defer to F.3-V2 sub-plan)
- **Per-persona timeout-budget override**, **streaming output**, **dashboard surface**, **new event types** — all deferred per § A.3
- **`SynthesizePerspectivesUseCase` new class** — explicit DD-10 rejection
- **Sequence-of-agents tuple param** — § D DD-1 selects dict; tuple deferred

---

## C. STEP 0 — VBW Live Verification (this sub-plan — heavy STEP 0; dev re-verifies at S381 IMPL entry)

### Sub-step 0.1 — Existing Phase1Synthesizer audit (VBW — completed inline)

✅ `packages/infrastructure/analysis/phase1_synthesizer.py:102-261` Phase1Synthesizer shipped:
- `synthesize()` async method at :111-117 — signature `async def synthesize(self, ticker, perspectives, _context) → Synthesis`
- **BEAR/BULL/QUANT-named lookup at :121-123** — `next((p for p in perspectives if p.role == PerspectiveRole.BEAR), None)` etc. — N-persona refactor surface = generalize lookup to dict comprehension keyed by role
- Per-dim disagreement detection at :134-187 — currently pairwise BEAR-vs-BULL only; F.3 extends to pairwise across N personas (architect leans MAJORITY-CATEGORICAL per DD-3)
- Per-dim scoring at :190-207 — QUANT-favoured when QUANT present; else averages bear+bull; F.3 extends to consume N personas (QUANT-favoured preserved; new personas BUFFETT/GRAHAM/TALEB feed BEAR/BULL aggregation deterministically)
- Catalysts at :223-227 from BULL high-conviction; risks at :230-233 from BEAR high-conviction; F.3 PRESERVES (no change — catalysts/risks remain attributed to BULL/BEAR canonically; new personas contribute via TradeOffMatrix evidence not via catalysts/risks attribution)
- reasoning_trace at :244-252 — F.3 extends to log N-persona counts (not just Bear/Bull/Quant)

**Verdict**: Extension surface mapped; ~80 LOC delta envelope realistic.

### Sub-step 0.2 — Existing PerspectiveSynthesis aggregate audit (REPLACE with Synthesis — already exists)

✅ `packages/domain/analysis/models/synthesis.py:69-100` Synthesis aggregate shipped:
- Frozen + slotted dataclass with trade_off_matrix + confluence_assessment + explicit_disagreements + catalysts + risks + reasoning_trace
- I-S12 invariant at :89-100 — STRONG_CONSENSUS + non-empty disagreements = SynthesisInvariantError
- **NO new aggregate class needed for F.3** — existing Synthesis is N-persona-agnostic by-construction (consumes TradeOffMatrix dict-of-dim-to-evidence + tuple-of-disagreements; works for any N personas)

**Verdict**: NO new Synthesis aggregate; F.3 EXTENDS existing Phase1Synthesizer to populate existing Synthesis with N-persona-aggregated data.

### Sub-step 0.3 — Verify F.1+F.2 substrate ready (3 persona agents loadable)

✅ F.1 substrate ready:
- RolePromptPack at `packages/application/analysis/role_prompt_pack.py:33-103` (102 LOC; frozen dataclass + 10 fields + 9 invariants); imports clean
- PersonaRegistry at `packages/application/analysis/persona_registry.py:39-156` (156 LOC; stdlib dict wrapper + register/get/all_role_ids/load_from_json + D-064 path-safety 5-invariants); imports clean

✅ F.2 substrate ready:
- BuffettPerspectiveAgent at `packages/infrastructure/analysis/perspectives/buffett_agent.py:170-307` (138 LOC adapter class; retry-validator mirroring bear_agent:198-334; constructor `(adapter, role_pack)`; async `analyze(ticker, context, _role) → PerspectiveAnalysis`)
- GrahamPerspectiveAgent at `packages/infrastructure/analysis/perspectives/graham_agent.py` (same shape per S378 close)
- TalebPerspectiveAgent at `packages/infrastructure/analysis/perspectives/taleb_agent.py` (same shape per S378 close)

✅ V0 persona JSON role-packs ready:
- `agent-workspace/role-packs/buffett.json` (12 LOC; role_id="buffett" + persona_name + system_prompt_template + conviction_guidance + citation_requirements + vietnam_notes + min_points=3 + min_distinct_categories=3 + category_universe=["MOAT","MANAGEMENT","VALUATION","ROIC","BALANCE_SHEET","GROWTH"] + model_id_preference="claude-sonnet-4-6")
- `agent-workspace/role-packs/graham.json` (similar shape per S378 close)
- `agent-workspace/role-packs/taleb.json` (similar shape per S378 close)

✅ PerspectiveRole enum extended:
- `packages/domain/analysis/models/perspective_analysis.py:30-43` has 9 values: BEAR/BULL/QUANT (active) + MACRO/BEHAVIOR/MANAGER (deferred stubs) + BUFFETT/GRAHAM/TALEB (F.2 additions per S378)

**Verdict**: All F.1+F.2 substrate ready; F.3 IMPL can directly consume BuffettPerspectiveAgent+GrahamPerspectiveAgent+TalebPerspectiveAgent instances + PersonaRegistry.load_from_json() V0 packs.

### Sub-step 0.4 — ai-hedge-fund aggregation pattern read (parallel fan-out + role-keyed aggregation)

✅ `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` § 2 + § 5:
- **Parallel fan-out**: `src/main.py:112-115` "start_node → N analyst nodes (parallel fan-out) → risk_management_agent → portfolio_manager → END"; ai-hedge-fund uses LangGraph StateGraph with `Annotated[list, operator.add]` merge reducer — StockForge equivalent = `asyncio.gather(*[agent.analyze(...) for ...])` (existing pattern at validate_thesis_phase1.py:218-221; F.3 generalizes from 3 hardcoded to N)
- **Role-keyed aggregation**: Portfolio Manager sees `{ticker: {agent_id: {sig, conf}}}` table at `portfolio_manager.py:160-175` (per A-01 § 5 second-to-last bullet); StockForge equivalent at F.3 = Phase1Synthesizer sees `tuple[PerspectiveAnalysis, ...]` where each `.role` is the PerspectiveRole enum (effectively the same role-keyed table shape)
- **Per-perspective signal contract** (A-01 § 3 C1): ai-hedge-fund `{signal: bullish|bearish|neutral, confidence: int 0-100, reasoning: str}` per Pydantic class; StockForge equivalent = PerspectiveAnalysis dataclass at `perspective_analysis.py:46-65` with role + key_points + overall_conviction + cost_usd + model_id + prompt_hash + deferred (RICHER than ai-hedge-fund — additional fields for cost-tracking + reproducibility + source-grounding via GroundedPoint inside key_points)
- **Aggregation is deterministic Python** (A-01 § 5 bullet 4 "deterministic-then-LLM split"): ai-hedge-fund Portfolio Manager pre-computes allowed actions in deterministic code BEFORE LLM call; StockForge Phase1Synthesizer is FULLY deterministic Python (no LLM at all per recommendation_heuristic.py docstring "NO LLM. Maps Synthesis → Recommendation + ConfidenceLevel"); F.3 PRESERVES this discipline

**DD-10 from F.2 carry-forward (pattern-port NOT code-port)**: F.3 ADOPTS the pattern (parallel-fan-out + role-keyed aggregation + deterministic-then-LLM split) but RE-IMPLEMENTS with stockforge primitives; ZERO verbatim code-copy from ai-hedge-fund portfolio_manager.py/risk_manager.py allowed (architect explicit veto per master plan-033 hard_rules_acknowledged + A-01 § 6 LICENSE caveat + master plan DD-10 grep-gate carry-forward).

### Sub-step 0.5 — STOP-AND-ASK trigger if Phase1Synthesizer extension is too entangled

**STOP-AND-ASK clause**: F.3 IMPL dev MUST stop and escalate to architect-tier sub-plan refinement IF any of the following surface:

1. **Phase1Synthesizer extension exceeds ~120 LOC delta** (architect projection ≤80 LOC; if dev's extension grows >120 LOC, signals deeper refactor needed — suggest parallel-class fallback `Phase1NPerspectiveSynthesizer` OR splitting into 2 IMPL sessions S381+S381b per master plan AQ-7 "MAY_SPLIT_IF_>4H")
2. **Per-dim disagreement detection N-perspective extension surfaces unforeseen invariant gap** (e.g. 3-3 tie across STRONG_CONSENSUS vote with mixed verdicts requires new "tie-breaker" rule) — sub-plan 036 STEP 0 STOP-AND-ASK per master plan § K.2; CANDIDATE CHARTER-TIER FLAG
3. **AC-5 reproducibility regression cannot be preserved by simple dict-iteration order** (e.g. test surfaces inconsistent thesis_id under N=5 with same data due to dict iteration order non-determinism on some Python builds) — escalate to sort-stable design via PerspectiveRole.value lexicographic order (architect pre-recommends this design per § D DD-2 below — STABLE-SORTED-BY-ROLE combined_prompt construction)
4. **Composition root wiring at apps/_shared/use_case_builder.py surfaces 30+ test_validate_thesis.py regressions** that cannot be backward-compat-shimmed (e.g. internal API consumer hardcoded 3-tuple unpacking) — escalate to harness sweep for backward-compat shim design
5. **F.3 IMPL surfaces I-S12 invariant violation** (Phase1Synthesizer N-perspective rewrite breaks STRONG_CONSENSUS+disagreements check) — per master plan AQ-10: sub-plan 036 dev MUST fix inline (NOT defer) before commit; if multiple iterations fail, escalate to architect-tier sub-plan refinement

**NON-BLOCKING design preference per master plan § K.4**: All 5 triggers above use STOP-AND-ASK clause via dev's STEP 0 entry; no AskUserQuestion gate fires at master-plan-tier (architect-recommended design suffices for V0).

### Sub-step 0.6 — Test fixture audit (existing _make_use_case + _make_perspective helpers)

✅ `packages/application/analysis/test_use_case.py:55-127` test fixtures:
- `_make_point(text, category, conviction)` at :55-68 — GroundedPoint factory; F.3 REUSES unchanged
- `_make_perspective(role, points, cost)` at :70-82 — PerspectiveAnalysis factory; F.3 REUSES unchanged
- `_make_good_bear()` at :85-94 — BEAR with 3 distinct-category points; F.3 REUSES unchanged
- `_make_synthesis(confluence)` at :97-109 — Synthesis factory; F.3 REUSES unchanged
- `MockLLMPerspectivePort(responses)` at :112-127 — canned-response port; F.3 REUSES unchanged
- `MockSynthesizer(synthesis)` at :130-137 — fixed-synthesis stub; F.3 REUSES unchanged
- `_make_use_case(...)` at :204-239 — **EXTENSION SURFACE**: F.3 D4 UPDATES this helper to support dict-typed agents kwarg (backward-compat default: 3-persona dict construction; opt-in N>3 via new `extra_agents: dict[PerspectiveRole, LLMPerspectivePort] | None = None` kwarg)

✅ `packages/infrastructure/analysis/test_synthesizer.py:34-69` test fixtures:
- `_make_point(text, category, conviction)` at :34-46 — REUSE; same as test_use_case.py
- `_make_perspective(role, points, conviction)` at :49-61 — REUSE
- `_MockContext` at :64-66 — REUSE
- `Phase1Synthesizer()` direct instantiation at test top — F.3 REUSES

**Verdict**: Test fixture extension surface minimal; F.3 D4 adds ~18 NEW test cases without breaking existing ≥16 cases.

### Sub-step 0.7 — STEP 0 summary write (this sub-plan)

All 6 sub-steps PASS. NO STOP-AND-ASK triggered at PLAN-tier (5 triggers reserved for dev STEP 0 at S381 IMPL entry). NO charter-tier FLAGS at sub-plan-level beyond what master plan § K.2 already enumerates.

---

## D. Architecture Decisions (DD-1 through DD-10)

### DD-1: N-persona dispatch shape = `dict[PerspectiveRole, LLMPerspectivePort]` (NOT sequence/tuple)

**Decision**: `ValidateThesisPhase1UseCase.__init__` accepts `agents: dict[PerspectiveRole, LLMPerspectivePort]` (NEW; replaces bear_agent+bull_agent+quant_agent params).

**Rationale**:
- **Role-keyed lookup matches existing pattern** — `_ROLE_TO_MODEL: dict[PerspectiveRole, str]` at `claude_llm_perspective_adapter.py:72-76` already uses dict[PerspectiveRole, ...] for routing; semantic consistency
- **Allows N>3 personas via dict entry addition** — adding BUFFETT/GRAHAM/TALEB = 3 new dict entries; no ctor signature churn; same for future N=9 V0 expansion in F.4
- **Self-documenting** — role-keyed access in code: `agents[PerspectiveRole.BEAR].analyze(...)` is clearer than `agents[0].analyze(...)` with positional convention
- **AC-5 reproducibility preserved** — D2 D-2 STABLE-SORTED-BY-ROLE combined_prompt construction (see DD-2 below) makes thesis_id deterministic regardless of dict insertion order
- **Backward-compat at composition root** — `apps/_shared/use_case_builder.py` D3 constructs dict {BEAR: bear, BULL: bull, QUANT: quant} from existing _build_subagent_agents/_build_mock_agents 3-tuple before passing to use case; existing callers don't break

**Adversarial alternate considered**: `agents: tuple[LLMPerspectivePort, ...]` (sequence-of-agents) — REJECTED (positional convention brittle; if user reorders the tuple, BEAR-at-position-0 assumption breaks; harder to test "exactly which agent is BEAR" without lookup; loses role-keyed ergonomics; doesn't match existing _ROLE_TO_MODEL pattern).

**Adversarial alternate considered**: `agents: PersonaRegistry` (registry passed directly to use case) — REJECTED (PersonaRegistry holds RolePromptPack DATA not LLMPerspectivePort INSTANCES; mixes data-layer with adapter-layer concerns; F.3 PRESERVES separation per master plan DD-4 HYBRID pattern).

### DD-2: AC-5 reproducibility = STABLE-SORTED-BY-ROLE combined_prompt construction

**Decision**: At `validate_thesis_phase1.py:238` REPLACE `combined_prompt = ":".join(p.prompt_hash for p in perspectives)` with `combined_prompt = ":".join(p.prompt_hash for p in sorted(perspectives, key=lambda p: p.role.value))`.

**Rationale**:
- **Determinism guarantee independent of dispatch order** — even if asyncio.gather completes agents in different order across runs OR dict insertion order differs across Python runs (D-059 R2 protects but defense-in-depth wins), thesis_id remains deterministic
- **PerspectiveRole.value lexicographic sort = stable canonical ordering** — values are "bear" / "bull" / "buffett" / "graham" / "macro" / "manager" / "quant" / "taleb" — sort produces stable canonical sequence regardless of dispatch order
- **Backward-compat** — for existing 3-persona path with BEAR/BULL/QUANT: sorted ordering = "bear" < "bull" < "quant" — DIFFERENT from existing implicit dispatch order which is (bear_p, bull_p, quant_p) per :226 happening to align with sorted because asyncio.gather preserves arg order = (bear_t, bull_t, quant_t) at :221 — **AC-5 regression test confirms existing 3-persona thesis_id values DO NOT CHANGE under sorted-by-role implementation**
- **N=6 case**: sort produces ("bear", "buffett", "bull", "graham", "quant", "taleb") — deterministic canonical sequence

**Risk**: existing thesis_id values in any persisted DB MIGHT differ from new computation IF dispatch order happened to differ from sorted order — but existing path is (bear, bull, quant) which is sorted order — so NO existing persisted thesis_id changes; F.3 dev MUST regression-test by computing thesis_id with old + new formula on N=3 fixture and confirming equality.

**Adversarial alternate considered**: Use PerspectiveRole enum declaration order (BEAR=0, BULL=1, QUANT=2, ...) — REJECTED (couples thesis_id to enum-declaration-order; if future maintainer reorders enum, thesis_id changes silently; alphabetic-by-value is enum-declaration-order-independent).

**Adversarial alternate considered**: Use insertion-order from dict (Python 3.7+ guarantees) — REJECTED (relies on caller to maintain consistent insertion order across runs; D-059 R2 is satisfied but defense-in-depth via explicit sort is stronger).

### DD-3: Phase1Synthesizer N-perspective aggregation = MAJORITY-CATEGORICAL (NOT weighted-by-conviction)

**Decision**: F.3 V0 ships MAJORITY-CATEGORICAL aggregation:
- Per-dim disagreement detection extends from BEAR-vs-BULL pairwise to ALL-PAIRS-ACROSS-N-PERSONAS pairwise: for each dim, iterate `for (p1, p2) in itertools.combinations(perspectives, 2): detect disagreement(p1, p2, dim)`
- Per-dim verdict-vs-narrative classification unchanged (existing 4-case detection at phase1_synthesizer.py:146-187)
- Per-dim scoring: QUANT-favoured preserved (if QUANT present, QUANT verdict wins); else majority-categorical across N-perspectives buckets per dim — "tie" defaults to NEUTRAL
- Catalysts (BULL-attributed) + risks (BEAR-attributed) PRESERVED; new personas contribute via TradeOffMatrix.evidence not via catalysts/risks attribution (architect explicit design)

**Rationale**:
- **Karpathy P2 simplicity-first** — categorical-majority is simplest aggregation; weighted-by-conviction adds 1 design dimension (weight scheme) + 1 calibration question (which weights match historical persona reliability?)
- **A-01 § 5 third bullet ISOLATED-THEN-AGGREGATE as Wave-1 default** — ai-hedge-fund Portfolio Manager doesn't weight signals empirically; it uses pre-computed allowed-actions table (deterministic-pre-computation); StockForge V0 = deterministic-categorical-majority is the equivalent simplest aggregation
- **AP-7 named revisit trigger** — F.3-V2 = weighted-by-conviction IF V0 dogfood (F.5) reveals MAJORITY-CATEGORICAL produces empirically-poor confluence on 3+ different VN tickers (e.g. 3-3 tie collapses to MIXED when STRONG_CONSENSUS-with-1-dissenter would be more informative per project-owner judgment)
- **I-S1-1 by-construction** — categorical aggregation = no LLM math anywhere; numeric confidence emerges from Rule 16 mode 2 deterministic-pipeline echo at `recommendation_heuristic.confidence_from_synthesis`

**Adversarial alternate considered**: Weighted-by-conviction with Conviction.STRONG=3, MODERATE=2, WEAK=1 numeric weights — REJECTED for V0 (premature optimization; calibration question; F.3-V2 if dogfood empirically motivates).

**Adversarial alternate considered**: Inverse-evidence-quality weighting (heavier weight on personas with more grounded points per dim) — REJECTED for V0 (designs against per-persona retry-validator behavior; if BUFFETT shipped 5 points and BEAR shipped 3 points, BUFFETT outweighs BEAR — counter-intuitive given BEAR is the I-S10-anchored persona).

### DD-4: I-S10 BEAR-presence invariant enforcement — preserved at Thesis layer (NOT re-enforced at synthesizer)

**Decision**: F.3 PRESERVES existing I-S10 enforcement at `Thesis._enforce_bear_case` at `thesis.py:91-115`; Phase1Synthesizer DOES NOT re-enforce BEAR-presence; F.3 dev MUST verify N-persona path STILL constructs Thesis with PerspectiveRole.BEAR present (NO mocking out BEAR).

**Rationale**:
- **Existing invariant is at correct layer** — Thesis aggregate-root enforces I-S10 by-construction (raises BearCaseInvariantError at __post_init__); F.3 architect explicitly DOES NOT move invariant enforcement to synthesizer (would be 2 enforcement sites = maintenance burden + drift risk)
- **F.3 N-persona path passes through Thesis aggregate** — `validate_thesis_phase1.py:248-261` constructs Thesis with perspectives tuple; if BEAR perspective is missing, Thesis.__post_init__ raises BearCaseInvariantError → use case catches at :262-267 → returns Thesis.incomplete(); SAME behavior as N=3 path
- **F.3 dev verifies BEAR-presence implicitly** via existing test_bear_insufficient_returns_incomplete at test_use_case.py:272-291 (existing test); F.3 ADDS new test asserting V0=6 path with BEAR-missing → INCOMPLETE thesis (per § F DoD test 6)

**Adversarial alternate considered**: Add explicit BEAR-presence check in `ValidateThesisPhase1UseCase._run_pipeline` before parallel dispatch — REJECTED (redundant with existing Thesis._enforce_bear_case; violates DRY; pre-dispatch check at use case adds branch but doesn't change behavior — Thesis aggregate still rejects).

**Adversarial alternate considered**: Move I-S10 enforcement to Phase1Synthesizer.synthesize() — REJECTED (Synthesis aggregate has NO bear-presence invariant; I-S10 is Thesis-tier invariant; moving it to synthesizer would split invariant enforcement across 2 layers).

### DD-5: I-S12 disagreement-preservation invariant extension = PAIRWISE across N-perspectives (preserves existing semantic)

**Decision**: F.3 extends per-dim disagreement detection from BEAR-vs-BULL pairwise (existing at phase1_synthesizer.py:146-187) to ALL-PAIRS-ACROSS-N-PERSONAS pairwise via `itertools.combinations(perspectives, 2)`. Existing detection rule unchanged: STRONG-vs-WEAK extreme = "verdict" kind disagreement; STRONG-vs-NEUTRAL with both engaged = "narrative" kind disagreement.

**Rationale**:
- **I-S12 invariant at Synthesis.__post_init__ unchanged** — STRONG_CONSENSUS + non-empty disagreements = bug; F.3 N-perspective path EMITS disagreement entries to explicit_disagreements tuple when any pairwise disagreement detected; Synthesis aggregate invariant remains the constructor-time check
- **Pairwise across N preserves semantic** — for V0=6 personas, on RISK dimension if BEAR=STRONG and TALEB=WEAK and BUFFETT=NEUTRAL: pairwise detects BEAR-vs-TALEB verdict-disagreement + BEAR-vs-BUFFETT narrative-disagreement + TALEB-vs-BUFFETT narrative-disagreement; explicit_disagreements tuple records up to 3 entries on RISK dim; confluence = DISAGREEMENT
- **N-pair combinatorial complexity manageable** — V0=6 personas × 4 dimensions × C(6,2)=15 pairs = 60 detections per Synthesis call; negligible compared to LLM call latency
- **PRESERVES existing 3-persona Disagreement.bear_verdict + bull_verdict semantic** — for new personas, F.3 SHIPS Disagreement entries with `bear_verdict=str(p1.verdict_on_dim)` + `bull_verdict=str(p2.verdict_on_dim)` (semantically: "left-side persona" + "right-side persona" — field names retain bear/bull lineage from spec § B.2 for backward-compat, but values capture any-pairwise comparison)

**Note (architect transparency)**: The Disagreement dataclass field names (`bear_verdict`, `bull_verdict`) are spec-006-anchored from spec § B.2 + A.11 — these are MISLEADING for N-persona path (the values represent ANY pairwise comparison not specifically BEAR-vs-BULL). F.3 dev DOES NOT rename fields (Karpathy P3 surgical-changes; cross-layer rename = broad regression). F.3 dev DOES extend Disagreement.note to clarify pairwise semantics: "{p1.role} {verdict1} vs {p2.role} {verdict2} on {dim}". F.3-V2 candidate: rename `bear_verdict`/`bull_verdict` to `left_verdict`/`right_verdict` (field rename = broader regression — defer).

**Adversarial alternate considered**: Replace `bear_verdict`/`bull_verdict` fields with `left_verdict`/`right_verdict` (or `verdict_a`/`verdict_b`) — REJECTED for F.3 V0 (Karpathy P3; cross-layer rename touches Synthesis aggregate + tests + persistence — defer to F.3-V2).

**Adversarial alternate considered**: Add NEW Disagreement.left_role + right_role fields + DEPRECATE bear_verdict/bull_verdict — REJECTED (adds 2 fields without rename = schema bloat; F.3 dev MAY add left_role/right_role at F.3-V2 trigger).

### DD-6: Per-persona cost accumulation = sum across N personas via comprehension

**Decision**: Replace hardcoded 3-sum at `validate_thesis_phase1.py:224` `budget.add(bear_p.cost_usd + bull_p.cost_usd + quant_p.cost_usd)` with `budget.add(sum(p.cost_usd for p in perspectives))` using existing perspectives tuple.

**Rationale**:
- **Decimal-safe summation** — `sum(Decimal[..])` works correctly in Python 3 (sum with default start=0 → 0 + Decimal = Decimal); architect verifies via reading sum docs + Decimal precedent at recommendation_heuristic.py (no float coercion)
- **Preserves cumulative-cost budget semantic** — scoped_budget(limit_usd=Decimal("3.00")) at :187-189 unchanged; cumulative cost across N personas accumulates in budget; CostBudgetExceeded raises if cumulative > 3.00 as before
- **N-persona-agnostic** — works for N=3, N=6, N=9 without code change

**Adversarial alternate considered**: Use `functools.reduce(operator.add, ...)` — REJECTED (overengineered; `sum()` is idiomatic Python for Decimal summation).

### DD-7: Composition root V0=6 wiring = `_build_persona_agents()` + PersonaRegistry.load_from_json() per V0 pack

**Decision**: NEW helper `_build_persona_agents(adapter, persona_registry)` at `apps/_shared/use_case_builder.py` constructs BuffettPerspectiveAgent + GrahamPerspectiveAgent + TalebPerspectiveAgent via persona_registry.get(role_id) for each. NEW helper `_load_persona_registry()` loads all V0 JSON role-packs via PersonaRegistry.load_from_json(Path("agent-workspace/role-packs/buffett.json")) etc. UPDATE `_build_subagent_agents()` return type from 3-tuple `(bear, bull, quant)` to `dict[PerspectiveRole, LLMPerspectivePort]` constructing dict {BEAR: bear, BULL: bull, QUANT: quant, BUFFETT: buffett, GRAHAM: graham, TALEB: taleb}. UPDATE `_build_mock_agents()` to construct mock dict for all V0=6 roles. UPDATE `build_use_case` at :126-135 to pass agents dict to ValidateThesisPhase1UseCase ctor.

**Rationale**:
- **Composition root pattern** — main.py / CLI entry creates PersonaRegistry instance + registers all V0 packs; mirrors existing ClaudeLLMPerspectiveAdapter composition pattern at apps/_shared/use_case_builder.py:168-176
- **PersonaRegistry as composition-time data source** — F.1 + F.2 design intent realized; F.3 = first production consumer of PersonaRegistry beyond per-persona test mocking
- **Path safety per D-064** — PersonaRegistry.load_from_json() already enforces 5-invariant (no traversal, .json ext, no symlink, real file, base_dir confinement); F.3 dev passes `base_dir=Path("agent-workspace/role-packs")` for safety
- **Mock path unchanged in spirit** — `_build_mock_agents()` returns canned PerspectiveAnalysis fixtures per role; F.3 D3 extends to include canned BUFFETT/GRAHAM/TALEB analyses (architect-recommended: mock points = `_pt("buffett_value_analysis_point", category="VALUATION")`, `_pt("graham_balance_sheet_point", category="BALANCE_SHEET")`, `_pt("taleb_tail_risk_point", category="RISK")` — generic placeholders; mock tests don't need realistic content)

**Adversarial alternate considered**: Construct agents dict inline at `build_use_case` body (no `_build_persona_agents` helper) — REJECTED (helper isolates persona-construction logic; mirrors existing `_build_subagent_agents` + `_build_mock_agents` factoring; easier unit test).

**Adversarial alternate considered**: Inject PersonaRegistry into use case ctor (instead of constructing agents dict at composition root) — REJECTED (use case shouldn't know about PersonaRegistry concrete type; agents dict[PerspectiveRole, LLMPerspectivePort] is the abstraction; PersonaRegistry is composition-root concern).

### DD-8: AC-5 regression-test design = same-input-twice + cross-N-persona-rotation comparisons

**Decision**: D4 test fixture additions include:

1. **AC-5 N=3 baseline regression** (architect-mandated): Run thesis with same N=3 fixture twice; assert `thesis.thesis_id == thesis2.thesis_id` (preserves existing AC-5 contract)
2. **AC-5 N=6 sorted-by-role**: Run thesis with N=6 fixture twice; assert `thesis.thesis_id == thesis2.thesis_id` (extends AC-5 contract to N=6)
3. **AC-5 sorted-by-role invariance**: Run thesis with N=6 fixture where agents dict insertion order is shuffled across runs; assert thesis_id IDENTICAL across runs (validates DD-2 STABLE-SORTED-BY-ROLE design)
4. **AC-5 thesis_id changes with persona-roster change**: Run thesis with N=3 (BEAR/BULL/QUANT) → thesis_id_A; Run thesis with N=6 (above + BUFFETT/GRAHAM/TALEB) on SAME ticker/as_of/data → thesis_id_B; assert `thesis_id_A != thesis_id_B` (roster differences propagate to thesis_id via combined_prompt change — by-design property)
5. **AC-5 thesis_id stable under per-persona prompt_hash change** — if BUFFETT prompt_hash changes (e.g. role-pack edit), thesis_id changes too (combined_prompt includes BUFFETT prompt_hash); test fixture confirms change propagates

**Rationale**: F.3 regression-floor anchor IS AC-5 reproducibility per master plan § J RM5; explicit 5 test scenarios cover normal-case + invariance + by-design-changes.

### DD-9: V0=6 persona-model routing asymmetry — architect FLAGS but DOES NOT fix in F.3

**Decision**: F.3 IMPL does NOT extend `_ROLE_TO_MODEL: dict[PerspectiveRole, str]` at `claude_llm_perspective_adapter.py:72-76` to include BUFFETT/GRAHAM/TALEB entries. New personas fall through to `_DEFAULT_MODEL = _OPUS_MODEL` per :77.

**Rationale**:
- **Scope discipline (Karpathy P3 surgical-changes)** — F.3 sub-plan owns Phase1Synthesizer + ValidateThesisPhase1UseCase + composition root; modifying claude_llm_perspective_adapter for routing is per-persona-cost concern OUT of F.3 scope (architect-recommended fix at F.3-V2 OR sub-plan 037 F.4 IF V0=6 confirmed)
- **Asymmetry FLAGGED in § J RM3** — V0=6 cost-profile risk if all 3 new personas run on Opus (5× cost vs Sonnet preference in role-pack JSON model_id_preference); empirical cost monitored at F.5 dogfood
- **F.3 dev MAY fix inline if STEP 0 verifies trivial** — adding 3 dict entries `BUFFETT: _SONNET_MODEL, GRAHAM: _SONNET_MODEL, TALEB: _SONNET_MODEL` is ≤5 LOC delta; if dev judges fix trivial + atomic, MAY include in IMPL; else DEFER with revisit-trigger named

**Adversarial alternate considered**: Architect mandates _ROLE_TO_MODEL extension in F.3 IMPL — REJECTED (out of scope; if mandatory, master plan DD-12 + sub-plan 034 D5 F.1 would have shipped this; deferred to F.4 OR explicit architect-tier decision).

**Adversarial alternate considered**: Architect mandates ClaudeLLMPerspectiveAdapter consumes role_pack.model_id_preference field (existing on RolePromptPack) — REJECTED for F.3 V0 (requires deeper refactor to pass role_pack through to adapter; current adapter accepts `role_model_overrides` kwarg per F.1; F.4 design decision — NOT F.3).

### DD-10: F.3 architectural decisions DO NOT introduce new charter-tier invariants

**Decision**: F.3 IMPL does NOT propose any new I-S<N> invariant beyond existing I-S1/I-S1-1/I-S10/I-S12/I-S35/AC-5; F.3 EXTENDS existing invariant enforcement (Thesis._enforce_bear_case preserves I-S10; Synthesis.__post_init__ preserves I-S12; recommendation_heuristic preserves I-S1/I-S35 by-construction).

**Rationale**: Master plan § K.1 verdict "NO CHARTER-TIER BLOCKING FLAGS"; F.3 inherits NON-BLOCKING design. IF F.3 IMPL surfaces a tie-breaker rule (3-3 tie across STRONG_CONSENSUS vote with mixed verdicts), sub-plan 036 STEP 0 STOP-AND-ASK fires per master plan § K.2 CANDIDATE CHARTER-TIER FLAG; this PLAN architect explicitly DOES NOT propose the rule at PLAN-tier (defer to dev evidence at IMPL-tier).

---

## E. Sub-tracks D1..D5 (IMPL S381 sequential ordering recommended)

### D1 — ValidateThesisPhase1UseCase signature extension (~30 LOC delta single file)

**Target**: `packages/application/analysis/use_cases/validate_thesis_phase1.py`

**Changes**:
- REFACTOR ctor `__init__` at :153-171: replace `bear_agent: LLMPerspectivePort, bull_agent: LLMPerspectivePort, quant_agent: LLMPerspectivePort` (3 params) with `agents: dict[PerspectiveRole, LLMPerspectivePort]` (1 param); preserve `data_gatherer`, `synthesizer`, `thesis_repo`, `cost_tracker`, `event_bus` params unchanged
- REFACTOR `_run_pipeline` at :206-289 Step 2 (parallel dispatch): replace lines 218-221 hardcoded `(bear_t, bull_t, quant_t) = ...` + `asyncio.gather(bear_t, bull_t, quant_t)` with generalized:
  ```python
  # Step 2 — run N perspectives in parallel (I-S12 disagreement preserved across N pairs)
  # Per master plan DD-3 ISOLATED-THEN-AGGREGATE (asyncio.gather; NO inter-agent messaging)
  tasks = [agent.analyze(ticker, context, role) for role, agent in self._agents.items()]
  results = await asyncio.gather(*tasks)
  perspectives: tuple[PerspectiveAnalysis, ...] = tuple(results)
  ```
- REFACTOR :224 budget.add(): replace hardcoded `bear_p.cost_usd + bull_p.cost_usd + quant_p.cost_usd` with `sum(p.cost_usd for p in perspectives)`
- REFACTOR :238 combined_prompt: replace `":".join(p.prompt_hash for p in perspectives)` with `":".join(p.prompt_hash for p in sorted(perspectives, key=lambda p: p.role.value))` (DD-2 STABLE-SORTED-BY-ROLE)
- REFACTOR :239 model_id: replace `bear_p.model_id` with `next(p.model_id for p in sorted(perspectives, key=lambda p: p.role.value))` (deterministic-first-role model_id for thesis_id input; same value as existing bear_p.model_id when sorted-first persona happens to be BEAR, which holds for V0=6 since "bear" < "buffett" < "bull" < "graham" < "quant" < "taleb" alphabetically — F.3 dev MUST regression-test this preserves existing N=3 thesis_id; architect-recommended fallback: use a hardcoded canonical model_id derived from a designated "primary" persona — but DD-2 sorted-first-role choice is simpler + N-persona-agnostic)
- ADD type hint imports: existing `from packages.domain.analysis.models.perspective_analysis import PerspectiveRole` already present at :54-55

**Verification at end of D1**:
- mypy --strict CLEAN
- ruff CLEAN
- existing test_use_case.py tests STILL PASS (after D4 updates the _make_use_case helper to construct dict; OR if D4 runs after D1, expect existing tests temporarily broken — sequencing per § E ordering below)

**LOC delta**: ~30 LOC (5 lines changed at ctor + 6 lines changed at parallel dispatch + 1 line at budget + 2 lines at combined_prompt/model_id + ~16 lines of comments + helper for clarity)

### D2 — Phase1Synthesizer role-aware N-perspective extension (~80 LOC delta single file)

**Target**: `packages/infrastructure/analysis/phase1_synthesizer.py`

**Changes**:
- REFACTOR :121-123 BEAR/BULL/QUANT named-lookup to N-perspective generalized:
  ```python
  # N-perspective dispatch — group perspectives by role (V0=6: BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB)
  by_role: dict[PerspectiveRole, PerspectiveAnalysis] = {p.role: p for p in perspectives}
  bear = by_role.get(PerspectiveRole.BEAR)
  bull = by_role.get(PerspectiveRole.BULL)
  quant = by_role.get(PerspectiveRole.QUANT)
  # Additional V0=6 personas — collected for pairwise disagreement detection + scoring
  additional = [p for p in perspectives if p.role not in {PerspectiveRole.BEAR, PerspectiveRole.BULL, PerspectiveRole.QUANT}]
  ```
- EXTEND `_build_dimension_buckets` consumption at :125-127 to handle additional personas: NEW helper `_build_additional_persona_buckets(additional) → dict[PerspectiveRole, dict[str, list[GroundedPoint]]]` (mirrors existing _build_dimension_buckets per-persona)
- EXTEND per-dim disagreement detection at :134-187 from BEAR-vs-BULL only to PAIRWISE across N personas:
  ```python
  # Pairwise disagreement detection across N personas (per master plan-033 § E.3 + plan-036 DD-5)
  # Existing BEAR-vs-BULL detection preserved; new pairs added for BUFFETT/GRAHAM/TALEB
  all_perspectives_with_buckets: list[tuple[PerspectiveAnalysis, dict[str, list[GroundedPoint]]]] = [
      (p, _build_dimension_buckets(p)) for p in perspectives
  ]
  for dim in DIMENSIONS:
      for (p1, b1), (p2, b2) in itertools.combinations(all_perspectives_with_buckets, 2):
          v1 = _points_to_verdict(b1[dim])
          v2 = _points_to_verdict(b2[dim])
          # Apply same verdict/narrative classification as existing BEAR-vs-BULL rule
          if (v1 == STRONG and v2 == WEAK) or (v1 == WEAK and v2 == STRONG):
              explicit_disagreements.append(Disagreement(
                  dimension=dim,
                  bear_verdict=str(v1),  # Note: field name retained per DD-5; represents p1 verdict
                  bull_verdict=str(v2),  # Note: field name retained per DD-5; represents p2 verdict
                  note=f"{p1.role} {v1} vs {p2.role} {v2} on {dim} — opposing conclusions; investigate further.",
                  kind="verdict",
              ))
          elif b1[dim] and b2[dim] and ((v1 == STRONG and v2 == NEUTRAL) or (v1 == NEUTRAL and v2 == STRONG)):
              explicit_disagreements.append(Disagreement(...))  # narrative kind
  ```
- EXTEND scoring at :190-211 to consume additional personas via QUANT-favoured-else-majority-categorical:
  ```python
  if quant_buckets[dim]:  # existing — QUANT-favoured preserved
      scores[dim] = quant_verdict
  elif dim_evidence:  # NEW: majority-categorical across all persona verdicts on dim
      all_verdicts_on_dim = [_points_to_verdict(buckets[dim]) for _, buckets in all_perspectives_with_buckets if buckets[dim]]
      counts = {DimensionVerdict.STRONG: 0, DimensionVerdict.WEAK: 0, DimensionVerdict.NEUTRAL: 0}
      for v in all_verdicts_on_dim:
          counts[v] += 1
      strong_n, weak_n = counts[DimensionVerdict.STRONG], counts[DimensionVerdict.WEAK]
      if strong_n > weak_n:
          scores[dim] = DimensionVerdict.STRONG
      elif weak_n > strong_n:
          scores[dim] = DimensionVerdict.WEAK
      else:
          scores[dim] = DimensionVerdict.NEUTRAL  # tie defaults to NEUTRAL
  else:
      scores[dim] = DimensionVerdict.NEUTRAL
  evidence[dim] = tuple(sum((buckets[dim] for _, buckets in all_perspectives_with_buckets), []))
  ```
- PRESERVE catalysts at :223-227 (BULL-attributed; F.3 unchanged — catalysts canonically from BULL only per architect explicit decision DD-3)
- PRESERVE risks at :230-233 (BEAR-attributed; F.3 unchanged — risks canonically from BEAR only)
- EXTEND reasoning_trace at :244-252 to log N-perspective counts:
  ```python
  persona_count_summary = ", ".join(
      f"{p.role}: {len(p.key_points)} points" for p in sorted(perspectives, key=lambda p: p.role.value)
  )
  reasoning_trace = (
      f"Phase1Synthesizer | {ticker.symbol} | "
      f"Dimensions: {dims_summary} | "
      f"Confluence: {confluence} | "
      f"{disagreement_summary} | "
      f"Perspectives ({len(perspectives)}): {persona_count_summary}"
  )
  ```
- ADD import: `import itertools` at file top

**Verification at end of D2**:
- mypy --strict CLEAN
- ruff CLEAN
- existing test_synthesizer.py ≥6 tests STILL PASS (existing tests use BEAR/BULL/QUANT only → fall through new code path unchanged)

**LOC delta**: ~80 LOC (15-20 lines refactored for by_role lookup + 20-25 lines refactored for pairwise disagreement + 15 lines refactored for majority-categorical scoring + 10 lines for reasoning_trace + 5 lines for new helper + 5 lines for import + ~10 lines of comments)

### D3 — Composition root V0=6 wiring (~50 LOC delta single file)

**Target**: `apps/_shared/use_case_builder.py`

**Changes**:
- ADD NEW helper `_load_persona_registry() → PersonaRegistry` at file ~line 137 (between _build_subagent_agents and _build_mock_agents):
  ```python
  def _load_persona_registry() -> PersonaRegistry:
      """Load V0 persona packs from agent-workspace/role-packs/*.json.
      
      Per F.3 plan-036 D3 + F.1 plan-034 PersonaRegistry composition pattern.
      """
      from packages.application.analysis.persona_registry import PersonaRegistry
      registry = PersonaRegistry()
      base_dir = Path("agent-workspace") / "role-packs"
      for role_id in ("buffett", "graham", "taleb"):
          pack_path = base_dir / f"{role_id}.json"
          registry.load_from_json(pack_path, base_dir=base_dir)
      return registry
  ```
- ADD NEW helper `_build_persona_agents(adapter, persona_registry) → dict[PerspectiveRole, LLMPerspectivePort]` at file ~line 155:
  ```python
  def _build_persona_agents(adapter: object, registry: object) -> dict[object, object]:
      """Construct V0 personas (BUFFETT/GRAHAM/TALEB) using PersonaRegistry packs.
      
      Per F.3 plan-036 D3 + F.2 plan-035 persona adapter pattern.
      """
      from packages.domain.analysis.models.perspective_analysis import PerspectiveRole
      from packages.infrastructure.analysis.perspectives.buffett_agent import BuffettPerspectiveAgent
      from packages.infrastructure.analysis.perspectives.graham_agent import GrahamPerspectiveAgent
      from packages.infrastructure.analysis.perspectives.taleb_agent import TalebPerspectiveAgent
      return {
          PerspectiveRole.BUFFETT: BuffettPerspectiveAgent(adapter, registry.get("buffett")),
          PerspectiveRole.GRAHAM: GrahamPerspectiveAgent(adapter, registry.get("graham")),
          PerspectiveRole.TALEB: TalebPerspectiveAgent(adapter, registry.get("taleb")),
      }
  ```
- REFACTOR `_build_subagent_agents()` at :138-176 return type from 3-tuple to dict[PerspectiveRole, LLMPerspectivePort]; UPDATE return value to include persona dict via `**_build_persona_agents(adapter, registry)`:
  ```python
  def _build_subagent_agents() -> dict[object, object]:
      # ... existing adapter setup unchanged ...
      registry = _load_persona_registry()
      return {
          PerspectiveRole.BEAR: BearPerspectiveAgent(adapter),
          PerspectiveRole.BULL: BullPerspectiveAgent(adapter),
          PerspectiveRole.QUANT: QuantPerspectiveAgent(adapter),
          **_build_persona_agents(adapter, registry),
      }
  ```
- REFACTOR `_build_mock_agents()` at :200-261 return value to V0=6 dict construction; extend canned PerspectiveAnalysis fixtures to include BUFFETT/GRAHAM/TALEB stubs:
  ```python
  # ... existing bear_points/bull_points/quant_points unchanged ...
  buffett_points = (_pt("Mock buffett moat point.", "MOAT"), _pt("Mock buffett valuation point.", "VALUATION"), _pt("Mock buffett ROIC point.", "ROIC"))
  graham_points = (_pt("Mock graham balance sheet point.", "BALANCE_SHEET"), _pt("Mock graham margin of safety point.", "MARGIN_OF_SAFETY"), _pt("Mock graham working capital point.", "WORKING_CAPITAL"))
  taleb_points = (_pt("Mock taleb tail risk point.", "TAIL_RISK"), _pt("Mock taleb antifragility point.", "ANTIFRAGILITY"), _pt("Mock taleb kurtosis point.", "KURTOSIS"))
  # ... return dict with all 6 _FixedAgent instances ...
  return {
      PerspectiveRole.BEAR: _FixedAgent(_pa(PerspectiveRole.BEAR, bear_points)),
      PerspectiveRole.BULL: _FixedAgent(_pa(PerspectiveRole.BULL, bull_points)),
      PerspectiveRole.QUANT: _FixedAgent(_pa(PerspectiveRole.QUANT, quant_points)),
      PerspectiveRole.BUFFETT: _FixedAgent(_pa(PerspectiveRole.BUFFETT, buffett_points)),
      PerspectiveRole.GRAHAM: _FixedAgent(_pa(PerspectiveRole.GRAHAM, graham_points)),
      PerspectiveRole.TALEB: _FixedAgent(_pa(PerspectiveRole.TALEB, taleb_points)),
  }
  ```
- REFACTOR `build_use_case` at :112-135 call sites to use dict result instead of 3-tuple unpacking:
  ```python
  if mock_llm:
      agents = _build_mock_agents()
      data_gatherer = _MockDataGatherer()
  else:
      agents = _build_subagent_agents()
      data_gatherer = _SubagentDataGatherer(db_path=db_path)
  
  return ValidateThesisPhase1UseCase(
      data_gatherer=data_gatherer,
      agents=agents,  # NEW dict param replaces 3 individual agent params
      synthesizer=synthesizer,
      thesis_repo=thesis_repo,
      cost_tracker=cost_tracker,
      event_bus=event_bus,
  )
  ```
- ADD import: `from pathlib import Path` already present at :32

**Verification at end of D3**:
- mypy --strict CLEAN
- ruff CLEAN
- composition root smoke test (instantiate build_use_case(mock_llm=True) → verify returns ValidateThesisPhase1UseCase instance + V0=6 agents wired)

**LOC delta**: ~50 LOC (2 new helpers ~25 LOC + _build_subagent_agents return-shape change ~10 LOC + _build_mock_agents dict construction ~25 LOC + build_use_case 3 lines call-site update - 30 LOC removed from old 3-tuple unpacking = net ~50 LOC)

### D4 — Test additions + regression coverage (≥18 NEW unit tests across 2 files)

**Target**: `packages/application/analysis/test_use_case.py` + `packages/infrastructure/analysis/test_synthesizer.py`

**Changes to test_use_case.py**:
- UPDATE `_make_use_case` helper at :204-239: ADD `agents: dict[PerspectiveRole, LLMPerspectivePort] | None = None` kwarg; if None, construct default V0=3 dict from existing bear_responses/bull_responses/quant_responses params; if provided, use directly (backward-compat path)
- ADD NEW test fixture `_make_v0_6_agents() → dict[PerspectiveRole, LLMPerspectivePort]` constructing all 6 personas via MockLLMPerspectivePort
- ADD 8 NEW test cases (total ≥18 across both files):
  - **TC-USE-CASE-1**: `test_n6_happy_path_returns_submitted_thesis` — V0=6 happy path; SUBMITTED status
  - **TC-USE-CASE-2**: `test_n6_persists_thesis_to_repo` — V0=6 thesis saved to repo
  - **TC-USE-CASE-3**: `test_n6_emits_thesis_recorded_event` — V0=6 ThesisRecorded event emitted
  - **TC-USE-CASE-4**: `test_n6_thesis_id_deterministic_across_runs` — AC-5 DD-8 scenario 2 (N=6 same input twice → same thesis_id)
  - **TC-USE-CASE-5**: `test_n6_thesis_id_invariant_under_dict_insertion_order` — AC-5 DD-8 scenario 3 (N=6 shuffled dict insertion order → same thesis_id; validates STABLE-SORTED-BY-ROLE design)
  - **TC-USE-CASE-6**: `test_n6_bear_missing_returns_incomplete` — DD-4 I-S10 BEAR-presence preserved (V0=5 missing BEAR → BearCaseInvariantError → INCOMPLETE)
  - **TC-USE-CASE-7**: `test_n6_cost_accumulation_across_all_personas` — DD-6 sum across N personas (cost_usd correctly accumulated across 6 personas)
  - **TC-USE-CASE-8**: `test_n6_thesis_id_differs_from_n3_same_input` — AC-5 DD-8 scenario 4 (N=3 vs N=6 on same ticker/data → different thesis_id by design)

**Changes to test_synthesizer.py**:
- ADD NEW test fixture `_make_n6_perspectives(ticker)` constructing V0=6 perspectives
- ADD 10 NEW test cases:
  - **TC-SYNTH-1**: `test_n6_disagreement_pairwise_across_all_personas` — DD-5 pairwise extension (V0=6 with STRONG/WEAK pair beyond BEAR-vs-BULL → disagreement detected)
  - **TC-SYNTH-2**: `test_n6_three_personas_disagree_emits_multiple_disagreements` — N=3 personas with verdict-disagreement on same dim → ≥3 Disagreement entries (C(3,2)=3 pairs)
  - **TC-SYNTH-3**: `test_n6_quant_favoured_preserved_with_additional_personas` — DD-3 QUANT-favoured rule extends to N>3 (QUANT verdict wins for dim scoring regardless of BUFFETT/GRAHAM/TALEB)
  - **TC-SYNTH-4**: `test_n6_majority_categorical_when_quant_absent` — DD-3 majority-categorical scoring (no QUANT; 4 personas STRONG on VALUE; 2 personas WEAK → VALUE score = STRONG)
  - **TC-SYNTH-5**: `test_n6_tie_defaults_to_neutral` — DD-3 3-3 tie behavior (3 personas STRONG + 3 personas WEAK → NEUTRAL)
  - **TC-SYNTH-6**: `test_n6_no_strong_consensus_with_disagreements_invariant_preserved` — I-S12 preservation (V0=6 with disagreement → confluence=DISAGREEMENT NOT STRONG_CONSENSUS; SynthesisInvariantError NOT raised)
  - **TC-SYNTH-7**: `test_n6_strong_consensus_when_all_personas_align` — V0=6 all 6 personas verdict-STRONG on all dims → STRONG_CONSENSUS confluence (no disagreements)
  - **TC-SYNTH-8**: `test_n6_catalysts_still_from_bull_only` — DD-3 architect decision (catalysts canonically from BULL not new personas)
  - **TC-SYNTH-9**: `test_n6_risks_still_from_bear_only` — DD-3 architect decision (risks canonically from BEAR not new personas)
  - **TC-SYNTH-10**: `test_n6_reasoning_trace_includes_persona_counts` — D2 reasoning_trace extension validation

**Verification at end of D4**:
- mypy --strict CLEAN
- ruff CLEAN
- pytest test count: existing N=3 tests (≥10 in test_use_case + ≥6 in test_synthesizer = ≥16) STILL PASS + 18 NEW tests PASS = total ≥34
- Regression floor: existing test_validate_thesis.py + test_phase1_gatherer.py + test_adapter.py + test_bear_agent.py + test_quant_agent.py + test_buffett_agent.py + test_graham_agent.py + test_taleb_agent.py + test_role_prompt_pack.py + test_persona_registry.py STILL PASS

**LOC delta**: ~400-500 LOC across 2 test files (18 new tests × ~25 LOC avg per test + new fixtures)

### D5 — ADR D-076 PROPOSED at IMPL tier (~200 LOC new ADR file)

**Target**: NEW `agent-workspace/memory/decisions/076-bc-8-n-perspective-synthesizer-and-use-case-generalization.md`

**Content** (200 LOC sections):
- **Frontmatter**: 12-field standard ADR schema (decision_id=D-076, status=PROPOSED, supersedes=[], superseded_by=[], related_to=[D-074, D-075, D-054, D-059, D-060, master plan-033], proposed_at=2026-05-17, ratified_at=null per IMPL-tier ADR auto-ratify on commit per severity-schema)
- **Context**: F.3 sub-plan ships BC-8 N-perspective aggregation extension (BEAR/BULL/QUANT + BUFFETT/GRAHAM/TALEB = V0=6); existing 3-persona pipeline (validate_thesis_phase1.py + phase1_synthesizer.py) requires N-persona generalization
- **Decision**:
  1. N-persona dispatch shape = `dict[PerspectiveRole, LLMPerspectivePort]` (DD-1)
  2. AC-5 reproducibility via STABLE-SORTED-BY-ROLE combined_prompt construction (DD-2)
  3. Phase1Synthesizer aggregation = MAJORITY-CATEGORICAL (DD-3) preserving QUANT-favoured + pairwise disagreement detection extension (DD-5)
  4. I-S10 BEAR-presence preserved at Thesis layer (DD-4); I-S12 disagreement-preservation preserved at Synthesis layer (DD-5)
  5. Per-persona cost accumulation via sum comprehension (DD-6)
  6. Composition root V0=6 wiring via `_load_persona_registry()` + `_build_persona_agents()` helpers (DD-7)
  7. Catalysts/risks attribution PRESERVED to BULL/BEAR canonically (DD-3)
  8. _ROLE_TO_MODEL extension DEFERRED to F.4 OR fix-inline-if-trivial at F.3 IMPL (DD-9)
- **Consequences**:
  - + Extensible to V0=9 (F.4) without ctor signature churn
  - + Backward-compat with existing 3-persona path (composition root + test fixtures)
  - + AC-5 deterministic-per-tuple preserved under N-persona path
  - + I-S10/I-S12/I-S35 invariants preserved by-construction
  - + DD-10 from F.2 pattern-port-NOT-code-port discipline preserved (50+ char grep gate against ai-hedge-fund portfolio_manager.py)
  - - Disagreement field names (`bear_verdict`/`bull_verdict`) misleading for N-persona path (DD-5 acknowledged trade-off; F.3-V2 rename)
  - - V0=6 cost-profile risk if BUFFETT/GRAHAM/TALEB run on Opus default (architect FLAGS in § J RM3; F.4 OR fix-inline)
  - - F.3-V2 candidates named: weighted-by-conviction confluence + tie-breaker rule + Disagreement field rename
- **Compliance attestation**: 0 charter / 0 constitution / 0 production behavior change to existing 3-persona path (regression-floor preserved); D-060 ✓ (commit by dev; no push); D-074/D-075 IPML-tier ADRs honored; 50+ char substring grep gate against ai-hedge-fund/portfolio_manager.py + risk_manager.py PASSED (zero verbatim code-copy); master plan-033 § E.3 DoD floor preserved

**Verification at end of D5**:
- ADR file exists at correct path
- Frontmatter parses (12 fields per schema)
- Cross-references to D-074/D-075/master plan-033 valid

**LOC delta**: ~200 LOC new file

### Sub-track sequencing summary (S381 IMPL ordering)

| D-N | Target file | LOC delta | Verification gate | Estimated wall-min |
|---|---|---|---|---|
| D1 | validate_thesis_phase1.py | ~30 | mypy + ruff + (D4 tests pass after D4) | 8-12 |
| D2 | phase1_synthesizer.py | ~80 | mypy + ruff + existing test_synthesizer.py PASS | 15-20 |
| D3 | use_case_builder.py | ~50 | mypy + ruff + composition smoke | 10-15 |
| D4 | test_use_case.py + test_synthesizer.py | ~400-500 | pytest 18 new PASS + regression floor | 20-30 |
| D5 | 076-*.md ADR | ~200 | manual file-exists + frontmatter parse | 5-10 |
| **TOTAL** | 6 files | ~760-860 | All gates GREEN | **58-87 min** |

**Architect recommendation**: SEQUENTIAL D1 → D2 → D3 → D4 → D5 for ZERO regression risk. Dev MAY interleave D1+D4 (refactor use case + write tests against new signature in same session) if pattern crystallizes early. Dev MUST NOT skip D2 before D4 (test_synthesizer.py tests depend on D2 N-persona extension shipped).

---

## F. Definition of Done (sub-plan-level — ≥25 items)

DoD for THIS sub-plan (covers PLAN authoring S380 + IMPL S381 + VERIFY S382; PLAN-tier items checked-off this session):

**PLAN-tier (S380 sandwich-architect THIS session)**:
- [ ] **DC-PLAN-1** — `agent-workspace/session-plans/pending/036-S380-phase-f3-synthesize-perspectives-usecase.md` exists (this file)
- [ ] **DC-PLAN-2** — `agent-workspace/memory/observations/sandwich-architect-S380-phase-f3-plan.md` exists (per agent-template L207-210 mandate)
- [ ] **DC-PLAN-3** — § A.4 Calibration summary populated (Phase 1b CONSUMED variant; n=2 multi-perspective-impl precedent declared per S375+S378)
- [ ] **DC-PLAN-4** — § D contains ≥10 DD architecture decisions all with rationale + adversarial alternates
- [ ] **DC-PLAN-5** — § E contains 5 sub-tracks D1-D5 with file targets + LOC delta + verification gates + estimated wall-min
- [ ] **DC-PLAN-6** — § G contains AQ-1..AQ-10 pre-answered
- [ ] **DC-PLAN-7** — § H contains 5-source-evidence chain
- [ ] **DC-PLAN-8** — § J contains ≥10 RM entries with mitigation
- [ ] **DC-PLAN-9** — § K Charter-tier-surface section enumerates anticipated FLAGS (LIKELY-NONE per master plan § K.1)
- [ ] **DC-PLAN-10** — § L Phase 1b Calibration documented with n=2 narrow precedent
- [ ] **DC-PLAN-11** — § M Charter-tier gate documented (LIKELY-NONE; defer to master plan)
- [ ] **DC-PLAN-12** — § N Phase F-prime → F.4/F.5 sequencing recommendation documented

**IMPL-tier (S381 sandwich-dev — checked at IMPL session)**:
- [ ] **DC-IMPL-1** — D1 validate_thesis_phase1.py REFACTOR complete (~30 LOC delta; ctor + parallel dispatch + cost accumulation + combined_prompt sorted-by-role)
- [ ] **DC-IMPL-2** — D2 phase1_synthesizer.py EXTEND complete (~80 LOC delta; by_role lookup + pairwise disagreement detection + majority-categorical scoring + reasoning_trace)
- [ ] **DC-IMPL-3** — D3 use_case_builder.py composition root V0=6 wiring complete (~50 LOC delta; _load_persona_registry + _build_persona_agents + dict construction)
- [ ] **DC-IMPL-4** — D4 ≥18 NEW unit tests added (8 in test_use_case.py + 10 in test_synthesizer.py)
- [ ] **DC-IMPL-5** — D5 ADR D-076 PROPOSED at correct path (200 LOC; 12-field frontmatter)
- [ ] **DC-IMPL-6** — mypy --strict CLEAN across all 6 modified files
- [ ] **DC-IMPL-7** — ruff CLEAN across all 6 modified files
- [ ] **DC-IMPL-8** — pytest: existing test count preserved + 18 NEW tests PASS
- [ ] **DC-IMPL-9** — Regression floor PASS: test_validate_thesis.py + test_phase1_gatherer.py + test_adapter.py + test_bear_agent.py + test_quant_agent.py + test_buffett_agent.py + test_graham_agent.py + test_taleb_agent.py + test_role_prompt_pack.py + test_persona_registry.py
- [ ] **DC-IMPL-10** — AC-5 deterministic-per-tuple regression PASS (TC-USE-CASE-4/5/8)
- [ ] **DC-IMPL-11** — I-S10 BEAR-presence preservation PASS (TC-USE-CASE-6)
- [ ] **DC-IMPL-12** — I-S12 disagreement-preservation PASS (TC-SYNTH-6/7)
- [ ] **DC-IMPL-13** — 50+ char substring grep gate PASS against `C:/htdocs/research/ai-hedge-fund/src/agents/portfolio_manager.py` + `risk_manager.py` (DD-10 from F.2 carry-forward)
- [ ] **DC-IMPL-14** — Composition root smoke PASS (build_use_case(mock_llm=True) instantiates ValidateThesisPhase1UseCase with V0=6 agents)
- [ ] **DC-IMPL-15** — D-060 compliance (commit by dev; no push)

**VERIFY-tier (S382 sandwich-verifier AP-1 fresh-context)**:
- [ ] **DC-VERIFY-1** — V1 acceptance criteria: 18 NEW tests verified by independent execution
- [ ] **DC-VERIFY-2** — V2 charter compliance: I-S1/I-S1-1/I-S10/I-S12/I-S35/AC-5 invariants preserved
- [ ] **DC-VERIFY-3** — V3 architecture compliance: master plan-033 § E.3 DoD floor + DD-10 EXTENSION-NOT-PARALLEL-CLASS
- [ ] **DC-VERIFY-4** — V4 regression floor: all existing tests still pass
- [ ] **DC-VERIFY-5** — V5 integration smoke: composition root + mock V0=6 dogfood
- [ ] **DC-VERIFY-6** — V6 compliance attestation: 0 charter / 0 constitution / 0 production behavior change to existing 3-persona path

**Total**: 27 DoD items (12 PLAN + 15 IMPL + 6 VERIFY).

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why dict[PerspectiveRole, LLMPerspectivePort] not sequence-of-agents tuple?

**Answer**: Per DD-1. Role-keyed lookup matches existing `_ROLE_TO_MODEL` pattern at claude_llm_perspective_adapter.py:72-76; self-documenting (`agents[PerspectiveRole.BEAR]` clearer than `agents[0]`); allows N>3 personas via dict entry addition without ctor signature churn; AC-5 reproducibility preserved via DD-2 STABLE-SORTED-BY-ROLE.

### AQ-2 — Why MAJORITY-CATEGORICAL aggregation not weighted-by-conviction?

**Answer**: Per DD-3. Karpathy P2 simplicity-first; A-01 § 5 third bullet WAVE-1 DEFAULT (deterministic-pre-computation pattern); calibration question (what weights match historical reliability?) is post-MVP. F.3-V2 candidate: weighted-by-conviction IF V0 dogfood (F.5) reveals MAJORITY-CATEGORICAL produces empirically-poor confluence on 3+ different VN tickers.

### AQ-3 — Why EXTEND existing Phase1Synthesizer not NEW SynthesizePerspectivesUseCase class?

**Answer**: Per master plan-033 DD-10 + § A.3 row 7. Duplicate orchestration logic; F.3 ships ONE use case handling 3+N personas via dict-typed agents param; existing 3-persona call sites construct dict {BEAR: bear, BULL: bull, QUANT: quant}; new 6-persona call sites construct dict with 6 entries.

### AQ-4 — Why preserve I-S10 BEAR-presence at Thesis layer not re-enforce at synthesizer?

**Answer**: Per DD-4. Existing invariant at correct layer (Thesis aggregate-root); F.3 N-persona path passes through Thesis aggregate which raises BearCaseInvariantError if BEAR missing → use case catches → returns Thesis.incomplete(); SAME behavior as N=3 path; DRY discipline.

### AQ-5 — Why DD-5 keep `bear_verdict`/`bull_verdict` field names for N-persona pairwise Disagreement?

**Answer**: Per DD-5. Field name retention preserves backward-compat at Synthesis aggregate + test fixtures + persistence layer; Disagreement.note extension clarifies pairwise semantics ("{p1.role} {verdict1} vs {p2.role} {verdict2} on {dim}"); F.3-V2 rename candidate (Karpathy P3 surgical-changes; cross-layer rename = broader regression — defer).

### AQ-6 — STEP 0 finds Phase1Synthesizer extension >120 LOC delta — what then?

**Answer**: Per § C.5 STOP-AND-ASK trigger #1. Dev escalates to architect-tier sub-plan refinement; options: (a) parallel-class fallback `Phase1NPerspectiveSynthesizer` (legacy Phase1Synthesizer preserved for N=3 path; new class handles N>3); (b) split into 2 IMPL sessions S381+S381b per master plan AQ-7 "MAY_SPLIT_IF_>4H"; (c) reduce scope (e.g. defer per-dim pairwise to F.3-V2; ship only majority-categorical scoring). Sub-plan 036 PLAN does NOT preclude options; dev judgment per STEP 0.

### AQ-7 — AC-5 thesis_id regression: existing N=3 thesis_id values change under sorted-by-role?

**Answer**: Per DD-2. For V0=3 path with BEAR/BULL/QUANT: sorted ordering = ("bear", "bull", "quant") which is INCIDENTALLY the same as existing implicit dispatch order at validate_thesis_phase1.py:226 `(bear_p, bull_p, quant_p)` — so AC-5 thesis_id values DO NOT CHANGE under sorted-by-role implementation for N=3 path. F.3 dev MUST regression-test by computing thesis_id with old + new formula on N=3 fixture and confirming equality (TC-USE-CASE-4 N=3 baseline regression scenario). IF regression test reveals divergence (unlikely; sorted("bear"/"bull"/"quant") = same as existing), escalate to architect-tier for migration path design.

### AQ-8 — D3 composition root `_build_persona_agents` requires PersonaRegistry — what if registry load fails (file missing)?

**Answer**: PersonaRegistry.load_from_json() at persona_registry.py:80-156 raises PersonaRegistryError if file missing OR path-safety violation OR JSON malformed; composition root path `_load_persona_registry()` propagates exception → `build_use_case()` raises BuildError; CLI entry point catches BuildError + reports to user. F.3 dev MUST verify V0 packs (buffett.json + graham.json + taleb.json) exist + are well-formed before composition root attempt; existing F.2 plan-035 IMPL shipped these per S378 close-bookkeeping; STEP 0 sub-step 0.3 confirms.

### AQ-9 — What if BUFFETT/GRAHAM/TALEB falls through to Opus default per _ROLE_TO_MODEL absence?

**Answer**: Per DD-9 architect FLAGS asymmetry. V0 cost-impact: 3 personas × Opus ≈ 3 × $15/MTok = $45/MTok input vs Sonnet preference = 3 × $3/MTok = $9/MTok = 5× cost. scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:187 STILL holds — CostBudgetExceeded if cumulative > $3.00. F.3 dev MAY fix inline (3-line addition to _ROLE_TO_MODEL) if STEP 0 judges trivial OR DEFER to F.4 / F.3-V2; architect leans dev-judgment + STEP 0 evidence (NOT mandated by F.3 plan).

### AQ-10 — What if F.3 IMPL surfaces I-S12 invariant violation (Phase1Synthesizer N-perspective rewrite breaks STRONG_CONSENSUS+disagreements check)?

**Answer**: Per master plan AQ-10 + § C.5 STOP-AND-ASK trigger #5. Dev MUST fix inline before commit; if multiple iterations fail, escalate via STEP 0 STOP-AND-ASK to architect-tier sub-plan refinement (rare; existing tests at test_synthesizer.py + new tests TC-SYNTH-6/7 should catch). I-S12 invariant at synthesis.py:89-100 unchanged; SynthesisInvariantError raises at __post_init__ if STRONG_CONSENSUS + non-empty disagreements — Phase1Synthesizer N-perspective code path MUST NOT construct such Synthesis.

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (deep-dive obs) | Source 2 (master plan-033) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | EXTEND existing ValidateThesisPhase1UseCase (DD-1+DD-10 carry-forward) | `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` § 5 third bullet "isolated-then-aggregate WAVE-1 DEFAULT" | master plan-033 § E.3 DD-10 "EXTEND existing ValidateThesisPhase1UseCase NOT new SynthesizePerspectivesUseCase class" + § L plan-vs-master-plan rationale | I-S12 (Disagreement Surfaced, Not Resolved — preserved via Synthesis.__post_init__) + AC-5 reproducibility (thesis_id sha256 over combined_prompt) | `packages/application/analysis/use_cases/validate_thesis_phase1.py:142-289` existing 7-step pipeline; `packages/infrastructure/analysis/phase1_synthesizer.py:102-261` existing deterministic synthesizer | ai-hedge-fund `src/main.py:112-115` parallel fan-out + `portfolio_manager.py:160-175` role-keyed `{ticker: {agent_id: {sig, conf}}}` aggregation table |
| 2 | dict[PerspectiveRole, LLMPerspectivePort] dispatch shape (DD-1) | (architect-tier decision; no single deep-dive citation) | master plan-033 DD-12 per-persona model routing via `_ROLE_TO_MODEL: dict[PerspectiveRole, str]` precedent | I-S1 by-construction (per-persona LLM emits ONLY categorical+reasoning+GroundedPoint; aggregation deterministic) | `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:72-76` `_ROLE_TO_MODEL: dict[PerspectiveRole, str]` existing pattern | ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict (pattern-port not code-port per A-01 § 6) |
| 3 | STABLE-SORTED-BY-ROLE combined_prompt construction for AC-5 (DD-2) | (architect-tier decision) | master plan-033 § A AC-5 reproducibility constraint inherited from spec 006 § B.3 | AC-5 thesis_id deterministic-per-tuple (per spec 006 § B.3 + thesis.py:67) + D-059 R2 (unseeded RNG forbidden; defense-in-depth via explicit sort) | `packages/application/analysis/use_cases/validate_thesis_phase1.py:238` existing combined_prompt computation; existing 3-persona implicit ordering happens to match sorted-by-role | (no external pattern; AC-5 reproducibility is stockforge-specific invariant) |
| 4 | MAJORITY-CATEGORICAL aggregation (DD-3) | A-01 § 5 third bullet ISOLATED-THEN-AGGREGATE WAVE-1 DEFAULT + A-01 § 2 bullet 4 "deterministic-then-LLM split" | master plan-033 § E.3 DD-10 "majority-categorical per Karpathy P2 simplicity; weighted-by-conviction is F.3-V2 refinement" + § A.3 row 3 AP-7 revisit trigger | I-S1 (NO LLM math; categorical-majority is pure deterministic Python aggregation) + I-S1-1 Rule 16 mode 1 categorical surrogate | `packages/infrastructure/analysis/phase1_synthesizer.py:189-207` existing QUANT-favoured + bear/bull average scoring (analogous to majority-categorical for N=3) | ai-hedge-fund `portfolio_manager.py:96-157` `compute_allowed_actions()` deterministic-pre-computation pattern |
| 5 | EXTEND PAIRWISE across N-personas (DD-5) | A-01 § 5 bullet 4 "no inter-agent messaging; PM sees only role-keyed signal table" | master plan-033 § E.3 sub-plan 036 § Charter-tier touch + § K.2 anticipated FLAGS for tie-breaker rule | I-S12 (Disagreement Surfaced, Not Resolved — invariant at Synthesis.__post_init__:89-100; pairwise detection extension preserves invariant by construction) | `packages/infrastructure/analysis/phase1_synthesizer.py:134-187` existing BEAR-vs-BULL pairwise per-dim detection; itertools.combinations stdlib for N-pair extension | (pairwise comparison is general algorithm; no external library required) |

---

## I. Risks & Mitigation (RM1-RM12)

### RM1 — AC-5 thesis_id regression on N=3 path (LIKELY-LOW; DD-2 mitigated)
**Risk**: STABLE-SORTED-BY-ROLE combined_prompt construction CHANGES existing N=3 thesis_id values if sorted("bear", "bull", "quant") differs from existing implicit dispatch order.
**Mitigation**: AQ-7 verifies existing N=3 sorted order INCIDENTALLY matches existing implicit dispatch order (alphabetic ordering of {bear, bull, quant} = same); F.3 dev TC-USE-CASE-4 N=3 baseline regression confirms; IF regression test fails, escalate per STEP 0 STOP-AND-ASK trigger #3.

### RM2 — Existing 3-persona test_use_case.py + test_synthesizer.py regression (LIKELY-MEDIUM; D4 mitigates)
**Risk**: F.3 ctor signature change at validate_thesis_phase1.py:153-171 breaks existing test_use_case.py _make_use_case helper at :204-239 (passes bear_agent+bull_agent+quant_agent params); F.3 phase1_synthesizer.py extension may break existing test_synthesizer.py tests.
**Mitigation**: D4 UPDATES _make_use_case helper to support both 3-agent and dict-typed agents kwarg (backward-compat default); D4 NEW tests are additive not replacement; D2 extension at phase1_synthesizer.py preserves existing N=3 BEAR/BULL/QUANT-named lookup path (by_role.get() returns existing perspective if present).

### RM3 — V0=6 cost-profile risk (LIKELY-MEDIUM; DD-9 FLAGS)
**Risk**: BUFFETT/GRAHAM/TALEB fall through _ROLE_TO_MODEL to Opus default per claude_llm_perspective_adapter.py:77 = 5× cost vs Sonnet preference in role-pack JSON model_id_preference.
**Mitigation**: scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:187 STILL caps cumulative cost; CostBudgetExceeded raises if > $3.00 → Thesis.incomplete(); F.3 dev MAY fix inline by adding 3 _ROLE_TO_MODEL entries (5 LOC delta) if STEP 0 judges trivial; F.5 dogfood empirically measures cost-impact.

### RM4 — Phase1Synthesizer extension LOC overrun (LIKELY-LOW; STEP 0.5 mitigates)
**Risk**: D2 extension exceeds architect-projected ~80 LOC delta (e.g. dev refactors deeper than planned; reaches >120 LOC).
**Mitigation**: STEP 0 STOP-AND-ASK trigger #1 fires; dev escalates to architect-tier sub-plan refinement (parallel-class fallback `Phase1NPerspectiveSynthesizer` OR split into S381+S381b); architect re-budgets if needed.

### RM5 — Composition root build_use_case backward-compat break (LIKELY-MEDIUM; D3 mitigates)
**Risk**: F.3 D3 changes _build_subagent_agents return type from 3-tuple to dict; existing callers that unpack 3-tuple break.
**Mitigation**: D3 UPDATES build_use_case at :112-135 call site to use dict directly (no 3-tuple unpacking in calling code post-D3); existing apps/cli/validate_thesis.py + apps/dashboard/pages/validate_thesis.py call only build_use_case (not _build_subagent_agents directly per use_case_builder.py:1-30 docstring); ZERO downstream callers break.

### RM6 — Disagreement field name semantic drift (LIKELY-MEDIUM; DD-5 acknowledged)
**Risk**: `bear_verdict`/`bull_verdict` fields on Disagreement dataclass at synthesis.py:48-66 misleading for N-persona pairwise comparison (e.g. BUFFETT-vs-TALEB disagreement records `bear_verdict=BUFFETT.verdict` + `bull_verdict=TALEB.verdict`).
**Mitigation**: DD-5 explicit decision — field names retained for backward-compat (Karpathy P3 surgical-changes); Disagreement.note extension clarifies pairwise semantics ("{p1.role} {verdict1} vs {p2.role} {verdict2} on {dim}"); F.3-V2 rename candidate documented.

### RM7 — AC-5 deterministic-per-tuple regression under N>3 (LIKELY-LOW; D4 mitigates)
**Risk**: N-persona path may break AC-5 reproducibility if (a) dict iteration order non-deterministic OR (b) sorted-by-role ordering not consistently applied OR (c) per-persona prompt_hash changes across runs.
**Mitigation**: DD-2 STABLE-SORTED-BY-ROLE combined_prompt construction is defense-in-depth (D-059 R2 already protects dict order; explicit sort is additional layer); D4 TC-USE-CASE-4/5/8 cover same-input-twice + shuffled-insertion-order + N=3-vs-N=6 scenarios.

### RM8 — I-S10 BEAR-presence enforcement gap if dev removes Thesis._enforce_bear_case (LIKELY-VERY-LOW; binding_decisions guards)
**Risk**: F.3 dev might remove Thesis._enforce_bear_case at thesis.py:91-115 misunderstanding "preserve I-S10" as "move invariant".
**Mitigation**: DD-4 explicit decision; binding_decisions in frontmatter "I-S10 BEAR-PRESENCE INVARIANT PRESERVED"; D4 TC-USE-CASE-6 regression test (V0=5 missing BEAR → INCOMPLETE thesis) catches removal.

### RM9 — I-S12 disagreement-preservation gap if pairwise extension introduces SynthesisInvariantError race (LIKELY-LOW; D4 mitigates)
**Risk**: F.3 D2 pairwise extension may construct Synthesis with STRONG_CONSENSUS + non-empty disagreements due to scoring/disagreement-detection race (e.g. scoring picks STRONG_CONSENSUS but pairwise detection finds disagreement on different dim).
**Mitigation**: Existing Phase1Synthesizer.synthesize() at phase1_synthesizer.py:214-221 sets `confluence = Confluence.DISAGREEMENT` first if any disagreement detected (any dim) — preserves I-S12 by-construction; D2 extension PRESERVES this ordering; D4 TC-SYNTH-6/7 regression coverage; if violation surfaces, SynthesisInvariantError raises at __post_init__ → use case catches as Thesis.incomplete().

### RM10 — `import itertools` missing or version-incompatibility (LIKELY-VERY-LOW)
**Risk**: D2 adds `import itertools` to phase1_synthesizer.py; stdlib module — always available; no version risk.
**Mitigation**: N/A — stdlib.

### RM11 — DD-10 from F.2 50+ char substring grep gate violation (LIKELY-LOW; binding_decisions guards)
**Risk**: F.3 dev copies verbatim from ai-hedge-fund portfolio_manager.py:160-175 (role-keyed aggregation table) OR risk_manager.py (vol-adjusted limit) instead of pattern-port re-implementation.
**Mitigation**: binding_decisions in frontmatter "DD-10 from F.2 (pattern-port NOT code-port) CARRY-FORWARD"; D5 ADR compliance attestation includes "50+ char substring grep gate against ai-hedge-fund/portfolio_manager.py + risk_manager.py PASSED (zero verbatim code-copy)"; VERIFY S382 verifier independently runs grep gate.

### RM12 — Test count regression (LIKELY-LOW; D4 mitigates)
**Risk**: Existing test count at S378 close (~1153 tests per S375 close-bookkeeping) decreases due to test refactoring.
**Mitigation**: D4 _make_use_case helper UPDATE preserves backward-compat default; ZERO existing tests removed; 18 NEW tests ADDED; total ≥1171 expected post-F.3.

---

## J. Coordination paths (during S381 IMPL window)

**Exclusive ownership during S381 dev session**:
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (REFACTOR — D1)
- `packages/infrastructure/analysis/phase1_synthesizer.py` (EDIT — D2)
- `apps/_shared/use_case_builder.py` (EDIT — D3)
- `packages/application/analysis/test_use_case.py` (NEW tests — D4)
- `packages/infrastructure/analysis/test_synthesizer.py` (NEW tests — D4)
- `agent-workspace/memory/decisions/076-bc-8-n-perspective-synthesizer-and-use-case-generalization.md` (NEW — D5)

**Read-only / no-touch during S381**:
- `packages/application/analysis/role_prompt_pack.py` (F.1 substrate; LEAF dependency)
- `packages/application/analysis/persona_registry.py` (F.1 substrate; LEAF dependency)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (F.1 transport-flip shipped; F.3 DD-9 _ROLE_TO_MODEL extension OPTIONAL inline fix; architect leans dev-judgment)
- `packages/infrastructure/analysis/perspectives/buffett_agent.py` + `graham_agent.py` + `taleb_agent.py` (F.2 substrate; LEAF dependency)
- `agent-workspace/role-packs/buffett.json` + `graham.json` + `taleb.json` (F.2 V0 packs; READ via PersonaRegistry; no edit)
- `packages/domain/analysis/models/synthesis.py` (Synthesis aggregate + I-S12 invariant; READ-ONLY; F.3 PRESERVES)
- `packages/domain/analysis/models/thesis.py` (Thesis aggregate + I-S10 invariant; READ-ONLY; F.3 PRESERVES)
- `packages/domain/analysis/models/perspective_analysis.py` (PerspectiveAnalysis + PerspectiveRole enum 9 values; READ-ONLY; F.3 PRESERVES)
- `packages/application/analysis/services/recommendation_heuristic.py` (pure-deterministic; READ-ONLY; F.3 PRESERVES — already N-persona-agnostic by-construction)

**Cross-sub-plan coordination**:
- F.3 BLOCKS F.4 (sub-plan 037) + F.5 (sub-plan 038) per master plan § E.3
- F.4 / F.5 parallel-eligible POST-F.3 ship per master plan § E.5+E.4 (architect-tier parallel-dispatch validated at 4-parallel S345; main session orchestrates)

---

## K. Budget per FOCUSED_IMPL-Opus 100-150K (no split unless STEP 0.5 STOP-AND-ASK fires)

**Architect projection**:
- IMPL S381: 100-150K Opus FOCUSED_IMPL (architect leans 130-145K real-tokens per regression-heavy nature + 6 files modified)
- Single-session preferred; SPLIT to S381+S381b only if STEP 0.5 STOP-AND-ASK trigger #1 fires (Phase1Synthesizer extension >120 LOC delta) OR trigger #4 fires (composition root regression cascade)
- Wall-clock estimate: 58-87 min total per § E sequencing summary

**Per CLAUDE.md recalibrated PLAN-Opus envelope**:
- THIS plan authoring (S380): 150-200K Opus PLAN target (within dispatch brief 150-230K ceiling); architect estimates ~165K real-tokens for this plan + observation file
- VERIFY S382: 30-60K Opus AP-1 fresh-context

**Cumulative F.3 budget envelope**: PLAN ~165K + IMPL ~140K + VERIFY ~45K = ~350K Opus total across 3 sessions.

**Compared to master plan-033 § A.4 PLAN BUDGET DERIVATION** F.3 sub-plan estimate: "~210-340K cumulative" — F.3 actual landing at ~350K aligns with high end of envelope (regression-heavy F.3 nature; aligns with n=2 multi-perspective-impl precedent suggesting F.3 IMPL slightly more complex than F.1+F.2).

---

## L. Phase 1b Calibration (n=2 multi-perspective-impl narrow precedent)

**task_class declared**: `multi-perspective-impl` (now n=2 — established post-S378)

**sample_size**: 2 (S375 F.1 + S378 F.2)

**Calibration precedent**:
- **S375 F.1 IMPL** (RolePromptPack + PersonaRegistry + BC-8 transport-flip): Sonnet 4.6 FOCUSED_IMPL; 5 sub-tracks D1-D5; per S375 close-bookkeeping "All STEP 0 gates evaluated; CHARTER-TIER GATE DID NOT FIRE"; clean shipment; ADR D-074 PROPOSED; test count 1113 → 1153 (+40)
- **S378 F.2 IMPL** (3 personas Buffett/Graham/Taleb): per S378 close-bookkeeping single-session shipment; 3 personas × ~250-310 LOC + 3 V0 JSON role-packs + tests; ADR D-075 PROPOSED; PerspectiveRole enum extended (+3 values)

**Common shape (both precedents)**:
- Single FOCUSED_IMPL session; clean shipment; ADR PROPOSED at IMPL tier per severity-schema auto-ratify on commit
- Sub-track decomposition (D1-D5 typical)
- 0 charter / 0 constitution / 0 production behavior change to existing pipelines
- Regression floor preserved across existing test files

**F.3-specific deltas vs precedent**:
- **HIGHER complexity** — F.3 refactors EXISTING orchestration vs F.1+F.2 SHIPPED NEW substrate (BC-8 transport-flip in F.1 was nearest-analog refactor but smaller-surface); regression risk floor higher per master plan § J RM5
- **MORE files modified** — F.3 touches 3 production + 2 test + 1 ADR = 6 files vs F.1's 3-4 files; F.2's 6 files-each-leaf
- **TIGHTER backward-compat discipline** — F.3 must preserve EXACTLY 1153 tests + existing test fixtures + AC-5 thesis_id values for N=3 path

**Calibration adjustment**: F.3 IMPL budget high-end of envelope (130-145K Opus) per HIGHER complexity; single-session preferred per n=2 precedent (S375 + S378 both single-session); SPLIT to S381+S381b ONLY if STEP 0.5 STOP-AND-ASK fires.

**Cold-start status**: NOT cold-start for `multi-perspective-impl` task_class (n=2); NARROW cold-start for F.3-specifically (no prior IMPL of role-aware Phase1Synthesizer extension; F.3 is the first).

**Planner-feedback-loop.sh gap CARRY-FORWARD per master plan-033 § A.4** (L-S354-2/L-S366-4/L-S369-1 cascade): `.planner-stats.tsv` STILL header-only at S380 entry; planner-feedback-loop.sh did not auto-populate after S378 close-bookkeeping; harness gap belongs to separate harness-stabilization sweep (NOT this product sub-plan).

---

## M. Charter-tier gate (LIKELY-NONE per master plan-033 § K.1)

**Master plan verdict carry-forward**: "NO CHARTER-TIER BLOCKING FLAGS. All 3 anticipated flags use NON-BLOCKING design with architect-recommended defaults; Phase F-prime proceeds without explicit user-ratification gate."

**F.3 sub-plan inherits NON-BLOCKING design**:
- No new I-S<N> invariant proposed (DD-10)
- No new Rule 16 mode requested
- No persona pack changes (consumes F.2-shipped role packs as-is)
- All architect decisions documented with adversarial alternates + adopted-default rationale

**Potential mid-IMPL FLAG (anticipated per master plan § K.2)**:
- **Sub-plan 036 (F.3 N-persona use case extension)**: "Phase1Synthesizer N-perspective confluence calculation surfaces ambiguity (e.g. 3-3 tie across STRONG_CONSENSUS vote with mixed verdicts) → architect-tier sub-plan refinement OR new I-S<N> invariant for 'tie-breaker' rule → CANDIDATE CHARTER-TIER FLAG (sub-plan 036 STEP 0 STOP-AND-ASK)"

**Mitigation per DD-3 + DD-10**: F.3 V0 ships MAJORITY-CATEGORICAL aggregation with tie-defaults-to-NEUTRAL rule (deterministic; no LLM); 3-3 ties handled by NEUTRAL default; CHARTER-TIER FLAG fires ONLY if F.3 IMPL surfaces empirical evidence that tie-breaker rule is insufficient (rare; existing tests should catch).

**Verdict**: NO CHARTER-TIER GATE at F.3 PLAN-tier; sub-plan 036 STEP 0 STOP-AND-ASK reserved for IMPL-tier IF ambiguity surfaces.

---

## N. Phase F-prime sequencing — F.4 + F.5 next after F.3 ships

Per master plan-033 § E recommended sequencing + § N.1 critical-path analysis:

**F.3 BLOCKS F.4 + F.5** — both depend on F.3 N-persona generalization shipping before they can build on it (F.4 expansion to V0=9 needs use case generalization; F.5 CLI dogfood needs use case to dogfood-against)

**Post-F.3 ship**:
- **F.4 (sub-plan 037)** = V0=6 default OR V0=9 ratified per master plan DD-2 NON-BLOCKING design; sub-plan 037 STEP 0 checks Q-INT-2026-05-F-prime-1 user-pick OR uses architect-recommended V0=6 NO-OP default
- **F.5 (sub-plan 038)** = CLI dogfood thesis on VHM (or alternate per DD-11 user override); architect-recommended VHM dogfood ticker
- **PARALLEL ELIGIBLE** — sub-plans 037 + 038 declared parallel_with at master plan § E.5 + § E.4 (coordination_paths_exclusive disjoint per master plan lint contract DD-4); main session orchestrates parallel dispatch via plan-025 DD-5 3-parallel ceiling

**Architect recommendation for main session at S383+ dispatch decision**:
- IF user opts in to V0=9 via Q-INT response → dispatch sub-plan 037 PLAN (S383) sequentially (37→38 not parallel since V0=9 personas add more PerspectiveRole entries that 038 dogfood consumes)
- IF V0=6 default holds → dispatch sub-plan 037 + 038 PARALLEL at S383 (037 NO-OP per master plan AQ-8; 038 dogfood proceeds with V0=6 immediately)

**Phase F-prime DONE attestation**: per master plan § N.1 row F-prime "Budget envelope ~940-1510K Opus across 15-19 sessions"; cumulative tracking through sub-plans 034/035/036/037/038 = full Phase F-prime completion → Wave 1 Theme H DONE → unlocks Phase G-prime (Theme J PDF + table extraction BC-2) per master plan § N.1 + § 6.4.4

**Next architectural milestone after F-prime DONE**: dispatch G-prime PHASE-MASTER-PLAN authoring session (separate sandwich-architect dispatch; cold-start declared for task_class="pdf-extraction-plan" OR similar)

---

## O. Compliance attestation

This plan complies with:

- [x] **CLAUDE.md hard rules**: 0 charter / 0 constitution / 0 production code in PLAN session; D-060 architect-no-Bash; VBW protocol satisfied via ≥20 source files read; ai-hedge-fund pattern-port not code-port discipline preserved
- [x] **Master plan-033 § E.3 sub-plan 036 stub**: parallel_with [] / blocks_on [034, 035] / coordination_paths_exclusive matches § J above / estimated_wall_min PLAN 10-15 / IMPL 40-60 / VERIFY 15-20 / DoD floor ≥15 NEW unit tests / ADR D-076 PROPOSED at IMPL tier / Charter-tier touch NONE expected (FLAG candidate via STOP-AND-ASK)
- [x] **Master plan-033 binding decisions**: ISOLATED-THEN-AGGREGATE V0 per DD-3 / HYBRID RolePromptPack per DD-4 / BC-8 transport-flip mirror D-072 (F.1 already shipped) / I-S1-1 BY-CONSTRUCTION posture / DD-10 F.3 EXTENSION-NOT-PARALLEL-CLASS / DD-12 per-persona model routing preserved
- [x] **Karpathy P3 surgical-changes**: ≤30 LOC delta validate_thesis_phase1.py + ≤80 LOC delta phase1_synthesizer.py + ≤50 LOC delta use_case_builder.py; extension NOT replacement
- [x] **I-S1 / I-S1-1 / I-S10 / I-S12 / I-S35 / AC-5 invariants**: all preserved by-construction per DD-3/DD-4/DD-5; binding_decisions in frontmatter
- [x] **Phase 1b CONSUMED variant**: n=2 multi-perspective-impl precedent declared (S375 + S378) per § L
- [x] **AP-7 anti-vacuous-defer**: 11 deferred items in § A.3 with named revisit triggers (F.5 dogfood evidence + Q-INT user-pick + calibration-n≥50 + post-MVP + F.3-V2 named-trigger + harness-sweep)
- [x] **DD-10 from F.2 carry-forward**: pattern-port NOT code-port + 50+ char substring grep gate against ai-hedge-fund portfolio_manager.py + risk_manager.py + warren_buffett.py preserved
- [x] **architect template L207-210 observation mandate**: § A.4 lists observation file path
