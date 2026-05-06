---
id: D-029
title: S48d — Q-S48c-1 charter-promote drift-signals.md Tiered Coverage Map (DR1-DR12 ↔ D1-D9 reconciliation)
status: ACCEPTED
tier: CHARTER
date_proposed: 2026-05-05
date_ratified: 2026-05-05
ratified_by: Project owner — explicit AskUserQuestion ACCEPT pick (S48d 4-Q bundle, Q2)
ratifying_session: S48d (Phase 2.5 HH-C ritual codification; Q-S48c-1 carry-forward closure)
authoring_agent: Claude Opus 4.7
supersedes: none
superseded_by: none
source_evidence:
  - agent-workspace/proposals/drift-signals-reconciliation.md  # S48c HH-B.4 draft
  - agent-workspace/memory/observations/2026-05-05-drift-signal-audit-S48c.md  # gap matrix DR1-DR12 vs D1-D9
  - agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md § HH-B.4
  - scripts/hooks/drift-signals-D1-D9.sh  # Part B hook ext shipped S48c (DR1/3/6/8 detectors)
  - AskUserQuestion (S48d turn) — 4-Q bundle Q2=ACCEPT (Q-S48c-1)
options_considered:
  - A: ACCEPT Part A doctrine + Part B hook (Part B already live S48c) — chosen
  - B: AMEND (defer doctrine reorganization; specify revisions)
  - C: REJECT (leave doctrine misaligned with hook impl)
chosen_option: A
---

# D-029 — Drift-signals doctrine ↔ implementation reconciliation

## Summary

Charter amendment to `agent-workspace/constitution/drift-signals.md`: NEW "Tiered Coverage
Map" section inserted after `## How to Use` (before HIGH severity list). Categorizes the
14 DR-N signals across three tiers:

- **Tier-A** (Stop-hook automated): DR-A1..DR-A5 (formerly D1/D2/D3/D8/D9; renamed for
  numbering coherence) + 4 NEW DR1/3/6/8 grep detectors (Part B already shipped S48c)
  + DR-S1/S2 stock-specific + 3 partial-coverage signals (DR2/DR5/DR10).
- **Tier-B** (manual `/drift-check` semantic checks): DR4 / DR7 / DR12.
- **Tier-C** (DB-query checks; not run every session): DR9 / DR11.

Hook script filename `drift-signals-D1-D9.sh` retains its path for stability; internal
labels emit Tier-A signals as `DR-A<N>` per the new map.

## Why this charter-tier ratification

S48c HH-B.4 audit identified gap: doctrine defines 14 signals (DR1-DR12 + DR-S1/S2),
hook implements 9 (D1-D9). Coverage was 2/14 covered + 3/14 partial + 5/14
unimplemented-grep-feasible + 4/14 deferred-tier. The numbering schemes (D vs DR)
collided, leaving readers confused about which signal fires when.

Part B (4 NEW detectors DR1/3/6/8) already shipped S48c without charter gate — script
isn't in constitution. Part A doctrine reorganization needs USER-GATE because
constitution/drift-signals.md is in deny list.

## Implementation

**Charter edit** (deny-lift cycle this turn):
- `agent-workspace/constitution/drift-signals.md` — NEW "## Tiered Coverage Map" subsection
  inserted between `## How to Use` and `## HIGH Severity` (~40 LOC including the 3-tier
  bulleted list + numbering rationalization note).

**Permission ceremony** (S38 deny-lift mechanism):
- `.claude/settings.json` Edit deny rule `Edit(agent-workspace/constitution/**)`
  temporarily replaced with non-matching path `Edit(agent-workspace/constitution/.deny-lift-S48d/**)`
  for the duration of the drift-signals.md edit, then restored same-turn.
- D9 zero-residue verified: only drift-signals.md md5 changed; all other 12 constitution
  files md5 unchanged pre/post edit cycle.

**Hook ext (Part B)** — already shipped S48c:
- `scripts/hooks/drift-signals-D1-D9.sh` — added DR1/DR3/DR6/DR8 grep detectors (~30 LOC).
- Smoke S48c: DR3-LLM-NO-RETRY count=7 fires on packages/infrastructure/**;
  DR1/6/8 zero-state on clean domain layer (manually verified).

**Proposal closure**:
- `agent-workspace/proposals/drift-signals-reconciliation.md` — frontmatter
  `status: PROPOSAL` → `status: ACCEPTED`; ratification record points to this ADR.

## Numbering rename deferred

The proposal also lists internal label renames in script comments (D1 → DR-A1 etc.). This
turn ships ONLY the doctrine map; the script-comment rename is deferred to next routine
hook patch (low-priority cosmetic). Hook-emitted signal IDs continue using D1-D9 short
form until the comment-rename batch lands. Reader uses the Tiered Coverage Map for
correlation.

## Provenance chain

1. S48c HH-B.4 audit (2026-05-05) → gap matrix observation authored.
2. S48c shipped Part B hook ext (DR1/3/6/8 detectors) without charter gate.
3. S48c drafted proposal with Part A doctrine reorganization (USER-GATE per Q-B2).
4. Carry-forward Q-S48c-1 noted in S48c checkpoint as bundle opportunity.
5. S48d (this turn) bundled with HH-C.4 in 4-Q AskUserQuestion (Q2=Q-S48c-1).
6. User ACCEPT → deny-lift cycle this turn → Part A doctrine applied → this ADR authored.

## Trade-offs accepted

| Concern | Acceptance rationale |
|---|---|
| **drift-signals.md grows ~40 LOC** | Single canonical reference is cheaper than spread-out commentary in observations + decisions. |
| **Internal script labels still emit D1-D9** | Rename is cosmetic; deferred to next routine hook patch to avoid scope creep this session. |
| **DR2/DR5/DR10 marked "PARTIAL"** | Honest current state; full DB-check coverage (DR2 Tier-C) requires Postgres production deployment per Phase 3+. |

## Drift watch

- D9 charter md5: drift-signals.md CHANGED (intentional; ratified); all other 12 constitution files md5 UNCHANGED (verified pre/post via `find ... -exec md5sum`).
- D-INTENT: ALIGNED (Part A doctrine = exact text from proposal § Part A; no in-flight rewording).
- DR-PROV: this ADR cites proposal + observation + Part B hook ship reference + AskUserQuestion turn.

## Companion handoff

S48e (HH-D Mode-E charter promotion) NEXT — also charter-tier; could potentially bundle
with future charter amendments per L-S43f-1 doctrine. Currently no other queued
charter-tier proposals.

---

## Ratification record

User explicit ACCEPT via AskUserQuestion bundle (S48d turn 2026-05-05).
No amendments requested. Doctrine amendment shipped verbatim from proposal § Part A
(Part B was already live S48c).
