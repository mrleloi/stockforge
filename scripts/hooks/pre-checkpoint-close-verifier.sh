#!/usr/bin/env bash
# pre-checkpoint-close-verifier.sh — Stop hook detecting M-S67-3 pattern.
# L-S67-5 mitigation: agent should run `git status --short` BEFORE authoring "what
# survived" narrative in checkpoint close. M-S67-3 was: S67 checkpoint claimed only
# D1 survived, but git status showed D2+D3+D5 also in working tree → narrative drift
# from empirical state. This Stop hook detects post-hoc: if checkpoints/latest.md was
# modified this session AND git status shows entries whose basenames are NOT mentioned
# in the checkpoint text → emit WARN + notification (after whitelist filter).
#
# Wired: Stop (after autonomous-stop-watchdog.sh, before bash-hook-lint.sh)
# Kill switch: STOCKFORGE_CHECKPOINT_VERIFIER_DISABLE=1
# Detection signal: checkpoint mtime > .session-ready mtime (session-start-bootstrap.sh
# writes .session-ready on every SessionStart per its line ~124).
# Per L-S58-1 ERR-trap-aware: if/then/fi not [ x ] && Y
# Per L-S11-1 portability: bash + awk + grep + sed only

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
CKPT="$MEMORY_DIR/checkpoints/latest.md"
SESSION_READY="$MEMORY_DIR/.session-ready"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"

# Kill switch
if [ "${STOCKFORGE_CHECKPOINT_VERIFIER_DISABLE:-0}" = "1" ]; then
  exit 0
fi

# Only fire on Stop event
PAYLOAD="$(cat 2>/dev/null || true)"
HOOK_EVENT=""
if [ -n "$PAYLOAD" ]; then
  HOOK_EVENT="$(printf '%s' "$PAYLOAD" | grep -o '"hook_event_name":"[^"]*"' 2>/dev/null | head -1 | sed 's/"hook_event_name":"//;s/"//' || true)"
fi
if [ "$HOOK_EVENT" != "Stop" ]; then
  exit 0
fi

# Skip if no checkpoint or no session marker
if [ ! -f "$CKPT" ]; then
  exit 0
fi
if [ ! -f "$SESSION_READY" ]; then
  exit 0
fi

# Compare mtimes (Linux stat -c%Y / macOS stat -f%m fallback)
CKPT_MTIME="$(stat -c%Y "$CKPT" 2>/dev/null || stat -f%m "$CKPT" 2>/dev/null || echo 0)"
SESSION_START_TS="$(stat -c%Y "$SESSION_READY" 2>/dev/null || stat -f%m "$SESSION_READY" 2>/dev/null || echo 0)"

# If checkpoint not modified this session, skip
if [ "$CKPT_MTIME" -le "$SESSION_START_TS" ]; then
  exit 0
fi

# Run git status --short in PROJECT_DIR
cd "$PROJECT_DIR" 2>/dev/null || exit 0
GIT_STATUS="$(git status --short 2>/dev/null || true)"
if [ -z "$GIT_STATUS" ]; then
  exit 0
fi

# Whitelist: auto-generated/transient paths NOT expected in checkpoint narrative.
# Tested against working-tree paths from `git status --short` output (after status-code prefix strip).
# Configurable via env STOCKFORGE_CHECKPOINT_VERIFIER_EXTRA_WHITELIST (extra ERE patterns appended).
WHITELIST_PATTERN='^(agent-workspace/memory/(indexes/|\.|etl-queue/|\.precompact-snapshots/|checkpoints/latest\.md|component-telemetry\.jsonl|cost-ledger\.tsv|dispatch\.jsonl|\.continue-injector|\.last-event-ts|\.session-|\.qa-last-scan|\.transcript-tokens|\.attestation-checked-|\.dispatch-pending|\.profile-template-fired|\.mode-d-recovery-fired|\.unattested-observations\.tsv|sync-state\.md|sync-tracker/_index\.md|self-awareness/(sessions-rollup\.tsv|profiles/)|drift-logs/[0-9]{4}-[0-9]{2}-[0-9]{2}-rollup\.md|boot-summary\.md|attestation-log\.tsv|sessions/|observations/|telemetry-archive/|(agent-notes|mistake-log|current-execution)-archive-[0-9]{4}-[0-9]{2}-[0-9]{2}.*\.md)|agent-workspace/learning-data/|agent-workspace/raw-sessions/|agent-workspace/session-plans/completed/|human-workspace/notifications/|.*\.tmp$)'
if [ -n "${STOCKFORGE_CHECKPOINT_VERIFIER_EXTRA_WHITELIST:-}" ]; then
  WHITELIST_PATTERN="${WHITELIST_PATTERN}|${STOCKFORGE_CHECKPOINT_VERIFIER_EXTRA_WHITELIST}"
fi

UNMENTIONED=""
UNMENTIONED_COUNT=0

# Iterate git status entries; skip whitelisted; check basename in checkpoint
while IFS= read -r line; do
  if [ -z "$line" ]; then
    continue
  fi
  # `git status --short` output: 2-char status code + space + path (or rename has " -> ")
  # Strip first 3 chars to get path
  path="${line:3}"
  # Handle rename: "old -> new" — take new path
  if printf '%s' "$path" | grep -q ' -> '; then
    path="$(printf '%s' "$path" | sed 's/.* -> //')"
  fi
  if [ -z "$path" ]; then
    continue
  fi
  # Whitelist check
  if printf '%s' "$path" | grep -qE "$WHITELIST_PATTERN" 2>/dev/null; then
    continue
  fi
  bn="$(basename "$path")"
  # Look for basename literal in checkpoint text
  if ! grep -qF "$bn" "$CKPT" 2>/dev/null; then
    UNMENTIONED_COUNT=$((UNMENTIONED_COUNT + 1))
    UNMENTIONED="${UNMENTIONED}${path}\n"
  fi
done <<< "$GIT_STATUS"

# S318: fixed-name idempotent notification (per-fire timestamps caused 203-file spam); cleared when checkpoint is consistent.
NOTIF_FILE="$NOTIF_DIR/checkpoint-mentions-incomplete.md"
if [ "$UNMENTIONED_COUNT" -ge 1 ]; then
  TS="$(date -u +%FT%TZ 2>/dev/null || true)"
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  {
    printf '# Checkpoint mentions incomplete (L-S67-5 / M-S67-3 prevention)\n\n'
    printf '**Detected at**: %s (Stop hook)\n' "$TS"
    printf '**Checkpoint**: `agent-workspace/memory/checkpoints/latest.md`\n'
    printf '**Checkpoint mtime > session start**: %s > %s\n\n' "$CKPT_MTIME" "$SESSION_START_TS"
    printf '## Git-status entries NOT mentioned by basename in checkpoint (after whitelist filter)\n\n'
    printf '%b' "$UNMENTIONED" | awk 'NF>0 {print "- `"$0"`"}'
    printf '\n## Recommended action\n\n'
    printf 'Per L-S67-5: agent must run `git status --short` BEFORE authoring checkpoint\n'
    printf '"what survived" narrative. The hook found entries above that exist in working tree\n'
    printf 'but do NOT appear by basename in the checkpoint text.\n\n'
    printf '1. Re-read git status; cross-check intentional vs missed\n'
    printf '2. If intentional omission → ignore (false positive — consider extending whitelist via\n'
    printf '   `STOCKFORGE_CHECKPOINT_VERIFIER_EXTRA_WHITELIST` env var)\n'
    printf '3. If missed → amend checkpoint to reflect actual state (M-S67-3 recurrence pattern)\n'
  } > "$NOTIF_FILE"
  printf 'WARN: %d unmentioned git-status entry(ies) in checkpoint — see %s\n' \
    "$UNMENTIONED_COUNT" "$NOTIF_FILE" >&2
else
  rm -f "$NOTIF_FILE" 2>/dev/null || true
fi

# === D3 FSM check: refuse checkpoint close if any OBSERVATION_WRITTEN row for current session ===
# An OBSERVATION_WRITTEN row means the subagent wrote its output but sidecar not yet attested.
# Closing checkpoint in this state risks orphaning the row (L-S258-2 pattern).
# Per 012-S311-wave-0-W0-1-fsm-impl.md D3: "refuse close if any OBSERVATION_WRITTEN state row
# for current session".
REGISTRY="$MEMORY_DIR/.unattested-observations.tsv"
CURRENT_SESSION="${CLAUDE_SESSION_ID:-}"
OBS_WRITTEN_COUNT=0
OBS_WRITTEN_LIST=""

if [ -f "$REGISTRY" ] && [ -n "$CURRENT_SESSION" ]; then
  while IFS= read -r reg_line; do
    case "$reg_line" in
      detected_ts*|"#"*|"") continue ;;
    esac
    reg_session="$(printf '%s' "$reg_line" | cut -f2)"
    reg_state="$(printf '%s' "$reg_line" | cut -f6)"
    reg_bn="$(printf '%s' "$reg_line" | cut -f3)"
    # Only flag rows for current session in OBSERVATION_WRITTEN state
    if [ "$reg_session" = "$CURRENT_SESSION" ] && [ "$reg_state" = "OBSERVATION_WRITTEN" ]; then
      OBS_WRITTEN_COUNT=$((OBS_WRITTEN_COUNT + 1))
      OBS_WRITTEN_LIST="${OBS_WRITTEN_LIST}${reg_bn}\n"
    fi
  done < "$REGISTRY"
