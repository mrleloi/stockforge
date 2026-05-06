#!/usr/bin/env bash
# memory-etl-processor.sh — process queued memory ETL jobs in background
# Hook event: Stop (background processor; non-blocking)
# Per S65 harness burst D6; user request "background job queue"
#
# Queue format:
#   agent-workspace/memory/etl-queue/<priority>-<timestamp>-<task>.job
#   Where priority: 1 (high) → 9 (low)
#
# Job file format (YAML):
#   ---
#   task: <one-of: lesson-synthesize | profile-render | drift-rollup | sync-tracker-sweep>
#   payload: <JSON or path>
#   created_at: <ISO8601>
#   ---
#
# Processing:
# - Sort queue/ by priority + timestamp
# - For each: dispatch corresponding handler script (background subprocess)
# - Move processed job to queue/processed/<date>/

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
QUEUE_DIR="$PROJECT_DIR/agent-workspace/memory/etl-queue"
PROCESSED_DIR="$QUEUE_DIR/processed/$(date +%Y-%m-%d)"
LOG_FILE="$PROJECT_DIR/agent-workspace/memory/.memory-etl-processor.log"
PAYLOAD="$(cat 2>/dev/null || true)"

# Only fire on Stop event
if [ -n "$PAYLOAD" ]; then
  HOOK_EVENT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try { const p=JSON.parse(s); console.log(p.hook_event_name||''); }
  catch { console.log(''); }
});" 2>/dev/null || echo '')"
  [ "${HOOK_EVENT:-Stop}" = "Stop" ] || exit 0
fi

# Skip if queue dir doesn't exist (no jobs ever queued)
[ -d "$QUEUE_DIR" ] || exit 0

# Skip if processor disabled
[ "${MEMORY_ETL_DISABLE:-0}" = "1" ] && exit 0

mkdir -p "$PROCESSED_DIR"

# Pick highest-priority pending job (priority 1 = highest; sort lexically by filename = priority + timestamp)
PENDING_JOB="$(ls "$QUEUE_DIR"/*.job 2>/dev/null | sort | head -1 || true)"
[ -n "$PENDING_JOB" ] && [ -f "$PENDING_JOB" ] || exit 0

JOB_NAME="$(basename "$PENDING_JOB")"

# Parse job task field
TASK="$(awk -F': ' '/^task:/{print $2; exit}' "$PENDING_JOB" 2>/dev/null | tr -d '"' | tr -d "'")"
TASK="${TASK:-unknown}"

TS_NOW="$(date -Iseconds 2>/dev/null || date)"
echo "[$TS_NOW] processing $JOB_NAME (task=$TASK)" >> "$LOG_FILE"

# Dispatch handler (best-effort; record outcome regardless)
case "$TASK" in
  lesson-synthesize)
    # Defer to lesson-synthesizer subagent dispatch (next session entry will pick it up)
    echo "[$TS_NOW]   action=defer-to-next-session-dispatch" >> "$LOG_FILE"
    ;;
  profile-render)
    # Future: invoke profile-template-auto-populate.sh
    echo "[$TS_NOW]   action=profile-render-stub" >> "$LOG_FILE"
    ;;
  drift-rollup)
    if [ -x "$PROJECT_DIR/scripts/hooks/drift-rollup-daily.sh" ]; then
      echo "{}" | bash "$PROJECT_DIR/scripts/hooks/drift-rollup-daily.sh" >/dev/null 2>&1 || true
      echo "[$TS_NOW]   action=drift-rollup-daily-invoked" >> "$LOG_FILE"
    fi
    ;;
  sync-tracker-sweep)
    if [ -x "$PROJECT_DIR/scripts/hooks/sync-tracker-auto-update.sh" ]; then
      echo "{}" | bash "$PROJECT_DIR/scripts/hooks/sync-tracker-auto-update.sh" >/dev/null 2>&1 || true
      echo "[$TS_NOW]   action=sync-tracker-auto-update-invoked" >> "$LOG_FILE"
    fi
    ;;
  *)
    echo "[$TS_NOW]   action=unknown-task-skipped" >> "$LOG_FILE"
    ;;
esac

# Move processed job to processed/<date>/ (audit trail)
mv "$PENDING_JOB" "$PROCESSED_DIR/" 2>/dev/null || true

exit 0
