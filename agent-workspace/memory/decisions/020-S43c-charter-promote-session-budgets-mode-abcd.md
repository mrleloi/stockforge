---
id: D-020-S43c-charter-promote-session-budgets-mode-abcd
title: Append Mode A/B/C/D dispatch + Verifier Budget by Scope to constitution/session-budgets.md
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q3=A — Append (Recommended) — Edit charter + ADR D-020 ratifies"
  - path: agent-workspace/proposals/session-budgets-amendment.md
    section: full file (74 LOC) — Mode A/B/C/D + Verifier Budget by Scope
  - path: agent-workspace/memory/decisions/004-up07-context-threshold-opus47.md
    section: Opus 4.7 thresholds 180K/220K/250K
  - path: scripts/hooks/autonomous-stop-watchdog.sh
    section: Mode A/B/C/D detection (shipped S14 per L-S14-4)
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: false
  urgency: NORMAL
  complexity_score: 40
options_considered:
  - id: A
    summary: Append Mode A/B/C/D + Verifier Budget by Scope to session-budgets charter
    pros: ["Canonicalizes already-shipped autonomous-stop-watchdog dispatch logic", "L-S21-1 verifier budget calibration codified", "Cross-references autonomous-protocol Rule 2"]
    cons: ["Charter file grows ~50 LOC"]
  - id: B
    summary: Promote to autonomous-protocol.md instead
    pros: ["Single file for autonomous loop concerns"]
    cons: ["Cross-charter promote = more friction; budget concerns belong in session-budgets per topic"]
  - id: C
    summary: Defer entire proposal
    pros: ["Zero churn"]
    cons: ["Loses charter binding for shipped behavior"]
chosen: A
chosen_rationale: |
  Mode A/B/C/D is fundamentally a budget-threshold dispatch (180K/220K thresholds drive mode selection),
  belonging in session-budgets by topic. Cross-references to autonomous-protocol Rule 2 preserve
  cross-charter coherence. Verifier Budget by Scope (L-S21-1) is also budget-themed.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/session-budgets-amendment.md
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed 'Mode A/B/C/D — Cliff vs Injector Dispatch' appended"
affects:
  charter: true
  spec_files: []
  code_paths: ["scripts/hooks/autonomous-stop-watchdog.sh (already aligned)", "scripts/hooks/budget-watchdog.sh (already aligned)"]
  config_files: []
  other_decisions: ["D-004", "D-015"]
depends_on: ["D-004", "D-015"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "session-budgets", "autonomous-loop"]
---

# Decision 020 — S43c Charter Promote: Mode A/B/C/D + Verifier Budget

## Decision

Append `## Mode A/B/C/D — Cliff vs Injector Dispatch (D-020, ratified 2026-05-04)` to `agent-workspace/constitution/session-budgets.md` after `## Hard Rules`, before `## When to Escalate`. Includes deterministic dispatch table:

```
budget < 180K + checkpoint fresh                     → Mode D (clean)
budget < 180K + no checkpoint                        → Mode A (continue-injector mid-session)
180K ≤ budget < 220K                                  → Mode C (wind-down; handoff prep)
budget ≥ 220K                                        → Mode B (cliff; session-self-reboot fresh ctx)
```

Plus `## Verifier Budget by Scope (L-S21-1)` table calibrating sandwich-verifier dispatch budget per artifact-set scope (60-80K single-track / 100-120K multi-track / 150K whole-Phase).

## Why (Reasons)

1. Charter Principle 8 (Calibration over confidence) — codifies S14 + S21 empirical data
2. Deterministic dispatch (per budget threshold, not agent judgment) preserves AP-2 (self-track wind-down anti-pattern)
3. Cross-references autonomous-protocol Rule 2 — single charter file for related concerns of different topics

## Acceptance Record

- **2026-04-29**: PROPOSED by agent
- **2026-05-04**: ACCEPTED by user via Q&A 2026-05-01-003 Q3=A
