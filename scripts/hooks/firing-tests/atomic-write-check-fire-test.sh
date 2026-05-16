#!/usr/bin/env bash
# atomic-write-check-fire-test.sh — Firing-test for atomic-write-check.sh hook.
#
# Verifies the W0-3 hook fires correctly on banned non-atomic write patterns and
# stays silent on allowed patterns.
#
# SPAWN-CONTEXT: positional-arg
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
# ADR: agent-workspace/memory/decisions/062-atomic-write-doctrine.md
# Hook: scripts/hooks/atomic-write-check.sh
#
# ≥12 TC minimum (architect-proposed); 15 TC implemented.
# Exit 0 if all PASS; exit 1 on any FAIL.
set -uo pipefail

HOOK="${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/atomic-write-check.sh"
SANDBOX="$(mktemp -d)"
ORIG_DIR="$(pwd)"
PASS=0
FAIL=0

cleanup() {
  cd "$ORIG_DIR" 2>/dev/null || true
  rm -rf "$SANDBOX"
}
trap cleanup EXIT

fail_tc() {
  local tc="$1" msg="$2"
  printf 'FAIL %s: %s\n' "$tc" "$msg"
  FAIL=$(( FAIL + 1 ))
}

pass_tc() {
  local tc="$1"
  printf 'PASS %s\n' "$tc"
  PASS=$(( PASS + 1 ))
}

# Create sandbox directory structure mirroring packages/
PKGS="$SANDBOX/packages/infrastructure/test_target"
mkdir -p "$PKGS"
APPS="$SANDBOX/apps/cli"
mkdir -p "$APPS"
TESTS="$SANDBOX/packages/infrastructure/tests"
mkdir -p "$TESTS"

# Override PROJECT_DIR to point to sandbox
export CLAUDE_PROJECT_DIR="$SANDBOX"

# Ensure log dir exists
mkdir -p "$SANDBOX/agent-workspace/memory"
mkdir -p "$SANDBOX/human-workspace/notifications"

# Helper: run hook on a specific file (PostToolUse mode)
run_hook_on_file() {
  local filepath="$1"
  local payload
  payload="{\"file_path\": \"${filepath}\"}"
  printf '%s' "$payload" | bash "$HOOK" 2>/dev/null
  return $?
}

# Helper: run hook in Stop mode (no stdin)
run_hook_stop_mode() {
  bash "$HOOK" < /dev/null 2>/dev/null
  return $?
}

# Helper: check if violation was emitted for a rule
check_log_for_rule() {
  local rule="$1"
  grep -q "$rule" "$SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null
  return $?
}

# Helper: reset log between tests
reset_log() {
  rm -f "$SANDBOX/agent-workspace/memory/.session-hooks.log"
  # Also clear markers to force re-scan
  find "$SANDBOX/agent-workspace/memory" -name '.aw-marker-*' -delete 2>/dev/null || true
}

# ============================================================
# TC1 — AW-R1 fires on bare open(path,'w') + write() in production
# ============================================================
reset_log
cat > "$PKGS/tc1_bad_write.py" << 'PYEOF'
import json

