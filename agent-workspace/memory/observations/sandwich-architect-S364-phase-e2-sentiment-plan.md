---
observation_id: sandwich-architect-S364-phase-e2-sentiment-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md
target_session: S365 (dev FOCUSED_IMPL) + S366 (verifier AP-1)
verifier_session: S366 sandwich-verifier AP-1 (fresh-context post-S365 dev close)
phase_milestone: E.2 Vietnamese Sentiment Lexicon — SECOND sub-plan of Phase E master plan-028 (per § E sequencing; precedes E.3 + E.4)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template L5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with n=1 vietnamese-nlp-impl PRECEDENT from S362 (~159K Sonnet / ~39min / 1053/1053 tests / 0 mistakes per current-execution.md S362 row; variance window narrow at n=1 — sub-plan 030 IMPL projected to fit similar Sonnet 100-150K envelope unless corpus-labelling cycle inflates significantly)
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; second of 4 sub-themes per parent master plan-028 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN; sub-plan 030 satisfies its § E.2 contract per DD-4 LEXICON-PATTERN-PORT + CALIBRATE strategy)
predecessor_sub_plan: agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md (SHIPPED + VERIFIED; pyvi VnTokenizer + WhitespaceTokenizer fallback available via DI for sub-plan 030 D2)
---

# S364 sandwich-architect — Phase E.2 VN Sentiment Lexicon sub-plan-030 authoring observation

## What was authored

`agent-workspace/session-plans/pending/030-S364-phase-e2-vn-sentiment-lexicon.md` — FOCUSED_IMPL sub-plan for Phase E sub-theme E.2 Vietnamese sentiment lexicon, decomposing into 5 sub-tracks (D1 port + D2 lexicon dict + scoring fn + D3 tests + D4 calibration recipe + D5 CLI smoke) with LEXICON-PATTERN-PORT + CALIBRATE strategy (per parent plan-028 DD-4) gated by 2 CHARTER-TIER GATE STOP-AND-ASK triggers ((a) corpus-labelling source per § K.2 anticipated flag + (c) Rule 16 mode-2 violation per Rule 16 § Enforcement).

**Plan stats** (architect-internal):
- Total LOC: ~1100 (within 150-230K Opus PLAN recalibrated budget; well-grounded in 28 VBW-read source files)
- 7 DD architecture decisions (DD-1..DD-7) all pre-answered with rationale + adversarial alternates
- 5 sub-tracks D1-D5 in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 35 DC DoD items (≥25 floor satisfied; 11 file + 10 impl + 7 STEP 0 + 7 gates + 3 smoke + 5 bookkeeping)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 10 RM entries (RM1..RM10) with mitigation in § J
- **STEP 0 STOP-AND-ASK trigger inventory** with 5 documented triggers ((a) CHARTER-TIER GATE corpus-labelling + (b) corpus-expansion-failed + (c) Rule 16 mode-2 violation + (d) I-S34 HARD-REJECT + (e) non-determinism)
- **§ M CHARTER-TIER GATE clause** as canonical reference for S365 dev (2 mandatory STOP-AND-ASK triggers)
- **§ L Conditional next-step** with 4 branches L.1-L.4 covering all post-gate paths
- **Phase 1b CONSUMED variant with n=1 precedent CITATION** + cold-start window characterization (narrow; sub-plan 030 IMPL fits S362 envelope unless corpus-labelling cycle inflates)

## Key architectural decisions (DD-1..DD-7 summary)

