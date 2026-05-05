---
template_version: 1
created_at: 2026-04-29 (S19 — Track 9 Phase 0 reduced)
purpose: Schema for per-(model × effort) profile cards rendered Phase 1+ by telemetry-analyst.
phase_0_status: TEMPLATE only — no auto-rendering (per D-008 IMPL-S18-1 caller-fills doctrine)
---

# Profile Card Template — `<model>-<effort>.md`

> **Phase 0 ships this template only.** Phase 1+ telemetry-analyst subagent reads
> `sessions-rollup.tsv` + `component-telemetry.jsonl` and fills `profiles/<model>-<effort>.md`
> per (model × effort) pair.

## Schema (Phase 1+ consumer)

```yaml
---
model: claude-opus-4-7              # or claude-sonnet-4-6, claude-haiku-4-5-20251001
effort: medium                      # one of: low / medium / high / xhigh / max
thinking: enabled | disabled        # extended-thinking on/off
task_class:                         # most-frequent task classifications observed
  - planning
  - implementation
  - verification
samples_count: 0                    # number of (model × effort) sessions aggregated
last_updated: <ISO-8601 UTC>
source: agent-workspace/memory/self-awareness/sessions-rollup.tsv
---
```

## Body sections (Phase 1+ filled)

### 1. Capabilities (what model × effort does well)

Bullet list — populated from per-session success metrics where outcome=ok and
correction_rate < threshold. Source: telemetry-analyst LLM at session-end (NOT Phase 0).

### 2. Known limitations (where it struggles)

Bullet list — populated from failure_mode codes in `component-telemetry.jsonl`:
- `A` (assumption-without-verification)
- `B` (boundary-violation)
- `C` (charter-drift)
- `D` (deferral)
- `H` (harness-misuse)
- `P` (premature-termination)
- `T` (token-budget-overrun)

### 3. Recommended task_class allocation

Multi-criteria recommendation — which task classes route to this (model × effort)
pair vs. alternatives. Cross-references `agent-workspace/memory/capability-map.md`
(Track 5.5c shipped).

### 4. Recent corrections + drift events

Pointer to `mistake-log.md` entries tagged with this (model × effort).

### 5. Calibration

Hit rate per task_class (Charter Principle 8: Calibration over confidence).
Empirical only — no LLM-generated confidence numbers (Charter Principle 9).

## Profile card lifecycle

```
Phase 0 (this session): template + README + seeds.
Phase 1+ aggregator:    sessions-rollup.tsv has ≥3 rows per (model × effort) → render.
Phase 1+ telemetry-analyst (LLM, fresh context, session-end only):
                        reads rolled-up data + fills body sections + commits to profile card.
```

## Anti-patterns

- **DON'T** auto-fill in Phase 0 — caller-fills doctrine per D-008 + IMPL-S18-1.
- **DON'T** let LLM generate calibration numbers — Charter Principle 9 (No LLM math).
  Hit rate must come from `calibration/` empirical data.
- **DON'T** ship profile cards before sessions-rollup.tsv has ≥3 (model × effort) samples
  — sample-of-1 profiles are noise, not signal.
