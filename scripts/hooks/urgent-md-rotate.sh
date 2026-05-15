#!/usr/bin/env bash
# urgent-md-rotate.sh — Stop hook: size-triggered rotation of the URGENT notifications stream.
#
# When human-workspace/notifications/urgent.md exceeds 4096 bytes, the current
# content (header + all entries) is archived to urgent-archived-YYYY-MM-DD.md
# (appended if a same-day archive already exists) and urgent.md is reset to a
# fresh header.
#
# Spec recovered from urgent.md header text + observed urgent-archived-*.md files
# (S310-S316 mass-deletion recovery: this script was referenced in .claude/
# settings.json but never committed). Archives are plain markdown — human-facing
# audit trail, deliberately NOT gzipped and NOT auto-pruned (human decides
# retention, unlike the machine logs handled by telemetry-rotate.sh).
#
# Wires: Stop hook in .claude/settings.json.
# Non-blocking: exit 0 always (trap ERR -> exit 0).
# Idempotent by construction: post-rotation urgent.md is tiny -> next Stop skips.
#
# Per L-S10-1: split-local; if/then/fi only.
# Per L-S11-1: bash + POSIX tools only.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
URGENT="$NOTIF_DIR/urgent.md"
THRESHOLD=4096
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# Skip if urgent.md doesn't exist yet
if [ ! -f "$URGENT" ]; then
  printf '[%s] urgent-md-rotate: skip (no urgent.md)\n' "$TS" >> "$LOG" 2>/dev/null
  exit 0
fi

# Size check (portable: GNU stat -c, BSD stat -f)
URGENT_BYTES=$(stat -c %s "$URGENT" 2>/dev/null || stat -f %z "$URGENT" 2>/dev/null)
URGENT_BYTES="${URGENT_BYTES:-0}"
if [ "$URGENT_BYTES" -le "$THRESHOLD" ]; then
  printf '[%s] urgent-md-rotate: skip (size %s <= %s)\n' "$TS" "$URGENT_BYTES" "$THRESHOLD" >> "$LOG" 2>/dev/null
  exit 0
fi

# Archive target — one file per rotation DATE; append if a same-day archive exists.
ROTATE_DATE="$(date +%Y-%m-%d 2>/dev/null || echo unknown-date)"
ARCHIVE="$NOTIF_DIR/urgent-archived-${ROTATE_DATE}.md"
ARCHIVE_BASE="$(basename "$ARCHIVE")"

# Step 1 (non-destructive first): copy/append current urgent.md into the archive.
# Order matters — write the archive BEFORE touching urgent.md. If the reset in
# Step 2 fails, content is duplicated (recoverable), never lost.
if [ -f "$ARCHIVE" ]; then
  if ! { printf '\n\n<!-- ===== appended by urgent-md-rotate.sh at %s ===== -->\n\n' "$TS"; cat "$URGENT"; } >> "$ARCHIVE" 2>/dev/null; then
    printf '[%s] urgent-md-rotate: ERROR appending to %s; abort (urgent.md untouched)\n' "$TS" "$ARCHIVE_BASE" >> "$LOG" 2>/dev/null
    exit 0
  fi
else
  if ! cp "$URGENT" "$ARCHIVE" 2>/dev/null; then
    printf '[%s] urgent-md-rotate: ERROR creating %s; abort (urgent.md untouched)\n' "$TS" "$ARCHIVE_BASE" >> "$LOG" 2>/dev/null
    exit 0
  fi
fi

# Step 2: reset urgent.md to a fresh header (only after archive write succeeded).
NEW_HEADER="# URGENT notifications stream

_Auto-rotated ${TS} — previous content archived to ${ARCHIVE_BASE} (${URGENT_BYTES} bytes)._

_Append-only stream; rotates when size > 4096 bytes via urgent-md-rotate.sh Stop hook._

---
"
if printf '%s' "$NEW_HEADER" > "$URGENT" 2>/dev/null; then
  printf '[%s] urgent-md-rotate: rotated %s bytes -> %s; urgent.md reset\n' "$TS" "$URGENT_BYTES" "$ARCHIVE_BASE" >> "$LOG" 2>/dev/null
else
  printf '[%s] urgent-md-rotate: WARN archive written but urgent.md reset failed\n' "$TS" >> "$LOG" 2>/dev/null
fi

exit 0
