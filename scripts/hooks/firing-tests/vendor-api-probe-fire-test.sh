#!/usr/bin/env bash
# Firing-test for vendor-api-probe.sh (Phase 3.5 T7-followup; S73 NEW; S74 path-prefix fix update).
#
# Hook purpose (HH-A.1; SessionStart hook; per L-S28-1 + L-S32-1):
#   - reads agent-workspace/memory/current-execution.md to find active plan path
#     (matches `(agent-workspace/)?session-plans/pending/<digits>...md` — S74
#     path-prefix fix added optional agent-workspace/ prefix + post-match
#     normalization to always carry the prefix before existence check)
#   - if no current-execution.md OR no plan ref OR plan file missing → exit 0
#   - else: for each lib in whitelist (vnstock yfinance httpx anthropic openai
#     duckdb pgvector), grep plan for `import <lib>|from <lib>|<lib>.`; if hit,
#     run python -c "importlib.import_module('<lib>')" + log result to
#     .vendor-api-probe.log
#   - additionally counts multi-strategy ladder hits (Strategy A[1-4] /
#     alternative [A-D]: / ladder regex); if count >= 3 → log + stderr advisory
#   - always exits 0 (advisory only)
#
# 5 test cases (production-symmetric layout per S74; fixtures stage plans at
# $TEMPDIR/agent-workspace/session-plans/pending/<file>.md):
#   TC1 — no current-execution.md → exit 0; no log
#   TC2 — current-execution.md but no plan path → exit 0; no log
#   TC3 — plan with whitelist lib (httpx, available locally) → probe log entry
#   TC4 — plan with whitelist lib (anthropic, not installed locally) → FAIL log
#         entry + stderr "vendor-api-probe FAIL"
#   TC5 — plan with ≥3 multi-strategy ladder markers → log "multi-strategy
#         ladder detected" + stderr advisory
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../vendor-api-probe.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

EXEC_FILE="$TEMPDIR/agent-workspace/memory/current-execution.md"
LOG="$TEMPDIR/agent-workspace/memory/.vendor-api-probe.log"
# Production-symmetric layout (S74 path-prefix fix): plans staged under
# $TEMPDIR/agent-workspace/session-plans/pending/ to match production where
# current-execution.md references `agent-workspace/session-plans/pending/<plan>.md`.
PLAN_DIR="$TEMPDIR/agent-workspace/session-plans/pending"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory" "$PLAN_DIR"
}

# --- TC1: no current-execution.md → exit 0, no log ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ]; then
  echo "FAIL TC1: log should not exist when no current-execution.md"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no current-execution.md → silent no-op"

# --- TC2: current-execution.md but no plan ref → exit 0, no log ---
clean_state
echo "# Current execution — no active plan referenced" > "$EXEC_FILE"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ]; then
  echo "FAIL TC2: log should not exist when current-execution has no plan path"
  exit 1
fi
echo "PASS TC2: current-execution.md without plan ref → silent no-op"

# --- TC3: plan with whitelist lib (httpx, locally importable) → probe log entry ---
clean_state
PLAN_PATH="agent-workspace/session-plans/pending/099-test-vendor-import.md"
mkdir -p "$(dirname "$TEMPDIR/$PLAN_PATH")"
cat > "$TEMPDIR/$PLAN_PATH" <<'EOF'
# Test plan
This plan does:
import httpx
EOF
echo "Active plan: $PLAN_PATH" > "$EXEC_FILE"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC3: expected probe log at $LOG"
  ls -la "$TEMPDIR/agent-workspace/memory/" 2>/dev/null
  exit 1
fi
if ! grep -q "probe httpx" "$LOG"; then
  echo "FAIL TC3: log should contain 'probe httpx' entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: plan with import httpx → probe log entry"

# --- TC4: plan with non-installed whitelist lib (anthropic) → FAIL log + stderr ---
clean_state
PLAN_PATH="agent-workspace/session-plans/pending/099-test-vendor-fail.md"
mkdir -p "$(dirname "$TEMPDIR/$PLAN_PATH")"
cat > "$TEMPDIR/$PLAN_PATH" <<'EOF'
# Test plan
This plan does:
import anthropic
EOF
echo "Active plan: $PLAN_PATH" > "$EXEC_FILE"
STDERR="$TEMPDIR/tc4.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0 (advisory); got $RC"
  cat "$STDERR" || true
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC4: expected probe log at $LOG"
  exit 1
fi
if ! grep -q "probe anthropic" "$LOG"; then
  echo "FAIL TC4: log should contain 'probe anthropic' entry"
  cat "$LOG"
  exit 1
fi
# anthropic NOT installed in test env → expect FAIL line in log AND stderr msg
if ! grep -q "FAIL anthropic" "$LOG"; then
  echo "FAIL TC4: log should record FAIL for missing anthropic lib"
  cat "$LOG"
  exit 1
fi
if ! grep -q "vendor-api-probe FAIL" "$STDERR"; then
  echo "FAIL TC4: stderr should advise on FAIL"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC4: plan with import anthropic (not installed) → FAIL log + stderr"

# --- TC5: plan with ≥3 multi-strategy markers → ladder detected log ---
clean_state
PLAN_PATH="agent-workspace/session-plans/pending/099-test-ladder.md"
mkdir -p "$(dirname "$TEMPDIR/$PLAN_PATH")"
cat > "$TEMPDIR/$PLAN_PATH" <<'EOF'
# Test plan with multiple strategies
We could pick:
- Strategy A1 — direct
- Strategy A2 — proxy
- Strategy A3 — fallback
This is a strategy ladder evaluation.
EOF
echo "Active plan: $PLAN_PATH" > "$EXEC_FILE"
STDERR="$TEMPDIR/tc5.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC5: expected log even without vendor refs (ladder detection still fires)"
  exit 1
fi
if ! grep -q "multi-strategy ladder detected" "$LOG"; then
  echo "FAIL TC5: log should record 'multi-strategy ladder detected'"
  cat "$LOG"
  exit 1
fi
if ! grep -q "multi-strategy ladder detected" "$STDERR"; then
  echo "FAIL TC5: stderr should emit ladder advisory"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC5: plan with ≥3 strategy markers → ladder detection logged"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "vendor-api-probe.sh externally-observable behavior verified."
exit 0
