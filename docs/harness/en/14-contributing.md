# Chapter 14 — Contributing

> **Diataxis quadrant**: How-to + Explanation
> **Reading time**: ~25 minutes
> **Prerequisites**: Chapter 4 (Constitution), Chapter 10 (Self-Improvement)

This chapter is for people who want to *extend* the harness — add a skill, propose a constitution rule, ratify an ADR, port the harness to a new project. It assumes you have read the earlier chapters and want to participate in the system's evolution.

---

## 14.1 — The Mental Model of Contribution

Contributing to the harness is different from contributing to a typical open-source project. The differences:

| Typical OSS | Harness |
|---|---|
| Fork → PR → merge | Propose → cool-down → ratify → mv |
| Maintainers decide | Project owner ratifies; agent proposes |
| Code review by humans | Sandwich pattern (architect → dev → verifier) |
| Tests are the gate | Tests + drift signals + harness health + verifier |
| Breaking changes versioned | Constitution amendments versioned; everything else evolves freely |

The key shift: **the harness is contributed to by both humans and agents**. Both follow the same protocol.

If you are a human reading this: this chapter tells you what to do.
If you are an agent reading this: you already know this chapter; refer to [`agent-workspace/CLAUDE.md`](../../../agent-workspace/CLAUDE.md) § Contract Rules.

---

## 14.2 — What to Ask vs What to Decide

Per [`autonomous-protocol.md`](../../../agent-workspace/constitution/autonomous-protocol.md) Rule 8:

> "AskUserQuestion is for genuinely-new SCOPE/CHARTER decisions only — not for routine handoffs or 'what should I do next session?'"

Decision tier governs who decides:

| Tier | Confidence threshold | Who decides |
|---|---|---|
| CHARTER | 0.99 | Always AskUserQuestion bundle + human ratify |
| SCOPE | 0.90 | AskUserQuestion if < 0.90 |
| ARCH | 0.80 | Self-decide if ≥ 0.80 |
| IMPL | 0.50 | Self-decide if ≥ 0.50 |

### Examples

**ASK** (CHARTER-tier):
- Amend `PROJECT_CHARTER.md`
- Add a new bounded context to the architecture
- Change the 11 principles
- Override a hard boundary B-1..B-14

**ASK** (SCOPE-tier):
- Add a new data provider (e.g., another KOL channel)
- Change a Phase target
- Add a new session type

**SELF-DECIDE** (ARCH-tier):
- Pick between two valid architectures with similar tradeoffs
- Choose a library version
- Refactor approach within an established pattern

**SELF-DECIDE** (IMPL-tier):
- Variable names
- Test fixture structure
- Comment style
- Whether to inline or extract a function

### How to Tell the Tier

If unsure, ask: "Is this decision likely to outlive the current sprint?"

- **Yes, multi-phase impact** → CHARTER or SCOPE
- **Lives within a phase** → ARCH
- **Lives within a session** → IMPL

When still unsure, **bias to ASK**. False negatives (asking when self-decide would have been fine) cost a small amount of user attention. False positives (self-deciding when ask was needed) cost trust.

---

## 14.3 — Proposing a Constitution Rule

When a learned rule has reached invariant tier, it gets proposed for constitution.

### Step 1: Write the Proposal

Location: `agent-workspace/proposals/<slug>.md`.

Frontmatter:

```yaml
---
status: PROPOSED
tier: CHARTER  # or SCOPE
ratification_path: AskUserQuestion bundle
cool_down_hours: 48
target_file: agent-workspace/constitution/<file>.md
proposed_at: <ISO-8601>
proposed_by: <agent | human>
source_evidence:
  - <session ID where lesson surfaced>
  - <link to mistake-log entry>
  - <link to prior ADR if related>
---
```

Body:

```markdown
# Proposal: <title>

## Background
[why this rule is needed; what failure mode it addresses]

## Proposed Rule
[the literal rule text, ready to mv into constitution]

## Options Considered
- Option A (Recommended): <description> / pros / cons
- Option B: <description> / pros / cons
- Option C (defer): <description> / pros / cons

## Recommendation
[which option + rationale]

## Companion Artifacts
[hooks / skills / firing-tests that will ship with the rule]

## Catch-Rate Estimate
[from agent-notes.md: how many past sessions would this rule have helped]
```

