---
observation_id: sandwich-verifier-S322-batch-e-and-untangle-verify
session: S322-verify
agent: sandwich-verifier
date: 2026-05-15
verdict: PASS
merge_eligible: YES
defects:
  critical: 0
  important: 0
  minor: 1
final_lint_count: 0
warn_file_present: false
run_all_result: 103/103 PASS (elapsed 332s)
per_hook_fire_tests:
  bash-hook-lint-fire-test: 53/53
  autonomous-block-enforcer-fire-test: 13/13
  escalation-engine-fire-test: 10/10
  severity-classifier-fire-test: 5/5
  adr-empirical-close-verify-spot-check-fire-test: 5/5
  idle-state-advisory-fire-test: 5/5
charter_p11: PASS
push_status: agent-committed-not-pushed (D-060 compliant)
scope_discipline: PASS (zero leaks)
---

# Sandwich-Verifier S322-verify: Batch E Lint 6 to 0 + Untangle - Verification Report

## Session Reviewed

Five commits across S319+S321+S317+S318+S255+S322:
- 49fe2ca - S322 Batch E: bash-hook-lint 6 to 0 (the main artifact verified)
- 5d9e5f2, 40012ed, 9923c49, da02ad0 - predecessor harness commits in S321-S322 (S319+S321 previously verified PASS-MERGE-ELIGIBLE; re-spot-checked here for scope discipline only)

Dev observation: agent-workspace/memory/observations/sandwich-dev-S322b-plan016-batch-e-lint-zero.md

## Overall Verdict

PASS - MERGE ELIGIBLE.

Dev self-report is fully corroborated by independent re-runs and adversarial probing. The Batch E remediation took bash-hook-lint from 6 violations to 0 with no ghost-greens, no hidden REALs, and detector calibrations validated via dual-property TCs. Charter P11 (companion fire-test alongside every edited hook) honored. Scope discipline perfect across all four S322 commits.

## Independent Verification Results

| Check | Result | Notes |
|---|---|---|
| bash-hook-lint.sh re-run, RC | 0 | exit 0 on VIOLATIONS==0 path |
| Lint stdout | (empty) | Lint only logs to .session-hooks.log on success |
| human-workspace/notifications/bash-hook-lint-warn.md | ABSENT | Auto-deleted by lint else branch (rm -f NOTIF_FILE) |
| run-all.sh 103/103 | PASS | Elapsed 332s (within expected ~330s) |
| bash-hook-lint-fire-test.sh standalone | 53/53 PASS | Includes 4 new S322 dual-property TCs |
| autonomous-block-enforcer-fire-test.sh | 13/13 PASS | |
| escalation-engine-fire-test.sh | 10/10 PASS | |
| severity-classifier-fire-test.sh | 5/5 PASS | |
| adr-empirical-close-verify-spot-check-fire-test.sh | 5/5 PASS | |
| idle-state-advisory-fire-test.sh | 5/5 PASS | NEW (paired with new hook) |

## Ghost-Green Adversarial Probe (per-fix evidence)

For each REAL fix - verified the source-tree code embodies the claimed remediation:

1. autonomous-block-enforcer.sh:48 - the format string now has the -- sentinel before the leading dashes. Sentinel IS present (read at line 48). FIX REAL.
2. escalation-engine.sh:72-74,84 - All four lines use wc -l piped to tr -d (read 65-90); no grep -c . survives. wc -l always exits 0, so pipefail-safe. FIX REAL.
3. adr-empirical-close-verify-spot-check.sh:80 - brace-guard with grep -oE then || true present (read line 80). Awk receives empty stdin on no-match, tok undef, empty PROBE_TOKEN, then -z PROBE_TOKEN guard skips. FIX REAL.
4. severity-classifier.sh:212-215 - All four counters use brace-guard with grep then || true piped to wc -l then tr -d (read lines 212-215). FIX REAL.
5. severity-classifier.sh:143-153 - The subshell-guard with parens then || true remains intact (read 142-153); line 153 has the || true. FP correctly preserved.
6. idle-state-advisory.sh:135 - QG_OPEN now uses printf piped to wc -l piped to tr -d (read line 135). No || echo 0. QG_MATCHES is non-empty (enclosed in if -n guard at line 134) so wc -l returns the correct line count. FIX REAL.

