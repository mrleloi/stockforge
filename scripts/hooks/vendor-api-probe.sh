#!/usr/bin/env bash
# vendor-api-probe.sh — S35 D4 (per L-S28-1 vendor-API drift + L-S32-1 multi-strategy probe).
# Phase 1+ — relaxes L-S11-1 portability (Python OK).
# At IMPL-session entry, scan active session-plan for vendor library/API references; probe each;
# emit drift-log if API surface differs from master-plan-claimed.
#
# Wire as SessionStart hook AFTER Phase 0 close (S22+).
set -euo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
LOG="$PROJECT_DIR/agent-workspace/memory/.vendor-api-probe.log"
mkdir -p "$(dirname "$LOG")"

[ ! -f "$EXEC_FILE" ] && exit 0

# Active session-plan path resolution.
ACTIVE_PLAN=$(grep -oE 'session-plans/pending/[0-9-]+[^ )"`]+\.md' "$EXEC_FILE" | head -1 || true)
[ -z "$ACTIVE_PLAN" ] && exit 0
[ ! -f "$PROJECT_DIR/$ACTIVE_PLAN" ] && exit 0

# Whitelist of vendor libraries we care about (extend as project grows).
VENDOR_LIBS="vnstock yfinance httpx anthropic openai duckdb pgvector"

VIOLATIONS=0
for LIB in $VENDOR_LIBS; do
  if grep -qE "(import $LIB|from $LIB|$LIB\.)" "$PROJECT_DIR/$ACTIVE_PLAN"; then
    # Probe library importability + version.
    PROBE=$(python -c "
import importlib, sys
try:
    m = importlib.import_module('$LIB')
    v = getattr(m, '__version__', 'unknown')
    print(f'OK $LIB v={v}')
except Exception as e:
    print(f'FAIL $LIB err={e}')
    sys.exit(1)
" 2>&1) || true
    if echo "$PROBE" | grep -q '^FAIL'; then
      VIOLATIONS=$((VIOLATIONS + 1))
      echo "vendor-api-probe FAIL: $PROBE (referenced in $ACTIVE_PLAN)" >&2
    fi
    printf '[%s] probe %s : %s\n' "$(date -Iseconds)" "$LIB" "$PROBE" >> "$LOG"
  fi
done

# Multi-strategy ladder detection (L-S32-1).
LADDER=$(grep -cE 'Strategy A[1-4]|alternative [A-D]:|ladder' "$PROJECT_DIR/$ACTIVE_PLAN" || echo 0)
if [ "$LADDER" -ge 3 ]; then
  printf '[%s] multi-strategy ladder detected (count=%s) in %s — probe-first doctrine recommended\n' \
    "$(date -Iseconds)" "$LADDER" "$ACTIVE_PLAN" >> "$LOG"
  echo "vendor-api-probe INFO: multi-strategy ladder detected (≥3 strategies); probe all viable per L-S32-1 before commit." >&2
fi

[ "$VIOLATIONS" -gt 0 ] && exit 0  # non-blocking advisory; can tighten to exit 1 in v2
exit 0
