#!/usr/bin/env bash
# autonomous-stop-watchdog.sh — Stop hook detector for Mode A/B/C/D loop-break patterns.
# Logs suspected loop-break to .autonomous-stop-watchdog.log; auto-recovers via
# continue-injector.ps1 (Mode-B under wind-down, Mode-C, Mode-D under cliff)
# or session-self-reboot (Mode-B over wind-down, Mode-D over cliff).
# Ported from orch v2.2.0 (verbatim with STOCKFORGE_* env rename + ORCH_* fallback).
# Mode-D = clean-handoff (S14 mid-session add per user "why not autonomous continue?").
# Detects: no A/B/C suspected + checkpoints/latest.md mtime within last 60s + autonomous_mode=true.
# Pairs the existing failure-mode recovery with end-of-session continuation (clean session boundary).

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_DIR="$PROJECT_DIR/agent-workspace/memory"
mkdir -p "$LOG_DIR"
WATCHDOG_LOG="$LOG_DIR/.autonomous-stop-watchdog.log"
TS="$(date -Iseconds 2>/dev/null || date)"

# 1. Are we in autonomous mode?
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
if [[ ! -f "$EXEC_FILE" ]]; then exit 0; fi
if ! grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then exit 0; fi

# 2. Read Stop hook stdin (jq preferred; bash regex fallback for Windows-without-jq).
STDIN_JSON="$(cat 2>/dev/null || true)"
TRANSCRIPT_PATH=""
SESSION_ID=""
if [[ -n "$STDIN_JSON" ]]; then
  if command -v jq >/dev/null 2>&1; then
    TRANSCRIPT_PATH="$(printf '%s' "$STDIN_JSON" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
    SESSION_ID="$(printf '%s' "$STDIN_JSON" | jq -r '.session_id // empty' 2>/dev/null || true)"
  else
    if [[ "$STDIN_JSON" =~ \"transcript_path\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
      TRANSCRIPT_PATH="${BASH_REMATCH[1]}"
    fi
    if [[ "$STDIN_JSON" =~ \"session_id\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
      SESSION_ID="${BASH_REMATCH[1]}"
    fi
  fi
fi

# 3. Inspect last assistant text for narration-as-action / API error / premature-windown / self-pause.
NARRATION_HIT=""
SELF_PAUSE_HIT=""
API_ERROR_HIT=""
API_REQUEST_ID=""
PREMATURE_WINDOWN_HIT=""
REAL_TRANSCRIPT_TOKENS=""
WIND_DOWN_MARKER=""
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  LAST_TAIL="$(tail -c 8192 "$TRANSCRIPT_PATH" 2>/dev/null || true)"
  # Failure mode A: narration verbs WITHOUT tool_use block in same tail.
  if printf '%s' "$LAST_TAIL" | grep -qiE '(Dispatching|Now running|Now dispatching|Will dispatch|Will run|Awaiting (sandwich|task|spec|code|systematic|verifier|reviewer|implementer))' ; then
    if ! printf '%s' "$LAST_TAIL" | grep -qE '"type":"tool_use"' ; then
      NARRATION_HIT="suspected"
    fi
  fi
  # Failure mode E (S44 user-observed): self-pause pattern — LLM explicitly abdicates
  # in autonomous-full mode by saying "wait for fresh session" / "session boundary" /
  # "Stop hook handles" instead of executing next-action. Distinct from narration_hit
  # (which is "I will do X" without doing X); self-pause is "I'll stop here, fresh
  # context picks up next session" without dispatching anything. Mode-D continue-injector
  # types "continue" but LLM self-pauses again → infinite no-progress loop.
  if printf '%s' "$LAST_TAIL" | grep -qiE '(Holding here|holding at this point|next session.{0,30}(job|task|work|pick.up|trigger|start)|fresh (context|session) picks up|fresh session.{0,30}(trigger|entry|start)|session boundary|Stop hook.{0,30}(handles|takes over|fires)|wait for.{0,30}(fresh|next) session|S[0-9]+ entry is.{0,30}next)' ; then
    if ! printf '%s' "$LAST_TAIL" | grep -qE '"type":"tool_use"' ; then
      SELF_PAUSE_HIT="suspected"
    fi
  fi
  # Failure mode B: Anthropic API error truncating stream.
  if printf '%s' "$LAST_TAIL" | grep -qE '(overloaded_error|"type":"error".*"Overloaded"|rate_limit_error|api_error|"status":5[0-9][0-9])' ; then
    API_ERROR_HIT="suspected"
    API_REQUEST_ID="$(printf '%s' "$LAST_TAIL" | grep -oE '"request_id":"req_[A-Za-z0-9]+"' | head -1 | sed 's/.*"\(req_[A-Za-z0-9]*\)".*/\1/')"
  fi
  # Failure mode C: premature wind-down — wind-down language but real tokens < 200K and no marker.
  TOKENS_FILE="$LOG_DIR/.transcript-tokens"
  WIND_DOWN_FILE="$LOG_DIR/.wind-down"
  if [[ -f "$TOKENS_FILE" ]]; then
    REAL_TRANSCRIPT_TOKENS="$(tr -d '[:space:]' < "$TOKENS_FILE" 2>/dev/null || true)"
  fi
  if [[ -f "$WIND_DOWN_FILE" ]]; then WIND_DOWN_MARKER="present"; fi
  WIND_DOWN_LANGUAGE=""
  if printf '%s' "$LAST_TAIL" | grep -qiE '(approaching.{0,20}(200K|wind-down|wind down)|past 150K|fresh envelope|fresh budget|writing checkpoint|ending turn cleanly|reboot.{0,30}(envelope|budget|next))' ; then
    WIND_DOWN_LANGUAGE="suspected"
  fi
  if [[ "$WIND_DOWN_LANGUAGE" == "suspected" && -z "$WIND_DOWN_MARKER" && -n "$REAL_TRANSCRIPT_TOKENS" ]]; then
    if [[ "$REAL_TRANSCRIPT_TOKENS" =~ ^[0-9]+$ ]] && (( REAL_TRANSCRIPT_TOKENS < 180000 )); then
      PREMATURE_WINDOWN_HIT="suspected"
    fi
  fi
fi

# 4. Append structured warning line.
{
  printf '[%s] STOP autonomous_mode=true session=%s narration_hit=%s self_pause_hit=%s api_error=%s request_id=%s premature_windown=%s real_tokens=%s wind_down_marker=%s transcript=%s\n' \
    "$TS" "${SESSION_ID:-unknown}" "${NARRATION_HIT:-clean}" "${SELF_PAUSE_HIT:-clean}" "${API_ERROR_HIT:-clean}" "${API_REQUEST_ID:-none}" "${PREMATURE_WINDOWN_HIT:-clean}" "${REAL_TRANSCRIPT_TOKENS:-unknown}" "${WIND_DOWN_MARKER:-absent}" "${TRANSCRIPT_PATH:-unknown}"
} >> "$WATCHDOG_LOG"

# 4b. Self-pause-mode-E alert (Mode-D continue-injector still fires; this just makes
# the pattern visible deterministically so future occurrences can't hide).
if [[ "$SELF_PAUSE_HIT" == "suspected" ]]; then
  ALERT_FILE="$LOG_DIR/.autonomous-self-pause-alert.log"
  {
    printf '[%s] LIKELY MODE-E SELF-PAUSE STOP. session=%s real_tokens=%s. LLM self-paused at session boundary in autonomous-full mode (deferring to "fresh session" instead of executing checkpoint NEXT-ACTIONS). Mode-D continue-injector will fire normally; LLM-side policy enforcement required (see ~/memory/autonomous_continue_no_self_pause.md + agent-notes L-S44-1).\n' \
      "$TS" "${SESSION_ID:-unknown}" "${REAL_TRANSCRIPT_TOKENS:-unknown}"
  } >> "$ALERT_FILE"
fi

# 5. API-error alert.
if [[ "$API_ERROR_HIT" == "suspected" ]]; then
  ALERT_FILE="$LOG_DIR/.autonomous-api-error-alert.log"
  {
    printf '[%s] LIKELY API-TRUNCATION STOP. session=%s request_id=%s. Loop state may be inconsistent — re-derive next-action from checkpoints/latest.md before resuming.\n' \
      "$TS" "${SESSION_ID:-unknown}" "${API_REQUEST_ID:-unknown}"
  } >> "$ALERT_FILE"
fi

# === Mode-B auto-recovery (under wind-down → continue-injector; over → reboot) ===
DRY_RUN="${STOCKFORGE_RECOVERY_DRY_RUN:-${ORCH_RECOVERY_DRY_RUN:-0}}"
WIND_DOWN_THR="${STOCKFORGE_WIND_DOWN_TOKENS:-${ORCH_WIND_DOWN_TOKENS:-180000}}"

if [[ "$API_ERROR_HIT" == "suspected" ]]; then
  RECOVERY_KEY="${API_REQUEST_ID:-${SESSION_ID:-unknown}-$(date +%Y%m%d%H%M)}"
  RECOVERY_MARKER="$LOG_DIR/.api-truncation-recovery-fired-$RECOVERY_KEY"
  if [[ ! -f "$RECOVERY_MARKER" ]]; then
    REAL_TOK="$(tr -d '[:space:]' < "$LOG_DIR/.transcript-tokens" 2>/dev/null || echo 0)"
    [[ "$REAL_TOK" =~ ^[0-9]+$ ]] || REAL_TOK=0

    if (( REAL_TOK >= WIND_DOWN_THR )); then
      RECOVERY_MODE="reboot"
      RECOVERY_CMD=( bash "$PROJECT_DIR/scripts/session-self-reboot.sh" )
    else
      if [[ -f "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" ]] && command -v powershell.exe >/dev/null 2>&1; then
        RECOVERY_MODE="injector"
        RECOVERY_CMD=( powershell.exe -ExecutionPolicy Bypass -File "$(cygpath -w "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" 2>/dev/null || printf '%s' "$PROJECT_DIR/scripts/hooks/continue-injector.ps1")" )
      else
        RECOVERY_MODE="reboot-fallback"
        RECOVERY_CMD=( bash "$PROJECT_DIR/scripts/session-self-reboot.sh" )
      fi
    fi

    mkdir -p "$LOG_DIR"
    {
      printf 'fired_at=%s\nrequest_id=%s\nsession=%s\nreal_tokens=%s\nmode=%s\n' \
        "$TS" "${API_REQUEST_ID:-none}" "${SESSION_ID:-unknown}" "$REAL_TOK" "$RECOVERY_MODE"
    } > "$RECOVERY_MARKER"

    HANDOFF_LOG="$PROJECT_DIR/agent-workspace/memory/handoff-logs/api-truncation-recovery-$(date +%s)-$RECOVERY_KEY.log"
    mkdir -p "$(dirname "$HANDOFF_LOG")"
    if [[ "$DRY_RUN" != "1" ]]; then
      timeout 8 "${RECOVERY_CMD[@]}" >> "$HANDOFF_LOG" 2>&1 || true
    fi

    {
      printf '[%s] AUTO-RECOVERY FIRED. session=%s request_id=%s real_tokens=%s mode=%s marker=%s\n' \
        "$TS" "${SESSION_ID:-unknown}" "${API_REQUEST_ID:-unknown}" "$REAL_TOK" "$RECOVERY_MODE" "$(basename "$RECOVERY_MARKER")"
    } >> "$LOG_DIR/.autonomous-api-error-alert.log"
  fi
fi

# 6. Premature wind-down alert.
if [[ "$PREMATURE_WINDOWN_HIT" == "suspected" ]]; then
  ALERT_FILE="$LOG_DIR/.autonomous-premature-windown-alert.log"
  {
    printf '[%s] LIKELY MODE-C PREMATURE WIND-DOWN STOP. session=%s real_tokens=%s (threshold=180000) wind_down_marker=absent. Loop dead — task-notification will not arrive. RESUME via checkpoints/latest.md and dispatch next subagent.\n' \
      "$TS" "${SESSION_ID:-unknown}" "${REAL_TRANSCRIPT_TOKENS:-unknown}"
  } >> "$ALERT_FILE"
fi

# === Mode-C auto-recovery (Windows-only; under wind-down → continue-injector) ===
if [[ "$PREMATURE_WINDOWN_HIT" == "suspected" ]]; then
  MODE_C_KEY="${SESSION_ID:-unknown}-$(date +%Y%m%d%H%M)"
  MODE_C_MARKER="$LOG_DIR/.mode-c-recovery-fired-$MODE_C_KEY"
  if [[ ! -f "$MODE_C_MARKER" ]]; then
    if [[ -f "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" ]] && command -v powershell.exe >/dev/null 2>&1; then
      MODE_C_RECOVERY_MODE="injector"
      MODE_C_CMD=( powershell.exe -ExecutionPolicy Bypass -File "$(cygpath -w "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" 2>/dev/null || printf '%s' "$PROJECT_DIR/scripts/hooks/continue-injector.ps1")" )
    else
      MODE_C_RECOVERY_MODE="skip-non-windows"
      MODE_C_CMD=()
    fi

    {
      printf 'fired_at=%s\nsession=%s\nreal_tokens=%s\nmode=%s\n' \
        "$TS" "${SESSION_ID:-unknown}" "${REAL_TRANSCRIPT_TOKENS:-unknown}" "$MODE_C_RECOVERY_MODE"
    } > "$MODE_C_MARKER"

    if [[ "$MODE_C_RECOVERY_MODE" == "injector" && "$DRY_RUN" != "1" ]]; then
      rm -f "$LOG_DIR"/.continue-fired-* 2>/dev/null || true
      MODE_C_HANDOFF_LOG="$PROJECT_DIR/agent-workspace/memory/handoff-logs/mode-c-recovery-$(date +%s)-$MODE_C_KEY.log"
      mkdir -p "$(dirname "$MODE_C_HANDOFF_LOG")"
      timeout 8 "${MODE_C_CMD[@]}" >> "$MODE_C_HANDOFF_LOG" 2>&1 || true
    fi

    {
      printf '[%s] MODE-C AUTO-RECOVERY FIRED. session=%s real_tokens=%s mode=%s marker=%s\n' \
        "$TS" "${SESSION_ID:-unknown}" "${REAL_TRANSCRIPT_TOKENS:-unknown}" "$MODE_C_RECOVERY_MODE" "$(basename "$MODE_C_MARKER")"
    } >> "$LOG_DIR/.autonomous-premature-windown-alert.log"
  fi
fi

# === Mode-D auto-recovery (clean handoff — checkpoint just written within last 60s) ===
# Triggers when session ends cleanly (no A/B/C suspected) AND latest checkpoint mtime is recent.
# Recovery: tokens >= cliff (220K default) → session-self-reboot.sh (full reboot for fresh envelope);
#           tokens < cliff → continue-injector.ps1 (just nudge "continue" to TUI).
# L-S10-1 patterns: if/then/fi only; defensive integer validation.
CLIFF_THR="${STOCKFORGE_CLIFF_TOKENS:-${ORCH_CLIFF_TOKENS:-220000}}"
CHECKPOINT_FILE="$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md"

MODE_D_FIRE=0
CKPT_EPOCH=0
AGE_SEC=-1
if [[ -z "${API_ERROR_HIT:-}" ]] && [[ -z "${PREMATURE_WINDOWN_HIT:-}" ]]; then
  if [[ -f "$CHECKPOINT_FILE" ]]; then
    NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"
    CKPT_EPOCH="$(stat -c '%Y' "$CHECKPOINT_FILE" 2>/dev/null || echo 0)"
    if [[ "$NOW_EPOCH" =~ ^[0-9]+$ ]] && [[ "$CKPT_EPOCH" =~ ^[0-9]+$ ]]; then
      AGE_SEC=$(( NOW_EPOCH - CKPT_EPOCH ))
      if [[ "$AGE_SEC" -ge 0 ]] && [[ "$AGE_SEC" -le 60 ]]; then
        MODE_D_FIRE=1
      fi
    fi
  fi
fi

if [[ "$MODE_D_FIRE" -eq 1 ]]; then
  MODE_D_KEY="${SESSION_ID:-unknown}-${CKPT_EPOCH}"
  MODE_D_MARKER="$LOG_DIR/.mode-d-recovery-fired-$MODE_D_KEY"
  if [[ ! -f "$MODE_D_MARKER" ]]; then
    REAL_TOK_D=0
    if [[ -f "$LOG_DIR/.transcript-tokens" ]]; then
      REAL_TOK_D="$(tr -d '[:space:]' < "$LOG_DIR/.transcript-tokens" 2>/dev/null || echo 0)"
      if ! [[ "$REAL_TOK_D" =~ ^[0-9]+$ ]]; then REAL_TOK_D=0; fi
    fi

    MODE_D_RECOVERY_MODE="skip-non-windows"
    MODE_D_CMD=()
    if (( REAL_TOK_D >= CLIFF_THR )); then
      MODE_D_RECOVERY_MODE="reboot-handoff"
      MODE_D_CMD=( bash "$PROJECT_DIR/scripts/session-self-reboot.sh" )
    else
      if [[ -f "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" ]] && command -v powershell.exe >/dev/null 2>&1; then
        MODE_D_RECOVERY_MODE="injector-handoff"
        MODE_D_CMD=( powershell.exe -ExecutionPolicy Bypass -File "$(cygpath -w "$PROJECT_DIR/scripts/hooks/continue-injector.ps1" 2>/dev/null || printf '%s' "$PROJECT_DIR/scripts/hooks/continue-injector.ps1")" )
      fi
    fi

    {
      printf 'fired_at=%s\nsession=%s\ncheckpoint_mtime=%s\nage_sec=%s\nreal_tokens=%s\ncliff_thr=%s\nmode=%s\n' \
        "$TS" "${SESSION_ID:-unknown}" "$CKPT_EPOCH" "$AGE_SEC" "$REAL_TOK_D" "$CLIFF_THR" "$MODE_D_RECOVERY_MODE"
    } > "$MODE_D_MARKER"

    if [[ "$MODE_D_RECOVERY_MODE" != "skip-non-windows" ]] && [[ "$DRY_RUN" != "1" ]]; then
      rm -f "$LOG_DIR"/.continue-fired-* 2>/dev/null || true
      MODE_D_HANDOFF_LOG="$PROJECT_DIR/agent-workspace/memory/handoff-logs/mode-d-handoff-$(date +%s)-$MODE_D_KEY.log"
      mkdir -p "$(dirname "$MODE_D_HANDOFF_LOG")"
      timeout 8 "${MODE_D_CMD[@]}" >> "$MODE_D_HANDOFF_LOG" 2>&1 || true
    fi

    {
      printf '[%s] MODE-D CLEAN-HANDOFF FIRED. session=%s checkpoint_age=%ss real_tokens=%s cliff=%s mode=%s marker=%s\n' \
        "$TS" "${SESSION_ID:-unknown}" "$AGE_SEC" "$REAL_TOK_D" "$CLIFF_THR" "$MODE_D_RECOVERY_MODE" "$(basename "$MODE_D_MARKER")"
    } >> "$WATCHDOG_LOG"
  fi
fi

exit 0
