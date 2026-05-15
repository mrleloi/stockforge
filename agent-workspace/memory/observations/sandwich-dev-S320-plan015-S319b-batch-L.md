---
observation_id: sandwich-dev-S320-plan015-S319b-batch-L
plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
session: S320 (executing S319b scope — Batch L lint-calibration)
authored: 2026-05-14
agent: sandwich-dev (claude-sonnet-4-6)
---

# S319b Batch L Execution — Observation File

## Baseline (start of Batch L)

- Lint violations: **27** (carried from S319a)
- `run-all.sh`: 103/103 PASS (regression floor)
- `bash-hook-lint-fire-test.sh`: 38/38 PASS

---

## Triage Verdict Table

### L-S11-1 (Check 1 — portability)

| Hook | Verdict | Reason |
|---|---|---|
| `attach-portability-smoke.sh` | **REAL** (accepted false-positive via skip-marker) | `python` for YAML manifest parsing — no portable bash YAML parser; explicit design choice. Skip-marker + rationale added. |
| `autonomous-stop-watchdog.sh` | **FALSE-POSITIVE** | `jq` guarded by `if command -v jq ... else BASH_REMATCH` — complete fallback path. |
| `firing-test-spawn-context-lint.sh` | **FALSE-POSITIVE** | `python3` for JSON parse; degrades gracefully: empty inventory → SKIP log entry and exit 0. |
| `harness-health-self-scan.sh` | **FALSE-POSITIVE** | `python3` is ONLY fallback for `date -d` math (`date -d ... || python3 ...`); primary is bash-builtin `date`. |
| `post-dev-dispatch-attestation-check.sh` | **FALSE-POSITIVE** | `python -m pytest` guarded by `command -v python`; fallback: WARN-only and skip attestation. |
| `qa-pending-stale-mover.sh` | **FALSE-POSITIVE** | `python3` guarded by `if command -v python3`; fallback: `continue` (skip bundle). |
| `redact-secrets.sh` | **AMBIGUOUS → skip-marker** | Graceful chain exists (python3 → node → sed); sed is Phase-0 floor. Per plan recommendation: skip-marker + comment. |
| `session-export-raw.sh` | **REAL** | `python3` for `clean_text` (XML tag stripping) and SHA256 hash — no fallback for these. **Rewrote to bash+POSIX.** |
| `subagent-stop-logger.sh` | **FALSE-POSITIVE** | `jq` guarded by `if command -v jq`; BASH_REMATCH fallback for all parsed fields. |
| `vendor-api-probe.sh` | **FALSE-POSITIVE** | Explicit "Phase 1+" designation in header; `python` is the entire purpose (importlib probe). |

### L-S53-2 (Check 8 — unanchored grep)

| Hook | Verdict | Reason |
|---|---|---|
| `autonomous-stop-watchdog.sh` | **FALSE-POSITIVE** | grep targets transcript-tail narration mid-JSON-line; `^` would never match; P6 firing-test empirically proves anchoring would regress detector. Inline rationale at lines 68-77. |
| `promotion-cycle-trigger.sh` | **FALSE-POSITIVE** | grep targets basename token (`promote-rule-S52.md`); S<N> mid-string after prefix; `^S` would never match. Inline rationale at lines 38-46. |
| `session-start-bootstrap.sh` | **FALSE-POSITIVE** | grep on awk-scoped section (Class B probe — KI-S56-1 structural fix); `^` anchor wrong for this context; inline rationale at lines 78-89. |
| `stale-prompt-detector.sh` | **FALSE-POSITIVE** | grep on free-form user-input; Track/Session tokens appear mid-prompt; `\b` word boundary is correct mechanism; inline rationale at lines 71-105. |
| `sync-grilling-call.sh` | **FALSE-POSITIVE** | grep on `$DEC_ID` variable content (e.g. `sync-grilling-S102`); S<N> mid-string after prefix; `^` would never match. |

### L-S108-1 (Check 6b — session-ID fallback)

