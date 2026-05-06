#!/usr/bin/env bash
# checkpoint-marker-cleanup-resume.sh — SessionStart cleanup + autonomous-resume surfacing.
#
# Companion to:
# - `checkpoint-write-marker.sh` (PostToolUse — sets markers)
# - `checkpoint-write-end-turn-watchdog.sh` (PreToolUse — denies subsequent tools)
#
# Two responsibilities at SessionStart:
#
# 1) CLEANUP: delete stale `.checkpoint-written-<session_id>` markers from any
#    session OTHER than the current one. Without cleanup, an old marker would
#    block tool calls in this session until manually removed.
#
# 2) AUTONOMOUS RESUME SURFACING: if a `.fresh-resume-pending-<session_id>`
#    marker exists from a prior session AND `autonomous_mode=true` in
#    current-execution.md, emit a system-reminder to stdout that surfaces the
#    prior checkpoint's `next_action` to this session's LLM. The LLM should
#    then proceed with the next_action without re-asking — this replaces the
#    revoked Mode-D SendKeys "continue" mechanism (Rule 2 honored: NO
#    auto-typing of "continue" into the TUI).
#
# After surfacing, the resume marker is deleted to prevent re-firing.
#
# If autonomous_mode is FALSE, resume markers are still cleaned up but no
# system-reminder is emitted — user picks up at their leisure.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
EXEC_FILE="$MEM_DIR/current-execution.md"

mkdir -p "$MEM_DIR"

CURRENT_SID="${CLAUDE_SESSION_ID:-unknown}"
TS="$(date -Iseconds)"

# 1) CLEANUP — delete stale .checkpoint-written-* markers from other sessions
CLEANED=0
for f in "$MEM_DIR"/.checkpoint-written-*; do
  [ -e "$f" ] || continue
  fbase=$(basename "$f")
  fsid=${fbase#.checkpoint-written-}
  if [ "$fsid" != "$CURRENT_SID" ]; then
    rm -f "$f"
    CLEANED=$((CLEANED + 1))
  fi
done

if [ "$CLEANED" -gt 0 ]; then
  echo "[$TS] checkpoint-marker-cleanup: cleaned=$CLEANED stale markers (current=$CURRENT_SID)" >> "$LOG"
fi

# 2) AUTONOMOUS RESUME SURFACING — check for .fresh-resume-pending-* markers
AUTONOMOUS=false
if [ -f "$EXEC_FILE" ] && grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then
  AUTONOMOUS=true
fi

RESUME_FOUND=0
RESUME_EXCERPT=""
RESUME_PRIOR_SID=""

for f in "$MEM_DIR"/.fresh-resume-pending-*; do
  [ -e "$f" ] || continue
  fbase=$(basename "$f")
  fsid=${fbase#.fresh-resume-pending-}

  # Only consider markers from OTHER sessions (a marker for current session would be self-referential)
  if [ "$fsid" = "$CURRENT_SID" ]; then
    continue
  fi

  # Capture details before delete
  if [ "$RESUME_FOUND" = "0" ]; then
    RESUME_PRIOR_SID="$fsid"
    RESUME_EXCERPT=$(grep '^next_action_excerpt=' "$f" 2>/dev/null | head -1 | sed 's/^next_action_excerpt=//' | head -c 800 || true)
    RESUME_FOUND=1
  fi

  rm -f "$f"
done

if [ "$RESUME_FOUND" = "1" ]; then
  echo "[$TS] checkpoint-marker-cleanup-resume: resume-pending consumed prior_sid=$RESUME_PRIOR_SID autonomous=$AUTONOMOUS" >> "$LOG"

  if [ "$AUTONOMOUS" = "true" ]; then
    # Emit system-reminder to stdout (SessionStart hook stdout is injected as additional context)
    cat <<EOF

[checkpoint-marker-cleanup-resume] AUTONOMOUS RESUME PENDING — prior session ${RESUME_PRIOR_SID} ended at checkpoint write per L-S49b-4. autonomous_mode=true is active.

The prior session's checkpoint records a next_action that you (this session's LLM) should proceed with WITHOUT asking the user "should I continue?" — that's the AskUserQuestion anti-pattern user has flagged before.

Excerpt from \`agent-workspace/memory/checkpoints/latest.md\`:
${RESUME_EXCERPT}

Standard SessionStart reads still apply: read full checkpoint + current-execution.md + relevant spec. Then proceed with the announced next_action. If you genuinely need to ask user (SCOPE/CHARTER tier only per autonomous-protocol), do so; otherwise, just execute.

This marker has been consumed and deleted. Do NOT re-emit on subsequent SessionStart.
EOF
  else
    echo "[$TS] checkpoint-marker-cleanup-resume: autonomous=false — resume marker deleted silently, no surfacing" >> "$LOG"
  fi
fi

exit 0
