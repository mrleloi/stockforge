#!/usr/bin/env bash
# research-scanner-output-validator.sh — soft-warn when a research-scanner dispatch output
# is missing required discipline elements: frontmatter (picked + as_of), Adversarial Bear Case
# section, Provenance Log section. Implements L-S12-2 promotion target hook.
#
# Wires: stop hook in .claude/settings.json (S13+ optional). Non-blocking (exit 0 always).
# Phase 0 portability: bash + POSIX only (per L-S11-1).
# L-S10-1: if/then/fi only; split-local.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
DOGFOOD_DIR="$PROJECT_DIR/agent-workspace/learning-data/dogfood"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

if [ ! -d "$DOGFOOD_DIR" ]; then
  exit 0
fi

VIOLATIONS=0
VIOLATION_LIST=""

while IFS= read -r -d '' file; do
  bn="$(basename "$file")"
  missing=""
  # Frontmatter checks (within first 50 lines).
  head_block="$(head -n 50 "$file" 2>/dev/null || true)"
  if ! printf '%s' "$head_block" | grep -qE '^picked:'; then
    missing="${missing}picked-frontmatter,"
  fi
  if ! printf '%s' "$head_block" | grep -qE '^as_of:'; then
    missing="${missing}as_of-frontmatter,"
  fi
  # Section header checks (entire file).
  if ! grep -qE '^##[[:space:]]+Adversarial[[:space:]]+Bear[[:space:]]+Case' "$file" 2>/dev/null; then
    missing="${missing}adversarial-bear-case-section,"
  fi
  if ! grep -qE '^##[[:space:]]+Provenance[[:space:]]+Log' "$file" 2>/dev/null; then
    missing="${missing}provenance-log-section,"
  fi
  if [ -n "$missing" ]; then
    VIOLATIONS=$(( VIOLATIONS + 1 ))
    missing_clean="$(printf '%s' "$missing" | sed 's/,$//')"
    VIOLATION_LIST="${VIOLATION_LIST}  - ${bn}: missing [${missing_clean}]"$'\n'
  fi
done < <(find "$DOGFOOD_DIR" -name 'agent-pick-*-research-report-*.md' -type f -print0 2>/dev/null)

if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] research-scanner-output-validator WARN %d report(s) missing discipline elements:\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"
  if [ -d "$NOTIF_DIR" ]; then
    TS_FILE="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
    NOTIF_FILE="$NOTIF_DIR/$TS_FILE-research-scanner-validator-warn.md"
    {
      printf '# Research-Scanner Output Validator — Warnings\n\n'
      printf 'Per L-S12-2 (agent-notes 2026-04-29): every research-scanner dispatch output MUST include picked + as_of frontmatter, Adversarial Bear Case section, Provenance Log section.\n\n'
      printf '%d report(s) missing discipline elements:\n\n' "$VIOLATIONS"
      printf '%s' "$VIOLATION_LIST"
      printf '\nFix: edit each report to include the missing field/section; reference `.claude/agents/research-scanner.md` § Output for the canonical template.\n'
    } > "$NOTIF_FILE" 2>/dev/null || true
  fi
else
  printf '[%s] research-scanner-output-validator OK (0 violations)\n' "$TS" >> "$LOG"
fi

exit 0
