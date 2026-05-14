#!/usr/bin/env bash
# autonomous-block-enforcer.sh — Phase C of unified severity/escalation system (proposal §2 Layer 4)
#
# When `agent-workspace/memory/.autonomous-BLOCKED` flag exists:
#   - UserPromptSubmit cadence ($1=UserPromptSubmit): inject loud BLOCKED context via stdout
#   - PreToolUse cadence ($1=PreToolUse): exit RC=2 (block) for Edit/Write/Bash/MultiEdit/NotebookEdit
#     (Read/Glob/Grep stay allowed for diagnostic)
#
# Override: STOCKFORGE_FORCE_AUTONOMOUS=1 env bypasses block (and logs to mistake-log).
#
# Bash + POSIX only per L-S11-1. Default RC=0 (allow); RC=2 (block) only when guarded tool + flag present.
# SPAWN-CONTEXT: bash-c (companion firing-test required per L-S247-1 / firing-test-spawn-context-lint.sh)

set -uo pipefail
trap 'exit 0' ERR

EVENT="${1:-${HOOK_EVENT:-UserPromptSubmit}}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
BLOCK_FLAG="$MEM_DIR/.autonomous-BLOCKED"
LOG="$MEM_DIR/.autonomous-block-enforcer.log"
TS="$(date -Iseconds)"

mkdir -p "$MEM_DIR"

# No flag → allow silently
[ -f "$BLOCK_FLAG" ] || exit 0

# Override env → allow + log warning
if [ "${STOCKFORGE_FORCE_AUTONOMOUS:-0}" = "1" ]; then
  printf '[%s] autonomous-block-enforcer: BYPASSED via STOCKFORGE_FORCE_AUTONOMOUS=1 (event=%s)\n' "$TS" "$EVENT" >> "$LOG"
  exit 0
fi

# Read flag content (truncated to 40 lines for context budget)
FLAG_CONTENT=$(head -40 "$BLOCK_FLAG" 2>/dev/null || echo "(empty)")

case "$EVENT" in
  UserPromptSubmit)
    # Output via stdout becomes additionalContext for the LLM
    {
      printf 'AUTONOMOUS-BLOCKED active. Flag location: %s\n\n' "$BLOCK_FLAG"
      printf '--- Flag content (verbatim) ---\n'
      printf '%s\n' "$FLAG_CONTENT"
      printf -- '--- End flag content ---\n\n'
      printf 'Agent instructions this turn:\n'
      printf '  1. DO NOT proceed with any new work (Edit/Write/Bash tools are blocked by PreToolUse hook).\n'
      printf '  2. Respond to user with one-paragraph status of the blocking artifacts (Read/Glob/Grep allowed for diagnostic).\n'
      printf '  3. Wait for human to resolve + delete the flag file.\n'
      printf '  4. Emergency only: user can set STOCKFORGE_FORCE_AUTONOMOUS=1 env to bypass (logged to mistake-log).\n'
    }
    printf '[%s] autonomous-block-enforcer: UserPromptSubmit injection emitted\n' "$TS" >> "$LOG"
    exit 0
    ;;
  PreToolUse)
    # Read tool name from Claude Code's env: CLAUDE_TOOL_NAME (newer) or stdin JSON.
    # Fallback: assume guarded unless explicitly allowed via env.
    TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
    if [ -z "$TOOL_NAME" ] && [ ! -t 0 ]; then
      # Try parsing stdin JSON for tool_name
      STDIN_JSON=$(cat 2>/dev/null || true)
      TOOL_NAME=$(printf '%s' "$STDIN_JSON" | grep -o '"tool_name":"[^"]*"' | head -1 | sed 's/.*:"\([^"]*\)"/\1/' || echo "")
    fi
    case "$TOOL_NAME" in
      Read|Glob|Grep|"")
        # Read-only or unknown — allow (default safe)
        exit 0
        ;;
      Edit|Write|Bash|MultiEdit|NotebookEdit|Agent)
        # Block via RC=2 with stderr message
        echo "AUTONOMOUS-BLOCKED: tool=$TOOL_NAME denied. Flag at $BLOCK_FLAG. See flag content for resolution path. Emergency override: STOCKFORGE_FORCE_AUTONOMOUS=1 env." >&2
        printf '[%s] autonomous-block-enforcer: PreToolUse BLOCKED tool=%s\n' "$TS" "$TOOL_NAME" >> "$LOG"
        exit 2
        ;;
      *)
        # Unknown guarded tool — allow but log
        printf '[%s] autonomous-block-enforcer: PreToolUse unknown tool=%s allowed by default\n' "$TS" "$TOOL_NAME" >> "$LOG"
        exit 0
        ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac
