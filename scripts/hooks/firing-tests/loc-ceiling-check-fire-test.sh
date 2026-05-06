#!/usr/bin/env bash
# Firing-test for loc-ceiling-check.sh (Phase 3.5 T7 retrofit; S61).
#
# Hook purpose (DR-CONFIG / S2 audit PostToolUse): warn when LOC of edited
# .claude/{agents,skills,commands}/**/*.md file exceeds archetype ceiling
# (agents 200 / skills 150 / commands 120). Hard-block if STOCKFORGE_LOC_STRICT=1.
#
# Test strategy: pipe varying PostToolUse JSON payloads with file_path;
# assert exit code, stderr WARN, log entry, and JSON block decision in strict mode.
#
# 6 test cases:
#   TC1 — non-Write tool (Read) → exit 0 no-op
#   TC2 — non-.claude file path → exit 0
#   TC3 — .claude/agents/foo.md ≤ 200 lines → silent
#   TC4 — .claude/agents/foo.md > 200 lines → WARN stderr + log
#   TC5 — .claude/skills/x/SKILL.md > 150 lines → WARN stderr
#   TC6 — STOCKFORGE_LOC_STRICT=1 + overrun → JSON block decision in stdout
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../loc-ceiling-check.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

if ! command -v node >/dev/null 2>&1; then
  echo "SKIP: node not available; cannot test loc-ceiling-check"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook_with_payload() {
  local payload="$1"
  local rc=0
  local stderr_out
  local stdout_out
  # Capture both streams separately
  exec 3>&1
  stderr_out=$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" 2>&1 1>&3) && rc=0 || rc=$?
  exec 3>&-
  printf '%s' "$stderr_out"
  return $rc
}

run_hook_strict() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    STOCKFORGE_LOC_STRICT=1 bash "$HOOK" 2>/dev/null
}

run_hook_get_stderr() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" 2>&1 >/dev/null
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# Helper to make a file with N lines
make_file() {
  local path="$1"
  local n="$2"
  mkdir -p "$(dirname "$path")"
  for i in $(seq 1 "$n"); do echo "line $i" >> "$path"; done
}

# --- TC1: non-Write tool (Read) → exit 0 ---
clean_state
PAYLOAD=$(cat <<EOF
{"tool_name":"Read","tool_input":{"file_path":"/x/foo.md"}}
EOF
)
STDERR=$(run_hook_get_stderr "$PAYLOAD")
if [ -n "$STDERR" ]; then
  echo "FAIL TC1: Read tool should not warn; stderr:"
  echo "$STDERR"
  exit 1
fi
echo "PASS TC1: non-Write tool → silent"

# --- TC2: non-.claude file path → exit 0 ---
clean_state
mkdir -p "$TEMPDIR/apps"
make_file "$TEMPDIR/apps/large.md" 500
PAYLOAD=$(cat <<EOF
{"tool_name":"Write","tool_input":{"file_path":"$TEMPDIR/apps/large.md"}}
EOF
)
STDERR=$(run_hook_get_stderr "$PAYLOAD")
if [ -n "$STDERR" ]; then
  echo "FAIL TC2: non-.claude path should not warn; stderr:"
  echo "$STDERR"
  exit 1
fi
echo "PASS TC2: non-.claude path → silent"

# --- TC3: .claude/agents/foo.md ≤ 200 lines → silent ---
clean_state
AGENT_PATH="$TEMPDIR/.claude/agents/foo.md"
make_file "$AGENT_PATH" 150
PAYLOAD=$(cat <<EOF
{"tool_name":"Write","tool_input":{"file_path":"$AGENT_PATH"}}
EOF
)
STDERR=$(run_hook_get_stderr "$PAYLOAD")
if [ -n "$STDERR" ]; then
  echo "FAIL TC3: 150-line agent should not warn; stderr:"
  echo "$STDERR"
  exit 1
fi
echo "PASS TC3: agents/.md ≤ 200 LOC → silent"

# --- TC4: .claude/agents/foo.md > 200 → WARN ---
clean_state
AGENT_PATH="$TEMPDIR/.claude/agents/big.md"
make_file "$AGENT_PATH" 250
PAYLOAD=$(cat <<EOF
{"tool_name":"Write","tool_input":{"file_path":"$AGENT_PATH"}}
EOF
)
STDERR=$(run_hook_get_stderr "$PAYLOAD")
if ! echo "$STDERR" | grep -q "loc-ceiling-check.*WARN"; then
  echo "FAIL TC4: 250-line agent should WARN to stderr; got:"
  echo "$STDERR"
  exit 1
fi
if ! grep -q "agent=$AGENT_PATH" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected agent log entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: agents/.md 250 LOC > 200 → WARN + log"

# --- TC5: .claude/skills/x/SKILL.md > 150 → WARN ---
clean_state
SKILL_PATH="$TEMPDIR/.claude/skills/foo/SKILL.md"
make_file "$SKILL_PATH" 200
PAYLOAD=$(cat <<EOF
{"tool_name":"Write","tool_input":{"file_path":"$SKILL_PATH"}}
EOF
)
STDERR=$(run_hook_get_stderr "$PAYLOAD")
if ! echo "$STDERR" | grep -q "WARN"; then
  echo "FAIL TC5: 200-line SKILL.md should WARN; got:"
  echo "$STDERR"
  exit 1
fi
if ! echo "$STDERR" | grep -q "150"; then
  echo "FAIL TC5: WARN should mention 150 ceiling"
  echo "$STDERR"
  exit 1
fi
echo "PASS TC5: skills/x/SKILL.md 200 LOC > 150 → WARN"

# --- TC6: STOCKFORGE_LOC_STRICT=1 + overrun → JSON block ---
clean_state
COMMAND_PATH="$TEMPDIR/.claude/commands/foo.md"
make_file "$COMMAND_PATH" 200
PAYLOAD=$(cat <<EOF
{"tool_name":"Write","tool_input":{"file_path":"$COMMAND_PATH"}}
EOF
)
STDOUT=$(run_hook_strict "$PAYLOAD")
if ! echo "$STDOUT" | grep -q '"decision":"block"'; then
  echo "FAIL TC6: STRICT mode should emit JSON block decision; got stdout:"
  echo "$STDOUT"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "STOCKFORGE LOC-CEILING"; then
  echo "FAIL TC6: JSON block reason should mention LOC-CEILING"
  echo "$STDOUT"
  exit 1
fi
echo "PASS TC6: STOCKFORGE_LOC_STRICT=1 + commands 200 LOC > 120 → JSON block"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "loc-ceiling-check.sh externally-observable behavior verified."
exit 0
