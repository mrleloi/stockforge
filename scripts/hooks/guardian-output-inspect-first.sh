#!/usr/bin/env bash
# guardian-output-inspect-first.sh — PreToolUse soft-warn enforcing L-S200-1 + L-S201-1 doctrines.
#
# Origin: 2026-05-09 S203 promote-rule cycle Cluster A (proposal at
# agent-workspace/memory/observations/promote-rule-S202.md).
# Source rules: L-S200-1 (S200), L-S201-1 (S201), AP-24 (S200) — all explicitly
# name "hook (Check-N in bash-hook-lint.sh)" as promotion target with auto-detect=yes.
#
# Rule (L-S200-1 + L-S201-1 + AP-24):
#   When the agent is about to Edit/Write a hook script at scripts/hooks/<name>.sh,
#   AND that hook is flagged in the most-recent bash-hook-lint-warn notification,
#   the agent MUST first read the lint output + the flagged source code before
#   authoring the edit. Symptom of violation: 13-cycle phantom-chase S187..S199
#   when bash-hook-lint output named L-S108-1 root cause + fix at every Stop.
#
# Mechanism (S203 v1 — runtime advisory only; no Read-history check):
#   PreToolUse(Edit|Write) → extract file_path → if file_path matches
#   scripts/hooks/<name>.sh AND <name>.sh appears in latest bash-hook-lint-warn
#   notification's violation list → emit advisory to stderr (visible to agent).
#   Exit 0 always (soft-warn; AP-23 hook-tier == warning, not BLOCK; keeps
#   autonomous-full unobstructed).
#
# Future v2 enhancement (deferred per cheapest-by-RISK):
#   Add Read-history check via transcript_path JSONL grep — warn only if no
#   preceding Read on same file in last N tool calls. v1 always warns when
#   flagged file edited; v2 suppresses warning when Read already happened.
#
# Conformance: bash + POSIX per L-S11-1. Soft-warn via exit 0 + stderr.
# Logs decisions to .session-hooks.log per dispatch-jsonl-recorder pattern.

set -u
LOG="${CLAUDE_PROJECT_DIR:-.}/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="${CLAUDE_PROJECT_DIR:-.}/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || date)"

# Read stdin payload
PAYLOAD=$(cat 2>/dev/null || true)
[ -z "$PAYLOAD" ] && exit 0

# Extract tool_name + file_path via grep+sed (avoid jq dep per L-S11-1)
TOOL_NAME=$(printf '%s' "$PAYLOAD" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Only check Edit + Write tool calls
case "$TOOL_NAME" in
  Edit|Write) : ;;
  *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$PAYLOAD" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
[ -z "$FILE_PATH" ] && exit 0

# Normalize: convert backslashes to forward slashes; extract basename
NORM=$(printf '%s' "$FILE_PATH" | tr '\\' '/')
case "$NORM" in
  */scripts/hooks/*.sh|scripts/hooks/*.sh) : ;;
  *) exit 0 ;;
esac
BN="$(basename "$NORM")"

# Find the bash-hook-lint-warn notification (S318: fixed-name idempotent file — was per-fire timestamped)
LATEST_NOTIF=""
if [ -d "$NOTIF_DIR" ]; then
  LATEST_NOTIF=$(ls -t "$NOTIF_DIR"/bash-hook-lint-warn.md 2>/dev/null | head -1 || true)
fi
[ -z "$LATEST_NOTIF" ] && exit 0
[ ! -f "$LATEST_NOTIF" ] && exit 0

# Check if BN appears in the violation list (lines starting with `  - L-S` codes)
# NOTE on L-S53-2 lint advice (S203 ratification): grep `${BN}` is content-search of
# basename token in notification body where ${BN} appears mid-line per fix recipe;
# `^` anchor would NEVER match. WRONG advice from Check 8; ratify false-positive.
if grep -qE "^[[:space:]]*-[[:space:]]*L-S[0-9]+.*: ${BN} —" "$LATEST_NOTIF" 2>/dev/null; then
  # Extract violation codes for this file (informational)
  CODES=$(grep -E "^[[:space:]]*-[[:space:]]*L-S[0-9]+.*: ${BN} —" "$LATEST_NOTIF" 2>/dev/null \
    | sed -nE 's/^[[:space:]]*-[[:space:]]*([A-Z0-9-]+):.*/\1/p' \
    | sort -u | tr '\n' ',' | sed 's/,$//' || true)
  NOTIF_BN=$(basename "$LATEST_NOTIF")
  printf '[%s] guardian-output-inspect-first: WARN edit=%s flagged_in=%s codes=%s\n' \
    "$TS" "$BN" "$NOTIF_BN" "$CODES" >> "$LOG" 2>/dev/null || true
  cat >&2 <<EOF
guardian-output-inspect-first ADVISORY (L-S200-1 + L-S201-1 + AP-24):

  tool: $TOOL_NAME
  target: scripts/hooks/$BN
  flagged_in: human-workspace/notifications/$NOTIF_BN
  codes: $CODES

This hook script is flagged in the most-recent bash-hook-lint output. Per L-S200-1
(inspect Guardian output BEFORE LLM hypothesis cycle) + L-S201-1 (Guardians need
calibration too — verify Guardian claim against ground-truth code BEFORE acting):

  1. Read human-workspace/notifications/$NOTIF_BN to see exact line:detail.
  2. Read scripts/hooks/$BN to verify the flag against ground-truth code (Guardian
     regex itself can have false positives — e.g. S201 Check 6b BUCKET fix +
     S202 Check 8 ratification whitelist).
  3. Then proceed with the Edit/Write — OR if Guardian flag is itself a false
     positive, calibrate the Guardian (lint check) instead of mass-fixing source.

Soft-warn only (exit 0). Not blocking. AP-23 hook-tier doctrine.
EOF
fi

exit 0
