#!/usr/bin/env bash
# phase-status-coherence.sh — UserPromptSubmit + SessionStart hook.
# Verifies project.md "Phase Goals Tracker" IN-PROGRESS rows agree with the
# Phase claimed in current-execution.md's latest session block.
#
# Phase 3.5 / S175 deliverable. M-S171-1 prevention rule #3 (companion to
# idle-escape-detector.sh). HH-12 enhancement + HH-C.2 staleness-watchdog
# back-stop (project-md-staleness-check.sh runs Stop-only and missed the 2-day
# × 5-ADR slip pre-S172 — this hook fires per-prompt at UserPromptSubmit so
# the gap surfaces sooner).
#
# Three checks:
#   (A) Latest ## S<N> session header Phase claim ∈ {project.md IN PROGRESS rows}
#   (B) project.md mtime not >48h staler than current-execution.md mtime when
#       ADRs are referenced in current-execution.md's recent rows but absent
#       from project.md "Recent Architectural Decisions" section.
#   (C) project.md Phase Goals Tracker has at least one IN PROGRESS row when
#       current-execution.md is being actively appended (i.e., not all phases
#       PAUSED/DONE simultaneously while sessions still progress).
#
# Per CLAUDE.md hard rule + Phase 3.5 Hard Rule #2: every hook ships with companion
# firing-test (scripts/hooks/firing-tests/phase-status-coherence-fire-test.sh).
# Per UP-05 + L-S11-1: bash + POSIX tools only.
# Exit 0 ALWAYS (informational, not blocking).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
EVENT="${1:-${CLAUDE_HOOK_EVENT:-UserPromptSubmit}}"
mkdir -p "$PROJECT_DIR/agent-workspace/memory" 2>/dev/null || true

CE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
PROJ="$PROJECT_DIR/agent-workspace/memory/project.md"
DECISIONS_DIR="$PROJECT_DIR/agent-workspace/memory/decisions"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"
COHERENCE_LOG="$PROJECT_DIR/agent-workspace/memory/.phase-coherence.log"

BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$PROJECT_DIR/agent-workspace/memory/.phase-coherence-fired-${BUCKET}"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"

# Per-session 5-min cache (perf budget).
CACHE="$PROJECT_DIR/agent-workspace/memory/.phase-coherence-cache-${SID}"
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( $(date +%s) - CACHE_MTIME ))
  if [ "$AGE" -lt 300 ]; then
    echo "[$TS] phase-status-coherence: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
    exit 0
  fi
fi

# Cleanup stale hour-bucket markers (L-S108-1 prevention).
for old_marker in "$PROJECT_DIR/agent-workspace/memory"/.phase-coherence-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".phase-coherence-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null || true ;;
  esac
done

