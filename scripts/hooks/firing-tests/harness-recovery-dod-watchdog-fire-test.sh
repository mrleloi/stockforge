#!/usr/bin/env bash
# Firing-test for harness-recovery-dod-watchdog.sh (Phase 3.5 T7 retrofit; S60).
#
# Hook purpose (KI-S43b-7 / BP-S43b-7 / L-S43b-10): scan
# agent-workspace/memory/current-execution.md for ⏳ PENDING markers (recovery
# DoD not met). Emit ALERT to stderr in default mode; exit 2 in strict mode.
#
# Test strategy: stage temp PROJECT_DIR with various current-execution.md
# fixtures + env-mode flags; invoke hook; assert exit code, stderr ALERT, log
# entry contents.
#
# 6 test cases:
#   TC1 — current-execution.md missing → exit 0 + log "absent"
#   TC2 — no ⏳ PENDING markers → silent (exit 0; LOG entry only)
#   TC3 — HR-* line with ⏳ PENDING → ALERT stderr + exit 0 (default)
#   TC4 — non-HR ⏳ PENDING → all_pending counted in log + ALERT
#   TC5 — strict mode (STOCKFORGE_DOD_HARDBLOCK=1) + PENDING → exit 2
#   TC6 — default mode + PENDING → exit 0 (advisory)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../harness-recovery-dod-watchdog.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.dod-watchdog.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
EXEC_FILE="$TEMPDIR/agent-workspace/memory/current-execution.md"

run_hook() {
  local stderr_out
  stderr_out=$(CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null 2>&1 >/dev/null) && rc=0 || rc=$?
  printf '%s' "$stderr_out"
  return $rc
}

run_hook_strict() {
  local stderr_out
  stderr_out=$(CLAUDE_PROJECT_DIR="$TEMPDIR" \
    STOCKFORGE_DOD_HARDBLOCK=1 \
    bash "$HOOK" </dev/null 2>&1 >/dev/null) && rc=0 || rc=$?
  printf '%s' "$stderr_out"
  return $rc
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: current-execution.md missing → exit 0 + log "absent" ---
clean_state
RC=0
OUT=$(run_hook) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0 when file missing, got $RC"
  exit 1
fi
if ! grep -q "absent" "$HOOK_LOG" 2>/dev/null; then
  echo "FAIL TC1: expected 'absent' in hook log"
  cat "$HOOK_LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC1: current-execution.md missing → exit 0 + log 'absent'"

# --- TC2: no ⏳ PENDING markers → silent ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution
## Active focus: Phase 3.5 T7 retrofit.
All HR-1 items DONE.
EOF
RC=0
OUT=$(run_hook) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0 when no PENDING, got $RC"
  exit 1
fi
if echo "$OUT" | grep -q "ALERT"; then
  echo "FAIL TC2: should NOT emit ALERT when no PENDING; stderr:"
  echo "$OUT"
  exit 1
fi
# .dod-watchdog.log should record hr_pending=0 all_pending=0
if ! grep -q "all_pending=0" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected 'all_pending=0' in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC2: no ⏳ PENDING → silent (all_pending=0)"

# --- TC3: HR-* line with ⏳ PENDING → ALERT stderr ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Recovery
- HR-1 ⏳ PENDING ratify charter v1.1
- HR-2 DONE
EOF
RC=0
OUT=$(run_hook) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0 in default mode with PENDING, got $RC"
  exit 1
fi
if ! echo "$OUT" | grep -q "harness-recovery-dod-watchdog ALERT"; then
  echo "FAIL TC3: expected ALERT in stderr; got:"
  echo "$OUT"
  exit 1
fi
if ! grep -q "hr_pending=1" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected hr_pending=1 in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: HR-* ⏳ PENDING → ALERT stderr + hr_pending=1"

# --- TC4: non-HR ⏳ PENDING → all_pending counted ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Mixed
- Track J ⏳ PENDING approval
- HR-3 ⏳ PENDING migration
EOF
RC=0
OUT=$(run_hook) || RC=$?
# Expect hr_pending=1 (only HR-3 matches HR-[0-9]+); all_pending=2 (both lines)
if ! grep -q "all_pending=2" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected all_pending=2 in log"
  cat "$LOG"
  exit 1
fi
if ! grep -q "hr_pending=1" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected hr_pending=1 in log (only HR-3 matches)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: non-HR ⏳ PENDING counted in all_pending=2 (hr_pending=1)"

# --- TC5: strict mode + PENDING → exit 2 ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
- HR-9 ⏳ PENDING blockers
EOF
RC=0
OUT=$(run_hook_strict) || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC5: expected exit 2 in strict mode with PENDING, got $RC"
  echo "stderr: $OUT"
  exit 1
fi
if ! grep -q "HARD-BLOCK" "$HOOK_LOG" 2>/dev/null; then
  echo "FAIL TC5: expected HARD-BLOCK marker in hook log"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC5: strict mode + PENDING → exit 2 + HARD-BLOCK marker"

# --- TC6: default mode + PENDING → exit 0 (advisory) ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
- HR-7 ⏳ PENDING
EOF
RC=0
OUT=$(run_hook) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC6: expected exit 0 in default mode (advisory only), got $RC"
  exit 1
fi
echo "PASS TC6: default mode + PENDING → exit 0 (advisory)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "harness-recovery-dod-watchdog.sh externally-observable behavior verified."
exit 0
