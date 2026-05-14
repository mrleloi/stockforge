---
agent: sandwich-verifier
session: S316
date: 2026-05-14
plan_verified: agent-workspace/session-plans/pending/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md
dev_session_verified: agent-workspace/memory/sessions/2026-05-14-session-315.md
verdict: PASS-WITH-CONCERNS
---

# Verifier Observation S316 W0-2 Python Determinism Banned-Patterns

## Verdict: PASS-WITH-CONCERNS

All 5 deliverables landed (D1-D5). Acceptance criteria green. Two non-blocking concerns:
broken comment-filter for R1/R3/R4 (false-positive risk on docstrings or comments referencing
banned patterns) plus R3 heuristic misses next-iter pattern. Both tracked for W0-2.1
follow-up; not blockers for shipping.

## V1 Acceptance criteria

### D1 Hook scripts/hooks/python-determinism-check.sh
- R1 datetime.now() detection line 156-163: fires correctly on bare parens
- R2 awk-based main-block context detection line 172-184: correctly skips main block and test files
- R3 list keys index regex line 191-198: fires for explicit pattern, misses next-iter (V7 concern)
- R4 time.time() in domain layer line 200-211: gated by is_domain flag
- PostToolUse and Stop dual trigger: confirmed in .claude/settings.json line 537-545 plus 415-417
- RC=0 always: trap on line 29 plus exit 0 at line 245
- Hour-bucket marker idempotency line 56-76: uses set -o noclobber atomic claim
- Bash plus POSIX only: confirmed (awk is POSIX)
- HIGH severity emission: indirect via notification ALERT keyword that severity-classifier Layer 5 picks up

### D2 Firing test python-determinism-check-fire-test.sh
- 12/12 PASS confirmed on independent re-run by verifier
- SPAWN-CONTEXT positional-arg marker present at line 4
- Coverage TC01-12: R1-R4 plus edge cases (main block, test fixtures, allowed paths, empty file, clean file, out-of-scope path)

### D3 ADR decisions/059-python-determinism-contract.md
- 12-field schema present
- Status PROPOSED level IMPL: correctly maps to LOW severity in severity-classifier (does NOT drown HIGH signals)
- Charter alignment: extends Principle 8 calibration-over-confidence with determinism-over-flakiness
- WARN-to-BLOCKING ratchet documented as deferred to manual decision at S320 or later

### D4 .claude/settings.json wiring
- PostToolUse matcher Edit-Write-MultiEdit at line 538: PRESENT
- Stop chain position AFTER severity-classifier lines 411-413 then 415-417: CORRECT
- JSON valid (parsed via python -c)

### D5 DoD verification
- bash-hook-lint clean for python-determinism-check.sh: confirmed
- Firing-test 12/12 PASS: re-confirmed
- Smoke synthetic 4 patterns: confirmed via TC01 TC03 TC07 TC08
- Live audit on fsm.py: 0 violations
- 2 pre-existing violations: verified line-by-line as LEGITIMATE
- NO commit: git log -5 confirms baseline unchanged

## V2 Dev handoff notes

1. Firing-test re-run 12/12 PASS: CONFIRMED
2. bash-hook-lint clean on new hook: CONFIRMED
3. 2 pre-existing violations legitimate: CONFIRMED
4. PostToolUse matcher without .py filter: CONFIRMED; hook filters via stdin JSON payload line 91-94
5. Hour-bucket idempotency: CONFIRMED via 3 back-to-back runs (count 5 to 5 to 5)
6. ADR PROPOSED-IMPL: maps to LOW LOG-ONLY (does NOT drown HIGH signals) CONFIRMED

## V3 Charter compliance

- I-S1 NO LLM math: CONFIRMED
- bash plus POSIX only: CONFIRMED
- NO commit: CONFIRMED
- Firing-test SPAWN-CONTEXT marker positional-arg: CONFIRMED
- Atomic noclobber for marker writes line 71: CONFIRMED (Check 11 compliance)

## V4 Test quality

- TC01-12 independent: each TC calls setup_tmp
- Edge cases adequate
- Negative tests present (TC02 TC04 TC05 TC09 TC11 TC12)
- R2 test-fixture exception TC05: verified

