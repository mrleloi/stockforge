#!/usr/bin/env bash
# project-integrity-watchdog-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
# SPAWN-CONTEXT: positional-arg

set -uo pipefail
PASS=0; FAIL=0; ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/project-integrity-watchdog.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable"; exit 1; }

TMP="$(mktemp -d -t pintegrity-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_healthy() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory/decisions" "$TMP/agent-workspace/memory/sessions"
  mkdir -p "$TMP/agent-workspace/constitution" "$TMP/scripts/hooks" "$TMP/.claude" "$TMP/.git"
  mkdir -p "$TMP/human-workspace/notifications"
  touch "$TMP/PROJECT_CHARTER.md" "$TMP/CLAUDE.md" "$TMP/AGENT_OPERATING_MANUAL.md" "$TMP/.git/HEAD"
  touch "$TMP/agent-workspace/memory/agent-notes.md" "$TMP/agent-workspace/memory/current-execution.md"
  touch "$TMP/agent-workspace/memory/mistake-log.md"
}

run_hook() { CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" "${1:-Stop}" >/dev/null 2>&1; }

# TC1: healthy project → no block flag
setup_healthy
run_hook Stop
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC1: block flag should NOT exist for healthy project" || note_pass

# TC2: PROJECT_CHARTER.md missing → block flag written
setup_healthy
rm -f "$TMP/PROJECT_CHARTER.md"
run_hook Stop
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_pass || note_fail "TC2: block flag SHOULD exist when PROJECT_CHARTER.md missing"

# TC3: .git/HEAD missing → block flag written
setup_healthy
rm -f "$TMP/.git/HEAD"
run_hook Stop
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_pass || note_fail "TC3: block flag SHOULD exist when .git/HEAD missing"

# TC4: canonical dir missing → block flag written
setup_healthy
rm -rf "$TMP/agent-workspace/constitution"
run_hook Stop
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_pass || note_fail "TC4: block flag SHOULD exist when constitution/ dir missing"

# TC5: block flag content lists missing artifacts
setup_healthy
rm -f "$TMP/CLAUDE.md"
run_hook Stop
if grep -q "CLAUDE.md" "$TMP/agent-workspace/memory/.autonomous-BLOCKED" 2>/dev/null; then note_pass; else note_fail "TC5: block flag should name the missing artifact"; fi

# TC6: urgent.md alert written on violation
setup_healthy
rm -f "$TMP/AGENT_OPERATING_MANUAL.md"
run_hook Stop
if grep -q "PROJECT INTEGRITY VIOLATION" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null; then note_pass; else note_fail "TC6: urgent.md should get alert"; fi

# TC7: RC=0 always (even on violation)
setup_healthy
rm -f "$TMP/PROJECT_CHARTER.md"
CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" Stop >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC7: hook must exit RC=0 even on violation (got $RC)"

TOTAL=$((PASS+FAIL))
echo "project-integrity-watchdog-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
