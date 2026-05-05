---
spec_id: SPEC-2026-04-23-001
tier: 2
status: approved
version: 1.0
created: 2026-04-23
authors: [project-owner]
bounded_contexts: [Analysis, Market Data, Fundamental, News Stream]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-004]
ubiquitous_language_terms: [Thesis, Ticker, Thesis Card, Recommendation, Point-in-Time, Fair Value Range, Trade-Off Matrix]
---

# SPEC: Validate Investment Thesis (First End-to-End Feature)

> **This is the first feature you build**. Thin slice spanning BC-1, BC-2, BC-5, and BC-8.
> Gives end-to-end workflow from ticker → thesis card. Other features enhance this core.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Why This Feature First

Goal of Phase 1: a thin slice that touches every layer of the system, delivers dogfoodable value, and exposes integration issues early. Thesis validation is that slice because:

1. **It's the primary use case** — answers "should I look deeper at this stock?"
2. **It spans 4 BCs** — forces architecture decisions early
3. **It's personally valuable Day 1** — even without KOL tracking or pump detection
4. **It gives eval data** — every thesis becomes evaluation for later outer loop

**Phase 1 version is intentionally minimal**:
- Tier 1 + Tier 2 data only (no KOL, no crowd sentiment yet)
- 3 perspectives only: Bear, Bull, Quant (add Macro, Behavior, Manager in Phase 3)
- Synthesizer with simple trade-off matrix
- Streamlit dashboard interface

**Phase 3 expansion** (after 004 fully built):
- 6 perspectives
- Counter-narrative integration
- Calibration-based confidence

## A.2 User Story

```
As the project owner, when I want to evaluate whether to investigate HPG further,
I want to type "HPG" into StockForge and get a structured thesis card within 5
minutes that surfaces bull case, bear case, valuation, and what I should
investigate further — not a buy/sell signal.
```

## A.3 Acceptance Criteria

**AC-1: End-to-End Workflow**
- Input: ticker symbol (e.g., "HPG")
- Output: thesis card with sections defined in Section A.4
- Duration: ≤5 minutes from input to rendered card
- Cost: ≤$3 per validation (tracking enforced)

**AC-2: All Output Grounded**
- Every claim has source URL
- Every number traces to tool call (no LLM-generated numbers)
- As-of dates visible on all data

**AC-3: Bear Case Substantive**
- ≥3 distinct bear points
- Each with specific evidence (not boilerplate)
- System refuses to render thesis without substantive bear case

**AC-4: Multi-Source Disagreement Surfaced**
- If Bear and Bull perspectives reach opposite conclusions with equal conviction, thesis shows DISAGREEMENT explicitly
- Final recommendation is INVESTIGATE (not forced consensus)

**AC-5: Reproducibility**
- Same ticker + as-of date = same thesis (with same model version + prompt hash)
- Thesis ID + metadata stored for audit

**AC-6: Disclaimer Present**
- Output includes research-aid disclaimer (I-S35)

## A.4 Thesis Card Sections (Phase 1 minimal)

Output format (markdown), rendered in Streamlit:

