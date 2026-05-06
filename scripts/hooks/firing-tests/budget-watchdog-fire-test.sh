#!/usr/bin/env bash
# Firing-test for budget-watchdog.sh (Phase 3.5 T7 retrofit; S59).
#
# Hook purpose (PostToolUse + Stop): read transcript JSONL, compute real token
# usage via node, fire wind-down/cliff auto-reboot at thresholds. Mode-C guard
# (Stop only) blocks premature turn-end when LLM cites budget pressure but real
# tokens well under threshold.
#
# Test strategy: stage temp PROJECT_DIR with stubbed session-self-reboot.sh +
# current-execution.md fixture + transcript JSONL containing `usage` records;
# pipe stdin JSON simulating PostToolUse / Stop payload; assert observable
# state changes (.transcript-tokens, marker files, stdout decision JSON,
# .session-hooks.log entries).
#
# 6 test cases:
#   TC1 — STOCKFORGE_WATCHDOG_DISABLE=1 → silent (no .transcript-tokens written)
#   TC2 — empty transcript_path → silent
#   TC3 — normal token compute → .transcript-tokens written + log entry
#   TC4 — TOTAL ≥ CLIFF → .cliff-fired marker created (atomic noclobber claim)
#   TC5 — Mode-C guard fires (Stop + autonomous_mode=true + TOTAL<SOFT_LIMIT
#         + no .wind-down marker + transcript tail has premature-windown verb)
#         → emit decision block JSON to stdout
#   TC6 — Mode-C guard does NOT fire when TOTAL ≥ SOFT_LIMIT (verb match alone
#         is insufficient if real tokens are above threshold)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../budget-watchdog.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Need node (hook depends on it for JSONL parse). Bail-skip if absent.
if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available — budget-watchdog hook depends on node for transcript parse"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

stub_reboot_script() {
  mkdir -p "$TEMPDIR/scripts"
  cat > "$TEMPDIR/scripts/session-self-reboot.sh" <<'EOF'
#!/usr/bin/env bash
# Stub for firing-test — record invocation, exit success.
echo "STUB-REBOOT-INVOKED args=$*" >&2
exit 0
EOF
  chmod +x "$TEMPDIR/scripts/session-self-reboot.sh"
}

write_transcript() {
  local input_tokens="$1"
  local extra_content="${2:-}"
  local fixture_path="$TEMPDIR/transcript.jsonl"
  cat > "$fixture_path" <<EOF
{"role":"system","content":"setup"}
{"role":"assistant","message":{"usage":{"input_tokens":$input_tokens,"cache_creation_input_tokens":0,"cache_read_input_tokens":0}}}
EOF
  if [ -n "$extra_content" ]; then
    printf '%s\n' "$extra_content" >> "$fixture_path"
  fi
  echo "$fixture_path"
}

write_exec_with_autonomous() {
  local mode_value="${1:-true}"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
  cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**autonomous_mode**: $mode_value
EOF
}

run_hook_payload() {
  local payload="$1"
  local disable="${2:-0}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" STOCKFORGE_WATCHDOG_DISABLE="$disable" \
    bash "$HOOK" <<< "$payload" 2>/dev/null
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/transcript.jsonl" "$TEMPDIR/scripts"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
  stub_reboot_script
}

# --- TC1: STOCKFORGE_WATCHDOG_DISABLE=1 → silent ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript "100000")
PAYLOAD=$(printf '{"session_id":"tc1","transcript_path":"%s","hook_event_name":"PostToolUse"}' "$TRANSCRIPT_FILE")
STDOUT=$(run_hook_payload "$PAYLOAD" "1")
if [ -n "$STDOUT" ]; then
  echo "FAIL TC1: WATCHDOG_DISABLE=1 should produce no stdout"; echo "Got: $STDOUT"
  exit 1
fi
if [ -f "$TEMPDIR/agent-workspace/memory/.transcript-tokens" ]; then
  echo "FAIL TC1: WATCHDOG_DISABLE=1 should not write .transcript-tokens"
  exit 1
fi
echo "PASS TC1: WATCHDOG_DISABLE=1 → silent (no state mutation)"

# --- TC2: empty transcript_path → silent (early bail before token compute) ---
clean_state
write_exec_with_autonomous "true"
PAYLOAD='{"session_id":"tc2","transcript_path":"","hook_event_name":"PostToolUse"}'
STDOUT=$(run_hook_payload "$PAYLOAD")
if [ -f "$TEMPDIR/agent-workspace/memory/.transcript-tokens" ]; then
  echo "FAIL TC2: empty transcript_path should not write .transcript-tokens"
  exit 1
fi
echo "PASS TC2: empty transcript_path → silent (early bail)"

