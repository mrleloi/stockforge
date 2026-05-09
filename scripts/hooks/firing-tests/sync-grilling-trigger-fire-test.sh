#!/usr/bin/env bash
# Firing-test for sync-grilling-trigger.sh (L-S49b-4 charter-coverage push; S76).
#
# Hook purpose (SessionStart hook):
#   - Reads stdin JSON; extracts source field via node JSON.parse
#   - Filters: only runs on source ∈ {startup, resume, clear}
#   - Reads sync-state.md for last_check: YYYY-MM-DD field (latest match)
#   - Counts session log files dated > last_check (sessions_since)
#   - Computes (now - last_check) in days (days_since)
#   - Fires if sessions_since ≥ INTERVAL_SESSIONS (default 3) OR days_since ≥ INTERVAL_DAYS (default 7)
#   - On fire: appends to .sync-grill-fired.log + emits hookSpecificOutput JSON to stdout
#
# 5 test cases:
#   TC1 — source=prompt-submit (filtered) → exit 0; no log; no grill log
#   TC2 — source=startup + no sync-state.md → log skip; exit 0
#   TC3 — under threshold (last_check 1d ago + 1 session) → log not-due; no fire
#   TC4 — last_check 8d ago + 0 sessions → FIRED on days threshold + hookSpecificOutput
#   TC5 — last_check 1d ago + 4 sessions today → FIRED on session count + hookSpecificOutput
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../sync-grilling-trigger.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: hook depends on node for JSON.parse + JSON emit.
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not installed; sync-grilling-trigger requires node for JSON parse/emit"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
SESSIONS_DIR="$MEM_DIR/sessions"
SYNC_STATE="$MEM_DIR/sync-state.md"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
GRILL_LOG="$MEM_DIR/.sync-grill-fired.log"

# Date helpers (Git Bash + macOS compat).
date_minus_days() {
  local n="$1"
  date -d "$n days ago" +%Y-%m-%d 2>/dev/null || date -v-"$n"d +%Y-%m-%d 2>/dev/null || python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=$n)).isoformat())"
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR" "$SESSIONS_DIR"
}

# --- TC1: source=prompt-submit (filter rejects) → silent exit 0 ---
clean_state
echo "last_check: $(date_minus_days 1)" > "$SYNC_STATE"
RC=0
echo '{"source":"prompt-submit"}' | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$HOOK_LOG" ] && grep -q "sync-grilling-trigger" "$HOOK_LOG"; then
  echo "FAIL TC1: log should be empty for filtered source"
  cat "$HOOK_LOG"
  exit 1
fi
if [ -f "$GRILL_LOG" ]; then
  echo "FAIL TC1: grill log should not be created for filtered source"
  exit 1
fi
echo "PASS TC1: source=prompt-submit → silent exit 0 (filter rejected)"

# --- TC2: source=startup + no sync-state.md → log skip ---
clean_state
RC=0
echo '{"source":"startup"}' | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "skip (no sync-state.md)" "$HOOK_LOG"; then
  echo "FAIL TC2: log should record skip when sync-state.md absent"
  cat "$HOOK_LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC2: no sync-state.md → log skip"

# --- TC3: under threshold (last_check 1d ago + 1 session) → not-due ---
clean_state
YESTERDAY=$(date_minus_days 1)
TODAY=$(date +%Y-%m-%d)
echo "last_check: $YESTERDAY" > "$SYNC_STATE"
echo "stub" > "$SESSIONS_DIR/${TODAY}-session-1.md"
RC=0
echo '{"source":"startup"}' | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "not due" "$HOOK_LOG"; then
  echo "FAIL TC3: log should record not-due"
  cat "$HOOK_LOG"
  exit 1
fi
if [ -f "$GRILL_LOG" ]; then
  echo "FAIL TC3: grill log should not be created when not-due"
  cat "$GRILL_LOG"
  exit 1
fi
echo "PASS TC3: under threshold → log not-due, no grill log"

# --- TC4: last_check 8d ago + 0 sessions → FIRED on days threshold + hookSpecificOutput ---
clean_state
EIGHT_DAYS_AGO=$(date_minus_days 8)
echo "last_check: $EIGHT_DAYS_AGO" > "$SYNC_STATE"
RC=0
STDOUT=$(echo '{"source":"startup"}' | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "FIRED" "$HOOK_LOG"; then
  echo "FAIL TC4: log should record FIRED"
  cat "$HOOK_LOG"
  exit 1
fi
if [ ! -f "$GRILL_LOG" ] || ! grep -q "SYNC-GRILLING-DUE" "$GRILL_LOG"; then
  echo "FAIL TC4: grill log should record SYNC-GRILLING-DUE"
  cat "$GRILL_LOG" 2>/dev/null
  exit 1
fi
if ! grep -q "days elapsed" "$HOOK_LOG"; then
  echo "FAIL TC4: log should record days threshold reason"
  cat "$HOOK_LOG"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "hookSpecificOutput"; then
  echo "FAIL TC4: stdout should contain hookSpecificOutput JSON"
  echo "STDOUT: $STDOUT"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "additionalContext"; then
  echo "FAIL TC4: stdout JSON should contain additionalContext field"
  echo "STDOUT: $STDOUT"
  exit 1
fi
echo "PASS TC4: 8d days threshold → FIRED log + grill log + hookSpecificOutput JSON"

# --- TC5: last_check 1d ago + 4 sessions today → FIRED on session count ---
clean_state
YESTERDAY=$(date_minus_days 1)
TODAY=$(date +%Y-%m-%d)
echo "last_check: $YESTERDAY" > "$SYNC_STATE"
echo "stub" > "$SESSIONS_DIR/${TODAY}-session-1.md"
echo "stub" > "$SESSIONS_DIR/${TODAY}-session-2.md"
echo "stub" > "$SESSIONS_DIR/${TODAY}-session-3.md"
echo "stub" > "$SESSIONS_DIR/${TODAY}-session-4.md"
RC=0
STDOUT=$(echo '{"source":"resume"}' | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "FIRED" "$HOOK_LOG"; then
  echo "FAIL TC5: log should record FIRED on session count"
  cat "$HOOK_LOG"
  exit 1
fi
if ! grep -q "4 sessions elapsed" "$HOOK_LOG"; then
  echo "FAIL TC5: log should record 4 sessions reason"
  cat "$HOOK_LOG"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "hookSpecificOutput"; then
  echo "FAIL TC5: stdout should contain hookSpecificOutput JSON"
  echo "STDOUT: $STDOUT"
  exit 1
fi
echo "PASS TC5: 4 sessions threshold → FIRED on session count + hookSpecificOutput"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "sync-grilling-trigger.sh externally-observable behavior verified."
exit 0
