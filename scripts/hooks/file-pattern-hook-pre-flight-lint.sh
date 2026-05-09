#!/usr/bin/env bash
# file-pattern-hook-pre-flight-lint.sh — empirically validate file-pattern signatures
# in scripts/hooks/*.sh against real-state target files/directories.
#
# Per L-S176-1 (S176 NEW HIGH binding rule, retro-fit catalog of 5 bugs in M-S171-1
# recurrence-class): file-pattern hooks MUST validate against real-state inventory + ship
# companion firing-test. This lint is the deterministic-hook promotion of L-S176-1
# per Q-E3=D priority "hook FIRST, skill SECOND, charter LAST".
#
# Detects 2 high-signal pattern types (per S178 5-bug audit):
#   A. find <path> ... -name '<glob>' — flag if 0-match against non-empty <path>
#   B. awk/grep '^<markdown-anchor>' <file> — flag if 0-match against non-empty <file>
#      (anchor must start with markdown structural char `*`, `#`, `|`, or `>`)
#
# Override: `# pattern-lint-skip: <reason>` on same line OR within preceding 5 lines
# allows bypass. Use for legitimate cases (counter retained for observability,
# generated-cache directory expected initially-empty, etc.).
#
# Hook event: Stop (sweep all hooks once per session-end). Exit 0 always (soft-warn).
# Hour-bucket idempotency mirrors harness-health-self-scan / idle-escape-detector.
# Output: per-violation line to .session-hooks.log + (if violations >0) one notification
# in human-workspace/notifications/.
#
# Phase 0 portability: bash + POSIX only. L-S10-1: if/then/fi only; split-local.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HOOKS_DIR="$PROJECT_DIR/scripts/hooks"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
MARKER_DIR="$PROJECT_DIR/agent-workspace/memory"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# Hour-bucket idempotency (per harness-health-self-scan pattern; prevents double-fire
# within 1h window when Stop hook chain re-runs)
HOUR_BUCKET="$(date '+%Y%m%d-%H' 2>/dev/null || echo unknown)"
MARKER="$MARKER_DIR/.file-pattern-lint-fired-$HOUR_BUCKET"
[ -f "$MARKER" ] && exit 0
touch "$MARKER" 2>/dev/null || true
find "$MARKER_DIR" -maxdepth 1 -name '.file-pattern-lint-fired-*' -mmin +120 -delete 2>/dev/null || true

# Only fire on Stop event (skip if hooked into other events accidentally)
PAYLOAD="$(cat 2>/dev/null || true)"
if [ -n "$PAYLOAD" ] && command -v node >/dev/null 2>&1; then
  HOOK_EVENT="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{
  try { const p=JSON.parse(s); console.log(p.hook_event_name||''); }
  catch { console.log(''); }
});" 2>/dev/null || true)"
  [ "${HOOK_EVENT:-Stop}" = "Stop" ] || exit 0
fi

[ -d "$HOOKS_DIR" ] || exit 0

VIOLATIONS=0
VIOLATION_LIST=""

emit() {
  local code="$1" file="$2" detail="$3"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${code}: ${file} — ${detail}"$'\n'
}

# Resolve common path variables hooks reference (deterministic; no source/eval).
# Mirror the resolution that hooks themselves do at runtime.
resolve_var() {
  local v="$1"
  case "$v" in
    PROJECT_DIR|CLAUDE_PROJECT_DIR) printf '%s' "$PROJECT_DIR" ;;
    MEMORY_DIR|MEM_DIR) printf '%s' "$PROJECT_DIR/agent-workspace/memory" ;;
    HOOKS_DIR) printf '%s' "$PROJECT_DIR/scripts/hooks" ;;
    DECISIONS_DIR) printf '%s' "$PROJECT_DIR/agent-workspace/memory/decisions" ;;
    SESSIONS_DIR) printf '%s' "$PROJECT_DIR/agent-workspace/memory/sessions" ;;
    AN_FILE) printf '%s' "$PROJECT_DIR/agent-workspace/memory/agent-notes.md" ;;
    ML_FILE) printf '%s' "$PROJECT_DIR/agent-workspace/memory/mistake-log.md" ;;
    CE_FILE) printf '%s' "$PROJECT_DIR/agent-workspace/memory/current-execution.md" ;;
    ANSWERED_DIR) printf '%s' "$PROJECT_DIR/human-workspace/q-and-a/answered" ;;
    *) printf '' ;;
  esac
}

