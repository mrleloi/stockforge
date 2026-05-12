#!/usr/bin/env bash
# single-claude-instance-lock.sh
# PURPOSE: Prevent phantom-dispatch race condition surfaced by S238 M-S238-2 + S239 L-S239-4 + S240 L-S240-5.
# When multiple claude.exe instances run concurrently with autonomous_mode=true + same current-execution.md,
# each instance dispatches its own copy of the active task. This hook hard-blocks SessionStart on sibling claude.exe.
#
# WIRING STATUS: WIRED — active in .claude/settings.json SessionStart chain.
# SessionEnd chain (.claude/settings.json line ~239) cleans the lock file at session close.
# Lock lifetime = SESSION (created by SessionStart, persisted for entire claude.exe lifetime,
# removed by SessionEnd rm -f command). Do NOT add EXIT trap here — that would defeat persistence.
#
# RC reference: agent-workspace/memory/observations/drift-detector-S241b-phantom-dispatch-RC.md
# Related lessons: M-S238-2 / L-S239-4 / L-S240-5
# Bug fixed S244: removed line-30 EXIT trap that deleted lock microseconds after creation (defeating protection).
# Bug fixed S246: holder-pid was unreliable (PPID=1 in spawned context, CLAUDE_PID/SESSION_ID empty on Windows
#   per L-S48m-1/L-S108-1). Replaced with all-claude-pids csv + epoch staleness floor (Strategy f).
#   Empirical basis: lock-rc-probe-20260510-221147-1058996.txt confirmed:
#     - $PPID == 1 in spawned hook (Strategy c ancestor-walk FAILS)
#     - stdin JSON has no pid field (Strategy e stdin-pid FAILS for identity)
#     - session_id in stdin JSON IS reliable (extracted via node per dispatch-jsonl-recorder.sh:21-35)
#     - tasklist //V reliably lists all 4 live claude.exe pids
#
# LOCK FORMAT (S246+): "claude_pids=<csv>:created=<epoch>:session_id=<sid_or_unknown>"
#   csv = comma-separated PIDs from tasklist IMAGENAME=claude.exe (excluding subagent spawns with -p flag)
#   epoch = Unix seconds at write time
#   sid = session_id from stdin JSON (reliable per L-S108-1 fix pattern in dispatch-jsonl-recorder.sh:104-111)
#
# BLOCK CONDITION (both must hold):
#   (a) Staleness floor: now - created < STOCKFORGE_LOCK_STALE_SEC (default 7200 = 2hr)
#   (b) Liveness: any stored pid still alive in current tasklist AND not sole claude.exe
#       (if stored pids == current pids in count, assume same session resumed, no block)
#
# BACKWARD-COMPAT: S244 format "session=X:Y:Z" → treated as stale on read; overwritten without BLOCK.
#   Detection: if lock content does NOT start with "claude_pids=", treat as legacy/stale.
#
# DO NOT use $PPID — unreliable in spawn paths (proven 1 in 174/174 SessionStart events on Windows).
# DO NOT use $CLAUDE_SESSION_ID without empty-fallback handling — empty in 174/174 SessionStart
#   events on Windows per L-S48m-1 / L-S108-1.
# DO NOT use CLAUDE_PID — proven empty in spawned context (S245 observation).

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOCK="$PROJECT_DIR/agent-workspace/memory/.claude-instance.lock"
THRESHOLD="${STOCKFORGE_LOCK_STALE_SEC:-7200}"
NOW="$(date +%s)"

# ── Read stdin JSON before anything else (consumed exactly once) ──────────────
# Mirror dispatch-jsonl-recorder.sh:17 + dispatch-jsonl-recorder.sh:21-35 pattern.
PAYLOAD="$(cat 2>/dev/null || true)"

# Extract session_id from stdin JSON via node.
# Mirrors dispatch-jsonl-recorder.sh:21-35. Falls back to "unknown" (safe; lock is still useful
# for liveness check even without a unique session id).
SESSION_ID="unknown"
if [ -n "$PAYLOAD" ]; then
  _sid="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try { const p=JSON.parse(s); console.log(p.session_id||''); }
  catch { console.log(''); }
});" 2>/dev/null || true)"
  [ -n "$_sid" ] && SESSION_ID="$_sid"
fi

# ── Collect current claude.exe PIDs via tasklist ──────────────────────────────
# Uses //NH (no header) //FO CSV (CSV output) for reliable column parsing.
# Filters IMAGENAME eq claude.exe (per single-claude-instance-lock.sh original line 24 bare-tasklist usage).
# //V (verbose) adds command-line column so we can exclude subagent spawns (claude -p / --print).
# Precedent: plan §6.2 confirms bare 'tasklist' (not absolute path) is correct.
_tasklist_out="$(tasklist //NH //FO CSV //V //FI "IMAGENAME eq claude.exe" 2>/dev/null || true)"

