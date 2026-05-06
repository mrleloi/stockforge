#!/usr/bin/env bash
# Firing-test for write-vs-edit-guard.sh (Phase 3.5 T3.4 Cluster 1 RETROFIT per L-S51-1).
#
# Validates the L-S45-2 HARD-BLOCK semantics against real PreToolUse JSON envelope shape:
#   1. Write to existing protected files (agent-notes / project / mistake-log /
#      current-execution / constitution/* / proposals/*) → exit 2 + "HARD-BLOCK" stderr
#   2. Write to NEW (non-existent) protected path → exit 0 (first-creation ALLOW)
#   3. Edit (any tool != Write) on existing protected → exit 0 (Edit not gated)
#   4. Write to non-protected path (apps/**, etc) → exit 0
#
# Origin: 2026-05-05 S45 sandwich-architect data-loss; hook live ~12hr with 0 visible
# blocks pre-firing-test (per Phase 2.5 post-mortem § HH-A.5). Firing-test demonstrates
# detection works on real-format input.
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../write-vs-edit-guard.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory"
mkdir -p "$TEMPDIR/agent-workspace/constitution"
mkdir -p "$TEMPDIR/agent-workspace/proposals"
mkdir -p "$TEMPDIR/apps"

# Stage existing protected files
printf 'pre-existing\n' > "$TEMPDIR/agent-workspace/memory/agent-notes.md"
printf 'pre-existing\n' > "$TEMPDIR/agent-workspace/memory/project.md"
printf 'pre-existing\n' > "$TEMPDIR/agent-workspace/memory/mistake-log.md"
printf 'pre-existing\n' > "$TEMPDIR/agent-workspace/memory/current-execution.md"
printf 'pre-existing\n' > "$TEMPDIR/agent-workspace/constitution/foo.md"
printf 'pre-existing\n' > "$TEMPDIR/apps/main.py"
# proposals/new.md does NOT exist → first-creation case

run_case() {
  local label="$1" tool_name="$2" file_path="$3" expected="$4"
  local stdin_json
  stdin_json=$(printf '{"tool_name":"%s","tool_input":{"file_path":"%s","content":"x"}}' "$tool_name" "$file_path")
  local exit_code stderr_out
  set +e
  stderr_out=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$stdin_json" 2>&1 >/dev/null)
  exit_code=$?
  set -e

  if [ "$expected" = "block" ]; then
    if [ "$exit_code" -eq 2 ] && printf '%s' "$stderr_out" | grep -q "HARD-BLOCK"; then
      printf 'PASS [%s] block: tool=%s path=%s exit=%d\n' "$label" "$tool_name" "$file_path" "$exit_code"
      return 0
    else
      printf 'FAIL [%s] expected HARD-BLOCK; tool=%s path=%s exit=%d stderr=[%s]\n' \
        "$label" "$tool_name" "$file_path" "$exit_code" "$stderr_out"
      return 1
    fi
  else
    if [ "$exit_code" -eq 0 ]; then
      printf 'PASS [%s] allow: tool=%s path=%s\n' "$label" "$tool_name" "$file_path"
      return 0
    else
      printf 'FAIL [%s] expected ALLOW; tool=%s path=%s exit=%d stderr=[%s]\n' \
        "$label" "$tool_name" "$file_path" "$exit_code" "$stderr_out"
      return 1
    fi
  fi
}

PASS=0; FAIL=0

# TC1-4: Write to existing protected files → BLOCK
if run_case "TC1-agent-notes" "Write" "$TEMPDIR/agent-workspace/memory/agent-notes.md" "block"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
if run_case "TC2-project" "Write" "$TEMPDIR/agent-workspace/memory/project.md" "block"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
if run_case "TC3-constitution" "Write" "$TEMPDIR/agent-workspace/constitution/foo.md" "block"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
if run_case "TC4-mistake-log" "Write" "$TEMPDIR/agent-workspace/memory/mistake-log.md" "block"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi

# TC5: Write to NEW (non-existent) proposals/new.md → ALLOW (first-creation)
if run_case "TC5-firstcreate" "Write" "$TEMPDIR/agent-workspace/proposals/new.md" "allow"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi

# TC6: Edit (not Write) to existing protected agent-notes.md → ALLOW (Edit not gated)
if run_case "TC6-edit" "Edit" "$TEMPDIR/agent-workspace/memory/agent-notes.md" "allow"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi

# TC7: Write to apps/main.py (NOT protected) → ALLOW
if run_case "TC7-non-protected" "Write" "$TEMPDIR/apps/main.py" "allow"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi

# TC8: Write with empty file_path → ALLOW (defensive exit 0 path)
stdin_empty='{"tool_name":"Write","tool_input":{"content":"x"}}'
set +e
out_empty=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$stdin_empty" 2>&1 >/dev/null)
ec_empty=$?
set -e
if [ "$ec_empty" -eq 0 ]; then
  echo "PASS [TC8-empty-path] empty file_path → ALLOW"
  PASS=$((PASS+1))
else
  printf 'FAIL [TC8-empty-path] expected exit 0; got %d stderr=[%s]\n' "$ec_empty" "$out_empty"
  FAIL=$((FAIL+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
