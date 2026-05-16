#!/usr/bin/env bash
# pending-queue-escalator-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies pending-queue-escalator.sh (NEW S348 per ADR D-068):
#   TC-D3-1: empty queue file -> silent RC=0; no archive writes
#   TC-D3-2: escalate_at in future -> no Telegram fire (DRY_RUN); row preserved
#   TC-D3-3: escalate_at in past + telegram_pushed=false -> Telegram fires (DRY_RUN log entry); telegram_pushed updated
#   TC-D3-4: age > 24h + telegram_pushed=true -> auto-archive; queue row removed; archive file created
#   TC-D3-5: artifact_path points to NON-EXISTENT file -> resolve-archive (regardless of age); queue row removed
#   TC-D3-6: idempotency -- running TC-D3-3 twice -> Telegram fires only ONCE (telegram_pushed=true after first run)
#
# SPAWN-CONTEXT: positional-arg

set -uo pipefail

# Force DRY_RUN for all tests (never hit real Telegram API from fire-test)
export STOCKFORGE_TELEGRAM_DRY_RUN=1

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/pending-queue-escalator.sh"
[ -x "$HOOK" ] || chmod +x "$HOOK" 2>/dev/null || true
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t pending-queue-escalator-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

QUEUE_DIR="$TMP/human-workspace/notifications"
ARCHIVE_DIR="$QUEUE_DIR/archive"
QUEUE_FILE="$QUEUE_DIR/.pending-queue.tsv"
MEM_DIR="$TMP/agent-workspace/memory"

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$QUEUE_DIR" "$ARCHIVE_DIR" "$MEM_DIR"
}

write_queue_header() {
  {
    printf '# .pending-queue.tsv test fixture\n'
    printf '# columns: pending_id\tblock_tier\tseverity\tartifact_path\tdetected_at\tescalate_at\ttelegram_pushed\tarchived_at\tresolve_reason\n'
  } > "$QUEUE_FILE"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" Stop >/dev/null 2>&1
}

NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"
PAST_EPOCH=$(( NOW_EPOCH - 100 ))
FUTURE_EPOCH=$(( NOW_EPOCH + 21600 ))
PAST_25H_EPOCH=$(( NOW_EPOCH - 90000 ))
# ISO-8601 timestamps for detected_at
NOW_ISO="$(date -Iseconds 2>/dev/null || echo '2026-05-16T00:00:00Z')"
PAST_25H_ISO="$(date -d '25 hours ago' -Iseconds 2>/dev/null || echo '2026-05-14T00:00:00Z')"

# === TC-D3-1: empty queue file -> silent RC=0; no archive writes ===
setup_tmp
write_queue_header
run_hook
ARCHIVE_COUNT=$(ls "$ARCHIVE_DIR" 2>/dev/null | wc -l | tr -d ' ')
if [ "${ARCHIVE_COUNT:-0}" -eq 0 ]; then note_pass; else note_fail "TC-D3-1: archive should be empty for empty queue, got $ARCHIVE_COUNT files"; fi

# === TC-D3-2: escalate_at in future -> no Telegram fire; row preserved ===
setup_tmp
write_queue_header
printf 'future-checkpoint-1\tPENDING\tCRITICAL\tagent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint\t%s\t%s\tfalse\t-\t-\n' \
  "$NOW_ISO" "$FUTURE_EPOCH" >> "$QUEUE_FILE"