## V5 Regression

All firing-tests PASS:
- python-determinism-check: 12/12 PASS
- severity-classifier: 5/5 PASS
- escalation-engine: 7/7 PASS
- autonomous-block-enforcer: 11/11 PASS
- telegram-push: 3/3 PASS
- observation-orphan-detector: 12/12 PASS
- pytest packages/domain/observation_lifecycle/: 58 passed

## V6 Integration smoke

1. Live audit: 2 violations flagged (R1 and R2 known); no false-positives on legitimate code
2. severity-state.tsv: 5 python-determinism-warn notifications HIGH; D-059 LOW (correct)
3. Markers: created and aged correctly (550 markers spanning hours 10 and 11)
4. Same-hour idempotency: 3 back-to-back runs, 0 growth

## V7 False-positive risk assessment

R3 heuristic regex (line 191):
- items() iteration: correctly NOT flagged
- sorted() iteration: correctly NOT flagged
- list keys index 0: SHOULD fire, FIRES correctly
- next-iter pattern: SHOULD fire, DOES NOT fire (false-negative)
- dict equality: correctly NOT flagged

R3 severity WARN (not ERR) matches plan and ADR; correct given heuristic limitations.

## DEFECTS

### Important (track for W0-2.1; not blocking ship)

D-IMPORTANT-1 Comment-filter broken for R1/R3/R4 grep-based detection.
- Location: scripts/hooks/python-determinism-check.sh lines 157 192 204
- Pattern: grep -n PATTERN file then grep -v starting-with-hash
- Root cause: grep -n prepends line-number prefix, so second grep filter NEVER matches comments
- Reproducer verified: comment-line with datetime.now() triggers FALSE R1 violation
- Impact: docstrings or comments mentioning datetime.now() time.time() will false-positive
- R2 NOT affected (uses awk)
- Fix: pre-filter via sed delete-comments before grep, or use awk
- Recommendation: W0-2.1 cleanup ticket

D-IMPORTANT-2 R3 heuristic misses next-iter pattern.
- Location: scripts/hooks/python-determinism-check.sh line 191
- Current regex covers list keys index only; ADR line 178 documents as known limitation
- Recommendation: extend regex
- Lower priority than D-IMPORTANT-1 since dev and ADR acknowledged

### Minor

D-MINOR-1 local_TS_FILE line 227 is confusing variable name.
- Looks like typo of local TS_FILE= (bash local keyword only valid inside functions)
- Functionally works but confusing
- Fix: rename to TS_FILE

D-MINOR-2 find -mmin +120 -delete cleanup invoked per file in claim_file_slot line 69.
- O(N squared) behavior for 343 files: about 187k path checks
- Fix: hoist cleanup to once per hook invocation

D-MINOR-3 Summary line OK 0 violations across N files misreports N.
- When all files have markers, N still shows total candidates (343) even though 0 re-scanned
- Cosmetic only

## Pre-existing violations remediation path

Both LEGITIMATE (verified line-by-line):

1. packages/application/crowd/use_cases/capture_sentiment_snapshot_use_case.py:180
   - random.sample call
   - Fix: pass seeded RNG via DI OR use deterministic top-N
   - Recommendation: separate cleanup session

2. packages/infrastructure/analysis/sqlite_thesis_repository.py:206
   - else datetime.now() fallback
   - Fix: change to datetime.now(timezone.utc) trivial 1-line
   - Can be inline or in remediation pass

Recommended path: defer remediation AFTER W0-3/4/5 ship since hook is best-effort RC=0 (does not block).

## Recommended next steps

PASS-WITH-CONCERNS, ship W0-2.

Actions:
1. Move agent-workspace/session-plans/pending/014-S315 plan to completed/
2. Create W0-2.1 follow-up plan to address D-IMPORTANT-1 plus D-IMPORTANT-2 plus D-MINOR-1/2/3
3. Advance to W0-3 (TradingAgents atomic temp-file-replace) per plan sequence
4. Defer pre-existing violations remediation to dedicated cleanup pass (not blocking)
