#!/usr/bin/env bash
# Firing-test for drift-signals-log-rotate.sh (S106 ship per Phase 3.5 T7 hard rule #2).
#
# Hook purpose (Stop hook, weekly idempotent rotation):
#   - skip if .drift-signals.log missing
#   - skip if already rotated this week (marker matches CURRENT_WEEK)
#   - skip if size < 50KB (advance marker anyway)
#   - else: gzip → archive dir, truncate live file, advance marker, cleanup archives older than 28 days
#   - exit 0 always
#
# Test cases:
#   TC1 — DRIFT_FILE missing → log "skip (no .drift-signals.log)", no archive
#   TC2 — DRIFT_FILE present, marker == current ISO week → log "skip (already rotated)"
#   TC3 — DRIFT_FILE present, marker stale, size < 50KB → marker advance, no archive, log "skip (size ... < 50KB)"
#   TC4 — DRIFT_FILE present, marker stale, size >= 50KB → archive .gz exists, live file truncated, marker advanced
#   TC5 — first-ever rotation (no marker) + size >= 50KB → archive created with PREV_WEEK label
#   TC6 — old archive (mtime > 28d) gets cleaned during rotation
#   TC7 — exactly-50KB boundary (51199 = under threshold; 51200 = at threshold; strict <)
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../drift-signals-log-rotate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: gzip required for the rotation tests
if ! command -v gzip >/dev/null 2>&1; then
  echo "SKIP: gzip not available; drift-signals-log-rotate.sh requires gzip for archive"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
DRIFT_FILE="$MEM_DIR/.drift-signals.log"
MARKER="$MEM_DIR/.drift-signals-last-rotate-week"
ARCHIVE_DIR="$MEM_DIR/drift-signals-archive"
CURRENT_WEEK="$(date -u +%G-W%V)"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1
}

# --- TC1: DRIFT_FILE missing → skip ---
clean_state
run_hook
if ! grep -q "skip (no .drift-signals.log)" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: log should mention 'skip (no .drift-signals.log)'"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if [ -d "$ARCHIVE_DIR" ]; then
  echo "FAIL TC1: archive dir should NOT be created when DRIFT_FILE missing"
  exit 1
fi
echo "PASS TC1: missing DRIFT_FILE → skip"

# --- TC2: marker == current week → skip ---
clean_state
: > "$DRIFT_FILE"
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

# --- TC3: marker stale, size < 50KB → marker advance, no archive ---
clean_state
printf 'small content\n' > "$DRIFT_FILE"
printf '2025-W01' > "$MARKER"
run_hook
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC3: marker should advance to $CURRENT_WEEK; got '$NEW_MARKER'"
  exit 1
fi
if [ -d "$ARCHIVE_DIR" ] && [ -n "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)" ]; then
  echo "FAIL TC3: archive should be empty for size < 50KB"
  ls -la "$ARCHIVE_DIR"
  exit 1
fi
if ! grep -q "skip (size " "$LOG" 2>/dev/null; then
  echo "FAIL TC3: log should mention 'skip (size ... < 50KB)'"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: marker stale + size < 50KB → marker advance, no archive"

# --- TC4: marker stale + size >= 50KB → archive + truncate + marker advance ---
clean_state
head -c 100000 /dev/zero > "$DRIFT_FILE" 2>/dev/null
printf '2025-W01' > "$MARKER"
PRE_SIZE=$(stat -c %s "$DRIFT_FILE" 2>/dev/null || stat -f %z "$DRIFT_FILE")
if [ "$PRE_SIZE" -lt 50000 ]; then
  echo "FAIL TC4 setup: pre-rotation size should be ≥50KB; got $PRE_SIZE"
  exit 1
fi
run_hook
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'drift-signals.*.log.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${ARCHIVE_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC4: ≥1 .gz archive expected; got $ARCHIVE_COUNT"
  ls -la "$ARCHIVE_DIR" 2>/dev/null
  exit 1
