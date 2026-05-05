---
plan_id: 008-S45-track-G-H-I-impl-sub-plan
phase: 3
parent_plan: agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md
sessions_covered: S46 + S47 + S49
status: active
authored: 2026-05-05
authored_by: Claude Opus 4.7 (S45 sandwich-architect dispatch; lean ≤6 pre-reads per L-S43f-2)
binding_spec: specs/tier2-feature/002-influence-network-tracking.md
binding_adr: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md
binding_constitution: agent-workspace/constitution/architecture.md § "LLM Substrate Boundary" (D-026)
mode: AUTONOMOUS
---

# S45 Track G+H+I IMPL Sub-Plan — S46 + S47 + S49 (BC-6 Influence Network)

> **Goal**: Per-session deliverables matrix for BC-6 ship across S46 (Track G
> adapters) + S47 (Track H LLM extraction) + S49 (Track I calibration).
> Mirrors `006-S41-track-F-impl-sub-plan.md` format.
>
> **Binding spec**: `specs/tier2-feature/002-influence-network-tracking.md`
> **Binding ADR**: `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (D-027 same-session)
> **Binding master-plan**: `007-S44-phase-3-master-plan.md` § Track Catalog G/H/I + § Session Breakdown S46/S47/S49

---

## Identity & Scope

**3 sessions ship**:
- **S46** — Track G — 3 KOL channel adapters (YouTube + Telegram + Facebook) + shared rate-limited fetcher base + CLI smoke
- **S47** — Track H — LLM-perspective recommendation extractor (Vietnamese-language; D-026 substrate-boundary patterns); empirical-probe-first ladder at session entry (≥3 strategies)
- **S49** — Track I — Bayesian calibration domain service + outcome scheduler + KOL repository + provisional→active auto-transition

**3 sessions DO NOT ship**:
- Confluence detection (UC-4) — embedded in S57 dashboard cross-cutting
- Streamlit pages (UC-1 daily digest / UC-2 ticker sentiment / UC-4 calibration browser) — S57 cross-cutting Track M
- Pump-operator detection (UC-5) — BC-7 territory; ships at S52+S53 (separate sub-plan 009-S51)
- Postgres migration — Phase 4 SaaS-deploy boundary per L-S17-1

**Critical path**: S45 (this PLAN + D-027) → S46 → S47 → S49 → S50 (sandwich-verifier whole-BC-6).

S48 META_LOOP_RECOVERY reserve fires only if S46/S47 surface drift or substrate gap (per master-plan § Session Breakdown).

---

## SCOPE-tier User-Gate Reminders

Per master-plan § Open Questions: Q-P3-1/2/3 ALL RESOLVED at S44. Q-P3-4
IMPL-tier auto-decided (SQLite per D-027(a)). No SCOPE-tier user-gates
pending entry to S46.

S47 entry has 1 IMPL-tier auto-decide (LLM strategy pick from probe matrix);
escalate via Q&A bundle ONLY if all 3 strategies probe <0.85 precision (per
D-027 § Rollback path).

---

## S46 — Track G IMPL (3 KOL Channel Adapters + Fetcher Base + CLI)

### Meta

| Field | Value |
|---|---|
| Session type | MULTI_TASK_IMPL |
| Agent | main (Dev half of sandwich; S50 Verifier closes BC-6) |
| Budget envelope | 150-220K main + 50-100K subagent (per master-plan §S46) |
| Predecessor | S45 (this plan + D-027) |
| Successor | S47 |
| Decision tier | IMPL — per D-027(b) shared Protocol + 3 concretes; sub-decisions IMPL-tier |
| Split doctrine | If pre-flight projects >230K, split S46a (Protocol + base + YouTube) / S46b (Telegram + Facebook + CLI + tests) |

### Goal

Ship BC-6 adapter substrate: shared `KOLChannelAdapter` Protocol + `RateLimitedFetcher`
base + 3 platform concretes (YouTube + Telegram + Facebook) + CLI smoke + ~30 NEW
tests. All network calls mocked in CI; live smoke gated to manual `pytest -m live`.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/002-influence-network-tracking.md` § A.3 BR-1 (public-only) + § B.4 adapters + § B.7 cadences
2. `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (D-027 binding)
3. `packages/infrastructure/news/claude_llm_extractor.py` (S36 BC-5 reference for adapter patterns + provenance fields + UTF-8 Vietnamese handling)
4. `.claude/skills/crawler-reliability/SKILL.md` (per R-P3-2 mitigation; user-agent rotation + Playwright stealth + backoff procedure)
5. `agent-workspace/constitution/architecture.md` § BC-6 + § Folder Conventions

VBW pre-flight per L-S30-1: `Glob` each NEW directory before Write; verify no
existing file at target path.

### Deliverables (~14 files NEW + 2 EDIT; ~1,800 LOC; ≥30 NEW tests)

**BC-6 Domain (`packages/domain/influence_network/`):**
1. NEW `packages/domain/influence_network/__init__.py` ≤25 LOC (barrel)
2. NEW `packages/domain/influence_network/value_objects/__init__.py` + `kol_id.py` + `channel_id.py` + `recommendation_id.py` + `kol_style.py` (StrEnum 5 values per spec § B.1) + `kol_status.py` (StrEnum 5 values) + `intent.py` (StrEnum 6 values) + `timeframe.py` (StrEnum 5 values) — ≤25 LOC each, 8 files total
3. NEW `packages/domain/influence_network/models/__init__.py` + `kol.py` ≤120 LOC (Kol aggregate + transition_to_active behavior per UC-3 § auto-transition) + `channel.py` ≤80 LOC (Channel aggregate; platform StrEnum embedded) + `channel_content.py` ≤90 LOC (raw fetched content VO; published_at + url + raw_text + media_urls)

**BC-6 Application Ports (`packages/application/influence_network/`):**
4. NEW `packages/application/influence_network/__init__.py` ≤15 LOC + `ports/__init__.py` + `ports/kol_channel_adapter_port.py` ≤60 LOC (Protocol per D-027(b); methods `fetch_new_content(channel, since)` + `is_public(channel_url)` + `respect_rate_limit()`)

**BC-6 Infrastructure (`packages/infrastructure/influence_network/`):**
5. NEW `packages/infrastructure/influence_network/__init__.py` ≤15 LOC
6. NEW `packages/infrastructure/influence_network/rate_limited_fetcher.py` ≤180 LOC (base class; backoff + user-agent rotation + ToS pre-flight via robots.txt check + IP-rotation hook per Q-P3-2 R-P3-2; uses `httpx` + `tenacity`; refuses private content per BR-1)
7. NEW `packages/infrastructure/influence_network/youtube_adapter.py` ≤220 LOC (yt-dlp + YouTube Data API v3; quota tracker; daily 20:00 cadence per § B.7; auto-caption fetch with language=vi preference)
8. NEW `packages/infrastructure/influence_network/telegram_adapter.py` ≤180 LOC (Telegram Bot API for public broadcast channels; 1h cadence; message-link as source_url)
9. NEW `packages/infrastructure/influence_network/facebook_adapter.py` ≤220 LOC (Graph API for public fanpages ONLY per BR-1; 4h cadence during 8:00-22:00; refuses on private or login-required + raises `ToSBoundaryViolation`; documented gray-zone per Q-P3-2 user accept)
10. NEW `apps/cli/ingest_kol_channels.py` ≤120 LOC (Click CLI; flags `--platform=all|youtube|telegram|facebook` + `--channel-id` + `--dry-run`; smoke-test entry point)

**Tests (≥30 NEW):**
11. NEW `packages/domain/influence_network/test_value_objects.py` ≤140 LOC (≥8 tests — StrEnum membership + KolId/ChannelId/RecommendationId construction)
12. NEW `packages/domain/influence_network/test_models.py` ≤200 LOC (≥10 tests — Kol PROVISIONAL→ACTIVE transition gated on n_evaluated≥10; Channel platform invariant; ChannelContent published_at not-future)
13. NEW `packages/infrastructure/influence_network/test_rate_limited_fetcher.py` ≤120 LOC (≥6 tests — backoff schedule; ToS pre-flight rejects private; user-agent rotation; httpx mocked via `respx`)
14. NEW `packages/infrastructure/influence_network/test_adapters.py` ≤180 LOC (≥6 tests; 2 per platform — public-only enforcement + cadence respect; live calls mocked)

**EDIT (2):**
- `pyproject.toml` (+ yt-dlp ≥2024.10 + tenacity ≥9.0 + respx ≥0.21 deps)
- `agent-workspace/memory/current-execution.md` (+ S46 row at top)

**Total**: ~14 files NEW + 2 EDIT + ~1,800 LOC + ≥30 NEW tests.

### Success Criteria (acceptance — 7 testable bullets)

- [ ] `pytest packages/domain/influence_network/ packages/infrastructure/influence_network/` ≥30 PASS in <4s
- [ ] All 3 adapters mockable (no live network calls in default `pytest`); live calls behind `pytest -m live` opt-in
- [ ] BR-1 public-only enforcement: each adapter `is_public()` returns False for known-private URL fixture → adapter raises `ToSBoundaryViolation`; pytest asserts
- [ ] No framework imports in `packages/domain/influence_network/**` — grep `from fastapi\|from pydantic\|import django\|import httpx` returns 0
- [ ] Cross-BC import grep — `grep -r "from packages.domain.market_data\|from packages.domain.fundamental\|from packages.domain.news" packages/domain/influence_network/` returns 0
- [ ] mypy --strict + ruff: 0 errors on BC-6 surface; D1 baseline still 0
- [ ] CLI smoke: `python -m apps.cli.ingest_kol_channels --platform=youtube --channel-id=<fixture> --dry-run` exits 0; logs ≥1 ChannelContent fetch

### R-P3-2 mitigation checklist (Q-P3-2 ALL-3-platforms binding)

- [ ] crawler-reliability skill invoked at S46 entry (per .claude/skills/crawler-reliability/SKILL.md)
- [ ] ToS pre-flight: each adapter checks robots.txt + platform ToS public-content boundary
- [ ] Rate-limit: backoff matrix per platform (YouTube ~1 req/s + Telegram ~1 req/sec via Bot API + Facebook ~2 req/s Graph)
- [ ] User-agent rotation: 3-UA pool minimum per crawler-reliability/SKILL.md
- [ ] IP rotation hook: stub for Phase 4 proxy integration; documented in `RateLimitedFetcher` docstring (NOT implemented — stub only Phase 3)
- [ ] Monitoring: each adapter logs `(platform, channel_id, status, latency_ms)` to `.session-hooks.log` for post-run audit

### Open questions (queued-grill candidates)

| ID | Tier | Question | fire_when |
|---|---|---|---|
| Q-S46-1 | IMPL | YouTube quota daily limit (10K units default); use yt-dlp scrape-fallback when API exhausted? | S46 mid-session — recommend YES; document IMPL-S46-1 |
| Q-S46-2 | IMPL | Facebook Graph API requires App Review for some endpoints; restrict to v18+ public-page-posts only? | S46 entry — recommend YES; document IMPL-S46-2 |
| Q-S46-3 | IMPL | Telegram public-channel ID format: `@channel_name` vs numeric `-1001234567890`? | S46 mid-session — recommend support both; normalize to numeric internally |

### Risks (S46-specific)

- **R1 (HIGH) — Facebook ToS shifts mid-Phase-3**: per Q-P3-2 user explicit-accept gray-zone; mitigation = adapter raises `ToSBoundaryViolation` early + falls back to manual link-list mode if Graph API auth shifts
- **R2 (MED) — yt-dlp version drift breaks YouTube scraping**: pin to 2024.10+ in pyproject.toml; add weekly version-check to `vendor-api-probe.sh` skill
- **R3 (MED) — Vietnamese auto-caption quality on YouTube**: documented limitation; Track H S47 LLM extraction must handle noisy input gracefully
- **R4 (LOW) — IP block from Facebook Graph during dogfood**: rate-limit conservative + IP rotation hook stub ready for Phase 4

---

## S47 — Track H IMPL (LLM-Perspective Recommendation Extractor)

### Meta

| Field | Value |
|---|---|
| Session type | FOCUSED_IMPL |
| Agent | main (Dev half of sandwich; S50 Verifier closes BC-6) |
| Budget envelope | 130-180K main + 100-150K subagent (per master-plan §S47) |
| Predecessor | S46 |
| Successor | S49 |
| Decision tier | IMPL per D-027(d); strategy pick from empirical probe |

### Goal

Ship single LLM-perspective adapter `llm_recommendation_extractor.py` citing
architecture.md § "LLM Substrate Boundary" verbatim (per-role override +
prose-tolerant JSON + gatherer-wired compute per D-026 + D-027(d)). Extracts
Recommendation entities from Vietnamese KOL transcripts per spec 002 § B.5
prompt. ≥15 NEW tests with Vietnamese-language fixtures.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/002-influence-network-tracking.md` § B.5 LLM extraction prompt + § B.1 Recommendation entity + § A.3 BR-6 (extraction confidence threshold) + BR-7 (conditional separation) + BR-10 (provenance)
2. `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` § (d) LLM extractor substrate
3. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` + `packages/infrastructure/analysis/subagent_transport.py:55-118` (S43b BC-8 reference; reuse 3-tier extractor function)
4. `.claude/skills/empirical-probe-first/SKILL.md` (S43e ratified skill; mandatory invocation at S47 entry per L-S32-1)
5. `agent-workspace/constitution/architecture.md` § "LLM Substrate Boundary" verbatim

### EMPIRICAL-PROBE-FIRST INVOCATION (mandatory at S47 entry)

Per L-S32-1 + master-plan § R-P3-1 HIGH severity: BEFORE writing the extractor,
invoke `empirical-probe-first` skill to test ≥3 strategies on 50-fixture
Vietnamese KOL transcript labeled set:

| Strategy | Model(s) | Estimated $/50-fixture | Notes |
|---|---|---|---|
| **S1 Claude Opus** | claude-opus-4-7 | ~$5-7 | High precision; baseline |
| **S2 Claude Sonnet** | claude-sonnet-4-6 | ~$1-2 | Cost-baseline; precision tradeoff |
| **S3 Haiku-prefilter + Sonnet-extract** | claude-haiku-3-5 (filter) + claude-sonnet-4-6 (extract) | ~$2-3 | Hybrid; Haiku discards non-recommendation segments |

**Probe budget**: ~$8-12 one-time at S47 entry.
**Pick criterion**: precision/recall on labeled fixture; require precision ≥0.85
per master-plan § Phase 3 Success Criterion #2.
**Rollback**: if all 3 strategies <0.85 precision → escalate via SCOPE Q&A
bundle per D-027 § Rollback path; defer Track H to S48 META_LOOP_RECOVERY.

### Deliverables (~6 files NEW + 1 EDIT; ~700 LOC; ≥15 NEW tests)

**BC-6 Domain extension:**
1. NEW `packages/domain/influence_network/models/recommendation.py` ≤180 LOC (Recommendation aggregate; `__post_init__` enforces BR-10 provenance + BR-6 confidence ≥0.7 for non-manual-review path; `transcript_excerpt` ≤500 chars per spec § B.6)

**BC-6 Application Port:**
2. NEW `packages/application/influence_network/ports/llm_recommendation_extractor_port.py` ≤50 LOC (Protocol; method `extract(transcript, source_metadata) -> list[Recommendation]`)

**BC-6 Infrastructure (LLM extractor):**
3. NEW `packages/infrastructure/influence_network/kol_content_gatherer.py` ≤100 LOC (per D-027(d) gatherer-wired compute pattern; prepares transcript + channel-metadata + extraction-config; numbers come from code per I-S1)
4. NEW `packages/infrastructure/influence_network/llm_recommendation_extractor.py` ≤220 LOC (implements `LLMRecommendationExtractorPort`; cites D-026 patterns: per-role override dict + prose-tolerant JSON via `subagent_transport.py:55-118` reuse + gatherer-wired compute; prompt verbatim from spec § B.5)
5. NEW `packages/infrastructure/influence_network/extraction_strategy_picker.py` ≤80 LOC (encapsulates strategy chosen at S47 probe; documented as S47-IMPL-N artifact with probe matrix in docstring)

**Tests (≥15 NEW):**
6. NEW `packages/infrastructure/influence_network/test_llm_recommendation_extractor.py` ≤220 LOC (≥10 tests — happy path mock-LLM Vietnamese fixture; BR-6 confidence <0.7 routed to manual review; BR-7 conditional flag preserved; prose-tolerant JSON survives preamble; Vietnamese diacritics preserved)
7. NEW `packages/domain/influence_network/test_recommendation.py` ≤140 LOC (≥5 tests — invariant enforcement BR-10 missing source_url raises; transcript_excerpt >500 chars raises; conditional flag round-trip)

**Vietnamese-language fixture set:**
- NEW `packages/infrastructure/influence_network/fixtures/vi_kol_transcripts/` directory + 5+ JSON fixtures (transcript text + expected extraction set; sourced from spec § B.5 examples + 4 NEW Vietnamese samples)

**EDIT (1):**
- `agent-workspace/memory/current-execution.md` (+ S47 row at top)

**Total**: ~6-7 files NEW + 5 fixtures + 1 EDIT + ~700 LOC + ≥15 NEW tests.

### Success Criteria (6 testable bullets)

- [ ] `pytest packages/domain/influence_network/test_recommendation.py packages/infrastructure/influence_network/test_llm_recommendation_extractor.py` ≥15 PASS in <3s
- [ ] LLM port mocked in CI; live calls behind `-m live` opt-in
- [ ] Empirical probe matrix documented at session-log + extractor docstring; ≥3 strategies tested; chosen strategy precision ≥0.85 on 50-fixture set
- [ ] Vietnamese-diacritic round-trip: 5 fixtures with `ổ ậ ề ữ ợ` survive extraction → assertion preserves bytes
- [ ] BR-6 confidence threshold enforced — pytest constructs LLM output with confidence=0.5, asserts routed to manual_review_queue NOT recommendation_repo
- [ ] BR-10 provenance enforced — pytest asserts every extracted Recommendation has source_url + transcript_excerpt + extractor_model + extractor_version + extracted_at
- [ ] D-026 pattern citation: extractor file docstring cites all 3 patterns (per-role override + prose-tolerant JSON + gatherer-wired compute) by name
- [ ] mypy --strict + ruff: 0 errors on Track H surface; D1 baseline still 0

### Open questions

| ID | Tier | Question | fire_when |
|---|---|---|---|
| Q-S47-1 | IMPL | Which Whisper model for YouTube transcription pre-LLM? Local whisper-cpp vs OpenAI API? | S47 entry — recommend whisper-cpp local (cost) with API fallback for hard audio |
| Q-S47-2 | IMPL | Should extraction store full LLM raw response for audit? Or only extracted entities? | S47 mid — recommend full raw response in `outputs/llm_responses/` for first 30 days then aggregate |
| Q-S47-3 | IMPL | KOL guest-appearance attribution (per spec § C.2) — to host or to guest? | S47 entry — defer to Phase 4 (out-of-scope this track); document in extractor docstring |

### Risks (S47-specific)

- **R1 (HIGH) — Vietnamese-NLP precision <0.85 on all 3 strategies**: rollback per D-027 § escalate; document at session-end as SCOPE-tier blocker
- **R2 (MED) — LLM JSON-in-prose preamble breaks naive parser**: BP-S43b-2 prose-tolerant JSON extractor reused directly from BC-8 (subagent_transport.py:55-118); battle-tested at Phase 2
- **R3 (MED) — Spec § B.5 prompt may need Vietnamese-locale tuning**: 50-fixture probe surfaces this; iterate prompt 1-2 cycles within session budget; if >2 cycles needed, defer prompt-iteration to Phase 4
- **R4 (LOW) — Cost overrun**: 50-fixture × 3-strategy probe ~$8-12 one-time; per-KOL session ~$0.15-0.40 estimated (per spec assumption); cumulative S47 ≤$15 budget cap

---

## S49 — Track I IMPL (Bayesian Calibration + Outcome Scheduler + KOL Repo)

### Meta

| Field | Value |
|---|---|
| Session type | MULTI_TASK_IMPL |
| Agent | main (Dev half of sandwich; S50 Verifier closes BC-6) |
| Budget envelope | 150-220K main (per master-plan §S49) |
| Predecessor | S47 |
| Successor | S50 (sandwich-verifier whole-BC-6) |
| Decision tier | IMPL per D-027(e) + (f); deterministic Python; sub-decisions IMPL-tier |

### Goal

Ship BC-6 calibration substrate: Bayesian credibility update domain service
(per spec § B.3 UC-3) + outcome review scheduler (per UC-2 + § B.7) + KOL +
Recommendation + OutcomeReview + CredibilityScore SQLite repositories +
provisional→active auto-transition (per BR-2). All deterministic Python; LLM
NEVER invoked in Track I per D-027(e) + I-S1.

### Pre-flight reads (≤5 files)

1. `specs/tier2-feature/002-influence-network-tracking.md` § B.3 UC-2 + UC-3 + § A.3 BR-2..BR-5 + § B.6 schema (theses + outcome_reviews + credibility_scores tables)
2. `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` § (e) calibration determinism + § (f) outcome scheduler
3. `packages/infrastructure/analysis/sqlite_thesis_repository.py` (S42 BC-8 reference for SQLite repo + payload_json portability pattern)
4. `agent-workspace/constitution/invariants.md` § I-S1 (NO LLM math) — CRITICAL for this track
5. `packages/domain/fundamental/services/ratio_service.py` (S34 BC-2 reference for deterministic-service pattern in domain layer)

### Deliverables (~12 files NEW + 1 EDIT; ~1,500 LOC; ≥25 NEW tests)

**BC-6 Domain (calibration + outcome):**
1. NEW `packages/domain/influence_network/models/credibility_score.py` ≤180 LOC (CredibilityScore aggregate per spec § B.1; `is_statistically_meaningful()` + `is_high_credibility()` methods)
2. NEW `packages/domain/influence_network/models/outcome_review.py` ≤140 LOC (OutcomeReview aggregate; ReviewWindow StrEnum 4 values; OutcomeStatus StrEnum 6 values; status transition invariants)
3. NEW `packages/domain/influence_network/value_objects/sector_score.py` ≤80 LOC + `timeframe_score.py` ≤80 LOC (per BR-5 disaggregation; frozen dataclasses)
4. NEW `packages/domain/influence_network/services/__init__.py` + `calibration_service.py` ≤220 LOC (per D-027(e); UC-3 verbatim per spec § B.3; uses scipy.stats.beta; skeptical Beta(5,5) prior; partial-as-0.5-success weighting per spec § UC-3; sector_scores + timeframe_scores compute helpers; **0 LLM imports — verifiable via grep**)
5. NEW `packages/domain/influence_network/services/outcome_evaluator.py` ≤180 LOC (per UC-2; `_evaluate_by_intent` mapping per spec § UC-2; threshold matrix DAYS=0.03 / WEEKS=0.05 / MONTHS=0.10 / LONG_TERM=0.15; conditional INVALID handling per BR-7)

**BC-6 Application:**
6. NEW `packages/application/influence_network/ports/__init__.py` ext + `kol_repository_port.py` ≤50 LOC + `recommendation_repository_port.py` ≤60 LOC + `outcome_review_repository_port.py` ≤50 LOC + `credibility_repository_port.py` ≤40 LOC + `outcome_scheduler_port.py` ≤40 LOC + `quote_lookup_port.py` ≤40 LOC + `benchmark_service_port.py` ≤40 LOC (Protocols)
7. NEW `packages/application/influence_network/use_cases/__init__.py` + `update_kol_credibility_use_case.py` ≤120 LOC (per spec § UC-3 verbatim) + `evaluate_outcome_review_use_case.py` ≤180 LOC (per spec § UC-2 verbatim)

**BC-6 Infrastructure (SQLite repos + scheduler):**
8. NEW `packages/infrastructure/influence_network/sqlite_kol_repository.py` ≤180 LOC (kols + channels tables per spec § B.6 SQLite-adapted)
9. NEW `packages/infrastructure/influence_network/sqlite_recommendation_repository.py` ≤180 LOC (recommendations table; `find_recent_for_kol_ticker` + `find_recent` query methods; BR-6 confidence filter ≥0.7)
10. NEW `packages/infrastructure/influence_network/sqlite_outcome_review_repository.py` ≤140 LOC (outcome_reviews table; `get_due` query for cron; UNIQUE(rec_id, window))
11. NEW `packages/infrastructure/influence_network/sqlite_credibility_repository.py` ≤120 LOC (credibility_scores table; sector_scores + timeframe_scores as TEXT json)
12. NEW `packages/infrastructure/influence_network/outcome_scheduler.py` ≤140 LOC (per D-027(f); on RecommendationExtracted writes 4 outcome_review rows with due_at = published_at + offset)
13. NEW `apps/cli/run_due_outcome_reviews.py` ≤80 LOC (Click CLI; daily 02:00 cron entry per § B.7; queries outcome_review_repo.get_due + dispatches EvaluateOutcomeReviewUseCase per due review)

**Cross-BC contract:**
14. NEW `packages/contracts/events/credibility_score_updated.py` ≤50 LOC (frozen dataclass per spec § B.2)
15. NEW `packages/contracts/events/outcome_review_completed.py` ≤50 LOC (frozen dataclass)

**Tests (≥25 NEW):**
16. NEW `packages/domain/influence_network/test_credibility_score.py` ≤140 LOC (≥6 tests — Beta CI math; is_statistically_meaningful threshold; is_high_credibility threshold)
17. NEW `packages/domain/influence_network/test_outcome_review.py` ≤120 LOC (≥5 tests — status transitions; ReviewWindow membership)
18. NEW `packages/domain/influence_network/services/test_calibration_service.py` ≤180 LOC (≥6 tests — Bayesian update with skeptical prior; partial-weight=0.5; sector disaggregation; cold-start behavior)
19. NEW `packages/domain/influence_network/services/test_outcome_evaluator.py` ≤120 LOC (≥4 tests — HIT/MISS/PARTIAL by intent×timeframe matrix; conditional INVALID per BR-7)
20. NEW `packages/application/influence_network/use_cases/test_update_kol_credibility.py` ≤120 LOC (≥4 tests — orchestration with mock repos; PROVISIONAL→ACTIVE transition at n_evaluated=10 per BR-2)
21. NEW `packages/infrastructure/influence_network/test_repos_and_scheduler.py` ≤180 LOC (≥6 tests — SQLite roundtrip for each repo; outcome_scheduler writes 4 rows per Recommendation; `get_due` returns only pending+past)

**EDIT (1):**
- `agent-workspace/memory/current-execution.md` (+ S49 row at top)

**Total**: ~15 files NEW + 1 EDIT + ~1,500 LOC + ≥25 NEW tests.

### Success Criteria (8 testable bullets)

- [ ] `pytest packages/domain/influence_network/ packages/application/influence_network/ packages/infrastructure/influence_network/test_repos_and_scheduler.py` ≥25 NEW PASS in <4s (cumulative BC-6 ≥70 PASS)
- [ ] **I-S1 NO-LLM-MATH enforced** — `grep -r "anthropic\|openai\|claude_llm\|llm_perspective" packages/domain/influence_network/services/` returns 0; `grep -r "anthropic\|openai" packages/application/influence_network/use_cases/update_kol_credibility_use_case.py` returns 0
- [ ] No framework imports in `packages/domain/influence_network/**` — grep `from fastapi\|from pydantic\|import django\|import sqlite3` returns 0
- [ ] BR-2 PROVISIONAL→ACTIVE auto-transition — pytest creates Kol PROVISIONAL + 10 outcome reviews + dispatches UpdateKolCredibilityUseCase → asserts kol.status == ACTIVE
- [ ] BR-7 conditional INVALID — pytest creates Recommendation with conditions=["if breaks 30k"] + dispatches EvaluateOutcomeReviewUseCase with condition_evaluator returning False → asserts review.status == INVALID NOT MISS
- [ ] Bayesian skeptical prior — pytest with n_hits=3 n_misses=0 → asserts bayesian_mean < 0.7 (skeptical Beta(5,5) prior dampens small-sample optimism)
- [ ] CLI cron smoke: `python -m apps.cli.run_due_outcome_reviews --dry-run` exits 0; logs `due_count=N`
- [ ] mypy --strict + ruff: 0 errors on Track I surface; D1 baseline still 0

### Open questions

| ID | Tier | Question | fire_when |
|---|---|---|---|
| Q-S49-1 | IMPL | Quote lookup port — wire to existing BC-1 Quote repository or stub for Phase 3? | S49 entry — recommend wire to BC-1 if S34 Quote repo exists; else stub + Phase 4 wire |
| Q-S49-2 | IMPL | Benchmark service VN-INDEX — wire to existing or stub? | S49 entry — same pattern as Q-S49-1 |
| Q-S49-3 | IMPL | scipy dep — add to pyproject.toml or implement beta-fn pure-python fallback? | S49 entry — recommend scipy (battle-tested + standard); ~25MB acceptable |

### Risks (S49-specific)

- **R1 (HIGH) — I-S1 violation creep**: explicit grep CI gate prevents; calibration_service.py file header docstring re-states "DETERMINISTIC ONLY — NO LLM IMPORTS PERMITTED"
- **R2 (MED) — Quote lookup port unwired**: Phase 3 BC-1 quote repo state uncertain; if not wired, stub + document IMPL-S49-N + flag for Phase 4 wiring
- **R3 (MED) — Cold-start behavior surprising**: Beta(5,5) prior with 0 evaluations gives mean=0.5 + wide CI; document in calibration_service docstring + test_calibration_service test_cold_start
- **R4 (LOW) — SQLite repo migration friction**: payload_json portable; same pattern as S42 BC-8 sqlite_thesis_repository — proven path

---

## Cross-Cutting Acceptance (S46 + S47 + S49 cumulative)

- **Tests**: 30+ NEW S46 / 15+ NEW S47 / 25+ NEW S49 = **≥70 NEW BC-6 tests cumulative** (target per master-plan)
- **mypy --strict + ruff**: 0 errors on BC-6 surface across all 3 sessions; D1 baseline still 0
- **I-S1 NO-LLM-MATH**: enforced via grep gate at S49 close; calibration deterministic
- **D-026 LLM Substrate Boundary**: cited verbatim in S47 extractor file docstring (per-role override + prose-tolerant JSON + gatherer-wired compute)
- **BR-1 public-only**: enforced at adapter layer (S46) + verified at S47 extraction (source_url provenance check)
- **BR-2 PROVISIONAL→ACTIVE**: auto-transition tested at S49
- **BR-10 provenance**: Recommendation `__post_init__` invariant at S47; verified in repo roundtrip at S49
- **No commits**: per CLAUDE.md hard rule + S43c carry-forward; staged-only across all 3 sessions

---

## Cost Projection

| Item | Estimate | Source |
|---|---|---|
| **S47 LLM extraction per KOL session** | ~$0.15-0.40/session | spec § BR-? estimate + similar BC-5 extraction pattern |
| **S47 50-fixture × 3-strategy empirical probe** | ~$8-12 one-time | per L-S32-1 ladder; required at session entry |
| **S46 cumulative cost** | $0 (all mocked + dry-run only) | no live LLM calls Track G |
| **S49 cumulative cost** | $0 (deterministic Python only) | I-S1 + D-027(e) |
| **BC-6 sessions external burn total** | ~$10-20 (probe + light dogfood) | well within Phase 3 cumulative envelope |

**Token envelope per master-plan**:
- S46: 150-220K main + 50-100K subagent
- S47: 130-180K main + 100-150K subagent
- S49: 150-220K main (no subagent)
- **Cumulative**: ~430-620K main + 200-350K subagent (matches master-plan § Calibration Envelope row "Substantive tracks G+H+I")

---

## Sandwich Coverage

Per Phase 2 Track F precedent (S41 PLAN + S42 IMPL + S43a UI + S43 VERIFY):

| Stage | Session | Agent |
|---|---|---|
| **Architect (PLAN)** | **S45** | sandwich-architect subagent (this dispatch) |
| **Dev IMPL Track G** | **S46** | main session (Dev half) |
| **Dev IMPL Track H** | **S47** | main session (Dev half) |
| **Dev IMPL Track I** | **S49** | main session (Dev half) |
| **UI/dogfood** | **S57** | embedded in cross-cutting Track M |
| **VERIFY whole-BC-6** | **S50** | sandwich-verifier subagent |

S48 META_LOOP_RECOVERY reserve fires only if S46/S47 trigger; otherwise skip.

---

## Files Created by This Sub-Plan (S45 deliverables)

1. `agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md` (this file)
2. `agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md` (D-027 same-session)

---

## Connection to Master-Plan + Constitution + Spec

| Source | Section | How this sub-plan honors |
|---|---|---|
| `007-S44-phase-3-master-plan.md` § Track Catalog G/H/I | 3 substantive tracks | S46 = Track G, S47 = Track H, S49 = Track I, all per master-plan envelope rows |
| `007-S44` § Risk Register R-P3-1 | LLM extraction quality HIGH | S47 mandatory empirical-probe-first (≥3 strategies; precision ≥0.85 gate) |
| `007-S44` § Risk Register R-P3-2 | KOL crawler ToS HIGH | S46 crawler-reliability skill + ToS pre-flight + IP-rotation hook (Q-P3-2 ALL-3 binding) |
| `007-S44` § Risk Register R-P3-6 | Subagent stream stall MED | This sub-plan authored with lean ≤6 pre-reads per L-S43f-2 |
| `007-S44` § Open Questions | Q-P3-1/2/3 RESOLVED + Q-P3-4 IMPL auto | D-027 reflects user picks verbatim |
| `agent-workspace/constitution/architecture.md` § "LLM Substrate Boundary" (D-026) | All 3 patterns binding | S47 extractor cites verbatim per D-027(d) |
| `agent-workspace/constitution/invariants.md` § I-S1 | NO LLM math | S49 calibration_service.py grep-gated 0 LLM imports |
| `agent-workspace/constitution/invariants.md` § I-S2 | Provenance + as-of | BR-10 enforced at Recommendation __post_init__ S47 |
| `agent-workspace/constitution/invariants.md` § I-S35 | Research-aid framing | Recommendation entity uses "intent" StrEnum (BUY/AVOID/WATCH) per spec; never "advice" framing |
| `specs/tier2-feature/002-influence-network-tracking.md` § A.3 BR-1..BR-10 | All BRs | Mapped per-deliverable: BR-1 S46 / BR-2 S49 / BR-3 S49 / BR-6+10 S47 / BR-7 S49 |
| `specs/tier2-feature/002` § B.3 UC-1..UC-5 | UC-1 S46+S47 / UC-2 S49 / UC-3 S49 / UC-4 S57 / UC-5 BC-7 | Per-UC traceability via deliverable file paths |

---

## End of Sub-Plan

> Next action: User runs `/session-start` (or types "continue" if autonomous) →
> S46 entry; pre-flight reads §S46 above; pre-flight projection check (split if
> >230K); MULTI_TASK_IMPL execute per § Deliverables. Per CLAUDE.md never-mix:
> S45 (this PLAN session) closes here; S46 starts fresh session.
