#!/usr/bin/env bash
# escalation-engine.sh — Phase B of unified severity/escalation system (proposal §2 Layer 3)
#
# Reads agent-workspace/memory/.severity-state.tsv (produced by severity-classifier.sh)
# and acts per severity row:
#   CRITICAL → write .autonomous-BLOCKED flag + URGENT entry + Telegram push
#   HIGH     → append URGENT + UserPromptSubmit additionalContext for AskUserQuestion + Telegram push
#   MEDIUM   → append weekly digest entry
#   LOW      → log only
#
# Fires on three cadences: Stop + SessionStart + UserPromptSubmit.
# Argument $1 = event name (Stop / SessionStart / UserPromptSubmit). Defaults to "Stop".
#
# Bash + POSIX only per L-S11-1. RC=0 always (best-effort).
# UserPromptSubmit cadence: outputs JSON additionalContext via stdout when HIGH items demand AskUserQuestion.

set -uo pipefail
trap 'exit 0' ERR

EVENT="${1:-${HOOK_EVENT:-Stop}}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
STATE_FILE="$MEM_DIR/.severity-state.tsv"
URGENT="$PROJECT_DIR/human-workspace/notifications/urgent.md"
BLOCK_FLAG="$MEM_DIR/.autonomous-BLOCKED"
LOG="$MEM_DIR/.escalation-engine.log"
TELEGRAM_HOOK="$PROJECT_DIR/scripts/hooks/telegram-push.sh"

TS="$(date -Iseconds)"
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"

mkdir -p "$MEM_DIR" "$(dirname "$URGENT")"

# Skip if state file absent (classifier hasn't run yet)
[ -f "$STATE_FILE" ] || exit 0

# === Block-grace: if block-control.sh recently cleared the gate, suppress CRITICAL
# auto-raise for the grace window (anti-deadlock — gives the agent room to fix the
# root cause without escalation-engine instantly re-blocking the same CRITICAL). ===
GRACE_FILE="$MEM_DIR/.block-grace"
GRACE_ACTIVE=0
if [ -f "$GRACE_FILE" ]; then
  GRACE_EXP=$(grep '^expiry_epoch=' "$GRACE_FILE" 2>/dev/null | head -1 | sed 's/^expiry_epoch=//' || echo 0)
  case "$GRACE_EXP" in ''|*[!0-9]*) GRACE_EXP=0 ;; esac
  GRACE_NOW=$(date +%s 2>/dev/null || echo 0)
  case "$GRACE_NOW" in ''|*[!0-9]*) GRACE_NOW=0 ;; esac
  if [ "$GRACE_EXP" -gt "$GRACE_NOW" ]; then
    GRACE_ACTIVE=1
  else
    rm -f "$GRACE_FILE" 2>/dev/null || true
  fi
fi

# Per-event idempotency markers (hour-bucket to avoid stale-marker bug — L-S108-1)
MARKER="$MEM_DIR/.escalation-fired-${EVENT}-${BUCKET}"

# Cleanup stale markers
for old in "$MEM_DIR"/.escalation-fired-*; do
  [ -f "$old" ] || continue
  case "$old" in
    *".escalation-fired-${EVENT}-${BUCKET}") ;;
    *".escalation-fired-${EVENT}-"*) rm -f "$old" 2>/dev/null ;;
  esac
done

# === Collect rows by severity (strip header/comment lines) ===
CRIT_ROWS=$(grep "^CRITICAL"$'\t' "$STATE_FILE" 2>/dev/null || true)
HIGH_ROWS=$(grep "^HIGH"$'\t' "$STATE_FILE" 2>/dev/null || true)
MED_ROWS=$(grep "^MEDIUM"$'\t' "$STATE_FILE" 2>/dev/null || true)

CRIT_N=$([ -z "$CRIT_ROWS" ] && echo 0 || printf '%s\n' "$CRIT_ROWS" | grep -c .)
HIGH_N=$([ -z "$HIGH_ROWS" ] && echo 0 || printf '%s\n' "$HIGH_ROWS" | grep -c .)
MED_N=$([ -z "$MED_ROWS" ] && echo 0 || printf '%s\n' "$MED_ROWS" | grep -c .)

