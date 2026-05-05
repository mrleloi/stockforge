#!/usr/bin/env bash
# same-commit-rule.sh — pre-commit hook enforcing spec ↔ code coupling.
# When code in packages/ or apps/ is staged, related spec in specs/ should be staged too
# (or vice-versa). Charter (PROJECT_CHARTER.md) is exempt — its changes don't require code.
# Adapted from msmdp Same-Commit Rule (A-23 in borrow-list).
# Decision 002 § Track 5 REV-2 § B deliverable.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
mkdir -p "$(dirname "$HOOK_LOG")"

# Get staged files.
STAGED="$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null || true)"
[ -z "$STAGED" ] && exit 0

CODE_CHANGED=0
SPEC_CHANGED=0
CHARTER_ONLY=1

while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in
    PROJECT_CHARTER.md) ;;  # exempt — charter changes don't require code
    packages/*|apps/*)  CODE_CHANGED=1; CHARTER_ONLY=0 ;;
    specs/*)            SPEC_CHANGED=1; CHARTER_ONLY=0 ;;
    *)                  CHARTER_ONLY=0 ;;
  esac
done <<< "$STAGED"

# If only charter changed, OK.
[ "$CHARTER_ONLY" = "1" ] && exit 0

# If code changed but no spec, warn (not block — sometimes refactor without spec change is OK).
if [ "$CODE_CHANGED" = "1" ] && [ "$SPEC_CHANGED" = "0" ]; then
  printf '[same-commit-rule] WARN: code changed in packages/ or apps/ but no spec/ file staged.\n' >&2
  printf '  If this is a behavior change → add/update spec.\n' >&2
  printf '  If pure refactor → OK to commit; consider adding "refactor" tag in commit message.\n' >&2
  echo "[$(date -Iseconds)] same-commit-rule: WARN code-without-spec staged_files=$(echo "$STAGED" | tr '\n' ' ')" >> "$HOOK_LOG"

  if [ "${STOCKFORGE_SAME_COMMIT_STRICT:-0}" = "1" ]; then
    echo "[same-commit-rule] BLOCKING: STOCKFORGE_SAME_COMMIT_STRICT=1; spec required." >&2
    exit 1
  fi
fi

# If spec changed but no code AND not just docs/test changes — warn.
if [ "$SPEC_CHANGED" = "1" ] && [ "$CODE_CHANGED" = "0" ]; then
  # Check if any non-doc file changed (would indicate forgotten code update).
  NON_DOC="$(echo "$STAGED" | grep -vE '^(specs/|docs/|README|.*\.md)$' | head -1)"
  if [ -z "$NON_DOC" ]; then
    printf '[same-commit-rule] INFO: spec-only change. If new spec section, ensure code matches before next session start.\n' >&2
  fi
fi

exit 0
