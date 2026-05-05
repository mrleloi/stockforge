#!/usr/bin/env bash
# post-tool-citation-grep.sh — PostToolUse hook enforcing I-S2 (every claim cites source + as_of).
# Wired as PostToolUse on Write/Edit. Greps file content adjacent to numerical values for
# `source:` and `as_of:` lines. Flags violations to .citation-violations.log.
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.citation-violations.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

PAYLOAD="$(cat 2>/dev/null || true)"
[ -z "$PAYLOAD" ] && exit 0

TOOL_NAME="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).tool_name||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

# Only audit Write/Edit on data-bearing files.
case "$TOOL_NAME" in Write|Edit|MultiEdit) ;; *) exit 0 ;; esac

FILE_PATH="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const p=JSON.parse(s); console.log(p.tool_input?.file_path||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Audit only data-bearing dirs (specs, agent-workspace memory, thesis-log, calibration).
case "$FILE_PATH" in
  */specs/*|*/agent-workspace/memory/thesis-log/*|*/agent-workspace/calibration/*|*/agent-workspace/memory/decisions/*|*/eval-sets/*) ;;
  *) exit 0 ;;
esac

# Find lines with numerical claims (% / $ / VND / billion / tỷ / numeric values >2 digits).
# Then verify nearby (±5 lines) source: + as_of:.
NUMERIC_LINES="$(grep -nE '([0-9]{2,}\.?[0-9]*\s*(%|VND|tỷ|billion|million|đồng))|[0-9]{4,}' "$FILE_PATH" 2>/dev/null | head -20 || true)"
[ -z "$NUMERIC_LINES" ] && exit 0

VIOLATION_COUNT=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  LINENO_VAL="$(printf '%s' "$line" | cut -d: -f1)"
  SNIPPET="$(printf '%s' "$line" | cut -d: -f2- | head -c 100)"
  # Check ±5 lines for source: / as_of: presence.
  START=$(( LINENO_VAL - 5 ))
  [ $START -lt 1 ] && START=1
  END=$(( LINENO_VAL + 5 ))
  CONTEXT="$(sed -n "${START},${END}p" "$FILE_PATH" 2>/dev/null || true)"
  if ! printf '%s' "$CONTEXT" | grep -qE '(source:|as[_ ]of:|src:)'; then
    VIOLATION_COUNT=$(( VIOLATION_COUNT + 1 ))
    printf '[%s] CITATION-MISSING file=%s line=%s snippet="%s"\n' \
      "$(date -Iseconds)" "$FILE_PATH" "$LINENO_VAL" "$SNIPPET" >> "$LOG"
  fi
done <<< "$NUMERIC_LINES"

if [ "$VIOLATION_COUNT" -gt 0 ]; then
  echo "[$(date -Iseconds)] post-tool-citation-grep: $VIOLATION_COUNT violation(s) in $FILE_PATH" >> "$HOOK_LOG"
  # Soft-warn via stderr (not blocking). Hard-block reserved for `STOCKFORGE_CITATION_STRICT=1`.
  if [ "${STOCKFORGE_CITATION_STRICT:-0}" = "1" ]; then
    printf '{"decision":"block","reason":"[STOCKFORGE I-S2] %d numeric claim(s) in %s missing source: / as_of: citation. Add provenance metadata before continuing."}\n' \
      "$VIOLATION_COUNT" "$FILE_PATH"
    exit 0
  else
    printf '[citation-grep] WARN: %d numeric claim(s) in %s missing source/as_of (set STOCKFORGE_CITATION_STRICT=1 to block)\n' \
      "$VIOLATION_COUNT" "$FILE_PATH" >&2
  fi
fi

exit 0
