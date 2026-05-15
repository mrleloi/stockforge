#!/usr/bin/env bash
# autonomous-block-enforcer.sh — Phase C of unified severity/escalation system (proposal §2 Layer 4)
#
# When `agent-workspace/memory/.autonomous-BLOCKED` flag exists:
#   - UserPromptSubmit cadence ($1=UserPromptSubmit): inject loud BLOCKED context via stdout
#   - PreToolUse cadence ($1=PreToolUse): exit RC=2 (block) for Edit/Write/Bash/MultiEdit/NotebookEdit/Agent
#     (Read/Glob/Grep stay allowed for diagnostic)
#   - ESCAPE HATCH: a Bash call that invokes `block-control.sh` is ALWAYS allowed, even
#     while blocked — that script's only job is gate management (status/clear/raise), so
#     the agent/human can clear the gate without a manual file delete (the S316 deadlock).
#
# Clearing the gate: the normal path is `block-control.sh check-prompt` (UserPromptSubmit
# hook) auto-clearing when the human replies "approved" / "unblock" / etc. — see
# block-control.sh. Override: STOCKFORGE_FORCE_AUTONOMOUS=1 env bypasses block (and logs to mistake-log).
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
      printf -- '--- Flag content (verbatim) ---\n'
      printf '%s\n' "$FLAG_CONTENT"
      printf -- '--- End flag content ---\n\n'
      printf 'Agent instructions this turn:\n'
      printf '  1. DO NOT proceed with any new work (Edit/Write/MultiEdit/Agent + most Bash blocked by PreToolUse hook).\n'
      printf '  2. Respond to user with a one-paragraph status of the blocking artifact(s) (Read/Glob/Grep allowed for diagnostic).\n'
      printf '  3. TO RESUME: the user replies "approved" / "unblock" / "run autonomous" / "tiep tuc" — block-control.sh check-prompt auto-clears the gate. No manual file delete needed.\n'
      printf '  4. The agent MAY run "bash scripts/hooks/block-control.sh status|clear" — block-control.sh is exempt from the Bash block (escape hatch).\n'
      printf '  5. Emergency: user can set STOCKFORGE_FORCE_AUTONOMOUS=1 env to bypass (logged to mistake-log).\n'
    }
    printf '[%s] autonomous-block-enforcer: UserPromptSubmit injection emitted\n' "$TS" >> "$LOG"
    exit 0
    ;;
  PreToolUse)
    # Read tool name from Claude Code's env: CLAUDE_TOOL_NAME (newer) or stdin JSON.
    # Also capture stdin JSON for Bash calls so we can recognise the block-control.sh
    # escape hatch. Guard the `cat` with [ ! -t 0 ] so it never blocks on a TTY.
    TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
    STDIN_JSON=""
    if { [ -z "$TOOL_NAME" ] || [ "$TOOL_NAME" = "Bash" ]; } && [ ! -t 0 ]; then
      STDIN_JSON=$(cat 2>/dev/null || true)
    fi
    if [ -z "$TOOL_NAME" ] && [ -n "$STDIN_JSON" ]; then
      TOOL_NAME=$(printf '%s' "$STDIN_JSON" | grep -o '"tool_name":"[^"]*"' | head -1 | sed 's/.*:"\([^"]*\)"/\1/' || echo "")
    fi
    case "$TOOL_NAME" in
      Read|Glob|Grep|"")
        # Read-only or unknown — allow (default safe)
        exit 0
        ;;
      Bash)
        # ESCAPE HATCH: a Bash call that invokes block-control.sh is ALWAYS allowed —
        # that script's only job is gate management (status/clear/raise), so it is safe
        # even while blocked. Without this, clearing a gate is a deadlock (the S316 bug).
        case "$STDIN_JSON" in
          *block-control.sh*)
            printf '[%s] autonomous-block-enforcer: PreToolUse ALLOWED Bash block-control.sh (escape hatch)\n' "$TS" >> "$LOG"
            exit 0
            ;;
        esac
        echo "AUTONOMOUS-BLOCKED: tool=Bash denied. Flag at $BLOCK_FLAG. To resume: reply 'approved'/'unblock' to the agent, or run 'bash scripts/hooks/block-control.sh clear'. Emergency override: STOCKFORGE_FORCE_AUTONOMOUS=1 env." >&2
        printf '[%s] autonomous-block-enforcer: PreToolUse BLOCKED tool=Bash\n' "$TS" >> "$LOG"
        exit 2
        ;;
      Edit|Write|MultiEdit|NotebookEdit|Agent)
        # Block via RC=2 with stderr message
        echo "AUTONOMOUS-BLOCKED: tool=$TOOL_NAME denied. Flag at $BLOCK_FLAG. To resume: reply 'approved'/'unblock' to the agent, or run 'bash scripts/hooks/block-control.sh clear'. Emergency override: STOCKFORGE_FORCE_AUTONOMOUS=1 env." >&2
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
