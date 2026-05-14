#!/usr/bin/env bash
# observation-orphan-detector-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Exercises observation-orphan-detector.sh in isolated tmpdir. Verifies:
#   TC1:  empty registry → no severity rows emitted, RC=0
#   TC2:  1 fresh IN_FLIGHT row (1 min old) → not orphaned (below 30 min threshold)
#   TC3:  1 stale IN_FLIGHT row (60 min old) → ORPHANED + HIGH severity row
#   TC4:  1 stale OBSERVATION_WRITTEN row → ORPHANED + HIGH severity row
#   TC5:  kill switch STOCKFORGE_ORPHAN_DETECTOR_DISABLE=1 → no changes
#   TC6:  legacy row (no state column) → treated as SIDECAR_ATTESTED, no orphan
#   TC7:  non-Stop hook_event_name → skipped (hook only fires on Stop events)
#   TC8:  smoke — 3 orphan rows → 3 ORPHANED + 3 HIGH severity rows
#   TC9:  already-ORPHANED row + no marker → re-emit HIGH (D1 F1 fix)
#   TC10: already-ORPHANED row + marker <6h → no re-emit (within cadence)
#   TC11: already-ORPHANED row + marker >30d → CRITICAL severity (D1 F1 escalation)
#   TC12: empty CLAUDE_SESSION_ID → pre-checkpoint-close-verifier skips gracefully RC=0 (D4 F4)
#
# SPAWN-CONTEXT: positional-arg (hook reads stdin for JSON payload; we feed it)

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

note_fail() {
  FAIL=$((FAIL+1))
  ERRORS+=("$1")
}

note_pass() {
  PASS=$((PASS+1))
}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/observation-orphan-detector.sh"
CLOSE_VERIFIER="$SCRIPT_DIR/pre-checkpoint-close-verifier.sh"

[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }
[ -x "$HOOK" ] || chmod +x "$HOOK" 2>/dev/null || true

# Isolated tmpdir
TMP="$(mktemp -d -t orphan-detector-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

MEMORY_DIR="$TMP/agent-workspace/memory"
REGISTRY="$MEMORY_DIR/.unattested-observations.tsv"
SEVERITY_STATE="$MEMORY_DIR/.severity-state.tsv"
STOP_PAYLOAD='{"hook_event_name":"Stop","session_id":"test-session"}'

setup_tmp() {
  rm -rf "$TMP/agent-workspace"
  mkdir -p "$MEMORY_DIR"
}

init_registry() {
  printf 'detected_ts\tsession_id\tobservation_basename\tmarker_present\tlog_row_present\tstate\n' > "$REGISTRY"
}

# Add a row with specified state and age (using a real old timestamp for stale rows)
add_row() {
  local ts="$1"
  local basename="$2"
  local state="$3"
  printf '%s\tunknown\t%s\t0\t0\t%s\n' "$ts" "$basename" "$state" >> "$REGISTRY"
}

# Get timestamp N minutes ago in ISO-8601 UTC
ts_minutes_ago() {
  local minutes="$1"
  date -u -d "$minutes minutes ago" +%FT%TZ 2>/dev/null || \
    date -u -v"-${minutes}M" +%FT%TZ 2>/dev/null || \
    echo "2026-01-01T00:00:00Z"
}

run_hook() {
  local payload="${1:-$STOP_PAYLOAD}"
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" <<< "$payload" 2>/dev/null
}

# ===== TC1: empty registry → RC=0, no severity rows =====
setup_tmp
init_registry
run_hook
RC=$?
SEVERITY_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  SEVERITY_ROWS="$(grep -c "ORPHANED\|orphan" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$RC" -eq 0 ] && [ "$SEVERITY_ROWS" -eq 0 ]; then
  note_pass "TC1 PASS: empty registry → RC=0, no severity rows"
else
  note_fail "TC1 FAIL: RC=$RC, severity_rows=$SEVERITY_ROWS (expected 0/0)"
