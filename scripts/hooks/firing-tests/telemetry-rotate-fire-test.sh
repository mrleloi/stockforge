#!/usr/bin/env bash
# Firing-test for telemetry-rotate.sh (S99 RCA Layer 1; S100 firing-test backfill per T7 hard rule #2).
#
# Hook purpose (Stop hook, weekly idempotent rotation):
#   - skip if component-telemetry.jsonl missing
#   - skip if already rotated this week (marker matches CURRENT_WEEK)
#   - skip if size < 100KB (advance marker anyway)
#   - else: gzip → archive dir, truncate live file, advance marker, cleanup archives older than 28 days
#   - exit 0 always
#
# Test cases:
#   TC1 — TEL_FILE missing → log "skip (no component-telemetry.jsonl)", no archive
#   TC2 — TEL_FILE present, marker == current ISO week → log "skip (already rotated)"
#   TC3 — TEL_FILE present, marker stale, size < 100KB → marker advance, no archive, log "skip (size ... < 100KB)"
#   TC4 — TEL_FILE present, marker stale, size >= 100KB → archive .gz exists, live file truncated, marker advanced
#   TC5 — first-ever rotation (no marker) + size >= 100KB → archive created with PREV_WEEK label
#   TC6 — old archive (mtime > 28d) gets cleaned during rotation
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../telemetry-rotate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: gzip required for the rotation tests
if ! command -v gzip >/dev/null 2>&1; then
  echo "SKIP: gzip not available; telemetry-rotate.sh requires gzip for archive"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
TEL_FILE="$MEM_DIR/component-telemetry.jsonl"
MARKER="$MEM_DIR/.telemetry-last-rotate-week"
ARCHIVE_DIR="$MEM_DIR/telemetry-archive"
CURRENT_WEEK="$(date -u +%G-W%V)"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1
}

# --- TC1: TEL_FILE missing → skip ---
clean_state
run_hook
if ! grep -q "skip (no component-telemetry.jsonl)" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: log should mention 'skip (no component-telemetry.jsonl)'"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if [ -d "$ARCHIVE_DIR" ]; then
  echo "FAIL TC1: archive dir should NOT be created when TEL_FILE missing"
  exit 1
fi
echo "PASS TC1: missing TEL_FILE → skip"

# --- TC2: marker == current week → skip ---
clean_state
: > "$TEL_FILE"
printf '%s' "$CURRENT_WEEK" > "$MARKER"
run_hook
if ! grep -q "skip (already rotated week $CURRENT_WEEK)" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: log should mention 'skip (already rotated week $CURRENT_WEEK)'"
  cat "$LOG"
  exit 1
fi
if [ -d "$ARCHIVE_DIR" ]; then
  echo "FAIL TC2: archive dir should NOT exist when already rotated"
  exit 1
fi
echo "PASS TC2: marker == current week → skip"

# --- TC3: marker stale, size < 100KB → marker advance, no archive ---
clean_state
printf 'small content\n' > "$TEL_FILE"
printf '2025-W01' > "$MARKER"
run_hook
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC3: marker should advance to $CURRENT_WEEK; got '$NEW_MARKER'"
  exit 1
fi
if [ -d "$ARCHIVE_DIR" ] && [ -n "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)" ]; then
  echo "FAIL TC3: archive should be empty for size < 100KB"
  ls -la "$ARCHIVE_DIR"
  exit 1
fi
if ! grep -q "skip (size " "$LOG" 2>/dev/null; then
  echo "FAIL TC3: log should mention 'skip (size ... < 100KB)'"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: marker stale + size < 100KB → marker advance, no archive"

# --- TC4: marker stale + size >= 100KB → archive + truncate + marker advance ---
clean_state
head -c 200000 /dev/zero > "$TEL_FILE" 2>/dev/null
printf '2025-W01' > "$MARKER"
PRE_SIZE=$(stat -c %s "$TEL_FILE" 2>/dev/null || stat -f %z "$TEL_FILE")
if [ "$PRE_SIZE" -lt 100000 ]; then
  echo "FAIL TC4 setup: pre-rotation size should be ≥100KB; got $PRE_SIZE"
  exit 1
fi
run_hook
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'component-telemetry.*.jsonl.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${ARCHIVE_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC4: ≥1 .gz archive expected; got $ARCHIVE_COUNT"
  ls -la "$ARCHIVE_DIR" 2>/dev/null
  exit 1
fi
POST_SIZE=$(stat -c %s "$TEL_FILE" 2>/dev/null || stat -f %z "$TEL_FILE")
if [ "${POST_SIZE:-99}" -ne 0 ]; then
  echo "FAIL TC4: live TEL_FILE should be truncated to 0 bytes; got $POST_SIZE"
  exit 1
fi
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC4: marker should advance to $CURRENT_WEEK; got '$NEW_MARKER'"
  exit 1
fi
echo "PASS TC4: marker stale + size ≥ 100KB → archived + truncated + marker advanced"

# --- TC5: first-ever rotation (no marker) + size >= 100KB → archive created ---
clean_state
head -c 200000 /dev/zero > "$TEL_FILE" 2>/dev/null
# No MARKER file
run_hook
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'component-telemetry.*.jsonl.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${ARCHIVE_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC5: ≥1 .gz archive expected on first rotation; got $ARCHIVE_COUNT"
  exit 1
fi
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC5: marker should be created with current week; got '$NEW_MARKER'"
  exit 1
fi
echo "PASS TC5: first-ever rotation → archive + marker created"

# --- TC6: old archive (mtime > 28 days) cleaned during rotation ---
clean_state
head -c 200000 /dev/zero > "$TEL_FILE" 2>/dev/null
printf '2025-W01' > "$MARKER"
mkdir -p "$ARCHIVE_DIR"
OLD_ARCHIVE="$ARCHIVE_DIR/component-telemetry.2024-W01.jsonl.gz"
echo "old data" | gzip > "$OLD_ARCHIVE" 2>/dev/null
# Backdate mtime to 30 days ago (cross-platform attempt)
if touch -d '30 days ago' "$OLD_ARCHIVE" 2>/dev/null; then
  :
elif touch -t "$(date -v-30d +%Y%m%d0000 2>/dev/null)" "$OLD_ARCHIVE" 2>/dev/null; then
  :
else
  echo "SKIP TC6: cannot backdate mtime on this platform"
  echo "ALL PASS (5/6 TC6 skipped)"
  exit 0
fi
run_hook
if [ -f "$OLD_ARCHIVE" ]; then
  echo "FAIL TC6: old archive (>28d) should be deleted"
  ls -la "$ARCHIVE_DIR"
  exit 1
fi
NEW_ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'component-telemetry.*.jsonl.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${NEW_ARCHIVE_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC6: new rotation archive should still exist after old cleanup"
  exit 1
fi
echo "PASS TC6: old archive (>28d) cleaned during rotation"

echo "ALL PASS (6/6)"
exit 0
