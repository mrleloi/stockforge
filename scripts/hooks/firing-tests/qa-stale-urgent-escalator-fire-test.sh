#!/usr/bin/env bash
# Firing-test for qa-stale-urgent-escalator.sh (Phase 3.5 T7 retrofit; S61).
# Extended at S109 with TC7 — L-S108-1 stale-marker regression test.
#
# Hook purpose (HH-E.1 Stop): scan human-workspace/q-and-a/pending/ for bundles
# older than 48h; emit URGENT entry to human-workspace/notifications/urgent.md.
# Idempotent per HOUR-BUCKET via marker file (L-S108-1; was per-session but
# $CLAUDE_SESSION_ID empty on Windows → fallback-to-constant lockout).
#
# Test strategy: stage temp PROJECT_DIR with various pending bundle fixtures
# (varying mtime via touch -d); invoke hook; assert urgent.md content + log.
#
# 7 test cases:
#   TC1 — pending dir missing → silent (no urgent.md, no log)
#   TC2 — 0 stale bundles (all <48h) → log "0 stale"
#   TC3 — 1 stale bundle (>48h via touch -d) → URGENT entry + WARN + marker
#   TC4 — multiple stale bundles → URGENT counts all
#   TC5 — recent bundle (<48h) coexists with stale → only stale counted
#   TC6 — idempotent (marker prevents 2nd-call re-fire same hour)
#   TC7 — L-S108-1 REGRESSION: stale cross-bucket + legacy "main" marker
#         present → cleanup deletes both, URGENT fired
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../qa-stale-urgent-escalator.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.qa-urgent-escalator.log"
URGENT="$TEMPDIR/human-workspace/notifications/urgent.md"
PEND="$TEMPDIR/human-workspace/q-and-a/pending"

