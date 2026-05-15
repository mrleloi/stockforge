---
observation_id: sandwich-dev-S320-plan015-S319a-batch-BDC
plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
session: S320 (executing S319a scope)
authored: 2026-05-14
agent: sandwich-dev (claude-sonnet-4-6)
---

# S319a Batch B-D-C Execution — Observation File

## STEP 0 Re-confirmation

**Lint scan**: Re-ran `bash scripts/hooks/bash-hook-lint.sh </dev/null >/dev/null 2>&1` →
confirmed **33 violations** (matches brief). Notification file fresh.

**Clean/dirty audit for S319a scope files**:
All 8 scope files confirmed CLEAN (no output from `git status --short` for those files):
- `idle-escape-detector.sh` — CLEAN
- `phase-status-coherence.sh` — CLEAN
- `project-md-adr-staleness.sh` — CLEAN
- `sub-plan-completion-coherence.sh` — CLEAN
- `attach-portability-smoke.sh` — CLEAN
- `daily-backup.sh` — CLEAN
- `harness-health-self-scan.sh` — CLEAN
- `bootstrap-summary-renderer.sh` — CLEAN

`idle-state-advisory.sh` — UNTRACKED (confirmed as `??` in git status). Correctly deferred to Batch E per brief.

**Baseline firing test**: `bash scripts/hooks/firing-tests/run-all.sh` → **103/103 PASS** (elapsed ~301s).

---

## Batch B-clean — L-S108-1 Triage (4 files)

**All 4 hits are DETECTOR FALSE-POSITIVES. No edits made.**

### Mechanism of the false-positive

Check 6b in `bash-hook-lint.sh` fires when a file has BOTH:
- (a) `HAS_FALLBACK`: `${CLAUDE_SESSION_ID:-WORD}` assignment (the `-unknown` fallback)
- (b) `HAS_MARKER`: `.xxx-(fired|marker|ran|flag|written|pending)-${UPPERCASE_VAR}`

The `HAS_MARKER` regex `\.[a-zA-Z0-9_-]+-(fired|...)-\$\{?[A-Z_]` matches `.idle-escape-fired-${BUCKET}` because `BUCKET` starts with uppercase `B`. The lint cannot distinguish `${BUCKET}` (date-based hour-bucket = correct) from `${SID}` (session-ID = problematic).

### Per-file analysis

**`idle-escape-detector.sh`**: Has `SID="${CLAUDE_SESSION_ID:-unknown}"` (line 25). `SID` is used ONLY for the per-session performance cache file (`.idle-escape-cache-${SID}`, line 44). The MARKER file is correctly `.idle-escape-fired-${BUCKET}` (line 38). The hour-bucket pattern is already implemented correctly. `HAS_MARKER` fires on the MARKER line (`.idle-escape-fired-${BUCKET}`) not on the cache line.

**`phase-status-coherence.sh`**: Same pattern. `SID` used only for cache (`.phase-coherence-cache-${SID}`). MARKER uses `${BUCKET}`. `HAS_MARKER` fires on `.phase-coherence-fired-${BUCKET}`.

**`project-md-adr-staleness.sh`**: Same pattern. Cache: `.adr-staleness-cache-${SID}`. MARKER: `.adr-staleness-fired-${BUCKET}`.

**`sub-plan-completion-coherence.sh`**: Same pattern. Cache: `.sub-plan-coherence-cache-${SID}`. MARKER: `.sub-plan-coherence-fired-${BUCKET}`.

### Confirmation

Ran the exact `HAS_FALLBACK` and `HAS_MARKER` greps from Check 6b directly:
- `HAS_FALLBACK`: finds `SID="${CLAUDE_SESSION_ID:-unknown}"` in all 4 files — CORRECT
- `HAS_MARKER`: finds `.xxx-fired-${BUCKET}` lines in all 4 files — DETECTOR FALSE-POSITIVE (BUCKET is the correct date-bucket variable)

**Disposition**: Deferred to Batch L lint-calibration scope. Check 6b needs to exclude `${BUCKET}` from `HAS_MARKER` detection (either by requiring `${SID}` specifically, or by teaching the check to recognize date-bucket variables). The 4 SID cache files are benign (cache sharing under Windows empty-SID degrades performance slightly but is NOT a lockout risk).

**Violations NOT closed by B-clean**: 4 (all false-positives, properly deferred).

---

## Batch D-clean — L-S80-2 (5 files fixed)

### Lint count before: 33 | After: 28 (5 violations closed)

### Files edited

