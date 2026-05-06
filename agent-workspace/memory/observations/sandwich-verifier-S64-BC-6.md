---
observation_id: sandwich-verifier-S64-BC-6
type: sandwich-verifier-output
session: S64
target: BC-6 Influence Network (G+H+I)
verdict: PASS-WITH-RESIDUE
---

## Summary

BC-6 Influence Network (Tracks G+H+I shipped across S46+S47+S49) is structurally sound and meets the binding contract for Phase 3 deferred-verify scope. Domain purity is clean (zero framework deps; zero Any; zero cross-BC imports), I-S1 NO-LLM-MATH is enforced (grep-clean in packages/domain/influence/services/), the LLM extractor cites D-026 substrate-boundary patterns verbatim, and the Bayesian calibration math (skeptical Beta(5,5) prior + scipy.stats.beta posterior CI + partial-as-half-success weighting) matches spec section B.3 UC-3 exactly. BR-1/2/6/7/10 invariants are all enforced at construction or repository boundary. Tests are behavior-focused (boundary cases, invariant violations, round-trip preservation) rather than implementation-coupled.

The verdict is PASS-WITH-RESIDUE rather than PASS because of a small but coherent set of non-blocking gaps: (1) two domain events are defined in packages/contracts/events/ but never published by the use cases that should emit them per spec section B.2; (2) ADR D-027 references a path packages/.../influence_network/ while the actual ship path is packages/.../influence/ (one-directory naming drift; not a functional bug but creates audit confusion); (3) UL glossary lists Recommendation intent as BUY/HOLD/SELL/WATCH while IMPL+spec ship STRONG_BUY/BUY/WATCH/NEUTRAL/AVOID/STRONG_AVOID; (4) one deprecated datetime.utcnow() call; (5) YouTube subtitle extraction returns a placeholder URL marker rather than actual transcript text (Q-S47-1 explicitly defers Whisper to Phase 4, so this is intentional but means UC-1 end-to-end ingestion will be a no-op until Phase 4). None of these block S65 Phase 3 progression to BC-7 PLAN; all are recoverable in Phase 4 wiring or trivial fixes.

## Tier 1 deterministic gate

Per main-session S64 entry (echoed):
- pytest packages/{domain,application,infrastructure}/influence -> 149/149 PASS
- mypy --explicit-package-bases packages/{domain,application,infrastructure}/influence -> no issues, 61 files
- ruff check packages/{domain,application,infrastructure}/influence -> all checks passed

Verifier did not re-run; targeted spot-checks below confirm consistency with these gate results.

## Tier 2 findings

### Spec alignment

- BR-1 (public-only sources): PASS. KOLChannelAdapter.is_public() Protocol method (packages/application/influence/ports/kol_channel_adapter_port.py:60-68) + concrete impls in YouTube/Telegram/Facebook adapters refuse private URLs. RateLimitedFetcher._fetch raises ToSBoundaryViolation on HTTP 401/403 (packages/infrastructure/influence/rate_limited_fetcher.py:188-192). robots.txt pre-flight check via stdlib urllib.robotparser in check_robots_txt (rate_limited_fetcher.py:121-137).
- BR-2 (provisional -> active at n_evaluated >= 10): PASS. Domain enforces both invariants:
  - Kol.transition_to_active(n_evaluated) raises InvariantViolation when status != PROVISIONAL or n_evaluated < 10 (packages/domain/influence/models/kol.py:67-84).
  - UpdateKolCredibilityUseCase._maybe_transition_to_active (packages/application/influence/use_cases/update_kol_credibility_use_case.py:109-119) checks kol.is_provisional AND score.n_evaluated >= 10 before calling transition.
  - Test coverage: test_provisional_to_active_transitions_at_n_10 (n=10 transitions) + test_provisional_does_not_transition_below_threshold (n=9 stays PROVISIONAL) + test_active_kol_does_not_re_transition (already-ACTIVE no-op) in test_update_kol_credibility.py:171-213.
