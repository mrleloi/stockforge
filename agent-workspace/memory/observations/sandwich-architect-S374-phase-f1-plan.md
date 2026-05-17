---
observation_id: sandwich-architect-S374-phase-f1-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/034-S374-phase-f1-roleprompt-persona-transport.md (+ -part2.md + -part3.md + -part4.md split across 4 physical files per output-token-limit pragmatism; logical one plan)
target_session: S375 (dev FOCUSED_IMPL) + S376 (verifier AP-1)
verifier_session: S376 sandwich-verifier AP-1 (fresh-context post-S375 dev close)
phase_milestone: F.1 BC-8 RolePromptPack + PersonaRegistry + Transport-Flip — FIRST sub-plan of Phase F-prime master plan-033 (per § E.1 sequencing)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START DECLARED for task_class="multi-perspective-impl"; nearest analog vietnamese-nlp-impl n=3 (S362+S365+S368 ALL clean Sonnet cycles ~155K / ~39min / 0 mistakes); cold-start window NARROW on adapter+tests portion; PARTIAL-COLD-START for RolePromptPack+PersonaRegistry novel portion
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; first of 5 sub-themes per parent master plan-033 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (PHASE-MASTER-PLAN; sub-plan 034 satisfies its § E.1 contract per DD-4 HYBRID + DD-5 transport-flip MIRROR D-072 + DD-6 location + DD-7 frozen dataclass shape + DD-8 PersonaRegistry stdlib dict)
predecessor_sub_plans: [] (FIRST sub-plan of Phase F-prime; master plan-033 is the predecessor)
related_adrs: [D-050-S227-anthropic-to-subagent-systemic ACCEPTED CHARTER 2026-05-09 (this plan ADVANCES D-052 § Implementation step 1 closure for BC-8 surface), D-051-S228 news-extractor refactor (BC-5 transport precedent; SHIPPED S228), D-052-S229 anthropic SDK code-path removal (ACCEPTED 2026-05-09 with 4-step implementation plan; step 1 NOT APPLIED per S369 verifier F3 finding; THIS sub-plan closes step 1 for BC-8 surface), D-072 BC-5 VN claim extraction wrapper transport-flip (ACCEPTED S368; DIRECT MIRROR for BC-8), D-074 PROPOSED-AT-IMPL via this plan D5]
---

# S374 sandwich-architect — Phase F.1 BC-8 RolePromptPack + PersonaRegistry + Transport-Flip sub-plan-034 authoring observation

## What was authored

Sub-plan 034 at `agent-workspace/session-plans/pending/034-S374-phase-f1-roleprompt-persona-transport.md` (+ `-part2.md`, `-part3.md`, `-part4.md` split across 4 physical files for output-token-limit pragmatism; one logical plan). FOCUSED_IMPL sub-plan for Phase F-prime sub-theme F.1, decomposing into 5 sub-tracks:
- D1 RolePromptPack frozen dataclass (NEW packages/application/analysis/role_prompt_pack.py ~100 LOC)
- D2 PersonaRegistry stdlib dict + JSON loader + D-064 path-safety (NEW packages/application/analysis/persona_registry.py ~120 LOC)
- D3 ClaudeLLMPerspectiveAdapter transport-flip (MODIFIED packages/infrastructure/analysis/claude_llm_perspective_adapter.py +10/-30 LOC: _default_transport removal + import anthropic removal + transport field default flip to claude_cli_transport)
- D4 unit tests + regression additions (NEW test_role_prompt_pack.py ~70 LOC + NEW test_persona_registry.py ~80 LOC + MODIFIED test_adapter.py ~+50 LOC regression for transport-flip)
- D5 ADR D-074 PROPOSED + role-packs/README.md placeholder

