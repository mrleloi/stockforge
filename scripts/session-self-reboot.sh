#!/usr/bin/env bash
# session-self-reboot.sh — cross-platform wrapper around session-self-reboot.ps1
# Sends /new keystrokes to current Claude Code TUI; fresh session bootstraps via SessionStart hook.
# Ported from orch v2.2.0 (verbatim with path adapts).
#
# Usage (from main session via Bash tool):
#   bash scripts/session-self-reboot.sh
#   bash scripts/session-self-reboot.sh "custom first prompt"  # arg ignored, kept for back-compat
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FAIL_MARKER="$PROJECT_DIR/agent-workspace/memory/.auto-reboot-FAILED"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    PS_SCRIPT_WIN="$(cygpath -w "$SCRIPT_DIR/session-self-reboot.ps1")"
    if ! powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS_SCRIPT_WIN"; then
      EXIT=$?
      mkdir -p "$(dirname "$FAIL_MARKER")"
      printf 'AUTO-REBOOT FAILED at %s\nReason: powershell.exe exited %s (script parse error / PS-level failure -- did NOT reach SendKeys).\nFile: %s\nAction: investigate session-self-reboot.ps1; common: non-ASCII (em-dash) parsed as CP1252.\nNext Stop hook: budget-watchdog.sh detects this marker and retries reboot.\n' \
        "$(date -Iseconds)" "$EXIT" "$PS_SCRIPT_WIN" > "$FAIL_MARKER"
      echo "[ERROR] session-self-reboot.ps1 exited $EXIT; wrote .auto-reboot-FAILED for watchdog retry" >&2
      exit "$EXIT"
    fi
    ;;
  Darwin)
    rm -f "$PROJECT_DIR/agent-workspace/memory/.session-ready"
    rm -f "$PROJECT_DIR"/agent-workspace/memory/.continue-fired-*
    osascript <<EOF
delay 0.4
tell application "System Events"
  keystroke "/new"
  key code 36
end tell
EOF
    ;;
  Linux)
    if ! command -v xdotool >/dev/null 2>&1; then
      echo "[ERROR] xdotool not installed; install: apt install xdotool" >&2
      exit 1
    fi
    rm -f "$PROJECT_DIR/agent-workspace/memory/.session-ready"
    rm -f "$PROJECT_DIR"/agent-workspace/memory/.continue-fired-*
    sleep 0.4
    xdotool type --delay 30 "/new"
    xdotool key Return
    ;;
  *)
    echo "[ERROR] Unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

echo "[INFO] /new + Enter sent. Fresh session will auto-bootstrap via SessionStart hook."
