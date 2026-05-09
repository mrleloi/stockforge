#!/usr/bin/env bash
# continue-injector-spawn.sh — SessionStart hook that spawns DETACHED continue-injector
# script to SendKeys "continue" into the fresh Claude Code TUI.
#
# Extracted from session-start-bootstrap.sh:127-201 (S184 D-042) — separated as its own
# Stop-of-chain hook because the nested powershell.exe Start-Process spawn was empirically
# observed to truncate Claude Code's SessionStart hook chain on Windows after the spawning
# hook completes (S183 root-cause finding). By placing this spawn LAST in the chain, the
# truncation can no longer suppress the 13 hooks that previously sat between bootstrap and
# the chain end (vendor-api-probe through harness-health-self-scan).
#
# Wired LAST in .claude/settings.json SessionStart matcher startup|resume|clear chain.
# Earlier upstream hook (`session-start-bootstrap.sh`) still writes additionalContext +
# .session-ready file; this hook only handles the platform-detached SendKeys spawn.
#
# GATING (preserved verbatim from S8 revision per user "no continue, why? fix" + S48m HH-H.3):
#   source=clear  → fire if STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=1 OR autonomous_mode=true
#   source=resume → fire UNCONDITIONALLY (user invoked claude --resume → expects continuation)
#   source=startup → gated by autonomous_mode=true (fresh launch; user likely typing own prompt)
#
# Phase 0 portability: bash + POSIX only (L-S11-1). No -e (need clean exit 0 even when
# powershell.exe spawn fails so hook chain doesn't error-cascade).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PAYLOAD=$(cat)
SOURCE=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).source||''); } catch { console.log(''); } });" 2>/dev/null || echo "")

case "$SOURCE" in
  startup|resume|clear) ;;
  *) exit 0 ;;
esac

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
  echo "[$(date -Iseconds)] continue-injector-spawn FIRED ($FIRE_REASON)" >> "$HOOK_LOG"
else
  echo "[$(date -Iseconds)] continue-injector-spawn SKIPPED ($FIRE_REASON)" >> "$HOOK_LOG"
fi

exit 0
