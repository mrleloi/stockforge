#!/usr/bin/env bash
# Firing-test for userprompt-invariants-injector.sh (Phase 3.5 T7 retrofit; S61).
#
# Hook purpose (D-002 Track 5 REV-2 § B UserPromptSubmit): prepend stockforge
# invariants reminder via additionalContext for non-trivial user prompts.
# Skip injection when prompt matches trivial regex (continue/ok/yes/etc).
#
# Test strategy: pipe varying UserPromptSubmit JSON payloads; assert exit
# code, stdout JSON content, log entry contents.
#
# 6 test cases:
#   TC1 — trivial "continue" → SKIP log (no JSON output)
#   TC2 — trivial "ok" → SKIP log
#   TC3 — Vietnamese trivial "tiếp" → SKIP log (not in regex; SHOULD inject)
#   TC4 — non-trivial "implement BC-7 sentiment" → JSON with reminder
#   TC5 — empty prompt → graceful (no error)
#   TC6 — long non-trivial prompt → injection + length logged
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../userprompt-invariants-injector.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available; cannot test userprompt-invariants-injector"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook_with_payload() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" 2>/dev/null
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: trivial "continue" → SKIP log (no JSON output) ---
clean_state
PAYLOAD='{"prompt":"continue"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if [ -n "$OUT" ] && echo "$OUT" | grep -q "additionalContext"; then
  echo "FAIL TC1: trivial 'continue' should NOT inject; got JSON output:"
  echo "$OUT"
  exit 1
fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: expected 'SKIP (trivial' in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC1: trivial 'continue' → SKIP (no JSON output)"

# --- TC2: trivial "ok" → SKIP log ---
clean_state
PAYLOAD='{"prompt":"ok"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if echo "$OUT" | grep -q "additionalContext"; then
  echo "FAIL TC2: trivial 'ok' should NOT inject"
  echo "$OUT"
  exit 1
fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected 'SKIP (trivial' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: trivial 'ok' → SKIP"

# --- TC3: Vietnamese trivial "tiếp" → SKIP log ---
clean_state
PAYLOAD='{"prompt":"tiếp"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if echo "$OUT" | grep -q "additionalContext"; then
  echo "FAIL TC3: trivial 'tiếp' should NOT inject (in TRIVIAL_REGEX)"
  echo "$OUT"
  exit 1
fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected 'SKIP (trivial' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: Vietnamese 'tiếp' → SKIP"

# --- TC4: non-trivial → JSON with invariants reminder ---
clean_state
PAYLOAD='{"prompt":"implement BC-7 sentiment ingestion via cafef adapter"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if ! echo "$OUT" | grep -q "additionalContext"; then
  echo "FAIL TC4: non-trivial prompt should emit JSON with additionalContext"
  echo "$OUT"
  exit 1
fi
if ! echo "$OUT" | grep -q "I-S1"; then
  echo "FAIL TC4: invariants reminder should mention I-S1"
  echo "$OUT"
  exit 1
fi
if ! grep -q "invariants reminder injected" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected 'invariants reminder injected' log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: non-trivial prompt → JSON + invariants reminder"

# --- TC5: empty prompt → graceful ---
clean_state
PAYLOAD='{"prompt":""}'
RC=0
OUT=$(run_hook_with_payload "$PAYLOAD") || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: empty prompt should not error; got rc=$RC"
  exit 1
fi
echo "PASS TC5: empty prompt → graceful (no error)"

# --- TC6: long non-trivial prompt → injection + length logged ---
clean_state
LONG_TEXT="$(printf 'word %.0s' {1..50})"
PAYLOAD="{\"prompt\":\"$LONG_TEXT\"}"
OUT=$(run_hook_with_payload "$PAYLOAD")
if ! echo "$OUT" | grep -q "additionalContext"; then
  echo "FAIL TC6: long non-trivial prompt should still inject"
  exit 1
fi
if ! grep -qE "prompt_len=[0-9]+" "$LOG" 2>/dev/null; then
  echo "FAIL TC6: expected prompt_len=N in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: long non-trivial prompt → injection + length logged"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "userprompt-invariants-injector.sh externally-observable behavior verified."
exit 0
