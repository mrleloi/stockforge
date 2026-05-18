# Chapter 5 — Skills, Commands, and Subagents

> **Diataxis quadrant**: Reference + Explanation + How-to
> **Reading time**: ~45 minutes
> **Prerequisites**: Chapter 3 (Architecture) for layer context

This chapter covers the three user-facing extension surfaces of the harness:

- **Skills** — auto-discoverable patterns Claude invokes when context matches.
- **Commands** — user-typed slash invocations.
- **Subagents** — fresh-context worker personas you dispatch.

All three live under `.claude/` and follow consistent file conventions. They differ in how they are activated and what they own.

---

## 5.1 — How They Differ

| Property | Skill | Command | Subagent |
|---|---|---|---|
| **Trigger** | Auto-discovered by context match | User types `/<name>` | `Agent` tool dispatch (manual or programmatic) |
| **Context** | Inherits current session | Inherits current session | Fresh context — does NOT see parent session |
| **File location** | `.claude/skills/<name>/SKILL.md` | `.claude/commands/<name>.md` | `.claude/agents/<name>.md` |
| **Body content** | Reusable procedure | Thin wrapper over skill or agent | Persona definition + responsibility + I/O contract |
| **Owns what** | A *pattern* (what to do when X) | A *shortcut* (do this when I type Y) | A *job* (a persona with a specific responsibility) |
| **LOC ceiling** | ≤120 (D1) | ≤96 (D1) | ≤160 (D1) |
| **Tool grants** | `allowed-tools` frontmatter | Inherits all | `tools:` frontmatter (minimal-grant) |
| **Returns to caller** | N/A (inline procedure) | N/A (inline procedure) | One observation file + final message |

### When to Use Which

**Use a Skill** when:
- The same procedure appears in 3+ sessions
- It is LLM-mediated (not deterministic enough for a hook)
- It should auto-trigger when context matches (not user-typed)

**Use a Command** when:
- The user wants a typed shortcut
- The work is a thin wrapper over an existing skill or subagent
- The body is mostly user-facing (welcome message, brief schema)

**Use a Subagent** when:
- The work requires **fresh context** (e.g., adversarial review)
- The persona is distinct (architect vs verifier — different mindsets)
- The output is structured and traceable (one observation per dispatch)

### The Anti-Duplication Rule (L-S14-2)

A skill named `foo` and a command named `/foo` should not duplicate procedure. Pick one: either the skill body is canonical and the command body just invokes it, or vice versa. Duplication creates two truths that diverge.

---

## 5.2 — Skills

Skills live at `.claude/skills/<name>/SKILL.md`. They are auto-discovered by Claude Code: when the user's context matches the `description` frontmatter, the skill becomes available.

### Skill Anatomy

```
.claude/skills/<name>/
├── SKILL.md          # required (≤120 LOC first-draft per L-S14-1)
├── examples/         # optional concrete examples
└── references/       # optional companion docs (no LOC ceiling)
```

### `SKILL.md` Frontmatter

```yaml
---
name: <kebab-case-name>
description: <one-line summary used for discovery match>
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]  # minimal grant
---
```

The `description` is *the discovery surface*. A vague description means the skill never auto-fires. Write it leading with the core action and including domain keywords the user might mention.

**Bad description**: "Helps with data extraction."

**Good description**: "Extract structured claims from VN news articles with citation integrity. Use when ingesting CafeF / NDH / VietnamBiz content; enforces I-S1 no-LLM-math + I-S2 source+as_of date."

### SKILL.md Body Sections

Every skill should include:

1. **Purpose** — one paragraph of what the skill does
2. **When to use** — concrete triggers
3. **When NOT to use** — concrete non-triggers
4. **Process / Content** — the procedure itself
5. **Anti-patterns** — 3+ concrete bad examples
6. **Related** — links to other skills

### Progressive Disclosure (L-S14-1)

First-draft target: **20% under the ceiling** (skill ≤120 LOC, reserve 20-40 LOC for amendments). A skill drafted AT the ceiling violates D1 within 2-3 amendments.

