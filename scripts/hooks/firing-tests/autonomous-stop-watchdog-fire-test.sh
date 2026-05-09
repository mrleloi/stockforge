#!/usr/bin/env bash
# Firing-test for autonomous-stop-watchdog.sh § 4b SELF_PAUSE_HIT detector
# (Phase 3.5 T3.4 Cluster 4 RETROFIT per L-S51-1).
#
# Validates the regex extended 3× across S44 / S45 / S47 against:
#   - 7 known pause phrasings (must trigger SELF_PAUSE_HIT=suspected)
#   - 4 control phrasings (must NOT trigger; legit "continue" uses)
#
# Test sequence: stage current-execution.md with autonomous_mode=true, synthesize
# transcript with phrase, pass stdin JSON pointing at the transcript, run hook,
# inspect .autonomous-stop-watchdog.log for self_pause_hit field.
#
# Mode-D / Mode-C / API recovery suppression: STOCKFORGE_RECOVERY_DRY_RUN=1 +
# no checkpoint file in tempdir → MODE_D_FIRE=0; no API error / wind-down
# language in transcript → API_ERROR / PREMATURE_WINDOWN clean.
#
# Exit 0 = all assertions pass. Exit 1 = any failure.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../autonomous-stop-watchdog.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory"
# Stage current-execution.md with autonomous_mode=true
printf '# Current Execution\n\n**autonomous_mode**: true\n' > "$TEMPDIR/agent-workspace/memory/current-execution.md"

# Helper: run a single phrase + assert SELF_PAUSE_HIT field
run_case() {
  local label="$1" phrase="$2" expected="$3"  # expected: "pause" or "ok"
  local transcript="$TEMPDIR/transcript-$label.jsonl"
  # Synthesize transcript line WITHOUT "type":"tool_use" so SELF_PAUSE check can fire
  printf '{"role":"assistant","content":[{"type":"text","text":"%s"}]}\n' "$phrase" > "$transcript"

  # Clean previous logs
  rm -f "$TEMPDIR/agent-workspace/memory/.autonomous-self-pause-alert.log"
  rm -f "$TEMPDIR/agent-workspace/memory/.autonomous-stop-watchdog.log"

  local stdin_json
  stdin_json=$(printf '{"transcript_path":"%s","session_id":"test-%s"}' "$transcript" "$label")

  STOCKFORGE_RECOVERY_DRY_RUN=1 CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" <<<"$stdin_json" >/dev/null 2>&1 || true

  local watchdog_log="$TEMPDIR/agent-workspace/memory/.autonomous-stop-watchdog.log"
  local self_pause_field="absent"
  if [ -f "$watchdog_log" ]; then
    self_pause_field=$(grep -oE 'self_pause_hit=[a-z]+' "$watchdog_log" | tail -1 | sed 's/.*=//' || echo "absent")
    [ -z "$self_pause_field" ] && self_pause_field="absent"
  fi

  if [ "$expected" = "pause" ]; then
    if [ "$self_pause_field" = "suspected" ]; then
      printf 'PASS [%s] pause caught: %s\n' "$label" "$phrase"
      return 0
    else
      printf 'FAIL [%s] pause MISSED (self_pause_hit=%s): %s\n' "$label" "$self_pause_field" "$phrase"
      [ -f "$watchdog_log" ] && { echo "  --- watchdog log ---"; cat "$watchdog_log"; echo "  --------------------"; }
      return 1
    fi
  else
    if [ "$self_pause_field" = "suspected" ]; then
      printf 'FAIL [%s] control false-positive: %s\n' "$label" "$phrase"
      return 1
    else
      printf 'PASS [%s] control clean: %s\n' "$label" "$phrase"
      return 0
    fi
  fi
}

PASS=0; FAIL=0

# Pause cases (7 — must trigger SELF_PAUSE_HIT=suspected)
# Each phrase covers a distinct alternation in the § 4b regex extended at S44/S45/S47.
declare -a pause_cases=(
  "P1|Holding here. Stop hook + Mode-D handles boundaries."
  "P2|I will wait for your call before next session."
  "P3|Next continue enters S52 entry."
  "P4|Deferring to you for the next decision."
  "P5|Standing by until session boundary."
  "P6|S52 entry is the next session start."
  "P7|Wait for fresh session to trigger handoff."
)
for tc in "${pause_cases[@]}"; do
  label="${tc%%|*}"; phrase="${tc#*|}"
  if run_case "$label" "$phrase" "pause"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
done

# Control cases (6 — must NOT trigger; legit usage of "continue/wait/next" + archive-prose)
# C5/C6 added S55 (PoC retrofit; KI-S55-1): demonstrates that L-S53-2 lint advice (anchor
# with ^) is a FALSE POSITIVE for this hook's content-search context. C5 covers archive-style
# S<N> NEXT prose (the M-S53-2 family pattern in markdown context, but here in transcript
# narration it should NOT trigger because alternation requires entry-is structure, not just
# S<N>+next). C6 covers S<N> entry references lacking the `is.{0,30}next` proximity.
declare -a ok_cases=(
  "C1|If you continue with this approach we will likely succeed."
  "C2|Will continue running tests in parallel batches."
  "C3|Let it wait for build artifacts before deploying."
  "C4|Phase 3 next item is BC-7 sentiment ingestion."
  "C5|Reading the S38/S42 NEXT branching gate is documented in archive context."
  "C6|S40 entry was archived in current-execution-archive.md last week."
)
for tc in "${ok_cases[@]}"; do
  label="${tc%%|*}"; phrase="${tc#*|}"
  if run_case "$label" "$phrase" "ok"; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
