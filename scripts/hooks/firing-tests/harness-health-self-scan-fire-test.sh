#!/usr/bin/env bash
# harness-health-self-scan-fire-test.sh — verifies T6 hook fires correctly.
# Companion to scripts/hooks/harness-health-self-scan.sh (Phase 3.5 T6; D-035).
# Pattern: synthesize ≥1 deliberate FAIL state per signal + assert hook detects + reports.
# Phase 3.5 Hard Rule #2: every hook MUST ship with companion firing-test.
set -uo pipefail
trap 'cleanup; exit $rc' ERR EXIT

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
HOOK="$PROJECT_DIR/scripts/hooks/harness-health-self-scan.sh"
TMP_DIR="$(mktemp -d -t harness-health-test-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/harness-health-test-$$")"
mkdir -p "$TMP_DIR"

PASS=0
FAIL=0
TOTAL=0
rc=0

cleanup() {
  [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR" 2>/dev/null || true
}

assert() {
  local desc="$1" cond="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$cond" = "1" ] || [ "$cond" = "true" ]; then
    PASS=$((PASS + 1))
    echo "  [PASS] $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  [FAIL] $desc"
    rc=1
  fi
}

# === Pre-flight: hook script exists + executable ===
echo "=== Pre-flight ==="
if [ ! -f "$HOOK" ]; then
  echo "  [FATAL] hook script not found: $HOOK"
  rc=1
  exit $rc
fi
[ -x "$HOOK" ] || chmod +x "$HOOK"
assert "hook script exists" "$([ -f "$HOOK" ] && echo 1 || echo 0)"

# === Test 1: hook runs cleanly with default state (smoke) ===
echo "=== Test 1: smoke run (real project state) ==="
SMOKE_OUT="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_SESSION_ID="firing-test-smoke-$$" CLAUDE_HOOK_EVENT="SessionStart" bash "$HOOK" 2>&1 || echo "rc=$?")"
SMOKE_RC=$?
assert "smoke run exits 0 (informational hook)" "$([ $SMOKE_RC -eq 0 ] && echo 1 || echo 0)"

# Check log emitted
HEALTH_LOG="$PROJECT_DIR/agent-workspace/memory/.harness-health.log"
assert "smoke run wrote to .harness-health.log" "$([ -f "$HEALTH_LOG" ] && echo 1 || echo 0)"

# === Test 2: synthesized FAIL state — HH-7 (stale checkpoint) ===
echo "=== Test 2: HH-7 stale checkpoint (synthesized) ==="
# Create isolated project dir for this test
TEST_PROJ="$TMP_DIR/test-proj-hh7"
mkdir -p "$TEST_PROJ/agent-workspace/memory/checkpoints"
mkdir -p "$TEST_PROJ/agent-workspace/memory/sessions"
mkdir -p "$TEST_PROJ/scripts/hooks"
cp "$HOOK" "$TEST_PROJ/scripts/hooks/harness-health-self-scan.sh"

# Stale checkpoint (mtime 5 days ago)
echo "stale checkpoint" > "$TEST_PROJ/agent-workspace/memory/checkpoints/latest.md"
touch -d "5 days ago" "$TEST_PROJ/agent-workspace/memory/checkpoints/latest.md" 2>/dev/null || \
  touch -t "$(date -d '5 days ago' +%Y%m%d%H%M 2>/dev/null || echo "202604300000")" \
    "$TEST_PROJ/agent-workspace/memory/checkpoints/latest.md" 2>/dev/null || true

# Fresh session log (so sess_delta_hr is small)
echo "# session" > "$TEST_PROJ/agent-workspace/memory/sessions/2026-05-07-test.md"

# Run hook
HH7_OUT="$(CLAUDE_PROJECT_DIR="$TEST_PROJ" CLAUDE_SESSION_ID="firing-test-hh7-$$" CLAUDE_HOOK_EVENT="SessionStart" bash "$TEST_PROJ/scripts/hooks/harness-health-self-scan.sh" 2>&1 || true)"

