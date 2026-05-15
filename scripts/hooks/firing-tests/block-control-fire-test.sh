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

# Summary
TOTAL=$((PASS+FAIL))
echo "block-control-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
