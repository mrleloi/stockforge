#!/usr/bin/env bash
# path-safety-check-fire-test.sh — Firing-test for path-safety-check.sh hook.
#
# Verifies the W0-5 hook enforces all 5 path-safety invariants:
#   P1 (sandbox/traversal), P1b (domain-absolute), P2/P3 (user-supplied),
#   P4 (write-zone), P5 (UNC cross-cutting)
#
# SPAWN-CONTEXT: positional-arg
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
# ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
# Hook: scripts/hooks/path-safety-check.sh
#
# ≥15 TC minimum (5 invariants × ≥3 cases each); 18 TC implemented.
# Exit 0 if all PASS; exit 1 on any FAIL.
set -uo pipefail

HOOK="${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/path-safety-check.sh"
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

# Set up sandbox directory structure
INFRA="$SANDBOX/packages/infrastructure/file_tools"
DOMAIN="$SANDBOX/packages/domain/observation_lifecycle"
APPS="$SANDBOX/apps/cli"
mkdir -p "$INFRA" "$DOMAIN" "$APPS"
mkdir -p "$SANDBOX/agent-workspace/memory" "$SANDBOX/human-workspace/notifications"

export CLAUDE_PROJECT_DIR="$SANDBOX"

run_hook_on_file() {
  local filepath="$1"
  printf '%s' "{\"file_path\": \"${filepath}\"}" | bash "$HOOK" 2>/dev/null
  return $?
}

check_log_for_rule() {
  local rule="$1"
  grep -q "$rule" "$SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null
  return $?
}

reset_state() {
  rm -f "$SANDBOX/agent-workspace/memory/.session-hooks.log"
  find "$SANDBOX/agent-workspace/memory" -name '.psafety-marker-*' -delete 2>/dev/null || true
}

# ============================================================
# P1 — Sandbox/Traversal (3 cases)
# ============================================================

# TC1 — P1 fires on Path('/usr/local/../etc/passwd') literal
reset_state
cat > "$INFRA/tc1_traversal.py" << 'PYEOF'
from pathlib import Path

def read_config():
    p = Path('/usr/local/../etc/passwd')
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc1_traversal.py"
if check_log_for_rule "P1-TRAVERSAL"; then
  pass_tc "TC1: P1 fires on Path('/usr/local/../etc/passwd') literal"
else
  fail_tc "TC1" "P1-TRAVERSAL should fire on Path() with '..' literal"
fi

# TC2 — P1 fires on Path('../foo') in production
reset_state
cat > "$INFRA/tc2_dotdot.py" << 'PYEOF'
from pathlib import Path

def load_config(base):
    return Path('../foo/config.json').read_text()
PYEOF
run_hook_on_file "$INFRA/tc2_dotdot.py"
if check_log_for_rule "P1-TRAVERSAL"; then
  pass_tc "TC2: P1 fires on Path('../foo') literal"
else
  fail_tc "TC2" "P1-TRAVERSAL should fire on Path('../foo') with '..' traversal"
fi

# TC3 — No fire when safe_path wraps the path
reset_state
cat > "$INFRA/tc3_safe_wrap.py" << 'PYEOF'
from pathlib import Path
from packages._shared.path_safety import safe_path

def load_config(user_input, workdir):
    p = safe_path(user_input, workdir)
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc3_safe_wrap.py"
if check_log_for_rule "P1"; then
  fail_tc "TC3" "P1 should NOT fire when safe_path wrapper is used"
else
  pass_tc "TC3: no P1 fire when safe_path wrapper is used"
fi

# ============================================================
# P1b — Absolute path literal in domain layer (3 cases)
# ============================================================

# TC4 — P1b fires on Path('/var/log/stockforge.log') in domain
reset_state
cat > "$DOMAIN/tc4_abs_in_domain.py" << 'PYEOF'
from pathlib import Path

class ObservationRepository:
    def load(self):
        log = Path('/var/log/stockforge.log')
        return log.read_text()
PYEOF
run_hook_on_file "$DOMAIN/tc4_abs_in_domain.py"
if check_log_for_rule "P1b-DOMAIN-ABS"; then
  pass_tc "TC4: P1b fires on absolute path literal in domain layer"
else
  fail_tc "TC4" "P1b-DOMAIN-ABS should fire on Path('/var/log/...') in domain layer"
fi

# TC5 — P1b fires on Windows absolute path in domain
reset_state
cat > "$DOMAIN/tc5_win_abs.py" << 'PYEOF'
from pathlib import Path

def get_data():
    p = Path('C:\\Users\\stockforge\\data.json')
    return p.read_text()
PYEOF
run_hook_on_file "$DOMAIN/tc5_win_abs.py"
if check_log_for_rule "P1b-DOMAIN-ABS"; then
  pass_tc "TC5: P1b fires on Windows absolute path in domain"
else
  fail_tc "TC5" "P1b-DOMAIN-ABS should fire on Path('C:\\\\...') in domain layer"
fi

# TC6 — No P1b fire for same absolute path in infrastructure (allowed)
reset_state
cat > "$INFRA/tc6_abs_in_infra.py" << 'PYEOF'
from pathlib import Path

