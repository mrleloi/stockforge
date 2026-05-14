#!/usr/bin/env bash
# observation-orphan-detector.sh — Stop hook: detect stale IN_FLIGHT/OBSERVATION_WRITTEN rows
# and transition them to ORPHANED state, emitting HIGH severity rows to .severity-state.tsv.
# Also re-escalates already-ORPHANED rows that have gone silent (F1 fix — W0-1b D1).
#
# Wired: Stop hook (late chain, AFTER severity-classifier.sh per D2 spec).
# Closes L-S258-2 sidecar-orphan 4th-instance URGENT.
# W0-1b: Closes F1 (single-shot escalation gap) per 013-S313-wave-0-W0-1b plan.
#
# Behavior:
#   === New transition detection (unchanged from W0-1) ===
#   - For each row in state IN_FLIGHT or OBSERVATION_WRITTEN with last-seen timestamp >30 min:
#       → transition row state to ORPHANED (update TSV in-place atomically)
#       → emit HIGH severity row to .severity-state.tsv
#
#   === Re-escalation for already-ORPHANED rows (F1 fix — W0-1b D1) ===
#   - For each row already in state ORPHANED:
#       → compute time since last HIGH emit using marker file
#          marker path: agent-workspace/memory/.orphan-reescalate-<SHA256-of-artifact-path>.last
#       → if marker absent OR marker mtime > STOCKFORGE_ORPHAN_REESCALATE_HOURS (default 6h):
#           emit HIGH severity row (or CRITICAL if >30d since first ORPHANED detection)
#           update marker mtime atomically (atomic noclobber per L-S289-1)
#       → re-emit cadence (defaults): 6h / 24h / 72h / 7d (then weekly)
#       → after STOCKFORGE_ORPHAN_CRITICAL_DAYS (default 30d) with no resolution → CRITICAL
#
#   === TSV col7 back-compat (D2) ===
#   - 7-col rows: col7 = last_transition_at; use for age computation (F2 fix)
#   - 6-col rows: fall back to col1 (detected_ts) for age proxy (back-compat)
#
#   Best-effort: RC=0 always; never breaks Stop chain on internal error
#   Back-compat: rows without state column → read as SIDECAR_ATTESTED (no action)
#
# SPAWN-CONTEXT: positional-arg (hook receives Stop JSON payload on stdin)
#
# Per L-S11-1 portability: bash + awk + grep + sed only (no python imports here)
# Per L-S289-1 atomic noclobber: TSV mutations use tmp-file + mv; marker writes use noclobber
# Per L-S58-1 ERR-trap-aware: if/then/fi not [ x ] && Y
# Per L-S247-1: companion firing-test scripts/hooks/firing-tests/observation-orphan-detector-fire-test.sh
#
# Kill switch: STOCKFORGE_ORPHAN_DETECTOR_DISABLE=1
# Re-escalation kill switch: STOCKFORGE_ORPHAN_REESCALATE_DISABLE=1

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
REGISTRY="$MEMORY_DIR/.unattested-observations.tsv"
SEVERITY_STATE="$MEMORY_DIR/.severity-state.tsv"
LOG="$MEMORY_DIR/.orphan-detector.log"
ORPHAN_THRESHOLD_MINUTES="${STOCKFORGE_ORPHAN_THRESHOLD_MINUTES:-30}"
ORPHAN_REESCALATE_HOURS="${STOCKFORGE_ORPHAN_REESCALATE_HOURS:-6}"
ORPHAN_CRITICAL_DAYS="${STOCKFORGE_ORPHAN_CRITICAL_DAYS:-30}"

TS="$(date -u +%FT%TZ 2>/dev/null || true)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"

# Kill switch
if [ "${STOCKFORGE_ORPHAN_DETECTOR_DISABLE:-0}" = "1" ]; then
  exit 0
fi

