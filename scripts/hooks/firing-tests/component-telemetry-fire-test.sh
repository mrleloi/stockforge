#!/usr/bin/env bash
# component-telemetry-fire-test.sh — companion firing-test per L-S51-1.
# Tests externally-observable behavior per L-S59-1:
#   - JSONL line appended to component-telemetry.jsonl
#   - tokens_real field captured (D3 check)
#   - cache_read_tokens + cache_creation_tokens fields present (D3 new fields)
# L-S59-2: two-stage grep for multi-field assertions.
# L-S62-1: no yes|head patterns.
# 10 TCs: 6 baseline + 4 new D3 TCs (TC-G through TC-J).
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available; cannot test component-telemetry"
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../component-telemetry.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
TELEMETRY_FILE="$PROJECT_DIR/agent-workspace/memory/component-telemetry.jsonl"
TOKENS_FILE="$PROJECT_DIR/agent-workspace/memory/.transcript-tokens"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PASS=0
FAIL=0

run_hook() {
  local payload="$1"
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$payload" 2>/dev/null || true
  # Hook forks background; wait briefly
  sleep 1
}

clean_state() {
  rm -f "$TELEMETRY_FILE"
  rm -f "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens"
  rm -f "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens-prev"
  rm -f "$PROJECT_DIR/agent-workspace/memory/.last-event-ts-"*
}

# -----------------------------------------------------------------------
# BASELINE TCs (existing expected behavior)
# -----------------------------------------------------------------------

# TC1 — PostToolUse Read → JSONL line appended with component_type:hook
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tc1-sess","tool_name":"Read","tool_use_id":"tc1-tid"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"component_type"' "$TELEMETRY_FILE"; then
  echo "PASS TC1: PostToolUse → JSONL line appended"
  PASS=$((PASS+1))
else
  echo "FAIL TC1: no JSONL line appended for PostToolUse"
  FAIL=$((FAIL+1))
fi

# TC2 — SessionStart → line appended with component_name:SessionStart
clean_state
PAYLOAD='{"hook_event_name":"SessionStart","session_id":"tc2-sess"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"component_name":"SessionStart"' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC2: SessionStart → component_name:SessionStart in JSONL"
  PASS=$((PASS+1))
else
  echo "FAIL TC2: no SessionStart line found"
  cat "$TELEMETRY_FILE" 2>/dev/null | head -3 || true
  FAIL=$((FAIL+1))
fi

# TC3 — Outcome:reject when decision=deny
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tc3-sess","tool_name":"Write","decision":"deny"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"outcome":"reject"' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC3: decision=deny → outcome:reject in JSONL"
  PASS=$((PASS+1))
else
  echo "FAIL TC3: deny decision not reflected in outcome"
  cat "$TELEMETRY_FILE" 2>/dev/null | head -3 || true
  FAIL=$((FAIL+1))
fi

# TC4 — Agent PostToolUse → component_type:agent
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tc4-sess","tool_name":"Agent","tool_input":{"subagent_type":"sandwich-dev"}}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"component_type":"agent"' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC4: Agent PostToolUse → component_type:agent"
  PASS=$((PASS+1))
else
  echo "FAIL TC4: expected component_type:agent"
  FAIL=$((FAIL+1))
fi

# TC5 — tokens_real computed from .transcript-tokens delta
clean_state
printf '5000\n' > "$TOKENS_FILE"
printf '3000\n' > "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens-prev"
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tc5-sess","tool_name":"Read"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"tokens_real":2000' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC5: tokens_real delta computed (5000-3000=2000)"
  PASS=$((PASS+1))
else
  echo "FAIL TC5: tokens_real not 2000"
  cat "$TELEMETRY_FILE" 2>/dev/null | head -3 || true
  FAIL=$((FAIL+1))
fi

# TC6 — SubagentStop → component_type:agent
clean_state
PAYLOAD='{"hook_event_name":"SubagentStop","session_id":"tc6-sess","status":"DONE"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"component_type":"agent"' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC6: SubagentStop → component_type:agent in JSONL"
  PASS=$((PASS+1))
