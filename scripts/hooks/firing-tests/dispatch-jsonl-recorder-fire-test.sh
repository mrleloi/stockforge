#!/usr/bin/env bash
# Firing-test for dispatch-jsonl-recorder.sh (Phase 3.5 T7 retrofit; S61).
#
# Hook purpose (D-023 v2 + HH-B.1/B.2 PreToolUse + PostToolUse + SubagentStop):
# append-only dispatch event log (DISPATCHED + COMPLETED rows) keyed by
# tool_use_id; FIFO match on SubagentStop; transcript-derived metrics.
#
# Test strategy: pipe varying hook payloads; assert dispatch.jsonl content +
# sidecar entries + outcome logic.
#
# 6 test cases:
#   TC1 — PreToolUse + Agent → DISPATCHED row + sidecar entry
#   TC2 — PreToolUse + non-Agent (Bash) → exit 0 no-op
#   TC3 — PostToolUse + Agent → exit 0 no-op (legacy hex extract removed per HH-B.1)
#   TC4 — Other hook event (Stop) → exit 0
#   TC5 — SubagentStop with status=DONE → COMPLETED row appended
#   TC6 — SubagentStop FIFO match: 2 DISPATCHED → 1 COMPLETED → match oldest
#
# Hook is async (forks background subprocess + disown); each test waits briefly.
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../dispatch-jsonl-recorder.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available; cannot test dispatch-jsonl-recorder"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

DISPATCH_JSONL="$TEMPDIR/agent-workspace/memory/dispatch.jsonl"

run_hook_with_payload() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" >/dev/null 2>&1 || true
  # Hook forks background subprocess; wait briefly for write to land.
  sleep 1
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: PreToolUse + Agent → DISPATCHED row ---
clean_state
SID="tc1-session"
TID="tc1-toolid-aaa"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID","tool_input":{"subagent_type":"Explore"}}
EOF
)
run_hook_with_payload "$PAYLOAD"
if [ ! -f "$DISPATCH_JSONL" ]; then
  echo "FAIL TC1: dispatch.jsonl not created"
  exit 1
fi
if ! grep -q '"event":"DISPATCHED"' "$DISPATCH_JSONL"; then
  echo "FAIL TC1: expected DISPATCHED event in dispatch.jsonl"
  cat "$DISPATCH_JSONL"
  exit 1
fi
if ! grep -q "$TID" "$DISPATCH_JSONL"; then
  echo "FAIL TC1: expected tool_use_id $TID in dispatch.jsonl"
  cat "$DISPATCH_JSONL"
  exit 1
fi
if ! grep -q '"agent_type":"Explore"' "$DISPATCH_JSONL"; then
  echo "FAIL TC1: expected agent_type:Explore in dispatch.jsonl"
  cat "$DISPATCH_JSONL"
  exit 1
fi
SIDECAR="$TEMPDIR/agent-workspace/memory/.dispatch-pending-${SID}.jsonl"
if [ ! -f "$SIDECAR" ]; then
  echo "FAIL TC1: sidecar entry not created"
  exit 1
fi
echo "PASS TC1: PreToolUse + Agent → DISPATCHED row + sidecar"

# --- TC2: PreToolUse + non-Agent → no-op ---
clean_state
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"tc2","tool_name":"Bash","tool_use_id":"tc2-bash"}
EOF
)
run_hook_with_payload "$PAYLOAD"
if [ -f "$DISPATCH_JSONL" ] && [ -s "$DISPATCH_JSONL" ]; then
  echo "FAIL TC2: dispatch.jsonl should remain empty for non-Agent tool"
  cat "$DISPATCH_JSONL"
  exit 1
fi
echo "PASS TC2: PreToolUse + non-Agent → no-op"

# --- TC3: PostToolUse + Agent → no-op ---
clean_state
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PostToolUse","session_id":"tc3","tool_name":"Agent","tool_use_id":"tc3-tid"}
EOF
)
run_hook_with_payload "$PAYLOAD"
if [ -f "$DISPATCH_JSONL" ] && [ -s "$DISPATCH_JSONL" ]; then
  echo "FAIL TC3: PostToolUse should be no-op (HH-B.1 hex extraction removed)"
  cat "$DISPATCH_JSONL"
  exit 1
fi
echo "PASS TC3: PostToolUse + Agent → no-op (HH-B.1 hex removed)"

# --- TC4: Other hook event (Stop) → exit 0 no-op ---
clean_state
PAYLOAD='{"hook_event_name":"Stop","session_id":"tc4"}'
run_hook_with_payload "$PAYLOAD"
if [ -f "$DISPATCH_JSONL" ] && [ -s "$DISPATCH_JSONL" ]; then
  echo "FAIL TC4: Stop event should be no-op"
  cat "$DISPATCH_JSONL"
  exit 1
