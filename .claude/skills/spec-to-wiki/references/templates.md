# spec-to-wiki — Templates & Detailed Rules

Companion to `SKILL.md`. Detailed templates for each step in the 7-step process.

## Wiki File

Target path: `obsidian-vault/wiki/specs/tier<N>-<type>/<spec_id>-<slug>.md`

```markdown
---
type: spec
tier: 2
spec_id: SPEC-2026-04-001
spec_slug: validate-investment-thesis
status: draft
version: 1.0
created: 2026-04-20
last_reviewed: 2026-04-20
bounded_contexts:
  - "[[bc/analysis]]"
  - "[[bc/portfolio]]"
related_specs: []
ubiquitous_language_terms:
  - "[[Thesis]]"
  - "[[BearAnalysis]]"
  - "[[Catalyst]]"
source_raw: "[../../../specs/tier2-feature/001-validate-investment-thesis.md]"
tags:
  - spec
  - tier2
  - feature
  - analysis
---

# [[SPEC-2026-04-001]] — Validate Investment Thesis

> Wiki view of [[SPEC-2026-04-001]].
> Raw source: [../../../specs/tier2-feature/001-validate-investment-thesis.md](../../../specs/tier2-feature/001-validate-investment-thesis.md)

## Navigation

- [[#Part A — Business Specification]]
- [[#Part B — Agent Contract]]
- [[#Part C — Provenance & Review]]

## Related Nodes

- **Depends on**: [[bc/market-data]]
- **Enables**: [[bc/portfolio]]
- **Bounded contexts**: [[bc/analysis]], [[bc/portfolio]]
- **Key terms**: [[Thesis]], [[BearAnalysis]], [[BullAnalysis]], [[Catalyst]]

---

[Full content of raw spec, with wikilinks applied]
```

## Wikilink Rules

**First mention of term in wiki doc**: add wikilink

```markdown
A [[Thesis]] is the structured investment analysis produced...
```

**Subsequent mentions in same doc**: plain text OK (avoid link spam)

```markdown
When thesis is submitted, the system emits ThesisSubmittedEvent...
```

**Code references**: don't wikilink inside code blocks

```python
# This is plain code — no wikilinks
thesis = Thesis.create(ticker, bull, bear)
```

## Stub Template

For mentioned entities/concepts without wiki page, create at `obsidian-vault/wiki/entities/<slug>.md`:

```markdown
---
type: entity
status: stub
source_mentions:
  - "[[SPEC-2026-04-001]]"
created: 2026-04-20
tags:
  - stub
  - entity
---

# [[Entity Name]]

> Stub page. Created because mentioned in [[SPEC-2026-04-001]].
> Please expand with context and connections.

## Context
First mentioned in context of: [brief description from where]

## Properties
- [Add structured info as known]

## Relationships
- Connected to: [list]

## Backlinks
*(Obsidian auto-populates)*
```

## Index & Log

Append to `obsidian-vault/wiki/_index.md`:

```markdown
## Specs

### Tier 2 (Feature)

- [[specs/tier2-feature/SPEC-2026-04-001-validate-investment-thesis]]
  - Status: draft
  - BCs: [[bc/analysis]], [[bc/portfolio]]
  - Created: 2026-04-20
```

Append to `obsidian-vault/wiki/_log.md`:

```markdown
## [2026-04-20] ingest | SPEC-2026-04-001

**Type**: spec (tier 2)
**Title**: Validate Investment Thesis
**Raw source**: `specs/tier2-feature/001-validate-investment-thesis.md`
**Wiki entry**: `obsidian-vault/wiki/specs/tier2-feature/SPEC-2026-04-001-validate-investment-thesis.md`
**Stubs created**:
- `wiki/entities/vcb.md`
- `wiki/concepts/adversarial-analysis.md`
**Existing links to**: [[Thesis]], [[BearAnalysis]], [[BullAnalysis]] (x6)
```

## Regeneration

When raw spec changes and wiki already exists:

### Diff-based update

1. Read current wiki file
2. Extract human additions:
   - Extra wikilinks added manually
   - Cross-references beyond what auto-extracted
   - Comments / notes in wiki frontmatter
3. Regenerate from raw
4. Preserve human additions
5. Update `last_reviewed` in frontmatter

### Full regeneration

If spec changes fundamentally:
1. Move old wiki to `obsidian-vault/wiki/archive/<date>/`
2. Generate fresh
3. Note in `_log.md`: full regen + reason
