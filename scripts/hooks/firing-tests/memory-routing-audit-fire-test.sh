#!/usr/bin/env bash
# Firing-test for memory-routing-audit.sh (L-S49b-4 charter-coverage push; S75).
#
# Hook purpose (Stop hook; companion to HR-4 charter proposal memory-routing-tree.md):
#   - Step 1: PROD_TOUCHED via `git status --short -- packages/ apps/ agent-workspace/`
#   - Step 2: USER_MEM_FRESH=1 if STOCKFORGE_USER_MEMORY_DIR/MEMORY.md mtime <1d OR
#     any *.md inside STOCKFORGE_USER_MEMORY_DIR mtime <1d
#   - Step 3: NOTES_RECENT = mtime of agent-workspace/memory/agent-notes.md within 1d
#   - ALERT (stderr + log) if PROD_TOUCHED>=1 AND USER_MEM_FRESH=1 AND NOTES_RECENT=0
#   - HARD-BLOCK (exit 2) if STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1 OR
#     STOCKFORGE_HOOK_PROFILE=strict (default mode is exit 0 with stderr advisory)
#
# 5 test cases:
#   TC1 — no PROD_TOUCHED → "skip" log; exit 0
#   TC2 — PROD_TOUCHED + fresh agent-notes.md → no ALERT; exit 0
#   TC3 — PROD_TOUCHED + USER_MEM_FRESH + NOTES not fresh → ALERT log + stderr; exit 0 (default mode)
#   TC4 — same as TC3 + STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1 → ALERT + exit 2
#   TC5 — same as TC3 + STOCKFORGE_HOOK_PROFILE=strict → ALERT + exit 2
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../memory-routing-audit.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
USER_MEM_DIR="$TEMPDIR/user-memory"
LOG="$MEM_DIR/.memory-routing-audit.log"

clean_state() {
  rm -rf "$TEMPDIR/.git" "$TEMPDIR/agent-workspace" "$TEMPDIR/packages" "$TEMPDIR/apps" "$USER_MEM_DIR"
  mkdir -p "$MEM_DIR" "$TEMPDIR/packages" "$TEMPDIR/apps" "$USER_MEM_DIR"
  ( cd "$TEMPDIR" && git init -q && git config user.email "test@example.com" && git config user.name "Test" )
}

# --- TC1: no PROD_TOUCHED → skip log + exit 0 ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" STOCKFORGE_USER_MEMORY_DIR="$USER_MEM_DIR" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "prod_touched=0; skip" "$LOG"; then
  echo "FAIL TC1: log should record skip"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC1: no production files touched → skip log + exit 0"

# --- TC2: PROD_TOUCHED + fresh agent-notes.md → no ALERT; exit 0 ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
echo "# notes" > "$MEM_DIR/agent-notes.md"
echo "# user index" > "$USER_MEM_DIR/MEMORY.md"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" STOCKFORGE_USER_MEMORY_DIR="$USER_MEM_DIR" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if grep -q "ALERT" "$LOG"; then
  echo "FAIL TC2: log should NOT ALERT when agent-notes.md fresh"
  cat "$LOG"
  exit 1
fi
if ! grep -q "notes_recent=1" "$LOG"; then
  echo "FAIL TC2: log should record notes_recent=1"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: production touch + fresh agent-notes → no ALERT, exit 0"

# --- TC3: PROD_TOUCHED + USER_MEM_FRESH + NOTES_RECENT=0 → ALERT (default mode exit 0) ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
# NO agent-notes.md (NOTES_RECENT=0)
echo "# user index" > "$USER_MEM_DIR/MEMORY.md"
echo "# user mem entry" > "$USER_MEM_DIR/some_entry.md"
STDERR="$TEMPDIR/tc3.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" STOCKFORGE_USER_MEMORY_DIR="$USER_MEM_DIR" \
  bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0 (default mode); got $RC"
  cat "$STDERR" 2>/dev/null
  exit 1
fi
if ! grep -q "ALERT" "$LOG"; then
  echo "FAIL TC3: log missing ALERT"
  cat "$LOG"
  exit 1
fi
if ! grep -q "memory-routing-audit ALERT" "$STDERR"; then
  echo "FAIL TC3: stderr missing ALERT"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC3: triple-trigger → ALERT log + stderr (default mode exit 0)"

# --- TC4: same as TC3 + HARDBLOCK env → exit 2 ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
echo "# user mem" > "$USER_MEM_DIR/MEMORY.md"
RC=0
STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1 CLAUDE_PROJECT_DIR="$TEMPDIR" \
  STOCKFORGE_USER_MEMORY_DIR="$USER_MEM_DIR" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC4: expected exit 2 (HARDBLOCK); got $RC"
  exit 1
fi
if ! grep -q "ALERT" "$LOG"; then
  echo "FAIL TC4: log missing ALERT under HARDBLOCK"
  exit 1
fi
if ! grep -q "HARD-BLOCK exit=2" "$MEM_DIR/.session-hooks.log"; then
  echo "FAIL TC4: session-hooks.log missing HARD-BLOCK record"
  cat "$MEM_DIR/.session-hooks.log" 2>/dev/null
  exit 1
fi
echo "PASS TC4: STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1 → exit 2"

# --- TC5: same as TC3 + STOCKFORGE_HOOK_PROFILE=strict → exit 2 ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
echo "# user mem" > "$USER_MEM_DIR/MEMORY.md"
RC=0
STOCKFORGE_HOOK_PROFILE=strict CLAUDE_PROJECT_DIR="$TEMPDIR" \
  STOCKFORGE_USER_MEMORY_DIR="$USER_MEM_DIR" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC5: expected exit 2 (strict profile); got $RC"
  exit 1
fi
if ! grep -q "ALERT" "$LOG"; then
  echo "FAIL TC5: log missing ALERT under strict profile"
  exit 1
fi
echo "PASS TC5: STOCKFORGE_HOOK_PROFILE=strict → exit 2"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "memory-routing-audit.sh externally-observable behavior verified."
exit 0