| DD | Decision | Pre-decided or CONDITIONAL? |
|---|---|---|
| **DD-1** | **VnLexiconPort = Protocol (NOT ABC)** — mirrors sub-plan 029 D1 TextTokenizerPort + existing LlmExtractorPort precedent | PRE-DECIDED (DDD tactical pattern + Karpathy P2 simplicity) |
| **DD-2** | **Lexicon storage = Python dict literal in source file** (NOT external JSON/TSV) | PRE-DECIDED per Karpathy P2 simplicity + Python-import-determinism + diff-friendly review |
| **DD-3** | **Cultural anchors WIRED at lexicon-dict layer** (NOT separate dict) + companion `VN_CULTURAL_ANCHORS: frozenset[str]` for E.3 consumer | PRE-DECIDED per Karpathy P3 surgical-changes + Charter Principle 4 (cultural anchors ARE sentiment information) |
| **DD-4** | **Scoring fn shape = `score(text: str) -> SentimentScore`** (NOT `score(tokens: list[str])`) + DI of VnTokenizer at constructor | PRE-DECIDED per DDD tactical patterns + Karpathy P2 simplicity (adapter owns its dependencies) |
| **DD-5** | **SentimentScore = frozen dataclass with 4 fields** (numeric_score / category / keyword_hits / coverage_ratio) | PRE-DECIDED per Charter "Domain layer has ZERO framework dependency" mirror discipline + Rule 16 mode 2 + Rule 7 categorical |
| **DD-6** | **Numeric→categorical mapping = Buffett-rubric-inspired tier thresholds** (0.7/0.3/-0.3/-0.7) | PRE-DECIDED per A-01 § 3 C9 Buffett rubric pattern + Sentiment 5-class StrEnum native mapping |
| **DD-7** | **Calibration cycle MANDATORY per Principle 8 + A-14 § 7.8 anti-pattern explicit veto** — recipe + cross-validation accuracy ≥70% floor | PRE-DECIDED per Charter Principle 8 + recipe DEFERRED to sub-plan 030-V2 data-only update (v0 ships HYPOTHESIS weights) |

