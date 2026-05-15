# S322a Dev Observation — Plan 016 STEP 0 Inventory + Commit 1 (PAUSED)

**Session**: S322a
**Plan**: `agent-workspace/session-plans/pending/016-S322-batch-e-untangle-and-lint-zero.md`
**Subagent type**: sandwich-dev
**Date**: 2026-05-15
**Outcome**: STOP-and-ask triggered — Commit 1 PAUSED

---

## STEP 0.1 — Lint Scan

Regenerated: `CLAUDE_PROJECT_DIR="$(pwd)" bash scripts/hooks/bash-hook-lint.sh`

**Result: 6 violations — matches plan table exactly.**

| # | File | Class |
|---|---|---|
| 1 | `autonomous-block-enforcer.sh` | L-S43b-9 printf-dash |
| 2 | `escalation-engine.sh` | L-S43b-9 printf-dash |
| 3 | `escalation-engine.sh` | L-S48d-1 pipefail-bare-grep |
| 4 | `adr-empirical-close-verify-spot-check.sh` | L-S48d-1 pipefail-bare-grep |
| 5 | `severity-classifier.sh` | L-S48d-1 pipefail-bare-grep |
| 6 | `idle-state-advisory.sh` | L-S80-2 grep-c-capture-trap |

---

## STEP 0.2 — run-all.sh Baseline

**Result: 103/103 PASS** (run twice, both confirmed).

Run 1: `=== firing-test suite: 103/103 PASS (elapsed 307s) ===`
Run 2: `=== firing-test suite: 103/103 PASS (elapsed 304s) ===`

---

## STEP 0.3 — scripts/ Inventory Classification

### Tracked-dirty files (25 total)

| File | Class | Attribution |
|---|---|---|
| `scripts/hooks/adr-empirical-close-verify-spot-check.sh` | E (Batch E host) | Unattributed (STOP trigger A) |
| `scripts/hooks/autonomous-block-enforcer.sh` | E (Batch E host) | S317 (explicit in S317-close checkpoint) |
| `scripts/hooks/escalation-engine.sh` | E (Batch E host) | S317 (explicit in S317-close checkpoint) |
| `scripts/hooks/essential-routing-fields-verifier.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/file-pattern-hook-pre-flight-lint.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/firing-tests/autonomous-block-enforcer-fire-test.sh` | E (Batch E companion) | S317 ("UPDATED: autonomous-block-enforcer-fire-test.sh 13/13") |
| `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` | E (Batch E companion) | S317 ("UPDATED: escalation-engine-fire-test.sh 10/10") |
| `scripts/hooks/firing-tests/essential-routing-fields-verifier-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/file-pattern-hook-pre-flight-lint-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/guardian-output-inspect-first-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/learning-index-rebuild-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/learning-loop-metric-check-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/pre-checkpoint-close-verifier-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/research-scanner-output-validator-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/session-start-scan-unattested-observations-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/firing-tests/working-memory-budget-audit-fire-test.sh` | C (S318) | S318 "9 firing-tests updated" list |
| `scripts/hooks/guardian-output-inspect-first.sh` | C (S318) | S318 "Files touched" list ("1 consumer hook fixed") |
| `scripts/hooks/learning-index-rebuild.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/learning-loop-metric-check.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/pre-checkpoint-close-verifier.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/python-determinism-check.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/research-scanner-output-validator.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/session-start-scan-unattested-observations.sh` | C (S318) | S318 "Files touched" list |
| `scripts/hooks/severity-classifier.sh` | E (Batch E host) | Unattributed (STOP trigger A) |
| `scripts/hooks/working-memory-budget-audit.sh` | C (S318) | S318 "Files touched" list |

**Class-C count**: 19 files (10 production hooks + 9 firing-tests)
**Class-E count**: 6 files (4 dirty Batch E hooks + 2 companion firing-tests)

