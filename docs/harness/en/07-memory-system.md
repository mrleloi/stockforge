# Chapter 7 — The Memory System

> **Diataxis quadrant**: Reference + Explanation
> **Reading time**: ~40 minutes
> **Prerequisites**: Chapter 3 (Architecture), Chapter 4 (Constitution § memory-tiers)

The memory system is the harness's persistent state — the *filesystem brain* the agent reads at SessionStart and updates at SessionEnd. This chapter is the canonical reference: what every file is, what every directory is, who writes to it, who reads it, and what retention applies.

If Chapter 6 was the *moving parts*, this chapter is the *state they operate on*.

---

## 7.1 — The Three-Tier Memory Model

Per [`memory-tiers.md`](../../../agent-workspace/constitution/memory-tiers.md):

| Tier | What loads | Hard cap | Loaded when |
|---|---|---|---|
| **Tier 1** | Always-loaded identity + routing | ≤8K tokens combined | Every SessionStart, every session |
| **Tier 2** | Just-in-time (read when relevant signal fires) | None — per artifact | When skill / hook / task references it |
| **Tier 3** | Explicit-pull (read only when explicitly requested) | None | Manual user request, audit, post-mortem |

**Tier 1 contents** (≤8K combined):
- `CLAUDE.md` (project root, ~2500 tokens)
- `agent-workspace/CLAUDE.md` (~1500 tokens)
- `human-workspace/CLAUDE.md` (~500 tokens)
- `agent-workspace/memory/MEMORY.md` (user auto-memory index, ~500 tokens)
- `agent-workspace/memory/project.md` (~1500 tokens)
- `agent-workspace/memory/current-execution.md` (≤200 LOC inline, ~1000 tokens)

Total target: ~7500 tokens. Hard ceiling enforced by `tier1-bloat-check.sh` (Stop chain).

**Why this matters**: Tier 1 is the cost of *every* session, paid before any work. Bloat here compounds across every session for the project's lifetime.

---

## 7.2 — Memory Routing Tree

Per [`memory-routing-tree.md`](../../../agent-workspace/constitution/memory-routing-tree.md), the agent uses a decision tree to route new state to the right artifact:

```
What kind of state am I writing?
│
├── A rule earned through experience? 
│   → agent-workspace/memory/agent-notes.md (digest entry, ≤700 LOC)
│
├── A failure I observed?
│   → agent-workspace/memory/mistake-log.md (digest entry, ≤200 LOC)
│   → For root-cause analysis: agent-workspace/memory/post-mortems/<date>-<slug>.md
│
├── A decision I just made?
│   → agent-workspace/memory/decisions/NNN-<slug>.md (ADR, 12-field schema)
│
├── A subagent's return artifact?
│   → agent-workspace/memory/observations/<subagent>-<sid>-<TS>.md
│
├── Session log?
│   → agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md
│
├── Checkpoint state for next session?
│   → agent-workspace/memory/checkpoints/latest.md (canonical)
│   → agent-workspace/memory/checkpoints/<sid>-close.md (timestamped historical)
│
├── A drift detection result?
│   → agent-workspace/memory/drift-logs/YYYY-MM-DD-rollup.md
│
├── Telemetry row (deterministic, append-only)?
│   → agent-workspace/memory/dispatch.jsonl (per-Agent-call)
│   → agent-workspace/memory/cost-ledger.tsv (per-session USD)
│   → agent-workspace/memory/attestation-log.tsv (verifier verdicts)
│   → agent-workspace/memory/component-telemetry.jsonl (per-tool)
│
├── Self-awareness profile data?
│   → agent-workspace/memory/self-awareness/profiles/<model>-<effort>-<task_class>.md
│   → agent-workspace/memory/self-awareness/sessions-rollup.tsv
│
├── Confidence Score event?
│   → agent-workspace/memory/sync-tracker/events.tsv
│   → agent-workspace/memory/sync-tracker/state.tsv (derived)
│
├── A pattern that worked well?
│   → agent-workspace/memory/patterns-discovered/<pattern-name>.md
│
└── A thesis entry (stock domain)?
    → agent-workspace/memory/thesis-log/<TS>-<ticker>.md
```