**Single most important callout**: **DD-7 calibration cycle MANDATORY + STEP 0.5 CHARTER-TIER GATE on corpus-labelling source** — this is the entire architectural rationale for v0 shipping HYPOTHESIS weights + recipe + DEFER calibration. Architect REFUSES to pre-decide labelling source because (a) project-owner availability is unknown (orth orchestration realism), (b) LLM-bootstrap option carries CHARTER-TIER meta-sampling FLAG per plan-028 § K.2 sub-plan 030 anticipated flag, (c) UNCALIBRATED-V0 is acceptable ship state per AQ-8 + AP-7 trigger named (data-only update post-labelling doesn't block E.3/E.4 sub-plans).

## Phase 1b self-calibration (CONSUMED variant; n=1 PRECEDENT from S362; narrow variance)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `.claude/agents/sandwich-architect.md` (full read 252 LOC; agent template L42-65 Phase 1b path + L207-210 observation mandate + L110-120 sub-track 3 mandatory fields; recalibrated PLAN budget table per M-S360-2)
2. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 carry-forward — planner-feedback-loop.sh STILL header-only at S364 entry after S354/S357/S360/S361/S362/S363 dogfood cycles did not populate; auto-population infrastructure gap)
3. `agent-workspace/memory/current-execution.md` (offset 1-100 + 147-165 read; S362 sandwich-dev RETURN row confirms vietnamese-nlp-impl n=1 precedent: ~159K Sonnet over ~39 min, 1053/1053 tests, 0 mistakes per CHARTER-TIER GATE-did-not-fire path + S363 verifier mentioned)
4. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; no VN-NLP-lexicon-impl-specific failure pattern history; M-S360-2 Opus PLAN budget recalibration cited)
5. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; offset 1-400 + 400-700 read; §s A/B/C/D/E/F/G/H/J/K/L/M/N/P; CONFIRMED sub-plan 030 § E.2 row + DD-4 LEXICON-PATTERN-PORT + § K.2 anticipated FLAGS for sub-plan 030 + AQ-8 corpus labelling answer)
6. `agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md` (precedent sub-plan; offset 1-1100 read in 3 chunks; full template for sub-plan 030 structure mirror)
7. `agent-workspace/memory/observations/sandwich-architect-S361-phase-e1-tokenization-plan.md` (precedent observation; offset 1-80 read; format reference for THIS observation)
8. `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (ADR D-070; full read 100 LOC; pyvi==0.1.1 selection + license MIT + revisit triggers; trigger 1 honored by THIS sub-plan held-out corpus eval)
9. `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (precedent calibration file; full read 102 LOC; format reference for vn_sentiment_lexicon_v0.md; n=36 baseline; CafeF=0 gap noted as carry-forward)
10. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum — Theme I sub-plan 030 scoring categorical mapping target)
11. `packages/domain/news/models/extracted_claim.py` (full read 83 LOC; ExtractedClaim invariants + Rule 6 grounding + ≤500 char excerpt cap; future E.3 consumer)
12. `packages/domain/news/services/claim_extraction_service.py` (full read 70 LOC; LlmExtractorProtocol contract — VnLexiconProtocol design mirror for D1)
13. `packages/application/nlp/ports/text_tokenizer_port.py` (full read 51 LOC; TextTokenizerPort Protocol — DI consumer for D2 lexicon)
14. `packages/infrastructure/nlp/vn_tokenizer.py` (full read 148 LOC; VnTokenizer pyvi adapter + WhitespaceTokenizer fallback — DI source for D2 lexicon)
15. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (lines 232-278 read via Grep; underthesea+pyvi sub-deliverables + lexicon design recipe + cultural anchors + calibration from labelled corpus mandate)
16. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` § 3.5 + § 7.3 + § 7.8 (offset 140-200 + 240-330 read; CN sentiment lexicon weight-dict pattern + score-normalization formula `max(-1.0, min(1.0, score/3.0))` at akshare.py:1563 + VN cultural anchors + hand-tune anti-pattern explicit veto)
17. `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (offset 1-103 read; C9 Buffett-style confidence rubric pattern at warren_buffett.py:788-794 + R3 LLM-self-reported anti-pattern — for DD-6/DD-7 calibration tier mapping)
18. `agent-workspace/constitution/financial-data-protocol.md` Rule 7 + Rule 16 (offset 160-180 + 355-477 read; Sentiment categorical + Rule 16 mode-2 deterministic-pipeline-echo authoritative spec)
19. `.claude/skills/prompt-engineering/SKILL.md` (full read 140 LOC; § No-LLM-Math pattern + § Validation Pre-Conditions confirm rule-based lexicon scoring satisfies I-S1 by construction)
20. `pyproject.toml` (sub-plan 029 dev added pyvi>=0.1.1 line; expected ZERO new deps from sub-plan 030)
21. Glob `apps/extraction/**/*.py` — 0 matches (CONFIRMED `apps/extraction/sentiment/` is NEW namespace; clean baseline)
22. Glob `apps/_shared/**/*.py` — 12 files confirmed; reuse precedent pattern from RateLimiter + RobotsTxtManager
23. Glob `packages/application/nlp/**/*.py` — 3 files confirmed (text_tokenizer_port.py + __init__.py × 2); D1 adds vn_lexicon_port.py
24. Glob `data/raw/news/**/*.html` (5 article files baseline at parent master plan time; expectation = sub-plan 030 IMPL expands per § STEP 0.2 to ~200-500)
25. Glob `agent-workspace/calibration/**/*.md` — 1 file `vn_tokenizer_eval_v0.md` (from sub-plan 029); D4 adds `vn_sentiment_lexicon_v0.md`
26. Glob `agent-workspace/memory/decisions/0*.md` — 60 ADRs; D-070 most recent VN-NLP-related; D-071 next slot
27. Grep `lexicon|sentiment_score|positive_keywords|negative_keywords` across repo — 8 matches all in agent-workspace docs; ZERO production code references; clean baseline
28. Grep `VnSentiment|vn_lexicon|VnLexicon` across repo — 3 matches all in agent-workspace docs; ZERO production code; clean baseline

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (PRECEDENT n=1 from S362; THIS plan inherits)
- **sample_size**: **1** (S362 IMPL: ~159K Sonnet over ~39 min; precision low at n=1)
- **avg_wall_min observed**: ~39 min (S362 single sample)
- **avg tokens_real observed**: ~159K Sonnet (S362 single sample)
- **parallel_hit_rate**: N/A precise (n=1; D3+D4 parallel projected per plan-029 § E coordination_paths_exclusive; actual not telemetered per L-S354-2)
- **parallel_savings_avg**: N/A precise
- **failure_mode frequency**: 0 mistakes per S362 single sample (clean cycle); n=1 directional; sub-plan 030 may surface MORE defects than S362 because corpus-labelling cycle is novel work surface
- **Adjustment to default budget**: NONE for adapter+tests portion (mirror S362 ~159K Sonnet); +30-50K Sonnet reserve for STEP 0 corpus-labelling cycle IF CHARTER-TIER GATE STOP-AND-ASK does NOT fire
- **Cold-start?**: **NO for vietnamese-nlp-impl task-class** (n=1 precedent narrow-variance); **YES for sub-plan-030-specific lexicon-calibration-cycle shape** (no precedent)

## Charter-tier flags surfaced (anticipated per dispatch brief + plan-028 § K.2)

### Flag 1: Corpus labelling source (CHARTER-TIER GATE — STEP 0.5)

**Status**: ANTICIPATED at master-plan level (plan-028 § K.2 sub-plan 030 anticipated flag (a) + AQ-8); architect surfaces 3 options + recommended path per Karpathy P2 simplicity + budget realism.

