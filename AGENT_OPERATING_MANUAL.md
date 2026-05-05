# AGENT OPERATING MANUAL
## AI-First Development Workflow for StockForge

> **Status**: Living document v1.0
> **Owner**: Project lead (human)
> **Update cadence**: After each phase boundary, after significant learning, after post-mortem
> **Primary audience**: Me, and the AI agents working on this project

---

## Table of Contents

1. [Mental Model](#1-mental-model)
2. [Workspace Architecture](#2-workspace-architecture)
3. [Obsidian Integration](#3-obsidian-integration)
4. [Constitution (Immutable Rules)](#4-constitution)
5. [Skills Catalog](#5-skills-catalog)
6. [Slash Commands](#6-slash-commands)
7. [Subagents](#7-subagents)
8. [Hooks](#8-hooks)
9. [Memory System](#9-memory-system)
10. [Session Protocols](#10-session-protocols)
11. [Quality Gates](#11-quality-gates)
12. [Adopted Skills from Community](#12-adopted-skills)
13. [Development Workflow](#13-development-workflow)
14. [Escalation Protocols](#14-escalation-protocols)
15. [Anti-Patterns](#15-anti-patterns)

---

## 1. Mental Model

### 1.1 Core Abstraction

In this project, I am a **director and architect**. Claude Code is my **engineering team**. The work decomposes as:

- I write: specs, charter, learned rules, strategic direction
- Claude Code writes: code, tests, documentation, routine specs
- Claude Code + I together: bounded context design, critical architectural decisions

### 1.2 The Four Karpathy Principles (adopted from forrestchang/andrej-karpathy-skills)

These principles apply to every Claude Code session:

**P1. Think Before Coding** — State assumptions explicitly. Don't pick silently when ambiguity exists. Push back when a simpler approach exists. Stop when confused and ask.

**P2. Simplicity First** — Minimum code that solves the problem. No speculative features. No abstractions for single-use code. If 200 lines could be 50, rewrite it. Test: would a senior engineer say this is overcomplicated?

**P3. Surgical Changes** — Touch only what the task requires. Don't "improve" adjacent code. Match existing style even if I'd do it differently. Every changed line traces directly to the task. If I notice unrelated dead code, mention — don't delete.

**P4. Goal-Driven Execution** — Transform imperative tasks into verifiable goals. "Add validation" becomes "write tests for invalid inputs, then make them pass." Strong success criteria let the agent loop independently.

These four are loaded into CLAUDE.md and referenced throughout skills.

### 1.3 The Sandwich Pattern (adopted from Phase2 workflow)

Single-agent "plan + implement + verify" is proven to fail at 20% rate past ~200K tokens (Session 4 case). Adopted pattern:

```
ARCHITECT session (50-80K tokens)
  → plans, produces session-handoff.md
      ↓
DEV session (100-250K tokens)
  → implements per plan, never re-plans
      ↓
VERIFIER session (30-60K tokens)
  → adversarial review, separate context
```

This is how we build. Separate from what we build. Product pipeline may be single-agent initially; workflow is sandwich from Day 1.

### 1.4 Verify-Before-Write (VBW) Protocol

Measured hallucination rate in prior projects: 11.1% — agent wrote code from memory/convention instead of verified source. After VBW adoption: 0%.

Protocol enforced in constitution. Applied at pre-spec, pre-test, pre-code checkpoints. See [§4 Constitution](#4-constitution).

---

## 2. Workspace Architecture

### 2.1 Top-Level Directory Structure

```
stockforge/                                # Project root
├── .claude/                               # Claude Code convention folder
│   ├── CLAUDE.md                          # Always-loaded project context
│   ├── settings.json                      # Claude Code config
│   ├── commands/                          # Slash commands
│   ├── skills/                            # Agent skills (auto-discovered)
│   ├── agents/                            # Subagent definitions
│   └── hooks/                             # Pre/post tool hooks
│
├── agent-workspace/                       # Custom workspace (ours, not Claude Code's)
│   ├── constitution/                      # Immutable rules (loaded into CLAUDE.md)
│   │   ├── karpathy-principles.md         # Four P principles
│   │   ├── architecture.md                # Layer boundaries, 9 BC rules
│   │   ├── invariants.md                  # Things that must never break (I-S* stock-specific)
│   │   ├── boundaries.md                  # What agent cannot do without approval
│   │   ├── vbw-protocol.md                # Verify-Before-Write checkpoints
│   │   ├── drift-signals.md               # DR1-DR12 numbered signals
│   │   ├── session-budgets.md             # Token budget rules
│   │   └── financial-data-protocol.md    # Stock-specific data integrity rules
│   │
│   ├── memory/                            # Persistent memory (MIL pattern)
│   │   ├── project.md                     # Project state (auto-loaded each session)
│   │   ├── current-execution.md           # Routing source of truth
│   │   ├── agent-notes.md                 # Learned rules (post-mortem insights)
│   │   ├── sessions/                      # Session logs (YYYY-MM-DD-N.md)
│   │   ├── thesis-log/                    # All thesis ever recorded (append-only)
│   │   ├── post-mortems/                  # Thesis outcome reviews (append-only)
│   │   ├── patterns-discovered/           # Patterns that worked well
│   │   └── drift-logs/                    # Detected drift over time
│   │
│   ├── ubiquitous-language/               # DDD ubiquitous language (first-class)
│   │   ├── glossary.md                    # Canonical terms per bounded context
│   │   ├── domain-mapping.md              # Term → code location mapping
│   │   └── drift-log.md                   # UL drift tracking
│   │
│   ├── session-plans/                     # Pre-planned session briefs
│   │   ├── pending/
│   │   └── completed/
│   │
│   ├── calibration/                       # KOL accuracy, signal calibration data
│   │
│   └── quality-reports/                   # Gate outputs
│       ├── deterministic/
│       ├── probabilistic/
│       └── drift-reports/
│
├── obsidian-vault/                        # Obsidian vault (see §3)
│   ├── raw/                               # IMMUTABLE source materials
│   │   ├── research-sources/              # Web articles, PDFs, books
│   │   ├── conversations/                 # Raw transcripts, meeting notes
│   │   └── evidence/                      # Scraped data snapshots
│   │
│   ├── wiki/                              # AGENT-OWNED knowledge base
│   │   ├── _index.md                      # Content catalog
│   │   ├── _log.md                        # Append-only ingest log
│   │   ├── specs/                         # Spec documents (wiki format)
│   │   │   ├── tier1-strategic/
│   │   │   ├── tier2-feature/
│   │   │   └── tier3-task/
│   │   ├── patterns/                      # Business patterns library
│   │   ├── entities/                      # Companies, KOLs, markets
│   │   ├── concepts/                      # Frameworks, ideas
│   │   ├── playbooks/                     # Domain expert playbooks
│   │   └── synthesis/                     # Cross-source analyses
│   │
│   ├── CLAUDE.md                          # Vault-specific schema & conventions
│   └── .obsidian/                         # Obsidian config
│
├── specs/                                 # Living specs (source format)
│   ├── tier1-strategic/
│   ├── tier2-feature/
│   └── tier3-task/
│
├── bdd/                                   # BDD test catalog
│   ├── pyramid-index.md
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── packages/                              # Monorepo packages
│   ├── domain/                            # Pure Python domain (no framework, no Pydantic)
│   │   ├── market_data/                   # BC-1
│   │   ├── fundamental/                   # BC-2
│   │   ├── company_intelligence/          # BC-3
│   │   ├── macro/                         # BC-4
│   │   ├── news/                          # BC-5
│   │   ├── influence/                     # BC-6
│   │   ├── crowd/                         # BC-7
│   │   ├── analysis/                      # BC-8
│   │   └── portfolio/                     # BC-9
│   ├── application/                       # Use cases, ports (Protocol classes)
│   ├── infrastructure/                    # Adapters (DB, Redis, R2, scrapers, LLMs)
│   └── contracts/                         # Shared schemas + events for cross-BC
│
├── apps/                                  # Deployable applications
│   ├── dashboard/                         # Streamlit personal dashboard (Phase 1-2)
│   ├── api/                               # FastAPI gateway (Phase 2+)
│   └── workers/                           # Dramatiq/Prefect background workers
│
├── tests/                                 # Top-level tests
│   └── backtest/                          # Historical replay tests
│
├── eval-sets/                             # Ground truth for quality
│   ├── thesis-labeled/
│   └── baseline-results/
│
└── [standard project files: pyproject.toml, README.md, etc.]
```

### 2.2 Folder Responsibility Matrix

| Folder | Owner | Edit Permission | Typical Contents |
|---|---|---|---|
| `.claude/CLAUDE.md` | Human + curated | Careful edit | Project context always loaded |
| `.claude/commands/` | Human | Human edits, agent reads | Slash commands |
| `.claude/skills/` | Mixed | Human creates, agent uses | Reusable how-to knowledge |
| `.claude/agents/` | Human | Human edits | Subagent persona definitions |
| `agent-workspace/constitution/` | Human | Careful edit | Immutable rules |
| `agent-workspace/memory/project.md` | Agent writes, human reviews | Automated updates | Current state |
| `agent-workspace/memory/agent-notes.md` | Human + agent | Append-mostly | Learned rules |
| `agent-workspace/memory/sessions/` | Agent writes | Append-only | Session logs |
| `agent-workspace/memory/thesis-log/` | Agent writes | Append-only | All theses recorded |
| `agent-workspace/calibration/` | Agent writes | Append + update | KOL accuracy, signal data |
| `agent-workspace/ubiquitous-language/` | Human + agent (via /drill-me) | Curated | DDD language |
| `obsidian-vault/raw/` | Human only | **IMMUTABLE to agent** | Source materials |
| `obsidian-vault/wiki/` | Agent primary | Agent writes, human reviews | Knowledge base |
| `specs/` | Mixed | Both can edit with protocol | Living specs |
| `packages/`, `apps/` | Agent primary | Agent writes, human reviews | Code |

**Critical rule**: `obsidian-vault/raw/` is immutable to agent. Same with `PROJECT_CHARTER.md`. Changes require explicit human edit.

---

## 3. Obsidian Integration

### 3.1 The Raw/Wiki Pattern (adapted from Karpathy LLM Wiki)

Inspired by Karpathy's LLM Wiki gist and formalized in the llm-wiki skill. Core insight: **separate immutable sources from agent-mutable knowledge**.

```
obsidian-vault/
├── raw/                    Layer 1: IMMUTABLE SOURCE TRUTH
│   └── ...                 Agent can READ, cannot WRITE. Ever.
│
├── wiki/                   Layer 2: AGENT-OWNED KNOWLEDGE
│   ├── _index.md          Catalog (agent maintains)
│   ├── _log.md            Append-only ingest log
│   └── ...                Agent reads + writes + links
│
├── CLAUDE.md              Schema & conventions for this vault
└── .obsidian/             Obsidian config
```

### 3.2 Why Obsidian Specifically

- **Bidirectional links** (`[[entity]]`) create knowledge graph naturally
- **Wikilinks in markdown** human and agent both read/write
- **Tags + frontmatter** queryable
- **Graph view** for humans to navigate
- **No vendor lock-in** — it's just markdown files
- **Local-first** — works offline, git-friendly

### 3.3 Integration Approach (phased)

**Phase 1 — Level 1: Convention-only**
- Agent treats vault as plain directory
- Uses Read/Write tools on markdown files
- Follows vault CLAUDE.md conventions
- No special Obsidian features required

**Phase 2 — Level 2: Skill-based navigation**
- Adopt mattpocock `obsidian-vault` skill
- Agent uses wikilinks `[[entity]]` consistently
- Maintains `_index.md` and `_log.md`
- Understands frontmatter schema

**Phase 3+ — Level 3: API integration (optional)**
- If Level 2 proves insufficient: install Obsidian Local REST API plugin
- Adopt `hancengiz/cc-obsidian-vault-api-skill`
- Agent calls live API endpoints
- Only worth it if vault grows very large

### 3.4 Raw Spec → Wiki Spec Workflow

```
Step 1: Author creates raw spec
  /specs/tier2-feature/001-raw.md    ← Source format, free-form

Step 2: Invoke /spec-to-wiki skill
  Agent reads raw spec
  Agent converts to Obsidian format:
    - Add wikilinks for entities, concepts
    - Add frontmatter (type, status, tier, tags)
    - Create entries in /wiki/entities/ for new mentions
    - Update /wiki/_index.md
    - Append to /wiki/_log.md
  Output: /obsidian-vault/wiki/specs/tier2-feature/001-feature-name.md

Step 3: Human reviews wiki version in Obsidian
  Navigate graph
  Verify linkages
  Approve or request changes

Step 4: On spec change
  Update raw file
  Re-run /spec-to-wiki (diff-based update, preserves existing links)
  Agent reports changes for review
```

Raw file is source of truth for content. Wiki file is navigable view for collaboration. Both versioned in git.

### 3.5 Vault CLAUDE.md (schema definition)

The vault has its own `CLAUDE.md` defining conventions. Key sections:

```markdown
# StockForge Wiki — Agent Instructions

## Core Rule
NEVER write to raw/. NEVER. Period.
All agent writes go to wiki/.
To modify source: ask human to edit raw/, then re-run /wiki-ingest

## Frontmatter Schema
All wiki notes have frontmatter:
- type: source | entity | concept | spec | playbook | synthesis
- status: draft | review | stable | deprecated
- tier: (for specs) 1 | 2 | 3
- ingested: YYYY-MM-DD
- source: (for synthesis) list of source URIs
- tags: [domain, subdomain, ...]

## Linking Rules
- First mention of an entity → create [[entity-name]] link
- Create stub note at wiki/entities/entity-name.md if doesn't exist
- Cross-reference related concepts with [[concept-name]]

## Index Maintenance
After every ingest:
1. Update wiki/_index.md with new notes
2. Append to wiki/_log.md: [YYYY-MM-DD] <op> | <title>

## Lint (periodic)
Check for:
- Orphan pages (no incoming links)
- Stub pages (fewer than 3 lines)
- Stale pages (not touched in 90+ days)
- Concepts mentioned but lacking own page
```

---

## 4. Constitution

These files are always loaded into session context (via CLAUDE.md references). Total target: **~3K tokens**.

### 4.1 karpathy-principles.md (concise version)

```markdown
# Karpathy Principles

## P1: Think Before Coding
State assumptions. Surface tradeoffs. Push back when simpler approach exists.
Stop when confused — name what's unclear, ask.

## P2: Simplicity First
Minimum code that solves the problem. No speculative features.
No abstractions for single-use. If 200 lines could be 50, rewrite it.
Test: would a senior engineer say this is overcomplicated?

## P3: Surgical Changes
Touch only what the task requires. Don't improve adjacent code.
Match existing style. Every changed line traces to the task.
Notice dead code? Mention it, don't delete.

## P4: Goal-Driven Execution
Transform imperative → verifiable goals.
"Add validation" → "write tests for invalid inputs, make them pass"
Strong success criteria let the agent loop independently.

---
Source: forrestchang/andrej-karpathy-skills, MIT license.
Adopted: 2026-04-20
```

### 4.2 architecture.md (concise version)

```markdown
# Architecture Rules

## Layer Separation (mandatory)
- domain/        Pure Python, zero framework, zero IO, stdlib dataclasses only
- application/   Use cases, ports (Protocol classes), orchestration
- infrastructure/ Adapters, IO, external services (Postgres, Redis, R2, scrapers, LLMs)
- interfaces/    HTTP (FastAPI), CLI (Click), dashboard (Streamlit), alert handlers

## Import Rules
- domain imports nothing from application/infrastructure/interfaces
- application imports only from domain
- infrastructure implements application ports
- Cross-bounded-context imports via packages/contracts/ only

## Bounded Contexts (9)
BC-1: Market Data         BC-4: Macro & Policy      BC-7: Crowd Sentiment
BC-2: Fundamental         BC-5: News Stream          BC-8: Analysis & Thesis
BC-3: Company Intel       BC-6: Influence Network    BC-9: Portfolio & Action

## Stack (locked Phase 1-3)
Python 3.11+ | FastAPI (Phase 2+) | Streamlit (Phase 1-2 dashboard)
Postgres 16 + TimescaleDB + pgvector + pg_trgm | Redis | Cloudflare R2
Claude API (Sonnet/Opus) + OpenAI embeddings | uv (package manager)
Dramatiq/Prefect (workers) | Click (CLI) | structlog (logging)

## Event-Driven
Domain events exist from day 1, synchronous in Phase 1, Dramatiq queue in Phase 2+
```

### 4.3 invariants.md

```markdown
# Invariants (never break)

## Data Integrity
- I-1: Every claim has source_url
- I-2: Every extraction has extracted_at timestamp
- I-3: Hallucination is a bug
- I-4: Public output shows verified data only
- I-5: Data freshness visible ("as of [date]")

## Stock-Specific (I-S*) — real money depends on these
- I-S1: No LLM Math — LLM never returns numbers; all via deterministic Python tool calls
- I-S2: Point-in-time integrity — backtest queries filter WHERE filing_date <= as_of_date
- I-S3: Survivorship bias awareness — backtest universe includes delisted stocks
- I-S4: Adjusted vs unadjusted prices always tagged (adjustment_type field)
- I-S5: Source provider attribution (source_provider field on every data point)
- I-S6: Currency always specified (Money value object enforces currency)
- I-S7: Confidence = hit rate, not model feeling (calibration database required)
- I-S10: Thesis must include substantive bear case (≥3 distinct points)
- I-S11: Multi-perspective synthesis required (≥4 perspectives for high-confidence)
- I-S12: Disagreement surfaced, not vote-averaged
- I-S13: Counter-narrative required when community sentiment >80% bullish
- I-S35: All output includes "research aid, not financial advice" disclaimer

## Code Integrity
- I-10: Domain layer has ZERO framework dependency (dataclasses + stdlib only)
- I-11: Cross-BC communication via contracts only
- I-12: No Any type in domain package (mypy --strict enforces)
- I-13: No print() in production code (use structlog)

## Process Integrity
- Spec before code. VBW protocol mandatory. Session handoff always written.
- Constitution never modified by agent. Eval set regression blocks merge.
- mypy --strict, pytest, ruff must pass before commit.
```

### 4.4 vbw-protocol.md

```markdown
# Verify-Before-Write Protocol

Measured baseline: 11.1% hallucination when agent writes from memory.
After VBW: 0% (Phase2 MDP project data).

## Checkpoint 1: PRE-SPEC
Before writing any spec:
□ READ actual source code — not from memory
□ LIST all methods of entity — from code, not assumption
□ VERIFY method signatures — exact params from reading source
□ CHECK feature existence — grep before assuming "missing"
□ MARK items as CURRENT vs PROPOSED

## Checkpoint 2: PRE-TEST
Before writing any test:
□ VERIFY every method call exists
□ VERIFY factory signature — read create() source
□ VERIFY import paths — grep actual file location
□ VERIFY base class methods
□ TEST one file first — run pytest on it before writing more

## Checkpoint 3: MID-IMPLEMENT (every 5 steps)
□ Cross-reference against spec
□ Check state of plan — still on track?
□ Review recent edits for convention-derived assumptions

## Checkpoint 4: PRE-COMMIT
□ All claims in code match actual imports
□ All tests describe actual behavior
□ Any "obvious" method exists? Grep to verify
```

### 4.5 drift-signals.md

```markdown
# Drift Signals DR1-DR12

Run via /drift-check command. Numbered, severity-assigned, tracked over time.

## HIGH Severity (blocks merge)
- DR1: Domain layer imports framework (FastAPI, Pydantic, SQLAlchemy, etc.)
- DR2: Evidence without citation (source_url missing)
- DR5: Claim stored without source_url
- DR6: Any type in domain package
- DR7: UL term drift (code vs glossary)
- DR8: Cross-BC direct import (no contract)
- DR9: Validation output without verifier step

## MEDIUM Severity (flags warning)
- DR3: LLM call without retry/budget
- DR4: Hardcoded prompt outside /prompts/
- DR10: Spec referenced doesn't exist
- DR12: Anti-pattern from agent-notes.md

## LOW Severity (logged)
- DR11: Stale session-handoff.md

## Checking Method
Each DR has grep pattern or script in scripts/drift-check/DR<N>.sh
Run all: scripts/drift-check/run-all.sh
Results append to agent-workspace/quality-reports/drift-reports/
```

### 4.6 session-budgets.md

```markdown
# Session Budget Rules

## Measured Data (Phase2 project, 51 sessions)
Quality degrades sharply past 250K tokens. "Lost in middle" effect kicks in.

## Session Types & Budgets
| Type | Budget | Purpose |
|---|---|---|
| PLAN | 50-80K | Architect subagent, produces session plan |
| FOCUSED IMPL | 100-150K | Dev, 1-3 tasks from plan |
| MULTI-TASK IMPL | 150-250K | Dev, 4-10 tasks from plan |
| VERIFY | 30-60K | Verifier subagent, adversarial review |
| RECOVERY | 80-150K | Revert + re-plan after failure |
| THESIS | 60-100K | Multi-perspective adversarial analysis on a stock |
| INGEST | 40-80K | Process new data sources into KB |
| POST-MORTEM | 30-50K | Review thesis outcomes, update calibration |

## Hard Rules
- If projected >250K → MANDATORY SPLIT
- If plan has >10 tasks → split plan into 2+ sessions
- If previous session failed → RECOVERY type required
- Never mix PLAN + IMPL in same session (Session 4 failure mode)
- THESIS sessions are read-only on code; output goes to thesis-log/

## Decision Tree (in /plan-next-session)
Q1: Detailed plan exists?
  NO → PLAN type (Architect)
  YES → Q2
Q2: How many tasks?
  1-3 small → FOCUSED IMPL
  4-10 → MULTI-TASK IMPL
  >10 → SPLIT
Q3: Previous session failed?
  YES → RECOVERY first
  NO → proceed
Q4: Analyzing a specific stock thesis?
  YES → THESIS type (code read-only)
  NO → proceed
```

### 4.7 financial-data-protocol.md

Stock-specific data integrity protocol. Always read before working with any data layer.

Key rules:
- **Rule 1: Point-in-Time Integrity** — every fundamental has `period_end`, `filing_date`, `ingested_at`. Backtest filters on `filing_date <= as_of_date`. Repository exposes only `get_as_of()` and `get_latest()`.
- **Rule 2: Survivorship-Aware Universe** — backtest universe includes delisted stocks; CI gate warns if <5% delisted.
- **Rule 3: Adjustment Type Tagging** — every price record has `adjustment_type` (NONE | DIVIDEND | SPLIT | BOTH). No mixed queries.
- **Rule 4: Source Attribution** — every data point has `source_provider`; reconciliation rules handle disagreements.
- **Rule 5: Currency Discipline** — `Money` value object always has `currency`; cross-currency math requires explicit conversion.
- **Rule 6: LLM Output Provenance** — extracted claims require `source_url`, `source_text_excerpt`, `extractor_model`, `extractor_prompt_hash`, `extractor_version`, `extracted_at`, `confidence_extracted`.
- **Rule 7: Sentiment Scores Are Categorical** — enum (STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH), not numeric. Aggregation to score happens in code.
- **Rule 8: Anti-Look-Ahead in News** — records have `published_at`, `ingested_at`, `scored_at`. Backtest applies `acting_lag`.
- **Rule 9: KOL Recommendation Provenance** — includes `timestamp_in_source`, `transcript_excerpt`, `extracted_conditions`, `extracted_timeframe`.
- **Rule 10: Backtest Reproducibility** — every run records `code_commit_hash`, `data_snapshot_id`, `config_file_hash`, `random_seed`.

Full detail: `agent-workspace/constitution/financial-data-protocol.md`.

---

## 5. Skills Catalog

Skills are **auto-discovered** by Claude Code when matching description. Keep them focused and composable.

### 5.1 Core Skills (our own)

**`.claude/skills/ddd-tactical-patterns/SKILL.md`**
When to use aggregate vs entity vs value object. Repository pattern in Python. Domain events. Anti-corruption layer. Stock domain examples: Thesis, Recommendation, KolCredibilityScore.

**`.claude/skills/spec-dual-layer/SKILL.md`**
Dual-layer spec structure (business narrative + agent contract). How to derive Part B from Part A. Tier 1/2/3 distinctions. Data Provenance and Adversarial Check sections for stock domain.

**`.claude/skills/evidence-extraction/SKILL.md`**
Extract claims with citation. Verification pattern. Link to source_url requirement (I-1). KOL recommendation extraction patterns.

**`.claude/skills/prompt-engineering/SKILL.md`**
Context assembly. Prompt caching strategy. Budget-aware prompts. No-LLM-math constraint enforcement in prompts.

**`.claude/skills/fastapi-module/SKILL.md`**
Project conventions for Python packages. dataclasses in domain. Pydantic in infrastructure/interfaces only. uv workflow. FastAPI DI via `Depends()` for API modules.

**`.claude/skills/postgres-pgvector/SKILL.md`**
Schema patterns. TimescaleDB usage. pgvector + pg_trgm. JSONB vs structured columns decision. Point-in-time query patterns.

**`.claude/skills/crawler-reliability/SKILL.md`**
Playwright patterns. Retry/backoff. Selector robustness. Scraping rate limits + robots.txt respect (I-S34).

**`.claude/skills/spec-to-wiki/SKILL.md`**
Convert raw spec to Obsidian wiki format. Add wikilinks, frontmatter, update index.

**`.claude/skills/test-pyramid-balance/SKILL.md`**
Unit vs integration vs E2E decision. BDD vs unit tests. Pyramid health metrics. Stock-specific: backtest tests, LLM extractor snapshot tests, calibration tests.

### 5.2 Meta-Skills (about the system)

**`.claude/skills/write-a-skill/SKILL.md`** (from mattpocock, adopted as-is)
Create new skills with proper structure, progressive disclosure, bundled resources.

**`.claude/skills/ubiquitous-language/SKILL.md`** (from mattpocock, adopted as-is)
Extract DDD-style ubiquitous language glossary from current conversation.

### 5.3 Skill Discovery Priority

When Claude Code starts a session, skills are ranked by description match. Our naming convention for high-match:

- Use clear verb-noun names: `spec-to-wiki`, `extract-evidence`
- Include domain keywords in description
- Link to relevant constitution files

---

## 6. Slash Commands

User-triggered, explicit actions. Located in `.claude/commands/`.

### 6.1 Session Lifecycle

**`/session-start [goal]`**
Load project state, read memory/project.md + last 3 sessions, check current-execution.md, identify session type, output session brief with context budget estimate.

**`/session-verify`**
Mid-session alignment check. Compare current work against session brief + invariants. Report drift.

**`/session-end`**
Summarize accomplishments, update project.md, write session log, flag pending items, update tracking. If thesis logged → ensure entry in thesis-log/.

**`/handoff-read`**
Load and summarize last session-handoff without full session-start ceremony.

**`/plan-next-session [topic]`**
Invoke master-planner subagent. Decomposes work, estimates context budget, outputs pending session-plan.

### 6.2 DDD & Specification

**`/drill-me [domain-area]`** (inspired by mattpocock grill-me, customized for DDD)
Interactive UL session. Agent asks structured questions about domain terms. Updates glossary. Flags conflicts with existing code.

**`/spec-author [feature-name]`**
Invoke spec-author subagent. Creates dual-layer spec (business + agent contract).

**`/spec-to-wiki [spec-path]`**
Convert raw spec to Obsidian wiki format. Add wikilinks, frontmatter, update _index.md.

**`/wiki-ingest [source-path]`**
Read source from raw/, create wiki entries, update index.

### 6.3 Quality & Verification

**`/drift-check [severity]`**
Run DR1-DR12 signals. Default: all. Can limit to HIGH only.

**`/vbw-check [target]`**
Run Verify-Before-Write protocol for given target (spec/test/code).

**`/ul-audit`**
Audit ubiquitous language consistency across codebase.

**`/spec-drift-check [spec-id]`**
Check if implementation drifted from spec.

**`/eval-regression-check`**
Run eval set, compare with baseline.

**`/thesis-validate [ticker]`**
Run thesis validation pipeline for given ticker. THESIS session type. Output to thesis-log/.

**`/post-mortem [thesis-id]`**
Review thesis outcome against original prediction. POST-MORTEM session type. Update calibration.

### 6.4 Planning & Strategy

**`/master-plan [task]`**
Invoke master-planner subagent for high-level work decomposition.

**`/devils-advocate [target]`**
Invoke devils-advocate subagent to critique current approach or plan.

**`/grill-me`** (from mattpocock, adopted as-is)
Get relentlessly interviewed about plan or design until every branch is resolved.

### 6.5 Token Management

**`/budget-check`**
Report current session token consumption, project against budget.

---

## 7. Subagents

Spawned via Task tool with isolated fresh context. Use when:
- Need objectivity (plan, review, critique)
- Need different persona (bear/bull/expert)
- Main context is full

### 7.1 Planning Subagents

**`.claude/agents/master-planner.md`**
Decompose high-level work into sessions. Estimate context budget. Enforce session budget rules. Output session-plan files.

**`.claude/agents/action-guide-planner.md`**
Given session brief, figure out exact execution plan: files to read, skills to load, specs to consult, test cases to satisfy.

**`.claude/agents/bdd-planner.md`**
Manage test pyramid centrally. Propose tests at each level. Check coverage balance. Stock-specific: propose backtest and LLM snapshot tests.

### 7.2 Specification Subagents

**`.claude/agents/spec-author.md`**
Business-analyst mindset. Turn requirements into dual-layer spec. Ask clarifying questions. Enforces Data Provenance and Adversarial Check sections for thesis-producing features.

**`.claude/agents/ul-auditor.md`**
Audit ubiquitous language consistency across codebase. Fresh context essential.

### 7.3 Execution Subagents (Sandwich Pattern)

**`.claude/agents/sandwich-architect.md`**
Plans session. Never implements. Produces detailed plan with task breakdown.

**`.claude/agents/sandwich-dev.md`**
Implements per plan. Does NOT re-plan. Executes tasks, reports results.

**`.claude/agents/sandwich-verifier.md`**
Adversarial review. Separate context from dev. Fresh eyes on implementation.

### 7.4 Critical Subagents

**`.claude/agents/devils-advocate.md`**
Critique current approach. Find weaknesses, hidden assumptions, missed edge cases. For stock theses: must produce explicit bear case, challenge calibration claims.

**`.claude/agents/drift-detector.md`**
Run drift signals, report violations with evidence.

---

## 8. Hooks

Deterministic pre/post tool events. Implemented as scripts in `.claude/hooks/`.

### 8.1 Pre-Commit
- Run `ruff` (block on fail)
- Run `mypy --strict` (block on fail)
- Run `pytest` (block on fail)
- Run drift signals HIGH severity (block on fail)
- Log to quality-reports/deterministic/

### 8.2 Post-File-Edit
- If edit touched `packages/domain/` → trigger UL drift check (advisory)
- If edit touched spec → flag for spec-drift-check next session
- If edit touched eval-sensitive code → flag eval regression check
- If edit touched data repository → flag financial-data-protocol compliance check

### 8.3 Pre-Merge
- All pre-commit checks
- Full drift signal scan (all DR)
- Eval set regression check

### 8.4 Pre-Deploy
- Full test suite
- Constitution invariants check
- Backup verification

### 8.5 Session-End
- Auto-reminder if session idle >15 min
- Enforce /session-end before exit

---

## 9. Memory System (MIL Pattern)

Three-tier memory layering. Total overhead target: **~5-7K tokens**.

### 9.1 Tier 1 — Session Memory

`agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`

Size: ~200-500 tokens per session.
Written at /session-end.
Format:
```markdown
# Session N — YYYY-MM-DD

## Goal
One sentence.

## Approach
2-3 sentences.

## Accomplished
- [list]

## Blocked / Unresolved
- [list]

## Patterns Noticed
- [list, link to patterns-discovered/ if added]

## Next Session Pickup
[What to do first next time]
```

### 9.2 Tier 2 — Cross-Session Memory

`agent-workspace/memory/project.md`

Size: ~1500 tokens target. Updated weekly by human or after major decisions.

Format:
```markdown
# Project Memory — StockForge

## Current Phase
[Phase N — Name]. Week X of Y.

## Phase Goals
- [goal]

## Recent Architectural Decisions (last 5)
1. [decision] — [rationale] — [date]

## Active TODOs (top 10)
- [todo]

## Known Issues
- [issue]

## Top Invariants (reference)
See constitution/invariants.md — don't duplicate.
```

`agent-workspace/memory/current-execution.md`

Routing source of truth. Prevents hardcoded paths in CLAUDE.md.

Format:
```markdown
# Current Execution

## Active Track
Phase: 1
Current focus: Foundation vertical slice
Active plan: session-plans/pending/001-thesis-validation.md
Session N: 5 (in progress)

## Routing
- "phase 1.x" → session-plans/ + phase1/
- "phase 2.x" → session-plans/ + phase2/
- "session N" → memory/sessions/
- "thesis X" → memory/thesis-log/

## Paused/Archived
(none yet)
```

### 9.3 Tier 3 — Permanent Memory

CLAUDE.md + constitution/ files. Size: ~4-6K tokens. Always loaded.

### 9.4 Thesis Log

`agent-workspace/memory/thesis-log/TICKER-YYYY-MM-DD.md`

Append-only. Each thesis entry:
- Ticker + as-of date
- Perspectives included (bear/bull/quant/macro/behavior/manager)
- Key claims with source citations
- Trade-off matrix
- Disagreement points surfaced
- Post-mortem scheduled (6-month)

Human curates: at 6-month mark run /post-mortem.

### 9.5 Pattern Memory

`agent-workspace/memory/patterns-discovered/*.md`

Grows organically. Each file:
- Pattern name
- When discovered (session N)
- Problem it solves
- Solution structure
- Example usage

Human curates quarterly: promote valuable patterns to skills, remove obsolete.

### 9.6 Learned Rules (Agent Notes)

`agent-workspace/memory/agent-notes.md`

Most valuable file. Each failure → new rule with evidence.

Format:
```markdown
## YYYY-MM-DD — Rule: [Short Name]

**Context**: What happened, in which session
**Problem**: What went wrong
**Rule**: The new rule
**Rationale**: Why this rule
**Enforcement**: How we'll catch it (gate, lint, manual check)

### Example rule entries

## 2026-04-20 — Rule: Never generate numbers from LLM output
**Context**: Session 3, thesis for HPG included ROE claim
**Problem**: LLM said "ROE approximately 18%" without tool call — violated I-S1
**Rule**: Before any thesis output, verify every numeric claim traces to a deterministic Python tool call result. grep output for "[0-9]+%" patterns not preceded by tool call result.
**Rationale**: Finance hallucination = real money lost. No exceptions.
**Enforcement**: DR5 drift signal + output validator + system prompt constraint.
```

### 9.7 Drift Logs

`agent-workspace/memory/drift-logs/YYYY-MM-DD-drift-N.md`

Each detected drift gets entry. Patterns over time reveal systemic issues.

---

## 10. Session Protocols

### 10.1 Session Start Protocol

```
1. Load .claude/CLAUDE.md (auto)
2. Run /session-start [optional goal]
   Which does:
   a. Read memory/current-execution.md → identify active track
   b. Read memory/project.md → current state
   c. Read last 3 session logs → context
   d. Read relevant glossary sections (if domain known)
   e. Check session-plans/pending/ → find matching plan
   f. Output session brief:
      - Goal
      - Session type (PLAN/IMPL/VERIFY/THESIS/INGEST/POST-MORTEM)
      - Context budget estimate
      - Files to load
      - Skills relevant
      - Success criteria
3. Human confirms or adjusts
4. Begin work
```

### 10.2 Mid-Session Protocol

Every ~30 min or after major task:
- Run /session-verify (lightweight alignment check)
- Run /budget-check (token consumption)
- If drift detected → pause, discuss, adjust

### 10.3 Session End Protocol

```
1. Run /session-end
   Which does:
   a. Summarize accomplishments
   b. Update memory/project.md (if arch decisions made)
   c. Write memory/sessions/YYYY-MM-DD-N.md
   d. Update memory/current-execution.md (status, next session)
   e. Flag unresolved items
   f. If learned rule emerged → add to agent-notes.md
   g. If thesis logged → ensure entry in memory/thesis-log/
2. Human reviews summary
3. Commit session artifacts
4. (Optional) Run /drift-check if code changed
```

### 10.4 Handoff Between Sessions

If work spans multiple sessions:
- Previous session writes explicit "Next session pickup" section
- Next session starts with /handoff-read
- Verifier session (if sandwich pattern) reviews previous dev output before new work

---

## 11. Quality Gates

Three-tier gate system (from Phase2 workflow research).

### 11.1 Tier 1 — Deterministic Gates

Automated, binary pass/fail. Block on fail.

- `mypy --strict` — types correct (Python 3.11+ strict mode)
- `pytest` — tests pass
- `ruff` — style correct (includes no-print rule for I-13)
- Dependency cycle check (`import-linter`)
- Drift signals HIGH severity (DR1, DR2, DR5, DR6, DR7, DR8, DR9)

Agent self-corrects with max 3 retry loop. Escalate if still failing.

### 11.2 Tier 2 — Probabilistic Gates

AI-as-critic. Separate agent (not same session). Advisory with escalation.

Process:
1. Fetch task context (spec, issue)
2. Gather diff (what changed)
3. Load contracts (spec, architecture, invariants)
4. Adversarial review (skeptical mindset)
5. Verdict: PASS or VIOLATIONS with citations

Used for:
- Spec alignment verification
- Architecture boundary checks
- UL consistency
- Test quality review
- Code smell detection
- **Calibration drift check** (stock-specific)
- **Thesis quality review** (adversarial check for bear case, provenance)

**Critical**: MUST use separate agent context. Same-agent self-review = echo chamber.

### 11.3 Tier 3 — Human Gates

Human strategic judgment required for:
- Architectural decisions
- API contract changes
- Security-sensitive changes
- Business rule changes
- Eval set regression sign-off
- Public-facing output review
- Charter-level changes
- **Thesis quality review** (post-mortem sign-off)
- **Signal weight changes** (requires calibration evidence)

NOT required for:
- Internal refactoring (same behavior)
- Bug fixes with test coverage
- Adding tests
- Doc updates

---

## 12. Adopted Skills from Community

### 12.1 mattpocock/skills

Adopted as-is:

- `ubiquitous-language` — Extract DDD glossary from conversation. **Core to our DDD workflow.**
- `grill-me` — Relentless interview on plan/design. Use before major implementation.
- `write-a-skill` — Meta-skill for creating skills properly.
- `obsidian-vault` — Base Obsidian interaction. We extend with raw/wiki schema.
- `edit-article` — Useful for refining specs and documentation.

Not adopted:
- `migrate-to-shoehorn` — TS type utility, not relevant
- `setup-pre-commit` — We have custom setup
- `design-an-interface` — Less relevant for Python data pipeline; may revisit for Streamlit dashboard

### 12.2 forrestchang/andrej-karpathy-skills

Adopted as-is:
- The four principles merged into `constitution/karpathy-principles.md`
- Philosophy integrated throughout constitution

### 12.3 LLM Wiki Pattern

Adopted architectural pattern:
- raw/ immutable + wiki/ LLM-owned + CLAUDE.md schema
- Applied to obsidian-vault/ structure
- Ingest/query/lint workflows referenced

### 12.4 kepano/obsidian-skills

Consider for Phase 2+:
- Teach agent to use Markdown, Bases, JSON Canvas
- Only if basic Level 2 integration proves insufficient

---

## 13. Development Workflow

### 13.1 Standard Feature Development Cycle

```
Phase A — Specification (1-2 sessions)
  /drill-me [domain] (if new domain)
  /spec-author [feature]
  Spec file created: specs/tier2-feature/NNN-feature.md
  Human reviews Part A (business narrative)
  /spec-to-wiki [spec-path]
  Wiki version created for navigation

Phase B — Test Planning (1 session)
  Invoke bdd-planner subagent
  Test cases proposed across pyramid
  Tests written, all failing (red)
  For data-layer features: include backtest and LLM snapshot tests

Phase C — Session Planning (1 session)
  /master-plan [feature]
  Sessions decomposed with budget estimates
  Session plans in session-plans/pending/

Phase D — Implementation (N sessions, sandwich pattern)
  For each session:
    /session-start
    sandwich-architect subagent: plan (if not already planned)
    sandwich-dev subagent: implement
    sandwich-verifier subagent: verify
    /session-end

Phase E — Quality Gates
  /drift-check
  /spec-drift-check
  /eval-regression-check
  Tier 2 probabilistic gate review
  Human Tier 3 review

Phase F — Integration & Learn
  Merge
  Update agent-notes.md if learned rules emerged
  Promote new patterns to patterns-discovered/
```

### 13.2 Thesis Development Cycle (THESIS session type)

```
Step 1: User requests thesis on ticker
  /thesis-validate [TICKER]

Step 2: THESIS session (60-100K budget, code read-only)
  Load BC-1/2/5 data for ticker (deterministic code, no LLM math)
  Run multi-perspective analysis:
    - Bear: ≥3 distinct points with citations
    - Bull: opportunity + catalysts with citations
    - Quant: valuation inputs from code-computed ratios
    (Phase 3+: add Macro, Behavior, Manager perspectives)
  Synthesize trade-off matrix (not single score)
  Surface disagreements explicitly (I-S12)
  Generate counter-narrative if sentiment >80% bullish (I-S13)
  Apply "research aid" framing (I-S35)

Step 3: Output
  Thesis card rendered in Streamlit dashboard
  Entry created in agent-workspace/memory/thesis-log/
  6-month post-mortem scheduled (I-S26)

Step 4: 6-Month Post-Mortem (POST-MORTEM session type)
  /post-mortem [thesis-id]
  Compare prediction vs actual outcome
  Update calibration database
  Update KOL credibility scores if applicable
```

### 13.3 The Goal-Driven Pattern (Karpathy P4)

Every session has explicit success criteria. Not "work on X" but:

```
Session goal: [concrete deliverable]
Success criteria:
1. [verifiable check]
2. [verifiable check]
3. [verifiable check]

Verification:
- Run [test/script/check]
- Output should be [expected]
```

Strong criteria let agent loop independently. Weak criteria require constant clarification.

### 13.4 The Think-Before-Coding Ritual (Karpathy P1)

Before implementation starts, agent explicitly:
1. States assumptions about the task
2. Lists multiple interpretations if ambiguity exists
3. Identifies tradeoffs
4. Asks for clarification on unclear points
5. Waits for human response before coding

---

## 14. Escalation Protocols

### 14.1 When to Escalate to Human

- Architectural decision beyond established patterns
- Conflict between two constitution rules
- Cost projected to exceed session budget
- Tier 2 gate finds HIGH severity violations
- Drift signal DR1-DR9 (HIGH) can't be auto-fixed
- Eval set shows regression
- 3 retry attempts on same error all failed
- Ambiguity that can't be resolved from spec
- **Any numeric output that cannot be traced to a deterministic Python tool call**
- **Thesis output missing bear case or source citations**

### 14.2 How to Escalate

Don't quietly keep trying. Agent outputs:

```
ESCALATION: [category]

Context: [what was being done]
Issue: [specific problem]
Attempted: [what was tried]
Blocking: [what can't proceed without human]
Options: [2-3 paths forward]
Recommendation: [agent's suggestion]

Awaiting human decision.
```

### 14.3 Emergency Stops

Hard stops (agent must stop immediately):
- Constitution invariant violation detected
- Security-sensitive operation unclear
- Destructive operation (delete, drop, revert) without explicit approval
- Cost projection exceeds daily budget
- **LLM output containing self-computed numbers (I-S1 violation)**
- **Thesis produced without substantive bear case (I-S10 violation)**

---

## 15. Anti-Patterns

### 15.1 Context Anti-Patterns
- **Load entire codebase before starting** (Session 4 failure) — use just-in-time
- **Load all specs at once** — load only target + dependencies
- **Narrative handoff format** — grows linearly, use structured summary
- **Stale entrypoints** — current-execution.md single source of truth

### 15.2 Process Anti-Patterns
- **Mix plan + implement** in same session (Session 4 — catastrophic)
- **Skip pre-flight check** — causes context misalignment
- **Single-agent cross-BC changes** — miss boundary violations
- **Retry failed approach** instead of revert (Session 45)
- **Cross-cutting change without dependency graph**
- **THESIS session editing code** — thesis sessions are read-only on code

### 15.3 Memory Anti-Patterns
- **Embed current state in permanent memory** — goes stale
- **Skip session-end protocol** — loses context
- **Don't update agent-notes.md on failure** — repeat mistakes
- **Keep stale entries in project.md** — misleading
- **Skip thesis-log entry** — loses calibration data

### 15.4 AI Anti-Patterns (Karpathy observations)
- **Silent assumption picking** — surface ambiguity
- **Wrong confidence without checking** — VBW protocol
- **Overcomplicate code/APIs** — Simplicity First
- **Change code you don't understand** — Surgical Changes
- **No explicit success criteria** — Goal-Driven Execution

### 15.5 Stock-Domain Anti-Patterns (StockForge-specific)

- **LLM generating numbers** — `"Based on my analysis, ROE is approximately 18%"` — WRONG. Code must compute from data. Violates I-S1.
- **Single-perspective thesis** — Always include bear case (≥3 distinct points), even when bullish. Violates I-S10.
- **Confident output without calibration data** — "High confidence" requires historical hit rate from calibration database, not model feeling. Violates I-S7.
- **Recommending stocks user already owns** — Check portfolio first; surface conflicts (confirmation bias risk).
- **Over-fitting to recent backtest** — VN market regimes change; 2021-2022 performance doesn't predict 2024.
- **Single "buy/sell" score** — Always multi-dimensional trade-off matrix. Violates I-52.
- **No insider information** — Public sources only. No paid leaks, no insider channels. I-S34.
- **Missing disclaimer** — All thesis/alert output must include "research aid, not financial advice" framing. Violates I-S35.
- **Look-ahead bias in backtest** — Query data with `get_as_of()`, never `latest`. Violates I-S2.
- **Collapsing disagreement to consensus** — When bear and bull reach opposite conclusions, show DISAGREEMENT. Violates I-S12.

### 15.6 Meta Anti-Patterns
- **Documentation replaces shipping** — if editing docs more than code, trouble
- **Feature creep past phase boundary** — phase locks
- **Quality regression unchecked** — eval set mandatory
- **Over-engineering Phase 1** — skeleton only, muscle grows

---

## Appendix A — Skill Template

```markdown
---
name: skill-name-kebab-case
description: One sentence. Specific keywords. When to use.
---

# Skill: Skill Name

## Purpose
What this skill does. Why it exists.

## When to Use
- Specific trigger 1
- Specific trigger 2

## When NOT to Use
- Wrong context 1
- Wrong context 2

## Process
Step-by-step workflow.

## Output Format
What the skill produces.

## Examples
Good examples, bad examples.

## Related Skills
Cross-references.
```

## Appendix B — Subagent Template

```markdown
---
name: subagent-name
description: Role summary. When to invoke.
model: opus | sonnet | haiku
tools: [list]
---

# Subagent: Name

## Persona
Role definition. Background. Mindset.

## Responsibility
What this agent does.

## Input
What it receives.

## Output
What it produces.

## Process
How it works.

## Constraints
What it must NOT do.
```

## Appendix C — Commands Quick Reference

| Command | Purpose | Typical Cost |
|---|---|---|
| `/session-start` | Begin session with context | ~5K tokens |
| `/session-verify` | Mid-session alignment | ~2K |
| `/session-end` | Close session, save state | ~3K |
| `/handoff-read` | Lightweight last-session load | ~1K |
| `/plan-next-session` | Decompose work | ~15K (subagent) |
| `/drill-me` | DDD language extraction | ~20K interactive |
| `/spec-author` | Create dual-layer spec | ~30K (subagent) |
| `/spec-to-wiki` | Convert to Obsidian | ~10K |
| `/drift-check` | Run drift signals | ~5K + script |
| `/vbw-check` | Verify-Before-Write | ~3K |
| `/master-plan` | High-level decomposition | ~20K (subagent) |
| `/devils-advocate` | Critique approach | ~15K (subagent) |
| `/grill-me` | Interactive interview | ~20K interactive |
| `/budget-check` | Token consumption check | ~500 |
| `/thesis-validate` | Run stock thesis pipeline | ~60-100K (THESIS session) |
| `/post-mortem` | Review thesis outcome | ~30-50K (POST-MORTEM session) |
