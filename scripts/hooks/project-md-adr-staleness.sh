#!/usr/bin/env bash
# project-md-adr-staleness.sh — Stop hook (renamed from project-md-staleness-check.sh per D-038 Option E).
#
# Purpose (single): detect drift between agent-workspace/memory/project.md mtime
# and newest ADR in agent-workspace/memory/decisions/. Tolerates ≤2h drift; WARNs at >2h.
#
# Per D-038 Option E (S176 audit observations/2026-05-07-S176-HH-C2-misfire-root-cause.md):
#   - Check A (phase mismatch) RETIRED — superseded by phase-status-coherence.sh
#     at UserPromptSubmit cadence (S175 D-037) with stronger 3-sub-check semantics.
#   - Check B (project.md mtime vs newest ADR) RETAINED + glob FIXED.
#     Original glob `D-*.md` matched ZERO files (actual ADR naming `NNN-*.md`); fixed
#     to accept both `[0-9][0-9][0-9]-*.md` (production primary) AND `D-*.md` (backward
#     compat) via combined find -name clause.
#
# Per L-S108-1: hour-bucket marker (no fallback constant; cleanup-stale-markers loop).
# Per L-S11-1 + UP-05: bash + POSIX tools only.
# Per Phase 3.5 Hard Rule #2: companion firing-test at firing-tests/project-md-adr-staleness-fire-test.sh
# uses REAL-STATE-DERIVED fixtures (NNN-*.md naming) per L-S176-1.
#
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
PROJECT_MD="$MEMORY_DIR/project.md"
DECISIONS_DIR="$MEMORY_DIR/decisions"
HOOK_LOG="$MEMORY_DIR/.session-hooks.log"
ADR_STALENESS_LOG="$MEMORY_DIR/.adr-staleness.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
TOLERANCE_HOURS="2.0"

mkdir -p "$MEMORY_DIR" 2>/dev/null || true

BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$MEMORY_DIR/.adr-staleness-fired-${BUCKET}"
CACHE="$MEMORY_DIR/.adr-staleness-cache-${SID}"

# Per-session 5-min cache (perf budget).
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( $(date +%s) - CACHE_MTIME ))
  if [ "$AGE" -lt 300 ]; then
    echo "[$TS] project-md-adr-staleness: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
    exit 0
  fi
fi

# Cleanup stale hour-bucket markers (L-S108-1 prevention) — also drops legacy
# .project-md-staleness-fired-* markers from pre-rename predecessor.
for old_marker in "$MEMORY_DIR"/.adr-staleness-fired-* "$MEMORY_DIR"/.project-md-staleness-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".adr-staleness-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null || true ;;
  esac
done

# Idempotent: bail if already fired this hour-bucket.
[ -f "$MARKER" ] && exit 0

# Bail gracefully if project.md or decisions/ missing.
if [ ! -f "$PROJECT_MD" ] || [ ! -d "$DECISIONS_DIR" ]; then
  touch "$MARKER" 2>/dev/null || true
  echo "session=$SID ts=$TS state=NO-FILES detail=project-md-or-decisions-dir-missing" > "$CACHE" 2>/dev/null || true
  exit 0
fi

set +o pipefail

# Find newest ADR — accept both production naming (NNN-*.md) AND backward-compat (D-*.md).
# Original hook used only `D-*.md` which matched ZERO files (M-S176-1 root cause).
NEWEST_ADR_INFO=$(find "$DECISIONS_DIR" -maxdepth 1 -type f \
                  \( -name '[0-9][0-9][0-9]-*.md' -o -name 'D-*.md' \) \
                  -printf '%T@\t%f\n' 2>/dev/null | sort -rn | head -1)

NEWEST_ADR_TS=$(echo "$NEWEST_ADR_INFO" | cut -f1)
NEWEST_ADR_NAME=$(echo "$NEWEST_ADR_INFO" | cut -f2)

# Empty decisions/ → graceful bail (no ADRs yet to compare against).
if [ -z "$NEWEST_ADR_TS" ] || [ -z "$NEWEST_ADR_NAME" ]; then
  touch "$MARKER" 2>/dev/null || true
  echo "session=$SID ts=$TS state=GREEN detail=no-adr-files newest_adr=" > "$CACHE" 2>/dev/null || true
  echo "[$TS] project-md-adr-staleness: state=GREEN detail=no-adr-files session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
  exit 0
fi

PROJECT_MTIME=$(find "$PROJECT_MD" -printf '%T@\n' 2>/dev/null)
[ -z "$PROJECT_MTIME" ] && PROJECT_MTIME=0

STATE="GREEN"
SEVERITY="LOW"
DELTA_HOURS="0.0"
WARN_COUNT=0

# Compare floats via awk — bash arithmetic doesn't handle floats.
OLDER=$(awk -v p="$PROJECT_MTIME" -v a="$NEWEST_ADR_TS" 'BEGIN{print (p < a) ? 1 : 0}')
if [ "$OLDER" = "1" ]; then
  DELTA_HOURS=$(awk -v p="$PROJECT_MTIME" -v a="$NEWEST_ADR_TS" 'BEGIN{printf "%.1f", (a - p) / 3600}')
  OVER=$(awk -v d="$DELTA_HOURS" -v t="$TOLERANCE_HOURS" 'BEGIN{print (d > t) ? 1 : 0}')
  if [ "$OVER" = "1" ]; then
    STATE="WARN"
    SEVERITY="MEDIUM"
    WARN_COUNT=1
  fi
fi

# Cache result (per-session; testable state).
{
  printf 'session=%s ts=%s state=%s severity=%s delta_hours=%s newest_adr=%s warn_count=%d\n' \
    "$SID" "$TS" "$STATE" "$SEVERITY" "$DELTA_HOURS" "$NEWEST_ADR_NAME" "$WARN_COUNT"
} > "$CACHE" 2>/dev/null || true

# Hook log: every invocation logs current state (mirrors phase-status-coherence pattern).
echo "[$TS] project-md-adr-staleness: state=$STATE delta_hr=$DELTA_HOURS newest_adr=$NEWEST_ADR_NAME session=$SID" >> "$HOOK_LOG" 2>/dev/null || true

# GREEN → done; mark idempotent + exit.
if [ "$STATE" = "GREEN" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# WARN: dedicated drift log + stderr message for human-visible Stop output.
{
  printf '[%s] WARN state=%s severity=%s delta_hr=%s newest_adr=%s session=%s\n' \
    "$TS" "$STATE" "$SEVERITY" "$DELTA_HOURS" "$NEWEST_ADR_NAME" "$SID"
} >> "$ADR_STALENESS_LOG" 2>/dev/null || true

cat >&2 <<EOF
[project-md-adr-staleness] WARN: project.md mtime ${DELTA_HOURS}h older than newest ADR ($NEWEST_ADR_NAME).
Tolerance: ${TOLERANCE_HOURS}h. Action: update project.md '## Recent Architectural Decisions' with the new ADR summary.
EOF

touch "$MARKER" 2>/dev/null || true
exit 0