def get_log_path():
    # Infrastructure is allowed to use concrete paths
    return Path('/var/log/stockforge.log')
PYEOF
run_hook_on_file "$INFRA/tc6_abs_in_infra.py"
if check_log_for_rule "P1b-DOMAIN-ABS"; then
  fail_tc "TC6" "P1b should NOT fire in infrastructure layer (only domain is strict)"
else
  pass_tc "TC6: no P1b fire for absolute path in infrastructure (allowed)"
fi

# ============================================================
# P2/P3 — User-supplied path without safe_*_path (3 cases)
# ============================================================

# TC7 — P2 fires on Path(sys.argv[1]) without wrapper
reset_state
cat > "$APPS/tc7_argv_unsafe.py" << 'PYEOF'
import sys
from pathlib import Path

def main():
    p = Path(sys.argv[1])
    data = p.read_text()
PYEOF
run_hook_on_file "$APPS/tc7_argv_unsafe.py"
if check_log_for_rule "P2P3-UNSANITIZED"; then
  pass_tc "TC7: P2/P3 fires on Path(sys.argv[1]) without safe wrapper"
else
  fail_tc "TC7" "P2P3-UNSANITIZED should fire on Path(sys.argv[1]) without wrapper"
fi

# TC8 — P2 fires on Path(os.environ.get('USER_INPUT'))
reset_state
cat > "$APPS/tc8_env_unsafe.py" << 'PYEOF'
import os
from pathlib import Path

def load():
    p = Path(os.environ.get('USER_FILE_PATH', ''))
    return p.read_text()
PYEOF
run_hook_on_file "$APPS/tc8_env_unsafe.py"
if check_log_for_rule "P2P3-UNSANITIZED"; then
  pass_tc "TC8: P2/P3 fires on Path(os.environ.get()) without safe wrapper"
else
  fail_tc "TC8" "P2P3-UNSANITIZED should fire on Path(os.environ.get())"
fi

# TC9 — No fire when safe_user_path wraps sys.argv
reset_state
cat > "$APPS/tc9_safe_argv.py" << 'PYEOF'
import sys
from packages._shared.path_safety import safe_user_path

def main():
    p = safe_user_path(sys.argv[1])
    data = p.read_text()
PYEOF
run_hook_on_file "$APPS/tc9_safe_argv.py"
if check_log_for_rule "P2P3-UNSANITIZED"; then
  fail_tc "TC9" "P2/P3 should NOT fire when safe_user_path wraps sys.argv"
else
  pass_tc "TC9: no P2/P3 fire when safe_user_path wraps the path"
fi

# ============================================================
# P4 — Write outside allowed zone (3 cases)
# ============================================================

# TC10 — P4 fires on write_text to /tmp (not allowed zone)
reset_state
cat > "$INFRA/tc10_tmp_write.py" << 'PYEOF'
from pathlib import Path

def write_temp(content):
    Path('/tmp/foo.json').write_text(content)
PYEOF
run_hook_on_file "$INFRA/tc10_tmp_write.py"
if check_log_for_rule "P4-WRITE-ZONE"; then
  pass_tc "TC10: P4 fires on write_text to /tmp (not in allowed zone)"
else
  fail_tc "TC10" "P4-WRITE-ZONE should fire on write to /tmp path"
fi

# TC11 — No P4 fire for write to outputs/ (allowed persistence zone)
reset_state
cat > "$INFRA/tc11_outputs_write.py" << 'PYEOF'
from pathlib import Path

def export(content):
    Path('outputs/state.json').write_text(content)
PYEOF
run_hook_on_file "$INFRA/tc11_outputs_write.py"
if check_log_for_rule "P4-WRITE-ZONE"; then
  fail_tc "TC11" "P4 should NOT fire for write to outputs/ (allowed zone)"
else
  pass_tc "TC11: no P4 fire for write to outputs/ (allowed zone)"
fi

# TC12 — No P4 fire for write to agent-workspace/memory (allowed zone)
reset_state
cat > "$INFRA/tc12_memory_write.py" << 'PYEOF'
from pathlib import Path

def write_observation(content):
    Path('agent-workspace/memory/observations/foo.md').write_text(content)
PYEOF
run_hook_on_file "$INFRA/tc12_memory_write.py"
if check_log_for_rule "P4-WRITE-ZONE"; then
  fail_tc "TC12" "P4 should NOT fire for write to agent-workspace/memory/ (allowed zone)"
else
  pass_tc "TC12: no P4 fire for write to agent-workspace/memory/ (allowed zone)"
fi

# ============================================================
# P5 — UNC path rejection (3 cases)
# ============================================================

# TC13 — P5 fires on Windows UNC '\\server\share\file'
reset_state
cat > "$INFRA/tc13_win_unc.py" << 'PYEOF'
from pathlib import Path

def load_remote():
    p = Path('\\\\server\\share\\file.json')
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc13_win_unc.py"
if check_log_for_rule "P5-UNC"; then
  pass_tc "TC13: P5 fires on Windows UNC path literal"
else
  fail_tc "TC13" "P5-UNC should fire on Path('\\\\\\\\server\\\\share\\\\file')"
