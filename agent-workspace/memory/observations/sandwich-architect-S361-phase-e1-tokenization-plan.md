---
observation_id: sandwich-architect-S361-phase-e1-tokenization-plan
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
target_session: S362 (dev FOCUSED_IMPL) + S363 (verifier AP-1)
verifier_session: S363 sandwich-verifier AP-1 (fresh-context post-S362 dev close)
phase_milestone: E.1 Vietnamese Tokenization — FIRST sub-plan of Phase E master plan-028 (per § E sequencing)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template line 5; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START EXPLICIT (task_class="vietnamese-nlp-impl" n=0 sample; nearest analog crawler-adapter-impl n=3 NOT comparable shape — adapter-shape vs tokenizer-wrapper-shape)
plan_type: FOCUSED_IMPL sub-plan (4 sub-tracks D1-D4; first of 4 sub-themes per parent master plan-028 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN; sub-plan 029 satisfies its § E.1 contract per DD-3 DEPENDENCY-EVAL pattern)
---

# S361 sandwich-architect — Phase E.1 VN Tokenization sub-plan-029 authoring observation

## What was authored

`agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md` — FOCUSED_IMPL sub-plan for Phase E sub-theme E.1 Vietnamese tokenization, decomposing into 4 sub-tracks (D1 port + D2 adapter + D3 tests + D4 CLI smoke) with DEPENDENCY-EVAL STEP 0 pattern (per parent plan-028 DD-3) gated by CHARTER-TIER GATE STOP-AND-ASK for GPL-3.0 license posture (per parent plan AQ-10 + § K.2).

**Plan stats** (architect-internal):
- Total LOC: ~820 (within 50-80K Opus PLAN budget; well-grounded in 26 VBW-read source files)
- 6 DD architecture decisions (DD-1..DD-6) all pre-answered with rationale + adversarial alternates
- 4 sub-tracks D1-D4 in § E with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 33 DC DoD items (≥25 floor satisfied)
- 8 AQ pre-answered (AQ-1..AQ-8)
- 5-source-evidence chain (5 decisions × 5 sources = 25 citations) in § H
- 8 RM entries (RM1..RM8) with mitigation in § J
- **STEP 0 STOP-AND-ASK trigger inventory** with 6 documented triggers (3 from dispatch brief + 3 architect-added per AP-7 + Karpathy P1)
- **§ M CHARTER-TIER GATE clause** as canonical reference for S362 dev
- **§ L Conditional next-step** with 4 branches L.1-L.4 covering all post-gate paths

## Key architectural decisions (DD-1..DD-6 summary)

| DD | Decision | Pre-decided or CONDITIONAL? |
|---|---|---|
| **DD-1** | **TokenizerProtocol = Protocol (NOT ABC)** | PRE-DECIDED (mirrors existing LlmExtractorPort at llm_extractor_port.py:28 precedent + Karpathy P2 simplicity) |
| **DD-2** | **Library selection (underthesea / pyvi / WhitespaceTokenizer)** | **CONDITIONAL on STEP 0.5 user ratification** — architect DOES NOT pre-decide library (Charter Principle 8 + GPL-3.0 charter-tier surface) |
| **DD-3** | **Adapter location = `packages/infrastructure/nlp/vn_tokenizer.py`** (port at `packages/application/nlp/ports/`) | PRE-DECIDED per parent plan-028 DD-7 (NEW cross-BC `application/nlp/` namespace) |
| **DD-4** | **Test fixtures = synthetic inline VN text** (NOT gitignored real corpus) | PRE-DECIDED per BSD-3 attribution risk lesson from S358 VietnamBiz F1 inline-remediation + reproducibility |
| **DD-5** | **Caching / memoization = DEFER to E.3 consumer** | PRE-DECIDED per Karpathy P2 simplicity (no premature optimization) |
| **DD-6** | **Type stubs = `cast` + `type:ignore` first; vendor minimal stub at n≥3** | PRE-DECIDED per mypy --strict + disallow_any_explicit (pyproject.toml:95-101) |

