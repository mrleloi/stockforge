---
id: D-016-S38-charter-promote-decision-discipline
title: Promote decision-discipline.md to constitution + Rule 2 sub-clause (L-S26-1) + Rule 4a phase-boundary trigger
date: 2026-05-01
status: ACCEPTED
level: CHARTER

author:
  - "Claude Opus 4.7"
  - "user (explicit pick Q&A 2026-05-01-001 Q2=A)"

source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md
    quote: "Q2=A — Promote with Rule 2 + Rule 4a augmentation"
  - path: agent-workspace/memory/decisions/013-S35-meta-loop-recovery-promote-routing.md
    section: PARTIAL-ACCEPTED — charter subset PENDING (now resolved by D-015/D-016/D-017)
  - path: agent-workspace/proposals/decision-discipline.md (predecessor; moved at S38)
  - path: agent-workspace/memory/agent-notes.md
    section: L-S11-2 (IMPL-tier-resolution-doctrine) + L-S26-1 (master-plan internal contradiction)
  - path: agent-workspace/memory/observations/promote-rule-S35.md
    section: META-skip 15 sessions S20-S34 → Rule 4a fix

intent_classification:
  primary_intent: DECISION
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 75

options_considered:
  - id: A
    summary: Promote with Rule 2 sub-clause (L-S26-1) + Rule 4a phase-boundary trigger augmentation (+~18 LOC)
    pros: ["META-skip pattern formally prevented", "L-S26-1 doctrine codified before next master-plan contradiction"]
    cons: ["Slightly larger charter file (~129 LOC, was 111)"]
  - id: B
    summary: Promote as-is without Rule 4a augmentation; defer Rule 4a to Phase 3
    pros: ["Minimum-change move"]
    cons: ["META-skip can recur before Phase 3"]
  - id: C
    summary: Defer entire proposal
    pros: ["Wait for more evidence"]
    cons: ["Rule 1/2/3/4/5 already cited 5+ times; charter-tier rules with no charter binding = drift risk"]

chosen: A
chosen_rationale: |
  Per Q&A 2026-05-01-001 Q2=A explicit user pick. Rule 4a (every 5 sessions OR phase-boundary trigger) directly prevents the S20-S34 META-skip pattern documented in promote-rule-S35.md. Rule 2 sub-clause for L-S26-1 codifies "prefer deliverable explicit text over abstract count" before the next master-plan internal contradiction surfaces.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/decision-discipline.md (S16 IMPL — Track 7 ratification draft)
  - actor: user
    action: ACCEPTED
    at: 2026-05-01
    via: chat reply "Q2=A" to Q&A 2026-05-01-001 (S38 entry — file-bundle pick)

verified_by:
  - mechanism: smoke-test
    at: 2026-05-01
    result: PASS
    note: "decision-discipline.md re-read post-edit; Rule 2 sub-clause + Rule 4a render coherently within existing rule structure"

affects:
  charter: true
  spec_files: []
  code_paths: []
  config_files:
    - .claude/settings.json (deny constitution Edit/Write — preserved post-S38)
  other_decisions:
    - D-013 (PARTIAL-ACCEPTED → ACCEPTED for decision-discipline subset)
    - D-006 (cites L-S11-2/L-S17-1 — now charter-binding)

depends_on:
  - D-013 (S35 promote-rule routing — PARTIAL-ACCEPTED)

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — ACCEPTED.

tags: ["S38", "charter-promote", "Bundle-1", "Q&A-2026-05-01-001-Q2", "decision-discipline", "Rule-4a-phase-boundary", "L-S26-1"]
---

# D-016 — Promote decision-discipline.md to constitution + Rule 2/4a augmentation

## Context

`agent-workspace/proposals/decision-discipline.md` (111 LOC pre-augmentation) was authored at S16 IMPL (Track 7 ratification draft). 5 rules: tier-vs-default-acceptance, IMPL-tier doctrine + storage-substrate sub-clause, hook-skill-charter promotion priority, phase-boundary frequency, provenance-required.

S35 META_LOOP_RECOVERY surfaced 2 augmentation needs:
- **Rule 2 sub-clause for L-S26-1**: master-plan internal contradiction → prefer deliverable explicit text over abstract count; document IMPL-S{N}-* deviation
- **Rule 4a phase-boundary trigger**: promote-cycle MUST run every 5 sessions OR phase boundary; without this, META-skip pattern recurs (empirical S20-S34 = 15 sessions without promotion run)

## Analysis

Per `decision-discipline.md` Rule 3 (Promotion Target Priority), charter promotion is heaviest lift. Rule 4a was implemented as hook (`scripts/hooks/promotion-cycle-trigger.sh` shipped at S35 D4) but the doctrine itself was unwritten in any charter file — without Rule 4a charter binding, the hook is advisory not mandatory.

The S20-S34 META-skip is documented in `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` and `agent-workspace/memory/observations/promote-rule-S35.md`. Direct cause: Rule 4 was interpreted as "phase boundary only" instead of "phase boundary OR every 5 sessions"; agent-notes accumulated 15+ entries before promotion ran.

## Decision

Move `agent-workspace/proposals/decision-discipline.md` → `agent-workspace/constitution/decision-discipline.md`. Augment with:
1. **Rule 2 sub-clause** (after existing storage-substrate sub-clause): master-plan internal contradiction resolution per L-S26-1 (~9 LOC)
2. **Rule 4a** (after Rule 4): phase-boundary trigger enforcement; every 5 sessions OR phase boundary (~9 LOC)

Update frontmatter status PROPOSAL → CHARTER. Charter-tier binding effective S38+.

### What this means concretely

- All 5 original rules + 2 augmentations become CHARTER-tier binding
- `scripts/hooks/promotion-cycle-trigger.sh` upgraded from advisory to mandatory acknowledgment hook
- Future master-plan contradictions resolved per Rule 2 sub-clause (deliverable wins; document IMPL-S{N}-*)

## Why (Reasons)

1. **Prevents META-skip recurrence** — Rule 4a charter binding forces acknowledgment of promotion-cycle-trigger soft-warning
2. **Codifies L-S26-1 before next contradiction** — master-plan 005 (Phase 2) is currently in flight; Rule 2 sub-clause armed for any S39+ contradiction
3. **Resolves S35 D-013 PARTIAL** — decision-discipline subset ratified

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Rule 4a soft-warning fatigue (every 5 sessions) | Medium | Hook emits to stderr only; agent acknowledges via current-execution.md note (no AskUserQuestion friction) |
| Rule 2 sub-clause misapplied to non-master-plan contradictions | Low | Sub-clause text constrains scope to "master-plan internal contradiction" specifically |

## Open Questions

None (Q&A 2026-05-01-001 Q2 resolved).

## Acceptance Record

- **2026-04-29**: PROPOSED at S16 IMPL Track 7 ratification (proposal file authored)
- **2026-05-01**: ACCEPTED by user via Q&A 2026-05-01-001 Q2=A explicit pick at S38 entry