fi

# TC14 — P5 fires on POSIX UNC '//server/share/file'
reset_state
cat > "$INFRA/tc14_posix_unc.py" << 'PYEOF'
from pathlib import Path

def load_nfs():
    p = Path('//server/share/file.json')
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc14_posix_unc.py"
if check_log_for_rule "P5-UNC"; then
  pass_tc "TC14: P5 fires on POSIX UNC path //server/share"
else
  fail_tc "TC14" "P5-UNC should fire on Path('//server/share/file')"
fi

# TC15 — P5 fires on Windows extended-length path '\\?\C:\foo'
reset_state
cat > "$INFRA/tc15_extended.py" << 'PYEOF'
from pathlib import Path

def load_extended():
    p = Path('\\\\?\\C:\\foo\\bar.txt')
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc15_extended.py"
if check_log_for_rule "P5-UNC"; then
  pass_tc "TC15: P5 fires on Windows extended-length path (\\\\?\\...)"
else
  fail_tc "TC15" "P5-UNC should fire on Path('\\\\\\\\?\\\\C:\\\\...')"
fi

# ============================================================
# Allow-list and edge cases (3 cases)
# ============================================================

# TC16 — No fire with inline # path-safety-ok: marker
reset_state
cat > "$INFRA/tc16_marker.py" << 'PYEOF'
from pathlib import Path

def load_unc():
    p = Path('//server/share/file.json')  # path-safety-ok: explicit UNC for windows-only build script
    return p.read_text()
PYEOF
run_hook_on_file "$INFRA/tc16_marker.py"
if check_log_for_rule "P5-UNC"; then
  fail_tc "TC16" "P5 should NOT fire when # path-safety-ok: inline marker is present"
else
  pass_tc "TC16: no fire with inline path-safety-ok marker"
fi

# TC17 — Edge: empty Python file → no fire
reset_state
printf '' > "$INFRA/tc17_empty.py"
run_hook_on_file "$INFRA/tc17_empty.py"
if check_log_for_rule "P[0-9]"; then
  fail_tc "TC17" "hook should NOT fire on empty Python file"
else
  pass_tc "TC17: no fire on empty Python file (degenerate)"
fi

# TC18 — Regression-floor: hook on non-existent file → RC=0
reset_state
TC18_SANDBOX="$(mktemp -d)"
mkdir -p "$TC18_SANDBOX/packages/infra" "$TC18_SANDBOX/agent-workspace/memory" "$TC18_SANDBOX/human-workspace/notifications"
export CLAUDE_PROJECT_DIR="$TC18_SANDBOX"

FAKE_FILE="$TC18_SANDBOX/packages/infra/does_not_exist.py"
tc18_rc=0
printf '%s' "{\"file_path\": \"${FAKE_FILE}\"}" | bash "$HOOK" 2>/dev/null || tc18_rc=$?

export CLAUDE_PROJECT_DIR="$SANDBOX"

if [ "$tc18_rc" -ne 0 ]; then
  fail_tc "TC18" "hook should exit RC=0 even on non-existent file (best-effort)"
else
  if grep -q "P[0-9]" "$TC18_SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null; then
    fail_tc "TC18" "hook should NOT fire on non-existent file"
  else
    pass_tc "TC18: RC=0 and no false fire on non-existent file path"
  fi
fi
rm -rf "$TC18_SANDBOX"

# ============================================================
# TC19 — S341 D1: content-hash dedup: level:WARN frontmatter + mtime unchanged on 2nd run
# ============================================================
reset_state
cat > "$INFRA/tc19_traversal.py" << 'PYEOF'
import os
def load(p):
    return open(os.path.join("../etc", p)).read()
PYEOF
run_hook_on_file "$INFRA/tc19_traversal.py"
NOTIF="$SANDBOX/human-workspace/notifications/path-safety-warn.md"
# Verify level:WARN frontmatter
LVL="$(head -10 "$NOTIF" 2>/dev/null | grep -m1 '^level:' | sed 's/^level:[[:space:]]*//' | tr -d '[:space:]' || true)"
if [ "$LVL" = "WARN" ]; then
  pass_tc "TC19a: level:WARN frontmatter present in path-safety-warn.md"
else
  fail_tc "TC19a" "expected level:WARN in path-safety-warn.md, got '$LVL'"
fi
# Verify mtime unchanged on 2nd run (content-hash dedup)
if [ -f "$NOTIF" ]; then
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  sleep 1
  run_hook_on_file "$INFRA/tc19_traversal.py"
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    pass_tc "TC19b: mtime unchanged on 2nd run (content-hash dedup fired)"
  else
    fail_tc "TC19b" "mtime changed on 2nd run with identical path-safety content: mtime1=$MTIME1 mtime2=$MTIME2"
  fi
else
  fail_tc "TC19b" "notification not found for mtime check"
fi

# ============================================================
# Results
# ============================================================
TOTAL=$(( PASS + FAIL ))
printf '\n=== path-safety-check firing-test: PASS=%d FAIL=%d (%d TCs) ===\n' "$PASS" "$FAIL" "$TOTAL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
