#!/usr/bin/env bash
# checkpoint-write-end-turn-watchdog.sh — PreToolUse enforcement for L-S49b-4.
#
# Origin: M-S49b-2 (2026-05-05) — LLM continued executing actions AFTER writing
# `agent-workspace/memory/checkpoints/latest.md`, causing duplicate dispatch
# across `/clear` boundary + lost subagent work. User mandate: "phần end session
# này phải do phần lớn deterministic (hook, script) đảm nhiệm chứ, do llm thì
# sẽ phát sinh rất nhiều lỗi".
#
# Mechanism: if companion PostToolUse hook (`checkpoint-write-marker.sh`) has
# set the marker `.checkpoint-written-<session_id>` in this session, deny any
# subsequent non-exempt tool call by exiting 2 with stderr message.
# Marker is cleared on SessionStart.
#
# EXEMPT tools (still allowed after checkpoint write — these don't cause work
# duplication or fresh-context-handoff violation):
#   - Read / Grep / Glob (passive read)
#   - TaskUpdate / TaskList / TaskGet (task-list housekeeping)
#   - ScheduleWakeup (loop-mode sleeping; doesn't fire new actions)
#   - Edit/Write targeting `agent-workspace/memory/checkpoints/latest.md`
#     itself (allows minor cleanup edits to the very file we're guarding)
#
# Bypass: STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1
# (use only for emergency same-turn cleanup; document in session log).
#
# Bash + node -e per existing hook conventions.
# Exit codes: 0=allow, 2=deny (stderr surfaces to LLM).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

mkdir -p "$MEM_DIR"

if [ "${STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END:-0}" = "1" ]; then
  echo "[$(date -Iseconds)] checkpoint-write-end-turn: BYPASSED via env" >> "$LOG"
  exit 0
fi

PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

eval "$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('HOOK_EVENT='+q(p.hook_event_name));
    console.log('SESSION_ID='+q(p.session_id));
    console.log('TOOL_NAME='+q(p.tool_name));
    console.log('FILE_PATH='+q((p.tool_input&&p.tool_input.file_path)||''));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

# Only act on PreToolUse
[ "${HOOK_EVENT:-}" != "PreToolUse" ] && exit 0

# L-S108-1 fix (S109): drop constant fallback "unknown". Per-turn marker semantics
# (intra-session blocking) means hour-bucket would WRONGLY block unrelated sessions
# in same hour. PreToolUse JSON payload reliably populates session_id; if missing,
# fail-safe ALLOW (don't deny tool call — better to allow than deny based on
# stale/colliding marker from another session).
SID="${SESSION_ID:-${CLAUDE_SESSION_ID:-}}"
if [ -z "$SID" ]; then
  echo "[$(date -Iseconds)] checkpoint-write-end-turn: ALLOW — session_id empty (L-S108-1 fail-safe)" >> "$LOG"
  exit 0
fi

MARKER="$MEM_DIR/.checkpoint-written-${SID}"

# If no marker → nothing written this turn, allow
[ ! -f "$MARKER" ] && exit 0

# Marker exists — checkpoint was written this turn. Determine if tool is exempt.
TN="${TOOL_NAME:-}"
FP="${FILE_PATH:-}"

EXEMPT=0

# Passive read tools
case "$TN" in
  Read|Grep|Glob) EXEMPT=1 ;;
esac

# Task-list housekeeping
case "$TN" in
  TaskUpdate|TaskList|TaskGet) EXEMPT=1 ;;
esac

# Loop-mode wake-up scheduling
case "$TN" in
  ScheduleWakeup) EXEMPT=1 ;;
esac

# Edit/Write against the checkpoint file itself (allow follow-up cleanup)
if [ "$TN" = "Edit" ] || [ "$TN" = "Write" ] || [ "$TN" = "MultiEdit" ]; then
  case "$FP" in
    *checkpoints/latest.md) EXEMPT=1 ;;
  esac
fi

if [ "$EXEMPT" = "1" ]; then
  echo "[$(date -Iseconds)] checkpoint-write-end-turn: EXEMPT tool=$TN session=$SID" >> "$LOG"
  exit 0
fi

# Not exempt — DENY via exit 2 with stderr
TS="$(date -Iseconds)"
MSG="checkpoint-write-end-turn-watchdog: DENY tool=$TN session=$SID. Per L-S49b-4 + M-S49b-2: \`agent-workspace/memory/checkpoints/latest.md\` was written this turn — END TURN now. Checkpoint write is the session-boundary marker; the announced next_action is for the NEXT session, not the current one. Acknowledge with a short user-facing summary and stop. Bypass (emergency only): \`STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1\`."

echo "[$TS] checkpoint-write-end-turn: DENIED tool=$TN session=$SID" >> "$LOG"
echo "$MSG" >&2
exit 2
