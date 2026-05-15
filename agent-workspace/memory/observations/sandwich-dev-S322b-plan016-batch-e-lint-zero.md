---
agent: sandwich-dev
session: S322b
plan: 016-S322-batch-e-untangle-and-lint-zero.md
scope: Batch E lint fixes 6 → 0 + commit
date: 2026-05-15
commit: 49fe2ca
---

# Sandwich-Dev S322b: Batch E Lint 6 → 0 — Observation File

## Pre-flight Results

1. `git log --oneline -5`: HEAD=`5d9e5f2` confirmed; 4 expected commits in history (da02ad0, 9923c49, 40012ed, 5d9e5f2). PASS.
2. `git status --short -- scripts/`: ONLY 2 untracked files: `idle-state-advisory.sh` + `idle-state-advisory-fire-test.sh`. No dirty tracked files. PASS.
3. Lint re-run: 6 violations confirmed, file list matches plan table. PASS.
4. Baseline run-all.sh: 103/103 PASS. PASS.

## Per-Fix Triage Decisions

### Fix 1 — L-S43b-9 REAL: autonomous-block-enforcer.sh:48

**File:line**: `autonomous-block-enforcer.sh:48`
**Evidence**: `printf '--- Flag content (verbatim) ---\n'` — format string starts with `---` (three dashes). Check 4 pattern `grep -nE "printf[[:space:]]+['"]-"` matches; no `printf --` sentinel present.
**Triage**: REAL — genuine unguarded shell printf with leading-dash format string.
**Fix**: Added `--` sentinel: `printf -- '--- Flag content (verbatim) ---\n'`
**Verification**: `bash -n` SYNTAX OK; `autonomous-block-enforcer-fire-test.sh` 13/13 PASS; lint 6→5.

---

### Fix 2 — L-S43b-9 DETECTOR-GAP: escalation-engine.sh:133,152

**File:line**: `escalation-engine.sh:133` and `:152`
**Evidence**: Both lines have `printf '%s\n' "$ROWS" | awk -F'\t' '{printf "- `%s` ...}'`. The `printf "- ..."` inside the awk script is AWK's builtin printf, not shell's. Check 4's regex `printf[[:space:]]+['"]-` matched the awk-context printf inside the single-quoted awk script string.
**Triage**: DETECTOR FALSE POSITIVE — awk's printf doesn't need the `--` sentinel; the AWK runtime doesn't interpret `-` as an option flag in the same way as bash's `printf`.
**Fix**: Refined Check 4 in `bash-hook-lint.sh` — added third filter: `grep -vE "\{printf"` to exclude lines where printf appears after `{` (awk-script opening brace). Added comment explaining the S322 calibration.
**Dual-property TC**: Added to `bash-hook-lint-fire-test.sh`:
  - `TC-S43b9-awk-fp`: `awk -F'\t' '{printf "- ..."}` → NOT flagged (FP suppressed)
  - `TC-S43b9-shell-real`: shell `printf '----- separator -----\n'` without `--` → STILL flagged (genuine fires)
**Verification**: `bash -n` SYNTAX OK on lint; `bash-hook-lint-fire-test.sh` 51/51 PASS; lint 5→4.

---

### Fix 3 — L-S48d-1 REAL: escalation-engine.sh:72-74,84

**File:line**: `escalation-engine.sh:72` (awk found first; 73, 74, 84 same pattern)
**Evidence**: Check 7 awk found line 72: `CRIT_N=$([ -z "$CRIT_ROWS" ] && echo 0 || printf '%s\n' "$CRIT_ROWS" | grep -c .)`. Under `set -uo pipefail` + `trap 'exit 0' ERR`, `grep -c .` at end of pipeline with no alt-guard. The `||` preceding the pipeline arm applies to the ternary shortcircuit, not to guard the grep. The lint (which only reports first match per file) showed line 72; lines 73, 74, 84 are the same pattern.
**Triage**: REAL — `grep -c .` exits 1 when there are 0 matching lines; under pipefail + ERR trap, this causes silent script exit.
**Fix**: Replaced `grep -c .` with `wc -l | tr -d '[:space:]'` — `wc -l` always exits 0.
**Verification**: `bash -n` SYNTAX OK; `escalation-engine-fire-test.sh` 10/10 PASS; lint 4→3.

---

### Fix 4 — L-S48d-1 REAL: adr-empirical-close-verify-spot-check.sh:80