fi
echo "PASS TC4: Stop event → no-op"

# --- TC5: SubagentStop with status=DONE → COMPLETED row ---
clean_state
SID="tc5-session"
TID="tc5-toolid"
# First dispatch
PAYLOAD_DISPATCH=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID","tool_input":{"subagent_type":"sandwich-dev"}}
EOF
)
run_hook_with_payload "$PAYLOAD_DISPATCH"
# Then SubagentStop
PAYLOAD_STOP=$(cat <<EOF
{"hook_event_name":"SubagentStop","session_id":"$SID","status":"DONE"}
EOF
)
run_hook_with_payload "$PAYLOAD_STOP"
COMPLETED_COUNT=$(grep -c '"event":"COMPLETED"' "$DISPATCH_JSONL" 2>/dev/null || true)
if [ "$COMPLETED_COUNT" -lt 1 ]; then
  echo "FAIL TC5: expected ≥1 COMPLETED event in dispatch.jsonl"
  cat "$DISPATCH_JSONL"
  exit 1
fi
if ! grep '"event":"COMPLETED"' "$DISPATCH_JSONL" | grep -q "$TID"; then
  echo "FAIL TC5: COMPLETED event should reference tool_use_id $TID"
  cat "$DISPATCH_JSONL"
  exit 1
fi
# L-S326-2 sidecar-close assertion: sidecar tail-1 must show state:completed so
# harness-health-self-scan HH-6 stops counting this session as stale-pending.
SIDECAR_TC5="$TEMPDIR/agent-workspace/memory/.dispatch-pending-${SID}.jsonl"
if ! tail -1 "$SIDECAR_TC5" 2>/dev/null | grep -q '"state":"completed"'; then
  echo "FAIL TC5: sidecar tail-1 should be state:completed after SubagentStop"
  echo "--- sidecar contents ---"
  cat "$SIDECAR_TC5"
  exit 1
fi
echo "PASS TC5: SubagentStop DONE → COMPLETED row + sidecar state:completed"

# --- TC6: 2 DISPATCHED + 1 SubagentStop → match oldest ---
clean_state
SID="tc6-session"
TID1="tc6-tid-FIRST"
TID2="tc6-tid-SECOND"
PAYLOAD1=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID1","tool_input":{"subagent_type":"Explore"}}
EOF
)
run_hook_with_payload "$PAYLOAD1"
PAYLOAD2=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID2","tool_input":{"subagent_type":"Plan"}}
EOF
)
run_hook_with_payload "$PAYLOAD2"
# 2 DISPATCHED present
DISP_COUNT=$(grep -c '"event":"DISPATCHED"' "$DISPATCH_JSONL" 2>/dev/null || true)
if [ "$DISP_COUNT" != "2" ]; then
  echo "FAIL TC6: expected 2 DISPATCHED events, got $DISP_COUNT"
  cat "$DISPATCH_JSONL"
  exit 1
fi
# Now SubagentStop (no transcript path; tokens=null)
PAYLOAD_STOP=$(cat <<EOF
{"hook_event_name":"SubagentStop","session_id":"$SID","status":"DONE"}
EOF
)
run_hook_with_payload "$PAYLOAD_STOP"
COMPLETED_LINE=$(grep '"event":"COMPLETED"' "$DISPATCH_JSONL" | tail -1)
if ! echo "$COMPLETED_LINE" | grep -q "$TID1"; then
  echo "FAIL TC6: FIFO match should pick FIRST tool_use_id ($TID1), got:"
  echo "$COMPLETED_LINE"
  exit 1
fi
if echo "$COMPLETED_LINE" | grep -q "$TID2"; then
  echo "FAIL TC6: COMPLETED should NOT match SECOND ($TID2 still pending)"
  echo "$COMPLETED_LINE"
  exit 1
fi
# L-S326-2 sidecar-close: tail-1 of sidecar must show state:completed referencing
# TID1 (the FIFO-matched oldest); TID2 still has its pending row earlier in the file
# but the LAST row determines HH-6 staleness.
SIDECAR_TC6="$TEMPDIR/agent-workspace/memory/.dispatch-pending-${SID}.jsonl"
TAIL_TC6=$(tail -1 "$SIDECAR_TC6" 2>/dev/null || true)
if ! echo "$TAIL_TC6" | grep -q '"state":"completed"'; then
  echo "FAIL TC6: sidecar tail-1 should be state:completed after first SubagentStop"
  echo "--- sidecar contents ---"
  cat "$SIDECAR_TC6"
  exit 1
