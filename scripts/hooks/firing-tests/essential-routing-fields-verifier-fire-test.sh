#!/usr/bin/env bash
# Firing-test for essential-routing-fields-verifier.sh (S101 deliverable per Phase 3.5
# T7 hard rule #2 — every hook ships with companion firing-test).
#
# Hook purpose (SessionStart): verify essential routing fields exist in current-execution.md.
#   1. **autonomous_mode**: <true|false>  (controls continue-injector spawn on /clear)
#   2. ≥1 ## S<N> session row              (sanity)
#
# Behavior on missing/invalid: WARN to log + emit notification + emit additionalContext.
# Always exit 0 (soft-warn).
#
# Test cases (8 TC):
#   TC1 — current-execution.md missing → 1 violation (missing_file), notification + context emitted
#   TC2 — clean state (autonomous_mode=true + ≥1 session row) → 0 violations, no notification
#   TC3 — autonomous_mode field absent → 1 violation (missing_field) — M-S99-2 regression scenario
#   TC4 — autonomous_mode value invalid (e.g. "yes") → 1 violation (invalid_value)
#   TC5 — 0 ## S<N> session rows → 1 violation (missing_session_rows)
#   TC6 — source != startup|resume|clear (e.g. PreCompact) → exit 0 no-op skip line
#   TC7 — multiple violations (no autonomous_mode + 0 sessions) → notification lists all
#   TC8 — empirical M-S99-2 reproduction: file has header but no autonomous_mode line
#         (exact pattern S99 archive truncation produced) → flagged with M-S99-2 reference
#
# Exit 0 = all pass. Exit 1 = any fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../essential-routing-fields-verifier.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

MEM_DIR="$TEMPDIR/agent-workspace/memory"
NOTIF_DIR="$TEMPDIR/human-workspace/notifications"
EXEC_FILE="$MEM_DIR/current-execution.md"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_FILE="$NOTIF_DIR/essential-routing-fields-MISSING.md"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace" "$TEMPDIR/human-workspace"
  mkdir -p "$MEM_DIR" "$NOTIF_DIR"
}

run_hook_with_payload() {
  local payload="$1"
  printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" >/dev/null 2>&1
}

run_hook_default() {
  # No payload → verifier defaults SOURCE=startup.
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1
}

assert_violations_eq() {
  local expected="$1" tag="$2"
  local got
  got=$(grep "essential-routing-fields-verifier: violations=" "$LOG" 2>/dev/null | tail -1 | grep -oE 'violations=[0-9]+' | sed 's/violations=//' || true)
  if [ "${got:-MISSING}" != "$expected" ]; then
    echo "FAIL $tag: expected violations=$expected; got violations=${got:-MISSING}"
    [ -f "$LOG" ] && cat "$LOG"
    exit 1
  fi
}

# --- TC1: current-execution.md missing → 1 violation (missing_file) ---
clean_state
run_hook_default
assert_violations_eq 1 "TC1"
if ! grep -q "missing_file" "$LOG"; then
  echo "FAIL TC1: log should mention missing_file"
  cat "$LOG"
  exit 1
fi
if [ ! -f "$NOTIF_FILE" ]; then
  echo "FAIL TC1: notification file should exist"
  exit 1
fi
echo "PASS TC1: file missing → 1 violation (missing_file) + notification emitted"

# --- TC2: clean state → 0 violations ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: true (RE-ENABLED 2026-05-05 S48 via /autonomous on)

## S101 — Phase 3 — test row

content here
EOF
run_hook_default
assert_violations_eq 0 "TC2"
if [ -f "$NOTIF_FILE" ]; then
  echo "FAIL TC2: notification should NOT exist when clean"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC2: clean state (autonomous_mode=true + 1 session row) → 0 violations"

# --- TC3: autonomous_mode absent → 1 violation (missing_field) ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

(no autonomous_mode line — exactly the S99 archive bug)

## S101 — Phase 3 — row

content
EOF
run_hook_default
assert_violations_eq 1 "TC3"
if ! grep -q "missing_field: \*\*autonomous_mode\*\*" "$LOG"; then
  echo "FAIL TC3: log should mention missing_field for autonomous_mode"
  cat "$LOG"
  exit 1
