---
name: ubiquitous-language
description: Extract a DDD-style ubiquitous language glossary from the current conversation or domain area. Use when starting work on a new bounded context, when new domain terms emerge, or when verifying consistency between business language and code. Adapted from mattpocock/skills, MIT licensed.
---

# Skill: Ubiquitous Language

## Purpose

DDD requires a shared vocabulary between domain experts and developers. This skill extracts and maintains that vocabulary for StockForge's Vietnamese stock market domain (9 BCs).

## When to Use

- Starting a new bounded context
- Processing conversation with domain expert about stock investing
- Reviewing conversation for undocumented terms
- Checking code for term drift from glossary
- Onboarding new contributor

## When NOT to Use

- Technical infrastructure (not domain-specific)
- External API integration (use their terminology)
- UI framework concerns (not DDD-relevant)

## Relationship to /drill-me

`/drill-me` is interactive — asks user questions, extracts language live. This skill is passive — analyzes existing content. Use both: `/drill-me` for new domains, this skill for ongoing maintenance.

## Extraction Process

1. **Identify candidates** — scan source for: domain nouns (`thesis`, `KOL recommendation`, `pump detection`), domain verbs (`submit thesis`, `extract recommendation`), state names (`active`, `incubating`, `dumped`), relationships (`KOL owns Channel`), rules (`Thesis can only be submitted when bear case is substantive`).

2. **Vet each candidate** — is it domain-specific or generic? Does it have precise business meaning? Could a Vietnamese investor define it clearly? Already in glossary under different name? Skip generic terms (`user`, `item`, `data`) unless they have specific domain meaning.

3. **Define accepted terms** with this 6-field schema (see `references/templates.md` for full example):
   - `Bounded context` (which of 9 BCs owns it)
   - `Definition` (clear, specific — what it is, what it's for)
   - `Lifecycle` (state transitions, if applicable)
   - `Not to confuse with` (similar-but-different terms)
   - `Code` (file path if implemented, or "not yet built")
   - `Introduced` (date, source conversation/spec)

4. **Drift detection** — for each term, `grep -rn "TermName\|term_name" packages/ apps/ --include="*.py"`. Flag if: code uses different name for same concept; multiple names exist for one term; term defined but unused in code.

5. **Resolve conflicts**:
   - **Rename code to match glossary** (most common; glossary is canonical)
   - **Update glossary to match code** (if code name is better; log to drift-log)
   - **Recognize two distinct concepts** (sometimes synonymous candidates are actually different — define both)

## Writing Good Definitions

**Bad**: `Thesis: An analysis of a stock.` (too vague)

**Good** (see `references/templates.md` § Term Definition Example for `Thesis`): includes BC, precise definition with adversarial-by-design constraint, lifecycle Draft → Active → [Closed | Abandoned] → PostMortem, and explicit "Not to confuse with" entries (ExtractedClaim, KolRecommendation, generic "Analysis").

## Common Pitfalls

- **Term explosion** — don't add every noun mentioned; reserve glossary for terms with precise meaning
- **Synonym tolerance** — never allow "Recommendation" + "KolRecommendation" for same thing; pick one, enforce
- **Over-abstraction** — "Signal" is too generic; be specific (`ExtractedClaim`, `KolRecommendation`, `SentimentScore`)
- **Missing lifecycle** — most domain entities have states; document them
- **No "Not to Confuse With"** — if term is easy to confuse with another, document the distinction explicitly

## Updating the Glossary

Every change to `agent-workspace/ubiquitous-language/glossary.md` must:

1. Update or add the term definition
2. Append entry to `agent-workspace/ubiquitous-language/drift-log.md` (date, change type, rationale, impact files)
3. If renaming, add entry to glossary "Stop List" (`Do NOT use` ↔ `USE instead`)

See `references/templates.md` § Drift Log + Stop List for entry templates.

## Output Format (extraction run)

When extracting language from a source, produce:

- Header (date, source ID/path)
- `Accepted [M]` — full definitions
- `Deferred [K]` — terms needing more domain-expert context
- `Rejected [L]` — too generic / technical infra / not domain
- `Conflicts Detected` — existing term vs candidate, resolution needed
- `Next Steps` — review with expert / update glossary / run /ul-audit / schedule /drill-me

Full template: `references/templates.md` § Extraction Output.

## Integration

- `/drill-me` — interactive interview (this skill processes results)
- `/ul-audit` — scans code against glossary (this skill drives definitions)
- `agent-workspace/ubiquitous-language/glossary.md` — output target
- `agent-workspace/ubiquitous-language/drift-log.md` — change log

## Attribution

Adapted from mattpocock/skills (`ubiquitous-language`), MIT licensed. Customized for StockForge DDD workflow with 9 bounded contexts and Vietnamese stock domain.
