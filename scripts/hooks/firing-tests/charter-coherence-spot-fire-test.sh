#!/usr/bin/env bash
# Firing-test for charter-coherence-spot.sh (Phase 3.5 T7 retrofit; S60).
#
# Hook purpose (D-002 Track 5 REV-2): grep recent thesis-log/observations/specs
# for charter-incoherent language (advice without research-aid framing,
# LLM-self-claim-of-computation, insider-info signals).
#
# Test strategy: stage temp PROJECT_DIR with various .md files in the audit
# scope; invoke hook; assert .charter-coherence-violations.log content +
# .session-hooks.log WARN line.
#
# 6 test cases:
#   TC1 — no recent (<120min) files → silent
#   TC2 — file without violations → silent
#   TC3 — "buy this stock" without aid framing → I-S35-VIOLATION
#   TC4 — "buy this stock" + "thesis exploration" → no violation (framing present)
#   TC5 — "my analysis estimates 18%" → I-S1-VIOLATION
#   TC6 — "insider info from broker" → CHARTER-VIOLATION (insider-info)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../charter-coherence-spot.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.charter-coherence-violations.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null >/dev/null 2>/dev/null || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory/thesis-log"
  mkdir -p "$TEMPDIR/agent-workspace/memory/observations"
  mkdir -p "$TEMPDIR/specs"
}

# Helper — was this TC's tag logged as a violation? (each TC stages a unique file path)
violation_logged() {
  local tag="$1"
  [ -f "$LOG" ] && grep -q "$tag" "$LOG"
}

# --- TC1: no recent (<120min) files → silent ---
clean_state
echo "buy this stock now" > "$TEMPDIR/agent-workspace/memory/thesis-log/old-thesis.md"
# Force mtime old (>120 minutes ago).
touch -d "3 hours ago" "$TEMPDIR/agent-workspace/memory/thesis-log/old-thesis.md"
run_hook
if [ -f "$LOG" ] && [ -s "$LOG" ]; then
  echo "FAIL TC1: log should be empty (no recent files); found:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no recent files → silent"

# --- TC2: file without violations → silent ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/tc2-thesis.md" <<'EOF'
# Thesis exploration: VNM
This is a thesis exploration; the goal is research aid, not financial advice.
Numerical claims must come from code with citations.
EOF
run_hook
if violation_logged "tc2-thesis"; then
  echo "FAIL TC2: clean file should not be logged; got:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: clean file → silent"

# --- TC3: advice phrasing without aid framing → I-S35-VIOLATION ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/tc3-bad-advice.md" <<'EOF'
# Stock recommendation
You should buy this stock — guaranteed return next quarter.
EOF
run_hook
if ! violation_logged "tc3-bad-advice"; then
  echo "FAIL TC3: expected I-S35-VIOLATION for tc3-bad-advice; log:"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
if ! grep -q "I-S35-VIOLATION" "$LOG"; then
  echo "FAIL TC3: expected I-S35-VIOLATION marker in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: advice without aid framing → I-S35-VIOLATION"

# --- TC4: advice phrasing WITH aid framing → no violation ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/tc4-aid-framed.md" <<'EOF'
# VNM thesis exploration
For thesis exploration purposes only — not financial advice.
The bull case might suggest one should buy this stock; the bear case argues
against. Use as research aid only.
EOF
run_hook
if violation_logged "tc4-aid-framed"; then
  echo "FAIL TC4: aid-framed file should NOT be logged as I-S35; log:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: advice + aid framing → no violation"

# --- TC5: LLM-self-claim-of-computation → I-S1-VIOLATION ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/tc5-llm-math.md" <<'EOF'
# Analysis output
My analysis estimates the ROE at 18% based on recent filings.
EOF
run_hook
if ! violation_logged "tc5-llm-math"; then
  echo "FAIL TC5: expected I-S1-VIOLATION for tc5-llm-math; log:"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
if ! grep -q "I-S1-VIOLATION" "$LOG"; then
  echo "FAIL TC5: expected I-S1-VIOLATION marker in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: 'my analysis estimates 18%' → I-S1-VIOLATION"

# --- TC6: insider-info signal → CHARTER-VIOLATION ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/observations/tc6-insider.md" <<'EOF'
# Note
Got insider info from broker — earnings will beat estimates.
EOF
run_hook
if ! violation_logged "tc6-insider"; then
  echo "FAIL TC6: expected CHARTER-VIOLATION for tc6-insider; log:"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
if ! grep -q "insider-info" "$LOG"; then
  echo "FAIL TC6: expected insider-info marker in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: 'insider info from broker' → CHARTER-VIOLATION (insider-info)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "charter-coherence-spot.sh externally-observable behavior verified."
exit 0
