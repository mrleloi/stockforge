#!/usr/bin/env bash
# sync-tracker-render.sh — Track 8a Confidence Score System render hook
# Per D-006 (IMPL-S17-1): bash+awk only; no python/jq/yq/sqlite3 (L-S11-1 portability).
#
# Reads state.tsv + events.tsv + weights.yaml; generates _index.md (human-readable view).
# Idempotent — safe to re-run; output is deterministic given inputs.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SYNC_DIR="$ROOT_DIR/agent-workspace/memory/sync-tracker"
EVENTS="$SYNC_DIR/events.tsv"
STATE="$SYNC_DIR/state.tsv"
WEIGHTS="$SYNC_DIR/weights.yaml"
INDEX="$SYNC_DIR/_index.md"

get_weight() { awk -F': *' -v key="$1" '$1==key {print $2; exit}' "$WEIGHTS"; }

T_CHARTER="$(get_weight threshold_CHARTER)"
T_SCOPE="$(get_weight threshold_SCOPE)"
T_ARCH="$(get_weight threshold_ARCH)"
T_IMPL="$(get_weight threshold_IMPL)"

T_HIGH="$(get_weight tier_HIGH)"
T_MED_HIGH="$(get_weight tier_MED_HIGH)"
T_MED="$(get_weight tier_MED)"
T_MED_LOW="$(get_weight tier_MED_LOW)"

# Render
RENDER_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
{
  cat <<MD
# Confidence Score Index — sync-tracker

> **Auto-generated** by \`scripts/hooks/sync-tracker-render.sh\`. Do NOT edit by hand.
> **Last rendered**: $RENDER_TS
> **Source**: D-006 (Track 8a) + Charter Principle 8 (Calibration over confidence)
> **Storage**: bash+TSV flat-file MVP per IMPL-S17-1; SQLite migration deferred Phase 1+

## Current State (5 categories)

| Category | Score | Tier | Sample Count | Last Updated | Must-Grill Remaining |
|---|---|---|---|---|---|
MD

  # Render category rows with tier mapping inline
  awk -F'\t' -v th="$T_HIGH" -v tmh="$T_MED_HIGH" -v tm="$T_MED" -v tml="$T_MED_LOW" '
NR==1 { next }
{
  score = $2 + 0;
  if (score >= th)        tier = "🟢 HIGH-CONFIDENCE  (≥0.90 hit-rate)";
  else if (score >= tmh)  tier = "🟢 MED-HIGH         (0.70-0.89)";
  else if (score >= tm)   tier = "🟡 MED              (0.50-0.69)";
  else if (score >= tml)  tier = "🟠 MED-LOW          (0.30-0.49)";
  else                    tier = "🔴 MUST-GRILL       (<0.30)";
  printf "| %s | %g | %s | %d | %s | %d |\n", $1, score, tier, $3, $4, $5;
}
' "$STATE"

  cat <<MD

## Decision-Class Thresholds

| Decision class | Threshold | Action when current_score < threshold |
|---|---|---|
| CHARTER | $T_CHARTER | MUST grill via AskUserQuestion (charter-tier letter pick) |
| SCOPE | $T_SCOPE | MUST grill via AskUserQuestion |
| ARCH | $T_ARCH | SHOULD grill; if self-decide, double-cite source_evidence |
| IMPL | $T_IMPL | OK to self-decide; subject to drift audit |

> Threshold check: \`current_score >= threshold\` → safe to self-decide. Below → grill.

## Recent Events (top 10 newest)

| ts | category | event_type | delta | decision_id | reason |
|---|---|---|---|---|---|
MD

  # Render top-10 events from events.tsv (most recent first)
  awk -F'\t' '
NR==1 { next }
{
  printf "| %s | %s | %s | %s | %s | %s |\n", $1, $2, $3, $4, $5, $7;
}
' "$EVENTS" | tail -n 10

  cat <<MD

## How to use

- **Before SCOPE+ decision**: invoke \`sync-pull\` skill OR check this file's category row.
- **If category score below decision-class threshold**: MUST grill (AskUserQuestion).
- **If \`Must-Grill Remaining\` > 0**: forced grill regardless of score (reversal protocol per Q&A A6).
- **Weights tunable**: edit \`weights.yaml\`; re-run \`sync-tracker-update.sh\` with any event to recompute.

## Source schema

- Categories (5): LANGUAGE / DOMAIN_UBIQUITOUS / DESIGN_THINKING / SCOPE / DECISION_ROUTING
- Tier boundaries: see \`weights.yaml\` (\`tier_*\` keys)
- Asymmetric weights: see \`weights.yaml\` (\`weight_*\` keys; positive = earned confidence; negative = correction debt)

See \`README.md\` for full schema; \`D-006\` for design rationale.
MD
} > "$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"

exit 0
