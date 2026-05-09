#!/usr/bin/env bash
# dispatch-jsonl-backfill-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2 retro-fit
# REAL-STATE-DERIVED per L-S176-1: parent hook is one-shot CLI utility that recovers agent_type+model
# in dispatch.jsonl COMPLETED rows by cross-referencing .dispatch-pending-*.jsonl sidecars + observation
# filename prefixes + .claude/agents/<type>.md frontmatter. Plan 011 D2 deliverable.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/dispatch-jsonl-backfill.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
OBS_DIR="$MEM_DIR/observations"
AGENTS_DIR="$PROJECT_DIR/.claude/agents"
mkdir -p "$MEM_DIR" "$OBS_DIR" "$AGENTS_DIR"

PASS=0
FAIL=0

# TC1: missing dispatch.jsonl → exit 0 with INFO message
out=$(bash "$HOOK" --project-dir "$PROJECT_DIR" 2>&1)
rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'dispatch.jsonl not found'; then
  echo "  TC TC1-missing-dispatch-info: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-missing-dispatch-info: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC2: empty dispatch.jsonl + --dry-run → "Total rows: 0", no backup file written
: > "$MEM_DIR/dispatch.jsonl"
out=$(bash "$HOOK" --project-dir "$PROJECT_DIR" --dry-run 2>&1)
rc=$?
backup_count=$(find "$MEM_DIR" -maxdepth 1 -name 'dispatch.jsonl.backfill-backup-*' 2>/dev/null | wc -l)
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'Total rows: 0' && [ "$backup_count" = 0 ]; then
  echo "  TC TC2-empty-dispatch-dryrun: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-empty-dispatch-dryrun: FAIL — rc=$rc out=$out backup_count=$backup_count"
  FAIL=$((FAIL+1))
fi

# TC3: dispatch.jsonl with unknown-agent rows + sidecar with real agent_type → recovery happens
# REAL-STATE-DERIVED: schema mirrors actual stockforge dispatch.jsonl (event=DISPATCHED|COMPLETED, dispatch_id, agent_type, model)
SIDECAR="$MEM_DIR/.dispatch-pending-test-sid.jsonl"
cat > "$SIDECAR" <<'EOF'
{"dispatch_id":"toolu_01TestRecover123","tool_use_id":"toolu_01TestRecover123","agent_type":"sandwich-architect","model":"opus","parent_session_id":"test-sid","ts_ms":1778000000000,"state":"pending"}
EOF
cat > "$MEM_DIR/dispatch.jsonl" <<'EOF'
{"event":"DISPATCHED","dispatch_id":"toolu_01TestRecover123","agent_type":"unknown-agent","model":"unknown","parent_session_id":"test-sid","bg":true,"ts_ms":1778000000000,"outcome":null,"tokens_used":null,"tool_use_id":"toolu_01TestRecover123"}
{"event":"COMPLETED","dispatch_id":"toolu_01TestRecover123","agent_type":"unknown-agent","model":"unknown","parent_session_id":"test-sid","bg":true,"ts_ms":1778001000000,"outcome":"DONE","tokens_used":50000,"duration_ms":60000,"failure_mode":null,"tool_use_id":"toolu_01TestRecover123"}
EOF
out=$(bash "$HOOK" --project-dir "$PROJECT_DIR" --dry-run 2>&1)
rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -qE 'Recovered: [12]'; then
  echo "  TC TC3-sidecar-recovery-dryrun: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-sidecar-recovery-dryrun: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC4: actual run (no --dry-run) creates .backfill-backup-* file + updates dispatch.jsonl
rm -f "$MEM_DIR"/dispatch.jsonl.backfill-backup-*
out=$(bash "$HOOK" --project-dir "$PROJECT_DIR" 2>&1)
rc=$?
backup_file=$(find "$MEM_DIR" -maxdepth 1 -name 'dispatch.jsonl.backfill-backup-*' 2>/dev/null | head -1)
recovered_in_jsonl=$(grep -c 'sandwich-architect' "$MEM_DIR/dispatch.jsonl" 2>/dev/null || echo 0)
if [ "$rc" = 0 ] && [ -n "$backup_file" ] && [ "$recovered_in_jsonl" -ge 1 ]; then
  echo "  TC TC4-actual-run-creates-backup: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-actual-run-creates-backup: FAIL — rc=$rc backup=$backup_file recovered=$recovered_in_jsonl"
  FAIL=$((FAIL+1))
fi

# TC5: model resolution from .claude/agents/<type>.md frontmatter for non-fast-path agent
# Build fixture: lesson-synthesizer.md with model: claude-opus-4-7
cat > "$AGENTS_DIR/lesson-synthesizer.md" <<'EOF'
---
name: lesson-synthesizer
model: claude-opus-4-7
---
EOF
SIDECAR2="$MEM_DIR/.dispatch-pending-test-sid2.jsonl"
cat > "$SIDECAR2" <<'EOF'
{"dispatch_id":"toolu_01TestModel456","tool_use_id":"toolu_01TestModel456","agent_type":"lesson-synthesizer","model":"unknown","parent_session_id":"test-sid2","ts_ms":1778002000000,"state":"pending"}
EOF
cat > "$MEM_DIR/dispatch.jsonl" <<'EOF'
{"event":"COMPLETED","dispatch_id":"toolu_01TestModel456","agent_type":"unknown-agent","model":"unknown","parent_session_id":"test-sid2","bg":true,"ts_ms":1778002000000,"outcome":"DONE","tokens_used":10000,"tool_use_id":"toolu_01TestModel456"}
EOF
out=$(bash "$HOOK" --project-dir "$PROJECT_DIR" --dry-run 2>&1)
rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -qE 'Recovered: 1'; then
  echo "  TC TC5-model-resolution-from-agents: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-model-resolution-from-agents: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== dispatch-jsonl-backfill firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
