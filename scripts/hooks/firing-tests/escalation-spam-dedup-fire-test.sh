#!/usr/bin/env bash
# escalation-spam-dedup-fire-test.sh — firing-test for D1 escalation HIGH-spam dedup fix.
#
# SPAWN-CONTEXT: positional-arg (bash escalation-spam-dedup-fire-test.sh)
# Tests: content-hash dedup in all 3 source hooks + level:WARN frontmatter.
#
# Test cases (6 TC):
#   TC01 — python-determinism-check emits level:WARN frontmatter when violations present
#   TC02 — python-determinism-check skips write when content unchanged (mtime preserved)
#   TC03 — html-separator-check emits level:WARN frontmatter when violations present
#   TC04 — html-separator-check skips write when content unchanged (mtime preserved)
#   TC05 — path-safety-check emits level:WARN frontmatter when violations present
#   TC06 — path-safety-check skips write when content unchanged (mtime preserved)
#
# Exit 0 = all pass. Exit 1 = any fail.
#
# S341 D1: companion firing-test for content-hash dedup fix.
# Charter v1.1 Principle 11: Harness must self-verify firing.

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

note_pass() { PASS=$(( PASS + 1 )); }
note_fail() {
  FAIL=$(( FAIL + 1 ))
  ERRORS+=("$1")
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_DIR="$SCRIPT_DIR/.."
PYDET_HOOK="$HOOK_DIR/python-determinism-check.sh"
HTMLSEP_HOOK="$HOOK_DIR/html-separator-check.sh"
PSAFE_HOOK="$HOOK_DIR/path-safety-check.sh"

for h in "$PYDET_HOOK" "$HTMLSEP_HOOK" "$PSAFE_HOOK"; do
  [ -f "$h" ] || { echo "FAIL: hook not found: $h"; exit 1; }
  chmod +x "$h" 2>/dev/null || true
done

# Isolated tmpdir
TMP="$(mktemp -d -t escalation-dedup-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_pydet() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  mkdir -p "$TMP/packages/domain/market_data"
  mkdir -p "$TMP/packages/infrastructure/market_data"
  mkdir -p "$TMP/apps/cli"
  mkdir -p "$TMP/scripts/hooks"
  # Inject R1 violation
  cat > "$TMP/packages/domain/market_data/model.py" <<'EOF'
from datetime import datetime
def ts():
    return datetime.now()
EOF
}

setup_htmlsep() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  # Inject HS-R1: multi-entry file without ENTRY_END separator
  # HS-R1 requires >=2 headings AND >=200 lines AND 0 separators
  mkdir -p "$TMP/agent-workspace/memory/observations"
  local obs_file="$TMP/agent-workspace/memory/observations/test-obs.md"
  printf '# Entry A\n\n' > "$obs_file"
  # Pad to 200 lines by writing repetitive content
  for i in $(seq 1 90); do
    printf 'Content line %d for entry A to reach the 200-line threshold.\n' "$i"
  done >> "$obs_file"
  printf '\n# Entry B\n\n' >> "$obs_file"
  for i in $(seq 1 105); do
    printf 'Content line %d for entry B to reach the 200-line threshold.\n' "$i"
  done >> "$obs_file"
}

setup_psafe() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  mkdir -p "$TMP/packages/domain/market_data"
  mkdir -p "$TMP/packages/infrastructure/market_data"
  mkdir -p "$TMP/apps/cli"
  # Inject P1 violation: path traversal
  cat > "$TMP/packages/domain/market_data/loader.py" <<'EOF'
import os
def load(p):
    return open(os.path.join("../etc", p)).read()
EOF
}

run_hook() {
  local hook="$1"
  CLAUDE_PROJECT_DIR="$TMP" bash "$hook" </dev/null >/dev/null 2>&1 || true
}

notif_level() {
  local notif="$1"
  [ -f "$notif" ] || { echo "MISSING"; return; }
  head -10 "$notif" 2>/dev/null | grep -m1 '^level:' | sed 's/^level:[[:space:]]*//' | tr -d '[:space:]' || echo ""
}

# ============================================================
# TC01: python-determinism-check emits level:WARN frontmatter
# ============================================================
setup_pydet
run_hook "$PYDET_HOOK"
NOTIF="$TMP/human-workspace/notifications/python-determinism-warn.md"
LVL=$(notif_level "$NOTIF")
if [ "$LVL" = "WARN" ]; then
  note_pass
else
  note_fail "TC01: expected level:WARN in python-determinism-warn.md, got '$LVL'"
fi

# ============================================================
# TC02: python-determinism-check skips write on unchanged content (mtime preserved)
# ============================================================
setup_pydet
run_hook "$PYDET_HOOK"
NOTIF="$TMP/human-workspace/notifications/python-determinism-warn.md"
if [ ! -f "$NOTIF" ]; then
  note_fail "TC02: notification not created on first run"
else
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  # Sleep 1s to ensure mtime would differ if file were re-written
  sleep 1
  run_hook "$PYDET_HOOK"
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    note_pass
  else
    note_fail "TC02: mtime changed on 2nd run with identical content (dedup did not fire): mtime1=$MTIME1 mtime2=$MTIME2"
  fi
fi

# ============================================================
# TC03: html-separator-check emits level:WARN frontmatter
# ============================================================
setup_htmlsep
run_hook "$HTMLSEP_HOOK"
NOTIF="$TMP/human-workspace/notifications/html-separator-warn.md"
LVL=$(notif_level "$NOTIF")
if [ "$LVL" = "WARN" ]; then
  note_pass
else
  note_fail "TC03: expected level:WARN in html-separator-warn.md, got '$LVL'"
fi

# ============================================================
# TC04: html-separator-check skips write on unchanged content
# ============================================================
setup_htmlsep
run_hook "$HTMLSEP_HOOK"
NOTIF="$TMP/human-workspace/notifications/html-separator-warn.md"
if [ ! -f "$NOTIF" ]; then
  note_fail "TC04: notification not created on first run"
else
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  sleep 1
  run_hook "$HTMLSEP_HOOK"
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    note_pass
  else
    note_fail "TC04: mtime changed on 2nd run with identical html-sep content: mtime1=$MTIME1 mtime2=$MTIME2"
  fi
fi

# ============================================================
# TC05: path-safety-check emits level:WARN frontmatter
# ============================================================
setup_psafe
run_hook "$PSAFE_HOOK"
NOTIF="$TMP/human-workspace/notifications/path-safety-warn.md"
LVL=$(notif_level "$NOTIF")
if [ "$LVL" = "WARN" ]; then
  note_pass
else
  note_fail "TC05: expected level:WARN in path-safety-warn.md, got '$LVL'"
fi

# ============================================================
# TC06: path-safety-check skips write on unchanged content
# ============================================================
setup_psafe
run_hook "$PSAFE_HOOK"
NOTIF="$TMP/human-workspace/notifications/path-safety-warn.md"
if [ ! -f "$NOTIF" ]; then
  note_fail "TC06: notification not created on first run"
else
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  sleep 1
  run_hook "$PSAFE_HOOK"
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    note_pass
  else
    note_fail "TC06: mtime changed on 2nd run with identical path-safety content: mtime1=$MTIME1 mtime2=$MTIME2"
  fi
fi

# ============================================================
# Summary
# ============================================================
TOTAL=$(( PASS + FAIL ))
echo "escalation-spam-dedup-fire-test: ${PASS}/${TOTAL} PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do
    echo "  FAIL: $e"
  done
  exit 1
fi
exit 0
