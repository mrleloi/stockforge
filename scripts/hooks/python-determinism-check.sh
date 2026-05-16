#!/usr/bin/env bash
# python-determinism-check.sh — DST-style banned-pattern enforcement for Python-primary stack.
#
# Ported from nautilus_trader DST doctrine (docs/concepts/dst.md:140-180, SHA dd49f70).
# Source: agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md §1.5
# Plan: agent-workspace/session-plans/pending/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md
# ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md
#
# Bans 4 non-determinism patterns in packages/**/*.py + apps/**/*.py:
#   R1  datetime.now() without timezone arg  → ERR
#   R2  random.random()/randint()/secrets.token_*() outside __main__ or test_*.py  → ERR
#   R3  Dict iteration order assumption heuristic  → WARN
#   R4  time.time() in packages/domain/**  → ERR
#
# Severity: violations land in .severity-state.tsv as HIGH (via .session-hooks.log for
# severity-classifier to consume). High severity is per severity-schema.md Layer 4.
#
# Event targets:
#   PostToolUse (Edit|Write on *.py) — scans single edited file
#   Stop — full tree audit of packages/**/*.py + apps/**/*.py
#
# Best-effort: RC=0 always; never blocks Stop chain.
# Idempotency: hour-bucket marker per file (avoid re-flagging same file multiple times per session).
#
# Phase 0 portability: bash + POSIX only. L-S11-1.
# Atomic noclobber for marker writes: L-S289-1.
# Hour-bucket marker: L-S108-1.
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
# Helpers
# ============================================================

emit_violation() {
  local rule="$1" sev="$2" file="$3" detail="$4"
  VIOLATIONS=$(( VIOLATIONS + 1 ))
  VIOLATION_LIST="${VIOLATION_LIST}  - ${rule} [${sev}]: ${file} — ${detail}"$'\n'
  printf '[%s] python-determinism-check %s severity=%s file=%s detail=%s\n' \
    "$TS" "$rule" "$sev" "$file" "$detail" >> "$LOG"
}

