#!/usr/bin/env bash
# sub-plan-completion-coherence.sh — Stop hook (S224 ship per L-S223-1 HOOK-TIER promotion;
# S235 EXTENDED per L-S223-1-MP master-plan-staleness sister-class catch).
#
# Purpose (combined): detect routing-staleness in `agent-workspace/session-plans/pending/`.
# Two detection paths:
#   (A) SUB-PLAN: ≥80% NEW <path> deliverables on disk + no close-row mention → WARN.
#   (B) MASTER-PLAN: frontmatter `phase: N` matches a project.md Phase Goals Tracker row
#       whose Status column contains DONE or CLOSED → WARN. (Added S235; covers the gap
#       where 9 phase master-plans accumulated stale-routing across Phase 0/1/2/2.5/3/3.5
#       closes — empirical catch during S235 Phase 4 mid-IMPL parent audit.)
#
# Per L-S223-1 (S223 same-session 2nd-recurrence-MET): both 008-S45 + 009-S51
# sub-plans had Track I / J+K shipped DAYS earlier yet stayed in pending/ across
# 6+ sessions of stale routing self-attest. This hook prevents 3rd recurrence.
# Per L-S223-1-MP (S235 catch): same family at master-plan tier — 9 master-plans
# stale across 5 phase closes; promotion target = Stop-hook 2nd loop (this file)
# rather than separate `master-plan-coherence.sh` per single-source-of-routing-truth.
#
# Per L-S108-1: hour-bucket marker (no fallback constant; cleanup-stale-markers loop).
# Per L-S11-1 + UP-05: bash + POSIX tools only. STOCKFORGE_HOOK_PORTABILITY_TIER=1
# allows POSIX tooling per S222 financial-data-protocol.md:301.
# Per Phase 3.5 Hard Rule #2: companion firing-test at firing-tests/sub-plan-completion-coherence-fire-test.sh
# uses REAL-STATE-DERIVED fixtures per L-S176-1.
#
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
PENDING_DIR="$PROJECT_DIR/agent-workspace/session-plans/pending"
CURRENT_EXEC="$MEMORY_DIR/current-execution.md"
PROJECT_MD="$MEMORY_DIR/project.md"
HOOK_LOG="$MEMORY_DIR/.session-hooks.log"
COHERENCE_LOG="$MEMORY_DIR/.sub-plan-coherence.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
THRESHOLD_PCT="${STOCKFORGE_SUB_PLAN_THRESHOLD_PCT:-80}"

mkdir -p "$MEMORY_DIR" 2>/dev/null || true

BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$MEMORY_DIR/.sub-plan-coherence-fired-${BUCKET}"
CACHE="$MEMORY_DIR/.sub-plan-coherence-cache-${SID}"

# Per-session 5-min cache.
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( $(date +%s) - CACHE_MTIME ))
  if [ "$AGE" -lt 300 ]; then
    echo "[$TS] sub-plan-completion-coherence: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
    exit 0
  fi
fi

# Cleanup stale hour-bucket markers (L-S108-1).
for old_marker in "$MEMORY_DIR"/.sub-plan-coherence-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".sub-plan-coherence-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null || true ;;
  esac
done

# Idempotent: bail if already fired this hour-bucket.
[ -f "$MARKER" ] && exit 0

# Bail gracefully if pending dir or current-execution.md missing.
if [ ! -d "$PENDING_DIR" ] || [ ! -f "$CURRENT_EXEC" ]; then
  touch "$MARKER" 2>/dev/null || true
  echo "session=$SID ts=$TS state=NO-FILES detail=pending-or-current-exec-missing" > "$CACHE" 2>/dev/null || true
  exit 0
fi

set +o pipefail

WARN_PLANS=""
TOTAL_PENDING=0
TOTAL_WARN=0

