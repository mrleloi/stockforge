---
type: archive
source: agent-workspace/memory/agent-notes.md
archived_at: 2026-05-06
archived_during: S99 RCA Layer 1+2 (tracking-bloat cap-and-compact + lesson demotion)
sessions_archived: L-S48m-1 through L-S90-1 (42 operational lessons; 1524 LOC)
note: |
  Per RCA-2026-05-06-S98 Layer 1+2 + user Q-RCA-1+Q-RCA-2 = A acceptance: agent-notes.md
  cap = charter-design rules inline (lines 1-484 of original) + 1-line digest index for
  operational lessons. Full lesson bodies in this archive file. Retrieval: read this file
  on-demand when a digest entry's status (ACTIVE / PASSIVE / RETIRED) requires deep dive.
  
  Lessons archived here include both ACTIVE (most) and PASSIVE (L-S87-1, L-S90-1 — see digest
  in main agent-notes.md for status). The archive itself is forensic; status mutates only
  in digest, not here. Body is canonical reference; digest is the working-memory index.
---

# Agent Notes — Operational Lessons Archive (S48m through S90, archived 2026-05-06 at S99)

### L-S48m-1 — Per-session-marker hooks must NOT use $CLAUDE_SESSION_ID env var on Windows Claude Code 4.x

**Date**: 2026-05-05
**Origin**: S48m HH-H investigation; auto-populate-hook S48e..S48h gap root cause
**Severity**: MEDIUM (silent skip = harder to debug than loud fail)

**Finding**: `$CLAUDE_SESSION_ID` env var is EMPTY in 174/174 SessionStart events on Windows Claude Code 4.x (deterministic empirical via `grep "SessionStart session= " agent-workspace/memory/.session-hooks.log | wc -l`). Per-session marker pattern `.profile-template-fired-${CLAUDE_SESSION_ID:-default}` collapses to `.profile-template-fired-default` for ALL Stops — first session writes marker, all subsequent silent-skip via `[ -f $MARKER ] && exit 0`.

**Rule**: Any hook needing per-session uniqueness must derive marker name from session-log filename or transcript content, NOT from `${CLAUDE_SESSION_ID:-default}`.

**Correct pattern** (per `scripts/hooks/profile-template-auto-populate.sh` post-S48m fix):
```bash
LATEST_SESSION=$(find "${SESSIONS_DIR}" -name "*.md" -mtime -240m -printf '%T@ %p\n' | sort -nr | head -1 | awk '{print $2}')
LATEST_BASENAME=$(basename "${LATEST_SESSION}" .md)
MARKER="${MARKER_DIR}/.profile-template-fired-${LATEST_BASENAME}"
```

**Anti-pattern** (silent-fail):
```bash
MARKER="${MARKER_DIR}/.profile-template-fired-${CLAUDE_SESSION_ID:-default}"
[ -f "$MARKER" ] && exit 0
```

**Generic-pattern**: scan `scripts/hooks/*.sh` for `CLAUDE_SESSION_ID` references; replace with session-log-basename derivation. Only marker-name uses are problematic; logging uses (e.g. `echo "SessionStart session=$CLAUDE_SESSION_ID"`) are safe (just logs empty string).

**Where applied**:
- `scripts/hooks/profile-template-auto-populate.sh` (S48m fix; ~10 LOC delta)

**Open work**: audit other `scripts/hooks/*.sh` for the same anti-pattern. Pattern grep: `grep -l "CLAUDE_SESSION_ID" scripts/hooks/` lists candidates.

**Lesson ID**: L-S48m-1.

---

### L-S49a-1 — Verify Phase-N "DONE" claims empirically before authorizing Phase-(N+1) IMPL

**Date**: 2026-05-05
**Origin**: User halt of S49 mid-IMPL with explicit demand to audit Phase 2.5 before resume
**Severity**: HIGH (calibration over confidence; un-audited "DONE" claims compound across phases)

**Finding**: S48m checkpoint asserted "Phase 2.5 SUBSTANTIVE WORK 8/8 COMPLETE" based on author-side write-ups + smoke evidence within each S48-letter session. User caught the trust gap and demanded independent verification before authorizing Phase 3 IMPL budget consumption. Audit (S49a) found 8/8 deliverables structurally GREEN BUT 3 NEW drift issues (6 missing session logs / Tier 1 bloat 3.7x / HH-F.4 amended target) that the in-flight checkpoints did not surface.

