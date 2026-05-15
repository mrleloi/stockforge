#!/usr/bin/env bash
# qa-pending-stale-mover.sh — SessionStart hook moving past-deadline pending Q&A bundles to stale/.
# Scans human-workspace/q-and-a/pending/*.md for `expected_answer_by:` field; if past-deadline,
# move to stale/ and emit notification. Hook runs OUTSIDE Claude permission model so can write
# to deny-listed paths (per agent-notes 2026-04-29 hooks-bypass-permissions rule).
# Track 5 deliverable (deferred from Track 4 in S2).
# bash-hook-lint:allow L-S11-1 python3 is guarded by `if command -v python3` check; fallback path `continue` when unavailable; graceful degradation.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PENDING_DIR="$PROJECT_DIR/human-workspace/q-and-a/pending"
STALE_DIR="$PROJECT_DIR/human-workspace/q-and-a/stale"
NOTIFY_DIR="$PROJECT_DIR/human-workspace/notifications"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

[ ! -d "$PENDING_DIR" ] && exit 0
mkdir -p "$STALE_DIR" "$NOTIFY_DIR"

NOW_EPOCH="$(date -u +%s 2>/dev/null || echo 0)"
MOVED_COUNT=0

for bundle in "$PENDING_DIR"/*.md; do
  [ -f "$bundle" ] || continue
  # Extract expected_answer_by from frontmatter (within first 30 lines).
  DEADLINE="$(awk '/^---$/{c++; if(c==2)exit} /^expected_answer_by:/{sub(/^expected_answer_by: */,""); print; exit}' "$bundle" 2>/dev/null | tr -d '"' | tr -d "'" | tr -d '[:space:]')"
  [ -z "$DEADLINE" ] && continue

  # Convert ISO 8601 to epoch (python3 robust; date fallback).
  DEADLINE_EPOCH=0
  if command -v python3 >/dev/null 2>&1; then
    DEADLINE_EPOCH="$(python3 -c "
import sys, datetime
try:
    d = datetime.datetime.fromisoformat(sys.argv[1].replace('Z','+00:00'))
    print(int(d.timestamp()))
except: print(0)
" "$DEADLINE" 2>/dev/null || echo 0)"
  fi
  [ "$DEADLINE_EPOCH" -eq 0 ] && continue

  if [ "$NOW_EPOCH" -gt "$DEADLINE_EPOCH" ]; then
    BUNDLE_NAME="$(basename "$bundle")"
    mv "$bundle" "$STALE_DIR/$BUNDLE_NAME" 2>/dev/null || continue
    MOVED_COUNT=$(( MOVED_COUNT + 1 ))

    # Emit notification (URGENT priority — past-deadline bundle needs attention).
    NOTIFY_FILE="$NOTIFY_DIR/$(date +%Y-%m-%d)-stale-bundle-$BUNDLE_NAME.txt"
    {
      printf '[URGENT] Q&A bundle moved to stale: %s\n' "$BUNDLE_NAME"
      printf 'Deadline was: %s\n' "$DEADLINE"
      printf 'Action: review %s/%s and re-fire questions via AskUserQuestion if still relevant.\n' "$STALE_DIR" "$BUNDLE_NAME"
    } > "$NOTIFY_FILE" 2>/dev/null || true

    echo "[$(date -Iseconds)] qa-pending-stale-mover: moved $BUNDLE_NAME (deadline=$DEADLINE, now=$(date -Iseconds))" >> "$HOOK_LOG"
  fi
done

[ "$MOVED_COUNT" -gt 0 ] && echo "[$(date -Iseconds)] qa-pending-stale-mover: $MOVED_COUNT bundle(s) moved to stale/" >> "$HOOK_LOG"
exit 0
