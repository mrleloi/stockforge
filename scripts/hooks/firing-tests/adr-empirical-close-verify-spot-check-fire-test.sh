#!/usr/bin/env bash
# Firing-test for adr-empirical-close-verify-spot-check.sh (E.3 deliverable; S250).
# Extended S388 D5 plan-039 (L-S369-1 PROMOTE-NOW): adds TC6-TC9 for N=3 sample + HIGH severity.
#
# Hook purpose (D-052 ghost-greening RCA / S250 Minimum E):
# Random-sample 3 ACCEPTED ADRs per fire (was 1; L-S369-1 D5 promotion),
# re-run any "grep ... = 0 hits" claim, flag divergence with HIGH severity to .severity-state.tsv.
#
# Test strategy: stage temp PROJECT_DIR with crafted ADR files + production-code
# files that match-or-don't-match the grep claim; invoke hook; assert
# .adr-empirical-spot-check.log content + .session-hooks.log line + .severity-state.tsv.
#
# 9 test cases:
#   TC1 — no ACCEPTED ADRs in window → silent
#   TC2 — ACCEPTED ADR with "= 0 hits" claim + actual production-code = 0 hits → clean log line, no DIVERGENCE
#   TC3 — ACCEPTED ADR with "= 0 hits" claim + actual production-code > 0 hits → DIVERGENCE logged
#   TC4 — ACCEPTED ADR with NO "= 0 hits" claim (only PASS-count claims) → silent (PASS-skip path)
#   TC5 — ADR with status PROPOSED (not ACCEPTED) → skipped (out of candidate pool)
#   TC6 — hook samples N=3 (not 1) per fire (shuf -n 3 check)
#   TC7 — divergence detection emits HIGH severity row to .severity-state.tsv
#   TC8 — no divergence → NO HIGH row in .severity-state.tsv
#   TC9 — no ACCEPTED ADRs with empirical_close_verify → silent (empty PICKS)
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

# --- TC6: hook uses shuf -n 3 (N=3 sample per fire — L-S369-1 D5 plan-039) ---
# Verify the hook script contains 'shuf -n 3' (not shuf -n 1).
SHUF_N=$(grep 'shuf -n' "$HOOK" | grep -o 'shuf -n [0-9]*' | head -1)
if [ "$SHUF_N" = "shuf -n 3" ]; then
  echo "PASS TC6: hook samples N=3 per fire (shuf -n 3 confirmed)"
else
  echo "FAIL TC6: expected 'shuf -n 3' but found: '$SHUF_N'"
  exit 1
fi

# --- TC7: divergence emits HIGH severity row to .severity-state.tsv ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/095-high-sev.md" <<'EOF'
---
id: D-095-high-sev
status: ACCEPTED
level: ARCH
empirical_close_verify:
  - "Production-code grep `import anthropic` in packages/ = 0 hits"
---
body
EOF
cat > "$TEMPDIR/packages/infrastructure/news/with_anthropic.py" <<'EOF'
import anthropic
client = anthropic.Anthropic()
EOF
run_hook
SEVER_STATE="$TEMPDIR/agent-workspace/memory/.severity-state.tsv"
if [ -f "$SEVER_STATE" ] && grep -q "HIGH" "$SEVER_STATE" 2>/dev/null && grep -q "095-high-sev" "$SEVER_STATE" 2>/dev/null; then
  echo "PASS TC7: divergence → HIGH severity row in .severity-state.tsv for adr_id=095-high-sev"
else
  echo "FAIL TC7: expected HIGH severity row in .severity-state.tsv; state:"
  cat "$SEVER_STATE" 2>&1 || echo "(no .severity-state.tsv)"
  exit 1
fi

# --- TC8: no divergence → NO HIGH row in .severity-state.tsv ---
clean_state
cat > "$TEMPDIR/agent-workspace/memory/decisions/094-clean-high.md" <<'EOF'
---
id: D-094-clean-high
status: ACCEPTED
level: ARCH
empirical_close_verify:
  - "Production-code grep `import neverexists` in packages/ = 0 hits"
---
body
EOF
echo "import sys" > "$TEMPDIR/packages/infrastructure/news/no_match.py"
run_hook
SEVER_STATE="$TEMPDIR/agent-workspace/memory/.severity-state.tsv"
if [ -f "$SEVER_STATE" ] && grep -q "094-clean-high" "$SEVER_STATE" 2>/dev/null; then
  echo "FAIL TC8: clean ADR should NOT produce HIGH severity row; state:"
  cat "$SEVER_STATE"
  exit 1
fi
echo "PASS TC8: clean ADR → no HIGH row in .severity-state.tsv"

# --- TC9: no ACCEPTED ADRs with empirical_close_verify → silent ---
clean_state
# ADR exists but NO empirical_close_verify field.
cat > "$TEMPDIR/agent-workspace/memory/decisions/093-no-ecv.md" <<'EOF'
---
id: D-093-no-ecv
status: ACCEPTED
level: ARCH
---
## Decision
No empirical_close_verify field here.
EOF
run_hook
if [ -f "$LOG" ] && grep -q "DIVERGENCE.*093" "$LOG" 2>/dev/null; then
  echo "FAIL TC9: ADR without empirical_close_verify should produce no DIVERGENCE"
  exit 1
fi
echo "PASS TC9: ADR with no empirical_close_verify → silent skip"

echo ""
echo "=== ALL FIRING-TESTS PASSED (9/9) ==="
echo "adr-empirical-close-verify-spot-check.sh externally-observable behavior verified."
exit 0
