#!/usr/bin/env bash
# Firing-test for learning-loop-metric-check.sh (L-S49b-4 charter-coverage push; S78).
#
# Hook purpose (Stop hook; L-S12-1 promotion target priority hook per Q-E3):
#   - Skip if LOOP_DIR (agent-workspace/learning-data/loop/) missing.
#   - Iterate *-experiment-frame.md files; parse first 30 lines for `^metric_function:`.
#   - Violation if line missing OR value empty / null / none / tbd / TBD / not-yet-authored.
#   - VIOLATIONS > 0: log "WARN N framing(s) without metric_function:" + write notif.
#   - VIOLATIONS == 0: log "OK (0 violations)".
#   - Always exit 0 (non-blocking).
#
# 5 test cases:
#   TC1 — no LOOP_DIR → silent exit 0; no log entry
#   TC2 — empty LOOP_DIR (no framing files) → log OK (0 violations)
#   TC3 — 1 framing with valid metric_function: scripts/foo.sh → log OK (0 violations)
#   TC4 — 1 framing with missing metric_function: → log WARN 1 framing(s) + notif written
#   TC5 — 1 framing with placeholder metric_function: tbd → log WARN 1 framing(s) + notif written
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../learning-loop-metric-check.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOOP_DIR="$TEMPDIR/agent-workspace/learning-data/loop"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$NOTIF_DIR"
}

# --- TC1: no LOOP_DIR → silent exit 0; no log entry ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ] && grep -q "learning-loop-metric-check" "$LOG"; then
  echo "FAIL TC1: log should not contain entry when LOOP_DIR missing"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no LOOP_DIR → silent exit 0"

# --- TC2: empty LOOP_DIR → log OK (0 violations) ---
clean_state
mkdir -p "$LOOP_DIR"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "learning-loop-metric-check OK (0 violations)" "$LOG"; then
  echo "FAIL TC2: log should record OK (0 violations) for empty LOOP_DIR"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC2: empty LOOP_DIR → log OK (0 violations)"

# --- TC3: framing with valid metric_function → log OK (0 violations) ---
clean_state
mkdir -p "$LOOP_DIR"
cat > "$LOOP_DIR/2026-05-06-experiment-frame.md" <<'EOF'
---
experiment_id: e1
hypothesis: "approach X reduces failure mode rate"
metric_function: scripts/hooks/metric-failure-mode-rate.sh
expected_outcome: "failure-mode-rate < baseline"
---

# Experiment frame
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "learning-loop-metric-check OK (0 violations)" "$LOG"; then
  echo "FAIL TC3: log should record OK (0 violations) for valid metric_function"
  cat "$LOG"
  exit 1
fi
if grep -q "learning-loop-metric-check WARN" "$LOG"; then
  echo "FAIL TC3: log should NOT WARN for valid metric_function"
  cat "$LOG"
  exit 1
fi
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name '*-loop-metric-check-warn.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -ne 0 ]; then
  echo "FAIL TC3: notif should NOT be written when 0 violations"
  ls -la "$NOTIF_DIR"
  exit 1
fi
echo "PASS TC3: valid metric_function → log OK (0 violations)"

# --- TC4: framing missing metric_function → log WARN 1 + notif ---
clean_state
mkdir -p "$LOOP_DIR"
cat > "$LOOP_DIR/2026-05-06-bad-experiment-frame.md" <<'EOF'
---
experiment_id: e2
hypothesis: "another approach Y"
expected_outcome: "improvement"
---

# Experiment frame missing metric_function
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "learning-loop-metric-check WARN 1 framing" "$LOG"; then
  echo "FAIL TC4: log should WARN 1 framing(s) without metric_function"
  cat "$LOG"
  exit 1
fi
if ! grep -q "2026-05-06-bad-experiment-frame.md" "$LOG"; then
  echo "FAIL TC4: log should list the offending framing basename"
  cat "$LOG"
  exit 1
fi
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name '*-loop-metric-check-warn.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -lt 1 ]; then
  echo "FAIL TC4: notif file should be written when violations > 0"
  ls -la "$NOTIF_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC4: missing metric_function → WARN 1 + notif"

# --- TC5: framing with placeholder "tbd" → log WARN 1 + notif ---
clean_state
mkdir -p "$LOOP_DIR"
cat > "$LOOP_DIR/2026-05-06-placeholder-experiment-frame.md" <<'EOF'
---
experiment_id: e3
hypothesis: "approach Z"
metric_function: tbd
expected_outcome: "tbd"
---

# Experiment frame with placeholder
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "learning-loop-metric-check WARN 1 framing" "$LOG"; then
  echo "FAIL TC5: log should WARN 1 framing(s) for placeholder 'tbd'"
  cat "$LOG"
  exit 1
fi
if ! grep -q "missing or placeholder metric_function" "$LOG"; then
  echo "FAIL TC5: log should mention 'missing or placeholder' detail"
  cat "$LOG"
  exit 1
fi
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name '*-loop-metric-check-warn.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -lt 1 ]; then
  echo "FAIL TC5: notif file should be written for placeholder violation"
  ls -la "$NOTIF_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC5: placeholder 'tbd' → WARN 1 + notif"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "learning-loop-metric-check.sh externally-observable behavior verified."
exit 0
