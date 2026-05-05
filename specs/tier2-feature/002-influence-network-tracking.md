---
spec_id: SPEC-2026-04-23-002
tier: 2
status: approved
version: 1.0
created: 2026-04-23
authors: [project-owner]
bounded_contexts: [Influence Network, Calibration]
related_specs: [SPEC-2026-04-23-T1-001, SPEC-2026-04-23-004, SPEC-2026-04-23-005]
ubiquitous_language_terms: [KOL, Channel, Recommendation, Credibility Score, Calibration, Outcome Review, Bayesian Update, Confluence, Pumper]
---

# SPEC: Influence Network Tracking System (BC-6)

> Implements Tier 3 of the four-tier signal architecture.
> The single most edge-creating component for the Vietnamese market.

---

# PART A — BUSINESS SPECIFICATION

## A.1 Context & Opportunity

In Vietnam stock market, KOLs (YouTube channels, Facebook influencers, podcast hosts, personal blogs) **measurably move prices**. Some KOL recommendations precede 3-7% moves within days. Others are inverse indicators (their recommendations often mark tops).

**The problem**: no way to know which KOLs to trust until you've watched them for years and remembered their calls. Retail investors typically follow the loudest voice or the most recent video, leading to poor outcomes.

**The opportunity**: systematically track every KOL's recommendations + outcomes, building a calibration database that scores credibility per KOL, per sector, per timeframe. After 6-12 months, this becomes proprietary data no one can replicate without starting equally early.

**Why this is proprietary**: US/global quant funds don't do this because the KOL ecosystem doesn't affect efficient markets. Vietnam commercial products (FiinPro, Wichart) don't do it because it's labor-intensive — exactly what LLMs now solve at scale.

## A.2 Core Use Cases

**UC-1 Daily Digest** — Daily 21:00 summary of all new recommendations from tracked KOLs, sorted by credibility, with flip alerts.

**UC-2 Per-Ticker Sentiment** — "Show me all KOL recommendations on HPG last 30 days" → chronological list weighted by credibility, disagreement flagged.

**UC-3 Confluence Detection** — Alert when ≥3 high-credibility KOLs converge on same ticker within 7 days.

**UC-4 Calibration Inspection** — Browse each KOL's track record: overall/sector/timeframe hit rates, Bayesian CI, recent hits/misses.

**UC-5 Pump Operator Detection** — Warn when known pumper (high frequency of recommendations that subsequently dump) pushes a stock.

## A.3 Business Rules

**BR-1 Public Only** — Data sourced exclusively from public channels (YouTube public videos, public Facebook fanpages, public Telegram broadcast channels, public podcasts, public blogs). Never private groups, never paid leaks.

**BR-2 Calibration Required** — Every KOL has credibility score before counted in confluence. New KOLs "provisional" until 10 evaluated recommendations.

**BR-3 Outcome Tracking Mandatory** — Every extracted recommendation gets scheduled reviews at 1m/3m/6m/12m. Reviews run automatically when due.

**BR-4 Bayesian Updates** — Credibility via Bayesian inference, not naive averaging. Skeptical prior (Beta(5,5) ≈ 50% with weak confidence). Each outcome updates posterior.

**BR-5 Sector & Timeframe Disaggregation** — Hit rate computed per sector and per timeframe, not just overall. A KOL may excel at banking short-term but fail at real estate long-term.

**BR-6 Extraction Confidence Threshold** — Recommendations with `extraction_confidence < 0.7` NOT counted in calibration. Sent to manual review queue.

**BR-7 Conditional Recommendations Separated** — "Buy if breaks 30k" tracked separately. Outcome evaluated only if condition met; else marked INVALID (not MISS).

**BR-8 KOL Style Classification** — FUNDAMENTAL | TECHNICAL | NARRATIVE | PUMPER | MIXED. Calibration weights vary by style.

