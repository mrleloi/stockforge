#!/usr/bin/env bash
# Firing-test for stop-finding-frontmatter-validator.sh (plan-046 D2; L-S397-2+PCG-S401-3).
#
# TCs:
#   TC1: STOP-FINDING with canonical severity + status -> no WARN
#   TC2: STOP-FINDING with ad-hoc severity "IMPLEMENTATION-BLOCKER" -> WARN emitted
#   TC3: STOP-FINDING with missing status field -> WARN emitted
#   TC4: STOP-FINDING with severity=HIGH + status=resolved-... -> no WARN (canonical happy path)
#   TC5: _STOP-FINDING-template.md file -> SKIP (underscore-prefix exclusion)
#   TC6: no STOP-FINDING files in dir -> silent exit 0 (no errors)
#
# Exit 0 = all TCs pass. Exit 1 = any TC fails.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../stop-finding-frontmatter-validator.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir=$TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/human-workspace/notifications"
mkdir -p "$TEMPDIR/agent-workspace/memory"
STATE="$TEMPDIR/agent-workspace/memory/.severity-state.tsv"
LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
touch "$STATE" "$LOG"

PASS=0; FAIL=0

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null || true
}

# TC1: canonical severity + status -> no WARN
cat > "$TEMPDIR/human-workspace/notifications/STOP-FINDING-TC1-good.md" <<'EOF'
---
type: STOP-FINDING
session: S999
severity: HIGH
status: pending
---
# STOP-FINDING: TC1 Good
EOF

> "$STATE"; > "$LOG"
run_hook

if grep -q 'STOP-FINDING-TC1-good' "$STATE" 2>/dev/null || \
   grep -q 'WARN.*STOP-FINDING-TC1-good' "$LOG" 2>/dev/null; then
  echo "FAIL [TC1] false-positive: canonical good file flagged"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC1] canonical good file not flagged"
  PASS=$((PASS+1))
fi

# TC2: ad-hoc severity -> WARN
cat > "$TEMPDIR/human-workspace/notifications/STOP-FINDING-TC2-badsev.md" <<'EOF'
---
type: STOP-FINDING
session: S999
severity: IMPLEMENTATION-BLOCKER
status: pending
---
# STOP-FINDING: TC2 Bad severity
EOF

> "$STATE"; > "$LOG"
run_hook

if grep -q 'STOP-FINDING-TC2-badsev' "$STATE" 2>/dev/null || \
   grep -q 'WARN.*STOP-FINDING-TC2-badsev\|ad-hoc severity.*STOP-FINDING-TC2' "$LOG" 2>/dev/null; then
  echo "PASS [TC2] ad-hoc severity detected (WARN emitted)"
  PASS=$((PASS+1))
else
  echo "FAIL [TC2] ad-hoc severity NOT detected"
  echo "--- state ---"; cat "$STATE" 2>/dev/null
  echo "--- log ---"; cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC3: missing status field -> WARN
cat > "$TEMPDIR/human-workspace/notifications/STOP-FINDING-TC3-nostatus.md" <<'EOF'
---
type: STOP-FINDING
session: S999
severity: HIGH
requires_human_decision: true
---
# STOP-FINDING: TC3 No status
EOF

> "$STATE"; > "$LOG"
run_hook

if grep -q 'STOP-FINDING-TC3-nostatus' "$STATE" 2>/dev/null || \
   grep -q 'WARN.*STOP-FINDING-TC3-nostatus\|missing status.*STOP-FINDING-TC3' "$LOG" 2>/dev/null; then
  echo "PASS [TC3] missing status field detected (WARN emitted)"
  PASS=$((PASS+1))
else
  echo "FAIL [TC3] missing status field NOT detected"
  echo "--- state ---"; cat "$STATE" 2>/dev/null
  echo "--- log ---"; cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC4: severity=HIGH + status=resolved-... -> no WARN (canonical happy path)
cat > "$TEMPDIR/human-workspace/notifications/STOP-FINDING-TC4-resolved.md" <<'EOF'
---
type: STOP-FINDING
session: S999
severity: HIGH
status: resolved-2026-05-17-via-D-081-S396
---
# STOP-FINDING: TC4 Resolved
EOF

> "$STATE"; > "$LOG"
run_hook

if grep -q 'STOP-FINDING-TC4-resolved' "$STATE" 2>/dev/null || \
   grep -q 'WARN.*STOP-FINDING-TC4-resolved' "$LOG" 2>/dev/null; then
  echo "FAIL [TC4] false-positive: resolved canonical file flagged"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC4] resolved canonical file not flagged"
  PASS=$((PASS+1))
fi

# TC5: _STOP-FINDING-template.md -> SKIP (underscore-prefix not matched by glob)
cat > "$TEMPDIR/human-workspace/notifications/_STOP-FINDING-template.md" <<'EOF'
---
type: STOP-FINDING
session: S<N>
severity: <CRITICAL | HIGH | MEDIUM | LOW>
---
# Template file — should not be scanned
EOF

> "$STATE"; > "$LOG"
# Remove other test files first so we isolate TC5
rm -f "$TEMPDIR/human-workspace/notifications/STOP-FINDING-TC"*.md
run_hook

if grep -q '_STOP-FINDING-template' "$STATE" 2>/dev/null || \
   grep -q 'WARN.*_STOP-FINDING-template' "$LOG" 2>/dev/null; then
  echo "FAIL [TC5] false-positive: _template.md was scanned (should be excluded by underscore prefix)"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC5] _template.md excluded from scan (underscore prefix)"
  PASS=$((PASS+1))
fi

# TC6: no STOP-FINDING files -> silent exit 0
rm -f "$TEMPDIR/human-workspace/notifications"/*
> "$STATE"; > "$LOG"

HOOK_RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null || HOOK_RC=$?

if [ "$HOOK_RC" -eq 0 ]; then
  echo "PASS [TC6] empty notifications dir: hook exits 0 silently"
  PASS=$((PASS+1))
else
  echo "FAIL [TC6] empty notifications dir: hook returned RC=$HOOK_RC"
  FAIL=$((FAIL+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
