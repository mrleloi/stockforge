---
id: D-028
title: S48d — HH-C.4 CLAUDE.md § Session End ritual extension (5 → 9 steps; codifies HH-C.1+2+3 watchdog hooks)
status: ACCEPTED
tier: CHARTER
date_proposed: 2026-05-05
date_ratified: 2026-05-05
ratified_by: Project owner — explicit AskUserQuestion ACCEPT pick (S48d 4-Q bundle, Q1)
ratifying_session: S48d (Phase 2.5 HH-C ritual codification)
authoring_agent: Claude Opus 4.7
supersedes: none
superseded_by: none
source_evidence:
  - agent-workspace/proposals/claude-md-session-end-extension-HH-C.4.md  # this turn's draft
  - agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md § HH-C
  - agent-workspace/memory/observations/2026-05-05-harness-alignment-audit.md § DRC-1 Continuous-obligation gap
  - agent-workspace/constitution/decision-discipline.md § Rule 4b (D-026; lesson-synthesis mandatory)
  - AskUserQuestion (S48d turn) — 4-Q bundle Q1=ACCEPT (HH-C.4)
  - scripts/hooks/session-end-checklist-linter.sh  # HH-C.1 companion (shipped this session)
  - scripts/hooks/project-md-staleness-check.sh  # HH-C.2 companion
  - scripts/hooks/profile-template-auto-populate.sh  # HH-C.3 companion
options_considered:
  - A: ACCEPT 9-step extension verbatim (chosen)
  - B: AMEND (would require user-specified per-step rewording; deferred re-draft next session)
  - C: REJECT (would leave watchdog hooks operational but no documented agent expectation)
chosen_option: A
---

# D-028 — HH-C.4 CLAUDE.md § Session End ritual extension

## Summary

CLAUDE.md § Session End checklist extended from 5 → 9 explicit steps. The 4 NEW steps
(#6 mistake-log update / #7 project.md staleness verify / #8 auto profile-template /
#9 auto promote-rule) document agent obligations now mechanically enforced by S48d
HH-C.1+2+3 Stop-hook watchdogs. Steps 1-5 unchanged.

## Why this charter-tier ratification

CLAUDE.md is always-loaded Tier 1 (per `tier1-bloat-check.sh` ceiling 8K tok). Any change
to CLAUDE.md affects every future session — high blast radius warrants USER-GATE per the
project convention even though the file isn't literally in `.claude/settings.json` deny list.

The DRC-1 audit finding (2026-05-05 `harness-alignment-audit.md`) attributed
~70% alignment to "continuous-obligation gap" — agent inconsistently completes session-end
ritual. HH-C track (S48d) ships the deterministic enforcement layer (3 Stop-hook watchdogs);
HH-C.4 documents the agent-side expectation those hooks enforce. Without HH-C.4, the hooks
emit warnings against an undocumented baseline.

## Implementation

**File**: `CLAUDE.md` lines 50-55 (the 5-line `### End` block) → replaced with 9-line block.

**Net diff**: +4 lines / 0 lines deleted (steps 1-5 verbatim preserved).

**Token impact**: ~50 tokens added to always-loaded Tier 1 (well within 8K ceiling — current
Tier 1 ~120K per S48 baseline; ~50/8K = 0.6% of ceiling delta).

**Companion hooks shipped same session**:
- `scripts/hooks/session-end-checklist-linter.sh` (~85 LOC; soft-warn; smoke 2/2 GREEN)
- `scripts/hooks/project-md-staleness-check.sh` (~115 LOC; 2-check; smoke 2/2 GREEN)
- `scripts/hooks/profile-template-auto-populate.sh` (~155 LOC; idempotent append; smoke 3/3 GREEN)
- `.claude/settings.json` Stop chain extended (+3 hook entries)

## Provenance chain

1. Phase 2.5 audit (2026-05-05) → DRC-1 root cause identified.
2. Plan 009-S48-harness-hardening-middle-phase.md § HH-C drafted (S48 main-session).
3. S48d shipped HH-C.1+2+3 hooks main-session per autonomous-full + L-S43f-2 LEAN brief.
4. Proposal `claude-md-session-end-extension-HH-C.4.md` drafted same turn.
5. AskUserQuestion 4-Q bundle (Q1=HH-C.4 + Q2=Q-S48c-1 + Q3=sync-027 + Q4=sync-036) →
   ACCEPT all 4.
6. CLAUDE.md edit applied; this ADR authored as ratifying record.

## Trade-offs accepted

| Concern | Acceptance rationale |
|---|---|
| **CLAUDE.md grows +4 lines (~50 tok)** | Tier 1 budget has 7.9K tok headroom; cost negligible. Codification value high. |
| **Step #6 enforcement is soft-warn only** | Per L-S11-1 portability + L-S45-2 caution: hard-block on first session-end after introduction = excessive. Soft-warn allows agent self-correction without blocking Stop chain. |
| **Steps #8 + #9 are auto-only** | Documented for awareness, not agent action. Avoids redundant manual work — hooks ARE the canonical enforcement. |

## Drift watch

- D9 charter md5: drift-signals.md changed (D-029 same turn); CLAUDE.md is NOT in `agent-workspace/constitution/` namespace (CLAUDE.md is project-root identity file, separate from constitution/).
- D-INTENT: ALIGNED (HH-C.4 = exact ACCEPTED option from user pick).
- DR-PROV: this ADR cites proposal + 3 companion hooks + audit observation.

## Companion handoff

S48 next critical path (S48e HH-D Mode-E charter promotion) MUST honor Rule 4b (D-026)
+ this Rule extension — both reference each other:
- Rule 4b: lesson-synthesis at session-end mandatory.
- HH-C.4 step #6: mistake-log update OR explicit "no mistakes" attestation.

Together they form the agent-side ritual; HH-C.1+2+3 hooks are the deterministic layer.

---

## Ratification record

User explicit ACCEPT via AskUserQuestion bundle (S48d turn 2026-05-05).
No amendments requested. CLAUDE.md edit shipped verbatim from proposal.
