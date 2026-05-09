#!/usr/bin/env bash
# Firing-test for learning-queue-sweeper.sh (L-S49b-4 charter-coverage push; S76).
#
# Hook purpose (SessionStart hook; runs in BACKGROUND subshell + disown):
#   - Rotate learning-data/events/*.ndjson with mtime > LEARNING_ROTATE_DAYS (default 7) → archive/
#   - Purge learning-data/archive/*.ndjson with mtime > LEARNING_PURGE_DAYS (default 30)
#   - Warn (no-rotate) when events/*.ndjson size > LEARNING_MAX_FILE_BYTES (default 10MB)
#   - Logs result to .session-hooks.log: rotated=N purged=N size_warn=N rotate_days=X purge_days=Y
#
# 5 test cases (uses poll loop because subshell is backgrounded with disown):
#   TC1 — empty EVENTS_DIR + ARCHIVE_DIR → log "rotated=0 purged=0 size_warn=0"
#   TC2 — fresh event (mtime now) + ROTATE_DAYS=7 → no rotate
#   TC3 — stale event (mtime 8d ago) + ROTATE_DAYS=7 → rotated to archive/
#   TC4 — old archive (mtime 31d ago) + PURGE_DAYS=30 → purged
#   TC5 — oversized event (env override LEARNING_MAX_FILE_BYTES=10) → size_warn=1
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../learning-queue-sweeper.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

EVENTS_DIR="$TEMPDIR/agent-workspace/learning-data/events"
ARCHIVE_DIR="$TEMPDIR/agent-workspace/learning-data/archive"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$EVENTS_DIR" "$ARCHIVE_DIR" "$MEM_DIR"
}

# Poll log for pattern (subshell is backgrounded + disowned; needs grace period).
# Returns 0 when pattern found within timeout, 1 otherwise.
poll_log() {
  local pattern="$1"
  local timeout="${2:-6}"
  local count=0
  while [ "$count" -lt "$timeout" ]; do
    if [ -f "$LOG" ] && grep -q "$pattern" "$LOG" 2>/dev/null; then
      return 0
    fi
    sleep 1
    count=$(( count + 1 ))
  done
  return 1
}

# --- TC1: empty EVENTS_DIR + ARCHIVE_DIR → rotated=0 purged=0 size_warn=0 ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "rotated=0 purged=0 size_warn=0" 6; then
  echo "FAIL TC1: log should record rotated=0 purged=0 size_warn=0 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC1: empty dirs → rotated=0 purged=0 size_warn=0"

# --- TC2: fresh event (mtime now) + ROTATE_DAYS=7 → no rotate ---
clean_state
echo '{"event":"foo"}' > "$EVENTS_DIR/fresh.ndjson"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "rotated=0 purged=0" 6; then
  echo "FAIL TC2: log should record rotated=0 purged=0 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
sleep 1
if [ ! -f "$EVENTS_DIR/fresh.ndjson" ]; then
  echo "FAIL TC2: fresh event should remain in events/"
  exit 1
fi
echo "PASS TC2: fresh event → no rotate"

# --- TC3: stale event (mtime 8d ago) → rotated to archive/ ---
clean_state
echo '{"event":"old"}' > "$EVENTS_DIR/stale.ndjson"
touch -d "8 days ago" "$EVENTS_DIR/stale.ndjson" 2>/dev/null || touch -t "$(date -v-8d +%Y%m%d%H%M)" "$EVENTS_DIR/stale.ndjson"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "rotated=1" 6; then
  echo "FAIL TC3: log should record rotated=1 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
sleep 1
if [ -f "$EVENTS_DIR/stale.ndjson" ]; then
  echo "FAIL TC3: stale event should be moved out of events/"
  exit 1
fi
if [ ! -f "$ARCHIVE_DIR/stale.ndjson" ]; then
  echo "FAIL TC3: stale event should now be in archive/"
  ls -la "$ARCHIVE_DIR/" 2>/dev/null
  exit 1
fi
echo "PASS TC3: stale event (8d) → rotated to archive/"

# --- TC4: old archive (mtime 31d ago) + PURGE_DAYS=30 → purged ---
clean_state
echo '{"event":"ancient"}' > "$ARCHIVE_DIR/ancient.ndjson"
touch -d "31 days ago" "$ARCHIVE_DIR/ancient.ndjson" 2>/dev/null || touch -t "$(date -v-31d +%Y%m%d%H%M)" "$ARCHIVE_DIR/ancient.ndjson"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "purged=1" 6; then
  echo "FAIL TC4: log should record purged=1 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
sleep 1
if [ -f "$ARCHIVE_DIR/ancient.ndjson" ]; then
  echo "FAIL TC4: ancient archive should be purged"
  exit 1
fi
echo "PASS TC4: old archive (31d) → purged"

# --- TC5: oversized event with env override LEARNING_MAX_FILE_BYTES=10 → size_warn=1 ---
clean_state
echo '{"event":"large_payload_exceeding_threshold"}' > "$EVENTS_DIR/big.ndjson"
RC=0
LEARNING_MAX_FILE_BYTES=10 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "size_warn=1" 6; then
  echo "FAIL TC5: log should record size_warn=1 with LEARNING_MAX_FILE_BYTES=10"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC5: file > 10 bytes (env override) → size_warn=1"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "learning-queue-sweeper.sh externally-observable behavior verified."
exit 0
