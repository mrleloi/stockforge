#!/usr/bin/env bash
# Firing-test for metric-failure-mode-rate.sh (Phase 3.5 T7 retrofit; S62).
#
# Hook purpose (S12 Karpathy framing; CLI tool — invoked by learning-loop-metric-check):
# compute count(events.failure_mode != null) / count(events) over
# learning-data/events/*.ndjson. Output: stdout summary + JSON file at
# learning-data/index/metrics-<TS>.json.
# CLI flags: --quiet (suppress stdout), --window N (last N events only).
#
# Test strategy: stage temp PROJECT_DIR with various events fixtures;
# invoke CLI; assert stdout summary + index JSON file content.
#
# 6 test cases:
#   TC1 — events dir absent → total=0 + JSON file written
#   TC2 — events with no failure_mode → with_fm=0 rate=0
#   TC3 — events with failure_mode → with_fm>0 + dist populated
#   TC4 — --window 2 → only last 2 events counted
#   TC5 — --quiet → no stdout but JSON file still written
#   TC6 — invalid --window value → graceful exit (trap), no JSON written
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../metric-failure-mode-rate.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "SKIP: node required (hook uses node -e)"; exit 0; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

EVENTS_DIR="$TEMPDIR/agent-workspace/learning-data/events"
INDEX_DIR="$TEMPDIR/agent-workspace/learning-data/index"

run_hook() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" "$@" 2>/dev/null || true
}

run_hook_capture_stdout() {
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" "$@" 2>/dev/null || true
}

clean_state() {
  rm -rf "$TEMPDIR/agent-workspace"
  mkdir -p "$INDEX_DIR"
}

latest_metric_file() {
  # `ls + head` with pipefail can SIGPIPE / propagate ls-no-match exit;
  # `|| true` ensures helper returns clean even when no matches.
  ls -t "$INDEX_DIR"/metrics-*.json 2>/dev/null | head -1 || true
}

# --- TC1: events dir absent → total=0 ---
clean_state
run_hook --quiet >/dev/null
JSON_FILE=$(latest_metric_file)
if [ -z "$JSON_FILE" ] || [ ! -f "$JSON_FILE" ]; then
  echo "FAIL TC1: index JSON file should be written even when events absent"
  ls -la "$INDEX_DIR" 2>/dev/null
  exit 1
fi
if ! grep -q '"total":0' "$JSON_FILE"; then
  echo "FAIL TC1: expected total=0"
  cat "$JSON_FILE"
  exit 1
fi
echo "PASS TC1: events dir absent → total=0 + JSON written"

# --- TC2: events with no failure_mode → with_fm=0 ---
clean_state
mkdir -p "$EVENTS_DIR"
cat > "$EVENTS_DIR/2026-05-05.ndjson" <<'EOF'
{"ts":"2026-05-05T10:00:00Z","payload":{"event":"foo"}}
{"ts":"2026-05-05T10:01:00Z","payload":{"event":"bar"}}
EOF
run_hook --quiet >/dev/null
JSON_FILE=$(latest_metric_file)
if ! grep -q '"total":2' "$JSON_FILE"; then
  echo "FAIL TC2: expected total=2"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"with_fm":0' "$JSON_FILE"; then
  echo "FAIL TC2: expected with_fm=0"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"rate":0' "$JSON_FILE"; then
  echo "FAIL TC2: expected rate=0"
  cat "$JSON_FILE"
  exit 1
fi
echo "PASS TC2: no failure_mode in events → rate=0"

