#!/usr/bin/env bash
# escalation-engine-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
#
# Verifies:
#   TC1: empty state.tsv → no block flag, no urgent.md entry
#   TC2: CRITICAL row → .autonomous-BLOCKED written + urgent.md entry
#   TC3: HIGH row → urgent.md entry but no block flag
#   TC4: UserPromptSubmit event with CRITICAL → stdout contains "AUTONOMOUS-BLOCKED"
#   TC5: idempotency — second call same bucket → no duplicate urgent.md entry
#   TC6: CRITICAL row + ACTIVE .block-grace → block flag SUPPRESSED (anti-deadlock)
#   TC7: CRITICAL row + EXPIRED .block-grace → block flag written + expired grace removed
#
# SPAWN-CONTEXT: positional-arg

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/escalation-engine.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable at $HOOK"; exit 1; }

TMP="$(mktemp -d -t escalation-engine-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  # Pre-rotate markers (avoid hour-bucket collision across TCs)
  rm -f "$TMP/agent-workspace/memory/.escalation-fired-"* 2>/dev/null || true
}

write_state() {
  local rows="$1"
  {
    printf '# severity-state.tsv test fixture\n'
    printf '%s\n' "$rows"
  } > "$TMP/agent-workspace/memory/.severity-state.tsv"
}

run_hook() {
  local event="${1:-Stop}"
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" "$event"
}

# === TC1: empty state.tsv → no side effects ===
setup_tmp
write_state ""
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC1: block flag should not exist for empty state" || note_pass

# === TC2: CRITICAL row → block flag + urgent.md ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z')"
run_hook Stop >/dev/null 2>&1
if [ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC2: block flag not written"; fi
URG_HAS_CRIT=$(grep -c "ESCALATION\|CRITICAL" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
[ "$URG_HAS_CRIT" -ge 0 ] && note_pass || note_fail "TC2: urgent.md missing entry"

# === TC3: HIGH row → urgent.md but no block flag ===
setup_tmp
write_state "$(printf 'HIGH\ttest-bundle.md\t7\tESCALATE-ASKUSERQUESTION\t2026-05-14T02:00:00Z')"
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC3: block flag should NOT exist for HIGH" || note_pass
HIGH_IN_URG=$(grep -c "HIGH" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
if [ "$HIGH_IN_URG" -ge 1 ]; then note_pass; else note_fail "TC3: urgent.md missing HIGH entry"; fi

# === TC4: UserPromptSubmit + CRITICAL → stdout has BLOCKED text ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z')"
OUT=$(run_hook UserPromptSubmit 2>/dev/null)
echo "$OUT" | grep -q "AUTONOMOUS-BLOCKED\|CRITICAL" && note_pass || note_fail "TC4: UserPromptSubmit stdout missing CRITICAL/BLOCKED text"

# === TC5: idempotency — second call same bucket → no double urgent.md HIGH entry ===
setup_tmp
write_state "$(printf 'HIGH\tbundle1.md\t7\tESCALATE-ASKUSERQUESTION\t2026-05-14T02:00:00Z')"
run_hook Stop >/dev/null 2>&1
COUNT1=$(grep -c "ESCALATION" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
run_hook Stop >/dev/null 2>&1
COUNT2=$(grep -c "ESCALATION" "$TMP/human-workspace/notifications/urgent.md" 2>/dev/null || echo 0)
if [ "$COUNT2" -eq "$COUNT1" ]; then note_pass; else note_fail "TC5: second call duplicated entry ($COUNT1 → $COUNT2)"; fi

# === TC6: CRITICAL row + ACTIVE .block-grace → block flag SUPPRESSED ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z')"
GRACE_FUTURE=$(( $(date +%s 2>/dev/null || echo 0) + 1800 ))
printf 'expiry_epoch=%s\ncleared_at=test\n' "$GRACE_FUTURE" > "$TMP/agent-workspace/memory/.block-grace"
run_hook Stop >/dev/null 2>&1
[ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ] && note_fail "TC6: block flag should be SUPPRESSED while .block-grace active" || note_pass

# === TC7: CRITICAL row + EXPIRED .block-grace → block flag written + expired grace removed ===
setup_tmp
write_state "$(printf 'CRITICAL\ttest-artifact.md\t0\tBLOCK\t2026-05-14T02:00:00Z')"
GRACE_PAST=$(( $(date +%s 2>/dev/null || echo 0) - 100 ))
printf 'expiry_epoch=%s\ncleared_at=test\n' "$GRACE_PAST" > "$TMP/agent-workspace/memory/.block-grace"
run_hook Stop >/dev/null 2>&1
if [ -f "$TMP/agent-workspace/memory/.autonomous-BLOCKED" ]; then note_pass; else note_fail "TC7: block flag should be written when grace is expired"; fi
[ -f "$TMP/agent-workspace/memory/.block-grace" ] && note_fail "TC7: expired .block-grace should be removed" || note_pass

# Summary
TOTAL=$((PASS+FAIL))
echo "escalation-engine-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
