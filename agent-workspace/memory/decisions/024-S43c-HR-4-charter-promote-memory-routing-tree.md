---
id: D-024-S43c-HR-4-charter-promote-memory-routing-tree
title: Promote HR-4 memory-routing-tree.md from proposals/ to constitution/ + wire memory-routing-audit.sh hook
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: agent-workspace/proposals/memory-routing-tree.md
    section: full file (HR-4 draft authored 2026-05-01 during S43b-EVIDENCE harness recovery)
  - path: agent-workspace/memory/checkpoints/latest.md
    section: HR-4 row "DRAFTED + GATED-HUMAN-APPROVAL"
  - path: agent-workspace/memory/self-awareness/known-issues.md
    section: KI-S43b-5 (project-vs-user-memory routing failure)
  - path: agent-workspace/memory/self-awareness/best-practices.md
    section: BP-S43b-5 (project-scoped lessons land in agent-notes.md)
  - path: scripts/hooks/memory-routing-audit.sh
    section: 93 LOC bash + POSIX; smoke-tested 2026-05-01; UNWIRED until ratification
intent_classification:
  primary_intent: CORRECTION
  affects_charter: true
  affects_scope: false
  urgency: NORMAL
  complexity_score: 45
options_considered:
  - id: A
    summary: Promote proposal verbatim to constitution/memory-routing-tree.md + wire memory-routing-audit.sh hook into Stop chain
    pros: ["Closes HR-4 charter gate from S43b harness recovery", "Hook becomes deterministic enforcement of routing tree", "User-detected failure mode (KI-S43b-5) gets charter-binding fix"]
    cons: ["Adds 1 to Stop hook chain (now 18)"]
  - id: B
    summary: Merge proposal as new § into existing memory-tiers.md
    pros: ["Single charter file for memory concerns"]
    cons: ["Memory-tiers covers vertical Tier 1/2/3; routing-tree covers horizontal project vs user; conflating loses clarity"]
  - id: C
    summary: Reject — keep informal in agent-notes.md
    pros: ["Zero charter touch"]
    cons: ["Failure mode recurs; deterministic hook stays unwired"]
chosen: A
chosen_rationale: |
  The proposal is short (94 LOC), low-ambiguity, addresses a user-detected failure mode
  (KI-S43b-5: 12+ entries accumulated as user-memory when they should have been project memory).
  Companion hook memory-routing-audit.sh provides deterministic enforcement complementary to the
  charter doctrine. Net governance load is positive (one new file; one new hook; clear rules).
  Sibling charter memory-tiers.md (D-017) covers vertical tiers within project memory; this charter
  covers horizontal project-vs-user routing — orthogonal concerns, separate files.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-01
    via: agent-workspace/proposals/memory-routing-tree.md (HR-4 harness recovery)
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent và các đề xuất còn đang block"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "ls confirms file moved from proposals/ to constitution/; frontmatter status flipped PROPOSAL→CHARTER; .claude/settings.json Stop chain shows memory-routing-audit.sh wired between lesson-synthesis-watchdog and promotion-cycle-trigger; deny lines restored at lines 96+105"
affects:
  charter: true
  spec_files: []
  code_paths: ["scripts/hooks/memory-routing-audit.sh (now wired into Stop chain)"]
  config_files: [".claude/settings.json"]
  other_decisions: ["D-017"]
depends_on: []
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "HR-4", "memory-routing", "harness-recovery"]
---

# Decision 024 — S43c HR-4 Charter Promote: memory-routing-tree

## Context

S43b-EVIDENCE harness recovery (2026-05-01) detected user-memory dir accumulating 12+ project-scoped entries that should have been in `agent-notes.md`. KI-S43b-5 documented the failure mode. Agent drafted memory-routing-tree.md proposal authored at proposals/ + companion hook memory-routing-audit.sh DRAFTED but UNWIRED. Both gated on charter ratification.

## Decision

1. Move `agent-workspace/proposals/memory-routing-tree.md` → `agent-workspace/constitution/memory-routing-tree.md`
2. Update frontmatter: `status: PROPOSAL` → `status: CHARTER`, add `ratified_at: 2026-05-04`, `ratifying_decision: D-024`
3. Wire `scripts/hooks/memory-routing-audit.sh` into `.claude/settings.json` Stop chain after `lesson-synthesis-watchdog.sh`, before `promotion-cycle-trigger.sh`

## What this means concretely

- Routing tree (Q1/Q2/Q3 + 4 hard rules) becomes charter-binding
- Hook ALERTs (default) when production-code session ends with no fresh agent-notes.md write but fresh user-memory dir mtime
- `STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1` OR `STOCKFORGE_HOOK_PROFILE=strict` upgrades to exit 2 hard-block
- KI-S43b-5 failure mode now structurally prevented (deterministic enforcement)

## Why (Reasons)

1. User-detected failure mode (KI-S43b-5) — autonomous-loop credibility depends on closing
2. Closes HR-4 from S43b checkpoint (last outstanding charter-tier gate from harness recovery)
3. Companion hook = deterministic enforcement matches Charter Principle 8 (calibration over confidence)
4. Sibling memory-tiers.md (D-017) covers orthogonal concern (vertical Tier 1/2/3) — separate files preserve clarity

## Acceptance Record

- **2026-05-01**: PROPOSED by agent (S43b-EVIDENCE — HR-4)
- **2026-05-04**: ACCEPTED by user at S43c entry
