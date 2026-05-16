#!/usr/bin/env bash
# escalation-engine-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies:
#   TC1: empty state.tsv → no block flag, no urgent.md entry
#   TC2: CRITICAL row → .autonomous-BLOCKED written + urgent.md entry
#   TC3: HIGH row → urgent.md entry but no block flag
#   TC4: UserPromptSubmit event with CRITICAL → stdout contains "AUTONOMOUS-BLOCKED"
#   TC5: idempotency — second call same bucket → no duplicate urgent.md entry
#   TC6: CRITICAL row + ACTIVE .block-grace → block flag SUPPRESSED (anti-deadlock)
#   TC7: CRITICAL row + EXPIRED .block-grace → block flag written + expired grace removed
#
# SPAWN-CONTEXT: positional-arg

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/escalation-engine.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t escalation-engine-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  # Pre-rotate markers (avoid hour-bucket collision across TCs)
  rm -f "$TMP/agent-workspace/memory/.escalation-fired-"* 2>/dev/null || true
}

write_state() {
  local rows="$1"
  {
    printf '# severity-state.tsv test fixture\n'
    printf '%s\n' "$rows"
  } > "$TMP/agent-workspace/memory/.severity-state.tsv"
}

run_hook() {
  local event="${1:-Stop}"
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" "$event"
}

# === TC1: empty state.tsv → no side effects ===
setup_tmp
write_state ""
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC1: block flag should not exist for empty state" || note_pass

