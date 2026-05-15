#!/usr/bin/env bash
# working-memory-budget-audit.sh — SessionStart hook (preventive, S103 deliverable).
#
# Purpose: Enforce the "routine load" working-memory budget per S99 proposal
# `agent-workspace/proposals/memory-tiers.md` § Tier 1 (≤ 20 KB combined). The three
# files an agent loads on EVERY `continue` (boot-summary + latest checkpoint +
# routing-config) MUST stay under the combined ceiling so /clear-resume context
# remains compact. This is distinct from `tier1-bloat-check.sh` (broader CLAUDE.md +
# current-execution.md set; older 8K-token ceiling from S38 D-017).
#
# Files audited (combined byte sum):
#   1. agent-workspace/memory/boot-summary.md        (sub-cap ≤  4 KB recommended)
#   2. agent-workspace/memory/checkpoints/latest.md  (sub-cap ≤  8 KB recommended)
#   3. agent-workspace/memory/routing-config.md      (sub-cap ≤  8 KB recommended)
#
# Ceiling: 20480 bytes combined (= 20 KB hard byte ceiling per CLAUDE.md hard rule:
#   "Working-memory budget per agent-workspace/proposals/memory-tiers.md § Tier 1
#    = ≤ 20 KB combined for routine load.")
#
# Behavior on breach:
#   - WARN to .session-hooks.log
#   - Create dated notification at human-workspace/notifications/
#   - Emit additionalContext (system-reminder-style) so agent surfaces issue at boot
#   - exit 0 always (soft-warn; never HARD-BLOCK; harness fixing requires loading
#     these very files, so blocking would lock-out the recovery path)
#
# Order: wired AFTER essential-routing-fields-verifier.sh BUT BEFORE
# session-start-bootstrap.sh in .claude/settings.json — both pre-bootstrap concerns
# (routing-fields presence + working-memory-budget shape) surface before bootstrap
# silently parses the over-large files.
#
# Phase 0 portability per L-S11-1: bash + POSIX only (node optional for JSON emit;
# audit still functions if node missing — just skips additionalContext output).
# PIPEFAIL pattern per L-S48d-1 + L-S80-2: `2>/dev/null || true` after wc/grep.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
BOOT_SUMMARY="$PROJECT_DIR/agent-workspace/memory/boot-summary.md"
CHECKPOINT="$PROJECT_DIR/agent-workspace/memory/checkpoints/latest.md"
ROUTING_CONFIG="$PROJECT_DIR/agent-workspace/memory/routing-config.md"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

CEILING_BYTES=20480  # 20 KB combined budget

mkdir -p "$(dirname "$HOOK_LOG")" "$NOTIF_DIR" 2>/dev/null || true

# Read SessionStart payload to filter event source (only act on startup|resume|clear).
PAYLOAD=""
if [ ! -t 0 ]; then
  PAYLOAD=$(cat 2>/dev/null || true)
fi
SOURCE=""
if [ -n "$PAYLOAD" ] && command -v node >/dev/null 2>&1; then
  SOURCE=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).source||''); } catch { console.log(''); } });" 2>/dev/null || true)
fi
# Fallback: if no payload (e.g. firing-test direct invocation), default to startup so
# audit still runs; production hook chain always has payload via Anthropic harness.
SOURCE="${SOURCE:-startup}"

case "$SOURCE" in
  startup|resume|clear) ;;
  *)
    echo "[$TS] working-memory-budget-audit: skipped source=$SOURCE (not startup|resume|clear)" >> "$HOOK_LOG"
    exit 0
    ;;
esac

# Sum bytes of routine-load files. Missing files contribute 0 bytes (the
# essential-routing-fields-verifier.sh + bootstrap-summary-renderer.sh hooks own
# the missing-file detection responsibility — this hook is only about budget).
file_bytes() {
  local f="$1"
  if [ -f "$f" ]; then
    local b
    b=$(wc -c < "$f" 2>/dev/null || echo 0)
    # wc -c may return whitespace-prefixed; strip via arithmetic coercion.
    printf '%s' "$((b + 0))"
  else
    printf '0'
  fi
}

