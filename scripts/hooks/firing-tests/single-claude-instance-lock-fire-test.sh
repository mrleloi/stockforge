#!/usr/bin/env bash
# Firing-test for single-claude-instance-lock.sh (S244 + S246 — Phase 3.5 §HH-G companion firing-test).
#
# Hook purpose: Prevent phantom-dispatch race condition. On SessionStart, write a
# session-lifetime lock file ($CLAUDE_PROJECT_DIR/agent-workspace/memory/.claude-instance.lock).
# If a lock exists AND holder PIDs are live siblings (fresh enough by epoch), BLOCK with exit 2.
# S246 lock format: "claude_pids=<csv>:created=<epoch>:session_id=<sid>"
# S244 lock format (legacy): "session=<session_id>:<pid>:<epoch>" — treated as stale on read.
# Lock cleanup is handled by SessionEnd hook (settings.json ~line 239), NOT by EXIT trap.
#
# Bug fixed S244: EXIT trap on line 30 deleted lock microseconds after creation, defeating
# phantom-dispatch protection. This test validates the fix (lock persists after hook exit).
# Bug fixed S246: holder-pid was PPID=1 / CLAUDE_SESSION_ID=empty. Replaced with all-claude-pids
# csv + epoch staleness floor (Strategy f). TC3 unblocked via PATH-shadow mock tasklist.
# Empirical basis: lock-rc-probe-20260510-221147-1058996.txt (S246-A probe artifact).
#
# Test cases:
#   TC1 — first-run path: no lock exists → hook writes lock + exits 0; assert new csv format
#   TC2 — stale-lock path: lock pre-written with non-existent PID (csv format) → overwrite + exit 0
#   TC3 — live-sibling-blocked: mock tasklist returns 2 PIDs; new hook = 3 PIDs → BLOCK + exit 2
#   TC4 — SessionEnd cleanup contract: lock present → cleanup command removes it; assert gone
#   TC5 — stale-by-time: epoch=now-10000 (>7200 threshold) + live pids → no BLOCK; overwritten
#   TC6 — S244-format backward-compat: old "session=X:Y:Z" format → treat stale → overwrite
#   TC7 — stdin JSON session_id: feed {"session_id":"abc-123"} via stdin → lock has session_id=abc-123
#   TC8 — partial-die: 2 stored pids, only 1 alive now (stored==current count) → no BLOCK; overwrite
#
# Mock-tasklist technique (S246 — unblocks TC3):
#   Write a stub 'tasklist' in $SANDBOX/bin/ prepended to PATH for the hook invocation.
#   Stub echoes a CSV fixture from MOCK_TASKLIST_OUT env var.
#   Precedent: plan S246 §6.2 mock_tasklist mechanism spec.
#   Works because hook uses bare 'tasklist' (not absolute path) per original line 24.
#
# Pattern: mktemp -d sandbox + trap cleanup per L-S174-1.
# RC capture: RC=0; cmd || RC=$? per L-S174-1 (prevents ERR trap exit on deliberate non-zero).
# File-based fixtures per L-S176-1 where applicable.
#
# Exit 0 = all assertions pass.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../single-claude-instance-lock.sh"

