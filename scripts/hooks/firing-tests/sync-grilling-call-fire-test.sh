#!/usr/bin/env bash
# Firing-test for sync-grilling-call.sh (S129 promote-to-hook L-S69-1 2nd-instance;
# S130 timezone-contract regression TC6 added per M-S130-1).
#
# Wrapper purpose:
#   - Hides $3 OVERRIDE_DELTA arg (M-S98-1 + M-S101-1 prevention contract)
#   - Calls sync-tracker-update.sh with 5-arg contract
#   - S129 NEW: on rc=0 + sync-state.md present + S<N> parseable from $3,
#     updates frontmatter `last_check: <today>` + `last_check_session: S<N>`
#   - S130 FIX: TODAY = `date +%Y-%m-%d` (LOCAL TZ) — matches session-file naming
#     convention sessions/YYYY-MM-DD-session-N.md (local at write); aligns with
#     sync-grilling-trigger.sh consumer which compares filename-date > last_check.
#   - Wrapper rc = sync-tracker-update.sh rc; sync-state.md update is best-effort
#
# 6 test cases:
#   TC1 — missing arg (only 4 supplied) → exit 2; sync-state.md untouched
#   TC2 — success path: events.tsv updated AND sync-state.md last_check (LOCAL) + last_check_session updated
#   TC3 — invalid category → wrapper exits non-zero; sync-state.md untouched
#   TC4 — missing sync-state.md → wrapper still succeeds; events.tsv updated; no edit attempt
#   TC5 — decision_id without S<N> → wrapper succeeds; sync-state.md NOT updated (no S<N>)
#   TC6 — timezone contract: last_check value matches `date +%Y-%m-%d` (LOCAL), NOT `date -u +%Y-%m-%d`
#         when local and UTC differ (regression guard for M-S130-1 UTC-vs-local mismatch)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/.."
WRAPPER_SRC="$SRC_DIR/sync-grilling-call.sh"
UPDATE_SRC="$SRC_DIR/sync-tracker-update.sh"
RENDER_SRC="$SRC_DIR/sync-tracker-render.sh"

