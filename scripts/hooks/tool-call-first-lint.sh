#!/usr/bin/env bash
# tool-call-first-lint.sh — Stop hook lint for Mode A (narrate-without-tool-call).
# Reads stdin JSON, extracts last assistant turn, classifies as Mode-A if narration verbs
# present without tool_use block. v1: advisory-only (always exits 0); v2 will block.
# Ported from orch v2.2.0 (verbatim).

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_DIR="$PROJECT_DIR/agent-workspace/memory"
mkdir -p "$LOG_DIR"
LINT_LOG="$LOG_DIR/.tool-call-first-lint.log"
TS="$(date -Iseconds 2>/dev/null || date)"

contains_narration_verb() {
  grep -qEi \
    '(Dispatching|Will run|Will dispatch|About to|Now (running|dispatching)|Awaiting (sandwich|task|spec|code|systematic|verifier|reviewer|implementer))' \
    2>/dev/null
}

get_verb_hint() {
  local text="$1"
  printf '%s' "$text" | grep -oEi \
    '(Dispatching|Will run|Will dispatch|About to|Now (running|dispatching)|Awaiting (sandwich|task|spec|code|systematic|verifier|reviewer|implementer))[^.!?\n]*' \
    2>/dev/null | head -1 || true
}

extract_last_assistant_turn() {
  local transcript_path="$1"
  tail -c 32768 "$transcript_path" 2>/dev/null | awk '
  {
    if (index($0, "\"role\":\"assistant\"") > 0) { last_line = $0 }
  }
  END {
    if (last_line == "") { exit 1 }
    if (index(last_line, "\"type\":\"tool_use\"") > 0) { print "HAS_TOOL_USE=1" } else { print "HAS_TOOL_USE=0" }
    s = last_line
    while (length(s) > 0) {
      i = index(s, "\"text\":\"")
      if (i == 0) break
      s = substr(s, i + 8)
      j = index(s, "\"")
      if (j == 0) break
      val = substr(s, 1, j - 1)
      if (length(val) > 0) print val
      s = substr(s, j + 1)
    }
  }
  '
}

emit_warning() {
  local session_id="$1" verb_hint="$2"
  local msg="[TS=$TS] [session=$session_id] mode_a_suspected=true narration_only=true verb_hint=\"$verb_hint\""
  echo "$msg" >> "$LINT_LOG"
  echo "[tool-call-first-lint] WARNING: Mode-A suspected — narration verb without tool_use block detected. $msg" >&2
}

STDIN_JSON="$(cat 2>/dev/null || true)"
TRANSCRIPT_PATH=""
SESSION_ID=""

if [[ -n "$STDIN_JSON" ]]; then
  TRANSCRIPT_PATH="$(printf '%s' "$STDIN_JSON" | grep -o '"transcript_path":"[^"]*"' | sed 's/"transcript_path":"//;s/"//' | head -1 || true)"
  SESSION_ID="$(printf '%s' "$STDIN_JSON" | grep -o '"session_id":"[^"]*"' | sed 's/"session_id":"//;s/"//' | head -1 || true)"
fi

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then exit 0; fi

EXEC_FILE="$PROJECT_DIR/agent-workspace/memory/current-execution.md"
if [[ ! -f "$EXEC_FILE" ]]; then exit 0; fi
if ! grep -qE '^\*\*autonomous_mode\*\*:\s*true' "$EXEC_FILE" 2>/dev/null; then exit 0; fi

TURN_OUTPUT=""
if ! TURN_OUTPUT="$(extract_last_assistant_turn "$TRANSCRIPT_PATH")"; then
  echo "[TS=$TS] [session=${SESSION_ID:-unknown}] parse_error=no_assistant_turn_found" >> "$LINT_LOG"
  exit 0
fi

if [[ -z "$TURN_OUTPUT" ]]; then
  echo "[TS=$TS] [session=${SESSION_ID:-unknown}] parse_error=empty_content" >> "$LINT_LOG"
  exit 0
fi

HAS_TOOL_USE_LINE="$(printf '%s\n' "$TURN_OUTPUT" | head -1)"
TEXT_CONTENT="$(printf '%s\n' "$TURN_OUTPUT" | tail -n +2)"

HAS_TOOL_USE="0"
[[ "$HAS_TOOL_USE_LINE" == "HAS_TOOL_USE=1" ]] && HAS_TOOL_USE="1"

NARRATION_VERB_HIT=""
if [[ -n "$TEXT_CONTENT" ]]; then
  if printf '%s' "$TEXT_CONTENT" | contains_narration_verb; then
    NARRATION_VERB_HIT="$(get_verb_hint "$TEXT_CONTENT")"
  fi
fi

[[ -z "$NARRATION_VERB_HIT" ]] && exit 0
[[ "$HAS_TOOL_USE" == "1" ]] && exit 0

emit_warning "${SESSION_ID:-unknown}" "$NARRATION_VERB_HIT"
exit 0
