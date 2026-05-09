#!/usr/bin/env bash
# Firing-test for sync-tracker-update.sh (S102 backfill per Phase 3.5 T7 hard rule #2).
#
# Existing hook (created S17/Track 8a). Firing-test backfilled at S102 to capture:
#   1. Happy path with explicit override_delta (numeric).
#   2. Happy path with empty $3 (uses weight_<event_type> from weights.yaml).
#   3. M-S98-1 regression: long reason text in $3 OVERRIDE_DELTA → rc=2 (S101 deterministic guard).
#   4. M-S101-1 regression: decision_id in $3 OVERRIDE_DELTA → rc=2.
#   5. Invalid category → rc=2.
#   6. Missing required args → rc=2.
#   7. Negative override_delta (e.g. -0.5 for drift_signal) accepted by validation.
#   8. State.tsv recompute correctness: SCOPE +0.2 from weight_charter_match.
#
# Test strategy: stage temp PROJECT_DIR with minimal weights.yaml + empty events.tsv,
# invoke sync-tracker-update.sh from real ROOT_DIR (script computes ROOT_DIR via dirname,
# so we need to copy the script into temp tree OR override ROOT_DIR). We do the latter
# via setting the temp directory as the script's own location.
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../sync-tracker-update.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

# Stage temp tree mirroring sync-tracker layout. The script computes ROOT_DIR via
# `cd "$(dirname "$0")/../.." && pwd` — so we need to invoke it with a path that
# resolves correctly. We copy the script into TEMPDIR/scripts/hooks/ and run it from there.
TEMP_HOOKS_DIR="$TEMPDIR/scripts/hooks"
TEMP_SYNC_DIR="$TEMPDIR/agent-workspace/memory/sync-tracker"
mkdir -p "$TEMP_HOOKS_DIR" "$TEMP_SYNC_DIR"
cp "$HOOK" "$TEMP_HOOKS_DIR/sync-tracker-update.sh"

# Stub render script (no-op) so update doesn't fail on render call.
cat > "$TEMP_HOOKS_DIR/sync-tracker-render.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "$TEMP_HOOKS_DIR/sync-tracker-render.sh"

WEIGHTS="$TEMP_SYNC_DIR/weights.yaml"
EVENTS="$TEMP_SYNC_DIR/events.tsv"
STATE="$TEMP_SYNC_DIR/state.tsv"

stage_clean() {
  cat > "$WEIGHTS" <<'YAMLEOF'
category_LANGUAGE: 50
category_DOMAIN_UBIQUITOUS: 50
category_DESIGN_THINKING: 50
category_SCOPE: 50
category_DECISION_ROUTING: 50
weight_decision_correctness: 0.5
weight_charter_match: 0.2
weight_drift_signal: -0.3
tier_HIGH: 90
tier_MED_HIGH: 70
tier_MED: 50
tier_MED_LOW: 30
tier_MUST_GRILL: 0
YAMLEOF
  # Real events.tsv has a header row that the script's awk replay skips via NR==1.
  printf 'ts\tcategory\tevent_type\tdelta\tdecision_id\tsource_evidence\treason\n' > "$EVENTS"
  : > "$STATE"
}

run_hook() {
  bash "$TEMP_HOOKS_DIR/sync-tracker-update.sh" "$@" 2>&1
}

# --- TC1: happy path with explicit override_delta=0.5 numeric ---
stage_clean
OUT=$(run_hook SCOPE charter_match "0.5" "test-decision-id" "src.md" "test reason")
RC=$?
if [ "$RC" -ne 0 ]; then
  echo "FAIL TC1: expected rc=0 with valid numeric override; got rc=$RC"
  echo "$OUT"
  exit 1
fi
ROW=$(tail -1 "$EVENTS")
DELTA_COL=$(printf '%s' "$ROW" | awk -F'\t' '{print $4}')
if [ "$DELTA_COL" != "0.5" ]; then
  echo "FAIL TC1: expected delta column=0.5; got '$DELTA_COL'"
  exit 1
fi
echo "PASS TC1: explicit numeric override_delta=0.5 accepted"

# --- TC2: happy path with empty $3 → uses weight_charter_match=0.2 ---
stage_clean
run_hook SCOPE charter_match "" "test-id" "src.md" "reason" >/dev/null 2>&1
ROW=$(tail -1 "$EVENTS")
DELTA_COL=$(printf '%s' "$ROW" | awk -F'\t' '{print $4}')
if [ "$DELTA_COL" != "0.2" ]; then
  echo "FAIL TC2: expected delta=0.2 from weights.yaml; got '$DELTA_COL'"
  cat "$EVENTS"
  exit 1
