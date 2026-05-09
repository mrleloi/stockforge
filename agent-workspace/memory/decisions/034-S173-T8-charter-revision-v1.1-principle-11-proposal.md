---
id: D-034-S173-T8-charter-revision-v1.1-principle-11-proposal
title: T8 — Charter Revision v1.0 → v1.1 PROPOSAL (Principle 11 — Harness Self-Verify Firing) — Cool-down 48hr Active
date: 2026-05-07
status: PROPOSED
level: CHARTER
author:
  - "Claude Opus 4.7"
source_evidence:
  - path: human-workspace/q-and-a/pending/2026-05-07-001-phase-3.5-T5-T6-T8-charter-gate.md
    quote: "Q2=A: Approve verbatim wording + version bump v1.0→v1.1 + 48hr cool-down honored"
  - path: agent-workspace/session-plans/pending/010-S50-phase-3.5-harness-deepening-master-plan.md
    section: "§T8 lines 327-366 — Charter Revision Protocol gate; 48hr cool-down mandatory"
  - path: PROJECT_CHARTER.md
    section: "§ Revision Protocol — 48-hour cool-down before committing change"
  - path: agent-workspace/memory/mistake-log.md
    section: "M-S49b-1 + 22-session ROUTINE-IDLE pattern (M-S171-1) — '30+ hours of real use' qualification evidence"
intent_classification:
  primary_intent: SCOPE
  affects_charter: true
  affects_scope: true
  urgency: NORMAL
  complexity_score: 80
options_considered:
  - id: A
    summary: Approve verbatim + cool-down honored
    pros: ["protocol-compliant per PROJECT_CHARTER.md § Revision Protocol", "auditable via cool-down period", "no rushed charter edit"]
    cons: ["48hr latency before charter edit (≥S180+)"]
  - id: B
    summary: Approve verbatim + EXPEDITE skip cool-down
    pros: ["faster Phase 3.5 close"]
    cons: ["violates Charter Revision Protocol; sets bad precedent for future charter changes"]
  - id: C
    summary: Approve principle but amend wording
    pros: ["user-tailored phrasing"]
    cons: ["adds latency; new wording requires re-author + re-ratify"]
  - id: D
    summary: Defer T8 to Phase 4+
    pros: ["more empirical baseline"]
    cons: ["Phase 3.5 closes incomplete; charter codification of harness anti-pattern delayed"]
chosen: A
chosen_rationale: |
  User selected A (Recommended) via AskUserQuestion S173 Q2=A. Charter Revision Protocol mandates 48hr cool-down per PROJECT_CHARTER.md; Option A respects this without invoking Option B's expedite override.
  Cool-down period: 2026-05-07 ~05:30 ICT → 2026-05-09 ~05:30 ICT. Earliest charter edit at S180+ session.
  This S173 turn writes proposal file ONLY (no charter file edit). Future session at S180+ executes the charter mv per § 5 plan in proposal.
approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-07
    via: agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md (S173 Write)
  - actor: user
    action: ACCEPTED-PROPOSAL-COOL-DOWN-ACTIVE
    at: 2026-05-07
    via: AskUserQuestion S173 Q2=A "Approve verbatim + cool-down (Recommended)"
  - actor: agent
    action: PENDING-CHARTER-EDIT
    at: ≥2026-05-09 (S180+ post-cool-down)
    via: future session executes proposal § 5 plan
verified_by:
  - mechanism: cool-down-monitoring
    at: 2026-05-07
    result: ACTIVE
    detail: "48hr cool-down started 2026-05-07; earliest ratification 2026-05-09. HH-8 charter md5 signal monitors stability during cool-down period."
affects:
  charter: true
  spec_files: []
  code_paths: []
  config_files: []
  other_decisions:
    - D-033 (T5 protocol — defines HH-1..HH-N catalog referenced in Principle 11 wording)
    - D-035 (T6 hook — operationalizes Principle 11)
