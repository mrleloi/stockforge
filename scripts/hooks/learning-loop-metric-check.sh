#!/usr/bin/env bash
# learning-loop-metric-check.sh — soft-warn when a Karpathy framing artifact lacks a
# deterministic metric_function declaration. Implements L-S12-1 promotion target priority
# hook (cheapest enforcement per Q-E3 doctrine: hook>skill>charter).
#
# Wires: stop hook in .claude/settings.json (S13+ optional). Non-blocking (exit 0 always).
# Output: warnings to .session-hooks.log + per-violation note to NOTIF_DIR if any found.
# Phase 0 portability: bash + node-eval + POSIX only (per L-S11-1).
# L-S10-1: if/then/fi only; split-local.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOOP_DIR="$PROJECT_DIR/agent-workspace/learning-data/loop"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# Skip if directory missing or empty (no framings yet emitted = no violation possible).
if [ ! -d "$LOOP_DIR" ]; then
  exit 0
fi

VIOLATIONS=0
VIOLATION_LIST=""

if [ -d "$LOOP_DIR" ]; then
  while IFS= read -r -d '' file; do
    bn="$(basename "$file")"
    # Frontmatter is the first --- ... --- block; grep for the field within first 30 lines.
    head_block="$(head -n 30 "$file" 2>/dev/null || true)"
    metric_line=""
    metric_line="$(printf '%s\n' "$head_block" | grep -E '^metric_function:' | head -n 1 || true)"
    # Violation if line absent OR value is empty / null / "not-yet-authored" / placeholder.
    is_violation=0
    if [ -z "$metric_line" ]; then
      is_violation=1
    else
      val="$(printf '%s' "$metric_line" | sed 's/^metric_function:[[:space:]]*//' | sed 's/[[:space:]]*#.*$//' | sed 's/[[:space:]]*$//' | tr -d '"' | tr -d "'")"
      case "$val" in
        ""|null|none|tbd|TBD|"not-yet-authored"|"not yet authored")
          is_violation=1
          ;;
      esac
    fi
    if [ "$is_violation" -eq 1 ]; then
      VIOLATIONS=$(( VIOLATIONS + 1 ))
      VIOLATION_LIST="${VIOLATION_LIST}  - ${bn}: missing or placeholder metric_function field"$'\n'
    fi
  done < <(find "$LOOP_DIR" -name '*-experiment-frame.md' -type f -print0 2>/dev/null)
fi

# S318: fixed-name idempotent notification (per-fire timestamps are the notification-spam anti-pattern); cleared when violations resolve.
NOTIF_FILE="$NOTIF_DIR/loop-metric-check-warn.md"
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] learning-loop-metric-check WARN %d framing(s) without metric_function:\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"
  if [ -d "$NOTIF_DIR" ]; then
    {
      printf '# Learning-Loop Metric-Function Check — Warnings\n\n'
      printf 'Per L-S12-1 (agent-notes 2026-04-29): every Karpathy framing artifact MUST cite a deterministic metric function.\n\n'
      printf '%d framing artifact(s) lack a usable `metric_function:` field:\n\n' "$VIOLATIONS"
      printf '%s' "$VIOLATION_LIST"
      printf '\nFix: edit each frame to add `metric_function: <path-or-inline-name>` in frontmatter; reference the metric script at `scripts/hooks/metric-failure-mode-rate.sh` or sibling.\n'
    } > "$NOTIF_FILE" 2>/dev/null || true
  fi
else
  printf '[%s] learning-loop-metric-check OK (0 violations)\n' "$TS" >> "$LOG"
  rm -f "$NOTIF_FILE" 2>/dev/null || true
fi

exit 0
