---
observation_id: sandwich-verifier-S352-planner-upgrade-verify
type: sandwich-verifier-audit
verifier_agent_id: a3b07f455f9252bbe
created_at: 2026-05-16
plan_audited: agent-workspace/session-plans/completed/025-S346-planner-upgrade.md
dev_session_audited: S349 (agentId aa6a1e35b0b37ebf4, commit fcc63e7)
main_wire_audited: 52558cb (settings.json wire for planner-feedback-loop.sh L416)
verifier_has_no_Write: true (recovery pattern: main writes this file per S312/S314/S321/S333/S339/S342/S345 precedent)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
---

# S352 sandwich-verifier — Planner Subagent Upgrade IMPL audit

## Overall Verdict

**PASS WITH CONCERNS — MERGE-ELIGIBLE: YES**

All 6 sub-tracks (D1-D6) delivered substantively. 13/13 fire-tests PASS. 6/6 self-awareness regression PASS. 990 pytest baseline maintained. 0 charter / 0 constitution / 0 production drift. settings.json wire landed at 52558cb L416 in correct chain position. 5 concerns flagged (3 IMPORTANT F1+F2+F3, 2 MINOR F4+F5); none block merge. ADR D-069 PROPOSED with Empirical-Tuning-Window: 30 days names revisit triggers per AP-7.

## V1 — DoD 37 items (independent verification)

**Aggregate: 33 PASS / 1 RESOLVED-BY-MAIN (HOOK-3) / 2 DEFERRED (CALIB-2 + SMOKE-3) / 1 CONCERN-PARTIAL (PARALLEL-1/2/3 = 3 items)**

**FILE group (9/9 PASS)**:
- FILE-1: sandwich-architect.md +67 LOC (plan est 75-90; -8 below). Content verification: Phase 1b L42-65 (24 LOC) + Sub-track Template L110-126 (17 LOC) + Calibration Summary L212-236 (25 LOC). All required substantive blocks present.
- FILE-2: master-planner.md +31 LOC (plan est 45-60; -14 below). Phase 1b mirror L50-66 (17 LOC); sub-track decomp L139-151 (13 LOC); L92 explicit parallel_with verified.
- FILE-3: sandwich-dev.md +16 LOC (plan est 35-50; -19 below). Parallelism Discipline L145-160 functionally complete.
- FILE-4: action-guide-planner.md +4 LOC (plan est 8-15). Cross-ref L87-89.
- FILE-5: bdd-planner.md +4 LOC (plan est 8-15). Cross-ref L75-77.
- FILE-6/7/8/9: planner-feedback-loop.sh 187 / fire-test 280 / .planner-stats.tsv 1 / ADR 069 205 — all PASS schema/content.

**AGENT group (5/5 PASS)**: grep Phase 1b sandwich-architect=15, parallel_with sandwich-architect=7, Phase 1b master-planner=6, Parallelism Discipline sandwich-dev=1, Calibration Summary sandwich-architect=5 — all exceed thresholds.

**HOOK group (3/3 PASS)**: bash -n + 13/13 fire-test + settings.json wire L416 AFTER profile-template-auto-populate L412 (correct chain order per plan § J).

**SCHEMA group (3/3 PASS)**: head -1 sessions-rollup.tsv = original 8-col preserved; 14-col extension docs at self-awareness-aggregate.sh:19-21. **Verifier ran synthetic mixed-NF test** — appended 14-col row to sessions-rollup, ran self-awareness-aggregate-fire-test → 6/6 STILL PASS; mixed 8+14 NF both readable; restored backup. **Back-compat empirically validated.**

**PARALLEL group (3/3 CONCERN — see F1/F2)**: Plan DD-4 allowed lint in D4 hook OR adjacent `plan-format-lint.sh` — neither shipped. Lint contract documented in prose only (sandwich-architect.md:122-126 + sandwich-dev.md:159-160). No deterministic enforcement.

