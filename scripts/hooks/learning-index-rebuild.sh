#!/usr/bin/env bash
# learning-index-rebuild.sh — rebuild RAG-style index over learning-data/events/.
# Wired as Stop in .claude/settings.json. Async; fail-silent; non-blocking.
# Track 5.5d.2 D-005. Phase 0: bash + node-eval (sqlite3 unavailable on Win Git Bash;
# IMPL-tier pick of "simple bash grep+regex" branch from D-005 § Open Questions).
# Phase 1+ swap-out target: pgvector / FTS5 when DB infra arrives.
# Throttle gates: rebuild only if events_delta>=N_EVENTS or LEARNING_INDEX_FORCE=1.
# Boundary: writes to learning-data/index/ (read-allowed); reads events/ (write-only path,
# but hook runs outside main-session permission scope per harness model).
# Patterns: if/then/fi + split-local per L-S10-1 lesson.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
EVENTS_DIR="$PROJECT_DIR/agent-workspace/learning-data/events"
INDEX_DIR="$PROJECT_DIR/agent-workspace/learning-data/index"
STATE_FILE="$INDEX_DIR/.last-index-build.json"
MANIFEST="$INDEX_DIR/manifest.json"
SAMPLE="$INDEX_DIR/recent-sample.ndjson"
LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds)"

N_EVENTS_THRESHOLD="${LEARNING_INDEX_N_EVENTS:-100}"
SAMPLE_LINES="${LEARNING_INDEX_SAMPLE_LINES:-100}"

mkdir -p "$INDEX_DIR" 2>/dev/null || true
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

(
EVENTS_TOTAL=0
if [ -d "$EVENTS_DIR" ]; then
  while IFS= read -r -d '' file; do
    n=0
    n="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
    if [[ ! "$n" =~ ^[0-9]+$ ]]; then
      n=0
    fi
    EVENTS_TOTAL=$(( EVENTS_TOTAL + n ))
  done < <(find "$EVENTS_DIR" -name '*.ndjson' -type f -print0 2>/dev/null)
fi

LAST_BUILD_EVENTS=0
if [ -f "$STATE_FILE" ]; then
  LAST_BUILD_EVENTS="$(node -e "
let s='';process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { const o=JSON.parse(s); console.log(o.events_at_build||0); } catch { console.log(0); } });" < "$STATE_FILE" 2>/dev/null || echo 0)"
  if [[ ! "$LAST_BUILD_EVENTS" =~ ^[0-9]+$ ]]; then
    LAST_BUILD_EVENTS=0
  fi
fi

EVENTS_DELTA=$(( EVENTS_TOTAL - LAST_BUILD_EVENTS ))
if [ "$EVENTS_DELTA" -lt 0 ]; then
  EVENTS_DELTA=0
fi

SHOULD_REBUILD=0
if [ "${LEARNING_INDEX_FORCE:-0}" = "1" ]; then
  SHOULD_REBUILD=1
fi
if [ "$EVENTS_DELTA" -ge "$N_EVENTS_THRESHOLD" ]; then
  SHOULD_REBUILD=1
fi

if [ "$SHOULD_REBUILD" -eq 0 ]; then
  printf '[%s] learning-index-rebuild SKIP delta=%d total=%d threshold=%d\n' \
    "$TS" "$EVENTS_DELTA" "$EVENTS_TOTAL" "$N_EVENTS_THRESHOLD" >> "$LOG"
  exit 0
fi

{
  printf '{"as_of":"%s","total_events":%d,"events_delta_since_last_build":%d,"files":[' \
    "$TS" "$EVENTS_TOTAL" "$EVENTS_DELTA"
  FIRST=1
  if [ -d "$EVENTS_DIR" ]; then
    while IFS= read -r -d '' file; do
      bn="$(basename "$file")"
      lines=0
      lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
      if [[ ! "$lines" =~ ^[0-9]+$ ]]; then
        lines=0
      fi
      size=0
      size="$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)"
      if [[ ! "$size" =~ ^[0-9]+$ ]]; then
        size=0
      fi
      if [ "$FIRST" -eq 0 ]; then
        printf ','
      fi
      printf '{"name":"%s","lines":%d,"size":%d}' "$bn" "$lines" "$size"
      FIRST=0
    done < <(find "$EVENTS_DIR" -name '*.ndjson' -type f -print0 2>/dev/null | sort -z)
  fi
  printf ']}\n'
} > "$MANIFEST" 2>/dev/null

: > "$SAMPLE"
if [ -d "$EVENTS_DIR" ]; then
  while IFS= read -r -d '' file; do
    cat "$file" 2>/dev/null
  done < <(find "$EVENTS_DIR" -name '*.ndjson' -type f -print0 2>/dev/null | sort -z) | tail -n "$SAMPLE_LINES" >> "$SAMPLE"
fi

printf '{"as_of":"%s","events_at_build":%d,"sample_lines":%d}\n' \
  "$TS" "$EVENTS_TOTAL" "$(wc -l < "$SAMPLE" 2>/dev/null | tr -d '[:space:]' || echo 0)" > "$STATE_FILE"

if [ "$EVENTS_DELTA" -ge "$N_EVENTS_THRESHOLD" ] && [ -d "$NOTIF_DIR" ]; then
  TS_FILE="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
  NOTIF_FILE="$NOTIF_DIR/$TS_FILE-learning-analysis-ready.md"
  {
    printf '# Background Learning Analysis Ready\n\n'
    printf 'Index rebuilt at %s (Stop hook).\n\n' "$TS"
    printf -- '- Events delta since last build: %d\n' "$EVENTS_DELTA"
    printf -- '- Events total: %d\n' "$EVENTS_TOTAL"
    printf -- '- Sample: agent-workspace/learning-data/index/recent-sample.ndjson\n'
    printf -- '- Manifest: agent-workspace/learning-data/index/manifest.json\n\n'
    printf 'Next-turn agent action: dispatch sonnet medium classifier; output to agent-workspace/learning-data/index/categories-<TS>.md (per D-005 § 5.5d.2).\n'
  } > "$NOTIF_FILE" 2>/dev/null || true
fi

SAMPLE_COUNT=0
SAMPLE_COUNT="$(wc -l < "$SAMPLE" 2>/dev/null | tr -d '[:space:]')"
if [[ ! "$SAMPLE_COUNT" =~ ^[0-9]+$ ]]; then
  SAMPLE_COUNT=0
fi
printf '[%s] learning-index-rebuild OK delta=%d total=%d sample_lines=%d\n' \
  "$TS" "$EVENTS_DELTA" "$EVENTS_TOTAL" "$SAMPLE_COUNT" >> "$LOG"
) </dev/null >/dev/null 2>&1 &

disown 2>/dev/null || true
exit 0
