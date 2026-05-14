#!/usr/bin/env bash
# destructive-command-guard-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Exercises destructive-command-guard.sh via stdin JSON (the actual PreToolUse spawn topology).
#
# SPAWN-CONTEXT: bash-c (hook reads tool_input.command from stdin JSON; firing-test feeds JSON via stdin)

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/destructive-command-guard.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t dcg-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/agent-workspace/memory"

# Helper: run hook with a JSON payload on stdin, return RC
run_cmd() {
  local cmd_json="$1"
  local override="${2:-0}"
  printf '%s' "$cmd_json" | CLAUDE_PROJECT_DIR="$TMP" STOCKFORGE_ALLOW_DESTRUCTIVE="$override" bash "$HOOK" PreToolUse >/dev/null 2>&1
  return $?
}

# JSON builder (minimal)
mkjson() {
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

# === BLOCK cases (expect RC=2) ===
echo "--- BLOCK cases (expect RC=2) ---"

for dangerous in \
  'rm -rf /c/htdocs/stockforge' \
  'rm -rf .' \
  'rm -r agent-workspace' \
  'rm -fr some-dir' \
  'find . -type f -delete' \
  'find . -newer marker -delete' \
  'find /c/htdocs -mtime +0 -exec rm {} ;' \
  'git reset --hard HEAD~5' \
  'git reset --hard origin/main' \
  'git clean -fd' \
  'git clean -fdx' \
  'git checkout HEAD -- .' \
  'git checkout HEAD --' \
  'git worktree remove ../wt' \
  'git stash' \
  'git stash push -m foo' \
  'dd if=/dev/zero of=/dev/sda' \
  'chmod -R 777 /' \
  'chown -R user /c'
do
  run_cmd "$(mkjson "$dangerous")"
  RC=$?
  if [ "$RC" -eq 2 ]; then note_pass; else note_fail "BLOCK expected RC=2 for: $dangerous (got $RC)"; fi
done

# === ALLOW cases (expect RC=0) ===
echo "--- ALLOW cases (expect RC=0) ---"

for safe in \
  'ls -la' \
  'git status' \
  'git add -A' \
  'git commit -m test' \
  'git log --oneline -5' \
  'cat file.txt' \
  'grep pattern file' \
  'python -m pytest' \
  'echo hello' \
  'rm -f agent-workspace/memory/.autonomous-BLOCKED' \
  'rm -f agent-workspace/memory/.severity-state.tsv' \
  'rm -f agent-workspace/memory/.telegram-pushed-abc123' \
  'rm -f agent-workspace/memory/.escalation-fired-Stop-20260514-11' \
  'find agent-workspace/memory -maxdepth 1 -name ".pydet-marker-*" -mmin +120 -delete' \
  'find agent-workspace/memory -maxdepth 1 -name ".telegram-pushed-*" -mtime +1 -delete' \
  'mkdir -p some/dir' \
  'cp file1 file2'
do
  run_cmd "$(mkjson "$safe")"
  RC=$?
  if [ "$RC" -eq 0 ]; then note_pass; else note_fail "ALLOW expected RC=0 for: $safe (got $RC)"; fi
done

# === OVERRIDE case: destructive + STOCKFORGE_ALLOW_DESTRUCTIVE=1 → RC=0 ===
echo "--- OVERRIDE case ---"
run_cmd "$(mkjson 'rm -rf some-dir')" 1
RC=$?
if [ "$RC" -eq 0 ]; then note_pass; else note_fail "OVERRIDE expected RC=0 with STOCKFORGE_ALLOW_DESTRUCTIVE=1 (got $RC)"; fi

# === Non-Bash tool → always allow ===
echo "--- Non-Bash tool passthrough ---"
printf '{"tool_name":"Read","tool_input":{"file_path":"/etc/passwd"}}' | CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" PreToolUse >/dev/null 2>&1
RC=$?
if [ "$RC" -eq 0 ]; then note_pass; else note_fail "Non-Bash tool expected RC=0 (got $RC)"; fi

# === Empty stdin → allow (defensive) ===
echo "--- Empty stdin ---"
printf '' | CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" PreToolUse >/dev/null 2>&1
RC=$?
if [ "$RC" -eq 0 ]; then note_pass; else note_fail "Empty stdin expected RC=0 (got $RC)"; fi

# === Summary ===
TOTAL=$((PASS+FAIL))
echo ""
echo "destructive-command-guard-fire-test: $PASS/$TOTAL PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do echo "  - $e"; done
  exit 1
fi
exit 0