EXISTING-EXTRACTOR-AUGMENT STEP 0 pattern (per parent plan-031 STEP 0 template) bundled with D-052 § Implementation step 1 final closure (per S369 verifier F3 finding that exposed analysis adapter STILL has `import anthropic` at L80 despite D-052 ACCEPTED 2026-05-09) gated by CHARTER-TIER GATE STOP-AND-ASK for claude CLI substrate availability.

**Plan stats** (architect-internal):
- Total LOC across 4 files: ~1100 (within 150-230K Opus PLAN budget; well-grounded in 35 VBW-read source files)
- 9 DD architecture decisions (DD-1..DD-9) all pre-answered with rationale + adversarial alternates
- 5 sub-tracks D1-D5 in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 36 DC DoD items (≥25 floor satisfied)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 10 RM entries (RM1..RM10 + RM-AS-2 carry-forward) with mitigation in § J
- **STEP 0 STOP-AND-ASK trigger inventory** with 5 documented triggers (1 CHARTER-TIER + 3 TACTICAL-TIER + 1 BLOCKING) per AP-7 anti-vacuous-defer
- **§ M CHARTER-TIER GATE clause** as canonical reference for S375 dev
- **§ L Conditional next-step** with 5 branches L.1-L.5 covering all post-gate paths
- **§ N D-052 cleanup completion attestation contract** — D-052 spec compliance audit (0% → 100% for BC-8 surface) + sub-plan dispatch sequencing post-S376

## Key architectural decisions (DD-1..DD-9 summary)

| DD | Decision | Pre-decided or CONDITIONAL? |
|---|---|---|
| **DD-1** | **RolePromptPack contract = FROZEN DATACLASS (NOT Protocol, NOT ABC)** | PRE-DECIDED per master plan-033 DD-7 |
| **DD-2** | **PersonaRegistry = STDLIB DICT + JSON LOADER (no new dep; YAML deferred)** | PRE-DECIDED per master plan-033 DD-8 + STEP 0.3 pyproject.toml audit (pyyaml NOT in deps) |
| **DD-3** | **RolePromptPack location = packages/application/analysis/ package-root** | PRE-DECIDED per master plan-033 DD-6 |
| **DD-4** | **BC-8 transport-flip strategy = REUSE existing claude_cli_transport from subagent_transport.py (NOT new claude_cli_perspective_transport.py file)** | ARCHITECT-REFINEMENT of master plan-033 dispatch brief; per D-052 § Implementation step 1 EXPLICIT naming "Set the dataclass `transport` default to `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC import)" + STEP 0.1 VBW confirmation subagent_transport.py:144-222 ships matching signature |
| **DD-5** | **Transport default FLIPPED from _default_transport to claude_cli_transport (D-052 § step 1 FINAL closure)** | PRE-DECIDED per D-052 SYSTEMIC + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09) + S369 verifier F3 finding (step 1 NOT APPLIED); CONDITIONAL only on STEP 0.4 claude CLI substrate availability gate |
| **DD-6** | **Conviction enum preservation (NO numeric per-persona confidence)** | PRE-DECIDED per I-S1 + Rule 16 mode 1 + master plan-033 DD-7 (Buffett 90-100 numeric rubric REJECTED) |
| **DD-7** | **RolePromptPack EXACT 10-field shape** | PRE-DECIDED per master plan-033 DD-7 verbatim lines 378-388 |
| **DD-8** | **ADR D-074 PROPOSED-AT-IMPL records D-052 § step 1 closure + RolePromptPack contract + PersonaRegistry pattern** | PRE-DECIDED per severity-schema IMPL-tier auto-ratification + AP-7 anti-vacuous-defer + D-050 → D-052 → D-072 → D-074 closure traceability |
| **DD-9** | **Existing subagent_transport.py UNCHANGED — consumed verbatim per DD-4** | PRE-DECIDED per Karpathy P3 surgical-changes + already-shipped per D-052 § Implementation step 1 explicit |

