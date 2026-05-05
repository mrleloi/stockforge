#!/usr/bin/env bash
# qa-answered-detector.sh — SessionStart hook flagging newly-moved answered bundles.
# Detects bundles in human-workspace/q-and-a/answered/ with mtime > last-scan timestamp.
# Emits notification line in .session-hooks.log so agent reads them at SessionStart.
# Track 5 deliverable (deferred from Track 4 in S2).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
ANSWERED_DIR="$PROJECT_DIR/human-workspace/q-and-a/answered"
LAST_SCAN_FILE="$PROJECT_DIR/agent-workspace/memory/.qa-last-scan-ts"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
SYNC_HOOK="$PROJECT_DIR/scripts/hooks/sync-tracker-update.sh"

[ ! -d "$ANSWERED_DIR" ] && exit 0

NOW_EPOCH="$(date -u +%s 2>/dev/null || echo 0)"

# Read last scan timestamp; if missing, default to 1 day ago.
LAST_SCAN=0
if [ -f "$LAST_SCAN_FILE" ]; then
  LAST_SCAN="$(tr -d '[:space:]' < "$LAST_SCAN_FILE" 2>/dev/null || echo 0)"
  [[ "$LAST_SCAN" =~ ^[0-9]+$ ]] || LAST_SCAN=0
fi
if [ "$LAST_SCAN" -eq 0 ]; then
  LAST_SCAN=$(( NOW_EPOCH - 86400 ))
fi

NEW_COUNT=0
for bundle in "$ANSWERED_DIR"/*.md; do
  [ -f "$bundle" ] || continue
  MTIME="$(stat -c%Y "$bundle" 2>/dev/null || stat -f%m "$bundle" 2>/dev/null || echo 0)"
  [[ "$MTIME" =~ ^[0-9]+$ ]] || continue
  if [ "$MTIME" -gt "$LAST_SCAN" ]; then
    BUNDLE_NAME="$(basename "$bundle")"
    NEW_COUNT=$(( NEW_COUNT + 1 ))
    echo "[$(date -Iseconds)] qa-answered-detector: NEW answered bundle: $BUNDLE_NAME (mtime=$(date -d "@$MTIME" -Iseconds 2>/dev/null || echo "$MTIME"))" >> "$HOOK_LOG"
    # Track 8a wire-in (S18 Option C coda per D-007): emit q_and_a_resolution event.
    if [ -x "$SYNC_HOOK" ]; then
      "$SYNC_HOOK" DESIGN_THINKING q_and_a_resolution "" "" "$BUNDLE_NAME" "qa bundle answered" >> "$HOOK_LOG" 2>&1 || true
    fi
  fi
done

# Update last-scan timestamp.
printf '%s\n' "$NOW_EPOCH" > "$LAST_SCAN_FILE"

[ "$NEW_COUNT" -gt 0 ] && echo "[$(date -Iseconds)] qa-answered-detector: $NEW_COUNT new answered bundle(s) detected — agent should read them at session start" >> "$HOOK_LOG"
exit 0
