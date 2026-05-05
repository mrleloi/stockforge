#!/usr/bin/env bash
# taskcompleted-audit.sh — runs after task/subagent completion to grep changed files
# for I-S1 (LLM math) + I-S2 (missing citations) violations.
# Wired as Stop hook (poor man's TaskCompleted; Claude Code v2.x has no TaskCompleted event).
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.taskcompleted-audit.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

# Gather files changed in last hour (heuristic for "this turn's changes").
# Only audit thesis-log + specs + agent-workspace/memory data files.
CHANGED_FILES="$(find "$PROJECT_DIR/agent-workspace/memory/thesis-log" \
                       "$PROJECT_DIR/specs" \
                       "$PROJECT_DIR/agent-workspace/memory/decisions" \
                  -type f -name '*.md' -mmin -60 2>/dev/null | head -20)"

[ -z "$CHANGED_FILES" ] && exit 0

VIOLATIONS=0

# I-S1: LLM math anti-pattern — "approximately N", "around N", "roughly N", "N% confidence" without metadata.
while IFS= read -r f; do
  [ -z "$f" ] || [ ! -f "$f" ] && continue
  if grep -qiE '(approximately|roughly|around|circa)\s+[0-9]' "$f" 2>/dev/null; then
    VIOLATIONS=$(( VIOLATIONS + 1 ))
    printf '[%s] I-S1-VIOLATION (LLM-math anti-pattern) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
  fi
  # I-S1: confidence claim without n_samples / hit_rate / lookback metadata.
  if grep -qiE '[0-9]+%\s*confidence' "$f" 2>/dev/null; then
    if ! grep -qiE '(n_samples|hit_rate|lookback)' "$f" 2>/dev/null; then
      VIOLATIONS=$(( VIOLATIONS + 1 ))
      printf '[%s] I-S1-VIOLATION (confidence-without-calibration) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
    fi
  fi
  # I-S2: numeric values without source: / as_of: in same file.
  if grep -qE '[0-9]{2,}\.?[0-9]*\s*(%|VND|tỷ|billion)' "$f" 2>/dev/null; then
    if ! grep -qE '(source:|as[_ ]of:)' "$f" 2>/dev/null; then
      VIOLATIONS=$(( VIOLATIONS + 1 ))
      printf '[%s] I-S2-VIOLATION (numeric-no-citation) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
    fi
  fi
  # I-S10: thesis without bear case (only for thesis-log/).
  case "$f" in
    */thesis-log/*)
      if ! grep -qiE '(bear[_ ]case|risks?|downside)' "$f" 2>/dev/null; then
        VIOLATIONS=$(( VIOLATIONS + 1 ))
        printf '[%s] I-S10-VIOLATION (thesis-no-bear-case) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
      fi
      ;;
  esac
done <<< "$CHANGED_FILES"

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "[$(date -Iseconds)] taskcompleted-audit: $VIOLATIONS violation(s) found across recent files" >> "$HOOK_LOG"
fi

exit 0
