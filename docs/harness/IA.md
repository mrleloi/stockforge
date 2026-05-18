# Harness Framework — Documentation Information Architecture

> **Status**: Draft v0 (2026-05-19). Refined after research-agent returns.
> **Audience**: Internal — guides docs writers (humans + agents).

## The Diataxis Map

Following [Diataxis](https://diataxis.fr/) — every chapter is classified by its dominant purpose:

| Purpose | Audience need | Chapters |
|---|---|---|
| **Tutorial** (learning-by-doing) | "Take me from zero" | 01-quickstart |
| **Explanation** (understanding) | "Help me think about it" | 02-mental-model, 03-architecture, 09-quality-system, 12-internals |
| **How-to** (problem-solving) | "Help me do X" | 11-cookbook, 14-contributing |
| **Reference** (information lookup) | "Tell me exactly what" | 04-constitution, 05-skills-commands-agents, 06-hooks, 07-memory-system, 13-reference, 15-glossary |
| **Mixed** | Most components have both why + what | 08-lifecycle, 10-self-improvement |

## Top-Level TOC (mirrored EN ↔ VI)

```
docs/harness/
├── README.md                       ← landing page (both EN + VI quicklinks)
├── IA.md                            ← this file (internal)
│
├── en/                              ← English authoritative version
│   ├── 00-preface.md
│   ├── 01-quickstart.md
│   ├── 02-mental-model.md
│   ├── 03-architecture.md
│   ├── 04-constitution.md
│   ├── 05-skills-commands-agents.md
│   ├── 06-hooks.md
│   ├── 07-memory-system.md
│   ├── 08-lifecycle.md
│   ├── 09-quality-system.md
│   ├── 10-self-improvement.md
│   ├── 11-cookbook.md
│   ├── 12-internals.md
│   ├── 13-reference.md
│   ├── 14-contributing.md
│   └── 15-glossary.md
│
├── vi/                              ← Vietnamese mirror (same structure)
│   ├── 00-loi-noi-dau.md
│   ├── 01-bat-dau-nhanh.md
│   ├── 02-mo-hinh-tu-duy.md
│   ├── 03-kien-truc.md
│   ├── 04-hien-phap.md
│   ├── 05-skills-commands-agents.md
│   ├── 06-hooks.md
│   ├── 07-he-thong-bo-nho.md
│   ├── 08-vong-doi.md
│   ├── 09-he-thong-chat-luong.md
│   ├── 10-tu-cai-thien.md
│   ├── 11-cong-thuc.md
│   ├── 12-noi-tai.md
│   ├── 13-tham-khao.md
│   ├── 14-dong-gop.md
│   └── 15-thuat-ngu.md
│
├── reference/                       ← auto-generatable inventories
│   ├── inventory-skills.md          ← 23 skills, one table row each
│   ├── inventory-commands.md        ← 17 commands
│   ├── inventory-agents.md          ← 14 subagents
│   ├── inventory-hooks.md           ← 118 hooks grouped by event + category
│   ├── inventory-constitution.md    ← 17 constitution files
│   ├── inventory-memory.md          ← memory files + dirs
│   └── inventory-decisions.md       ← all ADRs D-001..D-NNN
│
├── assets/                          ← diagrams, screenshots
│
└── .research/                       ← raw inventories from research agents (internal)
```

## Per-Chapter Brief

### 00 — Preface (~300 lines)
What this is. Who it's for. Why we wrote a book for it. How to read it (depending on role).

### 01 — Quickstart (~400 lines)
Tutorial. Take a reader who has never seen the harness through one complete session: open Claude Code → `/session-start` → look at what loaded → understand the brief → see the sandwich-architect dispatch → understand the result.

### 02 — Mental Model (~500 lines)
The 5 big ideas:
1. The agent is a director, Claude Code is the team
2. Sandwich pattern beats single-agent past 200K
3. Constitution + invariants are immutable; everything else evolves
4. The harness must self-verify firing, not self-attest existence (Principle 11)
5. Calibration over confidence (evidence + as-of dates)

### 03 — Architecture (~600 lines)
The 8 layers (constitution / permissions / hooks / memory / skills / commands / subagents / lifecycle). How they compose. Data-flow diagram. Where to put new features.

### 04 — Constitution (~800 lines)
Reference. Every constitution file in `agent-workspace/constitution/` with what it enforces, when it's consulted, immutability status. PROJECT_CHARTER deep-dive.

### 05 — Skills / Commands / Subagents (~1000 lines)
Reference + how-to. The 3 user-facing extension surfaces. Anatomy of each. When to use which. Real examples from current 23+17+14 inventory.

### 06 — Hooks (~1200 lines)
Reference + explanation. The 118-hook engine. Event model (SessionStart/SessionEnd/UserPromptSubmit/Stop/PreToolUse/PostToolUse). Categories. Firing-test discipline (Principle 11). Cascades and dependencies. Severity escalation pipeline.

### 07 — Memory System (~900 lines)
Reference + explanation. Memory tiers. Routing source-of-truth (`current-execution.md`). Decision discipline (ADRs). Append-only logs (sessions/, decisions/, observations/). Retention policies.

### 08 — Lifecycle (~1000 lines)
Explanation + reference. Session types (8). Plan lifecycle (pending → completed). Sandwich pattern flow. Workspace dualism (agent-workspace vs human-workspace). Q&A bundles.

### 09 — Quality System (~800 lines)
Explanation + reference. 3 tiers (deterministic / probabilistic / human). VBW protocol. Drift signals DR1-DR12. Harness health HH-1..HH-12. Charter Principle 11.

### 10 — Self-Improvement (~600 lines)
The continuous-learning loop: agent-notes (rules earned through experience), mistake-log (failure catalog), promote-rule (escalate pattern → skill → hook → constitution), severity-classifier + escalation-engine.

### 11 — Cookbook (~1000 lines)
How-to. Real procedures: write a new skill, write a new hook, write a new subagent, run a sandwich cycle, recover from an incident, dispatch parallel agents, set up Telegram alerts, archive memory, rotate logs.

### 12 — Internals (~600 lines)
Explanation. The 23 anti-patterns (AP-1..AP-23). Why sandwich works. Why the harness needs 118 hooks. What we tried and abandoned (RECOVERY sessions). Future directions.

### 13 — Reference (~400 lines)
Pointer chapter. Index of every artifact with link to detailed reference file.

### 14 — Contributing (~400 lines)
How-to. Adding to the harness. The ADR workflow. Constitution amendments (cool-down, ratification). What requires AskUserQuestion vs autonomous.

### 15 — Glossary (~300 lines)
Reference. Every term used throughout the docs. Cross-linked.

## Estimated Total

- **EN**: ~10,000 lines across 16 files
- **VI**: ~10,000 lines (mirror)
- **Reference**: ~3,000 lines (7 inventories)
- **Grand total**: ~23,000 lines of docs

## Writing Conventions

1. **Voice**: Direct, professional, no fluff. Style of Django/Spring docs — explain the *why* before the *what*.
2. **Examples**: Real artifacts from this project, with file:line citations. No invented examples.
3. **Cross-references**: Use `[link](relative-path)` between chapters. Glossary terms linked first occurrence.
4. **Code blocks**: Always specify language for syntax highlighting.
5. **Tables**: Use for reference material (lists of artifacts, properties, etc.)
6. **Diagrams**: ASCII for conceptual flow; mermaid for architecture (rendered in GitHub).
7. **Vietnamese**: Use English for technical terms (skill, hook, ADR, constitution). Vietnamese for prose. This matches the user's working preference.