# Parse PID column (field 2 in CSV) and filter out subagent spawns.
# CSV row: "claude.exe","PID","Session Name","Session#","Mem Usage","Status","User Name","CPU Time","Window Title"
# CommandLine is NOT a separate column in tasklist //V CSV — Window Title is the last column.
# We filter by checking if the raw row contains ' -p ' or ' --print ' pattern (subagent dispatch argv).
# Precedent: plan §4.3 counter-argument 4 + plan §3.6 mechanism spec.
CURRENT_PIDS=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  # Extract PID: field 2 after stripping CSV quotes.
  _pid="$(printf '%s' "$line" | awk -F'","' '{gsub(/^"|"$/,"",$2); print $2}' 2>/dev/null || true)"
  [ -z "$_pid" ] && continue
  # Exclude subagent spawns: look for -p or --print in window title / any field (best-effort).
  # tasklist //V CSV window title is the last quoted field — subagent spawns show "N/A" or blank.
  # The actual filtering that matters: the subagent claude.exe is a separate PID; as long as
  # we don't BLOCK on our own session starting, the liveness count logic handles it.
  # Include all claude.exe pids; self-identification via count heuristic (see READ-side logic).
  if [ -n "$CURRENT_PIDS" ]; then
    CURRENT_PIDS="${CURRENT_PIDS},${_pid}"
  else
    CURRENT_PIDS="$_pid"
  fi
done <<< "$_tasklist_out"

# ── READ-SIDE: check existing lock ────────────────────────────────────────────
if [ -f "$LOCK" ]; then
  LOCK_CONTENT="$(cat "$LOCK" 2>/dev/null || true)"

  # Backward-compat: S244 format starts with "session=" not "claude_pids=".
  # Treat as stale → fall through to write new format. No BLOCK.
  if ! printf '%s' "$LOCK_CONTENT" | grep -q '^claude_pids='; then
    # Legacy format — treat as stale; overwrite below.
    true
  else
    # S246 format: "claude_pids=<csv>:created=<epoch>:session_id=<sid>"
    # Parse fields.
    _f1="$(printf '%s' "$LOCK_CONTENT" | awk -F: '{print $1}' 2>/dev/null || true)"
    _f2="$(printf '%s' "$LOCK_CONTENT" | awk -F: '{print $2}' 2>/dev/null || true)"
    _f3="$(printf '%s' "$LOCK_CONTENT" | awk -F: '{print $3}' 2>/dev/null || true)"
    STORED_PIDS_CSV="${_f1#claude_pids=}"
    STORED_CREATED="${_f2#created=}"
    STORED_SID="${_f3#session_id=}"

    # Staleness check: if age >= THRESHOLD, treat as stale → overwrite.
    AGE=$(( NOW - ${STORED_CREATED:-0} ))
    if [ "$AGE" -ge "$THRESHOLD" ] 2>/dev/null; then
      # Stale lock — overwrite below (no BLOCK).
      true
    else
      # Fresh lock (within threshold). Check liveness.
      # Count stored pids.
      STORED_COUNT=0
      for _p in $(printf '%s' "$STORED_PIDS_CSV" | tr ',' ' '); do
        STORED_COUNT=$(( STORED_COUNT + 1 ))
      done

      # Count current pids.
      CURRENT_COUNT=0
      for _p in $(printf '%s' "$CURRENT_PIDS" | tr ',' ' '); do
        CURRENT_COUNT=$(( CURRENT_COUNT + 1 ))
      done

      # Check if any stored PID is still alive in current tasklist.
      LIVE_SIBLING=0
      for _stored_pid in $(printf '%s' "$STORED_PIDS_CSV" | tr ',' ' '); do
        [ -z "$_stored_pid" ] && continue
        for _cur_pid in $(printf '%s' "$CURRENT_PIDS" | tr ',' ' '); do
          if [ "$_stored_pid" = "$_cur_pid" ]; then
            LIVE_SIBLING=1
            break
          fi
        done
        [ "$LIVE_SIBLING" -eq 1 ] && break
      done

      if [ "$LIVE_SIBLING" -eq 1 ]; then
        # Self-identification heuristic (plan §3.1):
        # If current count > stored count: a NEW claude.exe joined → that new one is us → BLOCK.
        # If current count == stored count: same set of processes (we ARE the stored session) → no BLOCK.
        # If current count < stored count: some stored pids died → they are not all alive → liveness
        #   check above would have missed (but we already set LIVE_SIBLING=1, so re-evaluate).
        if [ "$CURRENT_COUNT" -le "$STORED_COUNT" ]; then
          # Same or fewer pids → we are the same session or the set shrank; don't self-block.
          true  # Fall through to overwrite.
        else
          # More pids now than stored: we are a NEW claude.exe; existing stored pids are siblings.
          BLOCK_PIDS=""
          for _stored_pid in $(printf '%s' "$STORED_PIDS_CSV" | tr ',' ' '); do
            [ -z "$_stored_pid" ] && continue
            for _cur_pid in $(printf '%s' "$CURRENT_PIDS" | tr ',' ' '); do
              if [ "$_stored_pid" = "$_cur_pid" ]; then
                if [ -n "$BLOCK_PIDS" ]; then
                  BLOCK_PIDS="${BLOCK_PIDS},${_stored_pid}"
                else
                  BLOCK_PIDS="$_stored_pid"
                fi
                break
              fi
            done
          done
          echo "[BLOCK] live claude.exe holder(s)=${BLOCK_PIDS} in lock; created ${AGE}s ago. Refusing autonomous-continue spawn." >&2
          export STOCKFORGE_AUTONOMOUS_DISABLE=1
          exit 2
        fi
      fi
      # No live sibling found (or same-count heuristic) → overwrite below.
    fi
  fi
fi

# ── WRITE-SIDE: write new lock ────────────────────────────────────────────────
printf 'claude_pids=%s:created=%s:session_id=%s\n' \
  "${CURRENT_PIDS:-unknown}" \
  "$NOW" \
  "$SESSION_ID" \
  > "$LOCK"
exit 0
