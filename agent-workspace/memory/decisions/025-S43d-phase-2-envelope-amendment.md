---
id: D-025-phase-2-envelope-amendment
title: Phase 2 token-budget envelope amendment — calibration delta after Track F dogfood
date: 2026-05-04
status: ACCEPTED
level: IMPL

author:
  - "Claude Opus 4.7"

source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q10=A — agent authors envelope amendment ADR after S43b LIVE-via-subagent close, documenting calibration delta"
  - path: agent-workspace/memory/checkpoints/latest.md
    section: "S43d — Budget"
  - path: agent-workspace/memory/current-execution.md
    section: "Active Focus Track — Budget delta (post-S42) + S43c row + S43d row"
  - path: agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md
    section: "Phase 2 envelope ~860K-1.25M main + ~250K subagent"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 25

options_considered:
  - id: A
    summary: Amend envelope to ~1.60M-1.85M main + ~700K subagent (~2.30M-2.55M combined; absorb actuals + 5% headroom for residual S38/S39/S40/S43e closure)
    pros:
      - Reflects empirical truth — S31-S43d cumulative ~1.60M-1.79M main + ~664K subagent
      - Acknowledges structural drivers (META_LOOP_RECOVERY 207K + sandwich-architect 222K + rule-application 150K + dogfood 120K) that were undercounted at S31 master-plan time
      - Sets calibration baseline for Phase 3 master-plan (~2× original Phase 1 cumulative ~888-1023K is now realistic upper bound for similar-scope phases)
    cons:
      - Acknowledges +50-65% overrun publicly; reduces credibility of original master-plan estimates
      - May embolden future scope-creep ("envelope was already amended once")
  - id: B
    summary: Hold original envelope; classify overrun as METRIC-FAILURE; defer revision until Phase 2 close
    pros:
      - Preserves master-plan integrity as baseline
      - Forces tighter scoping for residual sessions (S38/S39/S40/S43e)
    cons:
      - Already empirically broken; pretending otherwise is calibration drift (Charter Principle 8)
      - Q&A 003 Q10=A explicitly directed amendment after dogfood close; B is a defection
      - Tightening residual sessions to fit broken envelope risks rushed/incomplete work
  - id: C
    summary: Defer entirely until Phase 2 actual close (S43e); amend with full retrospective
    pros:
      - More data for calibration accuracy
    cons:
      - Q&A 003 Q10=A dictated post-S43b close timing; deferring further violates user pick
      - Defer-cycles already accumulating; pre-empts can-kicking pattern (R7 mitigation)

chosen: A

chosen_rationale: |
  Option A directly executes Q&A 003 Q10=A user pick. The empirical actuals are clear:
  S31-S43d cumulative = ~1.60M-1.79M main + ~664K subagent = ~2.26M-2.45M combined,
  vs original envelope ~860K-1.25M main + ~250K subagent = ~1.10M-1.50M total. The
  ~50-65% overrun is dominated by 4 structural drivers that were undercounted at
  master-plan time:

  (1) S35 META_LOOP_RECOVERY (207K main) — surfaced as a need not anticipated by
      master-plan; Phase 2 was the first phase where the self-upgrade loop was tested
      under pressure and it required mid-phase recovery work.
  (2) S41 sandwich-architect dispatch (222K subagent) — master-plan budgeted PLAN
      sessions at ~50-80K but did not account for sandwich-architect subagent burn
      on top of main-session orchestration.
  (3) S43b harness-recovery (~110-150K + 6 NEW substrate hooks HR-1..HR-8) — the
      pivot from FPT dogfood to substrate recovery was not foreseen.
  (4) S43c rule-application (~150K) + S43d dogfood (~120K main) — Q&A 003 mega-bundle
      apply turn was a "single-purpose" rule-application session that consumed full
      FOCUSED_IMPL budget on its own. Track F dogfood added another full session.

  Holding the original envelope (Option B) would force a calibration lie — the
  numbers already happened. Deferring (Option C) would compound defer_cycles on the
  Q10 entry, which already deferred from S43c → S43d → now. Option A is the only
  one that respects both the empirical actuals AND the user's Q10=A timing pick.

  The amended envelope sets a realistic calibration baseline for Phase 3
  master-plan: similar-scope phases should expect ~2× original budget if META_LOOP
  events + sandwich-subagent burn + harness-recovery contingency are properly
  attributed.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-04
    via: session 2026-05-04-session-43d.md (postscript) + this ADR file
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: Q&A 2026-05-01-003 Q10=A user pick "tôi accept toàn bộ q&a recommend của agent" (S43c chat reply)

