#!/usr/bin/env bash
# html-separator-check-fire-test.sh — Firing-test for html-separator-check.sh hook.
#
# Verifies the W0-4 hook fires correctly on missing/malformed HTML-comment separators
# in audited memory-zone markdown files.
#
# SPAWN-CONTEXT: positional-arg
# Plan: agent-workspace/session-plans/pending/018-S331-wave-0-W0-3-4-5-bundle.md
# ADR: agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md
# Hook: scripts/hooks/html-separator-check.sh
#
# ≥10 TC minimum (architect-proposed); 12 TC implemented.
# Exit 0 if all PASS; exit 1 on any FAIL.
set -uo pipefail

HOOK="${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/html-separator-check.sh"
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

# Set up sandbox directory structure matching audited zones
MEM_DIR="$SANDBOX/agent-workspace/memory"
mkdir -p "$MEM_DIR/thesis-log"
mkdir -p "$MEM_DIR/observations"
mkdir -p "$MEM_DIR/post-mortems"
mkdir -p "$SANDBOX/human-workspace/notifications"
mkdir -p "$SANDBOX/agent-workspace/master-plans"

export CLAUDE_PROJECT_DIR="$SANDBOX"

# Helper: run hook in Stop mode
run_hook_stop() {
  bash "$HOOK" < /dev/null 2>/dev/null
  return $?
}

# Helper: run hook on a specific file (PostToolUse mode for .md files)
run_hook_on_file() {
  local filepath="$1"
  local payload
  payload="{\"file_path\": \"${filepath}\"}"
  printf '%s' "$payload" | bash "$HOOK" 2>/dev/null
  return $?
}

# Helper: check if violation rule was emitted in log
check_log_for_rule() {
  local rule="$1"
  grep -q "$rule" "$MEM_DIR/.session-hooks.log" 2>/dev/null
  return $?
}

# Helper: reset log and markers between tests
reset_state() {
  rm -f "$MEM_DIR/.session-hooks.log"
  find "$MEM_DIR" -name '.htmlsep-marker-*' -delete 2>/dev/null || true
}

# Helper: generate a large entry (>200 lines) for threshold tests
make_large_entry() {
  local heading="$1"
  printf '## %s\n\n' "$heading"
  for i in $(seq 1 100); do
    printf 'Observation line %d: data point with context and explanation.\n' "$i"
  done
}

# ============================================================
# TC1 — No fire for file with 3 entries and correct separators
# ============================================================
reset_state
TC1_FILE="$MEM_DIR/mistake-log.md"
{
  make_large_entry "Entry 1 — First failure"
  printf '\n\n<!-- ENTRY_END -->\n\n'
  make_large_entry "Entry 2 — Second failure"
  printf '\n\n<!-- ENTRY_END -->\n\n'
  make_large_entry "Entry 3 — Third failure"
  printf '\n\n<!-- ENTRY_END -->\n\n'
} > "$TC1_FILE"

run_hook_on_file "$TC1_FILE"
if check_log_for_rule "HS-R"; then
  fail_tc "TC1" "hook should NOT fire on file with correct <!-- ENTRY_END --> separators"
else
  pass_tc "TC1: no fire for file with 3 correct ENTRY_END separators"
fi

# ============================================================
# TC2 — HS-R1 fires on multi-entry file with no separator and ≥200 lines
# ============================================================
reset_state
TC2_FILE="$MEM_DIR/agent-notes.md"
{
  make_large_entry "Entry 1 — First note"
  printf '\n'
  make_large_entry "Entry 2 — Second note"
  printf '\n'
  make_large_entry "Entry 3 — Third note"
} > "$TC2_FILE"

run_hook_on_file "$TC2_FILE"
if check_log_for_rule "HS-R1"; then
  pass_tc "TC2: HS-R1 fires on multi-entry file without separator (≥200 lines)"
else
  fail_tc "TC2" "HS-R1 should fire on file with 3 entries and 0 separators (≥200 lines)"
fi

# ============================================================
# TC3 — No fire for single small file (no separator needed)
# ============================================================
reset_state
TC3_FILE="$MEM_DIR/observations/single-obs.md"
printf '## Single observation\n\nThis is a single entry. It is small and has only one heading.\n' > "$TC3_FILE"

run_hook_on_file "$TC3_FILE"
if check_log_for_rule "HS-R1"; then
  fail_tc "TC3" "HS-R1 should NOT fire on small single-entry file (< 200 lines, 1 heading)"
else
  pass_tc "TC3: no fire for small single-entry observation file"
fi

# ============================================================
# TC4 — HS-R2 fires on <!-- ENTRY --> (singular, missing _END)
# ============================================================
reset_state
TC4_FILE="$MEM_DIR/thesis-log/tc4.md"
{
  make_large_entry "Thesis 1"
  printf '\n\n<!-- ENTRY -->\n\n'
  make_large_entry "Thesis 2"
} > "$TC4_FILE"

