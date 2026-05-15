#!/usr/bin/env bash
# idle-state-advisory.sh — SessionStart + UserPromptSubmit hook.
# Read-only harness-state AGGREGATOR. Collects the states already computed by the
# upstream sub-hooks (harness-health-self-scan, idle-escape-detector,
# phase-status-coherence) plus a few cheap workspace counters, and writes a
# single-line snapshot to .idle-state-advisory-cache-${SID}.
#
# Recovered after the S310-S316 mass-deletion: the script was referenced in
# .claude/settings.json but never committed. The surviving cache file
# (.idle-state-advisory-cache-unknown) fixed the exact output contract:
#   session= ts= green=YES|NO hh= ie= pc= urgent_lines= unattested= \
#     up_delta_hr= qa_bundles= qa_delta_hr= qg_open=
#
# Wires: SessionStart + UserPromptSubmit, AFTER harness-health-self-scan.sh /
# idle-escape-detector.sh / phase-status-coherence.sh — so their session caches
# are fresh when this hook reads them.
#
# Design: QUIET aggregator. The cache line is the deliverable; other tooling reads
# it for a one-glance harness snapshot. Emits at most ONE plain-stderr line when
# green=NO (no stdout JSON — the three upstream sub-hooks already own the detailed
# system-reminder emission; duplicating it here would be noise AND a JSON-schema
# risk). green=YES/NO is derived purely from hh/ie/pc (the signals readable with
# confidence); the other fields are informational context.
#
# Per L-S11-1: bash + POSIX tools only. Exit 0 ALWAYS (informational, not blocking).
# Per L-S108-1: hour-bucket idempotency marker (CLAUDE_SESSION_ID may be empty).
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SID="${CLAUDE_SESSION_ID:-unknown}"
EVENT="${1:-${CLAUDE_HOOK_EVENT:-UserPromptSubmit}}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
mkdir -p "$MEM_DIR" 2>/dev/null || true

HOOK_LOG="$MEM_DIR/.session-hooks.log"
CACHE="$MEM_DIR/.idle-state-advisory-cache-${SID}"
TS="$(date -Iseconds 2>/dev/null || date '+%Y-%m-%dT%H:%M:%S')"
NOW="$(date +%s 2>/dev/null || echo 0)"

# === Same-session 5-min cache (mirrors harness-health-self-scan.sh) ===
if [ -f "$CACHE" ]; then
  CACHE_MTIME=$(stat -c %Y "$CACHE" 2>/dev/null || stat -f %m "$CACHE" 2>/dev/null || echo 0)
  AGE=$(( NOW - CACHE_MTIME ))
  if [ "$AGE" -ge 0 ] && [ "$AGE" -lt 300 ]; then
    echo "[$TS] idle-state-advisory: CACHE-HIT age=${AGE}s session=$SID" >> "$HOOK_LOG" 2>/dev/null || true
    exit 0
  fi
fi

# === Hour-bucket idempotency marker (suppresses repeat stderr emission) ===
BUCKET="$(date +%Y%m%d-%H 2>/dev/null)"
[ -z "$BUCKET" ] && BUCKET="unbucketed-$$"
MARKER="$MEM_DIR/.idle-state-advisory-fired-${BUCKET}"
for old_marker in "$MEM_DIR"/.idle-state-advisory-fired-*; do
  [ -f "$old_marker" ] || continue
  case "$old_marker" in
    *".idle-state-advisory-fired-${BUCKET}") ;;
    *) rm -f "$old_marker" 2>/dev/null || true ;;
  esac
done

# Pipefail off for the data-gathering section (mirrors idle-escape-detector.sh):
# grep|head pipelines legitimately "fail" on no-match and must not trip trap ERR.
set +o pipefail

# === Helper: extract `state=` value from a sub-hook's single-line cache file ===
read_state() {
  local f="$1"
  [ -f "$f" ] || return 0
  grep -oE 'state=[A-Za-z0-9_.-]+' "$f" 2>/dev/null | head -1 | cut -d= -f2
}

# === Sub-hook states (fresh: those hooks run earlier in the same chain) ===
HH="$(read_state "$MEM_DIR/.harness-health-cache-${SID}")"
IE="$(read_state "$MEM_DIR/.idle-escape-cache-${SID}")"
PC="$(read_state "$MEM_DIR/.phase-coherence-cache-${SID}")"

# === urgent.md line count ===
URGENT_LINES=0
URGENT_MD="$PROJECT_DIR/human-workspace/notifications/urgent.md"
if [ -f "$URGENT_MD" ]; then
  URGENT_LINES=$(wc -l < "$URGENT_MD" 2>/dev/null | tr -d '[:space:]')
fi
[[ "$URGENT_LINES" =~ ^[0-9]+$ ]] || URGENT_LINES=0

# === Unattested observations (data rows in the registry, minus header) ===
UNATTESTED=0
REG="$MEM_DIR/.unattested-observations.tsv"
if [ -f "$REG" ]; then
  REG_LINES=$(wc -l < "$REG" 2>/dev/null | tr -d '[:space:]')
  [[ "$REG_LINES" =~ ^[0-9]+$ ]] || REG_LINES=0
  [ "$REG_LINES" -gt 1 ] && UNATTESTED=$(( REG_LINES - 1 ))
