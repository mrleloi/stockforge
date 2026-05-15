#!/usr/bin/env bash
# session-start-scan-unattested-observations.sh — SessionStart scan for unattested sandwich-dev observations.
# L-S68-1 mitigation: D1 attestation hook (post-dev-dispatch-attestation-check.sh) does NOT
# fire on /clear-killed SubagentStop chain. This SessionStart hook scans
# observations/sandwich-dev-*.md, detects files lacking BOTH the marker
# .attestation-checked-${BASENAME} AND a row in attestation-log.tsv. Surfaces detected
# unattested files via notification + .unattested-observations.tsv registry. Does NOT
# auto-fire D1 logic — agent decides whether to manually attest.
#
# Wired: SessionStart (after session-start-bootstrap.sh, in startup|resume|clear matcher block)
# Kill switch: STOCKFORGE_UNATTESTED_SCAN_DISABLE=1
# Per L-S58-1 ERR-trap-aware: if/then/fi not [ x ] && Y
# Per L-S68-2 find pipefail guard: glob expansion guarded with [ -f ]
# Per L-S11-1 portability: bash + awk + grep + sed only

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
OBS_DIR="$MEMORY_DIR/observations"
ATTEST_LOG="$MEMORY_DIR/attestation-log.tsv"
REGISTRY="$MEMORY_DIR/.unattested-observations.tsv"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"

# Kill switch
if [ "${STOCKFORGE_UNATTESTED_SCAN_DISABLE:-0}" = "1" ]; then
  exit 0
fi

# Read SessionStart payload (best-effort)
PAYLOAD="$(cat 2>/dev/null || true)"
SOURCE=""
if [ -n "$PAYLOAD" ]; then
  SOURCE="$(printf '%s' "$PAYLOAD" | grep -o '"source":"[^"]*"' 2>/dev/null | head -1 | sed 's/"source":"//;s/"//' || true)"
fi
case "$SOURCE" in
  startup|resume|clear|"") ;;
  *) exit 0 ;;
esac

# No observations dir → nothing to scan
if [ ! -d "$OBS_DIR" ]; then
  exit 0
fi

TS="$(date -u +%FT%TZ 2>/dev/null || true)"

# Initialise registry header if missing
if [ ! -f "$REGISTRY" ]; then
  mkdir -p "$(dirname "$REGISTRY")" 2>/dev/null || true
  printf 'detected_ts\tsession_id\tobservation_basename\tmarker_present\tlog_row_present\n' > "$REGISTRY"
fi

UNATTESTED=""
UNATTESTED_COUNT=0

# D1 attestation contract scope = sandwich-dev-*.md only
for f in "$OBS_DIR"/sandwich-dev-*.md; do
  if [ ! -f "$f" ]; then
    continue
  fi
  bn="$(basename "$f" .md)"
  marker="$MEMORY_DIR/.attestation-checked-${bn}"
  marker_present="0"
  log_row_present="0"

  if [ -f "$marker" ]; then
    marker_present="1"
  fi

  if [ -f "$ATTEST_LOG" ]; then
    if grep -qF "$bn" "$ATTEST_LOG" 2>/dev/null; then
      log_row_present="1"
    fi
  fi

  if [ "$marker_present" = "0" ] && [ "$log_row_present" = "0" ]; then
    UNATTESTED_COUNT=$((UNATTESTED_COUNT + 1))
    UNATTESTED="${UNATTESTED}${bn}\n"
    if ! grep -qF "	${bn}	" "$REGISTRY" 2>/dev/null; then
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "$TS" "${CLAUDE_SESSION_ID:-unknown}" "$bn" "$marker_present" "$log_row_present" >> "$REGISTRY"
    fi
  fi
done

# D3 FSM-aware: only ALERT for ORPHANED state rows.
# SIDECAR_ATTESTED rows are legitimate-pending (normal, attested externally or via marker).
# Legacy rows (no state col) default to SIDECAR_ATTESTED per back-compat rule (D1 spec).
ORPHANED_LIST=""
ORPHANED_COUNT=0
if [ "$UNATTESTED_COUNT" -ge 1 ]; then
  # Re-scan registry for ORPHANED-state rows only
  while IFS= read -r reg_line; do
    case "$reg_line" in
      detected_ts*|"#"*|"") continue ;;
    esac
    reg_state="$(printf '%s' "$reg_line" | cut -f6)"
    reg_bn="$(printf '%s' "$reg_line" | cut -f3)"
    # Legacy rows (empty state col) → treat as SIDECAR_ATTESTED → skip
    if [ -z "$reg_state" ]; then
      continue
    fi
    if [ "$reg_state" = "ORPHANED" ]; then
      ORPHANED_COUNT=$((ORPHANED_COUNT + 1))
      ORPHANED_LIST="${ORPHANED_LIST}${reg_bn} [ORPHANED]\n"
    fi
  done < "$REGISTRY"
fi

# S318: fixed-name idempotent notification (per-fire timestamps caused 162-file spam); cleared when no ORPHANED rows.
NOTIF_FILE="$NOTIF_DIR/unattested-observations.md"
if [ "$ORPHANED_COUNT" -ge 1 ]; then
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  {
    printf '# ALERT: Orphaned sandwich-dev observations (FSM state=ORPHANED)\n\n'
    printf '**Detected at**: %s (SessionStart scan)\n' "$TS"
    printf '**Session**: %s\n' "${CLAUDE_SESSION_ID:-unknown}"
    printf '**Source**: %s\n\n' "${SOURCE:-unknown}"
    printf '## Rows in ORPHANED state (stale IN_FLIGHT/OBSERVATION_WRITTEN >30 min)\n\n'
    printf '%b' "$ORPHANED_LIST" | awk 'NF>0 {print "- `"$0"`"}'
    printf '\n## Recommended action\n\n'
    printf 'Per L-S258-2 FSM closure (D-058 Wave 0 W0-1): ORPHANED rows require rectification.\n\n'
    printf '1. Check observation file for the subagent dispatch\n'
    printf '2. If subagent completed: transition row to SIDECAR_ATTESTED by attesting the observation\n'
    printf '3. If subagent failed: transition to RESOLVED after manual cleanup\n'
    printf '4. Use orphan-detector hook to re-scan or manually update state column in registry\n\n'
    printf 'Registry: `agent-workspace/memory/.unattested-observations.tsv`\n'
    printf 'Note: SIDECAR_ATTESTED rows are normal — only ORPHANED rows require action.\n'
  } > "$NOTIF_FILE"
  printf 'ALERT: %d ORPHANED sandwich-dev observation(s) detected — see %s\n' \
    "$ORPHANED_COUNT" "$NOTIF_FILE" >&2
elif [ "$UNATTESTED_COUNT" -ge 1 ]; then
  # Non-orphaned unattested rows: still log to registry (for audit trail) but do NOT alert
  printf 'INFO: %d unattested sandwich-dev observation(s) in registry (non-ORPHANED states, no alert)\n' \
    "$UNATTESTED_COUNT" >&2
  rm -f "$NOTIF_FILE" 2>/dev/null || true
else
  rm -f "$NOTIF_FILE" 2>/dev/null || true
fi

exit 0
