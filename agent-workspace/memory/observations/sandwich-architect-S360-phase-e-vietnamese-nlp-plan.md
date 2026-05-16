---
observation_id: sandwich-architect-S360-phase-e-vietnamese-nlp-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-16
plan_authored: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
target_session: S360 (THIS plan IS the master plan; sub-plan 029 dispatched at S361)
verifier_session: N/A this master plan (sub-plans verified individually post-IMPL)
phase_milestone: E Theme I ENTRY (Phase D Theme L FULLY DONE at S358; Phase E unlocks 4-sub-theme VN NLP substrate)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START EXPLICIT (task_class="vietnamese-nlp-plan" n=0 sample; nearest analog crawler-adapter-impl n=3 cited)
plan_type: PHASE-MASTER-PLAN (NOT single multi-sub-track FOCUSED_IMPL — DD-1 + § L explicit)
sub_plan_count: 4 (029/030/031/032 = E.1/E.2/E.3/E.4)
---

# S360 sandwich-architect — Phase E Theme I Vietnamese NLP entry master plan-028 authoring observation

## What was authored

`agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` — comprehensive PHASE-MASTER-PLAN for Phase E Theme I Vietnamese NLP entry, decomposing into 4 follow-on per-theme PLAN+IMPL+VERIFY chains (sub-plans 029/030/031/032).

**Plan stats** (architect-internal):
- Total LOC: ~880 (within 60-100K Opus PLAN budget envelope per dispatch brief; consciously LIGHTER than per-adapter plans 020/022/026/027 because master-plan = decomposition + recommendation NOT detailed file-level recipes — those land in sub-plan 029/030/031/032 when authored)
- 10 DD architecture decisions (DD-1..DD-10) all pre-answered with rationale + adversarial alternates
- 4 sub-plan decompositions in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 12 DC-MASTER DoD items
- 10 AQ pre-answered (AQ-1..AQ-10)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 12 RM entries (RM1..RM12) with mitigation in § J
- 3-subsection Charter-Tier-Surface § K (K.1 master-plan-level NO FLAGS / K.2 per-sub-plan anticipated FLAGS / K.3 ratification path)
- § L Plan-vs-Master-Plan decision rationale (3 subsections)
- § M Phase E → F-prime → G-prime → H-prime sequencing recommendation (3 subsections including parallel-dispatch from S363 supported)
- § P compliance attestation (16 items)

## Key architectural decisions (DD-1..DD-10 summary)

| DD | Decision | Novelty vs Phase D Theme L precedent |
|---|---|---|
| **DD-1** | **Phase E = PHASE-MASTER-PLAN (4 sub-plan decomposition)** | **NEW pattern** — Phase D Theme L was per-source decomposition (4 sub-plans 020/022/026/027 individual per-adapter); Phase E does per-theme decomposition (4 sub-plans 029/030/031/032 per-NLP-substrate-theme) |
| **DD-2** | 4 sub-themes (E.1-E.4) NOT collapsed | Direct application of master plan § 5.4 explicit enumeration |
| **DD-3** | Sub-plan 029 = DEPENDENCY-EVAL pattern | NEW pattern in StockForge production-code track — parallels Phase D Theme L plan-020 STEP 0 library evaluation (crawl4ai vs Scrapling vs MediaCrawler) but at sub-plan PLAN level |
| **DD-4** | Sub-plan 030 = LEXICON-PATTERN-PORT + CALIBRATE | NEW pattern; direct PORT from TradingAgents-CN `akshare.py:1497-1611` per A-14 § 3.5 |
| **DD-5** | Sub-plan 031 = AUGMENT existing ClaudeLlmExtractor | DDD tactical pattern; preserves backward compat |
| **DD-6** | Sub-plan 032 = FRESH MODULE + ALIAS-TABLE | Mirror `apps/_shared/crawl/` cross-app shared utility namespace precedent from Phase D Theme L |
| **DD-7** | TokenizerPreprocessor port at `packages/application/nlp/ports/` | NEW cross-BC capability namespace — `application/nlp/` (vs existing `application/news/` `application/crowd/` etc.) per architecture.md cross-BC discipline |
| **DD-8** | VN sentiment lexicon at `apps/extraction/sentiment/` | Per supplement § I.4 explicit recommendation; matches `apps/_shared/crawl/` apps-tier-orchestration namespace precedent |
| **DD-9** | VN ticker resolver at `apps/_shared/entities/` | Per supplement § I.4 explicit recommendation; mirrors `apps/_shared/crawl/` precedent |
| **DD-10** | Calibration data at `agent-workspace/calibration/` | Per CLAUDE.md Key References canonical location |

