---
spec_id: SPEC-2026-04-23-003
tier: 2
status: approved
version: 1.0
created: 2026-04-23
authors: [project-owner]
bounded_contexts: [Crowd Sentiment]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-004]
ubiquitous_language_terms: [Crowd Sentiment, Narrative, Narrative Phase, Pump Phase, Coordination Score, Mention Velocity, Posting Pattern, FOMO, Distribution, Counter-Narrative]
---

# SPEC: Crowd Sentiment & Pump Detection (BC-7)

> Implements Tier 4 of the four-tier signal architecture.
> Most Vietnam-specific edge — no commercial product tracks crowd behavior at this depth.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context

Vietnam stock market has an active online retail community: F319 forum, Facebook public groups with 50K-500K members, Telegram channels, comment sections on CafeF/Vietstock. This community's collective behavior follows patterns:

- **Narratives have lifecycles** (incubation → emerging → mainstream → saturation → exhaustion → reversal). Trading the narrative at right phase = alpha; buying at saturation = losses.

- **Pumps follow signatures**. Pump operators ("đội lái") don't vary their playbook much: quiet accumulation → narrative seeding through proxy accounts → sudden volume + price spike → KOL amplification → retail FOMO → distribution → dump. Each phase has detectable features.

- **Coordinated posting is detectable**. Same talking points, similar phrasing, clustered timing across supposedly independent accounts = coordinated messaging. LLMs can detect this at scale that humans cannot.

- **Crowd sentiment LAGS price**. By the time community is euphoric, the move is often 80% done. By the time despair sets in, bottom often forming. Sentiment is **timing signal for narrative phases**, not directional signal.

Major commercial products (FiinPro, Wichart, Stockbiz) don't provide this. It's labor-intensive and requires Vietnamese NLP — exactly what LLMs now enable.

## A.2 Core Use Cases

**UC-1 Pump Warning** — Alert when ticker shows pump signature: alert specifies suspected phase (pre-pump / pump / distribution / dump) with contributing signals and recommended action (avoid / exit / continue watching).

**UC-2 Narrative Tracking** — Track narratives (e.g., "đầu tư công 2026", "ngành thép phục hồi") through lifecycle phases. Alert when narrative reaches saturation (likely top forming).

**UC-3 Counter-Narrative Generator** — When a ticker reaches high sentiment (>80% bullish community), system auto-generates counter-narrative: what if this is wrong, what are bear cases, historical similar setups that failed.

**UC-4 Sentiment Momentum on Watchlist** — Daily: which of my watchlist stocks have meaningful sentiment changes? (Crowd suddenly notices = late; crowd turning negative on one I own = signal.)

**UC-5 FOMO Detection** — Detect when I'm about to FOMO — if I'm querying a ticker that's currently in saturation phase with high pump signals, system reminds me of pattern.

## A.3 Business Rules

**BR-1 Public Only** — Forums (F319 public section), public Facebook groups (non-restricted), public Telegram channels, article comments. **NEVER private groups, never Zalo private, never DMs.**

**BR-2 Respect Rate Limits** — Every scraper has declared RPM cap; source-specific polite user agent identifying as research tool with contact.

**BR-3 Aggregate, Don't Store Individuals** — Individual posts retained only for labeled training data + random sample for debugging. Aggregate metrics retained forever. (Privacy + storage cost + legal hygiene.)

**BR-4 Vietnamese Sentiment Categorical** — Sentiment scored categorically (STRONGLY_BULLISH | BULLISH | NEUTRAL | BEARISH | STRONGLY_BEARISH). Never numeric "80% bullish" from LLM (I-S1 + Rule 7).

**BR-5 Pump Detection Must Be Backtest-Validated** — Rules tested on historical labeled pumps before going live. Minimum precision > 0.5, recall > 0.3 on hold-out.

**BR-6 Counter-Narrative Mandatory for Hot Stocks** — When community sentiment >80% bullish on a ticker we're considering, system MUST produce counter-narrative before any positive signal issued (I-S13).

**BR-7 Narrative Phase Transitions Event-Driven** — Each narrative has phase; transitions trigger events and alerts. Phases don't skip (INCUBATION → EMERGING → MAINSTREAM → SATURATION → EXHAUSTION → REVERSAL).

