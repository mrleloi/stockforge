# BC-8: Analysis & Thesis

> Cross-tier synthesis — multi-perspective adversarial analysis, thesis lifecycle, post-mortem. Confluence engine lives here.

**Responsibility**: Multi-perspective adversarial analysis, thesis lifecycle, post-mortem.

**Aggregates**: Thesis, BearAnalysis, BullAnalysis, Synthesis, PostMortem, Catalyst, ConfluenceAssessment

**Storage**: Postgres + Markdown files in `agent-workspace/memory/thesis-log/` (immutable append-only).

**LLM role**: Multi-perspective adversarial agents (bear, bull, critic, quant, behavior, manager). Output is structured trade-off matrix — NEVER single buy/sell score (Charter Principle 2).

**Hard rules**:
- Every thesis MUST include substantive bear case (≥3 distinct points; charter principle 3 + I-S10)
- Confidence claims MUST trace to historical hit rate from calibration database (charter principle 8)
- Output framed as "thesis exploration" / "consideration" — NEVER "recommendation" / "buy" / "sell" (I-S35)
- Thesis revoked → must enter post-mortem (calibration feedback loop)

**Confluence engine**: combines tier signals into ConfluenceAssessment per `specs/tier1-strategic/001-four-tier-signal-architecture.md` § A.3 patterns (Early Opportunity / Likely Top / Manufactured Pump / Forgotten Value).

See `specs/tier2-feature/001-validate-investment-thesis.md` + `004-multi-perspective-adversarial-agents.md`.