**Single most important callout**: **DD-1 PHASE-MASTER-PLAN approach** — this is the FIRST phase-master-plan in StockForge (Wave 0 was W0-N per-sub-wave; Phase D Theme L was per-source; Phase E is per-theme so master-plan-first rhythm is natural). The dispatch brief gave architect explicit choice; I picked master-plan with strong rationale (4 reasons in § L.1 + 5 anti-reasons in § L.2 + alternative-considered in § L.3).

## Phase 1b self-calibration (CONSUMED variant; COLD-START EXPLICIT per L-S354-2)

**Source files read (VBW empirical, ALL via Read tool — architect has no Bash)**:
1. `.claude/agents/sandwich-architect.md` (full read 252 LOC; agent template L42-65 Phase 1b cold-start path + L207-210 observation mandate)
2. `agent-workspace/memory/current-execution.md` (full read 185 LOC; recent session context S346-S347 + S343-S345 + S354)
3. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 carry-forward — planner-feedback-loop.sh STILL has not auto-populated after S354 first-dogfood + S357 second-dogfood)
4. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read last 30 rows; schema lacks task_class column; cannot key cleanly to vietnamese-nlp-plan task_class)
5. `agent-workspace/memory/dispatch.jsonl` (read 30 rows offset 200; agent_type populated only on recent rows; legacy agent_type="unknown-agent" predominantly)
6. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 UTC+7 inline-resolved / M-S354-NONE / M-S347-NONE / M-S342-1 medium / M-S341-1 low)
7. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (offset 1-120 for frontmatter + § 1-2; offset 460-560 for § 5.4 Theme I + § 6.4 Phase D-K)
8. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (offset 232-280; full subsection)
9. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` (offset 1-100 + offset 155-280; § 3.5 sentiment lexicon citation + § 3.6 KOL platform list)
10. `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (offset 1-80; § 2-3 deterministic-then-LLM split + confidence rubric)
11. `agent-workspace/agent-workspace/CLAUDE.md` (full read inline via system reminder; constitution-immutability + auto-mv rule)
12. `agent-workspace/constitution/architecture.md` (offset 60-140; BC-5 + BC-6 + BC-7 + cross-BC rules + LLM substrate boundary)
13. `agent-workspace/constitution/financial-data-protocol.md` (Rule 16 detail at offset 360-475)
14. `agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md` (offset 1-100 + offset 100-300 for plan format reference)
15. `agent-workspace/session-plans/completed/025-S346-planner-upgrade.md` (offset 1-120 for plan format reference)
16. `agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md` (offset 700-1000 for sub-track decomposition format reference)
17. `agent-workspace/memory/observations/sandwich-architect-S356-vietnambiz-adapter-plan.md` (offset 1-100 for observation file format reference)
18. `agent-workspace/memory/observations/sandwich-architect-S337-phase-d-theme-l-plan.md` (offset 1-80 for older observation format reference)
19. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum)
20. `packages/domain/news/models/extracted_claim.py` (full read 82 LOC; ExtractedClaim invariants)
21. `packages/domain/news/models/news_article.py` (full read 72 LOC; NewsArticle Rule 8 invariants)
22. `packages/domain/news/services/claim_extraction_service.py` (full read 69 LOC; LlmExtractorProtocol contract)
23. `packages/infrastructure/news/claude_llm_extractor.py` (full read 226 LOC; ClaudeLlmExtractor + anthropic SDK direct import at line 84 = anthropic_api_to_subagent memory-rule violation surface)
24. `agent-workspace/memory/project.md` (offset 1-80; project phase tracker + recent ADRs)

