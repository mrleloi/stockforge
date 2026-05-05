# write-a-skill — Templates & Examples

Companion to `SKILL.md`. Concrete templates referenced from each section.

## SKILL.md Skeleton

```markdown
---
name: skill-name-kebab-case
description: One sentence. Specific keywords. When to use. Why it matters.
---

# Skill: Human-Readable Name

## Purpose
What this skill does. Why it exists. One paragraph.

## When to Use
- Specific trigger 1
- Specific trigger 2

## When NOT to Use
- Wrong context 1
- Wrong context 2

## Process / Content
Step-by-step or structured explanation of the skill.

## Examples
Good examples. Bad examples. Correct patterns.

## Anti-Patterns
Common mistakes to avoid.

## Related Skills
Cross-references to other skills.
```

## Description Examples

### Bad

```yaml
description: Helps with stuff
```

Too vague. Won't trigger reliably.

### Good

```yaml
description: Extract structured claims from unstructured sources with citation
  integrity. Use when building extraction pipelines, parsing news articles or KOL
  transcripts, or anywhere claims are created from raw data. Ensures every claim
  has source_url, extracted_at, confidence, and verified attribution.
  Enforces no-LLM-math invariant (I-S1).
```

Specific keywords. Clear "use when". Mentions what's ensured. StockForge-specific.

### StockForge-specific patterns

Lead phrases that match user vocabulary:

- "Extract structured claims..." → matches "extract claims from KOL"
- "Implement FastAPI routers following StockForge conventions..." → matches "build new endpoint"
- "Design Postgres schemas with pgvector..." → matches "add migration"
- "Build reliable web crawlers..." → matches "scrape CafeF"

Always end with the invariant: "Enforces no-LLM-math (I-S1)" / "Every claim cites source + as_of (I-S2)" / etc.

## Frontmatter Fields (full reference)

| Field | Required | Notes |
|---|---|---|
| `name` | yes | kebab-case; matches folder name |
| `description` | yes | 1-2 sentences; auto-discovery driver |
| `allowed-tools` | optional | restrict to specific tools (e.g. `[Read, Glob, Grep]` for analysis-only) |

`allowed-tools` is the only optional field — when set, the skill cannot use other tools even if invoked.

## Common Failure Modes (when writing a skill)

1. **Drafting at the ceiling** — D1 violation within 2-3 amendments. Use 20% reserve.
2. **Code-dumping into SKILL.md** — push code to `examples/<name>.py` or `references/templates.md` instead.
3. **Skipping "When NOT to use"** — leads to mis-triggering on adjacent contexts.
4. **No anti-patterns section** — useful negative examples often clarify the positive case.
5. **Duplicating with sibling command** — `/<name>` and `<name>` skill must not have overlapping bodies (L-S14-2).