**3 options for user ratification**:
- (i) Project-owner manual labelling — highest quality; ~5-10 hours owner time
- (ii) LLM-bootstrap with 5% spot-check — faster but carries META-sampling CHARTER-TIER FLAG (potential new I-S<N>)
- (iii) Distant-labelling via market signals — DEFERRED (too noisy for v0)
- (iv) DEFER calibration; ship UNCALIBRATED-V0 — explicit "v0.HYPOTHESIS" docstring + revisit trigger

**Architect recommendation**: option (i) IF owner available; option (iv) IF unknown / time-sensitive (most likely path per realism).

**Mitigation**: dev DOES NOT BLOCK on user pick; proceeds with HYPOTHESIS weights + STOP-FINDING file; recalibration is data-only update post-labelling. Phase E does NOT block on calibration cycle.

### Flag 2: Rule 16 mode-2 violation (CHARTER-TIER — STEP 0.4)

**Status**: BY-CONSTRUCTION mitigation (lexicon is LLM-free by construction; STEP 0.4 grep enforces; verifier S366 re-asserts via DC-GATE-7).

**Trigger condition**: Lexicon scoring path accidentally imports LLM SDK (extremely unlikely; defense-in-depth audit).

**Mitigation**: STEP 0.4 STOP-AND-ASK fires → dev refactors to pure-function (option (a) preferred) OR escalates to CHARTER-TIER for new Rule 16 mode (option (b) unlikely).

## Lessons identified (candidate per AP-23 first-instance HOLD)

### L-S364-1 (HOLD; promote-on-2nd-recurrence per AP-23)

**Observation**: Phase 1b at n=1 is "narrow-variance" not "cold-start"; characterization matters for budget envelope justification + future architect calibration.

**Refinement**: agent template L65 cold-start path covers n<3; n=1 specifically is an in-between state (some precedent but precision-low). Architect needs to document HOW to use n=1 directionally without false-precision.

**Pattern**: 2nd recurrence triggers promote-to-skill calculus (potential agent-template update OR new SKILL.md entry on "Phase 1b narrow-variance n=1 handling").

**Status**: HOLD; track for sub-plan 031 + 032 architect cycles (will hit n=2 + n=3 progressively).

### L-S364-2 (HOLD; promote-on-2nd-recurrence per AP-23)

**Observation**: Recalibrated PLAN budget table (150-230K Opus per M-S360-2) is the 2nd opportunity for empirical validation per dispatch brief. Sub-plan 030 dispatch fits ~165-200K Opus PLAN envelope based on (a) parent plan-028 was ~100-130K Opus / (b) sub-plan 029 was ~50-80K Opus / (c) sub-plan 030 is larger scope than 029 (calibration cycle adds complexity).

**Refinement**: Recalibrated table empirically tracking — sub-plan 030 architect dispatch is the 2nd data point.

**Pattern**: 2nd recurrence triggers promote-to-data-row in agent template Phase 1b reference table.

**Status**: HOLD; this dispatch IS the 2nd data point; track for sub-plan 031 architect dispatch (will be 3rd).

### L-S364-3 (HOLD; promote-on-2nd-recurrence per AP-23)

**Observation**: ADR D-070 trigger 1 ('pyvi quality <50% on sub-plan 030 held-out corpus eval n=200+') is INHERENTLY honored by sub-plan 030 because the labelled-corpus calibration cycle IS the held-out corpus eval surface. Sub-plan 030 is naturally the canonical eval point for D-070.

**Refinement**: ADR revisit triggers can be designed to be "naturally hit by next sub-plan's work" rather than requiring explicit separate eval session.

**Pattern**: 2nd recurrence triggers promote-to-ADR-template-guidance.

**Status**: HOLD; track for sub-plan 031/032 ADR landing.

## Risks during plan-030 IMPL (S365 dev session)

Per § J § plan-030: 10 RM entries cover cold-start budget / corpus-labelling ambiguity / cultural-anchor incomplete / HYPOTHESIS-weight misclassify / pyvi underscoring vs lexicon-key format / Rule 16 echo validation / score normalization divisor miscalibration / anthropic_api_to_subagent rule (if LLM-bootstrap option) / Windows install failure / synthetic test fixtures edge-case coverage.

**Top-3 highest-impact RMs**:

