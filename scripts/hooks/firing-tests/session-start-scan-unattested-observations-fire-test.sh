#!/usr/bin/env bash
# session-start-scan-unattested-observations-fire-test.sh — Plan 012 D1 firing test.
# Tests externally-observable behavior per L-S59-1:
#   - .unattested-observations.tsv registry row appended
#   - notification file created on detection
#   - kill switch honored
#   - source filter (only startup|resume|clear|empty)
#   - dedup: re-fire same obs basename → no duplicate registry row
# Per L-S52-3 success-path: real-data smoke + ≥6 TCs (≥1 positive + ≥3 negative + kill-switch).
# Per L-S62-1: no yes|head patterns; fixtures via printf/cat heredoc.
# Per L-S11-1 portability: bash + awk + grep + sed only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../session-start-scan-unattested-observations.sh"
if [ ! -f "$HOOK" ]; then
  echo "FAIL: hook not found at $HOOK"
  exit 1
fi

PASS=0
FAIL=0

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
OBS_DIR="$PROJECT_DIR/agent-workspace/memory/observations"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
ATTEST_LOG="$MEMORY_DIR/attestation-log.tsv"
REGISTRY="$MEMORY_DIR/.unattested-observations.tsv"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"

setup_sandbox() {
  rm -rf "$PROJECT_DIR"
  mkdir -p "$OBS_DIR" "$MEMORY_DIR" "$NOTIF_DIR"
}

make_obs() {
  local basename="$1"
  cat > "$OBS_DIR/${basename}.md" <<EOF
---
observation_id: ${basename}
agent: sandwich-dev
verdict: READY-FOR-MAIN-VERIFY
---
body
EOF
}

run_hook() {
  local payload="$1"
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_SESSION_ID="test-sess-$$" \
    bash "$HOOK" <<< "$payload" 2>/dev/null
}

assert_pass() { PASS=$((PASS+1)); printf 'PASS TC%s: %s\n' "$2" "$1"; }
assert_fail() { FAIL=$((FAIL+1)); printf 'FAIL TC%s: %s\n' "$2" "$1"; }

PAYLOAD_STARTUP='{"hook_event_name":"SessionStart","source":"startup","session_id":"test-sess"}'
PAYLOAD_CLEAR='{"hook_event_name":"SessionStart","source":"clear","session_id":"test-sess"}'
PAYLOAD_RESUME='{"hook_event_name":"SessionStart","source":"resume","session_id":"test-sess"}'
PAYLOAD_OTHER='{"hook_event_name":"SessionStart","source":"compact","session_id":"test-sess"}'

# ----------------------------------------------------------------------
# TC1 — single unattested obs → registry row + notification + WARN to stderr
# (TC1 uses direct bash invocation to capture stderr; run_hook suppresses it)
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc1"
STDERR="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" CLAUDE_SESSION_ID="test-sess-tc1" \
  bash "$HOOK" <<< "$PAYLOAD_STARTUP" 2>&1 >/dev/null || true)"
REG_ROWS="$(grep -c "sandwich-dev-S99-tc1" "$REGISTRY" 2>/dev/null || true)"
REG_ROWS="${REG_ROWS:-0}"
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
WARN_HIT="$(printf '%s' "$STDERR" | grep -c 'WARN.*unattested' 2>/dev/null || true)"
WARN_HIT="${WARN_HIT:-0}"
if [ "$REG_ROWS" -eq 1 ] && [ "$NOTIF_COUNT" -eq 1 ] && [ "$WARN_HIT" -ge 1 ]; then
  assert_pass "single unattested → registry row + notification + WARN stderr" "1"
else
  assert_fail "TC1: reg_rows=$REG_ROWS notif=$NOTIF_COUNT warn=$WARN_HIT (expected 1/1/≥1)" "1"
fi

# ----------------------------------------------------------------------
# TC2 — obs with marker present → NOT flagged (attested via marker)
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc2"
touch "$MEMORY_DIR/.attestation-checked-sandwich-dev-S99-tc2"
run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
REG_ROWS="$(grep -c "sandwich-dev-S99-tc2" "$REGISTRY" 2>/dev/null || true)"
REG_ROWS="${REG_ROWS:-0}"
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ "$REG_ROWS" -eq 0 ] && [ "$NOTIF_COUNT" -eq 0 ]; then
  assert_pass "obs with marker → not flagged (attested)" "2"
else
  assert_fail "TC2: reg_rows=$REG_ROWS notif=$NOTIF_COUNT (expected 0/0)" "2"
fi

# ----------------------------------------------------------------------
# TC3 — obs with attestation-log row → NOT flagged (attested via log)
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc3"
printf 'ts\tdispatch_id\tobservation_passed\tempirical_passed\tdivergence\tverdict\n' > "$ATTEST_LOG"
printf '2026-05-06T00:00:00Z\tsandwich-dev-S99-tc3\t10\t10\t0\tPASS\n' >> "$ATTEST_LOG"
run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
REG_ROWS="$(grep -c "sandwich-dev-S99-tc3" "$REGISTRY" 2>/dev/null || true)"
REG_ROWS="${REG_ROWS:-0}"
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ "$REG_ROWS" -eq 0 ] && [ "$NOTIF_COUNT" -eq 0 ]; then
  assert_pass "obs with attestation-log row → not flagged (attested)" "3"
