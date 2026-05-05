---
id: D-010-VN-domain-constitution-proposals
title: VN-domain constitution amendment proposals (Rules 12-15 + I-S55-I-S65 + personal-risk-profile template)
date: 2026-04-30
status: ACCEPTED-as-PROPOSAL
level: CHARTER (target) ratified at SCOPE-as-PROPOSAL (per Q-B2 doctrine — charter-tier needs explicit user-approve to land in constitution/)
author: ["Claude Opus 4.7 (S26 IMPL — Phase 1 Track B)"]

source_evidence:
  - path: PROJECT_CHARTER.md
    section: "First Sub-Scope (locked 6 months) + Core Principles 9-10"
    quote: "VN30 + mid-cap; long-only; HOSE/HNX/UPCoM; deterministic risk; no LLM math"
  - path: agent-workspace/ubiquitous-language/glossary.md
    section: "v1.0 — 42 VN terms (T+2.5, Room ngoại, Sàn HOSE/HNX/UPCoM, Trần, Sàn, Phiên ATO/ATC, Tỷ giá USD/VND)"
    quote: "Vocabulary anchor for VN-domain Rules 12-15 + I-S55-I-S65"
  - path: specs/tier2-feature/000-phase-1-thin-slice-VHM.md
    section: "A.3 Business Rules + A.5 Out-of-Scope"
    quote: "BR-3 VND only Phase 1; BR-5 T+2.5 informational; BC-1 Bar field design"
  - path: agent-workspace/constitution/financial-data-protocol.md
    section: "Rules 1-10 (existing; Rule 11 = S16 amendment Hook Portability orthogonal to VN-domain)"
  - path: agent-workspace/constitution/invariants.md
    section: "I-S1-I-S54 (existing; I-S55-I-S65 amendment continues sequential)"
  - path: docs/DAY_1_CHECKLIST.md
    section: "§ A.4 + § B.1 + § B.5 (financial-data-protocol customization + personal-risk-profile.md)"
  - path: agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md
    section: "§ S26 deliverables matrix (5 deliverables; CHARTER-target tier)"

intent_classification: {primary_intent: CHARTER, affects_charter: true, affects_scope: true, urgency: NORMAL, complexity_score: 55}

options_considered:
  - id: A
    summary: "Single combined proposal file (fold S16 Rule 11 + new VN Rules 12-15 into one financial-data-protocol-amendment.md)"
    pros: ["8 proposals net (matches master-plan abstract count)"]
    cons: ["Conflates orthogonal concerns (Hook Portability vs VN-domain)", "Author audit chain breaks (S16 vs S26 distinct context)", "Master-plan deliverable #1 explicit text says 'separate'"]
  - id: B
    summary: "Two separate proposal files (S16 Rule 11 unchanged + NEW S26 financial-data-protocol-amendment-VN.md Rules 12-15)"
    pros: ["Clean author audit per master-plan deliverable #1 explicit", "Orthogonal concerns kept orthogonal", "Each amendment lands at constitution independently — graceful approve workflow"]
    cons: ["9 proposals net (master-plan abstract count drift +1; document discrepancy in S26 session log)"]
  - id: C
    summary: "Defer S26 entirely; ship VN rules in Phase 2 when full enforcement lands"
    pros: ["Avoids proposal-stacking pre-S27 entities"]
    cons: ["Master-plan 004 explicit S26 deliverable; deferring drifts plan", "Glossary v1.0 already references VN terms — types should anchor now per spec 000 § B"]

chosen: B
chosen_rationale: |
  Master-plan deliverable #1 explicit: "NEW proposal file (separate from existing S16 amendment to keep author audit clean)".
  Master-plan success-criteria #7 internal contradiction (says fold to 8 net) is documented as drift in S26 session log.
  Rules 12-15 (VN-domain) and Rule 11 (Hook Portability) are orthogonal; conflating breaks Charter Principle "When in doubt, simplify".
  Net result: 9 proposals post-S26 — honest count > matching abstract.