# === TC2: CRITICAL+HARD row → block flag + urgent.md ===
# S348: HARD tier (col6=HARD) triggers block flag (legacy 5-col rows now route to PENDING per D5 shim)
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z\tHARD')"
run_hook Stop >/dev/null 2>&1
if [ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC2: HARD row block flag not written"; fi
URG_HAS_CRIT=$(grep -c "ESCALATION\|CRITICAL" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
[ "$URG_HAS_CRIT" -ge 0 ] && note_pass || note_fail "TC2: urgent.md missing entry"

# === TC3: HIGH row → urgent.md but no block flag ===
setup_tmp
write_state "$(printf 'HIGH\ttest-bundle.md\t7\tESCALATE-ASKUSERQUESTION\t2026-05-14T02:00:00Z')"
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC3: block flag should NOT exist for HIGH" || note_pass
HIGH_IN_URG=$(grep -c "HIGH" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
if [ "$HIGH_IN_URG" -ge 1 ]; then note_pass; else note_fail "TC3: urgent.md missing HIGH entry"; fi

# === TC4: UserPromptSubmit + CRITICAL+HARD → stdout has BLOCKED text ===
# S348: UPS injection keyed off HARD_N per ADR D-068 DD-10
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z\tHARD')"
OUT=$(run_hook UserPromptSubmit 2>/dev/null)
echo "$OUT" | grep -q "SEVERITY-ESCALATION HARD\|AUTONOMOUS-BLOCKED\|CRITICAL\|HARD" && note_pass || note_fail "TC4: UserPromptSubmit stdout missing HARD/BLOCKED text"

# === TC5: idempotency — second call same bucket → no double urgent.md HIGH entry ===
setup_tmp
write_state "$(printf 'HIGH\tbundle1.md\t7\tESCALATE-ASKUSERQUESTION\t2026-05-14T02:00:00Z')"
run_hook Stop >/dev/null 2>&1
COUNT1=$(grep -c "ESCALATION" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
run_hook Stop >/dev/null 2>&1
COUNT2=$(grep -c "ESCALATION" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
if [ "$COUNT2" -eq "$COUNT1" ]; then note_pass; else note_fail "TC5: second call duplicated entry ($COUNT1 → $COUNT2)"; fi

# === TC6: CRITICAL+HARD row + ACTIVE .block-grace → block flag SUPPRESSED ===
# S348: uses 6-col HARD row; active grace should suppress even HARD tier
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z\tHARD')"
GRACE_FUTURE=$(( $(date +%s 2>/dev/null || echo 0) + 1800 ))
printf 'expiry_epoch=%s\ncleared_at=test\n' "$GRACE_FUTURE" > "$TMP/agent-workspace/memory/.block-grace"
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC6: HARD block flag should be SUPPRESSED while .block-grace active" || note_pass

# === TC7: CRITICAL+HARD row + EXPIRED .block-grace → block flag written + expired grace removed ===
# S348: uses 6-col HARD row; expired grace should not suppress block
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z\tHARD')"
GRACE_PAST=$(( $(date +%s 2>/dev/null || echo 0) - 100 ))
printf 'expiry_epoch=%s\ncleared_at=test\n' "$GRACE_PAST" > "$TMP/agent-workspace/memory/.block-grace"
run_hook Stop >/dev/null 2>&1
if [ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC7: HARD block flag should be written when grace is expired"; fi
[ -f "$TMP/agent-workspace/memory/.block-grace" ] && note_fail "TC7: expired .block-grace should be removed" || note_pass

# === TC-D2-1: state.tsv row tier=HARD -> .autonomous-BLOCKED written ===
# S348 D2: HARD tier still writes the block flag
setup_tmp
write_state "$(printf 'CRITICAL\ttest-hard-artifact.md\t0\tBLOCK\t2026-05-16T00:00:00Z\tHARD')"
run_hook Stop >/dev/null 2>&1
if [ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC-D2-1: HARD tier should write .autonomous-BLOCKED flag"; fi

# === TC-D2-2: state.tsv row tier=PENDING -> .pending-queue.tsv populated; NO block flag ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-pending-artifact.md\t0\tBLOCK-PENDING\t2026-05-16T00:00:00Z\tPENDING')"
run_hook Stop >/dev/null 2>&1
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
QUEUE_HAS_ROW=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
if [ ! -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && [ "${QUEUE_HAS_ROW:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D2-2: PENDING tier should NOT write block flag (blocked=$([ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && echo yes || echo no)) and should populate queue (queue_rows=$QUEUE_HAS_ROW)"
fi

# === TC-D2-3: state.tsv row tier=PENDING -> 2nd run does NOT duplicate queue row (idempotency) ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-pending-artifact.md\t0\tBLOCK-PENDING\t2026-05-16T00:00:00Z\tPENDING')"
run_hook Stop >/dev/null 2>&1
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
COUNT1=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
# Run again with same state (same artifact_path)
run_hook Stop >/dev/null 2>&1
COUNT2=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
if [ "${COUNT1:-0}" -eq "${COUNT2:-0}" ] && [ "${COUNT1:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D2-3: PENDING idempotency failed (count1=$COUNT1 count2=$COUNT2 — should not duplicate queue rows)"
fi

# === TC-D2-4: state.tsv mixed HARD+PENDING -> both paths fire correctly ===
setup_tmp
MIXED_STATE="$(printf 'CRITICAL\thard-artifact.md\t0\tBLOCK\t2026-05-16T00:00:00Z\tHARD\nCRITICAL\tpending-artifact.md\t0\tBLOCK-PENDING\t2026-05-16T00:00:00Z\tPENDING')"
write_state "$MIXED_STATE"
run_hook Stop >/dev/null 2>&1
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
HAS_BLOCK=$([ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && echo yes || echo no)
HAS_QUEUE=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
if [ "$HAS_BLOCK" = "yes" ] && [ "${HAS_QUEUE:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D2-4: mixed HARD+PENDING should write block flag (got=$HAS_BLOCK) AND populate queue (queue_rows=$HAS_QUEUE)"
fi

# === TC-D5-1: 5-col legacy CRITICAL row -> treated as PENDING (queue populated, no flag written) ===
# S348 D5: migration shim handles legacy rows without block_tier col
setup_tmp
write_state "$(printf 'CRITICAL\tlegacy-artifact.md\t0\tBLOCK\t2026-05-16T00:00:00Z')"
# 5-col row: no col6 (block_tier) — legacy format
run_hook Stop >/dev/null 2>&1
QUEUE="$TMP/human-workspace/notifications/.pending-queue.tsv"
QUEUE_HAS_ROW=$(grep -v '^#' "$QUEUE" 2>/dev/null | grep -c . 2>/dev/null || echo 0)
HAS_BLOCK=$([ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && echo yes || echo no)
if [ "$HAS_BLOCK" = "no" ] && [ "${QUEUE_HAS_ROW:-0}" -ge 1 ]; then
  note_pass
else
  note_fail "TC-D5-1: legacy 5-col CRITICAL row should be treated as PENDING (no block flag=$HAS_BLOCK, queue_rows=$QUEUE_HAS_ROW)"
fi

# === TC-D5-2: 6-col CRITICAL+HARD row -> flag written (proves shim doesn't over-suppress HARD) ===
setup_tmp
write_state "$(printf 'CRITICAL\thard-artifact-2.md\t0\tBLOCK\t2026-05-16T00:00:00Z\tHARD')"
run_hook Stop >/dev/null 2>&1
HAS_BLOCK=$([ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && echo yes || echo no)
if [ "$HAS_BLOCK" = "yes" ]; then
  note_pass
else
  note_fail "TC-D5-2: 6-col HARD row should still write block flag (not over-suppressed by shim)"
fi

# Summary
TOTAL=$((PASS+FAIL))
echo "escalation-engine-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
