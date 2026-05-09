#!/usr/bin/env bash
# Firing-test for sync-tracker-auto-update.sh (Phase 3.5 T7 retrofit; S62; S109 TC7 stale-marker
# regression; S179 D-039 fixture rewrite REAL-STATE-DERIVED per L-S176-1).
#
# Hook purpose (HH-B.5; Stop hook): detect sync-tracker-relevant events
# from session-end state and fire sync-tracker-update.sh with deltas.
# Events: (1) ADR mtime <6h → SCOPE charter_match (capped at 3),
# (2) HIGH-severity drift today → DECISION_ROUTING drift_signal,
# (3) Q&A in answered/ <6h → DECISION_ROUTING q_and_a_resolution.
# Idempotent per HOUR-BUCKET via marker file (L-S108-1; was per-session but
# $CLAUDE_SESSION_ID empty on Windows → fallback-to-constant lockout).
#
# Test strategy: stage temp PROJECT_DIR with stub sync-tracker-update.sh
# that records its arguments; invoke hook; assert marker + log + stub call args.
#
# 8 test cases (D-039 fixture rewrite per L-S176-1 — REAL-STATE-DERIVED + backward-compat coverage):
#   TC1 — sync-tracker-update.sh missing → silent no-op (no marker)
#   TC2 — marker already exists (current bucket) → exit 0 idempotent (no fire)
#   TC3 — D-039 PRIMARY: new ADR mtime <6h NNN-*.md naming (real-state) → SCOPE charter_match fired
#   TC3b — D-039 BACKWARD-COMPAT: new ADR D-*.md naming (legacy) → SCOPE charter_match fired
#   TC4 — HIGH drift today in .drift-signals.log → DECISION_ROUTING drift_signal fired
#   TC5 — Q&A in answered/ <6h → DECISION_ROUTING q_and_a_resolution fired
#   TC6 — marker created idempotently after firing (2nd invocation no-op); uses NNN-*.md primary
#   TC7 — L-S108-1 REGRESSION: stale cross-bucket + legacy "default" marker
#         present → cleanup deletes both, ADR fire happens; uses NNN-*.md primary
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../sync-tracker-auto-update.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

# Stage stub sync-tracker-update.sh that records its arguments
SYNC_DIR="$TEMPDIR/scripts/hooks"
mkdir -p "$SYNC_DIR"
STUB="$SYNC_DIR/sync-tracker-update.sh"
STUB_CALLS="$TEMPDIR/agent-workspace/memory/.stub-calls.log"
mkdir -p "$(dirname "$STUB_CALLS")"

stage_stub() {
  cat > "$STUB" <<'STUBEOF'
#!/usr/bin/env bash
# Stub: record args to STUB_CALLS log
mkdir -p "$(dirname "${STUB_CALLS:-/tmp/stub-calls.log}")"
echo "CALLED: $*" >> "${STUB_CALLS:-/tmp/stub-calls.log}"
exit 0
STUBEOF
  chmod +x "$STUB"
}

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  local sid="${1:-tc-session}"
  STUB_CALLS="$STUB_CALLS" CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory" "$TEMPDIR/human-workspace/q-and-a"
  : > "$STUB_CALLS"
}

current_marker() {
  # Hour-bucket marker per L-S108-1 (matches hook's date +%Y%m%d-%H)
  echo "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-$(date +%Y%m%d-%H)"
}

# --- TC1: sync-tracker-update.sh missing → silent no-op ---
clean_state
rm -f "$STUB"
run_hook "tc1"
if [ -f "$(current_marker)" ]; then
  echo "FAIL TC1: marker should NOT be created when stub missing"
  exit 1
fi
echo "PASS TC1: sync-tracker-update.sh missing → silent no-op"

# --- TC2: marker already exists (current bucket) → exit 0 idempotent (no fire) ---
# REAL-STATE-DERIVED fixture: NNN-*.md naming (per D-039 / L-S176-1).
clean_state
stage_stub
touch "$(current_marker)"
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR" > "$TEMPDIR/agent-workspace/memory/decisions/099-test-adr.md"
run_hook "tc2"
if [ -s "$STUB_CALLS" ]; then
  echo "FAIL TC2: stub should NOT be called when current-bucket marker exists"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC2: current-bucket marker exists → idempotent no-op"

# --- TC3 (D-039 PRIMARY REAL-STATE): NEW ADR NNN-*.md mtime <6h → SCOPE charter_match fired ---
# Pre-D-039 hook glob `-name 'D-*.md'` would match 0 here → hook silently no-ops on real state.
# Post-D-039 dual-glob `\( NNN-*.md -o D-*.md \)` matches → fires correctly.
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR 099 test" > "$TEMPDIR/agent-workspace/memory/decisions/099-test-adr.md"
run_hook "tc3"
if [ ! -s "$STUB_CALLS" ]; then
  echo "FAIL TC3 (D-039 PRIMARY): stub should be called for new NNN-*.md ADR"
  exit 1
fi
if ! grep -q "SCOPE charter_match" "$STUB_CALLS"; then
  echo "FAIL TC3 (D-039 PRIMARY): expected 'SCOPE charter_match' invocation"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC3 (D-039 PRIMARY): new NNN-*.md ADR <6h → SCOPE charter_match fired"

