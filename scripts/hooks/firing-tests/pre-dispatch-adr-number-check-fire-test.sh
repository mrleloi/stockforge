#!/usr/bin/env bash
# pre-dispatch-adr-number-check-fire-test.sh — companion firing-test per L-S51-1
# Tests externally-observable behavior of pre-dispatch-adr-number-check.sh:
# stderr WARN markers + JSON block in STRICT mode
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/pre-dispatch-adr-number-check.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
DECISIONS_DIR="$PROJECT_DIR/agent-workspace/memory/decisions"
mkdir -p "$DECISIONS_DIR"

# Seed existing ADRs: 026, 027, 028, 029, 030, 031 (highest=031)
for n in 026 027 028 029 030 031; do
  echo "test ADR $n" > "$DECISIONS_DIR/${n}-test-adr.md"
done

PASS=0
FAIL=0

run_tc() {
  local TC_NAME="$1" PAYLOAD="$2" EXPECT_PATTERN="$3" STRICT="${4:-0}"
  local OUTPUT EXIT
  OUTPUT="$(STOCKFORGE_ADR_CHECK_STRICT="$STRICT" CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>&1 || true)"
  EXIT=$?
  if [ "$EXPECT_PATTERN" = "SILENT" ]; then
    if [ -z "$OUTPUT" ]; then
      printf '  TC %s: PASS (silent)\n' "$TC_NAME"; PASS=$((PASS+1))
    else
      printf '  TC %s: FAIL — expected silent, got: %s\n' "$TC_NAME" "$OUTPUT"; FAIL=$((FAIL+1))
    fi
  elif printf '%s' "$OUTPUT" | grep -qE "$EXPECT_PATTERN"; then
    printf '  TC %s: PASS\n' "$TC_NAME"; PASS=$((PASS+1))
  else
    printf '  TC %s: FAIL — expected pattern "%s", got: %s\n' "$TC_NAME" "$EXPECT_PATTERN" "$OUTPUT"; FAIL=$((FAIL+1))
  fi
}

echo "=== pre-dispatch-adr-number-check-fire-test ==="

# TC1: non-Agent tool → silent
run_tc TC1-non-agent \
  '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' \
  "SILENT"

# TC2: Agent without ADR mention → silent
run_tc TC2-no-adr-mention \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Implement feature X with tests"}}' \
  "SILENT"

# TC3: Agent proposing NEW path with collision number 028 → WARN
run_tc TC3-path-collision \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Author new ADR at agent-workspace/memory/decisions/028-S51-BC-7-architecture.md"}}' \
  "ADR-NUMBER COLLISION DETECTED"

# TC4: Agent proposing safe NEW path 032 → silent (highest=031, 032 = next)
run_tc TC4-path-safe-next \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Author new ADR at agent-workspace/memory/decisions/032-S51-BC-7-architecture.md"}}' \
  "SILENT"

# TC5: Agent mentioning D-028 + "new ADR" intent → WARN
run_tc TC5-d-ref-with-intent \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Create new ADR D-028 for BC-7 architecture mirroring D-027"}}' \
  "Suggested: D-032"

# TC6: Agent mentioning D-027 (existing) without authoring intent → silent (D-027 is referenced not authored)
run_tc TC6-d-ref-no-intent \
  '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Mirror D-027 schema for the new spec"}}' \
  "SILENT"

# TC7: STRICT mode + collision → exit 2 + JSON block
OUTPUT_TC7="$(STOCKFORGE_ADR_CHECK_STRICT=1 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" \
  <<< '{"hook_event_name":"PreToolUse","tool_name":"Agent","tool_input":{"prompt":"Author new ADR at agent-workspace/memory/decisions/028-foo.md"}}' 2>&1 || true)"
if printf '%s' "$OUTPUT_TC7" | grep -qE '"permissionDecision":\s*"deny"'; then
  echo "  TC TC7-strict-block: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-strict-block: FAIL — expected JSON deny, got: $OUTPUT_TC7"; FAIL=$((FAIL+1))
fi

# TC8: empty payload → silent
run_tc TC8-empty-payload "" "SILENT"

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