# Check skip-comment: same line or any of preceding 5 lines (covers comment blocks)
has_skip_comment() {
  local file="$1" lineno="$2"
  local start=$(( lineno - 5 ))
  [ "$start" -lt 1 ] && start=1
  if sed -n "${start},${lineno}p" "$file" 2>/dev/null | grep -q 'pattern-lint-skip'; then
    return 0
  fi
  return 1
}

# === Check A — find <path> ... -name '<glob>' empirical eval ===
for f in "$HOOKS_DIR"/*.sh; do
  [ ! -f "$f" ] && continue
  bn="$(basename "$f")"
  [ "$bn" = "$(basename "$0")" ] && continue
  [ "$bn" = "bash-hook-lint.sh" ] && continue
  while IFS= read -r match_line; do
    [ -z "$match_line" ] && continue
    LN="${match_line%%:*}"
    LINE="${match_line#*:}"
    has_skip_comment "$f" "$LN" && continue
    GLOB="$(printf '%s' "$LINE" | sed -nE "s/.*-name[[:space:]]+['\"]([^'\"]+)['\"].*/\1/p" | head -1 || true)"
    [ -z "$GLOB" ] && continue
    PATH_EXPR="$(printf '%s' "$LINE" | sed -nE 's/.*find[[:space:]]+("[^"]+"|[^[:space:]]+).*/\1/p' | head -1 || true)"
    PATH_EXPR="${PATH_EXPR#\"}"
    PATH_EXPR="${PATH_EXPR%\"}"
    VAR_NAME="$(printf '%s' "$PATH_EXPR" | sed -nE 's/^\$\{?([A-Z_]+)\}?.*/\1/p' | head -1 || true)"
    if [ -n "$VAR_NAME" ]; then
      RESOLVED_PREFIX="$(resolve_var "$VAR_NAME")"
      [ -z "$RESOLVED_PREFIX" ] && continue
      REST="$(printf '%s' "$PATH_EXPR" | sed -E "s/^\\\$\\{?${VAR_NAME}\\}?//")"
      RESOLVED="${RESOLVED_PREFIX}${REST}"
    else
      RESOLVED="$PATH_EXPR"
    fi
    [ ! -d "$RESOLVED" ] && continue
    MATCHES=$(find "$RESOLVED" -maxdepth 1 -name "$GLOB" 2>/dev/null | wc -l | tr -d '[:space:]')
    DIR_COUNT=$(find "$RESOLVED" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d '[:space:]')
    if [ "${MATCHES:-0}" -eq 0 ] && [ "${DIR_COUNT:-0}" -gt 0 ]; then
      emit "FILE-PATTERN-A-find-name" "$bn:$LN" "find -name '$GLOB' matches 0 files in $RESOLVED ($DIR_COUNT files present); review pattern against real-state inventory or add '# pattern-lint-skip:' override"
    fi
  done < <(grep -nE 'find[[:space:]]+["'"'"']?\$?[a-zA-Z0-9_/.${}-]+["'"'"']?[[:space:]].*-name[[:space:]]+["'"'"']' "$f" 2>/dev/null || true)
done