BS_BYTES=$(file_bytes "$BOOT_SUMMARY")
CP_BYTES=$(file_bytes "$CHECKPOINT")
RC_BYTES=$(file_bytes "$ROUTING_CONFIG")
TOTAL_BYTES=$((BS_BYTES + CP_BYTES + RC_BYTES))

# Track how many of the 3 routine-load files are missing (informational only; not a
# violation — missing-file detection is essential-routing-fields-verifier's domain).
MISSING_COUNT=0
[ ! -f "$BOOT_SUMMARY" ]   && MISSING_COUNT=$((MISSING_COUNT + 1))
[ ! -f "$CHECKPOINT" ]     && MISSING_COUNT=$((MISSING_COUNT + 1))
[ ! -f "$ROUTING_CONFIG" ] && MISSING_COUNT=$((MISSING_COUNT + 1))

OVER_BUDGET=0
if [ "$TOTAL_BYTES" -gt "$CEILING_BYTES" ]; then
  OVER_BUDGET=1
fi

echo "[$TS] working-memory-budget-audit: total=${TOTAL_BYTES}B ceiling=${CEILING_BYTES}B over_budget=${OVER_BUDGET} source=$SOURCE missing_count=${MISSING_COUNT}" >> "$HOOK_LOG"

# S318: fixed-name idempotent notification (was date-bucketed); cleared when budget back under ceiling.
NOTIF_FILE="$NOTIF_DIR/working-memory-budget-OVER.md"
if [ "$OVER_BUDGET" -eq 1 ]; then
  OVER_BY=$((TOTAL_BYTES - CEILING_BYTES))
  PCT_OVER=$((OVER_BY * 100 / CEILING_BYTES))
  {
    echo "# Working-memory budget exceeded — $TS"
    echo ""
    echo "**Source**: $SOURCE"
    echo "**Total**: ${TOTAL_BYTES} bytes"
    echo "**Ceiling**: ${CEILING_BYTES} bytes (20 KB)"
    echo "**Over by**: ${OVER_BY} bytes (${PCT_OVER}%)"
    echo ""
    echo "## Per-file breakdown"
    echo ""
    echo "| File | Bytes | Sub-cap (KB) |"
    echo "|---|---|---|"
    echo "| boot-summary.md     | ${BS_BYTES} | ≤ 4 |"
    echo "| checkpoints/latest.md | ${CP_BYTES} | ≤ 8 |"
    echo "| routing-config.md   | ${RC_BYTES} | ≤ 8 |"
    echo ""
    echo "## Action required"
    echo "- Identify heaviest file and re-shape:"
    echo "  - boot-summary.md → re-render via bootstrap-summary-renderer.sh"
    echo "  - checkpoints/latest.md → trim non-essential prose; archive bulk to dated checkpoint"
    echo "  - routing-config.md → split task-class entries to extension file"
    echo "- Reference: \`agent-workspace/proposals/memory-tiers.md\` § Tier 1"
  } > "$NOTIF_FILE"

  # Emit additionalContext to surface to agent at session boot.
  if command -v node >/dev/null 2>&1; then
    CTX="WORKING-MEMORY BUDGET EXCEEDED — routine-load files total ${TOTAL_BYTES}B / ${CEILING_BYTES}B ceiling (over by ${OVER_BY}B / ${PCT_OVER}%). See $NOTIF_FILE. Trim heaviest of: boot-summary / latest checkpoint / routing-config."
    node -e "
const ctx = process.argv[1];
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'SessionStart',
    additionalContext: ctx
  }
}));
" "$CTX" 2>/dev/null || true
  fi
else
  rm -f "$NOTIF_FILE" 2>/dev/null || true
fi

exit 0
