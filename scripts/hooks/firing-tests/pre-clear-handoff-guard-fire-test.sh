#!/usr/bin/env bash
# Firing-test for pre-clear-handoff-guard.sh (Phase 3.5 T7 retrofit; S63).
#
# Hook purpose (BP-S43b-6 / KI-S43b-6; Stop hook priority 1):
# Detect pending-decision triggers in latest session log + raw-session log
# (AskUserQuestion / lettered options menu / SCOPE/charter-tier deferral /
# wind_down / cliff / q-and-a/pending) AND/OR ⚠️ unverified markers in
# checkpoints/latest.md, while checkpoint mtime is stale (>2h). If both
# pending=1 AND checkpoint_fresh=0 → ALERT to stderr + log entry.
# HR-7: STOCKFORGE_HANDOFF_HARDBLOCK=1 OR STOCKFORGE_HOOK_PROFILE=strict
# upgrades advisory exit 0 to hard-block exit 2.
#
# Test strategy: stage temp PROJECT_DIR with controlled session/checkpoint
# fixtures; invoke hook; assert exit code + log content + stderr ALERT.
#
# 6 test cases:
#   TC1 — no session log + no checkpoint → silent no-op (PENDING=0)
#   TC2 — clean session log + fresh checkpoint → no ALERT
#   TC3 — session log with AskUserQuestion + stale checkpoint → ALERT + log
#   TC4 — checkpoint with ⚠️ unverified marker + stale checkpoint → ALERT
#   TC5 — pending triggers + fresh checkpoint (mtime <2h) → no ALERT
#   TC6 — STRICT mode env + pending + stale → exit 2
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../pre-clear-handoff-guard.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.handoff-guard.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory/sessions" \
           "$TEMPDIR/agent-workspace/memory/checkpoints" \
           "$TEMPDIR/agent-workspace/raw-sessions"
}

# --- TC1: no session log + no checkpoint → silent no-op ---
clean_state
STDERR="$TEMPDIR/tc1.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  cat "$STDERR" || true
  exit 1
fi
if grep -q "ALERT" "$STDERR" 2>/dev/null; then
  echo "FAIL TC1: should NOT emit ALERT when no session log exists"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC1: no session log → silent no-op"

# --- TC2: clean session log + fresh checkpoint → no ALERT ---
clean_state
echo "Session ran cleanly. No triggers." > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-clean.md"
echo "# Checkpoint clean" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
STDERR="$TEMPDIR/tc2.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if grep -q "ALERT" "$STDERR" 2>/dev/null; then
  echo "FAIL TC2: clean session log should NOT emit ALERT"
  cat "$STDERR"
  exit 1
fi
echo "PASS TC2: clean session log + fresh checkpoint → no ALERT"

# --- TC3: pending triggers + stale checkpoint → ALERT ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-pending.md" <<'EOF'
# Session ran AskUserQuestion mid-session.
Lettered options menu surfaced:
  (a) option a
  (b) option b
EOF
echo "# Stale checkpoint" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
touch -d "3 hours ago" "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
STDERR="$TEMPDIR/tc3.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected advisory exit 0; got $RC"
  exit 1
fi
if ! grep -q "ALERT" "$STDERR"; then
  echo "FAIL TC3: expected ALERT in stderr (pending+stale)"
  cat "$STDERR"
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "FAIL TC3: expected $LOG to exist"
  exit 1
fi
if ! grep -q "pending=1" "$LOG"; then
  echo "FAIL TC3: expected 'pending=1' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: pending triggers + stale checkpoint → ALERT"

# --- TC4: checkpoint with ⚠️ unverified marker + stale → ALERT ---
clean_state
echo "Session was clean." > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-clean.md"
cat > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md" <<'EOF'
# Checkpoint with unverified marker
- ⚠️ unverified file foo.md
EOF
touch -d "3 hours ago" "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
STDERR="$TEMPDIR/tc4.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected advisory exit 0; got $RC"
  exit 1
fi
if ! grep -q "ALERT" "$STDERR"; then
  echo "FAIL TC4: expected ALERT (unverified+stale)"
  cat "$STDERR"
  exit 1
fi
if ! grep -q "unverified" "$LOG"; then
  echo "FAIL TC4: expected 'unverified' trigger in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: ⚠️ unverified + stale checkpoint → ALERT"

# --- TC5: pending triggers + fresh checkpoint → no ALERT ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-pending.md" <<'EOF'
# Session ran AskUserQuestion. q-and-a/pending triggered.
EOF
echo "# Fresh checkpoint" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
touch "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
STDERR="$TEMPDIR/tc5.stderr"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if grep -q "ALERT" "$STDERR" 2>/dev/null; then
  echo "FAIL TC5: fresh checkpoint should suppress ALERT"
  cat "$STDERR"
  exit 1
fi
if ! grep -q "checkpoint_fresh=1" "$LOG"; then
  echo "FAIL TC5: expected 'checkpoint_fresh=1' in log"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: pending + fresh checkpoint → no ALERT"

# --- TC6: STRICT mode env + pending + stale → exit 2 ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-pending.md" <<'EOF'
# AskUserQuestion fired. SCOPE-tier deferral.
EOF
echo "# Stale checkpoint" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
touch -d "3 hours ago" "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
STDERR="$TEMPDIR/tc6.stderr"
RC=0
STOCKFORGE_HANDOFF_HARDBLOCK=1 CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>"$STDERR" || RC=$?
if [ "$RC" != "2" ]; then
  echo "FAIL TC6: expected exit 2 (STRICT mode); got $RC"
  cat "$STDERR" || true
  exit 1
fi
if ! grep -q "HARD-BLOCK" "$HOOK_LOG"; then
  echo "FAIL TC6: expected 'HARD-BLOCK' in $HOOK_LOG"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC6: STRICT mode + pending + stale → exit 2"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "pre-clear-handoff-guard.sh externally-observable behavior verified."
exit 0
