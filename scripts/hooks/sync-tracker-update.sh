#!/usr/bin/env bash
# sync-tracker-update.sh — Track 8a Confidence Score System update hook
# Per D-006 (IMPL-S17-1): bash+awk only; no python/jq/yq/sqlite3 (L-S11-1 portability).
#
# Usage:
#   sync-tracker-update.sh <category> <event_type> [<override_delta>] [<decision_id> [<source_evidence> [<reason>]]]
#
# If <override_delta> is empty/omitted, the hook looks up `weight_<event_type>` from weights.yaml.
# This preserves the tunable-weights contract: edit weights.yaml once, all callers pick up new values.
# Override mode is for testing or non-standard partial-credit events.
#
# Categories: LANGUAGE | DOMAIN_UBIQUITOUS | DESIGN_THINKING | SCOPE | DECISION_ROUTING
# Event types: decision_correctness | charter_match | q_and_a_resolution
#              drift_signal | decision_correction | decision_revocation | thesis_revocation
#
# Behavior:
#   1. Resolve delta from weights.yaml if not overridden.
#   2. Append event row to events.tsv (atomic append).
#   3. Recompute state.tsv from full events.tsv replay.
#   4. Decrement must_grill_remaining for the affected category if >0.
#   5. Call sync-tracker-render.sh to regenerate _index.md (best-effort; log if fails).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SYNC_DIR="$ROOT_DIR/agent-workspace/memory/sync-tracker"
EVENTS="$SYNC_DIR/events.tsv"
STATE="$SYNC_DIR/state.tsv"
WEIGHTS="$SYNC_DIR/weights.yaml"
RENDER_HOOK="$ROOT_DIR/scripts/hooks/sync-tracker-render.sh"
LOG="$ROOT_DIR/.session-hooks.log"

CAT="${1:-}"
EVT="${2:-}"
OVERRIDE_DELTA="${3:-}"
DEC_ID="${4:-}"
SOURCE_EV="${5:-}"
REASON="${6:-}"

if [[ -z "$CAT" || -z "$EVT" ]]; then
  echo "[sync-tracker-update] usage: $0 <category> <event_type> [<override_delta>] [<decision_id> [<source_evidence> [<reason>]]]" >&2
  exit 2
fi

# Validate category
case "$CAT" in
  LANGUAGE|DOMAIN_UBIQUITOUS|DESIGN_THINKING|SCOPE|DECISION_ROUTING) ;;
  *) echo "[sync-tracker-update] invalid category: $CAT" >&2; exit 2 ;;
esac

# Resolve delta: override CLI arg wins; else look up weight_<event_type> from weights.yaml.
get_weight() { awk -F': *' -v key="$1" '$1==key {print $2; exit}' "$WEIGHTS"; }
if [[ -n "$OVERRIDE_DELTA" ]]; then
  DELTA="$OVERRIDE_DELTA"
else
  DELTA="$(get_weight "weight_$EVT")"
  if [[ -z "$DELTA" ]]; then
    echo "[sync-tracker-update] no weight defined for event_type=$EVT; pass override_delta or add weight_$EVT to weights.yaml" >&2
    exit 2
  fi
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Append event (TSV; tab-separated; replace tabs in fields with spaces to keep single line)
sanitize() { printf '%s' "${1:-}" | tr '\t\n' '  '; }
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$TS" "$CAT" "$EVT" "$DELTA" \
  "$(sanitize "$DEC_ID")" "$(sanitize "$SOURCE_EV")" "$(sanitize "$REASON")" \
  >> "$EVENTS"

# --- Recompute state.tsv ---
# Read initial scores from weights.yaml (category_<NAME>: <int>)
INIT_LANG="$(get_weight category_LANGUAGE)"
INIT_DOM="$(get_weight category_DOMAIN_UBIQUITOUS)"
INIT_DES="$(get_weight category_DESIGN_THINKING)"
INIT_SCO="$(get_weight category_SCOPE)"
INIT_DEC="$(get_weight category_DECISION_ROUTING)"

