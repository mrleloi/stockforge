---
id: D-032
title: BC-7 Crowd Sentiment + Pump Detection architecture (Tracks J+K)
status: ACCEPTED
tier: ARCH
date_proposed: 2026-05-06
date_ratified: 2026-05-06
ratifying_session: S65
authoring_agent: Claude Opus 4.7 (sandwich-architect dispatch; lean ≤6 pre-reads per L-S43f-2; mirror D-027 schema verbatim; renumbered 028→032 at S65 close per M-S65-1 collision-fix — original S48d D-028 ratified CLAUDE-md-session-end-ritual-extension; master-plan §S51 reference stale per L-S65-1 candidate)
supersedes: none
superseded_by: none
source_evidence:
  - specs/tier2-feature/003-crowd-sentiment-pump-detection.md (binding spec; § A.3 BR-1..BR-10 + § B.1 entities + § B.3 UC-1..UC-4 + § B.4 adapters + § B.5 schema + § B.7 calibration + § B.8 quality gates)
  - agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027; mirror schema + § (a)..(f) pattern verbatim)
  - agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md (D-026; LLM Substrate Boundary patterns binding for Track K)
  - agent-workspace/constitution/architecture.md § BC-7 + § "LLM Substrate Boundary" + § Layer Hierarchy + § Cross-BC Rules + § Forbidden Patterns
  - agent-workspace/constitution/invariants.md § I-S1 (NO LLM math) + § I-S2 (provenance + as-of) + § I-S35 (research-aid framing)
  - agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md § Track Catalog J/K + § Session Breakdown S51-S53 + § Risk Register R-P3-2/R-P3-4/R-P3-6
  - agent-workspace/memory/agent-notes.md § L-S17-1 (SQLite portability binds Phase 1+2+3; migration at Phase 4 SaaS-deploy)
