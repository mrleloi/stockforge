#!/usr/bin/env bash
# qa-pending-auto-mover.sh — HH-E.2 companion deliverable (Phase 2.5 harness hardening).
#
# Stop hook scans human-workspace/q-and-a/pending/ for bundles whose frontmatter
# `status:` starts with `answered-|closed-|resolved-` AND whose `wait_until:` (if
# present) ISO-8601 timestamp is in the past, AND no global `.auto-mv-paused` kill
# switch exists. Mv qualifying bundles to human-workspace/q-and-a/answered/.
# Idempotent per hour-bucket via marker file (L-S108-1: per-session intent
# requires per-session signal; CLAUDE_SESSION_ID empty on Windows so we use
# date hour-bucket instead).
#
# Bash + POSIX only per L-S11-1. Pipefail-bracket pattern per L-S48d-1.
# Stop hook (priority: late chain — AFTER qa-stale-urgent-escalator.sh).
# Authorized by D-031 (charter ratification 2026-05-05) — agent-workspace/CLAUDE.md
# § "Connection to human-workspace/" Auto-mv rule.

set -uo pipefail
trap 'exit 0' ERR

# === L-S48d-1 lint flag — S57 ratify per KI-S54-1 (alt-guard recognition) ===
# bash-hook-lint Check 7 flags this file. Pattern: explicit `set +o pipefail
# / grep / set -o pipefail` brackets around each grep, PLUS `|| echo ""` /
# `|| echo 0` end-of-pipeline alt-guard.
#   `STATUS_LINE=$(head -25 ... | grep -m1 '^status:' || echo "")` — alt-guard ✓
#   `WAIT_LINE=$(head -25 ... | grep -m1 '^wait_until:' || echo "")` — alt-guard ✓
#   `WAIT_EPOCH=$(date -d "$WAIT_VAL" +%s 2>/dev/null || echo 0)` — alt-guard ✓
# Pipefail-bracket double-defense; all grep usages SAFE. Lint refinement
# to recognize pipefail-bracket + `|| echo NN` deferred per KI-S54-1.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
QA_PEND="$PROJECT_DIR/human-workspace/q-and-a/pending"
QA_ANS="$PROJECT_DIR/human-workspace/q-and-a/answered"
KILL_SWITCH="$PROJECT_DIR/human-workspace/q-and-a/.auto-mv-paused"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.qa-auto-mv.log"
# Marker uses HOUR-BUCKET (NOT $CLAUDE_SESSION_ID-with-fallback per L-S108-1).
# Reason: $CLAUDE_SESSION_ID empty on Windows → fallback-to-constant ("main")
# shares marker across all sessions → permanent idempotency lockout (M-S108-1
# RCA: bundle stuck in pending/ for 24+h before discovery). Hour-bucket
# self-recovers (next hour creates fresh marker) and works on Windows.
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"  # PID fallback if date fails
MARKER="$MEM_DIR/.qa-auto-mv-fired-${BUCKET}"
TS="$(date -Iseconds)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"

# Cleanup stale markers from prior buckets (L-S108-1 prevention).
# Keeps current bucket marker; removes all others matching pattern.
for old_marker in "$MEM_DIR"/.qa-auto-mv-fired-*; do
  [ -f "$old_marker" ] || continue  # glob no-match safety
  case "$old_marker" in
    *".qa-auto-mv-fired-${BUCKET}") ;;  # current bucket → keep
    *) rm -f "$old_marker" 2>/dev/null ;;  # stale → delete
  esac
done

# Idempotency: skip if already fired this hour-bucket
[ -f "$MARKER" ] && exit 0

mkdir -p "$(dirname "$LOG")" "$QA_ANS"

# Skip if pending dir absent
[ -d "$QA_PEND" ] || { echo "fired" > "$MARKER"; exit 0; }

# Global kill switch
if [ -f "$KILL_SWITCH" ]; then
  printf '[%s] qa-pending-auto-mover: kill switch %s present; skip all mv\n' "$TS" "$KILL_SWITCH" >> "$LOG"
  echo "fired" > "$MARKER"
  exit 0
