# S322a STOP-and-ask — Provenance Clarification Required [RESOLVED 2026-05-15 10:05]

**level: RESOLVED**
**status: resolved**
**created**: 2026-05-15
**resolved_at**: 2026-05-15T10:05+07:00
**session**: S322a (sandwich-dev, plan 016)
**stop-item**: Plan § STOP-and-ask items #2 + additional edge case

> **RESOLUTION**: User answered both provenance questions via AskUserQuestion (S321 follow-up turn 2026-05-15): (Q1=A) `severity-classifier.sh` + `adr-empirical-close-verify-spot-check.sh` belong to S317 — folded into the S317 commit alongside `autonomous-block-enforcer.sh` + `escalation-engine.sh` + their fire-tests + `block-control.sh` pair. (Q2=A) The 6 untracked non-S318 files split into separate S317 (block-control pair) + S255 (rotate-hooks pair) commits per session attribution. The 3 untangle commits shipped: `9923c49` (S318 idempotent-notification, 19 files), `40012ed` (S317 block-mechanism + harness hygiene, 8 files), `5d9e5f2` (S255 urgent-md-rotate + session-hooks-log-rotate, 4 files). Working tree `scripts/` now carries only the 2 untracked `idle-state-advisory` files (saved for the upcoming Batch E commit 4). Lint stable at 6 (Batch E target, unchanged); `run-all.sh` 103/103 confirmed post-untangle. S322b dispatched to apply the Batch E lint 6→0 fixes.

---

S322a STEP 0 pre-flight completed. A STOP-and-ask condition was triggered. S322a is pausing before Commit 1. S322b is NOT dispatched. This notification details what was found and what requires user input.

---

## STEP 0 Results (for reference)

- **Lint count**: 6 violations (confirmed, matches plan table exactly)
- **run-all.sh baseline**: 103/103 PASS
- **Tracked-dirty scripts/ files**: 25
- **Untracked scripts/ files**: 8

---

## STOP Trigger A — STEP 0.4: Two dirty Batch E hooks have no explicit session-log attribution

**Files**: `scripts/hooks/severity-classifier.sh` and `scripts/hooks/adr-empirical-close-verify-spot-check.sh`

**Finding**: These two files have working-tree changes that are NOT listed in any session's "Files touched" deliverable summary. The S320 checkpoint flagged them as "2 unattributed changes, no session log" — STEP 0.4 confirms this.

### `severity-classifier.sh` diff summary

The diff removes `.autonomous-BLOCKED` from the Layer 1 CRITICAL markers (with the justification "self-perpetuating deadlock") and replaces the Layer 5 body-text keyword grep with frontmatter `level:` field classification.

- These changes are *thematically* consistent with S317's block-mechanism redesign.
- However, `severity-classifier.sh` is NOT listed in the S317-close checkpoint's "MODIFIED" files (`autonomous-block-enforcer.sh` and `escalation-engine.sh` are; `severity-classifier.sh` is not).
- There is no session log entry that claims these changes.

**Question for user**: Were the `severity-classifier.sh` changes made during S317 (block mechanism redesign), or during some other session? Which commit boundary do they belong to?

### `adr-empirical-close-verify-spot-check.sh` diff summary

The diff fixes the JSON hook schema emitted on divergence detection — removes `hookSpecificOutput` (not valid for Stop hooks) and replaces it with top-level `systemMessage` (valid), using `node` for safe JSON encoding with plain stderr fallback.

- This is a standalone bug fix to JSON schema compliance.
- It is NOT traceable to S317, S318, or any other documented session via the session logs or checkpoints.

**Question for user**: When was this `adr-empirical-close-verify-spot-check.sh` fix made, and which commit boundary does it belong to?

**Impact**: Per plan § STOP-and-ask item #2, the files with attributable changes (`autonomous-block-enforcer.sh`, `escalation-engine.sh`) CAN proceed to a commit boundary once user confirms. The two flagged files must wait for user attribution.

---

## STOP Trigger B — STEP 0.3: Six untracked scripts/ files with non-S318 session attribution

The following untracked files have session-log attribution but are NOT S318 work and do NOT fit class-C, class-E, or the "genuinely unattributed class-U" definitions. They need a user-designated commit boundary:

