#!/usr/bin/env bash
# pending-queue-escalator.sh — Stop cadence (NEW S348 per ADR D-068)
#
# Reads human-workspace/notifications/.pending-queue.tsv (produced by escalation-engine.sh
# PENDING-tier routing per ADR D-068) and acts per row age + state:
#   - escalate_at <= now AND telegram_pushed=false -> fire Telegram + set telegram_pushed=true
#   - row age > 24h AND telegram_pushed=true AND no ack received -> auto-archive to notifications/archive/
#   - underlying artifact_path GONE (deleted/resolved) -> mark resolve_reason="artifact-gone" + archive
#
# Bash + POSIX only per L-S11-1. Best-effort: never fails Stop chain on its own errors (RC=0).
# SPAWN-CONTEXT: positional-arg (event optional via $1; reads .pending-queue.tsv either way)

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PENDING_QUEUE="$PROJECT_DIR/human-workspace/notifications/.pending-queue.tsv"
ARCHIVE_DIR="$PROJECT_DIR/human-workspace/notifications/archive"
LOG="$PROJECT_DIR/agent-workspace/memory/.pending-queue-escalator.log"
TELEGRAM_HOOK="$PROJECT_DIR/scripts/hooks/telegram-push.sh"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"
case "$NOW_EPOCH" in ''|*[!0-9]*) NOW_EPOCH=0 ;; esac

mkdir -p "$(dirname "$LOG")" "$ARCHIVE_DIR" 2>/dev/null || true

# No queue file -> silent exit
[ -f "$PENDING_QUEUE" ] || exit 0

# Atomic rewrite per D-062
TMP="$PENDING_QUEUE.tmp.$$"
trap 'rm -f "$TMP" 2>/dev/null || true; exit 0' EXIT ERR

# Preserve header lines (#)
grep '^#' "$PENDING_QUEUE" 2>/dev/null > "$TMP" || true

ARCHIVED=0
TELEGRAM_FIRED=0
RESOLVED=0

# Use process substitution to keep counters in parent shell (avoids subshell variable scoping issue)
while IFS=$'\t' read -r pending_id block_tier severity artifact_path detected_at escalate_at telegram_pushed archived_at resolve_reason; do
  [ -z "$pending_id" ] && continue
  case "$pending_id" in '#'*) continue ;; esac

  # Age in seconds since detected_at (parse ISO 8601 via date -d; gnu-coreutils)
  DETECTED_EPOCH=$(date -d "$detected_at" +%s 2>/dev/null || echo "$NOW_EPOCH")
  case "$DETECTED_EPOCH" in ''|*[!0-9]*) DETECTED_EPOCH=$NOW_EPOCH ;; esac
  AGE_SECONDS=$(( NOW_EPOCH - DETECTED_EPOCH ))

  # === Self-resolution check: artifact GONE? ===
  if [ -n "$artifact_path" ] && [ ! -e "$PROJECT_DIR/$artifact_path" ]; then
    # Artifact resolved/deleted -> archive with resolve_reason="artifact-gone"
    SLUG=$(basename "$artifact_path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo "unknown")
    ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d-%H%M%S 2>/dev/null)-PENDING-${SLUG}.md"
    {
      printf '# PENDING resolved (artifact-gone) %s\n' "$TS"
      printf 'pending_id: %s\n' "$pending_id"
      printf 'block_tier: %s\n' "$block_tier"
      printf 'severity: %s\n' "$severity"
      printf 'artifact_path: %s\n' "$artifact_path"
      printf 'detected_at: %s\n' "$detected_at"
      printf 'archived_at: %s\n' "$TS"
      printf 'resolve_reason: artifact-gone\n'
    } > "$ARCHIVE_FILE" 2>/dev/null || true
    RESOLVED=$((RESOLVED+1))
    continue  # Skip writing to new TMP (effectively delete from queue)
  fi

  # === Auto-archive: age > 24h AND telegram_pushed=true AND no ack received ===
  if [ "$AGE_SECONDS" -gt 86400 ] && [ "$telegram_pushed" = "true" ]; then
    SLUG=$(basename "$artifact_path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo "unknown")
    ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d-%H%M%S 2>/dev/null)-PENDING-${SLUG}.md"
    {
      printf '# PENDING auto-archived (24h-no-action) %s\n' "$TS"
      printf 'pending_id: %s\n' "$pending_id"
      printf 'block_tier: %s\n' "$block_tier"
      printf 'severity: %s\n' "$severity"
      printf 'artifact_path: %s\n' "$artifact_path"
      printf 'detected_at: %s\n' "$detected_at"
      printf 'archived_at: %s\n' "$TS"
      printf 'resolve_reason: auto-archive-24h-no-action\n'
    } > "$ARCHIVE_FILE" 2>/dev/null || true
    ARCHIVED=$((ARCHIVED+1))
    continue  # Skip writing to new TMP (remove from queue)
  fi

  # === Telegram escalation: escalate_at <= now AND telegram_pushed=false ===
  case "$escalate_at" in ''|*[!0-9]*) escalate_at=0 ;; esac
  if [ "$telegram_pushed" = "false" ] && [ "$NOW_EPOCH" -ge "$escalate_at" ]; then
    if [ -x "$TELEGRAM_HOOK" ] && [ "${STOCKFORGE_TELEGRAM_DRY_RUN:-0}" != "1" ]; then
      SLUG=$(basename "$artifact_path" 2>/dev/null)
      AGE_HOURS=$(( AGE_SECONDS / 3600 ))
      HOURS_REMAINING=$(( (86400 - AGE_SECONDS) / 3600 ))
      [ "$HOURS_REMAINING" -lt 0 ] && HOURS_REMAINING=0
      TG_MSG=$(printf '[StockForge PENDING] severity=%s artifact=%s\nDetected %sh ago at %s. No human action yet -- escalating.\nSuggested actions: (a) review marker + decide if resolved (b) reply "ack %s" to dismiss (c) reply "approved" to escalate to HARD.\nArchive in %sh if no action.' \
        "$severity" "$SLUG" "$AGE_HOURS" "$detected_at" "$SLUG" "$HOURS_REMAINING")
      bash "$TELEGRAM_HOOK" "HIGH" "$TG_MSG" 2>/dev/null || true
      telegram_pushed="true"
      TELEGRAM_FIRED=$((TELEGRAM_FIRED+1))
    elif [ "${STOCKFORGE_TELEGRAM_DRY_RUN:-0}" = "1" ]; then
      # DRY_RUN: record what would have fired (for fire-tests)
      printf '[DRY_RUN] telegram would fire: severity=%s artifact=%s\n' "$severity" "$artifact_path" >> "$LOG" 2>/dev/null || true
      telegram_pushed="true"
      TELEGRAM_FIRED=$((TELEGRAM_FIRED+1))
    fi
  fi

  # Keep row in queue (write to TMP)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$pending_id" "$block_tier" "$severity" "$artifact_path" "$detected_at" \
    "$escalate_at" "$telegram_pushed" "$archived_at" "$resolve_reason" >> "$TMP"
done < <(grep -v '^#' "$PENDING_QUEUE" 2>/dev/null)

# Atomic install
mv -f "$TMP" "$PENDING_QUEUE" 2>/dev/null || { rm -f "$TMP"; exit 0; }

printf '[%s] pending-queue-escalator: archived=%s telegram_fired=%s resolved=%s\n' \
  "$TS" "$ARCHIVED" "$TELEGRAM_FIRED" "$RESOLVED" >> "$LOG"

exit 0
