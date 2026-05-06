#!/usr/bin/env bash
# Firing-test for bash-hook-lint.sh patterns A/B/C/D extension (Phase 3.5 T3.4 + S54 refinement + S58 KI-S54-1 closure per L-S51-1).
#
# Stages synthetic hook scripts (dirty + clean) into a tempdir scripts/hooks/ layout,
# runs bash-hook-lint pointed at the tempdir, and asserts:
#   Check 5 — Pattern A (M-S51-1) emits on imagined-format grep
#   Check 6 — Pattern B (L-S48m-1) emits on $CLAUDE_SESSION_ID marker
#   Check 7 — Pattern C (L-S48d-1) emits on pipefail+ERR-trap+bare-grep:
#     TC-C  : bare-line grep (orig fixture)
#     TC-C2 : command-substitution `VAR="$(grep ...)"` form (S54 KI-S53-1; was missed pre-S54)
#     TC-C3 : pipeline `grep ... | other ...` form (S54 refinement)
#     TC-C-tricky-bare : bare-grep with `||` inside regex pattern (S58 regression — alt-guard rule
#                        must distinguish operator `||` from regex alternation)
#   Check 7 negative — `if grep`, already-guarded `|| true`:
#     TC-C-cond : `if grep ...; then` form NOT flagged
#     TC-C-guard: `$(grep ... || true)` NOT flagged
#     TC-C-compound-and : `if X && grep ...; then` (NEW S58) NOT flagged
#     TC-C-compound-pipe : `if X | grep ...; then` (NEW S58) NOT flagged
#     TC-C-alt-echo : `... || echo NN`/`... || echo ""` end-of-pipeline (NEW S58) NOT flagged
#     TC-C-bracket : `set +o pipefail; grep; set -o pipefail` form (NEW S58) NOT flagged
#   Check 8 — Pattern D (L-S53-2 unanchored positional-marker grep, NEW S54):
#     TC-D  : unanchored `grep -E 'S[0-9]+ NEXT'` flagged
#     TC-D-anchored : anchored `grep -E '^S[0-9]+ NEXT'` NOT flagged
#     TC-D-content : arbitrary content `grep "foo bar"` NOT flagged
#   TC-clean — pure clean hook NOT flagged for any check.
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../bash-hook-lint.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/scripts/hooks"
mkdir -p "$TEMPDIR/agent-workspace/memory"

# === Pattern A (Check 5): M-S51-1 imagined-format grep (literal **Session N**) ===
cat > "$TEMPDIR/scripts/hooks/imagined-format-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -u
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
LATEST_SESSION=$(grep -E '^\*\*Session N\*\*:' "$EXEC_FILE" | head -1 | sed 's/.*: //' || true)
echo "$LATEST_SESSION"
EOF

# === Pattern B (Check 6): L-S48m-1 CLAUDE_SESSION_ID marker without fallback ===
cat > "$TEMPDIR/scripts/hooks/claude-session-id-marker.sh" <<'EOF'
#!/usr/bin/env bash
set -u
MARKER_DIR="$PROJECT_DIR/agent-workspace/memory"
MARKER="${MARKER_DIR}/.foo-fired-${CLAUDE_SESSION_ID}"
[ -f "$MARKER" ] && exit 0
touch "$MARKER"
EOF

# === Pattern C (Check 7) — TC-C: bare-line grep (orig fixture) ===
cat > "$TEMPDIR/scripts/hooks/pipefail-err-trap-bare-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
    grep -m1 -E '^session=' "$LOG"
echo "after grep"
EOF

# === Pattern C (Check 7) — TC-C2: command-substitution form (S54 KI-S53-1 regression) ===
# This is the EXACT shape of session-export-raw.sh:42 pre-S53. Pre-S54 Check 7 missed it.
cat > "$TEMPDIR/scripts/hooks/pipefail-cmd-sub-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
EXEC_FILE="$PROJECT_DIR/exec.md"
SESSION_N="$(grep -E '^foo' "$EXEC_FILE" | grep -oE '[0-9]+' | sort -n | tail -1)"
echo "$SESSION_N"
EOF

# === Pattern C (Check 7) — TC-C3: pipeline grep at start, no || true ===
cat > "$TEMPDIR/scripts/hooks/pipefail-pipeline-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
grep -E 'pat' "$LOG" | head -1 | sed 's/foo/bar/'
echo "done"
EOF

# === Pattern C negative — TC-C-cond: `if grep` form NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/pipefail-if-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
if grep -qE 'foo' "$LOG"; then
  echo "found"
