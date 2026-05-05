---
spec_id: SPEC-2026-04-23-T1-001
tier: 1
status: approved
version: 1.0
created: 2026-04-23
last_reviewed: 2026-04-23
authors: [project-owner]
bounded_contexts: [Market Data, News Stream, Influence Network, Crowd Sentiment, Analysis]
related_specs: [SPEC-2026-04-23-001, SPEC-2026-04-23-002, SPEC-2026-04-23-003, SPEC-2026-04-23-004, SPEC-2026-04-23-005]
ubiquitous_language_terms: [Signal Tier, Lead Time, Reliability, Calibration, Hard Data, Official Narrative, Influence Network, Crowd Sentiment, Narrative Phase, Signal Confluence]
---

# SPEC: Four-Tier Signal Architecture

> **TIER 1 STRATEGIC SPEC** — defines the foundational analytical framework all feature specs build upon.

---

# PART A — STRATEGIC CONTEXT

## A.1 The Insight This Spec Encodes

Quant funds in efficient markets win on three things: clean data, execution speed, and diverse alpha factors. They explicitly avoid sentiment from social media because it's noise at their scale and gets arbitraged away in efficient markets.

Vietnam stock market inverts every assumption:
- **Inefficient by structure**: 85-90% retail investor share (US: 20-25%); information asymmetry is structural, not transient
- **Sentiment is signal, not noise**: KOL recommendations measurably move prices; pump operators visible
- **Narrative dominates fundamentals**: stocks can deviate from fair value for 6-24 months based on which narrative captures attention
- **Foreign flow distorts**: $1B can move VN-Index 5-7%; same $1B moves S&P 500 by 0.0001%

The arbitrage opportunity: **apply quant methodology + LLM reasoning + sentiment/influence data layers that no commercial product offers for VN**.

This spec defines HOW we encode that opportunity into a four-tier signal architecture that every other feature builds on.

## A.2 The Four Tiers

Each tier has fundamentally different properties:

| Tier | Type | Source | Lead Time | Reliability | LLM Role |
|---|---|---|---|---|---|
| **1** Hard Data | Deterministic | Exchange feeds, financial reports | Hours-Days | Very High | None |
| **2** Official Narrative | Semi-structured | Mainstream news, broker reports | Real-time | High | Extract claims |
| **3** Influence Network | Semi-structured | YouTube, KOL pages, podcasts | Can lead by days | Medium (per-KOL calibrated) | Transcribe + extract |
| **4** Crowd Sentiment | Unstructured | Forums, public chats, comments | Lags price | Low (mass behavior) | Classify + detect coordination |

Critical: tiers are not "more data is better". They are **different kinds of information** with different decision implications.

## A.3 The Combinatorial Edge

The edge is not in any single tier. It's in **how tiers combine**.

**Pattern 1: Early Opportunity (T1+T2+T3 confluence before T4)**
- Hard data shows fundamentals improving (Q-on-Q margin expansion, inventory normalizing)
- Official news quietly reports positive developments (broker quietly upgrades, no fanfare)
- 2-3 calibrated KOLs start mentioning the stock with conviction
- BUT crowd sentiment hasn't woken up yet (low mention frequency, no FOMO posts)
- → **High-confidence early entry signal**

**Pattern 2: Likely Top (T4 hot but T1+T2 weak)**
- Crowd sentiment frenzied (mention frequency at 90th percentile, FOMO posts dominant)
- Multiple KOLs pushing the stock (T3 hot)
- BUT hard data shows decelerating fundamentals (T1 weak)
- AND no major positive official news (T2 silent)
- → **Likely distribution phase, avoid or exit**

**Pattern 3: Manufactured Pump (T3 hot, T4 building, T1+T2 absent)**
- Few specific KOLs (often same ones repeatedly) push stock
- Crowd starts repeating same talking points (coordination signature)
- No fundamental basis (T1)
- No real news (T2)
- → **Pump warning, avoid entirely**

**Pattern 4: Forgotten Value (T1 strong, T2-T4 silent)**
- Excellent fundamentals quietly grinding
- No news catalysts
- No KOL attention
- No crowd buzz
- → **Value trap candidate OR patient accumulation opportunity (need catalyst hypothesis)**

These patterns are detectable only when you track all four tiers with calibrated reliability scores.

## A.4 Why This Beats Single-Tier Approaches

**Approach: Pure Tier 1 (traditional quant)**
- Misses narrative-driven mispricing that lasts months in VN
- Gets value-trapped in cheap stocks no one cares about
- Cannot detect or avoid pumps

