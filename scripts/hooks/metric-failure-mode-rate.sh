#!/usr/bin/env bash
# metric-failure-mode-rate.sh — compute count(events.failure_mode != null) / count(events)
# over learning-data/events/*.ndjson. Per S12 Karpathy framing (loop/20260429T131608Z-experiment-frame.md)
# falsification clause; baseline 0/60=0.0% (S11 corpus); target ≥8.3% on next ≥60-event corpus.
# Phase 0: bash + node only (L-S11-1 portability — NO python3 at hook level).
# CLI: ./metric-failure-mode-rate.sh [--quiet] [--window N]
#   --window N     measure over the most-recent N events only (chronologically by file mtime + line order).
#                  Default: cumulative over all events. Per L-S13-2 cumulative-vs-windowed distinction.
# Output: stdout summary + JSON file at learning-data/index/metrics-<TS>.json.
# Boundary: reads events/ via hook permission scope (harness-shell exempt from main-session deny).
# L-S10-1 patterns: if/then/fi only; split-local; defensive integer validation.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EVENTS_DIR="$PROJECT_DIR/agent-workspace/learning-data/events"
INDEX_DIR="$PROJECT_DIR/agent-workspace/learning-data/index"
TS_FILE="$(date -u +%Y%m%dT%H%M%SZ 2>/dev/null || echo unknown)"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"
OUT_FILE="$INDEX_DIR/metrics-${TS_FILE}.json"
QUIET=0
WINDOW=0
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1 ;;
    --window)
      shift
      if [ $# -gt 0 ] && [[ "${1:-}" =~ ^[0-9]+$ ]]; then
        WINDOW="$1"
      else
        printf 'metric-failure-mode-rate: --window requires a positive integer\n' >&2
        exit 0
      fi
      ;;
    *) ;;
  esac
  shift || true
done

mkdir -p "$INDEX_DIR" 2>/dev/null || true

# Aggregate counts via node-eval (single pass over concatenated NDJSON stream).
# When --window N set, slice the most recent N lines after concatenation
# (files concatenated in mtime order so the tail is most recent).
RESULT='{"total":0,"with_fm":0,"rate":0,"dist":{}}'
if [ -d "$EVENTS_DIR" ]; then
  CONCAT_CMD="find \"$EVENTS_DIR\" -name '*.ndjson' -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | awk '{print \$2}' | xargs cat 2>/dev/null"
  if [ "$WINDOW" -gt 0 ]; then
    CONCAT_CMD="$CONCAT_CMD | tail -n $WINDOW"
  fi
  RESULT="$(eval "$CONCAT_CMD" | \
    node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  const lines=s.split('\n').filter(Boolean);
  let total=0, with_fm=0;
  const dist={};
  for (const line of lines) {
    try {
      const o=JSON.parse(line);
      total++;
      const fm = (o && o.payload && o.payload.failure_mode);
      if (fm !== null && fm !== undefined && fm !== 'null') {
        with_fm++;
        const k = String(fm);
        dist[k] = (dist[k]||0) + 1;
      }
    } catch {}
  }
  const rate = total > 0 ? (with_fm / total) : 0;
  console.log(JSON.stringify({total, with_fm, rate, dist}));
});" 2>/dev/null)"
  if [ -z "$RESULT" ]; then
    RESULT='{"total":0,"with_fm":0,"rate":0,"dist":{}}'
  fi
fi

# Compose output file with metric metadata.
MODE="cumulative"
if [ "$WINDOW" -gt 0 ]; then
  MODE="windowed:$WINDOW"
fi
{
  printf '{"as_of":"%s","metric":"failure_mode_populated_rate","mode":"%s","formula":"count(events.failure_mode != null) / count(events)","baseline":{"s11":"0/60=0.0%%","measured_at":"2026-04-29"},"target":{"s12_plus_1":">= 0.083"},"measurement":' "$TS" "$MODE"
  printf '%s' "$RESULT"
  printf '}\n'
} > "$OUT_FILE" 2>/dev/null

if [ "$QUIET" -ne 1 ]; then
  TOTAL_HUMAN="$(printf '%s' "$RESULT" | node -e "let s='';process.stdin.on('data',c=>s+=c);process.stdin.on('end',()=>{try{const o=JSON.parse(s);console.log(o.total||0);}catch{console.log(0);}});" 2>/dev/null || echo 0)"
  WITH_HUMAN="$(printf '%s' "$RESULT" | node -e "let s='';process.stdin.on('data',c=>s+=c);process.stdin.on('end',()=>{try{const o=JSON.parse(s);console.log(o.with_fm||0);}catch{console.log(0);}});" 2>/dev/null || echo 0)"
  RATE_HUMAN="$(printf '%s' "$RESULT" | node -e "let s='';process.stdin.on('data',c=>s+=c);process.stdin.on('end',()=>{try{const o=JSON.parse(s);console.log(((o.rate||0)*100).toFixed(2));}catch{console.log('0.00');}});" 2>/dev/null || echo 0.00)"
  DIST_HUMAN="$(printf '%s' "$RESULT" | node -e "let s='';process.stdin.on('data',c=>s+=c);process.stdin.on('end',()=>{try{const o=JSON.parse(s);console.log(JSON.stringify(o.dist||{}));}catch{console.log('{}');}});" 2>/dev/null || echo '{}')"
  printf 'metric-failure-mode-rate @ %s\n' "$TS"
  printf '  mode:            %s\n' "$MODE"
  printf '  total events:    %s\n' "$TOTAL_HUMAN"
  printf '  with failure_mode: %s\n' "$WITH_HUMAN"
  printf '  rate:            %s%% (target ≥ 8.30%%; baseline S11 = 0.00%%)\n' "$RATE_HUMAN"
  printf '  distribution:    %s\n' "$DIST_HUMAN"
  printf '  output:          %s\n' "$OUT_FILE"
fi

exit 0
