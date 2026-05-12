#!/usr/bin/env bash
# Firing-test for sub-plan-completion-coherence.sh (S224 ship per L-S223-1 HOOK-TIER promotion).
#
# Hook purpose: detect routing-staleness — pending/ sub-plans with ≥80% deliverables
# present on disk + no close-row mention in current-execution.md ⇒ WARN.
#
# Per L-S176-1: REAL-STATE-DERIVED fixtures (NEW `<path>` deliverable lines mirror
# 008-S45 + 009-S51 actual format).
#
# 6 test cases:
#   TC1 — pending dir or current-execution.md missing → graceful bail (silent)
#   TC2 — GREEN: pending plan with 50% deliverables on disk → no WARN (below threshold)
#   TC3 — WARN: pending plan with 100% deliverables AND no close-row → WARN
#   TC4 — GREEN: pending plan with 100% deliverables BUT close-row mentions plan_id → no WARN
#   TC5 — cache-hit on 2nd invocation
#   TC6 — L-S108-1 REGRESSION: stale hour-bucket marker cleaned, current-bucket marker exists
#
# Per L-S174-1: use `RC=0; cmd || RC=$?` pattern when checking deliberate non-zero rc.
# Exit 0 = all assertions pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../sub-plan-completion-coherence.sh"
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
  d=$(mktemp -d -t sub-plan-coherence-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/sub-plan-coherence-$$-${RANDOM}")
  mkdir -p "$d/agent-workspace/memory" 2>/dev/null
  mkdir -p "$d/agent-workspace/session-plans/pending" 2>/dev/null
  mkdir -p "$d/agent-workspace/session-plans/completed" 2>/dev/null
  echo "$d"
}

run_hook() {
  local dir="$1" sid="$2"
  local rc=0
  CLAUDE_PROJECT_DIR="$dir" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || rc=$?
  return $rc
}

