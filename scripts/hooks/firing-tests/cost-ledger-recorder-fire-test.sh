#!/usr/bin/env bash
# cost-ledger-recorder-fire-test.sh — companion firing-test per L-S51-1
# Tests externally-observable behavior: cost-ledger.tsv row append + USD compute
set -uo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available" >&2; exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/cost-ledger-recorder.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
LEDGER="$PROJECT_DIR/agent-workspace/memory/cost-ledger.tsv"
TRANSCRIPT="$TEMPDIR/transcript.jsonl"
mkdir -p "$(dirname "$LEDGER")"

PASS=0
FAIL=0

# Synthetic transcript: opus model, 100K input + 20K output
cat > "$TRANSCRIPT" <<'EOF'
{"message":{"model":"claude-opus-4-7","usage":{"input_tokens":100000,"output_tokens":20000,"cache_read_input_tokens":0,"cache_creation_input_tokens":0}}}
EOF

# TC1: Stop hook with valid transcript → row appended; cost ~ 100*15 + 20*75 = $1500+$1500 = $3.000
PAYLOAD_TC1="{\"hook_event_name\":\"Stop\",\"session_id\":\"test-session-tc1\",\"transcript_path\":\"$TRANSCRIPT\"}"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if [ -f "$LEDGER" ] && grep -q "test-session-tc1" "$LEDGER"; then
  COST_TC1=$(grep "test-session-tc1" "$LEDGER" | tail -1 | cut -f9)
  if awk -v c="$COST_TC1" 'BEGIN{exit !(c >= 2.99 && c <= 3.01)}'; then
    echo "  TC TC1-stop-opus-100k20k: PASS (cost=$COST_TC1)"; PASS=$((PASS+1))
  else
    echo "  TC TC1-stop-opus-100k20k: FAIL — cost $COST_TC1 not in [2.99,3.01]"; FAIL=$((FAIL+1))
  fi
else
  echo "  TC TC1-stop-opus-100k20k: FAIL — no row appended"; FAIL=$((FAIL+1))
fi

# TC2: Header present
if head -1 "$LEDGER" | grep -q "timestamp.*session_id.*actor.*model.*cost_usd"; then
  echo "  TC TC2-header-present: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-header-present: FAIL"; FAIL=$((FAIL+1))
fi

# TC3: SubagentStop with sandwich-architect → actor=sub:sandwich-architect; sonnet model 50K/10K
cat > "$TRANSCRIPT" <<'EOF'
{"message":{"model":"claude-sonnet-4-6","usage":{"input_tokens":50000,"output_tokens":10000}}}
EOF
PAYLOAD_TC3="{\"hook_event_name\":\"SubagentStop\",\"session_id\":\"test-session-tc3\",\"tool_input\":{\"subagent_type\":\"sandwich-architect\"},\"transcript_path\":\"$TRANSCRIPT\"}"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC3" 2>&1 || true
if grep -q "test-session-tc3.*sub:sandwich-architect" "$LEDGER"; then
  COST_TC3=$(grep "test-session-tc3" "$LEDGER" | tail -1 | cut -f9)
  # 50*3 + 10*15 = $150 + $150 = $0.300
  if awk -v c="$COST_TC3" 'BEGIN{exit !(c >= 0.299 && c <= 0.301)}'; then
    echo "  TC TC3-subagent-sonnet: PASS (cost=$COST_TC3)"; PASS=$((PASS+1))
  else
    echo "  TC TC3-subagent-sonnet: FAIL — cost $COST_TC3 not in [0.299,0.301]"; FAIL=$((FAIL+1))
  fi
else
  echo "  TC TC3-subagent-sonnet: FAIL — no row with sub:sandwich-architect"; FAIL=$((FAIL+1))
fi

# TC4: Haiku model with cache_read → cost reduced
cat > "$TRANSCRIPT" <<'EOF'
{"message":{"model":"claude-haiku-4-5-20251001","usage":{"input_tokens":10000,"output_tokens":2000,"cache_read_input_tokens":50000}}}
EOF
PAYLOAD_TC4="{\"hook_event_name\":\"Stop\",\"session_id\":\"test-session-tc4\",\"transcript_path\":\"$TRANSCRIPT\"}"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC4" 2>&1 || true
if grep -q "test-session-tc4.*haiku" "$LEDGER"; then
  echo "  TC TC4-haiku-with-cache: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-haiku-with-cache: FAIL — no haiku row"; FAIL=$((FAIL+1))
fi

# TC5: Non-Stop/SubagentStop hook event → no append
ROWS_BEFORE=$(wc -l < "$LEDGER")
PAYLOAD_TC5='{"hook_event_name":"PreToolUse","tool_name":"Read","session_id":"test-session-tc5"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC5" 2>&1 || true
ROWS_AFTER=$(wc -l < "$LEDGER")
if [ "$ROWS_BEFORE" = "$ROWS_AFTER" ]; then
  echo "  TC TC5-non-stop-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-non-stop-skip: FAIL — rows changed $ROWS_BEFORE→$ROWS_AFTER"; FAIL=$((FAIL+1))
fi

# TC6: Empty transcript → no append (skip if zero tokens)
cat > "$TRANSCRIPT" <<'EOF'
{}
EOF
ROWS_BEFORE=$(wc -l < "$LEDGER")
PAYLOAD_TC6="{\"hook_event_name\":\"Stop\",\"session_id\":\"test-session-tc6\",\"transcript_path\":\"$TRANSCRIPT\"}"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC6" 2>&1 || true
ROWS_AFTER=$(wc -l < "$LEDGER")
if [ "$ROWS_BEFORE" = "$ROWS_AFTER" ]; then
  echo "  TC TC6-empty-transcript-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-empty-transcript-skip: FAIL"; FAIL=$((FAIL+1))
fi

# TC7: Empty payload → silent
ROWS_BEFORE=$(wc -l < "$LEDGER")
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "" 2>&1 || true
ROWS_AFTER=$(wc -l < "$LEDGER")
if [ "$ROWS_BEFORE" = "$ROWS_AFTER" ]; then
  echo "  TC TC7-empty-payload-silent: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-empty-payload-silent: FAIL"; FAIL=$((FAIL+1))
fi

# TC8: Idempotent — multiple calls add multiple rows (append-only audit trail)
ROWS_BEFORE=$(wc -l < "$LEDGER")
cat > "$TRANSCRIPT" <<'EOF'
{"message":{"model":"claude-opus-4-7","usage":{"input_tokens":1000,"output_tokens":200}}}
EOF
PAYLOAD_TC8="{\"hook_event_name\":\"Stop\",\"session_id\":\"test-session-tc8\",\"transcript_path\":\"$TRANSCRIPT\"}"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC8" 2>&1 || true
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC8" 2>&1 || true
ROWS_AFTER=$(wc -l < "$LEDGER")
DELTA=$((ROWS_AFTER - ROWS_BEFORE))
if [ "$DELTA" = "2" ]; then
  echo "  TC TC8-append-only-2x: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-append-only-2x: FAIL — expected delta 2, got $DELTA"; FAIL=$((FAIL+1))
fi

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
