#!/usr/bin/env bash
# sync-grilling-trigger.sh — SessionStart hook signaling "sync-grilling due" when N sessions
# or M days elapsed since last sync check. Surfaces notification only — does NOT auto-fire
# AskUserQuestion (per UP-05 § Q2.1 — only SUPERVISED mode fires; agent decides timing).
# Created S7 (2026-04-29) per Track 5.5b.3 (D-003).
# Wired as SessionStart in .claude/settings.json (after session-start-bootstrap.sh).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SYNC_STATE="$PROJECT_DIR/agent-workspace/memory/sync-state.md"
SESSIONS_DIR="$PROJECT_DIR/agent-workspace/memory/sessions"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
GRILL_LOG="$PROJECT_DIR/agent-workspace/memory/.sync-grill-fired.log"

# Configurable via env (with stockforge + orch fallbacks for backward compat).
INTERVAL_SESSIONS="${STOCKFORGE_SYNC_GRILL_INTERVAL_SESSIONS:-${ORCH_SYNC_GRILL_INTERVAL_SESSIONS:-3}}"
INTERVAL_DAYS="${STOCKFORGE_SYNC_GRILL_INTERVAL_DAYS:-${ORCH_SYNC_GRILL_INTERVAL_DAYS:-7}}"

mkdir -p "$PROJECT_DIR/agent-workspace/memory"

PAYLOAD=$(cat 2>/dev/null || true)
SOURCE=$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).source||''); } catch { console.log(''); } });" 2>/dev/null || echo "")

# Only run on real SessionStart triggers.
case "$SOURCE" in
  startup|resume|clear) ;;
  *) exit 0 ;;
esac

[ -f "$SYNC_STATE" ] || { echo "[$(date -Iseconds)] sync-grilling-trigger: skip (no sync-state.md)" >> "$HOOK_LOG"; exit 0; }

# Get last_check newest date from sync-state.md
LAST_CHECK=$(grep -oE 'last_check:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$SYNC_STATE" 2>/dev/null \
  | awk '{print $2}' | sort -r | head -1 || true)

# Count sessions since last_check (count session log files dated after LAST_CHECK)
SESSIONS_SINCE=0
if [ -d "$SESSIONS_DIR" ] && [ -n "$LAST_CHECK" ]; then
  SESSIONS_SINCE=$(ls "$SESSIONS_DIR"/*-session-*.md 2>/dev/null \
    | awk -v cutoff="$LAST_CHECK" -F/ '{
        fname = $NF;
        if (match(fname, /^[0-9]{4}-[0-9]{2}-[0-9]{2}/)) {
          fdate = substr(fname, RSTART, RLENGTH);
          if (fdate > cutoff) count++
        }
      } END { print count+0 }')
fi

# Days elapsed (Unix timestamp diff)
DAYS_SINCE=0
if [ -n "$LAST_CHECK" ]; then
  if command -v gdate >/dev/null 2>&1; then
    DATE_BIN=gdate
  else
    DATE_BIN=date
  fi
  LAST_TS=$($DATE_BIN -d "$LAST_CHECK" +%s 2>/dev/null || echo 0)
  NOW_TS=$($DATE_BIN +%s 2>/dev/null || echo 0)
  if [ "$LAST_TS" -gt 0 ] && [ "$NOW_TS" -gt 0 ]; then
    DAYS_SINCE=$(( (NOW_TS - LAST_TS) / 86400 ))
  fi
fi

# Decide: fire if either threshold exceeded
SHOULD_FIRE=false
REASON=""
if [ "$SESSIONS_SINCE" -ge "$INTERVAL_SESSIONS" ]; then
  SHOULD_FIRE=true
  REASON="${SESSIONS_SINCE} sessions elapsed (≥${INTERVAL_SESSIONS} threshold)"
fi
if [ "$DAYS_SINCE" -ge "$INTERVAL_DAYS" ]; then
  SHOULD_FIRE=true
  if [ -n "$REASON" ]; then
    REASON="$REASON; $DAYS_SINCE days elapsed (≥${INTERVAL_DAYS} threshold)"
  else
    REASON="${DAYS_SINCE} days elapsed (≥${INTERVAL_DAYS} threshold)"
  fi
fi

if [ "$SHOULD_FIRE" = "true" ]; then
  TS=$(date -Iseconds)
  printf '[%s] SYNC-GRILLING-DUE last_check=%s sessions_since=%s days_since=%s reason=%s\n' \
    "$TS" "$LAST_CHECK" "$SESSIONS_SINCE" "$DAYS_SINCE" "$REASON" >> "$GRILL_LOG"
  echo "[$TS] sync-grilling-trigger: FIRED ($REASON)" >> "$HOOK_LOG"

  CTX="SYNC-GRILLING DUE (auto-injected by sync-grilling-trigger.sh):
$REASON since last_check=$LAST_CHECK in sync-state.md.
Recommendation: agent should consider firing AskUserQuestion(≤4) sync-bundle this session,
using template at .claude/skills/grill-maximization/references/sync-bundle-template.md.
Pick 4 sync-state items with state=assumed-aligned or open-question; phrase as 'do we still
understand X the same way?'. Update sync-state.md last_check after answers received.
Non-blocking — agent decides timing within session."

  node -e "
const ctx = process.argv[1];
process.stdout.write(JSON.stringify({
  hookSpecificOutput: {
    hookEventName: 'SessionStart',
    additionalContext: ctx
  }
}));
" "$CTX" 2>/dev/null || true
else
  echo "[$(date -Iseconds)] sync-grilling-trigger: not due (sessions=$SESSIONS_SINCE/$INTERVAL_SESSIONS days=$DAYS_SINCE/$INTERVAL_DAYS last_check=$LAST_CHECK)" >> "$HOOK_LOG"
fi

exit 0