# --- TC3b (D-039 BACKWARD-COMPAT): NEW ADR D-*.md mtime <6h → SCOPE charter_match fired ---
# Verifies dual-glob preserves legacy D-*.md naming detection (defensive backward-compat).
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR D-099 legacy" > "$TEMPDIR/agent-workspace/memory/decisions/D-099-legacy.md"
run_hook "tc3b"
if [ ! -s "$STUB_CALLS" ]; then
  echo "FAIL TC3b (D-039 BACKWARD-COMPAT): stub should be called for D-*.md ADR"
  exit 1
fi
if ! grep -q "SCOPE charter_match" "$STUB_CALLS"; then
  echo "FAIL TC3b (D-039 BACKWARD-COMPAT): expected 'SCOPE charter_match' invocation"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC3b (D-039 BACKWARD-COMPAT): D-*.md ADR <6h → SCOPE charter_match fired"

# --- TC4: HIGH drift today → DECISION_ROUTING drift_signal fired ---
clean_state
stage_stub
TODAY="$(date -u +%Y-%m-%d)"
cat > "$TEMPDIR/agent-workspace/memory/.drift-signals.log" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=HIGH file=foo.md
[${TODAY}T10:01:00+00:00] D5-MISSING-CITATION severity=HIGH file=bar.md
EOF
run_hook "tc4"
if ! grep -q "DECISION_ROUTING drift_signal" "$STUB_CALLS"; then
  echo "FAIL TC4: expected 'DECISION_ROUTING drift_signal' invocation"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC4: HIGH drift today → DECISION_ROUTING drift_signal fired"

# --- TC5: Q&A in answered/ <6h → DECISION_ROUTING q_and_a_resolution ---
clean_state
stage_stub
mkdir -p "$TEMPDIR/human-workspace/q-and-a/answered"
echo "# answered bundle" > "$TEMPDIR/human-workspace/q-and-a/answered/2026-05-05-bundle.md"
run_hook "tc5"
if ! grep -q "DECISION_ROUTING q_and_a_resolution" "$STUB_CALLS"; then
  echo "FAIL TC5: expected 'DECISION_ROUTING q_and_a_resolution' invocation"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC5: Q&A answered <6h → q_and_a_resolution fired"

# --- TC6: marker created after firing; 2nd invocation idempotent ---
# REAL-STATE-DERIVED: NNN-*.md naming (per D-039).
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR 100" > "$TEMPDIR/agent-workspace/memory/decisions/100-test-adr.md"
run_hook "tc6"
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC6: current-bucket marker should exist after firing"
  exit 1
fi
CALLS_1=$(wc -l < "$STUB_CALLS")
# 2nd invocation with same hour-bucket — marker exists → no-op
run_hook "tc6"
CALLS_2=$(wc -l < "$STUB_CALLS")
if [ "$CALLS_1" != "$CALLS_2" ]; then
  echo "FAIL TC6: 2nd invocation should NOT call stub again (1=$CALLS_1 2=$CALLS_2)"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC6: marker created + 2nd invocation idempotent"

# --- TC7: L-S108-1 REGRESSION — stale cross-bucket + legacy 'default' marker ---
# Reproduces M-S108-1 sister-bug: hook stuck because .sync-tracker-fired-default
# (legacy CLAUDE_SESSION_ID:-default fallback marker) blocked all subsequent sessions.
# Fix asserts cleanup loop deletes BOTH stale-bucket and legacy markers + work happens.
# REAL-STATE-DERIVED: NNN-*.md naming (per D-039).
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR 101" > "$TEMPDIR/agent-workspace/memory/decisions/101-test-adr.md"
# Plant stale Jan-2026 hour-bucket marker (different bucket from current)
touch "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-20260105-13"
# Plant LEGACY fallback marker (the EXACT M-S108-1 sister-bug filename observed on disk)
touch "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-default"
run_hook "tc7"
if ! grep -q "SCOPE charter_match" "$STUB_CALLS" 2>/dev/null; then
  echo "FAIL TC7 (REGRESSION): stub should have been called for new ADR; stale-marker lockout NOT prevented"
  ls -la "$TEMPDIR/agent-workspace/memory/" 2>&1
  cat "$STUB_CALLS" 2>&1
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-20260105-13" ]; then
  echo "FAIL TC7: stale Jan-2026 marker should have been cleaned up"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-default" ]; then
  echo "FAIL TC7: legacy 'default' fallback marker should have been cleaned up"
  exit 1
fi
if [ ! -f "$(current_marker)" ]; then
  echo "FAIL TC7: current-bucket marker should be created post-fire"
  exit 1
fi
echo "PASS TC7: L-S108-1 REGRESSION — stale markers cleaned + ADR fire happened"

echo ""
echo "=== ALL FIRING-TESTS PASSED (8/8) ==="
echo "sync-tracker-auto-update.sh externally-observable behavior verified."
echo "L-S108-1 stale-marker regression COVERED (TC7)."
echo "D-039 dual-glob (NNN-*.md primary + D-*.md backward-compat) COVERED (TC3 + TC3b)."
exit 0
