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
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE 'UP-[0-9]+' | sort -u); do
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
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE 'D-[0-9]+' | sort -u); do
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
if [ -f "$EXEC_FILE" ]; then
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE 'Track [0-9]+(\.[0-9]+[a-z]*(\.[0-9]+)?)?' | sort -u); do
    TRACK_NUM=$(printf '%s' "$ref" | sed 's/^Track //')
    DONE_LINE=$(grep -E "Track ${TRACK_NUM}.*(✅|DONE|done)" "$EXEC_FILE" 2>/dev/null | head -1 || true)
    if [ -n "$DONE_LINE" ]; then
      add_warning "- $ref is marked DONE in current-execution.md. If user wants amendments, surface what shipped before re-implementing."
    fi
  done
fi

# === S<N> session reference check (only flag if session log exists; means session closed) ===
SESSIONS_DIR="$PROJECT_DIR/agent-workspace/memory/sessions"
if [ -d "$SESSIONS_DIR" ]; then
  for ref in $(printf '%s' "$USER_PROMPT" | grep -oE '\bS[0-9]+\b' | sort -u); do
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