All 4 hits confirmed FALSE-POSITIVES by S319a (inherited):
- `idle-escape-detector.sh`, `phase-status-coherence.sh`, `project-md-adr-staleness.sh`, `sub-plan-completion-coherence.sh`
- ALL already use correct hour-bucket (`${BUCKET}`) for markers; `${CLAUDE_SESSION_ID:-unknown}` only used for per-session performance cache filename (not the idempotency marker).
- `idle-state-advisory.sh` had L-S108-1 too but is UNTRACKED (Batch E) — however it was also fixed by the Check 6b calibration since it uses `${BUCKET}` pattern.

**Disposition**: Cleared by Check 6b calibration (narrowed HAS_MARKER to require session-ID-derived variable names: SID/SESSION/SESS/CLAUDE_SESSION_ID).

### L-S48d-1 (Check 7 — pipefail+bare-grep)

| Hook | Verdict |
|---|---|
| `harness-health-self-scan.sh` | **DETECTOR FALSE-POSITIVE → then GENUINE hits revealed** |

The Check 7 `/\\$/` fix (S319a KEY FINDING) cleared the false join of `$`-variable lines. After the fix, Check 7 found:
1. Line 260 (`HH1_check   # grep log — cheap-medium`) — inline comment; fixed by adding inline-comment-before-grep skip rule to Check 7.
2. Line 57 (HH1_check: `grep -n "SessionStart session=$SID" | tail -1 | cut -d: -f1`) — GENUINE: no `|| true`. **Fixed.**
3. Lines 244-245 (HH12_check: `grep -m1 -E '^## S[0-9]+...' | grep -oE ... | head -1`) — GENUINE: no `|| true`. **Fixed.**

---

## Calibration Edits to `bash-hook-lint.sh`

### Check 1 (L-S11-1) — skip-marker support

Added skip-marker check BEFORE the grep scan: if file contains `# bash-hook-lint:allow L-S11-1 <reason>`, the file is skipped for Check 1. Placed at lines ~55-57 (after self-skip, before NON_COMMENT scan).

**Companion TCs added to fire test:**
- `TC-L-S11-1-skipmarker`: `python3-with-skipmarker.sh` — has skip-marker → NOT flagged (PASS)
- `TC-L-S11-1-genuine`: `python3-no-skipmarker.sh` — no skip-marker with python3 → STILL flagged (PASS)

### Check 6b (L-S108-1) — HAS_MARKER narrowed

Changed `HAS_MARKER` regex from matching ANY `${UPPERCASE_VAR}` to specifically requiring the variable name to be session-ID-derived: `SID|SESSION|SESS|CLAUDE_SESSION_ID`. Date-bucket variables (`BUCKET`, `TODAY`, `DATE_HR` etc.) are explicitly excluded.

Before: `\.[a-zA-Z0-9_-]+-(fired|...)-\$\{?[A-Z_]`
After: `\.[a-zA-Z0-9_-]+-(fired|...)-\$\{?(SID|SESSION|SESS|CLAUDE_SESSION_ID)[^A-Z_]`

**Companion TCs added to fire test:**
- `TC-L-S108-1-bucket`: `sid-bucket-marker.sh` — uses `${BUCKET}` in marker → NOT flagged (PASS)
- `TC-L-S108-1-sid-marker`: `sid-in-marker.sh` — uses `${SID}` in marker → STILL flagged (PASS)

### Check 7 (L-S48d-1) — /\\$/ carry-line fix + inline-comment skip

Two sub-edits:

**1. `/\\$/` → `substr(line, length(line)) == "\\"` (M-S80-1 family fix):**
The `/\\$/` regex in awk's carry-line detection was matching ANY line containing `$` (dollar sign) on this Windows/GNU-awk 5.3.2 environment — NOT lines ending with literal backslash. This caused ALL lines with shell variables to be joined into one accumulated `full`, obscuring per-line `if` guards.

Confirmed empirically (inline probe before change):
```
printf 'echo "$VAR"\n' | awk '/\\$/ {print "MATCHED"}' → MATCHED (WRONG)
printf 'abc\\\n' | awk 'substr($0,length($0))=="\\"{print "END-BS"}' → END-BS (CORRECT)
```

Fixed by replacing `if (line ~ /\\$/)` with `if (length(line) > 0 && substr(line, length(line)) == "\\")` in BOTH Check 7 and Check 9 awk bodies.