approval_chain:
  - {actor: agent, action: PROPOSED, at: 2026-04-30, via: "S26 IMPL session per master-plan 004 § S26 deliverables list"}
  - {actor: agent, action: ACCEPTED-as-PROPOSAL, at: 2026-04-30, via: "IMPL-tier ratification per autonomous_mode=true (substrate decision; user explicit-approve gate moves to constitution/)", notes: "Distinct from ACCEPTED — proposals require user explicit-approve to move to agent-workspace/constitution/. Until then, S27-S29 reference existing constitution Rules 1-10 + I-S1-I-S54 only."}
  - {actor: user, action: PENDING-APPROVE, at: TBD, via: "future user-trigger (no auto-promotion); explicit-approve moves the 3 deliverable proposals from agent-workspace/proposals/ to agent-workspace/constitution/"}

verified_by:
  - {mechanism: file-creation-grep, at: 2026-04-30, result: PASS, notes: "Both proposal files + personal-risk-profile.md template authored within LOC ceilings"}
  - {mechanism: drift-sweep, at: 2026-04-30, result: PASS, notes: "D1=0 sustained; no new D9; no constitution edits"}

affects:
  charter: true (target — pending user explicit-approve)
  spec_files: [specs/tier2-feature/000-phase-1-thin-slice-VHM.md]
  code_paths: []
  config_files: []
  other_decisions: [D-002 (Workspace Dualism — proposals/ routing), D-009 (VHM exemplar — same Phase 1 thin-slice scope)]

depends_on: [D-002, D-009]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A — proposals stand pending user explicit-approve (no agent re-attempt). User-approve workflow:
  (1) user reviews 3 deliverables (financial-data-protocol-amendment-VN.md + invariants-amendment-VN.md + personal-risk-profile.md);
  (2) user issues explicit "approve VN-domain proposals" trigger;
  (3) agent moves 2 proposals from proposals/ to constitution/ (filenames preserved); personal-risk-profile.md stays in memory/ (not constitution-tier);
  (4) D-010 status updates ACCEPTED-as-PROPOSAL → ACCEPTED.

tags: ["phase-1", "track-B", "VN-domain", "charter-target", "proposal-stage", "data-protocol", "invariants", "personal-risk-profile"]
---

# D-010 — VN-domain constitution amendment proposals

> Status: ACCEPTED-as-PROPOSAL via IMPL-tier (autonomous_mode=true; substrate decisions). User explicit-approve required for promotion to constitution/.

## Decision

**Author 3 deliverables anchoring VN-domain Phase 1 enforcement scaffolds**:
1. `agent-workspace/proposals/financial-data-protocol-amendment-VN.md` — 116 LOC; Rules 12-15 (T+2.5 settlement / Room ngoại saturation / Sàn HOSE-HNX-UPCoM tiering / FX VND-USD point-in-time)
2. `agent-workspace/proposals/invariants-amendment-VN.md` — 108 LOC; I-S55-I-S65 (11 NEW VN-specific invariants enforcing Rules 12-15)
3. `agent-workspace/memory/personal-risk-profile.md` — 110 LOC; template with 33 USER FILL placeholders across 7 sections (holding period / position sizing / stop-loss / dividend / sector exclusions / drawdown tolerance / audit trail)

NOT in this decision: edits to constitution/ files (deny-listed; user explicit-approve required per Q-B2 doctrine), entities at packages/domain/ (S27 deliverables; reference existing Rules 1-10 + I-S1-I-S54 only).

## Why ACCEPTED-as-PROPOSAL not ACCEPTED

ACCEPTED status would mean the rules bind production code. ACCEPTED-as-PROPOSAL means: rules are codified for review, but enforcement does not attach until user moves files to constitution/. This preserves CLAUDE.md hard rule "Constitution never modified by agent" + agent-workspace/CLAUDE.md Contract Rule 1 — and gives user a bounded review surface (3 files; not a full charter rewrite).

## Why 9 proposals net post-S26 (master-plan said 8)

Master-plan 004 § S26 deliverable #1 says "separate from existing S16 amendment to keep author audit clean"; master-plan success-criteria #7 says "fold S16 into VN amendment for 8 net". Internal contradiction. Going with deliverable #1 explicit text — orthogonal concerns (Hook Portability vs VN-domain) deserve separate audit chains. Documented in S26 session log as master-plan drift item; not a regression — better count than fold.

## Acceptance Record

- **2026-04-30**: PROPOSED by Claude Opus 4.7 in S26 IMPL session per master-plan 004 § S26 deliverables list
- **2026-04-30**: ACCEPTED-as-PROPOSAL by agent via IMPL-tier ratification (autonomous_mode=true)
- **TBD**: PENDING user explicit-approve to move proposals → constitution/
