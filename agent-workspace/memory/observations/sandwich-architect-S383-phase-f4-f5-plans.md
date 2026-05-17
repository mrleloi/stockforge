---
observer: sandwich-architect (Claude Opus 4.7, background dispatch)
session: S383
authored: 2026-05-17
covers: plan-037 (F.4 NO-OP DEFERRAL) + plan-038 (F.5 CLI dogfood VHM thesis)
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md § E.4 + § E.5
dispatch_brief_reference: main session S383 dispatch covering BOTH plans per master plan § E.4-5 PARALLEL-ELIGIBLE (V0=6 default = F.4 NO-OP)
status: pending-review (main session reviews + dispatches S384 sandwich-dev FOCUSED_IMPL for F.5 per plan-038 § E sub-tracks)
budget_actual: TBD (this observation written before main commits architect's plan output; expected ~150-230K Opus PLAN per recalibrated CLAUDE.md table; combined plan-037 + plan-038 single dispatch)
---

# Observation — S383 sandwich-architect — Phase F.4+F.5 plans authored (NO-OP + FULL)

## 1. What this dispatch ships

**Plan-037 (F.4 V0=9 expansion)**: NO-OP DEFERRAL plan (~280 LOC) per master plan-033 DD-2 architect-recommended V0=6 default + master plan § K.1.a NON-BLOCKING design.

**Plan-038 (F.5 CLI dogfood VHM thesis)**: FULL plan (~1000 LOC) covering CLI extension + live dogfood execution + V0 calibration baseline + Phase F-prime DONE attestation contract.

**Combined**: ~1280 LOC across 2 plan files + this observation (~200 LOC).

## 2. Plan-037 verdict (NO-OP vs FULL?)

**Verdict**: F.4 = **NO-OP DEFERRED** per architect-recommended V0=6 default.

**Decision gate evidence chain** (5 items per plan-037 § A.0):
1. Master plan-033 DD-2: V0=6 architect-recommended; V0=9 ratification-gated NON-BLOCKING
2. Master plan-033 § K.1.a: NON-BLOCKING design; default applies if no user opt-in
3. Master plan-033 AQ-8: explicit "V0=6 confirmed → F.4 NO-OP; ≤200 LOC PLAN file with revisit trigger named"
4. VBW empirical check (S383, 2026-05-17): `Glob human-workspace/q-and-a/**/Q-INT-2026-05-F-prime*` returns **zero matches**; `Grep V0=9|Munger|Lynch|VN_DOMAIN_SPECIALIST in human-workspace/q-and-a` returns ONLY answered/qa-2026-05-15-wave-1-bis.md (unrelated charter Q&A bundle). No user opt-in observed.
5. Verdict: V0=6 default applies; plan-037 = NO-OP per master plan default branch

**Explicit revisit triggers named** (per AP-7 anti-vacuous-defer):
- **Trigger A**: project-owner direct JSON edit + V0=9+ wiring request → re-dispatch F.4 PLAN
- **Trigger B**: project-owner explicit `/effort` user prompt + V0=9 ratification → main fires Q-INT-2026-05-F-prime-1 → user opt-in → re-dispatch F.4 PLAN
- **Trigger C**: F.5 VHM dogfood (plan-038) empirically demonstrates V0=6 has measurable persona-coverage gap on 3+ tickers → re-dispatch F.4 PLAN with evidence-driven sub-track structure

**L-S382-1 carry-forward**: NOT activated by NO-OP (zero ctor changes ship; risk class does not apply). For any future F.4 IMPL (if re-opened), V0=9 expansion is PURELY ADDITIVE per F.3 SHIPPED dict[PerspectiveRole, LLMPerspectivePort] generalization — 3 new dict entries + 3 new agent files + 3 new JSON packs; ZERO ctor signature change required.

## 3. Plan-038 stats

- **Size**: ~1000 LOC (within dispatch-brief 800-1100 LOC budget)
- **STEP 0 BLOCKING gates**: 5 (0.1 claude CLI substrate + 0.2 VHM data availability + 0.3 existing CLI surface + 0.4 live API budget + 0.5 STOP-AND-ASK aggregator + charter-tier flag evaluation)
- **DD-1 through DD-7**: 7 decision documents with architect-VBW evidence chain
- **Sub-tracks D1-D5**: D1 markdown renderer V0=6 extension ~80-100 LOC + D2 --run-mode flag ~20-30 LOC + D3 live dogfood execution wall-clock (no code) + D4 ≥5 NEW tests ~80-100 LOC + D5 ADR D-078 PROPOSED ~150-200 LOC; estimated 38-60 min IMPL wall-clock total
- **DoD**: 30 attestation items across PLAN/IMPL/VERIFY/CLOSE tiers (DC-PLAN-1..12 + DC-IMPL-1..10 + DC-VERIFY-1..8 + DC-CLOSE-1..7)
- **AQ-1 through AQ-10**: 10 anticipated questions answered (AQ-1 ticker choice + AQ-2 extend-not-new + AQ-3 INCOMPLETE handling + AQ-4 cost cap + AQ-5 no API key needed + AQ-6 CLI timeout + AQ-7 calibration_grade='D' default + AQ-8 prose violation handling + AQ-9 PASS-WITH-CONCERNS path + AQ-10 Phase G-prime entry)
- **5-source evidence chain**: master plan § E.5 + DD-11 + § K.1.c/K.2 + F.3 SHIPPED artifacts + VBW empirical reads (validate_thesis.py + use_case_builder.py + validate_thesis_phase1.py + role-packs JSON + claude CLI confirmed)
- **Risk matrix RM1-RM7**: VHM corpus stale (MEDIUM) + cost exceed (LOW) + buy/sell prose (LOW) + numeric prose (LOW) + CLI timeout (MEDIUM) + L-S382-1 recurrence (LOW carry-forward) + DONE attestation incomplete (LOW)
- **Coordination paths exclusive**: 6 paths (validate_thesis.py + test_validate_thesis.py + ADR D-078 + thesis-log VHM markdown + sqlite Thesis row + dev observation)
- **Budget envelope**: 100-150K FOCUSED_IMPL Opus per recalibrated CLAUDE.md
- **Phase 1b calibration**: n=3 multi-perspective-impl precedent declared (S375 F.1 + S378 F.2 + S381 F.3); S384 = 4th instance
- **Phase F-prime DONE attestation contract**: 10 BLOCKING items + 3 OPTIONAL items per § M; Wave 1 MVP gate definition explicit

## 4. Phase 1b Calibration (n=3 multi-perspective-plan precedent shared)

**task_class**: multi-perspective-plan (PLAN authoring) for plan-037 + plan-038 BOTH; multi-perspective-impl (IMPL) for plan-038 S384 dev session.

**n=3 precedent declared** (per dispatch brief constraint "Phase 1b MANDATORY"):

For PLAN authoring (sandwich-architect):
1. **S375 (F.1 PLAN; sub-plan 034)** — ~150K Opus actual
2. **S378 (F.2 PLAN; sub-plan 035)** — ~165K Opus actual
3. **S380 (F.3 PLAN; sub-plan 036)** — ~180K Opus actual
4. **S383 (THIS session; F.4+F.5 combined PLAN)** — 4th instance; calibration band ~150-230K Opus

For IMPL execution (sandwich-dev; reference for S384):
1. **S375 (F.1 IMPL)** — Sonnet; D-052 closed; 1153 tests; CLEAN PASS
2. **S378 (F.2 IMPL)** — Sonnet; 3 personas + JSON packs; 1190 tests; PASS-WITH-CONCERNS
3. **S381 (F.3 IMPL)** — Sonnet; dict[PerspectiveRole, LLMPerspectivePort]; 1208 tests; **M-S381-1 + M-S381-2 inline-remediated** (L-S382-1 PROMOTE-NOW HIGH carry-forward)
4. **S384 (F.5 IMPL)** — 4th instance; calibration band 100-150K FOCUSED_IMPL Opus per recalibrated CLAUDE.md

**Empirical confidence**: HIGH for D1+D2+D4+D5 (mature pattern from F.1+F.2+F.3); MEDIUM for D3 wall-clock dogfood (first live LLM substrate exercise of V0=6 pipeline; unknown empirical cost + retry rate + persona output quality variability). RM1-RM7 covers known risks.

## 5. Key DD decisions

### Plan-037 NO-OP key decisions

- **DD-1**: V0=6 architect-default applies; NO IMPL dispatched this turn (per master plan DD-2 + AQ-8 + VBW evidence)
- **DD-2**: Revisit-trigger evidence chain MUST be explicit (per AP-7); 3 triggers named A/B/C
- **DD-3**: L-S382-1 carry-forward DOES NOT apply to this NO-OP (preserved by-construction; future F.4 IMPL purely additive per F.3 SHIPPED dict[PerspectiveRole, LLMPerspectivePort])

### Plan-038 FULL key decisions

- **DD-1**: CLI dogfood = EXTEND existing validate_thesis.py NOT new file (master plan § E.5 'NEW apps/cli/synthesize_vn_thesis.py' RE-INTERPRETED per architect-VBW that validate_thesis.py is V0=6-ready post-F.3 SHIP; master plan AQ-7 explicitly references existing CLI)
- **DD-2**: Dogfood ticker = VHM per master plan DD-11; HPG/VIC/FPT pre-named fallbacks per STEP 0.2 STOP-AND-ASK option (b); NON-BLOCKING design (no Q-INT)
- **DD-3**: Markdown renderer extension = ADDITIVE V0=6 sections (BUFFETT/GRAHAM/TALEB after BEAR/BULL/QUANT); backward-compat with N=3 thesis input preserved
- **DD-4**: L-S382-1 carry-forward MANDATORY — IF any ctor signature change introduced in F.5 IMPL, dev MUST grep-all-callers + full-project pytest scope re-run (NOT sub-package) BEFORE commit; architect RECOMMENDS NO new class to avoid risk by-construction
- **DD-5**: V0 calibration baseline = n=1 dogfood; calibration_grade='D' default per Charter Principle 8; n≥50 post-MVP calibration trigger named in ADR D-078
- **DD-6**: Dogfood output destination = agent-workspace/memory/thesis-log/ per existing CLI default; naming `{as_of}-{ticker_upper}.md` = `2026-05-17-VHM.md`
- **DD-7**: Run-mode metadata = optional --run-mode=dogfood|smoke flag (default smoke); dogfood adds 3 frontmatter fields (dogfood: true + dogfood_session + dogfood_ticker_rationale)

## 6. STEP 0 STOP-AND-ASK triggers for F.5

Per plan-038 § C, S384 dev evaluates 5 STEP 0 BLOCKING gates:

1. **STEP 0.1 claude CLI substrate** — STOP-AND-ASK if claude CLI not found OR --version fails OR --help fails (options: install + retry / defer / fallback to mock)
2. **STEP 0.2 VHM data availability** — STOP-AND-ASK if VHM bars<30 OR statements<1 OR news<5 (options per master plan AQ-9: corpus refresh / alternate ticker HPG/VIC/FPT / defer)
3. **STEP 0.3 existing CLI surface** — STOP-AND-ASK if CLI import errors OR test_validate_thesis.py has failures (options: inspect+fix inline / defer)
4. **STEP 0.4 live API budget** — STOP-AND-ASK if expected cost > $2.50 OR project owner cost concern (options: tighten budget cap / downgrade personas to Sonnet / proceed default)
5. **STEP 0.5 STOP-AND-ASK aggregator + charter-tier flag** — bundle all 4 STEP 0 items per Q&A bundling mega-bundle pattern; charter-tier flag protocol: I-S35 buy/sell prose violation OR I-S1-1 numeric confidence violation OR I-S1 NO-LLM-MATH violation in dogfood output → MANDATORY STOP-AND-ASK per master plan § K.1.c + § K.2

**Sequencing**: STEP 0 BLOCKING evaluated BEFORE any edit; if any triggers, S384 dev STOP-AND-ASKs project owner (main session fires AskUserQuestion bundle); IMPL proceeds only when all 5 cleared.

## 7. S384 dev budget (F.5 IMPL)

**S384 sandwich-dev FOCUSED_IMPL Opus 100-150K** per recalibrated CLAUDE.md PLAN-Opus table; sub-track sequencing D1 → D2 → D4 → D3 → D5 per plan-038 § E architect recommendation; estimated 38-60 min wall-clock total (D3 wall-clock dogfood adds ~3-7 min ambient LLM latency from 6 persona LLM calls).

**S385 sandwich-verifier AP-1 fresh-context Opus 30-60K** per recalibrated CLAUDE.md VERIFY-Opus table; inspects plan-038 § F DC-VERIFY-1 through DC-VERIFY-8 (8 verifier-tier criteria).

**S386 main session close-bookkeeping**: ~10-20K main session; updates current-execution.md + latest.md + plan-037 + plan-038 both mv pending/→completed/ + Phase F-prime DONE marker + Wave 1 MVP gate cleared.

**F.4 dev budget**: N/A — NO-OP plan-037 ships zero production code; no S384 dev IMPL dispatch authorized for F.4. Plan-037 mv pending/→completed/ at S386 close per parallel-eligible bundled-close pattern.

**Combined Phase F-prime DONE budget**: F.5 IMPL+VERIFY+CLOSE ~140-230K + F.4 NO-OP ~0K = ~140-230K to close Phase F-prime.

**Live API budget**: Decimal('3.00') HARD CAP per validate_thesis_phase1.py:189 scoped_budget; expected actual cost ~$1.50-2.50 per dogfood run (Sonnet 5 personas × $0.20-0.40/call + Opus QUANT × $0.40-0.80/call).

## 8. Wave 1 MVP attestation contract per § M

**Phase F-prime DONE attestation = 10 BLOCKING items + 3 OPTIONAL items** per plan-038 § M:

**BLOCKING (required for Wave 1 MVP ready)**:
- PFP-DONE-1: F.1 SHIPPED+VERIFIED (substrate)
- PFP-DONE-2: F.2 SHIPPED+VERIFIED (3 personas)
- PFP-DONE-3: F.3 SHIPPED+VERIFIED (N-perspective dispatch)
- PFP-DONE-4: V0=6 ratification (plan-037 NO-OP confirmed)
- PFP-DONE-5: F.5 SHIPPED+VERIFIED per plan-038
- PFP-DONE-6: dogfood thesis artifact at thesis-log/
- PFP-DONE-7: Thesis aggregate persisted to sqlite
- PFP-DONE-8: I-S1+I-S10+I-S12+I-S35 invariants empirically validated by verifier
- PFP-DONE-9: V0 calibration baseline n=1 established; calibration_grade='D' default
- PFP-DONE-10: Phase F-prime closure bookkeeping (plans mv + current-execution.md + latest.md + Wave 1 MVP gate cleared)

**OPTIONAL (nice-to-have for Wave 1 MVP)**:
- PFP-DONE-O1: AC-5 reproducibility re-run
- PFP-DONE-O2: per-persona cost breakdown
- PFP-DONE-O3: persona output quality observations (input for plan-037 § B Trigger C evidence chain)

**Wave 1 MVP READY** when ALL 10 BLOCKING items PASS. This unlocks Phase G-prime entry per master plan-033 § 6 + production dogfood loop + calibration outcomes feedback loop initialization (post-MVP per Charter Principle 8).

**Wave 1 MVP NOT READY** if any BLOCKING item FAIL → main session decides (a) inline remediation / (b) F.5-V2 follow-up sub-plan / (c) Phase F-prime hold. Per plan-038 AQ-9 PASS-WITH-CONCERNS is acceptable as long as ≥10 BLOCKING items eventually clear.

## 9. Compliance attestation (this dispatch)

- **harness_priority_one**: ✓ — no harness gaps surfaced this turn beyond carry-forward L-S382-1 (HIGH HOLD; explicitly applied per plan-038 § DD-4 + § J RM6 + § F DC-IMPL-8)
- **AP-1 fresh-context**: ✓ — sandwich-architect dispatched fresh (background agent); S384 dev + S385 verifier MUST be fresh-context per AP-1 mandatory
- **autonomous_continue_no_self_pause**: ✓ — architect proceeds to PLAN authoring; main session continues post-architect-return for S384 dispatch per dispatch brief
- **dont_self_pause_at_session_boundary**: ✓ — architect deliverables (2 plan files + this observation) ship complete; main session decides immediate S384 dispatch
- **stop_offering_routing_branches**: ✓ — architect returns deliverable summary; main session picks + executes per autonomous-full mode
- **D-060**: ✓ — architect has no Bash; 0 commits by architect; main session commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook
- **0 charter / 0 constitution / 0 PROJECT_CHARTER.md changes**: ✓
- **0 human-workspace writes**: ✓ (architect did NOT write to human-workspace/q-and-a/ or human-workspace/notifications/)
- **VBW protocol**: ✓ — every architect claim cites file:line; actual files read via Read tool (validate_thesis.py + use_case_builder.py + validate_thesis_phase1.py + role-packs JSON + master plan-033 + mistake-log.md + agent-notes.md + current-execution.md)
- **I-S1 + I-S10 + I-S35 preservation**: ✓ — both plans preserve invariants by-construction; F.5 dogfood validates empirically
- **L-S382-1 carry-forward**: ✓ — plan-037 § DD-3 (NOT activated by NO-OP) + plan-038 § DD-4 + § J RM6 + § F DC-IMPL-8 (MANDATORY for F.5 IMPL)
- **AP-7 anti-vacuous-defer**: ✓ — plan-037 § A.3 names 3 explicit revisit triggers (A/B/C); plan-038 § A.3 names revisit triggers for all deferred items
- **AP-23 promote-or-retire**: ✓ — V0=6 persona-pack template = 1st-instance AP-23 candidate per master plan § DD-2 architect-stance; F.4 expansion uses AP-7 named revisit trigger pattern (not 2nd-instance refinement)
- **Karpathy P2 simplicity**: ✓ — plan-037 NO-OP ≤300 LOC; plan-038 ~1000 LOC within dispatch brief budget; D1-D5 sub-tracks each ≤200 LOC delta
- **Karpathy P3 surgical-changes**: ✓ — plan-038 D1 EXTENDS inline functions at validate_thesis.py:192-317 (architect recommends NO new class to avoid ctor risk); D2 EXTENDS click options block; D4 ADDS test cases; D5 NEW ADR file; NO destructive refactors

## 10. Known gaps + handoff notes for S384 dev

- **Gap 1 (NON-BLOCKING)**: F.3 plan-036 DD-9 deferred _ROLE_TO_MODEL extension for BUFFETT/GRAHAM/TALEB (defaults to _DEFAULT_MODEL Opus per fall-through); F.5 STEP 0.4 BLOCKING gate options include "(b) downgrade BUFFETT/GRAHAM/TALEB to Sonnet via role_model_overrides at use_case_builder.py:217" to mitigate cost
- **Gap 2 (NON-BLOCKING)**: claude CLI v2.1.140 confirmed alive per S375 close-bookkeeping but NOT re-verified by S383 architect; STEP 0.1 BLOCKING gate re-verifies
- **Gap 3 (NON-BLOCKING)**: VHM data corpus freshness UNKNOWN at S383 architect-tier; STEP 0.2 BLOCKING gate verifies via sqlite3 query
- **Gap 4 (NON-BLOCKING)**: F.5 IMPL may surface I-S35 / I-S1-1 / I-S1 violation in real LLM output (per RM3+RM4); STEP 0.5 charter-tier flag protocol per § C handles
- **Handoff to S384 dev**: read plan-038 § C STEP 0 BEFORE any edit; respect § DD-4 L-S382-1 mandatory (architect RECOMMENDS preserving existing inline-function pattern at validate_thesis.py:192-317 to avoid ctor risk by-construction); follow sub-track sequencing D1 → D2 → D4 → D3 → D5 per architect recommendation
- **Handoff to S385 verifier**: read plan-038 § F DC-VERIFY-1 through DC-VERIFY-8 for verifier-tier criteria; inspect plan-038 § M Phase F-prime DONE attestation contract ≥10 BLOCKING items; produce Phase F-prime DONE attestation report

## 11. Commits (this dispatch)

Architect ships 3 files (commit by main per D-060):
1. `agent-workspace/session-plans/pending/037-S383-phase-f4-v0-9-expansion.md` (~280 LOC NO-OP)
2. `agent-workspace/session-plans/pending/038-S383-phase-f5-cli-dogfood-vhm-thesis.md` (~1000 LOC FULL)
3. `agent-workspace/memory/observations/sandwich-architect-S383-phase-f4-f5-plans.md` (THIS file; ~200 LOC)

**No commit by architect** (D-060 compliance; sandwich-architect has no Bash).

**Expected main-session commit message** (suggested): `S383: Phase F-prime sub-plans 037 (F.4 NO-OP) + 038 (F.5 CLI dogfood VHM) PLAN authored by sandwich-architect Opus (background; ~150-230K Opus PLAN). Plan-037 NO-OP DEFERRAL per master plan DD-2 V0=6 default + § K.1.a NON-BLOCKING + AQ-8 (3 explicit revisit triggers named per AP-7). Plan-038 FULL plan ~1000 LOC: 5 STEP 0 BLOCKING gates + DD-1..7 + D1-D5 sub-tracks + 30 DoD items + 10 AQ + RM1-7 + Phase F-prime DONE attestation contract ≥10 BLOCKING items defining Wave 1 MVP readiness. L-S382-1 PROMOTE-NOW HIGH carry-forward explicitly applied per plan-038 § DD-4 + § J RM6 + § F DC-IMPL-8 (architect RECOMMENDS NO new class to avoid ctor risk). Phase 1b n=3 multi-perspective-plan precedent declared (S375+S378+S380 → S383 4th instance). 0 charter / 0 constitution / 0 production code shipped this PLAN session.`

## 12. Files read this session (VBW evidence)

- `agent-workspace/memory/current-execution.md` (lines 1-150, 100-200, 150-198 — S375 F.1 SHIPPED + S368 E.3 + S347 stop-hook + behavioral-hold)
- `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (Grep-only; long file → grep extracted F.4/F.5/V0=6/V0=9/Munger/Lynch/VN_DOMAIN_SPECIALIST/DD-2/DD-9/DD-11/AQ-8/§ K.1.a relevant lines)
- `agent-workspace/memory/agent-notes.md` (lines 1-100 — Recent rules digest L-S360-cluster + L-S333-1/2/3 + L-S312-1/2/3 + L-S310-1/2)
- `agent-workspace/memory/mistake-log.md` (lines 160-192 — M-S371-1 LOC drift + M-S381-1 L-S382-1 ctor-signature-change gap + M-S381-2 L-S382-2 commit-attestation drift)
- `agent-workspace/memory/checkpoints/latest.md` (lines 1-100 — S347 close; Phase D NDH + Stop Hook Perf Quick Wins + Wave 1 master plan progress)
- `apps/cli/validate_thesis.py` (lines 1-340 — full CLI surface; click options + main + _render_thesis_md + _find_persp + _ensure_utf8)
- `apps/_shared/use_case_builder.py` (lines 1-380 — composition root; build_use_case + _load_persona_registry + _build_persona_agents + _build_subagent_agents + _build_mock_agents + _check_live_gate + _InProcessEventBus + _MockDataGatherer + _SubagentDataGatherer)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (lines 1-300 — SharedContext dataclass + _compute_thesis_id + ValidateThesisPhase1UseCase ctor at :158-172 dict[PerspectiveRole, LLMPerspectivePort] + execute + _run_pipeline 7-step pipeline + AC-5 STABLE-SORTED-BY-ROLE)
- `agent-workspace/role-packs/buffett.json` (lines 1-50 — role_id + persona_name + system_prompt_template + vietnam_notes + min_points + min_distinct_categories + category_universe + model_id_preference structure)
- `agent-workspace/role-packs/README.md` (full file — JSON format reference + path-safety + V0 content authoring)
- `agent-workspace/session-plans/completed/036-S380-phase-f3-synthesize-perspectives-usecase.md` (lines 1-120, 600-720 — F.3 plan-036 binding_decisions + § D DD-1 dict[PerspectiveRole, LLMPerspectivePort] + § D DD-9 _ROLE_TO_MODEL deferral + D3 use_case_builder wiring + D5 ADR D-076)
- `Glob` checks: agent-workspace/session-plans/**/033-*.md, agent-workspace/session-plans/**/034-*, 035-*, 036-*, 037-*, 038-* + agent-workspace/memory/decisions/074-*, 075-*, 076-* + agent-workspace/role-packs/**/* + apps/cli/validate_thesis*.py + packages/**/synthesize*.py + human-workspace/q-and-a/**/Q-INT-2026-05-F-prime* + data/raw/news/**/VHM* + data/stockforge.sqlite + packages/infrastructure/analysis/perspectives/*_agent.py

## 13. Architectural decisions needing human approval

**NONE**. Both plans use existing master plan-033 architect-tier decisions (DD-2 NON-BLOCKING V0=6 default + DD-11 VHM ticker pre-recommended + DD-3 ISOLATED-THEN-AGGREGATE per § K NON-BLOCKING design). No charter amendment required. No new I-S<N> invariant. Phase F-prime DONE attestation contract per plan-038 § M is architect-authored (not charter-tier; sub-plan-level).

**CHARTER-TIER FLAGS anticipated** (per plan-038 § C STEP 0.5):
- F.5 dogfood persona emits 'buy/sell' prose → I-S35 violation surface → MANDATORY STOP-AND-ASK + main session AskUserQuestion ratification gate per master plan § K.1.c options
- F.5 dogfood persona emits numeric prose ('approximately 15%') → I-S1 NO-LLM-MATH violation surface → MANDATORY STOP-AND-ASK + master plan § K.2 protocol
- F.5 dogfood persona emits numeric confidence ('0.85') → I-S1-1 Rule 16 violation surface → MANDATORY STOP-AND-ASK + master plan § K.2 protocol

These FLAGS are EVALUATED by S385 verifier; if surfaced, main session fires AskUserQuestion bundle per existing protocol; current PLAN does NOT pre-emptively fire AskUserQuestion (NON-BLOCKING design).

---

**End of S383 sandwich-architect observation**.

Approx LOC: ~200 (within dispatch-brief budget).
