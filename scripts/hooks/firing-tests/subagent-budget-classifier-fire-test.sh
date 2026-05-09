#!/usr/bin/env bash
# subagent-budget-classifier-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2 retro-fit
# REAL-STATE-DERIVED per L-S176-1: parent hook is PostToolUse(Agent) classifier; reads JSON payload from stdin
# (tool_input.prompt + tool_response.usage.{input,cache_read,cache_creation}_tokens); soft-warns on overshoot.
# S35 D4 (per L-S25-1 architect-overshoot calibration). Envelopes: spec-frame 200K / pure-plan 80K /
# verifier-whole-phase 150K / verifier-sub-track 80K / general 80K.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/subagent-budget-classifier.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.subagent-budget.log"

PASS=0
FAIL=0

# Helper: build JSON payload with prompt and tokens
build_payload() {
  local prompt="$1" input_tokens="$2"
  printf '{"tool_input":{"prompt":"%s"},"tool_response":{"usage":{"input_tokens":%s,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}' \
    "$prompt" "$input_tokens"
}

run_classifier() {
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1
}

# TC1: empty PROMPT → exit 0 no-op (line 30 guard)
out=$(printf '{"tool_input":{"prompt":""},"tool_response":{"usage":{"input_tokens":50000}}}' | run_classifier)
rc=$?
if [ "$rc" = 0 ] && [ ! -f "$LOG" ]; then
  echo "  TC TC1-empty-prompt-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-empty-prompt-noop: FAIL — rc=$rc log_exists=$([ -f "$LOG" ] && echo yes || echo no)"
  FAIL=$((FAIL+1))
fi

# TC2: zero TOKENS → exit 0 no-op (line 31 guard)
rm -f "$LOG"
out=$(build_payload "spec-author dispatch" 0 | run_classifier)
rc=$?
if [ "$rc" = 0 ] && [ ! -f "$LOG" ]; then
  echo "  TC TC2-zero-tokens-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-zero-tokens-noop: FAIL — rc=$rc"
  FAIL=$((FAIL+1))
fi

# TC3: spec-author keyword + tokens within env (180K < warn 220K) → log line classified=architect-spec-frame, no stderr WARN
rm -f "$LOG"
out=$(build_payload "spec-author dispatch — drill-me glossary work" 180000 | run_classifier 2>&1)
rc=$?
if [ "$rc" = 0 ] && [ -f "$LOG" ] && grep -q 'classified=architect-spec-frame' "$LOG" && ! printf '%s' "$out" | grep -q 'WARN:'; then
  echo "  TC TC3-spec-frame-within-env: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-spec-frame-within-env: FAIL — rc=$rc log=$(cat "$LOG" 2>/dev/null) out=$out"
  FAIL=$((FAIL+1))
fi

# TC4: master-plan keyword + tokens over warn (110K > 100K) → WARN to stderr
rm -f "$LOG"
out=$(build_payload "master-plan: track sequencing" 110000 | run_classifier 2>&1)
rc=$?
if [ "$rc" = 0 ] && grep -q 'classified=architect-pure-plan' "$LOG" && printf '%s' "$out" | grep -q 'subagent-budget WARN'; then
  echo "  TC TC4-pure-plan-overshoot-warn: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-pure-plan-overshoot-warn: FAIL — rc=$rc log=$(cat "$LOG" 2>/dev/null) out=$out"
  FAIL=$((FAIL+1))
fi

# TC5: verifier-whole-phase keyword + tokens within env (140K < 150K) → classified=verifier-whole-phase
rm -f "$LOG"
out=$(build_payload "verifier whole-phase 10 V dim Phase 1 close" 140000 | run_classifier 2>&1)
rc=$?
if [ "$rc" = 0 ] && grep -q 'classified=verifier-whole-phase' "$LOG"; then
  echo "  TC TC5-verifier-whole-phase: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-verifier-whole-phase: FAIL — rc=$rc log=$(cat "$LOG" 2>/dev/null)"
  FAIL=$((FAIL+1))
fi

# TC6: generic prompt → general-purpose classification at 80K target
rm -f "$LOG"
out=$(build_payload "general work without keywords" 70000 | run_classifier 2>&1)
rc=$?
if [ "$rc" = 0 ] && grep -q 'classified=general-purpose' "$LOG"; then
  echo "  TC TC6-general-purpose-default: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-general-purpose-default: FAIL — rc=$rc log=$(cat "$LOG" 2>/dev/null)"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== subagent-budget-classifier firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
