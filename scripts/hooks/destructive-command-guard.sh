#!/usr/bin/env bash
# destructive-command-guard.sh — PreToolUse guard against mass-destruction commands.
#
# Origin: 2026-05-14 mass-deletion incident (post-mortems/2026-05-14-mass-deletion-recovery.md).
# ~2688 files destroyed by a recency-based mass deletion (find -newer / git op) during a
# subagent execution window. Exact command unrecoverable (Claude Code 0-byte transcripts).
# Prevention = deny-list defense-in-depth: block destructive command CLASSES at PreToolUse,
# applies to BOTH main session AND every subagent, regardless of which agent issues it.
#
# Mechanism: PreToolUse hook. Reads the Bash command from stdin JSON (tool_input.command).
# If the command matches a destructive pattern AND is not on the narrow safe-allowlist,
# exit RC=2 (deny). Otherwise exit 0 (allow).
#
# Override: STOCKFORGE_ALLOW_DESTRUCTIVE=1 env bypasses (for the rare legitimate case;
# logged to mistake-log so it is auditable).
#
# Bash + POSIX only per L-S11-1. SPAWN-CONTEXT: bash-c (reads stdin JSON; firing-test must exercise it).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.destructive-command-guard.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# --- Extract the command being run ---
# Claude Code passes tool input as JSON on stdin for PreToolUse hooks.
CMD=""
TOOL=""
if [ ! -t 0 ]; then
  STDIN_JSON=$(cat 2>/dev/null || true)
  TOOL=$(printf '%s' "$STDIN_JSON" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/' || true)
  # tool_input.command may contain escaped quotes; grab the broad slice then unescape minimally
  CMD=$(printf '%s' "$STDIN_JSON" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//' || true)
fi

# Only guard Bash tool calls; allow everything else through.
case "$TOOL" in
  Bash|"") ;;          # "" = unknown (defensive: still scan if we got a CMD)
  *) exit 0 ;;
esac

# Nothing to scan → allow.
[ -z "$CMD" ] && exit 0

# --- Override gate ---
if [ "${STOCKFORGE_ALLOW_DESTRUCTIVE:-0}" = "1" ]; then
  printf '[%s] destructive-command-guard: BYPASSED via STOCKFORGE_ALLOW_DESTRUCTIVE=1 cmd=%s\n' "$TS" "${CMD:0:200}" >> "$LOG"
  # Also append to mistake-log for auditability (best-effort).
  if [ -f "$MEM_DIR/mistake-log.md" ]; then
    printf '\n<!-- %s destructive-command-guard BYPASS: %s -->\n' "$TS" "${CMD:0:200}" >> "$MEM_DIR/mistake-log.md" 2>/dev/null || true
  fi
  exit 0
fi

# --- Safe allowlist (checked FIRST; these are legitimate harness operations) ---
# Marker-file cleanup: rm -f of dot-prefixed marker files under agent-workspace/memory/
# Pattern: rm -f "...agent-workspace/memory/.<something>" — single or multiple dot-files.
# These are the legitimate idempotency-marker cleanups used by many hooks.
is_safe() {
  local c="$1"
  # rm of ONLY dot-prefixed files (markers) — no directories, no recursive
  case "$c" in
    *"rm -rf"*|*"rm -fr"*|*"rm -r "*|*"rm --recursive"*) return 1 ;;  # never safe
  esac
  # rm targeting only .dotfile markers in memory dir → safe
  if printf '%s' "$c" | grep -qE '^[[:space:]]*rm[[:space:]]+(-f[[:space:]]+|-f$)' 2>/dev/null; then
    # every non-flag token must be a dot-file path (contains /. or starts with .)
    # crude but effective: reject if any token looks like a directory or glob-of-dirs
    case "$c" in
      *"*"*"/"*|*"/"*"*"*) return 1 ;;  # path+glob combo — not safe
    esac
    # if it only mentions .marker-style files, treat safe
    if printf '%s' "$c" | grep -qE '\.(autonomous-BLOCKED|severity-state|telegram-pushed|escalation-fired|escalation-digest|pydet-marker|file-pattern-lint-fired|qa-urgent-fired|orphan-reescalate|auto-reboot|cliff-fired|mode-d-recovery)' 2>/dev/null; then
      return 0
    fi
  fi
  # find -delete / find -mtime with BOTH -maxdepth AND -name → the safe rotation pattern
  if printf '%s' "$c" | grep -qE 'find[[:space:]]' 2>/dev/null; then
    if printf '%s' "$c" | grep -qE '\-maxdepth[[:space:]]+[0-9]' 2>/dev/null \
       && printf '%s' "$c" | grep -qE "\-name[[:space:]]" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

