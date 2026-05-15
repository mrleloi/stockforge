#!/usr/bin/env bash
# block-control.sh — unified human-gate (block / unblock) control for StockForge.
#
# THE single interface for the "agent hits a block / q&a / confirm / decision that
# needs a human -> notify -> human approves -> resume" loop. Replaces the scattered,
# deadlock-prone manual flag management (the S316/2026-05-14 incident: clearing a
# block required a human to manually `rm` 3 files because Write/Bash were themselves
# blocked).
#
# Subcommands:
#   raise <severity> <slug> -- <reason / recommendation text...>
#       Agent calls this when it hits something needing a human. Writes the
#       .autonomous-BLOCKED flag (structured: severity + slug + reason + resume steps)
#       and sends a Telegram push. Idempotent: will NOT overwrite an existing gate.
#
#   clear [actor] [reason...]
#       Clears the gate. Removes .autonomous-BLOCKED + the stale .severity-state.tsv
#       cache (escalation-engine reads it on UserPromptSubmit and would instantly
#       re-raise) + false-positive .auto-reboot-PRE-BLOCKED-* markers. Writes
#       .block-grace (default 30 min) so escalation-engine won't instantly re-raise,
#       giving the agent room to fix the root cause. This is the anti-deadlock path.
#
#   status
#       Prints BLOCKED (+ flag content) or CLEAR (+ grace remaining). RC=0 always.
#
#   check-prompt
#       UserPromptSubmit hook entry. Reads the user prompt from stdin JSON; if a gate
#       is active AND the prompt contains an approval keyword (approved / unblock /
#       run autonomous / go ahead / proceed / tiep tuc / dong y ...) with no negation,
#       auto-runs `clear`. Emits a stdout confirmation (becomes additionalContext).
#       This is what lets a human resume by just replying "approved" — no file ops.
#
# Bash + POSIX only per L-S11-1 (node is allowed — Claude Code runtime; used only to
# parse stdin JSON in check-prompt, mirroring stale-prompt-detector.sh +
# correction-rate-tracker.sh).
# Best-effort: RC=0 always; never fails a hook chain.
# SPAWN-CONTEXT: positional-arg (subcommand is $1; companion firing-test required per L-S247-1)

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
BLOCK_FLAG="$MEM_DIR/.autonomous-BLOCKED"
STATE_FILE="$MEM_DIR/.severity-state.tsv"
GRACE_FILE="$MEM_DIR/.block-grace"
LOG="$MEM_DIR/.block-control.log"
TELEGRAM_HOOK="$PROJECT_DIR/scripts/hooks/telegram-push.sh"

GRACE_SECONDS="${STOCKFORGE_BLOCK_GRACE_SECONDS:-1800}"
case "$GRACE_SECONDS" in ''|*[!0-9]*) GRACE_SECONDS=1800 ;; esac

TS="$(date -Iseconds 2>/dev/null || echo unknown)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"
case "$NOW_EPOCH" in ''|*[!0-9]*) NOW_EPOCH=0 ;; esac

mkdir -p "$MEM_DIR"

SUBCMD="${1:-status}"

log() { printf '[%s] block-control %s: %s\n' "$TS" "$SUBCMD" "$1" >> "$LOG" 2>/dev/null || true; }

