#!/usr/bin/env bash
# Firing-test for project-md-adr-staleness.sh (renamed S177 from project-md-staleness-check-fire-test.sh per D-038).
#
# Hook purpose: detect drift between project.md mtime and newest ADR mtime.
# Tolerates ≤2h drift; WARNs at >2h. Single-purpose post-D-038 Option E (Check A retired).
#
# Per L-S176-1 (NEW S176): firing-test fixtures MUST use REAL-STATE-DERIVED naming
# convention. Predecessor used `D-NNN-*.md` synthesized fixtures which matched the
# (broken) `-name 'D-*.md'` glob — passed against fiction, not production. This
# firing-test uses `NNN-*.md` primary fixtures (matches actual decisions/ naming) +
# `D-*.md` backward-compat fixture in dedicated TC.
#
# 6 test cases (5 substantive + L-S108-1 regression):
#   TC1 — files missing → silent (graceful bail)
#   TC2 — GREEN: project.md mtime ≥ newest ADR mtime → no WARN, log GREEN
#   TC3 — GREEN-tolerance: delta_hours = 1.0h (within 2h tolerance) → no WARN
#   TC4 — WARN: delta_hours = 5h (>2h tolerance) with NNN-*.md ADR → WARN log + cache state=WARN
#   TC5 — backward-compat: D-NNN-*.md ADR fixture (legacy naming) detected
#   TC6 — cache-hit on 2nd invocation
#   TC7 — L-S108-1 REGRESSION: stale cross-bucket + legacy 'default' marker → cleaned
#
# Per L-S174-1: use `RC=0; cmd || RC=$?` pattern when checking deliberate non-zero rc.
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../project-md-adr-staleness.sh"
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
  d=$(mktemp -d -t adr-staleness-test-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/adr-staleness-$$-${RANDOM}")
  mkdir -p "$d/agent-workspace/memory/decisions" 2>/dev/null
  echo "$d"
}

run_hook() {
  local dir="$1" sid="$2"
  local rc=0
  CLAUDE_PROJECT_DIR="$dir" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || rc=$?
  return $rc
}

