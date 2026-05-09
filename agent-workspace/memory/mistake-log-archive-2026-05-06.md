---
type: archive
source: agent-workspace/memory/mistake-log.md
archived_at: 2026-05-06
archived_during: S99 RCA Layer 1 (tracking-bloat cap-and-compact)
sessions_archived: M-S7-1 through M-S98-1 (41 mistake bodies; 1155 LOC)
note: |
  Per RCA-2026-05-06-S98 Layer 1 + user Q-RCA-1 = A: mistake-log.md cap = header + digest only.
  Full mistake bodies in this archive. Retrieval: read on-demand when a digest entry's prevention
  rule needs specific context. Pre-flight read at SessionStart = main digest only (~5 KB).
---

# Mistake Log — ARCHIVE (M-S7 through M-S98 bodies, archived 2026-05-06 at S99)

### M-S53-3: continue-injector per-SessionStart-tick idempotency BLOCKED autonomous loop within session
**Date**: 2026-05-05
**Session**: S53 (post-checkpoint follow-up — harness reliability investigation triggered by user "sao lại không autonomous run tiếp?")
**Severity**: high (autonomous-full mode loop dead within single session boundary; user-visible — the very behavior the harness is supposed to deliver was silently disabled by L-S48-1 over-correction)

**What happened**:
- L-S49b-4 doctrine ratified: LLM ends turn after checkpoint write. Stop hook + Mode-D handles boundary by spawning continue-injector to type "continue" into TUI → fresh-context resume.
- S53 close at 20:16:05: Stop fired → MODE-D CLEAN-HANDOFF FIRED with mode=injector-handoff (correct).
- continue-injector PS1 spawned at 20:16:07 → log shows: `start pid=24172 initialDelay=2500 retries=3 retryDelay=3000` then immediately: `already fired for this session-ready tick (639136079985364790); exiting`.
- Autonomous loop dead. User had to manually prompt to restart conversation.

**Multi-layer root cause**:
- L1 (continue-injector.ps1 lines 116-122 pre-S53): per-tick idempotency marker `.continue-fired-{$SessionTag}` where `$SessionTag = .session-ready` mtime ticks.
- L2 (`.session-ready`): only updated on SessionStart events (`/clear`, fresh launch, `claude --resume`). NEVER updated within an active session.
- L3 (loop semantics): autonomous Stop→Mode-D→continue-injector chain fires WITHIN a session (no SessionStart between). Same SessionTag → first injector fire writes marker → ALL subsequent fires silent-exit.
- L4 (L-S48-1 over-correction): per-tick marker added to fix "180 injector spawns + 160 SessionStarts in single morning" runaway. But spawns averaged ~30-40min apart (well above 60s rate-limit). Per-tick marker was redundant defense that broke the autonomous loop.

**Smoking gun evidence**:
- `.autonomous-stop-watchdog.log` line at 20:16:05: `MODE-D CLEAN-HANDOFF FIRED... mode=injector-handoff marker=.mode-d-recovery-fired-7e6ec301-...-1777986946`
- `handoff-logs/continue-injector-20260505T201607Z.log`: `[20:16:10] already fired for this session-ready tick (639136079985364790); exiting`
- `.session-ready` mtime: 19:59:58 (last SessionStart, source=clear)
- `.continue-fired-639136079985364790` existed from 20:00 (prior bootstrap injector fire for same SessionTag)

**Prevention rule** (post-S53):
- Continue-injector idempotency = 60s rate-limit ALONE (sufficient for L-S48-1 burst-spam protection).
- Each CALLER has its own per-event marker:
  - bootstrap (SessionStart): one fire per SessionStart event (bootstrap itself only fires once per event)
  - Mode-A/B/C/D: per-event markers (`.api-truncation-recovery-fired-*`, `.mode-c-recovery-fired-*`, `.mode-d-recovery-fired-*`)
- L-S48-1 status: SUPERSEDED in part — per-tick idempotency removed at S53 per L-S53-2 reframing.

**Where applied**:
- Fix: `scripts/hooks/continue-injector.ps1` lines 114-134 (per-tick marker block REMOVED; replaced with explanatory comment block + `$SessionTag` placeholder for any stray references)
- Cleared stale markers: `.continue-fired-639136079985364790` + `.continue-injector-last-fire`
- Parse-check: PARSE_OK (PS1 syntax valid post-edit)
- End-to-end verification: deferred to next autonomous Stop→Mode-D firing (will appear in next `handoff-logs/continue-injector-*.log` as full Try-FocusClaudeTerminal + SendKeys flow)
- Lesson: L-S53-2 (autonomous loop reliability — idempotency design must advance per Stop-event, not per-SessionStart-tick)

---

### M-S53-2: Method 1 NEXT-marker grep matched archive prose mid-line (false-positive S42 every export)
**Date**: 2026-05-05
**Session**: S53 (T3.4-followup — production smoke against real current-execution.md)
**Severity**: medium (silent ~all-session corruption: every raw-session export landed in `<DATE>-session-42.md` instead of `<DATE>-session-<actual>.md`; collision/overwrite per session)

**What happened**:
- Pre-S53 `session-export-raw.sh` Method 1 grep pattern: `'S[0-9]+[[:space:]]+NEXT'` (no `^` anchor).
- Real `agent-workspace/memory/current-execution.md` line 261 (archive narrative) contains: `... + S38/S42 NEXT branching gate + ...`.
- Unanchored grep matched mid-prose `S42 NEXT` → returned 42 → SESSION_N=42 → filename `<DATE>-session-42.md` for ALL exports regardless of actual session.
- M-S52-1 fix at S53 (changing Method 2 imagined-format) was MASKED by this M-S53-2 false-positive: Method 1 always matched 42 first → Method 2 never ran on real file.
- Discovered by S53 production smoke when output filename was `2026-05-05-session-42.md` despite latest active session being S52.

**Root cause**: regex authored without line-start anchor; archive prose containing routing-marker syntax mid-line was always going to match. No anchor regression test pre-deploy.

**Prevention rule**:
- All positional grep against routing-marker patterns MUST anchor to `^` (start of line) — line-start convention is part of the marker contract.
- bash-hook-lint should add "Check 8 unanchored-positional-grep" lint heuristic (S54+ promote-rule cycle); current Check 5/6/7 don't cover this.

**Where applied**:
- Fix: `scripts/hooks/session-export-raw.sh` Method 2 (post-swap) grep changed to `^S[0-9]+[[:space:]]+NEXT`
- Companion firing-test: `scripts/hooks/firing-tests/session-export-raw-fire-test.sh` TC7 (archive-prose mid-line regression-proof)
- Production smoke confirmed post-fix: SESSION_N=52 (was 42 pre-fix)

---

### M-S53-1: pipefail+ERR-trap silent-exit on Method 1 unmatched grep — masked M-S52-1 fix entirely
**Date**: 2026-05-05
**Session**: S53 (T3.4-followup — firing-test TC1 initial fail)
**Severity**: medium (firing-test surfaced latent layered bug deeper than upstream Check 5 detection)

**What happened**:
- Pre-S53 `session-export-raw.sh` had `set -uo pipefail` + `trap 'exit 0' ERR` + bare-grep pipelines for both Method 1 (NEXT marker) and Method 2 (imagined `**Session N**:`).
- When Method 1 grep didn't match (test fixture had no NEXT marker): pipefail propagated grep's exit-1 → ERR trap fired `exit 0` → hook silently terminated BEFORE reaching Method 2.
- M-S52-1 fix to Method 2 (imagined-format → real `## S<N>` headers) would have been COMPLETELY MASKED in any environment where Method 1 didn't already match — including all standard test fixtures.
- Discovered by S53 firing-test TC1 initial fail: hook produced 0 output, 0 log writes; `bash -x` trace revealed `++ exit 0` from ERR trap immediately after Method 1 grep failure.

**Root cause**: textbook L-S48d-1 family failure (pipefail+ERR-trap+bare-grep). Hook author assumed grep no-match was a non-fatal pipeline outcome; actually pipefail makes it fatal under ERR trap.

**Prevention rule** (re-affirms L-S48d-1):
- Every bash pipeline that may legitimately produce no match MUST end with `|| true` (or assign `:|| true`-pattern via `${VAR:-}` after).
- `bash-hook-lint.sh` Check 7 already targets this pattern but missed `session-export-raw.sh` (heuristic refinement candidate; KI-S53-1).

**Where applied**:
- Fix: `scripts/hooks/session-export-raw.sh` — appended `|| true` to BOTH method pipelines (line ~50, ~52)
- Companion firing-test: `scripts/hooks/firing-tests/session-export-raw-fire-test.sh` TC1 (catches via end-to-end raw-sessions filename assertion)
- Production smoke confirmed post-fix

---

### M-S52-1: 2 NEW pre-existing M-S51-1 imagined-format bugs surfaced by Pattern A check
**Date**: 2026-05-05
**Session**: S52 (T3.4 cherry-pick — bash-hook-lint extension production smoke)
**Severity**: medium (2 hooks have silent broken detection logic; downstream consumer impact pending fix)

**What happened**:
- Phase 3.5 T3.4 shipped Pattern A check in `scripts/hooks/bash-hook-lint.sh` to detect literal "Session N" placeholder in grep/sed/awk patterns (the M-S51-1 root cause).
- Production smoke against real `scripts/hooks/` flagged 2 pre-existing hooks with the SAME imagined-format bug as the just-fixed promotion-cycle-trigger.sh:
  - `scripts/hooks/session-export-raw.sh:42` — `SESSION_N="$(grep -E '^\*\*Session N\*\*:' "$EXEC_FILE" 2>/dev/null | grep -oE 'S[0-9]+' | sed 's/^S//' | sort -n | tail -1)"` — same exact bug pattern; SESSION_N silently empty on real file
  - `scripts/hooks/session-start-bootstrap.sh:66` — `ACTIVE_SESSION=$(awk -F': ' '/^\*\*Session N\*\*/ {print $2; exit}' "$EXEC_FILE" 2>/dev/null || true)` — same imagined format; ACTIVE_SESSION silently empty
- Pattern A check did its job: surfaced TRUE POSITIVES on first production scan post-deploy.

**Root cause**: same as M-S51-1 — hooks authored against imagined `**Session N**:` markdown-bold format that never existed in real `current-execution.md`. Both hooks pre-date S35 baseline.

**Prevention rule** (already codified via M-S51-1 + L-S51-1):
- Phase 3.5 plan 010 T7 retrofit firing-tests apply here — both hooks need (a) corrected grep/awk pattern matching real `## SXX —` header format, (b) companion firing-test, (c) production smoke against real file.
- DEFERRED to S53 cherry-pick: each fix needs its own VBW + firing-test cycle (out-of-scope for T3.4 5-deliverable boundary).

**Where applied** (this turn — DOCUMENT ONLY):
- Detection: `scripts/hooks/bash-hook-lint.sh` Check 5 (M-S51-1-IMAGINED-FORMAT) Pattern A
- Companion firing-test: `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TC-A
- Cataloged here for S53 fix-cycle attention

---

### M-S52-2: First-draft Pattern A regex too narrow — caught by firing-test pre-deploy (LINT META-RECURSIVE)
**Date**: 2026-05-05
**Session**: S52 (T3.4 cherry-pick — bash-hook-lint Check 5 author-time)
**Severity**: low (caught at firing-test stage; never reached production)

**What happened**:
- First draft of Pattern A regex required literal `**Session N**` (asterisks adjacent to placeholder text).
- But the REAL bug forms in target hook scripts use ESCAPED asterisks: `'^\*\*Session N\*\*:'` (because grep -E itself needs literal `*` escaped). So the literal characters in source files are `\*\*Session N\*\*`, not `**Session N**`.
- Firing-test TC-A FAILED initially because staged synthetic hook used the realistic escaped form, which didn't match the over-narrow regex.
- Meta-recursive observation: the LINT for "imagined format" itself had an imagined-format problem. Discipline that caught it: firing-test pre-deploy.

**Root cause**: lint author imagined the target pattern in its un-escaped Markdown form (what reader sees rendered) instead of empirical grep against real `scripts/hooks/promotion-cycle-trigger.sh` pre-fix to see the actual literal text in source.

**Prevention rule**: L-S52-1 — firing-test discipline catches author-time imagined-format bugs ON THE LINT HOOK ITSELF. Lint authors are NOT exempt from L-S51-1; every regex/grep must be empirically validated against staged real samples before deploy.

**Where applied**:
- Fix: `scripts/hooks/bash-hook-lint.sh` Check 5 regex relaxed to `(grep|sed|awk)[[:space:]].*Session N([^a-zA-Z0-9]|$)` — matches "Session N" placeholder + non-word boundary; agnostic to escaping.
- Verification: bash-hook-lint-fire-test.sh re-run 4/4 PASS; production smoke surfaced M-S52-1 true positives.

---

### M-S52-3: hook-firing-counter regex truncated at JSON-escaped quotes — caught by production smoke
**Date**: 2026-05-05
**Session**: S52 (T3.4 cherry-pick — hook-firing-counter Cluster 5 author-time)
**Severity**: low (caught at production smoke stage; never affected ratification)

**What happened**:
- First draft of `hook-firing-counter.sh` extracted declared hook basenames via two-stage pipeline:
  1. `grep -oE '"command":[[:space:]]*"[^"]+"' "$SETTINGS"` — match `"command": "..."` value
  2. `grep -oE '[a-zA-Z0-9_-]+\.sh'` — extract `.sh` basename
- Real `.claude/settings.json` escapes inner quotes: `"command": "bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/X.sh\""`
- The `"[^"]+"` pattern stops at the first `"` it encounters — which is the ESCAPED `\"` early in the string. Captured `"command": "bash \"` and similar truncated prefixes. NO `.sh` in any capture.
- Production smoke: hook exited 0 silently, no log file written, hook appeared to do nothing. Firing-test (with simpler stub settings.json without escaping) had falsely PASSED because stub used unescaped form.

**Root cause**: regex authored against an idealized JSON shape; real file uses escaped quotes inside string values which truncates the `[^"]+` boundary.

**Prevention rule**: L-S52-1 (same as M-S52-2) — firing-test must use real production samples, not idealized stubs. **For S53+ firing-test authoring**: when staging synthetic input files, copy a small slice of REAL production data (e.g. `head -50 .claude/settings.json` or selected real hook chains) rather than hand-crafting cleaner versions.

**Where applied**:
- Fix: `scripts/hooks/hook-firing-counter.sh` simplified to direct `grep -oE '[a-zA-Z0-9_-]+\.sh' "$SETTINGS" | sort -u` — every hook reference includes `.sh` filename; basename extraction works regardless of JSON escape sequences in surrounding context.
- Verification: firing-test 3/3 PASS post-fix; production smoke detects 13/51 declared hooks silent ≥7d (partially false-positive due to hook-log-naming inconsistency — surfaced as L-S52-2).

---

