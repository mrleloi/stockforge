#!/usr/bin/env bash
# Firing-test for drift-signals-D1-D9.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (D-002 Track 5 + D-005 § 5.5d.1; Stop hook): composite
# drift detector running 9 grep-based signals. D1=LOC ceiling overrun
# (PRIMARY), D2=self-attestation drift, D3=charter-mixed bundle, D4=spec
# dangling ref, D5=missing citation, D6=LLM-math, D7=no-bear-case,
# D8=confidence-no-calib, D9=learning-data path leak. Plus DR1/DR3/DR6/DR8
# domain checks. Append violations to .drift-signals.log; exit 2 in
# STOCKFORGE_DRIFT_STRICT=1 + HIGH violations.
#
# Test strategy: stage temp PROJECT_DIR with various fixture trees;
# invoke hook; assert .drift-signals.log entries + exit code.
#
# 10 test cases:
#   TC1 — clean state (no agents/skills/commands/data) → no violations
#   TC2 — agent file 250 LOC > 200 ceiling, overrun ≥ 20% → D1-LOC-CEILING HIGH
#   TC3 — agent file 220 LOC > 200, overrun < 20% → D1-LOC-CEILING MEDIUM
#   TC4 — data file with "18% confidence" but no source/as_of + no calib → D5/D8 HIGH
#   TC5 — D9 path leak: skill referencing learning-data/events → D9-LEARNING-PATH-LEAK
#   TC6 — STOCKFORGE_DRIFT_STRICT=1 + HIGH violation → exit 2 (block)
#   TC7 — fresh session log w/ "LOC within target" + no "wc -l" → D2-SELF-ATTEST MEDIUM (S118)
#   TC8 — fresh session log w/ "LOC within target" AND "wc -l" → NOT flagged (S118)
#   TC9 — fresh session log w/ no LOC claim text → NOT flagged (S118)
#   TC10 — historical session log (mtime > 60 min) w/ unverified LOC claim → NOT flagged
#          (S118 narrowed scan window 1440 → 60 min; out-of-window file falls out cleanly)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../drift-signals-D1-D9.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.drift-signals.log"

run_hook() {
  local strict="${1:-0}"
  STOCKFORGE_DRIFT_STRICT="$strict" CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null >/dev/null 2>&1
  echo $?
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/.claude" "$TEMPDIR/specs" "$TEMPDIR/packages"
  mkdir -p "$TEMPDIR/agent-workspace/memory" "$TEMPDIR/.claude/agents" \
           "$TEMPDIR/.claude/skills" "$TEMPDIR/.claude/commands"
}

# --- TC1: clean state → no violations ---
clean_state
EXIT=$(run_hook 0)
if [ "$EXIT" != "0" ]; then
  echo "FAIL TC1: clean state should exit 0 (got $EXIT)"
  exit 1
fi
if [ -f "$LOG" ] && [ -s "$LOG" ]; then
  echo "FAIL TC1: clean state should NOT log violations"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: clean state → no violations logged"

# --- TC2: agent 250 LOC > 200 ceiling, overrun ≥ 20% → D1 HIGH ---
clean_state
# Generate a 250-line agent file
seq 1 250 | sed 's/.*/# line/' > "$TEMPDIR/.claude/agents/big-agent.md"
EXIT=$(run_hook 0)
if [ "$EXIT" != "0" ]; then
  echo "FAIL TC2: should exit 0 in non-strict mode"
  exit 1
fi
if ! grep -q "D1-LOC-CEILING" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected D1-LOC-CEILING entry"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if ! grep -q "severity=HIGH" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected severity=HIGH (250/200 = 25% overrun ≥ 20%)"
  cat "$LOG"
  exit 1
fi
if ! grep -q "lines=250" "$LOG" 2>/dev/null; then
  echo "FAIL TC2: expected lines=250 in detail"
  cat "$LOG"
  exit 1
fi
echo "PASS TC2: agent 250 LOC > 200 → D1-LOC-CEILING HIGH"

# --- TC3: agent 220 LOC, overrun 10% < 20% → D1 MEDIUM ---
clean_state
seq 1 220 | sed 's/.*/# line/' > "$TEMPDIR/.claude/agents/midsize-agent.md"
EXIT=$(run_hook 0)
if ! grep -q "D1-LOC-CEILING" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected D1-LOC-CEILING entry"
  cat "$LOG"
  exit 1
fi
if ! grep -q "severity=MEDIUM" "$LOG" 2>/dev/null; then
  echo "FAIL TC3: expected severity=MEDIUM (220/200 = 10% overrun < 20%)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC3: agent 220 LOC > 200 (10% overrun) → D1-LOC-CEILING MEDIUM"

# --- TC4: data file with confidence claim but no calibration → D5+D8 ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/thesis-log" "$TEMPDIR/agent-workspace/calibration"
# Note: file mtime must be recent (mmin -1440)
cat > "$TEMPDIR/agent-workspace/calibration/test-thesis.md" <<'EOF'
# Thesis claim
Stock returned 18% over past year with high confidence.
The ROE is around 25% based on Q2 reports.
EOF
EXIT=$(run_hook 0)
if ! grep -q "D5-MISSING-CITATION" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected D5-MISSING-CITATION (numeric without source/as_of)"
  cat "$LOG"
  exit 1
