#!/usr/bin/env bash
# severity-classifier.sh — Phase A of unified severity/escalation system (D-058+L-S310-1+proposal §2 Layer 2)
#
# Stop hook (late chain — after lesson-synthesis-watchdog). Scans across artifact types
# and emits `agent-workspace/memory/.severity-state.tsv` with normalized severity rows.
#
# Severity schema (per agent-workspace/constitution/severity-schema.md):
#   CRITICAL — block autonomous mode immediately
#   HIGH     — escalate to AskUserQuestion at 6h pending
#   MEDIUM   — digest after 168h
#   LOW      — log only
#
# Bash + POSIX only per L-S11-1. Best-effort: never fails Stop chain on its own errors (RC=0).

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
STATE_FILE="$MEM_DIR/.severity-state.tsv"
LOG="$MEM_DIR/.severity-classifier.log"
QA_DIR="$PROJECT_DIR/human-workspace/q-and-a/pending"
DECISIONS_DIR="$MEM_DIR/decisions"
MISTAKE_LOG="$MEM_DIR/mistake-log.md"
URGENT="$PROJECT_DIR/human-workspace/notifications/urgent.md"

TS="$(date -Iseconds)"
NOW_EPOCH="$(date +%s 2>/dev/null || echo 0)"

mkdir -p "$MEM_DIR" "$(dirname "$LOG")"

# Atomic state-file rewrite: write to temp + rename (NEVER append; classifier is full re-scan).
TMP="$STATE_FILE.tmp.$$"

# Header
{
  printf '# severity-state.tsv — generated %s by severity-classifier.sh\n' "$TS"
  printf '# columns: severity\\tartifact_path\\tage_hours\\tnext_action\\tclassified_at\n'
  printf '# severity: CRITICAL | HIGH | MEDIUM | LOW\n'
  printf '# next_action: BLOCK | ESCALATE-ASKUSERQUESTION | DIGEST | LOG-ONLY\n'
} > "$TMP"

# Helper: age in hours from file mtime
age_hours() {
  local f="$1"
  local mt
  mt=$(stat -c %Y "$f" 2>/dev/null || echo 0)
  echo $(( (NOW_EPOCH - mt) / 3600 ))
}

emit_row() {
  local sev="$1" path="$2" age="$3" action="$4"
  printf '%s\t%s\t%s\t%s\t%s\n' "$sev" "$path" "$age" "$action" "$TS" >> "$TMP"
}

# === Layer 1: CRITICAL — stale-checkpoint marker, charter violation markers ===
# NOTE: .autonomous-BLOCKED is deliberately NOT in this list. It is escalation
# OUTPUT (written by escalation-engine.sh when CRITICAL rows exist), not input.
# Including it created a self-perpetuating deadlock: flag present -> CRITICAL row
# -> escalation-engine re-writes flag -> never clears. Mirrors the urgent.md
# self-loop guard in Layer 5.
CRIT_MARKERS=(
  "$MEM_DIR/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
  "$MEM_DIR/.charter-violation-detected"
  "$MEM_DIR/.ghost-greening-confirmed"
)
for m in "${CRIT_MARKERS[@]}"; do
  [ -f "$m" ] || continue
  rel="${m#$PROJECT_DIR/}"
  age=$(age_hours "$m")
  emit_row "CRITICAL" "$rel" "$age" "BLOCK"
done