Note: `bash-hook-lint.sh` is in the S318 touched list but is NOT in git status --short (it was committed in da02ad0 as part of S321).

### Untracked files (8 total)

| File | Status | Attribution |
|---|---|---|
| `scripts/hooks/block-control.sh` | Non-E, non-C, HAS session attribution (S317) | S317-close checkpoint explicit "NEW" deliverable |
| `scripts/hooks/firing-tests/block-control-fire-test.sh` | Non-E, non-C, HAS session attribution (S317) | S317-close checkpoint "NEW 11/11 PASS" |
| `scripts/hooks/firing-tests/idle-state-advisory-fire-test.sh` | E (Batch E companion, untracked) | Plan 015/016 Batch E definition |
| `scripts/hooks/firing-tests/session-hooks-log-rotate-fire-test.sh` | Non-E, non-C, HAS session attribution (S255) | S255 mistake-log ("session-hooks-log-rotate.sh NEW Stop hook size-trigger 2MB") |
| `scripts/hooks/firing-tests/urgent-md-rotate-fire-test.sh` | Non-E, non-C, HAS session attribution (S255) | S255 mistake-log ("urgent-md-rotate.sh NEW Stop hook size-trigger 4KB") |
| `scripts/hooks/idle-state-advisory.sh` | E (Batch E lint host, untracked) | Plan 015/016 Batch E definition; confirmed ACTIVE in hook-registry.tsv |
| `scripts/hooks/session-hooks-log-rotate.sh` | Non-E, non-C, HAS session attribution (S255) | S255 mistake-log |
| `scripts/hooks/urgent-md-rotate.sh` | Non-E, non-C, HAS session attribution (S255) | S255 mistake-log |

**Note on S255/S317 untracked files**: These are NOT class-U (they have session-log attribution). But they are NOT class-C (not S318 work) and cannot go into Commit 1 without mislabeling provenance. They need a separate commit boundary. This is STOP trigger B.

---

## STEP 0.4 — Diff-Region Attribution for 4 Dirty Batch E Hooks

### `autonomous-block-enforcer.sh` — ATTRIBUTION: S317, CLEAN

All hunks trace to S317-close checkpoint § "MODIFIED: autonomous-block-enforcer.sh":
- Added ESCAPE HATCH for Bash calls invoking `block-control.sh`
- Separated Bash from other guarded tools into its own case branch
- Updated messaging to reference block-control.sh clear path
- Added `STDIN_JSON` capture for Bash escape-hatch detection

S317-close checkpoint explicitly lists this as a modified deliverable. **ATTRIBUTABLE — S317.**

### `escalation-engine.sh` — ATTRIBUTION: S317, CLEAN

All hunks trace to S317-close checkpoint § "MODIFIED: escalation-engine.sh":
- Added `.block-grace` suppression logic (anti-deadlock — grace window after clear)
- Added `HIGH_QA_ROWS` split (only Q&A bundles warrant AskUserQuestion, not notifications)
- Updated messaging to reference block-control.sh

S317-close checkpoint explicitly lists this as a modified deliverable. **ATTRIBUTABLE — S317.**

### `severity-classifier.sh` — ATTRIBUTION: UNCLEAR (STOP trigger A)

Hunks:
1. Removes `.autonomous-BLOCKED` from Layer 1 CRITICAL markers with comment about "self-perpetuating deadlock". Thematically consistent with S317 block redesign, but `severity-classifier.sh` is NOT listed in S317-close checkpoint's modified files.
2. Layer 5 classification changed from body-text keyword grep to frontmatter `level:` field priority, with body-grep as fallback for legacy files.

Neither hunk appears in any session's "Files touched" list. S320 checkpoint explicitly flagged this as "unattributed, no session log." **NOT ATTRIBUTABLE — STOP-and-ask required.**

### `adr-empirical-close-verify-spot-check.sh` — ATTRIBUTION: UNCLEAR (STOP trigger A)