**Calibration parameters extracted**:
- task_class = `vietnamese-nlp-plan` (NEW class — no precedent)
- sample_size = **0** (cold-start declared)
- avg_wall_min = N/A cold-start; budget envelope estimated per agent-template L65 default 100-150K + dispatch brief override 60-100K for master-plan authoring
- avg tokens_real = N/A cold-start; per-theme PLAN sessions inherit precedent from THIS plan after first sub-plan ships
- parallel_hit_rate empirical = 0% (no .planner-stats population; L-S354-2 gap)
- parallel_hit_rate declared at master-plan-level = sub-plans 031+032 declared parallel_with (architect-tier orchestration eligible)
- failure_mode frequency = N/A cold-start; nearest analog crawler-adapter-impl n=3 shows 1-2 IMPORTANT defects per cycle all INLINE-RESOLVABLE
- Adjusted budget for THIS master plan = 60-100K Opus PLAN (per dispatch brief target ceiling)
- Cold-start? **YES EXPLICIT** (per agent-template L65 + plan-025 DD-11 mandate + L-S354-2 carry-forward)

**Calibration verdict**: Phase 1b COLD-START EXPLICIT at task_class=vietnamese-nlp-plan with PARTIAL infrastructure observation (.planner-stats.tsv still header-only after 2 dogfood cycles). Architect honors Karpathy P1 "calibration over confidence" by NOT making up precedent + explicitly declaring cold-start in plan output + naming the L-S354-2 carry-forward as the cause. Final budget recommendation **60-100K Opus PLAN this master plan** (per dispatch brief Budget target ceiling) + cumulative Phase E envelope ~720-1150K across 12-16 sessions (calibrated per sub-plan rhythm precedent from Wave 0 + Phase D Theme L).

## Why a PHASE-MASTER-PLAN (not single multi-sub-track FOCUSED_IMPL)

Per § L of the plan output, summarised:

1. **CLAUDE.md hard rule violation**: single-session PLAN+IMPL of 4 sub-themes = mix PLAN+IMPL = explicit anti-pattern
2. **Budget arithmetic**: 4 × 100-150K IMPL = 400-600K cumulative IMPL exceeds MULTI-TASK ceiling (150-250K)
3. **Phase 1b cold-start**: bundling cold-start work loses incremental calibration; per-theme PLAN sessions calibrate n=0 → n=1 → n=2 → n=3
4. **Wave 0 + Phase D Theme L precedent**: 9 instances of per-sub-wave / per-source PLAN+IMPL+VERIFY rhythm; W0-3+4+5 plan-018 bundle exception surfaced 9 technical issues = strong evidence bundling is high-risk
5. **Architect-tier parallel-dispatch**: per plan-025 DD-5 + S345 4-parallel validation = sub-plans 031+032 parallel-eligible = wall-clock saving without bundling complexity

## What I rejected

