---
name: harness-docs-maintainer
description: Keep docs/harness/ in sync with the live harness — detect drift between book chapters / reference inventories and actual .claude/skills + .claude/commands + .claude/agents + scripts/hooks + agent-workspace/constitution counts. Use when running /harness-docs, after adding/removing skills/commands/agents/hooks, on quarterly cadence, or when chapter prose may be stale.
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
---

# Skill: Harness Docs Maintainer

## Purpose

The book at `docs/harness/` documents the live harness. The live harness evolves continuously. This skill detects drift between book and reality, regenerates auto-syncable inventory files, and surfaces prose chapters that may be stale.

It is the operational arm of [Chapter 14 § Keeping the Book in Sync](../../../docs/harness/en/14-contributing.md#keeping-the-book-in-sync).

## When to Use

- User runs `/harness-docs sync` (full inventory regen)
- User runs `/harness-docs drift` (drift report only, no writes)
- User runs `/harness-docs validate` (verify all internal links resolve)
- A new skill / command / subagent / hook is added or removed
- Constitution amended (charter version bump, new rule mv from proposals/)
- Quarterly cadence (full audit + dispatch `harness-docs-auditor` subagent)

## When NOT to Use

- For drift in *content* of chapters (vs counts) — that needs `harness-docs-auditor` subagent (fresh-context audit)
- For UL drift between glossary and code — use `/ul-audit` instead
- For DR1-DR12 drift signals — use `/drift-check`
- For brand-new documentation projects in other repos — use `attach` skill to port the framework first

## Process

### Step 1 — Inventory Diff

For each artifact type, compare live count vs reference inventory count:

```bash
# Skills
LIVE_SKILLS=$(find .claude/skills -mindepth 2 -name SKILL.md 2>/dev/null | wc -l)
DOC_SKILLS=$(grep -c '^| `' docs/harness/reference/inventory-skills.md 2>/dev/null || echo 0)

# Commands
LIVE_COMMANDS=$(find .claude/commands -maxdepth 1 -name '*.md' 2>/dev/null | wc -l)
DOC_COMMANDS=$(grep -c '^| `/' docs/harness/reference/inventory-commands.md 2>/dev/null || echo 0)

# Subagents
LIVE_AGENTS=$(find .claude/agents -maxdepth 1 -name '*.md' 2>/dev/null | wc -l)
DOC_AGENTS=$(grep -c '^| `' docs/harness/reference/inventory-agents.md 2>/dev/null || echo 0)

# Hooks
LIVE_HOOKS=$(find scripts/hooks -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l)
DOC_HOOKS=$(grep -c '^| `' docs/harness/reference/inventory-hooks.md 2>/dev/null || echo 0)

# Firing-tests
LIVE_FIRETESTS=$(find scripts/hooks/firing-tests -maxdepth 1 -name '*-fire-test.sh' 2>/dev/null | wc -l)

# Constitution
LIVE_CONST=$(find agent-workspace/constitution -maxdepth 1 -name '*.md' 2>/dev/null | wc -l)
DOC_CONST=$(grep -c '^| `' docs/harness/reference/inventory-constitution.md 2>/dev/null || echo 0)
```

For each mismatch, list the diff: which artifacts are in live but not docs (NEW), which are in docs but not live (REMOVED).

### Step 2 — Frontmatter Diff

For each artifact present in BOTH live and docs, check whether description/purpose drift exists:

- Skills: compare `description:` in SKILL.md vs the table row
- Commands: compare first-line title vs the table row
- Subagents: compare `description:` in agent.md vs the table row
- Hooks: header comment first line vs table row

### Step 3 — Link Resolution Check

Walk each chapter file in `docs/harness/en/` and `docs/harness/vi/`. For each `[text](path)` link, verify the target path exists.

Report broken links.

### Step 4 — Cross-Chapter Reference Validation

For chapter prose that cites specific counts ("23 skills", "118 hooks", "14 subagents"), verify the count is current. Report drift.

### Step 5 — Generate Drift Report

Write to `docs/harness/.research/drift-report-YYYY-MM-DD.md`:

```markdown
# Drift Report — YYYY-MM-DD

## Counts
| Layer | Live | Docs | Diff |
|---|---|---|---|
| Skills | <n> | <m> | <±k> |
| Commands | <n> | <m> | <±k> |
| Subagents | <n> | <m> | <±k> |
| Hooks | <n> | <m> | <±k> |
| Firing-tests | <n> | <m> | <±k> |
| Constitution | <n> | <m> | <±k> |

## New Artifacts (in live, not docs)
- skills/<new-skill>
- ...

## Removed Artifacts (in docs, not live)
- commands/<removed-command>
- ...

## Description Drift
- skill `<name>` description changed: ...
- ...

## Broken Links
- en/03-architecture.md cites path that doesn't exist: ...

## Prose Count Drift
- en/03-architecture.md says "118 hooks" but live count is 120
- ...

## Recommended Actions
1. Run `/harness-docs sync` to regenerate <list>
2. Manual update needed for: <list>
```

### Step 6 — Regenerate Inventories (sync mode only)

If invoked as `/harness-docs sync`, regenerate the inventory files in `docs/harness/reference/`:

- `inventory-skills.md`
- `inventory-commands.md`
- `inventory-agents.md`
- `inventory-hooks.md`
- `inventory-constitution.md`
- `inventory-memory.md`
- `inventory-decisions.md`

For each, read live artifacts + rebuild the markdown table. Preserve hand-written cross-reference sections; only regenerate the auto-table portion.

Use the existing inventory file structure as template (don't replace, edit the table region in-place).

### Step 7 — Surface Prose Update Needs

For chapter prose drift (counts cited inline), DO NOT auto-edit chapters. Surface as recommendations in the drift report. Chapter prose updates need human review because they may touch surrounding context.

Recommendation format:
- File: `en/03-architecture.md`
- Line: ~120 ("with 118 hooks")
- Change: "118 hooks" → "120 hooks"
- Why: live count changed

### Step 8 — Trigger `harness-docs-auditor` if Needed

If drift is substantial (>10% count change, or any constitution amendment), recommend dispatching the `harness-docs-auditor` subagent for fresh-context full chapter audit.

## Output

Always: drift report at `docs/harness/.research/drift-report-YYYY-MM-DD.md`.

If `sync` mode: regenerated inventory files.

If `validate` mode: link resolution table.

If `drift` mode: drift report only (no writes to inventories or chapters).

## Anti-Patterns

- **Auto-editing chapter prose** — chapters need human review; auto-edit risks losing context
- **Skipping link validation** — broken cross-references compound; validate every cycle
- **Treating inventory regen as truth** — regen is mechanical; the prose chapters still need periodic deeper audit (via `harness-docs-auditor`)
- **Running without `bash -n` lint of bash one-liners** — syntax errors in this skill block all maintenance

## Related Skills

- `attach` — porting harness to new project (reads same manifest)
- `promote-rule` — both are "self-maintenance" skills
- `ubiquitous-language` — UL audit pairs with docs audit for full glossary coverage

## Related Artifacts

- Command: `/harness-docs` (this skill's user-facing wrapper)
- Subagent: `harness-docs-auditor` (fresh-context full chapter audit)
- Book: `docs/harness/`
- Source: `.claude/skills/`, `.claude/commands/`, `.claude/agents/`, `scripts/hooks/`, `agent-workspace/constitution/`