For each DETECTOR-GAP fix - verified BOTH the calibration AND the dual-property TCs:

- Check 4 (awk-context printf filter) - bash-hook-lint.sh:75 grep-vE chain now has third filter that excludes lines where printf follows an opening brace. Negative TC fixture (awk-printf-dash.sh) has awk with brace-printf; positive TC fixture (shell-printf-dash-no-sentinel.sh) has bare shell printf with leading dashes. Both TCs run green standalone (TC-S43b9-awk-fp NOT-flagged, TC-S43b9-shell-real STILL-flagged). DUAL-PROPERTY VERIFIED.
- Check 7 (subshell-open line skip) - bash-hook-lint.sh:300 awk has new rule: if the joined logical line begins with leading whitespace then open-paren, skip. Negative TC fixture (pipefail-subshell-guard-grep.sh) opens with paren-grep; positive TC fixture (pipefail-subshell-real-grep.sh) has RESULT command-sub paren mid-line, not line-leading. Both TCs run green standalone (TC-C-subshell-guard NOT-flagged, TC-C-subshell-real STILL-flagged). DUAL-PROPERTY VERIFIED.

## Hidden-REAL Audit (highest-risk failure mode for this remediation class)

Per S322-verify scope item 5: swept all grep sites in the five edited hooks. Each grep call site classified as one of:
- Direct alt-guard: || true or || echo N on pipeline tail
- Brace-guard: braces around grep ... || true then piped
- Subshell-guard: parens around grep then || true
- Conditional form: if grep -q then ... (exit consumed)
- Pipefail-off scope: under explicit set +o pipefail

Per-file findings:
- autonomous-block-enforcer.sh: 1 grep site at :71 - || echo guarded. SAFE.
- escalation-engine.sh: 5 grep sites - all || true or || echo 0 guarded. SAFE.
- severity-classifier.sh: 13 grep sites - head|grep -m1 || true, grep -q conditional, subshell-guard (Layer 4), and brace-guard (hidden-REAL fix at 212-215). SAFE.
- adr-empirical-close-verify-spot-check.sh: 6 grep sites - all braces or || true guarded. SAFE.
- idle-state-advisory.sh: 2 grep sites - :71 under set +o pipefail scope; :133 directly || true guarded. SAFE.

No hidden REAL violations remain in any edited file.

## Hidden-REAL Mechanism Validated

Confirmed bash-hook-lint.sh Check 7 awk uses exit after first violation per file (read line 319). This is the mechanism the dev hidden-REAL discovery relies on: the lint first-match-per-file architecture meant the FP at severity-classifier.sh:143-147 was hiding the REAL at :212-215 from view. Dev claim of hidden REAL revealed is architecturally sound.

## Commit Hygiene Audit

| Commit | Files | Scope | OOS Leaks |
|---|---|---|---|
| 49fe2ca (S322 Batch E) | 8 (all scripts/hooks/) | matches dev claim exactly | NONE |
| 5d9e5f2 (S255) | 4 (all scripts/hooks/) | hygiene NEW hooks | NONE |
| 40012ed (S317) | 8 (all scripts/hooks/) | block-mechanism redesign | NONE |
| 9923c49 (S318) | 19 (all scripts/hooks/) | notification-spam root fix | NONE |

Each commit was scanned for .claude/, CLAUDE.md, agent-workspace/CLAUDE.md, agent-workspace/memory/ path prefixes: ZERO leaks across all 4 commits. The working-tree-uncommitted artifacts remain uncommitted by design.

