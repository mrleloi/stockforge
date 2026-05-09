#!/usr/bin/env bash
# attach-portability-smoke-fire-test.sh — verifies HH-G.3 smoke runner detects
# real RED states + emits state=GREEN under valid manifest.
# Companion to scripts/hooks/attach-portability-smoke.sh (Phase 2.5 HH-G.3 closed S174 per Q4=A).
# Phase 3.5 Hard Rule #2: every hook MUST ship with companion firing-test.
#
# Strategy: synthesize a minimal fixture project tree with deliberate manifest
# violations + assert smoke detects them; then valid fixture + assert GREEN.
set -uo pipefail
trap 'cleanup; exit $RC' ERR EXIT

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SMOKE="$PROJECT_DIR/scripts/hooks/attach-portability-smoke.sh"
TMP_DIR="$(mktemp -d -t attach-smoke-test-XXXXXX 2>/dev/null || mktemp -d 2>/dev/null || echo "/tmp/attach-smoke-test-$$")"
mkdir -p "$TMP_DIR"

PASS=0
FAIL=0
TOTAL=0
RC=0

cleanup() {
  [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR" 2>/dev/null || true
}

assert() {
  local desc="$1" cond="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$cond" = "1" ] || [ "$cond" = "true" ]; then
    PASS=$((PASS + 1))
    printf '  [PASS] %s\n' "$desc"
  else
    FAIL=$((FAIL + 1))
    RC=1
    printf '  [FAIL] %s\n' "$desc"
  fi
}

# ============================================================================
# Pre-flight
# ============================================================================
echo "=== Pre-flight ==="
if [ ! -f "$SMOKE" ]; then
  echo "  [FATAL] smoke script not found: $SMOKE"
  exit 2
fi
[ -x "$SMOKE" ] || chmod +x "$SMOKE"
assert "smoke script exists + executable" "$([ -x "$SMOKE" ] && echo 1 || echo 0)"

# Run smoke against real project (production smoke — should be GREEN since all artifacts present)
echo ""
echo "=== Test 1: smoke against real project (production GREEN expected) ==="
SMOKE_OUT="$(bash "$SMOKE" 2>&1 || true)"
SMOKE_RC=$?
if echo "$SMOKE_OUT" | grep -q "state=GREEN"; then
  assert "real-project smoke emits state=GREEN" "1"
else
  STATE_FOUND=$(echo "$SMOKE_OUT" | grep -oE 'state=[A-Z-]+' | tail -1)
  echo "    (debug) state observed: ${STATE_FOUND:-NONE}"
  assert "real-project smoke emits state=GREEN (got: ${STATE_FOUND:-NONE})" "0"
fi

# ============================================================================
# Test 2: synthesized fixture with deliberate VIOLATION (HH-G.1 template missing)
# ============================================================================
echo ""
echo "=== Test 2: synthesized fixture — HH-G.1 template missing (should FAIL) ==="
FIX_DIR="$TMP_DIR/fixture-no-template"
mkdir -p "$FIX_DIR/.claude"
mkdir -p "$FIX_DIR/scripts/hooks"
# Copy real manifest (so layer assertions A1-B3 still pass)
cp "$PROJECT_DIR/.claude/manifest.yaml" "$FIX_DIR/.claude/manifest.yaml"
# Copy real settings.json (so STOCKFORGE_ env grep works)
[ -f "$PROJECT_DIR/.claude/settings.json" ] && cp "$PROJECT_DIR/.claude/settings.json" "$FIX_DIR/.claude/settings.json"
# Copy smoke script itself so PROJECT_DIR can self-resolve to fixture
cp "$SMOKE" "$FIX_DIR/scripts/hooks/attach-portability-smoke.sh"
chmod +x "$FIX_DIR/scripts/hooks/attach-portability-smoke.sh"
# Deliberately do NOT create templates/general-harness/CLAUDE.md
# Skip Check 2 STRUCTURAL paths absence (the fixture has no scripts/ etc.) by
# checking specifically that HH-G.1 template-existence assertion FAILs
FIX_OUT="$(CLAUDE_PROJECT_DIR="$FIX_DIR" bash "$FIX_DIR/scripts/hooks/attach-portability-smoke.sh" 2>&1 || true)"
if echo "$FIX_OUT" | grep -q "\[FAIL\] HH-G.1: templates/general-harness/CLAUDE.md exists"; then
  assert "fixture-no-template: smoke detects missing template" "1"
else
  echo "    (debug) HH-G.1 line:"
  echo "$FIX_OUT" | grep "HH-G.1" | head -3
  assert "fixture-no-template: smoke detects missing template" "0"
fi

