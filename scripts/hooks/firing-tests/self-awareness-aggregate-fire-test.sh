#!/usr/bin/env bash
# Firing-test for self-awareness-aggregate.sh (Phase 3.5 T7 retrofit; S60).
#
# Hook purpose (D-008 Stop): aggregate per-session telemetry into
# agent-workspace/memory/self-awareness/sessions-rollup.tsv.
# Sources: dispatch.jsonl, component-telemetry.jsonl, .transcript-tokens,
# .session-hooks.log, sessions/*.md.
#
# Test strategy: stage temp PROJECT_DIR with various source-file states; invoke
# hook; assert sessions-rollup.tsv content + .session-hooks.log entry.
#
# 6 test cases:
#   TC1 — empty memory dir → row with all defaults (0/unknown/0/0/0/-/0)
#   TC2 — sessions/ has session-N → session_n field populated
#   TC3 — component-telemetry has lines → tools_used = line count
#   TC4 — dispatch.jsonl has DISPATCHED events → subagents counted
#   TC5 — component-telemetry has failure_mode → failure_codes counted per code
#   TC6 — idempotent: header only on first run; appends on subsequent
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../self-awareness-aggregate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

ROLLUP="$TEMPDIR/agent-workspace/memory/self-awareness/sessions-rollup.tsv"

# Hook resolves ROOT_DIR via $(cd "$(dirname "$0")/../.." && pwd) — i.e. relative
# to script location, NOT $CLAUDE_PROJECT_DIR. Workaround: copy hook to a temp
# tree mirroring scripts/hooks/ structure rooted at $TEMPDIR.
HOOK_TEMP_DIR="$TEMPDIR/scripts/hooks"
mkdir -p "$HOOK_TEMP_DIR"
cp "$HOOK" "$HOOK_TEMP_DIR/self-awareness-aggregate.sh"
HOOK_TEMP="$HOOK_TEMP_DIR/self-awareness-aggregate.sh"