# --- TC3: normal compute → .transcript-tokens + log entry ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript "75000")
PAYLOAD=$(printf '{"session_id":"tc3","transcript_path":"%s","hook_event_name":"PostToolUse"}' "$TRANSCRIPT_FILE")
run_hook_payload "$PAYLOAD" >/dev/null
TOKENS_FILE="$TEMPDIR/agent-workspace/memory/.transcript-tokens"
if [ ! -f "$TOKENS_FILE" ]; then
  echo "FAIL TC3: expected .transcript-tokens to be written"
  exit 1
fi
TOKENS_VAL=$(cat "$TOKENS_FILE")
if [ "$TOKENS_VAL" != "75000" ]; then
  echo "FAIL TC3: expected .transcript-tokens=75000 got '$TOKENS_VAL'"
  exit 1
fi
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
if [ ! -f "$HOOK_LOG" ] || ! grep -q "tokens=75000" "$HOOK_LOG"; then
  echo "FAIL TC3: expected .session-hooks.log to record tokens=75000"
  cat "$HOOK_LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC3: normal compute → .transcript-tokens=75000 + log entry"

# --- TC4: TOTAL ≥ CLIFF → .cliff-fired marker created ---
clean_state
write_exec_with_autonomous "true"
TRANSCRIPT_FILE=$(write_transcript "230000")
PAYLOAD=$(printf '{"session_id":"tc4","transcript_path":"%s","hook_event_name":"PostToolUse"}' "$TRANSCRIPT_FILE")
run_hook_payload "$PAYLOAD" >/dev/null
CLIFF_MARK="$TEMPDIR/agent-workspace/memory/.cliff-fired"
if [ ! -f "$CLIFF_MARK" ]; then
  echo "FAIL TC4: expected .cliff-fired marker"
  ls "$TEMPDIR/agent-workspace/memory/" 2>&1
  exit 1
fi
if ! grep -q "tokens=230000" "$CLIFF_MARK"; then
  echo "FAIL TC4: .cliff-fired should record tokens=230000"
  cat "$CLIFF_MARK"
  exit 1
fi
echo "PASS TC4: TOTAL ≥ CLIFF → .cliff-fired marker created"

# --- TC5: Mode-C guard fires (Stop + autonomous + low tokens + verb hint) ---
clean_state
write_exec_with_autonomous "true"
# TOTAL = 50000 (well under SOFT_LIMIT 160000); transcript tail has "wind down threshold" verb.
TRANSCRIPT_FILE=$(write_transcript "50000" '{"role":"assistant","content":[{"type":"text","text":"approaching wind down threshold; need to start summarizing now"}]}')
PAYLOAD=$(printf '{"session_id":"tc5","transcript_path":"%s","hook_event_name":"Stop"}' "$TRANSCRIPT_FILE")
STDOUT=$(run_hook_payload "$PAYLOAD")
if [ -z "$STDOUT" ]; then
  echo "FAIL TC5: Mode-C guard should emit decision block JSON"
  exit 1
fi
if ! printf '%s' "$STDOUT" | grep -q '"decision":"block"'; then
  echo "FAIL TC5: stdout should contain '\"decision\":\"block\"'"
  echo "Got: $STDOUT"
  exit 1
fi
if ! printf '%s' "$STDOUT" | grep -q "MODE-C GUARD"; then
  echo "FAIL TC5: stdout should reference MODE-C GUARD"
  echo "Got: $STDOUT"
  exit 1
fi
echo "PASS TC5: Mode-C guard fires (low tokens + verb hint) → block JSON"

# --- TC6: Mode-C guard does NOT fire when TOTAL ≥ SOFT_LIMIT ---
clean_state
write_exec_with_autonomous "true"
# TOTAL = 170000 (>= SOFT_LIMIT 160000); same verb hint present.
TRANSCRIPT_FILE=$(write_transcript "170000" '{"role":"assistant","content":[{"type":"text","text":"approaching wind down threshold; need to start summarizing now"}]}')
PAYLOAD=$(printf '{"session_id":"tc6","transcript_path":"%s","hook_event_name":"Stop"}' "$TRANSCRIPT_FILE")
STDOUT=$(run_hook_payload "$PAYLOAD")
if [ -n "$STDOUT" ] && printf '%s' "$STDOUT" | grep -q '"decision":"block"'; then
  echo "FAIL TC6: Mode-C should NOT block when real tokens (170000) >= SOFT_LIMIT (160000)"
  echo "Got: $STDOUT"
  exit 1
fi
echo "PASS TC6: TOTAL >= SOFT_LIMIT → Mode-C guard does NOT fire (real budget pressure legit)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "budget-watchdog.sh externally-observable behavior verified."
exit 0