fi
if ! grep -q "D8-CONFIDENCE-NO-CALIB" "$LOG" 2>/dev/null; then
  echo "FAIL TC4: expected D8-CONFIDENCE-NO-CALIB (high confidence without n_samples/hit_rate)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: numeric+confidence without calibration → D5+D8 HIGH"

# --- TC5: D9 path leak — skill referencing learning-data/events ---
clean_state
mkdir -p "$TEMPDIR/.claude/skills/leaky-skill"
cat > "$TEMPDIR/.claude/skills/leaky-skill/SKILL.md" <<'EOF'
# Leaky Skill
This skill reads from learning-data/events directly (anti-pattern).
EOF
EXIT=$(run_hook 0)
if ! grep -q "D9-LEARNING-PATH-LEAK" "$LOG" 2>/dev/null; then
  echo "FAIL TC5: expected D9-LEARNING-PATH-LEAK"
  cat "$LOG"
  exit 1
fi
if ! grep -q "category=read-path" "$LOG" 2>/dev/null; then
  echo "FAIL TC5: expected category=read-path"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: skill refs learning-data/events → D9-LEARNING-PATH-LEAK"

# --- TC6: STOCKFORGE_DRIFT_STRICT=1 + HIGH → exit 2 ---
clean_state
seq 1 250 | sed 's/.*/# line/' > "$TEMPDIR/.claude/agents/big-agent.md"
EXIT=$(run_hook 1)
if [ "$EXIT" != "2" ]; then
  echo "FAIL TC6: STRICT mode + HIGH should exit 2 (got $EXIT)"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC6: STRICT=1 + HIGH violation → exit 2 (block)"

# --- TC7: fresh session log w/ "LOC within target" + no "wc -l" → D2 MEDIUM ---
# S118 backfill (L-S49b-4 charter-coverage discipline). D2 had ZERO test coverage prior.
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-06-session-200.md" <<'EOF'
# Session 200 — sample
agent-notes.md is 563 LOC within target (≤700 cap).
mistake-log.md within target as well.
EOF
EXIT=$(run_hook 0)
if ! grep -q "D2-SELF-ATTEST" "$LOG" 2>/dev/null; then
  echo "FAIL TC7: expected D2-SELF-ATTEST entry"
  cat "$LOG" 2>/dev/null
  exit 1
fi
if ! grep -q "without-wc-l-verification" "$LOG" 2>/dev/null; then
  echo "FAIL TC7: expected detail=without-wc-l-verification"
  cat "$LOG"
  exit 1
fi
echo "PASS TC7: fresh session log w/ unverified LOC claim → D2-SELF-ATTEST MEDIUM"

# --- TC8: fresh session log w/ "LOC within target" AND "wc -l" → NOT flagged ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-06-session-201.md" <<'EOF'
# Session 201 — sample
Verified via `wc -l agent-notes.md` → 563 LOC within target.
EOF
EXIT=$(run_hook 0)
if grep -q "D2-SELF-ATTEST" "$LOG" 2>/dev/null; then
  echo "FAIL TC8: D2-SELF-ATTEST should NOT fire when wc -l verification present"
  cat "$LOG"
  exit 1
fi
echo "PASS TC8: fresh session log w/ wc -l verification → D2-SELF-ATTEST NOT flagged"

# --- TC9: fresh session log w/ no LOC claim text → NOT flagged ---
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-06-session-202.md" <<'EOF'
# Session 202 — sample
Drained backlog item; no architectural change. No commits this session.
EOF
EXIT=$(run_hook 0)
if grep -q "D2-SELF-ATTEST" "$LOG" 2>/dev/null; then
  echo "FAIL TC9: D2-SELF-ATTEST should NOT fire when no LOC-claim trigger words present"
  cat "$LOG"
  exit 1
fi
echo "PASS TC9: fresh session log w/ no LOC claim → D2-SELF-ATTEST NOT flagged"

# --- TC10: historical session log (mtime > 60 min) w/ unverified LOC claim → NOT flagged ---
# S118 narrowed scan window 1440 → 60 min. Verifies out-of-window file is excluded.
clean_state
mkdir -p "$TEMPDIR/agent-workspace/memory/sessions"
cat > "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-099.md" <<'EOF'
# Session 099 — historical
agent-notes.md is 563 LOC within target.
EOF
# Backdate mtime to 65 min ago (out of -mmin -60 window)
PAST_EPOCH=$(( $(date +%s) - 3960 ))
touch -d "@$PAST_EPOCH" "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-099.md"
EXIT=$(run_hook 0)
if grep -q "D2-SELF-ATTEST" "$LOG" 2>/dev/null; then
  echo "FAIL TC10: D2-SELF-ATTEST should NOT fire on historical (>60 min) session log"
  echo "  (S118 fix narrowed scan window from -mmin -1440 to -mmin -60)"
  cat "$LOG"
  exit 1
fi
echo "PASS TC10: historical session log (mtime > 60 min) → D2-SELF-ATTEST NOT flagged"

echo ""
echo "=== ALL FIRING-TESTS PASSED (10/10) ==="
echo "drift-signals-D1-D9.sh externally-observable behavior verified."
exit 0
