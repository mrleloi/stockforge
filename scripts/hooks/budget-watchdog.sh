#!/usr/bin/env bash
# budget-watchdog.sh — hook-fired budget watchdog (ported from orch v2.2.0).
# Wired as PostToolUse + Stop hook in .claude/settings.json.
# Reads transcript JSONL, sums real token usage, auto-triggers session-self-reboot at cliff.
#
# Stdin (JSON from Claude Code):
#   { "session_id": "...", "transcript_path": "...", "cwd": "...", "hook_event_name": "...", ... }
#
# Env (STOCKFORGE_* preferred; ORCH_* legacy fallback for migration):
#   STOCKFORGE_WIND_DOWN_TOKENS / ORCH_WIND_DOWN_TOKENS  (default 180000; was 200000 pre D-004)
#   STOCKFORGE_CLIFF_TOKENS     / ORCH_CLIFF_TOKENS      (default 220000; was 230000 pre D-004)
#   STOCKFORGE_WATCHDOG_DISABLE / ORCH_WATCHDOG_DISABLE  (=1 → skip)
# Defaults recalibrated per D-004 (UP-07): Opus 4.7 auto-compact at 160-180K + quality
# degradation at 250K+ argue for tighter band. See agent-workspace/memory/decisions/004-up07-context-threshold-opus47.md
set -euo pipefail
trap 'exit 0' ERR

WIND_DOWN="${STOCKFORGE_WIND_DOWN_TOKENS:-${ORCH_WIND_DOWN_TOKENS:-180000}}"
CLIFF="${STOCKFORGE_CLIFF_TOKENS:-${ORCH_CLIFF_TOKENS:-220000}}"

[ "${STOCKFORGE_WATCHDOG_DISABLE:-${ORCH_WATCHDOG_DISABLE:-0}}" = "1" ] && exit 0

PAYLOAD=$(cat)
TRANSCRIPT=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).transcript_path||''); } catch { console.log(''); } });" 2>/dev/null || true)
HOOK_EVENT=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).hook_event_name||''); } catch { console.log(''); } });" 2>/dev/null || true)

if [ -z "${TRANSCRIPT:-}" ] || [ ! -f "$TRANSCRIPT" ]; then
  exit 0
fi

# Compute running context size from transcript JSONL usage fields; fallback to file size / 3.5.
TOTAL=$(node -e "
const fs=require('fs');
const path=process.argv[1];
function pickUsage(o){return o&&(o.message&&o.message.usage)||o.usage||o.response&&o.response.usage||null;}
try{
  const raw=fs.readFileSync(path,'utf8');
  const lines=raw.split('\n').filter(Boolean);
  let latest=null;
  for(const line of lines){
    try{const o=JSON.parse(line);const u=pickUsage(o);
      if(u&&(u.input_tokens||u.cache_read_input_tokens||u.cache_creation_input_tokens))latest=u;
    }catch{}
  }
  let ctx=0;
  if(latest)ctx=(latest.input_tokens||0)+(latest.cache_creation_input_tokens||0)+(latest.cache_read_input_tokens||0);
  if(ctx===0){const stat=fs.statSync(path);ctx=Math.floor(stat.size/3.5);}
  console.log(ctx);
}catch{console.log(0);}" "$TRANSCRIPT" 2>/dev/null || echo 0)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
printf '%s\n' "$TOTAL" > "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens"

HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
printf '[%s] watchdog tokens=%s wind_down=%s cliff=%s\n' "$(date -Iseconds)" "$TOTAL" "$WIND_DOWN" "$CLIFF" >> "$HOOK_LOG"

WIND_DOWN_MARK="$PROJECT_DIR/agent-workspace/memory/.wind-down"
WIND_DOWN_FIRED="$PROJECT_DIR/agent-workspace/memory/.wind-down-fired"
CLIFF_MARK="$PROJECT_DIR/agent-workspace/memory/.cliff-fired"
FAILED_MARKER="$PROJECT_DIR/agent-workspace/memory/.auto-reboot-FAILED"
mkdir -p "$PROJECT_DIR/agent-workspace/memory/handoff-logs"

# Auto-recovery on prior failed reboot: clear once-only markers so retry can fire.
# Without this, .cliff-fired / .wind-down-fired persist after a UIPI/SendKeys failure
# (Windows secure-desktop), silently blocking ALL future reboot retries.
if [ -f "$FAILED_MARKER" ]; then
  rm -f "$WIND_DOWN_FIRED" "$CLIFF_MARK" "$FAILED_MARKER"
  printf '[%s] watchdog: prior auto-reboot FAILED — cleared once-only markers to retry\n' \
    "$(date -Iseconds)" >> "$HOOK_LOG"
fi

# S35 D7 stale-marker auto-clear (2026-05-01): if a once-only marker is older than 1 hour
# AND the current session_id differs from the one that fired the marker, clear it so future
# cliff/wind-down can fire fresh in the new session. Surfaced from S34-extension where
# `.cliff-fired` from a prior session blocked re-fire after partial reboot left no
# .auto-reboot-FAILED marker (e.g., user manually /clear'd before failure was detected).
SESSION_ID=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).session_id||''); } catch { console.log(''); } });" 2>/dev/null || true)
clear_stale_marker() {
  local marker="$1"
  [ ! -f "$marker" ] && return 0
  # Marker mtime in epoch seconds vs now: clear if >3600s old.
  local marker_age
  marker_age=$(($(date +%s) - $(stat -c %Y "$marker" 2>/dev/null || stat -f %m "$marker" 2>/dev/null || echo 0)))
  if [ "$marker_age" -gt 3600 ]; then
    # If marker recorded a session_id different from current, OR marker pre-dates SESSION_ID file: clear.
    local recorded_session
    recorded_session=$(grep -oE 'session_id=[^ ]+' "$marker" 2>/dev/null | head -1 | cut -d= -f2 || true)
    if [ -z "$recorded_session" ] || [ "$recorded_session" != "$SESSION_ID" ]; then
      rm -f "$marker"
      printf '[%s] watchdog: cleared stale marker %s (age=%ss recorded_session=%s current_session=%s)\n' \
        "$(date -Iseconds)" "$marker" "$marker_age" "${recorded_session:-none}" "${SESSION_ID:-unknown}" >> "$HOOK_LOG"
    fi
  fi
}
clear_stale_marker "$CLIFF_MARK"
clear_stale_marker "$WIND_DOWN_FIRED"
clear_stale_marker "$WIND_DOWN_MARK"

