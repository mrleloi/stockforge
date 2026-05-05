---
spec_id: SPEC-2026-04-23-004
tier: 2
status: approved
version: 1.0
created: 2026-04-23
authors: [project-owner]
bounded_contexts: [Analysis]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-001, SPEC-2026-04-23-002, SPEC-2026-04-23-003]
ubiquitous_language_terms: [Perspective, Adversarial Analysis, Synthesis, Bear Case, Bull Case, Confluence, Trade-Off Matrix, Disagreement, Thesis Card]
---

# SPEC: Multi-Perspective Adversarial Agents (BC-8)

> Orchestrates specialized perspectives to produce structured thesis.
> Implements adversarial-by-default principle from PROJECT_CHARTER.md.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

Single-perspective analysis is the #1 retail investor mistake — confirmation bias. When someone "analyzes" a stock they already want to buy, every signal becomes bullish; when they want to avoid, every signal becomes bearish.

Professional fund analysts fight this by structuring teams: long analysts + short analysts + risk team + sector specialist + behavioral/quant specialist. They debate before investment committee.

**We emulate that structure with specialized LLM agents**, each constrained to its perspective, each forbidden from consensus-seeking. The synthesizer doesn't vote-average — it surfaces disagreement explicitly.

This is conceptually similar to "Society of Mind" debate, Anthropic's "Constitutional AI", and fund investment committees. Applied specifically to Vietnamese equity thesis.

**Unique Vietnam considerations**:
- Must include Narrative perspective (narrative-driven market)
- Must include Manager perspective (governance quality varies wildly)
- Must include Behavior perspective (crowd sentiment often drives short-term)
- Quant perspective less about factor modeling, more about ratio analysis + Graham/Buffett methods

## A.2 The Six Perspectives

**Bear Analyst** — adversarial pessimist. Finds every reason NOT to buy. Expected to be wrong sometimes; job is to stress-test bull case. Success measure: identified real risks that materialized.

**Bull Analyst** — adversarial optimist. Finds every reason TO buy. Expected to be wrong sometimes; job is to stress-test bear case. Success measure: identified real catalysts that materialized.

**Quant Analyst** — pure numbers. Valuation ratios, DCF, point-in-time fundamentals, sector comparables. Zero narrative. Output: "Based on numbers alone, what's the fair value range and confidence?"

**Macro Analyst** — top-down sector and macro fit. Is this sector at the right point in its cycle? Does macro environment support? Does policy favor or disfavor?

**Behavior Analyst** — T3 + T4 perspective. What's the narrative phase? Sentiment state? KOL confluence? Pump risk? "Is this good stock at bad time, or bad stock at good time?"

**Manager Analyst** — corporate governance + leadership quality. Track record, alignment, related-party transactions, capital allocation history. Vietnamese governance quality varies 100x; this perspective essential.

## A.3 Core Use Cases

**UC-1 Full Thesis Validation** — User provides ticker + (optional) initial thesis draft. System runs all 6 perspectives independently, then synthesizer produces structured thesis card with trade-off matrix, disagreement markers, final recommendation (INVESTIGATE / WATCH / PASS / THESIS_CANDIDATE — never BUY/SELL).

**UC-2 Quick Check** — Fast version: only Quant + Behavior perspectives, ~30 seconds. Used for initial triage ("should I spend more time on this?").

**UC-3 Pre-Decision Challenge** — User says "I'm about to buy X". System runs Bear + Behavior + Manager perspectives specifically looking for disqualifiers. If any perspective raises serious flags, delivery paused for review.

**UC-4 Post-Mortem Synthesis** — After thesis has outcome (3m/6m/12m), all perspectives review: which was right, which was wrong, why. Fed back into calibration.

**UC-5 Disagreement Report** — For existing thesis: have perspectives diverged since thesis created? Surface disagreements that emerged.

## A.4 Business Rules

**BR-1 No Consensus-Seeking** — Perspectives don't see each other's output during generation. Generated independently. Synthesizer explicitly preserves disagreement (I-S12).

**BR-2 Grounded Output Required** — Every claim from every perspective has source citation (I-1). No free-floating opinions.

**BR-3 Bear Case Substantive** — Bear case ≥3 distinct points, each grounded in evidence, each specific to this stock (not boilerplate) (I-S10).

**BR-4 No Single Score** — Output is trade-off matrix, not "8/10 buy" (I-S52).

