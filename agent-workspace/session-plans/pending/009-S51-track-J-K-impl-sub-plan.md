---
plan_id: 009-S51-track-J-K-impl-sub-plan
phase: 3
parent_plan: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md
sessions_covered: S52 + S53
status: active
authored: 2026-05-06
authored_by: Claude Opus 4.7 (S65 sandwich-architect dispatch; lean ≤6 pre-reads per L-S43f-2)
binding_spec: specs/tier2-feature/003-crowd-sentiment-pump-detection.md
binding_adr: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md
binding_constitution: agent-workspace/constitution/architecture.md § "LLM Substrate Boundary" (D-026)
mirrors_subplan: agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md (verbatim structure; BC-6 → BC-7)
mode: AUTONOMOUS
---

# S65 Track J+K IMPL Sub-Plan — S52 + S53 (BC-7 Crowd Sentiment + Pump Detection)

> **Goal**: Per-session deliverables matrix for BC-7 ship across S52 (Track J — 3 crowd
> aggregators + sentiment classifier + coordination detector) + S53 (Track K — narrative
> phase classifier + pump phase classifier + counter-narrative generator + historical
> analog finder).
>
> **Binding spec**: `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` BR-1..BR-10
> + § B.1 entities + § B.3 UC-1..UC-4 + § B.4 adapters + § B.5 schema + § B.7 calibration
> + § B.8 quality gates
> **Binding ADR**: `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` (D-032 same-session)
> **Binding master-plan**: `007-S44-phase-3-master-plan.md` § Track Catalog J/K + § Session Breakdown S51/S52/S53

---

## Identity & Scope

**2 sessions ship**:
- **S52** — Track J — 3 crowd source aggregators (F319 forum + FacebookPublicGroup +
  ArticleComments-CafeF/Vietstock) + shared `RateLimitedFetcher` base + LlmSentiment-
  Classifier + CoordinationDetector + CLI smoke + 30+ NEW tests
- **S53** — Track K — NarrativePhaseClassifier + PumpPhaseClassifier + Counter-
  NarrativeGenerator + HistoricalAnalogFinder + PumpEvidenceSummarizer + 20+ NEW tests
  + backtest validation harness (BR-5 hold-out gate)

**2 sessions DO NOT ship**:
- Streamlit dashboard pages (UC sentiment view + UC counter-narrative review + UC
  coordination alerts) — S57 cross-cutting Track M
- Telegram public-channel crowd ingestion — deferred Phase 4 (BC-6 S46 ships
  TelegramPublicChannelAdapter for KOL signal; BC-7 Telegram defers per D-032(b))
- Postgres+TimescaleDB migration — Phase 4 SaaS-deploy boundary per L-S17-1 + D-032(a)
- Pump auto-fire alerts — Phase 1 human-review-first per § B.8 + D-032(i); auto-fire
  Phase 2+ gated on monthly false-positive review

**Critical path**: S51 (this PLAN + D-032) → S52 → S53 → S59 (sandwich-verifier whole-
Phase-3 close consolidates BC-7 VERIFY per master-plan § Sandwich Coverage).

S54 META_LOOP_RECOVERY reserve fires only if S52/S53 surface drift or substrate gap
(per master-plan § Session Breakdown).

---

## SCOPE-tier User-Gate Reminders

Per master-plan § Open Questions: Q-P3-1/2/3 ALL RESOLVED at S44 (Q-P3-2 = ALL platforms
including FB; Q-P3-3 = ADD outer-loop activation invariant pending S55+S56 ratification).
Q-P3-4 IMPL-tier auto-decided (SQLite per D-032(a) mirror D-027(a)). No SCOPE-tier
user-gates pending entry to S52.

S52 entry has 1 IMPL-tier auto-decide (LLM sentiment classifier strategy pick from probe
matrix); escalate via SCOPE Q&A bundle ONLY if all 3 strategies probe <0.85 per-label
accuracy (per D-032 § Rollback path).

S53 entry has 1 IMPL-tier auto-decide (HistoricalAnalogFinder embedding model pick: reuse
OpenAI text-embedding-3-small per architecture.md § LLM vs alternative). Default Recommended.

S53 close has 1 BR-5 BACKTEST GATE (precision >0.5 + recall >0.3 hold-out); failure
escalates per D-032 § Rollback path.

---

## S52 — Track J IMPL (3 Crowd Aggregators + Sentiment Classifier + Coordination Detector + CLI)

### Meta

| Field | Value |
|---|---|
| Session type | MULTI_TASK_IMPL |
| Agent | main (Dev half of sandwich; S59 Verifier closes whole-Phase-3 incl. BC-7) |
| Budget envelope | 150-220K main + 50-100K subagent (per master-plan §S52) |
| Predecessor | S51 (this plan + D-032) |
| Successor | S53 |
| Decision tier | IMPL — per D-032(b) shared Protocol + 3 concretes; sub-decisions IMPL-tier |
| Split doctrine | If pre-flight projects >230K, split S52a (Protocol + base + F319 + sentiment classifier) / S52b (FB group + comments + coordination + CLI + tests) |

### Goal

