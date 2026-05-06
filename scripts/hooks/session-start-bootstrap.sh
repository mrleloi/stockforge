#!/usr/bin/env bash
# session-start-bootstrap.sh — SessionStart hook injecting stockforge resume context.
# Wired as SessionStart in .claude/settings.json (matcher: startup|resume|clear).
# Reads payload, emits hookSpecificOutput.additionalContext pointing model at latest checkpoint.
# Also: spawns continue-injector.ps1 (Windows) so fresh session gets first prompt.
# Ported from orch v2.2.0; adapted paths (phase-1-core.md → docs/DAY_1_CHECKLIST.md) +
# removed orch worktree sweep + added queued-grill-master fire_when scan.
set -euo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
CHECKPOINT_DIR="$PROJECT_DIR/agent-workspace/memory/checkpoints"
LATEST="$CHECKPOINT_DIR/latest.md"

mkdir -p "$PROJECT_DIR/agent-workspace/memory"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

PAYLOAD=$(cat)
SOURCE=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).source||''); } catch { console.log(''); } });" 2>/dev/null || echo "")

echo "[$(date -Iseconds)] SessionStart-bootstrap source=$SOURCE latest_exists=$([ -f "$LATEST" ] && echo yes || echo no)" >> "$HOOK_LOG"

case "$SOURCE" in
  startup|resume|clear) ;;
  *) exit 0 ;;
esac

[ -f "$LATEST" ] || exit 0

# Reset once-only watchdog markers so new session has clean budget slate.
rm -f "$PROJECT_DIR/agent-workspace/memory/.cliff-fired" \
      "$PROJECT_DIR/agent-workspace/memory/.wind-down" \
      "$PROJECT_DIR/agent-workspace/memory/.wind-down-fired"

# Proactive parse-check session-self-reboot.ps1 on Windows so encoding bugs surface
# BEFORE wind-down hits (avoid silent reboot block).
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    PS_SCRIPT="$PROJECT_DIR/scripts/session-self-reboot.ps1"
    if [ -f "$PS_SCRIPT" ] && command -v powershell.exe >/dev/null 2>&1; then
      PS_SCRIPT_WIN="$(cygpath -w "$PS_SCRIPT" 2>/dev/null || printf '%s' "$PS_SCRIPT")"
      PARSE_OUT=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
        "try { \$null = [scriptblock]::Create((Get-Content -Raw -Path '$PS_SCRIPT_WIN')); 'PARSE_OK' } catch { 'PARSE_FAIL: ' + \$_.Exception.Message }" \
        2>&1 | tr -d '\r' | head -1 || echo "PARSE_FAIL: powershell.exe invocation failed")
      if ! printf '%s' "$PARSE_OUT" | grep -q '^PARSE_OK'; then
        printf 'AUTO-REBOOT FAILED at %s (SessionStart proactive parse-check)\nReason: PowerShell parser cannot load session-self-reboot.ps1.\nParse output: %s\nFile: %s\nAction: investigate scripts/session-self-reboot.ps1.\n' \
          "$(date -Iseconds)" "$PARSE_OUT" "$PS_SCRIPT_WIN" \
          > "$PROJECT_DIR/agent-workspace/memory/.auto-reboot-FAILED"
        echo "[$(date -Iseconds)] SessionStart-bootstrap PROACTIVE PARSE-CHECK FAILED: $PARSE_OUT" >> "$HOOK_LOG"
      else
        echo "[$(date -Iseconds)] SessionStart-bootstrap parse-check OK on session-self-reboot.ps1" >> "$HOOK_LOG"
      fi
    fi
    ;;
esac

