#!/usr/bin/env bash
# scheduled-drift-detector-trigger-fire-test.sh — companion firing-test per L-S51-1
set -uo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available" >&2; exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/scheduled-drift-detector-trigger.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LAST_FIRE="$MEM_DIR/.drift-detector-last-fire"
DUE="$MEM_DIR/.drift-detector-due"
mkdir -p "$MEM_DIR"

PASS=0
FAIL=0

PAYLOAD='{"hook_event_name":"Stop"}'

# TC1: First run (no last-fire) → marker created
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true
if [ -f "$DUE" ]; then
  echo "  TC TC1-first-run-marker: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-first-run-marker: FAIL — marker not created"; FAIL=$((FAIL+1))
fi

# TC2: Idempotent — second run with marker pending → no duplicate creation (mtime check)
MTIME_BEFORE=$(stat -c '%Y' "$DUE" 2>/dev/null || stat -f '%m' "$DUE" 2>/dev/null || echo 0)
sleep 1
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true
MTIME_AFTER=$(stat -c '%Y' "$DUE" 2>/dev/null || stat -f '%m' "$DUE" 2>/dev/null || echo 0)
if [ "$MTIME_BEFORE" = "$MTIME_AFTER" ]; then
  echo "  TC TC2-idempotent-pending: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-idempotent-pending: FAIL — marker mtime changed"; FAIL=$((FAIL+1))
fi

# TC3: Recent fire (within interval) → no marker creation
rm -f "$DUE"
NOW="$(date +%s)"
echo "$NOW" > "$LAST_FIRE"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true
if [ ! -f "$DUE" ]; then
  echo "  TC TC3-recent-fire-no-marker: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-recent-fire-no-marker: FAIL"; FAIL=$((FAIL+1))
fi

# TC4: Stale fire (>6h ago) → marker created
rm -f "$DUE"
STALE=$((NOW - 25000))  # >6h
echo "$STALE" > "$LAST_FIRE"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true
if [ -f "$DUE" ]; then
  echo "  TC TC4-stale-fire-marker: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-stale-fire-marker: FAIL"; FAIL=$((FAIL+1))
fi

# TC5: Custom interval via env (1s)
rm -f "$DUE"
echo "$((NOW - 5))" > "$LAST_FIRE"
DRIFT_DETECTOR_INTERVAL_SECONDS=1 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true
if [ -f "$DUE" ]; then
  echo "  TC TC5-custom-interval: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-custom-interval: FAIL"; FAIL=$((FAIL+1))
fi

# TC6: Non-Stop event → no marker
rm -f "$DUE" "$LAST_FIRE"
PAYLOAD_TC6='{"hook_event_name":"PreToolUse","tool_name":"Read"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC6" 2>&1 || true
if [ ! -f "$DUE" ]; then
  echo "  TC TC6-non-stop-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-non-stop-skip: FAIL"; FAIL=$((FAIL+1))
fi

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
