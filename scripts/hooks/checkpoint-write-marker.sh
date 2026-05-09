#!/usr/bin/env bash
# checkpoint-write-marker.sh — PostToolUse companion for L-S49b-4 enforcement.
#
# Fires AFTER any Edit/Write/MultiEdit tool. If the tool's file_path is
# `agent-workspace/memory/checkpoints/latest.md`, writes a session-scoped
# marker file. The PreToolUse companion `checkpoint-write-end-turn-watchdog.sh`
# reads this marker on next tool call to block subsequent tools (per
# L-S49b-4: checkpoint write = end turn).
#
# Autonomous-mode integration: if `current-execution.md` has
# `**autonomous_mode**: true`, ALSO writes `.fresh-resume-pending-<session_id>`
# marker so SessionStart on next /clear/resume can surface a system-reminder
# to the new LLM telling it to proceed with checkpoint's next_action without
# re-asking. This replaces the revoked Mode-D SendKeys "continue" mechanism
# (per ~/memory/autonomous_continue_no_self_pause.md Rule 2).
#
# Bash + node -e (jq alternative) per existing hook conventions.
# Idempotent: re-running on same checkpoint write rewrites marker (no harm).
# Bypass: set STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1 to skip marker write
# (use only for emergency same-turn cleanup; document in session log).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

mkdir -p "$MEM_DIR"

# Bypass guard
if [ "${STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END:-0}" = "1" ]; then
  echo "[$(date -Iseconds)] checkpoint-write-marker: BYPASSED via env" >> "$LOG"
  exit 0
fi

PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

# Parse JSON via node -e (matches dispatch-jsonl-recorder.sh pattern).
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

# Only react to Edit/Write/MultiEdit
case "${TOOL_NAME:-}" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

# Only react when target is checkpoints/latest.md
case "${FILE_PATH:-}" in
  *checkpoints/latest.md) ;;
  *) exit 0 ;;
esac

# L-S108-1 fix (S109): drop constant fallback "unknown". Per-turn marker semantics
# (intra-session blocking) means hour-bucket would WRONGLY block unrelated sessions
# in same hour. PostToolUse JSON payload reliably populates session_id; if missing,
# fail-safe no-op (don't write marker → watchdog won't block).
SID="${SESSION_ID:-${CLAUDE_SESSION_ID:-}}"
if [ -z "$SID" ]; then
  echo "[$(date -Iseconds)] checkpoint-write-marker: SKIP — session_id empty (L-S108-1 fail-safe)" >> "$LOG"
  exit 0
fi

MARKER="$MEM_DIR/.checkpoint-written-${SID}"
TS="$(date -Iseconds)"

# Write the marker — content includes timestamp + tool name + file path for audit
{
  echo "ts=$TS"
  echo "session_id=$SID"
  echo "tool_name=$TOOL_NAME"
  echo "file_path=$FILE_PATH"
} > "$MARKER"

echo "[$TS] checkpoint-write-marker: SET marker=$MARKER session=$SID tool=$TOOL_NAME" >> "$LOG"

# Autonomous-mode integration — check current-execution.md for the flag
EXEC_FILE="$MEM_DIR/current-execution.md"
AUTONOMOUS=false
if [ -f "$EXEC_FILE" ] && grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then
  AUTONOMOUS=true
fi

if [ "$AUTONOMOUS" = "true" ]; then
  RESUME_MARKER="$MEM_DIR/.fresh-resume-pending-${SID}"
  CHECKPOINT_REF="$MEM_DIR/checkpoints/latest.md"

  # Extract a 5-line excerpt of "Next action" / "Successor" from checkpoint for surfacing
  NEXT_ACTION_EXCERPT=$(grep -A 5 -iE '^## Next action|^\*\*Successor\*\*|^## Successor' "$CHECKPOINT_REF" 2>/dev/null | head -20 | sed 's/"/\\"/g' | tr '\n' ' ' || true)

  {
    echo "ts=$TS"
    echo "prior_session_id=$SID"
    echo "checkpoint_ref=$CHECKPOINT_REF"
    echo "autonomous_mode=true"
    echo "next_action_excerpt=$NEXT_ACTION_EXCERPT"
  } > "$RESUME_MARKER"

  echo "[$TS] checkpoint-write-marker: AUTONOMOUS resume-pending marker=$RESUME_MARKER" >> "$LOG"
fi

# Emit additionalContext / hookSpecificOutput so PostToolUse output surfaces to LLM
# as a reminder (Claude Code: stdout text from PostToolUse becomes additional context).
cat <<EOF

[checkpoint-write-marker] CHECKPOINT WRITE DETECTED — turn should end now per L-S49b-4.
- Marker set: .checkpoint-written-${SID}
- Subsequent tool calls (except Read/Grep/Glob/TaskUpdate/TaskList/TaskGet) will be DENIED by checkpoint-write-end-turn-watchdog.sh.
- If autonomous_mode=true, a fresh-resume-pending marker has also been written; next /clear or /resume will auto-surface the checkpoint's next_action to the new session.
- One short user-facing summary message is OK before ending the turn. NO further Bash, NO Agent dispatch, NO further Edits.
- Bypass (emergency only): set env STOCKFORGE_HOOK_BYPASS_CHECKPOINT_END=1.
EOF

exit 0