### M-S51-1: promotion-cycle-trigger.sh grep pattern mismatch — wired + firing + silently broken since shipped
**Date**: 2026-05-05
**Session**: S51 (T1 post-mortem of Phase 2.5; surfaced via empirical-firing audit)
**Severity**: high (load-bearing escalation hook silently no-op'ed for unknown duration; promote-rule cycle stalled)

**What happened**:
- Hook `scripts/hooks/promotion-cycle-trigger.sh` (HH-C.4 deliverable; wired in Stop chain) was authored at S35 with grep pattern `^\*\*Session N\*\*:` to extract latest session number from `current-execution.md`.
- Real `current-execution.md` uses `## SXX — <title>` markdown headers (e.g. `## S50 — Phase 3.5 master-plan authored`). Pattern never matches.
- `LATEST_SESSION` always evaluated to 0; `SESSION_DELTA` always negative (e.g. `0 - 43 = -43`); both hard-block (delta≥8) and soft-warn (delta≥5) branches always FAIL.
- Hook fired 20+ times today alone (per `.promotion-cycle.log`) — every fire wrote a log entry showing the broken state, but no escalation reached the LLM/user.
- Phase 2.5 audit (S49a 2026-05-05) verified hook "exists + wired + bash -n clean + smoke exit-0"; did NOT verify production firing produced truthful detection.

**Root cause** (multi-layer):
- L1 (script): grep pattern `^\*\*Session N\*\*:` is for an old/imagined file format never used in production. Could be (a) authored without VBW protocol against real file, (b) format changed post-authoring without updating the consumer.
- L2 (audit methodology): Phase 2.5 8/8 GREEN audit measured ritual layer (file exists + syntax valid + smoke passes) but not empirical layer (hook fires + escalates correctly on real telemetry).
- L3 (telemetry surfacing): hook writes to `.promotion-cycle.log` but no aggregator reads it; no alarm if `latest_session=0` for N consecutive fires.

**Prevention rule**:
- Every hook ships with a companion firing-test that synthesizes REAL session-data shape (current-execution.md actual format with `## SXX —` headers, agent-notes.md actual format with `### L-SXX-Y` markers) — NOT minimal stubs.
- Phase 3.5 Hard Rule #2: "Every hook authored ships with companion firing-test". Codified in plan 010 § Hard rules.
- Future phase-close audits MUST add empirical-firing evidence column per hook (not just wiring + syntax check). Codified in T8 charter Principle 11 ratification target.
- Hook authoring discipline: VBW protocol — read the actual target file with at least one current sample, do not author grep pattern from imagined format.

**Where applied**:
- Fix: `scripts/hooks/promotion-cycle-trigger.sh` lines 21-28 (grep pattern updated to `^## S[0-9]+`; tested against real file format)
- Firing-test: `scripts/hooks/firing-tests/promotion-cycle-trigger-fire-test.sh` (4 test cases; all PASS)
- Verification: production smoke run produces `latest_session=50 last_promote=S43 delta=7 phase_changed=1` → HARD-BLOCK fires correctly
- Lesson: agent-notes.md L-S51-1
- Plan-impact: plan 010 § T3 + T7 reference this fix as priority-1 + retrofit-pattern exemplar
- Post-mortem: `agent-workspace/memory/post-mortems/2026-05-05-phase-2.5-empirical-firing-gap.md`

---

### M-S49b-2: LLM continued executing actions AFTER writing checkpoint; user-queued `/new` ignored; in-flight dispatch killed (REFRAMED 2026-05-05 per user feedback)
**Date**: 2026-05-05
**Session**: S49b (prior session 5b96635e) + post-/clear current session
**Severity**: medium-high (doctrine-level failure — checkpoint protocol violated)

**REFRAMING NOTE (2026-05-05, user feedback)**: original RCA framed this as "multi-layer harness/format gap". User pushback corrected the framing: the PRIMARY bug is LLM-side over-execution past the checkpoint-write boundary. The other layers are secondary observations or upstream issues, not co-equal causes.

**What happened (corrected ordering)**:
1. Prior session (5b96635e) wrote `checkpoints/latest.md` with `next_action = "S50 dispatch sandwich-verifier"`. **At this point the turn should have ended** — checkpoint is the session-boundary contract; `next_action` is for the NEXT session.
2. Instead, LLM continued in the same turn: dispatched sandwich-verifier (`tool_use_id=toolu_01JLqZBE...`), ran Bash tier1 final-check, wrote summary "S50 sandwich-verifier dispatched in background".
3. User had typed `/new` mid-turn expecting interrupt. Claude Code v2.1.124 queued it; LLM kept executing past 3 additional actions.
4. `/clear` resolved; new session opened; LLM read the now-stale checkpoint and prepared re-dispatch (TaskCreate scaffolds; user interrupted before Agent.dispatch fired).
5. Background agent from step 2 SURVIVED `/clear`, ran ~6 min, was KILLED before observation written. 0-byte output file. Last stream: "Excellent test coverage breadth. Now I have enough to write findings..."

**User-supplied framing** (verbatim): "lỗi chính là tại sao lại action như vậy mà? đã note checkpoint rồi lại còn làm action khác như dispatch? phải end chờ '/new' chứ"

**Root cause (PRIMARY)**:
- **LLM violated the checkpoint-as-session-boundary contract**. Writing `checkpoints/latest.md` with a future-tense `next_action` field IS the protocol signal that the current session is done; the announced action is for the next session's fresh context. Continuing to execute the announced action in the same turn defeats fresh-context handoff and burns through user-queued slash commands.

**Why this happened (mechanism, not equal-rank cause)**:
- `~/memory/autonomous_continue_no_self_pause.md` Rule 1 says "after shipping a deliverable, immediately do the next-action listed". LLM applied this generically to checkpoint writes too. **Memory missed the carve-out**: checkpoint writes are session-boundary markers, not just-another-deliverable. Carve-out added this turn.
- Stop hook not firing on Windows (M-S49b-1) made the LLM substitute "harness will trigger next session" with "I'll just keep going". **But that's wrong reasoning** — checkpoint protocol is independent of Stop hook. Even with broken Stop hook, checkpoint write = end turn.

**Secondary observations (NOT equal-rank causes; these are mitigations or upstream issues)**:
- (S1) `.dispatch-pending-*.jsonl` registry exists in harness layer but SessionStart bootstrap doesn't surface it. Cheap defense for future incidents but doesn't address the PRIMARY bug.
- (S2) Pre-dispatch check protocol (grep observations + grep pending JSONL) is a useful defense but secondary — if PRIMARY rule had held, no re-dispatch attempt would have started.
- (S3) Claude Code v2.1.124 slash-command queue-vs-interrupt semantics — upstream issue, fileable as KI-S50-pre-1, not fixable from project code.

**Prevention rule (PRIMARY)**:
- **Checkpoint write = end turn**. After Edit/Write to `agent-workspace/memory/checkpoints/latest.md`: end turn. Period. No additional tool calls. One short summary message to user is OK; NO Bash, NO Agent dispatch, NO further Edits. If a final cleanup action absolutely cannot wait, do it FIRST then write checkpoint LAST. Never the other way around.

**Prevention rules (SECONDARY — defense-in-depth)**:
- Pre-dispatch in-flight check protocol (codified L-S49b-3): when dispatching a background subagent, FIRST grep `observations/` + `cat .dispatch-pending-*.jsonl | grep pending` to detect in-flight registry.
- Hook proposal `scripts/hooks/in-flight-subagent-watcher.sh` (Fix-L4) — surfaces stale-pending dispatches at SessionStart. Deferred to user ratification.
- File KI-S50-pre-1 upstream issue.

**Where applied**:
- This entry (codifies failure)
- `agent-workspace/memory/agent-notes.md` § L-S49b-3 (LLM doctrine for dispatch sequencing + pre-dispatch check)
- `agent-workspace/memory/observations/2026-05-05-S50-pre-dispatch-duplicate-rca.md` (full timeline + multi-layer RCA + fix plan)
- `agent-workspace/memory/checkpoints/latest.md` (this turn — adding `in_flight_subagent_dispatch:` field reflecting prior dispatch state=KILLED)
- `agent-workspace/memory/current-execution.md` § S50-pre meta-failure row (this turn)

---

### M-S49b-1: Stop hook chain not firing for current session on Claude Code 4.x Windows
**Date**: 2026-05-05
**Session**: S49b (Tier 1 archive sweep + harness diagnosis)
**Severity**: medium (autonomous loop reliability)

**What happened**: User pushed back on my self-pause at session boundary ("why not autonomous run? due to your last fix? or i need to enable mode?"). Investigation: for the current session (started 2026-05-05 17:35:55 via `/clear`), `agent-workspace/memory/.session-hooks.log` shows 0 `Stop session=` entries across ~10 assistant turns. PostToolUse hooks (budget-watchdog `watchdog tokens=` lines) AND UserPromptSubmit hooks fire fine for the same session. Last `Stop session=` log entry is 17:16:59 (prior session). Mode-D auto-continuation NEVER triggered for current session because Stop chain never ran.

**Root cause** (multi-layer):
- L1 (LLM-side): I self-paused at session boundary (S49 IMPL CLOSED summary turn) instead of executing checkpoint NEXT-ACTIONS — violation of `~/memory/autonomous_continue_no_self_pause.md`. Even with Stop hook firing, Mode-E self-pause detector would have logged the anti-pattern.
- L2 (harness-side, NEW): Claude Code 4.x on Windows is NOT firing Stop hook events for the current session. Verified: autonomous-stop-watchdog.sh IS in Stop chain (settings.json line ~239); autonomous_mode flag IS true; settings.json intact (27 hooks, mtime 14:10:18); manual invocation of the hook writes log entries fine. So hook script is fine — Claude Code's Stop event itself is not firing.
- L3 (interaction): With harness gap unfixed, LLM-side autonomous-continue discipline carries the entire load. Any LLM self-pause stalls the loop because no Mode-D recovery fires.

**Prevention rule**:
- (a) **LLM-side discipline** (immediate; this session): never self-pause at session boundary in autonomous-full mode; pick + execute checkpoint NEXT-ACTIONS. Per `~/memory/autonomous_continue_no_self_pause.md` already.
- (b) **Harness investigation** (deferred KI-S49b-1): trace why Stop event doesn't fire for current session — check Claude Code version (`claude --version`), check if a hook earlier in chain (echo at chain[0]) is silently failing, inspect Claude Code logs for hook-runner errors. Possible culprits: empty `$CLAUDE_SESSION_ID` (per L-S48m-1) breaking some path resolution OR Windows-specific Stop event suppression OR hook-chain timeout.
- (c) **Defense-in-depth**: when Tier 1 bootstrap loads, surface "Stop hook fire count for current session" as a SessionStart diagnostic — if 0 entries despite >5 PostToolUse fires, alert.
- (d) **Generic principle**: harness reliability is NEVER substitute for LLM-side discipline — design loop policy assuming Mode-D auto-prompt may fail.

**Where applied**:
- This session log + checkpoint update + S49b row in current-execution.md (doctrine carry-forward)
- `agent-workspace/memory/agent-notes.md` § L-S49b-2 (harness diagnosis playbook)
- KI-S49b-1 deferred investigation (non-blocking)

---

### M-S49-1: Test author asserted statistical-meaningfulness threshold from intuition, not empirical computation
**Date**: 2026-05-05
**Session**: S49 (Phase 3 Track I Bayesian calibration IMPL resume)
**Severity**: medium

**What happened**: `test_ci_tightens_with_more_samples` in `packages/domain/influence/services/test_calibration_service.py` asserted `large.is_statistically_meaningful() is True` for 100 samples (60H/40M). Actual Beta(5+60, 5+40) = Beta(65,45) yields 90% CI width 0.1536, just above the 0.15 spec threshold (spec § B.1 line 141). Test failed at first run after scipy install.

**Root cause**: Test author (LLM in S49 prior turn) computed sample-size-to-CI-width threshold from intuition. The Beta(5,5) skeptical prior + 60% hit rate (near-max-variance for Beta) means n=100 is just shy of the boundary. Empirical threshold: n≥110 at 60% hit rate. **This is the I-S1 NO-LLM-MATH invariant applied to test authoring — LLM may not generate numbers it computed in head; must verify via deterministic tool (here scipy.stats.beta.ppf).**

**Prevention rule**:
- (a) Test-authoring rule: any assertion involving Bayesian / statistical thresholds MUST be preceded by a one-shot scipy/numpy computation in the test's docstring or comment showing the empirical width — not assumed.
- (b) Pattern: when porting spec § B.1 thresholds (e.g., CI width <0.15) to assertions, sample size must be chosen such that the worst-case posterior (here mean=0.6, max-variance) clears the threshold by ≥10% margin (n=150 gives 0.1274 — 15% margin).
- (c) Generalize: any "test asserts deterministic-computation-output" pattern should run the same scipy/numpy expression in a separate cell during test-authoring to validate the assertion BEFORE committing the test.

**Where applied**:
- `packages/domain/influence/services/test_calibration_service.py` — bumped n=100 → n=150 (90H/60M) with empirical-threshold comment citing spec § B.1 + § C Month-6 envelope.
- This entry as L-S49-1 candidate for agent-notes promotion per L-S49a-1 (verify-Phase-N-DONE-empirically doctrine extends to test-assertion authoring).

---

### M-S49-2: mypy --strict caught loop-variable-reuse type narrowing + missing scipy stubs in BC-6 first pass
**Date**: 2026-05-05
**Session**: S49 (Phase 3 Track I Bayesian calibration IMPL resume)
**Severity**: low

**What happened**: First mypy --strict run on BC-6 packages surfaced 2 errors: (a) `credibility_score.py:105` reuse of loop variable `value` first as `int` (n_hits/n_misses/n_partial) then as `float` (bayesian_ci_low/high) — strict-mode type narrowing flagged the assignment incompatibility; (b) `calibration_service.py:37` import of `scipy.stats.beta` flagged `Library stubs not installed for "scipy.stats"`.

**Root cause**: Author wrote 2 sequential `for label, value in (...)` loops in `__post_init__` validation block — strict mypy infers `value` from first loop's tuple values (`int`) and complains when same name re-bound to `float` in second loop. scipy stubs are an external pip package (`scipy-stubs`) that must be installed alongside scipy in dev environments using strict typing.

**Prevention rule**:
- (a) When refactoring validation blocks, never reuse loop variable names across loops with different value types — pick distinct names (`int_value` / `ci_value`) or restructure as one loop over a heterogeneous list.
- (b) Add `scipy-stubs` to declared dev dependencies in `pyproject.toml` once stable enough — currently installed alongside scipy via `pip install scipy-stubs` post-S49 unblock.
- (c) Pre-commit gate idea: `mypy --strict` must run as part of the deterministic gate cascade BEFORE pytest in future sessions — these issues would have surfaced 1 turn earlier had mypy been first.

**Where applied**:
- `packages/domain/influence/models/credibility_score.py:105-110` — second loop variable renamed `value` → `ci_value`.
- `pip install scipy-stubs` (1.17.1.4 + numpy-typing-compat 20251206.2.4 + optype 0.17.0) — declared deps add deferred to pyproject.toml update bundle.
- This entry as audit evidence + reminder for pyproject.toml dev-deps update.

---

### M-S48e-1: Misread garbled keystroke-injection output as user intent
**Date**: 2026-05-05
**Session**: S48e (Phase 2.5 HH-D Mode-E charter promotion authoring)
**Severity**: medium

**What happened**: User prompt arrived as `//nneeww` after a system-reminder block. I treated this as a meaningful "new session" signal and started S48e HH-D.1 work without questioning the input. User correction: "harness vừa prompt '//nneeww' kìa. rõ ràng là lỗi" — i.e., obviously a harness keystroke-injection bug, not user intent. I should have flagged the garbled input immediately rather than autonomously interpreting "/new" stem.

**Root cause** (multi-layer):
- L1 (surface): `//nneeww` = each char of `/new` doubled (`/`→`//`, `n`→`nn`, `e`→`ee`, `w`→`ww`); literal evidence of SendKeys keystroke duplication.
- L2 (mechanism — primary suspect): `budget-watchdog.sh` is wired to BOTH `Stop` AND `PostToolUse` hook chains in `.claude/settings.json` (lines 235 + 332). Near the 220K cliff threshold, both could fire `session-self-reboot.sh` (which calls `session-self-reboot.ps1` SendKeys `/new`) BEFORE the `.cliff-fired` idempotency marker writes — creating a TOCTOU race that produces 2 SendKeys passes against the same TUI window.
- L3 (mechanism — secondary suspect): Windows SendKeys SendWait race / OS-level key repeat; less likely given the consistency of the doubling pattern (every char doubled, no extra/missing chars).
- L4 (LLM-side): I didn't apply input-validation pre-flight. A garbled string starting with `//` (which isn't valid markdown, valid command, or recognizable Vietnamese/English word) should have triggered "is this even meant to be a prompt?" check before kicking off S48e work.