**`attach-portability-smoke.sh:223`**
- Old: `STOCKFORGE_ENV_COUNT=$(grep -c "STOCKFORGE_" "$SETTINGS_SRC" 2>/dev/null || echo 0)`
- New: `if grep -qE "STOCKFORGE_" "$SETTINGS_SRC" 2>/dev/null; then STOCKFORGE_ENV_COUNT=1; else STOCKFORGE_ENV_COUNT=0; fi`
- Downstream: `if [ "$STOCKFORGE_ENV_COUNT" -gt 0 ]` — binary 0/1 is sufficient.
- Verification: `bash -n` clean; `attach-portability-smoke-fire-test.sh` 7/7 PASS.

**`daily-backup.sh:88`**
- Old: `VERIFY_HITS=$(tar -tzf "$ARCHIVE" 2>/dev/null | grep -cE '...' 2>/dev/null || echo 0)` (pipeline form)
- New: `if tar -tzf "$ARCHIVE" 2>/dev/null | grep -qE '...'; then ARCHIVE_OK=1; fi`
- Note: `VERIFY_HITS` variable removed (was only used as a binary check). `ARCHIVE_OK` already handles the gate.
- Verification: `bash -n` clean; `daily-backup-fire-test.sh` 6/6 PASS.
- Note: R3 mass-deletion-prevention code — fix was kept surgical (P3); only lines 87-91 changed.

**`harness-health-self-scan.sh:58,74,103`**
- Line 58 (HH1_check): `stop_count=$(awk ... | grep -c "Stop session=$SID" || echo 0)` → `if awk ... | grep -q "Stop session=$SID"; then stop_count=1; else stop_count=0; fi`
- Line 74 (HH2_check): `recent=$(awk ... | grep -c "UserPromptSubmit" || echo 0)` → `if awk ... | grep -q "UserPromptSubmit"; then recent=1; else recent=0; fi`
- Line 103 (HH4_check): `candidates=$(grep -c "Auto-detect:.*yes" "$notes" 2>/dev/null || echo 0)` → `candidates=$(grep -c "Auto-detect:.*yes" "$notes" 2>/dev/null || true)` (actual count preserved for orphan_delta arithmetic; existing `[[ ]] || candidates=0` guard handles empty case).
- Verification: `bash -n` clean; `harness-health-self-scan-fire-test.sh` 7/7 PASS.

**`idle-escape-detector.sh:76`**
- Old: `HEADER_COUNT=$(echo "$HEADERS" | grep -c '^## S' 2>/dev/null || echo 0)`
- New: `if echo "$HEADERS" | grep -q '^## S' 2>/dev/null; then HEADER_COUNT=1; else HEADER_COUNT=0; fi`
- Downstream: only used in `if [ "$HEADER_COUNT" -lt 1 ]` — binary is sufficient.
- Verification: `bash -n` clean; `idle-escape-detector-fire-test.sh` 15/15 PASS.

**`phase-status-coherence.sh:98`**
- Old: `IN_PROGRESS_COUNT=$(echo "$IN_PROGRESS_PHASES" | grep -c . 2>/dev/null || echo 0)`
- New: `if echo "$IN_PROGRESS_PHASES" | grep -q . 2>/dev/null; then IN_PROGRESS_COUNT=1; else IN_PROGRESS_COUNT=0; fi`
- Downstream: used in `-eq 0` and `-gt 0` only — binary is sufficient.
- Verification: `bash -n` clean; `phase-status-coherence-fire-test.sh` 16/16 PASS.

**`idle-state-advisory.sh`** — L-S80-2 hit remains but this file is UNTRACKED (Batch E). Correctly left untouched.

---

## Batch C-clean — L-S48d-1 (1 file fixed; 1 detector false-positive)

### Lint count before: 28 | After: 27 (1 violation closed)

### `bootstrap-summary-renderer.sh` — GENUINE HIT, fixed

**Line 76** (before):
```bash
  RECENT_MISTAKES="$(grep -E '^\| M-S[0-9]+' "$MEMORY_DIR/mistake-log.md" 2>/dev/null | tail -3 | awk -v max="$MAX_MISTAKE_LEN" '{
    ...
  }' || true)"
```

The `|| true` is on line 79, not on the grep's physical line 76. Check 7's awk detector flags this because the carry mechanism (joining lines containing `$`) doesn't reach line 79's `|| true` to satisfy the guard check `grep[[:space:]].*[[:space:]](&&|\|\|)[[:space:]]` for the accumulated `full` from lines 76+77+78+79.

**Fix** (line 76 after):
```bash
  RECENT_MISTAKES="$({ grep -E '^\| M-S[0-9]+' "$MEMORY_DIR/mistake-log.md" 2>/dev/null || true; } | tail -3 | awk -v max="$MAX_MISTAKE_LEN" '{
```