# HIGH rows that are genuine Q&A bundles (severity-classifier Layer 2). Only these
# warrant the "MUST fire AskUserQuestion" demand — L-S310-1 rule 3 is explicitly
# scoped to a "SCOPE+CHARTER bundle pending >6h". HIGH rows from Layer 5
# (notification files) escalate to urgent.md but are NOT AskUserQuestion-eligible:
# notifications are agent->human informational pushes, not blocked decisions.
# Without this split, a backlog of HIGH notifications falsely demands a (possibly
# huge) AskUserQuestion every UserPromptSubmit.
HIGH_QA_ROWS=$(printf '%s\n' "$HIGH_ROWS" | grep 'q-and-a/pending/' 2>/dev/null || true)
HIGH_QA_N=$([ -z "$HIGH_QA_ROWS" ] && echo 0 || printf '%s\n' "$HIGH_QA_ROWS" | grep -c .)

# === CRITICAL handling — write block flag (idempotent via flag presence check) ===
# Suppressed while .block-grace is active (a human just cleared the gate) — see the
# Block-grace block above + block-control.sh.
if [ "$CRIT_N" -gt 0 ]; then
  if [ ! -f "$BLOCK_FLAG" ] && [ "$GRACE_ACTIVE" -eq 0 ]; then
    {
      printf 'BLOCKED at %s by escalation-engine.sh (event=%s)\n' "$TS" "$EVENT"
      printf 'CRITICAL_COUNT=%s\n' "$CRIT_N"
      printf 'Affected artifacts:\n'
      printf '%s\n' "$CRIT_ROWS" | awk -F'\t' '{printf "  - %s (age=%sh, next=%s)\n", $2, $3, $4}'
      printf '\nTO RESUME (simplest first):\n'
      printf '  1. Reply to the agent with: "approved" / "unblock" / "run autonomous" / "tiep tuc".\n'
      printf '     block-control.sh check-prompt (UserPromptSubmit hook) auto-clears the gate. No file delete needed.\n'
      printf '  2. Or run:  bash scripts/hooks/block-control.sh clear\n'
      printf '  3. Review/resolve the affected artifact(s) above so they do not re-trigger after the grace window.\n'
      printf '  4. Emergency bypass: set env STOCKFORGE_FORCE_AUTONOMOUS=1 (will log warning to mistake-log).\n'
    } > "$BLOCK_FLAG"
    echo "escalation-engine: $CRIT_N CRITICAL items detected; .autonomous-BLOCKED flag written" >&2
  elif [ "$GRACE_ACTIVE" -eq 1 ]; then
    printf '[%s] escalation-engine: %s CRITICAL but .block-grace active — auto-raise suppressed\n' "$TS" "$CRIT_N" >> "$LOG"
  fi
fi

# === Idempotency: most actions per hour-bucket; CRITICAL flag always re-checked ===
HAS_HIGH_DELTA=0
if [ -f "$MARKER" ]; then
  # Skip Stop/SessionStart re-emission; UserPromptSubmit still injects context for LLM
  case "$EVENT" in
    UserPromptSubmit) ;;  # always emit injection
    *) [ "$CRIT_N" -eq 0 ] && exit 0 ;;
  esac
else
  HAS_HIGH_DELTA=1
fi

