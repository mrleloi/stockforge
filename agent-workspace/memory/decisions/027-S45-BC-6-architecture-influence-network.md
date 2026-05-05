---
id: D-027
title: BC-6 Influence Network architecture (Tracks G+H+I)
status: ACCEPTED
tier: ARCH
date_proposed: 2026-05-05
date_ratified: 2026-05-05
ratifying_session: S45
authoring_agent: Claude Opus 4.7 (sandwich-architect dispatch; lean ≤6 pre-reads per L-S43f-2)
supersedes: none
superseded_by: none
source_evidence:
  - specs/tier2-feature/002-influence-network-tracking.md (binding spec; § A.3 BR-1..BR-10 + § B.1 entities + § B.3 UC-1..UC-5 + § B.4 adapters + § B.6 schema)
  - agent-workspace/memory/decisions/026-S43e-charter-promote-bundle-C1-C2.md (D-026; LLM Substrate Boundary patterns binding for Track H)
  - agent-workspace/constitution/architecture.md § BC-6 + § "LLM Substrate Boundary" + § Layer Hierarchy + § Cross-BC Rules
  - agent-workspace/constitution/invariants.md § I-S1 (NO LLM math) + § I-S2 (provenance + as-of) + § I-S35 (research-aid framing)
  - agent-workspace/session-plans/pending/007-S44-phase-3-master-plan.md § Track Catalog G/H/I + § Open Questions Q-P3-2/4
  - agent-workspace/memory/agent-notes.md § L-S17-1 (SQLite portability binds Phase 1+2; migration at Phase 4 SaaS-deploy)
  - User picks 2026-05-05: Q-P3-2 = ALL 3 platforms (YouTube + Telegram + Facebook); Q-P3-4 = SQLite (auto-decided IMPL-tier)
options_considered:
  - decision_a_storage:
      A1_sqlite_extension: chosen — match Phase 1+2 substrate per L-S17-1 portability
      A2_postgres_now: rejected — premature; Phase 4 SaaS-deploy boundary triggers migration
      A3_hybrid_sqlite_recs_postgres_calibration: rejected — substrate split adds drift surface without Phase 3 benefit
  - decision_b_adapter_pattern:
      B1_shared_protocol_three_concretes: chosen — KOLChannelAdapter Protocol + 3 concrete classes; Liskov-clean swapping for tests
      B2_three_unrelated_concrete_classes: rejected — duplication of rate-limit + ToS pre-flight + retry logic across 3 platforms
      B3_single_god_adapter_with_platform_dispatch: rejected — anti-pattern god service per architecture.md § Forbidden Patterns
  - decision_c_recommendation_persistence:
      C1_domain_layer_aggregate_repository_protocol: chosen — Recommendation + Kol + Channel + CredibilityScore aggregates in packages/domain/influence_network/; Protocol in domain; impl in infrastructure
      C2_service_layer_only_anemic: rejected — anemic-domain anti-pattern; spec 002 § B.1 explicitly defines rich entities with invariants
  - decision_d_llm_extractor_substrate:
      D1_cite_d026_substrate_boundary_verbatim: chosen — per-role override + prose-tolerant JSON + gatherer-wired compute mandatory per D-026 ratified
      D2_freeform_extractor_no_substrate_pattern: rejected — D-026 binding for ALL Phase 3 LLM-perspective adapters; would violate ratified constitution
  - decision_e_calibration_determinism:
      E1_pure_python_bayesian_in_domain_service: chosen — packages/domain/influence_network/calibration_service.py; scipy.stats.beta deterministic; LLM never outputs credibility numbers per I-S1
      E2_llm_assisted_credibility_synthesis: rejected — violates I-S1 NO-LLM-math hard rule; finance-grade traceability lost
  - decision_f_outcome_scheduler:
      F1_sqlite_jobs_table_cron_runner: chosen — outcome_scheduler.py writes pending jobs to SQLite outcome_reviews table per spec 002 § B.6 schema; daily cron picks due_at <= now
      F2_redis_streams_or_rq: rejected — Redis broker not yet wired Phase 3; SQLite jobs sufficient for personal-scale; migrate at Phase 4
chosen_options: A1 + B1 + C1 + D1 + E1 + F1
---

# D-027 — BC-6 Influence Network Architecture

> Ratifying ADR for BC-6 (KOL Influence Network) bounded-context architecture
> covering Phase 3 Tracks G (adapters) + H (LLM extraction) + I (calibration).
> Sub-plan binding: `008-S45-track-G-H-I-impl-sub-plan.md`.

## Context

Phase 3 master-plan (007-S44) confirmed BC-6 full-scope ship via Q-P3-2 = ALL 3
platforms (YouTube + Telegram + Facebook) + Q3=CONFIRM Phase 3 envelope. Spec
002 (Tier 2) defines the entity model + use cases + business rules. D-026 just
ratified the LLM Substrate Boundary patterns at S43f, mandating Track H cite
the 3 patterns verbatim. This ADR commits the architectural decisions for
S46+S47+S49 IMPL sessions.

## Decisions

### (a) Storage substrate — SQLite extension

Match Phase 1+2 substrate (per L-S17-1 portability). Schema mirrors spec 002
§ B.6 verbatim adapted for SQLite (TIMESTAMPTZ → TEXT ISO8601; JSONB → TEXT
json-serialized; TEXT[] → TEXT json-array). Migration to Postgres deferred to
Phase 4 SaaS-deploy boundary. Substrate gain: zero new infra; consistent with
BC-5 (S36) + BC-8 (S42) precedent. Rejected A2 Postgres-now (premature) + A3
hybrid (drift surface).

