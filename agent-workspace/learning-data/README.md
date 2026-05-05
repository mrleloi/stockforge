# learning-data/ — Boundary Discipline (Track 5.5d.1)

> **Status**: write-heavy data ETL store. **Runtime read path MUST NOT load this tree** (drift signal D9 enforces).
> **Established**: D-005 § 5.5d.1 (UP-08 ratification, 2026-04-29).

## Why this directory exists

Per UP-08 (Vietnamese verbatim): *"self-learning/upgrade lại nặng về bài toán 'write', 'index', 'cache', nơi mà thu thập càng nhiều dữ liệu... với chi phí rẻ nhất mà không làm ảnh hưởng tới runtime"*.

User-provided framing: **harness engineering = backend engineering / data ETL**. Runtime is read-heavy + reasoning + delegating; self-learning is write-heavy + indexing + caching. They are different disciplines. Conflating them in shared storage causes runtime to load write-only data accidentally (size penalty + relevance dilution).

This tree isolates the write-heavy stream from the read-heavy memory layer (`agent-workspace/memory/`) so that:
- Runtime context loads stay small and relevant
- Background analysis can scan a large event corpus without polluting per-session context
- Boundary violations are detectable via deterministic drift signal (D9), not vibes

## Subdirectories

| Path | Purpose | Tracked? | Read by runtime? |
|---|---|---|---|
| `events/` | Append-only NDJSON event stream emitted by hooks (Track 5.5d.1 D-2). One file per UTC date: `YYYY-MM-DD.ndjson`. | **gitignored** (volume + ephemerality) | **NO** — D9 violation if loaded |
| `archive/` | Rotated events older than 7 days (Track 5.5d.2 sweeper, S11). Purged at >30 days. | **gitignored** | **NO** — D9 violation if loaded |
| `index/` | RAG query target (Track 5.5d.2 index rebuild, S11). Phase 0: SQLite FTS5. Phase 1+: pgvector. | tracked (small; useful for diff review) | **YES** — read-allowed (RAG query path) |
| `dogfood/` | Opensource-tool integration insight artifacts (Track 5.5d.3, S12). One file per tool studied. | tracked | **YES** — read-allowed (insight artifacts are reference material) |
| `loop/` | Karpathy outer-loop experiment-framing artifacts (Track 5.5d.3, S12). One file per loop iteration. | tracked | **YES** — read-allowed |

## Boundary contract (BINDING)

1. **Write-only via hooks for `events/` + `archive/`.** Runtime sessions never write to these; only hook scripts (`component-telemetry.sh`, `learning-queue-sweeper.sh`, etc.) emit/rotate.
2. **Runtime read deny for `events/` + `archive/`.** Enforced by `.claude/settings.json` permissions (deny Read) + drift signal D9 (greps runtime code paths for `learning-data/events/` or `learning-data/archive/` references).
3. **`index/` is the runtime query surface.** When sessions need to query learning data, they read pre-built index files, not raw events. Phase 0 = SQLite FTS5; Phase 1+ = pgvector.
4. **`dogfood/` + `loop/` are append-only.** Sessions append; never delete or rewrite. History is the artifact.
5. **Schema**: NDJSON events MUST include `ts` (ISO-8601 UTC), `source` (which hook emitted), `event_type`, `payload`, `as_of` (per I-S2 — provenance). Set at S10 (D-2 deliverable).

## Anti-patterns

- **AP-1**: Loading `learning-data/events/*.ndjson` into a runtime session prompt. Fix: query `index/` instead.
- **AP-2**: Emitting events from non-hook code (e.g., session-end manual write). Fix: route through `component-telemetry.sh` hook to keep emission deterministic.
- **AP-3**: Deleting historical archives "to save space". Fix: sweeper handles rotation deterministically; manual delete = lost calibration data.

## Connection to existing harness

- Extends `scripts/hooks/component-telemetry.sh` (5.5c.5 JSONL telemetry pattern shipped S8) — adds learning-event emission alongside existing component-telemetry stream.
- Extended by `scripts/hooks/drift-signals-D1-D9.sh` (renamed from D1-D8 in S10) — D9 detects boundary violations.
- Read by future `scripts/hooks/learning-queue-sweeper.sh` (5.5d.2 S11) + `scripts/hooks/learning-index-rebuild.sh` (5.5d.2 S11).
- Consumed by `.claude/agents/research-scanner.md` (5.5d.3 S12) for opensource-tool dogfood.

## References

- Decision: `agent-workspace/memory/decisions/005-up08-track-5.5d-self-learning-pipeline.md`
- Decomposition: `agent-workspace/memory/observations/decompose-work-up08-S9.md`
- User prompt: `human-workspace/user_prompt/20260429_08.txt`
- Plan: `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` § 5.5d
