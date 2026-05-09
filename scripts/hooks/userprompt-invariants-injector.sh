#!/usr/bin/env bash
# userprompt-invariants-injector.sh — UserPromptSubmit hook prepending stockforge invariants
# reminder before each user prompt reaches the LLM.
# Wired as UserPromptSubmit in .claude/settings.json. Adds 5-line I-S1/I-S2/I-S3 reminder
# via additionalContext (won't appear in transcript as user-typed text).
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

# Skip injection if user prompt is trivial (continue / ok / help / etc.) — saves context.
PAYLOAD="$(cat 2>/dev/null || true)"
USER_PROMPT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).prompt || JSON.parse(s).user_message || ''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

# Trim + lowercase first 80 chars for trivial detection.
PROMPT_HEAD="$(printf '%s' "$USER_PROMPT" | head -c 80 | tr '[:upper:]' '[:lower:]' | sed 's/^ *//;s/ *$//')"
TRIVIAL_REGEX='^(continue|ok|ok rồi\.? *continue|ok continue|yes|y|n|no|tiếp|skip|next|done)$'
if [ -n "$PROMPT_HEAD" ] && printf '%s' "$PROMPT_HEAD" | grep -qE "$TRIVIAL_REGEX"; then
  echo "[$(date -Iseconds)] UserPromptSubmit-injector: SKIP (trivial prompt detected)" >> "$HOOK_LOG"
  # S186 D-043 — emit minimal hookSpecificOutput JSON on SKIP path so Windows
  # UserPromptSubmit hook chain advances past this hook (S185 hypothesis: stdout
  # JSON emission is required for chain continuation on Claude Code Windows).
  node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true
  exit 0
fi

# Emit hookSpecificOutput with invariants reminder.
REMINDER="STOCKFORGE INVARIANTS REMINDER (auto-injected, do not echo back):
- I-S1: NO LLM math. Every number from deterministic Python tool call. LLM only interprets.
- I-S2: Every claim cites source + as_of date. No silent picks; show source disagreement.
- I-S3: Position sizing / risk management is deterministic code, not LLM judgment.
- I-S10: Thesis must include bear case (≥3 specific evidence-grounded points).
- I-S35: Frame as research aid (\"thesis exploration\"), never \"buy/sell/recommendation\".
For full list: agent-workspace/constitution/invariants.md."

node -e "
const reminder = process.argv[1];
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'UserPromptSubmit',
    additionalContext: reminder
  }
}));
" "$REMINDER" 2>/dev/null || true

echo "[$(date -Iseconds)] UserPromptSubmit-injector: invariants reminder injected (prompt_len=${#USER_PROMPT})" >> "$HOOK_LOG"
exit 0
