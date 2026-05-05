# /drill-me — Interactive Ubiquitous Language Extraction

> Interrogate the user about a domain area to build/refine the ubiquitous language glossary.
> Inspired by mattpocock/grill-me, customized for DDD purposes. Body delegates to `ubiquitous-language` skill for term-definition substance.

## When to Use

- Before implementing a new feature area (extracts domain terms first)
- When new domain vocabulary emerges in conversation
- When glossary and code are drifting (run periodically)
- At the start of a new bounded context

## Input

`$ARGUMENTS` — domain area to drill on (e.g., `KOL influence tracking`, `pump detection signals`, `thesis lifecycle`).

If no argument, ask user what domain area they want to explore.

## Process (8 steps)

1. **Load current state** — read `agent-workspace/ubiquitous-language/glossary.md` + `domain-mapping.md` + any existing specs in the domain. Identify already-defined terms, undefined concepts, potential synonyms.

2. **Opening question** — frame: "Let's drill down on [domain area]. I'll ask structured questions to build out the ubiquitous language. Your answers become the canonical domain vocabulary — both human and agent will use these exact terms going forward."

3. **Structured question sequence** — ONE question at a time; adapt next question on response. Six phases:
   - **A. Nouns** — main "things" in domain; what each "always has"; critical distinctions between similar things
   - **B. Verbs** — key actions/operations; triggers + expected outcomes; actions that look similar but differ
   - **C. Lifecycle** — states for key entities; allowed/forbidden transitions; invariants per state
   - **D. Relationships** — A-to-B cardinality (1:1 / 1:N / N:M); ownership vs reference
   - **E. Conflict check** — compare new terms with existing glossary; force explicit resolution of every potential synonym
   - **F. Boundary check** — which of 9 BCs owns each term

4. **Real-time draft entries** — as user answers, build draft per `ubiquitous-language` skill schema (BC / Definition / Lifecycle / Not to confuse with / Code / Introduced). Show draft, ask "does this capture it accurately?".

5. **Drift check** — for each proposed term, grep existing code (`grep -rn "TermName\|term_name" packages/ apps/ --include="*.py"`). If matches: surface contradictions for resolution.

6. **Write to glossary** — append new terms to `glossary.md` (Core Domain or BC-specific section). Renames go to "Stop List". Append entry to `drift-log.md`.

7. **Suggest code audit** — if existing code uses terms inconsistently with new glossary, list specifically what needs to change; recommend `/ul-audit` follow-up.

8. **Output summary** — Domain Explored / Terms Added / Terms Refined / Terms Deprecated / Conflicts Resolved / Files Updated / Recommended Follow-up.

## Anti-Patterns

- Asking all questions at once (overwhelming, loses quality)
- Accepting vague definitions ("it's like X but different") — push for specifics
- Letting user use same term for two concepts (force differentiation)
- Skipping conflict check with existing glossary
- Writing to glossary without user confirmation of drafts

## Do

- Go slowly, one concept at a time
- Insist on clear distinctions
- Surface conflicts proactively
- Use real examples from user's domain
- Connect new terms to existing terms

## Related

- `ubiquitous-language` skill — passive analysis variant; this command is the interactive variant
- `/ul-audit` command — code-vs-glossary drift detector; runs after this session
- `agent-workspace/ubiquitous-language/glossary.md` — output target

Full term-definition schema, drift-log entry template, and extraction output format: `.claude/skills/ubiquitous-language/references/templates.md`.
