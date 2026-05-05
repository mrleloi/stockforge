#!/usr/bin/env bash
# write-vs-edit-guard.sh — PreToolUse HARD-BLOCK enforcing L-S45-2 doctrine.
#
# Origin: 2026-05-05 S45 sandwich-architect data-loss incident.
# A subagent called Write on agent-workspace/memory/agent-notes.md instead of
# Edit, destructively overwriting ~470 LOC of accumulated learned rules with
# a ~40 LOC stub. Recovery from cached transcripts left a ~140-line gap
# (lines 315..454) that is permanently lost.
#
# Rule (L-S45-2): For files under agent-workspace/memory/{agent-notes,
# project,mistake-log}.md AND agent-workspace/{constitution,proposals,
# session-plans}/**/*.md, append/insert via Edit ONLY. Write is reserved
# for genuinely new files (existence-check via Glob first).
#
# Conformance: bash + POSIX per L-S11-1. Soft-block via exit 2 (HARD per
# Anthropic PreToolUse semantics; stderr shown to model). Logs decisions to
# .session-hooks.log.

set -u
LOG="${CLAUDE_PROJECT_DIR:-.}/agent-workspace/memory/.session-hooks.log"
TS="$(date -Iseconds 2>/dev/null || date)"

# Read stdin payload
PAYLOAD=$(cat)

# Extract tool_name + file_path via grep+sed (avoid jq dep per L-S11-1)
TOOL_NAME=$(printf '%s' "$PAYLOAD" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Only check Write tool calls
if [ "$TOOL_NAME" != "Write" ]; then
    exit 0
fi

FILE_PATH=$(printf '%s' "$PAYLOAD" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Normalize: convert backslashes to forward slashes; lowercase for matching
NORM=$(printf '%s' "$FILE_PATH" | tr '\\' '/')

# Pattern match: append-only protected paths
PROTECTED=0
case "$NORM" in
    */agent-workspace/memory/agent-notes.md|agent-workspace/memory/agent-notes.md) PROTECTED=1 ;;
    */agent-workspace/memory/project.md|agent-workspace/memory/project.md) PROTECTED=1 ;;
    */agent-workspace/memory/mistake-log.md|agent-workspace/memory/mistake-log.md) PROTECTED=1 ;;
    */agent-workspace/memory/current-execution.md|agent-workspace/memory/current-execution.md) PROTECTED=1 ;;
    */agent-workspace/constitution/*) PROTECTED=1 ;;
    */agent-workspace/proposals/*) PROTECTED=1 ;;
esac

if [ "$PROTECTED" -eq 0 ]; then
    exit 0
fi

# File doesn't exist yet → Write is legitimate (first-creation)
if [ ! -f "$FILE_PATH" ]; then
    printf '[%s] write-vs-edit-guard: ALLOW first-creation file=%s\n' "$TS" "$FILE_PATH" >> "$LOG" 2>/dev/null
    exit 0
fi

# File exists → HARD-BLOCK
printf '[%s] write-vs-edit-guard: BLOCKED Write on existing protected file=%s\n' "$TS" "$FILE_PATH" >> "$LOG" 2>/dev/null

cat >&2 <<EOF
write-vs-edit-guard HARD-BLOCK (L-S45-2):

  tool: Write
  target: $FILE_PATH

This file is on the append-only protected list. Use Edit, not Write.

Rationale: Write semantics overwrite the entire file. The Read-before-Write
safety only blocks first-write of fully-unread files; it does NOT prevent
loss when partial Reads have happened earlier in the session. Origin
incident: 2026-05-05 S45 sandwich-architect destroyed ~140 LOC of
agent-notes.md (irrecoverable from cache). See L-S45-2 in agent-notes.md.

Correct path:
  1. Read the file fully (or Read tail with offset to capture last anchor)
  2. Edit(file_path, old_string=<verbatim trailing anchor>,
                    new_string=<same anchor>+<your new content>)

Override: only if you are doing an authorized full-file rewrite (rare).
Document inline at the call site why Write is appropriate vs Edit.
EOF

exit 2