def save_state(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(json.dumps(data))
PYEOF

run_hook_on_file "$PKGS/tc1_bad_write.py"
if check_log_for_rule "AW-R1"; then
  pass_tc "TC1: AW-R1 fires on bare open(path,'w') + write()"
else
  fail_tc "TC1" "AW-R1 should have fired on bare open(path,'w') + write()"
fi

# ============================================================
# TC2 — No fire for atomic open().write() with os.replace
# ============================================================
reset_log
cat > "$PKGS/tc2_atomic_open.py" << 'PYEOF'
import os

def save_state_atomic(path, content):
    tmp = path + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        f.write(content)
    os.replace(tmp, path)
PYEOF

run_hook_on_file "$PKGS/tc2_atomic_open.py"
if check_log_for_rule "AW-R1"; then
  fail_tc "TC2" "AW-R1 should NOT fire when os.replace follows within 10 lines"
else
  pass_tc "TC2: no fire for open()+write() followed by os.replace()"
fi

# ============================================================
# TC3 — AW-R2 fires on Path.write_text on .md file
# ============================================================
reset_log
cat > "$PKGS/tc3_write_text.py" << 'PYEOF'
from pathlib import Path

def write_log(path, content):
    Path(path + '/log.md').write_text(content, encoding='utf-8')
PYEOF

run_hook_on_file "$PKGS/tc3_write_text.py"
if check_log_for_rule "AW-R2"; then
  pass_tc "TC3: AW-R2 fires on Path.write_text on .md file"
else
  fail_tc "TC3" "AW-R2 should fire on Path.write_text on .md file"
fi

# ============================================================
# TC4 — No fire for atomic write_text via .tmp path
# ============================================================
reset_log
cat > "$PKGS/tc4_atomic_write_text.py" << 'PYEOF'
from pathlib import Path

def write_log_atomic(path):
    content = 'new entry'
    tmp = Path(path + '/log.md.tmp')
    tmp.write_text(content, encoding='utf-8')
    tmp.replace(path + '/log.md')
PYEOF

run_hook_on_file "$PKGS/tc4_atomic_write_text.py"
if check_log_for_rule "AW-R2"; then
  fail_tc "TC4" "AW-R2 should NOT fire on .tmp path write_text"
else
  pass_tc "TC4: no fire for atomic .tmp write_text + replace"
fi

# ============================================================
# TC5 — AW-R1 fires on append mode open(path,'a')
# ============================================================
reset_log
cat > "$PKGS/tc5_append_mode.py" << 'PYEOF'
def append_record(path, record):
    with open(path, 'a', encoding='utf-8') as f:
        f.write(record + '\n')
PYEOF

run_hook_on_file "$PKGS/tc5_append_mode.py"
if check_log_for_rule "AW-R1"; then
  pass_tc "TC5: AW-R1 fires on append mode open(path,'a')"
else
  fail_tc "TC5" "AW-R1 should fire on open(path,'a') without atomic replace"
fi

# ============================================================
# TC6 — No cross-fire on W0-2 patterns (random.random)
# ============================================================
reset_log
cat > "$PKGS/tc6_w02_pattern.py" << 'PYEOF'
import random

def pick_random():
    return random.random()
PYEOF

run_hook_on_file "$PKGS/tc6_w02_pattern.py"
# W0-3 hook should NOT fire on random.random() — that's W0-2's job
if check_log_for_rule "AW-R"; then
  fail_tc "TC6" "atomic-write-check should NOT fire on random.random() (W0-2 pattern)"
else
  pass_tc "TC6: no cross-fire on W0-2 random.random() pattern"
fi

# ============================================================
# TC7 — No fire for open() inside if __name__ == '__main__'
# ============================================================
reset_log
cat > "$PKGS/tc7_main_block.py" << 'PYEOF'
def normal_func():
    pass

if __name__ == '__main__':
    with open('/tmp/output.json', 'w') as f:
        f.write('{}')
PYEOF

run_hook_on_file "$PKGS/tc7_main_block.py"
if check_log_for_rule "AW-R1"; then
  fail_tc "TC7" "AW-R1 should NOT fire inside if __name__ == '__main__' block"
else
  pass_tc "TC7: no fire for open() inside __main__ block"
fi

# ============================================================
# TC8 — No fire in test files (test_*.py)
# ============================================================
reset_log
cat > "$TESTS/test_write_fixture.py" << 'PYEOF'
from pathlib import Path

def test_writes_state(tmp_path):
    p = tmp_path / 'state.json'
    p.write_text('{}')
PYEOF

run_hook_on_file "$TESTS/test_write_fixture.py"
if check_log_for_rule "AW-R"; then
  fail_tc "TC8" "hook should NOT fire on test_*.py files (test allow-list)"
else
  pass_tc "TC8: no fire in test files (test allow-list)"
fi

# ============================================================
# TC9 — No fire with inline # atomic-write-ok: marker
# ============================================================
reset_log
cat > "$PKGS/tc9_marker.py" << 'PYEOF'
from pathlib import Path

def write_rotated(path, content):
    Path(path + '/app.log').write_text(content, encoding='utf-8')  # atomic-write-ok: log file rotation handled externally by logrotate
PYEOF

run_hook_on_file "$PKGS/tc9_marker.py"
if check_log_for_rule "AW-R2"; then
  fail_tc "TC9" "AW-R2 should NOT fire with inline # atomic-write-ok: marker"
else
  pass_tc "TC9: no fire with inline atomic-write-ok marker"
fi

# ============================================================
# TC10 — AW-R3 fires on json.dump(obj, open(path,'w')) combined pattern
# ============================================================
reset_log
cat > "$PKGS/tc10_json_dump.py" << 'PYEOF'
import json

def dump_state(path, data):
    json.dump(data, open(path + '/state.json', 'w'))
PYEOF

run_hook_on_file "$PKGS/tc10_json_dump.py"
if check_log_for_rule "AW-R3"; then
  pass_tc "TC10: AW-R3 fires on json.dump combined with open()"
else
  fail_tc "TC10" "AW-R3 should fire on json.dump(obj, open(path,'w'))"
fi

# ============================================================
# TC11 — AW-R4 fires WARN on write_text in apps/cli persistence zone
# ============================================================
reset_log
cat > "$APPS/tc11_csv_write.py" << 'PYEOF'
from pathlib import Path

def write_report(base_dir, content):
    Path(base_dir + '/outputs/report.pkl').write_text(content)
PYEOF

run_hook_on_file "$APPS/tc11_csv_write.py"
if check_log_for_rule "AW-R4"; then
  pass_tc "TC11: AW-R4 fires WARN on write_text in persistence zone"
else
  fail_tc "TC11" "AW-R4 should fire WARN on write_text in persistence zone (outputs/)"
fi

# ============================================================
# TC12 — No fire for legitimate atomic write (Path.tmp then replace)
# ============================================================
reset_log
cat > "$PKGS/tc12_full_atomic.py" << 'PYEOF'
from pathlib import Path

def save_state_fully_atomic(path, content):
    target = Path(path) / 'state.json'
    tmp = Path(path) / 'state.json.tmp'
    tmp.write_text(content, encoding='utf-8')
    tmp.replace(target)
PYEOF

run_hook_on_file "$PKGS/tc12_full_atomic.py"
if check_log_for_rule "AW-R"; then
  fail_tc "TC12" "hook should NOT fire on full atomic .tmp + replace pattern"
else
  pass_tc "TC12: no fire for full atomic write_text + replace"
fi

# ============================================================
# TC13 — Edge: empty Python file (0 bytes)
# ============================================================
reset_log
printf '' > "$PKGS/tc13_empty.py"
run_hook_on_file "$PKGS/tc13_empty.py"
if check_log_for_rule "AW-R"; then
  fail_tc "TC13" "hook should NOT fire on empty Python file"
else
  pass_tc "TC13: no fire on empty Python file (degenerate)"
fi

# ============================================================
# TC14 — Edge: file with no write operations
# ============================================================
reset_log
cat > "$PKGS/tc14_no_writes.py" << 'PYEOF'
def compute(x, y):
    return x + y

class Processor:
    def process(self, data):
        return [d * 2 for d in data]
PYEOF

run_hook_on_file "$PKGS/tc14_no_writes.py"
if check_log_for_rule "AW-R"; then
  fail_tc "TC14" "hook should NOT fire on file with no write operations"
else
  pass_tc "TC14: no fire on file with no write operations"
fi

# ============================================================
# TC15 — Regression-floor: hook on non-existent file → RC=0, no false fire
# Use a dedicated clean sandbox to avoid Stop-mode re-scan of prior test fixtures
# ============================================================
TC15_SANDBOX="$(mktemp -d)"
mkdir -p "$TC15_SANDBOX/agent-workspace/memory" "$TC15_SANDBOX/human-workspace/notifications"
mkdir -p "$TC15_SANDBOX/packages/infra"
export CLAUDE_PROJECT_DIR="$TC15_SANDBOX"

# Non-existent .py file inside packages/ (path contains packages/ so PostToolUse mode fires)
FAKE_FILE="$TC15_SANDBOX/packages/infra/does_not_exist.py"
tc15_rc=0
printf '%s' "{\"file_path\": \"${FAKE_FILE}\"}" | bash "$HOOK" 2>/dev/null || tc15_rc=$?

# Restore SANDBOX as PROJECT_DIR
export CLAUDE_PROJECT_DIR="$SANDBOX"

if [ "$tc15_rc" -ne 0 ]; then
  fail_tc "TC15" "hook should exit RC=0 even on non-existent file (best-effort)"
else
  if grep -q "AW-R" "$TC15_SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null; then
    fail_tc "TC15" "hook should NOT fire on non-existent file"
  else
    pass_tc "TC15: RC=0 and no false fire on non-existent file path"
  fi
fi
rm -rf "$TC15_SANDBOX"

# ============================================================
# TC-HOISTED — D1 S346 plan-023: hoisted marker cleanup runs ONCE per invocation
# (was per-file inside claim_file_slot; now before the scan loop)
# ============================================================
# Verify: find-delete NO LONGER appears inside claim_file_slot() body in the hook source
# Use $HOOK (absolute path set at top of fire-test) — not CLAUDE_PROJECT_DIR (may be sandbox).
HOOK_SRC="$(cat "$HOOK" 2>/dev/null)"
CLAIM_BODY="$(printf '%s' "$HOOK_SRC" | awk '/^claim_file_slot\(\)/,/^\}/' 2>/dev/null)"
# Check for EXECUTABLE find command (not comments) — grep for non-comment lines with find -delete
if printf '%s' "$CLAIM_BODY" | grep -v '^[[:space:]]*#' | grep -q 'find.*-delete'; then
  fail_tc "TC-HOISTED" "find-delete executable command should NOT be inside claim_file_slot() body (D1 hoist failed)"
else
  pass_tc "TC-HOISTED: find-delete is NOT inside claim_file_slot() body (D1 hoist verified)"
fi

# Verify: at least ONE find-delete appears at module level (hoisted location)
if echo "$HOOK_SRC" | grep -q 'find.*aw-marker.*-delete'; then
  pass_tc "TC-HOISTED: hoisted find-delete for .aw-marker-* found in hook source (D1)"
else
  fail_tc "TC-HOISTED" "hoisted find-delete for .aw-marker-* NOT found in hook source"
fi

# ============================================================
# TC-COOLDOWN — D2 S346 plan-023: cool-down marker suppresses redundant Stop-mode sweeps
# ============================================================
COOLDOWN_SANDBOX="$(mktemp -d)"
mkdir -p "$COOLDOWN_SANDBOX/agent-workspace/memory" "$COOLDOWN_SANDBOX/human-workspace/notifications"
mkdir -p "$COOLDOWN_SANDBOX/packages/test_cooldown"

# Create >100 dummy .py files so SCAN_FILES exceeds the >100 heuristic for marker write.
# D2 cool-down marker only written when SCAN_FILES > 100 (Stop-mode full-tree sweep heuristic).
for i in $(seq 1 105); do
  printf 'def compute_%d(x): return x + %d\n' "$i" "$i" > "$COOLDOWN_SANDBOX/packages/test_cooldown/ok_${i}.py"
done

export CLAUDE_PROJECT_DIR="$COOLDOWN_SANDBOX"
COOLDOWN_MARKER="$COOLDOWN_SANDBOX/agent-workspace/memory/.aw-last-full-sweep"
COOLDOWN_LOG="$COOLDOWN_SANDBOX/agent-workspace/memory/.session-hooks.log"

# Run once (full sweep, no cooldown marker) — should write cooldown marker
rm -f "$COOLDOWN_MARKER"
bash "$HOOK" < /dev/null > /dev/null 2>/dev/null || true
if [ -f "$COOLDOWN_MARKER" ]; then
  pass_tc "TC-COOLDOWN: cooldown marker created after first full sweep (D2)"
else
  fail_tc "TC-COOLDOWN" "cooldown marker NOT created after first full sweep"
fi

# Run again immediately — should SKIP-COOLDOWN
bash "$HOOK" < /dev/null > /dev/null 2>/dev/null || true
if grep -q "SKIP-COOLDOWN" "$COOLDOWN_LOG" 2>/dev/null; then
  pass_tc "TC-COOLDOWN: SKIP-COOLDOWN logged on second immediate Stop-mode invocation (D2)"
else
  fail_tc "TC-COOLDOWN" "SKIP-COOLDOWN not logged on second invocation (cooldown not firing)"
fi

# Backdate marker to 700s ago — should NOT skip
touch -d "700 seconds ago" "$COOLDOWN_MARKER" 2>/dev/null || \
  touch -t "$(date -d '12 minutes ago' +%Y%m%d%H%M 2>/dev/null || echo '202505010000')" "$COOLDOWN_MARKER" 2>/dev/null || true
rm -f "$COOLDOWN_LOG"
bash "$HOOK" < /dev/null > /dev/null 2>/dev/null || true
if grep -q "SKIP-COOLDOWN" "$COOLDOWN_LOG" 2>/dev/null; then
  fail_tc "TC-COOLDOWN" "SKIP-COOLDOWN should NOT fire when marker is 700s old (exceeds 600s threshold)"
else
  pass_tc "TC-COOLDOWN: full sweep runs when cooldown marker is expired (D2 threshold correct)"
fi

# PostToolUse single-file audit bypasses cooldown (EDITED_FILE populated)
touch "$COOLDOWN_MARKER" 2>/dev/null || true  # fresh cooldown
rm -f "$COOLDOWN_LOG"
FAKE_PY="$COOLDOWN_SANDBOX/packages/test_cooldown/edited.py"
cat > "$FAKE_PY" << 'PYEOF'
def func(): pass
PYEOF
POSIX_FILE="$(printf '%s' "$FAKE_PY" | sed 's|\\|/|g')"
printf '{"file_path": "%s"}' "$POSIX_FILE" | bash "$HOOK" > /dev/null 2>/dev/null || true
if grep -q "SKIP-COOLDOWN" "$COOLDOWN_LOG" 2>/dev/null; then
  fail_tc "TC-COOLDOWN" "PostToolUse single-file audit should bypass cooldown"
else
  pass_tc "TC-COOLDOWN: PostToolUse single-file audit bypasses cooldown (D2 AQ-7 compliance)"
fi

export CLAUDE_PROJECT_DIR="$SANDBOX"
rm -rf "$COOLDOWN_SANDBOX"

# ============================================================
# Results
# ============================================================
TOTAL=$(( PASS + FAIL ))
printf '\n=== atomic-write-check firing-test: PASS=%d FAIL=%d (%d TCs) ===\n' "$PASS" "$FAIL" "$TOTAL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