# === Queued-grill master fire_when scan (UP-06 doctrine, S3 Track 5 deliverable) ===
# Reads queued-grill-master.md; emits notification line for each entry whose fire_when matches
# the active phase/track. Agent decides timing — hook surfaces, doesn't auto-fire AskUserQuestion.
QUEUED_GRILL_FILE="$PROJECT_DIR/agent-workspace/memory/observations/queued-grill-master.md"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
if [ -f "$QUEUED_GRILL_FILE" ] && [ -f "$EXEC_FILE" ]; then
  ACTIVE_PHASE=$(awk -F': ' '/^\*\*Phase\*\*/ {print $2; exit}' "$EXEC_FILE" 2>/dev/null || true)
  # ACTIVE_SESSION: extract LARGEST `## S<N>` header — real file format (per L-S51-1 / M-S52-1 fix at S53).
  # Prior bug (M-S52-1): awked for `^**Session N**` literal which never appears in real file
  # → ACTIVE_SESSION silently empty → queued-grill awk matcher (line ~75 below) `sess != ""`
  # branch never executed → session-token fire_when entries (e.g. "S20+", "S52", "S5 Track 7")
  # silently never fired in production. Track-based matching kept working (ACTIVE_TRACK line below).
  ACTIVE_SESSION_NUM=$(grep -oE '^## S[0-9]+' "$EXEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1 || true)
  ACTIVE_SESSION="${ACTIVE_SESSION_NUM:+S$ACTIVE_SESSION_NUM}"
  # KI-S56-1 STRUCTURAL FIX SHIPPED S57 (was deferred at S56). Prior bug:
  # `grep -oE 'Track [0-9]+' | head -1` on whole file returned archive-prose
  # Track ref (e.g. "Track 5" from S53 narrative) instead of currently-active
  # Track. Per L-S56-1 3-class typology: target is Class B free-form-prose-in-
  # markdown, so `^` anchor advice from Check 8 was INVALID (Track refs don't
  # line-anchor in this file format). Real fix is structural — parse the
  # "## Active Focus Track" section bounded by next `---` separator FIRST via
  # awk range pattern, then grep section-content only. Archive prose lives
  # OUTSIDE the section so head -1 picks active Track ref, or empty if Phase
  # 3.5 uses T<N> shorthand exclusively (also correct: ACTIVE_TRACK="" → no
  # spurious match in queued-grill awk per `track != ""` guard line ~98).
  # `|| true` end-of-pipeline preserved (L-S48d-1 pipefail+ERR-trap discipline).
  ACTIVE_TRACK=$(awk '/^## Active Focus Track/,/^---/' "$EXEC_FILE" 2>/dev/null | grep -oE 'Track [0-9]+' | head -1 || true)
  GRILL_QUEUE_LOG="$PROJECT_DIR/agent-workspace/memory/.queued-grill-fired.log"
  # Match entries whose fire_when contains active session "S<N>" or track "Track <N>" tokens.
  awk -v phase="$ACTIVE_PHASE" -v sess="$ACTIVE_SESSION" -v track="$ACTIVE_TRACK" '
    /^### Q-/ { qid=$2; in_entry=1; fire_when=""; next }
    in_entry && /^- \*\*fire_when\*\*:/ {
      sub(/^- \*\*fire_when\*\*: */,""); fire_when=$0;
      match_hit=0;
      if (sess  != "" && index(fire_when, sess)  > 0) match_hit=1
      if (track != "" && index(fire_when, track) > 0) match_hit=1
      if (match_hit) print "[queued-grill] " qid " fire_when=" fire_when
    }
    /^### / && !/^### Q-/ { in_entry=0 }
  ' "$QUEUED_GRILL_FILE" >> "$GRILL_QUEUE_LOG" 2>/dev/null || true
fi

# Build resume context.
CONTEXT="STOCKFORGE AUTONOMOUS RESUME: SessionStart hook fired. \
Read these in order before any tool call: \
(1) $LATEST [handoff checkpoint with current phase/track/next_action], \
(2) $PROJECT_DIR/CLAUDE.md [project rules: NO LLM math, every claim has source+as-of, deterministic risk, multi-perspective adversarial], \
(3) $PROJECT_DIR/PROJECT_CHARTER.md [immutable invariants I-S1..I-S35], \
(4) $PROJECT_DIR/agent-workspace/memory/current-execution.md [routing + active phase/track], \
(5) $PROJECT_DIR/agent-workspace/memory/observations/queued-grill-master.md [check fire_when triggers matching active context], \
(6) Active session plan via current-execution.md routing table. \
Then resume at checkpoint's next_action. Do NOT commit (CLAUDE.md hard rule). For Agent dispatches: run_in_background=true."

node -e "
const ctx = process.argv[1];
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'SessionStart',
    additionalContext: ctx
  }
}));
" "$CONTEXT"

echo "[$(date -Iseconds)] SessionStart-bootstrap injected additionalContext" >> "$HOOK_LOG"