**BR-8 Coordination Score Conservative** — Coordination detection has high threshold (0.8+) before flagging to avoid false accusations. Flagged ≠ confirmed pump; requires human review.

**BR-9 Historical Pattern Matching Required** — Every pump detection references historical similar cases. If no historical analog, flag as "novel pattern, low confidence".

**BR-10 No Public Accusations** — System output frames as "pattern detected, exercise caution" — never names specific operators or accuses. Legal safety.

## A.4 Success Criteria

**Month 6**:
- Sentiment tracking for top 100 stocks operational
- 5+ labeled historical pumps in training set
- First pump warning issued before broad retail recognition
- First narrative tracked through full lifecycle

**Month 9**:
- Pump detection precision >0.5 on hold-out
- 15+ narratives tracked; 3+ completed full lifecycle
- Counter-narrative generator routinely catches over-enthusiasm

**Month 12**:
- Documented case: system warned me about pump I was considering
- Documented case: system detected narrative shift before I noticed
- Crowd sentiment integrates into thesis validation (BC-8)

**Qualitative**:
- I genuinely delay FOMO decisions because system shows late phase
- Counter-narratives have changed at least 2 decisions
- I trust pump warnings enough to act on them (usually: avoid)

## A.5 Out of Scope

- Individual post content analysis beyond aggregation
- Targeting specific individuals (no naming, no accusations)
- Real-time stream processing (hourly batch acceptable Phase 1-2)
- Non-Vietnamese sentiment (English later)
- Predicting price direction from sentiment alone

---

# PART B — AGENT CONTRACT

## B.1 Key Domain Model

```python
# packages/domain/crowd/models/

class Sentiment(Enum):
    STRONGLY_BULLISH = "strongly_bullish"
    BULLISH = "bullish"
    NEUTRAL = "neutral"
    BEARISH = "bearish"
    STRONGLY_BEARISH = "strongly_bearish"

class NarrativePhase(Enum):
    INCUBATION = "incubation"       # first mentions, few
    EMERGING = "emerging"           # velocity rising, not mainstream yet
    MAINSTREAM = "mainstream"       # major KOLs + news covering
    SATURATION = "saturation"       # everyone knows, no new bulls to convert
    EXHAUSTION = "exhaustion"       # velocity declining despite mentions
    REVERSAL = "reversal"           # counter-narrative emerging
    DEAD = "dead"                   # no more mentions

class PumpPhase(Enum):
    PRE_PUMP = "pre_pump"           # low-volume accumulation, whispers
    PUMP = "pump"                   # volume + price spike, narrative seeding
    DISTRIBUTION = "distribution"   # high volume flat price, novice posts
    DUMP = "dump"                   # price crash, narrative shift to confused
    UNCERTAIN = "uncertain"

@dataclass
class SentimentSnapshot:
    """Aggregate sentiment for a ticker over a time window."""
    snapshot_id: str
    ticker: Ticker
    captured_at: datetime
    window: Window  # 1H | 4H | 1D | 1W
    mention_count: int
    sentiment_distribution: dict[Sentiment, int]  # counts per category
    posting_velocity: float         # posts/hour
    unique_posters: int
    coordinated_posting_score: float # 0-1, template/timing similarity
    sources: dict[str, int]         # source -> mention count
    top_terms: list[str]            # most common phrases
    source_posts_sample: list[str]  # max 20 sample IDs for debugging

    def dominant_sentiment(self) -> Sentiment:
        return max(self.sentiment_distribution.items(), key=lambda x: x[1])[0]

    def bullish_ratio(self) -> float:
        total = sum(self.sentiment_distribution.values())
        if total == 0:
            return 0.0
        bullish = (self.sentiment_distribution.get(Sentiment.BULLISH, 0)
                  + self.sentiment_distribution.get(Sentiment.STRONGLY_BULLISH, 0))
        return bullish / total

@dataclass
class Narrative:
    narrative_id: NarrativeId
    description: str              # "đầu tư công 2026"
    thematic_keywords: list[str]
    affected_tickers: list[Ticker]
    affected_sectors: list[Sector]
    first_detected_at: datetime
    current_phase: NarrativePhase
    phase_history: list[PhaseTransition]
    velocity_trend: str           # ACCELERATING | STEADY | DECELERATING
    counter_narrative_ids: list[NarrativeId]
    related_narrative_ids: list[NarrativeId]

    def days_in_current_phase(self) -> int:
        if not self.phase_history:
            return (datetime.utcnow() - self.first_detected_at).days
        return (datetime.utcnow() - self.phase_history[-1].transitioned_at).days

@dataclass
class PhaseTransition:
    from_phase: NarrativePhase
    to_phase: NarrativePhase
    transitioned_at: datetime
    trigger_signals: list[str]   # e.g., ["mention_velocity_declining", "new_counter_narrative_emerged"]

@dataclass
class PumpDetection:
    detection_id: str
    ticker: Ticker
    detected_at: datetime
    phase: PumpPhase
    phase_confidence: float       # 0-1
    contributing_signals: list[SignalContribution]
    historical_similar_cases: list[str]  # detection_ids of past matches
    recommended_action: PumpAction  # AVOID | EXIT_IF_HOLDING | WATCH | INFORMATIONAL
    evidence_summary: str         # LLM-generated, grounded

@dataclass
class SignalContribution:
    signal_name: str              # "volume_spike_without_news", "coordinated_posting_detected"
    signal_value: float
    weight: float
    contribution_to_detection: float
```

