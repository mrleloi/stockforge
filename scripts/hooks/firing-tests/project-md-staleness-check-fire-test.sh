#!/usr/bin/env bash
# Firing-test for project-md-staleness-check.sh (Phase 3.5 T7 retrofit; S59).
#
# Hook purpose (HH-C.2 Stop): detect drift between project.md "Phase Goals Tracker"
# and current-execution.md "Active Focus Track". Two staleness modes:
#   (A) Active phase from current-execution absent (or wrong status) in project.md tracker
#   (B) project.md mtime older than newest ADR by >2h
#
# Test strategy: stage temp PROJECT_DIR with project.md + current-execution.md +
# decisions/ fixtures; invoke hook; assert .session-hooks.log content reflects warns.
#
# 6 test cases:
#   TC1 — both files missing → silent (graceful bail)
#   TC2 — clean alignment (active phase exists with status IN PROGRESS) → silent
#   TC3 — active phase absent from project.md → WARN
#   TC4 — phase status DONE in project.md but IN PROGRESS in current-execution → WARN
#   TC5 — project.md mtime > 2h older than newest ADR → WARN
#   TC6 — project.md mtime < 2h older than newest ADR → silent (within tolerance)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../project-md-staleness-check.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  local session_id="${1:-test-session-tc}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$session_id" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
}

# --- TC1: both files missing → silent (graceful bail) ---
clean_state
run_hook "tc1-session"
if [ -f "$LOG" ] && grep -q "tc1-session" "$LOG" 2>/dev/null; then
  echo "FAIL TC1: hook should silently exit when project.md/current-execution.md missing"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: missing files → silent"

# --- TC2: clean alignment → silent ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5 — Harness Deepening
EOF
cat > "$TEMPDIR/agent-workspace/memory/project.md" <<EOF
# Project State

| Phase | Tracks | Status | Started | Closed |
|---|---|---|---|---|
| 3.5 — Harness Deepening | 8 tracks | IN PROGRESS | 2026-05-05 | - |
EOF
run_hook "tc2-session"
if [ -f "$LOG" ] && grep -q "tc2-session" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: clean alignment should NOT emit warns"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: clean alignment → silent"

# --- TC3: active phase absent from project.md → WARN ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 9 — Future Phase
EOF
cat > "$TEMPDIR/agent-workspace/memory/project.md" <<EOF
# Project State

| Phase | Tracks | Status | Started | Closed |
|---|---|---|---|---|
| 3.5 — Harness Deepening | 8 tracks | IN PROGRESS | 2026-05-05 | - |
EOF
run_hook "tc3-session"
if [ ! -f "$LOG" ] || ! grep -q "tc3-session" "$LOG"; then
  echo "FAIL TC3: expected WARN log entry for missing phase"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
# Should mention phase=9
if ! grep -q "phase=9" "$LOG"; then
  echo "FAIL TC3: log should mention phase=9 in warn entry"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: active phase absent from project.md → WARN"

# --- TC4: project.md says DONE but current-execution.md says IN PROGRESS → WARN ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 2 — Done Phase

Phase 2 IN PROGRESS active here.
EOF
cat > "$TEMPDIR/agent-workspace/memory/project.md" <<EOF
# Project State

| Phase | Tracks | Status | Started | Closed |
|---|---|---|---|---|
| 2 — Done Phase | 5 tracks | DONE | 2026-04-01 | 2026-04-15 |
EOF
run_hook "tc4-session"
if [ ! -f "$LOG" ] || ! grep -q "tc4-session" "$LOG"; then
  echo "FAIL TC4: expected WARN log entry for status mismatch"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC4: project.md DONE vs current-execution.md IN PROGRESS → WARN"

# --- TC5: project.md mtime > 2h older than newest ADR → WARN ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5 — Harness Deepening
EOF
cat > "$TEMPDIR/agent-workspace/memory/project.md" <<EOF
# Project State

| Phase | Tracks | Status | Started | Closed |
|---|---|---|---|---|
| 3.5 — Harness Deepening | 8 tracks | IN PROGRESS | 2026-05-05 | - |
EOF
# Make project.md 5 hours old; ADR is fresh.
touch -d "5 hours ago" "$TEMPDIR/agent-workspace/memory/project.md"
cat > "$TEMPDIR/agent-workspace/memory/decisions/D-031-test-adr.md" <<EOF
# D-031 test ADR
EOF
# ADR mtime = now (default); project.md mtime = 5h ago → delta = 5h > 2h tolerance.
run_hook "tc5-session"
if [ ! -f "$LOG" ] || ! grep -q "tc5-session" "$LOG"; then
  echo "FAIL TC5: expected WARN log entry for mtime drift"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC5: project.md > 2h older than newest ADR → WARN"

# --- TC6: project.md mtime < 2h older than ADR → silent (within tolerance) ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution

**Phase**: 3.5 — Harness Deepening
EOF
cat > "$TEMPDIR/agent-workspace/memory/project.md" <<EOF
# Project State

| Phase | Tracks | Status | Started | Closed |
|---|---|---|---|---|
| 3.5 — Harness Deepening | 8 tracks | IN PROGRESS | 2026-05-05 | - |
EOF
# Make project.md 30 minutes old; ADR is fresh — within 2h tolerance.
touch -d "30 minutes ago" "$TEMPDIR/agent-workspace/memory/project.md"
cat > "$TEMPDIR/agent-workspace/memory/decisions/D-031-test-adr.md" <<EOF
# D-031 test ADR
EOF
run_hook "tc6-session"
if [ -f "$LOG" ] && grep -q "tc6-session" "$LOG" 2>/dev/null; then
  echo "FAIL TC6: 30min mtime delta within 2h tolerance — should NOT WARN"
  cat "$LOG"
  exit 1
fi
echo "PASS TC6: project.md mtime within 2h tolerance → silent"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "project-md-staleness-check.sh externally-observable behavior verified."
exit 0