fi
EOF

# === Pattern C negative — TC-C-guard: $(grep ... || true) form NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/pipefail-grep-guarded.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
RESULT="$(grep -E 'foo' "$LOG" | head -1 || true)"
echo "$RESULT"
EOF

# === Pattern C negative — TC-C-compound-and: `if X && grep ...; then` form NOT flagged (NEW S58) ===
# Surfaced by S57 budget-watchdog.sh categorization. Cond exit consumed by `if`.
cat > "$TEMPDIR/scripts/hooks/pipefail-compound-and-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
if [ -f "$LOG" ] && grep -qE 'foo' "$LOG"; then
  echo "found"
fi
EOF

# === Pattern C negative — TC-C-compound-pipe: `if X | grep ...; then` form NOT flagged (NEW S58) ===
# Surfaced by S57 budget-watchdog.sh categorization. Pipeline IS the condition.
cat > "$TEMPDIR/scripts/hooks/pipefail-compound-pipe-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
if cat "$LOG" 2>/dev/null | grep -qE 'foo'; then
  echo "found"
fi
EOF

# === Pattern C negative — TC-C-alt-echo: `... || echo NN`/`... || echo ""` form NOT flagged (NEW S58) ===
# Surfaced by S57 hook-firing-counter.sh + sync-tracker-auto-update.sh + qa-pending-auto-mover.sh.
# Alt-guard echo provides non-zero substitute when pipeline returns non-zero → ERR-trap exempt.
cat > "$TEMPDIR/scripts/hooks/pipefail-alt-echo-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
COUNT=$(grep -c 'foo' "$LOG" 2>/dev/null || echo 0)
RESULT=$(grep -E 'pat' "$LOG" | head -1 || echo "")
echo "$COUNT $RESULT"
EOF

# === Pattern C negative — TC-C-bracket: pipefail-bracket form NOT flagged (NEW S58) ===
# Surfaced by S57 qa-pending-auto-mover.sh. Per-grep `set +o pipefail; grep; set -o pipefail`
# explicitly disables pipefail around the grep; double-defense pattern.
cat > "$TEMPDIR/scripts/hooks/pipefail-bracket-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
set +o pipefail
RESULT=$(head -25 "$LOG" 2>/dev/null | grep -m1 '^status:')
set -o pipefail
echo "$RESULT"
EOF

# === Pattern C negative — TC-C-and-chain: `[ X ] && grep ... && Y` form NOT flagged (NEW S58 broad chain rule) ===
# Surfaced by S58 ghost-work-audit.sh:39 categorization. Per bash(1) ERR trap spec:
# command in `&&`/`||` list except the FINAL command is exempt from ERR trap. Here grep
# is between two `&&` operators (not final) → grep no-match doesn't trigger silent exit.
cat > "$TEMPDIR/scripts/hooks/pipefail-and-chain-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
DOCUMENTED=0
[ -f "$LOG" ] && grep -qiE 'GHOST-WORK FOUND' "$LOG" 2>/dev/null && DOCUMENTED=1
echo "$DOCUMENTED"
EOF

# === Pattern C — TC-C-tricky-bare: bare-grep with `||` inside regex pattern SHOULD STILL be flagged (NEW S58 regression) ===
# Regression test for S58 alt-guard rule: must NOT confuse regex alternation `|` (single)
# inside a quoted pattern with shell `||` (double) operator. This grep has NO `||` operator
# anywhere on the line — only `|` inside `'(true|false)'` regex.
cat > "$TEMPDIR/scripts/hooks/pipefail-tricky-bare-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
LOG="$PROJECT_DIR/log.txt"
RESULT=$(grep -E '(true|false)' "$LOG")
echo "$RESULT"
EOF

# === Pattern D (Check 8) — TC-D: unanchored positional-marker grep ===
cat > "$TEMPDIR/scripts/hooks/unanchored-positional-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
RESULT=$(grep -E 'S[0-9]+[[:space:]]+NEXT' "$LOG" | head -1 || true)
echo "$RESULT"
EOF

# === Pattern D negative — TC-D-anchored: ^-anchored positional-marker grep NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/anchored-positional-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
RESULT=$(grep -E '^S[0-9]+[[:space:]]+NEXT' "$LOG" | head -1 || true)
HEADER=$(grep -oE '^## S[0-9]+' "$LOG" | sort | tail -1 || true)
echo "$RESULT $HEADER"
EOF