| File | Attribution | Status |
|---|---|---|
| `scripts/hooks/block-control.sh` | S317-close checkpoint (explicit "NEW" deliverable) | Untracked |
| `scripts/hooks/firing-tests/block-control-fire-test.sh` | S317-close checkpoint (explicit "NEW 11/11 PASS") | Untracked |
| `scripts/hooks/session-hooks-log-rotate.sh` | S255 mistake-log entry ("session-hooks-log-rotate.sh NEW Stop hook size-trigger 2MB") | Untracked |
| `scripts/hooks/firing-tests/session-hooks-log-rotate-fire-test.sh` | S255 (companion firing-test) | Untracked |
| `scripts/hooks/urgent-md-rotate.sh` | S255 mistake-log entry ("urgent-md-rotate.sh NEW Stop hook size-trigger 4KB") | Untracked |
| `scripts/hooks/firing-tests/urgent-md-rotate-fire-test.sh` | S255 (companion firing-test) | Untracked |

These files have been RUNNING (confirmed in `.session-hooks.log`) but were never committed.

**Note**: These are NOT class-U (they have attribution). But they also cannot go into Commit 1 (that commit is scoped to S318 idempotent-notification work only; folding S317/S255 files in would mislabel provenance). They need their own commit boundary(ies).

**Question for user**: Should these be committed as:
- (a) A separate "S317: block-control.sh" commit + a separate "S255: session-hooks-log-rotate + urgent-md-rotate" commit?
- (b) A single "S317+S255: uncommitted hook work" commit?
- (c) Folded into the Batch E Commit 3 (since they're all untracked files and Commit 3 already covers idle-state-advisory pair)?
- (d) Some other boundary?

---

## What CAN proceed without user input

The following files have clean attribution and would go into Commit 1 (S318 idempotent-notification work):

**Class-C (S318 production hooks — 10 files):**
- `essential-routing-fields-verifier.sh`, `file-pattern-hook-pre-flight-lint.sh`, `guardian-output-inspect-first.sh`, `learning-index-rebuild.sh`, `learning-loop-metric-check.sh`, `pre-checkpoint-close-verifier.sh`, `python-determinism-check.sh`, `research-scanner-output-validator.sh`, `session-start-scan-unattested-observations.sh`, `working-memory-budget-audit.sh`

**Class-C (S318 firing-tests — 9 files):**
- `essential-routing-fields-verifier-fire-test.sh`, `file-pattern-hook-pre-flight-lint-fire-test.sh`, `guardian-output-inspect-first-fire-test.sh`, `learning-index-rebuild-fire-test.sh`, `learning-loop-metric-check-fire-test.sh`, `pre-checkpoint-close-verifier-fire-test.sh`, `research-scanner-output-validator-fire-test.sh`, `session-start-scan-unattested-observations-fire-test.sh`, `working-memory-budget-audit-fire-test.sh`

**BUT**: Committing these class-C files alone will NOT make all 4 Batch E hooks clean. After Commit 1 (class-C only), the status will be:
- `autonomous-block-enforcer.sh` — still dirty (S317 work, will wait for user answer on Trigger A's resolution path)
- `escalation-engine.sh` — still dirty (S317 work, same)
- `severity-classifier.sh` — still dirty (unattributed per Trigger A)
- `adr-empirical-close-verify-spot-check.sh` — still dirty (unattributed per Trigger A)

Therefore S322a is PAUSING before Commit 1 pending user answers to both triggers. S322b (Batch E lint fixes) cannot proceed until the Batch E hooks are clean.

---

## Recommended user actions

1. For `severity-classifier.sh`: confirm which session made those changes (S317, or some other session). Answer: "severity-classifier changes belong to S317 (or: S___)" or "I don't know — treat as unattributed."

2. For `adr-empirical-close-verify-spot-check.sh`: same — identify which session, or authorize treating it as a standalone "harness cleanup" commit.

3. For the 6 untracked non-S318/non-E files: pick a commit shape (a)/(b)/(c)/(d) from Trigger B above.

Once these answers are received, S322a (or a resumption dispatch) can complete Commit 1 + any additional commit(s) authorized, then hand off to S322b.

---

*S322a (sandwich-dev) — plan 016 — STEP 0 complete, Commit 1 PAUSED pending this notification.*
