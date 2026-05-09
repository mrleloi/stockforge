#!/usr/bin/env bash
# session-end-checklist-linter.sh — HH-C.1 Stop hook
#
# Purpose: enforce session-end ritual discipline by verifying the most recent
# session log mentions a mistake-log update (entry M-S<N>-<M> OR explicit
# "no mistakes this session" attestation). Soft-warn on miss.
#
# Per HH-C of agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md
# and decision-discipline.md Rule 4b (D-026): lesson-synthesis mandatory at session-end.
# This hook is the deterministic complement codifying the mistake-log half of that rule.
#
# Per L-S11-1 portability: bash + standard POSIX tools only.
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
SESSIONS_DIR="$MEMORY_DIR/sessions"
# L-S108-1 fix (S109): per-session marker MUST use hour-bucket, NEVER fallback constant.
# CLAUDE_SESSION_ID empty for Stop hooks on Windows → fallback "default" shared across
# ALL sessions (M-S108-1 RCA: stale .session-end-checklist-fired-default from S48g
# blocked hook S99-S108). SESSION_ID still captured for log diagnostics.
SESSION_ID="${CLAUDE_SESSION_ID:-}"
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$MEMORY_DIR/.session-end-checklist-fired-${BUCKET}"
LOG="$MEMORY_DIR/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

# Cleanup stale markers from prior buckets (L-S108-1 prevention).
for old_marker in "$MEMORY_DIR"/.session-end-checklist-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".session-end-checklist-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null ;;
  esac
done

# Idempotent: bail if already fired this hour-bucket.
[ -f "$MARKER" ] && exit 0

# Bail if sessions dir missing.
[ ! -d "$SESSIONS_DIR" ] && { touch "$MARKER" 2>/dev/null || true; exit 0; }

# Find most recent session log (mtime sorted; first hit).
LATEST_SESSION="$(find "$SESSIONS_DIR" -maxdepth 1 -name '*.md' -type f -printf '%T@\t%p\n' 2>/dev/null \
                  | sort -rn | head -1 | cut -f2)"

# Bail if no session logs exist.
[ -z "$LATEST_SESSION" ] || [ ! -f "$LATEST_SESSION" ] && { touch "$MARKER" 2>/dev/null || true; exit 0; }

# Only audit logs written within last 4h (otherwise this is a Stop in a session that
# never wrote a log — which is itself the violation, surfaced by the existence check below).
RECENT_LOGS="$(find "$SESSIONS_DIR" -maxdepth 1 -name '*.md' -type f -mmin -240 2>/dev/null | wc -l | tr -d '[:space:]')"
[[ "$RECENT_LOGS" =~ ^[0-9]+$ ]] || RECENT_LOGS=0

if [ "$RECENT_LOGS" -eq 0 ]; then
  echo "[session-end-checklist-linter] WARN: no session log written in last 4h." >&2
  echo "[session-end-checklist-linter] Action: write agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md before Stop." >&2
  echo "[$TS] session-end-checklist-linter: no_recent_log session=$SESSION_ID" >> "$LOG" 2>/dev/null || true
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# Pattern check on latest session log.
# Pass conditions (any one suffices):
#   1. References mistake-log file directly
#   2. Cites a M-S<N>-<M> entry
#   3. Explicit "no mistakes this session" / "0 mistakes" / "no new mistakes" attestation
PATTERNS="mistake-log|M-S[0-9]+-[0-9]+|no mistakes this session|no new mistakes|0 mistakes|0 NEW mistakes|no mistake entries|nothing to mistake-log"

if grep -qiE "$PATTERNS" "$LATEST_SESSION" 2>/dev/null; then
  # Pass — lesson-synthesis discipline observed.
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# Miss — soft-warn.
LATEST_BASENAME="$(basename "$LATEST_SESSION")"
echo "[session-end-checklist-linter] WARN: $LATEST_BASENAME does not mention mistake-log update or 'no mistakes this session'." >&2
echo "[session-end-checklist-linter] Per decision-discipline.md Rule 4b: every session-end MUST either:" >&2
echo "[session-end-checklist-linter]   (a) cite a NEW M-S<N>-<M> entry written to agent-workspace/memory/mistake-log.md, OR" >&2
echo "[session-end-checklist-linter]   (b) explicitly state 'no mistakes this session' as attestation." >&2
echo "[$TS] session-end-checklist-linter: missing_attestation session=$SESSION_ID file=$LATEST_BASENAME" >> "$LOG" 2>/dev/null || true

touch "$MARKER" 2>/dev/null || true
exit 0
