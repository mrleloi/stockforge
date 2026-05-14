#!/usr/bin/env bash
# severity-classifier-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Exercises severity-classifier.sh in isolated tmpdir; verifies:
#   TC1: empty state → empty .severity-state.tsv (header only)
#   TC2: stale-checkpoint marker → 1 CRITICAL row
#   TC3: Q&A bundle age=7h status=pending → 1 HIGH row
#   TC4: Q&A bundle age=2h status=pending → 1 LOW row (under 6h threshold)
#   TC5: Q&A bundle status=answered → 0 rows (filtered)
#
# SPAWN-CONTEXT: positional-arg (hook runs as bash $script; no env var injection needed)

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

note_fail() {
  FAIL=$((FAIL+1))
  ERRORS+=("$1")
}

note_pass() {
  PASS=$((PASS+1))
}

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/severity-classifier.sh"

[ -x "$HOOK" ] || chmod +x "$HOOK" 2>/dev/null || true
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

# Isolated tmpdir
TMP="$(mktemp -d -t severity-classifier-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/agent-workspace/memory/decisions"
  mkdir -p "$TMP/human-workspace/q-and-a/pending"
  mkdir -p "$TMP/human-workspace/notifications"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" >/dev/null 2>&1
}

# === TC1: empty state ===
setup_tmp
run_hook
[ -f "$TMP/agent-workspace/memory/.severity-state.tsv" ] || note_fail "TC1: state file not created"
ROW_COUNT=$(grep -v "^#" "$TMP/agent-workspace/memory/.severity-state.tsv" 2>/dev/null | grep -c . 2>/dev/null)
[ -z "$ROW_COUNT" ] && ROW_COUNT=0
if [ "$ROW_COUNT" -eq 0 ]; then note_pass; else note_fail "TC1: expected 0 rows, got $ROW_COUNT"; fi

# === TC2: stale-checkpoint marker → CRITICAL ===
setup_tmp
touch "$TMP/agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint"
run_hook
CRIT=$(grep -c "^CRITICAL"$'\t' "$TMP/agent-workspace/memory/.severity-state.tsv" 2>/dev/null || echo 0)
if [ "$CRIT" -ge 1 ]; then note_pass; else note_fail "TC2: expected ≥1 CRITICAL, got $CRIT"; fi

# === TC3: Q&A bundle age=7h pending → HIGH ===
setup_tmp
QA_FILE="$TMP/human-workspace/q-and-a/pending/test-bundle-age7h.md"
cat > "$QA_FILE" <<EOF
---
status: pending
priority: HIGH
---
test bundle
EOF
# Set mtime to 7h ago
touch -d "7 hours ago" "$QA_FILE" 2>/dev/null || touch -t "$(date -d '7 hours ago' +%Y%m%d%H%M.%S 2>/dev/null || echo '202605140000.00')" "$QA_FILE" 2>/dev/null || true
run_hook
HIGH=$(grep -c "^HIGH"$'\t' "$TMP/agent-workspace/memory/.severity-state.tsv" 2>/dev/null || echo 0)
if [ "$HIGH" -ge 1 ]; then note_pass; else note_fail "TC3: expected ≥1 HIGH, got $HIGH (state.tsv: $(cat $TMP/agent-workspace/memory/.severity-state.tsv 2>/dev/null))"; fi

# === TC4: Q&A bundle age=2h pending → LOW (under 6h threshold) ===
setup_tmp
QA_FILE="$TMP/human-workspace/q-and-a/pending/test-bundle-fresh.md"
cat > "$QA_FILE" <<EOF
---
status: pending
priority: HIGH
---
fresh bundle
EOF
# Recent mtime (default = now)
run_hook
LOW=$(grep -c "^LOW"$'\t' "$TMP/agent-workspace/memory/.severity-state.tsv" 2>/dev/null || echo 0)
if [ "$LOW" -ge 1 ]; then note_pass; else note_fail "TC4: expected ≥1 LOW, got $LOW"; fi

# === TC5: Q&A bundle status=answered → 0 rows ===
setup_tmp
QA_FILE="$TMP/human-workspace/q-and-a/pending/test-bundle-answered.md"
cat > "$QA_FILE" <<EOF
---
status: answered-2026-05-14
priority: HIGH
---
EOF
touch -d "10 hours ago" "$QA_FILE" 2>/dev/null || true
run_hook
ROWS=$(grep "test-bundle-answered" "$TMP/agent-workspace/memory/.severity-state.tsv" 2>/dev/null | grep -c . 2>/dev/null)
[ -z "$ROWS" ] && ROWS=0
if [ "$ROWS" -eq 0 ]; then note_pass; else note_fail "TC5: expected 0 rows for answered bundle, got $ROWS"; fi

# === Summary ===
TOTAL=$((PASS+FAIL))
echo "severity-classifier-fire-test: $PASS/$TOTAL PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do echo "  - $e"; done
  exit 1
fi
exit 0
