#!/usr/bin/env bash
# path-safety-check.sh — 5-invariant path-safety enforcement for StockForge production code.
#
# Ported from Vibe-Trading (HKUDS/Vibe-Trading, MIT-licensed, 2026).
# Upstream: agent/src/tools/path_utils.py:1-213 (4 helpers + _rejects_unc cross-cutting guard)
# Source: agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md § 0
# ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
#
# Enforces 5 path-safety invariants in packages/**/*.py + apps/**/*.py:
#   P1 (Sandbox)      — '..' traversal in Path()/os.path.join()/open() args  → ERR
#   P1b (Domain-abs)  — absolute path literals in packages/domain/**  → ERR
#   P2/P3 (User/Doc)  — Path(sys.argv[N]) or Path(os.environ.get()) without safe_*_path()  → WARN
#   P4 (Write-zone)   — write_text/write_bytes/open('w'/'a') to non-allowed zones  → WARN
#   P5 (UNC)          — '\\' or '//' UNC prefix in path literals  → ERR
#
# Cross-cutting: P5 (_rejects_unc) fires FIRST in each public helper;
# this hook checks P5 independently as a static-analysis pattern.
# Fix recipe: packages/_shared/path_safety.py (safe_path / safe_user_path /
# safe_document_path / safe_run_dir helpers).
#
# Severity: violations land in .session-hooks.log as severity=HIGH (ERR) / severity=MEDIUM (WARN).
#
# Event targets:
#   PostToolUse (Edit|Write|MultiEdit on *.py in packages/ or apps/) — scans single file
#   Stop — full tree audit of packages/**/*.py + apps/**/*.py
#
# Best-effort: RC=0 always; never blocks Stop chain.
# Idempotency: hour-bucket marker per file under agent-workspace/memory/.psafety-marker-*
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
PY_HELPER="$(mktemp /tmp/ps_check_XXXXXX.py 2>/dev/null || echo "/tmp/ps_check_$$.py")"
cat > "$PY_HELPER" << 'EOF'
#!/usr/bin/env python3
"""path-safety detector helper — checks 5 path-safety invariants."""
import sys
import re

def main():
    if len(sys.argv) < 3:
        print("0 0 0 0 0")
        return

    path = sys.argv[1]
    is_domain = sys.argv[2] == "1"

    try:
        with open(path, 'r', encoding='utf-8', errors='replace') as fh:
            lines = fh.readlines()
    except Exception:
        print("0 0 0 0 0")
        return

    # P1: '..' traversal in path expressions
    p1_re = re.compile(r'(?:Path|os\.path\.join|open)\([^)]*\.\.[^)]*\)')

    # P1b: absolute path literals in domain layer
    # Matches Path('/...'), Path('C:\\...'), Path('C:/...')
    p1b_re = re.compile(r'Path\([\'"](?:/|[A-Za-z]:[/\\])')

    # P2/P3: user-supplied path from sys.argv or os.environ.get without safe_*_path
    p23_src_re = re.compile(r'(?:Path|open)\s*\(\s*(?:sys\.argv|os\.environ\.get)')
    safe_wrap_re = re.compile(r'safe_(?:path|user_path|document_path|run_dir)\s*\(')

    # P4: write to path not in allowed zones
    write_re = re.compile(r'(?:\.write_text|\.write_bytes)\s*\(|open\s*\([^)]*[\'"](?:w|a|wb|ab)[\'"]')
    allowed_zone_re = re.compile(r'(?:outputs|logs|state|cache|data|agent-workspace/memory|human-workspace|agent_workspace|human_workspace)/')

    # P5: UNC path prefix in string literals
    # Matches '\\\\...' or '//...' at start of path string inside Path() or open()
    p5_re = re.compile(r'(?:Path|open)\s*\([\'"](?:\\\\\\\\|//[a-zA-Z])')

    p1 = p1b = p23 = p4 = p5 = 0

    for i, line in enumerate(lines):
        stripped = line.rstrip()

        # Skip comment lines
        if stripped.lstrip().startswith('#'):
            continue
        # Skip inline path-safety-ok marker
        if '# path-safety-ok:' in stripped:
            continue

        # P5 (UNC) — highest priority, check first
        if p5_re.search(stripped):
            p5 += 1
            continue

        # P1: '..' traversal
        if p1_re.search(stripped):
            p1 += 1
            continue

        # P1b: absolute path literal in domain layer
        if is_domain and p1b_re.search(stripped):
            p1b += 1
            continue

        # P2/P3: user-supplied path from untrusted source
        if p23_src_re.search(stripped):
            # Check if wrapped by a safe_*_path helper (preceding 10 lines)
            context = lines[max(0, i-10):i+1]
            if not any(safe_wrap_re.search(cl) for cl in context):
                p23 += 1
            continue

        # P4: write to non-allowed zone
        if write_re.search(stripped):
            if not allowed_zone_re.search(stripped):
                p4 += 1

    print(f"{p1} {p1b} {p23} {p4} {p5}")

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
  printf '[%s] path-safety-check %s severity=%s file=%s detail=%s\n' \
    "$TS" "$rule" "$sev" "$file" "$detail" >> "$LOG"
}

