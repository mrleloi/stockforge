#!/usr/bin/env bash
# correction-rate-aggregator.sh — Stop hook aggregating .correction-rate.log per session.
# Created S8 (2026-04-29) per D-004 § Tracking Instrumentation Q2=A + S7 carry-over.
# Reads JSONL from correction-rate-tracker.sh, summarizes per-session bucket counts,
# appends digest line to .correction-rate-digest.log. Feeds Q4=A empirical
# re-evaluation of context-threshold band after N=10 sessions accumulate.
# Non-blocking; safe-by-default; runs at every Stop event.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_FILE="$PROJECT_DIR/agent-workspace/memory/.correction-rate.log"
DIGEST_FILE="$PROJECT_DIR/agent-workspace/memory/.correction-rate-digest.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

mkdir -p "$PROJECT_DIR/agent-workspace/memory"

TS=$(date -Iseconds)
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

# If log file doesn't exist or is empty, emit empty digest + exit
if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
  echo "[$TS] correction-rate-aggregator: no log entries (file empty or missing); skip" >> "$HOOK_LOG"
  exit 0
fi

# Aggregate via node — read all lines, group by session_id + bucket_50k.
# For current session: emit per-bucket counts.
# For all-sessions: emit total session count + total correction count.
DIGEST_JSON=$(node -e "
const fs = require('fs');
const path = process.argv[1];
const sessionId = process.argv[2];
const ts = process.argv[3];

let lines;
try { lines = fs.readFileSync(path, 'utf8').split('\n').filter(l => l.trim()); }
catch (e) { console.log('{}'); process.exit(0); }

const all = [];
for (const ln of lines) {
  try { all.push(JSON.parse(ln)); } catch { /* skip malformed */ }
}

// Per-session-id bucket counts for THIS session
const thisSession = all.filter(o => o.session_id === sessionId);
const bucketCounts = {};
for (const o of thisSession) {
  const b = String(o.bucket_50k || 0);
  bucketCounts[b] = (bucketCounts[b] || 0) + 1;
}

// All-sessions summary
const sessionSet = new Set(all.map(o => o.session_id || 'unknown'));
const totalCorrections = all.length;

const digest = {
  ts: ts,
  session_id: sessionId,
  this_session_corrections: thisSession.length,
  this_session_by_bucket_50k: bucketCounts,
  all_sessions_total_count: totalCorrections,
  all_sessions_distinct_count: sessionSet.size,
  d_004_n10_progress: \`\${sessionSet.size}/10\`
};
process.stdout.write(JSON.stringify(digest));
" "$LOG_FILE" "$SESSION_ID" "$TS" 2>/dev/null || echo "{}")

# Append digest line to digest log
echo "$DIGEST_JSON" >> "$DIGEST_FILE"

# Emit human-readable summary to hook log
SUMMARY=$(printf '%s' "$DIGEST_JSON" | node -e "
let s=''; process.stdin.on('data', c => s += c);
process.stdin.on('end', () => {
  try {
    const o = JSON.parse(s);
    const buckets = Object.entries(o.this_session_by_bucket_50k || {})
      .map(([k,v]) => k+':'+v).join(' ');
    process.stdout.write(\`this=\${o.this_session_corrections} buckets=[\${buckets}] all_sessions=\${o.all_sessions_distinct_count} progress=\${o.d_004_n10_progress}\`);
  } catch { process.stdout.write('parse_error'); }
});" 2>/dev/null || echo "summary_error")

echo "[$TS] correction-rate-aggregator: $SUMMARY" >> "$HOOK_LOG"
exit 0
