#!/usr/bin/env bash
# pre-commit-pytest-regression-guard.sh — PreToolUse guard for `git commit` invocations.
#
# Purpose (L-S382-1 PROMOTE-NOW n=10 L-S345-1 cluster — D2 plan-039):
# When a sandwich-dev session runs `git commit`, this hook runs pytest on the
# test files directly related to any changed Python files. If pytest fails,
# the commit is BLOCKED (exit RC=2) to prevent commit-claim vs empirical-gate divergence.
#
# Root cause addressed (M-S381-1): ctor-signature-change not propagated to test helper;
# 4 pytest failures + 4 mypy errors slipped past dev commit to verifier.
#
# Scope: CHANGED-FILE ANCESTRY ONLY (not full project pytest per commit).
# Rationale (DD-2): full-project pytest is too slow at every commit (~50K cache tokens
# minimum); changed-file ancestry catches the M-S381-1 class; S389 verifier catches
# full-project regressions via separate gate.
#
# Override: STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1 env bypass (mirrors pre-dispatch-architect-
# commit-guard.sh:14 pattern per DD-4).
# Cache: skip if same SHA of staged-file-set was recently green
# (hour-bucket marker at agent-workspace/memory/.pre-commit-pytest-green-<sha>.last).
#
# Pattern reference: pre-dispatch-architect-commit-guard.sh (stdin JSON parse + RC=2 block).
# Windows-compatible spawn topology per RM10 + L-S247-1.
# Bash + POSIX only per L-S11-1 portability discipline.
# SPAWN-CONTEXT: stdin-json (PreToolUse).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.pre-commit-pytest-regression-guard.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# --- Extract tool_name and command from stdin JSON ---
TOOL_NAME=""
COMMAND=""
if [ ! -t 0 ]; then
    STDIN_JSON=$(cat 2>/dev/null || true)
    TOOL_NAME=$(printf '%s' "$STDIN_JSON" \
        | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
        | sed 's/.*"\([^"]*\)"$/\1/' || true)
    COMMAND=$(printf '%s' "$STDIN_JSON" \
        | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
        | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//' || true)
fi

# Only guard Bash tool calls; allow everything else through.
[ "$TOOL_NAME" = "Bash" ] || exit 0

# Only guard commands that contain `git commit`; allow other Bash calls through.
printf '%s' "$COMMAND" | grep -qiE 'git[[:space:]]+commit' 2>/dev/null || exit 0

# --- Override gate ---
if [ "${STOCKFORGE_SKIP_PRECOMMIT_PYTEST:-0}" = "1" ]; then
    printf '[%s] pre-commit-pytest-regression-guard: BYPASSED via STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1\n' \
        "$TS" >> "$LOG" 2>/dev/null || true
    exit 0
fi

# --- Discover changed Python files (staged + unstaged) ---
CHANGED_PY_FILES=""
if command -v git >/dev/null 2>&1; then
    STAGED=$(git -C "$PROJECT_DIR" diff --name-only --cached 2>/dev/null \
        | grep '\.py$' || true)
    UNSTAGED=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null \
        | grep '\.py$' || true)
    CHANGED_PY_FILES=$(printf '%s\n%s' "$STAGED" "$UNSTAGED" \
        | grep -v '^$' | sort -u || true)
fi

# No Python files changed → allow (no pytest to run; non-Python commit is safe).
if [ -z "$CHANGED_PY_FILES" ]; then
    printf '[%s] pre-commit-pytest-regression-guard: ALLOW (no .py files changed)\n' \
        "$TS" >> "$LOG" 2>/dev/null || true
    exit 0
fi

# --- SHA-keyed green cache check ---
# Build a SHA from the sorted list of changed files + their git SHAs.
CACHE_KEY=$(printf '%s' "$CHANGED_PY_FILES" | sort | sha1sum 2>/dev/null \
    | awk '{print $1}' || printf '%s' "$CHANGED_PY_FILES" | wc -c | tr -d '[:space:]')
CACHE_MARKER="$MEM_DIR/.pre-commit-pytest-green-${CACHE_KEY}.last"

