#!/usr/bin/env bash
# dispatch-pending-rotation.sh — Stop hook: archive ended-session dispatch-pending JSONL.
# P-LOW-3 structural fix per S320/S325 checkpoint carry-forward: per-dispatch close = busy-work
# (catch-rate 0 = AP-23 ritual-demotion red flag); rotation is the structural fix.
#
# Detects `.dispatch-pending-<session-id>.jsonl` files in agent-workspace/memory/ whose mtime
# is older than ROTATION_THRESHOLD_HRS (default 12h) and moves them to
# `.dispatch-pending-archive/` to prevent HH-6-DISPATCH-STALE alert accumulation.
#
# Idempotent: archive directory auto-created; skip if no eligible files.
# L-S11-1 portability: bash + POSIX only.
# L-S58-1 ERR-trap-aware: if/then/fi not [ x ] && Y.
#
# Wired: Stop chain (after urgent-md-rotate, before auto-reboot-handoff-verify).
# Override: STOCKFORGE_DISPATCH_ROTATION_HRS=N (default 12). Set 0 to disable (rotation skipped).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
JSONL_DIR="$PROJECT_DIR/agent-workspace/memory"
ARCHIVE_DIR="$JSONL_DIR/.dispatch-pending-archive"
ROTATION_THRESHOLD_HRS="${STOCKFORGE_DISPATCH_ROTATION_HRS:-12}"

# Kill switch: threshold=0 disables rotation entirely
if [ "$ROTATION_THRESHOLD_HRS" = "0" ]; then
  exit 0
fi

# Numeric validation
case "$ROTATION_THRESHOLD_HRS" in
  ''|*[!0-9]*) ROTATION_THRESHOLD_HRS=12 ;;
esac

THRESHOLD_SEC=$(( ROTATION_THRESHOLD_HRS * 3600 ))
NOW=$(date +%s 2>/dev/null || echo 0)
if [ "$NOW" -le 0 ]; then
  exit 0
fi
CUTOFF=$(( NOW - THRESHOLD_SEC ))

if [ ! -d "$JSONL_DIR" ]; then
  exit 0
fi

ROTATED=0
ROTATED_LIST=""
for f in "$JSONL_DIR"/.dispatch-pending-*.jsonl; do
  if [ ! -f "$f" ]; then
    continue
  fi
  mtime=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  if [ "$mtime" -lt "$CUTOFF" ] 2>/dev/null; then
    if [ ! -d "$ARCHIVE_DIR" ]; then
      mkdir -p "$ARCHIVE_DIR" 2>/dev/null || continue
    fi
    bn=$(basename "$f")
    if mv "$f" "$ARCHIVE_DIR/$bn" 2>/dev/null; then
      ROTATED=$((ROTATED + 1))
      ROTATED_LIST="$ROTATED_LIST $bn"
    fi
  fi
done

if [ "$ROTATED" -gt 0 ]; then
  printf 'INFO: dispatch-pending-rotation archived %s stale ledger(s) > %sh to %s\n' \
    "$ROTATED" "$ROTATION_THRESHOLD_HRS" "$ARCHIVE_DIR" >&2
fi

exit 0