1. **RM2 Corpus labelling source ambiguity (LIKELY-MEDIUM)** — STEP 0.5 STOP-AND-ASK + dev DOES NOT BLOCK on user pick + recalibration is data-only update (mitigation strong)
2. **RM3 VN cultural anchor list incomplete (LIKELY-MEDIUM)** — append-only dict + AP-23 trigger 3 (mitigation strong; expansion is cheap)
3. **RM4 HYPOTHESIS weights misclassify (LIKELY-MEDIUM)** — D4 calibration recipe + DoD floor ≥70% macro-F1 + grid search adjustment protocol (mitigation strong; v0.HYPOTHESIS → v0.CALIBRATED transition path documented)

## What was rejected (adversarial alternates)

| DD | Alternate considered | Why rejected |
|---|---|---|
| DD-1 | ABC with `@abstractmethod` | Protocol is lighter; mypy --strict catches missing methods at adapter import time; sub-plan 029 D1 precedent established |
| DD-2 | JSON file at apps/extraction/sentiment/vn_lexicon.json | Adds file I/O + parse step; harder to review per-line; storage cost negligible |
| DD-2 | TSV file at agent-workspace/calibration/vn_sentiment_lexicon_v0.tsv | Conflates calibration data with lexicon code; separation broken |
| DD-2 | YAML file with hierarchical structure | Parse fragility; tier-grouping is incidental complexity |
| DD-2 | Database table | Premature; v0 has ~220 entries; infra without benefit at this scale |
| DD-3 | Separate `_VN_CULTURAL_ANCHORS: dict[str, float]` with own scoring path | Duplicates infrastructure; scoring fn must walk both dicts = error-prone |
| DD-3 | Cultural anchors as flag-only (no weight) | Loses signal for VN F0 retail-culture context per Charter Principle 4 |
| DD-4 | `score(tokens: list[str])` — caller tokenizes | Split-of-concerns reduces caller convenience; if caching needed, decorator path is cleaner |
| DD-4 | `score(article: NewsArticle)` — full article object | Domain leak; lexicon should not know about NewsArticle aggregate |
| DD-5 | Return only `numeric_score: float` | Loses audit trail; E.3 consumer needs category + keyword_hits |
| DD-5 | Return `dict[str, Any]` blob | mypy-strict disallow_any_explicit blocks; loses type safety |
| DD-5 | Return Pydantic model | apps/extraction/ is apps-tier orchestration; unnecessary for v0 |
| DD-6 | Linear mapping (numeric_score → percentile → Sentiment) | Requires percentile distribution; non-deterministic until calibration sample |
| DD-6 | 3-class collapse (BULLISH / NEUTRAL / BEARISH only) | Loses strongly-vs-moderately distinction; Sentiment 5-class is existing contract |
| DD-6 | Sigmoid mapping | Smooth boundaries lose categorical clarity; tier thresholds give clear interpretability |
| DD-7 | Hand-tune weights based on architect intuition | A-14 § 7.8 anti-pattern explicit veto + Charter Principle 8 violation |
| DD-7 | Skip calibration entirely | Ships uncalibrated weights without documenting path forward = naked defer AP-7 violation |
| DD-7 | Block IMPL on calibration cycle completion | Budget overrun risk; ship hypothesis + recipe + revisit is correct path |

## What's NOT in this plan (deferred work; explicit non-goals)

Per § A.3 (14 OOS items each with revisit trigger per AP-7):
- Sub-themes E.3 (claim extraction wrapper) + E.4 (ticker resolver) — separate sub-plans 031/032
- PhoBERT fallback (E.2-V2) + custom-trained BERT (E.2-V3) — coverage <50% / accuracy <80% triggers
- Reinforcement-learning calibration — calibration plateau OR n≥5000 trigger
- Async sentiment scoring interface — Phase 3 throughput trigger
- Multi-language sentiment (English / Chinese) — explicit user directive trigger
- Sentiment-score caching / memoization — E.3 latency trigger
- Sentiment-score persistence to database — E.3 query-time trigger
- Sentiment-score historical regression dashboard — 2+ silent-regression trigger
- Lexicon entry version-control via per-entry git annotations — n≥1000 entries trigger
- Lexicon weight A/B testing harness — competing candidates with empirical equipoise trigger
- Lexicon entries beyond initial 200-500 — coverage <70% trigger
- Charter amendment SHIP for corpus-labelling-meta-sampling discipline — § CHARTER-TIER GATE STEP 0.5 fires trigger
- New harness hook for VN-lexicon-determinism check — 2+ silent drift incidents trigger
- Sentiment-score integration into NewsArticle pipeline — E.3 at-ingest scoring trigger

