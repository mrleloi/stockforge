#!/usr/bin/env bash
# Firing-test for auto-reboot-handoff-verify.sh (Phase 3.5 T7-followup; S73).
#
# Hook purpose (HH-H.4 Stop hook; defense-in-depth outer fence to HH-H.1's
# 5-min strict guard inside session-self-reboot.sh):
#   - reads agent-workspace/memory/.transcript-tokens (TOTAL token count)
#   - if TOTAL < STOCKFORGE_WIND_DOWN_TOKENS (default 180000) → exit 0 (no-op)
#   - else: checks agent-workspace/memory/checkpoints/latest.md mtime
#   - if checkpoint age <= 7200s (2h) → exit 0 + clear any prior pre-block
#     marker so budget-watchdog can fire normally
#   - else: writes .auto-reboot-PRE-BLOCKED-stale-checkpoint marker AND
#     appends URGENT entry to human-workspace/notifications/urgent.md
#   - always exits 0 (soft-warn never blocks Stop chain)
#
# 5 test cases:
#   TC1 — no token file → silent no-op (no marker, no urgent)
#   TC2 — tokens below wind_down → silent no-op (no marker, no urgent)
#   TC3 — tokens >= wind_down + fresh checkpoint (<2h) → no marker, no urgent
#   TC4 — tokens >= wind_down + stale checkpoint (>2h) → marker exists +
#         URGENT line appended
#   TC5 — tokens >= wind_down + missing checkpoint → marker exists + URGENT
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../auto-reboot-handoff-verify.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MARKER="$TEMPDIR/agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
URGENT="$TEMPDIR/human-workspace/notifications/urgent.md"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
TOKEN_FILE="$TEMPDIR/agent-workspace/memory/.transcript-tokens"
CHECKPOINT="$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory/checkpoints" \
           "$TEMPDIR/human-workspace/notifications"
}

# --- TC1: no token file → silent no-op ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0 (no token file); got $RC"
  exit 1
fi
if [ -f "$MARKER" ]; then
  echo "FAIL TC1: pre-block marker should NOT exist when no token file"
  exit 1
fi
if [ -f "$URGENT" ] && grep -q "AUTO-REBOOT BLOCKED" "$URGENT"; then
  echo "FAIL TC1: URGENT should not contain BLOCKED line when no token file"
  exit 1
fi
echo "PASS TC1: no token file → silent no-op"

# --- TC2: tokens below wind_down → silent no-op ---
clean_state
echo "100000" > "$TOKEN_FILE"
echo "# Checkpoint clean" > "$CHECKPOINT"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$MARKER" ]; then
  echo "FAIL TC2: pre-block marker should NOT exist below wind_down threshold"
  exit 1
fi
echo "PASS TC2: tokens below wind_down → silent no-op"

# --- TC3: tokens >= wind_down + fresh checkpoint → no marker; prior marker cleared ---
clean_state
echo "200000" > "$TOKEN_FILE"
echo "# Fresh checkpoint" > "$CHECKPOINT"
# Pre-stage a prior pre-block marker — hook should clear it on fresh-checkpoint path.
echo "stale_marker_from_prior_run" > "$MARKER"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$MARKER" ]; then
  echo "FAIL TC3: prior pre-block marker should be cleared when checkpoint is fresh"
  exit 1
fi
echo "PASS TC3: tokens above wind_down + fresh checkpoint → marker cleared"

# --- TC4: tokens >= wind_down + stale checkpoint → marker + URGENT ---
clean_state
echo "210000" > "$TOKEN_FILE"
echo "# Stale checkpoint" > "$CHECKPOINT"
touch -d "3 hours ago" "$CHECKPOINT"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0 (soft-warn); got $RC"
  exit 1
fi
if [ ! -f "$MARKER" ]; then
  echo "FAIL TC4: expected pre-block marker at $MARKER"
  exit 1
fi
if ! grep -q "pre_blocked_at" "$MARKER"; then
  echo "FAIL TC4: marker should contain 'pre_blocked_at' field"
  cat "$MARKER"
  exit 1
fi
if [ ! -f "$URGENT" ]; then
  echo "FAIL TC4: expected URGENT notification file at $URGENT"
  exit 1
fi
if ! grep -q "AUTO-REBOOT BLOCKED" "$URGENT"; then
  echo "FAIL TC4: URGENT should contain 'AUTO-REBOOT BLOCKED' header"
  cat "$URGENT"
  exit 1
fi
if ! grep -q "STALE CHECKPOINT" "$URGENT"; then
  echo "FAIL TC4: URGENT should mention 'STALE CHECKPOINT'"
  cat "$URGENT"
  exit 1
fi
if ! grep -q "BLOCKED reboot tokens=210000" "$HOOK_LOG"; then
  echo "FAIL TC4: hook log should record 'BLOCKED reboot tokens=210000'"
  cat "$HOOK_LOG" 2>/dev/null || true
  exit 1
fi
echo "PASS TC4: tokens above wind_down + stale checkpoint → marker + URGENT"

# --- TC5: tokens >= wind_down + missing checkpoint → marker + URGENT ---
clean_state
echo "220000" > "$TOKEN_FILE"
# No checkpoint file written.
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$MARKER" ]; then
  echo "FAIL TC5: expected pre-block marker when checkpoint missing"
  exit 1
fi
if ! grep -q "checkpoint_age_s=999999" "$MARKER"; then
  echo "FAIL TC5: marker should record sentinel age 999999 for missing checkpoint"
  cat "$MARKER"
  exit 1
fi
echo "PASS TC5: tokens above wind_down + missing checkpoint → marker + URGENT"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "auto-reboot-handoff-verify.sh externally-observable behavior verified."
exit 0