# === Layer 2: Q&A pending bundles → HIGH at 6h pending, CRITICAL at 96h ===
if [ -d "$QA_DIR" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -f "$f" ] || continue
    # Skip if status is answered/closed/resolved (per HH-E.2 auto-mv rule)
    status_line=$(head -20 "$f" 2>/dev/null | grep -m1 '^status:' || true)
    case "$status_line" in
      *answered-*|*closed-*|*resolved-*) continue ;;
    esac
    rel="${f#$PROJECT_DIR/}"
    age=$(age_hours "$f")
    if [ "$age" -ge 96 ]; then
      emit_row "CRITICAL" "$rel" "$age" "BLOCK"
    elif [ "$age" -ge 6 ]; then
      emit_row "HIGH" "$rel" "$age" "ESCALATE-ASKUSERQUESTION"
    else
      emit_row "LOW" "$rel" "$age" "LOG-ONLY"
    fi
  done < <(find "$QA_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort)
fi

# === Layer 3: Decisions PROPOSED with expired cool-down → HIGH (if charter-tier) / MEDIUM (other) ===
if [ -d "$DECISIONS_DIR" ]; then
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    [ -f "$d" ] || continue
    # Skip templates / README / index files (NOT real decisions)
    base=$(basename "$d")
    case "$base" in
      _template.md|README.md|TEMPLATE.md|index.md) continue ;;
    esac
    status_line=$(head -30 "$d" 2>/dev/null | grep -m1 '^status:' || true)
    case "$status_line" in
      *PROPOSED*) ;;
      *) continue ;;
    esac
    level_line=$(head -30 "$d" 2>/dev/null | grep -m1 '^level:' || true)
    rel="${d#$PROJECT_DIR/}"
    age=$(age_hours "$d")
    # Cool-down: charter-tier 24h, scope/arch 12h, impl 0h
    case "$level_line" in
      *CHARTER*)
        cd_h=24
        sev_if_expired="HIGH"
        ;;
      *SCOPE*|*ARCH*)
        cd_h=12
        sev_if_expired="MEDIUM"
        ;;
      *)
        cd_h=0
        sev_if_expired="LOW"
        ;;
    esac
    if [ "$age" -ge "$cd_h" ]; then
      action="ESCALATE-ASKUSERQUESTION"
      [ "$sev_if_expired" = "MEDIUM" ] && action="DIGEST"
      [ "$sev_if_expired" = "LOW" ] && action="LOG-ONLY"
      emit_row "$sev_if_expired" "$rel" "$age" "$action"
    fi
  done < <(find "$DECISIONS_DIR" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort)
fi

# === Layer 4: Mistake log severity scan (last 30 lines for recent unresolved) ===
# Filter logic: emit only when there's an unresolved NEW high/critical mistake.
# Exclude "resolved", "carryover" (knowingly tracked-not-stale), "SHIPPED" (fix landed).
if [ -f "$MISTAKE_LOG" ]; then
  # pipefail + while-read-EOF returns RC=1; wrap in subshell with || true to prevent trap ERR exit
  ( tail -50 "$MISTAKE_LOG" 2>/dev/null \
    | grep -E "Severity (critical|high)" 2>/dev/null \
    | grep -v -E "resolved|carryover|SHIPPED|FIX-SHIPPED|RETRO-DISCOVERED" 2>/dev/null \
    | head -5 \
    | while IFS= read -r line; do
        case "$line" in
          *critical*) emit_row "CRITICAL" "agent-workspace/memory/mistake-log.md" "0" "BLOCK" ;;
          *high*)     emit_row "HIGH"     "agent-workspace/memory/mistake-log.md" "0" "ESCALATE-ASKUSERQUESTION" ;;
        esac
      done
  ) || true
fi