**Single most important callout**: **DD-4 + DD-5 + DD-8 are the D-052 § Implementation step 1 closure** — D-052 ACCEPTED CHARTER 2026-05-09 explicitly named `claude_cli_transport` from `subagent_transport.py` (no cross-BC import) as the transport-flip target for BC-8 perspective adapter. S369 verifier F3 finding (per dispatch brief) surfaced that step 1 was NOT APPLIED — analysis adapter STILL has `import anthropic` at L80 + `_default_transport` function present + transport field default still `_default_transport`. THIS sub-plan IS the residual closure. D-052 spec compliance reaches 100% for BC-8 surface upon S375 dev commit.

## Phase 1b self-calibration (CONSUMED variant; COLD-START DECLARED for task_class="multi-perspective-impl"; nearest analog vietnamese-nlp-impl n=3)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 35 files cited in plan § A.4):

Highlights:
1. `agent-workspace/memory/.planner-stats.tsv` (header-only confirmed; L-S354-2 + L-S366-4 + L-S369-1 cascade carry-forward)
2. `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (parent master plan; § E.1 sub-plan-034 contract + DD-4/DD-5/DD-6/DD-7/DD-8 verbatim)
3. `agent-workspace/session-plans/completed/031-S367-phase-e3-claim-extraction-wrapper.md` (DIRECT TEMPLATE for sub-plan structure mirror; BC-5 transport-flip precedent)
4. `agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md` (D-050 CHARTER ACCEPTED 2026-05-09)
5. `agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md` (D-052 ACCEPTED 2026-05-09; § Implementation step 1 EXPLICITLY targets claude_llm_perspective_adapter.py)
6. `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (D-072 ACCEPTED S368; BC-5 mirror)
7. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (full read 264 LOC; _default_transport L73-98 + import anthropic L80 + transport field L197-199; modification target for D3)
8. `packages/infrastructure/analysis/subagent_transport.py` (full read 222 LOC; claude_cli_transport L144-222 ALREADY-SHIPPED drop-in)
9. `packages/infrastructure/analysis/test_adapter.py` (offset 1-100; _make_stub_transport L24-33 — regression-floor surface)
10. `pyproject.toml` (Grep `pyyaml|yaml|anthropic` — anthropic>=0.40.0 STILL at L11; pyyaml NOT in deps)

**Calibration parameters extracted**:
- **task_class**: `multi-perspective-impl` (NEW — no precedent)
- **sample_size**: **0 for multi-perspective-impl** (COLD-START); **3 for nearest-analog vietnamese-nlp-impl** (S362+S365+S368 ALL clean Sonnet ~155K / ~39min / 0 mistakes)
- **Cold-start?**: **YES for multi-perspective-impl task-class**; **NO for adapter-AUGMENT+tests+ADR shape** (transfers cleanly from vietnamese-nlp-impl n=3); **PARTIAL-COLD-START for RolePromptPack+PersonaRegistry shape** (sub-component novel; never previously shipped); **NO for transport-flip shape** (D-072 BC-5 precedent S368)
- **Adjustment to default budget**: +20-30K novelty reserve over nearest-analog ~155K = ~175-185K projected typical; full 150K Opus cap respected per recalibrated CLAUDE.md FOCUSED_IMPL envelope (if work exceeds, SPLIT trigger AQ-7)

**S375 DEV BUDGET PROJECTION**: 100-150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md table (per master plan-033 § A.4: sandwich-dev back on Opus per Phase F-prime entry); typical 105-160K; 115-175K with STEP 0 STOP-AND-ASK path; full 150K cap respected.

## What was NOT included (deliberately deferred)

Per § A.3 (14 OOS items each with revisit trigger):