**Approach: Pure Tier 2 (news-based)**
- News is reactive, often coincident or lagging
- Misses pre-news positioning
- Susceptible to "official narrative" being co-opted

**Approach: Pure Tier 3 (follow KOLs)**
- KOL accuracy varies wildly (5%-70% hit rate observed)
- KOL recommendations susceptible to incentive bias (paid promotions)
- Reactive — by time KOL public, edge often gone

**Approach: Pure Tier 4 (sentiment trading)**
- Crowd sentiment lags; trading on it = late
- High signal-to-noise ratio without filtering
- Pumpers manipulate sentiment deliberately

**Combined four-tier approach:**
- Each tier validates or contradicts the others
- Confluence = high confidence; disagreement = caution flag
- Pump operators can't manipulate all four tiers simultaneously (T1 hardest to fake)

## A.5 The Compounding Moat

This architecture creates compounding moats over time:

**Per-tier calibration**:
- Tier 1 doesn't need calibration (deterministic)
- Tier 2 needs source calibration (which broker reports prove right? which news outlets best for which sectors?)
- Tier 3 needs per-KOL calibration (each KOL gets a credibility score that updates monthly)
- Tier 4 needs pattern calibration (which crowd patterns precede tops/bottoms?)

After 12 months, calibration data becomes proprietary. After 24 months, it's irreplicable without starting over.

**Cross-tier pattern library**:
- "Pattern X happened 7 times since 2022. 5 were profitable. 2 false signals had common feature Y."
- Each new occurrence updates the pattern's reliability score.
- Library starts empty; grows with every dogfood session.

---

# PART B — TECHNICAL ARCHITECTURE

## B.1 Tier 1: Hard Data

### Sources

**Required (Phase 1)**:
- vnstock — historical EOD prices, OHLCV, basic fundamentals
- Vietstock public — financial reports (PDF + structured)
- TCBS API — semi-public quotes, foreign flow
- VnDirect / SSI public APIs — backup sources

**Optional (Phase 2-3 if budget)**:
- FiinPro — comprehensive normalized fundamentals
- Bloomberg / Refinitiv — overkill for personal use

### Data Categories

```python
# Stored in BC-1 Market Data
class Quote:        # Time-series, TimescaleDB hypertable
    ticker: Ticker
    timestamp: datetime
    open: Money
    high: Money
    low: Money
    close: Money
    volume: int
    foreign_buy: int
    foreign_sell: int
    adjustment_type: AdjustmentType
    source_provider: SourceProvider

# Stored in BC-2 Fundamental
class FinancialStatement:
    ticker: Ticker
    statement_type: StatementType  # IS | BS | CF
    period_end: date
    filing_date: date
    line_items: dict[str, Money]
    source_provider: SourceProvider

# Stored in BC-4 Macro
class MacroIndicator:
    indicator: str  # "VN_GDP_GROWTH", "VN_CPI", "FED_FUNDS_RATE"
    timestamp: datetime
    value: Decimal
    unit: str
```

### LLM Role: NONE

Tier 1 is pure code. LLM never touches it. Calculations like P/E, ROE, DCF use deterministic formulas in `packages/domain/fundamental/services/`.

### Lead Time

- Intraday: real-time (if subscribed) or 15-min delay
- EOD: end of trading day
- Fundamentals: filing date + ingestion lag (typically T+1 day)

### Reliability

Very high, BUT:
- Source disagreements happen (Rule 4 in financial-data-protocol.md)
- Restated financials happen (track via `restated_at` field)
- Adjustment type confusion is biggest risk

## B.2 Tier 2: Official Narrative

### Sources

**Required**:
- CafeF (cafef.vn) — most popular VN financial news
- Vietstock News (vietstock.vn) — second most popular
- NDH (nhipcaudautu.vn) — quality analysis
- VietnamBiz (vietnambiz.vn) — business focus
- Đầu Tư Chứng Khoán (tinnhanhchungkhoan.vn)

**Source-specific (companies/sectors)**:
- Company official announcements via HOSE/HNX disclosure portals
- Broker reports (SSI, HSC, VCSC, VND, FPTS) — public summaries

**Government/Regulatory**:
- SBV (State Bank of Vietnam) announcements
- MoF (Ministry of Finance) policy documents
- Quốc hội / Chính phủ document portals

### Data Categories

