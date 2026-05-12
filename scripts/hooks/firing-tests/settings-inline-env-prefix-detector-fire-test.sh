#!/usr/bin/env bash
# Companion firing-test for settings-inline-env-prefix-detector.sh.
# Synthesizes a settings.json with both violating + corrective patterns, runs the
# detector, asserts WARN emit + correct violation count.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
HOOK="$PROJECT_DIR/scripts/hooks/settings-inline-env-prefix-detector.sh"

PASS=0
FAIL=0
TOTAL=0

assert_contains() {
  local desc="$1" haystack="$2" needle="$3"
  TOTAL=$((TOTAL + 1))
  if printf '%s' "$haystack" | grep -qF "$needle"; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc"
    echo "    expected substring: $needle"
    echo "    actual:"
    printf '%s\n' "$haystack" | sed 's/^/      /'
  fi
}

# === Test 1: violations present (WARN expected) ===
TEST_PROJ_VIOL="$(mktemp -d)"
mkdir -p "$TEST_PROJ_VIOL/.claude" "$TEST_PROJ_VIOL/agent-workspace/memory" "$TEST_PROJ_VIOL/scripts/hooks"
cp "$HOOK" "$TEST_PROJ_VIOL/scripts/hooks/"
cat > "$TEST_PROJ_VIOL/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          { "type": "command", "command": "bash \"foo.sh\"" },
          { "type": "command", "command": "CLAUDE_HOOK_EVENT=SessionStart bash \"bar.sh\"" },
          { "type": "command", "command": "MY_VAR=value bash \"baz.sh\"" },
          { "type": "command", "command": "bash -c 'CLAUDE_HOOK_EVENT=SessionStart bash \"corrective.sh\"'" }
        ]
      }
    ]
  }
}
EOF

CLAUDE_PROJECT_DIR="$TEST_PROJ_VIOL" bash "$TEST_PROJ_VIOL/scripts/hooks/settings-inline-env-prefix-detector.sh" >/dev/null 2>&1 || true
LOG_VIOL="$(cat "$TEST_PROJ_VIOL/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"

echo "Test 1: violations present"
assert_contains "WARN state with violations=2" "$LOG_VIOL" "state=WARN violations=2"
assert_contains "violation 1 (CLAUDE_HOOK_EVENT)" "$LOG_VIOL" "CLAUDE_HOOK_EVENT=SessionStart"
assert_contains "violation 2 (MY_VAR)" "$LOG_VIOL" "MY_VAR=value"
# Corrective `bash -c 'VAR=val ...'` MUST NOT be flagged
TOTAL=$((TOTAL + 1))
if printf '%s' "$LOG_VIOL" | grep -q "corrective.sh"; then
  FAIL=$((FAIL + 1))
  echo "  FAIL: corrective bash -c pattern incorrectly flagged"
else
  PASS=$((PASS + 1))
  echo "  PASS: corrective bash -c pattern NOT flagged"
fi

rm -rf "$TEST_PROJ_VIOL"

# === Test 2: clean settings.json (GREEN expected) ===
TEST_PROJ_CLEAN="$(mktemp -d)"
mkdir -p "$TEST_PROJ_CLEAN/.claude" "$TEST_PROJ_CLEAN/agent-workspace/memory" "$TEST_PROJ_CLEAN/scripts/hooks"
cp "$HOOK" "$TEST_PROJ_CLEAN/scripts/hooks/"
cat > "$TEST_PROJ_CLEAN/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          { "type": "command", "command": "bash \"foo.sh\"" },
          { "type": "command", "command": "bash -c 'CLAUDE_HOOK_EVENT=SessionStart bash \"bar.sh\"'" }
        ]
      }
    ]
  }
}
EOF

CLAUDE_PROJECT_DIR="$TEST_PROJ_CLEAN" bash "$TEST_PROJ_CLEAN/scripts/hooks/settings-inline-env-prefix-detector.sh" >/dev/null 2>&1 || true
LOG_CLEAN="$(cat "$TEST_PROJ_CLEAN/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"

echo "Test 2: clean settings.json"
assert_contains "GREEN state with violations=0" "$LOG_CLEAN" "state=GREEN violations=0"

rm -rf "$TEST_PROJ_CLEAN"

# === Test 3: missing settings.json (SKIP expected) ===
TEST_PROJ_MISSING="$(mktemp -d)"
mkdir -p "$TEST_PROJ_MISSING/agent-workspace/memory" "$TEST_PROJ_MISSING/scripts/hooks"
cp "$HOOK" "$TEST_PROJ_MISSING/scripts/hooks/"

CLAUDE_PROJECT_DIR="$TEST_PROJ_MISSING" bash "$TEST_PROJ_MISSING/scripts/hooks/settings-inline-env-prefix-detector.sh" >/dev/null 2>&1 || true
LOG_MISSING="$(cat "$TEST_PROJ_MISSING/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"

echo "Test 3: settings.json missing"
assert_contains "SKIP" "$LOG_MISSING" "SKIP settings.json-missing"

rm -rf "$TEST_PROJ_MISSING"

# === Summary ===
echo ""
echo "=== Firing-test summary ==="
echo "Total: $TOTAL  Pass: $PASS  Fail: $FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
