#!/usr/bin/env bash
# promotion-cycle-trigger.sh — S35 D4 META-fix (per L-S35-1 / BP-S35-1 / decision-discipline Rule 4a draft).
# Fires `promote-rule` subagent dispatch reminder when:
#   (a) ≥5 sessions passed since last `agent-workspace/memory/observations/promote-rule-S*.md`, OR
#   (b) Phase boundary detected (current-execution.md `Phase` field changed since last run).
# Hard-block at 8 sessions / phase-cross without promotion observation.
#
# Wire as Stop hook in .claude/settings.json once L-S11-1 portability check (Phase 0 = bash+POSIX) passes.
# Output goes to stderr + drift-log; non-zero exit only at hard-block.
set -euo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
LOG="$PROJECT_DIR/agent-workspace/memory/.promotion-cycle.log"
mkdir -p "$(dirname "$LOG")"

[ ! -f "$EXEC_FILE" ] && exit 0

# Latest session number — scoped to ## SXX section headers (per L-S51-1 fix at S51).
# Prior bug (M-S51-1): grepped for `**Session N**:` literal which never appears in current-execution.md
# (file uses `## S50 — ...` header format). LATEST_SESSION was always 0; SESSION_DELTA was always
# negative; hard-block + soft-warn rules never escalated despite 20+ fires/day.
# Real format: `## S<NN>[a-z]? — <title>` headers (e.g. `## S50 — Phase 3.5 master-plan authored`,
# `## S49b — Tier 1 archive sweep`). Also handle subordinate variants (S49a, S49b, S50-pre).
LATEST_SESSION=$(grep -oE '^## S[0-9]+' "$EXEC_FILE" | grep -oE '[0-9]+' | sort -n | tail -1 || echo 0)
[ -z "$LATEST_SESSION" ] && LATEST_SESSION=0

# Latest phase number.
LATEST_PHASE=$(grep -oE '\*\*Phase\*\*: [0-9]+' "$EXEC_FILE" | head -1 | grep -oE '[0-9]+' || echo 0)

# Find latest promote-rule observation file.
LAST_PROMOTE_FILE=$(ls -t "$OBS_DIR"/promote-rule-S*.md 2>/dev/null | head -1 || true)
LAST_PROMOTE_SESSION=0
LAST_PROMOTE_PHASE=0
if [ -n "$LAST_PROMOTE_FILE" ]; then
  # NOTE on L-S53-2 lint advice (S56 categorization, KI-S55-1 family):
  #   bash-hook-lint Check 8 flags `grep -oE 'S[0-9]+'` here as unanchored
  #   positional-marker → suggests `^` anchor. WRONG advice for THIS line: target
  #   is `basename "$LAST_PROMOTE_FILE"` which yields strings like "promote-rule-S52.md"
  #   where `S<N>` appears mid-string after the "promote-rule-" prefix. Anchoring
  #   `^S[0-9]+` would NEVER match (filename starts with `p`). Categorization:
  #   content-search of filename token (NOT header-parse). Per L-S55-1 retrofit
  #   recipe: ratify false-positive via this comment. Lint flag persists in surface
  #   log (acceptable per soft-warn surface).
  LAST_PROMOTE_SESSION=$(basename "$LAST_PROMOTE_FILE" | grep -oE 'S[0-9]+' | tr -d 'S' || echo 0)
  LAST_PROMOTE_PHASE=$(grep -oE 'phase: [0-9]+' "$LAST_PROMOTE_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' || echo 0)
fi

SESSION_DELTA=$((LATEST_SESSION - LAST_PROMOTE_SESSION))
PHASE_CHANGED=0
[ "$LATEST_PHASE" -gt "$LAST_PROMOTE_PHASE" ] && PHASE_CHANGED=1

printf '[%s] promotion-cycle-trigger: latest_session=%s last_promote=S%s delta=%s latest_phase=%s last_phase=%s phase_changed=%s\n' \
  "$(date -Iseconds)" "$LATEST_SESSION" "$LAST_PROMOTE_SESSION" "$SESSION_DELTA" "$LATEST_PHASE" "$LAST_PROMOTE_PHASE" "$PHASE_CHANGED" >> "$LOG"

# Hard-block: ≥8 sessions OR phase-changed without promote.
if [ "$SESSION_DELTA" -ge 8 ] || { [ "$PHASE_CHANGED" -eq 1 ] && [ "$SESSION_DELTA" -ge 1 ]; }; then
  printf '[%s] HARD-BLOCK promotion-cycle: delta=%s phase_changed=%s\n' \
    "$(date -Iseconds)" "$SESSION_DELTA" "$PHASE_CHANGED" >> "$LOG"
  echo "promotion-cycle HARD-BLOCK: ≥8 sessions OR phase boundary crossed without promote-rule run. Dispatch promote-rule subagent before next session-end." >&2
  exit 0  # non-blocking; advisory only — hard-block via Stop-hook decision JSON in v2
fi

# Soft-warn: ≥5 sessions.
if [ "$SESSION_DELTA" -ge 5 ]; then
  printf '[%s] SOFT-WARN promotion-cycle: delta=%s — recommend running promote-rule subagent\n' \
    "$(date -Iseconds)" "$SESSION_DELTA" >> "$LOG"
  echo "promotion-cycle SOFT-WARN: ${SESSION_DELTA} sessions since last promote-rule run; recommend dispatching subagent." >&2
fi

exit 0