When content grows: extract topical sub-sections to `references/<topic>.md` (no D1 ceiling) and replace inline content with a one-line pointer.

### The 23 Skills Catalog

The three skill families:

#### Family A — Stockforge Business Logic (7 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`crawler-reliability`](../../../.claude/skills/crawler-reliability/SKILL.md) | Build reliable scrapers (CafeF/NDH/YouTube/FB) | Implementing scraper, retry logic |
| [`ddd-tactical-patterns`](../../../.claude/skills/ddd-tactical-patterns/SKILL.md) | Apply DDD aggregate/VO/repo in Python dataclasses | New aggregate, repo Protocol, domain event |
| [`evidence-extraction`](../../../.claude/skills/evidence-extraction/SKILL.md) | Structured claim extraction with citation integrity | Building extractor pipelines |
| [`fastapi-module`](../../../.claude/skills/fastapi-module/SKILL.md) | FastAPI router conventions (Phase 2+) | New HTTP endpoint, router wiring |
| [`obsidian-vault`](../../../.claude/skills/obsidian-vault/SKILL.md) | Manage Obsidian wiki (entities/concepts/sources) | Adding KB note, ingesting source |
| [`postgres-pgvector`](../../../.claude/skills/postgres-pgvector/SKILL.md) | Schema design with pgvector + TimescaleDB | New migration, schema design |
| [`prompt-engineering`](../../../.claude/skills/prompt-engineering/SKILL.md) | LLM prompt design with no-LLM-math discipline | Authoring new extractor/analysis prompt |

#### Family B — Harness Self-Loop (10 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`decompose-work`](../../../.claude/skills/decompose-work/SKILL.md) | Split task into deterministic vs LLM portions | Multi-part task ≥3 sub-parts |
| [`empirical-probe-first`](../../../.claude/skills/empirical-probe-first/SKILL.md) | Probe ALL strategies in multi-option ladder | Plan lists ≥3 strategies for one problem |
| [`grill-maximization`](../../../.claude/skills/grill-maximization/SKILL.md) | Bundle 15-20 Q&A questions per human touchpoint | Confidence below threshold |
| [`hook-diagnostics`](../../../.claude/skills/hook-diagnostics/SKILL.md) | Inspect hook state machine + transcript cache | Hook stuck active, aggregator row missing |
| [`promote-rule`](../../../.claude/skills/promote-rule/SKILL.md) | Cluster agent-notes → propose promotion | ≥10 new rules since last run |
| [`qa-escalation`](../../../.claude/skills/qa-escalation/SKILL.md) | File-based Q&A bundle protocol | intent-classifier OPEN_QA_BUNDLE |
| [`session-memory-l0-l1`](../../../.claude/skills/session-memory-l0-l1/SKILL.md) | Extract L0 regex + L1 LLM memories from JSONL | Post-SessionEnd ingestion |
| [`sync-pull`](../../../.claude/skills/sync-pull/SKILL.md) | Pre-flight confidence-score lookup | About to commit non-trivial decision |
| [`try-n-approaches`](../../../.claude/skills/try-n-approaches/SKILL.md) | Generate ≥3 approaches + metric function | Open question from drift/dogfood |
| [`user-prompt-intake`](../../../.claude/skills/user-prompt-intake/SKILL.md) | Hybrid intent classifier (lite-detect + subagent) | Any new user prompt landing |

#### Family C — Knowledge-Base (6 skills)

| Skill | Purpose | Trigger |
|---|---|---|
| [`attach`](../../../.claude/skills/attach/SKILL.md) | Port harness layer to a new project dir | New CC project, peer copy |
| [`spec-dual-layer`](../../../.claude/skills/spec-dual-layer/SKILL.md) | Author specs with Part A + Part B | Tier 2/3 spec authoring |
| [`spec-to-wiki`](../../../.claude/skills/spec-to-wiki/SKILL.md) | Convert raw spec to Obsidian wiki | After /spec-author |
| [`test-pyramid-balance`](../../../.claude/skills/test-pyramid-balance/SKILL.md) | Balance unit/integration/E2E tests | New feature test plan |
| [`ubiquitous-language`](../../../.claude/skills/ubiquitous-language/SKILL.md) | DDD glossary extraction + maintenance | New BC, term emerges |
| [`write-a-skill`](../../../.claude/skills/write-a-skill/SKILL.md) | Create new skills with progressive disclosure | Pattern surfaces in 3+ sessions |

