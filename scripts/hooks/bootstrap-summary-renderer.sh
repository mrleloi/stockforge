#!/usr/bin/env bash
# bootstrap-summary-renderer.sh — render compact boot-summary.md for next-session reboot
# Hook event: Stop
# Per S65 user request: reduce reboot bootstrap cost (~$15-50/phase → ~$2-5/phase)
# Output: agent-workspace/memory/boot-summary.md (~2K target = ~10x cheaper than reading 8 files)
#
# Sections:
#   1. Active phase + track + next_action (from current-execution.md top row)
#   2. Last 5 ratified ADRs (decisions/ scan)
#   3. Last 3 M-S<N>-<M> mistakes (mistake-log scan)
#   4. In-flight subagent dispatch (checkpoint scan)
#   5. Rendered timestamp + cache-validity hint (1h)
#
# Determinism: pure awk/grep extraction; NO LLM call

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
OUTPUT="$MEMORY_DIR/boot-summary.md"
PAYLOAD="$(cat 2>/dev/null || true)"

# Only fire on Stop event (skip if hooked into other events accidentally)
if [ -n "$PAYLOAD" ]; then
  HOOK_EVENT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try { const p=JSON.parse(s); console.log(p.hook_event_name||''); }
  catch { console.log(''); }
});" 2>/dev/null || true)"
  [ "${HOOK_EVENT:-Stop}" = "Stop" ] || exit 0
fi

[ -d "$MEMORY_DIR" ] || exit 0

# Section 1: Active phase + track from current-execution.md top
ACTIVE_HEADER=""
NEXT_ACTION=""
if [ -f "$MEMORY_DIR/current-execution.md" ]; then
  # First top-level "## " heading (most recent session row)
  ACTIVE_HEADER="$(grep -m 1 '^## ' "$MEMORY_DIR/current-execution.md" 2>/dev/null | head -1 || true)"
  # Find Next-action line within that section (until next ## or 200 lines)
  NEXT_ACTION="$(awk '/^## /{c++; if (c==2) exit} /^\*\*Next action\*\*/{print; exit}' "$MEMORY_DIR/current-execution.md" 2>/dev/null || true)"
fi

# Section 2: Last 5 ADRs (sorted by NNN descending)
RECENT_ADRS=""
if [ -d "$MEMORY_DIR/decisions" ]; then
  RECENT_ADRS="$(ls "$MEMORY_DIR/decisions"/[0-9][0-9][0-9]-*.md 2>/dev/null | sort -r | head -5 | sed 's|.*/||' || true)"
fi

# Section 3: Last 3 M-S<N>-<M> entries (newest at bottom of file per mistake-log convention)
RECENT_MISTAKES=""
if [ -f "$MEMORY_DIR/mistake-log.md" ]; then
  RECENT_MISTAKES="$(grep -E '^### M-S[0-9]+(-[0-9]+|[a-z]-[0-9]+):' "$MEMORY_DIR/mistake-log.md" 2>/dev/null | tail -3 || true)"
fi

# Section 4: In-flight subagent dispatch from checkpoint (latest.md)
INFLIGHT_BLOCK=""
if [ -f "$MEMORY_DIR/checkpoints/latest.md" ]; then
  # Extract YAML block under "in_flight_subagent_dispatch:" until closing ``` or empty array
  INFLIGHT_BLOCK="$(awk '
    /^in_flight_subagent_dispatch:/{p=1; print; next}
    p && /^```/{exit}
    p && /^[a-z_]+:/ && !/^  /{exit}
    p{print}
  ' "$MEMORY_DIR/checkpoints/latest.md" 2>/dev/null | head -25 || true)"
fi

# Section 5: Render
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

mkdir -p "$MEMORY_DIR"
{
  echo "---"
  echo "rendered_at: $TS"
  echo "cache_ttl_hours: 1"
  echo "purpose: compact-bootstrap-context-for-reboot"
  echo "fallback: read current-execution.md + checkpoint/latest.md if mtime > 1h or content stale"
  echo "---"
  echo
  echo "# Boot Summary — auto-rendered (compact reboot context)"
  echo
  echo "> Per L-S65-reboot-cost-reduction. Read FIRST at SessionStart; full chain only if ambiguous."
  echo
  echo "## Active session/phase/track"
  if [ -n "$ACTIVE_HEADER" ]; then
    echo "$ACTIVE_HEADER"
  else
    echo "(no active section detected — check current-execution.md)"
  fi
  echo
  if [ -n "$NEXT_ACTION" ]; then
    echo "$NEXT_ACTION"
    echo
  fi
  echo "## Recent ADRs (last 5; review for binding context)"
  if [ -n "$RECENT_ADRS" ]; then
    echo '```'
    echo "$RECENT_ADRS"
    echo '```'
  else
    echo "(none)"
  fi
  echo
  echo "## Recent mistakes (last 3 M-S<N>-<M>)"
  if [ -n "$RECENT_MISTAKES" ]; then
    echo '```'
    echo "$RECENT_MISTAKES"
    echo '```'
  else
    echo "(none — clean state)"
  fi
  echo
  echo "## In-flight subagent dispatch (M-S64-1 prevention check)"
  if [ -n "$INFLIGHT_BLOCK" ]; then
    echo '```yaml'
    echo "$INFLIGHT_BLOCK"
    echo '```'
  else
    echo "(empty — no in-flight dispatch)"
  fi
  echo
  echo "---"
  echo "**Bootstrap reads remaining** (cheap follow-up):"
  echo "- routing-config.md (model × effort)"
  echo "- queued-grill-master.md (deferred Q&A triggers)"
  echo "- last 1 session log (semantic continuity)"
  echo
  echo "Full chain (if boot-summary stale > 1h or content ambiguous):"
  echo "- agent-workspace/memory/checkpoints/latest.md"
  echo "- agent-workspace/memory/current-execution.md (top section only)"
  echo "- last 3 sessions/* logs"
} > "$OUTPUT"

exit 0
