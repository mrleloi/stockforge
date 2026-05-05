#!/usr/bin/env bash
# precompact-thesis-state-dump.sh — PreCompact hook persisting active thesis state before
# context compaction loses it.
# Wired as PreCompact in .claude/settings.json. Snapshots thesis-log/active.yaml +
# current-execution.md + checkpoints/latest.md to compaction-snapshot dir.
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SNAPSHOT_DIR="$PROJECT_DIR/agent-workspace/memory/.precompact-snapshots"
mkdir -p "$SNAPSHOT_DIR"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

TS="$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || date -u +%s)"
TARGET="$SNAPSHOT_DIR/$TS"
mkdir -p "$TARGET"

# Snapshot critical state files.
for src in \
  "$PROJECT_DIR/agent-workspace/memory/current-execution.md" \
  "$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md" \
  "$PROJECT_DIR/agent-workspace/memory/thesis-log/active.yaml" \
  "$PROJECT_DIR/agent-workspace/memory/observations/queued-grill-master.md" \
  "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens"
do
  if [ -f "$src" ]; then
    cp "$src" "$TARGET/$(basename "$src")" 2>/dev/null || true
  fi
done

# Capture last 200 lines of session-hooks log for activity context.
if [ -f "$HOOK_LOG" ]; then
  tail -n 200 "$HOOK_LOG" > "$TARGET/session-hooks.tail" 2>/dev/null || true
fi

# Capture metadata.
{
  printf 'snapshot_id: %s\n' "$TS"
  printf 'created_at: %s\n' "$(date -Iseconds)"
  printf 'session_id: %s\n' "${CLAUDE_SESSION_ID:-unknown}"
  printf 'reason: PreCompact hook (context compaction imminent)\n'
} > "$TARGET/metadata.yaml"

echo "[$(date -Iseconds)] PreCompact: thesis state snapshotted to $TARGET" >> "$HOOK_LOG"

# Rotate: keep last 10 snapshots.
SNAPSHOT_COUNT="$(ls -1 "$SNAPSHOT_DIR" 2>/dev/null | wc -l)"
if [ "${SNAPSHOT_COUNT:-0}" -gt 10 ]; then
  ls -1t "$SNAPSHOT_DIR" 2>/dev/null | tail -n +11 | while read -r old; do
    rm -rf "$SNAPSHOT_DIR/$old" 2>/dev/null || true
  done
fi

exit 0
