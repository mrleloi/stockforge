#!/usr/bin/env bash
# session-hooks-log-rotate.sh — weekly rotation for .session-hooks.log.
#
# Purpose: rotate agent-workspace/memory/.session-hooks.log weekly; retain 4 weeks
# of compressed archives; delete older archives. .session-hooks.log accumulates one
# line per SessionStart/Stop/SessionEnd plus per-hook activity entries and grows
# unbounded otherwise (observed 708 KB at S317 recovery).
#
# Spec: mirrors drift-signals-log-rotate.sh / telemetry-rotate.sh (S99 RCA Layer 1
# pattern). Referenced in .claude/settings.json Stop chain but never committed —
# S310-S316 mass-deletion recovery re-author.
#
# NOTE: the file this hook rotates IS the file every hook (incl. this one) logs to.
# Intentional and safe: gzip reads the full file first, then truncate, then the
# rotation-status line becomes the first line of the fresh log.
#
# Wires: Stop hook in .claude/settings.json. Order-independent within the Stop
# chain (unlike drift-signals-log-rotate, which must follow drift-rollup-daily).
#
# Soft-warn only (exit 0 always; never blocks).
# Trigger logic: idempotent week-based marker. First Stop of a new ISO week
# rotates; subsequent Stops in the same week skip.
#
# Per L-S10-1: split-local; if/then/fi only.
# Per L-S53-2: idempotency advances per Stop-event, not per-SessionStart-tick.
# Per L-S69-1: artifact-verifier whitelist — this hook writes archive files (.gz).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
MARKER="$MEM_DIR/.session-hooks-last-rotate-week"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# Skip if the log doesn't exist yet (nothing to rotate, nothing to log to)
if [ ! -f "$LOG" ]; then
  exit 0
fi

# Determine current ISO week (YYYY-WNN)
CURRENT_WEEK="$(date -u +%G-W%V 2>/dev/null)"
if [ -z "$CURRENT_WEEK" ]; then
  printf '[%s] session-hooks-log-rotate: skip (cannot determine ISO week)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Read last-rotation week marker
LAST_WEEK=""
if [ -f "$MARKER" ]; then
  LAST_WEEK="$(cat "$MARKER" 2>/dev/null)"
fi

# Skip if already rotated this week
if [ "$CURRENT_WEEK" = "$LAST_WEEK" ]; then
  printf '[%s] session-hooks-log-rotate: skip (already rotated week %s)\n' "$TS" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  exit 0
fi

# Skip rotation if file is small (< 128 KB). .session-hooks.log grows fast (one
# line per hook per Stop), so a modest threshold still rotates most weeks while
# avoiding needless gzip cycles on low-activity weeks.
LOG_BYTES=$(stat -c %s "$LOG" 2>/dev/null || stat -f %z "$LOG" 2>/dev/null)
LOG_BYTES="${LOG_BYTES:-0}"
if [ "$LOG_BYTES" -lt 131072 ]; then
  # Advance the marker anyway so we don't re-check until next week.
  printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
  printf '[%s] session-hooks-log-rotate: skip (size %s < 128KB; marker advanced to %s)\n' "$TS" "$LOG_BYTES" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  exit 0
fi

# Compute previous ISO week label for the archive name
PREV_WEEK=""
if [ -n "$LAST_WEEK" ]; then
  PREV_WEEK="$LAST_WEEK"
else
  # First-ever rotation: use current-week minus 1 (best-effort label)
  PREV_WEEK="$(date -u -d 'last week' +%G-W%V 2>/dev/null)"
  PREV_WEEK="${PREV_WEEK:-unknown-week}"
fi

ARCHIVE_DIR="$MEM_DIR/session-hooks-archive"
mkdir -p "$ARCHIVE_DIR" 2>/dev/null || true
ARCHIVE_FILE="$ARCHIVE_DIR/session-hooks.${PREV_WEEK}.log.gz"

# Compress + truncate. gzip reads the full file first, so truncation after is safe.
if command -v gzip >/dev/null 2>&1; then
  if gzip -c "$LOG" > "$ARCHIVE_FILE" 2>/dev/null; then
    : > "$LOG"  # truncate
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] session-hooks-log-rotate: archived %s bytes -> %s; truncated; marker -> %s\n' \
      "$TS" "$LOG_BYTES" "$ARCHIVE_FILE" "$CURRENT_WEEK" >> "$LOG" 2>/dev/null
  else
    printf '[%s] session-hooks-log-rotate: gzip failed; abort\n' "$TS" >> "$LOG" 2>/dev/null
    exit 0
  fi
else
  # No gzip — fall back to plain copy + truncate
  if cp "$LOG" "${ARCHIVE_FILE%.gz}" 2>/dev/null; then
    : > "$LOG"
    printf '%s' "$CURRENT_WEEK" > "$MARKER" 2>/dev/null
    printf '[%s] session-hooks-log-rotate: no-gzip fallback; copied -> %s; marker -> %s\n' \
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
    done < <(find "$ARCHIVE_DIR" -type f -name 'session-hooks.*' -mtime +28 2>/dev/null)
    if [ "$DELETED" -gt 0 ]; then
      printf '[%s] session-hooks-log-rotate: cleaned %d archive(s) older than 28 days\n' "$TS" "$DELETED" >> "$LOG" 2>/dev/null
    fi
  fi
fi

exit 0
