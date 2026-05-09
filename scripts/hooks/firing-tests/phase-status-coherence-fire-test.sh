#!/usr/bin/env bash
# Firing-test for phase-status-coherence.sh.
# Phase 3.5 / S175 deliverable. Per Hard Rule #2 every hook ships with companion
# firing-test that synthesizes a deliberate FAIL state + asserts hook detects it.
#
# 6 test cases:
#   TC1 — files missing → silent (graceful bail)
#   TC2 — aligned (CE Phase 3.5 + project.md row 3.5 IN PROGRESS) → silent GREEN
#   TC3 — mismatch (CE Phase 9 + project.md only Phase 3.5 IN PROGRESS) → RED HIGH
#   TC4 — stale project.md (3 NEW ADRs newer than project.md by >2h) → YELLOW MEDIUM
#   TC5 — no IN PROGRESS rows in project.md (all DONE/PAUSED) → YELLOW MEDIUM
#   TC6 — cache-hit on 2nd invocation → CACHE-HIT log

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../phase-status-coherence.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }
[ -x "$HOOK" ] || chmod +x "$HOOK" 2>/dev/null || true

PASS=0
FAIL=0
TOTAL=0

assert() {
  local desc="$1" cond="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$cond" = "1" ] || [ "$cond" = "true" ]; then
    PASS=$((PASS + 1))
    echo "  [PASS] $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  [FAIL] $desc"
  fi
}

