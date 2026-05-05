#!/usr/bin/env bash
# ghost-work-audit.sh — SessionStart hook (C4 promote-rule S43c).
#
# Detects ghost-work: untracked source files under packages/ that were authored
# in a prior partial session but never staged, never logged in any session log,
# never referenced in checkpoints. Per L-S43b-11 (KI-S43b-8 / agent-notes
# 2026-05-01 § "Ghost-Work Pre-Flight Discovery Requires Explicit Provenance
# Audit"): silent adoption of ghost-work is a data-integrity risk; surface to
# the agent at SessionStart so VBW pre-flight covers provenance.
#
# Exempt: tests (test_*.py, *_test.py), __init__.py, configs, generated files.
# Bash + POSIX only per L-S11-1. Soft-warn (exit 0); never blocks.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

cd "$PROJECT_DIR" 2>/dev/null || exit 0
command -v git >/dev/null 2>&1 || exit 0

UNTRACKED="$(git status --short 2>/dev/null | awk '$1=="??"{print $2}' \
  | grep -E '^packages/.+\.py$' \
  | grep -vE '(test_|_test\.py$|__init__\.py$|/migrations/|/generated/)' \
  || true)"

[ -z "$UNTRACKED" ] && {
  printf '[%s] ghost-work-audit OK (0 untracked source files under packages/)\n' "$TS" >> "$LOG"
  exit 0
}

COUNT="$(printf '%s\n' "$UNTRACKED" | wc -l | tr -d ' ')"
LATEST_SESSION="$(find "$PROJECT_DIR/agent-workspace/memory/sessions" -name '*.md' -type f 2>/dev/null \
  | xargs -I{} stat -c '%Y {}' {} 2>/dev/null | sort -rn | head -1 | awk '{print $2}' || true)"

DOCUMENTED=0
[ -n "$LATEST_SESSION" ] && grep -qiE 'GHOST-WORK FOUND|ghost.work.found' "$LATEST_SESSION" 2>/dev/null && DOCUMENTED=1

if [ "$DOCUMENTED" -eq 1 ]; then
  printf '[%s] ghost-work-audit INFO %d untracked source file(s) but latest session log documents GHOST-WORK FOUND\n' "$TS" "$COUNT" >> "$LOG"
  exit 0
fi

printf '[%s] ghost-work-audit ALERT %d untracked source file(s) under packages/ — VBW provenance audit required (L-S43b-11):\n' "$TS" "$COUNT" >> "$LOG"
printf '%s\n' "$UNTRACKED" | sed 's/^/  - /' >> "$LOG"
echo "ghost-work-audit ALERT: $COUNT untracked source file(s) under packages/ require provenance audit per L-S43b-11. Run \`git log --all --full-history -- <path>\` per file; add 'GHOST-WORK FOUND' entry to current session log before staging." >&2

exit 0
