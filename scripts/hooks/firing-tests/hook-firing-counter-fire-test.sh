#!/usr/bin/env bash
# Firing-test for hook-firing-counter.sh (Phase 3.5 T3.4 Cluster 5 per L-S51-1).
#
# Stages a synthetic .claude/settings.json declaring 3 hooks + .session-hooks.log
# with evidence for only one of them; asserts hook-firing-counter detects 2 silent hooks.
# Negative case: all hooks fired → no alert.
#
# Real file shapes referenced:
#   .claude/settings.json hooks chain entries: "command": "bash scripts/hooks/<name>.sh"
#   .session-hooks.log lines: [ISO-timestamp] event=... session=... (hook names appear
#     either as direct emit lines or as substrings of structured warnings)
#
# Exit 0 = all assertions pass.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="$SCRIPT_DIR/../hook-firing-counter.sh"
[ ! -f "$HOOK" ] && { echo "FAIL: hook not found at $HOOK"; exit 1; }

TEMPDIR=$(mktemp -d)
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir -p "$TEMPDIR/.claude"
mkdir -p "$TEMPDIR/agent-workspace/memory"

PASS=0; FAIL=0

# === TC1: 3 hooks declared, 1 fired (active-hook), 2 silent → ALERT count=2 ===
cat > "$TEMPDIR/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [
      {"hooks": [
        {"type": "command", "command": "bash scripts/hooks/active-hook.sh"},
        {"type": "command", "command": "bash scripts/hooks/silent-hook.sh"}
      ]}
    ],
    "UserPromptSubmit": [
      {"hooks": [
        {"type": "command", "command": "bash scripts/hooks/another-silent.sh"}
      ]}
    ]
  }
}
EOF

# session-hooks.log with active-hook reference (recent)
TS_NOW="$(date -Iseconds 2>/dev/null || date)"
printf '[%s] active-hook fired session=test\n' "$TS_NOW" > "$TEMPDIR/agent-workspace/memory/.session-hooks.log"

# Per-hook log for active-hook (recent mtime)
printf 'recent log\n' > "$TEMPDIR/agent-workspace/memory/.active-hook.log"

# silent-hook + another-silent: NO log file, NOT in session-hooks.log

STDERR_TC1=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)

if printf '%s' "$STDERR_TC1" | grep -qE "2 hook\(s\) with 0 firings"; then
  echo "PASS [TC1] 2 silent hooks detected"
  PASS=$((PASS+1))
else
  printf 'FAIL [TC1] expected "2 hook(s) with 0 firings"; got: %s\n' "$STDERR_TC1"
  cat "$TEMPDIR/agent-workspace/memory/.hook-firing-counter.log" 2>/dev/null || true
  FAIL=$((FAIL+1))
fi

# Counter log lists both silent hooks by name
COUNTER_LOG="$TEMPDIR/agent-workspace/memory/.hook-firing-counter.log"
if [ -f "$COUNTER_LOG" ] \
   && grep -q "silent-hook.sh" "$COUNTER_LOG" \
   && grep -q "another-silent.sh" "$COUNTER_LOG"; then
  echo "PASS [TC2] counter log lists both silent hooks by name"
  PASS=$((PASS+1))
else
  echo "FAIL [TC2] counter log incomplete"
  [ -f "$COUNTER_LOG" ] && cat "$COUNTER_LOG"
  FAIL=$((FAIL+1))
fi

# === TC3: All hooks fired → no alert ===
rm -f "$COUNTER_LOG"
cat > "$TEMPDIR/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [
      {"hooks": [
        {"type": "command", "command": "bash scripts/hooks/all-fired.sh"}
      ]}
    ]
  }
}
EOF
TS_NOW2="$(date -Iseconds 2>/dev/null || date)"
printf '[%s] all-fired completed session=test\n' "$TS_NOW2" > "$TEMPDIR/agent-workspace/memory/.session-hooks.log"

