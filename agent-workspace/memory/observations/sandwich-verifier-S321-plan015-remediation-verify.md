---
observation_id: sandwich-verifier-S321-plan015-remediation-verify
plan: agent-workspace/session-plans/pending/015-S319-bash-hook-lint-violation-remediation.md
session: S321
authored: 2026-05-15
agent: sandwich-verifier (Claude Opus 4.7, fresh context)
verifies: sandwich-dev-S321-plan015-remediation.md (S321 remediation of the S320 verifier verdict)
verdict: PASS-WITH-CONCERNS
merge_eligible: YES
note: Verifier could not Write in its context (Write disabled); report persisted to file by main session verbatim from the verifier's returned findings.
---

# S321-verify — Adversarial Verification Report

**Verdict: PASS-WITH-CONCERNS — MERGE-ELIGIBLE: YES**
**Defect count: 0 IMPORTANT outstanding · 3 MINOR (1 new, 2 tracked/known)**

## Independent re-verification (did not trust main-session spot-check)
- `bash -n` clean on all 6 S321 files — CONFIRMED.
- `daily-backup-fire-test.sh` 7/7, `session-export-raw-fire-test.sh` 12/12, `bash-hook-lint-fire-test.sh` 49/49 — all CONFIRMED standalone.
- `run-all.sh` **103/103 PASS** — CONFIRMED via foreground tee run (FIRING_TEST_TIMEOUT=45, elapsed 327s, exit 0, zero FAIL/TIMEOUT lines). No timeout artifact.
- Lint = **6, all Batch E** — CONFIRMED; daily-backup.sh NOT flagged (L-S80-2 = 0).
- Batch E (5 files) untouched — CONFIRMED, zero staged.
- Scope discipline — CONFIRMED: 6 S321 files fully staged, zero `S321` tags leaked into the 16 S319-baseline files.

## Per-defect verdicts

**IMPORTANT-1 (daily-backup SIGPIPE) — FIXED (core).** Built a 253-entry tar.gz with PROJECT_CHARTER.md first: old `grep -q` form → `rc=141` (regression reproduced); new `( tar | grep -cE ) || echo 0` form → `VERIFY_HITS=253` → `ARCHIVE_OK=1`. Good large early-match backup now correctly marked. TC7 genuinely exercises SIGPIPE — its 203-entry fixture returns `rc=141` on the old code, so it's a real regression test, not pass-by-luck.

**IMPORTANT-2 (clean_text awk divergence) — FIXED (a)(b)(c).** Reference comparison vs python `re.sub`: (a) `line before [stripped] line after` == python; (b) `mixed [stripped] then [stripped]` == python, inline `x` stripped; (c) emits `unclosed [stripped]` — diverges from python but COMPLIANT with the S320 "at minimum do not silently drop" recommendation. TC8–TC12 give real dual-property coverage. Nested tags and literal-`[stripped]`-in-source both match python.

**MINOR-1 (Check 7 hash-in-string) — FIXED.** Char-scan with `#` preceded by ` `/`\t`/`;`/`&` correctly distinguishes string-`#` from comment-`#`. `split(full,chars,"")` verified portable on gawk 5.3.2. TC-C-hash-in-string asserts the genuine grep still fires.

**MINOR-2 (Check 6b SESSION_ID) — FIXED.** `SESSION(_ID)?` — `${SESSION_ID}` matches, `${SESSION}` bare matches, `${SID}` matches, `${SESSION_IDX}` correctly does NOT (no over-match). TC-L-S108-1-session-id asserts it.

**MINOR-3 (backslash carry-path test) — COMPLETE.** Both `TC-C-backslash-fire` (`assert_flagged`) and `TC-C-backslash-guarded` (`assert_NOT_flagged`) are wired with real assertions in the final staged version — earlier mid-flight "missing assertions" concern is resolved. Both genuinely exercise the substr carry-join.

**Charter P11** — PASS: every code change ships a companion dual-property firing-test TC.

## Findings

### MINOR (track + defer — do NOT block merge)

1. **MINOR-A (NEW, introduced by IMPORTANT-1 fix).** `scripts/hooks/daily-backup.sh:91` — in the **no-match** case, `( tar | grep -cE ) || echo 0` captures multi-line `"0\n0"` (grep -c outputs `0` AND exits 1 → subshell stdout `0` + `echo 0` both captured). The dev's comment at daily-backup.sh:86-88 ("always a clean integer (no multi-line)") is **factually false**. **No functional impact** — traced exactly: the `[ ... -gt 0 ]` errors with `integer expression expected` but as an `if`-condition the ERR trap is suppressed, `ARCHIVE_OK` stays 0, WARN still logs, `exit 0`. Net effect = spurious `[: 0\n0: integer expression expected` on stderr + a wrong comment. Cosmetic/hygiene. Fix recipe: `| head -1` or `| tr -d '\n'` inside the subshell, OR canonical `if ( tar | grep -qE ... ); then ARCHIVE_OK=1; fi` (grep -q is SIGPIPE-safe here because the `( )` subshell absorbs the rc and the `if` ignores it); then correct the comment.

2. **MINOR-B (pre-existing, NOT a S321 regression).** `scripts/hooks/session-export-raw.sh:63-138` — clean_text awk still diverges from python on bare-unclosed / mismatched single-line opening tags (`a <system-reminder> b <task-notification> c`, and `<X> ... </Y>` same-line): drops text after the spurious open to EOF where python keeps it verbatim. Same mechanism as S320-accepted case (c); S319b awk had identical behavior. Low probability on well-formed Claude Code transcripts. Known limitation, not a blocker.

3. **(carried from S320, MINOR precision).** `scripts/hooks/bash-hook-lint.sh:298-307` — Check 7: a `#` after `|` or `(` is not treated as a comment boundary; can yield a false POSITIVE (over-flag), never a missed violation / ghost-green. Not worse than S319b.

## Recommendation

**MERGE.** Both S320 IMPORTANT defects are genuinely closed on their core failure modes and empirically verified. All 3 MINOR fixes are correct with proper dual-property firing-test coverage. run-all.sh 103/103, lint 6 (Batch E only), bash -n clean, Batch E untouched, scope discipline clean. The one new defect (MINOR-A) is cosmetic stderr-noise + a wrong comment with zero functional/safety impact — does not reach the bar to block merge.

Next action: hand the staged 23-file tree to the user for the commit boundary. Schedule MINOR-A + MINOR-B as a small follow-up calibration pass (both 1–2 line fixes); neither is urgent.
