#!/usr/bin/env bash
# Firing-test for promotion-cycle-trigger.sh (Phase 3.5 T3 priority-1 fix; companion to L-S51-1).
#
# Tests the grep-pattern fix that resolves M-S51-1: the prior `^\*\*Session N\*\*:` literal pattern
# never matched the actual `## S50 — ...` header format in current-execution.md, causing LATEST_SESSION=0
# always.
#
# Test strategy:
#   1. Synthesize a temp current-execution.md with known-truthy header format.
#   2. Synthesize a temp obs/promote-rule-S<NN>.md to set last_promote baseline.
#   3. Invoke the hook with CLAUDE_PROJECT_DIR pointing to temp.
#   4. Assert LATEST_SESSION extracted correctly + SESSION_DELTA computes correctly.
#   5. Assert hard-block / soft-warn fires at expected thresholds.
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../promotion-cycle-trigger.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory/observations"

# --- Test case 1: hard-block when SESSION_DELTA ≥ 8 ---
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3 — Track I

## S50 — Phase 3.5 master-plan authored (2026-05-05) PLAN
## S49b — Tier 1 archive sweep
## S49a — audit
## S49 — closed

EOF
cat > "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S40.md" <<EOF
phase: 2
EOF

EXEC_FILE="$TEMPDIR/agent-workspace/memory/current-execution.md"
OUTPUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 || true)

# Read the log to extract latest_session
LOG="$TEMPDIR/agent-workspace/memory/.promotion-cycle.log"
[ ! -f "$LOG" ] && { echo "FAIL: log file not created"; exit 1; }

LAST_LINE=$(grep -E 'promotion-cycle-trigger: latest_session=' "$LOG" | tail -1)
LATEST_SESSION=$(echo "$LAST_LINE" | grep -oE 'latest_session=[0-9]+' | grep -oE '[0-9]+')
LAST_PROMOTE=$(echo "$LAST_LINE" | grep -oE 'last_promote=S[0-9]+' | grep -oE '[0-9]+')
DELTA=$(echo "$LAST_LINE" | grep -oE 'delta=-?[0-9]+' | grep -oE '\-?[0-9]+')

# Assert: LATEST_SESSION == 50 (extracted from `## S50` header)
if [ "$LATEST_SESSION" != "50" ]; then
  echo "FAIL TC1: LATEST_SESSION expected 50, got $LATEST_SESSION"
  echo "Log line: $LAST_LINE"
  exit 1
fi

# Assert: LAST_PROMOTE == 40
if [ "$LAST_PROMOTE" != "40" ]; then
  echo "FAIL TC1: LAST_PROMOTE expected 40, got $LAST_PROMOTE"
  exit 1
fi

# Assert: DELTA == 10 (50 - 40)
if [ "$DELTA" != "10" ]; then
  echo "FAIL TC1: DELTA expected 10, got $DELTA"
  exit 1
fi

# Assert: hook emitted HARD-BLOCK to stderr (delta=10 ≥ 8)
if ! echo "$OUTPUT" | grep -q "HARD-BLOCK\|HARD BLOCK\|HARD_BLOCK\|hard-block\|HARDBLOCK"; then
  echo "FAIL TC1: expected HARD-BLOCK message in stderr, got:"
  echo "$OUTPUT"
  exit 1
fi

echo "PASS TC1: hard-block fires correctly when SESSION_DELTA=10 (latest=50, last_promote=40)"

# --- Test case 2: soft-warn when 5 ≤ SESSION_DELTA < 8 ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S45.md" <<EOF
phase: 3
EOF

OUTPUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 || true)
LAST_LINE=$(grep -E 'promotion-cycle-trigger: latest_session=' "$LOG" | tail -1)
DELTA=$(echo "$LAST_LINE" | grep -oE 'delta=-?[0-9]+' | grep -oE '\-?[0-9]+')

# delta = 50 - 45 = 5 (soft-warn band)
if [ "$DELTA" != "5" ]; then
  echo "FAIL TC2: DELTA expected 5, got $DELTA"
  exit 1
fi

if echo "$OUTPUT" | grep -q "HARD-BLOCK"; then
  echo "FAIL TC2: should NOT hard-block at delta=5"
  echo "$OUTPUT"
  exit 1
fi

if ! echo "$OUTPUT" | grep -qi "SOFT-WARN\|soft-warn\|SOFT_WARN"; then
  echo "FAIL TC2: expected SOFT-WARN message, got:"
  echo "$OUTPUT"
  exit 1
fi

echo "PASS TC2: soft-warn fires correctly when SESSION_DELTA=5"

# --- Test case 3: silent when SESSION_DELTA < 5 ---
rm -f "$LOG"
rm -f "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S45.md"
cat > "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S48.md" <<EOF
phase: 3
EOF

OUTPUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 || true)
LAST_LINE=$(grep -E 'promotion-cycle-trigger: latest_session=' "$LOG" | tail -1)
DELTA=$(echo "$LAST_LINE" | grep -oE 'delta=-?[0-9]+' | grep -oE '\-?[0-9]+')

# delta = 50 - 48 = 2 (no fire)
if [ "$DELTA" != "2" ]; then
  echo "FAIL TC3: DELTA expected 2, got $DELTA"
  exit 1
fi

if echo "$OUTPUT" | grep -qi "SOFT-WARN\|HARD-BLOCK"; then
  echo "FAIL TC3: should be silent at delta=2, got:"
  echo "$OUTPUT"
  exit 1
fi

echo "PASS TC3: silent correctly when SESSION_DELTA=2"

# --- Test case 4: handles subordinate session formats (S49a, S49b, S50-pre) ---
rm -f "$LOG"
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3 — Track I

## S50 — main row
## S50-pre — meta-incident
## S49b — sweep
## S49a — audit
## S48m — closure
EOF
rm -f "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S48.md"
cat > "$TEMPDIR/agent-workspace/memory/observations/promote-rule-S40.md" <<EOF
phase: 2
EOF

OUTPUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 || true)
LAST_LINE=$(grep -E 'promotion-cycle-trigger: latest_session=' "$LOG" | tail -1)
LATEST_SESSION=$(echo "$LAST_LINE" | grep -oE 'latest_session=[0-9]+' | grep -oE '[0-9]+')

# Should still be 50 (not 50pre, not S49b's 49)
if [ "$LATEST_SESSION" != "50" ]; then
  echo "FAIL TC4: LATEST_SESSION with subordinate formats expected 50, got $LATEST_SESSION"
  echo "Log line: $LAST_LINE"
  exit 1
fi

echo "PASS TC4: handles subordinate formats (S50-pre, S49a, S49b) correctly — extracts 50"

# --- All passed ---
echo ""
echo "=== ALL FIRING-TESTS PASSED (4/4) ==="
echo "promotion-cycle-trigger.sh L-S51-1 fix verified empirically."
exit 0