### Skill Pruning

Quarterly: any skill not triggered in 3 months — evaluate (still relevant? description need fixing? deprecate?). Every loaded skill costs context tokens.

---

## 5.3 — Commands

Commands live at `.claude/commands/<name>.md`. They are user-typed slash invocations. Most are thin wrappers that delegate to a skill or dispatch a subagent.

### Command Anatomy

```markdown
# /<name> — <One-line purpose>

> Optional aside.

## When to Use
<concrete triggers>

## Input
<optional $ARGUMENTS>

## Steps
1. <numbered>
2. ...

## Output Schema
<what the user sees>

## Anti-Patterns
<3+ concrete bad examples>

## Related
<links>
```

### The 16 Commands Catalog

Note: 16 commands, not 17 — there is no `bdd-planner` command file (only the subagent exists; BDD planning is dispatched manually).

#### Session Lifecycle (5 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/session-start`](../../../.claude/commands/session-start.md) | Load state, identify session type, output brief | (no skill — reading priority in body) |
| [`/session-verify`](../../../.claude/commands/session-verify.md) | Mid-session alignment check | (no skill) |
| [`/session-end`](../../../.claude/commands/session-end.md) | Close session + update memory | (no skill — checklist in body) |
| [`/handoff-read`](../../../.claude/commands/handoff-read.md) | Lightweight session-pickup (vs full /session-start) | (no skill) |
| [`/budget-check`](../../../.claude/commands/budget-check.md) | Report token consumption + projection | (no skill) |

#### Planning + Spec (3 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/master-plan`](../../../.claude/commands/master-plan.md) | Decompose goal into phased sessions | `master-planner` subagent |
| [`/spec-author`](../../../.claude/commands/spec-author.md) | Create dual-layer spec | `spec-author` subagent |
| [`/spec-to-wiki`](../../../.claude/commands/spec-to-wiki.md) | Convert raw spec to Obsidian wiki | `spec-to-wiki` skill |

#### Adversarial + Quality (6 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/devils-advocate`](../../../.claude/commands/devils-advocate.md) | Adversarial critique of plan/spec/code/thesis | `devils-advocate` subagent |
| [`/drift-check`](../../../.claude/commands/drift-check.md) | Run drift signals DR1-DR12 | `drift-signals-D1-D9.sh` + `drift-detector` for DR7/DR12 |
| [`/drill-me`](../../../.claude/commands/drill-me.md) | Interactive DDD UL extraction | `ubiquitous-language` skill |
| [`/grill-me`](../../../.claude/commands/grill-me.md) | Relentless plan/design interview | `grill-maximization` skill |
| [`/ul-audit`](../../../.claude/commands/ul-audit.md) | Audit UL consistency (code vs glossary) | `ul-auditor` subagent + grep checks |
| [`/vbw-check`](../../../.claude/commands/vbw-check.md) | Apply VBW protocol for current task | `vbw-protocol.md` constitution |

#### Infrastructure Toggles (2 commands)

| Command | Purpose | Invokes |
|---|---|---|
| [`/autonomous`](../../../.claude/commands/autonomous.md) | Toggle autonomous mode on/off/status | (atomic file ops) |
| [`/block`](../../../.claude/commands/block.md) | Human-gate control (status/clear/raise) | `block-control.sh` |

### Common Command Body Sections

Every command should have:

- **When to Use** — concrete trigger conditions
- **Input** — what `$ARGUMENTS` (or stdin) the command takes
- **Steps** — numbered procedure
- **Brief Schema / Output Schema** — what the user sees
- **Error Handling** — how it fails gracefully
- **Anti-Patterns** — concrete bad examples
- **Related** — other commands / skills