fi

# ===== TC2: 1 fresh IN_FLIGHT (1 min old) → NOT orphaned =====
setup_tmp
init_registry
FRESH_TS="$(ts_minutes_ago 1)"
add_row "$FRESH_TS" "sandwich-dev-S999-fresh-inflight" "IN_FLIGHT"
STOCKFORGE_ORPHAN_THRESHOLD_MINUTES=30 run_hook
STATE_AFTER="$(grep "fresh-inflight" "$REGISTRY" 2>/dev/null | cut -f6 || echo '')"
if [ "$STATE_AFTER" = "IN_FLIGHT" ]; then
  note_pass "TC2 PASS: fresh IN_FLIGHT (1 min) not orphaned"
else
  note_fail "TC2 FAIL: state_after='$STATE_AFTER' (expected IN_FLIGHT)"
fi

# ===== TC3: 1 stale IN_FLIGHT (60 min old) → ORPHANED + HIGH severity =====
setup_tmp
init_registry
STALE_TS="$(ts_minutes_ago 60)"
add_row "$STALE_TS" "sandwich-dev-S999-stale-inflight" "IN_FLIGHT"
STOCKFORGE_ORPHAN_THRESHOLD_MINUTES=30 run_hook
STATE_AFTER="$(grep "stale-inflight" "$REGISTRY" 2>/dev/null | cut -f6 || echo '')"
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$STATE_AFTER" = "ORPHANED" ] && [ "$HIGH_ROWS" -ge 1 ]; then
  note_pass "TC3 PASS: stale IN_FLIGHT (60 min) → ORPHANED + HIGH severity"
else
  note_fail "TC3 FAIL: state='$STATE_AFTER' high_rows=$HIGH_ROWS (expected ORPHANED/≥1)"
fi

# ===== TC4: 1 stale OBSERVATION_WRITTEN (90 min old) → ORPHANED + HIGH severity =====
setup_tmp
init_registry
STALE_TS="$(ts_minutes_ago 90)"
add_row "$STALE_TS" "sandwich-dev-S999-stale-obs-written" "OBSERVATION_WRITTEN"
STOCKFORGE_ORPHAN_THRESHOLD_MINUTES=30 run_hook
STATE_AFTER="$(grep "stale-obs-written" "$REGISTRY" 2>/dev/null | cut -f6 || echo '')"
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$STATE_AFTER" = "ORPHANED" ] && [ "$HIGH_ROWS" -ge 1 ]; then
  note_pass "TC4 PASS: stale OBSERVATION_WRITTEN → ORPHANED + HIGH severity"
else
  note_fail "TC4 FAIL: state='$STATE_AFTER' high_rows=$HIGH_ROWS (expected ORPHANED/≥1)"
fi

# ===== TC5: kill switch → no changes =====
setup_tmp
init_registry
STALE_TS="$(ts_minutes_ago 60)"
add_row "$STALE_TS" "sandwich-dev-S999-killswitch" "IN_FLIGHT"
STOCKFORGE_ORPHAN_DETECTOR_DISABLE=1 CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" <<< "$STOP_PAYLOAD" 2>/dev/null
STATE_AFTER="$(grep "killswitch" "$REGISTRY" 2>/dev/null | cut -f6 || echo '')"
if [ "$STATE_AFTER" = "IN_FLIGHT" ]; then
  note_pass "TC5 PASS: kill switch → state unchanged (IN_FLIGHT)"
else
  note_fail "TC5 FAIL: state='$STATE_AFTER' (expected IN_FLIGHT — kill switch should prevent change)"
fi

