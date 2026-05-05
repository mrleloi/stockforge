#!/usr/bin/env bash
# jaccard-helper.sh — deterministic Phase 1+2 of promote-rule skill.
# Reads agent-notes.md, extracts rules, computes pairwise Jaccard similarity,
# clusters via connected components, emits JSON.
# Usage: bash jaccard-helper.sh [threshold] [min-cluster-size]
# Defaults: threshold=0.7 min-cluster-size=3
# Output: stdout JSON with clusters list. STDERR for trace.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
AGENT_NOTES="$PROJECT_DIR/agent-workspace/memory/agent-notes.md"
THRESHOLD="${1:-0.7}"
MIN_SIZE="${2:-3}"

if [ ! -f "$AGENT_NOTES" ]; then
  echo '{"error":"agent-notes.md not found"}' && exit 1
fi

# Extract rule headers (line_no:title) + bodies; pipe to node for clustering.
node -e "
const fs = require('fs');
const path = process.argv[1];
const threshold = parseFloat(process.argv[2]);
const minSize = parseInt(process.argv[3], 10);

const text = fs.readFileSync(path, 'utf8');
const lines = text.split('\n');

// Extract rules: every '### ' header opens a rule; body is until next '### ' or EOF.
const rules = [];
let cur = null;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].startsWith('### ')) {
    if (cur) rules.push(cur);
    cur = { line: i + 1, title: lines[i].slice(4).trim(), body: [] };
  } else if (cur) {
    cur.body.push(lines[i]);
  }
}
if (cur) rules.push(cur);

// Tokenize: split on /\W+/, filter length>=4, lowercase, dedupe.
const tokenize = (text) => {
  const toks = text.toLowerCase().split(/\W+/).filter(t => t.length >= 4);
  return new Set(toks);
};

const tokenSets = rules.map(r => ({ ...r, tokens: tokenize(r.title + ' ' + r.body.join(' ')) }));

// Pairwise Jaccard.
const jaccard = (a, b) => {
  let inter = 0;
  for (const t of a) if (b.has(t)) inter++;
  const union = a.size + b.size - inter;
  return union === 0 ? 0 : inter / union;
};

// Edges where sim >= threshold.
const edges = [];
for (let i = 0; i < tokenSets.length; i++) {
  for (let j = i + 1; j < tokenSets.length; j++) {
    const sim = jaccard(tokenSets[i].tokens, tokenSets[j].tokens);
    if (sim >= threshold) edges.push([i, j, sim]);
  }
}

// Connected components.
const parent = Array.from({ length: tokenSets.length }, (_, i) => i);
const find = (x) => { while (parent[x] !== x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; };
const union = (a, b) => { const ra = find(a), rb = find(b); if (ra !== rb) parent[ra] = rb; };
for (const [i, j] of edges) union(i, j);

const groups = new Map();
for (let i = 0; i < tokenSets.length; i++) {
  const r = find(i);
  if (!groups.has(r)) groups.set(r, []);
  groups.get(r).push(i);
}

// Filter clusters by min size; sort by total internal similarity desc.
const clusters = [...groups.values()]
  .filter(idxs => idxs.length >= minSize)
  .map(idxs => {
    let totalSim = 0, pairCount = 0;
    for (let i = 0; i < idxs.length; i++) {
      for (let j = i + 1; j < idxs.length; j++) {
        const sim = jaccard(tokenSets[idxs[i]].tokens, tokenSets[idxs[j]].tokens);
        totalSim += sim; pairCount++;
      }
    }
    const avgSim = pairCount > 0 ? totalSim / pairCount : 0;
    return {
      size: idxs.length,
      avg_sim: Number(avgSim.toFixed(3)),
      total_sim: Number(totalSim.toFixed(3)),
      members: idxs.map(i => ({ line: tokenSets[i].line, title: tokenSets[i].title, body_chars: tokenSets[i].body.join(' ').length }))
    };
  })
  .sort((a, b) => b.total_sim - a.total_sim);

const out = {
  threshold,
  min_cluster_size: minSize,
  total_rules: rules.length,
  total_edges: edges.length,
  cluster_count: clusters.length,
  clusters
};
console.log(JSON.stringify(out, null, 2));
" "$AGENT_NOTES" "$THRESHOLD" "$MIN_SIZE"