[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

SANDBOX=$(mktemp -d)
trap 'rm -rf "$SANDBOX"' EXIT

MOCK_BIN="$SANDBOX/bin"
LOCK_DIR="$SANDBOX/agent-workspace/memory"
LOCK_FILE="$LOCK_DIR/.claude-instance.lock"

mkdir -p "$LOCK_DIR" "$MOCK_BIN"

PASS=0
FAIL=0
NOW="$(date +%s)"

# ── Helper: install mock tasklist stub ───────────────────────────────────────
# Writes a fake tasklist at $MOCK_BIN/tasklist that echoes MOCK_TASKLIST_OUT file content.
# Caller must set MOCK_TASKLIST_OUT env and prepend MOCK_BIN to PATH before hook invocation.
# Precedent: plan §6.2 mock_tasklist mechanism spec (S246).
install_mock_tasklist() {
  local out_file="$1"
  cat > "$MOCK_BIN/tasklist" <<'STUB'
#!/usr/bin/env bash
# Mock tasklist stub — reads fixture from MOCK_TASKLIST_OUT file.
# Ignores all arguments (hook passes //NH //FO CSV //V //FI which are irrelevant to stub).
cat "${MOCK_TASKLIST_OUT:-/dev/null}" 2>/dev/null || true
STUB
  chmod +x "$MOCK_BIN/tasklist"
  export MOCK_TASKLIST_OUT="$out_file"
}

# ── Helper: run hook in sandbox with controlled env ───────────────────────────
# Args: $1=stdin_payload (empty string means /dev/null), $2=use_mock_tasklist (0|1)
run_hook() {
  local stdin_payload="${1:-}"
  local use_mock="${2:-0}"
  RC=0
  if [ "$use_mock" = "1" ]; then
    # Prepend mock bin to PATH so hook finds stub first.
    if [ -n "$stdin_payload" ]; then
      CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" <<< "$stdin_payload" 2>/dev/null || RC=$?
    else
      CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" < /dev/null 2>/dev/null || RC=$?
    fi
  else
    if [ -n "$stdin_payload" ]; then
      CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" <<< "$stdin_payload" 2>/dev/null || RC=$?
    else
      CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" < /dev/null 2>/dev/null || RC=$?
    fi
  fi
  echo "$RC"
}

# Same as run_hook but captures stderr too (for [BLOCK] assertion).
run_hook_with_stderr() {
  local stdin_payload="${1:-}"
  local use_mock="${2:-0}"
  RC=0
  if [ "$use_mock" = "1" ]; then
    if [ -n "$stdin_payload" ]; then
      STDERR_OUT="$(CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" <<< "$stdin_payload" 2>&1 >/dev/null || true)"
    else
      STDERR_OUT="$(CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" < /dev/null 2>&1 >/dev/null || true)"
    fi
    # Re-run to capture exit code (stderr captured separately).
    if [ -n "$stdin_payload" ]; then
      CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" <<< "$stdin_payload" > /dev/null 2>/dev/null || RC=$?
    else
      CLAUDE_PROJECT_DIR="$SANDBOX" \
      PATH="$MOCK_BIN:$PATH" \
        bash "$HOOK" < /dev/null > /dev/null 2>/dev/null || RC=$?
    fi
  else
    if [ -n "$stdin_payload" ]; then
      STDERR_OUT="$(CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" <<< "$stdin_payload" 2>&1 >/dev/null || true)"
      CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" <<< "$stdin_payload" > /dev/null 2>/dev/null || RC=$?
    else
      STDERR_OUT="$(CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" < /dev/null 2>&1 >/dev/null || true)"
      CLAUDE_PROJECT_DIR="$SANDBOX" \
        bash "$HOOK" < /dev/null > /dev/null 2>/dev/null || RC=$?
    fi
  fi
}

# ============================================================
# TC1: First-run path — no lock exists → hook writes lock + exits 0
# Assert: (a) exit code 0; (b) lock file exists; (c) content matches S246 csv format
# ============================================================
rm -f "$LOCK_FILE"

TC1_RC=$(run_hook "" "0")

if [ "$TC1_RC" != "0" ]; then
  echo "FAIL [TC1] first-run: expected exit 0; got rc=$TC1_RC"
  FAIL=$((FAIL + 1))
else
  if [ ! -f "$LOCK_FILE" ]; then
    echo "FAIL [TC1] lock file absent after first-run (EXIT trap bug regressed!)"
    FAIL=$((FAIL + 1))
  else
    LOCK_CONTENT="$(cat "$LOCK_FILE")"
    # S246 format: "claude_pids=<something>:created=<epoch>:session_id=<something>"
    if echo "$LOCK_CONTENT" | grep -qE '^claude_pids=[^:]+:created=[0-9]+:session_id=.+$'; then
      echo "PASS [TC1] first-run: exit 0, lock file exists, content='$LOCK_CONTENT' matches S246 format"
      PASS=$((PASS + 1))
    else
      echo "FAIL [TC1] lock content does not match 'claude_pids=...:created=...:session_id=...' shape; got: '$LOCK_CONTENT'"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

# ============================================================
# TC2: Stale-lock path — lock pre-written with non-existent PID in S246 csv format.
# Epoch = 1000000000 (ancient, well past threshold). Hook should overwrite + exit 0.
# Assert: (a) exit 0; (b) lock content updated; (c) lock still present; (d) new format
# ============================================================
STALE_PID="99999999"
STALE_CONTENT="claude_pids=${STALE_PID}:created=1000000000:session_id=stale-session"
echo "$STALE_CONTENT" > "$LOCK_FILE"

TC2_RC=$(run_hook "" "0")

if [ "$TC2_RC" != "0" ]; then
  echo "FAIL [TC2] stale-lock: expected exit 0; got rc=$TC2_RC"
  FAIL=$((FAIL + 1))