# === TC1: files missing → silent (graceful bail) ===
echo "=== TC1: missing files ==="
TC1_DIR=$(new_tempdir)
rm -rf "$TC1_DIR/agent-workspace/memory/decisions"  # remove decisions dir
TC1_RC=0
run_hook "$TC1_DIR" "tc1" || TC1_RC=$?
TC1_LOG="$TC1_DIR/agent-workspace/memory/.session-hooks.log"
TC1_FIRED=0
[ -f "$TC1_LOG" ] && grep -q "tc1" "$TC1_LOG" 2>/dev/null && TC1_FIRED=1
assert "TC1: hook exits 0 with missing decisions dir" "$([ "$TC1_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC1: no WARN logged (silent bail)" "$([ "$TC1_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC1_DIR" 2>/dev/null || true

# === TC2: GREEN — project.md fresher than newest ADR ===
echo "=== TC2: GREEN (project.md fresher than newest ADR) ==="
TC2_DIR=$(new_tempdir)
echo "# Project" > "$TC2_DIR/agent-workspace/memory/project.md"
echo "# 037" > "$TC2_DIR/agent-workspace/memory/decisions/037-real-format.md"
# Make ADR 1h old, project.md fresh (now)
touch -d "1 hour ago" "$TC2_DIR/agent-workspace/memory/decisions/037-real-format.md" 2>/dev/null || \
  touch -t "$(date -d '1 hour ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC2_DIR/agent-workspace/memory/decisions/037-real-format.md" 2>/dev/null || true
TC2_RC=0
run_hook "$TC2_DIR" "tc2" || TC2_RC=$?
TC2_CACHE="$TC2_DIR/agent-workspace/memory/.adr-staleness-cache-tc2"
TC2_STATE=$(grep -oE 'state=[A-Z-]+' "$TC2_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC2_WARN_LOG="$TC2_DIR/agent-workspace/memory/.adr-staleness.log"
TC2_WARN_FIRED=0
[ -f "$TC2_WARN_LOG" ] && [ -s "$TC2_WARN_LOG" ] && TC2_WARN_FIRED=1
assert "TC2: hook exits 0" "$([ "$TC2_RC" -eq 0 ] && echo 1 || echo 0)"
assert "TC2: cache state=GREEN" "$([ "$TC2_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC2: no WARN drift-log entry" "$([ "$TC2_WARN_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC2_DIR" 2>/dev/null || true

# === TC3: GREEN-tolerance — 1h delta within 2h tolerance ===
echo "=== TC3: GREEN-tolerance (1h delta < 2h) ==="
TC3_DIR=$(new_tempdir)
echo "# Project" > "$TC3_DIR/agent-workspace/memory/project.md"
echo "# 038" > "$TC3_DIR/agent-workspace/memory/decisions/038-tolerance.md"
# Make project.md 1h old; ADR fresh → delta = 1h < 2h tolerance
touch -d "1 hour ago" "$TC3_DIR/agent-workspace/memory/project.md" 2>/dev/null || \
  touch -t "$(date -d '1 hour ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC3_DIR/agent-workspace/memory/project.md" 2>/dev/null || true
TC3_RC=0
run_hook "$TC3_DIR" "tc3" || TC3_RC=$?
TC3_CACHE="$TC3_DIR/agent-workspace/memory/.adr-staleness-cache-tc3"
TC3_STATE=$(grep -oE 'state=[A-Z-]+' "$TC3_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC3_WARN_LOG="$TC3_DIR/agent-workspace/memory/.adr-staleness.log"
TC3_WARN_FIRED=0
[ -f "$TC3_WARN_LOG" ] && [ -s "$TC3_WARN_LOG" ] && TC3_WARN_FIRED=1
assert "TC3: cache state=GREEN (within tolerance)" "$([ "$TC3_STATE" = "GREEN" ] && echo 1 || echo 0)"
assert "TC3: no WARN drift-log entry" "$([ "$TC3_WARN_FIRED" -eq 0 ] && echo 1 || echo 0)"
rm -rf "$TC3_DIR" 2>/dev/null || true

# === TC4: WARN — 5h delta over 2h tolerance with NNN-*.md ADR (REAL-STATE-DERIVED) ===
echo "=== TC4: WARN (5h delta > 2h tolerance; NNN-*.md naming per L-S176-1) ==="
TC4_DIR=$(new_tempdir)
echo "# Project" > "$TC4_DIR/agent-workspace/memory/project.md"
echo "# 039" > "$TC4_DIR/agent-workspace/memory/decisions/039-real-naming.md"
touch -d "5 hours ago" "$TC4_DIR/agent-workspace/memory/project.md" 2>/dev/null || \
  touch -t "$(date -d '5 hours ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC4_DIR/agent-workspace/memory/project.md" 2>/dev/null || true
TC4_RC=0
run_hook "$TC4_DIR" "tc4" || TC4_RC=$?
TC4_CACHE="$TC4_DIR/agent-workspace/memory/.adr-staleness-cache-tc4"
TC4_STATE=$(grep -oE 'state=[A-Z-]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC4_WARN_COUNT=$(grep -oE 'warn_count=[0-9]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/warn_count=//')
TC4_NEWEST=$(grep -oE 'newest_adr=[^[:space:]]+' "$TC4_CACHE" 2>/dev/null | head -1 | sed 's/newest_adr=//')
TC4_WARN_LOG="$TC4_DIR/agent-workspace/memory/.adr-staleness.log"
TC4_WARN_FIRED=0
[ -f "$TC4_WARN_LOG" ] && grep -q "tc4" "$TC4_WARN_LOG" 2>/dev/null && TC4_WARN_FIRED=1
assert "TC4: cache state=WARN" "$([ "$TC4_STATE" = "WARN" ] && echo 1 || echo 0)"
assert "TC4: warn_count=1" "$([ "$TC4_WARN_COUNT" = "1" ] && echo 1 || echo 0)"
assert "TC4: newest_adr=039-real-naming.md (NNN-*.md fixture)" "$([ "$TC4_NEWEST" = "039-real-naming.md" ] && echo 1 || echo 0)"
assert "TC4: WARN drift-log entry written" "$([ "$TC4_WARN_FIRED" -eq 1 ] && echo 1 || echo 0)"
rm -rf "$TC4_DIR" 2>/dev/null || true

# === TC5: backward-compat — D-NNN-*.md ADR (legacy naming) detected ===
echo "=== TC5: backward-compat (D-NNN-*.md fixture) ==="
TC5_DIR=$(new_tempdir)
echo "# Project" > "$TC5_DIR/agent-workspace/memory/project.md"
echo "# D-040" > "$TC5_DIR/agent-workspace/memory/decisions/D-040-legacy-naming.md"
touch -d "5 hours ago" "$TC5_DIR/agent-workspace/memory/project.md" 2>/dev/null || \
  touch -t "$(date -d '5 hours ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC5_DIR/agent-workspace/memory/project.md" 2>/dev/null || true
TC5_RC=0
run_hook "$TC5_DIR" "tc5" || TC5_RC=$?
TC5_CACHE="$TC5_DIR/agent-workspace/memory/.adr-staleness-cache-tc5"
TC5_STATE=$(grep -oE 'state=[A-Z-]+' "$TC5_CACHE" 2>/dev/null | head -1 | sed 's/state=//')
TC5_NEWEST=$(grep -oE 'newest_adr=[^[:space:]]+' "$TC5_CACHE" 2>/dev/null | head -1 | sed 's/newest_adr=//')
assert "TC5: cache state=WARN" "$([ "$TC5_STATE" = "WARN" ] && echo 1 || echo 0)"
assert "TC5: newest_adr=D-040-legacy-naming.md (D-*.md fallback)" "$([ "$TC5_NEWEST" = "D-040-legacy-naming.md" ] && echo 1 || echo 0)"
rm -rf "$TC5_DIR" 2>/dev/null || true

# === TC6: cache-hit on 2nd invocation ===
echo "=== TC6: cache-hit on 2nd invocation ==="
TC6_DIR=$(new_tempdir)
echo "# Project" > "$TC6_DIR/agent-workspace/memory/project.md"
echo "# 041" > "$TC6_DIR/agent-workspace/memory/decisions/041-cache-test.md"
TC6_LOG="$TC6_DIR/agent-workspace/memory/.session-hooks.log"
run_hook "$TC6_DIR" "tc6"
run_hook "$TC6_DIR" "tc6"
TC6_HITS=$(grep -c "CACHE-HIT" "$TC6_LOG" 2>/dev/null || echo 0)
[[ "$TC6_HITS" =~ ^[0-9]+$ ]] || TC6_HITS=0
assert "TC6: CACHE-HIT logged on 2nd invocation" "$([ "$TC6_HITS" -ge 1 ] && echo 1 || echo 0)"
rm -rf "$TC6_DIR" 2>/dev/null || true

# === TC7: L-S108-1 REGRESSION — stale + legacy markers cleaned, hook fires ===
echo "=== TC7: L-S108-1 REGRESSION (stale + legacy markers cleaned) ==="
TC7_DIR=$(new_tempdir)
echo "# Project" > "$TC7_DIR/agent-workspace/memory/project.md"
echo "# 042" > "$TC7_DIR/agent-workspace/memory/decisions/042-regression.md"
touch -d "5 hours ago" "$TC7_DIR/agent-workspace/memory/project.md" 2>/dev/null || \
  touch -t "$(date -d '5 hours ago' +%Y%m%d%H%M 2>/dev/null || echo '202604300000')" \
    "$TC7_DIR/agent-workspace/memory/project.md" 2>/dev/null || true
# Plant stale Jan-2026 hour-bucket marker (different bucket from current)
touch "$TC7_DIR/agent-workspace/memory/.adr-staleness-fired-20260105-13"
# Plant legacy predecessor marker (project-md-staleness-fired-* per pre-rename hook)
touch "$TC7_DIR/agent-workspace/memory/.project-md-staleness-fired-20260105-13"
touch "$TC7_DIR/agent-workspace/memory/.project-md-staleness-fired-default"
TC7_RC=0
run_hook "$TC7_DIR" "tc7" || TC7_RC=$?
TC7_CURRENT_BUCKET="$TC7_DIR/agent-workspace/memory/.adr-staleness-fired-$(date +%Y%m%d-%H)"
TC7_STALE_NEW=$([ -f "$TC7_DIR/agent-workspace/memory/.adr-staleness-fired-20260105-13" ] && echo 0 || echo 1)
TC7_STALE_LEGACY1=$([ -f "$TC7_DIR/agent-workspace/memory/.project-md-staleness-fired-20260105-13" ] && echo 0 || echo 1)
TC7_STALE_LEGACY2=$([ -f "$TC7_DIR/agent-workspace/memory/.project-md-staleness-fired-default" ] && echo 0 || echo 1)
TC7_CURRENT_EXISTS=$([ -f "$TC7_CURRENT_BUCKET" ] && echo 1 || echo 0)
assert "TC7: stale .adr-staleness-fired-20260105-13 cleaned" "$TC7_STALE_NEW"
assert "TC7: legacy .project-md-staleness-fired-20260105-13 cleaned" "$TC7_STALE_LEGACY1"
assert "TC7: legacy .project-md-staleness-fired-default cleaned" "$TC7_STALE_LEGACY2"
assert "TC7: current-bucket marker exists post-fire" "$TC7_CURRENT_EXISTS"
rm -rf "$TC7_DIR" 2>/dev/null || true

# === Summary ===
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ALL firing-tests passed (project-md-adr-staleness post-D-038 + L-S108-1 regression)."
  echo "  Per L-S176-1: TC4/TC5 use REAL-STATE-DERIVED fixtures (NNN-*.md primary + D-*.md backward-compat)."
  exit 0
else
  echo "  $FAIL firing-test(s) failed."
  exit 1
fi
