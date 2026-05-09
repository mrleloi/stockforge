#!/usr/bin/env bash
# Firing-test for precompact-thesis-state-dump.sh (L-S49b-4 charter-coverage push; S79).
#
# Hook purpose (PreCompact hook; Decision 002 § Track 5 REV-2 § B deliverable):
#   - Snapshot critical state files before context compaction loses them.
#   - Always creates SNAPSHOT_DIR/$TS/; copies 5 source files (if exist):
#     current-execution.md / checkpoints/latest.md / thesis-log/active.yaml /
#     observations/queued-grill-master.md / .transcript-tokens.
#   - Captures last 200 lines of .session-hooks.log → session-hooks.tail.
#   - Writes metadata.yaml (snapshot_id + created_at + session_id + reason).
#   - Logs success line to HOOK_LOG.
#   - Rotation: if SNAPSHOT_COUNT > 10, prunes oldest (ls -1t | tail -n +11) via rm -rf.
#   - Always exit 0 (non-blocking).
#
# 5 test cases:
#   TC1 — no source files → snapshot dir created with metadata.yaml only; log entry present
#   TC2 — subset of source files (only current-execution.md + checkpoints/latest.md exist)
#         → those 2 copied; metadata.yaml; no copies of missing files
#   TC3 — all 5 source files exist → all 5 copied + session-hooks.tail + metadata.yaml + log
#   TC4 — 10 prior snapshot dirs (older mtimes) → after run count=10 (oldest pruned), new dir present
#   TC5 — CLAUDE_SESSION_ID env var set → metadata.yaml records session_id correctly
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../precompact-thesis-state-dump.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
SNAPSHOT_DIR="$MEM_DIR/.precompact-snapshots"
LOG="$MEM_DIR/.session-hooks.log"
CHECKPOINT_DIR="$MEM_DIR/checkpoints"
THESIS_DIR="$MEM_DIR/thesis-log"
OBS_DIR="$MEM_DIR/observations"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$MEM_DIR"
}

# --- TC1: no source files → snapshot dir + metadata.yaml only; log entry present ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
SNAPSHOT_COUNT=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$SNAPSHOT_COUNT" -ne 1 ]; then
  echo "FAIL TC1: expected exactly 1 snapshot dir; got $SNAPSHOT_COUNT"
  ls -la "$SNAPSHOT_DIR" 2>/dev/null
  exit 1
fi
NEW_SNAPSHOT=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
if [ ! -f "$NEW_SNAPSHOT/metadata.yaml" ]; then
  echo "FAIL TC1: metadata.yaml should be created"
  ls -la "$NEW_SNAPSHOT" 2>/dev/null
  exit 1
