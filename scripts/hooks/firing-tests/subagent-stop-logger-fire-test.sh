#!/usr/bin/env bash
# Firing-test for subagent-stop-logger.sh (Phase 3.5 T7-followup; S73).
#
# Hook purpose (HH-B.2-related; SubagentStop hook):
#   - reads stdin JSON {agent_id, status, session_id} via jq if available,
#     else regex fallback
#   - falls back to env vars CLAUDE_AGENT_ID / CLAUDE_AGENT_STATUS /
#     CLAUDE_SESSION_ID when stdin fields empty
#   - if BOTH agent_id AND status empty after fallback → stderr skip msg + exit 0
#   - else: appends one structured line to .session-hooks.log:
#         "[<TS>] SubagentStop agentId=<a> status=<s> session=<sid>"
#   - if BOTH agent_id AND session_id present → also appends marker line to
#     observations/_subagent-stops/<UTC-date>.log
#   - always exits 0
#
# 5 test cases:
#   TC1 — no stdin + no env → skip with stderr msg; no log file
#   TC2 — stdin JSON (all 3 fields) → log line + observation file
#   TC3 — env vars only → log line written; observation if both ids present
#   TC4 — stdin partial (status only, no agent_id) but env empty → log line
#         written (status != empty satisfies "agent_id OR status" guard);
#         observation NOT written (agent_id empty)
#   TC5 — malformed stdin (not JSON) + env populated → falls back to env;
#         log line written
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../subagent-stop-logger.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
OBS_DIR="$TEMPDIR/agent-workspace/memory/observations/_subagent-stops"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
  unset CLAUDE_AGENT_ID CLAUDE_AGENT_STATUS CLAUDE_SESSION_ID
}

# --- TC1: no stdin + no env → skip with stderr msg ---
clean_state
STDERR="$TEMPDIR/tc1.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  cat "$STDERR" || true
  exit 1
fi
if ! grep -q "no agent_id or status available" "$STDERR"; then
  echo "FAIL TC1: expected skip msg in stderr"
  cat "$STDERR"
  exit 1
fi
if [ -f "$LOG" ]; then
  echo "FAIL TC1: log should NOT be written when both agent_id+status empty"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no stdin + no env → skip with stderr msg"

# --- TC2: stdin JSON (all 3 fields) → log line + observation file ---
clean_state
STDIN_JSON='{"agent_id":"sandwich-dev","status":"completed","session_id":"S73-test"}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$STDIN_JSON" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC2: expected log file at $LOG"
  exit 1
fi
if ! grep -q "agentId=sandwich-dev" "$LOG"; then
  echo "FAIL TC2: log should contain 'agentId=sandwich-dev'"
  cat "$LOG"
  exit 1
fi
if ! grep -q "status=completed" "$LOG"; then
  echo "FAIL TC2: log should contain 'status=completed'"
  cat "$LOG"
  exit 1
fi
if ! grep -q "session=S73-test" "$LOG"; then
  echo "FAIL TC2: log should contain 'session=S73-test'"
  cat "$LOG"
  exit 1
fi
# Observation file: _subagent-stops/<UTC-date>.log should exist
OBS_FILES=$(find "$OBS_DIR" -name "*.log" 2>/dev/null | wc -l)
if [ "$OBS_FILES" -lt 1 ]; then
  echo "FAIL TC2: expected ≥1 observation log file in $OBS_DIR"
  ls -la "$OBS_DIR" 2>/dev/null || true
  exit 1
fi
if ! grep -rq "agent_id=sandwich-dev" "$OBS_DIR" 2>/dev/null; then
  echo "FAIL TC2: observation log should record agent_id=sandwich-dev"
  exit 1
fi
echo "PASS TC2: stdin JSON full → log line + observation file"

# --- TC3: env vars only → log line written ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_AGENT_ID="env-agent" \
  CLAUDE_AGENT_STATUS="ok" CLAUDE_SESSION_ID="env-session" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "agentId=env-agent" "$LOG"; then
  echo "FAIL TC3: env-fallback agentId should appear in log"
  cat "$LOG"
  exit 1
fi
if ! grep -q "status=ok" "$LOG"; then
  echo "FAIL TC3: env-fallback status should appear in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: env vars only → log line written"

# --- TC4: stdin partial (status only) + env empty → log line, no observation ---
clean_state
STDIN_JSON='{"status":"failed"}'
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$STDIN_JSON" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC4: log should be written when status alone is non-empty"
  exit 1
fi
if ! grep -q "status=failed" "$LOG"; then
  echo "FAIL TC4: log should contain 'status=failed'"
  cat "$LOG"
  exit 1
fi
# Observation file should NOT exist (agent_id and session_id both empty).
if [ -d "$OBS_DIR" ] && [ "$(find "$OBS_DIR" -name "*.log" 2>/dev/null | wc -l)" -gt 0 ]; then
  echo "FAIL TC4: observation log should NOT be written when agent_id is empty"
  ls -la "$OBS_DIR"
  exit 1
fi
echo "PASS TC4: stdin partial → log line, no observation (agent_id empty)"

# --- TC5: malformed stdin + env populated → falls back to env ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_AGENT_ID="fallback-agent" \
  CLAUDE_AGENT_STATUS="ok" CLAUDE_SESSION_ID="fallback-session" \
  bash "$HOOK" <<<"this is not json" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0 (graceful fallback); got $RC"
  exit 1
fi
if ! grep -q "agentId=fallback-agent" "$LOG"; then
  echo "FAIL TC5: malformed stdin should trigger env fallback for agentId"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: malformed stdin + env populated → env fallback works"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "subagent-stop-logger.sh externally-observable behavior verified."
exit 0
