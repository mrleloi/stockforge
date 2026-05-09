#!/usr/bin/env bash
# Firing-test for bash-hook-lint.sh patterns A/B/C/D/E/F extension (Phase 3.5 T3.4 + S54 refinement + S58 KI-S54-1 closure per L-S51-1 + S80 L-S68-2 family three-variant promotion + S81 L-S80-2 Pattern F promotion + S117 Check 3 D-IDENTITY backfill per L-S69-1 self-reference rule).
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
#   Check 9 — Pattern E (L-S68-2 family find/ls on possibly-missing path under pipefail+ERR-trap, NEW S80):
#     TC-E-a  : single-path `find $DIR -name foo` flagged (S68+S75 variant)
#     TC-E-b  : `ls $DIR/*.glob` flagged (S76 variant)
#     TC-E-c  : multi-path `find $A $B $C -type f` flagged (S78 variant)
#     TC-E-2null    : `find $DIR ... 2>/dev/null` NOT flagged (errors silenced)
#     TC-E-altguard : `find $DIR ... || true` NOT flagged (alt-guarded)
#     TC-E-dgaurd   : `[ -d "$DIR" ] && find "$DIR" ...` NOT flagged (same-line file-test guard)
#     TC-E-multiline-2null : multi-line find with 2>/dev/null on tail continuation NOT flagged
#     TC-E-nullglob : ls $dir/*.glob with `shopt -s nullglob` set NOT flagged
#     TC-E-no-precondition : `find $DIR ...` in script WITHOUT pipefail+ERR-trap NOT flagged
#     TC-E-conditional : `if find $DIR ...; then` NOT flagged (conditional consumes exit)
#   Check 10 — Pattern F (L-S80-2 grep -c||echo capture trap, NEW S81):
#     TC-F-a  : `VAR=$(grep -c X file || echo 0)` flagged (basic form)
#     TC-F-b  : `VAR="$(grep -cE 'X' file 2>/dev/null || echo 0)"` flagged (quoted + 2>/dev/null + flag-combo)
#     TC-F-existing : reuse of pipefail-alt-echo-grep.sh (S58 fixture; FIRST line `COUNT=$(grep -c ...)` matches Pattern F)
#     TC-F-or-true : `VAR=$(grep -c ... || true)` NOT flagged (no echo N)
#     TC-F-no-or : `VAR=$(grep -c ... )` NOT flagged (no || at all)
#     TC-F-no-c-flag : `VAR=$(grep -E pat file || echo 0)` NOT flagged (grep without -c → not the trap)
#     TC-F-comment : commented-line containing the pattern NOT flagged
#   Check 3 — D-IDENTITY-AUTONOMOUS-REGRESSION (NEW S117 backfill; L-S69-1 self-reference allow-list):
#     TC-D-IDENTITY-bare      : bare regression line (no denial / no negation) → flagged
#     TC-D-IDENTITY-denial    : regression + existing denial markers (`forbidden|fabricated|...`) → NOT flagged
#     TC-D-IDENTITY-negation  : regression in `no <pattern>` negation form (S117 NEW) → NOT flagged
#     TC-D-IDENTITY-self-ref  : line referencing the lint check itself (`bash-hook-lint`/`D-IDENTITY`; S117 NEW) → NOT flagged
#   TC-clean — pure clean hook NOT flagged for any check.
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../bash-hook-lint.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap '[ -n "${KEEP_TEMP:-}" ] && echo "(KEEP_TEMP set; tempdir at $TEMPDIR)" || rm -rf "$TEMPDIR"' EXIT

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

# === Pattern E (Check 9) — TC-E-a: single-path `find $DIR -name foo` flagged (S68+S75 variant) ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-single-path.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
RESULT=$(find "$DIR" -name '*.md' -mtime -1)
echo "$RESULT"
EOF