```markdown
# Thesis Card: {TICKER} (as of {AS_OF_DATE})

## Summary
**Recommendation**: {THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS}
**Confidence**: {HIGH | MEDIUM | LOW}
**Top Question to Resolve**: {one-sentence key uncertainty}

## Trade-Off Matrix
| Dimension | Verdict | Key Evidence |
|---|---|---|
| Value | {STRONG/NEUTRAL/WEAK} | {grounded evidence} |
| Quality | ... | ... |
| Growth | ... | ... |
| Risk | ... | ... |

## Quant Summary (numbers from code, not LLM)
- **Current Price**: {price} as of {timestamp}
- **Fair Value Range**: {low} — {mid} — {high}
  - DCF (WACC {x}%, g {y}%): {value}
  - Graham Number: {value}
  - Peer multiples (P/E, P/B avg): implied {value}
- **Key Ratios (TTM)**:
  - P/E: {x} (sector avg {y}, 5-yr own avg {z})
  - P/B: {x}
  - ROE: {x}% (sector avg {y}%)
  - Debt/Equity: {x}
- **Margin of Safety** (vs mid fair value): {x}%

## Bull Case ({N} points)
1. **{Point}** — {grounded evidence + source URL}
2. ...

## Bear Case ({N} points, minimum 3)
1. **{Point}** — {grounded evidence + source URL}
2. ...
3. ...

## Explicit Disagreements
{List of topics where Bear and Bull disagree substantively, with each position summarized}
OR
{"No substantive disagreements — perspectives align"}

## Catalysts (what could trigger re-rating)
- {catalyst} ({timeframe}, {likelihood})

## Risks (what could invalidate thesis)
- {risk} ({impact level})

## Data Freshness
- Price data: {staleness indicator}
- Fundamentals: {as of {period_end}, filed {filing_date}}
- News: {most recent article date}

## Reasoning Trace
{How synthesizer arrived at recommendation, citing which perspectives support what}

---
*This is a research aid, not financial advice. Decisions and responsibility are yours.*

[Archive Thesis ID: {thesis_id}]
```

## A.5 Out of Scope (Phase 1)

- KOL recommendation integration (Phase 2, spec 002)
- Crowd sentiment integration (Phase 2, spec 003)
- Counter-narrative generation (Phase 3)
- Macro / Manager / Behavior perspectives (Phase 3, spec 004 expansion)
- Outcome tracking (Phase 2)
- Portfolio/position integration (Phase 4)
- Multi-ticker comparison (later)

---

# PART B — AGENT CONTRACT

## B.1 Bounded Context Involvement

| BC | Role | What It Provides |
|---|---|---|
| BC-1 Market Data | Input | Current price, volume, foreign flow |
| BC-2 Fundamental | Input | Financial statements, ratios, peer data |
| BC-5 News Stream | Input | Recent news, sentiment (Phase 1 simple) |
| BC-8 Analysis | Orchestrator | Thesis aggregate, perspective coordination, synthesis |

## B.2 Phase 1 Simplifications

**Perspectives Phase 1**: only 3 agents (Bear, Bull, Quant). Macro/Behavior/Manager stubbed out (return empty or marked "Phase 3").

**Calibration Phase 1**: no historical hit rate yet. Confidence set heuristically:
- HIGH: all 3 perspectives strong conviction AND agree
- MEDIUM: perspectives mixed but evidence grounded
- LOW: perspectives disagree OR evidence limited

**Data gathering Phase 1**: automated via BC-1, BC-2, BC-5 adapters. No LLM-driven search yet.

## B.3 Key Use Case Implementation