# Hour-bucket marker to avoid re-scanning same file within same hour.
# Uses noclobber atomic claim (L-S289-1).
file_marker_path() {
  local f="$1"
  # Convert slashes to dashes for marker filename safety
  local safe
  safe="$(printf '%s' "$f" | tr '/' '-' | tr '\\' '-' | tr ':' '_')"
  local HOUR_BUCKET
  HOUR_BUCKET="$(date '+%Y%m%d-%H' 2>/dev/null || echo unknown)"
  echo "$MEM_DIR/.pydet-marker-${safe}-${HOUR_BUCKET}"
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
# ============================================================

# Read stdin (PostToolUse payload is JSON on stdin)
STDIN_PAYLOAD="$(cat 2>/dev/null || true)"

# Determine the set of files to scan
SCAN_FILES=()

if [ -n "$STDIN_PAYLOAD" ]; then
  # PostToolUse mode — extract file_path from JSON payload using grep/sed (POSIX only)
  # Covers "file_path": "...", "new_path": "...", "path": "..."
  EDITED_FILE="$(printf '%s' "$STDIN_PAYLOAD" \
    | grep -oE '"(file_path|new_path|path)"[[:space:]]*:[[:space:]]*"[^"]*\.py"' \
    | head -1 \
    | sed 's/.*:[[:space:]]*"\(.*\)"/\1/' 2>/dev/null || true)"

  if [ -n "$EDITED_FILE" ]; then
    # Resolve relative path against PROJECT_DIR
    case "$EDITED_FILE" in
      /*) ;;
      *)  EDITED_FILE="$PROJECT_DIR/$EDITED_FILE" ;;
    esac
    # Only scan if within packages/ or apps/
    case "$EDITED_FILE" in
      */packages/*|*/apps/*) SCAN_FILES+=("$EDITED_FILE") ;;
    esac
  fi
fi

# === D1: Hoisted marker cleanup (S346 plan-023 P1) — runs ONCE per hook invocation.
# Observation 2026-05-16: agent-workspace/memory/observations/2026-05-16-stop-hook-performance-audit.md
find "$MEM_DIR" -maxdepth 1 -name '.pydet-marker-*' -mmin +120 -delete 2>/dev/null || true

# === D2: Stop-mode cool-down (S346 plan-023 P2) — early-exit if last full sweep ≤ 600s ago.
PYDET_COOLDOWN_MARKER="$MEM_DIR/.pydet-last-full-sweep"
PYDET_COOLDOWN_S=600
if [ -z "${EDITED_FILE:-}" ] && [ "${#SCAN_FILES[@]}" -eq 0 ] && [ -f "$PYDET_COOLDOWN_MARKER" ]; then
  _age_s=$(( $(date +%s) - $(stat -c %Y "$PYDET_COOLDOWN_MARKER" 2>/dev/null || stat -f %m "$PYDET_COOLDOWN_MARKER" 2>/dev/null || echo 0) ))
  if [ "$_age_s" -lt "$PYDET_COOLDOWN_S" ]; then
    printf '[%s] python-determinism-check: SKIP-COOLDOWN (last full sweep %ds ago, threshold %ds)\n' \
      "$TS" "$_age_s" "$PYDET_COOLDOWN_S" >> "$LOG"
    exit 0
  fi
fi

# If no files from stdin (Stop mode or no edited .py found), run full tree audit
if [ "${#SCAN_FILES[@]}" -eq 0 ]; then
  # Full tree scan for Stop event
  for search_dir in "$PROJECT_DIR/packages" "$PROJECT_DIR/apps"; do
    [ -d "$search_dir" ] || continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      SCAN_FILES+=("$f")
    done < <(find "$search_dir" -name '*.py' -type f 2>/dev/null | sort)
  done
fi

# ============================================================
# Scan each file for 4 banned patterns
# ============================================================

scan_file() {
  local f="$1"
  [ -f "$f" ] || return
  [ -r "$f" ] || return

  local marker
  marker="$(file_marker_path "$f")"

  # Hour-bucket idempotency — skip if already scanned this hour
  if ! claim_file_slot "$marker"; then
    return
  fi

  local rel_path="${f#$PROJECT_DIR/}"
  local is_test=0
  local is_domain=0

  # Detect test file (test_*.py or *_test.py pattern anywhere in path)
  case "$rel_path" in
    */test_*.py|*/*_test.py) is_test=1 ;;
  esac

  # Detect domain layer (packages/domain/**)
  case "$rel_path" in
    packages/domain/*) is_domain=1 ;;
  esac

  # --- R1: datetime.now() without timezone ---
  # Pattern: datetime.now( followed by ) with no argument (empty parens)
  # Allow: datetime.now(timezone.utc), datetime.now(tz=...), datetime.now(UTC), etc.
  local r1_hits
  r1_hits="$(grep -n 'datetime\.now()' "$f" 2>/dev/null \
    | grep -v '^[[:space:]]*#' \
    | wc -l | tr -d '[:space:]' || true)"
  [ -z "$r1_hits" ] && r1_hits=0
  if [ "$r1_hits" -gt 0 ]; then
    emit_violation "R1" "ERR" "$rel_path" \
      "datetime.now() without timezone ($r1_hits occurrence(s)) — use datetime.now(timezone.utc)"
  fi

  # --- R2: random.random()/randint()/secrets.token_*() outside __main__ or test files ---
  if [ "$is_test" -eq 0 ]; then
    # Check whether the matched lines are inside an `if __name__ == "__main__":` block.
    # Heuristic: scan for the patterns and then exclude lines that appear after
    # `if __name__` guard (full AST would be better but this is bash heuristic).
    # We use awk to track __main__ block context.
    local r2_hits
    r2_hits="$(awk '
BEGIN { in_main=0; hits=0 }
/if[[:space:]]+__name__[[:space:]]*==[[:space:]]*["\x27]__main__["\x27]/ { in_main=1 }
/^[^[:space:]]/ && in_main && !/if[[:space:]]+__name__/ { in_main=0 }
!in_main && /^[[:space:]]*#/ { next }
!in_main && /(random\.(random|randint|choice|shuffle|sample)\(|secrets\.token_)/ { hits++ }
END { print hits }
' "$f" 2>/dev/null || echo 0)"
    [ -z "$r2_hits" ] && r2_hits=0
    if [ "$r2_hits" -gt 0 ]; then
      emit_violation "R2" "ERR" "$rel_path" \
        "random/secrets non-determinism ($r2_hits occurrence(s)) outside __main__ block — use seeded RNG per-test fixture"
    fi
  fi

  # --- R3: Dict iteration order assumption heuristic ---
  # Pattern: list(<dict>.keys())[0], next(iter(<dict>)), or dict[0] index-like access
  # after iteration. Simple regex heuristic only (AST analysis deferred per plan out-of-scope).
  local r3_hits
  r3_hits="$(grep -n 'list([^)]*\.keys())\[[0-9]' "$f" 2>/dev/null \
    | grep -v '^[[:space:]]*#' \
    | wc -l | tr -d '[:space:]' || true)"
  [ -z "$r3_hits" ] && r3_hits=0
  if [ "$r3_hits" -gt 0 ]; then
    emit_violation "R3" "WARN" "$rel_path" \
      "dict iteration order assumption heuristic ($r3_hits occurrence(s)) — use OrderedDict if iteration order matters"
  fi

  # --- R4: time.time() in packages/domain/** ---
  if [ "$is_domain" -eq 1 ]; then
    local r4_hits
    r4_hits="$(grep -n 'time\.time()' "$f" 2>/dev/null \
      | grep -v '^[[:space:]]*#' \
      | wc -l | tr -d '[:space:]' || true)"
    [ -z "$r4_hits" ] && r4_hits=0
    if [ "$r4_hits" -gt 0 ]; then
      emit_violation "R4" "ERR" "$rel_path" \
        "time.time() in domain layer ($r4_hits occurrence(s)) — domain layer must be pure functions; no clock access"
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
  printf '[%s] python-determinism-check: %d violation(s) (R1/R2/R3/R4)\n%s' \
    "$TS" "$VIOLATIONS" "$VIOLATION_LIST" >> "$LOG"

  # Write notification for severity-classifier to pick up as MEDIUM (WARN tier).
  # S318: fixed-name idempotent notification (per-fire timestamps caused notifications/ spam). No auto-clear: dual-mode (PostToolUse single-file + Stop full-tree) + hour-bucket marker make VIOLATIONS==0 ambiguous.
  # S341 D1: content-hash dedup — only write if content changed (preserves mtime → prevents per-cycle escalation-engine re-emit).
  mkdir -p "$NOTIF_DIR" 2>/dev/null || true
  NOTIF_FILE="$NOTIF_DIR/python-determinism-warn.md"
  NEW_CONTENT="$(
    printf '%s\n' '---' 'level: WARN' 'status: pending' '---' ''
    printf '# python-determinism-check — ALERT\n\n'
    printf 'Determinism violations detected: %d\n\n' "$VIOLATIONS"
    printf '%s' "$VIOLATION_LIST"
    printf '\n## Fix guidance\n'
    printf -- '- R1: replace `datetime.now()` with `datetime.now(timezone.utc)`\n'
    printf -- '- R2: use seeded RNG in test fixtures; no bare `random.*` / `secrets.token_*` in production paths\n'
    printf -- '- R3: use `OrderedDict` if iteration order matters; avoid `list(d.keys())[N]` index patterns\n'
    printf -- '- R4: domain layer must be pure functions; remove `time.time()` from `packages/domain/**`\n'
    printf '\nSee ADR: agent-workspace/memory/decisions/059-python-determinism-contract.md\n'
  )"
  NEW_HASH="$(printf '%s' "$NEW_CONTENT" | sha256sum 2>/dev/null | cut -d' ' -f1 || true)"
  OLD_HASH="$(sha256sum "$NOTIF_FILE" 2>/dev/null | cut -d' ' -f1 || true)"
  if [ "$NEW_HASH" != "$OLD_HASH" ]; then
    printf '%s\n' "$NEW_CONTENT" > "$NOTIF_FILE" 2>/dev/null || true
  fi
else
  printf '[%s] python-determinism-check: OK (0 violations across %d file(s))\n' \
    "$TS" "${#SCAN_FILES[@]}" >> "$LOG"
fi

# === D2: Touch cool-down marker if this was a full-tree sweep.
if [ "${#SCAN_FILES[@]}" -gt 100 ]; then
  touch "$PYDET_COOLDOWN_MARKER" 2>/dev/null || true
fi

exit 0
