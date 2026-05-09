#!/usr/bin/env bash
# dispatch-jsonl-recorder.sh — append-only dispatch event log (Decision 023 v2 schema + HH-B.1/B.2 telemetry).
# PreToolUse(Agent) → DISPATCHED row + sidecar entry keyed by tool_use_id.
# PostToolUse(Agent) → no-op (legacy hex-extract removed; never matched in stockforge agents).
# SubagentStop → COMPLETED row with FIFO-matched tool_use_id + transcript-derived tokens/duration/failure_mode.
# HH-B.1: replaced broken "agentId: <hex>" regex correlation with FIFO match against dispatch.jsonl
#         (filter parent_session_id, find oldest DISPATCHED without matching COMPLETED).
# HH-B.2: SubagentStop reads transcript_path to populate tokens_real + duration_ms + failure_mode.
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
    console.log('TRANSCRIPT_PATH='+q(p.transcript_path));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

[ "$HOOK_EVENT" = "PreToolUse" ] && [ "$TOOL_NAME" != "Agent" ] && exit 0
[ "$HOOK_EVENT" = "PostToolUse" ] && [ "$TOOL_NAME" != "Agent" ] && exit 0
[ "$HOOK_EVENT" != "PreToolUse" ] && [ "$HOOK_EVENT" != "PostToolUse" ] && [ "$HOOK_EVENT" != "SubagentStop" ] && exit 0

# Stockforge subagent → model map (per .claude/agents/ frontmatter).
# Re-grounded against actual frontmatter at S48c (HH-B.1) — added intent-vs-impl-diff,
# research-scanner, lesson-synthesizer; corrected spec-author opus (was sonnet).
case "${SUBAGENT_TYPE:-}" in
  master-planner|sandwich-architect|sandwich-verifier|devils-advocate|intent-vs-impl-diff|spec-author|lesson-synthesizer|drift-detector) MODEL="opus" ;;
  sandwich-dev|action-guide-planner|bdd-planner|ul-auditor|research-scanner) MODEL="sonnet" ;;
  intent-classifier) MODEL="haiku" ;;
  *) MODEL="unknown" ;;
esac

# D2 (Plan 011): model resolution fallback — read .claude/agents/<type>.md frontmatter.
# Cache in .dispatch-model-cache.tsv to avoid repeated file reads.
# Only runs when SUBAGENT_TYPE is non-empty and MODEL is still unknown.
MODEL_CACHE="$MEMORY_DIR/.dispatch-model-cache.tsv"
resolve_model_from_agents() {
  local stype="$1"
  local cached_model=""
  # Check cache first (bash-only; no grep exit-1 risk with while read)
  if [ -f "$MODEL_CACHE" ]; then
    while IFS="	" read -r ct cm; do
      if [ "$ct" = "$stype" ]; then
        cached_model="$cm"
        break
      fi
    done < "$MODEL_CACHE" 2>/dev/null || true
  fi
  if [ -n "$cached_model" ]; then
    printf '%s' "$cached_model"
    return
  fi
  # Read .claude/agents/<stype>.md frontmatter model: field (awk; ERR-trap-safe)
  local agent_file="$PROJECT_DIR/.claude/agents/${stype}.md"
  local resolved="unknown"
  if [ -f "$agent_file" ]; then
    local m
    m="$(awk '/^---/{c++;next}c==1&&/^model:/{sub(/^model:[[:space:]]*/,"");print;exit}c>1{exit}' "$agent_file" 2>/dev/null || true)"
    if [ -n "$m" ]; then
      # Normalize: claude-opus → opus, claude-sonnet → sonnet, claude-haiku → haiku
      case "$m" in
        *opus*) resolved="opus" ;;
        *sonnet*) resolved="sonnet" ;;
        *haiku*) resolved="haiku" ;;
        opus|sonnet|haiku) resolved="$m" ;;
        *) resolved="$m" ;;
      esac
    fi
  fi
  # Cache the result (create header if needed)
  if [ ! -f "$MODEL_CACHE" ]; then
    printf 'subagent_type\tmodel\n' > "$MODEL_CACHE" 2>/dev/null || true
  fi
  printf '%s\t%s\n' "$stype" "$resolved" >> "$MODEL_CACHE" 2>/dev/null || true
  printf '%s' "$resolved"
}