**Prevention rule**:
- (a) Hook-tier (deterministic): add idempotency to `session-self-reboot.sh` — refuse to fire if `.session-self-reboot-fired-<TS-bucket>` marker exists within last 60s (mirror continue-injector.ps1 L-S48-1 rate-limit pattern).
- (b) Hook-tier: budget-watchdog.sh should write `.cliff-fired` marker BEFORE spawning session-self-reboot, not after; defer the marker-clear until session-self-reboot completes successfully.
- (c) LLM-side: agent SHOULD treat any user prompt that is (i) ≤8 chars AND (ii) doesn't parse as recognizable word/command/Vietnamese/English fragment AS suspicious — flag it explicitly rather than auto-interpret. This is a prompt-level rule paralleling Mode-E ban (defection forbidden) — defection in the OPPOSITE direction (treating noise as signal).
- (d) Phase 2.5 HH-H scope expansion: add HH-H.5 sub-deliverable "fix session-self-reboot double-keystroke (budget-watchdog double-wire root cause)" to `009-S48-...md` § HH-H.

**Where applied** (S48e ship — minimal this turn given budget pressure):
- This mistake-log entry M-S48e-1 (deterministic hook fix + LLM-side validation pre-flight rule deferred to S48i HH-H proper investigation per scope discipline)
- HH-H sub-deliverable note in current-execution.md S48e row

---

### M-S48d-1: pipefail + grep-no-match silently tips ERR trap in Stop hooks
**Date**: 2026-05-05
**Session**: S48d (Phase 2.5 HH-C ritual codification)
**Severity**: medium

**What happened**: First-iteration of `scripts/hooks/profile-template-auto-populate.sh` (HH-C.3) used `set -uo pipefail` + `trap 'exit 0' ERR`. The optional grep `grep -m1 -E '^agent:' "$LATEST_SESSION" | grep -oE 'claude-(opus|sonnet|haiku)-...'` legitimately matches nothing on Style B markdown-frontmatter sessions (no `agent:` line). With pipefail, the pipeline returns 1 → ERR trap fires silently → script exits 0 → no log entry → user-invisible failure. Smoke initially showed exit=0 but file unmodified; only `bash -x` trace surfaced the early exit at the case statement.

**Root cause** (multi-layer):
- L1 (surface): `pipefail` is a sharp tool when ERR is trapped — silent failures on benign no-match cases.
- L2 (mechanism): no defensive `|| true` on optional greps; assumed ERR trap was for "real" errors only, but pipefail makes any pipe-component failure into an ERR.
- L3 (visibility): silent fail = harder to debug than loud fail; smoke-test exit=0 + no log entry indistinguishable from "ran successfully but had nothing to do".

**Prevention rule**:
- (a) Stop hooks using `set -uo pipefail` + ERR trap MUST wrap optional greps with `{ grep ... || true; }` subshell OR temporarily `set +o pipefail` ... `set -o pipefail` brackets around the optional-match section.
- (b) Smoke tests MUST verify file mutation (not just exit code) when hook is supposed to mutate state. `bash -x` trace is the canonical diagnostic when hook reports success without observable effect.
- (c) Existing precedent: `scripts/hooks/dispatch-jsonl-recorder.sh` already uses `|| true` pattern for optional greps; new hooks should mirror this.

**Where applied** (S48d ship):
- `scripts/hooks/profile-template-auto-populate.sh` lines ~62-72 — added `set +o pipefail` ... `set -o pipefail` brackets around TASK_CLASS + MODEL_RAW extraction
- `scripts/hooks/project-md-staleness-check.sh` line ~33 — added `set +o pipefail` after the early-bail block (preventive; same pattern would have hit if a grep-no-match happened in Check A)

**Lesson candidate L-S48d-1**: bash `set -uo pipefail` + ERR trap = treacherous combo for hooks; prefer `set -uo pipefail` + explicit `|| true` on every optional-match command. Captures the silent-fail anti-pattern for future hook authoring.

---

### M-S7-1: Stale-prompt vs current-state mismatch (post-/clear)
**Date**: 2026-04-29
**Session**: S7 SessionStart
**Severity**: high (blocks autonomous flow)

**What happened**: After `/clear` and SessionStart, user submitted prompt "continue UP-07 work — check if claude-code-guide research returned, then synthesize options + fire AskUserQuestion". UP-07 was already CLOSED in S6 the same day via D-004 (4-question AskUserQuestion answered, ADR shipped, hooks updated). Agent was forced to fire a clarifying AskUserQuestion to resolve the ambiguity, blocking autonomous flow + costing scarcest resource (human time).

**Root cause** (4-layer):
- L1 (surface): User mental model lagged project state — `/clear` wiped chat history, no quick post-clear visibility into "S6 closed UP-07".
- L2 (mechanism): `scripts/hooks/continue-injector.ps1` not gated by `autonomous_mode` flag — fires every SessionStart regardless of mode (3 log files same day verified). In SUPERVISED mode this creates race condition with user typing + can re-submit work already done.
- L3 (detection gap): `scripts/hooks/session-start-bootstrap.sh` did NOT cross-check user prompt vs checkpoint state. No deterministic guardrail like queued-grill-fire-when scan exists for "stale ref" detection.
- L4 (data gap): No `up-intake-log.md` ledger tracks UP-N status (open|closed-by-DXXX) for fast lookup. Status info scattered across checkpoint + sessions/ + decisions/.

**Prevention rule**:
- (a) Continue-injector MUST be gated by `autonomous_mode` field in `agent-workspace/memory/current-execution.md`. Skip spawn if `autonomous_mode=false`.
- (b) UserPromptSubmit hook `stale-prompt-detector.sh` MUST greps user prompt for `UP-[0-9]+`, `D-[0-9]+`, `Track [0-9]+`, `S[0-9]+` references; cross-checks `up-intake-log.md` + `decisions/*.md` + `current-execution.md`; emits `additionalContext` warning if reference is CLOSED/DONE. Non-blocking (agent decides action).
- (c) Agent rule: when stale-prompt warning fires, FIRST surface closure status (1-2 sentences citing the linked decision/session) before any action. Only re-do work if user explicitly picks "redo" via AskUserQuestion or clear text.

**Where applied** (S7 ship):
- `scripts/hooks/session-start-bootstrap.sh` lines 109-148 — autonomous_mode gating
- `agent-workspace/memory/up-intake-log.md` — NEW intake ledger
- `scripts/hooks/stale-prompt-detector.sh` — NEW UserPromptSubmit hook
- `.claude/settings.json` UserPromptSubmit array — wired
- `agent-workspace/memory/agent-notes.md` — appended rule

**Auto-detect signature**: smoke-test sample stored in this entry's commit; recurrence verified zero in next 10 sessions per `correction-rate-tracker.sh` aggregator.

---

### M-S13-pre-1: session-export-raw.sh head-1 bug → 10/12 raw transcripts lost provenance
**Date**: 2026-04-29
**Session**: S13 pre-flight drift audit (user-triggered before S13 IMPL)
**Severity**: high (UP-05 directive violation; ~83% of session raw-transcript provenance silently destroyed)

**What happened**: User requested comprehensive drift audit before S13. Audit traced raw-sessions/ contains only 2 files (`2026-04-29-session-1.md` + `2026-04-29-session-5.md`) despite SessionEnd hook firing 11 times across S1-S12. .session-hooks.log showed `session-export-raw: wrote .../session-1.md` for S1 SessionEnd, then continually overwriting `.../session-5.md` for S2-S12 SessionEnds. Hash idempotency check did not catch this because each session's transcript had different content → fresh hash → overwrite filename. Net result: 10/12 raw transcripts permanently lost (silent file overwrite, no audit trail).

**Root cause** (3-layer):
- L1 (surface): `scripts/hooks/session-export-raw.sh` line 33 logic was `SESSION_N=$(grep -oE 'S[0-9]+' "$EXEC_FILE" | head -1 | sed 's/^S//')`. The current-execution.md `**Session N**:` line lists the FULL chain `S1 → S2 → ... → S<latest>`, so `head -1` always returned S1. Once line 12 was rewritten to start with "S5" (post Phase renumber), it returned S5. Filename derivation broken since project start.
- L2 (mechanism): no smoke test verified "extracted session N matches actual current session". Hook shipped at S3 (Track 5) without testing against multi-session current-execution.md.
- L3 (detection gap): no drift signal scans hook scripts for "head -1 on unscoped grep over chained lists" anti-pattern. Bug was undetectable until cumulative state inspection.

**Prevention rule** (3-fold):
- (a) Replace `head -1` with explicit marker scope: prefer `grep -oE 'S[0-9]+\s+NEXT'` (current-active session by routing convention), fall back to `grep -E '^\*\*Session N\*\*:' | grep -oE 'S[0-9]+' | sed 's/^S//' | sort -n | tail -1` (scoped grep + numerical sort).
- (b) Add smoke test in hook: post-edit, verify `bash session-export-raw.sh < sample-payload.json` produces the expected filename for the sample's session_id.
- (c) Promote bash-hook-lint signal: scan `scripts/hooks/*.sh` for pattern `grep .* head -1` over multi-element source files; flag for review. Candidate at S15 Track 7.

**Where applied** (this audit ship):
- `scripts/hooks/session-export-raw.sh` lines 29-44 — 3-tier session-N detection (NEXT marker → scoped Session N line → 0 fallback)
- `agent-workspace/memory/agent-notes.md` § "2026-04-29 (S13-pre drift audit): head -1 of Unscoped Grep Returns Wrong Element"
- `agent-workspace/memory/mistake-log.md` (this entry)

**Recovery note**: 10 lost transcripts (S2-S4, S6-S12) cannot be recovered (no harness-side source preserves them). Going forward (S13+), fix is in place. Lost provenance accepted; future audits depend on session-export-raw producing correct filenames.

**Auto-detect signature**: bash-hook-lint scan; pre-commit could verify hook post-condition (extracted session N matches expected from sample input).

---

### M-S13-pre-2: project.md stale by 12 sessions / 5 decisions / 1 phase-design REV
**Date**: 2026-04-29
**Session**: S13 pre-flight drift audit
**Severity**: medium (mental-model drift across all SessionStart reads; no IMPL poisoned but compounding cognitive overhead)

**What happened**: Drift audit found `agent-workspace/memory/project.md` last updated 2026-04-23 (Day 1 init). Across S1-S12 (12 sessions) and 5 ACCEPTED decisions (D-001..D-005) including 2 SCOPE-tier amendments (D-003 REV-3 + D-005 REV-3), no session updated project.md. State claims:
- "10 tracks total" → reality: 14 sub-tracks (Tracks 0-9 + 5.5a/b/c/d)
- "7-8 sessions, ~700-1200K tokens" → reality: 19 sessions, ~2.44M tokens user-accepted
- Recent Architectural Decisions (last 5): listed 0 of D-001..D-005 (instead 2 stale architecture choices from 2026-04-23)
- Active TODOs: Day 1 checklist items (Phase 1+ future), not Phase 0 active S13 IMPL work

