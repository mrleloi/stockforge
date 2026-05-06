#!/usr/bin/env bash
# drift-rollup-daily.sh — promotes raw .drift-signals.log entries into a dated
# human-readable rollup at agent-workspace/memory/drift-logs/YYYY-MM-DD-rollup.md.
#
# Decision basis: KI-S43b harness recovery — drift hook fires healthy but the
# `drift-logs/` directory was confused as proof of staleness (L-S43b-8 / agent-notes
# 2026-05-01 "Drift Hook Is Healthy"). Two surfaces have distinct semantics:
#   (a) .drift-signals.log = raw deterministic-hook stream (always-on, append)
#   (b) drift-logs/*.md     = curated drift reports for human review
# This hook bridges them. Idempotent: regenerates today's rollup only when the
# raw log has new entries since the rollup was last written.
#
# Bash + POSIX only per L-S11-1.
# Stop hook (low priority — runs after lesson-synthesis-watchdog).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
RAW_LOG="$MEM_DIR/.drift-signals.log"
ROLLUP_DIR="$MEM_DIR/drift-logs"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
TS="$(date -Iseconds)"
TODAY="$(date +%Y-%m-%d)"
ROLLUP_FILE="$ROLLUP_DIR/$TODAY-rollup.md"

mkdir -p "$ROLLUP_DIR"

# Skip when no raw log exists yet
[ -f "$RAW_LOG" ] || { printf '[%s] drift-rollup-daily: raw log absent; skip\n' "$TS" >> "$HOOK_LOG"; exit 0; }

# Idempotency: skip when rollup is already newer than raw log (no new entries)
if [ -f "$ROLLUP_FILE" ]; then
  RAW_MTIME="$(stat -c %Y "$RAW_LOG" 2>/dev/null || stat -f %m "$RAW_LOG" 2>/dev/null || echo 0)"
  ROLL_MTIME="$(stat -c %Y "$ROLLUP_FILE" 2>/dev/null || stat -f %m "$ROLLUP_FILE" 2>/dev/null || echo 0)"
  if [ "$RAW_MTIME" -le "$ROLL_MTIME" ]; then
    printf '[%s] drift-rollup-daily: rollup current (raw_mtime=%s rollup_mtime=%s); skip\n' \
      "$TS" "$RAW_MTIME" "$ROLL_MTIME" >> "$HOOK_LOG"
    exit 0
  fi
fi

# Today's entries: lines starting with [YYYY-MM-DDT...
TODAY_ENTRIES="$(grep "^\[$TODAY" "$RAW_LOG" 2>/dev/null || true)"
TOTAL_TODAY="$(printf '%s\n' "$TODAY_ENTRIES" | grep -c '^\[' || true)"
[ -z "$TODAY_ENTRIES" ] && TOTAL_TODAY=0

# Aggregations
HIGH_COUNT="$(printf '%s\n' "$TODAY_ENTRIES" | grep -c 'severity=HIGH' || true)"
MEDIUM_COUNT="$(printf '%s\n' "$TODAY_ENTRIES" | grep -c 'severity=MEDIUM' || true)"
LOW_COUNT="$(printf '%s\n' "$TODAY_ENTRIES" | grep -c 'severity=LOW' || true)"

# Per-signal counts (signal name = 2nd whitespace-delimited token)
SIGNAL_BREAKDOWN="$(printf '%s\n' "$TODAY_ENTRIES" \
  | awk '{ print $2 }' \
  | sort \
  | uniq -c \
  | sort -rn \
  | sed 's/^ */  - /')"

# Distinct files referenced (extract file=... up to whitespace)
DISTINCT_FILES="$(printf '%s\n' "$TODAY_ENTRIES" \
  | grep -oE 'file=[^ ]+' \
  | sort -u \
  | sed 's/^file=/  - /' || true)"
DISTINCT_FILE_COUNT="$(printf '%s\n' "$DISTINCT_FILES" | grep -c '^  - ' || true)"

# Last 10 HIGH entries verbatim for triage
LAST_HIGH="$(printf '%s\n' "$TODAY_ENTRIES" | grep 'severity=HIGH' | tail -10 | sed 's/^/    /' || true)"

# Write rollup
{
  printf '# Drift Rollup — %s\n\n' "$TODAY"
  printf '_Generated: %s_\n_Source: agent-workspace/memory/.drift-signals.log_\n_Generator: scripts/hooks/drift-rollup-daily.sh_\n\n' "$TS"
  printf '## Summary\n\n'
  printf -- '- **Total signals today**: %s\n' "$TOTAL_TODAY"
  printf -- '- **HIGH**: %s\n' "$HIGH_COUNT"
  printf -- '- **MEDIUM**: %s\n' "$MEDIUM_COUNT"
  printf -- '- **LOW**: %s\n' "$LOW_COUNT"
  printf -- '- **Distinct files referenced**: %s\n\n' "$DISTINCT_FILE_COUNT"
  printf '## Signal breakdown\n\n'
  if [ -n "$SIGNAL_BREAKDOWN" ]; then
    printf -- '%s\n\n' "$SIGNAL_BREAKDOWN"
  else
    printf '_(none)_\n\n'
  fi
  printf '## Files referenced\n\n'
  if [ -n "$DISTINCT_FILES" ]; then
    printf -- '%s\n\n' "$DISTINCT_FILES"
  else
    printf '_(none)_\n\n'
  fi
  printf '## Last 10 HIGH-severity entries\n\n'
  if [ -n "$LAST_HIGH" ]; then
    printf '```\n'
    printf -- '%s\n' "$LAST_HIGH"
    printf '```\n'
  else
    printf '_(none — clean day at HIGH severity)_\n'
  fi
} > "$ROLLUP_FILE"

printf '[%s] drift-rollup-daily: wrote %s (total=%s high=%s medium=%s low=%s files=%s)\n' \
  "$TS" "$ROLLUP_FILE" "$TOTAL_TODAY" "$HIGH_COUNT" "$MEDIUM_COUNT" "$LOW_COUNT" "$DISTINCT_FILE_COUNT" >> "$HOOK_LOG"

exit 0
