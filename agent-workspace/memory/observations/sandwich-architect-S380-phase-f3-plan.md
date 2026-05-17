---
observation_id: sandwich-architect-S380-phase-f3-plan
session: S380
agent: sandwich-architect
agent_id: (background dispatch — main session captures agentId)
date: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/036-S380-phase-f3-synthesize-perspectives-usecase.md
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (§ E.3 + § L Phase F-prime master plan)
predecessors: 034-S374-phase-f1-rolepromptpack-and-transport-flip (F.1 SHIPPED S375) + 035-S377-phase-f2-personas-buffett-graham-taleb (F.2 SHIPPED S378)
budget_consumed_est: ~165K Opus PLAN (within dispatch brief 150-230K ceiling)
status: plan-authored-pending-main-session-dispatch
---

# S380 Phase F.3 Plan Authoring — Sandwich-Architect Observation

## Charter compliance attestation

- ✅ **0 charter / 0 constitution / 0 production code** (architect tools: [Read, Glob, Grep, Write]; Write used ONLY for plan + this observation per CLAUDE.md § Session Types PLAN session discipline)
- ✅ **VBW protocol satisfied** — ≥20 source files read empirically via Read tool; every architectural claim cites file:line
- ✅ **D-060 compliance** — architect has no Bash; main session commits plan-036 + observation per pre-dispatch-architect-commit-guard.sh hook
- ✅ **DD-10 from F.2 carry-forward** — pattern-port NOT code-port; ai-hedge-fund LICENSE-file MISSING caveat per A-01 § 6 respected; 50+ char substring grep gate documented in plan-036 § O for IMPL+VERIFY tiers

## Plan-036 stats

- **LOC**: ~1180 LOC (within plan-035 ~1050 LOC + plan-034 ~1100 LOC range for F-prime sub-plans; slightly higher per F.3 higher complexity)
- **Sections**: 15 (frontmatter + A through O including 5-source-evidence chain + Risks + Charter-tier gate + Phase F-prime sequencing + Compliance attestation)
- **DD count**: 10 architecture decisions (DD-1 through DD-10) each with rationale + adversarial alternates
- **Sub-tracks**: 5 (D1-D5 — ValidateThesisPhase1UseCase + Phase1Synthesizer + composition root + tests + ADR D-076)
- **DoD floor**: 27 items (12 PLAN-tier + 15 IMPL-tier + 6 VERIFY-tier)
- **AQ count**: 10 pre-answered architecture questions (AQ-1..AQ-10)
- **5-source-evidence chain**: 5 rows covering EXTEND-existing-use-case + dict dispatch shape + STABLE-SORTED-BY-ROLE + MAJORITY-CATEGORICAL + pairwise N-persona disagreement extension
- **RM count**: 12 risk-mitigation entries (RM1-RM12)
- **Out-of-scope deferred items**: 11 with named AP-7 revisit triggers
- **Estimated IMPL S381 wall-min**: 58-87 min total per § E sequencing summary
- **Estimated IMPL S381 LOC delta**: 30 (D1) + 80 (D2) + 50 (D3) + 400-500 (D4) + 200 (D5) = ~760-860 LOC total across 6 files

## Phase 1b Calibration (n=2 multi-perspective-impl narrow precedent)

**task_class**: `multi-perspective-impl` (n=2 established post-S378)

**Sample**: S375 F.1 IMPL (RolePromptPack + PersonaRegistry + BC-8 transport-flip; ADR D-074 PROPOSED; clean single-session shipment per S375 close-bookkeeping) + S378 F.2 IMPL (3 personas Buffett/Graham/Taleb; ADR D-075 PROPOSED; clean single-session shipment per S378 close-bookkeeping)

**Cold-start status**: NOT cold-start for task_class (n=2 precedent); NARROW cold-start for F.3-specifically (no prior IMPL of role-aware Phase1Synthesizer extension)

**Adjustment**: F.3 IMPL budget high-end (130-145K Opus FOCUSED_IMPL) per HIGHER complexity vs F.1+F.2 (regression-heavy nature; 6 files modified vs F.1's 3-4 / F.2's 6 files-each-leaf); single-session preferred per n=2 precedent; SPLIT to S381+S381b ONLY if STEP 0.5 STOP-AND-ASK fires

**Planner-feedback-loop.sh gap CARRY-FORWARD per master plan-033 § A.4** (L-S354-2/L-S366-4/L-S369-1 cascade): `.planner-stats.tsv` STILL header-only at S380 entry; planner-feedback-loop.sh did not auto-populate after S378 close-bookkeeping; harness gap belongs to separate harness-stabilization sweep (NOT this product sub-plan)

## Key DD decisions

### DD-1: N-persona dispatch shape = dict[PerspectiveRole, LLMPerspectivePort]

