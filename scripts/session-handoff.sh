#!/usr/bin/env bash
# session-handoff.sh — spawn fresh Claude Code session that resumes current stockforge work.
# Ported from orch v2.2.0; adapted bootstrap text + STOCKFORGE_* env rename + ORCH_* fallback.
#
# Usage:
#   ./scripts/session-handoff.sh                          # latest checkpoint
#   ./scripts/session-handoff.sh <slug>                   # checkpoint matching slug
#   STOCKFORGE_HEADLESS=1 ./scripts/session-handoff.sh    # autonomous via -p mode
#   STOCKFORGE_CCS_PROFILE=work ./scripts/session-handoff.sh   # route through ccs profile

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKPOINT_DIR="$PROJECT_DIR/agent-workspace/memory/checkpoints"

# STOCKFORGE_* preferred; ORCH_* fallback for migration.
HEADLESS="${STOCKFORGE_HEADLESS:-${ORCH_HEADLESS:-0}}"
CCS_PROFILE="${STOCKFORGE_CCS_PROFILE:-${ORCH_CCS_PROFILE:-}}"
RC_NAME_OVERRIDE="${STOCKFORGE_RC_NAME:-${ORCH_RC_NAME:-}}"

if [ $# -ge 1 ]; then
  CHECKPOINT=$(ls -t "$CHECKPOINT_DIR"/*"$1"*.md 2>/dev/null | head -1)
else
  CHECKPOINT=$(ls -t "$CHECKPOINT_DIR"/*.md 2>/dev/null | grep -v 'latest\.md$' | head -1)
fi

if [ -z "${CHECKPOINT:-}" ] || [ ! -f "$CHECKPOINT" ]; then
  # Fall back to latest.md when no timestamped checkpoint exists yet.
  if [ -f "$CHECKPOINT_DIR/latest.md" ]; then
    CHECKPOINT="$CHECKPOINT_DIR/latest.md"
  else
    echo "[ERROR] No checkpoint found in $CHECKPOINT_DIR" >&2
    exit 1
  fi
fi

echo "[INFO] Resuming from checkpoint: $(basename "$CHECKPOINT")"

BOOTSTRAP="You are Claude (Opus 4.7) resuming a STOCKFORGE execution session.

STEP 1 — read these files in order before any other action:
- $CHECKPOINT    (handoff checkpoint — current phase/track/next-action)
- $PROJECT_DIR/CLAUDE.md    (project instructions: NO LLM math, source+as_of citations, deterministic risk, adversarial-by-default)
- $PROJECT_DIR/PROJECT_CHARTER.md    (immutable invariants I-S1..I-S35)
- $PROJECT_DIR/agent-workspace/memory/current-execution.md    (routing + active phase/track)
- $PROJECT_DIR/agent-workspace/memory/observations/queued-grill-master.md (check fire_when triggers)

STEP 2 — honor stockforge hard rules (CLAUDE.md):
- Domain layer ZERO framework dependency (pure Python in packages/domain/)
- Cross-BC communication via contracts only
- VBW Protocol mandatory before specs/tests/code
- Never edit obsidian-vault/raw/ or PROJECT_CHARTER.md without explicit approval
- Agents MUST NOT git commit unless user requests
- User prompt overrides ALL defaults
- For Agent dispatches: run_in_background=true (when subagent has no return-value dependency)
- At YOUR ~200K self-track mark: write checkpoint to agent-workspace/memory/checkpoints/, update latest.md, then invoke 'STOCKFORGE_HEADLESS=1 scripts/session-handoff.sh' BEFORE ending turn — chains autonomous loop
- Never commit; stage only

STEP 3 — resume at checkpoint's next_action. Continue task loop until phase complete OR your own 200K mark (checkpoint + self-handoff) OR real STOP condition.

Begin now."

RC_NAME="${RC_NAME_OVERRIDE:-stockforge-$(basename "$CHECKPOINT" .md)}"

unset CLAUDECODE  # so nested claude-from-claude spawn doesn't trip nested-session guard

cd "$PROJECT_DIR"

if [ "$HEADLESS" = "1" ]; then
  LOG_DIR="$PROJECT_DIR/agent-workspace/memory/handoff-logs"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/$(date +%Y%m%dT%H%M%SZ)-$RC_NAME.log"
  echo "[INFO] Headless handoff → $LOG_FILE"
  if [ -n "$CCS_PROFILE" ]; then
    exec ccs "$CCS_PROFILE" claude --rc "$RC_NAME" -p "$BOOTSTRAP" > "$LOG_FILE" 2>&1
  else
    exec claude --rc "$RC_NAME" -p "$BOOTSTRAP" > "$LOG_FILE" 2>&1
  fi
fi

if [ -n "$CCS_PROFILE" ]; then
  exec ccs "$CCS_PROFILE" claude --rc "$RC_NAME" "$BOOTSTRAP"
else
  exec claude --rc "$RC_NAME" "$BOOTSTRAP"
fi
