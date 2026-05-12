#!/usr/bin/env bash
# Firing-test for adr-empirical-close-verify-spot-check.sh (E.3 deliverable; S250).
#
# Hook purpose (D-052 ghost-greening RCA / S250 Minimum E):
# Random-sample a recently-ACCEPTED ADR's empirical_close_verify block,
# re-run any "grep ... = 0 hits" claim, flag divergence.
#
# Test strategy: stage temp PROJECT_DIR with crafted ADR files + production-code
# files that match-or-don't-match the grep claim; invoke hook; assert
# .adr-empirical-spot-check.log content + .session-hooks.log line.
#
# 5 test cases:
#   TC1 — no ACCEPTED ADRs in window → silent
#   TC2 — ACCEPTED ADR with "= 0 hits" claim + actual production-code = 0 hits → clean log line, no DIVERGENCE
#   TC3 — ACCEPTED ADR with "= 0 hits" claim + actual production-code > 0 hits → DIVERGENCE logged
#   TC4 — ACCEPTED ADR with NO "= 0 hits" claim (only PASS-count claims) → silent (PASS-skip path)
#   TC5 — ADR with status PROPOSED (not ACCEPTED) → skipped (out of candidate pool)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../adr-empirical-close-verify-spot-check.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.adr-empirical-spot-check.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null >/dev/null 2>/dev/null || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/packages" "$TEMPDIR/apps"
  mkdir -p "$TEMPDIR/agent-workspace/memory/decisions"
  mkdir -p "$TEMPDIR/packages/infrastructure/news"
  mkdir -p "$TEMPDIR/apps"
}

# --- TC1: no ACCEPTED ADRs in window → silent ---
clean_state
run_hook
if [ -f "$LOG" ] && grep -q DIVERGENCE "$LOG" 2>/dev/null; then
  echo "FAIL TC1: no ADRs should produce no DIVERGENCE; log:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: empty decisions dir → silent"

# --- TC2: ACCEPTED ADR + clean production code → no DIVERGENCE ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/099-clean-adr.md" <<'EOF'
---
id: D-099-clean
status: ACCEPTED
level: ARCH
empirical_close_verify:
  - "Production-code grep `import oldlib` in packages/+apps/ = 0 hits"

files_touched:
  - "deleted"
---
body
EOF
# No production code has "import oldlib"
echo "import sys" > "$TEMPDIR/packages/infrastructure/news/clean.py"
run_hook
if [ -f "$LOG" ] && grep -q "DIVERGENCE.*D-099-clean" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: clean ADR should not log DIVERGENCE; log:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: clean ADR + matching working tree → no DIVERGENCE"

# --- TC3: ACCEPTED ADR + DIVERGENT production code → DIVERGENCE logged ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/098-ghost-adr.md" <<'EOF'
---
id: D-098-ghost
status: ACCEPTED
level: ARCH
empirical_close_verify:
  - "Production-code grep `import anthropic` in packages/+apps/ = 0 hits"

files_touched:
  - "supposedly removed"
---
body
EOF
# Production code STILL has "import anthropic" — divergence!
cat > "$TEMPDIR/packages/infrastructure/news/ghost.py" <<'EOF'
import anthropic
client = anthropic.Anthropic()
EOF
run_hook
if ! grep -q "DIVERGENCE.*098-ghost-adr" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected DIVERGENCE in log for 098-ghost-adr; log:"
  cat "$LOG" 2>&1 || echo "(no log)"
  exit 1
fi
echo "PASS TC3: ghost-greening ADR + divergent working tree → DIVERGENCE logged"

# --- TC4: ACCEPTED ADR with only PASS-count claims (no '= 0 hits') → silent on probe ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/097-pass-only.md" <<'EOF'
---
id: D-097-pass-only
status: ACCEPTED
level: IMPL
empirical_close_verify:
  - "pytest packages/ = 125 PASS in 0.83s"
  - "firing-tests/run-all.sh = 86/86 PASS in 236s"
  - "py_compile all 3 edited files = OK"

files_touched: []
---
body
EOF
run_hook
if [ -f "$LOG" ] && grep -q "DIVERGENCE.*097-pass-only" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: PASS-only ADR should be silent (no grep claims to probe); log:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: PASS-count-only claims → skipped (no DIVERGENCE)"

# --- TC5: PROPOSED ADR (not ACCEPTED) → not in candidate pool ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/096-proposed.md" <<'EOF'
---
id: D-096-proposed
status: PROPOSED
level: ARCH
empirical_close_verify:
  - "Production-code grep `import anthropic` = 0 hits"
---
body
EOF
cat > "$TEMPDIR/packages/infrastructure/news/x.py" <<'EOF'
import anthropic
EOF
run_hook
if grep -q "DIVERGENCE.*096-proposed" "$LOG" 2>/dev/null; then
  echo "FAIL TC5: PROPOSED ADRs should be skipped; log:"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: PROPOSED ADR → skipped (not in ACCEPTED candidate pool)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "adr-empirical-close-verify-spot-check.sh externally-observable behavior verified."
exit 0