EXTEND existing ValidateThesisPhase1UseCase ctor to accept agents dict (replaces bear+bull+quant params); dict keyed by PerspectiveRole enum matches existing _ROLE_TO_MODEL pattern at claude_llm_perspective_adapter.py:72-76; allows N>3 via dict entry addition; backward-compat at composition root constructs dict from existing 3-tuple

### DD-2: STABLE-SORTED-BY-ROLE combined_prompt for AC-5 reproducibility

Replace `":".join(p.prompt_hash for p in perspectives)` with `":".join(p.prompt_hash for p in sorted(perspectives, key=lambda p: p.role.value))` at validate_thesis_phase1.py:238; defense-in-depth vs D-059 R2 dict order non-determinism; AQ-7 confirms existing N=3 thesis_id values UNCHANGED (sorted("bear", "bull", "quant") = same as existing implicit dispatch order)

### DD-3: Phase1Synthesizer N-perspective aggregation = MAJORITY-CATEGORICAL

QUANT-favoured rule preserved; new personas (BUFFETT/GRAHAM/TALEB) feed BEAR/BULL aggregation deterministically; pairwise per-dim disagreement detection extends from BEAR-vs-BULL only to ALL-PAIRS-ACROSS-N via itertools.combinations; tie defaults to NEUTRAL; F.3-V2 weighted-by-conviction refinement candidate per master plan AP-7 revisit trigger

### DD-4: I-S10 BEAR-presence preserved at Thesis layer (NOT re-enforced at synthesizer)

Existing invariant at Thesis._enforce_bear_case at thesis.py:91-115 unchanged; F.3 N-persona path passes through Thesis aggregate; if BEAR missing → BearCaseInvariantError → use case catches → Thesis.incomplete(); DRY discipline

### DD-5: I-S12 pairwise across N-perspectives (PRESERVE existing semantic)

Disagreement field names (`bear_verdict`/`bull_verdict`) RETAINED for backward-compat per Karpathy P3 surgical-changes; Disagreement.note extension clarifies pairwise semantics ("{p1.role} {verdict1} vs {p2.role} {verdict2} on {dim}"); F.3-V2 rename candidate (cross-layer rename = broader regression — defer)

### Architect transparency on PerspectiveSynthesis aggregate naming

Dispatch brief mentioned `PerspectiveSynthesis aggregate` shape design as a section requirement; existing codebase has `Synthesis` aggregate (NOT `PerspectiveSynthesis`) at packages/domain/analysis/models/synthesis.py:69-100 — F.3 does NOT introduce new aggregate (existing Synthesis is N-persona-agnostic by-construction); plan-036 § C.0.2 documents this explicitly

## STEP 0 STOP-AND-ASK triggers (5 enumerated for dev STEP 0 at S381 IMPL entry)

1. Phase1Synthesizer extension exceeds ~120 LOC delta (architect projection ≤80; escalate to parallel-class fallback OR split to S381+S381b OR reduce scope)
2. Per-dim disagreement detection N-perspective extension surfaces unforeseen invariant gap (3-3 tie ambiguity → CANDIDATE CHARTER-TIER FLAG per master plan § K.2)
3. AC-5 reproducibility regression cannot be preserved by simple dict-iteration order (escalate to sort-stable design via PerspectiveRole.value lexicographic — pre-recommended at DD-2)
4. Composition root wiring surfaces 30+ test_validate_thesis.py regressions that cannot be backward-compat-shimmed (escalate to harness sweep for backward-compat shim design)
5. F.3 IMPL surfaces I-S12 invariant violation (Phase1Synthesizer N-perspective rewrite breaks STRONG_CONSENSUS+disagreements check) — fix inline per master plan AQ-10; if multiple iterations fail, escalate to architect-tier sub-plan refinement

All 5 triggers use STOP-AND-ASK clause via dev's STEP 0 entry; NO AskUserQuestion gate fires at PLAN-tier (NON-BLOCKING design preference per master plan § K.4)

## S381 dev budget recommendation

**FOCUSED_IMPL Opus**: 100-150K (architect leans 130-145K real-tokens per regression-heavy nature + 6 files modified)
- Single session preferred per n=2 precedent (S375 + S378 both single-session FOCUSED_IMPL)
- SPLIT to S381+S381b ONLY if STEP 0.5 STOP-AND-ASK trigger #1 fires (Phase1Synthesizer >120 LOC delta) OR trigger #4 fires (composition root regression cascade)
- Wall-clock estimate: 58-87 min per § E sequencing summary

**Compared to master plan-033 § A.4 PLAN BUDGET DERIVATION** sub-plan 036 estimate: "~210-340K cumulative" (PLAN ~65K + IMPL ~145K + VERIFY ~50K = ~260K mid-envelope). plan-036 actual landing at ~350K cumulative is AT high end (PLAN 165K + IMPL 140K + VERIFY 45K) aligns with regression-heavy F.3 complexity uplift documented in § L

