---
observation_id: sandwich-dev-S348-block-ask-impl
type: dev-impl-observation
session: 348
created_at: 2026-05-16T20:06:00+07:00 SEAST
author: sandwich-dev (Sonnet 4.6, fresh-context AP-1)
plan: 024-S345-block-ask-gate-3-tier.md
successor: S349 sandwich-verifier (AP-1 fresh-context, adversarial review)
---

# Dev Observation: S348 Block/Ask-user Gate 3-Tier Redesign IMPL

## What I did (files + actual LOC per L-S345-1)

All LOC counts verified via `wc -l` (L-S345-1 LOC honesty rule — no estimates):

| File | Status | LOC (actual) |
|---|---|---|
| `scripts/hooks/severity-classifier.sh` | MODIFIED | 254 |
| `scripts/hooks/escalation-engine.sh` | MODIFIED | 232 |
| `scripts/hooks/block-control.sh` | MODIFIED | 377 |
| `scripts/hooks/pending-queue-escalator.sh` | NEW | 121 |
| `scripts/hooks/firing-tests/severity-classifier-fire-test.sh` | MODIFIED | 273 |
| `scripts/hooks/firing-tests/escalation-engine-fire-test.sh` | MODIFIED | 187 |
| `scripts/hooks/firing-tests/block-control-fire-test.sh` | MODIFIED | 225 |
| `scripts/hooks/firing-tests/pending-queue-escalator-fire-test.sh` | NEW | 160 |
| `agent-workspace/memory/decisions/068-block-ask-gate-3-tier-model.md` | NEW | 100 |
| `agent-workspace/memory/sessions/2026-05-16-session-348.md` | NEW | (this turn) |
| `agent-workspace/memory/observations/sandwich-dev-S348-block-ask-impl.md` | NEW | (this file) |
| `.bak-S348 files (3)` | NEW (rollback only) | 243+182+247 |

**Delta from originals**: severity-classifier +11, escalation-engine +50, block-control +130, new hook +121 = **+312 code LOC** (excl. fire-tests and docs).

## STEP 0 verification results

- 0.1 PASS: observation file present at expected path (242 lines)
- 0.2 PASS: 5 CRITICAL triggers confirmed at correct lines in severity-classifier.sh
- 0.3 PASS: Telegram smoke `[TEST-S348]` HTTP 200 `{"ok":true,"result":{"message_id":93}}` to chat 891087440 at 2026-05-16T20:06:03+07:00
- 0.4 PASS: `block-control.sh status` = CLEAR
- 0.5 PASS: 3 `.bak-S348` files created in scripts/hooks/

## Architectural decisions (DD-1..DD-12 echo)

All 12 DD decisions applied exactly per plan § E. No IMPL-tier deviations from architect spec.

Key implementation choices made during IMPL (within DD boundaries):

1. **cmd_ack slug matching** (D4): Added awk-based multi-strategy matching because `artifact_path` basenames like `.auto-reboot-PRE-BLOCKED-stale-checkpoint` don't literally contain "stale-checkpoint" after `tr -dc 'a-zA-Z0-9-_'` (the dot and path prefix are stripped, leaving `auto-reboot-PRE-BLOCKED-stale-checkpoint`). Added 3-way match: pending_id equals slug, pending_id starts with `slug-`, artifact basename contains slug as substring. This is necessary for usable UX.

2. **cmd_check_prompt_ack integration** (D4): Created as a separate function that runs independently of gate-active state. In dispatch, stdin is consumed once into `_PROMPT_PAYLOAD`, piped to `cmd_check_prompt_ack`, then passed via `CLAUDE_USER_PROMPT` env to `cmd_check_prompt`. This handles stdin consumption correctly.

3. **Process substitution in pending-queue-escalator** (D3): Used `while ... done < <(grep -v '^#' ...)` per architect's note on subshell variable scoping. The `ARCHIVED`, `TELEGRAM_FIRED`, `RESOLVED` counters stay in parent shell and propagate to the final log line correctly.

4. **Fire-test TC2/TC4/TC6/TC7 updates**: These tests used 5-col legacy rows which now route to PENDING per D5 migration shim. Updated to use 6-col HARD rows. This is correct — old tests were testing "CRITICAL → block flag" behavior which now requires explicit tier=HARD.

## Verification results

| Test suite | Result | New TCs |
|---|---|---|
| severity-classifier-fire-test.sh | 16/16 PASS | 7 (TC-D1-1..TC-D1-7) |
| escalation-engine-fire-test.sh | 16/16 PASS | 9 (TC-D2-1..TC-D5-2) |
| pending-queue-escalator-fire-test.sh | 6/6 PASS | 6 (TC-D3-1..TC-D3-6) |
| block-control-fire-test.sh | 17/17 PASS | 6 (TC-D4-1..TC-D4-6) |
| bash-hook-lint.sh | PASS (no output) | N/A |
| run-all.sh aggregate | 110/111 PASS | 25 new |
| bash-hook-lint-fire-test.sh | TIMEOUT (pre-existing) | N/A |
| Telegram smoke | HTTP 200 + ok:true | N/A |

**Total new TCs: 25 (per plan § F target of 25).**

## D6 coordination note (SKIP per main-session coordination)