## B.2 Key Domain Events

```python
SentimentSnapshotCaptured(ticker, window, captured_at, dominant_sentiment, mention_count)
NarrativeEmerged(narrative_id, description, affected_tickers, first_detected_at)
NarrativePhaseChanged(narrative_id, from_phase, to_phase, affected_tickers, transitioned_at)
PumpPhaseDetected(detection_id, ticker, phase, phase_confidence, detected_at)
CoordinatedPostingDetected(ticker, posting_pattern, coordination_score, detected_at)
CounterNarrativeRequested(ticker, trigger_sentiment, requested_at)
CounterNarrativeGenerated(ticker, bear_points, historical_analogs, generated_at)
```

## B.3 Core Use Cases

### UC-1: Capture Sentiment Snapshot

```python
class CaptureSentimentSnapshotUseCase:
    """Every N hours: aggregate new posts for tracked tickers into snapshot."""

    async def execute(self, ticker: Ticker, window: Window) -> SentimentSnapshot:
        from_time = datetime.utcnow() - window.duration
        raw_posts = await self.post_aggregator.fetch_recent(ticker, from_time)

        # LLM sentiment classification (categorical, batched)
        classified = await self.sentiment_classifier.classify_batch(raw_posts)

        # Coordination detection
        coord_score = self.coordination_detector.score(
            posts=classified,
            features=[TEMPLATE_SIMILARITY, TIMING_CLUSTER, ACCOUNT_AGE_DISTRIBUTION],
        )

        # Aggregate (deterministic, no LLM for numbers)
        dist = defaultdict(int)
        sources = defaultdict(int)
        for post in classified:
            dist[post.sentiment] += 1
            sources[post.source] += 1

        snapshot = SentimentSnapshot(
            snapshot_id=new_id(),
            ticker=ticker,
            captured_at=datetime.utcnow(),
            window=window,
            mention_count=len(classified),
            sentiment_distribution=dict(dist),
            posting_velocity=len(classified) / window.hours,
            unique_posters=len({p.poster_id for p in classified}),
            coordinated_posting_score=coord_score,
            sources=dict(sources),
            top_terms=self._extract_top_terms(classified),
            source_posts_sample=[p.post_id for p in random.sample(classified, min(20, len(classified)))],
        )
        await self.snapshot_repo.save(snapshot)
        await self.event_bus.publish(SentimentSnapshotCaptured(...))

        if coord_score >= 0.8:
            await self.event_bus.publish(CoordinatedPostingDetected(
                ticker=ticker, posting_pattern=self._describe_pattern(classified),
                coordination_score=coord_score, detected_at=datetime.utcnow(),
            ))
        return snapshot
```

### UC-2: Update Narrative Lifecycle

