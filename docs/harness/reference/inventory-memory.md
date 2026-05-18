# Reference — Memory Inventory

> **Audited**: 2026-05-19
> **Source**: `agent-workspace/memory/` (20 top-level files + 14 subdirs)
> **Maintainer**: Run `/harness-docs sync memory` to regenerate

See [Chapter 7 — Memory System](../en/07-memory-system.md) for full reference.

---

## Top-Level Files

| File | Purpose | Mutability | Retention |
|---|---|---|---|
| `MEMORY.md` | User auto-memory index | Editable | Lines >200 truncated |
| `project.md` | High-level state + Phase Goals Tracker + last 5 ADRs | Editable | Trim to most recent |
| `current-execution.md` | THE routing source-of-truth | Editable | ≤5 sessions inline / ≤200 LOC |
| `agent-notes.md` | Learned rules | Append-mostly | Digest only / ≤700 LOC |
| `mistake-log.md` | Failure catalog | Append-mostly | Digest only / ≤200 LOC |
| `capability-map.md` | Per-task_class agent capability profile | Editable | Updated per profile-template-auto-populate.sh |
| `personal-risk-profile.md` | User's risk tolerance + bias profile | Editable | Human-curated |
| `sync-state.md` | Sync-tracker narrative state | Editable | Updated per sync-grilling fire |
| `boot-summary.md` | Auto-rendered cheap-load summary | Auto-render | Recomputed every Stop |
| `routing-config.md` | Memory routing config | Editable | Stable |
| `up-intake-log.md` | User prompt intake events | Append-only | Long-lived |
| `component-telemetry.jsonl` | Per-tool JSONL | Append-only | ≤10 MB (weekly rotate) |
| `cost-ledger.tsv` | USD cost ledger | Append-only | Long-lived |
| `dispatch.jsonl` | Per-Agent-call telemetry | Append-only | Long-lived |
| `attestation-log.tsv` | Verifier verdicts | Append-only | Long-lived |
| `.session-hooks.log` | Hook firing log | Append-only | Weekly rotate |
| `.severity-state.tsv` | Severity classifier output | Atomic-rewrite | Replaced every Stop |
| `.harness-health.log` | Harness-health detection log | Append-only | Long-lived |
| `.drift-signals.log` | Drift raw output | Append-only | Weekly rotate |
| `.harness-health-cache-<sid>` | Same-session HH cache | Auto | 5-min TTL |
| `.claude-instance.lock` | Single-instance lock | Auto | Cleared at SessionEnd |
| `.cliff-fired`, `.wind-down` | Budget threshold markers (noclobber) | Auto | Per-session |

---

## Subdirectories

| Directory | Purpose | Naming | File count |
|---|---|---|---|
| `sessions/` | One file per session | `YYYY-MM-DD-session-N.md` | 257+ |
| `decisions/` | Sequential ADRs | `NNN-<slug>.md` + `_template.md` + `README.md` | 90+ |
| `observations/` | Subagent return artifacts | `<subagent>-S<sid>-<TS>.md` | varies |
| `checkpoints/` | Session handoff state | `latest.md` + `YYYY-MM-DD-S<sid>-close.md` | varies |
| `patterns-discovered/` | Pattern mining outputs | `<pattern-name>.md` + `SYNTHESIS.md` | varies |
| `drift-logs/` | Drift-check results | `YYYY-MM-DD-rollup.md` | time-series |
| `post-mortems/` | Significant failure post-mortems | `YYYY-MM-DD-<incident>.md` | varies |
| `thesis-log/` | Stock-domain thesis entries | `<TS>-<ticker>.md` | varies |
| `sync-tracker/` | Confidence Score store | `state.tsv`, `events.tsv`, `weights.yaml`, `_index.md` | 5 |
| `self-awareness/` | Profile cards + rollup | `profiles/<model>-<effort>-<task_class>.md` + `sessions-rollup.tsv` | varies |
| `indexes/` | Rendered manifest TSVs | `<type>.tsv` | varies |
| `etl-queue/` | Pending memory ETL | `<TS>-<op>.yaml` + `processed/` | varies |
| `handoff-logs/` | Handoff history | `YYYY-MM-DD-S<sid>-handoff.md` | varies |
| `telemetry-archive/` | Rotated telemetry | `<TS>.gz` | varies |
| `session-hooks-archive/` | Rotated session-hooks.log | `<week>.log` | varies |
| `drift-signals-archive/` | Rotated drift-signals.log | `<week>.log` | varies |
| `.precompact-snapshots/` | PreCompact state dumps | `YYYYMMDDTHHMMSSZ/` | varies |
| `.dispatch-pending-archive/` | Archived dispatch pending rows | `<TS>.jsonl` | varies |

---

## Reading Priority (per agent-workspace/CLAUDE.md)

1. `memory/current-execution.md` — first; resolve active track
2. `memory/project.md` — project state
3. `memory/checkpoints/latest.md` if recent (within 24h)
4. `memory/agent-notes.md` — learned rules
5. `memory/mistake-log.md` — pre-flight failure catalog
6. Last 3 files in `memory/sessions/`
7. `session-plans/pending/<active-plan>.md` — current plan
8. Relevant constitution files as task demands
9. Relevant skills + agents + commands as task demands

---

## Tier 1 (Always-Loaded ≤ 8K)

- `CLAUDE.md` (project root, ~2500 tokens)
- `agent-workspace/CLAUDE.md` (~1500 tokens)
- `human-workspace/CLAUDE.md` (~500 tokens)
- `memory/MEMORY.md` (~500 tokens)
- `memory/project.md` (~1500 tokens)
- `memory/current-execution.md` (≤200 LOC inline, ~1000 tokens)

Target: ~7500 tokens. Hard ceiling enforced by `tier1-bloat-check.sh` (Stop chain).

---

## Retention Caps (per CLAUDE.md / tracking-retention.sh)

| File | Cap | Action when over |
|---|---|---|
| `current-execution.md` | ≤5 sessions / ≤200 LOC | Auto-migrate oldest session row to archive |
| `agent-notes.md` | digest only / ≤700 LOC | WARN |
| `mistake-log.md` | digest only / ≤200 LOC | WARN |
| `component-telemetry.jsonl` | ≤10 MB | Weekly rotate |
| `.session-hooks.log` | varies | Weekly rotate |
| `.drift-signals.log` | varies | Weekly rotate |
| `urgent.md` | 4KB | Size-triggered rotate |

---

## See Also

- [Chapter 7 — Memory System](../en/07-memory-system.md) (full reference)
- [Chapter 8 — Lifecycle](../en/08-lifecycle.md) (how memory flows)
