#!/usr/bin/env bash
# profile-template-auto-populate.sh — HH-C.3 Stop hook
#
# Purpose: emit/update one self-awareness profile card per session by
# extracting (model, effort, task_class) from the most recent session log
# frontmatter and appending a sample row to the matching profile card under
# agent-workspace/memory/self-awareness/profiles/.
#
# Deterministic boundary:
#   - Updates frontmatter `samples_count` + `sample_sessions` array only.
#   - Body sections (Capabilities, Limitations, etc.) remain LLM-filled per
#     profile-template.md § "Phase 1+ telemetry-analyst" doctrine.
#
# Per HH-C of 009-S48-harness-hardening-middle-phase.md.
# Per L-S11-1 portability: bash + standard POSIX tools only.
# Soft-warn exit 0 always; never blocks Stop chain.

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
SESSIONS_DIR="$MEMORY_DIR/sessions"
PROFILES_DIR="$MEMORY_DIR/self-awareness/profiles"
TEMPLATE="$MEMORY_DIR/self-awareness/profile-template.md"
LOG="$MEMORY_DIR/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

[ ! -d "$SESSIONS_DIR" ] && exit 0
mkdir -p "$PROFILES_DIR" 2>/dev/null || true

# Find latest session log written within last 4h.
LATEST_SESSION="$(find "$SESSIONS_DIR" -maxdepth 1 -name '*.md' -type f -mmin -240 -printf '%T@\t%p\n' 2>/dev/null \
                  | sort -rn | head -1 | cut -f2)"
[ -z "$LATEST_SESSION" ] || [ ! -f "$LATEST_SESSION" ] && exit 0

# === S48m fix: derive per-session marker from session-log filename, not from
# $CLAUDE_SESSION_ID env (which is empty in 174/174 SessionStart events on
# Windows Claude Code 4.x; auto-populate residue investigation finding). The
# session-log basename is unique-per-session and stable across hook re-fires.
LATEST_BASENAME="$(basename "$LATEST_SESSION" .md 2>/dev/null)"
[ -z "$LATEST_BASENAME" ] && exit 0
MARKER="$MEMORY_DIR/.profile-template-fired-${LATEST_BASENAME}"

# Idempotent: bail if already fired for this session log.
[ -f "$MARKER" ] && exit 0

# ============================================================================
# Extract metadata (supports two frontmatter styles):
#   Style A (YAML):  type: FOCUSED_IMPL  /  agent: sandwich-dev (claude-sonnet-4-6)
#   Style B (md):    **Type**: FOCUSED_IMPL
# Default model = opus47-max when not specified (main session per CLAUDE.md identity).
# ============================================================================

# Disable pipefail temporarily — optional greps that legitimately match-nothing
# would otherwise tip the ERR trap. Re-enabled after extraction.
set +o pipefail

# task_class via type field
TASK_CLASS="$( { grep -m1 -iE '^(type:|^\*\*type\*\*:)' "$LATEST_SESSION" 2>/dev/null || true; } \
              | sed -E 's/^.*[Tt]ype[*:]+[[:space:]]*//; s/[[:space:]].*$//' \
              | tr -d '[:space:]')"
[ -z "$TASK_CLASS" ] && TASK_CLASS="UNKNOWN"

# model from agent line (YAML style only); fallback opus47
MODEL_RAW="$( { grep -m1 -E '^agent:' "$LATEST_SESSION" 2>/dev/null || true; } \
             | { grep -oE 'claude-(opus|sonnet|haiku)-[0-9]+(-[0-9]+)?' || true; } | head -1)"

set -o pipefail

case "$MODEL_RAW" in
  claude-opus-4-7|claude-opus-4-6) MODEL_SHORT="opus47-max" ;;
  claude-sonnet-4-6|claude-sonnet-4-5) MODEL_SHORT="sonnet46-max" ;;
  claude-haiku-4-5*) MODEL_SHORT="haiku45-max" ;;
  *) MODEL_SHORT="opus47-max" ;;
esac

# Extract session N number from filename (YYYY-MM-DD-session-N.md or -session-Nx.md).
SESSION_FILENAME="$(basename "$LATEST_SESSION")"
SESSION_N="$(echo "$SESSION_FILENAME" | sed -E 's/.*session-([0-9]+[a-z]?).*/S\1/')"
[ -z "$SESSION_N" ] || [ "$SESSION_N" = "$SESSION_FILENAME" ] && SESSION_N="S?"

# Bail if extraction failed completely.
if [ "$TASK_CLASS" = "UNKNOWN" ]; then
  echo "[$TS] profile-template-auto-populate: skip session=$SESSION_ID file=$SESSION_FILENAME (no type extracted)" >> "$LOG" 2>/dev/null || true
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

PROFILE_CARD="$PROFILES_DIR/${MODEL_SHORT}-${TASK_CLASS}.md"

