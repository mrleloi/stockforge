#!/usr/bin/env bash
# Firing-test for post-tool-citation-grep.sh (Phase 3.5 T7 retrofit; S59).
#
# Hook purpose (PostToolUse on Write/Edit/MultiEdit): for data-bearing files
# (specs/, agent-workspace/memory/thesis-log/, agent-workspace/calibration/,
# agent-workspace/memory/decisions/, eval-sets/), enforce I-S2 (every numeric
# claim cites source: + as_of:). Soft-warn unless STOCKFORGE_CITATION_STRICT=1.
#
# Test strategy: stage temp files in audit dirs, pipe stdin JSON simulating
# PostToolUse payload, assert .citation-violations.log + .session-hooks.log
# content reflects expected per-case classification.
#
# 6 test cases:
#   TC1 — tool_name=Read (not Write/Edit) → silent (early bail)
#   TC2 — file_path outside audit dirs → silent (early bail)
#   TC3 — file in audit dir, no numeric claims → silent
#   TC4 — numeric claim WITH source/as_of nearby → silent
#   TC5 — numeric claim WITHOUT source/as_of → WARN (citation-missing)
#   TC6 — STOCKFORGE_CITATION_STRICT=1 + violation → emit block JSON to stdout
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../post-tool-citation-grep.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

VIOL_LOG="$TEMPDIR/agent-workspace/memory/.citation-violations.log"

run_hook() {
  local tool_name="$1" file_path="$2" strict="${3:-0}"
  local payload
  payload=$(printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "$tool_name" "$file_path")
  STOCKFORGE_CITATION_STRICT="$strict" CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" <<< "$payload" 2>/dev/null
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/specs"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: tool_name=Read → silent (early bail before file check) ---
clean_state
mkdir -p "$TEMPDIR/specs"
echo "ROE 18%" > "$TEMPDIR/specs/foo.md"
STDOUT=$(run_hook "Read" "$TEMPDIR/specs/foo.md")
if [ -n "$STDOUT" ]; then
  echo "FAIL TC1: tool_name=Read should produce no stdout"; echo "Got: $STDOUT"
  exit 1
fi
if [ -f "$VIOL_LOG" ]; then
  echo "FAIL TC1: tool_name=Read should not create violations log"
  cat "$VIOL_LOG"
  exit 1
fi
echo "PASS TC1: tool_name=Read → silent (early bail)"

# --- TC2: file outside audit dirs → silent ---
clean_state
mkdir -p "$TEMPDIR/random-dir"
echo "ROE 18%" > "$TEMPDIR/random-dir/foo.md"
STDOUT=$(run_hook "Edit" "$TEMPDIR/random-dir/foo.md")
if [ -n "$STDOUT" ]; then
  echo "FAIL TC2: file outside audit dirs should produce no stdout"; echo "Got: $STDOUT"
  exit 1
fi
if [ -f "$VIOL_LOG" ]; then
  echo "FAIL TC2: file outside audit dirs should not create violations log"
  cat "$VIOL_LOG"
  exit 1
fi
echo "PASS TC2: file outside audit dirs → silent"

# --- TC3: audit dir, no numeric claims → silent ---
clean_state
mkdir -p "$TEMPDIR/specs"
cat > "$TEMPDIR/specs/clean.md" <<EOF
# Clean spec

This spec has prose only. No numeric values worth citing.
EOF
STDOUT=$(run_hook "Edit" "$TEMPDIR/specs/clean.md")
if [ -n "$STDOUT" ]; then
  echo "FAIL TC3: clean file should produce no stdout"; echo "Got: $STDOUT"
  exit 1
fi
if [ -f "$VIOL_LOG" ]; then
  echo "FAIL TC3: clean file should not log violations"
  cat "$VIOL_LOG"
  exit 1
fi
echo "PASS TC3: no numeric claims → silent"

# --- TC4: numeric claim WITH source/as_of nearby → silent ---
clean_state
mkdir -p "$TEMPDIR/specs"
cat > "$TEMPDIR/specs/cited.md" <<EOF
# Cited spec

ROE 18% (above industry average)
source: vnstock fundamentals API
as_of: 2026-05-05
EOF
STDOUT=$(run_hook "Edit" "$TEMPDIR/specs/cited.md")
if [ -n "$STDOUT" ]; then
  echo "FAIL TC4: cited file should produce no stdout"; echo "Got: $STDOUT"
  exit 1
fi
if [ -f "$VIOL_LOG" ] && [ -s "$VIOL_LOG" ]; then
  echo "FAIL TC4: cited file should not log violations"
  cat "$VIOL_LOG"
  exit 1
fi
echo "PASS TC4: numeric claim with source/as_of nearby → silent"

# --- TC5: numeric claim WITHOUT source/as_of → log violation ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/thesis-log"
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/uncited.md" <<EOF
# Uncited thesis

Some thesis claims:
- ROE 18%
- Revenue growth 35% YoY
- Market cap 12000 billion VND

No provenance metadata anywhere here.
EOF
STDOUT=$(run_hook "Edit" "$TEMPDIR/agent-workspace/memory/thesis-log/uncited.md")
# Soft-warn: stdout may be empty (warn goes to stderr); violations should be logged.
if [ ! -f "$VIOL_LOG" ] || ! grep -q "CITATION-MISSING" "$VIOL_LOG"; then
  echo "FAIL TC5: expected CITATION-MISSING entries in $VIOL_LOG"
  cat "$VIOL_LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC5: numeric claim without source/as_of → WARN (violation logged)"

# --- TC6: STRICT mode + violation → emit block JSON to stdout ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/thesis-log"
cat > "$TEMPDIR/agent-workspace/memory/thesis-log/strict-violation.md" <<EOF
# Strict-mode test

Bare claims again: ROE 22%, revenue 15000 billion VND, market cap 8500 tỷ.
EOF
STDOUT=$(run_hook "Edit" "$TEMPDIR/agent-workspace/memory/thesis-log/strict-violation.md" "1")
if [ -z "$STDOUT" ] || ! printf '%s' "$STDOUT" | grep -q '"decision":"block"'; then
  echo "FAIL TC6: STRICT mode + violation should emit block JSON to stdout"
  echo "Got stdout: '$STDOUT'"
  exit 1
fi
if ! printf '%s' "$STDOUT" | grep -q "STOCKFORGE I-S2"; then
  echo "FAIL TC6: block JSON should reference 'STOCKFORGE I-S2'"
  echo "Got stdout: $STDOUT"
  exit 1
fi
echo "PASS TC6: STRICT mode + violation → block JSON emitted"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "post-tool-citation-grep.sh externally-observable behavior verified."
exit 0
