---
id: D-019-S43c-charter-promote-financial-data-protocol-rule-11
title: Append Rule 11 (Hook Portability Per Phase) to constitution/financial-data-protocol.md
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q2=A — Append (Recommended) — Edit charter + ADR D-019 ratifies; bash-hook-lint upgrades from advisory to charter-mandated"
  - path: agent-workspace/proposals/financial-data-protocol-amendment.md
    section: full file (42 LOC) — Rule 11 Hook Portability Per Phase
  - path: scripts/hooks/bash-hook-lint.sh
    section: Check 1 L-S11-1 (deterministic enforcement shipped S16)
  - path: agent-workspace/memory/agent-notes.md
    section: L-S11-1 (Phase 0 hook portability)
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: false
  urgency: NORMAL
  complexity_score: 35
options_considered:
  - id: A
    summary: Append Rule 11 to financial-data-protocol charter; bash-hook-lint upgrades to charter-mandated
    pros: ["Already enforced informally by 30+ hooks", "L-S11-1 codified", "Charter binding upstream of Rules 1-10"]
    cons: ["Charter file grows ~25 LOC"]
  - id: B
    summary: Move Rule 11 to architecture-amendment instead
    pros: ["Architecture is more natural home for hook conventions"]
    cons: ["Misses the 'upstream of data integrity' framing; financial-data-protocol IS where Rules 1-10 live, so portability rule belongs adjacent"]
  - id: C
    summary: Defer entire proposal
    pros: ["Zero charter touch"]
    cons: ["Loses traceability; bash-hook-lint stays advisory"]
chosen: A
chosen_rationale: |
  Rule 11 is upstream of data-integrity Rules 1-10 — silent hook failure means drift signals don't fire,
  meaning Rules 1-10 violations go undetected. Placing Rule 11 in financial-data-protocol.md is correct
  because it explicitly frames "hook portability is a precondition for data integrity." Architecture-
  amendment placement (Option B) loses that framing.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/financial-data-protocol-amendment.md
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed 'Rule 11 — Hook Portability' appended to financial-data-protocol.md"
affects:
  charter: true
  spec_files: []
  code_paths: ["scripts/hooks/bash-hook-lint.sh (charter-mandated when STOCKFORGE_HOOK_PROFILE=strict)"]
  config_files: []
  other_decisions: ["D-018"]
depends_on: ["D-007"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "financial-data-protocol", "hook-portability"]
---

# Decision 019 — S43c Charter Promote: Rule 11 Hook Portability

## Context

Hook portability rule L-S11-1 (Phase 0 hooks must be bash + POSIX only; Phase 1+ accept Python+jq) shipped as `bash-hook-lint.sh § Check 1` at S16 with advisory severity. Charter binding requires Q&A user pick; opened at Q&A 2026-05-01-003 Q2; user accepted Recommended at S43c entry 2026-05-04.

## Decision

Append `## Rule 11 — Hook Portability Per Phase` to `agent-workspace/constitution/financial-data-protocol.md` after `## When This Protocol Conflicts With Convenience`. Two phase-binding tiers:

- **Phase 0**: bash + POSIX only; forbidden `python|jq|pip|npm`
- **Phase 1+**: Python + jq accepted (downgrades L-S11-1 to informational at `STOCKFORGE_HOOK_PORTABILITY_TIER=1`)

`bash-hook-lint.sh § Check 1` upgrades from advisory to HARD-fail when `STOCKFORGE_HOOK_PROFILE=strict`.

## Why (Reasons)

1. Silent hook failure = drift signal doesn't fire = data-integrity violation undetected (Rule 6 LLM Provenance critical)
2. Charter Principle 8 (Calibration over confidence) — formalize what 30+ hooks already comply with
3. Aligns with Phase 1 already-active scope; phase boundary clearly defined

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Phase 1 hook author writes Python without realizing portability tier | Low | bash-hook-lint warns when in Phase 0 mode regardless; user opt-in to strict |

## Acceptance Record

- **2026-04-29**: PROPOSED by agent (S16 IMPL — Track 7 ratification draft)
- **2026-05-04**: ACCEPTED by user via Q&A 2026-05-01-003 Q2=A