The routing tree is canonical. If you cannot find a route, you have either discovered a missing route (propose an addition) or you are trying to store something that does not belong in memory.

---

## 7.3 — Memory Subdirectory Reference

All paths are relative to `agent-workspace/memory/`.

### Top-Level Files

| File | Purpose | Mutability | Retention |
|---|---|---|---|
| `MEMORY.md` | User auto-memory index (one-line per memory file) | Editable | Lines after 200 truncated |
| `project.md` | High-level project state; phase tracker; last 5 ADRs | Editable | Trim to most recent decisions |
| `current-execution.md` | **THE routing source-of-truth**. Active phase + active session + autonomous_mode flag + routing table | Editable | ≤5 sessions inline; older to archive (auto-archive via `tracking-retention.sh`) |
| `agent-notes.md` | Learned rules earned through real experience | Append-mostly | Digest only / ≤700 LOC |
| `mistake-log.md` | Failure catalog: what went wrong / root cause / prevention | Append-mostly | Digest only / ≤200 LOC |
| `capability-map.md` | Per-task_class agent capability profile | Editable | Updated per profile-template-auto-populate.sh |
| `personal-risk-profile.md` | User's risk tolerance + bias profile | Editable | Human-curated |
| `sync-state.md` | Sync-tracker narrative state | Editable | Updated per sync-grilling fire |
| `boot-summary.md` | Auto-rendered cheap-load summary for next-session reboot | Auto-render | Recomputed every Stop |
| `routing-config.md` | Memory routing config (per memory-routing-tree.md) | Editable | Stable |
| `up-intake-log.md` | User prompt intake events (intent classification log) | Append-only | Long-lived |
| `component-telemetry.jsonl` | Per-tool JSONL telemetry | Append-only | ≤10 MB (weekly rotate) |
| `cost-ledger.tsv` | Per-session + per-dispatch USD cost ledger | Append-only | Long-lived |
| `dispatch.jsonl` | Per-Agent-call telemetry (DISPATCHED + COMPLETED) | Append-only | Long-lived |
| `attestation-log.tsv` | Sandwich-verifier verdicts (PASS / PASS-WITH-CONCERNS / FAIL) | Append-only | Long-lived |
| `.session-hooks.log` | Hook firing log (every hook event) | Append-only | Weekly rotate via session-hooks-log-rotate.sh |
| `.severity-state.tsv` | Severity classifier output (rebuilt every Stop) | Atomic-rewrite | Replaced every Stop |
| `.harness-health.log` | Harness-health detection log | Append-only | Long-lived |
| `.drift-signals.log` | Drift detection raw output | Append-only | Weekly rotate via drift-signals-log-rotate.sh |
| `.harness-health-cache-<sid>` | Same-session HH cache (5-min TTL) | Auto | Cleared between sessions |
| `.claude-instance.lock` | Single-instance lock file | Auto | Cleared at SessionEnd |
| `.cliff-fired`, `.wind-down` | Budget threshold markers (noclobber) | Auto | Per-session |

### Subdirectories