```python
# packages/application/analysis/use_cases/validate_thesis_phase1.py

class ValidateThesisPhase1UseCase:
    """Phase 1 version of thesis validation.
    
    Simplifications from full spec (004):
    - 3 perspectives only (Bear/Bull/Quant)
    - No counter-narrative integration
    - No calibration-based confidence
    - Bias log stubbed
    
    Future: upgrade to full 004 version once all BCs exist.
    """
    
    def __init__(
        self,
        data_gatherer: Phase1DataGatherer,
        bear_agent: BearPerspectiveAgent,
        bull_agent: BullPerspectiveAgent,
        quant_agent: QuantPerspectiveAgent,
        synthesizer: Phase1Synthesizer,
        thesis_repo: ThesisRepository,
        event_bus: EventBus,
        cost_tracker: CostTrackerPort,
    ):
        ...
    
    async def execute(self, ticker: Ticker, as_of: date | None = None) -> Thesis:
        as_of = as_of or date.today()
        thesis_id = new_id()
        
        # Cost budget enforcement
        with self.cost_tracker.scoped_budget(limit_usd=3.0) as budget:
            # Step 1: Gather Tier 1+2 data (deterministic, no LLM)
            context = await self.data_gatherer.gather(ticker, as_of)
            if context.has_critical_gaps():
                return Thesis.incomplete(
                    thesis_id=thesis_id, ticker=ticker,
                    reason=f"missing critical data: {context.gaps}",
                )
            
            # Step 2: Run 3 perspectives in parallel
            bear_task = self.bear_agent.analyze(ticker, context)
            bull_task = self.bull_agent.analyze(ticker, context)
            quant_task = self.quant_agent.analyze(ticker, context)
            
            perspectives = await asyncio.gather(bear_task, bull_task, quant_task)
            
            # Step 3: Synthesize (preserve disagreements)
            synthesis = await self.synthesizer.synthesize(
                ticker=ticker, perspectives=perspectives, context=context,
            )
            
            # Step 4: Determine recommendation (heuristic Phase 1)
            recommendation = self._recommendation_from_synthesis(synthesis)
            confidence = self._confidence_from_synthesis(synthesis)
            
            # Step 5: Build thesis (aggregate invariants validate)
            thesis = Thesis(
                thesis_id=thesis_id,
                ticker=ticker,
                created_at=datetime.utcnow(),
                as_of=as_of,
                user_intent=None,
                perspectives=perspectives,
                synthesis=synthesis,
                final_recommendation=recommendation,
                confidence_level=confidence,
                status=ThesisStatus.DRAFT,
            )
            await self.thesis_repo.save(thesis)
            await self.event_bus.publish(ThesisRecorded(
                thesis_id=thesis_id, ticker=ticker, recommendation=recommendation,
                recorded_at=datetime.utcnow(),
            ))
            
            return thesis
    
    def _recommendation_from_synthesis(self, synth: Synthesis) -> Recommendation:
        # Heuristic Phase 1 rules:
        # THESIS_CANDIDATE: all dimensions positive, no substantive disagreement
        # PASS: all dimensions negative OR governance red flag
        # WATCH: mostly neutral or mixed-weak
        # INVESTIGATE (default): substantive signals present but disagreement or key question unresolved
        ...
    
    def _confidence_from_synthesis(self, synth: Synthesis) -> ConfidenceLevel:
        # Phase 1 heuristic; Phase 3 replaces with calibration-based
        ...
```

## B.4 Phase 1 Data Gatherer

```python
# packages/infrastructure/analysis/phase1_data_gatherer.py

class Phase1DataGatherer:
    """Assembles context for Phase 1 thesis validation.
    
    Pulls from BC-1 (prices), BC-2 (fundamentals), BC-5 (news).
    Returns SharedContext with all data + staleness indicators.
    """
    
    async def gather(self, ticker: Ticker, as_of: date) -> SharedContext:
        # All queries use point-in-time (I-S2)
        quotes = await self.quote_repo.get_range_as_of(
            ticker=ticker, from_date=as_of - timedelta(days=365), to_date=as_of,
        )
        financials = await self.fundamental_repo.get_as_of(ticker, as_of)
        ratios_ttm = self.ratio_service.compute_ttm_ratios(financials, quotes)
        peer_comparables = await self.peer_service.get_comparables(ticker, sector_as_of=as_of)
        historical_ratios = self.ratio_service.compute_historical_percentiles(
            ticker, quotes, financials, years=5,
        )
        recent_news = await self.news_repo.get_for_ticker(
            ticker, from_date=as_of - timedelta(days=90), to_date=as_of,
        )
        sector_news = await self.news_repo.get_for_sector(
            sector=financials.sector, from_date=as_of - timedelta(days=90),
        )
        
        # Staleness check
        gaps = []
        if not quotes or quotes[-1].date < as_of - timedelta(days=3):
            gaps.append("price_data_stale")
        if not financials or financials.filing_date < as_of - timedelta(days=180):
            gaps.append("fundamentals_stale")
        if len(recent_news) == 0:
            gaps.append("no_news_last_90d")
        
        return SharedContext(
            ticker=ticker, as_of=as_of,
            quotes=quotes, financials=financials, ratios_ttm=ratios_ttm,
            peer_comparables=peer_comparables, historical_ratios=historical_ratios,
            recent_news=recent_news, sector_news=sector_news,
            gaps=gaps,
        )
```

## B.5 Phase 1 Bear/Bull Agents (abbreviated)