# Bail gracefully if either file missing.
if [ ! -f "$CE" ] || [ ! -f "$PROJ" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

set +o pipefail

# ============================================================================
# Step 1: extract latest session Phase claim from current-execution.md.
# Headers look like:  ## S174 — Phase 3.5 — FOCUSED_IMPL-DONE: ...
# ============================================================================
LATEST_HEADER=$(grep -m 1 -E '^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase' "$CE" 2>/dev/null)
if [ -z "$LATEST_HEADER" ]; then
  touch "$MARKER" 2>/dev/null || true
  echo "session=$SID ts=$TS state=NO-HEADER detail=cannot-parse-current-execution" > "$CACHE" 2>/dev/null || true
  exit 0
fi

LATEST_SID=$(echo "$LATEST_HEADER" | sed -E 's/^## (S[0-9]+[a-z]?).*/\1/')
LATEST_PHASE=$(echo "$LATEST_HEADER" | sed -E 's/^## S[0-9]+[a-z]?[[:space:]]+—[[:space:]]+Phase[[:space:]]+([0-9]+(\.[0-9]+)?).*/\1/')

# ============================================================================
# Step 2: collect project.md IN PROGRESS Phase rows. Tracker rows look like:
#   | 3.5 — Harness Deepening (...) | targets ... | IN PROGRESS PARTIAL-S173 | started | closed |
# We scan rows starting with `| <N>(.<M>)?` and containing "IN PROGRESS".
# ============================================================================
IN_PROGRESS_PHASES=$(grep -E '^\|[[:space:]]*[0-9]+(\.[0-9]+)?[[:space:]]+—' "$PROJ" 2>/dev/null \
                     | grep -i 'IN PROGRESS' \
                     | sed -E 's/^\|[[:space:]]*([0-9]+(\.[0-9]+)?)[[:space:]]+—.*/\1/' \
                     | sort -u)

IN_PROGRESS_COUNT=0
if [ -n "$IN_PROGRESS_PHASES" ]; then
  # L-S80-2: avoid VAR=$(grep -c ... || echo 0) multi-line capture trap.
  # IN_PROGRESS_COUNT only needs binary ≥0/≥1 for downstream -eq 0 / -gt 0 checks.
  if echo "$IN_PROGRESS_PHASES" | grep -q . 2>/dev/null; then IN_PROGRESS_COUNT=1; else IN_PROGRESS_COUNT=0; fi
fi

# ============================================================================
# Step 3: Check (A) — latest session phase ∈ IN PROGRESS phase rows?
# ============================================================================
PHASE_MATCH=0
if [ -n "$LATEST_PHASE" ] && [ -n "$IN_PROGRESS_PHASES" ]; then
  if echo "$IN_PROGRESS_PHASES" | grep -qE "^${LATEST_PHASE}$"; then
    PHASE_MATCH=1
  fi
fi

# ============================================================================
# Step 4: Check (B) — staleness via mtime delta + new-ADR detection.
# project.md "Recent Architectural Decisions" should reference ALL recent ADRs
# from agent-workspace/memory/decisions/ that are newer than the file's last
# update. If decisions/ has D-NNN files newer than project.md mtime, project.md
# is missing recent decisions → stale.
# ============================================================================
PROJ_MTIME=$(stat -c %Y "$PROJ" 2>/dev/null || stat -f %m "$PROJ" 2>/dev/null || echo 0)
CE_MTIME=$(stat -c %Y "$CE" 2>/dev/null || stat -f %m "$CE" 2>/dev/null || echo 0)
NOW=$(date +%s)
PROJ_AGE_HR=$(( (NOW - PROJ_MTIME) / 3600 ))

NEW_ADRS=0
if [ -d "$DECISIONS_DIR" ] && [ "$PROJ_MTIME" -gt 0 ]; then
  # Count ADR files (D-NNN-*.md or NNN-*.md) newer than project.md by >2h tolerance
  # (matches project-md-staleness-check.sh tolerance).
  while IFS= read -r adr; do
    [ -f "$adr" ] || continue
    ADR_MTIME=$(stat -c %Y "$adr" 2>/dev/null || stat -f %m "$adr" 2>/dev/null || echo 0)
    DELTA=$(( ADR_MTIME - PROJ_MTIME ))
    if [ "$DELTA" -gt 7200 ]; then
      NEW_ADRS=$((NEW_ADRS + 1))
    fi
  done < <(find "$DECISIONS_DIR" -maxdepth 1 -type f \( -name 'D-*.md' -o -name '[0-9][0-9][0-9]-*.md' \) 2>/dev/null)
fi

# CE is fresher than project.md by how much?
CE_PROJ_DELTA_HR=0
if [ "$CE_MTIME" -gt "$PROJ_MTIME" ] && [ "$PROJ_MTIME" -gt 0 ]; then
  CE_PROJ_DELTA_HR=$(( (CE_MTIME - PROJ_MTIME) / 3600 ))
fi

# ============================================================================
# Step 5: Check (C) — at least one IN PROGRESS row exists.
# ============================================================================
NO_ACTIVE_PHASE=0
if [ "$IN_PROGRESS_COUNT" -eq 0 ]; then
  NO_ACTIVE_PHASE=1
fi

# ============================================================================
# Step 6: severity classification.
# ============================================================================
STATE="GREEN"
SEVERITY="LOW"
DETAILS=""

if [ -n "$LATEST_PHASE" ] && [ "$IN_PROGRESS_COUNT" -gt 0 ] && [ "$PHASE_MATCH" -eq 0 ]; then
  STATE="RED"
  SEVERITY="HIGH"
  DETAILS="${DETAILS}phase-mismatch(ce=${LATEST_PHASE},in-progress=$(echo "$IN_PROGRESS_PHASES" | tr '\n' ',' | sed 's/,$//'));"
fi

if [ "$NEW_ADRS" -ge 3 ] && [ "$CE_PROJ_DELTA_HR" -gt 24 ]; then
  if [ "$STATE" = "GREEN" ]; then
    STATE="YELLOW"
    SEVERITY="MEDIUM"
  fi
  DETAILS="${DETAILS}stale-project-md(new_adrs=${NEW_ADRS},ce_delta_hr=${CE_PROJ_DELTA_HR});"
fi

if [ "$NO_ACTIVE_PHASE" -eq 1 ]; then
  if [ "$STATE" = "GREEN" ]; then
    STATE="YELLOW"
    SEVERITY="MEDIUM"
  fi
  DETAILS="${DETAILS}no-in-progress-phase(rows=0);"
fi

# Cache result.
{
  printf 'session=%s ts=%s state=%s severity=%s ce_phase=%s in_progress=%s match=%d new_adrs=%d ce_delta_hr=%d details=%s\n' \
    "$SID" "$TS" "$STATE" "$SEVERITY" "$LATEST_PHASE" "$(echo "$IN_PROGRESS_PHASES" | tr '\n' ',' | sed 's/,$//')" \
    "$PHASE_MATCH" "$NEW_ADRS" "$CE_PROJ_DELTA_HR" "$DETAILS"
} > "$CACHE" 2>/dev/null || true

echo "[$TS] phase-status-coherence: state=$STATE ce_sid=$LATEST_SID ce_phase=$LATEST_PHASE in_progress=[$(echo "$IN_PROGRESS_PHASES" | tr '\n' ',' | sed 's/,$//')] match=$PHASE_MATCH new_adrs=$NEW_ADRS session=$SID" \
  >> "$HOOK_LOG" 2>/dev/null || true

# Idempotent fire — suppress system-reminder if already fired this hour-bucket.
if [ -f "$MARKER" ]; then
  exit 0
fi

if [ "$STATE" = "GREEN" ]; then
  touch "$MARKER" 2>/dev/null || true
  exit 0
fi

# Audit log entry.
{
  printf '[%s] %s state=%s severity=%s ce_sid=%s ce_phase=%s in_progress=[%s] match=%d new_adrs=%d ce_delta_hr=%d details=%s session=%s event=%s\n' \
    "$TS" "DRIFT-DETECTED" "$STATE" "$SEVERITY" "$LATEST_SID" "$LATEST_PHASE" \
    "$(echo "$IN_PROGRESS_PHASES" | tr '\n' ',' | sed 's/,$//')" \
    "$PHASE_MATCH" "$NEW_ADRS" "$CE_PROJ_DELTA_HR" "$DETAILS" "$SID" "$EVENT"
} >> "$COHERENCE_LOG" 2>/dev/null || true

REMINDER_BODY="PHASE-STATUS-COHERENCE: state=$STATE severity=$SEVERITY
Latest current-execution.md session: $LATEST_SID — Phase $LATEST_PHASE
project.md Phase Goals Tracker IN PROGRESS rows: [$(echo "$IN_PROGRESS_PHASES" | tr '\n' ',' | sed 's/,$//')]
Match: $PHASE_MATCH (0=mismatch, 1=aligned)
New ADRs in decisions/ since project.md last update: $NEW_ADRS (delta_hr=$CE_PROJ_DELTA_HR)
Details: $DETAILS

Per HH-12 + HH-C.2 doctrine + verify_phase_before_next_phase BINDING: silent phase advance is forbidden.
Required action ONE OF:
  (a) Reconcile project.md Phase Goals Tracker against current-execution.md (add missing IN PROGRESS row, adjust DONE/PAUSED status, update Recent ADRs);
  (b) Correct current-execution.md if the latest session block claims a Phase that is not actually active;
  (c) Run /drift-check or fresh-context audit subagent if the source-of-truth is genuinely ambiguous.
Forbidden: continue substantive work until reconciled. AP-5 + Charter Principle 8 binding."

if [ "$EVENT" = "UserPromptSubmit" ]; then
  if command -v node >/dev/null 2>&1; then
    node -e "process.stdout.write(JSON.stringify({hookSpecificOutput:{hookEventName:'UserPromptSubmit',additionalContext:process.argv[1]}}))" "$REMINDER_BODY" 2>/dev/null || \
      echo "[phase-coherence] $REMINDER_BODY" >&2
  else
    echo "[phase-coherence] $REMINDER_BODY" >&2
  fi
elif [ "$EVENT" = "SessionStart" ]; then
  echo "[phase-coherence] $REMINDER_BODY" >&2
else
  echo "[phase-coherence] event=$EVENT $REMINDER_BODY" >&2
fi

touch "$MARKER" 2>/dev/null || true
exit 0
