#!/usr/bin/env bash
# block-control-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies block-control.sh — the unified human-gate (block/unblock) control script:
#   TC1:  status, no flag                       -> "CLEAR"
#   TC2:  raise                                 -> .autonomous-BLOCKED written w/ severity+slug+reason
#   TC3:  status, flag present                  -> "BLOCKED" + flag content
#   TC4:  raise again                           -> idempotent: flag NOT overwritten
#   TC5:  clear                                 -> flag + .severity-state.tsv gone, .block-grace written
#   TC6:  check-prompt "approved" + flag         -> flag cleared + stdout "AUTO-CLEARED"
#   TC7:  check-prompt non-approval + flag        -> flag REMAINS
#   TC8:  check-prompt, no flag                   -> silent RC=0, no stdout
#   TC9:  check-prompt VN "tiep tuc" + flag        -> flag cleared
#   TC10: check-prompt negation "do not unblock"  -> flag REMAINS
#   TC11: clear removes .auto-reboot-PRE-BLOCKED-* markers
#
# SPAWN-CONTEXT: positional-arg (block-control.sh subcommand is $1)

set -uo pipefail

# Never hit the real Telegram API from a firing-test.
export STOCKFORGE_TELEGRAM_DRY_RUN=1

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/block-control.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t block-control-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

MEM=""

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  MEM="$TMP/agent-workspace/memory"
}

run_bc() {
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" "$@"
}

# === TC1: status, no flag → CLEAR ===
setup_tmp
OUT=$(run_bc status 2>/dev/null)
if echo "$OUT" | grep -q "CLEAR"; then note_pass; else note_fail "TC1: status no-flag expected CLEAR, got: ${OUT:0:80}"; fi

# === TC2: raise → flag written with content ===
setup_tmp
run_bc raise CRITICAL test-slug -- test reason text >/dev/null 2>&1
RC=$?
if [ "$RC" -eq 0 ] && [ -f "$MEM/.autonomous-BLOCKED" ] \
   && grep -q "severity=CRITICAL" "$MEM/.autonomous-BLOCKED" \
   && grep -q "slug=test-slug" "$MEM/.autonomous-BLOCKED" \
   && grep -q "test reason text" "$MEM/.autonomous-BLOCKED"; then
  note_pass
else
  note_fail "TC2: raise did not write a well-formed flag (RC=$RC)"
fi

# === TC3: status, flag present → BLOCKED + content ===
OUT=$(run_bc status 2>/dev/null)
if echo "$OUT" | grep -q "BLOCKED" && echo "$OUT" | grep -q "test reason text"; then
  note_pass
else
  note_fail "TC3: status with flag expected BLOCKED + content, got: ${OUT:0:80}"
fi

# === TC4: raise again → idempotent (flag not overwritten) ===
run_bc raise HIGH other-slug -- different reason >/dev/null 2>&1
if grep -q "slug=test-slug" "$MEM/.autonomous-BLOCKED" && ! grep -q "slug=other-slug" "$MEM/.autonomous-BLOCKED"; then
  note_pass
else
  note_fail "TC4: second raise overwrote the original flag"
fi

# === TC5: clear → flag + state.tsv gone, .block-grace written with future expiry ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
printf 'CRITICAL\tx\t0\tBLOCK\tts\n' > "$MEM/.severity-state.tsv"
run_bc clear test-actor cleared for test >/dev/null 2>&1
if [ ! -f "$MEM/.autonomous-BLOCKED" ] && [ ! -f "$MEM/.severity-state.tsv" ] && [ -f "$MEM/.block-grace" ]; then
  GEXP=$(grep '^expiry_epoch=' "$MEM/.block-grace" 2>/dev/null | head -1 | sed 's/^expiry_epoch=//' || echo 0)
  GNOW=$(date +%s 2>/dev/null || echo 0)
  case "$GEXP" in ''|*[!0-9]*) GEXP=0 ;; esac
  if [ "$GEXP" -gt "$GNOW" ]; then note_pass; else note_fail "TC5: .block-grace expiry not in the future"; fi
