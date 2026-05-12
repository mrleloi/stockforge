#!/bin/bash
# Stop hook: detects hook scripts that write `.session-hooks.log` to project root
# instead of canonical `agent-workspace/memory/.session-hooks.log`.
#
# Anti-pattern: LOG="$ROOT_DIR/.session-hooks.log"     (writes to project root)
# Correct:      LOG="$MEM_DIR/.session-hooks.log"     (canonical memory dir)
#               LOG="$ROOT_DIR/agent-workspace/memory/.session-hooks.log"  (also OK; explicit)
#
# Origin: L-S214-1 (S214, 2026-05-09). Two hooks (self-awareness-aggregate.sh,
# sync-tracker-update.sh) silently wrote to project root for ~10 days, causing
# split log corpus + a near-miss false-bug-fix during S214 triage of HH-1 HIGH.
# Pairs with settings-inline-env-prefix-detector.sh (L-S208-1) — both are
# harness-portability invariant detectors.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
HOOKS_DIR="$PROJECT_DIR/scripts/hooks"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS=$(date -Iseconds)
SID="${CLAUDE_SESSION_ID:-unknown}"

[ -d "$HOOKS_DIR" ] || { echo "[$TS] hook-log-path-canonical-detector: SKIP=hooks-dir-missing session=$SID" >> "$LOG"; exit 0; }

# Match: assignment-line `LOG="$ROOT_DIR/.session-hooks.log"` (not a comment).
# Anchor `^[[:space:]]*LOG=` excludes doc-comments showing the anti-pattern.
PATTERN='^[[:space:]]*LOG="\$ROOT_DIR/\.session-hooks\.log"'
violations=$(grep -lE "$PATTERN" "$HOOKS_DIR"/*.sh 2>/dev/null | grep -v firing-tests | wc -l | tr -d ' ')

if [ "$violations" -gt 0 ]; then
  files=$(grep -lE "$PATTERN" "$HOOKS_DIR"/*.sh 2>/dev/null | grep -v firing-tests | xargs -I{} basename {} | tr '\n' ',' | sed 's/,$//')
  echo "[$TS] hook-log-path-canonical-detector: state=WARN violations=$violations files=$files session=$SID (L-S214-1)" >> "$LOG"
else
  echo "[$TS] hook-log-path-canonical-detector: state=GREEN violations=0 session=$SID" >> "$LOG"
fi

exit 0
