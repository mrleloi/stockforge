#!/usr/bin/env bash
# Firing-test for userprompt-invariants-injector.sh (Phase 3.5 T7 retrofit; S61).
# Updated S186 D-043 — SKIP path now emits minimal hookSpecificOutput JSON with
# empty additionalContext so Windows UserPromptSubmit hook chain advances past
# this hook to next chain entry (stale-prompt-detector → in-flight-subagent-watcher → …).
#
# Hook purpose (D-002 Track 5 REV-2 § B UserPromptSubmit): prepend stockforge
# invariants reminder via additionalContext for non-trivial user prompts. For
# trivial prompts (continue/ok/yes/etc) emit minimal empty-additionalContext JSON
# so the chain advances without injecting per-prompt context.
#
# Test strategy: pipe varying UserPromptSubmit JSON payloads; assert exit
# code, stdout JSON shape + content, log entry contents.
#
# 7 test cases:
#   TC1 — trivial "continue" → minimal JSON (additionalContext="") + SKIP log
#   TC2 — trivial "ok" → minimal JSON (additionalContext="") + SKIP log
#   TC3 — Vietnamese trivial "tiếp" → minimal JSON (additionalContext="") + SKIP log
#   TC4 — non-trivial "implement BC-7 sentiment" → JSON with reminder
#   TC5 — empty prompt → graceful (no error)
#   TC6 — long non-trivial prompt → injection + length logged
#   TC7 — S186 chain-continuation contract — SKIP-path JSON shape exactly matches
#         {hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:""}}
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

# Assert that OUT is valid JSON whose additionalContext field is exactly the empty string.
# Used for SKIP-path TCs (TC1, TC2, TC3). Uses file-based stdin to avoid shell-escape issues.
assert_skip_path_json() {
  local out="$1"
  local label="$2"
  if [ -z "$out" ]; then
    echo "FAIL $label: SKIP path expected minimal JSON output; got empty stdout"
    return 1
  fi
  local out_file="$TEMPDIR/_assert_in.json"
  printf '%s' "$out" > "$out_file"
  local marker
  marker=$(node -e "
    const fs = require('fs');
    const s = fs.readFileSync(process.argv[1], 'utf8');
    try {
      const j = JSON.parse(s);
      if (!j.hookSpecificOutput) { console.log('__NO_HSO__'); process.exit(0); }
      if (j.hookSpecificOutput.hookEventName !== 'UserPromptSubmit') { console.log('__BAD_EVENT__'); process.exit(0); }
      console.log(j.hookSpecificOutput.additionalContext === '' ? '__EMPTY__' : '__NON_EMPTY__');
    } catch (e) { console.log('__PARSE_ERR__:' + e.message); }
  " "$out_file" 2>/dev/null)
  if [ "$marker" != "__EMPTY__" ]; then
    echo "FAIL $label: SKIP-path JSON expected additionalContext=\"\" (empty); got marker=$marker"
    echo "  raw output: $out"
    return 1
  fi
  return 0
}

# --- TC1: trivial "continue" → minimal JSON (additionalContext="") + SKIP log ---
clean_state
PAYLOAD='{"prompt":"continue"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if echo "$OUT" | grep -q "STOCKFORGE INVARIANTS REMINDER"; then
  echo "FAIL TC1: trivial 'continue' should NOT inject invariants reminder"
  echo "$OUT"
  exit 1
fi
if ! assert_skip_path_json "$OUT" "TC1"; then exit 1; fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: expected 'SKIP (trivial' in log"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC1: trivial 'continue' → minimal JSON (additionalContext=\"\") + SKIP log"

# --- TC2: trivial "ok" → minimal JSON + SKIP log ---
clean_state
PAYLOAD='{"prompt":"ok"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if echo "$OUT" | grep -q "STOCKFORGE INVARIANTS REMINDER"; then
  echo "FAIL TC2: trivial 'ok' should NOT inject invariants reminder"
  echo "$OUT"
  exit 1
fi
if ! assert_skip_path_json "$OUT" "TC2"; then exit 1; fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected 'SKIP (trivial' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: trivial 'ok' → minimal JSON + SKIP log"

# --- TC3: Vietnamese trivial "tiếp" → minimal JSON + SKIP log ---
clean_state
PAYLOAD='{"prompt":"tiếp"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
if echo "$OUT" | grep -q "STOCKFORGE INVARIANTS REMINDER"; then
  echo "FAIL TC3: trivial 'tiếp' should NOT inject invariants reminder"
  echo "$OUT"
  exit 1
fi
if ! assert_skip_path_json "$OUT" "TC3"; then exit 1; fi
if ! grep -q "SKIP (trivial" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected 'SKIP (trivial' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: Vietnamese 'tiếp' → minimal JSON + SKIP log"

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

# --- TC7: S186 chain-continuation contract — exact JSON shape on SKIP path ---
# Verifies the explicit hypothesis: SKIP-path emits hookSpecificOutput JSON with
# hookEventName="UserPromptSubmit" + additionalContext="" so Windows hook chain
# advances past this hook. If this assertion regresses, the S186 fix is broken
# and downstream hooks (stale-prompt-detector etc.) will stop firing in production.
clean_state
PAYLOAD='{"prompt":"yes"}'
OUT=$(run_hook_with_payload "$PAYLOAD")
TC7_FILE="$TEMPDIR/_tc7_in.json"
printf '%s' "$OUT" > "$TC7_FILE"
SHAPE_CHECK=$(node -e "
  const fs = require('fs');
  const s = fs.readFileSync(process.argv[1], 'utf8');
  try {
    const j = JSON.parse(s);
    const hso = j.hookSpecificOutput;
    if (!hso) { console.log('FAIL: missing hookSpecificOutput'); process.exit(0); }
    if (hso.hookEventName !== 'UserPromptSubmit') { console.log('FAIL: wrong hookEventName=' + hso.hookEventName); process.exit(0); }
    if (typeof hso.additionalContext !== 'string') { console.log('FAIL: additionalContext not string'); process.exit(0); }
    if (hso.additionalContext !== '') { console.log('FAIL: additionalContext not empty'); process.exit(0); }
    const keys = Object.keys(hso).sort().join(',');
    if (keys !== 'additionalContext,hookEventName') { console.log('FAIL: unexpected keys=' + keys); process.exit(0); }
    console.log('OK');
  } catch (e) { console.log('FAIL: JSON parse error: ' + e.message); }
" "$TC7_FILE" 2>/dev/null)
if [ "$SHAPE_CHECK" != "OK" ]; then
  echo "FAIL TC7: S186 chain-continuation contract violated; got: $SHAPE_CHECK"
  echo "  raw output: $OUT"
  exit 1
fi
echo "PASS TC7: S186 chain-continuation contract — exact JSON shape on SKIP path"

echo ""
echo "=== ALL FIRING-TESTS PASSED (7/7) ==="
echo "userprompt-invariants-injector.sh externally-observable behavior verified."
echo "S186 D-043 chain-continuation JSON emission verified on SKIP path."
exit 0
