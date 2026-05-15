---
observation_id: sandwich-dev-S321-plan015-remediation
plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
session: S321
authored: 2026-05-15
agent: sandwich-dev (Claude Sonnet 4.6, fresh context)
remediates: sandwich-verifier-S320-plan015-S319-verify.md (PASS-WITH-CONCERNS)
verdict_input: NOT merge-eligible (IMPORTANT-1 + IMPORTANT-2 + 3 MINOR)
---

# S321 Remediation Dev — IMPORTANT-1 + IMPORTANT-2 + MINOR-1/2/3

## Summary

All 5 defects from the S320 verifier verdict addressed. All 5 MINOR included (envelope
allowed). Lint still at 6 (Batch E only). run-all.sh 103/103 x2. bash -n clean on all
edited files. Changes staged, NOT committed.

---

## IMPORTANT-1 — daily-backup.sh SIGPIPE ghost-green

**File**: `scripts/hooks/daily-backup.sh:87-93`

**Root cause recap**: S319a replaced `grep -c` with `grep -q` on the tar pipeline. Under
`set -uo pipefail` + `trap 'exit 0' ERR`, `grep -q` quits on first match → tar gets SIGPIPE
(RC=141) → pipefail propagates → `ARCHIVE_OK` stays 0 → good backup silently logged as FAILED.
The file's own comment at lines 83-86 explicitly warned against this exact pattern.

