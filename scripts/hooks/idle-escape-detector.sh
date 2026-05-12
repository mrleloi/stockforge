#!/usr/bin/env bash
# idle-escape-detector.sh — UserPromptSubmit + SessionStart hook.
# Detects ≥3 consecutive ROUTINE-IDLE / META-CADENCE session blocks at the top
# (newest) of agent-workspace/memory/current-execution.md and demands an escape
# action (phase-audit subagent dispatch OR Q&A escalation) before agent slips
# into a 4th idle session.
#
# Phase 3.5 / S175 deliverable. M-S171-1 prevention rule #3.
# Pairs with phase-status-coherence.sh (same session; complementary check).
#
# Source-of-truth pattern markers (anchored from S148-S170 production blocks):
#   ## S<N> — Phase <X> — ROUTINE-IDLE: ...
#   ## S<N> — Phase <X> — META-CADENCE: ...
# Both are zero-substantive-work session classes. ≥3 consecutive at top = the
# 22-session stall pattern that surfaced as M-S171-1 (S148-S170, ~100K wasted main).
#
# Per CLAUDE.md hard rule + Phase 3.5 Hard Rule #2: every hook ships with companion
# firing-test (scripts/hooks/firing-tests/idle-escape-detector-fire-test.sh).
# Per UP-05 + L-S11-1: bash + POSIX tools only; no Skill tool calls.
# Exit 0 ALWAYS (informational, not blocking).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
EVENT="${1:-${CLAUDE_HOOK_EVENT:-UserPromptSubmit}}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory" 2>/dev/null || true

CE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
PLANS_DIR="$PROJECT_DIR/agent-workspace/session-plans/pending"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
IDLE_LOG="$PROJECT_DIR/agent-workspace/memory/.idle-escape.log"

# Per-hour-bucket idempotency marker per L-S108-1 (CLAUDE_SESSION_ID may be empty
# under SessionStart on Windows → fallback to constant collides across sessions).
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$PROJECT_DIR/agent-workspace/memory/.idle-escape-fired-${BUCKET}"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

# Per-session 5-min cache (mirrors harness-health-self-scan.sh) to avoid re-firing
# on every UserPromptSubmit within same session — perf budget on UserPromptSubmit
# is <2s.
CACHE="$PROJECT_DIR/agent-workspace/memory/.idle-escape-cache-${SID}"
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( $(date +%s) - CACHE_MTIME ))
  if [ "$AGE" -lt 300 ]; then
    echo "[$TS] idle-escape-detector: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
    exit 0
  fi
fi

# Cleanup stale hour-bucket markers from prior buckets (L-S108-1 prevention).
for old_marker in "$PROJECT_DIR/agent-workspace/memory"/.idle-escape-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".idle-escape-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null || true ;;
  esac
done