# === TC1: missing dirs → graceful bail ===
echo "=== TC1: missing pending dir + current-execution.md ==="
TC1_DIR=$(new_tempdir)
rm -rf "$TC1_DIR/agent-workspace/session-plans/pending"
TC1_RC=0
run_hook "$TC1_DIR" "tc1" || TC1_RC=$?
TC1_LOG="$TC1_DIR/agent-workspace/memory/.session-hooks.log"
TC1_FIRED=0
[ -f "$TC1_LOG" ] && grep -q "WARN" "$TC1_LOG" 2>/dev/null && TC1_FIRED=1
assert "TC1: hook exits 0 with missing pending dir" "$([ "$TC1_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC1: no WARN logged" "$([ "$TC1_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC1_DIR" 2>/dev/null || true

# === TC2: GREEN — 50% deliverables on disk (below 80% threshold) ===
echo "=== TC2: GREEN (50% deliverables, below threshold) ==="
TC2_DIR=$(new_tempdir)
echo "# routing log" > "$TC2_DIR/agent-workspace/memory/current-execution.md"
mkdir -p "$TC2_DIR/packages/domain/test_bc"
touch "$TC2_DIR/packages/domain/test_bc/exists_a.py"
# pending plan declares 2 NEW files; only 1 present → 50%
cat > "$TC2_DIR/agent-workspace/session-plans/pending/099-S99-test-half-shipped.md" <<EOF
---
plan_id: 099-S99-test-half-shipped
---
1. NEW \`packages/domain/test_bc/exists_a.py\` ≤50 LOC (present)
2. NEW \`packages/domain/test_bc/missing_b.py\` ≤50 LOC (missing)
EOF
TC2_RC=0
run_hook "$TC2_DIR" "tc2" || TC2_RC=$?
TC2_CACHE="$TC2_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc2"
TC2_STATE=$(grep -oE 'state=[A-Z-]+' "$TC2_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC2_WARN_LOG="$TC2_DIR/agent-workspace/memory/.sub-plan-coherence.log"
TC2_WARN_FIRED=0
[ -f "$TC2_WARN_LOG" ] && [ -s "$TC2_WARN_LOG" ] && TC2_WARN_FIRED=1
assert "TC2: hook exits 0" "$([ "$TC2_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC2: cache state=GREEN (below threshold)" "$([ "$TC2_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC2: no WARN drift-log entry" "$([ "$TC2_WARN_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC2_DIR" 2>/dev/null || true

# === TC3: WARN — 100% deliverables on disk, NO close-row mention ===
echo "=== TC3: WARN (100% deliverables, no close-row) ==="
TC3_DIR=$(new_tempdir)
echo "# routing log — no mention of plan id" > "$TC3_DIR/agent-workspace/memory/current-execution.md"
mkdir -p "$TC3_DIR/packages/domain/test_bc"
touch "$TC3_DIR/packages/domain/test_bc/file_a.py"
touch "$TC3_DIR/packages/domain/test_bc/file_b.py"
cat > "$TC3_DIR/agent-workspace/session-plans/pending/099-S100-test-fully-shipped.md" <<EOF
---
plan_id: 099-S100-test-fully-shipped
---
1. NEW \`packages/domain/test_bc/file_a.py\` ≤50 LOC
2. NEW \`packages/domain/test_bc/file_b.py\` ≤50 LOC
EOF
TC3_RC=0
run_hook "$TC3_DIR" "tc3" || TC3_RC=$?
TC3_CACHE="$TC3_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc3"
TC3_STATE=$(grep -oE 'state=[A-Z-]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC3_WARN_COUNT=$(grep -oE 'warn_count=[0-9]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/warn_count=//')
TC3_WARN_LOG="$TC3_DIR/agent-workspace/memory/.sub-plan-coherence.log"
TC3_WARN_FIRED=0
[ -f "$TC3_WARN_LOG" ] && grep -q "tc3" "$TC3_WARN_LOG" 2>/dev/null && TC3_WARN_FIRED=1
TC3_PLAN_IN_LOG=0
[ -f "$TC3_WARN_LOG" ] && grep -q "099-S100" "$TC3_WARN_LOG" 2>/dev/null && TC3_PLAN_IN_LOG=1
assert "TC3: hook exits 0 (soft-warn)" "$([ "$TC3_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC3: cache state=WARN" "$([ "$TC3_STATE" = "WARN" ] && echo 1 || echo 0)"
assert "TC3: warn_count=1" "$([ "$TC3_WARN_COUNT" = "1" ] && echo 1 || echo 0)"
assert "TC3: WARN drift-log entry written" "$([ "$TC3_WARN_FIRED" -eq 1 ] && echo 1 || echo 0)"
assert "TC3: plan_id mentioned in drift-log" "$([ "$TC3_PLAN_IN_LOG" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC3_DIR" 2>/dev/null || true

# === TC4: GREEN — 100% deliverables BUT close-row mentions plan_id ===
echo "=== TC4: GREEN (100% deliverables, close-row mentions plan_id) ==="
TC4_DIR=$(new_tempdir)
# routing log mentions plan_id 099-S101 — simulates close-row already prepended
echo "## S225 — Phase X — RECONCILE plan 099-S101 to completed/ — 100% on disk" > "$TC4_DIR/agent-workspace/memory/current-execution.md"
mkdir -p "$TC4_DIR/packages/domain/test_bc"
touch "$TC4_DIR/packages/domain/test_bc/closed_a.py"
touch "$TC4_DIR/packages/domain/test_bc/closed_b.py"
cat > "$TC4_DIR/agent-workspace/session-plans/pending/099-S101-test-close-row-present.md" <<EOF
---
plan_id: 099-S101-test-close-row-present
---
1. NEW \`packages/domain/test_bc/closed_a.py\` ≤50 LOC
2. NEW \`packages/domain/test_bc/closed_b.py\` ≤50 LOC
EOF
TC4_RC=0
run_hook "$TC4_DIR" "tc4" || TC4_RC=$?
TC4_CACHE="$TC4_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc4"
TC4_STATE=$(grep -oE 'state=[A-Z-]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC4_WARN_LOG="$TC4_DIR/agent-workspace/memory/.sub-plan-coherence.log"
TC4_WARN_FIRED=0
[ -f "$TC4_WARN_LOG" ] && [ -s "$TC4_WARN_LOG" ] && TC4_WARN_FIRED=1
assert "TC4: cache state=GREEN (close-row found)" "$([ "$TC4_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC4: no WARN drift-log entry" "$([ "$TC4_WARN_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC4_DIR" 2>/dev/null || true

# === TC5: cache-hit on 2nd invocation ===
echo "=== TC5: cache-hit on 2nd invocation ==="
TC5_DIR=$(new_tempdir)
echo "# routing log" > "$TC5_DIR/agent-workspace/memory/current-execution.md"
TC5_LOG="$TC5_DIR/agent-workspace/memory/.session-hooks.log"
run_hook "$TC5_DIR" "tc5"
run_hook "$TC5_DIR" "tc5"
TC5_HITS=$(grep -c "CACHE-HIT" "$TC5_LOG" 2>/dev/null || echo 0)
[[ "$TC5_HITS" =~ ^[0-9]+$ ]] || TC5_HITS=0
assert "TC5: CACHE-HIT logged on 2nd invocation" "$([ "$TC5_HITS" -ge 1 ] && echo 1 || echo 0)"
rm -rf "$TC5_DIR" 2>/dev/null || true

# === TC6: L-S108-1 REGRESSION — stale marker cleaned ===
echo "=== TC6: L-S108-1 REGRESSION (stale hour-bucket marker cleaned) ==="
TC6_DIR=$(new_tempdir)
echo "# routing log" > "$TC6_DIR/agent-workspace/memory/current-execution.md"
touch "$TC6_DIR/agent-workspace/memory/.sub-plan-coherence-fired-20260105-13"
TC6_RC=0
run_hook "$TC6_DIR" "tc6" || TC6_RC=$?
TC6_STALE=$([ -f "$TC6_DIR/agent-workspace/memory/.sub-plan-coherence-fired-20260105-13" ] && echo 0 || echo 1)
TC6_CURRENT_BUCKET="$TC6_DIR/agent-workspace/memory/.sub-plan-coherence-fired-$(date +%Y%m%d-%H)"
TC6_CURRENT_EXISTS=$([ -f "$TC6_CURRENT_BUCKET" ] && echo 1 || echo 0)
assert "TC6: stale hour-bucket marker cleaned" "$TC6_STALE"
assert "TC6: current-bucket marker exists post-fire" "$TC6_CURRENT_EXISTS"
rm -rf "$TC6_DIR" 2>/dev/null || true

# === TC7: GREEN — master-plan in pending with phase=N where project.md says IN PROGRESS ===
echo "=== TC7: GREEN (master-plan phase IN PROGRESS) ==="
TC7_DIR=$(new_tempdir)
echo "# routing log" > "$TC7_DIR/agent-workspace/memory/current-execution.md"
cat > "$TC7_DIR/agent-workspace/memory/project.md" <<'EOF'
## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 4 — Multi-perspective | desc | IN PROGRESS — Phase 4 PLAN LANDED | 2026-05-09 | - |
EOF
cat > "$TC7_DIR/agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md" <<'EOF'
---
plan_id: 008-S235-phase-4-master-plan
phase: 4
status: active
---
# Phase 4 master-plan body
EOF
TC7_RC=0
run_hook "$TC7_DIR" "tc7" || TC7_RC=$?
TC7_CACHE="$TC7_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc7"
TC7_STATE=$(grep -oE 'state=[A-Z-]+' "$TC7_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
assert "TC7: hook exits 0" "$([ "$TC7_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC7: cache state=GREEN (active phase, no MP-WARN)" "$([ "$TC7_STATE" = "GREEN" ] && echo 1 || echo 0)"
rm -rf "$TC7_DIR" 2>/dev/null || true

# === TC8: WARN — master-plan in pending with phase=N where project.md says CLOSED ===
echo "=== TC8: WARN (master-plan phase CLOSED, MP-staleness) ==="
TC8_DIR=$(new_tempdir)
echo "# routing log" > "$TC8_DIR/agent-workspace/memory/current-execution.md"
cat > "$TC8_DIR/agent-workspace/memory/project.md" <<'EOF'
## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 3 — Tier 3+4 KOL | desc | CLOSED-S234 PASS-WITH-RESIDUE | 2026-05-05 | 2026-05-09 |
EOF
cat > "$TC8_DIR/agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md" <<'EOF'
---
plan_id: 007-S44-phase-3-master-plan
phase: 3
status: active
---
# Phase 3 master-plan body — should have been moved to completed/
EOF
TC8_RC=0
run_hook "$TC8_DIR" "tc8" || TC8_RC=$?
TC8_CACHE="$TC8_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc8"
TC8_STATE=$(grep -oE 'state=[A-Z-]+' "$TC8_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC8_WARN_LOG="$TC8_DIR/agent-workspace/memory/.sub-plan-coherence.log"
TC8_MP_FLAGGED=0
[ -f "$TC8_WARN_LOG" ] && grep -q "MP-phase-3-closed" "$TC8_WARN_LOG" 2>/dev/null && TC8_MP_FLAGGED=1
assert "TC8: hook exits 0 (soft-warn)" "$([ "$TC8_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC8: cache state=WARN" "$([ "$TC8_STATE" = "WARN" ] && echo 1 || echo 0)"
assert "TC8: MP-phase-3-closed flag in drift-log" "$([ "$TC8_MP_FLAGGED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC8_DIR" 2>/dev/null || true

# === TC9: GREEN — master-plan with phase=2.5 (decimal); project.md DONE → WARN; verifies decimal regex ===
echo "=== TC9: WARN decimal-phase token ==="
TC9_DIR=$(new_tempdir)
echo "# routing log" > "$TC9_DIR/agent-workspace/memory/current-execution.md"
cat > "$TC9_DIR/agent-workspace/memory/project.md" <<'EOF'
## Phase Goals Tracker

| Phase | Target | Status | Started | Completed |
|---|---|---|---|---|
| 2.5 — Harness Hardening | desc | DONE | 2026-05-05 | 2026-05-07 |
EOF
cat > "$TC9_DIR/agent-workspace/session-plans/pending/009-S48-harness-hardening.md" <<'EOF'
---
plan_id: 009-S48-harness-hardening
phase: 2.5
---
# Phase 2.5 master-plan body
EOF
TC9_RC=0
run_hook "$TC9_DIR" "tc9" || TC9_RC=$?
TC9_CACHE="$TC9_DIR/agent-workspace/memory/.sub-plan-coherence-cache-tc9"
TC9_STATE=$(grep -oE 'state=[A-Z-]+' "$TC9_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC9_WARN_LOG="$TC9_DIR/agent-workspace/memory/.sub-plan-coherence.log"
TC9_FLAGGED=0
[ -f "$TC9_WARN_LOG" ] && grep -q "MP-phase-2.5-closed" "$TC9_WARN_LOG" 2>/dev/null && TC9_FLAGGED=1
assert "TC9: hook exits 0" "$([ "$TC9_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC9: decimal phase token 2.5 detected as DONE" "$([ "$TC9_STATE" = "WARN" ] && echo 1 || echo 0)"
assert "TC9: MP-phase-2.5-closed flag in drift-log" "$([ "$TC9_FLAGGED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC9_DIR" 2>/dev/null || true

# === Summary ===
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ALL firing-tests passed (sub-plan-completion-coherence S224+S235 — sub-plan + master-plan staleness detection)."
  exit 0
else
  echo "  $FAIL firing-test(s) failed."
  exit 1
fi
