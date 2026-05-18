# Chapter 4 — The Constitution

> **Diataxis quadrant**: Reference + Explanation
> **Reading time**: ~45 minutes
> **Prerequisites**: Chapter 2 (Mental Model) for the *why*

The constitution is the immutable foundation. Everything above it can change; the constitution can only change through an explicit ratification process with cool-down windows. This chapter is the complete reference.

It documents:

1. **`PROJECT_CHARTER.md`** — the 11 principles
2. **Identity files** (`CLAUDE.md`, workspace contracts)
3. **The 17 constitution files** at `agent-workspace/constitution/`
4. **Permissions** at `.claude/settings.json`
5. **The amendment process**

---

## 4.1 — Identity Files (Always-Loaded)

Three files are loaded automatically into every session via `CLAUDE.md` mechanisms. Together they consume **~5-8K tokens** ([Tier 1 budget per HH-5](09-quality-system.md#hh-5)).

### `PROJECT_CHARTER.md`

> **Status**: Immutable v1.1 — changes require explicit charter revision.
> **Revision protocol**: 48h cool-down + version bump.
> **Last revision**: 2026-05-12 (v1.0 → v1.1, added Principle 11).

The charter sets vision, scope, principles, and success criteria. It does **not** change with the product roadmap — it changes only when the project's *fundamental nature* changes.

| Section | What it locks |
|---|---|
| **Vision** | What the system is and is not |
| **Core Insight** | Why Vietnam stock market structure justifies this approach |
| **Craft Philosophy** | Self-use first, commercial second |
| **11 Principles** | The non-negotiable rules of how the system operates |
| **Four-Tier Signal Architecture** | Hard data / official narrative / influence network / crowd sentiment |
| **First Sub-Scope (6 months)** | VN30 + mid-cap, long-only equity, 1-month+ holds |
| **Honest Boundaries** | What system does NOT do |
| **Success Criteria** | Month 3, 6, 9, 12 measurable outcomes |
| **Technical Foundation** | Stack (Python, Postgres, Redis, Claude API) |
| **Anti-Charter** | What we explicitly reject |

### The 11 Principles (Reference)

1. **Evidence grounding** — every claim, every number traceable to source + as-of date.
2. **Structured output over narrative** — multi-criteria assessment, never single buy/sell score.
3. **Adversarial by design** — bear + bull + critic + quant + behavior + manager perspectives.
4. **Proprietary data moat** — every news ingested, every KOL recommendation tracked, every thesis post-mortem'd.
5. **Pattern transfer + local adaptation** — global setups + Vietnam-specific overlays.
6. **Human-in-loop is the product** — augment thinking, never replace it.
7. **Dogfood mandatory** — if I don't use it weekly, it gets killed.
8. **Calibration over confidence** — track own accuracy, never claim confidence not earned through hit rate.
9. **No LLM math** — LLM never generates numbers; deterministic code only.
10. **Position sizing & risk management are deterministic** — code-enforced rules; LLM cannot override.
11. **Harness must self-verify firing, not self-attest existence** — every hook ships with firing-test; HH-1..HH-12 continuous self-scan.

Principles 9, 10, 11 are the **harness load-bearers** — they shape most hooks and constitution rules.

### `CLAUDE.md` (Project Root)

> **Token target**: <2500 (loaded every session).

This is the project-level always-loaded context. Sections:

- **Identity**: who Claude Code is in this project
- **Core Principles (Karpathy 4)** — P1 Think Before Coding, P2 Simplicity First, P3 Surgical Changes, P4 Goal-Driven Execution
- **StockForge-Specific Hard Rules** — domain integrity rules
- **Session Protocol** — start / end ritual checklists
- **Constitution table** — pointers to detailed rules
- **Hard Rules (general)** — domain framework purity, BC isolation, VBW protocol, immutability lists, deterministic gates, retention bands
- **Dispatch Rules** — single source of truth
- **Session Types** — 8 types + budgets
- **Quality Gates** — 3 tiers
- **Common Anti-Patterns** — high-frequency mistakes to avoid
- **Key References** — file pointer index

### `agent-workspace/CLAUDE.md` (Workspace Contract)

The agent's own workspace contract. Sets:

- **Identity** — agent-owned execution + memory layer
- **Subdirectory table** — purpose + lifecycle for each
- **Contract Rules (BINDING)** — 7 numbered rules including ADR discipline, routing source-of-truth, raw/wiki immutability, provenance mandate, commit/push distinction
- **Reading Priority** — canonical load order
- **Anti-Patterns** — workspace-specific
- **Connection to human-workspace/** — the auto-mv rule (HH-E.2 / D-031)

### `human-workspace/CLAUDE.md` (Human Contract)

Defines what the human owns and the agent's narrow write rights:

- `user_prompt/` — human writes; agent reads only
- `decisions/` — human writes formal ratifications
- `q-and-a/` — pending/answered/stale lifecycle (auto-mv rule)
- `notifications/` — agent appends urgent.md; human reads

### `obsidian-vault/CLAUDE.md` (Vault Contract)

Defines:

- `raw/` — immutable source materials (agent READS only; never writes)
- `wiki/` — agent-owned knowledge base
- Wikilink + frontmatter conventions
- Schema (entity types, tag conventions)

---

## 4.2 — The 17 Constitution Files

These live at `agent-workspace/constitution/`. All are denied to agent edit by [`.claude/settings.json`](#43--permissions). Modification requires a [proposal → cool-down → ratification](#46--amendment-process) cycle.

| File | Status | Purpose |
|---|---|---|
| [`karpathy-principles.md`](#karpathy-principles) | CHARTER | The 4 P principles applied to every session |
| [`architecture.md`](#architecture) | CHARTER | Layer boundaries, 9 BC rules |
| [`invariants.md`](#invariants) | CHARTER | General invariants (I-1..I-54) |
| [`invariants-stockforge.md`](#invariants-stockforge) | CHARTER | Stock-domain invariants (I-S1..I-S65) |
| [`boundaries.md`](#boundaries) | CHARTER | Hard + soft boundaries (B-1..B-N, SB-1..SB-N) |
| [`vbw-protocol.md`](#vbw-protocol) | CHARTER | Verify-Before-Write 4 checkpoints |
| [`drift-signals.md`](#drift-signals) | CHARTER | DR1-DR12 + stock-specific DR-S signals |
| [`session-budgets.md`](#session-budgets) | CHARTER | Per-session-type token budgets |
| [`autonomous-protocol.md`](#autonomous-protocol) | CHARTER | Autonomous-mode rules (Rules 1-10) |
| [`coding-principles.md`](#coding-principles) | CHARTER | Code-level style + structure rules |
| [`decision-discipline.md`](#decision-discipline) | CHARTER | ADR 12-field schema + confidence thresholds |
| [`financial-data-protocol.md`](#financial-data-protocol) | CHARTER | 16 stock-domain data integrity rules |
| [`harness-health-protocol.md`](#harness-health-protocol) | CHARTER | HH-1..HH-12 self-scan signal catalog |
| [`memory-routing-tree.md`](#memory-routing-tree) | CHARTER | Where to put what memory artifact |
| [`memory-tiers.md`](#memory-tiers) | CHARTER | Tier 1 (always-load) ≤8K; Tier 2 JIT; Tier 3 explicit |
| [`severity-schema.md`](#severity-schema) | CHARTER | CRITICAL / HIGH / MEDIUM / LOW classifications |
| [`portability.md`](#portability) | PROPOSAL | Cross-platform (Win/Mac/Linux) rules |

The 15 CHARTER + 1 SCHEMA + 1 PROPOSAL split reflects that `portability.md` is awaiting Cluster C ratification bundle. The functional rules in `portability.md` are partially enforced by hooks (`bash-hook-lint.sh`, `settings-inline-env-prefix-detector.sh`) but not yet binding at constitution tier.

---

### karpathy-principles

**Source**: forrestchang/andrej-karpathy-skills (MIT). Adopted at Charter v1.0.

Four principles. Applied to every session. Address specific LLM failure modes.

| Principle | Prevents | Mechanism |
|---|---|---|
| **P1 Think Before Coding** | Silent picking, hidden confusion, missed tradeoffs | State assumptions explicitly; ask when ambiguous; stop when confused |
| **P2 Simplicity First** | Overengineering, speculative flexibility, defensive code for impossible cases | Minimum code that solves the problem; no abstractions for single-use code |
| **P3 Surgical Changes** | Drive-by refactoring, silent formatting changes, deletion of pre-existing dead code | Every changed line traces to the task; don't "improve" adjacent code |
| **P4 Goal-Driven Execution** | Unclear "done" state, unverifiable work | Transform imperative → verifiable: "add validation" becomes "write tests for invalid inputs, then make them pass" |

**Conflict resolution** (when two principles disagree):
- P1 over P4 — if confused, stop and ask
- P2 over P3 — if existing code is bad AND task is substantial, simplify carefully with approval
- P3 over P2 — don't let "simplicity" justify rewriting unrelated code
- P1 over P2 — don't assume simple solution if task is genuinely ambiguous

When in doubt: ask rather than assume; write less rather than more; change less rather than more; make goals explicit rather than implicit.

---

### architecture

Defines the **9 bounded contexts** of the StockForge stock domain:

- BC-1: Market Data (prices, volumes, OHLCV)
- BC-2: Fundamental (financial statements, ratios)
- BC-3: Company Intelligence (corporate actions, governance)
- BC-4: Macro (rates, FX, money flow)
- BC-5: News (mainstream financial news)
- BC-6: Influence (KOL channels, recommendations)
- BC-7: Crowd (sentiment, pump detection)
- BC-8: Analysis (thesis, signals, scoring)
- BC-9: Portfolio (positions, risk, P&L)

**Layer boundaries** (Clean Architecture):

- `packages/domain/<bc>/` — pure Python, **no framework**, no Pydantic, no FastAPI. Use dataclasses.
- `packages/application/<bc>/` — use cases, ports (Protocol classes).
- `packages/infrastructure/<bc>/` — adapters (DB, LLM, scraper, HTTP).
- `packages/contracts/` — shared cross-BC schemas + events.

**BC isolation rule**: never direct-import between bounded contexts. Use the `contracts/` layer.

**Domain purity rule** (enforced by [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals)): `packages/domain/**` may not `import fastapi`, `import pydantic`, `import sqlalchemy`, etc.

---

### invariants + invariants-stockforge

Two files. `invariants.md` carries general invariants (I-1..I-54); `invariants-stockforge.md` carries stock-domain invariants (I-S1..I-S65).

**Most important stock invariants** (cited everywhere):

| ID | Rule | Enforced by |
|---|---|---|
| **I-S1** | No LLM math. Every number from deterministic code. | `post-tool-citation-grep.sh`, `taskcompleted-audit.sh` |
| **I-S1-1** | Numeric-field discipline (D-065 amendment) — required precision + units | Code review |
| **I-S2** | Every claim cites source + as-of date | `post-tool-citation-grep.sh` |
| **I-S7** | Confidence claims must cite calibration data | `boundaries.md` B-12 |
| **I-S10** | Thesis must include bear case (≥3 specific points) | `drift-signals-D1-D9.sh` D7 |
| **I-S35** | Frame as research aid; never "buy/sell/recommendation" | `charter-coherence-spot.sh` |
| **I-S55..I-S65** | VN-specific (T+2.5 settlement, room ngoại, sàn-tier, FX VND-USD) | Code review |

---

### boundaries

Two tiers: **Hard** (never cross without explicit approval) and **Soft** (require good reason; document in decision log).

**Hard Boundaries** (B-1..B-14):

| ID | Boundary |
|---|---|
| B-1 | Never modify `PROJECT_CHARTER.md` |
| B-2 | Never modify `agent-workspace/constitution/*` |
| B-3 | Never write to `obsidian-vault/raw/` |
| B-4 | Never commit without explicit user request *(superseded 2026-05-15 by D-060: agents MAY commit; agents MUST NOT push)* |
| B-5 | Never perform destructive operations without same-session approval (DELETE FROM, DROP TABLE, rm -rf, force push, branch deletion) |
| B-6 | Never deploy to production without approval |
| B-7 | Never disable tests or lints to make CI pass |
| B-8 | Never install new dependencies without review |
| B-9 | Never hardcode secrets, credentials, API keys |
| B-10 | Never override safety mechanisms (budget caps, rate limits, retry limits) |
| B-11 | Never override position sizing or risk rules |
| B-12 | Never claim confidence without calibration data |
| B-13 | Never modify past thesis-log entries |
| B-14 | Never modify `eval-sets/baseline-results/` |

**Soft Boundaries** (SB-1..SB-N): architectural decisions beyond established patterns, API contract changes, security-sensitive changes, cross-BC contract changes, business rule changes, destructive schema migrations, downstream-affecting spec changes, new data provider integrations.

---

### vbw-protocol

Verify-Before-Write. Measured: 11.1% hallucination rate → 0% after adoption.

Four checkpoints, applied always, cannot skip:

| Checkpoint | When | Action |
|---|---|---|
| **PRE-SPEC** | Before writing any specification | Read actual source code; list actual methods; verify factory signatures; grep before assuming "missing"; mark CURRENT vs PROPOSED |
| **PRE-TEST** | Before writing any test | Verify every method call exists from type defs; verify factory signature; verify import paths; verify base class methods; test one file first |
| **MID-IMPLEMENT (every 5 steps)** | During session | Cross-reference against spec; check plan state; review for convention-derived assumptions; re-read task description |
| **PRE-COMMIT** | Before staging changes | Verify diff matches plan; mypy/pytest/ruff pass; no new D1-D9 drift signals |

The protocol is operationalized inside every sandwich plan as **STEP 0 — VBW Live Verification**.

---

### drift-signals

Twelve drift signals (DR1-DR12) plus stock-specific (DR-S1, DR-S2). Run via `/drift-check` command + auto-fired on Stop via [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals).

**Tiered coverage map** (added 2026-05-05 via D-029):

- **Tier-A — Automated detector** (Stop-hook, every session-end): DR-A1..DR-A5, DR1, DR3, DR6, DR8, DR-S1, DR-S2, plus partial DR2, DR5, DR10.
- **Tier-B — Manual `/drift-check` command** (semantic, LLM-judgment): DR4 (hardcoded prompt outside `prompts/`), DR7 (UL term drift), DR12 (anti-pattern from `agent-notes.md`).
- **Tier-C — DB-query check** (requires Postgres): DR9 (synthesis without verifier), DR11 (stale session-handoff).

**HIGH severity signals** (block commit/merge):

- DR1: Domain layer imports framework
- DR2: Evidence without citation
- DR5: Claim stored without required metadata
- DR6: `Any` type in domain package
- DR-S1: LLM emitted number without tool call
- DR-S2: Thesis output without bear case
- DR-A1: LOC ceiling overrun (>20%)

---

### session-budgets

Per-session-type token budgets. Two columns: Sonnet original + Opus recalibration (per S345-S361 empirical sample n=10+).

| Session type | Sonnet budget | Opus budget | Purpose |
|---|---|---|---|
| PLAN | 50-80K | 150-230K | Architect; produces session plan |
| FOCUSED_IMPL | 100-150K | 100-150K† | Dev; 1-3 tasks from plan |
| MULTI_TASK_IMPL | 150-250K | 200-330K | Dev; 4-10 tasks |
| VERIFY | 30-60K | 80-180K | Verifier; adversarial review |
| RECOVERY | 80-150K | 130-230K | Revert + re-plan after failure |
| THESIS | 60-100K | 100-180K | Multi-perspective stock analysis |
| INGEST | 40-80K | 80-150K | Data source → KB |
| POST-MORTEM | 30-50K | 60-100K | Outcome review + calibration update |

† Dev on Opus shows under-budget actuals (S349=98K, S354=34K, S357=45K) — file-bounded work resists token inflation.

**Hard caps** (per D-004 Opus 4.7 recalibration):

- **Wind-down**: 180K (auto-prep handoff)
- **Cliff**: 220K (auto-reboot via `session-self-reboot.sh`)
- **Hard cap**: 250K (mandatory split)

**Hard rule**: never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)

**Hard rule**: THESIS sessions are read-only on code. Output goes to `agent-workspace/memory/thesis-log/`.

---

### autonomous-protocol

Ten rules governing autonomous mode operation:

1. `autonomous_mode = true` is the ONLY mode (no SUPERVISED bifurcation)
2. Mode A/B/C/D coverage (Stop-hook handoff modes)
3. Context auto-loader: hybrid deterministic + LLM-selector
4. Bootstrap token ceiling per session type (≤6K-≤20K)
5. Skill-tool in autonomous mode: gate; replace with inline/subagent
6. Drift self-detection: defense-in-depth (per-task + Stop-hook + fresh-context auditor)
7. Drift recovery flow: Q&A bundle async
8. AskUserQuestion is for genuinely-new SCOPE/CHARTER decisions only
9. Mode-D clean-handoff coverage (checkpoint mtime ≤60s, no A/B/C)
10. Autonomous-mode defection forbidden (Mode-E habit-pattern hardening; 4-layer defense)

### coding-principles

Code-level style + structure. Topics: SOLID adherence in Python, Protocol-based DI in `domain/`, async/await rules, error handling conventions, logging discipline, no-bare-except, type hints required, mypy --strict baseline.

### decision-discipline

The ADR (Architecture Decision Record) discipline. Detailed in [§ 4.5](#45--decision-discipline-adrs).

### financial-data-protocol

16 rules specific to financial data integrity. Highlights:

- **Rule 1**: All price data must be timezone-aware (Vietnam = ICT/Bangkok = UTC+7)
- **Rule 4**: All fundamental data must carry `as_of` date matching the report period
- **Rule 12**: VN trades settle T+2.5 — exposure calc must respect settlement window
- **Rule 13**: Room ngoại (foreign-owned-room) data must be sourced from official HOSE/HNX feed
- **Rule 14**: Sàn tier (HOSE/HNX/UPCoM) must drive different liquidity assumptions
- **Rule 15**: FX VND-USD must use SBV official rate, not market rate
- **Rule 16** (D-065 amendment): Numeric fields must declare precision + units in glossary; no implicit conversions

### harness-health-protocol

The 12-signal HH-1..HH-12 catalog. Detailed in [Chapter 9 § Harness Health](09-quality-system.md#harness-health).

### memory-routing-tree

Where to put what memory artifact. The decision tree the agent uses to route a piece of state. Branches on artifact type (rule learned / decision / observation / thesis / etc.) → destination directory.

### memory-tiers

Three-tier memory model:

- **Tier 1** — Always-loaded. Hard cap **≤8K tokens**. Enforced by `tier1-bloat-check.sh`.
- **Tier 2** — Just-in-time (read when relevant signal fires).
- **Tier 3** — Explicit-pull (read only when explicitly requested).

`CLAUDE.md` + `agent-workspace/CLAUDE.md` + `human-workspace/CLAUDE.md` + `MEMORY.md` + `project.md` + `current-execution.md` must sum to ≤8K combined.

### severity-schema

Four severity levels (D-058 ratification, S310):

| Level | Examples | Action |
|---|---|---|
| **CRITICAL** | Stale-checkpoint marker, Q&A age ≥96h, charter-violation marker, ghost-greening marker | Write `.autonomous-BLOCKED` flag; URGENT entry; Telegram push |
| **HIGH** | Q&A age ≥6h pending, charter-tier ADR PROPOSED age ≥24h, mistake-log severity=high, notification ALERT-URGENT | URGENT entry; UserPromptSubmit context demanding AskUserQuestion; Telegram push |
| **MEDIUM** | ARCH/SCOPE PROPOSED age ≥12h, notification WARN | Weekly digest |
| **LOW** | Below threshold | Log only |

### portability (PROPOSAL — awaiting Cluster C bundle)

Cross-platform rules. Currently enforced partially via hooks. Topics: bash POSIX-only (no jq/yq/python3 except in fallbacks), Windows path conversions, line endings (LF only via .gitattributes), env-prefix gotchas (use `env VAR=val cmd` not `VAR=val cmd`).

---

## 4.3 — Permissions (`.claude/settings.json`)

The harness's enforcement layer for what files the agent may read/write/edit, what bash commands are allowed/denied, and which hooks fire on which events.

### Permission Model

```json
{
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [
      "Bash(ls:*)", "Bash(git status:*)", "Bash(git commit:*)",
      "Bash(python -m pytest:*)", "Bash(mypy:*)", "Bash(ruff:*)",
      "Read(*)",
      "Write(apps/**)", "Write(packages/**)", "Write(specs/**)",
      "Write(agent-workspace/memory/sessions/**)",
      "Write(agent-workspace/memory/decisions/**)",
      "Edit(apps/**)", "Edit(packages/**)",
      "Edit(.claude/agents/**)", "Edit(.claude/skills/**)",
      "Edit(.claude/settings.json)",
      ...
    ],
    "deny": [
      "Write(PROJECT_CHARTER.md)",
      "Write(agent-workspace/constitution/**)",
      "Write(obsidian-vault/raw/**)",
      "Write(eval-sets/baseline-results/**)",
      "Write(human-workspace/user_prompt/**)",
      "Write(human-workspace/decisions/**)",
      "Edit(PROJECT_CHARTER.md)",
      "Edit(AGENT_OPERATING_MANUAL.md)",
      "Edit(agent-workspace/constitution/**)",
      "Bash(git push:*)",
      "Bash(rm -rf:*)",
      "Bash(DROP:*)",
      "Bash(DELETE FROM:*)",
      ...
    ]
  }
}
```

### Key Deny Rules

| Pattern | Rationale |
|---|---|
| `Write(PROJECT_CHARTER.md)` | B-1 enforcement |
| `Edit(PROJECT_CHARTER.md)` | B-1 enforcement (Edit also denied) |
| `Edit(agent-workspace/constitution/**)` | B-2 enforcement |
| `Write(obsidian-vault/raw/**)` | B-3 enforcement |
| `Write(eval-sets/baseline-results/**)` | B-14 enforcement |
| `Write(human-workspace/user_prompt/**)` | Workspace dualism |
| `Write(human-workspace/decisions/**)` | Workspace dualism |
| `Write/Edit(human-workspace/q-and-a/{answered,stale}/**)` | Auto-mv hook is sole writer |
| `Bash(git push:*)` | Agents commit; humans push |
| `Bash(rm -rf:*)` | Mass-deletion defense (R1 of 3) |
| `Bash(DROP:*)` | SQL destructive guard |
| `Bash(DELETE FROM:*)` | SQL destructive guard |

### Environment Variables

```json
"env": {
  "PYTHON_ENV": "development",
  "STOCKFORGE_HOOK_PROFILE": "standard",
  "STOCKFORGE_SPAWNED": "false",
  "STOCKFORGE_WIND_DOWN_TOKENS": "180000",
  "STOCKFORGE_CLIFF_TOKENS": "220000",
  "STOCKFORGE_LOC_STRICT": "0",
  "STOCKFORGE_CITATION_STRICT": "0",
  "STOCKFORGE_DRIFT_STRICT": "0",
  "STOCKFORGE_SAME_COMMIT_STRICT": "0",
  "STOCKFORGE_WATCHDOG_DISABLE": "0",
  "STOCKFORGE_LINT_DOCTRINE_PHASE_0_PORTABILITY": "0"
}
```

These are read by hooks. Most are 0/1 strictness toggles for warn-vs-block behavior.

### Hooks Wiring

`settings.json` declares which hook scripts fire on which Claude Code event. Detailed in [Chapter 6 § Wiring](06-hooks.md#wiring).

---

## 4.4 — Decision Discipline (ADRs)

ADRs (Architecture Decision Records) live at `agent-workspace/memory/decisions/NNN-<slug>.md`. Sequential numbering, never reused.

### The 12+ Field Schema

```yaml
---
id: D-NNN
title: <short title>
date: YYYY-MM-DD
status: PROPOSED | ACCEPTED | SHIPPED | SUPERSEDED-BY-D-NNN | REJECTED
level: CHARTER | SCOPE | ARCH | IMPL
author: <agent | human>
source_evidence:
  - <file:line citations>
intent_classification: <one of: CHARTER_AMEND | SCOPE_CHANGE | ARCH_DECISION | IMPL_PICK>
options_considered:
  - id: A
    description: <description>
    pros: [...]
    cons: [...]
  - id: B
    description: ...
chosen: A | B | C | ...
chosen_rationale: <why>
approval_chain: <list of confidence sources>
verified_by: <empirical test / smoke / firing-test / human ratification>
affects: [<files / BCs / artifacts>]
depends_on: [D-NNN, D-MMM]
supersedes: [D-NNN]  # optional
superseded_by: [D-NNN]  # optional, when retired
defer_cycles: 0  # count of times this was deferred
re_attempt_prereq: <if rejected, what unlocks reattempt>
tags: [<keywords>]
---
```

### Confidence Thresholds (Self-Decide vs Q&A)

Per `decision-discipline.md`:

| Level | Confidence threshold | Decision path |
|---|---|---|
| CHARTER | 0.99 | Always Q&A bundle + human ratify |
| SCOPE | 0.90 | Q&A bundle if <0.90 |
| ARCH | 0.80 | Self-decide if ≥0.80 |
| IMPL | 0.50 | Self-decide if ≥0.50 |

Confidence comes from `sync-tracker/state.tsv` (per-category Confidence Score). Below threshold → trigger `/grill-me` to build Q&A bundle.

### Defer-Cycle Drift Alert

If `defer_cycles > 3`, R7 mitigation triggers: surfaces as MEDIUM severity in the escalation pipeline.

---

## 4.5 — Karpathy Principles, Visualized

P1, P2, P3, P4 from `karpathy-principles.md` map onto observable agent behaviors. Here is the *agent's flowchart* for any non-trivial task:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  User: "Add X feature"                                      │
│              │                                              │
│              ▼                                              │
│       ┌────────────────────────┐                            │
│       │   P1: Is it ambiguous? │                            │
│       └─────────┬──────────────┘                            │
│            yes  │  no                                       │
│       ┌─────────┴─────────┐                                 │
│       │                   │                                 │
│       ▼                   ▼                                 │
│   ┌────────┐         ┌───────────────────────────┐          │
│   │ ASK    │         │ P4: Frame as verifiable   │          │
│   │ user   │         │ success criteria          │          │
│   │ (mega- │         └──────────┬────────────────┘          │
│   │ bundle)│                    │                           │
│   └────────┘                    ▼                           │
│       │             ┌───────────────────────┐               │
│       │             │ P2: Minimum solution? │               │
│       │             └──────┬────────────────┘               │
│       │                    │                                │
│       │                    ▼                                │
│       │            ┌───────────────────────┐                │
│       │            │ P3: Surgical changes  │                │
│       │            │ only?                 │                │
│       │            └──────┬────────────────┘                │
│       │                   │                                 │
│       │                   ▼                                 │
│       │            ┌───────────────────────┐                │
│       │            │ Execute → verify →    │                │
│       │            │ report                │                │
│       │            └───────────────────────┘                │
│       │                                                     │
│       ▼                                                     │
│   (user answers)                                            │
│       │                                                     │
│       └──── go to P4 with answers                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

This flowchart is the operational expression of `karpathy-principles.md`.

---

## 4.6 — Amendment Process

The constitution changes through this protocol:

```
1. PROPOSAL
   Agent identifies a gap or improvement.
   Writes proposal to agent-workspace/proposals/<slug>.md.
   Proposal cites: source evidence, options considered, chosen pick, rationale.
   Status: PROPOSED.

2. COOL-DOWN
   48 hours minimum before any ratification.
   Allows the proposal to be re-read with fresh context.
   `proposal-bundle-advisor.sh` SessionStart hook surfaces ready-to-ratify proposals.

3. RATIFICATION
   User issues explicit approval via AskUserQuestion bundle.
   Agent records ratification in:
     - The proposal's status field (PROPOSED → ACCEPTED)
     - A new ADR in agent-workspace/memory/decisions/NNN-*.md
     - The relevant CHANGELOG row in the proposal

4. MV-TO-CONSTITUTION
   Once ACCEPTED, agent issues a one-time deny-lift:
     - Either: bundle the mv with an existing approved Edit operation
     - Or: temporary deny-lift via .claude/settings.json (then restored)
   The file moves from proposals/ to constitution/.

5. CROSS-REFERENCE UPDATE
   All callers of the old proposal-path are updated to reference the new
   constitution-path. Searches: grep -r "proposals/<slug>" entire repo.
```

Charter revisions specifically (not constitution files) follow `PROJECT_CHARTER.md § Revision Protocol`:

- Written rationale with evidence (linked to specific sessions / post-mortems)
- 48-hour cool-down before committing change
- Explicit version bump (v1.0 → v2.0)

---

## 4.7 — Where to Read Next

If you want to:

- **See the layered hook engine** that enforces constitution rules → [Chapter 6 — Hooks](06-hooks.md)
- **Understand how sessions ratify decisions** → [Chapter 8 — Lifecycle](08-lifecycle.md)
- **Run drift checks** that catch constitution violations → [Chapter 9 — Quality System](09-quality-system.md)
- **Propose a new constitution rule** → [Chapter 14 — Contributing](14-contributing.md#proposing-a-rule)
- **See the full ADR list** → [Reference § ADRs](../reference/inventory-decisions.md)