# === HIGH handling — urgent.md append + UserPromptSubmit additionalContext ===
if [ "$HIGH_N" -gt 0 ] && [ "$HAS_HIGH_DELTA" -eq 1 ]; then
  {
    printf '\n## ESCALATION — %s — %d HIGH-severity items (event=%s)\n\n' "$TS" "$HIGH_N" "$EVENT"
    printf 'Fired by: scripts/hooks/escalation-engine.sh\n'
    if [ "$HIGH_QA_N" -gt 0 ]; then
      printf 'Action required from agent: fire AskUserQuestion for the %d Q&A bundle(s) below.\n' "$HIGH_QA_N"
      printf 'Remaining HIGH rows are notification escalations — informational, no AskUserQuestion.\n\n'
    else
      printf 'Action: review the HIGH-severity notification(s) below. These are informational\n'
      printf 'escalations (no pending Q&A bundle) — no AskUserQuestion required.\n\n'
    fi
    printf '%s\n' "$HIGH_ROWS" | awk -F'\t' '{printf "- `%s` (age=%sh, action=%s)\n", $2, $3, $4}'
    if [ "$HIGH_QA_N" -gt 0 ]; then
      printf '\nPer L-S310-1 rule 3: agent MUST fire AskUserQuestion when SCOPE+CHARTER bundle pending >6h with no user signal.\n\n'
    else
      printf '\n'
    fi
    printf -- '---\n'
  } >> "$URGENT"
fi

# === MEDIUM handling — weekly digest (week-bucket) ===
if [ "$MED_N" -gt 0 ]; then
  WEEK=$(date +%G-W%V 2>/dev/null || echo "unbucketed")
  DIGEST="$PROJECT_DIR/human-workspace/notifications/digest-${WEEK}.md"
  WEEK_MARKER="$MEM_DIR/.escalation-digest-fired-${WEEK}"
  if [ ! -f "$WEEK_MARKER" ]; then
    {
      printf '# Weekly MEDIUM-severity digest — %s\n\n' "$WEEK"
      printf 'Generated %s by escalation-engine.sh\n\n' "$TS"
      printf '%s\n' "$MED_ROWS" | awk -F'\t' '{printf "- %s (age=%sh, action=%s)\n", $2, $3, $4}'
    } > "$DIGEST"
    echo "fired" > "$WEEK_MARKER"
  fi
fi

# === UserPromptSubmit cadence: inject additionalContext via JSON stdout ===
# Claude Code reads UserPromptSubmit hook stdout as additionalContext. We emit a brief
# system-reminder when CRITICAL or HIGH+age>6h items exist, instructing LLM to act.
if [ "$EVENT" = "UserPromptSubmit" ]; then
  if [ "$CRIT_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION CRITICAL: %d item(s) require human resolution. .autonomous-BLOCKED flag is ACTIVE. Agent should: respond with one-paragraph status of blocking artifacts (see %s), then await human action. Tools other than Read/Glob/Grep are blocked by autonomous-block-enforcer.sh.\n' "$CRIT_N" "$BLOCK_FLAG"
  elif [ "$HIGH_QA_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION HIGH: %d Q&A bundle(s) age >6h require AskUserQuestion. Agent MUST fire AskUserQuestion this turn for the pending bundles before resuming other work. See `%s` for the row list.\n' "$HIGH_QA_N" "$STATE_FILE"
  elif [ "$HIGH_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION HIGH: %d HIGH-severity notification(s) appended to urgent.md (no pending Q&A bundle). These are informational escalations — review urgent.md when convenient; no AskUserQuestion required.\n' "$HIGH_N"
  fi
fi

# === Telegram push for CRITICAL/HIGH (best-effort) ===
if [ -x "$TELEGRAM_HOOK" ] && { [ "$CRIT_N" -gt 0 ] || [ "$HIGH_N" -gt 0 ]; }; then
  TG_SEV="HIGH"
  [ "$CRIT_N" -gt 0 ] && TG_SEV="CRITICAL"
  TG_MSG="StockForge $EVENT: $CRIT_N CRITICAL + $HIGH_N HIGH items pending. See urgent.md."
  bash "$TELEGRAM_HOOK" "$TG_SEV" "$TG_MSG" 2>/dev/null || true
fi

echo "fired" > "$MARKER"
printf '[%s] escalation-engine event=%s CRIT=%s HIGH=%s MED=%s\n' "$TS" "$EVENT" "$CRIT_N" "$HIGH_N" "$MED_N" >> "$LOG"

exit 0