### (b) Adapter pattern — Shared Protocol + 3 concrete impls

`packages/application/influence_network/ports/kol_channel_adapter_port.py`
defines `KOLChannelAdapter` Protocol with methods `fetch_new_content(channel,
since) -> list[ChannelContent]` + `fetch_transcript(content) -> Transcript`.
Three concretes in infrastructure: `youtube_adapter.py`, `telegram_adapter.py`,
`facebook_adapter.py`. Shared `RateLimitedFetcher` base class encapsulates
backoff + ToS pre-flight + user-agent rotation (per Q-P3-2 R-P3-2 mitigation).
Rejected B2 (duplicated boilerplate) + B3 (god-service).

### (c) Recommendation entity persistence — Domain aggregates + Protocol repo

`packages/domain/influence_network/{kol,channel,recommendation,credibility_score}.py`
hold rich aggregates per spec 002 § B.1 — frozen dataclasses + `__post_init__`
invariants (Recommendation requires source_url + transcript_excerpt ≤500 chars +
extracted_at + extraction_confidence per BR-10). Protocol
`packages/application/influence_network/ports/{kol,recommendation,outcome_review}_repository.py`.
Concrete `packages/infrastructure/influence_network/sqlite_*_repository.py`.
Rejected C2 (anemic anti-pattern violates architecture.md § Domain Model Rules).

### (d) LLM extractor substrate — D-026 verbatim citation

`packages/infrastructure/influence_network/llm_recommendation_extractor.py`
implements `LLMRecommendationExtractorPort`. Cites architecture.md § "LLM
Substrate Boundary" verbatim:
- **Per-role override (BP-S43b-1)**: `role_model_overrides` dict allows
  Haiku-prefilter + Sonnet-extract hybrid without touching call sites.
- **Prose-tolerant JSON (BP-S43b-2)**: 3-tier extractor (fenced block →
  first-`{` heuristic → best-effort recovery); reuse
  `subagent_transport.py:55-118` extractor function (Phase 2 BC-8 substrate).
- **Gatherer-wired compute (BP-S43b-3)**: `KOLContentGatherer` prepares
  transcript + channel-metadata + extraction-config context; numbers (timestamps,
  confidence floats) come from code, never LLM-narrated.

S47 entry MUST run empirical-probe-first (per L-S32-1 skill) on ≥3 strategies
before committing to extraction model: Claude Opus / Claude Sonnet /
Haiku-prefilter+Sonnet-extract. Probe set = 50 Vietnamese KOL fixtures
(YouTube auto-captions noisy + Facebook posts mixed-media); pick by
precision/recall on labeled-fixture set per R-P3-1 master-plan mitigation.

### (e) Calibration determinism — Pure Python Bayesian in domain service

`packages/domain/influence_network/calibration_service.py` implements UC-3
verbatim per spec 002 § B.3 UC-3. Uses `scipy.stats.beta` (or pure-python
beta-fn fallback) for posterior CI computation. Skeptical prior Beta(5,5).
LLM never invoked in this code path. I-S1 enforced: no LLM math, no
"approximately N%" prose anywhere in service. Rejected E2 (violates I-S1 hard
rule + finance-grade traceability).

### (f) Outcome review scheduler — SQLite jobs + cron runner

`packages/infrastructure/influence_network/outcome_scheduler.py` implements
`OutcomeSchedulerPort`. On RecommendationExtracted, writes 4 rows to
outcome_reviews table (1m/3m/6m/12m windows; `due_at` computed via
`published_at + offset`). Cron runner `apps/cli/run_due_outcome_reviews.py`
queries `WHERE status = 'pending' AND due_at <= NOW()` and dispatches
`EvaluateOutcomeReviewUseCase` per spec 002 § B.3 UC-2. Rejected F2 (Redis
not wired Phase 3).

## Consequences

**Positive**:
- BC-6 ships 3 substantive tracks G/H/I within ~430-620K main + 200-350K subagent envelope
- D-026 LLM Substrate Boundary patterns get first cross-BC application (BC-6 LLM extractor mirrors BC-8 perspective adapter)
- Calibration determinism preserved across stack (I-S1 enforced)
- SQLite substrate continuity simplifies Phase 4 migration (single batch vs split)

**Negative / accepted**:
- Cold-start (BR-2): KOLs marked PROVISIONAL until 10 evaluated recs; first 6 months produce calibration data with wide CI
- Empirical-probe-first ladder at S47 entry adds ~$8-12 one-time probe cost (one-time; necessary per R-P3-1 HIGH severity)
- Facebook ToS gray-zone risk (per Q-P3-2 user explicit accept); R-P3-2 mitigation via crawler-reliability skill MANDATORY at S46

**Rollback path**: If S47 LLM extraction precision <0.85 across all 3 strategies on 50-fixture probe → escalate via SCOPE Q&A bundle; defer Track H to S48 META_LOOP_RECOVERY reserve; do NOT silently lower threshold.

## Provenance

- spec 002 § A.3 BR-1..BR-10 + § B.1 entities + § B.3 UC-1..UC-5 + § B.4 adapters + § B.6 schema (binding)
- D-026 (LLM Substrate Boundary verbatim citation requirement)
- L-S17-1 (SQLite portability) — agent-notes.md
- L-S32-1 (empirical-probe-first) — `.claude/skills/empirical-probe-first/SKILL.md`
- I-S1 (NO LLM math) + I-S2 (provenance + as-of) + I-S35 (research-aid framing)
- Q-P3-2 user pick 2026-05-05 (ALL 3 platforms)
- Q-P3-4 IMPL-tier auto-decide (SQLite Phase 3)