## Push Status

- git status -sb shows ahead 1 - HEAD 49fe2ca not on remote.
- The 4 prior commits (da02ad0, 9923c49, 40012ed, 5d9e5f2) are already on origin/main (pre-existing pushed commits).
- D-060 compliant: only the S322 Batch E commit awaits human push.

## Charter Principle 11

- All 6 affected hooks have a *-fire-test.sh companion in scripts/hooks/firing-tests/.
- idle-state-advisory.sh newly tracked, paired with idle-state-advisory-fire-test.sh newly tracked, BOTH in commit 49fe2ca (verified via git show --diff-filter=A --name-only 49fe2ca).
- Each companion fire-test runs green individually (all 6, see table above).

P11: PASS.

## Dev Self-Report Accuracy

Dev report at agent-workspace/memory/observations/sandwich-dev-S322b-plan016-batch-e-lint-zero.md:
- Final lint 0: VERIFIED.
- run-all.sh 103/103 x2: VERIFIED (independent run produced 103/103).
- bash-hook-lint-fire-test.sh 53/53: VERIFIED.
- 6-violation triage (4 REAL + 2 DETECTOR-GAP): all classifications match the source-tree evidence.
- Hidden REAL at severity-classifier.sh:212-215: VERIFIED real, VERIFIED fixed.
- 8 files staged: VERIFIED (git show --stat 49fe2ca shows exactly those 8 files).

## Findings

### Critical (must fix)

NONE.

### Important (should fix)

NONE.

### Minor (track, can defer)

1. Check 7 subshell-open skip rule is heuristic, not semantic.
   - File:line: scripts/hooks/bash-hook-lint.sh:300
   - Risk: the skip rule fires unconditionally when the logical line begins with leading whitespace then open-paren, regardless of whether a matching closing paren with || true (or other tail guard) is present. In principle, this could miss a future violation pattern of paren-grep-paren without a tail guard.
   - Why minor: such a pattern is uncommon and produces a desirable failure (the subshell exit propagates correctly under pipefail). The dual-property TC suite catches the canonical FP/real shapes. Skip rule is documented in code comment (lines 295-299).
   - Fix recipe (if/when needed): enhance Check 7 awk to track multi-line paren depth and verify the closing paren is followed by || true or || colon before activating the skip. Defer until a real-world false-negative surfaces.

## Scope Discipline

S322 Batch E touched only the planned 8 files (5 edited hooks + 1 hook newly tracked + 1 fire-test newly tracked + lint detector + lint fire-test). Zero drive-by refactors. Plan-following: COMPLETE.

## Karpathy Principle Check

- P1 (Think before coding): dev surfaced triage matrix (REAL vs DETECTOR-GAP), justified each calibration. OK.
- P2 (Simplicity): each fix is a one-line shape change (replace grep -c . with wc -l piped to tr -d, add brace guard, add -- sentinel); calibrations add a single grep -vE or if-full-match line. OK.
- P3 (Surgical changes): only the documented violation sites modified. OK.
- P4 (Goal-driven): success criterion explicit (lint: 6 to 0; warn file gone); achieved. OK.

## Constitution Check (relevant subset)

- DR1 (domain framework imports): N/A - no domain code touched.
- DR6 (Any types): N/A - bash only.
- DR8 (cross-BC imports): N/A.
- I-1 (citations): N/A - no thesis or claim emitted.
- I-S1 (No LLM math): N/A.
- Bash hook hygiene (L-S43b-9, L-S48d-1, L-S80-2, L-S68-2 family): PASS - final lint 0 violations.
- Charter P11 (companion fire-test): PASS.
- D-060 (commit, do not push): PASS.

## Recommendations

MERGE: ready. No critical or important defects. One minor calibration-precision note tracked for future refinement.

Specific next action: human-side git push origin main when ready to ship 49fe2ca upstream.