new_tempdir() {
  local d
  d=$(mktemp -d -t phase-coherence-test-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/phase-coherence-$$-${RANDOM}")
  mkdir -p "$d/agent-workspace/memory" "$d/agent-workspace/memory/decisions" 2>/dev/null
  echo "$d"
}

write_ce() {
  local out="$1" sid="$2" phase="$3" label="${4:-FOCUSED_IMPL-DONE}"
  cat > "$out" <<EOF
# Current Execution — Test fixture

## ${sid} — Phase ${phase} — ${label}: synthesized fixture session.

Body of session ${sid}.

---
EOF
}

write_proj_with_row() {
  local out="$1" phase="$2" status="$3"
  cat > "$out" <<EOF
# Project Memory — Test fixture

## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| ${phase} — Synth | tests | ${status} | 2026-05-01 | - |
| 99 — Future | nothing | NOT STARTED | - | - |

## Recent ADRs

(none for fixture)
EOF
}

# === TC1: both files missing → silent ===
echo "=== TC1: missing files ==="
TC1_DIR=$(new_tempdir)
TC1_LOG="$TC1_DIR/agent-workspace/memory/.session-hooks.log"
TC1_COH_LOG="$TC1_DIR/agent-workspace/memory/.phase-coherence.log"
RC=0
CLAUDE_PROJECT_DIR="$TC1_DIR" CLAUDE_SESSION_ID="tc1" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
TC1_FIRED=0
[ -f "$TC1_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC1_COH_LOG" 2>/dev/null && TC1_FIRED=1
assert "TC1: hook exits 0 with missing files" "$([ "$RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC1: no drift fired (graceful bail)" "$([ "$TC1_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC1_DIR" 2>/dev/null || true

# === TC2: aligned → silent GREEN ===
echo "=== TC2: aligned (CE 3.5 + project.md 3.5 IN PROGRESS) ==="
TC2_DIR=$(new_tempdir)
write_ce "$TC2_DIR/agent-workspace/memory/current-execution.md" "S174" "3.5"
write_proj_with_row "$TC2_DIR/agent-workspace/memory/project.md" "3.5" "IN PROGRESS"
TC2_CACHE="$TC2_DIR/agent-workspace/memory/.phase-coherence-cache-tc2"
TC2_COH_LOG="$TC2_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC2_DIR" CLAUDE_SESSION_ID="tc2" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC2_STATE=$(grep -oE 'state=[A-Z]+' "$TC2_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC2_MATCH=$(grep -oE 'match=[01]' "$TC2_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
TC2_FIRED=0
[ -f "$TC2_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC2_COH_LOG" 2>/dev/null && TC2_FIRED=1
assert "TC2: state=GREEN (aligned)" "$([ "$TC2_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC2: match=1 (phase aligned)" "$([ "$TC2_MATCH" = "1" ] && echo 1 || echo 0)"
assert "TC2: no drift fired" "$([ "$TC2_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC2_DIR" 2>/dev/null || true

# === TC3: mismatch → RED HIGH ===
echo "=== TC3: mismatch (CE 9 + project.md 3.5 IN PROGRESS) ==="
TC3_DIR=$(new_tempdir)
write_ce "$TC3_DIR/agent-workspace/memory/current-execution.md" "S180" "9"
write_proj_with_row "$TC3_DIR/agent-workspace/memory/project.md" "3.5" "IN PROGRESS"
TC3_CACHE="$TC3_DIR/agent-workspace/memory/.phase-coherence-cache-tc3"
TC3_COH_LOG="$TC3_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC3_DIR" CLAUDE_SESSION_ID="tc3" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC3_STATE=$(grep -oE 'state=[A-Z]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC3_SEV=$(grep -oE 'severity=[A-Z]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/severity=//')
TC3_MATCH=$(grep -oE 'match=[01]' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
TC3_FIRED=0
[ -f "$TC3_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC3_COH_LOG" 2>/dev/null && TC3_FIRED=1
assert "TC3: state=RED (mismatch)" "$([ "$TC3_STATE" = "RED" ] && echo 1 || echo 0)"
assert "TC3: severity=HIGH" "$([ "$TC3_SEV" = "HIGH" ] && echo 1 || echo 0)"
assert "TC3: match=0 (drift)" "$([ "$TC3_MATCH" = "0" ] && echo 1 || echo 0)"
assert "TC3: drift fired" "$([ "$TC3_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC3_DIR" 2>/dev/null || true

# === TC4: stale project.md (3 NEW ADRs >2h newer) → YELLOW ===
echo "=== TC4: stale project.md (3 NEW ADRs newer) ==="
TC4_DIR=$(new_tempdir)
write_ce "$TC4_DIR/agent-workspace/memory/current-execution.md" "S180" "3.5"
write_proj_with_row "$TC4_DIR/agent-workspace/memory/project.md" "3.5" "IN PROGRESS"
# Make project.md old (48 hours old) — well past 2h tolerance + 24h threshold.
touch -d "48 hours ago" "$TC4_DIR/agent-workspace/memory/project.md" 2>/dev/null || \
  touch -t "$(date -d '48 hours ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC4_DIR/agent-workspace/memory/project.md" 2>/dev/null || true
# Touch CE recent so CE_PROJ_DELTA_HR >24
touch "$TC4_DIR/agent-workspace/memory/current-execution.md" 2>/dev/null || true
# 3 new ADRs (mtime now → newer than project.md by 48h).
echo "# D-100" > "$TC4_DIR/agent-workspace/memory/decisions/D-100-test.md"
echo "# D-101" > "$TC4_DIR/agent-workspace/memory/decisions/D-101-test.md"
echo "# D-102" > "$TC4_DIR/agent-workspace/memory/decisions/D-102-test.md"
TC4_CACHE="$TC4_DIR/agent-workspace/memory/.phase-coherence-cache-tc4"
TC4_COH_LOG="$TC4_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC4_DIR" CLAUDE_SESSION_ID="tc4" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC4_STATE=$(grep -oE 'state=[A-Z]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC4_NEW=$(grep -oE 'new_adrs=[0-9]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/new_adrs=//')
TC4_FIRED=0
[ -f "$TC4_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC4_COH_LOG" 2>/dev/null && TC4_FIRED=1
assert "TC4: state=YELLOW (stale project.md)" "$([ "$TC4_STATE" = "YELLOW" ] && echo 1 || echo 0)"
assert "TC4: new_adrs=3 detected" "$([ "$TC4_NEW" = "3" ] && echo 1 || echo 0)"
assert "TC4: drift fired" "$([ "$TC4_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC4_DIR" 2>/dev/null || true

# === TC5: no IN PROGRESS rows → YELLOW ===
echo "=== TC5: no IN PROGRESS rows ==="
TC5_DIR=$(new_tempdir)
write_ce "$TC5_DIR/agent-workspace/memory/current-execution.md" "S180" "3.5"
cat > "$TC5_DIR/agent-workspace/memory/project.md" <<'EOF'
# Project — all phases done/paused

## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 0 — Bootstrap | xx | DONE | 2026-04-01 | 2026-04-15 |
| 3 — Tier3 | xx | PAUSED | 2026-05-05 | - |
| 99 — Future | xx | NOT STARTED | - | - |
EOF
TC5_CACHE="$TC5_DIR/agent-workspace/memory/.phase-coherence-cache-tc5"
TC5_COH_LOG="$TC5_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC5_DIR" CLAUDE_SESSION_ID="tc5" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC5_STATE=$(grep -oE 'state=[A-Z]+' "$TC5_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC5_DETAILS=$(grep -oE 'details=[^[:space:]]+' "$TC5_CACHE" 2>/dev/null | head -1)
TC5_FIRED=0
[ -f "$TC5_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC5_COH_LOG" 2>/dev/null && TC5_FIRED=1
assert "TC5: state=YELLOW (no in-progress)" "$([ "$TC5_STATE" = "YELLOW" ] && echo 1 || echo 0)"
assert "TC5: details mention no-in-progress-phase" "$(echo "$TC5_DETAILS" | grep -q 'no-in-progress-phase' && echo 1 || echo 0)"
assert "TC5: drift fired" "$([ "$TC5_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC5_DIR" 2>/dev/null || true

# === TC6: cache-hit ===
echo "=== TC6: cache-hit on 2nd invocation ==="
TC6_DIR=$(new_tempdir)
write_ce "$TC6_DIR/agent-workspace/memory/current-execution.md" "S180" "3.5"
write_proj_with_row "$TC6_DIR/agent-workspace/memory/project.md" "3.5" "IN PROGRESS"
TC6_LOG="$TC6_DIR/agent-workspace/memory/.session-hooks.log"
CLAUDE_PROJECT_DIR="$TC6_DIR" CLAUDE_SESSION_ID="tc6" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
CLAUDE_PROJECT_DIR="$TC6_DIR" CLAUDE_SESSION_ID="tc6" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC6_HITS=$(grep -c "CACHE-HIT" "$TC6_LOG" 2>/dev/null || echo 0)
[[ "$TC6_HITS" =~ ^[0-9]+$ ]] || TC6_HITS=0
assert "TC6: cache-hit on 2nd invocation" "$([ "$TC6_HITS" -ge 1 ] && echo 1 || echo 0)"
rm -rf "$TC6_DIR" 2>/dev/null || true

# === Summary ===
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ALL firing-tests passed (phase-status-coherence M-S171-1 prevention rule)."
  exit 0
else
  echo "  $FAIL firing-test(s) failed."
  exit 1
fi
