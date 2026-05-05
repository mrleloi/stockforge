#!/usr/bin/env bash
# proposal-bundle-advisor.sh — L-S43f-1 hook-tier promotion (Q-E3 priority).
#
# Detects when ≥2 charter-tier proposals are simultaneously pending and target
# distinct constitution files. Emits SessionStart soft advisory recommending
# bundled deny-lift cycle (1 lift + N edits + 1 restore + 1 combined ADR) to
# amortize permission ceremony cost.
#
# Decision basis: D-026 § "Why bundled" + agent-notes L-S43f-1 (2026-05-05).
# Anti-pattern prevented: sequencing N separate cycles when bundling is correct.
#
# Bash + POSIX only per L-S11-1.
# SessionStart hook (matcher startup|resume|clear); soft-warn (exit 0).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PROP_DIR="$PROJECT_DIR/agent-workspace/proposals"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

[ -d "$PROP_DIR" ] || exit 0

# Count proposals whose first 20 lines contain status: PROPOSAL or status: PROPOSED
# (not ACCEPTED, REJECTED, AMENDED). Inline `**Status**: PROPOSAL` form also matched.
PENDING=0
TARGETS=""
for f in "$PROP_DIR"/*.md; do
  [ -f "$f" ] || continue
  # Match YAML frontmatter (status: PROPOSAL) OR inline markdown (**Status**: PROPOSAL).
  head -n 20 "$f" 2>/dev/null | grep -qiE '(^status:|\*\*Status\*\*:)\s*(PROPOSAL|PROPOSED)' || continue
  # Skip if same head also shows ACCEPTED/REJECTED/AMENDED/RATIFIED (safer double-check).
  head -n 20 "$f" 2>/dev/null | grep -qiE '(ACCEPTED|REJECTED|AMENDED|RATIFIED)' && continue
  PENDING=$((PENDING + 1))
  TARGETS="$TARGETS $(basename "$f")"
done

if [ "$PENDING" -ge 2 ]; then
  ADVISORY="proposal-bundle-advisor: $PENDING charter-tier proposals currently pending. Consider bundled deny-lift cycle (single AskUserQuestion + single permission lift + 1 combined ADR) per L-S43f-1 / D-026 precedent. Pending:$TARGETS"
  printf '[%s] %s\n' "$TS" "$ADVISORY" >> "$LOG"
  echo "$ADVISORY" >&2
else
  printf '[%s] proposal-bundle-advisor: pending=%s (no bundling opportunity)\n' "$TS" "$PENDING" >> "$LOG"
fi

exit 0