options_considered:
  - decision_a_storage:
      A1_sqlite_extension: chosen — match BC-6 D-027(a) + Phase 1+2 substrate per L-S17-1 portability; TimescaleDB-style hypertable behavior emulated via (ticker, captured_at) composite index for Phase 3
      A2_postgres_now_with_timescale: rejected — premature; spec § B.5 declares Postgres+TimescaleDB target but Phase 3 substrate continuity dominates; migration boundary = Phase 4 SaaS-deploy
      A3_hybrid_sqlite_aggregates_postgres_snapshots: rejected — substrate split adds drift surface without Phase 3 benefit; mirror D-027 A3 rejection rationale
  - decision_b_adapter_pattern:
      B1_shared_protocol_three_concretes: chosen — PostAggregator Protocol + 3 concrete classes (F319 + FacebookPublicGroup + ArticleComments-CafeF/Vietstock); shared RateLimitedFetcher base mirroring D-027(b); Liskov-clean swapping for tests
      B2_three_unrelated_concrete_classes: rejected — duplicates rate-limit + ToS pre-flight + retry logic across 3 platforms
      B3_single_god_aggregator_with_platform_dispatch: rejected — anti-pattern god service per architecture.md § Forbidden Patterns
  - decision_c_domain_persistence:
      C1_domain_layer_aggregate_repository_protocol: chosen — SentimentSnapshot + Narrative + PhaseTransition + PumpDetection + CounterNarrative + LabeledPump aggregates in packages/domain/crowd/; frozen dataclasses + __post_init__ invariants per spec § B.1; Protocol repos in application/crowd/ports/; concrete in infrastructure/crowd/
      C2_service_layer_only_anemic: rejected — anemic-domain anti-pattern violates architecture.md § Domain Model Rules; spec 003 § B.1 explicitly defines rich entities with bullish_ratio() + dominant_sentiment() + days_in_current_phase() behaviors
  - decision_d_llm_substrate_boundary:
      D1_cite_d026_substrate_boundary_verbatim: chosen — per-role override + prose-tolerant JSON + gatherer-wired compute mandatory per D-026 ratified; LLM ONLY for (1) categorical sentiment classification per BR-4 enum 5-level (2) counter-narrative bear-point text per UC-4 (3) pump evidence summary text per UC-3; LLM NEVER outputs numeric per I-S1
      D2_freeform_llm_no_substrate_pattern: rejected — D-026 binding for ALL Phase 3 LLM-perspective adapters; would violate ratified constitution
      D3_llm_outputs_numeric_sentiment_score: rejected — violates I-S1 NO-LLM-math hard rule + BR-4 explicit categorical-only mandate
  - decision_e_narrative_phase_classifier:
      E1_deterministic_rule_based_seven_state: chosen — 7-phase machine (INCUBATION → EMERGING → MAINSTREAM → SATURATION → EXHAUSTION → REVERSAL → DEAD) per spec § B.3 lines 301-333; thresholds tunable via config; pure-Python no LLM; reproducible classifications per § B.8 bootstrap test
      E2_llm_classifies_phase_directly: rejected — not reproducible, not calibratable, violates I-S1 (phase = ordinal but classifier output drives event publication = numeric semantic in finance grade); spec § C.1 explicitly rejects this alternative
      E3_ml_model_trained_on_labeled_phases: rejected — labeled dataset insufficient Phase 3 (5 narratives target per § B.7); deferred to Year 2 outer-loop activation per spec 005
  - decision_f_pump_phase_classifier:
      F1_deterministic_multi_signal_weighted_scoring: chosen — 5-state (PRE_PUMP/PUMP/DISTRIBUTION/DUMP/UNCERTAIN) per spec § B.3 lines 379-423; weighted scoring across signals; confidence gate ≥0.4 or returns UNCERTAIN; weights tunable per Karpathy outer loop (Year 2 activation per spec 005)
      F2_llm_declares_phase_with_confidence: rejected — same rationale as E2; spec § C.1 explicitly rejects "Let LLM declare pump phase directly"
      F3_no_confidence_gate_emit_all_classifications: rejected — would violate § B.10 R6 "Alerts too noisy, user ignores" mitigation requiring strict thresholds + historical precision requirement
  - decision_g_counter_narrative_generator:
      G1_llm_bear_points_grounded_in_three_sources: chosen — UC-4 verbatim per spec § B.3; LLM bear points grounded in (1) HistoricalAnalogFinder failing analogs (subsequent_return_12m < -0.10) (2) bullish_consensus_summary (3) sector_structural_risks; MANDATORY per BR-6 when sentiment >80% bullish on considered ticker (gates positive signal issuance per I-S13)
      G2_template_based_no_llm: rejected — spec § C.1 rejects this; counter-narrative quality requires Vietnamese-language LLM synthesis; templated bear-points stale + low-quality
      G3_llm_freeform_no_grounding: rejected — violates BR-6 + I-S2 provenance + spec § B.10 R3 "Vietnamese sentiment accuracy <target" mitigation requiring grounded inputs
  - decision_h_coordination_detection:
      H1_feature_extractor_three_signals_high_threshold: chosen — TEMPLATE_SIMILARITY (embedding-based cosine ≥0.9 within 1h window) + TIMING_CLUSTER (>5 accounts within 3-min window repeatedly) + ACCOUNT_AGE_DISTRIBUTION (>50% bullish posters <30-day-old); coordination_score in [0,1]; conservative threshold ≥0.8 per BR-8; **flagged ≠ confirmed** per BR-10 NEVER names operators; framed as "pattern detected, exercise caution"
      H2_llm_judges_coordination: rejected — violates I-S1 (coordination_score is numeric output) + BR-8 reproducibility requirement
      H3_two_signal_no_account_age: rejected — spec § B.4 explicitly requires 3-feature ensemble; account-age is highest-signal feature for VN F319+FB sock-puppet patterns
  - decision_i_backtest_validation_gate:
      I1_precision_recall_holdout_pre_deploy: chosen — precision >0.5 + recall >0.3 on hold-out per BR-5 BEFORE pump classifier deploys live; deferred outcome calibration via labeled_pumps table per spec § B.5; human-review-first for Phase 1 detections per § B.8 (every pump detection in Phase 1 reviewed by user before alert fires)
      I2_no_validation_gate_ship_then_calibrate: rejected — violates BR-5 explicit mandate + § B.10 R6 "Alerts too noisy" mitigation; ship-then-calibrate pattern violates calibration-over-confidence Charter Principle
      I3_higher_threshold_precision_0_8: rejected — 0.8 precision target unachievable Phase 3 with 5-20 labeled pumps; defer threshold-tightening to Year 2 outer-loop activation per spec 005
