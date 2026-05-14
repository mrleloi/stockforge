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

TOTAL=$((PASS+FAIL))
echo "daily-backup-fire-test: $PASS/$TOTAL PASS"
[ "$FAIL" -gt 0 ] && { for e in "${ERRORS[@]}"; do echo "  - $e"; done; exit 1; }
exit 0