else
  note_fail "TC5: clear did not remove flag/state.tsv or write .block-grace"
fi

# === TC6: check-prompt "approved" + flag → cleared + AUTO-CLEARED stdout ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
OUT=$(echo '{"prompt":"ok approved, go ahead"}' | run_bc check-prompt 2>/dev/null)
if [ ! -f "$MEM/.autonomous-BLOCKED" ] && echo "$OUT" | grep -q "AUTO-CLEARED"; then
  note_pass
else
  note_fail "TC6: check-prompt 'approved' did not clear gate / no AUTO-CLEARED stdout"
fi

# === TC7: check-prompt non-approval + flag → flag REMAINS ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
echo '{"prompt":"what is the current status of the build?"}' | run_bc check-prompt >/dev/null 2>&1
if [ -f "$MEM/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC7: non-approval prompt wrongly cleared the gate"; fi

# === TC8: check-prompt, no flag → silent RC=0 ===
setup_tmp
OUT=$(run_bc check-prompt </dev/null 2>/dev/null)
RC=$?
if [ "$RC" -eq 0 ] && [ -z "$OUT" ]; then note_pass; else note_fail "TC8: check-prompt no-flag expected silent RC=0, got RC=$RC out=${OUT:0:60}"; fi

# === TC9: check-prompt VN "tiep tuc" + flag → cleared ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
echo '{"prompt":"tiep tuc chay autonomous di"}' | run_bc check-prompt >/dev/null 2>&1
if [ ! -f "$MEM/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC9: VN keyword 'tiep tuc' did not clear the gate"; fi

# === TC10: check-prompt negation + flag → flag REMAINS ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
echo '{"prompt":"do not unblock yet, still reviewing"}' | run_bc check-prompt >/dev/null 2>&1
if [ -f "$MEM/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC10: negation 'do not unblock' wrongly cleared the gate"; fi

# === TC11: clear removes .auto-reboot-PRE-BLOCKED-* markers ===
setup_tmp
run_bc raise HIGH s -- r >/dev/null 2>&1
printf 'stale marker\n' > "$MEM/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
run_bc clear >/dev/null 2>&1
if [ ! -f "$MEM/.auto-reboot-PRE-BLOCKED-stale-checkpoint" ]; then note_pass; else note_fail "TC11: clear did not remove .auto-reboot-PRE-BLOCKED-* marker"; fi

# === D4 TCs: ack subcommand + check-prompt ack extension ===

write_queue() {
  local queue_dir="$TMP/human-workspace/notifications"
  mkdir -p "$queue_dir/archive"
  {
    printf '# .pending-queue.tsv test fixture\n'
    printf '# columns: pending_id\tblock_tier\tseverity\tartifact_path\tdetected_at\tescalate_at\ttelegram_pushed\tarchived_at\tresolve_reason\n'
    printf 'stale-checkpoint-1\tPENDING\tCRITICAL\tagent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint\t2026-05-16T00:00:00Z\t9999999999\tfalse\t-\t-\n'
    printf 'charter-violation-1\tPENDING\tCRITICAL\tagent-workspace/memory/.charter-violation-detected\t2026-05-16T00:00:00Z\t9999999999\tfalse\t-\t-\n'
    printf 'ghost-greening-1\tPENDING\tCRITICAL\tagent-workspace/memory/.ghost-greening-confirmed\t2026-05-16T00:00:00Z\t9999999999\tfalse\t-\t-\n'
  } > "$queue_dir/.pending-queue.tsv"
}

# === TC-D4-1: ack <slug> subcommand archives matching row; removes from queue ===
setup_tmp
write_queue
run_bc ack stale-checkpoint >/dev/null 2>&1
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
ARCHIVE_DIR="$TMP/human-workspace/notifications/archive"
REMAINING=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep 'stale-checkpoint' | wc -l | tr -d ' ')
ARCHIVED=$(ls "$ARCHIVE_DIR" 2>/dev/null | wc -l | tr -d ' ')
OTHERS=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -v 'stale-checkpoint' | grep -c . 2>/dev/null || echo 0)
if [ "${REMAINING:-0}" -eq 0 ] && [ "${ARCHIVED:-0}" -ge 1 ] && [ "${OTHERS:-0}" -ge 2 ]; then
  note_pass
else
  note_fail "TC-D4-1: ack stale-checkpoint should remove from queue (remaining=$REMAINING) and archive (archived=$ARCHIVED); other rows preserved (others=$OTHERS)"
fi

# === TC-D4-2: ack <invalid-slug> invalid chars rejected with error message ===
setup_tmp
write_queue
OUT=$(run_bc ack 'bad/slug' 2>/dev/null || true)
if echo "$OUT" | grep -q "invalid slug\|must match"; then note_pass; else note_fail "TC-D4-2: invalid slug should emit error, got: ${OUT:0:80}"; fi

# === TC-D4-3: ack <no-match-slug> reports "no matching PENDING row" ===
setup_tmp
write_queue
OUT=$(run_bc ack nonexistent-slug 2>/dev/null || true)
if echo "$OUT" | grep -q "no matching"; then note_pass; else note_fail "TC-D4-3: no-match slug should report 'no matching PENDING row', got: ${OUT:0:80}"; fi

# === TC-D4-4: check-prompt with "ack stale-checkpoint" auto-runs ack subcommand ===
setup_tmp
write_queue
OUT=$(echo '{"prompt":"please ack stale-checkpoint to dismiss it"}' | run_bc check-prompt 2>/dev/null || true)
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
REMAINING=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep 'stale-checkpoint' | wc -l | tr -d ' ')
if echo "$OUT" | grep -q "ack keyword\|PENDING row\|resolved" && [ "${REMAINING:-1}" -eq 0 ]; then
  note_pass