**2. Inline-comment-before-grep skip rule:**
After the `/\\$/` fix, Check 7 false-flagged lines like `HH1_check   # grep log — cheap-medium` where `grep` appears ONLY in an inline comment (after `#`), not as a command. Added:
```awk
hash_pos = index(full, "#")
grep_pos = index(full, "grep")
if (hash_pos > 0 && hash_pos < grep_pos) next
```

**Companion TCs added to fire test:**
- `TC-C-inline-comment`: `pipefail-inline-comment-grep.sh` — grep only in inline comment → NOT flagged (PASS)
- All existing TCs (TC-C through TC-C-and-chain) still pass confirming genuine violations still fire.

### Check 8 (L-S53-2) — skip-marker support

Added skip-marker check BEFORE BAD_D scan: if file contains `# bash-hook-lint:allow L-S53-2 <reason>`, the file is skipped for Check 8.

**Companion TCs added to fire test:**
- `TC-L-S53-2-skipmarker`: `unanchored-with-skipmarker.sh` — has skip-marker → NOT flagged (PASS)
- `TC-L-S53-2-genuine`: reuses `unanchored-positional-grep.sh` (TC-D) — no skip-marker → STILL flagged (PASS)

---

## Source Rewrites

### `session-export-raw.sh` — L-S11-1 REAL fix

Rewrote two `python3` invocations to bash+POSIX:

1. `clean_text()` function: `python3 -c "import re, sys..."` → awk state machine with range patterns for multi-line XML tag stripping + inline gsub for same-line tags.
2. SHA256 hash: `python3 -c "import hashlib..."` → `sha256sum ... | cut -c1-8`.

### `harness-health-self-scan.sh` — L-S48d-1 GENUINE fixes

Three grep pipelines missing `|| true`:
1. Line 57 (HH1): `start_line=$(grep -n ... | tail -1 | cut -d: -f1)` → added `|| true`
2. Lines 244-245 (HH12): `ce_phase=$(grep -m1 ... | grep -oE ... | head -1)` and `proj_phase=...` → added `|| true` to each

---

## Skip-Markers Added to Source Files

### L-S11-1 skip-markers (8 hooks):
- `autonomous-stop-watchdog.sh`: jq guarded by command-v + BASH_REMATCH fallback
- `firing-test-spawn-context-lint.sh`: python3 degrades to SKIP when unavailable
- `harness-health-self-scan.sh`: python3 is date-math fallback only
- `post-dev-dispatch-attestation-check.sh`: python guarded by command-v
- `qa-pending-stale-mover.sh`: python3 guarded by command-v
- `redact-secrets.sh`: graceful chain python3→node→sed
- `subagent-stop-logger.sh`: jq guarded by command-v + BASH_REMATCH fallback
- `vendor-api-probe.sh`: Phase 1+ explicit designation
- `attach-portability-smoke.sh`: YAML hard dep, explicit design choice

### L-S53-2 skip-markers (5 hooks):
- `autonomous-stop-watchdog.sh`: transcript-tail narration mid-JSON
- `promotion-cycle-trigger.sh`: basename token mid-string
- `session-start-bootstrap.sh`: awk-scoped section Class B probe
- `stale-prompt-detector.sh`: free-form user-input content-search
- `sync-grilling-call.sh`: decision_id variable content mid-string

---

## Per-Edit File:Line Summary

### `bash-hook-lint.sh`:
- Check 1 (~line 55): skip-marker support added (3 lines)
- Check 6b (~line 207): `HAS_MARKER` regex narrowed to session-ID vars (comment + regex change)
- Check 7 (~line 264): `/\\$/` → `substr` fix + inline-comment skip rule (2 additions)
- Check 8 (~line 322): skip-marker support added (3 lines)
- Check 9 (~line 375): `/\\$/` → `substr` fix (same as Check 7)

### `bash-hook-lint-fire-test.sh`:
- New fixtures (before chmod): 7 new synthetic hook scripts
- New assertions (after TC-clean): 8 new assert_flagged/assert_NOT_flagged calls

### `harness-health-self-scan.sh`:
- Line 57 (HH1): `|| true` added
- Lines 244-245 (HH12): `|| true` added to each grep pipeline
- Line 8: `# bash-hook-lint:allow L-S11-1` marker added