chosen_options: A1 + B1 + C1 + D1 + E1 + F1 + G1 + H1 + I1
---

# D-032 — BC-7 Crowd Sentiment + Pump Detection Architecture

> Ratifying ADR for BC-7 (Crowd Sentiment + Pump Detection) bounded-context architecture
> covering Phase 3 Tracks J (3-source crowd ingestion + coordination feature extractor)
> + K (narrative phase classifier + pump phase classifier + counter-narrative generator).
> Sub-plan binding: `009-S51-track-J-K-impl-sub-plan.md`.

## Context

Phase 3 master-plan (007-S44) confirmed BC-7 full-scope ship via Q-P3-3 = ADD invariant
(outer-loop activation gate) at S43f. Spec 003 (Tier 2) defines the entity model + use
cases + business rules. D-026 ratified the LLM Substrate Boundary patterns at S43f+S43e
mandating Track K cite the 3 patterns verbatim. D-027 (S45) committed parallel architecture
decisions for BC-6 — this BC-7 ADR mirrors D-027's structure verbatim where applicable
and extends it for the 3 BC-7-specific decision domains (E narrative classifier, G counter-
narrative, H coordination detection, I backtest gate). This ADR commits the architectural
decisions for S52+S53 IMPL sessions.

BC-7 is Tier 4 of the four-tier signal architecture and the most VN-specific edge — no
commercial product (FiinPro / Wichart / Stockbiz) tracks crowd behavior at this depth.
Implementation depth carries proportional risk: BR-1 public-only enforcement, BR-10 no
public accusations, BR-5 backtest-validation gate before live deploy.

## Decisions

### (a) Storage substrate — SQLite extension

Match Phase 1+2+3 substrate (per L-S17-1 portability + D-027(a) precedent). Schema
mirrors spec 003 § B.5 verbatim adapted for SQLite (TIMESTAMPTZ → TEXT ISO8601;
JSONB → TEXT json-serialized; TEXT[] → TEXT json-array). TimescaleDB hypertable
behavior emulated via composite index `(ticker, captured_at DESC)` on
`sentiment_snapshots` table; Phase 4 migration adds `create_hypertable()` call. Tables:
`sentiment_snapshots`, `narratives`, `phase_transitions` (denormalized from
narratives.phase_history JSONB for query efficiency), `pump_detections`,
`counter_narratives`, `labeled_pumps` per spec § B.5. Migration to Postgres+TimescaleDB
deferred to Phase 4 SaaS-deploy boundary. Substrate gain: zero new infra; consistent
with BC-5 (S36) + BC-6 (S46-S49) + BC-8 (S42) precedent. Rejected A2 Postgres-now
(premature) + A3 hybrid (drift surface).

### (b) Adapter pattern — Shared Protocol + 3 concrete impls

`packages/application/crowd/ports/post_aggregator_port.py` defines `PostAggregator`
Protocol with methods `fetch_recent(ticker, since) -> list[RawPost]` +
`is_public(source_url) -> bool` + `respect_rate_limit() -> None`. Three concretes in
infrastructure: `f319_forum_aggregator.py`, `facebook_public_group_aggregator.py`,
`article_comments_aggregator.py` (CafeF + Vietstock article-comment scrapers).
Shared `RateLimitedFetcher` base class encapsulates backoff + ToS pre-flight +
user-agent rotation (mirror BC-6 D-027(b) pattern; reuse module if importable from
infrastructure/influence/, else duplicate-with-attribution per Phase 3 BC-7
needs). Per R-P3-2 HIGH severity master-plan binding: crawler-reliability skill MANDATORY
at S52 entry (mirrors S46 BC-6 entry). BR-1 public-only enforced at adapter layer:
each `is_public()` returns False for known-private fixtures; private content raises
`ToSBoundaryViolation` mirroring BC-6 telegram_adapter S64 fix-cycle hardening pattern
(verifier-confirmed pattern at S64 close).

