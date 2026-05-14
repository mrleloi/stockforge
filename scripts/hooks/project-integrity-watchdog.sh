#!/usr/bin/env bash
# project-integrity-watchdog.sh — R2 of 2026-05-14 mass-deletion prevention.
#
# Stop hook (late chain). Verifies canonical project files + directories still exist.
# If ANY are missing → CRITICAL: writes .autonomous-BLOCKED flag DIRECTLY (does not wait
# for severity-classifier→escalation-engine round-trip) + emits CRITICAL severity row +
# alerts urgent.md + Telegram. This is the early-warning system that would have caught
# the 2026-05-14 mass-deletion within one Stop event instead of hours later.
#
# Origin: post-mortems/2026-05-14-mass-deletion-recovery.md §5 R2.
# Bash + POSIX only per L-S11-1. RC=0 always (the BLOCK is via flag file, not exit code,
# so this hook never breaks the Stop chain).
# SPAWN-CONTEXT: positional-arg

set -uo pipefail
trap 'exit 0' ERR

EVENT="${1:-Stop}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.project-integrity.log"
BLOCK_FLAG="$MEM_DIR/.autonomous-BLOCKED"
STATE_FILE="$MEM_DIR/.severity-state.tsv"
URGENT="$PROJECT_DIR/human-workspace/notifications/urgent.md"
TELEGRAM_HOOK="$PROJECT_DIR/scripts/hooks/telegram-push.sh"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# --- Canonical files/dirs that MUST exist (a project without these is corrupted) ---
CANONICAL_FILES=(
  "$PROJECT_DIR/PROJECT_CHARTER.md"
  "$PROJECT_DIR/CLAUDE.md"
  "$PROJECT_DIR/AGENT_OPERATING_MANUAL.md"
  "$PROJECT_DIR/.git/HEAD"
  "$MEM_DIR/agent-notes.md"
  "$MEM_DIR/current-execution.md"
  "$MEM_DIR/mistake-log.md"
)
CANONICAL_DIRS=(
  "$PROJECT_DIR/agent-workspace/constitution"
  "$PROJECT_DIR/scripts/hooks"
  "$PROJECT_DIR/.claude"
  "$MEM_DIR/decisions"
  "$MEM_DIR/sessions"
)

MISSING=()
for f in "${CANONICAL_FILES[@]}"; do
  [ -f "$f" ] || MISSING+=("FILE:${f#$PROJECT_DIR/}")
done
for d in "${CANONICAL_DIRS[@]}"; do
  [ -d "$d" ] || MISSING+=("DIR:${d#$PROJECT_DIR/}")
done

MISSING_COUNT="${#MISSING[@]}"

if [ "$MISSING_COUNT" -eq 0 ]; then
  printf '[%s] project-integrity-watchdog: OK (event=%s; all %d canonical files + %d dirs present)\n' \
    "$TS" "$EVENT" "${#CANONICAL_FILES[@]}" "${#CANONICAL_DIRS[@]}" >> "$LOG" 2>/dev/null || true
  exit 0
fi

# --- INTEGRITY VIOLATION — canonical artifact missing ---
printf '[%s] project-integrity-watchdog: CRITICAL — %d canonical artifact(s) MISSING (event=%s)\n' \
  "$TS" "$MISSING_COUNT" "$EVENT" >> "$LOG" 2>/dev/null || true
for m in "${MISSING[@]}"; do
  printf '[%s]   missing: %s\n' "$TS" "$m" >> "$LOG" 2>/dev/null || true
done

# 1. Write .autonomous-BLOCKED flag DIRECTLY (early-warning — don't wait for escalation-engine)
if [ ! -f "$BLOCK_FLAG" ]; then
  {
    printf 'BLOCKED at %s by project-integrity-watchdog.sh (event=%s)\n' "$TS" "$EVENT"
    printf 'REASON: %d CANONICAL PROJECT ARTIFACT(S) MISSING — possible mass-deletion event\n' "$MISSING_COUNT"
    printf 'Missing artifacts:\n'
    for m in "${MISSING[@]}"; do printf '  - %s\n' "$m"; done
    printf '\nResolution required:\n'
    printf '  1. STOP. Do not run any further commands that could compound the loss.\n'
    printf '  2. Check forensic backups: stockforge-rescue-*, stockforge-fresh-*, .git-corrupt-*\n'
    printf '  3. Recovery procedure: agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md §4\n'
    printf '  4. After recovery verified: delete this flag (rm "%s")\n' "$BLOCK_FLAG"
    printf '\nEmergency override: STOCKFORGE_FORCE_AUTONOMOUS=1 env (logged)\n'
  } > "$BLOCK_FLAG" 2>/dev/null || true
fi

# 2. Emit CRITICAL severity row (append to state file; severity-classifier rewrites it but
#    escalation-engine reads appended rows in same Stop chain)
if [ -f "$STATE_FILE" ]; then
  printf 'CRITICAL\tproject-integrity-violation\t0\tBLOCK\t%s\n' "$TS" >> "$STATE_FILE" 2>/dev/null || true
fi

# 3. urgent.md alert (idempotent per hour-bucket)
BUCKET="$(date +%Y%m%d-%H 2>/dev/null || echo unbucketed)"
URGENT_MARKER="$MEM_DIR/.project-integrity-alerted-${BUCKET}"
if [ ! -f "$URGENT_MARKER" ] && [ -d "$(dirname "$URGENT")" ]; then
  {
    printf '\n## CRITICAL — %s — PROJECT INTEGRITY VIOLATION (project-integrity-watchdog)\n\n' "$TS"
    printf '%d canonical project artifact(s) MISSING — possible mass-deletion event.\n\n' "$MISSING_COUNT"
    printf 'Missing:\n'
    for m in "${MISSING[@]}"; do printf -- '- `%s`\n' "$m"; done
    printf '\n`.autonomous-BLOCKED` flag written. Autonomous mode halted. See flag for recovery steps.\n\n'
    printf -- '---\n'
  } >> "$URGENT" 2>/dev/null || true
  echo "fired" > "$URGENT_MARKER" 2>/dev/null || true
fi

# 4. Telegram push (best-effort)
if [ -x "$TELEGRAM_HOOK" ]; then
  bash "$TELEGRAM_HOOK" "CRITICAL" "PROJECT INTEGRITY VIOLATION: $MISSING_COUNT canonical artifact(s) missing. Autonomous BLOCKED. Possible mass-deletion. Check forensic backups + post-mortem recovery procedure." 2>/dev/null || true
fi

# 5. stderr (visible in Stop chain)
echo "project-integrity-watchdog: CRITICAL — $MISSING_COUNT canonical artifact(s) missing; .autonomous-BLOCKED written" >&2

exit 0
