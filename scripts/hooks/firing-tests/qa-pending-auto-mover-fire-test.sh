#!/usr/bin/env bash
# Firing-test for qa-pending-auto-mover.sh (Phase 3.5 T7 retrofit; S61).
# Extended at S108 with TC7 — L-S108-1 stale-marker regression test.
#
# Hook purpose (HH-E.2 / D-031 Stop): scan human-workspace/q-and-a/pending/
# for bundles whose frontmatter `status:` starts with answered-|closed-|
# resolved-, AND whose `wait_until:` ISO is past (or absent), AND no global
# `.auto-mv-paused` kill switch. Mv qualifying bundles to answered/.
# Idempotent per HOUR-BUCKET via marker file (L-S108-1; was per-session
# but $CLAUDE_SESSION_ID empty on Windows → fallback-to-constant lockout).
#
# Test strategy: stage temp PROJECT_DIR with various pending bundle fixtures;
# invoke hook; assert mv outcome (file moved or not) + log entries.
#
# 7 test cases:
#   TC1 — pending dir missing → silent + current-bucket marker created
#   TC2 — kill switch (.auto-mv-paused) present → skip all + log
#   TC3 — bundle status=answered-via-chat, no wait_until → MV to answered/
#   TC4 — bundle status=open → SKIP (wrong status)
#   TC5 — bundle status=answered + wait_until in future → DEFER
#   TC6 — idempotent (marker prevents 2nd-call re-fire same hour)
#   TC7 — L-S108-1 REGRESSION: stale cross-bucket markers + legacy "main"
#         fallback marker present → cleanup deletes both, MV happens
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../qa-pending-auto-mover.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.qa-auto-mv.log"
PEND="$TEMPDIR/human-workspace/q-and-a/pending"
ANS="$TEMPDIR/human-workspace/q-and-a/answered"
KILL_SWITCH="$TEMPDIR/human-workspace/q-and-a/.auto-mv-paused"

run_hook() {
  local sid="${1:-tc-session}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory" "$TEMPDIR/human-workspace/q-and-a"
}

current_marker() {
  # Hour-bucket marker per L-S108-1 (matches hook's date +%Y%m%d-%H)
  echo "$TEMPDIR/agent-workspace/memory/.qa-auto-mv-fired-$(date +%Y%m%d-%H)"
}

# --- TC1: pending dir missing → silent + current-bucket marker touched ---
clean_state
run_hook "tc1"
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC1: current-bucket marker should be touched even when pending/ missing"
  ls -la "$TEMPDIR/agent-workspace/memory/" 2>&1
  exit 1
fi
echo "PASS TC1: pending/ missing → silent + current-bucket marker touched"

# --- TC2: kill switch present → skip all + log ---
clean_state
mkdir -p "$PEND"
: > "$KILL_SWITCH"
cat > "$PEND/bundle1.md" <<'EOF'
---
status: answered-via-chat
---
content
EOF
run_hook "tc2"
if [ ! -f "$PEND/bundle1.md" ]; then
  echo "FAIL TC2: kill switch should prevent mv; bundle was moved"
  exit 1
fi
if ! grep -q "kill switch" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected 'kill switch' in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC2: kill switch → skip all + log"

# --- TC3: status=answered-via-chat, no wait_until → MV ---
clean_state
mkdir -p "$PEND"
cat > "$PEND/bundle-tc3.md" <<'EOF'
---
status: answered-via-chat
---
Content here.
EOF
run_hook "tc3"
if [ -f "$PEND/bundle-tc3.md" ]; then
  echo "FAIL TC3: bundle should have been moved to answered/"
  ls -la "$PEND" "$ANS" 2>&1
  cat "$LOG" 2>&1
  exit 1
fi
if [ ! -f "$ANS/bundle-tc3.md" ]; then
  echo "FAIL TC3: bundle should appear in answered/"
  ls -la "$ANS" 2>&1
  exit 1
fi
if ! grep -q "MV bundle-tc3" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected MV log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: status=answered-via-chat → MV to answered/"

# --- TC4: status=open → SKIP ---
clean_state
mkdir -p "$PEND"
cat > "$PEND/bundle-tc4.md" <<'EOF'
---
status: open
---
Open question.
EOF
run_hook "tc4"
if [ ! -f "$PEND/bundle-tc4.md" ]; then
  echo "FAIL TC4: open bundle should NOT be moved"
  exit 1
fi
if ! grep -q "SKIP bundle-tc4" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected SKIP log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: status=open → SKIP (no mv)"

