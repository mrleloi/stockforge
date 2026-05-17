---
observation_id: sandwich-architect-S373-phase-fprime-master-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md
target_session: S373 (THIS plan IS the master plan; sub-plan 034 dispatched at S374)
verifier_session: N/A this master plan (sub-plans verified individually post-IMPL)
phase_milestone: F-prime Theme H ENTRY (Phase E Theme I FULLY DONE at S372 commit 8f68947; Phase F-prime unlocks 5-sub-track BC-8 multi-perspective extension)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START EXPLICIT (task_class="multi-perspective-plan" n=0 sample; nearest analogs vietnamese-nlp-plan n=1 + crawler-adapter-impl n=3 cited)
plan_type: PHASE-MASTER-PLAN (NOT single multi-sub-track FOCUSED_IMPL — DD-1 + § L explicit)
sub_plan_count: 5 (034/035/036/037/038 = F.1/F.2/F.3/F.4/F.5)
---

# S373 sandwich-architect — Phase F-prime Theme H BC-8 multi-perspective entry master plan-033 authoring observation

## What was authored

`agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` — comprehensive PHASE-MASTER-PLAN for Phase F-prime Theme H BC-8 multi-perspective EXTENSION (not new build — BC-8 substrate ~80% existing per § C.0.1 audit), decomposing into 5 follow-on per-sub-track PLAN+IMPL+VERIFY chains (sub-plans 034/035/036/037/038).

**Plan stats** (architect-internal):
- Total LOC: ~1080 (within 150-230K Opus PLAN budget envelope per dispatch brief recalibrated CLAUDE.md PLAN-Opus; CONSCIOUSLY larger than Phase E master plan-028 ~880 LOC because (a) BC-8 substrate audit required substantial existing-code reading [perspective_analysis.py / thesis.py / synthesis.py / validate_thesis_phase1.py / claude_llm_perspective_adapter.py / bear_agent.py + 3 perspectives package] vs Phase E which built fresh, (b) H.3 verdict-INVERSION rationale required adversarial 3-strong-reason argument, (c) DD-2 V0 persona count Vietnam-relevance evidence chain across 6 personas, (d) Rule 16 D-065 surface audit across 6 candidate fields)
- 12 DD architecture decisions (DD-1..DD-12) all pre-answered with rationale + adversarial alternates
- 5 sub-plan decompositions in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 23 DC-MASTER DoD items
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 12 RM entries (RM1..RM12 including RM-AS-1) with mitigation in § J
- 4-subsection Charter-Tier-Surface § K (K.1 master-plan-level 3 NON-BLOCKING flags / K.2 per-sub-plan anticipated FLAGS / K.3 ratification path / K.4 NON-BLOCKING design preference rationale)
- § L Plan-vs-Master-Plan decision rationale (3 subsections)
- § N Phase F-prime → G-prime → H-prime sequencing recommendation (4 subsections including Phase E DONE attestation N.4)
- § P compliance attestation (24 items)

## Key architectural decisions (DD-1..DD-12 summary)

| DD | Decision | Novelty vs Phase E precedent |
|---|---|---|
| **DD-1** | **Phase F-prime = PHASE-MASTER-PLAN (5 sub-plan decomposition)** | Mirrors Phase E plan-028 pattern (4 sub-themes); ADDS 5th sub-track for CLI dogfood per F.5 (Phase E did not have separate dogfood sub-plan — dogfood was per-sub-track DoD floor) |
| **DD-2** | **V0=6 persona count (architect-default) + V0=9 NON-BLOCKING ratification path** | NEW pattern — Phase E did not have charter-tier ratification surface; uses NON-BLOCKING design with architect-recommended default |
| **DD-3** | **V0 ISOLATED-THEN-AGGREGATE (INVERTS H.3 supplement verdict per AP-7 named revisit trigger)** | UNIQUE — INVERTS prior integration-proposal recommendation with 3-strong-reason argument + AP-7 revisit trigger named; sets precedent for "earn the verdict with V0 evidence" pattern |
| **DD-4** | **HYBRID RolePromptPack data + per-persona adapter class** | NEW pattern — combines ai-hedge-fund per-perspective signal contract (A-01 § 3 C1) + plugin registry (A-01 § 3 C2) WITH existing BC-8 file-per-persona-adapter precedent (bear_agent.py/bull_agent.py/quant_agent.py) |
| **DD-5** | **BC-8 transport-flip mirror D-072 strategy** | DIRECT PRECEDENT REUSE — mirrors S368 sub-plan 031 IMPL pattern that SHIPPED + verified at S369; reduces architect+dev cognitive load |
| **DD-6** | **RolePromptPack location = `packages/application/analysis/` package-root** | Application-tier configuration data; NOT ports/use_cases/services subdirectory |
| **DD-7** | **RolePromptPack contract shape = frozen dataclass (NOT Protocol + NOT ABC)** | Per data-vs-behavior distinction; D-066 CrawlerAdapter ABC precedent INFORMATIONAL but rejected (CrawlerAdapter has behavior overrides per source; RolePromptPack has NO behavior overrides per persona — validators live in adapter class) |
| **DD-8** | **PersonaRegistry = stdlib dict + YAML loader (NO new dep)** | Per Karpathy P2; pyyaml availability check at sub-plan 034 STEP 0 |
| **DD-9** | **Per-persona adapter location = mirror existing `packages/infrastructure/analysis/perspectives/`** | Per existing precedent + consistency principle |
| **DD-10** | **F.3 EXTEND existing ValidateThesisPhase1UseCase (NOT new use case)** | Per Karpathy P3 surgical-changes; preserves AC-5 reproducibility + existing test regression floor |
| **DD-11** | **F.5 CLI dogfood ticker = project-owner-pick (architect recommends VHM)** | NEW pattern — architect picks default + NON-BLOCKING override path at sub-plan 038 STEP 0 |
| **DD-12** | **Per-persona LLM model preference = existing _ROLE_TO_MODEL routing** | Cost-control rationale (5 Sonnet + 1 Opus = ~$30/MTok cumulative vs $540 all-Opus) |

