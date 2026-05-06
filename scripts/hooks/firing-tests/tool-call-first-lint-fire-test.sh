#!/usr/bin/env bash
# Firing-test for tool-call-first-lint.sh (Phase 3.5 T7 retrofit; S59).
#
# Hook purpose (Stop hook): detect Mode-A (narrate-without-tool-call) by parsing
# last assistant turn from transcript JSONL. Mode-A = narration verb present
# (Dispatching/Will run/About to/...) WITHOUT tool_use block in same turn.
#
# Test strategy: stage temp PROJECT_DIR with current-execution.md (autonomous_mode
# flag) + transcript JSONL fixture; pipe stdin JSON; assert .tool-call-first-lint.log
# content reflects expected classification.
#
# 6 test cases:
#   TC1 — no transcript_path → silent
#   TC2 — autonomous_mode != true → silent (early bail)
#   TC3 — last assistant turn has tool_use → silent (not Mode-A)
#   TC4 — narration verb + tool_use present → silent (not Mode-A)
#   TC5 — narration verb without tool_use → WARN (Mode-A suspected)
#   TC6 — clean text without narration verb → silent
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../tool-call-first-lint.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LINT_LOG="$TEMPDIR/agent-workspace/memory/.tool-call-first-lint.log"

write_exec_with_autonomous() {
  local mode_value="${1:-true}"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
  cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**autonomous_mode**: $mode_value
EOF
}

write_transcript() {
  local fixture_content="$1"
  local fixture_path="$TEMPDIR/transcript.jsonl"
  printf '%s\n' "$fixture_content" > "$fixture_path"
  echo "$fixture_path"
}

run_hook() {
  local transcript_path="$1"
  local session_id="${2:-test-session-tc}"
  local payload
  payload=$(printf '{"session_id":"%s","transcript_path":"%s"}' "$session_id" "$transcript_path")
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<< "$payload" >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/transcript.jsonl"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: no transcript_path → silent ---
clean_state
write_exec_with_autonomous "true"
# Empty transcript_path in payload.
PAYLOAD='{"session_id":"tc1","transcript_path":""}'
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<< "$PAYLOAD" >/dev/null 2>&1 || true
if [ -f "$LINT_LOG" ] && grep -q "tc1" "$LINT_LOG" 2>/dev/null; then
  echo "FAIL TC1: empty transcript_path should silently exit (no log entry)"
  cat "$LINT_LOG"
  exit 1
fi
echo "PASS TC1: empty transcript_path → silent"

# --- TC2: autonomous_mode != true → silent (early bail before transcript parse) ---
clean_state
write_exec_with_autonomous "false"
TRANSCRIPT_FILE=$(write_transcript '{"role":"assistant","content":[{"type":"text","text":"Dispatching the verifier"}]}')
run_hook "$TRANSCRIPT_FILE" "tc2-session"
if [ -f "$LINT_LOG" ] && grep -q "tc2-session" "$LINT_LOG" 2>/dev/null; then
  echo "FAIL TC2: autonomous_mode=false should bail before classification"
  cat "$LINT_LOG"
  exit 1
fi
echo "PASS TC2: autonomous_mode != true → silent (early bail)"

# Helper: check whether a given session_id was classified as Mode-A in the log.
# Real log line shape is `[TS=...] [session=<id>] mode_a_suspected=true ...` so
# we need to check BOTH substrings on the same line, not regex-anchored ordering.
session_classified_mode_a() {
  local sess="$1"
  [ ! -f "$LINT_LOG" ] && return 1
  grep "session=$sess" "$LINT_LOG" 2>/dev/null | grep -q "mode_a_suspected=true"
}

# --- TC3: last assistant turn HAS tool_use → silent ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript '{"role":"assistant","content":[{"type":"text","text":"Reading the file"},{"type":"tool_use","id":"toolu_01","name":"Read","input":{"file_path":"x.md"}}]}')
run_hook "$TRANSCRIPT_FILE" "tc3-session"
if session_classified_mode_a "tc3-session"; then
  echo "FAIL TC3: tool_use present → should NOT classify as Mode-A"
  cat "$LINT_LOG"
  exit 1
fi
echo "PASS TC3: tool_use present → silent"

# --- TC4: narration verb + tool_use both present → silent (not Mode-A) ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript '{"role":"assistant","content":[{"type":"text","text":"Dispatching the sandwich-verifier now"},{"type":"tool_use","id":"toolu_02","name":"Agent","input":{"prompt":"verify"}}]}')
run_hook "$TRANSCRIPT_FILE" "tc4-session"
if session_classified_mode_a "tc4-session"; then
  echo "FAIL TC4: tool_use accompanies narration verb → should NOT classify as Mode-A"
  cat "$LINT_LOG"
  exit 1
fi
echo "PASS TC4: narration verb + tool_use → silent"

# --- TC5: narration verb WITHOUT tool_use → WARN (Mode-A suspected) ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript '{"role":"assistant","content":[{"type":"text","text":"Dispatching the verifier shortly"}]}')
run_hook "$TRANSCRIPT_FILE" "tc5-session"
if ! session_classified_mode_a "tc5-session"; then
  echo "FAIL TC5: expected mode_a_suspected=true WARN entry for tc5-session"
  cat "$LINT_LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC5: narration verb without tool_use → WARN Mode-A suspected"

# --- TC6: clean text (no narration verb, no tool_use) → silent ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript '{"role":"assistant","content":[{"type":"text","text":"Result summary: completed three tasks."}]}')
run_hook "$TRANSCRIPT_FILE" "tc6-session"
if session_classified_mode_a "tc6-session"; then
  echo "FAIL TC6: clean text → should NOT classify as Mode-A"
  cat "$LINT_LOG"
  exit 1
fi
echo "PASS TC6: clean text without narration verb → silent"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "tool-call-first-lint.sh externally-observable behavior verified."
exit 0
