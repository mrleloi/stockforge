---
observation_id: 2026-05-05-S50-pre-dispatch-duplicate-rca
type: incident-rca
severity: medium
created_at: 2026-05-05T18:00:00+07:00
created_by: Claude Opus 4.7 (post-/clear session, S50-pre)
related_session_ids:
  - 5b96635e-a2c5-4533-b20d-3bd15af5600c  # prior session (dispatch fired)
  - current  # post-/clear session (re-dispatch attempted but interrupted)
related_tasks:
  - ac2775d9e37ca8e7e  # killed sandwich-verifier
related_dispatch_pending:
  - .dispatch-pending-5b96635e-a2c5-4533-b20d-3bd15af5600c.jsonl
incident_class: harness-gap + LLM-protocol-gap (multi-layer)
status: open
fix_layer: defense-in-depth (LLM discipline + checkpoint format + hook proposal)
user_directive: "update, note, fix, rồi mới được tiếp tục"
---

# Incident RCA — S50 sandwich-verifier dispatched twice across `/clear` boundary

## Timeline

| Time (2026-05-05) | Session | Event |
|---|---|---|
| ~17:35 | session 5b96635e | S49b IMPL turn started; archive sweep + harness diagnosis |
| ~17:50 | session 5b96635e | Checkpoint `latest.md` updated with `next_action = "S50 dispatch sandwich-verifier"`. Still in same turn. |
| ~17:52 | session 5b96635e | LLM dispatched sandwich-verifier (`tool_use_id=toolu_01JLqZBE23fMs1c814JDsCn2`); `dispatch-pending-*.jsonl` written `state=pending` |
| ~17:52 | session 5b96635e | Bash tier1 final check + summary "S50 sandwich-verifier dispatched in background" |
| ~17:53 | (boundary) | User typed `/new` (queued) — per user complaint: "/new đã tự động trên queue prompt sẵn, mà llm vẫn continue dispatch agent". Slash-command queue semantics did NOT interrupt the in-flight LLM turn |
| ~17:54 | session current | `/clear` actually fires (or `/new` resolved as `/clear`); fresh context begins; SessionStart hook injects autonomous-resume context |
| ~17:54-17:55 | session current | LLM (this session) reads checkpoint + executes pre-flight reads; checkpoint says `next_action = S50 dispatch sandwich-verifier`; LLM has NO signal that prior dispatch already happened |
| ~17:55 | session current | LLM creates 3 tasks via TaskCreate (Dispatch / Integrate / Write session-log); marks task #1 in_progress |
| ~17:56 | session current | User INTERRUPTS before Agent.dispatch fires for the second time — new dispatch never actually executed |
| ~18:00 | session current | Background subagent from session 5b96635e is KILLED (system-notification arrives). Output file `ac2775d9e37ca8e7e.output` is 0 bytes (no observation written). Last known stream content: "Excellent test coverage breadth. Now I have enough to write findings. Let me do one final quick sanity check — confirm `evaluate_outcome_review_use_case.py` calls UpdateKolCredibility on THREE_MONTH (per spec § B.3 UC-2)." |

**Net state at incident close**:
- Prior dispatch: KILLED before writing observation (0-byte output file)
- Current-session dispatch: NEVER FIRED (interrupted at TaskCreate stage; only task list scaffolding existed)
- No `2026-05-05-S50-bc-6-verifier-verdict.md` observation exists
- `dispatch-pending-5b96635e-*.jsonl` still has stale `state=pending` row (never reconciled)

## Reframing note (added 2026-05-05 post-user-feedback)

The original multi-layer framing below treated harness/format gaps as co-equal causes. **User pushback corrected the framing**: the PRIMARY bug is L1 (LLM-side over-execution past checkpoint-write boundary). User-supplied verbatim: "lỗi chính là tại sao lại action như vậy mà? đã note checkpoint rồi lại còn làm action khác như dispatch? phải end chờ '/new' chứ"

**Corrected ranking**:
- **PRIMARY**: L1 (LLM violated checkpoint-as-session-boundary contract). Codified as **L-S49b-4** in agent-notes (new entry, supersedes prior framing).
- **SECONDARY (mitigations / mechanism explanations, NOT equal-rank causes)**: L2 (harness slash-command queue + bootstrap doesn't read pending JSONL), L3 (LLM didn't run pre-dispatch check post-`/clear`).
- **UPSTREAM (not fixable from project)**: Claude Code v2.1.124 slash-command queue-vs-interrupt semantics.

**Why the reframe matters**: if the PRIMARY rule (checkpoint write = end turn) had been applied, NONE of the secondary failures would have manifested. The user-queued `/new` would have fired cleanly into a fresh session; the prior dispatch would never have been initiated; no killed subagent; no work loss; no re-dispatch attempt. The harness/format defenses are still useful as defense-in-depth, but they exist to catch failures of the PRIMARY rule, not to replace it.