STDERR_TC3=$(CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" 2>&1 >/dev/null || true)

if printf '%s' "$STDERR_TC3" | grep -q "with 0 firings"; then
  printf 'FAIL [TC3] should be silent (all hooks fired); got: %s\n' "$STDERR_TC3"
  FAIL=$((FAIL+1))
else
  echo "PASS [TC3] all hooks fired → no alert"
  PASS=$((PASS+1))
fi

# === TC4: S188 D-044 H-c contract — hook emits minimal stdout JSON on chain tail
# (UserPromptSubmit chain truncation hypothesis: stdout JSON re-emission required
# at segment boundary at hook #5/#6 on Claude Code Windows).
# Reuses TC3 sandbox (all-fired path, silent_count=0); captures STDOUT separately
# via file-based fixture per L-S176-1 (avoids inline shell-quote pitfalls).
STDOUT_TC4_FILE="$TEMPDIR/tc4-stdout.json"
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" > "$STDOUT_TC4_FILE" 2>/dev/null || true

# Validate JSON structure: hookSpecificOutput.hookEventName=='UserPromptSubmit'
# AND hookSpecificOutput.additionalContext==''
TC4_RESULT=$(node -e "
const fs=require('fs');
try {
  const s=fs.readFileSync(process.argv[1],'utf8');
  const j=JSON.parse(s);
  if (!j.hookSpecificOutput) { console.log('FAIL:no-hookSpecificOutput'); process.exit(0); }
  const o=j.hookSpecificOutput;
  if (o.hookEventName !== 'UserPromptSubmit') { console.log('FAIL:wrong-event:'+o.hookEventName); process.exit(0); }
  if (o.additionalContext !== '') { console.log('FAIL:non-empty-context:'+JSON.stringify(o.additionalContext)); process.exit(0); }
  const keys=Object.keys(o).sort().join(',');
  if (keys !== 'additionalContext,hookEventName') { console.log('FAIL:extra-keys:'+keys); process.exit(0); }
  console.log('OK');
} catch(e) { console.log('FAIL:parse-error:'+e.message); }
" "$STDOUT_TC4_FILE" 2>/dev/null)

if [ "$TC4_RESULT" = "OK" ]; then
  echo "PASS [TC4] hook emits stdout JSON {hookEventName:'UserPromptSubmit',additionalContext:''} on all-fired path"
  PASS=$((PASS+1))
else
  printf 'FAIL [TC4] stdout JSON contract broken: %s; raw: %s\n' "$TC4_RESULT" "$(cat "$STDOUT_TC4_FILE")"
  FAIL=$((FAIL+1))
fi

# === TC5: S188 D-044 H-c contract — same stdout JSON contract on silent>0 path
# (TC1 reproduces silent_count=2 setup; verifies stdout JSON emits AFTER stderr alert).
cat > "$TEMPDIR/.claude/settings.json" <<'EOF'
{
  "hooks": {
    "Stop": [
      {"hooks": [
        {"type": "command", "command": "bash scripts/hooks/active-hook.sh"},
        {"type": "command", "command": "bash scripts/hooks/silent-hook.sh"}
      ]}
    ],
    "UserPromptSubmit": [
      {"hooks": [
        {"type": "command", "command": "bash scripts/hooks/another-silent.sh"}
      ]}
    ]
  }
}
EOF
TS_NOW3="$(date -Iseconds 2>/dev/null || date)"
printf '[%s] active-hook fired session=test\n' "$TS_NOW3" > "$TEMPDIR/agent-workspace/memory/.session-hooks.log"
printf 'recent log\n' > "$TEMPDIR/agent-workspace/memory/.active-hook.log"
rm -f "$TEMPDIR/agent-workspace/memory/.hook-firing-counter.log"

STDOUT_TC5_FILE="$TEMPDIR/tc5-stdout.json"
CLAUDE_PROJECT_DIR="$TEMPDIR" bash "$HOOK" > "$STDOUT_TC5_FILE" 2>/dev/null || true

TC5_RESULT=$(node -e "
const fs=require('fs');
try {
  const s=fs.readFileSync(process.argv[1],'utf8');
  const j=JSON.parse(s);
  if (!j.hookSpecificOutput) { console.log('FAIL:no-hookSpecificOutput'); process.exit(0); }
  const o=j.hookSpecificOutput;
  if (o.hookEventName !== 'UserPromptSubmit') { console.log('FAIL:wrong-event'); process.exit(0); }
  if (o.additionalContext !== '') { console.log('FAIL:non-empty-context'); process.exit(0); }
  console.log('OK');
} catch(e) { console.log('FAIL:parse-error:'+e.message); }
" "$STDOUT_TC5_FILE" 2>/dev/null)

if [ "$TC5_RESULT" = "OK" ]; then
  echo "PASS [TC5] hook emits stdout JSON on silent>0 path (alongside stderr alert)"
  PASS=$((PASS+1))
else
  printf 'FAIL [TC5] stdout JSON contract broken on silent>0 path: %s; raw: %s\n' "$TC5_RESULT" "$(cat "$STDOUT_TC5_FILE")"
  FAIL=$((FAIL+1))
fi

echo ""
printf '=== TOTAL: PASS=%d FAIL=%d (target: 5/5) ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
