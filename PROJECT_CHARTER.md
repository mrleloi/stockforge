# PROJECT CHARTER
## StockForge — Personal Investment Advisor for Vietnamese Stock Market

> **Status**: Immutable v1.0 — changes require explicit charter revision.
> **Scope of immutability**: Vision, principles, success criteria.
> **Things that do evolve**: Agent configs, specs, implementation, signal weights, eval sets.

---

## Vision

An AI-first investment research and advisory system that combines **quant fund methodology** with **Vietnam-specific edge sources** (KOL networks, crowd sentiment, pump pattern detection) to surface high-conviction opportunities in an inefficient market where logic-based screening alone is insufficient.

Primary user: project owner (self) + 3-5 trusted peers in Vietnamese investing community.

Primary goal: build a system that compounds edge over time through proprietary data accumulation, not through any single clever algorithm. After 12-24 months of dogfood, the system should be a genuine advisor I would pay money for if someone else built it.

Not a goal: high-frequency trading, replacing human judgment, becoming a SaaS in Year 1, beating frontier LLMs at general reasoning, providing licensed financial advice.

---

## The Core Insight (the why)

**Quant funds (Renaissance, Two Sigma, DE Shaw) win in efficient markets through clean data + execution speed + diverse alpha factors.** They don't use sentiment from Facebook/YouTube because at their scale it's noise, not signal — and in efficient markets it gets arbitraged away anyway.

**Vietnam stock market inverts this.** It is structurally inefficient:
- 85-90% retail investor share (vs 20-25% in US)
- Information asymmetry between sophisticated and retail crowd
- KOL/influencer recommendations measurably move prices
- "Đội lái" (pump operators) operate openly
- News and narrative cycles dominate over fundamentals for months at a time
- Foreign flow creates non-fundamental price pressure

In this market, **sentiment + influence + narrative tracking is signal, not noise**. And LLMs can process Vietnamese unstructured text at scale that was impossible before 2023.

This creates a **structural arbitrage**: apply quant methodology + LLM reasoning + sentiment/influence data layers that no commercial product offers for VN. Position not as "decision maker" but as **advisor + alert watcher + bias mirror**.

---

## The Craft Philosophy

Take the craft seriously. Build for personal use first, commercial second.

- Production-grade engineering standards from Day 1 (DDD + clean architecture + multi-loop discipline)
- Commercial extension kept as option, never as driver
- When self-use conflicts with hypothetical-future-SaaS, self-use wins
- Quality bar: I genuinely trust output enough to act on real money decisions
- Edge comes from compounding moats (proprietary data, calibration, personal bias log), not from any single feature

Reference models: Renaissance Technologies (data + iteration discipline), Bridgewater (principles-based decision making), personal Bloomberg Terminal (data density + analysis depth), Athletic.com (subscription-quality content for niche audience).

---

## Core Principles (non-negotiable)

1. **Evidence grounding** — every claim, every number traceable to source + as-of date. Hallucination in finance = bug, not stylistic issue.

2. **Structured output over narrative** — multi-criteria assessment, never single "buy/sell" score. Output is trade-off matrix.

3. **Adversarial by design** — bear + bull + critic + quant + behavior + manager perspectives. Never consensus from single agent.

4. **Proprietary data moat** — every news ingested, every KOL recommendation tracked, every thesis post-mortem'd compounds the edge. Raw data is sacred.

5. **Pattern transfer + local adaptation** — global setups (cyclical bottom, dividend value, GARP) + Vietnam-specific overlays (policy timing, foreign flow, narrative phase).

6. **Human-in-loop is the product** — augment thinking, never replace it. System should challenge user's gut instinct without overriding it.

7. **Dogfood mandatory** — if I don't use it weekly for real decisions, the feature gets killed. Self-use is the only validation that matters in Year 1.

8. **Calibration over confidence** — system tracks its own accuracy across signal types, never claims confidence it hasn't earned through hit rate.

9. **No LLM math** — LLM never generates numbers. All calculations through deterministic code with verified data inputs. LLM only interprets.

10. **Position sizing & risk management are deterministic** — code-enforced rules, LLM cannot override. Maximum position size, sector concentration, stop loss rules are immutable per session.

---

## The Four-Tier Signal Architecture

System operates on four distinct signal tiers, each with different lead time, reliability, and processing approach:

**Tier 1 — Hard Data (deterministic):** prices, volumes, fundamentals, foreign flow, macro indicators. Zero LLM, pure code. Lead time: hours-days.

