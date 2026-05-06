#!/usr/bin/env bash
# effort-escalation-detector-fire-test.sh — companion firing-test per L-S51-1
# Tests externally-observable: stderr "effort_recommendation: <level>" emission
set -uo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available" >&2; exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/effort-escalation-detector.sh"

PASS=0
FAIL=0

run_tc() {
  local TC_NAME="$1" PAYLOAD="$2" EXPECT_LEVEL="$3"
  local OUTPUT
  OUTPUT="$(bash "$HOOK" <<< "$PAYLOAD" 2>&1 1>/dev/null || true)"
  if [ "$EXPECT_LEVEL" = "NONE" ]; then
    if [ -z "$OUTPUT" ]; then
      printf '  TC %s: PASS (silent)\n' "$TC_NAME"; PASS=$((PASS+1))
    else
      printf '  TC %s: FAIL — expected silent, got: %s\n' "$TC_NAME" "$OUTPUT"; FAIL=$((FAIL+1))
    fi
  elif printf '%s' "$OUTPUT" | grep -q "effort_recommendation: $EXPECT_LEVEL"; then
    printf '  TC %s: PASS (level=%s)\n' "$TC_NAME" "$EXPECT_LEVEL"; PASS=$((PASS+1))
  else
    printf '  TC %s: FAIL — expected %s, got: %s\n' "$TC_NAME" "$EXPECT_LEVEL" "$OUTPUT"; FAIL=$((FAIL+1))
  fi
}

echo "=== effort-escalation-detector-fire-test ==="

# TC1: routine prompt → silent (no level)
run_tc TC1-routine \
  '{"hook_event_name":"UserPromptSubmit","prompt":"Update the session log with deliverables shipped"}' \
  "NONE"

# TC2: ambiguity signal → high
run_tc TC2-ambiguous \
  '{"hook_event_name":"UserPromptSubmit","prompt":"This spec is ambiguous, please clarify before implementing"}' \
  "high"

# TC3: debug stuck → high
run_tc TC3-debug-stuck \
  '{"hook_event_name":"UserPromptSubmit","prompt":"I am stuck debugging this test failure for hours"}' \
  "high"

# TC4: novel pattern → xhigh
run_tc TC4-novel \
  '{"hook_event_name":"UserPromptSubmit","prompt":"This is a novel pattern, no precedent in our codebase"}' \
  "xhigh"

# TC5: charter-tier touch → xhigh
run_tc TC5-charter \
  '{"hook_event_name":"UserPromptSubmit","prompt":"Need to charter-amend invariants.md for new BR-X rule"}' \
  "xhigh"

# TC6: multi-perspective adversarial → max
run_tc TC6-multi-perspective \
  '{"hook_event_name":"UserPromptSubmit","prompt":"Need bear, bull, critic, quant, behavior, manager perspectives all weighing in"}' \
  "max"

# TC7: recurring failure → max
run_tc TC7-recurring \
  '{"hook_event_name":"UserPromptSubmit","prompt":"This is the third time this same failure has recurred"}' \
  "max"

# TC8: mechanical operation → low
run_tc TC8-mechanical \
  '{"hook_event_name":"UserPromptSubmit","prompt":"continue"}' \
  "low"

# TC9: PreToolUse on Agent with cross-BC signal → high
run_tc TC9-pretooluse-agent \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Cross-BC contract authoring with BC-1 BC-7 dependency"}}' \
  "high"

# TC10: PreToolUse non-Agent → silent
run_tc TC10-pretooluse-non-agent \
  '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"x"}}' \
  "NONE"

# TC11: Kill switch
OUTPUT_KS="$(EFFORT_DETECTOR_DISABLE=1 bash "$HOOK" <<< '{"hook_event_name":"UserPromptSubmit","prompt":"This is ambiguous and stuck"}' 2>&1 1>/dev/null || true)"
if [ -z "$OUTPUT_KS" ]; then
  echo "  TC TC11-kill-switch: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC11-kill-switch: FAIL — switch ignored: $OUTPUT_KS"; FAIL=$((FAIL+1))
fi

# TC12: Empty prompt → silent
run_tc TC12-empty-prompt \
  '{"hook_event_name":"UserPromptSubmit","prompt":""}' \
  "NONE"

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