# ---------------------------------------------------------------------------
# raise <severity> <slug> -- <reason...>
# ---------------------------------------------------------------------------
cmd_raise() {
  local severity slug reason
  severity="${1:-HIGH}"
  slug="${2:-unspecified}"
  reason=""
  if [ "$#" -ge 3 ]; then
    shift 2
    if [ "${1:-}" = "--" ]; then shift; fi
    reason="$*"
  fi
  [ -z "$reason" ] && reason="(no reason provided)"

  case "$severity" in
    CRITICAL|HIGH|MEDIUM|LOW) ;;
    critical|Critical) severity="CRITICAL" ;;
    high|High) severity="HIGH" ;;
    medium|Medium) severity="MEDIUM" ;;
    low|Low) severity="LOW" ;;
    *) severity="HIGH" ;;
  esac

  # Idempotent: never overwrite an existing gate (preserve the original reason).
  if [ -f "$BLOCK_FLAG" ]; then
    log "gate already active — not overwriting (slug=$slug)"
    printf 'BLOCK-CONTROL: a gate is already active (see %s). Not overwriting.\n' "$BLOCK_FLAG"
    return 0
  fi

  {
    printf 'BLOCKED at %s by block-control.sh (raised-by=agent severity=%s slug=%s)\n' "$TS" "$severity" "$slug"
    printf '\n'
    printf 'REASON / RECOMMENDATION:\n'
    printf '%s\n' "$reason"
    printf '\n'
    printf 'TO RESUME (simplest first):\n'
    printf '  1. Just reply to the agent with one of: "approved" / "unblock" / "run autonomous" / "go ahead" / "tiep tuc".\n'
    printf '     A UserPromptSubmit hook (block-control.sh check-prompt) auto-clears the gate. No file deletion needed.\n'
    printf '  2. Or run:  bash scripts/hooks/block-control.sh clear\n'
    printf '  3. Emergency bypass: set env STOCKFORGE_FORCE_AUTONOMOUS=1 (logged to mistake-log).\n'
  } > "$BLOCK_FLAG"

  log "gate RAISED severity=$severity slug=$slug reason_first80=${reason:0:80}"

  # Telegram push (best-effort; telegram-push.sh no-ops if creds absent / honors DRY_RUN).
  if [ -r "$TELEGRAM_HOOK" ]; then
    bash "$TELEGRAM_HOOK" "$severity" "GATE RAISED [$slug]: ${reason:0:280} -- reply 'approved' or 'unblock' to resume." 2>/dev/null || true
  fi

  printf 'BLOCK-CONTROL: gate RAISED (severity=%s slug=%s). Flag: %s. Telegram pushed (best-effort).\n' "$severity" "$slug" "$BLOCK_FLAG"
  return 0
}

# ---------------------------------------------------------------------------
# clear [actor] [reason...]
# ---------------------------------------------------------------------------
cmd_clear() {
  local actor reason had_flag expiry
  actor="${1:-manual}"
  if [ "$#" -ge 1 ]; then shift; fi
  reason="$*"
  [ -z "$reason" ] && reason="(no reason)"

  had_flag="no"
  [ -f "$BLOCK_FLAG" ] && had_flag="yes"

  # Remove the block flag.
  rm -f "$BLOCK_FLAG" 2>/dev/null || true
  # Remove the stale severity cache — escalation-engine reads it on UserPromptSubmit
  # and would instantly re-raise. severity-classifier regenerates it cleanly on Stop.
  rm -f "$STATE_FILE" 2>/dev/null || true
  # Remove false-positive auto-reboot markers (the S316 incident root cause class).
  rm -f "$MEM_DIR"/.auto-reboot-PRE-BLOCKED-* 2>/dev/null || true

  # Grace window: escalation-engine respects this and won't instantly re-raise,
  # giving the agent room to fix the root cause.
  expiry=$(( NOW_EPOCH + GRACE_SECONDS ))
  {
    printf 'expiry_epoch=%s\n' "$expiry"
    printf 'cleared_at=%s\n' "$TS"
    printf 'cleared_by=%s\n' "$actor"
    printf 'reason=%s\n' "$reason"
  } > "$GRACE_FILE"

  log "gate CLEARED actor=$actor had_flag=$had_flag grace_until_epoch=$expiry reason_first80=${reason:0:80}"
  printf 'BLOCK-CONTROL: gate CLEARED (was_blocked=%s by=%s). Grace %ss — escalation-engine auto-raise suppressed until then. Autonomous mode resumed.\n' "$had_flag" "$actor" "$GRACE_SECONDS"
  return 0
}

