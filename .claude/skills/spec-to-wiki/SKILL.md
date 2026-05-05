---
name: spec-to-wiki
description: Convert raw specifications to Obsidian wiki format with wikilinks, frontmatter, and index updates. Use when adding a new spec to the knowledge base, or when regenerating wiki view after spec changes. Maintains raw as source of truth, wiki as navigable view.
---

# Skill: Spec to Wiki Conversion

## Purpose

Transform raw spec file into Obsidian-optimized wiki entry that enables graph navigation and cross-referencing.

## Core Rule

- `specs/` = source of truth (raw format, free to edit)
- `obsidian-vault/wiki/specs/` = derived view (Obsidian format)
- Raw changes → regenerate wiki (preserving human additions where possible)
- **Never edit `obsidian-vault/raw/`** (project-wide constraint, see CLAUDE.md hard rules)

## When to Use

- New spec lands in `specs/` and has no wiki entry yet
- Existing spec edited → wiki view drifts
- Periodic vault audit catches missing wikilinks / stale frontmatter

## When NOT to Use

- Quick draft notes (use `obsidian-vault/wiki/scratch/` instead)
- Non-spec docs (use `obsidian-vault` skill for general note creation)

## Process (7 steps)

1. **Read raw spec completely** — frontmatter (spec_id/tier/status), Part A/B/C structure, all mentioned terms.
2. **Identify linkable items** — glossary terms (`[[term]]`), spec cross-refs (`[[SPEC-...]]`), bounded contexts (`[[bc/...]]`), entity mentions (companies, tickers, KOLs).
3. **Generate wiki file** at `obsidian-vault/wiki/specs/tier<N>-<type>/<spec_id>-<slug>.md` — see `references/templates.md` § Wiki File for full frontmatter + body schema.
4. **Apply wikilinks** — first mention only per doc; never inside code blocks; see `references/templates.md` § Wikilink Rules.
5. **Create missing stubs** — for entities/concepts mentioned but no page; see `references/templates.md` § Stub Template.
6. **Update index + log** — append to `obsidian-vault/wiki/_index.md` + `_log.md`; see `references/templates.md` § Index & Log.
7. **Regeneration** when raw changes — diff-based update preserves human additions; see `references/templates.md` § Regeneration.

## Wikilink Boundaries (concise)

- ✅ First mention of glossary/spec/entity term in this doc
- ✅ Cross-references between specs and bounded contexts
- ❌ Inside ` ```code``` ` blocks
- ❌ Subsequent mentions in same doc (link spam)
- ❌ Generic terms not in glossary

## Anti-Patterns

- Wikilink inside code blocks
- Linking every single mention (link pollution)
- Overwriting wiki without diff-preserving human additions
- Creating wikilinks to non-existent pages without stub
- Skipping `_index.md` / `_log.md` updates

## Do

- First-mention linking per doc
- Aggressive stub creation (empty stub > missing link)
- Diff-based update to preserve human curation
- Frontmatter consistent with `references/wiki-template.md` schema

## Related

- `obsidian-vault` — base Obsidian interactions
- `spec-dual-layer` — understanding spec structure being converted
- `ubiquitous-language` — glossary drives link candidates
