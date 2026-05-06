#!/usr/bin/env bash
# component-telemetry.sh — records one JSONL line per hook event for self-awareness telemetry.
# Wired as PostToolUse / SubagentStop / SessionStart in .claude/settings.json.
# Daemon-dumb: shell + node -e only, no LLM/network. Append-only with rotation at 10 MB.
# Ported from orch v2.2.0; adapted subagent_type→model classification for stockforge agents.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
mkdir -p "$MEMORY_DIR"

JSONL_FILE="$MEMORY_DIR/component-telemetry.jsonl"
TOKENS_FILE="$MEMORY_DIR/.transcript-tokens"
TOKENS_PREV_FILE="$MEMORY_DIR/.transcript-tokens-prev"
# S13 (Track 5.5c.3 wire-in): correlate_failure_mode reads .session-hooks.log + mode-C alert
# log instead of the never-written .autonomous-stop-watchdog.log path. Per S12 Karpathy framing
# DEEPEN decision; baseline 0/60=0%, target ≥8.3% populated rate.
HOOKS_LOG="$MEMORY_DIR/.session-hooks.log"
MODE_C_LOG="$MEMORY_DIR/.autonomous-premature-windown-alert.log"

PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

(
HOOK_EVENT_NAME="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).hook_event_name||''); } catch { console.log(''); } });" 2>/dev/null || true)"

SESSION_ID="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).session_id||''); } catch { console.log(''); } });" 2>/dev/null || true)"

TOOL_NAME="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).tool_name||''); } catch { console.log(''); } });" 2>/dev/null || true)"

SUBAGENT_TYPE="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const p=JSON.parse(s); console.log((p.tool_input&&p.tool_input.subagent_type)||''); } catch { console.log(''); } });" 2>/dev/null || true)"

PAYLOAD_STATUS="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).status||''); } catch { console.log(''); } });" 2>/dev/null || true)"

PAYLOAD_ERROR="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).error||''); } catch { console.log(''); } });" 2>/dev/null || true)"

PAYLOAD_DECISION="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).decision||''); } catch { console.log(''); } });" 2>/dev/null || true)"

AGENT_ID="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).agent_id||''); } catch { console.log(''); } });" 2>/dev/null || true)"

# HH-B.3: extract tool_response text patterns for fine-grained failure_mode classification.
# Pattern → code map:  permission denied → H, timeout → T, rate limit → R, file not found → F,
# invalid input → I, error: prefix → B (generic error), connection refused → N (network).
RESPONSE_FAILURE_MODE="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try {
  const p=JSON.parse(s);
  const r=p.tool_response;
  if (!r) { console.log(''); return; }
  let txt='';
  if (typeof r==='string') txt=r;
  else if (r.content&&Array.isArray(r.content)) txt=r.content.map(c=>c.text||'').join(' ');
  else txt=JSON.stringify(r);
  txt=txt.toLowerCase();
  if (r.is_error===true) {
    if (txt.includes('rate limit')||txt.includes('rate_limit_error')) { console.log('R'); return; }
    if (txt.includes('permission denied')||txt.includes('not allowed')||txt.includes('access denied')) { console.log('H'); return; }
    if (txt.includes('timeout')||txt.includes('timed out')) { console.log('T'); return; }
    if (txt.includes('file not found')||txt.includes('no such file')||txt.includes('does not exist')) { console.log('F'); return; }
    if (txt.includes('connection refused')||txt.includes('econnrefused')||txt.includes('network error')) { console.log('N'); return; }
    if (txt.includes('invalid')||txt.includes('inputvalidationerror')) { console.log('I'); return; }
    console.log('B');
    return;
  }
  console.log('');
} catch { console.log(''); } });" 2>/dev/null || true)"

[ -z "$HOOK_EVENT_NAME" ] && [ -z "$SESSION_ID" ] && [ -z "$TOOL_NAME" ] && exit 0

