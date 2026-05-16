---
id: D-069-planner-self-calibration-protocol
title: Planner Self-Calibration Protocol — Phase 1b + parallel_with field + feedback-loop hook
date: 2026-05-16
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6"   # sandwich-dev S349 (executing plan-025 from architect S346)

source_evidence:
  - path: agent-workspace/session-plans/pending/025-S346-planner-upgrade.md
    section: "Whole plan — DD-1..DD-12 ratification"
  - path: agent-workspace/memory/observations/2026-05-16-planner-upgrade-proposal.md
    section: "E1-E4 enhancements + Concrete examples + Implementation plan"
  - path: .claude/agents/sandwich-architect.md
    section: "Phase 1b insertion (DD-1 decision)"
  - path: .claude/agents/master-planner.md
    section: "Phase 1b mirror (DD-1)"
  - path: .claude/agents/sandwich-dev.md
    section: "Parallelism Discipline section new (DD-5)"
  - path: scripts/hooks/planner-feedback-loop.sh
    section: "Whole NEW hook (DD-8/DD-9/DD-10)"
  - path: agent-workspace/memory/self-awareness/sessions-rollup.tsv
    section: "8→14 col schema extension (DD-7)"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 45

options_considered:
  - id: A
    summary: "Phase 1b self-calibration + explicit parallel_with field + Stop-cadence feedback hook"
    pros:
      - "Closes the calibration feedback loop (Charter Principle 8)"
      - "Eliminates planner telemetry-blindness (0 tracking-log refs in 692 LOC pre-plan)"
      - "Enables dormant parallel-dispatch capacity"
    cons:
      - "Adds ~30 rows to architect Phase 1 read budget per plan"
      - "First-run cold-start has no data to read (graceful degradation mitigates)"
  - id: B
    summary: "Keep existing sequential-only planner (no change)"
    pros:
      - "Zero implementation risk"
    cons:
      - "User-stated bottleneck unaddressed"
      - "Calibration stays LLM-guess-only (violates Charter Principle 8)"
      - "Dormant parallel-dispatch capacity never activated"

