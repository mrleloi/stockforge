#!/usr/bin/env bash
# loc-ceiling-check.sh — PostToolUse hook on .claude/{agents,skills,commands}/**/*.md.
# Warns when LOC exceeds ceiling; blocks (exit 2) only if STOCKFORGE_LOC_STRICT=1.
# Ceilings: agents 200, skills 150, commands 120.
# DR-CONFIG queued item from S2 audit (added to Track 5 task list).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

PAYLOAD="$(cat 2>/dev/null || true)"
[ -z "$PAYLOAD" ] && exit 0

TOOL_NAME="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).tool_name||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"
case "$TOOL_NAME" in Write|Edit|MultiEdit) ;; *) exit 0 ;; esac

FILE_PATH="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const p=JSON.parse(s); console.log(p.tool_input?.file_path||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

# Determine archetype + ceiling.
ARCHETYPE=""
CEILING=0
case "$FILE_PATH" in
  */.claude/agents/*.md)   ARCHETYPE="agent";   CEILING=200 ;;
  */.claude/skills/*/SKILL.md) ARCHETYPE="skill";   CEILING=150 ;;
  */.claude/commands/*.md) ARCHETYPE="command"; CEILING=120 ;;
  *) exit 0 ;;
esac

LINES="$(wc -l < "$FILE_PATH" 2>/dev/null | tr -d '[:space:]')"
[[ "$LINES" =~ ^[0-9]+$ ]] || exit 0

if [ "$LINES" -le "$CEILING" ]; then
  exit 0
fi

OVERRUN=$(( LINES - CEILING ))
PCT=$(( OVERRUN * 100 / CEILING ))

echo "[$(date -Iseconds)] loc-ceiling-check: $ARCHETYPE=$FILE_PATH lines=$LINES ceiling=$CEILING overrun=$OVERRUN (+${PCT}%)" >> "$HOOK_LOG"

# Soft warn always.
printf '[loc-ceiling-check] WARN: %s exceeds ceiling — %s LOC vs %s (overrun +%s%%). Trim body to references/ subdir.\n' \
  "$FILE_PATH" "$LINES" "$CEILING" "$PCT" >&2

# Hard block only if STOCKFORGE_LOC_STRICT=1.
if [ "${STOCKFORGE_LOC_STRICT:-0}" = "1" ]; then
  printf '{"decision":"block","reason":"[STOCKFORGE LOC-CEILING] %s exceeds %s ceiling (%s LOC vs %s, +%s%%). Trim body content into %s/references/ subdir or split into multiple skills/agents. Set STOCKFORGE_LOC_STRICT=0 to convert to warn-only."}\n' \
    "$FILE_PATH" "$ARCHETYPE" "$LINES" "$CEILING" "$PCT" "$(dirname "$FILE_PATH")"
fi

exit 0
