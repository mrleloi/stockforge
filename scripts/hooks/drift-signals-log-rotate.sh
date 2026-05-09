#!/usr/bin/env bash
# drift-signals-log-rotate.sh — weekly rotation for .drift-signals.log (S105 backlog).
#
# Purpose: rotate agent-workspace/memory/.drift-signals.log weekly; retain 4 weeks
# of compressed archives; delete older archives. Eliminates the staleness pattern
# diagnosed at S105 (33 stale D9 entries on metric-failure-mode-rate.sh appearing as
# false-alarm HIGH-severity in 2026-05-06-rollup.md after whitelist update at line 148
# of drift-signals-D1-D9.sh; live re-run produced zero hits but log retained history).
#
# Wires: Stop hook in .claude/settings.json AFTER drift-rollup-daily.sh.
# Order matters: drift-rollup-daily reads today's entries from the full log first;
# this rotation truncates AFTER. Same-day rotate-before-rollup would zero today's rollup.
#
# Soft-warn only (exit 0 always; never blocks).
# Trigger logic: idempotent week-based marker file. First Stop event of a new ISO week
# rotates the file; subsequent Stops in the same week skip.
#
# Mirrors telemetry-rotate.sh (S99 RCA Layer 1 / Q-RCA-6 = A) — same pattern, different
# source/archive paths and a smaller size threshold (drift-signals.log line-based, grows
# slower than telemetry.jsonl).
#
# Per L-S10-1: split-local; if/then/fi only.
# Per L-S53-2: idempotency advances per Stop-event, not per-SessionStart-tick.
# Per L-S69-1: artifact-verifier whitelist — this hook writes archive files (.gz);
#              not a target for verifier.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
MARKER="$MEM_DIR/.drift-signals-last-rotate-week"
DRIFT_FILE="$MEM_DIR/.drift-signals.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# Skip if drift signals log doesn't exist yet
if [ ! -f "$DRIFT_FILE" ]; then
  printf '[%s] drift-signals-log-rotate: skip (no .drift-signals.log)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Determine current ISO week (YYYY-WNN format)
CURRENT_WEEK="$(date -u +%G-W%V 2>/dev/null)"
if [ -z "$CURRENT_WEEK" ]; then
  printf '[%s] drift-signals-log-rotate: skip (cannot determine ISO week)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Read last-rotation week marker
LAST_WEEK=""
if [ -f "$MARKER" ]; then
  LAST_WEEK="$(cat "$MARKER" 2>/dev/null)"
fi

# Skip if already rotated this week
if [ "$CURRENT_WEEK" = "$LAST_WEEK" ]; then
  printf '[%s] drift-signals-log-rotate: skip (already rotated week %s)\n' "$TS" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  exit 0
fi

# Skip rotation if file is small (< 50 KB) — drift-signals grows slower than telemetry,
# so smaller threshold is appropriate. At ~500 lines/day, a week of clean drift = ~3500
# lines which is typically 200-400 KB; a week of a quiet repo could be smaller. Threshold
# 50 KB avoids needless gzip/truncate cycles on low-activity weeks while still catching
# the staleness-accumulation pattern that motivated this hook.
DRIFT_BYTES=$(stat -c %s "$DRIFT_FILE" 2>/dev/null || stat -f %z "$DRIFT_FILE" 2>/dev/null)
DRIFT_BYTES="${DRIFT_BYTES:-0}"
if [ "$DRIFT_BYTES" -lt 51200 ]; then
  # Update marker anyway so we don't re-check until next week
  printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
  printf '[%s] drift-signals-log-rotate: skip (size %s < 50KB; marker advanced to %s)\n' "$TS" "$DRIFT_BYTES" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  exit 0
fi

# Compute previous ISO week label for archive name
PREV_WEEK=""
if [ -n "$LAST_WEEK" ]; then
  PREV_WEEK="$LAST_WEEK"
else
  # First-ever rotation: use current-week minus 1 (best-effort label)
  PREV_WEEK="$(date -u -d 'last week' +%G-W%V 2>/dev/null)"
  PREV_WEEK="${PREV_WEEK:-unknown-week}"
fi

ARCHIVE_DIR="$MEM_DIR/drift-signals-archive"
mkdir -p "$ARCHIVE_DIR" 2>/dev/null || true
ARCHIVE_FILE="$ARCHIVE_DIR/drift-signals.${PREV_WEEK}.log.gz"

# Compress + truncate atomically
if command -v gzip >/dev/null 2>&1; then
  if gzip -c "$DRIFT_FILE" > "$ARCHIVE_FILE" 2>/dev/null; then
    : > "$DRIFT_FILE"  # truncate
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] drift-signals-log-rotate: archived to %s; truncated %s; marker -> %s\n' \
      "$TS" "$ARCHIVE_FILE" "$DRIFT_FILE" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  else
    printf '[%s] drift-signals-log-rotate: gzip failed; abort\n' "$TS" >> "$LOG" 2>/dev/null
    exit 0
  fi
else
  # No gzip — fall back to plain copy + truncate
  if cp "$DRIFT_FILE" "${ARCHIVE_FILE%.gz}" 2>/dev/null; then
    : > "$DRIFT_FILE"
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] drift-signals-log-rotate: no-gzip fallback; copied to %s; marker -> %s\n' \
      "$TS" "${ARCHIVE_FILE%.gz}" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  fi
fi

# Cleanup: delete archives older than 4 weeks (28 days)
if command -v find >/dev/null 2>&1; then
  if [ -d "$ARCHIVE_DIR" ]; then
    DELETED=0
    while IFS= read -r OLD_FILE; do
      if [ -f "$OLD_FILE" ]; then
        rm -f "$OLD_FILE" 2>/dev/null && DELETED=$((DELETED + 1))
      fi
    done < <(find "$ARCHIVE_DIR" -type f -name 'drift-signals.*' -mtime +28 2>/dev/null)
    if [ "$DELETED" -gt 0 ]; then
      printf '[%s] drift-signals-log-rotate: cleaned %d archive(s) older than 28 days\n' "$TS" "$DELETED" >> "$LOG" 2>/dev/null
    fi
  fi
fi

exit 0