The carve-out has been added to `~/memory/autonomous_continue_no_self_pause.md` so that the prior "continue, no self-pause" doctrine is no longer applied to checkpoint-write boundaries. Memory file Rule 1 originally said "after shipping a deliverable, immediately do the next-action listed" — LLM applied this generically; it should NOT apply when the deliverable is the checkpoint itself.

---

## Root cause (multi-layer — historical framing, retained for audit; superseded by Reframing above)

### L1 — LLM in PRIOR session (session 5b96635e) [PRIMARY per reframing]
**Failure**: Wrote checkpoint `next_action = "S50 dispatch sandwich-verifier"` BEFORE actually dispatching the subagent in the same turn. Then dispatched immediately after. Never updated the checkpoint to reflect the new state `dispatch IN-FLIGHT — wait for observation`.

**Reframed (post-user-feedback)**: The "wrote checkpoint before dispatching" framing is a SYMPTOM of the deeper bug. The deeper bug is "wrote checkpoint AND THEN continued doing actions in the same turn". The order (write-then-dispatch vs dispatch-then-write) is secondary; the violation is "any actions after checkpoint write within the same turn". Per L-S49b-4: checkpoint write = end turn, period.

**Why this is wrong**: Checkpoint's "next_action" is meant to be read by the NEXT session. By the time the NEXT session opens, the action HAS BEEN taken (or attempted). Stale `next_action` causes re-execution of already-done work.

**Correct sequencing**: dispatch FIRST → then write checkpoint with `in_flight_subagent_dispatch:` field reflecting the dispatch that just happened → then end turn.

### L2 — Harness layer (Claude Code v2.1.124)
**Failure A**: Slash-command queue-vs-interrupt semantics. User typed `/new` mid-turn expecting interrupt; harness queued it for end-of-turn. LLM continued executing pending tool calls (dispatch + bash + summary) for ~30+ seconds before `/clear` actually resolved. **Not fixable from project code** — upstream Claude Code behavior. Workaround: file as known-issue + LLM-side restraint at certain turn-boundaries.

**Failure B**: SessionStart bootstrap does not surface `dispatch-pending-*.jsonl` files from prior sessions. The current session's bootstrap reads `current-execution.md` + `checkpoints/latest.md` + `queued-grill-master.md` + autonomous-protocol — but NOT the `.dispatch-pending-<session_id>.jsonl` registry that already exists and tracks in-flight subagents. Result: LLM has no signal that a prior dispatch is still in-flight or recently killed.

**Failure C**: Background subagent lifecycle across `/clear` is opaque. Empirical observation this incident: agent SURVIVED `/clear` and continued running (positive signal — better than my earlier assumption). However, when killed (mechanism unclear — possibly idle timeout or harness cleanup triggered by my Bash queries), no observation was written and no notification fired in the new session until much later.

### L3 — LLM in CURRENT session (post-`/clear`)
**Failure**: Read checkpoint and prepared to re-dispatch sandwich-verifier without first checking:
1. `agent-workspace/memory/observations/` for any `*-S50-*` file
2. `agent-workspace/memory/.dispatch-pending-*.jsonl` for `state=pending` rows whose `parent_session_id` matches a recent session
3. `agent-workspace/memory/.session-hooks.log` for Stop+Subagent events

**This is the most actionable layer** — LLM-side discipline is the cheapest defense. `dispatch-pending-*.jsonl` files ALREADY EXIST in the repo as harness telemetry; LLM just doesn't read them at SessionStart.

## Fix plan (defense-in-depth)

### Fix-L1 (LLM doctrine — IMMEDIATE; codify in agent-notes)
**Rule**: When dispatching a background subagent, the LLM MUST:
1. **Dispatch first** (the Agent() call)
2. **Then write checkpoint** with `in_flight_subagent_dispatch:` field populated reflecting the just-dispatched task
3. **Then end turn**

Anti-pattern: write checkpoint with `next_action: dispatch X` then dispatch X in same turn. Either dispatch hasn't happened (checkpoint truthful but action incomplete) or has happened (checkpoint stale).

### Fix-L2 (LLM doctrine — IMMEDIATE; pre-dispatch check protocol)
**Rule**: Before dispatching ANY background subagent, run:
```bash
# Quick: is there already an observation for this work?
ls agent-workspace/memory/observations/ | grep -iE "<session_id>|<short-task-name>"

# Comprehensive: any in-flight dispatch tracked?
cat agent-workspace/memory/.dispatch-pending-*.jsonl 2>/dev/null | grep '"state":"pending"'
```