classify_component() {
  local hook_event="$1" tool_name="$2" subagent_type="$3"
  local subagent_agent_id="${4:-}" subagent_session="${5:-}"
  COMP_TYPE=""; COMP_NAME=""; TRIGGER=""

  case "$hook_event" in
    PostToolUse)
      if printf '%s' "$tool_name" | grep -qE '^skill:([A-Za-z0-9_-]+)$'; then
        COMP_TYPE="skill"; COMP_NAME="$(printf '%s' "$tool_name" | sed 's/^skill://')"; TRIGGER="keyword_match"
      elif [ "$tool_name" = "Task" ] || [ "$tool_name" = "Agent" ]; then
        COMP_TYPE="agent"; COMP_NAME="${subagent_type:-unknown-agent}"; TRIGGER="agent_dispatch"
      elif printf '%s' "$tool_name" | grep -qE '^slash:'; then
        COMP_TYPE="command"; COMP_NAME="$(printf '%s' "$tool_name" | sed 's|^slash:/\?||')"; TRIGGER="explicit_invoke"
      elif printf '%s' "$tool_name" | grep -qE '\.claude/commands/'; then
        COMP_TYPE="command"; COMP_NAME="$(basename "$tool_name" .md)"; TRIGGER="explicit_invoke"
      else
        COMP_TYPE="hook"; COMP_NAME="${tool_name:-PostToolUse}"; TRIGGER="hook_event"
      fi
      ;;
    SubagentStop)
      COMP_TYPE="agent"; TRIGGER="agent_dispatch"
      local sidecar_name sidecar_match sidecar_type
      sidecar_name="${subagent_session:+$MEMORY_DIR/.dispatch-pending-${subagent_session}.jsonl}"
      sidecar_type=""
      if [ -n "$subagent_agent_id" ] && [ -n "$sidecar_name" ] && [ -f "$sidecar_name" ]; then
        sidecar_match="$(grep "\"dispatch_id\":\"${subagent_agent_id}\"" "$sidecar_name" | tail -1 2>/dev/null || true)"
        if [ -n "$sidecar_match" ]; then
          sidecar_type="$(printf '%s' "$sidecar_match" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).agent_type||''); } catch { console.log(''); } });" 2>/dev/null || true)"
        fi
      fi
      [ -n "$sidecar_type" ] && COMP_NAME="$sidecar_type" || COMP_NAME="${subagent_type:-unknown-agent}"
      ;;
    SessionStart|Stop|PreToolUse|SessionEnd|UserPromptSubmit|PreCompact|Notification|TaskCompleted)
      COMP_TYPE="hook"; COMP_NAME="$hook_event"; TRIGGER="hook_event"
      ;;
    *)
      COMP_TYPE="hook"; COMP_NAME="${hook_event:-unknown}"; TRIGGER="hook_event"
      ;;
  esac
}

compute_tokens_real() {
  local current=0 prev=0
  if [ -f "$TOKENS_FILE" ]; then
    current="$(tr -d '[:space:]' < "$TOKENS_FILE" 2>/dev/null || echo 0)"
    [[ "$current" =~ ^[0-9]+$ ]] || current=0
  fi
  if [ -f "$TOKENS_PREV_FILE" ]; then
    prev="$(tr -d '[:space:]' < "$TOKENS_PREV_FILE" 2>/dev/null || echo 0)"
    [[ "$prev" =~ ^[0-9]+$ ]] || prev=0
  fi
  printf '%s\n' "$current" > "$TOKENS_PREV_FILE"
  TOKENS_REAL=$(( current - prev ))
  if [ "$TOKENS_REAL" -lt 0 ]; then TOKENS_REAL=0; fi
}

compute_duration_ms() {
  local session="$1"
  local ts_file="$MEMORY_DIR/.last-event-ts-${session}"
  local now=0 prev=0
  now="$(date -u +%s%3N 2>/dev/null || echo 0)"
  [[ "$now" =~ ^[0-9]+$ ]] || now=0
  if [ -f "$ts_file" ]; then
    prev="$(tr -d '[:space:]' < "$ts_file" 2>/dev/null || echo 0)"
    [[ "$prev" =~ ^[0-9]+$ ]] || prev=0
  fi
  printf '%s\n' "$now" > "$ts_file"
  DURATION_MS=$(( now - prev ))
  if [ "$DURATION_MS" -lt 0 ] || [ "$prev" -eq 0 ]; then DURATION_MS=0; fi
}

