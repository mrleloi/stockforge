#!/usr/bin/env bash
# Firing-test for session-end-checklist-linter.sh (Phase 3.5 T7 retrofit; S59).
#
# Hook purpose (HH-C.1 Stop): verify most-recent session log mentions a mistake-log
# update (entry M-S<N>-<M> OR explicit "no mistakes this session" attestation).
# Soft-warn on miss. Idempotent per session (marker file).
#
# Test strategy: stage temp PROJECT_DIR with sessions/ dir + various log fixtures;
# invoke hook; assert .session-hooks.log content reflects pass/warn classification
# AND marker file is created (idempotency).
#
# 6 test cases:
#   TC1 — sessions dir missing → silent (marker still touched)
#   TC2 — no recent (<4h) session log → WARN no_recent_log
#   TC3 — recent log mentions M-S<N>-<M> → silent (pass attestation)
#   TC4 — recent log says "no mistakes this session" → silent (pass attestation)
#   TC5 — recent log lacks attestation → WARN missing_attestation
#   TC6 — idempotent: second invocation no-op (marker present)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../session-end-checklist-linter.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  local session_id="${1:-test-session-tc}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$session_id" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: sessions/ dir missing → silent (no log entry) ---
clean_state
run_hook "tc1-session"
# Hook should silently exit; no log entry expected.
if [ -f "$LOG" ] && grep -q "tc1-session" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: hook should silently exit when sessions/ missing; log entry found"
  cat "$LOG"
  exit 1
fi
# Marker still touched per hook contract.
if [ ! -f "$TEMPDIR/agent-workspace/memory/.session-end-checklist-fired-tc1-session" ]; then
  echo "FAIL TC1: marker should be touched even on silent path"
  exit 1
fi
echo "PASS TC1: sessions/ missing → silent + marker touched"

# --- TC2: no recent log (mtime > 4h old) → WARN no_recent_log ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
echo "old log content with M-S1-1 mention" > "$TEMPDIR/agent-workspace/memory/sessions/2020-01-01-session-1.md"
# Force mtime old (>240 minutes ago).
touch -d "5 hours ago" "$TEMPDIR/agent-workspace/memory/sessions/2020-01-01-session-1.md"
run_hook "tc2-session"
if [ ! -f "$LOG" ] || ! grep -q "no_recent_log" "$LOG"; then
  echo "FAIL TC2: expected 'no_recent_log' WARN in session-hooks.log"
  echo "Log content:"; cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC2: no recent (<4h) log → WARN no_recent_log"

# --- TC3: recent log mentions M-S<N>-<M> → silent (pass) ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-99.md" <<EOF
# Session 99

Some work happened. M-S99-1 was the new mistake catalogued this session.
EOF
run_hook "tc3-session"
if [ -f "$LOG" ] && grep -q "missing_attestation" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: log mentions M-S99-1 attestation; should NOT emit missing_attestation WARN"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: M-S<N>-<M> attestation → silent (pass)"

# --- TC4: "no mistakes this session" attestation → silent (pass) ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-100.md" <<EOF
# Session 100

Routine work; no mistakes this session.
EOF
run_hook "tc4-session"
if [ -f "$LOG" ] && grep -q "missing_attestation" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: log says 'no mistakes this session'; should NOT emit missing_attestation WARN"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: 'no mistakes this session' attestation → silent (pass)"

# --- TC5: recent log lacks attestation → WARN missing_attestation ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-101.md" <<EOF
# Session 101

Wrote some code. Closed deliverables. No discussion of mistakes here at all.
EOF
run_hook "tc5-session"
if [ ! -f "$LOG" ] || ! grep -q "missing_attestation" "$LOG"; then
  echo "FAIL TC5: expected 'missing_attestation' WARN in session-hooks.log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC5: lacks attestation → WARN missing_attestation"

# --- TC6: idempotent (marker present → silent on 2nd call) ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-102.md" <<EOF
# Session 102

Lacks attestation again.
EOF
run_hook "tc6-session"
# First call should warn.
LOG_LINES_AFTER_1=$(grep -c "tc6-session" "$LOG" 2>/dev/null || echo 0)
LOG_LINES_AFTER_1=${LOG_LINES_AFTER_1//[^0-9]/}
[ -z "$LOG_LINES_AFTER_1" ] && LOG_LINES_AFTER_1=0
run_hook "tc6-session"
LOG_LINES_AFTER_2=$(grep -c "tc6-session" "$LOG" 2>/dev/null || echo 0)
LOG_LINES_AFTER_2=${LOG_LINES_AFTER_2//[^0-9]/}
[ -z "$LOG_LINES_AFTER_2" ] && LOG_LINES_AFTER_2=0
if [ "$LOG_LINES_AFTER_1" -ne "$LOG_LINES_AFTER_2" ]; then
  echo "FAIL TC6: idempotency broken; first=$LOG_LINES_AFTER_1 second=$LOG_LINES_AFTER_2 (should be equal)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: idempotent — marker prevents second-call re-fire"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "session-end-checklist-linter.sh externally-observable behavior verified."
exit 0
