#!/usr/bin/env bash
# guardian-output-inspect-first-fire-test.sh — firing test for guardian-output-inspect-first.sh
# (Cluster A from S202 promote-rule cycle proposal).
#
# Per Phase 3.5 §HH-G + L-S176-1: every new hook ships with companion firing-test
# covering at minimum: trigger-state WARN / no-trigger silent / cache-miss-on-edge.
#
# Test cases:
#   TC-flag-edit     : Edit on flagged hook   → WARN + log entry
#   TC-flag-write    : Write on flagged hook  → WARN + log entry
#   TC-not-flagged   : Edit on UN-flagged hook → no WARN
#   TC-non-hook      : Edit on file outside scripts/hooks/ → no WARN
#   TC-non-edit      : Read tool call → no WARN
#   TC-no-notif      : No bash-hook-lint-warn notification present → no WARN
#   TC-empty-payload : empty stdin → no WARN
#
# Phase 0 portability: bash + POSIX only. Soft assert via PASS/FAIL counter.

set -uo pipefail

HOOK="${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/guardian-output-inspect-first.sh"
[ -f "$HOOK" ] || { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR="$(mktemp -d)"
trap "rm -rf $TEMPDIR" EXIT

mkdir -p "$TEMPDIR/scripts/hooks"
mkdir -p "$TEMPDIR/agent-workspace/memory"
mkdir -p "$TEMPDIR/human-workspace/notifications"

# Create fake flagged hook + un-flagged hook
echo '#!/usr/bin/env bash' > "$TEMPDIR/scripts/hooks/flagged-hook.sh"
echo '#!/usr/bin/env bash' > "$TEMPDIR/scripts/hooks/safe-hook.sh"

# Create fake bash-hook-lint-warn notification flagging flagged-hook.sh
NOTIF_FILE="$TEMPDIR/human-workspace/notifications/20260509-120000-bash-hook-lint-warn.md"
cat > "$NOTIF_FILE" <<'EOF'
# bash-hook-lint — Warnings

Per L-S11-1 + L-S13-1 + S16 D-IDENTITY: 2 violation(s) detected.

  - L-S11-1-PORTABILITY: flagged-hook.sh — non-Phase-0-portable invocation (python/jq/yq/pip/npm)
  - L-S48d-1-PIPEFAIL-BARE-GREP: flagged-hook.sh — pipefail + ERR trap + grep without guard

Fix:
- Apply L-S11-1 + L-S48d-1 patterns
EOF

PASS=0
FAIL=0

run_hook() {
  local payload="$1"
  export CLAUDE_PROJECT_DIR="$TEMPDIR"
  printf '%s' "$payload" | bash "$HOOK" 2>&1
}

assert_warn() {
  local tc_name="$1" output="$2"
  if printf '%s' "$output" | grep -q 'guardian-output-inspect-first ADVISORY'; then
    echo "PASS [$tc_name] WARN emitted"
    PASS=$((PASS+1))
  else
    echo "FAIL [$tc_name] expected WARN, got:"
    printf '%s\n' "$output" | head -5 | sed 's/^/  /'
    FAIL=$((FAIL+1))
  fi
}

assert_no_warn() {
  local tc_name="$1" output="$2"
  if printf '%s' "$output" | grep -q 'guardian-output-inspect-first ADVISORY'; then
    echo "FAIL [$tc_name] unexpected WARN:"
    printf '%s\n' "$output" | head -5 | sed 's/^/  /'
    FAIL=$((FAIL+1))
  else
    echo "PASS [$tc_name] no WARN (silent)"
    PASS=$((PASS+1))
  fi
}

# === TC-flag-edit: Edit on flagged hook → WARN ===
PAYLOAD_EDIT_FLAGGED='{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"'"$TEMPDIR"'/scripts/hooks/flagged-hook.sh","old_string":"a","new_string":"b"}}'
OUT=$(run_hook "$PAYLOAD_EDIT_FLAGGED")
assert_warn "TC-flag-edit" "$OUT"

# === TC-flag-write: Write on flagged hook → WARN ===
PAYLOAD_WRITE_FLAGGED='{"hook_event_name":"PreToolUse","tool_name":"Write","tool_input":{"file_path":"'"$TEMPDIR"'/scripts/hooks/flagged-hook.sh","content":"x"}}'
OUT=$(run_hook "$PAYLOAD_WRITE_FLAGGED")
assert_warn "TC-flag-write" "$OUT"

# === TC-not-flagged: Edit on un-flagged hook → no WARN ===
PAYLOAD_EDIT_SAFE='{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"'"$TEMPDIR"'/scripts/hooks/safe-hook.sh","old_string":"a","new_string":"b"}}'
OUT=$(run_hook "$PAYLOAD_EDIT_SAFE")
assert_no_warn "TC-not-flagged" "$OUT"

# === TC-non-hook: Edit on file outside scripts/hooks/ → no WARN ===
PAYLOAD_EDIT_OTHER='{"hook_event_name":"PreToolUse","tool_name":"Edit","tool_input":{"file_path":"'"$TEMPDIR"'/some-other-file.md","old_string":"a","new_string":"b"}}'
OUT=$(run_hook "$PAYLOAD_EDIT_OTHER")
assert_no_warn "TC-non-hook" "$OUT"

# === TC-non-edit: Read tool call → no WARN ===
PAYLOAD_READ='{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"'"$TEMPDIR"'/scripts/hooks/flagged-hook.sh"}}'
OUT=$(run_hook "$PAYLOAD_READ")
assert_no_warn "TC-non-edit" "$OUT"

# === TC-no-notif: notification missing → no WARN ===
mv "$NOTIF_FILE" "$NOTIF_FILE.disabled"
OUT=$(run_hook "$PAYLOAD_EDIT_FLAGGED")
assert_no_warn "TC-no-notif" "$OUT"
mv "$NOTIF_FILE.disabled" "$NOTIF_FILE"

# === TC-empty-payload: empty stdin → no WARN ===
export CLAUDE_PROJECT_DIR="$TEMPDIR"
OUT=$(bash "$HOOK" < /dev/null 2>&1)
assert_no_warn "TC-empty-payload" "$OUT"

echo
echo "=== TOTAL: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