# Only fire on Stop events
PAYLOAD="$(cat 2>/dev/null || true)"
HOOK_EVENT=""
if [ -n "$PAYLOAD" ]; then
  HOOK_EVENT="$(printf '%s' "$PAYLOAD" | grep -o '"hook_event_name":"[^"]*"' 2>/dev/null | head -1 | sed 's/"hook_event_name":"//;s/"//' || true)"
fi
if [ -n "$HOOK_EVENT" ] && [ "$HOOK_EVENT" != "Stop" ]; then
  exit 0
fi

# No registry → nothing to scan
if [ ! -f "$REGISTRY" ]; then
  exit 0
fi

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# === Helper: age in minutes from an ISO-8601 UTC timestamp ===
# Used for orphan threshold check (col7 if present, col1 fallback).
age_minutes_from_ts() {
  local iso_ts="$1"
  local row_epoch
  row_epoch="$(date -u -d "$iso_ts" +%s 2>/dev/null || echo 0)"
  if [ "$row_epoch" -eq 0 ]; then
    # Unparseable → treat as very old (999 minutes) — counts as stale
    echo 999
    return
  fi
  echo $(( (NOW_EPOCH - row_epoch) / 60 ))
}

# === Helper: age in hours from file mtime ===
# Returns hours since marker file was last modified.
# If file does not exist, returns 99999 (effectively infinity → always re-emit).
marker_age_hours() {
  local marker_path="$1"
  if [ ! -f "$marker_path" ]; then
    echo 99999
    return
  fi
  local mtime
  mtime="$(stat -c%Y "$marker_path" 2>/dev/null || stat -f%m "$marker_path" 2>/dev/null || echo 0)"
  if [ "$mtime" -eq 0 ]; then
    echo 99999
    return
  fi
  echo $(( (NOW_EPOCH - mtime) / 3600 ))
}

# === Helper: age in days from an ISO-8601 UTC timestamp ===
age_days_from_ts() {
  local iso_ts="$1"
  local row_epoch
  row_epoch="$(date -u -d "$iso_ts" +%s 2>/dev/null || echo 0)"
  if [ "$row_epoch" -eq 0 ]; then
    echo 0
    return
  fi
  echo $(( (NOW_EPOCH - row_epoch) / 86400 ))
}

# === Helper: SHA256 of artifact path string (for marker filename) ===
# Uses sha256sum (Linux) or shasum -a 256 (macOS).
sha256_of() {
  local s="$1"
  printf '%s' "$s" | sha256sum 2>/dev/null | cut -d' ' -f1 || \
  printf '%s' "$s" | shasum -a 256 2>/dev/null | cut -d' ' -f1 || \
  # Fallback: simple CRC-style using cksum (always available)
  printf '%s' "$s" | cksum 2>/dev/null | awk '{print $1}' || \
  echo "fallback"
}

# === Helper: write/touch marker file atomically (L-S289-1 noclobber) ===
# Creates parent dirs if needed. Uses noclobber for create; touch for update.
touch_marker() {
  local marker_path="$1"
  mkdir -p "$(dirname "$marker_path")" 2>/dev/null || true
  if [ ! -f "$marker_path" ]; then
    # First create: use noclobber (set -C) to prevent races
    ( set -C; printf '%s\n' "$TS" > "$marker_path" 2>/dev/null ) || true
  else
    # Already exists: update mtime
    touch "$marker_path" 2>/dev/null || true
  fi
}

# States that are orphan candidates (trigger new ORPHANED transition)
is_active_state() {
  local state="$1"
  case "$state" in
    IN_FLIGHT|OBSERVATION_WRITTEN) return 0 ;;
    *) return 1 ;;
  esac
}

# Read registry, find orphan candidates, rewrite registry with updated states
# and append to .severity-state.tsv
TMP_REGISTRY="$REGISTRY.orphan-detector-tmp.$$"
ORPHAN_COUNT=0
REESCALATE_COUNT=0