```python
# packages/infrastructure/analysis/perspectives/bear_agent.py

class BearPerspectiveAgent:
    """Phase 1 Bear agent — operates on SharedContext only, no deep search."""

    async def analyze(self, ticker: Ticker, context: SharedContext) -> PerspectiveAnalysis:
        tool_set = BearToolSet(context)
        
        system_prompt = self._build_system_prompt(ticker)
        response = await self.llm.complete(
            system_prompt=system_prompt,
            messages=[{"role": "user", "content": f"Analyze {ticker}"}],
            tools=tool_set.tools,
            model="claude-sonnet-4-6",
        )
        
        # Parse structured output — must include key_points with source_urls
        analysis = self._parse_response(response, role=PerspectiveRole.BEAR)
        
        # Enforce BR-3 (substantive bear case)
        if len(analysis.key_points) < 3:
            # Retry with more explicit instruction
            analysis = await self._retry_with_bear_minimum(ticker, context, analysis)
        
        return analysis
    
    def _build_system_prompt(self, ticker: Ticker) -> str:
        return f"""You are a BEAR analyst for {ticker}. Your job is to find every
credible reason NOT to buy this stock. You are NOT balanced. Adversarial role.

Rules:
- Every claim cites source (URL + excerpt from context data)
- Focus on specific, material risks — not boilerplate
- Required categories: fundamental concerns, structural risks, valuation concerns,
  competitive threats
- Minimum 3 substantive points, each grounded
- Rate your conviction (STRONG/MODERATE/WEAK)
- Do NOT generate numbers in prose — use tool calls; state computed results only
- If unable to find substantive bear case after examining context, state so

Output as JSON matching PerspectiveAnalysis schema.
"""
```

Same pattern for BullPerspectiveAgent and QuantPerspectiveAgent, with role-appropriate system prompts.

## B.6 Phase 1 Synthesizer

```python
# packages/infrastructure/analysis/phase1_synthesizer.py

class Phase1Synthesizer:
    """Synthesizes 3 perspective analyses into trade-off matrix.
    
    KEY: does NOT collapse disagreement. Preserves it.
    """

    async def synthesize(
        self, ticker: Ticker, perspectives: list[PerspectiveAnalysis], context: SharedContext,
    ) -> Synthesis:
        # Build trade-off matrix across standard dimensions
        trade_off = TradeOffMatrix(dimensions=[VALUE, QUALITY, GROWTH, RISK])
        for dim in trade_off.dimensions:
            trade_off.scores[dim] = self._assess_dimension(dim, perspectives)
        
        # Explicit disagreement detection
        disagreements = self._detect_disagreements(perspectives)
        
        # Catalysts from bull + risks from bear (both grounded)
        catalysts = [c for p in perspectives if p.role == PerspectiveRole.BULL 
                     for c in self._extract_catalysts(p)]
        risks = [r for p in perspectives if p.role == PerspectiveRole.BEAR
                 for r in self._extract_risks(p)]
        
        # Reasoning trace via LLM (grounded)
        reasoning = await self._generate_reasoning_trace(
            ticker, perspectives, trade_off, disagreements,
        )
        
        return Synthesis(
            trade_off_matrix=trade_off,
            confluence_assessment=self._confluence(perspectives),
            explicit_disagreements=disagreements,
            catalysts=catalysts,
            risks=risks,
            personal_bias_flags=[],  # Phase 1 stub
            counter_narrative_summary=None,  # Phase 1 stub
            reasoning_trace=reasoning,
        )
```

## B.7 Streamlit UI

Single page for Phase 1:

```python
# apps/dashboard/pages/validate_thesis.py

import streamlit as st

st.title("Validate Investment Thesis")

ticker = st.text_input("Ticker", placeholder="HPG").upper()
as_of = st.date_input("As of", value=date.today())

if st.button("Validate"):
    with st.spinner(f"Running thesis validation on {ticker}..."):
        thesis = await validate_thesis_usecase.execute(ticker, as_of)
    
    # Render thesis card
    render_thesis_card(thesis)
    st.caption(f"Thesis ID: {thesis.thesis_id} • Cost: ${thesis.cost_usd:.3f}")
```

## B.8 Tasks (concrete work items)

