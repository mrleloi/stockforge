#!/usr/bin/env bash
# Firing-test for working-memory-budget-audit.sh (S103 deliverable per Phase 3.5
# T7 hard rule #2 — every hook ships with companion firing-test).
#
# Hook purpose (SessionStart): audit combined byte size of the 3 "routine load"
# files (boot-summary.md + checkpoints/latest.md + routing-config.md). Ceiling
# 20480 bytes (20 KB) per CLAUDE.md hard rule + memory-tiers.md proposal § Tier 1.
#
# Behavior on breach: WARN to log + notification + additionalContext. Always exit 0.
#
# Test cases (9 TC):
#   TC1 — clean state under budget (15 KB total) → over_budget=0, no notification
#   TC2 — breach: total > 20480 (e.g. 22 KB) → over_budget=1, notification + ctx
#   TC3 — boundary EXACTLY 20480 → over_budget=0 (strict greater-than)
#   TC4 — boundary 20481 (1 byte over) → over_budget=1
#   TC5 — boot-summary missing but other two under cap → 0 violations; missing tally =1
#   TC6 — all 3 files missing → total=0 → over_budget=0 (no false alarm; missing-file
#         detection is essential-routing-fields-verifier's domain not this hook's)
#   TC7 — source=PreCompact → exit 0 no-op skip line in log
#   TC8 — single oversized file (25 KB checkpoint alone) → over_budget=1; notification
#         per-file breakdown lists exact byte counts
#   TC9 — clear-on-resolve: breach notification removed when budget returns under ceiling (S318)
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../working-memory-budget-audit.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
BOOT_SUMMARY="$MEM_DIR/boot-summary.md"
CHECKPOINT_DIR="$MEM_DIR/checkpoints"
CHECKPOINT="$CHECKPOINT_DIR/latest.md"
ROUTING_CONFIG="$MEM_DIR/routing-config.md"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_FILE="$NOTIF_DIR/working-memory-budget-OVER.md"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$CHECKPOINT_DIR" "$NOTIF_DIR"
}

# Generate a file of approximately N bytes (deterministic, no randomness).
make_bytes() {
  local target="$1" out="$2"
  local n=$((target / 64))   # 64-byte block × n
  local rem=$((target % 64))
  printf '' > "$out"
  local i=0
  while [ $i -lt $n ]; do
    printf 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB' >> "$out"
    i=$((i + 1))
  done
  if [ "$rem" -gt 0 ]; then
    printf '%*s' "$rem" '' | tr ' ' 'X' >> "$out"
  fi
}

run_hook_with_payload() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1
}

run_hook_default() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1
}

assert_log_contains() {
  local pat="$1" tag="$2"
  if ! grep -q "$pat" "$LOG" 2>/dev/null; then
    echo "FAIL $tag: log missing pattern: $pat"
    [ -f "$LOG" ] && cat "$LOG"
    exit 1
  fi
}

last_log_field() {
  local key="$1"
  grep "working-memory-budget-audit:" "$LOG" 2>/dev/null | tail -1 | grep -oE "${key}=[0-9]+" | sed "s/${key}=//" || true
}

# --- TC1: clean state under budget (≈15 KB total) → over_budget=0 ---
clean_state
make_bytes 1500  "$BOOT_SUMMARY"     # 1.5 KB
make_bytes 7000  "$CHECKPOINT"       # 7 KB
make_bytes 6500  "$ROUTING_CONFIG"   # 6.5 KB → total 15 KB
run_hook_default
TOTAL=$(last_log_field total)
TOTAL_NUM=$(printf '%s' "$TOTAL" | tr -d 'B')
OVER=$(last_log_field over_budget)
if [ "${TOTAL_NUM:-0}" -ne 15000 ]; then
  echo "FAIL TC1: expected total=15000B; got total=${TOTAL:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "0" ]; then
  echo "FAIL TC1: expected over_budget=0; got over_budget=${OVER:-MISSING}"
  exit 1
