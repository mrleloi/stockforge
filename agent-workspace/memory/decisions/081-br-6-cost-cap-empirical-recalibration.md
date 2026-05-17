---
id: D-081-br-6-cost-cap-empirical-recalibration
title: "BR-6 per-thesis cost cap raised $3.00 → $6.00 after empirical evidence from S395"
date: 2026-05-17
status: ACCEPTED
level: IMPL

author:
  - "Claude Sonnet 4.6 (sandwich-dev S395 — discovered blocker)"
  - "Claude Sonnet 4.6 (sandwich-dev S396 — authored ADR + applied fix)"

source_evidence:
  - path: agent-workspace/memory/observations/sandwich-dev-S395-data-corpus-ingestion.md
    quote: "Total cost: $4.24 > $3.00 hard cap → CostBudgetExceeded raised"
  - path: agent-workspace/memory/thesis-log/2026-05-17-VHM.md
    quote: "gaps: ['cost_budget_exceeded']"
  - path: human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md
    section: "Option A (recommended): Raise cap $3 → $6"
  - path: agent-workspace/memory/observations/sandwich-dev-S395-data-corpus-ingestion.md
    section: "STEP 5 — BLOCKED-BY-cost-cap; packages/application/analysis/use_cases/validate_thesis_phase1.py:189"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 15

options_considered:
  - id: A
    summary: "Raise BR-6 cap $3.00 → $6.00 in validate_thesis_phase1.py (single LOC change)"
    pros:
      - "Empirically grounded: $4.24 observed max + 40% headroom at $6.00"
      - "Preserves V0=6 persona architecture (BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB)"
      - "Minimal code change: 1 LOC + inline comment"
    cons:
      - "Increases per-run spend ceiling; 4-ticker full suite = up to $24 worst-case"
      - "BULL/Haiku retry pattern could still occasionally hit $6.00 if retries multiply"
  - id: B
    summary: "Reduce personas V0=6 → V0=3 (BEAR/BULL/QUANT only) to bring cost under $3.00"
    pros:
      - "Keeps BR-6 original $3.00 cap intact"
      - "Cheaper per-run"
    cons:
      - "Loses 3 analytical personas (BUFFETT/GRAHAM/TALEB) — degrades thesis adversarial quality"
      - "Contradicts D-075 (3-persona phase-1 milestone) which already approved 6-persona expansion"
  - id: C
    summary: "Accept PARTIAL status; defer full-thesis validation to Phase F.5-V2 with separate budget review"
    pros:
      - "No code change required now"
    cons:
      - "PFP-DONE-7 (thesis persisted) deferred indefinitely; corpus work partially wasted"
      - "Wave 1 MVP blocked on thesis-end goal"

chosen: A
chosen_rationale: |
  User explicitly selected Q1=A (raise cap $3 → $6; dev-recommended) at S395 AskUserQuestion close.
  The empirical evidence from S395 VHM dry-run shows $4.24 actual cost for a V0=6 6-persona run with
  1 BULL/Haiku retry. $6.00 provides 42% headroom above observed max. The V0=6 architecture is the
  product of deliberate design decisions (D-074, D-075, D-076) and reducing persona count would
  degrade adversarial thesis quality (Charter Principle 7). A $6.00 cap per ticker × 4 tickers = $24
  worst-case, which the user accepted explicitly (Q1=A plus explicit full-4 $17 spend acceptance).

  Note: `use_case_builder.py:109` `--max-cost-usd` is silently ignored (design intent per BR-6);
  that is a separate cleanup opportunity NOT addressed in this scope. A future IMPL session may wire
  the CLI flag through to the use-case to make it configurable at invocation time.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-17
    via: "STOP-FINDING-S395-validate-thesis-cost-blocker.md; S395 AskUserQuestion Q1"
  - actor: user
    action: ACCEPTED
    at: 2026-05-17
    via: "AskUserQuestion Q1=A (raise BR-6 cap $3 → $6, dev-recommended); S395 close chat"

verified_by:
  - mechanism: sandwich-dev S396 implementation
    at: 2026-05-17
    result: PASS

affects:
  charter: false
  spec_files: []
  code_paths:
    - packages/application/analysis/use_cases/validate_thesis_phase1.py
  config_files: []
  other_decisions:
    - D-074
    - D-075
    - D-076
    - D-078

depends_on:
  - D-074
  - D-075
  - D-076

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A — decision ACCEPTED and implemented."

promotion_candidate: |
  L-S396-1: "Architectural-cap-empirical-recalibration discipline."
  BR-6 was set at $3.00 without empirical evidence (Charter Principle 8: Calibration over confidence).
  After V0=6 persona expansion (D-074 through D-076), the cap was not re-evaluated against observed costs.
  Rule: any hard cost/resource cap must be re-validated after persona-count or model-tier changes.
  Status: HELD-FOR-PROMOTION (1st instance; AP-23 — 2nd recurrence mandates promote-or-retire).

