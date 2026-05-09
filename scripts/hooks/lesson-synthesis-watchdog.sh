#!/usr/bin/env bash
# lesson-synthesis-watchdog.sh — Stage 2 of self-upgrade loop (BP-S43b-4 / KI-S43b-5).
#
# Detects sessions that touched production code without appending ≥1 lesson entry
# to known-issues.md / best-practices.md / agent-notes.md. STRICT mode (S43e D-026
# Rule 4b ratification): exit 2 on dormancy detection branch — auto-clears once
# next session writes a qualifying KI/BP/agent-notes entry. Loop finite: ≤1
# hard-block per episode.
#
# Bash + POSIX only per L-S11-1.
# Stop hook (priority 2 — after self-awareness-aggregate, before promotion-cycle).
# Decision basis: KI-S43b-5 (9-session dormant loop) + BP-S43b-4 promotion target.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
SA_DIR="$MEM_DIR/self-awareness"
LOG="$MEM_DIR/.lesson-synthesis.log"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
TS="$(date -Iseconds)"

mkdir -p "$(dirname "$LOG")"

# Scope: count files touched in production tree (staged + unstaged + untracked).
# git status --short gives one line per touched file regardless of state.
PROD_TOUCHED=$(cd "$PROJECT_DIR" && git status --short -- packages/ apps/ 2>/dev/null | wc -l | tr -d '[:space:]')
[[ "$PROD_TOUCHED" =~ ^[0-9]+$ ]] || PROD_TOUCHED=0

# Threshold: if 0 files touched, no lesson expected
if [ "$PROD_TOUCHED" -lt 1 ]; then
  printf '[%s] lesson-synthesis-watchdog: prod_touched=%s files (under threshold; skip)\n' \
    "$TS" "$PROD_TOUCHED" >> "$LOG"
  exit 0
fi

# Were any of the lesson-target files updated in last 24h?
# L-S68 fix: guard find with [ -f ] check; bare find on non-existent path errors under pipefail
# (find non-zero + pipe to wc → pipefail propagates → ERR trap → silent exit 0). Caught in D6 dogfood.
KI_RECENT=0
if [ -f "$SA_DIR/known-issues.md" ]; then
  KI_RECENT=$(find "$SA_DIR/known-issues.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
fi
BP_RECENT=0
if [ -f "$SA_DIR/best-practices.md" ]; then
  BP_RECENT=$(find "$SA_DIR/best-practices.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
fi
NOTES_RECENT=0
if [ -f "$MEM_DIR/agent-notes.md" ]; then
  NOTES_RECENT=$(find "$MEM_DIR/agent-notes.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
fi

LESSON_TOTAL=$(( KI_RECENT + BP_RECENT + NOTES_RECENT ))

printf '[%s] lesson-synthesis-watchdog: prod_touched=%s ki_recent=%s bp_recent=%s notes_recent=%s\n' \
  "$TS" "$PROD_TOUCHED" "$KI_RECENT" "$BP_RECENT" "$NOTES_RECENT" >> "$LOG"

if [ "$LESSON_TOTAL" -eq 0 ]; then
  ALERT="lesson-synthesis-watchdog STRICT-ALERT (D-026 Rule 4b): production files touched = $PROD_TOUCHED but ZERO lesson entries (KI/BP/agent-notes) updated in last 24h. Self-upgrade loop Stage 2 dormant. Per Rule 4b, append ≥1 entry before next /clear OR record \`lesson_synthesis: NA-no-triggers\` in session log if exempt. AUTOMATED PATH: dispatch \`lesson-synthesizer\` subagent (.claude/agents/lesson-synthesizer.md) to extract patterns from session diff + write the entry; re-running this watchdog after dispatch will clear the alert."
  printf '[%s] %s\n' "$TS" "$ALERT" >> "$LOG"
  printf '[%s] lesson-synthesis-watchdog: STRICT-ALERT prod_touched=%s lessons=0\n' "$TS" "$PROD_TOUCHED" >> "$HOOK_LOG"
  echo "$ALERT" >&2

  # Plan 011 D6: enqueue async lesson-synthesizer dispatch job (priority 2 — high; runs before profile-render).
  # Kill switch: MEMORY_ETL_DISABLE=1. Failure here is non-fatal (still exit 2 below).
  ETL_QUEUE_DIR="$MEM_DIR/etl-queue"
  if [ "${MEMORY_ETL_DISABLE:-0}" != "1" ]; then
    if mkdir -p "$ETL_QUEUE_DIR" 2>/dev/null; then
      ETL_TS="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
      ETL_JOB="$ETL_QUEUE_DIR/2-${ETL_TS}-lesson-synthesize.job"
      {
        printf -- '---\n'
        printf 'task: lesson-synthesize\n'
        printf 'payload: {"prod_touched":%s,"trigger":"dormancy"}\n' "$PROD_TOUCHED"
        printf 'created_at: %s\n' "$TS"
        printf 'producer: lesson-synthesis-watchdog.sh\n'
        printf -- '---\n'
      } > "$ETL_JOB" 2>/dev/null || true
    fi
  fi

  exit 2
fi

exit 0
