# S201 — MAJOR REFRAME #2: S200 checkpoint's "3 hook bug classes" partially misdiagnosed; 1 real bug + 1 lint regex bug fixed; 2 framings retired

**Created**: 2026-05-09 (S201 entry; ~10:47-10:53)
**Predecessor**: S200 close (D-049 H-g.1 REJECTED + chain-truncation framing FALSIFIED + 3 "bug classes" identified)
**Type**: VERIFY+IMPL hybrid; cheap-by-RISK 8th instance
**Outcome**: 2 of 3 S200 bug-class framings RETIRED as misdiagnosis; 1 real bug fixed (HH-1 empty-SID); 1 NEW bug found in lint Check 6b regex (false-positive on the L-S108-1 fix itself)

## TL;DR — applied L-S200-1 to S200's own output

S200 close lesson **L-S200-1** (just minted): "When deterministic Guardian emits hypothesized root cause, agent MUST inspect Guardian output + lint-flagged files BEFORE launching ≥2nd hypothesis cycle on same symptom."

S201 entry **applied L-S200-1 to S200's own checkpoint** by re-reading the affected files VERBATIM before any code change. Result: 2 of the 3 "bug classes" S200 identified turn out to be misdiagnoses based on wrong detection signals; the actual bash-hook-lint Guardian itself has a false-positive regex bug (Check 6b) that flagged the L-S108-1 FIX as if it were the L-S108-1 BUG. Meta-lesson: even Guardians need calibration; "Guardian-first" doctrine still requires verifying the Guardian's claim against the ground-truth code.

## Re-classification of S200's "3 bug classes"

### Bug Class 1 (effort-escalation MIS-WIRED) — RETIRED (misdiagnosis)

**S200 framing**: `effort-escalation-detector.sh:34` guard `HOOK_EVENT=PreToolUse && TOOL_NAME=Agent` → MIS-WIRED to UserPromptSubmit → always early-exits.

**S201 verification (read source verbatim)**:
- Line 33-34: `[ "${HOOK_EVENT:-}" = "UserPromptSubmit" ] || { [ "${HOOK_EVENT:-}" = "PreToolUse" ] && [ "${TOOL_NAME:-}" = "Agent" ]; } || exit 0`
- Guard reads as: pass IF `HOOK_EVENT=UserPromptSubmit` OR `(HOOK_EVENT=PreToolUse AND TOOL_NAME=Agent)`. Hook IS designed for both events.
- Settings.json line 458: hook ALSO already registered as `PreToolUse` matcher `.*`. So both event paths covered.
- Hook never writes to `.effort-escalation.log` (only stderr at line 108). The "log MISSING" detection signal in S187..S200 observations was WRONG — the file is never created by design.

**Verdict**: NO BUG. S200's "log MISSING = silent" detection signal was invalid. No fix needed.

### Bug Class 2 (idle-escape + phase-coherence L-S108-1 lockout) — RETIRED (misdiagnosis)

**S200 framing**: bash-hook-lint flags `${CLAUDE_SESSION_ID:-WORD}` fallback-to-constant + marker filename per-session lockout.

**S201 verification**:
- `idle-escape-detector.sh` lines 36-38: `BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"; [ -z "$BUCKET" ] && BUCKET="unbucketed-$$"; MARKER="...-fired-${BUCKET}"` — date-hour-bucket fix ALREADY PRESENT (per S108 prevention rule).
- `phase-status-coherence.sh` lines 39-41: identical pattern; date-hour-bucket fix ALREADY PRESENT.
- `project-md-adr-staleness.sh` lines 37-39: identical pattern; date-hour-bucket fix ALREADY PRESENT.
- All 3 hooks ALREADY apply L-S108-1 prevention correctly.

**Real bug found**: `bash-hook-lint.sh` Check 6b at line 192 has overly broad regex `\.[a-zA-Z0-9_-]+-(fired|marker|ran|flag|written|pending)-\$\{?[A-Z_]` which matches `${BUCKET}` (and any `[A-Z_]`-prefixed variable) — flagging the L-S108-1 SAFE pattern as if it were the BUG. This is a Guardian false-positive that misled S200 (and S187..S199 by extension since this lint output had been emitting since S195).

**Fix applied (S201 IMPL)**: Edit `bash-hook-lint.sh` Check 6b to whitelist `BUCKET`-token marker filenames:
```bash
HAS_MARKER="$(grep -nE '\.[a-zA-Z0-9_-]+-(fired|...)-\$\{?[A-Z_]' "$f" 2>/dev/null \
              | grep -vE "^[[:space:]]*[0-9]+:[[:space:]]*#" \
              | grep -vE '\$\{?[A-Z_]*BUCKET[A-Z_]*\}?' \    # NEW S201
              || true)"
```

