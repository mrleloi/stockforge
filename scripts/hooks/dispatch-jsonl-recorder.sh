#!/usr/bin/env bash
# dispatch-jsonl-recorder.sh — append-only dispatch event log (Decision 023 v2 schema, 10 fields).
# PreToolUse(Agent) → DISPATCHED row + sidecar entry keyed by tool_use_id.
# PostToolUse(Agent) → sidecar entry keyed by hex agent_id (extracted from result text "agentId: <hex>").
# SubagentStop → COMPLETED row; sidecar lookup by hex agent_id retrieves tool_use_id.
# Ported from orch v2.2.0; adapted subagent_type→model map for stockforge agents.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
mkdir -p "$MEMORY_DIR"
PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

(
eval "$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('HOOK_EVENT='+q(p.hook_event_name));
    console.log('SESSION_ID='+q(p.session_id));
    console.log('TOOL_NAME='+q(p.tool_name));
    console.log('TOOL_USE_ID='+q(p.tool_use_id));
    console.log('AGENT_ID='+q(p.agent_id));
    console.log('STATUS='+q(p.status));
    console.log('SUBAGENT_TYPE='+q((p.tool_input&&p.tool_input.subagent_type)||''));
    const resultText=(p.tool_response&&p.tool_response.content&&p.tool_response.content[0]&&p.tool_response.content[0].text)||'';
    const m=resultText.match(/agentId:\\s*([a-f0-9]{10,20})/i);
    console.log('RESULT_AGENT_ID='+q(m?m[1]:''));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

[ "$HOOK_EVENT" = "PreToolUse" ] && [ "$TOOL_NAME" != "Agent" ] && exit 0
[ "$HOOK_EVENT" = "PostToolUse" ] && [ "$TOOL_NAME" != "Agent" ] && exit 0
[ "$HOOK_EVENT" != "PreToolUse" ] && [ "$HOOK_EVENT" != "PostToolUse" ] && [ "$HOOK_EVENT" != "SubagentStop" ] && exit 0

# Stockforge subagent → model map (per .claude/agents/ frontmatter).
case "${SUBAGENT_TYPE:-}" in
  master-planner|sandwich-architect|sandwich-verifier|devils-advocate) MODEL="opus" ;;
  sandwich-dev|action-guide-planner|bdd-planner|drift-detector|spec-author|ul-auditor|intent-classifier) MODEL="sonnet" ;;
  *) MODEL="unknown" ;;
esac

TS_MS="$(node -e 'console.log(Date.now())' 2>/dev/null || echo 0)"
PARENT_SID="${SESSION_ID:-${CLAUDE_SESSION_ID:-main}}"
[ -z "$PARENT_SID" ] && PARENT_SID="main"
SIDECAR="$MEMORY_DIR/.dispatch-pending-${PARENT_SID}.jsonl"
DISPATCH_JSONL="$MEMORY_DIR/dispatch.jsonl"

if [ "$HOOK_EVENT" = "PreToolUse" ]; then
  DID="${TOOL_USE_ID:-}"
  [ -z "$DID" ] && DID="$(node -e 'const c=require("crypto");console.log(c.randomUUID())' 2>/dev/null || echo "gen-$(date +%s)")"
  ATYPE="${SUBAGENT_TYPE:-unknown-agent}"
  [ -z "$ATYPE" ] && ATYPE="unknown-agent"
  printf '%s\n' "{\"dispatch_id\":\"${DID}\",\"tool_use_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\"}" >> "$SIDECAR"
  printf '%s\n' "{\"event\":\"DISPATCHED\",\"dispatch_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\",\"parent_session_id\":\"${PARENT_SID}\",\"bg\":true,\"ts_ms\":${TS_MS},\"outcome\":null,\"tokens_used\":null,\"tool_use_id\":\"${DID}\"}" >> "$DISPATCH_JSONL"
elif [ "$HOOK_EVENT" = "PostToolUse" ]; then
  HEX_ID="${RESULT_AGENT_ID:-}"
  if [ -z "$HEX_ID" ]; then
    printf '[WARN] dispatch-jsonl-recorder: PostToolUse-Agent: RESULT_AGENT_ID empty — agentId pattern not found in result text. SubagentStop correlation will degrade to unknown-agent.\n' >&2
  fi
  ORIG_TID="${TOOL_USE_ID:-}"
  if [ -n "$HEX_ID" ] && [ -n "$ORIG_TID" ] && [ -f "$SIDECAR" ]; then
    MATCH="$(grep "\"tool_use_id\":\"${ORIG_TID}\"" "$SIDECAR" | tail -1 || true)"
    if [ -n "$MATCH" ]; then
      eval "$(printf '%s' "$MATCH" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try{const p=JSON.parse(s);
  console.log('ATYPE='+JSON.stringify(p.agent_type||'unknown-agent'));
  console.log('MODEL='+JSON.stringify(p.model||'unknown'));
}catch{console.log('ATYPE=\"unknown-agent\"\nMODEL=\"unknown\"');} });" 2>/dev/null || echo 'ATYPE="unknown-agent"')"
      printf '%s\n' "{\"dispatch_id\":\"${HEX_ID}\",\"tool_use_id\":\"${ORIG_TID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\"}" >> "$SIDECAR"
    fi
  fi
else
  # SubagentStop
  LID="${AGENT_ID:-}"; ATYPE="unknown-agent"; MODEL="unknown"; TOOL_USE_ID_FOUND=""
  if [ -n "$LID" ] && [ -f "$SIDECAR" ]; then
    MATCH="$(grep "\"dispatch_id\":\"${LID}\"" "$SIDECAR" | tail -1 || true)"
    if [ -n "$MATCH" ]; then
      eval "$(printf '%s' "$MATCH" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try{const p=JSON.parse(s);
  console.log('ATYPE='+JSON.stringify(p.agent_type||'unknown-agent'));
  console.log('MODEL='+JSON.stringify(p.model||'unknown'));
  console.log('TOOL_USE_ID_FOUND='+JSON.stringify(p.tool_use_id||''));
}catch{console.log('ATYPE=\"unknown-agent\"\nMODEL=\"unknown\"\nTOOL_USE_ID_FOUND=\"\"');} });" 2>/dev/null || echo 'ATYPE="unknown-agent"')"
    fi
  fi
  case "${STATUS:-}" in
    DONE|done|ok) OUTCOME='"DONE"' ;; FAIL|fail|error) OUTCOME='"FAIL"' ;;
    BLOCKED|blocked) OUTCOME='"BLOCKED"' ;; *) OUTCOME='"DONE"' ;;
  esac
  if [ -n "$TOOL_USE_ID_FOUND" ]; then
    DID="$TOOL_USE_ID_FOUND"
    TOOL_USE_ID_JSON="\"$TOOL_USE_ID_FOUND\""
  else
    DID="${LID:-unknown}"
    TOOL_USE_ID_JSON="null"
  fi
  printf '%s\n' "{\"event\":\"COMPLETED\",\"dispatch_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\",\"parent_session_id\":\"${PARENT_SID}\",\"bg\":true,\"ts_ms\":${TS_MS},\"outcome\":${OUTCOME},\"tokens_used\":null,\"tool_use_id\":${TOOL_USE_ID_JSON}}" >> "$DISPATCH_JSONL"
fi
) </dev/null >/dev/null 2>&1 &
disown 2>/dev/null || true
exit 0
