#!/usr/bin/env bash
# Firing-test for learning-index-rebuild.sh (L-S49b-4 charter-coverage push; S78).
#
# Hook purpose (Stop hook; runs in BACKGROUND subshell + disown per D-005 § 5.5d.2):
#   - Counts events across agent-workspace/learning-data/events/*.ndjson
#   - Reads prior count from index/.last-index-build.json
#   - SHOULD_REBUILD=1 if delta >= LEARNING_INDEX_N_EVENTS (default 100) OR LEARNING_INDEX_FORCE=1
#   - Else: log SKIP delta=N total=M threshold=K
#   - Rebuild path: writes manifest.json + recent-sample.ndjson + .last-index-build.json
#     then logs OK delta=N total=M sample_lines=L. If delta >= threshold AND NOTIF_DIR exists:
#     writes notification file to NOTIF_DIR.
#
# 5 test cases (uses poll loop because subshell is backgrounded with disown):
#   TC1 — no EVENTS_DIR → SHOULD_REBUILD=0; log SKIP delta=0 total=0
#   TC2 — fresh events under threshold (LEARNING_INDEX_N_EVENTS=100, 1 event) → SKIP
#   TC3 — events delta >= threshold (override LEARNING_INDEX_N_EVENTS=3, 5 events) → REBUILD
#         + manifest/sample/state written + notif written
#   TC4 — LEARNING_INDEX_FORCE=1 with no events → REBUILD; log OK delta=0 total=0; no notif
#   TC5 — prior state exists (events_at_build=10), current total=15, threshold=3 → REBUILD;
#         new state events_at_build=15
#
# Pre-flight: node availability (hook depends on node JSON parse for prior state).
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../learning-index-rebuild.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: node required for prior-state JSON parse.
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node unavailable; hook depends on node for prior-state JSON parse"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

EVENTS_DIR="$TEMPDIR/agent-workspace/learning-data/events"
INDEX_DIR="$TEMPDIR/agent-workspace/learning-data/index"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
STATE_FILE="$INDEX_DIR/.last-index-build.json"
MANIFEST="$INDEX_DIR/manifest.json"
SAMPLE="$INDEX_DIR/recent-sample.ndjson"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$NOTIF_DIR"
}

# Poll log for pattern (subshell is backgrounded + disowned; needs grace period).
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

# Poll for a file's existence.
poll_file() {
  local path="$1"
  local timeout="${2:-6}"
  local count=0
  while [ "$count" -lt "$timeout" ]; do
    if [ -f "$path" ]; then
      return 0
    fi
    sleep 1
    count=$(( count + 1 ))
  done
  return 1
}

# --- TC1: no EVENTS_DIR → SHOULD_REBUILD=0; log SKIP ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "learning-index-rebuild SKIP delta=0 total=0" 6; then
  echo "FAIL TC1: log should record SKIP delta=0 total=0 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
sleep 1
if [ -f "$MANIFEST" ]; then
  echo "FAIL TC1: manifest should not be written on SKIP path"
  exit 1
fi
echo "PASS TC1: no EVENTS_DIR → SKIP delta=0 total=0"

# --- TC2: 1 event + threshold=100 → SKIP ---
clean_state
mkdir -p "$EVENTS_DIR"
echo '{"event":"foo","ts":1}' > "$EVENTS_DIR/probe.ndjson"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "learning-index-rebuild SKIP delta=1 total=1 threshold=100" 6; then
  echo "FAIL TC2: log should record SKIP delta=1 total=1 threshold=100 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
sleep 1
if [ -f "$MANIFEST" ]; then
  echo "FAIL TC2: manifest should not be written on SKIP path (under threshold)"
  exit 1
fi
echo "PASS TC2: 1 event + threshold=100 → SKIP"

