#!/usr/bin/env bash
# continue-injector-spawn-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2
# REAL-STATE-DERIVED fixtures per L-S176-1:
#   - TC fixtures mirror actual current-execution.md `**autonomous_mode**:` line format
#   - Asserts on `.session-hooks.log` entries actually emitted by the hook
#   - Sandbox uses mktemp -d trap-cleanup per L-S174-1 (RC-pattern)
#
# Note on platform spawn side-effects (MINGW/Git-Bash):
#   When SHOULD_FIRE_INJECTOR=true, the hook spawns a detached powershell.exe Start-Process
#   targeting `$PROJECT_DIR/scripts/hooks/continue-injector.ps1`. In this sandbox that file
#   does NOT exist, so the inner Start-Process dies in milliseconds with no observable effect.
#   The outer powershell.exe call is `>/dev/null 2>&1 &` + `disown`, so no test-output pollution.
#   Test assertions check the hook's own FIRE/SKIP log line — that's where the decision lives.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/continue-injector-spawn.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
EXEC_FILE="$MEM_DIR/current-execution.md"
mkdir -p "$MEM_DIR"

PASS=0
FAIL=0

reset_state() {
  : > "$LOG" 2>/dev/null || true
  rm -f "$EXEC_FILE" 2>/dev/null || true
}

write_exec_file() {
  # $1 = autonomous_mode value (true|false)
  cat > "$EXEC_FILE" <<EOF
# Current Execution

**autonomous_mode**: $1 (test fixture)

## S0 — placeholder

EOF
}

run_with_source() {
  # $1 = source value to inject as JSON payload
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" \
    bash "$HOOK" <<EOF
{"hook_event_name":"SessionStart","source":"$1"}
EOF
  return $?
}

# ---------------------------------------------------------------------------
# TC1: source=compact (not in startup|resume|clear) → exit 0, NO log entry
# ---------------------------------------------------------------------------
reset_state
write_exec_file "true"
run_with_source "compact" >/dev/null 2>&1
rc=$?
log_entries=$(grep -c 'continue-injector-spawn' "$LOG" 2>/dev/null; true)
log_entries="${log_entries:-0}"
if [ "$rc" = 0 ] && [ "$log_entries" = "0" ]; then
  echo "  TC TC1-source-compact-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-source-compact-noop: FAIL — rc=$rc log_entries=$log_entries"
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC2: source=clear, autonomous_mode=false, no override → SKIPPED log entry
# ---------------------------------------------------------------------------
reset_state
write_exec_file "false"
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "clear" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn SKIPPED.*source=clear.*autonomous_mode=false' "$LOG"; then
  echo "  TC TC2-clear-autonomous-false-no-override-skipped: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-clear-autonomous-false-no-override-skipped: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC3: source=clear, autonomous_mode=false, override=1 → FIRED log entry (override path)
# ---------------------------------------------------------------------------
reset_state
write_exec_file "false"
STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=1 \
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" \
  bash "$HOOK" >/dev/null 2>&1 <<EOF
{"hook_event_name":"SessionStart","source":"clear"}
EOF
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn FIRED.*STOCKFORGE_FORCE_CONTINUE_ON_CLEAR=1' "$LOG"; then
  echo "  TC TC3-clear-override-fired: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-clear-override-fired: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC4: source=clear, autonomous_mode=true → FIRED log entry
# ---------------------------------------------------------------------------
reset_state
write_exec_file "true"
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "clear" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn FIRED.*source=clear.*autonomous_mode=true' "$LOG"; then
  echo "  TC TC4-clear-autonomous-true-fired: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-clear-autonomous-true-fired: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC5: source=resume → FIRED unconditionally regardless of autonomous_mode
# ---------------------------------------------------------------------------
reset_state
write_exec_file "false"
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "resume" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn FIRED.*source=resume' "$LOG"; then
  echo "  TC TC5-resume-fired-unconditional: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-resume-fired-unconditional: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC6: source=startup, autonomous_mode=false → SKIPPED log entry
# ---------------------------------------------------------------------------
reset_state
write_exec_file "false"
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "startup" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn SKIPPED.*source=startup.*autonomous_mode=false' "$LOG"; then
  echo "  TC TC6-startup-autonomous-false-skipped: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-startup-autonomous-false-skipped: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC7: source=startup, autonomous_mode=true → FIRED log entry
# ---------------------------------------------------------------------------
reset_state
write_exec_file "true"
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "startup" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn FIRED.*source=startup.*autonomous_mode=true' "$LOG"; then
  echo "  TC TC7-startup-autonomous-true-fired: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-startup-autonomous-true-fired: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC8: missing current-execution.md → autonomous_mode defaults to false
# source=startup → SKIPPED (defensive default)
# ---------------------------------------------------------------------------
reset_state
# No write_exec_file — current-execution.md absent
unset STOCKFORGE_FORCE_CONTINUE_ON_CLEAR 2>/dev/null || true
run_with_source "startup" >/dev/null 2>&1
rc=$?
if [ "$rc" = 0 ] && grep -q 'continue-injector-spawn SKIPPED.*source=startup.*autonomous_mode=false' "$LOG"; then
  echo "  TC TC8-missing-exec-file-defaults-false: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-missing-exec-file-defaults-false: FAIL — rc=$rc log:"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# ---------------------------------------------------------------------------
# TC9: empty payload (no source field) → exit 0, NO log entry (case fall-through)
# ---------------------------------------------------------------------------
reset_state
write_exec_file "true"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" \
  bash "$HOOK" >/dev/null 2>&1 <<EOF
{}
EOF
rc=$?
log_entries=$(grep -c 'continue-injector-spawn' "$LOG" 2>/dev/null; true)
log_entries="${log_entries:-0}"
if [ "$rc" = 0 ] && [ "$log_entries" = "0" ]; then
  echo "  TC TC9-empty-payload-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC9-empty-payload-noop: FAIL — rc=$rc log_entries=$log_entries"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== continue-injector-spawn firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