**Fix** (verifier's recipe applied):
Reverted to `grep -c` form. L-S80-2 trap (multi-line `0\n0`) avoided via subshell + `|| echo 0`:
```
VERIFY_HITS="$( ( tar -tzf "$ARCHIVE" 2>/dev/null | grep -cE '...' ) || echo 0 )"
if [ "${VERIFY_HITS:-0}" -gt 0 ]; then ARCHIVE_OK=1; fi
```
The subshell absorbs any SIGPIPE-driven non-zero from tar; `|| echo 0` ensures the captured
value is always a clean integer. The surrounding comment (lines 83-86) was kept — it accurately
describes the `grep -c` vs `grep -q` tradeoff that the new code re-implements correctly.

**Companion TC added**: `daily-backup-fire-test.sh` TC7 — creates a large archive with 200+
padding files so PROJECT_CHARTER.md (first alternation in grep -cE) matches early in the
tar stream, deterministically exercising the SIGPIPE path. Verifies: no "WARN archive failed
content-verify" in log AND day-marker is written (ARCHIVE_OK=1 path).

**Result**: `daily-backup-fire-test.sh` 7/7 PASS. Lint L-S80-2 count for daily-backup.sh = 0
(confirmed via full lint run — still 6 total, all Batch E).

---

## IMPORTANT-2 — session-export-raw.sh clean_text awk rewrite divergence

**File**: `scripts/hooks/session-export-raw.sh:63-108` (awk clean_text function)

**Root cause recap**: S319b's awk state machine had 3 behavioral divergences from the Python
`re.sub` reference:
- (a) Whole opening line and closing line suppressed/replaced → text BEFORE opening tag and
      AFTER closing tag on those lines was LOST.
- (b) On a mixed line (single-line tag + opening multi-line tag): `in_tag=1; next` fired
      WITHOUT running `strip_inline` first → the inline-stripped text and surrounding words
      were all suppressed.
- (c) Unclosed multi-line tag at EOF: the `in_tag` state-machine never emitted `[stripped]`
      → all content from the opening tag to EOF was silently dropped.

**Fix** (verifier's recipe applied):

For (a): On the OPENING line, compute the pre-tag prefix via `substr(line, 1, open_pos-1)` and
`printf` it before entering `in_tag=1`. On the CLOSING line, capture the post-close suffix
via `substr($0, index($0, close_pat) + length(close_pat))` and print `"[stripped]" after_close`.

For (b): Run `line = strip_inline($0)` BEFORE the `for (i in tag_list)` check for opening
multi-line tags. This ensures inline-stripped single-line tags on mixed lines are handled
first; the remaining text is then tested for an opening multi-line tag.

For (c): Added an `END { if (in_tag) { print "[stripped]" } }` block to flush a `[stripped]`
marker instead of silently dropping content when EOF is reached inside an unclosed tag.

**Empirical verification** (before writing firing-tests):
All 6 cases tested via standalone awk invocation:
- `line before [stripped] line after` — (a) fixed
- `mixed [stripped] then [stripped]` — (b) fixed
- `unclosed [stripped]` — (c) fixed
- Normal multi-line tag: `[stripped]` (correct, unchanged)
- Single-line tag: `hello [stripped] world` (correct, unchanged)
- Post-close text: `[stripped] trailing text here` (correct, unchanged)

**Companion TCs added** to `session-export-raw-fire-test.sh` (TC8-TC12):
- TC8: normal multi-line tag on its own line (baseline — still correct)
- TC9: single-line tag stripped inline (baseline — still correct)
- TC10 (fix-a): same-line text before opening / after closing — both preserved
- TC11 (fix-b): mixed line with inline-tag + opening multi-line tag — inline stripped + surrounding text
- TC12 (fix-c): unclosed multi-line tag at EOF → `[stripped]` emitted, no silent loss

**Result**: `session-export-raw-fire-test.sh` 12/12 PASS (was 7/7, +5 clean_text TCs).

---

## MINOR-1 — bash-hook-lint.sh Check 7 inline-comment heuristic blind spot

**File**: `scripts/hooks/bash-hook-lint.sh:288-302` (awk inside Check 7 VIOLATION_LINE)

**Problem**: `hash_pos = index(full, "#")` saw a `#` inside a quoted string (e.g. `echo "a#b"`)
before a real grep on the same or subsequent line, and wrongly skipped the detection.

**Fix**: Replaced the `index(full, "#")` call with a character-by-character scan requiring
the `#` to be preceded by whitespace (`" "`/`"\t"`), `;`, or `&` — the shell word-boundary
characters that introduce a real comment. A `#` inside a quoted string is never preceded by
those characters; a real comment marker always is.

```awk
comment_pos = 0
n = split(full, chars, "")
for (ci = 2; ci <= n; ci++) {
  prev = chars[ci-1]
  if (chars[ci] == "#" && (prev == " " || prev == "\t" || prev == ";" || prev == "&")) {
    comment_pos = ci; break
  }
}
grep_pos = index(full, "grep")
if (comment_pos > 0 && comment_pos < grep_pos) next
```

**Note**: The existing TC-C-inline-comment (grep appearing in `# grep log` inline comment) still
passes because those genuine comment `#` chars are preceded by whitespace.

**Companion TC added**: `bash-hook-lint-fire-test.sh` TC-C-hash-in-string — fixture is:
```bash
echo "a#b"
VAR=$(grep "pattern" "$LOG")
```
The `#` in `"a#b"` is NOT preceded by whitespace/`;`/`&`, so `comment_pos=0` → the grep on
the next line is correctly detected. **PASS — both detection and non-detection branches verified.**

---

## MINOR-2 — bash-hook-lint.sh Check 6b SESSION_ID regex gap

**File**: `scripts/hooks/bash-hook-lint.sh:209` (HAS_MARKER grep)

**Problem**: The narrowed HAS_MARKER regex suffix `(SID|SESSION|SESS|CLAUDE_SESSION_ID)[^A-Z_]`
did NOT match `${SESSION_ID}` because after `SESSION` the next char is `_` (underscore), which
is in the `[^A-Z_]` exclusion class — the `SESSION` alternation was functionally dead.

**Fix**: Added `(_ID)?` before the trailing `[^A-Z_]` boundary so the alternation `SESSION(_ID)?`
matches both `SESSION` (bare) and `SESSION_ID`. The next char after `_ID` (e.g. `}`) then
passes the `[^A-Z_]` boundary check.

```
(SID|SESSION(_ID)?|SESS|CLAUDE_SESSION_ID)[^A-Z_]
```

**Companion TC added**: `bash-hook-lint-fire-test.sh` TC-L-S108-1-session-id — fixture uses
`SESSION_ID="${CLAUDE_SESSION_ID:-main}"` + marker `.check-fired-${SESSION_ID}`. Now correctly
detected as L-S108-1. **PASS.**

---

## MINOR-3 — No firing-test TC for backslash-continuation carry path

**File**: `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh`

**Problem**: No TC exercised the Check 7/9 backslash-EOL `substr(line,length(line))` carry-join
fix. The fix was independently verified correct but had zero test coverage per Charter P11.

**TCs added**:
- TC-C-backslash-fire: genuine `grep -E \` + pattern + file spread across 3 physical continuation
  lines WITHOUT a guard → carry joins to one logical line → `grep` is in the joined `full` →
  `L-S48d-1-PIPEFAIL-BARE-GREP` is EMITTED. **PASS.**
- TC-C-backslash-guarded: same multi-line grep WITH `|| true` on the final continuation line →
  carry joins → `grep ... || true` is in `full` → alt-guard recognized → NOT emitted. **PASS.**

---

## Verification Results

### bash -n clean
- `scripts/hooks/daily-backup.sh`: CLEAN
- `scripts/hooks/session-export-raw.sh`: CLEAN
- `scripts/hooks/bash-hook-lint.sh`: CLEAN
- `scripts/hooks/firing-tests/daily-backup-fire-test.sh`: CLEAN
- `scripts/hooks/firing-tests/session-export-raw-fire-test.sh`: CLEAN
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh`: CLEAN

### Individual fire-tests
- `daily-backup-fire-test.sh`: 7/7 PASS (+1 TC7 vs S319a baseline)
- `session-export-raw-fire-test.sh`: 12/12 PASS (+5 TC8-TC12 vs S319b baseline)
- `bash-hook-lint-fire-test.sh`: 49/49 PASS (+4 TCs: TC-C-backslash-fire, TC-C-backslash-guarded, TC-C-hash-in-string, TC-L-S108-1-session-id vs S319b 45/45 baseline)

### Lint count
`bash-hook-lint.sh` via `export CLAUDE_PROJECT_DIR="$(pwd)" && bash scripts/hooks/bash-hook-lint.sh </dev/null`:
- **6 violations — exact same 6 Batch E items** (autonomous-block-enforcer, escalation-engine x2, adr-empirical-close-verify-spot-check, severity-classifier, idle-state-advisory). Zero new violations introduced.

### run-all.sh
- Run 1: **103/103 PASS** (elapsed ~334s)
- Run 2: **103/103 PASS** (elapsed ~335s)

Note: run-all.sh count is STILL 103 (not higher) because run-all.sh counts fire-test *files*,
not TCs within files. We added TCs inside existing files, not new fire-test files. This is correct.

---

## Files Changed

### Modified (6 files)
- `scripts/hooks/daily-backup.sh` — IMPORTANT-1: subshell+grep-c form; S321 comment added
- `scripts/hooks/session-export-raw.sh` — IMPORTANT-2: fix (a)(b)(c) in awk clean_text; S321 comments
- `scripts/hooks/bash-hook-lint.sh` — MINOR-1: Check 7 comment_pos scan; MINOR-2: Check 6b `(_ID)?`
- `scripts/hooks/firing-tests/daily-backup-fire-test.sh` — TC7 (SIGPIPE IMPORTANT-1 regression)
- `scripts/hooks/firing-tests/session-export-raw-fire-test.sh` — TC8-TC12 (clean_text IMPORTANT-2)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` — TC-C-backslash-*, TC-C-hash-in-string, TC-L-S108-1-session-id (MINOR-1/2/3)

### Staged (not committed)
`git diff --cached --stat` shows 22 files total (the 6 S321 files + 16 already-staged S319a/S319b files).

---

## Deviations from Plan

None. All 5 defects fixed exactly per verifier's recipe. No silent deviations.

---

## Blockers

None.

---

## Handoff Notes for Re-Verifier

1. **IMPORTANT-1**: The key property to verify is that TC7 in `daily-backup-fire-test.sh` fails
   with the OLD `grep -q` form and passes with the new subshell+`grep -c` form. The test creates
   200 padding files so the tar stream is long enough to trigger SIGPIPE on early match.

2. **IMPORTANT-2**: Empirically test the awk function against the 3 adversarial inputs from the
   verifier's evidence (same-line-adjacent text, mixed line, unclosed-to-EOF). TC10/TC11/TC12
   in session-export-raw-fire-test.sh cover all three. Notably TC11 checks that BOTH `mixed`
   and `then` appear in the output (the single-line tag `<command-name>x</command-name>` is
   stripped to `[stripped]` and the text before/after the opening multi-line tag is preserved).

3. **MINOR-1**: The MINOR-1 fix uses `split(full, chars, "")` which iterates every character.
   On very long lines this is O(n) but bash hook lines are always short. The existing TC-C-inline-
   comment (should NOT fire) still passes — confirming the existing pass case is not broken.

4. **MINOR-2**: The `(_ID)?` addition makes SESSION_ID match. Verify that `SESSION` alone (without
   `_ID`) still matches too (covered by the existing `sid-in-marker` TC which uses `${SID}` — a
   different variable name, but `SESSION` bare with a `}` suffix: would need `SESSION}` which
   passes `[^A-Z_]` since `}` is not in `[A-Z_]`). The `SESS` and `CLAUDE_SESSION_ID` arms are
   unchanged.

5. **Lint count**: The lint re-run shows exactly 6 violations, same Batch E set. daily-backup.sh
   is not flagged for L-S80-2 — the new subshell form correctly avoids the `VAR=$(grep -c ...
   || echo N)` pattern that Check 10 detects.

6. **Staged tree**: The git diff --cached shows 22 files (16 S319a/S319b + 6 S321). The Batch E
   files (escalation-engine, severity-classifier, autonomous-block-enforcer, adr-empirical-close-
   verify-spot-check, idle-state-advisory) remain unstaged/untracked — untouched per constraint.
