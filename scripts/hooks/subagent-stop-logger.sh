#!/usr/bin/env bash
# subagent-stop-logger.sh — SubagentStop hook: logs structured event to .session-hooks.log.
# Ported from orch v2.2.0; removed orch-specific build-subagent-index.sh trigger
# (stockforge defers index build to Track 9 self-awareness).
#
# Stdin (JSON): { "agent_id": "...", "status": "...", "session_id": "..." }
# Falls back to env vars (CLAUDE_AGENT_ID, CLAUDE_AGENT_STATUS) if stdin unavailable.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

STDIN_JSON="$(cat 2>/dev/null || true)"
AGENT_ID=""
STATUS=""
SESSION_ID=""

if [[ -n "$STDIN_JSON" ]]; then
  if command -v jq >/dev/null 2>&1; then
    AGENT_ID="$(printf '%s' "$STDIN_JSON" | jq -r '.agent_id // empty' 2>/dev/null || true)"
    STATUS="$(printf '%s' "$STDIN_JSON" | jq -r '.status // empty' 2>/dev/null || true)"
    SESSION_ID="$(printf '%s' "$STDIN_JSON" | jq -r '.session_id // empty' 2>/dev/null || true)"
  else
    if [[ "$STDIN_JSON" =~ \"agent_id\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then AGENT_ID="${BASH_REMATCH[1]}"; fi
    if [[ "$STDIN_JSON" =~ \"status\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then STATUS="${BASH_REMATCH[1]}"; fi
    if [[ "$STDIN_JSON" =~ \"session_id\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then SESSION_ID="${BASH_REMATCH[1]}"; fi
  fi
fi

[[ -z "$AGENT_ID"   ]] && AGENT_ID="${CLAUDE_AGENT_ID:-}"
[[ -z "$STATUS"     ]] && STATUS="${CLAUDE_AGENT_STATUS:-}"
[[ -z "$SESSION_ID" ]] && SESSION_ID="${CLAUDE_SESSION_ID:-}"

if [[ -z "$AGENT_ID" && -z "$STATUS" ]]; then
  printf '[subagent-stop-logger] no agent_id or status available — skipping log entry\n' >&2
  exit 0
fi

mkdir -p "$(dirname "$LOG_FILE")"
printf '[%s] SubagentStop agentId=%s status=%s session=%s\n' \
  "$TS" "${AGENT_ID:-unknown}" "${STATUS:-unknown}" "${SESSION_ID:-}" \
  >> "$LOG_FILE"

# Append observation file if SubagentStop carries enough payload to warrant a file entry
# (per Track 6 contract: subagent observations land in agent-workspace/memory/observations/).
# Lightweight: write a one-line marker; full observation files are written by the subagent itself.
if [[ -n "$AGENT_ID" && -n "$SESSION_ID" ]]; then
  OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations/_subagent-stops"
  mkdir -p "$OBS_DIR"
  printf '[%s] agent_id=%s session=%s status=%s\n' \
    "$TS" "$AGENT_ID" "$SESSION_ID" "${STATUS:-unknown}" \
    >> "$OBS_DIR/$(date -u +%Y-%m-%d).log"
fi

exit 0
