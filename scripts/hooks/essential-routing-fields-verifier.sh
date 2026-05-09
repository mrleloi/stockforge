#!/usr/bin/env bash
# essential-routing-fields-verifier.sh — SessionStart hook (preventive, S101 deliverable).
#
# Purpose: Prevent recurrence of M-S99-2 (autonomous_mode flag dropped during S99 archive
# truncation → /clear-resume dead loop ~6h until user reported "đứng im").
# Per L-S100-1 (codified S100): compaction on routing source-of-truth files MUST
# preserve global non-session-row fields explicitly. This hook is the deterministic
# safety net per Q-E3 promotion priority (hook FIRST, skill SECOND, charter LAST).
#
# Essential fields verified in agent-workspace/memory/current-execution.md:
#   1. **autonomous_mode**: <true|false>  (controls continue-injector spawn on /clear)
#   2. ≥1 ## S<N> session row              (sanity: file not empty/wrong-shape)
#
# Behavior on missing/invalid field:
#   - WARN to .session-hooks.log
#   - Create dated notification at human-workspace/notifications/
#   - Emit additionalContext (system-reminder-style) so agent surfaces issue at boot
#   - exit 0 always (soft-warn; never HARD-BLOCK to avoid lock-out from harness fixing)
#
# Order: wired BEFORE session-start-bootstrap.sh in .claude/settings.json so the
# warning is visible before bootstrap silently parses fallback default.
#
# Phase 0 portability per L-S11-1: bash + POSIX only (node optional for JSON emit;
# verifier still functions if node missing — just skips additionalContext output).
# PIPEFAIL pattern per L-S48d-1 + L-S80-2: `2>/dev/null || true` after grep -c.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

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
# verifier still runs; production hook chain always has payload via Anthropic harness.
SOURCE="${SOURCE:-startup}"

case "$SOURCE" in
  startup|resume|clear) ;;
  *)
    echo "[$TS] essential-routing-fields-verifier: skipped source=$SOURCE (not startup|resume|clear)" >> "$HOOK_LOG"
    exit 0
    ;;
esac

VIOLATIONS=()

if [ ! -f "$EXEC_FILE" ]; then
  VIOLATIONS+=("missing_file: $EXEC_FILE not found — routing source-of-truth absent")
else
  # Field 1: **autonomous_mode**: <true|false> — non-empty, valid value.
  AM_RAW=$(awk -F': ' '/^\*\*autonomous_mode\*\*/ {print $2; exit}' "$EXEC_FILE" 2>/dev/null || true)
  AM_VALUE=$(printf '%s' "$AM_RAW" | awk '{print $1}' | tr -d '*' 2>/dev/null || true)
  if [ -z "${AM_VALUE:-}" ]; then
    VIOLATIONS+=("missing_field: **autonomous_mode** absent — M-S99-2 pattern (S99 archive lost flag → /clear-resume dead)")
  elif [ "$AM_VALUE" != "true" ] && [ "$AM_VALUE" != "false" ]; then
    VIOLATIONS+=("invalid_value: **autonomous_mode** expected 'true' or 'false', got '$AM_VALUE'")
  fi

  # Field 2: ≥1 ## S<N> session row (sanity check; file not empty/wrong shape).
  SESSION_COUNT=$(grep -cE '^## S[0-9]+' "$EXEC_FILE" 2>/dev/null || true)
  SESSION_COUNT="${SESSION_COUNT:-0}"
  if [ "$SESSION_COUNT" -eq 0 ]; then
    VIOLATIONS+=("missing_session_rows: 0 '## S<N>' headers in $EXEC_FILE — file empty or wrong shape")
  fi
fi

VCOUNT="${#VIOLATIONS[@]}"
echo "[$TS] essential-routing-fields-verifier: violations=$VCOUNT source=$SOURCE" >> "$HOOK_LOG"

if [ "$VCOUNT" -gt 0 ]; then
  NOTIF_FILE="$NOTIF_DIR/essential-routing-fields-MISSING-$(date +%Y-%m-%d 2>/dev/null || echo unknown).md"
  {
    echo "# Essential routing field(s) missing — $TS"
    echo ""
    echo "**File**: \`$EXEC_FILE\`"
    echo "**Source**: $SOURCE"
    echo "**Lesson**: L-S100-1 (compaction must preserve routing globals)"
    echo "**Mistake pattern**: M-S99-2 (autonomous_mode flag dropped → /clear-resume dead ~6h)"
    echo ""
    echo "## Violations ($VCOUNT)"
    for v in "${VIOLATIONS[@]}"; do
      echo "- $v"
      echo "[$TS] essential-routing-fields-verifier: $v" >> "$HOOK_LOG"
    done
    echo ""
    echo "## Action required"
    echo "- For \`**autonomous_mode**\`: restore the line near top of \`$EXEC_FILE\` (above first \`## S<N>\` row)."
    echo "- Verify with: \`awk -F': ' '/^\*\*autonomous_mode\*\*/ {print \$2; exit}' $EXEC_FILE\`"
    echo "- Canonical line format (S100 fix reference):"
    echo "  \`**autonomous_mode**: true (RE-ENABLED 2026-05-05 S48 via /autonomous on; ...)\`"
  } > "$NOTIF_FILE"

  # Emit additionalContext to surface to agent at session boot.
  if command -v node >/dev/null 2>&1; then
    CTX="ESSENTIAL ROUTING FIELD MISSING — verifier flagged $VCOUNT violation(s) in current-execution.md. See $NOTIF_FILE before any /clear or autonomous-loop work. Per L-S100-1 / M-S99-2."
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
fi

exit 0
