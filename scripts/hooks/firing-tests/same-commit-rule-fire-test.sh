#!/usr/bin/env bash
# same-commit-rule-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2 retro-fit
# REAL-STATE-DERIVED per L-S176-1: parent hook is a pre-commit gate enforcing spec ↔ code coupling.
# Real fixture mirrors stockforge layout: PROJECT_CHARTER.md, packages/, apps/, specs/.
# Decision 002 § Track 5 REV-2 § B; A-23 in borrow-list.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/same-commit-rule.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
mkdir -p "$PROJECT_DIR/packages" "$PROJECT_DIR/apps" "$PROJECT_DIR/specs" "$PROJECT_DIR/docs" "$PROJECT_DIR/agent-workspace/memory"
( cd "$PROJECT_DIR" && git init -q . && git config user.email t@t.t && git config user.name t ) >/dev/null 2>&1

PASS=0
FAIL=0

reset_repo() {
  ( cd "$PROJECT_DIR" && git reset HEAD -- . >/dev/null 2>&1 && git rm -rf --cached --quiet . >/dev/null 2>&1 || true )
  find "$PROJECT_DIR/packages" "$PROJECT_DIR/apps" "$PROJECT_DIR/specs" "$PROJECT_DIR/docs" -type f -delete 2>/dev/null || true
  rm -f "$PROJECT_DIR/PROJECT_CHARTER.md"
}

# TC1: empty staged → exit 0 no-op (no warn line)
reset_repo
out=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 0 ] && [ -z "$out" ]; then
  echo "  TC TC1-empty-staged-noop: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-empty-staged-noop: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC2: charter-only staged → exit 0 OK (charter is exempt)
reset_repo
echo "v1" > "$PROJECT_DIR/PROJECT_CHARTER.md"
( cd "$PROJECT_DIR" && git add PROJECT_CHARTER.md ) >/dev/null 2>&1
out=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 0 ] && ! printf '%s' "$out" | grep -q 'WARN:'; then
  echo "  TC TC2-charter-only-OK: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-charter-only-OK: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC3: code (packages/) staged without spec → WARN to stderr (rc=0, not blocking)
reset_repo
echo "def f(): pass" > "$PROJECT_DIR/packages/a.py"
( cd "$PROJECT_DIR" && git add packages/a.py ) >/dev/null 2>&1
out=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'code-without-spec\|WARN:'; then
  echo "  TC TC3-code-without-spec-warn: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-code-without-spec-warn: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC4: code + spec both staged → exit 0 OK (no warn)
reset_repo
echo "def f(): pass" > "$PROJECT_DIR/packages/a.py"
echo "# spec for a" > "$PROJECT_DIR/specs/a-spec.md"
( cd "$PROJECT_DIR" && git add packages/a.py specs/a-spec.md ) >/dev/null 2>&1
out=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 0 ] && ! printf '%s' "$out" | grep -q 'WARN:'; then
  echo "  TC TC4-both-staged-OK: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-both-staged-OK: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC5: STRICT mode (env=1) + code without spec → exit 1 BLOCK
reset_repo
echo "def f(): pass" > "$PROJECT_DIR/apps/b.py"
( cd "$PROJECT_DIR" && git add apps/b.py ) >/dev/null 2>&1
out=$(STOCKFORGE_SAME_COMMIT_STRICT=1 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 1 ] && printf '%s' "$out" | grep -q 'BLOCKING\|spec required'; then
  echo "  TC TC5-strict-mode-block: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-strict-mode-block: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

# TC6: spec-only staged (no code) → INFO message (rc=0)
reset_repo
echo "# new spec section" > "$PROJECT_DIR/specs/c-spec.md"
( cd "$PROJECT_DIR" && git add specs/c-spec.md ) >/dev/null 2>&1
out=$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" 2>&1)
rc=$?
if [ "$rc" = 0 ] && printf '%s' "$out" | grep -q 'INFO:\|spec-only'; then
  echo "  TC TC6-spec-only-info: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-spec-only-info: FAIL — rc=$rc out=$out"
  FAIL=$((FAIL+1))
fi

TOTAL=$((PASS+FAIL))
echo ""
echo "=== same-commit-rule firing-test: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