# --- TC3: 5 events + threshold=3 → REBUILD + manifest/sample/state + notif ---
clean_state
mkdir -p "$EVENTS_DIR"
{
  echo '{"event":"a","ts":1}'
  echo '{"event":"b","ts":2}'
  echo '{"event":"c","ts":3}'
} > "$EVENTS_DIR/file1.ndjson"
{
  echo '{"event":"d","ts":4}'
  echo '{"event":"e","ts":5}'
} > "$EVENTS_DIR/file2.ndjson"
RC=0
LEARNING_INDEX_N_EVENTS=3 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "learning-index-rebuild OK delta=5 total=5" 6; then
  echo "FAIL TC3: log should record OK delta=5 total=5 within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if ! poll_file "$MANIFEST" 6; then
  echo "FAIL TC3: manifest should be written within 6s"
  exit 1
fi
if ! poll_file "$SAMPLE" 6; then
  echo "FAIL TC3: sample should be written within 6s"
  exit 1
fi
if ! poll_file "$STATE_FILE" 6; then
  echo "FAIL TC3: state file should be written within 6s"
  exit 1
fi
if ! grep -q '"events_at_build":5' "$STATE_FILE"; then
  echo "FAIL TC3: state should record events_at_build=5"
  cat "$STATE_FILE"
  exit 1
fi
if ! grep -q '"total_events":5' "$MANIFEST"; then
  echo "FAIL TC3: manifest should record total_events=5"
  cat "$MANIFEST"
  exit 1
fi
# notif file written when delta >= threshold AND NOTIF_DIR exists
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name 'learning-analysis-ready.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -lt 1 ]; then
  echo "FAIL TC3: notification file should be written when delta >= threshold"
  ls -la "$NOTIF_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC3: 5 events + threshold=3 → REBUILD + manifest/sample/state + notif written"

# --- TC4: LEARNING_INDEX_FORCE=1 + no events → REBUILD; log OK delta=0 total=0; no notif ---
clean_state
mkdir -p "$EVENTS_DIR"
RC=0
LEARNING_INDEX_FORCE=1 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "learning-index-rebuild OK delta=0 total=0" 6; then
  echo "FAIL TC4: log should record OK delta=0 total=0 (force rebuild) within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if ! poll_file "$MANIFEST" 6; then
  echo "FAIL TC4: manifest should be written even on force+empty"
  exit 1
fi
if ! poll_file "$STATE_FILE" 6; then
  echo "FAIL TC4: state file should be written even on force+empty"
  exit 1
fi
if ! grep -q '"events_at_build":0' "$STATE_FILE"; then
  echo "FAIL TC4: state should record events_at_build=0"
  cat "$STATE_FILE"
  exit 1
fi
sleep 1
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name 'learning-analysis-ready.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -ne 0 ]; then
  echo "FAIL TC4: notif should NOT be written when delta < threshold (delta=0, threshold=100)"
  ls -la "$NOTIF_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC4: FORCE=1 + no events → REBUILD; OK delta=0 total=0; no notif"

# --- TC5: prior state events_at_build=10, current total=15, threshold=3 → REBUILD; new state=15 ---
clean_state
mkdir -p "$EVENTS_DIR" "$INDEX_DIR"
echo '{"as_of":"2026-01-01","events_at_build":10,"sample_lines":10}' > "$STATE_FILE"
{
  for i in $(seq 1 15); do
    echo "{\"event\":\"e$i\",\"ts\":$i}"
  done
} > "$EVENTS_DIR/file.ndjson"
RC=0
LEARNING_INDEX_N_EVENTS=3 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! poll_log "learning-index-rebuild OK delta=5 total=15" 6; then
  echo "FAIL TC5: log should record OK delta=5 total=15 (15-10=5) within 6s"
  cat "$LOG" 2>/dev/null
  exit 1
fi
# Wait for state file rewrite
sleep 2
if ! grep -q '"events_at_build":15' "$STATE_FILE"; then
  echo "FAIL TC5: state should be updated to events_at_build=15"
  cat "$STATE_FILE"
  exit 1
fi
echo "PASS TC5: prior state=10 + total=15 → REBUILD; new state=15"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "learning-index-rebuild.sh externally-observable behavior verified."
exit 0
