#!/usr/bin/env bash
# subagent-budget-classifier.sh — S35 D4 (per L-S25-1 architect-overshoot calibration).
# Reads dispatch prompt header; classifies subagent kind (architect-spec-frame / architect-pure-plan / verifier / general);
# soft-warns on overshoot vs envelope.
#
# Envelopes (calibrated):
#   architect-spec-frame  : 150-200K (extends to 220K acceptable; >220K = warn)
#   architect-pure-plan   : 60-80K   (warn at 100K+)
#   verifier-whole-phase  : 80-150K  (per L-S21-1 calibrated)
#   verifier-sub-track    : 60-80K
#   general-purpose       : 80K (default)
#
# Wire as PostToolUse hook on Agent tool calls.
set -euo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG="$PROJECT_DIR/agent-workspace/memory/.subagent-budget.log"
mkdir -p "$(dirname "$LOG")"

# Read JSON payload from stdin.
PAYLOAD=$(cat)
PROMPT=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const o=JSON.parse(s); console.log((o.tool_input&&o.tool_input.prompt)||''); } catch { console.log(''); } });" 2>/dev/null || true)
TOKENS=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const o=JSON.parse(s); const u=(o.tool_response&&o.tool_response.usage)||{}; console.log((u.input_tokens||0)+(u.cache_read_input_tokens||0)+(u.cache_creation_input_tokens||0)); } catch { console.log(0); } });" 2>/dev/null || echo 0)

[ -z "$PROMPT" ] && exit 0
[ "${TOKENS:-0}" = "0" ] && exit 0

# Classify by keyword grep.
KIND="general-purpose"
ENV_TARGET=80000
ENV_WARN=100000

if echo "$PROMPT" | grep -qiE 'spec-author|spec frame|drill-me|glossary|ubiquitous-language'; then
  KIND="architect-spec-frame"
  ENV_TARGET=200000
  ENV_WARN=220000
elif echo "$PROMPT" | grep -qiE 'master-plan|session plan|architect|track sequencing'; then
  KIND="architect-pure-plan"
  ENV_TARGET=80000
  ENV_WARN=100000
elif echo "$PROMPT" | grep -qiE 'verifier|sandwich-verifier|whole.?phase|10 V dim'; then
  if echo "$PROMPT" | grep -qiE 'whole.?phase|all.{0,15}files|44 files|Phase [12] close'; then
    KIND="verifier-whole-phase"
    ENV_TARGET=150000
    ENV_WARN=180000
  else
    KIND="verifier-sub-track"
    ENV_TARGET=80000
    ENV_WARN=100000
  fi
fi

OVERSHOOT_PCT=$(( TOKENS * 100 / ENV_TARGET ))

printf '[%s] subagent classified=%s tokens=%s target=%s overshoot=%s%%\n' \
  "$(date -Iseconds)" "$KIND" "$TOKENS" "$ENV_TARGET" "$OVERSHOOT_PCT" >> "$LOG"

if [ "$TOKENS" -ge "$ENV_WARN" ]; then
  echo "subagent-budget WARN: ${KIND} ran ${TOKENS} tokens (envelope ${ENV_TARGET}, warn ${ENV_WARN}); ${OVERSHOOT_PCT}% of target." >&2
fi

exit 0
