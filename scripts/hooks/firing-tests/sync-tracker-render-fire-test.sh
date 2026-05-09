#!/usr/bin/env bash
# Firing-test for sync-tracker-render.sh (Phase 3.5 T7 retrofit; S63).
#
# Hook purpose (D-006 IMPL-S17-1; render hook): read state.tsv + events.tsv +
# weights.yaml; render _index.md (Confidence Score Index — sync-tracker).
# Map score → tier display string (HIGH-CONFIDENCE / MED-HIGH / MED / MED-LOW
# / MUST-GRILL). Render decision-class thresholds (CHARTER/SCOPE/ARCH/IMPL).
# Render top-10 most recent events from events.tsv. Atomic write (tmp + mv);
# idempotent.
#
# Test strategy: hook computes ROOT_DIR via $(dirname $0)/../.. so we copy
# hook to TEMPDIR/scripts/hooks/ (ROOT_DIR resolves to TEMPDIR), stage
# state/events/weights fixtures, invoke hook, verify _index.md content.
#
# Per L-S62-1: avoid `yes | head` under pipefail; use `seq | printf` for
# deterministic line counts.
#
# 6 test cases:
#   TC1 — score=95 → tier "HIGH-CONFIDENCE"
#   TC2 — score=20 → tier "MUST-GRILL"
#   TC3 — 5 categories at 5 different tiers → all 5 rows + correct tier text
#   TC4 — events.tsv with 12 entries → top-10 only in output
#   TC5 — thresholds rendered from weights.yaml (CHARTER 99 / SCOPE 90 / IMPL 50)
#   TC6 — idempotent: 2nd run produces same _index.md modulo RENDER_TS line
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../sync-tracker-render.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

# Copy hook to TEMPDIR/scripts/hooks/ so $(dirname $0)/../.. resolves to TEMPDIR
HOOK_DIR="$TEMPDIR/scripts/hooks"
mkdir -p "$HOOK_DIR"
cp "$HOOK" "$HOOK_DIR/sync-tracker-render.sh"
chmod +x "$HOOK_DIR/sync-tracker-render.sh"
HOOK_COPY="$HOOK_DIR/sync-tracker-render.sh"

SYNC_DIR="$TEMPDIR/agent-workspace/memory/sync-tracker"
INDEX="$SYNC_DIR/_index.md"

stage_weights() {
  mkdir -p "$SYNC_DIR"
  cat > "$SYNC_DIR/weights.yaml" <<'EOF'
# test fixture
threshold_CHARTER: 99
threshold_SCOPE: 90
threshold_ARCH: 80
threshold_IMPL: 50
tier_HIGH: 90
tier_MED_HIGH: 70
tier_MED: 50
tier_MED_LOW: 30
tier_MUST_GRILL: 0
EOF
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  stage_weights
}

run_hook() {
  bash "$HOOK_COPY" </dev/null >/dev/null 2>&1
}

# --- TC1: score=95 → HIGH-CONFIDENCE tier ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
LANGUAGE	95	10	2026-05-05T10:00:00Z	0
EOF
cat > "$SYNC_DIR/events.tsv" <<'EOF'
ts	category	event_type	delta	decision_id	source_evidence	reason
2026-05-05T10:00:00Z	LANGUAGE	decision_correctness	0.5	D-001	src-1	r1
EOF
run_hook
if [ ! -f "$INDEX" ]; then
  echo "FAIL TC1: $INDEX not produced"
  exit 1
fi
if ! grep -q "HIGH-CONFIDENCE" "$INDEX"; then
  echo "FAIL TC1: expected 'HIGH-CONFIDENCE' for score=95"
  cat "$INDEX"
  exit 1
fi
echo "PASS TC1: score=95 → HIGH-CONFIDENCE"

# --- TC2: score=20 → MUST-GRILL tier ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
SCOPE	20	5	2026-05-05T10:00:00Z	3
EOF
cat > "$SYNC_DIR/events.tsv" <<'EOF'
ts	category	event_type	delta	decision_id	source_evidence	reason
EOF
run_hook
if ! grep -q "MUST-GRILL" "$INDEX"; then
  echo "FAIL TC2: expected 'MUST-GRILL' for score=20"
  cat "$INDEX"
  exit 1
fi
echo "PASS TC2: score=20 → MUST-GRILL"

# --- TC3: 5 categories at 5 different tier levels ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
LANGUAGE	95	10	2026-05-05T10:00:00Z	0
DOMAIN_UBIQUITOUS	75	10	2026-05-05T10:00:00Z	0
DESIGN_THINKING	55	10	2026-05-05T10:00:00Z	0
SCOPE	35	10	2026-05-05T10:00:00Z	2
DECISION_ROUTING	15	10	2026-05-05T10:00:00Z	5
EOF
cat > "$SYNC_DIR/events.tsv" <<'EOF'
ts	category	event_type	delta	decision_id	source_evidence	reason
EOF
run_hook
# Each tier should appear once via distinct score-range markers
for tier_marker in "HIGH-CONFIDENCE" "MED-HIGH" "0.50-0.69" "MED-LOW" "MUST-GRILL"; do
  if ! grep -qF "$tier_marker" "$INDEX"; then
    echo "FAIL TC3: expected tier marker '$tier_marker' in output"
    cat "$INDEX"
    exit 1
  fi