# ---------------------------------------------------------------------------
# status
# ---------------------------------------------------------------------------
cmd_status() {
  local exp
  if [ -f "$BLOCK_FLAG" ]; then
    printf 'BLOCK-CONTROL STATUS: BLOCKED\n'
    printf -- '--- flag content ---\n'
    cat "$BLOCK_FLAG" 2>/dev/null || true
    printf -- '--- end flag content ---\n'
  else
    printf 'BLOCK-CONTROL STATUS: CLEAR\n'
    if [ -f "$GRACE_FILE" ]; then
      exp="$(grep '^expiry_epoch=' "$GRACE_FILE" 2>/dev/null | head -1 | sed 's/^expiry_epoch=//' || echo 0)"
      case "$exp" in ''|*[!0-9]*) exp=0 ;; esac
      if [ "$exp" -gt "$NOW_EPOCH" ]; then
        printf 'grace: ACTIVE, %ss remaining (escalation-engine auto-raise suppressed)\n' "$(( exp - NOW_EPOCH ))"
      else
        printf 'grace: expired\n'
      fi
    else
      printf 'grace: none\n'
    fi
  fi
  return 0
}

# ---------------------------------------------------------------------------
# check-prompt  (UserPromptSubmit hook entry)
# ---------------------------------------------------------------------------
cmd_check_prompt() {
  # No gate active -> nothing to do.
  [ -f "$BLOCK_FLAG" ] || exit 0

  local payload user_prompt prompt_lower approval_re matched
  payload="$(cat 2>/dev/null || true)"
  user_prompt="$(printf '%s' "$payload" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).prompt || JSON.parse(s).user_message || ''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

  # Fallback: env var (non-standard invocation paths / manual testing).
  [ -z "$user_prompt" ] && user_prompt="${CLAUDE_USER_PROMPT:-}"
  [ -z "$user_prompt" ] && exit 0

  prompt_lower="$(printf '%s' "$user_prompt" | tr '[:upper:]' '[:lower:]')"

  # Negation guard — if the prompt explicitly says NOT to unblock, leave the gate.
  if printf '%s' "$prompt_lower" | grep -qE "(do not|don'?t|never|not approv|not unblock|keep block|stay block|chua approv|khong unblock)" 2>/dev/null; then
    log "check-prompt: negation detected — gate left active"
    exit 0
  fi

  # Approval keywords (EN + VI). Bounded by non-letter / line-edge to limit false hits.
  approval_re='(^|[^a-z])(approved?|unblock|un-block|run autonomous|resume autonomous|continue autonomous|go ahead|proceed|green light|greenlight|tiep tuc|dong y|chap nhan|mo khoa|go block)([^a-z]|$)'

  if printf '%s' "$prompt_lower" | grep -qE "$approval_re" 2>/dev/null; then
    matched="$(printf '%s' "$prompt_lower" | grep -oE "$approval_re" 2>/dev/null | head -1 | sed 's/^[^a-z]*//; s/[^a-z]*$//' || echo "approval")"
    cmd_clear "human-prompt" "matched approval keyword: $matched" >/dev/null 2>&1 || true
    log "check-prompt: AUTO-CLEARED via keyword '$matched'"
    printf 'BLOCK-CONTROL: human approval keyword detected ("%s") — autonomous gate AUTO-CLEARED. The agent may resume work this turn. (block-control.sh check-prompt)\n' "$matched"
    exit 0
  fi

  # Gate active but no approval keyword — leave it; the enforcer keeps blocking and
  # injects its own "still blocked" context.
  log "check-prompt: gate active, no approval keyword — left active"
  exit 0
}

# ---------------------------------------------------------------------------
# dispatch
# ---------------------------------------------------------------------------
case "$SUBCMD" in
  raise)
    shift 2>/dev/null || true
    cmd_raise "$@"
    ;;
  clear)
    shift 2>/dev/null || true
    cmd_clear "$@"
    ;;
  status)
    cmd_status
    ;;
  check-prompt)
    cmd_check_prompt
    ;;
  *)
    printf 'block-control.sh — unknown subcommand: %s\n' "$SUBCMD" >&2
    printf 'usage: block-control.sh {raise <severity> <slug> -- <reason> | clear [actor] [reason] | status | check-prompt}\n' >&2
    ;;
esac

exit 0
