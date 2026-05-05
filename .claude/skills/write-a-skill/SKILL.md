---
name: write-a-skill
description: Create new Claude Code skills with proper structure, progressive disclosure, and discoverability. Use when extracting a pattern from multiple sessions into a reusable skill, or when user asks to formalize a technique. Adapted from mattpocock/skills, MIT licensed.
---

# Skill: Write a Skill

## Purpose

Turn an observed pattern into a reusable skill that Claude Code auto-discovers and applies.

## When to Create a Skill

- Same pattern applied in 3+ sessions → skill candidate
- User explains the same technique repeatedly → formalize it
- Post-mortem reveals a rule that would help future sessions → skill
- New tool/library adopted with non-obvious correct usage → skill

## When NOT to Create a Skill

- One-off patterns (not reusable)
- Framework documentation (link to docs instead)
- Obvious patterns (experienced dev would know)
- Duplicates of existing skills

## Anatomy

```
.claude/skills/<skill-name>/
├── SKILL.md          # required (≤150 LOC per drift-signals D1)
├── examples/         # optional concrete examples
└── references/       # optional companion docs (no LOC ceiling)
```

## SKILL.md Structure

Template + section breakdown: see `references/best-practices.md` § "Structure" and `references/templates.md` § "SKILL.md skeleton".

Core sections every skill needs: frontmatter (`name` + `description`), Purpose, When to Use, When NOT to Use, Process / Content, Anti-Patterns, Related.

## Critical: The Description Field

Claude Code auto-discovers skills by matching `description` to current context. A vague description means the skill never fires.

### Description writing rules

1. **Lead with the core action** — "Extract X", "Implement Y", "Design Z"
2. **Include domain keywords** — terms the user might mention (`thesis`, `KOL`, `pump`)
3. **"Use when" clause** — explicit trigger conditions
4. **Optional**: what's avoided / ensured
5. **StockForge-specific**: mention any invariants this skill enforces (e.g., I-S1 no-LLM-math)

Bad/good examples + StockForge-specific examples: `references/templates.md` § "Description examples".

## Progressive Disclosure (L-S14-1)

First-draft target: **20% under the ceiling** (skill ≤120 LOC, command ≤96 LOC, agent ≤160 LOC). Reserve 20-40 LOC for amendments. A skill drafted AT the ceiling violates D1 within 2-3 amendments. See `references/best-practices.md` § L-S14-1.

When content grows past compression reserve: extract topical sub-sections to `references/<topic>.md` (no D1 ceiling) and replace inline content with a one-line pointer. Don't compress at the cost of clarity.

## Quality Checklist for New Skill

- [ ] `description` is specific enough to trigger appropriately
- [ ] `description` contains keywords user would likely use
- [ ] "When to use" + "When NOT to use" both concrete
- [ ] At least one example included
- [ ] Anti-patterns section has 3+ concrete bad examples
- [ ] Cross-references to related skills
- [ ] SKILL.md ≤120 LOC (first-draft target per L-S14-1)
- [ ] If skill touches financial output: I-S1 no-LLM-math constraint noted
- [ ] Tested: manually trigger with matching keywords, verify activation

## Skill Bloat — Pruning

Every skill loaded consumes context tokens. Quarterly: any skill not triggered in 3 months — evaluate (still relevant? description need fixing? deprecate?).

## Migration from mattpocock Skills

If adopting from upstream:

1. Copy SKILL.md
2. Review description for StockForge-specific context
3. Adjust examples to StockForge domain (thesis, KOL, VN stocks) if relevant
4. Keep MIT attribution note
5. Add stock-domain invariants (I-S1 no-LLM-math, I-S2 citation) where applicable
6. Link to upstream in "Related" section

## Anti-Patterns

- Vague description (won't trigger reliably)
- SKILL.md drafted AT ceiling (violates D1 after first amendment)
- Code dumps in SKILL.md (push to `examples/` or `references/`)
- Duplicating procedure between `<name>` skill and `/<name>` command (L-S14-2 — see `references/best-practices.md`)
- No "Not to confuse with" / no anti-patterns section

## Related Skills

- `ubiquitous-language` — when skill involves domain terms
- `obsidian-vault` — when skill involves knowledge management