if [ "$MODEL" = "unknown" ] && [ -n "${SUBAGENT_TYPE:-}" ]; then
  RESOLVED="$(resolve_model_from_agents "$SUBAGENT_TYPE")"
  if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "unknown" ]; then
    MODEL="$RESOLVED"
  fi
fi

TS_MS="$(node -e 'console.log(Date.now())' 2>/dev/null || echo 0)"
# L-S108-1 fix (S109): drop constant fallback "main". Per-session sidecar
# (.dispatch-pending-<sid>.jsonl) requires unique-per-session value for FIFO
# matching to work correctly; constant fallback caused cross-session contamination
# risk. JSON payload reliably populates session_id for Agent / SubagentStop hooks;
# if missing, fail-safe no-op (skip recording rather than contaminate "main" sidecar).
PARENT_SID="${SESSION_ID:-${CLAUDE_SESSION_ID:-}}"
[ -z "$PARENT_SID" ] && exit 0
SIDECAR="$MEMORY_DIR/.dispatch-pending-${PARENT_SID}.jsonl"
DISPATCH_JSONL="$MEMORY_DIR/dispatch.jsonl"

if [ "$HOOK_EVENT" = "PreToolUse" ]; then
  DID="${TOOL_USE_ID:-}"
  [ -z "$DID" ] && DID="$(node -e 'const c=require("crypto");console.log(c.randomUUID())' 2>/dev/null || echo "gen-$(date +%s)")"
  ATYPE="${SUBAGENT_TYPE:-unknown-agent}"
  [ -z "$ATYPE" ] && ATYPE="unknown-agent"
  printf '%s\n' "{\"dispatch_id\":\"${DID}\",\"tool_use_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\",\"parent_session_id\":\"${PARENT_SID}\",\"ts_ms\":${TS_MS},\"state\":\"pending\"}" >> "$SIDECAR"
  printf '%s\n' "{\"event\":\"DISPATCHED\",\"dispatch_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\",\"parent_session_id\":\"${PARENT_SID}\",\"bg\":true,\"ts_ms\":${TS_MS},\"outcome\":null,\"tokens_used\":null,\"tool_use_id\":\"${DID}\"}" >> "$DISPATCH_JSONL"
elif [ "$HOOK_EVENT" = "PostToolUse" ]; then
  # HH-B.1: PostToolUse hex-extraction removed — orch-specific "agentId: <hex>" pattern never matched
  # in stockforge subagent return text. SubagentStop now does FIFO matching directly against
  # dispatch.jsonl, no PostToolUse correlation step needed.
  :
else
  # SubagentStop — HH-B.1 FIFO matching against dispatch.jsonl + HH-B.2 transcript enrichment.
  case "${STATUS:-}" in
    DONE|done|ok) OUTCOME='"DONE"' ;; FAIL|fail|error) OUTCOME='"FAIL"' ;;
    BLOCKED|blocked) OUTCOME='"BLOCKED"' ;; *) OUTCOME='"DONE"' ;;
  esac

  # FIFO match: find oldest DISPATCHED for this parent_session_id without a matching COMPLETED.
  # Falls back to legacy AGENT_ID hex if FIFO returns nothing (e.g. dispatch.jsonl truncated).
  eval "$(node -e "
