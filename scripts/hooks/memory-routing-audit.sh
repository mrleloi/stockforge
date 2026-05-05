#!/usr/bin/env bash
# memory-routing-audit.sh — companion hook for HR-4 charter proposal
# (`agent-workspace/proposals/memory-routing-tree.md`).
#
# STATUS: DRAFT — NOT yet wired into .claude/settings.json.
# Ratification path: when human approves the HR-4 charter proposal, this hook
# moves into the Stop chain (after lesson-synthesis-watchdog). Until then,
# it stays unwired but smoke-testable for dry-run validation.
#
# Mechanism:
#   1. Detect this session touched project work (production code or workspace
#      memory): `git status --short -- packages/ apps/ agent-workspace/`
#      non-empty.
#   2. Detect user-memory dir was written in last 24h (mtime check on the
#      MEMORY.md index in that dir).
#   3. Detect agent-notes.md was NOT written in last 24h (project lesson loop
#      bypassed).
#   4. If 1 + 2 + 3 all true → ALERT (suggests project-substrate lesson
#      misrouted to user-memory; per HR-4 proposal § Hard Rule 1).
#
# Modes:
#   default → stderr ALERT + log; exit 0
#   strict  → exit 2 when triple-trigger (STOCKFORGE_MEMORY_ROUTING_HARDBLOCK=1
#             OR STOCKFORGE_HOOK_PROFILE=strict)
#
# User-memory dir is machine-local. Override the default path via
# STOCKFORGE_USER_MEMORY_DIR env var; otherwise fall back to a heuristic.
#
# Bash + POSIX only per L-S11-1.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.memory-routing-audit.log"
HOOK_LOG="$MEM_DIR/.session-hooks.log"
TS="$(date -Iseconds)"

# Resolve user-memory dir. Default heuristic for the project owner's env;
# override via STOCKFORGE_USER_MEMORY_DIR.
USER_MEM_DIR="${STOCKFORGE_USER_MEMORY_DIR:-/c/Users/PC/.ccs/instances/nathanleewindy/projects/C--htdocs-stockforge/memory}"
USER_MEM_INDEX="$USER_MEM_DIR/MEMORY.md"

mkdir -p "$(dirname "$LOG")"

# Step 1: project work touched?
PROD_TOUCHED=$(cd "$PROJECT_DIR" && git status --short -- packages/ apps/ agent-workspace/ 2>/dev/null | wc -l | tr -d '[:space:]')
[[ "$PROD_TOUCHED" =~ ^[0-9]+$ ]] || PROD_TOUCHED=0

if [ "$PROD_TOUCHED" -lt 1 ]; then
  printf '[%s] memory-routing-audit: prod_touched=0; skip\n' "$TS" >> "$LOG"
  exit 0
fi

# Step 2: user-memory write in last 24h?
USER_MEM_FRESH=0
if [ -f "$USER_MEM_INDEX" ]; then
  if find "$USER_MEM_INDEX" -mtime -1 2>/dev/null | grep -q .; then
    USER_MEM_FRESH=1
  fi
fi

# Also check any *.md inside the dir for recent writes (more robust than just index)
USER_MEM_RECENT_FILES=0
if [ -d "$USER_MEM_DIR" ]; then
  USER_MEM_RECENT_FILES=$(find "$USER_MEM_DIR" -name '*.md' -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
  [[ "$USER_MEM_RECENT_FILES" =~ ^[0-9]+$ ]] || USER_MEM_RECENT_FILES=0
fi
if [ "$USER_MEM_RECENT_FILES" -gt 0 ]; then
  USER_MEM_FRESH=1
fi

# Step 3: agent-notes.md fresh?
NOTES_RECENT=$(find "$MEM_DIR/agent-notes.md" -mtime -1 2>/dev/null | wc -l | tr -d '[:space:]')
[[ "$NOTES_RECENT" =~ ^[0-9]+$ ]] || NOTES_RECENT=0

printf '[%s] memory-routing-audit: prod_touched=%s user_mem_fresh=%s user_mem_files=%s notes_recent=%s\n' \
  "$TS" "$PROD_TOUCHED" "$USER_MEM_FRESH" "$USER_MEM_RECENT_FILES" "$NOTES_RECENT" >> "$LOG"

if [ "$USER_MEM_FRESH" -eq 1 ] && [ "$NOTES_RECENT" -eq 0 ]; then
  ALERT="memory-routing-audit ALERT: project work touched (prod_touched=$PROD_TOUCHED files) AND user-memory written in last 24h (files=$USER_MEM_RECENT_FILES) AND agent-notes.md NOT written in last 24h. Per HR-4 proposal Hard Rule 1, project-substrate lessons must land in agent-workspace/memory/agent-notes.md, NOT user-memory dir. Verify recent user-memory writes are user-role/cross-project (allowed) vs project-substrate (must mirror to agent-notes.md)."
  printf '[%s] %s\n' "$TS" "$ALERT" >> "$LOG"
  printf '[%s] memory-routing-audit: ALERT triple-trigger\n' "$TS" >> "$HOOK_LOG"
  echo "$ALERT" >&2

  if [ "${STOCKFORGE_MEMORY_ROUTING_HARDBLOCK:-0}" = "1" ] || [ "${STOCKFORGE_HOOK_PROFILE:-standard}" = "strict" ]; then
    printf '[%s] memory-routing-audit: HARD-BLOCK exit=2 (strict)\n' "$TS" >> "$HOOK_LOG"
    exit 2
  fi
fi

exit 0
