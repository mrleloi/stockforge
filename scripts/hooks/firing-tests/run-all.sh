#!/usr/bin/env bash
# run-all.sh — orchestrator for firing-test suite under scripts/hooks/firing-tests/.
#
# Purpose: empirically validate "N/N PASS" claims from session close notes per
# Charter Principle 8 (Calibration over confidence). Each *-fire-test.sh exits 0 on
# pass, non-zero on fail. This script iterates all of them with a per-test timeout,
# tallies results, and returns 0 only if ALL pass.
#
# Authored S121 (2026-05-06) to close S120 close-note "69/69 PASS" unverifiable claim
# (no orchestrator existed). Each fire-test self-isolates via TEMPDIR + traps; this
# runner does not stage fixtures itself.
#
# Wires: NOT auto-wired to Stop hook (would slow every turn). Run manually post-hook-edit
# or via `bash scripts/hooks/firing-tests/run-all.sh` to verify suite state.
#
# Phase 0 portability: bash + POSIX only (L-S11-1). No -e (need rc capture per test).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PER_TEST_TIMEOUT="${FIRING_TEST_TIMEOUT:-30}"

# Detect timeout(1) availability (POSIX-non-portable; GNU coreutils ubiquitous on Linux/git-bash).
if command -v timeout >/dev/null 2>&1; then
  USE_TIMEOUT=1
else
  USE_TIMEOUT=0
  echo "WARN: timeout(1) not available; running without per-test timeout (slow tests may stall suite)"
fi

PASS=0
FAIL=0
FAILED_TESTS=""
TOTAL=0
START_TS="$(date +%s 2>/dev/null || echo unknown)"

for test in "$SCRIPT_DIR"/*-fire-test.sh; do
  [ ! -f "$test" ] && continue
  bn="$(basename "$test")"
  TOTAL=$((TOTAL + 1))

  if [ "$USE_TIMEOUT" = 1 ]; then
    timeout "$PER_TEST_TIMEOUT" bash "$test" >/dev/null 2>&1
  else
    bash "$test" >/dev/null 2>&1
  fi
  rc=$?

  if [ "$rc" = 0 ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    if [ "$rc" = 124 ] && [ "$USE_TIMEOUT" = 1 ]; then
      FAILED_TESTS="${FAILED_TESTS}  ✗ ${bn} (TIMEOUT >${PER_TEST_TIMEOUT}s)"$'\n'
    else
      FAILED_TESTS="${FAILED_TESTS}  ✗ ${bn} (rc=${rc})"$'\n'
    fi
  fi
done

END_TS="$(date +%s 2>/dev/null || echo unknown)"
if [ "$START_TS" != "unknown" ] && [ "$END_TS" != "unknown" ]; then
  ELAPSED=$((END_TS - START_TS))
else
  ELAPSED="?"
fi

echo "=== firing-test suite: ${PASS}/${TOTAL} PASS (elapsed ${ELAPSED}s) ==="
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  printf '%s' "$FAILED_TESTS"
  exit 1
fi
exit 0