**Telegram explicitly NOT included Phase 3 BC-7** — spec 003 § B.4 lists "TelegramPublic-
ChannelAggregator" but master-plan § Track Catalog J restricts to F319 + FacebookPublic-
Group + CafeF/Vietstock comments; Telegram crowd-sentiment deferred to Phase 4 (BC-6 S46
already ships TelegramPublicChannelAdapter for KOL signal — different use case). Document
this scoping decision as IMPL-S52-N at session entry per IMPL-S15-1 inline-document
doctrine.

Rejected B2 (duplicated boilerplate) + B3 (god-service).

### (c) Domain aggregates persistence — Domain aggregates + Protocol repos

`packages/domain/crowd/{sentiment_snapshot,narrative,phase_transition,pump_detection,counter_narrative,labeled_pump}.py`
hold rich aggregates per spec 003 § B.1 — frozen dataclasses + `__post_init__`
invariants:
- `SentimentSnapshot` requires sentiment_distribution dict non-empty + coordinated_posting_score in [0,1] + posting_velocity ≥ 0
- `Narrative` requires non-empty thematic_keywords + current_phase NarrativePhase enum + first_detected_at not future
- `PhaseTransition` requires from_phase != to_phase + transitioned_at not future
- `PumpDetection` requires phase_confidence in [0,1] + non-empty contributing_signals + recommended_action PumpAction enum
- `CounterNarrative` requires non-empty bear_points + at-least-one historical_analog
- `LabeledPump` requires period_end > period_start + non-empty phases + labeled_by in {'user', 'agent_with_review'}

Behaviors per spec § B.1: `SentimentSnapshot.dominant_sentiment()`, `bullish_ratio()`;
`Narrative.days_in_current_phase()`. Protocol repos
`packages/application/crowd/ports/{sentiment_snapshot,narrative,pump_detection,counter_narrative,labeled_pump}_repository.py`.
Concrete `packages/infrastructure/crowd/sqlite_*_repository.py`.

Value objects: `Sentiment` StrEnum (5 levels: STRONGLY_BULLISH | BULLISH | NEUTRAL |
BEARISH | STRONGLY_BEARISH per BR-4); `NarrativePhase` StrEnum (7 levels per spec
§ B.1 + DEAD); `PumpPhase` StrEnum (5 levels); `PumpAction` StrEnum (4 levels:
AVOID | EXIT_IF_HOLDING | WATCH | INFORMATIONAL); `Window` StrEnum (4 levels: ONE_HOUR |
FOUR_HOUR | ONE_DAY | ONE_WEEK with `hours` + `duration` properties).

Rejected C2 (anemic anti-pattern violates architecture.md § Domain Model Rules + spec
§ B.1 rich-entity behaviors).

### (d) LLM substrate boundary — D-026 verbatim citation

`packages/infrastructure/crowd/sentiment_classifier.py` (LlmSentimentClassifier) +
`packages/infrastructure/crowd/counter_narrative_generator.py` +
`packages/infrastructure/crowd/pump_evidence_summarizer.py` all implement their respective
ports and cite architecture.md § "LLM Substrate Boundary" verbatim:

- **Per-role override (BP-S43b-1)**: each adapter exposes `role_model_overrides` dict
  allowing Haiku-batch (sentiment classifier — 50 posts/call cost-driven) vs
  Sonnet-extract (counter-narrative — quality-driven) vs Opus-summary (pump evidence
  rare-call quality-driven) hybrid without touching call sites.
