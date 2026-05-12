#!/usr/bin/env bash
# Companion firing-test for firing-test-spawn-context-lint.sh.
# Synthesizes settings.json + firing-test fixture combinations covering the 5
# acceptance-criteria cases from promote-rule-S247-AP-23-firing-test-gap.md:
#
#   TC1 — Form-A inline-env-prefix (sibling detector handles; lint sees 0 violations)
#   TC2 — Form-B env-wrap (bad; Pass 1 must flag it)
#   TC3 — Form-C positional-arg (good; 0 violations — safe in Windows executor)
#   TC4 — bash-c hook with missing companion firing-test (bad; Pass 2 must flag)
#   TC5 — bash-c hook with companion firing-test but missing SPAWN-CONTEXT marker (bad; Pass 3 must flag)
#   TC6 — bash-c hook with companion firing-test + SPAWN-CONTEXT marker (good; 0 violations)
#   TC7 — settings.json missing (SKIP expected)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../firing-test-spawn-context-lint.sh"

[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

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
    echo "    actual output:"
    printf '%s\n' "$haystack" | sed 's/^/      /'
  fi
}

assert_not_contains() {
  local desc="$1" haystack="$2" needle="$3"
  TOTAL=$((TOTAL + 1))
  if ! printf '%s' "$haystack" | grep -qF "$needle"; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc (unexpected match)"
    echo "    unexpected substring: $needle"
    echo "    actual output:"
    printf '%s\n' "$haystack" | sed 's/^/      /'
  fi
}

# Helper: create minimal test project scaffold
make_proj() {
  local dir="$1"
  mkdir -p "$dir/.claude" "$dir/agent-workspace/memory" "$dir/scripts/hooks/firing-tests"
}

# ─── TC1: Form-A inline-env-prefix — sibling detector catches it; this lint sees 0 ───
echo "TC1: Form-A inline-env-prefix (sibling handles; spawn-context-lint sees GREEN)"
PROJ1="$(mktemp -d)"
make_proj "$PROJ1"
cat > "$PROJ1/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks": [
      {"type":"command","command":"CLAUDE_HOOK_EVENT=Stop bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/some-hook.sh\""}
    ]}]
  }
}
EOF
CLAUDE_PROJECT_DIR="$PROJ1" bash "$HOOK" >/dev/null 2>&1 || true
LOG1="$(cat "$PROJ1/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
# Form-A is inline-env-A; our lint skips it (sibling handles)
assert_contains "TC1: GREEN state (Form-A delegated to sibling)" "$LOG1" "state=GREEN"
assert_not_contains "TC1: Form-A NOT flagged by spawn-context-lint" "$LOG1" "reason=form-B"
rm -rf "$PROJ1"

# ─── TC2: Form-B env-wrap — Pass 1 must flag it ───────────────────────────────
echo ""
echo "TC2: Form-B env-wrap (bad — Pass 1 must flag)"
# SPAWN-CONTEXT: env-wrap-B
# Reproduces Claude-Code Windows spawn topology:
#   - CLAUDE_PID not exported; env wrapper fails to exec PE32+ binary
#   - command invoked as: env CLAUDE_HOOK_EVENT=Stop bash "script.sh"
PROJ2="$(mktemp -d)"
make_proj "$PROJ2"
cat > "$PROJ2/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks": [
      {"type":"command","command":"env CLAUDE_HOOK_EVENT=Stop bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/bad-hook.sh\""}
    ]}]
  }
}
EOF
CLAUDE_PROJECT_DIR="$PROJ2" bash "$HOOK" >/dev/null 2>&1 || true
LOG2="$(cat "$PROJ2/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC2: WARN state emitted" "$LOG2" "state=WARN"
assert_contains "TC2: form=env-wrap-B flagged" "$LOG2" "form=env-wrap-B"
assert_contains "TC2: reason=form-B emitted" "$LOG2" "reason=form-B"
assert_contains "TC2: class=AP-23 emitted" "$LOG2" "class=AP-23"
rm -rf "$PROJ2"

# ─── TC3: Form-C positional-arg — safe in Windows executor; 0 violations ──────
echo ""
echo "TC3: Form-C positional-arg (good — 0 violations)"
PROJ3="$(mktemp -d)"
make_proj "$PROJ3"
# These are exactly the shapes used by idle-escape-detector, phase-status-coherence,
# harness-health-self-scan in production settings.json
cat > "$PROJ3/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "SessionStart": [{"hooks": [
      {"type":"command","command":"bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/idle-escape-detector.sh\" SessionStart"},
      {"type":"command","command":"bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/phase-status-coherence.sh\" SessionStart"},
      {"type":"command","command":"bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/harness-health-self-scan.sh\" SessionStart"}
    ]}]
  }
}
EOF
CLAUDE_PROJECT_DIR="$PROJ3" bash "$HOOK" >/dev/null 2>&1 || true
LOG3="$(cat "$PROJ3/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC3: GREEN state (Form-C safe)" "$LOG3" "state=GREEN"
assert_not_contains "TC3: No WARN emitted for Form-C" "$LOG3" "state=WARN"
rm -rf "$PROJ3"

