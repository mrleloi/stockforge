#!/usr/bin/env bash
# Firing-test for profile-template-auto-populate.sh (Phase 3.5 T7-followup; S73).
#
# Hook purpose (HH-C.3 Stop hook):
#   - finds latest session log in agent-workspace/memory/sessions/ within
#     last 4h (find -mmin -240); if none → exit 0
#   - extracts task_class from `type:` (or `**Type**:`) frontmatter line
#   - extracts model from `agent:` line; maps claude-opus-4-7 → opus47-max etc;
#     defaults to opus47-max
#   - derives SESSION_N from filename (YYYY-MM-DD-session-N.md → SN)
#   - writes idempotency marker .profile-template-fired-<session-basename>
#   - if profile card exists at self-awareness/profiles/<model>-<task>.md →
#     appends SESSION_N to sample_sessions array + increments samples_count
#   - else → creates stub card with frontmatter + skeleton body
#   - if samples_count >= STOCKFORGE_PROFILE_REBUILD_THRESHOLD (default 10),
#     enqueue profile-render ETL job (skipped if MEMORY_ETL_DISABLE=1)
#
# 5 test cases:
#   TC1 — no sessions dir → exit 0; no card created
#   TC2 — session log exists but >4h old → exit 0; no card created
#   TC3 — fresh session with type=FOCUSED_IMPL + agent=claude-opus-4-7 →
#         creates stub card with sample_sessions=[S99]; marker written
#   TC4 — fresh session + existing card with sample_sessions=[S95, S96] →
#         appends S99 → sample_sessions=[S95, S96, S99]; samples_count=3
#   TC5 — idempotency: marker pre-exists → second invocation no-op (card
#         unchanged)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../profile-template-auto-populate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

SESSIONS_DIR="$TEMPDIR/agent-workspace/memory/sessions"
PROFILES_DIR="$TEMPDIR/agent-workspace/memory/self-awareness/profiles"

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$SESSIONS_DIR" "$PROFILES_DIR"
}

# --- TC1: no session log at all → exit 0; no card created ---
clean_state
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" MEMORY_ETL_DISABLE=1 \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC1: expected exit 0; got $RC"
  exit 1
fi
CARDS_TC1=$(find "$PROFILES_DIR" -name '*.md' 2>/dev/null | wc -l)
if [ "$CARDS_TC1" -gt 0 ]; then
  echo "FAIL TC1: profile card should NOT be created when no session logs exist"
  exit 1
fi
echo "PASS TC1: no session log → silent no-op"

# --- TC2: session log >4h old → exit 0; no card created ---
clean_state
SESSION_FILE="$SESSIONS_DIR/2026-05-06-session-99.md"
cat > "$SESSION_FILE" <<'EOF'
---
type: FOCUSED_IMPL
agent: main-session (claude-opus-4-7)
---
# Old session
EOF
touch -d "5 hours ago" "$SESSION_FILE"
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" MEMORY_ETL_DISABLE=1 \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC2: expected exit 0; got $RC"
  exit 1
fi
CARDS_TC2=$(find "$PROFILES_DIR" -name '*.md' 2>/dev/null | wc -l)
if [ "$CARDS_TC2" -gt 0 ]; then
  echo "FAIL TC2: stale session (>4h) should NOT trigger card creation"
  ls -la "$PROFILES_DIR" 2>/dev/null
  exit 1
fi
echo "PASS TC2: session >4h old → silent no-op (mmin -240 filter)"

# --- TC3: fresh session → creates stub card ---
clean_state
SESSION_FILE="$SESSIONS_DIR/2026-05-06-session-99.md"
cat > "$SESSION_FILE" <<'EOF'
---
type: FOCUSED_IMPL
agent: main-session (claude-opus-4-7)
---
# Fresh session
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" MEMORY_ETL_DISABLE=1 \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC3: expected exit 0; got $RC"
  exit 1
fi
EXPECTED_CARD="$PROFILES_DIR/opus47-max-FOCUSED_IMPL.md"
if [ ! -f "$EXPECTED_CARD" ]; then
  echo "FAIL TC3: expected stub card at $EXPECTED_CARD"
  ls -la "$PROFILES_DIR"
  exit 1
fi
if ! grep -qE '^sample_sessions:[[:space:]]*\[S99\]' "$EXPECTED_CARD"; then
  echo "FAIL TC3: card should contain 'sample_sessions: [S99]'"
  cat "$EXPECTED_CARD"
  exit 1