## Coordination paths off-limits (during S365 dev session window)

Per § K of plan-030. Main session avoids `packages/application/nlp/ports/vn_lexicon_port.py` + `apps/extraction/**` + `apps/cli/score_vn_sentiment.py` + `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` + `agent-workspace/calibration/vn_sentiment_lexicon_v0.md` + dev session log + dev observation + CONDITIONAL STOP-FINDING files + CONDITIONAL `data/corpus/vn_financial_news_labelled/**` (gitignored).

When main session dispatches S366 verifier (AP-1 fresh-context post-S365 dev close), main session avoids `agent-workspace/memory/observations/sandwich-verifier-S366-vn-sentiment-lexicon-verify.md`.

## Recommended next-step (post architect ratification of THIS plan)

Per § L conditional-branching:

- **L.1 STOP-AND-ASK did NOT fire**: S365 sandwich-dev FOCUSED_IMPL dispatch (background; ~100-150K Sonnet per recalibrated table + n=1 vietnamese-nlp-impl precedent) → S366 sandwich-verifier AP-1 → sub-plan 031 architect dispatch + POSSIBLE PARALLEL sub-plan 032 architect dispatch (per parent plan-028 § E.3 + § E.4 parallel_with declaration)
- **L.2/L.3/L.4 STOP-AND-ASK FIRED**: dev proceeds D1-D5 with HYPOTHESIS weights + UNCALIBRATED-V0 docstring + STOP-FINDING file + main session dispatches AskUserQuestion gate; calibration cycle runs offline post-IMPL; E.3+E.4 sub-plans dispatch UNBLOCKED at S366 verifier confirm

**Recommended sub-plan 030 dispatch budget for S365 dev**: **100-150K Sonnet FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=1 precedent from S362 (sandwich-dev back on Sonnet per M-S360-2 ratification). Adjustment +30-50K if corpus-labelling cycle runs in-session (option (ii) LLM-bootstrap); +0K if option (iv) UNCALIBRATED-V0 (most likely).

## Compliance attestation (architect S364 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session; L-S354-2 carry-forward noted in § A.4)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief)
- [x] AP-5 ✓ (re-read all binding sources per VBW protocol — 28 files cited)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers)
- [x] AP-23 ✓ (no refinement-of-rule iterations; 3 candidate lessons L-S364-1/2/3 HOLD per first-instance discipline)
- [x] D-060 ✓ (architect has no Bash; main commits per pre-dispatch-architect-commit-guard.sh)
- [x] 0 charter / 0 constitution / 0 human-workspace writes ✓
- [x] 0 production code ✓
- [x] I-S1 ✓ (lexicon is LLM-free by construction)
- [x] I-S2 ✓ (every plan claim cites source file:line)
- [x] I-S20 ✓ (calibration over confidence — D4 recipe + DoD floor ≥70% macro-F1)
- [x] I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward)
- [x] I-S35 ✓ (lexicon = scoring utility; emits signals not recommendations)
- [x] Rule 7 ✓ (Sentiment 5-class StrEnum reused for category mapping)
- [x] Rule 16 mode 2 ✓ (numeric_score is deterministic-pipeline echo; STEP 0.4 + DC-GATE-7 enforce)
- [x] Principle 4 ✓ (VN-specific lexicon + cultural anchors = proprietary moat)
- [x] Principle 7 ✓ (Dogfood mandated in D5 CLI smoke)
- [x] Principle 8 ✓ (calibration recipe mandatory per DD-7; A-14 § 7.8 anti-pattern veto cited)
- [x] Phase 1b CONSUMED + n=1 precedent per § A.4
- [x] CHARTER-TIER GATE clause per § M (canonical reference for S365 dev — 2 STOP-AND-ASK triggers)
- [x] Recalibrated PLAN budget per CLAUDE.md table validated (this dispatch is 2nd opportunity per M-S360-2)
- [x] 5-source-evidence chain populated per § H (25 citations)
- [x] D1-D5 sub-tracks declare 3 mandatory fields per plan-025 contract

---

**END OF OBSERVATION FILE**

> Sub-plan 030 authoring complete. Main session reviews + commits architect output (D-060) + dispatches S365 sandwich-dev FOCUSED_IMPL per parent plan-028 § L sequencing.
