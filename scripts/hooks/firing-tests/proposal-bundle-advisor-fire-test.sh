#!/usr/bin/env bash
# Firing-test for proposal-bundle-advisor.sh (L-S49b-4 charter-coverage push; S77).
#
# Hook purpose (SessionStart hook; L-S43f-1 hook-tier promotion per Q-E3 priority):
#   - Scans agent-workspace/proposals/*.md (head -20 lines)
#   - Counts files with `status: PROPOSAL/PROPOSED` or `**Status**: PROPOSAL/PROPOSED`
#   - Skip if same head also contains ACCEPTED/REJECTED/AMENDED/RATIFIED
#   - If pending ≥ 2 → ADVISORY log + stderr (recommend bundled deny-lift cycle)
#   - Else → log "pending=N (no bundling opportunity)"
#
# 5 test cases:
#   TC1 — no PROP_DIR → exit 0 silently
#   TC2 — empty PROP_DIR → log "pending=0 (no bundling opportunity)"
#   TC3 — 1 pending proposal → log "pending=1 (no bundling opportunity)"
#   TC4 — 2 pending proposals → ADVISORY log + stderr (bundling opportunity)
#   TC5 — 2 status:PROPOSAL but 1 also has ACCEPTED in head → counts only 1; no advisory
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../proposal-bundle-advisor.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

PROP_DIR="$TEMPDIR/agent-workspace/proposals"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

# --- TC1: no PROP_DIR → silent exit 0 ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ] && grep -q "proposal-bundle-advisor" "$LOG"; then
  echo "FAIL TC1: log should be empty when no PROP_DIR"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no PROP_DIR → silent exit 0"

# --- TC2: empty PROP_DIR → log pending=0 ---
clean_state
mkdir -p "$PROP_DIR"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "proposal-bundle-advisor: pending=0" "$LOG"; then
  echo "FAIL TC2: log should record pending=0"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC2: empty PROP_DIR → log pending=0"

# --- TC3: 1 pending proposal → log pending=1 ---
clean_state
mkdir -p "$PROP_DIR"
cat > "$PROP_DIR/001-foo.md" <<'EOF'
---
status: PROPOSAL
target: agent-workspace/constitution/foo.md
---

# Proposal: foo
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "proposal-bundle-advisor: pending=1" "$LOG"; then
  echo "FAIL TC3: log should record pending=1"
  cat "$LOG"
  exit 1
fi
if grep -q "Consider bundled deny-lift" "$LOG"; then
  echo "FAIL TC3: should NOT trigger bundling advisory for single pending"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: 1 pending → log pending=1 (no advisory)"

# --- TC4: 2 pending proposals → ADVISORY log + stderr ---
clean_state
mkdir -p "$PROP_DIR"
cat > "$PROP_DIR/001-foo.md" <<'EOF'
---
status: PROPOSAL
target: agent-workspace/constitution/foo.md
---

# Proposal: foo
EOF
cat > "$PROP_DIR/002-bar.md" <<'EOF'
---
status: PROPOSED
target: agent-workspace/constitution/bar.md
---

# Proposal: bar
EOF
STDERR="$TEMPDIR/tc4.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0 (soft-warn); got $RC"
  cat "$STDERR" 2>/dev/null
  exit 1
fi
if ! grep -q "proposal-bundle-advisor: 2 charter-tier proposals currently pending" "$LOG"; then
  echo "FAIL TC4: log should ADVISE 2 pending"
  cat "$LOG"
  exit 1
fi
if ! grep -q "Consider bundled deny-lift cycle" "$LOG"; then
  echo "FAIL TC4: log should mention bundled deny-lift"
  cat "$LOG"
  exit 1
fi
if ! grep -q "proposal-bundle-advisor" "$STDERR"; then
  echo "FAIL TC4: stderr should contain advisory"
  cat "$STDERR"
  exit 1
fi
if ! grep -q "001-foo.md" "$LOG"; then
  echo "FAIL TC4: log should list 001-foo.md target"
  cat "$LOG"
  exit 1
fi
if ! grep -q "002-bar.md" "$LOG"; then
  echo "FAIL TC4: log should list 002-bar.md target"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: 2 pending → ADVISORY log + stderr + targets listed"

# --- TC5: 1 PROPOSAL + 1 ACCEPTED-in-head → counts only 1; no advisory ---
clean_state
mkdir -p "$PROP_DIR"
cat > "$PROP_DIR/001-foo.md" <<'EOF'
---
status: PROPOSAL
target: agent-workspace/constitution/foo.md
---

# Proposal: foo
EOF
# Accepted proposal in head — has both PROPOSAL keyword AND ACCEPTED → safer double-check skips
cat > "$PROP_DIR/003-baz.md" <<'EOF'
---
status: PROPOSAL
ratification_status: ACCEPTED
target: agent-workspace/constitution/baz.md
---

# Proposal: baz (already accepted via ratification flow)
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "proposal-bundle-advisor: pending=1" "$LOG"; then
  echo "FAIL TC5: log should count only 1 pending (PROPOSAL+ACCEPTED head excluded by safer double-check)"
  cat "$LOG"
  exit 1
fi
if grep -q "Consider bundled deny-lift" "$LOG"; then
  echo "FAIL TC5: should NOT advise bundling for effective 1 pending"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: PROPOSAL+ACCEPTED head excluded → effective 1 pending; no advisory"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "proposal-bundle-advisor.sh externally-observable behavior verified."
exit 0