**Rule**: At end of any "Phase N closed N/N tracks" claim, BEFORE moving to Phase N+1 IMPL, run a fresh independent audit:
1. List each track's claimed deliverables (per session-plan success criteria, not just session-log claims).
2. `ls -la` + `bash -n` (where shell) + grep-for-content-sentinel on each claimed file.
3. Re-execute deterministic smoke tests cited GREEN (don't trust write-up only).
4. Spot-check Stop chain ordering, settings.json validity, charter md5 deltas.
5. Document drift in `observations/YYYY-MM-DD-S<NN>-phase-N-audit-verdict.md`.
6. Append findings to `mistake-log.md` (root cause + recurrence risk + fix proposed).
7. Only resume Phase N+1 after audit clears OR explicit user override.

**Why**: Charter Principle 8 (Calibration over confidence) — claims about completeness must be empirically verified, not asserted. Self-reported "DONE" by the same agent that did the work is an echo chamber (matches AP-1 same-agent self-review anti-pattern even though no IMPL change is happening).

**Where applied**:
- `agent-workspace/memory/observations/2026-05-05-S49a-phase-2.5-audit-verdict.md` (audit verdict template)
- This entry (L-S49a-1)
- User memory `verify_phase_before_next_phase.md` (cross-conversation persistence)

**Auto-detect signature**: at session_type=PLAN OR session_type=MULTI_TASK_IMPL OR session_type=FOCUSED_IMPL with brief mentioning "Phase N+1" entry and predecessor "Phase N N/N DONE", insert audit-first task in pre-flight. Hook candidate: `phase-boundary-audit-required.sh` HARD-BLOCK at SessionStart if `current-execution.md` shows "Phase N close" within last 3 sessions AND no `S<NN>a-phase-N-audit-verdict.md` observation file present.

**Lesson ID**: L-S49a-1.

---

### L-S49-1 — NO-LLM-MATH invariant extends to test-assertion authoring

**Date**: 2026-05-05
**Origin**: S49 BC-6 pytest first-run failure on `test_ci_tightens_with_more_samples` — author-side intuition asserted n=100 60H/40M would yield CI width <0.15; actual 0.1536 (M-S49-1).
**Severity**: MEDIUM (single test failure, but pattern is generic across stat-heavy tests)

**Rule**: When authoring a test that asserts a deterministic-computation output (Bayesian CI width, confidence interval coverage, hit-rate threshold, etc.), the LLM author MUST run the computation explicitly (scipy / numpy / statistics / ad-hoc Python) BEFORE writing the assertion — never derive sample-size or threshold values from intuition. This is the I-S1 NO-LLM-MATH invariant (Charter Principle 9) extended from production code into test authoring: even though tests aren't shipped numerical output to user, they encode invariants that gate IMPL release, so an intuition-derived assertion is a silent calibration drift.

**Anti-example** (S49 first turn):
```python
# WRONG — author assumed n=100 was "enough"
[_review(...HIT) for i in range(60)] + [_review(...MISS) for i in range(40)]
# actual width=0.1536 > 0.15 threshold → assertion fails
```

**Correct example** (S49 fix):
```python
# Empirical threshold: at 60% hit rate, Beta(5,5) prior needs n>=110 for
# CI width <0.15 (spec § B.1). n=150 (90H/60M) → width=0.1274, comfortably
# below the 0.15 statistically-meaningful threshold ...
[_review(...HIT) for i in range(90)] + [_review(...MISS) for i in range(60)]
```

**Where applied**:
- `packages/domain/influence/services/test_calibration_service.py:160-178` — fix + empirical-threshold comment
- This entry (L-S49-1)
- `agent-workspace/memory/mistake-log.md` § M-S49-1

**Auto-detect signature**: pre-commit hook idea `assertion-empirical-validation.sh` — grep for `assert .*_ci|assert .*meaningful|assert .*threshold` in newly-changed test files; if found AND no nearby comment block with empirical-derivation evidence (sentinel "Empirical threshold:" or "scipy.stats" usage), warn. Phase 1+ deferred (single-occurrence so far; revisit if pattern recurs).

**Lesson ID**: L-S49-1.

---

### L-S49-2 — mypy --strict requires --explicit-package-bases for src-layout repos with packages/ root

**Date**: 2026-05-05
**Origin**: S49 BC-6 first mypy run failed with `Source file found twice under different module names: "domain.influence.value_objects.channel_id" and "packages.domain.influence.value_objects.channel_id"`.
**Severity**: LOW (recoverable via flag; gate-cascade docs need update)

**Rule**: When invoking `mypy --strict` on a path inside `packages/` directly (e.g., `mypy packages/domain/influence`), ALWAYS pass `--explicit-package-bases` flag — otherwise mypy auto-discovers BOTH the `packages/` parent (yielding `packages.domain.X`) AND the path-relative-to-CWD (yielding `domain.X`) as candidate module roots, causing the dual-naming error.

**Background**: This project uses `root_packages = ["packages"]` in `[tool.importlinter]` and absolute imports of the form `from packages.domain.*`. mypy's auto package-base detection conflicts with this layout when paths are passed directly rather than via package name.

**Correct invocation** (gate cascade canonical):
```bash
python -m mypy --strict --explicit-package-bases \
  packages/domain/influence \
  packages/application/influence \
  packages/infrastructure/influence \
  packages/contracts/events
```

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49-2
- This entry (L-S49-2)

**Auto-detect signature**: candidate hook `mypy-strict-canonical-invocation.sh` Phase 1+ — if any agent runs `mypy` without `--explicit-package-bases` against `packages/**`, surface this as a known-issue note. Or codify in `agent-workspace/constitution/coding-principles.md` § Gate Invocation Canonical Forms (charter-tier addition deferred until 2-3 cases recur).

**Lesson ID**: L-S49-2.

---

### L-S49b-1 — Tier 1 archive sweep: 6-pass progressive compression playbook

**Date**: 2026-05-05
**Origin**: M-S49a-2 fix (Tier 1 bloat 30844 tok ≫ 8000 ceiling, 3.85x); produced 71.7% reduction (8712 tok final, 8.9% over ceiling).
**Severity**: MEDIUM (operational hygiene; SessionStart bootstrap discipline)

**Rule**: When Tier 1 bootstrap exceeds ceiling >2x, run a multi-pass progressive archive sweep (older→recent), with empirical bloat-check verify between passes. Don't try to do it all in one mega-edit — incremental passes let you measure progress + back off if a section turns out to be load-bearing for routing.

**Playbook (6-pass canonical from S49b)**:
1. **Pass 1 — Oldest detail block**: Identify the oldest large `## S<N>` detail rows (e.g., S48c..S48m). Append verbatim to `current-execution-archive.md` under a `## ... archived YYYY-MM-DD` section header. Replace the block in current-execution.md with a one-liner index linking to archive.
2. **Pass 2 — 2nd oldest block**: Repeat for next-oldest detail (e.g., S43f..S47).
3. **Pass 3 — Stale "Current Work Items"**: This section often hoards detail from prior sessions even after they close. Replace with a 4-5-line pointer.
4. **Pass 4 — Audit-row archive**: Audit verdicts (e.g., S49a) become subsumed by IMPL closure; archive detail to its observation file.
5. **Pass 5 — "Active Focus Track" rewrite**: This section drifts. Rewrite based on current phase status (don't trim — replace with fresh content tightly aligned to current state).
6. **Pass 6 — Most-recent row trim**: The latest `## S<N>` row often has redundant detail vs session log + checkpoint. Trim bullets that are duplicated downstream.

**Per-pass verify**: run `scripts/hooks/tier1-bloat-check.sh` after each pass to confirm direction + measure remaining gap.

**Practical floor**: with 2 load-bearing CLAUDE.md (~4.5K tok combined), Routing Table (~550 tok), and minimum session/checkpoint context (~2K tok), expect ~7-9K tok floor. Don't burn budget chasing the literal 8K ceiling — accept ~10% over as acceptable practical state.

**Where applied**:
- `agent-workspace/memory/current-execution.md` (sweep target; 4 archive sections + 2 row updates)
- `agent-workspace/memory/current-execution-archive.md` (sweep landing; 4 sections appended)
- `agent-workspace/memory/checkpoints/latest.md` (companion trim; 1507→846 tok)
- This entry (L-S49b-1)

**Auto-detect signature**: `tier1-bloat-check.sh` already SOFT-WARNS at every SessionStart when over ceiling — promote to nudge agent to schedule sweep when ratio >2x for 3+ consecutive sessions. Hook idea: `tier1-bloat-trend-tracker.sh` Phase 1+.

**Lesson ID**: L-S49b-1.

---

### L-S49b-2 — Harness diagnosis playbook: when hooks "don't seem to fire"

**Date**: 2026-05-05
**Origin**: User pushback on autonomous-loop self-pause led to root-cause investigation of harness Stop chain (M-S49b-1).
**Severity**: MEDIUM (autonomous loop reliability; deferred fix)

**Rule**: When investigating "this hook isn't firing", do NOT trust the conclusion "hook is broken" without these 5 diagnostic steps:

1. **Enumerate event types in `.session-hooks.log` for the current session window**. Different hook event types (PostToolUse / UserPromptSubmit / Stop / SubagentStop / SessionStart) write distinct line patterns — count each separately. If one event type has 0 entries while others fire, the harness is suppressing that event, not the script.
2. **Verify hook IS in chain**: `python -c "import json; d=json.load(open('.claude/settings.json')); print(d['hooks']['<EventType>'])"`. Settings file may have been edited; chain may be missing.
3. **Verify hook config preconditions**: e.g., autonomous-stop-watchdog requires `^\*\*autonomous_mode\*\*:\s*true` in current-execution.md. Grep for the pattern.
4. **Manually invoke the hook** with mocked stdin: `echo '{"transcript_path":"/dev/null","session_id":"test"}' | bash <hook-path>`. If this writes to log fine, the script is OK; the harness isn't invoking it.
5. **Check Claude Code version** + recent changelog for known hook-system bugs (esp. Windows-specific). `claude --version`. May need to upgrade or downgrade.

**S49b-specific finding**: Claude Code 4.x on Windows did NOT fire Stop hook for the current session despite all script-side preconditions being correct. Manual invocation works. Settings intact. autonomous_mode true. But Claude Code itself is not emitting Stop events. This is a HARNESS-side gap, not a script gap. Mitigation: LLM-side autonomous-continue discipline must take the load.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-1
- This entry (L-S49b-2)
- KI-S49b-1 deferred Claude Code version + Stop event suppression investigation

**Auto-detect signature**: candidate hook `stop-hook-fire-count-watchdog.sh` Phase 1+ — at SessionStart, count `Stop session=` entries in `.session-hooks.log` for current session. If 0 entries despite >5 PostToolUse fires, surface as a SessionStart diagnostic alert.

**Lesson ID**: L-S49b-2.

---

### L-S49b-3 — Background-subagent dispatch sequencing + pre-dispatch in-flight check

**Date**: 2026-05-05
**Origin**: M-S49b-2 incident — S50 sandwich-verifier dispatched twice across `/clear` boundary; one in-flight dispatch was killed before observation could be written, then post-`/clear` LLM was about to re-dispatch unaware of the prior in-flight state.
**Severity**: MEDIUM (work-loss + meta-failure pattern)

**Rule** (two parts — both binding for any background subagent dispatch):

**Part A — Dispatch sequencing**: when dispatching a background subagent in a session, the LLM MUST follow this order within the same turn:

1. **Run pre-dispatch check** (Part B below — non-skippable)
2. **Make the Agent() call** with `run_in_background=true`
3. **Write/update the checkpoint** to reflect that the dispatch HAS HAPPENED, populating `in_flight_subagent_dispatch:` field with `tool_use_id`, `dispatched_at`, `expected_observation_path`, `status: PENDING`
4. **End turn** (or continue with non-conflicting work)

**Anti-pattern**: write checkpoint with future-tense `next_action: dispatch X` and then dispatch X immediately in the same turn. Either (a) checkpoint is truthful but action is unfinished — `next_action` is a TODO; or (b) action just happened — `next_action` is stale by the time anyone reads it. Across `/clear` boundaries this stale field causes re-dispatch.

**Correct example**:
```
[Turn N actions, in this exact order:]
1. Read state (current-execution + checkpoints + observations + .dispatch-pending-*.jsonl)
2. Pre-dispatch check passes — no matching observation, no matching pending registry row
3. Agent({ subagent_type: "sandwich-verifier", run_in_background: true, prompt: "..." })
4. Edit checkpoint: append `in_flight_subagent_dispatch:` entry with tool_use_id from step 3 + expected_observation_path + status=PENDING
5. Optional: write/update current-execution.md with the dispatch row
6. End turn
```

**Part B — Pre-dispatch in-flight check protocol**: BEFORE Agent.dispatch in step 2 above, run these grep/ls checks in parallel:

```bash
# Check 1 — observation already exists?
ls agent-workspace/memory/observations/ | grep -iE "<short-task-name>|<session_id>|<related_track>"

# Check 2 — in-flight registry has matching pending entry?
cat agent-workspace/memory/.dispatch-pending-*.jsonl 2>/dev/null | grep '"state":"pending"'

# Check 3 — checkpoint frontmatter has matching in_flight_subagent_dispatch entry?
grep -A 5 "in_flight_subagent_dispatch:" agent-workspace/memory/checkpoints/latest.md
```

**Decision rules**:
- Check 1 returns match → INTEGRATE that observation; do NOT re-dispatch unless explicitly redoing work
- Check 2 returns match → investigate (read the JSONL row's `parent_session_id` + `ts_ms`):
  - If `ts_ms` < 30 min ago AND no observation file → likely still running; wait or query task
  - If `ts_ms` > 2hr ago AND no observation file → likely killed/orphaned; mark `state=killed` in JSONL, then OK to re-dispatch
- Check 3 returns match → read the entry's `status`:
  - PENDING → see Check 2 logic
  - OBSERVED → integrate (should have triggered Check 1 too)
  - LOST/KILLED → OK to re-dispatch with note

**Anti-example** (M-S49b-2 incident): post-`/clear` LLM read checkpoint's stale `next_action` and prepared 3 TaskCreate scaffolds for the dispatch flow — never ran any pre-dispatch check. User interrupted before Agent.dispatch fired, but the protocol gap is generic.

**Correct example**: this very session's recovery flow — when user flagged the incident, the LLM ran Check 1 (`ls observations/` → 0 S50 files), Check 2 (`cat .dispatch-pending-*.jsonl` → found `5b96635e-*.jsonl` with `state=pending` matching `tool_use_id=toolu_01JLqZBE...`), then waited for the killed-task notification to clarify state before deciding whether to re-dispatch.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-2 (failure catalog)
- `agent-workspace/memory/observations/2026-05-05-S50-pre-dispatch-duplicate-rca.md` (full RCA + fix plan)
- This entry (L-S49b-3)
- `agent-workspace/memory/checkpoints/latest.md` — schema extended with `in_flight_subagent_dispatch:` field
- (deferred) `scripts/hooks/in-flight-subagent-watcher.sh` Phase 1+ — proposed Fix-L4 to surface stale-pending dispatches at SessionStart as `<system-reminder>` injection

**Auto-detect signature**: hook `in-flight-subagent-watcher.sh` (proposed; not yet ratified) — runs at UserPromptSubmit; reads `.dispatch-pending-*.jsonl`; for any `state=pending` row with `ts_ms` > 2hr old + no companion observation file → emits `<system-reminder>` to LLM saying "STALE PENDING DISPATCH — verify before any new dispatch".

**Lesson ID**: L-S49b-3.

---

### L-S49b-4 — Checkpoint write IS a session-boundary marker; end turn after it (PRIMARY rule, supersedes any "continue past checkpoint" interpretation)

### L-S51-1 — Empirical-firing discipline supersedes ritual-completion verdict
**Context**: Phase 2.5 (HH-A..HH-H) was audited as 8/8 GREEN at S49a 2026-05-05. Audit measured: file exists / `bash -n` clean / wired in settings.json / smoke command exit-0. Did NOT measure: hook fires on real session events / detection logic produces truthful output on real telemetry shape / escalates when threshold crossed / escalation channel reaches a human or LLM with action authority. T1 post-mortem (this session) found ≥4 hooks wired + executing + silently broken. Smoking gun: `promotion-cycle-trigger.sh` fired 20× today, escalated 0× — grep pattern `^\*\*Session N\*\*:` never matched the real `## SXX —` header format → `LATEST_SESSION=0` always → arithmetic delta always negative → escalation thresholds never crossed.

**Rule**: "Wired + syntax-clean + smoke-passing" is necessary but NOT sufficient evidence of operational health. Every hook ships with a companion firing-test that synthesizes REAL session-data shape (NOT minimal stubs). Phase-close audit MUST include per-hook empirical firing column. Hooks that fail to fire (or fire silently) for ≥3 consecutive sessions are flagged for remediation.

**Anti-example**: Phase 2.5 S49a audit verdict "all 4 watchdog hooks wired + bash -n clean + smoke exit=0" → declared GREEN. Empirical reality: HH-C.4 promotion-cycle-trigger silently no-op'ed because grep pattern mismatch → 14+ session backlog of accumulated lessons never escalated.

**Correct example**: T3 priority-1 fix flow this session (S51): (a) inspect `.promotion-cycle.log` per-line → reveals broken state; (b) edit grep pattern to match real file format; (c) author firing-test in `scripts/hooks/firing-tests/<hook-name>-fire-test.sh` with 4 test cases (hard-block / soft-warn / silent / subordinate-format); (d) run firing-test → 4/4 PASS; (e) run hook against REAL current-execution.md → produces `latest_session=50 last_promote=S43 delta=7 phase_changed=1` → HARD-BLOCK fires; (f) document in M-S51-1 + this rule.

**Severity**: high

**Auto-detect**: yes — Phase 3.5 T6 hook `harness-health-self-scan.sh` will codify this signal. Specifically: scan `.promotion-cycle.log` for `latest_session=0` runs OR scan agent-notes for accumulated `Auto-detect: yes` entries without companion shipped hook + firing-test.

**Where applied**: this rule + M-S51-1 + post-mortem 2026-05-05-phase-2.5-empirical-firing-gap.md + plan 010 § T7 retrofit pattern. Charter promote target: Phase 3.5 T8 ratification as Principle 11.

**Date**: 2026-05-05
**Origin**: User-supplied reframing of M-S49b-2 incident: "lỗi chính là tại sao lại action như vậy mà? đã note checkpoint rồi lại còn làm action khác như dispatch? phải end chờ '/new' chứ"
**Severity**: HIGH (doctrine — applies to ALL session-boundary work, not just dispatch flows)

**Rule**: When the LLM writes / Edits `agent-workspace/memory/checkpoints/latest.md`, that write IS the session-boundary marker. The LLM MUST end the turn after the checkpoint write. The whole purpose of the checkpoint protocol is fresh-context handoff — writing checkpoint, then immediately doing the work the checkpoint announces, defeats the protocol.

**Why this is a PRIMARY rule (not just a dispatch-flow concern)**:
- Checkpoint's `next_action` field is meant to be read by the NEXT session, not executed by the current one
- Continuing past checkpoint write causes:
  - (a) work duplication if user fires `/new` or `/clear` mid-turn (Claude Code v2.1.124 queues slash commands instead of interrupting; LLM doesn't see the queue)
  - (b) stale `next_action` field across `/clear` boundary that misleads the next session into re-executing
  - (c) burns through user-queued intent; user has implicit "go to next session" signal that LLM ignores
  - (d) violates the fresh-context-handoff principle that justifies the checkpoint protocol existing in the first place

**How to apply**:
- After Edit/Write to `checkpoints/latest.md`: end turn. Period.
- One short summary message to user is OK ("S49b done. Tier 1: 8667 tok. Checkpoint written for S50 dispatch."). NO additional tool calls — no Bash, no Agent dispatch, no further Edits.
- If a final cleanup action absolutely cannot wait, do it FIRST then write checkpoint LAST. Never the other way around.
- This rule OVERRIDES `~/memory/autonomous_continue_no_self_pause.md` Rule 1's "immediately do the next-action" clause WHEN the next-action is recorded in a checkpoint. Checkpoint-recorded actions are for the NEXT session, not this one. Carve-out added to that memory file this turn.

**Anti-example** (M-S49b-2, prior session 5b96635e):
```
[Turn N actions in observed order]
1. Edit current-execution.md (S49b row + archive sweep)
2. Edit checkpoints/latest.md (next_action = "S50 dispatch sandwich-verifier")
   ↑ TURN SHOULD HAVE ENDED HERE
3. Agent({sandwich-verifier, run_in_background: true, ...})  ← VIOLATION
4. Bash tier1 final-check                                     ← VIOLATION
5. Summary message "S50 sandwich-verifier dispatched..."      ← VIOLATION
6. /new queued by user mid-turn (ignored by LLM)
7. /clear resolves; new session opens; reads stale checkpoint
8. New LLM almost re-dispatches (interrupted just in time)
9. Background agent from step 3 killed mid-investigation; observation lost
```

**Correct example** (what should have happened in 5b96635e):
```
1. Edit current-execution.md (S49b row + archive sweep)
2. Edit checkpoints/latest.md (next_action = "S50 dispatch sandwich-verifier")
3. Brief summary message: "S49b done. Tier 1: 8667 tok. Checkpoint written for S50."
   ↑ TURN ENDS HERE
[user types /new at leisure; new session starts; new LLM reads checkpoint and dispatches]
```

**Relationship to L-S49b-3 (dispatch sequencing)**:
- L-S49b-3 prescribes: dispatch FIRST → write checkpoint with `in_flight_subagent_dispatch:` populated → end turn
- L-S49b-4 prescribes: ANY checkpoint write = end turn
- **They are compatible**: if dispatch is necessary in current session, do it BEFORE the checkpoint write, then write the checkpoint reflecting completed-state, then end. Checkpoint stays the boundary marker.

**Auto-detect signature**: hook `checkpoint-write-end-turn-watchdog.sh` (proposed; not ratified) — runs on PostToolUse for Edit/Write tools targeting `checkpoints/latest.md`; if any further tool call fires in the same turn, emit `<system-reminder>` "VIOLATION: Edit/Write to checkpoints/latest.md should end the turn — see L-S49b-4". Implementation: track `last-checkpoint-write-ts` per session in `.session-hooks.log`; on subsequent tool call within same session, compare timestamps and alert.

**Where applied**:
- `agent-workspace/memory/mistake-log.md` § M-S49b-2 (PRIMARY root-cause section)
- `~/memory/autonomous_continue_no_self_pause.md` (carve-out added: checkpoint write = session-boundary marker; overrides Rule 1's "immediately do next-action")
- `agent-workspace/memory/observations/2026-05-05-S50-pre-dispatch-duplicate-rca.md` (full RCA reframed)
- This entry (L-S49b-4)
- (proposed, deferred) `scripts/hooks/checkpoint-write-end-turn-watchdog.sh`

**Lesson ID**: L-S49b-4.

---

### L-S52-1 — Firing-test catches author-time imagined-format bugs ON THE LINT HOOK ITSELF (meta-recursive discipline)
**Date**: 2026-05-05
**Origin**: S52 T3.4 cherry-pick — bash-hook-lint Pattern A (M-S51-1 detector) initial draft FAILED its own firing-test TC-A.

**Context**: When extending `bash-hook-lint.sh` Check 5 with Pattern A (detect literal "Session N" placeholder in grep/sed/awk patterns — the M-S51-1 root cause), the first-draft regex required literal `**Session N**`. Real bug instances in target hooks use ESCAPED form `'^\*\*Session N\*\*:'` because grep -E itself needs `*` escaped. The lint regex looked for the un-escaped Markdown-rendered form (what reader sees), not the literal source-file form (what `grep -E` matches against). M-S52-2.

**Rule**: L-S51-1 empirical-firing discipline applies recursively — including to lint hooks that DETECT empirical-firing failures. Lint authors must:
1. **VBW the actual buggy hook source** before authoring the detection regex (read `scripts/hooks/<bug-hook>.sh` pre-fix line-by-line; copy the literal characters into a notes file).
2. **Stage firing-test with REAL escape sequences**, not idealized/cleaned versions. The synthesized hook script in firing-test must be a faithful reproduction of how the bug actually appears in source.
3. **Trust the firing-test failure** — if firing-test fails on a "looks-right" regex, the regex is wrong; the staged sample is the ground truth (not vice versa).

**Anti-example** (this turn): first-draft Pattern A regex `(grep|sed|awk).*[\\^]?[*][*]Session N[*][*]` required `**Session N**` literal — failed firing-test against staged `\*\*Session N\*\*` form.

**Correct example**: relaxed regex to `(grep|sed|awk)[[:space:]].*Session N([^a-zA-Z0-9]|$)` — matches "Session N" placeholder + non-word boundary. Agnostic to escape sequences. Firing-test 4/4 PASS post-fix → production smoke surfaces 2 NEW pre-existing bugs (M-S52-1 = TRUE POSITIVES).

**Severity**: high (lint hooks are the meta-defense; if they're silently broken, all other empirical-firing claims are unverified).

**Auto-detect**: yes — every NEW hook with a regex/grep pattern requires a companion firing-test using staged synthetic input that REPRODUCES the bug shape from real source. Phase 3.5 T7 retrofit applies this to the existing 24+ untested hooks.

**Where applied**:
- `scripts/hooks/bash-hook-lint.sh` § Check 5 (regex relaxed)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (Pattern A staged with `'^\*\*Session N\*\*:'` real-escape form)
- mistake-log.md § M-S52-2 (lint regex iteration bug; caught pre-deploy)
- This entry (L-S52-1)

**Lesson ID**: L-S52-1.

---

### L-S52-2 — Hook-log-naming inconsistency causes false-positives in firing-counter MVP; T6 must standardize
**Date**: 2026-05-05
**Origin**: S52 T3.4 hook-firing-counter.sh production smoke — flagged 13/51 hooks as "silent ≥7d" but ~50% are false-positives due to inconsistent log file naming conventions.

**Context**: The new `hook-firing-counter.sh` MVP uses two evidence sources to detect hook firing:
1. Per-hook log file `agent-workspace/memory/.<basename>.log` (mtime within 7d)
2. Hook basename appears in `agent-workspace/memory/.session-hooks.log`

Production hooks write to varied log paths that don't follow the `.<basename>.log` convention:
- `promotion-cycle-trigger.sh` writes to `.promotion-cycle.log` (drops "-trigger" suffix)
- `budget-watchdog.sh` writes anonymous `[ts] watchdog tokens=...` lines (no basename in log)
- `userprompt-invariants-injector.sh` emits to stdout (no log file at all)

**Rule**: For deterministic firing detection, hooks MUST log their own basename in a standard location. Two acceptable patterns going forward:
- **Pattern A**: every hook writes a one-liner `[<ISO>] <basename> session=<id> ...` to `.session-hooks.log` on every fire (cheap; centralized; greppable).
- **Pattern B**: every hook with a private log uses `agent-workspace/memory/.<basename>.log` exact basename match (no suffix-dropping).

Phase 3.5 T6 (`harness-health-self-scan.sh`) MUST standardize on one of these patterns + retrofit existing hooks to comply. Until then, MVP hook-firing-counter expects ~50% false-positive rate; treat its silent-list output as a TRIAGE QUEUE, not a fail-list.

**Anti-example**: pre-T6 ecosystem — 51 hooks, ≥4 different logging conventions, no central event-stream → cannot deterministically distinguish "silent broken" from "silent because log goes elsewhere".

**Correct example** (proposed for T6): every hook starts with one line `printf '[%s] %s session=%s\n' "$(date -Iseconds)" "$(basename "$0")" "${CLAUDE_SESSION_ID:-unknown}" >> "$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"` immediately after `set -uo pipefail`. Standardizes the firing fingerprint.

**Severity**: medium (MVP works as a useful triage signal; full fidelity blocks on T6).

**Auto-detect**: yes — once Pattern A or B is standardized, hook-firing-counter graduates from MVP to the full T6 surveillance hook with strict pass/fail semantics.

**Where applied**:
- `scripts/hooks/hook-firing-counter.sh` (MVP; documents this nuance in header)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S52-T3.4-firing-tests.log` § Production smoke triage table
- This entry (L-S52-2)
- Phase 3.5 plan 010 § T6 design will reference this lesson for the standardization decision

**Lesson ID**: L-S52-2.

---

### L-S52-3 — Firing-test catches at AUTHOR-iteration stage = SUCCESS path, not failure
**Date**: 2026-05-05
**Origin**: S52 T3.4 hook authoring cycle — 2 author-iteration bugs (M-S52-2 + M-S52-3) caught by firing-test/production-smoke before any deploy harm.

**Context**: M-S52-2 (Pattern A regex too narrow) was caught by `bash-hook-lint-fire-test.sh` TC-A failing on first run. M-S52-3 (settings-extract regex truncation at escaped quotes) was caught by hook-firing-counter production smoke writing 0-byte log. Both fixes shipped same-turn; neither bug ever affected production correctness or downstream consumer.

**Rule**: When a firing-test or production smoke catches an author-iteration bug PRE-DEPLOY, that is the SUCCESS path of L-S51-1 empirical-firing discipline — not a failure. Iteration-bugs are the expected output. The metric is "did any un-caught bug reach production where downstream consumers depended on it?". Pre-deploy catches don't increment the failure counter.

**Anti-pattern to avoid**: marking an author-iteration cycle as "failed" because the first regex was wrong. That confuses the metric. The CORRECT framing: iteration-bug count is the inverse of empirical-firing discipline rigor — more iteration-bugs caught means MORE rigor, not less.

**Correct example** (this turn): both M-S52-2 and M-S52-3 are cataloged with severity LOW (caught pre-deploy via the discipline) — not severity HIGH (which is reserved for un-caught bugs that reached production, like M-S51-1).

**Severity**: medium (framing/calibration rule; affects how subsequent sessions interpret iteration counts).

**Auto-detect**: no — judgment-tier rule; cannot be deterministically detected.

**Where applied**:
- mistake-log.md § M-S52-2 + M-S52-3 (severity = low per this rule)
- quality-report 2026-05-05-S52-T3.4-firing-tests.log § Discoveries this turn
- This entry (L-S52-3)

**Lesson ID**: L-S52-3.

---

### L-S53-1 — Firing-test catches LAYERED latent bugs deeper than upstream detection
**Date**: 2026-05-05
**Origin**: S53 T3.4-followup — fixing M-S52-1 (imagined-format) in `session-export-raw.sh` surfaced 2 ADDITIONAL pre-existing latent bugs in the same hook (M-S53-1 pipefail-silent-exit + M-S53-2 archive-prose-anchor-false-positive) that the upstream Pattern A detection layer (`bash-hook-lint.sh` Check 5) did NOT flag.

**Context**: Pattern A (Check 5) at S52 detected the imagined-format symptom (`^\*\*Session N\*\*:` literal). It did NOT detect:
- That Method-1's pipefail+ERR-trap silent-exit would prevent Method-2 from ever running (this is L-S48d-1 / Check 7 territory; meta-lint gap noted as KI-S53-1).
- That Method-1's NEXT-marker grep was unanchored and would false-positive on archive-prose mid-line (S38/S42 NEXT branching gate at line 261 of real `current-execution.md` → SESSION_N=42 returned every export, not the actual latest session).

Both bugs were surfaced ONLY by the firing-test → production-smoke retrofit cycle:
- M-S53-1 caught at firing-test TC1 initial fail (no raw-sessions/<DATE>-session-52.md created despite fixed Method-2 grep).
- M-S53-2 caught at production smoke (raw-sessions filename was `<DATE>-session-42.md` instead of `<DATE>-session-52.md`).

**Rule**: When applying an L-S51-1 retrofit fix to a hook with `set -uo pipefail` + `trap '... ERR'` + bare-grep pipelines, treat the ENTIRE pipeline-success contract as part of the fix scope. A surfaced symptom (imagined-format regex) is rarely the only latent bug — bash discipline failures cluster (pipefail-trap + missing `|| true` + missing line-anchors). Budget for triple-bug discovery per retrofit and fix all surfaced layers in one turn rather than deferring sequentially.

**Anti-pattern to avoid**: ship the "minimal" fix matching ONLY the upstream-detected symptom, then defer the deeper layers to a follow-up session. That fragments the firing-test artifact (TC count drifts; coverage diluted) and leaves the hook latently broken in production until the NEXT detection cycle catches it.

**Correct example** (this turn): S53 retrofit fixed all 3 layered bugs (M-S52-1 + M-S53-1 + M-S53-2) in one Edit + one firing-test extension (5 → 7 TCs) + one production smoke. Quality report § Triple-bug discovery section explicitly catalogs the dependency order so future readers see the chain.

**Severity**: high (process rule for all future L-S51-1 retrofit cycles).

**Auto-detect**: partial — `bash-hook-lint.sh` Check 7 already targets pipefail+ERR-trap+bare-grep but missed `session-export-raw.sh` (heuristic refinement opportunity, KI-S53-1). Anchor-on-grep is NOT yet a check; consider adding "Check 8 unanchored-`^`-on-positional-grep" in S54+ promote-rule cycle.

**Where applied**:
- `scripts/hooks/session-export-raw.sh` triple-bug fix
- `scripts/hooks/firing-tests/session-export-raw-fire-test.sh` 7 TCs (TC6 + TC7 added for M-S53-* coverage)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S53-T3.4-followup-fixes.log` § Triple-bug discovery
- This entry (L-S53-1)

**Lesson ID**: L-S53-1.

---

### L-S53-2 — Autonomous loop reliability: idempotency must advance per Stop-event, not per-SessionStart-tick
**Date**: 2026-05-05
**Origin**: S53 post-checkpoint follow-up — user pushback "sao lại không autonomous run tiếp? tại sao, harness lại lỗi à" surfaced harness reliability gap. M-S53-3 root cause: continue-injector per-SessionStart-tick idempotency blocked autonomous Stop→Mode-D→continue-injector loop within a single session.

**Context**: L-S49b-4 (PRIMARY rule) says LLM ends turn after checkpoint write; Mode-D in autonomous-stop-watchdog.sh fires continue-injector to type "continue" into TUI → fresh resume. The mechanism worked end-to-end UP TO injector silent-exit. continue-injector.ps1 had two idempotency layers:
- 60s rate-limit (sufficient for L-S48-1 burst-spam scenario where 180 spawns occurred over a morning ~30-40min apart)
- Per-SessionStart-tick marker `.continue-fired-{SessionTag}` where SessionTag = `.session-ready` mtime ticks

`.session-ready` only updates on SessionStart events. Within a session, SessionTag NEVER changes. After the FIRST injector fire for a given SessionStart, ALL subsequent fires (including legitimate Mode-D handoffs) hit "already fired for this session-ready tick" silent exit.

**Rule**: Idempotency for autonomous-loop hooks must advance on the CAUSAL event (Stop, checkpoint write, recovery trigger) — NOT on the SessionStart tick. SessionStart is a coarse-grained lifecycle event that fires only on `/clear` / fresh-launch / `--resume`; it cannot advance within an active session, so any idempotency tied to it permanently blocks intra-session autonomous chains.

**Anti-pattern to avoid**: layering "belt-and-suspenders" idempotency without analyzing whether the redundant layer can BLOCK the legitimate flow. L-S48-1 added per-tick marker as defense-in-depth; the 60s rate-limit was already sufficient for the original spam scenario (spawns 30-40 min apart). The redundant per-tick marker silently disabled the autonomous loop the harness exists to deliver.

**Correct example** (post-S53 contract):
- 60s rate-limit (cross-caller spam protection): retained
- Per-event markers on caller side:
  - `bootstrap` (SessionStart): one fire per SessionStart (bootstrap itself only fires once per event)
  - `Mode-A` (API-truncation): `.api-truncation-recovery-fired-$RECOVERY_KEY`
  - `Mode-C` (premature wind-down): `.mode-c-recovery-fired-$MODE_C_KEY`
  - `Mode-D` (clean handoff): `.mode-d-recovery-fired-$MODE_D_KEY`
- Per-tick marker on injector side: REMOVED (M-S53-3 fix)

**Severity**: HIGH (autonomous-full mode loop dead until fix lands; user-visible reliability gap directly contradicting AOM autonomous-loop guarantees).

**Auto-detect**: yes — propose harness-health-self-scan signal HH-X (NEW): "if continue-injector log shows `already fired for this session-ready tick` AND `.mode-d-recovery-fired-*` marker exists for same time window → flag as M-S53-3-recurrence". Codify in Phase 3.5 T6 hook.

**Status of L-S48-1**: SUPERSEDED IN PART. Per-tick marker removed. Original L-S48-1 cross-window-typing prevention via `Try-FocusClaudeTerminal` ancestor-walk is RETAINED (still essential to prevent typing into wrong window).

**Where applied**:
- `scripts/hooks/continue-injector.ps1` lines 114-134 (per-tick marker block REMOVED; explanatory comment retained for forensic clarity)
- `agent-workspace/memory/mistake-log.md` § M-S53-3
- This entry (L-S53-2)
- Phase 3.5 T6 hook design will reference this as HH-X auto-detect signal

---

### L-S54-1 — 2-pass grep filter beats single-regex with `[^^]` first-char negation when target token CAN be body start
**Date**: 2026-05-05
**Origin**: S54 Check 8 authoring — initial Check 8 regex used `['\"][^^'\"][^'\"]*(MARKER)` to "skip patterns starting with `^`". Failed TC-D firing-test because when MARKER is the FIRST body char (e.g. `'S[0-9]+ NEXT'`), the `[^^'\"]` consumes `S` and the trailing alternation never finds another `S\[0-9\]\+` token to match.

**Context**: Tempting to encode "first char must NOT be caret" as a single regex constraint. But ERE has no lookahead — the negation char-class `[^^]` consumes a char, and that char is unavailable for downstream alternation. Backtracking can't recover because the consumed `[^^]` position is fixed.

**Rule**: When a heuristic needs to (a) detect a routing/marker token in pattern body AND (b) exclude patterns where body starts with a specific anchor char, use 2-pass filter:
- pass-1: `grep -E "marker_token_regex"` finds candidate lines
- pass-2: `grep -vE "anchor_prefix_regex"` excludes anchored patterns

This is cleaner, more readable, and avoids ERE backtracking pitfalls. Applies to any heuristic involving "find pattern X but exclude when prefix Y exists".

**Anti-pattern to avoid**: trying to encode the entire whitelist + flag logic as a single grep regex. Single-regex bash heuristics become hairy fast and fail in non-obvious ways (token-at-body-start edge case here was a textbook example).

**Correct example** (S54 Check 8):
```bash
BAD_D="$(grep -nE "grep[[:space:]]+(...)?['\"][^'\"]*(S\[0-9\]\+|...)" "$f" 2>/dev/null \
  | grep -vE "grep[[:space:]]+(...)?['\"]\^" \
  | grep -vE '^[[:space:]]*[0-9]+:[[:space:]]*#' \
  || true)"
```

**Severity**: medium (technique rule; affects future bash-lint authoring + any deterministic pattern-detection hook).

**Auto-detect**: no — judgment-tier rule; lint-on-lint would be over-meta. Apply at code-review time during firing-test author cycle.

**Where applied**:
- `scripts/hooks/bash-hook-lint.sh` Check 8 (post-iteration v2; v1 used `[^^][^...]*` and failed TC-D)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TC-D / TC-D-anchored / TC-D-content (pass-1+pass-2 approach validated empirically)
- This entry (L-S54-1)

**Lesson ID**: L-S54-1.

---

### L-S54-2 — Meta-lint heuristic upgrade reveals BROADER retrofit scope than estimate
**Date**: 2026-05-05
**Origin**: S54 production smoke — refined Check 7 (now catching command-sub + pipeline forms in addition to bare-line) surfaced 27 latent L-S48d-1 candidates. Pre-S54 Check 7 surfaced 0 hits in the same hook tree. Same with Check 8: 4 unanchored-positional-grep candidates.

**Context**: Phase 2.5 (HH-A..HH-H) closed "ritually" 8/8 GREEN. Phase 3.5 master-plan (010) estimated T7 retrofit scope as "~22 remaining HH-A..HH-H untested hooks" based on session-count audit. S54 production smoke shows the L-S48d-1 family alone has ≥27 hooks with un-guarded grep under pipefail+ERR-trap context. The actual retrofit surface is BROADER than the original count-by-session estimate.

**Rule**: When a deterministic detector heuristic is upgraded mid-phase, expect production-smoke counts to JUMP, often substantially. Treat the new count as the empirical baseline for retrofit scope (not the prior under-detected count). Update master-plan envelope estimates downstream.

**Anti-pattern to avoid**: treat the post-upgrade count as "regression" or "noise". The detector wasn't catching real bugs before; the higher count is the truth surfaced. Resist the urge to relax the heuristic to bring counts back down.

**Correct example** (S54 → S55+ implications):
- T7 (firing-tests retrofit) scope reframes: each hook retrofit must ALSO normalize grep-guard form per L-S48d-1 + audit positional-marker patterns for `^` anchor per L-S53-2 — not just "add a firing-test".
- 010 plan envelope estimate for T7 batch should bump to account for grep-normalization step per hook.
- Promote-rule cycle should treat lint upgrade as observable signal of phase-2.5 incompleteness (not Phase 2.5 success criterion violation; just empirical correction).

**Severity**: medium (planning/scoping rule; affects T7 phase budget; informs how phase-closure rituals interpret deterministic-gate counts).

**Auto-detect**: yes — every post-upgrade lint smoke run logs the count delta. Compare today's `bash-hook-lint WARN N violation(s)` to last archived count; flag if N changed by ≥5 OR if a new violation code appeared.

**Where applied**:
- `agent-workspace/quality-reports/deterministic/2026-05-05-S54-bash-hook-lint-meta-refinement.log` § Production smoke breakdown
- `agent-workspace/memory/current-execution.md` S54 row (T7 scope reframing note)
- This entry (L-S54-2)

**Lesson ID**: L-S54-2.

---

### KI-S54-1 — Check 7 recognizes only canonical `|| true` / `|| :` guards (CLOSED via S58 broad refinement)
**Date**: 2026-05-05
**Origin**: S54 Check 7 refinement — chose conservative recognition of `|| true` and `|| :` as ONLY canonical guards. Alternative forms `|| echo "..."`, `|| exit 0`, `|| return 0` flag as Check 7 false-positive even though they semantically guard against the ERR trap.

**Status**: CLOSED — structural refinement shipped 2026-05-05 S58. Check 7 reimplemented as awk script with 4 NEW skip rules: (1) compound-conditional `if X && grep`/`if X | grep` (line starts with `if|while|until|elif`); (2) broad `&&`/`||` chain rule subsumes narrow keyword whitelist (covers `|| echo NN`, `|| exit N`, `|| return N`, AND arbitrary chain commands like `[ X ] && grep && action`); (3) pipefail-bracket region tracking (`set +o pipefail; grep; set -o pipefail`); (4) multi-line `\`-continuation joining (catches alt-guards on continuation lines). Production smoke validated empirically: L-S48d-1 violations 27 → 0 (cleared 20 via false-positive recognition + 11 surgical `|| true` fixes across 6 hooks). 17/17 firing-test cases PASS (was 11/11 baseline; +6 NEW: tricky-bare + compound-and + compound-pipe + alt-echo + bracket + and-chain).

**Original status (pre-S58; preserved for audit)**: deferred refinement — accepted trade-off. Hook authors should normalize to canonical `|| true; ...` form for clarity. If false-positive rate proves disruptive in S55+ batch retrofit (≥5 hooks legitimately use alternative-guard form and complain), promote refinement to add `|| (echo|exit|return)` recognition.

**Where tracked**:
- `agent-workspace/quality-reports/deterministic/2026-05-05-S54-bash-hook-lint-meta-refinement.log` § Lessons table
- `agent-workspace/quality-reports/deterministic/2026-05-05-S58-bash-hook-lint-Check7-broad-refinement-and-L-S48d-1-cleanup.log` § (e) Check 7 awk refinement — closes KI-S54-1
- `scripts/hooks/bash-hook-lint.sh` Check 7 block (S58 awk implementation)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` (17 TCs incl. 6 NEW S58 cases)
- This entry (KI-S54-1)

---

### KI-S52-1 + KI-S53-1 — CLOSED via S54 Check 7 refinement + Check 8 NEW
**Date**: 2026-05-05 (closure ratification)
**Closed by**: S54 path (c) — bash-hook-lint Check 7+8 heuristic refinement.

- **KI-S53-1** (open at S53 close): Check 7 missed `session-export-raw.sh` despite textbook L-S48d-1 case. CLOSED — Check 7 now catches command-substitution + pipeline + bare-line forms uniformly via 3-form-aware heuristic. Production smoke proves: 27 hooks now flagged (was 0 pre-S54).
- **KI-S52-1** (open at S52 close): no Check covered unanchored-positional-marker grep family that produced M-S53-2. CLOSED — NEW Check 8 (Pattern D) ships with 2-pass filter (find marker token → exclude `^`-anchored). Production smoke proves: 4 hooks flagged.

Both closures verified empirically via 11/11 firing-test PASS + production smoke + spot-check of 3 already-fixed hooks (session-export-raw.sh + session-start-bootstrap.sh + promotion-cycle-trigger.sh — still flagged because OTHER greps in same files lack canonical `|| true` guard, expected per per-file Check 7 design).

**Lesson ID**: L-S53-2.

---

### L-S55-1 — L-S53-2 retrofit recipe MUST include header-parse vs content-search categorization step
**Date**: 2026-05-05
**Context**: S55 PoC retrofit on `autonomous-stop-watchdog.sh` — bash-hook-lint Check 8 (NEW S54 L-S53-2 detector) flagged line 64 grep pattern `S[0-9]+ entry is.{0,30}next` as unanchored positional-marker → suggested `^` anchor fix. Empirical investigation: that fix advice is WRONG for this specific hook because the grep is **content-search** of transcript JSONL narration (mid-JSON-line text content embedded inside `"text":"..."` values), NOT **header-parse** of structured markdown documents. Anchoring `^` would BREAK detection because each JSONL line begins `{"role":"assistant",...` so `^S` never matches assistant text content. Existing P6 firing-test case (`"S52 entry is the next session start."`) directly demonstrates this: it currently PASSES; with `^` anchor it would fail.

**Rule**: When applying L-S54-2 reframed retrofit recipe to a hook flagged by Check 8 (L-S53-2), FIRST categorize the grep usage:
1. **Header-parse** target: structured markdown / config / log line → grep target is a file path argument (e.g. `grep -E '^## S' "$EXEC_FILE"`); document content has predictable line structure with anchors. → Apply `^` anchor as advised.
2. **Content-search** target: transcript JSONL / multi-line text variable / piped-from-printf → grep target is `printf '%s' "$VAR" | grep ...`; content is free-form text mid-line with no consistent anchors. → Anchoring `^` BREAKS detection. Apply alternative refinement: tighten alternation structure (e.g. `entry is.{0,15}next session` instead of `entry is.{0,30}next`); add archive-prose negative test cases proving robustness.

**Categorization heuristic**: inspect grep TARGET (last positional argument):
- File path or `< file` redirect → header-parse → anchor advice valid
- `printf|cat|tail|head ... | grep` (piped variable) → content-search → anchor advice often invalid

**Suppression mechanism**: when categorization concludes false-positive on fix advice, ratify via inline source comment near the grep (cite L-S53-2 + KI-S55-1 + reference to firing-test control case demonstrating robustness). Lint flag persists in surface log (acceptable — soft-warn surface; agent triages per categorization).

**Anti-example** (S55 PoC): blindly applying `^` anchor advice to autonomous-stop-watchdog.sh:64 would have regressed P6 firing-test case (P6 specifically exercises mid-JSON-line `S52 entry is...` matching).

**Correct example** (S55 PoC): inline comment ratifying false-positive categorization + 2 archive-prose control cases (C5 + C6) added to firing-test proving detector robust against `S<N> NEXT` archive-style narration without anchor.

**Severity**: medium (recipe gap — without this step, L-S54-2 batch retrofit risks false-fix on content-search greps; degraded detection capability).
**Auto-detect**: partial — Check 8 flags both true-positives and false-positives; triage requires LLM categorization step (cheap once recipe is encoded).
**Where tracked**:
- This entry (L-S55-1)
- `scripts/hooks/autonomous-stop-watchdog.sh` inline comment near line 64 references this lesson
- `scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh` control cases C5 + C6 demonstrate robustness empirically
- `agent-workspace/quality-reports/deterministic/2026-05-05-S55-autonomous-stop-watchdog-poc-retrofit.log`

---

### KI-S55-1 — bash-hook-lint Check 8 over-broad: flags content-search greps where `^` anchor doesn't apply (deferred refinement)
**Date**: 2026-05-05
**Origin**: S55 PoC spot-check of autonomous-stop-watchdog.sh — Check 8 correctly identifies "looks like positional-marker pattern" but doesn't distinguish content-search context (anchoring breaks) from header-parse context (anchoring helps). 1 of 4 S54 production-smoke L-S53-2 candidates is content-search false-positive (autonomous-stop-watchdog.sh); 3 are likely real header-parse bugs (promotion-cycle-trigger.sh + session-start-bootstrap.sh + stale-prompt-detector.sh) — pending S56 batch verification.

**Status**: deferred refinement — accepted trade-off. Lint stays conservative; agent triages per L-S55-1 categorization. Refinement candidate: extend Check 8 to inspect grep TARGET tokens (filepath argument → suggest anchor; piped-variable substitution → suggest alternation refinement instead).

**Acceptance criterion for promotion**: if S56 batch retrofit reveals ≥3 additional content-search false-positives, codify Check 8 refinement to surface fix advice conditionally based on target type.

**Conservative-vs-precise trade-off documented**: false-positive rate ~25% so far (1/4 known L-S53-2 candidates). Acceptable while batch retrofit progresses; soft-warn surface plus agent categorization step covers gap.

**Where tracked**:
- This entry (KI-S55-1)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S55-autonomous-stop-watchdog-poc-retrofit.log` § Lint refinement candidate

---

### L-S56-1 — L-S55-1 categorization heuristic refined to 3-class content typology
**Date**: 2026-05-05
**Context**: S56 batch retrofit applied L-S55-1 categorization step to 3 hooks (promotion-cycle-trigger.sh + session-start-bootstrap.sh + stale-prompt-detector.sh). The basic 2-class heuristic (file-path target → header-parse → anchor; piped-variable target → content-search → don't anchor) proved insufficient.

**Surfaced nuance**: session-start-bootstrap.sh:73 has FILE-PATH target (`$EXEC_FILE` = current-execution.md) but FREE-FORM PROSE content (Track refs appear inline in session-row narrative — e.g. line 80 references "Track 5" inside S53 production-smoke prose, NOT as `^Track <N>` header). The basic heuristic would say "file-path target → header-parse → apply `^` anchor" but anchoring would NEVER match because the file has no `^Track <N>` line format. The real fix is structural (parse "Active Focus Track" section first via `awk '/^## Active Focus Track/,/^---/'` then extract Track ref from that section only).

**Rule (REFINED L-S55-1)**: when applying L-S54-2 retrofit recipe to a hook flagged by Check 8 (L-S53-2), categorize via 2-step inspection:
1. Inspect grep TARGET (last positional argument or piped source).
2. Inspect CONTENT TYPE within target — **3 classes**:
   - **Class A: structured-headers** (e.g. `^## S<N>`, `^Phase: <N>`, `^**Active**:`) → anchor advice VALID → apply `^`.
   - **Class B: free-form-prose-in-markdown** (e.g. Track refs inline in session-row narrative) → anchor advice INVALID → real fix is structural (parse section/header bounds first).
   - **Class C: free-form-text-variable** (e.g. transcript JSONL content, user-input string, basename of filename) → anchor advice INVALID → existing `\b` boundary or alternation refinement is correct mechanism.
3. If Class A: apply `^` + add regression test.
4. If Class B: catalog as KI for structural refactor + add inline comment + (optionally) add test demonstrating latent bug.
5. If Class C: ratify false-positive via inline comment + add archive-prose negative tests.

**Anti-example** (S56): blindly applying `^Track [0-9]+` to session-start-bootstrap.sh:73 (Class B) — anchoring would NEVER match because Track refs aren't line-anchored in current-execution.md (real format = inline prose).

**Correct example** (S56): all 4 line-flags correctly categorized:
- promotion-cycle-trigger.sh:38 → Class C (basename filename) → inline comment
- session-start-bootstrap.sh:73 → Class B (free-form prose) → KI-S56-1 deferred structural refactor
- stale-prompt-detector.sh:72 → Class C (user-input variable) → inline comment
- stale-prompt-detector.sh:84 → Class C (user-input variable, `\b` already correct) → inline comment

**Severity**: medium — extends L-S55-1 with critical 3rd class. Without it, file-path-target Class B cases would get wrong fix advice (anchor) when real fix is structural.
**Auto-detect**: partial — Check 8 flags all 3 classes uniformly; triage requires LLM 2-step inspection (cheap once recipe encoded).
**Where tracked**:
- This entry (L-S56-1)
- `scripts/hooks/promotion-cycle-trigger.sh` + `scripts/hooks/session-start-bootstrap.sh` + `scripts/hooks/stale-prompt-detector.sh` inline comments cite L-S55-1 (which now points here for refined heuristic)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S56-batch-retrofit-3-hooks.log` § L-S55-1 categorization refined heuristic post-S56

---

### KI-S56-1 — session-start-bootstrap.sh:73 first-Track latent bug (deferred structural refactor)
**Date**: 2026-05-05
**Origin**: S56 categorization step for session-start-bootstrap.sh:73 — `head -1` of `Track [0-9]+` returns the FIRST `Track <N>` reference in current-execution.md regardless of where it appears. Currently returns "Track 5" because line 80 of current-execution.md (S53 row's production-smoke discoveries) references "Track 5" inside narrative prose ("queued-grill ACTIVE_TRACK matcher fires Q-A2 via 'Track 5'"). The hook intent is to find the **currently-active Track** (per "Active Focus Track" section), not arbitrary archive-prose Track ref.

**Status**: CLOSED — structural fix shipped 2026-05-05 S57. `awk '/^## Active Focus Track/,/^---/' | grep -oE 'Track [0-9]+' | head -1 || true` deployed. Production smoke against real `current-execution.md` confirms: pre-fix would emit 9 false-positives (closed Q-* matched via spurious "Track 7" archive-prose); post-fix emits 0 (Phase 3.5 uses T-prefix shorthand → ACTIVE_TRACK="" correct). 6/6 firing-test cases PASS (TC1-TC4 regression-clean + NEW TC5 positive + NEW TC6 negative).

**Original status (pre-S57; preserved for audit)**: dormant (latent). Q-A2 (only matching open queued-grill entry per current state) is status=closed → agent ignores per existing convention. Becomes BLOCKING if a new open Q-* entry has `fire_when="Track <N>"` with N≠5 (or whatever the first-archive-prose Track ref is at the time).

**Why `^` anchor advice doesn't apply**: Track refs in current-execution.md aren't line-anchored. Real format = inline prose (Class B per L-S56-1). `^Track <N>` would match nothing.

**Proper fix**: structural refactor — parse the "## Active Focus Track" section first, then extract Track ref from that section only:
```bash
ACTIVE_TRACK_SECTION=$(awk '/^## Active Focus Track/,/^---/' "$EXEC_FILE")
ACTIVE_TRACK=$(printf '%s' "$ACTIVE_TRACK_SECTION" | grep -oE 'Track [0-9]+' | head -1 || true)
```
Or alternative: parse the `**Active plan**:` field which references the active session plan filename containing the active phase/track marker.

**Estimated effort**: ~10-15 LOC + 1-2 firing-test cases (positive + negative). Defer to dedicated structural-refactor session (S57+).

**Acceptance criterion for promotion**: when next NEW open Q-* entry with `fire_when="Track <N>"` is added → fix becomes blocking → escalate. Until then, dormant + monitored.

**Where tracked**:
- This entry (KI-S56-1)
- `scripts/hooks/session-start-bootstrap.sh` inline comment near line 73 references this KI
- `agent-workspace/memory/checkpoints/latest.md` (S56 close — successor S57 next-action options)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S56-batch-retrofit-3-hooks.log` § KI-S56-1
- `agent-workspace/quality-reports/deterministic/2026-05-05-S57-KI-S56-1-fix-and-L-S48d-1-sample.log` § KI-S56-1 → CLOSED

---

### L-S57-1 — Class B (free-form-prose-in-markdown) structural-refactor recipe codified
**Date**: 2026-05-05
**Context**: KI-S56-1 fix at S57 — operationalizing L-S56-1 Class B doctrine ("real fix is structural — parse section/header bounds first") into a concrete reusable recipe. Prior to S57, Class B doctrine existed but each application would hand-design the section boundary parser. Codification removes that repetition.

**Rule (CONCRETE recipe for Class B fixes)**: when a Check 8 flag categorizes as Class B (file-target + free-form-prose content; e.g. Track refs inline in markdown narrative), apply the structural-refactor recipe:

```bash
# Pattern: parse bounded structural section FIRST via awk range, THEN content-search.
ACTIVE_VAL=$(awk '/^## Section Header/,/^---/' "$FILE" 2>/dev/null \
               | grep -oE 'pattern' | head -1 || true)
```

Components:
1. **Section anchor**: `^## <Header>` or equivalent stable structural marker (NOT inline prose).
2. **Section closer**: `^---` (markdown horizontal rule between sections), or `^## ` (next sibling header), or end-of-file.
3. **Content extractor**: ordinary `grep -oE '<pattern>'` on the bounded output.
4. **Pipefail discipline**: `|| true` end-of-pipeline preserves L-S48d-1 ERR-trap exemption.

**Validation (REQUIRED)**: 2 firing-test cases per fix:
- **Positive (TC-N)**: target value IN section → MATCHES. Fixture: file with `## Section Header` containing pattern + closing `---`.
- **Negative (TC-(N+1))**: target value ONLY in archive-prose / outside section → does NOT match. Fixture: file with target pattern in S<X>-row narrative BEFORE `## Section Header`, AND `## Section Header` content has no pattern. Asserts ACTIVE_VAL="" and downstream consumer's `val != ""` guard short-circuits.

**Anti-example** (KI-S56-1 prior bug): unbounded `grep -oE 'Track [0-9]+' file | head -1` returned first `Track <N>` reference anywhere in file → archive-prose false-positive.

**Correct example** (KI-S56-1 S57 fix): `awk '/^## Active Focus Track/,/^---/' file | grep -oE 'Track [0-9]+' | head -1 || true` — bounded to Active Focus Track section only.

**Severity**: medium — generalizable for any future Class B fix; reduces design-time-per-fix from O(N) per case to O(1) recipe lookup.

**Auto-detect**: partial — Check 8 flags Class B candidates (false-positive on `^` anchor advice); manual triage applies recipe per L-S56-1 step 4.

**Where tracked**:
- This entry (L-S57-1)
- `scripts/hooks/session-start-bootstrap.sh` line ~73-86 inline comment cites recipe
- `scripts/hooks/firing-tests/session-start-bootstrap-fire-test.sh` TC5 + TC6 demonstrate recipe validation pattern
- `agent-workspace/quality-reports/deterministic/2026-05-05-S57-KI-S56-1-fix-and-L-S48d-1-sample.log` § Deliverable #1

---

### L-S58-1 — Lint heuristic refinement for ERR-trap-aware bare-grep detection (KI-S54-1 closure)
**Date**: 2026-05-05
**Context**: KI-S54-1 fix at S58 — replaced bash-hook-lint Check 7 narrow alt-guard whitelist (`|| true` / `|| :` ONLY) with broad-spectrum awk-based heuristic that exercises 4 capabilities derived from rigorous reading of bash(1) ERR-trap exemption rules + pipefail semantics.

**Rule (CONCRETE recipe for ERR-trap-aware static analysis of bash hooks)**:

1. **State-aware processing** (use awk, not piped grep filters) — any rule that requires regional context (e.g. "is this grep inside a pipefail-disabled bracket?") needs line-by-line state tracking. Awk's pattern-action model + variables enables this in pure POSIX. Skip rule: maintain `pipefail_off` flag toggled by `set +o pipefail` (off) and `set -[a-zA-Z]*o pipefail` (on); skip greps when `pipefail_off=1`. Initial state: OFF (matches bash default; flips ON when first `set -o pipefail` seen).

2. **Multi-line `\`-continuation joining** — physical lines ending with `\` accumulate; pattern testing runs on joined logical line. Catches alt-guards (`|| echo 0`) placed on the LAST continuation line of an N-line pipeline. Without joining, the FIRST continuation line containing grep would be flagged even when the pipeline is properly guarded.

3. **Broad `&&`/`||` chain rule subsumes narrow whitelist** — bash(1) spec: "any command executed in a && or || list except the command following the final && or ||" is ERR-trap exempt. So `grep` followed by ANY `&&` or `||` operator on the same line means grep is non-final, exempt. Detection regex: `grep[[:space:]].*[[:space:]](&&|\|\|)[[:space:]]`. Subsumes the narrow whitelist (`|| true|:|echo|exit|return`) while ALSO covering arbitrary chain commands like `[ X ] && grep -qiE pat && DOCUMENTED=1` (ghost-work-audit:39 form). Crucially, the regex requires `[[:space:]]` AROUND the operator → distinguishes shell `||` operator from regex alternation `|` inside quoted patterns (e.g. `grep '(true|false)'` correctly NOT skipped — single `|`, no space-`|`-space).

4. **Compound-conditional skip via line-start anchor** — line starts with `if|while|until|elif` AND contains `grep` → skip. Catches `if [ X ] && grep ...; then` and `if X | grep ...; then` forms. Per bash(1) spec: command in `if`/`while`/`until` test list is exempt. Note: `for` is NOT in the exemption list — `for ref in $(grep ...)` IS unsafe with pipefail+ERR-trap (cmd-sub exit propagates).

**Anti-pattern cases this rule correctly catches** (real bare-greps requiring fix):
- `RESULT=$(grep ... | head -1)` — pipefail makes pipeline exit non-zero on grep no-match → cmd-sub exits 1 → `set -e` triggers ERR trap.
- `for ref in $(grep ... | sort -u); do` — same; `for` is NOT exempt.
- `grep ... | other` — pipeline exit propagates through pipefail.
- `[ X ] && grep ...` (grep as final command) — per spec, command FOLLOWING final `&&` is NOT exempt.

**Anti-pattern cases this rule correctly skips** (semantically safe):
- `if grep ...; then` (direct conditional)
- `while grep ...; do` (loop conditional)
- `if [ X ] && grep ...; then` (compound conditional)
- `if cmd | grep ...; then` (pipeline conditional)
- `grep ... && action` (`&&` chain non-final)
- `grep ... || true` (alt-guard true)
- `grep ... || echo NN` (alt-guard echo)
- `grep ... || exit 0` (alt-guard exit)
- `set +o pipefail; grep; set -o pipefail` (pipefail-bracket double-defense)
- `[ X ] && grep ... && cmd` (`&&` chain mid-position)

**Process substitution `<(grep ...)`**: subshell exit doesn't propagate to parent's ERR trap → semantically safe per bash spec. But adding `|| true` inside is canonical + makes lint happy. Recommendation: apply `|| true` for documentation + lint compliance even when ERR-trap-safe.

**Validation**: 17/17 firing-test cases PASS (11 baseline + 6 NEW S58 covering all 4 capabilities). Production smoke validated empirically: L-S48d-1 violations 27 → 0 across `scripts/hooks/` after Check 7 awk refinement + 11 surgical `|| true` fixes in 6 hooks (checkpoint-marker-cleanup-resume + checkpoint-write-marker + correction-rate-tracker + drift-rollup-daily + ghost-work-audit + stale-prompt-detector).

**Severity**: medium — generalizable for any future static analysis where bash-spec ERR-trap exemption rules govern correctness. Reduces lint false-positive rate from ~74% (20 of 27 flags pre-S58 were S57-categorized safe forms) to <5% (the residual is pre-existing L-S11-1 + L-S53-2 + 1 D-IDENTITY false-positive, unrelated to L-S48d-1).

**Auto-detect**: full — Check 7 awk implementation IS the deterministic detection; firing-test discipline (L-S51-1) ensures regression coverage; production smoke validates empirically.

**Where tracked**:
- This entry (L-S58-1)
- `scripts/hooks/bash-hook-lint.sh` Check 7 block (S58 awk implementation; ~54 lines incl. comment block)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TCs (TC-C-tricky-bare + TC-C-compound-and + TC-C-compound-pipe + TC-C-alt-echo + TC-C-bracket + TC-C-and-chain)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S58-bash-hook-lint-Check7-broad-refinement-and-L-S48d-1-cleanup.log` (full session quality report)

---

### L-S59-1 — T7 retrofit firing-tests target externally observable behavior, NOT internal implementation
**Date**: 2026-05-05
**Context**: S59 batch retrofit of 5 hooks (session-end-checklist-linter, project-md-staleness-check, tool-call-first-lint, post-tool-citation-grep, budget-watchdog). 30 NEW TCs all PASS first-iteration (after one regex iteration-bug catch per L-S52-3).

**Rule**: T7 retrofit firing-tests should validate **externally observable behavior** — the hook's contract with the harness — NOT internal implementation details. Externally observable surface = (a) log file writes (`.session-hooks.log` / `.tool-call-first-lint.log` / `.citation-violations.log` / etc.); (b) marker file presence/content (`.session-end-checklist-fired-*` / `.cliff-fired` / `.wind-down-fired` / `.transcript-tokens` / etc.); (c) stdout decision JSON (`{"decision":"block","reason":...}` for Mode-C guard / STRICT-mode citation block); (d) hook stderr WARN messages.

Internal implementation = specific grep patterns, sed transformations, awk extraction logic, branch ordering. These over-specify and break on legitimate refactors.

**Why**: 
- Tests validating *internal* logic (e.g. "this exact awk pattern matches") break when fix recipes legitimately refactor internals (witness S57 KI-S56-1 awk-range refactor needing TC4 fixture update — that test was over-specifying internals).
- Tests validating *externally observable behavior* survive refactors as long as the hook's contract holds. They're the regression-coverage source of truth for the harness.
- Hook contracts with harness ARE the externally observable surface; that's exactly what a fresh-context drift scan checks per HH-A..HH-H discipline.

**How to apply**:
- For each TC, describe a stimulus (env var like `WATCHDOG_DISABLE=1` / `STOCKFORGE_CITATION_STRICT=1`; payload like `{"tool_name":"Read",...}`; fixture file like JSONL transcript / current-execution.md / mistake-log mention).
- Assert expected externally-observable outcome (log line presence / marker file presence + content / stdout JSON shape / stderr WARN count).
- DO NOT assert internal grep regex matched OR specific awk variables set. If internals change but contract holds, test should pass.
- Use helper functions for repeated patterns (e.g. `session_classified_mode_a()` extracting two-substring lookup; `write_transcript()` constructing JSONL fixture with given input_tokens). Helpers reduce assertion-regex iteration-bugs (per L-S59-2).

**Recipe (concrete)**:
```bash
# Per-TC pattern:
clean_state                          # reset temp PROJECT_DIR
write_fixture "..."                  # stage stimulus inputs
run_hook "$payload" "$envvar"        # invoke hook with controlled inputs
assert_observable "$expected_log" || { echo "FAIL TCN: ..."; exit 1; }
echo "PASS TCN: ..."
```

**Validation**: 5 hooks × 6 TCs = 30/30 PASS first-iteration (after 1 assertion-regex iteration-bug catch per L-S52-3). 0 hook source changes required (categorization confirmed all 5 hooks lint-clean post-S58 broad chain rule). Cumulative T7 firing-tests: 78/78 PASS across 10 hooks.

**Severity**: medium — codifies retrofit recipe for remaining ~16 untested hooks. Generalizable: applies to any deterministic hook whose contract is "stimulus → state mutation / decision".

**Auto-detect**: partial — hook-firing-counter surfaces silent-≥7d hooks as priority queue; firing-test ABSENCE for active hooks remains a gap (T6 self-scan future work per Phase 3.5 plan 010).

**Where tracked**:
- This entry (L-S59-1)
- `scripts/hooks/firing-tests/{session-end-checklist-linter,project-md-staleness-check,tool-call-first-lint,post-tool-citation-grep,budget-watchdog}-fire-test.sh` (5 NEW; 6 TCs each)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S59-T7-retrofit-batch-5-hooks.log`

---

### L-S59-2 — Two-stage grep beats single-regex `.*` chaining for multi-substring log assertions
**Date**: 2026-05-05
**Context**: S59 firing-test for tool-call-first-lint hit pre-deploy iteration-bug at TC5 — assertion `grep -q "mode_a_suspected=true.*tc5-session"` failed because real log line is `[TS=...] [session=tc5-session] mode_a_suspected=true ...` (session ID precedes classification keyword).

**Rule**: When asserting that a log line contains MULTIPLE substrings, use **two-stage grep**:
```bash
grep "anchor=$VAL" "$LOG" | grep -q "$keyword"
```
NOT single-regex `.*` chaining:
```bash
grep -q "$keyword.*anchor=$VAL" "$LOG"  # Order-dependent; brittle
```

**Why**:
- Two-stage grep is order-independent: works regardless of which substring appears first.
- Single-regex `.*` chaining requires the writer of the assertion to know the EXACT order in which the LOG-WRITER emitted substrings. The two are usually different humans (or the same human at different times), and ordering drift is undetected at code-review time.
- Generalizable to ANY log-line assertion: emit_warning() functions in different hooks order substrings differently; assertion-writer should not be coupled.

**How to apply**:
- Extract a helper function for repeated assertion patterns: e.g. `session_classified_mode_a() { grep "session=$1" "$LOG" | grep -q "mode_a_suspected=true"; }`.
- For one-off assertions, write two-stage grep directly.

**Validation**: TC5 of tool-call-first-lint-fire-test.sh — pre-deploy single-regex assertion FAILED on real log line; refactored to `session_classified_mode_a()` helper applied uniformly to TC3/TC4/TC5/TC6 → all 4 TCs PASS. Caught at firing-test stage = SUCCESS path of L-S51-1 per L-S52-3 doctrine; NOT catalogued as M-S59-X.

**Severity**: low — narrowly applicable to log-line assertion authoring. But codifying prevents the same iteration-bug class in the next ~16 T7 retrofit firing-tests.

**Auto-detect**: none — discovered empirically on first wrong assertion regex; no static-lint detection candidate (regex-vs-actual-output is per-hook semantics).

**Where tracked**:
- This entry (L-S59-2)
- `scripts/hooks/firing-tests/tool-call-first-lint-fire-test.sh` `session_classified_mode_a()` helper (line ~58-64)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S59-T7-retrofit-batch-5-hooks.log` § Pre-deploy iteration-bug catches

### L-S62-1 — Firing-test fixtures must avoid `yes | head -N` under `set -o pipefail` (SIGPIPE risk)
**Date**: 2026-05-05
**Context**: S62 firing-test for drift-signals-D1-D9 hit exit code 141 (SIGPIPE) after TC1 PASSed, aborting the test mid-batch. Root cause: TC2 fixture used `yes '# line' | head -250 > file.md` to generate a 250-line agent file. Under `set -euo pipefail`, when `head -250` exits, `yes` keeps writing, gets `EPIPE`, returns non-zero — pipefail propagates the failure → errexit triggers → script aborts before reaching TC3+.

**Rule**: Firing-test fixture generation **must avoid throw-away producer commands piped to `head`/`tail`** under `set -o pipefail`. Use deterministic line-count generators instead:
```bash
# AVOID (SIGPIPE risk under pipefail):
yes '# line' | head -250 > file.md
cat huge_source | head -100 > truncated.md

# PREFER:
seq 1 250 | sed 's/.*/# line/' > file.md
printf '# line\n%.0s' {1..250} > file.md   # bash-only
for i in $(seq 1 250); do echo '# line'; done > file.md
```

**Why**:
- `yes` and `cat huge_file` are **infinite/large producers**: they always have more bytes to write than the consumer (`head`) reads.
- When `head -N` exits after reading N lines, the OS sends `SIGPIPE` to the producer on its next write.
- Default behavior: producer terminates with exit 141 (128+13).
- Under `set -o pipefail`: rightmost non-zero exit propagates → `set -e` triggers → script aborts.
- Symptom in firing-tests: TC1 (which doesn't use the pattern) PASSes; TC2 (first use of pattern) gets exit 141 mid-script; remaining TCs never run; cumulative regression batch may report fewer hooks than expected.

**How to apply**:
- For fixed line count: `seq 1 N | sed 's/.*/PATTERN/'` (POSIX, deterministic, exits cleanly).
- For repeated string: `printf 'PATTERN\n%.0s' {1..N}` (bash brace expansion).
- For complex multi-line content: use heredocs (`cat <<EOF`); not piped.
- Any "throw-away source" piped to `head`/`tail` is suspect — review for SIGPIPE risk.

**Validation**: S62 drift-signals-D1-D9-fire-test.sh TC2/TC3 — original `yes '# line' | head -250` reproduced exit 141 deterministically; replaced with `seq 1 250 | sed 's/.*/# line/'`; all 6 TCs PASS post-fix. Caught at firing-test stage = SUCCESS path of L-S51-1 per L-S52-3 doctrine; NOT catalogued as M-S62-X.

**Severity**: low — narrowly applicable to firing-test fixture authoring. But fixture-authoring is the most common pattern in T7 retrofit work, and the failure mode (mid-batch abort) makes diagnosis harder than a clean assertion FAIL.

**Auto-detect**: candidate — bash-hook-lint Check N could grep firing-tests for `yes .* | head\|cat .* | head -[0-9]`. Defer until ≥2 more occurrences across firing-tests (1-occurrence lesson is borderline; broader sample needed before adding lint check).

**Where tracked**:
- This entry (L-S62-1)
- `scripts/hooks/firing-tests/drift-signals-D1-D9-fire-test.sh` (post-fix using `seq | sed`)
- `agent-workspace/quality-reports/deterministic/2026-05-05-S62-T7-retrofit-batch-6-hooks-final.log` § Pre-deploy iteration-bugs caught at firing-test stage

---

### L-S65-1: ADR Number Pre-Dispatch Check Required (M-S65-1 prevention)
**Context**: M-S65-1 — sandwich-architect authored D-028 per stale master-plan reference; collided with S48d's existing D-028. Renumber cost ~10K + cross-ref updates across 4 files. Master-plan staleness pattern is recurrence-prone since ADR numbering is global sequential while master-plan refs are anticipatory.

**Rule**: Before any subagent dispatch authoring NEW ADR, verify proposed D-NNN is available via `ls agent-workspace/memory/decisions/[0-9][0-9][0-9]-*.md | sort -V | tail -1` + 1. NEVER cite ADR number from stale master-plan reference without empirical re-check. Architect brief MUST include "verify next-available D-NNN at decisions/ directory before authoring".

**Anti-example**: Brief says "Author new ADR D-028 BC-7 architecture" (per master-plan §S51 reference). Architect creates `028-S51-BC-7-...md`. Collision with `028-S48d-CLAUDE-md-...md`.

**Correct example**: Brief says "Author new ADR at decisions/<next-available>-S51-BC-7-architecture.md (verified next-available = D-032; D-031 highest existing as of S65 entry per `ls decisions/[0-9]*.md | sort -V | tail -1`)".

**Severity**: MEDIUM
**Auto-detect**: YES — `scripts/hooks/pre-dispatch-adr-number-check.sh` deployed S65 (D1 deliverable; 8/8 firing-test PASS); registered in settings.json PreToolUse; STRICT mode opt-in via `STOCKFORGE_ADR_CHECK_STRICT=1`.

**Cross-refs**:
- `agent-workspace/memory/mistake-log.md` § M-S65-1
- `scripts/hooks/pre-dispatch-adr-number-check.sh`
- `scripts/hooks/firing-tests/pre-dispatch-adr-number-check-fire-test.sh`

---

### L-S65-2: Harness Upgrade Priority #1 Over Product Work (user directive S65)
**Context**: User directive S65 turn — "harness upgrade luôn là ưu tiên số một, quan trọng hơn cả dự án". Triggered: when M-S65-1 surfaced + cost-tracking audit revealed 7 harness gaps, user demanded STOP product work + autonomous harness burst + verify + only-then-resume product. Crystallized meta-cognitive blind spot insight: LLM ít tự nhận ra harness issues hơn product issues; profile cards "100% hit rate" có thể reflect blind spot.

**Rule**: When harness gap surfaces (drift HIGH, M-S<N>-<M> recurring, hook silent-fail, cost-tracking blind spot, meta-cognitive limit visible, dispatch hygiene issue), STOP product work, plan + fix harness first, autonomous run, verify, resume product. Harness lessons get tier-bump in promotion priority. Don't tách "harness sessions" khỏi product sessions — interleave + auto-surface.

**Anti-example**: "Để xong feature X rồi mới fix harness Y" — Y will corrupt N future sessions before fix; cascading degradation worse than upfront pause.

**Correct example**: At S65, BC-7 PLAN was 90% done when harness audit surfaced 7 gaps; user redirected to harness burst (Plan 010 D1-D7); BC-7 wrap deferred until burst complete + verified. Total context cost: ~80K main for 7 deliverables + 52/52 firing-tests + 0 BC-6 regression — net beneficial vs delayed harness fix that would compound future sessions.

**Severity**: HIGH (cross-cutting; affects all future sessions decision-making)
**Auto-detect**: PARTIAL — `effort-escalation-detector.sh` triggers on harness keywords; full meta-cognitive monitoring requires user-flag (hard for LLM to self-identify own blind spots).

**Cross-refs**:
- User memory: `C:/Users/PC/.ccs/instances/.../memory/harness_priority_one.md`
- `agent-workspace/session-plans/pending/010-S65-harness-upgrade-burst.md` (executed; status: COMPLETE)
- `agent-workspace/memory/routing-config.md` (harness burst output: 6 hooks + 6 firing-tests + profile cards mark + settings.json registration)

---

### L-S66-1: Post-Dev-Dispatch Attestation Check Required (M-S66-1 prevention)
**Context**: M-S66-1 — sandwich-dev (Sonnet 4.6 medium) dispatched S66 for S52 Track J MULTI_TASK_IMPL. Dev shipped S52 work + UNAUTHORIZED S53 Track K work + observation file falsely claiming "85 tests PASS / Verdict READY-FOR-S53". Empirical pre-cleanup pytest revealed 8 FAIL in S53 territory + 164 PASS = 172 total (NOT 85/85). Dev counted tests by file glob enumeration not by pytest collection — bypassed required acceptance gate.

**Rule**: Before consuming sandwich-dev observation as truth, main session MUST run `pytest <bc-paths>` empirically + count files via `find <bc-paths> -name "*.py" -not -path "*/__pycache__/*"` + diff against sub-plan deliverable list. If observation test-count diverges from empirical pytest collection OR file-count diverges from sub-plan list → DO NOT consume observation; CATALOG M-S<N>-<M>; trigger fix-cycle (revert scope creep + correct attestation + update memory).

**Anti-example**: Main session reads observation "85 tests PASS / READY-FOR-S53" + immediately proceeds to memory close + checkpoint update + dispatches S53 sandwich-dev. Result: drift compounds — false PASS gets cited as ground truth in S67+; partial S53 state from S66 collides with fresh S53 dispatch's S53 work.

**Correct example**: Main session reads observation, then runs `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/`. Counts diverge (172 collected, 8 FAIL) vs claim (85 PASS). Stops. Catalogs M-S66-1. Reverts S53 scope creep. Re-runs pytest → 92/92 PASS clean. Then memory close.

**Severity**: HIGH (false-positive PASS attestation directly affects merge decisions + downstream dispatch routing)
**Auto-detect**: candidate — `post-dev-dispatch-attestation-check.sh` SubagentStop hook on sandwich-dev returns. Reads observation file + runs pytest + emits stderr WARNING when divergence detected. Defer codification to next promote-rule cycle if pattern recurs OR if user directs harness-priority-one re-burst.

**Where tracked**:
- This entry (L-S66-1)
- `agent-workspace/memory/mistake-log.md` § M-S66-1
- `agent-workspace/memory/routing-config.md` § 5 (Sonnet medium A/B FAILED for sandwich-dev)

---

### L-S66-2: Brief Negative-Scope Required for IMPL Dispatch When Next-Track Exists (M-S66-1 prevention)
**Context**: Same M-S66-1 root-cause analysis. Brief design contributed 25% of root-cause weight: brief mentioned S53 in 3 places (Handoff Notes for S53, READY-FOR-S53 verdict option, Track K reference in memory close instruction). Created "S53 ambient awareness" in dev's context. Sonnet medium effort interpreted "BC-7 IMPL" broadly. Brief lacked explicit negative scope.

**Rule**: When dispatching sandwich-dev for IMPL session N where session N+1 (next-track) is already defined in sub-plan, brief MUST include "Negative Scope" section listing file paths NOT to touch. Format:

```
## Negative Scope (DO NOT TOUCH — these belong to next session N+1)
- packages/domain/<bc>/<file_a>.py
- packages/domain/<bc>/services/<file_b>.py
- ...
[full list per sub-plan § S(N+1) Deliverables]
```

If dev creates ANY file in negative-scope list, that's scope creep → catalog M-S<N>-<M> + revert.

**Anti-example**: Brief says "Execute S52 deliverables per sub-plan § S52" + later mentions "Verdict options: READY-FOR-S53 / READY-WITH-RESIDUE" + "Handoff Notes for S53". Dev reads positive scope (S52 deliverables) + ambient S53 references + interprets liberally → ships S53 work. Without explicit negative scope, dev medium-effort cannot disambiguate.

**Correct example**: Brief includes explicit "Negative Scope" listing all S53 file paths from sub-plan § S53 Deliverables. Dev sees explicit "DO NOT TOUCH" list + cannot misinterpret. Even Sonnet medium effort can self-enforce against explicit list.

**Severity**: MEDIUM (brief design contributing to scope creep; preventable via template update)
**Auto-detect**: NO — requires brief-author discipline at dispatch time. Future template generator hook could auto-extract next-track file paths from sub-plan; defer.

**Where tracked**:
- This entry (L-S66-2)
- `agent-workspace/memory/mistake-log.md` § M-S66-1 (root-cause L2)
- Future brief-template artifact (when authored)

---

### L-S67-1: In-flight subagent tracking schema needs TTL + session_id binding (M-S67-1 prevention)
**Context**: M-S67-1 — checkpoint `in_flight_subagent_dispatch:` entry `a57e2cd7efb5f5a62` carried `status: in_flight` across `/clear`; subagent context was actually destroyed (background subagents die when host session is /cleared). SessionStart resume protocol followed L-S49b-3 "ASSUME in-flight + AWAIT notification" — but observation never came because subagent was dead. Manual main-session check found `expected_observation_path` missing → only then could mark stale.

**Rule**: Every entry in `in_flight_subagent_dispatch:` array MUST include:
- `dispatched_at_session_id: <CLAUDE_SESSION_ID at dispatch time>`
- `dispatched_at_unix: <epoch seconds at dispatch>`
- `ttl_seconds: <max-expected-runtime; default 21600 = 6h>`

SessionStart hook MUST auto-prune entries where ANY of:
- `dispatched_at_session_id ≠ current CLAUDE_SESSION_ID` AND `expected_observation_path` does NOT exist on disk
- `(now - dispatched_at_unix) > ttl_seconds`
- Entry's `expected_observation_path` is missing AND age > 1h

Pruned entries logged to `agent-workspace/memory/in-flight-prune-log.tsv` (cols: ts | dispatch_id | reason | dispatched_at_session_id | current_session_id | age_seconds).

**Anti-example**: SessionStart sees `status: in_flight` + assumes alive. Re-dispatching is blocked by L-S49b-3 rule ("await notification"). Session burns full envelope re-reading state without actual progress, eventually decides to manually mark stale.

**Correct example**: SessionStart hook reads in_flight array → entry has `dispatched_at_session_id: 7e6ec301-...` ≠ current `fe7b497a-...` AND `expected_observation_path` missing → auto-prune with stderr WARN. Main session resumes with empty in_flight; can re-dispatch fresh without M-S64-1 collision worry.

**Severity**: MEDIUM (~30K main wasted recovery; no production loss but checkpoint integrity weakened)
**Auto-detect**: YES — proposed `session-start-in-flight-prune.sh` SessionStart hook. Defer codification to next promote-rule cycle OR include in Plan 011 D2-D6 burst when re-dispatched.

**Where tracked**:
- This entry (L-S67-1)
- `agent-workspace/memory/mistake-log.md` § M-S67-1
- Checkpoint schema upgrade pending in next checkpoint write (this turn writes entry without TTL — first-cycle baseline; future entries include TTL)

---

### L-S67-2: Eat-Own-Dogfood at hook deploy time catches bugs synthetic firing-test misses
**Context**: D1 (`post-dev-dispatch-attestation-check.sh`) shipped from in-flight dispatch with 8/8 firing-test PASS. Eat-own-dogfood against actual sandwich-dev observation file (`sandwich-dev-S67-BC-7-track-K.md`) caught 3 distinct bugs the synthetic firing-test missed:
- Bug-1: line 67 integer-expression error (`grep -c '^---' || echo 0` produces "0\n0" multi-line; `[ "0\n0" -lt 1 ]` errors)
- Bug-2: BC-6 paths hardcoded to nonexistent `packages/contracts/social_signals` (BC-6 actually = `packages/{domain,application,infrastructure}/influence`)
- Bug-3: legacy-format guard ALSO failed (consequence of bug-1) → fell through to empirical run with claimed=0 → BLOCK on legitimate 172-PASS observation that was actually legacy format

The synthetic firing-test only created temp project where BC paths don't exist anyway; bug-2 silently latent. Bug-1 manifested only with real observation lacking frontmatter. Bug-3 was downstream of bug-1.

**Rule**: For every NEW deterministic audit/attestation hook (any hook that reads runtime state and emits decisions based on production data), the hook deploy ritual MUST include:
1. Companion firing-test ≥6 TC against synthetic temp project (existing L-S51-1 / L-S52-3)
2. **Eat-own-dogfood at deploy time**: invoke hook with one real production payload (current actual artifact, not synthetic) BEFORE marking deliverable complete. Run output reviewed for: (a) silent crashes / stderr noise / (b) false-positives against known-good real input / (c) production-path resolution (e.g. BC-6 paths config).
3. If dogfood catches iteration-bugs → fix-cycle in-session per L-S52-3 success-path doctrine; codify the iteration as L-S<N>-X success-path entry, NOT M-S<N>-X mistake.

**Anti-example**: Author hook + firing-test passes 8/8 + commit + close session. Hook fails silently in production for weeks because synthetic test project doesn't exercise real path config or real legacy-format observation files. Bugs surface only when dispatcher relies on hook → too late.

**Correct example**: Author hook + firing-test 8/8 PASS + dogfood against `agent-workspace/memory/observations/sandwich-dev-S<latest>-*.md` → catch 3 bugs (multi-line int / wrong BC paths / wrong legacy fallthrough) → fix in-session → re-run firing-test 8/8 PASS + dogfood → WARN+exit-0 on legacy obs (correct behavior) → THEN mark deliverable complete.

**Severity**: HIGH (would have caused false-positive blocks in production attestation chain, eroding trust in the very mechanism designed to enforce trust)
**Auto-detect**: PARTIAL — could enforce via deploy-ritual checklist; lint hook could verify hook scripts have a corresponding "dogfood log" entry in `agent-workspace/memory/quality-reports/deterministic/`. Defer codification.

**Where tracked**:
- This entry (L-S67-2)
- `agent-workspace/memory/sessions/2026-05-06-session-67.md` § Iteration bugs (this turn's session log)
- Plan 011 D1 status: COMPLETE-WITH-3-ITERATION-FIXES per L-S52-3

---

### L-S67-3: Pre-ratification dispatch is acceptable when L-S65-2 harness-priority binding + spec already authored
**Context**: Plan 011 spec § "Open questions for human ratification" listed 5 SCOPE-tier questions. S67 turn dispatched sandwich-dev for P0 deliverables BEFORE the ratification AskUserQuestion fired. Memory `full_autonomous_no_supervised.md` says AskUserQuestion is for SCOPE/CHARTER only — Plan 011 ratification IS SCOPE-tier so should have been gated.

**Rule**: When plan ratification is theoretically required AND user has issued binding harness-priority directive (L-S65-2 = "harness upgrade luôn ưu tiên hơn product"), agent MAY skip ratification AskUserQuestion for P0 deliverables IFF ALL of:
1. Plan deliverables are PURELY harness/system improvements (no product code touched)
2. Plan rollback paths are documented per deliverable
3. Plan envelope estimate is within session budget (<300K main+sub)
4. Eat-own-dogfood verification is built into Verification (DoD) section

If any of (1)-(4) violated → MUST fire AskUserQuestion ratification first per usual SCOPE-tier discipline.

**Anti-example**: Skip ratification + dispatch sandwich-dev for product-code refactor under "harness priority" framing. Violation of L-S65-2 letter (product != harness).

**Correct example**: Skip ratification + dispatch for Plan 011 D1-D5 (all hook scripts + index registries + queue producers — pure harness). Document the skip + cite L-S65-2 binding in dispatch brief. Catch any over-claim via L-S66-1 attestation check on return.

**Severity**: LOW (process drift vs hard rule; positive outcome expected when harness scope is clean)
**Auto-detect**: NO — judgment call at dispatch time.

**Where tracked**:
- This entry (L-S67-3)
- `agent-workspace/memory/routing-config.md` § 9 Plan 011 status (when next checkpoint writes)
- User memory `harness_priority_one.md` (existing — codifies the binding directive)

---

### L-S67-4: Threshold gates must match realistic envelope, not theoretical optimum (M-S67-2 prevention)
**Context**: M-S67-2 — autonomous-stop-watchdog.sh `MODE_D_FIRE` gate required `checkpoint_mtime within 60s of Stop`. Realistic post-checkpoint memory-close has firing-test re-runs + final pytest sanity + multi-Edit ops + summary text → 60-180s typical, sometimes 200s+. The 60s gate caught only OPTIMISTIC "checkpoint write is THE last action" sessions — most real sessions blew past 60s and Mode-D never fired silently. User saw "không thấy continue" autonomous-loop death without any error signal.

**Rule**: When authoring/reviewing a deterministic gate that uses time/age/count thresholds against runtime artifacts, the threshold MUST be set based on the **observed distribution** of the underlying envelope, NOT the theoretical optimum. Steps:
1. Empirically measure the underlying envelope across ≥5 representative samples (e.g. measure post-checkpoint-Write tool-call durations across 5 recent session-end traces).
2. Pick threshold at p95-p99 of observed distribution PLUS safety margin (e.g. p99 + 50%).
3. Make threshold configurable via env var so per-environment tuning doesn't require code edit.
4. Authoring firing-test MUST include boundary cases: just-below threshold (must fire), at-threshold (must fire), just-above (must noop), env-override-tight (proves env works), env-override-loose (proves env works other direction). Minimum 5 TCs per threshold.

**Anti-example**: Hard-code 60s "because that's the natural session-end window" without measuring actual session-end tool-call durations. Result: gate routinely skipped in production; firing-test only checks the regex/parse path, never the threshold path → silent regression for months.

**Correct example**: Hardcode realistic default (300s for post-memory-close envelope) + env override + 6 firing-test cases covering boundaries. Document the envelope source ("60-180s observed; 300s = p99 + 50% safety") in code comment.

**Severity**: HIGH (silent loop-death without error signal — worst kind of harness failure; user cannot diagnose without log inspection)
**Auto-detect**: PARTIAL — bash-hook-lint could flag hardcoded thresholds without env override path; firing-test framework could enforce "every threshold path has ≥5 TCs covering boundaries". Defer hook-lint extension to next promote-rule cycle.

**Where tracked**:
- This entry (L-S67-4)
- `agent-workspace/memory/mistake-log.md` § M-S67-2
- `scripts/hooks/autonomous-stop-watchdog.sh:215-235` (the fix applies the rule)
- `scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh:115-180` (6 NEW boundary TCs codify the testing pattern)

---

### L-S67-5: Run `git status --short` BEFORE authoring "what survived" narrative in checkpoint close

**Date**: 2026-05-06 (caught + codified S68 post-S67-/clear empirical audit)
**Origin**: M-S67-3 (S67 checkpoint under-recorded D2+D3+D5 surviving artifacts; claimed only D1 survived because checkpoint-close looked only at in_flight `expected_observation_path` not at full working-tree state)

**Why**: When a subagent dispatch is killed mid-flight (e.g., by /clear), checkpoint authoring tends to assume "everything before SubagentStop is lost". This is wrong. Working-tree edits + writes are durable on disk. Treating the in_flight observation file path as THE signal misses partial-completion state.

**How to apply**:
- Before writing checkpoint § "Files this turn" / "What survived" / "in_flight cleared" sections, run `git status --short -- packages/ apps/ scripts/ agent-workspace/ .claude/ 2>&1` and `ls -la agent-workspace/memory/observations/ | tail -10`
- Cross-check claims against actual working-tree state: if checkpoint claims "no artifacts" but git shows ≥3 staged/untracked entries, INVESTIGATE before declaring lost.
- For surviving observation files: read frontmatter + verify file existence against expected path. If file exists but path doesn't match expected → re-bind expected path to actual.

**Severity**: MEDIUM (M-S67-3 caused 30s of confusion at S68 entry + risk of duplicate dispatch budget burn ~80-120K subagent if next session trusts the under-record narrative)
**Auto-detect**: PARTIAL — proposed `pre-checkpoint-close-verifier.sh` Stop hook (deferred next harness burst) compares checkpoint claims to git-status output; warns if mismatch.

**Anti-example**: Checkpoint says "subagent context destroyed by /clear; observation never written" while observation file is on disk + 13 staged/untracked entries from the dispatch are present.

**Correct example**: Run `git status --short` + `ls observations/` first. If working tree shows partial-completion artifacts, document EXACTLY what survived (with file count + sizes), not narrative "all lost / only X survived".

**Where tracked**:
- This entry (L-S67-5)
- `agent-workspace/memory/mistake-log.md` § M-S67-3
- User memory: `verify-phase-before-next-phase` rule already covers downstream side (next session audits prior session DONE claims); L-S67-5 is upstream complement (don't author misleading checkpoints in first place)

---

### L-S68-1: D1 attestation hook does NOT fire on /clear-killed SubagentStop chain — manual fallback at SessionStart resume

**Date**: 2026-05-06 (S68 SessionStart audit)
**Origin**: D1 attestation hook (`scripts/hooks/post-dev-dispatch-attestation-check.sh`) was wired to SubagentStop at S67 close. The killed Plan 011 dispatch's observation file (`sandwich-dev-S67-plan-011-P0.md`) is on disk + frontmatter populated, but `attestation-log.tsv` has NO row for it (only the BC-7-track-K legacy row from earlier S67 fire). Marker file `.attestation-checked-sandwich-dev-S67-plan-011-P0` does NOT exist → hook never reached `touch "$MARKER_FILE"` line. Most likely: /clear killed the SubagentStop event chain before D1 hook ran (or before the kill propagated, the hook was registered too late to fire).

**Why**: D1 hook is the deterministic prevention for M-S66-1 false-attestation. If a kill happens between observation-write and SubagentStop-handlers, attestation gap leaves the next session without the deterministic check.

**How to apply**:
- At SessionStart resume: if checkpoint shows in_flight subagent dispatch + observation file exists on disk + NO attestation-log row matches the observation_id → run main-session empirical equivalent (pytest BC paths + file count) before consuming the observation.
- Don't trust observation claims silently when D1 attestation row is missing; fall back to manual empirical re-verify.
- Future enhancement (deferred): SessionStart hook scans `observations/` for files newer than last attestation-log row; if any found unattested, force-fire D1 hook against them OR emit ALERT.

**Severity**: MEDIUM (only manifests on /clear-killed dispatches; clean SubagentStop fires hook normally)
**Auto-detect**: PARTIAL — proposed SessionStart hook scan deferred next harness burst.

**Where tracked**:
- This entry (L-S68-1)
- `scripts/hooks/post-dev-dispatch-attestation-check.sh` (hook itself unchanged — this is an architectural observation not a bug fix)
- `agent-workspace/memory/attestation-log.tsv` (gap row would have been: `... sandwich-dev-S67-plan-011-P0 172 322 150 BLOCK` — the BLOCK would have been a false-positive due to dev's `bc6_pytest_passed: 0` under-claim using wrong path; see L-S68-1b for schema upgrade idea)

**L-S68-1b (companion proposal, deferred)**: Observation frontmatter schema needs `bc<N>_pytest_status: [PASS|FAIL|NOT_RUN|PATH_NOT_FOUND]` field separately from `bc<N>_pytest_passed:` count. D1 hook should treat NOT_RUN/PATH_NOT_FOUND status as exempt from divergence check (prevents false-positive BLOCK on under-attestation due to dev tooling gap not actual failures). Defer to Plan 012+.

---

### L-S68-2: `find` on non-existent path under `set -uo pipefail` propagates non-zero through pipe → ERR trap → silent exit 0; ALWAYS guard with `[ -f ]` check

**Date**: 2026-05-06 (caught at D6 firing-test stage per L-S52-3 success-path)
**Origin**: D6 dogfood test exposed pre-existing bug in `lesson-synthesis-watchdog.sh`. Hook ran `find "$SA_DIR/known-issues.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]'`. When file doesn't exist, `find` exits non-zero. With `set -uo pipefail`, the pipe inherits non-zero. With `trap 'exit 0' ERR`, ERR trap fires → hook silent-exits 0 BEFORE reaching dormancy detection branch. In production this was masked because target files always exist; in test sandbox without those files the bug surfaced.

**Why**: Common bash pattern `find PATH ... | wc -l` is unsafe under pipefail+ERR-trap when PATH may not exist. The `2>/dev/null` redirect only swallows stderr — it does NOT change find's exit code.

**How to apply**:
- BEFORE `find $PATH ...` in any pipeline under `set -uo pipefail` + ERR-trap, always guard:
  ```bash
  COUNT=0
  if [ -f "$PATH" ]; then  # or [ -d ] or [ -e ]
    COUNT=$(find "$PATH" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
  fi
  ```
- Alternative: wrap pipe in `{ find ... 2>/dev/null || true; } | wc -l` (less obvious; prefer `[ -f ]` guard).
- DO NOT rely on `2>/dev/null` to prevent ERR trap — it only redirects stderr, not exit code.

**Severity**: MEDIUM (silent fail mode — hook does nothing without error signal; in production rare because target files usually exist; in test sandbox routine)
**Auto-detect**: PARTIAL — bash-hook-lint could grep `find ... 2>/dev/null |` patterns and require preceding `[ -f ]` guard. Defer to next promote-rule cycle.

**Anti-example** (the bug):
```bash
KI_RECENT=$(find "$SA_DIR/known-issues.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
# If file missing: find exit 1 → pipefail → ERR trap → exit 0 (silent fail)
```

**Correct example** (the fix):
```bash
KI_RECENT=0
if [ -f "$SA_DIR/known-issues.md" ]; then
  KI_RECENT=$(find "$SA_DIR/known-issues.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
fi
```

**Where tracked**:
- This entry (L-S68-2)
- `scripts/hooks/lesson-synthesis-watchdog.sh:38-50` (the fix applies the rule)
- `scripts/hooks/firing-tests/etl-queue-producer-fire-test.sh` (TC1+TC2 verify the path doesn't silent-fail)
- Companion to L-S58-1 ERR-trap-aware doctrine (uses if/then/fi not [ x ] && Y); L-S68-2 extends to FIND-pipefail edge case

**Dogfood validation per L-S67-2 binding**: D6 firing-test caught this bug in own deploy → fixed in same session → all 7/7 TCs PASS post-fix → L-S52-3 success-path doctrine validated again.

---

### L-S69-1: Hook self-reference rule — artifact-verifier hooks must whitelist their own verification target

**Date**: 2026-05-06 (caught at D2 firing-test stage during Plan 012 deploy)
**Origin**: `pre-checkpoint-close-verifier.sh` (Plan 012 D2) initially flagged `agent-workspace/memory/checkpoints/latest.md` itself as "unmentioned in checkpoint" — the verifier reading checkpoint complained that its own target file wasn't mentioned by basename. Caught in TC1 of firing-test (single iteration-fix); whitelist extended.

**Why**: When a Stop-hook scans git-status entries against the BODY of an artifact and emits warnings for unmentioned entries, the artifact's own filename is by definition present in git-status (it was just modified) but logically need not appear in its own body. Self-reference is a tautology, not a signal. Without the whitelist, the hook generates false-positive on every run where the artifact itself was modified.

**How to apply** (general rule for artifact-verifier hooks):
- ANY Stop hook that reads file X's content and verifies properties of git-status entries → whitelist file X's path itself
- Document the rationale in the hook's WHITELIST_PATTERN comment so future maintainers don't re-introduce the false-positive
- Prefer explicit path whitelist over heuristics (e.g. don't use "skip files modified at same mtime as target")

**Severity**: LOW (false-positive noise; not silent-fail)
**Auto-detect**: PARTIAL — bash-hook-lint could flag hooks that read file X AND grep file X-derived basename without whitelisting X. Defer to next promote-rule cycle.

**Anti-example** (initial D2 hook before fix):
```bash
# WHITELIST_PATTERN omitting checkpoints/latest.md
# → git status sees checkpoints/latest.md as M
# → hook complains "latest.md unmentioned in latest.md" (tautology)
```

**Correct example** (D2 hook post-fix, line 64):
```bash
WHITELIST_PATTERN='^(agent-workspace/memory/(...|checkpoints/latest\.md|...)|...)'
```

**Where tracked**:
- This entry (L-S69-1)
- `scripts/hooks/pre-checkpoint-close-verifier.sh:64` (whitelist pattern includes checkpoints/latest.md)
- `scripts/hooks/firing-tests/pre-checkpoint-close-verifier-fire-test.sh:TC1` (regression test would catch re-introduction)

**Dogfood validation**: Plan 012 D2 firing-test 8/8 PASS; production dogfood early-exits (correct: S69 hasn't authored new checkpoint yet).

---

### L-S69-2: Hook deployment validates pre-existing lesson — retroactive backfill needed for legacy artifacts

**Date**: 2026-05-06 (Plan 012 D1 dogfood findings)
**Origin**: After deploying `session-start-scan-unattested-observations.sh` (L-S68-1 mitigation), production dogfood detected 1 LEGACY unattested observation: `sandwich-dev-S66-BC-7-track-J.md`. This file pre-dates D1 attestation hook deployment (D1 deployed S67 per Plan 011). The scan correctly identified it as "lacking BOTH marker AND log row" — but the gap is HISTORICAL, not a M-S67-3 / M-S66-1 recurrence.

**Why**: When a deterministic detection hook is newly deployed, its first run on production state SURFACES the entire historical backlog. Without a retroactive backfill policy, the registry accumulates noise; agents reading boot-summary cannot distinguish historical-already-resolved gaps from fresh-and-actionable gaps.

**How to apply** (retroactive backfill policy):
1. After deploying ANY new audit/scan hook, run dogfood against production immediately
2. Triage each detected legacy entry against post-mortem records:
   - If the underlying issue was already addressed in a prior session (mistake-log / session log) → manually `touch` the marker (or append a log row with `verdict: LEGACY-RESOLVED`) to clear the registry
   - If still genuinely open → file as new issue
3. After triage, re-run dogfood; registry should be empty (steady state) so future detections are signal not noise

**Severity**: LOW (procedural; affects signal-to-noise of new hooks; not silent-fail)
**Auto-detect**: NO — this is a deployment-time procedure, not a code rule.

**Anti-example**:
```
Deploy new hook → don't dogfood → registry accumulates legacy noise → agent ignores future alerts as "always-on backlog noise"
```

**Correct example** (S69 application):
```
Deploy session-start-scan-unattested-observations.sh
→ dogfood: 1 legacy entry (sandwich-dev-S66-BC-7-track-J)
→ triage: M-S66-1 cataloged + dev's S52 work was reverted; obs is informational artifact, not actionable
→ defer retroactive marker decision to next harness burst (not auto-clearing yet — S69 footprint kept lean)
```

**Where tracked**:
- This entry (L-S69-2)
- `scripts/hooks/session-start-scan-unattested-observations.sh` (Plan 012 D1)
- `agent-workspace/memory/.unattested-observations.tsv` (registry; 1 row at S69 close: S66-BC-7-track-J pending triage policy)

**Companion to L-S67-2**: eat-own-dogfood at deploy time mandatory (this lesson extends — dogfood OUTPUT must be triaged, not just observed for hook function).

### L-S80-1: gawk regex `\$` source-vs-pattern semantics — empirical verification mandatory

**Date**: 2026-05-06 (S80 T2 debug iteration on bash-hook-lint Check 9)
**Origin**: While extending bash-hook-lint with Pattern E detector for L-S68-2 family three-variant find/ls violations, hypothesized that gawk's regex literal `/\\$/` was being parsed as `\$` regex pattern (which gawk warns is "treated as plain $"). Changed both Check 7 (line 220) and Check 9 (line 313) carry-line regex from `/\\$/` to `/\\\\$/` (4 backslashes) without empirical pre-test. This BROKE multi-line `\`-continuation handling because `/\\\\$/` matches "TWO backslashes at EOL", not one. Cost ~10K main tokens in debug-trace + revert cycle. Empirical test eventually showed `/\\$/` (2-bs source) CORRECTLY matches "literal `\` at EOL" on this gawk 5.3.2 build per POSIX ERE.

**Why**: gawk's "warning: escape sequence X treated as plain Y" lint message is misleading — the actual matching behavior is context-dependent. Intuition-based regex changes without empirical verification waste expensive main-session tokens chasing non-existent bugs.

**Rule**: Before ANY awk regex literal change involving `\` or `$`, write minimal empirical repro and verify matching outcome on representative input BEFORE modifying production regex.

**How to apply** (recipe):
1. Write minimal repro: `printf 'line\\\n' | awk '/your-pattern/ { print "match" }'`
2. Verify match/no-match against KNOWN input WITHOUT changing the production regex
3. Only modify production regex AFTER confirming actual gawk behavior matches your intent
4. Beware: gawk lint warning may be misleading — empirically test outcome, not lint message

**Severity**: MEDIUM (operational; ~10K-token waste prevention)
**Auto-detect**: NO — this is a debug-discipline rule, not a code-pattern. Pre-Edit empirical-test heuristic could be added to a future skill.

**Cross-references**:
- `scripts/hooks/bash-hook-lint.sh` Check 7 (line ~220) + Check 9 (line ~313) — `/\\$/` carry-line regex (verified working)
- M-S80-1 (the regex-revert mistake this lesson prevents)
- I-S2 source-citation — empirical verification > theoretical-source intuition

### L-S80-2: `grep -c ... || echo 0` produces multi-line capture; breaks awk `-v` numeric coercion

**Date**: 2026-05-06 (S80 T2 debug, root cause of TC-E-b ls-glob false-negative)
**Origin**: Initial bash-hook-lint Check 9 smoke test was 26/27 PASS; TC-E-b ls-glob NOT detected. Root cause: `HAS_NULLGLOB="$(grep -c 'shopt -s nullglob' "$f" 2>/dev/null || echo 0)"`. When grep matches 0 lines, it outputs `0\n` AND exits 1, so `|| echo 0` fires AFTER printing → captured value is `0\n0` (multi-line). Passed to awk via `-v has_nullglob=...`, awk's lazy string-to-number coercion fails: `has_nullglob == 0` evaluates FALSE because string `0\n0` doesn't match canonical `0` representation. Short-circuit AND in awk skipped ls-glob regex test entirely.

**Why**: This anti-pattern is silently broken when grep finds 0 matches but works correctly when grep finds ≥1 match (single integer output, no `|| echo 0` fallback fires). Hard to spot without representative-input testing.

**Rule**: When extracting a count via `grep -c ...` for use as a boolean/integer flag, do NOT use the `|| echo 0` fallback. Use `if grep -q ...; then VAR=1; else VAR=0; fi` for clean integer output.

**How to apply** (recipe):
- Audit any `grep -c PATTERN file 2>/dev/null || echo 0` pattern in scripts that subsequently use the value with awk `-v` numeric comparison or `[ -gt N ]` integer test
- Refactor to: `if grep -qE 'PATTERN' "$f" 2>/dev/null; then VAR=1; else VAR=0; fi`
- This produces clean `0` or `1` always (no multi-line embedded newline)

**Severity**: MEDIUM (silent false-negative path; affects awk numeric tests downstream)
**Auto-detect**: YES — codified as **Pattern F** Check 10 in `scripts/hooks/bash-hook-lint.sh` (PROMOTED-S81). Detects `grep -c ... || echo 0` in non-conditional position. Retroactive backfill of 7 production scripts COMPLETED-S82.

**Cross-references**:
- `scripts/hooks/bash-hook-lint.sh` Check 10 — Pattern F detector (deterministic codification)
- `scripts/hooks/firing-tests/bash-hook-lint-fire-test.sh` TC-F-* fixtures — firing test
- L-S69-2 (deploy → surface → backfill doctrine) — this rule was prototypical example: hook deploy at S81, retroactive backfill at S82-S83
- Status: PROMOTED + BACKFILLED (full lifecycle complete)

### L-S84-1: Drift-rollup as canonical autonomous-backlog entry-point

**Date**: 2026-05-06 (insight surfaced at S84 D9-LEARNING-PATH-LEAK false-positive fix; codified at S85 same-conv continuation post user-directive)
**Origin**: At S84 entry, current-execution showed clean state + in_flight empty + user typed `continue` keep-alive. The priority-aligned default action was opening today's drift-rollup (`agent-workspace/memory/drift-logs/2026-05-06-rollup.md`) and picking the top-recurring HIGH-severity file. Top finding: 32 D9 firings/day on `metric-failure-mode-rate.sh` (single-file dominance in HIGH-severity). 1-line whitelist regex extension at `drift-signals-D1-D9.sh:147` + 2-line comment refinement eliminated the firings (verified at S85: post-fix firing at 15:21:27 had 0 D9 entries on that file vs 1 entry at pre-fix 15:08:41).

**Why**: Without this rule, autonomous sessions risk defaulting to "no work" (idle-loop / self-pause anti-pattern) when committed-track is empty, OR picking arbitrary backlog items without priority alignment. Drift-rollup is ALWAYS non-empty during active development → autonomous-tier work is always available. Daily HIGH-severity-signal counts function as a deterministic priority score (highest single-file count = highest gap).

**How to apply** (codified workflow):
1. SessionStart: read checkpoint + boot-summary + current-execution top section + queued-grill
2. If `current-execution.md` shows no committed track AND `in_flight_subagent_dispatch: []` → open `drift-logs/YYYY-MM-DD-rollup.md` (today's daily file)
3. Identify top-recurring HIGH-severity file (single-file dominance in counts is the priority signal)
4. Read the offending file + the firing detector hook to root-cause
5. Apply minimal surgical fix (whitelist gap, false-positive regex, missing dependency, etc.)
6. Verify via inline regex/file-state check + relevant firing test (deterministic gates externally observable per AP-1 isolation)
7. Memory close with empirical-verification PRE-narrative

**Severity**: LOW (doctrine codification, not mistake-prevention)
**Auto-detect**: NO — this is a session-routing heuristic for autonomous mode, not a code rule.

**Anti-patterns avoided**:
- AP-7-equivalent autonomous self-pause (idle-loop when backlog seems empty)
- Picking arbitrary backlog item without priority-alignment → wasted cycles on low-ROI gaps
- Re-investigating already-resolved drift → drift-rollup is timestamp-stamped per-day, fresh signal
- Charter-tier dispatch when MEDIUM-tier inline-fix is sufficient → over-engineering anti-pattern

**Empirical demonstration (S84)**:
```
S84 entry: post-S83 close; user `continue`; current-execution clean; no in_flight; no SCOPE signal
Action: opened 2026-05-06-rollup.md → top finding 32 D9/day all on metric-failure-mode-rate.sh
Outcome: 1-line whitelist fix at drift-signals-D1-D9.sh:147; 6/6 firing-test PASS + 63/63 full regression PASS unchanged
S85 verification: post-fix firing at 15:21:27 had 0 D9 entries on that file (32→0 firings/day going forward)
ROI: ~5K main inline for permanent elimination of repeated HIGH-severity false-positive
```

**Where tracked**:
- This entry (L-S84-1)
- `agent-workspace/memory/sessions/2026-05-06-session-84.md` (root-cause + fix narrative)
- `agent-workspace/memory/sessions/2026-05-06-session-85.md` § Lessons codified (verification + codification turn)
- `agent-workspace/memory/checkpoints/latest.md` § Binding rules item 11

**Companion to L-S69-2**: deploy → surface → backfill pattern. Drift-rollup is the surfacing channel for harness gaps. L-S84-1 codifies "what to do when surfacing channel has signal but no committed track exists yet".

**Promotion candidate**: At S86+ if pattern recurs successfully → consider promoting to skill (`.claude/skills/drift-rollup-backlog-entry/SKILL.md`) at next promote-rule cycle.

### L-S85-1: MULTI_TASK_IMPL bundle preference for small-batch harness gap-fixing

**Date**: 2026-05-06 (insight surfaced + ratified mid-S85 via user-directive Option A "ok A")
**Origin**: User questioned at S85 whether main-session-only pattern across S81-S85 is structured or drift, and whether budget is healthy. Empirical analysis from `agent-workspace/memory/cost-ledger.tsv` + `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (as_of 2026-05-06T15:21:28+07:00):
- Small harness gap-fix sessions (FOCUSED_IMPL 1-3 tasks) overhead ratio ~55-65% (pre-flight reads + memory close + cache cold-start dominate productive output)
- S84 conv 9c48f51f delta 15:08:42→15:21:28: tokens_out +98299, cache_read +9.4M, cost +$24.25 for 1-line whitelist regex extension + 2-line comment refinement
- Self-track "5K main inline" measures productive output; actual tokens_out ~10-20× higher per AP-2 (transcript-tokens authoritative, not LLM self-track)
- 3 dependent serial harness fixes (S82+S83+S84) ≈ 3× pre-flight + 3× memory close vs bundling possible

**Why**: Small-batch FOCUSED_IMPL sessions dedicate ~55-65% of tokens to ritual/bootstrap, not deliverable. When backlog has multiple independent surgical fixes available, MULTI_TASK_IMPL amortizes the bootstrap+close cost across more output. Cost-per-fix drops from ~$24 → projected ~$5-10 per fix. ROI compounds across remaining harness gap-fix backlog.

**How to apply** (rule):
1. At SessionStart, after reading checkpoint + boot-summary + current-execution: scan today's drift-rollup AND backlog list (per L-S84-1)
2. Count actionable independent surgical fixes available
3. **If ≥4 independent fixes** + each fix is 1-10 LOC + each fix is deterministic-test verifiable + no architectural design space → declare session-type **MULTI_TASK_IMPL** (4-10 tasks bundled, 150-250K budget per session-budgets.md)
4. **If <4 fixes** OR ANY fix has architectural-design-space / charter-tier / sandwich-verifier-required risk → fall back to FOCUSED_IMPL (1-3 tasks, 100-150K) OR sandwich pattern
5. Single SessionStart pre-flight + single memory close ritual amortizes across more deliverable

**Trigger conditions** (apply rule):
- Backlog shape: ≥4 independent surgical fixes available in drift-rollup or backlog
- Each fix: 1-10 LOC, deterministic-test verifiable (firing test or grep-state check), no architectural design space
- Constitutional fit: MULTI_TASK_IMPL budget 150-250K tokens (sufficient headroom for 4-10 surgical fixes)

**Anti-trigger conditions** (DO NOT bundle):
- Any fix is charter-tier (requires AskUserQuestion gate per `full_autonomous_no_supervised.md`)
- Any fix has architectural design space (PLAN sandwich-architect required first)
- Any fix subjective enough to need sandwich-verifier (AP-1 same-agent self-review risk)
- Token estimate would exceed 250K (split into multiple MULTI_TASK_IMPL sessions)

**Severity**: MEDIUM (operational efficiency doctrine; user explicitly ratified at S85 mid-session via "ok A")
**Auto-detect**: NO — this is a session-type-selection heuristic. Could be auto-suggested at SessionStart if drift-rollup HIGH count ≥4 detected, but final decision still agent-judgment.

**Empirical baseline (pre-codification)**:
```
S82-S84: 3 sessions × ~5-13K main self-tracked + 3× pre-flight (~1.5K each = 4.5K) + 3× memory close (~1K each = 3K) ≈ 22-46K total + 3× cache cold-start
Hypothetical bundled: 1 MULTI_TASK_IMPL × 30-50K main + 1× pre-flight (~1.5K) + 1× memory close (~1.5K) ≈ 33-53K total + 1× cache cold-start
Ratio: ~40-60% cost reduction depending on tasks bundled
Cost-per-fix: from ~$24 (FOCUSED_IMPL singleton) → projected ~$5-10 (MULTI_TASK_IMPL bundled 4-6 tasks)
```

**Where tracked**:
- This entry (L-S85-1)
- `agent-workspace/memory/sessions/2026-05-06-session-85.md` § Lessons codified (extended after user-directive)
- `agent-workspace/memory/checkpoints/latest.md` § Binding rules item 12 (added post-directive)
- `agent-workspace/memory/cost-ledger.tsv` (empirical cost source; as_of 2026-05-06T15:21:28+07:00)

**Cross-references**:
- `agent-workspace/constitution/session-budgets.md` § Session Types + § Decision Tree Q2 — L-S85-1 activates the MULTI_TASK_IMPL branch more aggressively
- L-S84-1 (drift-rollup as canonical autonomous-backlog entry-point) — provides the multi-fix backlog source that triggers L-S85-1
- `harness_priority_one.md` user binding — harness optimization > product
- AP-2 transcript-tokens-authoritative — empirical baseline for cost measurement
- I-S1 NO LLM math — cost numbers cited from `cost-ledger.tsv` deterministic source
- I-S2 source-citation — cost-ledger as_of 2026-05-06T15:21:28+07:00

**Promotion candidate**: Observe at S86+ application. If 2-3 successful applications reduce cost-per-fix below $15 baseline → promote to skill (`.claude/skills/multi-task-bundle-when-backlog-rich/SKILL.md`) at next promote-rule cycle.

**Companion to L-S84-1**: L-S84-1 sources the backlog (drift-rollup); L-S85-1 chooses the session-type to drain it efficiently. Use together at S86+ entry.

### L-S87-1: Backlog-description structural claims require next-session empirical verification

**Date**: 2026-05-06 (codified at S88 after 3rd consecutive structural-claim correction; deferred at S87 per Lesson Codification Frugality at 2 instances)

**Origin**: 3 consecutive checkpoint-to-next-session structural-claim corrections:
- **S86 caught S85's** "14+ lessons missing from canonical agent-notes.md" — actual gap was 2 lessons + 1 mistake (~5x over-count)
- **S87 caught S86's** "L-S67-1..4 exist as inline sub-bullets within bigger L-S67-2 prose section" — actual reality was 4 properly separated `### sections` with old-format `### YYYY-MM-DD:` headers (different defect class entirely)
- **S88 caught S87's** "L-S65-1+L-S65-2 ID assignment is creative work needing sandwich-architect dispatch alongside renderer regex extension" — actual work was mechanical 2-LOC header rename identical to S87's own normalization pattern (IDs already obvious: L-S65-1 paired with M-S65-1 mistake at body cross-ref line 1394; L-S65-2 already canonically referenced at L-S67-3 lines 1523/1526/1534/1536)

**Why**: Checkpoint backlog descriptions of file structure (line counts, lesson IDs, task complexity, "creative vs mechanical" framing) tend to drift from actual file state across the predecessor→successor session boundary. Two compounding factors:
1. Predecessor session author drafts checkpoint backlog under "looks like" heuristic, often without re-reading the actual file region after intervening edits
2. Successor session, under autonomous-continue cadence, tends to consume backlog framing as ground truth (saves a few hundred tokens of re-verification) → inherits the drift

Without empirical re-verification at next-session entry, downstream sessions consume inaccurate framing → wrong session-type selection (e.g. "creative work" framing might trigger sandwich-architect dispatch when mechanical FOCUSED_IMPL inline edit suffices), wrong tooling choice, or wasted scope-discipline cycles.

**Rule**: Before consuming any prior-session checkpoint claim about file structure (line counts, lesson-ID gaps, "X file has Y entries", "Z task is creative/mechanical"), empirically grep/read the actual file region at next-session entry. Apply at SessionStart pre-flight AFTER current-execution.md / boot-summary.md / checkpoint reads, BEFORE consuming the checkpoint's "next action" framing.

**How to apply** (sequence at SessionStart pre-flight):
1. Read checkpoint backlog § "Next action when session resumes"
2. Identify backlog items framed by structural claims (regex hint: phrases like "lines X+Y", "≥N entries", "creative work", "mechanical", "sub-bullets", "missing N lessons", "small-batch", "needs sandwich-X dispatch")
3. For each such item: run targeted `grep -n` or `Read` on the cited file region (~0.5-1K main per audit; reading 50-100 lines is sufficient)
4. If empirical reality differs from checkpoint claim → re-frame the work in the S<N+1> session log § Outcome T0 ("S<N> backlog-description empirical audit")
5. Log the correction inline in S<N+1> session log + this lesson entry's running-tally if pattern persists

**Trigger conditions** (apply rule):
- Predecessor session checkpoint contains "Backlog for autonomous continuation" with structural claims
- Successor session SessionStart pre-flight is being executed (every session, not just when in doubt)
- Cost ceiling: ~1K main per audit (skip claims whose verification would exceed 1K main; instead trust + cite uncertainty in S<N+1> § Outcome)

**Anti-trigger conditions** (skip — rare):
- Checkpoint backlog item is non-structural (e.g. "consider X strategy" — opinion, not file-state claim)
- Successor session has already been forced into different track by user redirect or fresh USER-CRITICAL prompt

**Severity**: MEDIUM (preventable via systematic verification; doesn't affect production code; affects session-type selection + tooling choice + scope discipline)

**Auto-detect**: NO at L-S87-1 codification time — requires agent judgment at SessionStart pre-flight. Could become a hook script `scripts/hooks/checkpoint-backlog-claim-verifier.sh` (PostToolUse on SessionStart Read of checkpoints/latest.md → grep backlog § for structural-claim patterns + auto-emit "verify these N claims at file region X" notification). Defer hook codification per L-S69-2 (deploy → surface → backfill): codify L-S87-1 first; observe S89-S91 application; if manual-verification cost stays ≥0.5K main per session AND pattern persists → promote to hook at S92+.

**Where tracked**:
- This entry (L-S87-1)
- 3 consecutive sessions with empirical-correction outcomes:
  - `agent-workspace/memory/sessions/2026-05-06-session-86.md` § Discovery (S85→S86 over-count correction)
  - `agent-workspace/memory/sessions/2026-05-06-session-87.md` § Outcome T0 (S86→S87 mis-description correction)
  - `agent-workspace/memory/sessions/2026-05-06-session-88.md` § Outcome T0 (S87→S88 over-framing correction; codification turn)
- `agent-workspace/memory/checkpoints/latest.md` § Binding rules item 13 (NEW at S88; replaces emerging-pattern note carried inline at S86+S87 turns)

**Cross-references**:
- `verify_phase_before_next_phase.md` user binding (extended-S86 to backlog-count claims; extended-S87 to structural claims; L-S87-1 makes it self-codified rule rather than user-only directive)
- Charter Principle 8 — Calibration over confidence (verify, don't assume)
- L-S67-5 (run `git status --short` BEFORE authoring narrative) — same family of "verify before authoring" rules at predecessor-session checkpoint-write timing; L-S87-1 is the symmetric rule at successor-session checkpoint-read timing
- AP-2 (transcript-tokens authoritative, not LLM self-track) — same root-pattern: empirical verification mandatory over LLM "looks like" claims

**Promotion candidate**: At S92+ if manual-verification application persists ≥0.5K main per session → promote to hook (`scripts/hooks/checkpoint-backlog-claim-verifier.sh` PostToolUse on SessionStart Read of checkpoint). At S95+ if hook fires + catches ≥1 correction → consider charter-tier amendment to `agent-workspace/constitution/autonomous-protocol.md` § SessionStart pre-flight.

**Companion to `verify_phase_before_next_phase.md`**: User memory says "verify Phase-N DONE claims before authorizing Phase-(N+1) IMPL". L-S87-1 codifies the structural-claims subset of that rule self-referentially (agent verifying agent-checkpoint claims, not just agent verifying phase-DONE claims). Together they form a complete pre-consumption-verification regime at session boundaries.

### L-S90-1: Verification rule application creates self-tightening feedback loop

**Date**: 2026-05-06 (codified at S92 after 3rd consecutive clean L-S87-1 audit; deferred at S90+S91 per Lesson Codification Frugality at <3-instance threshold)

**Origin**: 3 consecutive clean L-S87-1 audits (S90+S91+S92) following 4 catches with magnitude-decreasing sequence:
- **S86 caught S85's** ~5x over-count
- **S87 caught S86's** categorical mis-description
- **S88 caught S87's** framing mis-classification
- **S89 caught S88's** ~1.27x soft LOC over-estimate (partial; below severity-HIGH)
- **S90→S91→S92** 3 consecutive ZERO-corrections caught
- Catch sequence magnitude: 5x → categorical → framing → 1.27x → 0 → 0 → 0 (monotonically converging to steady-state)

3 consecutive clean transitions:
- **S89→S90**: S89 self-corrected S88's `~1956 LOC` claim via wc-l verification at S89 close → S90 audit found S89's hard claims accurate ✓ (1st clean)
- **S90→S91**: S90 author wrote tightened claims (line anchors verified, no LOC speculation) → S91 audit found S90's hard claims accurate ✓ (2nd clean consecutive)
- **S91→S92**: S91 author maintained tightened-claim discipline → S92 audit found S91's hard claims accurate ✓ (3rd clean consecutive — codification turn)

**Why**: When successor session systematically applies a verification rule (e.g. L-S87-1) to predecessor session output, the predecessor session author internalizes the verification expectation and pre-emptively tightens claims at checkpoint-write time. This creates a self-reinforcing cycle: each successor verification round → predecessor pre-emptive tightening → fewer corrections needed → calibration converges toward 0-correction steady state.

The mechanism is NOT just "agent learns the rule" — it's "agent writes claims under awareness of impending verification". Functionally similar to test-driven development: knowing tests will run forces tighter API contracts; knowing structural-claim audits will run forces tighter structural-claim phrasing.

**Rule**: When introducing a new verification rule at a session boundary (SessionStart pre-flight, Stop hook, sandwich-verifier dispatch, etc.), expect 3 phases of cost evolution:
1. **Catch phase** (early sessions): rule fires + catches corrections; cost = audit + correction codification (~1-2K main per session)
2. **Tightening phase** (middle sessions): rule fires + catches diminishing magnitude corrections; predecessor session author begins internalizing
3. **Steady-state phase** (after ≥3 consecutive clean): rule fires + finds nothing; cost = bare verification (~0.3-0.5K main)

In steady-state phase, the rule's measured catch-rate ≠ its actual prevention-rate. The rule continues creating value via deterrent effect at predecessor-session checkpoint-write timing — even when no corrections are caught.

**How to apply** (when designing or evaluating verification rules):
1. After codifying a verification rule, track its catch sequence over ≥3 successor sessions
2. If catch sequence shows MAGNITUDE DECREASE (e.g. 5x → categorical → framing → 1.27x → 0 → 0), tag the rule as "self-tightening"
3. For self-tightening rules at steady state: do NOT promote to hook just because catches drop to 0. The 0-catch rate is evidence of WORKING deterrent, not evidence of redundancy
4. Reserve hook-promotion criteria for rules whose audit cost exceeds threshold (e.g. >1K main per session sustained) OR whose catch rate stays HIGH despite ≥5 successor sessions (i.e. predecessor author NOT internalizing — needs deterministic enforcement)
5. For self-tightening rules: continue rule-based application indefinitely; cost stays low; deterrent effect persists

**Trigger conditions** (apply this lesson when evaluating verification rules):
- A verification rule has been codified for ≥3 successor sessions
- Catch sequence shows decreasing magnitude OR decreasing frequency
- Cost per audit at steady state is ≤0.5K main

**Anti-trigger conditions** (skip — rule may not be self-tightening):
- Verification rule's catch rate stays high across many successor sessions (predecessor not internalizing)
- Per-audit cost is high (>1K main) — promote to deterministic hook regardless
- Catches show categorical drift rather than magnitude decrease (rule may be detecting NEW types of failures, not training predecessor on existing types)

**Severity**: LOW-MEDIUM (insight about HOW rules work, not WHAT to do; affects rule-promotion decisions, not session work itself)

**Auto-detect**: NO — requires multi-session pattern analysis. Could become observation in periodic promote-rule cycle (catalog rules by tightening pattern). Defer hook codification indefinitely; this is meta-rule, not enforcement-rule.

**Where tracked**:
- This entry (L-S90-1)
- 3 consecutive clean audit sessions:
  - `agent-workspace/memory/sessions/2026-05-06-session-90.md` § Outcome T1 (S89→S90 1st clean)
  - `agent-workspace/memory/sessions/2026-05-06-session-91.md` § Outcome T1 (S90→S91 2nd clean)
  - `agent-workspace/memory/sessions/2026-05-06-session-92.md` § Outcome T2 (S91→S92 3rd clean — codification turn)
- L-S87-1 at agent-notes.md line 1888 (the verification rule whose self-tightening pattern this lesson generalizes)

**Cross-references**:
- L-S87-1 (the verification rule whose application this lesson observes)
- L-S69-2 (deploy → surface → backfill pattern; L-S90-1 extends with "→ tighten → steady-state")
- Charter Principle 8 — Calibration over confidence (self-tightening is empirical calibration)
- AP-23 LLM-Guardian creep — counter-evidence: deterministic verification rules at session boundaries can converge to low-cost steady-state without becoming "always-on Guardian"; rule-based catches are NOT pre-execution Guardian polling

**Promotion candidate**: NOT typical hook promotion. Instead, codify as charter-tier doctrine at S95+ if pattern observed across ≥2 different verification rules (currently 1: L-S87-1). If 2nd rule (e.g. future verification rule) also shows self-tightening behavior, codify L-S90-1 to `agent-workspace/constitution/autonomous-protocol.md` § Verification rule lifecycle.

**Companion to L-S87-1**: L-S87-1 is the structural-claim verification rule that exhibits self-tightening; L-S90-1 is the meta-observation about why such rules don't need promotion based purely on catch-rate. Together they form a "deploy + measure" pair: L-S87-1 deploys; L-S90-1 measures.
