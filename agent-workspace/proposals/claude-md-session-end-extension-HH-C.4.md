---
status: ACCEPTED
ratified_at: 2026-05-05
ratified_via: AskUserQuestion S48d 4-Q bundle Q1=ACCEPT
ratifying_adr: D-028
proposal_id: HH-C.4
created_at: 2026-05-05
created_via: S48d main-session opus47-max (Phase 2.5 HH-C ritual codification)
target_file: CLAUDE.md (root, always-loaded Tier 1)
binding_charter_clauses:
  - decision-discipline.md Rule 4b (D-026) — lesson-synthesis mandatory at session-end
  - 009-S48-harness-hardening-middle-phase.md § HH-C — Continuous-loop ritual codification
ratification_path: USER-GATE via AskUserQuestion (CLAUDE.md is always-loaded; charter-tier blast radius)
companion_hooks_shipped_S48d:
  - scripts/hooks/session-end-checklist-linter.sh (HH-C.1; soft-warns on missing mistake-log mention)
  - scripts/hooks/project-md-staleness-check.sh (HH-C.2; soft-warns on Phase Goals Tracker drift)
  - scripts/hooks/profile-template-auto-populate.sh (HH-C.3; auto-appends sample to profile cards)
---

# CLAUDE.md § Session End ritual extension (HH-C.4)

## Why this proposal exists

Phase 2.5 audit (2026-05-05; `observations/2026-05-05-harness-alignment-audit.md`) surfaced
DRC-1 "Continuous-obligation gap" — agent inconsistently completes session-end ritual.
HH-C deliverables S48d ship 3 deterministic Stop-hook watchdogs (HH-C.1+2+3) that emit
soft-warnings when the ritual is missed. This proposal codifies the agent-side counterpart:
extend CLAUDE.md § Session End checklist from 5 → 9 explicit steps so the watchdogs have
a documented expectation to enforce.

The 4 NEW steps (#6 mistake-log / #7 staleness check / #8 auto profile-template / #9 auto
promote-rule) are NOT new behaviors — they're already partially observed in past sessions
ad-hoc. Codifying makes them deterministic-checkable.

## Current CLAUDE.md § Session End (5 steps; line 50-55)

```markdown
### End
1. Update `agent-workspace/memory/project.md` (if architectural decisions made)
2. Write `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`
3. Update `agent-workspace/memory/current-execution.md` (status, next session)
4. If learned rule emerged → append to `agent-workspace/memory/agent-notes.md`
5. If thesis logged this session → ensure entry in `agent-workspace/memory/thesis-log/`
```

## Proposed CLAUDE.md § Session End (9 steps; +4 new)

```markdown
### End
1. Update `agent-workspace/memory/project.md` (if architectural decisions made)
2. Write `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`
3. Update `agent-workspace/memory/current-execution.md` (status, next session)
4. If learned rule emerged → append to `agent-workspace/memory/agent-notes.md`
5. If thesis logged this session → ensure entry in `agent-workspace/memory/thesis-log/`
6. Update `agent-workspace/memory/mistake-log.md` with new M-S<N>-<M> entries OR explicitly
   state "no mistakes this session" in the session log (enforced by `session-end-checklist-linter.sh`)
7. If a NEW ADR landed this session → verify `project.md` Phase Goals Tracker still matches
   `current-execution.md` Active Focus Track Phase status (enforced by `project-md-staleness-check.sh`)
8. (auto) Stop-hook `profile-template-auto-populate.sh` appends a sample row to the matching
   `agent-workspace/memory/self-awareness/profiles/<model>-<effort>-<task_class>.md` card
9. (auto) Stop-hook `promotion-cycle-trigger.sh` HARD-BLOCKs at next SessionStart if ≥8 new
   lessons accumulated since last `promote-rule` dispatch — schedule a promote-rule subagent
   dispatch in the next session if blocked
```

## Rationale per step

- **#6 mistake-log**: Rule 4b (D-026) requires lesson-synthesis at session-end; mistake-log
  is the structured failure catalog half of that rule. Without explicit attestation, sessions
  with 0 mistakes are indistinguishable from sessions where the agent forgot to check.
- **#7 project.md staleness**: project.md "Recent Architectural Decisions" must reflect
  every NEW ADR within 2h or it falls out of sync with current-execution.md (which IS
  always-current). Detected by HH-C.2 hook with 2h tolerance.
- **#8 profile-template (auto)**: Documents that this is now an automated step — agent
  doesn't need to manually update profile cards; just write session log with proper
  frontmatter (`type:` or `**Type**:` + optional `agent: ... (claude-<model>)`) and the
  hook handles append.
- **#9 promote-rule (auto)**: Documents that promotion-cycle-trigger.sh is the deterministic
  gate; agent doesn't need to track delta manually but should be aware of the HARD-BLOCK
  semantic (next session blocked at SessionStart until promote-rule dispatched).

## Blast radius

- CLAUDE.md is always-loaded Tier 1 (`tier1-bloat-check.sh` measures it).
- Adds ~12 lines (~50 tokens at conservative 4 byte/tok) — well within Tier 1 budget.
- Affects EVERY future session — agent applies new steps immediately on next session start.
- Reversible via single Edit if undesired.

## Ratification paths

| Pick | Action | Effect |
|---|---|---|
| **A: ACCEPT (Recommended)** | Edit CLAUDE.md lines 50-55 → replace with 9-step block above | Codifies HH-C.4; closes Phase 2.5 HH-C track |
| **B: AMEND** | User specifies which steps to keep/drop/reword | Re-draft proposal next session |
| **C: REJECT** | Leave CLAUDE.md as-is; rely on watchdog hook warnings only | Hooks remain operational but no documented expectation |

## Companion artifacts shipped this session (S48d)

- `scripts/hooks/session-end-checklist-linter.sh` (~85 LOC; soft-warn; smoke 2/2 GREEN)
- `scripts/hooks/project-md-staleness-check.sh` (~115 LOC; 2-check; smoke 2/2 GREEN)
- `scripts/hooks/profile-template-auto-populate.sh` (~150 LOC; idempotent; smoke 3/3 GREEN)
- `.claude/settings.json` Stop chain extended (3 NEW hooks wired)

## Out of scope (this proposal does NOT)

- Modify any constitution/ file (all 4 NEW steps reference existing files only).
- Add new hook scripts beyond the 3 shipped this session.
- Change the existing 5 steps (steps 1-5 stay verbatim).
- Auto-trigger promote-rule subagent (the hook only HARD-BLOCKs at SessionStart; agent decides dispatch).