run_hook() {
  local sid="${1:-tc-session}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

current_marker() {
  # Hour-bucket marker per L-S108-1 (matches hook's date +%Y%m%d-%H)
  echo "$TEMPDIR/agent-workspace/memory/.qa-urgent-fired-$(date +%Y%m%d-%H)"
}

# --- TC1: pending dir missing → silent ---
clean_state
run_hook "tc1"
if [ -f "$URGENT" ]; then
  echo "FAIL TC1: urgent.md should not be created when pending/ missing"
  cat "$URGENT"
  exit 1
fi
echo "PASS TC1: pending/ missing → silent"

# --- TC2: 0 stale bundles (recent) → log '0 stale' ---
clean_state
mkdir -p "$PEND"
echo "fresh content" > "$PEND/fresh1.md"
echo "fresh content" > "$PEND/fresh2.md"
run_hook "tc2"
if [ -f "$URGENT" ]; then
  echo "FAIL TC2: urgent.md should NOT be created when 0 stale bundles"
  cat "$URGENT"
  exit 1
fi
if ! grep -q "0 stale" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected '0 stale' in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC2: 0 stale bundles → log '0 stale'"

# --- TC3: 1 stale bundle (>48h) → URGENT entry + marker ---
clean_state
mkdir -p "$PEND"
echo "stale content" > "$PEND/stale1.md"
touch -d "3 days ago" "$PEND/stale1.md"
run_hook "tc3"
if [ ! -f "$URGENT" ]; then
  echo "FAIL TC3: urgent.md should be created"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
if ! grep -q "stale1.md" "$URGENT"; then
  echo "FAIL TC3: urgent.md should mention stale1.md"
  cat "$URGENT"
  exit 1
fi
if ! grep -q "1 count" "$URGENT"; then
  echo "FAIL TC3: urgent.md should report count=1"
  cat "$URGENT"
  exit 1
fi
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC3: current-bucket marker should exist after firing"
  exit 1
fi
echo "PASS TC3: 1 stale (>48h) → URGENT entry + marker"

# --- TC4: multiple stale bundles → URGENT counts all ---
clean_state
mkdir -p "$PEND"
for i in 1 2 3; do
  echo "stale $i" > "$PEND/stale-$i.md"
  touch -d "5 days ago" "$PEND/stale-$i.md"
done
run_hook "tc4"
if ! grep -q "3 count" "$URGENT" 2>/dev/null; then
  echo "FAIL TC4: urgent.md should report count=3"
  cat "$URGENT" 2>&1 || echo "(no urgent)"
  exit 1
fi
echo "PASS TC4: 3 stale bundles → count=3 in URGENT"

# --- TC5: recent + stale coexist → only stale counted ---
clean_state
mkdir -p "$PEND"
echo "fresh" > "$PEND/fresh.md"
echo "stale" > "$PEND/stale.md"
touch -d "4 days ago" "$PEND/stale.md"
run_hook "tc5"
if ! grep -q "1 count" "$URGENT" 2>/dev/null; then
  echo "FAIL TC5: urgent.md should report count=1 (only stale)"
  cat "$URGENT"
  exit 1
fi
if grep -q "fresh.md" "$URGENT" 2>/dev/null; then
  echo "FAIL TC5: urgent.md should NOT mention fresh.md"
  cat "$URGENT"
  exit 1
fi
echo "PASS TC5: recent + stale → only stale counted"

# --- TC6: idempotent (marker prevents 2nd re-fire) ---
clean_state
mkdir -p "$PEND"
echo "stale" > "$PEND/stale.md"
touch -d "3 days ago" "$PEND/stale.md"
run_hook "tc6"
URGENT_LINES_1=$(wc -l < "$URGENT" 2>/dev/null | tr -d '[:space:]')
[ -z "$URGENT_LINES_1" ] && URGENT_LINES_1=0
run_hook "tc6"
URGENT_LINES_2=$(wc -l < "$URGENT" 2>/dev/null | tr -d '[:space:]')
[ -z "$URGENT_LINES_2" ] && URGENT_LINES_2=0
if [ "$URGENT_LINES_1" != "$URGENT_LINES_2" ]; then
  echo "FAIL TC6: idempotency broken — urgent.md grew on 2nd call (1=$URGENT_LINES_1 2=$URGENT_LINES_2)"
  cat "$URGENT"
  exit 1
fi
echo "PASS TC6: idempotent — marker prevents 2nd-call re-fire"

# --- TC7: L-S108-1 REGRESSION — stale cross-bucket + legacy 'main' marker ---
# Reproduces M-S108-1 sister-bug: agent stuck because .qa-urgent-fired-main
# (legacy CLAUDE_SESSION_ID:-main fallback marker) blocked all subsequent sessions.
# Fix asserts cleanup loop deletes BOTH stale-bucket and legacy markers + work happens.
clean_state
mkdir -p "$PEND"
echo "stale" > "$PEND/stale-tc7.md"
touch -d "3 days ago" "$PEND/stale-tc7.md"
# Plant stale Jan-2026 hour-bucket marker (different bucket from current)
touch "$TEMPDIR/agent-workspace/memory/.qa-urgent-fired-20260105-13"
# Plant LEGACY fallback marker (the EXACT M-S108-1 sister-bug filename observed on disk)
touch "$TEMPDIR/agent-workspace/memory/.qa-urgent-fired-main"
run_hook "tc7"
if [ ! -f "$URGENT" ]; then
  echo "FAIL TC7 (REGRESSION): URGENT should fire; stale-marker lockout NOT prevented"
  ls -la "$TEMPDIR/agent-workspace/memory/" 2>&1
  cat "$LOG" 2>&1
  exit 1
fi
if ! grep -q "stale-tc7.md" "$URGENT"; then
  echo "FAIL TC7: URGENT should mention stale-tc7.md"
  cat "$URGENT"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.qa-urgent-fired-20260105-13" ]; then
  echo "FAIL TC7: stale Jan-2026 marker should have been cleaned up"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.qa-urgent-fired-main" ]; then
  echo "FAIL TC7: legacy 'main' fallback marker should have been cleaned up"
  exit 1
fi
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC7: current-bucket marker should be created post-fire"
  exit 1
fi
echo "PASS TC7: L-S108-1 REGRESSION — stale markers cleaned + URGENT fired"

echo ""
echo "=== ALL FIRING-TESTS PASSED (7/7) ==="
echo "qa-stale-urgent-escalator.sh externally-observable behavior verified."
echo "L-S108-1 stale-marker regression COVERED (TC7)."
exit 0
