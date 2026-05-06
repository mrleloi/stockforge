#!/usr/bin/env bash
# cost-ledger-recorder.sh — append-only USD cost ledger per session + subagent dispatch
# Hooks: Stop + SubagentStop
# Per S65 user request "tracking cost real not estimate"; per I-S1 NO LLM math (awk does compute, not LLM)
#
# Schema (cost-ledger.tsv):
#   timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event
#
# Pricing table (USD per MTok; Anthropic public 2025-2026):
#   opus    $15 input / $75 output
#   sonnet  $3 input / $15 output
#   haiku   $0.80 input / $4 output
#   cache_read = 10% of input price; cache_create = 125% of input price (standard caching tier)

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LEDGER="$PROJECT_DIR/agent-workspace/memory/cost-ledger.tsv"
PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit 0

# Parse hook payload
eval "$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try {
    const p=JSON.parse(s),q=v=>JSON.stringify(String(v||''));
    console.log('HOOK_EVENT='+q(p.hook_event_name));
    console.log('SESSION_ID='+q(p.session_id));
    console.log('SUBAGENT_TYPE='+q((p.tool_input&&p.tool_input.subagent_type)||''));
    console.log('TRANSCRIPT_PATH='+q(p.transcript_path));
  } catch { console.log('HOOK_EVENT=\"\"'); }
});" 2>/dev/null || echo 'HOOK_EVENT=""')"

[ "${HOOK_EVENT:-}" = "Stop" ] || [ "${HOOK_EVENT:-}" = "SubagentStop" ] || exit 0
[ -n "${TRANSCRIPT_PATH:-}" ] && [ -f "${TRANSCRIPT_PATH}" ] || exit 0

# Extract tokens from transcript JSONL (best-effort; tokens recorded in message.usage)
eval "$(node -e "
const fs=require('fs');
const path=process.argv[1];
let in_tot=0, out_tot=0, cache_read=0, cache_create=0, model='unknown';
try {
  const lines=fs.readFileSync(path,'utf8').split('\n').filter(l=>l.trim());
  for (const line of lines) {
    try {
      const obj=JSON.parse(line);
      const u = (obj.message && obj.message.usage) || obj.usage;
      if (u) {
        in_tot += (u.input_tokens||0);
        out_tot += (u.output_tokens||0);
        cache_read += (u.cache_read_input_tokens||0);
        cache_create += (u.cache_creation_input_tokens||0);
      }
      const m = (obj.message && obj.message.model) || obj.model;
      if (m && model==='unknown') model = m;
    } catch {}
  }
} catch {}
let mfam='unknown';
if (typeof model === 'string') {
  if (model.includes('opus')) mfam='opus';
  else if (model.includes('sonnet')) mfam='sonnet';
  else if (model.includes('haiku')) mfam='haiku';
}
console.log('TOKENS_IN='+in_tot);
console.log('TOKENS_OUT='+out_tot);
console.log('CACHE_READ='+cache_read);
console.log('CACHE_CREATE='+cache_create);
console.log('MODEL='+mfam);
" "$TRANSCRIPT_PATH" 2>/dev/null || echo 'TOKENS_IN=0
TOKENS_OUT=0
CACHE_READ=0
CACHE_CREATE=0
MODEL=unknown')"

# Skip if no token data (transcript empty or unparseable)
TOTAL_TOKENS=$(( ${TOKENS_IN:-0} + ${TOKENS_OUT:-0} + ${CACHE_READ:-0} + ${CACHE_CREATE:-0} ))
[ "$TOTAL_TOKENS" -gt 0 ] || exit 0

# Pricing per MTok (case statement; portable bash 3+)
case "${MODEL:-unknown}" in
  opus)    PIN=15;     POUT=75 ;;
  sonnet)  PIN=3;      POUT=15 ;;
  haiku)   PIN=0.80;   POUT=4 ;;
  *)       PIN=10;     POUT=50 ;;  # fallback
esac

# Cost computation (awk; deterministic; cache tiers per Anthropic standard)
# cache_read = 10% of input price; cache_create = 125% of input price
COST_USD="$(awk -v ti="${TOKENS_IN:-0}" -v to="${TOKENS_OUT:-0}" \
                -v cr="${CACHE_READ:-0}" -v cc="${CACHE_CREATE:-0}" \
                -v pi="$PIN" -v po="$POUT" \
  'BEGIN{
    base = (ti*pi + to*po + cr*pi*0.10 + cc*pi*1.25) / 1000000.0;
    printf "%.6f", base;
  }')"

# Determine actor
case "${HOOK_EVENT}" in
  Stop)         ACTOR="main" ;;
  SubagentStop) ACTOR="sub:${SUBAGENT_TYPE:-unknown}" ;;
  *)            ACTOR="unknown" ;;
esac

# Initialize ledger with header if missing
if [ ! -f "$LEDGER" ]; then
  mkdir -p "$(dirname "$LEDGER")"
  printf 'timestamp\tsession_id\tactor\tmodel\ttokens_in\ttokens_out\tcache_read\tcache_create\tcost_usd\thook_event\n' > "$LEDGER"
fi

TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$TS" "${SESSION_ID:-unknown}" "$ACTOR" "${MODEL:-unknown}" \
  "${TOKENS_IN:-0}" "${TOKENS_OUT:-0}" "${CACHE_READ:-0}" "${CACHE_CREATE:-0}" \
  "$COST_USD" "${HOOK_EVENT:-unknown}" >> "$LEDGER"

exit 0