Ship BC-7 ingestion + classification substrate: shared `PostAggregator` Protocol +
`RateLimitedFetcher` base (mirror BC-6 D-027(b); reuse if importable from
`packages/infrastructure/influence/rate_limited_fetcher.py`, else duplicate-
with-attribution per Phase 3 BC-7 needs) + 3 platform concretes (F319 + FacebookPublic-
Group + ArticleComments) + LlmSentimentClassifier (Vietnamese categorical 5-level per
BR-4 + D-026 patterns) + CoordinationDetector (3-feature ensemble per D-032(h)) + CLI
smoke + 30+ NEW tests. All network calls + LLM calls mocked in CI; live smoke gated to
manual `pytest -m live`.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` § A.3 BR-1..BR-4 + BR-8 + BR-10 + § B.1 entities (SentimentSnapshot + Sentiment + Window) + § B.3 UC-1 (CaptureSentimentSnapshotUseCase) + § B.4 adapters + § B.7 cadences
2. `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` (D-032 binding; (a) storage + (b) adapter pattern + (d) LLM substrate + (h) coordination)
3. `packages/infrastructure/influence/rate_limited_fetcher.py` + `packages/infrastructure/influence/telegram_adapter.py` (S46 BC-6 reference for adapter patterns + ToS pre-flight + S64 verifier-confirmed hardening pattern)
4. `.claude/skills/crawler-reliability/SKILL.md` + `.claude/skills/empirical-probe-first/SKILL.md` (per R-P3-2 + R-P3-1 mitigation; user-agent rotation + Playwright stealth + backoff + 3-strategy LLM probe procedure)
5. `agent-workspace/constitution/architecture.md` § BC-7 + § Folder Conventions + § "LLM Substrate Boundary"

VBW pre-flight per L-S30-1: `Glob` each NEW directory before Write; verify no existing
file at target path.

### EMPIRICAL-PROBE-FIRST INVOCATION (mandatory at S52 entry — 3 strategies)

Per L-S32-1 + master-plan § R-P3-1 HIGH severity: BEFORE writing the LlmSentimentClassifier,
invoke `empirical-probe-first` skill to test ≥3 strategies on 50-fixture hand-labeled
VN forum-post sentiment set:

| Strategy | Model(s) | Estimated $/50-fixture | Notes |
|---|---|---|---|
| **S1 Claude Haiku batch** | claude-haiku-3-5 | ~$0.30-0.60 | Cost-baseline; 50 posts/call batch |
| **S2 Claude Sonnet batch** | claude-sonnet-4-6 | ~$1-2 | Quality-baseline; precision tradeoff |
| **S3 Haiku-prefilter + Sonnet-extract hybrid** | claude-haiku-3-5 (filter non-financial) + claude-sonnet-4-6 (classify financial) | ~$0.80-1.50 | Hybrid; Haiku discards off-topic posts |

**Probe budget**: ~$3-6 one-time at S52 entry (~6x cheaper than BC-6 S47 KOL probe due
to shorter post text vs full transcripts).
**Pick criterion**: per-label accuracy on hand-labeled fixture; require ≥85% per category
per spec § B.7 calibration target.
**Rollback**: if all 3 strategies <85% per-label accuracy → escalate via SCOPE Q&A bundle
per D-032 § Rollback path; defer Track J sentiment classifier to S54 META_LOOP_RECOVERY.

**Empirical-probe-first ladder ALSO at S52 entry — 3 adapter ToS-compliance strategies
× public-only enforcement** (per skill `.claude/skills/empirical-probe-first/SKILL.md`):

| Strategy | Approach | Notes |
|---|---|---|
| **A1 robots.txt + UA rotation + 2 req/s baseline** | requests + tenacity backoff + 3-UA pool | F319 + comments baseline; lowest infra |
| **A2 Playwright stealth + 1 req/s + cookie eviction** | Playwright headless + stealth-plugin + per-session cookie rotation | FB Graph API gray-zone; per Q-P3-2 R-P3-2 elevated mitigation |
| **A3 Hybrid (A1 for F319+comments, A2 for FB)** | Per-platform adapter selects strategy | RECOMMENDED — match infra to per-platform fragility |

**Pick criterion**: 30-fixture smoke per platform; require 0 ToS-violations + 0
private-content-fetched + ≥95% legitimate-content-fetch rate. **Default**: A3 hybrid
(match BC-6 D-027 facebook_adapter pattern + S64 telegram_adapter ToS hardening
precedent).

### Deliverables (~15 files NEW + 2 EDIT; ~2,000 LOC; ≥30 NEW tests)

**BC-7 Domain (`packages/domain/crowd/`):**
1. NEW `packages/domain/crowd/__init__.py` ≤25 LOC (barrel)
2. NEW `packages/domain/crowd/value_objects/__init__.py` + `sentiment.py` (StrEnum 5 levels per BR-4) + `narrative_phase.py` (StrEnum 7 levels per spec § B.1) + `pump_phase.py` (StrEnum 5 levels) + `pump_action.py` (StrEnum 4 levels) + `window.py` (StrEnum 4 values + `hours: float` + `duration: timedelta` properties) + `narrative_id.py` + `snapshot_id.py` + `detection_id.py` — ≤25 LOC each, 9 files total
3. NEW `packages/domain/crowd/sentiment_snapshot.py` ≤140 LOC (SentimentSnapshot aggregate per spec § B.1 — frozen dataclass + `__post_init__` invariants per D-032(c) + `dominant_sentiment()` + `bullish_ratio()` behaviors verbatim from spec)
4. NEW `packages/domain/crowd/raw_post.py` ≤80 LOC (RawPost VO; post_id + ticker + source + posted_at + text + poster_id + account_age_days; account_age_days: int | None for sources where unknown)

**BC-7 Application Ports (`packages/application/crowd/`):**
5. NEW `packages/application/crowd/__init__.py` ≤15 LOC + `ports/__init__.py` + `ports/post_aggregator_port.py` ≤60 LOC (Protocol per D-032(b); methods `fetch_recent(ticker, since) -> list[RawPost]` + `is_public(source_url) -> bool` + `respect_rate_limit() -> None`)
6. NEW `packages/application/crowd/ports/sentiment_classifier_port.py` ≤40 LOC (Protocol; method `classify_batch(posts: list[RawPost]) -> list[ClassifiedPost]`)
7. NEW `packages/application/crowd/ports/coordination_detector_port.py` ≤40 LOC (Protocol; method `score(posts: list[ClassifiedPost], features: list[CoordinationFeature]) -> float` returns coordination_score in [0,1])
8. NEW `packages/application/crowd/ports/sentiment_snapshot_repository_port.py` ≤50 LOC (Protocol; methods `save(snapshot)` + `get_recent(ticker, window)` + `find_by_id(snapshot_id)`)

**BC-7 Application Use Case:**
9. NEW `packages/application/crowd/use_cases/__init__.py` + `capture_sentiment_snapshot_use_case.py` ≤180 LOC (per spec § B.3 UC-1 verbatim; orchestrates aggregator + classifier + coordination_detector; emits `SentimentSnapshotCaptured` + conditional `CoordinatedPostingDetected` events; deterministic numeric aggregation per I-S1)

**BC-7 Infrastructure (`packages/infrastructure/crowd/`):**
10. NEW `packages/infrastructure/crowd/__init__.py` ≤15 LOC
11. NEW `packages/infrastructure/crowd/rate_limited_fetcher.py` ≤180 LOC OR import-from-influence if module shape compatible (mirror D-032(b) reuse-or-duplicate decision; if duplicate, attribute via docstring "duplicated from packages/infrastructure/influence/rate_limited_fetcher.py at S46 commit hash; sync via vendor-api-probe.sh weekly")
12. NEW `packages/infrastructure/crowd/aggregators/f319_forum_aggregator.py` ≤200 LOC (F319 public sections; 30-min cadence per § B.7; A1-strategy per S52 probe; thread-id + post-id + ticker-tag + posted_at extraction)
13. NEW `packages/infrastructure/crowd/aggregators/facebook_public_group_aggregator.py` ≤220 LOC (Graph API for public groups ONLY per BR-1; 2h cadence per § B.7; A2/A3-strategy per S52 probe; refuses on private-group + login-required + raises `ToSBoundaryViolation` mirror BC-6 telegram_adapter S64 hardening)
14. NEW `packages/infrastructure/crowd/aggregators/article_comments_aggregator.py` ≤200 LOC (CafeF + Vietstock comment-section scrape per § B.7 "with parent article fetch (Tier 2 cycle)"; A1-strategy; HTML-fragility documented + manual fallback)
15. NEW `packages/infrastructure/crowd/sentiment_classifier.py` ≤220 LOC (LlmSentimentClassifier; implements `SentimentClassifierPort`; cites D-026 patterns: per-role override dict + prose-tolerant JSON via `subagent_transport.py:55-118` reuse + gatherer-wired compute via `CrowdContentGatherer`; prompt verbatim from spec calibration target; categorical 5-level enum output ONLY per BR-4 + I-S1)
16. NEW `packages/infrastructure/crowd/crowd_content_gatherer.py` ≤100 LOC (per D-032(d) gatherer-wired compute pattern; prepares post batches + window metadata + ticker context; numbers come from code per I-S1)
17. NEW `packages/infrastructure/crowd/coordination_detector.py` ≤220 LOC (3-feature ensemble per D-032(h); template_similarity via OpenAI text-embedding-3-small + timing_cluster sliding-window + account_age_distribution; weighted ensemble 0.4/0.3/0.3 default; threshold 0.8 per BR-8; payload constructor CONSTITUTIONALLY FORBIDDEN from operator-naming fields per BR-10)
18. NEW `packages/infrastructure/crowd/sqlite_sentiment_snapshot_repository.py` ≤180 LOC (sentiment_snapshots table per spec § B.5 SQLite-adapted per D-032(a); composite index `(ticker, captured_at DESC)` for hypertable emulation)

**BC-7 CLI:**
19. NEW `apps/cli/ingest_crowd_sentiment.py` ≤140 LOC (Click CLI; flags `--platform=all|f319|fb_group|comments` + `--ticker` + `--window=1H|4H|1D|1W` + `--dry-run`; smoke-test entry point; orchestrates CaptureSentimentSnapshotUseCase per ticker)

**Tests (≥30 NEW):**
20. NEW `packages/domain/crowd/test_value_objects.py` ≤140 LOC (≥8 tests — Sentiment+NarrativePhase+PumpPhase+PumpAction+Window enum membership + Window.hours/duration math)
21. NEW `packages/domain/crowd/test_sentiment_snapshot.py` ≤180 LOC (≥8 tests — SentimentSnapshot construction + invariants ([0,1] coordination_score; non-empty distribution; non-future captured_at) + dominant_sentiment + bullish_ratio computation per spec)
22. NEW `packages/infrastructure/crowd/test_rate_limited_fetcher.py` ≤120 LOC OR skip-if-imported-from-influence-network (≥6 tests — backoff schedule; ToS pre-flight rejects private; user-agent rotation; httpx mocked via `respx`)
23. NEW `packages/infrastructure/crowd/aggregators/test_aggregators.py` ≤220 LOC (≥9 tests; 3 per platform — public-only enforcement (raises ToSBoundaryViolation on private fixture) + cadence respect + RawPost shape; live calls mocked)
24. NEW `packages/infrastructure/crowd/test_sentiment_classifier.py` ≤220 LOC (≥8 tests — happy path mock-LLM Vietnamese fixture; BR-4 categorical-only enforcement (constructs LLM output with numeric "80%" → asserts raises LlmOutputViolatesISOne); prose-tolerant JSON survives preamble; Vietnamese diacritics preserved)
25. NEW `packages/infrastructure/crowd/test_coordination_detector.py` ≤180 LOC (≥7 tests — template_similarity feature; timing_cluster feature; account_age_distribution feature; ensemble scoring; BR-8 threshold ≥0.8; **BR-10 payload-no-PII test**: synthetic CoordinationDetected event + asserts no poster_id/account_name/operator-substring fields)
26. NEW `packages/application/crowd/use_cases/test_capture_sentiment_snapshot.py` ≤140 LOC (≥4 tests — orchestration with mock aggregator + classifier + detector; emits SentimentSnapshotCaptured; conditional CoordinatedPostingDetected fires only at coord_score ≥0.8)

**Vietnamese-language fixture set:**
- NEW `packages/infrastructure/crowd/fixtures/vi_forum_posts/` directory + 50+ JSON fixtures (post text + expected sentiment label; mix of F319 + FB group public posts + CafeF/Vietstock comments; sourced from spec calibration § B.7 + 50 NEW VN samples; this IS the empirical-probe-first 50-fixture set)

**EDIT (2):**
- `pyproject.toml` (+ httpx + tenacity ≥9.0 + respx ≥0.21 + openai ≥1.0 (text-embedding-3-small) deps if not yet present from BC-6)
- `agent-workspace/memory/current-execution.md` (+ S52 row at top)

**Total**: ~15 files NEW + 50 fixtures + 2 EDIT + ~2,000 LOC + ≥30 NEW tests.

### Test Pyramid Budget (S52)

| Tier | Count | LOC | Examples |
|---|---|---|---|
| **Unit (domain + VO)** | ≥16 tests | ~320 LOC | enum membership; SentimentSnapshot invariants; bullish_ratio math |
| **Unit (infrastructure)** | ≥12 tests | ~600 LOC | adapter mocked HTTP; sentiment classifier mocked LLM; coordination detector ensemble |
| **Integration (use case)** | ≥4 tests | ~140 LOC | CaptureSentimentSnapshotUseCase end-to-end with mock repos + mock external |
| **E2E (live)** | 0 tests in CI; smoke gated `pytest -m live` | — | manual smoke `python -m apps.cli.ingest_crowd_sentiment --platform=f319 --ticker=VND --dry-run` |
| **TOTAL** | **≥32 tests** | **~1,060 LOC** | |

Inverse pyramid avoided per Phase 2 L-S29-* lessons (heavy E2E in CI is anti-pattern).

### Success Criteria (acceptance — 8 testable bullets)

- [ ] `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/` ≥30 PASS in <4s
- [ ] All 3 aggregators mockable (no live network calls in default `pytest`); live calls behind `pytest -m live` opt-in
- [ ] BR-1 public-only enforcement: each aggregator `is_public()` returns False for known-private URL fixture → aggregator raises `ToSBoundaryViolation`; pytest asserts (mirror BC-6 telegram_adapter S64 pattern)
- [ ] **BR-4 categorical-only enforcement**: pytest constructs LLM output with numeric "80%" sentiment → asserts `LlmOutputViolatesISOne` raised (NOT silently coerced)
- [ ] **BR-10 NO PII in CoordinationDetected payload**: pytest asserts `posting_pattern` field has no poster_id/account_name/operator-name substrings; payload schema validation rejects PII fields
- [ ] No framework imports in `packages/domain/crowd/**` — grep `from fastapi\|from pydantic\|import django\|import httpx\|import sqlite3` returns 0
- [ ] Cross-BC import grep — `grep -r "from packages.domain.market_data\|from packages.domain.fundamental\|from packages.domain.news\|from packages.domain.influence" packages/domain/crowd/` returns 0
- [ ] mypy --strict + ruff: 0 errors on BC-7 surface; D1 baseline still 0
- [ ] CLI smoke: `python -m apps.cli.ingest_crowd_sentiment --platform=f319 --ticker=VND --window=1H --dry-run` exits 0; logs ≥1 SentimentSnapshot construction
- [ ] Empirical probe matrix documented at session-log + classifier docstring; ≥3 strategies tested; chosen strategy per-label accuracy ≥0.85 on 50-fixture set

### R-P3-2 mitigation checklist (Q-P3-2 ALL-3-platforms binding) + BR-10 hardening

- [ ] crawler-reliability skill invoked at S52 entry (per .claude/skills/crawler-reliability/SKILL.md)
- [ ] empirical-probe-first skill ladder run for adapter ToS-compliance (3 strategies × public-only)
- [ ] ToS pre-flight: each aggregator checks robots.txt + platform ToS public-content boundary
- [ ] Rate-limit: backoff matrix per platform (F319 ~2 req/s + FB Graph ~2 req/s + CafeF/Vietstock ~1 req/s)
- [ ] User-agent rotation: 3-UA pool minimum per crawler-reliability/SKILL.md
- [ ] IP rotation hook: stub for Phase 4 proxy integration; documented in `RateLimitedFetcher` docstring (NOT implemented — stub only Phase 3)
- [ ] BR-10 payload audit: CoordinationDetector schema enforces no poster_id/account_name; pytest BR-10 test verifies
- [ ] Monitoring: each aggregator logs `(platform, ticker, status, latency_ms, post_count)` to `.session-hooks.log` for post-run audit

### Rollback Path (S52)

- If sentiment classifier all-3-strategy probe <85% per-label accuracy → SCOPE Q&A escalate; defer Track J classifier to S54 META_LOOP_RECOVERY; aggregators + coordination detector still ship (decoupled paths)
- If FB Graph API auth shifts mid-S52 (ToS hardening) → fb_group_aggregator falls back to manual link-list mode (mirror BC-6 D-027 R1 pattern); document IMPL-S52-N
- If F319 / CafeF / Vietstock HTML changes mid-session → adapter falls back to RSS feed where available; manual fallback documented at adapter docstring + vendor-api-probe.sh weekly check

### Open questions (queued-grill candidates)

| ID | Tier | Question | fire_when |
|---|---|---|---|
| Q-S52-1 | IMPL | F319 forum requires login for some thread sections; restrict to fully-public threads only? | S52 entry — recommend YES per BR-1; document IMPL-S52-1 |
| Q-S52-2 | IMPL | Facebook Graph API public-group post-iteration via `feed` endpoint or `posts` endpoint v18+? | S52 entry — recommend `posts` v18+ for stability; document IMPL-S52-2 |
| Q-S52-3 | IMPL | Should account_age_days be fetched per-post (expensive) or sampled (cheap)? | S52 mid — recommend sampled + cached per poster_id (24h TTL) |
| Q-S52-4 | IMPL | RateLimitedFetcher: import-from-influence OR duplicate-with-attribution? | S52 entry — recommend import-if-shape-compatible; else duplicate per D-032(b) |

### Risks (S52-specific cross-ref to master-plan R-P3-*)

- **R1 (HIGH) — R-P3-2 ToS gray-zone shift mid-Phase-3**: Q-P3-2 user explicit-accept; mitigation = adapter raises `ToSBoundaryViolation` early + falls back to manual link-list mode if Graph API auth shifts (mirror BC-6 D-027 R1)
- **R2 (HIGH) — R-P3-1 Vietnamese sentiment classifier accuracy <0.85**: rollback per D-032 § Rollback path; document at session-end as SCOPE-tier blocker
- **R3 (MED) — BR-10 PII leakage via CoordinationDetector**: explicit pytest BR-10 test + payload schema enforcement gate; CONSTITUTIONALLY FORBIDDEN audit
- **R4 (MED) — CafeF/Vietstock HTML fragility**: pin selectors + vendor-api-probe.sh weekly check; manual fallback at docstring
- **R5 (MED) — R-P3-6 subagent stream stall**: this sub-plan authored with lean ≤6 pre-reads per L-S43f-2; main-session fallback per Option 2 if subagent dispatch fails

---

## S53 — Track K IMPL (NarrativePhaseClassifier + PumpPhaseClassifier + Counter-Narrative + HistoricalAnalogFinder)

### Meta

| Field | Value |
|---|---|
| Session type | FOCUSED_IMPL |
| Agent | main (Dev half of sandwich; S59 Verifier closes whole-Phase-3 incl. BC-7) |
| Budget envelope | 150-220K main + 100-150K subagent (per master-plan §S53) |
| Predecessor | S52 |
| Successor | S55 (Track L outer-loop scaffolding; BC-7 VERIFY consolidates into S59) |
| Decision tier | IMPL per D-032(e) + (f) + (g) + (i); deterministic Python for classifiers; LLM-perspective for counter-narrative + pump evidence summary |

### Goal

Ship BC-7 classification + analog + counter-narrative substrate: NarrativePhaseClassifier
(deterministic 7-state per D-032(e)) + PumpPhaseClassifier (deterministic 5-state weighted
per D-032(f)) + HistoricalAnalogFinder (embedding-based similarity per spec § B.4) +
CounterNarrativeGenerator (LLM bear-points grounded per D-032(g)) + PumpEvidenceSummarizer
(LLM evidence text per D-032(d)) + Narrative aggregate + PumpDetection aggregate +
CounterNarrative aggregate + LabeledPump aggregate + 20+ NEW tests + BR-5 backtest validation
harness (precision >0.5 + recall >0.3 hold-out gate per D-032(i)).

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` § B.3 UC-2 (UpdateNarrativeLifecycleUseCase + NarrativePhaseClassifier verbatim) + UC-3 (DetectPumpPhaseUseCase + PumpPhaseClassifier verbatim) + UC-4 (GenerateCounterNarrativeUseCase) + § A.3 BR-5/BR-6/BR-9/BR-10 + § B.5 schema + § B.7 calibration + § B.8 quality gates (Phase 1 human-review-first)
2. `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` § (e) NarrativePhaseClassifier + § (f) PumpPhaseClassifier + § (g) Counter-narrative generator + § (i) Backtest validation gate
3. `packages/infrastructure/crowd/sentiment_classifier.py` (S52 same-track reference for D-026 substrate boundary patterns; reuse `subagent_transport.py:55-118` extractor directly)
4. `packages/domain/influence/services/calibration_service.py` (S49 BC-6 reference for deterministic-service pattern in domain layer + grep-gate-NO-LLM enforcement)
5. `agent-workspace/constitution/invariants.md` § I-S1 (NO LLM math) + § I-S13 (counter-narrative mandatory hot-stocks)

### Deliverables (~12 files NEW + 1 EDIT; ~1,800 LOC; ≥20 NEW tests)

**BC-7 Domain (`packages/domain/crowd/`):**
1. NEW `packages/domain/crowd/narrative.py` ≤180 LOC (Narrative aggregate per spec § B.1 — frozen dataclass + `__post_init__` invariants per D-032(c) + `days_in_current_phase()` behavior + `phase_history` list + counter_narrative_ids + related_narrative_ids)
2. NEW `packages/domain/crowd/phase_transition.py` ≤80 LOC (PhaseTransition VO; from_phase + to_phase + transitioned_at + trigger_signals)
3. NEW `packages/domain/crowd/pump_detection.py` ≤180 LOC (PumpDetection aggregate per spec § B.1 — frozen dataclass + invariants + contributing_signals list + recommended_action + evidence_summary; Phase 1 human-review-first status field per D-032(i): `status: 'pending_review' | 'reviewed_approved' | 'reviewed_rejected'`)
4. NEW `packages/domain/crowd/signal_contribution.py` ≤80 LOC (SignalContribution VO; signal_name + signal_value + weight + contribution_to_detection + phase: PumpPhase tag)
5. NEW `packages/domain/crowd/counter_narrative.py` ≤140 LOC (CounterNarrative aggregate per spec § B.1 — bear_points list + historical_analogs + failing_analog_details + bullish_consensus_summary; invariants: non-empty bear_points; at-least-one historical_analog)
6. NEW `packages/domain/crowd/labeled_pump.py` ≤120 LOC (LabeledPump aggregate per spec § B.5 — period_start + period_end + phases JSONB + features_at_detection + subsequent_outcome; invariants: period_end > period_start + non-empty phases + labeled_by in {'user', 'agent_with_review'})

**BC-7 Domain Services (`packages/domain/crowd/services/`):**
7. NEW `packages/domain/crowd/services/__init__.py` ≤15 LOC + `narrative_phase_classifier.py` ≤220 LOC (per D-032(e); UC-2 verbatim per spec § B.3 lines 301-333; deterministic 7-state machine; NarrativePhaseClassifierConfig dataclass for thresholds; **0 LLM imports — verifiable via grep**)
8. NEW `packages/domain/crowd/services/pump_phase_classifier.py` ≤280 LOC (per D-032(f); UC-3 verbatim per spec § B.3 lines 379-423; deterministic 5-state weighted scoring; confidence gate ≥0.4; PumpPhaseClassifierConfig dataclass for weights; **0 LLM imports — verifiable via grep**)

**BC-7 Application Ports + Use Cases:**
9. NEW `packages/application/crowd/ports/narrative_repository_port.py` ≤50 LOC (Protocol; `save` + `get_active` + `find_by_id` + `get_bullish_points_for(ticker)`)
10. NEW `packages/application/crowd/ports/pump_detection_repository_port.py` ≤50 LOC (Protocol; `save` + `get_pending_review` + `find_recent`)
11. NEW `packages/application/crowd/ports/counter_narrative_repository_port.py` ≤40 LOC (Protocol; `save` + `find_recent_for_ticker`)
12. NEW `packages/application/crowd/ports/labeled_pump_repository_port.py` ≤40 LOC (Protocol; `save` + `get_holdout_set`)
13. NEW `packages/application/crowd/ports/historical_analog_finder_port.py` ≤50 LOC (Protocol; `find(ticker, setup_description, top_k) -> list[HistoricalAnalog]`)
14. NEW `packages/application/crowd/ports/counter_narrative_generator_port.py` ≤50 LOC (Protocol; `generate(ticker, bullish_consensus, failing_analogs, structural_risks) -> list[str]` returns bear-point strings)
15. NEW `packages/application/crowd/ports/pump_evidence_summarizer_port.py` ≤40 LOC (Protocol; `summarize_pump_evidence(ticker, signals, historical_matches) -> str`)
16. NEW `packages/application/crowd/use_cases/update_narrative_lifecycle_use_case.py` ≤180 LOC (per spec § B.3 UC-2 verbatim; orchestrates classifier + repo; emits NarrativePhaseChanged event)
17. NEW `packages/application/crowd/use_cases/detect_pump_phase_use_case.py` ≤220 LOC (per spec § B.3 UC-3 verbatim; orchestrates classifier + analog finder + summarizer; Phase 1 human-review-first per D-032(i): `status='pending_review'` set at creation; PumpPhaseDetected event fires only on `reviewed_approved`)
18. NEW `packages/application/crowd/use_cases/generate_counter_narrative_use_case.py` ≤200 LOC (per spec § B.3 UC-4 verbatim; orchestrates analog finder + counter-narrative generator + sector_risks query; **MANDATORY trigger** when `bullish_ratio() > 0.8` per BR-6 + I-S13)

**BC-7 Infrastructure (`packages/infrastructure/crowd/`):**
19. NEW `packages/infrastructure/crowd/historical_analog_finder.py` ≤220 LOC (HistoricalAnalogFinderPort impl; setup-fingerprint embedding via OpenAI text-embedding-3-small per architecture.md § LLM; embedding similarity search on historical ticker-period setup data; returns top-K with subsequent_return_12m + outcome metadata)
20. NEW `packages/infrastructure/crowd/counter_narrative_generator.py` ≤220 LOC (LLM bear-points grounded per D-032(g); cites D-026 patterns: per-role override + prose-tolerant JSON + gatherer-wired compute via `CounterNarrativeGatherer`; LLM output: list of bear-point strings; regex gate at output for `\d+\s*%|approximately|roughly` raises `LlmOutputViolatesISOne`)
21. NEW `packages/infrastructure/crowd/pump_evidence_summarizer.py` ≤180 LOC (LLM evidence summary text per D-032(d); cites D-026 patterns; gatherer-wired compute via `PumpEvidenceGatherer`; LLM output: single string; same regex gate)
22. NEW `packages/infrastructure/crowd/sqlite_narrative_repository.py` ≤180 LOC (narratives + phase_transitions tables per spec § B.5 SQLite-adapted)
23. NEW `packages/infrastructure/crowd/sqlite_pump_detection_repository.py` ≤180 LOC (pump_detections table; subsequent_outcome filled post-hoc)
24. NEW `packages/infrastructure/crowd/sqlite_counter_narrative_repository.py` ≤140 LOC (counter_narratives table)
25. NEW `packages/infrastructure/crowd/sqlite_labeled_pump_repository.py` ≤140 LOC (labeled_pumps table; `get_holdout_set(test_split=0.3)` query for backtest gate)

**BC-7 Backtest Harness:**
26. NEW `apps/cli/backtest_pump_classifier.py` ≤140 LOC (Click CLI; runs PumpPhaseClassifier on `LabeledPumpRepository.get_holdout_set()`; computes precision + recall; **REQUIRED at S53 close per D-032(i) BR-5 gate**: precision >0.5 AND recall >0.3 OR session-end blocker fires)

**Cross-BC contract:**
27. NEW `packages/contracts/events/narrative_emerged.py` ≤50 LOC (frozen dataclass per spec § B.2)
28. NEW `packages/contracts/events/narrative_phase_changed.py` ≤60 LOC
29. NEW `packages/contracts/events/pump_phase_detected.py` ≤60 LOC
30. NEW `packages/contracts/events/coordinated_posting_detected.py` ≤60 LOC (S52 referenced; defined here for cohesion; payload BR-10-compliant per D-032(h))
31. NEW `packages/contracts/events/counter_narrative_generated.py` ≤60 LOC

**Tests (≥20 NEW):**
32. NEW `packages/domain/crowd/test_narrative.py` ≤120 LOC (≥4 tests — Narrative invariants + days_in_current_phase + PhaseTransition immutability)
33. NEW `packages/domain/crowd/test_pump_detection.py` ≤120 LOC (≥4 tests — PumpDetection invariants + status transition + signal_contribution validation)
34. NEW `packages/domain/crowd/services/test_narrative_phase_classifier.py` ≤180 LOC (≥6 tests — INCUBATION/EMERGING/MAINSTREAM/SATURATION/EXHAUSTION/REVERSAL/DEAD branches per spec § B.3 lines 301-333; threshold tuning round-trip)
35. NEW `packages/domain/crowd/services/test_pump_phase_classifier.py` ≤180 LOC (≥7 tests — PRE_PUMP/PUMP/DISTRIBUTION/DUMP/UNCERTAIN branches per spec § B.3 lines 379-423; confidence gate ≥0.4; weight tuning round-trip; **deterministic roundtrip test** per § B.8 "run same data twice, identical classifications")
36. NEW `packages/infrastructure/crowd/test_counter_narrative_generator.py` ≤140 LOC (≥4 tests — happy path mock-LLM Vietnamese fixture; **regex gate fires for "approximately 18%"** in bear-point output; D-026 pattern citations in docstring; BR-6 trigger at bullish_ratio>0.8)
37. NEW `packages/infrastructure/crowd/test_pump_evidence_summarizer.py` ≤120 LOC (≥3 tests — happy path; regex gate for numeric output; gatherer-wired numbers come from code)
38. NEW `packages/infrastructure/crowd/test_historical_analog_finder.py` ≤140 LOC (≥4 tests — embedding similarity search; subsequent_return_12m filtering; top-K result shape; novel-pattern fallback returns empty list)
39. NEW `packages/application/crowd/use_cases/test_update_narrative_lifecycle.py` ≤100 LOC (≥3 tests — orchestration with mock repos + classifier; emits NarrativePhaseChanged on phase change)
40. NEW `packages/application/crowd/use_cases/test_detect_pump_phase.py` ≤140 LOC (≥4 tests — orchestration; **Phase 1 human-review-first**: status='pending_review' at creation; PumpPhaseDetected event NOT fired until status='reviewed_approved'; UNCERTAIN phase returns None per spec § UC-3 line 348)
41. NEW `packages/application/crowd/use_cases/test_generate_counter_narrative.py` ≤120 LOC (≥3 tests — **MANDATORY trigger** at bullish_ratio>0.8 per BR-6; bear-points grounded in 3 sources; CounterNarrative aggregate persistence)

**Vietnamese-language fixture set extension:**
- NEW `packages/infrastructure/crowd/fixtures/vi_counter_narratives/` directory + 3+ JSON fixtures (ticker + bullish_consensus + failing_analogs + expected bear-point themes)
- NEW `packages/infrastructure/crowd/fixtures/vi_pump_evidence/` directory + 3+ JSON fixtures (ticker + signals + historical_matches + expected evidence-text shape)
- NEW `eval-sets/labeled-pumps/` directory + 5-10 JSON fixtures (LabeledPump entries seeded manually per spec § B.7; 70/30 train/holdout split for BR-5 gate)

**EDIT (1):**
- `agent-workspace/memory/current-execution.md` (+ S53 row at top)

**Total**: ~25 files NEW + ~10 fixtures + 1 EDIT + ~1,800 LOC + ≥20 NEW tests.

### Test Pyramid Budget (S53)

| Tier | Count | LOC | Examples |
|---|---|---|---|
| **Unit (domain + services)** | ≥21 tests | ~700 LOC | Narrative + PumpDetection invariants; classifier branches; deterministic roundtrip |
| **Unit (infrastructure)** | ≥11 tests | ~400 LOC | LLM-mocked counter-narrative + pump-evidence; embedding-mocked analog finder; SQLite repo roundtrip |
| **Integration (use case)** | ≥10 tests | ~360 LOC | UpdateNarrativeLifecycle + DetectPumpPhase + GenerateCounterNarrative orchestration |
| **E2E (backtest)** | 1 test | ~80 LOC | Backtest harness on holdout-set; **REQUIRED PASS for S53 close** |
| **TOTAL** | **≥43 tests** | **~1,540 LOC** | |

### Success Criteria (acceptance — 9 testable bullets)

- [ ] `pytest packages/domain/crowd/ packages/application/crowd/ packages/infrastructure/crowd/test_counter_narrative_generator.py packages/infrastructure/crowd/test_pump_evidence_summarizer.py packages/infrastructure/crowd/test_historical_analog_finder.py` ≥20 NEW PASS in <4s (cumulative BC-7 ≥50 PASS)
- [ ] **I-S1 NO-LLM-MATH enforced** — `grep -r "anthropic\|openai\|claude_llm\|llm_perspective" packages/domain/crowd/services/` returns 0; `grep -r "anthropic\|openai" packages/application/crowd/use_cases/update_narrative_lifecycle_use_case.py packages/application/crowd/use_cases/detect_pump_phase_use_case.py` returns 0 (LLM imports allowed only in counter-narrative + pump-evidence use cases via Port)
- [ ] **D-032(e)/(f) deterministic guarantee**: pytest runs PumpPhaseClassifier 2x on identical input → asserts identical (PumpPhase, confidence, contributions) tuple per § B.8 bootstrap test
- [ ] **D-026 pattern citation**: counter_narrative_generator.py + pump_evidence_summarizer.py file docstrings cite all 3 patterns by name (per-role override + prose-tolerant JSON + gatherer-wired compute)
- [ ] **BR-6 mandatory trigger**: pytest creates SentimentSnapshot with bullish_ratio=0.85 + dispatches GenerateCounterNarrativeUseCase → asserts CounterNarrative persisted + non-empty bear_points
- [ ] **BR-9 historical pattern fallback**: pytest creates PumpPhaseDetection with empty historical_similar_cases → asserts confidence capped at 0.6 per "novel pattern, low confidence" framing
- [ ] **BR-5 BACKTEST GATE — REQUIRED for S53 close**: `python -m apps.cli.backtest_pump_classifier --holdout-split=0.3` exits 0; reports precision >0.5 AND recall >0.3; failure escalates per D-032 § Rollback path
- [ ] **D-032(i) Phase 1 human-review-first**: pytest dispatches DetectPumpPhaseUseCase + asserts PumpDetection persisted with `status='pending_review'`; PumpPhaseDetected event NOT fired (only fires on subsequent reviewed_approved status update)
- [ ] **BR-10 NO public accusations** — pump_evidence_summarizer + counter_narrative_generator output regex-gated for operator-naming substrings + numeric percentage substrings; pytest asserts violation raises
- [ ] mypy --strict + ruff: 0 errors on Track K surface; D1 baseline still 0

### Open questions

| ID | Tier | Question | fire_when |
|---|---|---|---|
| Q-S53-1 | IMPL | HistoricalAnalogFinder embedding model: reuse OpenAI text-embedding-3-small per architecture.md § LLM, or local-only via sentence-transformers? | S53 entry — recommend OpenAI for Vietnamese quality + portability; document IMPL-S53-1 |
| Q-S53-2 | IMPL | LabeledPump seed: who labels? user-manual or agent-with-review? | S53 entry — recommend hybrid: agent drafts from spec § B.7 historical examples (2021-2024 VN pumps) + user reviews 5-10 entries; sets the eval-sets/labeled-pumps/ directory |
| Q-S53-3 | IMPL | sector_structural_risks query: stub for Phase 3 or wire to BC-3 Company Intelligence? | S53 entry — recommend stub if BC-3 sector-risk repo not wired (likely Phase 4); document IMPL-S53-3 + flag for Phase 4 wiring |
| Q-S53-4 | IMPL | Counter-narrative bear-points length cap: 500 chars per audit-traceability or longer? | S53 entry — recommend 500 chars per spec § B.5 + audit-trace alignment with KOL Recommendation BR-10 |
| Q-S53-5 | IMPL | Phase 1 human-review-first storage: `pending_review` status + UI queue at S57 — accept Phase 3 stub-UI? | S53 mid — recommend stub UI at S53 + full UI at S57 Track M |

### Risks (S53-specific cross-ref to master-plan R-P3-*)

- **R1 (HIGH) — R-P3-4 Pump detection false-positive rate**: BR-5 hold-out gate at S53 close + Phase 1 human-review-first per D-032(i); IF gate fails → SCOPE Q&A escalate; pump live-deploy deferred to S54
- **R2 (HIGH) — I-S1 violation creep in counter-narrative or pump-evidence LLM output**: explicit regex gate at output (`\d+\s*%|approximately|roughly`) + grep CI gate prevents I-S1 violations; counter_narrative_generator.py + pump_evidence_summarizer.py docstrings re-state "TEXT-ONLY OUTPUT — NO NUMERIC PER I-S1 + BR-4"
- **R3 (HIGH) — BR-10 operator-naming leakage in counter-narrative or pump-evidence text**: regex gate at output + LLM prompt instructs "NEVER name individuals or operators; frame as 'pattern detected'"; pytest BR-10 test verifies
- **R4 (MED) — LabeledPump dataset insufficient for BR-5 gate (5 historical pumps minimum needed)**: spec § B.7 calls for "10-20 historical pump events" — Phase 3 ships with 5-10 minimum; if user-time-constrained, agent-with-review drafts; document IMPL-S53-N
- **R5 (MED) — HistoricalAnalogFinder cold-start (no historical setup-fingerprints loaded)**: bootstrap script seeds 20+ historical ticker-period fingerprints from BC-1 Quote repo + BC-2 Fundamental repo if available; else empty fallback returns no analogs (BR-9 "novel pattern" framing applies)
- **R6 (LOW) — sector_structural_risks query unwired (BC-3 not yet built Phase 3)**: stub returns empty list; counter-narrative grounding falls back to 2 sources (bullish_consensus + failing_analogs); document IMPL-S53-N + Phase 4 wiring flag

### Rollback Path (S53)

- If BR-5 hold-out gate fails (precision ≤0.5 OR recall ≤0.3) → SCOPE Q&A escalate; pump live-deploy deferred to S54 META_LOOP_RECOVERY; counter-narrative + sentiment paths still ship (decoupled)
- If LLM regex gate fires repeatedly during integration tests (counter-narrative or pump-evidence with numeric output) → iterate prompt 1-2 cycles within session budget; if >2 cycles needed, defer prompt-iteration to Phase 4 + document IMPL-S53-N
- If LabeledPump seeding incomplete (<5 entries) → BR-5 gate cannot run; partial deploy: NarrativePhaseClassifier + counter-narrative ship; PumpPhaseClassifier deferred to S54 with backfill

---

## Cross-Cutting Acceptance (S52 + S53 cumulative)

- **Tests**: 30+ NEW S52 / 20+ NEW S53 = **≥50 NEW BC-7 tests cumulative** (target per master-plan; matches D-032 verifier baseline)
- **mypy --strict + ruff**: 0 errors on BC-7 surface across both sessions; D1 baseline still 0
- **I-S1 NO-LLM-MATH**: enforced via grep gate at S53 close; classifiers + use cases deterministic; LLM ONLY in counter-narrative + pump-evidence + sentiment-classifier text output
- **BR-4 categorical-only**: enforced at LlmSentimentClassifier output + verified in repo roundtrip (Sentiment enum DB column)
- **BR-5 BACKTEST GATE**: precision >0.5 + recall >0.3 hold-out at S53 close; CLI harness `apps/cli/backtest_pump_classifier.py`
- **BR-6 MANDATORY counter-narrative**: enforced at use case orchestration; pytest verified
- **BR-8 conservative coordination threshold ≥0.8**: enforced at CoordinationDetector + verified
- **BR-9 historical pattern matching**: every PumpDetection cross-references; novel-pattern confidence cap at 0.6
- **BR-10 NO public accusations**: payload schema enforcement + regex gate at LLM output + UI framing reminder for S57 Track M
- **D-026 LLM Substrate Boundary**: cited verbatim in S52 sentiment_classifier docstring + S53 counter_narrative_generator + pump_evidence_summarizer file docstrings (per-role override + prose-tolerant JSON + gatherer-wired compute)
- **No commits**: per CLAUDE.md hard rule + S43c carry-forward; staged-only across both sessions

---

## Cost Projection

| Item | Estimate | Source |
|---|---|---|
| **S52 LLM sentiment classification 50-fixture × 3-strategy probe** | ~$3-6 one-time | per L-S32-1 ladder; required at S52 entry |
| **S52 cumulative ongoing** | ~$0.05-0.15/snapshot batch (50 posts/call Haiku) | ~6x cheaper per-token vs KOL extraction |
| **S53 50-fixture × 3-strategy counter-narrative probe** | NOT REQUIRED (single LLM strategy; D-026 already proven Phase 2) | reuse Sonnet 4.6 default per BC-8 + BC-6 precedent |
| **S53 LLM bear-point generation cost** | ~$0.10-0.30/counter-narrative | Sonnet 4.6; quality-driven |
| **S53 LLM pump-evidence summary cost** | ~$0.05-0.15/pump-detection | Sonnet 4.6; rare-call (Phase 1 human-review-first) |
| **S53 OpenAI text-embedding-3-small cost** | ~$0.001/embedding × 100 setup-fingerprints bootstrap | one-time bootstrap; embedding cache |
| **BC-7 sessions external burn total** | ~$5-12 (probe + light dogfood) | well within Phase 3 cumulative envelope |

**Token envelope per master-plan**:
- S52: 150-220K main + 50-100K subagent
- S53: 150-220K main + 100-150K subagent
- **Cumulative**: ~300-440K main + 150-250K subagent (matches master-plan § Calibration Envelope row "Substantive tracks J+K (BC-7)")

---

## Sandwich Coverage

Per Phase 3 BC-6 precedent (S45 PLAN + S46+S47+S49 IMPL + S50 VERIFY) + master-plan § Sandwich Coverage:

| Stage | Session | Agent |
|---|---|---|
| **Architect (PLAN)** | **S65 (this dispatch; logical S51)** | sandwich-architect subagent |
| **Dev IMPL Track J** | **S52** | main session (Dev half) |
| **Dev IMPL Track K** | **S53** | main session (Dev half) |
| **UI/dogfood** | **S57** | embedded in cross-cutting Track M |
| **VERIFY whole-Phase-3 (incl. BC-7)** | **S59** | sandwich-verifier subagent (consolidated per master-plan) |

S54 META_LOOP_RECOVERY reserve fires only if S52/S53 trigger; otherwise skip.

---

## Files Created by This Sub-Plan (S65 deliverables)

1. `agent-workspace/session-plans/pending/009-S51-track-J-K-impl-sub-plan.md` (this file)
2. `agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md` (D-032 same-session)

---

## Connection to Master-Plan + Constitution + Spec

| Source | Section | How this sub-plan honors |
|---|---|---|
| `007-S44-phase-3-master-plan.md` § Track Catalog J/K | 2 substantive tracks | S52 = Track J, S53 = Track K, both per master-plan envelope rows |
| `007-S44` § Risk Register R-P3-1 | LLM extraction quality HIGH | S52 mandatory empirical-probe-first sentiment classifier (≥3 strategies; per-label accuracy ≥0.85 gate) |
| `007-S44` § Risk Register R-P3-2 | F319 + FB ToS HIGH | S52 crawler-reliability skill + ToS pre-flight + IP-rotation hook (Q-P3-2 ALL-3 binding extending to FB groups for crowd) |
| `007-S44` § Risk Register R-P3-4 | Pump detection false-positive MED | S53 BR-5 hold-out gate + Phase 1 human-review-first |
| `007-S44` § Risk Register R-P3-6 | Subagent stream stall MED | This sub-plan authored with lean ≤6 pre-reads per L-S43f-2 |
| `007-S44` § Open Questions | Q-P3-2 RESOLVED + Q-P3-4 IMPL auto | D-032 reflects user picks verbatim |
| `agent-workspace/constitution/architecture.md` § "LLM Substrate Boundary" (D-026) | All 3 patterns binding | S52 sentiment_classifier + S53 counter_narrative + pump_evidence cite verbatim per D-032(d)+(g) |
| `agent-workspace/constitution/invariants.md` § I-S1 | NO LLM math | S53 narrative_phase_classifier + pump_phase_classifier grep-gated 0 LLM imports; LLM text-output regex-gated for numeric leakage |
| `agent-workspace/constitution/invariants.md` § I-S2 | Provenance + as-of | All BC-7 entities have captured_at + extracted_at + source_url provenance |
| `agent-workspace/constitution/invariants.md` § I-S13 | Counter-narrative mandatory hot-stocks | BR-6 enforced at GenerateCounterNarrativeUseCase; pytest verified |
| `agent-workspace/constitution/invariants.md` § I-S35 | Research-aid framing | "pattern detected, exercise caution" framing in coordination + pump output; never "buy/sell" recommendation |
| `specs/tier2-feature/003-crowd-sentiment-pump-detection.md` § A.3 BR-1..BR-10 | All BRs | Mapped per-deliverable: BR-1+BR-2 S52 / BR-3 across both / BR-4 S52 / BR-5 S53 / BR-6 S53 / BR-7 S53 / BR-8 S52 / BR-9 S53 / BR-10 S52+S53 |
| `specs/tier2-feature/003` § B.3 UC-1..UC-4 | UC-1 S52 / UC-2 S53 / UC-3 S53 / UC-4 S53 / UC-5 deferred to S57 dashboard FOMO Detection | Per-UC traceability via deliverable file paths |
| `specs/tier2-feature/003` § B.8 quality gates | Bootstrap + 2% sample + Phase 1 human-review-first | S53 deterministic-roundtrip test + S57 sample queue + Phase 1 status='pending_review' D-032(i) |

---

## End of Sub-Plan

> Next action: User runs `/session-start` (or types "continue" if autonomous) →
> S52 entry; pre-flight reads §S52 above; pre-flight projection check (split if
> >230K); MULTI_TASK_IMPL execute per § Deliverables. Per CLAUDE.md never-mix:
> S65 (this PLAN session) closes here; S52 starts fresh session.
