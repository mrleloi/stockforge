#!/usr/bin/env bash
# Firing-test for stale-prompt-detector.sh (Phase 3.5 T7 retrofit per L-S51-1; S56 PoC).
#
# stale-prompt-detector is a UserPromptSubmit hook that scans user-submitted prompts for
# references to work items already CLOSED in current state (UP-NN closed in up-intake-log,
# D-NNN in terminal status, Track <N> DONE in current-execution, S<N> with session log).
# When stale refs detected, emits additionalContext warning so agent surfaces closure status
# before re-doing work (per UP-06 NO-Silent-Default + UP-07 RCA).
#
# Test strategy: stage temp PROJECT_DIR with appropriate fixtures (up-intake-log.md / sessions/
# / current-execution.md), pass user prompt via stdin JSON `prompt` field, run hook, inspect
# stdout for additionalContext warning emission (or absence for control cases).
#
# L-S55-1 categorization context (S56 retrofit): hook line 72 `grep -oE 'Track [0-9]+...'`
# + line 84 `grep -oE '\bS[0-9]+\b'` flagged by bash-hook-lint Check 8 as unanchored
# positional-marker. Categorized as content-search false-positives (target = `$USER_PROMPT`
# piped variable holding free-form user text). Content-search is exactly what we want
# (user typing "remind me about Track 5" should match mid-prompt). Existing `\b` boundary
# on line 84 is the right mechanism. TC4 + TC5 specifically exercise mid-prompt token
# detection to prove content-search robustness.
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../stale-prompt-detector.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory/sessions" \
         "$TEMPDIR/agent-workspace/memory/decisions"

# Stage common fixtures
cat > "$TEMPDIR/agent-workspace/memory/up-intake-log.md" <<'EOF'
# UP Intake Log

- up_id: UP-07
  status: closed-by-D-004
  topic: post-clear context restore
- up_id: UP-99
  status: open
  topic: example open
EOF

cat > "$TEMPDIR/agent-workspace/memory/current-execution.md" <<'EOF'
# Current Execution

**Phase**: 3.5

## S55 — done
- Track 7 ✅ DONE
- Track 99 — open
EOF

# Helper: invoke hook with stdin JSON and capture stdout
run_hook() {
  local prompt="$1"
  local stdin_json
  stdin_json=$(printf '{"prompt":"%s"}' "$prompt")
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<<"$stdin_json" 2>/dev/null || true
}

PASS=0; FAIL=0

# --- TC1: closed UP-NN reference triggers warning ---
OUT=$(run_hook "Need to revisit UP-07 because of new evidence")
if echo "$OUT" | grep -q "UP-07 is CLOSED"; then
  echo "PASS TC1: closed UP-07 reference detected and warning emitted"
  PASS=$((PASS+1))
else
  echo "FAIL TC1: expected 'UP-07 is CLOSED' warning, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC2: DONE Track <N> reference triggers warning ---
OUT=$(run_hook "Can we extend Track 7 with the new feature?")
if echo "$OUT" | grep -q "Track 7 is marked DONE"; then
  echo "PASS TC2: DONE Track 7 reference detected and warning emitted"
  PASS=$((PASS+1))
else
  echo "FAIL TC2: expected 'Track 7 is marked DONE' warning, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC3: closed S<N> reference (session log exists) triggers warning ---
touch "$TEMPDIR/agent-workspace/memory/sessions/2026-05-05-session-55.md"
OUT=$(run_hook "Let me update S55 outputs")
if echo "$OUT" | grep -q "S55 has a session log"; then
  echo "PASS TC3: closed S55 reference detected and warning emitted"
  PASS=$((PASS+1))
else
  echo "FAIL TC3: expected 'S55 has a session log' warning, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC4: L-S55-1 categorization — Track ref MID-PROMPT triggers (content-search proof) ---
# Anchoring `^Track [0-9]+` would FAIL this case (prompt starts with "Can we").
# Verifies that content-search behavior is correct for free-form user input.
OUT=$(run_hook "Can we re-open Track 7 after closing some prerequisites")
if echo "$OUT" | grep -q "Track 7 is marked DONE"; then
  echo "PASS TC4: L-S55-1 content-search proof — mid-prompt Track 7 detected (anchoring would break)"
  PASS=$((PASS+1))
else
  echo "FAIL TC4: mid-prompt Track 7 should match (content-search content); got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC5: L-S55-1 categorization — S<N> ref MID-PROMPT triggers (\\b boundary proof) ---
# Anchoring `^S[0-9]+` would FAIL (prompt has prefix). The existing `\b` boundary
# is the correct content-search anchor for token detection in free-form text.
OUT=$(run_hook "Quick question: is S55 still active or closed already?")
if echo "$OUT" | grep -q "S55 has a session log"; then
  echo "PASS TC5: L-S55-1 content-search proof — mid-prompt S55 detected via \\b boundary"
  PASS=$((PASS+1))
else
  echo "FAIL TC5: mid-prompt S55 should match (content-search via \\b); got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC6: clean prompt with no stale references → no warning emitted ---
OUT=$(run_hook "Working on a brand new feature for the dashboard")
if [ -z "$OUT" ] || ! echo "$OUT" | grep -q "additionalContext"; then
  echo "PASS TC6: clean prompt produces no warning emission"
  PASS=$((PASS+1))
else
  echo "FAIL TC6: clean prompt should produce no warning, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC7: trivial prompt 'continue' short-circuits before any check ---
# Hook line 26: literal trivial-prompt regex bypasses checks entirely.
OUT=$(run_hook "continue")
if [ -z "$OUT" ] || ! echo "$OUT" | grep -q "additionalContext"; then
  echo "PASS TC7: trivial 'continue' prompt short-circuits (no warning regardless)"
  PASS=$((PASS+1))
else
  echo "FAIL TC7: trivial 'continue' should short-circuit, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

# --- TC8: open UP-NN does NOT trigger (only closed-* refs) ---
OUT=$(run_hook "Status check on UP-99 please")
if [ -z "$OUT" ] || ! echo "$OUT" | grep -q "UP-99 is CLOSED"; then
  echo "PASS TC8: open UP-99 does not trigger stale-warning (only closed-* refs)"
  PASS=$((PASS+1))
else
  echo "FAIL TC8: open UP-99 should NOT trigger stale-warning, got:"
  echo "$OUT"
  FAIL=$((FAIL+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d (target: 8/8) ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
