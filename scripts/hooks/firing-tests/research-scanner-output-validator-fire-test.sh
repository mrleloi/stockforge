#!/usr/bin/env bash
# Firing-test for research-scanner-output-validator.sh (L-S49b-4 charter-coverage push; S79).
#
# Hook purpose (Stop hook; L-S12-2 promotion target hook):
#   - Skip if DOGFOOD_DIR (agent-workspace/learning-data/dogfood/) missing.
#   - Iterate agent-pick-*-research-report-*.md files.
#   - Per file: head -50 frontmatter check for `^picked:` + `^as_of:`; entire file check
#     for `^##\s+Adversarial\s+Bear\s+Case` + `^##\s+Provenance\s+Log`.
#   - Per-file violations collected as comma-list; logged in VIOLATION_LIST.
#   - VIOLATIONS > 0: log WARN + write notif. Else: log OK (0 violations).
#   - Always exit 0 (non-blocking).
#
# 5 test cases:
#   TC1 — no DOGFOOD_DIR → silent exit 0; no log entry
#   TC2 — empty DOGFOOD_DIR (no agent-pick-* files) → log OK (0 violations)
#   TC3 — 1 valid report (all 4 discipline elements) → log OK (0 violations); no notif
#   TC4 — 1 report missing all 4 elements → WARN 1 + notif + 4 missing items listed
#   TC5 — 1 report missing only `picked:` → WARN 1 + notif; only `picked-frontmatter` listed
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../research-scanner-output-validator.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

DOGFOOD_DIR="$TEMPDIR/agent-workspace/learning-data/dogfood"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
MEM_DIR="$TEMPDIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$NOTIF_DIR"
}

# --- TC1: no DOGFOOD_DIR → silent exit 0; no log entry ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
if [ -f "$LOG" ] && grep -q "research-scanner-output-validator" "$LOG"; then
  echo "FAIL TC1: log should not contain entry when DOGFOOD_DIR missing"
  cat "$LOG"
  exit 1
fi
echo "PASS TC1: no DOGFOOD_DIR → silent exit 0"

# --- TC2: empty DOGFOOD_DIR → log OK (0 violations) ---
clean_state
mkdir -p "$DOGFOOD_DIR"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "research-scanner-output-validator OK (0 violations)" "$LOG"; then
  echo "FAIL TC2: log should record OK (0 violations) for empty DOGFOOD_DIR"
  cat "$LOG" 2>/dev/null
  exit 1
fi
echo "PASS TC2: empty DOGFOOD_DIR → log OK (0 violations)"

# --- TC3: valid report (all 4 elements) → log OK (0 violations) ---
clean_state
mkdir -p "$DOGFOOD_DIR"
cat > "$DOGFOOD_DIR/agent-pick-1-research-report-2026-05-06.md" <<'EOF'
---
picked: opensearch-foo
as_of: 2026-05-06
provenance: research-scanner-S79
---

# Research Report

## Summary
Findings.

## Adversarial Bear Case
Risks identified.

## Provenance Log
- 2026-05-06: searched cafef.vn for foo
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "research-scanner-output-validator OK (0 violations)" "$LOG"; then
  echo "FAIL TC3: log should record OK (0 violations) for valid report"
  cat "$LOG"
  exit 1
fi
if grep -q "research-scanner-output-validator WARN" "$LOG"; then
  echo "FAIL TC3: log should NOT WARN for valid report"
  cat "$LOG"
  exit 1
fi
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name '*-research-scanner-validator-warn.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -ne 0 ]; then
  echo "FAIL TC3: notif should NOT be written when 0 violations"
  ls -la "$NOTIF_DIR"
  exit 1
fi
echo "PASS TC3: valid report → log OK (0 violations); no notif"

# --- TC4: report missing all 4 elements → WARN 1 + notif + 4 items listed ---
clean_state
mkdir -p "$DOGFOOD_DIR"
cat > "$DOGFOOD_DIR/agent-pick-2-research-report-2026-05-06.md" <<'EOF'
---
provenance: research-scanner-S79
---

# Research Report

## Summary
Findings only — no discipline elements.
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "research-scanner-output-validator WARN 1 report" "$LOG"; then
  echo "FAIL TC4: log should WARN 1 report missing discipline elements"
  cat "$LOG"
  exit 1
fi
for ITEM in "picked-frontmatter" "as_of-frontmatter" "adversarial-bear-case-section" "provenance-log-section"; do
  if ! grep -q "$ITEM" "$LOG"; then
    echo "FAIL TC4: log should mention missing $ITEM"
    cat "$LOG"
    exit 1
  fi
done
if ! grep -q "agent-pick-2-research-report-2026-05-06.md" "$LOG"; then
  echo "FAIL TC4: log should list offending basename"
  cat "$LOG"
  exit 1
fi
NOTIF_COUNT=0
NOTIF_COUNT=$(find "$NOTIF_DIR" -name '*-research-scanner-validator-warn.md' -type f 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "$NOTIF_COUNT" -lt 1 ]; then
  echo "FAIL TC4: notif file should be written when violations > 0"
  ls -la "$NOTIF_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC4: missing all 4 elements → WARN 1 + notif + 4 items listed"

# --- TC5: report missing only picked: frontmatter → WARN 1 + only picked-frontmatter listed ---
clean_state
mkdir -p "$DOGFOOD_DIR"
cat > "$DOGFOOD_DIR/agent-pick-3-research-report-2026-05-06.md" <<'EOF'
---
as_of: 2026-05-06
provenance: research-scanner-S79
---

# Research Report

## Adversarial Bear Case
Risks listed.

## Provenance Log
- 2026-05-06: searched cafef.vn
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
if ! grep -q "research-scanner-output-validator WARN 1 report" "$LOG"; then
  echo "FAIL TC5: log should WARN 1 report missing only picked frontmatter"
  cat "$LOG"
  exit 1
fi
if ! grep -q "picked-frontmatter" "$LOG"; then
  echo "FAIL TC5: log should mention missing picked-frontmatter"
  cat "$LOG"
  exit 1
fi
# These should NOT appear (they were present)
for ITEM in "as_of-frontmatter" "adversarial-bear-case-section" "provenance-log-section"; do
  if grep -q "$ITEM" "$LOG"; then
    echo "FAIL TC5: log should NOT mention $ITEM (was present in fixture)"
    cat "$LOG"
    exit 1
  fi
done
echo "PASS TC5: missing only picked: → WARN 1 + only picked-frontmatter listed"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "research-scanner-output-validator.sh externally-observable behavior verified."
exit 0
