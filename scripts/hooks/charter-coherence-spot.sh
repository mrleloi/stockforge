#!/usr/bin/env bash
# charter-coherence-spot.sh — greps for charter-incoherent language in recent agent outputs.
# Detects: "buy/sell/recommend" without "thesis exploration" framing (violates I-S35);
# LLM-output numerics without code-source citation; financial-advice phrasing.
# Adapted from orch scripts/verify/charter_coherence_spot_check.* (A-6 in borrow-list).
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.charter-coherence-violations.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

# Files to audit: recent thesis-log, agent outputs, anything claiming to be advice.
TARGETS="$(find "$PROJECT_DIR/agent-workspace/memory/thesis-log" \
                "$PROJECT_DIR/agent-workspace/memory/observations" \
                "$PROJECT_DIR/specs" \
            -type f -name '*.md' -mmin -120 2>/dev/null | head -30)"
[ -z "$TARGETS" ] && exit 0

VIOLATIONS=0

while IFS= read -r f; do
  [ -z "$f" ] || [ ! -f "$f" ] && continue
  # I-S35: charter framing — "buy" / "sell" / "recommend" / "should invest" must coexist with
  # "thesis exploration" / "consideration" / "research aid" framing.
  if grep -qiE '\b(buy this|sell this|should buy|should sell|recommend.{0,20}(stock|share|invest)|definitely (buy|sell)|guaranteed return)\b' "$f" 2>/dev/null; then
    if ! grep -qiE '(thesis exploration|research aid|consideration|not financial advice|not advice)' "$f" 2>/dev/null; then
      VIOLATIONS=$(( VIOLATIONS + 1 ))
      printf '[%s] I-S35-VIOLATION (advice-without-aid-framing) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
    fi
  fi
  # I-S1: bare percentages outside code blocks claiming to be analysis output.
  if grep -qiE '(my analysis|i (calculated|computed|estimate|think))[^.]*[0-9]+%' "$f" 2>/dev/null; then
    VIOLATIONS=$(( VIOLATIONS + 1 ))
    printf '[%s] I-S1-VIOLATION (LLM-self-claim-of-computation) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
  fi
  # Insider information signal: "insider" / "leaked" / "private channel" — flag for review.
  if grep -qiE '\b(insider info|leaked from|private channel|paid leak|confidential source)\b' "$f" 2>/dev/null; then
    VIOLATIONS=$(( VIOLATIONS + 1 ))
    printf '[%s] CHARTER-VIOLATION (insider-info-signal) file=%s\n' "$(date -Iseconds)" "$f" >> "$LOG"
  fi
done <<< "$TARGETS"

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "[$(date -Iseconds)] charter-coherence-spot: $VIOLATIONS violation(s) — see $LOG" >> "$HOOK_LOG"
  printf '[charter-coherence] WARN: %d charter-incoherent pattern(s) detected. See %s\n' "$VIOLATIONS" "$LOG" >&2
fi

exit 0