fi
echo "PASS TC2: empty \$3 → weight_charter_match=0.2 used"

# --- TC3: M-S98-1 regression — long reason text in $3 → rc=2 ---
stage_clean
OUT=$(run_hook SCOPE charter_match "S98 sync-grilling refresher: long text reason" "test-id" "src.md" "")
RC=$?
if [ "$RC" -ne 2 ]; then
  echo "FAIL TC3 (M-S98-1 regression): expected rc=2 for non-numeric \$3; got rc=$RC"
  echo "$OUT"
  exit 1
fi
if ! printf '%s' "$OUT" | grep -q "M-S98-1"; then
  echo "FAIL TC3: error message should reference M-S98-1"
  echo "$OUT"
  exit 1
fi
echo "PASS TC3: M-S98-1 regression — long reason text in \$3 → rc=2 (deterministic guard)"

# --- TC4: M-S101-1 regression — decision_id in $3 → rc=2 ---
stage_clean
OUT=$(run_hook SCOPE charter_match "sync-grilling-S101" "actual-decision-id" "src.md" "reason")
RC=$?
if [ "$RC" -ne 2 ]; then
  echo "FAIL TC4 (M-S101-1 regression): expected rc=2 for decision_id in \$3; got rc=$RC"
  echo "$OUT"
  exit 1
fi
if ! printf '%s' "$OUT" | grep -q "M-S101-1"; then
  echo "FAIL TC4: error message should reference M-S101-1"
  echo "$OUT"
  exit 1
fi
echo "PASS TC4: M-S101-1 regression — decision_id in \$3 → rc=2 (deterministic guard)"

# --- TC5: invalid category → rc=2 ---
stage_clean
OUT=$(run_hook BAD_CATEGORY charter_match "" "id" "src.md" "reason")
RC=$?
if [ "$RC" -ne 2 ]; then
  echo "FAIL TC5: invalid category should rc=2; got rc=$RC"
  exit 1
fi
echo "PASS TC5: invalid category → rc=2"

# --- TC6: missing required args → rc=2 ---
OUT=$(bash "$TEMP_HOOKS_DIR/sync-tracker-update.sh" 2>&1)
RC=$?
if [ "$RC" -ne 2 ]; then
  echo "FAIL TC6: missing args should rc=2; got rc=$RC"
  echo "$OUT"
  exit 1
fi
echo "PASS TC6: missing required args → rc=2"

# --- TC7: negative override_delta (drift_signal) accepted ---
stage_clean
OUT=$(run_hook SCOPE drift_signal "-0.3" "drift-id" "src.md" "drift reason")
RC=$?
if [ "$RC" -ne 0 ]; then
  echo "FAIL TC7: negative override_delta=-0.3 should be accepted; got rc=$RC"
  echo "$OUT"
  exit 1
fi
ROW=$(tail -1 "$EVENTS")
DELTA_COL=$(printf '%s' "$ROW" | awk -F'\t' '{print $4}')
if [ "$DELTA_COL" != "-0.3" ]; then
  echo "FAIL TC7: expected delta=-0.3; got '$DELTA_COL'"
  exit 1
fi
echo "PASS TC7: negative override_delta=-0.3 accepted (numeric regex includes optional sign)"

# --- TC8: SCOPE +0.2 reflected in state.tsv after charter_match event ---
stage_clean
run_hook SCOPE charter_match "" "test-state-recompute" "src.md" "reason" >/dev/null 2>&1
SCOPE_SCORE=$(grep "^SCOPE" "$STATE" | awk -F'\t' '{print $2}')
SCOPE_SAMPLE=$(grep "^SCOPE" "$STATE" | awk -F'\t' '{print $3}')
# Initial score 50 + 0.2 charter_match = 50.2
if [ "$SCOPE_SCORE" != "50.2" ]; then
  echo "FAIL TC8: expected SCOPE score=50.2 (init 50 + 0.2); got '$SCOPE_SCORE'"
  cat "$STATE"
  exit 1
fi
if [ "$SCOPE_SAMPLE" != "1" ]; then
  echo "FAIL TC8: expected SCOPE sample=1; got '$SCOPE_SAMPLE'"
  exit 1
fi
echo "PASS TC8: state.tsv recompute correct (SCOPE 50→50.2 from weight_charter_match)"

echo "ALL PASS (8/8)"
exit 0
