#!/usr/bin/env bash
# Firing-test for checkpoint-marker-cleanup-resume.sh (L-S49b-4 charter-coverage push; S77).
#
# Hook purpose (SessionStart hook; companion to checkpoint-write-marker.sh + end-turn-watchdog):
#   - Two responsibilities:
#     1) CLEANUP: delete stale `.checkpoint-written-<sid>` markers from sessions other
#        than CLAUDE_SESSION_ID; without cleanup, old marker would block tool calls.
#     2) RESUME: if `.fresh-resume-pending-<sid>` exists from prior session AND
#        current-execution.md has `**autonomous_mode**: true`, emit system-reminder
#        (stdout becomes additionalContext) + delete marker. If autonomous=false,
#        marker still deleted but no reminder emitted.
#
# 5 test cases:
#   TC1 — no markers → silent exit 0 (no log entry, no stdout)
#   TC2 — stale .checkpoint-written-OLD-SID (≠ current) → cleaned + log "cleaned=N"
#   TC3 — .checkpoint-written-CURRENT_SID → NOT cleaned (own session)
#   TC4 — .fresh-resume-pending-OTHER + autonomous_mode=true → stdout reminder + marker deleted + log
#   TC5 — .fresh-resume-pending-OTHER + autonomous_mode=false → no stdout reminder + marker deleted + log
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../checkpoint-marker-cleanup-resume.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
EXEC_FILE="$MEM_DIR/current-execution.md"
CURRENT_SID="current-session-abc"
OLD_SID="old-session-xyz"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

# --- TC1: no markers → silent exit 0 ---
clean_state
RC=0
STDOUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$CURRENT_SID" bash "$HOOK" </dev/null 2>/dev/null) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ] && grep -q "checkpoint-marker-cleanup" "$LOG"; then
  echo "FAIL TC1: log should be empty when no markers"
  cat "$LOG"
  exit 1
fi
if [ -n "$STDOUT" ]; then
  echo "FAIL TC1: stdout should be empty"
  echo "STDOUT: $STDOUT"
  exit 1
fi
echo "PASS TC1: no markers → silent exit 0"

# --- TC2: stale .checkpoint-written-OLD-SID → cleaned + log ---
clean_state
touch "$MEM_DIR/.checkpoint-written-$OLD_SID"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$CURRENT_SID" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$MEM_DIR/.checkpoint-written-$OLD_SID" ]; then
  echo "FAIL TC2: stale marker should be deleted"
  ls -la "$MEM_DIR/" 2>/dev/null
  exit 1
fi
if ! grep -q "checkpoint-marker-cleanup: cleaned=1" "$LOG"; then
  echo "FAIL TC2: log should record cleaned=1"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC2: stale marker deleted + log cleaned=1"

# --- TC3: .checkpoint-written-CURRENT_SID → NOT cleaned (own session) ---
clean_state
touch "$MEM_DIR/.checkpoint-written-$CURRENT_SID"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$CURRENT_SID" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$MEM_DIR/.checkpoint-written-$CURRENT_SID" ]; then
  echo "FAIL TC3: own-session marker should NOT be deleted"
  exit 1
fi
if grep -q "cleanup: cleaned=" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: log should NOT record cleaned (own marker preserved)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: own-session marker preserved (CURRENT_SID match)"

# --- TC4: .fresh-resume-pending + autonomous=true → stdout reminder + marker deleted ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: true

## S76 — last session
Some content.
EOF
cat > "$MEM_DIR/.fresh-resume-pending-$OLD_SID" <<'EOF'
checkpoint_ref=agent-workspace/memory/checkpoints/latest.md
prior_session_id=old-session-xyz
next_action_excerpt=Continue L-S49b-4 charter-coverage push (next 3-4 hooks: ghost-work-audit + proposal-bundle-advisor + checkpoint-marker-cleanup-resume + taskcompleted-audit)
EOF
RC=0
STDOUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$CURRENT_SID" bash "$HOOK" </dev/null 2>/dev/null) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$MEM_DIR/.fresh-resume-pending-$OLD_SID" ]; then
  echo "FAIL TC4: resume marker should be consumed (deleted)"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "AUTONOMOUS RESUME PENDING"; then
  echo "FAIL TC4: stdout should contain AUTONOMOUS RESUME PENDING reminder"
  echo "STDOUT: $STDOUT"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "$OLD_SID"; then
  echo "FAIL TC4: stdout should reference prior session ID"
  echo "STDOUT: $STDOUT"
  exit 1
fi
if ! echo "$STDOUT" | grep -q "L-S49b-4"; then
  echo "FAIL TC4: stdout should include next_action_excerpt content"
  echo "STDOUT: $STDOUT"
  exit 1
fi
if ! grep -q "resume-pending consumed prior_sid=$OLD_SID autonomous=true" "$LOG"; then
  echo "FAIL TC4: log should record consumption with autonomous=true"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: resume marker + autonomous=true → stdout reminder + marker consumed + log"

# --- TC5: .fresh-resume-pending + autonomous=false → no stdout reminder, marker still deleted ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: false

## S76 — last session
EOF
cat > "$MEM_DIR/.fresh-resume-pending-$OLD_SID" <<'EOF'
checkpoint_ref=agent-workspace/memory/checkpoints/latest.md
prior_session_id=old-session-xyz
next_action_excerpt=Resume routine work
EOF
RC=0
STDOUT=$(CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$CURRENT_SID" bash "$HOOK" </dev/null 2>/dev/null) || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$MEM_DIR/.fresh-resume-pending-$OLD_SID" ]; then
  echo "FAIL TC5: resume marker should be deleted even when autonomous=false"
  exit 1
fi
if echo "$STDOUT" | grep -q "AUTONOMOUS RESUME PENDING"; then
  echo "FAIL TC5: stdout should NOT contain AUTONOMOUS RESUME PENDING when autonomous=false"
  echo "STDOUT: $STDOUT"
  exit 1
fi
if ! grep -q "resume-pending consumed prior_sid=$OLD_SID autonomous=false" "$LOG"; then
  echo "FAIL TC5: log should record consumption with autonomous=false"
  cat "$LOG"
  exit 1
fi
if ! grep -q "autonomous=false — resume marker deleted silently" "$LOG"; then
  echo "FAIL TC5: log should record silent-delete branch"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: resume marker + autonomous=false → marker deleted + log silent (no stdout)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "checkpoint-marker-cleanup-resume.sh externally-observable behavior verified."
exit 0