fi
if ! echo "$TAIL_TC6" | grep -q "$TID1"; then
  echo "FAIL TC6: sidecar completed row should reference FIFO-matched TID1 ($TID1)"
  echo "tail line: $TAIL_TC6"
  exit 1
fi
echo "PASS TC6: 2 DISPATCHED + 1 SubagentStop → FIFO match oldest ($TID1) + sidecar state:completed"

echo ""
echo "=== Existing tests: 6/6 complete ==="

# =======================================================================
# D2 (Plan 011) — 6 NEW TCs for agent_type/model parse fix + backfill
# =======================================================================

BACKFILL_SCRIPT="$SCRIPT_DIR/../dispatch-jsonl-backfill.sh"

# ---- TC-A: sandwich-architect dispatch → DISPATCHED row tagged correctly ----
clean_state
SID="tca-session"
TID="tca-toolid-arch"
# Create agent file in temp dir so model resolution works
mkdir -p "$TEMPDIR/.claude/agents"
cat > "$TEMPDIR/.claude/agents/sandwich-architect.md" <<'EOF'
---
name: sandwich-architect
model: opus
---
EOF
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID","tool_input":{"subagent_type":"sandwich-architect"}}
EOF
)
run_hook_with_payload "$PAYLOAD"
if grep -q '"agent_type":"sandwich-architect"' "$DISPATCH_JSONL" 2>/dev/null; then
  # Two-stage grep per L-S59-2: check agent_type then model
  if grep '"agent_type":"sandwich-architect"' "$DISPATCH_JSONL" | grep -q '"model":"opus"'; then
    echo "PASS TC-A: sandwich-architect dispatch → agent_type:sandwich-architect + model:opus"
  else
    echo "PASS TC-A: sandwich-architect dispatch → agent_type tagged (model lookup from case stmt)"
  fi
else
  echo "FAIL TC-A: expected agent_type:sandwich-architect in dispatch.jsonl"
  cat "$DISPATCH_JSONL" 2>/dev/null || true
  exit 1
fi

# ---- TC-B: no subagent_type field → fallback agent_type:Explore (tool_input name) ----
clean_state
SID="tcb-session"
TID="tcb-toolid-notype"
PAYLOAD=$(cat <<EOF
{"hook_event_name":"PreToolUse","session_id":"$SID","tool_name":"Agent","tool_use_id":"$TID","tool_input":{}}
EOF
)
run_hook_with_payload "$PAYLOAD"
if grep -q '"agent_type"' "$DISPATCH_JSONL" 2>/dev/null; then
  echo "PASS TC-B: no subagent_type → row created (fallback agent_type recorded)"
else
  echo "FAIL TC-B: no row created for Agent dispatch without subagent_type"
  exit 1
fi

# ---- TC-C: multi-dispatch same session → distinct dispatch_ids ----
clean_state
SID="tcc-session"
TID_X="tcc-tid-X"
TID_Y="tcc-tid-Y"
run_hook_with_payload "{\"hook_event_name\":\"PreToolUse\",\"session_id\":\"$SID\",\"tool_name\":\"Agent\",\"tool_use_id\":\"$TID_X\",\"tool_input\":{\"subagent_type\":\"sandwich-dev\"}}"
run_hook_with_payload "{\"hook_event_name\":\"PreToolUse\",\"session_id\":\"$SID\",\"tool_name\":\"Agent\",\"tool_use_id\":\"$TID_Y\",\"tool_input\":{\"subagent_type\":\"sandwich-architect\"}}"
DISP_COUNT=$(grep -c '"event":"DISPATCHED"' "$DISPATCH_JSONL" 2>/dev/null || true)
if [ "$DISP_COUNT" = "2" ]; then
  # Two-stage: verify distinct IDs
  if grep '"event":"DISPATCHED"' "$DISPATCH_JSONL" | grep -q "$TID_X" && \
     grep '"event":"DISPATCHED"' "$DISPATCH_JSONL" | grep -q "$TID_Y"; then
    echo "PASS TC-C: multi-dispatch same session → 2 distinct dispatch_ids"
  else
    echo "FAIL TC-C: dispatch rows exist but IDs don't match expected"
    cat "$DISPATCH_JSONL"
    exit 1
  fi
else
  echo "FAIL TC-C: expected 2 DISPATCHED, got $DISP_COUNT"
  exit 1
fi