**Single most important callout**: **DD-3 V0 ISOLATED-THEN-AGGREGATE INVERSION of H.3 supplement verdict** — this is an adversarial-evidence-driven architecture decision that INVERTS the integration proposal's recommended approach. Rationale uses 3-strong-reason argument (existing-BC-8-shape preservation + 4-of-9 properties win in H.3's own trade-off table + simpler V0 with AP-7 named revisit trigger) AND cites H.3 mitigation #5 which explicitly supports V0 isolated as substrate for DEBATE-V2. This is the "earn the verdict with empirical evidence" pattern, not abandonment of H.3 principle. Verifier (sandwich-verifier dispatched fresh-context) may flag this — RM6 mitigation pre-emptively addresses.

## Phase 1b self-calibration (CONSUMED variant; COLD-START EXPLICIT per L-S354-2 → L-S366-4 → L-S369-1 cascade)

**Source files read (VBW empirical, ALL via Read tool — architect has no Bash)**:
1. `.claude/agents/sandwich-architect.md` (implicit from agent template L42-65 Phase 1b cold-start path + L207-210 observation mandate)
2. `agent-workspace/memory/current-execution.md` (full read 199 LOC; recent session context S365/S368/S371 + Phase E sub-plan dispatches)
3. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 → L-S366-4 → L-S369-1 carry-forward cascade — planner-feedback-loop.sh STILL has not auto-populated after 3 dogfood cycles M-S360/M-S363/M-S366)
4. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read last 10 rows; schema lacks task_class column; cannot key cleanly to multi-perspective-plan task_class)
5. `agent-workspace/memory/dispatch.jsonl` (read 5 rows offset 0; agent_type="unknown-agent" predominantly on older rows)
6. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (offset 1-400 for frontmatter + § 1-2 + § 4.1 ai-hedge-fund + § 4.13 TradingAgents + § 4.14 TradingAgents-CN FIT-HIGH evidence)
7. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme H (offset 148-230; full H.1-H.5 + verdict-and-mitigations) + § Theme I header references
8. `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (full read 104 LOC; § 2-7 architecture + per-perspective Pydantic signal contract + deterministic-then-LLM split + Buffett confidence rubric + license caveat + R1-R10 anti-patterns)
9. `agent-workspace/agent-workspace/CLAUDE.md` (full read inline via system reminder; constitution-immutability + auto-mv rule)
10. `agent-workspace/constitution/architecture.md` (offset 60-180; BC-8 path + cross-BC rules + LLM substrate boundary BP-S43b-1/2/3)
11. `PROJECT_CHARTER.md` (Grep for I-S10/I-S11/I-S12/bear-case/adversarial; spec 004 reference confirmed)
12. `agent-workspace/constitution/invariants-stockforge.md` (Grep for I-S10/I-S11/I-S12; ≥3 distinct points + ≥4 high-conf + Disagreement Surfaced)
13. `agent-workspace/constitution/financial-data-protocol.md` § Rule 16 (offset 358-477; full Rule 16 + 4 satisfaction modes + EchoValidator runtime tier + Rule 16 amended 2026-05-16 via D-065 — EXPLICITLY names Phase F-prime BC-8 schemas in 'Fields explicitly subject' inventory)
14. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (offset 1-700 across 2 reads; PHASE-MASTER-PLAN shape reference; Phase E precedent)
15. `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (full read 100 LOC; master-plan observation file precedent)
16. `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (offset 1-60; D-072 ACCEPTED ADR; precedent for BC-8 transport-flip in F.1)
17. `agent-workspace/memory/sessions/2026-05-17-session-371.md` (offset 1-70; S371 Phase E.4 ticker resolver IMPL session log; Phase E DONE attestation surface; commit 8f68947 reference)
18. `packages/domain/analysis/models/perspective_analysis.py` (full read 62 LOC; existing PerspectiveAnalysis dataclass + PerspectiveRole 6-value StrEnum)
19. `packages/domain/analysis/models/thesis.py` (full read 147 LOC; Thesis aggregate root + I-S10 _enforce_bear_case invariant)
20. `packages/domain/analysis/models/synthesis.py` (full read 101 LOC; Synthesis aggregate + I-S12 invariant)
21. `packages/domain/analysis/value_objects/grounded_point.py` (full read 72 LOC; GroundedPoint invariants)
22. `packages/application/analysis/use_cases/validate_thesis_phase1.py` (full read 290 LOC; existing 7-step pipeline use case + SharedContext + LLMPerspectivePort + Phase1Synthesizer Protocol + CostTrackerPort)
23. `packages/application/analysis/ports/llm_perspective_port.py` (full read 53 LOC; existing LLMPerspectivePort Protocol)
24. `packages/application/analysis/services/recommendation_heuristic.py` (read first 80 LOC; existing pure-deterministic Synthesis→Recommendation+ConfidenceLevel mapping)
25. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (read first 90 LOC + offset 170-290 for ClaudeLLMPerspectiveAdapter dataclass; **existing direct `import anthropic` at line 80** = anthropic_api_to_subagent surface)
26. `packages/infrastructure/analysis/perspectives/bear_agent.py` (read first 300 LOC; existing BEAR persona implementation with retry-validator + SYSTEM_PROMPT + Jaccard distinctness + I-S10 strict gate)
27. `packages/infrastructure/news/claude_cli_news_transport.py` (read offset 90-170; existing transport precedent for F.1 transport-flip mirror)
28. `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` (read first 80 LOC; SPEC-2026-04-23-004 v1.0 approved; A.2 six perspectives + BR-1..BR-9)

**Calibration parameters extracted**:
- task_class = `multi-perspective-plan` (NEW class — no precedent)
- sample_size = **0** (cold-start declared)
- avg_wall_min = N/A cold-start; budget envelope estimated per recalibrated CLAUDE.md PLAN-Opus + dispatch brief target 150-230K
- avg tokens_real = N/A cold-start; per-sub-track PLAN sessions inherit precedent from THIS plan after first sub-plan ships
- parallel_hit_rate empirical = 0% (no .planner-stats population; L-S354-2 → L-S366-4 → L-S369-1 cascade gap)
- parallel_hit_rate declared at master-plan-level = sub-plans 037+038 declared parallel_with (architect-tier orchestration eligible per plan-025 DD-5)
- failure_mode frequency = N/A cold-start; nearest analog vietnamese-nlp-plan n=1 shows 0 IMPORTANT defects per cycle; Theme H expected MORE per cycle because (a) persona prompt template design has more decision points, (b) AC-5 reproducibility regression risk per persona-pack rotation, (c) BC-8 transport-flip touches existing test_adapter.py/test_bear_agent.py/test_quant_agent.py = regression-floor broader than D-072
- Adjusted budget for THIS master plan = 150-230K Opus PLAN (per dispatch brief target ceiling)
- Cold-start? **YES EXPLICIT** (per agent-template L65 + plan-025 DD-11 mandate + L-S354-2/L-S366-4/L-S369-1 cascade carry-forward)

**Calibration verdict**: Phase 1b COLD-START EXPLICIT at task_class=multi-perspective-plan with PARTIAL infrastructure observation (.planner-stats.tsv still header-only after 3 dogfood cycles; planner-feedback-loop bug now 3rd-instance per AP-23 — promotion-or-retire calculus applies). Architect honors Karpathy P1 "calibration over confidence" by NOT making up precedent + explicitly declaring cold-start in plan output + naming the L-S354-2/L-S366-4/L-S369-1 cascade as the cause. Final budget recommendation **150-230K Opus PLAN this master plan** (per dispatch brief target ceiling) + cumulative Phase F-prime envelope ~940-1510K across 15-19 sessions (calibrated per sub-plan rhythm precedent from Phase E plan-028 sub-themes 029/030/031/032).

## Why a PHASE-MASTER-PLAN (not single multi-sub-track FOCUSED_IMPL)

Per § L of the plan output, summarised:

1. **CLAUDE.md hard rule violation**: single-session PLAN+IMPL of 5 sub-tracks = mix PLAN+IMPL = explicit anti-pattern
2. **Budget arithmetic**: 5 × 100-150K IMPL = 500-750K cumulative IMPL exceeds MULTI-TASK ceiling (150-250K)
3. **Phase 1b cold-start**: bundling cold-start work loses incremental calibration; per-sub-track PLAN sessions calibrate n=0 → n=1 → n=2 → n=3 → n=4
4. **Phase E plan-028 precedent**: 4 sub-themes per-PLAN+IMPL+VERIFY all SHIPPED + verified (S366/S369/S372) = strong precedent for per-sub-track rhythm
5. **Existing BC-8 backward-compat preservation**: 5 sub-tracks with INDIVIDUAL verifier sessions = better defect-catch per session vs bundled regression flood (especially critical given BC-8 has existing test suite for 3-persona path + AC-5 reproducibility AC)

## Key DD decisions (esp. persona count V0, rubric I-S1 compliance, aggregation strategy)

| Architect question | Decision | Rationale | Charter-tier-touch |
|---|---|---|---|
| V0 persona count | V0=6 default (existing 3 + Buffett/Graham/Taleb in F.2); V0=9 NON-BLOCKING ratification (Munger/Lynch/VN_DOMAIN_SPECIALIST in F.4) | Spec 004 A.2 6 archetypes + Charter Principle 4 moat + Karpathy P2 simplicity; Vietnam-relevance evidence chain per persona | NON-BLOCKING — proceeds with default unless user opts in |
| Rubric I-S1 compliance | Categorical surrogate via Conviction StrEnum STRONG/MODERATE/WEAK per Rule 16 mode 1 | Buffett 90-100 numeric rubric REJECTED per A-01 § 5 caveat + Rule 16 explicit | NONE — Rule 16 ratified D-065 already operationalizes |
| Aggregation strategy | V0 ISOLATED-THEN-AGGREGATE (INVERTS H.3 supplement verdict) | 3 strong reasons (existing-BC-8-shape + cost/determinism/AP-1-risk per H.3 trade-off 4-of-9 + AP-7 named revisit trigger for DEBATE-V2) + H.3 mitigation #5 explicitly supports V0 isolated as substrate | NONE — I-S12 satisfied by-construction either way |
| RolePromptPack pattern | HYBRID frozen dataclass + per-persona adapter class | Per-persona validator semantics DIFFER (BEAR ≥3 categories; QUANT numeric-tool-grounding; BUFFETT moat-grounding); pure-data-driven = over-abstraction | NONE — application-tier configuration |
| BC-8 transport flip | Mirror D-072 strategy (claude_cli_perspective_transport factory + default-flip + remove import anthropic) | Direct precedent reuse from S368 sub-plan 031 IMPL + S369 verifier PASS | NONE — anthropic_api_to_subagent memory rule operationalized |

## Charter-tier flags + NON-BLOCKING design vs BLOCKING

**3 NON-BLOCKING flags at master-plan level**:
- K.1.a — V0 persona count V0=6 vs V0=9 (architect-default V0=6; Q-INT-2026-05-F-prime-1 ratification path optional)
- K.1.b — V0 aggregation ISOLATED vs DEBATE (architect-default isolated INVERTS H.3; Q-INT-2026-05-F-prime-2 ratification path optional)
- K.1.c — Per-persona confidence categorical vs numeric (architect-default categorical; NO ratification needed per Rule 16 ratified D-065)

**5 anticipated sub-plan-level FLAGS** (per § K.2): pyyaml dep (F.1) / interpretation creep BUY-SELL (F.2 + F.5) / TALEB tail-risk VaR-numeric (F.2) / N-perspective tie-breaker rule (F.3) / VN_DOMAIN_SPECIALIST microstructure encoding (F.4)

**NO BLOCKING flags at master-plan level** — architect-recommended defaults are empirically defensible; sub-plan STEP 0s STOP-AND-ASK if defaults prove wrong; main session MAY fire Q-INT bundle at any time but Phase F-prime does NOT require ratification gate to proceed.

## S374 dev budget recommendation (for sub-plan F.1 entry IMPL)

Sub-plan 034 (F.1 RolePromptPack + transport-flip) IMPL S375 budget recommendation:

- **Type**: FOCUSED_IMPL (single-sub-track scope: RolePromptPack + PersonaRegistry + BC-8 transport-flip)
- **Budget**: 100-150K Opus FOCUSED_IMPL per CLAUDE.md § Session Types (cold-start default; sub-plan 034 PLAN re-runs Phase 1b at S374 to refine)
- **Model**: Opus 4.7 (default per CLAUDE.md; if cost-sensitive, F.1 can downgrade to Sonnet 4.6 for ~50% cost saving without quality risk — F.1 IMPL is mostly transport-migration + new contract authoring, not deep reasoning)
- **Sub-tracks per sub-plan 034**: D1 RolePromptPack dataclass + invariants tests; D2 PersonaRegistry lookup + YAML loader; D3 claude_cli_perspective_transport new factory; D4 ClaudeLLMPerspectiveAdapter default-flip + remove import anthropic; D5 regression test coverage across 3 existing perspective adapters
- **Wall-clock estimate**: PLAN 8-12 min / IMPL 30-45 min / VERIFY 10-15 min = ~50-70 min total for sub-plan 034 + S376 verifier

## Phase F-prime → G-prime/H-prime sequencing recommendation

**Sequential Phase F-prime** (S373 master plan → S374-S386 sub-plans):
- S373: this master plan
- S374/S375/S376: F.1 (sub-plan 034)
- S376/S377/S378: F.2 (sub-plan 035)
- S378/S379-S380/S381: F.3 (sub-plan 036; IMPL may span 2 sessions)
- S381/S382-S383/S384: F.4 (sub-plan 037; PARALLEL with F.5; NO-OP if V0=6 confirmed)
- S384/S385/S386: F.5 (sub-plan 038; PARALLEL with F.4)

**Parallel Phase G-prime** (architect-tier parallel-dispatch per S345 4-parallel precedent):
- After F.1 ships at S376: main session MAY dispatch Phase G-prime master-plan author parallel with F.2 PLAN authoring
- G-prime authoring = independent file scope; no contention with Phase F-prime

**Deferred Phase H-prime** — triggers at Phase 2 dashboard work entry per master plan § 6.4.5

**Wall-clock projection**:
- Phase F-prime sequential: ~15-19 turns
- With F.4+F.5 parallel + G-prime parallel from S376 + V0=6 NO-OP: ~12-15 turns total to Phase F-prime+G-prime close

## Commits

This plan-session produces 0 commits by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash). Main session commits plan file + observation per D-060 + pre-dispatch-architect-commit-guard.sh.

**Expected commit boundaries** (main session decides):
- 1 commit: plan-033 + this observation file (~1080 + ~250 LOC = ~1330 LOC delta)
- D-060 attestation: agent-tier authored; user-tier pushes per AGENT_OPERATING_MANUAL

## Compliance attestation (replicates § P of plan)

- harness_priority_one ✓ (L-S354-2/L-S366-4/L-S369-1 cascade carry-forward NOTED in § A.4 + plan; explicitly NOT fixed here per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 28 source files read inline)
- AP-7 ✓ (every DEFER in § A.3 + § J names prerequisites + revisit triggers; AP-7 named revisit trigger explicitly cited in DD-3 for DEBATE-V2)
- AP-23 ✓ (no refinement-of-rule iterations; H.3 verdict-INVERSION is empirical-evidence-driven NOT refinement-of-rule)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = master plan + observation; main session dispatches sub-plan 034)
- stop_offering_routing_branches ✓ (sequencing recommendation in § N structural advice not menu)
- D-060 ✓ (architect has no Bash; main commits)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (constitution/** untouched)
- 0 human-workspace writes ✓
- 0 production code ✓ (architect PLAN-only)
- I-S1 ✓ + I-S1-1 ✓ (Rule 16 mode 1+2 satisfaction by-construction per § C.0.4)
- I-S2 ✓ (28 source files cited file:line)
- I-S10 ✓ + I-S11 ✓ + I-S12 ✓ (existing aggregate invariants preserved; F.3 generalization preserves all 3)
- I-S35 ✓ (output = Recommendation enum, no buy/sell surface)
- Phase 1b COLD-START explicit per § A.4
- 5-source-evidence chain populated per § H
- ai-hedge-fund LICENSE-file caveat A-01 § 6 ACKNOWLEDGED; pattern-port not code-port mandate
- anthropic_api_to_subagent BC-8 surface flagged in § C.0.5 + DD-5 + RM-AS-1
- Phase E DONE attestation S372 8f68947 acknowledged in § N.1 + § N.4
