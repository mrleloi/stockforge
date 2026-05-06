#!/usr/bin/env bash
# correction-rate-tracker.sh — UserPromptSubmit hook detecting user-correction patterns.
# Created S7 (2026-04-29) per D-004 § Tracking Instrumentation (Q2=A commitment).
# Logs JSONL to agent-workspace/memory/.correction-rate.log; aggregator at session-end
# (Stop hook) summarizes correction count per 50K-bucket. Feeds Q4=A empirical
# re-evaluation of context-threshold band after 10 sessions of new-band data.
# Non-blocking — does NOT modify prompt or block submit. Pure telemetry.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="$PROJECT_DIR/agent-workspace/memory/.correction-rate.log"
TOKENS_FILE="$PROJECT_DIR/agent-workspace/memory/.transcript-tokens"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PAYLOAD="$(cat 2>/dev/null || true)"
USER_PROMPT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).prompt || JSON.parse(s).user_message || ''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

[ -z "$USER_PROMPT" ] && exit 0

# Vietnamese correction patterns (case-insensitive, word-boundary-ish via grep -E)
VI_PATTERNS='không phải|sai rồi|sai mất|đâu phải|không đúng|chưa đúng|ngừng|dừng|đừng|không nên|tại sao'
# English correction patterns
EN_PATTERNS='\bno\b|\bwrong\b|incorrect|\bstop\b|don.?t|\brevert\b|\bundo\b|that.?s not'

PROMPT_LOWER="$(printf '%s' "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')"

MATCHED_VI=""
MATCHED_EN=""
if printf '%s' "$PROMPT_LOWER" | grep -qE "$VI_PATTERNS" 2>/dev/null; then
  MATCHED_VI=$(printf '%s' "$PROMPT_LOWER" | grep -oE "$VI_PATTERNS" 2>/dev/null | head -3 | tr '\n' '|' | sed 's/|$//' || true)
fi
if printf '%s' "$PROMPT_LOWER" | grep -qE "$EN_PATTERNS" 2>/dev/null; then
  MATCHED_EN=$(printf '%s' "$PROMPT_LOWER" | grep -oE "$EN_PATTERNS" 2>/dev/null | head -3 | tr '\n' '|' | sed 's/|$//' || true)
fi

[ -z "$MATCHED_VI" ] && [ -z "$MATCHED_EN" ] && exit 0

# Read current transcript token count for bucket assignment
TOKENS=0
if [ -f "$TOKENS_FILE" ]; then
  TOKENS=$(awk 'NR==1 {print $1+0; exit}' "$TOKENS_FILE" 2>/dev/null || echo 0)
fi
BUCKET_50K=$(awk -v t="$TOKENS" 'BEGIN { printf "%d", int(t/50000)*50000 }')

# Hash prompt head (40 chars) for de-dup tracking without storing full text
PROMPT_HASH=$(printf '%s' "$USER_PROMPT" | head -c 200 | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  const crypto=require('crypto');
  process.stdout.write(crypto.createHash('sha256').update(s).digest('hex').slice(0,12));
});" 2>/dev/null || echo "nohash")

TS=$(date -Iseconds)
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

# Build JSONL line
node -e "
const obj = {
  ts: process.argv[1],
  session_id: process.argv[2],
  tokens_at_correction: parseInt(process.argv[3], 10),
  bucket_50k: parseInt(process.argv[4], 10),
  prompt_hash: process.argv[5],
  prompt_len: parseInt(process.argv[6], 10),
  matched_vi: process.argv[7] || null,
  matched_en: process.argv[8] || null
};
process.stdout.write(JSON.stringify(obj) + '\n');
" "$TS" "$SESSION_ID" "$TOKENS" "$BUCKET_50K" "$PROMPT_HASH" "${#USER_PROMPT}" "$MATCHED_VI" "$MATCHED_EN" \
  >> "$LOG_FILE" 2>/dev/null || true

echo "[$TS] correction-rate-tracker: matched (vi=$MATCHED_VI en=$MATCHED_EN) tokens=$TOKENS bucket=$BUCKET_50K" >> "$HOOK_LOG"
exit 0