**BR-9 Flip-Flop Penalty** — KOLs with >3 reversals in 6 months on same ticker get reduced weight. Indicates confusion or audience-bait.

**BR-10 Provenance Required** — source_url + timestamp_in_source + transcript_excerpt (≤500 chars) + extractor_model + extractor_version + extracted_at. Without these, insert fails.

## A.4 Success Criteria

**Month 3**: 15+ KOLs tracked. 150+ recommendations extracted. Pipeline running daily reliably.

**Month 6**: 30+ KOLs. 500+ recommendations. 200+ have ≥3-month outcome data. First 5 KOLs with CI width <15% (statistically meaningful). First confluence alert triggered.

**Month 12**: 50+ KOLs. 1500+ recommendations. 10+ KOLs with meaningful calibration. Documented cases of system catching pumps early. Personal "list of trusted KOLs" calibrated, not intuited.

**Qualitative**: I genuinely consult the KOL ranking before taking a position. Have changed ≥3 decisions based on KOL credibility insights. Identified ≥2 previously-trusted "pumpers".

## A.5 Out of Scope (this spec)

- Private channel scraping (legal/ethical)
- Real-time extraction (T+1 day acceptable Phase 2)
- Multi-language (Vietnamese only Phase 1-2)
- Audience sentiment of KOL videos (that's BC-7)
- Auto-trading on confluence (always human decision)

---

# PART B — AGENT CONTRACT

## B.1 Key Domain Model

```python
# packages/domain/influence/models/

@dataclass
class Kol:
    kol_id: KolId
    name: str
    primary_channel_id: ChannelId
    secondary_channel_ids: list[ChannelId]
    style: KolStyle              # FUNDAMENTAL | TECHNICAL | NARRATIVE | PUMPER | MIXED
    status: KolStatus            # PROVISIONAL | ACTIVE | PAUSED | RETIRED | BLACKLISTED
    sectors_covered: list[Sector]
    credibility: CredibilityScore | None  # None during PROVISIONAL

@dataclass
class Recommendation:
    recommendation_id: RecommendationId
    kol_id: KolId
    channel_id: ChannelId
    source_url: str              # PROVENANCE
    timestamp_in_source: str     # e.g. "12:34-13:02" for video
    transcript_excerpt: str      # ≤500 chars, exact quote
    ticker: Ticker
    intent: Intent               # STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID
    conditions: list[str]        # ["if breaks 30k"]
    timeframe: Timeframe         # INTRADAY | DAYS | WEEKS | MONTHS | LONG_TERM
    extraction_confidence: float # 0-1, LLM's confidence in extraction
    extractor_model: str
    extractor_version: str
    published_at: datetime
    extracted_at: datetime
    flip_from_recommendation_id: RecommendationId | None

@dataclass
class CredibilityScore:
    kol_id: KolId
    n_evaluated: int
    n_hits: int
    n_misses: int
    n_partial: int
    # Beta posterior
    posterior_alpha: float
    posterior_beta: float
    bayesian_mean: float
    bayesian_ci_low: float       # 5th pct
    bayesian_ci_high: float      # 95th pct
    sector_scores: dict[Sector, SectorScore]
    timeframe_scores: dict[Timeframe, TimeframeScore]
    last_updated_at: datetime

    def is_statistically_meaningful(self) -> bool:
        return (self.bayesian_ci_high - self.bayesian_ci_low) < 0.15

    def is_high_credibility(self) -> bool:
        return self.bayesian_mean >= 0.6 and self.is_statistically_meaningful()

@dataclass
class OutcomeReview:
    review_id: str
    recommendation_id: RecommendationId
    review_window: ReviewWindow  # ONE_MONTH | THREE_MONTH | SIX_MONTH | TWELVE_MONTH
    scheduled_at: datetime
    completed_at: datetime | None
    status: OutcomeStatus        # PENDING | HIT | MISS | PARTIAL | INVALID | INCONCLUSIVE
    price_at_rec: Money | None
    price_at_review: Money | None
    return_pct: float | None
    benchmark_return_pct: float | None  # VN-Index over same period
    excess_return_pct: float | None
```

## B.2 Key Domain Events

```python
RecommendationExtracted(recommendation_id, kol_id, ticker, intent, extraction_confidence, extracted_at)
OutcomeReviewScheduled(review_id, recommendation_id, review_window, due_at)
OutcomeReviewCompleted(review_id, recommendation_id, status, excess_return_pct)
CredibilityScoreUpdated(kol_id, old_mean, new_mean, n_evaluated, updated_at)
HighCredibilityFlipDetected(kol_id, ticker, from_rec_id, to_rec_id, detected_at)
ConfluenceDetected(ticker, direction, converging_rec_ids, confluence_strength, detected_at)
```

## B.3 Core Use Cases

### UC-1: Ingest Channel Content

```python
class IngestChannelContentUseCase:
    """Scrape new content from channel → transcribe → extract recommendations → schedule reviews."""

    async def execute(self, channel_id: ChannelId) -> IngestResult:
        channel = await self.channel_repo.get(channel_id)
        new_content = await self._fetch_new_content(channel)

        for content in new_content:
            transcript = await self.transcriber.transcribe(content)
            recs = await self.extractor.extract(transcript, source_metadata=content.metadata)

            for rec in recs:
                if rec.extraction_confidence < 0.7:
                    await self.manual_review_queue.enqueue(rec)
                    continue

                # Flip detection
                prior = await self.recommendation_repo.find_recent_for_kol_ticker(
                    kol_id=channel.kol_id, ticker=rec.ticker, lookback_days=180
                )
                if prior and self._is_reversal(prior, rec):
                    rec.flip_from_recommendation_id = prior.recommendation_id

                await self.recommendation_repo.save(rec)
                for window in [ONE_MONTH, THREE_MONTH, SIX_MONTH, TWELVE_MONTH]:
                    await self.scheduler.schedule_outcome_review(rec.recommendation_id, window)

                await self.event_bus.publish(RecommendationExtracted(...))
                if rec.flip_from_recommendation_id and self._is_high_credibility(channel.kol_id):
                    await self.event_bus.publish(HighCredibilityFlipDetected(...))
```

### UC-2: Evaluate Outcome Review

```python
class EvaluateOutcomeReviewUseCase:
    """Run a due review: compare recommendation to actual price action."""

    async def execute(self, review_id: str) -> OutcomeReview:
        review = await self.review_repo.get(review_id)
        rec = await self.recommendation_repo.get(review.recommendation_id)

        if rec.is_conditional():
            condition_met = await self.condition_evaluator.evaluate(
                conditions=rec.conditions,
                ticker=rec.ticker,
                from_date=rec.published_at,
                to_date=review.scheduled_at,
            )
            if not condition_met:
                review.status = INVALID
                review.notes = "Condition never met during review period"
                return await self.review_repo.save(review)

        # Get prices with point-in-time safety
        price_at_rec = await self.quote_repo.get_close_on(
            ticker=rec.ticker,
            date=rec.published_at.date() + timedelta(days=1),  # next-day open assumption
        )
        price_at_review = await self.quote_repo.get_close_on(rec.ticker, review.scheduled_at.date())
        benchmark_return = await self.benchmark_service.get_index_return(
            "VN-INDEX", rec.published_at.date(), review.scheduled_at.date()
        )

        review.return_pct = (price_at_review - price_at_rec) / price_at_rec
        review.benchmark_return_pct = benchmark_return
        review.excess_return_pct = review.return_pct - benchmark_return
        review.status = self._evaluate_by_intent(rec.intent, review.excess_return_pct, rec.timeframe)
        review.completed_at = datetime.utcnow()
        await self.review_repo.save(review)

        # Trigger credibility recompute on 3-month reviews
        if review.review_window == THREE_MONTH:
            await self.credibility_updater.update(rec.kol_id)

        return review

    def _evaluate_by_intent(
        self, intent: Intent, excess_return: float, timeframe: Timeframe
    ) -> OutcomeStatus:
        """HIT/MISS/PARTIAL based on intent + excess return thresholds."""
        threshold = {DAYS: 0.03, WEEKS: 0.05, MONTHS: 0.10, LONG_TERM: 0.15}[timeframe]

        if intent in (STRONG_BUY, BUY):
            if excess_return >= threshold:
                return HIT
            elif excess_return >= threshold / 2:
                return PARTIAL
            return MISS

        if intent in (STRONG_AVOID, AVOID):
            if excess_return <= -threshold:
                return HIT       # right to avoid
            elif excess_return <= -threshold / 2:
                return PARTIAL
            return MISS

        if intent == NEUTRAL:
            return HIT if abs(excess_return) <= threshold / 2 else MISS

        return INCONCLUSIVE  # WATCH is informational
```

### UC-3: Update KOL Credibility (Bayesian)

```python
class UpdateKolCredibilityUseCase:
    async def execute(self, kol_id: KolId) -> CredibilityScore:
        all_reviews = await self.review_repo.get_completed_for_kol(kol_id)
        n_hits = sum(1 for r in all_reviews if r.status == HIT)
        n_misses = sum(1 for r in all_reviews if r.status == MISS)
        n_partial = sum(1 for r in all_reviews if r.status == PARTIAL)

        # Partial = 0.5 success
        n_total_weighted = n_hits + n_misses + n_partial
        n_success_weighted = n_hits + 0.5 * n_partial

        # Bayesian with skeptical prior
        prior_alpha, prior_beta = 5.0, 5.0
        posterior_alpha = prior_alpha + n_success_weighted
        posterior_beta = prior_beta + (n_total_weighted - n_success_weighted)

        bayesian_mean = posterior_alpha / (posterior_alpha + posterior_beta)
        ci_low = beta.ppf(0.05, posterior_alpha, posterior_beta)
        ci_high = beta.ppf(0.95, posterior_alpha, posterior_beta)

        score = CredibilityScore(
            kol_id=kol_id,
            n_evaluated=len(all_reviews),
            n_hits=n_hits, n_misses=n_misses, n_partial=n_partial,
            posterior_alpha=posterior_alpha,
            posterior_beta=posterior_beta,
            bayesian_mean=bayesian_mean,
            bayesian_ci_low=ci_low,
            bayesian_ci_high=ci_high,
            sector_scores=self._compute_sector_scores(all_reviews),
            timeframe_scores=self._compute_timeframe_scores(all_reviews),
            last_updated_at=datetime.utcnow(),
        )
        await self.credibility_repo.save(score)

        # Auto-transition from PROVISIONAL
        kol = await self.kol_repo.get(kol_id)
        if kol.status == PROVISIONAL and len(all_reviews) >= 10:
            kol.transition_to_active(score)
            await self.kol_repo.save(kol)

        await self.event_bus.publish(CredibilityScoreUpdated(...))
        return score
```

### UC-4: Detect Confluence

```python
class DetectConfluenceUseCase:
    """≥3 high-credibility KOLs agree on same ticker within N days."""

    async def execute(self, lookback_days: int = 7) -> list[ConfluenceDetection]:
        recent = await self.recommendation_repo.find_recent(
            since=datetime.utcnow() - timedelta(days=lookback_days),
            min_extraction_confidence=0.7,
        )
        by_ticker = defaultdict(list)
        for rec in recent:
            by_ticker[rec.ticker].append(rec)

        detections = []
        for ticker, recs in by_ticker.items():
            # Filter high-credibility
            hc_recs = []
            for rec in recs:
                kol = await self.kol_repo.get(rec.kol_id)
                if kol.credibility and kol.credibility.is_high_credibility():
                    hc_recs.append((rec, kol.credibility))

            distinct_kols = {r.kol_id for r, _ in hc_recs}
            if len(distinct_kols) < 3:
                continue

            buy_count = sum(1 for r, _ in hc_recs if r.intent in (STRONG_BUY, BUY))
            avoid_count = sum(1 for r, _ in hc_recs if r.intent in (STRONG_AVOID, AVOID))
            if buy_count < 3 and avoid_count < 3:
                continue  # no directional confluence

            direction = "BUY" if buy_count >= 3 else "AVOID"
            converging = [r for r, _ in hc_recs if self._matches_direction(r.intent, direction)]
            strength = sum(c.bayesian_mean for r, c in hc_recs if r in converging) / len(converging)

            detections.append(ConfluenceDetection(
                ticker=ticker, direction=direction,
                converging_recommendations=[r.recommendation_id for r in converging],
                confluence_strength=strength, detected_at=datetime.utcnow(),
            ))
            await self.event_bus.publish(ConfluenceDetected(...))
        return detections
```

## B.4 Infrastructure Adapters

**Transcribers** (`packages/infrastructure/influence/transcribers/`):
- `WhisperLocalTranscriber` — cost reduction, good enough quality
- `WhisperApiTranscriber` — hard audio fallback
- `TextContentExtractor` — for FB posts, blog text (no transcription needed)

**Extractors** (`packages/infrastructure/influence/extractors/`):
- `LlmRecommendationExtractor` — Claude Sonnet + structured output (JSON schema)

**Scrapers** (`packages/infrastructure/influence/scrapers/`):
- `YoutubeChannelScraper` — yt-dlp + YouTube Data API, respects quotas
- `FacebookFanpageScraper` — Graph API for public pages only
- `TelegramPublicChannelScraper` — Bot API for public broadcast channels
- `PodcastRssScraper` — RSS + audio download
- `BlogScraper` — RSS or sitemap, respects robots.txt

**All scrapers**: base class enforces user-agent identification, rate limits, private-content refusal.

## B.5 LLM Extraction Prompt (system)

```
You extract investment recommendations from Vietnamese financial content. Extract ONLY
explicit recommendations about specific stocks. Do NOT extract general market commentary,
past recommendations, hypothetical examples, or educational content.

For each recommendation:
- ticker: VN stock symbol (e.g., HPG, VIC, FPT)
- intent: STRONG_BUY | BUY | WATCH | NEUTRAL | AVOID | STRONG_AVOID
- conditions: list of conditions, may be empty (e.g., ["if breaks 30k", "after VN-Index 1300"])
- timeframe: INTRADAY | DAYS | WEEKS | MONTHS | LONG_TERM
- timestamp_in_source: for video, mm:ss-mm:ss range
- transcript_excerpt: exact quote ≤500 chars
- extraction_confidence: 0-1, your confidence in this extraction (not in the recommendation itself)

Rules:
- If confidence < 0.5, DO NOT extract
- If speaker says "I'm not giving advice, just sharing view", still extract but mark timeframe LONG_TERM
- If speaker references own past recommendation ("as I said last week"), don't double-extract
- Vietnamese nuances: "cẩn thận" = AVOID, "theo dõi" = WATCH, "mạnh tay mua" = STRONG_BUY

Return JSON array. Empty array if no extractable recommendations.
```

## B.6 Database Schema (key tables)

```sql
-- db/migrations/006_influence_network.sql

CREATE TABLE kols (
    kol_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    primary_channel_id TEXT NOT NULL,
    style TEXT NOT NULL CHECK (style IN ('fundamental','technical','narrative','pumper','mixed','unknown')),
    status TEXT NOT NULL CHECK (status IN ('provisional','active','paused','retired','blacklisted')),
    sectors_covered TEXT[],
    profile_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_active_at TIMESTAMPTZ
);

CREATE TABLE channels (
    channel_id TEXT PRIMARY KEY,
    platform TEXT NOT NULL,
    url TEXT NOT NULL,
    kol_id TEXT REFERENCES kols(kol_id),
    subscriber_count INT,
    last_scraped_at TIMESTAMPTZ
);

CREATE TABLE recommendations (
    recommendation_id TEXT PRIMARY KEY,
    kol_id TEXT NOT NULL REFERENCES kols(kol_id),
    channel_id TEXT NOT NULL REFERENCES channels(channel_id),
    ticker TEXT NOT NULL,
    intent TEXT NOT NULL,
    conditions JSONB DEFAULT '[]',
    timeframe TEXT NOT NULL,
    source_url TEXT NOT NULL,                        -- Provenance
    timestamp_in_source TEXT,
    transcript_excerpt TEXT NOT NULL CHECK (LENGTH(transcript_excerpt) <= 500),
    extraction_confidence REAL NOT NULL CHECK (extraction_confidence BETWEEN 0 AND 1),
    extractor_model TEXT NOT NULL,
    extractor_version TEXT NOT NULL,
    published_at TIMESTAMPTZ NOT NULL,
    extracted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    flip_from_recommendation_id TEXT REFERENCES recommendations(recommendation_id)
);

CREATE INDEX idx_recs_ticker_published ON recommendations(ticker, published_at DESC);
CREATE INDEX idx_recs_kol_published ON recommendations(kol_id, published_at DESC);

CREATE TABLE outcome_reviews (
    review_id TEXT PRIMARY KEY,
    recommendation_id TEXT NOT NULL REFERENCES recommendations(recommendation_id),
    review_window TEXT NOT NULL CHECK (review_window IN ('one_month','three_month','six_month','twelve_month')),
    scheduled_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'pending',
    price_at_rec_vnd NUMERIC,
    price_at_review_vnd NUMERIC,
    return_pct REAL,
    benchmark_return_pct REAL,
    excess_return_pct REAL,
    notes TEXT,
    UNIQUE(recommendation_id, review_window)
);

CREATE INDEX idx_reviews_scheduled ON outcome_reviews(scheduled_at) WHERE status = 'pending';

CREATE TABLE credibility_scores (
    kol_id TEXT PRIMARY KEY REFERENCES kols(kol_id),
    n_evaluated INT NOT NULL,
    n_hits INT NOT NULL,
    n_misses INT NOT NULL,
    n_partial INT NOT NULL,
    posterior_alpha REAL NOT NULL,
    posterior_beta REAL NOT NULL,
    bayesian_mean REAL NOT NULL,
    bayesian_ci_low REAL NOT NULL,
    bayesian_ci_high REAL NOT NULL,
    sector_scores JSONB NOT NULL DEFAULT '{}',
    timeframe_scores JSONB NOT NULL DEFAULT '{}',
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE confluence_detections (
    detection_id TEXT PRIMARY KEY,
    ticker TEXT NOT NULL,
    direction TEXT NOT NULL,
    converging_recommendation_ids TEXT[] NOT NULL,
    confluence_strength REAL NOT NULL,
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    first_reviewed_at TIMESTAMPTZ,
    user_action TEXT           -- what user did with this signal
);
```

## B.7 Update Cadences

- **YouTube channels**: daily 20:00 (after most channels publish)
- **Facebook fanpages**: every 4h during 8:00-22:00
- **Telegram public channels**: every 1h
- **Podcasts**: RSS check hourly
- **Blogs**: every 2h
- **Outcome reviews**: daily cron 02:00 — runs all due reviews
- **Credibility recompute**: triggered by 3m reviews + weekly batch Sunday 03:00
- **Confluence detection**: every 1h during market days

## B.8 Quality Gates

**Deterministic**:
- Schema constraints prevent missing provenance fields
- Repository `find_recent` returns only `extraction_confidence >= 0.7`
- Domain `Recommendation` constructor raises `InvariantViolation` on missing fields
- Type checking (mypy --strict) on all domain code

**Probabilistic** (separate agent):
- Sample 5% of new recommendations for human review
- LLM critic reviews confluence alerts before user-facing
- Cross-check: do transcribed segments match source video timestamps?

**Human**:
- Monthly: review blacklist additions (BLACKLISTED status requires human confirmation)
- Quarterly: review KOL style classifications
- Before confluence alert deployment: I manually check first 3 confluence cases

## B.9 Tasks (initial breakdown)

**Phase 1** (spec-to-running-skeleton): ~3 weeks
- T-001: Create BC-6 domain skeleton (Kol, Channel, Recommendation entities + VOs)
- T-002: Postgres schema + migrations
- T-003: Repository implementations (Postgres adapters)
- T-004: Domain tests for all aggregates

**Phase 2** (ingestion pipeline): ~4 weeks
- T-005: YoutubeChannelScraper with yt-dlp + rate limiting
- T-006: WhisperLocalTranscriber
- T-007: LlmRecommendationExtractor with structured output
- T-008: IngestChannelContentUseCase wiring
- T-009: Scheduled job to run daily ingestion
- T-010: Seed 10 initial KOLs for testing

**Phase 3** (calibration): ~3 weeks
- T-011: EvaluateOutcomeReviewUseCase + quote integration
- T-012: UpdateKolCredibilityUseCase with Bayesian math
- T-013: Scheduled cron for due reviews
- T-014: Provisional → Active auto-transition

**Phase 4** (confluence + delivery): ~2 weeks
- T-015: DetectConfluenceUseCase
- T-016: Daily digest generation (markdown + email/Telegram)
- T-017: Per-ticker query API (Streamlit page)
- T-018: KOL profile browser UI

## B.10 Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| LLM mis-extracts recommendations | HIGH | MEDIUM | 0.7 confidence threshold + human sample review + eval set |
| Pumpers adapt to evade detection | MEDIUM | HIGH | Multiple signal types, continuous rule updates, don't publish detection logic |
| YouTube API quota exhaustion | MEDIUM | LOW | yt-dlp fallback, caching, reasonable poll frequency |
| Facebook ToS changes block scraping | MEDIUM | MEDIUM | Graph API only for public fanpages; fallback to manual link lists |
| KOL complains about being tracked | LOW | MEDIUM | Public data only, GDPR-style removal on request, opt-out mechanism |
| Bayesian prior too weak, slow to learn | LOW | LOW | Tunable; start weak, review after 6 months of data |
| Confluence false positives drive decisions | HIGH | HIGH | Always paired with Tier 1/2 check; "investigate" not "act" framing |

---

# PART C — PROVENANCE & REVIEW

## C.1 Why This Design

**Considered alternative: single credibility score per KOL**
- Rejected: KOL might be good at one sector and bad at another. Disaggregation surfaces this.

**Considered alternative: naive hit rate average**
- Rejected: Small samples mislead (KOL with 3-for-3 appears perfect). Bayesian CI honestly reports uncertainty.

**Considered alternative: evaluate at fixed timeframe (always 3m)**
- Rejected: KOL's stated timeframe matters. "Buy for intraday" and "Buy for 2 years" are different signals, evaluated differently.

**Considered alternative: don't track PUMPER category**
- Rejected: Identifying pumpers is specifically valuable for VN. Cost is low (same pipeline).

## C.2 Open Questions

- Should BLACKLISTED KOLs be tracked for counter-signal use (their recommendation = avoid)?
- How do we handle KOL collaboration (guest appearances)? Attribute to host or guest?
- When paid promotions are disclosed in videos, should extraction mark it specially?
- How to handle KOLs who delete/edit videos post-publication (rewriting history)?

## C.3 Reviews

| Date | Reviewer | Status | Notes |
|---|---|---|---|
| 2026-04-23 | project-owner | Approved | Initial |