# === Layer 5: Notifications severity scan (last 24h via mtime) ===
# Classification is driven by the frontmatter `level:` field — the authoritative
# self-declared severity (notifications are named N-<TS>-<level>-<slug>.md per
# human-workspace/CLAUDE.md). Body-text keyword grep is FALLBACK ONLY, for legacy
# notifications with no `level:` field.
# Why: the old body-grep-first logic mis-escalated any notification that merely
# MENTIONED the word "critical" (e.g. an ALERT file *describing* a critical
# finding) to CRITICAL severity → false autonomous-mode block.
if [ -d "$PROJECT_DIR/human-workspace/notifications" ]; then
  while IFS= read -r n; do
    [ -z "$n" ] && continue
    [ -f "$n" ] || continue
    # Skip urgent.md + digest files (these are escalation OUTPUTS, not inputs — avoid self-loop)
    base=$(basename "$n")
    case "$base" in
      urgent.md|urgent-archived-*.md|digest-*.md) continue ;;
    esac
    # Skip notifications already resolved/answered/deferred (frontmatter status)
    nstatus=$(head -10 "$n" 2>/dev/null | grep -m1 '^status:' || true)
    case "$nstatus" in
      *ANSWERED*|*RESOLVED*|*DEFERRED*|*answered-*|*resolved-*|*deferred-*) continue ;;
    esac
    rel="${n#$PROJECT_DIR/}"
    age=$(age_hours "$n")
    [ "$age" -le 24 ] || continue
    # Authoritative: frontmatter `level:` field (strip whitespace incl. CR for CRLF files).
    nlevel=$(head -10 "$n" 2>/dev/null | grep -m1 '^level:' | sed 's/^level:[[:space:]]*//' | tr -d '[:space:]' || true)
    case "$nlevel" in
      CRITICAL|critical|Critical)
        emit_row "CRITICAL" "$rel" "$age" "BLOCK" ;;
      ALERT|alert|Alert|URGENT|urgent|Urgent)
        emit_row "HIGH" "$rel" "$age" "ESCALATE-ASKUSERQUESTION" ;;
      WARN|warn|Warn|WARNING|warning|Warning)
        emit_row "MEDIUM" "$rel" "$age" "DIGEST" ;;
      INFO|info|Info|SUMMARY|summary|Summary)
        emit_row "LOW" "$rel" "$age" "LOG-ONLY" ;;
      *)
        # No recognized `level:` frontmatter — fall back to body keyword scan (legacy).
        if grep -q "CRITICAL\|critical" "$n" 2>/dev/null; then
          emit_row "CRITICAL" "$rel" "$age" "BLOCK"
        elif grep -q "ALERT\|alert\|URGENT" "$n" 2>/dev/null; then
          emit_row "HIGH" "$rel" "$age" "ESCALATE-ASKUSERQUESTION"
        elif grep -q "WARN\|warn" "$n" 2>/dev/null; then
          emit_row "MEDIUM" "$rel" "$age" "DIGEST"
        else
          emit_row "LOW" "$rel" "$age" "LOG-ONLY"
        fi
        ;;
    esac
  done < <(find "$PROJECT_DIR/human-workspace/notifications" -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort)
fi

# Atomic install
mv -f "$TMP" "$STATE_FILE" 2>/dev/null || { rm -f "$TMP"; exit 0; }

# Summary log
CRIT_N=$( { grep "^CRITICAL" "$STATE_FILE" 2>/dev/null || true; } | wc -l | tr -d ' \n')
HIGH_N=$( { grep "^HIGH" "$STATE_FILE" 2>/dev/null || true; } | wc -l | tr -d ' \n')
MED_N=$( { grep "^MEDIUM" "$STATE_FILE" 2>/dev/null || true; } | wc -l | tr -d ' \n')
LOW_N=$( { grep "^LOW" "$STATE_FILE" 2>/dev/null || true; } | wc -l | tr -d ' \n')
[ -z "$CRIT_N" ] && CRIT_N=0
[ -z "$HIGH_N" ] && HIGH_N=0
[ -z "$MED_N" ] && MED_N=0
[ -z "$LOW_N" ] && LOW_N=0
printf '[%s] severity-classifier: CRITICAL=%s HIGH=%s MEDIUM=%s LOW=%s\n' "$TS" "$CRIT_N" "$HIGH_N" "$MED_N" "$LOW_N" >> "$LOG"

# Stderr alert if CRITICAL or HIGH
if [ "$CRIT_N" -gt 0 ] || [ "$HIGH_N" -gt 0 ]; then
  echo "severity-classifier: CRITICAL=$CRIT_N HIGH=$HIGH_N — escalation-engine.sh will act" >&2
fi

exit 0
