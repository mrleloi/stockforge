# Reference — Commands Inventory

> **Audited**: 2026-05-19
> **Source**: `.claude/commands/*.md` (17 commands total — includes `/harness-docs` added with this book)
> **Maintainer**: Run `/harness-docs sync commands` to regenerate

Each command is a user-typed slash invocation at `.claude/commands/<name>.md`. Most are thin wrappers that delegate to a skill or dispatch a subagent.

See [Chapter 5 § Commands](../en/05-skills-commands-agents.md#53--commands) for anatomy.

**Note**: 16 command files exist (not 17). There is no `/bdd-planner` command — the `bdd-planner` subagent is dispatched manually.

---

## Session Lifecycle (5 commands)

| Command | Purpose | Invokes |
|---|---|---|
| `/session-start` | Load state, identify session type, output brief | (no skill — reading priority in body) |
| `/session-verify` | Mid-session alignment check | (no skill) |
| `/session-end` | Close session + update memory | (no skill — checklist in body) |
| `/handoff-read` | Lightweight session-pickup (vs full /session-start) | (no skill) |
| `/budget-check` | Report token consumption + projection | (no skill — formula in body) |

---

## Planning + Spec (3 commands)

| Command | Purpose | Invokes |
|---|---|---|
| `/master-plan` | Decompose goal into phased sessions | `master-planner` subagent |
| `/spec-author` | Create dual-layer spec | `spec-author` subagent |
| `/spec-to-wiki` | Convert raw spec to Obsidian wiki | `spec-to-wiki` skill |

---

## Adversarial + Quality (6 commands)

| Command | Purpose | Invokes |
|---|---|---|
| `/devils-advocate` | Adversarial critique of plan/spec/code/thesis | `devils-advocate` subagent |
| `/drift-check` | Run drift signals DR1-DR12 | `drift-signals-D1-D9.sh` + `drift-detector` for DR7/DR12 |
| `/drill-me` | Interactive DDD UL extraction | `ubiquitous-language` skill |
| `/grill-me` | Relentless plan/design interview | `grill-maximization` skill |
| `/ul-audit` | Audit UL consistency (code vs glossary) | `ul-auditor` subagent + grep checks |
| `/vbw-check` | Apply VBW protocol for current task | `vbw-protocol.md` constitution |

---

## Documentation Maintenance (1 command — added 2026-05-19)

| Command | Purpose | Invokes |
|---|---|---|
| `/harness-docs` | Detect drift + regen inventories for docs/harness/ | `harness-docs-maintainer` skill + `harness-docs-auditor` subagent (audit mode) |

---

## Infrastructure Toggles (2 commands)

| Command | Purpose | Invokes |
|---|---|---|
| `/autonomous` | Toggle autonomous mode on/off/status | (atomic file ops on current-execution.md) |
| `/block` | Human-gate control (status/clear/raise) | `block-control.sh` |

---

## Anatomy

Each command file structure:

```markdown
# /<name> — <one-line purpose>

## When to Use
<concrete triggers>

## Input
<optional $ARGUMENTS>

## Steps
1. <numbered>
2. ...

## Brief Schema / Output Schema
<what user sees>

## Error Handling
## Anti-Patterns
## Related
```

**D1 ceiling**: 96 LOC first-draft.

---

## The Anti-Duplication Rule (L-S14-2)

A skill named `foo` and a command named `/foo` should NOT duplicate procedure. Pick one canonical implementation; the other invokes.

Example: `/drill-me` delegates to `ubiquitous-language` skill (canonical); `/grill-me` delegates to `grill-maximization` skill.

---

## Missing / Drift Notes

- No `/bdd-planner` command (subagent only)
- No `/thesis-author` command/agent (THESIS routes through `/session-start --type THESIS`)
- No `/phase-boundary` command (phase boundary is implicit trigger for multiple skills)
- CCS plugin commands (`ccs`, `init`, `review`, `security-review`, etc.) appear in available-skills banner but are NOT project commands — at the CCS plugin level

---

## See Also

- [Chapter 5 — Skills, Commands, Subagents](../en/05-skills-commands-agents.md)
- [Chapter 11 — Cookbook](../en/11-cookbook.md) for recipes that use these commands
