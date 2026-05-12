#!/usr/bin/env bash
# no-anthropic-sdk-d10.sh — D10 drift signal: no `import anthropic` / `ANTHROPIC_API_KEY`
# in production code (apps/**/*.py + packages/**/*.py).
#
# Authored S230 (2026-05-09) post-D-050/D-051/D-052 chain. Production code is now
# clean (D-052 removed all SDK call paths). This hook prevents regression: any
# future re-introduction of `import anthropic` / `from anthropic` / `ANTHROPIC_API_KEY`
# raises a HIGH-severity drift event in .drift-signals.log.
#
# Charter Principle 11 binding (deterministic enforcement layer for L-S227-1
# critical-severity rule + CLAUDE.md hard rule "NO ANTHROPIC_API_KEY / no direct
# anthropic SDK calls in production code"). Companion firing-test:
# scripts/hooks/firing-tests/no-anthropic-sdk-d10-fire-test.sh.
#
# Strict-zero-tolerance: any hit in apps/+packages/ Python files = HIGH violation.
# Exclusions: tests/fixtures legitimately reference these strings (see exclusion
# list below); they are scoped via path-globs, not content-allow-listing.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory"
LOG="$PROJECT_DIR/agent-workspace/memory/.drift-signals.log"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds)"

VIOLATIONS=0

emit() {
  local severity="$1" detail="$2"
  printf '[%s] D10-NO-ANTHROPIC-SDK severity=%s %s\n' "$TS" "$severity" "$detail" >> "$LOG"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
}

scan_dir() {
  local dir="$1"
  [ ! -d "$dir" ] && return
  # Real-import scan: anchored line-start (with optional indent) — avoids docstring
  # mentions like "forbids `import anthropic`". Test fixture files
  # (test_*.py / *_test.py) MAY contain monkeypatch.delenv("ANTHROPIC_API_KEY")
  # for negative-path testing — kept allow-listed via path filter.
  local hits
  hits="$(grep -rEn '^[[:space:]]*(import[[:space:]]+anthropic|from[[:space:]]+anthropic\b)' \
    "$dir" --include='*.py' 2>/dev/null \
    | grep -vE '/(test_[^/]*\.py|[^/]*_test\.py):' \
    | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$hits" =~ ^[0-9]+$ ]] || hits=0
  if [ "$hits" -gt 0 ]; then
    emit "HIGH" "scope=$dir kind=import-anthropic count=$hits"
  fi

  # ANTHROPIC_API_KEY: only flag real env-var access
  # (`os.environ["ANTHROPIC_API_KEY"]`, `os.environ.get(...)`, `os.getenv(...)`,
  # `env["..."]`). Docstring/comment prose mentions are NOT flagged — the regex
  # requires the env-access pattern adjacent to the key string.
  local key_hits
  key_hits="$(grep -rEn '(os\.environ(\.get)?[\[\(]|os\.getenv\(|environ[\[\(])[[:space:]]*["'"'"']ANTHROPIC_API_KEY' \
    "$dir" --include='*.py' 2>/dev/null \
    | grep -vE '/(test_[^/]*\.py|[^/]*_test\.py):' \
    | wc -l | tr -d '[:space:]' || echo 0)"
  [[ "$key_hits" =~ ^[0-9]+$ ]] || key_hits=0
  if [ "$key_hits" -gt 0 ]; then
    emit "HIGH" "scope=$dir kind=ANTHROPIC_API_KEY count=$key_hits"
  fi
}

scan_dir "$PROJECT_DIR/apps"
scan_dir "$PROJECT_DIR/packages"

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "[$TS] no-anthropic-sdk-d10: $VIOLATIONS violation(s) — see $LOG" >> "$HOOK_LOG"
fi

# Strict mode: exit non-zero if any HIGH violation (blocks Stop hook chain).
# Default: emit-only; user can opt into strict via STOCKFORGE_D10_STRICT=1.
if [ "${STOCKFORGE_D10_STRICT:-0}" = "1" ] && [ "$VIOLATIONS" -gt 0 ]; then
  exit 1
fi
exit 0