# --- Destructive pattern blocklist ---
BLOCK_REASON=""
check_block() {
  local c="$1"
  # 1. Recursive rm
  case "$c" in
    *"rm -rf"*|*"rm -fr"*|*"rm -Rf"*|*"rm -r "*|*"rm --recursive"*)
      BLOCK_REASON="recursive rm (rm -rf / rm -r)"; return 0 ;;
  esac
  # 2. find with -delete or -exec rm — UNLESS safe (maxdepth+name) already returned 0 above
  if printf '%s' "$c" | grep -qE 'find[[:space:]].*-delete' 2>/dev/null; then
    BLOCK_REASON="find ... -delete without -maxdepth+-name guard"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'find[[:space:]].*-exec[[:space:]]+rm' 2>/dev/null; then
    BLOCK_REASON="find ... -exec rm"; return 0
  fi
  # 3. git destructive
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard' 2>/dev/null; then
    BLOCK_REASON="git reset --hard"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*[fdx]' 2>/dev/null; then
    BLOCK_REASON="git clean -f/-d/-x"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+checkout[[:space:]].*--[[:space:]]+(\.|\*)' 2>/dev/null; then
    BLOCK_REASON="git checkout -- . / -- * (bulk working-tree overwrite)"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+checkout[[:space:]]+(HEAD|[a-f0-9]{7,})[[:space:]]+--[[:space:]]*$' 2>/dev/null; then
    BLOCK_REASON="git checkout <ref> -- (no path = bulk)"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+worktree[[:space:]]+remove' 2>/dev/null; then
    BLOCK_REASON="git worktree remove"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'git[[:space:]]+stash([[:space:]]|$)' 2>/dev/null; then
    BLOCK_REASON="git stash (reverts working tree)"; return 0
  fi
  # 4. Device / filesystem destruction
  if printf '%s' "$c" | grep -qE '>[[:space:]]*/dev/(sd|nvme|hd|disk)' 2>/dev/null; then
    BLOCK_REASON="write to block device"; return 0
  fi
  if printf '%s' "$c" | grep -qE '(^|[^a-zA-Z])dd[[:space:]].*of=/dev/' 2>/dev/null; then
    BLOCK_REASON="dd of=/dev/..."; return 0
  fi
  if printf '%s' "$c" | grep -qE 'mkfs(\.|[[:space:]])' 2>/dev/null; then
    BLOCK_REASON="mkfs"; return 0
  fi
  # 5. Recursive chmod/chown on broad paths
  if printf '%s' "$c" | grep -qE 'chmod[[:space:]]+-R' 2>/dev/null; then
    BLOCK_REASON="chmod -R (recursive permission change)"; return 0
  fi
  if printf '%s' "$c" | grep -qE 'chown[[:space:]]+-R' 2>/dev/null; then
    BLOCK_REASON="chown -R (recursive ownership change)"; return 0
  fi
  # 6. Fork bomb / shred / truncate-all
  case "$c" in
    *":(){"*|*"shred "*) BLOCK_REASON="fork-bomb or shred"; return 0 ;;
  esac
  return 1
}

# --- Decision ---
if is_safe "$CMD"; then
  printf '[%s] destructive-command-guard: ALLOW (safe-allowlist) cmd=%s\n' "$TS" "${CMD:0:160}" >> "$LOG" 2>/dev/null || true
  exit 0
fi

if check_block "$CMD"; then
  printf '[%s] destructive-command-guard: BLOCKED reason="%s" cmd=%s\n' "$TS" "$BLOCK_REASON" "${CMD:0:200}" >> "$LOG" 2>/dev/null || true
  echo "DESTRUCTIVE-COMMAND-GUARD: denied — $BLOCK_REASON" >&2
  echo "Command: ${CMD:0:200}" >&2
  echo "If this is genuinely needed, the user must approve: prefix with STOCKFORGE_ALLOW_DESTRUCTIVE=1 in a settings.json env block, or run it manually via the ! shell prefix." >&2
  echo "Origin: 2026-05-14 mass-deletion incident — see agent-workspace/post-mortems/2026-05-14-mass-deletion-recovery.md" >&2
  exit 2
fi

# Not destructive → allow.
exit 0
