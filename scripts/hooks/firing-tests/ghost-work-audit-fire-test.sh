#!/usr/bin/env bash
# Firing-test for ghost-work-audit.sh (L-S49b-4 charter-coverage push; S77).
#
# Hook purpose (SessionStart hook; C4 promote-rule S43c per L-S43b-11):
#   - cd to PROJECT_DIR; require git
#   - List untracked files: `git status --short | awk '$1=="??"{print $2}'`
#   - Filter to packages/*.py
#   - Exempt: test_*.py / *_test.py / __init__.py / /migrations/ / /generated/
#   - 0 untracked → log "OK (0 untracked source files under packages/)"
#   - N untracked + latest session log has GHOST-WORK FOUND → log INFO (documented)
#   - N untracked + NOT documented → log ALERT + stderr message + exit 0 (soft warn)
#
# 5 test cases:
#   TC1 — clean repo (0 untracked) → log OK
#   TC2 — untracked test_foo.py (exempt by test_ prefix) → log OK (0 effective)
#   TC3 — untracked packages/foo.py + no session log → ALERT log + stderr
#   TC4 — untracked packages/foo.py + session log contains "GHOST-WORK FOUND" → log INFO (documented)
#   TC5 — untracked packages/migrations/foo.py (exempt by /migrations/) → log OK
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../ghost-work-audit.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: hook depends on git for `git status --short`.
if ! command -v git >/dev/null 2>&1; then
  echo "SKIP: git not installed; ghost-work-audit requires git for status --short"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
SESSIONS_DIR="$MEM_DIR/sessions"
PACKAGES_DIR="$TEMPDIR/packages"
LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/.git" "$TEMPDIR/agent-workspace" "$PACKAGES_DIR" "$TEMPDIR/packages"
  mkdir -p "$MEM_DIR" "$SESSIONS_DIR" "$PACKAGES_DIR" "$PACKAGES_DIR/migrations"
  # Pre-track packages/ + packages/migrations/ via baseline .gitkeep commit.
  # Without this, `git status --short` rolls fully-untracked dirs up to "?? packages/" (no per-file list)
  # and the hook regex `^packages/.+\.py$` fails to match. Production state has packages/ already-tracked,
  # so individual untracked .py files surface — this fixture matches that.
  ( cd "$TEMPDIR" && git init -q && git config user.email "test@example.com" && git config user.name "Test" \
      && touch packages/.gitkeep packages/migrations/.gitkeep \
      && git add packages/.gitkeep packages/migrations/.gitkeep >/dev/null 2>&1 \
      && git commit -q -m "baseline" >/dev/null 2>&1 )
}

# --- TC1: clean repo (0 untracked) → log OK ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "ghost-work-audit OK (0 untracked source files" "$LOG"; then
  echo "FAIL TC1: log should record OK 0-untracked"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC1: clean repo → log OK"

# --- TC2: untracked test_foo.py (exempt by test_ prefix) → log OK ---
clean_state
echo "stub" > "$PACKAGES_DIR/test_foo.py"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "ghost-work-audit OK (0 untracked source files" "$LOG"; then
  echo "FAIL TC2: test_*.py should be exempt — log should record OK"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if grep -q "ghost-work-audit ALERT" "$LOG"; then
  echo "FAIL TC2: should NOT ALERT for exempt test file"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: untracked test_foo.py → exempt → log OK"

# --- TC3: untracked packages/foo.py + no session log → ALERT log + stderr ---
clean_state
echo "stub" > "$PACKAGES_DIR/foo.py"
STDERR="$TEMPDIR/tc3.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0 (soft-warn); got $RC"
  cat "$STDERR" 2>/dev/null
  exit 1
fi
if ! grep -q "ghost-work-audit ALERT 1 untracked source file" "$LOG"; then
  echo "FAIL TC3: log should ALERT 1 untracked"
  cat "$LOG"
  exit 1
fi
if ! grep -q "packages/foo.py" "$LOG"; then
  echo "FAIL TC3: log should list packages/foo.py file"
  cat "$LOG"
  exit 1
fi
if ! grep -q "ghost-work-audit ALERT" "$STDERR"; then
  echo "FAIL TC3: stderr should contain ALERT message"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC3: untracked packages/foo.py → ALERT log + stderr"

# --- TC4: untracked packages/foo.py + session log with GHOST-WORK FOUND → log INFO (documented) ---
clean_state
echo "stub" > "$PACKAGES_DIR/foo.py"
cat > "$SESSIONS_DIR/2026-05-06-session-X.md" <<'EOF'
# Session X — GHOST-WORK FOUND audit
GHOST-WORK FOUND: packages/foo.py provenance audited via git log; benign.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "ghost-work-audit INFO 1 untracked source file" "$LOG"; then
  echo "FAIL TC4: log should record INFO when GHOST-WORK FOUND in latest session"
  cat "$LOG"
  exit 1
fi
if grep -q "ghost-work-audit ALERT" "$LOG"; then
  echo "FAIL TC4: should NOT ALERT when documented in session log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: untracked + documented in latest session → log INFO"

# --- TC5: untracked packages/migrations/foo.py (exempt by /migrations/) → log OK ---
clean_state
mkdir -p "$PACKAGES_DIR/migrations"
echo "stub" > "$PACKAGES_DIR/migrations/foo.py"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "ghost-work-audit OK (0 untracked source files" "$LOG"; then
  echo "FAIL TC5: /migrations/ files should be exempt — log should record OK"
  cat "$LOG"
  exit 1
fi
if grep -q "ghost-work-audit ALERT" "$LOG"; then
  echo "FAIL TC5: should NOT ALERT for /migrations/ exempt file"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: untracked /migrations/ file → exempt → log OK"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "ghost-work-audit.sh externally-observable behavior verified."
exit 0
