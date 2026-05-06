#!/usr/bin/env bash
# Firing-test for in-flight-subagent-watcher.sh (Phase 3.5 T3.4 Cluster 3 per L-S51-1).
#
# Stages 4 cases against the real .dispatch-pending-*.jsonl file format:
#   TC1: fresh pending (10min ago) → NO alert
#   TC2: stale pending (>2hr) without observation file → ALERT
#   TC3: stale pending (>2hr) WITH observation file present → NO alert (subagent done)
#   TC4: state=observed (already closed) → NO alert
#
# Sample real format (S51 dispatch JSONL line shape):
#   {"dispatch_id":"...","state":"pending","ts_ms":1777984124514,
#    "expected_observation_path":"agent-workspace/memory/observations/promote-rule-S52.md",...}
#
# Exit 0 = all assertions pass.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../in-flight-subagent-watcher.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory/observations"
PENDING_DIR="$TEMPDIR/agent-workspace/memory"

NOW_S=$(date +%s)
NOW_MS=$(( NOW_S * 1000 ))
FRESH_MS=$(( NOW_MS - 600000 ))   # 10 min ago
STALE_MS=$(( NOW_MS - 8000000 ))  # ~2.2 hr ago

clean_logs() {
  rm -f "$PENDING_DIR"/.dispatch-pending-*.jsonl
  rm -f "$TEMPDIR/agent-workspace/memory/.in-flight-subagent-watcher.log"
}

PASS=0; FAIL=0

# === TC1: fresh pending → NO alert ===
clean_logs
cat > "$PENDING_DIR/.dispatch-pending-test1.jsonl" <<EOF
{"dispatch_id":"fresh-1","state":"pending","ts_ms":$FRESH_MS,"expected_observation_path":"agent-workspace/memory/observations/fresh-obs.md"}
EOF
STDERR_TC1=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)
if printf '%s' "$STDERR_TC1" | grep -q "stale pending dispatch"; then
  printf 'FAIL [TC1] fresh dispatch alerted: %s\n' "$STDERR_TC1"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC1] fresh dispatch (10min) → no alert"
  PASS=$((PASS+1))
fi

# === TC2: stale pending without observation → ALERT ===
clean_logs
cat > "$PENDING_DIR/.dispatch-pending-test2.jsonl" <<EOF
{"dispatch_id":"stale-noobs","state":"pending","ts_ms":$STALE_MS,"expected_observation_path":"agent-workspace/memory/observations/missing-obs.md"}
EOF
STDERR_TC2=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)
if printf '%s' "$STDERR_TC2" | grep -q "stale pending dispatch"; then
  echo "PASS [TC2] stale pending without observation → alert"
  PASS=$((PASS+1))
else
  printf 'FAIL [TC2] stale-no-obs did NOT alert: %s\n' "$STDERR_TC2"
  cat "$TEMPDIR/agent-workspace/memory/.in-flight-subagent-watcher.log" 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

# === TC3: stale pending WITH observation file → NO alert (subagent completed) ===
clean_logs
printf 'observation arrived\n' > "$TEMPDIR/agent-workspace/memory/observations/arrived-obs.md"
cat > "$PENDING_DIR/.dispatch-pending-test3.jsonl" <<EOF
{"dispatch_id":"stale-withobs","state":"pending","ts_ms":$STALE_MS,"expected_observation_path":"agent-workspace/memory/observations/arrived-obs.md"}
EOF
STDERR_TC3=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)
if printf '%s' "$STDERR_TC3" | grep -q "stale pending dispatch"; then
  printf 'FAIL [TC3] stale-with-obs alerted (should suppress): %s\n' "$STDERR_TC3"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC3] stale pending WITH observation → no alert"
  PASS=$((PASS+1))
fi

# === TC4: state=observed (closed) → NO alert ===
clean_logs
cat > "$PENDING_DIR/.dispatch-pending-test4.jsonl" <<EOF
{"dispatch_id":"observed-1","state":"observed","ts_ms":$STALE_MS,"expected_observation_path":"missing.md"}
EOF
STDERR_TC4=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)
if printf '%s' "$STDERR_TC4" | grep -q "stale pending dispatch"; then
  printf 'FAIL [TC4] state=observed alerted (should be silent): %s\n' "$STDERR_TC4"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC4] state=observed → no alert"
  PASS=$((PASS+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d (target: 4/4) ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