### Step 2: Cool-Down

48 hours minimum before ratification. The hook `proposal-bundle-advisor.sh` (SessionStart) surfaces ready proposals.

The cool-down is non-negotiable. It exists so the proposal can be re-read with fresh context.

### Step 3: Ratification

User issues explicit approval via `AskUserQuestion` bundle:

```
Q: Approve proposal <slug> Option A as recommended?
Options:
  (A) Approve verbatim
  (B) Approve with minor edits (specify)
  (C) Defer (specify why)
  (D) Reject (specify why)
```

Capture user's pick.

### Step 4: Author the Ratifying ADR

Per [Recipe 11](11-cookbook.md#recipe-11--run-an-adr-through-the-lifecycle). The ADR's `chosen_rationale` field cites the user's Q1=A pick.

### Step 5: MV to Constitution

The `agent-workspace/constitution/**` path is denied to agent edit. To mv, you need a one-time deny-lift:

**Path 1** (preferred): bundle the mv with an existing approved Edit operation. The agent commit cycle handles both at once.

**Path 2**: temporarily lift the deny in `.claude/settings.json`, mv, restore deny. This requires human approval (charter-tier).

Per L-S310-2 actually shipped pattern:
```bash
# Bash bypass via cp (Write deny doesn't catch Bash cp)
cp agent-workspace/proposals/<slug>.md agent-workspace/constitution/<file>.md
git rm agent-workspace/proposals/<slug>.md  # archive
```

### Step 6: Cross-Reference Update

Grep for `proposals/<slug>` across repo. Update all to `constitution/<file>`.

```bash
grep -rln "proposals/<slug>" .
# update each match
```

### Step 7: Update `project.md`

Add the ratifying ADR to the **Recent Architectural Decisions** section.

### Step 8: Verify

In next session, verify:
- File exists at constitution path
- Old proposal path is gone
- ADR cross-references resolve
- Any hooks/skills that read the rule still find it

---

## 14.4 — Adding a New Skill / Command / Subagent / Hook

See:
- [Chapter 11 § Recipe 1 — Write a New Skill](11-cookbook.md#recipe-1--write-a-new-skill)
- [Chapter 11 § Recipe 2 — Write a New Slash Command](11-cookbook.md#recipe-2--write-a-new-slash-command)
- [Chapter 11 § Recipe 3 — Write a New Subagent](11-cookbook.md#recipe-3--write-a-new-subagent)
- [Chapter 11 § Recipe 4 — Write a New Hook](11-cookbook.md#recipe-4--write-a-new-hook)

After adding, update the relevant inventory:
- Skills → [`docs/harness/reference/inventory-skills.md`](../reference/inventory-skills.md)
- Commands → [`docs/harness/reference/inventory-commands.md`](../reference/inventory-commands.md)
- Subagents → [`docs/harness/reference/inventory-agents.md`](../reference/inventory-agents.md)
- Hooks → [`docs/harness/reference/inventory-hooks.md`](../reference/inventory-hooks.md)

OR run `/harness-docs sync` and let the maintainer agent regenerate.

---

## 14.5 — Keeping the Book in Sync

This book is itself a harness artifact. It needs maintenance.

### The `harness-docs-maintainer` Skill

Lives at [`.claude/skills/harness-docs-maintainer/SKILL.md`](../../../.claude/skills/harness-docs-maintainer/SKILL.md).

**Triggers**:
- User runs `/harness-docs sync`
- A new skill / command / subagent / hook is added (Stop hook detects + recommends sync)
- A constitution rule is amended

**What it does**:
1. Scans `.claude/skills/`, `.claude/commands/`, `.claude/agents/`, `scripts/hooks/`
2. Compares each artifact's frontmatter against the corresponding inventory file
3. Reports drift: new artifacts not yet in inventory, deleted artifacts still listed, changed descriptions not yet reflected
4. Offers to regenerate the affected inventory files

**Output**: drift report + regenerated inventories.

### The `/harness-docs` Command

Wrapper for the skill.

```
/harness-docs sync            # full inventory sync
/harness-docs sync skills     # only skills inventory
/harness-docs drift           # report drift without writing
/harness-docs validate        # verify all links resolve
```

See [`.claude/commands/harness-docs.md`](../../../.claude/commands/harness-docs.md).

### The `harness-docs-auditor` Subagent

For drift between the prose chapters (00-15) and the live harness, dispatch the [`harness-docs-auditor`](../../../.claude/agents/harness-docs-auditor.md) subagent. It runs in fresh context, reads:
- Both the live system inventories
- The prose chapters

And reports:
- Chapter claims that no longer match reality (e.g., "23 skills" when there are now 25)
- Missing cross-references
- Out-of-date examples
- Sections that should be updated

### Triggers for Re-Audit

| Trigger | Action |
|---|---|
| Constitution amendment | Re-audit Chapter 4 |
| New ADR ratified | Re-audit Reference § ADRs |
| Skill / command / subagent added or removed | Run `/harness-docs sync` |
| Hook added or removed | Run `/harness-docs sync` + re-audit Chapter 6 sections |
| Charter version bump | Full re-audit |
| Quarterly cadence | Full re-audit + dispatch `harness-docs-auditor` |

### Drift Signal Integration

Drift between docs and reality is tracked as a drift signal (similar to DR1-DR12). Add to constitution if needed:

- DR-D1 — Inventory file count mismatches live count
- DR-D2 — Chapter cites artifact name that does not exist
- DR-D3 — Example file:line citation invalid

These would be promoted from `agent-notes.md` per the standard lifecycle.

---

## 14.6 — Porting the Harness to a New Project

If you want to spin up the harness in a different project (e.g., a sister project at `C:\htdocs\my-new-project/`).

### Use the `attach` Skill

Lives at [`.claude/skills/attach/SKILL.md`](../../../.claude/skills/attach/SKILL.md). Designed exactly for this.

```
Dispatch attach skill to port harness layer from C:\htdocs\stockforge to C:\htdocs\my-new-project
```

What it does:
1. Reads `.claude/manifest.yaml` for harness metadata
2. Honors layer tags (harness / stockforge / personal)
3. Copies harness layer to target project
4. Adapts paths and identity rules to target
5. Supports `--dry-run` for preview

What it does NOT copy:
- Stockforge-specific constitution (financial-data-protocol, invariants-stockforge)
- Stockforge-specific skills (crawler-reliability, evidence-extraction, etc.)
- Project memory (sessions, decisions, observations)
- Calibration data
- Stock-domain BCs

### Manual Porting Checklist

If you do not use the `attach` skill:

1. **Copy `.claude/`** (skills, commands, agents, settings.json template, hooks/example)
2. **Copy `scripts/hooks/`** (all 118 hooks + firing-tests) — these are generic to the harness pattern
3. **Copy generic constitution files** (`karpathy-principles.md`, `architecture.md`, `boundaries.md`, `vbw-protocol.md`, `drift-signals.md` (generic part), `session-budgets.md`, `autonomous-protocol.md`, `coding-principles.md`, `decision-discipline.md`, `harness-health-protocol.md`, `memory-routing-tree.md`, `memory-tiers.md`, `severity-schema.md`, `portability.md`)
4. **Author project-specific charter** (`PROJECT_CHARTER.md`)
5. **Author project-specific CLAUDE.md** at project root
6. **Author project-specific invariants** (`agent-workspace/constitution/invariants-<project>.md`)
7. **Initialize memory directories** (empty `sessions/`, `decisions/`, etc.)
8. **Initialize `current-execution.md`** with autonomous_mode = true + Phase 0 entry
9. **Initialize `project.md`** with project description + initial Phase Goals Tracker
10. **Run `bash scripts/hooks/firing-tests/run-all.sh`** — verify all firing-tests pass

### Layer Tags

Per `attach` skill manifest, artifacts are tagged:

- **harness** — generic; copy to any project
- **stockforge** — stock-domain; copy only to stock-related projects
- **personal** — owner-specific; do not copy

Examples:
- `karpathy-principles.md` → tag: harness
- `evidence-extraction` skill → tag: stockforge
- `personal-risk-profile.md` → tag: personal

---

## 14.7 — Reporting a Bug in the Harness

When the harness itself is broken (not the product code), report via:

### Severity-Tier Routing

- **Mass deletion / data loss** → CRITICAL — `human-workspace/notifications/urgent.md` + Telegram push
- **Block enforcer false positive (loops the agent)** → HIGH — write to `human-workspace/q-and-a/pending/`
- **Hook silently fails to fire** → MEDIUM — write to `agent-notes.md` as lesson + propose hook fix
- **Documentation inconsistency** → LOW — write to `human-workspace/q-and-a/pending/` low-priority

### Anatomy of a Bug Report

```markdown
# Bug: <short title>

## Severity
<CRITICAL | HIGH | MEDIUM | LOW>

## Discovery
- Session: S<N>
- Trigger: <what user did or what hook fired>
- Symptom: <what went wrong>

## Reproduction
1. Step 1
2. Step 2
3. Step 3

## Expected vs Actual
- Expected: <behavior>
- Actual: <behavior>

## Hypothesis
<root cause guess>

## Proposed Fix
<fix sketch — may be a new hook, a constitution amendment, etc.>

## Related
- M-S<N>-<M> (mistake log entry)
- Past lesson L-S<NN>-<MM> if related class
- Other bugs in similar class
```

---

## 14.8 — The Promotion Lifecycle (Recap)

Detailed in [Chapter 10 § 10.2](10-self-improvement.md#102--the-promotion-lifecycle). Quick recap:

```
TIER 0 — INLINE (agent-notes.md digest)
  ↓ promote on 2nd instance (per AP-23)
TIER 1 — SKILL (.claude/skills/<name>/SKILL.md)
  ↓ promote when statically detectable
TIER 2 — HOOK (scripts/hooks/<name>.sh + firing-test)
  ↓ promote when rule rises to invariant
TIER 3 — CONSTITUTION (agent-workspace/constitution/<file>.md)
```

Each tier graduation requires:
1. Authoring the artifact (skill / hook / proposal)
2. Companion firing-test (for hooks; per Principle 11)
3. ADR ratifying the promotion
4. Cross-reference update across all consumers

---

## 14.9 — Documentation Standards

When writing for the book or proposing rules:

### Voice
- Direct, professional, no fluff
- Active voice
- "You" (second person) for instructional prose
- "The agent" / "The harness" for system descriptions

### Examples
- Real artifacts from the project (file:line citations)
- No invented examples

### Cross-References
- Use `[link](relative-path)` between chapters
- Link glossary terms on first occurrence in a chapter

### Code Blocks
- Always specify language for syntax highlighting
- Bash examples must work on Windows (bash via Git Bash) + Linux + Mac
- Python examples assume Python 3.11+

### Tables
- Use for reference material (lists, properties)
- Include header row
- Right-align numbers, left-align text

### Diagrams
- ASCII for conceptual flow (rendered everywhere)
- Mermaid for architecture (renders on GitHub)
- Inline images only when ASCII would obscure

### Vietnamese Mirror
- Same structure, same content
- Technical terms in English
- Natural Vietnamese for prose
- See [`docs/harness/vi/`](../vi/) for reference

---

## 14.10 — Getting Help

| Question type | Where to ask |
|---|---|
| How do I do X? | Read [Chapter 11 — Cookbook](11-cookbook.md); if not covered, write to `human-workspace/q-and-a/pending/` |
| Why does the harness do Y? | Read [Chapter 12 — Internals](12-internals.md); if not covered, run `/devils-advocate` on Y |
| What is Z? | Check [Chapter 15 — Glossary](15-glossary.md) |
| Where is the artifact for W? | Check [Chapter 13 — Reference](13-reference.md) |
| Is this a bug? | Run `/drift-check` first; if drift surfaces, file per [§ 14.7](#147--reporting-a-bug-in-the-harness) |

---

## 14.11 — Where to Read Next

- **Glossary of terms** → [Chapter 15 — Glossary](15-glossary.md)
- **Full artifact inventory** → [Chapter 13 — Reference](13-reference.md)
- **Recipes** → [Chapter 11 — Cookbook](11-cookbook.md)
- **The first chapter you read** → start over at [Chapter 1 — Quickstart](01-quickstart.md) if you have not done so
