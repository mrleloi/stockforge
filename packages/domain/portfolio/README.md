# BC-9: Portfolio & Action

> Watchlist + alerts + position sizing + risk management. Position sizing & risk are DETERMINISTIC code (Charter Principle 10); LLM cannot override.

**Responsibility**: Watchlist, alerts, position sizing, risk management, personal bias tracking.

**Aggregates**: Watchlist, Position, RiskRule, Alert, PersonalBias, Decision

**Storage**: Postgres + append-only Decision log (immutable audit trail).

**Hard rules** (per CLAUDE.md + invariants.md I-S*):
- Maximum position size, sector concentration, stop-loss rules are CODE-ENFORCED — LLM cannot override
- Every Decision in append-only log with full context (thesis_id, signals, as-of date, outcome pending)
- PersonalBias log tracks user's own biases discovered through dogfooding (Charter ultimate signal: "When my gut says buy XYZ, check what StockForge says first")
- Conflict detection: if user already owns ticker, flag confirmation-bias risk before suggesting

**Phase 1 sub-scope** (locked 6 months, per Charter):
- Long-only equity (no derivatives, no shorting, no day trading)
- VN30 + mid-cap (vốn hóa 2K-50K tỷ VND)
- Holding 1-month minimum, 6-24 month preferred
- Position 5-15% per stock

**LLM role**: Generate alert messages (qualitative); NEVER numbers. Risk computations through deterministic Python services.