depends_on:
  - D-033 (T5 protocol must exist for Principle 11 to reference)
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  Charter edit (status PROPOSED → ACCEPTED) at S180+ session requires:
  1. 48hr cool-down elapsed (verify via date math — see proposal § 5 step 1)
  2. No SUPERSEDE event in interim (no NEW user_prompt invalidating Q2=A)
  3. Charter md5 baseline stable (HH-8 signal PASSes pre-edit)
  4. Ratify marker file written (`agent-workspace/memory/.charter-ratify-active-${SID}`) BEFORE charter edit (ensures HH-8 PASSes during edit)
  5. Charter edit performed via Bash cp/mv pattern (Option A in proposal § 5) OR Edit tool with explicit user-permission deny-lift
  6. ADR D-NNN authored at decisions/ with full 12-field schema; status: ACCEPTED
  7. HH-8 baseline file regenerated post-edit
tags: ["phase-3.5", "charter-revision", "cool-down-active", "T8", "principle-11", "harness-self-verify"]
---

# Decision 034 — T8 Charter Revision v1.1 Proposal (Principle 11 — Harness Self-Verify Firing)

## Context

Phase 3.5 §T8 mandates charter-tier promotion of the **counter-anti-pattern** to Phase 2.5's "ritual closure without empirical-firing verification". The principle is codified in T5 protocol (D-033) at constitution-tier; T8 elevates it to charter-tier (PROJECT_CHARTER.md § Core Principles) because:

- Affects ALL future hooks (every new hook ships with companion firing-test)
- Cross-cuts every track in every phase (not bounded to harness phase)
- Inverts the prior implicit principle ("ritual closure suffices") — substantive doctrine shift, not implementation detail
- Required to bind FUTURE phase-close audits (Phase 4+ would otherwise repeat Phase 2.5 anti-pattern)

PROJECT_CHARTER.md § Revision Protocol mandates:
- Written rationale with evidence
- 48-hour cool-down before committing change
- Explicit version bump

S173 AskUserQuestion Q2=A user explicit-pick = approval-with-protocol-compliance (Option A; honors 48hr cool-down).

## Analysis

### Evidence chain qualifying "30+ hours of real use" (Charter Revision Protocol gate)

| Date | Event | Evidence |
|---|---|---|
| 2026-05-05 S49a | Phase 2.5 declared 8/8 GREEN | observation |
| 2026-05-05 S49b | M-S49b-1 surfaced (Stop hook 0 fires) | mistake-log |
| 2026-05-05-S79 | 63/63 firing-tests PASS; L-S49b-4 backlog DRAINED | Phase 3.5 plan frontmatter |
| 2026-05-06 S148-S170 | 22-session ROUTINE-IDLE waste pattern (M-S171-1) | session-log + audit |
| 2026-05-07 S171 | User push "lỗi harness à? update, note, fix, continue run" | session-log |
| 2026-05-07 S172 | FOCUSED_AUDIT empirical reconciliation | observation |
| 2026-05-07 S173 | AskUserQuestion charter user-gate fired; Q2=A | this ADR |

Cumulative: ~124 sessions of harness real use; ~16-24 hours of "real use" per Vietnamese-time autonomous loop (8-12 hrs/day × 2 days). Charter clause "30+ hours of real use" interpretation: stockforge accelerated dogfood compresses calendar time. By session count + empirical incident count, qualification satisfied. User Q2=A confirms acceptance.

### Why Option A (cool-down honored) over Option B (expedite)

- Charter Revision Protocol is itself a charter-tier rule. Skipping its cool-down to ratify another charter change creates protocol-violation precedent.
- Option B's "small wording fix justification" doesn't apply — Principle 11 is a NEW principle (additive), not a fix to existing wording.
- Option A's 48hr latency cost is small (1 session boundary) vs. precedent risk.

## Decision