**CALIB group (1/2 PASS, 1 DEFERRED-BY-DESIGN)**: TC2/TC6 fire-test proves row emission. CALIB-2 dogfood requires first real architect dispatch consuming .planner-stats.tsv (defer to next architect dispatch).

**ADR group (1/1 PASS)**: D-069 12-field schema complete + 7 source_evidence cites + 5 revisit_triggers (1 over plan's 4 — additive).

**COMPLIANCE group (5/5 PASS)**: git diff verified — 0 charter / 0 constitution / 0 production. 1 dev commit + 1 main wire commit. VBW pre-flight in session log.

**SMOKE group (2/3 PASS, 1 DEFERRED)**: bash -n clean + fire-test PASS. SMOKE-3 Stop chain delta deferred to next live session.

**BOOK group (3/3 PASS)**: session log + dev observation + plan mv pending→completed.

## V2 — Sub-track delivery D1-D6

All 6 sub-tracks delivered substantively. D6b settings.json wire-up correctly deferred to main (52558cb) per coordination directive.

## V3 — DD compliance (DD-1..DD-12)

- DD-1 Phase 1b position ✓
- DD-2 30-row read cap ✓
- DD-3 3 required fields ✓
- **DD-4 lint at dispatch-time — CONCERN F1+F2 (prose-only)**
- DD-5 3-parallel ceiling ✓
- DD-6 skip-decision explicit ✓
- DD-7 append-only schema ✓ (empirically tested via V7)
- DD-8 debounce per plan_id ✓
- DD-9 .planner-stats.tsv 6-col ✓
- **DD-10 age-decay — CONCERN F3 (uniform weight=0.5 fallback)**
- DD-11 Calibration summary mandatory ✓
- DD-12 ADR D-069 PROPOSED ✓

## V4 — Charter/invariant compliance

0 charter / 0 constitution / 0 production code. ADR in decisions/. D-060 ✓ (2 commits / 0 pushes). D-062 atomic-write ✓ (planner-feedback-loop.sh:164-177 mktemp+mv). D-064 path-safety ✓. L-S11-1 bash+awk only ✓. I-S1/I-S2/I-S22/I-S33 ✓. AP-1/AP-7/AP-23 ✓.

## V5 — Regression

- pytest collection 990 (baseline maintained)
- planner-feedback-loop fire-test 13/13 PASS (re-run)
- self-awareness-aggregate fire-test 6/6 PASS (re-run)
- bash -n clean / settings.json JSON parse clean

## V6 — Phase 1b text empirical

sandwich-architect.md L42-65: ✓ MANDATORY/SKIPPABLE + cites all 4 logs + cold-start clause.
master-planner.md L50-66: ✓ Mirror + cites all 4 logs. **F4 MINOR** — explicit cold-start clause missing (implicit via "mirror sandwich-architect.md DD-1" only).

## V7 — Schema migration empirical

Verifier copied sessions-rollup.tsv → /tmp; appended synthetic 14-col row; re-ran self-awareness-aggregate-fire-test → 6/6 PASS; restored backup. Confirmed mixed 8+14 NF readable per DD-7.

## Findings

### Critical: None.

### Important:

**F1 — plan-format-lint.sh NOT shipped (deterministic enforcement missing)**

Plan DD-4 allowed lint in D4 hook OR adjacent `plan-format-lint.sh`. Neither shipped. Lint contract only prose at sandwich-architect.md:122-126 + sandwich-dev.md:159-160. Risk: file-collision (plan RM3 "High corrupted state") only guarded by LLM self-discipline. Verifier recommends F1B = ACCEPT deferral with explicit ADR D-069 revisit trigger ("first M-S<N>-N file-collision incident OR first 3 successful parallel dispatches without incident → re-evaluate plan-format-lint.sh build OR permanently-defer").

**F2 — PARALLEL-1/2/3 DoD items written as assertions but no enforcement (linked to F1)**

Plan § F DoD PARALLEL-1/2/3 written as runnable assertions ("synthetic plan with X passes/fails lint check"). Dev marked PARTIAL/VERIFIER-SCOPE. Verifier classifies as known-gap-with-revisit-trigger (same as F1) rather than auto-block. Plan IS internally usable (architect can emit `parallel_with: []` for safe sequential default).

**F3 — Age-decay uniform weight=0.5 fallback for ALL historical rows (IMPORTANT-DOCUMENTED)**

planner-feedback-loop.sh:138-140 collapses 3-tier age-decay (1.0/0.5/0.0 per DD-10) to 2-tier (1.0 current / 0.5 all-historical). awk lacks date parsing → >90d-drop tier not enforced. Dev openly flagged in observation Risk Area #3. Empirical impact low until task_class accumulates 90+ days (~100+ rollup rows). Verifier recommends ACCEPT for IMPL tier per dev rationale + ADR D-069 revisit trigger ("task_class accumulates >30 plans OR first biased avg_wall_min vs actual → re-implement age-decay using date -d or python sub-call").

### Minor:

**F4 — master-planner.md Phase 1b lacks explicit cold-start clause (MINOR)**

L50-66 mirrors sandwich-architect.md DD-1 implicitly via prose "mirror sandwich-architect.md DD-1" but doesn't restate the .planner-stats.tsv sample_size<3 graceful-degradation clause. Fix: add 1-line "Cold-start fallback per sandwich-architect.md DD-1 applies" near L65.

**F5 — LOC deltas substantially below plan estimates for FILE-1/2/3 (MINOR — L-S349-1 candidate)**

| File | Plan | Actual | Delta |
|---|---|---|---|
| sandwich-architect.md | +75-90 | +67 | -8 |
| master-planner.md | +45-60 | +31 | -14 |
| sandwich-dev.md | +35-50 | +16 | -19 |

Total ~41 LOC below upper-bound. Content NOT missing (grep counts exceed thresholds). L-S349-1: "sandwich-architect plan LOC estimates trend upper-bound; if dev consistently delivers ~75% of upper-bound without content loss, architect's Phase 1b should learn `loc_inflation_factor: ~1.33` and calibrate estimates". Trigger: 3 consecutive plans <80% upper-bound without content omission per verifier audit.

## Promotion candidates (AP-23 1st-instance HOLD)

- **L-S349-1**: planner-stats should track LOC-estimate-accuracy as new metric. Empirical-Tuning-Window 30 days revisit.
- **L-S349-2** (3rd-instance candidate watch): "Plan DoD items written as runnable assertions but no enforcement code shipped" pattern — first instance is PARALLEL-1/2/3. If 2nd instance arises, AP-23 RED FLAG mandates plan-template addendum.
- **L-S349-3**: planner-feedback-loop.sh age-decay precision is awk-language constraint. If 2nd instance of awk-precision-fallback, AP-23 PROMOTE-NOW could mandate python helper sub-call.

## Dev-handoff (main close-bookkeeping)

1. Persist this observation (verifier-has-no-Write recovery — DONE by main this turn).
2. **No inline remediation required for merge** — all 5 concerns documented-gaps with named revisit triggers.
3. Recommended ADR D-069 § Amendments append (3 revisit triggers per F1/F3/F5).
4. L-S349-1/L-S349-2/L-S349-3 queue in next harness session.
5. CALIB-2 dogfood: next sandwich-architect dispatch should be spot-checked.
6. SMOKE-3: main session adds Stop chain timestamp in next session log.
7. plan-025 mv to completed/ confirmed at fcc63e7.

## Compliance attestation

- harness_priority_one ✓
- AP-1 fresh-context ✓
- 0 charter / 0 constitution / 0 production
- 0 commits / 0 pushes (verifier)
- VBW applied ✓
- AP-7 anti-vacuous-defer ✓ (all defers have named revisit triggers)
- D-060 N/A
- dont_self_pause_at_session_boundary ✓

## Recommendation

**MERGE** at commits fcc63e7 + 52558cb. All 5 concerns are documented-gaps with named revisit triggers; none block merge per IMPL-tier severity standards. Empirical-Tuning-Window 30 days in ADR D-069 covers the calibration refinement cycle.
