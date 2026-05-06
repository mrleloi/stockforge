#!/usr/bin/env bash
# Firing-test for correction-rate-aggregator.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (D-004 § Tracking Instrumentation Q2=A; Stop hook):
# read JSONL .correction-rate.log, group by session_id + bucket_50k, append
# digest line to .correction-rate-digest.log + summary to .session-hooks.log.
# Idempotent: each invocation appends one digest line (no dedup).
#
# Test strategy: stage temp PROJECT_DIR with various .correction-rate.log
# fixtures; invoke hook; assert digest JSON + hook log summary.
#
# 6 test cases:
#   TC1 — log file missing → "no log entries; skip" + no digest written
#   TC2 — log file empty → "no log entries; skip" + no digest written
#   TC3 — 1 entry for current session → digest with this_session_corrections=1
#   TC4 — multi-bucket entries → bucket counts populated correctly
#   TC5 — multi-session entries → all_sessions_distinct_count tracks unique sessions
#   TC6 — malformed JSONL line → skip silently, valid lines aggregated
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../correction-rate-aggregator.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "SKIP: node required (hook uses node -e)"; exit 0; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

LOG="$TEMPDIR/agent-workspace/memory/.correction-rate.log"
DIGEST="$TEMPDIR/agent-workspace/memory/.correction-rate-digest.log"
HOOK_LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"

run_hook() {
  local sid="${1:-tc-session}"
  CLAUDE_PROJECT_DIR="$TEMPDIR" CLAUDE_SESSION_ID="$sid" \
    bash "$HOOK" </dev/null >/dev/null 2>&1 || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$TEMPDIR/agent-workspace/memory"
}

# --- TC1: log file missing → skip ---
clean_state
run_hook "tc1"
if [ -f "$DIGEST" ]; then
  echo "FAIL TC1: digest file should NOT be written when log absent"
  cat "$DIGEST"
  exit 1
fi
if ! grep -q "no log entries" "$HOOK_LOG"; then
  echo "FAIL TC1: expected 'no log entries' message in hook log"
  cat "$HOOK_LOG" 2>/dev/null || echo "(no hook log)"
  exit 1
fi
echo "PASS TC1: log missing → no digest + skip message"

# --- TC2: log file empty → skip ---
clean_state
: > "$LOG"
run_hook "tc2"
if [ -f "$DIGEST" ]; then
  echo "FAIL TC2: digest should NOT be written when log empty"
  exit 1
fi
if ! grep -q "no log entries" "$HOOK_LOG"; then
  echo "FAIL TC2: expected 'no log entries' message"
  cat "$HOOK_LOG"
  exit 1
fi
echo "PASS TC2: log empty → no digest + skip message"

# --- TC3: 1 entry for current session ---
clean_state
cat > "$LOG" <<'EOF'
{"ts":"2026-05-05T10:00:00+00:00","session_id":"tc3-sid","tokens_at_correction":12345,"bucket_50k":0,"prompt_hash":"abc","prompt_len":50,"matched_vi":"không phải","matched_en":null}
EOF
run_hook "tc3-sid"
if [ ! -f "$DIGEST" ]; then
  echo "FAIL TC3: digest should be written"
  exit 1
fi
if ! grep -q '"this_session_corrections":1' "$DIGEST"; then
  echo "FAIL TC3: expected this_session_corrections=1"
  cat "$DIGEST"
  exit 1
fi
echo "PASS TC3: 1 entry → this_session_corrections=1"

# --- TC4: multi-bucket entries for SAME session ---
clean_state
cat > "$LOG" <<'EOF'
{"ts":"2026-05-05T10:00:00+00:00","session_id":"tc4-sid","tokens_at_correction":12000,"bucket_50k":0,"prompt_hash":"a1","prompt_len":10,"matched_vi":"sai","matched_en":null}
{"ts":"2026-05-05T10:01:00+00:00","session_id":"tc4-sid","tokens_at_correction":55000,"bucket_50k":50000,"prompt_hash":"a2","prompt_len":10,"matched_vi":"sai","matched_en":null}
{"ts":"2026-05-05T10:02:00+00:00","session_id":"tc4-sid","tokens_at_correction":61000,"bucket_50k":50000,"prompt_hash":"a3","prompt_len":10,"matched_vi":"sai","matched_en":null}
EOF
run_hook "tc4-sid"
if ! grep -q '"this_session_corrections":3' "$DIGEST"; then
  echo "FAIL TC4: expected this_session_corrections=3"
  cat "$DIGEST"
  exit 1
fi
if ! grep -q '"0":1' "$DIGEST"; then
  echo "FAIL TC4: expected bucket 0 count=1"
  cat "$DIGEST"
  exit 1
fi
if ! grep -q '"50000":2' "$DIGEST"; then
  echo "FAIL TC4: expected bucket 50000 count=2"
  cat "$DIGEST"
  exit 1
fi
echo "PASS TC4: multi-bucket → bucket counts populated correctly"

# --- TC5: multi-session entries → distinct count ---
clean_state
cat > "$LOG" <<'EOF'
{"ts":"2026-05-05T09:00:00+00:00","session_id":"sess-A","tokens_at_correction":1000,"bucket_50k":0,"prompt_hash":"x","prompt_len":5,"matched_vi":"sai","matched_en":null}
{"ts":"2026-05-05T10:00:00+00:00","session_id":"sess-B","tokens_at_correction":2000,"bucket_50k":0,"prompt_hash":"y","prompt_len":5,"matched_vi":"sai","matched_en":null}
{"ts":"2026-05-05T11:00:00+00:00","session_id":"sess-C","tokens_at_correction":3000,"bucket_50k":0,"prompt_hash":"z","prompt_len":5,"matched_vi":"sai","matched_en":null}
EOF
run_hook "sess-current"
if ! grep -q '"all_sessions_total_count":3' "$DIGEST"; then
  echo "FAIL TC5: expected all_sessions_total_count=3"
  cat "$DIGEST"
  exit 1
fi
if ! grep -q '"all_sessions_distinct_count":3' "$DIGEST"; then
  echo "FAIL TC5: expected all_sessions_distinct_count=3"
  cat "$DIGEST"
  exit 1
fi
echo "PASS TC5: 3 distinct sessions → distinct_count=3"

# --- TC6: malformed JSONL line → skip silently ---
clean_state
cat > "$LOG" <<'EOF'
{"ts":"2026-05-05T09:00:00+00:00","session_id":"tc6-sid","tokens_at_correction":1000,"bucket_50k":0,"prompt_hash":"x","prompt_len":5,"matched_vi":"sai","matched_en":null}
GARBAGE NOT JSON
{"ts":"2026-05-05T09:01:00+00:00","session_id":"tc6-sid","tokens_at_correction":1000,"bucket_50k":0,"prompt_hash":"y","prompt_len":5,"matched_vi":"sai","matched_en":null}
EOF
run_hook "tc6-sid"
if [ ! -f "$DIGEST" ]; then
  echo "FAIL TC6: digest should still be produced (skipping malformed)"
  exit 1
fi
# 2 valid lines processed, 1 garbage skipped → this_session_corrections=2
if ! grep -q '"this_session_corrections":2' "$DIGEST"; then
  echo "FAIL TC6: expected 2 valid entries (1 malformed line skipped)"
  cat "$DIGEST"
  exit 1
fi
echo "PASS TC6: malformed JSONL skipped; valid lines aggregated"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "correction-rate-aggregator.sh externally-observable behavior verified."
exit 0