printf 'ready_at=%s\nsession_id=%s\nsource=%s\n' "$(date -Iseconds)" "${CLAUDE_SESSION_ID:-unknown}" "$SOURCE" \
  > "$PROJECT_DIR/agent-workspace/memory/.session-ready"

# Spawn DETACHED continue-injector that SendKeys "continue" to fresh TUI.
# GATING (S8 revision per user "no continue, why? fix" complaint, supersedes S7 unconditional gate):
#   source=clear  → fire UNCONDITIONALLY (explicit user /clear → expects checkpoint resume; race risk low)
#   source=resume → fire UNCONDITIONALLY (user invoked claude --resume → expects continuation)
#   source=startup → gated by autonomous_mode=true (fresh launch; user likely typing own prompt → race risk high)
# stale-prompt-detector.sh line 26 short-circuits literal "continue" prompt → no false stale-warning firing.
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
AUTONOMOUS_MODE="false"
if [ -f "$EXEC_FILE" ]; then
  AUTONOMOUS_MODE=$(awk -F': ' '/^\*\*autonomous_mode\*\*/ {print $2; exit}' "$EXEC_FILE" 2>/dev/null \
    | awk '{print $1}' | tr -d '*' || echo "false")
  AUTONOMOUS_MODE="${AUTONOMOUS_MODE:-false}"
fi

SHOULD_FIRE_INJECTOR="false"
FIRE_REASON=""
case "$SOURCE" in
  clear)
    # HH-H.3 (S48m): gate clear-branch by autonomous_mode + STOCKFORGE_FORCE_CONTINUE_ON_CLEAR
    # override. Pre-S48m unconditionally fired — but a user-driven /clear with
    # autonomous_mode=false (post-Phase-2.5 ratification gate) would race against
    # the human typing their own first prompt. Override env var keeps the explicit-
    # user-flow path fast.
    if [ "${STOCKFORGE_FORCE_CONTINUE_ON_CLEAR:-0}" = "1" ]; then
      SHOULD_FIRE_INJECTOR="true"
      FIRE_REASON="source=clear + STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=1 (override)"
    elif [ "$AUTONOMOUS_MODE" = "true" ]; then
      SHOULD_FIRE_INJECTOR="true"
      FIRE_REASON="source=clear + autonomous_mode=true"
    else
      FIRE_REASON="source=clear + autonomous_mode=false (HH-H.3 gate; user-driven /clear → race risk)"
    fi
    ;;
  resume)
    SHOULD_FIRE_INJECTOR="true"
    FIRE_REASON="source=resume (user invoked claude --resume)"
    ;;
  startup)
    if [ "$AUTONOMOUS_MODE" = "true" ]; then
      SHOULD_FIRE_INJECTOR="true"
      FIRE_REASON="source=startup + autonomous_mode=true"
    else
      FIRE_REASON="source=startup + autonomous_mode=false (race risk with user typing)"
    fi
    ;;
esac

if [ "$SHOULD_FIRE_INJECTOR" = "true" ]; then
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      PS_SCRIPT="$(cygpath -w "$PROJECT_DIR/scripts/hooks/continue-injector.ps1")"
      powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass \
        -Command "Start-Process -WindowStyle Hidden -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$PS_SCRIPT'" \
        >/dev/null 2>&1 &
      disown 2>/dev/null || true
      ;;
    Darwin)
      nohup osascript -e 'delay 2.5' \
        -e 'tell application "System Events" to keystroke "continue"' \
        -e 'tell application "System Events" to key code 36' \
        >/dev/null 2>&1 &
      disown 2>/dev/null || true
      ;;
    Linux)
      if command -v xdotool >/dev/null 2>&1; then
        ( sleep 2.5; xdotool type --delay 30 "continue"; xdotool key Return ) \
          >/dev/null 2>&1 &
        disown 2>/dev/null || true
      fi
      ;;
  esac
  echo "[$(date -Iseconds)] SessionStart-bootstrap spawned continue-injector ($FIRE_REASON)" >> "$HOOK_LOG"
else
  echo "[$(date -Iseconds)] SessionStart-bootstrap SKIPPED continue-injector ($FIRE_REASON)" >> "$HOOK_LOG"
fi

exit 0