| Directory | Purpose | Naming convention | Lifecycle |
|---|---|---|---|
| `sessions/` | One file per session | `YYYY-MM-DD-session-N.md` | Append-only; ~257+ files |
| `decisions/` | Sequential ADRs | `NNN-<slug>.md` + `_template.md` + `README.md` | Append-only; supersession via status field; 90+ files |
| `observations/` | Subagent return artifacts | `<subagent-type>-S<sid>-<TS>.md` | Append; cleaned periodically by aggregator |
| `checkpoints/` | Session handoff state | `latest.md` (canonical) + `YYYY-MM-DD-S<sid>-close.md` (historical) | Append + latest.md updated each checkpoint |
| `patterns-discovered/` | Pattern mining outputs (Track 0) | `<pattern-name>.md` + `SYNTHESIS.md` | Append; significant patterns promoted to constitution |
| `drift-logs/` | Drift-check results | `YYYY-MM-DD-rollup.md` | Time-series append |
| `post-mortems/` | Significant failure post-mortems | `YYYY-MM-DD-<incident-name>.md` | Append |
| `thesis-log/` | Stock-domain thesis entries | `<TS>-<ticker>.md` | Append; revisited per calibration |
| `sync-tracker/` | Confidence Score store | `state.tsv`, `events.tsv`, `weights.yaml`, `_index.md` | Live-updated by hooks |
| `self-awareness/` | Model x effort x task_class profile cards | `profiles/<model>-<effort>-<task_class>.md` + `sessions-rollup.tsv` | Live-updated by Stop-hook aggregator |
| `indexes/` | Rendered manifest TSVs | `<type>.tsv` | Recomputed by index-registry-renderer.sh |
| `etl-queue/` | Pending memory ETL operations | `<TS>-<op>.yaml` + `processed/` subdir | Drained by memory-etl-processor.sh |
| `handoff-logs/` | Handoff history | `YYYY-MM-DD-S<sid>-handoff.md` | Append |
| `telemetry-archive/` | Rotated telemetry files | `<TS>.gz` | Append; periodic prune |
| `session-hooks-archive/` | Rotated `.session-hooks.log` files | `<week>.log` | Append; periodic prune |
| `drift-signals-archive/` | Rotated `.drift-signals.log` files | `<week>.log` | Append; periodic prune |
| `.precompact-snapshots/` | PreCompact state dumps | `YYYYMMDDTHHMMSSZ/` | Auto; periodic prune |
| `.dispatch-pending-archive/` | Archived dispatch.jsonl pending rows | `<TS>.jsonl` | Periodic rotation (12h) |

---

## 7.4 — The Routing Source-of-Truth (`current-execution.md`)

This file is THE single routing source-of-truth. Every session begins by reading it. Every session ends by updating it.

### Structure

```markdown
# Current Execution — Routing Source of Truth

> **autonomous_mode**: true | false
> **Retention**: last 5 sessions inline; older sessions archived to
> `current-execution-archive-YYYY-MM-DD-S<from>-to-S<to>.md`

## Active Focus

[narrative paragraph: current phase, current track, what's next]

## Active Sub-Track

[detailed table: sub-track / status / next session]

## Session Log (most recent first)

### S<N> — <DATE> — <TYPE> — <STATUS>
**Goal**: ...
**Dispatched**: <agent>
**Result**: ...
**Carry-forward**: ...

### S<N-1> — ...
[similar]

## Routing Table

| Symbol | Resolves to |
|---|---|
| `session N` | active session per Active Focus |
| `phase X` | active phase per Phase Goals Tracker |
| `wave 1` | per master plan §6 |

## Coordination Rules (active)

[file/dir avoidance lists when subagents are working in parallel]
```

### Hard Rules

- **No skill, agent, or command may hardcode phase paths from memory.** Resolve via this file.
- **Auto-archive** at >200 LOC OR >5 sessions inline (via `tracking-retention.sh`).
- **Update immediately on task complete**, not session-end (AP-8 prevention).
- **`autonomous_mode` flag**: parsed by `session-start-bootstrap.sh` to gate `continue-injector` spawn. The exact awk parse on this field controls the autonomous loop.

---

## 7.5 — Learned Rules (`agent-notes.md`)

`agent-notes.md` is the harness's institutional memory of rules learned through experience.

### Format

```markdown
### YYYY-MM-DD: [Short rule name]
**Context**: What situation triggered learning this
**Rule**: The actionable rule
**Anti-example**: What was done wrong
**Correct example**: What should be done instead
**Severity**: critical | high | medium | low
**Auto-detect**: yes/no — can a drift signal catch this?
```

### Retention

**Cap**: 700 LOC (digest only). `tracking-retention.sh` warns when exceeded.

Older rules archive to `agent-notes-archive-YYYY-MM-DD.md`.

### Lifecycle

1. **Capture**: rule earned during a session → written as digest entry at session-end (per `session-end-checklist-linter.sh`).
2. **Cluster**: every 5+ sessions, `promote-rule` subagent dispatched. Clusters rules by Jaccard similarity. Identifies promotion candidates.
3. **Promote** (3 tiers):
   - **HOOK promotion**: rule is statically detectable → ship as `scripts/hooks/<name>.sh` + companion firing-test.
   - **SKILL promotion**: rule is a recurring procedure → ship as `.claude/skills/<name>/SKILL.md`.
   - **CHARTER promotion**: rule rises to invariant → propose for constitution amendment.