# === Pattern E (Check 9) — TC-E-b: `ls $DIR/*.glob` flagged (S76 variant) ===
cat > "$TEMPDIR/scripts/hooks/pipefail-ls-glob.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
FILES=$(ls "$DIR"/*.md)
echo "$FILES"
EOF

# === Pattern E (Check 9) — TC-E-c: multi-path `find $A $B $C` flagged (S78 variant) ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-multi-path.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
A="$PROJECT_DIR/dir1"
B="$PROJECT_DIR/dir2"
C="$PROJECT_DIR/dir3"
RESULT=$(find "$A" "$B" "$C" -type f -name '*.md')
echo "$RESULT"
EOF

# === Pattern E negative — TC-E-2null: 2>/dev/null silences errors ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-2null.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
RESULT=$(find "$DIR" -name '*.md' 2>/dev/null)
echo "$RESULT"
EOF

# === Pattern E negative — TC-E-altguard: `|| true` alt-guarded ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-altguard.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
RESULT=$(find "$DIR" -name '*.md' || true)
echo "$RESULT"
EOF

# === Pattern E negative — TC-E-dguard: same-line `[ -d "$DIR" ] && find` guard ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-dguard.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
[ -d "$DIR" ] && find "$DIR" -name '*.md'
EOF

# === Pattern E negative — TC-E-multiline-2null: multi-line find with 2>/dev/null on tail ===
# Mirrors charter-coherence-spot.sh + taskcompleted-audit.sh production form.
cat > "$TEMPDIR/scripts/hooks/pipefail-find-multiline-2null.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
TARGETS="$(find "$PROJECT_DIR/dir1" \
                "$PROJECT_DIR/dir2" \
                "$PROJECT_DIR/dir3" \
            -type f -name '*.md' 2>/dev/null | head -10)"
echo "$TARGETS"
EOF

# === Pattern E negative — TC-E-nullglob: shopt -s nullglob covers ls glob no-match ===
cat > "$TEMPDIR/scripts/hooks/pipefail-ls-nullglob.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
shopt -s nullglob
DIR="$PROJECT_DIR/maybe-missing"
FILES=$(ls "$DIR"/*.md)
echo "$FILES"
EOF

# === Pattern E negative — TC-E-no-precondition: no pipefail+ERR-trap ===
# Without the precondition, ERR trap can't fire silently — risk doesn't apply.
cat > "$TEMPDIR/scripts/hooks/find-no-precondition.sh" <<'EOF'
#!/usr/bin/env bash
set -u
DIR="$PROJECT_DIR/maybe-missing"
RESULT=$(find "$DIR" -name '*.md')
echo "$RESULT"
EOF

# === Pattern E negative — TC-E-conditional: `if find ...; then` form ===
cat > "$TEMPDIR/scripts/hooks/pipefail-find-conditional.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
trap 'exit 0' ERR
DIR="$PROJECT_DIR/maybe-missing"
if find "$DIR" -mtime -1 2>/dev/null | grep -q .; then
  echo "found"
fi
EOF

# === Pattern F (Check 10) — TC-F-a: basic `VAR=$(grep -c X file || echo 0)` flagged ===
cat > "$TEMPDIR/scripts/hooks/grep-c-or-echo-basic.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
LOG="$PROJECT_DIR/log.txt"
COUNT=$(grep -c 'foo' "$LOG" || echo 0)
echo "$COUNT"
EOF

# === Pattern F (Check 10) — TC-F-b: quoted form with 2>/dev/null + flag-combo `-cE` ===
cat > "$TEMPDIR/scripts/hooks/grep-c-or-echo-quoted-flagcombo.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
LOG="$PROJECT_DIR/log.txt"
COUNT="$(grep -cE 'foo|bar' "$LOG" 2>/dev/null || echo 0)"
if [ "$COUNT" -gt 0 ] 2>/dev/null; then echo "found"; fi
EOF

# === Pattern F negative — TC-F-or-true: `|| true` (no echo N) NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/grep-c-or-true.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
LOG="$PROJECT_DIR/log.txt"
COUNT=$(grep -c 'foo' "$LOG" || true)
echo "$COUNT"
EOF

# === Pattern F negative — TC-F-no-or: no `||` at all NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/grep-c-no-or.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
COUNT=$(grep -c 'foo' "$LOG")
echo "$COUNT"
EOF

# === Pattern F negative — TC-F-no-c-flag: grep without `-c` flag NOT flagged ===
# `grep -E pat file || echo 0` is NOT the L-S80-2 trap (no count emission; if grep fails,
# only echo's "0" lands in capture — single-line "0", not multi-line "0\n0").
cat > "$TEMPDIR/scripts/hooks/grep-no-c-or-echo.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
LOG="$PROJECT_DIR/log.txt"
RESULT=$(grep -E '^foo' "$LOG" || echo 0)
echo "$RESULT"
EOF

# === Pattern F negative — TC-F-comment: commented-out line NOT flagged ===
cat > "$TEMPDIR/scripts/hooks/grep-c-comment.sh" <<'EOF'
#!/usr/bin/env bash
set -u
LOG="$PROJECT_DIR/log.txt"
# COUNT=$(grep -c 'foo' "$LOG" || echo 0)  -- this is a doc comment showing the antipattern
COUNT=0
echo "$COUNT"
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

# === Check 3 (D-IDENTITY-AUTONOMOUS-REGRESSION) fixtures (NEW S117) ===
# Stage live-target markdown files in $TEMPDIR/agent-workspace/constitution/.
# Check 3 scans these for SUPERVISED|autonomous_mode:false|until Track 7 patterns.
mkdir -p "$TEMPDIR/agent-workspace/constitution"

# TC-D-IDENTITY-bare: regression line with NO denial / NO negation / NO self-ref → SHOULD flag
cat > "$TEMPDIR/agent-workspace/constitution/d-identity-tc-bare.md" <<'EOF'
# Stub Doctrine
Default mode is SUPERVISED mode until Track 7 completes.
EOF

# TC-D-IDENTITY-denial: regression line with denial marker (existing allow-list) → NOT flagged
cat > "$TEMPDIR/agent-workspace/constitution/d-identity-tc-denial.md" <<'EOF'
# Doctrine: Denial Form
The fabricated SUPERVISED mode framing is forbidden — never user-authorized.
EOF

# TC-D-IDENTITY-negation: regression line with `no <pattern>` negation form (S117 NEW allow-list) → NOT flagged
cat > "$TEMPDIR/agent-workspace/constitution/d-identity-tc-negation.md" <<'EOF'
# Doctrine: Negation Form
There is no SUPERVISED bifurcation, no human-in-the-loop default mode, no "until Track 7" gate.
EOF

# TC-D-IDENTITY-self-ref: line referencing the lint check itself (S117 NEW allow-list) → NOT flagged
cat > "$TEMPDIR/agent-workspace/constitution/d-identity-tc-self-ref.md" <<'EOF'
# Doctrine: Self-Reference
The drift signal `bash-hook-lint.sh § D-IDENTITY` scans LIVE config for `SUPERVISED|autonomous_mode:\s*false|until Track 7` regression and soft-warns.
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

assert_flagged_path() {
  # $1=label, $2=violation_code, $3=relative_path (full; e.g. "agent-workspace/constitution/foo.md")
  # Used for Check 3 (D-IDENTITY) which emits with full file path, not basename.
  if grep -qE "${2}: ${3} " "$LOG"; then
    echo "PASS [${1}] ${2} detected on ${3}"
    PASS=$((PASS+1))
  else
    echo "FAIL [${1}] ${2} NOT detected on ${3}"
    grep -E "${3}|${2}" "$LOG" || echo "(no matches)"
    FAIL=$((FAIL+1))
  fi
}

assert_NOT_flagged_path() {
  # $1=label, $2=violation_code, $3=relative_path (full)
  if grep -qE "${2}: ${3} " "$LOG"; then
    echo "FAIL [${1}] false-positive: ${2} flagged on ${3}"
    grep -E "${3}" "$LOG" || true
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

# Check 9 — Pattern E (NEW S80; L-S68-2 family three-variant)
assert_flagged "TC-E-a" "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-single-path"
assert_flagged "TC-E-b" "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-ls-glob"
assert_flagged "TC-E-c" "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-multi-path"

# Check 9 negative
assert_NOT_flagged "TC-E-2null"            "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-2null"
assert_NOT_flagged "TC-E-altguard"         "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-altguard"
assert_NOT_flagged "TC-E-dguard"           "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-dguard"
assert_NOT_flagged "TC-E-multiline-2null"  "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-multiline-2null"
assert_NOT_flagged "TC-E-nullglob"         "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-ls-nullglob"
assert_NOT_flagged "TC-E-no-precondition"  "L-S68-2-FIND-LS-MISSING-PATH" "find-no-precondition"
assert_NOT_flagged "TC-E-conditional"      "L-S68-2-FIND-LS-MISSING-PATH" "pipefail-find-conditional"

# Check 10 — Pattern F (NEW S81; L-S80-2 grep -c||echo capture trap)
assert_flagged "TC-F-a"        "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-c-or-echo-basic"
assert_flagged "TC-F-b"        "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-c-or-echo-quoted-flagcombo"
assert_flagged "TC-F-existing" "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "pipefail-alt-echo-grep"

# Check 10 negative
assert_NOT_flagged "TC-F-or-true"    "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-c-or-true"
assert_NOT_flagged "TC-F-no-or"      "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-c-no-or"
assert_NOT_flagged "TC-F-no-c-flag"  "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-no-c-or-echo"
assert_NOT_flagged "TC-F-comment"    "L-S80-2-GREP-C-OR-ECHO-CAPTURE-TRAP" "grep-c-comment"

# Check 3 — D-IDENTITY-AUTONOMOUS-REGRESSION (NEW S117 backfill)
assert_flagged_path     "TC-D-IDENTITY-bare"     "D-IDENTITY-AUTONOMOUS-REGRESSION" "agent-workspace/constitution/d-identity-tc-bare.md"
assert_NOT_flagged_path "TC-D-IDENTITY-denial"   "D-IDENTITY-AUTONOMOUS-REGRESSION" "agent-workspace/constitution/d-identity-tc-denial.md"
assert_NOT_flagged_path "TC-D-IDENTITY-negation" "D-IDENTITY-AUTONOMOUS-REGRESSION" "agent-workspace/constitution/d-identity-tc-negation.md"
assert_NOT_flagged_path "TC-D-IDENTITY-self-ref" "D-IDENTITY-AUTONOMOUS-REGRESSION" "agent-workspace/constitution/d-identity-tc-self-ref.md"

# TC-clean — no violations on clean-hook.sh for ANY check (now includes L-S80-2)
if grep -qE "(M-S51-1|L-S48m-1|L-S48d-1|L-S53-2|L-S68-2|L-S80-2).*clean-hook" "$LOG"; then
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