### Why Commands Are Thin

A command should mostly *route* — to a skill, to a subagent, to a script. The body of the command file is primarily **user-facing prose**: when to invoke, what the user can expect, edge cases.

The actual work — the procedure that achieves the goal — lives in a skill (for reusable procedures) or a subagent (for fresh-context tasks).

---

## 5.4 — Subagents

Subagents live at `.claude/agents/<name>.md`. They are *personas* with distinct responsibilities, dispatched via the `Agent` tool. Each runs in **fresh context** — the subagent does not inherit the parent session's transcript.

### Subagent Anatomy

```markdown
---
name: <kebab-case-name>
description: <one-line summary; matched against task at dispatch time>
model: opus | sonnet | haiku
tools: [Read, Glob, Grep, Write, Edit, Bash]  # minimal grant
---

# Subagent: <Title>

## Persona
<who this agent is>

## Responsibility
<what they own>

## Input
<what dispatch must provide>

## Process
### Phase 1: Comprehend
### Phase 2: ...

## Output Contract
<structured return format>

## Anti-Patterns
<what this agent must NOT do>
```

### Fresh Context

This is the key property. When you dispatch a subagent, it starts with:

- The system prompt + persona definition (this file)
- The prompt you give it
- The tools you grant
- **Nothing else from your conversation**

This makes them ideal for:
- **Adversarial review** — verifier cannot rationalize architect's reasoning if it never saw it
- **Parallel work** — multiple subagents on independent tasks, no shared state
- **Context isolation** — heavy reads don't pollute the parent session

### The 14 Subagents Catalog

All 14 agents declare `model: opus` (per user 2026-05-17 directive "full opus + follow budget").

#### Planner Personas (5 agents)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`action-guide-planner`](../../../.claude/agents/action-guide-planner.md) | Pragmatic lead dev — turn brief into next actions | Read, Glob, Grep | Manual / session-start follow-up |
| [`bdd-planner`](../../../.claude/agents/bdd-planner.md) | Senior QA — test pyramid balance | Read, Glob, Grep, Write | Manual (post `/spec-author`) |
| [`master-planner`](../../../.claude/agents/master-planner.md) | Senior tech lead — decompose goal into sessions | Read, Glob, Grep, Write | `/master-plan` |
| [`sandwich-architect`](../../../.claude/agents/sandwich-architect.md) | Senior architect — plans IMPL sessions | Read, Glob, Grep, Write | PLAN session type |
| [`spec-author`](../../../.claude/agents/spec-author.md) | BA + DDD designer — dual-layer spec | Read, Glob, Grep, Write | `/spec-author` |

#### Executor Persona (1 agent)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`sandwich-dev`](../../../.claude/agents/sandwich-dev.md) | Focused implementer — executes architect's plan | Read, Glob, Grep, Write, Edit, Bash | FOCUSED_IMPL / MULTI_TASK_IMPL |

#### Auditor / Fresh-Eyes Personas (8 agents)

| Agent | Persona | Tools | When Dispatched |
|---|---|---|---|
| [`devils-advocate`](../../../.claude/agents/devils-advocate.md) | Experienced skeptic | Read, Glob, Grep | `/devils-advocate` |
| [`drift-detector`](../../../.claude/agents/drift-detector.md) | Structural integrity inspector | Read, Glob, Grep, Bash | `/drift-check` (for DR7/DR12) |
| [`intent-classifier`](../../../.claude/agents/intent-classifier.md) | Cool-headed triage | Read, Glob, Grep | `user-prompt-intake` skill |
| [`intent-vs-impl-diff`](../../../.claude/agents/intent-vs-impl-diff.md) | Adversarial cross-checker (intent vs impl) | Read, Glob, Grep, Bash, Write | On-demand / phase-boundary |
| [`lesson-synthesizer`](../../../.claude/agents/lesson-synthesizer.md) | Pattern miner — Stage 2 self-upgrade | Read, Glob, Grep, Bash, Write, Edit | `lesson-synthesis-watchdog` ALERT |
| [`research-scanner`](../../../.claude/agents/research-scanner.md) | Repo cartographer — opensource fit | Read, Glob, Grep, WebFetch | Manual (research dogfood) |
| [`sandwich-verifier`](../../../.claude/agents/sandwich-verifier.md) | Skeptical fresh-context reviewer | Read, Glob, Grep, Bash | VERIFY session type |
| [`ul-auditor`](../../../.claude/agents/ul-auditor.md) | Detail-obsessed DDD — synonym / drift detection | Read, Glob, Grep, Bash | `/ul-audit` |