# ===== TC6: legacy row (no state column) → treated as SIDECAR_ATTESTED, no orphan =====
setup_tmp
# Write legacy registry WITHOUT state column
printf 'detected_ts\tsession_id\tobservation_basename\tmarker_present\tlog_row_present\n' > "$REGISTRY"
STALE_TS="$(ts_minutes_ago 60)"
# Legacy row: only 5 columns, no state
printf '%s\tunknown\tsandwich-dev-S999-legacy\t1\t1\n' "$STALE_TS" >> "$REGISTRY"
STOCKFORGE_ORPHAN_THRESHOLD_MINUTES=30 run_hook
# Legacy row should NOT be marked ORPHANED (default = SIDECAR_ATTESTED = already attested)
ORPHANED_COUNT=0
if grep -q "ORPHANED" "$REGISTRY" 2>/dev/null; then
  ORPHANED_COUNT="$(grep -c "ORPHANED" "$REGISTRY" 2>/dev/null || echo 0)"
fi
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ] && grep -q "^HIGH" "$SEVERITY_STATE" 2>/dev/null; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$ORPHANED_COUNT" -eq 0 ] && [ "$HIGH_ROWS" -eq 0 ]; then
  note_pass "TC6 PASS: legacy row (no state col) → SIDECAR_ATTESTED default, no orphan"
else
  note_fail "TC6 FAIL: orphaned_count=$ORPHANED_COUNT high_rows=$HIGH_ROWS (expected 0/0)"
fi

# ===== TC7: non-Stop hook_event_name (SessionStart) → no action =====
setup_tmp
init_registry
STALE_TS="$(ts_minutes_ago 60)"
add_row "$STALE_TS" "sandwich-dev-S999-skip-sessstart" "IN_FLIGHT"
SESSION_START_PAYLOAD='{"hook_event_name":"SessionStart","source":"startup"}'
CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" <<< "$SESSION_START_PAYLOAD" 2>/dev/null
STATE_AFTER="$(grep "skip-sessstart" "$REGISTRY" 2>/dev/null | cut -f6 || echo '')"
if [ "$STATE_AFTER" = "IN_FLIGHT" ]; then
  note_pass "TC7 PASS: SessionStart event → hook skipped, state unchanged"
else
  note_fail "TC7 FAIL: state='$STATE_AFTER' (expected IN_FLIGHT — non-Stop should be skipped)"
fi

# ===== TC8: smoke — 3 orphan rows → 3 HIGH severity rows =====
setup_tmp
init_registry
STALE_TS="$(ts_minutes_ago 60)"
add_row "$STALE_TS" "sandwich-dev-S999-smoke1" "IN_FLIGHT"
add_row "$STALE_TS" "sandwich-dev-S999-smoke2" "OBSERVATION_WRITTEN"
add_row "$STALE_TS" "sandwich-dev-S999-smoke3" "IN_FLIGHT"
# Also add 2 rows that should NOT be orphaned
FRESH_TS="$(ts_minutes_ago 1)"
add_row "$FRESH_TS" "sandwich-dev-S999-smoke-fresh" "IN_FLIGHT"
STALE_TS_ATTESTED="$(ts_minutes_ago 120)"
add_row "$STALE_TS_ATTESTED" "sandwich-dev-S999-smoke-attested" "SIDECAR_ATTESTED"
STOCKFORGE_ORPHAN_THRESHOLD_MINUTES=30 run_hook
ORPHANED_COUNT="$(grep -c "ORPHANED" "$REGISTRY" 2>/dev/null || echo 0)"
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$ORPHANED_COUNT" -eq 3 ] && [ "$HIGH_ROWS" -eq 3 ]; then
  note_pass "TC8 PASS (smoke): 3 stale rows → 3 ORPHANED + 3 HIGH severity rows"
else
  note_fail "TC8 FAIL: orphaned=$ORPHANED_COUNT high=$HIGH_ROWS (expected 3/3)"
fi