### `session-export-raw.sh`:
- Lines 64-80: `clean_text()` rewritten python3→awk
- Line 89: hash computation rewritten python3→sha256sum
- skip-marker NOT added (this was a REAL fix, not a false-positive)

### Each of 9 FALSE-POSITIVE L-S11-1 hooks: 1 comment line added at top
### Each of 5 L-S53-2 hooks: 1 comment line added at top (autonomous-stop-watchdog has both markers)

---

## Verification

### bash -n
All 16 edited files (bash-hook-lint.sh, bash-hook-lint-fire-test.sh, harness-health-self-scan.sh, session-export-raw.sh + 12 skip-marker hooks): **CLEAN (no syntax errors)**.

### bash-hook-lint-fire-test.sh
- Before S319b: 38/38 PASS
- After S319b: **45/45 PASS** (7 new TCs, all green)
- Dual property verified per Charter Principle 11: (a) false-positives no longer fire, (b) genuine violations STILL fire.

### harness-health-self-scan-fire-test.sh
- After harness-health edits: **7/7 PASS**

### Lint count
| Stage | Count |
|---|---|
| Start of Batch L | 27 |
| After Check 6b fix (5× L-S108-1 cleared) | 22 |
| After Check 7 fix + harness-health genuine fixes (L-S48d-1 harness-health cleared) | 21 |
| After L-S11-1 skip-markers (10 cleared) + session-export-raw rewrite | 11 |
| After L-S53-2 skip-markers (5 cleared) | **6** |

### run-all.sh
- Run 1 (mid-session): 103/103 PASS (~276s)
- Run 2 (final): **103/103 PASS** (~277s)

---

## Remaining Violations (6 — all Batch E, not in S319b scope)

| Violation | File | Status |
|---|---|---|
| L-S43b-9 | `autonomous-block-enforcer.sh` | DIRTY (Batch E gated) |
| L-S43b-9 | `escalation-engine.sh` | DIRTY (Batch E gated) |
| L-S48d-1 | `adr-empirical-close-verify-spot-check.sh` | DIRTY (Batch E gated) |
| L-S48d-1 | `escalation-engine.sh` | DIRTY (Batch E gated) |
| L-S48d-1 | `severity-classifier.sh` | DIRTY (Batch E gated) |
| L-S80-2 | `idle-state-advisory.sh` | UNTRACKED (Batch E gated) |

---

## Notable Architecture Notes

- `bash-hook-lint.sh` now coexists two separate work-streams in non-overlapping regions:
  - **S318 region**: "Emit results" section (~lines 436-464) — idempotent notification; fixed-name file. NOT touched by S319b.
  - **S319b region**: Check 1 / Check 6b / Check 7 / Check 8 (earlier in the file). No overlap.
- The `/\\$/` → `substr` fix applies to BOTH Check 7 and Check 9 (same awk body pattern) for consistency.
- The inline-comment-before-grep skip rule (`hash_pos < grep_pos`) is a heuristic — it correctly handles the `# grep log` inline-comment pattern but would incorrectly skip a line like `# comment && grep file` where grep is both in comment and as command. In practice this edge case doesn't occur in the codebase.

---

## Deviations from Plan

1. **`attach-portability-smoke.sh`**: Plan suggested rewrite OR PHASE-1+ guard. I chose skip-marker instead of rewrite. Rationale: the PHASE-1+ exemption is not implemented in Check 1; implementing it would require additional complexity (scanning for a PHASE-1+ guard in the file AND checking the tool usage is under that guard). Skip-marker achieves the same result more cleanly. The hook genuinely requires YAML parsing; the rationale is explicit in the marker comment.

2. **Check 7 inline-comment fix**: Not explicitly in the plan, but required by the /\\$/ fix (the fix exposed a new false-positive pattern — `# grep log` inline comments). This is a necessary correctness fix, not a speculative addition.

3. **harness-health-self-scan.sh genuine L-S48d-1 hits**: The S319a analysis said line 135 (`if tail -1 | grep -q`) was the expected hit (guarded by `if`, so a false-positive). After the /\\$/ fix, the REAL first violation was line 57 (NOT guarded). These were genuine violations that the buggy `/\\$/` pattern had hidden. Fixed rather than ratified.

---

## Staged for Commit

