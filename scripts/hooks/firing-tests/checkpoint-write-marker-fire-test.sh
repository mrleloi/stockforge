#!/usr/bin/env bash
# Firing-test for checkpoint-write-marker.sh (L-S49b-4 charter-coverage push; S75).
#
# Hook purpose (PostToolUse hook; per L-S49b-4 + autonomous-protocol Rule 10 Mode-D):
#   - reads stdin JSON: hook_event_name + session_id + tool_name + tool_input.file_path
#   - bypass: STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 → log "BYPASSED" + exit 0
#   - filter: tool_name MUST be Edit/Write/MultiEdit (else exit 0)
#   - filter: file_path MUST end with checkpoints/latest.md (else exit 0)
#   - on match: write `.checkpoint-written-<session_id>` marker (audit content)
#   - if current-execution.md has `**autonomous_mode**: true`:
#       ALSO write `.fresh-resume-pending-<session_id>` with checkpoint_ref +
#       next_action_excerpt (5-line head from "## Next action" / "**Successor**")
#   - emit additionalContext stdout for LLM (DENY-NEXT-TOOL reminder)
#
# 6 test cases:
#   TC1 — no stdin → exit 0 silently (no marker, no log)
#   TC2 — STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 → exit 0; "BYPASSED" log entry; no marker
#   TC3 — wrong tool_name (Bash) → exit 0; no marker, no log entry
#   TC4 — Edit + non-checkpoint file_path → exit 0; no marker
#   TC5 — Edit + checkpoints/latest.md + autonomous_mode=false → marker SET; log entry; NO resume marker
#   TC6 — Edit + checkpoints/latest.md + autonomous_mode=true → marker SET + resume marker SET
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../checkpoint-write-marker.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: hook depends on `node` (JSON parsing). Skip test if absent.
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not installed; checkpoint-write-marker requires node for JSON parsing"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
CHECKPOINT_DIR="$MEM_DIR/checkpoints"
LOG="$MEM_DIR/.session-hooks.log"
EXEC_FILE="$MEM_DIR/current-execution.md"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR" "$CHECKPOINT_DIR"
}

# --- TC1: no stdin → exit 0 silently ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
MARKER_COUNT=$(find "$MEM_DIR" -name '.checkpoint-written-*' 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
if [ "$MARKER_COUNT" != "0" ]; then
  echo "FAIL TC1: marker should NOT exist for empty stdin"
  ls -la "$MEM_DIR/" 2>/dev/null
  exit 1
fi
echo "PASS TC1: empty stdin → exit 0; no marker"

# --- TC2: bypass env var → BYPASSED log, exit 0, no marker ---
clean_state
RC=0
STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "BYPASSED via env" "$LOG"; then
  echo "FAIL TC2: log should record BYPASSED"
  cat "$LOG" 2>/dev/null
  exit 1
fi
MARKER_COUNT=$(find "$MEM_DIR" -name '.checkpoint-written-*' 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
if [ "$MARKER_COUNT" != "0" ]; then
  echo "FAIL TC2: marker should NOT exist with bypass"
  exit 1
fi
echo "PASS TC2: STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 → BYPASSED log, no marker"

# --- TC3: wrong tool_name (Bash) → exit 0; no marker ---
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"test-session-1","tool_name":"Bash","tool_input":{"file_path":"agent-workspace/memory/checkpoints/latest.md"}}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$PAYLOAD" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
MARKER_COUNT=$(find "$MEM_DIR" -name '.checkpoint-written-*' 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
if [ "$MARKER_COUNT" != "0" ]; then
  echo "FAIL TC3: marker should NOT exist for tool_name=Bash"
  exit 1
fi
echo "PASS TC3: tool_name=Bash → filter rejects, no marker"

# --- TC4: Edit + non-checkpoint file_path → exit 0; no marker ---
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"test-session-2","tool_name":"Edit","tool_input":{"file_path":"agent-workspace/memory/agent-notes.md"}}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$PAYLOAD" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
MARKER_COUNT=$(find "$MEM_DIR" -name '.checkpoint-written-*' 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
if [ "$MARKER_COUNT" != "0" ]; then
  echo "FAIL TC4: marker should NOT exist for non-checkpoint file_path"
  exit 1
fi
echo "PASS TC4: Edit on non-checkpoint file → no marker"

# --- TC5: Edit + checkpoints/latest.md + autonomous_mode=false → marker SET; NO resume marker ---
clean_state
echo "**autonomous_mode**: false" > "$EXEC_FILE"
echo "# stub checkpoint" > "$CHECKPOINT_DIR/latest.md"
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"test-session-5","tool_name":"Edit","tool_input":{"file_path":"agent-workspace/memory/checkpoints/latest.md"}}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$PAYLOAD" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$MEM_DIR/.checkpoint-written-test-session-5" ]; then
  echo "FAIL TC5: marker .checkpoint-written-test-session-5 should exist"
  ls -la "$MEM_DIR/" 2>/dev/null
  exit 1
fi
if ! grep -q "session_id=test-session-5" "$MEM_DIR/.checkpoint-written-test-session-5"; then
  echo "FAIL TC5: marker should contain session_id=test-session-5"
  cat "$MEM_DIR/.checkpoint-written-test-session-5"
  exit 1
fi
if [ -f "$MEM_DIR/.fresh-resume-pending-test-session-5" ]; then
  echo "FAIL TC5: resume marker should NOT exist with autonomous_mode=false"
  cat "$MEM_DIR/.fresh-resume-pending-test-session-5"
  exit 1
fi
echo "PASS TC5: Edit + checkpoints/latest.md + autonomous=false → marker SET, no resume marker"

# --- TC6: Edit + checkpoints/latest.md + autonomous_mode=true → marker + resume marker SET ---
clean_state
echo "**autonomous_mode**: true" > "$EXEC_FILE"
cat > "$CHECKPOINT_DIR/latest.md" <<'EOF'
# Checkpoint stub
**Successor**: S99 — autonomous continuation; backlog top: foo bar.

## Next action when session resumes
1. Read this checkpoint
2. Continue with backlog top
EOF
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"test-session-6","tool_name":"Write","tool_input":{"file_path":"agent-workspace/memory/checkpoints/latest.md"}}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$PAYLOAD" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC6: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$MEM_DIR/.checkpoint-written-test-session-6" ]; then
  echo "FAIL TC6: marker .checkpoint-written-test-session-6 should exist"
  exit 1
fi
if [ ! -f "$MEM_DIR/.fresh-resume-pending-test-session-6" ]; then
  echo "FAIL TC6: resume marker .fresh-resume-pending-test-session-6 should exist with autonomous_mode=true"
  ls -la "$MEM_DIR/" 2>/dev/null
  exit 1
fi
if ! grep -q "autonomous_mode=true" "$MEM_DIR/.fresh-resume-pending-test-session-6"; then
  echo "FAIL TC6: resume marker should record autonomous_mode=true"
  cat "$MEM_DIR/.fresh-resume-pending-test-session-6"
  exit 1
fi
if ! grep -q "next_action_excerpt=" "$MEM_DIR/.fresh-resume-pending-test-session-6"; then
  echo "FAIL TC6: resume marker should record next_action_excerpt"
  cat "$MEM_DIR/.fresh-resume-pending-test-session-6"
  exit 1
fi
echo "PASS TC6: Edit + checkpoints/latest.md + autonomous=true → marker + resume marker SET"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "checkpoint-write-marker.sh externally-observable behavior verified."
exit 0