# ===== TC9: already-ORPHANED row + no marker → re-emit HIGH (D1 re-escalation) =====
setup_tmp
init_registry
# Orphaned row detected 2 hours ago (col1 = detected_ts; 2h old but recent enough for HIGH not CRITICAL)
ORPHAN_TS="$(ts_minutes_ago 120)"
# 7-col row: col7 = last_transition_at (when it became ORPHANED) = 2h ago
printf '%s\tunknown\tsandwich-dev-S999-orphan-reescalate\t0\t0\tORPHANED\t%s\n' \
  "$ORPHAN_TS" "$ORPHAN_TS" >> "$REGISTRY"
# No marker file → marker_age_hours returns 99999 (> default 6h threshold)
STOCKFORGE_ORPHAN_REESCALATE_HOURS=6 run_hook
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
# Marker should have been created
MARKER_CREATED=0
MARKER_COUNT="$(find "$MEMORY_DIR" -name ".orphan-reescalate-*.last" 2>/dev/null | wc -l || echo 0)"
if [ "$MARKER_COUNT" -ge 1 ]; then
  MARKER_CREATED=1
fi
if [ "$HIGH_ROWS" -ge 1 ] && [ "$MARKER_CREATED" -eq 1 ]; then
  note_pass "TC9 PASS: already-ORPHANED + no marker → HIGH re-emitted + marker created"
else
  note_fail "TC9 FAIL: high_rows=$HIGH_ROWS marker_created=$MARKER_CREATED (expected ≥1/1)"
fi

# ===== TC10: already-ORPHANED row + marker <6h → no re-emit =====
setup_tmp
init_registry
ORPHAN_TS="$(ts_minutes_ago 120)"
printf '%s\tunknown\tsandwich-dev-S999-orphan-within-cadence\t0\t0\tORPHANED\t%s\n' \
  "$ORPHAN_TS" "$ORPHAN_TS" >> "$REGISTRY"
# Pre-create a marker file with a very recent mtime (touches it as current time → age ≈ 0h)
# Compute the sha256 of the artifact key the same way the hook does:
#   artifact_key = "agent-workspace/memory/.unattested-observations.tsv#<basename>"
ARTIFACT_KEY="agent-workspace/memory/.unattested-observations.tsv#sandwich-dev-S999-orphan-within-cadence"
ARTIFACT_SHA="$(printf '%s' "$ARTIFACT_KEY" | sha256sum 2>/dev/null | cut -d' ' -f1 || \
               printf '%s' "$ARTIFACT_KEY" | shasum -a 256 2>/dev/null | cut -d' ' -f1 || \
               printf '%s' "$ARTIFACT_KEY" | cksum 2>/dev/null | awk '{print $1}' || echo fallback)"
MARKER_FILE="$MEMORY_DIR/.orphan-reescalate-${ARTIFACT_SHA}.last"
# Create marker with current timestamp (< 6h old)
printf '%s\n' "marker-created-fresh" > "$MARKER_FILE"
STOCKFORGE_ORPHAN_REESCALATE_HOURS=6 run_hook
HIGH_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  HIGH_ROWS="$(grep -c "^HIGH" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$HIGH_ROWS" -eq 0 ]; then
  note_pass "TC10 PASS: already-ORPHANED + marker <6h → no re-emit"
else
  note_fail "TC10 FAIL: high_rows=$HIGH_ROWS (expected 0 — within cadence, should not re-emit)"
fi

# ===== TC11: already-ORPHANED row + marker mtime >30d (simulated) → CRITICAL severity =====
setup_tmp
init_registry
# Simulate detection >30 days ago (col1 = 31 days ago for CRITICAL escalation check)
ANCIENT_TS="$(date -u -d "31 days ago" +%FT%TZ 2>/dev/null || date -u -v-31d +%FT%TZ 2>/dev/null || echo "2026-04-13T00:00:00Z")"
printf '%s\tunknown\tsandwich-dev-S999-orphan-critical\t0\t0\tORPHANED\t%s\n' \
  "$ANCIENT_TS" "$ANCIENT_TS" >> "$REGISTRY"
