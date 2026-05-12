#!/usr/bin/env bash
# settings-inline-env-prefix-detector.sh — L-S208-1 prevention.
# Stop hook. Scans .claude/settings.json for hook commands that use bash-style
# inline env-var-prefix `VAR=val command` syntax at the top of the command string.
# This pattern fails silently in Claude Code's Windows hook runtime (root cause of
# HH-1 + idle-escape + phase-status-coherence 2-day production dormancy at S208).
#
# Pattern detected: `"command":\s*"[A-Z_][A-Z_0-9]*=` — i.e. the command string
# STARTS with a `VAR=val` token. This does NOT match the corrective wrapper form
# `"command": "bash -c 'VAR=val command'"` because that starts with `bash`, not `VAR=`.
#
# WARN-only (exit 0); informational. Phase 3.5 / S212 deliverable. L-S208-1 promotion
# target hook-tier (charter-tier blocked by M-S173-1 deny → proposal-only).
# Per CLAUDE.md hard rule: hook ships with companion firing-test
# (scripts/hooks/firing-tests/settings-inline-env-prefix-detector-fire-test.sh).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory" 2>/dev/null || true
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
SETTINGS="$PROJECT_DIR/.claude/settings.json"
TS="$(date -Iseconds)"
NAME="settings-inline-env-prefix-detector"

[ ! -f "$SETTINGS" ] && { echo "[$TS] $NAME: SKIP settings.json-missing" >> "$HOOK_LOG"; exit 0; }

# Pattern: a command-string value that STARTS with bash-style inline env assignment.
# `[A-Z_][A-Z_0-9]*=` is a conservative match for env-var names (uppercase + underscore + digits, at least 1 char).
PATTERN='"command":[[:space:]]*"[A-Z_][A-Z_0-9]*='

VIOLATIONS=$(grep -nE "$PATTERN" "$SETTINGS" 2>/dev/null || true)
if [ -z "$VIOLATIONS" ]; then
  echo "[$TS] $NAME: state=GREEN violations=0" >> "$HOOK_LOG"
  exit 0
fi

# Count + emit
COUNT=$(printf '%s\n' "$VIOLATIONS" | wc -l | tr -d '[:space:]')
echo "[$TS] $NAME: state=WARN violations=$COUNT (L-S208-1 inline-env-prefix pattern in settings.json)" >> "$HOOK_LOG"

# Emit each violating line for context
while IFS= read -r line; do
  [ -z "$line" ] && continue
  echo "[$TS] $NAME:   $line" >> "$HOOK_LOG"
done <<< "$VIOLATIONS"

exit 0