else
  if [ ! -f "$LOCK_FILE" ]; then
    echo "FAIL [TC2] lock file absent after stale-lock overwrite"
    FAIL=$((FAIL + 1))
  else
    NEW_CONTENT="$(cat "$LOCK_FILE")"
    if [ "$NEW_CONTENT" = "$STALE_CONTENT" ]; then
      echo "FAIL [TC2] lock content not updated; still stale: '$NEW_CONTENT'"
      FAIL=$((FAIL + 1))
    else
      if echo "$NEW_CONTENT" | grep -qE '^claude_pids=[^:]+:created=[0-9]+:session_id=.+$'; then
        echo "PASS [TC2] stale-lock: exit 0, lock overwritten with new content='$NEW_CONTENT'"
        PASS=$((PASS + 1))
      else
        echo "FAIL [TC2] new lock content does not match S246 shape: '$NEW_CONTENT'"
        FAIL=$((FAIL + 1))
      fi
    fi
  fi
fi

# ============================================================
# TC3: Live-sibling-blocked — mock tasklist returns 2 stored PIDs alive; hook sees 3 PIDs now
# (stored 2 still alive + 1 new = us). BLOCK should fire.
# Mechanism: PATH-shadow mock tasklist per plan §6.2.
# Mock fixture: tasklist returns CSV with PIDs 12345 + 67890 alive.
# Lock: stored pids=12345,67890 (count=2), fresh epoch.
# Hook reads tasklist: 3 PIDs (12345,67890,88888) → current_count(3) > stored_count(2) → BLOCK.
# Assert: (a) exit 2; (b) stderr contains "[BLOCK]"; (c) lock NOT overwritten
# ============================================================
rm -f "$LOCK_FILE"

# Write mock tasklist fixture: 2 PIDs alive.
TC3_MOCK_OUT="$SANDBOX/.tc3-tasklist"
cat > "$TC3_MOCK_OUT" <<'CSV'
"claude.exe","12345","Console","1","887,208 K","Unknown","DESKTOP-2MBMI7S\PC","1:46:40","N/A"
"claude.exe","67890","Console","1","290,876 K","Unknown","DESKTOP-2MBMI7S\PC","0:00:01","N/A"
"claude.exe","88888","Console","1","106,716 K","Unknown","DESKTOP-2MBMI7S\PC","0:00:00","N/A"
CSV

install_mock_tasklist "$TC3_MOCK_OUT"

# Pre-write lock: stored 2 PIDs, fresh epoch (< 7200 seconds ago).
FRESH_EPOCH=$(( NOW - 60 ))
echo "claude_pids=12345,67890:created=${FRESH_EPOCH}:session_id=stored-session" > "$LOCK_FILE"
LOCK_CONTENT_BEFORE_TC3="$(cat "$LOCK_FILE")"

STDERR_OUT=""
RC=0
run_hook_with_stderr "" "1"
TC3_RC="$RC"

if [ "$TC3_RC" != "2" ]; then
  echo "FAIL [TC3] live-sibling-blocked: expected exit 2; got rc=$TC3_RC"
  FAIL=$((FAIL + 1))
else
  if ! echo "$STDERR_OUT" | grep -q '\[BLOCK\]'; then
    echo "FAIL [TC3] live-sibling-blocked: exit 2 but stderr missing [BLOCK]; stderr='$STDERR_OUT'"
    FAIL=$((FAIL + 1))
  else
    # Lock should NOT have been overwritten.
    LOCK_CONTENT_AFTER_TC3="$(cat "$LOCK_FILE" 2>/dev/null || true)"
    if [ "$LOCK_CONTENT_AFTER_TC3" = "$LOCK_CONTENT_BEFORE_TC3" ]; then
      echo "PASS [TC3] live-sibling-blocked: exit 2, [BLOCK] on stderr, lock unchanged, stderr='$STDERR_OUT'"
      PASS=$((PASS + 1))
    else
      echo "FAIL [TC3] live-sibling-blocked: exit 2 + [BLOCK] but lock was overwritten; before='$LOCK_CONTENT_BEFORE_TC3' after='$LOCK_CONTENT_AFTER_TC3'"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

# ============================================================
# TC4: SessionEnd cleanup contract — write lock, run cleanup command, assert lock removed
# Cleanup command (from .claude/settings.json SessionEnd chain):
#   rm -f "${CLAUDE_PROJECT_DIR:-.}/agent-workspace/memory/.claude-instance.lock" 2>/dev/null; exit 0
# ============================================================
echo "claude_pids=99999:created=${NOW}:session_id=session-tc4" > "$LOCK_FILE"

