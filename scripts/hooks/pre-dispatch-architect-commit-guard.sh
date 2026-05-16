#!/usr/bin/env bash
# pre-dispatch-architect-commit-guard.sh — PreToolUse guard for sandwich-architect dispatch.
#
# Anomaly: S335+S337×2 = 3rd-instance dispatch-template gap (AP-23 promote-now per
# ritual-demotion rule). sandwich-architect has NO Bash tool (tools: [Read, Glob, Grep, Write]
# per .claude/agents/sandwich-architect.md:5). If an architect prompt mentions "git commit"
# or related git operations, the architect cannot execute them — and if it tries, it reveals
# a plan authoring mistake (architect shouldn't be trying to commit).
#
# This hook intercepts Agent tool calls where subagent_type=sandwich-architect and the prompt
# contains git commit/add/mv/push keywords. Exit RC=2 blocks the dispatch; the invoker
# (main session) should commit the architect's plan output itself per D-060.
#
# Override: STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 env bypasses for rare legitimate cases
# (e.g. quoting a prior commit hash in a plan description).
#
# Pattern reference: destructive-command-guard.sh (stdin JSON parse + RC=2 block).
#
# S341 D3: closes AP-23 3rd-instance dispatch-template gap.
# Bash + POSIX only per L-S11-1. SPAWN-CONTEXT: stdin-json (PreToolUse).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.pre-dispatch-architect-commit-guard.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# --- Extract tool name, subagent_type, and prompt from stdin JSON ---
TOOL_NAME=""
SUBAGENT_TYPE=""
PROMPT=""
if [ ! -t 0 ]; then
  STDIN_JSON=$(cat 2>/dev/null || true)
  TOOL_NAME=$(printf '%s' "$STDIN_JSON" \
    | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
    | sed 's/.*"\([^"]*\)"$/\1/' || true)
  # subagent_type is nested under tool_input
  SUBAGENT_TYPE=$(printf '%s' "$STDIN_JSON" \
    | grep -o '"subagent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
    | sed 's/.*"\([^"]*\)"$/\1/' || true)
  # prompt or description field (Agent tool may use either)
  PROMPT=$(printf '%s' "$STDIN_JSON" \
    | grep -o '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
    | sed 's/^"prompt"[[:space:]]*:[[:space:]]*"//; s/"$//' || true)
  if [ -z "$PROMPT" ]; then
    PROMPT=$(printf '%s' "$STDIN_JSON" \
      | grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
      | sed 's/^"description"[[:space:]]*:[[:space:]]*"//; s/"$//' || true)
  fi
fi

# Only guard Agent tool calls to sandwich-architect; allow everything else through.
[ "$TOOL_NAME" = "Agent" ] || exit 0
[ "$SUBAGENT_TYPE" = "sandwich-architect" ] || exit 0

# Empty prompt → allow (defensive; can't check).
[ -z "$PROMPT" ] && exit 0

# --- Override gate ---
if [ "${STOCKFORGE_ALLOW_ARCHITECT_COMMIT:-0}" = "1" ]; then
  printf '[%s] pre-dispatch-architect-commit-guard: BYPASSED via STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 prompt=%s\n' \
    "$TS" "${PROMPT:0:200}" >> "$LOG" 2>/dev/null || true
  exit 0
fi

# --- Check for git commit/add/mv/push keywords in prompt ---
BLOCK_REASON=""
if printf '%s' "$PROMPT" | grep -qiE '(git[[:space:]]+commit|git[[:space:]]+add|git[[:space:]]+mv|git[[:space:]]+push)' 2>/dev/null; then
  BLOCK_REASON="architect prompt contains git operation (git commit/add/mv/push)"
fi

if [ -n "$BLOCK_REASON" ]; then
  printf '[%s] pre-dispatch-architect-commit-guard: BLOCKED reason="%s" prompt=%s\n' \
    "$TS" "$BLOCK_REASON" "${PROMPT:0:200}" >> "$LOG" 2>/dev/null || true
  echo "PRE-DISPATCH-ARCHITECT-COMMIT-GUARD: denied — $BLOCK_REASON" >&2
  echo "sandwich-architect has NO Bash tool (tools: [Read, Glob, Grep, Write])." >&2
  echo "The architect cannot execute git operations. Per D-060, main session commits" >&2
  echo "the architect's plan output. Remove git commit instructions from the architect prompt," >&2
  echo "or set STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 if quoting a commit hash non-operationally." >&2
  exit 2
fi

# Prompt is clean → allow.
printf '[%s] pre-dispatch-architect-commit-guard: ALLOW prompt=%s\n' \
  "$TS" "${PROMPT:0:200}" >> "$LOG" 2>/dev/null || true
exit 0