const fs=require('fs'),path=require('path');
const dispatchPath=process.argv[1], sid=process.argv[2], legacyAgentId=process.argv[3]||'';
let tid='', atype='unknown-agent', model='unknown';
try {
  const lines=fs.readFileSync(dispatchPath,'utf8').split('\n').filter(Boolean);
  const events=lines.map(l=>{ try{return JSON.parse(l);}catch{return null;} }).filter(Boolean);
  const sessionEvents=events.filter(e=>e.parent_session_id===sid);
  const dispatched=sessionEvents.filter(e=>e.event==='DISPATCHED');
  const completedTids=new Set(sessionEvents.filter(e=>e.event==='COMPLETED'&&e.tool_use_id).map(e=>e.tool_use_id));
  const unmatched=dispatched.filter(d=>d.tool_use_id&&!completedTids.has(d.tool_use_id));
  if (unmatched.length>0) {
    const pick=unmatched[0]; // FIFO oldest
    tid=pick.tool_use_id||''; atype=pick.agent_type||'unknown-agent'; model=pick.model||'unknown';
  }
} catch {}
const q=v=>JSON.stringify(String(v||''));
console.log('TID='+q(tid));
console.log('ATYPE='+q(atype));
console.log('MODEL='+q(model));
" "$DISPATCH_JSONL" "$PARENT_SID" "${AGENT_ID:-}" 2>/dev/null || echo 'TID=""
ATYPE="unknown-agent"
MODEL="unknown"')"

  # HH-B.2: extract tokens_real + duration_ms + failure_mode from subagent transcript JSONL.
  TOKENS_REAL_JSON="null"; DURATION_MS_JSON="null"; FAILURE_MODE_JSON="null"
  if [ -n "${TRANSCRIPT_PATH:-}" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    eval "$(node -e "
const fs=require('fs');
const tp=process.argv[1];
let tokens=0, firstTs=0, lastTs=0, fmode='', errCount=0, lineCount=0;
try {
  const lines=fs.readFileSync(tp,'utf8').split('\n').filter(Boolean);
  for (const line of lines) {
    try {
      const e=JSON.parse(line);
      lineCount++;
      const u=e.message&&e.message.usage;
      if (u) {
        tokens+=(u.input_tokens||0)+(u.output_tokens||0)+(u.cache_creation_input_tokens||0)+(u.cache_read_input_tokens||0);
      }
      const ts=e.timestamp?new Date(e.timestamp).getTime():0;
      if (ts>0) { if (firstTs===0||ts<firstTs) firstTs=ts; if (ts>lastTs) lastTs=ts; }
      const txt=JSON.stringify(e.message||e).toLowerCase();
      if (e.isError||txt.includes('\"is_error\":true')) errCount++;
      if (txt.includes('rate limit')||txt.includes('rate_limit_error')) { if (!fmode) fmode='R'; }
      else if (txt.includes('timeout')||txt.includes('timed out')) { if (!fmode) fmode='T'; }
      else if (txt.includes('permission denied')||txt.includes('not allowed')) { if (!fmode) fmode='H'; }
    } catch {}
  }
  if (errCount>0&&!fmode) fmode='B';
} catch {}
const dur=(firstTs>0&&lastTs>firstTs)?(lastTs-firstTs):0;
console.log('TOKENS='+tokens);
console.log('DURATION_MS='+dur);
console.log('FMODE='+JSON.stringify(fmode));
" "$TRANSCRIPT_PATH" 2>/dev/null || echo 'TOKENS=0
DURATION_MS=0
FMODE=""')"
    [[ "${TOKENS:-0}" =~ ^[0-9]+$ ]] && [ "${TOKENS:-0}" -gt 0 ] && TOKENS_REAL_JSON="$TOKENS"
    [[ "${DURATION_MS:-0}" =~ ^[0-9]+$ ]] && [ "${DURATION_MS:-0}" -gt 0 ] && DURATION_MS_JSON="$DURATION_MS"
    [ -n "${FMODE:-}" ] && FAILURE_MODE_JSON="\"${FMODE}\""
  fi

  if [ -n "${TID:-}" ]; then
    DID="$TID"; TOOL_USE_ID_JSON="\"${TID}\""
  else
    DID="${AGENT_ID:-unknown}"; TOOL_USE_ID_JSON="null"
  fi
  printf '%s\n' "{\"event\":\"COMPLETED\",\"dispatch_id\":\"${DID}\",\"agent_type\":\"${ATYPE}\",\"model\":\"${MODEL}\",\"parent_session_id\":\"${PARENT_SID}\",\"bg\":true,\"ts_ms\":${TS_MS},\"outcome\":${OUTCOME},\"tokens_used\":${TOKENS_REAL_JSON},\"duration_ms\":${DURATION_MS_JSON},\"failure_mode\":${FAILURE_MODE_JSON},\"tool_use_id\":${TOOL_USE_ID_JSON}}" >> "$DISPATCH_JSONL"
fi
) </dev/null >/dev/null 2>&1 &
disown 2>/dev/null || true
exit 0
