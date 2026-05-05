---
name: obsidian-vault
description: Search, create, and manage notes in the StockForge Obsidian vault with wikilinks, frontmatter, and index maintenance. Use when adding content to the knowledge base, navigating entities/concepts, or maintaining the raw/wiki separation. Adapted from mattpocock/skills, MIT licensed. Extended with raw/wiki pattern from Karpathy LLM Wiki.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Skill: Obsidian Vault Management

## Purpose

Maintain `obsidian-vault/` as a navigable knowledge graph for Vietnamese stock market research.

## Core Pattern: Raw vs Wiki

```
obsidian-vault/
├── raw/          IMMUTABLE — source materials. Agent READS only. Never writes.
├── wiki/         AGENT-OWNED — knowledge base
│   ├── _index.md, _log.md
│   ├── specs/, entities/, concepts/, sources/, thesis/, synthesis/
└── CLAUDE.md     Schema & conventions
```

**Golden rule**: Never write to `raw/`. Ever. If source needs correction, ask human to edit raw/ then re-ingest. Hard-enforced via `.claude/settings.json` deny rule.

## When to Use

- Adding a new note to vault
- Converting a spec to wiki format (use `spec-to-wiki` skill)
- Ingesting a research source into wiki
- Creating entity / concept stub (company, KOL, market pattern)
- Updating index after additions

## When NOT to Use

- Modifying `raw/` (never — immutable)
- Technical / engineering docs (use `docs/` at repo root)
- Session-specific memory (use `agent-workspace/memory/`)

## Note Types

| Type | Path | Used for |
|---|---|---|
| **Entity** | `wiki/entities/<slug>.md` | Company, stock, KOL, market, sector |
| **Concept** | `wiki/concepts/<slug>.md` | Framework, pattern, signal, theory |
| **Source** | `wiki/sources/<slug>.md` | Summary of ingested article / report / KOL transcript (links to `raw/` via `raw_path`) |
| **Thesis** | `wiki/thesis/<YYYY-MM-DD-ticker>.md` | Investment thesis entry (live tracking in `agent-workspace/memory/thesis-log/`) |
| **Synthesis** | `wiki/synthesis/<slug>.md` | Cross-source analysis, sector overview, pattern analysis |
| **Spec** | `wiki/specs/tier<N>-<type>/<spec-id>-<slug>.md` | Wiki view of a spec (use `spec-to-wiki` skill) |

Frontmatter templates for all six in `references/note-templates.md`.

## Wikilink Rules

### Create wikilink when

- First mention of an entity / concept in a doc
- Reference to another spec, BC, or domain term (from glossary)
- Reference to a stock ticker

### Don't create when

- Subsequent mentions in same doc (avoid pollution)
- Inside code blocks (plain text)
- In frontmatter (only specific list-typed fields like `source_mentions`, `related_concepts`)

### Stub creation

If a wikilink points to a non-existent note → create a stub immediately. Stubs preserve backlinks and let search surface that the term exists. Better than missing pages.

## Index Maintenance

`wiki/_index.md` is the top-level catalog. Append to relevant section every ingest. Keep it tidy — agent updates, human reads.

`wiki/_log.md` is append-only ingestion log: timestamp + note path + 1-line summary per add.

Full `_index.md` skeleton + structure in `references/note-templates.md` § Index template.

## Search Patterns

| Goal | Tool |
|---|---|
| By ticker | `Grep "VCB\|Vietcombank" wiki/ --type md` |
| By type / status | Obsidian Bases query on `type:` + `status:` frontmatter |
| Backlinks | Open note in Obsidian → "Linked mentions" panel |

## Validation Pre-Conditions

- Target path is under `wiki/`, NEVER `raw/`
- Frontmatter has `type:` field matching note type table
- `created:` and `last_updated:` are ISO dates
- Every wikilink target either exists or is created as a stub in the same operation
- `wiki/_index.md` updated for first-of-kind notes
- `wiki/_log.md` appended on every ingest

## Anti-Patterns

**Don't**:
- Edit `raw/` (violates core pattern + harness deny rule)
- Skip wikilink creation (loses navigability)
- Create duplicate entity pages (one per company / KOL)
- Dump long content inline (split into connected notes)
- Forget to update index / log

**Do**:
- Aggressive wikilinking on first mention
- Create stubs rather than leave broken links
- Keep notes focused (one concept per file)
- Use frontmatter consistently (enables Obsidian Bases queries)
- Update index + log every ingest

## Smoke Test

For task "ingest a CafeF article on VCB Q1 2026 earnings":

Expected output:
- Create `wiki/sources/2026-04-vcb-q1-earnings-cafef.md` with frontmatter (`type: source`, `source_url`, `raw_path`, `tickers_mentioned: [VCB]`)
- Reference `[[entities/vcb]]` in body — if missing, create stub
- Append to `wiki/_index.md § Sources` and `wiki/_log.md`
- Source body extracts key claims with quotes; numbers come from article verbatim (I-S2)
- Never edit `raw/research-sources/2026-04-vcb-q1-earnings.pdf`

If the proposal touches `raw/`, suggests an LLM-summarized number, or skips wikilink/index update → reject.

## Attribution

Base: `mattpocock/skills` `obsidian-vault` (MIT licensed). Extended with raw/wiki pattern from Karpathy's LLM Wiki gist. Customized for StockForge investment research.

## See Also

- `references/note-templates.md` — full frontmatter blocks per type + index template + search examples
- `spec-to-wiki` SKILL.md — workflow for converting specs to wiki notes
- `ubiquitous-language` SKILL.md — drives wikilink candidates from glossary
- `obsidian-vault/CLAUDE.md` — vault-local schema rules