file_marker_path() {
  local f="$1"
  local safe
  safe="$(printf '%s' "$f" | tr '/' '-' | tr '\\' '-' | tr ':' '_')"
  local HOUR_BUCKET
  HOUR_BUCKET="$(date '+%Y%m%d-%H' 2>/dev/null || echo unknown)"
  echo "$MEM_DIR/.psafety-marker-${safe}-${HOUR_BUCKET}"
}

claim_file_slot() {
  local marker="$1"
  find "$MEM_DIR" -maxdepth 1 -name '.psafety-marker-*' -mmin +120 -delete 2>/dev/null || true
  if ( set -o noclobber; printf '%s\n' "$TS" > "$marker" ) 2>/dev/null; then
    return 0
  else
    return 1
  fi
}

# ============================================================
# Detect scan mode from PostToolUse stdin or Stop event
# Stdin must be read BEFORE any Python helper usage.
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

# Full tree audit for Stop mode
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
  local rel_basename
  rel_basename="$(basename "$rel_path")"

  # Allow-list: test files (by filename, not directory name)
  case "$rel_basename" in
    test_*.py|*_test.py) return ;;
  esac
  # Allow-list: tests/ subdirectory
  case "$rel_path" in
    */tests/*) return ;;
  esac

  # Allow-list: scripts/ dev tooling
  case "$rel_path" in
    scripts/*) return ;;
  esac

  # Allow-list: examples/ docs/
  case "$rel_path" in
    examples/*|docs/*) return ;;
  esac

  # Allow-list: firing-tests
  case "$f" in
    */firing-tests/*) return ;;
  esac

  # Allow-list: the path_safety.py helper itself
  case "$rel_basename" in
    path_safety.py) return ;;
  esac

  # Determine if this is the domain layer (strictest — P1b fires here)
  local is_domain=0
  case "$rel_path" in
    packages/domain/*) is_domain=1 ;;
  esac

  # Run Python helper for all 5 invariants
  local result
  result="$(python3 "$PY_HELPER" "$f" "$is_domain" 2>/dev/null || echo "0 0 0 0 0")"

  local p1 p1b p23 p4 p5
  read -r p1 p1b p23 p4 p5 <<< "$result"
  p1="${p1:-0}"; p1b="${p1b:-0}"; p23="${p23:-0}"; p4="${p4:-0}"; p5="${p5:-0}"

  if [ "$p5" -gt 0 ] 2>/dev/null; then
    emit_violation "P5-UNC" "ERR" "$rel_path" \
      "UNC path prefix (${p5} occurrence(s)) — use safe_path/safe_user_path; add # path-safety-ok: if intentional"
  fi
  if [ "$p1" -gt 0 ] 2>/dev/null; then
    emit_violation "P1-TRAVERSAL" "ERR" "$rel_path" \
      "'..' traversal in path expression (${p1} occurrence(s)) — use safe_path(p, workdir) from packages/_shared/path_safety.py"
  fi
  if [ "$p1b" -gt 0 ] 2>/dev/null; then
    emit_violation "P1b-DOMAIN-ABS" "ERR" "$rel_path" \
      "absolute path literal in domain layer (${p1b} occurrence(s)) — domain must be pure; no filesystem literals"
  fi
  if [ "$p23" -gt 0 ] 2>/dev/null; then
    emit_violation "P2P3-UNSANITIZED" "WARN" "$rel_path" \
      "user-supplied path from sys.argv/os.environ without safe_*_path wrapper (${p23} occurrence(s)) — wrap with safe_user_path or safe_document_path"
  fi
  if [ "$p4" -gt 0 ] 2>/dev/null; then
    emit_violation "P4-WRITE-ZONE" "WARN" "$rel_path" \
      "write operation outside allowed zone (${p4} occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones"
  fi
}

for f in "${SCAN_FILES[@]}"; do
  scan_file "$f"
done

# ============================================================
# Emit summary
# ============================================================
if [ "$VIOLATIONS" -gt 0 ]; then
  printf '[%s] path-safety-check: %d violation(s) (P1/P1b/P2P3/P4/P5)\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"

  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/path-safety-warn.md"
  {
    printf '%s\n' '---' 'status: pending' '---' ''
    printf '# path-safety-check %s\n\n' '— ALERT'
    printf 'Path safety violations detected: %d\n\n' "$VIOLATIONS"
    printf '%s' "$VIOLATION_LIST"
    printf '\n## Fix guidance\n'
    printf '%s\n' '- P1/P1b: Use safe_path(p, workdir) from packages/_shared/path_safety.py'
    printf '%s\n' '- P2/P3: Wrap user-supplied paths with safe_user_path() or safe_document_path()'
    printf '%s\n' '- P4: Write to allowed zones (outputs/, logs/, state/, cache/, data/, memory/)'
    printf '%s\n' '- P5: Use safe_path/safe_user_path (UNC reject is cross-cutting); add # path-safety-ok: if intentional'
    printf '\nSee ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md\n'
    printf 'Helpers: packages/_shared/path_safety.py\n'
    printf 'Source: Vibe-Trading agent/src/tools/path_utils.py:1-213 (MIT 2026)\n'
  } > "$NOTIF_FILE" 2>/dev/null || true
else
  printf '[%s] path-safety-check: OK (0 violations across %d file(s))\n' \
    "$TS" "${#SCAN_FILES[@]}" >> "$LOG"
fi

exit 0
