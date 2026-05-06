#!/usr/bin/env bash
# scheduled-drift-detector-trigger.sh — soft-trigger drift-detector subagent every N hours
# Hook event: Stop (no-op if interval not elapsed)
# Per S65 harness burst D5; user request "scheduled task plan" + "scheduled drift-detector via CronCreate"
#
# Why soft-trigger (not CronCreate remote agent):
# - CronCreate spawns remote agents that don't have local project context
# - Drift-detector needs file-system access to grep current artifacts
# - Soft-trigger writes a marker; Main session at next SessionStart reads marker → dispatches drift-detector subagent
#
# Marker file: agent-workspace/memory/.drift-detector-due (with reason text)
# SessionStart bootstrap reads this marker; if exists → suggest dispatch + clear marker post-dispatch

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
LAST_FIRE_FILE="$MEMORY_DIR/.drift-detector-last-fire"
DUE_MARKER="$MEMORY_DIR/.drift-detector-due"
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

[ -d "$MEMORY_DIR" ] || exit 0

# Interval: 6 hours (configurable via env)
INTERVAL_SECONDS="${DRIFT_DETECTOR_INTERVAL_SECONDS:-21600}"  # 6h default
NOW="$(date +%s)"

# Skip if marker already pending (avoid duplicate triggers)
[ -f "$DUE_MARKER" ] && exit 0

# Compute time since last fire
if [ -f "$LAST_FIRE_FILE" ]; then
  LAST_FIRE="$(cat "$LAST_FIRE_FILE" 2>/dev/null || echo 0)"
  LAST_FIRE="${LAST_FIRE//[^0-9]/}"
  LAST_FIRE="${LAST_FIRE:-0}"
else
  LAST_FIRE=0
fi

ELAPSED=$((NOW - LAST_FIRE))

if [ "$ELAPSED" -ge "$INTERVAL_SECONDS" ] || [ "$LAST_FIRE" = "0" ]; then
  HUMAN_ELAPSED="$((ELAPSED / 3600))h"
  cat > "$DUE_MARKER" <<EOF
# Drift-detector scheduled run due

**Triggered at**: $(date -Iseconds 2>/dev/null || date)
**Reason**: ${HUMAN_ELAPSED} elapsed since last drift-detector dispatch (interval = $((INTERVAL_SECONDS / 3600))h)
**Action**: Main session at next SessionStart should dispatch \`drift-detector\` subagent (Opus per routing-config; ~30-60K)
**Output**: agent-workspace/memory/drift-logs/scheduled-$(date +%Y-%m-%d-%H).md
**Clear marker**: rm $DUE_MARKER post-dispatch
EOF
fi

exit 0
