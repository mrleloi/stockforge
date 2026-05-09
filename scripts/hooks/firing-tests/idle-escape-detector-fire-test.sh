#!/usr/bin/env bash
# Firing-test for idle-escape-detector.sh.
# Phase 3.5 / S175 deliverable. Per Hard Rule #2 every hook ships with companion
# firing-test that synthesizes a deliberate FAIL state + asserts hook detects it.
#
# 6 test cases:
#   TC1 — current-execution.md missing → silent (graceful bail)
#   TC2 — 1 ROUTINE-IDLE at top → silent (consecutive=1 < threshold 3)
#   TC3 — 3 consecutive ROUTINE-IDLE → state=YELLOW (no pending plans)
#   TC4 — 3 consecutive ROUTINE-IDLE + 2 pending plans → state=RED (severity=HIGH)
#   TC5 — 5 ACTIVE blocks → silent (consecutive=0)
#   TC6 — cache hit on second invocation within 5 min → CACHE-HIT log
#
# Per L-S174-1: when checking RED-state RC, use `RC=0; cmd || RC=$?` pattern
# (this script doesn't set ERR-trap on EXIT but we follow the doctrine for any
# rc-capture).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../idle-escape-detector.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }
[ -x "$HOOK" ] || chmod +x "$HOOK" 2>/dev/null || true

PASS=0
FAIL=0
TOTAL=0

assert() {
  local desc="$1" cond="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$cond" = "1" ] || [ "$cond" = "true" ]; then
    PASS=$((PASS + 1))
    echo "  [PASS] $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  [FAIL] $desc"
  fi
}

