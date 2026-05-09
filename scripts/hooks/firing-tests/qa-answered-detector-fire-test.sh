#!/usr/bin/env bash
# Firing-test for qa-answered-detector.sh (L-S49b-4 charter-coverage push; S76).
#
# Hook purpose (SessionStart hook):
#   - Reads .qa-last-scan-ts (default NOW-86400 if missing)
#   - Scans human-workspace/q-and-a/answered/*.md
#   - For each bundle with mtime > LAST_SCAN → log "NEW answered bundle: <name>"
#   - Forwards DESIGN_THINKING q_and_a_resolution event to sync-tracker-update.sh if executable
#   - Updates .qa-last-scan-ts to current epoch
#
# 5 test cases:
#   TC1 — no ANSWERED_DIR → exit 0 silently (no log entry)
#   TC2 — fresh bundle (mtime now) > default LAST_SCAN (NOW-86400) → log NEW + ts written
#   TC3 — bundle mtime > explicit LAST_SCAN value → log NEW
#   TC4 — bundle mtime <= LAST_SCAN value → no log NEW
#   TC5 — sync-tracker-update.sh executable → forward DESIGN_THINKING q_and_a_resolution event
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../qa-answered-detector.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

ANSWERED_DIR="$TEMPDIR/human-workspace/q-and-a/answered"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LAST_SCAN_FILE="$MEM_DIR/.qa-last-scan-ts"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
SYNC_HOOK_DIR="$TEMPDIR/scripts/hooks"
SYNC_HOOK="$SYNC_HOOK_DIR/sync-tracker-update.sh"

clean_state() {
  rm -rf "$TEMPDIR/human-workspace" "$TEMPDIR/agent-workspace" "$TEMPDIR/scripts"
  mkdir -p "$MEM_DIR"
}

# --- TC1: no ANSWERED_DIR → silent exit 0 ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$HOOK_LOG" ] && grep -q "qa-answered-detector" "$HOOK_LOG"; then
  echo "FAIL TC1: log should be empty when no ANSWERED_DIR exists"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC1: no ANSWERED_DIR → silent exit 0"

# --- TC2: fresh bundle (mtime now) > default LAST_SCAN (NOW-86400) → log NEW + ts written ---
clean_state
mkdir -p "$ANSWERED_DIR"
echo "answered" > "$ANSWERED_DIR/2026-05-06-fresh-bundle.md"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "NEW answered bundle: 2026-05-06-fresh-bundle.md" "$HOOK_LOG"; then
  echo "FAIL TC2: log should record NEW bundle (default LAST_SCAN = NOW-1d)"
  cat "$HOOK_LOG" 2>/dev/null
  exit 1
fi
if [ ! -f "$LAST_SCAN_FILE" ]; then
  echo "FAIL TC2: .qa-last-scan-ts file should be created"
  exit 1
fi
LAST_SCAN_VALUE=$(cat "$LAST_SCAN_FILE")
if ! [[ "$LAST_SCAN_VALUE" =~ ^[0-9]+$ ]]; then
  echo "FAIL TC2: .qa-last-scan-ts should be numeric epoch; got $LAST_SCAN_VALUE"
  exit 1
fi
echo "PASS TC2: fresh bundle → log NEW + ts written"

# --- TC3: bundle mtime > explicit LAST_SCAN epoch → log NEW ---
clean_state
mkdir -p "$ANSWERED_DIR"
NOW=$(date -u +%s)
LAST_SCAN_3H=$(( NOW - 10800 ))   # LAST_SCAN = 3h ago
echo "$LAST_SCAN_3H" > "$LAST_SCAN_FILE"
echo "answered" > "$ANSWERED_DIR/2026-05-06-detected.md"   # mtime defaults to NOW (>3h ago)
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "NEW answered bundle: 2026-05-06-detected.md" "$HOOK_LOG"; then
  echo "FAIL TC3: log should record NEW when bundle mtime > LAST_SCAN"
  cat "$HOOK_LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC3: bundle mtime > LAST_SCAN → log NEW"

# --- TC4: bundle mtime <= LAST_SCAN (LAST_SCAN in future) → no log NEW ---
clean_state
mkdir -p "$ANSWERED_DIR"
NOW=$(date -u +%s)
LAST_SCAN_FUTURE=$(( NOW + 60 ))   # LAST_SCAN = 1min in future
echo "$LAST_SCAN_FUTURE" > "$LAST_SCAN_FILE"
echo "answered" > "$ANSWERED_DIR/2026-05-06-stale.md"   # mtime = NOW < LAST_SCAN_FUTURE
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if grep -q "NEW answered bundle: 2026-05-06-stale.md" "$HOOK_LOG"; then
  echo "FAIL TC4: log should NOT record NEW when bundle mtime <= LAST_SCAN"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC4: bundle mtime <= LAST_SCAN → no NEW log"

# --- TC5: sync-tracker-update.sh executable → forward DESIGN_THINKING q_and_a_resolution event ---
clean_state
mkdir -p "$ANSWERED_DIR" "$SYNC_HOOK_DIR"
cat > "$SYNC_HOOK" <<'STUBEOF'
#!/usr/bin/env bash
# Stub sync-tracker — record positional args to a known file for assertion.
echo "STUB-SYNC-TRACKER args: $*" > "$CLAUDE_PROJECT_DIR/agent-workspace/memory/.sync-stub-called"
exit 0
STUBEOF
chmod +x "$SYNC_HOOK"
echo "answered" > "$ANSWERED_DIR/2026-05-06-with-sync.md"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if [ ! -f "$MEM_DIR/.sync-stub-called" ]; then
  echo "FAIL TC5: sync-tracker-update.sh should be invoked when executable"
  cat "$HOOK_LOG" 2>/dev/null
  exit 1
fi
if ! grep -q "DESIGN_THINKING" "$MEM_DIR/.sync-stub-called"; then
  echo "FAIL TC5: sync-tracker should be called with DESIGN_THINKING category"
  cat "$MEM_DIR/.sync-stub-called"
  exit 1
fi
if ! grep -q "q_and_a_resolution" "$MEM_DIR/.sync-stub-called"; then
  echo "FAIL TC5: sync-tracker should be called with q_and_a_resolution event type"
  cat "$MEM_DIR/.sync-stub-called"
  exit 1
fi
if ! grep -q "2026-05-06-with-sync.md" "$MEM_DIR/.sync-stub-called"; then
  echo "FAIL TC5: sync-tracker should be called with bundle name"
  cat "$MEM_DIR/.sync-stub-called"
  exit 1
fi
echo "PASS TC5: sync-tracker forward — DESIGN_THINKING q_and_a_resolution + bundle name"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "qa-answered-detector.sh externally-observable behavior verified."
exit 0
