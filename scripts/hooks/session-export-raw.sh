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
# S319b L-S11-1: rewritten from python3 to awk (bash+POSIX). Multi-line XML tag ranges
# handled via awk state machine. S321 IMPORTANT-2 fix: corrected 3 behavioral divergences
# from the python re.sub reference:
#   (a) same-line text BEFORE an opening / AFTER a closing multi-line tag was LOST — now
#       the pre-tag prefix is kept and the post-close suffix is kept (strip in place).
#   (b) on a mixed line (single-line tag + opening multi-line tag), strip_inline now runs
#       BEFORE the open-multi-line check, so inline-stripped text is preserved.
#   (c) an unclosed multi-line tag to EOF now flushes a single "[stripped]" instead of
#       silently dropping buffered context (matches python fallback behaviour).
clean_text() {
  awk '
  function strip_inline(line,    i, out, t, open_pos, close_pos, close_pat) {
    # Strip single-line tags: <tag>...</tag> on same line → [stripped]
    tags[1]="system-reminder"; tags[2]="command-name"; tags[3]="command-message";
    tags[4]="command-args";    tags[5]="task-notification";
    tags[6]="local-command-stdout"; tags[7]="user-prompt-submit-hook";
    out = line
    for (i=1; i<=7; i++) {
      t = tags[i]
      while (index(out, "<" t ">") > 0 && index(out, "</" t ">") > 0) {
        open_pos = index(out, "<" t ">")
        close_pat = "</" t ">"
        close_pos = index(out, close_pat)
        if (close_pos > open_pos) {
          out = substr(out, 1, open_pos - 1) "[stripped]" substr(out, close_pos + length(close_pat))
        } else { break }
      }
    }
    return out
  }
  BEGIN {
    in_tag = 0; cur_tag = ""
    split("system-reminder command-name command-message command-args task-notification local-command-stdout user-prompt-submit-hook", tag_list, " ")
  }
  {
    if (in_tag) {
      # We are inside a multi-line tag; look for the closing tag on this line.
      close_pat = "</" cur_tag ">"
      if (index($0, close_pat) > 0) {
        # S321 fix (a): keep text AFTER the closing tag on the same line.
        after_close = substr($0, index($0, close_pat) + length(close_pat))
        print "[stripped]" after_close
        in_tag = 0; cur_tag = ""
      }
      # Lines wholly inside the multi-line tag range are suppressed (next).
      next
    }
    # S321 fix (b): run strip_inline FIRST so single-line tags on a mixed line are
    # handled before we test for an opening multi-line tag.
    line = strip_inline($0)
    # Check for an opening multi-line tag (open but no close on the same post-inline line).
    for (i in tag_list) {
      t = tag_list[i]
      if (index(line, "<" t ">") > 0 && index(line, "</" t ">") == 0) {
        # S321 fix (a): keep text BEFORE the opening tag on this line.
        open_pos = index(line, "<" t ">")
        prefix = substr(line, 1, open_pos - 1)
        if (length(prefix) > 0) { printf "%s", prefix }
        in_tag = 1; cur_tag = t
        next
      }
    }
    print line
  }
  END {
    # S321 fix (c): if we reach EOF while still inside a multi-line tag, emit [stripped]
    # rather than silently dropping the buffered context.
    if (in_tag) { print "[stripped]" }
  }
  ' 2>/dev/null
}

# Compose: read transcript → cleanText → redact-secrets → write.
TRANSCRIPT_RAW="$(cat "$TRANSCRIPT_PATH" 2>/dev/null || echo "")"
TRANSCRIPT_CLEAN="$(printf '%s' "$TRANSCRIPT_RAW" | clean_text)"
TRANSCRIPT_REDACTED="$(printf '%s' "$TRANSCRIPT_CLEAN" | bash "$PROJECT_DIR/scripts/hooks/redact-secrets.sh")"

# Compute hash for idempotency.
# S319b L-S11-1: rewritten from python3 hashlib to sha256sum (available on Git-Bash/Linux/macOS).
# sha256sum outputs "<hexhash>  -"; take first 8 chars of the hash field.
HASH="$(printf '%s' "$TRANSCRIPT_REDACTED" | sha256sum 2>/dev/null | cut -c1-8 || echo "00000000")"

# Skip re-export if hash matches existing file (idempotency).
if [ -f "$RAW_FILE" ]; then
  EXISTING_HASH="$(grep -E '^hash:' "$RAW_FILE" 2>/dev/null | head -1 | awk -F': ' '{print $2}' | tr -d '"' || echo "")"
  if [ "$EXISTING_HASH" = "$HASH" ]; then
    echo "[$(date -Iseconds)] session-export-raw: hash unchanged ($HASH); skipping re-export" >> "$HOOK_LOG"
    exit 0
  fi
fi

# Count redacted secrets + stripped chatter for metadata.
REDACTED_COUNT="$(printf '%s' "$TRANSCRIPT_REDACTED" | grep -c '\[REDACTED:' 2>/dev/null || true)"
STRIPPED_COUNT="$(printf '%s' "$TRANSCRIPT_CLEAN" | grep -c '\[stripped\]' 2>/dev/null || true)"

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