for plan in "$PENDING_DIR"/*.md; do
  [ -f "$plan" ] || continue
  TOTAL_PENDING=$((TOTAL_PENDING + 1))
  plan_name=$(basename "$plan")
  plan_id=$(echo "$plan_name" | grep -oE '^[0-9]+-S[0-9]+' | head -1)
  [ -z "$plan_id" ] && plan_id="$plan_name"

  # Extract NEW <path> deliverables — pattern: backtick-quoted path after "NEW ".
  # Filter to file paths (must contain '.' = extension; skip directory-only paths).
  total=0
  present=0
  while IFS= read -r dpath; do
    [ -z "$dpath" ] && continue
    case "$dpath" in *.*) ;; *) continue ;; esac
    total=$((total + 1))
    [ -e "$PROJECT_DIR/$dpath" ] && present=$((present + 1))
  done < <(grep -oE 'NEW `[^`]+`' "$plan" 2>/dev/null | sed 's/^NEW `//;s/`$//')

  [ "$total" -eq 0 ] && continue
  pct=$(( present * 100 / total ))
  [ "$pct" -lt "$THRESHOLD_PCT" ] && continue

  # ≥THRESHOLD% deliverables present — check for close-row mention.
  # Match either plan filename (basename) OR plan_id (e.g. "009-S51").
  if grep -qF "$plan_name" "$CURRENT_EXEC" 2>/dev/null; then continue; fi
  if grep -qF "$plan_id" "$CURRENT_EXEC" 2>/dev/null; then continue; fi

  # WARN: shipped-but-pending sub-plan detected.
  TOTAL_WARN=$((TOTAL_WARN + 1))
  WARN_PLANS="$WARN_PLANS $plan_id($present/$total)"
done

# === S235 Loop B: master-plan staleness via frontmatter `phase: N` vs project.md ===
# Skip Loop B if project.md missing.
if [ -f "$PROJECT_MD" ]; then
  for plan in "$PENDING_DIR"/*.md; do
    [ -f "$plan" ] || continue
    plan_name=$(basename "$plan")
    plan_id=$(echo "$plan_name" | grep -oE '^[0-9]+-S[0-9]+' | head -1)
    [ -z "$plan_id" ] && plan_id="$plan_name"

    # Avoid double-counting if Loop A already flagged this plan.
    case "$WARN_PLANS" in *"$plan_id("*) continue ;; esac

    # Extract phase token from YAML frontmatter (first 30 lines, line starting "phase:").
    # Match either "phase: N" or "phase: N.M" or "phase: N — descriptor"; capture leading numeric/decimal.
    phase_token=$(head -30 "$plan" 2>/dev/null | grep -E '^phase:[[:space:]]+[0-9]' | head -1 | sed -E 's/^phase:[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/')
    [ -z "$phase_token" ] && continue

    # Look up the matching Phase Goals Tracker row in project.md.
    # Format: `| <token> — <name> | ... | <Status> | ... |`
    phase_row=$(grep -E "^\|[[:space:]]*${phase_token}[[:space:]]+(—|--)" "$PROJECT_MD" 2>/dev/null | head -1)
    [ -z "$phase_row" ] && continue

    # Status column is field 4 (1-indexed) when split by `|`. Field offsets: leading | empty + Phase + Target + Status + Started + Completed + trailing.
    # Robust extraction: pipe-split, take 4th field, lowercase, scan for done/closed.
    phase_status=$(printf '%s\n' "$phase_row" | awk -F'|' '{print $4}' | tr '[:upper:]' '[:lower:]')
    case "$phase_status" in
      *done*|*closed*)
        TOTAL_WARN=$((TOTAL_WARN + 1))
        WARN_PLANS="$WARN_PLANS ${plan_id}(MP-phase-${phase_token}-closed)"
        ;;
    esac
  done
fi

STATE="GREEN"
[ "$TOTAL_WARN" -gt 0 ] && STATE="WARN"

# Cache result.
{
  printf 'session=%s ts=%s state=%s pending_count=%d warn_count=%d threshold_pct=%s warn_plans=%s\n' \
    "$SID" "$TS" "$STATE" "$TOTAL_PENDING" "$TOTAL_WARN" "$THRESHOLD_PCT" "${WARN_PLANS:-none}"
} > "$CACHE" 2>/dev/null || true

echo "[$TS] sub-plan-completion-coherence: state=$STATE pending=$TOTAL_PENDING warn=$TOTAL_WARN session=$SID" >> "$HOOK_LOG" 2>/dev/null || true

if [ "$STATE" = "GREEN" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# WARN: dedicated drift log + stderr message for human-visible Stop output.
{
  printf '[%s] WARN state=%s pending=%d warn=%d plans=%s session=%s\n' \
    "$TS" "$STATE" "$TOTAL_PENDING" "$TOTAL_WARN" "$WARN_PLANS" "$SID"
} >> "$COHERENCE_LOG" 2>/dev/null || true

cat >&2 <<EOF
[sub-plan-completion-coherence] WARN: $TOTAL_WARN sub-plan(s) in pending/ have ≥${THRESHOLD_PCT}% deliverables on disk but no close-row in current-execution.md:$WARN_PLANS
Action: empirically verify; if shipped, git mv pending/<plan>.md → completed/ + prepend close-row.
EOF

touch "$MARKER" 2>/dev/null || true
exit 0
