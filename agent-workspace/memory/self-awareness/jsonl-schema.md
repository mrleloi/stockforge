---
schema_version: 2
created_at: 2026-04-29 (S13 — Track 5.5c.5)
updated_at: 2026-04-29
description: |
  JSONL telemetry schema for stockforge harness self-awareness loop. Two streams:
  (1) component-telemetry.jsonl — flat per-tool event log, rotated at 10 MB.
  (2) learning-data/events/<UTC-date>.ndjson — write-heavy ETL stream for L-1 classifier.
  This document is the source-of-truth for both. Schema extension drives loop closure
  (task_id + approach_id + metric let outcomes attribute back to the framing artifact).
source_decision: agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md § 5.5c.5
related_artifacts:
  - scripts/hooks/component-telemetry.sh    # producer
  - scripts/hooks/learning-index-rebuild.sh # consumer (RAG index path)
  - scripts/hooks/metric-failure-mode-rate.sh # consumer (metric path)
  - .claude/skills/try-n-approaches/SKILL.md  # producer of task_id/approach_id (Phase 1+)
  - agent-workspace/learning-data/loop/      # outcome attribution target
---

# JSONL Telemetry Schema

> Schema for both stockforge telemetry streams. Versioned. Backward-compatible by default
> (new fields are optional + default null); breaking changes bump `schema_version`.

## Stream A: component-telemetry.jsonl (flat event log)

Path: `agent-workspace/memory/component-telemetry.jsonl` (rotated to `.1`..`.5` at 10 MB).
Producer: `scripts/hooks/component-telemetry.sh` (PostToolUse / SubagentStop / SessionStart hook).
Consumer: drift signals + ad-hoc grep.

### Fields (S13 close)

| Field | Type | Status | Source | Notes |
|---|---|---|---|---|
| `ts` | string (ISO-8601 UTC, ms) | shipped S8 | `date -u +%FT%T.%3NZ` | event timestamp |
| `component_type` | string | shipped S8 | classify_component() | one of: hook / agent / skill / command |
| `component_name` | string | shipped S8 | classify_component() | tool name, agent type, or skill name |
| `trigger` | string | shipped S8 | classify_component() | hook_event / agent_dispatch / keyword_match / explicit_invoke |
| `outcome` | string | shipped S8 | OUTCOME var | ok / error / timeout / reject / no_op |
| `tokens_real` | int | shipped S8 | compute_tokens_real() | delta from `.transcript-tokens` |
| `duration_ms` | int | shipped S8 | compute_duration_ms() | wall-clock from prior event |
| `session_id` | string \| null | shipped S8 | payload.session_id | Claude Code session UUID |
| `task_id` | string \| null | **always null today (S13)** | reserved | wires from try-n-approaches frame at Phase 1+ |
| `failure_mode` | string \| null | **shipped S13** | correlate_failure_mode() + outcome fallback | A/B/C/D/H/P/T (see § Failure mode codes) |

### Phase 1+ extensions (S14+)

| Field | Type | Status | Notes |
|---|---|---|---|
| `approach_id` | string \| null | designed (5.5c.5) | links event to N-approach branch from try-n-approaches frame |
| `metric` | string \| null | designed (5.5c.5) | name of deterministic metric function evaluating this event (per L-S12-1) |

## Stream B: learning-data/events/<UTC-date>.ndjson (ETL store)

Path: `agent-workspace/learning-data/events/YYYY-MM-DD.ndjson` (boundary: gitignored + runtime read-deny per D9).
Producer: `scripts/hooks/component-telemetry.sh` (same hook; emit_learning_event() wraps the payload).
Consumer: L-1 classifier dispatch (background sonnet); metric scripts; `learning-index-rebuild.sh`.

### Wrapper schema (S13 close)

```json
{
  "ts": "<ISO-8601 UTC ms>",
  "source": "component-telemetry.sh",
  "event_type": "harness-component-event",
  "payload": { /* same fields as Stream A, minus the wrapper */ },
  "as_of": "<YYYY-MM-DD>"
}
```

`as_of` is per I-S2 (point-in-time integrity) — bucket date for which the event was emitted (UTC).

### Phase 1+ extensions for Stream B

Same as Stream A: `approach_id`, `metric` populate inside `payload`.

## Failure mode codes (S13 wire-in)

| Code | Meaning | Source | S13 status |
|---|---|---|---|
| `A` | agent narration drift (LLM ended turn without producing artifact) | reserved (LLM-side detector) | NOT WIRED |
| `B` | api / tool error | outcome=error fallback | wired |
| `C` | premature wind-down (mode-C guard fired) | `.autonomous-premature-windown-alert.log` correlate | wired |
| `D` | drift signal threshold exceeded | reserved (constant-fire today; gated until D-thresholds tuned) | NOT WIRED |
| `H` | permission deny (PAYLOAD_DECISION="deny") | dispatch-site override | wired |
| `P` | cliff auto-reboot fire | `.session-hooks.log` correlate within current minute | wired |
| `T` | tool timeout | outcome=timeout fallback | wired |
| `null` | no failure detected | default | wired |

Ordering in dispatch: correlate first (A/C/D/P) → outcome fallback (B/T) → deny override (H).
H takes precedence because the deny information is authoritative (came directly from the harness).

## Consumer contract

- Stream A (component-telemetry.jsonl): drift signal scripts + ad-hoc grep. NEVER loaded into LLM context.
- Stream B (learning-data/events/): write-only-during-runtime; read by RAG path (`index/`) + classifier dispatch + metric scripts. NEVER loaded into LLM context directly (D9 enforces).
- Schema changes: any new field is OPTIONAL + defaults `null`. Breaking changes bump `schema_version`. Never silent-rename a field — append + deprecate.

## Anti-patterns

- Loading raw `events/*.ndjson` into runtime context. Always go via `index/` (D9 violation).
- Renaming a field without bump. Loops break silently because consumers grep field names.
- Synthesizing metrics inside the LLM. Per I-S1: metric values come from code; LLM only interprets.
- Adding a Phase 1+ field (e.g., `approach_id`) and treating its null today as bug. It's by design until try-n-approaches wires the producer side.

## Version history

- `v1` (S8): shipped flat 9-field schema (no failure_mode, no learning-data wrapper)
- `v2` (S13): added `failure_mode` (wired); designed `approach_id` + `metric` (Phase 1+); learning-data wrapper formalized

## See also

- D-003 § 5.5c.5 — strategic rationale (UP-06 §3)
- agent-workspace/memory/agent-notes.md § L-S12-1 — metric_function-required rule
- agent-workspace/learning-data/README.md — boundary contract
- scripts/hooks/component-telemetry.sh — producer (canonical implementation)
