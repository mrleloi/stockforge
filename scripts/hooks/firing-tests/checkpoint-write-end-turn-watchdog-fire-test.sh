#!/usr/bin/env bash
# Firing-test for checkpoint-write-end-turn-watchdog.sh (Phase 3.5 T7 retrofit; S60).
#
# Hook purpose (M-S49b-2 / L-S49b-4 PreToolUse): if companion PostToolUse hook
# created marker `.checkpoint-written-<session_id>` this turn, deny any
# subsequent non-exempt tool call (exit 2 with stderr message).
#
# Test strategy: stage temp PROJECT_DIR with marker file; pipe varying
# PreToolUse JSON payloads; assert exit code + DENY stderr or EXEMPT log.
#
# 6 test cases:
#   TC1 — bypass env var STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 → exit 0
#   TC2 — HOOK_EVENT != PreToolUse → exit 0 (no-op)
#   TC3 — no marker file → exit 0 (no checkpoint written)
#   TC4 — marker + Read tool (exempt) → exit 0 + EXEMPT log
#   TC5 — marker + Bash tool (non-exempt) → exit 2 + DENY message
#   TC6 — marker + Write to checkpoints/latest.md → exit 0 + EXEMPT log
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../checkpoint-write-end-turn-watchdog.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Skip test if node not available (hook depends on node -e for JSON parsing).
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available; cannot test checkpoint-write-end-turn-watchdog"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
SID="tc-session-1234"

run_hook_with_payload() {
  local payload="$1"
  local rc=0
  local stderr_out
  stderr_out=$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" 2>&1 >/dev/null) && rc=0 || rc=$?
  printf '%s' "$stderr_out"
  return $rc
}

run_hook_with_bypass() {
  local payload="$1"
  local rc=0
  local stderr_out
  stderr_out=$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 \
    bash "$HOOK" 2>&1 >/dev/null) && rc=0 || rc=$?
  printf '%s' "$stderr_out"
  return $rc
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

mark_checkpoint_written() {
  local sid="$1"
  : > "$TEMPDIR/agent-workspace/memory/.checkpoint-written-${sid}"
}

# --- TC1: bypass env var → exit 0 ---
clean_state
mark_checkpoint_written "$SID"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Bash","tool_input":{"command":"ls"}}
EOF
)
RC=0
OUT=$(run_hook_with_bypass "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0 with bypass env, got $RC"
  echo "$OUT"
  exit 1
fi
if ! grep -q "BYPASSED" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: expected BYPASSED in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC1: bypass env → exit 0 + BYPASSED log"

# --- TC2: HOOK_EVENT != PreToolUse → exit 0 ---
clean_state
mark_checkpoint_written "$SID"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PostToolUse","session_id":"$SID","tool_name":"Bash"}
EOF
)
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0 for PostToolUse event, got $RC"
  exit 1
fi
echo "PASS TC2: HOOK_EVENT=PostToolUse → exit 0 (no-op)"

# --- TC3: no marker file → exit 0 ---
clean_state
# No marker created
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Bash","tool_input":{"command":"ls"}}
EOF
)
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0 with no marker, got $RC"
  echo "$OUT"
  exit 1
fi
echo "PASS TC3: no marker → exit 0"

# --- TC4: marker + Read tool (exempt) → exit 0 + EXEMPT log ---
clean_state
mark_checkpoint_written "$SID"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Read","tool_input":{"file_path":"/tmp/x.md"}}
EOF
)
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0 for exempt Read tool, got $RC"
  echo "$OUT"
  exit 1
fi
if ! grep -q "EXEMPT tool=Read" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected EXEMPT log for Read"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC4: marker + Read → exit 0 + EXEMPT log"

# --- TC5: marker + Bash (non-exempt) → exit 2 + DENY ---
clean_state
mark_checkpoint_written "$SID"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Bash","tool_input":{"command":"echo hi"}}
EOF
)
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC5: expected exit 2 for non-exempt Bash after marker, got $RC"
  echo "$OUT"
  exit 1
fi
if ! echo "$OUT" | grep -q "checkpoint-write-end-turn-watchdog: DENY"; then
  echo "FAIL TC5: expected DENY message in stderr; got:"
  echo "$OUT"
  exit 1
fi
if ! grep -q "DENIED tool=Bash" "$LOG" 2>/dev/null; then
  echo "FAIL TC5: expected DENIED log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: marker + Bash → exit 2 + DENY message"

# --- TC6: marker + Write to checkpoints/latest.md → exit 0 + EXEMPT ---
clean_state
mark_checkpoint_written "$SID"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Write","tool_input":{"file_path":"/x/agent-workspace/memory/checkpoints/latest.md"}}
EOF
)
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC6: expected exit 0 for Write to checkpoints/latest.md, got $RC"
  echo "$OUT"
  exit 1
fi
if ! grep -q "EXEMPT tool=Write" "$LOG" 2>/dev/null; then
  echo "FAIL TC6: expected EXEMPT log for Write to checkpoint file"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: marker + Write checkpoints/latest.md → exit 0 + EXEMPT"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "checkpoint-write-end-turn-watchdog.sh externally-observable behavior verified."
exit 0