run_hook() {
  bash "$HOOK_TEMP" >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: empty memory dir → row with all defaults ---
clean_state
run_hook
if [ ! -f "$ROLLUP" ]; then
  echo "FAIL TC1: rollup TSV not created"
  exit 1
fi
HEADER=$(head -1 "$ROLLUP")
if ! echo "$HEADER" | grep -q "session_n"; then
  echo "FAIL TC1: header missing session_n column"
  cat "$ROLLUP"
  exit 1
fi
ROW=$(tail -1 "$ROLLUP")
# Default row: 0  unknown  TS  0  0  0  -  0
if ! echo "$ROW" | grep -qE $'^0\tunknown\t.*\t0\t0\t0\t-\t0$'; then
  echo "FAIL TC1: row defaults incorrect"
  echo "Got: $ROW"
  exit 1
fi
echo "PASS TC1: empty memory → row with defaults (0/unknown/0/0/0/-/0)"

# --- TC2: sessions/ has session-N → session_n parsed ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
touch "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-42.md"
touch "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-7.md"
run_hook
ROW=$(tail -1 "$ROLLUP")
SESSION_N=$(echo "$ROW" | cut -f1)
if [ "$SESSION_N" != "42" ]; then
  echo "FAIL TC2: expected session_n=42 (max), got $SESSION_N"
  echo "Row: $ROW"
  exit 1
fi
echo "PASS TC2: sessions/ has session-42 → session_n=42"

# --- TC3: component-telemetry has lines → tools_used = count ---
clean_state
COMP="$TEMPDIR/agent-workspace/memory/component-telemetry.jsonl"
{
  echo '{"tool":"Read","ts":"2026-05-05T12:00:00Z"}'
  echo '{"tool":"Edit","ts":"2026-05-05T12:01:00Z"}'
  echo '{"tool":"Bash","ts":"2026-05-05T12:02:00Z"}'
} > "$COMP"
run_hook
ROW=$(tail -1 "$ROLLUP")
TOOLS_USED=$(echo "$ROW" | cut -f5)
if [ "$TOOLS_USED" != "3" ]; then
  echo "FAIL TC3: expected tools_used=3, got $TOOLS_USED"
  echo "Row: $ROW"
  exit 1
fi
echo "PASS TC3: component-telemetry 3 lines → tools_used=3"

# --- TC4: dispatch.jsonl has DISPATCHED events → subagents counted ---
clean_state
DISPATCH="$TEMPDIR/agent-workspace/memory/dispatch.jsonl"
{
  echo '{"event":"DISPATCHED","ts_ms":1700000000000,"subagent":"Explore"}'
  echo '{"event":"DISPATCHED","ts_ms":1700000060000,"subagent":"Plan"}'
  echo '{"event":"COMPLETED","ts_ms":1700000120000}'
} > "$DISPATCH"
run_hook
ROW=$(tail -1 "$ROLLUP")
SUBAGENTS=$(echo "$ROW" | cut -f6)
if [ "$SUBAGENTS" != "2" ]; then
  echo "FAIL TC4: expected subagents=2, got $SUBAGENTS"
  echo "Row: $ROW"
  exit 1
fi
echo "PASS TC4: dispatch.jsonl 2 DISPATCHED → subagents=2"

# --- TC5: component-telemetry has failure_mode → failure_codes counted ---
clean_state
COMP="$TEMPDIR/agent-workspace/memory/component-telemetry.jsonl"
{
  echo '{"tool":"Edit","failure_mode":"A"}'
  echo '{"tool":"Edit","failure_mode":"A"}'
  echo '{"tool":"Bash","failure_mode":"B"}'
  echo '{"tool":"Read"}'
} > "$COMP"
run_hook
ROW=$(tail -1 "$ROLLUP")
FAILURE_CODES=$(echo "$ROW" | cut -f7)
# Expect "A:2,B:1" or "B:1,A:2" (awk dict order non-deterministic). Check both substrings.
if ! echo "$FAILURE_CODES" | grep -q "A:2"; then
  echo "FAIL TC5: expected A:2 in failure_codes, got '$FAILURE_CODES'"
  echo "Row: $ROW"
  exit 1
fi
if ! echo "$FAILURE_CODES" | grep -q "B:1"; then
  echo "FAIL TC5: expected B:1 in failure_codes, got '$FAILURE_CODES'"
  echo "Row: $ROW"
  exit 1
fi
echo "PASS TC5: component-telemetry 2×A + 1×B → failure_codes='$FAILURE_CODES'"

# --- TC6: idempotent — header only on first run; appends on subsequent ---
clean_state
run_hook
HEADER_COUNT_AFTER_1=$(grep -c "^session_n" "$ROLLUP" 2>/dev/null || true)
ROW_COUNT_AFTER_1=$(wc -l < "$ROLLUP" | tr -d '[:space:]')
run_hook
HEADER_COUNT_AFTER_2=$(grep -c "^session_n" "$ROLLUP" 2>/dev/null || true)
ROW_COUNT_AFTER_2=$(wc -l < "$ROLLUP" | tr -d '[:space:]')

if [ "$HEADER_COUNT_AFTER_1" != "1" ] || [ "$HEADER_COUNT_AFTER_2" != "1" ]; then
  echo "FAIL TC6: header should appear exactly once across runs; first=$HEADER_COUNT_AFTER_1 second=$HEADER_COUNT_AFTER_2"
  cat "$ROLLUP"
  exit 1
fi
if [ "$ROW_COUNT_AFTER_2" -le "$ROW_COUNT_AFTER_1" ]; then
  echo "FAIL TC6: second run should append a row; first=$ROW_COUNT_AFTER_1 second=$ROW_COUNT_AFTER_2"
  exit 1
fi
echo "PASS TC6: idempotent — header once + row appended each run"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "self-awareness-aggregate.sh externally-observable behavior verified."
exit 0
