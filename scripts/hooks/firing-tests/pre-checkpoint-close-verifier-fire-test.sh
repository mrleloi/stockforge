#!/usr/bin/env bash
# pre-checkpoint-close-verifier-fire-test.sh — Plan 012 D2 firing test.
# Tests externally-observable behavior per L-S59-1:
#   - notification file created on detection
#   - WARN to stderr
#   - whitelist filter (auto-generated paths skipped)
#   - kill switch honored
#   - hook event filter (only Stop)
#   - mtime gate (checkpoint not modified this session → skip)
# Per L-S52-3 success-path: real-data smoke + ≥6 TCs (≥1 positive + ≥3 negative + kill-switch).
# Per L-S62-1: no yes|head patterns; fixtures via printf/cat heredoc.
# Per L-S11-1 portability: bash + awk + grep + sed only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../pre-checkpoint-close-verifier.sh"
if [ ! -f "$HOOK" ]; then
  echo "FAIL: hook not found at $HOOK"
  exit 1
fi

PASS=0
FAIL=0

TEMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEMPDIR"' EXIT

PROJECT_DIR="$TEMPDIR/proj"
MEMORY_DIR="$PROJECT_DIR/agent-workspace/memory"
CKPT="$MEMORY_DIR/checkpoints/latest.md"
SESSION_READY="$MEMORY_DIR/.session-ready"
NOTIF_DIR="$PROJECT_DIR/human-workspace/notifications"

setup_sandbox() {
  rm -rf "$PROJECT_DIR"
  mkdir -p "$MEMORY_DIR/checkpoints" "$NOTIF_DIR"
  # Commit baseline so untracked changes after setup are isolated to this-session work.
  ( cd "$PROJECT_DIR" && \
    git init -q . && \
    git config user.email t@t.t && \
    git config user.name t && \
    : > "$MEMORY_DIR/checkpoints/.gitkeep" && \
    : > "$NOTIF_DIR/.gitkeep" && \
    git add -A && \
    git commit -qm "baseline" \
  ) >/dev/null 2>&1 || true
}

