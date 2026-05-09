#!/usr/bin/env bash
# Firing-test for qa-pending-stale-mover.sh (L-S49b-4 charter-coverage push; S76).
#
# Hook purpose (SessionStart hook):
#   - Scans human-workspace/q-and-a/pending/*.md for `expected_answer_by:` field
#   - Extracts ISO 8601 deadline; converts to epoch via python3
#   - If past-deadline → mv to stale/ + emit URGENT notification + log
#   - If no deadline / empty pending dir / malformed deadline → silent exit 0
#
# 5 test cases:
#   TC1 — no PENDING_DIR → exit 0 silently (no log entry)
#   TC2 — bundle without expected_answer_by → continue (no mv, no notif)
#   TC3 — bundle with FUTURE deadline → no mv
#   TC4 — bundle with PAST deadline → mv to stale/ + URGENT notification + log
#   TC5 — bundle with malformed deadline → continue (no mv; DEADLINE_EPOCH=0)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../qa-pending-stale-mover.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

# Pre-flight: hook depends on python3 for ISO 8601 → epoch conversion.
if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 not installed; qa-pending-stale-mover requires python3 for ISO 8601 parsing"
  exit 0
fi

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

PENDING_DIR="$TEMPDIR/human-workspace/q-and-a/pending"
STALE_DIR="$TEMPDIR/human-workspace/q-and-a/stale"
NOTIFY_DIR="$TEMPDIR/human-workspace/notifications"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/human-workspace" "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: no PENDING_DIR → silent exit 0 ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$HOOK_LOG" ] && grep -q "qa-pending-stale-mover" "$HOOK_LOG"; then
  echo "FAIL TC1: log should be empty when no PENDING_DIR exists"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC1: no PENDING_DIR → silent exit 0"

# --- TC2: bundle without expected_answer_by field → no mv ---
clean_state
mkdir -p "$PENDING_DIR"
cat > "$PENDING_DIR/bundle-no-deadline.md" <<'EOF'
---
status: pending
created_at: 2026-05-06
---

Question content without deadline.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$PENDING_DIR/bundle-no-deadline.md" ]; then
  echo "FAIL TC2: bundle should remain in pending/ when no deadline"
  exit 1
fi
if [ -f "$STALE_DIR/bundle-no-deadline.md" ]; then
  echo "FAIL TC2: bundle should NOT be moved to stale/ when no deadline"
  exit 1
fi
echo "PASS TC2: bundle without expected_answer_by → no mv"

# --- TC3: bundle with FUTURE deadline → no mv ---
clean_state
mkdir -p "$PENDING_DIR"
FUTURE_DEADLINE=$(python3 -c "import datetime; print((datetime.datetime.utcnow() + datetime.timedelta(days=7)).strftime('%Y-%m-%dT%H:%M:%SZ'))")
cat > "$PENDING_DIR/bundle-future.md" <<EOF
---
status: pending
expected_answer_by: $FUTURE_DEADLINE
---

Question content (deadline in future).
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$PENDING_DIR/bundle-future.md" ]; then
  echo "FAIL TC3: future-deadline bundle should remain in pending/"
  exit 1
fi
if [ -f "$STALE_DIR/bundle-future.md" ]; then
  echo "FAIL TC3: future-deadline bundle should NOT be moved to stale/"
  exit 1
fi
echo "PASS TC3: future deadline → no mv"

# --- TC4: bundle with PAST deadline → mv to stale/ + URGENT notif + log ---
clean_state
mkdir -p "$PENDING_DIR"
PAST_DEADLINE=$(python3 -c "import datetime; print((datetime.datetime.utcnow() - datetime.timedelta(days=7)).strftime('%Y-%m-%dT%H:%M:%SZ'))")
cat > "$PENDING_DIR/bundle-past.md" <<EOF
---
status: pending
expected_answer_by: $PAST_DEADLINE
---

Question content (deadline expired).
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$PENDING_DIR/bundle-past.md" ]; then
  echo "FAIL TC4: past-deadline bundle should be moved out of pending/"
  exit 1
fi
if [ ! -f "$STALE_DIR/bundle-past.md" ]; then
  echo "FAIL TC4: past-deadline bundle should be in stale/"
  ls -la "$STALE_DIR/" 2>/dev/null
  exit 1
fi
NOTIFY_COUNT=$(find "$NOTIFY_DIR" -name "*-stale-bundle-bundle-past.md.txt" 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)
if [ "$NOTIFY_COUNT" -lt 1 ]; then
  echo "FAIL TC4: URGENT notification file should be emitted"
  ls -la "$NOTIFY_DIR/" 2>/dev/null
  exit 1
fi
NOTIFY_FILE=$(find "$NOTIFY_DIR" -name "*-stale-bundle-bundle-past.md.txt" 2>/dev/null | head -1)
if ! grep -q "URGENT" "$NOTIFY_FILE" 2>/dev/null; then
  echo "FAIL TC4: notification file should contain URGENT marker"
  cat "$NOTIFY_FILE" 2>/dev/null
  exit 1
fi
if ! grep -q "moved bundle-past.md" "$HOOK_LOG"; then
  echo "FAIL TC4: hook log should record mv with bundle name"
  cat "$HOOK_LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC4: past deadline → mv to stale/ + URGENT notif + log"

# --- TC5: bundle with MALFORMED deadline → no mv (DEADLINE_EPOCH=0) ---
clean_state
mkdir -p "$PENDING_DIR"
cat > "$PENDING_DIR/bundle-malformed.md" <<'EOF'
---
status: pending
expected_answer_by: not-a-real-date
---

Question content with bogus deadline.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$PENDING_DIR/bundle-malformed.md" ]; then
  echo "FAIL TC5: malformed-deadline bundle should remain in pending/ (DEADLINE_EPOCH=0 continue)"
  exit 1
fi
if [ -f "$STALE_DIR/bundle-malformed.md" ]; then
  echo "FAIL TC5: malformed-deadline bundle should NOT be moved to stale/"
  exit 1
fi
echo "PASS TC5: malformed deadline → no mv"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "qa-pending-stale-mover.sh externally-observable behavior verified."
exit 0