```python
class UpdateNarrativeLifecycleUseCase:
    """Re-evaluate each active narrative: has phase changed?"""

    async def execute(self) -> list[PhaseTransition]:
        active_narratives = await self.narrative_repo.get_active()
        transitions = []
        for narrative in active_narratives:
            new_phase = await self._compute_current_phase(narrative)
            if new_phase != narrative.current_phase:
                transition = PhaseTransition(
                    from_phase=narrative.current_phase,
                    to_phase=new_phase,
                    transitioned_at=datetime.utcnow(),
                    trigger_signals=self._identify_triggers(narrative, new_phase),
                )
                narrative.phase_history.append(transition)
                narrative.current_phase = new_phase
                await self.narrative_repo.save(narrative)
                transitions.append(transition)
                await self.event_bus.publish(NarrativePhaseChanged(...))
        return transitions

    async def _compute_current_phase(self, narrative: Narrative) -> NarrativePhase:
        """Deterministic phase classifier based on recent metrics."""
        recent_metrics = await self._gather_narrative_metrics(narrative, lookback_days=14)
        return self.phase_classifier.classify(recent_metrics, narrative.current_phase)

class NarrativePhaseClassifier:
    """Deterministic rules. Tunable via config."""

    def classify(self, metrics: NarrativeMetrics, current: NarrativePhase) -> NarrativePhase:
        # INCUBATION: low mentions, isolated sources
        if metrics.avg_mentions_per_day < 5 and metrics.unique_sources < 3:
            return NarrativePhase.INCUBATION

        # EMERGING: mentions rising fast, still <20% from major sources
        if metrics.velocity_trend == "ACCELERATING" and metrics.major_source_share < 0.2:
            return NarrativePhase.EMERGING

        # MAINSTREAM: major news + broker coverage + KOL attention
        if metrics.major_source_share >= 0.3 and metrics.kol_mention_count >= 3:
            # Distinguish MAINSTREAM vs SATURATION
            if metrics.bullish_ratio >= 0.8 and metrics.new_unique_posters_trend == "DECELERATING":
                return NarrativePhase.SATURATION
            return NarrativePhase.MAINSTREAM

        # EXHAUSTION: high mentions but declining velocity
        if metrics.avg_mentions_per_day >= 20 and metrics.velocity_trend == "DECELERATING":
            return NarrativePhase.EXHAUSTION

        # REVERSAL: counter-narratives emerging
        if metrics.counter_narrative_velocity > metrics.velocity * 0.3:
            return NarrativePhase.REVERSAL

        # DEAD: almost no mentions
        if metrics.avg_mentions_per_day < 1:
            return NarrativePhase.DEAD

        return current  # no change
```

### UC-3: Detect Pump Phase

