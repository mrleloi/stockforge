#!/usr/bin/env bash
# stale-prompt-detector.sh — UserPromptSubmit hook detecting "stale-prompt vs current-state" mismatch.
# Created S7 (2026-04-29) per UP-07 follow-up RCA: post-/clear user prompts may reference work
# already CLOSED in checkpoint state (e.g., "continue UP-07" when UP-07 closed-by-D-004 in S6).
# Without this hook the agent re-fires AskUserQuestion to clarify, blocking autonomous flow.
# Hook is NON-BLOCKING: only injects additionalContext warning. Agent decides action.
# Wired as UserPromptSubmit in .claude/settings.local.json (after invariants-injector).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
INTAKE_LOG="$PROJECT_DIR/agent-workspace/memory/up-intake-log.md"
DECISIONS_DIR="$PROJECT_DIR/agent-workspace/memory/decisions"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PAYLOAD="$(cat 2>/dev/null || true)"
USER_PROMPT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).prompt || JSON.parse(s).user_message || ''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

# Skip on empty / trivial prompts.
if [ -z "$USER_PROMPT" ]; then exit 0; fi
if printf '%s' "$USER_PROMPT" | head -c 40 | grep -qiE '^[[:space:]]*(continue|ok|yes|y|n|no|done)[[:space:]]*$'; then
  exit 0
fi

WARNINGS=""

add_warning() {
  if [ -z "$WARNINGS" ]; then
    WARNINGS="$1"
  else
    WARNINGS="$WARNINGS
$1"
  fi
}

# === UP-NN reference check ===
if [ -f "$INTAKE_LOG" ]; then
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE 'UP-[0-9]+' | sort -u || true); do
    STATUS=$(awk -v ref="$ref" '
      $0 ~ "up_id: " ref "$" { in_entry=1; next }
      in_entry && /^- up_id:/ { in_entry=0 }
      in_entry && /^[[:space:]]*status:/ { gsub(/^[[:space:]]*status:[[:space:]]*/,""); print; exit }
    ' "$INTAKE_LOG" 2>/dev/null || true)
    if [ -n "$STATUS" ] && printf '%s' "$STATUS" | grep -qE '^closed-'; then
      add_warning "- $ref is CLOSED ($STATUS per up-intake-log.md). If user wants to revisit, treat as new scope; otherwise surface closure status (cite the linked decision) before re-doing work."
    fi
  done
fi

# === D-NNN reference check ===
if [ -d "$DECISIONS_DIR" ]; then
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE 'D-[0-9]+' | sort -u || true); do
    NUM=$(printf '%s' "$ref" | sed 's/D-0*//; s/^$/0/')
    NUM_PADDED=$(printf '%03d' "$NUM" 2>/dev/null || echo "$NUM")
    DEC_FILE=$(ls "$DECISIONS_DIR"/${NUM_PADDED}-*.md 2>/dev/null | head -1 || true)
    if [ -n "$DEC_FILE" ]; then
      DEC_STATUS=$(awk '/^status:/ { gsub(/^status:[[:space:]]*/,""); print; exit }' "$DEC_FILE" 2>/dev/null || true)
      if printf '%s' "$DEC_STATUS" | grep -qiE '^(ACCEPTED|SUPERSEDED|REJECTED)$'; then
        add_warning "- $ref already in terminal status ($DEC_STATUS per $DEC_FILE). Re-opening requires explicit user pick + new ADR (D-NNN+1 superseding) — do not silently re-decide."
      fi
    fi
  done
fi

