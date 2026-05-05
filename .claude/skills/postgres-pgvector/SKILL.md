---
name: postgres-pgvector
description: Design Postgres schemas with pgvector and TimescaleDB for StockForge. Use when creating migrations, designing tables, writing queries. Covers vector embeddings for semantic search on Vietnamese text, time-series for price/sentiment data, JSONB vs structured columns.
allowed-tools: [Read, Glob, Grep, Bash, Edit, Write]
---

# Skill: Postgres + pgvector + TimescaleDB

## Purpose

Consistent schema patterns leveraging Postgres 16 extensions for Vietnamese stock market data. Encodes structural-vs-JSONB rules, point-in-time integrity for fundamentals (I-S2), and pgvector indexing for Vietnamese semantic search.

## When to Use

- Authoring a new migration in `apps/api/migrations/`
- Designing an aggregate persistence schema
- Choosing between JSONB and structured columns
- Adding semantic search via embeddings
- Modeling time-series (prices, sentiment, KOL recommendation streams)

## When NOT to Use

- Pure domain layer design — see `ddd-tactical-patterns` first; persistence is downstream
- Phase 1 (Streamlit-direct) prototyping — defer migration discipline; just write SQLite or pickled CSV
- Frontend / dashboard schemas — N/A

## Extensions

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";    -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Fuzzy text search (Vietnamese)
CREATE EXTENSION IF NOT EXISTS "vector";       -- pgvector for embeddings
CREATE EXTENSION IF NOT EXISTS "timescaledb";  -- Time-series (prices, sentiment)
```

## Decision Rules

### Structured column vs JSONB

| Use **structured** when | Use **JSONB** when |
|---|---|
| Field is queried in WHERE | Schema differs per row |
| Field is indexed | Archive / audit data |
| Field has CHECK / NOT NULL / FK | Document returned together |
| Field is critical business state (ticker, dates, amounts) | No indexed sub-field access needed |

Hard rule: ticker, dates, status, amounts → ALWAYS structured. Never JSONB.

### Time-series vs row table

- High-cardinality time-stamped (prices, volumes, sentiment, foreign flow) → TimescaleDB hypertable
- Aggregates / one-shot per period (financial statements) → regular table with `period_end + filing_date`
- Domain events → regular table with `sequence_num BIGSERIAL` for ordered replay

### Vector index

- pgvector cosine similarity → HNSW (`m=16, ef_construction=64`)
- Embedding dimension fixed per model_version; never change without migration

## Process — designing a new table

1. **Identify aggregate boundary** (per `ddd-tactical-patterns`). One table per aggregate root; child tables FK back.
2. **List queryable fields** — these become structured columns with appropriate indexes.
3. **List archival/audit fields** — these go in JSONB.
4. **Add point-in-time fields** if data describes a past period: `period_end DATE` + `filing_date DATE` (I-S2 requirement — backtests filter on `filing_date <= ...`).
5. **Add temporal audit**: `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`, `updated_at`, `version INT` for optimistic locking on aggregate roots.
6. **Add source attribution** if multi-provider: `source TEXT NOT NULL CHECK (source IN ('vnstock','fiinpro','manual'))`. Required for I-S2 disagreement surfacing.
7. **Index queryable WHERE columns + ORDER BY ranges**; do NOT index every column.
8. **Wrap in BEGIN/COMMIT** in migration; one logical change per file; test up + down.

See `references/schema-patterns.md` for full SQL templates (aggregate root, point-in-time, event log, pgvector, hypertable, continuous aggregate).

## Anti-Patterns

**Don't**:
- Put business logic in triggers — use application layer
- `SELECT *` in production code — explicit column list always
- Skip migration for "quick schema change" — every schema change is a migration
- Index everything "just in case" — slows writes
- Store timestamps without TZ — always TIMESTAMPTZ
- Use JSONB for ticker / dates / status / amounts — they're queryable
- Query fundamentals without `filing_date` filter in backtest (I-S2 violation)
- String-interpolate user input into SQL (injection)

**Do**:
- Structured columns for queryable fields; JSONB for flexible/archival
- HNSW index for pgvector cosine similarity
- Prepared statements / parameterized queries always (asyncpg `$1`)
- Transactions for multi-statement logic
- `version` column for optimistic locking on aggregates
- TIMESTAMPTZ for all timestamps

## Validation Pre-Conditions

- Migration file matches `apps/api/migrations/YYYYMMDDHHMMSS_description.sql`
- Migration is idempotent (`IF NOT EXISTS` on extensions, indexes)
- Every fundamental-data table has BOTH `period_end` AND `filing_date`
- Every multi-provider table has `source` CHECK constraint
- Every embedding table has `model_version` column

## Smoke Test

For a sample task — "design table for KOL recommendation tracking":

Expected output shape:
- One aggregate root `kol_recommendations` table with structured: id, kol_id, ticker, action ('buy'|'sell'|'hold'), recommended_at TIMESTAMPTZ, source URL, period of validity
- JSONB for: original_post_text, extraction_metadata
- Index: `(kol_id, recommended_at DESC)` + `(ticker, recommended_at DESC)`
- Point-in-time: `recommended_at` (when the rec was published) + `extracted_at` (when our pipeline saw it)

If the proposal includes both audit timestamps + structured queryable fields + JSONB only for free-form text → skill is functional.

## See Also

- `references/schema-patterns.md` — full SQL templates (aggregate, point-in-time, event log, pgvector, TimescaleDB)
- `ddd-tactical-patterns` SKILL.md — aggregates that map to these tables
- `fastapi-module` SKILL.md — repositories accessing these tables (Phase 2+)
- `agent-workspace/constitution/invariants.md` § I-S2 — citation + as-of date requirement
- `PROJECT_CHARTER.md` § Technical Foundation — stack rationale
