#!/usr/bin/env bash
# sync-tracker-auto-update.sh — Stop hook wrapper for HH-B.5.
# Detects sync-tracker-relevant events from session-end state and fires sync-tracker-update.sh
# with conservative deltas. Idempotent per session via marker file.
#
# Events detected:
#   1. New ADR authored this session (mtime <6h on agent-workspace/memory/decisions/*.md)
#      → SCOPE charter_match (+0.2 per ADR, capped at 3 to avoid runaway)
#   2. HIGH-severity drift this session (.drift-signals.log tail with current minute)
#      → DECISION_ROUTING drift_signal (-0.3 once)
#   3. Q&A resolved this session (mtime <6h on human-workspace/q-and-a/answered/*.md)
#      → DECISION_ROUTING q_and_a_resolution (+0.1 once)
#
# Per L-S11-1 portability: bash + standard POSIX tools only (no jq/python/node-required logic).
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

# === L-S48d-1 lint flag — S57 ratify per KI-S54-1 (alt-guard recognition) ===
# bash-hook-lint Check 7 flags this file. Categorization:
#   `HIGH_TODAY="$(grep "^\[..." "$DRIFT_LOG" 2>/dev/null | grep -c severity=HIGH || echo 0)"` —
#     alt-guard `|| echo 0` end-of-pipeline ✓
# Single grep usage; SAFE. Lint refinement to recognize `|| echo NN`
# alt-guard deferred per KI-S54-1.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
SYNC_HOOK="$PROJECT_DIR/scripts/hooks/sync-tracker-update.sh"
SESSION_ID="${CLAUDE_SESSION_ID:-default}"
MARKER="$MEMORY_DIR/.sync-tracker-fired-${SESSION_ID}"
LOG="$MEMORY_DIR/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

# Idempotent: bail if already fired this session.
[ -f "$MARKER" ] && exit 0

# Bail if sync-tracker-update.sh missing.
[ ! -x "$SYNC_HOOK" ] && [ ! -f "$SYNC_HOOK" ] && exit 0

FIRED=0

# Event 1: new ADRs authored this session (mtime <6h).
DECISIONS_DIR="$MEMORY_DIR/decisions"
if [ -d "$DECISIONS_DIR" ]; then
  ADR_COUNT="$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' -mmin -360 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$ADR_COUNT" =~ ^[0-9]+$ ]] || ADR_COUNT=0
  if [ "$ADR_COUNT" -gt 0 ]; then
    # Cap at 3 fires to avoid runaway when bulk ADRs land.
    [ "$ADR_COUNT" -gt 3 ] && ADR_COUNT=3
    for i in $(seq 1 "$ADR_COUNT"); do
      bash "$SYNC_HOOK" SCOPE charter_match "" "auto-S${SESSION_ID:0:8}-adr-$i" "" "auto-detected new ADR mtime <6h" >/dev/null 2>&1 || true
      FIRED=$(( FIRED + 1 ))
    done
  fi
fi

# Event 2: HIGH-severity drift this session.
DRIFT_LOG="$MEMORY_DIR/.drift-signals.log"
if [ -f "$DRIFT_LOG" ]; then
  # Use today's date prefix to scope to today (avoid stale-bucket false positive).
  TODAY="$(date -u +%Y-%m-%d 2>/dev/null || true)"
  if [ -n "$TODAY" ]; then
    HIGH_TODAY="$(grep "^\[${TODAY}" "$DRIFT_LOG" 2>/dev/null | grep -c "severity=HIGH" || echo 0)"
    [[ "$HIGH_TODAY" =~ ^[0-9]+$ ]] || HIGH_TODAY=0
    if [ "$HIGH_TODAY" -gt 0 ]; then
      bash "$SYNC_HOOK" DECISION_ROUTING drift_signal "" "auto-S${SESSION_ID:0:8}-drift" "" "auto-detected $HIGH_TODAY HIGH-drift events today" >/dev/null 2>&1 || true
      FIRED=$(( FIRED + 1 ))
    fi
  fi
fi

# Event 3: Q&A resolved this session.
ANSWERED_DIR="$PROJECT_DIR/human-workspace/q-and-a/answered"
if [ -d "$ANSWERED_DIR" ]; then
  QA_RECENT="$(find "$ANSWERED_DIR" -maxdepth 1 -name '*.md' -mmin -360 2>/dev/null | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$QA_RECENT" =~ ^[0-9]+$ ]] || QA_RECENT=0
  if [ "$QA_RECENT" -gt 0 ]; then
    bash "$SYNC_HOOK" DECISION_ROUTING q_and_a_resolution "" "auto-S${SESSION_ID:0:8}-qa" "" "auto-detected $QA_RECENT Q&A in answered/ <6h" >/dev/null 2>&1 || true
    FIRED=$(( FIRED + 1 ))
  fi
fi

# Mark session as fired (regardless of FIRED count — prevents re-entry within same session).
touch "$MARKER" 2>/dev/null || true

if [ "$FIRED" -gt 0 ]; then
  echo "[$TS] sync-tracker-auto-update: fired=$FIRED session=$SESSION_ID" >> "$LOG"
fi

exit 0