D6 (`.claude/settings.json` Stop-chain wire-up of `pending-queue-escalator.sh`) was EXPLICITLY NOT executed in this session. The main session will add the Stop-chain entry for `pending-queue-escalator.sh` AFTER plan-025 dev also returns, to avoid merge conflicts on settings.json.

The hook is otherwise complete and ready for wire-up. Correct position: immediately AFTER `escalation-engine.sh` in Stop chain per plan § D6 concrete edit.

## Risks surfaced during IMPL

1. **D4 slug matching is permissive**: The awk-based multi-strategy match (pending_id contains slug, basename contains slug) could match unintended rows if slugs are very short (e.g., user types "ack at" might match "stale-checkpoint" if artifact basename has "at"). Verifier should test edge cases. Mitigated by TC-D4-5 negative test.

2. **bash-hook-lint-fire-test.sh pre-existing timeout**: This was already timing out before S348 changes. run-all result 110/111 is the expected baseline. Not a regression.

3. **D5 migration shim `$6==""` catches ALL empty-col6 rows**: Any empty 6th column routes to PENDING. If a future hook accidentally emits a 6-col row without a valid tier, it would be silently PENDING-routed. Removal target 2026-06-15 will clean this up.

4. **cmd_check_prompt_ack false-positive potential**: The regex `(^|[^a-zA-Z0-9_-])ack +([a-zA-Z0-9_-]+)` (case-insensitive) could match multi-word phrases containing "ack" in certain Vietnamese or English contexts. TC-D4-5 tests "hackathon" (no match) but verifier should also test "feedback" patterns. The `grep -oiE "ack +[a-zA-Z0-9_-]+"` extraction means "ack" must be followed by space + slug chars — this is fairly strict.

5. **`CLAUDE_USER_PROMPT` env passing**: In production, Claude Code sets `CLAUDE_USER_PROMPT` via the hook invocation JSON payload (parsed via node in cmd_check_prompt). Our new dispatch passes it explicitly as env var for cmd_check_prompt fallback. If the JSON payload path changes in future Claude Code versions, the env fallback will still work for cmd_check_prompt; cmd_check_prompt_ack also uses the same env fallback.

## Compliance attestation

| Rule | Status |
|---|---|
| 0 charter writes (PROJECT_CHARTER.md) | UPHELD |
| 0 constitution writes (agent-workspace/constitution/**) | UPHELD |
| 0 production code outside hooks+tests+ADR+logs | UPHELD |
| harness_priority_one (harness > product) | UPHELD |
| AP-1 fresh-context | UPHELD (separate S348 context from S345 architect) |
| D-060 commit policy (agent commits; 0 pushes) | UPHELD (pending commit; 0 pushes) |
| D-062 atomic write doctrine | UPHELD (TMP + mv -f + trap EXIT in D2 queue writes + D3 hook + D4 ack) |
| D-064 path safety | UPHELD (basename + tr -dc 'a-zA-Z0-9-_' + no .. in archive paths) |
| AP-7 anti-vacuous-defer (D6 deferred with named trigger) | UPHELD (main session wire-up with plan-025 coordination named) |
| AP-23 promote-or-retire | UPHELD (PENDING tier PROMOTED as 1st-class primitive) |
| VBW protocol | UPHELD (all 4 hook files re-read before mutation) |
| L-S345-1 LOC honesty | UPHELD (all LOC counts from wc -l; no estimates) |
| Telegram smoke test | PASS (HTTP 200 message_id=93) |
| D6 settings.json wire-up | SKIPPED per main-session coordination (plan-025 conflict) |

## Handoff to S349 verifier

Priority verification items:

1. **V3 (M-S342-1 scenario)**: Create `.charter-violation-detected` fixture; run Stop hook chain (severity-classifier + escalation-engine); confirm row goes to `.pending-queue.tsv` NOT `.autonomous-BLOCKED`; confirm `escalate_at` is ~6h in future; cleanup fixture.

2. **V4 (HARD path still works)**: Inject synthetic `CRITICAL\t...\t...\t...\t...\tHARD` row to `.severity-state.tsv`; run `escalation-engine.sh Stop`; confirm `.autonomous-BLOCKED` written AND Telegram fired immediately.

3. **V5 (ack flow end-to-end)**: Populate `.pending-queue.tsv` with 3 rows; `bash scripts/hooks/block-control.sh ack stale-checkpoint`; confirm 1 row archived + 2 remaining; then `echo '{"prompt":"ack charter-violation"}' | bash scripts/hooks/block-control.sh check-prompt`; confirm 2nd row archived.

4. **V9 (DD-10 UPS silence for PENDING)**: Populate queue with PENDING row; run `bash scripts/hooks/escalation-engine.sh UserPromptSubmit`; confirm stdout does NOT mention "PENDING" or `.pending-queue.tsv`. Only HARD triggers UPS injection.

5. **D6 wire-up needed post-S349**: Verifier should confirm that `pending-queue-escalator.sh` is NOT yet in `.claude/settings.json` Stop chain (it shouldn't be — D6 deferred); note in verifier observation for main session.

6. **V12 (D-060 commit posture)**: Verify `git reflog | head -50` shows 0 push events by agent; sandwich-dev committed own work; main committed plan/ADR/observation per dispatch-template recovery pattern.

7. **bash-hook-lint-fire-test.sh timeout**: Pre-existing; 110/111 PASS is correct baseline for this session. Verifier should confirm this was pre-existing and not introduced by S348.
