#!/usr/bin/env bash
# pre-dispatch-architect-commit-guard-fire-test.sh — companion firing-test for D3 hook.
#
# SPAWN-CONTEXT: positional-arg (bash pre-dispatch-architect-commit-guard-fire-test.sh)
#
# Test cases (6 TC):
#   TC1 — Agent + sandwich-architect + prompt contains "git commit" → BLOCKED (RC=2)
#   TC2 — Agent + sandwich-architect + prompt clean → ALLOW (RC=0)
#   TC3 — Agent + sandwich-dev + prompt contains "git commit" → ALLOW (dev can commit)
#   TC4 — Bash tool (non-Agent) + any → ALLOW (only guards Agent dispatches)
#   TC5 — env STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 + sandwich-architect + "git commit" → ALLOW (bypass)
#   TC6 — stdin empty → ALLOW (defensive)
#
# Exit 0 = all pass. Exit 1 = any fail.
#
# S341 D3: companion firing-test per Charter v1.1 Principle 11.

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

note_pass() { PASS=$(( PASS + 1 )); }
note_fail() {
  FAIL=$(( FAIL + 1 ))
  ERRORS+=("$1")
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../pre-dispatch-architect-commit-guard.sh"

[ -f "$HOOK" ] || { echo "FAIL: hook not found at $HOOK"; exit 1; }
chmod +x "$HOOK" 2>/dev/null || true

TMP="$(mktemp -d -t architect-guard-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/agent-workspace/memory"

run_hook() {
  local payload="$1"
  local rc=0
  CLAUDE_PROJECT_DIR="$TMP" printf '%s' "$payload" | bash "$HOOK" 2>/dev/null || rc=$?
  echo "$rc"
}

# Helper to build a minimal PreToolUse JSON payload
make_payload() {
  local tool_name="$1"
  local subagent_type="$2"
  local prompt="$3"
  printf '{"tool_name":"%s","tool_input":{"subagent_type":"%s","prompt":"%s"}}' \
    "$tool_name" "$subagent_type" "$prompt"
}

# ============================================================
# TC1: Agent + sandwich-architect + "git commit" → BLOCKED (RC=2)
# ============================================================
PAYLOAD=$(make_payload "Agent" "sandwich-architect" "Please git commit the plan file and push it.")
RC=$(run_hook "$PAYLOAD")
if [ "$RC" -eq 2 ]; then
  note_pass
else
  note_fail "TC1: expected RC=2 (BLOCKED) for architect+git commit, got RC=$RC"
fi

# ============================================================
# TC2: Agent + sandwich-architect + clean prompt → ALLOW (RC=0)
# ============================================================
PAYLOAD=$(make_payload "Agent" "sandwich-architect" "Read the codebase and produce a plan file for feature X.")
RC=$(run_hook "$PAYLOAD")
if [ "$RC" -eq 0 ]; then
  note_pass
else
  note_fail "TC2: expected RC=0 (ALLOW) for clean architect prompt, got RC=$RC"
fi

# ============================================================
# TC3: Agent + sandwich-dev + "git commit" → ALLOW (dev can commit)
# ============================================================
PAYLOAD=$(make_payload "Agent" "sandwich-dev" "Implement the plan and git commit at the end.")
RC=$(run_hook "$PAYLOAD")
if [ "$RC" -eq 0 ]; then
  note_pass
else
  note_fail "TC3: expected RC=0 (ALLOW) for sandwich-dev+git commit (dev can commit), got RC=$RC"
fi

# ============================================================
# TC4: Bash tool (non-Agent) → ALLOW regardless of content
# ============================================================
PAYLOAD='{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}'
RC=$(run_hook "$PAYLOAD")
if [ "$RC" -eq 0 ]; then
  note_pass
else
  note_fail "TC4: expected RC=0 (ALLOW) for Bash tool (not Agent), got RC=$RC"
fi

# ============================================================
# TC5: override STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1 → ALLOW
# ============================================================
PAYLOAD=$(make_payload "Agent" "sandwich-architect" "git commit the plan immediately after writing it.")
RC=0
export STOCKFORGE_ALLOW_ARCHITECT_COMMIT=1
CLAUDE_PROJECT_DIR="$TMP" printf '%s' "$PAYLOAD" | bash "$HOOK" 2>/dev/null || RC=$?
unset STOCKFORGE_ALLOW_ARCHITECT_COMMIT
if [ "$RC" -eq 0 ]; then
  note_pass
else
  note_fail "TC5: expected RC=0 (ALLOW) with override env, got RC=$RC"
fi

# ============================================================
# TC6: stdin empty → ALLOW (defensive)
# ============================================================
RC=0
CLAUDE_PROJECT_DIR="$TMP" printf '' | bash "$HOOK" 2>/dev/null || RC=$?
if [ "$RC" -eq 0 ]; then
  note_pass
else
  note_fail "TC6: expected RC=0 (ALLOW) for empty stdin, got RC=$RC"
fi

# ============================================================
# Summary
# ============================================================
TOTAL=$(( PASS + FAIL ))
echo "pre-dispatch-architect-commit-guard-fire-test: ${PASS}/${TOTAL} PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do
    echo "  FAIL: $e"
  done
  exit 1
fi
exit 0
