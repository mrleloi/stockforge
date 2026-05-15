#!/usr/bin/env bash
# autonomous-block-enforcer-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies:
#   TC1: no flag → RC=0 silent (both UserPromptSubmit and PreToolUse)
#   TC2: flag + UserPromptSubmit → RC=0 + stdout has "AUTONOMOUS-BLOCKED"
#   TC3: flag + PreToolUse + tool=Edit → RC=2 (blocked) + stderr has "AUTONOMOUS-BLOCKED"
#   TC4: flag + PreToolUse + tool=Read → RC=0 (allowed for diagnostic)
#   TC5: flag + STOCKFORGE_FORCE_AUTONOMOUS=1 → RC=0 (bypass)
#   TC6: flag + PreToolUse + Bash invoking block-control.sh → RC=0 (escape hatch)
#   TC7: flag + PreToolUse + Bash NOT block-control → RC=2 (still blocked)
#
# SPAWN-CONTEXT: bash-c (hook reads CLAUDE_TOOL_NAME env var and stdin; firing-test must exercise both)

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/autonomous-block-enforcer.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t block-enforcer-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
}

set_flag() {
  cat > "$TMP/agent-workspace/memory/.autonomous-BLOCKED" <<EOF
BLOCKED test
CRITICAL_COUNT=1
EOF
}

run_hook() {
  local event="$1" tool="${2:-}"
  CLAUDE_PROJECT_DIR="$TMP" CLAUDE_TOOL_NAME="$tool" bash "$HOOK" "$event"
  return $?
}

# === TC1: no flag → RC=0 silent ===
setup_tmp
run_hook UserPromptSubmit >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC1 UserPromptSubmit: expected RC=0, got $RC"

run_hook PreToolUse Edit >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC1 PreToolUse Edit no-flag: expected RC=0, got $RC"

# === TC2: flag + UserPromptSubmit → RC=0 + stdout has BLOCKED ===
setup_tmp
set_flag
OUT=$(run_hook UserPromptSubmit 2>/dev/null)
RC=$?
if [ "$RC" -eq 0 ] && echo "$OUT" | grep -q "AUTONOMOUS-BLOCKED"; then
  note_pass
else
  note_fail "TC2: expected RC=0 + BLOCKED in stdout; got RC=$RC stdout_first80=${OUT:0:80}"
fi

# === TC3: flag + PreToolUse + Edit → RC=2 (blocked) ===
setup_tmp
set_flag
ERR=$(run_hook PreToolUse Edit 2>&1 >/dev/null)
RC=$?
if [ "$RC" -eq 2 ] && echo "$ERR" | grep -q "AUTONOMOUS-BLOCKED"; then
  note_pass
else
  note_fail "TC3: expected RC=2 + AUTONOMOUS-BLOCKED in stderr; got RC=$RC stderr_first80=${ERR:0:80}"
fi

# Additional guarded tools (stdin from /dev/null — enforcer may cat stdin for Bash)
for guarded_tool in Write Bash MultiEdit; do
  setup_tmp; set_flag
  run_hook PreToolUse "$guarded_tool" </dev/null >/dev/null 2>&1
  RC=$?
  if [ "$RC" -eq 2 ]; then note_pass; else note_fail "TC3.$guarded_tool: expected RC=2, got $RC"; fi
done

# === TC4: flag + PreToolUse + Read → RC=0 (allowed) ===
setup_tmp
set_flag
run_hook PreToolUse Read >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC4 Read: expected RC=0, got $RC"

run_hook PreToolUse Glob >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC4 Glob: expected RC=0, got $RC"

run_hook PreToolUse Grep >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC4 Grep: expected RC=0, got $RC"

# === TC5: bypass via STOCKFORGE_FORCE_AUTONOMOUS=1 ===
setup_tmp
set_flag
CLAUDE_PROJECT_DIR="$TMP" CLAUDE_TOOL_NAME="Edit" STOCKFORGE_FORCE_AUTONOMOUS=1 bash "$HOOK" PreToolUse >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC5: bypass expected RC=0, got $RC"

# === TC6: flag + PreToolUse + Bash invoking block-control.sh → RC=0 (escape hatch) ===
setup_tmp
set_flag
echo '{"tool_name":"Bash","tool_input":{"command":"bash scripts/hooks/block-control.sh clear"}}' \
  | CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" PreToolUse >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC6: Bash block-control.sh escape hatch expected RC=0, got $RC"

# === TC7: flag + PreToolUse + Bash NOT block-control → RC=2 (still blocked) ===
setup_tmp
set_flag
echo '{"tool_name":"Bash","tool_input":{"command":"echo hello world"}}' \
  | CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" PreToolUse >/dev/null 2>&1
RC=$?
[ "$RC" -eq 2 ] && note_pass || note_fail "TC7: non-block-control Bash expected RC=2, got $RC"

# Summary
TOTAL=$((PASS+FAIL))
echo "autonomous-block-enforcer-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
