---
id: D-009-VHM-thin-slice-exemplar
title: VHM as Phase 1 thin-slice exemplar
date: 2026-04-30
status: ACCEPTED
level: SCOPE
author: ["Claude Opus 4.7", "user (Q-S25-1 explicit pick)"]

source_evidence:
  - path: PROJECT_CHARTER.md
    section: "First Sub-Scope (locked 6 months) + Success Criteria § Month 3"
    quote: "VN30 + mid-cap; long-only; Tier 1+2 pipeline / 50 dossiers / 5 thesis / thesis-validate <5min"
  - path: agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md
    section: "Thin-Slice Definition § Exemplar stock pick"
    quote: "VHM — VN30 + high data coverage + non-banking baseline + not a pump candidate"
  - path: agent-workspace/memory/checkpoints/latest.md
    section: "S23 close — monorepo skeleton 9 BCs SHIPPED"
  - path: specs/tier2-feature/000-phase-1-thin-slice-VHM.md
    section: "A.6.1 Decision (this same S25 session)"

intent_classification: {primary_intent: SCOPE, affects_charter: false, affects_scope: true, urgency: NORMAL, complexity_score: 35}

options_considered:
  - id: A
    summary: "VHM (Vinhomes; HOSE; VN30; real-estate)"
    pros: ["VN30 matches Charter § First Sub-Scope verbatim", "Full coverage on vnstock+TCBS+Vietstock", "Real-estate exercises foreign-flow authentically", "Not a pump candidate (Tier 4 deferral honest)", "Non-banking baseline (generic statements)"]
    cons: ["Vốn hóa ~150K tỷ VND above mid-cap band (large-cap edge case)", "Real-estate cyclicality may produce noisy thesis"]
  - id: B
    summary: "VIC (Vingroup; conglomerate)"
    pros: ["Same data quality as VHM (sister stock)", "Conglomerate exercises BC-3 ownership"]
    cons: ["Conglomerate complexity violates P2 Simplicity", "Multi-segment fundamentals harder to attribute"]
  - id: C
    summary: "VPB (VPBank; banking)"
    pros: ["Exercises Room ngoại 30% banking-specific saturation"]
    cons: ["Banking statements (NIM/CASA/NPL) need Phase 2 BC-2 maturity", "Phase 1 wants generic baseline"]

chosen: A
chosen_rationale: |
  VHM cleanest thin-slice exemplar: (1) Charter § First Sub-Scope verbatim match;
  (2) data coverage clean on vnstock+TCBS+Vietstock for OHLCV + foreign flow;
  (3) generic non-banking sector exercises foreign-flow without specialized statements;
  (4) not a pump candidate, keeping Phase 1 Tier-4 deferral honest.
  VIC adds conglomerate complexity (P2 violation). VPB needs banking-specific rules (Phase 2 BC-2).
  Sister-quality data; Q-S25-1 = A Recommended user-explicit confirmed.

approval_chain:
  - {actor: agent, action: PROPOSED, at: 2026-04-30, via: "session-plans/pending/004-S24-... § Thin-Slice Definition (master-plan Recommended)"}
  - {actor: user, action: ACCEPTED, at: 2026-04-30, via: "S25 AskUserQuestion Q-S25-1 = VHM (Recommended)", notes: "SCOPE-tier user-gate per proposals/decision-discipline.md Q-B2 doctrine."}

verified_by:
  - {mechanism: spec-frame-author, at: 2026-04-30, result: PASS, notes: "specs/tier2-feature/000-phase-1-thin-slice-VHM.md frontmatter exemplar_stock: VHM; A.6.1 records options + rationale matching D-009"}

affects:
  charter: false
  spec_files: [specs/tier2-feature/000-phase-1-thin-slice-VHM.md]
  code_paths: [apps/cli/ingest_vhm.py, data/vhm.sqlite, agent-workspace/memory/thesis-log/2026-04-30-VHM-exemplar.md]
  config_files: []
  other_decisions: []

depends_on: [D-002, D-007]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  Phase 2 PLAN re-evaluates for VN30 expansion. Revisit BEFORE Phase 2 if:
  (1) VHM data coverage degrades >5% reconciliation divergence over 2+ weeks;
  (2) VHM delists or suspends >5 sessions;
  (3) S29 verifier raises material exemplar-adequacy concern.

tags: ["phase-1", "thin-slice", "exemplar", "VHM", "VN30", "BC-1", "BC-9", "scope-tier"]
---

# D-009 — VHM as Phase 1 thin-slice exemplar

> Status: ACCEPTED via SCOPE-tier user-gate (Q-S25-1 = VHM Recommended at S25 entry).

## Decision

**Phase 1 thin-slice exemplar = VHM (Vinhomes JSC, HOSE listing).** S26-S30 deliverables anchor on VHM:
- S28 ingestion: `python apps/cli/ingest_vhm.py --start 2025-04-30 --end 2026-04-29 --output ./data/vhm.sqlite` ≥200 daily Bar rows
- S30 exemplar thesis: `memory/thesis-log/2026-04-30-VHM-exemplar.md` — read-only on real data; SQL-derived numbers, not LLM
- BC-1 Bar gets authentic foreign_buy/foreign_sell exercise; BC-9 Position single-ticker integration path
- Reconciliation service tested on real vnstock+TCBS divergence (not synthetic fixtures only)

NOT changed: constitution (deny-listed; VN rules → S26 proposals); 9-BC skeleton (S23); Charter; VN30 rollout (still Phase 2).

## Why

1. Charter § First Sub-Scope verbatim (VN30 + long-only + 1-month-min + 5-15% sizing).
2. Charter Principle 4 (moat): 1 stock × 250 days starts the moat; Phase 2 scales 30×.
3. Karpathy P2 (Simplicity): forces honest scope before VN30 multi-stock cost.
4. Karpathy P3 (Surgical): every S26-S30 line traces "ingest → persist → position → reconcile → thesis".

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| VHM data quality degrades | LOW | Reconciliation handles divergence; >5% logged not fatal (Phase 2 hardening) |
| VHM delists during Phase 1 | VERY LOW | VN30 anchor; 25y tenure; trigger D-009 revisit → swap VIC/VPB |
| S30 exemplar thesis vacuous (1y EOD) | MED | EXEMPLAR not real (master-plan Q-S30-1); template demo, not investment |
| Real-estate cycle inflection | LOW | Phase 1 = scaffolding test, not signal validation |

## Open Questions

(None — Q-S25-1 user-picked Recommended; ACCEPTED full-status at S25 close.)

## Acceptance Record

- **2026-04-30**: PROPOSED by Claude Opus 4.7 in S24 master-plan 004 § Thin-Slice Definition (Recommended)
- **2026-04-30**: ACCEPTED by user via S25 AskUserQuestion Q-S25-1 = VHM (Recommended)