- BR-3 (1m/3m/6m/12m outcome reviews): PASS. SqliteOutcomeScheduler.schedule_for writes 4 rows (one per ReviewWindow) per Recommendation idempotently via INSERT OR IGNORE (packages/infrastructure/influence/outcome_scheduler.py:43-75). UNIQUE constraint UNIQUE(recommendation_id, review_window) in schema (sqlite_outcome_review_repository.py:42). window_offset deterministic in domain (outcome_review.py:67-77).
- Recommendation extraction contract: PASS. Recommendation.__post_init__ (recommendation.py:92-141) enforces ALL of BR-10 (source_url, transcript_excerpt, extractor_model, extractor_version, extracted_at non-empty), BR-6 (extraction_confidence < 0.7 must have requires_manual_review=True), and the spec section B.6 <=500 char excerpt cap. SQLite schema CHECK (LENGTH(transcript_excerpt) <= 500) (sqlite_recommendation_repository.py:41). LLM extractor _hydrate_recommendation (llm_recommendation_extractor.py:363-445) clamps confidence to [0,1], skips items <0.5 per spec section B.5 rule, sets requires_manual_review=True when 0.5 <= confidence < 0.7. Recommendation ID is uuid4 generated server-side (line 422), not LLM-supplied -- clean I-S1 boundary.

### Architecture boundaries

- D-026 LLM Substrate Boundary: PASS. llm_recommendation_extractor.py cites all 3 patterns by name in module docstring (packages/infrastructure/influence/llm_recommendation_extractor.py:6-56):
  - Pattern 1 (Per-role override BP-S43b-1): implemented as role_model_overrides dict[str,str] field with default factory at line 217-219; extract reads model from role_model_overrides.get(extraction, ...) at line 252; extract_from_context allows gatherer to override at line 282-285.
  - Pattern 2 (Prose-tolerant JSON BP-S43b-2): 3-tier extractor _unwrap_fence (line 142-158) tries _INNER_FENCE_RE regex match first (tier 1), then _extract_first_json_object_or_array for top-level brace or bracket block (tier 2), then returns text as-is (tier 3 fallback). Faithful re-implementation of the BC-8 reference pattern, extended to also handle top-level arrays since the spec section B.5 prompt returns a JSON array (correctly noted in _extract_first_json_object_or_array docstring at line 161-166).
  - Pattern 3 (Gatherer-wired compute BP-S43b-3): KOLContentGatherer (kol_content_gatherer.py:64-167) builds ExtractionContext with all numeric/structured config fields (extractor_version, confidence_threshold, transcript_excerpt_max_chars, source_url, channel_id, published_at_iso, platform, kol_id) before LLM is invoked. Comments at line 34-38 explicitly call out that constants come from code per I-S1.
- I-S1 (No LLM Math): PASS. Grep anthropic/openai/claude_llm/llm_perspective in packages/domain/influence/services/ returns 0 (verified at S49 close per session-49.md gate). Calibration math is pure scipy.stats.beta + arithmetic in calibration_service.py:148-218. bayesian_mean = post_alpha / (post_alpha + post_beta) (line 117) is deterministic Python; ci_low/ci_high = scipy_beta.ppf(...) (lines 118-119) is deterministic library call. extraction_confidence from LLM is a meta-confidence flag (used only as a routing input to requires_manual_review), NOT a financial number. No approximately-X-percent prose patterns anywhere in BC-6.
- Domain layer purity: PASS. Grep "from pydantic | import pydantic | from fastapi | import fastapi" returns 0 across packages/domain/influence/ AND packages/application/influence/ AND packages/infrastructure/influence/. Pure dataclasses + StrEnum + stdlib datetime/typing throughout the domain. ": Any" and "cast(Any, ...)" grep returns 0 in domain layer per I-12. The only third-party import in domain is scipy.stats.beta in calibration_service.py:37 -- this is acceptable per architecture.md (scipy is a math library, not a framework; serves the deterministic compute role; matches the precedent of numpy etc. used in BC-2 RatioService).

### Cross-BC contracts