else
  assert_fail "TC3: reg_rows=$REG_ROWS notif=$NOTIF_COUNT (expected 0/0)" "3"
fi

# ----------------------------------------------------------------------
# TC4 — kill switch STOCKFORGE_UNATTESTED_SCAN_DISABLE=1 → no scan, no registry, no notif
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc4"
STOCKFORGE_UNATTESTED_SCAN_DISABLE=1 run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
REG_EXISTS="0"
if [ -f "$REGISTRY" ]; then REG_EXISTS="1"; fi
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ "$REG_EXISTS" = "0" ] && [ "$NOTIF_COUNT" -eq 0 ]; then
  assert_pass "kill switch → no scan, no registry, no notification" "4"
else
  assert_fail "TC4: reg_exists=$REG_EXISTS notif=$NOTIF_COUNT (expected 0/0)" "4"
fi

# ----------------------------------------------------------------------
# TC5 — payload source=compact (not startup|resume|clear|empty) → no scan
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc5"
run_hook "$PAYLOAD_OTHER" >/dev/null 2>&1
REG_EXISTS="0"
if [ -f "$REGISTRY" ]; then REG_EXISTS="1"; fi
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ "$REG_EXISTS" = "0" ] && [ "$NOTIF_COUNT" -eq 0 ]; then
  assert_pass "source=compact → hook exits without scan" "5"
else
  assert_fail "TC5: reg_exists=$REG_EXISTS notif=$NOTIF_COUNT (expected 0/0)" "5"
fi

# ----------------------------------------------------------------------
# TC6 — multiple unattested obs (mix sandwich-dev + sandwich-arch) → only sandwich-dev flagged
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc6a"
make_obs "sandwich-dev-S99-tc6b"
# Architect/verifier observations should NOT be scanned (D1 contract = sandwich-dev only)
cat > "$OBS_DIR/sandwich-architect-S99-ignored.md" <<'EOF'
---
observation_id: sandwich-architect-S99-ignored
agent: sandwich-architect
---
body
EOF
cat > "$OBS_DIR/sandwich-verifier-S99-ignored.md" <<'EOF'
---
observation_id: sandwich-verifier-S99-ignored
agent: sandwich-verifier
---
body
EOF
run_hook "$PAYLOAD_RESUME" >/dev/null 2>&1
DEV_ROWS="$(grep -c "sandwich-dev-S99-tc6" "$REGISTRY" 2>/dev/null || true)"
DEV_ROWS="${DEV_ROWS:-0}"
ARCH_ROWS="$(grep -c "sandwich-architect-S99" "$REGISTRY" 2>/dev/null || true)"
ARCH_ROWS="${ARCH_ROWS:-0}"
VER_ROWS="$(grep -c "sandwich-verifier-S99" "$REGISTRY" 2>/dev/null || true)"
VER_ROWS="${VER_ROWS:-0}"
if [ "$DEV_ROWS" -eq 2 ] && [ "$ARCH_ROWS" -eq 0 ] && [ "$VER_ROWS" -eq 0 ]; then
  assert_pass "scope = sandwich-dev only (2 dev rows; 0 architect; 0 verifier)" "6"
else
  assert_fail "TC6: dev=$DEV_ROWS arch=$ARCH_ROWS ver=$VER_ROWS (expected 2/0/0)" "6"
fi

# ----------------------------------------------------------------------
# TC7 — dedup: re-fire same obs → registry row count stays at 1
# ----------------------------------------------------------------------
setup_sandbox
make_obs "sandwich-dev-S99-tc7"
run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
REG_ROWS="$(grep -c "sandwich-dev-S99-tc7" "$REGISTRY" 2>/dev/null || true)"
REG_ROWS="${REG_ROWS:-0}"
if [ "$REG_ROWS" -eq 1 ]; then
  assert_pass "re-fire same obs → dedup honored (1 row not 2)" "7"
else
  assert_fail "TC7: reg_rows=$REG_ROWS (expected 1)" "7"
fi

# ----------------------------------------------------------------------
# TC8 — empty observations dir → graceful exit, no registry, no notif
# ----------------------------------------------------------------------
setup_sandbox
# OBS_DIR exists but empty
run_hook "$PAYLOAD_STARTUP" >/dev/null 2>&1
EXIT_CODE=$?
NOTIF_COUNT="$(ls "$NOTIF_DIR"/*-unattested-observations.md 2>/dev/null | wc -l || true)"
NOTIF_COUNT="${NOTIF_COUNT:-0}"
if [ "$EXIT_CODE" -eq 0 ] && [ "$NOTIF_COUNT" -eq 0 ]; then
  assert_pass "empty observations dir → exit 0, no notification" "8"
else
  assert_fail "TC8: exit=$EXIT_CODE notif=$NOTIF_COUNT (expected 0/0)" "8"
fi

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
TOTAL=$((PASS+FAIL))
echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
if [ "$FAIL" -eq 0 ]; then
  echo "session-start-scan-unattested-observations (Plan 012 D1) verified."
  exit 0
else
  echo "FAILURE — review TCs above."
  exit 1
fi