fi
if ! grep -qE '^samples_count:[[:space:]]*1' "$EXPECTED_CARD"; then
  echo "FAIL TC3: card should contain 'samples_count: 1'"
  cat "$EXPECTED_CARD"
  exit 1
fi
MARKER_TC3="$TEMPDIR/agent-workspace/memory/.profile-template-fired-2026-05-06-session-99"
if [ ! -f "$MARKER_TC3" ]; then
  echo "FAIL TC3: idempotency marker not written at $MARKER_TC3"
  exit 1
fi
echo "PASS TC3: fresh FOCUSED_IMPL/opus47 session → stub card + marker"

# --- TC4: fresh session + existing card → append SESSION_N + increment count ---
clean_state
SESSION_FILE="$SESSIONS_DIR/2026-05-06-session-99.md"
cat > "$SESSION_FILE" <<'EOF'
---
type: FOCUSED_IMPL
agent: main-session (claude-opus-4-7)
---
EOF
EXISTING_CARD="$PROFILES_DIR/opus47-max-FOCUSED_IMPL.md"
cat > "$EXISTING_CARD" <<'EOF'
---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 2
sample_sessions: [S95, S96]
last_updated: 2026-05-05T00:00:00+07:00
source: agent-workspace/memory/self-awareness/sessions-rollup.tsv
auto_populated_by: scripts/hooks/profile-template-auto-populate.sh
---

# Profile — opus47-max × FOCUSED_IMPL
EOF
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" MEMORY_ETL_DISABLE=1 \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC4: expected exit 0; got $RC"
  exit 1
fi
if ! grep -qE '^sample_sessions:[[:space:]]*\[S95, S96, S99\]' "$EXISTING_CARD"; then
  echo "FAIL TC4: sample_sessions should now contain S95, S96, S99"
  cat "$EXISTING_CARD"
  exit 1
fi
if ! grep -qE '^samples_count:[[:space:]]*3' "$EXISTING_CARD"; then
  echo "FAIL TC4: samples_count should be incremented to 3"
  cat "$EXISTING_CARD"
  exit 1
fi
echo "PASS TC4: fresh session + existing card → S99 appended; count=3"

# --- TC5: idempotency — marker pre-exists → no-op (card unchanged) ---
clean_state
SESSION_FILE="$SESSIONS_DIR/2026-05-06-session-99.md"
cat > "$SESSION_FILE" <<'EOF'
---
type: FOCUSED_IMPL
agent: main-session (claude-opus-4-7)
---
EOF
EXISTING_CARD="$PROFILES_DIR/opus47-max-FOCUSED_IMPL.md"
cat > "$EXISTING_CARD" <<'EOF'
---
model: claude-opus-4-7
effort: max
thinking: enabled
task_class:
  - FOCUSED_IMPL
samples_count: 5
sample_sessions: [S90, S91, S92, S93, S94]
last_updated: 2026-05-05T00:00:00+07:00
source: agent-workspace/memory/self-awareness/sessions-rollup.tsv
auto_populated_by: scripts/hooks/profile-template-auto-populate.sh
---
EOF
MARKER="$TEMPDIR/agent-workspace/memory/.profile-template-fired-2026-05-06-session-99"
touch "$MARKER"
# Capture card content pre-invocation.
PRE_HASH=$(md5sum "$EXISTING_CARD" 2>/dev/null | cut -d' ' -f1 || true)
RC=0
CLAUDE_PROJECT_DIR="$TEMPDIR" MEMORY_ETL_DISABLE=1 \
  bash "$HOOK" </dev/null >/dev/null 2>&1 || RC=$?
if [ "$RC" != "0" ]; then
  echo "FAIL TC5: expected exit 0; got $RC"
  exit 1
fi
POST_HASH=$(md5sum "$EXISTING_CARD" 2>/dev/null | cut -d' ' -f1 || true)
if [ "$PRE_HASH" != "$POST_HASH" ]; then
  echo "FAIL TC5: card should be unchanged when idempotency marker exists"
  echo "pre=$PRE_HASH post=$POST_HASH"
  exit 1
fi
if ! grep -qE '^sample_sessions:[[:space:]]*\[S90, S91, S92, S93, S94\]' "$EXISTING_CARD"; then
  echo "FAIL TC5: sample_sessions should NOT change when marker exists"
  cat "$EXISTING_CARD"
  exit 1
fi
echo "PASS TC5: idempotency marker → no-op (card unchanged)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (5/5) ==="
echo "profile-template-auto-populate.sh externally-observable behavior verified."
exit 0