- **Prose-tolerant JSON (BP-S43b-2)**: 3-tier extractor (fenced block → first-`{`
  heuristic → best-effort recovery); reuse `subagent_transport.py:55-118` extractor
  function (Phase 2 BC-8 substrate; Phase 3 BC-6 S47 precedent).
- **Gatherer-wired compute (BP-S43b-3)**: deterministic services prepare LLM context
  — `CrowdContentGatherer` for sentiment classifier (post batching + window metadata),
  `CounterNarrativeGatherer` for counter-narrative (HistoricalAnalogFinder results +
  bullish_consensus + sector_risks), `PumpEvidenceGatherer` for pump summary (signals +
  historical_matches). Numbers (timestamps, confidence floats, mention_counts,
  posting_velocity, coordination_scores) come from code per I-S1; LLM ONLY outputs
  text — categorical sentiment enum + bear-point prose + evidence-summary prose.

**Critical I-S1 enforcement** per CLAUDE.md hard rule + invariants.md § I-S1: LLM
NEVER outputs numeric. Sentiment classifier returns `Sentiment` enum 5-level (BR-4
mandates categorical-only). Counter-narrative generator returns list of bear-point
strings. Pump evidence summarizer returns single string. Verifier grep gate at S52/S53
close: `grep -r "anthropic\|openai\|claude_llm" packages/domain/crowd/` returns 0;
LLM-output JSON schema validation rejects any non-enum sentiment + any number-shaped
field in counter-narrative bear-points + any number-shaped field in pump evidence
summary.

S52 entry MUST run empirical-probe-first (per L-S32-1 skill) on ≥3 strategies for
sentiment classifier model pick: Claude Haiku batch / Claude Sonnet batch / Haiku-prefilter+
Sonnet-extract hybrid. Probe set = 50 hand-labeled VN forum posts (mix of F319 + FB
group public posts). Pick by per-label accuracy (≥85% per category per § B.7
calibration target). Cost band: ~$3-6 one-time for 50-fixture × 3-strategy probe
(sentiment classification much cheaper per-token than KOL extraction). Rejected D2
(violates D-026 ratified) + D3 (violates I-S1 + BR-4).

### (e) NarrativePhaseClassifier — Deterministic rule-based 7-state

`packages/domain/crowd/services/narrative_phase_classifier.py` per UC-2 + spec § B.3
lines 301-333. **DETERMINISTIC pure-Python; NO LLM**. 7-phase machine:
INCUBATION → EMERGING → MAINSTREAM → SATURATION → EXHAUSTION → REVERSAL → DEAD.
Rules verbatim from spec § B.3 lines 301-333:

```
INCUBATION:   avg_mentions_per_day < 5 AND unique_sources < 3
EMERGING:     velocity_trend == "ACCELERATING" AND major_source_share < 0.2
MAINSTREAM:   major_source_share >= 0.3 AND kol_mention_count >= 3
SATURATION:   MAINSTREAM context AND bullish_ratio >= 0.8 AND new_unique_posters_trend == "DECELERATING"
EXHAUSTION:   avg_mentions_per_day >= 20 AND velocity_trend == "DECELERATING"
REVERSAL:     counter_narrative_velocity > velocity * 0.3
DEAD:         avg_mentions_per_day < 1
```

Thresholds tunable via `NarrativePhaseClassifierConfig` dataclass (default values
match spec § B.3 verbatim; tuning deferred to Year 2 outer-loop activation per spec
005). Phase transitions emit `NarrativePhaseChanged` event per § B.2. Verifier grep
gate at S53 close: `grep -r "anthropic\|openai\|claude_llm" packages/domain/crowd/services/`
returns 0. Rejected E2 (LLM declares phase — violates spec § C.1 explicit rejection
+ I-S1) + E3 (ML model — insufficient labeled data Phase 3).

### (f) PumpPhaseClassifier — Deterministic multi-signal weighted scoring

`packages/domain/crowd/services/pump_phase_classifier.py` per UC-3 + spec § B.3
lines 379-423. **DETERMINISTIC pure-Python; NO LLM**. 5-state classifier:
PRE_PUMP / PUMP / DISTRIBUTION / DUMP / UNCERTAIN. Multi-signal weighted scoring:

- **PRE_PUMP signals**: quiet_accumulation (price_change_30d < 0.10 + volume_30d_avg
  rising) + kol_whispers_no_news (t3_kol_mentions_rising + t2_news_silent)
- **PUMP signals**: volume_price_spike (price_5d_change > 0.20 + volume ratio >3x) +
  fomo_active (t3_kol_mentions_peak + t4_novice_post_share > 0.5)
- **DISTRIBUTION signals**: volume_without_price (volume ratio >2x + abs(price_5d_change)
  < 0.05) + novice_fomo_dominant (t4_novice_post_share > 0.7 + t4_coordination_score < 0.3)
- **DUMP signals**: price_crash_volume_decline (price_5d_change < -0.15 + volume declining)

Scoring weights per spec § B.3 verbatim (PRE_PUMP signals 0.3+0.3=0.6 max; PUMP
0.4+0.3=0.7 max; etc.). Confidence gate ≥0.4 OR returns UNCERTAIN per spec line 418.
Weight tuning deferred to Year 2 outer-loop activation per spec 005. Per § B.8
"Bootstrap test: run same data twice, identical classifications" — pure-Python
guarantees this; pytest deterministic-roundtrip test.

**BR-9 historical pattern matching** binding: every detection cross-references via
`HistoricalAnalogFinder` (decision (g) substrate); if no historical analog matches,
detection annotated `historical_similar_cases=[]` and confidence capped at 0.6 per
BR-9 "novel pattern, low confidence" framing.

**BR-5 backtest validation gate** per decision (i) below: precision >0.5 + recall >0.3
hold-out gate at S53 close BEFORE classifier deploys live (initially Phase 1 detections
human-reviewed-first per § B.8).

Rejected F2 (LLM declares phase) + F3 (no confidence gate — violates § B.10 R6
mitigation).

### (g) Counter-narrative generator — LLM bear points grounded in 3 sources

`packages/infrastructure/crowd/counter_narrative_generator.py` implements
`CounterNarrativeGeneratorPort` per UC-4 + spec § B.3 lines 425-465. LLM bear points
grounded in 3 sources (gatherer-wired per (d)):

1. **HistoricalAnalogFinder failing analogs**: `subsequent_return_12m < -0.10`
   threshold per spec line 442; embedding-based similarity search on historical
   ticker-period setup-fingerprints (price_trajectory + sentiment_shape +
   fundamental_state) per § B.4
2. **Bullish consensus summary**: aggregated from active narratives where ticker
   in `affected_tickers` + recent `SentimentSnapshot.dominant_sentiment()` is
   STRONGLY_BULLISH or BULLISH
3. **Sector structural risks**: `risk_repo.get_sector_risks(ticker)` query (cross-BC
   contract; ticker → sector → known structural risk catalog; Phase 3 may stub-out
   if cross-BC sector-risk repo not yet wired — flag IMPL-S53-N at entry)

**MANDATORY per BR-6** when `bullish_ratio() > 0.8` on considered ticker (gates
positive signal issuance per I-S13). Triggered via `CounterNarrativeRequested` event
on sentiment threshold crossing. CounterNarrative aggregate stored with non-empty
bear_points + non-empty historical_analogs invariants per (c).

**LLM output constraints per (d) D-026 + I-S1**: bear_points = list[str] (each
bear-point ≤500 chars per audit-traceability); NO numeric scores; NO percentage
phrasing ("approximately 18%" anti-pattern). Verifier S53 close test: regex match
on bear_point output for `\d+\s*%|approximately|roughly|around \d+` raises
`LlmOutputViolatesISOne`.

Rejected G2 (template-based — spec § C.1 rejects) + G3 (freeform no grounding —
violates BR-6 + I-S2).

### (h) Coordination detection — 3-feature extractor + conservative threshold

`packages/infrastructure/crowd/coordination_detector.py` implements
`CoordinationDetectorPort`. Three feature extractors per spec § B.4 verbatim:

1. **Template similarity**: embedding-based (OpenAI text-embedding-3-small per
   architecture.md § LLM); flag if >10 posts with cosine similarity >0.9 within 1h
   sliding window
2. **Timing cluster**: flag if >5 accounts post within 3-min window repeatedly
   (≥3 occurrences in 24h)
3. **Account age distribution**: flag if >50% of bullish posters are <30-day-old
   accounts (account-age fetched via aggregator-supplied metadata; F319 surface +
   FB Graph API public-page-author-creation-date)

Coordination score in [0,1] (computed deterministically as weighted ensemble; weights
0.4/0.3/0.3 default tunable). Conservative threshold ≥0.8 per BR-8 before flagging.

**BR-10 NO public accusations** binding enforcement:
- `CoordinationDetected` event payload contains `posting_pattern: str` description
  (e.g., "10 posts cosine-sim >0.9 within 1h on F319 ticker thread") + `coordination_score: float`
- **NEVER includes**: poster_id, account_name, individual post content, operator name
- UI rendering (S57 Track M) frames as "pattern detected, exercise caution" per spec
  A.3 BR-10; system output CONSTITUTIONALLY FORBIDDEN from naming operators

**Flagged ≠ confirmed**: detection emits event for human review queue per § B.8
"Pump detection cases all go to manual review first 3 months". Verifier S52 close
test: pytest creates synthetic CoordinationDetected event payload + asserts no PII
fields + asserts no operator-naming substrings in `posting_pattern`.

Rejected H2 (LLM judges — violates I-S1 + BR-8 reproducibility) + H3 (2-signal —
violates spec § B.4 explicit 3-feature requirement).

### (i) Backtest validation gate — precision >0.5 + recall >0.3 holdout pre-deploy

Per BR-5 + master-plan § Phase 3 Success Criterion #4. Before PumpPhaseClassifier
deploys live, S53 close MUST run validation harness:

- **Labeled training set**: seeded manually per § B.7 (user labels 5-10 historical
  pump events from 2021-2024 VN market memory; period_start + period_end + phases
  JSONB + features_at_detection + subsequent_outcome); stored in
  `eval-sets/labeled-pumps/` per spec § B.7
- **Hold-out**: 70/30 split; train weights validated (no weights fit Phase 3 — weights
  fixed per spec § B.3 verbatim; hold-out tests classifier behavior on unseen labels)
- **Acceptance**: precision >0.5 AND recall >0.3 per BR-5 verbatim
- **Rollback if fails**: do NOT silently lower threshold; escalate via SCOPE Q&A
  bundle per D-027 § Rollback path precedent; defer Track K live-deploy to S54
  harness-recovery reserve

**Phase 1 detection mode** per § B.8: every pump detection in Phase 1 reviewed by
user before alert fires. Implementation: `PumpDetection` aggregate has
`status: 'pending_review' | 'reviewed_approved' | 'reviewed_rejected'` field;
`PumpPhaseDetected` event ONLY fires for `status == reviewed_approved`. UI S57
Track M includes review queue. Phase 1 → Phase 2 transition (auto-fire-on-detection)
gated on monthly false-positive review per § B.8 quarterly recalibration.

