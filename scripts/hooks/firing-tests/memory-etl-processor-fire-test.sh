#!/usr/bin/env bash
# memory-etl-processor-fire-test.sh — companion firing-test per L-S51-1
set -uo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available" >&2; exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/memory-etl-processor.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
QUEUE_DIR="$PROJECT_DIR/agent-workspace/memory/etl-queue"
mkdir -p "$QUEUE_DIR"

PASS=0
FAIL=0

# TC1: Empty queue → silent
PAYLOAD_TC1='{"hook_event_name":"Stop"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 | grep -q "" || true
if [ ! -f "$PROJECT_DIR/agent-workspace/memory/.memory-etl-processor.log" ]; then
  echo "  TC TC1-empty-queue-silent: PASS"; PASS=$((PASS+1))
else
  # OK if log exists but no processing happened
  if ! grep -q "processing" "$PROJECT_DIR/agent-workspace/memory/.memory-etl-processor.log" 2>/dev/null; then
    echo "  TC TC1-empty-queue-silent: PASS (log empty)"; PASS=$((PASS+1))
  else
    echo "  TC TC1-empty-queue-silent: FAIL"; FAIL=$((FAIL+1))
  fi
fi

# TC2: Job queued + processed → log updated + job moved to processed/
cat > "$QUEUE_DIR/1-20260506-test1.job" <<'EOF'
---
task: drift-rollup
payload: {}
created_at: 2026-05-06T10:00:00Z
---
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if grep -q "1-20260506-test1.job" "$PROJECT_DIR/agent-workspace/memory/.memory-etl-processor.log" 2>/dev/null; then
  echo "  TC TC2-job-processed-logged: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-job-processed-logged: FAIL"; FAIL=$((FAIL+1))
fi

# TC3: Job moved to processed/ dir
PROCESSED_DIR="$QUEUE_DIR/processed/$(date +%Y-%m-%d)"
if [ -f "$PROCESSED_DIR/1-20260506-test1.job" ] && [ ! -f "$QUEUE_DIR/1-20260506-test1.job" ]; then
  echo "  TC TC3-job-moved-to-processed: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-job-moved-to-processed: FAIL — orig still exists or not moved"; FAIL=$((FAIL+1))
fi

# TC4: Priority sort — process priority-1 before priority-9
cat > "$QUEUE_DIR/9-20260506-low.job" <<'EOF'
---
task: lesson-synthesize
---
EOF
cat > "$QUEUE_DIR/1-20260506-high.job" <<'EOF'
---
task: profile-render
---
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
# After 1 fire, the priority-1 job should be processed (priority sort)
if [ ! -f "$QUEUE_DIR/1-20260506-high.job" ] && [ -f "$QUEUE_DIR/9-20260506-low.job" ]; then
  echo "  TC TC4-priority-sort: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-priority-sort: FAIL"; FAIL=$((FAIL+1))
fi

# TC5: Kill switch
cat > "$QUEUE_DIR/2-20260506-killtest.job" <<'EOF'
---
task: drift-rollup
---
EOF
MEMORY_ETL_DISABLE=1 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if [ -f "$QUEUE_DIR/2-20260506-killtest.job" ]; then
  echo "  TC TC5-kill-switch: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-kill-switch: FAIL — job processed despite disable"; FAIL=$((FAIL+1))
fi
rm -f "$QUEUE_DIR/2-20260506-killtest.job"

# TC6: Non-Stop event → no processing
cat > "$QUEUE_DIR/2-20260506-nonstop.job" <<'EOF'
---
task: drift-rollup
---
EOF
PAYLOAD_TC6='{"hook_event_name":"PreToolUse","tool_name":"Read"}'
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC6" 2>&1 || true
if [ -f "$QUEUE_DIR/2-20260506-nonstop.job" ]; then
  echo "  TC TC6-non-stop-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-non-stop-skip: FAIL"; FAIL=$((FAIL+1))
fi

# TC7: Unknown task → log unknown-task-skipped, still moved
# Priority 0 ensures this is picked first regardless of leftover jobs from prior TCs
cat > "$QUEUE_DIR/0-20260506-unknown.job" <<'EOF'
---
task: foobar-novel
---
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_TC1" 2>&1 || true
if grep -q "unknown-task-skipped" "$PROJECT_DIR/agent-workspace/memory/.memory-etl-processor.log" 2>/dev/null && \
   [ ! -f "$QUEUE_DIR/0-20260506-unknown.job" ]; then
  echo "  TC TC7-unknown-task-handled: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-unknown-task-handled: FAIL"; FAIL=$((FAIL+1))
fi

# TC8: Empty payload (no hook event detect) → silent (default Stop)
cat > "$QUEUE_DIR/2-20260506-emptyp.job" <<'EOF'
---
task: drift-rollup
---
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "" 2>&1 || true
# Empty payload defaults to Stop → should process
if [ ! -f "$QUEUE_DIR/2-20260506-emptyp.job" ]; then
  echo "  TC TC8-empty-payload-defaults-stop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-empty-payload-defaults-stop: FAIL"; FAIL=$((FAIL+1))
fi

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
