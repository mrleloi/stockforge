#!/usr/bin/env bash
# Firing-test for no-anthropic-sdk-d10.sh (S230 D-052 follow-up).
#
# Hook purpose: detect any `import anthropic` / `from anthropic` / `ANTHROPIC_API_KEY`
# references in production-code paths (apps/+packages/) post-D-052 cleanup.
# Strict-zero-tolerance: every hit = HIGH severity. Test fixtures (test_*.py,
# *_test.py) excluded via path filter. Comment-only ANTHROPIC_API_KEY refs
# excluded (line begins with `#`).
#
# Test strategy: stage temp PROJECT_DIR with synthetic apps/ + packages/ Python
# files (clean + dirty); invoke hook; assert .drift-signals.log emits expected
# D10 lines.
#
# 6 test cases:
#   TC1 — clean state (no forbidden refs) → no D10 emission
#   TC2 — production file with `import anthropic` → D10 HIGH (kind=import-anthropic)
#   TC3 — production file with `from anthropic import Anthropic` → D10 HIGH
#   TC4 — production file with ANTHROPIC_API_KEY env reference → D10 HIGH (kind=ANTHROPIC_API_KEY)
#   TC5 — test_*.py with `import anthropic` (legitimate fixture) → NOT flagged
#   TC6 — production docstring containing "import anthropic" prose → NOT flagged
#         (anchored regex matches real import statements only)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../no-anthropic-sdk-d10.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.drift-signals.log"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null >/dev/null 2>/dev/null || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/apps" "$TEMPDIR/packages"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
  mkdir -p "$TEMPDIR/apps/cli"
  mkdir -p "$TEMPDIR/packages/infrastructure/news"
}

d10_count() {
  [ -f "$LOG" ] || { echo 0; return; }
  grep -c "D10-NO-ANTHROPIC-SDK" "$LOG" 2>/dev/null || echo 0
}

# --- TC1: clean state → no D10 emission ---
clean_state
cat > "$TEMPDIR/packages/infrastructure/news/clean.py" <<'EOF'
"""Clean module — no forbidden references."""
from collections.abc import Callable
def hello() -> str:
    return "hi"
EOF
run_hook
if [ "$(d10_count)" -ne 0 ]; then
  echo "FAIL TC1: expected 0 D10 emissions on clean state; got $(d10_count)"
  cat "$LOG" 2>/dev/null
  exit 1
fi

# --- TC2: production file with `import anthropic` → D10 HIGH ---
clean_state
cat > "$TEMPDIR/packages/infrastructure/news/dirty_import.py" <<'EOF'
import anthropic
client = anthropic.Anthropic()
EOF
run_hook
if [ "$(d10_count)" -lt 1 ]; then
  echo "FAIL TC2: expected ≥1 D10 emission for `import anthropic`; got $(d10_count)"
  exit 1
fi
if ! grep -q "kind=import-anthropic" "$LOG"; then
  echo "FAIL TC2: expected kind=import-anthropic in log; got:"
  cat "$LOG"
  exit 1
fi

# --- TC3: production file with `from anthropic import Anthropic` → D10 HIGH ---
clean_state
cat > "$TEMPDIR/apps/cli/dirty_from.py" <<'EOF'
from anthropic import Anthropic
EOF
run_hook
if [ "$(d10_count)" -lt 1 ]; then
  echo "FAIL TC3: expected ≥1 D10 emission for `from anthropic import`; got $(d10_count)"
  exit 1
fi

# --- TC4: production file with ANTHROPIC_API_KEY → D10 HIGH ---
clean_state
cat > "$TEMPDIR/apps/cli/dirty_env.py" <<'EOF'
import os
key = os.environ["ANTHROPIC_API_KEY"]
EOF
run_hook
if ! grep -q "kind=ANTHROPIC_API_KEY" "$LOG"; then
  echo "FAIL TC4: expected kind=ANTHROPIC_API_KEY in log; got:"
  cat "$LOG" 2>/dev/null
  exit 1
fi

# --- TC5: test_*.py with `import anthropic` → NOT flagged ---
clean_state
cat > "$TEMPDIR/packages/infrastructure/news/test_fixture.py" <<'EOF'
import anthropic
def test_something():
    assert anthropic is not None
EOF
run_hook
if [ "$(d10_count)" -ne 0 ]; then
  echo "FAIL TC5: expected 0 D10 emissions for test_*.py fixture; got $(d10_count)"
  cat "$LOG"
  exit 1
fi

# --- TC6: production docstring mentioning "import anthropic" prose → NOT flagged ---
clean_state
cat > "$TEMPDIR/packages/infrastructure/news/clean_with_prose.py" <<'EOF'
"""Module that mentions `import anthropic` in prose only.

Per D-052 + L-S227-1, this module forbids import anthropic in code; the
ANTHROPIC_API_KEY environment variable is also forbidden by hard rule.
"""
def hello() -> str:
    return "hi"
EOF
run_hook
if [ "$(d10_count)" -ne 0 ]; then
  echo "FAIL TC6: expected 0 D10 emissions for docstring-prose mention; got $(d10_count)"
  cat "$LOG"
  exit 1
fi

echo "PASS no-anthropic-sdk-d10-fire-test (6/6 TC)"
exit 0