fi

# Iterate pending bundles
MOVED=0
SKIPPED=0
DEFERRED=0

set +o pipefail
PENDING_FILES=$(find "$QA_PEND" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort)
set -o pipefail

[ -z "$PENDING_FILES" ] && { echo "fired" > "$MARKER"; exit 0; }

while IFS= read -r f; do
  [ -z "$f" ] && continue
  base=$(basename "$f")

  # Condition 1: status field starts with answered-|closed-|resolved-
  set +o pipefail
  STATUS_LINE=$(head -25 "$f" 2>/dev/null | grep -m1 '^status:' || echo "")
  set -o pipefail

  if [ -z "$STATUS_LINE" ]; then
    SKIPPED=$((SKIPPED + 1))
    printf '[%s] qa-pending-auto-mover: SKIP %s (no status: field in head -25)\n' "$TS" "$base" >> "$LOG"
    continue
  fi

  # Strip "status:" prefix + leading whitespace; lowercase compare
  STATUS_VAL=$(printf '%s' "$STATUS_LINE" | sed 's/^status:[[:space:]]*//' | tr '[:upper:]' '[:lower:]')

  case "$STATUS_VAL" in
    answered-*|closed-*|resolved-*) ;;  # match → continue to condition 2
    *)
      SKIPPED=$((SKIPPED + 1))
      printf '[%s] qa-pending-auto-mover: SKIP %s (status not answered-/closed-/resolved-: %s)\n' "$TS" "$base" "$STATUS_VAL" >> "$LOG"
      continue
      ;;
  esac

  # Condition 2: wait_until ISO timestamp; if present AND > NOW → defer
  set +o pipefail
  WAIT_LINE=$(head -25 "$f" 2>/dev/null | grep -m1 '^wait_until:' || echo "")
  set -o pipefail

  if [ -n "$WAIT_LINE" ]; then
    WAIT_VAL=$(printf '%s' "$WAIT_LINE" | sed 's/^wait_until:[[:space:]]*//' | sed 's/[[:space:]]*$//')
    # Parse ISO via date -d if available; on failure, treat as past (allow mv)
    set +o pipefail
    WAIT_EPOCH=$(date -d "$WAIT_VAL" +%s 2>/dev/null || echo 0)
    set -o pipefail
    if [ "$WAIT_EPOCH" -gt "$NOW_EPOCH" ]; then
      DEFERRED=$((DEFERRED + 1))
      printf '[%s] qa-pending-auto-mover: DEFER %s (wait_until=%s > NOW)\n' "$TS" "$base" "$WAIT_VAL" >> "$LOG"
      continue
    fi
  fi

  # All conditions hold → mv
  if mv "$f" "$QA_ANS/$base" 2>>"$LOG"; then
    MOVED=$((MOVED + 1))
    printf '[%s] qa-pending-auto-mover: MV %s → answered/ (status=%s)\n' "$TS" "$base" "$STATUS_VAL" >> "$LOG"
  else
    SKIPPED=$((SKIPPED + 1))
    printf '[%s] qa-pending-auto-mover: MV-FAIL %s (status=%s)\n' "$TS" "$base" "$STATUS_VAL" >> "$LOG"
  fi
done <<< "$PENDING_FILES"

# Summary log + idempotency marker (hour-bucketed per L-S108-1)
printf '[%s] qa-pending-auto-mover: bucket=%s moved=%d deferred=%d skipped=%d\n' "$TS" "$BUCKET" "$MOVED" "$DEFERRED" "$SKIPPED" >> "$LOG"
echo "fired" > "$MARKER"

# Soft-warn stderr only when non-zero mv
if [ "$MOVED" -gt 0 ]; then
  echo "qa-pending-auto-mover: auto-mv'd $MOVED bundle(s) pending/ → answered/ (deferred=$DEFERRED skipped=$SKIPPED)" >&2
fi

exit 0
