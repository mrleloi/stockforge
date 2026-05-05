#!/usr/bin/env bash
# Drift-check runner — executes all deterministic drift signals defined in
# `agent-workspace/constitution/drift-signals.md`. Exit non-zero if any HIGH
# signal trips. Called by `.claude/hooks/pre-commit.example` and CI.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

FAIL=0
fail()  { echo "  ✗ $*"; FAIL=1; }
pass()  { echo "  ✓ $*"; }
info()  { echo "→ $*"; }

info "DR1: Framework leak into domain layer"
if grep -R --include='*.py' -nE '^(from|import) (fastapi|pydantic|sqlalchemy|psycopg2|redis|httpx)\b' packages/domain 2>/dev/null | grep -v '^$'; then
  fail "DR1: framework import found under packages/domain/"
else
  pass "DR1 clean"
fi

info "DR-S1: LLM number-emission without tool call (grep heuristic)"
if grep -R --include='*.py' -nE 'llm\.complete\(.*(ROE|PE|EPS|DCF|giá trị)' packages apps 2>/dev/null | grep -v '^$'; then
  fail "DR-S1: suspected LLM math — review call sites"
else
  pass "DR-S1 clean"
fi

info "DR8: Cross-BC direct import (should go through contracts/)"
# Pairs of BCs that must not import each other directly
for pair in "bc4_thesis bc6_influence" "bc4_thesis bc7_crowd" "bc6_influence bc7_crowd"; do
  a="${pair% *}"; b="${pair#* }"
  if grep -R --include='*.py' -nE "from packages\.domain\.${b}" "packages/domain/${a}" 2>/dev/null | grep -v '^$'; then
    fail "DR8: ${a} imports ${b} directly"
  fi
done
pass "DR8 scan complete"

info "Type check"
if command -v mypy >/dev/null 2>&1; then
  if mypy --strict packages apps 2>&1 | tail -5; then pass "mypy"; else fail "mypy failed"; fi
else
  echo "  (mypy not installed — skipped)"
fi

info "Lint"
if command -v ruff >/dev/null 2>&1; then
  if ruff check packages apps; then pass "ruff"; else fail "ruff failed"; fi
else
  echo "  (ruff not installed — skipped)"
fi

info "Tests"
if command -v pytest >/dev/null 2>&1; then
  if pytest -q; then pass "pytest"; else fail "pytest failed"; fi
else
  echo "  (pytest not installed — skipped)"
fi

if [ $FAIL -ne 0 ]; then
  echo
  echo "DRIFT CHECK: FAIL — fix HIGH signals before commit."
  exit 1
fi

echo
echo "DRIFT CHECK: PASS"
