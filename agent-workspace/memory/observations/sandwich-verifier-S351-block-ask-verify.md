---
observation_id: sandwich-verifier-S351-block-ask-verify
type: sandwich-verifier-audit
verifier_agent_id: ab3c2575543eb609c
created_at: 2026-05-16
plan_audited: agent-workspace/session-plans/completed/024-S345-block-ask-gate-3-tier.md
dev_session_audited: S348 (commit 39bbb58)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 1 IMPORTANT (INLINE-RESOLVED) / 4 MINOR (deferred)
---

# S351 sandwich-verifier — Block/Ask Gate 3-Tier Verify

## Overall Verdict

**PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES**

The 3-tier model is correctly implemented and empirically verified through 6 live fixture tests. All 5 dev-flagged risk areas passed empirical probes. PENDING tier routing works (V3 + V8); HARD tier preserved (V4); ack flow E2E (V5); D5 shim handles legacy rows (V8); DD-10 UPS silence confirmed (V9). 1 IMPORTANT defect found + RESOLVED INLINE this turn (F1 trap-EXIT unbound-variable warning). 4 MINOR defects deferred with named triggers.

## V1 — DoD 40 items per plan § H

**Aggregate: 38/40 PASS, 1 N/A (DC-32 live verification), 1 PARTIAL (DC-40 pre-existing baseline noise).**

Highlights:
- DC-3 through DC-6: all 5 trigger types reclassified to PENDING (severity-classifier.sh:76-81, :104, :146-152, :168)
- DC-11: HARD_N>0 writes .autonomous-BLOCKED (V4 empirical fixture: flag written)
- DC-12: PENDING_N>0 populates .pending-queue.tsv (V3 empirical: row appended with PENDING tier)
- DC-14: UPS injection HARD_N only — PENDING silent (V9 empirical: 0 bytes stdout)
- DC-15: Telegram push keyed off HARD_N+HIGH_N — PENDING deferred (escalation-engine.sh:222)
- DC-23..27: ack subcommand complete (cmd_ack defined; slug whitelist; multi-ack supported; ack NEVER clears .autonomous-BLOCKED per comment line 250)
- DC-28: D5 shim hard removal date 2026-06-15 documented in 7 places (AP-7 anti-vacuous-defer)
- DC-31: settings.json wire correct (pending-queue-escalator AFTER escalation-engine — landed via main commit 52558cb post-coordination)
- DC-33: 55/55 new+modified fire-test TCs PASS (severity 16 + escalation 16 + pending-queue 6 + block-control 17 = 55)
- DC-35: Telegram smoke HTTP 200 msg_id 93 chat 891087440 verified in session log

## V2 — Sub-track delivery D1-D7

All 7 sub-tracks DELIVERED. D6 deferred-then-done (by main S349 commit 52558cb per coordination).

## V3 — DD compliance (DD-1..DD-12)

All 12 DDs UPHELD post-fixture verification.

## V4 — Charter/invariant compliance

0 charter / 0 constitution / 0 product code. D-068 lives in `memory/decisions/`. D-060 ✓ (1 dev commit / 0 pushes). D-062 atomic-write: ✓ for pending-queue-escalator + block-control cmd_ack; **F2 deferred for escalation-engine append-write**. D-064 path safety ✓ (basename + tr -dc whitelist; no traversal).

## V5 — Regression

- pytest collection 990 (matches S345 floor)
- ruff 4 pre-existing errors (NOT S348-introduced)
- bash-hook-lint 53/0 PASS
- run-all aggregate 108/111 (3 NEW TIMEOUTs from S347 commit d435ac0 modifying atomic-write/path-safety/python-determinism; NOT S348-regression — S348-time was 110/111)
- Telegram smoke accepted on faith per goal "do not push test message yourself"

## V6 — Integration smoke (empirical fixture tests)

- **V3 (.charter-violation-detected → PENDING)**: PASS. Fixture → severity-classifier ran → col6=PENDING action=BLOCK-PENDING → escalation-engine routed to `.pending-queue.tsv` with `escalate_at = now + 21600s` → NO `.autonomous-BLOCKED`
- **V4 (synthetic CRITICAL+HARD)**: PASS. Hand-crafted state.tsv with `\tHARD` col6 → escalation-engine emitted "1 HARD items detected" + wrote `.autonomous-BLOCKED` flag
- **V5 (ack flow E2E)**: PASS. Queue with 3 rows → `block-control.sh ack stale-checkpoint` archived 1 + preserved 2 → check-prompt path archived 2nd row
- **V8 (D5 shim legacy row)**: PASS. 5-col legacy → routed to PENDING with synthetic ID → NO autonomous-BLOCKED
- **V9 (DD-10 UPS silence)**: PASS. PENDING-only state.tsv → 0 bytes stdout on UserPromptSubmit
- **Goal #5 (check-prompt stdin + HARD clear)**: PASS. HARD fixture → autonomous-BLOCKED → `echo '{"prompt":"approved"}' | check-prompt` → flag removed