count_notif() {
  local count=0
  local f
  for f in "$NOTIF_DIR"/*-checkpoint-mentions-incomplete.md; do
    if [ -f "$f" ]; then
      count=$((count+1))
    fi
  done
  echo "$count"
}

write_session_ready() {
  printf 'ready_at=2026-05-06T00:00:00Z\nsession_id=test-sess\nsource=startup\n' > "$SESSION_READY"
  # Set mtime to a known older time so we can author checkpoint after it
  touch -t 202605060000 "$SESSION_READY" 2>/dev/null || true
}

write_checkpoint() {
  local content="$1"
  printf '%s' "$content" > "$CKPT"
  # Touch newer (current time)
  touch "$CKPT"
}

assert_pass() { PASS=$((PASS+1)); printf 'PASS TC%s: %s\n' "$2" "$1"; }
assert_fail() { FAIL=$((FAIL+1)); printf 'FAIL TC%s: %s\n' "$2" "$1"; }

PAYLOAD_STOP='{"hook_event_name":"Stop","session_id":"test-sess"}'
PAYLOAD_OTHER='{"hook_event_name":"PreToolUse","session_id":"test-sess"}'

# ----------------------------------------------------------------------
# TC1 — checkpoint mentions all git-status basenames → no notif
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
echo "untracked content" > "$PROJECT_DIR/foo_module.py"
write_checkpoint "checkpoint mentions foo_module.py explicitly here"
( cd "$PROJECT_DIR" && CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null )
N="$(count_notif)"
N="${N:-0}"
if [ "$N" -eq 0 ]; then
  assert_pass "all git entries mentioned → no notification" "1"
else
  assert_fail "TC1: notif=$N (expected 0)" "1"
fi

# ----------------------------------------------------------------------
# TC2 — checkpoint omits a git-status entry → notification + WARN
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
echo "p1" > "$PROJECT_DIR/mentioned_file.py"
echo "p2" > "$PROJECT_DIR/unmentioned_file.py"
write_checkpoint "checkpoint mentions only mentioned_file.py here"
STDERR="$(CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>&1 >/dev/null || true)"
N="$(count_notif)"
N="${N:-0}"
WARN_HIT="$(printf '%s' "$STDERR" | grep -c 'WARN.*unmentioned' 2>/dev/null || true)"
WARN_HIT="${WARN_HIT:-0}"
if [ "$N" -eq 1 ] && [ "$WARN_HIT" -ge 1 ]; then
  CONTENT="$(cat "$NOTIF_DIR"/*-checkpoint-mentions-incomplete.md 2>/dev/null)"
  if printf '%s' "$CONTENT" | grep -qF "unmentioned_file.py"; then
    assert_pass "checkpoint omits entry → notification names omitted file + WARN stderr" "2"
  else
    assert_fail "TC2: notification missing 'unmentioned_file.py' in body" "2"
  fi
else
  assert_fail "TC2: notif=$N warn=$WARN_HIT (expected 1/≥1)" "2"
fi

# ----------------------------------------------------------------------
# TC3 — kill switch STOCKFORGE_CHECKPOINT_VERIFIER_DISABLE=1 → no notif even with omission
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
echo "p1" > "$PROJECT_DIR/missing.py"
write_checkpoint "checkpoint says nothing about that file"
STOCKFORGE_CHECKPOINT_VERIFIER_DISABLE=1 \
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null
N="$(count_notif)"
N="${N:-0}"
if [ "$N" -eq 0 ]; then
  assert_pass "kill switch → no notification despite omission" "3"
else
  assert_fail "TC3: notif=$N (expected 0)" "3"
fi

# ----------------------------------------------------------------------
# TC4 — non-Stop event (PreToolUse) → no scan
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
echo "p1" > "$PROJECT_DIR/missing.py"
write_checkpoint "checkpoint says nothing about that file"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_OTHER" 2>/dev/null
N="$(count_notif)"
N="${N:-0}"
if [ "$N" -eq 0 ]; then
  assert_pass "PreToolUse event → no scan" "4"
else
  assert_fail "TC4: notif=$N (expected 0)" "4"
fi

# ----------------------------------------------------------------------
# TC5 — checkpoint NOT modified this session (mtime <= session-ready) → skip
# ----------------------------------------------------------------------
setup_sandbox
echo "p1" > "$PROJECT_DIR/missing.py"
write_checkpoint "checkpoint says nothing"
# Make session-ready NEWER than checkpoint by writing it after
sleep 1
printf 'ready_at=2026-05-06T01:00:00Z\nsession_id=test-sess\nsource=startup\n' > "$SESSION_READY"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null
N="$(count_notif)"
N="${N:-0}"
if [ "$N" -eq 0 ]; then
  assert_pass "checkpoint mtime ≤ session-ready → skip (not authored this session)" "5"
else
  assert_fail "TC5: notif=$N (expected 0)" "5"
fi

# ----------------------------------------------------------------------
# TC6 — whitelist auto-generated paths skipped
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
mkdir -p "$PROJECT_DIR/agent-workspace/memory/indexes" \
         "$PROJECT_DIR/agent-workspace/learning-data/index" \
         "$PROJECT_DIR/agent-workspace/raw-sessions" \
         "$PROJECT_DIR/human-workspace/notifications"
echo "x" > "$PROJECT_DIR/agent-workspace/memory/indexes/lesson-registry.tsv"
echo "x" > "$PROJECT_DIR/agent-workspace/learning-data/index/manifest.json"
echo "x" > "$PROJECT_DIR/agent-workspace/raw-sessions/2026-05-06-session-X.md"
echo "x" > "$PROJECT_DIR/agent-workspace/memory/.last-event-ts-foo"
echo "x" > "$PROJECT_DIR/agent-workspace/memory/component-telemetry.jsonl"
echo "x" > "$PROJECT_DIR/agent-workspace/memory/.attestation-checked-something"
echo "x" > "$PROJECT_DIR/human-workspace/notifications/some-notif.md"
write_checkpoint "checkpoint mentions nothing about these auto-files"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null
N="$(count_notif)"
N="${N:-0}"
# The newly-written own notif from THIS hook would land in NOTIF_DIR but only if the
# hook actually fired. Whitelist should skip ALL the auto-files → 0 unmentioned → 0 notif.
# The "some-notif.md" we pre-seeded is also in human-workspace/notifications/ which IS
# whitelisted, so does NOT count toward unmentioned. Final notif count should be 0.
WHITELISTED_NOTIFS="$(ls "$NOTIF_DIR"/*-checkpoint-mentions-incomplete.md 2>/dev/null | wc -l || true)"
WHITELISTED_NOTIFS="${WHITELISTED_NOTIFS:-0}"
if [ "$WHITELISTED_NOTIFS" -eq 0 ]; then
  assert_pass "whitelist auto-paths (indexes/learning-data/raw-sessions/notifications) → no notification" "6"
else
  assert_fail "TC6: whitelisted_notifs=$WHITELISTED_NOTIFS (expected 0)" "6"
fi

# ----------------------------------------------------------------------
# TC7 — extra whitelist via env var
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
echo "p" > "$PROJECT_DIR/custom_skip.txt"
echo "p" > "$PROJECT_DIR/should_flag.py"
write_checkpoint "checkpoint mentions only should_flag.py"
STOCKFORGE_CHECKPOINT_VERIFIER_EXTRA_WHITELIST='custom_skip\.txt' \
  CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null
N="$(count_notif)"
N="${N:-0}"
if [ "$N" -eq 0 ]; then
  assert_pass "extra whitelist via env → custom path skipped" "7"
else
  # If a notif WAS generated, check it doesn't include custom_skip.txt
  CONTENT="$(cat "$NOTIF_DIR"/*-checkpoint-mentions-incomplete.md 2>/dev/null)"
  if printf '%s' "$CONTENT" | grep -qF "custom_skip.txt"; then
    assert_fail "TC7: extra whitelist not honored (custom_skip.txt still in notif)" "7"
  else
    assert_fail "TC7: notif=$N (expected 0)" "7"
  fi
fi

# ----------------------------------------------------------------------
# TC8 — clean working tree → no notif (graceful early exit)
# ----------------------------------------------------------------------
setup_sandbox
write_session_ready
write_checkpoint "checkpoint authored but no working-tree changes"
CLAUDE_PROJECT_DIR="$PROJECT_DIR" bash "$HOOK" <<< "$PAYLOAD_STOP" 2>/dev/null
EC=$?
N="$(count_notif)"
N="${N:-0}"
if [ "$EC" -eq 0 ] && [ "$N" -eq 0 ]; then
  assert_pass "clean working tree → exit 0, no notification" "8"
else
  assert_fail "TC8: exit=$EC notif=$N (expected 0/0)" "8"
fi

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
TOTAL=$((PASS+FAIL))
echo ""
echo "=== Results: PASS=$PASS FAIL=$FAIL ($TOTAL TCs) ==="
if [ "$FAIL" -eq 0 ]; then
  echo "pre-checkpoint-close-verifier (Plan 012 D2) verified."
  exit 0
else
  echo "FAILURE — review TCs above."
  exit 1
fi
