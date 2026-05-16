---
observation_id: sandwich-architect-S346-planner-upgrade-plan
session: S346
agent: sandwich-architect (background; Claude Opus 4.7)
date: 2026-05-16
agentId: (this dispatch's runtime id; filled by main session at task-notification)
budget_used: ~50-60K (within 60-80K PLAN envelope; single-pass authoring, no second-architect parallel dispatch)
deliverable: agent-workspace/session-plans/pending/025-S346-planner-upgrade.md (~1050 LOC)
phase: harness-substrate (non-product; per harness_priority_one doctrine)
status: PLAN-AUTHORED-AWAITING-DISPATCH
---

# S346 — Planner Subagent Upgrade PLAN authoring (observation)

## What I did

1. **VBW reading pass** (~15 files; ~25K tokens):
   - `agent-workspace/memory/observations/2026-05-16-planner-upgrade-proposal.md` (primary design source — E1-E4 enhancements with concrete examples)
   - `.claude/agents/sandwich-architect.md` (D1 target; verified 183 LOC + Phase 1 lines 32-40 + Output § lines 157-163)
   - `.claude/agents/master-planner.md` (D2 target; verified 168 LOC + Phase 1 lines 40-47 + Phase 5 line 74 vague "Identify parallel opportunities")
   - `.claude/agents/sandwich-dev.md` (D3 target; verified ~163 LOC + Constraints lines 135 + just-edited to opus per S346 turn)
   - `.claude/agents/action-guide-planner.md` (D3 cross-ref; 178 LOC verified)
   - `.claude/agents/bdd-planner.md` (D3 cross-ref; 163 LOC verified)
   - `.claude/agents/sandwich-verifier.md` (verifier-side context; tools=[Read,Glob,Grep,Bash] no Write — informs DD-12 sandwich-verifier observation handling unchanged)
   - `scripts/hooks/self-awareness-aggregate.sh` (D5 reference — verified existing schema header comment lines 14-17 + ROOT_DIR resolution lines 22-32)
   - `scripts/hooks/firing-tests/self-awareness-aggregate-fire-test.sh` (D4 fire-test pattern reference)
   - `scripts/hooks/firing-tests/correction-rate-aggregator-fire-test.sh` (D4 fire-test pattern reference; alternate structure)
   - `agent-workspace/memory/dispatch.jsonl` first 3 rows (Phase 1b read-source verification; JSON-per-line format with event/dispatch_id/agent_type/duration_ms/outcome/tokens_used confirmed)
   - `agent-workspace/memory/component-telemetry.jsonl` first 3 rows (Phase 1b read-source verification; per-tool + per-agent format confirmed)
   - `agent-workspace/memory/self-awareness/sessions-rollup.tsv` first 5 rows (Phase 1b read-source + D5 schema-extension target; current 8-col schema confirmed)
   - `agent-workspace/memory/current-execution.md` first 180 lines (next session id resolution; S343-S344 done; S345 verifier user-paused → next dev session is S347; architect = S346)
   - `agent-workspace/memory/checkpoints/latest.md` first 15 lines (S342 close — Harness Sweep DONE; latest harness anomalies status)
   - `agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md` first 40 lines (ADR template + 12-field schema reference for D-069)
   - `agent-workspace/session-plans/completed/021-S340-harness-stabilization-sweep.md` first 200 lines (plan shape reference for sub-track + DD + § layout)
   - `agent-workspace/session-plans/completed/022-S343-phase-d-ndh-adapter.md` first 150 lines (plan shape reference — alternate format with STEP 0 BLOCKING + AQ-pre-answered)
   - `agent-workspace/memory/observations/sandwich-architect-S340-harness-stabilization-plan.md` first 100 lines (observation format reference)
   - `.claude/settings.json` end-to-end (D6 wire-up location — Stop chain lines 315-523; verified `self-awareness-aggregate.sh` line ~408 + `profile-template-auto-populate.sh` line ~412 chain positions)

2. **Architectural decisions made + adversarial alternates rejected** (per Karpathy P1):

   **DD-1 Phase 1b position**: chose insert-between-Phase-1-and-Phase-2 over (a) merge-into-Phase-1 [REJECTED — Phase 1b is skippable per Q-PL2 while Phase 1 always mandatory; mixing breaks skip-audit] (b) insert-after-Phase-2 [REJECTED — Phase 2 architectural decisions should consume calibration, not precede].

   **DD-2 read budget cap**: chose `tail -30` per file over (a) full-log-scan [REJECTED — 5000-row context bloat for marginal gain] (b) `tail -10` [REJECTED — too small for low-volume task_classes].

   **DD-3 required-field placement**: chose 3-fields-required (parallel_with/blocks_on/coordination_paths_exclusive) over (a) only-emit-when-parallel [REJECTED — silent-absent ambiguous] (b) free-form text description [REJECTED — not lint-checkable].

   **DD-4 lint location**: chose dispatch-time refuse (in D4 hook OR adjacent linter) over (a) runtime-trust [REJECTED — corrupted state is catastrophic] (b) post-hoc audit [REJECTED — too late].

   **DD-5 parallel ceiling**: chose 3-initial per Q-PL1 ratification; revisit-trigger named per AP-7 (10+ successful runs).

   **DD-6 skip threshold**: chose explicit-skip-line per Q-PL2 ratification; silent-skip = lint refuse.

   **DD-7 schema strategy**: chose APPEND per Q-PL3 ratification; STOP-AND-ASK clause added in case D5 finds entanglement (existing emit might be tighter than line-comment suggests).

   **DD-8 hook cadence**: chose Stop+debounce-per-plan_id per Q-PL4 ratification; marker pattern mirrors escalation-engine.sh:56 (hour-bucket style adapted to plan-id keying).

   **DD-9 `.planner-stats.tsv` schema**: 6 columns (task_class, sample_size, avg_wall_min, parallel_hit_rate, parallel_savings_avg, last_updated) chosen for cheapest-architect-query; rejected (a) per-plan rows [too verbose for cold reads] (b) JSON format [violates bash+awk-only portability per L-S11-1].

   **DD-10 age-decay**: chose gradient (1.0/0.5/0.0 at 30/90 days) over (a) hard cutoff [REJECTED — cliff vs gradual] (b) no-decay [REJECTED — RM2 stale-bias risk].

   **DD-11 calibration summary format**: 1-paragraph section in plan output per RM9 noise-cap; format template enforced in DoD AGENT-5 grep.

   **DD-12 ADR D-069 tier**: PROPOSED at IMPL tier (no cool-down per severity-schema); 30-day Empirical-Tuning-Window clause invites revisit per AP-7.

3. **Plan structure followed brief sections A-N completely**:
   - § A session metadata (8 fields including plan_id/target_session/budget/phase/type)
   - § B predecessor + invocation context (4 empirical findings + projected concrete saving)
   - § C charter compliance map (10-row table)
   - § D Architecture Decisions DD-1..DD-12 (each with decision + rationale + rejected alternative + implementation hint)
   - § E sub-track decomposition D1-D6 (each declaring the 3 NEW fields per DD-3 — demo-by-example)
   - § F DoD checklist (37 criteria; FILE×9 + AGENT×5 + HOOK×3 + SCHEMA×3 + PARALLEL×3 + CALIB×2 + ADR×1 + COMPLIANCE×5 + SMOKE×3 + BOOK×3)
   - § G Architecture Questions AQ-1..AQ-10 (all pre-answered per Q-PL1-4 ratifications + cold-start + grandfathering + violation handling + co-existence + rate-limit + main-session-scope)
   - § H 5-source evidence chain (per I-S2; ≥5 sources per claim)
   - § I Risk-Mitigation RM1..RM10 (each with probability/impact/mitigation)
   - § J coordination paths (S347 IMPL window + S348 verifier window paths off-limits)
   - § K budget envelope (~130K central within 100-150K; cold-start declared per DD-11)
   - § L AP-23 attestation (7-row instance-counter table)
   - § M compliance attestation (17-row table)
   - § N out-of-scope with explicit AP-7 revisit triggers (9 deferred items)

## Decisions I made + why

### Key decision matrix

| Decision | Choice | Rationale |
|---|---|---|
| Plan ID | 025-S346-planner-upgrade | Sequential after plan-024 (none authored; next is 025); session id S346 = architect's dispatch; target_session S347 = dev |
| ADR number | D-069 | Highest existing = D-066; D-067 + D-068 reserved (S341 D-067 OPTIONAL janitor + S342 L-S342-1 cross-layer DI candidate); D-069 next available |
| Plan target_session | S347 with informational note | Session numbering may slip if main session intercedes; plan_id is authoritative binding |
| Q-PL1-4 ratifications | 4-Qs honored verbatim | User explicit ratification 2026-05-16T~20:30 SEAST "follow your recommendation"; no architect re-litigation |
| Sub-track count | 6 (D1-D6) | One sub-track per file/concern: D1 architect template, D2 master-planner template, D3 dev+2-cross-refs, D4 new hook+firing-test, D5 schema extension+new TSV, D6 ADR+settings.json+bookkeeping |
| Parallel-with declarations in this plan | D2 parallel_with D3; rest sequential | D1 establishes template shape both D2 and D3 mirror — must precede; D4 depends on D5 schema; D6 depends on D4+D5; D2 and D3 touch separate files post-D1 → parallel-safe |
| Phase 1b cold-start handling | Graceful degradation to boilerplate budget | First architect dispatch after plan-025 ships has empty `.planner-stats.tsv`; AQ-5 + RM2 explicit |
| Lint location | D4 hook OR adjacent linter (dev's call) | Architect leaves implementation-mechanism choice to dev (DD-4); both acceptable per AP-7 |
| ADR D-069 Empirical-Tuning-Window | 30 days post-deployment | Mirrors observation RM2 + Karpathy P2 simplicity (single TTL number); revisit-trigger named per AP-7 |
| STOP-AND-ASK clause for D5 | Schema entanglement risk | self-awareness-aggregate.sh emit-block might rewrite rather than append; surface as plan-finding if found |

## What I rejected

- **E5+ scope creep into this plan**: per RM8, explicit STOP-AND-SPLIT. Auto-tuning of DD-2/DD-5/DD-10 thresholds, main-session parallel-dispatch productization, multi-plan composite metrics — ALL deferred to § N with revisit triggers. Plan-025 binds E1-E4 strictly.

- **Full re-design of sessions-rollup.tsv with versioned-header line**: REJECTED per Q-PL3 + DD-7 (append-only minimum disruption). Versioned header would require migration of `correction-rate-aggregator.sh` + `profile-template-auto-populate.sh` readers.

- **Phase 1b reads `mistake-log.md` full file**: REJECTED in favor of last-200-LOC digest per CLAUDE.md tracking-retention rule (mistake-log digest only ≤200 LOC).

- **Mandatory Phase 1b for ALL plans incl. single-file FOCUSED_IMPL**: REJECTED per Q-PL2 (1-2 sub-track skippable; explicit-skip-line required).

- **`bdd-planner.md` full Phase 1b upgrade in this bundle**: REJECTED per § N item 7 — minimal cross-ref only; full upgrade deferred to future planner-upgrade-phase-2 plan with revisit trigger (5+ BDD-planner dispatches showing Phase 1b benefit).

- **Architect-writes-own-ADR-D-069 in this plan-session**: REJECTED per "no production code in plan-session" hard rule; ADR ships as D6 dev task in S347.

- **Backfill of historical sessions-rollup rows with plan_id metadata**: REJECTED per § N item 4 + observation § "going forward; no backfill needed for first cycle"; revisit if architect requests historical comparison ≥3 times.

## Open questions remaining (NONE for user; some for verifier S348)

For user: NONE. All 4 Q-PL design Qs already ratified pre-dispatch. Architect did not introduce new charter/scope questions per `full_autonomous_no_supervised`.

For sandwich-verifier S348:
- **V-OPEN-1**: did dev resolve the DD-7 STOP-AND-ASK contingency for self-awareness-aggregate.sh entanglement? If yes, what was found + how resolved?
- **V-OPEN-2**: did dev's D4 hook achieve ≤5sec Stop-chain delta per SMOKE-3? Empirical wall-time measurement required.
- **V-OPEN-3**: dogfood expectation — was NEXT architect dispatch after this verify able to consume Phase 1b? (If S348 + S349 chain runs, this is empirically testable.)

## Compliance attestation (this PLAN session)

| Rule | Status |
|---|---|
| harness_priority_one | ✓ (planner-upgrade IS harness investment; supersedes Phase 4 product work per user directive) |
| 0 production code | ✓ (architect-only; D1-D6 are FUTURE dev edits) |
| 0 charter writes | ✓ (PROJECT_CHARTER.md untouched) |
| 0 constitution writes | ✓ (agent-workspace/constitution/** untouched; ADR D-069 lives in decisions/) |
| 0 human-workspace writes | ✓ (only plan file + this observation file written this turn) |
| 0 commits by architect | ✓ (sandwich-architect tools: [Read, Glob, Grep, Write] — no Bash; main commits per D-060 + pre-dispatch-architect-commit-guard.sh hook) |
| 0 pushes by architect | ✓ (D-060: agent never pushes) |
| AP-1 fresh-context | ✓ (this architect dispatched fresh-context per main session brief) |
| VBW protocol | ✓ (15 files read end-to-end; every claim cites file:line) |
| Karpathy P1-P4 | ✓ (P1 think-first with 4 Qs ratified pre-design; P2 simplicity — no E5+ creep; P3 surgical — 6 sub-tracks each scoped; P4 goal-driven — 37 DoD criteria with measurable verification) |
| AP-7 anti-vacuous-defer | ✓ (all 9 § N defers name revisit triggers) |
| AP-23 ritual-demotion | ✓ (4 Qs ratified at 1st instance; ADR D-069 Empirical-Tuning-Window for 2nd-instance trigger) |
| 5-source evidence chain | ✓ § H (≥5 sources per claim) |
| I-S2 source + as-of | ✓ (every plan claim cites file:line; observation date 2026-05-16 declared in frontmatter) |
| dispatch-template-via-pre-dispatch-architect-commit-guard.sh | ✓ (S341 D3 landed this hook; main commits architect's plan output per D-060 recovery pattern; this observation file accompanies plan per S339 F5 + S342 sandwich-architect.md template update) |

## Handoff to S347 sandwich-dev

**Plan ready for IMPL**. Recommended dispatch:
- Fresh context (AP-1)
- Opus FOCUSED_IMPL budget 100-150K (per § K)
- Read plan-025 end-to-end first (VBW per Phase 1 of sandwich-dev.md)
- Execute D1 → D2 → D3 → D5 → D4 → D6 (per blocks_on chain in § E sub-track parallel_with declarations)
- D2 and D3 may run parallel post-D1 IF main session decides to dispatch via parallel-dispatch this turn as live dogfood; otherwise sequential is the safe default per cold-start (no past task_class=planner-template-upgrade data)
- STOP-AND-SPLIT on any E5+ temptation per RM8
- STOP-AND-FLAG on DD-7 entanglement contingency
- Observation file mandatory per S339 F5 + sandwich-dev.md Phase 5
- Plan mv pending → completed at end-of-session per BOOK-3

**Verifier S348** brief should reference V-OPEN-1/2/3 above.