1. **Sub-theme F.2 first 3 personas (Buffett/Graham/Taleb)** — separate sub-plan 035
2. **Sub-theme F.3 N-perspective use case extension** — separate sub-plan 036
3. **Sub-theme F.4 V0 expansion to 6/9 personas** — separate sub-plan 037 (NON-BLOCKING CHARTER-TIER GATE)
4. **Sub-theme F.5 CLI dogfood** — separate sub-plan 038
5. **Per-persona role-prompt-pack JSON content authoring** — F.2 scope
6. **D-052 § Implementation step 3 anthropic-dep removal from pyproject.toml** — RM-AS-2 carry-forward; separate D-052-V2 cleanup ADR scope
7. **YAML format for role-packs** — JSON-only V0 per DD-2 STEP 0.3 pyyaml audit + AP-7 named revisit trigger
8. **ChannelManager-style persona-rotation methodology** — V0-V2 if needed
9. **Per-persona historical hit-rate calibration** — post-MVP
10. **New harness hook for RolePromptPack-field-determinism check** — harness-stabilization sweep; AP-23 2+ instance trigger
11. **EchoValidator runtime enforcement for RolePromptPack data** — N/A this sub-plan
12. **Persona-rotation hot-reload / dynamic registry mutation** — Phase F-prime-V2
13. **Charter amendment SHIP for any new I-S<N>** — STOP-FINDING file only
14. **RolePromptPack inheritance hierarchy / DSL** — V0-V2 if needed
15. **Async RolePromptPack loader** — async unnecessary at V0 throughput

## STEP 0 STOP-AND-ASK trigger inventory (5 documented)

Master plan-033 § K.2 implicit 2 FLAGS (pyyaml gap + BC-8 transport-flip regression risk) — architect SPLITS/REFINES to 5 + maps:

1. **(a) CHARTER-TIER — claude CLI substrate unavailable** (STEP 0.4; if `which claude` fails)
2. **(b) TACTICAL — RolePromptPack/PersonaRegistry non-determinism** (STEP 0.6 (a); AP-7 architect-added)
3. **(c) TACTICAL — regression-floor break** (STEP 0.6 (b); existing test_adapter.py or test_bear/quant_agent.py breaks)
4. **(d) BLOCKING — import grep-assert fails** (STEP 0.6 (c); post-D3 `import anthropic` STILL present; this IS the purpose of F.1)
5. **(e) TACTICAL — SPLIT trigger budget overrun** (post-D3 commit; >130K Opus mid-IMPL; per AQ-7)

Master plan-033 § K.2 anticipated FLAG (i) pyyaml dep gap = HANDLED at STEP 0.3 architect-decision JSON fallback (NOT a runtime trigger; NON-BLOCKING design); FLAG (ii) BC-8 transport-flip regression risk = becomes trigger (c) regression-floor break + trigger (d) import grep-assert.

## D-052 cleanup completion path (analysis adapter `import anthropic` removed at S375 dev)

Per § N attestation contract:

| D-052 step | Status pre-S375 (S369 verifier F3) | Status post-S375 dev commit |
|---|---|---|
| 1 (delete _default_transport + import anthropic from analysis adapter + set transport default to claude_cli_transport) | **NOT APPLIED** | **APPLIED via plan-034 D3** — grep-asserted by verifier S376 |
| 2 (delete _default_transport stub from news extractor) | APPLIED (D-051 / D-072) | APPLIED (UNCHANGED) |
| 3 (remove anthropic>=0.40.0 from pyproject.toml) | **NOT APPLIED** | **DEFERRED** per RM-AS-2 (separate D-052-V2 cleanup ADR scope) |
| 4 (regression test asserting (a) _default_transport gone (b) no anthropic import) | APPLIED for BC-5; NOT APPLIED for BC-8 | **APPLIED for BC-8 via plan-034 D4** — test_adapter.py regression additions |

**Net D-052 spec compliance after this plan-034 ships**: 3 of 4 steps complete (75% → 100% for BC-8 surface specifically; step 3 pyproject drop deferred per scope-narrowing).

## S375 dev budget recommendation