else
  note_fail "TC-D4-4: check-prompt 'ack stale-checkpoint' should auto-ack (out=${OUT:0:80}) and remove row (remaining=$REMAINING)"
fi

# === TC-D4-5: check-prompt with "hackathon project" does NOT false-match ===
setup_tmp
write_queue
OUT=$(echo '{"prompt":"hackathon project review and ack-ack ack nowledgement"}' | run_bc check-prompt 2>/dev/null || true)
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
ROWS_BEFORE=3
ROWS_AFTER=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
# Should NOT have removed any rows (hackathon doesn't match "ack <slug>")
# Note: "ack-ack" should not match (no word boundary after "ack" followed by space + slug)
if [ "${ROWS_AFTER:-0}" -ge 3 ]; then
  note_pass
else
  note_fail "TC-D4-5: 'hackathon' text should NOT trigger ack (rows_before=$ROWS_BEFORE rows_after=$ROWS_AFTER) - potential false-match"
fi

# === TC-D4-6: check-prompt with "ack charter-violation ack ghost-greening" matches BOTH slugs (multi-ack) ===
setup_tmp
write_queue
OUT=$(echo '{"prompt":"ack charter-violation ack ghost-greening thanks"}' | run_bc check-prompt 2>/dev/null || true)
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
# Expect both charter-violation and ghost-greening removed; stale-checkpoint remains
REMAINING_CHARTER=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep 'charter-violation' | wc -l | tr -d ' ')
REMAINING_GHOST=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep 'ghost-greening' | wc -l | tr -d ' ')
REMAINING_STALE=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep 'stale-checkpoint' | wc -l | tr -d ' ')
if [ "${REMAINING_CHARTER:-1}" -eq 0 ] && [ "${REMAINING_GHOST:-1}" -eq 0 ] && [ "${REMAINING_STALE:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D4-6: multi-ack should remove both slugs (charter=$REMAINING_CHARTER ghost=$REMAINING_GHOST stale=$REMAINING_STALE)"
fi

# Summary
TOTAL=$((PASS+FAIL))
echo "block-control-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