# Use a fresh tempdir per test to isolate cache + markers.
new_tempdir() {
  local d
  d=$(mktemp -d -t idle-escape-test-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/idle-escape-$$-${RANDOM}")
  mkdir -p "$d/agent-workspace/memory" "$d/agent-workspace/session-plans/pending" 2>/dev/null
  echo "$d"
}

# Build a current-execution.md with N consecutive ROUTINE-IDLE blocks at top
# followed by M ACTIVE blocks. SID counter starts at 200.
build_ce() {
  local out="$1" idle_count="$2" active_count="$3"
  : > "$out"
  echo "# Current Execution — Test fixture" >> "$out"
  echo "" >> "$out"
  local sid=200
  local i
  for ((i=0; i<idle_count; i++)); do
    echo "## S${sid} — Phase 3 — ROUTINE-IDLE: synthesized idle block #${i} for fixture testing." >> "$out"
    echo "" >> "$out"
    echo "Body of routine idle session ${sid}." >> "$out"
    echo "" >> "$out"
    echo "---" >> "$out"
    echo "" >> "$out"
    sid=$((sid - 1))
  done
  for ((i=0; i<active_count; i++)); do
    echo "## S${sid} — Phase 3.5 — FOCUSED_IMPL-DONE: synthesized active block." >> "$out"
    echo "" >> "$out"
    echo "Body of active session ${sid}." >> "$out"
    echo "" >> "$out"
    echo "---" >> "$out"
    echo "" >> "$out"
    sid=$((sid - 1))
  done
}

# === TC1: missing current-execution.md → silent (graceful bail) ===
echo "=== TC1: missing current-execution.md ==="
TC1_DIR=$(new_tempdir)
TC1_LOG="$TC1_DIR/agent-workspace/memory/.session-hooks.log"
RC=0
CLAUDE_PROJECT_DIR="$TC1_DIR" CLAUDE_SESSION_ID="tc1" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
TC1_FIRED=0
[ -f "$TC1_LOG" ] && grep -q "ESCAPE-TRIGGER" "$TC1_LOG" 2>/dev/null && TC1_FIRED=1
assert "TC1: hook exits 0 with missing CE file" "$([ "$RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC1: no escape-trigger fired (graceful bail)" "$([ "$TC1_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC1_DIR" 2>/dev/null || true

# === TC2: 1 ROUTINE-IDLE → silent ===
echo "=== TC2: 1 idle block (below threshold) ==="
TC2_DIR=$(new_tempdir)
build_ce "$TC2_DIR/agent-workspace/memory/current-execution.md" 1 4
TC2_CACHE="$TC2_DIR/agent-workspace/memory/.idle-escape-cache-tc2"
TC2_IDLE_LOG="$TC2_DIR/agent-workspace/memory/.idle-escape.log"
CLAUDE_PROJECT_DIR="$TC2_DIR" CLAUDE_SESSION_ID="tc2" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC2_STATE=$(grep -oE 'state=[A-Z]+' "$TC2_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC2_FIRED=0
[ -f "$TC2_IDLE_LOG" ] && grep -q "ESCAPE-TRIGGER" "$TC2_IDLE_LOG" 2>/dev/null && TC2_FIRED=1
assert "TC2: state=GREEN (1 idle)" "$([ "$TC2_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC2: no escape-trigger fired" "$([ "$TC2_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC2_DIR" 2>/dev/null || true

# === TC3: 3 consecutive ROUTINE-IDLE → state=YELLOW (no pending plans) ===
echo "=== TC3: 3 idle blocks no pending plans (YELLOW) ==="
TC3_DIR=$(new_tempdir)
build_ce "$TC3_DIR/agent-workspace/memory/current-execution.md" 3 2
TC3_CACHE="$TC3_DIR/agent-workspace/memory/.idle-escape-cache-tc3"
TC3_IDLE_LOG="$TC3_DIR/agent-workspace/memory/.idle-escape.log"
CLAUDE_PROJECT_DIR="$TC3_DIR" CLAUDE_SESSION_ID="tc3" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC3_STATE=$(grep -oE 'state=[A-Z]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC3_CONS=$(grep -oE 'consecutive=[0-9]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/consecutive=//')
TC3_FIRED=0
[ -f "$TC3_IDLE_LOG" ] && grep -q "ESCAPE-TRIGGER" "$TC3_IDLE_LOG" 2>/dev/null && TC3_FIRED=1
assert "TC3: state=YELLOW (3 idle, 0 plans)" "$([ "$TC3_STATE" = "YELLOW" ] && echo 1 || echo 0)"
assert "TC3: consecutive=3 detected" "$([ "$TC3_CONS" = "3" ] && echo 1 || echo 0)"
assert "TC3: escape-trigger fired" "$([ "$TC3_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC3_DIR" 2>/dev/null || true

# === TC4: 3 idle + 2 pending plans → state=RED severity=HIGH ===
echo "=== TC4: 3 idle blocks + 2 pending plans (RED HIGH) ==="
TC4_DIR=$(new_tempdir)
build_ce "$TC4_DIR/agent-workspace/memory/current-execution.md" 3 2
echo "# plan a" > "$TC4_DIR/agent-workspace/session-plans/pending/plan-a.md"
echo "# plan b" > "$TC4_DIR/agent-workspace/session-plans/pending/plan-b.md"
TC4_CACHE="$TC4_DIR/agent-workspace/memory/.idle-escape-cache-tc4"
TC4_IDLE_LOG="$TC4_DIR/agent-workspace/memory/.idle-escape.log"
CLAUDE_PROJECT_DIR="$TC4_DIR" CLAUDE_SESSION_ID="tc4" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC4_STATE=$(grep -oE 'state=[A-Z]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC4_SEV=$(grep -oE 'severity=[A-Z]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/severity=//')
TC4_PLANS=$(grep -oE 'pending_plans=[0-9]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/pending_plans=//')
TC4_FIRED=0
[ -f "$TC4_IDLE_LOG" ] && grep -q "ESCAPE-TRIGGER" "$TC4_IDLE_LOG" 2>/dev/null && TC4_FIRED=1
assert "TC4: state=RED (3 idle + 2 plans)" "$([ "$TC4_STATE" = "RED" ] && echo 1 || echo 0)"
assert "TC4: severity=HIGH" "$([ "$TC4_SEV" = "HIGH" ] && echo 1 || echo 0)"
assert "TC4: pending_plans=2 detected" "$([ "$TC4_PLANS" = "2" ] && echo 1 || echo 0)"
assert "TC4: escape-trigger fired" "$([ "$TC4_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC4_DIR" 2>/dev/null || true

# === TC5: 5 ACTIVE blocks → silent ===
echo "=== TC5: 5 active blocks (no idle) ==="
TC5_DIR=$(new_tempdir)
build_ce "$TC5_DIR/agent-workspace/memory/current-execution.md" 0 5
TC5_CACHE="$TC5_DIR/agent-workspace/memory/.idle-escape-cache-tc5"
TC5_IDLE_LOG="$TC5_DIR/agent-workspace/memory/.idle-escape.log"
CLAUDE_PROJECT_DIR="$TC5_DIR" CLAUDE_SESSION_ID="tc5" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC5_STATE=$(grep -oE 'state=[A-Z]+' "$TC5_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC5_CONS=$(grep -oE 'consecutive=[0-9]+' "$TC5_CACHE" 2>/dev/null | head -1 | sed 's/consecutive=//')
TC5_FIRED=0
[ -f "$TC5_IDLE_LOG" ] && grep -q "ESCAPE-TRIGGER" "$TC5_IDLE_LOG" 2>/dev/null && TC5_FIRED=1
assert "TC5: state=GREEN (0 idle)" "$([ "$TC5_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC5: consecutive=0" "$([ "$TC5_CONS" = "0" ] && echo 1 || echo 0)"
assert "TC5: no escape-trigger" "$([ "$TC5_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC5_DIR" 2>/dev/null || true

# === TC6: cache-hit on second invocation within 5 min ===
echo "=== TC6: cache-hit on 2nd invocation ==="
TC6_DIR=$(new_tempdir)
build_ce "$TC6_DIR/agent-workspace/memory/current-execution.md" 3 2
TC6_LOG="$TC6_DIR/agent-workspace/memory/.session-hooks.log"
# First fire — populates cache.
CLAUDE_PROJECT_DIR="$TC6_DIR" CLAUDE_SESSION_ID="tc6" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
# Second fire — should be CACHE-HIT.
CLAUDE_PROJECT_DIR="$TC6_DIR" CLAUDE_SESSION_ID="tc6" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC6_HITS=$(grep -c "CACHE-HIT" "$TC6_LOG" 2>/dev/null || echo 0)
[[ "$TC6_HITS" =~ ^[0-9]+$ ]] || TC6_HITS=0
assert "TC6: cache-hit on 2nd invocation" "$([ "$TC6_HITS" -ge 1 ] && echo 1 || echo 0)"
rm -rf "$TC6_DIR" 2>/dev/null || true

# === Summary ===
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ALL firing-tests passed (idle-escape-detector M-S171-1 prevention rule)."
  exit 0
else
  echo "  $FAIL firing-test(s) failed."
  exit 1
fi