**100-150K Opus FOCUSED_IMPL** per recalibrated CLAUDE.md FOCUSED_IMPL envelope + nearest-analog vietnamese-nlp-impl n=3 (~155K Sonnet historical) + 20-30K novelty reserve for RolePromptPack+PersonaRegistry first-instance + 10-20K reserve IF STEP 0.4 CHARTER-TIER GATE fires. SPLIT trigger documented at AQ-7 if >130K mid-IMPL.

Recommended sandwich-dev model: Opus 4.7 (per master plan-033 § A.4 + cold-start FOCUSED_IMPL-Opus profile inheritance). Sonnet 4.6 acceptable fallback per nearest-analog n=3 (all Sonnet); Opus token cost similar to Sonnet but may complete faster.

## Commits

This architect-PLAN-only session produces 2 commits via main session (architect has no Bash; main commits per D-060 + pre-dispatch-architect-commit-guard.sh hook):
1. Plan-034 (split across 4 physical files: main + part2 + part3 + part4) + this observation file (~1250 LOC total)
2. (CONDITIONAL — main session decision) Phase 1b telemetry refresh OR sub-plan 035 architect dispatch decision

ZERO charter / ZERO constitution / ZERO production code / ZERO human-workspace writes from this S374 architect session.

## Plan-035 dispatch trigger

After plan-034 ratification + S375 dev SHIP + S376 verifier PASS:
- Main session dispatches sub-plan 035 sandwich-architect (F.2 First 3 personas Buffett/Graham/Taleb) per master plan-033 § E.1 + § N.2 sequencing
- BLOCKS_ON 034 sub-plan VERIFY (sequential ship; parallel-with empty for 035)
- POSSIBLE PARALLEL post-S376: Phase G-prime master-plan author may dispatch in parallel per master plan-033 § N.2 (independent file scope)

## Compliance attestation (architect S374 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; L-S354-2/L-S366-4/L-S369-1 planner-stats infrastructure gap noted as carry-forward; explicitly NOT fixed here per § hard_rules)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- [x] AP-5 ✓ (re-read all binding sources via VBW protocol — 35 files cited)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers)
- [x] AP-23 ✓ (no refinement-of-rule iterations; new patterns get first-instance HOLD; RolePromptPack data-driven persona + PersonaRegistry stdlib-dict are first-instance)
- [x] D-060 ✓ (architect has no Bash tool; main commits per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- [x] D-052 honored + ADVANCED — THIS plan CLOSES D-052 § Implementation step 1 outstanding for BC-8 surface per DD-5 + DD-8 + § N attestation
- [x] D-072 honored — BC-5 transport-flip MIRROR adopted exactly per DD-5
- [x] memory rule `anthropic_api_to_subagent` honored — IMPLEMENTED for BC-8 perspective-adapter path per DD-5
- [x] 0 charter / 0 constitution / 0 production code / 0 human-workspace writes ✓
- [x] I-S1 ✓ + I-S1-1 + Rule 16 mode 1 ✓ (Conviction StrEnum categorical preserved per DD-6)
- [x] I-S2 ✓ (5-source-evidence chain populated per § H)
- [x] I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward)
- [x] Phase 1b CONSUMED + COLD-START DECLARED for task_class="multi-perspective-impl" + nearest-analog vietnamese-nlp-impl n=3 honored per § A.4
- [x] CHARTER-TIER GATE clause documented per § M (1 CHARTER-TIER + 2 NON-BLOCKING + 1 BLOCKING)
- [x] D1-D5 sub-tracks declare 4 mandatory fields per plan-025 contract
- [x] Recalibrated PLAN budget per CLAUDE.md table (150-230K Opus PLAN) — 4th opportunity per M-S360-2 ratification

---

**END OF S374 ARCHITECT OBSERVATION** — sub-plan-034 + 3 part files (~1100 LOC plan + ~155 LOC observation = ~1255 LOC artifact) authored; main session reviews + dispatches S375 sandwich-dev FOCUSED_IMPL per master plan-033 § N.2 sequencing post-ratification.
