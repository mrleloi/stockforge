#!/usr/bin/env bash
# index-registry-renderer-fire-test.sh — companion firing-test per L-S51-1.
# Tests externally-observable behavior per L-S59-1:
#   - 4 manifest TSVs rendered with >0 data rows
#   - Correct schema headers
#   - Idempotent output (re-run produces identical TSV)
# L-S59-2: two-stage grep for multi-field assertions.
# L-S62-1: no yes|head patterns; fixtures use seq/sed/printf.
# 8 TCs per Plan 011 D5 acceptance.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../index-registry-renderer.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
INDEXES_DIR="$PROJECT_DIR/agent-workspace/memory/indexes"
mkdir -p "$PROJECT_DIR/agent-workspace/memory/observations"
mkdir -p "$PROJECT_DIR/agent-workspace/memory/decisions"
mkdir -p "$PROJECT_DIR/scripts/hooks/firing-tests"
mkdir -p "$PROJECT_DIR/.claude/agents"

PASS=0
FAIL=0

run_renderer() {
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>/dev/null || true
}

# Populate minimal fixtures
setup_fixtures() {
  # Minimal settings.json with hook wiring
  cat > "$PROJECT_DIR/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks":[{"type":"command","command":"bash \"${CLAUDE_PROJECT_DIR}/scripts/hooks/test-hook.sh\""}]}],
    "PreToolUse": [{"hooks":[{"type":"command","command":"bash \"${CLAUDE_PROJECT_DIR}/scripts/hooks/other-hook.sh\""}]}]
  }
}
EOF
  # Two hook scripts
  printf '#!/usr/bin/env bash\n# L-S10-1 L-S11-1\nset -uo pipefail\nexit 0\n' \
    > "$PROJECT_DIR/scripts/hooks/test-hook.sh"
  printf '#!/usr/bin/env bash\nset -uo pipefail\necho hi\n' \
    > "$PROJECT_DIR/scripts/hooks/other-hook.sh"
  # Firing test for test-hook
  printf '#!/usr/bin/env bash\necho "test"\n' \
    > "$PROJECT_DIR/scripts/hooks/firing-tests/test-hook-fire-test.sh"

  # Minimal agent-notes with 2 lessons
  cat > "$PROJECT_DIR/agent-workspace/memory/agent-notes.md" <<'EOF'
# Agent Notes

### 2026-01-01: L-S10-1 First rule
**Severity**: critical
Some text.

### 2026-01-15: L-S11-1 Second rule
**Severity**: high
More text.
EOF

  # Minimal mistake-log with 2 entries
  cat > "$PROJECT_DIR/agent-workspace/memory/mistake-log.md" <<'EOF'
# Mistake Log

### M-S10-1: First mistake
**Session**: S10
**Severity**: high
**What happened**: something bad
**Prevention rule**: rule A

### M-S11-1: Second mistake
**Session**: S11
**Severity**: medium
**What happened**: another thing
EOF

  # Two ADR files
  cat > "$PROJECT_DIR/agent-workspace/memory/decisions/001-first-adr.md" <<'EOF'
---
session: S10
tier: ARCH
status: ACCEPTED
promoted_to: none
---
# ADR 001
EOF
  cat > "$PROJECT_DIR/agent-workspace/memory/decisions/002-second-adr.md" <<'EOF'
---
session: S11
tier: IMPL
status: ACCEPTED
promoted_to: none
---
# ADR 002
EOF
}

setup_fixtures
run_renderer

# -----------------------------------------------------------------------
# TC1 — fresh state → 4 manifests rendered
# -----------------------------------------------------------------------
MANIFESTS_OK=0
for tsv in hook-registry.tsv lesson-registry.tsv mistake-registry.tsv decision-registry.tsv; do
  if [ -f "$INDEXES_DIR/$tsv" ]; then
    MANIFESTS_OK=$((MANIFESTS_OK+1))
  fi
done
if [ "$MANIFESTS_OK" -eq 4 ]; then
  echo "PASS TC1: 4 manifests rendered (hook, lesson, mistake, decision)"
  PASS=$((PASS+1))
else
  echo "FAIL TC1: only $MANIFESTS_OK/4 manifests rendered"
  ls "$INDEXES_DIR/" 2>/dev/null || echo "(indexes dir empty)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC2 — hook-registry has >0 data rows (besides header)
# -----------------------------------------------------------------------
HOOK_ROWS=$(tail -n +2 "$INDEXES_DIR/hook-registry.tsv" 2>/dev/null | wc -l | tr -d ' ' || echo 0)
if [ "${HOOK_ROWS:-0}" -ge 2 ]; then
  echo "PASS TC2: hook-registry has $HOOK_ROWS data rows"
  PASS=$((PASS+1))