tags: ["phase-f-prime", "cost-cap", "br-6", "empirical-recalibration", "v0-6-personas"]
---

# Decision 081 — BR-6 Cost Cap Empirical Recalibration ($3 → $6)

## Context

BR-6 established a per-thesis Anthropic API spend hard cap to prevent runaway costs during
automated thesis validation runs. The original cap was $3.00/thesis, set during Phase F.5 design
before the V0=6 6-persona architecture was finalized.

During S395 data corpus ingestion, the first live VHM thesis run using V0=6 (BEAR/BULL/QUANT/
BUFFETT/GRAHAM/TALEB) via subagent transport cost $4.24 — exceeding the $3.00 cap. The run
used a mix of Opus (QUANT/BUFFETT/GRAHAM/TALEB) and Haiku (BULL, which retried 2×
due to Haiku reading CLAUDE.md context as an orchestration task instead of a structured
JSON persona response). Total: 6 personas × Opus/Haiku rates + 2 BULL retries = $4.24.

The CostBudgetExceeded exception was raised, the thesis was marked incomplete, and
PFP-DONE-7 (thesis persisted to SQLite) was not met. This is a direct Charter Principle 8 violation
(cap set without calibration data).

Source evidence:
- `agent-workspace/memory/observations/sandwich-dev-S395-data-corpus-ingestion.md` (STEP 5 section)
- `agent-workspace/memory/thesis-log/2026-05-17-VHM.md:13` — `gaps: ['cost_budget_exceeded']`
- `human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md`

## Analysis

Per-run cost breakdown (S395 empirical evidence):
- 4 Opus personas (QUANT/BUFFETT/GRAHAM/TALEB): dominant cost ~$1/each
- 1 Haiku persona (BULL) with 2 retries: ~$0.24 total
- 1 Opus persona (BEAR): ~$1
- Overhead (data-gather, synthesis): small
- Total: ~$4.24

$6.00 cap provides 42% headroom above the observed $4.24 maximum. This accommodates up to
~2-3 BULL retries without exceeding cap. For a worst-case 4-ticker suite: 4 × $6.00 = $24.00
worst-case; user explicitly accepted full-4 $17 realistic spend at S395 Q1=A close.

The `--max-cost-usd` CLI flag in `apps/cli/validate_thesis.py` is currently silently ignored
at `apps/_shared/use_case_builder.py:109` by design (BR-6 forces the hard cap in the use-case
layer, not the CLI layer). This is a separate cleanup opportunity; not in scope for D-081.

## Decision

Raise `limit_usd` in `packages/application/analysis/use_cases/validate_thesis_phase1.py:189`
from `Decimal("3.00")` to `Decimal("6.00")`.

### What this means concretely

- Per-thesis hard cap is now $6.00 (was $3.00)
- V0=6 persona architecture (BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB) is preserved
- `CostBudgetExceeded` will still fire if a single run exceeds $6.00 (pathological retry storms)
- The $24.00 worst-case 4-ticker ceiling is user-accepted
- `--max-cost-usd` CLI flag remains silently ignored (separate cleanup scope)

## Why

1. Charter Principle 8 (Calibration over confidence): cap must be grounded in empirical data.
   The original $3.00 was set before V0=6 was finalized; it was speculation, not measurement.
2. Charter Principle 7 (Adversarial by default): preserving all 6 personas maintains the
   bull/bear/quant/value/risk multi-perspective adversarial design. Reducing persona count
   would degrade thesis quality.
3. User explicitly authorized Q1=A (raise to $6.00) at S395 close. Direct human ratification.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| BULL/Haiku retry storm exceeds $6.00 | Low | $6.00 cap still fires; thesis marked incomplete; investigate retry root cause separately |
| 4-ticker full suite costs >$17 actual | Low | Empirical estimate $4.24/ticker × 4 = ~$17; HARD STOP at $17 cumulative in S396 IMPL |
| Future persona expansion again outdates cap | Med | L-S396-1 prevention rule: re-validate cap on every persona/model-tier change |

## Promotion Candidate

**L-S396-1** (HELD-FOR-PROMOTION per AP-23 1st-instance rule):
"Any hard cost/resource cap must be empirically re-validated after persona-count or model-tier changes."
On 2nd recurrence of cap-set-without-evidence: mandatory promote-or-retire (not inline accumulation).

## Acceptance Record

- **2026-05-17**: PROPOSED by sandwich-dev S395 (cost-blocker discovery) via STOP-FINDING
- **2026-05-17**: ACCEPTED by user via AskUserQuestion Q1=A at S395 close
- **2026-05-17**: IMPLEMENTED by sandwich-dev S396 (this session; 1 LOC change + inline comment)
