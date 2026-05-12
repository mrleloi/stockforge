#!/usr/bin/env bash
# lock-rc-probe.sh — DIAGNOSTIC ONLY — not wired by default.
#
# PURPOSE: Capture process-tree + env-var + stdin-JSON signals at SessionStart
# to empirically determine why SELF_PID resolves to 1 inside single-claude-instance-lock.sh
# (S245 defect: agent-workspace/memory/observations/2026-05-10-S245-lock-pid-secondary-defect.md:24).
#
# See probe results: agent-workspace/memory/observations/sandwich-dev-S246-A-probe-ship.md
# Strategy (f) was selected based on probe data confirming:
#   - $PPID == 1 in spawned hook context (Strategy c fails)
#   - stdin JSON has no pid field (Strategy e fails for PID; session_id IS reliable)
#   - tasklist //V reliably lists all claude.exe PIDs
#
# WIRING STATUS: NOT WIRED — removed from .claude/settings.json after S246-A probe captured data.
# To re-wire for future RC investigation: add hook entry BEFORE single-claude-instance-lock.sh
# in .claude/settings.json SessionStart chain. See sandwich-dev-S246-A-probe-ship.md for
# the exact JSON block. Revert after capturing diagnostic artifact.
#
# NEVER modifies agent-workspace/memory/.claude-instance.lock.
# ALWAYS exits 0 (diagnostic, not enforcement).
#
# Do NOT add a firing-test for this script (plan §2.4: throwaway diagnostic).
# Do NOT wire permanently. Re-wire only for RC investigation.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
mkdir -p "$OBS_DIR" 2>/dev/null || true

OUTFILE="$OBS_DIR/lock-rc-probe-$(date +%Y%m%d-%H%M%S)-$$.txt"

# Read stdin JSON before anything else (it is consumed exactly once).
# Mirror dispatch-jsonl-recorder.sh:17 pattern: PAYLOAD=$(cat).
PAYLOAD="$(cat 2>/dev/null || true)"

{
  echo "=== lock-rc-probe ==="
  echo "timestamp=$(date -Iseconds 2>/dev/null || date)"
  echo ""

  # Signal 1: hook's own PID
  echo "--- SIGNAL 1: hook PID ($$) ---"
  echo "hook_pid=$$"
  echo ""

  # Signal 2: PPID (S245 saw 1 — confirm)
  echo "--- SIGNAL 2: hook PPID (\$PPID) ---"
  echo "hook_ppid=$PPID"
  echo ""

  # Signal 3: ps -ef snapshot for parent-chain walk
  echo "--- SIGNAL 3: ps -ef (full snapshot; look for claude.exe ancestor) ---"
  ps -ef 2>/dev/null || echo "(ps -ef unavailable)"
  echo ""

  # Signal 4: tasklist //V no-filter (full claude.exe list with command-line columns)
  echo "--- SIGNAL 4: tasklist //V (all claude.exe processes) ---"
  tasklist //V //FI "IMAGENAME eq claude.exe" 2>/dev/null || echo "(tasklist unavailable)"
  echo ""

  # Signal 5: wmic process parent linkage
  echo "--- SIGNAL 5: wmic process where name='claude.exe' (ProcessId,ParentProcessId,CommandLine) ---"
  wmic process where "name='claude.exe'" get ProcessId,ParentProcessId,CommandLine 2>/dev/null \
    || echo "(wmic unavailable)"
  echo ""

  # Signal 6: env vars matching CLAUDE_* | STOCKFORGE_* | SESSION*
  echo "--- SIGNAL 6: env vars (CLAUDE_* | STOCKFORGE_* | SESSION*) ---"
  env 2>/dev/null | grep -E '^(CLAUDE_|STOCKFORGE_|SESSION)' | sort \
    || echo "(no matching env vars found)"
  echo ""

  # Signal 7: full stdin JSON payload
  # Mirror dispatch-jsonl-recorder.sh:21-35 node-parse pattern to extract fields.
  echo "--- SIGNAL 7: stdin JSON payload (raw) ---"
  if [ -n "$PAYLOAD" ]; then
    echo "$PAYLOAD"
    echo ""
    echo "--- SIGNAL 7 (parsed fields via node) ---"
    printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('hook_event_name='+q(p.hook_event_name));
    console.log('session_id='+q(p.session_id));
    console.log('pid='+q(p.pid));
    console.log('ppid='+q(p.ppid));
    console.log('parent_pid='+q(p.parent_pid));
    console.log('process_id='+q(p.process_id));
    console.log('cwd='+q(p.cwd));
    console.log('tool_name='+q(p.tool_name));
    console.log('ALL_KEYS='+JSON.stringify(Object.keys(p)));
  } catch(e) { console.log('parse_error='+JSON.stringify(String(e))); }
});" 2>/dev/null || echo "(node parse failed)"
  else
    echo "(stdin was empty)"
  fi

  echo ""
  echo "=== end lock-rc-probe ==="

} > "$OUTFILE" 2>&1 || true

# Always exit 0 — diagnostic never blocks SessionStart.
exit 0