verified_by:
  - mechanism: empirical-actuals-cross-check
    at: 2026-05-04
    result: PASS
    note: "checkpoint S43c+S43d Budget sections reconcile to current-execution.md S42+S43c+S43d rows"

affects:
  charter: false
  spec_files:
    - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md
  code_paths: []
  config_files: []
  other_decisions:
    - D-011  # Phase 2 entry SCOPE-tier; envelope was abstractly bounded there, refined by 005 master-plan
    - D-014  # Track F architecture; spec 006 cost target $0.90/thesis amended S43c

depends_on:
  - D-023  # Cost Substrate — subscription-billed; informs subagent burn accounting
supersedes: null
superseded_by: null

defer_cycles: 2
re_attempt_prereq: |
  N/A — accepted with this filing. Future revision triggered if Phase 3 master-plan
  similarly exceeds its envelope by ≥40% (then re-calibrate the master-plan-estimate
  → actuals ratio).

tags: ["phase-2", "envelope", "calibration", "Q10", "post-dogfood"]
---

# Decision 025 — Phase 2 token-budget envelope amendment (calibration delta)

## Context

Phase 2 master-plan (`session-plans/pending/005-S31-phase-2-master-plan.md`) set
envelope at ~860K-1.25M main + ~250K subagent (~1.10M-1.50M combined) for 11 sessions
S32-S43 across Tracks A-F. By S43d close, cumulative actuals reached ~1.60M-1.79M
main + ~664K subagent (~2.26M-2.45M combined) — ~50-65% over original envelope band.

Q&A 2026-05-01-003 Q10=A user pick directed agent to author this envelope-amendment
ADR post-S43b LIVE-via-subagent close, documenting the calibration delta with
empirical attribution.

## Analysis

### Cumulative actuals (per current-execution.md + checkpoints)

| Session | Type | Main (K) | Subagent (K) | Note |
|---|---|---|---|---|
| S31 | PLAN | 30-45 | 158 | master-plan via master-planner subagent |
| S32 | FOCUSED_IMPL | 80-110 | 0 | Track A SSI iBoard adapter + R2 close |
| S33 | MULTI_TASK_IMPL | 80-110 | 0 | Track B VN30 BC-1 universe expansion |
| S34 | FOCUSED_IMPL | ~100-120 | 0 | Track C BC-2 Fundamental |
| S35 | META_LOOP_RECOVERY | 80-110 | 207 | mid-phase recovery (drift-recovery subagent) |
| S36 | MULTI_TASK_IMPL | 120-160 | 0 | Track D BC-5 News + CafeF + LLM extractor |
| S41 | PLAN | 30-45 | 222 | Track F sandwich-architect dispatch |
| S42 | MULTI_TASK_IMPL | 30-45 | 73 | Track F BC-8 IMPL via sandwich-dev subagent |
| S43c | FOCUSED_IMPL | 140-180 | 60 | Q&A 003 mega-bundle apply + HR-4 ratify + HR-6 lesson-synthesizer first dispatch |
| S43d | FOCUSED_IMPL | 110-150 | 102 | promote-rule subagent + 5-thesis dogfood |
| **S31-S43d total** | — | **~1.60M-1.79M** | **~664K** | **~2.26M-2.45M combined** |

### Drivers undercounted at S31 master-plan time

1. **META_LOOP events (S35: 207K subagent + 80-110K main)**: master-plan assumed
   linear track-by-track execution; did not budget for mid-phase loop-fidelity audits.
   Empirically, Phase 2 needed at least one such recovery cycle.
