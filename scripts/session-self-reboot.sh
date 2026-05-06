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

# === HH-H.1 stale-checkpoint guard (S48m) ===
# Refuse to fire UNLESS checkpoints/latest.md mtime within last 5 minutes.
# Forces a fresh checkpoint write before reboot — prevents auto-reboot from
# losing pending work when the agent hasn't yet handed off state.
# Override via STOCKFORGE_FORCE_REBOOT=1 (e.g. for manual smoke tests).
CHECKPOINT="$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md"
STALE_BLOCK_MARKER="$PROJECT_DIR/agent-workspace/memory/.auto-reboot-BLOCKED-stale-checkpoint"
if [ "${STOCKFORGE_FORCE_REBOOT:-0}" != "1" ]; then
  if [ ! -f "$CHECKPOINT" ]; then
    mkdir -p "$(dirname "$STALE_BLOCK_MARKER")"
    printf 'AUTO-REBOOT BLOCKED at %s\nReason: checkpoints/latest.md missing (HH-H.1 guard).\nAction: write a fresh checkpoint via /handoff-prep before reboot fires.\nOverride: set STOCKFORGE_FORCE_REBOOT=1 to bypass.\n' \
      "$(date -Iseconds)" > "$STALE_BLOCK_MARKER"
    echo "[ERROR] session-self-reboot ABORT: checkpoints/latest.md missing — refusing to fire (HH-H.1)" >&2
    exit 2
  fi
  CHECKPOINT_MTIME=$(stat -c %Y "$CHECKPOINT" 2>/dev/null || stat -f %m "$CHECKPOINT" 2>/dev/null || echo 0)
  CHECKPOINT_AGE=$(( $(date +%s) - CHECKPOINT_MTIME ))
  if [ "$CHECKPOINT_AGE" -gt 300 ]; then
    mkdir -p "$(dirname "$STALE_BLOCK_MARKER")"
    printf 'AUTO-REBOOT BLOCKED at %s\nReason: checkpoints/latest.md mtime is %ss old (>300s threshold; HH-H.1 guard).\nAction: write a fresh checkpoint via /handoff-prep before reboot fires.\nOverride: set STOCKFORGE_FORCE_REBOOT=1 to bypass.\n' \
      "$(date -Iseconds)" "$CHECKPOINT_AGE" > "$STALE_BLOCK_MARKER"
    echo "[ERROR] session-self-reboot ABORT: checkpoint stale (${CHECKPOINT_AGE}s > 300s) — refusing to fire (HH-H.1)" >&2
    exit 2
  fi
fi

# === HH-H.5a 60s rate-limit idempotency (S48m) ===
# Mirrors continue-injector.ps1 L-S48-1 pattern: prevents double-spawn when
# budget-watchdog.sh fires from BOTH Stop AND PostToolUse near cliff (TOCTOU
# on .cliff-fired marker check; M-S48e-1 //nneeww garbled keystroke root cause).
RATE_LIMIT_MARKER="$PROJECT_DIR/agent-workspace/memory/.session-self-reboot-last-fire"
if [ "${STOCKFORGE_FORCE_REBOOT:-0}" != "1" ] && [ -f "$RATE_LIMIT_MARKER" ]; then
  LAST_FIRE_MTIME=$(stat -c %Y "$RATE_LIMIT_MARKER" 2>/dev/null || stat -f %m "$RATE_LIMIT_MARKER" 2>/dev/null || echo 0)
  AGE_S=$(( $(date +%s) - LAST_FIRE_MTIME ))
  if [ "$AGE_S" -lt 60 ]; then
    echo "[INFO] session-self-reboot rate-limit: another instance fired ${AGE_S}s ago (<60s); exiting (HH-H.5a)" >&2
    exit 0
  fi
fi
mkdir -p "$(dirname "$RATE_LIMIT_MARKER")"
date -Iseconds > "$RATE_LIMIT_MARKER"

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
