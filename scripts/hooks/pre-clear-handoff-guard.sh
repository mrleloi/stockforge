#!/usr/bin/env bash
# pre-clear-handoff-guard.sh — durable handoff invariant (BP-S43b-6 / KI-S43b-6).
#
# At Stop hook (priority 1 — before aggregator), if the LATEST session log shows
# pending-decision triggers (AskUserQuestion / numbered options menu / SCOPE-tier
# deferral / wind-down threshold), AND checkpoints/latest.md is older than the
# session start, surface alert.
#
# Modes (HR-7 — hard-block opt-in):
#   default  → advisory: stderr echo + log; exit 0 (user/agent may miss it)
#   strict   → hard-signal: exit 2 (Claude Code surfaces stderr to assistant
#              transcript, forcing acknowledgement). Opt in via either:
#                STOCKFORGE_HANDOFF_HARDBLOCK=1   (per-session env)
#                STOCKFORGE_HOOK_PROFILE=strict   (project-wide profile)
#              When agent then writes a checkpoint, next Stop sees fresh mtime
#              and auto-clears the block (loop is finite, ≤1 hard-block per
#              triggering pattern).
#
# Bash + POSIX only per L-S11-1.
# User-reported failure mode: agent listed Q&A options, /clear fired, options lost.
#
# Heuristic phrases (Vietnamese + English) — append-only growth:
#   "AskUserQuestion" — agent dispatched question tool
#   "(a)" "(b)" "(c)" "(d)" — lettered option menu
#   "SCOPE-tier" "charter-tier" — deferral surface
#   "wind_down" "cliff" — budget threshold breached
#   "Q&A" "q-and-a" — pending bundle reference

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.handoff-guard.log"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
CHECKPOINT="$MEM_DIR/checkpoints/latest.md"
TS="$(date -Iseconds)"

mkdir -p "$(dirname "$LOG")"

# Find the most-recently modified session log.
LATEST_SESSION=$(find "$MEM_DIR/sessions" -name '*.md' -mmin -120 2>/dev/null | head -1 || true)

# Also check transcript via raw-sessions if available.
LATEST_RAW=$(find "$PROJECT_DIR/agent-workspace/raw-sessions" -name '*.md' -mmin -120 2>/dev/null | head -1 || true)

PENDING=0
TRIGGER_LIST=""

scan_for_triggers() {
  local file="$1"
  [ ! -f "$file" ] && return
  if grep -qiE 'AskUserQuestion|^\s*\(a\)|^\s*\(b\)|^\s*\(c\)|SCOPE-tier|charter-tier|wind_down|cliff fired|q-and-a/pending' "$file" 2>/dev/null; then
    PENDING=1
    TRIGGER_LIST="$TRIGGER_LIST $(basename "$file")"
  fi
}

scan_for_triggers "$LATEST_SESSION"
scan_for_triggers "$LATEST_RAW"

# C3 extension (BP-S43b-8): scan checkpoint for `⚠️ unverified` markers — these
# are first-action obligations on the successor session per BP-S43b-8. If
# checkpoint contains them AND no session log has been written since checkpoint
# mtime, the markers risk slipping past resolution.
UNVERIFIED_HITS=0
if [ -f "$CHECKPOINT" ] && grep -qE '⚠️ unverified|⚠ unverified|unverified ⚠' "$CHECKPOINT" 2>/dev/null; then
  UNVERIFIED_HITS=1
  PENDING=1
  TRIGGER_LIST="$TRIGGER_LIST checkpoint:unverified-marker"
fi

# Compare checkpoint mtime vs session start (heuristic: 2h ago).
CHECKPOINT_FRESH=0
if [ -f "$CHECKPOINT" ]; then
  if find "$CHECKPOINT" -mmin -120 2>/dev/null | grep -q .; then
    CHECKPOINT_FRESH=1
  fi
fi

printf '[%s] pre-clear-handoff-guard: pending=%s checkpoint_fresh=%s unverified=%s triggers=%s\n' \
  "$TS" "$PENDING" "$CHECKPOINT_FRESH" "$UNVERIFIED_HITS" "${TRIGGER_LIST:-none}" >> "$LOG"

if [ "$PENDING" -eq 1 ] && [ "$CHECKPOINT_FRESH" -eq 0 ]; then
  ALERT="pre-clear-handoff-guard ALERT: pending-decision triggers detected (${TRIGGER_LIST}) but checkpoints/latest.md is stale (>2h). Write checkpoint before /clear per BP-S43b-6."
  printf '[%s] %s\n' "$TS" "$ALERT" >> "$LOG"
  printf '[%s] pre-clear-handoff-guard: ALERT pending=1 stale_checkpoint=1\n' "$TS" >> "$HOOK_LOG"
  echo "$ALERT" >&2

  # HR-7: opt-in hard-signal via exit 2 (Claude Code surfaces stderr to
  # assistant transcript, forcing acknowledgement). Default advisory exit 0.
  if [ "${STOCKFORGE_HANDOFF_HARDBLOCK:-0}" = "1" ] || [ "${STOCKFORGE_HOOK_PROFILE:-standard}" = "strict" ]; then
    printf '[%s] pre-clear-handoff-guard: HARD-BLOCK exit=2 (strict profile)\n' "$TS" >> "$HOOK_LOG"
    exit 2
  fi
fi

exit 0