```python
# Stored in BC-5 News Stream
class NewsArticle:
    article_id: str
    source: str               # "cafef", "vietstock", etc
    url: str
    title: str
    body_excerpt: str         # full body in R2
    published_at: datetime
    ingested_at: datetime
    
class ExtractedClaim:
    claim_id: str
    article_id: str
    claim_text: str           # extracted by LLM
    mentioned_tickers: list[Ticker]
    mentioned_sectors: list[Sector]
    sentiment: Sentiment      # categorical, not numeric (Rule 7)
    extractor_model: str
    extractor_version: str
    extracted_at: datetime
    source_text_excerpt: str
    confidence_extracted: float
```

### LLM Role

- **Extract structured claims** from unstructured news
- **Classify sentiment** categorically (STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH)
- **Identify mentioned entities** (tickers, sectors, people)
- **Detect contradictions** between sources reporting same event
- **Cluster related stories** (same event covered by multiple sources)

LLM does NOT:
- Generate sentiment scores numerically
- Predict price impact (that's BC-8 Analysis with deterministic models)
- Produce summaries that displace original (copyright + accuracy)

### Lead Time

Real-time. Pipeline polls every 5-15 min for new articles.

### Reliability

High but variable:
- Major outlets (CafeF, Vietstock): high reliability for facts, watch for "PR disguised as news"
- Smaller outlets: variable; calibrate per source over time
- Broker reports: have inherent bias (broker has positions); track which broker is right for which sector
- Government docs: high reliability for facts, low for interpretation

## B.3 Tier 3: Influence Network ⭐

### Sources

**YouTube channels** (selected, not exhaustive — examples):
- Mr. X30, Học Viện Đầu Tư, Take Profit, Đầu Tư Từ Đầu, Giao Dịch Cùng Tôi, etc.
- Each channel: subscribe with yt-dlp, monitor for new uploads daily

**Facebook fanpages** (public, ToS-respecting):
- Fanpages of well-known finance KOLs
- Read-only access, respect rate limits

**Telegram public channels**:
- Public broadcast channels (not private groups)
- Use Telegram API with read-only bot

**Podcasts**:
- BizPodcast, Money Talk, others
- RSS feeds + Whisper transcription

**Personal blogs / Substack**:
- Vietnamese investing bloggers with consistent output

### Data Categories

```python
# Stored in BC-6 Influence Network
class Kol:
    kol_id: KolId
    name: str
    primary_channel: ChannelId
    secondary_channels: list[ChannelId]
    profile_summary: str       # human-curated
    sectors_covered: list[Sector]
    style: KolStyle           # FUNDAMENTAL | TECHNICAL | NARRATIVE | PUMPER | MIXED
    credibility_score: CredibilityScore  # see calibration spec
    
class Channel:
    channel_id: ChannelId
    platform: Platform        # YOUTUBE | FACEBOOK | TELEGRAM | PODCAST | BLOG
    url: str
    kol_id: KolId
    subscriber_count: int
    last_scraped_at: datetime
    
class Recommendation:
    recommendation_id: str
    kol_id: KolId
    channel_id: ChannelId
    source_url: str
    timestamp_in_source: str   # for video: "12:34-13:02"
    transcript_excerpt: str
    ticker: Ticker
    extracted_intent: Intent   # STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID
    extracted_conditions: list[str]
    extracted_timeframe: Timeframe
    extraction_confidence: float
    published_at: datetime
    extracted_at: datetime
    
class CredibilityScore:
    kol_id: KolId
    overall_hit_rate: float
    n_recommendations_evaluated: int
    sector_specific_scores: dict[Sector, float]
    timeframe_specific_scores: dict[Timeframe, float]
    last_updated_at: datetime
    bayesian_confidence_interval: tuple[float, float]
```

### LLM Role

- **Transcribe** audio/video (Whisper, not LLM but adjacent)
- **Extract recommendations** with timestamp, intent, conditions, timeframe
- **Detect coordinated messaging** (same KOL mentioning many stocks in pattern)
- **Classify KOL style** (fundamental? technical? narrative-driven? potential pumper?)
- **Identify when KOL changes view** (was bullish, now bearish — track flip-flop frequency)

### Lead Time

Variable per KOL:
- Some KOLs lead price by 1-3 days (publish recommendation, audience acts)
- Some are coincident (publish during the move)
- Some are contrarian indicators (pumpers; their recommendation = sell signal)

This is exactly what calibration database tracks.

### Reliability

Very wide range. Each KOL gets calibrated:
- Some KOLs have 60-70% hit rate → high signal
- Some have 30-40% → noise
- Some have <30% → contra-indicator (consistent enough to bet against)

After 6 months tracking, you have calibrated weights per KOL. After 12 months, statistically meaningful.

See `specs/tier2-feature/002-influence-network-tracking.md` for full implementation.

## B.4 Tier 4: Crowd Sentiment & Pump Detection ⭐

### Sources

**Forums (public)**:
- F319 (forum cổ phiếu)
- VFPress
- Comments on CafeF/Vietstock articles

**Facebook public groups** (public, ToS-respecting):
- "Đầu tư chứng khoán Việt Nam" type groups (large public ones)
- Read-only, respect rate limits
- NEVER private groups

**Telegram public broadcast channels**:
- Stock-specific public channels
- Public chat rooms only

**Twitter/X**:
- VN finance Twitter (smaller but growing)

### Data Categories

```python
# Stored in BC-7 Crowd Sentiment
class SentimentSnapshot:
    snapshot_id: str
    ticker: Ticker
    captured_at: datetime
    window: Window               # 1H | 4H | 1D | 1W
    mention_count: int
    sentiment_distribution: SentimentDistribution  # categorical counts
    posting_velocity: float       # posts/hour
    unique_posters: int
    coordinated_posting_score: float  # 0-1, see pump detection
    sources: dict[str, int]       # source -> mention count

class Narrative:
    narrative_id: NarrativeId
    description: str               # "đầu tư công 2026"
    affected_tickers: list[Ticker]
    affected_sectors: list[Sector]
    first_detected_at: datetime
    current_phase: NarrativePhase  # INCUBATION | EMERGING | MAINSTREAM | SATURATION | EXHAUSTION | REVERSAL
    velocity_trend: str            # ACCELERATING | STEADY | DECELERATING
    counter_narratives: list[NarrativeId]
    
class PumpDetection:
    detection_id: str
    ticker: Ticker
    detected_at: datetime
    phase: PumpPhase  # PRE_PUMP | PUMP | DISTRIBUTION | DUMP | UNCERTAIN
    phase_confidence: float
    contributing_signals: list[SignalSnapshot]  # what triggered detection
    historical_similar_cases: list[PumpDetectionId]  # past matches
```

### LLM Role

- **Classify Vietnamese sentiment** (categorical, not numeric)
- **Detect coordinated posting** (template detection, timing clustering)
- **Identify narrative themes** in posts
- **Extract pump signatures** (specific language patterns)
- **Compare to historical labeled pump cases**

### Lead Time

Typically LAGS price. Crowd sentiment is mostly exhaustion signal:
- High crowd activity often = late stage
- Sentiment euphoria often = top forming
- Sentiment despair often = bottom forming

Useful primarily as **timing signal** (when narrative-driven move is exhausting), not as **direction signal**.

### Reliability

Mass behavior is noisy individually but structured statistically. Patterns reliable, individual posts not.

See `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` for full implementation.

## B.5 Cross-Tier Synthesis

### The Confluence Engine

Combines tier signals into actionable assessments. Lives in BC-8 Analysis.

```python
class ConfluenceAssessment:
    ticker: Ticker
    assessed_at: datetime
    tier_signals: dict[SignalTier, TierSignal]
    confluence_pattern: ConfluencePattern  # see patterns A.3
    confluence_strength: float  # how many tiers agree
    historical_pattern_matches: list[PatternMatch]
    historical_hit_rate: float | None  # if pattern has enough samples
    recommended_action: RecommendedAction  # WATCH | INVESTIGATE | THESIS_CANDIDATE | PUMP_AVOID
    reasoning: str  # LLM-generated, grounded in tier signals
```

### Decision Rules

Phase 1: Simple rules
- All 4 tiers agree positive → WATCH (potential thesis)
- T1+T2+T3 agree, T4 silent → INVESTIGATE (early opportunity)
- T4 hot, T1 weak → AVOID (potential top)
- T3 hot from low-credibility KOLs only, T1 weak → PUMP_AVOID

Phase 4: Karpathy-optimized weights
- Outer loop tunes signal weights based on historical hit rate
- Same patterns evaluated, but weights evolve

## B.6 Storage Strategy

### Tier 1 (high volume, time-series)
- TimescaleDB hypertables (price/volume)
- Postgres regular tables (fundamentals)
- Compression: TimescaleDB native after 7 days
- Retention: full history for prices, 10 years for fundamentals

### Tier 2 (medium volume, append-mostly)
- Postgres for metadata + extracted claims
- R2 for full article text (cheap storage)
- pgvector for semantic search across articles
- Retention: full history (cheap)

### Tier 3 (medium volume, mixed)
- Postgres for KOL profiles + recommendations + calibration
- R2 for video/podcast transcripts
- Retention: full history of recommendations + calibrated outcomes

### Tier 4 (high volume, low individual value)
- TimescaleDB for sentiment snapshots
- Postgres for narratives + pump detections
- R2 for raw posts (sample only, not all)
- Retention: aggregated retained forever, individual posts 90 days unless flagged

## B.7 Update Cadences

```yaml
# Defined in apps/data-pipeline/schedules.py

tier_1_hard_data:
  intraday: every 15 min during market hours (9:00-15:00 VN time)
  eod: 16:00 daily
  fundamentals: nightly poll for new filings
  macro: daily at 8:00

tier_2_official_narrative:
  news_polling: every 10 min
  broker_reports: daily at 18:00
  regulatory: every 4 hours

tier_3_influence_network:
  youtube_channels: daily at 20:00 (after most channels publish)
  facebook_fanpages: every 4 hours during active hours
  podcasts: hourly RSS check
  blogs: every 2 hours

tier_4_crowd_sentiment:
  forums: every 30 min
  facebook_groups: every 2 hours
  telegram: every 1 hour
  comments: with parent article fetch

cross_tier:
  confluence_engine: every 1 hour during market days
  pattern_matching: nightly at 22:00
  narrative_lifecycle_update: every 4 hours
```

## B.8 Cost Profile

Estimated costs for Phase 1 (Tier 1+2 only) for personal use:

```
Data sources: 0-2M VND/month (mostly free + light scraping)
LLM (Tier 2 extraction): ~5-10M VND/month
Compute (single VPS): 1-2M VND/month
Storage (R2): <0.5M VND/month
Total: ~10-15M VND/month
```

Phase 2 adds Tier 3+4:
```
+Whisper transcription: 3-5M VND/month
+LLM (Tier 3+4 extraction): 10-15M VND/month
+Storage growth: 1-2M VND/month
Total: ~25-35M VND/month
```

## B.9 Privacy & Legal

- All scraping respects robots.txt and reasonable rate limits
- User agent identifies as research tool with contact email
- Public sources only — never private groups, never paid leaks
- Personal data not retained beyond what's needed for analysis
- GDPR-style: if KOL requests their data removed, comply
- Output explicitly framed as personal research, never licensed advice

---

# PART C — PROVENANCE & REVIEW

## C.1 Why This Architecture (Not Alternative)

**Considered alternative**: Single-pipeline LLM approach (feed everything to LLM, get verdict)
- **Rejected because**: black box, no calibration possible, no compounding moat, hallucination risk extreme

**Considered alternative**: Pure quant (no LLM, no sentiment)
- **Rejected because**: misses VN-specific edge, gets value-trapped, can't detect pumps

**Considered alternative**: Three-tier (combine T3+T4)
- **Rejected because**: Influence Network and Crowd Sentiment have very different ingestion patterns, calibration logic, and meaning. Combining creates god-package. Separation enables independent evolution.

**Considered alternative**: Five-tier (split T1 into market data + fundamentals)
- **Rejected because**: They're both deterministic with same LLM role (none); the natural split is BC-1 vs BC-2 in architecture, not two separate signal tiers.

## C.2 Open Questions for Future Revision

- Should there be a Tier 5 for "insider" signals (block trades, unusual options activity)? Currently in BC-1 but possibly distinct.
- Should foreign flow get its own tier? Currently in BC-1 Market Data.
- How do we handle paid data sources cleanly when they enter (FiinPro)?
- When does Karpathy outer loop become reliable enough to trust weight updates?

## C.3 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Initial spec |

---

## Related Specs

- **Implementation specs (Tier 2)**:
  - `specs/tier2-feature/001-validate-investment-thesis.md` — uses confluence engine
  - `specs/tier2-feature/002-influence-network-tracking.md` — implements Tier 3
  - `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` — implements Tier 4
  - `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` — synthesizes tiers
  - `specs/tier2-feature/005-karpathy-outer-loop.md` — optimizes tier weights

- **Constitution**:
  - `agent-workspace/constitution/architecture.md` — 9 BC structure
  - `agent-workspace/constitution/financial-data-protocol.md` — data integrity rules
  - `agent-workspace/constitution/invariants.md` — I-S* stock-specific invariants