One hunk: fixes the JSON hook schema for Stop event — removes `hookSpecificOutput` (invalid for Stop), replaces with top-level `systemMessage` using `node` for JSON encoding with stderr fallback.

This is a standalone bug fix to Claude Code hook schema compliance. It does not appear in any session's "Files touched" list. S320 checkpoint flagged it as "unattributed, no session log." **NOT ATTRIBUTABLE — STOP-and-ask required.**

---

## STEP 0.5 — Out-of-scope files confirmation

The following will NOT be staged or committed by this plan:
- `.claude/settings.json` — modified (D-060 commit-policy change + other changes), out of scope
- `CLAUDE.md` — modified, out of scope
- `agent-workspace/CLAUDE.md` — modified, out of scope
- `agent-workspace/memory/**` — large churn, out of scope

Confirmed: S322a/S322b commit ONLY `scripts/` paths with explicit `git add scripts/hooks/<file>`.

---

## STOP-and-Ask Triggers Hit

### Trigger A — STEP 0.4 unattributable hunks in 2 of the 4 dirty Batch E hooks

Per plan § STOP-and-ask item #2:
- `severity-classifier.sh`: changes are NOT in any session's "Files touched" list despite being thematically S317-related.
- `adr-empirical-close-verify-spot-check.sh`: hook schema fix NOT in any session's "Files touched" list.

**Action**: Notification written to `human-workspace/notifications/S322a-stop-and-ask-provenance.md`. User must identify which session owns these changes or authorize a standalone attribution.

### Trigger B — STEP 0.3 six untracked files with non-S318 session attribution need a commit boundary

S317 work (`block-control.sh` + `block-control-fire-test.sh`) and S255 work (`session-hooks-log-rotate.sh`, `urgent-md-rotate.sh` + their fire-tests) are untracked but session-attributed. They cannot go into Commit 1 (wrong provenance). User must designate commit boundaries.

**Action**: Included in the same STOP-and-ask notification.

---

## Commit 1 Status

**PAUSED — not created.**

The 19 class-C files (S318 work) could be committed as Commit 1 without awaiting user input (they are fully attributable). However, because the Batch E hooks would still be dirty after Commit 1 (two of them carry unattributed hunks), the post-commit verification criterion would immediately fail ("git status -- scripts/ shows the 4 tracked Batch E hooks are now CLEAN"). This means S322a's DoD cannot be met with Commit 1 alone.

Therefore S322a is pausing BEFORE creating Commit 1, pending the STOP-and-ask resolution.

The cleanly-attributable files (class-C) are ready to stage whenever user provides answers.

---

## Post-commit git status -- scripts/ (projected if Commit 1 were created)

If Commit 1 were created with class-C only:
- `autonomous-block-enforcer.sh`: STILL DIRTY (S317 work not in Commit 1)
- `escalation-engine.sh`: STILL DIRTY (S317 work not in Commit 1)
- `severity-classifier.sh`: STILL DIRTY (unattributed)
- `adr-empirical-close-verify-spot-check.sh`: STILL DIRTY (unattributed)

All 4 Batch E hooks would remain dirty — this is the condition that would trigger plan STOP-and-ask #3 (post-commit a Batch E hook is still dirty). S322a is correctly halting before Commit 1 rather than creating it and then tripping STOP #3.

---

## Summary

| Item | Result |
|---|---|
| Lint count | 6 (confirmed, matches plan) |
| run-all.sh baseline | 103/103 (×2) |
| STOP-and-ask triggered | YES — items A (unattributed hunks) + B (6 untracked non-S318/E files) |
| Commit 1 created | NO — paused pending STOP-and-ask resolution |
| Commit 1 SHA | N/A |
| Notification written | `human-workspace/notifications/S322a-stop-and-ask-provenance.md` |
| Files staged | NONE |
| S322b dispatched | NO — blocked until STOP-and-ask resolved |

End of S322a observation.
