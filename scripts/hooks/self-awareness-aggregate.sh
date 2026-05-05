#!/usr/bin/env bash
# self-awareness-aggregate.sh — Track 9 (D-008) Stop hook aggregator.
#
# Reads telemetry sources + emits aggregated session row to sessions-rollup.tsv.
# Bash + awk ONLY (no python/jq/yq/sqlite3) per L-S11-1 portability discipline.
# Best-effort: errors suppressed via `|| true` — never blocks Stop pipeline.
#
# Sources:
#   agent-workspace/memory/dispatch.jsonl              (subagent dispatches)
#   agent-workspace/memory/component-telemetry.jsonl   (per-tool events; failure_mode codes)
#   agent-workspace/memory/.transcript-tokens          (real-transcript token count)
#   agent-workspace/memory/.session-hooks.log          (session_id source)
#   agent-workspace/memory/sessions/2026-*-N.md        (session_n parser)
#
# Output: agent-workspace/memory/self-awareness/sessions-rollup.tsv (append; header on first run)
# Schema: session_n  session_id  ts_utc  tokens_real  tools_used  subagents  failure_codes  wall_min
#
# Trigger: Stop hook (Claude Code session end).

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
MEM_DIR="$ROOT_DIR/agent-workspace/memory"
SA_DIR="$MEM_DIR/self-awareness"
ROLLUP="$SA_DIR/sessions-rollup.tsv"
LOG="$ROOT_DIR/.session-hooks.log"

DISPATCH="$MEM_DIR/dispatch.jsonl"
COMP_TEL="$MEM_DIR/component-telemetry.jsonl"
TRANS_TOK="$MEM_DIR/.transcript-tokens"
HOOKS_LOG="$MEM_DIR/.session-hooks.log"
SESSIONS_DIR="$MEM_DIR/sessions"

mkdir -p "$SA_DIR"

ts_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# session_n — latest sessions/YYYY-MM-DD-session-N.md filename → N (or 0 if none)
session_n=0
if [[ -d "$SESSIONS_DIR" ]]; then
    latest_session=$(ls -1 "$SESSIONS_DIR" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}-session-[0-9]+\.md$' | sed -E 's/.*session-([0-9]+)\.md$/\1/' | sort -n | tail -1)
    if [[ -n "$latest_session" ]]; then
        session_n="$latest_session"
    fi
fi

# session_id — last UUID-shaped token in .session-hooks.log (or "unknown")
session_id="unknown"
if [[ -r "$HOOKS_LOG" ]]; then
    sid=$(grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' "$HOOKS_LOG" 2>/dev/null | tail -1)
    if [[ -n "$sid" ]]; then
        session_id="$sid"
    fi
fi

# tokens_real — last line of .transcript-tokens (numeric; default 0)
tokens_real=0
if [[ -r "$TRANS_TOK" ]]; then
    last=$(tail -1 "$TRANS_TOK" 2>/dev/null | tr -d '[:space:]')
    if [[ "$last" =~ ^[0-9]+$ ]]; then
        tokens_real="$last"
    fi
fi

# tools_used — count lines in component-telemetry.jsonl (proxy for tool-call count)
tools_used=0
if [[ -r "$COMP_TEL" ]]; then
    tools_used=$(wc -l < "$COMP_TEL" 2>/dev/null | tr -d '[:space:]')
    [[ "$tools_used" =~ ^[0-9]+$ ]] || tools_used=0
fi

# subagents — DISPATCHED events in dispatch.jsonl
subagents=0
if [[ -r "$DISPATCH" ]]; then
    subagents=$(grep -c '"event":"DISPATCHED"' "$DISPATCH" 2>/dev/null || echo 0)
fi

# failure_codes — comma-separated A:N,B:M,C:N,... from non-null failure_mode in component-telemetry.jsonl
failure_codes="-"
if [[ -r "$COMP_TEL" ]]; then
    failure_codes=$(awk '
        match($0, /"failure_mode":"[^"]+"/) {
            f = substr($0, RSTART+16, RLENGTH-17)
            counts[f]++
        }
        END {
            n = 0
            out = ""
            for (k in counts) {
                if (n > 0) out = out ","
                out = out k ":" counts[k]
                n++
            }
            print (n == 0 ? "-" : out)
        }
    ' "$COMP_TEL" 2>/dev/null)
    [[ -z "$failure_codes" ]] && failure_codes="-"
fi

# wall_min — minutes elapsed since dispatch.jsonl earliest entry (best-effort; 0 if N/A)
wall_min=0
if [[ -r "$DISPATCH" && -s "$DISPATCH" ]]; then
    first_ts=$(head -1 "$DISPATCH" 2>/dev/null | grep -oE '"ts_ms":[0-9]+' | head -1 | cut -d':' -f2)
    last_ts=$(tail -1 "$DISPATCH" 2>/dev/null | grep -oE '"ts_ms":[0-9]+' | head -1 | cut -d':' -f2)
    if [[ "$first_ts" =~ ^[0-9]+$ && "$last_ts" =~ ^[0-9]+$ ]]; then
        delta_ms=$((last_ts - first_ts))
        wall_min=$((delta_ms / 60000))
        [[ $wall_min -lt 0 ]] && wall_min=0
    fi
fi

# Header on first run.
if [[ ! -f "$ROLLUP" ]]; then
    printf 'session_n\tsession_id\tts_utc\ttokens_real\ttools_used\tsubagents\tfailure_codes\twall_min\n' > "$ROLLUP"
fi

# Append row.
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$session_n" "$session_id" "$ts_utc" "$tokens_real" "$tools_used" "$subagents" "$failure_codes" "$wall_min" \
    >> "$ROLLUP"

echo "[$(date -u +%FT%TZ)] self-awareness-aggregate session_n=$session_n tokens_real=$tokens_real tools_used=$tools_used subagents=$subagents failure_codes=$failure_codes wall_min=$wall_min" >> "$LOG"

exit 0
