---
id: D-021-S43c-charter-promote-financial-data-protocol-VN
title: Append Vietnam-Domain Rules 12-15 to constitution/financial-data-protocol.md
date: 2026-05-04
status: ACCEPTED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-01-003-S39-track-E-bundle-2-scope-amendments.md
    quote: "Q4=A — Append (Recommended) — Edit charter + ADR D-021 ratifies; effective immediately"
  - path: agent-workspace/proposals/financial-data-protocol-amendment-VN.md
    section: full file (116 LOC) — Rules 12-15 Vietnam-domain
  - path: agent-workspace/ubiquitous-language/glossary.md
    section: v1.0 (S25 — 42 VN terms incl. T+2.5, Room ngoại, Sàn HOSE/HNX/UPCoM, Tỷ giá USD/VND)
  - path: PROJECT_CHARTER.md
    section: First Sub-Scope (HOSE/HNX/UPCoM, vốn hóa 2,000-50,000 tỷ VND)
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 70
options_considered:
  - id: A
    summary: Append Rules 12-15 as written; effective immediately (deferred enforcement per phase binding noted in each Rule body)
    pros: ["Anchors S27-S28 entity design", "Glossary v1.0 binding", "Rules 14 already implemented at S33"]
    cons: ["Phase 2+ rules (12 partial, 13, 15) are scaffold-only initially"]
  - id: B
    summary: Append BUT mark Rules 12, 13, 15 as Phase 2+ binding
    pros: ["More explicit phase gate"]
    cons: ["Phase binding already noted in Rule body; no functional difference"]
  - id: C
    summary: Defer entire amendment to Phase 3
    pros: ["Less charter surface now"]
    cons: ["Phase 2 entity design (S27-S28) loses charter anchor"]
chosen: A
chosen_rationale: |
  Rules 12-15 codify glossary v1.0 binding terms with phase-tagged enforcement. Phase 1 enforces
  Rule 14 already (S33 shipped Sàn-tier reconciliation tolerance ahead of charter ratification);
  Rules 12-13 + 15 scaffold types (Position.opened_at, ForeignOwnershipState, FxRate) so Phase 2
  enforcement layers slot in without retrofit. Charter binding now is correct because schema
  decisions taken in Phase 2 must reference these Rules.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-04-30
    via: agent-workspace/proposals/financial-data-protocol-amendment-VN.md
  - actor: user
    action: ACCEPTED
    at: 2026-05-04
    via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent"
verified_by:
  - mechanism: smoke-test
    at: 2026-05-04
    result: PASS
    notes: "grep confirmed 'Rule 12' through 'Rule 15' appended to financial-data-protocol.md"
affects:
  charter: true
  spec_files: ["specs/tier2-feature/000-phase-1-thin-slice-VHM.md (BR-3 + BR-5 alignment)"]
  code_paths: ["packages/domain/market_data/services/reconciliation_service.py (Rule 14 already aligned at S33)"]
  config_files: []
  other_decisions: ["D-022"]
depends_on: ["D-009", "D-010"]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A
tags: ["charter-promote", "S43c", "financial-data-protocol", "vietnam-domain", "vn-stock"]
---

# Decision 021 — S43c Charter Promote: VN-Domain Rules 12-15

## Decision

Append `## Rule 12 — T+2.5 Settlement Timing Awareness`, `## Rule 13 — Room Ngoại (Foreign-Ownership Cap) Detection`, `## Rule 14 — Sàn HOSE / HNX / UPCoM Data-Quality Tiering`, `## Rule 15 — FX VND-USD Point-in-Time Discipline` to `agent-workspace/constitution/financial-data-protocol.md` after Rule 11.

Each Rule carries phase-binding metadata (Phase 1 = scaffold; Phase 2+ = enforcement). Sibling D-022 ships invariants I-S55-I-S65 enforcing these Rules.

## Why (Reasons)

1. Glossary v1.0 (S25) surfaced 8 critical VN-domain terms; 4 are data-integrity-binding for Phase 1+ → Rules 12-15 cover them
2. Rule 14 already implemented at S33 (per-Sàn reconciliation tolerance) — charter binding now formalizes shipped behavior
3. PROJECT_CHARTER First Sub-Scope explicitly names HOSE/HNX/UPCoM — financial-data-protocol must codify the scope binding

## Acceptance Record

- **2026-04-30**: PROPOSED by agent
- **2026-05-04**: ACCEPTED by user via Q&A 2026-05-01-003 Q4=A
