#!/usr/bin/env bash
# session-export-raw.sh — SessionEnd hook auto-exporting raw transcript to agent-workspace/raw-sessions/.
# Pipes through redact-secrets.sh + cleanText regex BEFORE write so chatter / secrets / system-tags
# don't pollute memory. Adds YAML frontmatter per UP-05 Q3.3 minimalist spec.
# Decision 002 § Track 5 + UP-05 Q4.1=A deliverable.
set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
RAW_DIR="$PROJECT_DIR/agent-workspace/raw-sessions"
mkdir -p "$RAW_DIR"
HOOK_LOG="$PROJECT_DIR/agent-workspace/memory/.session-hooks.log"

PAYLOAD="$(cat 2>/dev/null || true)"
[ -z "$PAYLOAD" ] && exit 0

TRANSCRIPT_PATH="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).transcript_path||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"
SESSION_ID="$(printf '%s' "$PAYLOAD" | node -e "
let s=''; process.stdin.on('data',c=>s+=c);
process.stdin.on('end',()=>{ try { console.log(JSON.parse(s).session_id||''); } catch { console.log(''); } });" 2>/dev/null || echo "")"

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  echo "[$(date -Iseconds)] session-export-raw: no transcript_path; skipping" >> "$HOOK_LOG"
  exit 0
fi

# Determine session number from current-execution.md via 3-tier fallback.
# Fix S13-pre-drift-audit: previous `head -1` of unscoped grep always returned S1
# (line 12 chain "S1 → S2 → ... → S<latest>" → first match always S1) → 10/12 raw
# transcripts overwrote session-1.md / session-5.md, losing provenance.
#
# Method 1 (primary, post-S53): LARGEST `## S<N>` header — real file format. Topmost row
#   in current-execution.md by convention = latest session.
# Method 2 (fallback): explicit "S<N> NEXT" marker, anchored to line start to prevent
#   false-positive on archive prose. Vestigial routing convention; rarely used.
# Method 3 (final fallback): 0 (timestamp filename via caller).
#
# Triple-bug fix at S53 (in dependency order):
#   - M-S52-1: prior Method 2 grepped imagined `^\*\*Session N\*\*:` literal that never
#     matched real `## S<N> — title` header format → SESSION_N silently empty.
#   - M-S53-1: prior pipeline lacked `|| true` → set -o pipefail + trap ERR fired silent
#     exit on unmatched grep BEFORE Method 2 ever ran → masked M-S52-1 fix entirely.
#     Discovered via S53 firing-test; family of L-S48d-1.
#   - M-S53-2: prior Method 1 (NEXT marker) was unanchored → matched archive prose mid-line
#     (e.g. "S38/S42 NEXT branching gate") returning false-positive 42 every export.
#     Discovered via S53 production smoke against real current-execution.md.
# Resolution: swap order so header-scan is primary; anchor NEXT-marker to ^; add `|| true`.
EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
SESSION_N=""
if [ -f "$EXEC_FILE" ]; then
  SESSION_N="$(grep -oE '^## S[0-9]+' "$EXEC_FILE" 2>/dev/null | grep -oE '[0-9]+' | sort -n | tail -1 || true)"
  if [ -z "$SESSION_N" ]; then
    SESSION_N="$(grep -oE '^S[0-9]+[[:space:]]+NEXT' "$EXEC_FILE" 2>/dev/null | head -1 | grep -oE '[0-9]+' | head -1 || true)"
  fi
fi
[ -z "$SESSION_N" ] && SESSION_N="0"

DATE_STR="$(date -u +%Y-%m-%d)"
RAW_FILE="$RAW_DIR/${DATE_STR}-session-${SESSION_N}.md"

# cleanText: strip Claude Code system reminders / command markers / task notifications.
clean_text() {
  python3 -c "
import sys, re
text = sys.stdin.read()
patterns = [
    r'<system-reminder>[\s\S]*?</system-reminder>',
    r'<command-name>.*?</command-name>',
    r'<command-message>.*?</command-message>',
    r'<command-args>.*?</command-args>',
    r'<task-notification>[\s\S]*?</task-notification>',
    r'<local-command-stdout>[\s\S]*?</local-command-stdout>',
    r'<user-prompt-submit-hook>[\s\S]*?</user-prompt-submit-hook>',
]
for p in patterns:
    text = re.sub(p, '[stripped]', text)
sys.stdout.write(text)
" 2>/dev/null
}

# Compose: read transcript → cleanText → redact-secrets → write.
TRANSCRIPT_RAW="$(cat "$TRANSCRIPT_PATH" 2>/dev/null || echo "")"
TRANSCRIPT_CLEAN="$(printf '%s' "$TRANSCRIPT_RAW" | clean_text)"
TRANSCRIPT_REDACTED="$(printf '%s' "$TRANSCRIPT_CLEAN" | bash "$PROJECT_DIR/scripts/hooks/redact-secrets.sh")"

# Compute hash for idempotency.
HASH="$(printf '%s' "$TRANSCRIPT_REDACTED" | python3 -c "
import sys, hashlib
print(hashlib.sha256(sys.stdin.buffer.read()).hexdigest()[:8])
" 2>/dev/null || echo "00000000")"

# Skip re-export if hash matches existing file (idempotency).
if [ -f "$RAW_FILE" ]; then
  EXISTING_HASH="$(grep -E '^hash:' "$RAW_FILE" 2>/dev/null | head -1 | awk -F': ' '{print $2}' | tr -d '"' || echo "")"
  if [ "$EXISTING_HASH" = "$HASH" ]; then
    echo "[$(date -Iseconds)] session-export-raw: hash unchanged ($HASH); skipping re-export" >> "$HOOK_LOG"
    exit 0
  fi
fi

# Count redacted secrets + stripped chatter for metadata.
REDACTED_COUNT="$(printf '%s' "$TRANSCRIPT_REDACTED" | grep -c '\[REDACTED:' 2>/dev/null || echo 0)"
STRIPPED_COUNT="$(printf '%s' "$TRANSCRIPT_CLEAN" | grep -c '\[stripped\]' 2>/dev/null || echo 0)"

TOKEN_COUNT="$(cat "$PROJECT_DIR/agent-workspace/memory/.transcript-tokens" 2>/dev/null | tr -d '[:space:]' || echo 0)"

# Write file with frontmatter.
{
  printf -- '---\n'
  printf 'id: %s-session-%s\n' "$DATE_STR" "$SESSION_N"
  printf 'session_n: %s\n' "$SESSION_N"
  printf 'session_id: %s\n' "${SESSION_ID:-unknown}"
  printf 'exported_at: %s\n' "$(date -Iseconds)"
  printf 'token_count_self_track: %s\n' "$TOKEN_COUNT"
  printf 'hash: %s\n' "$HASH"
  printf 'sanitization:\n'
  printf '  redacted_secrets: %s\n' "$REDACTED_COUNT"
  printf '  stripped_chatter_lines: %s\n' "$STRIPPED_COUNT"
  printf -- '---\n\n'
  printf '%s\n' "$TRANSCRIPT_REDACTED"
} > "$RAW_FILE" 2>/dev/null

echo "[$(date -Iseconds)] session-export-raw: wrote $RAW_FILE (hash=$HASH redacted=$REDACTED_COUNT stripped=$STRIPPED_COUNT tokens=$TOKEN_COUNT)" >> "$HOOK_LOG"
exit 0
