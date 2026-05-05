---
name: hook-diagnostics
description: Inspect hook event lifecycle (state machine + transcript cache + aggregator output) when triaging failed/stuck hooks or auditing self-awareness rollups. Use during sandwich-verifier review, drift investigation, or post-mortem when component-telemetry.jsonl + dispatch.jsonl + sessions-rollup.tsv need cross-checking.
allowed-tools: [Read, Glob, Grep, Bash]
---

# hook-diagnostics

> Phase 0 (D-008) diagnostic skill consuming `packages/observability/state_machine.py` +
> `packages/observability/transcript_cache.py` + Stop hook output `sessions-rollup.tsv`.

## Purpose

When something looks wrong with hook telemetry — a hook is stuck `active`, an aggregator
row is missing, a `failure_mode` count seems off — this skill walks you through the
deterministic check chain. No LLM dispatch; pure inspection of files + Python module imports.

## When to Use

- **Hook event lifecycle introspection**: a Stop or PostToolUse hook is reported failing;
  walk its state-machine transitions to identify where it left `active`.
- **Aggregator output read**: `agent-workspace/memory/self-awareness/sessions-rollup.tsv`
  emitted unexpected values; trace back to source telemetry files.
- **State-machine validation in tests**: writing a new hook that needs lifecycle tracking;
  verify transition table matches D-008 contract before shipping.

## When NOT to Use

- **Production alerting / on-call paging** — Phase 1+ telemetry-analyst subagent + OTEL
  Grafana stack covers that.
- **Cross-session pattern mining** — defer to Phase 1+ telemetry-analyst (LLM, fresh ctx,
  session-end only). This skill is single-session inspection.

## API Quick Reference (from packages/observability)

```python
from packages.observability import (
    HookEvent, HookEventState, transition, is_terminal,
    InvalidTransitionError, VALID_TRANSITIONS, TranscriptCache,
)
```

State machine (D-008):
- 4 states: `active` / `completed` / `error` / `abandoned`
- 5 transitions: 3 forward (`active` → completed/error/abandoned) + 2 reactivation (`error`/`abandoned` → `active`)
- `completed` is terminal; `is_terminal(s)` returns True only for `completed`

## Examples

### 1. Walk a hook's state-machine transitions

```python
from packages.observability import HookEvent, HookEventState, transition

e = HookEvent(hook_name="Stop", started_at="2026-04-29T15:00:00Z")
transition(e, HookEventState.ERROR)        # tool failed
transition(e, HookEventState.ACTIVE)       # caller retries
transition(e, HookEventState.COMPLETED)    # second try succeeds
print(e.transitions_log)
# [(<ts1>, ACTIVE, ERROR), (<ts2>, ERROR, ACTIVE), (<ts3>, ACTIVE, COMPLETED)]
```

### 2. Inspect aggregator output for a session

```bash
# Read the latest aggregator row
tail -1 agent-workspace/memory/self-awareness/sessions-rollup.tsv

# Cross-check session_n against the latest session log file
ls -1 agent-workspace/memory/sessions/2026-*-session-*.md | tail -1
```

If `session_n` in the rollup row doesn't match the latest session log filename, the
aggregator hook ran before the session log was written — re-run after session close.

### 3. Grep dispatch.jsonl for stuck DISPATCHED events without COMPLETED

```bash
# All dispatch IDs that started
grep -oE '"dispatch_id":"[^"]+"' agent-workspace/memory/dispatch.jsonl | sort -u > /tmp/all_ids.txt

# All dispatch IDs that completed
grep -E '"event":"COMPLETED"' agent-workspace/memory/dispatch.jsonl | grep -oE '"dispatch_id":"[^"]+"' | sort -u > /tmp/done_ids.txt

# Diff = stuck (state-machine still ACTIVE)
diff /tmp/all_ids.txt /tmp/done_ids.txt
```

## Inputs

- `agent-workspace/memory/dispatch.jsonl` (subagent dispatches)
- `agent-workspace/memory/component-telemetry.jsonl` (per-tool events)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (aggregator output)
- `packages/observability/state_machine.py` (state-machine module)

## Outputs

- Inline analysis (no files written by this skill).
- Optional: stdout grep / awk results piped to caller.

## Source Schema Pointer

- State machine contract: `agent-workspace/memory/decisions/008-track-9-self-awareness-reduced.md`
- Telemetry schema: `agent-workspace/memory/self-awareness/jsonl-schema.md` (S13 v2)

## Anti-Patterns

- **Don't** infer hook state from file mtimes alone — use the state machine + transitions_log.
  Mtime-only inference misses reactivation cycles (D-008 § state_machine.py contract).
- **Don't** auto-render profile cards from this skill — that's Phase 1+ telemetry-analyst job
  per IMPL-S18-1 caller-fills doctrine.
- **Don't** dispatch LLM for cross-event aggregation in this skill — UP02 §1.4 cost concern;
  defer to session-end aggregator hook (already deterministic) or Phase 1+ telemetry-analyst.