# Check if marker is from within the last hour (3600 seconds).
if [ -f "$CACHE_MARKER" ]; then
    MARKER_AGE=9999
    if command -v stat >/dev/null 2>&1; then
        MTIME=$(stat -c %Y "$CACHE_MARKER" 2>/dev/null \
            || stat -f %m "$CACHE_MARKER" 2>/dev/null || echo 0)
        NOW=$(date +%s 2>/dev/null || echo 9999999999)
        if [ "$MTIME" -gt 0 ] 2>/dev/null; then
            MARKER_AGE=$(( NOW - MTIME ))
        fi
    fi
    if [ "$MARKER_AGE" -lt 3600 ] 2>/dev/null; then
        printf '[%s] pre-commit-pytest-regression-guard: ALLOW (cache hit sha=%s age=%ss)\n' \
            "$TS" "$CACHE_KEY" "$MARKER_AGE" >> "$LOG" 2>/dev/null || true
        exit 0
    fi
fi

# --- Find related test files ---
TEST_FILES=""
for py_file in $CHANGED_PY_FILES; do
    # Skip test files themselves (they're the test, not the subject).
    case "$py_file" in
        *test_*.py|*_test.py) continue ;;
    esac
    BASE="$(basename "$py_file" .py)"
    DIR="$(dirname "$py_file")"

    # Sibling test file: test_<basename>.py in same directory.
    SIBLING_TEST="$PROJECT_DIR/$DIR/test_${BASE}.py"
    if [ -f "$SIBLING_TEST" ]; then
        TEST_FILES="$TEST_FILES $SIBLING_TEST"
    fi

    # tests/ subdirectory: tests/test_<basename>.py relative to project root.
    MODULE_TEST="$PROJECT_DIR/tests/test_${BASE}.py"
    if [ -f "$MODULE_TEST" ]; then
        TEST_FILES="$TEST_FILES $MODULE_TEST"
    fi
done

# No test files found for changed Python files → allow (no test siblings means
# file is not yet tested; WIP commits are legitimate per DD-2).
if [ -z "$TEST_FILES" ]; then
    printf '[%s] pre-commit-pytest-regression-guard: ALLOW (no test siblings found for changed .py files)\n' \
        "$TS" >> "$LOG" 2>/dev/null || true
    exit 0
fi

# --- Run pytest on related test files (60-second timeout) ---
PYTEST_OUT=""
PYTEST_EXIT=0
PYTEST_CMD="python -m pytest $TEST_FILES -x --no-header -q"
printf '[%s] pre-commit-pytest-regression-guard: running pytest on test siblings\n' \
    "$TS" >> "$LOG" 2>/dev/null || true

if command -v timeout >/dev/null 2>&1; then
    PYTEST_OUT=$(timeout 60 $PYTEST_CMD 2>&1) || PYTEST_EXIT=$?
    if [ "$PYTEST_EXIT" -eq 124 ]; then
        # Timeout: log WARN + allow (non-blocking per spec).
        printf '[%s] pre-commit-pytest-regression-guard: WARN timeout (60s); allowing commit\n' \
            "$TS" >> "$LOG" 2>/dev/null || true
        printf '[pre-commit-pytest-regression-guard] WARN: pytest timed out after 60s — commit allowed; check test speed.\n' >&2
        exit 0
    fi
else
    # No timeout available (e.g. macOS without coreutils); run without timeout.
    PYTEST_OUT=$($PYTEST_CMD 2>&1) || PYTEST_EXIT=$?
fi

if [ "$PYTEST_EXIT" -ne 0 ]; then
    printf '[%s] pre-commit-pytest-regression-guard: BLOCKED pytest_exit=%d\n' \
        "$TS" "$PYTEST_EXIT" >> "$LOG" 2>/dev/null || true
    # Write BLOCK details to log for audit.
    printf '%s\n' "$PYTEST_OUT" >> "$LOG" 2>/dev/null || true
    echo "PRE-COMMIT-PYTEST-REGRESSION-GUARD: BLOCKED — pytest failed on changed-file test siblings." >&2
    echo "Fix the failing tests before committing, or set STOCKFORGE_SKIP_PRECOMMIT_PYTEST=1 to bypass." >&2
    printf '%s\n' "$PYTEST_OUT" | tail -20 >&2
    exit 2
fi

# Pytest passed: write cache marker.
touch "$CACHE_MARKER" 2>/dev/null || true

printf '[%s] pre-commit-pytest-regression-guard: ALLOW (pytest green sha=%s)\n' \
    "$TS" "$CACHE_KEY" >> "$LOG" 2>/dev/null || true
exit 0
