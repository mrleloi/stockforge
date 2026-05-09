# Memory Tiers — Working Memory vs Forensic Archive (S99 EXTENSION)

> **Status**: ACCEPTED-PENDING-CODIFICATION (S99 extension; user explicit pick Q-RCA-3 = A + Q-RCA-5 = A + Q-RCA-7 = A on 2026-05-06; D-017 base already ratified at S38). Full S99 extension codification (20 KB working-memory budget + boot-summary + routing-config + Tier 1.5 indexes + Ritual Governance) requires constitution deny-list lift to update `agent-workspace/constitution/memory-tiers.md` from D-017 base (≤8K tokens, 4 Tier-1 files) to S99 extension.
> **Status-field updated**: 2026-05-07 (S124 zombie-cleanup; hook proposal-bundle-advisor was firing false-positive on stale PROPOSAL status; user already approved Q-RCA-3 = A but ADR + constitution lift not yet authored).
> **Promote target**: `agent-workspace/constitution/memory-tiers.md` (requires user explicit approval per `agent-workspace/CLAUDE.md` deny-list — pending separate S99-extension ADR + one-time deny-list lift to apply edit).
> **Predecessor decision**: D-017 (S38 ratification of base memory-tiers; constitution/memory-tiers.md created with ≤8K token Tier-1 ceiling; this S99 extension supplements that base).
> **Q&A bundle**: `human-workspace/q-and-a/answered/2026-05-06-S98-tracking-bloat-rca.md` (status: answered-via-chat-2026-05-06).

---

## Why this artifact exists

S91→S98 cycle exposed a structural failure: tracking files (`current-execution.md` 304 KB, `agent-notes.md` 216 KB, `mistake-log.md` 116 KB, `component-telemetry.jsonl` 2.3 MB) had grown to where:
- `current-execution.md` exceeded the Read tool 256 KB limit ⇒ tooling could not read the very file claiming to be "single source of truth".
- Loading these into LLM context every `continue` consumed 50-100 K tokens for routine bookkeeping with measurable catch-rate ≈ 0% (L-S87-1 audit cycle as Exhibit A).
- 34 hooks read `current-execution.md` per Stop event — most needing only top section but reading full file.

User escalated: tracking cost > tracking benefit; need long-term efficient approach.

This proposal codifies the split: **working memory** (loaded routine, ≤ 20 KB budget) vs **forensic archive** (write-often-read-rare, on-demand grep).

---

## Tier 1 — Working Memory (load every `continue`)

**Budget**: ≤ 20 KB combined for routine load. Each file in this tier MUST stay under its sub-cap.

| File | Sub-cap | Purpose |
|---|---|---|
| `agent-workspace/memory/boot-summary.md` | ≤ 4 KB | auto-rendered compact bootstrap |
| `agent-workspace/memory/checkpoints/latest.md` | ≤ 8 KB | active session handoff state |
| `agent-workspace/memory/routing-config.md` | ≤ 8 KB | model × effort × task-class routing |
| `agent-workspace/memory/project.md` head section | ≤ 6 KB | active phase + last-5-ADR pointers |
| `agent-workspace/memory/current-execution.md` | ≤ 24 KB / 200 LOC / 5 sessions | active routing; older archived |
| `agent-workspace/memory/agent-notes.md` | ≤ 700 LOC | charter rules inline + lesson digest (1-line per L-S<N>-<M>) |
| `agent-workspace/memory/mistake-log.md` | ≤ 200 LOC | header + digest table only |

**Rule**: agents may load these in full when authoring/grilling. Hooks should prefer index-derived projections (Tier 1.5) when only metadata needed.

---

## Tier 1.5 — Index Projections (cheap deterministic views)

**Purpose**: hooks needing only metadata read these instead of full files. Auto-rendered by `index-registry-renderer.sh` Stop hook.

