#!/usr/bin/env bash
# telegram-push-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies:
#   TC1: no creds env → silent no-op (RC=0)
#   TC2: DRY_RUN=1 + creds → log line emitted, marker written, no curl call
#   TC3: idempotency — second call same bucket → no double log entry
#
# Does NOT exercise real HTTP POST (would require live bot). Real-API verification
# is manual gated on user providing credentials.
#
# SPAWN-CONTEXT: positional-arg

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/telegram-push.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t telegram-push-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
}

# === TC1: no creds → silent no-op ===
setup_tmp
CLAUDE_PROJECT_DIR="$TMP" \
  STOCKFORGE_TELEGRAM_BOT_TOKEN="" \
  STOCKFORGE_TELEGRAM_CHAT_ID="" \
  bash "$HOOK" "HIGH" "test message TC1" >/dev/null 2>&1
RC=$?
LOG_HAS_SKIPPED=$(grep -c "SKIPPED (creds not configured)" "$TMP/agent-workspace/memory/.telegram-push.log" 2>/dev/null || echo 0)
if [ "$RC" -eq 0 ] && [ "$LOG_HAS_SKIPPED" -ge 1 ]; then note_pass; else note_fail "TC1: expected RC=0 + SKIPPED log; got RC=$RC log_skipped=$LOG_HAS_SKIPPED"; fi

# === TC2: DRY_RUN + creds → log + marker, no real curl ===
setup_tmp
CLAUDE_PROJECT_DIR="$TMP" \
  STOCKFORGE_TELEGRAM_BOT_TOKEN="fake-token-test" \
  STOCKFORGE_TELEGRAM_CHAT_ID="123456" \
  STOCKFORGE_TELEGRAM_DRY_RUN=1 \
  bash "$HOOK" "CRITICAL" "test message TC2 DRY_RUN" >/dev/null 2>&1
RC=$?
LOG_HAS_DRY=$(grep -c "DRY_RUN" "$TMP/agent-workspace/memory/.telegram-push.log" 2>/dev/null || echo 0)
MARKER_COUNT=$(find "$TMP/agent-workspace/memory" -name ".telegram-pushed-*" 2>/dev/null | grep -c . || echo 0)
if [ "$RC" -eq 0 ] && [ "$LOG_HAS_DRY" -ge 1 ] && [ "$MARKER_COUNT" -ge 1 ]; then
  note_pass
else
  note_fail "TC2: expected RC=0 + DRY_RUN log + marker; got RC=$RC log_dry=$LOG_HAS_DRY markers=$MARKER_COUNT"
fi

# === TC3: idempotency ===
setup_tmp
for i in 1 2 3; do
  CLAUDE_PROJECT_DIR="$TMP" \
    STOCKFORGE_TELEGRAM_BOT_TOKEN="fake-token-test" \
    STOCKFORGE_TELEGRAM_CHAT_ID="123456" \
    STOCKFORGE_TELEGRAM_DRY_RUN=1 \
    bash "$HOOK" "HIGH" "identical message TC3" >/dev/null 2>&1
done
DRY_COUNT=$(grep -c "DRY_RUN" "$TMP/agent-workspace/memory/.telegram-push.log" 2>/dev/null || echo 0)
# Expect: first call logs DRY_RUN; subsequent same-hour-bucket calls hit marker → no second log
if [ "$DRY_COUNT" -eq 1 ]; then note_pass; else note_fail "TC3: idempotency — expected 1 DRY_RUN log across 3 calls same bucket, got $DRY_COUNT"; fi

# Summary
TOTAL=$((PASS+FAIL))
echo "telegram-push-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