**Tier 2 — Official Narrative (semi-structured):** mainstream financial news, broker reports, official company disclosures, government announcements. LLM extracts claims + classifies sentiment + detects contradictions. Lead time: real-time.

**Tier 3 — Influence Network (semi-structured):** YouTube channels, Facebook KOL pages, Telegram channels, podcasts. LLM transcribes + extracts recommendations + tags entities. Calibration database tracks each KOL's accuracy over time. Lead time: can lead by days.

**Tier 4 — Crowd Sentiment & Pump Detection (unstructured):** community forums, public chat groups, comments. LLM classifies sentiment + detects coordinated posting + identifies pump narratives + tracks narrative lifecycle phase. Lead time: typically lags price (signals exhaustion).

The combination — when Tier 1+2+3 agree before Tier 4 heats up = early opportunity; when Tier 4 hot but Tier 1+2 don't support = likely top — is the core analytical edge.

See `specs/tier1-strategic/001-four-tier-signal-architecture.md` for detailed tier specs.

---

## First Sub-Scope (locked 6 months)

**Vietnam stocks listed on HOSE/HNX/UPCoM**, specifically:
- VN30 + mid-cap (vốn hóa 2,000-50,000 tỷ VND) for primary coverage
- Long-only equity strategies (no derivatives, no shorting)
- Holding periods: 1-month minimum, 6-24 month preferred
- Position sizing per stock: 5-15% of portfolio

Out of scope (Year 1): derivatives, warrants (CW), short selling, cryptocurrency, fund products, foreign markets, day trading, automated execution.

---

## Honest Boundaries (what system does NOT do)

- **Predict price** — system predicts narrative phase, money flow direction, mispricing level. Never a price target with false precision.
- **Replace fundamental research** — surfaces opportunities, user must verify thesis before acting.
- **Execute trades** — pure research/alert tool. Execution stays manual.
- **Provide licensed financial advice** — personal research aid only. Output explicitly framed as "thesis exploration", not "buy/sell recommendation".
- **Time the market precisely** — works on phase identification (early/mid/late), not on tick-level timing.
- **Insider information** — uses only public sources. No paid leaks, no insider channels, no anything that crosses legal/ethical lines.

---

## Success Criteria

**Month 3 (end of Phase 1 — Foundation):**
- Tier 1 + 2 data pipeline operational for VN30
- 50 companies have basic dossier in wiki
- First 5 thesis recorded with formal structure
- Can run /thesis-validate on a stock end-to-end in <5 minutes

**Month 6 (end of Phase 2 — Edge Sources):**
- 30+ KOL channels tracked, calibration database has >100 recommendations with outcomes pending
- Tier 3 + 4 ingestion operational for top 100 stocks
- First detectable pump pattern caught (warning issued before public dump)
- 20+ thesis logged, first 5 hit 3-month review

**Month 9 (end of Phase 3 — Multi-perspective):**
- Bear/bull/critic/quant/macro/behavior agents operational
- Pattern library has 15+ Vietnam-specific patterns with outcome data
- Personal bias log shows 3+ identified biases
- Thesis hit rate measurable (statistically meaningful sample)

**Month 12 (end of Phase 4 — Compounding):**
- Karpathy outer loop optimizing signal weights weekly
- Cross-validation: system suggestions vs my manual analysis = where do they diverge?
- 3-5 trusted peers using it, providing feedback
- Demonstrable alpha vs VN-Index on dogfood portfolio (or honest accounting of why not)

**Ultimate signal of success**: When my gut says "buy XYZ", I check what StockForge says first — and seriously consider it when it disagrees.

---

## Technical Foundation (locked Phase 1-3)

**Stack:**
- **Python primary** — for data science, LLM workflows, time-series, backtesting (heavier than IdeaForge which was TS-primary)
- **Postgres 16 + TimescaleDB + pgvector + pg_trgm** — single DB for time-series + relational + vector
- **Redis** — cache + pub/sub + queue broker
- **Cloudflare R2** — raw content storage (PDFs, transcripts, scraped pages)
- **Claude API primary** — Sonnet for most tasks, Opus for thesis synthesis
- **OpenAI embeddings** — text-embedding-3-small (Vietnamese acceptable)
- **NestJS** — only if/when we need a public-facing API (Phase 4+)
- **Streamlit/Next.js** — Streamlit for personal dashboard (Phase 1-2), Next.js if SaaS path
- **Apache Airflow / Prefect** — data pipeline orchestration