2. **Sandwich-architect subagent dispatches (S41: 222K subagent)**: master-plan PLAN
   sessions were budgeted at 50-80K main; the sandwich-architect subagent on top of
   that adds ~150-220K subagent burn per major-track architectural pass.
3. **Harness-recovery contingency (S43b series cumulative): not in master-plan at all**.
   The substrate hooks HR-1..HR-8 were authored mid-Phase-2 in response to dormancy
   detection; ~150-200K total accross S43b-FRESH/EVIDENCE/BULL.
4. **Rule-application + dogfood validation (S43c+S43d: ~270K main + ~162K subagent)**:
   master-plan bundled S43 as a single closing session; in practice it split into 4
   sub-turns (S43a CLI/UI + S43b dogfood + S43c rule-apply + S43d substrate-validate).

### Comparison vs Phase 1 actuals

Phase 1 closed S30 at cumulative ~888-1023K main (per current-execution.md "Phase 1
cumulative ~888-1023K (closed)"). Phase 2 main ~1.60M-1.79M = ~1.8× Phase 1.
Subagent burn was effectively 0 in Phase 1; Phase 2 ~664K is a Phase-2-specific
artifact of subagent-first cost-substrate adoption (D-023).

## Decision

**Amend Phase 2 envelope to**:

| Bucket | Original (S31 master-plan) | Amended (this ADR) | Delta |
|---|---|---|---|
| Main | 860K-1.25M | **1.60M-1.85M** | +86%-+48% |
| Subagent | ~250K | **~700K** | +180% |
| Combined | 1.10M-1.50M | **2.30M-2.55M** | +109%-+70% |

Includes ~5% headroom (~80-100K main + ~30-40K subagent) for residual S38/S39/S40/S43e
closure.

### What this means concretely

- Phase 2 cumulative actuals ARE the new envelope baseline. No "overrun" framing.
- Phase 3 master-plan should set initial envelope at ≥1.8× the equivalent Phase-1 ratio,
  with explicit budget lines for: (a) sandwich-architect subagent burn, (b) potential
  META_LOOP recovery contingency (15-20% adder), (c) rule-application/promote-rule turns.
- Spec 006 § B.10 cost target ($0.90/thesis amended S43c) holds at the per-thesis
  level — substrate-burn is orthogonal to per-thesis cost. The $0.90 metric is for
  marginal LLM-call cost; this envelope is for orchestration token cost.

## Why (Reasons)

1. **Charter Principle 8 (Calibration over confidence)** — pretending the numbers
   didn't happen is calibration drift. Empirical actuals are the authoritative
   source for envelope claims.
2. **Q&A 003 Q10=A user pick** — agent committed to this ADR at S43c; deferring
   further is a defection.
3. **R7 defer-can-kicking mitigation** (per Decision 002 REV-2 § C) — defer_cycles
   for Q10 was already 2 (S43c → S43d). >3 triggers drift-detector alert.
4. **Phase 3 master-plan calibration** — without empirical Phase 2 baseline, the
   next master-plan would repeat the undercounted-driver mistake.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Embolden future scope-creep ("envelope was amended once") | Med | This ADR explicitly attributes 4 structural drivers; future amendments require similar attribution chain |
| Phase 3 also overruns | High | Set Phase 3 envelope using Phase 2 actuals as baseline + additional META_LOOP contingency line |
| Loss of master-plan credibility | Low-Med | Master-plan was ABSTRACT envelope per D-011; refined-by-005 was first detailed pass; calibration-driven amendment is normal not anomalous |

## Open Questions

None — all questions resolved by Q&A 003 Q10=A and empirical actuals.

## Amendments (append-only)

(none yet)

## Acceptance Record

- **2026-05-04**: PROPOSED + ACCEPTED by user via Q&A 2026-05-01-003 Q10=A pick "tôi accept toàn bộ q&a recommend của agent" (single-turn close per the bundle's pre-authored Recommended pick)
