#!/usr/bin/env bash
# Firing-test for session-export-raw.sh (Phase 3.5 T3.4-followup; S53 fix for M-S52-1).
#
# Validates SESSION_N extraction logic post-fix. Prior bug (M-S52-1):
#   Method 2 grepped `^\*\*Session N\*\*:` literal which never matched real `## S<N> — title`
#   header format in current-execution.md → SESSION_N silently empty → fallback to 0
#   → raw-sessions filename always `<DATE>-session-0.md` (collision per session).
#
# Test strategy: stage temp PROJECT_DIR with current-execution.md + transcript file;
# invoke hook with JSON payload via stdin; assert raw-sessions/<DATE>-session-<N>.md
# created with correct N (verified via frontmatter session_n field).
#
# Exit 0 = all assertions pass. Exit 1 = any assertion fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../session-export-raw.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook script not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap "rm -rf $TEMPDIR" EXIT

mkdir -p "$TEMPDIR/agent-workspace/memory" \
         "$TEMPDIR/agent-workspace/raw-sessions" \
         "$TEMPDIR/scripts/hooks"

# Stub redact-secrets.sh (consumed by hook line ~73). Pass-through.
cat > "$TEMPDIR/scripts/hooks/redact-secrets.sh" <<'EOF'
#!/usr/bin/env bash
cat
EOF
chmod +x "$TEMPDIR/scripts/hooks/redact-secrets.sh"

DATE_STR="$(date -u +%Y-%m-%d)"

run_hook() {
  local exec_content="$1"
  local transcript_content="${2:-test transcript content}"

  printf '%s\n' "$exec_content" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
  local transcript_path="$TEMPDIR/transcript.jsonl"
  printf '%s\n' "$transcript_content" > "$transcript_path"

  # Convert path for cross-platform (bash on Windows may need forward slashes).
  local payload
  payload=$(printf '{"transcript_path":"%s","session_id":"test-session-id"}' "$transcript_path")
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<< "$payload" >/dev/null 2>&1 || true
}

# --- TC1: extract LARGEST session from `## S<N>` headers ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

**Phase**: 3.5

## S52 — latest row
## S51 — older
## S50 — older
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-52.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC1: expected $EXPECTED to be created"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
SESSION_N=$(grep -E '^session_n:' "$EXPECTED" | head -1 | awk '{print $2}')
if [ "$SESSION_N" != "52" ]; then
  echo "FAIL TC1: session_n in frontmatter expected 52, got '$SESSION_N'"
  exit 1
fi
echo "PASS TC1: SESSION_N=52 extracted from '## S52' topmost header"

# --- TC2: subordinate formats (S50-pre, S49a, S49b) — extract LARGEST numeric ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

**Phase**: 3.5

## S50 — main
## S50-pre — incident
## S49b — sweep
## S49a — audit
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-50.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC2: expected $EXPECTED to be created"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
SESSION_N=$(grep -E '^session_n:' "$EXPECTED" | head -1 | awk '{print $2}')
if [ "$SESSION_N" != "50" ]; then
  echo "FAIL TC2: subordinate formats — expected 50, got '$SESSION_N'"
  exit 1
fi
echo "PASS TC2: subordinate formats handled — largest numeric (50) wins (S50-pre/S49a/S49b discarded)"

# --- TC3 (post-S53 swap): `## S<N>` header (Method 1) takes precedence over `^S<N> NEXT` marker (Method 2) ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

**Phase**: 3.5

S99 NEXT placeholder

## S52 — latest row
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-52.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC3: '## S52' header should take precedence — expected $EXPECTED missing"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
echo "PASS TC3: '## S52' header (Method 1) takes precedence over 'S99 NEXT' marker (Method 2)"

# --- TC4: fallback to 0 when no markers AND no headers ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

(no session headers, no NEXT marker)
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-0.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC4: expected fallback session-0 when no markers — got:"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
echo "PASS TC4: SESSION_N=0 fallback when no markers and no headers"

# --- TC5: regression — phantom `**Session N**:` literal alone yields fallback 0
# (proves new code does NOT match the old imagined-format pattern accidentally) ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

**Session N**: S99 (phantom format that never existed in real file pre-fix)
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-0.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC5: phantom **Session N**: should yield SESSION_N=0; got:"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
SESSION_N=$(grep -E '^session_n:' "$EXPECTED" | head -1 | awk '{print $2}')
if [ "$SESSION_N" != "0" ]; then
  echo "FAIL TC5: phantom literal accidentally matched — SESSION_N got '$SESSION_N' (expected 0)"
  exit 1
fi
echo "PASS TC5: phantom **Session N**: literal NOT matched by new pattern (regression-proof)"

# --- TC6: anchored `^S<N> NEXT` marker (Method 2) fires when no `## S<N>` headers exist ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

**Phase**: 3.5

S99 NEXT placeholder

(no '## S<N>' headers — Method 2 fallback path test)
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-99.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC6: NEXT marker fallback — expected $EXPECTED missing"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
echo "PASS TC6: anchored 'S99 NEXT' (Method 2) fires correctly when no '## S<N>' headers exist"

# --- TC7 (M-S53-2 regression): unanchored NEXT marker mention in archive prose does NOT match ---
rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md
run_hook "# Current Execution

(no '## S<N>' headers, no anchored NEXT marker)

The archive contains: S38/S42 NEXT branching gate + S34 (this prose mid-line should NOT match)
"

EXPECTED="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-0.md"
if [ ! -f "$EXPECTED" ]; then
  echo "FAIL TC7 (M-S53-2 regression): archive-prose mid-line 'S42 NEXT' should NOT false-positive"
  ls -la "$TEMPDIR/agent-workspace/raw-sessions/" 2>&1 || true
  exit 1
fi
SESSION_N=$(grep -E '^session_n:' "$EXPECTED" | head -1 | awk '{print $2}')
if [ "$SESSION_N" != "0" ]; then
  echo "FAIL TC7: archive-prose 'S42 NEXT' false-positive — SESSION_N got '$SESSION_N' (expected 0)"
  exit 1
fi
echo "PASS TC7 (M-S53-2 regression): archive-prose 'S42 NEXT branching gate' does NOT match (^ anchor works)"

echo ""
echo "=== ALL FIRING-TESTS PASSED (7/7) ==="
echo "session-export-raw.sh M-S52-1 + M-S53-1 + M-S53-2 fix verified empirically."
exit 0