# --- TC5: status=answered + wait_until in future → DEFER ---
clean_state
mkdir -p "$PEND"
FUTURE_TS="$(date -d '+1 hour' -Iseconds 2>/dev/null || date -u -v+1H +%Y-%m-%dT%H:%M:%S 2>/dev/null || echo "2099-01-01T00:00:00Z")"
cat > "$PEND/bundle-tc5.md" <<EOF
---
status: answered-via-chat
wait_until: $FUTURE_TS
---
Wait until future.
EOF
run_hook "tc5"
if [ ! -f "$PEND/bundle-tc5.md" ]; then
  echo "FAIL TC5: bundle with future wait_until should be deferred (not moved)"
  exit 1
fi
if ! grep -q "DEFER bundle-tc5" "$LOG" 2>/dev/null; then
  echo "FAIL TC5: expected DEFER log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: wait_until in future → DEFER"

# --- TC6: idempotent (marker prevents 2nd-call re-fire) ---
clean_state
mkdir -p "$PEND"
cat > "$PEND/bundle-tc6.md" <<'EOF'
---
status: answered-via-chat
---
Round 1.
EOF
run_hook "tc6"
LOG_LINES_1=$(wc -l < "$LOG" 2>/dev/null | tr -d '[:space:]')
[ -z "$LOG_LINES_1" ] && LOG_LINES_1=0
# Stage another bundle; second invocation must NOT process it (marker exists)
cat > "$PEND/bundle-tc6-second.md" <<'EOF'
---
status: answered-via-chat
---
Round 2.
EOF
run_hook "tc6"
LOG_LINES_2=$(wc -l < "$LOG" 2>/dev/null | tr -d '[:space:]')
[ -z "$LOG_LINES_2" ] && LOG_LINES_2=0
if [ "$LOG_LINES_1" != "$LOG_LINES_2" ]; then
  echo "FAIL TC6: idempotency broken — second call wrote new log lines (1=$LOG_LINES_1 2=$LOG_LINES_2)"
  cat "$LOG"
  exit 1
fi
if [ ! -f "$PEND/bundle-tc6-second.md" ]; then
  echo "FAIL TC6: second bundle should NOT be moved (marker prevents 2nd-call)"
  exit 1
fi
echo "PASS TC6: idempotent — marker prevents second-call re-fire"

# --- TC7: L-S108-1 REGRESSION — stale cross-bucket marker + legacy fallback ---
# Reproduces M-S108-1 bug: agent stuck for 24+h because .qa-auto-mv-fired-main
# (legacy CLAUDE_SESSION_ID:-main fallback marker) blocked all subsequent
# sessions. Fix asserts cleanup loop deletes BOTH stale-bucket and legacy markers.
clean_state
mkdir -p "$PEND"
cat > "$PEND/bundle-tc7.md" <<'EOF'
---
status: answered-via-test
---
Stuck-bundle regression scenario.
EOF
# Plant stale Jan-2026 hour-bucket marker (different bucket from current)
touch "$TEMPDIR/agent-workspace/memory/.qa-auto-mv-fired-20260105-13"
# Plant LEGACY fallback marker (the EXACT M-S108-1 bug filename)
touch "$TEMPDIR/agent-workspace/memory/.qa-auto-mv-fired-main"
run_hook "tc7"
if [ -f "$PEND/bundle-tc7.md" ]; then
  echo "FAIL TC7 (REGRESSION): bundle stuck in pending/ — stale-marker lockout NOT prevented"
  ls -la "$TEMPDIR/agent-workspace/memory/" 2>&1
  cat "$LOG" 2>&1
  exit 1
fi
if [ ! -f "$ANS/bundle-tc7.md" ]; then
  echo "FAIL TC7 (REGRESSION): bundle should be in answered/ after stale-marker cleanup"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.qa-auto-mv-fired-20260105-13" ]; then
  echo "FAIL TC7: stale Jan-2026 marker should have been cleaned up"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.qa-auto-mv-fired-main" ]; then
  echo "FAIL TC7: legacy 'main' fallback marker should have been cleaned up"
  exit 1
fi
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC7: current-bucket marker should be created post-MV"
  exit 1
fi
echo "PASS TC7: L-S108-1 REGRESSION — stale markers cleaned + bundle MV'd"

echo ""
echo "=== ALL FIRING-TESTS PASSED (7/7) ==="
echo "qa-pending-auto-mover.sh externally-observable behavior verified."
echo "L-S108-1 stale-marker regression COVERED (TC7)."
exit 0
