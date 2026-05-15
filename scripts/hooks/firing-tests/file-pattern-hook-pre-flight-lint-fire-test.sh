#!/usr/bin/env bash
# file-pattern-hook-pre-flight-lint-fire-test.sh — companion firing-test per Phase 3.5 Hard Rule #2
# REAL-STATE-DERIVED fixtures per L-S176-1 (1)+(2)+(3):
#   - Each TC fixture mirrors actual file/dir naming used in production hooks
#   - TC4 reproduces D-039 Bug #1 pre-fix glob `D-*.md` against decisions/ with NNN-*.md naming
#   - TC7 reproduces D-039 Bug #4 pre-fix anchor `^### L-S` against agent-notes.md inline-card format
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/file-pattern-hook-pre-flight-lint.sh"
TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
HOOKS_TEST_DIR="$PROJECT_DIR/scripts/hooks"
DECISIONS_DIR="$MEM_DIR/decisions"
LOG="$MEM_DIR/.session-hooks.log"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"
mkdir -p "$MEM_DIR" "$HOOKS_TEST_DIR" "$DECISIONS_DIR" "$NOTIF_DIR"

# Real-state-derived seed: agent-notes.md uses inline-card format `### YYYY-MM-DD (S<N>): ... — L-S<N>-<M>`
cat > "$MEM_DIR/agent-notes.md" <<'EOF'
# Agent Notes

## Recent Rules (digest; last 5)

### 2026-05-07 (S179): D-039 file-pattern hook batch fix — L-S179-1

Real-state validation before file-pattern hook ship.

### 2026-05-07 (S176): Real-state validation rule — L-S176-1

File-pattern hooks must validate against real-state inventory.
EOF

# Real-state-derived seed: mistake-log.md uses table-row digest
cat > "$MEM_DIR/mistake-log.md" <<'EOF'
# Mistake Log

## Mistake Digest Index

| ID | Session | Severity | Summary | Archive line |
|---|---|---|---|---|
| M-S176-1 | S176 | high | HH-C.2 misfire | inline |
| M-S179-1 | S179 | medium | placeholder | inline |
EOF

# Real-state-derived seed: decisions/ uses NNN-*.md naming (D-*.md form is post-S179 backward-compat)
echo "test 030" > "$DECISIONS_DIR/030-test.md"
echo "test 031" > "$DECISIONS_DIR/031-test.md"
echo "test 032" > "$DECISIONS_DIR/032-test.md"

PASS=0
FAIL=0
PAYLOAD_STOP='{"hook_event_name":"Stop"}'
PAYLOAD_NONSTOP='{"hook_event_name":"PreToolUse","tool_name":"Read"}'