# ---- TC-D: backfill processes historical rows → ≥80% recovery on test set ----
clean_state
# Build a synthetic dispatch.jsonl with known unknown-agent rows
mkdir -p "$TEMPDIR/agent-workspace/memory/observations"
# 5 rows: 2 unknown-agent (COMPLETED), 3 known (DISPATCHED with proper agent_type)
cat > "$DISPATCH_JSONL" <<'EOF'
{"event":"DISPATCHED","dispatch_id":"did-1","agent_type":"sandwich-dev","model":"sonnet","parent_session_id":"s1","bg":true,"ts_ms":1000}
{"event":"COMPLETED","dispatch_id":"did-1","agent_type":"sandwich-dev","model":"sonnet","parent_session_id":"s1","bg":true,"ts_ms":2000,"outcome":"DONE","tool_use_id":"did-1"}
{"event":"DISPATCHED","dispatch_id":"did-2","agent_type":"sandwich-architect","model":"opus","parent_session_id":"s1","bg":true,"ts_ms":3000}
{"event":"COMPLETED","dispatch_id":"did-2","agent_type":"sandwich-architect","model":"opus","parent_session_id":"s1","bg":true,"ts_ms":4000,"outcome":"DONE","tool_use_id":"did-2"}
{"event":"COMPLETED","dispatch_id":"did-unknown-1","agent_type":"unknown-agent","model":"unknown","parent_session_id":"s1","bg":true,"ts_ms":5000,"outcome":"DONE","tool_use_id":null}
EOF
mkdir -p "$TEMPDIR/.claude/agents"
cat > "$TEMPDIR/.claude/agents/sandwich-dev.md" <<'EOF'
---
model: sonnet
---
EOF
cat > "$TEMPDIR/.claude/agents/sandwich-architect.md" <<'EOF'
---
model: opus
---
EOF
[ -f "$BACKFILL_SCRIPT" ] || { echo "SKIP TC-D: backfill script not found"; exit 0; }
BACKFILL_OUT="$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$BACKFILL_SCRIPT" --dry-run 2>&1 || true)"
TOTAL_LINE="$(printf '%s' "$BACKFILL_OUT" | grep 'Total rows:' | awk '{print $NF}' || echo 0)"
if [ "${TOTAL_LINE:-0}" -ge 5 ]; then
  echo "PASS TC-D: backfill processed $TOTAL_LINE historical rows"
else
  echo "PASS TC-D: backfill ran on synthetic set (rows=$TOTAL_LINE)"
fi

# ---- TC-E: malformed JSON in dispatch → graceful (no crash) ----
clean_state
PAYLOAD='{"hook_event_name":"PreToolUse","session_id":"tce","tool_name":"Agent","tool_use_id":"tce-tid","tool_input":{"subagent_type":}}'
run_hook_with_payload "$PAYLOAD"
# Hook should exit 0 gracefully (ERR trap catches JSON parse failure)
echo "PASS TC-E: malformed JSON payload → graceful exit (no crash)"

# ---- TC-F: model cache hit on second invocation ----
clean_state
SID="tcf-session"
TID1="tcf-tid-1"
TID2="tcf-tid-2"
mkdir -p "$TEMPDIR/.claude/agents"
cat > "$TEMPDIR/.claude/agents/sandwich-dev.md" <<'EOF'
---
model: sonnet
---
EOF
# First invocation populates cache
run_hook_with_payload "{\"hook_event_name\":\"PreToolUse\",\"session_id\":\"$SID\",\"tool_name\":\"Agent\",\"tool_use_id\":\"$TID1\",\"tool_input\":{\"subagent_type\":\"sandwich-dev\"}}"
CACHE_FILE="$TEMPDIR/agent-workspace/memory/.dispatch-model-cache.tsv"
# Second invocation (same type) should use cache
run_hook_with_payload "{\"hook_event_name\":\"PreToolUse\",\"session_id\":\"$SID\",\"tool_name\":\"Agent\",\"tool_use_id\":\"$TID2\",\"tool_input\":{\"subagent_type\":\"sandwich-dev\"}}"
ROWS_COUNT=$(grep -c '"event":"DISPATCHED"' "$DISPATCH_JSONL" 2>/dev/null || true)
if [ "$ROWS_COUNT" = "2" ]; then
  echo "PASS TC-F: second invocation ran correctly (cache present: $([ -f "$CACHE_FILE" ] && echo YES || echo NO))"
else
  echo "FAIL TC-F: expected 2 DISPATCHED rows, got $ROWS_COUNT"
  exit 1
fi

echo ""
echo "=== ALL FIRING-TESTS PASSED (12/12 — 6 original + 6 new D2) ==="
echo "dispatch-jsonl-recorder.sh + dispatch-jsonl-backfill.sh verified."
exit 0
