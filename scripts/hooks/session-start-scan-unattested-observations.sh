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

if [ "$UNATTESTED_COUNT" -ge 1 ]; then
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/${TS//[:.]/-}-unattested-observations.md"
  {
    printf '# Unattested sandwich-dev observations (L-S68-1 mitigation)\n\n'
    printf '**Detected at**: %s (SessionStart scan)\n' "$TS"
    printf '**Session**: %s\n' "${CLAUDE_SESSION_ID:-unknown}"
    printf '**Source**: %s\n\n' "${SOURCE:-unknown}"
    printf '## Files lacking BOTH attestation marker AND attestation-log row\n\n'
    printf '%b' "$UNATTESTED" | awk 'NF>0 {print "- `"$0"`"}'
    printf '\n## Recommended action\n\n'
    printf 'Per L-S68-1: when /clear (or other event) killed the SubagentStop chain,\n'
    printf 'the post-dev-dispatch-attestation-check.sh hook never fired. Manual fallback:\n\n'
    printf '1. Read each observation frontmatter; cross-check claimed metrics empirically\n'
    printf '   (pytest + git-status)\n'
    printf '2. If empirical state matches → manually `touch` the marker file:\n'
    printf '   `agent-workspace/memory/.attestation-checked-<basename>`\n'
    printf '3. If divergence → treat as M-S67-3 / M-S66-1 pattern; catalog in mistake-log\n\n'
    printf 'Registry log: `agent-workspace/memory/.unattested-observations.tsv`\n'
  } > "$NOTIF_FILE"
  printf 'WARN: %d unattested sandwich-dev observation(s) detected — see %s\n' \
    "$UNATTESTED_COUNT" "$NOTIF_FILE" >&2
fi

exit 0
