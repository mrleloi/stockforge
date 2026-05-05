#!/usr/bin/env bash
# harness-recovery-dod-watchdog.sh — prevents premature-stop during charter-tier
# recovery arcs (KI-S43b-7 / BP-S43b-7 / L-S43b-10).
#
# Mechanism:
#   1. Scan agent-workspace/memory/current-execution.md for the ACTIVE recovery
#      row (heuristic: lines containing "HARNESS-RECOVERY" or "fix toàn diện" or
#      "HR-[0-9]" markers).
#   2. If ≥1 line within recovery row contains "⏳ PENDING" (the convention from
#      BP-S43b-7), recovery DoD is NOT MET.
#   3. ALERT to stderr in default mode; exit 2 in strict mode (agent must keep
#      working, not write tidy summary).
#
# Modes:
#   default  → stderr ALERT + log; exit 0 (advisory)
#   strict   → exit 2 when DoD-not-met (Claude Code surfaces stderr to assistant)
#              Opt in via STOCKFORGE_DOD_HARDBLOCK=1 OR STOCKFORGE_HOOK_PROFILE=strict.
#
# Bash + POSIX only per L-S11-1.
# Stop hook (after lesson-synthesis-watchdog, before promotion-cycle-trigger).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
LOG="$PROJECT_DIR/agent-workspace/memory/.dod-watchdog.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

mkdir -p "$(dirname "$LOG")"

[ -f "$EXEC_FILE" ] || { printf '[%s] dod-watchdog: current-execution.md absent; skip\n' "$TS" >> "$HOOK_LOG"; exit 0; }

# Count ⏳ PENDING markers within HR-* lines.
PENDING_COUNT="$(grep -cE 'HR-[0-9]+.*⏳ PENDING' "$EXEC_FILE" 2>/dev/null || true)"
[[ "$PENDING_COUNT" =~ ^[0-9]+$ ]] || PENDING_COUNT=0

# Also surface count of explicit ⏳ PENDING lines (broader catch, not just HR-*).
ALL_PENDING="$(grep -cE '⏳ PENDING' "$EXEC_FILE" 2>/dev/null || true)"
[[ "$ALL_PENDING" =~ ^[0-9]+$ ]] || ALL_PENDING=0

# List the actual pending lines for the alert + log.
PENDING_LINES="$(grep -nE '⏳ PENDING' "$EXEC_FILE" 2>/dev/null | head -10 || true)"

printf '[%s] dod-watchdog: hr_pending=%s all_pending=%s\n' \
  "$TS" "$PENDING_COUNT" "$ALL_PENDING" >> "$LOG"

if [ "$ALL_PENDING" -gt 0 ]; then
  ALERT="harness-recovery-dod-watchdog ALERT: ${ALL_PENDING} ⏳ PENDING items remain in current-execution.md (HR-* count=${PENDING_COUNT}). Per BP-S43b-7, agent must not stop with PENDING items. Continue executing or mark items 🔒 GATED-HUMAN / 🔭 PHASE-N-DEFERRED with explicit reason."
  printf '[%s] %s\n' "$TS" "$ALERT" >> "$LOG"
  printf '[%s] dod-watchdog: ALERT pending=%s\n' "$TS" "$ALL_PENDING" >> "$HOOK_LOG"
  echo "$ALERT" >&2
  if [ -n "$PENDING_LINES" ]; then
    echo "Pending lines (first 10):" >&2
    printf -- '%s\n' "$PENDING_LINES" >&2
  fi

  if [ "${STOCKFORGE_DOD_HARDBLOCK:-0}" = "1" ] || [ "${STOCKFORGE_HOOK_PROFILE:-standard}" = "strict" ]; then
    printf '[%s] dod-watchdog: HARD-BLOCK exit=2 (strict)\n' "$TS" >> "$HOOK_LOG"
    exit 2
  fi
fi

exit 0
