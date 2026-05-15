#!/usr/bin/env bash
# Firing-test for urgent-md-rotate.sh (S317 harness recovery; mass-deletion re-author).
#
# Hook purpose: size-triggered rotation of human-workspace/notifications/urgent.md.
# When urgent.md > 4096 bytes, archive content to urgent-archived-YYYY-MM-DD.md
# (append if same-day archive exists) and reset urgent.md to a fresh header.
#
# Test strategy: stage temp PROJECT_DIR with urgent.md fixtures of various sizes;
# invoke hook; assert archive existence/content + urgent.md reset + skip behavior.
#
# 5 test cases:
#   TC1 — urgent.md absent → skip, no archive
#   TC2 — urgent.md small (<= 4096) → skip, content unchanged
#   TC3 — urgent.md large (> 4096), no archive yet → archived + urgent.md reset
#   TC4 — urgent.md large, same-day archive exists → appended (both contents present)
#   TC5 — post-rotation idempotency → second run skips (urgent.md now small)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../urgent-md-rotate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
URGENT="$NOTIF_DIR/urgent.md"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
TODAY="$(date +%Y-%m-%d)"
ARCHIVE="$NOTIF_DIR/urgent-archived-${TODAY}.md"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/human-workspace" "$TEMPDIR/agent-workspace"
  mkdir -p "$NOTIF_DIR" "$TEMPDIR/agent-workspace/memory"
}

# helper: write a urgent.md larger than 4096 bytes
make_large_urgent() {
  {
    echo "# URGENT notifications stream"
    echo ""
    echo "---"
    i=0
    while [ "$i" -lt 200 ]; do
      echo "## [entry $i] some urgent notification line with padding text to grow the file"
      i=$((i + 1))
    done
  } > "$URGENT"
}

# --- TC1: urgent.md absent → skip ---
clean_state
run_hook
if [ -f "$ARCHIVE" ]; then
  echo "FAIL TC1: no archive should be created when urgent.md absent"
  exit 1
fi
if ! grep -q "urgent-md-rotate: skip (no urgent.md)" "$HOOK_LOG" 2>/dev/null; then
  echo "FAIL TC1: expected 'skip (no urgent.md)' in hook log"
  cat "$HOOK_LOG" 2>/dev/null || echo "(no hook log)"
  exit 1
fi
echo "PASS TC1: urgent.md absent → skip"

# --- TC2: small urgent.md → skip, unchanged ---
clean_state
printf '# URGENT notifications stream\nsmall content\n' > "$URGENT"
BEFORE="$(cat "$URGENT")"
run_hook
if [ -f "$ARCHIVE" ]; then
  echo "FAIL TC2: small urgent.md should NOT rotate"
  exit 1
fi
if [ "$(cat "$URGENT")" != "$BEFORE" ]; then
  echo "FAIL TC2: small urgent.md content should be unchanged"
  exit 1
fi
echo "PASS TC2: small urgent.md (<= 4096) → skip, unchanged"

# --- TC3: large urgent.md, no archive → rotate ---
clean_state
make_large_urgent
MARKER_LINE="## [entry 137] some urgent notification line with padding text to grow the file"
run_hook
if [ ! -f "$ARCHIVE" ]; then
  echo "FAIL TC3: archive should be created"
  exit 1
fi
if ! grep -qF "$MARKER_LINE" "$ARCHIVE"; then
  echo "FAIL TC3: archive should contain the rotated content"
  exit 1
fi
if grep -qF "$MARKER_LINE" "$URGENT"; then
  echo "FAIL TC3: urgent.md should be reset (rotated content removed)"
  exit 1
fi
if ! grep -q "Auto-rotated" "$URGENT"; then
  echo "FAIL TC3: reset urgent.md should carry an 'Auto-rotated' header"
  cat "$URGENT"
  exit 1
fi
echo "PASS TC3: large urgent.md → archived + reset"

# --- TC4: large urgent.md, same-day archive exists → append ---
clean_state
mkdir -p "$NOTIF_DIR"
echo "PREEXISTING-ARCHIVE-MARKER" > "$ARCHIVE"
make_large_urgent
MARKER_LINE="## [entry 42] some urgent notification line with padding text to grow the file"
run_hook
if ! grep -q "PREEXISTING-ARCHIVE-MARKER" "$ARCHIVE"; then
  echo "FAIL TC4: pre-existing archive content should be preserved"
  exit 1
fi
if ! grep -qF "$MARKER_LINE" "$ARCHIVE"; then
  echo "FAIL TC4: newly-rotated content should be appended to archive"
  exit 1
fi
echo "PASS TC4: same-day archive exists → appended (both contents present)"

# --- TC5: post-rotation idempotency → second run skips ---
clean_state
make_large_urgent
run_hook   # first run rotates
run_hook   # second run — urgent.md now small → must skip
SKIP_COUNT=$(grep -c "urgent-md-rotate: skip (size" "$HOOK_LOG" 2>/dev/null || true)
if [ "${SKIP_COUNT:-0}" -lt 1 ]; then
  echo "FAIL TC5: second run should log a size-skip (urgent.md small post-rotation)"
  cat "$HOOK_LOG" 2>/dev/null || echo "(no hook log)"
  exit 1
fi
echo "PASS TC5: post-rotation idempotency → second run skips"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "urgent-md-rotate.sh externally-observable behavior verified."
exit 0
