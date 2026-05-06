#!/usr/bin/env bash
# Firing-test for drift-rollup-daily.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (KI-S43b harness recovery; Stop hook low priority):
# promote raw .drift-signals.log entries into dated rollup at
# drift-logs/YYYY-MM-DD-rollup.md. Idempotent: regenerates today's rollup
# only when raw log mtime > rollup mtime.
#
# Test strategy: stage temp PROJECT_DIR with various .drift-signals.log
# fixtures; invoke hook; assert rollup file existence + content sections.
#
# 6 test cases:
#   TC1 — raw log absent → "raw log absent; skip" + no rollup file
#   TC2 — raw log exists, no rollup yet → rollup written with summary
#   TC3 — rollup current (raw mtime <= rollup mtime) → "rollup current; skip"
#   TC4 — multiple severity levels → HIGH/MEDIUM/LOW counts in summary
#   TC5 — file= references → "Files referenced" section populated
#   TC6 — HIGH entries → "Last 10 HIGH-severity entries" code block populated
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../drift-rollup-daily.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

RAW_LOG="$TEMPDIR/agent-workspace/memory/.drift-signals.log"
ROLLUP_DIR="$TEMPDIR/agent-workspace/memory/drift-logs"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
TODAY="$(date +%Y-%m-%d)"
ROLLUP_FILE="$ROLLUP_DIR/$TODAY-rollup.md"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: raw log absent → skip ---
clean_state
run_hook
if [ -f "$ROLLUP_FILE" ]; then
  echo "FAIL TC1: rollup should NOT be written when raw log absent"
  exit 1
fi
if ! grep -q "raw log absent" "$HOOK_LOG"; then
  echo "FAIL TC1: expected 'raw log absent' message in hook log"
  cat "$HOOK_LOG" 2>/dev/null || echo "(no hook log)"
  exit 1
fi
echo "PASS TC1: raw log absent → no rollup + skip message"

# --- TC2: raw log exists, no rollup yet → write rollup ---
clean_state
cat > "$RAW_LOG" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=MEDIUM file=foo.md lines=180 ceiling=150
[${TODAY}T11:00:00+00:00] D5-MISSING-CITATION severity=HIGH file=bar.md
EOF
run_hook
if [ ! -f "$ROLLUP_FILE" ]; then
  echo "FAIL TC2: rollup should be written"
  exit 1
fi
if ! grep -q "# Drift Rollup" "$ROLLUP_FILE"; then
  echo "FAIL TC2: expected '# Drift Rollup' header"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "Total signals today.*: 2" "$ROLLUP_FILE"; then
  echo "FAIL TC2: expected total=2"
  cat "$ROLLUP_FILE"
  exit 1
fi
echo "PASS TC2: raw log → rollup written with summary"

# --- TC3: rollup current (raw mtime <= rollup) → skip ---
clean_state
cat > "$RAW_LOG" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=MEDIUM file=foo.md
EOF
mkdir -p "$ROLLUP_DIR"
echo "# stale rollup placeholder" > "$ROLLUP_FILE"
# Make rollup newer than raw log
touch "$ROLLUP_FILE"
sleep 1
# Make raw log OLDER than rollup
touch -t 200001010000.00 "$RAW_LOG" 2>/dev/null || touch -d "2000-01-01" "$RAW_LOG" 2>/dev/null || true
run_hook
if ! grep -q "rollup current" "$HOOK_LOG"; then
  echo "FAIL TC3: expected 'rollup current; skip' message"
  cat "$HOOK_LOG"
  exit 1
fi
# Rollup file content should be UNCHANGED (still placeholder)
if ! grep -q "stale rollup placeholder" "$ROLLUP_FILE"; then
  echo "FAIL TC3: rollup should NOT have been regenerated"
  cat "$ROLLUP_FILE"
  exit 1
fi
echo "PASS TC3: rollup current (raw mtime ≤ rollup) → skip"

# --- TC4: multiple severity levels → counts in summary ---
clean_state
cat > "$RAW_LOG" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=HIGH file=a.md
[${TODAY}T10:01:00+00:00] D1-LOC-CEILING severity=HIGH file=b.md
[${TODAY}T10:02:00+00:00] D2-SELF-ATTEST severity=MEDIUM file=c.md
[${TODAY}T10:03:00+00:00] D4-SPEC-DANGLING-REF severity=LOW file=d.md
EOF
run_hook
if ! grep -q "HIGH.*: 2" "$ROLLUP_FILE"; then
  echo "FAIL TC4: expected HIGH count=2"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "MEDIUM.*: 1" "$ROLLUP_FILE"; then
  echo "FAIL TC4: expected MEDIUM count=1"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "LOW.*: 1" "$ROLLUP_FILE"; then
  echo "FAIL TC4: expected LOW count=1"
  cat "$ROLLUP_FILE"
  exit 1
fi
echo "PASS TC4: severity counts populated correctly"

# --- TC5: file= references → "Files referenced" section ---
clean_state
cat > "$RAW_LOG" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=HIGH file=alpha.md lines=300
[${TODAY}T10:01:00+00:00] D5-MISSING-CITATION severity=HIGH file=beta.md
[${TODAY}T10:02:00+00:00] D7-NO-BEAR-CASE severity=MEDIUM file=alpha.md
EOF
run_hook
if ! grep -q "Files referenced" "$ROLLUP_FILE"; then
  echo "FAIL TC5: expected 'Files referenced' section header"
  cat "$ROLLUP_FILE"
  exit 1
fi
# Distinct files: alpha.md + beta.md (sort -u)
if ! grep -q "alpha.md" "$ROLLUP_FILE"; then
  echo "FAIL TC5: expected alpha.md in Files referenced"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "beta.md" "$ROLLUP_FILE"; then
  echo "FAIL TC5: expected beta.md in Files referenced"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "Distinct files referenced.*: 2" "$ROLLUP_FILE"; then
  echo "FAIL TC5: expected distinct file count=2"
  cat "$ROLLUP_FILE"
  exit 1
fi
echo "PASS TC5: distinct files populated in 'Files referenced'"

# --- TC6: HIGH entries → Last 10 HIGH section ---
clean_state
cat > "$RAW_LOG" <<EOF
[${TODAY}T10:00:00+00:00] D1-LOC-CEILING severity=HIGH file=h1.md
[${TODAY}T10:01:00+00:00] D5-MISSING-CITATION severity=HIGH file=h2.md
[${TODAY}T10:02:00+00:00] D2-SELF-ATTEST severity=MEDIUM file=m1.md
EOF
run_hook
if ! grep -q "Last 10 HIGH-severity entries" "$ROLLUP_FILE"; then
  echo "FAIL TC6: expected 'Last 10 HIGH-severity entries' section"
  cat "$ROLLUP_FILE"
  exit 1
fi
# HIGH entries should appear in code fence, not "(none — clean day...)"
if grep -q "clean day at HIGH severity" "$ROLLUP_FILE"; then
  echo "FAIL TC6: should NOT show 'clean day' when HIGH entries exist"
  cat "$ROLLUP_FILE"
  exit 1
fi
if ! grep -q "h1.md" "$ROLLUP_FILE"; then
  echo "FAIL TC6: expected h1.md in HIGH entries section"
  cat "$ROLLUP_FILE"
  exit 1
fi
echo "PASS TC6: HIGH entries → Last 10 section populated"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "drift-rollup-daily.sh externally-observable behavior verified."
exit 0
