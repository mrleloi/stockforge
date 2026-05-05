# write-a-skill — Best Practices (S16 amendment)

> Companion to `SKILL.md`. Lessons from S14 progressive-disclosure refactor of top-8 D1 violators.

## L-S14-1 — First-draft compression reserve

When refactoring an existing skill that violates D1 (LOC ceiling 150 for skills, 120 for commands, 200 for agents), aim for a first-draft target **20% under** the ceiling, not at the ceiling. Reason: subsequent additions (best practices learned during use, cross-references to new sibling skills, examples) accumulate. A skill that lands AT 150 will violate D1 within 2-3 amendments.

**Concrete target**: skill SKILL.md first-draft = 110-130 LOC; budget 20-40 LOC reserve for amendments. Move depth to `references/<topic>.md` early; keep SKILL.md as the orientation surface.

**Anti-example**: a skill drafted at 148 LOC "to fit" the 150 ceiling. Within one amendment cycle it lands at 165 = D1 violation. Refactor cost = re-split into references/. Net cost > if drafted at 120 with planned references/ companions.

**Correct example**: `try-n-approaches/SKILL.md` first draft = 120 LOC; budget for amendments = 30 LOC; references for `output-template.md` + `metric-patterns.md` carry depth.

## L-S14-2 — Skill vs Command — Responsibility Split

Skills (`.claude/skills/<name>/SKILL.md`) and slash commands (`.claude/commands/<name>.md`) overlap in form (both markdown procedures) but should NOT overlap in body content. Per `proposals/architecture-amendment.md` § Slash Command vs Skill:

- Skill = agent-facing procedure auto-discovered by description match
- Command = user-facing trigger; body delegates to skill where possible

**Anti-pattern**: writing a `<name>` skill and `/<name>` command with overlapping 80-line bodies. When the rule changes (e.g., AskUserQuestion 4-question max), only one gets updated. The duplication multiplier doubles maintenance cost; drift is inevitable.

**Correct example**: `/grill-me` command body = short user-facing trigger; the procedure body lives in `grill-maximization` skill, which the command references via Skill tool invocation.

**When in doubt**: if the procedure is "what to do when context X auto-matches" → skill. If it's "what to do when user types `/<name>`" → command. If both apply: skill carries body; command is entry point.

## L-S14-1 corollary — references/ as expansion buffer

When a skill's content grows past first-draft compression reserve, the right move is to extract topical sub-sections to `references/<topic>.md` (no D1 ceiling on references/) and replace inline content with a one-line pointer. Don't compress at the cost of clarity.

**Example structure**:
```
.claude/skills/<name>/
├── SKILL.md                # ≤150 LOC; orientation + when-to-use + core rules
├── references/
│   ├── best-practices.md   # Lessons learned (this file pattern)
│   ├── output-template.md  # Detailed output schema
│   └── examples.md         # Concrete examples
```

Agent loads SKILL.md first; references/ on-demand only.