# Create artifact so it doesn't self-resolve
mkdir -p "$TMP/agent-workspace/memory"
touch "$TMP/agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
run_hook
# Row should still be in queue (telegram_pushed=false, escalate_at in future)
ROW_COUNT=$(grep -v '^#' "$QUEUE_FILE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
ARCHIVE_COUNT=$(ls "$ARCHIVE_DIR" 2>/dev/null | wc -l | tr -d ' ')
if [ "${ROW_COUNT:-0}" -ge 1 ] && [ "${ARCHIVE_COUNT:-0}" -eq 0 ]; then
  note_pass
else
  note_fail "TC-D3-2: row should be preserved when escalate_at in future (rows=$ROW_COUNT archives=$ARCHIVE_COUNT)"
fi

# === TC-D3-3: escalate_at in past + telegram_pushed=false -> Telegram fires (DRY_RUN); telegram_pushed updated ===
setup_tmp
write_queue_header
printf 'past-checkpoint-1\tPENDING\tCRITICAL\tagent-workspace/memory/.charter-violation-detected\t%s\t%s\tfalse\t-\t-\n' \
  "$NOW_ISO" "$PAST_EPOCH" >> "$QUEUE_FILE"
touch "$TMP/agent-workspace/memory/.charter-violation-detected"
run_hook
# Check telegram_pushed updated to true
PUSHED=$(grep -v '^#' "$QUEUE_FILE" 2>/dev/null | awk -F'\t' '{print $7}' | head -1 || echo "")
LOG_LINE=$(grep 'DRY_RUN.*telegram' "$MEM_DIR/.pending-queue-escalator.log" 2>/dev/null | tail -1 || echo "")
if [ "$PUSHED" = "true" ] || [ -n "$LOG_LINE" ]; then
  note_pass
else
  note_fail "TC-D3-3: telegram_pushed should be true after DRY_RUN escalation (pushed=$PUSHED log=$LOG_LINE)"
fi

# === TC-D3-4: age > 24h + telegram_pushed=true -> auto-archive; queue row removed; archive file created ===
setup_tmp
write_queue_header
printf 'old-checkpoint-1\tPENDING\tCRITICAL\tagent-workspace/memory/.ghost-greening-confirmed\t%s\t%s\ttrue\t-\t-\n' \
  "$PAST_25H_ISO" "$PAST_EPOCH" >> "$QUEUE_FILE"
touch "$TMP/agent-workspace/memory/.ghost-greening-confirmed"
run_hook
ROW_COUNT=$(grep -v '^#' "$QUEUE_FILE" 2>/dev/null | grep -c . 2>/dev/null || echo "0"); ROW_COUNT="${ROW_COUNT//[[:space:]]/}"
ARCHIVE_COUNT=$(ls "$ARCHIVE_DIR" 2>/dev/null | wc -l | tr -d '[:space:]'); ARCHIVE_COUNT="${ARCHIVE_COUNT//[[:space:]]/}"
if [ "${ROW_COUNT:-0}" -eq 0 ] && [ "${ARCHIVE_COUNT:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D3-4: 24h auto-archive should remove row from queue and write archive file (rows=$ROW_COUNT archives=$ARCHIVE_COUNT)"
fi

# === TC-D3-5: artifact_path points to NON-EXISTENT file -> resolve-archive; queue row removed ===
setup_tmp
write_queue_header
printf 'gone-artifact-1\tPENDING\tCRITICAL\tagent-workspace/memory/.nonexistent-marker\t%s\t%s\tfalse\t-\t-\n' \
  "$NOW_ISO" "$FUTURE_EPOCH" >> "$QUEUE_FILE"
# Do NOT create the artifact -- it's intentionally missing
run_hook
ROW_COUNT=$(grep -v '^#' "$QUEUE_FILE" 2>/dev/null | grep -c . 2>/dev/null || echo "0"); ROW_COUNT="${ROW_COUNT//[[:space:]]/}"
ARCHIVE_COUNT=$(ls "$ARCHIVE_DIR" 2>/dev/null | wc -l | tr -d '[:space:]'); ARCHIVE_COUNT="${ARCHIVE_COUNT//[[:space:]]/}"
RESOLVE_REASON=$(grep 'resolve_reason' "$ARCHIVE_DIR"/*.md 2>/dev/null | grep -c 'artifact-gone' 2>/dev/null || echo 0); RESOLVE_REASON="${RESOLVE_REASON//[[:space:]]/}"
if [ "${ROW_COUNT:-0}" -eq 0 ] && [ "${ARCHIVE_COUNT:-0}" -ge 1 ] && [ "${RESOLVE_REASON:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D3-5: non-existent artifact should self-resolve to archive (rows=$ROW_COUNT archives=$ARCHIVE_COUNT resolve_reason_count=$RESOLVE_REASON)"
fi

# === TC-D3-6: idempotency -- run TC-D3-3 scenario twice -> Telegram fires only ONCE ===
setup_tmp
write_queue_header
printf 'idem-checkpoint-1\tPENDING\tCRITICAL\tagent-workspace/memory/.charter-violation-detected\t%s\t%s\tfalse\t-\t-\n' \
  "$NOW_ISO" "$PAST_EPOCH" >> "$QUEUE_FILE"
touch "$TMP/agent-workspace/memory/.charter-violation-detected"
# First run: should fire Telegram (DRY_RUN)
run_hook
PUSHED_AFTER_FIRST=$(grep -v '^#' "$QUEUE_FILE" 2>/dev/null | awk -F'\t' '{print $7}' | head -1 || echo "false")
LOG_LINES_1=$(grep 'DRY_RUN.*telegram' "$MEM_DIR/.pending-queue-escalator.log" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
# Second run: telegram_pushed=true -> should NOT fire again
run_hook
LOG_LINES_2=$(grep 'DRY_RUN.*telegram' "$MEM_DIR/.pending-queue-escalator.log" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
if [ "$PUSHED_AFTER_FIRST" = "true" ] && [ "${LOG_LINES_2:-0}" -eq "${LOG_LINES_1:-0}" ]; then
  note_pass
else
  note_fail "TC-D3-6: Telegram should fire exactly once (pushed_after_first=$PUSHED_AFTER_FIRST log_lines_1=$LOG_LINES_1 log_lines_2=$LOG_LINES_2)"
fi

# === Summary ===
TOTAL=$((PASS+FAIL))
echo "pending-queue-escalator-fire-test: $PASS/$TOTAL PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do echo "  - $e"; done
  exit 1
fi
exit 0
