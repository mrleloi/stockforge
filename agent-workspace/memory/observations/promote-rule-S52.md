---
observation_id: promote-rule-S52
created_at: 2026-05-05
created_by: general-purpose subagent (Phase 3.5 T3.2 dispatch from S51 close; tool_use_id=aa453f3be2313a61a)
type: promote-rule-cycle
phase: 3.5
trigger: 14+ session backlog since last cycle promote-rule-S43c (2026-05-04); HH-C.4 promotion-cycle-trigger HARD-BLOCK confirmed firing post-fix (S51 T3.1 — grep pattern updated from `^\*\*Session N\*\*:` to `^## S[0-9]+`; firing-test 4/4 PASS)
predecessor: promote-rule-S43c.md (2026-05-04; 6 clusters / 19 candidate rules; 2 NEW HOOK + 1 charter proposal authored — all delivered S43c..S43f)
input_corpus:
  - agent-notes.md entries newer than L-S43f-2 (count: 14 distinct lessons; lines 375-814)
  - mistake-log.md entries since M-S45-1 (count: 11 entries; lines 21-723)
  - 25 entries in agent-notes.md tagged `Auto-detect: yes` (deterministic grep `^\*\*Auto-detect\*\*: yes`)
  - 56 hook scripts inventoried in scripts/hooks/ (1 firing-test in scripts/hooks/firing-tests/)
  - post-mortem 2026-05-05-phase-2.5-empirical-firing-gap.md (T1 deliverable; this dispatch's ground-truth corpus)
  - master-plan 010-S50-phase-3.5-harness-deepening (T3 explicitly targets this dispatch)
output_format: prioritized promotion proposal — hook FIRST per Q-E3 closed answer; ≥3 priority-1 hooks with REAL file-format detection specs (per L-S51-1 discipline) + companion firing-test strategy
read_method: |
  - Full-Read of post-mortem 2026-05-05-phase-2.5-empirical-firing-gap.md (285 lines)
  - Full-Read of master-plan 010-S50-phase-3.5-harness-deepening (444 lines)
  - Full-Read of promote-rule-S43c.md (162 lines, format reference)
  - agent-notes.md offset=300-814 chunked Reads (covers RECOVERY GAP marker through L-S51-1)
  - mistake-log.md offset=1-723 chunked Reads (full 30 M-S* entries)
  - scripts/hooks/promotion-cycle-trigger.sh full-Read (real grep-pattern format reference)
  - scripts/hooks/ Glob inventory (56 .sh files — duplicate-name check)
  - 25× `Auto-detect: yes` entries cross-referenced against shipped hook inventory
---

# Promote-rule cycle S52 — Phase 3.5 T3.2 dispatch

> **One-line takeaway**: Of 14 lessons accumulated since S43c (delta=7 sessions; phase 2→3.5 crossed = HARD-BLOCK condition), 6 distinct clusters emerge. Top recommendation: ship 5 priority-1 hooks (3 strict-doctrine HARD-BLOCKs + 2 detection-instrument SOFT-WARNs), all with REAL file-format detection specs + companion firing-tests per L-S51-1 discipline. 1 priority-2 skill (post-clear-resume routine for in-flight dispatch reconciliation). 1 priority-3 charter candidate (L-S49b-4 codification — already targeted by Phase 3.5 T4 + T8). All proposals respect Q-E3 hook-first cadence.

---

## Input corpus inventory

| Source | Total entries | Newer than baseline | Auto-detect: yes | Already has shipped hook |
|---|---|---|---|---|
| agent-notes.md | 56+ rule headers (full file) | 14 lessons (L-S44-1 through L-S51-1) | 25 (deterministic grep `^\*\*Auto-detect\*\*: yes` count) | ~18 of 25 (cross-ref scripts/hooks/ Glob inventory) |
| mistake-log.md | 30 M-S* entries (724 lines) | 11 entries (M-S45-1 through M-S51-1) | (n/a — mistake-log uses `Auto-detect signature:` not `Auto-detect:`) | ~6 of 11 already mitigated via shipped hook |
| `scripts/hooks/firing-tests/` | 1 firing-test (`promotion-cycle-trigger-fire-test.sh`) | n/a | n/a | 1/56 hooks have companion firing-test (1.7% coverage — confirms L-S51-1 systemic gap) |

**Baseline marker**: L-S43f-2 (companion to L-S43f-1; cited in L-S44-1 + L-S46-2 provenance lines as predecessor anchor). Per the brief, "everything authored AFTER 2026-05-04 21:29 when last `promote-rule-S43c.md` ran" qualifies for clustering.

**Empirical session-delta**: latest_session=51 (S51 T3.2 dispatch authoring this observation) − last_promote=S43 = 7. PHASE_CHANGED=1 (Phase 2 at S43 → Phase 3.5 by S50 master-plan). Hook condition `(SESSION_DELTA ≥ 8) || (PHASE_CHANGED ∧ SESSION_DELTA ≥ 1)` evaluates `(false || true) = true` → HARD-BLOCK fires correctly post-S51 fix. **This dispatch is the cycle the fixed hook escalated.**

---

## Cluster analysis

### Cluster 1: Append-mostly file Write→Edit substrate protection — ALREADY-APPLIED (HARD-BLOCK SHIPPED) + PROPOSED EXTENSION

**Member entries** (≥3): L-S45-1, L-S45-2, M-S45-1, M-S45-2 (cross-cited), L-S49a-1 audit doctrine

**Common pattern**: Substrate files under `agent-workspace/memory/{agent-notes,project,decisions,observations,sessions,checkpoints,mistake-log}.md` + `agent-workspace/{constitution,session-plans,proposals}/**/*.md` are append-mostly. The `Write` tool overwrites; the `Edit` tool surgical-replaces. Tool-level Read-before-Write blocker DOES NOT FIRE if file was Read at any offset earlier in session — partial reads bypass the safety. Result: M-S45-1 destroyed ~140 LOC of agent-notes.md (lines 315..454 unrecoverable) when sandwich-architect called `Write` on agent-notes thinking they were appending.

**Detection mechanism**: PreToolUse hook intercepts `Write` events; if `tool_input.file_path` matches protected-paths regex AND file already exists on disk → HARD-BLOCK with stderr explanation pointing to L-S45-2.

**Status**: ✅ ALREADY-APPLIED — `scripts/hooks/write-vs-edit-guard.sh` (3524 bytes) shipped 2026-05-05 07:57 same-turn as the M-S45-1 incident; wired in `.claude/settings.json` PreToolUse chain; 4/4 smoke-test green per M-S45-1 § Where applied.

**Proposed extension** (this cycle adds): companion firing-test `scripts/hooks/firing-tests/write-vs-edit-guard-fire-test.sh` per Phase 3.5 Hard Rule #2 + L-S51-1 discipline. The hook has been live for ~12 hours with 0 visible blocks (no agents have tried to Write to protected paths post-deploy) — without firing-test we cannot DEMONSTRATE it works on real telemetry shape. Real session-data shape: PreToolUse JSON envelope with `tool_input.file_path` field.

**Promotion target priority**: priority-1 hook (already ✅) + priority-1 firing-test (NEW this cycle).

**Cheapest-first justification**: hook tier is the only level that can mechanically prevent the failure mode (LLM-judgment-tier guidance has already been violated 3+ times per L-S44-1 / M-S45-2 / M-S47-1 self-pause family — same pattern of "doctrine without enforcement gets violated"). Skill or charter would not block the destructive call.

---

### Cluster 2: Checkpoint-write IS session-boundary marker — PARTIAL-APPLIED + STRICT-MODE PROMOTION CANDIDATE

**Member entries** (≥3): L-S49b-3, L-S49b-4, M-S49b-2 (REFRAMED PRIMARY root cause)

**Common pattern**: Writing/Editing `agent-workspace/memory/checkpoints/latest.md` is the session-boundary contract. The `next_action` field in the checkpoint is meant to be read by the NEXT session in fresh-context handoff — NOT executed by the current turn. M-S49b-2 incident: prior session 5b96635e wrote checkpoint with `next_action: dispatch sandwich-verifier`, then dispatched sandwich-verifier in same turn, then ran Bash tier1 final-check, then wrote summary. User had typed `/new` mid-turn; v2.1.124 queued the slash command; LLM ignored the queue. New session opened with stale checkpoint; almost re-dispatched. Background agent killed mid-investigation; observation lost.

**Detection mechanism**: PostToolUse hook gates on Edit/Write to `checkpoints/latest.md`; emits marker file `agent-workspace/memory/.checkpoint-written-<session_id>` with timestamp; companion watchdog checks subsequent tool calls within same session — if Edit/Write/Agent/Bash fires AFTER marker, emit drift-signal severity HIGH "L-S49b-4 carve-out violated".

**Status**: ⚠️ PARTIAL-APPLIED — `scripts/hooks/checkpoint-write-end-turn-watchdog.sh` (3923 bytes; 2026-05-05 18:17) + `scripts/hooks/checkpoint-write-marker.sh` + `scripts/hooks/checkpoint-marker-cleanup-resume.sh` ALL EXIST in scripts/hooks/ Glob (cross-ref Phase 3.5 plan 010 § T4.2). Wiring status uncertain (T4 has not yet ratified per master-plan 010 status line — would need `.claude/settings.json` cross-check). Phase 3.5 master-plan T4 explicitly targets ratification + AskUserQuestion gate.

**Proposed promotion priority**: priority-3 charter — but Phase 3.5 plan 010 T4 + T8 ALREADY captures this work. **This cycle's contribution**: surface that this cluster is mature for charter ratification (Phase 3.5 T4 timing), and propose a firing-test that synthesizes the M-S49b-2 violation pattern (write checkpoint → 3 follow-up tool calls → assert hook emits violation marker). Real file-format detection: `.session-hooks.log` line pattern `PostToolUse session=<id> tool=Edit file=.../checkpoints/latest.md` + subsequent line `PostToolUse session=<id> tool=Bash` within same session.

**Cheapest-first justification**: HOOK exists (good defense-in-depth); CHARTER promote needed because pattern is identity-shaping (defines fresh-context-handoff contract). Per Q-E3 closed cadence: hook FIRST (done), then charter-LAST (Phase 3.5 T4/T8 schedule).

---

### Cluster 3: Dispatch state inference — pre-dispatch in-flight check + post-/clear artifact verify (NEW HOOK CANDIDATE)

**Member entries** (≥3): L-S45-1 (pre-staged file VBW), L-S46-2 (post-/clear TaskList loss), L-S49b-3 (background-subagent dispatch sequencing), M-S49b-2 (REFRAMED — secondary observation S1 + S2)

**Common pattern**: Indirect signals (TaskList state, /clear effects, stale checkpoint `next_action`) lead LLM to infer wrong dispatch state and re-execute completed work. Three sub-patterns:
1. Pre-staged file artifact: prior dispatch shipped already; new dispatch fires and Glob misses → LLM thinks file absent → attempts Write → near-miss data loss (L-S45-1).
2. Post-/clear TaskList loss: empty TaskList misread as "dispatch killed"; redundant re-dispatch burns ~150K tokens (L-S46-2).
3. Stale checkpoint next_action: post-/clear LLM reads `next_action` and prepares re-dispatch unaware of in-flight state (M-S49b-2 secondary).

**Detection mechanism**: SessionStart hook scans (a) `current-execution.md` for "IN-PROGRESS" rows older than 1hr → cross-checks with expected session log via Glob; if log exists, emit ALERT "may already be COMPLETE; verify before re-dispatch"; (b) `agent-workspace/memory/.dispatch-pending-*.jsonl` for `state=pending` rows older than 2hr → cross-checks with expected observation file path; if absent + age > 2hr, emit ALERT "stale pending dispatch — verify before any new dispatch"; (c) `agent-workspace/{memory/decisions,session-plans/pending}/` for files created within last 24h matching active-session-id (pre-staged artifacts).

**Status**: 🔴 NO SHIPPED HOOK — closest existing hook is `dispatch-jsonl-recorder.sh` (records dispatches but doesn't surveil stale entries). L-S49b-3 explicitly proposes `scripts/hooks/in-flight-subagent-watcher.sh` as deferred Fix-L4. M-S49b-2 § Prevention Rules SECONDARY also lists this hook.

**Proposed promotion**: priority-1 NEW HOOK — `scripts/hooks/in-flight-subagent-watcher.sh` (UserPromptSubmit + SessionStart hook).

**Hook design**:
- **Trigger event**: UserPromptSubmit (cheap surveillance every prompt) + SessionStart (resume/clear chain)
- **Real file format hook detects against**:
  - `agent-workspace/memory/.dispatch-pending-S<NN>-current.jsonl` — sample format from current checkpoint:
    ```json
    {"state":"pending","tool_use_id":"toolu_01JLqZBE...","ts_ms":1714940000000,"parent_session_id":"5b96635e-..."}
    ```
  - `agent-workspace/memory/observations/promote-rule-S*.md` — observation Glob target
  - `agent-workspace/memory/checkpoints/latest.md` — read `in_flight_subagent_dispatch:` YAML block
- **Detection script** (~50 LOC bash, POSIX per L-S11-1):
  ```bash
  set -uo pipefail
  trap 'exit 0' ERR
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
  PENDING_GLOB="$PROJECT_DIR/agent-workspace/memory/.dispatch-pending-*.jsonl"
  OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
  NOW_S=$(date +%s)
  AGE_THRESHOLD_S=7200  # 2 hours
  STALE_COUNT=0
  for f in $PENDING_GLOB; do
    [ -f "$f" ] || continue
    while IFS= read -r line; do
      state=$(echo "$line" | grep -oE '"state":"[a-z]+"' | head -1 | sed 's/.*"state":"//;s/"//' || echo "")
      [ "$state" = "pending" ] || continue
      ts_ms=$(echo "$line" | grep -oE '"ts_ms":[0-9]+' | head -1 | sed 's/.*://' || echo 0)
      ts_s=$((ts_ms / 1000))
      age_s=$((NOW_S - ts_s))
      [ "$age_s" -lt "$AGE_THRESHOLD_S" ] && continue
      expected=$(echo "$line" | grep -oE '"expected_observation_path":"[^"]+"' | head -1 | sed 's/.*://;s/"//g' || echo "")
      [ -n "$expected" ] && [ -f "$PROJECT_DIR/$expected" ] && continue  # observation arrived
      STALE_COUNT=$((STALE_COUNT + 1))
      printf 'STALE PENDING DISPATCH: ts_age=%ss expected=%s\n' "$age_s" "$expected" >&2
    done < "$f"
  done
  [ "$STALE_COUNT" -gt 0 ] && \
    echo "in-flight-subagent-watcher: $STALE_COUNT stale pending dispatch(es) — verify state before any new Agent.dispatch" >&2
  exit 0
  ```
- **Companion firing-test strategy**: synthesize 3 inputs:
  1. `.dispatch-pending-test1.jsonl` with `state=pending`, `ts_ms` = (now - 10000) ms (fresh) → assert NO alert
  2. `.dispatch-pending-test2.jsonl` with `state=pending`, `ts_ms` = (now - 8000000) ms (stale, >2hr), `expected_observation_path` = nonexistent file → assert ALERT fires
  3. `.dispatch-pending-test3.jsonl` with same stale ts but `expected_observation_path` = existing file → assert NO alert (observation arrived)
- **Severity emitted**: medium (advisory; LLM checks before next dispatch).

**Cheapest-first justification**: HOOK is the right level — pattern is mechanically detectable via JSONL parse + file existence. SKILL would burn LLM cost on trivial check every prompt. Charter would over-codify a defense-in-depth tool.

---

### Cluster 4: Self-pause / Mode-E recurrence detector incompleteness — ALREADY-APPLIED HOOK + REGEX EXTENSION CANDIDATE

**Member entries** (≥3): L-S44-1 (initial — Holding here / next session's job), M-S45-2 (1st miss — wait for your call), M-S47-1 (2nd miss — Next 'continue' enters Sxx)

**Common pattern**: Self-pause family. LLM ends turn with phrasing that defers next action to user/next-session/Stop-hook even in autonomous-full mode. Detector regex in `scripts/hooks/autonomous-stop-watchdog.sh` evolves reactively — each new sub-pattern slips past prior regex; M-S45-2 added "wait for your" / "deferring to" / "standing by"; M-S47-1 added 4 routing-branch alternations ("Next continue enters/triggers/fires"). **3 recurrences post-detector-deployed** — Q-E3 promotion cadence threshold for Hook-extended-twice → next escalation is Skill or Charter at 4th recurrence.

**Detection mechanism**: post-Stop hook scans last assistant text via `LAST_TAIL` against SELF_PAUSE_HIT regex; emits `.autonomous-self-pause-alert.log` with session_id + tokens.

**Status**: ✅ ALREADY-APPLIED — `scripts/hooks/autonomous-stop-watchdog.sh` § 3 + § 4b regex extended at S44 + S45 + S47. ⚠️ Per post-mortem 2026-05-05 § HH-D table: HH-D Mode-E detector reports "0 firings of any 'mode-e' or 'self-pause' or 'defection' detector in `.session-hooks.log` last 7 days" — i.e., either the detector is genuinely catching all phrasings (no recurrences) OR the detector trace channel is opaque.

**Proposed promotion**: priority-1 — RETROFIT firing-test for `autonomous-stop-watchdog.sh` per L-S51-1 discipline. The detector has been extended 3 times and we have NO firing-test that synthesizes the 7+ known self-pause phrasings + 4+ control phrasings (per M-S47-1 smoke-test "5/5 self-pause caught + 4/4 controls skipped"). Without firing-test, we cannot DEMONSTRATE the regex still catches all 3 sub-pattern families.

**Hook design** (firing-test, not new hook):
- **Trigger event**: manual-invoke for CI; smoke-tested at hook-edit time
- **Real file format**: `LAST_TAIL` extracted from `transcript_path` JSON; sample line patterns:
  - Mode-E hits (must trigger): `Holding here. Stop hook + Mode-D handles.`, `wait for your call`, `Next 'continue' enters S52`, `S{N+1} entry is the next session's job`, `standing by`, `deferring to you`
  - Controls (must NOT trigger): `If you continue with this approach`, `Will continue running tests`, `wait for build to finish`, `Phase 3 next session = S46`
- **Detection script** (~80 LOC):
  ```bash
  #!/usr/bin/env bash
  # autonomous-stop-watchdog-fire-test.sh
  set -uo pipefail
  HOOK="scripts/hooks/autonomous-stop-watchdog.sh"
  cases_pause=("Holding here. Stop hook handles." "I'll wait for your call." \
               "Next 'continue' enters S52." "deferring to you" "standing by" \
               "S52 entry is the next session's job" "wait for fresh session")
  cases_ok=("If you continue with this approach" "Will continue running tests" \
            "wait for build to finish" "Phase 3 next session = S46")
  PASS=0; FAIL=0
  for phrase in "${cases_pause[@]}"; do
    out=$(echo "$phrase" | bash "$HOOK" 2>&1 || true)
    if echo "$out" | grep -q "self-pause\|SELF_PAUSE\|Mode-E"; then
      PASS=$((PASS+1))
    else
      FAIL=$((FAIL+1))
      printf "FAIL pause case: %s\n" "$phrase"
    fi
  done
  for phrase in "${cases_ok[@]}"; do
    out=$(echo "$phrase" | bash "$HOOK" 2>&1 || true)
    if echo "$out" | grep -q "self-pause\|SELF_PAUSE\|Mode-E"; then
      FAIL=$((FAIL+1))
      printf "FAIL false-positive: %s\n" "$phrase"
    else
      PASS=$((PASS+1))
    fi
  done
  printf "Total: PASS=%d FAIL=%d\n" "$PASS" "$FAIL"
  [ "$FAIL" -eq 0 ] && exit 0 || exit 1
  ```
- **Severity emitted**: HIGH if any pause case slips past regex; LOW if any control case false-positives.

**Cheapest-first justification**: hook tier already extended 3 times (= mechanical layer). Skill-tier would be appropriate if 4th recurrence happens AND new failure mode is fundamentally different from regex (e.g., contextual judgment about whether phrase is autonomous-defection). Charter-tier would re-codify autonomous_continue_no_self_pause memory rule as project-binding — pending if 4th recurrence forces it.

---

### Cluster 5: Hook-firing empirical gap (NEW PROPOSAL — META-RULE) — PRIORITY-1 NEW HOOK

**Member entries** (≥3): L-S51-1 (empirical-firing discipline), M-S51-1 (HH-C.4 grep pattern mismatch — fires but silently broken), L-S49b-2 (harness diagnosis playbook — when hooks "don't seem to fire") + post-mortem 2026-05-05-phase-2.5-empirical-firing-gap.md gap classes (a)/(b)/(c)/(d)

**Common pattern**: Hooks may be wired + bash-syntax-clean + smoke-passing AND STILL be silently broken at the empirical-firing layer. Post-mortem identifies 4 gap classes:
- (a) hook never fires on real session events (HH-A.4 qa-pending-auto-mover, HH-D Mode-E, HH-E.1, HH-E.3)
- (b) hook fires but emits no auditable trace (HH-A.1 vendor-api-probe, HH-C.1 session-end-checklist-linter, HH-C.2 project-md-staleness-check)
- (c) hook fires + traces but no aggregator surfaces (HH-B.2, HH-B.3)
- (d) hook fires correctly but covered scope ≠ declared scope — **SMOKING GUN class** (HH-C.4 promotion-cycle-trigger; just fixed S51 T3.1)

**Detection mechanism**: SessionStart hook (or Stop-aggregator) scans `.session-hooks.log` for hook-name entries last 7 days; for each declared-active hook in `.claude/settings.json`, computes (a) firing-count last 7d, (b) escalation-events count, (c) last-fire-mtime; emits FAIL if firing-count = 0 for 3+ consecutive sessions OR escalation-rate < expected (e.g. promotion-cycle-trigger should escalate ≥1× per 8-session-delta cycle).

**Status**: 🔴 NO SHIPPED HOOK — Phase 3.5 master-plan 010 T6 explicitly targets `harness-health-self-scan.sh` as the deliverable (signals HH-1..HH-12 codified at T5 first). T3.5 of plan 010 says "Author each priority-1 hook + companion firing-test" — this cluster's proposal is a candidate for that scope.

**Proposed promotion**: priority-1 NEW HOOK — `scripts/hooks/hook-firing-counter.sh` (UserPromptSubmit hook; lightweight precursor to T6's full harness-health-self-scan).

**Hook design**:
- **Trigger event**: UserPromptSubmit (high-frequency cheap check; output via `<system-reminder>` channel)
- **Real file format hook detects against**:
  - `agent-workspace/memory/.session-hooks.log` — sample lines (verified via post-mortem grep):
    ```
    [2026-05-05T18:48:20+07:00] watchdog tokens=...
    [2026-05-05T19:03:58+07:00] SessionStart session=...
    [2026-05-05T19:12:38+07:00] Stop session=...
    [2026-05-05T19:13:00+07:00] PostToolUse session=...
    ```
  - `.claude/settings.json` — JSON with `hooks: { Stop: [...], UserPromptSubmit: [...], SessionStart: [...], PostToolUse: [...], PreToolUse: [...] }` chains; each chain entry has `hooks: [{ command: "bash scripts/hooks/<hook-name>.sh" }]` shape
  - `.promotion-cycle.log`, `.autonomous-stop-watchdog.log`, `.autonomous-self-pause-alert.log`, etc. — per-hook log files
- **Detection script** (~70 LOC):
  ```bash
  set -uo pipefail
  trap 'exit 0' ERR
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
  HOOKS_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
  SETTINGS="$PROJECT_DIR/.claude/settings.json"
  [ -f "$HOOKS_LOG" ] || exit 0
  [ -f "$SETTINGS" ] || exit 0
  # Extract declared hook names from settings.json (cheap-first: prefer python if available; else grep)
  declared=$(python -c "import json,sys; d=json.load(open('$SETTINGS')); chains=d.get('hooks',{}); names=set(); 
  for c in chains.values():
    for entry in c:
      for h in entry.get('hooks',[]):
        cmd=h.get('command','');
        for tok in cmd.split():
          if tok.endswith('.sh'): names.add(tok.split('/')[-1])
  print('\n'.join(sorted(names)))" 2>/dev/null || true)
  [ -z "$declared" ] && exit 0
  # 7-day window
  cutoff=$(date -d '7 days ago' +%s 2>/dev/null || date -v-7d +%s 2>/dev/null || echo 0)
  silent_count=0
  for hook_name in $declared; do
    # Map to per-hook log file IF exists; else search session-hooks.log for hook-emitted patterns
    log_file="$PROJECT_DIR/agent-workspace/memory/.${hook_name%.sh}.log"
    if [ -f "$log_file" ]; then
      mtime=$(stat -c '%Y' "$log_file" 2>/dev/null || stat -f '%m' "$log_file" 2>/dev/null || echo 0)
      [ "$mtime" -gt "$cutoff" ] && continue
    fi
    # Also check session-hooks.log for hook-name mention
    hits=$(grep -c "$hook_name" "$HOOKS_LOG" 2>/dev/null || echo 0)
    [ "$hits" -gt 0 ] && continue
    silent_count=$((silent_count + 1))
    printf 'SILENT-HOOK: %s — 0 firings in last 7 days\n' "$hook_name" >&2
  done
  [ "$silent_count" -gt 0 ] && \
    echo "hook-firing-counter: $silent_count declared hook(s) have 0 firings in last 7d — investigate per L-S49b-2 5-step playbook" >&2
  exit 0
  ```
- **Companion firing-test strategy**:
  1. Synthesize `.session-hooks.log` with 3 entries for hook-A + 0 entries for hook-B + 0 entries for hook-C (no log file)
  2. Synthesize `.claude/settings.json` declaring all 3 hooks
  3. Assert hook-firing-counter emits "SILENT-HOOK: hook-B" + "SILENT-HOOK: hook-C" (2 silent hooks counted)
  4. Negative case: when ALL 3 hooks have ≥1 fire in log → assert NO alert
- **Severity emitted**: medium (informational counter; T6 self-scan in plan 010 will add structured FAIL/PASS aggregation later)

**Cheapest-first justification**: HOOK is correct level — pattern is mechanically detectable via grep + JSON parse. SKILL would not give continuous surveillance (only on-demand). CHARTER (Principle 11 in T8) is targeted but operates at audit/policy level — daily-firing detection still needs a hook. **This hook is the precursor to T6's `harness-health-self-scan.sh`** (plan 010 T5 + T6); shipping a minimal version this cycle gives faster feedback while T5 protocol gets ratified.

---

### Cluster 6: Bash-hook authoring traps + grep-pattern-on-imagined-format anti-pattern (NEW HOOK CANDIDATE)

**Member entries** (≥3): L-S51-1 (empirical-firing — root cause is grep-on-imagined-format), M-S51-1 (HH-C.4 grep pattern bug), L-S48d-1 (pipefail + grep-no-match silent fail), L-S48m-1 (CLAUDE_SESSION_ID env var empty on Windows — silent skip), M-S48d-1 (same as L-S48d-1 source), L-S43b-9 + L-S11-1 (referenced via S43c carry-over: bash printf, POSIX portability)

**Common pattern**: Bash hook authors write detection logic against an IMAGINED file format instead of doing VBW protocol read of real format. Symptoms:
1. Grep pattern never matches (M-S51-1: `^\*\*Session N\*\*:` literal vs real `## S50 — ...` header)
2. Marker uses `$CLAUDE_SESSION_ID` which is empty on Windows → silent skip (L-S48m-1)
3. `set -uo pipefail` + `trap 'exit 0' ERR` + optional grep that legitimately matches nothing → ERR trap fires silently → script exits 0 → no log entry → invisible failure (L-S48d-1 / M-S48d-1)
4. `printf '-'` without `--` sentinel → printf treats hyphen-string as flag (L-S43b-9 from S43c carry-over)
5. `head -1` of unscoped grep returns wrong element (L-S11-1 / L-S43b-9 family)

**Detection mechanism**: PreCommit/PreToolUse hook OR scheduled lint scans `scripts/hooks/*.sh` for known anti-patterns:
- pattern A (M-S51-1): `grep .* '\^\*\*Session N\*\*:'` literal — flag for review (file format check needed)
- pattern B (L-S48m-1): `\$\{?CLAUDE_SESSION_ID:?-default\}?` in marker name — flag (use session-log basename per L-S48m-1)
- pattern C (L-S48d-1): `set -.*pipefail.*` AND `trap '.*' ERR` AND `grep ` without surrounding `|| true` or `set +o pipefail` brackets — flag
- pattern D (L-S43b-9): `printf '-` or `printf "-` without preceding `--` sentinel — flag
- pattern E (L-S11-1): `grep -oE.* | head -1` over multi-element source — flag with severity LOW

**Status**: ⚠️ PARTIAL — `scripts/hooks/bash-hook-lint.sh` shipped per S43c S43c-C5 (printf `--` sentinel + head -1 sentinel checks per S43c § 110); needs extension for patterns A + B + C added this cycle.

**Proposed promotion**: priority-1 — extend existing `scripts/hooks/bash-hook-lint.sh` with 3 new pattern checks (A + B + C). Estimated +30 LOC.

**Hook design**:
- **Trigger event**: SessionStart (or weekly cron via SessionStart frequency rate-limit)
- **Real file format hook detects against**: `scripts/hooks/*.sh` — sample real lines from inspected scripts:
  - Pattern A example (just-fixed in `promotion-cycle-trigger.sh:L23` pre-fix): `grep -E '^\*\*Session N\*\*:' "$EXEC_FILE"` ← fixed S51 T3.1
  - Pattern B example (`profile-template-auto-populate.sh` pre-S48m fix): `MARKER="${MARKER_DIR}/.profile-template-fired-${CLAUDE_SESSION_ID:-default}"` ← fixed S48m
  - Pattern C example (`profile-template-auto-populate.sh` pre-S48d fix): `set -uo pipefail; trap 'exit 0' ERR; ... grep -m1 -E '^agent:' "$LATEST_SESSION" | grep -oE 'claude-(opus|...)'` (no `|| true`) ← fixed S48d
- **Detection script** (~30 LOC ADD to existing bash-hook-lint.sh):
  ```bash
  # === pattern A: grep on imagined format (M-S51-1) ===
  for sh in scripts/hooks/*.sh; do
    if grep -nE 'grep .* '\''\^\*\*Session N' "$sh" >/dev/null; then
      printf '[A] %s: literal **Session N** grep — verify against real current-execution.md format\n' "$sh"
    fi
  done
  # === pattern B: CLAUDE_SESSION_ID marker (L-S48m-1) ===
  for sh in scripts/hooks/*.sh; do
    if grep -nE '\.\w+-fired-\$\{?CLAUDE_SESSION_ID' "$sh" >/dev/null; then
      printf '[B] %s: marker uses $CLAUDE_SESSION_ID (empty on Windows; L-S48m-1)\n' "$sh"
    fi
  done
  # === pattern C: pipefail + ERR trap + bare grep (L-S48d-1) ===
  for sh in scripts/hooks/*.sh; do
    if grep -lE 'set [^#]*pipefail' "$sh" >/dev/null && \
       grep -lE "trap '[^']*' ERR" "$sh" >/dev/null; then
      # check for bare `grep` not followed by `|| true` or wrapped in `{ ... || true; }`
      if grep -nE '^\s+grep [^|]*$' "$sh" >/dev/null; then
        printf '[C] %s: pipefail + ERR trap + bare grep — wrap with || true (L-S48d-1)\n' "$sh"
      fi
    fi
  done
  ```
- **Companion firing-test strategy**: stage 3 synthetic hook scripts in temp dir — one with pattern A, one with pattern B, one with pattern C; assert lint emits 3 distinct flags. Negative case: 1 clean script → assert 0 flags.
- **Severity emitted**: medium (warn — author-time discipline, not runtime block)

**Cheapest-first justification**: HOOK extension is +30 LOC vs new hook +60 LOC. Existing `bash-hook-lint.sh` is a natural home (already lints printf + head -1 patterns).

---

## Auto-detect-tagged entries audit

Cross-reference: `agent-workspace/memory/agent-notes.md` entries marked `Auto-detect: yes` against shipped hooks in `scripts/hooks/`. Per L-S51-1 + L-S49b-2 discipline: tagged entries WITHOUT companion shipped hook are priority-1 promotion candidates.

| Entry | Auto-detect tag | Has companion shipped hook? | Has firing-test? | Recommendation |
|---|---|---|---|---|
| 2026-04-23 LLM Never Outputs Numbers | yes | partial (post-tool-citation-grep.sh) | no | priority-1 firing-test (M-LLM math regex catch) |
| 2026-04-23 Bear Case Required for Every Thesis | yes | no | no | DEFER — Phase 3 thesis cycle dependency |
| 2026-04-29 Q&A Bundle defer_cycle Field | yes | yes (qa-pending-stale-mover.sh) | no | priority-1 firing-test |
| 2026-04-29 "ok rồi. continue" idiom | yes | yes (lite-detect whitelist via user-prompt-intake skill) | n/a | already-applied |
| 2026-04-29 (post-audit) AP-S2-3 measurable properties | yes | yes (ghost-work-audit.sh + correction-rate-tracker.sh) | no | priority-2 firing-test |
| 2026-04-29 (post-audit) Charter-Tier No Default Bundles | yes | yes (proposal-bundle-advisor.sh) | no | priority-1 firing-test |
| 2026-04-29 (UP-06) NO Silent File-Defaults | yes | yes (qa-answered-detector.sh + qa-pending-auto-mover.sh) | no | priority-1 firing-test (E.3 0-firings per post-mortem!) |
| 2026-04-29 (UP-05) AskUserQuestion 4-Q Limit | yes | n/a (runtime-enforced by Anthropic) | n/a | already-applied |
| 2026-04-29 (UP-04) AskUserQuestion PRIMARY Q&A | yes | yes (memory-routing-audit.sh) | no | priority-2 firing-test |
| 2026-04-29 grep -c with || fallback | yes | yes (bash-hook-lint.sh) | no | priority-1 firing-test |
| 2026-04-29 Stale-Prompt Reference Check | yes | yes (stale-prompt-detector.sh) | no | priority-1 firing-test |
| 2026-04-29 Continue-Injector Gated by autonomous_mode | yes | yes (session-start-bootstrap.sh:109-148) | no | priority-1 firing-test |
| 2026-04-29 Source-Specific Continue-Injector Gating | yes | yes (session-start-bootstrap.sh) | no | priority-1 firing-test (L-S48-1 incident corollary) |
| 2026-04-29 Pre-Amendment Delta Summary | yes (partial) | no | no | DEFER — needs spec amendment cadence to test |
| 2026-04-29 (S10) Bash Hook ERR-Trap Silent Failure | yes (candidate D10) | partial (loc-ceiling-check.sh predecessor; bash-hook-lint.sh extension proposed Cluster 6) | no | priority-1 — promote via Cluster 6 extension |
| 2026-04-29 (S10) Glob+Read+Bash File-Ops Boundary Deny | yes | yes (write-vs-edit-guard.sh + Anthropic boundary system) | no | priority-2 firing-test |
| 2026-04-29 (S10) Append-Only Stale Filenames | yes | yes (append-only enforced via .claude/settings deny) | n/a | already-applied |
| 2026-04-29 (S11) Phase 0 Hook Portability bash+POSIX | yes | yes (bash-hook-lint.sh non-whitelisted-cmd check) | no | priority-1 firing-test |
| 2026-04-29 (S12) Self-Learning Deterministic Metric | yes | yes (learning-loop-metric-check.sh + learning-index-rebuild.sh) | no | priority-2 firing-test |
| 2026-04-29 (S13-pre) head -1 Unscoped Grep | yes | yes (bash-hook-lint.sh head -1 check) | no | priority-1 firing-test |
| 2026-04-29 (S13) Producer-Consumer Log Path Mismatch | yes | yes (bash-hook-lint.sh LOG_VAR check) | no | priority-2 firing-test |
| 2026-04-29 (S14) Wildcard Permissions in settings.local | yes (covered by user memory) | n/a (process rule) | n/a | already-applied |
| 2026-04-29 (S13) Cumulative-vs-Windowed Metric | partial | no | no | DEFER — single-occurrence; revisit at S60+ data |
| 2026-04-29 (S13-pre) project.md Update at SessionEnd | yes | yes (project-md-staleness-check.sh) | no | priority-1 firing-test |
| 2026-04-29 (S12) research-scanner adversarial | yes | yes (research-scanner-output-validator.sh) | no | priority-2 firing-test |

**Audit summary**: 25 `Auto-detect: yes` entries; **18 already have companion shipped hook (~72%)**; **7 with priority-1 firing-test gap** (i.e., shipped but no firing-test per L-S51-1 = empirical layer not validated). The post-mortem identified ≥4 of these (qa-pending-auto-mover at 0 firings, sync-tracker-auto-update at 1 vs ~186 expected, HH-D Mode-E 0 firings, HH-E.1 0 firings) as priority remediation targets.

---

## Top-N final recommendations (ranked)

### Priority-1 hooks (deterministic; ship in S52 cherry-pick OR T7 retrofit)

1. **`scripts/hooks/in-flight-subagent-watcher.sh`** (Cluster 3, NEW HOOK)
   - Severity: medium
   - Estimated hook LOC: ~50 (bash + POSIX per L-S11-1)
   - Estimated firing-test LOC: ~60
   - Suggested next-session ship target: S52 IMPL (T3.4 cherry-pick window OR T4 if T3.4 cannot fit)
   - Real file detected: `agent-workspace/memory/.dispatch-pending-*.jsonl`
   - Resolves M-S49b-2 secondary observation S1 + S2 + L-S49b-3 deferred Fix-L4

2. **`scripts/hooks/hook-firing-counter.sh`** (Cluster 5, NEW HOOK — precursor to T6)
   - Severity: medium
   - Estimated hook LOC: ~70
   - Estimated firing-test LOC: ~80
   - Suggested next-session ship target: S52 IMPL OR S56 (T6 entry)
   - Real file detected: `.session-hooks.log` + `.claude/settings.json` + per-hook `.<hook>.log` files
   - Resolves L-S51-1 (precursor) + post-mortem class (a)/(b)/(c) gap surveillance

3. **`scripts/hooks/bash-hook-lint.sh` extension** (Cluster 6, EXTEND existing)
   - Severity: medium
   - Estimated hook LOC: +30 (extension to existing 140-LOC script)
   - Estimated firing-test LOC: ~60 (synthesize 3 anti-pattern files)
   - Suggested next-session ship target: S52 IMPL
   - Real file detected: `scripts/hooks/*.sh` (lints peers)
   - Resolves L-S51-1 + L-S48d-1 + L-S48m-1 + L-S11-1 + L-S43b-9 (5-rule cluster)

4. **`scripts/hooks/firing-tests/write-vs-edit-guard-fire-test.sh`** (Cluster 1, RETROFIT firing-test)
   - Severity: high (validates ALREADY-SHIPPED HARD-BLOCK hook)
   - Estimated firing-test LOC: ~70
   - Suggested next-session ship target: S52 IMPL OR S57 (T7 entry)
   - Real file shape: PreToolUse JSON envelope with `tool_input.file_path` matching `agent-workspace/memory/agent-notes.md`
   - Resolves L-S45-2 + M-S45-1 demonstration gap (hook live ~12hr with 0 visible blocks; firing-test PROVES it works)

5. **`scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh`** (Cluster 4, RETROFIT firing-test)
   - Severity: high (validates 3×-extended detector)
   - Estimated firing-test LOC: ~80 (7+ pause cases + 4+ control cases per M-S47-1)
   - Suggested next-session ship target: S52 IMPL
   - Real file shape: `LAST_TAIL` extracted from transcript; phrase regex match
   - Resolves L-S44-1 + M-S45-2 + M-S47-1 demonstration gap

### Priority-2 skill candidates (procedural; deferred to T-future)

6. **Skill `post-clear-resume-routine`** (Cluster 3 escalation candidate)
   - Trigger: post-/clear OR resume session-source
   - Procedure: pre-flight check pending-dispatch state + cross-ref expected observation paths + flag stale entries to LLM via system-reminder
   - Cheapest-first justification: deferred until skill-tier required. Hook (Cluster 3 #1) covers mechanical layer; skill would add LLM-judgment layer for ambiguous cases (e.g., "this dispatch was killed but partial work shipped — should I redo?").
   - Suggested ship target: S58+ if Cluster 3 hook recurrences ≥1 within 3 sessions of deploy.

### Priority-3 charter candidates (identity-shaping; deferred to T4 + T8 of Phase 3.5)

7. **L-S49b-4 codification (Cluster 2)** — Phase 3.5 plan 010 T4 already targets this. **This cycle's contribution**: confirm cluster is mature for charter promote (≥3 entries: L-S49b-3 + L-S49b-4 + M-S49b-2).
8. **L-S51-1 charter Principle 11 (Cluster 5)** — Phase 3.5 plan 010 T8 already targets this. **This cycle's contribution**: confirm cluster is mature for charter promote (≥3 entries: L-S51-1 + M-S51-1 + post-mortem 2026-05-05).

### Already-applied (validation only this cycle)

- Cluster 1 hard-block hook (`write-vs-edit-guard.sh`) ✅ shipped same-turn as M-S45-1
- Cluster 4 self-pause regex (`autonomous-stop-watchdog.sh`) ✅ shipped + extended 3× across S44/S45/S47

---

## Out-of-scope (NOT promoting this cycle)

| Item | Reason | Re-trigger condition |
|---|---|---|
| L-S46-1 ruff Callable+Any import collision | Singleton (1 occurrence at S46 BC-6 IMPL); pattern is Python-tooling-specific, not harness-doctrine. | 2nd recurrence in mypy --strict + ruff combo |
| L-S47-1 Empirical Probe Auto-Decide Path Documentation | Singleton; explicitly tagged `Auto-detect: no (human review at S49 calibration session)` | S49+ calibration shows precision drift triggering escalation |
| L-S49-1 NO-LLM-MATH in test authoring | Singleton; assertion-empirical-validation hook proposed but explicitly deferred per agent-notes line 577 ("Phase 1+ deferred (single-occurrence so far; revisit if pattern recurs)") | 2nd recurrence in stat-heavy test authoring |
| L-S49-2 mypy --explicit-package-bases | Singleton (1 occurrence at S49 BC-6); explicitly tagged "candidate hook Phase 1+; charter-tier addition deferred until 2-3 cases recur" | 2nd recurrence of mypy dual-naming error |
| L-S49b-1 Tier 1 archive 6-pass playbook | Procedural playbook (singleton incident at M-S49a-2); hook `tier1-bloat-trend-tracker.sh` proposed but explicitly deferred ("Phase 1+") | tier1-bloat-check WARN persists 3+ Stops in a row |
| M-S35-5 Want-me-to-/schedule defection | Singleton; covered by user memory `full_autonomous_no_supervised.md` | 2nd recurrence — promote agent-output linter at that point |
| HH-E.3 + HH-A.4 Q&A auto-mover firing-test retrofit | Plan 010 T7 already targets this | T7 entry session |
| L-S48-1 continue-injector wrong-window spam | Already-applied (rate-limit + window-targeting fix shipped same-turn) | spam-counter exceeds 5/min OR fallback-focus log line appears post-deploy |
| 2026-04-23 LLM Never Outputs Numbers — citation grep firing-test | Plan 010 T7 retrofit territory | T7 entry session |
| `redact-secrets.sh` + 18 other already-shipped hooks without firing-tests | Plan 010 T7 retrofit territory (~24-25 hooks need firing-tests) | T7 entry session |

---

## Doctrine validation

- **Q-E3 honored**: 5 priority-1 are HOOK (3 NEW + 1 EXTENSION + 2 RETROFIT firing-tests = mechanical layer); 1 priority-2 SKILL deferred until 2nd-recurrence trigger; 2 priority-3 charter candidates (Cluster 2 + Cluster 5 confirmation only — Phase 3.5 T4/T8 already targets via plan 010).
- **Q-B2 honored**: charter-tier promotes (Cluster 2 + Cluster 5) NOT bundled with sub-charter clusters; route through plan 010 T4/T8 + AskUserQuestion gate per master-plan.
- **Q-E2 / Rule 4a honored**: this dispatch IS the 8-session-OR-phase-boundary clearance run; cadence enforced via post-S51-fix HARD-BLOCK firing.
- **Karpathy P3 surgical**: 3 NEW + 1 EXTENSION + 2 RETROFIT actionables; out-of-scope deferrals with explicit re-trigger conditions per ≥10 items.
- **L-S15-1 honored**: charter-tier clusters NOT bundled together with sub-charter; 1 single-pick AskUserQuestion required per Cluster 2 + Cluster 5 each.
- **L-S51-1 empirical-firing discipline honored**: every priority-1 proposal includes (a) real file format hook detects against (NOT imagined format), (b) detection script with concrete grep/parse logic citing real sample lines, (c) companion firing-test strategy.
- **Provenance preserved**: every cluster cites verbatim rule IDs (≥17 distinct citations: L-S44-1, L-S45-1, L-S45-2, L-S46-2, L-S47-1, L-S48-1, L-S48d-1, L-S48m-1, L-S49a-1, L-S49b-2, L-S49b-3, L-S49b-4, L-S51-1; M-S45-1, M-S45-2, M-S47-1, M-S49b-1, M-S49b-2, M-S51-1).

---

## Implementation recommendations for next session (S52 entry — T3.4 cherry-pick)

| Priority | Action | LOC | Owner | Dependency |
|---|---|---|---|---|
| 1 | Author `scripts/hooks/in-flight-subagent-watcher.sh` (Cluster 3) + companion firing-test | ~50 + ~60 | autonomous (S52) | T3 dispatch in-flight check protocol verified post-deploy via firing-test |
| 2 | Author `scripts/hooks/hook-firing-counter.sh` (Cluster 5) + companion firing-test | ~70 + ~80 | autonomous (S52) OR (S56 T6 if defer) | precursor to T6 harness-health-self-scan |
| 3 | Extend `scripts/hooks/bash-hook-lint.sh` with patterns A/B/C (Cluster 6) + firing-test | +30 + ~60 | autonomous (S52) | none |
| 4 | Author `scripts/hooks/firing-tests/write-vs-edit-guard-fire-test.sh` (Cluster 1 retrofit) | ~70 | autonomous (S52) OR T7 | hook is live; firing-test demonstrates real-format detection |
| 5 | Author `scripts/hooks/firing-tests/autonomous-stop-watchdog-fire-test.sh` (Cluster 4 retrofit) | ~80 | autonomous (S52) OR T7 | hook is live + extended 3×; firing-test catches future regex regressions |
| 6 | Wire new hooks (#1, #2) in `.claude/settings.json` UserPromptSubmit + SessionStart chains | +20 settings.json edit | autonomous (S52) | hooks shipped |
| 7 | Run all 5 firing-tests; capture results to `quality-reports/deterministic/2026-05-XX-S52-T3.4-firing-tests.log` | n/a | autonomous (S52) | hooks shipped |

**Total LOC budget for S52 cherry-pick**: ~250 hook LOC + ~340 firing-test LOC + ~20 settings edit + 1 quality-report = ~610 LOC across 5 actions. Comfortable in FOCUSED_IMPL or MULTI_TASK_IMPL session envelope (Phase 3.5 plan 010 T3 budget = 80-120K main).

---

## Dispatch consumption note

Main session (S52 or later) consumes this observation by:
1. **Cherry-picking top 3-5 priority-1 hook proposals** (recommendations #1-#5 above)
2. **Authoring each hook + companion firing-test** per L-S51-1 discipline (REAL file-format detection; NOT imagined formats)
3. **Running firing-tests**; production smoke against real session-data shape (current `.session-hooks.log` format with `[ISO-timestamp] event=... ` line shape; current `.claude/settings.json` JSON shape; current `.dispatch-pending-*.jsonl` format)
4. **Wiring new hooks** to appropriate event chains (UserPromptSubmit + SessionStart per Cluster 3 + 5 design)
5. **Updating `mistake-log.md`** with M-S52-N entries per shipped fix (per CLAUDE.md § Session End step 6 + session-end-checklist-linter.sh)
6. **Updating `agent-notes.md`** with L-S52-N entries documenting new hooks + firing-tests (per Rule 4b lesson-synthesis-mandatory + L-S45-2 Edit-not-Write discipline; L-S51-1 empirical-firing column per shipped hook)
7. **Updating `current-execution.md`** S52 row + checkpoint with `next_action: S53 T3 promote-rule cycle backlog dispatch (sandwich subagent per plan 010)`
8. **Ending turn after checkpoint write** per L-S49b-4 (carve-out: this dispatch's authoring is the LAST tool call per M-S49b-2 anti-pattern guidance from brief)

---

## Re-trigger schedule

- **Next promote-rule eligible session**: S60 default (S52 + 8 per Q-E2) OR earlier if:
  - Phase 3.5 closes at S57 (PHASE_CHANGED=1 → trigger at S58 even if delta < 8)
  - ≥5 new agent-notes entries land between now and S58 (Rule 4a soft-warn)
  - ≥8 new agent-notes entries land OR phase boundary crosses (Rule 4a hard-block — `promotion-cycle-trigger.sh` post-S51-fix should now fire correctly)
- **Footer status**: HARD-BLOCK CLEARED for `promotion-cycle-trigger.sh` (delta resets at next session-start since this observation file matches glob `promote-rule-S*.md`).
- **Charter-tier escalation watch**: if L-S44-1 family (self-pause) hits 4th recurrence post-M-S47-1, mandatory skill-tier promotion per Q-E3 cadence (Hook-extended-3× → next escalation = Skill or Charter).
- **Phase 3.5 T4 + T8 cool-down**: 48hr per Revision Protocol; this cycle does NOT pre-empt those gates — only confirms cluster maturity.

---

## Confidence assessment

- **Empirical grounding**: HIGH — every cluster cites verbatim rule IDs + real file-format detection samples + cross-references to existing hook inventory + post-mortem evidence
- **Bias acknowledgment**: MEDIUM — this dispatch authored by general-purpose subagent in fresh context (per L-S49b-3); no prior involvement with the lessons being clustered. Bias risk: same-promotion-doctrine subagent that authored S43c (3 cycles ago) — promote-rule skill bias toward "more hooks". Counter-bias: every priority-1 has explicit re-trigger condition + LOC estimate + firing-test scope; deferrals are equally numbered to actionables (10 deferrals vs 5 actionables = restraint signal).
- **Audit handle**: this observation file IS the verification artifact per brief's M-S49b-2 anti-pattern guidance (no post-Write verification call).

End of cycle.