else
  echo "FAIL TC6: expected component_type:agent for SubagentStop"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# D3 NEW TCs (Plan 011)
# -----------------------------------------------------------------------

# TC-G — env vars CLAUDE_TOKENS_CACHE_READ + CLAUDE_TOKENS_CACHE_CREATION present → captured
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tcg-sess","tool_name":"Read"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_TOKENS_CACHE_READ=1500 CLAUDE_TOKENS_CACHE_CREATION=3000 \
  bash "$HOOK" <<< "$PAYLOAD" 2>/dev/null || true
sleep 1
if [ -f "$TELEMETRY_FILE" ] && grep -q '"cache_read_tokens":1500' "$TELEMETRY_FILE" 2>/dev/null; then
  # Two-stage: also check cache_creation_tokens
  if grep '"cache_read_tokens":1500' "$TELEMETRY_FILE" | grep -q '"cache_creation_tokens":3000'; then
    echo "PASS TC-G: env vars captured → cache_read_tokens:1500 + cache_creation_tokens:3000"
    PASS=$((PASS+1))
  else
    echo "FAIL TC-G: cache_read_tokens found but cache_creation_tokens:3000 missing"
    cat "$TELEMETRY_FILE" | tail -1 || true
    FAIL=$((FAIL+1))
  fi
else
  echo "FAIL TC-G: cache_read_tokens:1500 not found in JSONL"
  cat "$TELEMETRY_FILE" 2>/dev/null | tail -1 || true
  FAIL=$((FAIL+1))
fi

# TC-H — env vars unavailable → fallback works (cache fields default to 0)
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tch-sess","tool_name":"Bash"}'
# Explicitly unset cache env vars
env -u CLAUDE_TOKENS_CACHE_READ -u CLAUDE_TOKENS_CACHE_CREATION \
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD" 2>/dev/null || true
sleep 1
if [ -f "$TELEMETRY_FILE" ] && grep -q '"cache_read_tokens":0' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC-H: env vars unavailable → cache fields default to 0"
  PASS=$((PASS+1))
else
  echo "FAIL TC-H: cache_read_tokens:0 not found when env vars absent"
  cat "$TELEMETRY_FILE" 2>/dev/null | tail -1 || true
  FAIL=$((FAIL+1))
fi

# TC-I — cache fields populated in output JSON (schema check)
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tci-sess","tool_name":"Write"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_TOKENS_CACHE_READ=500 CLAUDE_TOKENS_CACHE_CREATION=1000 \
  bash "$HOOK" <<< "$PAYLOAD" 2>/dev/null || true
sleep 1
if [ -f "$TELEMETRY_FILE" ]; then
  LAST_LINE="$(tail -1 "$TELEMETRY_FILE" 2>/dev/null || true)"
  if printf '%s' "$LAST_LINE" | grep -q '"cache_read_tokens"' && \
     printf '%s' "$LAST_LINE" | grep -q '"cache_creation_tokens"'; then
    echo "PASS TC-I: both cache field keys present in output JSON"
    PASS=$((PASS+1))
  else
    echo "FAIL TC-I: cache_read_tokens or cache_creation_tokens key missing from JSON"
    printf '%s\n' "$LAST_LINE"
    FAIL=$((FAIL+1))
  fi
else
  echo "FAIL TC-I: telemetry file not created"
  FAIL=$((FAIL+1))
fi

# TC-J — re-run baseline TCs 1-6 pass after D3 changes (no regression)
# Re-run TC1 as regression check
clean_state
PAYLOAD='{"hook_event_name":"PostToolUse","session_id":"tcj-sess","tool_name":"Read"}'
run_hook "$PAYLOAD"
if [ -f "$TELEMETRY_FILE" ] && grep -q '"component_type"' "$TELEMETRY_FILE" 2>/dev/null; then
  echo "PASS TC-J: regression check — baseline TC1 still PASS after D3 changes"
  PASS=$((PASS+1))
else
  echo "FAIL TC-J: baseline TC1 REGRESSION after D3 changes"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL (10 TCs: 6 baseline + 4 new D3) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
