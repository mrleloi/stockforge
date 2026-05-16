#!/usr/bin/env bash
# atomic-write-check.sh — Banned-pattern enforcement for atomic temp-file-replace doctrine.
#
# Ported from TradingAgents v0.2.4 (Tauric Research, Apache-2.0).
# Upstream: tradingagents/agents/utils/memory.py:109-217 (atomic idiom: tmp_path.write_text → tmp_path.replace)
# Source: agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md § 0
# ADR: agent-workspace/memory/decisions/062-atomic-write-doctrine.md
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
#
# Bans 4 non-atomic write patterns in packages/**/*.py + apps/**/*.py:
#   AW-R1  open(path, 'w'/'a'/'wb'/'ab') + .write() without sibling os.replace  → ERR
#   AW-R2  Path(...).write_text/write_bytes on audited-extension paths without .tmp  → ERR
#   AW-R3  json.dump/pickle.dump(obj, open(path, 'w')) combined anti-pattern  → ERR
#   AW-R4  .write_text( on persistence-zone paths outside audited extensions  → WARN
#
# Severity: violations land in .session-hooks.log as severity=HIGH (ERR) / severity=MEDIUM (WARN).
# Consumed by severity-classifier.sh per severity-schema.md Layer 4.
#
# Event targets:
#   PostToolUse (Edit|Write|MultiEdit on *.py) — scans single edited file
#   Stop — full tree audit of packages/**/*.py + apps/**/*.py
#
# Best-effort: RC=0 always; never blocks Stop chain.
# Idempotency: hour-bucket marker per file under agent-workspace/memory/.aw-marker-*
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

# ============================================================
# Write Python detection helper to a temp file (avoids stdin conflict)
# ============================================================
PY_HELPER="$(mktemp /tmp/aw_check_XXXXXX.py 2>/dev/null || echo "/tmp/aw_check_$$.py")"
cat > "$PY_HELPER" << 'EOF'
#!/usr/bin/env python3
"""atomic-write detector helper — reads Python source, checks for 4 banned patterns."""
import sys
import re

def main():
    if len(sys.argv) < 2:
        print("0 0 0 0")
        return

    path = sys.argv[1]
    try:
        with open(path, 'r', encoding='utf-8', errors='replace') as fh:
            lines = fh.readlines()
    except Exception:
        print("0 0 0 0")
        return

    audited_ext_re = re.compile(r'\.(json|jsonl|tsv|tsvl|md|log|csv)[\'"]')
    persistence_re = re.compile(r'/(outputs|logs|state|cache|data)/')
    write_text_re = re.compile(r'\.(write_text|write_bytes)\(')
    open_write_re = re.compile(r'open\([^)]*["\'](?:w|a|wb|ab)["\']')
    replace_re = re.compile(r'(?:os\.replace|os\.rename|\.replace\()')
    main_re = re.compile(r'if\s+__name__\s*==\s*["\']__main__["\']')
    dump_re = re.compile(r'(?:json|pickle)\.dump\([^,]+,\s*open\(')

    r1 = r2 = r3 = r4 = 0
    in_main = False

    for i, line in enumerate(lines):
        stripped = line.rstrip()

        # Track __main__ block
        if main_re.search(stripped):
            in_main = True
        elif in_main and stripped and not stripped[0].isspace():
            in_main = False

        if in_main:
            continue
        if stripped.lstrip().startswith('#'):
            continue
        if '# atomic-write-ok:' in stripped:
            continue

        # R3: json/pickle.dump combined with open()
        if dump_re.search(stripped):
            r3 += 1
            continue

        # R1: open() with write mode without atomic replace
        if open_write_re.search(stripped) and '.tmp' not in stripped:
            has_replace = any(replace_re.search(lines[j]) for j in range(i, min(i+11, len(lines))))
            if not has_replace:
                r1 += 1
            continue

        # R2: write_text/write_bytes on audited extension without .tmp
        if write_text_re.search(stripped) and '.tmp' not in stripped:
            if audited_ext_re.search(stripped):
                r2 += 1
                continue
            # R4: write_text/write_bytes in persistence zone (non-audited ext)
            if persistence_re.search(stripped):
                r4 += 1

    print(f"{r1} {r2} {r3} {r4}")

main()
EOF

cleanup_helper() {
  rm -f "$PY_HELPER"
  exit 0
}
trap cleanup_helper EXIT

# ============================================================
# Helpers
# ============================================================

