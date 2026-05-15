#!/usr/bin/env bash
# html-separator-check.sh — Enforce HTML-comment separator pattern in append-only memory zones.
#
# Ported from TradingAgents v0.2.4 (Tauric Research, Apache-2.0).
# Upstream: tradingagents/agents/utils/memory.py:13-14 (_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n")
# Source: agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md § 0
# ADR: agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
#
# Enforces that append-only entry-segmented markdown files in StockForge memory zones
# use "\n\n<!-- ENTRY_END -->\n\n" as inter-entry separator.
#
# The HTML comment is:
#   - Forgery-proof: LLMs cannot emit HTML comments inside markdown prose (they see but
#     render swallows them). Source: TradingAgents memory.py:13 inline comment.
#   - Invisible to markdown renderers (doesn't pollute visual output).
#   - Unambiguous: exact string; no false-positive risk from prose.
#
# Detection rules:
#   HS-R1  Multi-entry audited file has 0 <!-- ENTRY_END --> markers  → ERR
#   HS-R2  File contains malformed separator (wrong case/spacing)  → ERR
#   HS-R3  File mixes <!-- ENTRY_END --> with naive ASCII separators  → WARN
#
# Audited zones (entry-segmented append-only markdown logs):
#   agent-workspace/memory/mistake-log.md
#   agent-workspace/memory/agent-notes.md
#   agent-workspace/memory/thesis-log/*.md
#   agent-workspace/memory/observations/*.md
#   agent-workspace/memory/post-mortems/*.md
#
# Excluded zones (single-document files, not entry-segmented):
#   repo root *.md, constitution/, research/, master-plans/, session-plans/,
#   memory/sessions/, memory/decisions/, memory/checkpoints/
#
# Severity: violations land in .session-hooks.log as severity=HIGH (ERR) / severity=MEDIUM (WARN).
#
# Event targets:
#   PostToolUse (Edit|Write|MultiEdit on *.md) — scans only the edited file if in audited zone
#   Stop — full audit of audited zone files
#
# Best-effort: RC=0 always; never blocks Stop chain.
# Idempotency: hour-bucket marker per file under agent-workspace/memory/.htmlsep-marker-*
#
# Phase 0 portability: bash + POSIX only. L-S11-1.
# Atomic noclobber for marker writes: L-S289-1.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

VIOLATIONS=0
VIOLATION_LIST=""

# Exact separator string (matches TradingAgents memory.py:13-14)
SEPARATOR="<!-- ENTRY_END -->"

# ============================================================
# Helpers
# ============================================================

emit_violation() {
  local rule="$1" sev="$2" file="$3" detail="$4"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${rule} [${sev}]: ${file} — ${detail}"$'\n'
  printf '[%s] html-separator-check %s severity=%s file=%s detail=%s\n' \
    "$TS" "$rule" "$sev" "$file" "$detail" >> "$LOG"
}

file_marker_path() {
  local f="$1"
  local safe
  safe="$(printf '%s' "$f" | tr '/' '-' | tr '\\' '-' | tr ':' '_')"
  local HOUR_BUCKET
  HOUR_BUCKET="$(date '+%Y%m%d-%H' 2>/dev/null || echo unknown)"
  echo "$MEM_DIR/.htmlsep-marker-${safe}-${HOUR_BUCKET}"
}

