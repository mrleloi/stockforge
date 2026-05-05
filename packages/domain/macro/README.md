# BC-4: Macro & Policy

> Tier 1 (deterministic indicators) + Tier 2 (regulatory documents) — VN-specific policy timing matters more than US-pattern overlay.

**Responsibility**: Macro indicators (GDP, CPI, lãi suất), regulatory documents, policy changes, geopolitical events.

**Aggregates**: MacroIndicator, PolicyDocument, RegulatoryEvent, MacroRegime

**Storage**: TimescaleDB (indicators) + document store (policy text + R2 raw PDFs).

**Sources** (Phase 1):
- SBV (State Bank of Vietnam) — interest rate, FX policy
- MoF (Ministry of Finance) — fiscal policy
- Quốc hội / Chính phủ document portals — laws/regulations
- General Statistics Office VN — GDP, CPI, IIP, exports

**LLM role**: Classify policy direction (TIGHTENING | LOOSENING | NEUTRAL) and tag affected sectors. NEVER generate numbers.

**Update cadence**: macro indicators daily 08:00; regulatory every 4 hours.