**Architecture:**
- Clean Architecture with DDD tactical patterns (same as IdeaForge)
- 9 bounded contexts (see `agent-workspace/constitution/architecture.md`)
- Event-driven for cross-context communication
- Multi-loop execution (Karpathy outer + Continuous middle + Per-stock inner)

**Development approach:**
- AI-first: Claude Code as primary builder, human as spec author + reviewer + bias-checker
- Spec-Driven (SDD) + Domain-Driven (DDD) + selective BDD
- Sandwich pattern (Architect → Dev → Verifier) from Day 1
- Verify-Before-Write (VBW) protocol mandatory
- Three-tier quality gates (deterministic / probabilistic / human)

---

## Data Sources (Tier 1 budget)

**Free/cheap (Phase 1):**
- vnstock (open source) — historical EOD, fundamentals
- Vietstock public — financial reports
- TCBS API — semi-public market data
- CafeF, NDH, VietnamBiz — news scraping
- Public YouTube channels — transcript via yt-dlp + Whisper
- Public Facebook fanpages — selective scraping (legal grey, careful scope)

**Paid (Phase 2-3 if budget allows):**
- FiinPro Platform — comprehensive fundamental data (~30-100M VND/year)
- Wichart — pre-cleaned data
- SSI FastConnect — realtime quotes if needed

**Budget cap Year 1**: 50M VND for data + LLM combined.

---

## Meta-Discipline

These charter principles override daily decisions:

- **When in doubt, simplify** — minimum code that solves the problem, nothing speculative
- **Ship thin slices, not perfect systems** — each phase ends with something I actually use
- **Document what you learn, not what you plan** — post-mortem > prospective docs
- **Dogfood or delete** — features I don't use weekly get removed
- **Calibrate, don't guess** — every confidence claim must have outcome tracking
- **Stay agnostic about commercial outcome** — build for the craft, not for the exit

---

## Revision Protocol

This charter changes only when:
- A core principle proves materially wrong through 30+ hours of real use
- Scope demonstrably needs revision based on accumulated dogfood data
- Technical foundation invalidated by external event (tool deprecation, regulatory change, etc.)

Charter revisions require:
- Written rationale with evidence (linked to specific sessions/post-mortems)
- 48-hour cool-down before committing change
- Explicit version bump (v1.0 → v2.0)

Minor clarifications go in `agent-workspace/memory/agent-notes.md`. This charter stays stable.

---

## Document Index

| Document | Purpose | Stability |
|---|---|---|
| `PROJECT_CHARTER.md` (this) | Vision + principles | Immutable for ~3 months |
| `AGENT_OPERATING_MANUAL.md` | Agent configs, skills, workflows | Living, frequent updates |
| `SPEC_TEMPLATE.md` | How to write specs | Stable |
| `specs/tier1-strategic/001-four-tier-signal-architecture.md` | Strategic: signal architecture | Stable |
| `specs/tier2-feature/001-validate-investment-thesis.md` | First implementation spec | Stable |
| `specs/tier2-feature/002-influence-network-tracking.md` | KOL tracking system spec | Stable |
| `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` | Pump detection spec | Stable |
| `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` | Adversarial analysis spec | Stable |
| `specs/tier2-feature/005-karpathy-outer-loop.md` | Pipeline self-optimization spec | Stable |
| `agent-workspace/memory/project.md` | Current state | Continuously updated |
| `agent-workspace/memory/agent-notes.md` | Learned rules | Append-mostly |
| `agent-workspace/memory/thesis-log/` | All thesis ever recorded | Append-only |
| `agent-workspace/memory/post-mortems/` | Thesis outcome reviews | Append-only |
| `agent-workspace/calibration/` | KOL accuracy, signal calibration data | Continuously updated |

---

## Anti-Charter (what we explicitly reject)

To stay focused, we reject these tempting paths:

- **Predict prices with ML models** — models trained on VN price data overfit; no edge there.
- **Compete with broker research** — we have less data, less staff. We win on integration + edge sources, not on raw analysis depth.
- **Build for general retail public** — we build for ourselves and 3-5 peers. Mass market needs hand-holding we won't provide.
- **Trust LLM for numbers** — every numerical output must come from code with traceable inputs.
- **Build features without dogfooding** — speculative features die fast in this project.
- **Optimize for backtest performance** — Goodhart's Law is real. We optimize for forward decision quality.
- **Make money fast** — this is a 24-month project minimum to reach edge. Quick wins are anti-pattern.