reset_state() {
  rm -f "$LOG" "$MEM_DIR"/.file-pattern-lint-fired-* 2>/dev/null || true
  rm -rf "$NOTIF_DIR" && mkdir -p "$NOTIF_DIR"
  rm -f "$HOOKS_TEST_DIR"/*.sh 2>/dev/null || true
}

run_lint() {
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>&1 || true
}

# TC1: Stop event → summary line in log
reset_state
cat > "$HOOKS_TEST_DIR/clean-hook.sh" <<'EOF'
#!/usr/bin/env bash
# Clean hook with no file-pattern signatures.
echo "no patterns here"
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC1-stop-summary: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC1-stop-summary: FAIL — summary line not emitted on Stop"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC2: Non-Stop event → no log entry written this turn
reset_state
cat > "$HOOKS_TEST_DIR/clean-hook.sh" <<'EOF'
#!/usr/bin/env bash
echo "no patterns"
EOF
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_NONSTOP" 2>&1 || true
if [ ! -s "$LOG" ] || ! grep -q 'file-pattern-lint summary' "$LOG" 2>/dev/null; then
  echo "  TC TC2-non-stop-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC2-non-stop-skip: FAIL — fired on non-Stop event"; FAIL=$((FAIL+1))
fi

# TC3: find -name with VALID glob → no violation (NNN-*.md matches real seed files)
reset_state
cat > "$HOOKS_TEST_DIR/sync-test.sh" <<'EOF'
#!/usr/bin/env bash
DECISIONS_DIR="$1"
ADR_COUNT=$(find "$DECISIONS_DIR" -maxdepth 1 -name '[0-9][0-9][0-9]-*.md' | wc -l)
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC3-find-valid-glob: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC3-find-valid-glob: FAIL — false positive on valid NNN-*.md glob"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC4 (D-039 Bug #1 PRE-FIX REPRO): find -name 'D-*.md' against real-state NNN-*.md naming → VIOLATION
reset_state
cat > "$HOOKS_TEST_DIR/buggy-glob.sh" <<'EOF'
#!/usr/bin/env bash
ADR_COUNT=$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' | wc -l)
EOF
run_lint
if grep -q 'FILE-PATTERN-A-find-name' "$LOG" 2>/dev/null && grep -q "buggy-glob.sh" "$LOG" 2>/dev/null; then
  echo "  TC TC4-find-broken-glob (D-039 Bug #1 REPRO): PASS"; PASS=$((PASS+1))
else
  echo "  TC TC4-find-broken-glob (D-039 Bug #1 REPRO): FAIL — broken D-*.md glob not flagged"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC5: find -name in empty dir → no violation (DIR_COUNT=0 triggers skip)
reset_state
EMPTY_DIR="$PROJECT_DIR/agent-workspace/memory/empty-test-dir"
mkdir -p "$EMPTY_DIR"
cat > "$HOOKS_TEST_DIR/empty-dir-test.sh" <<EOF
#!/usr/bin/env bash
EMPTY_DIR="$EMPTY_DIR"
COUNT=\$(find "\$MEMORY_DIR/empty-test-dir" -maxdepth 1 -name '*.md' | wc -l)
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC5-find-empty-dir-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC5-find-empty-dir-skip: FAIL — empty-dir false positive"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi
rmdir "$EMPTY_DIR" 2>/dev/null || true

# TC6: anchor matching real file → no violation
reset_state
cat > "$HOOKS_TEST_DIR/valid-anchor.sh" <<'EOF'
#!/usr/bin/env bash
COUNT=$(grep -c "^### " "$AN_FILE")
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC6-anchor-valid: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC6-anchor-valid: FAIL — false positive on valid '^### ' anchor"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC7 (D-039 Bug #4 PRE-FIX REPRO): anchor '^### L-S' against real agent-notes.md inline-card format → VIOLATION
reset_state
cat > "$HOOKS_TEST_DIR/buggy-anchor.sh" <<'EOF'
#!/usr/bin/env bash
COUNT=$(grep -c "^### L-S" "$AN_FILE")
EOF
run_lint
if grep -q 'FILE-PATTERN-B-anchor-match' "$LOG" 2>/dev/null && grep -q 'buggy-anchor.sh' "$LOG" 2>/dev/null; then
  echo "  TC TC7-anchor-broken (D-039 Bug #4 REPRO): PASS"; PASS=$((PASS+1))
else
  echo "  TC TC7-anchor-broken (D-039 Bug #4 REPRO): FAIL — broken '^### L-S' anchor not flagged"
  cat "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC8: pattern-lint-skip override on same line → suppresses violation
reset_state
cat > "$HOOKS_TEST_DIR/skipped-broken.sh" <<'EOF'
#!/usr/bin/env bash
COUNT=$(grep -c "^### L-S" "$AN_FILE") # pattern-lint-skip: legacy compat
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC8-skip-comment-same-line: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC8-skip-comment-same-line: FAIL — same-line skip-comment not respected"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC9: pattern-lint-skip override on preceding line (within 5-line window) → suppresses violation
reset_state
cat > "$HOOKS_TEST_DIR/skipped-block.sh" <<'EOF'
#!/usr/bin/env bash
# Some retire context comment block above
# pattern-lint-skip: D-039 Bug #4 RETIRE — counter retained for forward-compat observability
COUNT=$(grep -c "^### L-S" "$AN_FILE")
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC9-skip-comment-preceding: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC9-skip-comment-preceding: FAIL — preceding-line skip-comment not respected"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# TC10: Hour-bucket idempotency — 2nd run same hour skips
reset_state
cat > "$HOOKS_TEST_DIR/buggy-glob2.sh" <<'EOF'
#!/usr/bin/env bash
ADR_COUNT=$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' | wc -l)
EOF
run_lint
RUN1_LOG_LINES=$(wc -l < "$LOG" 2>/dev/null || echo 0)
run_lint
RUN2_LOG_LINES=$(wc -l < "$LOG" 2>/dev/null || echo 0)
if [ "$RUN1_LOG_LINES" = "$RUN2_LOG_LINES" ]; then
  echo "  TC TC10-hour-bucket-idempotent: PASS (lines unchanged $RUN1_LOG_LINES → $RUN2_LOG_LINES)"; PASS=$((PASS+1))
else
  echo "  TC TC10-hour-bucket-idempotent: FAIL ($RUN1_LOG_LINES → $RUN2_LOG_LINES)"; FAIL=$((FAIL+1))
fi

# TC11: Notification file created when violations >0
reset_state
cat > "$HOOKS_TEST_DIR/buggy-glob3.sh" <<'EOF'
#!/usr/bin/env bash
ADR_COUNT=$(find "$DECISIONS_DIR" -maxdepth 1 -name 'D-*.md' | wc -l)
EOF
run_lint
NOTIF_COUNT=$(find "$NOTIF_DIR" -maxdepth 1 -name 'N-INFO-file-pattern-lint.md' 2>/dev/null | wc -l | tr -d '[:space:]')
if [ "${NOTIF_COUNT:-0}" -ge 1 ]; then
  echo "  TC TC11-notification-on-violation: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC11-notification-on-violation: FAIL — no notification file created"; FAIL=$((FAIL+1))
fi

# TC12: non-structural anchors NOT flagged (Pattern B requires markdown structural char `*#|>` after `^`)
reset_state
cat > "$HOOKS_TEST_DIR/non-structural-anchor.sh" <<'EOF'
#!/usr/bin/env bash
COUNT=$(grep -c "^[A-Z_]" "$AN_FILE")
COUNT2=$(grep -oE '^[a-z]+' "$AN_FILE")
EOF
run_lint
if grep -q 'file-pattern-lint summary | violations=0' "$LOG" 2>/dev/null; then
  echo "  TC TC12-non-structural-anchor-skip: PASS"; PASS=$((PASS+1))
else
  echo "  TC TC12-non-structural-anchor-skip: FAIL — non-markdown anchor falsely flagged"
  grep 'file-pattern' "$LOG" 2>/dev/null
  FAIL=$((FAIL+1))
fi

echo
echo "=== Results: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