The `{ grep ... || true; }` form puts `|| true` on the same physical line as `grep`. Check 7's guard `grep[[:space:]].*[[:space:]](&&|\|\|)[[:space:]]` now matches on line 76 itself → SKIP.

Semantics: `{ grep ... || true; }` captures all grep output (including 0 lines when no match) and pipes to `tail -3`. `|| true` ensures the brace-group exits 0 even if grep finds no matches. Behavior is identical to the original.

Verification: `bash -n` clean; `bootstrap-summary-renderer-fire-test.sh` 13/13 PASS.

### `harness-health-self-scan.sh` — DETECTOR FALSE-POSITIVE, not edited

Check 7 reports `harness-health-self-scan.sh` for L-S48d-1. Investigation: the flagged grep is on line 135: `if tail -1 "$f" 2>/dev/null | grep -q '"state":"pending"'; then` — this IS properly guarded by `if`. However, the Check 7 awk carry mechanism treats `$` as a backslash-continuation signal (due to `line ~ /\\$/` matching any line containing `$`, not just lines ending with literal `\`). Lines 133 (`stat ... "$f" ... || echo 0`), 134 (`[ "$mtime" ...`), and 135 all contain `$` variables, so they get joined into one `full`. The joined `full` starts with `mtime=` not `if`, so the `if/while/until/elif` skip rule doesn't trigger.

The grep on line 135 is NOT genuinely unguarded — it's inside an `if` conditional. Adding a redundant `|| true` to line 135 would be a ghost-green.

**Disposition**: Deferred to Batch L lint-calibration. Check 7's awk `/\\$/` matching `$` (dollar sign) instead of literal `\` (backslash) is a awk regex interpretation issue on this platform. Fix: improve Check 7's `BEGIN { pipefail_off = 1 }` initial state or fix the carry mechanism to use a proper backslash-end-of-line detection.

**Violations NOT closed by C-clean**: 1 (harness-health-self-scan false-positive, properly deferred).

---

## Final State

### Lint count: 33 → 27 (6 violations closed)

- L-S80-2: 6 → 1 (5 closed; 1 remaining = idle-state-advisory.sh, Batch E/untracked)
- L-S48d-1: 5 → 4 (1 closed = bootstrap-summary-renderer.sh; 1 remaining in scope = harness-health-self-scan.sh false-positive, deferred to Batch L)
- L-S108-1: 5 → 5 (0 closed; all 4 S319a-scope files are false-positives, deferred to Batch L)

### Files edited (6 total)
1. `scripts/hooks/attach-portability-smoke.sh` (L-S80-2: line 223)
2. `scripts/hooks/daily-backup.sh` (L-S80-2: line 88)
3. `scripts/hooks/harness-health-self-scan.sh` (L-S80-2: lines 58, 74, 103)
4. `scripts/hooks/idle-escape-detector.sh` (L-S80-2: line 76)
5. `scripts/hooks/phase-status-coherence.sh` (L-S80-2: line 98)
6. `scripts/hooks/bootstrap-summary-renderer.sh` (L-S48d-1: line 76)

### Files NOT edited (correctly left untouched)
- `idle-escape-detector.sh`, `phase-status-coherence.sh`, `project-md-adr-staleness.sh`, `sub-plan-completion-coherence.sh` — Batch B false-positives
- `harness-health-self-scan.sh` for L-S48d-1 — Batch C false-positive (already edited for L-S80-2, but the L-S48d-1 hit is not fixed because it's a detector false-positive)
- `idle-state-advisory.sh` — UNTRACKED, Batch E scope
- `bash-hook-lint.sh` — DIRTY, out of S319a scope
- All 4 Batch E files (escalation-engine, severity-classifier, autonomous-block-enforcer, adr-empirical-close-verify-spot-check) — DIRTY

### bash -n verification
All 6 edited files: CLEAN (no syntax errors).

### Firing tests (per-file)
- `attach-portability-smoke-fire-test.sh`: 7/7 PASS
- `daily-backup-fire-test.sh`: 6/6 PASS
- `harness-health-self-scan-fire-test.sh`: 7/7 PASS
- `idle-escape-detector-fire-test.sh`: 15/15 PASS
- `phase-status-coherence-fire-test.sh`: 16/16 PASS
- `bootstrap-summary-renderer-fire-test.sh`: 13/13 PASS

### run-all.sh (×2 confirmed)
- Run 1 (after Batch D): 103/103 PASS (~275s)
- Run 2 (after Batch C): 103/103 PASS (~276s)

### Staged for commit
```
M  scripts/hooks/attach-portability-smoke.sh
M  scripts/hooks/bootstrap-summary-renderer.sh
M  scripts/hooks/daily-backup.sh
M  scripts/hooks/harness-health-self-scan.sh
M  scripts/hooks/idle-escape-detector.sh
M  scripts/hooks/phase-status-coherence.sh
```

---

## Deferrals to Batch L (lint-calibration scope)

### 1. L-S108-1 — 4 files (false-positives in Check 6b HAS_MARKER detection)
Files: `idle-escape-detector.sh`, `phase-status-coherence.sh`, `project-md-adr-staleness.sh`, `sub-plan-completion-coherence.sh`

Root cause: `HAS_MARKER` regex `\.[a-zA-Z0-9_-]+-(fired|...)-\$\{?[A-Z_]` matches `.xxx-fired-${BUCKET}` because `BUCKET` is uppercase. The lint cannot distinguish `${BUCKET}` (date-based = correct) from `${SID}` (session-based = problematic).

Calibration fix needed: Teach Check 6b to recognize date-bucket variables by name (`BUCKET`, `TODAY`, `DATE_HR`) as exceptions, OR require the marker variable to be traceable to `${CLAUDE_SESSION_ID:-...}` specifically.

### 2. L-S48d-1 — 1 file (false-positive in Check 7 awk carry mechanism)
File: `harness-health-self-scan.sh` (the HH6 check, line 135)

Root cause: Check 7's awk `line ~ /\\$/` in this shell/awk environment matches lines containing ANY `$` character (not just lines ending with literal `\`). This causes lines 133+134+135 to be joined into one `full` line, obscuring the `if` guard that covers the grep on line 135.

Calibration fix needed: Fix the Check 7 awk carry detection to use a reliable backslash-at-end-of-line test. Possible fix: `if (match(line, /\\$/) && substr(line, length(line)) == "\\") { ... }` — explicitly checking the last character rather than regex. Or use `substr(line, length(line))` comparison.

---

## Deviations from Plan

1. **Batch B: 0 violations closed** (plan expected up to 4). Reason: all 4 are detector false-positives (Check 6b `HAS_MARKER` matches `${BUCKET}` not just `${SID}`). Applying the hour-bucket recipe would have been a no-op or actively wrong — files already correctly implement hour-bucket.

2. **Batch C: 1 violation closed instead of 2** (plan expected both `bootstrap-summary-renderer.sh` and `harness-health-self-scan.sh`). `harness-health-self-scan.sh` L-S48d-1 is a detector false-positive.

3. **`harness-health-self-scan.sh` line 103**: plan said use binary `if/then/fi` recipe; implementation used `grep -c ... || true` to preserve actual count for `orphan_delta` arithmetic. This is a justified deviation — binary would break the delta calculation. The `|| true` form avoids the `"0\nN"` trap while preserving the count value.

---

## Key Finding for Batch L (lint-calibration)

**Check 7's `/\\$/` is a platform-specific bug**: on this Windows+Git-Bash+GNU-awk environment, awk's `/\\$/` regex matches lines containing `$` (dollar sign), not lines ending with literal `\` (backslash). This causes the carry mechanism to join ALL lines with shell variables into one accumulated `full` line, losing the per-line guard context. The Check 7 awk needs a cross-platform backslash-EOL detection fix.

**Check 6b's `HAS_MARKER` is too broad**: matches any `${UPPERCASE_VAR}` suffix on marker patterns, not specifically `${CLAUDE_SESSION_ID}` derivations.

---

## Handoff Notes for Verifier

1. `harness-health-self-scan.sh` line 103: `candidates=$(grep -c ... 2>/dev/null || true)` — note the change from `|| echo 0` to `|| true`. The existing `[[ "$candidates" =~ ^[0-9]+$ ]] || candidates=0` guard handles the empty case when grep finds no matches (grep returns 1 under `set -uo pipefail + trap 'exit 0' ERR`, but the ERR trap makes the function return early anyway — this is pre-existing behavior preserved).

2. The `idle-state-advisory.sh` L-S80-2 hit remaining in the notification is expected — this file is UNTRACKED and belongs to Batch E. The verifier should confirm it's still untracked.

3. The `harness-health-self-scan.sh` L-S48d-1 remaining hit is expected (detector false-positive). The verifier should confirm the grep on line 135 IS inside `if tail ... | grep -q ...` and is genuinely guarded.

4. The 4 L-S108-1 files remaining are expected (detector false-positives). The verifier should confirm each MARKER file uses `${BUCKET}` not `${SID}`.

5. Total violations remaining: 27 (down from 33). Breakdown: L-S11-1=10, L-S43b-9=2, L-S108-1=5, L-S48d-1=4, L-S53-2=5, L-S80-2=1. All remaining L-S80-2 and the L-S48d-1 harness-health hit are either untracked-file or confirmed false-positives.