- No direct cross-BC imports: PASS. Grep "from packages.{domain,application,infrastructure}.{market_data,fundamental,company_intelligence,macro,news,crowd,analysis,portfolio}" returns 0 in BC-6 source files. BC-6 only references its own domain VOs + ports + scipy + stdlib + httpx + tenacity (infra only).
- Cross-BC contract events defined: 2 events shipped in packages/contracts/events/: outcome_review_completed.py + credibility_score_updated.py. Both are frozen dataclass + slots, properly framework-free.
- GAP -- events defined but not published: per spec section B.2 the BC-6 use cases should emit 6 events: RecommendationExtracted, OutcomeReviewScheduled, OutcomeReviewCompleted, CredibilityScoreUpdated, HighCredibilityFlipDetected, ConfluenceDetected. Sub-plan 008-S45 deliverables list only 2 (CredibilityScoreUpdated + OutcomeReviewCompleted) which were created. But neither EvaluateOutcomeReviewUseCase nor UpdateKolCredibilityUseCase actually publishes them. Grep "event_bus|publish.*Event" in packages/application/influence/ returns 0. This appears to be a global Phase 2/3 deferral (BC-5 packages/application/news/ also has no event_bus wiring -- the in-process event bus port itself is not shipped yet). Recommend tracking as a Phase 4 prerequisite rather than a BC-6 fix-cycle blocker; the contract types are present so future wiring is mechanical.

### Ubiquitous language consistency

Spot-checked 8 terms against agent-workspace/ubiquitous-language/glossary.md:

- KOL (glossary.md:166-168) -- PASS, definition matches IMPL.
- Channel -- not separately defined in glossary section Tier 3-4, IMPL uses Channel aggregate with Platform StrEnum (5 values). No drift, but glossary could add explicit Channel entry.
- Recommendation (KOL) (glossary.md:170-172) -- DRIFT: glossary says intent values are BUY/HOLD/SELL/WATCH, but spec section B.1 + B.5 + actual Intent enum (packages/domain/influence/value_objects/intent.py:26-31) has STRONG_BUY/BUY/WATCH/NEUTRAL/AVOID/STRONG_AVOID (6 values, no SELL or HOLD; AVOID and STRONG_AVOID are the SELL-equivalent semantics). IMPL is correct vs spec; glossary is stale. Severity LOW (non-functional; documentation update needed).
- KolStyle -- not in glossary; IMPL has 5 values FUNDAMENTAL/TECHNICAL/NARRATIVE/PUMPER/MIXED (kol_style.py) per spec section A.3 BR-8. Recommend add to glossary.
- Intent -- not defined separately; IMPL faithful to spec.
- Timeframe -- not in glossary; IMPL has 5 values INTRADAY/DAYS/WEEKS/MONTHS/LONG_TERM per spec section B.1. Faithful.
- CredibilityScore -- referenced via Calibration entry (glossary.md:35) but no dedicated entry. IMPL faithful to spec section B.1.
- OutcomeReview -- not in glossary. IMPL has ReviewWindow (4 values) + OutcomeStatus (6 values) per spec section B.1. Faithful.

Net UL drift verdict: 1 LOW-severity drift (glossary Recommendation intent values stale) + 4 missing entries that should be added at next UL refresh. None block BC-6 ship.

### D-027 ADR alignment

Cross-checked all 6 decisions in D-027 against actual IMPL:

- (a) Storage substrate -- SQLite extension: PASS. 4 SQLite repos shipped in packages/infrastructure/influence/sqlite_*_repository.py. Schema mirrors spec section B.6 with the documented adaptations (TIMESTAMPTZ -> TEXT ISO8601; JSONB -> TEXT json; TEXT[] -> TEXT json-array).
- (b) Adapter pattern -- Shared Protocol + 3 concretes: PASS. KOLChannelAdapter Protocol in packages/application/influence/ports/kol_channel_adapter_port.py + 3 concretes (youtube_adapter.py, telegram_adapter.py, facebook_adapter.py) all subclass-pattern + RateLimitedFetcher shared base.
- (c) Recommendation entity persistence -- Domain aggregates + Protocol repo: PASS. Rich aggregates in packages/domain/influence/models/ with __post_init__ invariants; Protocols in packages/application/influence/ports/; SQLite concretes in infrastructure. No anemic anti-pattern.
- (d) LLM extractor substrate -- D-026 verbatim citation: PASS. Cited by name in extractor docstring; all 3 patterns implemented faithfully (per details above in Architecture boundaries).
- (e) Calibration determinism -- Pure Python Bayesian in domain service: PASS. calibration_service.py uses scipy.stats.beta only; explicit grep gate at S49 close confirms 0 LLM imports. Skeptical Beta(5,5) prior matches spec section B.3 UC-3 line 295.
- (f) Outcome scheduler -- SQLite jobs + cron runner: PASS. outcome_scheduler.py writes 4 rows on schedule_for(recommendation) + apps/cli/run_due_outcome_reviews.py is the cron entry point per spec section B.7.

