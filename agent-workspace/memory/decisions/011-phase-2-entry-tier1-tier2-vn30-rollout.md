---
id: D-011-phase-2-entry-tier1-tier2-vn30-rollout
title: Phase 2 entry — Tier 1+2 VN30 rollout (mainstream news + fundamentals + working TCBS / DNSE / KBS adapter)
date: 2026-04-30
status: ACCEPTED
level: SCOPE (phase boundary; user explicit-gate via AskUserQuestion S30 close per Q-B2 doctrine)
author: ["Claude Opus 4.7 (S30 FOCUSED_IMPL — Phase 1 close ceremony)", "project owner (SCOPE-tier explicit pick: Option A Recommended)"]

source_evidence:
  - path: PROJECT_CHARTER.md
    section: "Success Criteria — Month 3 (Phase 1 close) + Month 6 (Phase 2 close)"
    quote: "Tier 1 + 2 data pipeline operational for VN30; 50 companies have basic dossier in wiki; first 5 thesis recorded"
  - path: agent-workspace/session-plans/pending/004-S24-phase-1-thin-slice-plan.md
    section: "§ S30 § Decision tier — SCOPE phase boundary user-pick"
    quote: "Phase 1 closed; ready to enter Phase 2 (Tier 1+2 VN30 rollout) or pause for dogfood?"
  - path: agent-workspace/memory/checkpoints/phase-1-thin-slice-S29-verdict.md
    section: "Verdict: PASS-WITH-RESIDUE — phase_gate UNBLOCKED"
    quote: "S30 closure session NEXT — eval-sets seed + thesis-template + VHM exemplar + Phase 1 close ceremony"
  - path: agent-workspace/memory/sessions/2026-04-30-session-30.md
    section: "AskUserQuestion 1Q SCOPE-tier — user picked Option A 'Enter Phase 2 — Tier 1+2 VN30 rollout (Recommended)'"
  - path: specs/tier1-strategic/001-four-tier-signal-architecture.md
    section: "§ B.1 Tier 1 + § B.2 Tier 2 — Hard Data + Official Narrative"
  - path: docs/DAY_1_CHECKLIST.md
    section: "Phase 1 → Phase 2 transition; Tier 2 ingestion (CafeF + NDH + VietnamBiz news scrapers)"

intent_classification: {primary_intent: SCOPE, affects_charter: false, affects_scope: true, urgency: NORMAL, complexity_score: 70}

options_considered:
  - id: A
    label: "Enter Phase 2 — Tier 1+2 VN30 rollout (Recommended)"
    description: "Author Phase 2 master-plan; scale BC-1 ingestion to VN30 ~30 tickers; discover working TCBS endpoint OR pivot to DNSE/KBS via vnstock (R2 closure); add Tier 2 BC-2 Fundamental + BC-5 News with mainstream Vietnamese news scrapers (CafeF + NDH + VietnamBiz); claim extraction + sentiment classification per spec 001 § B Phase 1 simplifications + spec-T1-001 § B.2. Estimated ~600-900K tokens (similar to Phase 1)."
    chosen: true
    rationale: "Continues compounding the data moat (Charter Principle 4). Charter Month 3 success criteria #1+#2 (Tier 1+2 pipeline VN30 + 50 dossiers) reachable. User explicit pick at S30 close."
  - id: B
    label: "Pause for dogfood week"
    description: "Stop adding scope; user manually runs VHM thin-slice for ~1 week; fills personal-risk-profile.md; reviews thesis-template structure; finds friction points before Phase 2 spec authoring. Resume Phase 2 PLAN once dogfood log written."
    chosen: false
    rationale: "Honors Charter Principle 7 (dogfood mandatory) but user judged Phase 2 momentum more valuable than 1-week dogfood pause; dogfood happens incidentally during Phase 2 anyway."
  - id: C
    label: "User-approve 9 proposals first"
    description: "Process queue at agent-workspace/proposals/; each proposal CHARTER-tier; explicit-approve moves to constitution/. After ratification, Phase 2 spec author can reference as binding rules instead of drafts."
    chosen: false
    rationale: "9 proposals are reference-only at agent-workspace/proposals/; Phase 2 IMPL can reference existing constitution Rules 1-11 + I-S1-I-S54; proposals approval can run in parallel with Phase 2 PLAN, not gate it."

decision: "Phase 1 closed at S30 (FOCUSED_IMPL ~110-130K self-track main session). Phase 2 entry approved SCOPE-tier via user explicit pick Option A at S30 AskUserQuestion. Phase 2 next session = PLAN type (master-plan author for Tier 1+2 VN30 rollout); separate session per CLAUDE.md hard rule 'never mix PLAN+IMPL'."

drift_notes:
  - "DR-PROV: every S30 deliverable maps to user 'continue' + master-plan 004 § S30 + AskUserQuestion explicit pick"
  - "DR-CONFIG: 0 — no settings.json edits at S30"
  - "DR-IDENTITY: stockforge identity preserved through Phase 1 close"

phase_impact: "PHASE-2-ENTRY"
binding_phase: 2

success_criteria:
  - "Phase 2 master-plan authored next session (PLAN type; NOT this session)"
  - "Phase 2 first session inherits all Phase 1 artifacts (Bar/Position/RiskRule + Tier 1 adapters + 248 VHM bars + thesis template + post-mortem template)"
  - "Phase 2 PLAN must address R2 (TCBS 404) + R3 (advisory LOC ceiling overruns architectural review) + 9 proposals user-approve workflow"

risks:
  - "vnstock API surface drift between Phase 1 and Phase 2 (L-S28-1 candidate; vendor-API drift)"
  - "Tier 2 news scraping legal/ToS surface (per Charter § Honest Boundaries; CafeF/NDH/VietnamBiz public-page-only)"
  - "VN30 universe expansion stresses adapter rate limits (Phase 1 rate-limit was 1 req/sec for VHM only; VN30 = ~30x)"

dependents:
  - "Phase 2 master-plan (next PLAN session)"
  - "Phase 2 first IMPL sessions (BC-2 Fundamental + BC-5 News stub)"
  - "9 proposals user-approve workflow (parallel; not a Phase 2 gate)"

revision_history:
  - {date: 2026-04-30, change: "Initial v1.0 — Phase 2 entry approved SCOPE-tier via user explicit pick A at S30 close"}
