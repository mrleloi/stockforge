#!/usr/bin/env bash
# dispatch-jsonl-backfill.sh — one-shot CLI to recover agent_type + model for historical
# dispatch.jsonl rows where agent_type="unknown-agent" or model="unknown".
# Plan 011 D2 deliverable.
#
# Strategy:
#   For DISPATCHED rows: agent_type already recorded at dispatch time (from tool_input).
#   For COMPLETED rows with tool_use_id:null (old SubagentStop format):
#     - Cross-ref observation files in agent-workspace/memory/observations/
#       matching pattern: sandwich-<role>-S<N>-*.md → role = agent_type
#     - Cross-ref .dispatch-pending-*.jsonl bodies for matching dispatch_id
#   Model: resolve via .claude/agents/<type>.md frontmatter model: field.
#
# Usage: bash dispatch-jsonl-backfill.sh [--project-dir <dir>] [--dry-run]
# Output: writes updated dispatch.jsonl + summary to stdout.
# L-S11-1 portability: bash + awk + grep + sed only; node already dependency in parent hook.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
DRY_RUN=0

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --project-dir) shift; PROJECT_DIR="$1" ;;
    --dry-run) DRY_RUN=1 ;;
    *) ;;
  esac
  shift
done

MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
DISPATCH_JSONL="$MEMORY_DIR/dispatch.jsonl"
OBS_DIR="$MEMORY_DIR/observations"
MODEL_CACHE="$MEMORY_DIR/.dispatch-model-cache.tsv"
AGENTS_DIR="$PROJECT_DIR/.claude/agents"

if [ ! -f "$DISPATCH_JSONL" ]; then
  printf 'INFO: dispatch.jsonl not found at %s — nothing to backfill\n' "$DISPATCH_JSONL"
  exit 0
fi

# Build observation → agent_type map from filenames
# Pattern: sandwich-<role>-S<N>-*.md → agent_type = sandwich-<role>
# Also: sandwich-dev, sandwich-architect, sandwich-verifier, promote-rule, lesson-synthesis, etc.
declare -A OBS_ROLE_MAP 2>/dev/null || true
OBS_ROLE_MAP_FILE="$(mktemp)"
if [ -d "$OBS_DIR" ]; then
  for obs in "$OBS_DIR"/*.md; do
    if [ -f "$obs" ]; then
      bn="$(basename "$obs" .md)"
      # Extract agent role from filename prefix
      atype=""
      case "$bn" in
        sandwich-dev-*) atype="sandwich-dev" ;;
        sandwich-architect-*) atype="sandwich-architect" ;;
        sandwich-verifier-*) atype="sandwich-verifier" ;;
        lesson-synthesis-*) atype="lesson-synthesizer" ;;
        promote-rule-*) atype="promote-rule" ;;
        intent-*) atype="intent-classifier" ;;
        drift-*) atype="drift-detector" ;;
        *) ;;
      esac
      if [ -n "$atype" ]; then
        printf '%s\t%s\n' "$bn" "$atype" >> "$OBS_ROLE_MAP_FILE"
      fi
    fi
  done
fi

# Model resolution function (file-based; no caching for backfill to avoid side effects)
resolve_model() {
  local stype="$1"
  # Fast path: known types
  case "$stype" in
    master-planner|sandwich-architect|sandwich-verifier|devils-advocate|intent-vs-impl-diff|spec-author|lesson-synthesizer|drift-detector) printf 'opus'; return ;;
    sandwich-dev|action-guide-planner|bdd-planner|ul-auditor|research-scanner) printf 'sonnet'; return ;;
    intent-classifier) printf 'haiku'; return ;;
  esac
  # Read from agent file
  local agent_file="$AGENTS_DIR/${stype}.md"
  if [ -f "$agent_file" ]; then
    local m
    m="$(awk '/^---/{c++;next}c==1&&/^model:/{sub(/^model:[[:space:]]*/,"");print;exit}c>1{exit}' "$agent_file" 2>/dev/null || true)"
    if [ -n "$m" ]; then
      case "$m" in
        *opus*) printf 'opus'; return ;;
        *sonnet*) printf 'sonnet'; return ;;
        *haiku*) printf 'haiku'; return ;;
      esac
      printf '%s' "$m"
      return
    fi
  fi
  printf 'unknown'
}