**Single most important callout**: **DD-2 CONDITIONAL library selection** — this is the entire architectural rationale for STEP 0 being BLOCKING. Architect REFUSES to pre-decide library because (a) license posture is charter-tier (user pick mandatory), (b) quality is empirical not assumed, (c) STEP 0 eval is cheap relative to wrong-choice rework cost.

## Phase 1b self-calibration (CONSUMED variant; COLD-START EXPLICIT)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `.claude/agents/sandwich-architect.md` (full read 252 LOC; agent template L42-65 Phase 1b cold-start path + L207-210 observation mandate + L110-120 sub-track 3 mandatory fields)
2. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 carry-forward — planner-feedback-loop.sh STILL has not auto-populated after S354/S357/S360 dogfood cycles)
3. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read first 50 rows; schema lacks task_class column; cannot key cleanly to vietnamese-nlp-impl task_class)
4. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 INLINE-RESOLVED UTC+7 fix / M-S354-NONE / M-S342-1 medium / M-S341-1 low; **no VN-NLP-impl-specific failure pattern history**)
5. `agent-workspace/memory/current-execution.md` (first 100 LOC; INCIDENT+RECOVERY + BEHAVIORAL HOLD + Wave 0 substrate progress + Wave 1 Phase D Theme L closed)
6. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; 3-chunk full read covering §s A/B/C/D/E/F/G/H/J/K/L/M/N/P)
7. `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (parent observation; full read 200 LOC; DD-1..DD-10 reasoning + Phase 1b cold-start declaration + Charter-tier flags surfaced + 3 candidate lessons L-S360-1/2/3)
8. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (Grep'd lines 246-267; underthesea/pyvi/cli-tool comparison + sub-deliverables + license/Phase 4+ deferral references including GPL-3.0 mentions for NarratoAI/MoneyPrinter family)
9. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum)
10. `packages/domain/news/models/news_article.py` (full read 73 LOC; NewsArticle + Rule 8 + mentioned_tickers coarse-scan comment at L38-42)
11. `packages/domain/news/services/claim_extraction_service.py` (full read 70 LOC; LlmExtractorProtocol contract — TokenizerProtocol mirror)
12. `packages/infrastructure/news/claude_llm_extractor.py` (offset 1-100 read; ClaudeLlmExtractor system prompt VN-language explicit + anthropic SDK direct import at L84 carry-forward to E.3 sub-plan 031)
13. `packages/application/news/ports/llm_extractor_port.py` (full read 50 LOC; LlmExtractorPort Protocol shape — TokenizerProtocol mirrors)
14. `packages/application/news/ports/crawler_adapter.py` (offset 1-80 read; CrawlerAdapter ABC pattern + license header style)
15. `apps/_shared/crawl/__init__.py` (full read 24 LOC; crawl shared utility namespace pattern — REJECTED for tokenizer per DD-3 different-layer-concern)
16. `apps/_shared/crawl/rate_limiter.py` (offset 1-50 read; per-file BSD-3-style attribution header + D-059 compliance comment pattern)
17. `packages/infrastructure/news/cafef_scraper.py` (offset 1-80 read; ScrapedArticle + body_text field — input shape for tokenizer)
18. `pyproject.toml` (full read 195 LOC; current dep stack — confirmed NO underthesea/pyvi/torch/transformers; license="Proprietary"; mypy strict + disallow_any_explicit; pytest config; ruff config)
19. `.claude/skills/crawler-reliability/SKILL.md` (offset 1-100 read; DEPENDENCY-EVAL pattern precedent — Adapter Storage Discipline § L-S345-3 n=3 promotion; transferable rhythm even though crawler vs NLP shapes differ)
20. `agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md` (offset 1-150 + 700-900 read for sub-track decomposition format + DC schema reference)
21. `agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md` (offset 700-1000 read for D1-D5 parallel_with field examples)
22. Glob `apps/_shared/**/*.py` (12 files confirmed; no nlp subdir yet — clean baseline)
23. Glob `packages/application/**/*.py` (54 files confirmed; application/nlp/ NEW namespace per DD-7)
24. Glob `data/raw/news/**/*.html` (5 article files confirmed: 2 NDH + 2 Vietstock + 1 VietnamBiz; CafeF NOT persisted)
25. Glob `**/nlp/**` (0 matches confirmed — packages/infrastructure/nlp/ + packages/application/nlp/ both NEW directories)
26. Grep `underthesea|pyvi|phobert|vn_tokenizer|VnTokenizer` across repo (10 matches all in agent-workspace docs/observations; ZERO production code references; clean baseline)
27. Grep `underthesea|pyvi|GPL-3|GPL3` in supplement § Theme I (confirmed underthesea+pyvi pair mention at supplement line 249; GPL-3.0 family mentioned for MoneyPrinter family but NOT underthesea-specific)
28. Grep `STEP 0\.|library evaluation` in plan-020 (confirmed DEPENDENCY-EVAL precedent format at plan-020 § STEP 0 for crawl4ai/Scrapling/MediaCrawler eval)

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (NEW class — no precedent)
- **sample_size**: **0** (cold-start declared explicit)
- **avg_wall_min**: N/A cold-start; full 100-150K envelope honored per agent-template L65
- **avg tokens_real**: N/A cold-start; nearest-shape precedent = library-wrapper code at apps/_shared/crawl/ shipped under W0-3 (~70K Sonnet for ~140 LOC wrapper + 200 LOC tests; tokenizer is similar shape)
- **parallel_hit_rate empirical**: 0% (no .planner-stats population; L-S354-2 gap)
- **parallel_hit_rate declared**: D3+D4 parallel post-D2 ship; 2-parallel ≤ 3-ceiling per plan-025 DD-5
- **failure_mode frequency**: N/A cold-start; nearest analog crawler-adapter-impl n=3 shows 1 IMPORTANT defect per cycle all INLINE-RESOLVABLE
- **Adjusted budget for THIS plan**: 50-80K Opus PLAN (per CLAUDE.md § Session Types PLAN envelope)
- **Adjusted budget for S362 dev**: 100-150K Opus FOCUSED_IMPL (cold-start defaults per plan-025 DD-6 + agent-template L65) with +5-10K reserve if STOP-AND-ASK fires
- **Cold-start?**: **YES EXPLICIT** (per agent-template L65 + plan-025 DD-11 mandate; both `.planner-stats.tsv` infrastructure gap AND first VN-NLP-impl-shaped work)

**Calibration verdict**: Phase 1b COLD-START EXPLICIT at task_class=vietnamese-nlp-impl with PARTIAL infrastructure observation (.planner-stats.tsv header-only). Architect honors Karpathy P1 calibration over confidence by NOT manufacturing crawler-adapter-impl n=3 as precedent (shape difference — adapter HTTP+selectors vs tokenizer text-transform makes adapter-precedent invalid for tokenizer-shape work). Full envelope absorption honored.

## STEP 0 STOP-AND-ASK triggers detail (6 documented; 3 from dispatch + 3 architect-added)

| Trigger | Sub-step | Condition | User decision class |
|---|---|---|---|
| **(a) CHARTER-TIER GATE** | 0.5 | SELECTED library license = GPL-3.0 / AGPL / SSPL / copyleft | CHARTER-TIER (re-license OR pattern-port OR alternative) |
| **(b) all-fail-quality** | 0.3 | All 3 candidates <30% quality | SCOPE-TIER (WhitespaceTokenizer fallback OR PhoBERT cycle OR expand corpus) |
| **(c) corpus-too-small** | 0.3 | All 3 candidates within ±5% spread | TACTICAL-TIER (expand to ~150 articles) |
| **(d) I-S34 HARD-REJECT** | 0.6 | Transitive dep includes patchright/StealthyFetcher/etc. | TACTICAL-TIER (alternative lib OR defer) |
| **(e) non-determinism** | 0.7 | Tokenizer output differs across runs | TACTICAL-TIER (alternative lib OR defer) |
| **(f) corpus-expansion-failed** | 0.2 | Adapter CLIs fail to expand to n≥30 in 30-min budget | TACTICAL-TIER (thin-evidence OR defer OR alternative corpus) |

Dispatch brief specified 3 triggers; architect added 3 more per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding (surface ALL failure modes upfront).

## Charter-tier GPL-3.0 gate handling (the load-bearing decision)

**Surfacing path**:
1. STEP 0.5 (S362 dev) discovers SELECTED library license empirically (reads LICENSE file verbatim from installed package)
2. IF license = GPL-3.0/copyleft → S362 dev writes `human-workspace/notifications/STOP-FINDING-S362-underthesea-gpl3-license-gate.md` (template at § C STEP 0.5 of the plan; 3 options a/b/c enumerated)
3. S362 dev PAUSES at STEP 0.5 (does NOT proceed to D1)
4. Main session dispatches AskUserQuestion gate per CLAUDE.md hard rule "User prompt overrides ALL defaults"
5. User picks (a) ACCEPT GPL + re-license, (b) PATTERN-ONLY port, (c) USE pyvi alternative
6. User pick recorded in ADR D-070 § Authorization (which dev creates as part of D2)
7. S362 dev resumes per § L.2/L.3/L.4 branch matching user pick

**Architect recommendation** (per § C STEP 0.5 inline guidance):
- IF pyvi quality within 10% of underthesea: pick (c) — simplicity + license safety wins over marginal quality
- IF underthesea wins by >10% + project owner has commercial flexibility constraint: pick (b)
- IF underthesea wins by >10% + project owner accepts GPL-3.0: pick (a)

**Why this gate matters**: Adopting GPL-3.0 in StockForge (currently dep stack is Apache/MIT/BSD permissive + license="Proprietary" per pyproject.toml:7) = CHARTER-TIER decision (changes distributable posture). Architect REFUSES to pre-decide; user picks. This is the canonical "calibration over confidence" application.

## Why I rejected (architectural alternates considered)

1. **Pre-decide underthesea** for quality popularity → REJECTED (Charter Principle 8 + GPL-3.0 charter-tier surface; user MUST decide license)
2. **Pre-decide pyvi** for license safety → REJECTED (forecloses on quality eval; ignores empirical evidence; per Karpathy P1 think-before-coding "state assumptions; surface tradeoffs; push back when simpler approach exists")
3. **Pre-decide WhitespaceTokenizer** for simplicity → REJECTED (Karpathy P2 simplicity should ground in evidence not assumption; tokenization quality affects downstream E.2/E.3/E.4 budget)
4. **ABC over Protocol for TokenizerProtocol** → REJECTED (DD-1; Protocol is lighter; LlmExtractorPort precedent)
5. **`apps/_shared/nlp/tokenizer.py` instead of `packages/infrastructure/nlp/vn_tokenizer.py`** → REJECTED (DD-3; layer discipline mandates infra for port-backed adapter; apps/_shared/ is for orchestration helpers different concern)
6. **Real-corpus snapshot fixtures gitignored at `data/fixtures/`** → REJECTED (DD-4; non-reproducible tests + CI cannot run; defeats fixture purpose)
7. **`@functools.lru_cache` on tokenize method** → REJECTED (DD-5; premature optimization)
8. **Vendor type stubs upfront** → REJECTED (DD-6; premature; cast+type:ignore for n=1-2; vendor at n≥3 trigger)
9. **`Any`-typed return** → REJECTED (DD-6; pyproject.toml `disallow_any_explicit=true` blocks)
10. **`ignore_missing_imports = true`** for SELECTED lib in mypy overrides → REJECTED (DD-6; too broad; loses type safety on other-lib calls)
11. **Phase E PLAN+IMPL in single session** → REJECTED (CLAUDE.md hard rule "Never mix PLAN+IMPL"; this IS the sub-plan PLAN session; S362 = separate IMPL session)
12. **Bundle E.1 + E.2 sentiment lexicon into single plan** → REJECTED (parent plan-028 DD-2; distinct decision classes + file scopes + corpus regimes)

## S362 dev budget recommendation

**S362 = first sub-plan IMPL session for Phase E** (sub-plan 029 D1-D4 IMPL):
- Budget: **100-150K Opus FOCUSED_IMPL** (cold-start envelope per agent-template L65 + plan-025 DD-6)
- Reserve: +5-10K if STEP 0 STOP-AND-ASK fires (e.g. CHARTER-TIER GATE adds STOP-FINDING file authoring + user pick wait)
- Worst case: STOP-AND-ASK fires + user pick latency → S362 exits cleanly mid-STEP-0; re-dispatched after user-pick recorded
- Estimated wall: ~25-40 min (~3 min STEP 0.1 + ~8 min STEP 0.2 corpus expansion + ~10 min STEP 0.3-0.4 eval + ~3 min STEP 0.5-0.7 audits + ~3 min D1 + ~12 min D2 + parallel D3+D4 ~8 min) WITHOUT CHARTER-TIER GATE; +unknown wait IF gate fires
- Sub-plan 029 IMPL ships: packages/application/nlp/* + packages/infrastructure/nlp/* + apps/cli/tokenize_vn_text.py + pyproject.toml dep add (CONDITIONAL) + ADR D-070 + calibration scorecard + session log + observation; estimated total LOC ~500 production + ~250 tests

**Phase 1b for S362 dev inherits precedent from THIS sub-plan + (post-S363 verifier acceptance) provides n=1 sample to .planner-stats.tsv for vietnamese-nlp-impl task_class — incremental calibration begins (n=0 → n=1 → n=2 → n=3 across sub-plans 029/030/031/032 per parent L-S360-2).**

## Lessons surfaced this session (candidate AP-23 first-instance HOLD)

- **L-S361-1** (first instance): **Sub-plan author inherits parent master plan FLAGS as MANDATORY surfacing path** — parent plan-028 § K.2 enumerated anticipated FLAGS for sub-plan STEP 0s; sub-plan 029 MUST cite + canonicalize the GPL-3.0 gate per § M CHARTER-TIER GATE clause; this is the contract between master plan and sub-plan. Promotion candidate: codify in sandwich-architect.md template as "sub-plan inheritance check from parent master plan § K".
- **L-S361-2** (first instance): **STOP-AND-ASK trigger enumeration MUST expand beyond dispatch brief minimum** — dispatch brief specified 3 triggers; architect added 3 more per AP-7 + Karpathy P1 (surface ALL failure modes upfront). Pattern: architect-tier expansion of dispatch-brief baseline. Promotion candidate: codify as "STEP 0 STOP-AND-ASK trigger expansion is architect's job not dispatch-brief's job".
- **L-S361-3** (first instance): **CHARTER-TIER GATE has its own § (§ M) as canonical reference for downstream agent** — sub-plan structure includes a dedicated § M CHARTER-TIER GATE clause so S362 dev can quote-by-reference without re-deriving from § C STEP 0.5. Pattern: load-bearing decisions get their own canonical-reference section. Promotion candidate: codify as sandwich-architect.md template "load-bearing decisions get their own § for canonical reference".

All 3 candidates AP-23 HELD-FOR-PROMOTION at first-instance per Charter Principle 11 + CLAUDE.md ritual-demotion calculus (promote-or-retire on 2nd recurrence).

## Compliance attestation (architect S361)

- harness_priority_one ✓ (no harness fix in this session; L-S354-2 carry-forward NOTED in calibration but explicitly deferred per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies)
- AP-5 ✓ (re-read 26 binding sources at session entry via VBW protocol — see Phase 1b list above)
- AP-7 ✓ (every DEFER in plan § A.3 + § J names prerequisites + revisit triggers; 6 STOP-AND-ASK triggers all with named user decision class — zero naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations; 3 candidate lessons FLAGGED for first-instance HOLD)
- D-060 ✓ (architect has no Bash; main session commits per pre-dispatch-architect-commit-guard.sh hook)
- 0 charter writes ✓
- 0 constitution writes ✓
- 0 human-workspace writes ✓ (STOP-FINDING file is dev-conditional write at S362; not architect-S361 write)
- 0 production code ✓ (architect PLAN-only)
- I-S1 ✓ (plan PROMOTES I-S1 satisfaction — tokenizer is LLM-free by construction)
- I-S2 ✓ (every claim cites source file:line per § H 5-source-evidence chain)
- I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward)
- I-S35 ✓ (tokenizer = transform utility; no recommendation surface)
- Phase 1b CONSUMED + COLD-START explicit per § A.4
- 5-source-evidence chain populated per § H (5 decisions × 5 sources = 25 citations)

---

**END OF OBSERVATION sandwich-architect-S361-phase-e1-tokenization-plan**