done
# All 5 categories should appear as table rows
for cat_name in LANGUAGE DOMAIN_UBIQUITOUS DESIGN_THINKING SCOPE DECISION_ROUTING; do
  if ! grep -qF "| $cat_name |" "$INDEX"; then
    echo "FAIL TC3: expected category $cat_name row"
    cat "$INDEX"
    exit 1
  fi
done
echo "PASS TC3: 5 categories at 5 tier levels rendered"

# --- TC4: events.tsv with 12 entries → top-10 only ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
LANGUAGE	50	5	2026-05-05T10:00:00Z	0
EOF
{
  printf "ts\tcategory\tevent_type\tdelta\tdecision_id\tsource_evidence\treason\n"
  # Generate 12 events deterministically (per L-S62-1: no `yes|head`; seq+printf instead)
  for i in $(seq 1 12); do
    printf "2026-05-05T10:%02d:00Z\tLANGUAGE\tdecision_correctness\t0.5\tD-%03d\tsrc-%d\tevent-%02d\n" "$i" "$i" "$i" "$i"
  done
} > "$SYNC_DIR/events.tsv"
run_hook
EVENT_COUNT=$(grep -c "^| 2026-05-05T10:" "$INDEX" || true)
if [ "$EVENT_COUNT" != "10" ]; then
  echo "FAIL TC4: expected 10 event rows (top-10); got $EVENT_COUNT"
  grep "^| 2026-05-05T10:" "$INDEX" || true
  exit 1
fi
# events 03-12 should appear (last 10 from tail -n 10), events 01-02 should NOT
if grep -q "event-01" "$INDEX"; then
  echo "FAIL TC4: oldest event-01 should be tail-cut"
  cat "$INDEX"
  exit 1
fi
if ! grep -q "event-12" "$INDEX"; then
  echo "FAIL TC4: newest event-12 should be present"
  exit 1
fi
echo "PASS TC4: 12 events → top-10 rendered (oldest 2 cut)"

# --- TC5: thresholds rendered from weights.yaml ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
LANGUAGE	50	5	2026-05-05T10:00:00Z	0
EOF
cat > "$SYNC_DIR/events.tsv" <<'EOF'
ts	category	event_type	delta	decision_id	source_evidence	reason
EOF
run_hook
if ! grep -qF "| CHARTER | 99 |" "$INDEX"; then
  echo "FAIL TC5: expected '| CHARTER | 99 |' threshold row"
  grep "CHARTER" "$INDEX" || true
  exit 1
fi
if ! grep -qF "| SCOPE | 90 |" "$INDEX"; then
  echo "FAIL TC5: expected '| SCOPE | 90 |' threshold row"
  exit 1
fi
if ! grep -qF "| ARCH | 80 |" "$INDEX"; then
  echo "FAIL TC5: expected '| ARCH | 80 |' threshold row"
  exit 1
fi
if ! grep -qF "| IMPL | 50 |" "$INDEX"; then
  echo "FAIL TC5: expected '| IMPL | 50 |' threshold row"
  exit 1
fi
echo "PASS TC5: thresholds rendered from weights.yaml"

# --- TC6: idempotent — 2nd run produces same _index.md modulo RENDER_TS ---
clean_state
cat > "$SYNC_DIR/state.tsv" <<'EOF'
category	current_score	sample_count	last_updated_ts	must_grill_remaining
LANGUAGE	95	10	2026-05-05T10:00:00Z	0
EOF
cat > "$SYNC_DIR/events.tsv" <<'EOF'
ts	category	event_type	delta	decision_id	source_evidence	reason
EOF
run_hook
cp "$INDEX" "$TEMPDIR/.run1.md"
run_hook
# Filter out the variable RENDER_TS line ("> **Last rendered**: ...")
grep -v "Last rendered" "$TEMPDIR/.run1.md" > "$TEMPDIR/.run1.filt"
grep -v "Last rendered" "$INDEX"           > "$TEMPDIR/.run2.filt"
if ! diff -q "$TEMPDIR/.run1.filt" "$TEMPDIR/.run2.filt" >/dev/null 2>&1; then
  echo "FAIL TC6: idempotency violated outside RENDER_TS line"
  diff "$TEMPDIR/.run1.filt" "$TEMPDIR/.run2.filt" || true
  exit 1
fi
if ! grep -q "Confidence Score Index" "$INDEX"; then
  echo "FAIL TC6: 2nd run output missing header"
  exit 1
fi
echo "PASS TC6: idempotent — 2nd run identical modulo RENDER_TS"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "sync-tracker-render.sh externally-observable behavior verified."
exit 0