fi

# S318: fixed-name idempotent notification; cleared when no OBSERVATION_WRITTEN rows pending.
NOTIF_FILE2="$NOTIF_DIR/checkpoint-obs-written-block.md"
if [ "$OBS_WRITTEN_COUNT" -ge 1 ]; then
  TS2="$(date -u +%FT%TZ 2>/dev/null || true)"
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  {
    printf '# WARN: Checkpoint close blocked — OBSERVATION_WRITTEN rows pending attestation\n\n'
    printf '**Detected at**: %s (Stop hook pre-checkpoint-close-verifier)\n' "$TS2"
    printf '**Session**: %s\n\n' "${CURRENT_SESSION}"
    printf '## Rows in OBSERVATION_WRITTEN state for current session\n\n'
    printf '%b' "$OBS_WRITTEN_LIST" | awk 'NF>0 {print "- `"$0"`"}'
    printf '\n## Why this matters\n\n'
    printf 'Per D3 (012-S311-wave-0-W0-1-fsm-impl): an OBSERVATION_WRITTEN row means the\n'
    printf 'subagent wrote its observation .md file but the sidecar has NOT been attested yet.\n'
    printf 'Closing checkpoint now risks orphaning the row (L-S258-2 recurrence pattern).\n\n'
    printf '## Recommended action\n\n'
    printf '1. Attest the observation: run attestation check for each listed basename\n'
    printf '2. Or manually transition row state to SIDECAR_ATTESTED in registry\n'
    printf '3. Then re-run checkpoint close\n\n'
    printf 'Registry: `agent-workspace/memory/.unattested-observations.tsv`\n'
  } > "$NOTIF_FILE2"
  printf 'WARN: %d OBSERVATION_WRITTEN row(s) pending attestation for session %s — see %s\n' \
    "$OBS_WRITTEN_COUNT" "$CURRENT_SESSION" "$NOTIF_FILE2" >&2
else
  rm -f "$NOTIF_FILE2" 2>/dev/null || true
fi

exit 0