# Bail gracefully if current-execution.md missing.
if [ ! -f "$CE" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

set +o pipefail

# ============================================================================
# Step 1: pull last 5 session-block ## S<N> header lines (newest-first since
# current-execution.md prepends new sessions at top).
# ============================================================================
HEADERS=$(grep -m 5 -E '^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase' "$CE" 2>/dev/null)
HEADER_COUNT=$(echo "$HEADERS" | grep -c '^## S' 2>/dev/null || echo 0)
[[ "$HEADER_COUNT" =~ ^[0-9]+$ ]] || HEADER_COUNT=0

if [ "$HEADER_COUNT" -lt 1 ]; then
  touch "$MARKER" 2>/dev/null || true
  echo "session=$SID ts=$TS state=NO-HEADERS detail=cannot-parse-blocks" > "$CACHE" 2>/dev/null || true
  exit 0
fi

# ============================================================================
# Step 2: count consecutive ROUTINE-IDLE / META-CADENCE among newest blocks.
# Stop counting at first non-idle header.
# ============================================================================
CONSECUTIVE=0
LATEST_LABEL=""
LATEST_SID=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  if [ -z "$LATEST_LABEL" ]; then
    LATEST_SID=$(echo "$line" | sed -E 's/^## (S[0-9]+[a-z]?).*/\1/')
    if echo "$line" | grep -qE '— ROUTINE-IDLE'; then LATEST_LABEL="ROUTINE-IDLE"
    elif echo "$line" | grep -qE '— META-CADENCE'; then LATEST_LABEL="META-CADENCE"
    else LATEST_LABEL="ACTIVE"
    fi
  fi
  if echo "$line" | grep -qE '— (ROUTINE-IDLE|META-CADENCE)'; then
    CONSECUTIVE=$((CONSECUTIVE + 1))
  else
    break
  fi
done <<< "$HEADERS"

# ============================================================================
# Step 3: scan session-plans/pending/ for queued plans (informational boost —
# idle while plans are queued = stronger escape signal).
# ============================================================================
PENDING_PLANS=0
if [ -d "$PLANS_DIR" ]; then
  PENDING_PLANS=$(find "$PLANS_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
  [[ "$PENDING_PLANS" =~ ^[0-9]+$ ]] || PENDING_PLANS=0
fi

# ============================================================================
# Step 4: severity classification.
#   - GREEN: 0-2 consecutive idle
#   - YELLOW: ≥3 consecutive idle, no pending plans
#   - RED: ≥3 consecutive idle AND pending plans ≥1 (work queued + ignored)
# Threshold ≥3 anchors to L-S171-1 / M-S171-1 doctrine.
# ============================================================================
STATE="GREEN"
SEVERITY="LOW"
if [ "$CONSECUTIVE" -ge 3 ] && [ "$PENDING_PLANS" -ge 1 ]; then
  STATE="RED"
  SEVERITY="HIGH"
elif [ "$CONSECUTIVE" -ge 3 ]; then
  STATE="YELLOW"
  SEVERITY="MEDIUM"
fi

# Cache the result regardless (so cache-hit fast-path holds for next 5 min).
{
  printf 'session=%s ts=%s state=%s severity=%s consecutive=%d latest_sid=%s latest_label=%s pending_plans=%d\n' \
    "$SID" "$TS" "$STATE" "$SEVERITY" "$CONSECUTIVE" "$LATEST_SID" "$LATEST_LABEL" "$PENDING_PLANS"
} > "$CACHE" 2>/dev/null || true

# Always log a one-line summary for telemetry (passive observability).
echo "[$TS] idle-escape-detector: state=$STATE consecutive=$CONSECUTIVE latest=$LATEST_SID(${LATEST_LABEL}) pending_plans=$PENDING_PLANS session=$SID" \
  >> "$HOOK_LOG" 2>/dev/null || true

# Idempotent fire: if marker already touched this hour-bucket, suppress system-reminder
# emission BUT keep cache + log fresh (so observability doesn't go silent).
if [ -f "$MARKER" ]; then
  exit 0
fi

# ============================================================================
# Step 5: emit signal on RED/YELLOW.
# ============================================================================
if [ "$STATE" = "GREEN" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# Audit log entry capturing escape trigger (richer than .session-hooks.log).
{
  printf '[%s] %s state=%s consecutive=%d latest=%s(%s) pending_plans=%d session=%s event=%s\n' \
    "$TS" "ESCAPE-TRIGGER" "$STATE" "$CONSECUTIVE" "$LATEST_SID" "$LATEST_LABEL" "$PENDING_PLANS" "$SID" "$EVENT"
} >> "$IDLE_LOG" 2>/dev/null || true

REMINDER_BODY="IDLE-ESCAPE-DETECTOR: state=$STATE (consecutive_idle=$CONSECUTIVE; latest=$LATEST_SID/$LATEST_LABEL; pending_plans=$PENDING_PLANS)
Per L-S171-1 / M-S171-1 doctrine: ≥3 consecutive ROUTINE-IDLE / META-CADENCE blocks ⇒ phase-audit required BEFORE next idle.
Required action ONE OF:
  (a) Dispatch phase-audit subagent (fresh-context Phase 2.5/3 status verify per verify_phase_before_next_phase doctrine);
  (b) Open Q&A escalation bundle (human-workspace/q-and-a/pending/) if SCOPE/CHARTER ambiguity blocks substantive work;
  (c) Pick + execute a queued session-plan from agent-workspace/session-plans/pending/ ($PENDING_PLANS available).
Forbidden: silent 4th ROUTINE-IDLE / META-CADENCE block. Charter Principle 8 + AP-5 binding."

# UserPromptSubmit emission via Claude Code JSON contract (mirrors
# harness-health-self-scan.sh § UserPromptSubmit emit; node may be unavailable
# in stripped environments → fallback to stderr).
if [ "$EVENT" = "UserPromptSubmit" ]; then
  if command -v node >/dev/null 2>&1; then
    node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:process.argv[1]}}))" "$REMINDER_BODY" 2>/dev/null || \
      echo "[idle-escape] $REMINDER_BODY" >&2
  else
    echo "[idle-escape] $REMINDER_BODY" >&2
  fi
elif [ "$EVENT" = "SessionStart" ]; then
  echo "[idle-escape] $REMINDER_BODY" >&2
else
  echo "[idle-escape] event=$EVENT $REMINDER_BODY" >&2
fi

touch "$MARKER" 2>/dev/null || true
exit 0
