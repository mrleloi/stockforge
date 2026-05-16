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

CRIT_N=$([ -z "$CRIT_ROWS" ] && echo 0 || printf '%s\n' "$CRIT_ROWS" | wc -l | tr -d '[:space:]')
HIGH_N=$([ -z "$HIGH_ROWS" ] && echo 0 || printf '%s\n' "$HIGH_ROWS" | wc -l | tr -d '[:space:]')
MED_N=$([ -z "$MED_ROWS" ] && echo 0 || printf '%s\n' "$MED_ROWS" | wc -l | tr -d '[:space:]')

# === MIGRATION SHIM — S348 D5 ===
# Legacy .severity-state.tsv rows (pre-D1) have 5 cols (no block_tier column).
# Per D5 (30-day window): treat legacy CRITICAL rows as PENDING tier (back-compat default).
# This preserves the LESS-aggressive behavior (no flag write) during rollout.
# REMOVAL TARGET: 2026-06-15 (30 days post-deploy of S348). After removal, $6=="" branch
# in the awk split below should be deleted, and any remaining 5-col rows will be IGNORED
# by the tier-split logic (silent fail-safe).
# Concrete removal step: in the awk at $6=="PENDING" || $6==""
# delete the `|| $6==""` clause + this comment block + the test cases TC-D5-* below.
# Tracking: queue this in agent-workspace/memory/checkpoints/latest.md § PROMOTED-CANDIDATES
# with target removal session = S380-ish (30d).

# Split CRIT_ROWS by block_tier (col6, default PENDING per D5 migration shim window)
HARD_ROWS=$(printf '%s\n' "$CRIT_ROWS" | awk -F'\t' '$6=="HARD" {print}' 2>/dev/null || true)
PENDING_ROWS=$(printf '%s\n' "$CRIT_ROWS" | awk -F'\t' '$6=="PENDING" || $6=="" {print}' 2>/dev/null || true)
# Note: $6=="" branch catches legacy rows during 30-day migration shim window (D5)
# After 2026-06-15 (30 days post-deploy), the $6=="" clause SHOULD be removed; comment with removal date
HARD_N=$([ -z "$HARD_ROWS" ] && echo 0 || printf '%s\n' "$HARD_ROWS" | grep -c . 2>/dev/null | tr -d '[:space:]')
PENDING_N=$([ -z "$PENDING_ROWS" ] && echo 0 || printf '%s\n' "$PENDING_ROWS" | grep -c . 2>/dev/null | tr -d '[:space:]')
case "$HARD_N" in ''|*[!0-9]*) HARD_N=0 ;; esac
case "$PENDING_N" in ''|*[!0-9]*) PENDING_N=0 ;; esac

# HIGH rows that are genuine Q&A bundles (severity-classifier Layer 2). Only these
# warrant the "MUST fire AskUserQuestion" demand — L-S310-1 rule 3 is explicitly
# scoped to a "SCOPE+CHARTER bundle pending >6h". HIGH rows from Layer 5
# (notification files) escalate to urgent.md but are NOT AskUserQuestion-eligible:
# notifications are agent->human informational pushes, not blocked decisions.
# Without this split, a backlog of HIGH notifications falsely demands a (possibly
# huge) AskUserQuestion every UserPromptSubmit.
HIGH_QA_ROWS=$(printf '%s\n' "$HIGH_ROWS" | grep 'q-and-a/pending/' 2>/dev/null || true)
HIGH_QA_N=$([ -z "$HIGH_QA_ROWS" ] && echo 0 || printf '%s\n' "$HIGH_QA_ROWS" | wc -l | tr -d '[:space:]')

# === HARD handling — write block flag (unchanged from legacy CRITICAL logic) ===
# Suppressed while .block-grace is active (a human just cleared the gate) — see the
# Block-grace block above + block-control.sh.
if [ "$HARD_N" -gt 0 ]; then
  if [ ! -f "$BLOCK_FLAG" ] && [ "$GRACE_ACTIVE" -eq 0 ]; then
    {
      printf 'BLOCKED at %s by escalation-engine.sh (event=%s tier=HARD)\n' "$TS" "$EVENT"
      printf 'HARD_COUNT=%s\n' "$HARD_N"
      printf 'Affected artifacts:\n'
      printf '%s\n' "$HARD_ROWS" | awk -F'\t' '{printf "  - %s (age=%sh, next=%s)\n", $2, $3, $4}'
      printf '\nTO RESUME (simplest first):\n'
      printf '  1. Reply to the agent with: "approved" / "unblock" / "run autonomous" / "tiep tuc".\n'
      printf '     block-control.sh check-prompt (UserPromptSubmit hook) auto-clears the gate. No file delete needed.\n'
      printf '  2. Or run:  bash scripts/hooks/block-control.sh clear\n'
      printf '  3. Review/resolve the affected artifact(s) above so they do not re-trigger after the grace window.\n'
      printf '  4. Emergency bypass: set env STOCKFORGE_FORCE_AUTONOMOUS=1 (will log warning to mistake-log).\n'
    } > "$BLOCK_FLAG"
    echo "escalation-engine: $HARD_N HARD items detected; .autonomous-BLOCKED flag written" >&2
  elif [ "$GRACE_ACTIVE" -eq 1 ]; then
    printf '[%s] escalation-engine: %s HARD but .block-grace active — auto-raise suppressed\n' "$TS" "$HARD_N" >> "$LOG"
  fi
