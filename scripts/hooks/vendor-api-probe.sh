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
# Match optional `agent-workspace/` prefix because grep -oE returns ONLY the matched
# substring (without it, production paths like `agent-workspace/session-plans/...`
# get stripped to bare `session-plans/...` and the existence check fails — silent
# no-op against production layout). S74 fix per L-S74-1 — was latent S73 finding.
RAW_PATH=$(grep -oE '(agent-workspace/)?session-plans/pending/[0-9-]+[^ )"`]+\.md' "$EXEC_FILE" | head -1 || true)
[ -z "$RAW_PATH" ] && exit 0
# Normalize: ensure agent-workspace/ prefix (production layout).
case "$RAW_PATH" in
  agent-workspace/*) ACTIVE_PLAN="$RAW_PATH" ;;
  *) ACTIVE_PLAN="agent-workspace/$RAW_PATH" ;;
esac
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
LADDER=$(grep -cE 'Strategy A[1-4]|alternative [A-D]:|ladder' "$PROJECT_DIR/$ACTIVE_PLAN" 2>/dev/null || true)
[[ "$LADDER" =~ ^[0-9]+$ ]] || LADDER=0
if [ "$LADDER" -ge 3 ]; then
  printf '[%s] multi-strategy ladder detected (count=%s) in %s — probe-first doctrine recommended\n' \
    "$(date -Iseconds)" "$LADDER" "$ACTIVE_PLAN" >> "$LOG"
  echo "vendor-api-probe INFO: multi-strategy ladder detected (≥3 strategies); probe all viable per L-S32-1 before commit." >&2
fi

[ "$VIOLATIONS" -gt 0 ] && exit 0  # non-blocking advisory; can tighten to exit 1 in v2
exit 0