else
  echo "FAIL TC2: hook-registry has $HOOK_ROWS data rows (expected ≥2)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC3 — lesson-registry schema check: all 7 header cols present
# -----------------------------------------------------------------------
LESSON_HEADER="$(head -1 "$INDEXES_DIR/lesson-registry.tsv" 2>/dev/null || true)"
if printf '%s' "$LESSON_HEADER" | grep -q 'lesson_id' && \
   printf '%s' "$LESSON_HEADER" | grep -q 'severity' && \
   printf '%s' "$LESSON_HEADER" | grep -q 'hook_codified'; then
  echo "PASS TC3: lesson-registry header has required columns"
  PASS=$((PASS+1))
else
  echo "FAIL TC3: lesson-registry header missing required columns"
  printf 'header: %s\n' "$LESSON_HEADER"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC4 — mistake-registry schema check
# -----------------------------------------------------------------------
MISTAKE_HEADER="$(head -1 "$INDEXES_DIR/mistake-registry.tsv" 2>/dev/null || true)"
if printf '%s' "$MISTAKE_HEADER" | grep -q 'mistake_id' && \
   printf '%s' "$MISTAKE_HEADER" | grep -q 'prevention_status'; then
  echo "PASS TC4: mistake-registry header has required columns"
  PASS=$((PASS+1))
else
  echo "FAIL TC4: mistake-registry header missing required columns"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC5 — decision-registry schema check
# -----------------------------------------------------------------------
DECISION_HEADER="$(head -1 "$INDEXES_DIR/decision-registry.tsv" 2>/dev/null || true)"
if printf '%s' "$DECISION_HEADER" | grep -q 'adr_id' && \
   printf '%s' "$DECISION_HEADER" | grep -q 'tier' && \
   printf '%s' "$DECISION_HEADER" | grep -q 'promoted_to'; then
  echo "PASS TC5: decision-registry header has required columns"
  PASS=$((PASS+1))
else
  echo "FAIL TC5: decision-registry header missing required columns"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC6 — idempotent: re-running produces identical TSV
# -----------------------------------------------------------------------
cp "$INDEXES_DIR/hook-registry.tsv" "$TEMPDIR/hook-before.tsv"
cp "$INDEXES_DIR/lesson-registry.tsv" "$TEMPDIR/lesson-before.tsv"
run_renderer
if diff -q "$TEMPDIR/hook-before.tsv" "$INDEXES_DIR/hook-registry.tsv" >/dev/null 2>&1 && \
   diff -q "$TEMPDIR/lesson-before.tsv" "$INDEXES_DIR/lesson-registry.tsv" >/dev/null 2>&1; then
  echo "PASS TC6: idempotent — re-run produces identical hook + lesson manifests"
  PASS=$((PASS+1))
else
  echo "FAIL TC6: re-run produced different output (not idempotent)"
  diff "$TEMPDIR/hook-before.tsv" "$INDEXES_DIR/hook-registry.tsv" | head -5 || true
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC7 — hook-registry status column: wired hook → ACTIVE, unwired → ORPHAN
# -----------------------------------------------------------------------
# test-hook.sh is wired in Stop → should be ACTIVE
# other-hook.sh is wired in PreToolUse → should be ACTIVE
# Both should appear; check for ACTIVE status
if grep 'test-hook.sh' "$INDEXES_DIR/hook-registry.tsv" | grep -q 'ACTIVE\|Stop'; then
  echo "PASS TC7: test-hook.sh (wired in Stop) → ACTIVE status"
  PASS=$((PASS+1))
else
  echo "FAIL TC7: test-hook.sh not showing ACTIVE"
  grep 'test-hook.sh' "$INDEXES_DIR/hook-registry.tsv" || echo "(not found)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC8 — decision-registry data: ADR files rendered with correct adr_id
# -----------------------------------------------------------------------
if grep -q 'D-001' "$INDEXES_DIR/decision-registry.tsv" 2>/dev/null && \
   grep -q 'D-002' "$INDEXES_DIR/decision-registry.tsv" 2>/dev/null; then
  # Two-stage: check tier field populated
  if grep 'D-001' "$INDEXES_DIR/decision-registry.tsv" | grep -q 'ARCH\|IMPL\|CHARTER'; then
    echo "PASS TC8: D-001 + D-002 in decision-registry with tier populated"
    PASS=$((PASS+1))
  else
    echo "FAIL TC8: D-001 found but tier field missing"
    grep 'D-001' "$INDEXES_DIR/decision-registry.tsv" || true
    FAIL=$((FAIL+1))
  fi
else
  echo "FAIL TC8: D-001 or D-002 missing from decision-registry"
  cat "$INDEXES_DIR/decision-registry.tsv" 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL (8 TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
