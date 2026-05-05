---
status: CHARTER
ratified_at: 2026-05-01
ratified_by: Project owner — Q&A 2026-05-01-001 Q3=A explicit pick (S38 FOCUSED_IMPL Bundle 1 charter promote)
ratifying_decision: D-017
companion_hook: scripts/hooks/tier1-bloat-check.sh (authored at S38 per Q3=A)
source_evidence:
  - observations/queued-grill-master.md § Q-D3 (codify Tier 1/2/3 memory tiers; closed S15 Batch 1 — Yes, add memory-tiers.md to constitution)
  - session-plans/pending/003-S15-track-7-constitution-amendments.md § 4.2
  - CLAUDE.md § Session Protocol (existing implicit tiering)
  - agent-workspace/CLAUDE.md § Reading Priority for Agent (existing implicit tiering)
  - human-workspace/q-and-a/pending/2026-05-01-001-S35-charter-promote-batch.md § Q3=A (explicit pick — promote + author tier1-bloat-check.sh)
predecessor_proposal: agent-workspace/proposals/memory-tiers.md (S16 draft; moved to constitution at S38)
---

# Memory Tiers — CHARTER

> **Status**: CHARTER (ratified 2026-05-01 at S38 via Q&A 2026-05-01-001 Q3=A). Edits require explicit user prompt + Q&A per `agent-workspace/CLAUDE.md` constitution-amendment process.

## Purpose

Make explicit the three tiers of context the agent draws from across a session. Without this codification, every agent re-derives the priority order from scattered prose and occasionally over-loads at SessionStart (blowing bootstrap budgets per `autonomous-protocol.md` Rule 4).

## Tier Definitions

### Tier 1 — Immutable Always-Loaded (bootstrap)

**Loaded automatically at SessionStart by the harness** (CLAUDE.md hard rule + SessionStart hook injects). Counts against bootstrap ceiling per session type.

| File | Why Tier 1 |
|---|---|
| `CLAUDE.md` | Project-wide identity + hard rules; needed every turn |
| `agent-workspace/CLAUDE.md` | Workspace contract; agent's domain rules |
| `agent-workspace/memory/current-execution.md` | THE single routing source of truth |
| `agent-workspace/memory/checkpoints/latest.md` (if recent ≤24h) | Resume context |

**Total target size**: ≤8K tokens (per `autonomous-protocol.md` Rule 4 PLAN session ceiling). Tier 1 must stay tight; if it exceeds 8K consistently, files must be re-shaped or split (heaviest file becomes Tier 2 with explicit-load discipline).

### Tier 2 — Just-In-Time (loaded on demand at first need)

**Read when the active task surfaces them as needed**. Agent reads via Read tool; not auto-injected.

| File | When to load |
|---|---|
| `PROJECT_CHARTER.md` | When charter principle being applied or charter clause being amended |
| `AGENT_OPERATING_MANUAL.md` | When dispatching subagent / picking session type / consulting model-routing rules |
| `agent-workspace/memory/project.md` | Phase-boundary review; consulting recent ADRs |
| `agent-workspace/memory/agent-notes.md` | Pattern recall; learning rule lookup |
| `agent-workspace/memory/mistake-log.md` | Pre-flight failure catalog (per agent-workspace/CLAUDE.md priority 5) |
| Last 3 files in `agent-workspace/memory/sessions/` | Recent session context |
| `agent-workspace/session-plans/pending/<active-plan>.md` | When executing a plan's specific track |
| `agent-workspace/constitution/<topic>.md` (the SPECIFIC one task touches) | Topical lookup |
| Specific spec in `specs/**/*.md` | When implementing the spec or verifying alignment |
| Specific skill `.claude/skills/<name>/SKILL.md` (beyond auto-discover) | When deep-diving into a procedure |

### Tier 3 — Explicit Pull (loaded only when user or audit demands)

**Never auto-loaded; read only on direct request or specific audit dispatch**.

| File / directory | When to load |
|---|---|
| `agent-workspace/memory/sessions/` (older than last 3) | Post-mortem / archaeology |
| `agent-workspace/memory/decisions/<NNN>-*.md` (specific historical decision) | Cross-reference for new decision |
| `agent-workspace/memory/observations/` (subagent return artifacts) | When ingesting a specific subagent's output |
| `agent-workspace/memory/drift-logs/` | Drift audit dispatch |
| `agent-workspace/memory/post-mortems/` | Failure-driven learning |
| `agent-workspace/learning-data/index/` (RAG queryable) | Research scanner / promote-rule subagent |
| `agent-workspace/memory/thesis-log/` | THESIS sessions only (read-only on code per CLAUDE.md) |
| `obsidian-vault/wiki/<entity>.md` | Entity / concept lookup during INGEST or THESIS |
| `eval-sets/baseline-results/` | Eval regression review only |

**Hard exclusion (never read in runtime path)**: `agent-workspace/learning-data/{events,archive}/` — write-only NDJSON queue per D-005 5.5d.1 + drift signal D9. Settings.json `permissions.deny` enforces.

## Boundary Rules

1. **Tier 1 never exceeds bootstrap ceiling per session type** (per `autonomous-protocol.md` Rule 4). If it would, redesign — split a file, pull non-essential prose to Tier 2.
2. **Tier 3 stays Tier 3**: don't auto-promote to Tier 2 just because it was useful once. Promotion requires phase-boundary review.
3. **Recency-window for "last 3 sessions"**: `find sessions/ -name '*.md' | sort -r | head -3` — strict mtime, no judgment about "the relevant 3".
4. **Wiki vs raw**: `obsidian-vault/wiki/` is Tier 3 navigable; `obsidian-vault/raw/` is immutable (deny-list per CLAUDE.md hard rule); never load raw in production reasoning.

## Anti-Patterns

- **Greedy SessionStart bootstrap**: loading all 9 constitution files at start "just in case" — that's ~12-15K wasted; each is Tier 2 unless task touches its topic.
- **Tier-3 normalization**: making historical sessions/decisions Tier 2 because "they might be relevant" — that's defensive over-loading; explicit-pull is intentional.
- **Reading wiki/raw at thesis time without Tier discipline**: loads 200+ entity files; should be RAG-queried via `learning-data/index/` instead.

## Acceptance Process

Moves to `agent-workspace/constitution/memory-tiers.md` on user approval. Once promoted, additions to any tier require explicit rationale + drift impact note (a Tier 1 addition expands every session's bootstrap; not a free choice).
