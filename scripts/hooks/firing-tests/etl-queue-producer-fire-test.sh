#!/usr/bin/env bash
# etl-queue-producer-fire-test.sh — Plan 011 D6 firing test.
# Exercises all 3 etl-queue producer hooks: lesson-synthesis-watchdog,
# profile-template-auto-populate, index-registry-renderer.
# Per L-S52-3 success-path: real-data smoke + ≥6 TCs (≥1 positive + ≥3 negative + kill-switch).
# Per L-S11-1 portability: bash + awk + grep + sed only.

set -uo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SCRIPT_DIR="$PROJECT_ROOT/scripts/hooks"
PASS=0
FAIL=0

SANDBOX="$(mktemp -d)"
cleanup() { rm -rf "$SANDBOX"; }
trap cleanup EXIT

setup_sandbox() {
  rm -rf "$SANDBOX"/*
  rm -rf "$SANDBOX"/.[!.]* 2>/dev/null || true
  mkdir -p "$SANDBOX/agent-workspace/memory/etl-queue/processed"
  mkdir -p "$SANDBOX/agent-workspace/memory/sessions"
  mkdir -p "$SANDBOX/agent-workspace/memory/self-awareness/profiles"
  mkdir -p "$SANDBOX/agent-workspace/memory/decisions"
  mkdir -p "$SANDBOX/scripts/hooks/firing-tests"
  mkdir -p "$SANDBOX/.claude"
  mkdir -p "$SANDBOX/packages" "$SANDBOX/apps"
  ( cd "$SANDBOX" && git init -q . && git config user.email t@t.t && git config user.name t ) >/dev/null 2>&1 || true
}

count_jobs() {
  local pattern="$1"
  local count
  count="$(ls "$SANDBOX/agent-workspace/memory/etl-queue/" 2>/dev/null | grep -c "$pattern" 2>/dev/null || true)"
  printf '%s' "${count:-0}"
}

assert_pass() { PASS=$((PASS+1)); printf 'PASS TC%s: %s\n' "$2" "$1"; }
assert_fail() { FAIL=$((FAIL+1)); printf 'FAIL TC%s: %s\n' "$2" "$1"; }

# ----------------------------------------------------------------------
# TC1: lesson-synthesis-watchdog dormancy → queue lesson-synthesize.job
# ----------------------------------------------------------------------
setup_sandbox
echo "test prod content" > "$SANDBOX/packages/test_file.py"
# KI/BP/agent-notes do NOT exist → LESSON_TOTAL=0 (post L-S68 find guard fix)
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/lesson-synthesis-watchdog.sh" 2>/dev/null
EXIT_CODE=$?
JOB_COUNT="$(count_jobs 'lesson-synthesize.job$')"
if [ "$EXIT_CODE" -eq 2 ] && [ "$JOB_COUNT" -ge 1 ]; then
  assert_pass "dormancy detected → exit 2 + lesson-synthesize.job queued" "1"
else
  assert_fail "dormancy: exit=$EXIT_CODE jobs=$JOB_COUNT (expected exit 2 + ≥1 job)" "1"
fi

# ----------------------------------------------------------------------
# TC2: lesson-synthesis-watchdog with MEMORY_ETL_DISABLE=1 → no job (kill switch)
# ----------------------------------------------------------------------
setup_sandbox
echo "test prod content" > "$SANDBOX/packages/test_file.py"
MEMORY_ETL_DISABLE=1 CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/lesson-synthesis-watchdog.sh" 2>/dev/null
EXIT_CODE=$?
JOB_COUNT="$(count_jobs 'lesson-synthesize.job$')"
if [ "$EXIT_CODE" -eq 2 ] && [ "$JOB_COUNT" -eq 0 ]; then
  assert_pass "MEMORY_ETL_DISABLE=1 → exit 2 + NO job (kill switch honored)" "2"
else
  assert_fail "kill switch: exit=$EXIT_CODE jobs=$JOB_COUNT (expected exit 2 + 0 jobs)" "2"
fi

# ----------------------------------------------------------------------
# TC3: profile-template-auto-populate threshold not reached → no job
# ----------------------------------------------------------------------
setup_sandbox
SESSION_LOG="$SANDBOX/agent-workspace/memory/sessions/2026-05-06-session-99.md"
cat > "$SESSION_LOG" <<'EOF'
---
type: FOCUSED_IMPL
agent: sandwich-dev (claude-sonnet-4-6)
---
# Session log
EOF
PROFILE="$SANDBOX/agent-workspace/memory/self-awareness/profiles/sonnet46-max-FOCUSED_IMPL.md"
cat > "$PROFILE" <<'EOF'
---
model: claude-sonnet-4-6
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 3
sample_sessions: [S40, S42, S45]
last_updated: 2026-05-01
---
EOF
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/profile-template-auto-populate.sh" </dev/null 2>/dev/null
JOB_COUNT="$(count_jobs 'profile-render')"
if [ "$JOB_COUNT" -eq 0 ]; then
  assert_pass "samples_count 3→4 < threshold 10 → no profile-render job queued" "3"
else
  assert_fail "below-threshold: jobs=$JOB_COUNT (expected 0)" "3"
fi

# ----------------------------------------------------------------------
# TC4: profile-template-auto-populate threshold reached → queue profile-render.job
# ----------------------------------------------------------------------
setup_sandbox
SESSION_LOG="$SANDBOX/agent-workspace/memory/sessions/2026-05-06-session-100.md"
cat > "$SESSION_LOG" <<'EOF'
---
type: FOCUSED_IMPL
agent: sandwich-dev (claude-sonnet-4-6)
---
EOF
PROFILE="$SANDBOX/agent-workspace/memory/self-awareness/profiles/sonnet46-max-FOCUSED_IMPL.md"
cat > "$PROFILE" <<'EOF'
---
model: claude-sonnet-4-6
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 9
sample_sessions: [S40, S42, S45, S48, S52, S55, S58, S60, S62]
last_updated: 2026-05-01
---
EOF
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/profile-template-auto-populate.sh" </dev/null 2>/dev/null
JOB_COUNT="$(count_jobs 'profile-render')"
if [ "$JOB_COUNT" -ge 1 ]; then
  assert_pass "samples_count 9→10 (threshold) → profile-render job queued" "4"
else
  assert_fail "threshold-reached: jobs=$JOB_COUNT (expected ≥1)" "4"
fi

# ----------------------------------------------------------------------
# TC5: profile-template low threshold via env var → queue at lower count
# ----------------------------------------------------------------------
setup_sandbox
SESSION_LOG="$SANDBOX/agent-workspace/memory/sessions/2026-05-06-session-101.md"
cat > "$SESSION_LOG" <<'EOF'
---
type: PLAN
agent: sandwich-architect (claude-opus-4-7)
---
EOF
PROFILE="$SANDBOX/agent-workspace/memory/self-awareness/profiles/opus47-max-PLAN.md"
cat > "$PROFILE" <<'EOF'
---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - PLAN
samples_count: 1
sample_sessions: [S30]
last_updated: 2026-05-01
---
EOF
STOCKFORGE_PROFILE_REBUILD_THRESHOLD=2 \
  CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/profile-template-auto-populate.sh" </dev/null 2>/dev/null
JOB_COUNT="$(count_jobs 'profile-render')"
if [ "$JOB_COUNT" -ge 1 ]; then
  assert_pass "STOCKFORGE_PROFILE_REBUILD_THRESHOLD=2 → job queued at samples=2" "5"
else
  assert_fail "low-threshold: jobs=$JOB_COUNT (expected ≥1)" "5"
fi

# ----------------------------------------------------------------------
# TC6: index-registry-renderer → queues manifest-render-complete job at end
# ----------------------------------------------------------------------
setup_sandbox
echo '#!/bin/bash' > "$SANDBOX/scripts/hooks/sample.sh"
chmod +x "$SANDBOX/scripts/hooks/sample.sh"
cat > "$SANDBOX/.claude/settings.json" <<'EOF'
{ "hooks": { "Stop": [ { "hooks": [ { "type": "command", "command": "bash ${CLAUDE_PROJECT_DIR}/scripts/hooks/sample.sh" } ] } ] } }
EOF
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/index-registry-renderer.sh" 2>/dev/null
JOB_COUNT="$(count_jobs 'manifest-render-complete')"
INDEXES_OK="$(ls "$SANDBOX/agent-workspace/memory/indexes/" 2>/dev/null | grep -c '\.tsv$' 2>/dev/null || true)"
INDEXES_OK="${INDEXES_OK:-0}"
if [ "$JOB_COUNT" -ge 1 ] && [ "$INDEXES_OK" -ge 4 ]; then
  assert_pass "index-render → 4 manifests rendered + manifest-render-complete job queued" "6"
else
  assert_fail "index-render: jobs=$JOB_COUNT manifests=$INDEXES_OK (expected ≥1 job + ≥4 manifests)" "6"
fi

# ----------------------------------------------------------------------
# TC7: dedup — second run of profile-template at threshold → no duplicate job
# ----------------------------------------------------------------------
setup_sandbox
SESSION_LOG="$SANDBOX/agent-workspace/memory/sessions/2026-05-06-session-102.md"
cat > "$SESSION_LOG" <<'EOF'
---
type: VERIFY
agent: sandwich-verifier (claude-opus-4-7)
---
EOF
PROFILE="$SANDBOX/agent-workspace/memory/self-awareness/profiles/opus47-max-VERIFY.md"
cat > "$PROFILE" <<'EOF'
---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - VERIFY
samples_count: 9
sample_sessions: [S30, S31, S32, S33, S34, S35, S36, S37, S38]
last_updated: 2026-05-01
---
EOF
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/profile-template-auto-populate.sh" </dev/null 2>/dev/null
# Reset MARKER + samples_count to simulate second session firing
rm -f "$SANDBOX/agent-workspace/memory/.profile-template-fired-"*
cat > "$PROFILE" <<'EOF'
---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - VERIFY
samples_count: 10
sample_sessions: [S30, S31, S32, S33, S34, S35, S36, S37, S38, S39]
last_updated: 2026-05-01
---
EOF
SESSION_LOG2="$SANDBOX/agent-workspace/memory/sessions/2026-05-06-session-102b.md"
cat > "$SESSION_LOG2" <<'EOF'
---
type: VERIFY
agent: sandwich-verifier (claude-opus-4-7)
---
EOF
CLAUDE_PROJECT_DIR="$SANDBOX" bash "$SCRIPT_DIR/profile-template-auto-populate.sh" </dev/null 2>/dev/null
JOB_COUNT="$(count_jobs 'profile-render-opus47-max-VERIFY')"
if [ "$JOB_COUNT" -eq 1 ]; then
  assert_pass "re-fire same cell → dedup honored (1 job not 2)" "7"
else
  assert_fail "dedup: jobs=$JOB_COUNT (expected 1)" "7"
fi

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
TOTAL=$((PASS+FAIL))
echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
if [ "$FAIL" -eq 0 ]; then
  echo "etl-queue producer wiring (Plan 011 D6) verified."
  exit 0
else
  echo "FAILURE — review TCs above."
  exit 1
fi