### The Sandwich Verifier No-Write Override

[`sandwich-verifier.md`](../../../.claude/agents/sandwich-verifier.md) intentionally lacks `Write` in its tools grant. This is per **PCG-S401-4** — a 3-incident cluster (S397/S400/S401) where dispatch briefs asked the agent to Write findings, but the persona forbids it. The pattern now codified:

- Verifier returns findings **inline as text** in its final message.
- Main session reads the verifier's text and persists to disk under main's authorship.
- This keeps verifier's role purely advisory and preserves traceability.

### Cost of Dispatch

Each subagent dispatch:

- Spawns fresh context (~1-3K bootstrap)
- Reads its persona file (~1-2K)
- Reads the relevant inputs (varies)
- Costs Anthropic API tokens at the agent's model rate
- Logged in `agent-workspace/memory/dispatch.jsonl`
- USD cost logged in `agent-workspace/memory/cost-ledger.tsv`

For PLAN (Opus): typically 150-230K tokens; ~$2-4 USD per dispatch.
For VERIFY (Opus): typically 80-180K tokens; ~$1-2 USD per dispatch.
For lesson-synthesizer (Opus): typically 60-100K tokens.

---

## 5.5 — The Five Canonical Pipelines

Skills, commands, and subagents compose into recognizable pipelines. The harness has five canonical patterns:

### Pipeline 1 — Sandwich Workflow (the load-bearing one)

```
/session-start
   ↓ (no plan exists yet)
/master-plan <goal>
   ↓ dispatches master-planner
   ↓ writes session-plans/pending/NNN-S<sid>-<slug>.md
next session loads plan
   ↓ session type detected as PLAN
sandwich-architect dispatched
   ↓ reads plan + constitution + relevant code
   ↓ writes detailed sub-plan (D1..DN tasks)
next session loads sub-plan
   ↓ session type detected as FOCUSED_IMPL / MULTI_TASK_IMPL
sandwich-dev dispatched
   ↓ implements D1..DN
   ↓ runs mypy/pytest/ruff
   ↓ writes session log with verification
next session loads dev observation
   ↓ session type detected as VERIFY
sandwich-verifier dispatched
   ↓ fresh-context review
   ↓ returns verdict (PASS / PASS-WITH-CONCERNS / FAIL) inline
main session persists verifier's findings to attestation-log.tsv
/session-end
```

### Pipeline 2 — Knowledge-Base

```
/drill-me
   ↓ interactive UL extraction
   ↓ uses ubiquitous-language skill
   ↓ updates agent-workspace/ubiquitous-language/glossary.md
/spec-author <feature>
   ↓ dispatches spec-author subagent
   ↓ writes specs/tier2-feature/NNN-*.md
/spec-to-wiki <spec-path>
   ↓ uses spec-to-wiki skill
   ↓ writes obsidian-vault/wiki/specs/...md
/ul-audit
   ↓ dispatches ul-auditor subagent
   ↓ checks code vs glossary
   ↓ writes drift report
```

### Pipeline 3 — Self-Upgrade Loop (Karpathy autoresearch)

