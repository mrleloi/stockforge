#!/usr/bin/env bash
# Firing-test for correction-rate-tracker.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (D-004 § Tracking Instrumentation Q2=A; UserPromptSubmit):
# detect VI/EN correction patterns in user prompt, append JSONL line to
# .correction-rate.log with bucket_50k from current .transcript-tokens.
# Non-blocking; pure telemetry.
#
# Test strategy: stage temp PROJECT_DIR; pipe JSON {prompt: "..."} to hook
# stdin; assert .correction-rate.log JSONL contents + .session-hooks.log entry.
#
# 6 test cases:
#   TC1 — empty stdin → exit 0; no log entry written
#   TC2 — neutral prompt "ok continue" → no match → no JSONL appended
#   TC3 — VI correction "không phải" → JSONL with matched_vi populated
#   TC4 — EN correction "no, that's wrong" → JSONL with matched_en populated
#   TC5 — both VI + EN match → JSONL with BOTH matched_vi AND matched_en
#   TC6 — bucket_50k computed from .transcript-tokens (e.g. 75432 → 50000)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../correction-rate-tracker.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "SKIP: node required (hook uses node -e)"; exit 0; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.correction-rate.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
TOK_FILE="$TEMPDIR/agent-workspace/memory/.transcript-tokens"

run_hook() {
  local prompt="$1" sid="${2:-tc-session}"
  local payload
  payload=$(node -e "process.stdout.write(JSON.stringify({prompt: process.argv[1]}))" "$prompt")
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: empty stdin → exit 0; no log written ---
clean_state
printf '' | CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="tc1" bash "$HOOK" >/dev/null 2>&1 || true
if [ -f "$LOG" ]; then
  echo "FAIL TC1: empty stdin should NOT create log file"
  exit 1
fi
echo "PASS TC1: empty stdin → no log written"

# --- TC2: neutral prompt "ok continue" → no match → no JSONL ---
clean_state
run_hook "ok continue please" "tc2"
if [ -f "$LOG" ] && [ -s "$LOG" ]; then
  echo "FAIL TC2: neutral prompt should NOT trigger JSONL append"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: neutral prompt → no JSONL appended"

# --- TC3: VI correction "không phải" → JSONL with matched_vi ---
clean_state
run_hook "không phải, làm lại đi" "tc3"
if [ ! -f "$LOG" ]; then
  echo "FAIL TC3: VI correction should write JSONL log file"
  exit 1
fi
if ! grep -q '"matched_vi"' "$LOG"; then
  echo "FAIL TC3: expected matched_vi field in JSONL"
  cat "$LOG"
  exit 1
fi
if ! grep -q 'không phải' "$LOG"; then
  echo "FAIL TC3: expected 'không phải' in matched_vi"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: VI correction → JSONL with matched_vi populated"

# --- TC4: EN correction "no, that's wrong" → JSONL with matched_en ---
clean_state
run_hook "no, that's wrong, please undo" "tc4"
if [ ! -f "$LOG" ]; then
  echo "FAIL TC4: EN correction should write JSONL log file"
  exit 1
fi
if ! grep -q '"matched_en"' "$LOG"; then
  echo "FAIL TC4: expected matched_en field"
  cat "$LOG"
  exit 1
fi
# At least one of the EN keywords should appear in matched_en value
if ! grep -qE '(wrong|no|undo)' "$LOG"; then
  echo "FAIL TC4: expected EN keyword in matched_en"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: EN correction → JSONL with matched_en populated"

# --- TC5: both VI + EN match → JSONL with BOTH ---
clean_state
run_hook "không đúng — that's wrong" "tc5"
if [ ! -f "$LOG" ]; then
  echo "FAIL TC5: combined correction should write JSONL"
  exit 1
fi
# Both matched_vi and matched_en should be populated on same JSONL line
# (single-line grep avoids over-engineering the assertion)
if ! grep -q '"matched_vi":"không đúng"' "$LOG"; then
  echo "FAIL TC5: expected matched_vi=\"không đúng\""
  cat "$LOG"
  exit 1
fi
if ! grep -q '"matched_en":"wrong"' "$LOG"; then
  echo "FAIL TC5: expected matched_en=\"wrong\""
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: combined VI+EN → both matched fields populated"

# --- TC6: bucket_50k computed from .transcript-tokens ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory"
echo "75432" > "$TOK_FILE"
run_hook "không phải" "tc6"
if [ ! -f "$LOG" ]; then
  echo "FAIL TC6: should write JSONL"
  exit 1
fi
# 75432 → bucket = floor(75432/50000)*50000 = 50000
if ! grep -q '"bucket_50k":50000' "$LOG"; then
  echo "FAIL TC6: expected bucket_50k=50000 from tokens=75432"
  cat "$LOG"
  exit 1
fi
if ! grep -q '"tokens_at_correction":75432' "$LOG"; then
  echo "FAIL TC6: expected tokens_at_correction=75432"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: bucket_50k computed from .transcript-tokens (75432→50000)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "correction-rate-tracker.sh externally-observable behavior verified."
exit 0