run_hook_on_file "$TC4_FILE"
if check_log_for_rule "HS-R2"; then
  pass_tc "TC4: HS-R2 fires on <!-- ENTRY --> (missing _END suffix)"
else
  fail_tc "TC4" "HS-R2 should fire on <!-- ENTRY --> (missing _END suffix)"
fi

# ============================================================
# TC5 — HS-R2 fires on <!--ENTRY_END--> (no spaces)
# ============================================================
reset_state
TC5_FILE="$MEM_DIR/thesis-log/tc5.md"
{
  make_large_entry "Thesis A"
  printf '\n\n<!--ENTRY_END-->\n\n'
  make_large_entry "Thesis B"
} > "$TC5_FILE"

run_hook_on_file "$TC5_FILE"
if check_log_for_rule "HS-R2"; then
  pass_tc "TC5: HS-R2 fires on <!--ENTRY_END--> (missing spaces)"
else
  fail_tc "TC5" "HS-R2 should fire on <!--ENTRY_END--> (no spaces)"
fi

# ============================================================
# TC6 — HS-R2 fires on <!-- entry_end --> (lowercase)
# ============================================================
reset_state
TC6_FILE="$MEM_DIR/post-mortems/tc6.md"
{
  make_large_entry "Post-mortem 1"
  printf '\n\n<!-- entry_end -->\n\n'
  make_large_entry "Post-mortem 2"
} > "$TC6_FILE"

run_hook_on_file "$TC6_FILE"
if check_log_for_rule "HS-R2"; then
  pass_tc "TC6: HS-R2 fires on <!-- entry_end --> (lowercase)"
else
  fail_tc "TC6" "HS-R2 should fire on <!-- entry_end --> (lowercase)"
fi

# ============================================================
# TC7 — HS-R3 fires on mix of correct separator and --- naive separator
# ============================================================
reset_state
TC7_FILE="$MEM_DIR/observations/mixed-sep.md"
{
  make_large_entry "Observation A"
  printf '\n\n<!-- ENTRY_END -->\n\n'
  make_large_entry "Observation B"
  printf '\n\n---\n\n'
  make_large_entry "Observation C"
  printf '\n\n<!-- ENTRY_END -->\n\n'
} > "$TC7_FILE"

run_hook_on_file "$TC7_FILE"
if check_log_for_rule "HS-R3"; then
  pass_tc "TC7: HS-R3 fires on mix of <!-- ENTRY_END --> and --- separators"
else
  fail_tc "TC7" "HS-R3 should fire on file mixing <!-- ENTRY_END --> with --- naive separator"
fi

# ============================================================
# TC8 — No fire for file with frontmatter html-separator-exempt: true
# ============================================================
reset_state
TC8_FILE="$MEM_DIR/observations/exempt.md"
{
  printf '%s\n' '---' 'html-separator-exempt: true' '---' ''
  make_large_entry "Exempt Entry 1"
  printf '\n'
  make_large_entry "Exempt Entry 2"
  printf '\n'
  make_large_entry "Exempt Entry 3"
} > "$TC8_FILE"

run_hook_on_file "$TC8_FILE"
if check_log_for_rule "HS-R"; then
  fail_tc "TC8" "hook should NOT fire on file with html-separator-exempt: true frontmatter"
else
  pass_tc "TC8: no fire for file with html-separator-exempt: true"
fi

# ============================================================
# TC9 — No fire for file in EXCLUDED zone (master-plans)
# Use fresh sandbox to avoid Stop-mode re-scanning prior test files
# ============================================================
TC9_SANDBOX="$(mktemp -d)"
mkdir -p "$TC9_SANDBOX/agent-workspace/memory/observations"
mkdir -p "$TC9_SANDBOX/agent-workspace/master-plans"
mkdir -p "$TC9_SANDBOX/human-workspace/notifications"
export CLAUDE_PROJECT_DIR="$TC9_SANDBOX"

TC9_FILE="$TC9_SANDBOX/agent-workspace/master-plans/foo.md"
{
  make_large_entry "Plan Section 1"
  printf '\n'
  make_large_entry "Plan Section 2"
  printf '\n'
  make_large_entry "Plan Section 3"
} > "$TC9_FILE"

# Run hook on a file in excluded zone (PostToolUse mode — but file not in audited zone,
# so hook falls back to Stop mode scanning only the sandbox's audited dirs which are empty)
printf '%s' "{\"file_path\": \"${TC9_FILE}\"}" | bash "$HOOK" 2>/dev/null

# Restore
export CLAUDE_PROJECT_DIR="$SANDBOX"

