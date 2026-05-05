---
id: D-018-S43c-charter-promote-architecture-amendment
title: Promote architecture-amendment.md (Slash Command vs Skill split + companions) to constitution/architecture.md
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q1=A — Append (Recommended) — Edit charter + ADR D-018 ratifies; effective immediately"
  - path: agent-workspace/proposals/architecture-amendment.md
    section: full file (98 LOC) — ratified text appended to constitution at S43c
  - path: agent-workspace/memory/agent-notes.md
    section: L-S14-2 (skill-vs-command duplication multiplier) + L-S16-1 (SKILL.md companion-via-references) + L-S18-1 (cross-locale pattern extension) + L-S19-1 (telemetry rollup deterministic-aggregator-first)
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: false
  urgency: NORMAL
  complexity_score: 60
options_considered:
  - id: A
    summary: Append amendment to charter + ADR ratifies; effective immediately
    pros: ["Codifies practical-applied 5+ uses", "Anti-pattern catalog grows", "Companion lessons (L-S16-1/L-S18-1/L-S19-1) bundled efficiently"]
    cons: ["Charter file grows ~80 LOC"]
  - id: B
    summary: Defer to Phase 3 — collect more duplication evidence
    pros: ["More empirical data"]
    cons: ["Already 3+ uses; further data won't change shape; defers L-S16-1 codification"]
  - id: C
    summary: Reject — keep informal in agent-notes.md
    pros: ["Zero charter-file churn"]
    cons: ["Loses charter-binding force; drift signal cannot reference"]
chosen: A
chosen_rationale: |
  User explicit "tôi accept toàn bộ q&a recommend của agent" at S43c entry confirms Recommended pick.
  Mechanism uses S38 deny-lift precedent (verified zero-residue at S38). All 4 lesson clusters
  (L-S14-2 / L-S16-1 / L-S18-1 / L-S19-1) bundle efficiently into one charter section because they
  share the meta-theme of "skill substrate discipline." Anti-pattern catalog AP-23 already references
  L-S19-1 informally; this gives it charter status.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-29
    via: agent-workspace/proposals/architecture-amendment.md (S16 IMPL — Track 7 ratification)
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent và các đề xuất còn đang block"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed 'Slash Command vs Skill' section appended to architecture.md; deny lines restored at lines 96+105 of .claude/settings.json"
affects:
  charter: true
  spec_files: []
  code_paths: []
  config_files: [".claude/settings.json (deny-lift transient; restored same turn)"]
  other_decisions: ["D-019", "D-020", "D-021", "D-022", "D-023", "D-024"]
depends_on: ["D-007"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "architecture", "skill-discipline"]
---

# Decision 018 — S43c Charter Promote: architecture-amendment.md (Slash Command vs Skill + companions)

## Context

Architecture amendment authored at S16 (2026-04-29) sat in `agent-workspace/proposals/` 5 days awaiting user ratification. Per `decision-discipline.md` Rule 1 (charter-tier requires explicit user pick), agent could not auto-ratify. Q&A 2026-05-01-003 Q1 surfaced the gate; user accepted Recommended at S43c entry 2026-05-04.

## Analysis

The amendment bundles 4 lessons sharing the meta-theme "skill substrate discipline":
- **L-S14-2**: skill-vs-command duplication multiplier (responsibility split table)
- **L-S16-1**: SKILL.md exceeds 150 LOC ceiling → split to `references/<topic>.md` companion
- **L-S18-1**: cross-locale pattern extension (regex content is locale-sensitive even when syntax is agnostic)
- **L-S19-1**: telemetry rollup — deterministic aggregator before LLM Guardian (cost + auditability)

Practical-applied evidence: `/grill-me` correctly delegates to `grill-maximization` skill; Track 6 secondary closure S20 split 3 SKILL.md files via companion; Track 8b S18 extractor added 5 Vietnamese phrases; `self-awareness-aggregate.sh` 124 LOC bash+awk shipped S19.

## Decision

Append to `agent-workspace/constitution/architecture.md` after `## Forbidden Patterns`, before `## Evolution Protocol`. New section title: `## Slash Command vs Skill — Responsibility Split (D-018, ratified 2026-05-04)` with 4 sub-sections covering each lesson cluster.

### What this means concretely

- Drift signal D-DUPL (TBD) gains charter backing for >50% command/skill body overlap
- SKILL.md ≤150 LOC enforced via D1; companion-via-references pattern is the documented escape hatch
- Bilingual pattern checklist mandatory when porting locale-sensitive regex/lexicon
- Continuous LLM-Guardian remains anti-pattern (AP-23) for telemetry rollup; deterministic-first

## Why (Reasons)

1. Charter Principle 8 (Calibration over confidence) — codify shipped patterns; don't re-discover
2. P3 (Surgical Changes) — bundling 4 related lessons in one charter section is the minimum-viable formalization
3. Aligns with stockforge identity-scope: VN-speaking user demands cross-locale extensibility (L-S18-1)

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Charter bloat (~80 LOC added) | Low | Section is dense + delegates to AP-23 anti-pattern catalog |
| Future skill drift | Med | D1 LOC ceiling check + manual review at /promote-rule cycles |

## Acceptance Record

- **2026-04-29**: PROPOSED by agent (S16 IMPL — Track 7 ratification draft)
- **2026-05-04**: ACCEPTED by user via "tôi accept toàn bộ q&a recommend của agent" + Q&A 2026-05-01-003 Q1=A