fi
if [ -f "$NOTIF_FILE" ]; then
  echo "FAIL TC1: notification should NOT exist when under budget"
  exit 1
fi
echo "PASS TC1: clean state 15000B ≤ 20480B → over_budget=0, no notification"

# --- TC2: breach total ≈ 22 KB → over_budget=1, notification + ctx ---
clean_state
make_bytes 2000  "$BOOT_SUMMARY"     # 2 KB
make_bytes 10000 "$CHECKPOINT"       # 10 KB
make_bytes 10000 "$ROUTING_CONFIG"   # 10 KB → total 22 KB = 22000B > 20480
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
if [ "${TOTAL_NUM:-0}" -ne 22000 ]; then
  echo "FAIL TC2: expected total=22000B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "1" ]; then
  echo "FAIL TC2: expected over_budget=1; got over_budget=${OVER:-MISSING}"
  exit 1
fi
if [ ! -f "$NOTIF_FILE" ]; then
  echo "FAIL TC2: notification should exist on breach"
  exit 1
fi
if ! grep -q "Working-memory budget exceeded" "$NOTIF_FILE"; then
  echo "FAIL TC2: notification missing header"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC2: breach 22000B > 20480B → over_budget=1, notification emitted"

# --- TC3: boundary EXACTLY 20480 bytes → over_budget=0 (strict >) ---
clean_state
make_bytes 5000  "$BOOT_SUMMARY"
make_bytes 7740  "$CHECKPOINT"
make_bytes 7740  "$ROUTING_CONFIG"   # total 5000 + 7740 + 7740 = 20480 exactly
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
if [ "${TOTAL_NUM:-0}" -ne 20480 ]; then
  echo "FAIL TC3: expected total=20480B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "0" ]; then
  echo "FAIL TC3: expected over_budget=0 at exactly 20480 (strict greater-than); got over_budget=${OVER:-MISSING}"
  exit 1
fi
echo "PASS TC3: boundary exactly 20480B → over_budget=0 (strict greater-than)"

# --- TC4: boundary 20481 (1 byte over) → over_budget=1 ---
clean_state
make_bytes 5000  "$BOOT_SUMMARY"
make_bytes 7740  "$CHECKPOINT"
make_bytes 7741  "$ROUTING_CONFIG"   # total 20481
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
if [ "${TOTAL_NUM:-0}" -ne 20481 ]; then
  echo "FAIL TC4: expected total=20481B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "1" ]; then
  echo "FAIL TC4: expected over_budget=1 at 20481 (1B over); got over_budget=${OVER:-MISSING}"
  exit 1
fi
echo "PASS TC4: boundary 20481B (1 byte over) → over_budget=1"

# --- TC5: boot-summary missing; other two under budget → over_budget=0; missing_count=1 ---
clean_state
# Skip boot-summary
make_bytes 7000  "$CHECKPOINT"
make_bytes 6000  "$ROUTING_CONFIG"   # total 13 KB → under
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
MISSING=$(last_log_field missing_count)
if [ "${TOTAL_NUM:-0}" -ne 13000 ]; then
  echo "FAIL TC5: expected total=13000B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "0" ]; then
  echo "FAIL TC5: expected over_budget=0; got over_budget=${OVER:-MISSING}"
  exit 1
fi
if [ "${MISSING:-MISSING}" != "1" ]; then
  echo "FAIL TC5: expected missing_count=1; got missing_count=${MISSING:-MISSING}"
  exit 1
fi
echo "PASS TC5: boot-summary missing + 13000B total → over_budget=0, missing_count=1"

# --- TC6: all 3 files missing → total=0 → over_budget=0 (no false alarm) ---
clean_state
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
MISSING=$(last_log_field missing_count)
if [ "${TOTAL_NUM:-X}" != "0" ]; then
  echo "FAIL TC6: expected total=0B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "0" ]; then
  echo "FAIL TC6: expected over_budget=0 (missing-files NOT this hook's responsibility); got over_budget=${OVER:-MISSING}"
  exit 1
