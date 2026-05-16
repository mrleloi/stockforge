#!/usr/bin/env bash
# python-determinism-check-fire-test.sh — companion firing-test for python-determinism-check.sh
#
# SPAWN-CONTEXT: positional-arg (hook invoked via: bash python-determinism-check.sh)
# No env-var injection needed; PROJECT_DIR passed via CLAUDE_PROJECT_DIR env.
#
# Test cases (12 TC):
#   TC01 — datetime.now() without timezone  → R1 fires
#   TC02 — datetime.now(timezone.utc)       → R1 no fire
#   TC03 — random.random() in module-level  → R2 fires
#   TC04 — random.random() inside __main__  → R2 no fire
#   TC05 — random.random() in test_*.py     → R2 no fire
#   TC06 — secrets.token_urlsafe() in app   → R2 fires
#   TC07 — list(d.keys())[0] pattern        → R3 WARN fires
#   TC08 — time.time() in packages/domain/  → R4 fires
#   TC09 — time.time() in infrastructure/   → R4 no fire (allowed)
#   TC10 — empty file                       → 0 violations
#   TC11 — fully clean file                 → 0 violations
#   TC12 — file outside scan scope (scripts/hooks/)  → not scanned
#
# Exit 0 = all pass. Exit 1 = any fail.

set -uo pipefail

PASS=0
FAIL=0
ERRORS=()

note_pass() {
  PASS=$(( PASS + 1 ))
}

