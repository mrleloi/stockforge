#!/usr/bin/env bash
# Firing-test for session-hooks-log-rotate.sh (S317 harness recovery; mass-deletion re-author).
#
# Hook purpose: weekly rotation of agent-workspace/memory/.session-hooks.log.
# When a new ISO week starts and the log is >= 128KB, gzip-archive it to
# session-hooks-archive/, truncate the log, advance the week marker; prune
# archives older than 28 days.
#
# 5 test cases:
#   TC1 — log absent → silent, no crash, no archive
#   TC2 — log small (< 128KB), no marker → skip + marker advanced, no archive
#   TC3 — log large (>= 128KB), no marker → rotated: .gz archive + log truncated
#   TC4 — marker == current ISO week → skip (already rotated this week)
#   TC5 — archive older than 28 days → pruned on a rotation run
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../session-hooks-log-rotate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
MARKER="$MEM_DIR/.session-hooks-last-rotate-week"
ARCHIVE_DIR="$MEM_DIR/session-hooks-archive"
CURRENT_WEEK="$(date -u +%G-W%V)"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

# helper: write a .session-hooks.log >= 128KB (3000 lines ~ 230KB)
make_large_log() {
  : > "$LOG"
  i=0
  while [ "$i" -lt 3000 ]; do
    echo "[2026-05-14T00:00:00+00:00] Stop session=test hook activity padding line number $i" >> "$LOG"
    i=$((i + 1))
  done
}

# --- TC1: log absent → silent, no crash ---
clean_state
run_hook
if [ -d "$ARCHIVE_DIR" ] && ls "$ARCHIVE_DIR"/*.gz >/dev/null 2>&1; then
  echo "FAIL TC1: no archive should be produced when log is absent"
  exit 1
fi
echo "PASS TC1: log absent → silent, no archive"

# --- TC2: small log, no marker → skip + marker advanced ---
clean_state
echo "[ts] Stop tiny log" > "$LOG"
run_hook
if [ -d "$ARCHIVE_DIR" ] && ls "$ARCHIVE_DIR"/*.gz >/dev/null 2>&1; then
  echo "FAIL TC2: small log should NOT be archived"
  exit 1
fi
if [ "$(cat "$MARKER" 2>/dev/null)" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC2: marker should be advanced to current week even on size-skip"
  echo "marker=$(cat "$MARKER" 2>/dev/null) expected=$CURRENT_WEEK"
  exit 1
fi
echo "PASS TC2: small log → skip + marker advanced"

# --- TC3: large log, no marker → rotate ---
# NOTE: assertions avoid `cmd | grep -q` / `ls | head` pipelines — under
# `set -o pipefail` the upstream cmd gets SIGPIPE when grep/head closes the pipe
# early, making the pipeline intermittently "fail". Use glob loops + decompress-
# to-file instead.
clean_state
make_large_log
MARKER_LINE="hook activity padding line number 1500"
run_hook
GZ=""
for f in "$ARCHIVE_DIR"/session-hooks.*.log.gz; do
  [ -f "$f" ] && { GZ="$f"; break; }
done
if [ -z "$GZ" ]; then
  echo "FAIL TC3: expected a .gz archive in $ARCHIVE_DIR"
  ls -la "$ARCHIVE_DIR" 2>/dev/null || echo "(no archive dir)"
  exit 1
fi
gzip -dc "$GZ" > "$TEMPDIR/_tc3_decompressed.log" 2>/dev/null || true
if ! grep -qF "$MARKER_LINE" "$TEMPDIR/_tc3_decompressed.log"; then
  echo "FAIL TC3: archive should contain the rotated log content"
  exit 1
fi
if grep -qF "$MARKER_LINE" "$LOG"; then
  echo "FAIL TC3: .session-hooks.log should be truncated (old content gone)"
  exit 1
fi
if [ "$(cat "$MARKER" 2>/dev/null)" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC3: marker should be set to current week after rotation"
  exit 1
fi
echo "PASS TC3: large log → .gz archived + log truncated + marker set"

# --- TC4: marker == current week → skip ---
clean_state
make_large_log
printf '%s' "$CURRENT_WEEK" > "$MARKER"
run_hook
if [ -d "$ARCHIVE_DIR" ] && ls "$ARCHIVE_DIR"/*.gz >/dev/null 2>&1; then
  echo "FAIL TC4: should skip when already rotated this week (marker == current week)"
  exit 1
fi
echo "PASS TC4: marker == current week → skip"

# --- TC5: archive older than 28 days → pruned ---
clean_state
make_large_log
mkdir -p "$ARCHIVE_DIR"
OLD_ARCHIVE="$ARCHIVE_DIR/session-hooks.2000-W01.log.gz"
echo "ancient" | gzip -c > "$OLD_ARCHIVE" 2>/dev/null || echo "ancient" > "$OLD_ARCHIVE"
touch -t 200001010000.00 "$OLD_ARCHIVE" 2>/dev/null || touch -d "2000-01-01" "$OLD_ARCHIVE" 2>/dev/null || true
run_hook
if [ -f "$OLD_ARCHIVE" ]; then
  echo "FAIL TC5: archive older than 28 days should have been pruned"
  exit 1
fi
echo "PASS TC5: archive older than 28 days → pruned"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "session-hooks-log-rotate.sh externally-observable behavior verified."
exit 0
