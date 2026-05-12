---
decision_id: D-047
title: PROJECT_CHARTER.md v1.0 → v1.1 ratified — Principle 11 (Harness must self-verify firing) inserted
status: ratified
created_at: 2026-05-09
created_via: S220 main-session opus47-max bundled deny-lift cycle
ratification_basis:
  - D-034 (S173 charter v1.1 proposal authored; Q2=A user approval same turn)
  - Charter Revision Protocol § "48-hour cool-down" — elapsed S173 (2026-05-07) → S219/S220 (2026-05-09) = 2 days
  - S219 AskUserQuestion re-confirmation Q2=A (no semantic delta from S173)
  - S220 AskUserQuestion deny-lift mode = A (agent temp-lift + land + restore same-turn)
related_decisions:
  - D-033 (T5 harness-health-protocol.md authored — promoted to constitution/ same S220 turn; see D-048)
  - D-034 (T8 charter v1.1 proposal — this ratifies)
  - D-035 (T6 harness-health-self-scan.sh hook — operationalizes Principle 11)
  - L-S208-1 portability rule — promoted to constitution/portability.md same S220 turn (see D-049)
artifacts_modified:
  - PROJECT_CHARTER.md (version bump v1.0→v1.1 + revision history line + Principle 11 inserted between P10 and § Four-Tier Signal Architecture)
  - agent-workspace/memory/.charter-md5-baseline (rebaselined to d77f59db666d54cdd2f167b59e92ff69)
  - .claude/settings.json (4 deny lines temp-lifted then restored within same turn)
---

## Why ratified

S173 charter user-gate Q2=A user-approved Principle 11 verbatim wording + version bump v1.0→v1.1 + 48hr cool-down acknowledgment. Cool-down (2 days minimum) elapsed S173 → S219/S220 (2 days). S219 re-confirmation AskUserQuestion landed identical Q2=A (no drift). S220 single-Q deny-lift AskUserQuestion = A approved agent temp-lift mechanism.

## Mechanism (S220 turn)

1. Pre-flight: cool-down verify (`date -d 2026-05-09 - date -d 2026-05-07 = 2 days >= 2`). PASS.
2. Set ratify marker: `touch agent-workspace/memory/.charter-ratify-active-${SID}` (HH-8 charter-md5 signal authorized to PASS).
3. Edit `.claude/settings.json` deny block: prefix `_S220_TEMP_LIFTED_` to 4 entries (Write+Edit for PROJECT_CHARTER.md and constitution/**). Edit not denied (settings.json itself only blocks `Edit(.claude/settings.json)` allow-listed via line 81).
4. Edit `PROJECT_CHARTER.md` Status line — add v1.1 + revision history.
5. Edit `PROJECT_CHARTER.md` Core Principles section — insert Principle 11 between P10 and § Four-Tier Signal Architecture (verbatim per D-034 proposal § 2).
6. mv `agent-workspace/proposals/harness-health-protocol.md` → `agent-workspace/constitution/harness-health-protocol.md` (D-048).
7. mv `agent-workspace/proposals/charter-L-S208-1-settings-portability.md` → `agent-workspace/constitution/portability.md` (D-049).
8. Restore `.claude/settings.json` deny block — strip `_S220_TEMP_LIFTED_` prefixes; deny restored to baseline.
9. Rebaseline charter md5: `md5sum PROJECT_CHARTER.md > .charter-md5-baseline` = d77f59db666d54cdd2f167b59e92ff69.
10. Author this ADR + D-048 + D-049.

## Empirical close-verify

- `head -8 PROJECT_CHARTER.md` shows "Status: Immutable v1.1" + revision history line ✓
- `grep ^11\\. PROJECT_CHARTER.md` returns Principle 11 verbatim ✓
- `.claude/settings.json` deny block grep: 0 occurrences of `_S220_TEMP_LIFTED_` (restored) ✓
- `agent-workspace/constitution/harness-health-protocol.md` exists (23 KB) ✓
- `agent-workspace/constitution/portability.md` exists (7 KB) ✓
- `agent-workspace/proposals/{harness-health-protocol.md,charter-L-S208-1-settings-portability.md}` no longer exist ✓
- `.charter-md5-baseline` updated post-edit ✓

## Consequences

- Phase 3.5 T8 charter promotion COMPLETE.
- All future hooks must ship with companion firing-test (charter-binding rule).
- `harness-health-self-scan.sh` (T6/D-035) signal set now charter-anchored via Principle 11 reference.
- Constitution layer now contains: harness-health-protocol.md (signal catalog), portability.md (settings.json portability rule).
- M-S173-1 deny-rule continues to bind for FUTURE constitution writes (this ratification was a one-time bundled deny-lift; deny restored same-turn).
- Charter Revision Protocol next minor bump = v1.2 (or v2.0 for principle deletion/inversion).
