#!/usr/bin/env bash
# Firing-test for dogfood-the-promotion.sh (plan-046 D1; L-S389-1 PROMOTE-NOW).
#
# Verifies:
#   TC1: observation with "STEP 5.4 promoted" + "~580" within ±5 lines -> DETECT (LOW row in state)
#   TC2: observation with "STEP 5.4 promoted" but no "~" -> NO detection
#   TC3: observation with "~999" but no "STEP X.Y promoted" -> NO detection
#   TC4: observation older than 5 minutes -> NO scan (find -mmin filter)
#   TC5: missing observations dir -> silent skip (exit 0)
#
# Exit 0 = all TCs pass. Exit 1 = any TC fails.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../dogfood-the-promotion.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir=$TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory/observations"
STATE="$TEMPDIR/agent-workspace/memory/.severity-state.tsv"
LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
touch "$STATE" "$LOG"

PASS=0; FAIL=0

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null || true
}

# TC1: DETECT — promotion marker + tilde-digit within ±5 lines
cat > "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc1.md" <<'EOF'
# Dev Observation TC1
STEP 5.4 promoted exact-integer discipline this session.
LOC table below:
~580 lines total in the new hook
This is the dogfood violation: ~580 uses tilde prefix.
EOF
touch "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc1.md"  # ensure mtime is fresh

run_hook

if grep -q 'DOGFOOD-VIOLATION\|LOW.*sandwich-dev-S999-tc1' "$LOG" 2>/dev/null || \
   grep -q 'sandwich-dev-S999-tc1' "$STATE" 2>/dev/null; then
  echo "PASS [TC1] DETECT: promotion+tilde violation caught"
  PASS=$((PASS+1))
else
  echo "FAIL [TC1] DETECT: promotion+tilde violation NOT caught"
  echo "--- state ---"; cat "$STATE" 2>/dev/null || echo "(empty)"
  echo "--- log ---"; cat "$LOG" 2>/dev/null || echo "(empty)"
  FAIL=$((FAIL+1))
fi

# Reset state/log for next TC
> "$STATE"; > "$LOG"

# TC2: NO detection — promotion marker present but NO tilde
cat > "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc2.md" <<'EOF'
# Dev Observation TC2
STEP 5.4 promoted exact-integer discipline this session.
LOC table below:
580 lines total in the new hook (exact integer, no tilde)
This observation correctly uses exact integers.
EOF
touch "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc2.md"

run_hook

if grep -q 'sandwich-dev-S999-tc2' "$STATE" 2>/dev/null || \
   grep -q 'DOGFOOD-VIOLATION.*sandwich-dev-S999-tc2' "$LOG" 2>/dev/null; then
  echo "FAIL [TC2] false-positive: clean observation flagged"
  grep 'sandwich-dev-S999-tc2' "$STATE" "$LOG" 2>/dev/null || true
  FAIL=$((FAIL+1))
else
  echo "PASS [TC2] NO false-positive: clean observation not flagged"
  PASS=$((PASS+1))
fi

> "$STATE"; > "$LOG"
rm -f "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc1.md" \
       "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc2.md"

# TC3: NO detection — tilde present but NO promotion marker
cat > "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc3.md" <<'EOF'
# Dev Observation TC3
Regular observation with ~999 lines mentioned incidentally.
No rule promotion happens in this file.
EOF
touch "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc3.md"

run_hook

if grep -q 'sandwich-dev-S999-tc3' "$STATE" 2>/dev/null || \
   grep -q 'DOGFOOD-VIOLATION.*sandwich-dev-S999-tc3' "$LOG" 2>/dev/null; then
  echo "FAIL [TC3] false-positive: tilde-only (no promotion) flagged"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC3] NO false-positive: tilde-without-promotion not flagged"
  PASS=$((PASS+1))
fi

> "$STATE"; > "$LOG"
rm -f "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc3.md"

# TC4: NO scan — file older than 5 minutes (use touch -t to backdate)
cat > "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc4.md" <<'EOF'
# Dev Observation TC4
STEP 5.4 promoted this session.
~123 lines (would be a violation if file were recent)
EOF
# Backdate to 10 minutes ago
touch -t "$(date -d '10 minutes ago' +'%Y%m%d%H%M.%S' 2>/dev/null || date -v -10M +'%Y%m%d%H%M.%S' 2>/dev/null || echo '202001010000.00')" \
  "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc4.md" 2>/dev/null || \
  touch -d '-600 seconds' "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc4.md" 2>/dev/null || true

run_hook

if grep -q 'sandwich-dev-S999-tc4' "$STATE" 2>/dev/null || \
   grep -q 'DOGFOOD-VIOLATION.*sandwich-dev-S999-tc4' "$LOG" 2>/dev/null; then
  echo "FAIL [TC4] false-positive: old file (>5 min) was scanned"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC4] old file not scanned (find -mmin -5 filter working)"
  PASS=$((PASS+1))
fi

> "$STATE"; > "$LOG"
rm -f "$TEMPDIR/agent-workspace/memory/observations/sandwich-dev-S999-tc4.md"

# TC5: missing observations dir -> silent skip (exit 0)
rm -rf "$TEMPDIR/agent-workspace/memory/observations"

HOOK_RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>/dev/null || HOOK_RC=$?

if [ "$HOOK_RC" -eq 0 ]; then
  echo "PASS [TC5] missing observations dir: hook exits 0 (silent skip)"
  PASS=$((PASS+1))
else
  echo "FAIL [TC5] missing observations dir: hook returned RC=$HOOK_RC (should be 0)"
  FAIL=$((FAIL+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