if grep -q "HS-R" "$TC9_SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null; then
  fail_tc "TC9" "hook should NOT fire on file in excluded zone (master-plans/)"
else
  pass_tc "TC9: no fire for file in excluded zone (master-plans/)"
fi
rm -rf "$TC9_SANDBOX"

# ============================================================
# TC10 — No fire for single-entry observation file (one-file-per-subagent)
# ============================================================
reset_state
TC10_FILE="$MEM_DIR/observations/single-subagent.md"
printf '## Subagent Return\n\nThis is a single-entry observation from one subagent dispatch.\nIt should not require a separator.\n' > "$TC10_FILE"

run_hook_on_file "$TC10_FILE"
if check_log_for_rule "HS-R1"; then
  fail_tc "TC10" "HS-R1 should NOT fire on small single-entry observation (< 200 lines)"
else
  pass_tc "TC10: no fire for single-entry observation file (small)"
fi

# ============================================================
# TC11 — Edge: empty file in audited zone (0 bytes)
# ============================================================
reset_state
TC11_FILE="$MEM_DIR/observations/empty.md"
printf '' > "$TC11_FILE"

run_hook_on_file "$TC11_FILE"
if check_log_for_rule "HS-R"; then
  fail_tc "TC11" "hook should NOT fire on empty file in audited zone"
else
  pass_tc "TC11: no fire on empty markdown file (degenerate)"
fi

# ============================================================
# TC12 — Regression-floor: hook on non-existent file → RC=0
# ============================================================
reset_state
TC12_SANDBOX="$(mktemp -d)"
mkdir -p "$TC12_SANDBOX/agent-workspace/memory/observations"
mkdir -p "$TC12_SANDBOX/human-workspace/notifications"
export CLAUDE_PROJECT_DIR="$TC12_SANDBOX"

FAKE_FILE="$TC12_SANDBOX/agent-workspace/memory/observations/nonexistent.md"
tc12_rc=0
printf '%s' "{\"file_path\": \"${FAKE_FILE}\"}" | bash "$HOOK" 2>/dev/null || tc12_rc=$?

# Restore CLAUDE_PROJECT_DIR
export CLAUDE_PROJECT_DIR="$SANDBOX"

if [ "$tc12_rc" -ne 0 ]; then
  fail_tc "TC12" "hook should exit RC=0 even for non-existent file"
else
  if grep -q "HS-R" "$TC12_SANDBOX/agent-workspace/memory/.session-hooks.log" 2>/dev/null; then
    fail_tc "TC12" "hook should NOT fire on non-existent file"
  else
    pass_tc "TC12: RC=0 and no false fire on non-existent file path"
  fi
fi
rm -rf "$TC12_SANDBOX"

# ============================================================
# TC13 — S341 D1: content-hash dedup: level:WARN frontmatter + mtime unchanged on 2nd run
# ============================================================
reset_state
TC13_FILE="$MEM_DIR/observations/large-multi-entry.md"
{
  make_large_entry "Entry One"
  printf '\n'
  make_large_entry "Entry Two"
  printf '\n'
  make_large_entry "Entry Three"
} > "$TC13_FILE"

run_hook_on_file "$TC13_FILE"
NOTIF="$SANDBOX/human-workspace/notifications/html-separator-warn.md"
# Verify level:WARN frontmatter
LVL="$(head -10 "$NOTIF" 2>/dev/null | grep -m1 '^level:' | sed 's/^level:[[:space:]]*//' | tr -d '[:space:]' || true)"
if [ "$LVL" = "WARN" ]; then
  pass_tc "TC13a: level:WARN frontmatter present in html-separator-warn.md"
else
  fail_tc "TC13a" "expected level:WARN in html-separator-warn.md, got '$LVL'"
fi
# Verify mtime unchanged on 2nd run (content-hash dedup)
if [ -f "$NOTIF" ]; then
  MTIME1="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  sleep 1
  run_hook_on_file "$TC13_FILE"
  MTIME2="$(stat -c %Y "$NOTIF" 2>/dev/null || echo 0)"
  if [ "$MTIME1" = "$MTIME2" ]; then
    pass_tc "TC13b: mtime unchanged on 2nd run (content-hash dedup fired)"
  else
    fail_tc "TC13b" "mtime changed on 2nd run with identical html-sep content: mtime1=$MTIME1 mtime2=$MTIME2"
  fi
else
  fail_tc "TC13b" "notification not found for mtime check"
fi

# ============================================================
# TC-HOISTED: D1 S346 plan-023 — find-delete NOT in claim_file_slot body
# ============================================================
reset_state
export CLAUDE_PROJECT_DIR="$SANDBOX"