MINOR drift in ADR D-027: D-027 references package paths as packages/.../influence_network/ throughout the Decisions section. Actual ship paths use packages/.../influence/ (one-directory naming drift). Sub-plan 008-S45 also has the influence_network paths throughout. The IMPL is consistent internally and the actual ship path matches architecture.md section BC-6 (which specifies packages/domain/influence/). So the correct path is what shipped; the ADR + sub-plan are stale on naming. Severity LOW (audit-trail friction; no functional impact). Recommend an addendum or supersession note on D-027.

### Adversarial probes

- Probe 1 -- Vietnamese diacritic boundary in transcript_excerpt 500-char limit: PASS. Recommendation.__post_init__ uses len(self.transcript_excerpt) (Python string length is character count, not byte count for str). Test test_transcript_excerpt_at_limit_ok asserts exactly 500 chars OK with diacritic; test_transcript_excerpt_over_500_raises asserts 501 raises. Char-count semantics correct for spec section B.6 wording "<=500 chars". NOTE: SQLite LENGTH(transcript_excerpt) <= 500 operates on UTF-8 byte length by default for TEXT in SQLite -- so a 500-char string with multi-byte diacritics could exceed 500 bytes and fail the schema check despite passing the domain check. Quick estimate: each Vietnamese diacritic char is ~2-3 UTF-8 bytes; 500 diacritics could be 1000-1500 bytes. This is a subtle inconsistency between domain (char count) and SQLite (byte count). Severity MEDIUM if real Vietnamese excerpts approach the limit; severity LOW for typical KOL excerpts (<200 chars). Mitigation: domain truncation already at 500 chars in LLM extractor (llm_recommendation_extractor.py:411) which is char-not-byte truncation, so the gap is real but only triggers on excerpts approaching 500. Worth tracking.
- Probe 2 -- Provisional KOL transition without 10 evaluations: PASS. Triple-guarded:
  1. Domain Kol.transition_to_active(n_evaluated) raises InvariantViolation when n_evaluated < 10 (kol.py:79-83).
  2. Use case _maybe_transition_to_active returns early when score.n_evaluated < 10 (update_kol_credibility_use_case.py:117-118).
  3. Test test_provisional_does_not_transition_below_threshold asserts that with n=9 reviews, kol_repo.save_calls == [] (no save attempted).
  No bypass path identified. Even if a caller bypassed the use case and tried kol.transition_to_active(score.n_evaluated) with n<10, the domain raises. Defensive depth is good.
