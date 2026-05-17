#!/usr/bin/env bash
# stop-finding-frontmatter-validator.sh — Deterministic frontmatter checker for
# STOP-FINDING-*.md notification files.
#
# Promoted by: plan-046 D2 (L-S397-2 PROMOTE-NOW + PCG-S401-3 PROMOTE-NOW)
# Stop hook (late chain — after dogfood-the-promotion.sh).
#
# Logic:
#   1. Scan human-workspace/notifications/STOP-FINDING-*.md (exclude _template.md)
#   2. For each: check severity field value is in {CRITICAL, HIGH, MEDIUM, LOW}
#   3. For each: check status field is present (any non-empty value)
#   4. Violations: emit LOW severity WARN rows to .severity-state.tsv
#
# Severity of violations: LOW (WARN-only; no auto-block; main session decides inline-fix)
# Read-only: does NOT modify existing STOP-FINDING files
# Canonical severity vocab: agent-workspace/constitution/severity-schema.md §1 (4-level)
#
# Bash + POSIX only per L-S11-1. Best-effort: never fails Stop chain (RC=0 always).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
STATE_FILE="$PROJECT_DIR/agent-workspace/memory/.severity-state.tsv"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

[ -d "$NOTIF_DIR" ] || exit 0

VIOLATIONS=0

while IFS= read -r sf_file; do
  [ -z "$sf_file" ] && continue
  [ -f "$sf_file" ] || continue

  rel_path="${sf_file#$PROJECT_DIR/}"

  # Extract frontmatter (first 25 lines covers all expected frontmatter fields)
  frontmatter=""
  frontmatter=$(head -25 "$sf_file" 2>/dev/null || true)

  # --- Check 1: severity field present and in canonical 4-level enum ---
  sev_line=$(printf '%s' "$frontmatter" | grep -m1 '^severity:' || true)
  sev_value=$(printf '%s' "$sev_line" | sed 's/^severity:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs 2>/dev/null || true)

  if [ -z "$sev_value" ]; then
    printf 'LOW\t%s\t0\tLOG-ONLY\t%s\tSOFT\n' "$rel_path" "$TS" >> "$STATE_FILE" 2>/dev/null || true
    printf '[%s] stop-finding-frontmatter-validator.sh: WARN missing severity field in %s\n' "$TS" "$rel_path" >> "$LOG" 2>/dev/null || true
    VIOLATIONS=$(( VIOLATIONS + 1 ))
  else
    case "$sev_value" in
      CRITICAL|HIGH|MEDIUM|LOW) ;;
      *)
        printf 'LOW\t%s\t0\tLOG-ONLY\t%s\tSOFT\n' "$rel_path" "$TS" >> "$STATE_FILE" 2>/dev/null || true
        printf '[%s] stop-finding-frontmatter-validator.sh: WARN ad-hoc severity "%s" in %s (must be CRITICAL|HIGH|MEDIUM|LOW per severity-schema.md)\n' "$TS" "$sev_value" "$rel_path" >> "$LOG" 2>/dev/null || true
        VIOLATIONS=$(( VIOLATIONS + 1 ))
        ;;
    esac
  fi

  # --- Check 2: status field present and non-empty ---
  status_line=$(printf '%s' "$frontmatter" | grep -m1 '^status:' || true)
  status_value=$(printf '%s' "$status_line" | sed 's/^status:[[:space:]]*//' | tr -d '"' | tr -d "'" | xargs 2>/dev/null || true)

  if [ -z "$status_value" ]; then
    printf 'LOW\t%s\t0\tLOG-ONLY\t%s\tSOFT\n' "$rel_path" "$TS" >> "$STATE_FILE" 2>/dev/null || true
    printf '[%s] stop-finding-frontmatter-validator.sh: WARN missing status field in %s (required for HH-E.2 auto-mv)\n' "$TS" "$rel_path" >> "$LOG" 2>/dev/null || true
    VIOLATIONS=$(( VIOLATIONS + 1 ))
  fi

done < <(find "$NOTIF_DIR" -maxdepth 1 -name 'STOP-FINDING-*.md' 2>/dev/null || true)

if [ "$VIOLATIONS" -eq 0 ]; then
  printf '[%s] stop-finding-frontmatter-validator.sh: OK all STOP-FINDING files pass frontmatter checks\n' "$TS" >> "$LOG" 2>/dev/null || true
fi

exit 0