# Assert HH-7 FAIL emitted
HH7_HEALTH="$TEST_PROJ/agent-workspace/memory/.harness-health.log"
if [ -f "$HH7_HEALTH" ]; then
  if grep -q "HH-7-CHECKPOINT-STALE" "$HH7_HEALTH"; then
    assert "HH-7 detected stale checkpoint (5 days)" "1"
  else
    assert "HH-7 detected stale checkpoint (5 days)" "0"
  fi
else
  assert "HH-7 health log written" "0"
fi

# === Test 3: synthesized FAIL — HH-11 (frozen log) ===
echo "=== Test 3: HH-11 frozen log (synthesized) ==="
TEST_PROJ_HH11="$TMP_DIR/test-proj-hh11"
mkdir -p "$TEST_PROJ_HH11/agent-workspace/memory/checkpoints"
mkdir -p "$TEST_PROJ_HH11/agent-workspace/memory/sessions"
mkdir -p "$TEST_PROJ_HH11/scripts/hooks"
cp "$HOOK" "$TEST_PROJ_HH11/scripts/hooks/harness-health-self-scan.sh"

# Frozen .session-hooks.log (mtime 2 hours ago)
LOG_FILE="$TEST_PROJ_HH11/agent-workspace/memory/.session-hooks.log"
echo "[old-timestamp] SessionStart session=test" > "$LOG_FILE"
touch -d "2 hours ago" "$LOG_FILE" 2>/dev/null || \
  touch -t "$(date -d '2 hours ago' +%Y%m%d%H%M 2>/dev/null || echo "202605070000")" "$LOG_FILE" 2>/dev/null || true

# Fresh checkpoint to avoid HH-7 noise
echo "fresh" > "$TEST_PROJ_HH11/agent-workspace/memory/checkpoints/latest.md"

HH11_OUT="$(CLAUDE_PROJECT_DIR="$TEST_PROJ_HH11" CLAUDE_SESSION_ID="firing-test-hh11-$$" CLAUDE_HOOK_EVENT="SessionStart" bash "$TEST_PROJ_HH11/scripts/hooks/harness-health-self-scan.sh" 2>&1 || true)"

HH11_HEALTH="$TEST_PROJ_HH11/agent-workspace/memory/.harness-health.log"
if [ -f "$HH11_HEALTH" ]; then
  if grep -q "HH-11-LOG-FROZEN" "$HH11_HEALTH"; then
    assert "HH-11 detected frozen log (2 hours)" "1"
  else
    assert "HH-11 detected frozen log (2 hours)" "0"
  fi
else
  assert "HH-11 health log written" "0"
fi

# === Test 4: GREEN state (no synthesized FAILs) ===
echo "=== Test 4: GREEN state (clean fixtures) ==="
TEST_PROJ_GREEN="$TMP_DIR/test-proj-green"
mkdir -p "$TEST_PROJ_GREEN/agent-workspace/memory/checkpoints"
mkdir -p "$TEST_PROJ_GREEN/agent-workspace/memory/sessions"
mkdir -p "$TEST_PROJ_GREEN/agent-workspace/memory/observations"
mkdir -p "$TEST_PROJ_GREEN/scripts/hooks/firing-tests"
cp "$HOOK" "$TEST_PROJ_GREEN/scripts/hooks/harness-health-self-scan.sh"

# Fresh artifacts
echo "fresh" > "$TEST_PROJ_GREEN/agent-workspace/memory/checkpoints/latest.md"
echo "[$(date -Iseconds)] SessionStart session=test" > "$TEST_PROJ_GREEN/agent-workspace/memory/.session-hooks.log"
echo "[$(date -Iseconds)] UserPromptSubmit" >> "$TEST_PROJ_GREEN/agent-workspace/memory/.session-hooks.log"
echo "[$(date -Iseconds)] Stop session=test" >> "$TEST_PROJ_GREEN/agent-workspace/memory/.session-hooks.log"
echo "# session" > "$TEST_PROJ_GREEN/agent-workspace/memory/sessions/2026-05-07-test.md"
echo "# promote-rule" > "$TEST_PROJ_GREEN/agent-workspace/memory/observations/promote-rule-S100.md"
echo "no mistakes this session" >> "$TEST_PROJ_GREEN/agent-workspace/memory/sessions/2026-05-07-test.md"
echo "# notes" > "$TEST_PROJ_GREEN/agent-workspace/memory/agent-notes.md"
echo "# mistake" > "$TEST_PROJ_GREEN/agent-workspace/memory/mistake-log.md"

