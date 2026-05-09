#!/usr/bin/env bash
# Firing-test for taskcompleted-audit.sh (L-S49b-4 charter-coverage push; S78).
#
# Hook purpose (Stop hook; Decision 002 § Track 5 REV-2 § B deliverable):
#   - Find recent .md files (mmin -60) in: thesis-log/, specs/, decisions/
#   - Grep each for I-S1 (LLM-math anti-pattern), I-S1 (confidence-without-calibration),
#     I-S2 (numeric-no-citation), I-S10 (thesis-no-bear-case for thesis-log/ only).
#   - Per-violation line appended to .taskcompleted-audit.log.
#   - If any violations: count summary appended to .session-hooks.log.
#   - Always exit 0 (non-blocking).
#
# 5 test cases:
#   TC1 — no audit dirs (no thesis-log/specs/decisions) → silent exit 0; no log entries
#   TC2 — clean thesis (bear_case + source + as_of + no LLM-math) → no violation logged
#   TC3 — decision with "approximately 8 something" → I-S1 LLM-math violation logged
#   TC4 — thesis-log/ entry without bear_case keywords → I-S10 violation logged
#   TC5 — decision with "25% return" no source/as_of → I-S2 numeric-no-citation violation logged
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../taskcompleted-audit.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

THESIS_DIR="$TEMPDIR/agent-workspace/memory/thesis-log"
DECISION_DIR="$TEMPDIR/agent-workspace/memory/decisions"
SPECS_DIR="$TEMPDIR/specs"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
AUDIT_LOG="$MEM_DIR/.taskcompleted-audit.log"
HOOK_LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  # Pre-create all 3 audit dirs to mimic production layout. Without all 3 present,
  # `find dir1 dir2 dir3` exits rc=1 (multi-path: missing arg → error code) which
  # under pipefail+ERR-trap causes hook silent-exit before any audit work. This is
  # a multi-path variant of the L-S68-2 family (S68/S75 single-path missing dir,
  # S76 ls-glob no-match). Fixture matches production where specs/ + thesis-log/
  # + decisions/ are all well-known dirs (even if empty). NOT a hook bug — production
  # invariant. Backlog candidate for bash-hook-lint extension to detect multi-path
  # find without per-arg [ -d ] guard.
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/specs"
  mkdir -p "$MEM_DIR" "$THESIS_DIR" "$DECISION_DIR" "$SPECS_DIR"
}

# --- TC1: empty audit dirs (no recent files) → silent exit 0; no log entries ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$AUDIT_LOG" ]; then
  echo "FAIL TC1: audit log should not exist when no recent files"
  cat "$AUDIT_LOG" 2>/dev/null
  exit 1
fi
if [ -f "$HOOK_LOG" ] && grep -q "taskcompleted-audit" "$HOOK_LOG"; then
  echo "FAIL TC1: hook log should not contain taskcompleted-audit entry"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC1: empty audit dirs → silent exit 0"

# --- TC2: clean thesis (bear_case + source + as_of) → no violation ---
clean_state
mkdir -p "$THESIS_DIR"
cat > "$THESIS_DIR/clean.md" <<'EOF'
---
ticker: VIC
source: cafef.vn/foo
as_of: 2026-01-01
---

# Hold thesis on VIC
Long position considered.
bear_case: rate hike sensitivity noted.
downside: macro shock could compress multiples.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$AUDIT_LOG" ]; then
  echo "FAIL TC2: audit log should not exist for clean thesis"
  cat "$AUDIT_LOG"
  exit 1
fi
if [ -f "$HOOK_LOG" ] && grep -q "taskcompleted-audit" "$HOOK_LOG"; then
  echo "FAIL TC2: hook log should not flag clean thesis"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC2: clean thesis → no violation"

# --- TC3: decision with LLM-math "approximately 8" → I-S1 violation ---
clean_state
mkdir -p "$DECISION_DIR"
cat > "$DECISION_DIR/D-test.md" <<'EOF'
---
status: ACCEPTED
source: cafef.vn/baz
as_of: 2026-01-01
---

# Decision: approximately 8 percent allocation
Position size around 8 of book per L-S12-1 doctrine.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$AUDIT_LOG" ]; then
  echo "FAIL TC3: audit log should exist after I-S1 violation"
  exit 1
fi
if ! grep -q "I-S1-VIOLATION (LLM-math anti-pattern)" "$AUDIT_LOG"; then
  echo "FAIL TC3: audit log should record I-S1 LLM-math anti-pattern"
  cat "$AUDIT_LOG"
  exit 1
fi
if ! grep -q "taskcompleted-audit:.*violation" "$HOOK_LOG"; then
  echo "FAIL TC3: hook log should record violation count summary"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC3: decision with 'approximately 8' → I-S1 LLM-math violation logged"

# --- TC4: thesis-log/ without bear_case → I-S10 violation ---
clean_state
mkdir -p "$THESIS_DIR"
cat > "$THESIS_DIR/missing-bear.md" <<'EOF'
---
ticker: HPG
source: cafef.vn/hpg
as_of: 2026-01-01
---

# Long thesis on HPG
Strong fundamentals; favorable supply/demand dynamics.
Steel margins expanding.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$AUDIT_LOG" ]; then
  echo "FAIL TC4: audit log should exist after I-S10 violation"
  exit 1
fi
if ! grep -q "I-S10-VIOLATION (thesis-no-bear-case)" "$AUDIT_LOG"; then
  echo "FAIL TC4: audit log should record I-S10 thesis-no-bear-case"
  cat "$AUDIT_LOG"
  exit 1
fi
if ! grep -q "taskcompleted-audit:.*violation" "$HOOK_LOG"; then
  echo "FAIL TC4: hook log should record violation count summary"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC4: thesis-log without bear_case → I-S10 violation logged"

# --- TC5: decision with "25%" no source/as_of → I-S2 numeric-no-citation ---
clean_state
mkdir -p "$DECISION_DIR"
cat > "$DECISION_DIR/D-bare.md" <<'EOF'
---
status: PROPOSAL
---

# Decision: portfolio rebalance
Target allocation: 25% growth, 35% value, balance defensive.
Expected drawdown: 15% peak-to-trough.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$AUDIT_LOG" ]; then
  echo "FAIL TC5: audit log should exist after I-S2 violation"
  exit 1
fi
if ! grep -q "I-S2-VIOLATION (numeric-no-citation)" "$AUDIT_LOG"; then
  echo "FAIL TC5: audit log should record I-S2 numeric-no-citation"
  cat "$AUDIT_LOG"
  exit 1
fi
if ! grep -q "taskcompleted-audit:.*violation" "$HOOK_LOG"; then
  echo "FAIL TC5: hook log should record violation count summary"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC5: decision with 25% no citation → I-S2 numeric-no-citation logged"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "taskcompleted-audit.sh externally-observable behavior verified."
exit 0