```python
class DetectPumpPhaseUseCase:
    """Evaluate ticker for pump phase. Multi-signal deterministic + LLM evidence summary."""

    async def execute(self, ticker: Ticker) -> PumpDetection | None:
        # Gather signals from Tier 1 + Tier 3 + Tier 4
        signals = await self._gather_signals(ticker)

        # Deterministic phase classification
        phase, confidence, contributing = self.pump_classifier.classify(signals)

        if phase == PumpPhase.UNCERTAIN or confidence < 0.5:
            return None  # don't emit low-confidence detections

        # Historical matching
        similar = await self.pattern_matcher.find_similar_cases(
            ticker_signals=signals,
            top_k=5,
        )

        # LLM evidence summary (qualitative, grounded)
        summary = await self.llm_summarizer.summarize_pump_evidence(
            ticker=ticker,
            signals=contributing,
            historical_matches=similar,
        )

        detection = PumpDetection(
            detection_id=new_id(),
            ticker=ticker,
            detected_at=datetime.utcnow(),
            phase=phase,
            phase_confidence=confidence,
            contributing_signals=contributing,
            historical_similar_cases=[c.detection_id for c in similar],
            recommended_action=self._action_for_phase(phase),
            evidence_summary=summary,
        )
        await self.detection_repo.save(detection)
        await self.event_bus.publish(PumpPhaseDetected(...))
        return detection

class PumpPhaseClassifier:
    """Deterministic rules. Weights tuned by Karpathy outer loop."""

    def classify(self, signals: TickerSignals) -> tuple[PumpPhase, float, list[SignalContribution]]:
        scores = {phase: 0.0 for phase in PumpPhase}
        contributions = []

        # PRE_PUMP signals (accumulation without news)
        if signals.price_change_30d < 0.10 and signals.volume_30d_avg_rising:
            scores[PumpPhase.PRE_PUMP] += 0.3
            contributions.append(SignalContribution("quiet_accumulation", ...))
        if signals.t3_kol_mentions_rising and signals.t2_news_silent:
            scores[PumpPhase.PRE_PUMP] += 0.3
            contributions.append(SignalContribution("kol_whispers_no_news", ...))

        # PUMP signals (spike + narrative)
        if signals.price_5d_change > 0.20 and signals.volume_5d_avg / signals.volume_30d_avg > 3:
            scores[PumpPhase.PUMP] += 0.4
            contributions.append(SignalContribution("volume_price_spike", ...))
        if signals.t3_kol_mentions_peak and signals.t4_novice_post_share > 0.5:
            scores[PumpPhase.PUMP] += 0.3
            contributions.append(SignalContribution("fomo_active", ...))

        # DISTRIBUTION signals (high volume, price stalling)
        if signals.volume_5d_avg / signals.volume_30d_avg > 2 and abs(signals.price_5d_change) < 0.05:
            scores[PumpPhase.DISTRIBUTION] += 0.4
            contributions.append(SignalContribution("volume_without_price", ...))
        if signals.t4_novice_post_share > 0.7 and signals.t4_coordination_score < 0.3:
            # Novice FOMO dominant, sophisticated exiting
            scores[PumpPhase.DISTRIBUTION] += 0.3
            contributions.append(SignalContribution("novice_fomo_dominant", ...))

        # DUMP signals
        if signals.price_5d_change < -0.15 and signals.volume_5d_avg_declining:
            scores[PumpPhase.DUMP] += 0.5
            contributions.append(SignalContribution("price_crash_volume_decline", ...))

        # Pick highest
        best_phase = max(scores.items(), key=lambda x: x[1])
        if best_phase[1] < 0.4:
            return PumpPhase.UNCERTAIN, best_phase[1], contributions

        # Keep only contributions for winning phase
        return best_phase[0], best_phase[1], [c for c in contributions if c.phase == best_phase[0]]
```

### UC-4: Generate Counter-Narrative

```python
class GenerateCounterNarrativeUseCase:
    """When sentiment extremely one-sided, force production of contrarian analysis."""

    async def execute(self, ticker: Ticker, trigger: CounterNarrativeTrigger) -> CounterNarrative:
        # Gather material for contrarian analysis
        recent_sentiment = await self.snapshot_repo.get_recent(ticker, window=Window.ONE_WEEK)
        bullish_points = await self.narrative_repo.get_bullish_points_for(ticker)

        # Find historical analogs: times where similar sentiment/price/fundamental setup existed
        analogs = await self.historical_analog_finder.find(
            ticker=ticker,
            setup_description=self._describe_current_setup(ticker),
            top_k=5,
        )
        failing_analogs = [a for a in analogs if a.subsequent_return_12m < -0.10]

        # LLM generates bear points grounded in (1) current bullish consensus,
        # (2) historical analogs' failure modes, (3) structural risks in sector
        bear_points = await self.llm_bear_generator.generate(
            ticker=ticker,
            bullish_consensus=bullish_points,
            failing_analogs=failing_analogs,
            structural_risks=await self.risk_repo.get_sector_risks(ticker),
        )

        counter = CounterNarrative(
            ticker=ticker,
            generated_at=datetime.utcnow(),
            trigger=trigger,
            bear_points=bear_points,
            historical_analogs=analogs,
            failing_analog_details=failing_analogs,
            bullish_consensus_summary=bullish_points,
        )
        await self.counter_repo.save(counter)
        await self.event_bus.publish(CounterNarrativeGenerated(...))
        return counter
```

## B.4 Infrastructure Adapters

**Post aggregators** (`packages/infrastructure/crowd/aggregators/`):
- `F319ForumAggregator` — F319 public sections
- `FacebookPublicGroupAggregator` — Graph API for public groups only
- `TelegramPublicChannelAggregator` — Bot API for public broadcast
- `ArticleCommentsAggregator` — CafeF/Vietstock comments via scraping