**ALL test fixtures cleaned up post-verification per M-S342-1 anti-recurrence.**

## V7 — Telegram smoke replay

NOT re-pushed (per goal "do not push test message yourself"). Dev's evidence in session log accepted: HTTP 200 msg_id 93 at 2026-05-16T20:06:03+07:00 to chat 891087440.

## Defects

### IMPORTANT (RESOLVED INLINE this turn)

**F1 RESOLVED** — block-control.sh cmd_ack emitted `TMP_ACK: unbound variable` warning to stderr on EXIT. Cause: `local TMP_ACK=...` at function scope; `trap '...$TMP_ACK' EXIT` fires AFTER local scope ends → `set -u` errors on bare $TMP_ACK. Functional impact: NONE (rows archived correctly per V5). Inline fix this turn: `trap 'rm -f "${TMP_ACK:-}" 2>/dev/null || true' EXIT` (parameter expansion suppresses unbound). Re-verified: ack flow runs clean, fire-test still 17/17 PASS.

### MINOR (deferred with named triggers)

**F2 — escalation-engine.sh PENDING-queue write is non-atomic**
`escalation-engine.sh:150` uses `>>` append vs DD-11 "tmp + mv -f + trap EXIT". Race-prone only if parallel Stop hooks ever land. Mitigation: bash Stop chain serialized by Claude Code hook invocation. Defer to next harness FOCUSED_IMPL session.

**F3 — TC-D4-5 negative-test passes via content-mismatch not regex-deny**
`ack nowledgement` HITS the regex (RC=0); test asserts ROWS_AFTER ≥ 3 → passes because no row matches slug, NOT because regex denied. Test-quality issue. Recommendation: add TC-D4-7 asserting regex DENY directly.

**F4 — D6 wire-up shipped without "Stop" positional arg per plan spec**
Plan D6 said `pending-queue-escalator.sh Stop`; actual settings.json:456 has no arg. Functional impact NONE (hook doesn't read $1). Plan-spec drift; update plan OR settings to match.

**F5 — Commit message TC arithmetic mismatch**
Commit f9d4f60 message claims "28 across 4 files" but actual count is 25. Dev observation has correct count. Audit-trail noise only.

## Promotion candidates (queue for next harness session)

- **L-S351-1**: `local`-scoped variable in `trap EXIT` cleanup triggers unbound-variable under `set -u`. Promote to bash-hook-lint Pattern G candidate. (F1 root cause; now fixed but pattern recognition needed.)
- **L-S351-2**: D-062 atomic-write should be enforced consistently — `escalation-engine.sh` uses direct `>>` append; only pending-queue-escalator + cmd_ack use TMP+mv. Promote to bash-hook-lint Check for ".tsv writes inside if-file-exists scope expect TMP+mv pattern".
- **L-S351-3**: Negative-test discipline (TC-D4-5 type defect): tests that assert "feature X does NOT trigger Y" should verify via expected path (regex deny) not unexpected coincidence (slug mismatch).
- **L-S351-4**: Commit message TC count arithmetic auto-verify pre-commit. Promote: PreToolUse hook on `git commit` that grep-counts TC definitions in changed `*-fire-test.sh` files vs message claim.

## Compliance attestation

- harness_priority_one ✓ (full harness focus)
- AP-1 fresh-context ✓
- 0 charter / 0 constitution / 0 product code
- 0 commits / 0 pushes (verifier)
- VBW ✓ (re-read all 4 hooks + plan + observation + session log)
- M-S342-1 anti-recurrence ✓ (ALL test fixtures cleaned)
- F1 inline-fix by main is applying-per-mandate (precedent S339 9eaeed1) NOT self-review

## Recommendations

**MERGE** at commits 39bbb58 (dev) + 52558cb (main wire-up) + (this turn F1 inline-fix). All 4 MINOR concerns have named revisit triggers. Promote L-S351-1..4 in next harness session.