# Preserve must_grill_remaining from existing state.tsv (so decrement persists across runs)
get_grill() { awk -F'\t' -v cat="$1" 'NR>1 && $1==cat {print $5; exit}' "$STATE"; }
GRILL_LANG="$(get_grill LANGUAGE)"; GRILL_LANG="${GRILL_LANG:-0}"
GRILL_DOM="$(get_grill DOMAIN_UBIQUITOUS)"; GRILL_DOM="${GRILL_DOM:-0}"
GRILL_DES="$(get_grill DESIGN_THINKING)"; GRILL_DES="${GRILL_DES:-0}"
GRILL_SCO="$(get_grill SCOPE)"; GRILL_SCO="${GRILL_SCO:-0}"
GRILL_DEC="$(get_grill DECISION_ROUTING)"; GRILL_DEC="${GRILL_DEC:-0}"

# Reversal protocol: revocation events set must_grill_remaining=5
RVC="$(get_weight reversal_must_grill_cycles)"; RVC="${RVC:-5}"
case "$EVT" in
  decision_revocation|thesis_revocation)
    case "$CAT" in
      LANGUAGE) GRILL_LANG="$RVC" ;;
      DOMAIN_UBIQUITOUS) GRILL_DOM="$RVC" ;;
      DESIGN_THINKING) GRILL_DES="$RVC" ;;
      SCOPE) GRILL_SCO="$RVC" ;;
      DECISION_ROUTING) GRILL_DEC="$RVC" ;;
    esac
    ;;
esac

# Replay events.tsv to compute current scores + sample counts + last_updated_ts.
awk -F'\t' -v il="$INIT_LANG" -v id="$INIT_DOM" -v ie="$INIT_DES" -v is="$INIT_SCO" -v ir="$INIT_DEC" \
    -v gl="$GRILL_LANG" -v gd="$GRILL_DOM" -v ge="$GRILL_DES" -v gs="$GRILL_SCO" -v gr="$GRILL_DEC" '
BEGIN {
  s["LANGUAGE"]=il; s["DOMAIN_UBIQUITOUS"]=id; s["DESIGN_THINKING"]=ie; s["SCOPE"]=is; s["DECISION_ROUTING"]=ir;
  c["LANGUAGE"]=0; c["DOMAIN_UBIQUITOUS"]=0; c["DESIGN_THINKING"]=0; c["SCOPE"]=0; c["DECISION_ROUTING"]=0;
  t["LANGUAGE"]="1970-01-01T00:00:00Z"; t["DOMAIN_UBIQUITOUS"]="1970-01-01T00:00:00Z";
  t["DESIGN_THINKING"]="1970-01-01T00:00:00Z"; t["SCOPE"]="1970-01-01T00:00:00Z";
  t["DECISION_ROUTING"]="1970-01-01T00:00:00Z";
  g["LANGUAGE"]=gl; g["DOMAIN_UBIQUITOUS"]=gd; g["DESIGN_THINKING"]=ge; g["SCOPE"]=gs; g["DECISION_ROUTING"]=gr;
  cats="LANGUAGE DOMAIN_UBIQUITOUS DESIGN_THINKING SCOPE DECISION_ROUTING";
}
NR==1 { next }  # skip header
$2 in s {
  s[$2] += $4 + 0;
  if (s[$2] < 0) s[$2] = 0;
  if (s[$2] > 100) s[$2] = 100;
  c[$2] += 1;
  if ($1 > t[$2]) t[$2] = $1;
}
END {
  print "category\tcurrent_score\tsample_count\tlast_updated_ts\tmust_grill_remaining";
  n=split(cats, arr, " ");
  for (i=1; i<=n; i++) {
    k=arr[i];
    printf "%s\t%g\t%d\t%s\t%d\n", k, s[k], c[k], t[k], g[k];
  }
}
' "$EVENTS" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

# Decrement must_grill_remaining for the just-affected category (if it was >0 before this event)
# (Decrement happens AFTER state replay so the recorded grill count reflects post-event state.)
case "$EVT" in
  decision_revocation|thesis_revocation) ;;  # already set fresh above
  *)
    awk -F'\t' -v cat="$CAT" -v OFS='\t' '
NR==1 { print; next }
$1==cat && $5+0 > 0 { $5 = $5 - 1; print; next }
{ print }
' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
    ;;
esac

# Render _index.md (best-effort)
if [[ -x "$RENDER_HOOK" ]]; then
  "$RENDER_HOOK" >> "$LOG" 2>&1 || echo "[sync-tracker-update] render hook failed (non-blocking)" >> "$LOG"
fi

echo "[sync-tracker-update] $TS  $CAT  $EVT  delta=$DELTA  decision=$DEC_ID" >> "$LOG"
exit 0