**BR-5 Final Framing: Research Aid** — Output always framed as "thesis exploration", never "recommendation" or "buy/sell advice" (I-S35).

**BR-6 Multi-Perspective Minimum** — Any synthesis uses ≥4 perspectives. Fewer perspectives = lower confidence tier (I-S11).

**BR-7 Numbers from Code Only** — Quant perspective cites computed values via tool calls, never LLM-generated numbers (I-S1).

**BR-8 Historical Calibration Applied** — Final confidence level based on historical hit rate of similar patterns, not model certainty (I-S7).

**BR-9 User Bias Mirror** — If user has stated intent about this ticker, system surfaces user's own potential biases (from personal bias log) in output.

**BR-10 Counter-Narrative When Needed** — If ticker currently at high community sentiment (BR-6 of 003), Counter-Narrative from BC-7 is MANDATORY input before synthesis proceeds.

## A.5 Success Criteria

**Month 9**:
- All 6 perspective agents operational
- Full Thesis Validation runs end-to-end in <5 minutes
- First 20 thesis completed with full output
- Disagreement cases explicit in output (>20% of thesis show substantive disagreement)

**Month 12**:
- 50+ thesis with 3-month outcome data
- Post-mortem comparing perspective accuracy: which perspective tends to be right/wrong in which regimes?
- Personal bias mirror has caught ≥3 cases where user's intent colored their analysis

**Qualitative**:
- I read the bear case carefully even when bullish
- I've changed ≥5 decisions due to perspective disagreement surfacing issues
- When perspectives all agree, I feel genuinely higher confidence (not false)
- When perspectives disagree, I investigate rather than average

## A.6 Out of Scope

