# Obsidian Vault — Claude Instructions

> Loaded when agent is operating inside `obsidian-vault/`.

## Hard rules

- **NEVER edit `obsidian-vault/raw/`.** Immutable ingestion store. All derivative writes go to `wiki/`.
- **Every wiki page has frontmatter** with at minimum: `title`, `type`, `source_urls[]`, `as_of_date`, `bc` (owning bounded context).
- **Every number has a source_url + as_of_date** inline. No un-cited numbers (I-S1, I-S2).
- **Bear case required** on every thesis page in `wiki/entities/*` (I-S10).
- **Framing** — wiki prose says "exploration / consideration", never "recommendation / buy / sell" (I-S35).

## Directory map

- `raw/conversations/` — copy-pasted Claude/GPT chats, interviews. Read-only.
- `raw/evidence/` — snapshots, PDFs, transcripts. Read-only.
- `raw/research-sources/` — primary source dumps (10-K-equivalents, BCTC, etc.). Read-only.
- `wiki/concepts/` — domain concepts (e.g., `owner-earnings.md`, `moat.md`).
- `wiki/entities/` — one file per tracked ticker or KOL.
- `wiki/patterns/` — reusable market setups with outcome log.
- `wiki/playbooks/` — personal decision playbooks (e.g., "when Tier-4 heats up before T1+T2").
- `wiki/synthesis/` — cross-entity analyses.
- `wiki/specs/tier{1,2,3}-*/` — mirror of `/specs/` tree for Obsidian link-graph use.

## Update pattern

- New raw source arrives → drop file under `raw/<category>/` verbatim, set as read-only.
- Claim extracted from raw → create/update corresponding `wiki/` page; link back to `raw/` file via relative path.
- Conflict between claims → add a "Contradictions" section on the entity page with both sources.

## Links

- `_index.md` — entry point.
- `_log.md` — append-only ingestion log.