done

echo ""
printf '=== Self-pause detection: PASS=%d FAIL=%d (target: 13/13) ===\n' "$PASS" "$FAIL"

# === S67-fix Mode-D age-threshold regression tests (M-S67-2 prevention) ===
# Helper: stage a checkpoint with controlled age, run hook, assert MODE-D fired (or not).
mode_d_case() {
  local label="$1" age_seconds="$2" max_age_env="$3" expected="$4"  # expected: "fire" or "noop"
  # Stage transcript with NO pause/error language (clean STOP)
  local transcript="$TEMPDIR/transcript-d-$label.jsonl"
  printf '{"role":"assistant","content":[{"type":"tool_use","name":"X","input":{}}]}\n' > "$transcript"

  # Stage checkpoint with controlled mtime
  mkdir -p "$TEMPDIR/agent-workspace/memory/checkpoints"
  local ckpt="$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
  printf '# checkpoint stub\n' > "$ckpt"
  if command -v touch >/dev/null 2>&1; then
    touch -d "$age_seconds seconds ago" "$ckpt" 2>/dev/null \
      || touch -t "$(date -d "$age_seconds seconds ago" +%Y%m%d%H%M.%S 2>/dev/null)" "$ckpt" 2>/dev/null \
      || true
  fi

  # Reset logs + markers
  rm -f "$TEMPDIR/agent-workspace/memory/.autonomous-stop-watchdog.log"
  rm -f "$TEMPDIR/agent-workspace/memory/.mode-d-recovery-fired-"*
  rm -f "$TEMPDIR/agent-workspace/memory/.transcript-tokens"
  printf '5000\n' > "$TEMPDIR/agent-workspace/memory/.transcript-tokens"  # below cliff

  local stdin_json
  stdin_json=$(printf '{"transcript_path":"%s","session_id":"test-d-%s"}' "$transcript" "$label")

  # Run hook with DRY_RUN=1 (don't actually fire continue-injector); pass max_age env
  local env_max_age=""
  if [ -n "$max_age_env" ]; then env_max_age="STOCKFORGE_MODE_D_MAX_AGE=$max_age_env"; fi
  env STOCKFORGE_RECOVERY_DRY_RUN=1 $env_max_age CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" <<<"$stdin_json" >/dev/null 2>&1 || true

  local watchdog_log="$TEMPDIR/agent-workspace/memory/.autonomous-stop-watchdog.log"
  local fired="no"
  if [ -f "$watchdog_log" ] && grep -q "MODE-D CLEAN-HANDOFF FIRED" "$watchdog_log"; then
    fired="yes"
  fi

  if [ "$expected" = "fire" ]; then
    if [ "$fired" = "yes" ]; then
      printf 'PASS [D-%s] MODE-D fired (age=%ss, max=%s)\n' "$label" "$age_seconds" "${max_age_env:-default}"
      return 0
    fi
    printf 'FAIL [D-%s] expected MODE-D fire (age=%ss, max=%s) — log:\n' "$label" "$age_seconds" "${max_age_env:-default}"
    [ -f "$watchdog_log" ] && cat "$watchdog_log"
    return 1
  else
    if [ "$fired" = "no" ]; then
      printf 'PASS [D-%s] MODE-D no-op (age=%ss, max=%s)\n' "$label" "$age_seconds" "${max_age_env:-default}"
      return 0
    fi
    printf 'FAIL [D-%s] unexpected MODE-D fire (age=%ss, max=%s)\n' "$label" "$age_seconds" "${max_age_env:-default}"
    return 1
  fi
}

D_PASS=0; D_FAIL=0
# TC-D1: 5s old checkpoint, default 300s → fire
if mode_d_case "1-fresh" 5 "" "fire"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi
# TC-D2 (M-S67-2 regression): 90s old, default 300 → fire (legacy 60s would have blocked)
if mode_d_case "2-90s" 90 "" "fire"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi
# TC-D3: 250s old, default 300 → fire (within new envelope)
if mode_d_case "3-250s" 250 "" "fire"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi
# TC-D4: 400s old, default 300 → no-op (above threshold)
if mode_d_case "4-400s" 400 "" "noop"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi
# TC-D5: 90s old, env override max=60 → no-op (override tighter than legacy default)
if mode_d_case "5-env-tight" 90 "60" "noop"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi
# TC-D6: 500s old, env override max=900 → fire (override looser)
if mode_d_case "6-env-loose" 500 "900" "fire"; then D_PASS=$((D_PASS+1)); else D_FAIL=$((D_FAIL+1)); fi

echo ""
printf '=== Mode-D age-threshold (M-S67-2): PASS=%d FAIL=%d (target: 6/6) ===\n' "$D_PASS" "$D_FAIL"

TOTAL_PASS=$(( PASS + D_PASS ))
TOTAL_FAIL=$(( FAIL + D_FAIL ))
echo ""
printf '=== GRAND TOTAL: PASS=%d FAIL=%d (target: 19/19) ===\n' "$TOTAL_PASS" "$TOTAL_FAIL"
[ "$TOTAL_FAIL" -eq 0 ] && exit 0 || exit 1