```
Drift surfaces signal (DR1-DR12 hook fires)
   ↓
try-n-approaches skill
   ↓ frames experiment (≥3 approaches: DEEPEN / BROADEN / ABANDON)
   ↓ writes framing artifact to learning-data/loop/
   ↓ defines metric function (BLOCKING per L-S12-1)
executes approaches
   ↓ outcomes accumulate in agent-notes.md
promote-rule skill
   ↓ clusters via Jaccard similarity
   ↓ writes observations/promotion-proposals-<TS>.md
   ↓ proposes promotion: inline → skill → hook → constitution
lesson-synthesizer agent
   ↓ when lesson-synthesis-watchdog ALERTs
   ↓ fills KI / BP entries with session-diff evidence
   ↓ assigns L-S{NN}-N ID
```

Parallel: `decompose-work` decides det-vs-LLM split for every step; `empirical-probe-first` rejects stale-evidence recommendations BEFORE commit.

### Pipeline 4 — Calibration / Q&A

```
User submits prompt
   ↓
user-prompt-intake skill (lite-detect)
   ↓ trivial whitelist (incl. Vietnamese)
   ↓ non-trivial → dispatch intent-classifier
intent-classifier subagent
   ↓ YAML verdict: primary_intent / recommended_action / suggested_grill_questions
if recommended_action == "OPEN_QA_BUNDLE":
   sync-pull skill
   ↓ reads sync-tracker/state.tsv + weights.yaml
   ↓ emits SELF-DECIDE-OK / GRILL / FORCE-GRILL
if GRILL:
   grill-maximization skill
   ↓ bundles 15-20 Qs per touchpoint
   ↓ writes to human-workspace/q-and-a/pending/<bundle>.md
   ↓ AskUserQuestion (≤4 per call; the BINDING surface)
qa-escalation skill
   ↓ pending → answered → stale lifecycle
   ↓ auto-mv hook moves resolved bundles
```

### Pipeline 5 — Quality Gates

```
Per-commit (Tier 1 deterministic):
   - mypy --strict
   - pytest
   - ruff
   - drift-signals-D1-D9.sh
   - dependency cycle check
Per-merge (Tier 2 probabilistic):
   - /vbw-check (VBW protocol)
   - /drift-check (semantic DR7/DR12 via drift-detector)
   - /devils-advocate (pre-merge adversarial review)
   - intent-vs-impl-diff at phase boundary
Per-phase (Tier 3 human):
   - Architectural decisions (CHARTER-tier ratify)
   - API contracts (SCOPE-tier ratify)
   - Eval regression sign-off
   - Thesis quality review
```

---

## 5.6 — Sandwich Architect Mechanics

Because the sandwich pattern is load-bearing, the architect persona deserves a closer look. The [`sandwich-architect.md`](../../../.claude/agents/sandwich-architect.md) file (~600 LOC) defines a 5-phase process:

### Phase 1: Comprehend

Read:
- Target spec completely (Part A + B)
- Relevant constitution files (architecture, invariants)
- Existing code in affected bounded contexts
- Related ADRs or notes

Apply VBW Protocol — verify source against memory.

### Phase 1b: Self-Calibration (mandatory if ≥3 sub-tracks)