# ============================================================================
# Test 3: synthesized fixture — manifest layer leak (stockforge skill in default_includes)
# ============================================================================
echo ""
echo "=== Test 3: synthesized fixture — manifest layer leak (stockforge in includes) ==="
FIX_DIR2="$TMP_DIR/fixture-leak"
mkdir -p "$FIX_DIR2/.claude"
mkdir -p "$FIX_DIR2/scripts/hooks"
mkdir -p "$FIX_DIR2/templates/general-harness"
cp "$PROJECT_DIR/templates/general-harness/CLAUDE.md" "$FIX_DIR2/templates/general-harness/CLAUDE.md"
cp "$SMOKE" "$FIX_DIR2/scripts/hooks/attach-portability-smoke.sh"
chmod +x "$FIX_DIR2/scripts/hooks/attach-portability-smoke.sh"
[ -f "$PROJECT_DIR/.claude/settings.json" ] && cp "$PROJECT_DIR/.claude/settings.json" "$FIX_DIR2/.claude/settings.json"

# Mutate manifest: add invariants-stockforge.md to default_includes (should make A3 FAIL)
PYTHONIOENCODING=utf-8 python -c "
import yaml
src = r'$(echo "$PROJECT_DIR/.claude/manifest.yaml" | sed 's|/c/|C:/|; s|/d/|D:/|')'
dst = r'$(echo "$FIX_DIR2/.claude/manifest.yaml" | sed 's|/c/|C:/|; s|/d/|D:/|; s|/tmp/|/tmp/|')'
import os
# Convert /tmp paths properly for Windows
if not os.path.isabs(src):
    src = os.path.abspath(src)
m = yaml.safe_load(open(src))
m.setdefault('attach', {}).setdefault('default_includes', []).append('agent-workspace/constitution/invariants-stockforge.md')
with open(dst, 'w') as f:
    yaml.safe_dump(m, f, sort_keys=False)
" 2>/dev/null || {
  # Fallback: simpler shell-based mutation
  cp "$PROJECT_DIR/.claude/manifest.yaml" "$FIX_DIR2/.claude/manifest.yaml"
  # Append a leak line under default_includes
  awk '
    /^  default_includes:/ {print; print "    - agent-workspace/constitution/invariants-stockforge.md"; next}
    {print}
  ' "$PROJECT_DIR/.claude/manifest.yaml" > "$FIX_DIR2/.claude/manifest.yaml"
}

LEAK_OUT="$(CLAUDE_PROJECT_DIR="$FIX_DIR2" bash "$FIX_DIR2/scripts/hooks/attach-portability-smoke.sh" 2>&1 || true)"
if echo "$LEAK_OUT" | grep -q "\[FAIL\] A3:"; then
  assert "fixture-leak: smoke detects invariants-stockforge.md in includes (A3 FAIL)" "1"
else
  echo "    (debug) A3 line:"
  echo "$LEAK_OUT" | grep "A3:" | head -2
  assert "fixture-leak: smoke detects invariants-stockforge.md in includes (A3 FAIL)" "0"
fi

# ============================================================================
# Test 4: smoke uses ATTACH_SMOKE_TARGET env override
# ============================================================================
echo ""
echo "=== Test 4: ATTACH_SMOKE_TARGET env override honored ==="
CUSTOM_TGT="$TMP_DIR/custom-target"
mkdir -p "$CUSTOM_TGT"
ENV_OUT="$(ATTACH_SMOKE_TARGET="$CUSTOM_TGT" bash "$SMOKE" 2>&1 || true)"
if echo "$ENV_OUT" | grep -q "scratch target: $CUSTOM_TGT"; then
  assert "ATTACH_SMOKE_TARGET env var honored" "1"
else
  echo "    (debug) scratch line:"
  echo "$ENV_OUT" | grep "scratch target:" | head -2
  assert "ATTACH_SMOKE_TARGET env var honored" "0"
fi

# ============================================================================
# Test 5: exit code semantics
# ============================================================================
echo ""
echo "=== Test 5: exit code semantics (RC=0 GREEN; RC=1 RED) ==="
# Real project should exit 0
REAL_RC=0
bash "$SMOKE" >/dev/null 2>&1 || REAL_RC=$?
if [ "$REAL_RC" -eq 0 ]; then
  assert "real-project exit code = 0 (GREEN)" "1"
else
  assert "real-project exit code = $REAL_RC (expected 0)" "0"
fi
# fixture-leak should exit 1
LEAK_RC=0
CLAUDE_PROJECT_DIR="$FIX_DIR2" bash "$FIX_DIR2/scripts/hooks/attach-portability-smoke.sh" >/dev/null 2>&1 || LEAK_RC=$?
if [ "$LEAK_RC" -eq 1 ]; then
  assert "fixture-leak exit code = 1 (RED)" "1"
else
  assert "fixture-leak exit code = $LEAK_RC (expected 1)" "0"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=== Summary ==="
echo "  PASS: $PASS / $TOTAL"
echo "  FAIL: $FAIL / $TOTAL"
if [ "$FAIL" -eq 0 ]; then
  echo "  All firing-tests passed."
else
  echo "  $FAIL firing-test(s) failed."
fi
exit $RC
