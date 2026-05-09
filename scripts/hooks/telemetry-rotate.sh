#!/usr/bin/env bash
# telemetry-rotate.sh — weekly rotation for component-telemetry.jsonl (S99 RCA Layer 1 / Q-RCA-6 = A)
#
# Purpose: rotate component-telemetry.jsonl weekly; retain 4 weeks of compressed archives;
# delete older archives. Per RCA-2026-05-06-S98 user pick Q-RCA-6 = A.
#
# Wires: Stop hook in .claude/settings.json. Soft-warn only (exit 0 always; never blocks).
# Trigger logic: idempotent week-based marker file. First Stop event of a new ISO week
# rotates the file; subsequent Stops in the same week skip.
#
# Per L-S10-1: split-local; if/then/fi only.
# Per L-S53-2: idempotency must advance per Stop-event, not per-SessionStart-tick (used here:
#   marker advances on first rotation in week; subsequent same-week Stops skip).
# Per L-S69-1: artifact-verifier whitelist — this hook writes archive files (.gz); not a target.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
MARKER="$MEM_DIR/.telemetry-last-rotate-week"
TEL_FILE="$MEM_DIR/component-telemetry.jsonl"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# Skip if telemetry file doesn't exist yet
if [ ! -f "$TEL_FILE" ]; then
  printf '[%s] telemetry-rotate: skip (no component-telemetry.jsonl)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Determine current ISO week (YYYY-WNN format)
CURRENT_WEEK="$(date -u +%G-W%V 2>/dev/null)"
if [ -z "$CURRENT_WEEK" ]; then
  printf '[%s] telemetry-rotate: skip (cannot determine ISO week)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Read last-rotation week marker
LAST_WEEK=""
if [ -f "$MARKER" ]; then
  LAST_WEEK="$(cat "$MARKER" 2>/dev/null)"
fi

# Skip if already rotated this week
if [ "$CURRENT_WEEK" = "$LAST_WEEK" ]; then
  printf '[%s] telemetry-rotate: skip (already rotated week %s)\n' "$TS" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  exit 0
fi

# Skip rotation if file is small (< 100 KB) — no need to rotate weekly when tiny
TEL_BYTES=$(stat -c %s "$TEL_FILE" 2>/dev/null || stat -f %z "$TEL_FILE" 2>/dev/null)
TEL_BYTES="${TEL_BYTES:-0}"
if [ "$TEL_BYTES" -lt 102400 ]; then
  # Update marker anyway so we don't re-check until next week
  printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
  printf '[%s] telemetry-rotate: skip (size %s < 100KB; marker advanced to %s)\n' "$TS" "$TEL_BYTES" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
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

ARCHIVE_DIR="$MEM_DIR/telemetry-archive"
mkdir -p "$ARCHIVE_DIR" 2>/dev/null || true
ARCHIVE_FILE="$ARCHIVE_DIR/component-telemetry.${PREV_WEEK}.jsonl.gz"

# Compress + truncate atomically
if command -v gzip >/dev/null 2>&1; then
  if gzip -c "$TEL_FILE" > "$ARCHIVE_FILE" 2>/dev/null; then
    : > "$TEL_FILE"  # truncate
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] telemetry-rotate: archived to %s; truncated %s; marker -> %s\n' \
      "$TS" "$ARCHIVE_FILE" "$TEL_FILE" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  else
    printf '[%s] telemetry-rotate: gzip failed; abort\n' "$TS" >> "$LOG" 2>/dev/null
    exit 0
  fi
else
  # No gzip — fall back to plain copy + truncate
  if cp "$TEL_FILE" "${ARCHIVE_FILE%.gz}" 2>/dev/null; then
    : > "$TEL_FILE"
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] telemetry-rotate: no-gzip fallback; copied to %s; marker -> %s\n' \
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
    done < <(find "$ARCHIVE_DIR" -type f -name 'component-telemetry.*' -mtime +28 2>/dev/null)
    if [ "$DELETED" -gt 0 ]; then
      printf '[%s] telemetry-rotate: cleaned %d archive(s) older than 28 days\n' "$TS" "$DELETED" >> "$LOG" 2>/dev/null
    fi
  fi
fi

exit 0