fi
if [ "${MISSING:-MISSING}" != "3" ]; then
  echo "FAIL TC6: expected missing_count=3; got missing_count=${MISSING:-MISSING}"
  exit 1
fi
if [ -f "$NOTIF_FILE" ]; then
  echo "FAIL TC6: notification should NOT exist when total=0 (no breach)"
  exit 1
fi
echo "PASS TC6: all 3 files missing → total=0, over_budget=0, missing_count=3 (no false alarm)"

# --- TC7: source=PreCompact → no-op skip ---
clean_state
make_bytes 5000 "$BOOT_SUMMARY"
make_bytes 5000 "$CHECKPOINT"
make_bytes 5000 "$ROUTING_CONFIG"
if command -v node >/dev/null 2>&1; then
  run_hook_with_payload '{"source":"PreCompact"}'
  if ! grep -q "skipped source=PreCompact" "$LOG"; then
    echo "FAIL TC7: log should record skipped source=PreCompact"
    cat "$LOG"
    exit 1
  fi
  echo "PASS TC7: source=PreCompact → no-op skip line"
else
  echo "SKIP TC7: node unavailable; cannot test source-filter branch"
fi

# --- TC8: single oversized file (25 KB checkpoint) → breach + per-file breakdown ---
clean_state
make_bytes 1000  "$BOOT_SUMMARY"
make_bytes 25000 "$CHECKPOINT"     # 25 KB alone breaks budget
make_bytes 1000  "$ROUTING_CONFIG" # total 27 KB
run_hook_default
TOTAL_NUM=$(last_log_field total | tr -d 'B')
OVER=$(last_log_field over_budget)
if [ "${TOTAL_NUM:-0}" -ne 27000 ]; then
  echo "FAIL TC8: expected total=27000B; got total=${TOTAL_NUM:-MISSING}"
  cat "$LOG"
  exit 1
fi
if [ "${OVER:-MISSING}" != "1" ]; then
  echo "FAIL TC8: expected over_budget=1; got over_budget=${OVER:-MISSING}"
  exit 1
fi
if [ ! -f "$NOTIF_FILE" ]; then
  echo "FAIL TC8: notification should exist on breach"
  exit 1
fi
# Verify per-file breakdown lists checkpoint as the heaviest contributor.
if ! grep -q "checkpoints/latest.md | 25000" "$NOTIF_FILE"; then
  echo "FAIL TC8: notification should list checkpoint at 25000B in breakdown"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC8: single oversized checkpoint 25000B → breach detected + per-file breakdown lists 25000B"

# --- TC9: clear-on-resolve — notification removed when budget returns under ceiling (S318) ---
clean_state
make_bytes 2000  "$BOOT_SUMMARY"
make_bytes 10000 "$CHECKPOINT"
make_bytes 10000 "$ROUTING_CONFIG"   # 22 KB → breach
run_hook_default
TC9_MID=0
[ -f "$NOTIF_FILE" ] && TC9_MID=1
# Shrink files back under budget IN PLACE (no clean_state — must preserve notif to test removal)
make_bytes 1500 "$BOOT_SUMMARY"
make_bytes 7000 "$CHECKPOINT"
make_bytes 6500 "$ROUTING_CONFIG"    # 15 KB → under ceiling
run_hook_default
TC9_AFTER=0
[ -f "$NOTIF_FILE" ] && TC9_AFTER=1
if [ "$TC9_MID" -eq 1 ] && [ "$TC9_AFTER" -eq 0 ]; then
  echo "PASS TC9: clear-on-resolve — notification removed when budget back under ceiling"
else
  echo "FAIL TC9: mid=$TC9_MID after=$TC9_AFTER (expected 1/0)"
  exit 1
fi

echo "ALL PASS (9/9)"
exit 0
