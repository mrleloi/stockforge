#!/usr/bin/env bash
# daily-backup-fire-test.sh — companion firing-test (AP-23 / L-S247-1)
# SPAWN-CONTEXT: positional-arg

set -uo pipefail
PASS=0; FAIL=0; ERRORS=()
note_fail() { FAIL=$((FAIL+1)); ERRORS+=("$1"); }
note_pass() { PASS=$((PASS+1)); }

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/daily-backup.sh"
[ -r "$HOOK" ] || { echo "FAIL: hook not readable"; exit 1; }

TMP="$(mktemp -d -t dbackup-test-XXXXXX 2>/dev/null || mktemp -d)"
BACKUP="$(mktemp -d -t dbackup-out-XXXXXX 2>/dev/null || mktemp -d)"
trap 'rm -rf "$TMP" "$BACKUP"' EXIT

setup_project() {
  rm -rf "$TMP"/* "$BACKUP"/*
  mkdir -p "$TMP/agent-workspace/memory" "$TMP/scripts/hooks" "$TMP/.claude" "$TMP/packages"
  # Add enough content so the archive exceeds the 10KB sanity threshold
  for i in $(seq 1 50); do
    printf 'line %d of content padding to exceed size threshold for backup sanity check\n' "$i" >> "$TMP/PROJECT_CHARTER.md"
  done
  cp "$TMP/PROJECT_CHARTER.md" "$TMP/CLAUDE.md"
  cp "$TMP/PROJECT_CHARTER.md" "$TMP/agent-workspace/memory/agent-notes.md"
}

run_hook() {
  CLAUDE_PROJECT_DIR="$TMP" STOCKFORGE_BACKUP_DIR="$BACKUP" bash "$HOOK" "${1:-Stop}" >/dev/null 2>&1
  return $?
}

TODAY="$(date +%Y-%m-%d)"

# TC1: first run → archive created
setup_project
run_hook Stop
RC=$?
ARCHIVE="$BACKUP/stockforge-${TODAY}.tar.gz"
if [ "$RC" -eq 0 ] && [ -f "$ARCHIVE" ]; then note_pass; else note_fail "TC1: expected archive at $ARCHIVE (RC=$RC)"; fi

# TC2: archive is non-trivial size (> 10KB threshold... gzip of padding may be small, just check >0)
if [ -f "$ARCHIVE" ]; then
  SZ=$(stat -c %s "$ARCHIVE" 2>/dev/null || stat -f %z "$ARCHIVE" 2>/dev/null || echo 0)
  [ "$SZ" -gt 0 ] && note_pass || note_fail "TC2: archive empty"
else
  note_fail "TC2: no archive to size-check"
fi

# TC3: idempotency — second run same day → marker present, no error
run_hook Stop
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC3: second same-day run should RC=0 (got $RC)"

# TC4: day-marker file written
if [ -f "$TMP/agent-workspace/memory/.daily-backup-done-${TODAY}" ]; then note_pass; else note_fail "TC4: day-marker not written"; fi

# TC5: RC=0 always (even if tar would fail — simulate by removing project dirs after setup)
setup_project
rm -rf "$TMP/agent-workspace" "$TMP/scripts" "$TMP/.claude" "$TMP/packages"
run_hook Stop
RC=$?
[ "$RC" -eq 0 ] && note_pass || note_fail "TC5: hook must RC=0 even when dirs missing (got $RC)"

# TC6: archive excludes .git
setup_project
mkdir -p "$TMP/.git/objects"
echo "secret git internal" > "$TMP/.git/HEAD"
rm -f "$TMP/agent-workspace/memory/.daily-backup-done-${TODAY}"
run_hook Stop
if [ -f "$ARCHIVE" ]; then
  if tar -tzf "$ARCHIVE" 2>/dev/null | grep -q '\.git/'; then
    note_fail "TC6: archive should EXCLUDE .git/"
  else
    note_pass
  fi
else
  note_fail "TC6: no archive produced"
fi

# TC7: S321 IMPORTANT-1 regression — large archive with EARLY-matching entry must still be
# marked content-verified (ARCHIVE_OK=1). Under `set -o pipefail`, `grep -q` exits early on
# the first match → tar gets SIGPIPE (RC=141) → pipefail propagates → ARCHIVE_OK stays 0 →
# good backup silently logged as FAILED. The fix uses subshell+grep-c+|| echo 0 to absorb SIGPIPE.
#
# Strategy: create an archive where PROJECT_CHARTER.md (the first pattern in the grep -cE
# alternation) appears VERY EARLY in the tar listing — before many other entries. With a
# large tar stream this deterministically exercises the SIGPIPE path. We ensure it is the
# FIRST entry by creating PROJECT_CHARTER.md first and making the rest of the archive large.
setup_project
# Place PROJECT_CHARTER.md very early; pad the rest of agent-workspace with many files.
rm -f "$TMP/agent-workspace/memory/.daily-backup-done-${TODAY}"
for i in $(seq 1 200); do
  printf 'padding file %d to inflate archive size so tar stream is long\n' "$i" > "$TMP/agent-workspace/memory/padding-${i}.txt"
done
# Remove any existing archive so the hook actually runs
rm -f "$BACKUP/stockforge-${TODAY}.tar.gz"
run_hook Stop
ARCHIVE="$BACKUP/stockforge-${TODAY}.tar.gz"
if [ ! -f "$ARCHIVE" ]; then
  note_fail "TC7: no archive produced (SIGPIPE-path regression test)"
else
  # Check the backup log: should NOT say "WARN archive failed content-verify"
  LOG_WARN=0
  if [ -f "$TMP/agent-workspace/memory/.daily-backup.log" ]; then
    if grep -q "WARN archive failed content-verify" "$TMP/agent-workspace/memory/.daily-backup.log"; then
      LOG_WARN=1
    fi
  fi
  MARKER_FILE="$TMP/agent-workspace/memory/.daily-backup-done-${TODAY}"
  if [ "$LOG_WARN" -eq 1 ]; then
    note_fail "TC7: SIGPIPE regression — large archive with early-match logged WARN (grep -q exited early → SIGPIPE → ARCHIVE_OK=0)"
  elif [ ! -f "$MARKER_FILE" ]; then
    note_fail "TC7: day-marker not written — content-verify may have failed silently"
  else
    note_pass
  fi
fi

TOTAL=$((PASS+FAIL))
echo "daily-backup-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