**Week 1 — Domain Foundation**
- T-001: Implement BC-8 domain models: `Thesis`, `PerspectiveAnalysis`, `Synthesis`, `TradeOffMatrix`, `GroundedPoint`
- T-002: Implement value objects: `Ticker`, `Money`, `ConfidenceLevel`, `Recommendation` enum
- T-003: Unit tests for all aggregates enforcing invariants

**Week 2 — Data Infrastructure**
- T-004: Postgres schema for `theses` + `perspective_analyses`
- T-005: `QuoteRepository`, `FundamentalRepository` with point-in-time methods
- T-006: vnstock adapter for Quote ingestion (Tier 1)
- T-007: CafeF adapter for news ingestion (Tier 2)
- T-008: Phase1DataGatherer implementation

**Week 3 — Perspective Agents**
- T-009: `BearPerspectiveAgent` with system prompt + tool set
- T-010: `BullPerspectiveAgent`
- T-011: `QuantPerspectiveAgent` with deterministic tool calls for all numeric output
- T-012: Eval test: each agent on 3 known tickers, verify grounded output

**Week 4 — Synthesis + UI**
- T-013: `Phase1Synthesizer` with trade-off matrix + disagreement detection
- T-014: `ValidateThesisPhase1UseCase` orchestration
- T-015: Streamlit page + thesis card rendering
- T-016: Cost tracking integration (I-40 enforcement)
- T-017: End-to-end test on 5 watchlist tickers

**Week 5 — Dogfood + Refinement**
- T-018: Run on personal watchlist (10+ stocks)
- T-019: Record observations in `agent-workspace/memory/agent-notes.md`
- T-020: Refine prompts based on observed failures
- T-021: Session post-mortem, identify Phase 2 priorities

## B.9 Key Invariants Enforced

- **I-1** every claim has source_url (perspective key_points validated)
- **I-S1** no LLM math (Quant agent only uses tool calls for numbers)
- **I-S2** point-in-time queries (repositories have no `get_latest` in this path)
- **I-S10** bear case substantive ≥3 points (aggregate validates)
- **I-S11** ≥4 perspectives (Phase 1 exception: 3 + 3 stubs = acceptable, upgrade Phase 3)
- **I-S12** disagreement surfaced not resolved (synthesizer validated)
- **I-S35** research-aid disclaimer (UI template)
- **I-40** cost budget enforced ($3 per validation)

Phase 1 accepts relaxation of I-S11 (3 perspectives instead of 4) — documented exception that must be resolved by Phase 3 (004 spec).

## B.10 Cost Profile

Per thesis validation (Phase 1):
- Bear agent: ~20K tokens (Sonnet) = $0.10
- Bull agent: ~20K tokens (Sonnet) = $0.10
- Quant agent: ~25K tokens (Opus for reliability) = $0.70
- Synthesizer: ~15K tokens (Opus) = $0.40
- Data gather: ~$0 (deterministic)
- Target: ~$1.30 average, <$3 ceiling

Monthly at 20 validations: $25-60. Within personal budget.

## B.11 Success Measures (Phase 1 feature-level)

- [ ] End-to-end validation runs <5 min on 90% of tests
- [ ] All invariants enforced (no violations in test set)
- [ ] First 10 thesis produce genuinely useful output (user opinion)
- [ ] Cost stays within budget ($3 ceiling)
- [ ] User runs validation ≥2x/week for real decisions

---

# PART C — PROVENANCE & REVIEW

## C.1 Why Phase 1 Simplifications

**Only 3 perspectives**: Macro/Behavior/Manager need BC-4/BC-7/BC-3 maturity first. Phase 1 proves end-to-end flow with 3; Phase 3 adds the other 3.

**Heuristic recommendation**: Calibration needs eval data we don't have yet. Phase 1 uses heuristics; Phase 3 replaces with calibration-based.

**Phase 1 data only Tier 1+2**: Tier 3 (KOL) and Tier 4 (sentiment) are large separate specs. Phase 1 ships without them to get early dogfood.

## C.2 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Phase 1 spec. Start here. |