# ─── TC4: bash-c hook with missing companion firing-test — Pass 2 must flag ───
echo ""
echo "TC4: bash-c hook missing firing-test (bad — Pass 2 must flag)"
PROJ4="$(mktemp -d)"
make_proj "$PROJ4"
cat > "$PROJ4/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks": [
      {"type":"command","command":"bash -c 'CLAUDE_HOOK_EVENT=Stop bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/orphan-hook.sh\"'"}
    ]}]
  }
}
EOF
# No firing-test file created for orphan-hook
CLAUDE_PROJECT_DIR="$PROJ4" bash "$HOOK" >/dev/null 2>&1 || true
LOG4="$(cat "$PROJ4/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC4: WARN state emitted" "$LOG4" "state=WARN"
assert_contains "TC4: reason=no-firing-test" "$LOG4" "reason=no-firing-test"
rm -rf "$PROJ4"

# ─── TC5: bash-c hook with firing-test but no SPAWN-CONTEXT marker — Pass 3 ──
echo ""
echo "TC5: bash-c hook has firing-test but no SPAWN-CONTEXT marker (bad — Pass 3)"
PROJ5="$(mktemp -d)"
make_proj "$PROJ5"
cat > "$PROJ5/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks": [
      {"type":"command","command":"bash -c 'CLAUDE_HOOK_EVENT=Stop bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/unmarked-hook.sh\"'"}
    ]}]
  }
}
EOF
# Companion firing-test exists but lacks # SPAWN-CONTEXT: marker
cat > "$PROJ5/scripts/hooks/firing-tests/unmarked-hook-fire-test.sh" <<'EOF'
#!/usr/bin/env bash
# Companion firing-test — missing spawn-context marker (intentional for TC5)
HOOK="$(dirname "$0")/../unmarked-hook.sh"
CLAUDE_PROJECT_DIR="$(mktemp -d)"
bash "$HOOK" >/dev/null 2>&1 || true
echo "1/1 PASS"
exit 0
EOF
CLAUDE_PROJECT_DIR="$PROJ5" bash "$HOOK" >/dev/null 2>&1 || true
LOG5="$(cat "$PROJ5/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC5: WARN state emitted" "$LOG5" "state=WARN"
assert_contains "TC5: reason=no-spawn-marker" "$LOG5" "reason=no-spawn-marker"
rm -rf "$PROJ5"

# ─── TC6: bash-c hook with firing-test + SPAWN-CONTEXT marker — GREEN ─────────
echo ""
echo "TC6: bash-c hook with firing-test + SPAWN-CONTEXT marker (good — GREEN)"
PROJ6="$(mktemp -d)"
make_proj "$PROJ6"
cat > "$PROJ6/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [{"hooks": [
      {"type":"command","command":"bash -c 'CLAUDE_HOOK_EVENT=Stop bash \"${CLAUDE_PROJECT_DIR:-.}/scripts/hooks/marked-hook.sh\"'"}
    ]}]
  }
}
EOF
# Companion firing-test with SPAWN-CONTEXT marker
cat > "$PROJ6/scripts/hooks/firing-tests/marked-hook-fire-test.sh" <<'EOF'
#!/usr/bin/env bash
# SPAWN-CONTEXT: bash-c
# Reproduces Claude-Code Windows spawn topology:
#   - CLAUDE_PID unset (hook receives no env from wrapper)
#   - command invoked exactly as Claude Code would: bash -c 'CLAUDE_HOOK_EVENT=Stop bash "marked-hook.sh"'
HOOK="$(dirname "$0")/../marked-hook.sh"
touch "$HOOK" 2>/dev/null || true
CLAUDE_PROJECT_DIR="$(mktemp -d)"
bash "$HOOK" >/dev/null 2>&1 || true
echo "1/1 PASS"
exit 0
EOF
CLAUDE_PROJECT_DIR="$PROJ6" bash "$HOOK" >/dev/null 2>&1 || true
LOG6="$(cat "$PROJ6/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC6: GREEN state (marked hook)" "$LOG6" "state=GREEN"
assert_not_contains "TC6: No WARN for marked hook" "$LOG6" "state=WARN"
rm -rf "$PROJ6"

# ─── TC7: settings.json missing — SKIP expected ───────────────────────────────
echo ""
echo "TC7: settings.json missing (SKIP expected)"
PROJ7="$(mktemp -d)"
mkdir -p "$PROJ7/agent-workspace/memory"
CLAUDE_PROJECT_DIR="$PROJ7" bash "$HOOK" >/dev/null 2>&1 || true
LOG7="$(cat "$PROJ7/agent-workspace/memory/.session-hooks.log" 2>/dev/null || echo "")"
assert_contains "TC7: SKIP emitted" "$LOG7" "SKIP settings.json-missing"
rm -rf "$PROJ7"

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "=== Firing-test summary ==="
echo "Total: $TOTAL  Pass: $PASS  Fail: $FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