**Deferred outcome calibration**: `labeled_pumps.subsequent_outcome` filled post-hoc
via outcome scheduler (mirror BC-6 outcome_scheduler pattern from D-027(f) but
simplified — single 30d/90d post-label review window vs BC-6's 4-window 1m/3m/6m/12m).
Phase 4+ activates calibration update loop.

Rejected I2 (no validation gate) + I3 (precision 0.8 threshold unachievable Phase 3).

## Consequences

**Positive**:
- BC-7 ships 2 substantive tracks J/K within ~300-440K main + 150-250K subagent envelope
  (per master-plan § Calibration Envelope row "Substantive tracks J+K (BC-7)")
- D-026 LLM Substrate Boundary patterns extend BC-6 → BC-7 cross-BC application (
  3 LLM adapter sites: sentiment classifier + counter-narrative + pump-evidence summary)
- Determinism preserved across stack: phase classifiers + coordination scoring + backtest
  gate all pure-Python (I-S1 enforced via grep)
- SQLite substrate continuity simplifies Phase 4 migration (BC-5 + BC-6 + BC-7 + BC-8
  single migration batch)
- Counter-narrative MANDATORY per BR-6 closes I-S13 hot-stock confirmation-bias gap
  (groupthink mitigation — biggest VN-market risk per spec § C.1)
- Most VN-specific edge (no commercial product matches) — competitive moat builds
  Phase 3 ship

**Negative / accepted**:
- **Cold-start (BR-5+BR-9)**: pump classifier requires ≥5 labeled historical pumps before
  hold-out validation runnable; first 3 months Phase 1 detections all human-reviewed
  per § B.8 before alerts fire — slows Phase 3 dogfood feedback loop
- **Empirical-probe-first ladder at S52 entry adds ~$3-6 one-time probe cost** for
  sentiment classifier (50-fixture × 3-strategy; ~6x cheaper than BC-6 S47 KOL probe
  due to shorter post text vs full transcripts)
- **Facebook ToS gray-zone risk** (mirror Q-P3-2 BC-6 user accept) for FB public group
  scraping; R-P3-2 mitigation: crawler-reliability skill MANDATORY at S52; refuses
  private content per BR-1 raises `ToSBoundaryViolation`
- **Coordination detection has high latent legal risk** (BR-10 NO public accusations);
  3-tier mitigation: payload schema CONSTITUTIONALLY FORBIDDEN from operator-naming
  fields + UI framing "pattern detected exercise caution" + human-review-first
  Phase 1
- **CafeF/Vietstock comment scraping fragility** — site HTML changes break adapter;
  vendor-api-probe.sh weekly skill check; manual fallback documented at adapter docstring
- **Telegram crowd deferred** to Phase 4 (BC-7 ships F319 + FB + comments only); some
  VN crowd activity on Telegram public channels NOT captured Phase 3

**Rollback path**:
- If S52 sentiment classifier precision <0.85 across all 3 strategies on 50-fixture
  probe → escalate via SCOPE Q&A bundle; defer Track J completion to S54 META_LOOP_
  RECOVERY reserve; do NOT silently lower threshold
- If S53 pump classifier fails BR-5 hold-out gate (precision ≤0.5 OR recall ≤0.3) →
  pump live-deploy deferred to S54; counter-narrative generator + sentiment snapshots
  still ship (decoupled paths)
- If FB Graph API auth shifts mid-Phase-3 (ToS hardening) → fb_group_aggregator falls
  back to manual link-list mode (mirror Phase 4 BC-6 facebook_adapter rollback per
  D-027 R1 mitigation)

## Provenance

- spec 003 § A.3 BR-1..BR-10 + § B.1 entities + § B.3 UC-1..UC-4 + § B.4 adapters +
  § B.5 schema + § B.7 calibration + § B.8 quality gates (binding)
- D-027 (BC-6 architecture; mirror schema verbatim)
- D-026 (LLM Substrate Boundary verbatim citation requirement)
- L-S17-1 (SQLite portability) — agent-notes.md
- L-S32-1 (empirical-probe-first) — `.claude/skills/empirical-probe-first/SKILL.md`
- I-S1 (NO LLM math) + I-S2 (provenance + as-of) + I-S35 (research-aid framing) +
  I-S13 (counter-narrative mandatory hot-stocks)
- master-plan 007-S44 § Track Catalog J/K + § Session Breakdown S51-S53 +
  § Risk Register R-P3-2/R-P3-4/R-P3-6
- BC-6 S64 sandwich-verifier net = PASS-WITH-RESIDUE-MEDIUM Tier 1 GREEN 150/150 pytest
  (telegram_adapter ToS hardening pattern referenced in (b) for fb_group adapter)
- spec 005 § A.2 (Year 2 outer-loop activation gate; weight tuning deferred)
