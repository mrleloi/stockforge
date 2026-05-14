#!/usr/bin/env bash
# telegram-push.sh — Phase D of unified severity/escalation system (proposal §2 Layer 5)
#
# Pushes severity-tagged messages to Telegram via Bot API. SKELETON — user must configure:
#   1. Create bot via @BotFather → obtain bot token
#   2. Send `/start` to your bot, then GET https://api.telegram.org/bot<TOKEN>/getUpdates
#      → extract `chat.id` from the response
#   3. Set env vars in `.claude/settings.local.json` (gitignored per wildcard-permissions-preference):
#        STOCKFORGE_TELEGRAM_BOT_TOKEN=<token>
#        STOCKFORGE_TELEGRAM_CHAT_ID=<chat_id>
#   4. (Optional) Set STOCKFORGE_TELEGRAM_DRY_RUN=1 to log without HTTP call
#
# Without credentials → exits silently (no-op).
# Best-effort: never fails caller on network/API error.
#
# Args: $1 severity (CRITICAL|HIGH|MEDIUM|LOW), $2 message body
# Idempotency: per-event marker via SHA of (severity + first 80 chars of message + hour-bucket).
#
# Bash + POSIX only per L-S11-1.

set -uo pipefail
trap 'exit 0' ERR

SEVERITY="${1:-LOW}"
MESSAGE="${2:-(no message)}"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.telegram-push.log"
TS="$(date -Iseconds)"

mkdir -p "$MEM_DIR"

TOKEN="${STOCKFORGE_TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${STOCKFORGE_TELEGRAM_CHAT_ID:-}"
DRY_RUN="${STOCKFORGE_TELEGRAM_DRY_RUN:-0}"

# No credentials → silent no-op (skeleton mode awaiting user config)
if [ -z "$TOKEN" ] || [ -z "$CHAT_ID" ]; then
  printf '[%s] telegram-push: SKIPPED (creds not configured) severity=%s\n' "$TS" "$SEVERITY" >> "$LOG"
  exit 0
fi

# Idempotency: hash-based marker
HASH=$(printf '%s|%s|%s' "$SEVERITY" "${MESSAGE:0:80}" "$(date +%Y%m%d-%H 2>/dev/null)" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "nohash")
MARKER="$MEM_DIR/.telegram-pushed-${HASH}"

# Cleanup stale markers (older than 24h)
find "$MEM_DIR" -maxdepth 1 -name ".telegram-pushed-*" -mtime +1 -delete 2>/dev/null || true

[ -f "$MARKER" ] && exit 0

# Severity prefix (ASCII-only for cross-platform UTF-8 reliability)
# Note: emoji were attempted but Windows bash + curl --data-urlencode mishandles UTF-8 multibyte
# resulting in Telegram API 400 "strings must be encoded in UTF-8". Plain-text tags work universally.
case "$SEVERITY" in
  CRITICAL) PREFIX="[!! CRITICAL !!]" ;;
  HIGH)     PREFIX="[!  HIGH  !]" ;;
  MEDIUM)   PREFIX="[ MEDIUM ]" ;;
  LOW)      PREFIX="[ low ]" ;;
  *)        PREFIX="[ ${SEVERITY} ]" ;;
esac

FULL_MSG="${PREFIX} StockForge: ${MESSAGE}"

if [ "$DRY_RUN" = "1" ]; then
  printf '[%s] telegram-push: DRY_RUN msg=%s\n' "$TS" "$FULL_MSG" >> "$LOG"
  echo "fired-dry" > "$MARKER"
  exit 0
fi

# POST to Telegram via JSON body with explicit UTF-8 charset (best-effort; ignore errors)
if command -v curl >/dev/null 2>&1; then
  # Escape JSON special chars in message: \, ", control chars
  ESC_MSG=$(printf '%s' "$FULL_MSG" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/	/\\t/g')
  ESC_MSG=$(printf '%s' "$ESC_MSG" | tr '\n' ' ')
  JSON_BODY="{\"chat_id\":\"${CHAT_ID}\",\"text\":\"${ESC_MSG}\"}"
  RESP=$(curl -sS -X POST \
    "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "$JSON_BODY" \
    --max-time 10 2>&1 || echo "(curl-failed)")
  printf '[%s] telegram-push: severity=%s resp_first120=%s\n' "$TS" "$SEVERITY" "${RESP:0:120}" >> "$LOG"
  echo "fired" > "$MARKER"
else
  printf '[%s] telegram-push: SKIPPED (curl not available) severity=%s\n' "$TS" "$SEVERITY" >> "$LOG"
fi

exit 0