fi
COPY_COUNT=$(find "$NEW_SNAPSHOT" -maxdepth 1 -type f ! -name 'metadata.yaml' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$COPY_COUNT" -ne 0 ]; then
  echo "FAIL TC1: no source files should have been copied (got $COPY_COUNT extra files)"
  ls -la "$NEW_SNAPSHOT"
  exit 1
fi
if ! grep -q "PreCompact: thesis state snapshotted" "$LOG"; then
  echo "FAIL TC1: log should record snapshot entry"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC1: no source files → snapshot dir + metadata.yaml only"

# --- TC2: subset (current-execution.md + checkpoints/latest.md) exist → only those copied ---
clean_state
mkdir -p "$CHECKPOINT_DIR"
echo "current-execution content" > "$MEM_DIR/current-execution.md"
echo "checkpoint content" > "$CHECKPOINT_DIR/latest.md"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
NEW_SNAPSHOT=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
if [ ! -f "$NEW_SNAPSHOT/current-execution.md" ]; then
  echo "FAIL TC2: current-execution.md should be copied"
  ls -la "$NEW_SNAPSHOT"
  exit 1
fi
if [ ! -f "$NEW_SNAPSHOT/latest.md" ]; then
  echo "FAIL TC2: latest.md should be copied"
  ls -la "$NEW_SNAPSHOT"
  exit 1
fi
if [ -f "$NEW_SNAPSHOT/active.yaml" ]; then
  echo "FAIL TC2: active.yaml should NOT be copied (source missing)"
  exit 1
fi
if [ -f "$NEW_SNAPSHOT/queued-grill-master.md" ]; then
  echo "FAIL TC2: queued-grill-master.md should NOT be copied (source missing)"
  exit 1
fi
echo "PASS TC2: subset of source files → only existing copied"

# --- TC3: all 5 source files exist → all 5 copied + session-hooks.tail + metadata ---
clean_state
mkdir -p "$CHECKPOINT_DIR" "$THESIS_DIR" "$OBS_DIR"
echo "current-execution" > "$MEM_DIR/current-execution.md"
echo "latest checkpoint" > "$CHECKPOINT_DIR/latest.md"
echo "active thesis" > "$THESIS_DIR/active.yaml"
echo "queued grills" > "$OBS_DIR/queued-grill-master.md"
echo "transcript-tokens-state" > "$MEM_DIR/.transcript-tokens"
# Pre-seed hooks log (≥1 line) to test session-hooks.tail capture
echo "[2026-05-06] sample log line" > "$LOG"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
NEW_SNAPSHOT=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
for FILE in current-execution.md latest.md active.yaml queued-grill-master.md .transcript-tokens session-hooks.tail metadata.yaml; do
  if [ ! -f "$NEW_SNAPSHOT/$FILE" ]; then
    echo "FAIL TC3: $FILE should be present in snapshot"
    ls -la "$NEW_SNAPSHOT"
    exit 1
  fi
done
if ! grep -q "sample log line" "$NEW_SNAPSHOT/session-hooks.tail"; then
  echo "FAIL TC3: session-hooks.tail should contain seeded log content"
  cat "$NEW_SNAPSHOT/session-hooks.tail"
  exit 1
fi
if ! grep -q "snapshot_id:" "$NEW_SNAPSHOT/metadata.yaml"; then
  echo "FAIL TC3: metadata.yaml should contain snapshot_id"
  cat "$NEW_SNAPSHOT/metadata.yaml"
  exit 1
fi
if ! grep -q "reason: PreCompact hook" "$NEW_SNAPSHOT/metadata.yaml"; then
  echo "FAIL TC3: metadata.yaml should contain reason field"
  cat "$NEW_SNAPSHOT/metadata.yaml"
  exit 1
fi
echo "PASS TC3: all 5 source files → all copied + session-hooks.tail + metadata"

# --- TC4: 10 prior snapshots → after run count=10 (oldest pruned), new dir present ---
clean_state
mkdir -p "$SNAPSHOT_DIR"
# Pre-create 10 prior snapshots with progressively older mtimes
for i in $(seq 1 10); do
  PRIOR="$SNAPSHOT_DIR/prior-$(printf '%02d' "$i")"
  mkdir -p "$PRIOR"
  echo "prior $i" > "$PRIOR/metadata.yaml"
  # Spread mtimes: prior-01 oldest, prior-10 newest pre-existing
  AGE_DAYS=$(( 11 - i ))
  touch -d "${AGE_DAYS} days ago" "$PRIOR" 2>/dev/null || touch -t "$(date -v-${AGE_DAYS}d +%Y%m%d%H%M 2>/dev/null || echo 202604010000)" "$PRIOR"
done
COUNT_BEFORE=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d '[:space:]')
if [ "$COUNT_BEFORE" -ne 10 ]; then
  echo "FAIL TC4: pre-condition expected 10 prior dirs; got $COUNT_BEFORE"
  exit 1
fi
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
COUNT_AFTER=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d '[:space:]')
if [ "$COUNT_AFTER" -ne 10 ]; then
  echo "FAIL TC4: rotation should keep count at 10 (was 11 → prune 1); got $COUNT_AFTER"
  ls -la "$SNAPSHOT_DIR"
  exit 1
fi
# prior-01 (oldest) should be pruned
if [ -d "$SNAPSHOT_DIR/prior-01" ]; then
  echo "FAIL TC4: oldest snapshot prior-01 should be pruned"
  ls -la "$SNAPSHOT_DIR"
  exit 1
fi
# prior-10 (newest pre-existing) should remain
if [ ! -d "$SNAPSHOT_DIR/prior-10" ]; then
  echo "FAIL TC4: newest pre-existing prior-10 should remain"
  ls -la "$SNAPSHOT_DIR"
  exit 1
fi
echo "PASS TC4: 10 prior + new = 11 → rotation prunes oldest, count back to 10"

# --- TC5: CLAUDE_SESSION_ID env var → metadata.yaml records session_id ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="test-session-S79-fixture" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
NEW_SNAPSHOT=$(find "$SNAPSHOT_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)
if ! grep -q "session_id: test-session-S79-fixture" "$NEW_SNAPSHOT/metadata.yaml"; then
  echo "FAIL TC5: metadata.yaml should record session_id from env"
  cat "$NEW_SNAPSHOT/metadata.yaml"
  exit 1
fi
echo "PASS TC5: CLAUDE_SESSION_ID env → metadata.yaml records session_id"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "precompact-thesis-state-dump.sh externally-observable behavior verified."
exit 0
