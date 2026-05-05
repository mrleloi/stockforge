# Schema Patterns — Full SQL Templates

> Reference companion to `../SKILL.md`. Contains verbatim SQL for the patterns referenced by the skill.

## Aggregate Root Table

```sql
CREATE TABLE theses (
  -- Identity
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- References
  ticker TEXT NOT NULL,
  user_id UUID NOT NULL,

  -- State
  status TEXT NOT NULL CHECK (status IN ('draft', 'active', 'closed')),

  -- Business content (JSONB for flexible structure)
  bull_case JSONB NOT NULL,
  bear_case JSONB NOT NULL,
  catalysts JSONB NOT NULL DEFAULT '[]',

  -- Calibration
  confidence_score NUMERIC(4,3) CHECK (confidence_score BETWEEN 0 AND 1),
  hit_rate_basis INT NOT NULL DEFAULT 0,  -- N past theses of this type

  -- Temporal
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  submitted_at TIMESTAMPTZ,
  closed_at TIMESTAMPTZ,

  -- Audit
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  version INT NOT NULL DEFAULT 1  -- optimistic locking
);

CREATE INDEX idx_theses_ticker ON theses(ticker, created_at DESC);
CREATE INDEX idx_theses_status ON theses(status) WHERE status IN ('draft', 'active');
```

## Point-in-Time Integrity (Fundamentals — I-S2)

Every fundamental data row MUST have BOTH dates:

```sql
CREATE TABLE financial_statements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticker TEXT NOT NULL,

  -- CRITICAL: point-in-time integrity (I-S2)
  period_end DATE NOT NULL,      -- what period this covers
  filing_date DATE NOT NULL,     -- when it became public knowledge

  -- Financials (all in VND million)
  revenue BIGINT,
  net_income BIGINT,
  total_assets BIGINT,
  total_equity BIGINT,

  -- Source
  source TEXT NOT NULL CHECK (source IN ('vnstock', 'fiinpro', 'manual')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(ticker, period_end, filing_date, source)
);

CREATE INDEX idx_financial_ticker_period ON financial_statements(ticker, filing_date DESC, period_end DESC);
```

Backtest query MUST use `filing_date` filter:

```sql
-- CORRECT: filters by when data was known (avoids look-ahead bias)
SELECT * FROM financial_statements
WHERE ticker = 'VCB'
  AND filing_date <= '2024-03-31'::date
ORDER BY period_end DESC
LIMIT 1;

-- WRONG: would introduce look-ahead bias in backtest
-- SELECT * FROM financial_statements WHERE ticker = 'VCB' ORDER BY period_end DESC LIMIT 1;
```

## Event Log Table

```sql
CREATE TABLE domain_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  aggregate_id UUID NOT NULL,
  aggregate_type TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_version INT NOT NULL DEFAULT 1,
  payload JSONB NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  sequence_num BIGSERIAL NOT NULL
);

CREATE INDEX idx_events_aggregate ON domain_events(aggregate_type, aggregate_id, occurred_at);
CREATE INDEX idx_events_unpublished ON domain_events(occurred_at) WHERE published_at IS NULL;
```

## pgvector Semantic Search (Vietnamese)

```sql
CREATE TABLE article_embeddings (
  article_id UUID PRIMARY KEY REFERENCES news_articles(id) ON DELETE CASCADE,
  embedding vector(1536) NOT NULL,  -- OpenAI text-embedding-3-small
  model_version TEXT NOT NULL DEFAULT 'text-embedding-3-small',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- HNSW index for cosine similarity search
CREATE INDEX idx_article_embeddings_hnsw ON article_embeddings
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);
```

Semantic search query:

```sql
SELECT
  ae.article_id,
  1 - (ae.embedding <=> $1::vector) AS similarity
FROM article_embeddings ae
WHERE 1 - (ae.embedding <=> $1::vector) > 0.85
ORDER BY ae.embedding <=> $1::vector
LIMIT 10;
```

## TimescaleDB Hypertable + Continuous Aggregate

```sql
-- Market data hypertable
CREATE TABLE market_bars (
  time TIMESTAMPTZ NOT NULL,
  ticker TEXT NOT NULL,
  open NUMERIC(15,2) NOT NULL,
  high NUMERIC(15,2) NOT NULL,
  low NUMERIC(15,2) NOT NULL,
  close NUMERIC(15,2) NOT NULL,
  volume BIGINT NOT NULL,
  foreign_buy_volume BIGINT,
  foreign_sell_volume BIGINT
);

SELECT create_hypertable('market_bars', 'time');

CREATE UNIQUE INDEX idx_market_bars_ticker_time ON market_bars(ticker, time DESC);

-- Continuous aggregate for daily OHLCV
CREATE MATERIALIZED VIEW market_bars_daily
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', time) AS day,
  ticker,
  FIRST(open, time) AS open,
  MAX(high) AS high,
  MIN(low) AS low,
  LAST(close, time) AS close,
  SUM(volume) AS volume
FROM market_bars
GROUP BY day, ticker;
```

## Migration Conventions

### File naming

`apps/api/migrations/YYYYMMDDHHMMSS_description.sql`

Example: `20260420100000_create_theses_table.sql`

### Structure

```sql
-- Up migration
BEGIN;

CREATE TABLE theses (/* ... */);
CREATE INDEX /* ... */;

COMMIT;

-- Down migration (in comment or separate file)
-- BEGIN;
-- DROP TABLE theses;
-- COMMIT;
```

### Rules

- Always wrap in `BEGIN`/`COMMIT`
- Idempotent where possible (`IF NOT EXISTS`)
- No data manipulation in schema migrations (use separate data migration)
- Test up and down
- One logical change per migration

## Query Patterns

### Explicit column list

```python
# Good
rows = await db.fetch("""
    SELECT id, status, created_at
    FROM theses
    WHERE ticker = $1 AND status = 'active'
    ORDER BY created_at DESC
""", ticker)

# Bad — SELECT *
# rows = await db.fetch("SELECT * FROM theses WHERE ...")
```

### Prepared statements (asyncpg)

```python
# Use parameterized queries always
stmt = await conn.prepare("SELECT * FROM theses WHERE id = $1")
row = await stmt.fetchrow(thesis_id)

# Never string interpolation
# await conn.fetch(f"SELECT * FROM theses WHERE id = '{thesis_id}'")  # SQL INJECTION
```