# Build sidecar index: dispatch_id → agent_type from .dispatch-pending-*.jsonl files
SIDECAR_INDEX="$(mktemp)"
for sidecar in "$MEMORY_DIR"/.dispatch-pending-*.jsonl; do
  if [ -f "$sidecar" ]; then
    while IFS= read -r line; do
      if [ -z "$line" ]; then
        continue
      fi
      did="$(printf '%s' "$line" | grep -o '"dispatch_id":"[^"]*"' 2>/dev/null | head -1 | sed 's/"dispatch_id":"//;s/"//' || true)"
      atype="$(printf '%s' "$line" | grep -o '"agent_type":"[^"]*"' 2>/dev/null | head -1 | sed 's/"agent_type":"//;s/"//' || true)"
      if [ -n "$did" ] && [ -n "$atype" ] && [ "$atype" != "unknown-agent" ]; then
        printf '%s\t%s\n' "$did" "$atype" >> "$SIDECAR_INDEX"
      fi
    done < "$sidecar"
  fi
done

# Process dispatch.jsonl — rewrite with recovered agent_type + model
TOTAL=0
RECOVERED=0
ALREADY_KNOWN=0
TMPOUT="$(mktemp)"

while IFS= read -r line; do
  if [ -z "$line" ]; then
    continue
  fi
  TOTAL=$(( TOTAL + 1 ))

  # Extract current fields using awk
  cur_atype="$(printf '%s' "$line" | awk '{match($0,/"agent_type":"([^"]*)"/, a); print a[1]}' || true)"
  cur_model="$(printf '%s' "$line" | awk '{match($0,/"model":"([^"]*)"/, a); print a[1]}' || true)"

  # If both are known, keep as-is
  if [ "${cur_atype:-unknown-agent}" != "unknown-agent" ] && [ "${cur_model:-unknown}" != "unknown" ]; then
    printf '%s\n' "$line" >> "$TMPOUT"
    ALREADY_KNOWN=$(( ALREADY_KNOWN + 1 ))
    continue
  fi

  # Try to recover agent_type
  new_atype="$cur_atype"

  # Check sidecar index
  did="$(printf '%s' "$line" | awk '{match($0,/"dispatch_id":"([^"]*)"/, a); print a[1]}' || true)"
  if [ "${new_atype:-unknown-agent}" = "unknown-agent" ] && [ -n "$did" ]; then
    if [ -f "$SIDECAR_INDEX" ]; then
      sc_atype="$(awk -v d="$did" 'BEGIN{FS="\t"} $1==d{print $2;exit}' "$SIDECAR_INDEX" 2>/dev/null || true)"
      if [ -n "$sc_atype" ] && [ "$sc_atype" != "unknown-agent" ]; then
        new_atype="$sc_atype"
      fi
    fi
  fi

  # Resolve model from agent type
  new_model="$cur_model"
  if [ "${new_model:-unknown}" = "unknown" ] && [ "${new_atype:-unknown-agent}" != "unknown-agent" ]; then
    new_model="$(resolve_model "$new_atype")"
  fi

  # If still unknown-agent, keep original
  if [ "${new_atype:-unknown-agent}" = "unknown-agent" ]; then
    printf '%s\n' "$line" >> "$TMPOUT"
    continue
  fi

  # Build updated line using awk substitution
  updated_line="$(printf '%s' "$line" | \
    awk -v na="$new_atype" -v nm="$new_model" '{
      gsub(/"agent_type":"[^"]*"/, "\"agent_type\":\""na"\"");
      gsub(/"model":"[^"]*"/, "\"model\":\""nm"\"");
      print
    }' || true)"

  if [ -n "$updated_line" ]; then
    printf '%s\n' "$updated_line" >> "$TMPOUT"
    RECOVERED=$(( RECOVERED + 1 ))
  else
    printf '%s\n' "$line" >> "$TMPOUT"
  fi

done < "$DISPATCH_JSONL"

# Compute recovery rate
POSS_RECOVERY=$(( TOTAL - ALREADY_KNOWN ))
RATE=0
if [ "$POSS_RECOVERY" -gt 0 ]; then
  RATE="$(awk -v r="$RECOVERED" -v t="$POSS_RECOVERY" 'BEGIN{printf "%.0f", r*100/t}')"
fi

printf '=== dispatch-jsonl-backfill summary ===\n'
printf 'Total rows: %s\n' "$TOTAL"
printf 'Already known (agent_type+model correct): %s\n' "$ALREADY_KNOWN"
printf 'Candidates for recovery: %s\n' "$POSS_RECOVERY"
printf 'Recovered: %s\n' "$RECOVERED"
printf 'Recovery rate: %s%%\n' "$RATE"

if [ "$DRY_RUN" = "1" ]; then
  printf '[DRY RUN] No files written. Would update dispatch.jsonl.\n'
  printf 'Sample updated rows (first 5 recovered):\n'
  diff "$DISPATCH_JSONL" "$TMPOUT" 2>/dev/null | grep '^>' | head -5 || true
else
  # Backup original
  cp "$DISPATCH_JSONL" "${DISPATCH_JSONL}.backfill-backup-$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
  mv "$TMPOUT" "$DISPATCH_JSONL"
  printf 'dispatch.jsonl updated.\n'
fi

# Cleanup
rm -f "$OBS_ROLE_MAP_FILE" "$SIDECAR_INDEX" "$TMPOUT" 2>/dev/null || true

exit 0
