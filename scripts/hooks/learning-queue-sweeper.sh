#!/usr/bin/env bash
# learning-queue-sweeper.sh — rotate aged events to archive/; purge old archives.
# Wired as SessionStart in .claude/settings.json. Async; fail-silent; non-blocking.
# Track 5.5d.2 D-005. Boundary: writes to learning-data/{events,archive}/ only;
# whitelisted in drift-signals-D1-D9.sh D9 LEARNING_WRITE_HOOKS regex.
# Patterns: if/then/fi + split-local per L-S10-1 lesson (no [ x ] && Y).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EVENTS_DIR="$PROJECT_DIR/agent-workspace/learning-data/events"
ARCHIVE_DIR="$PROJECT_DIR/agent-workspace/learning-data/archive"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

ROTATE_DAYS="${LEARNING_ROTATE_DAYS:-7}"
PURGE_DAYS="${LEARNING_PURGE_DAYS:-30}"
MAX_FILE_BYTES="${LEARNING_MAX_FILE_BYTES:-10485760}"

mkdir -p "$ARCHIVE_DIR" 2>/dev/null || true
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

(
ROTATED=0
PURGED=0
SIZE_WARN=0

if [ -d "$EVENTS_DIR" ]; then
  while IFS= read -r -d '' file; do
    bn="$(basename "$file")"
    if mv "$file" "$ARCHIVE_DIR/$bn" 2>/dev/null; then
      ROTATED=$(( ROTATED + 1 ))
    fi
  done < <(find "$EVENTS_DIR" -name '*.ndjson' -type f -mtime "+$ROTATE_DAYS" -print0 2>/dev/null)
fi

if [ -d "$ARCHIVE_DIR" ]; then
  while IFS= read -r -d '' file; do
    if rm -f "$file" 2>/dev/null; then
      PURGED=$(( PURGED + 1 ))
    fi
  done < <(find "$ARCHIVE_DIR" -name '*.ndjson' -type f -mtime "+$PURGE_DAYS" -print0 2>/dev/null)
fi

if [ -d "$EVENTS_DIR" ]; then
  while IFS= read -r -d '' file; do
    fsize=0
    fsize="$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)"
    if [[ ! "$fsize" =~ ^[0-9]+$ ]]; then
      fsize=0
    fi
    if [ "$fsize" -gt "$MAX_FILE_BYTES" ]; then
      SIZE_WARN=$(( SIZE_WARN + 1 ))
    fi
  done < <(find "$EVENTS_DIR" -name '*.ndjson' -type f -print0 2>/dev/null)
fi

printf '[%s] learning-queue-sweeper rotated=%d purged=%d size_warn=%d rotate_days=%d purge_days=%d\n' \
  "$TS" "$ROTATED" "$PURGED" "$SIZE_WARN" "$ROTATE_DAYS" "$PURGE_DAYS" >> "$LOG"
) </dev/null >/dev/null 2>&1 &

disown 2>/dev/null || true
exit 0
