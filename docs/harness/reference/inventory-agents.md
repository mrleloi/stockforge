# Reference — Subagents Inventory

> **Audited**: 2026-05-19
> **Source**: `.claude/agents/*.md` (15 subagents total — includes `harness-docs-auditor` added with this book)
> **Maintainer**: Run `/harness-docs sync agents` to regenerate

Each subagent is a fresh-context worker persona at `.claude/agents/<name>.md`. Dispatched via the `Agent` tool.

All 15 declare `model: opus` (per user directive 2026-05-17 "full opus + follow budget").

See [Chapter 5 § Subagents](../en/05-skills-commands-agents.md#54--subagents) for anatomy.

---

## Planner Personas (5 agents)

| Agent | Tools | Dispatched by | Output |
|---|---|---|---|
| `action-guide-planner` | Read, Glob, Grep | Manual / session-start follow-up | File-read order + modify list + skill activations + verification steps |
| `bdd-planner` | Read, Glob, Grep, Write | Manual (post `/spec-author`) | BDD scenarios + integration cases + unit cases + pyramid check |
| `master-planner` | Read, Glob, Grep, Write | `/master-plan` | Session plans at `session-plans/pending/NNN-*.md` |
| `sandwich-architect` | Read, Glob, Grep, Write | PLAN session type | Detailed execution plan; never writes prod code |
| `spec-author` | Read, Glob, Grep, Write | `/spec-author` | Dual-layer spec to `specs/tier2-feature/NNN-*.md` |

---

## Executor Persona (1 agent)

| Agent | Tools | Dispatched by | Output |
|---|---|---|---|
| `sandwich-dev` | Read, Glob, Grep, Write, Edit, Bash | FOCUSED_IMPL / MULTI_TASK_IMPL | Working code + tests + verification |

---

## Auditor / Fresh-Eyes Personas (9 agents)

| Agent | Tools | Dispatched by | Output |
|---|---|---|---|
| `devils-advocate` | Read, Glob, Grep | `/devils-advocate` | Multi-dim critique: hidden assumptions / edge / failure / alternatives / 2nd-order |
| `drift-detector` | Read, Glob, Grep, Bash | `/drift-check` | Semantic DR7 (UL drift) + DR12 (anti-pattern); writes to `observations/` |
| `harness-docs-auditor` | Read, Glob, Grep, Bash | `/harness-docs audit` (manual) | Inline text audit report; main session persists per PCG-S401-4 (added 2026-05-19) |
| `intent-classifier` | Read, Glob, Grep | `user-prompt-intake` skill | YAML w/ primary_intent + recommended_action + suggested_grill_questions |
| `intent-vs-impl-diff` | Read, Glob, Grep, Bash, Write | On-demand / phase-boundary | Drift-log at `drift-logs/intent-impl-<TS>.md`; aligned/drifted-soft/drifted-hard |
| `lesson-synthesizer` | Read, Glob, Grep, Bash, Write, Edit | `lesson-synthesis-watchdog` ALERT | ≥1 new KI/BP/agent-notes entry with session-diff evidence + L-S{NN}-N ID |
| `research-scanner` | Read, Glob, Grep, WebFetch | Manual (agent-pick-1 dogfood) | ≤5-page report with repo URL + SHA + as-of for every claim |
| `sandwich-verifier` | Read, Glob, Grep, Bash | VERIFY session type | Inline text findings (NO Write per PCG-S401-4); main session persists |
| `ul-auditor` | Read, Glob, Grep, Bash | `/ul-audit` | Drift report with V-N violations; suggests but never auto-renames |

---

## Why `sandwich-verifier` Has No Write Tool

Per **PCG-S401-4**: a 3-incident cluster (S397/S400/S401) where dispatch briefs asked the verifier to Write findings, but the persona forbids it. The pattern now codified:

- Verifier returns findings **inline as text** in its final message.
- Main session reads and persists to disk under main's authorship.
- Keeps verifier's role purely advisory; preserves traceability.

---

## Tool Grant Patterns

Most agents have minimal-grant tools:

- **Read-only review** (devils-advocate, drift-detector with bash, sandwich-verifier): Read + Glob + Grep + optional Bash
- **Plan-write only** (master-planner, sandwich-architect, spec-author, bdd-planner): + Write
- **Full impl** (sandwich-dev): + Edit + Bash
- **Special** (research-scanner): + WebFetch (singleton — only agent with WebFetch)
- **Special** (lesson-synthesizer): + Edit (writes to agent-notes.md, mistake-log.md)

---

## Cost Profile (Opus, Approximate)

| Agent | Typical tokens | Typical USD |
|---|---|---|
| master-planner | 100-200K | $1.5-3 |
| sandwich-architect | 150-230K | $2-4 |
| sandwich-dev (FOCUSED_IMPL) | 100-150K | $1.5-2 |
| sandwich-dev (MULTI_TASK_IMPL) | 200-330K | $3-5 |
| sandwich-verifier | 80-180K | $1-2 |
| lesson-synthesizer | 60-100K | $0.9-1.5 |
| intent-classifier | 30-60K | $0.5-1 |
| devils-advocate | 80-150K | $1-2 |
| research-scanner | 60-180K | $1-3 |

Logged to `cost-ledger.tsv` automatically via `cost-ledger-recorder.sh`.

---

## See Also

- [Chapter 5 — Subagents](../en/05-skills-commands-agents.md#54--subagents)
- [Chapter 8 — Sandwich Pattern Choreography](../en/08-lifecycle.md#84--the-sandwich-pattern-choreography)
- [Chapter 11 § Recipe 3 — Write a New Subagent](../en/11-cookbook.md#recipe-3--write-a-new-subagent)