- Auto-generating thesis without user ticker input (that's screener, separate)
- Sell decisions (these are thesis for entry; exit logic is BC-9)
- Multi-stock portfolio synthesis (per-stock for now)
- Real-time thesis updates (refresh on demand or scheduled, not streaming)

---

# PART B — AGENT CONTRACT

## B.1 Key Domain Model

```python
# packages/domain/analysis/models/

class PerspectiveRole(Enum):
    BEAR = "bear"
    BULL = "bull"
    QUANT = "quant"
    MACRO = "macro"
    BEHAVIOR = "behavior"
    MANAGER = "manager"

class Recommendation(Enum):
    THESIS_CANDIDATE = "thesis_candidate"  # high conviction, pursue further
    INVESTIGATE = "investigate"             # worth deeper research
    WATCH = "watch"                         # monitor, not acting now
    PASS = "pass"                           # not a fit at this time
    # Deliberately NO "BUY" / "SELL" — those are user decisions

@dataclass
class PerspectiveAnalysis:
    perspective_id: str
    ticker: Ticker
    role: PerspectiveRole
    generated_at: datetime
    llm_model: str
    llm_version: str
    prompt_hash: str

    # Core output
    key_points: list[GroundedPoint]   # each with source_url
    conviction_level: ConvictionLevel # STRONG | MODERATE | WEAK
    stated_verdict: Verdict           # what this perspective concludes on its own

    # Supporting
    considered_data: list[DataReference]  # what this perspective looked at
    known_blind_spots: list[str]          # what this perspective doesn't consider

@dataclass
class GroundedPoint:
    text: str                    # the claim in natural language
    source_url: str              # I-1 requirement
    source_excerpt: str          # ≤500 chars
    supporting_data: list[DataReference]  # specific metrics/events referenced
    extraction_confidence: float

@dataclass
class Thesis:
    thesis_id: ThesisId
    ticker: Ticker
    created_at: datetime
    user_intent: str | None            # user's stated position if provided
    perspectives: list[PerspectiveAnalysis]  # 4-6 perspectives
    synthesis: Synthesis
    final_recommendation: Recommendation
    confidence_level: ConfidenceLevel  # with calibration metadata
    status: ThesisStatus               # DRAFT | ACTIVE | REVIEWED | RETIRED

    def __post_init__(self):
        if len(self.perspectives) < 4:
            raise InvariantViolation("Thesis requires ≥4 perspectives (I-S11)")
        bear = next((p for p in self.perspectives if p.role == PerspectiveRole.BEAR), None)
        if not bear or len(bear.key_points) < 3:
            raise InvariantViolation("Thesis requires substantive bear case ≥3 points (I-S10)")

@dataclass
class Synthesis:
    trade_off_matrix: TradeOffMatrix  # structured, not narrative
    confluence_assessment: ConfluenceAssessment  # how much do perspectives agree?
    explicit_disagreements: list[Disagreement]  # where they disagree, preserved
    catalysts: list[Catalyst]         # what could trigger re-rating
    risks: list[Risk]                 # what could invalidate thesis
    personal_bias_flags: list[str]    # from user's bias log
    counter_narrative_summary: str | None  # from BC-7 if triggered
    reasoning_trace: str              # how synthesizer arrived at recommendation

@dataclass
class TradeOffMatrix:
    dimensions: list[Dimension]  # e.g., Value, Quality, Momentum, Sentiment, Risk
    scores: dict[Dimension, DimensionAssessment]

@dataclass
class DimensionAssessment:
    dimension: Dimension
    verdict: str                 # qualitative: "strong" | "neutral" | "weak"
    contributing_perspectives: list[PerspectiveRole]
    key_evidence: list[GroundedPoint]

@dataclass
class Disagreement:
    topic: str                   # "intrinsic value", "cycle timing", "management quality"
    perspectives_involved: list[PerspectiveRole]
    positions: dict[PerspectiveRole, str]  # each position summarized
    significance: Significance   # MINOR | SUBSTANTIVE | CRITICAL
    resolution_needed: bool      # true if user should investigate further

@dataclass
class Catalyst:
    description: str
    source_perspectives: list[PerspectiveRole]
    expected_timeframe: Timeframe
    evidence: list[GroundedPoint]
    probability_estimate: str    # qualitative: "likely" | "possible" | "uncertain"

@dataclass
class ConfidenceLevel:
    level: Level  # HIGH | MEDIUM | LOW
    basis: ConfidenceBasis
    calibration_metadata: CalibrationMetadata  # I-S7

@dataclass
class CalibrationMetadata:
    pattern_matched: str         # e.g., "cyclical_bottom_dividend_paying"
    historical_n: int            # number of historical cases
    historical_hit_rate: float   # for similar patterns
    lookback_months: int
```

## B.2 Key Domain Events

```python
ThesisValidationRequested(ticker, user_intent, requested_at, thesis_id)
PerspectiveAnalysisCompleted(perspective_id, thesis_id, role, conviction, completed_at)
SynthesisGenerated(thesis_id, recommendation, confidence_level, disagreement_count, generated_at)
ThesisRecorded(thesis_id, ticker, recommendation, recorded_at)
CounterNarrativeRequired(thesis_id, ticker, reason)
PersonalBiasFlagged(thesis_id, user_id, flagged_bias, evidence)
```

## B.3 Core Use Cases

### UC-1: Validate Investment Thesis

```python
class ValidateInvestmentThesisUseCase:
    """Orchestrates 6 perspective agents → synthesizer → structured thesis card."""

    def __init__(
        self,
        perspective_factory: PerspectiveAgentFactory,
        synthesizer: SynthesizerAgent,
        data_gatherer: DataGathererPort,
        calibration_service: CalibrationServicePort,
        bias_service: PersonalBiasServicePort,
        counter_narrative_service: CounterNarrativeServicePort,
        thesis_repo: ThesisRepository,
        event_bus: EventBus,
    ):
        ...

    async def execute(self, ticker: Ticker, user_intent: str | None = None) -> Thesis:
        thesis_id = new_id()
        await self.event_bus.publish(ThesisValidationRequested(
            ticker=ticker, user_intent=user_intent,
            requested_at=datetime.utcnow(), thesis_id=thesis_id,
        ))

        # Step 1: Gather data once (shared across perspectives)
        shared_context = await self.data_gatherer.gather(ticker)
        # shared_context includes: financial summary, recent news, KOL recs,
        # sentiment snapshot, sector data, peer comparables, price action

        # Step 2: Check if counter-narrative mandatory
        counter_narrative = None
        if shared_context.sentiment_snapshot.bullish_ratio() > 0.8:
            counter_narrative = await self.counter_narrative_service.get_or_generate(ticker)
            await self.event_bus.publish(CounterNarrativeRequired(thesis_id, ticker, "high_sentiment"))

        # Step 3: Run 6 perspectives in parallel (they don't see each other)
        perspective_tasks = [
            self._run_perspective(role, ticker, shared_context, counter_narrative)
            for role in [BEAR, BULL, QUANT, MACRO, BEHAVIOR, MANAGER]
        ]
        perspectives = await asyncio.gather(*perspective_tasks)

        # Step 4: Synthesizer sees all perspectives + counter-narrative + user bias
        user_biases = await self.bias_service.get_relevant_biases(ticker, user_intent)
        synthesis = await self.synthesizer.synthesize(
            ticker=ticker,
            perspectives=perspectives,
            counter_narrative=counter_narrative,
            user_biases=user_biases,
            user_intent=user_intent,
        )

        # Step 5: Calibrate confidence
        pattern = self._identify_pattern(synthesis, perspectives)
        calibration = await self.calibration_service.get_historical_hit_rate(pattern)
        confidence = ConfidenceLevel(
            level=self._level_from_calibration(calibration, synthesis),
            basis=synthesis.reasoning_trace,
            calibration_metadata=calibration,
        )

        # Step 6: Build thesis (aggregate validates invariants)
        thesis = Thesis(
            thesis_id=thesis_id,
            ticker=ticker,
            created_at=datetime.utcnow(),
            user_intent=user_intent,
            perspectives=perspectives,
            synthesis=synthesis,
            final_recommendation=self._recommendation_from_synthesis(synthesis, confidence),
            confidence_level=confidence,
            status=ThesisStatus.DRAFT,
        )
        await self.thesis_repo.save(thesis)
        await self.event_bus.publish(SynthesisGenerated(...))
        return thesis

    async def _run_perspective(
        self,
        role: PerspectiveRole,
        ticker: Ticker,
        context: SharedContext,
        counter_narrative: CounterNarrative | None,
    ) -> PerspectiveAnalysis:
        agent = self.perspective_factory.create(role)
        analysis = await agent.analyze(ticker=ticker, context=context, counter_narrative=counter_narrative)
        await self.event_bus.publish(PerspectiveAnalysisCompleted(...))
        return analysis
```

## B.4 Perspective Agent Specifications

Each perspective is a separate Claude invocation with role-specific system prompt, role-specific tools, role-specific data view. They're constrained to their perspective.

### Bear Analyst

**System prompt** (abbreviated):
```
You are a dedicated BEAR analyst for stock {ticker}. Your job is to find every credible
reason NOT to buy this stock. You are NOT trying to be balanced. You are the short-seller
perspective in an investment committee.

Rules:
- Every claim must cite source (URL + excerpt)
- Focus on specific, material risks — not boilerplate ("market volatility")
- Required categories: fundamental concerns, structural risks, governance concerns,
  valuation concerns, competitive threats, macro headwinds
- Minimum 3 substantive points, each with evidence
- Rate your own conviction (STRONG/MODERATE/WEAK) based on evidence strength
- If you cannot find substantive bear case, state so explicitly — do not invent

Tools available:
- query_fundamentals(ticker, as_of) — point-in-time financials
- query_news(ticker, days=90) — recent news
- query_peer_comparables(ticker, sector) — how peers have performed
- query_red_flags(ticker) — known governance/accounting flags
```

**Tools**:
- `query_fundamentals` — returns point-in-time financial data with trend
- `query_news` — recent news filtered for negative signal
- `query_peer_comparables` — sector peers
- `query_red_flags` — from `playbooks/red-flag-checklists/` matched to sector
- `query_short_interest` — if available
- `query_competitive_landscape` — competitors + market share trends

**Output schema**: PerspectiveAnalysis with role=BEAR.

### Bull Analyst

**System prompt** (abbreviated):
```
You are a dedicated BULL analyst for stock {ticker}. Your job is to find every credible
reason TO buy this stock. You are NOT trying to be balanced. You are the long-side
perspective in an investment committee.

Rules:
- Every claim must cite source
- Focus on specific, material catalysts — not boilerplate ("good company")
- Required categories: fundamental strengths, structural advantages, growth catalysts,
  valuation attractiveness, competitive moats, macro tailwinds
- Minimum 3 substantive points
- Rate conviction based on evidence strength
- If bear case is overwhelming, acknowledge — don't force bull case

Tools: [same structure as bear, filter opposite]
```

### Quant Analyst

**System prompt** (abbreviated):
```
You are a QUANT analyst. You deal in numbers only. Narrative is out of scope.

Required deliverables:
1. Valuation triangulation: DCF, Graham Number, Owner Earnings, peer multiples, historical multiples
2. Key ratios with trend: ROE, ROIC, margin, leverage, cash conversion
3. Growth analysis: revenue/earnings trajectory, deceleration/acceleration
4. Quality score: earnings quality, accruals ratio, cash flow vs net income divergence
5. Fair value range (low/mid/high) with reasoning for each
6. Margin of safety vs current price (quantified)

Rules:
- ALL numbers via tool calls. NEVER state "approximately X" or "around Y" in your own words.
- Every number accompanied by its source (tool result + timestamp)
- Use point-in-time data — no look-ahead
- If data incomplete or stale, state so

Tools:
- compute_dcf(ticker, wacc, growth_assumptions)
- compute_graham_number(ticker)
- compute_owner_earnings(ticker, years)
- compute_peer_multiples(ticker)
- compute_historical_multiples(ticker, years)
- compute_quality_score(ticker)
- compare_sector_valuation(ticker)
```

**Tools are all deterministic computations** — return dataclasses with source + as_of date.

### Macro Analyst

**System prompt** (abbreviated):
```
You are a MACRO analyst. Focus on sector cycle position and top-down factors.

Required analysis:
1. Where is this sector in its cycle? (early / mid / late / downturn)
2. What macro variables drive this sector? (rates, FX, commodities, policy)
3. Current state of each driver + trajectory
4. Policy environment: supportive / neutral / adverse
5. Historical analog: when has this sector looked similar before, what followed?

Tools:
- query_sector_cycle_indicators(sector)
- query_macro_indicators() — VN + global
- query_policy_documents(sector, days=180)
- find_historical_sector_analogs(sector, current_state)
```

### Behavior Analyst

**System prompt** (abbreviated):
```
You are a BEHAVIOR analyst. Focus on T3 + T4 signals: narrative phase, KOL sentiment,
crowd state, pump risk.

Required analysis:
1. Current narrative phase for this ticker (or related narratives)
2. KOL confluence: who's saying what, credibility-weighted
3. Crowd sentiment state: mainstream/peripheral, momentum direction
4. Pump risk assessment: phase, signals, historical analogs
5. Timing context: is this good stock at bad time, or opposite?

Tools:
- query_kol_recommendations(ticker, days=60)
- query_sentiment_snapshot(ticker)
- query_pump_detections(ticker)
- query_narrative_phase(ticker)
- query_coordinated_posting_history(ticker)
```

### Manager Analyst

**System prompt** (abbreviated):
```
You are a MANAGER quality analyst. Evaluate governance + leadership + capital allocation.

Required analysis:
1. Executive track record: tenure, prior results, consistency
2. Capital allocation history: M&A, buyback, dividend, capex discipline
3. Related-party transactions: flagged concerns, patterns
4. Shareholder treatment: dilution history, minority treatment
5. Board independence + governance structure
6. Historical promises vs delivery: has management delivered what they said?

Tools:
- query_executive_history(ticker)
- query_capital_allocation_history(ticker, years=5)
- query_related_party_transactions(ticker)
- query_shareholder_dilution(ticker, years=5)
- query_governance_structure(ticker)
- query_manager_promises_vs_delivery(ticker)
```

## B.5 Synthesizer Agent

The synthesizer is special. It sees all 6 perspectives + counter-narrative + user biases.

**System prompt** (abbreviated):
```
You are a SYNTHESIZER. You see 6 perspective analyses, counter-narrative if generated,
and user bias context.

Your job is NOT to reach consensus. Your job is to:
1. Build trade-off matrix across standard dimensions (Value, Quality, Growth, Sentiment, Risk, Timing)
2. Identify explicit disagreements between perspectives
3. Extract catalysts (from bull + macro + behavior perspectives)
4. Extract risks (from bear + manager + behavior perspectives)
5. Flag user biases that might be affecting analysis
6. Integrate counter-narrative if present
7. Produce structured thesis card — NOT a recommendation to buy/sell

Rules:
- If perspectives disagree substantively, preserve the disagreement — do NOT average
- If bear case is strong AND bull case is strong, that's an INVESTIGATE not a HOLD
- Final verdict: THESIS_CANDIDATE | INVESTIGATE | WATCH | PASS (never BUY/SELL)
- Confidence calibrated to historical hit rate of this pattern
- Reasoning trace must cite which perspectives support which conclusions
- If a perspective has conviction WEAK, don't weight it as high as one with STRONG

Output: Synthesis dataclass with trade-off matrix, disagreements, catalysts, risks,
confidence, reasoning trace.
```

## B.6 Thesis Card Output Format

User-facing output is a **structured card**, not narrative:

```markdown
# Thesis Card: HPG (as of 2026-04-23)

## Recommendation: INVESTIGATE
**Confidence**: MEDIUM (basis: cyclical_bottom_dividend pattern; n=23 historical cases 2018-2025; hit rate 65%±8%)

## Trade-Off Matrix

| Dimension | Verdict | Key Signal |
|---|---|---|
| Value | STRONG | P/B 0.9 (historical 5-yr avg 1.8), DCF fair value 31,500 vs 24,000 current |
| Quality | MODERATE | ROE 12% (sector 15%), margin declining Q-o-Q |
| Growth | WEAK | Volume stagnant, no obvious demand driver |
| Sentiment | NEUTRAL | Crowd silent; 2 KOL mentions (both WATCH) |
| Risk | MODERATE | High leverage 2.5x, input cost volatility |
| Timing | WEAK | Early cycle not confirmed; might be value trap |

## Bull Case (3 points)
1. **Valuation extreme**: P/B 0.9 vs sector 1.8 vs own 5-yr avg 1.8 (source: FiinPro Q1 2026)
2. **Dividend sustainable**: 8% yield with coverage 2.1x (source: FY2025 report)
3. **Ministry policy support**: new steel import tariff announced 2026-03 (source: MoIT)

## Bear Case (4 points)
1. **Demand signal weak**: cement + construction indicators flat 12m (source: GSO data)
2. **Competition rising**: Imported steel market share rising despite tariff (source: industry report)
3. **Capex cycle starting**: new BOF plant means cash drain 2-3 years (source: FY2025 AGM)
4. **Governance flag**: recent related-party transaction with related cement supplier at above-market price (source: audit note)

## Explicit Disagreements
- **Quant vs Macro**: Quant says value extreme; Macro says sector cycle not yet favorable
- **Resolution**: User should investigate if cycle timing matters more than valuation for their holding period

## Catalysts
- Import tariff enforcement (H2 2026, probability: likely)
- Q3 2026 construction pickup if rate cuts proceed (probability: possible)

## Risks
- Capex drag on cash flow (certain, magnitude TBD)
- Governance escalation if related-party pattern continues (probability: uncertain)

## Personal Bias Flags
- You have bullish bias on industrial stocks (bias log: 2/3 industrial thesis ended up buying at late cycle)
- Current position: not owned; stated intent: considering accumulation

## Counter-Narrative Integration
N/A — community sentiment not elevated on this ticker.

## Reasoning Trace
Synthesizer weighs valuation extremity (strong signal) against cycle timing uncertainty (moderate
negative). Bear case on governance is specific and recent (not boilerplate), elevating risk dimension.
Disagreement between Quant (strong) and Macro (weak) is the key question. User's historical bias
toward industrial cyclicals at late cycle is flagged. INVESTIGATE recommended — user should
resolve macro cycle timing uncertainty before decision. Similar patterns historically: 65% hit rate.

---
*This is a research aid, not financial advice. Decisions and responsibility are yours.*
```

## B.7 Database Schema

```sql
-- db/migrations/008_analysis.sql

CREATE TABLE theses (
    thesis_id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    user_intent TEXT,
    final_recommendation TEXT NOT NULL,
    confidence_level TEXT NOT NULL,
    calibration_metadata JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft',
    synthesis JSONB NOT NULL
);

CREATE TABLE perspective_analyses (
    perspective_id TEXT PRIMARY KEY,
    thesis_id TEXT NOT NULL REFERENCES theses(thesis_id),
    role TEXT NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL,
    llm_model TEXT NOT NULL,
    llm_version TEXT NOT NULL,
    prompt_hash TEXT NOT NULL,
    key_points JSONB NOT NULL,
    conviction_level TEXT NOT NULL,
    stated_verdict TEXT NOT NULL,
    considered_data JSONB NOT NULL,
    known_blind_spots TEXT[]
);

CREATE INDEX idx_perspectives_thesis ON perspective_analyses(thesis_id);
CREATE INDEX idx_theses_ticker_created ON theses(ticker, created_at DESC);

CREATE TABLE thesis_outcomes (
    outcome_id TEXT PRIMARY KEY,
    thesis_id TEXT NOT NULL REFERENCES theses(thesis_id),
    review_window TEXT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    price_at_thesis NUMERIC,
    price_at_review NUMERIC,
    return_pct REAL,
    benchmark_return_pct REAL,
    excess_return_pct REAL,
    which_perspectives_were_right TEXT[],
    which_perspectives_were_wrong TEXT[],
    notes TEXT,
    UNIQUE(thesis_id, review_window)
);
```

## B.8 Performance & Cost Budget

**Full thesis validation (6 perspectives + synthesizer)**:
- Target: <5 minutes wall time
- Cost ceiling: <$5 per thesis (I-40)
- Parallelization: 6 perspectives run concurrently

**Quick check (2 perspectives)**:
- Target: <30 seconds
- Cost ceiling: <$0.50

**Per perspective**:
- Sonnet for Bear/Bull/Macro/Behavior/Manager (good enough, faster)
- Opus for Quant (more reliable with numbers) + Synthesizer (needs nuanced integration)
- Token budget: 30-50K per perspective (data context + reasoning)

## B.9 Quality Gates

**Deterministic**:
- Schema enforces: ≥4 perspectives per thesis, bear case ≥3 points
- Number validator: flag any "approximately" in LLM output
- Provenance validator: every claim has source_url

**Probabilistic** (separate agent):
- Synthesis critic reviews: did synthesizer preserve disagreement or collapse it?
- Confidence critic reviews: is confidence level justified by calibration data?
- Disclaimer presence check

**Human**:
- First 10 thesis: user reviews full output before acting on any
- Monthly: user spot-checks 2 random theses for quality regressions

## B.10 Tasks (initial breakdown)

**Phase 1** (foundation, ~3 weeks):
- BC-8 domain: Thesis, PerspectiveAnalysis, Synthesis aggregates + value objects
- Schema migrations
- Repository implementations
- Unit tests for all aggregates + invariants

**Phase 2** (perspectives, ~4 weeks):
- Each of 6 perspective agents with system prompt + tool set
- Shared data gatherer
- Parallel orchestration
- Dry-run on 3 test tickers

**Phase 3** (synthesizer + calibration, ~3 weeks):
- Synthesizer agent + trade-off matrix generator
- Calibration service (patterns + historical hit rate)
- Personal bias integration with BC-9
- Counter-narrative integration with BC-7

**Phase 4** (UX, ~2 weeks):
- Streamlit page: ticker input → thesis card
- Thesis archive browser
- Outcome tracking UI

## B.11 Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Perspectives converge despite independent prompting | MEDIUM | HIGH | Different system prompts + different tool access + separate LLM calls + critic verifies disagreement preserved |
| Cost overruns | MEDIUM | MEDIUM | Quick check mode for initial triage; full thesis only on chosen tickers |
| Data gatherer misses key data | HIGH | MEDIUM | Iterate data needs per perspective; each perspective can request additional data |
| Synthesizer hallucinates final verdict | MEDIUM | CRITICAL | Reasoning trace mandatory + human reviews first 10 theses |
| User treats output as buy/sell signal | MEDIUM | CRITICAL | Framing language + disclaimer + recommendation enum doesn't include BUY/SELL |
| Perspective blind spots compound | MEDIUM | MEDIUM | Known blind spots logged per perspective; over time identified by post-mortem |

---

# PART C — PROVENANCE & REVIEW

## C.1 Why This Design

**Considered alternative: single comprehensive LLM agent**
- Rejected: groupthink from within single call. Multiple perspectives from single context still converge.

**Considered alternative: 3 perspectives (bull/bear/neutral)**
- Rejected: "neutral" collapses to average; BEHAVIOR and MANAGER needed specifically for VN.

**Considered alternative: sequential perspectives (each sees prior)**
- Rejected: anchoring bias. Later perspectives forced to acknowledge earlier. Independent + synthesizer sees all = better.

**Considered alternative: vote-based final recommendation**
- Rejected: violates principle of not collapsing disagreement. Disagreement is signal, not noise.

## C.2 Open Questions

- Should we add a "Devil's Advocate" 7th perspective specifically seeking disqualifiers?
- How to handle when perspectives fundamentally look at different timeframes (Quant=fair value, Behavior=next 3 months)?
- When user rejects thesis recommendation and takes opposite action, how do we capture learning?
- Should synthesizer have access to past thesis outcomes for this ticker?

## C.3 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Initial |