fi

# === Hours since newest human-workspace/user_prompt/ file (999 sentinel = none) ===
UP_DELTA_HR=999
UP_DIR="$PROJECT_DIR/human-workspace/user_prompt"
if [ -d "$UP_DIR" ]; then
  NEWEST_UP=$(find "$UP_DIR" -maxdepth 1 -type f -name '*.txt' 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
  if [ -n "$NEWEST_UP" ] && [ -f "$NEWEST_UP" ]; then
    UP_MTIME=$(stat -c %Y "$NEWEST_UP" 2>/dev/null || stat -f %m "$NEWEST_UP" 2>/dev/null || echo 0)
    if [ "$UP_MTIME" -gt 0 ] && [ "$NOW" -gt 0 ]; then
      UP_DELTA_HR=$(( (NOW - UP_MTIME) / 3600 ))
    fi
  fi
fi

# === Pending Q&A bundle count + hours since newest Q&A activity ===
QA_BUNDLES=0
QA_PENDING="$PROJECT_DIR/human-workspace/q-and-a/pending"
if [ -d "$QA_PENDING" ]; then
  QA_BUNDLES=$(find "$QA_PENDING" -maxdepth 1 -type f -name '*.md' 2>/dev/null | wc -l | tr -d '[:space:]')
fi
[[ "$QA_BUNDLES" =~ ^[0-9]+$ ]] || QA_BUNDLES=0

QA_DELTA_HR=999
QA_ANSWERED="$PROJECT_DIR/human-workspace/q-and-a/answered"
NEWEST_QA=$(find "$QA_PENDING" "$QA_ANSWERED" -maxdepth 1 -type f -name '*.md' 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
if [ -n "$NEWEST_QA" ] && [ -f "$NEWEST_QA" ]; then
  QA_MTIME=$(stat -c %Y "$NEWEST_QA" 2>/dev/null || stat -f %m "$NEWEST_QA" 2>/dev/null || echo 0)
  if [ "$QA_MTIME" -gt 0 ] && [ "$NOW" -gt 0 ]; then
    QA_DELTA_HR=$(( (NOW - QA_MTIME) / 3600 ))
  fi
fi

# === Open quality gates — best-effort: quality-report files recording a FAIL.
# The exact open-count source was not recovered from the mass-deletion; this is a
# bounded approximation. Informational only — does NOT drive green. ===
QG_OPEN=0
QR_DIR="$PROJECT_DIR/agent-workspace/quality-reports"
if [ -d "$QR_DIR" ]; then
  QG_MATCHES=$(grep -rlE '(^|[^A-Za-z])FAIL([^A-Za-z]|$)' "$QR_DIR" 2>/dev/null || true)
  if [ -n "$QG_MATCHES" ]; then
    QG_OPEN=$(printf '%s\n' "$QG_MATCHES" | wc -l | tr -d '[:space:]')
  fi
fi
[[ "$QG_OPEN" =~ ^[0-9]+$ ]] || QG_OPEN=0

# === Derive green=YES/NO from the sub-hook states readable with confidence.
# Any non-GREEN, non-empty hh/ie/pc => NO. Empty (sub-hook cache absent) does not
# penalize — matches the surviving cache (ie= pc= empty; green driven by hh). ===
GREEN="YES"
case "$HH" in GREEN|"") ;; *) GREEN="NO" ;; esac
case "$IE" in GREEN|"") ;; *) GREEN="NO" ;; esac
case "$PC" in GREEN|"") ;; *) GREEN="NO" ;; esac

# === Write the single-line snapshot cache (the deliverable) ===
printf 'session=%s ts=%s green=%s hh=%s ie=%s pc=%s urgent_lines=%s unattested=%s up_delta_hr=%s qa_bundles=%s qa_delta_hr=%s qg_open=%s\n' \
  "$SID" "$TS" "$GREEN" "$HH" "$IE" "$PC" "$URGENT_LINES" "$UNATTESTED" "$UP_DELTA_HR" "$QA_BUNDLES" "$QA_DELTA_HR" "$QG_OPEN" \
  > "$CACHE" 2>/dev/null || true

echo "[$TS] idle-state-advisory: green=$GREEN hh=${HH:-?} ie=${IE:-?} pc=${PC:-?} urgent_lines=$URGENT_LINES unattested=$UNATTESTED qa_bundles=$QA_BUNDLES session=$SID event=$EVENT" >> "$HOOK_LOG" 2>/dev/null || true

# === Emit at most one plain-stderr advisory line when green=NO (once per hour
# bucket). No stdout JSON — upstream sub-hooks own the detailed reminders. ===
if [ "$GREEN" = "NO" ] && [ ! -f "$MARKER" ]; then
  echo "[idle-state-advisory] green=NO (hh=${HH:-?} ie=${IE:-?} pc=${PC:-?} urgent_lines=$URGENT_LINES unattested=$UNATTESTED) — see upstream harness-health / idle-escape / phase-coherence reminders" >&2
fi
touch "$MARKER" 2>/dev/null || true

exit 0
