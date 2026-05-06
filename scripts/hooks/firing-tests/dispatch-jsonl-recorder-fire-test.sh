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
COMPLETED_COUNT=$(grep -c '"event":"COMPLETED"' "$DISPATCH_JSONL" 2>/dev/null || echo 0)
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
echo "PASS TC5: SubagentStop DONE → COMPLETED row with FIFO match"

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
DISP_COUNT=$(grep -c '"event":"DISPATCHED"' "$DISPATCH_JSONL" 2>/dev/null || echo 0)
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
echo "PASS TC6: 2 DISPATCHED + 1 SubagentStop → FIFO match oldest ($TID1)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "dispatch-jsonl-recorder.sh externally-observable behavior verified."
exit 0