chosen: A
chosen_rationale: |
  User explicitly requested self-calibrating planner capable of reading tracking logs and
  dispatching more parallel agents (2026-05-16T~20:30 SEAST: "the planner make claudecode run
  faster to achieve the goals"). Option A directly addresses this with 4 bounded enhancements
  (E1-E4) ratified via Q-PL1..Q-PL4. Option B preserves status quo which contradicts Charter
  Principle 8 (calibration over confidence). The 3 ratified design Q&A answers (3-parallel max,
  Phase 1b mandatory for ≥3 sub-tracks, append-only schema, Stop-cadence debounce) bound the
  risk surface to a manageable IMPL-tier change.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-16
    via: "S349 sandwich-dev session (plan-025 D6 task)"
  - actor: user
    action: ACCEPTED
    at: 2026-05-16
    via: "Q-PL1..Q-PL4 ratification per main session + 'follow your recommendation' + 'run full autonomous'"

verified_by:
  - mechanism: sandwich-verifier
    at: 2026-05-16
    result: PENDING   # S348/S350 verifier to run fire-tests + DoD audit

affects:
  charter: false
  spec_files: []
  code_paths:
    - .claude/agents/sandwich-architect.md
    - .claude/agents/master-planner.md
    - .claude/agents/sandwich-dev.md
    - .claude/agents/action-guide-planner.md
    - .claude/agents/bdd-planner.md
    - scripts/hooks/planner-feedback-loop.sh
    - scripts/hooks/firing-tests/planner-feedback-loop-fire-test.sh
    - scripts/hooks/self-awareness-aggregate.sh
    - agent-workspace/memory/.planner-stats.tsv
    - agent-workspace/memory/self-awareness/sessions-rollup.tsv
  config_files:
    - .claude/settings.json   # Stop chain wire-up DEFERRED to main session post-plan-024-dev
  other_decisions:
    - D-062   # atomic-write-doctrine (BINDING for .planner-stats.tsv writes)
    - D-064   # path-safety-5-invariant (BINDING for planner-feedback-loop.sh)
    - D-060   # commit-policy

depends_on:
  - D-060
  - D-062
  - D-064

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — PROPOSED; not deferred.

empirical_tuning_window: 30 days post-deployment

revisit_triggers:
  - "10+ plans consumed Phase 1b → re-evaluate cold-start gate threshold (AQ-5)"
  - "10+ successful 3-parallel runs without rate-limit/file-collision → consider Q-PL1 4-parallel raise (DD-5)"
  - "Any M-S<N>-N file-collision incident → tighten DD-4 lint (RM3)"
  - "Any plan formatted without parallel_with field → back-fill OR mark deprecated-plan-format"
  - "ADR D-069 § Empirical-Tuning-Window 30 days reached → re-evaluate DD-2 read budget cap / DD-10 age-decay thresholds"

tags: ["harness", "planner-calibration", "parallel-dispatch", "self-awareness", "phase-0-adjacent"]
---

# Decision 069 — Planner Self-Calibration Protocol

## Context

Prior to plan-025, the 4 planner subagent templates (sandwich-architect.md, master-planner.md,
action-guide-planner.md, bdd-planner.md) contained **zero references** to the 3 rich tracking logs
that exist in `agent-workspace/memory/`: dispatch.jsonl (530 rows), component-telemetry.jsonl
(3666 rows), sessions-rollup.tsv (623 rows). This meant every architect session estimated budget and
parallelism from LLM intuition alone — violating Charter Principle 8 (Calibration over Confidence)
and leaving dormant parallel-dispatch capacity untapped.

The user's 2026-05-16 directive: "the planner make claudecode run faster to achieve the goals" and
"more subagent running in parallel without causing any error" motivated 4 enhancements (E1-E4)
proposed in `observations/2026-05-16-planner-upgrade-proposal.md`, ratified via Q-PL1..Q-PL4.

## Analysis

VBW audit (architect S346) confirmed:
1. Grep `parallel_with|parallel-dispatch|concurrent` on `.claude/agents/` = 0 matches
2. sessions-rollup.tsv 623 rows readable (8-col schema) — not consumed by any planner
3. dispatch.jsonl 530 rows readable — not consumed by any planner
4. Claude Code Agent tool supports parallel-dispatch (demonstrated in main session with 4 parallel agents)
5. Recent multi-track plans (plan-020 4 sub-tracks, plan-021 6 sub-tracks, plan-022 5 sub-tracks) all dispatched 1 sequential dev

Projected improvement: ~25-35% wall-time reduction for 3-5 independent sub-track plans once parallel
dispatch is activated via `parallel_with` field.

## Decision

Planner subagents (sandwich-architect, master-planner) MUST consume tracking-log telemetry in Phase 1b
to ground budget + parallelism decisions in past actuals, not LLM guesses. Plan format gains required
`parallel_with`/`blocks_on`/`coordination_paths_exclusive` fields per sub-track. Stop-cadence hook
`planner-feedback-loop.sh` closes the feedback loop by aggregating per-plan throughput metrics to
`.planner-stats.tsv`.

### What this means concretely

- sandwich-architect.md gains Phase 1b (after Phase 1 Comprehend; before Phase 2 Architecture Decisions)
- Every plan's § D sub-track decomposition MUST include 3 new fields per DD-3
- master-planner.md mirrors Phase 1b for multi-session master-plans
- sandwich-dev.md gains Parallelism Discipline section (max-3 ceiling; self-check before write)
- `planner-feedback-loop.sh` Stop hook (NOT yet wired — main session adds after plan-024 dev returns)
- `.planner-stats.tsv` created (header-only on deployment; populated on first VERIFY-DONE Stop)
- sessions-rollup.tsv schema extended from 8→14 cols (append-only; back-compat; D4 writes new cols)

### What does NOT change

- Existing sessions-rollup.tsv rows (8-col legacy preserved; readers handle via `NF >= 14` check)
- self-awareness-aggregate.sh behavior (schema documentation added to header comment only)
- Charter, constitution, production code (0 edits)
- Phase 1 (Comprehend) remains mandatory; Phase 1b is MANDATORY for ≥3 sub-tracks, SKIPPABLE for 1-2

## Why (Reasons)

1. Charter Principle 8: Calibration over confidence — budget estimates must ground in actual past durations
2. Charter Principle 7: Dogfood mandatory — planner must consume the same telemetry it helps generate
3. Charter Principle 11: Harness must self-verify firing — planner-feedback-loop.sh ships with 12 TC fire-test
4. Karpathy P3 surgical changes — 3 required fields per sub-track; 1 new hook; 0 production code changes
5. AP-7 anti-vacuous-defer — every DEFER in this ADR names prerequisites + revisit trigger

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Rate-limit on parallel devs | Medium | Cap at 3 initially (DD-5); fall back to sequential on rate-limit error |
| Phase 1b context overrun | Low | Cap last 30 rows per log (DD-2); ~90 rows total ≈ ~5K tokens |
| File-collision from over-parallelization | Medium | Lint validates coordination_paths_exclusive disjoint (DD-4) |
| Stale calibration biases planner | Medium | Age-decay: 30d weight=1.0; 30-90d weight=0.5; >90d dropped (DD-10) |
| ADR D-069 churn before data accumulates | Medium | PROPOSED at IMPL tier; Empirical-Tuning-Window: 30 days |
| Cold-start first run | Low | Graceful degradation to 100-150K boilerplate budget; "cold-start" flag in calibration summary |

## Open Questions

None — Q-PL1..Q-PL4 all ratified by user at 2026-05-16T~20:30 SEAST.

## Amendments (append-only)

_None yet — PROPOSED 2026-05-16._

## Acceptance Record

- **2026-05-16**: PROPOSED by Claude Sonnet 4.6 (sandwich-dev S349 executing plan-025)
- **2026-05-16**: User pre-acceptance via Q-PL1..Q-PL4 ratification + "follow your recommendation" + "run full autonomous" (binding_decisions in plan-025 frontmatter)
