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

# ============================================================
# TC8-TC12: S321 IMPORTANT-2 — clean_text behavioral coverage
# These TCs exercise the awk state machine directly via a
# transcript that contains each edge-case shape. They verify
# that the raw-session output file contains the expected text
# (using the stub redact-secrets.sh that is a passthrough).
# ============================================================

# Helper: invoke hook and return raw-session content for given session_n
get_raw_content() {
  local transcript_content="$1"
  local session_n="${2:-52}"
  rm -f "$TEMPDIR/agent-workspace/raw-sessions/"*.md

  printf '## S%s — test\n' "$session_n" > "$TEMPDIR/agent-workspace/memory/current-execution.md"
  local transcript_path="$TEMPDIR/transcript_ct.jsonl"
  printf '%s\n' "$transcript_content" > "$transcript_path"
  local payload
  payload=$(printf '{"transcript_path":"%s","session_id":"test-ct"}' "$transcript_path")
  CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" <<< "$payload" >/dev/null 2>&1 || true

  local raw_file="$TEMPDIR/agent-workspace/raw-sessions/${DATE_STR}-session-${session_n}.md"
  if [ -f "$raw_file" ]; then
    # Strip the YAML frontmatter (lines 1..5) and return the body
    tail -n +6 "$raw_file"
  else
    echo "(raw file not created)"
  fi
}

# TC8: normal multi-line tag — tag on its own line → [stripped]; surrounding plain text preserved
CONTENT_TC8="$(printf 'line before tag\n<system-reminder>\ntag content hidden\n</system-reminder>\nline after tag\n')"
OUT8="$(get_raw_content "$CONTENT_TC8" 53)"
if printf '%s' "$OUT8" | grep -q 'tag content hidden'; then
  echo "FAIL TC8: multi-line tag inner content should be stripped but found 'tag content hidden'"
  exit 1
fi
if printf '%s' "$OUT8" | grep -q '\[stripped\]' && printf '%s' "$OUT8" | grep -q 'line before tag' && printf '%s' "$OUT8" | grep -q 'line after tag'; then
  echo "PASS TC8: multi-line tag stripped; surrounding text preserved"
else
  echo "FAIL TC8: expected [stripped] + surrounding text; got: $OUT8"
  exit 1
fi

# TC9: single-line tag — stripped inline, surrounding text preserved
CONTENT_TC9="$(printf 'hello <command-name>foo-cmd</command-name> world\n')"
OUT9="$(get_raw_content "$CONTENT_TC9" 54)"
if printf '%s' "$OUT9" | grep -q 'foo-cmd'; then
  echo "FAIL TC9: single-line tag inner content should be stripped but found 'foo-cmd'"
  exit 1
fi
if printf '%s' "$OUT9" | grep -q 'hello \[stripped\] world'; then
  echo "PASS TC9: single-line tag stripped in place; surrounding text preserved"
else
  echo "FAIL TC9: expected 'hello [stripped] world'; got: $OUT9"
  exit 1
fi

# TC10 (IMPORTANT-2 fix a): same-line text before opening / after closing multi-line tag
# Python re.sub: "line before [stripped] line after"
CONTENT_TC10="$(printf 'line before <system-reminder>\nhidden content\n</system-reminder> line after\n')"
OUT10="$(get_raw_content "$CONTENT_TC10" 55)"
if printf '%s' "$OUT10" | grep -q 'hidden content'; then
  echo "FAIL TC10: hidden content inside tag should be stripped"
  exit 1
fi
if printf '%s' "$OUT10" | grep -q 'line before' && printf '%s' "$OUT10" | grep -q 'line after'; then
  echo "PASS TC10 (fix-a): same-line text before opening and after closing preserved"
else
  echo "FAIL TC10: expected 'line before' AND 'line after' preserved; got: $OUT10"
  exit 1
fi

# TC11 (IMPORTANT-2 fix b): mixed line — single-line tag followed by opening multi-line tag
# Python re.sub: "mixed [stripped] then [stripped]\n[stripped]"
CONTENT_TC11="$(printf 'mixed <command-name>x</command-name> then <system-reminder>\nmore content\n</system-reminder>\n')"
OUT11="$(get_raw_content "$CONTENT_TC11" 56)"
if printf '%s' "$OUT11" | grep -q 'more content'; then
  echo "FAIL TC11: multi-line tag content should be stripped"
  exit 1
fi
if printf '%s' "$OUT11" | grep -q 'mixed' && printf '%s' "$OUT11" | grep -q '\[stripped\]' && printf '%s' "$OUT11" | grep -q 'then'; then
  echo "PASS TC11 (fix-b): mixed line: inline strip ran + surrounding text preserved"
else
  echo "FAIL TC11: expected 'mixed' + '[stripped]' + 'then'; got: $OUT11"
  exit 1
fi

# TC12 (IMPORTANT-2 fix c): unclosed multi-line tag at EOF — should emit [stripped], not drop content
CONTENT_TC12="$(printf 'normal line\nunclosed <task-notification>\nline after open tag\nEOF line\n')"
OUT12="$(get_raw_content "$CONTENT_TC12" 57)"
if printf '%s' "$OUT12" | grep -q '\[stripped\]'; then
  echo "PASS TC12 (fix-c): unclosed tag at EOF emits [stripped] (no silent content loss)"
else
  echo "FAIL TC12: unclosed tag at EOF should emit [stripped]; got: $OUT12"
  exit 1
fi

echo ""
echo "=== ALL FIRING-TESTS PASSED (12/12) ==="
echo "session-export-raw.sh M-S52-1 + M-S53-1 + M-S53-2 fix + S321 IMPORTANT-2 clean_text fix verified empirically."
exit 0