claim_file_slot() {
  local marker="$1"
  find "$MEM_DIR" -maxdepth 1 -name '.htmlsep-marker-*' -mmin +120 -delete 2>/dev/null || true
  if ( set -o noclobber; printf '%s\n' "$TS" > "$marker" ) 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

# Check if a markdown file is in the audited zone
is_audited_zone() {
  local f="$1"
  local rel="${f#$PROJECT_DIR/}"
  case "$rel" in
    agent-workspace/memory/mistake-log.md) return 0 ;;
    agent-workspace/memory/agent-notes.md) return 0 ;;
    agent-workspace/memory/thesis-log/*.md) return 0 ;;
    agent-workspace/memory/observations/*.md) return 0 ;;
    agent-workspace/memory/post-mortems/*.md) return 0 ;;
  esac
  return 1
}

# ============================================================
# Detect scan mode
# ============================================================

STDIN_PAYLOAD="$(cat 2>/dev/null || true)"

SCAN_FILES=()

if [ -n "$STDIN_PAYLOAD" ]; then
  EDITED_FILE="$(printf '%s' "$STDIN_PAYLOAD" \
    | grep -oE '"(file_path|new_path|path)"[[:space:]]*:[[:space:]]*"[^"]*\.md"' \
    | head -1 \
    | sed 's/.*:[[:space:]]*"\(.*\)"/\1/' 2>/dev/null || true)"

  if [ -n "$EDITED_FILE" ]; then
    case "$EDITED_FILE" in
      /*) ;;
      *)  EDITED_FILE="$PROJECT_DIR/$EDITED_FILE" ;;
    esac
    if is_audited_zone "$EDITED_FILE"; then
      SCAN_FILES+=("$EDITED_FILE")
    fi
  fi
fi

# If no files from stdin (Stop mode), run full audit of audited zones
if [ "${#SCAN_FILES[@]}" -eq 0 ]; then
  # Explicit audited files
  for explicit_file in \
    "$MEM_DIR/mistake-log.md" \
    "$MEM_DIR/agent-notes.md"; do
    [ -f "$explicit_file" ] && SCAN_FILES+=("$explicit_file")
  done

  # Glob-matched audited directories
  for glob_dir in \
    "$MEM_DIR/thesis-log" \
    "$MEM_DIR/observations" \
    "$MEM_DIR/post-mortems"; do
    [ -d "$glob_dir" ] || continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      SCAN_FILES+=("$f")
    done < <(find "$glob_dir" -maxdepth 1 -name '*.md' -type f 2>/dev/null | sort)
  done
fi

# ============================================================
# Scan each file
# ============================================================

scan_file() {
  local f="$1"
  [ -f "$f" ] || return
  [ -r "$f" ] || return

  local marker
  marker="$(file_marker_path "$f")"
  if ! claim_file_slot "$marker"; then
    return
  fi

  local rel_path="${f#$PROJECT_DIR/}"

  # Allow-list: file with frontmatter html-separator-exempt: true
  if grep -q '^html-separator-exempt:[[:space:]]*true' "$f" 2>/dev/null; then
    return
  fi
  # Allow-list: inline exemption marker in first 20 lines
  if head -20 "$f" 2>/dev/null | grep -q '<!-- atomic-md-exempt:'; then
    return
  fi

  local line_count
  line_count="$(wc -l < "$f" 2>/dev/null | tr -d '[:space:]' || echo 0)"
  local heading_count
  heading_count="$(grep -c '^#\{1,2\} ' "$f" 2>/dev/null | tr -d '[:space:]' || echo 0)"
  local separator_count
  separator_count="$(grep -cF "$SEPARATOR" "$f" 2>/dev/null | tr -d '[:space:]' || echo 0)"

  # HS-R1: Multi-entry file (≥2 headings AND ≥200 lines) with 0 separators
  if [ "$heading_count" -ge 2 ] && [ "$line_count" -ge 200 ] && [ "$separator_count" -eq 0 ]; then
    emit_violation "HS-R1" "ERR" "$rel_path" \
      "multi-entry file (${heading_count} headings, ${line_count} lines) has 0 <!-- ENTRY_END --> separators — must use HTML-comment separator pattern"
  fi

  # HS-R2: Malformed separator (wrong variant of the ENTRY_END marker)
  # Catches: <!-- ENTRY -->, <!--ENTRY_END-->, <!-- entry_end -->, etc.
  local malformed_count
  malformed_count="$(grep -ciE '<!--[[:space:]]*entry(_end)?[[:space:]]*-->' "$f" 2>/dev/null | tr -d '[:space:]' || echo 0)"
  if [ "$malformed_count" -gt 0 ]; then
    # Subtract the correct separator occurrences
    local correct_count="$separator_count"
    local bad_count=$(( malformed_count - correct_count ))
    if [ "$bad_count" -gt 0 ]; then
      emit_violation "HS-R2" "ERR" "$rel_path" \
        "malformed separator found (${bad_count} occurrence(s)) — use exact string: <!-- ENTRY_END --> (with spaces)"
    fi
  fi

  # HS-R3: Mix of <!-- ENTRY_END --> and naive ASCII separators like ^---$ between entries
  if [ "$separator_count" -gt 0 ]; then
    local naive_sep_count
    naive_sep_count="$(grep -cE '^(---|\*\*\*|===+)$' "$f" 2>/dev/null | tr -d '[:space:]' || echo 0)"
    if [ "$naive_sep_count" -gt 0 ]; then
      emit_violation "HS-R3" "WARN" "$rel_path" \
        "separator drift: file mixes <!-- ENTRY_END --> (${separator_count}) with naive ASCII separators (${naive_sep_count}) — standardize on <!-- ENTRY_END -->"
    fi
  fi
}

for f in "${SCAN_FILES[@]}"; do
  scan_file "$f"
done

# ============================================================
# Emit summary
# ============================================================
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] html-separator-check: %d violation(s) (HS-R1/R2/R3)\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"

  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/html-separator-warn.md"
  {
    printf '%s\n' '---' 'status: pending' '---' ''
    printf '# html-separator-check %s\n\n' '— ALERT'
    printf 'HTML separator violations detected: %d\n\n' "$VIOLATIONS"
    printf '%s' "$VIOLATION_LIST"
    printf '\n## Fix guidance\n'
    printf '%s\n' '- HS-R1: Add "<!-- ENTRY_END -->" separator between entries in append-only memory files'
    printf '%s\n' '  Exact format: two blank lines, then <!-- ENTRY_END -->, then two blank lines'
    printf '%s\n' '- HS-R2: Fix malformed separator: must be exactly <!-- ENTRY_END --> (with spaces)'
    printf '%s\n' '- HS-R3: Remove naive ASCII separators (---/***) between entries; use <!-- ENTRY_END -->'
    printf '\nSee ADR: agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md\n'
    printf '\nRationale: HTML comments are forgery-proof (LLM prose cannot emit them) and\n'
    printf 'invisible to markdown renderers. Source: TradingAgents memory.py:13-14.\n'
  } > "$NOTIF_FILE" 2>/dev/null || true
else
  printf '[%s] html-separator-check: OK (0 violations across %d file(s))\n' \
    "$TS" "${#SCAN_FILES[@]}" >> "$LOG"
fi

exit 0