**Sentiment classifier** (`packages/infrastructure/crowd/sentiment/`):
- `LlmSentimentClassifier` — Claude Haiku (cost-efficient for volume), categorical output
- Batched: 50 posts per LLM call, output JSON array of sentiment labels

**Coordination detector** (`packages/infrastructure/crowd/coordination/`):
- Template similarity: embedding-based, flag if >10 posts with cosine similarity >0.9 within 1h
- Timing cluster: flag if >5 accounts post within 3 minutes of each other repeatedly
- Account age: flag if >50% of bullish posters are <30-day-old accounts

**Historical analog finder** (`packages/infrastructure/crowd/analogs/`):
- Setup fingerprint: (price_trajectory + sentiment_shape + fundamental_state)
- Embedding-based similarity search on historical ticker-periods
- Returns top-K with subsequent outcomes attached

## B.5 Database Schema (key tables)

```sql
-- db/migrations/007_crowd_sentiment.sql

-- TimescaleDB hypertable for sentiment snapshots
CREATE TABLE sentiment_snapshots (
    snapshot_id TEXT NOT NULL,
    ticker TEXT NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL,
    window TEXT NOT NULL,
    mention_count INT NOT NULL,
    sentiment_distribution JSONB NOT NULL,
    posting_velocity REAL NOT NULL,
    unique_posters INT NOT NULL,
    coordinated_posting_score REAL NOT NULL,
    sources JSONB NOT NULL,
    top_terms TEXT[] NOT NULL,
    PRIMARY KEY (snapshot_id, captured_at)
);
SELECT create_hypertable('sentiment_snapshots', 'captured_at');
CREATE INDEX idx_snapshots_ticker_time ON sentiment_snapshots(ticker, captured_at DESC);

CREATE TABLE narratives (
    narrative_id TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    thematic_keywords TEXT[] NOT NULL,
    affected_tickers TEXT[] NOT NULL,
    affected_sectors TEXT[] NOT NULL,
    first_detected_at TIMESTAMPTZ NOT NULL,
    current_phase TEXT NOT NULL,
    phase_history JSONB NOT NULL DEFAULT '[]',
    velocity_trend TEXT,
    counter_narrative_ids TEXT[],
    related_narrative_ids TEXT[]
);
CREATE INDEX idx_narratives_phase ON narratives(current_phase);

CREATE TABLE pump_detections (
    detection_id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    detected_at TIMESTAMPTZ NOT NULL,
    phase TEXT NOT NULL,
    phase_confidence REAL NOT NULL,
    contributing_signals JSONB NOT NULL,
    historical_similar_cases TEXT[],
    recommended_action TEXT NOT NULL,
    evidence_summary TEXT NOT NULL,
    subsequent_outcome JSONB                -- filled post-hoc for calibration
);
CREATE INDEX idx_pumps_ticker_time ON pump_detections(ticker, detected_at DESC);

CREATE TABLE counter_narratives (
    counter_id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    generated_at TIMESTAMPTZ NOT NULL,
    trigger TEXT NOT NULL,
    bear_points JSONB NOT NULL,
    historical_analogs JSONB NOT NULL,
    failing_analog_details JSONB NOT NULL,
    bullish_consensus_summary TEXT NOT NULL
);

-- Labeled training set (hand-labeled by user + agent assistance)
CREATE TABLE labeled_pumps (
    label_id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    phases JSONB NOT NULL,                  -- [{phase, from_date, to_date}, ...]
    features_at_detection JSONB NOT NULL,
    subsequent_outcome JSONB NOT NULL,       -- return 30d/90d post-label
    labeled_by TEXT NOT NULL,                -- 'user' | 'agent_with_review'
    labeled_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## B.6 Update Cadences

- **Forum scraping**: every 30 min
- **FB group scraping**: every 2h
- **Telegram scraping**: every 1h
- **Comments scraping**: with parent article fetch (Tier 2 cycle)
- **Sentiment snapshot aggregation**: top 100 tickers every 1h, others every 4h
- **Narrative phase update**: every 4h
- **Pump detection scan**: every 2h during market days
- **Counter-narrative trigger**: event-driven on sentiment threshold crossing
- **Historical pattern backfill**: nightly

## B.7 Training & Calibration

**Labeled pump dataset** (seeded manually):
- User labels 10-20 historical pump events from memory (2021-2024 VN market)
- For each: start/end dates, phase transitions, tickers involved, subsequent outcome
- Stored in `eval-sets/labeled-pumps/`
- Used to validate pump classifier precision/recall

**Sentiment classifier calibration**:
- Hand-label 200 posts for sentiment
- Run classifier, measure per-label accuracy
- If <85% per category, iterate on prompt

**Narrative phase classifier calibration**:
- Trace 5 historical narratives through their lifecycle
- Compare classifier phases to ground truth
- Tune thresholds until ≥80% agreement

## B.8 Quality Gates

**Deterministic**:
- Sentiment returns enum only (schema enforces)
- Coordination score in [0,1]
- Pump confidence in [0,1]
- Bootstrap test: run same data twice, identical classifications

**Probabilistic** (separate agent):
- Sample 2% of sentiment classifications for human review
- Pump detection cases all go to manual review first 3 months
- Counter-narrative quality: reviewed before delivered to user

**Human**:
- Every pump detection in Phase 1 reviewed by user before alert fires
- Monthly: review false positives, add to training data
- Quarterly: recalibrate narrative classifier thresholds

## B.9 Tasks (initial breakdown)

**Phase 1** (foundation, ~4 weeks):
- Post aggregators for F319 + 2 major FB public groups
- LlmSentimentClassifier with calibration dataset
- SentimentSnapshot aggregation pipeline
- Basic dashboard showing ticker sentiment

**Phase 2** (narrative tracking, ~3 weeks):
- Narrative detection + lifecycle classifier
- Phase transition events + history
- Narrative browser UI
- Backfill 5 historical narratives

**Phase 3** (pump detection, ~4 weeks):
- Coordination detector
- Historical pump labeling (user + agent assist)
- PumpPhaseClassifier with backtest validation
- Historical analog finder

**Phase 4** (counter-narrative, ~2 weeks):
- CounterNarrativeGenerator with grounded LLM
- Integration with thesis validation (BC-8)
- UI for reviewing counter-narratives

## B.10 Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Pump operators evolve patterns | HIGH | HIGH | Continuous training data refresh, multi-signal (one signal insufficient), don't publicize detection logic |
| False accuse legitimate trader | MEDIUM | HIGH | Never name individuals; frame as "pattern detected, exercise caution" |
| Vietnamese sentiment accuracy <target | MEDIUM | MEDIUM | Curated training data, iterative prompt refinement, human sample review |
| Legal/ToS issues with scraping | MEDIUM | HIGH | Public sources only, respect robots.txt, identify UA, polite rate limits, consult legal if unsure |
| Low-quality historical labeled data | HIGH | MEDIUM | Start with user's personal memory, agent-assisted expansion, external reviewer |
| Alerts too noisy, user ignores | HIGH | HIGH | Strict thresholds, historical precision requirement, human-review-first for Phase 1 |

---

# PART C — PROVENANCE & REVIEW

## C.1 Why This Design

**Considered alternative: Sentiment as single numeric score**
- Rejected: violates I-S1 (no LLM math). Categorical sentiment + deterministic aggregation is cleaner.

**Considered alternative: Store every individual post**
- Rejected: Storage cost + privacy + legal exposure. Aggregates sufficient; sample 20 per snapshot for debugging.

**Considered alternative: Let LLM declare pump phase directly**
- Rejected: Not reproducible, not calibratable. Deterministic rules + LLM evidence summary is reproducible.

**Considered alternative: Don't generate counter-narratives**
- Rejected: Groupthink is biggest risk in VN market. Counter-narrative forces consideration.

## C.2 Open Questions

- When narrative reaches SATURATION on a ticker we hold, trigger sell signal? Or just warn?
- Should we track narrative origination (who seeded it)? Potentially valuable, potentially risky.
- How to handle crypto-adjacent narratives (some VN stocks have crypto exposure, community overlaps)?
- When user's watchlist has heavy overlap with hot narrative, emphasize warnings?

## C.3 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Initial |
