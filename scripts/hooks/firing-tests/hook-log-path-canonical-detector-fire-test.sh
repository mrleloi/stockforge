#!/bin/bash
# Firing-test for hook-log-path-canonical-detector.sh
# 3 scenarios: violations-present (WARN), clean (GREEN), hooks-dir-missing (SKIP)
# Asserts log emit + exit code per L-S214-1 contract.
set -uo pipefail

THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$THIS_DIR/../../.." && pwd)"
DETECTOR="$PROJECT_DIR/scripts/hooks/hook-log-path-canonical-detector.sh"

[ -x "$DETECTOR" ] || chmod +x "$DETECTOR" 2>/dev/null || true
[ -f "$DETECTOR" ] || { echo "FAIL: detector script missing at $DETECTOR"; exit 1; }

PASS_COUNT=0
FAIL_COUNT=0

assert() {
  local name="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "PASS $name"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL $name: expected=$expected actual=$actual"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# === TC1: violations-present (WARN expected) ===
TMP1=$(mktemp -d)
mkdir -p "$TMP1/scripts/hooks" "$TMP1/agent-workspace/memory"
cat > "$TMP1/scripts/hooks/bad-hook.sh" <<'EOF'
#!/bin/bash
ROOT_DIR="/some/path"
LOG="$ROOT_DIR/.session-hooks.log"
echo "test" >> "$LOG"
EOF
cat > "$TMP1/scripts/hooks/good-hook.sh" <<'EOF'
#!/bin/bash
ROOT_DIR="/some/path"
MEM_DIR="$ROOT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
echo "test" >> "$LOG"
EOF
CLAUDE_PROJECT_DIR="$TMP1" CLAUDE_SESSION_ID="tc1" bash "$DETECTOR"
TC1_EXIT=$?
TC1_LOG=$(cat "$TMP1/agent-workspace/memory/.session-hooks.log" 2>/dev/null)
assert "TC1 exit code 0" "0" "$TC1_EXIT"
if echo "$TC1_LOG" | grep -q "state=WARN violations=1"; then
  assert "TC1 emits WARN with violations=1" "yes" "yes"
else
  assert "TC1 emits WARN with violations=1" "yes" "no [$TC1_LOG]"
fi
if echo "$TC1_LOG" | grep -q "files=bad-hook.sh"; then
  assert "TC1 names violating file" "yes" "yes"
else
  assert "TC1 names violating file" "yes" "no [$TC1_LOG]"
fi
rm -rf "$TMP1"

# === TC2: clean (GREEN expected) ===
TMP2=$(mktemp -d)
mkdir -p "$TMP2/scripts/hooks" "$TMP2/agent-workspace/memory"
cat > "$TMP2/scripts/hooks/good-hook.sh" <<'EOF'
#!/bin/bash
ROOT_DIR="/some/path"
MEM_DIR="$ROOT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.session-hooks.log"
echo "test" >> "$LOG"
EOF
CLAUDE_PROJECT_DIR="$TMP2" CLAUDE_SESSION_ID="tc2" bash "$DETECTOR"
TC2_EXIT=$?
TC2_LOG=$(cat "$TMP2/agent-workspace/memory/.session-hooks.log" 2>/dev/null)
assert "TC2 exit code 0" "0" "$TC2_EXIT"
if echo "$TC2_LOG" | grep -q "state=GREEN violations=0"; then
  assert "TC2 emits GREEN" "yes" "yes"
else
  assert "TC2 emits GREEN" "yes" "no [$TC2_LOG]"
fi
rm -rf "$TMP2"

# === TC3: hooks-dir-missing (SKIP expected) ===
TMP3=$(mktemp -d)
mkdir -p "$TMP3/agent-workspace/memory"
CLAUDE_PROJECT_DIR="$TMP3" CLAUDE_SESSION_ID="tc3" bash "$DETECTOR"
TC3_EXIT=$?
TC3_LOG=$(cat "$TMP3/agent-workspace/memory/.session-hooks.log" 2>/dev/null)
assert "TC3 exit code 0" "0" "$TC3_EXIT"
if echo "$TC3_LOG" | grep -q "SKIP=hooks-dir-missing"; then
  assert "TC3 emits SKIP" "yes" "yes"
else
  assert "TC3 emits SKIP" "yes" "no [$TC3_LOG]"
fi
rm -rf "$TMP3"

# === TC4: ignores firing-tests subfolder (avoid false-positives on test fixtures) ===
TMP4=$(mktemp -d)
mkdir -p "$TMP4/scripts/hooks/firing-tests" "$TMP4/agent-workspace/memory"
cat > "$TMP4/scripts/hooks/firing-tests/some-fire-test.sh" <<'EOF'
#!/bin/bash
LOG="$ROOT_DIR/.session-hooks.log"
EOF
cat > "$TMP4/scripts/hooks/clean-hook.sh" <<'EOF'
#!/bin/bash
LOG="$MEM_DIR/.session-hooks.log"
EOF
CLAUDE_PROJECT_DIR="$TMP4" CLAUDE_SESSION_ID="tc4" bash "$DETECTOR"
TC4_LOG=$(cat "$TMP4/agent-workspace/memory/.session-hooks.log" 2>/dev/null)
if echo "$TC4_LOG" | grep -q "state=GREEN violations=0"; then
  assert "TC4 ignores firing-tests subfolder" "yes" "yes"
else
  assert "TC4 ignores firing-tests subfolder" "yes" "no [$TC4_LOG]"
fi
rm -rf "$TMP4"

echo ""
echo "===== firing-test summary ====="
echo "PASS=$PASS_COUNT  FAIL=$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