1. **Single multi-sub-track FOCUSED_IMPL S361 covering all 4 sub-themes** — REJECTED per CLAUDE.md hard rule + budget envelope + Phase 1b cold-start risk amplification (DD-1)
2. **Collapse E.1+E.2 into one sub-plan** — REJECTED (DD-2; coupling adds risk without saving meaningful budget)
3. **2 sub-plan decomposition (E.1+E.2 bundle + E.3+E.4 bundle)** — REJECTED (§ L.3; mixed-decision-class within bundles)
4. **"Just adopt underthesea unconditionally"** — REJECTED (DD-3; Charter Principle 8 calibration over confidence)
5. **PhoBERT fine-tune as primary sentiment scoring** — REJECTED + DEFERRED to E.2-V2 with named trigger (DD-4 + § A.3; lexicon-first is calibration-friendly + interpretable + Rule 16 mode 2 satisfaction by construction)
6. **Create parallel VnClaudeExtractor class** — REJECTED (DD-5; AUGMENT existing is DDD-clean)
7. **spaCy / fuzzywuzzy / rapidfuzz as fuzzy-match library** — REJECTED (DD-6; difflib stdlib sufficient for VN30 universe; revisit trigger at n>200 tickers)
8. **Co-locate VnTokenizerProtocol in `packages/application/news/ports/`** — REJECTED (DD-7; Theme I serves 3 BCs so cross-BC `application/nlp/` is correct)
9. **Put lexicon in `packages/domain/news/lexicons/`** — REJECTED (DD-8; lexicon is application-tier reference data not domain invariant)
10. **Defer anthropic_api_to_subagent refactor to separate harness sub-plan** — REJECTED (AQ-6 + RM6; refactor naturally bundles with sub-plan 031 E.3 work touching same file; deferring = touch same file twice = churn)
11. **Charter amendment SHIP this plan** — REJECTED (CLAUDE.md hard rule; § K Charter-tier-surface FLAGS only, not amendments)
12. **Bundle Phase F-prime entry into this Phase E master plan** — REJECTED (§ A.3 + § M; Phase F-prime is independent master-plan; parallel-dispatch eligible from S363+)

## Charter-tier flags surfaced this session

**At master-plan-level**: **NONE**. Theme I as scoped satisfies all 11 charter principles + 35+ I-S<N> invariants by construction (per § K.1 audit of Rule 6/7/16 + I-S1/2/20/22/34/35).

**Anticipated at sub-plan-level** (per § K.2 — sub-plan STEP 0s watch for):
- Sub-plan 029: library license GPL3+ → user ratification gate per AQ-10
- Sub-plan 030: corpus labelling source = LLM-bootstrap → potential Rule 6 sampling exception for calibration-meta sampling
- Sub-plan 030: lexicon calibration <50% accuracy → potential Rule 7 5-class amendment (highly unlikely)
- Sub-plan 031: anthropic_api_to_subagent refactor → harness issue not charter
- Sub-plan 031: LLM-numeric drift via mentioned_pump_anchors interpretation creep → I-S1 violation surface → mandatory FLAG if surfaced
- Sub-plan 032: alias table ambiguous mappings (e.g. "VIN" → Vingroup vs Vinaconex) → potential NEW Rule 17 entity-ambiguity-disambiguation discipline (likelihood low)

**Ratification path** per § K.3: sub-plan STEP 0 STOP-AND-ASK → main session AskUserQuestion → ADR proposal/ tier → cool-down → constitution amendment landed by separate user-ratified PLAN+IMPL pair.

## S361 dev budget recommendation

**NOT APPLICABLE directly** — S361 is next sub-plan AUTHOR session (sandwich-architect dispatch for sub-plan 029 E.1 Tokenization), NOT a dev session. S361 = sub-plan 029 PLAN authoring (50-80K Opus per CLAUDE.md § Session Types).

**S362 = first dev session for Phase E** (sub-plan 029 IMPL):
- Budget: **100-150K Opus FOCUSED_IMPL** (cold-start envelope per agent-template L65 + plan-025 DD-6)
- Sub-plan 029 IMPL ships: `packages/infrastructure/nlp/vn_tokenizer.py` + port + test + pyproject.toml dep-add + D-070 ADR; estimated wall 25-40 min
- Phase 1b for S362 inherits precedent from THIS master plan + crawler-adapter-impl n=3 as nearest analog (NDH ~31min Sonnet ~116K; Vietstock ~36min Opus ~34K)

## Phase E → F-prime → G-prime → H-prime sequencing recommendation

Per § M:

