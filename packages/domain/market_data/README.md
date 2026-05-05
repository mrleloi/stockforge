# BC-1: Market Data

> Tier 1 (Hard Data) — deterministic, zero LLM. See `specs/tier1-strategic/001-four-tier-signal-architecture.md` § B.1.

**Responsibility**: Time-series price/volume, foreign flow, intraday data, market microstructure.

**Aggregates**: Quote, Bar, ForeignFlow, OrderBook, MarketRegime

**Storage**: TimescaleDB hypertables (compression after 7 days; full price history retention).

**Sources** (Phase 1):
- vnstock — historical EOD, OHLCV, basic fundamentals
- TCBS API — semi-public quotes, foreign flow
- VnDirect / SSI public APIs — backup sources

**Update cadence**:
- Intraday: every 15 min during market hours (9:00-15:00 VN time)
- EOD: 16:00 daily

**LLM role**: NONE. Pure code; no Pydantic in domain (dataclasses + enum only).