Read (cap last 30 rows each per DD-2):
- `agent-workspace/memory/.planner-stats.tsv`
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv`
- `agent-workspace/memory/dispatch.jsonl`
- `agent-workspace/memory/mistake-log.md`

Extract for current task_class similarity:
- Average duration_ms + outcome distribution + failure_mode frequency
- For model+effort similar to current dispatch context: tokens_real vs estimated
- For coordination-rule pattern: any file-collision incidents recorded

Use to:
- Set REALISTIC budget per sub-track (not boilerplate)
- Flag sub-tracks with high failure-mode frequency
- Identify safe parallelization opportunities

Cold-start: if sample_size < 3 for current task_class, gracefully degrades to default budget; flag as "cold-start". Do NOT block plan authoring.

### Phase 2: Architecture Decisions

For this implementation:
- Which bounded context owns this?
- What aggregates affected?
- New entities/value objects needed?
- Database changes?
- API changes?
- Events to publish/subscribe?

Document decisions explicitly.

### STEP 2.X — Dispatch-Brief Path Verification (L-S392-1)

For EVERY file path mention in dispatch brief:
1. Run Glob or Read to verify path exists
2. If path does NOT exist: do NOT cite that path; grep the actual correct path from mistake-log / observation evidence
3. Cite parent plan/spec verbatim with file:line reference
4. If brief contains paraphrased text deviating from primary source, USE primary source + document deviation

Anti-example: S392 dispatch brief cited `packages/_shared/pdf/pdf_table_extractor_port.py` (does not exist); architect VBW found canonical at `packages/application/fundamental/pdf_table_extractor_port.py`.

### STEP 2.Y — Operational-Track Full-Pipeline Cold-Probe (L-S395-1)

When authoring OPERATIONAL plans (data ingestion / cost-bearing pipeline / multi-ticker batch), STEP 0 MUST include a FULL-pipeline cold-probe (NOT just wire-probe) BEFORE bulk operational work commits resources:

1. Single-ticker dry-run of the entire pipeline end-to-end
2. Assert cost ≤ BR-N cap (cite specific BR rule by ID + current cap value)
3. Assert quality threshold (e.g. ≥N articles per ticker for sentiment; ≥N statements per ticker for fundamentals)
4. Surface any architectural blocker AT PLAN time, not at IMPL time
5. If cold-probe surfaces blocker: STOP-AND-ASK via STOP-FINDING in human-workspace/notifications/

### Phase Closure Attestation Vocabulary (L-S385-2)

Plans MUST use one of:
- **DONE**: code + data substrates both ready
- **CODE-DONE-DATA-PENDING**: code ready; data pending; gate marked CODE-READY-DATA-PENDING
- **DATA-DONE-CODE-PENDING**: rare; data ready but code not wired
- **PENDING**: neither ready
- **BLOCKED-BY-\<X\>**: explicit blocker

Flat "DONE" attestation when data is PENDING = anti-pattern.

### Phase 3: File-Level Planning

List every file that will be created or modified, with:
- Purpose
- Size estimate (LOC)
- Methods/functions
- Dependencies

### Phase 4: Risk Mitigations (RM1..RMN)

For each identifiable risk, write an RM entry naming the prevention measure.

### Phase 5: DoD Per Sub-Track

Each sub-track has its own DoD (Definition of Done) with per-category LOC ceilings and verification criteria.

---

## 5.7 — Common Anti-Patterns

| Anti-pattern | What goes wrong | Fix |
|---|---|---|
| Vague skill description | Won't trigger reliably | Lead with core action; include domain keywords |
| Skill drafted AT D1 ceiling | Violates D1 after first amendment | 20% under ceiling (L-S14-1) |
| Code dumps in SKILL.md | Bloats Tier 1 budget | Push to `examples/` or `references/` |
| Duplicate `<name>` skill and `/<name>` command | Two truths diverge (L-S14-2) | Pick one canonical; the other invokes |
| Subagent dispatched without fresh-context need | Wastes ~5-10K bootstrap tokens | Use a skill if context can be inherited |
| Verifier asked to Write findings | Violates persona; persistence breaks | Main session persists from inline text |
| Architect re-plans during dev session | Mixes PLAN + IMPL | Separate sessions; never mix |
| Sandwich-dev re-architects | Drifts from plan | Dev executes plan only; flags issues, doesn't fix architecturally |
| Master plan written without VBW | Cites paths that don't exist | STEP 2.X path verification |
| Architect cold-probes wire only | Misses operational blockers | STEP 2.Y full-pipeline cold-probe |
| Plan marks "DONE" when data pending | Misleading state | Use vocabulary: CODE-DONE-DATA-PENDING |

---

## 5.8 — Where to Read Next

- **The deterministic enforcement** of these rules → [Chapter 6 — Hooks](06-hooks.md)
- **How to build your own** skill / command / subagent → [Chapter 11 — Cookbook](11-cookbook.md)
- **Full inventory** with every artifact → [Reference § Skills](../reference/inventory-skills.md)
- **How the personas interact across sessions** → [Chapter 8 — Lifecycle](08-lifecycle.md)
