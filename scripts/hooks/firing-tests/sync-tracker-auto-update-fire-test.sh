#!/usr/bin/env bash
# Firing-test for sync-tracker-auto-update.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (HH-B.5; Stop hook): detect sync-tracker-relevant events
# from session-end state and fire sync-tracker-update.sh with deltas.
# Events: (1) ADR mtime <6h → SCOPE charter_match (capped at 3),
# (2) HIGH-severity drift today → DECISION_ROUTING drift_signal,
# (3) Q&A in answered/ <6h → DECISION_ROUTING q_and_a_resolution.
# Idempotent per session via marker file.
#
# Test strategy: stage temp PROJECT_DIR with stub sync-tracker-update.sh
# that records its arguments; invoke hook; assert marker + log + stub call args.
#
# 6 test cases:
#   TC1 — sync-tracker-update.sh missing → silent no-op (no marker)
#   TC2 — marker already exists → exit 0 idempotent (no fire)
#   TC3 — new ADR mtime <6h → SCOPE charter_match fired
#   TC4 — HIGH drift today in .drift-signals.log → DECISION_ROUTING drift_signal fired
#   TC5 — Q&A in answered/ <6h → DECISION_ROUTING q_and_a_resolution fired
#   TC6 — marker created idempotently after firing (2nd invocation no-op)
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

marker_path() {
  echo "$TEMPDIR/agent-workspace/memory/.sync-tracker-fired-$1"
}

# --- TC1: sync-tracker-update.sh missing → silent no-op ---
clean_state
rm -f "$STUB"
run_hook "tc1"
if [ -f "$(marker_path tc1)" ]; then
  echo "FAIL TC1: marker should NOT be created when stub missing"
  exit 1
fi
echo "PASS TC1: sync-tracker-update.sh missing → silent no-op"

# --- TC2: marker already exists → exit 0 idempotent (no fire) ---
clean_state
stage_stub
touch "$(marker_path tc2)"
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR" > "$TEMPDIR/agent-workspace/memory/decisions/D-099-test.md"
run_hook "tc2"
if [ -s "$STUB_CALLS" ]; then
  echo "FAIL TC2: stub should NOT be called when marker exists"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC2: marker exists → idempotent no-op"

# --- TC3: new ADR mtime <6h → SCOPE charter_match fired ---
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR D-099 test" > "$TEMPDIR/agent-workspace/memory/decisions/D-099-test.md"
run_hook "tc3"
if [ ! -s "$STUB_CALLS" ]; then
  echo "FAIL TC3: stub should be called for new ADR"
  exit 1
fi
if ! grep -q "SCOPE charter_match" "$STUB_CALLS"; then
  echo "FAIL TC3: expected 'SCOPE charter_match' invocation"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC3: new ADR <6h → SCOPE charter_match fired"

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
clean_state
stage_stub
mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
echo "# ADR" > "$TEMPDIR/agent-workspace/memory/decisions/D-100-test.md"
run_hook "tc6"
if [ ! -f "$(marker_path tc6)" ]; then
  echo "FAIL TC6: marker should exist after firing"
  exit 1
fi
CALLS_1=$(wc -l < "$STUB_CALLS")
# 2nd invocation with same SID — marker exists → no-op
run_hook "tc6"
CALLS_2=$(wc -l < "$STUB_CALLS")
if [ "$CALLS_1" != "$CALLS_2" ]; then
  echo "FAIL TC6: 2nd invocation should NOT call stub again (1=$CALLS_1 2=$CALLS_2)"
  cat "$STUB_CALLS"
  exit 1
fi
echo "PASS TC6: marker created + 2nd invocation idempotent"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "sync-tracker-auto-update.sh externally-observable behavior verified."
exit 0