# Process TSV line by line; emit updated rows to tmp file
while IFS= read -r line; do
  # Pass through header and comment lines unchanged
  case "$line" in
    detected_ts*|"#"*|"") printf '%s\n' "$line" >> "$TMP_REGISTRY"; continue ;;
  esac

  # Parse tab-separated columns
  col1="$(printf '%s' "$line" | cut -f1)"   # detected_ts (immutable)
  col2="$(printf '%s' "$line" | cut -f2)"   # session_id
  col3="$(printf '%s' "$line" | cut -f3)"   # observation_basename
  col4="$(printf '%s' "$line" | cut -f4)"   # marker_present
  col5="$(printf '%s' "$line" | cut -f5)"   # log_row_present
  col6="$(printf '%s' "$line" | cut -f6)"   # state (may be empty for legacy rows)
  col7="$(printf '%s' "$line" | cut -f7)"   # last_transition_at (W0-1b; may be absent)

  # Back-compat: missing state column → SIDECAR_ATTESTED (no action)
  if [ -z "$col6" ]; then
    col6="SIDECAR_ATTESTED"
  fi

  # D2: use col7 (last_transition_at) if present; fall back to col1 (detected_ts)
  age_ts="$col1"
  if [ -n "$col7" ]; then
    age_ts="$col7"
  fi

  if is_active_state "$col6"; then
    # === New ORPHANED transition path (unchanged from W0-1) ===
    age_min="$(age_minutes_from_ts "$age_ts")"
    if [ "$age_min" -gt "$ORPHAN_THRESHOLD_MINUTES" ]; then
      # Transition to ORPHANED; write col7 = current TS
      col6="ORPHANED"
      col7="$TS"
      ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
      # Emit HIGH severity row
      age_hours=$(( age_min / 60 ))
      rel_path="agent-workspace/memory/.unattested-observations.tsv"
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "HIGH" \
        "$rel_path#${col3}" \
        "$age_hours" \
        "ESCALATE-ASKUSERQUESTION" \
        "$TS" >> "$SEVERITY_STATE" 2>/dev/null || true
      printf '[%s] ORPHANED: %s (age %d min > %d min threshold)\n' \
        "$TS" "$col3" "$age_min" "$ORPHAN_THRESHOLD_MINUTES" >> "$LOG" 2>/dev/null || true
      printf 'WARN: observation-orphan-detector: %s → ORPHANED (age %d min)\n' \
        "$col3" "$age_min" >&2
    fi

  elif [ "$col6" = "ORPHANED" ] && [ "${STOCKFORGE_ORPHAN_REESCALATE_DISABLE:-0}" != "1" ]; then
    # === Re-escalation path for already-ORPHANED rows (F1 fix — D1) ===
    rel_path="agent-workspace/memory/.unattested-observations.tsv"
    artifact_key="${rel_path}#${col3}"
    artifact_sha="$(sha256_of "$artifact_key")"
    marker_path="$MEMORY_DIR/.orphan-reescalate-${artifact_sha}.last"

    marker_age_h="$(marker_age_hours "$marker_path")"

    if [ "$marker_age_h" -gt "$ORPHAN_REESCALATE_HOURS" ]; then
      # Determine severity: CRITICAL if orphaned for >ORPHAN_CRITICAL_DAYS days
      age_days="$(age_days_from_ts "$col1")"
      emit_severity="HIGH"
      if [ "$age_days" -gt "$ORPHAN_CRITICAL_DAYS" ]; then
        emit_severity="CRITICAL"
      fi

      # Emit severity row
      printf '%s\t%s\t%s\t%s\t%s\n' \
        "$emit_severity" \
        "$artifact_key" \
        "orphan-reescalate-${marker_age_h}h-silent" \
        "ESCALATE-ASKUSERQUESTION" \
        "$TS" >> "$SEVERITY_STATE" 2>/dev/null || true

      # Update marker (atomic noclobber create or touch-update)
      touch_marker "$marker_path"

      REESCALATE_COUNT=$((REESCALATE_COUNT + 1))
      printf '[%s] RE-ESCALATE (%s): %s (marker_age=%dh > threshold=%dh)\n' \
        "$TS" "$emit_severity" "$col3" "$marker_age_h" "$ORPHAN_REESCALATE_HOURS" >> "$LOG" 2>/dev/null || true
      printf 'WARN: observation-orphan-detector: re-escalating orphan %s (%s, %dh since last emit)\n' \
        "$col3" "$emit_severity" "$marker_age_h" >&2
    fi
  fi

  # Emit row (possibly with updated state col6 + col7)
  # Always write 7-col row: if col7 was absent before, col7 = col1 (back-compat upgrade)
  if [ -z "$col7" ]; then
    col7="$col1"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$col1" "$col2" "$col3" "$col4" "$col5" "$col6" "$col7" >> "$TMP_REGISTRY"
done < "$REGISTRY"

# Atomic replace if we made changes (new orphans OR re-escalation updated col7)
CHANGED=$(( ORPHAN_COUNT + REESCALATE_COUNT ))
if [ "$CHANGED" -gt 0 ] && [ -f "$TMP_REGISTRY" ]; then
  mv "$TMP_REGISTRY" "$REGISTRY" 2>/dev/null || true
else
  rm -f "$TMP_REGISTRY" 2>/dev/null || true
fi

if [ "$ORPHAN_COUNT" -gt 0 ]; then
  printf '[%s] orphan-detector: %d row(s) transitioned to ORPHANED\n' \
    "$TS" "$ORPHAN_COUNT" >> "$LOG" 2>/dev/null || true
fi
if [ "$REESCALATE_COUNT" -gt 0 ]; then
  printf '[%s] orphan-detector: %d ORPHANED row(s) re-escalated\n' \
    "$TS" "$REESCALATE_COUNT" >> "$LOG" 2>/dev/null || true
fi

exit 0