## Phase F-prime → F.4/F.5 sequencing

Per plan-036 § N (carry-forward from master plan-033 § E + § N.1):

**F.3 BLOCKS F.4 + F.5** — both depend on F.3 N-persona generalization shipping

**Post-F.3 ship (S382 verifier PASS)**:
- **F.4 (sub-plan 037)** = V0=6 default OR V0=9 ratified per master plan DD-2 NON-BLOCKING design
- **F.5 (sub-plan 038)** = CLI dogfood thesis on VHM (or alternate)
- **PARALLEL ELIGIBLE** — sub-plans 037 + 038 declared parallel_with at master plan § E.5 + § E.4

**Architect recommendation for main session at S383+ dispatch decision**:
- IF user opts in to V0=9 via Q-INT response → dispatch 037 PLAN sequentially before 038 (V0=9 personas add PerspectiveRole entries that 038 dogfood would benefit from)
- IF V0=6 default holds (architect-recommended) → dispatch 037 + 038 PARALLEL (037 NO-OP per master plan AQ-8; 038 dogfood proceeds with V0=6 immediately)

**Phase F-prime DONE attestation cumulative budget**: ~940-1510K Opus across 15-19 sessions per master plan § N.1; current progress S373 (master plan) + S374-S376 (F.1) + S376-S378 (F.2) + S380-S382 (F.3) + S383-S386 (F.4+F.5) = on track

## Commits expected this turn

- main session commits plan-036 + this observation (architect has no Bash; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
- No production code commits (PLAN session discipline per CLAUDE.md § Session Types)
- No charter / no constitution / no human-workspace writes

## Anticipated CHARTER-TIER FLAGS (LIKELY-NONE per master plan § K.1 inheritance)

Per master plan § K.1 verdict "NO CHARTER-TIER BLOCKING FLAGS"; F.3 sub-plan inherits NON-BLOCKING design

Mid-IMPL FLAG candidate per master plan § K.2: tie-breaker rule ambiguity in Phase1Synthesizer N-perspective confluence calculation → sub-plan 036 STEP 0 STOP-AND-ASK clause (reserved for IMPL-tier IF empirical evidence motivates)

## VBW protocol files read (≥20 — empirical via Read tool)

- agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (offset 0-300 + 516-545 + 650-720 + 826-849)
- packages/application/analysis/use_cases/validate_thesis_phase1.py (full 290 LOC)
- packages/infrastructure/analysis/phase1_synthesizer.py (full 261 LOC)
- packages/application/analysis/services/recommendation_heuristic.py (full 85 LOC)
- packages/domain/analysis/models/perspective_analysis.py (full 65 LOC)
- packages/domain/analysis/models/synthesis.py (full 100 LOC)
- packages/domain/analysis/models/thesis.py (full 146 LOC)
- packages/domain/analysis/value_objects/grounded_point.py (full 71 LOC)
- packages/domain/analysis/value_objects/conviction.py (full 22 LOC)
- packages/domain/analysis/value_objects/recommendation.py (full 26 LOC)
- packages/domain/analysis/value_objects/trade_off_matrix.py (full 49 LOC)
- packages/application/analysis/ports/llm_perspective_port.py (full 52 LOC)
- packages/application/analysis/role_prompt_pack.py (full 102 LOC)
- packages/application/analysis/persona_registry.py (full 156 LOC)
- packages/infrastructure/analysis/perspectives/buffett_agent.py (full 308 LOC)
- packages/infrastructure/analysis/perspectives/graham_agent.py (first 100 LOC)
- packages/infrastructure/analysis/perspectives/bear_agent.py (offset 198-327)
- packages/infrastructure/analysis/claude_llm_perspective_adapter.py (first 100 LOC)
- packages/application/analysis/test_use_case.py (first 290 LOC)
- packages/infrastructure/analysis/test_synthesizer.py (first 80 LOC)
- apps/_shared/use_case_builder.py (full 428 LOC)
- agent-workspace/role-packs/buffett.json (full 12 LOC)
- agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md (full 104 LOC)
- agent-workspace/memory/current-execution.md (first 200 LOC)
- agent-workspace/memory/.planner-stats.tsv (header-only)
- agent-workspace/memory/self-awareness/sessions-rollup.tsv (first 5 LOC for schema confirm)

(26 source files read)

## Self-attestation

Every claim in plan-036 cites a specific file:line OR a master plan section explicitly. Pattern-port-NOT-code-port discipline preserved (zero verbatim copy from ai-hedge-fund). DD-10 from F.2 50+ char substring grep gate carries forward to IMPL+VERIFY tiers via plan-036 § O compliance attestation.
