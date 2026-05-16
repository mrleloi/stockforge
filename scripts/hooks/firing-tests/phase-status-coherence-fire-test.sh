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

# === TC07: letter-phase D maps to numeric 4 (Wave 1 A-E → Phase 4) ===
# D4 S346 plan-023: verifies that "Phase D" headers match project.md Phase 4 IN PROGRESS.
# This is the ~25-session silent false-positive RED HIGH fix.
echo "=== TC07: letter-phase D → resolved to 4 (D4 fix) ==="
TC7_DIR=$(new_tempdir)
cat > "$TC7_DIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution — Test fixture

## S343 — Phase D NDH adapter PLAN dispatched — 2026-05-16

Body of session S343.

---
EOF
write_proj_with_row "$TC7_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
TC7_CACHE="$TC7_DIR/agent-workspace/memory/.phase-coherence-cache-tc7"
TC7_COH_LOG="$TC7_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC7_DIR" CLAUDE_SESSION_ID="tc7" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC7_STATE=$(grep -oE 'state=[A-Z]+' "$TC7_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC7_MATCH=$(grep -oE 'match=[01]' "$TC7_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
TC7_FIRED=0
[ -f "$TC7_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC7_COH_LOG" 2>/dev/null && TC7_FIRED=1
assert "TC07: state=GREEN (Phase D resolves to 4, matches IN PROGRESS)" "$([ "$TC7_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC07: match=1 (D→4 mapping correct)" "$([ "$TC7_MATCH" = "1" ] && echo 1 || echo 0)"
assert "TC07: no drift fired (D is valid Wave 1 letter)" "$([ "$TC7_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC7_DIR" 2>/dev/null || true

# === TC08: letter-phase F-prime maps to numeric 4 (Wave 1 -prime suffix) ===
echo "=== TC08: letter-phase F-prime → resolved to 4 (D4 fix, -prime suffix) ==="
TC8_DIR=$(new_tempdir)
cat > "$TC8_DIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution — Test fixture

## S400 — Phase F-prime — Theme placeholder — 2026-06-01

Body of session S400.

---
EOF
write_proj_with_row "$TC8_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
TC8_CACHE="$TC8_DIR/agent-workspace/memory/.phase-coherence-cache-tc8"
TC8_COH_LOG="$TC8_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC8_DIR" CLAUDE_SESSION_ID="tc8" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC8_STATE=$(grep -oE 'state=[A-Z]+' "$TC8_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC8_MATCH=$(grep -oE 'match=[01]' "$TC8_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
TC8_FIRED=0
[ -f "$TC8_COH_LOG" ] && grep -q "DRIFT-DETECTED" "$TC8_COH_LOG" 2>/dev/null && TC8_FIRED=1
assert "TC08: state=GREEN (Phase F-prime resolves to 4)" "$([ "$TC8_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC08: match=1 (F-prime→4 mapping correct)" "$([ "$TC8_MATCH" = "1" ] && echo 1 || echo 0)"
assert "TC08: no drift fired (F-prime is valid Wave 1 letter)" "$([ "$TC8_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC8_DIR" 2>/dev/null || true

# === TC09: unknown letter Z defaults to pass-through (no match → RED) ===
# The default branch in the case statement leaves LATEST_PHASE_RESOLVED=Z,
# which won't match any numeric IN_PROGRESS row → RED HIGH as expected (anomaly signal).
echo "=== TC09: unknown letter Z → pass-through default, RED if no Z row ==="
TC9_DIR=$(new_tempdir)
cat > "$TC9_DIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution — Test fixture

## S500 — Phase Z — Future unknown phase — 2027-01-01

Body of session S500.

---
EOF
write_proj_with_row "$TC9_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
TC9_CACHE="$TC9_DIR/agent-workspace/memory/.phase-coherence-cache-tc9"
TC9_COH_LOG="$TC9_DIR/agent-workspace/memory/.phase-coherence.log"
CLAUDE_PROJECT_DIR="$TC9_DIR" CLAUDE_SESSION_ID="tc9" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC9_STATE=$(grep -oE 'state=[A-Z]+' "$TC9_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC9_MATCH=$(grep -oE 'match=[01]' "$TC9_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
assert "TC09: state=RED (unknown Z doesn't match Phase 4 IN PROGRESS)" "$([ "$TC9_STATE" = "RED" ] && echo 1 || echo 0)"
assert "TC09: match=0 (Z has no mapping; anomaly correctly signalled)" "$([ "$TC9_MATCH" = "0" ] && echo 1 || echo 0)"
rm -rf "$TC9_DIR" 2>/dev/null || true

# === TC10: numeric phase 4 still works (regression — D4 must not break numeric path) ===
echo "=== TC10: numeric phase 4 still works (regression test for D4 fix) ==="
TC10_DIR=$(new_tempdir)
write_ce "$TC10_DIR/agent-workspace/memory/current-execution.md" "S174" "4"
write_proj_with_row "$TC10_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
TC10_CACHE="$TC10_DIR/agent-workspace/memory/.phase-coherence-cache-tc10"
CLAUDE_PROJECT_DIR="$TC10_DIR" CLAUDE_SESSION_ID="tc10" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC10_STATE=$(grep -oE 'state=[A-Z]+' "$TC10_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC10_MATCH=$(grep -oE 'match=[01]' "$TC10_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
assert "TC10: state=GREEN (numeric phase 4 still works post-D4)" "$([ "$TC10_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC10: match=1 (numeric 4 pass-through correct)" "$([ "$TC10_MATCH" = "1" ] && echo 1 || echo 0)"
rm -rf "$TC10_DIR" 2>/dev/null || true

# === TC11: S343-S344 format header (multi-session id) with "Phase 4" ===
# Regression: the S343-S344 compound header (S[0-9]+-S[0-9]+) matches phase-status-coherence
# grep only if the regex allows hyphen-numeric suffix. The hook grep at line 76 uses S[0-9]+[a-z]?
# which does NOT match S343-S344 (fails on -S344 suffix). Verifies hook picks up next header.
echo "=== TC11: S343-S344 compound header falls through to next header — regression ==="
TC11_DIR=$(new_tempdir)
cat > "$TC11_DIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution — Test fixture

## S343-S344 — Phase 4 — Wave 1 Phase D NDH adapter PLAN+IMPL DONE — 2026-05-16

Main row body.

## S343 — Phase D NDH adapter PLAN dispatched — 2026-05-16 [SUPERSEDED]

Secondary row body.

---
EOF
write_proj_with_row "$TC11_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
TC11_CACHE="$TC11_DIR/agent-workspace/memory/.phase-coherence-cache-tc11"
CLAUDE_PROJECT_DIR="$TC11_DIR" CLAUDE_SESSION_ID="tc11" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || true
TC11_STATE=$(grep -oE 'state=[A-Z]+' "$TC11_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC11_MATCH=$(grep -oE 'match=[01]' "$TC11_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
# With D4 fix: Phase D resolves to 4 → match=1 → GREEN.
# Without D4 fix: Phase D couldn't match → RED. This TC is the regression sentinel.
assert "TC11: state=GREEN (D4 fix: Phase D in SUPERSEDED header resolves via mapping)" "$([ "$TC11_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC11: match=1 (Phase D → 4 via D4 mapping; Wave 1 S343 superseded row)" "$([ "$TC11_MATCH" = "1" ] && echo 1 || echo 0)"
rm -rf "$TC11_DIR" 2>/dev/null || true

# === TC12: all Wave 1 letters A,B,C,E also map to 4 ===
echo "=== TC12: all Wave 1 letters A B C E map to 4 (spot-check) ==="
TC12_PASS=0
TC12_FAIL=0
for letter in A B C E; do
  TC12_DIR=$(new_tempdir)
  cat > "$TC12_DIR/agent-workspace/memory/current-execution.md" <<EOF
# Current Execution — Test fixture

## S200 — Phase ${letter} — Wave 1 sub-phase — 2026-06-01

Body.

---
EOF
  write_proj_with_row "$TC12_DIR/agent-workspace/memory/project.md" "4" "IN PROGRESS"
  TC12_CACHE="$TC12_DIR/agent-workspace/memory/.phase-coherence-cache-tc12${letter}"
  CLAUDE_PROJECT_DIR="$TC12_DIR" CLAUDE_SESSION_ID="tc12${letter}" CLAUDE_HOOK_EVENT="UserPromptSubmit" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
  st=$(grep -oE 'state=[A-Z]+' "$TC12_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
  mt=$(grep -oE 'match=[01]' "$TC12_CACHE" 2>/dev/null | head -1 | sed 's/match=//')
  if [ "$st" = "GREEN" ] && [ "$mt" = "1" ]; then
    TC12_PASS=$((TC12_PASS + 1))
  else
    TC12_FAIL=$((TC12_FAIL + 1))
  fi
  rm -rf "$TC12_DIR" 2>/dev/null || true
done
assert "TC12: all 4 Wave 1 letters (A,B,C,E) map GREEN match=1" "$([ "$TC12_FAIL" -eq 0 ] && echo 1 || echo 0)"
TOTAL=$((TOTAL + 3))  # TC07/08/09/10/11 already counted above; TC12 is single assert above

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