fi

# === PENDING handling — append to .pending-queue.tsv with escalate_at = now + 6h ===
# Per ADR D-068; agent continues working; pending-queue-escalator.sh handles 6h Telegram + 24h auto-archive
if [ "$PENDING_N" -gt 0 ]; then
  PENDING_QUEUE="$PROJECT_DIR/human-workspace/notifications/.pending-queue.tsv"
  mkdir -p "$(dirname "$PENDING_QUEUE")" 2>/dev/null || true
  ESCALATE_EPOCH=$(( $(date +%s 2>/dev/null || echo 0) + 21600 ))  # +6h
  # Ensure header exists (idempotent)
  if [ ! -f "$PENDING_QUEUE" ]; then
    {
      printf '# .pending-queue.tsv — generated by escalation-engine.sh per ADR D-068 (S348)\n'
      printf '# columns: pending_id\tblock_tier\tseverity\tartifact_path\tdetected_at\tescalate_at\ttelegram_pushed\tarchived_at\tresolve_reason\n'
    } > "$PENDING_QUEUE"
  fi
  while IFS=$'\t' read -r sev path age action ts tier _rest; do
    [ -z "$sev" ] && continue
    # Skip rows already in queue (idempotent — check by artifact_path)
    SLUG="$(basename "$path" 2>/dev/null | tr -dc 'a-zA-Z0-9-_' | head -c 40 || echo unknown)"
    PENDING_ID="${SLUG}-$(date +%s 2>/dev/null || echo 0)"
    if ! grep -F -q $'\t'"$path"$'\t' "$PENDING_QUEUE" 2>/dev/null; then
      printf '%s\t%s\t%s\t%s\t%s\t%s\tfalse\t-\t-\n' "$PENDING_ID" "PENDING" "$sev" "$path" "$TS" "$ESCALATE_EPOCH" >> "$PENDING_QUEUE"
    fi
  done < <(printf '%s\n' "$PENDING_ROWS" 2>/dev/null)
  printf '[%s] escalation-engine: %s PENDING items appended to .pending-queue.tsv\n' "$TS" "$PENDING_N" >> "$LOG"
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
# system-reminder when HARD or HIGH+age>6h items exist, instructing LLM to act.
# PENDING rows are SILENT on UPS per ADR D-068 + DD-10 (queue handles escalation; UPS noise just for HARD)
if [ "$EVENT" = "UserPromptSubmit" ]; then
  if [ "$HARD_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION HARD: %d item(s) require human resolution. .autonomous-BLOCKED flag is ACTIVE. Agent should: respond with one-paragraph status of blocking artifacts (see %s), then await human action. Tools other than Read/Glob/Grep are blocked by autonomous-block-enforcer.sh.\n' "$HARD_N" "$BLOCK_FLAG"
  elif [ "$HIGH_QA_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION HIGH: %d Q&A bundle(s) age >6h require AskUserQuestion. Agent MUST fire AskUserQuestion this turn for the pending bundles before resuming other work. See `%s` for the row list.\n' "$HIGH_QA_N" "$STATE_FILE"
  elif [ "$HIGH_N" -gt 0 ]; then
    printf 'SEVERITY-ESCALATION HIGH: %d HIGH-severity notification(s) appended to urgent.md (no pending Q&A bundle). These are informational escalations — review urgent.md when convenient; no AskUserQuestion required.\n' "$HIGH_N"
  fi
fi

# === Telegram push for HARD/HIGH (best-effort) ===
# HARD: immediate Telegram push (no 6h grace — this is the "truly stop now" tier)
# PENDING: NOT pushed here; pending-queue-escalator.sh handles 6h-delayed push per ADR D-068
if [ -x "$TELEGRAM_HOOK" ] && { [ "$HARD_N" -gt 0 ] || [ "$HIGH_N" -gt 0 ]; }; then
  TG_SEV="HIGH"
  [ "$HARD_N" -gt 0 ] && TG_SEV="CRITICAL"
  TG_MSG="StockForge $EVENT: $HARD_N HARD + $HIGH_N HIGH items pending. See urgent.md."
  bash "$TELEGRAM_HOOK" "$TG_SEV" "$TG_MSG" 2>/dev/null || true
fi

echo "fired" > "$MARKER"
printf '[%s] escalation-engine event=%s CRIT=%s HARD=%s PENDING=%s HIGH=%s MED=%s\n' "$TS" "$EVENT" "$CRIT_N" "$HARD_N" "$PENDING_N" "$HIGH_N" "$MED_N" >> "$LOG"

exit 0