emit_violation() {
  local rule="$1" sev="$2" file="$3" detail="$4"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${rule} [${sev}]: ${file} — ${detail}"$'\n'
  printf '[%s] atomic-write-check %s severity=%s file=%s detail=%s\n' \
    "$TS" "$rule" "$sev" "$file" "$detail" >> "$LOG"
}

# Hour-bucket marker to avoid re-scanning same file within same hour.
file_marker_path() {
  local f="$1"
  local safe
  safe="$(printf '%s' "$f" | tr '/' '-' | tr '\\' '-' | tr ':' '_')"
  local HOUR_BUCKET
  HOUR_BUCKET="$(date '+%Y%m%d-%H' 2>/dev/null || echo unknown)"
  echo "$MEM_DIR/.aw-marker-${safe}-${HOUR_BUCKET}"
}

claim_file_slot() {
  local marker="$1"
  # D1 S346 plan-023: find-delete REMOVED from claim_file_slot() body.
  # Hoisted to pre-scan block below (runs ONCE per hook invocation, not once per file).
  # Atomic noclobber claim (L-S289-1 compliance)
  if ( set -o noclobber; printf '%s\n' "$TS" > "$marker" ) 2>/dev/null; then
    return 0   # we won the slot
  else
    return 1   # already claimed this hour
  fi
}

# ============================================================
# Detect scan mode from PostToolUse stdin or Stop event
# Stdin must be read BEFORE any heredoc usage to avoid stdin conflict.
# ============================================================

STDIN_PAYLOAD="$(cat 2>/dev/null || true)"

SCAN_FILES=()