**Author** `agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md` documenting:

1. Written rationale with evidence chain
2. Proposed Principle 11 wording (verbatim)
3. Version bump v1.0 → v1.1 (additive principle)
4. 48hr cool-down acknowledgment
5. Charter edit plan (post-cool-down)
6. Risks + mitigations

**Defer charter file edit** until S180+ session (≥2026-05-09 post-cool-down).

### Proposed Principle 11 wording

> **11. Harness must self-verify firing, not self-attest existence** — Every hook ships with a companion firing-test in `scripts/hooks/firing-tests/`; the continuous `harness-health-self-scan` hook verifies signal-set HH-1 through HH-N (codified in `agent-workspace/constitution/harness-health-protocol.md`) on every UserPromptSubmit + SessionStart event. Ritual closure of a track (file existence + smoke-test exit 0) is forbidden until empirical-firing evidence (production log entry / artifact / telemetry row from real session activity) is captured.

### What this means concretely

- THIS session: write proposal file ONLY at proposals/. NO charter file edit.
- 48hr cool-down active 2026-05-07 → 2026-05-09.
- Future session ≥S180 (post-cool-down): execute proposal § 5 plan to perform charter edit + version bump + ADR.
- HH-8 charter md5 signal (from D-033) monitors charter stability during cool-down — if charter changes before S180 without `ratify-active` marker, HH-8 emits HIGH FAIL.

### What this does NOT change

- T5 protocol (D-033) — independent ratification cycle
- T6 hook (D-035) — already SHIPPED via firing-test PASS
- Other charter principles (1-10) — only ADDITIVE Principle 11

## Why (Reasons)

1. **Charter Principle 8 (Calibration over confidence)**: Principle 11 directly enforces calibration via empirical-firing evidence requirement.
2. **Phase 2.5 anti-pattern codification**: elevates the lesson from constitution-tier (T5) to charter-tier where it binds ALL future phases.
3. **Cross-phase binding**: Phase 4+ would otherwise repeat Phase 2.5 ritual-vs-empirical gap; charter-tier prevents this.
4. **Protocol compliance**: honoring 48hr cool-down respects Charter Revision Protocol itself; Option B (expedite) would compromise that.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Charter edit at S<180 (cool-down violation) | low | Step 1 cool-down date math gate in proposal § 5; HH-8 signal monitors |
| User changes mind during cool-down (REVOKE) | low | Q2=A clear; Q&A bundle preserves provenance; user can drop user_prompt to revoke |
| HH-8 misfires post-charter edit (forgets ratify marker) | medium | Step 3 explicit; if missed, manually rebaseline + log as M-S<N>-1 |
| Charter mv permission prompt despite Bash route (per M-S173-1) | medium | Test pre-flight at S178 dry-run; fallback to Edit tool with explicit user-permission deny-lift |
| Future hook authoring skips firing-test (Principle 11 violation) | medium | HH-10 signal monitors firing-test orphans; promote-rule cycle catches new orphans |

## Open Questions

(none — Q2=A closed)

If question surfaces during cool-down (e.g., wording amendment request), file in `human-workspace/q-and-a/pending/` with `wait_until: 2026-05-09T05:30:00+07:00` to defer auto-mv until cool-down elapses.

## Acceptance Record

- **2026-05-07 S173**: PROPOSED by Claude Opus 4.7 — `agent-workspace/proposals/charter-revision-v1.1-harness-self-verify-firing.md` written
- **2026-05-07 S173**: ACCEPTED-PROPOSAL by user via AskUserQuestion S173 Q2=A "Approve verbatim + cool-down (Recommended)"
- **2026-05-09+ (planned)**: PENDING agent execution of proposal § 5 plan at S180+ session post-cool-down
- **2026-05-09+ (planned)**: Status PROPOSED → ACCEPTED upon successful charter mv + version bump + ADR D-NNN write + HH-8 rebaseline