4. **Retire**: rule retired when 3+ consecutive sessions show catch-rate 0 OR when superseded.

### Auto-Detect Tag

The `Auto-detect: yes` field is a **promise**: it says "this rule should ship as a deterministic hook". If 20+ rules tag `Auto-detect: yes` without matching hook scripts, **HH-4** fires MEDIUM severity. This was a Phase 2.5 surface that caught ~20 such orphans.

---

## 7.6 — Failure Catalog (`mistake-log.md`)

`mistake-log.md` is the structured failure catalog. Format:

```markdown
### M-S<N>-<M>: Short mistake name
**Date**: YYYY-MM-DD
**Severity**: critical | high | medium | low
**What went wrong**: ...
**Root cause**: ...
**Prevention rule**: ...
**Status**: open | closed | superseded-by-L-<NN>-N
```

### Naming

- `M-S<N>-<M>` where:
  - `S<N>` = session ID where mistake occurred (e.g., `S360`)
  - `<M>` = sequential within that session (1, 2, 3...)

- `M-S<N>-NONE`: explicit "no mistakes this session" attestation

### Retention

**Cap**: 200 LOC (digest only). `tracking-retention.sh` enforces.

Older entries archive to `mistake-log-archive-YYYY-MM-DD.md`.

### Discipline

`session-end-checklist-linter.sh` (Stop hook) enforces: every session MUST either record at least one `M-S<N>-<M>` entry OR explicitly state `M-S<N>-NONE` in the session log. Silent omission is treated as drift.

---

## 7.7 — Architecture Decision Records (`decisions/`)