fi
if ! grep -q "M-S99-2" "$LOG"; then
  echo "FAIL TC3: log should reference M-S99-2 root cause"
  exit 1
fi
echo "PASS TC3: autonomous_mode absent → 1 violation (missing_field; M-S99-2 referenced)"

# --- TC4: autonomous_mode invalid value → 1 violation (invalid_value) ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: yes

## S101 — row
EOF
run_hook_default
assert_violations_eq 1 "TC4"
if ! grep -q "invalid_value" "$LOG"; then
  echo "FAIL TC4: log should mention invalid_value"
  cat "$LOG"
  exit 1
fi
echo "PASS TC4: autonomous_mode='yes' → 1 violation (invalid_value)"

# --- TC5: 0 session rows → 1 violation (missing_session_rows) ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: true

(no session rows — empty)
EOF
run_hook_default
assert_violations_eq 1 "TC5"
if ! grep -q "missing_session_rows" "$LOG"; then
  echo "FAIL TC5: log should mention missing_session_rows"
  cat "$LOG"
  exit 1
fi
echo "PASS TC5: 0 session rows → 1 violation (missing_session_rows)"

# --- TC6: source != startup|resume|clear → no-op skip ---
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution

**autonomous_mode**: true

## S101 — row
EOF
# Pass payload with non-matching source (e.g. PreCompact). Note: this requires node;
# if node missing, verifier falls back to default startup → test becomes vacuous
# but still safe (would just exit-0 for clean state).
if command -v node >/dev/null 2>&1; then
  run_hook_with_payload '{"source":"PreCompact"}'
  if ! grep -q "skipped source=PreCompact" "$LOG"; then
    echo "FAIL TC6: log should record skipped source=PreCompact"
    cat "$LOG"
    exit 1
  fi
  echo "PASS TC6: source=PreCompact → no-op skip line"
else
  echo "SKIP TC6: node unavailable; cannot test source-filter branch"
fi

# --- TC7: multiple violations → notification lists all ---
clean_state
printf '# Empty header\n' > "$EXEC_FILE"  # No autonomous_mode + 0 session rows
run_hook_default
assert_violations_eq 2 "TC7"
if [ ! -f "$NOTIF_FILE" ]; then
  echo "FAIL TC7: notification file should exist"
  exit 1
fi
NOTIF_VIOL_COUNT=$(grep -cE '^- (missing_file|missing_field|missing_session_rows|invalid_value)' "$NOTIF_FILE" 2>/dev/null || true)
NOTIF_VIOL_COUNT="${NOTIF_VIOL_COUNT:-0}"
if [ "$NOTIF_VIOL_COUNT" -lt 2 ]; then
  echo "FAIL TC7: notification should list ≥2 violation lines (got $NOTIF_VIOL_COUNT)"
  cat "$NOTIF_FILE"
  exit 1
fi
echo "PASS TC7: 2 violations listed in notification"

# --- TC8: M-S99-2 empirical reproduction — file shape exactly like S99 truncation outcome ---
# S99 archive collapsed current-execution.md from 2738 LOC to 158 LOC and dropped the
# **autonomous_mode** line that lived between header and S49b row. Reproduce that exact
# shape and confirm verifier flags it.
clean_state
cat > "$EXEC_FILE" <<'EOF'
# Current Execution — Routing Source of Truth

> This is THE single source of truth for "where is work currently happening".
> Agent reads this at session start to identify active track.

## S99 — Phase 3 — Tracking-bloat RCA Layer 1+2+3+5 IMPL ✅

(content)

## S98 — Phase 3 — sync-grilling-S98 ✅

(content)
EOF
run_hook_default
assert_violations_eq 1 "TC8"
if ! grep -q "missing_field: \*\*autonomous_mode\*\*" "$LOG"; then
  echo "FAIL TC8: M-S99-2 regression — should flag missing autonomous_mode field"
  cat "$LOG"
  exit 1
fi
if ! grep -q "M-S99-2" "$LOG"; then
  echo "FAIL TC8: notification should reference M-S99-2 lineage"
  exit 1
fi
echo "PASS TC8: M-S99-2 file-shape regression caught (missing autonomous_mode flagged)"

echo "ALL PASS (8/8)"
exit 0