skip_if_duplicate() {
  local ts_val="$1" comp_name="$2"
  [ ! -f "$JSONL_FILE" ] && return 1
  local last_line
  last_line="$(tail -n 1 "$JSONL_FILE" 2>/dev/null || true)"
  [ -z "$last_line" ] && return 1
  local last_ts last_name
  last_ts="$(printf '%s' "$last_line" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).ts||''); } catch { console.log(''); } });" 2>/dev/null || true)"
  last_name="$(printf '%s' "$last_line" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).component_name||''); } catch { console.log(''); } });" 2>/dev/null || true)"
  [ "$last_name" = "$comp_name" ] && [ "$last_ts" = "$ts_val" ] && return 0
  return 1
}

correlate_failure_mode() {
  # S13 wire-in: codes set deterministically. Outcome-based fallback (B/T) is added in
  # the dispatch site after this call, so this function only handles correlation-tier signals.
  #   A = reserved (agent narration drift; future LLM-side detector)
  #   B = api/tool error  (outcome=error → set after this call)
  #   C = premature wind-down (mode-C guard fired; explicit alert file)
  #   D = drift signal exceeded (reserved; constant-fire today, gated until D-thresholds tuned)
  #   H = permission deny (PAYLOAD_DECISION=deny → set after this call, takes precedence)
  #   P = cliff auto-reboot fire (real tokens crossed cliff threshold within current minute)
  #   T = tool timeout (outcome=timeout → set after this call)
  # Fix L-S10-1: replaced `[ x ] && return` ERR-trap patterns with `if; then; fi` blocks.
  FAILURE_MODE="null"
  local current_minute
  current_minute="$(date -u +%Y-%m-%dT%H:%M 2>/dev/null || true)"
  if [ -z "$current_minute" ]; then
    return
  fi
  # Mode-C alert log: written by budget-watchdog.sh when LLM ends turn citing budget pressure
  # while real-transcript well below threshold. Highest-priority correlate.
  if [ -f "$MODE_C_LOG" ]; then
    local mode_c_tail
    mode_c_tail="$(tail -n 5 "$MODE_C_LOG" 2>/dev/null || true)"
    if [ -n "$mode_c_tail" ] && printf '%s' "$mode_c_tail" | grep -q "MODE-C GUARD BLOCKED"; then
      FAILURE_MODE='"C"'
      return
    fi
  fi
  # Session hooks log: tail last 20 lines; require current-minute scoping to avoid stale-bucket false positives.
  if [ -f "$HOOKS_LOG" ]; then
    local hooks_tail
    hooks_tail="$(tail -n 20 "$HOOKS_LOG" 2>/dev/null || true)"
    if [ -n "$hooks_tail" ] && printf '%s' "$hooks_tail" | grep -q "$current_minute"; then
      if printf '%s' "$hooks_tail" | grep -q "CLIFF tokens="; then
        FAILURE_MODE='"P"'
      fi
    fi
  fi
}

append_with_rotation() {
  local json_line="$1" max_bytes=10485760
  if [ -f "$JSONL_FILE" ]; then
    local fsize=0
    fsize="$(stat -c%s "$JSONL_FILE" 2>/dev/null || stat -f%z "$JSONL_FILE" 2>/dev/null || echo 0)"
    [[ "$fsize" =~ ^[0-9]+$ ]] || fsize=0
    if [ "$fsize" -ge "$max_bytes" ]; then
      rm -f "${JSONL_FILE}.5"
      for i in 4 3 2 1; do
        local next=$(( i + 1 ))
        [ -f "${JSONL_FILE}.${i}" ] && mv "${JSONL_FILE}.${i}" "${JSONL_FILE}.${next}" || true
      done
      mv "$JSONL_FILE" "${JSONL_FILE}.1"
    fi
  fi
  printf '%s\n' "$json_line" >> "$JSONL_FILE"
}

compose_event_jsonl() {
  local comp_type="$1" comp_name="$2" trigger="$3" outcome="$4" tokens_real="$5"
  local duration_ms="$6" session_id="$7" failure_mode="$8" ts_val="$9"
  comp_name="$(printf '%s' "$comp_name" | tr -d '\n\r' | sed 's/"/\\"/g')"
  local session_id_json="null"
  [ -n "$session_id" ] && session_id_json="\"$(printf '%s' "$session_id" | sed 's/"/\\"/g')\""
  printf '{"ts":"%s","component_type":"%s","component_name":"%s","trigger":"%s","outcome":"%s","tokens_real":%s,"duration_ms":%s,"session_id":%s,"task_id":null,"failure_mode":%s}' \
    "$ts_val" "$comp_type" "$comp_name" "$trigger" "$outcome" "$tokens_real" "$duration_ms" "$session_id_json" "$failure_mode"
}