if [ "$TOTAL" -ge "$WIND_DOWN" ] && [ "$TOTAL" -lt "$CLIFF" ]; then
  if [ ! -f "$WIND_DOWN_MARK" ]; then
    printf 'wind_down_crossed_at=%s session_id=%s\ntokens=%s\n' "$(date -Iseconds)" "${SESSION_ID:-unknown}" "$TOTAL" > "$WIND_DOWN_MARK"
    printf '[%s] WIND_DOWN crossed tokens=%s — auto-reboot will fire at next Stop hook\n' "$(date -Iseconds)" "$TOTAL" >> "$HOOK_LOG"
  fi

  # Sync invocation (NOT background-detached): UIPI requires interactive desktop access
  # inherited from TUI ancestor. `timeout 8s` bounds Stop-hook latency.
  if [ "$HOOK_EVENT" = "Stop" ] && [ ! -f "$WIND_DOWN_FIRED" ]; then
    printf 'wind_down_fired_at=%s session_id=%s\ntokens=%s\n' "$(date -Iseconds)" "${SESSION_ID:-unknown}" "$TOTAL" > "$WIND_DOWN_FIRED"
    printf '[%s] WIND_DOWN auto-reboot firing on Stop tokens=%s\n' "$(date -Iseconds)" "$TOTAL" >> "$HOOK_LOG"
    timeout 8 bash "$PROJECT_DIR/scripts/session-self-reboot.sh" "continue from checkpoint" \
        >> "$PROJECT_DIR/agent-workspace/memory/handoff-logs/auto-wind-down-$(date +%s).log" 2>&1 || true
  fi
fi

# Cliff: HARD auto-reboot — fires on PostToolUse or Stop. Backstop for missed wind-down.
if [ "$TOTAL" -ge "$CLIFF" ] && [ ! -f "$CLIFF_MARK" ]; then
  printf 'cliff_fired_at=%s session_id=%s\ntokens=%s\n' "$(date -Iseconds)" "${SESSION_ID:-unknown}" "$TOTAL" > "$CLIFF_MARK"
  printf '[%s] CLIFF tokens=%s — firing session-self-reboot.sh\n' "$(date -Iseconds)" "$TOTAL" >> "$HOOK_LOG"
  timeout 8 bash "$PROJECT_DIR/scripts/session-self-reboot.sh" "continue from checkpoint" \
      >> "$PROJECT_DIR/agent-workspace/memory/handoff-logs/auto-cliff-$(date +%s).log" 2>&1 || true
fi

# === Mode-C premature wind-down guard (Stop-only) ===
# Triggers when LLM ends turn citing budget pressure but real tokens are well below threshold.
# Emits Stop-blocking decision JSON to stdout per Claude Code Stop hook spec.
if [ "$HOOK_EVENT" = "Stop" ]; then
  EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
  if [ -f "$EXEC_FILE" ] && grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then
    SOFT_LIMIT=$(( WIND_DOWN - 20000 ))
    if [ "$TOTAL" -lt "$SOFT_LIMIT" ] && [ ! -f "$WIND_DOWN_MARK" ]; then
      TAIL_TXT=$(tail -n 200 "$TRANSCRIPT" 2>/dev/null || true)
      if printf '%s' "$TAIL_TXT" | grep -qE '(approaching.{0,20}200K|give next task fresh envelope|past 150K[, ]?soft.?prep|near wind.?down|wind.?down threshold|start summarizing|write checkpoint and end turn|finish in.?flight subagents)'; then
        printf '{"decision":"block","reason":"[STOCKFORGE MODE-C GUARD] Real transcript = %s tokens (threshold = %s). Self-track inflates ~25%% over real. .wind-down marker is ABSENT. Do NOT end turn citing budget pressure — dispatch the next subagent and continue. Reference: agent-workspace/constitution/autonomous-protocol.md § TURN-END DISCIPLINE."}\n' \
          "$TOTAL" "$WIND_DOWN"
        ALERT_LOG="$PROJECT_DIR/agent-workspace/memory/.autonomous-premature-windown-alert.log"
        mkdir -p "$(dirname "$ALERT_LOG")"
        printf '[%s] MODE-C GUARD BLOCKED Stop. real_tokens=%s soft_limit=%s wind_down_marker=absent transcript=%s\n' \
          "$(date -Iseconds)" "$TOTAL" "$SOFT_LIMIT" "$TRANSCRIPT" >> "$ALERT_LOG"
        exit 0
      fi
    fi
  fi
fi

exit 0