ADRs are the canonical record of every decision made. Sequential numbering, never reused. The 12+ field YAML frontmatter schema is detailed in [§ Chapter 4 — Decision Discipline](04-constitution.md#44--decision-discipline-adrs).

### Subdirectory Structure

```
decisions/
├── _template.md           ← canonical schema
├── README.md              ← index + conventions
├── 001-<slug>.md
├── 002-<slug>.md
├── ...
└── NNN-<slug>.md          ← 90+ files
```

### Sequential Numbering Rule

Numbers are never reused. If you author an ADR and discover it should be merged into an earlier one, mark the new ADR `status: SUPERSEDED-BY-D-NNN` and link.

### Pre-Dispatch Number Check

`pre-dispatch-adr-number-check.sh` (PreToolUse) reads the next-expected ADR number from `decisions/` directory listing. If the dispatched architect cites an ADR number that already exists, the hook flags it. Prevents collision drift.

### Defer-Cycle Tracking

`defer_cycles` field in frontmatter tracks how many times this ADR was deferred. If `defer_cycles > 3`, R7 mitigation triggers: surfaces as MEDIUM severity in escalation pipeline.

### Confidence Thresholds

Per `decision-discipline.md`:

| Level | Threshold | Path |
|---|---|---|
| CHARTER | 0.99 | Always Q&A bundle + human ratify |
| SCOPE | 0.90 | Q&A bundle if <0.90 |
| ARCH | 0.80 | Self-decide if ≥0.80 |
| IMPL | 0.50 | Self-decide if ≥0.50 |

Confidence comes from `sync-tracker/state.tsv` per-category Confidence Score.

---

## 7.8 — Subagent Observations (`observations/`)

Every subagent dispatch returns at most one observation file. Naming convention:

```
<subagent-type>-S<sid>-<TS>.md
```

Examples:
- `sandwich-architect-S395-2026-05-17T14-32-00Z.md`
- `sandwich-verifier-S401-2026-05-17T22-15-00Z.md`
- `lesson-synthesizer-S365-2026-05-17T10-08-00Z.md`

### Frontmatter

```yaml
---
session_id: S<N>
subagent: <type>
dispatched_at: <ISO-8601>
returned_at: <ISO-8601>
duration_ms: <int>
tokens_used: <int>
tool_calls: <int>
outcome: PASS | PASS-WITH-CONCERNS | FAIL | DEFER
attestation_row: <attestation-log.tsv row index, if applicable>
---
```

### Body Structure

Per-subagent. Sandwich-verifier observations typically have:

```markdown
## Verdict
PASS-WITH-CONCERNS | merge-eligible

## V1 — Acceptance criteria check
- D1: PASS
- D2: PASS
- ...

## V2 — Verification grid
...

## CRITICAL Findings
(none)

## IMPORTANT Findings
F1: ...
F2: ...

## MINOR Findings
F3-F7: ...

## Promotion Candidates
PCG-V<sid>-1: ...
```

### Orphan Detection

`observation-orphan-detector.sh` (Stop hook) checks for observations whose dispatch.jsonl row never received a matching COMPLETED. Orphans flagged at HIGH after threshold.

---

## 7.9 — Session Logs (`sessions/`)

One file per session. Naming: `YYYY-MM-DD-session-<N>.md`. 257+ files at last count.

### Standard Body

```markdown
---
session: <N>
type: PLAN | FOCUSED_IMPL | MULTI_TASK_IMPL | VERIFY | RECOVERY | THESIS | INGEST | POST-MORTEM
model: opus | sonnet | haiku
plan: <pending plan reference if applicable>
---

# Session <N> — <DATE> — <TYPE>

## Goal
[from session brief]

## What Happened
[narrative]

## Files Touched
- `path/to/file1` — what changed
- `path/to/file2` — what changed

## Decisions Made
- D-NNN PROPOSED (see decisions/NNN-*.md)

## Mistakes This Session
- M-S<N>-1: ...
- M-S<N>-2: ...
OR
- M-S<N>-NONE: explicit no-mistakes attestation

## Verification
- mypy --strict: PASS
- pytest: 1178/1 PASS (baseline 1127+1)
- ruff: CLEAN
- bash-hook-lint: CLEAN

## Carry-Forward
[what next session inherits]

## Handoff
[checkpoint file written; next_action stated]
```

### Hook Enforcement

- `session-end-checklist-linter.sh`: enforces "Mistakes This Session" section presence (per HH-C.1).
- `taskcompleted-audit.sh`: scans for I-S1 (no LLM math) + I-S2 (citations) violations in session prose.
- `charter-coherence-spot.sh`: scans for I-S35 (research-aid framing) violations.

---

## 7.10 — Checkpoints (`checkpoints/`)

Checkpoints carry session-handoff state for cross-session continuity.

### Files

- `latest.md` — **canonical pointer**. Always the most recent checkpoint. Read by next session's bootstrap.
- `YYYY-MM-DD-S<sid>-close.md` — timestamped historical close.

### `latest.md` Body

```markdown
# Checkpoint — S<N> close — YYYY-MM-DD HH:MM SEAST

## Current Phase
[from current-execution.md]

## Active Track
[narrative]

## Last Action
[what just completed]

## Next Action (for resume)
[concrete next step the LLM should take on resume]

## Open Items
[any pending Q&A bundles, pending dispatches, etc.]

## Context Pointers
- session-plans/pending/NNN-*.md (active plan)
- specs/tier2-feature/NNN-*.md (active spec)
- last 3 session logs
```

### Hook Enforcement

- `checkpoint-write-marker.sh` (PostToolUse): marks `.checkpoint-written-<sid>` after any Edit/Write to `latest.md`.
- `checkpoint-write-end-turn-watchdog.sh` (PreToolUse): denies any subsequent non-exempt tool call once marker is set ("checkpoint write = end turn" rule).
- `checkpoint-marker-cleanup-resume.sh` (SessionStart): clears markers + surfaces `next_action` to new session.
- `pre-checkpoint-close-verifier.sh` (Stop): validates `latest.md` is internally consistent before allowing close.
- `auto-reboot-handoff-verify.sh` (Stop): HH-H.4 outer fence — verifies checkpoint freshness for auto-reboot.

---

## 7.11 — Telemetry Files

Append-only structured logs.

### `dispatch.jsonl`

Per-Agent-call telemetry. Two rows per dispatch:
- `DISPATCHED` (written by PreToolUse(Agent))
- `COMPLETED` (written by SubagentStop, FIFO-matched by `tool_use_id`)

Schema (excerpt):
```json
{
  "event": "DISPATCHED" | "COMPLETED",
  "ts": "<ISO-8601>",
  "tool_use_id": "<id>",
  "parent_session_id": "<sid>",
  "agent_type": "sandwich-architect",
  "model": "claude-opus-4-7",
  "tokens_real": 188432,
  "duration_ms": 286000,
  "outcome": "PASS",
  "failure_mode": null
}
```

Origin: D-023 v2 schema + HH-B.1/B.2.

### `cost-ledger.tsv`

Per-session + per-dispatch USD cost.

Schema:
```
timestamp \t session_id \t actor \t model \t tokens_in \t tokens_out \t cache_read \t cache_create \t cost_usd \t hook_event
```

Pricing table (Anthropic public 2025-2026):
- opus: $15 in / $75 out per MTok
- sonnet: $3 in / $15 out per MTok
- haiku: $0.80 in / $4 out per MTok
- cache_read = 10% input cost
- cache_create = 125% input cost

Computed by `cost-ledger-recorder.sh` (Stop + SubagentStop).

### `attestation-log.tsv`

Sandwich-verifier verdicts.

Schema:
```
ts \t session_id \t verifier_session_id \t plan_id \t verdict \t critical_count \t important_count \t minor_count \t merge_eligible
```

Append-only. Used by `harness-recovery-dod-watchdog.sh` (Stop) to detect un-attested completions.

### `component-telemetry.jsonl`

Per-tool JSONL telemetry. Captures every tool call across sessions.

### `up-intake-log.md`

User prompt intake events (intent classification log).

Records each prompt's:
- Trivial-whitelist match (yes/no)
- `intent-classifier` verdict (if dispatched)
- Resulting action (e.g., OPEN_QA_BUNDLE)

---

## 7.12 — Sync-Tracker (Confidence Score)

The `sync-tracker/` subdirectory implements the Confidence Score system (Track 8a, D-006).

### Files

- `weights.yaml` — per-category weights for Confidence Score computation
- `events.tsv` — append-only event log (each grill / answer / drift event)
- `state.tsv` — derived per-category Confidence Score (re-rendered from events)
- `_index.md` — auto-rendered human-readable view

### Categories

Categories defined in `weights.yaml`. Typical:
- SCOPE
- DECISION_ROUTING
- LANGUAGE (UL)
- INVARIANTS
- CALIBRATION
- ...

### How It's Used

Before any non-trivial decision, `sync-pull` skill reads `state.tsv`:
- If Confidence Score ≥ threshold (per `weights.yaml`) → SELF-DECIDE-OK
- Else → GRILL (build Q&A bundle)
- If very low → FORCE-GRILL

The threshold per category is what gates self-decide vs human-ratify.

### Sync-Grilling

`sync-grilling-trigger.sh` (SessionStart) fires when:
- 38 sessions elapsed since `last_check` in `sync-state.md`, OR
- 7 days elapsed since `last_check`

When triggered, agent considers firing an `AskUserQuestion` sync-bundle (4 questions max) per the template at `.claude/skills/grill-maximization/references/sync-bundle-template.md`.

**Catch-rate discipline** (per CLAUDE.md): if sync-grilling fires 3+ consecutive sessions with catch-rate 0 (no new SCOPE-tier divergence), the ritual is candidate for demotion-to-passive or retire.

---

## 7.13 — Self-Awareness (`self-awareness/`)

Per-model, per-effort-level, per-task-class profile cards.

### Files

- `profiles/<model>-<effort>-<task_class>.md` — profile card (one per combination)
- `sessions-rollup.tsv` — per-session aggregate

### Profile Card Structure

```markdown
---
model: claude-opus-4-7
effort: max
task_class: <one of: planning, focused-impl, multi-task-impl, verify, recovery, thesis, ingest, post-mortem>
sample_size: <int>
---

## Empirical Statistics

| Sample | Tokens (real) | Duration | Outcome |
|---|---|---|---|
| 1 | 188K | 286s | PASS |
| 2 | 224K | 340s | PASS-WITH-CONCERNS |
| ... |

## Known Issues
- KI-<id>: ...

## Best Practices
- BP-<id>: ...

## Cost Profile
[per-dispatch USD distribution]
```

### Auto-Population

`profile-template-auto-populate.sh` (Stop hook) appends a sample row to the matching profile card after every session. Bootstrap is automatic; the card grows over time.

Used by sandwich-architect for **Phase 1b self-calibration** (see [Chapter 5 § Sandwich Architect Mechanics](05-skills-commands-agents.md#sandwich-architect-mechanics)).

---

## 7.14 — Retention Policies

Per [CLAUDE.md § Tracking Retention (S99 RCA Layer 1; Q-RCA-1 = A)]:

| File | Cap | Action when over |
|---|---|---|
| `current-execution.md` | ≤5 sessions inline / ≤200 LOC | Auto-migrate oldest session row to archive |
| `agent-notes.md` | digest only / ≤700 LOC | WARN |
| `mistake-log.md` | digest only / ≤200 LOC | WARN |
| `component-telemetry.jsonl` | ≤10 MB | Weekly rotate via `telemetry-rotate.sh` |
| `.session-hooks.log` | varies | Weekly rotate via `session-hooks-log-rotate.sh` |
| `.drift-signals.log` | varies | Weekly rotate via `drift-signals-log-rotate.sh` |
| `dispatch.jsonl` | unbounded | Periodic 12h archive of pending rows via `dispatch-pending-rotation.sh` |
| `cost-ledger.tsv` | unbounded | Long-lived |
| `attestation-log.tsv` | unbounded | Long-lived |
| `urgent.md` | 4KB | Size-triggered rotate via `urgent-md-rotate.sh` |

Working-memory budget per `agent-workspace/proposals/memory-tiers.md` § Tier 1 = ≤ 20 KB combined for routine load.

Cap breaches: WARN-only via `tracking-retention.sh` Stop hook; manual archive to dated file.

---

## 7.15 — The Workspace Dualism Boundary

Memory lives in **`agent-workspace/memory/`**. The human-owned counterparts live in **`human-workspace/`**:

| Agent reads | Human writes |
|---|---|
| `agent-workspace/memory/personal-risk-profile.md` ← | (human curates) |
| (agent writes) → | `human-workspace/notifications/urgent.md` |
| ← | `human-workspace/user_prompt/*.txt` (agent reads only) |
| (agent writes to pending) | `human-workspace/q-and-a/answered/*.md` (human or agent via auto-mv) |
| (agent reads) | `human-workspace/decisions/*.md` (human writes formal ratifications) |

The dualism prevents [orch CF-DOGFOOD-2 failure mode](12-internals.md#cf-dogfood-2): shared-workspace mutation causing charter drift.

---

## 7.16 — Memory Anti-Patterns

| Anti-pattern | What goes wrong | Fix |
|---|---|---|
| Tier 1 bloat | Every session pays the overhead | `tier1-bloat-check.sh`; extract to Tier 2 |
| Skipping `current-execution.md` read at SessionStart | Hardcoded path drift | Read first per Reading Priority |
| Direct edit of constitution files | B-2 violation | Use proposal → ratification cycle |
| Write where Edit was needed (L-S45-2) | Destructive overwrite of append-only files | `write-vs-edit-guard.sh` blocks |
| Updating `current-execution.md` only at session-end | AP-8 pre-staged work drift | Update on task complete, not on close |
| ADR number collision | Two ADRs with same number | `pre-dispatch-adr-number-check.sh` |
| Silent dispatch.jsonl orphan | Subagent COMPLETED never written | `observation-orphan-detector.sh` |
| Hooks reading too many memory files | UserPromptSubmit chain slowdown | Cheap-first ordering + same-session caching |
| ROUTINE-IDLE close ritual when no signal | Busy-work loops (L-S310-1) | Demote ritual; emit one-line state ack |

---

## 7.17 — Where to Read Next

- **How sessions flow through memory** → [Chapter 8 — Lifecycle](08-lifecycle.md)
- **How memory is verified** → [Chapter 9 — Quality System](09-quality-system.md)
- **How rules emerge from memory** → [Chapter 10 — Self-Improvement](10-self-improvement.md)
- **Full memory inventory** → [Reference § Memory](../reference/inventory-memory.md)