if [ -n "$STDIN_PAYLOAD" ]; then
  EDITED_FILE="$(printf '%s' "$STDIN_PAYLOAD" \
    | grep -oE '"(file_path|new_path|path)"[[:space:]]*:[[:space:]]*"[^"]*\.py"' \
    | head -1 \
    | sed 's/.*:[[:space:]]*"\(.*\)"/\1/' 2>/dev/null || true)"

  if [ -n "$EDITED_FILE" ]; then
    case "$EDITED_FILE" in
      /*) ;;
      *)  EDITED_FILE="$PROJECT_DIR/$EDITED_FILE" ;;
    esac
    case "$EDITED_FILE" in
      */packages/*|*/apps/*) SCAN_FILES+=("$EDITED_FILE") ;;
    esac
  fi
fi

# === D1: Hoisted marker cleanup (S346 plan-023 P1) — runs ONCE per hook invocation
# instead of ONCE per scanned file (was inside claim_file_slot body).
# Root cause: with 364 files × 1289 entries = ~469K dir entry checks per Stop event.
# Hoisting reduces to 1289 entries × 1 invocation. ~50s → ~1-2s per hook.
# Observation 2026-05-16: agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md
find "$MEM_DIR" -maxdepth 1 -name '.aw-marker-*' -mmin +120 -delete 2>/dev/null || true

# === D2: Stop-mode cool-down (S346 plan-023 P2) — early-exit if last full sweep ≤ 600s ago.
# Only applies in Stop-mode (SCAN_FILES empty from stdin AND no EDITED_FILE from JSON parse).
# PostToolUse single-file audits are unaffected (SCAN_FILES already populated from EDITED_FILE).
# AQ-7: PostToolUse path remains active for per-file violations; cool-down only suppresses
# the redundant full-tree Stop sweep within the 10-min autonomous-mode burst window.
AW_COOLDOWN_MARKER="$MEM_DIR/.aw-last-full-sweep"
AW_COOLDOWN_S=600
if [ -z "${EDITED_FILE:-}" ] && [ "${#SCAN_FILES[@]}" -eq 0 ] && [ -f "$AW_COOLDOWN_MARKER" ]; then
  _age_s=$(( $(date +%s) - $(stat -c %Y "$AW_COOLDOWN_MARKER" 2>/dev/null || stat -f %m "$AW_COOLDOWN_MARKER" 2>/dev/null || echo 0) ))
  if [ "$_age_s" -lt "$AW_COOLDOWN_S" ]; then
    printf '[%s] atomic-write-check: SKIP-COOLDOWN (last full sweep %ds ago, threshold %ds)\n' \
      "$TS" "$_age_s" "$AW_COOLDOWN_S" >> "$LOG"
    exit 0
  fi
fi

# If no files from stdin (Stop mode or no edited .py found), run full tree audit
if [ "${#SCAN_FILES[@]}" -eq 0 ]; then
  for search_dir in "$PROJECT_DIR/packages" "$PROJECT_DIR/apps"; do
    [ -d "$search_dir" ] || continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      SCAN_FILES+=("$f")
    done < <(find "$search_dir" -name '*.py' -type f 2>/dev/null | sort)
  done
fi

# ============================================================
# Scan each file for banned write patterns
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
  local rel_basename
  rel_basename="$(basename "$rel_path")"

  # Allow-list: test files (match filename only, not directories named test_*)
  case "$rel_basename" in
    test_*.py|*_test.py) return ;;
  esac
  # Also allow-list: files inside tests/ subdirectory
  case "$rel_path" in
    */tests/*) return ;;
  esac

  # Allow-list: scripts/ (dev tooling)
  case "$rel_path" in
    scripts/*) return ;;
  esac

  # Allow-list: examples/ docs/
  case "$rel_path" in
    examples/*|docs/*) return ;;
  esac

  # Allow-list: firing-tests directory
  case "$f" in
    */firing-tests/*) return ;;
  esac

  # Run Python helper to detect all 4 rules at once (avoids stdin conflict)
  local result
  result="$(python3 "$PY_HELPER" "$f" 2>/dev/null || echo "0 0 0 0")"

  local r1 r2 r3 r4
  read -r r1 r2 r3 r4 <<< "$result"
  r1="${r1:-0}"; r2="${r2:-0}"; r3="${r3:-0}"; r4="${r4:-0}"

  if [ "$r1" -gt 0 ] 2>/dev/null; then
    emit_violation "AW-R1" "ERR" "$rel_path" \
      "open() with write mode (${r1} occurrence(s)) without atomic os.replace — use tmp_path.write_text + tmp_path.replace(path)"
  fi
  if [ "$r2" -gt 0 ] 2>/dev/null; then
    emit_violation "AW-R2" "ERR" "$rel_path" \
      "write_text/write_bytes on audited extension (${r2} occurrence(s)) without .tmp suffix — use tmp=path.with_suffix('.tmp'); tmp.write_text(...); tmp.replace(path)"
  fi
  if [ "$r3" -gt 0 ] 2>/dev/null; then
    emit_violation "AW-R3" "ERR" "$rel_path" \
      "json/pickle.dump combined with open() (${r3} occurrence(s)) — use atomic write pattern instead"
  fi
  if [ "$r4" -gt 0 ] 2>/dev/null; then
    emit_violation "AW-R4" "WARN" "$rel_path" \
      "write_text/write_bytes in persistence zone (${r4} occurrence(s)) without .tmp — consider atomic write pattern"
  fi
}

for f in "${SCAN_FILES[@]}"; do
  scan_file "$f"
done

# ============================================================
# Emit summary
# ============================================================
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] atomic-write-check: %d violation(s) (AW-R1/R2/R3/R4)\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"

  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/atomic-write-warn.md"
  {
    printf '---\nstatus: pending\n---\n'
    printf '# atomic-write-check — ALERT\n\n'
    printf 'Atomic write violations detected: %d\n\n' "$VIOLATIONS"
    printf '%s' "$VIOLATION_LIST"
    printf '\n## Fix guidance\n'
    printf -- '- AW-R1: Replace open(path, w) + f.write(...) with tmp+replace idiom:\n'
    printf -- '    tmp = Path(path).with_suffix(Path(path).suffix + ".tmp")\n'
    printf -- '    tmp.write_text(content, encoding="utf-8")\n'
    printf -- '    tmp.replace(path)\n'
    printf -- '- AW-R2: Replace Path(path).write_text(...) on audited files with the tmp+replace idiom\n'
    printf -- '- AW-R3: Replace json.dump(obj, open(path, "w")) with atomic write\n'
    printf -- '- AW-R4: Consider atomic write for persistence-zone files\n'
    printf '\nSee ADR: agent-workspace/memory/decisions/062-atomic-write-doctrine.md\n'
    printf '\nAtomicity rationale: tmp-file + os.replace so a crash mid-write never corrupts the log.\n'
    printf '(Source: TradingAgents memory.py:109-114 docstring)\n'
  } > "$NOTIF_FILE" 2>/dev/null || true
else
  printf '[%s] atomic-write-check: OK (0 violations across %d file(s))\n' \
    "$TS" "${#SCAN_FILES[@]}" >> "$LOG"
fi

# === D2: Touch cool-down marker if this was a full-tree sweep (>100 files = Stop-mode heuristic).
# PostToolUse single-file edits pass ≤3 files → don't update the marker (preserves cool-down).
# Full-tree Stop sweep passes 300+ files → update marker to suppress next burst-cycle redundant sweep.
if [ "${#SCAN_FILES[@]}" -gt 100 ]; then
  touch "$AW_COOLDOWN_MARKER" 2>/dev/null || true
fi

exit 0
