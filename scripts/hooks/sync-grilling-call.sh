#!/usr/bin/env bash
# sync-grilling-call.sh — wrapper for sync-tracker-update.sh with 5-arg contract.
#
# Per M-S98-1 prevention rule 3 (S98) + M-S101-1 same-day recurrence (S101 deterministic
# guard shipped in sync-tracker-update.sh:53-62). This wrapper adds defense-in-depth by
# hiding the $3 OVERRIDE_DELTA optional positional arg, eliminating the arg-position
# confusion that caused both M-S98-1 and M-S101-1 (long reason text or decision_id
# landing in $3 OVERRIDE_DELTA slot, awk replay coercing non-numeric to 0).
#
# S129 enhancement (L-S69-1 2nd-instance promote-to-hook): on successful invocation,
# also updates `last_check:` + `last_check_session:` fields in
# agent-workspace/memory/sync-state.md frontmatter. Eliminates recurring drift between
# events.tsv (canonical) + sync-state.md narrative (supplementary). Pattern 1st-instance
# observed S80 (M-S67-3-style under-recording, manual backfill at S83); 2nd-instance
# S86-S128 (15 wrapper events without narrative update). Forward Policy 2nd-instance
# trigger applied: promote-to-hook. Best-effort — wrapper does not fail if sync-state.md
# missing/malformed (events.tsv canonical; narrative supplementary).
#
# Contract (5 positional args, all required):
#   $1 category         e.g. SCOPE | LANGUAGE | DOMAIN_UBIQUITOUS | DESIGN_THINKING | DECISION_ROUTING
#   $2 event_type       e.g. charter_match | drift_signal | q_and_a_resolution | decision_correctness
#   $3 decision_id      e.g. sync-grilling-S102 (no spaces; identifies the event)
#   $4 source_evidence  file path to source (e.g. agent-workspace/memory/sync-state.md)
#   $5 reason           free-form text describing why this event was recorded
#
# Behavior:
#   1. Always passes "" (empty) as $3 OVERRIDE_DELTA to sync-tracker-update.sh,
#      triggering the weights.yaml `weight_<event_type>` lookup. Override mode is
#      unsupported here (use sync-tracker-update.sh directly for non-default deltas).
#   2. On rc=0 from sync-tracker-update.sh: extract S<N> from $3 decision_id; update
#      sync-state.md frontmatter `last_check: <today>` + `last_check_session: S<N>`.
#   3. Wrapper exits with rc from sync-tracker-update.sh (0 or non-zero); sync-state.md
#      update is best-effort and never affects exit code.
#
# Usage:
#   sync-grilling-call.sh SCOPE charter_match sync-grilling-S102 \
#     agent-workspace/memory/sync-state.md \
#     "S102 sync-grilling refresher: routine auto-tier; ..."
#
# Phase 0 portability per L-S11-1: bash + POSIX only.
# Per L-S65-2 (harness priority #1) + L-S69-1 (2nd-instance promote): this wrapper is
# the codification path; eliminates manual narrative backfill cycles.

set -euo pipefail

CAT="${1:-}"
EVT="${2:-}"
DEC_ID="${3:-}"
SRC_EV="${4:-}"
REASON="${5:-}"

if [ -z "$CAT" ] || [ -z "$EVT" ] || [ -z "$DEC_ID" ] || [ -z "$SRC_EV" ] || [ -z "$REASON" ]; then
  cat >&2 <<USAGE
[sync-grilling-call] usage: $0 <category> <event_type> <decision_id> <source_evidence> <reason>

All 5 args required. Example:
  $0 SCOPE charter_match sync-grilling-S102 \\
     agent-workspace/memory/sync-state.md \\
     "S102 sync-grilling refresher: routine auto-tier; ..."

Categories: LANGUAGE | DOMAIN_UBIQUITOUS | DESIGN_THINKING | SCOPE | DECISION_ROUTING
Event types: decision_correctness | charter_match | q_and_a_resolution
             drift_signal | decision_correction | decision_revocation | thesis_revocation

Per M-S98-1 + M-S101-1 prevention: this wrapper hides the \$3 OVERRIDE_DELTA arg to
prevent the arg-position confusion that caused both mistakes. For non-default deltas,
call sync-tracker-update.sh directly.
USAGE
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
UPDATE_HOOK="$SCRIPT_DIR/sync-tracker-update.sh"
SYNC_STATE="$ROOT_DIR/agent-workspace/memory/sync-state.md"

if [ ! -f "$UPDATE_HOOK" ]; then
  echo "[sync-grilling-call] sync-tracker-update.sh not found at $UPDATE_HOOK" >&2
  exit 2
fi

# Always pass "" as $3 OVERRIDE_DELTA → underlying script uses weight_<event_type> from weights.yaml.
set +e
bash "$UPDATE_HOOK" "$CAT" "$EVT" "" "$DEC_ID" "$SRC_EV" "$REASON"
RC=$?
set -e

# S129 enhancement: on rc=0, update sync-state.md last_check + last_check_session.
# Best-effort: missing/malformed sync-state.md or no S<N> in decision_id does not
# affect wrapper exit code (events.tsv is canonical; narrative is supplementary).
#
# S130 fix (M-S130-1): use LOCAL date (no -u) to match session-file naming convention
# (sessions/YYYY-MM-DD-session-N.md uses local time at write). UTC-vs-local mismatch
# caused sync-grilling-trigger.sh to spuriously fire SYNC-GRILLING DUE at S130 SessionStart
# despite S129 wrapper writing last_check successfully (UTC 2026-05-06 vs Vietnam-local
# session-file dates 2026-05-07; hook compared filename-date > last_check → 6 sessions
# elapsed). Aligning wrapper to LOCAL matches the consumer side.
if [ "$RC" -eq 0 ] && [ -f "$SYNC_STATE" ]; then
  TODAY="$(date +%Y-%m-%d)"
  SESSION_N=""
  if printf '%s' "$DEC_ID" | grep -qE 'S[0-9]+' 2>/dev/null; then
    SESSION_N="$(printf '%s' "$DEC_ID" | grep -oE 'S[0-9]+' | tail -1)"
  fi
  if [ -n "$SESSION_N" ]; then
    if awk -v today="$TODAY" -v sess="$SESSION_N" '
      /^last_check:[[:space:]]/ && !done_lc { print "last_check: " today; done_lc=1; next }
      /^last_check_session:[[:space:]]/ && !done_ls { print "last_check_session: " sess; done_ls=1; next }
      { print }
    ' "$SYNC_STATE" > "$SYNC_STATE.tmp"; then
      mv -f "$SYNC_STATE.tmp" "$SYNC_STATE"
    else
      rm -f "$SYNC_STATE.tmp"
    fi
  fi
fi

exit "$RC"