fi
POST_SIZE=$(stat -c %s "$DRIFT_FILE" 2>/dev/null || stat -f %z "$DRIFT_FILE")
if [ "${POST_SIZE:-99}" -ne 0 ]; then
  echo "FAIL TC4: live DRIFT_FILE should be truncated to 0 bytes; got $POST_SIZE"
  exit 1
fi
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC4: marker should advance to $CURRENT_WEEK; got '$NEW_MARKER'"
  exit 1
fi
echo "PASS TC4: marker stale + size ≥ 50KB → archived + truncated + marker advanced"

# --- TC5: first-ever rotation (no marker) + size >= 50KB → archive created ---
clean_state
head -c 100000 /dev/zero > "$DRIFT_FILE" 2>/dev/null
# No MARKER file
run_hook
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'drift-signals.*.log.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
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
head -c 100000 /dev/zero > "$DRIFT_FILE" 2>/dev/null
printf '2025-W01' > "$MARKER"
mkdir -p "$ARCHIVE_DIR"
OLD_ARCHIVE="$ARCHIVE_DIR/drift-signals.2024-W01.log.gz"
echo "old data" | gzip > "$OLD_ARCHIVE" 2>/dev/null
# Backdate mtime to 30 days ago (cross-platform attempt)
if touch -d '30 days ago' "$OLD_ARCHIVE" 2>/dev/null; then
  :
elif touch -t "$(date -v-30d +%Y%m%d0000 2>/dev/null)" "$OLD_ARCHIVE" 2>/dev/null; then
  :
else
  echo "SKIP TC6: cannot backdate mtime on this platform"
  echo "TC6 SKIPPED — continuing"
  TC6_SKIPPED=1
fi
if [ -z "${TC6_SKIPPED:-}" ]; then
  run_hook
  if [ -f "$OLD_ARCHIVE" ]; then
    echo "FAIL TC6: old archive (>28d) should be deleted"
    ls -la "$ARCHIVE_DIR"
    exit 1
  fi
  NEW_ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'drift-signals.*.log.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
  if [ "${NEW_ARCHIVE_COUNT:-0}" -lt 1 ]; then
    echo "FAIL TC6: new rotation archive should still exist after old cleanup"
    exit 1
  fi
  echo "PASS TC6: old archive (>28d) cleaned during rotation"
fi

# --- TC7: boundary check — exactly 51199B (just under) vs 51200B (at threshold; strict <) ---
# 51199 should be SKIP (< 50KB); 51200 should ROTATE (>= 50KB; not < 50KB)
clean_state
head -c 51199 /dev/zero > "$DRIFT_FILE" 2>/dev/null
# No marker → first-ever; under threshold should still advance marker without archive
run_hook
if [ -d "$ARCHIVE_DIR" ] && [ -n "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)" ]; then
  echo "FAIL TC7a: 51199B should NOT trigger archive (< 50KB strict)"
  ls -la "$ARCHIVE_DIR"
  exit 1
fi
NEW_MARKER=$(cat "$MARKER" 2>/dev/null)
if [ "$NEW_MARKER" != "$CURRENT_WEEK" ]; then
  echo "FAIL TC7a: marker should advance to $CURRENT_WEEK even when skipping; got '$NEW_MARKER'"
  exit 1
fi
echo "PASS TC7a: 51199B (<50KB strict) → skip + marker advance"

clean_state
head -c 51200 /dev/zero > "$DRIFT_FILE" 2>/dev/null
# No marker → first-ever; at threshold should ROTATE
run_hook
ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name 'drift-signals.*.log.gz' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${ARCHIVE_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC7b: 51200B should trigger archive (≥ 50KB); got $ARCHIVE_COUNT archives"
  ls -la "$ARCHIVE_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC7b: 51200B (≥50KB) → archive created"

if [ -n "${TC6_SKIPPED:-}" ]; then
  echo "ALL PASS (6/7; TC6 skipped — platform cannot backdate mtime)"
else
  echo "ALL PASS (7/7)"
fi
exit 0