If matches found → INTEGRATE existing observation OR investigate in-flight state, NEVER blindly re-dispatch.

### Fix-L3 (Checkpoint format extension)
**Add field** to `checkpoints/latest.md` frontmatter or markdown body:
```yaml
in_flight_subagent_dispatch:
  - id: "S50-sandwich-verifier-2026-05-05T17-52"
    tool_use_id: toolu_01JLqZBE23fMs1c814JDsCn2
    parent_session_id: 5b96635e-a2c5-4533-b20d-3bd15af5600c
    dispatched_at: 2026-05-05T17:52:00+07:00
    expected_observation_path: "agent-workspace/memory/observations/2026-05-05-S50-bc-6-verifier-verdict.md"
    status: PENDING  # PENDING | OBSERVED | LOST | KILLED
    last_known_stream: "Excellent test coverage breadth. Now I have enough to write findings..."
```

Next session reads this field at SessionStart; if any entry has `status=PENDING` whose `dispatched_at` is >2hr old AND `expected_observation_path` does NOT exist on disk → mark `status=LOST` and decide re-dispatch or salvage.

### Fix-L4 (Hook proposal — DEFER until user ratify)
**New hook**: `scripts/hooks/in-flight-subagent-watcher.sh`
- Run on SessionStart (UserPromptSubmit chain or session-start-bootstrap)
- Reads all `agent-workspace/memory/.dispatch-pending-*.jsonl`
- For each `state=pending` row with `ts_ms` older than 2hr (configurable):
  - Check if `expected_observation_path` (from companion checkpoint field) exists
  - If yes → log `OBSERVED`, mark dispatch resolved
  - If no → log `LOST`, surface notification to LLM via `<system-reminder>` channel
- Output goes to `.session-hooks.log` for auditability

This requires:
- (a) the LLM-side discipline (Fix-L1/L2) to populate `expected_observation_path` consistently
- (b) hook script authoring (small ~30 LOC bash)
- (c) wiring in `.claude/settings.json` (1 line)

### Fix-L5 (Slash-command harness behavior — UPSTREAM)
- Not fixable from project code
- File as known-issue: KI-S50-pre-1 — Claude Code v2.1.124 queues mid-turn slash commands instead of interrupting
- Workaround: when user asks for "stop", check pending-buffer + halt remaining tool calls. Already partial via `Request interrupted by user` mechanism but inconsistent across slash-commands

## Lesson-synthesis triggers

This incident triggers Rule 4b (D-026) lesson-synthesis (a)+(b)+(d):
- (a) deferred-fix surfaced: in-flight registry not surfaced at SessionStart — KI-S49b-1 sibling defect
- (b) doctrine refinement: pre-dispatch check protocol added
- (d) harness-gap diagnosis: dispatch-pending-*.jsonl exists but unread by SessionStart bootstrap

→ M-S49b-2 + L-S49b-3 codified in mistake-log + agent-notes (this incident's fix-where-applied).

## Open follow-ups

1. **Re-dispatch decision for S50 VERIFY**: prior dispatch killed mid-investigation; observation NOT written. Options:
   - (A) Re-dispatch fresh sandwich-verifier with same brief (loses ~5-10 min of prior work but clean) — RECOMMENDED
   - (B) Try to salvage from temp output (already 0 bytes — INFEASIBLE)
   - (C) Defer S50 VERIFY; proceed to Track J/K and run consolidated VERIFY at S59 — MASTER-PLAN ALREADY PERMITS THIS for J/K, BC-9 (see § Sandwich Coverage); same precedent could absorb BC-6 if user explicitly approves
   - **Default**: (A) — wait for user OK, with tighter brief that includes "explicitly write observation file at <path> as final step before returning"
2. **Reconcile stale dispatch-pending row**: `5b96635e-*.jsonl` `state=pending` row needs to be marked `state=killed` or removed; current state misleads any future drift-check
3. **Author Fix-L4 hook**: defer to next maintenance turn unless user wants now
4. **File KI-S50-pre-1**: known-issue for slash-command queue semantics; non-blocking

## Provenance for any post-incident reader

- This RCA written in session BEFORE re-dispatching anything; user explicit instruction "update, note, fix, rồi mới được tiếp tục"
- Killed task notification: task-id `ac2775d9e37ca8e7e`, output-file 0 bytes
- Last known stream from killed agent (single sentence): "Excellent test coverage breadth. Now I have enough to write findings. Let me do one final quick sanity check — confirm `evaluate_outcome_review_use_case.py` calls UpdateKolCredibility on THREE_MONTH (per spec § B.3 UC-2)."
- Inferred verifier had completed: spec read + 149-test scan + UseCase read; was about to commit verdict

End of RCA.