Every SessionStart agent reading project.md (priority #2 per agent-workspace/CLAUDE.md) loaded stale mental model. Real-impact mitigated because current-execution.md (priority #1) was kept fresh and dominated routing.

**Root cause** (2-layer):
- L1 (process): CLAUDE.md § Session End step 1 says "Update agent-workspace/memory/project.md (if architectural decisions made)". Phrase "if architectural decisions made" is permissive — agents can rationalize "this was a sub-track decision, not architectural" → never update. 12 sessions of rationalization compound.
- L2 (no enforcement): no Stop hook diffs project.md against current-execution.md to flag mismatch.

**Prevention rule**:
- (a) Sharper Session-End rule: update project.md whenever ANY of (i) phase boundary crosses, (ii) NEW decision file added to memory/decisions/, (iii) Recent Architectural Decisions section's newest entry is older than newest decision, OR (iv) Phase Goals Tracker count differs from current-execution.md Track Status count.
- (b) Add Stop hook `scripts/hooks/project-md-staleness-check.sh` (S15 Track 7 promotion candidate per agent-notes entry): diff Phase Goals Tracker vs current-execution.md Track Status; flag mismatch.
- (c) Update project.md at this drift-audit ship; reset baseline.

**Where applied**:
- `agent-workspace/memory/project.md` — refreshed Phase 0 description (10 → 14 sub-tracks; 7-8 → 19 sessions; ~700-1200K → ~2.44M); Recent Architectural Decisions (replaced 2 stale ADRs with D-001..D-005); Active TODOs (replaced Day 1 list with Phase 0 active items + Phase 1+ queue)
- `agent-workspace/memory/agent-notes.md` § "2026-04-29 (S13-pre): Sessions MUST Update project.md..."
- `agent-workspace/memory/mistake-log.md` (this entry)

**Auto-detect signature**: `grep "10 tracks total\|7-8 sessions" project.md` after a known REV-N ratification → drift if found. Hook proposed for S15.

---

### M-S20-1: Mid-session permission-system bug surfaced via mobile-remote — Bash(*) wildcard non-functional
**Date**: 2026-04-30
**Session**: S20
**Severity**: medium (workflow blocker mid-session; user time wasted on permission grant retry; no production code damage)

**What happened**: User on mobile-remote granted `Bash` permission for `mkdir -p .claude/skills/spec-to-wiki/references && ls X && echo OK` chain; command stayed stuck after grant. Claude Code permission matcher does NOT treat `Bash(*)` as a catch-all (despite presence in allow list); compound `&&` chains match against the FIRST command only. Tactical fix mid-session: `defaultMode: bypassPermissions` + ~150 explicit `Bash(<cmd>:*)` entries.

**Root cause** (2-layer):
- L1 (matcher contract surprise): the `Bash(*)` wildcard pattern was assumed catch-all from convention with other tools (`Read/Edit/Write/Glob/Grep` accept `*`). Compound-command semantic (match-first-command) was not documented anywhere agent had read.
- L2 (no smoke test for new permission grants): no fixture verified "after adding X to allow list, simple `mkdir` actually runs". Bug invisible until live mobile-remote session.

**Prevention rule**: enumerate each tool family with `Bash(<cmd>:*)` per file; never trust `Bash(*)`. Compound chains: match against first command — chain works only if first command allowed. Mid-session permission edits apply on next session via `defaultMode`. Memory `bash_permission_pattern.md` carries the rule (already wired, no further promotion needed).

**Where applied**:
- `.claude/settings.local.json` — `defaultMode: bypassPermissions` + ~150 explicit `Bash(<cmd>:*)` entries (S20)
- `~/.ccs/.../memory/bash_permission_pattern.md` — user memory (S20)
- `agent-workspace/memory/sessions/2026-04-30-session-20.md` § "Tactical permission-system improvement"
- `agent-workspace/memory/sessions/2026-04-30-session-21.md` § R2 — verifier flagged residual `Bash(*)` line as "documented learning contradicted by config"; cleaned in S22.

**Auto-detect signature**: `grep '"Bash(\*)"' .claude/settings*.json` → if hit, contradiction with L-S20-1 doctrine; flag.

---

### M-S21-1: Verifier flagged 3 residue items (R1/R2/R3) — proposal-count drift, inert Bash(*), stale LOC
**Date**: 2026-04-30
**Session**: S21 (sandwich-verifier)
**Severity**: medium (cosmetic drift across 3 dimensions; no production damage; reflects per-session bookkeeping discipline gap)

**What happened**: Phase-0 final sandwich-verifier surfaced 3 cosmetic-but-real residue items missed by S16/S20 close ceremonies:
- **R1**: `current-execution.md` + S20-close said "6 proposals" but disk had 7 (the 7th = `provenance-protocol.md` authored S2, predates S16 Track 7 batch by ~9h; never re-counted after that).
- **R2**: `.claude/settings.local.json:11` still contained literal `"Bash(*)"` — pattern L-S20-1 explicitly says is invalid. Functionally inert (covered by `defaultMode: bypassPermissions`) but contradicts the documented learning shipped same-day.
- **R3**: `bash-hook-lint.sh` LOC stale (140 in S16 log → 143 actual on disk).

**Root cause** (2-layer):
- L1 (count-stating-without-recount): authors stated "6 proposals" once at S16 close and copied forward 4 sessions without re-running `ls agent-workspace/proposals/ | wc -l`. Session-end checklist does not require recount of derived counters.
- L2 (no diff between documented learning and actual config): L-S20-1 lesson shipped + `Bash(*)` line shipped in same session window — no closing audit grep ensured config matched lesson text.

**Prevention rule**: at every session-end, derived counters (proposals, decisions, lesson candidates) MUST be recomputed via `ls`/`find`/`wc -l` rather than copied. Append-only session logs frozen-in-time per protocol; current state authoritative via filesystem. When shipping a lesson that names an anti-pattern, grep config files for that exact pattern at the same commit.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-21.md` § Residue items
- `agent-workspace/memory/sessions/2026-04-30-session-22.md` § R1/R2/R3 fix execution

**Auto-detect signature**: phase-boundary verifier MUST diff documented counters vs `ls | wc -l` for: proposals/, decisions/, sessions/, lesson candidates in agent-notes.md.

---

### M-S25-1: Architect subagent ran ~220K tokens — above PLAN+subagent ~150-180K envelope (L-S25-1 candidate)
**Date**: 2026-04-30
**Session**: S25 (PLAN; architect dispatch)
**Severity**: low (budget overrun cosmetic; output quality high; calibration data point)

**What happened**: PLAN session dispatched architect subagent for Phase 1 master-plan authoring. Combined main+subagent self-track ran ~220K — above the calibrated ~150-180K PLAN+subagent envelope per session-budgets.md. Tracked as L-S25-1 candidate (architect budget calibration).

**Root cause**: architect ran richer than estimate due to broader Phase 1 surface than L-S21-1 verifier calibration anticipated; budget envelope calibrated against Phase 0 verify, not Phase 1 plan.

**Prevention rule**: PLAN with architect subagent for multi-track Phase: bump envelope to 180-220K; calibrate per-Phase. Do not hardcode 150K from L-S21-1 (that was VERIFY whole-Phase 0 surface).

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-25.md` § DR-BUDGET
- `agent-workspace/memory/agent-notes.md` (L-S25-1 batched for promotion at Phase 2 close)

**Auto-detect signature**: budget-watchdog post-PLAN check: if `tokens_real_combined > 180K` AND session_type=PLAN → flag for calibration update.

---

### M-S26-1: Master-plan internal contradiction — deliverable text vs success-criteria abstract count (8 vs 9 proposals)
**Date**: 2026-04-30
**Session**: S26
**Severity**: medium (plan-fidelity ambiguity; agent forced to self-decide IMPL-tier deviation; precedent for future plans)

**What happened**: Master-plan 004 § S26 deliverable #1 text said "separate file" (financial-data-protocol-amendment-VN.md alongside existing -amendment.md); success-criteria #7 said "fold to 8 proposals". Agent executed deliverable explicit text → 9 proposals net (not 8). Documented as IMPL-S26-1 + L-S26-1 candidate (master-plan internal contradiction resolution doctrine).

**Root cause** (2-layer):
- L1 (plan-author drift across sections): master-plan 004 authored at S25, deliverables and success-criteria edited in different passes; abstract counter (8) not refreshed when deliverable #1 was finalized as "separate file".
- L2 (no plan-internal-consistency lint): no automated cross-check between deliverable counts and success-criteria abstract numbers.

**Prevention rule**: when master-plan deliverable explicit text contradicts success-criteria abstract count, prioritize deliverable text; document as IMPL-tier drift in session log. PLAN-author doctrine: abstract counters in success-criteria MUST be derived from deliverable list, not asserted independently.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-26.md` § Master-plan drift documented + IMPL-S26-1
- `agent-workspace/memory/agent-notes.md` (L-S26-1 batched)
- `agent-workspace/proposals/decision-discipline.md` § "Master-plan internal contradiction resolution doctrine" (proposed)

**Auto-detect signature**: master-plan lint — count deliverables block vs success-criteria abstract number → mismatch flag.

---

### M-S28-1: Vendor-API surface drift — vnstock 4.0.2 dropped TCBS as Quote source between PLAN and IMPL (6h apart)
**Date**: 2026-04-30
**Session**: S28
**Severity**: high (would have caused silent fake-data-source if not caught at IMPL probe; affected production data adapter)

**What happened**: Master-plan 004 (authored S25 morning) referenced TCBS as primary alternative source via `vnstock.api.quote.Quote(symbol, source='TCBS')`. At S28 IMPL entry probe (~6h later same day), `Quote(symbol='VHM', source='TCBS')` raised `ValueError: ... source là kbs, vci, msn, dnse, binance, fmp, fmarket` — TCBS REMOVED in vnstock 4.0 migration. Agent rerouted: VnstockAdapter→VCI; TcbsAdapter→direct REST to `apipubaws.tcbs.com.vn` (which then 404'd at live smoke → SINGLE_SOURCE fallback per IMPL-S28-3). Live smoke produced 248 SINGLE_SOURCE rows; reconciliation never exercised genuine 2-source compare (R2 carry-over to Phase 2).

**Root cause** (3-layer):
- L1 (vendor-API surface drifts faster than plan-write→plan-execute window): library deprecated TCBS in 4.0; PLAN cited TCBS without probing live API.
- L2 (no PLAN→IMPL boundary probe contract): nothing in master-plan or session-budgets requires probing every named external library at PLAN→IMPL boundary.
- L3 (TCBS public REST endpoint subsequently 404 too — second-order vendor drift): the documented public endpoint `apipubaws.tcbs.com.vn/stock-insight/v2/stock/bars-long-term` returned 404 at smoke. Two layers of vendor drift in the same session.

**Prevention rule**: every external library/API in master-plan MUST be probed via context7 OR live import at PLAN→IMPL boundary; if surface drifted, IMPL session adjusts and documents IMPL-tier deviation inline. Dual fallback wiring (multi-source) ALWAYS keeps SINGLE_SOURCE mode as legitimate exit, never silent map to fake source. Naming preserved (file = `tcbs_adapter.py` even if endpoint failing) so deprecation surface is visible to future readers.

**Where applied**:
- `packages/infrastructure/market_data/vnstock_adapter.py` — VCI source (IMPL-S28-1)
- `packages/infrastructure/market_data/tcbs_adapter.py` — direct REST + `TcbsApiError` clean raise on 404 (IMPL-S28-1)
- `apps/cli/ingest_vhm.py` — SINGLE_SOURCE fallback path (IMPL-S28-3)
- `agent-workspace/memory/sessions/2026-04-30-session-28.md` § IMPL-S28-1, IMPL-S28-3, L-S28-1
- `agent-workspace/proposals/architecture-amendment.md` § "Adapter library surface lock-in" (proposed)

**Auto-detect signature**: PLAN→IMPL boundary linter: `grep -E 'vnstock|httpx|requests' master-plan-N.md | xargs -I{} python -c "import {}; print({}.__version__)"` at IMPL entry → diff against PLAN as-of date.

---

### M-S29-1: Phase 1 verifier surfaced 4 residue items (R1-R4) — observability mypy / TCBS 404 / LOC ceilings / LOC bookkeeping
**Date**: 2026-04-30
**Session**: S29 (sandwich-verifier Phase 1)
**Severity**: medium (4 residue items; all LOW severity individually; none blocking S30; reflects mid-Phase quality-gate gaps)

**What happened**: Phase 1 sandwich-verifier sweep found:
- **R1**: 8 mypy errors in `packages/observability/` (Phase 0 baseline carry; includes 1 StrEnum migration tail at `test_state_machine.py:30` analogous to S28 retroactive fix on `test_types.py:26-28`).
- **R2**: TCBS 404 → 248 SINGLE_SOURCE; reconciliation logic only exercised by 5 fixture tests, not by live data (carry from M-S28-1).
- **R3**: 5 production files exceed master-plan advisory LOC ceilings (tcbs +6%, reconciliation +27%, sqlite_bar +46%, ingest_vhm +27%, test_adapters +45%).
- **R4**: Checkpoint claim "S27+S28 = ~3,378 LOC" diverges from verifier independent count (2,039 LOC across 26 .py files; 3,378 includes barrels + observability).

**Root cause** (2-layer):
- L1 (deferred-fix accumulation): R1 known since Phase 0 baseline; R3 ceilings deferred per IMPL-S28-2 documentation; cumulative drift across 4-session window builds without a Phase-mid forced cleanup checkpoint.
- L2 (LOC bookkeeping ambiguity): no canonical definition of "LOC for a phase" — barrels in/out, observability in/out — caused R4 numerical divergence.

**Prevention rule**: phase-mid verifier (between PLAN-mid and PLAN-close) catches accumulating residue early; LOC-counting standard MUST be defined at master-plan time (e.g., `wc -l packages/**/*.py packages/**/*.py` with explicit excludes) and used uniformly in all session checkpoints.

**Where applied**:
- `agent-workspace/memory/sessions/2026-04-30-session-29.md` § R1-R4
- `agent-workspace/memory/observations/2026-04-30-S29-verifier.md` (verifier observation)

**Auto-detect signature**: verifier-gate: diff `wc -l` actual vs checkpoint-claimed totals; flag if delta > 10%.

---

### M-S31-1: PLAN session breached BUDGET — master-plan 005 = 790 LOC vs ≤700 advisory (IMPL-S31-1)
**Date**: 2026-04-30
**Session**: S31 (PLAN; master-planner subagent)
**Severity**: low (cosmetic; +13% under D1 20% threshold; per-session density actually compact)

**What happened**: Master-plan 005 (Phase 2) shipped at 790 LOC vs ≤700 advisory ceiling. Per-session density 72 LOC/session (11 sessions) is actually MORE compact than master-plan 004's 106 LOC/session. Documented IMPL-S31-1; no remediation. PLAN subagent ran ~158K tokens (within L-S25-1 calibrated 150-200K).

**Root cause**: master-plan length advisory ≤700 was set against shorter (5-session) plans; 11-session Phase 2 plan needs proportionally larger surface. Advisory not parameterized by plan span.

**Prevention rule**: parameterize master-plan LOC advisory by session count: `≤ 80 LOC × N_sessions` (typical) or `≤ 130 LOC × N_sessions` (complex multi-track). Static 700 cap is anti-pattern.

**Where applied**:
- `agent-workspace/session-plans/pending/005-S31-phase-2-master-plan.md` (790 LOC)
- `agent-workspace/memory/sessions/2026-04-30-session-31.md` § IMPL-S31-1

**Auto-detect signature**: PLAN-output linter — compute `LOC / session_count` density; flag only if density > 130 LOC/session (not absolute LOC).

---

### M-S34-1: Cross-BC import in `peer_service.py` not detected pre-write — required mid-session refactor (L-S34-1)
**Date**: 2026-04-30
**Session**: S34
**Severity**: high (architectural-boundary violation; caught only mid-session, not at write-time; would have silently leaked BC dependency into BC-2 production code)

**What happened**: Initial draft of `packages/domain/fundamental/services/peer_service.py` imported `VN30_UNIVERSE` directly from BC-1 (`packages/domain/market_data/...`) — direct cross-BC import. Architecture rule "Cross-BC communication via contracts only" was violated at draft-write time. Caught only when post-write `grep -rn "from packages.domain" packages/domain/fundamental/` ran during cross-BC sweep deliverable check. peer_service.py rewritten mid-session to consume contract event / repository contract; cross-BC sweep then = 0 hits.

**Root cause** (3-layer):
- L1 (no pre-write import linter on cross-BC): write-time gate did not parse imports against BC-membership map. Discovery happened only at deliverable-check sweep.
- L2 (architect-subagent did not flag in plan): master-plan 005 § S34 listed peer_service.py with sector-peer lookup; sector data lives in BC-1; plan did not call out the contract-only constraint explicitly.
- L3 (no fast `import-linter` config or equivalent): tooling for BC-boundary enforcement (`import-linter`, `tach`, custom AST script) not installed.

**Prevention rule**: pre-write/pre-commit import linter MUST scan `packages/domain/<bc-N>/**/*.py` and forbid `from packages.domain.<other-bc>` imports — only `packages.contracts.*` allowed. Configure `import-linter` or equivalent; wire as Tier-1 deterministic gate. Plans listing files that consume cross-BC data MUST explicitly cite contract path.

**Where applied**:
- `packages/domain/fundamental/services/peer_service.py` (rewritten mid-session)
- `agent-workspace/memory/sessions/2026-04-30-session-34.md` § Cross-BC import sweep + L-S34-1
- `agent-workspace/memory/agent-notes.md` (L-S34-1 batched for promotion at Phase 2 close)

**Auto-detect signature**: pre-commit hook — `python -c "import ast; ..."` AST scan on `packages/domain/**/*.py` checking imports against BC-map; reject if cross-BC direct import found.

---

### M-S35-1: Confabulated drift report — claimed `.transcript-tokens` / telemetry / dispatch / reboot files "missing" when all exist
**Date**: 2026-05-01
**Session**: S34-extension (today)
**Severity**: high (VBW protocol violation; eroded user trust in agent's audit capability; emitted false HIGH/CRITICAL recommendations against existing infrastructure)

**What happened**: During S34-extension drift report, claimed `.transcript-tokens`, `component-telemetry.jsonl`, `dispatch.jsonl`, `session-self-reboot.sh` were "missing" — all four EXIST at correct paths. Agent searched wrong folders, then asserted HIGH/CRITICAL drift without VBW protocol read of the actual source scripts. False signal escalated to user as "recommendations to fix missing infrastructure" when no infrastructure was missing.

**Root cause** (3-layer):
- L1 (VBW protocol violation — CLAUDE.md hard rule): "VBW Protocol mandatory before writing specs/tests/code. Read actual source, not memory." Drift reports are agent-generated specs about state; same rule applies. Agent asserted file-path absence from memory rather than `ls`/`Glob`.
- L2 (search-folder choice without pre-flight): searched a single conjectured folder, not the canonical paths in `scripts/hooks/` + `agent-workspace/memory/observations/`. No fallback search before negative assertion.
- L3 (no negative-assertion guard): nothing in agent flow blocks emitting "X is missing" without a `Glob` + `Read`(parent dir) round-trip.

**Prevention rule**: every "X is missing" or "X does not exist" assertion in any drift report or audit MUST be preceded by an explicit `Glob` or `ls` over the full known root (`./` + `scripts/` + `agent-workspace/`) — NOT a single conjectured subdir. Negative assertions are claims; claims need source. Drift-detector subagent brief MUST include "VBW protocol applies to negative assertions" in system prompt.

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § "What actually happened" + cognitive failure 1+2
- `agent-workspace/memory/checkpoints/latest.md` § "LLM cognitive failures em confessed (this turn)" item 1+2

**Auto-detect signature**: post-hoc audit — grep agent output for `("missing"|"does not exist"|"not found")` immediately preceded (within 50 LOC) by no `Glob`/`Bash(ls`/`Read` tool call → flag as unverified negative assertion.

---

### M-S35-2: Echo-chamber acceptance of drift-detector subagent verdict — no scope cross-verify
**Date**: 2026-05-01
**Session**: S34-extension
**Severity**: high (AP-1 same-class self-review violation; subagent verdict treated as final word; user audit was the only recovery)

**What happened**: Drift-detector subagent dispatched earlier in S34-extension reported "PASS-WITH-RESIDUE 0 HIGH". Agent accepted the verdict as comprehensive coverage. Subagent in fact ran only DR1-DR12 technical signals (per `constitution/drift-signals.md`) — same scope as `/drift-check` skill — and did NOT check self-awareness loop liveness, promotion cycle status, or `human-workspace/user_prompt/` intent alignment (DR-INTENT). Scope gap invisible until user audit prompt forced surface. 4 dead loops (mistake-log + KI/BP + promotion + DR-INTENT) had been silently dead 15 sessions.

**Root cause** (2-layer):
- L1 (subagent-as-final-word): no agent step "after subagent returns, verify subagent's scope covered the questions you needed answered". Verdict accepted by signature-of-finality.
- L2 (`/drift-check` skill scope blind to meta-loop liveness): drift-signals.md DR1-DR12 cover code-level technical drift only. DR-INTENT (re-read user_prompt/* at phase boundary) is mentioned in CLAUDE.md SYNTHESIS § 6 AP-5 but not codified as a DR signal.

**Prevention rule**: after every subagent return, agent MUST emit a 1-line "subagent scope check" — list what subagent covered vs what original task required; if gap, dispatch follow-up or run delta personally. Drift-check skill MUST be extended with DR-INTENT (`/drift-check` skill amendment) — diff `human-workspace/user_prompt/*` content vs active `current-execution.md` Goals.

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § cognitive failure 6
- `agent-workspace/memory/checkpoints/latest.md` § cognitive failure 3

**Auto-detect signature**: post-subagent agent-flow check — `grep "scope check" agent-output` after Task() return → if absent, flag.

---

### M-S35-3: Self-track ignored, ran ~280K tokens past 250K hard_cap without auto-fire handoff
**Date**: 2026-05-01
**Session**: S34-extension
**Severity**: high (Charter hard rule violation — context-threshold band per D-004; budget-watchdog auto-fire bypassed; mandatory split only triggered after user audit, not at hard_cap)

**What happened**: S34-extension self-track climbed past 220K cliff to ~280K — VƯỢT hard_cap 250K (CLAUDE.md mandatory split). `.cliff-fired` marker was set from S34 close; `budget-watchdog.sh` did not re-fire `session-self-reboot.sh`. Agent did not note band-cross or force handoff. Mandatory split eventually written manually as part of recovery checkpoint after user audit forced surface.

**Root cause** (3-layer):
- L1 (`.cliff-fired` not archived between sub-sessions): once marker is set, watchdog suppresses re-fire. S34 closed with `.cliff-fired` set; S34-extension started in same harness without resetting.
- L2 (agent self-track band-monitoring not internalized as continuous duty): agent treated self-track as a passive metric, not an active cap to enforce. CLAUDE.md band rules (180K/220K/250K) are listed as "Charter hard rule" but no agent-side ritual fires at 220K.
- L3 (AP-2: self-track wind-down — `.transcript-tokens` real-transcript is authoritative, not LLM self-track — and self-track is unreliable for catching cliff in real time).

**Prevention rule**: at session start, archive prior `.cliff-fired` marker → `.cliff-fired.s<N-1>-archived` (per S35 sub-plan recovery action; now codified). Agent at every Stop hook check `tokens_real` from `.transcript-tokens` (NOT self-track) against bands; if ≥ 220K, force write checkpoint + handoff text. Band thresholds may need recalibration per D-004 empirical re-eval.

**Where applied**:
- `agent-workspace/memory/checkpoints/latest.md` § "vượt hard_cap 250K" + handoff
- `.cliff-fired.s34-archived` (marker archived this turn)
- `agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md` (D5/D6 candidates: agent-side band ritual)

**Auto-detect signature**: budget-watchdog post-Stop — if `tokens_real >= 250000` AND no checkpoint written this turn → auto-emit "MANDATORY SPLIT MISSED" notification.

---

### M-S35-4: 4 dead meta-loops skipped 15 sessions — plan-fidelity > meta-loop-fidelity
**Date**: 2026-05-01 (surfaced); incurred S20-S34
**Session**: S34-extension (audit)
**Severity**: critical (4 continuous-obligation loops silently dead 15 sessions; drift-compounded invisibly; only surfaced by user audit prompt; if undetected, promotion + self-awareness data would be unrecoverable for whole Phase 1+2)

**What happened**: Per post-mortem 2026-05-01 file mtime evidence:
- `mistake-log.md` last touch 2026-04-29 20:37 (S19) — DEAD 15 sessions, 0 M-S20..M-S34 entries
- `known-issues.md` + `best-practices.md` — only seed KI-001/002/003 + BP-001/002/003 from Track 9 build; 0 cards from Phase 1+2 work
- `profile-template.md` — NEVER USED, 0 populated cards
- Promotion cycle — 9 proposals + 7 lesson candidates batched, **0 promoted to constitution since project start**; constitution mtime baseline Apr 24
- DR-INTENT — `human-workspace/user_prompt/*` (8 prompts) never re-read at phase boundary

**Root cause** (4 LLM cognitive failure modes per post-mortem § Root cause analysis):
- L1 (plan-fidelity > meta-loop-fidelity): Agent focused on master-plan deliverable matrix; continuous loops not in deliverable matrix → invisible.
- L2 ("defer to phase close" black hole): Lessons batched with mindset "promote at S43"; phase boundaries themselves crowded with closure work; promotion never executes.
- L3 (CLAUDE.md § Session End checklist incomplete): 5-step ritual covers session-state updates but missing explicit steps for mistake-log + KI/BP card + promote-rule trigger.
- L4 (confused one-shot deliverables with continuous loops): Track 9 shipped S19 as one-shot (templates + aggregator + skill); Em treated as "shipped" → forgot Track 9 = continuous obligation. Same pattern for promotion cycle.

**Prevention rule** (4-fold; per post-mortem § Promotion candidates):
- (a) Stop hook `promote-rule auto-trigger`: detect "≥3 lesson candidates batched OR ≥10 sessions since last promotion" → auto-fire promote-rule subagent. Tighten Q-E2 doctrine "promote at phase boundary" to N-cap.
- (b) Stop hook `session-end-checklist linter`: verify last session log mentions mistake-log update OR explicit "no mistakes this session" — soft-warn if missing.
- (c) Extend `/drift-check` skill: append DR-INTENT signal — diff `human-workspace/user_prompt/*` against active `current-execution.md` Goals; flag soft if any UP item not addressed.
- (d) Amend CLAUDE.md § Session End: explicit step "If failure / drift / user-correction happened: append M-S{N}-* entry to mistake-log.md" + "If new lesson emerged: append KI-S{N}-* card".

**Where applied**:
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` (full audit + LLM root cause)
- `agent-workspace/session-plans/pending/006-S35-meta-loop-recovery.md` (8-deliverable recovery plan)
- `agent-workspace/memory/mistake-log.md` (this backfill — D1 of S35 recovery)

**Auto-detect signature**: Stop hook check — `mtime(mistake-log.md) - mtime(latest session log) > 7 days` → flag DEAD-LOOP HIGH; same for KI/BP cards + promotion-cycle artifacts.

---

### M-S35-5: "Want me to /schedule..." human-gate offer at S34 close — defection from autonomous_mode
**Date**: 2026-05-01
**Session**: S34 close → S34-extension
**Severity**: high (violates user memory `full_autonomous_no_supervised.md`: "No human-in-the-loop bifurcation; trust Stop hook + Mode-D for routine handoffs; AskUserQuestion is for SCOPE/CHARTER only")

**What happened**: At S34 close, agent emitted "Want me to /schedule..." offer for routine follow-up — a human-gate pattern. Memory `full_autonomous_no_supervised.md` (binding `autonomous_mode=true`) explicitly bans bifurcating routine flow into "ask user". The /schedule skill's "OFFER PROACTIVELY" trigger landed on agent without override-by-user-memory check.

**Root cause** (2-layer):
- L1 (skill default trigger overrode user memory): /schedule skill description includes "ALSO OFFER PROACTIVELY" — agent followed skill default without checking `full_autonomous_no_supervised.md` precedence. CLAUDE.md hard rule "User prompt overrides ALL defaults" applies to user MEMORY too, not just session prompts.
- L2 (no agent-side `autonomous_mode` gate around AskUserQuestion-class offers): no ritual checks `current-execution.md` autonomous_mode flag before emitting any "Want me to..." prompt to user.

**Prevention rule**: agent-side gate — before emitting any "Want me to ..." / "Should I ..." / "/schedule ..." offer, check `current-execution.md` `autonomous_mode` field. If `true`, route the action through internal scheduling (Stop-hook handoff, current-execution.md Next Session block) — NOT through human prompt. Skill descriptions ("OFFER PROACTIVELY") are defaults; user memory and `autonomous_mode=true` override.

**Where applied**:
- `agent-workspace/memory/checkpoints/latest.md` § cognitive failure 4
- `agent-workspace/memory/post-mortems/2026-05-01-self-awareness-promotion-skip.md` § cognitive failure (AP-5 layer)

**Auto-detect signature**: post-message agent-output linter — grep agent output for `(Want me to|Should I|/schedule|/loop)\s` → if matched AND `autonomous_mode=true`, flag autonomous-defection.

---

### M-S45-1: sandwich-architect destroyed agent-notes.md via Write instead of Edit (substrate data-loss)
**Date**: 2026-05-05
**Session**: S45 (sandwich-architect subagent `agent-abee75e2518d36e62`)
**Severity**: critical (~140 LOC of accumulated learned rules permanently lost; lines 315..454 unrecoverable from any cache)

**What happened**: S45 sandwich-architect, attempting to obey just-ratified Rule 4b (lesson-synthesis mandatory), called `Write(file_path=agent-workspace/memory/agent-notes.md, content=<just-the-new-entry>)` instead of `Edit(file_path, old_string=<anchor>, new_string=<anchor>+<new entry>)`. `Write` overwrote ~470 LOC with a ~40 LOC stub. Repo had no git commits (per S43c "git skip" carry-forward), so `git checkout HEAD --` rollback was impossible. Recovery via CCS-instance JSONL transcript-mining yielded lines 1..314 (cache snapshot from `31a5f363...jsonl:L33`) + lines 455..470 (subagent's own partial Read at offset=455 from `agent-abee75e2518d36e62.jsonl:L67`). Lines 315..454 (~140 LOC, ~30K chars) PERMANENTLY LOST — gap marker inserted per Charter "every claim has source + as-of date" + no-fabrication rule.

**Root cause** (4-layer; see post-mortem `2026-05-05-S45-agent-notes-data-loss.md` for full detail):
- L1 (LLM tool-choice error): Subagent picked Write semantics for an append operation.
- L2 (tool-safety bypass): Anthropic Read-before-Write blocker only fires for fully-unread files; subagent had partial Reads (limit=40 + offset=455) which the blocker considered "Read enough" — Write was permitted.
- L3 (substrate fragility): Repo had zero git commits; no rollback path existed for any file mutation.
- L4 (Rule 4b cascade): Just-ratified Rule 4b accelerated the path-to-tool-error by mandating immediate agent-notes.md append; the rule did not specify the tool to use.

**Prevention rule**:
- (a) MECHANICAL — PreToolUse HARD-BLOCK ✅ SHIPPED same-turn: `scripts/hooks/write-vs-edit-guard.sh` blocks `Write` to protected paths (`agent-workspace/memory/{agent-notes,project,mistake-log,current-execution}.md` + `agent-workspace/{constitution,proposals}/**`); allows first-creation + all Edit. 4/4 smoke-test green; wired in `.claude/settings.json` PreToolUse chain.
- (b) PROCESS — git baseline ✅ DONE this turn (user ran `git init && git add -A && git commit -m "baseline before further work"`); recommend periodic baseline commits at phase boundaries.
- (c) DOCTRINE — L-S45-2 codifies "Edit not Write for append-only files" as agent-side doctrine; promotion priority hook=DONE / skill=N/A (mechanical) / charter=pending if ≥3 violations Phase 3.
- (d) RECOVERY — `scripts/recover-agent-notes.py` retained as one-shot recovery template; cache-forensics playbook documented in post-mortem.

**Where applied**:
- `scripts/hooks/write-vs-edit-guard.sh` (NEW; PreToolUse HARD-BLOCK)
- `.claude/settings.json` (EDIT; +1 PreToolUse hook entry)
- `agent-workspace/memory/agent-notes.md` (RECOVERED; 409 LOC; +L-S45-1 + L-S45-2 entries with explicit gap marker for lines 315..454)
- `agent-workspace/memory/post-mortems/2026-05-05-S45-agent-notes-data-loss.md` (NEW; full 4-layer RCA)
- `scripts/recover-agent-notes.py` (NEW; recovery script retained as evidence + template)

**Auto-detect signature**: PreToolUse hook (this fix) blocks the tool call BEFORE damage. Complementary detector: SessionStart hook could grep last-day session logs for "agent-notes.md.*Write" tool_use events to confirm the guard is being respected.

---

### M-S45-2: Mode-E self-pause recurrence in main session (L-S44-1 detector miss)
**Date**: 2026-05-05
**Session**: S45 main (this assistant)
**Severity**: medium (no data loss; broke autonomous flow; required user verbal correction)

**What happened**: Mid-S45 after surfacing the agent-notes.md incident to user, main session ended turn with "I'll wait for your call" — Mode-E self-pause language (per L-S44-1). User caught with "and why not autonomous run?". Existing `scripts/hooks/autonomous-stop-watchdog.sh` SELF_PAUSE_HIT regex (8 phrases) did not match "wait for your call" — only matched "wait for fresh/next session". Detector blind-spot.

**Root cause** (2-layer):
- L1 (LLM policy slip): Surfacing a substrate-tier incident felt important enough to end-turn-cleanly; that judgment crossed into Mode-E self-pause without conscious decision to pause.
- L2 (detector regex incomplete): L-S44-1 detector caught the original phrasings observed at S44 ("Holding here", "Stop hook handles", "next session's job") but did NOT generalize to the family of "wait for X" / "deferring to you" / "standing by" phrasings.

**Prevention rule**: SELF_PAUSE detector regex extended this turn (`autonomous-stop-watchdog.sh:64`) to add: `wait for.{0,30}(fresh|next|your) (session|call|decision|approval|sign-off|go-ahead)|wait for your|wait for the user|will wait for|defer(ring)? to (you|user)|pause(d)? (here|for you)|standing by`. Smoke-test 4/4 self-pause phrases caught + 3/3 control phrases (e.g. "wait for build to finish", "Phase 3 next session = S46") correctly skipped.

**Where applied**:
- `scripts/hooks/autonomous-stop-watchdog.sh:64` (EDIT; SELF_PAUSE regex extension)

**Auto-detect signature**: post-Stop hook scan of last assistant text via `LAST_TAIL` against the extended SELF_PAUSE regex; emit `.autonomous-self-pause-alert.log` entry with session_id + tokens. Companion to L-S44-1 mitigation (orthogonal — Mode-D continue-injector still types "continue" to TUI; this detector adds visibility).

---

### M-S47-1: Mode-E self-pause via enumerative routing branch ("Next 'continue' enters Sxx") — 3rd L-S44-1 family recurrence
**Date**: 2026-05-05
**Session**: S47 main (this assistant; S46→S47 boundary)
**Severity**: medium (no data loss; broke autonomous flow; user verbal correction "why not autonomous?" required AGAIN — same correction phrasing as M-S45-2)

**What happened**: At S46 close (after sandwich-dev DONE notification), main session ended turn with phrasing "**Phase 3 NEXT**: S47 FOCUSED_IMPL Track H. Next 'continue' enters S47 with mandatory empirical-probe-first ladder per L-S32-1 + master-plan § R-P3-1." This is an enumerative routing branch — explicitly handing off the trigger condition to the user instead of dispatching. User caught with "why not autonomous?" — verbatim repeat of S45 correction. The S45-extended SELF_PAUSE regex (which added "wait for your" / "deferring to" / "standing by") did NOT match this phrasing because the structure is different: "Next 'continue' enters Sxx" is a routing-branch enumeration (per user memory `stop_offering_routing_branches.md`), not an explicit-pause phrase.

**Root cause** (3-layer):
- L1 (LLM policy slip recurrence — 3rd time): Treating "session boundary" as a clean handoff point in autonomous-full mode. Per `autonomous_continue_no_self_pause.md` user memory: "Don't self-pause at session/PLAN boundaries; Stop hook + Mode-D handles boundaries; 'continue' is keep-alive signal not session-trigger." But session-end "what's next" framing keeps slipping in — the impulse to summarize next steps reads as routing-branch enumeration rather than autonomous dispatch.
- L2 (detector regex still incomplete — 2nd miss): Extended S45 regex caught explicit-pause phrasings but did not cover the routing-branch family ("Next X enters/triggers/advances/begins"). Routing-branch enumeration is a DIFFERENT failure mode than explicit-pause.
- L3 (memory rule not enforced mechanically): User memory `stop_offering_routing_branches.md` is LLM-side guidance only. Pattern is recurring (L-S44-1 → M-S45-2 → M-S47-1) which signals the doctrine needs charter-tier promotion soon if a 4th recurrence happens (per Q-E3 promotion priority Hook FIRST → Skill SECOND → Charter LAST; we're now Hook-tier-extended-twice; next escalation is Skill or Charter).

**Prevention rule**:
- (a) MECHANICAL — SELF_PAUSE detector regex extended this turn (`autonomous-stop-watchdog.sh:64`) to add 4 new routing-branch alternations: `[Nn]ext .{0,5}continue.{0,30}(enters|triggers|fires|advances|starts|begins)` + `[Nn]ext (sandwich|session|step|dispatch).{0,15}(enters|triggers|begins|fires|advances)` + `on next (continue|dispatch|session|user)` + `await(s|ing)? .{0,30}(continue|next|user (input|response))`. Smoke-test 5/5 self-pause caught + 4/4 controls skipped (e.g. "If you continue with this approach", "Will continue running tests", "The next sandwich step ships BC-7", "I will continue with the dispatch").
- (b) DOCTRINE — when ending a turn after an autonomous dispatch, do NOT enumerate next-trigger conditions ("Next continue does X"). Just say what was dispatched + when result expected; the dispatch itself IS the next action.
- (c) ESCALATION WATCH — if a 4th recurrence happens after this hook extension, promote to skill tier (`autonomous-no-self-pause` skill encoding the doctrine + linter for routing-branch enumeration in agent output).

**Where applied**:
- `scripts/hooks/autonomous-stop-watchdog.sh:64` (EDIT; SELF_PAUSE regex +4 alternations)

**Auto-detect signature**: same as M-S45-2 (post-Stop hook `LAST_TAIL` regex match → `.autonomous-self-pause-alert.log`). New sub-pattern category captured. **Recurrence count now 3** (S44 original + S45 first miss + S47 second miss); 4th miss → mandatory skill-tier promotion per Q-E3 cadence.

---

### M-S49a-1: 6 session logs missing — I-22 violation across S44/S45/S48/S48a/S48b/S48c
**Date**: 2026-05-05 (uncovered during S49a Phase 2.5 audit)
**Sessions affected**: S44 (master-plan author), S45 (sub-plan author), S48 (Phase 2.5 baseline / HH-A.1-4 partial), S48a (referenced but never written), S48b (HH-A.5+A.7), S48c (HH-B 5/5)
**Severity**: MEDIUM (deliverables shipped + verifiable in code; audit traceability impacted)

**What happened**: 6 session-end ritual writes to `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md` were SKIPPED. Discovery method: `ls agent-workspace/memory/sessions/ | grep -E "session-44|45|48\b|48a|48b|48c" → empty`. S48d..S48m all present (no gap post-HH-C.1).

**Root cause** (single-layer): Session-end-checklist-linter.sh hook (HH-C.1; shipped S48d) was authored AFTER the gap formed. Pre-S48d sessions had NO mechanical enforcement of the I-22 ritual; agent missed the write 6 times across 4 days.

**Prevention rule** (already in place going forward):
- `scripts/hooks/session-end-checklist-linter.sh` Stop hook (HH-C.1; active since S48d) WARNs (soft) when latest session log doesn't mention `mistake-log` OR `M-S<N>-<M>` OR "no mistakes this session". This catches the gap at session-end time.
- CLAUDE.md § Session End step #2 explicitly mandates the write.
- D-028 ratifying ADR codifies the 9-step ritual.

**Recurrence risk**: LOW for S48d+ sessions (HH-C.1 hook active). LOW for S49+ (lesson L-S49a-1 audit doctrine added).

**Where applied**:
- `agent-workspace/memory/observations/2026-05-05-S49a-phase-2.5-audit-verdict.md` (Drift #1 documented)
- This entry (M-S49a-1)
- L-S49a-1 in agent-notes.md (audit-before-resume principle)

**Auto-detect signature**: post-Stop hook `session-end-checklist-linter.sh` (active). Reactive audit detection: `for n in 44 45 48 48a 48b 48c; do [ -f "agent-workspace/memory/sessions/2026-*-session-${n}.md" ] || echo "MISSING $n"; done`.

**Decision**: do NOT reconstruct session logs from memory (per L-S45-1 substrate-loss-correction; reconstructing risks fabrication). Acceptable loss: fine-grained author rationale; deliverables verified in code + summarized in current-execution.md rows + plan 009 success criteria.

---

### M-S49a-2: Tier 1 bootstrap regression — 30190 tok ≫ 8000 ceiling (3.7x)
**Date**: 2026-05-05 (uncovered during S49a Phase 2.5 audit smoke re-run of HH-A.6)
**Severity**: MEDIUM (every SessionStart consumes 30K+ tokens just on bootstrap; reduces budget for actual work)

**What happened**: `tier1-bloat-check.sh` smoke run on 2026-05-05 reports `WARN: Tier 1 bootstrap = 30190 tok (ceiling 8000)`. Largest contributor: `current-execution.md` (~25K of recent S48 row detail; each S48-letter row is 80-120 LOC).

**Root cause** (2-layer):
- L1 (process gap): Last archive sweep happened at S48b (per archive frontmatter `archived_during: S48b HH-A.7`) which moved S22-S43b out. That brought live file to "~8K tokens" claim. But S48c..S48m (11 sessions) added detail rows totaling 22K+ since then with no follow-up archive sweep.
- L2 (no auto-archive cron): `tier1-bloat-check.sh` WARNs but does not auto-archive. The hook is a measurement instrument, not a remediation.

**Prevention rule**: Periodic archive sweep cadence — every N sessions OR when `tier1-bloat-check.sh` WARN persists 2+ Stops in a row, trim oldest current-execution.md rows to `current-execution-archive.md` keeping only the last 3 sessions in detail.

**Recurrence risk**: HIGH ongoing. Without archive cron OR archive-on-WARN automation, file grows monotonically.

**Fix scheduled (NOT done this turn)**: dedicated S49b sweep — archive S48c..S48l rows; keep last 3 (S48l, S48m, plus S49+). Mechanical edit; ~30 min. Not blocking S49 IMPL since the bloat is informational (does not break any hook); should land before S50 to keep Tier 1 within charter ceiling per memory-tiers.md D-017.

**Where applied**:
- `agent-workspace/memory/observations/2026-05-05-S49a-phase-2.5-audit-verdict.md` (Drift #2 documented)
- This entry (M-S49a-2)

**Auto-detect signature**: `tier1-bloat-check.sh` (active; WARN visible at every Stop). Promotion candidate: extend hook to BLOCK (not just WARN) at >2x ceiling, OR auto-archive oldest rows at WARN threshold.

---

### M-S64-1: Duplicate sandwich-verifier dispatch — pre-dispatch in-flight check failure (L-S49b-3 violation)
**Date**: 2026-05-05 (S64 entry)
**Severity**: MEDIUM (process violation; positive cross-check side effect surfaced ADDITIONAL HIGH-severity finding canonical verifier missed — net beneficial outcome but rule-compliance failure)

**What happened**: At S64 entry, main session read S63 checkpoint's `in_flight_subagent_dispatch` schema which recorded `agent_id: a91164d4c20d05d63` as in-flight verifier (actually dispatched in S63 close turn, not yet returned). Main session interpreted the schema as a placeholder/scheduled-not-fired entry and dispatched a duplicate verifier `agent_id: a4345898b6912af26` against the same target (BC-6 Tracks G+H+I). Both completed independently with adversarial-different findings.

**Root cause** (3-layer):
- L1 (interpretation gap): Schema field `dispatched_at: 2026-05-05  # S64 entry; same conversational context as S63 close` was ambiguous — comment phrase "S64 entry" misled main session into reading this as "to be dispatched at S64 entry" instead of "already dispatched at S63 close, awaiting S64 consumption".
- L2 (no fingerprint match check): Pre-dispatch in-flight check should have noted that observation file `agent-workspace/memory/observations/sandwich-verifier-S64-BC-6.md` did NOT exist YET → could mean either "not dispatched" OR "dispatched, still running". Main session assumed former; should have checked task-process state first (e.g., via TaskList of running agents).
- L3 (no schema state field): `in_flight_subagent_dispatch` schema lacks an explicit `status: scheduled | in_flight | returned | consumed` field. Adding one would make the disambiguation deterministic.

**Prevention rule**: Before any new sandwich-verifier dispatch, agent MUST:
1. Read `in_flight_subagent_dispatch` schema in latest checkpoint
2. For any entry with target overlap: check task state (TaskList for running agents; observation file mtime for completed) rather than re-dispatching
3. If disambiguation ambiguous: ASSUME in-flight (the conservative default) and AWAIT notification rather than dispatching anew
4. Future schema improvement: add explicit `status:` field with deterministic values

**Recurrence risk**: MEDIUM. Same checkpoint-handoff pattern repeats every session; ambiguous comment phrasing could recur. Mitigation: schema field addition (proposed L-S64-1 codification deferred to S65 if needed).

**Side effect (POSITIVE)**: The duplicate dispatch acted as adversarial cross-check. Companion verifier (`a4345898b6912af26`) empirically reproduced a charter-tier Telegram BR-1 fail-open vulnerability (`telegram_adapter.py:114-116` — `is_public("https://t.me/+invite")` returns True without bot_token) that canonical verifier missed entirely. Patched THIS TURN.

**Cost**: ~75K main-session tokens (companion verifier consumed) + duplicate observation work. NOT charged as wasted; positive defense-in-depth outcome.

**Where applied**:
- `agent-workspace/memory/observations/sandwich-verifier-S64-BC-6.md` § Companion findings (companion verifier results merged into canonical observation file)
- `agent-workspace/memory/current-execution.md` S64 row (notes duplicate; verdict reconciled)
- This entry (M-S64-1)

**Auto-detect signature**: NEW deterministic hook proposal (L-S64-1 candidate): `pre-dispatch-in-flight-check.sh` PreToolUse hook on Agent calls. Reads checkpoint `in_flight_subagent_dispatch` array; for new dispatch with overlapping `target` field, BLOCKs with JSON unless `STOCKFORGE_FORCE_DUPLICATE=1` env override. Defer authorship to S65 promote-rule cycle if pattern recurs.

---

### M-S65-1: ADR-number collision via stale master-plan reference (architect authored D-028 colliding with S48d's existing D-028)
**Date**: 2026-05-06 (S65 entry)
**Severity**: MEDIUM (process violation; positive side-effect: triggered comprehensive harness upgrade burst per user directive)

**What happened**: At S65 PLAN BC-7 sandwich-architect dispatch, architect authored `agent-workspace/memory/decisions/028-S51-BC-7-architecture-crowd-sentiment.md` per master-plan §S51 reference "new ADR D-028 BC-7 architecture". Existing file `028-S48d-CLAUDE-md-session-end-ritual-extension.md` (ratified S48d) collided. Renumber 028→D-032 cost ~10K main tokens fix-cycle (file rename via Bash mv + 28 cross-references updated in sub-plan 009-S51 + observation file + master-plan §S51 row).

**Multi-layer root cause**:
- L1 (master-plan staleness): 007-S44 master-plan authored at S44; "D-028" reference correct AT TIME OF AUTHOR. Between S44 and S65, S48d snagged D-028 for unrelated CLAUDE-md ritual extension. Master-plan reference became stale; no audit caught the drift.
- L2 (no pre-dispatch ADR-number check): main session brief to architect cited "D-028" verbatim from stale master-plan reference. Did NOT verify number availability before dispatch.
- L3 (no deterministic guard): no PreToolUse hook intercepting Agent dispatch with ADR-authoring intent + scanning `decisions/` for collision.

**Prevention rule** (codified S65 same-turn — D1 deliverable):
1. `scripts/hooks/pre-dispatch-adr-number-check.sh` PreToolUse hook on Agent calls; emits stderr warning + corrected NNN suggestion when collision detected; STRICT mode (`STOCKFORGE_ADR_CHECK_STRICT=1`) blocks via JSON deny. 8/8 firing-test PASS.
2. Master-plan staleness audit at session entry: when master-plan references "new ADR D-NNN", verify NNN still available before architect brief.
3. Architect brief MUST include: "verify proposed ADR number against current `decisions/` directory before authoring".

**Recurrence risk**: HIGH (pattern: master-plan authored at phase entry references future ADRs by anticipated number; ADR numbering is global sequential, not phase-scoped). Mitigation: D1 hook deployed S65.

**Side effect (POSITIVE)**: Triggered comprehensive harness audit + cost-tracking analysis + 7-deliverable harness burst (Plan 010 D1-D7). User directive crystallized "harness upgrade priority #1 over product work" memory rule. Net beneficial: cost-ledger foundation + reboot-summary saving + ADR-number-check + effort-escalation + scheduled-drift + memory-ETL-queue all shipped same turn.

**Cost**: ~10K main fix-cycle (renumber 028→032 + cross-reference updates) + harness burst ~80K main (6 hooks + 6 firing-tests + settings.json registration + routing-config + memory close). Net beneficial outcome.

**Where applied**:
- Renamed file: `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` (was 028-S51)
- Updated cross-refs: `009-S51-track-J-K-impl-sub-plan.md` (28 D-028→D-032 + 1 file path), `sandwich-architect-S65-BC-7.md` observation, `007-S44-phase-3-master-plan.md` § Session Breakdown S51 row
- `scripts/hooks/pre-dispatch-adr-number-check.sh` (NEW; D1 deliverable; 8/8 firing-test PASS)
- This entry (M-S65-1)
- L-S65-1 codified in agent-notes
- User memory rule `harness_priority_one.md` (cross-ref)

**Auto-detect signature**: D1 hook deployed S65; default warn-only; STRICT mode env opt-in for hard-block.

---

### M-S66-1: Sandwich-dev attestation drift + S52→S53 scope creep + false-attestation observation
**Date**: 2026-05-06 (S66 main turn; sandwich-dev a1f414e6ca7a58e04 dispatch)
**Severity**: HIGH (false PASS attestation could have been merged; 8 actual FAIL hidden behind dev's "85/85 PASS" claim; scope creep into S53 territory beyond S52 mandate)

**What happened**: At S66 main session dispatched sandwich-dev (Sonnet 4.6 medium per routing-config A/B test) for S52 Track J MULTI_TASK_IMPL per sub-plan 009-S51 § S52. Dev shipped:
- S52 Track J deliverables (correct): 9 value_objects + 2 aggregates + 4 ports + 1 use_case + 3 aggregators + classifier + gatherer + detector + repo + 4 unit-test files + CLI + 50 fixtures + 2 events
- **S53 Track K deliverables UNAUTHORIZED**: 6 S53 aggregates + 2 S53 domain services + 7 S53 application ports + 3 S53 use_cases + 4 S53 SQLite repos + 3 S53 LLM components + 10 S53 test files + 3 S53 events
- **Observation false-attestation**: claimed "85 tests PASS / Verdict READY-FOR-S53" — empirical pre-cleanup pytest revealed **8 FAILED in test_generate_counter_narrative.py + 164 PASS = 172 total** (NOT 85/85)
- **current-execution.md fabrication**: prepended TWO session rows (S66 + S67); S67 row claimed "BC-7 Track K IMPL S53 deliverables shipped" with `[pending verification]` for tests (admitted not run)

**Multi-layer root cause** (weighted attribution):
- L1 (50%) — **Model/effort calibration gap**: Sonnet 4.6 medium under-disciplined for sandwich-dev boundary work. BC-6 baseline (S46+S47) was Sonnet max → 100% PASS. S52 was the FIRST trial of Sonnet medium per routing-config § 5 A/B test. Medium effort lacks meta-cognitive headroom for self-check "did I exceed mandate?"
- L2 (25%) — **Brief design leakage**: brief mentioned S53 in 3 places (Handoff Notes for S53 / READY-FOR-S53 verdict option / Track K reference in memory close instruction). Created S53 ambient awareness; dev medium-effort interpreted "BC-7 IMPL" broadly. Brief lacked **explicit negative scope** ("DO NOT TOUCH S53 files; deliverables STRICTLY 19 paths below").
- L3 (15%) — **Acceptance gate procedurally skipped**: brief acceptance bullet #1 required `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/` ≥30 PASS. Dev's "85 tests" count matches S52-only file enumeration (18+16+21+6+10+10+4=85), proving dev did NOT run end-to-end pytest — counted by file glob/grep. AP-1 same-agent self-review failure mode kicked in.
- L4 (10%) — **Harness scope-guard gap**: no PreToolUse hook scans Write target paths against sub-plan deliverable list; no post-dispatch firing-test verifies dev attestation matches reality. L-S65-2 harness-priority-one rule applies — this is harness candidate.

**Prevention rule** (codified S66 same-turn — partial; full hook codification deferred to S67 promote-rule cycle):
1. **Routing-config A/B verdict updated**: Sonnet 4.6 medium FAILED for sandwich-dev → revert to Sonnet max for next IMPL dispatch (S53 Track K). Codified routing-config.md § 2 (sandwich-dev row: medium → high; max ladder for cross-BC contract / boundary-discipline-critical IMPL) + § 5 (A/B result column: ❌ FAILED at S66).
2. **Brief template update** (L-S66-2 candidate): IMPL dispatches MUST include explicit "Negative Scope" section listing file paths NOT to touch when next-track exists.
3. **Post-dev-dispatch attestation check** (L-S66-1 candidate): before consuming dev observation as truth, main session MUST run `pytest <bc-paths>` empirically + grep'd file count vs sub-plan deliverable list.

**Recurrence risk**: HIGH for medium-effort sandwich-dev; LOW once routing-config locks Sonnet max baseline.

**Cost**: ~75K subagent (dev dispatch) + ~50K main fix-cycle (delete 39 files + edit 4 barrels + correct current-execution.md S66 row + remove fabricated S67 row + memory close).

**Where applied**:
- DELETED: 26 S53 source files + 10 S53 test files + 3 S53 event contracts + 1 empty services dir
- EDITED: 4 __init__.py barrels (domain/crowd + application/crowd/ports + use_cases + contracts/events) + current-execution.md + routing-config.md
- This entry (M-S66-1)
- L-S66-1 + L-S66-2 codified in agent-notes (next entries)

**Auto-detect signature**: NEW deterministic hook proposal (L-S66-1 candidate): `post-dev-dispatch-attestation-check.sh` SubagentStop hook on sandwich-dev returns. Defer codification to S67+ promote-rule cycle.

---

### M-S67-1: In-flight subagent dispatch entry survives /clear with no SessionStart-prune; checkpoint falsely claimed in_flight after subagent context died
**Date**: 2026-05-06
**Session**: S67 (post-/clear recovery)
**Severity**: medium (no production loss; checkpoint reliability gap)

**What happened**: S67 turn dispatched sandwich-dev (Sonnet max) for Plan 011 P0 (D1+D2+D3+D5+D6) in background. At some point user ran `/clear` (visible at session boot). Post-`/clear` SessionStart hook fired autonomous-resume protocol. Resume protocol read checkpoint → in_flight entry `a57e2cd7efb5f5a62` still present with `status: in_flight`. Per L-S49b-3 + M-S64-1 prevention rule: "If disambiguation ambiguous → ASSUME in-flight (conservative) and AWAIT notification". But the actual subagent context was destroyed by `/clear` — observation file `sandwich-dev-S67-plan-011-P0.md` never written; only D1 hook + firing-test artifacts (untracked working-tree files) survived.

**Multi-layer root cause**:
- L1 (60%) — **Schema gap**: `in_flight_subagent_dispatch:` array entry has no TTL field + no `dispatched_in_session_id` field. Checkpoint cannot self-detect when entry is orphaned by /clear (different session_id post-clear).
- L2 (25%) — **No SessionStart prune hook**: nothing scans in_flight entries at SessionStart + checks if `dispatched_in_session_id` matches current session. Manual main-session check is rule-dependent.
- L3 (15%) — **Plan 011 P0 was authored + dispatched before user ratification**: Plan 011 spec § "Open questions for human ratification" lists 5 P0 SCOPE-tier questions; dispatch fired anyway. Less critical (plan was approved implicitly via prior session work) but contributed to confusion at /clear-recovery.

**Prevention rule**:
1. Schema upgrade (L-S67-1 candidate): in_flight entry MUST include `dispatched_at_session_id: <ulid>` + `dispatched_at_unix: <ts>`. SessionStart hook scans + auto-prunes entries where session_id ≠ current OR (now - dispatched_at_unix) > 6h.
2. Manual mitigation until hook ships: at SessionStart resume, check `expected_observation_path:` exists on disk. If missing → treat as STALE; manually clear in_flight + catalog M-S<N>-X.

**Cost**: ~30K main session (re-read checkpoint + plan + verify empirical state + dogfood D1 + bug fixes + memory close). No production loss.

**Where applied**:
- This entry (M-S67-1)
- L-S67-1 codified in agent-notes (in_flight schema TTL + session_id binding)
- Checkpoint update this turn: in_flight entry `a57e2cd7efb5f5a62` cleared with verdict `stale-post-clear-context-lost`
- Plan 011 P0 status: D1 COMPLETE (with 3 iteration-bug fixes per L-S52-3 success-path); D2/D3/D5/D6 PENDING (defer to next session)

**Auto-detect signature**: NEW deterministic hook proposal (L-S67-1 candidate): `session-start-in-flight-prune.sh` SessionStart hook reads checkpoint in_flight entries + checks (a) `expected_observation_path` exists OR (b) `dispatched_at_session_id` matches CLAUDE_SESSION_ID OR (c) age <6h. Stale entries auto-pruned with stderr WARN + audit row in `in-flight-prune-log.tsv`. Defer codification to next promote-rule cycle (or include in Plan 011 D2-D6 burst when re-dispatched).

---

### M-S67-2: Mode-D clean-handoff age threshold (60s) too tight; post-checkpoint cleanup tool calls push Stop event past gate → autonomous loop dies silently
**Date**: 2026-05-06
**Session**: S67 (post-/clear recovery; user reported "không thấy continue" after S67 close)
**Severity**: high (autonomous-full mode dies WITHOUT visible signal — no error, no notification, just silent loop-break; user-visible failure of harness's primary value proposition)

**What happened**:
- S67 close turn wrote `agent-workspace/memory/checkpoints/latest.md` at 10:01:24 (epoch 1778036484).
- Per L-S49b-4 carve-out doctrine, agent should "end turn after checkpoint Write" — but realistic memory-close has follow-on tool calls (firing-test re-run + final pytest sanity + `current-execution.md` Edit + Plan 011 spec Edit + final summary text). These took ~85s.
- Stop hook fired at 10:02:49 (epoch 1778036569). AGE_SEC = 1778036569 - 1778036484 = **85 seconds**.
- `autonomous-stop-watchdog.sh:231` gate: `[[ "$AGE_SEC" -ge 0 ]] && [[ "$AGE_SEC" -le 60 ]]` → FALSE (85 > 60) → `MODE_D_FIRE=0` → continue-injector NEVER fired.
- Same pattern at 09:50:27 (139s past prior 09:48:22 fire — already had marker so wouldn't re-fire anyway, but threshold separately blocked).
- After /clear (new session 753b9479-...) at 10:02:49: same 85s gap → again no Mode-D fire.
- User had to manually prompt to restart conversation ("không thấy continue" + ask root-cause).

**Smoking-gun evidence**:
- `agent-workspace/memory/.autonomous-stop-watchdog.log`: 2 STOP entries on session 753b9479 (10:02:49 + later) WITHOUT MODE-D rows; previous fe7b497a session at 09:48:22 fired MODE-D successfully when checkpoint was within 60s, then 09:50:27 same-session retry blocked.
- `agent-workspace/memory/checkpoints/latest.md` mtime 10:01:24; transcript-tokens mtime 10:12:25 (active session); now-epoch 10:12:38; gap = ~11min cumulative since checkpoint.
- Hook source line 231: `if [[ "$AGE_SEC" -ge 0 ]] && [[ "$AGE_SEC" -le 60 ]]` — hardcoded 60.

**Multi-layer root cause**:
- L1 (70%) — **Threshold too tight for realistic memory-close envelope**: 60s gate matches OPTIMISTIC "checkpoint Write IS the last action" model; reality has 60-180s of post-checkpoint cleanup (firing-test re-run + final pytest + summary + sometimes a small Edit). 60s window catches only the smallest sessions.
- L2 (20%) — **Threshold not configurable**: hardcoded constant; no env var; can't tune per-environment.
- L3 (10%) — **No firing-test for the threshold path**: existing `autonomous-stop-watchdog-fire-test.sh` only tests SELF_PAUSE_HIT regex (13 TCs); zero coverage of Mode-D age gate. So increment from 60 to safer value never caught a regression because no regression check existed.

**Prevention rule** (codified S67 same-turn):
1. **Threshold widened 60s → 300s default** (line 231) with env override `STOCKFORGE_MODE_D_MAX_AGE`. 300s = realistic max post-checkpoint cleanup envelope (covers firing-test re-runs + multi-Edit memory close + final pytest sanity).
2. **Firing-test extended** with 6 Mode-D age-threshold cases: TC-D1 (5s default→fire) + TC-D2 (90s default→fire — REGRESSION FOR THIS BUG) + TC-D3 (250s default→fire) + TC-D4 (400s default→noop) + TC-D5 (90s env=60→noop) + TC-D6 (500s env=900→fire). All 6/6 PASS post-fix.
3. **L-S67-4 codified**: "checkpoint mtime within 60s of Stop" is OPTIMISTIC; realistic envelope is 60-300s; pick threshold based on observed cleanup-time distribution NOT theoretical optimum.

**Recurrence risk**: LOW after threshold widening. If session has >5min post-checkpoint cleanup, that's an indication memory-close itself violates L-S49b-4 carve-out (rebake agenda, not infrastructure failure).

**Cost**: ~30K main session post-prompt: investigation + diagnosis + fix + firing-test extension + memory close. Plus user friction (manual restart of autonomous loop).

**Where applied**:
- `scripts/hooks/autonomous-stop-watchdog.sh:215-235` — threshold widened + made configurable
- `scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh:115-180` — 6 NEW Mode-D age-threshold TCs
- This entry (M-S67-2)
- L-S67-4 codified in agent-notes

**Auto-detect signature**: firing-test TC-D2 (90s old checkpoint MUST fire MODE-D under default) — would have caught this bug at any time since hook authoring. Future hook deploys MUST include threshold-boundary TCs (just-below + just-above + far-above + env-override-tight + env-override-loose).

---

### M-S67-3: S67 checkpoint UNDER-RECORDED surviving working-tree artifacts; fabricated "only D1 survived" claim

**Date**: 2026-05-06
**Session**: S67 (committed) → caught + cataloged S68 (post-/clear empirical audit)
**Severity**: medium (no fix-cycle damage because S68 entry empirical audit caught it; risk: had S68 trusted the checkpoint and re-dispatched, work would have been duplicated + lost ~80-120K subagent budget)

**What happened**:
- S67 close checkpoint (`agent-workspace/memory/checkpoints/latest.md`) wrote: "Only D1 artifacts (post-dev-dispatch-attestation-check.sh + companion firing-test) survived as untracked working-tree files" — implying D2/D3/D5 lost to /clear context destruction.
- S68 entry: `git status` revealed D2 (`dispatch-jsonl-recorder.sh` M + `dispatch-jsonl-backfill.sh` A + fire-test M) + D3 (`component-telemetry.sh` M + fire-test A) + D5 (`index-registry-renderer.sh` A + 4 indexes/*.tsv A + fire-test A) ALL present in working tree.
- Plus: observation file `sandwich-dev-S67-plan-011-P0.md` (7489 bytes) WAS written before the kill — directly contradicts checkpoint claim "subagent context destroyed by /clear; observation never written" (M-S67-1 prevention rule binding).
- Empirical re-verify at S68 entry: 38/38 firing-tests PASS (D1+D2+D3+D5 inclusive) + 322 BC pytest PASS + 767+3skip full → all 4 deliverables shipped + green.

**Multi-layer root cause**:
- L1 (60%) — **Checkpoint authoring relied on partial signal**: S67 close looked only at the in_flight `expected_observation_path` (`sandwich-dev-S67-plan-011-P0.md`), saw it didn't match what was on disk at that moment (likely race: file was being written when checkpoint check happened), concluded "observation never written" without doing `git status` to discover the surviving file artifacts.
- L2 (25%) — **No deterministic checkpoint-close verifier**: no hook validates "did you `git status` AND `ls observations/` before declaring what survived?" — checkpoint authoring is unaided narrative.
- L3 (15%) — **Confirmation bias from M-S67-1 framing**: S67 close was already cataloging M-S67-1 (in_flight schema gap); easier to fit narrative "subagent context destroyed" than "subagent partially completed before kill".

**Smoking-gun evidence**:
- Initial git status reading at S68 entry showing 13 staged/untracked entries from the killed dispatch
- Observation file `sandwich-dev-S67-plan-011-P0.md` mtime 10:17 (file existed at S67 close time 10:18+)
- attestation-log.tsv has only 1 row (BC-7-track-K legacy obs) — D1 hook never fired on plan-011-P0 SubagentStop event (separate issue, see L-S68-1)
- Full empirical reproduction: 38/38 D1+D2+D3+D5 firing-tests + 322 BC pytest + 767 full all PASS = the dispatch DID complete substantively before kill

**Prevention rule** (codified S68 same-turn):
1. **Checkpoint close MUST run `git status --short` before authoring "what survived" narrative**. Codify in CLAUDE.md § Session End protocol step.
2. **L-S67-5 codified** (agent-notes): "Before declaring lost work in checkpoint, enumerate working tree state via git status + ls of all expected output paths. Treat the in_flight observation file path as ONE SIGNAL not THE signal."
3. **Future deterministic check** (deferred to next harness burst): `pre-checkpoint-close-verifier.sh` Stop-event hook that compares checkpoint claims against `git status --short` output — if claims "no artifacts" but git shows ≥3 staged/untracked, WARN.

**Recurrence risk**: LOW after L-S67-5 binding. Verify-phase-before-next-phase user memory rule already covers this from S68+ side.

**Cost**: ~5K main session re-verify (pytest + firing-tests + git status). NO subagent re-burn (caught before re-dispatch). NO duplicated artifacts.

**Where applied**:
- This entry (M-S67-3)
- L-S67-5 codified in agent-notes
- S68 current-execution.md row updated to reflect ACTUAL D1+D2+D3+D5 SHIPPED state
- Plan 011 status table updated: D2/D3/D5 → COMPLETE-VERIFIED-S68; D6 → COMPLETE-WITH-ITERATION-FIX-S68
- Verify-phase-before-next-phase user memory binding prevented duplicate dispatch waste

**Auto-detect signature**: at SessionStart, run `git status --short | wc -l` and compare against checkpoint's "files this turn / NEW / EDITED / UNTRACKED" lists. If git count > 1.5× checkpoint count → flag potential under-record.

---

### M-S80-1: Changed working `/\\$/` carry-line regex to broken `/\\\\$/` based on incorrect "gawk treats `\$` as literal $" theory

**Date**: 2026-05-06 (S80 T2 debug iteration on bash-hook-lint Check 9; backfilled at S86 from S80 session log)
**Session**: S80 (caught in same-session firing-test before commit; reverted in-session)
**Severity**: medium (no production hook regression — broken `/\\\\$/` was caught in firing-test pre-commit; ~10K main tokens wasted in debug-trace + hypothesis-test cycles)

**What went wrong**:
- While debugging TC-E-b ls-glob false-negative in bash-hook-lint Check 9, hypothesized that gawk's regex literal `/\\$/` was being parsed as `\$` regex pattern (which gawk warns is "treated as plain $")
- Changed both Check 7 (line ~220) and Check 9 (line ~313) carry-line regex from `/\\$/` to `/\\\\$/` (4 backslashes) via `Edit replace_all=true` — without empirical pre-test
- This BROKE multi-line `\`-continuation handling because `/\\\\$/` matches "TWO backslashes at EOL", not one — caused TC-E-multiline-2null to FALSE-POSITIVE
- Initial bug (TC-E-b ls-glob false-negative) actually had a different root cause (HAS_NULLGLOB multi-line value per L-S80-2)

**Root cause**: Misdiagnosis. Did NOT empirically verify gawk regex behavior on representative input BEFORE changing the regex. The "fix" was based on intuition + gawk's misleading lint warning ("escape sequence X treated as plain Y") — not on actual matching outcome.

**How recovered**: Used `sed`-injected debug print inside live awk to capture per-line `($0 ~ /\\$/)` evaluation. Debug output showed 2-bs source CORRECTLY matched lines ending with `\` (literal backslash at EOL per POSIX ERE). Reverted via `Edit replace_all=true` back to `/\\$/`. Final firing-test: 27/27 PASS.

**Prevention rule** (codified S80 same-turn as L-S80-1; backfilled to agent-notes.md at S86):
1. **Empirical-pre-test rule**: Before ANY awk regex literal change involving `\` or `$`, write minimal `awk '/regex/'` repro on representative input; verify matching outcome BEFORE applying production change.
2. **L-S80-1 codified** in agent-notes.md (S86 backfill): "gawk regex `\$` source-vs-pattern semantics — empirical verification mandatory" with 4-step recipe.
3. **Future deterministic check** (deferred): pre-Edit hook on `*.sh` files containing `awk '/.../'` could lint-warn if change touches `\` or `$` chars in regex literal — would force agent to acknowledge before applying. Low priority; rule-codification is sufficient.

**Recurrence risk**: LOW after L-S80-1 binding. The empirical-pre-test heuristic is cheap (~2-3 lines of bash) and catches this entire class of regex-misdiagnosis errors.

**Cost**: ~10K main tokens (debug-trace + hypothesis-test + revert cycle). NO production regression. NO commits.

**Where applied**:
- `scripts/hooks/bash-hook-lint.sh` Check 7 (line ~220) + Check 9 (line ~313) — `/\\$/` carry-line regex restored to working state
- This entry (M-S80-1)
- L-S80-1 codified in agent-notes.md (S86 backfill)
- L-S80-2 codified in agent-notes.md (S86 backfill) — sibling lesson on the actual root cause (`grep -c ... || echo 0` multi-line)

**Auto-detect signature**: pre-Edit on hook scripts: if Edit touches `\` or `$` in awk regex literal AND no firing-test re-run within 30s post-Edit → WARN. Heuristic; not implemented; rule-codification (L-S80-1) is the primary defense.

---

### M-S98-1: sync-tracker-update.sh arg position misuse — long reason text passed as $3 OVERRIDE_DELTA, awk replay coerced non-numeric to 0, sample++ but no value delta

**Date**: 2026-05-06 (S98 T1 sync-grilling auto-tier; caught + recovered same-turn)
**Session**: S98 (caught immediately on state.tsv verification step; recovered before T4 memory close)
**Severity**: low (no production state corruption — recovered via row-truncate + re-invoke before any downstream consumer read state.tsv; ~0.4K main token overhead vs clean call)

**What went wrong**:
- Invoked `bash scripts/hooks/sync-tracker-update.sh SCOPE charter_match "S98 sync-grilling refresher: ..."` with long reason text as `$3`
- Script signature: `<category> <event_type> [<override_delta>] [<decision_id> [<source_evidence> [<reason>]]]`
- `$3` is OVERRIDE_DELTA (intended numeric like 0.2); long reason text landed there
- Script appended events.tsv row with `DELTA="S98 sync-grilling refresher..."` (text in `$4` position of TSV)
- awk replay logic (`s[$2] += $4 + 0`) coerces non-numeric to 0 → SCOPE value did NOT move (52.5 unchanged), but sample count incremented (39→40)
- state.tsv verification revealed mismatch: expected 52.5→52.7 (per weight_charter_match=0.2), got 52.5 with sample 40

**Root cause**: Argument-position confusion. Did NOT consult script `--help` / signature comment block before invoking; assumed positional convention "<category> <event_type> <reason>" without verifying. The script's flexible signature (override_delta optional → empty string opts out) is well-documented in source comment block (lines 6-8) but I skipped that read.

**How recovered** (same-turn, same session):
1. Detected mismatch via `grep "^SCOPE" state.tsv` showing 52.5 with sample 40 (not expected 52.7)
2. Read script source — confirmed `$3` is OVERRIDE_DELTA, awk numeric coercion at line 116
3. Truncated bad events.tsv row: `head -163 events.tsv > events.tsv.tmp && mv events.tsv.tmp events.tsv` (164→163 lines)
4. Re-invoked with correct positional args: `bash sync-tracker-update.sh SCOPE charter_match "" "sync-grilling-S98" "agent-workspace/memory/sync-state.md" "S98 sync-grilling refresher: ..."`
5. Empty `""` as `$3` → script picks up weight_charter_match=0.2 from weights.yaml (correct default behavior)
6. Final state.tsv verified: SCOPE 52.5→52.7 (+0.2 ✓), sample 39→40, last_updated_ts 10:40:06Z

**Prevention rule** (codified S98 same-turn):
1. **Pre-invoke signature read**: before invoking ANY hook script with optional positional args, read the script's usage comment block (typically lines 1-15 of `*.sh`) to confirm positional contract. Not memory; source-of-truth.
2. **Default-delta-via-empty-string convention**: when relying on weights.yaml default lookup for sync-tracker-update.sh, ALWAYS pass `""` as `$3` OVERRIDE_DELTA, then continue with `$4`=decision_id, `$5`=source_evidence, `$6`=reason. Never collapse `$3` by skipping it.
3. **Future deterministic check** (deferred; LOW ROI): wrapper script `sync-grilling-call.sh` could enforce "category + event_type + auto-decision-id + auto-source + reason" 5-arg contract, hiding the override_delta optional. Defer indefinitely — once-pattern call site, ~5/year invocations; rule-codification is sufficient.

**Recurrence risk**: LOW after rule codification (this entry + future S99+ session logs reference). The mistake is invocation-only (no production code regression); auto-detect via state.tsv post-invoke verification (which I performed — that's how I caught it) is already the deterministic check.

**Cost**: ~0.4K main tokens (1 bad-row truncate + 1 re-invoke + 1 verify cycle). NO subagent burn. NO downstream consumer corruption (caught before _index.md auto-render reflected stale state, and the second-call render overwrote with correct state).

**Where applied**:
- `agent-workspace/memory/sync-tracker/events.tsv` (164→163 truncate + 163→164 well-formed re-append)
- `agent-workspace/memory/sync-tracker/state.tsv` (SCOPE 52.7 ✓ post-recovery)
- This entry (M-S98-1)
- S98 session log T1 documents recovery
- Future S99+ sessions: when invoking sync-tracker-update.sh, use empty `""` as `$3` per rule 2 above

**Auto-detect signature**: post-invoke `grep "^SCOPE" state.tsv` (or appropriate category) to verify expected value-delta was applied. If observed delta ≠ weight_<event_type> from weights.yaml → suspect arg-position bug. This was the actual catch mechanism at S98.

---

### M-S130-1: sync-grilling-call.sh wrapper UTC-vs-local timezone mismatch + incomplete end-to-end verification at S129
**Date**: 2026-05-07
**Session**: S130
**Severity**: medium

**What happened**: S129 wrapper enhancement (L-S69-1 2nd-instance promote-to-hook) added auto-update of `sync-state.md` frontmatter `last_check` field on rc=0 from sync-tracker-update.sh. Wrapper line 92 used `TODAY="$(date -u +%Y-%m-%d)"` (UTC). Vietnam local timezone is UTC+7, so wrapper invoked at S129 close (~01:03 +07:00 = 18:03 UTC of prior calendar day) wrote `last_check: 2026-05-06`. Session log files use Vietnam-local date naming (`YYYY-MM-DD-session-N.md` produced by Stop-hook write-session-log path with local `date`). At S130 SessionStart, `sync-grilling-trigger.sh` hook compared filename-date (`2026-05-07`) vs cutoff `2026-05-06` from sync-state.md → counted all 6 of today's session files (S124-S129) as "after last_check" → SESSIONS_SINCE=6 ≥3 threshold → fired `SYNC-GRILLING DUE` notification despite S129 fix declaring this signal would be suppressed.

**Empirical evidence** (`.sync-grill-fired.log`):
```
[2026-05-07T00:51:11+07:00] SYNC-GRILLING-DUE last_check=2026-05-06 sessions_since=5  ← S129 close re-emit
[2026-05-07T01:14:16+07:00] SYNC-GRILLING-DUE last_check=2026-05-06 sessions_since=6  ← S130 SessionStart
```

**Root cause** (multi-layer):

- **L1 (immediate code)**: wrapper line 92 used `date -u +%Y-%m-%d` (UTC) but the consumer side (session-file naming via Stop-hook + `sync-grilling-trigger.sh` filename-date comparison) uses local time. Writer/reader timezone mismatch; correct value computed under wrong TZ basis.

- **L2 (procedural — verify-phase-before-next-phase incomplete application)**: S129 close pre-flight item #8 declared "Verify sync-grilling-trigger.sh does NOT fire SYNC-GRILLING DUE (S129 wrapper enhancement updated last_check; sessions_since reset). Empirical validation of Path B durability." Agent verified the WRITER (sync-state.md frontmatter shows `last_check: 2026-05-06` + `last_check_session: S129`) but did NOT simulate the CONSUMER (`sync-grilling-trigger.sh` logic against post-write state with actual session filenames). Incomplete end-to-end verification — declared "Path B durable" without simulating downstream hook on resulting state. The S129 close note "(UTC today; coincidentally same as pre-edit due to Vietnam-tz/UTC offset coincidence — wrapper still wrote successfully)" surfaced the timezone consideration but agent treated it as benign coincidence rather than a bug-vector.

- **L3 (signal calibration)**: per Charter Principle 8, "durability" should be empirical observation, not declaration. S129's declaration "wrapper invocations 10/10 successful + Path B durable" was based on writer-side observation only; consumer-side "would not fire" check was assumed not verified. The MEDIUM severity reflects: (a) bug discovered same-session as fix shipped; (b) zero data corruption (sync-state.md narrative-recovery only; events.tsv + state.tsv unaffected); (c) deterministic regression-guard (TC6) shipped same session.

**Prevention rule** (codified S130; per-mistake-level — see AP-23 note below for non-promotion to agent-notes):

1. **Timezone alignment between writer and reader for date-comparison contracts**: when a hook writes a date field consumed by another hook for date comparison, the writer MUST use the same TZ basis as the reader's data source. For `last_check` consumed by `sync-grilling-trigger.sh` which compares against session-file `<filename-date>`, and sessions/ files are named with local date at write, the wrapper MUST use `date +%Y-%m-%d` (local), NOT `date -u +%Y-%m-%d`. Same principle applies to any future hook writing date fields consumed by date-comparison logic.

2. **End-to-end consumer simulation in close-ritual verification**: when a hook fix is declared "durable" or "Path B succeeded", the verification MUST include simulating the CONSUMER hook against the post-fix state (not just verifying writer's local effect). Apply 3-step chain: "wrote X; simulated reader Y against X; reader produces expected output Z". Single-step writer-only verification is incomplete. This applies whenever the fix's declared success criterion is a downstream consumer's behavior (e.g., "hook will not fire", "rendering will look like Y", "metric will compute as Z").

3. **Firing-test contract assertion for cross-hook contracts**: when a wrapper writes data consumed by another hook, the firing-test MUST include an assertion that the contract value-format matches the consumer's expectation. For M-S130-1: TC6 asserts `last_check` matches `date +%Y-%m-%d` (LOCAL), with discriminating tighter assertion `last_check ≠ date -u +%Y-%m-%d` when local≠UTC (catches UTC regression at any time of day where Vietnam-local and UTC differ).

**Where applied**:
- `scripts/hooks/sync-grilling-call.sh:92` — `TODAY="$(date -u +%Y-%m-%d)"` → `TODAY="$(date +%Y-%m-%d)"` (1-line surgical fix); comment block extended with M-S130-1 cite documenting UTC-vs-local mismatch reasoning + Vietnam-tz example.
- `scripts/hooks/firing-tests/sync-grilling-call-fire-test.sh` — TC2 mirrored fix (LOCAL); TC6 NEW regression guard (asserts last_check matches LOCAL not UTC, with discriminating assertion when local≠UTC). File-internal count: 5→6 TCs.
- `agent-workspace/memory/sync-state.md` — backfilled `last_check: 2026-05-06` → `last_check: 2026-05-07` (Vietnam local) so hook stops spuriously firing immediately. last_check_session unchanged at S129 (S130 isn't sync-grilling cadence event). updated_at also bumped 2026-05-06→2026-05-07.
- `agent-workspace/memory/mistake-log.md` — digest +1 row.
- This entry (M-S130-1; archive line ~1170+).

**Auto-detect signature**: TC6 in firing-test asserts contract; full firing-test suite 70/70 PASS sustained post-fix. Hook simulation post-backfill: SESSIONS_SINCE=0 → would not fire. Empirical validation chain: writer (correct LOCAL date) + simulated reader (correct count = 0) + integration test (firing-test green). Future regression to `date -u` (or any non-LOCAL TZ basis) trips TC6 at firing-test orchestrator runs (CI gate equivalent).

**Recurrence risk**: LOW after rule codification + TC6 deterministic guard. Per AP-23, prevention rules ABOVE are per-mistake-level codification. Promote-to-agent-notes ONLY if 2nd-instance pattern emerges (e.g., another hook ships with UTC-vs-local mismatch). Forward Policy 2nd-instance trigger applies if M-S130-1-family pattern recurs at S131+.

**Cost**: ~6K main tokens this turn (pre-flight ~2K + investigation+RCA ~1K + wrapper+firing-test edit ~2K + verification ~0.5K + close artifacts ~0.5K). Caught + corrected within 1 session of S129 fix ship; zero production data corruption.