**File:line**: `adr-empirical-close-verify-spot-check.sh:80`
**Evidence**: Check 7 awk found: `PROBE_TOKEN="$(echo "$PATTERN" | grep -oE '[A-Za-z_]{5,}' | awk ...)"`. The `grep -oE` returns exit 1 when the pattern has no 5+ char alphabetic token. Under pipefail, the command substitution's pipeline fails → ERR trap fires → silent exit.
**Triage**: REAL — `grep -oE` will exit 1 on patterns with no long alphabetic tokens (e.g. pure-regex ADR claim patterns like `\s+`, `\\b`).
**Fix**: Wrapped grep with brace guard: `{ grep -oE '[A-Za-z_]{5,}' 2>/dev/null || true; }` — the group always exits 0, pipeline proceeds to awk (empty stdin → awk outputs empty string → `PROBE_TOKEN` is empty → `[ -z "$PROBE_TOKEN" ] && continue` skips the claim safely).
**Verification**: `bash -n` SYNTAX OK; `adr-empirical-close-verify-spot-check-fire-test.sh` 5/5 PASS; lint 3→2.

---

### Fix 5 — L-S48d-1 DETECTOR-GAP: severity-classifier.sh:143-147 + REAL at :212-215

**File:line (FP)**: `severity-classifier.sh:143` (joined via backslash continuation to 147)
**Evidence**: Lines 143-153 form a `( tail | grep | grep-v | head | while ) || true` subshell-guard block. The Check 7 awk joins lines 143-147 via backslash continuation, stops at line 147 (`do` — no `\`), then processes the joined line which contains `grep`. The awk does NOT see the `|| true` on line 153 (a separate non-continuation-joined closing line). The L-S48d-1 flag was thus a false positive.
**Triage**: DETECTOR FALSE POSITIVE — the `( ... ) || true` multi-line subshell-guard pattern protects all greps inside the subshell; Check 7 awk doesn't track `()` depth across non-continuation lines.
**Fix**: Added skip rule to Check 7 awk: `if (full ~ /^[[:space:]]*\(/) next` — a logical line (possibly multi-continuation joined) starting with `(` indicates a subshell-guard opening; skip it.
**Dual-property TC**: Added to `bash-hook-lint-fire-test.sh`:
  - `TC-C-subshell-guard`: `( grep ...\n | ... ) || true` multi-line block → NOT flagged
  - `TC-C-subshell-real`: bare `grep` outside subshell → STILL flagged

**Hidden REAL violation revealed**: After the FP at 143-147 was suppressed, Check 7 found `severity-classifier.sh:212-215` — `CRIT_N=$(grep "^CRITICAL" "$STATE_FILE" 2>/dev/null | wc -l | tr -d ' \n')`. The `grep | wc -l` pipeline: `grep` exits 1 on no-match under pipefail → ERR trap fires. (Prior to the FP-fix, the awk's `exit` statement stopped at line 143 and never reached 212.)
**Fix for :212-215**: `{ grep "^CRITICAL/HIGH/MEDIUM/LOW" ... || true; } | wc -l | tr -d ' \n'` brace guard.
**Verification**: `bash -n` SYNTAX OK; `severity-classifier-fire-test.sh` 5/5 PASS; `bash-hook-lint-fire-test.sh` 53/53 PASS; lint 2→1 (then 1→0 after Fix 6).

---

### Fix 6 — L-S80-2 REAL: idle-state-advisory.sh:135

**File:line**: `idle-state-advisory.sh:135`
**Evidence**: `QG_OPEN=$(printf '%s\n' "$QG_MATCHES" | grep -c . 2>/dev/null || echo 0)`. Matches L-S80-2 pattern: `=$(... grep -c ... || echo 0)` inside command substitution. The `grep -c .` exits 1 on empty content; `|| echo 0` then fires → captured value is `"0\n0"` multi-line string, breaking the `[[ "$QG_OPEN" =~ ^[0-9]+$ ]]` guard below.
**Triage**: REAL — although `set +o pipefail` is in effect (line 65), the L-S80-2 check fires regardless of pipefail state (it's a pattern-level check on the `$(grep -c ... || echo N)` anti-pattern).
**Fix**: `QG_OPEN=$(printf '%s\n' "$QG_MATCHES" | wc -l | tr -d '[:space:]')` — `wc -l` always exits 0, no `|| echo` needed. `QG_MATCHES` is non-empty here (inside `if [ -n "$QG_MATCHES" ]`), so wc -l returns the correct count.
**idle-state-advisory.sh is UNTRACKED** — committed together with `idle-state-advisory-fire-test.sh` per Charter Principle 11.
**Verification**: `bash -n` SYNTAX OK; `idle-state-advisory-fire-test.sh` 5/5 PASS; lint 1→0.

---

## Verification Results

| Check | Result |
|---|---|
| bash -n all edited files | SYNTAX OK |
| autonomous-block-enforcer-fire-test | 13/13 PASS |
| escalation-engine-fire-test | 10/10 PASS |
| adr-empirical-close-verify-spot-check-fire-test | 5/5 PASS |
| severity-classifier-fire-test | 5/5 PASS |
| idle-state-advisory-fire-test | 5/5 PASS |
| bash-hook-lint-fire-test | 53/53 PASS (added 4 new TCs) |
| Final lint | 0 violations |
| bash-hook-lint-warn.md | AUTO-DELETED (confirmed) |
| run-all.sh x1 | 103/103 PASS |
| run-all.sh x2 | 103/103 PASS |

## Commit

**SHA**: `49fe2ca`
**Title**: S322 Batch E: bash-hook-lint 6 → 0 (parent plan 015 final batch)
**Files**: 8 files in `scripts/` only — 6 modified + 2 new (idle-state-advisory pair)
**NOT pushed** — D-060 compliant.

## Triage Tally

| Class | Count | Detail |
|---|---|---|
| REAL | 4 | autonomous-block-enforcer:48, escalation-engine:72-84, adr-empirical-close:80, severity-classifier:212-215 (hidden REAL) |
| DETECTOR-GAP | 2 | escalation-engine:133/152 (awk-context printf), severity-classifier:143-147 (subshell-guard join gap) |
| Detector refinements | 2 | Check 4 (`\{printf` filter), Check 7 (`^[[:space:]]*\(` skip rule) |
| New dual-property TCs | 4 | TC-S43b9-awk-fp, TC-S43b9-shell-real, TC-C-subshell-guard, TC-C-subshell-real |

## Notable Finding

The severity-classifier.sh FP (lines 143-147) concealed a REAL violation at lines 212-215. The Check 7 awk exits on first match per file, so only the first violation is reported. The fix correctly exposed and resolved the hidden violation. This is a property of the lint architecture (single-violation-per-file-per-check), not a defect — the verifier should confirm both that the FP is resolved AND the hidden REAL was fixed.

## Deviations from Plan

- Plan listed severity-classifier.sh L-S48d-1 as a suspected DETECTOR-GAP (lines 143-153). Confirmed DETECTOR-GAP at 143-147. However, revealed a REAL violation at 212-215 (same file, same check). Fixed both per plan's "REAL = fix the grep" instruction.
- The severity-classifier.sh fix count was effectively 2 distinct violations (FP suppressed + hidden REAL fixed), though the lint counted only 1 violation attributed to the file. This is an expansion beyond the original 6-count but is the correct behavior — ghost-green would have been leaving the hidden REAL at 212.

## Handoff Notes for Verifier (S322-verify)

1. Run `CLAUDE_PROJECT_DIR="$(pwd)" bash scripts/hooks/bash-hook-lint.sh </dev/null` — confirm 0 violations, no warn file.
2. Confirm `human-workspace/notifications/bash-hook-lint-warn.md` does NOT exist.
3. Run `bash scripts/hooks/firing-tests/run-all.sh` — confirm 103/103.
4. `git show --stat 49fe2ca` — confirm only `scripts/` files, 8 files total.
5. Adversarially probe ghost-green risk: verify that:
   - `autonomous-block-enforcer.sh:48` is now `printf -- '---` (not just `printf '---`)
   - `escalation-engine.sh:72-74,84` use `wc -l | tr -d` not `grep -c .`
   - `adr-empirical-close-verify-spot-check.sh:80` has `{ grep ... || true; }` brace guard
   - `severity-classifier.sh:212-215` has `{ grep ... || true; }` guards
   - `idle-state-advisory.sh:135` uses `wc -l | tr -d` not `grep -c . || echo 0`
6. Confirm the Check 4 + Check 7 detector calibrations: run `bash-hook-lint-fire-test.sh` and verify 53/53. Pay attention to TC-S43b9-awk-fp (should NOT fire) + TC-C-subshell-guard (should NOT fire) — these are the FP-suppression assertions.
7. The hidden REAL at severity-classifier.sh:212-215: verify `grep "^CRITICAL"` is wrapped with `{ ... || true; }`, not just left as bare grep.
8. Nothing was pushed (D-060).