# No marker → will re-emit; age_days > ORPHAN_CRITICAL_DAYS → CRITICAL
STOCKFORGE_ORPHAN_REESCALATE_HOURS=6 STOCKFORGE_ORPHAN_CRITICAL_DAYS=30 run_hook
CRITICAL_ROWS=0
if [ -f "$SEVERITY_STATE" ]; then
  CRITICAL_ROWS="$(grep -c "^CRITICAL" "$SEVERITY_STATE" 2>/dev/null || echo 0)"
fi
if [ "$CRITICAL_ROWS" -ge 1 ]; then
  note_pass "TC11 PASS: ORPHANED >30d + no marker → CRITICAL severity re-emitted"
else
  note_fail "TC11 FAIL: critical_rows=$CRITICAL_ROWS (expected ≥1 — >30d orphan should be CRITICAL)"
fi

# ===== TC12: empty CLAUDE_SESSION_ID → pre-checkpoint-close-verifier skips gracefully RC=0 (D4) =====
setup_tmp
# We need a registry + checkpoint file to trigger the close-verifier
mkdir -p "$TMP/agent-workspace/memory/checkpoints"
mkdir -p "$TMP/human-workspace/notifications"
# Create a .session-ready file (simulates session started)
touch "$TMP/agent-workspace/memory/.session-ready"
# Create latest.md checkpoint modified after .session-ready
sleep 0.1 2>/dev/null || true
printf '# test checkpoint\n' > "$TMP/agent-workspace/memory/checkpoints/latest.md"
# Create registry with OBSERVATION_WRITTEN row (would normally trigger warning)
printf 'detected_ts\tsession_id\tobservation_basename\tmarker_present\tlog_row_present\tstate\n' > "$REGISTRY"
FRESH_TS="$(ts_minutes_ago 1)"
printf '%s\tsession-abc\tobs-test.md\t0\t0\tOBSERVATION_WRITTEN\n' "$FRESH_TS" >> "$REGISTRY"
# Run pre-checkpoint-close-verifier with EMPTY CLAUDE_SESSION_ID
# Expected: hook skips the FSM OBSERVATION_WRITTEN check (CLAUDE_SESSION_ID is empty → guard fails)
# and returns RC=0 (no false block)
VERIFIER_RC=0
if [ -x "$CLOSE_VERIFIER" ] || [ -r "$CLOSE_VERIFIER" ]; then
  CLAUDE_SESSION_ID="" CLAUDE_PROJECT_DIR="$TMP" bash "$CLOSE_VERIFIER" <<< "$STOP_PAYLOAD" 2>/dev/null
  VERIFIER_RC=$?
  # Also check: no OBS_WRITTEN notification file should have been created for current (empty) session
  # because the guard `[ -n "$CURRENT_SESSION" ]` prevents the inner loop
  OBS_NOTIF_COUNT=0
  if [ -d "$TMP/human-workspace/notifications" ]; then
    OBS_NOTIF_COUNT="$(find "$TMP/human-workspace/notifications" -name "*obs-written-block*" 2>/dev/null | wc -l || echo 0)"
  fi
  if [ "$VERIFIER_RC" -eq 0 ] && [ "$OBS_NOTIF_COUNT" -eq 0 ]; then
    note_pass "TC12 PASS: empty CLAUDE_SESSION_ID → pre-checkpoint-close-verifier RC=0, no false OBSERVATION_WRITTEN block"
  else
    note_fail "TC12 FAIL: RC=$VERIFIER_RC obs_notif=$OBS_NOTIF_COUNT (expected RC=0 and no false block)"
  fi
else
  note_fail "TC12 SKIP/FAIL: pre-checkpoint-close-verifier.sh not found or not readable at $CLOSE_VERIFIER"
fi

# === Summary ===
TOTAL=$((PASS+FAIL))
printf '\nobservation-orphan-detector-fire-test: %d/%d PASS\n' "$PASS" "$TOTAL"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do printf '  - %s\n' "$e"; done
  exit 1
fi
exit 0