1. **Phase E (now)**: 12-16 sessions wall-clock; parallel-dispatch saves ~1-2 sessions (sub-plans 031+032 parallel post-E.2 ship)
2. **Phase F-prime (parallel from S363+)**: dispatch F-prime master-plan author in parallel with Phase E sub-plan 030 PLAN authoring (architect-tier parallel-dispatch per plan-025 + S345 4-parallel validation); F-prime is independent file scope
3. **Phase G-prime (deferred)**: trigger = Phase 2 entry per master plan § 6.4.4
4. **Phase H-prime (deferred)**: trigger = Phase 2 dashboard work entry per master plan § 6.4.5

**Total wall-clock projection**: Phase E + F-prime cumulative ~10-12 turns to dual-close at full-autonomous cadence.

## Commits expected this turn

This master-plan authoring session ships 2 files:
1. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (the master plan; ~880 LOC)
2. `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (this observation; ~200 LOC)

Architect has NO Bash tool — main session commits per D-060 + pre-dispatch-architect-commit-guard.sh hook recovery pattern (precedent: S335/S337/S340/S341/S343/S346/S353/S356).

## Lessons surfaced this session (candidate AP-23 first-instance HOLD)

- **L-S360-1** (first instance; AP-23 HELD-FOR-PROMOTION on 2nd recurrence): **Phase-master-plan-decomposition pattern** — when phase-entry brief gives architect-choice between single-multi-sub-track plan vs master-plan-decomposition, architect should default to master-plan when (a) sub-theme count ≥3, (b) cumulative IMPL budget exceeds MULTI-TASK ceiling, (c) sub-themes have distinct external-library / corpus / file-scope. Promotion candidate: codify in `agent-workspace/agent-notes.md` as routing heuristic.
- **L-S360-2** (first instance): **Phase 1b cold-start incremental calibration** — bundling cold-start work loses incremental calibration feedback; per-theme PLAN sessions let calibration go n=0 → n=1 → n=2 → n=3 across sub-plans = better than single-shot. Promotion candidate: extend plan-025 DD-11 to explicitly note cold-start incremental-calibration preference.
- **L-S360-3** (first instance): **Anticipated-FLAGS pre-enumeration in Charter-tier-surface** — § K.2 explicitly enumerates anticipated sub-plan FLAGS so sub-plan STEP 0s know what to watch for (vs requiring sub-plan author to re-discover). Promotion candidate: codify as master-plan template field.

All 3 candidates AP-23 HELD-FOR-PROMOTION at first-instance per Charter Principle 11 + CLAUDE.md ritual-demotion calculus.

## Compliance attestation (architect S360)

- harness_priority_one ✓ (no harness fix in this session; L-S354-2 carry-forward NOTED in calibration but explicitly deferred per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies)
- AP-5 ✓ (re-read 24 binding sources at session entry via VBW protocol — see Phase 1b list above)
- AP-7 ✓ (every DEFER in plan § A.3 + § J names prerequisites + revisit triggers — zero naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations; 3 candidate lessons FLAGGED for first-instance HOLD)
- D-060 ✓ (architect has no Bash; main session commits per pre-dispatch-architect-commit-guard.sh hook)
- 0 charter writes ✓
- 0 constitution writes ✓
- 0 human-workspace writes ✓
- 0 production code ✓ (architect PLAN-only)
- I-S1 ✓ (plan PROMOTES I-S1 satisfaction)
- I-S2 ✓ (every claim cites source file:line per § H 5-source-evidence chain)
- I-S34 ✓ (Theme I uses existing 4 VN adapters; HARD REJECT carried forward)
- I-S35 ✓ (Theme I = research-aid signals not recommendations)
- Phase 1b CONSUMED + COLD-START explicit per § A.4
- 5-source-evidence chain populated per § H (5 decisions × 5 sources = 25 citations)

---

**END OF OBSERVATION sandwich-architect-S360-phase-e-vietnamese-nlp-plan**