# Assert 1: no non-comment 'find.*-delete' line inside claim_file_slot() body
HOOK_SRC="$(cat "$HOOK" 2>/dev/null || true)"
CLAIM_BODY="$(printf '%s\n' "$HOOK_SRC" | awk '/^claim_file_slot\(\)/,/^\}/' | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$' | grep -v 'claim_file_slot' | grep -v '^}' || true)"
if printf '%s\n' "$CLAIM_BODY" | grep -q 'find.*-delete'; then
  fail_tc "TC-HOISTED-1" "find-delete still found in claim_file_slot() non-comment body (D1 regression)"
else
  pass_tc "TC-HOISTED-1: find-delete NOT in claim_file_slot body (D1 applied)"
fi

# Assert 2: hoisted find-delete line exists in hook source (outside claim_file_slot)
if printf '%s\n' "$HOOK_SRC" | grep -v '^[[:space:]]*#' | grep -q 'find.*\.htmlsep-marker.*-delete'; then
  pass_tc "TC-HOISTED-2: hoisted 'find .htmlsep-marker* -delete' exists in hook source"
else
  fail_tc "TC-HOISTED-2" "hoisted 'find .htmlsep-marker* -delete' not found in hook source (D1 not applied)"
fi

# ============================================================
# TC-COOLDOWN: D2 S346 plan-023 — Stop-mode cool-down behavior
# ============================================================
# html-separator threshold is >5 files (not >100); create 6 .md files in audited zones
COOL_SANDBOX="$(mktemp -d)"
COOL_MEM="$COOL_SANDBOX/agent-workspace/memory"
mkdir -p "$COOL_MEM/observations" "$COOL_MEM/thesis-log" "$COOL_MEM/post-mortems"
mkdir -p "$COOL_SANDBOX/human-workspace/notifications"
export CLAUDE_PROJECT_DIR="$COOL_SANDBOX"

# Create 6 .md files with correct separators so hook runs to completion without violations
for i in $(seq 1 6); do
  {
    make_large_entry "Entry A${i}"
    printf '\n\n<!-- ENTRY_END -->\n\n'
    make_large_entry "Entry B${i}"
    printf '\n\n<!-- ENTRY_END -->\n\n'
  } > "$COOL_MEM/observations/cooldown_test_${i}.md"
done

COOL_MARKER="$COOL_MEM/.htmlsep-last-full-sweep"
COOL_LOG="$COOL_MEM/.session-hooks.log"

# Assert 3: First Stop run creates the cooldown marker (6 files > threshold of 5)
bash "$HOOK" < /dev/null 2>/dev/null || true
if [ -f "$COOL_MARKER" ]; then
  pass_tc "TC-COOLDOWN-3: .htmlsep-last-full-sweep created after first run with >5 files"
else
  fail_tc "TC-COOLDOWN-3" ".htmlsep-last-full-sweep not created after first run with >5 files"
fi

# Assert 4: Second Stop run (within 600s) logs SKIP-COOLDOWN
bash "$HOOK" < /dev/null 2>/dev/null || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  pass_tc "TC-COOLDOWN-4: SKIP-COOLDOWN logged on second Stop run within 600s"
else
  fail_tc "TC-COOLDOWN-4" "SKIP-COOLDOWN not logged on second Stop run within 600s"
fi

# Assert 5: After marker is expired (>600s old), full sweep runs (no SKIP-COOLDOWN)
touch -d '700 seconds ago' "$COOL_MARKER" 2>/dev/null || true
rm -f "$COOL_LOG"
bash "$HOOK" < /dev/null 2>/dev/null || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  fail_tc "TC-COOLDOWN-5" "SKIP-COOLDOWN incorrectly logged after marker expired (>600s)"
else
  pass_tc "TC-COOLDOWN-5: no SKIP-COOLDOWN after marker expired (full sweep executed)"
fi

# Assert 6: PostToolUse JSON stdin (single file) bypasses cooldown
touch "$COOL_MARKER" 2>/dev/null || true
rm -f "$COOL_LOG"
CLEAN_MD="$COOL_MEM/observations/cooldown_test_1.md"
printf '%s' "{\"file_path\": \"${CLEAN_MD}\"}" | bash "$HOOK" 2>/dev/null || true
if grep -q 'SKIP-COOLDOWN' "$COOL_LOG" 2>/dev/null; then
  fail_tc "TC-COOLDOWN-6" "PostToolUse JSON stdin should NOT trigger SKIP-COOLDOWN"
else
  pass_tc "TC-COOLDOWN-6: PostToolUse JSON stdin bypasses cooldown correctly"
fi

rm -rf "$COOL_SANDBOX"
export CLAUDE_PROJECT_DIR="$SANDBOX"

# ============================================================
# Results
# ============================================================
TOTAL=$(( PASS + FAIL ))
printf '\n=== html-separator-check firing-test: PASS=%d FAIL=%d (%d TCs) ===\n' "$PASS" "$FAIL" "$TOTAL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
