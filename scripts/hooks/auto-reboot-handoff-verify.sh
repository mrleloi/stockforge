#!/usr/bin/env bash
# auto-reboot-handoff-verify.sh — HH-H.4 Stop hook (S48m)
#
# Purpose: BEFORE budget-watchdog.sh fires session-self-reboot at wind-down or
# cliff, verify checkpoints/latest.md is fresh enough to absorb a /clear+resume.
# If checkpoint mtime >2h stale AND we're at a threshold where reboot is
# imminent, BLOCK the reboot path (emit pre-block marker that watchdog honors)
# and surface URGENT notification so the agent writes a checkpoint first.
#
# Layered with HH-H.1 (5-min strict guard inside session-self-reboot.sh):
#   - HH-H.4 = soft outer fence (2h threshold; block before watchdog spawns)
#   - HH-H.1 = hard inner fence (5min; refuse if reboot somehow still fires)
# Defense-in-depth per autonomous-protocol § Drift recovery flow.
#
# Block mechanism: writes .auto-reboot-PRE-BLOCKED-stale-checkpoint marker.
# budget-watchdog.sh checks for this marker and skips spawn while preserving
# its own once-only markers untouched (so threshold doesn't get "consumed"
# silently — next session sees clean budget slate via SessionStart reset).
#
# Bash + POSIX only per L-S11-1.
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
CHECKPOINT="$MEM_DIR/checkpoints/latest.md"
TOKEN_FILE="$MEM_DIR/.transcript-tokens"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
URGENT="$NOTIF_DIR/urgent.md"
PRE_BLOCK_MARKER="$MEM_DIR/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

mkdir -p "$MEM_DIR"

# Threshold envs — match budget-watchdog defaults.
WIND_DOWN="${STOCKFORGE_WIND_DOWN_TOKENS:-${ORCH_WIND_DOWN_TOKENS:-180000}}"
CLIFF="${STOCKFORGE_CLIFF_TOKENS:-${ORCH_CLIFF_TOKENS:-220000}}"
STALE_THRESHOLD_S=7200  # 2 hours

# Need budget-watchdog's last-computed token count. If absent, this hook is
# a no-op (watchdog will compute on this Stop tick; first run benign).
[ ! -f "$TOKEN_FILE" ] && exit 0
TOTAL=$(cat "$TOKEN_FILE" 2>/dev/null | tr -d '[:space:]')
[ -z "$TOTAL" ] && exit 0

# Only act if approaching wind-down or beyond.
if [ "$TOTAL" -lt "$WIND_DOWN" ]; then
  exit 0
fi

# Checkpoint freshness check.
if [ ! -f "$CHECKPOINT" ]; then
  STALE_AGE_S=999999  # treat missing as ancient
else
  CP_MTIME=$(stat -c %Y "$CHECKPOINT" 2>/dev/null || stat -f %m "$CHECKPOINT" 2>/dev/null || echo 0)
  STALE_AGE_S=$(( $(date +%s) - CP_MTIME ))
fi

if [ "$STALE_AGE_S" -le "$STALE_THRESHOLD_S" ]; then
  # Checkpoint is fresh; clear any prior pre-block marker so watchdog can fire normally.
  rm -f "$PRE_BLOCK_MARKER"
  exit 0
fi

# Stale checkpoint near reboot threshold — write pre-block marker so watchdog skips spawn.
printf 'pre_blocked_at=%s session_id=%s\ntokens=%s wind_down=%s cliff=%s\ncheckpoint_age_s=%s threshold_s=%s\n' \
  "$TS" "${CLAUDE_SESSION_ID:-unknown}" "$TOTAL" "$WIND_DOWN" "$CLIFF" "$STALE_AGE_S" "$STALE_THRESHOLD_S" \
  > "$PRE_BLOCK_MARKER"

printf '[%s] auto-reboot-handoff-verify: BLOCKED reboot tokens=%s checkpoint_age_s=%s (>%ss) — wrote .auto-reboot-PRE-BLOCKED-stale-checkpoint\n' \
  "$TS" "$TOTAL" "$STALE_AGE_S" "$STALE_THRESHOLD_S" >> "$HOOK_LOG"

# Emit URGENT notification.
mkdir -p "$NOTIF_DIR"
{
  printf '\n## [%s] HH-H.4 AUTO-REBOOT BLOCKED — STALE CHECKPOINT\n\n' "$TS"
  printf '**Session**: %s\n' "${CLAUDE_SESSION_ID:-unknown}"
  printf '**Tokens**: %s (wind_down=%s cliff=%s)\n' "$TOTAL" "$WIND_DOWN" "$CLIFF"
  printf '**Checkpoint age**: %s seconds (>%s threshold)\n' "$STALE_AGE_S" "$STALE_THRESHOLD_S"
  printf '\n**Action required**: write a fresh `agent-workspace/memory/checkpoints/latest.md` BEFORE the next reboot fires. Auto-reboot path is blocked until the marker `.auto-reboot-PRE-BLOCKED-stale-checkpoint` is cleared — happens automatically once checkpoint mtime is within 2h.\n\n'
  printf '**Override**: set `STOCKFORGE_FORCE_REBOOT=1` env to bypass HH-H.1 strict guard if manual reboot needed.\n'
} >> "$URGENT"

exit 0