[ ! -f "$WRAPPER_SRC" ] && { echo "FAIL: wrapper not found at $WRAPPER_SRC"; exit 1; }
[ ! -f "$UPDATE_SRC" ] && { echo "FAIL: sync-tracker-update not found at $UPDATE_SRC"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

HOOKS_DIR="$TEMPDIR/scripts/hooks"
SYNC_DIR="$TEMPDIR/agent-workspace/memory/sync-tracker"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
mkdir -p "$HOOKS_DIR" "$SYNC_DIR" "$MEM_DIR"

cp "$WRAPPER_SRC" "$HOOKS_DIR/sync-grilling-call.sh"
cp "$UPDATE_SRC" "$HOOKS_DIR/sync-tracker-update.sh"
[ -f "$RENDER_SRC" ] && cp "$RENDER_SRC" "$HOOKS_DIR/sync-tracker-render.sh"

WRAPPER="$HOOKS_DIR/sync-grilling-call.sh"

stage_fixture() {
  cat > "$SYNC_DIR/weights.yaml" << 'EOF'
category_LANGUAGE: 50
category_DOMAIN_UBIQUITOUS: 50
category_DESIGN_THINKING: 50
category_SCOPE: 50
category_DECISION_ROUTING: 50

weight_charter_match: 0.2
weight_drift_signal: -0.5
weight_q_and_a_resolution: 0.3
weight_decision_correctness: 0.5
weight_decision_correction: -0.3
weight_decision_revocation: -1.0
weight_thesis_revocation: -1.0
reversal_must_grill_cycles: 5
EOF

  printf 'ts\tcat\tevt\tdelta\tdec_id\tsrc_ev\treason\n' > "$SYNC_DIR/events.tsv"
  printf 'category\tcurrent_score\tsample_count\tlast_updated_ts\tmust_grill_remaining\n' > "$SYNC_DIR/state.tsv"
  for cat in LANGUAGE DOMAIN_UBIQUITOUS DESIGN_THINKING SCOPE DECISION_ROUTING; do
    printf '%s\t50\t0\t1970-01-01T00:00:00Z\t0\n' "$cat" >> "$SYNC_DIR/state.tsv"
  done
}

stage_sync_state() {
  cat > "$MEM_DIR/sync-state.md" << 'EOF'
---
schema_version: 1
last_check: 2026-04-01
last_check_session: S001
description: |
  Test fixture
---

# Sync State
(test content)
EOF
}

# --- TC1 — missing arg (4 supplied, no $5 reason) → exit 2; sync-state.md untouched ---
stage_fixture
stage_sync_state
RC=0
bash "$WRAPPER" SCOPE charter_match sync-grilling-S129 agent-workspace/memory/sync-state.md >/dev/null 2>&1 || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC1: expected rc=2 for missing arg; got $RC"
  exit 1
fi
if ! grep -q "^last_check: 2026-04-01" "$MEM_DIR/sync-state.md"; then
  echo "FAIL TC1: sync-state.md was modified despite arg validation failure"
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
echo "PASS TC1: missing arg → exit 2; sync-state.md untouched"

# --- TC2 — success path → events.tsv + sync-state.md both updated ---
stage_fixture
stage_sync_state
TODAY=$(date +%Y-%m-%d)  # S130 fix: LOCAL TZ (was -u UTC); matches wrapper post-M-S130-1 fix
RC=0
bash "$WRAPPER" SCOPE charter_match sync-grilling-S129 agent-workspace/memory/sync-state.md "S129 test reason" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected rc=0; got $RC"
  exit 1
fi
EVENT_LINES=$(wc -l < "$SYNC_DIR/events.tsv")
if [ "$EVENT_LINES" != "2" ]; then
  echo "FAIL TC2: events.tsv expected 2 lines (header + 1 row); got $EVENT_LINES"
  cat "$SYNC_DIR/events.tsv"
  exit 1
fi
if ! grep -q "^last_check: $TODAY" "$MEM_DIR/sync-state.md"; then
  echo "FAIL TC2: sync-state.md last_check not updated to $TODAY"
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
if ! grep -q "^last_check_session: S129" "$MEM_DIR/sync-state.md"; then
  echo "FAIL TC2: sync-state.md last_check_session not updated to S129"
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
echo "PASS TC2: success path → events.tsv updated + sync-state.md last_check=$TODAY + last_check_session=S129"

# --- TC3 — invalid category → wrapper exits non-zero; sync-state.md untouched ---
stage_fixture
stage_sync_state
RC=0
bash "$WRAPPER" INVALID_CAT charter_match sync-grilling-S129 agent-workspace/memory/sync-state.md "test" >/dev/null 2>&1 || RC=$?
if [ "$RC" = "0" ]; then
  echo "FAIL TC3: expected non-zero rc for invalid category; got 0"
  exit 1
fi
if ! grep -q "^last_check: 2026-04-01" "$MEM_DIR/sync-state.md"; then
  echo "FAIL TC3: sync-state.md was modified despite update failure"
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
echo "PASS TC3: invalid category → wrapper exits non-zero; sync-state.md untouched"

# --- TC4 — missing sync-state.md → wrapper still succeeds; events.tsv updated ---
stage_fixture
rm -f "$MEM_DIR/sync-state.md"
RC=0
bash "$WRAPPER" SCOPE charter_match sync-grilling-S129 agent-workspace/memory/sync-state.md "test" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected rc=0 with missing sync-state.md; got $RC"
  exit 1
fi
EVENT_LINES=$(wc -l < "$SYNC_DIR/events.tsv")
if [ "$EVENT_LINES" != "2" ]; then
  echo "FAIL TC4: events.tsv not updated"
  exit 1
fi
echo "PASS TC4: missing sync-state.md → wrapper succeeds; events.tsv updated; no edit attempt"

# --- TC5 — decision_id without S<N> → wrapper succeeds; sync-state.md NOT updated ---
stage_fixture
stage_sync_state
RC=0
bash "$WRAPPER" SCOPE charter_match no-session-id agent-workspace/memory/sync-state.md "test" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected rc=0; got $RC"
  exit 1
fi
if ! grep -q "^last_check: 2026-04-01" "$MEM_DIR/sync-state.md"; then
  echo "FAIL TC5: sync-state.md was updated despite missing S<N> in decision_id"
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
echo "PASS TC5: decision_id without S<N> → wrapper succeeds; sync-state.md NOT updated"

# --- TC6 — timezone contract: last_check matches LOCAL date (regression guard M-S130-1) ---
# This test enforces the contract: wrapper writes `last_check` in local time (matching
# session-file naming convention) NOT UTC. If wrapper is changed back to `date -u`,
# this test fails when local-vs-UTC differ (e.g. Vietnam UTC+7 between 17:00-23:59 UTC).
stage_fixture
stage_sync_state
LOCAL_TODAY=$(date +%Y-%m-%d)
UTC_TODAY=$(date -u +%Y-%m-%d)
RC=0
bash "$WRAPPER" SCOPE charter_match sync-grilling-S130 agent-workspace/memory/sync-state.md "TC6 timezone contract" >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC6: expected rc=0; got $RC"
  exit 1
fi
WRITTEN=$(grep -E '^last_check:' "$MEM_DIR/sync-state.md" | head -1 | awk '{print $2}')
if [ "$WRITTEN" != "$LOCAL_TODAY" ]; then
  echo "FAIL TC6: wrapper wrote last_check=$WRITTEN; expected LOCAL=$LOCAL_TODAY (UTC=$UTC_TODAY)"
  echo "  This indicates regression to UTC date (M-S130-1). Sessions are named with local date."
  cat "$MEM_DIR/sync-state.md"
  exit 1
fi
# Tighter assertion only when local and UTC differ (otherwise indistinguishable):
if [ "$LOCAL_TODAY" != "$UTC_TODAY" ]; then
  if [ "$WRITTEN" = "$UTC_TODAY" ]; then
    echo "FAIL TC6: wrapper wrote UTC ($UTC_TODAY) instead of LOCAL ($LOCAL_TODAY)"
    exit 1
  fi
  echo "PASS TC6: timezone contract — wrapper wrote LOCAL=$LOCAL_TODAY (verified ≠ UTC=$UTC_TODAY)"
else
  echo "PASS TC6: timezone contract — wrapper wrote $WRITTEN (LOCAL=UTC today; tighter assertion non-discriminating)"
fi

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "sync-grilling-call.sh externally-observable behavior verified (S129 last_check auto-update + S130 timezone contract)."
exit 0