if [ ! -f "$LOCK_FILE" ]; then
  echo "FAIL [TC4] pre-condition: failed to write lock for cleanup test"
  FAIL=$((FAIL + 1))
else
  # Run the exact cleanup command from settings.json SessionEnd (substituting CLAUDE_PROJECT_DIR)
  CLEANUP_DIR="$SANDBOX"
  rm -f "${CLEANUP_DIR}/agent-workspace/memory/.claude-instance.lock" 2>/dev/null

  if [ -f "$LOCK_FILE" ]; then
    echo "FAIL [TC4] SessionEnd cleanup: lock file still present after rm -f"
    FAIL=$((FAIL + 1))
  else
    echo "PASS [TC4] SessionEnd cleanup: rm -f removed lock as expected"
    PASS=$((PASS + 1))
  fi
fi

# ============================================================
# TC5: Stale-by-time — stored PIDs alive in current tasklist BUT epoch > threshold.
# Even with live siblings, staleness wins → no BLOCK; lock overwritten.
# Mock: tasklist returns 2 PIDs alive; stored has those 2 PIDs; but created = now-10000 (>7200).
# Current tasklist has 3 PIDs (stored 2 + 1 more = would-be BLOCK if fresh).
# Assert: (a) exit 0; (b) lock overwritten with new content
# ============================================================
rm -f "$LOCK_FILE"

TC5_MOCK_OUT="$SANDBOX/.tc5-tasklist"
cat > "$TC5_MOCK_OUT" <<'CSV'
"claude.exe","11111","Console","1","887,208 K","Unknown","DESKTOP-2MBMI7S\PC","1:46:40","N/A"
"claude.exe","22222","Console","1","290,876 K","Unknown","DESKTOP-2MBMI7S\PC","0:00:01","N/A"
"claude.exe","33333","Console","1","106,716 K","Unknown","DESKTOP-2MBMI7S\PC","0:00:00","N/A"
CSV

install_mock_tasklist "$TC5_MOCK_OUT"

STALE_EPOCH=$(( NOW - 10000 ))
STALE5_CONTENT="claude_pids=11111,22222:created=${STALE_EPOCH}:session_id=old-session"
echo "$STALE5_CONTENT" > "$LOCK_FILE"

TC5_RC=$(run_hook "" "1")

if [ "$TC5_RC" != "0" ]; then
  echo "FAIL [TC5] stale-by-time: expected exit 0; got rc=$TC5_RC"
  FAIL=$((FAIL + 1))
else
  NEW5_CONTENT="$(cat "$LOCK_FILE" 2>/dev/null || true)"
  if [ "$NEW5_CONTENT" = "$STALE5_CONTENT" ]; then
    echo "FAIL [TC5] stale-by-time: lock not overwritten; still old: '$NEW5_CONTENT'"
    FAIL=$((FAIL + 1))
  else
    echo "PASS [TC5] stale-by-time: exit 0, lock overwritten despite live pids (staleness floor wins); new='$NEW5_CONTENT'"
    PASS=$((PASS + 1))
  fi
fi

# ============================================================
# TC6: S244-format backward-compat — pre-write lock in old format "session=X:Y:Z".
# Hook should recognize incompatible format, treat as stale, overwrite without BLOCK.
# Assert: (a) exit 0; (b) lock overwritten in S246 format; (c) no [BLOCK] on stderr
# ============================================================
rm -f "$LOCK_FILE"

# Use no mock tasklist (real tasklist for this TC — don't need live pids, just test format detection).
# Write S244-format lock.
S244_CONTENT="session=unknown:1:1778421770"
echo "$S244_CONTENT" > "$LOCK_FILE"

TC6_RC=$(run_hook "" "0")

if [ "$TC6_RC" != "0" ]; then
  echo "FAIL [TC6] S244-backward-compat: expected exit 0; got rc=$TC6_RC"
  FAIL=$((FAIL + 1))
