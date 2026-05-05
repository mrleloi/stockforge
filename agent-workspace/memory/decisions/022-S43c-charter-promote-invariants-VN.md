---
id: D-022-S43c-charter-promote-invariants-VN
title: Append Vietnam-Domain Invariants I-S55..I-S65 to constitution/invariants.md
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q5=A — Append (Recommended) — Edit charter + ADR D-022 ratifies; gate via Q4 (Q5 only effective if Q4=A or B)"
  - path: agent-workspace/proposals/invariants-amendment-VN.md
    section: full file (108 LOC) — I-S55 through I-S65 (11 invariants)
  - path: agent-workspace/memory/decisions/021-S43c-charter-promote-financial-data-protocol-VN.md
    section: Rules 12-15 (gate satisfied — Q4=A)
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70
options_considered:
  - id: A
    summary: Append I-S55-I-S65 (11 invariants) gated on D-021 acceptance
    pros: ["Faithful to master-plan 004 § S26 11-concern enumeration", "Phase 2 entity scaffolds anchored", "Phase 1 invariants (I-S59 scaffold, I-S64 tolerance) already aligned with S33 code"]
    cons: ["Charter invariants jump from 54 → 65 (≈20% growth)"]
  - id: B
    summary: Append BUT skip Phase 2+ scaffolds (only ship Phase 1-binding invariants now)
    pros: ["Smaller charter surface"]
    cons: ["Phase 2 entity scaffolds lose charter-tier traceability; retrofit cost when Phase 2 enforcement lands"]
  - id: C
    summary: Defer entire amendment to Phase 3
    pros: ["Zero charter touch"]
    cons: ["Phase 2 schema design floats without invariant traceability"]
chosen: A
chosen_rationale: |
  11 invariants enforce Rules 12-15 (D-021) plus 7 additional Phase 2+ scaffolds (ATO/ATC, ex-date,
  lot-size, ceiling/floor, suspension, ex-rights). Better to ship 11 honestly than cherry-pick 4.
  Phase-binding metadata in each invariant body keeps Phase 1 enforcement clean while reserving
  Phase 2+ slot.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-30
    via: agent-workspace/proposals/invariants-amendment-VN.md
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed I-S55 through I-S65 appended to invariants.md after I-S54"
affects:
  charter: true
  spec_files: []
  code_paths: ["packages/domain/market_data/value_objects/sàn.py (I-S59 — already at S33)", "packages/domain/market_data/services/reconciliation_service.py (I-S64 — already at S33)"]
  config_files: []
  other_decisions: ["D-021"]
depends_on: ["D-021"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "invariants", "vietnam-domain", "vn-stock"]
---

# Decision 022 — S43c Charter Promote: Vietnam-Domain Invariants I-S55..I-S65

## Decision

Append 11 NEW invariants (I-S55 through I-S65) to `agent-workspace/constitution/invariants.md` after I-S54, before `## Violations Handling`. Coverage map:

| Invariant | Enforces | Binding Phase |
|---|---|---|
| I-S55 | Rule 12 (T+2.5 cleared cash) | Phase 2 |
| I-S56 | Rule 13 (Foreign-Room saturation) | Phase 2 |
| I-S57 | Phiên ATO/ATC phase tagging | Phase 2+ |
| I-S58 | Dividend ex-date VN convention | Phase 1 scaffold + Phase 2 enforce |
| I-S59 | Sàn tagging (Rule 14 partial) | Phase 1 scaffold + Phase 2 enforce |
| I-S60 | Lot-size 100-share rule | Phase 2 |
| I-S61 | Ceiling/Floor (Trần/Sàn) per-Sàn limits | Phase 1 method + Phase 2 fillability |
| I-S62 | Trading-suspension event | Phase 2+ |
| I-S63 | Corporate-action ex-rights | Phase 1 enum + Phase 2 feed |
| I-S64 | Sàn-tiered reconciliation tolerance (Rule 14) | Phase 1 (S28+) |
| I-S65 | Source-fallback chain order | Phase 1 (S28+) |

## Why (Reasons)

1. Master-plan 004 § S26 enumerated 11 concerns; codified faithfully (better to ship 11 honestly than cherry-pick 10)
2. D-021 Rules 12-15 require I-S* enforcement at invariant tier per architecture pattern (Rules → Invariants → Code)
3. S33 code already aligned with I-S59 + I-S64 — charter binding now formalizes shipped behavior

## Acceptance Record

- **2026-04-30**: PROPOSED by agent
- **2026-05-04**: ACCEPTED by user via Q&A 2026-05-01-003 Q5=A (gate D-021 satisfied)
