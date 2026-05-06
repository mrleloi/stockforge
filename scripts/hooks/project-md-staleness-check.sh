#!/usr/bin/env bash
# project-md-staleness-check.sh — HH-C.2 Stop hook
#
# Purpose: detect drift between project.md "Phase Goals Tracker" and
# current-execution.md "Active Focus Track" / "Track status". Flags two
# staleness modes:
#   (A) Active phase appearing in current-execution.md not present (or
#       wrong status) in project.md Phase Goals Tracker.
#   (B) project.md mtime older than newest ADR in decisions/ (project.md
#       must reflect every architectural decision per the file's own header).
#
# Per HH-C of 009-S48-harness-hardening-middle-phase.md.
# Per L-S11-1 portability: bash + standard POSIX tools only.
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
PROJECT_MD="$MEMORY_DIR/project.md"
CURRENT_EXEC="$MEMORY_DIR/current-execution.md"
DECISIONS_DIR="$MEMORY_DIR/decisions"
SESSION_ID="${CLAUDE_SESSION_ID:-default}"
MARKER="$MEMORY_DIR/.project-md-staleness-fired-${SESSION_ID}"
LOG="$MEMORY_DIR/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

# Idempotent: bail if already fired this session.
[ -f "$MARKER" ] && exit 0

# Bail gracefully if either file missing.
[ ! -f "$PROJECT_MD" ] || [ ! -f "$CURRENT_EXEC" ] && { touch "$MARKER" 2>/dev/null || true; exit 0; }

# Disable pipefail — legitimate grep-no-match returns 1 and would tip ERR trap.
set +o pipefail

WARN_COUNT=0

# ============================================================================
# Check A: phase status alignment
# ============================================================================
# Extract active phase number from current-execution.md "**Phase**: N — ..." line.
ACTIVE_PHASE="$(grep -m1 -E '^\*\*Phase\*\*:[[:space:]]*[0-9]' "$CURRENT_EXEC" 2>/dev/null \
                | sed -E 's/^\*\*Phase\*\*:[[:space:]]*([0-9]+(\.[0-9]+)?).*/\1/')"

if [ -n "$ACTIVE_PHASE" ]; then
  # Check that project.md Phase Goals Tracker has a row for this phase with status
  # matching reality. Phase Goals Tracker rows look like:
  #   | 2.5 — Harness Hardening (NEW) | 8 tracks ... | IN PROGRESS | 2026-05-05 (S48) | - |
  # We grep the row and inspect column 4 (status).
  PHASE_ROW="$(grep -E "^\|[[:space:]]*${ACTIVE_PHASE}[[:space:]]+—" "$PROJECT_MD" 2>/dev/null | head -1)"

  if [ -z "$PHASE_ROW" ]; then
    echo "[project-md-staleness-check] WARN: active Phase $ACTIVE_PHASE absent from project.md Phase Goals Tracker." >&2
    echo "[project-md-staleness-check] Action: add row to project.md table." >&2
    WARN_COUNT=$(( WARN_COUNT + 1 ))
  else
    # Extract status column (3rd | -separated field after leading |).
    PHASE_STATUS="$(echo "$PHASE_ROW" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$4); print $4}')"
    case "$PHASE_STATUS" in
      "IN PROGRESS"|"DONE"|"PAUSED"|"NOT STARTED"|"BLOCKED")
        : # ok shape
        ;;
      *)
        echo "[project-md-staleness-check] WARN: Phase $ACTIVE_PHASE status='$PHASE_STATUS' not in {IN PROGRESS,DONE,PAUSED,NOT STARTED,BLOCKED}." >&2
        WARN_COUNT=$(( WARN_COUNT + 1 ))
        ;;
    esac

    # Cross-check: current-execution.md says active phase IN PROGRESS, project.md must agree.
    # current-execution.md "Track status" section enumerates phases with ✅/🔵/⏸️.
    if echo "$PHASE_ROW" | grep -q "DONE"; then
      # If project.md says DONE but current-execution.md still calls it active → mismatch.
      if grep -qE "Phase ${ACTIVE_PHASE} (IN PROGRESS|🔵|in progress)" "$CURRENT_EXEC" 2>/dev/null; then
        echo "[project-md-staleness-check] WARN: Phase $ACTIVE_PHASE = DONE in project.md but IN PROGRESS in current-execution.md." >&2
        WARN_COUNT=$(( WARN_COUNT + 1 ))
      fi
    fi
  fi
fi

# ============================================================================
# Check B: project.md mtime vs newest ADR
# ============================================================================
if [ -d "$DECISIONS_DIR" ]; then
  PROJECT_MTIME="$(find "$PROJECT_MD" -printf '%T@\n' 2>/dev/null | head -1)"
  NEWEST_ADR_MTIME="$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' -type f -printf '%T@\t%f\n' 2>/dev/null \
                      | sort -rn | head -1)"
  NEWEST_ADR_TS="$(echo "$NEWEST_ADR_MTIME" | cut -f1)"
  NEWEST_ADR_NAME="$(echo "$NEWEST_ADR_MTIME" | cut -f2)"

  if [ -n "$PROJECT_MTIME" ] && [ -n "$NEWEST_ADR_TS" ]; then
    # Compare floats via awk — bash arithmetic doesn't handle floats.
    OLDER="$(awk -v p="$PROJECT_MTIME" -v a="$NEWEST_ADR_TS" 'BEGIN{print (p < a) ? 1 : 0}')"
    if [ "$OLDER" = "1" ]; then
      DELTA_HOURS="$(awk -v p="$PROJECT_MTIME" -v a="$NEWEST_ADR_TS" 'BEGIN{printf "%.1f", (a - p) / 3600}')"
      # Tolerate <2h drift (ADR + project.md often updated minutes apart).
      OVER="$(awk -v d="$DELTA_HOURS" 'BEGIN{print (d > 2.0) ? 1 : 0}')"
      if [ "$OVER" = "1" ]; then
        echo "[project-md-staleness-check] WARN: project.md mtime $DELTA_HOURS h older than newest ADR ($NEWEST_ADR_NAME)." >&2
        echo "[project-md-staleness-check] Action: update project.md '## Recent Architectural Decisions' with the new ADR summary." >&2
        WARN_COUNT=$(( WARN_COUNT + 1 ))
      fi
    fi
  fi
fi

if [ "$WARN_COUNT" -gt 0 ]; then
  echo "[$TS] project-md-staleness-check: warns=$WARN_COUNT session=$SESSION_ID phase=${ACTIVE_PHASE:-?}" >> "$LOG" 2>/dev/null || true
fi

touch "$MARKER" 2>/dev/null || true
exit 0
