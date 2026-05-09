#!/usr/bin/env bash
# diagnostic-pretooluse-stash-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2 retro-fit
# REAL-STATE-DERIVED per L-S176-1: parent hook reads stdin, writes verbatim to .diag-pretooluse/<TS>.json,
# echoes stdin back to stdout. Ephemeral diagnostic tool ported from orch v2.2.0.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/diagnostic-pretooluse-stash.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
DIAG_DIR="$PROJECT_DIR/agent-workspace/memory/.diag-pretooluse"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PASS=0
FAIL=0

# TC1: empty stdin → exit 0, no file written
out_count_before=$(find "$DIAG_DIR" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)
echo -n "" | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
rc1=$?
out_count_after=$(find "$DIAG_DIR" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)
if [ "$rc1" = 0 ] && [ "$out_count_after" = "$out_count_before" ]; then
  echo "  TC TC1-empty-stdin-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-empty-stdin-noop: FAIL — rc=$rc1 file_delta=$((out_count_after - out_count_before))"
  FAIL=$((FAIL+1))
fi

# TC2: stdin payload → file written verbatim
PAYLOAD_REAL='{"hook_event_name":"PreToolUse","tool_name":"Edit","session_id":"abc-123"}'
echo -n "$PAYLOAD_REAL" | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
rc2=$?
written_file=$(find "$DIAG_DIR" -maxdepth 1 -name '*.json' 2>/dev/null | head -1)
if [ "$rc2" = 0 ] && [ -n "$written_file" ] && [ "$(cat "$written_file")" = "$PAYLOAD_REAL" ]; then
  echo "  TC TC2-stdin-written-verbatim: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-stdin-written-verbatim: FAIL — rc=$rc2 file=$written_file content_match=$([ "$(cat "$written_file" 2>/dev/null)" = "$PAYLOAD_REAL" ] && echo yes || echo no)"
  FAIL=$((FAIL+1))
fi

# TC3: stdout echoes stdin verbatim (passthrough requirement)
PAYLOAD2='{"hook_event_name":"PreToolUse","tool_input":{"file_path":"/x.md"}}'
out=$(echo -n "$PAYLOAD2" | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>/dev/null)
if [ "$out" = "$PAYLOAD2" ]; then
  echo "  TC TC3-stdout-passthrough: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-stdout-passthrough: FAIL — out_len=${#out} expected_len=${#PAYLOAD2}"
  FAIL=$((FAIL+1))
fi

# TC4: missing diag dir → auto-created (rm + retry)
rm -rf "$DIAG_DIR"
echo -n '{"x":1}' | CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
if [ -d "$DIAG_DIR" ] && [ "$(find "$DIAG_DIR" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)" -ge 1 ]; then
  echo "  TC TC4-auto-mkdir: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-auto-mkdir: FAIL — dir_exists=$([ -d "$DIAG_DIR" ] && echo yes || echo no) files=$(find "$DIAG_DIR" -maxdepth 1 -name '*.json' 2>/dev/null | wc -l)"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== diagnostic-pretooluse-stash firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