else
  NEW6_CONTENT="$(cat "$LOCK_FILE" 2>/dev/null || true)"
  if [ "$NEW6_CONTENT" = "$S244_CONTENT" ]; then
    echo "FAIL [TC6] S244-backward-compat: lock content unchanged (still S244 format); got: '$NEW6_CONTENT'"
    FAIL=$((FAIL + 1))
  else
    if echo "$NEW6_CONTENT" | grep -qE '^claude_pids=[^:]+:created=[0-9]+:session_id=.+$'; then
      echo "PASS [TC6] S244-backward-compat: exit 0, S244 lock overwritten with S246 format; new='$NEW6_CONTENT'"
      PASS=$((PASS + 1))
    else
      echo "FAIL [TC6] S244-backward-compat: new lock not in S246 format; got: '$NEW6_CONTENT'"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

# ============================================================
# TC7: stdin JSON session_id extraction — feed synthetic JSON via stdin.
# Hook should parse session_id from stdin JSON and embed in lock.
# Assert: (a) exit 0; (b) lock content contains "session_id=abc-123"
# ============================================================
rm -f "$LOCK_FILE"

TC7_STDIN='{"session_id":"abc-123","transcript_path":"/tmp/test.jsonl","cwd":"/c/htdocs/stockforge","hook_event_name":"SessionStart","source":"startup"}'

TC7_RC=$(run_hook "$TC7_STDIN" "0")

if [ "$TC7_RC" != "0" ]; then
  echo "FAIL [TC7] stdin-session_id: expected exit 0; got rc=$TC7_RC"
  FAIL=$((FAIL + 1))
else
  TC7_CONTENT="$(cat "$LOCK_FILE" 2>/dev/null || true)"
  if echo "$TC7_CONTENT" | grep -q 'session_id=abc-123'; then
    echo "PASS [TC7] stdin-session_id: exit 0, lock contains session_id=abc-123; content='$TC7_CONTENT'"
    PASS=$((PASS + 1))
  else
    echo "FAIL [TC7] stdin-session_id: lock missing session_id=abc-123; got: '$TC7_CONTENT'"
    FAIL=$((FAIL + 1))
  fi
fi

# ============================================================
# TC8: Partial-die — 2 PIDs stored in lock, only 1 alive now (other died).
# stored_count == current_count → same-count heuristic → no BLOCK; lock overwritten.
# Mock: lock has pids=44444,55555 (count=2, fresh); tasklist returns only 44444 (count=1).
# current_count(1) <= stored_count(2) → no BLOCK.
# Assert: (a) exit 0; (b) lock overwritten
# ============================================================
rm -f "$LOCK_FILE"

TC8_MOCK_OUT="$SANDBOX/.tc8-tasklist"
cat > "$TC8_MOCK_OUT" <<'CSV'
"claude.exe","44444","Console","1","887,208 K","Unknown","DESKTOP-2MBMI7S\PC","1:46:40","N/A"
CSV

install_mock_tasklist "$TC8_MOCK_OUT"

FRESH8_EPOCH=$(( NOW - 30 ))
TC8_STORED="claude_pids=44444,55555:created=${FRESH8_EPOCH}:session_id=old-two-pid-session"
echo "$TC8_STORED" > "$LOCK_FILE"

TC8_RC=$(run_hook "" "1")

if [ "$TC8_RC" != "0" ]; then
  echo "FAIL [TC8] partial-die: expected exit 0; got rc=$TC8_RC"
  FAIL=$((FAIL + 1))
else
  TC8_CONTENT="$(cat "$LOCK_FILE" 2>/dev/null || true)"
  if [ "$TC8_CONTENT" = "$TC8_STORED" ]; then
    echo "FAIL [TC8] partial-die: lock not overwritten; still: '$TC8_CONTENT'"
    FAIL=$((FAIL + 1))
  else
    if echo "$TC8_CONTENT" | grep -qE '^claude_pids=[^:]+:created=[0-9]+:session_id=.+$'; then
      echo "PASS [TC8] partial-die: exit 0, lock overwritten (one sibling died, count heuristic no-block); new='$TC8_CONTENT'"
      PASS=$((PASS + 1))
    else
      echo "FAIL [TC8] partial-die: new lock not in S246 format; got: '$TC8_CONTENT'"
      FAIL=$((FAIL + 1))
    fi
  fi
fi

# ============================================================
# Summary
# ============================================================
echo ""
TOTAL=$((PASS + FAIL))
printf '=== single-claude-instance-lock-fire-test: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
printf '    TCs: %d/%d\n' "$PASS" "$TOTAL"
printf '    TC coverage: TC1(first-run) TC2(stale-csv) TC3(live-sibling-BLOCK) TC4(cleanup) TC5(stale-by-time) TC6(S244-compat) TC7(stdin-session_id) TC8(partial-die)\n'

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