# --- TC3: events with failure_mode → with_fm>0 + dist ---
clean_state
mkdir -p "$EVENTS_DIR"
cat > "$EVENTS_DIR/2026-05-05.ndjson" <<'EOF'
{"ts":"2026-05-05T10:00:00Z","payload":{"event":"foo","failure_mode":"timeout"}}
{"ts":"2026-05-05T10:01:00Z","payload":{"event":"bar"}}
{"ts":"2026-05-05T10:02:00Z","payload":{"event":"baz","failure_mode":"validation"}}
{"ts":"2026-05-05T10:03:00Z","payload":{"event":"qux","failure_mode":"timeout"}}
EOF
run_hook --quiet >/dev/null
JSON_FILE=$(latest_metric_file)
if ! grep -q '"total":4' "$JSON_FILE"; then
  echo "FAIL TC3: expected total=4"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"with_fm":3' "$JSON_FILE"; then
  echo "FAIL TC3: expected with_fm=3"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"timeout":2' "$JSON_FILE"; then
  echo "FAIL TC3: expected dist timeout=2"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"validation":1' "$JSON_FILE"; then
  echo "FAIL TC3: expected dist validation=1"
  cat "$JSON_FILE"
  exit 1
fi
echo "PASS TC3: events with failure_mode → with_fm=3, dist populated"

# --- TC4: --window 2 → only last 2 events counted ---
clean_state
mkdir -p "$EVENTS_DIR"
cat > "$EVENTS_DIR/2026-05-05.ndjson" <<'EOF'
{"ts":"2026-05-05T10:00:00Z","payload":{"event":"e1","failure_mode":"timeout"}}
{"ts":"2026-05-05T10:01:00Z","payload":{"event":"e2","failure_mode":"timeout"}}
{"ts":"2026-05-05T10:02:00Z","payload":{"event":"e3"}}
{"ts":"2026-05-05T10:03:00Z","payload":{"event":"e4","failure_mode":"validation"}}
EOF
run_hook --quiet --window 2 >/dev/null
JSON_FILE=$(latest_metric_file)
if ! grep -q '"total":2' "$JSON_FILE"; then
  echo "FAIL TC4: expected total=2 (window of 2 events)"
  cat "$JSON_FILE"
  exit 1
fi
if ! grep -q '"mode":"windowed:2"' "$JSON_FILE"; then
  echo "FAIL TC4: expected mode=windowed:2"
  cat "$JSON_FILE"
  exit 1
fi
# Window covers e3 (no fm) + e4 (validation) → with_fm=1
if ! grep -q '"with_fm":1' "$JSON_FILE"; then
  echo "FAIL TC4: expected with_fm=1 (last 2 events: e3 no-fm, e4 validation)"
  cat "$JSON_FILE"
  exit 1
fi
echo "PASS TC4: --window 2 → only last 2 events counted"

# --- TC5: --quiet → no stdout but JSON still written ---
clean_state
mkdir -p "$EVENTS_DIR"
cat > "$EVENTS_DIR/2026-05-05.ndjson" <<'EOF'
{"ts":"2026-05-05T10:00:00Z","payload":{"event":"foo"}}
EOF
STDOUT=$(run_hook_capture_stdout --quiet)
if [ -n "$STDOUT" ]; then
  echo "FAIL TC5: --quiet should suppress stdout (got: $STDOUT)"
  exit 1
fi
JSON_FILE=$(latest_metric_file)
if [ -z "$JSON_FILE" ] || [ ! -f "$JSON_FILE" ]; then
  echo "FAIL TC5: --quiet should still write JSON file"
  exit 1
fi
echo "PASS TC5: --quiet → no stdout + JSON file written"

# --- TC6: invalid --window value → graceful exit (no JSON) ---
clean_state
mkdir -p "$EVENTS_DIR"
cat > "$EVENTS_DIR/2026-05-05.ndjson" <<'EOF'
{"ts":"2026-05-05T10:00:00Z","payload":{"event":"foo"}}
EOF
# --window without numeric arg → triggers stderr error; trap exits 0
run_hook --window not-a-number >/dev/null 2>&1
JSON_FILE=$(latest_metric_file)
if [ -n "$JSON_FILE" ] && [ -f "$JSON_FILE" ]; then
  echo "FAIL TC6: invalid --window should NOT produce JSON file"
  cat "$JSON_FILE"
  exit 1
fi
echo "PASS TC6: invalid --window value → graceful exit (no JSON)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (6/6) ==="
echo "metric-failure-mode-rate.sh externally-observable behavior verified."
exit 0