| Index file | Source | Projection |
|---|---|---|
| `agent-workspace/memory/indexes/lesson-registry.tsv` | agent-notes.md digest | lesson_id ∣ status ∣ severity ∣ archive_line |
| `agent-workspace/memory/indexes/mistake-registry.tsv` | mistake-log.md digest | mistake_id ∣ session ∣ severity ∣ archive_line |
| `agent-workspace/memory/indexes/decision-registry.tsv` | decisions/* | decision_id ∣ status ∣ phase ∣ tier |
| `agent-workspace/memory/indexes/hook-registry.tsv` | scripts/hooks/* | hook_name ∣ event ∣ severity ∣ last_modified |

Hooks SHOULD read these (≤ 5 KB each) instead of full files. Q-RCA-4 = A extension: `index-registry-renderer.sh` to cover agent-notes / mistake-log / current-execution.md projections (deferred to S100 backlog; existing index-registry-renderer.sh already covers other registries).

---

## Tier 2 — Forensic Archive (read on-demand only)

**Files**:
- `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md` (104 files at S99)
- `agent-workspace/memory/agent-notes-archive-YYYY-MM-DD.md` (1524 LOC at S99 first archive)
- `agent-workspace/memory/mistake-log-archive-YYYY-MM-DD.md` (1155 LOC at S99 first archive)
- `agent-workspace/memory/current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md` (2603 LOC at S99 first new-pattern archive)
- `agent-workspace/memory/current-execution-archive.md` (legacy 2026-05-05 archive)
- `agent-workspace/memory/dispatch.jsonl` + `component-telemetry.jsonl` (rotated weekly)
- `agent-workspace/memory/handoff-logs/`, `observations/`, `post-mortems/`, `decisions/`, `drift-logs/`

**Rule**: never load these into LLM context routine. Read on-demand via `Grep` / `Read offset+limit` / `Glob`. When agent or hook needs a specific lesson body, mistake body, or session log, read THAT file alone.

---

## Tier 3 — Generated Artifacts (regenerated; never read directly)

- `.drift-signals.log` (raw firing log)
- `.session-hooks.log` (hook output log)
- `drift-logs/YYYY-MM-DD-rollup.md` (auto-rendered daily)
- `sync-tracker/_index.md` (auto-rendered)
- `telemetry-archive/component-telemetry.YYYY-WNN.jsonl.gz` (weekly rotation; retain 4 weeks)

**Rule**: read DERIVED views (rollups, indexes), not raw logs. Raw log access only when debugging the renderer itself.

---

## Retention Policy (cap thresholds; enforced by `tracking-retention.sh`)

| File | Cap | Action on breach |
|---|---|---|
| `current-execution.md` | ≤ 5 sessions inline / ≤ 200 LOC | WARN → manual archive to dated file |
| `agent-notes.md` | digest only / ≤ 700 LOC | WARN → archive any inline lesson body |
| `mistake-log.md` | digest only / ≤ 200 LOC | WARN → archive any inline mistake body |
| `component-telemetry.jsonl` | ≤ 10 MB; weekly rotate | rotate via `telemetry-rotate.sh`; retain 4 weeks gzip |

`tracking-retention.sh` is **WARN-ONLY** first version (per Q-RCA-1 = A acceptance). Auto-archive deferred until pattern proven safe.

---

## Ritual Governance (per Q-RCA-5 = A + Q-RCA-7 = A)

**Problem catalogued at RCA**: per-session rituals accumulate without expiry. Catch-rate drops to 0; ritual continues consuming context.

**Rule**: every ritual running per-`continue` MUST have:
1. **Catch-rate threshold**: define empirically what the ritual catches.
2. **Dormancy clock**: if catch-rate = 0 over **3+ consecutive sessions**, ritual auto-demotes:
   - **Promote to deterministic hook** (~3K main impl) if catch logic is mechanical.
   - **Demote to passive** (digest entry marked `**PASSIVE**`; not applied routine).
   - **Retire** (digest entry deleted; body retained in archive forever via git history).
3. **Refinement-of-rule guard** (AP-23 prevention): if 2nd "lesson about how the 1st lesson behaves" is considered, mandate **promote-to-hook OR retire**. Do NOT codify lesson-of-lesson inline.

**Existing rituals demoted at S99**:
- L-S87-1 audit: catch-rate 0/4 S95-S98 ⇒ **PASSIVE** per Q-RCA-2 = A.
- L-S90-1 application: meta-recursive trap ⇒ **PASSIVE**.
- L-S94-1 candidate: **RETIRED-NEVER-CODIFIED**.

**Eligible for further demotion (S100 review)**:
- Drift-rollup re-scan: catch-rate ≈ 0% over 12 firings; consider weekly aggregator (Q-RCA-5 option C).

**Legitimate rituals (keep active)**:
- Sync-grilling refresh (every 3 sessions): periodic confidence-tracking touch.
- Per-session log: handoff record (no demotion).
- Current-execution prepend: handoff record; constrained by retention cap.

---

## Working-Memory Budget Audit (deferred S100 backlog)

`working-memory-budget-audit.sh` checks combined Tier 1 file sizes at SessionStart. If > 20 KB total, emit notification. First version: WARN-only.

---

## Revision Protocol

Constitution-tier file. Changes require:
- Written rationale linked to session evidence,
- 48-hour cool-down before commit,
- Explicit user version bump.

Minor clarifications: `agent-workspace/memory/agent-notes.md` digest. This file stays stable.

---

**v1.0-PROPOSAL** — drafted 2026-05-06 at S99 per RCA-2026-05-06-S98.

**Promotion checklist** (user action):
1. Review this proposal.
2. If approved: `mv agent-workspace/proposals/memory-tiers.md agent-workspace/constitution/memory-tiers.md` (or via temporary write-allow + Write tool).
3. Update `.claude/settings.json` deny-list if needed (currently denies constitution writes; this is the intended gate).
4. Append entry to `agent-workspace/memory/decisions/NNN-S99-charter-promote-memory-tiers.md` ADR.
