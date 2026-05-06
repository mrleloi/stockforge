#!/usr/bin/env bash
# pre-dispatch-adr-number-check.sh — block subagent dispatch authoring NEW ADR with collision number
# Hook event: PreToolUse on Agent calls
# Purpose: prevent M-S65-1 recurrence (architect created 028-S51 colliding with existing 028-S48d)
# Per L-S65-1 candidate (deferred codification per "Hook FIRST" Q-E3 doctrine + S65 user directive harness-priority-one)
#
# Detection logic:
#   Pattern A: prompt mentions new file path "agent-workspace/memory/decisions/NNN-..."
#   Pattern B: prompt mentions "D-NNN" + ADR-authoring intent ("new ADR", "author ADR", "NEW decision")
# If proposed NNN <= highest existing NNN → emit warning (default) or block (STOCKFORGE_ADR_CHECK_STRICT=1)

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
DECISIONS_DIR="$PROJECT_DIR/agent-workspace/memory/decisions"

# Read stdin payload
PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

# Parse via node (existing pattern in dispatch-jsonl-recorder.sh)
eval "$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('HOOK_EVENT='+q(p.hook_event_name));
    console.log('TOOL_NAME='+q(p.tool_name));
    console.log('PROMPT='+q((p.tool_input&&p.tool_input.prompt)||''));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

# Only fire on PreToolUse(Agent)
[ "${HOOK_EVENT:-}" = "PreToolUse" ] || exit 0
[ "${TOOL_NAME:-}" = "Agent" ] || exit 0
[ -n "${PROMPT:-}" ] || exit 0
[ -d "$DECISIONS_DIR" ] || exit 0

# Pattern A: new ADR file path
PROPOSED_NNN=""
PROPOSED_PATH="$(printf '%s' "$PROMPT" | grep -oE 'agent-workspace/memory/decisions/[0-9]{3}-[A-Za-z0-9_-]+\.md' | head -1 || true)"
if [ -n "$PROPOSED_PATH" ]; then
  PROPOSED_NNN="$(printf '%s' "$PROPOSED_PATH" | grep -oE '[0-9]{3}' | head -1)"
fi

# Pattern B: D-NNN + ADR-authoring intent
if [ -z "$PROPOSED_NNN" ]; then
  D_REF="$(printf '%s' "$PROMPT" | grep -oE 'D-[0-9]{3}\b' | head -1 || true)"
  if [ -n "$D_REF" ]; then
    INTENT_MATCH="$(printf '%s' "$PROMPT" | { grep -ciE 'new ADR|author.*ADR|new.*decision|ratifying.*ADR|create.*ADR' || true; })"
    if [ "$INTENT_MATCH" -gt 0 ] 2>/dev/null; then
      PROPOSED_NNN="$(printf '%s' "$D_REF" | sed 's/^D-//')"
    fi
  fi
fi

[ -n "$PROPOSED_NNN" ] || exit 0

# Find highest existing NNN
HIGHEST="$(ls "$DECISIONS_DIR"/[0-9][0-9][0-9]-*.md 2>/dev/null | sed 's|.*/||' | grep -oE '^[0-9]{3}' | sort -n | tail -1 || true)"
HIGHEST="${HIGHEST:-000}"
PROPOSED_INT=$((10#$PROPOSED_NNN))
HIGHEST_INT=$((10#$HIGHEST))
NEXT_AVAILABLE=$((HIGHEST_INT + 1))
NEXT_PADDED="$(printf "%03d" "$NEXT_AVAILABLE")"

# Compare
if [ "$PROPOSED_INT" -le "$HIGHEST_INT" ]; then
  EXISTING_FILE="$(ls "$DECISIONS_DIR"/${PROPOSED_NNN}-*.md 2>/dev/null | head -1 | sed 's|.*/||' || true)"
  EXISTING_FILE="${EXISTING_FILE:-(none — gap in numbering)}"

  printf 'ADR-NUMBER COLLISION DETECTED\n' >&2
  printf '  Proposed: D-%s\n' "$PROPOSED_NNN" >&2
  printf '  Existing: %s\n' "$EXISTING_FILE" >&2
  printf '  Suggested: D-%s (next available; highest = D-%s)\n' "$NEXT_PADDED" "$HIGHEST" >&2
  printf '  Hook: pre-dispatch-adr-number-check.sh per L-S65-1 (M-S65-1 prevention)\n' >&2

  if [ "${STOCKFORGE_ADR_CHECK_STRICT:-0}" = "1" ]; then
    cat <<EOF
{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "ADR collision: D-${PROPOSED_NNN} exists as ${EXISTING_FILE}; use D-${NEXT_PADDED}"}}
EOF
    exit 2
  fi
fi

exit 0
