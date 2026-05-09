#!/usr/bin/env bash
# qa-stale-urgent-escalator.sh — HH-E.1 deliverable (Phase 2.5 harness hardening).
#
# Stop hook scans human-workspace/q-and-a/pending/ for bundles older than 48h;
# emits an URGENT entry to human-workspace/notifications/urgent.md (idempotent
# per session via marker file).
#
# Bash + POSIX only per L-S11-1.
# Stop hook (priority: late chain — after lesson-synthesis-watchdog).
# Decision basis: 009-S48-...md § HH-E.1 + 4-bundle stale empirics S48f checkpoint.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
QA_DIR="$PROJECT_DIR/human-workspace/q-and-a/pending"
URGENT="$PROJECT_DIR/human-workspace/notifications/urgent.md"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.qa-urgent-escalator.log"
# L-S108-1 fix (S109): per-session marker MUST use hour-bucket, NEVER fallback constant.
# CLAUDE_SESSION_ID empty for Stop hooks on Windows → fallback "main" shared across
# ALL sessions → marker collision (M-S108-1 RCA: stale .qa-urgent-fired-main from
# S48g blocked hook S99-S108). SID still captured for log diagnostics.
SID="${CLAUDE_SESSION_ID:-}"
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$MEM_DIR/.qa-urgent-fired-${BUCKET}"
TS="$(date -Iseconds)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"

# Cleanup stale markers from prior buckets (L-S108-1 prevention).
for old_marker in "$MEM_DIR"/.qa-urgent-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".qa-urgent-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null ;;
  esac
done

# Idempotency: skip if already fired this hour-bucket
[ -f "$MARKER" ] && exit 0

mkdir -p "$(dirname "$LOG")" "$(dirname "$URGENT")"

# Skip if pending dir absent
[ -d "$QA_DIR" ] || exit 0

# Find bundles older than 48h (mtime > 2 days). +2 means strictly older than 2*24h.
set +o pipefail
STALE_FILES=$(find "$QA_DIR" -maxdepth 1 -type f -name "*.md" -mtime +2 2>/dev/null | sort)
set -o pipefail

STALE_COUNT=0
[ -n "$STALE_FILES" ] && STALE_COUNT=$(printf '%s\n' "$STALE_FILES" | grep -c . 2>/dev/null || true)
# Coerce to int (find can output empty string with -mtime)
[[ "$STALE_COUNT" =~ ^[0-9]+$ ]] || STALE_COUNT=0

if [ "$STALE_COUNT" -eq 0 ]; then
  printf '[%s] qa-stale-urgent-escalator: 0 stale bundles (>48h); skip\n' "$TS" >> "$LOG"
  exit 0
fi

# Emit URGENT entry (append-only)
{
  printf '\n## URGENT — %s — Q&A bundles stale >48h (%d count)\n\n' "$TS" "$STALE_COUNT"
  printf 'Fired by: scripts/hooks/qa-stale-urgent-escalator.sh (HH-E.1)\n'
  printf 'Session: %s\n\n' "$SID"
  printf 'Stale bundles requiring user attention:\n'
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#$PROJECT_DIR/}"
    MTIME_EPOCH=$(stat -c %Y "$f" 2>/dev/null || echo 0)
    AGE_HOURS=$(( (NOW_EPOCH - MTIME_EPOCH) / 3600 ))
    printf -- '- `%s` (age=%dh)\n' "$rel" "$AGE_HOURS"
  done <<< "$STALE_FILES"
  printf '\nLikely causes:\n'
  printf -- '- Bundle status `answered-via-chat awaiting user mv` (HH-E.2 contract revision pending ratification)\n'
  printf -- '- Or genuinely awaiting user response (open Q&A still pending answer)\n\n'
  printf 'Resolution path: review each bundle frontmatter `status:` field; mv answered ones to `human-workspace/q-and-a/answered/` OR record decision; for open Q&A, draft answer.\n\n'
  printf -- '---\n'
} >> "$URGENT"

# Log + write idempotency marker
printf '[%s] qa-stale-urgent-escalator: emitted URGENT for %d stale bundles\n' "$TS" "$STALE_COUNT" >> "$LOG"
echo "fired" > "$MARKER"

# Soft-warn to stderr (visible in Stop chain output)
echo "qa-stale-urgent-escalator: $STALE_COUNT Q&A bundles >48h stale; URGENT logged to $URGENT" >&2

exit 0
