# /spec-to-wiki — Convert Raw Spec to Obsidian Wiki Format

> Transform a raw spec into an Obsidian-optimized wiki entry with wikilinks and frontmatter.

## When to Use

- After `/spec-author` creates a spec
- When a spec changes significantly (regenerate wiki view)
- When retrofitting an existing spec into the wiki

## Input

`$ARGUMENTS` — path to raw spec file (e.g., `specs/tier2-feature/001-validate-investment-thesis.md`).

## Process

The full conversion procedure lives in the **`spec-to-wiki` skill** (`.claude/skills/spec-to-wiki/SKILL.md`). Do not duplicate it here. The command's role is to invoke + report.

High-level flow:

1. Read raw spec; parse Part A / B / C structure.
2. Identify entities for linking (glossary terms, other SPEC IDs, BCs, key concepts, tickers, companies).
3. Resolve each mention against `obsidian-vault/wiki/{entities,concepts}/`. Create stubs for any missing target before linking.
4. Generate wiki version at `obsidian-vault/wiki/specs/tier<N>-<type>/<NNN>-<slug>.md` with enriched frontmatter (`type`, `tier`, `spec_id`, `status`, `bounded_contexts`, `related_specs`, `ubiquitous_language_terms`, `source` link).
5. Replace glossary terms with `[[term]]` wikilinks; cross-spec references with `[[SPEC-...]]`; entity mentions with `[[entities/...]]`.
6. Update `wiki/_index.md` (specs section) + append to `wiki/_log.md` (one line per ingest).
7. **Diff-mode for re-runs** — if wiki version exists, diff against raw and preserve human-added wikilinks; do NOT blindly overwrite.

Frontmatter shapes for wiki note + stubs are in `.claude/skills/spec-to-wiki/references/` (or, transitively, in `obsidian-vault/wiki/CLAUDE.md`).

## Output Report

After conversion, return:

```markdown
# Spec Converted to Wiki

## Source
[raw spec path]

## Wiki Version Created
[wiki path]

## Entities Linked
- [[term1]] — existing
- [[term2]] — new stub created

## Stubs Created
- `entities/new-term.md`
- `concepts/new-concept.md`

## Index Updated
Added entry under `Specs § Tier <N>`.

## Log Appended
See `wiki/_log.md` latest entry.

## Next Steps
1. Open Obsidian, navigate to new spec
2. Review linkages in graph view
3. Expand stub pages that are important
4. Connect related concepts if not auto-linked
```

## Wiki vs Raw — When to Edit Which

- **Edit raw** when content / business rules / decisions change, or on version bump
- **Edit wiki** when adding wikilinks the agent missed, cross-references, or status updates
- **Regenerate wiki from raw** when the raw spec significantly changed and you want a clean state

Raw is the source of truth; wiki is the navigable view.

## Anti-Patterns

**Don't**:
- Overwrite the wiki version without diff check (loses human additions)
- Create wikilinks to non-existent concepts (create stubs first)
- Skip frontmatter (breaks Obsidian Bases queries)
- Duplicate content between raw and wiki (raw is source)
- Re-author the conversion procedure here — it lives in the skill

**Do**:
- Use wikilinks liberally for discoverability
- Create stubs proactively
- Keep frontmatter consistent with the schema in `obsidian-vault/wiki/CLAUDE.md`
- Update `_index.md` + `_log.md` every ingest

## See Also

- `.claude/skills/spec-to-wiki/SKILL.md` — full conversion procedure + diff-mode rules
- `.claude/skills/obsidian-vault/SKILL.md` — note types + raw/wiki golden rule
- `obsidian-vault/wiki/CLAUDE.md` — vault-local schema authority