# === Track N(.Nx) reference check ===
# NOTE on L-S53-2 lint advice (S56 categorization, KI-S55-1 family):
#   bash-hook-lint Check 8 flags `grep -oE 'Track [0-9]+...'` here as unanchored
#   positional-marker → suggests `^` anchor. WRONG advice: target is `$USER_PROMPT`
#   piped variable holding free-form user input where "Track 5" can appear anywhere.
#   Anchoring `^Track [0-9]+` would only match prompts STARTING with "Track <N>"
#   (e.g. user types "remind me about Track 5" → mid-prompt → anchored grep
#   misses). Categorization: content-search of user-input text (NOT header-parse).
#   Per L-S55-1: ratify false-positive via this comment.
#
# NOTE on for-loop word-splitting (S56 firing-test catch; L-S52-3 SUCCESS path):
#   Track refs like "Track 7" contain an internal space — `for ref in $(...)`
#   under default IFS would split into "Track" + "7" (separate iterations,
#   broken warning text). Use while-read with IFS= to preserve the full match.
#   Sibling UP-NN + D-NNN + S<N> loops below are safe because matched tokens
#   have no internal whitespace (hyphenated or single word).
if [ -f "$EXEC_FILE" ]; then
  while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    TRACK_NUM=$(printf '%s' "$ref" | sed 's/^Track //')
    DONE_LINE=$(grep -E "Track ${TRACK_NUM}.*(✅|DONE|done)" "$EXEC_FILE" 2>/dev/null | head -1 || true)
    if [ -n "$DONE_LINE" ]; then
      add_warning "- $ref is marked DONE in current-execution.md. If user wants amendments, surface what shipped before re-implementing."
    fi
  done < <(printf '%s' "$USER_PROMPT" | grep -oE 'Track [0-9]+(\.[0-9]+[a-z]*(\.[0-9]+)?)?' | sort -u || true)
fi

# === S<N> session reference check (only flag if session log exists; means session closed) ===
# NOTE on L-S53-2 lint advice (S56 categorization, KI-S55-1 family):
#   bash-hook-lint Check 8 flags `grep -oE '\bS[0-9]+\b'` here as unanchored
#   positional-marker → suggests `^` anchor. WRONG advice: target is `$USER_PROMPT`
#   user-input where "S52" can appear mid-prompt. The `\b` word boundary IS the
#   correct content-search anchor mechanism for token detection inside free-form
#   text (analogous role to `^` for line-anchored structured docs). Categorization:
#   content-search of user-input text (NOT header-parse). Per L-S55-1: ratify
#   false-positive via this comment; existing `\b` boundary is the right mechanism.
SESSIONS_DIR="$PROJECT_DIR/agent-workspace/memory/sessions"
if [ -d "$SESSIONS_DIR" ]; then
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE '\bS[0-9]+\b' | sort -u || true); do
    SNUM=$(printf '%s' "$ref" | sed 's/^S//')
    LOG_EXISTS=$(ls "$SESSIONS_DIR"/*-session-${SNUM}*.md 2>/dev/null | head -1 || true)
    if [ -n "$LOG_EXISTS" ]; then
      add_warning "- $ref has a session log ($LOG_EXISTS) — session closed. If user wants to amend its outputs, surface what shipped first."
    fi
  done
fi

# === Emit additionalContext if any warnings ===
if [ -n "$WARNINGS" ]; then
  WARN_BLOCK="STALE-PROMPT DETECTOR (auto-injected; deterministic hook):
The user's prompt references work items that appear CLOSED in current state. Before acting:
$WARNINGS

Recommendation: Briefly surface the closure status (1-2 sentences citing the decision/session) before doing any action. If user picks 'redo' explicitly, then proceed with new work. Per UP-06 NO-Silent-Default rule + UP-07 follow-up RCA."

  node -e "
const ctx = process.argv[1];
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'UserPromptSubmit',
    additionalContext: ctx
  }
}));
" "$WARN_BLOCK" 2>/dev/null || true

  echo "[$(date -Iseconds)] stale-prompt-detector: WARNING emitted for prompt (refs detected)" >> "$HOOK_LOG"
else
  echo "[$(date -Iseconds)] stale-prompt-detector: clean (no stale refs)" >> "$HOOK_LOG"
fi

exit 0