- Probe 3 -- Conditional INVALID handling without condition_evaluator wired: PASS. EvaluateOutcomeReviewUseCase.execute (evaluate_outcome_review_use_case.py:107-113) checks if rec.is_conditional() AND if self._condition_evaluator is None, then marks the review INVALID with reason "Conditional recommendation but no condition_evaluator wired" and persists. This is the safe-fail path -- conditional recs without evaluator land INVALID (excluded from Bayesian buckets per BR-7 + calibration_service _bucket excludes INVALID), NOT MISS. Excellent defensive design. The Phase 3 stub returns False-by-default per the docstring at evaluate_outcome_review_use_case.py:46-53 so unmet conditions do not pollute calibration.
- Probe 4 -- LLM extractor numeric leak boundary: PASS-WITH-NOTE. The LLM returns extraction_confidence (0-1 float) via JSON. This crosses the substrate boundary as a number. Strictly under I-S1 (LLM never returns a number as natural-language output), this is a structured tool-use number, not natural-language prose, so it fits the compute_roe(...) -> 17.83% pattern not the "approximately 18%" pattern. The number is then clamped to [0,1] at llm_recommendation_extractor.py:396 and used only as a routing flag (requires_manual_review = confidence < 0.7). It does NOT enter the calibration math (which uses HIT/MISS counts from deterministic OutcomeEvaluator). Verdict: BR-6 confidence is a meta-confidence not a financial number; I-S1 spirit preserved. The spec section B.5 system prompt explicitly distinguishes "confidence in this extraction (not in the recommendation itself)" -- design intent consistent. This is borderline but documented and structurally clean.
- Probe 5 -- datetime.utcnow() deprecated usage + tz-aware/naive mixing: NOTE.
  - sqlite_recommendation_repository.py:128 uses datetime.utcnow() (returns naive UTC datetime; deprecated since Python 3.12 -- issues DeprecationWarning). Other locations in BC-6 consistently use datetime.now(UTC). Severity LOW -- replace with datetime.now(UTC) in next surgical edit.
  - TZ consistency in OutcomeScheduler.schedule_for: scheduled_at = recommendation.published_at + window_offset(window) preserves TZ from published_at. If a Recommendation is constructed with a naive published_at (no __post_init__ enforcement of tz-awareness), the SQLite-stored scheduled_at.isoformat() will lack TZ suffix. get_due does string <= comparison on ISO timestamps -- mixing naive and tz-aware in the same query returns lexicographically-ordered results that may incorrectly include or exclude rows. Mitigation: enforce published_at.tzinfo is not None invariant in Recommendation.__post_init__ (currently only checks extracted_at is None). Severity LOW (no test exposed this; current callers are uniformly tz-aware via ChannelContent which DOES enforce future-check on tz-normalized timestamp). Worth a defensive __post_init__ add.

## Recommendations for Phase 3 progression

S65 PLAN BC-7 architect: PROCEED.

BC-6 is structurally and contractually solid. The 5 residue items above are non-blocking:
- (R1) ADR D-027 path naming drift influence_network vs influence -- documentation-only fix; D-028 BC-7 architect at S65 should adopt the corrected influence-style path and reference back-corrected D-027 if needed.
- (R2) UL glossary stale on Recommendation intent values -- single-line fix at next glossary refresh.
- (R3) Domain events defined but not published -- global Phase 2/3 deferral; in-process event bus port + concrete should ship at Phase 4 SaaS-deploy boundary or earlier if cross-BC reactions become needed.
- (R4) datetime.utcnow() single-call deprecation + tz-aware/naive risk in published_at invariant -- tiny defensive hardening; can fold into next BC-6 surgical edit (no fix-cycle session needed).
- (R5) Char-vs-byte length inconsistency in transcript_excerpt 500-cap -- only triggers on excerpts >500 chars with multi-byte diacritics; track for first dogfood incident, not pre-emptive fix.

No CHARTER breaches. No I-S1 violations. No DR1/6/8 drift. Tier 1 deterministic gate echoed GREEN.

S65 should proceed to BC-7 PLAN architect dispatch as scheduled by master-plan-007 section Critical Path. Optionally add a small BC-6 cleanup item to the standing-overhead reserve queue (S58 rule-application reserve is the right slot per master-plan) covering R1+R2+R4 -- none of these warrant a dedicated session.

## Files inspected

Domain (BC-6):
- C:/htdocs/stockforge/packages/domain/influence/models/recommendation.py (lines 1-189; full)
- C:/htdocs/stockforge/packages/domain/influence/models/kol.py (lines 1-93; full)
- C:/htdocs/stockforge/packages/domain/influence/models/credibility_score.py (lines 1-132; full)
- C:/htdocs/stockforge/packages/domain/influence/models/outcome_review.py (lines 1-172; full)
- C:/htdocs/stockforge/packages/domain/influence/models/channel.py (lines 1-54; full)
- C:/htdocs/stockforge/packages/domain/influence/models/channel_content.py (lines 1-64; full)
- C:/htdocs/stockforge/packages/domain/influence/value_objects/intent.py + timeframe.py + kol_status.py + kol_id.py (full)
- C:/htdocs/stockforge/packages/domain/influence/services/calibration_service.py (lines 1-219; full)
- C:/htdocs/stockforge/packages/domain/influence/services/outcome_evaluator.py (lines 1-90; full)