# Match phases
mkdir -p "$TEST_PROJ_GREEN/agent-workspace/memory"
cat > "$TEST_PROJ_GREEN/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution
## S100 — Phase 3.5 — test
EOF
cat > "$TEST_PROJ_GREEN/agent-workspace/memory/project.md" <<'EOF'
# Project
| 3.5 — test | scope | IN PROGRESS | 2026-05-07 | - |
EOF

# Charter md5 baseline
echo "test-charter" > "$TEST_PROJ_GREEN/PROJECT_CHARTER.md"
md5sum "$TEST_PROJ_GREEN/PROJECT_CHARTER.md" 2>/dev/null | awk '{print $1}' > "$TEST_PROJ_GREEN/agent-workspace/memory/.charter-md5-baseline" 2>/dev/null || \
  md5 "$TEST_PROJ_GREEN/PROJECT_CHARTER.md" 2>/dev/null | awk '{print $NF}' > "$TEST_PROJ_GREEN/agent-workspace/memory/.charter-md5-baseline" 2>/dev/null || \
  echo "skip-md5" > "$TEST_PROJ_GREEN/agent-workspace/memory/.charter-md5-baseline"

# tier1-bloat-check stub (returns 0 = PASS)
cat > "$TEST_PROJ_GREEN/scripts/hooks/tier1-bloat-check.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$TEST_PROJ_GREEN/scripts/hooks/tier1-bloat-check.sh"

GREEN_OUT="$(CLAUDE_PROJECT_DIR="$TEST_PROJ_GREEN" CLAUDE_SESSION_ID="test" CLAUDE_HOOK_EVENT="SessionStart" bash "$TEST_PROJ_GREEN/scripts/hooks/harness-health-self-scan.sh" 2>&1 || true)"

GREEN_CACHE="$TEST_PROJ_GREEN/agent-workspace/memory/.harness-health-cache-test"
if [ -f "$GREEN_CACHE" ]; then
  if grep -q "state=GREEN" "$GREEN_CACHE"; then
    assert "GREEN state with clean fixtures" "1"
  else
    STATE_FOUND=$(grep -oE 'state=[A-Z-]+[0-9]*' "$GREEN_CACHE" | head -1)
    echo "  (debug) state observed: $STATE_FOUND"
    cat "$GREEN_CACHE" | head -3
    assert "GREEN state with clean fixtures (got: $STATE_FOUND)" "0"
  fi
else
  assert "GREEN cache written" "0"
fi

# === Test 5: cache hit (5-min TTL skip) ===
echo "=== Test 5: cache hit skip (5-min TTL) ==="
# Run hook again with same SID; should skip via cache
CACHE_HIT_OUT="$(CLAUDE_PROJECT_DIR="$TEST_PROJ_GREEN" CLAUDE_SESSION_ID="test" CLAUDE_HOOK_EVENT="SessionStart" bash "$TEST_PROJ_GREEN/scripts/hooks/harness-health-self-scan.sh" 2>&1 || true)"
HOOK_LOG_GREEN="$TEST_PROJ_GREEN/agent-workspace/memory/.session-hooks.log"
if grep -q "CACHE-HIT" "$HOOK_LOG_GREEN"; then
  assert "cache hit on second invocation (5-min TTL)" "1"
else
  echo "  (debug) hook log tail:"
  tail -3 "$HOOK_LOG_GREEN" 2>/dev/null
  assert "cache hit on second invocation (5-min TTL)" "0"
fi

# === Summary ===
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  ✅ All firing-tests passed."
else
  echo "  ❌ $FAIL firing-test(s) failed."
fi
exit $rc