# ============================================================================
# Path A: card exists → append SESSION_N to sample_sessions array if not already present
# ============================================================================
if [ -f "$PROFILE_CARD" ]; then
  # Already cited?
  if grep -qE "(\[|, )${SESSION_N}(,|\])" "$PROFILE_CARD" 2>/dev/null; then
    # Idempotent — sample already recorded.
    touch "$MARKER" 2>/dev/null || true
    exit 0
  fi

  # Append session ID to sample_sessions array. The line looks like:
  #   sample_sessions: [S26, S28, S30, S32, S35]
  # Use sed to insert before the closing ].
  if grep -qE '^sample_sessions:[[:space:]]*\[' "$PROFILE_CARD" 2>/dev/null; then
    # Cross-platform sed inplace: write to tmp + mv (avoids GNU vs BSD -i divergence).
    TMP="${PROFILE_CARD}.tmp.$$"
    awk -v sn="$SESSION_N" -v ts="$TS" '
      /^sample_sessions:[[:space:]]*\[/ {
        # Insert sn before the closing bracket on this line.
        sub(/\]/, ", " sn "]")
      }
      /^samples_count:[[:space:]]*[0-9]+/ {
        # Increment count.
        match($0, /[0-9]+/)
        n = substr($0, RSTART, RLENGTH) + 1
        $0 = "samples_count: " n
      }
      /^last_updated:/ {
        $0 = "last_updated: " ts
      }
      { print }
    ' "$PROFILE_CARD" > "$TMP" && mv "$TMP" "$PROFILE_CARD"
    echo "[$TS] profile-template-auto-populate: appended $SESSION_N to ${MODEL_SHORT}-${TASK_CLASS}.md" >> "$LOG" 2>/dev/null || true

    # Plan 011 D6: enqueue profile-render job when samples_count crosses rebuild threshold (default 10).
    # Configurable via STOCKFORGE_PROFILE_REBUILD_THRESHOLD env var. Kill switch: MEMORY_ETL_DISABLE=1.
    PROFILE_THRESHOLD="${STOCKFORGE_PROFILE_REBUILD_THRESHOLD:-10}"
    NEW_COUNT="$(awk '/^samples_count:[[:space:]]*[0-9]+/ {match($0,/[0-9]+/);print substr($0,RSTART,RLENGTH);exit}' "$PROFILE_CARD" 2>/dev/null || echo 0)"
    if [ "${NEW_COUNT:-0}" -ge "$PROFILE_THRESHOLD" ] 2>/dev/null && [ "${MEMORY_ETL_DISABLE:-0}" != "1" ]; then
      ETL_QUEUE_DIR="$MEMORY_DIR/etl-queue"
      if mkdir -p "$ETL_QUEUE_DIR" 2>/dev/null; then
        ETL_TS_FN="$(date -u +%Y%m%d-%H%M%S 2>/dev/null || echo unknown)"
        ETL_JOB="$ETL_QUEUE_DIR/3-${ETL_TS_FN}-profile-render-${MODEL_SHORT}-${TASK_CLASS}.job"
        # Dedup: skip if same-cell job already pending in queue
        if ! ls "$ETL_QUEUE_DIR"/*"profile-render-${MODEL_SHORT}-${TASK_CLASS}.job" >/dev/null 2>&1; then
          {
            printf -- '---\n'
            printf 'task: profile-render\n'
            printf 'payload: {"model":"%s","task_class":"%s","samples_count":%s,"profile_card":"%s"}\n' \
              "$MODEL_SHORT" "$TASK_CLASS" "$NEW_COUNT" "$PROFILE_CARD"
            printf 'created_at: %s\n' "$TS"
            printf 'producer: profile-template-auto-populate.sh\n'
            printf -- '---\n'
          } > "$ETL_JOB" 2>/dev/null || true
        fi
      fi
    fi
  fi
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# ============================================================================
# Path B: card missing → create stub from template skeleton.
# Body left empty (LLM telemetry-analyst fills per Phase 1+ doctrine).
# ============================================================================
cat > "$PROFILE_CARD" 2>/dev/null <<EOF
---
model: ${MODEL_RAW:-claude-opus-4-7}
effort: max
thinking: enabled
task_class:
  - ${TASK_CLASS}
samples_count: 1
sample_sessions: [${SESSION_N}]
last_updated: ${TS}
source: agent-workspace/memory/self-awareness/sessions-rollup.tsv
auto_populated_by: scripts/hooks/profile-template-auto-populate.sh
---

# Profile — ${MODEL_SHORT} × ${TASK_CLASS}

> Stub auto-created at session-end. Body sections to be filled by telemetry-analyst
> (LLM, fresh context, session-end only) per profile-template.md § "Phase 1+ consumer".
> See agent-workspace/memory/self-awareness/profile-template.md for body schema.

## 1. Capabilities

(LLM-filled — see template body schema)

## 2. Known limitations

(LLM-filled — failure_mode codes from component-telemetry.jsonl)

## 3. Recommended task_class allocation

(LLM-filled)

## 4. Recent corrections + drift events

(LLM-filled — pointer to mistake-log.md entries)

## 5. Calibration

(empirical only — Charter Principle 9 No LLM math)

## 6. Notes

(LLM-filled)
EOF

echo "[$TS] profile-template-auto-populate: created ${MODEL_SHORT}-${TASK_CLASS}.md from session $SESSION_N" >> "$LOG" 2>/dev/null || true
touch "$MARKER" 2>/dev/null || true
exit 0