```
M  scripts/hooks/attach-portability-smoke.sh       (L-S11-1 skip-marker; L-S80-2 from S319a)
M  scripts/hooks/autonomous-stop-watchdog.sh       (L-S11-1 + L-S53-2 skip-markers)
M  scripts/hooks/bash-hook-lint.sh                 (Check 1/6b/7/8 calibration; S318 emit section unchanged)
M  scripts/hooks/bootstrap-summary-renderer.sh     (L-S48d-1 from S319a)
M  scripts/hooks/daily-backup.sh                   (L-S80-2 from S319a)
M  scripts/hooks/firing-test-spawn-context-lint.sh (L-S11-1 skip-marker)
M  scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh (7 new TCs; 38→45)
M  scripts/hooks/harness-health-self-scan.sh       (L-S11-1 skip-marker; L-S48d-1 genuine fixes lines 57,244,245)
M  scripts/hooks/idle-escape-detector.sh           (L-S80-2 from S319a)
M  scripts/hooks/phase-status-coherence.sh         (L-S80-2 from S319a)
M  scripts/hooks/post-dev-dispatch-attestation-check.sh (L-S11-1 skip-marker)
M  scripts/hooks/promotion-cycle-trigger.sh        (L-S53-2 skip-marker)
M  scripts/hooks/qa-pending-stale-mover.sh         (L-S11-1 skip-marker)
M  scripts/hooks/redact-secrets.sh                 (L-S11-1 skip-marker)
M  scripts/hooks/session-export-raw.sh             (L-S11-1 REAL fix: awk+sha256sum rewrite)
M  scripts/hooks/session-start-bootstrap.sh        (L-S53-2 skip-marker)
M  scripts/hooks/stale-prompt-detector.sh          (L-S53-2 skip-marker)
M  scripts/hooks/subagent-stop-logger.sh           (L-S11-1 skip-marker)
M  scripts/hooks/sync-grilling-call.sh             (L-S53-2 skip-marker)
M  scripts/hooks/vendor-api-probe.sh               (L-S11-1 skip-marker)
```

---

## Handoff Notes for Verifier

1. **Ghost-green check for skip-markers**: Verify each skip-marker hook has a genuine rationale (not silencing a real violation). Key ones: `attach-portability-smoke.sh` (YAML hard dep — check if python is required for the YAML parse), `session-export-raw.sh` (REAL fix via awk rewrite — verify clean_text awk logic is functionally equivalent to the python3 regex).

2. **harness-health-self-scan.sh L-S48d-1**: The S319a analysis said line 135 (`if tail -1 | grep -q`) is guarded by `if`. After the `/\\$/` fix, the ACTUAL first Check 7 violation was line 57. Verify: (a) line 57 now has `|| true`, (b) line 135 is still inside `if tail ... | grep -q ... ; then` (if guard — NOT flagged), (c) the awk runs clean.

3. **Check 7 `/\\$/` → `substr` fix**: This changes behavior for ALL hooks scanned by Check 7 and Check 9. Verify: TC-C through TC-C-and-chain all still pass (confirmed: 45/45). The fix only changes the carry-line detection, not the actual violation check logic.

4. **session-export-raw.sh awk clean_text**: The python3 version used `re.sub` with dotall patterns for multi-line XML tags. The awk version uses a state machine (`in_tag=1` on opening tag, `next` until closing tag). Verify the logic correctly handles: (a) multi-line tags, (b) same-line tags, (c) nested same-tag patterns.

5. **L-S108-1 count**: Was 5 in the notification (idle-escape-detector, idle-state-advisory, phase-status-coherence, project-md-adr-staleness, sub-plan-completion-coherence). Now 0. `idle-state-advisory.sh` is UNTRACKED (Batch E). Verify: idle-state-advisory is NOT in the remaining L-S108-1 list (it shouldn't be — the Check 6b fix clears it since it uses `${BUCKET}` pattern; but it still has L-S80-2). Check that `idle-state-advisory.sh` is indeed UNTRACKED (`??` in git status).

6. **Batch E files not touched**: Confirm `escalation-engine.sh`, `severity-classifier.sh`, `autonomous-block-enforcer.sh`, `adr-empirical-close-verify-spot-check.sh` are still DIRTY (` M` in git status) and NOT staged (no `M ` prefix).