# === Check B — awk/grep '^<markdown-anchor>' <file> empirical eval ===
# Anchor must start with markdown structural char (`*`, `#`, `|`, `>`); these are highest-signal
# bug patterns per S178 audit (5 bugs all matched this signature).
for f in "$HOOKS_DIR"/*.sh; do
  [ ! -f "$f" ] && continue
  bn="$(basename "$f")"
  [ "$bn" = "$(basename "$0")" ] && continue
  [ "$bn" = "bash-hook-lint.sh" ] && continue
  while IFS= read -r match_line; do
    [ -z "$match_line" ] && continue
    LN="${match_line%%:*}"
    LINE="${match_line#*:}"
    has_skip_comment "$f" "$LN" && continue
    ANCHOR="$(printf '%s' "$LINE" | sed -nE "s/.*['\"]\^([*#|>][^'\"\\/]*)['\"\\/].*/\1/p" | head -1 || true)"
    [ -z "$ANCHOR" ] && continue
    TARGET_EXPR="$(printf '%s' "$LINE" | grep -oE '"\$\{?[A-Z_]+\}?[^"]*"' | tail -1 || true)"
    TARGET_EXPR="${TARGET_EXPR#\"}"
    TARGET_EXPR="${TARGET_EXPR%\"}"
    [ -z "$TARGET_EXPR" ] && continue
    VAR_NAME="$(printf '%s' "$TARGET_EXPR" | sed -nE 's/^\$\{?([A-Z_]+)\}?.*/\1/p' | head -1 || true)"
    [ -z "$VAR_NAME" ] && continue
    RESOLVED_PREFIX="$(resolve_var "$VAR_NAME")"
    [ -z "$RESOLVED_PREFIX" ] && continue
    REST="$(printf '%s' "$TARGET_EXPR" | sed -E "s/^\\\$\\{?${VAR_NAME}\\}?//")"
    RESOLVED="${RESOLVED_PREFIX}${REST}"
    [ ! -f "$RESOLVED" ] && continue
    MATCHES=$(grep -cF "^$ANCHOR" "$RESOLVED" 2>/dev/null || true)
    MATCHES_REGEX=$(grep -cE "^${ANCHOR//\*/\\*}" "$RESOLVED" 2>/dev/null || true)
    LINES_TOTAL=$(wc -l < "$RESOLVED" 2>/dev/null || true)
    if [ "${MATCHES:-0}" -eq 0 ] && [ "${MATCHES_REGEX:-0}" -eq 0 ] && [ "${LINES_TOTAL:-0}" -gt 0 ]; then
      emit "FILE-PATTERN-B-anchor-match" "$bn:$LN" "anchor '^$ANCHOR' matches 0 lines in $RESOLVED ($LINES_TOTAL lines present); review against real-state file format or add '# pattern-lint-skip:' override"
    fi
  done < <(grep -nE "(awk|grep)[[:space:]]+(-[cnEoF]+[[:space:]]+)?['\"]/?\^[*#|>]" "$f" 2>/dev/null || true)
done

# === Emit summary ===
{
  printf '%s | file-pattern-lint summary | violations=%d hooks_scanned=%d\n' "$TS" "$VIOLATIONS" "$(ls "$HOOKS_DIR"/*.sh 2>/dev/null | wc -l | tr -d '[:space:]')"
  if [ "$VIOLATIONS" -gt 0 ]; then
    printf '%s' "$VIOLATION_LIST"
  fi
} >> "$LOG" 2>/dev/null || true

if [ "$VIOLATIONS" -gt 0 ]; then
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  TS_FILE="$(date '+%Y%m%dT%H%M%SZ' 2>/dev/null || echo unknown)"
  NOTIF_FILE="$NOTIF_DIR/N-${TS_FILE}-INFO-file-pattern-lint.md"
  {
    echo "# File-pattern-lint violations — $TS"
    echo
    echo "Detected $VIOLATIONS file-pattern signature(s) with 0-match against real-state target."
    echo "Per L-S176-1: review each pattern; either fix to match real state OR add"
    echo '`# pattern-lint-skip: <reason>` override on same/preceding line.'
    echo
    echo "## Violations"
    echo
    printf '%s' "$VIOLATION_LIST"
  } > "$NOTIF_FILE" 2>/dev/null || true
fi

exit 0