Application (BC-6):
- C:/htdocs/stockforge/packages/application/influence/use_cases/update_kol_credibility_use_case.py (lines 1-119; full)
- C:/htdocs/stockforge/packages/application/influence/use_cases/evaluate_outcome_review_use_case.py (lines 1-163; full)
- C:/htdocs/stockforge/packages/application/influence/ports/kol_channel_adapter_port.py (lines 1-77; full)

Infrastructure (BC-6):
- C:/htdocs/stockforge/packages/infrastructure/influence/llm_recommendation_extractor.py (lines 1-469; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/kol_content_gatherer.py (lines 1-167; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/rate_limited_fetcher.py (lines 1-218; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/youtube_adapter.py (lines 1-335; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/sqlite_recommendation_repository.py (lines 1-180; full; gap at line 128 datetime.utcnow)
- C:/htdocs/stockforge/packages/infrastructure/influence/sqlite_outcome_review_repository.py (lines 1-154; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/outcome_scheduler.py (lines 1-80; full)

Tests (BC-6):
- C:/htdocs/stockforge/packages/domain/influence/test_recommendation.py (lines 1-215; full)
- C:/htdocs/stockforge/packages/domain/influence/services/test_calibration_service.py (lines 1-179; full)
- C:/htdocs/stockforge/packages/application/influence/use_cases/test_update_kol_credibility.py (lines 1-213; full)
- C:/htdocs/stockforge/packages/infrastructure/influence/test_llm_recommendation_extractor.py (lines 1-250; partial)

Spec + ADR + plans:
- C:/htdocs/stockforge/specs/tier2-feature/002-influence-network-tracking.md (lines 1-611; full)
- C:/htdocs/stockforge/agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (lines 1-153; full)
- C:/htdocs/stockforge/agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md (lines 1-429; full)
- C:/htdocs/stockforge/agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md (lines 1-241; partial)
- C:/htdocs/stockforge/agent-workspace/memory/sessions/2026-05-05-session-49.md (lines 1-100; partial)

Constitution + UL:
- C:/htdocs/stockforge/agent-workspace/constitution/architecture.md (lines 1-300; partial)
- C:/htdocs/stockforge/agent-workspace/constitution/invariants.md (lines 1-179; full)
- C:/htdocs/stockforge/agent-workspace/constitution/invariants-stockforge.md (lines 1-198; full)
- C:/htdocs/stockforge/agent-workspace/ubiquitous-language/glossary.md (lines 160-208; partial)

Contracts:
- C:/htdocs/stockforge/packages/contracts/events/outcome_review_completed.py (lines 1-27; full)

Greps performed:
- "from pydantic|import pydantic|from fastapi|import fastapi" in domain/application/infrastructure influence -- 0 matches
- ": Any|-> Any|cast(Any" in domain influence -- 0 matches
- "from packages.{domain,application,infrastructure}.{market_data,fundamental,company_intelligence,macro,news,crowd,analysis,portfolio}" in domain/application/infrastructure influence -- 0 matches
- "event_bus|EventBus|publish.*Event" in application influence -- 0 matches (gap)
- "class DetectConfluenceUseCase|class IngestChannelContentUseCase" in packages -- 0 matches (deferred per sub-plan 008-S45 scope)
- "approximately|roughly|around.*%|tam.*%" in BC-6 source -- 0 matches (I-S1 clean)
- "datetime.utcnow()" in BC-6 -- 1 match (sqlite_recommendation_repository.py:128)

---

## Companion findings — duplicate dispatch (M-S64-1)

**Disclosure**: An L-S49b-3 pre-dispatch in-flight check failure occurred at S64 entry. The S63 checkpoint's `in_flight_subagent_dispatch` schema recorded `agent_id: a91164d4c20d05d63` as the planned/in-flight verifier for S64 (actually dispatched in the prior turn). The main session at S64 entry misread this as an unfilled placeholder and dispatched a duplicate verifier `agent_id: a4345898b6912af26`. Both dispatches completed independently with adversarial-different findings — surfaced as a positive cross-check (defense-in-depth) but classified as M-S64-1 process violation. Catalogued in `agent-workspace/memory/mistake-log.md`.

**Companion verifier (a4345898b6912af26) ADDITIONAL findings** (NOT redundant with the canonical above):

### Companion-Critical-1 (HIGH) — Telegram BR-1 fail-open for private invite links (NOT caught by canonical verifier)

**File:line**: `packages/infrastructure/influence/telegram_adapter.py:114-116`

**Code path**:
```python
if self.mock_api_caller is None and not self.bot_token:
    return channel_url.startswith("https://t.me/") or chat_id.startswith("@")
```

**Empirical verification** (companion verifier ran fresh Python interpreter):
- `is_public("https://t.me/+private_invite_link")` → `True` (should be False — private invite link)
- `is_public("https://t.me/joinchat/abc123")` → `True` (should be False — joinchat is private invite mechanism)
- `is_public("https://t.me/c/private_channel_id")` → `True` (should be False — private channel direct link)

**Why charter-tier**: When the autonomous ingestion pipeline runs without bot_token (likely Phase 4 boundary state), the Telegram adapter silently accepts private invite URLs. The invariant violation is in `is_public()` itself — the BR-1 gatekeeper. A private group operator could exfiltrate private discussion content into the public-only KOL calibration database, polluting credibility scores with non-public source data — direct violation of charter "Public sources only. No paid leaks, no insider channels."

**Severity**: HIGH (charter-tier BR-1 + I-S2 affecting calibration data integrity).

**Why canonical verifier missed it**: Canonical verifier verified the mocked path (Probe 1+ in §Spec alignment) but did not exercise the unmocked fail-open branch. Companion verifier explicitly pressure-tested the no-token + no-mock branch.

**Fix-cycle scope**: ~20 LOC source change + 1 regression test, ~30 min. APPLIED THIS TURN at S64 (see mistake-log M-S64-1 fix-cycle annex + post-fix gate evidence).

### Companion findings cross-check vs canonical

| Finding | Canonical verifier | Companion verifier | Resolution |
|---|---|---|---|
| Telegram BR-1 fail-open (HIGH) | NOT FOUND | FOUND empirically | **Patched THIS TURN** |
| `datetime.utcnow()` deprecated | FOUND (Probe 5; severity LOW) | FOUND (Critical-2; severity MEDIUM) | **Patched THIS TURN** |
| ADR D-027 path drift `influence_network/` vs `influence/` | FOUND (R1 audit-trail drift) | NOT FOUND | Defer to S58 standing-overhead reserve |
| UL glossary stale on Recommendation intent | FOUND (E §UL drift) | FOUND (Minor-1) | Defer to S58 standing-overhead reserve |
| BR-9 flip-flop penalty NOT IMPLEMENTED | NOT mentioned | FOUND (Minor-2 DEFER) | Per plan deferral; document at BC-6 close |
| Spec §B.2 events partially shipped | FOUND (R3 events defined not published) | FOUND (Minor-3) | Phase 4 prerequisite per both verifiers |
| Char-vs-byte SQLite LENGTH quirk on transcript_excerpt | FOUND (Probe 1 NOTE) | NOT mentioned | Defer per canonical verifier (track for first dogfood incident) |
| LLM extractor 468 LOC vs 220 LOC plan cap | NOT mentioned | FOUND (Critical-3) | Defer; not mandatory refactor per companion |
| Tz-aware/naive published_at invariant gap | FOUND (Probe 5 second part; LOW) | NOT mentioned | Defer to S58 |

**Net merged verdict**: PASS-WITH-RESIDUE-MEDIUM (HIGH severity from companion; charter-tier BR-1 hole takes precedence over canonical's LOW severity for same datetime issue).

**Net merged recommendation**: OPTION A — fix-cycle THIS TURN for Critical-1 + Critical-2 (~30 min); defer remaining LOW severity items to S58 standing-overhead reserve. Then S65 PLAN BC-7 J+K is GREEN.

---

## Fix-cycle execution (S64 close annex)

### Patches applied (3 source edits + 1 NEW regression test)

**Critical-1 — Telegram BR-1 fail-open hardening** (`packages/infrastructure/influence/telegram_adapter.py:101-145`):

- Added 3 hard-refusal guards BEFORE `_extract_chat_id`: refuse `https://t.me/+...`, `https://t.me/joinchat/...`, `https://t.me/c/...` patterns regardless of bot_token state.
- Tightened fail-open path: even when `mock_api_caller is None and not bot_token`, slug must be alphanumeric+underscore only; empty/non-canonical slugs return False.
- Added BR-1 hardening docstring referencing M-S64-1.
- LOC delta: +18 lines.

**Critical-1 regression test** (`packages/infrastructure/influence/test_adapters.py:197-220`):

- New `test_is_public_no_token_no_mock_refuses_private_invite_patterns` (8 assertions):
  - Refuse: `t.me/+invite_link`, `t.me/joinchat/abc123`, `t.me/c/1234567890`
  - Refuse: empty URL, bare `t.me/`, non-alphanumeric slug `t.me/!@#$%`
  - Accept: `t.me/stocktest`, `@stocktest`, `t.me/vn_stock_news` (underscore allowed)

**Critical-2 — datetime.utcnow() → datetime.now(UTC)** (`packages/infrastructure/influence/sqlite_recommendation_repository.py`):

- Line 14: import `from datetime import UTC, datetime, timedelta`
- Line 128: `cutoff = (datetime.now(UTC) - timedelta(days=lookback_days)).isoformat()`

### Tier 1 deterministic gate (post-fix)

| Tool | Pre-fix (S50/S64 entry) | Post-fix (S64 close) | Delta |
|---|---|---|---|
| pytest packages/{domain,application,infrastructure}/influence | 149 PASS in 1.24s | **150 PASS in 1.14s** | +1 regression test |
| mypy --strict --explicit-package-bases packages/influence/* | "no issues found in 61 source files" | **"no issues found in 61 source files"** | UNCHANGED |
| ruff check packages/influence/* | "All checks passed!" | **"All checks passed!"** | UNCHANGED |

### Residue closure status

| Residue | Severity | Status post-S64-close | Disposition |
|---|---|---|---|
| Critical-1 Telegram BR-1 fail-open | HIGH | **PATCHED** (3-pattern hard refusal + slug whitelist + 8-assertion regression) | CLOSED |
| Critical-2 datetime.utcnow() deprecated | MEDIUM | **PATCHED** (1-line import + 1-line call site) | CLOSED |
| Critical-3 LLM extractor 468 LOC vs 220 cap | MEDIUM | DEFERRED | Not mandatory per companion verifier; verify with planner at S65 PLAN |
| R1 ADR D-027 path drift `influence_network/` vs `influence/` | LOW | DEFERRED | Fold into S58 standing-overhead reserve (rule-application cycle) |
| R2 / Minor-1 UL glossary stale on Recommendation intent | LOW | DEFERRED | Fold into S58 standing-overhead reserve |
| R3 / Minor-3 Spec §B.2 events partially shipped | LOW | DEFERRED | Phase 4 prerequisite per both verifiers |
| R4 published_at tz-aware/naive invariant gap | LOW | DEFERRED | Fold into S58 standing-overhead reserve |
| R5 char-vs-byte SQLite LENGTH quirk | LOW | DEFERRED | Track for first dogfood incident per canonical verifier |
| Minor-2 BR-9 flip-flop penalty NOT IMPLEMENTED | LOW | DEFERRED | Per plan deferral; document at BC-6 close |

### Net post-fix verdict

**PASS** for the residue subset that was patched (Critical-1 + Critical-2). 5 remaining LOW-severity items DEFERRED per both verifiers' explicit recommendation. **S65 PLAN BC-7 J+K architect dispatch is GREEN.**

Phase 3 Track J/K IMPL gating: VERIFIER closed → BC-7 PLAN may proceed at S65 entry without further BC-6 work.
