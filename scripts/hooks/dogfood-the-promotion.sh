#!/usr/bin/env bash
# dogfood-the-promotion.sh — Self-attestation linter: catches dev observation files that
# promote a discipline rule AND violate it in the same file.
#
# Promoted by: plan-046 D1 (L-S389-1 PROMOTE-NOW; L-S345-1 cluster at n=12+)
# Stop hook (late chain — after severity-classifier.sh).
#
# Logic:
#   1. Find sandwich-dev-S*.md observation files modified within last 5 minutes
#   2. For each: grep for "STEP X.Y promoted" markers (rule-promotion signals)
#   3. For each promotion marker found, check ±5 lines context for "~[0-9]" tilde-prefix
#      (the dogfood violation pattern per M-S388-1: promoted exact-integer discipline
#      but still used "~" approximation prefixes in the same file)
#   4. If violation detected: emit WARN row to .severity-state.tsv
#
# Severity: LOW (WARN-only; main session decides whether to inline-fix on next turn)
# Bypass: set STOCKFORGE_SKIP_DOGFOOD=1 in env to skip this hook (mirrors pre-commit pattern)
#
# Bash + POSIX only per L-S11-1. Best-effort: never fails Stop chain (RC=0 always).

set -uo pipefail
trap 'exit 0' ERR

[ "${STOCKFORGE_SKIP_DOGFOOD:-0}" = "1" ] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
STATE_FILE="$PROJECT_DIR/agent-workspace/memory/.severity-state.tsv"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"
TIMEOUT_SEC=5

# Ensure observations dir exists; if not, nothing to do
[ -d "$OBS_DIR" ] || exit 0

# Find recently modified sandwich-dev observation files (within last 5 minutes)
RECENT_FILES=""
RECENT_FILES=$(find "$OBS_DIR" -maxdepth 1 -name 'sandwich-dev-S*.md' -mmin -5 2>/dev/null || true)

[ -z "$RECENT_FILES" ] && exit 0

VIOLATIONS=0

while IFS= read -r obs_file; do
  [ -z "$obs_file" ] && continue
  [ -f "$obs_file" ] || continue

  # Find lines containing "STEP X.Y promoted" pattern
  # Read full file content for ±5-line context window search
  file_content=""
  file_content=$(cat "$obs_file" 2>/dev/null || true)
  [ -z "$file_content" ] && continue

  total_lines=$(wc -l < "$obs_file" 2>/dev/null || echo 0)

  # Find line numbers of promotion markers
  promo_lines=""
  promo_lines=$(grep -n 'STEP [0-9][0-9]*\.[0-9][0-9]* promoted' "$obs_file" 2>/dev/null || true)
  [ -z "$promo_lines" ] && continue

  # For each promotion line, check ±5 lines for tilde-digit pattern (~[0-9])
  while IFS= read -r promo_entry; do
    [ -z "$promo_entry" ] && continue
    promo_lineno=$(printf '%s' "$promo_entry" | cut -d: -f1)
    [ -z "$promo_lineno" ] && continue

    # Calculate window bounds
    win_start=$(( promo_lineno - 5 ))
    win_end=$(( promo_lineno + 5 ))
    [ "$win_start" -lt 1 ] && win_start=1
    [ "$win_end" -gt "$total_lines" ] && win_end=$total_lines

    # Extract window and check for ~[0-9] pattern
    window_content=""
    window_content=$(sed -n "${win_start},${win_end}p" "$obs_file" 2>/dev/null || true)
    tilde_hit=$(printf '%s' "$window_content" | grep -c '~[0-9]' 2>/dev/null || echo 0)

    if [ "${tilde_hit:-0}" -gt 0 ]; then
      rel_path="${obs_file#$PROJECT_DIR/}"
      promo_rule=$(printf '%s' "$promo_entry" | grep -oE 'STEP [0-9]+\.[0-9]+' | head -1 || true)
      msg="DOGFOOD-VIOLATION: ${promo_rule:-STEP?} promoted exact-integer discipline but ~[0-9] found within ±5 lines (M-S388-1 pattern)"
      # Emit LOW severity WARN row to state file (append — classifier already wrote header)
      printf 'LOW\t%s\t0\tLOG-ONLY\t%s\tSOFT\n' "$rel_path" "$TS" >> "$STATE_FILE" 2>/dev/null || true
      printf '[%s] dogfood-the-promotion.sh: WARN %s in %s\n' "$TS" "$msg" "$rel_path" >> "$LOG" 2>/dev/null || true
      VIOLATIONS=$(( VIOLATIONS + 1 ))
    fi
  done <<< "$promo_lines"

done <<< "$RECENT_FILES"

if [ "$VIOLATIONS" -eq 0 ]; then
  printf '[%s] dogfood-the-promotion.sh: OK no promotion-self-violations in recent observations\n' "$TS" >> "$LOG" 2>/dev/null || true
fi

exit 0