**Post-fix verification**:
- bash -n OK
- bash-hook-lint run on full hooks/ tree: 23 violations → **20 violations** (3 L-S108-1 false positives eliminated for idle-escape, phase-coherence, project-md-adr-staleness).
- Notification file `human-workspace/notifications/20260509-035209-bash-hook-lint-warn.md` confirmed: ZERO L-S108-1 entries (only the static fix-suggestion footer mentions L-S108-1).

### Bug Class 3 (harness-health HH-1 empty-SID) — REAL bug, FIXED

**S200 framing** (correct): `harness-health-self-scan.sh:56-57` — `grep -n "SessionStart session=$SID"` fails when `CLAUDE_SESSION_ID` empty (Windows quirk → SID="unknown" via fallback) → `start_line` empty → `emit_skip "HH-1" "no-SessionStart-for-SID"` always fires → HH-1 dormant.

**S201 verification**:
- `.session-hooks.log` confirms `[2026-05-09T10:47:17+07:00] SessionStart session=` (empty SID literal) in real prod.
- HH-1 has been silent-skipping every run since CLAUDE_SESSION_ID env became empty on Windows.

**Fix applied (S201 IMPL)**: Edit `harness-health-self-scan.sh` HH1_check to handle empty/unknown SID by matching the latest `SessionStart session=` line regardless of SID, and matching `Stop session=` similarly. ~16 LOC change.

**Post-fix verification**:
- bash -n OK
- Firing-test `harness-health-self-scan-fire-test.sh`: **7/7 PASS** (smoke + HH-7 stale + HH-11 frozen + GREEN + cache-hit-skip).

## Files edited

1. `scripts/hooks/harness-health-self-scan.sh` — HH1_check empty-SID branch (~+16 LOC; replaces 3 LOC)
2. `scripts/hooks/bash-hook-lint.sh` — Check 6b BUCKET-token whitelist (~+5 LOC; replaces 1 LOC)

## Verification stack (S201 IMPL)

| Check | Result |
|---|---|
| bash -n harness-health-self-scan.sh | PASS |
| bash -n bash-hook-lint.sh | PASS |
| Lint run before S201 fix | 23 violations (3 L-S108-1 false positives) |
| Lint run after S201 fix | 20 violations (0 L-S108-1) |
| harness-health firing test | 7/7 PASS |
| L-S108-1 entries in latest lint notification | 0 (footer help-string only) |

## Hypothesis stack post-S201

- D-047 H-d.1 REJECTED-1OF1-BINARY (S197) — registration-count not cap mechanism
- D-048 H-f REJECTED-1OF1-BINARY (S198) — stdout-bytes/content not cap mechanism
- D-049 H-g.1 REJECTED-1OF1-BINARY (S200) — chain-position not cap mechanism
- **S200 "3 bug classes" RECLASSIFIED (S201)**: 2 misdiagnoses + 1 real bug + 1 lint regex false-positive. 1 real bug FIXED (HH-1). Lint false-positive FIXED (Check 6b BUCKET whitelist).

**Chain-truncation root cause: STILL UNKNOWN**. But further investigation is OUTRANKED by: (a) it's not actively blocking any product/harness work other than HH-1 which we just fixed independently; (b) cheapest-by-RISK exhausted across H-c/H-a/H-e/H-d.1/H-d.2/H-f/H-g.1; (c) AP-24 sustains: don't run more hypothesis cycles when Guardian signal already gave us actionable bugs; (d) real bugs identified above are higher-leverage than the chain-position phantom.

## New lesson candidates

**L-S201-1**: "Guardian (lint/static-analysis) outputs MUST be verified against ground-truth code before acting. Even Guardians have false-positive regex bugs. The L-S200-1 doctrine 'inspect Guardian before LLM hypothesis cycle' must be paired with 'inspect ACTUAL CODE before acting on Guardian claim'."

**L-S201-2**: "Detection signals (file-existence checks for log/marker files) MUST be verified by reading the producing script. S187..S200 spent ~13 hypothesis cycles on a `.effort-escalation.log MISSING` signal without verifying the producing script never writes that file. Auto-detect: if observation grep mentions `.<hook>.log MISSING`, MUST grep the hook script for matching write site BEFORE classifying as `SILENT`."

**Promotion target priority** (per Q-E3): hook FIRST. Both L-S201-1 + L-S201-2 → check-N additions to bash-hook-lint.sh (or detection-signal pre-validator hook). To be promoted in next promote-rule cycle (already overdue per AP-23).

## Hard rules binding sustained (S201)

ALL prior bindings (L-S176-1 + L-S174-1 + L-S65 + Phase 3.5 §HH-G + verify_phase_before_next_phase + harness_priority_one + autonomous_continue_no_self_pause + Charter Principle 8). NEW L-S200-1 candidate APPLIED in this S201 entry (didn't blindly follow checkpoint). NEW L-S201-1 + L-S201-2 candidates surfaced.

## No git commits / 0 charter file edits / 0 constitution writes

S201 = 2 hook code edits + 4 doc edits (this observation + session log + current-execution.md prepend + checkpoint refresh).
