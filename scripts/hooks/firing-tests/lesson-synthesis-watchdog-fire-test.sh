#!/usr/bin/env bash
# Firing-test for lesson-synthesis-watchdog.sh (L-S49b-4 charter-coverage push; S75).
#
# Hook purpose (Stop hook; per BP-S43b-4 / KI-S43b-5; D-026 Rule 4b STRICT mode):
#   - counts files touched in production tree via `git status --short -- packages/ apps/`
#   - if PROD_TOUCHED < 1 → skip (logs "under threshold")
#   - else: counts recent (mtime <1d) writes to known-issues.md / best-practices.md /
#     agent-notes.md
#   - if LESSON_TOTAL==0 → STRICT-ALERT (exit 2) + log entry + stderr msg + ETL queue
#     job enqueued (priority 2; basename `2-<utc-ts>-lesson-synthesize.job`)
#   - kill switch: MEMORY_ETL_DISABLE=1 → still exits 2 STRICT-ALERT but skips ETL
#     enqueue
#
# 4 test cases:
#   TC1 — TEMPDIR git init but NO production touch → exit 0; "under threshold; skip" log
#   TC2 — production touch (packages/foo.py untracked) + fresh agent-notes.md → exit 0;
#         normal log entry "notes_recent=1"; NO STRICT-ALERT
#   TC3 — production touch + ZERO recent lesson files → exit 2; STRICT-ALERT in log +
#         stderr; ETL job enqueued at memory/etl-queue/2-*-lesson-synthesize.job
#   TC4 — same as TC3 + MEMORY_ETL_DISABLE=1 → exit 2; STRICT-ALERT log; NO ETL job
#         (kill-switch verified)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../lesson-synthesis-watchdog.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
SA_DIR="$MEM_DIR/self-awareness"
LOG="$MEM_DIR/.lesson-synthesis.log"
ETL_QUEUE_DIR="$MEM_DIR/etl-queue"

clean_state() {
  rm -rf "$TEMPDIR/.git" "$TEMPDIR/agent-workspace" "$TEMPDIR/packages" "$TEMPDIR/apps"
  mkdir -p "$MEM_DIR" "$SA_DIR" "$TEMPDIR/packages" "$TEMPDIR/apps"
  ( cd "$TEMPDIR" && git init -q && git config user.email "test@example.com" && git config user.name "Test" )
}

# --- TC1: production tree exists but nothing touched → exit 0; skip log ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "under threshold; skip" "$LOG"; then
  echo "FAIL TC1: log should record 'under threshold; skip'"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC1: no production files touched → skip log + exit 0"

# --- TC2: production touch + fresh agent-notes.md → normal log + exit 0 ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
echo "# agent notes" > "$MEM_DIR/agent-notes.md"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0 (lesson present); got $RC"
  exit 1
fi
if ! grep -q "notes_recent=1" "$LOG"; then
  echo "FAIL TC2: log should record notes_recent=1"
  cat "$LOG"
  exit 1
fi
if grep -q "STRICT-ALERT" "$LOG"; then
  echo "FAIL TC2: log should NOT STRICT-ALERT when agent-notes.md fresh"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: production touch + fresh agent-notes → normal log + exit 0"

# --- TC3: production touch + ZERO lessons → STRICT-ALERT exit 2 + ETL job ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
# NO agent-notes / KI / BP — all missing → all _RECENT=0
STDERR="$TEMPDIR/tc3.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC3: expected exit 2 (STRICT-ALERT); got $RC"
  cat "$STDERR" 2>/dev/null
  cat "$LOG" 2>/dev/null
  exit 1
fi
if ! grep -q "STRICT-ALERT" "$LOG"; then
  echo "FAIL TC3: log missing STRICT-ALERT"
  cat "$LOG"
  exit 1
fi
if ! grep -q "STRICT-ALERT" "$STDERR"; then
  echo "FAIL TC3: stderr missing STRICT-ALERT"
  cat "$STDERR"
  exit 1
fi
ETL_JOB=$(find "$ETL_QUEUE_DIR" -name '2-*-lesson-synthesize.job' 2>/dev/null | head -1 || true)
if [ -z "$ETL_JOB" ]; then
  echo "FAIL TC3: ETL job not enqueued under $ETL_QUEUE_DIR"
  ls -la "$ETL_QUEUE_DIR/" 2>/dev/null || echo "(etl-queue dir missing)"
  exit 1
fi
if ! grep -q "task: lesson-synthesize" "$ETL_JOB"; then
  echo "FAIL TC3: ETL job malformed (missing 'task: lesson-synthesize')"
  cat "$ETL_JOB"
  exit 1
fi
echo "PASS TC3: production touch + zero lessons → STRICT-ALERT exit 2 + ETL job"

# --- TC4: STRICT-ALERT path + MEMORY_ETL_DISABLE=1 → exit 2 + NO ETL job (kill switch) ---
clean_state
echo "stub" > "$TEMPDIR/packages/foo.py"
RC=0
MEMORY_ETL_DISABLE=1 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC4: expected exit 2 (STRICT-ALERT still fires); got $RC"
  exit 1
fi
if ! grep -q "STRICT-ALERT" "$LOG"; then
  echo "FAIL TC4: log missing STRICT-ALERT under kill switch"
  exit 1
fi
ETL_JOB=$(find "$ETL_QUEUE_DIR" -name '2-*-lesson-synthesize.job' 2>/dev/null | head -1 || true)
if [ -n "$ETL_JOB" ]; then
  echo "FAIL TC4: ETL job should NOT exist with MEMORY_ETL_DISABLE=1"
  ls -la "$ETL_QUEUE_DIR/" 2>/dev/null
  exit 1
fi
echo "PASS TC4: MEMORY_ETL_DISABLE=1 → STRICT-ALERT exit 2 + ETL job suppressed"

echo ""
echo "=== ALL FIRING-TESTS PASSED (4/4) ==="
echo "lesson-synthesis-watchdog.sh externally-observable behavior verified."
exit 0
