#!/usr/bin/env bash
# in-flight-subagent-watcher.sh — UserPromptSubmit + SessionStart hook (Phase 3.5 T3.4 Cluster 3).
#
# Surveils agent-workspace/memory/.dispatch-pending-*.jsonl for state=pending entries
# older than threshold (default 2hr) without observation file present. Surfaces stale
# pending dispatches to the model via stderr so it can verify state before any new
# Agent.dispatch call.
#
# Origin: M-S49b-2 dispatch-duplicate-across-/clear (RCA observation S1+S2) +
#   L-S49b-3 background-subagent dispatch sequencing protocol (Fix-L4 deferred). The
#   prior session 5b96635e dispatched, user typed /new mid-turn, harness queued the
#   slash command, current session re-read stale checkpoint next_action and prepared
#   re-dispatch. This watcher catches that pattern at the harness layer.
#
# Conformance:
#   - Bash + POSIX per L-S11-1 (no python/jq/yq)
#   - Soft-warn only (always exit 0); does not block
#   - L-S48d-1 disciplined: each grep wrapped with || true OR if-grep form
#   - L-S48m-1 disciplined: NO marker filenames using $CLAUDE_SESSION_ID

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
PENDING_DIR="$PROJECT_DIR/agent-workspace/memory"
WATCHER_LOG="$PROJECT_DIR/agent-workspace/memory/.in-flight-subagent-watcher.log"
TS="$(date -Iseconds 2>/dev/null || date)"

# Threshold (seconds) configurable via env; 2hr default per L-S49b-3
AGE_THRESHOLD_S="${STOCKFORGE_INFLIGHT_AGE_THRESHOLD_S:-7200}"

# Validate dependencies
[ -d "$PENDING_DIR" ] || exit 0

NOW_S="$(date +%s 2>/dev/null || echo 0)"
case "$NOW_S" in
  ''|*[!0-9]*) exit 0 ;;
esac

STALE_COUNT=0
STALE_DETAIL=""

# Iterate pending JSONL files. nullglob makes the loop a no-op when no files match.
shopt -s nullglob 2>/dev/null || true
for f in "$PENDING_DIR"/.dispatch-pending-*.jsonl; do
  [ -f "$f" ] || continue

  while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Parse state field
    state=$(printf '%s' "$line" | grep -oE '"state":"[a-z_]+"' | head -1 | sed 's/.*":"//;s/"//' || true)
    [ "$state" = "pending" ] || continue

    # Parse ts_ms field
    ts_ms=$(printf '%s' "$line" | grep -oE '"ts_ms":[0-9]+' | head -1 | sed 's/.*://' || echo 0)
    case "$ts_ms" in
      ''|*[!0-9]*) ts_ms=0 ;;
    esac
    ts_s=$(( ts_ms / 1000 ))
    age_s=$(( NOW_S - ts_s ))

    # Skip fresh entries
    [ "$age_s" -lt "$AGE_THRESHOLD_S" ] && continue

    # Parse expected_observation_path
    expected=$(printf '%s' "$line" | grep -oE '"expected_observation_path":"[^"]+"' | head -1 | sed 's/.*":"//;s/"//' || true)

    # If observation already arrived (subagent completed but JSONL not closed) → skip
    if [ -n "$expected" ] && [ -f "$PROJECT_DIR/$expected" ]; then
      continue
    fi

    # Stale + no observation → flag
    STALE_COUNT=$(( STALE_COUNT + 1 ))
    dispatch_id=$(printf '%s' "$line" | grep -oE '"dispatch_id":"[^"]+"' | head -1 | sed 's/.*":"//;s/"//' || echo unknown)
    STALE_DETAIL="${STALE_DETAIL}  - dispatch_id=${dispatch_id} age_s=${age_s} expected=${expected:-unknown} file=$(basename "$f")
"
  done < "$f"
done

# Emit
mkdir -p "$(dirname "$WATCHER_LOG")" 2>/dev/null || true
if [ "$STALE_COUNT" -gt 0 ]; then
  {
    printf '[%s] in-flight-subagent-watcher: %d stale pending dispatch(es)\n' "$TS" "$STALE_COUNT"
    printf -- '%s' "$STALE_DETAIL"
  } >> "$WATCHER_LOG"
  printf 'in-flight-subagent-watcher: %d stale pending dispatch(es) age >= %ss — verify state before any new Agent.dispatch (L-S49b-3 Fix-L4); detail: %s\n' \
    "$STALE_COUNT" "$AGE_THRESHOLD_S" "$WATCHER_LOG" >&2
else
  printf '[%s] in-flight-subagent-watcher: clean (0 stale pending dispatch)\n' "$TS" >> "$WATCHER_LOG"
fi

exit 0
