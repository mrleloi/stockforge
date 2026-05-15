#!/usr/bin/env bash
# dispatch-pending-rotation-fire-test.sh — companion firing-test per L-S51-1.
# Tests externally-observable behavior per L-S59-1:
#   - stale ledgers (mtime > threshold) → moved to .dispatch-pending-archive/
#   - fresh ledgers (mtime <= threshold) → untouched
#   - empty directory / no ledgers → exit 0 clean
#   - archive dir auto-created
#   - STOCKFORGE_DISPATCH_ROTATION_HRS override honored
#   - kill switch (HRS=0) disables rotation
# L-S62-1: no yes|head patterns; fixtures via printf.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../dispatch-pending-rotation.sh"
if [ ! -f "$HOOK" ]; then
  echo "FAIL: hook not found at $HOOK"
  exit 1
fi

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
JSONL_DIR="$PROJECT_DIR/agent-workspace/memory"
ARCHIVE_DIR="$JSONL_DIR/.dispatch-pending-archive"
mkdir -p "$JSONL_DIR"

PASS=0
FAIL=0

make_pending() {
  local sid="$1"
  local mtime_offset_hrs="$2"
  local f="$JSONL_DIR/.dispatch-pending-${sid}.jsonl"
  printf '{"dispatch_id":"toolu_test","tool_use_id":"toolu_test","agent_type":"sandwich-dev","model":"sonnet","parent_session_id":"%s","ts_ms":1000000000000,"state":"pending"}\n' "$sid" > "$f"
  # Set mtime to NOW - offset_hrs
  local now
  now=$(date +%s)
  local target=$(( now - mtime_offset_hrs * 3600 ))
  # touch -d takes epoch via @ on GNU; fall back to -t YYYYMMDDhhmm on BSD
  touch -d "@$target" "$f" 2>/dev/null || touch -t "$(date -d "@$target" +%Y%m%d%H%M.%S 2>/dev/null || echo 200001010000)" "$f" 2>/dev/null || true
  printf '%s' "$f"
}

clean_state() {
  rm -rf "$JSONL_DIR"/.dispatch-pending-*.jsonl
  rm -rf "$ARCHIVE_DIR"
}

# -----------------------------------------------------------------------
# TC1 — stale ledger (mtime 24h ago) with default threshold 12h → archived
# -----------------------------------------------------------------------
clean_state
F1="$(make_pending "sess-tc1-stale" 24)"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ ! -f "$F1" ] \
   && [ -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc1-stale.jsonl" ]; then
  echo "PASS TC1: stale ledger (24h old) → archived under default 12h threshold"
  PASS=$((PASS+1))
else
  echo "FAIL TC1: expected archive of stale ledger; rc=$RC orig_exists=$([ -f "$F1" ] && echo y || echo n) archive_exists=$([ -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc1-stale.jsonl" ] && echo y || echo n)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC2 — fresh ledger (mtime 1h ago) → untouched
# -----------------------------------------------------------------------
clean_state
F2="$(make_pending "sess-tc2-fresh" 1)"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ -f "$F2" ] \
   && [ ! -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc2-fresh.jsonl" ]; then
  echo "PASS TC2: fresh ledger (1h old) → untouched, no archive"
  PASS=$((PASS+1))
else
  echo "FAIL TC2: fresh ledger should NOT be archived; rc=$RC orig_exists=$([ -f "$F2" ] && echo y || echo n)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC3 — no ledgers present → exit 0 clean
# -----------------------------------------------------------------------
clean_state
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ]; then
  echo "PASS TC3: no ledgers → exit 0 (no-op)"
  PASS=$((PASS+1))
else
  echo "FAIL TC3: expected exit 0, got $RC"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC4 — env override STOCKFORGE_DISPATCH_ROTATION_HRS=2 promotes 4h-old ledger to stale
# -----------------------------------------------------------------------
clean_state
F4="$(make_pending "sess-tc4-override" 4)"
STOCKFORGE_DISPATCH_ROTATION_HRS=2 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ ! -f "$F4" ] \
   && [ -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc4-override.jsonl" ]; then
  echo "PASS TC4: env override (HRS=2) archives 4h-old ledger"
  PASS=$((PASS+1))
else
  echo "FAIL TC4: env override should archive 4h ledger when HRS=2; rc=$RC orig_exists=$([ -f "$F4" ] && echo y || echo n)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC5 — kill switch STOCKFORGE_DISPATCH_ROTATION_HRS=0 disables rotation entirely
# -----------------------------------------------------------------------
clean_state
F5="$(make_pending "sess-tc5-killed" 999)"  # Very stale
STOCKFORGE_DISPATCH_ROTATION_HRS=0 CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ -f "$F5" ] \
   && [ ! -d "$ARCHIVE_DIR" ]; then
  echo "PASS TC5: kill switch (HRS=0) disables rotation; super-stale file untouched"
  PASS=$((PASS+1))
else
  echo "FAIL TC5: kill switch should preserve ledger; rc=$RC orig_exists=$([ -f "$F5" ] && echo y || echo n) archive_dir=$([ -d "$ARCHIVE_DIR" ] && echo y || echo n)"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC6 — mixed (fresh + stale) → only stale archived; fresh untouched
# -----------------------------------------------------------------------
clean_state
F6_FRESH="$(make_pending "sess-tc6-fresh" 1)"
F6_STALE="$(make_pending "sess-tc6-stale" 48)"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ -f "$F6_FRESH" ] \
   && [ ! -f "$F6_STALE" ] \
   && [ -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc6-stale.jsonl" ] \
   && [ ! -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc6-fresh.jsonl" ]; then
  echo "PASS TC6: mixed batch → only stale archived; fresh untouched"
  PASS=$((PASS+1))
else
  echo "FAIL TC6: mixed batch handling; rc=$RC"
  ls "$JSONL_DIR" "$ARCHIVE_DIR" 2>/dev/null
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC7 — idempotency: 2nd run after archive completes is no-op
# -----------------------------------------------------------------------
clean_state
F7="$(make_pending "sess-tc7-idem" 24)"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
# 2nd run
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ] \
   && [ -f "$ARCHIVE_DIR/.dispatch-pending-sess-tc7-idem.jsonl" ] \
   && [ ! -f "$F7" ]; then
  echo "PASS TC7: idempotent — 2nd run is no-op (archive preserved, no duplicate)"
  PASS=$((PASS+1))
else
  echo "FAIL TC7: idempotency; rc=$RC"
  FAIL=$((FAIL+1))
fi

# -----------------------------------------------------------------------
# TC8 — no false-positive on hook itself when project dir missing
# -----------------------------------------------------------------------
CLAUDE_PROJECT_DIR="/nonexistent/path/abc123" bash "$HOOK" >/dev/null 2>&1
RC=$?

if [ "$RC" -eq 0 ]; then
  echo "PASS TC8: missing project dir → exit 0 (graceful)"
  PASS=$((PASS+1))
else
  echo "FAIL TC8: expected exit 0 on missing project dir, got $RC"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL (8 TCs) ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
