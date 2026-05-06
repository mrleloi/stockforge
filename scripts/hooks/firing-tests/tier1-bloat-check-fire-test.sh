#!/usr/bin/env bash
# Firing-test for tier1-bloat-check.sh (Phase 3.5 T7 retrofit; S60).
#
# Hook purpose (D-017 SessionStart): warn when Tier 1 bootstrap (CLAUDE.md +
# agent-workspace/CLAUDE.md + current-execution.md + recent checkpoint) exceeds
# 8K tokens (bytes/4 heuristic).
#
# Test strategy: stage temp PROJECT_DIR with various Tier 1 files of known
# byte counts; invoke hook; assert stderr WARN content + per-file breakdown.
#
# 6 test cases:
#   TC1 — no Tier 1 files → silent (TOTAL_BYTES=0)
#   TC2 — files within ceiling → silent
#   TC3 — files exceeding ceiling (>32000 bytes) → WARN stderr + breakdown
#   TC4 — checkpoint <24h → included in calculation
#   TC5 — checkpoint >24h → excluded from calculation
#   TC6 — idempotent (multiple invocations same outcome)
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../tier1-bloat-check.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" \
    bash "$HOOK" </dev/null 2>&1 >/dev/null || true
}

clean_state() {
  rm -rf "$TEMPDIR"/*
  mkdir -p "$TEMPDIR/agent-workspace/memory/checkpoints"
}

# --- TC1: no Tier 1 files → silent ---
clean_state
OUT=$(run_hook)
if echo "$OUT" | grep -q "WARN"; then
  echo "FAIL TC1: should be silent when no files exist; got:"
  echo "$OUT"
  exit 1
fi
echo "PASS TC1: no Tier 1 files → silent"

# --- TC2: small files within ceiling → silent ---
clean_state
echo "tiny CLAUDE.md content" > "$TEMPDIR/CLAUDE.md"
echo "tiny agent-workspace CLAUDE.md" > "$TEMPDIR/agent-workspace/CLAUDE.md"
echo "tiny current-execution" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
OUT=$(run_hook)
if echo "$OUT" | grep -q "WARN"; then
  echo "FAIL TC2: small files should not warn; got:"
  echo "$OUT"
  exit 1
fi
echo "PASS TC2: tiny files within ceiling → silent"

# --- TC3: files exceeding ceiling → WARN stderr + breakdown ---
clean_state
# Generate ~40000 bytes of content → ~10000 tokens (above 8000 ceiling)
LARGE_CONTENT=$(printf 'X%.0s' {1..40000})
printf '%s' "$LARGE_CONTENT" > "$TEMPDIR/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
OUT=$(run_hook)
if ! echo "$OUT" | grep -q "tier1-bloat-check.*WARN"; then
  echo "FAIL TC3: expected WARN in stderr; got:"
  echo "$OUT"
  exit 1
fi
if ! echo "$OUT" | grep -q "ceiling 8000"; then
  echo "FAIL TC3: expected 'ceiling 8000' in WARN message"
  echo "$OUT"
  exit 1
fi
if ! echo "$OUT" | grep -q "CLAUDE.md"; then
  echo "FAIL TC3: expected per-file breakdown including CLAUDE.md"
  echo "$OUT"
  exit 1
fi
echo "PASS TC3: 10K-token bloat → WARN + per-file breakdown"

# --- TC4: checkpoint <24h → included in calculation ---
clean_state
echo "small" > "$TEMPDIR/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
# Checkpoint pushes total over ceiling
LARGE_CHECKPOINT=$(printf 'C%.0s' {1..40000})
printf '%s' "$LARGE_CHECKPOINT" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
# Recent mtime (default — current time)
OUT=$(run_hook)
if ! echo "$OUT" | grep -q "WARN"; then
  echo "FAIL TC4: expected WARN when recent checkpoint pushes over ceiling"
  echo "$OUT"
  exit 1
fi
if ! echo "$OUT" | grep -q "checkpoints/latest.md"; then
  echo "FAIL TC4: expected checkpoints/latest.md in breakdown (recent → included)"
  echo "$OUT"
  exit 1
fi
echo "PASS TC4: recent checkpoint (<24h) included → triggers WARN"

# --- TC5: checkpoint >24h → excluded ---
clean_state
echo "small" > "$TEMPDIR/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/CLAUDE.md"
echo "small" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
LARGE_CHECKPOINT=$(printf 'C%.0s' {1..40000})
printf '%s' "$LARGE_CHECKPOINT" > "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
# Force mtime to >24h ago
touch -d "2 days ago" "$TEMPDIR/agent-workspace/memory/checkpoints/latest.md"
OUT=$(run_hook)
if echo "$OUT" | grep -q "WARN"; then
  echo "FAIL TC5: stale checkpoint should be excluded; should not WARN. Got:"
  echo "$OUT"
  exit 1
fi
echo "PASS TC5: stale checkpoint (>24h) excluded → no WARN"

# --- TC6: idempotent ---
clean_state
LARGE_CONTENT=$(printf 'Y%.0s' {1..40000})
printf '%s' "$LARGE_CONTENT" > "$TEMPDIR/CLAUDE.md"
OUT1=$(run_hook)
OUT2=$(run_hook)
if [ "$OUT1" != "$OUT2" ]; then
  echo "FAIL TC6: idempotent run should produce identical output; first vs second:"
  echo "1: $OUT1"
  echo "2: $OUT2"
  exit 1
fi
echo "PASS TC6: idempotent — identical output across invocations"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "tier1-bloat-check.sh externally-observable behavior verified."
exit 0
