#!/usr/bin/env bash
# Firing-test for idle-state-advisory.sh (S317 harness recovery; mass-deletion re-author).
#
# Hook purpose: read-only harness-state aggregator. Collects upstream sub-hook
# states (harness-health, idle-escape, phase-coherence) + workspace counters into
# a single-line snapshot cache .idle-state-advisory-cache-${SID}.
#
# 5 test cases:
#   TC1 — empty workspace, no sub-caches → cache written, green=YES, default fields
#   TC2 — harness-health cache state=YELLOW → green=NO, hh=YELLOW in snapshot
#   TC3 — all 3 sub-caches GREEN → green=YES, hh/ie/pc all GREEN
#   TC4 — workspace counters (urgent.md lines, pending Q&A, user_prompt) populated
#   TC5 — 5-min session cache → second run within 300s logs CACHE-HIT
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../idle-state-advisory.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

SID="firetest"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
CACHE="$MEM_DIR/.idle-state-advisory-cache-${SID}"
HOOK_LOG="$MEM_DIR/.session-hooks.log"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$SID" bash "$HOOK" SessionStart </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR"
}

# --- TC1: empty workspace → cache written, green=YES, defaults ---
clean_state
run_hook
if [ ! -f "$CACHE" ]; then
  echo "FAIL TC1: cache file should be written"
  exit 1
fi
if ! grep -q "green=YES" "$CACHE"; then
  echo "FAIL TC1: expected green=YES with no non-GREEN sub-states; cache:"
  cat "$CACHE"
  exit 1
fi
for field in "session=$SID" "urgent_lines=0" "unattested=0" "qa_bundles=0" "qg_open=0"; do
  if ! grep -q "$field" "$CACHE"; then
    echo "FAIL TC1: expected '$field' in cache line; cache:"
    cat "$CACHE"
    exit 1
  fi
done
echo "PASS TC1: empty workspace → cache written, green=YES, default fields"

# --- TC2: harness-health YELLOW → green=NO ---
clean_state
echo "session=$SID ts=2026-01-01T00:00:00 state=YELLOW high=0 medium=2" > "$MEM_DIR/.harness-health-cache-${SID}"
run_hook
if ! grep -q "green=NO" "$CACHE"; then
  echo "FAIL TC2: harness-health=YELLOW should drive green=NO; cache:"
  cat "$CACHE"
  exit 1
fi
if ! grep -q "hh=YELLOW" "$CACHE"; then
  echo "FAIL TC2: expected hh=YELLOW in snapshot; cache:"
  cat "$CACHE"
  exit 1
fi
echo "PASS TC2: harness-health YELLOW → green=NO, hh=YELLOW"

# --- TC3: all sub-caches GREEN → green=YES ---
clean_state
echo "session=$SID ts=t state=GREEN high=0 medium=0" > "$MEM_DIR/.harness-health-cache-${SID}"
echo "session=$SID ts=t state=GREEN severity=LOW consecutive=0" > "$MEM_DIR/.idle-escape-cache-${SID}"
echo "session=$SID ts=t state=GREEN severity=LOW ce_phase=3.5" > "$MEM_DIR/.phase-coherence-cache-${SID}"
run_hook
if ! grep -q "green=YES" "$CACHE"; then
  echo "FAIL TC3: all-GREEN sub-caches should give green=YES; cache:"
  cat "$CACHE"
  exit 1
fi
if ! grep -q "hh=GREEN ie=GREEN pc=GREEN" "$CACHE"; then
  echo "FAIL TC3: expected hh=GREEN ie=GREEN pc=GREEN; cache:"
  cat "$CACHE"
  exit 1
fi
echo "PASS TC3: all sub-caches GREEN → green=YES"

# --- TC4: workspace counters populated ---
clean_state
mkdir -p "$TEMPDIR/human-workspace/notifications" "$TEMPDIR/human-workspace/q-and-a/pending" "$TEMPDIR/human-workspace/user_prompt"
printf 'line1\nline2\nline3\n' > "$TEMPDIR/human-workspace/notifications/urgent.md"
echo "bundle a" > "$TEMPDIR/human-workspace/q-and-a/pending/2026-01-01-001-test.md"
echo "bundle b" > "$TEMPDIR/human-workspace/q-and-a/pending/2026-01-02-001-test.md"
echo "a prompt" > "$TEMPDIR/human-workspace/user_prompt/20260101_01_test.txt"
run_hook
if ! grep -q "urgent_lines=3" "$CACHE"; then
  echo "FAIL TC4: expected urgent_lines=3; cache:"; cat "$CACHE"; exit 1
fi
if ! grep -q "qa_bundles=2" "$CACHE"; then
  echo "FAIL TC4: expected qa_bundles=2; cache:"; cat "$CACHE"; exit 1
fi
if grep -q "up_delta_hr=999" "$CACHE"; then
  echo "FAIL TC4: up_delta_hr should be computed (not 999) when a user_prompt file exists; cache:"
  cat "$CACHE"; exit 1
fi
echo "PASS TC4: workspace counters (urgent_lines, qa_bundles, up_delta_hr) populated"

# --- TC5: 5-min cache → second run logs CACHE-HIT ---
clean_state
run_hook   # first run writes cache
run_hook   # second run within 300s → CACHE-HIT
if ! grep -q "idle-state-advisory: CACHE-HIT" "$HOOK_LOG"; then
  echo "FAIL TC5: second run within 300s should log CACHE-HIT; hook log:"
  cat "$HOOK_LOG" 2>/dev/null || echo "(no hook log)"
  exit 1
fi
echo "PASS TC5: 5-min session cache → second run CACHE-HIT"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "idle-state-advisory.sh externally-observable behavior verified."
exit 0
