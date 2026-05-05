---
created_at: 2026-04-29 (S19 — Track 9 Phase 0 reduced)
source_decision: agent-workspace/memory/decisions/008-track-9-self-awareness-reduced.md
schema_source: agent-workspace/memory/self-awareness/jsonl-schema.md (S13 — Track 5.5c.5)
otel_source: agent-workspace/memory/self-awareness/otel-design.md (S13 — Track 5.5c.4)
---

# self-awareness/

> **Phase 0 status**: TEMPLATE seeds + design docs only. Auto-rendering profile cards
> + telemetry-analyst LLM aggregation defer to Phase 1+ per D-008 § Open Questions.

## Purpose

Stockforge's self-awareness layer is the **deterministic-hooks Guardian + session-end
LLM aggregator** approach (per D-002 REV-2 § B Track 9 REFINE: NOT continuous LLM
Guardian, NOT auto-fire). Phase 0 lays down:

1. **Schema** — `jsonl-schema.md` documents the telemetry stream this directory consumes.
2. **OTEL design** — `otel-design.md` describes the Phase 1+ Grafana stack.
3. **Templates** — `profile-template.md` + `known-issues.md` + `best-practices.md` are
   seeds that Phase 1+ aggregator + telemetry-analyst subagent fill in.
4. **Rollup** — `sessions-rollup.tsv` is auto-emitted by `scripts/hooks/self-awareness-aggregate.sh`
   (Stop hook) once events flow.

## Phase 0 vs Phase 1+ boundary

| Artifact | Phase 0 | Phase 1+ |
|---|---|---|
| `jsonl-schema.md` | Authored (S13) | Extended with `approach_id` + `metric` |
| `otel-design.md` | Authored (S13) | Docker stack shipped; Grafana boards live |
| `profile-template.md` | Authored (S19) | Auto-rendered to `profiles/<model>-<effort>.md` |
| `known-issues.md` | Seed entries (S19) | Append per session-end |
| `best-practices.md` | Seed entries (S19) | Append per learned-rule promotion |
| `sessions-rollup.tsv` | Emitted by aggregator (S19+) | Consumed by telemetry-analyst |
| `profiles/` directory | Empty | Populated post Phase 1+ aggregator |

## Aggregator contract (Phase 0)

`scripts/hooks/self-awareness-aggregate.sh` runs as Stop hook:

- Reads: `dispatch.jsonl` + `.transcript-tokens` + `.session-hooks.log` + `component-telemetry.jsonl`.
- Writes: `sessions-rollup.tsv` (append-mostly; header on first run).
- Failure mode: best-effort `|| true` (never blocks Stop pipeline).
- LLM dispatch: NONE in Phase 0 (deterministic-hooks Guardian doctrine).

## Anti-patterns (don't)

- **Continuous LLM Guardian** — UP02 §1.4 cost concern. Aggregator is bash + awk only.
- **Auto-render profile cards Phase 0** — defer per IMPL-S18-1 caller-fills doctrine.
- **Mutate raw telemetry** — `dispatch.jsonl` + `component-telemetry.jsonl` are source-of-truth
  read-only; rollup writes a separate file.
- **Mix thesis-side anomaly skills** with self-awareness — those land Phase 1+ when thesis
  data exists. Phase 0 has zero thesis events.

## References

- D-008 § Decision (REDUCED scope)
- D-002 REV-2 § B Track 9 + REV-3 § C reduction
- packages/observability/state_machine.py (consumed by hook-diagnostics skill)
- .claude/skills/hook-diagnostics/SKILL.md
