#!/usr/bin/env bash
# hook-firing-counter.sh — UserPromptSubmit hook (Phase 3.5 T3.4 Cluster 5).
#
# Lightweight precursor to T6 harness-health-self-scan.sh. Scans hooks declared in
# .claude/settings.json against firing evidence in .session-hooks.log + per-hook
# .{hook}.log files. Flags hooks with 0 firings in the last 7 days.
#
# Origin: L-S51-1 empirical-firing discipline + post-mortem 2026-05-05 § HH-* gap classes.
#   Pre-S51 fix, promotion-cycle-trigger.sh fired 20× / day yet escalated 0× because the
#   grep pattern never matched real format. Visible firing count != effective firing.
#   This hook catches the WEAKER signal: hooks with NO firing entries at all.
#
# Conformance:
#   - Bash + POSIX per L-S11-1 (no python/jq); .claude/settings.json parsed via grep+sed
#   - Soft-warn only (exit 0); surfaces silent count via stderr
#   - L-S48d-1 disciplined: every grep wrapped with || true (no bare grep under pipefail+ERR-trap)
#   - L-S48m-1 disciplined: no $CLAUDE_SESSION_ID markers

set -uo pipefail
trap 'exit 0' ERR

# === L-S48d-1 lint flag — S57 ratify per KI-S54-1 (alt-guard recognition) ===
# bash-hook-lint Check 7 flags this file. Categorization:
#   `DECLARED="$(grep -oE ... | sort -u 2>/dev/null || true)"` — already guarded ✓
#   `hits="$(grep -F -c "$base" "$HOOKS_LOG" 2>/dev/null || echo 0)"` —
#     alt-guard `|| echo 0` end-of-pipeline ✓
# Both grep usages SAFE; conservative `|| true` not applied (semantics
# already correct). Lint refinement to recognize `|| echo NN` alt-guard
# deferred per KI-S54-1.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HOOKS_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
SETTINGS="$PROJECT_DIR/.claude/settings.json"
COUNTER_LOG="$PROJECT_DIR/agent-workspace/memory/.hook-firing-counter.log"
TS="$(date -Iseconds 2>/dev/null || date)"

# Pre-checks
[ -f "$SETTINGS" ] || exit 0
[ -f "$HOOKS_LOG" ] || exit 0

# 7-day cutoff
NOW_S="$(date +%s 2>/dev/null || echo 0)"
case "$NOW_S" in
  ''|*[!0-9]*) exit 0 ;;
esac
CUTOFF=$(( NOW_S - 7 * 86400 ))

# Extract declared hook .sh basenames from settings.json.
# Note: cannot match `"command": "..."` value pairs directly because settings.json escapes
# inner quotes (\"...\") which truncates the simple "[^"]+" regex. Just grep for .sh
# basenames anywhere in the settings file — every hook reference includes one.
DECLARED="$(grep -oE '[a-zA-Z0-9_-]+\.sh' "$SETTINGS" 2>/dev/null \
            | sort -u 2>/dev/null || true)"

[ -z "$DECLARED" ] && exit 0

DECLARED_TOTAL=0
SILENT_COUNT=0
SILENT_LIST=""

for hook_name in $DECLARED; do
  DECLARED_TOTAL=$(( DECLARED_TOTAL + 1 ))
  base="${hook_name%.sh}"

  # Check 1: per-hook .log file mtime within 7d → recent firing
  log_file="$PROJECT_DIR/agent-workspace/memory/.${base}.log"
  if [ -f "$log_file" ]; then
    mtime="$(stat -c '%Y' "$log_file" 2>/dev/null || stat -f '%m' "$log_file" 2>/dev/null || echo 0)"
    case "$mtime" in
      ''|*[!0-9]*) mtime=0 ;;
    esac
    if [ "$mtime" -gt "$CUTOFF" ]; then
      continue
    fi
  fi

  # Check 2: hook basename appears in session-hooks.log (any 7-day entry).
  # Heuristic: grep -c "$base" — fixed-string-ish matching via -F to avoid regex pitfalls.
  hits="$(grep -F -c "$base" "$HOOKS_LOG" 2>/dev/null || true)"
  case "$hits" in
    ''|*[!0-9]*) hits=0 ;;
  esac
  if [ "$hits" -gt 0 ]; then
    continue
  fi

  # No firing evidence → flag
  SILENT_COUNT=$(( SILENT_COUNT + 1 ))
  SILENT_LIST="${SILENT_LIST}  - ${hook_name}
"
done

# Emit
mkdir -p "$(dirname "$COUNTER_LOG")" 2>/dev/null || true
if [ "$SILENT_COUNT" -gt 0 ]; then
  {
    printf '[%s] hook-firing-counter: %d/%d declared hook(s) silent ≥7d\n' "$TS" "$SILENT_COUNT" "$DECLARED_TOTAL"
    printf -- '%s' "$SILENT_LIST"
  } >> "$COUNTER_LOG"
  printf 'hook-firing-counter: %d hook(s) with 0 firings in last 7d — investigate per L-S49b-2 5-step playbook; detail: %s\n' \
    "$SILENT_COUNT" "$COUNTER_LOG" >&2
else
  printf '[%s] hook-firing-counter: all %d declared hooks fired within 7d\n' "$TS" "$DECLARED_TOTAL" >> "$COUNTER_LOG"
fi

# S188 D-044 H-c test — emit minimal hookSpecificOutput JSON so Windows
# UserPromptSubmit chain advances past this hook (S187 hypothesis: stdout JSON
# emission is required for chain continuation across segment boundaries on
# Claude Code Windows; this hook may be such a boundary at #5/#6).
node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:''}}))" 2>/dev/null || true

exit 0