note_fail() {
  FAIL=$(( FAIL + 1 ))
  ERRORS+=("$1")
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../python-determinism-check.sh"

[ -f "$HOOK" ] || { echo "FAIL: hook not found at $HOOK"; exit 1; }
chmod +x "$HOOK" 2>/dev/null || true

# Isolated tmpdir
TMP="$(mktemp -d -t pydet-fire-test-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Helpers

setup_tmp() {
  rm -rf "$TMP"/*
  mkdir -p "$TMP/agent-workspace/memory"
  mkdir -p "$TMP/human-workspace/notifications"
  mkdir -p "$TMP/packages/domain/market_data"
  mkdir -p "$TMP/packages/infrastructure/market_data"
  mkdir -p "$TMP/packages/domain/tests"
  mkdir -p "$TMP/apps/cli"
  mkdir -p "$TMP/scripts/hooks"
}

run_hook_stop() {
  # Stop mode: no stdin payload
  CLAUDE_PROJECT_DIR="$TMP" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

violation_count() {
  local rule="$1"
  # L-S80-2: use if/then/fi clean-integer form; avoid grep -c || echo N (produces "0\n0" on no-match)
  local log="$TMP/agent-workspace/memory/.session-hooks.log"
  if [ ! -f "$log" ]; then echo 0; return; fi
  local n
  n="$(grep -c "python-determinism-check ${rule}" "$log" 2>/dev/null || true)"
  # Sanitize: keep only digits
  n="$(printf '%s' "$n" | tr -d '[:space:]' | head -c 20)"
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  echo "$n"
}

total_violation_count() {
  # Count R-pattern violation entries (not OK entries)
  local log="$TMP/agent-workspace/memory/.session-hooks.log"
  if [ ! -f "$log" ]; then echo 0; return; fi
  local n
  n="$(grep -c "python-determinism-check R[1-4]" "$log" 2>/dev/null || true)"
  n="$(printf '%s' "$n" | tr -d '[:space:]' | head -c 20)"
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  echo "$n"
}

# ============================================================
# TC01: datetime.now() without timezone → R1 fires
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/model.py" <<'EOF'
from datetime import datetime
def get_ts():
    return datetime.now()
EOF
run_hook_stop
R1=$(violation_count "R1")
if [ "$R1" -ge 1 ]; then
  note_pass
else
  note_fail "TC01: expected R1 violation for datetime.now(), got 0 (log: $(cat $TMP/agent-workspace/memory/.session-hooks.log 2>/dev/null))"
fi

# ============================================================
# TC02: datetime.now(timezone.utc) → no R1 fire
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/model.py" <<'EOF'
from datetime import datetime, timezone
def get_ts():
    return datetime.now(timezone.utc)
EOF
run_hook_stop
R1=$(violation_count "R1")
if [ "$R1" -eq 0 ]; then
  note_pass
else
  note_fail "TC02: expected 0 R1 for datetime.now(timezone.utc), got $R1"
fi

# ============================================================
# TC03: random.random() in module-level code → R2 fires
# ============================================================
setup_tmp
cat > "$TMP/packages/infrastructure/market_data/sampler.py" <<'EOF'
import random
THRESHOLD = random.random()
EOF
run_hook_stop
R2=$(violation_count "R2")
if [ "$R2" -ge 1 ]; then
  note_pass
else
  note_fail "TC03: expected R2 for random.random() at module level, got 0"
fi

# ============================================================
# TC04: random.random() inside if __name__ == "__main__": → no R2
# ============================================================
setup_tmp
cat > "$TMP/packages/infrastructure/market_data/sampler.py" <<'EOF'
import random

def compute():
    return 42

if __name__ == "__main__":
    print(random.random())
EOF
run_hook_stop
R2=$(violation_count "R2")
if [ "$R2" -eq 0 ]; then
  note_pass
else
  note_fail "TC04: expected 0 R2 for random inside __main__, got $R2"
fi

# ============================================================
# TC05: random.random() in test_*.py → no R2
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/test_model.py" <<'EOF'
import random
def test_something():
    val = random.random()
    assert 0 <= val <= 1
EOF
run_hook_stop
R2=$(violation_count "R2")
if [ "$R2" -eq 0 ]; then
  note_pass
else
  note_fail "TC05: expected 0 R2 for random in test_*.py, got $R2"
fi

# ============================================================
# TC06: secrets.token_urlsafe() in app code → R2 fires
# ============================================================
setup_tmp
cat > "$TMP/apps/cli/auth.py" <<'EOF'
import secrets
def make_token():
    return secrets.token_urlsafe(32)
EOF
run_hook_stop
R2=$(violation_count "R2")
if [ "$R2" -ge 1 ]; then
  note_pass
else
  note_fail "TC06: expected R2 for secrets.token_urlsafe() in app code, got 0"
fi

# ============================================================
# TC07: list(d.keys())[0] dict iteration index → R3 WARN fires
# ============================================================
setup_tmp
cat > "$TMP/packages/infrastructure/market_data/loader.py" <<'EOF'
def get_first_key(d):
    return list(d.keys())[0]
EOF
run_hook_stop
R3=$(violation_count "R3")
if [ "$R3" -ge 1 ]; then
  note_pass
else
  note_fail "TC07: expected R3 WARN for list(d.keys())[0], got 0 (log: $(cat $TMP/agent-workspace/memory/.session-hooks.log 2>/dev/null))"
fi

# ============================================================
# TC08: time.time() in packages/domain/ → R4 fires
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/model.py" <<'EOF'
import time
def get_epoch():
    return time.time()
EOF
run_hook_stop
R4=$(violation_count "R4")
if [ "$R4" -ge 1 ]; then
  note_pass
else
  note_fail "TC08: expected R4 for time.time() in domain, got 0"
fi

# ============================================================
# TC09: time.time() in packages/infrastructure/ → no R4 (allowed)
# ============================================================
setup_tmp
cat > "$TMP/packages/infrastructure/market_data/poller.py" <<'EOF'
import time
def poll_interval():
    return time.time()
EOF
run_hook_stop
R4=$(violation_count "R4")
if [ "$R4" -eq 0 ]; then
  note_pass
else
  note_fail "TC09: expected 0 R4 for time.time() in infrastructure (allowed), got $R4"
fi

# ============================================================
# TC10: empty file → 0 violations
# ============================================================
setup_tmp
touch "$TMP/packages/domain/market_data/empty.py"
run_hook_stop
TOTAL_VIOLS=$(total_violation_count)
if [ "$TOTAL_VIOLS" -eq 0 ]; then
  note_pass
else
  note_fail "TC10: expected 0 violations on empty file, got $TOTAL_VIOLS"
fi

# ============================================================
# TC11: fully clean file → 0 violations
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/clean.py" <<'EOF'
"""Clean module with no banned patterns."""
from datetime import datetime, timezone
from decimal import Decimal


def get_ts() -> datetime:
    return datetime.now(timezone.utc)


def compute(value: Decimal) -> Decimal:
    return value * Decimal("1.05")
EOF
run_hook_stop
TOTAL_VIOLS=$(total_violation_count)
if [ "$TOTAL_VIOLS" -eq 0 ]; then
  note_pass
else
  note_fail "TC11: expected 0 violations on clean file, got $TOTAL_VIOLS (log: $(cat $TMP/agent-workspace/memory/.session-hooks.log 2>/dev/null))"
fi

# ============================================================
# TC12: file outside scan scope (scripts/hooks/) → not scanned
# ============================================================
setup_tmp
cat > "$TMP/scripts/hooks/helper.py" <<'EOF'
import random
x = random.random()
EOF
run_hook_stop
TOTAL_VIOLS=$(total_violation_count)
if [ "$TOTAL_VIOLS" -eq 0 ]; then
  note_pass
else
  note_fail "TC12: expected 0 violations for file outside scan scope (scripts/hooks/), got $TOTAL_VIOLS"
fi

# ============================================================
# TC13: S341 D1 — content-hash dedup: level:WARN frontmatter present + mtime unchanged on 2nd run
# ============================================================
setup_tmp
cat > "$TMP/packages/domain/market_data/model.py" <<'EOF'
from datetime import datetime
def ts():
    return datetime.now()
EOF
run_hook_stop
NOTIF="$TMP/human-workspace/notifications/python-determinism-warn.md"
# Verify level: WARN frontmatter
LVL="$(head -10 "$NOTIF" 2>/dev/null | grep -m1 '^level:' | sed 's/^level:[[:space:]]*//' | tr -d '[:space:]' || true)"
if [ "$LVL" = "WARN" ]; then
  note_pass
else
  note_fail "TC13a: expected level:WARN frontmatter in python-determinism-warn.md, got '$LVL'"
fi
# Verify mtime unchanged on 2nd run (content-hash dedup)
if [ -f "$NOTIF" ]; then
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  sleep 1
  run_hook_stop
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    note_pass
  else
    note_fail "TC13b: mtime changed on 2nd run with identical content (dedup did not fire): mtime1=$MTIME1 mtime2=$MTIME2"
  fi
else
  note_fail "TC13b: notification not found for mtime check"
fi

# ============================================================
# TC-HOISTED: D1 S346 plan-023 — find-delete NOT in claim_file_slot body
# ============================================================
# Assert 1: no non-comment 'find.*-delete' line inside claim_file_slot() body
HOOK_SRC="$(cat "$HOOK" 2>/dev/null || true)"
CLAIM_BODY="$(printf '%s\n' "$HOOK_SRC" | awk '/^claim_file_slot\(\)/,/^\}/' | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' | grep -v 'claim_file_slot' | grep -v '^}' || true)"
if printf '%s\n' "$CLAIM_BODY" | grep -q 'find.*-delete'; then
  note_fail "TC-HOISTED-1: find-delete still found in claim_file_slot() non-comment body (D1 regression)"
else
  note_pass
fi

# Assert 2: hoisted find-delete line exists in hook source (outside claim_file_slot)
if printf '%s\n' "$HOOK_SRC" | grep -v '^[[:space:]]*#' | grep -q 'find.*\.pydet-marker.*-delete'; then
  note_pass
else
  note_fail "TC-HOISTED-2: hoisted 'find .pydet-marker* -delete' not found in hook source (D1 not applied)"
fi

# ============================================================
# TC-COOLDOWN: D2 S346 plan-023 — Stop-mode cool-down behavior
# ============================================================
# Setup: fresh sandbox with 105 .py files to exceed >100 SCAN_FILES threshold
COOL_TMP="$(mktemp -d -t pydet-cooldown-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$COOL_TMP" "$TMP"' EXIT
mkdir -p "$COOL_TMP/agent-workspace/memory"
mkdir -p "$COOL_TMP/human-workspace/notifications"
mkdir -p "$COOL_TMP/packages/domain/market_data"

# Create 105 clean dummy .py files so SCAN_FILES > 100 and cooldown marker is written
for i in $(seq 1 105); do
  printf '# dummy %d\n' "$i" > "$COOL_TMP/packages/domain/market_data/dummy_${i}.py"
done

# Assert 3: First Stop run creates the cooldown marker
COOL_MARKER="$COOL_TMP/agent-workspace/memory/.pydet-last-full-sweep"
CLAUDE_PROJECT_DIR="$COOL_TMP" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
if [ -f "$COOL_MARKER" ]; then
  note_pass
else
  note_fail "TC-COOLDOWN-3: .pydet-last-full-sweep not created after first run with >100 files"
fi

# Assert 4: Second Stop run (within 600s) logs SKIP-COOLDOWN
COOL_LOG="$COOL_TMP/agent-workspace/memory/.session-hooks.log"
CLAUDE_PROJECT_DIR="$COOL_TMP" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  note_pass
else
  note_fail "TC-COOLDOWN-4: SKIP-COOLDOWN not logged on second Stop run within 600s"
fi

# Assert 5: After marker is expired (>600s old), full sweep runs (no SKIP-COOLDOWN on 3rd run)
touch -d '700 seconds ago' "$COOL_MARKER" 2>/dev/null || true
# Clear log to detect new SKIP-COOLDOWN entry
rm -f "$COOL_LOG"
CLAUDE_PROJECT_DIR="$COOL_TMP" bash "$HOOK" </dev/null >/dev/null 2>&1 || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  note_fail "TC-COOLDOWN-5: SKIP-COOLDOWN incorrectly logged after marker expired (>600s)"
else
  note_pass
fi

# Assert 6: PostToolUse JSON stdin bypasses cooldown (touch fresh marker first)
touch "$COOL_MARKER" 2>/dev/null || true
rm -f "$COOL_LOG"
CLEAN_PY="$COOL_TMP/packages/domain/market_data/clean_probe.py"
printf 'from datetime import datetime, timezone\ndef get_ts():\n    return datetime.now(timezone.utc)\n' > "$CLEAN_PY"
# PostToolUse JSON payload — should bypass cooldown entirely
printf '%s' "{\"file_path\": \"${CLEAN_PY}\"}" | CLAUDE_PROJECT_DIR="$COOL_TMP" bash "$HOOK" >/dev/null 2>&1 || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  note_fail "TC-COOLDOWN-6: PostToolUse JSON stdin should NOT trigger SKIP-COOLDOWN (bypass cooldown)"
else
  note_pass
fi
rm -rf "$COOL_TMP"

# ============================================================
# Summary
# ============================================================
TOTAL=$(( PASS + FAIL ))
echo "python-determinism-check-fire-test: ${PASS}/${TOTAL} PASS"
if [ "$FAIL" -gt 0 ]; then
  for e in "${ERRORS[@]}"; do
    echo "  FAIL: $e"
  done
  exit 1
fi
exit 0