# Track 5.5d.1 D-2: emit learning event to write-heavy NDJSON store.
# Boundary: agent-workspace/learning-data/events/ is gitignored, runtime-read-deny (D9 enforces).
# Rotation handled by learning-queue-sweeper.sh (Track 5.5d.2, S11), not here.
emit_learning_event() {
  local comp_type="$1" comp_name="$2" trigger="$3" outcome="$4" tokens_real="$5"
  local duration_ms="$6" session_id="$7" failure_mode="$8" ts_val="$9"
  local learning_dir="$PROJECT_DIR/agent-workspace/learning-data/events"
  mkdir -p "$learning_dir" 2>/dev/null || return 0
  local as_of
  as_of="$(date -u +%F 2>/dev/null || true)"
  [ -z "$as_of" ] && return 0
  local learning_file="$learning_dir/${as_of}.ndjson"
  comp_name="$(printf '%s' "$comp_name" | tr -d '\n\r' | sed 's/"/\\"/g')"
  local session_id_json="null"
  [ -n "$session_id" ] && session_id_json="\"$(printf '%s' "$session_id" | sed 's/"/\\"/g')\""
  printf '{"ts":"%s","source":"component-telemetry.sh","event_type":"harness-component-event","payload":{"component_type":"%s","component_name":"%s","trigger":"%s","outcome":"%s","tokens_real":%s,"duration_ms":%s,"session_id":%s,"failure_mode":%s},"as_of":"%s"}\n' \
    "$ts_val" "$comp_type" "$comp_name" "$trigger" "$outcome" "$tokens_real" "$duration_ms" "$session_id_json" "$failure_mode" "$as_of" >> "$learning_file"
}

TS="$(date -u +%FT%T.%3NZ 2>/dev/null || date -u +%FT%TZ 2>/dev/null || true)"

classify_component "$HOOK_EVENT_NAME" "$TOOL_NAME" "$SUBAGENT_TYPE" "${AGENT_ID:-}" "${SESSION_ID:-}"

OUTCOME="ok"
if [ -n "$PAYLOAD_ERROR" ]; then OUTCOME="error"
elif [ "$PAYLOAD_DECISION" = "deny" ]; then OUTCOME="reject"
elif [ -n "$PAYLOAD_STATUS" ]; then
  case "$PAYLOAD_STATUS" in
    error) OUTCOME="error" ;; timeout) OUTCOME="timeout" ;;
    denied) OUTCOME="reject" ;; no_op) OUTCOME="no_op" ;;
    *) OUTCOME="ok" ;;
  esac
fi

skip_if_duplicate "$TS" "$COMP_NAME" && exit 0

compute_tokens_real
compute_duration_ms "${SESSION_ID:-default}"
correlate_failure_mode
# HH-B.3: response-text pattern classification (more specific than outcome heuristic).
if [ "$FAILURE_MODE" = "null" ] && [ -n "${RESPONSE_FAILURE_MODE:-}" ]; then
  FAILURE_MODE="\"${RESPONSE_FAILURE_MODE}\""
fi
# S13 wire-in: outcome-based fallback (only set if correlate + response-text didn't populate).
if [ "$FAILURE_MODE" = "null" ] && [ "$OUTCOME" = "error" ]; then FAILURE_MODE='"B"'; fi
if [ "$FAILURE_MODE" = "null" ] && [ "$OUTCOME" = "timeout" ]; then FAILURE_MODE='"T"'; fi
if [ "$PAYLOAD_DECISION" = "deny" ]; then FAILURE_MODE='"H"'; fi

JSON_LINE="$(compose_event_jsonl \
  "$COMP_TYPE" "$COMP_NAME" "$TRIGGER" "$OUTCOME" \
  "$TOKENS_REAL" "$DURATION_MS" "${SESSION_ID:-}" "$FAILURE_MODE" "$TS")"

append_with_rotation "$JSON_LINE"

emit_learning_event \
  "$COMP_TYPE" "$COMP_NAME" "$TRIGGER" "$OUTCOME" \
  "$TOKENS_REAL" "$DURATION_MS" "${SESSION_ID:-}" "$FAILURE_MODE" "$TS"
) </dev/null >/dev/null 2>&1 &

disown 2>/dev/null || true
exit 0