# === Pattern D negative — TC-D-content: arbitrary content grep NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/content-grep.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
RESULT=$(grep "foo bar" "$LOG" | head -1 || true)
COUNT=$(grep -c "warning" "$LOG" || true)
echo "$RESULT $COUNT"
EOF

# === TC-clean: clean hook NOT flagged for any check ===
cat > "$TEMPDIR/scripts/hooks/clean-hook.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
mkdir -p "$(dirname "$LOG")"
printf '[%s] hello\n' "$(date)" >> "$LOG"
exit 0
EOF

chmod +x "$TEMPDIR/scripts/hooks/"*.sh

# Run bash-hook-lint pointed at tempdir
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" </dev/null >/dev/null 2>&1 || true

LOG="$TEMPDIR/agent-workspace/memory/.session-hooks.log"
[ ! -f "$LOG" ] && { echo "FAIL: session-hooks.log not created"; exit 1; }

PASS=0; FAIL=0

assert_flagged() {
  # $1=label, $2=violation_code_regex, $3=hook_basename (without .sh)
  # Use ": ${3}.sh" boundary to avoid substring collisions (e.g. "anchored" inside "unanchored").
  if grep -qE "${2}: ${3}\.sh " "$LOG"; then
    echo "PASS [${1}] ${2} detected on ${3}"
    PASS=$((PASS+1))
  else
    echo "FAIL [${1}] ${2} NOT detected on ${3}"
    echo "--- relevant log lines ---"
    grep -E "${3}|${2}" "$LOG" || echo "(no matches)"
    echo "--------------------------"
    FAIL=$((FAIL+1))
  fi
}

assert_NOT_flagged() {
  # $1=label, $2=violation_code_regex, $3=hook_basename (without .sh)
  if grep -qE "${2}: ${3}\.sh " "$LOG"; then
    echo "FAIL [${1}] false-positive: ${2} flagged on ${3}"
    grep -E ": ${3}\.sh" "$LOG" || true
    FAIL=$((FAIL+1))
  else
    echo "PASS [${1}] no false-positive: ${2} NOT on ${3}"
    PASS=$((PASS+1))
  fi
}

# Check 5 — Pattern A
assert_flagged "TC-A" "M-S51-1-IMAGINED-FORMAT" "imagined-format-grep"

# Check 6 — Pattern B
assert_flagged "TC-B" "L-S48m-1-CLAUDE-SESSION-ID-MARKER" "claude-session-id-marker"

# Check 7 — Pattern C (refined S54 + S58 regression)
assert_flagged "TC-C"  "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-err-trap-bare-grep"
assert_flagged "TC-C2" "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-cmd-sub-grep"
assert_flagged "TC-C3" "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-pipeline-grep"
assert_flagged "TC-C-tricky-bare" "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-tricky-bare-grep"

# Check 7 negative
assert_NOT_flagged "TC-C-cond"          "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-if-grep"
assert_NOT_flagged "TC-C-guard"         "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-grep-guarded"
assert_NOT_flagged "TC-C-compound-and"  "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-compound-and-grep"
assert_NOT_flagged "TC-C-compound-pipe" "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-compound-pipe-grep"
assert_NOT_flagged "TC-C-alt-echo"      "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-alt-echo-grep"
assert_NOT_flagged "TC-C-bracket"       "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-bracket-grep"
assert_NOT_flagged "TC-C-and-chain"     "L-S48d-1-PIPEFAIL-BARE-GREP" "pipefail-and-chain-grep"

# Check 8 — Pattern D (NEW S54)
assert_flagged "TC-D" "L-S53-2-UNANCHORED-POSITIONAL-GREP" "unanchored-positional-grep"

# Check 8 negative
assert_NOT_flagged "TC-D-anchored" "L-S53-2-UNANCHORED-POSITIONAL-GREP" "anchored-positional-grep"
assert_NOT_flagged "TC-D-content"  "L-S53-2-UNANCHORED-POSITIONAL-GREP" "content-grep"

# TC-clean — no violations on clean-hook.sh for ANY check
if grep -qE "(M-S51-1|L-S48m-1|L-S48d-1|L-S53-2).*clean-hook" "$LOG"; then
  echo "FAIL [TC-clean] false-positive on clean-hook.sh"
  grep "clean-hook" "$LOG" || true
  FAIL=$((FAIL+1))
else
  echo "PASS [TC-clean] no false-positive on clean-hook.sh"
  PASS=$((PASS+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
