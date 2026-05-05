#!/usr/bin/env bash
# tier1-bloat-check.sh — Tier 1 memory bloat alarm
# Companion hook to agent-workspace/constitution/memory-tiers.md (ratified S38, D-017)
#
# Per memory-tiers.md Tier 1 budget: ≤8K tokens (PLAN session bootstrap ceiling per
# autonomous-protocol.md Rule 4). If Tier 1 exceeds 8K consistently, files must be
# re-shaped or split (heaviest file → Tier 2 with explicit-load discipline).
#
# Soft-warns at SessionStart (non-blocking); does NOT halt execution.
# Token approximation: bytes/4 (ASCII heuristic; conservative).

set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"

CHECKPOINT_FILE="agent-workspace/memory/checkpoints/latest.md"
CURRENT_EXEC="agent-workspace/memory/current-execution.md"
ROOT_CLAUDE="CLAUDE.md"
WORKSPACE_CLAUDE="agent-workspace/CLAUDE.md"

TIER1_FILES=("$ROOT_CLAUDE" "$WORKSPACE_CLAUDE" "$CURRENT_EXEC")

# Include checkpoint only if recent (≤24h)
if [ -f "$CHECKPOINT_FILE" ]; then
    if find "$CHECKPOINT_FILE" -mtime -1 2>/dev/null | grep -q .; then
        TIER1_FILES+=("$CHECKPOINT_FILE")
    fi
fi

TOTAL_BYTES=0
for f in "${TIER1_FILES[@]}"; do
    if [ -f "$f" ]; then
        b=$(wc -c < "$f" 2>/dev/null || echo 0)
        TOTAL_BYTES=$((TOTAL_BYTES + b))
    fi
done

TOTAL_TOKENS=$((TOTAL_BYTES / 4))
CEILING=8000

if [ "$TOTAL_TOKENS" -gt "$CEILING" ]; then
    echo "[tier1-bloat-check] WARN: Tier 1 bootstrap = ${TOTAL_TOKENS} tok (ceiling ${CEILING})" >&2
    echo "[tier1-bloat-check] Files:" >&2
    for f in "${TIER1_FILES[@]}"; do
        if [ -f "$f" ]; then
            b=$(wc -c < "$f" 2>/dev/null || echo 0)
            t=$((b / 4))
            echo "[tier1-bloat-check]   ${t} tok  $f" >&2
        fi
    done
    echo "[tier1-bloat-check] Action: re-shape heaviest file or move non-essential prose to Tier 2." >&2
fi

exit 0
