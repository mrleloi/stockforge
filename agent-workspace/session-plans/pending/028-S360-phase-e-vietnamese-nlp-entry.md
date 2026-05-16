---
plan_id: 028-S360-phase-e-vietnamese-nlp-entry
target_session: S360 (THIS PLAN — Phase E master plan; further per-theme PLAN sessions dispatched per § L decomposition)
type: PHASE-MASTER-PLAN (decomposes Phase E into 4 follow-on PLAN+IMPL+VERIFY chains; NOT a single FOCUSED_IMPL plan per CLAUDE.md § Session Types "never mix PLAN+IMPL")
budget: master-plan authoring envelope ~60-100K Opus PLAN (THIS SESSION — architect); subsequent per-theme PLAN sessions ~50-80K each; per-theme IMPL sessions ~100-150K each (Phase 1b calibrated where precedent exists; cold-start otherwise)
phase: E (Theme I — Vietnamese NLP entry; FIRST master-plan after Phase D Theme L FULLY DONE at S358 4/4 VN sources shipped CafeF+NDH+Vietstock+VietnamBiz)
track: Wave 1 Theme I — VN tokenization + sentiment + claim extraction + ticker resolution (BC-5 News Stream extractor pipeline + BC-6 Influence + BC-7 Crowd; per master plan § 5.4 + § 6.4.2)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.4 + § 6.4.2 (Phase E unlocks post-Phase D close; depends on Theme L crawling output)
predecessor: 027-S356-phase-d-vietnambiz-adapter (VietnamBiz adapter shipped+verified S357-S358; Phase D Theme L FULLY DONE 4/4 VN sources; D-066 REV-3 amendment landed; n=3 SelectorChain[T] consumer threshold validated; L-S345-3 PROMOTE-NOW skill update fired post-S358 verifier-confirm)
successor: TBD — per § L decomposition four follow-on per-theme plans 029/030/031/032 (theme-by-theme PLAN → IMPL → VERIFY chains; tentatively S361/S363/S365/S367 per-theme entry sessions; verifier sessions interleaved; sequencing per § J + § L)
architect: S360 sandwich-architect (background; this PHASE-MASTER-PLAN)
dispatched_by: main session orchestrating Phase E entry per CLAUDE.md § Session Types phase-master-plan-first discipline + dispatch brief 2026-05-16 architect-decision = PHASE-MASTER-PLAN recommended
authored: 2026-05-16
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **COLD-START declared** for task_class="vietnamese-nlp-plan" per L-S354-2 carry-forward — no precedent in .planner-stats.tsv or sessions-rollup.tsv for VN-NLP-shaped work)
executing_agent: N/A this session (architect); subsequent per-theme dispatches per § L
status: pending-execution (Phase E master plan ratification path; main session reviews + dispatches first follow-on plan-029 per § L sequencing)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "D-066 + REV-1 + REV-2 + REV-3 (CrawlerAdapter ABC contract; all 4 VN sources CafeF/NDH/Vietstock/VietnamBiz registered + tested in Phase D Theme L; Theme I consumes their NewsArticle output as its data substrate)"
  - "D-061 (Wave-1 integration ratification — § Decision item 7 ratified Theme I VN-NLP entry as Phase E master-plan entry-point; § Decision item 4 Scrapling Cloudflare-solver HARD REJECT carries forward to ANY HTTP fetcher Theme I introduces for corpus collection)"
  - "D-065 (Theme G I-S1-1 Rule 16 numeric-field discipline — BINDING for ANY new schema field Theme I introduces; sentiment scoring particularly close to the LLM-numeric-field tripwire — see § Charter-tier-surface)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under Phase E sub-plans)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for each sub-plan dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any corpus/lexicon/calibration writes via tmp+os.replace pattern)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code in any Theme I sub-plan)"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks — THIS plan is master-plan but each follow-on per-theme plan MUST consume Phase 1b at dispatch)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VN-specific NLP IS the moat; OpenAI text-embedding-3-small is the documented baseline at architecture.md:129 but charter says 'works for Vietnamese — acceptable but not optimized'; Theme I is the optimization investment) + Principle 7 (Dogfood — each sub-plan dev MUST self-use the lexicon/extractor on real CafeF/NDH/Vietstock/VietnamBiz corpus) + Principle 8 (Calibration over confidence — sentiment lexicon weights MUST be calibrated against labelled corpus NOT hand-tuned per A-14 § 7.8 anti-pattern) + Principle 9 (NO LLM math — sentiment scoring is rule-based deterministic lexicon; embedding-based fallback is interpret-only; see § Charter-tier-surface for the tripwire) + Principle 11 (firing-test mandate for any hook shipped — IF Phase E ships hooks, companion firing-tests mandatory)"
  - "I-S1 (NO LLM math) + I-S1-1 (Rule 16 numeric-field discipline) + I-S2 (citation discipline — source_url + as_of + extracted_at on every claim) + I-S20 (calibration over confidence — sentiment weights MUST trace to labelled-corpus accuracy not LLM 'feeling certain') + I-S22 (data lineage) + I-S34 (robots.txt + reasonable rate limits + HARD REJECT of patchright/playwright_stealth — N/A for NLP per dispatch brief; but if Theme I introduces ANY new corpus-collection HTTP fetcher, the HARD REJECT carries forward) + I-S35 (research-aid framing — sentiment scores are SIGNALS not RECOMMENDATIONS; no 'buy/sell' single-action outputs)"
  - "Rule 6 (LLM Output Provenance — every ExtractedClaim emitted by Theme I extractor preserves source_url + source_text_excerpt verbatim quote + extractor_metadata bundle) + Rule 7 (sentiment categorical 5-class StrEnum — already shipped at packages/domain/news/value_objects/sentiment.py:19-30; Theme I scoring layer MUST NOT bypass this categorical contract OR aggregate numerically without explicit deterministic formula) + Rule 8 (anti-look-ahead — Theme I corpus collection MUST preserve published_at ≤ ingested_at carried through) + Rule 16 (numeric-field discipline — sentiment score numeric output goes through deterministic lexicon NOT LLM-generated)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline — prompt caching for system prompt amortization; structured-output JSON contract)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (already cited for Phase D Theme L; carries forward IF Theme I introduces corpus-collection HTTP fetchers; reuse existing 4 VN adapters NOT new crawlers per dispatch brief Theme I sub-themes)"

binding_decisions:
  - "PHASE-E AS PHASE-MASTER-PLAN (NOT single multi-sub-track FOCUSED_IMPL) — per dispatch brief architect-decision-rationale § L; CLAUDE.md § Session Types 'never mix PLAN+IMPL'; precedent: Wave 0 substrate = 5 W0-N sub-waves each = own PLAN+IMPL session; Phase D Theme L = 4 per-source sub-plans (plan-020/022/026/027) each = own PLAN+IMPL+VERIFY chain — Phase E = 4 per-theme sub-plans following the same architectural rhythm"
  - "TASK-CLASS COLD-START DECLARED — Phase 1b Calibration summary for THIS master plan explicitly cites COLD-START on .planner-stats.tsv task_class='vietnamese-nlp-plan' per L-S354-2 carry-forward (no precedent; first VN-NLP-shaped work in StockForge); follow-on per-theme plans 029-032 may inherit precedent from 028 once first dev cycle ships"
  - "D-060 — agent MAY git commit (NOT push); each per-theme plan dev decides commit boundary independently"
  - "AP-23 promote-or-retire — applied to first-instance: any new sentiment lexicon weight calibration approach is PROPOSED at IMPL tier with revisit trigger after 3 labelled-corpus retraining cycles or n=200 calibration sample (whichever comes first)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item in this plan + sub-plans names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "I-S1-1 BY-CONSTRUCTION posture for Theme I sentiment scoring — sentiment SCORE numeric value IS computed (it's not pure categorical), so Rule 16 satisfaction = mode 2 (deterministic-pipeline echo) — LLM never produces the score number; lexicon function does; LLM can interpret/explain the score but never echo a different number than the deterministic computation (EchoValidator enforces if added later)"
  - "VBW protocol mandatory — every sub-plan author must READ TradingAgents-CN `providers/china/akshare.py:1497-1611` empirically + the relevant VN NLP library source (underthesea / pyvi / PhoBERT) NOT memory; cite file:line for every architectural claim"
  - "Karpathy P3 surgical-changes — each sub-plan adds ≤500 LOC production code per sub-track; if a sub-track grows >500 LOC architect MUST split it further"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; this is master-plan authoring)"
  - "no commits in THIS plan-session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching Phase D Theme L files — all 4 VN adapters + 6 primitives shipped + verified; Theme I CONSUMES their NewsArticle output, does NOT modify their adapters"
  - "no Theme F-prime / G-prime / H-prime entry from THIS plan — those are independent Phase F-prime / G-prime / H-prime master-plans per master plan § 6.4; this plan ONLY scopes Phase E Theme I"
  - "no Charter amendment SHIP from THIS plan — IF Theme I surfaces a Rule-16 LLM-numeric-emit tripwire OR a new I-S<N> invariant need (see § Charter-tier-surface), this plan FLAGS it for separate user-ratification gate; the FLAG is not the AMENDMENT"
  - "no harness/hook changes — this plan ships product substrate (Theme I VN NLP); surface any harness gaps in observation; do NOT fix here. L-S354-2 (.planner-stats.tsv auto-population gap) belongs to harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward IF Theme I introduces ANY new HTTP fetcher for corpus collection (currently uses existing 4 VN crawler adapters per dispatch brief Theme I sub-themes — no new fetcher expected; verify at each sub-plan STEP 0)"
  - "If Phase E surfaces a charter-tier need (new I-S<N> invariant for sentiment scoring methodology / new Rule for VN-locale text handling), FLAG in § Charter-tier-surface for main session user-ratification gate dispatch"
---

# S360 — Phase E Theme I Vietnamese NLP Entry (PHASE-MASTER-PLAN)

> **One-sentence intent**: Decompose Phase E (Theme I — Vietnamese NLP) into 4 follow-on per-theme PLAN+IMPL+VERIFY chains covering tokenization, sentiment lexicon, claim extraction, and VN-specific ticker resolution — each chain ≤1 PLAN + 1-2 IMPL + 1 VERIFY session — without mixing PLAN+IMPL in the same session (CLAUDE.md hard rule), without LLM-emitting numeric sentiment scores (I-S1 + Rule 16), and without hand-tuned lexicon weights (Principle 8; A-14 § 7.8 anti-pattern explicit veto).

---

## A. Goal & Scope

### A.1 Goal (verbatim from master plan + dispatch brief)

Build the **Vietnamese NLP substrate** that lets StockForge interpret financial-news text in Vietnamese with:
- **Tokenization quality** comparable to or better than naive whitespace+regex (today's `mentioned_tickers` coarse scan is exactly that — see `packages/domain/news/models/news_article.py:38-42` comment "coarse keyword scan performed at ingest time (CLI grep over title + excerpt against the UL universe)")
- **Sentiment scoring** that is rule-based deterministic (categorical 5-class per Rule 7 already + numeric intensity score per the lexicon-weight pattern in TradingAgents-CN `providers/china/akshare.py:1497-1611` BUT computed deterministically NOT LLM-emitted per Rule 16)
- **Claim extraction** quality that improves on today's `ClaudeLlmExtractor` (`packages/infrastructure/news/claude_llm_extractor.py`) by adding VN-tokenization preprocessing + VN-specific entity hints (e.g. "đội lái" cultural anchor → flag for pump-cluster signal in BC-7)
- **VN-specific entity recognition** that resolves `VHM` vs `vinhomes` vs `Vinhomes` vs `Công ty Cổ phần Vinhomes` to one canonical `Ticker("VHM")` — currently this is done ad-hoc in `_build_claim` at `claude_llm_extractor.py:177-180` via a 2-4 char uppercase filter which would miss the lowercase variants

### A.2 Scope (4 sub-themes per master plan § 5.4 + supplement § I.3)

This phase ships:

1. **Sub-theme E.1 — Vietnamese tokenization library evaluation + adoption** (target: `packages/infrastructure/nlp/vn_tokenizer.py`)
2. **Sub-theme E.2 — Vietnamese sentiment lexicon (rule-based deterministic)** (target: `apps/extraction/sentiment/vn_lexicon.py` per supplement § I.4 + companion calibration loop per Principle 8)
3. **Sub-theme E.3 — VN-specific claim extraction wrapper** (target: refactor `ClaudeLlmExtractor` to use E.1 tokenizer + E.2 lexicon hints + emit claims with `mentioned_pump_anchors: tuple[str, ...]` for BC-7 downstream)
4. **Sub-theme E.4 — VN ticker / entity resolver** (target: `apps/_shared/entities/vn_ticker_resolver.py` per supplement § I.4 — fuzzy match + alias table for VHM / vinhomes / Vinhomes / Công ty Cổ phần Vinhomes → `Ticker("VHM")`)

Each sub-theme = one downstream PLAN session (S361 / S363 / S365 / S367) authored by sandwich-architect + one IMPL session (S362 / S364 / S366 / S368) executed by sandwich-dev + one VERIFY session (sandwich-verifier AP-1) per the standard sandwich pattern.

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Phase F-prime Theme H (BC-8 multi-perspective primitives) | Independent master-plan; depends on Phase C Theme G ratification (already done D-065) but does NOT depend on Theme I output | Master plan § 6.4.3 trigger — after Phase E first IMPL cycle (i.e. after sub-theme E.1 ships) main session may dispatch Phase F-prime master-plan in parallel with sub-themes E.2+E.3+E.4 (architect-tier parallel-dispatch precedent set at S345 architect run = 4 in parallel; main session decision) |
| Phase G-prime Theme J (PDF + table extraction BC-2) | Phase 2+ work per master plan § 6.4.4; not on Phase 1 critical path; Theme I has no PDF dependency | Master plan § 6.4.4 trigger — Phase 2 entry; ~MVP gap depending on Phase 1 close |
| Phase H-prime Theme K (UX/Output — Streamlit dashboard polish) | Phase 2+ work per master plan § 6.4.5; not on Phase 1 critical path | Master plan § 6.4.5 trigger — Phase 2 dashboard work entry |
| Fine-tuned PhoBERT / underthesea-LSTM sentiment fallback | Sub-theme E.2 ships lexicon-based scoring FIRST per A-14 § 7.8 "rule-based, deterministic, reproducible — directly satisfies I-S1"; transformer fallback is E.2-V2 once labelled corpus reaches n≥500 calibration sample (Principle 8) | E.2-V2 trigger: lexicon coverage <50% on held-out corpus OR n≥500 labelled samples for fine-tuning |
| Full Vietnamese-financial-domain BERT fine-tune | Same as above; PhoBERT fine-tune is the lighter-weight fallback before custom BERT | Custom BERT fine-tune trigger: ONLY if PhoBERT fallback (E.2-V2) coverage <80% on financial-news subdomain |
| Charter amendment SHIP for any new I-S<N> invariant Theme I surfaces | If a new invariant needed, this plan FLAGS in § Charter-tier-surface; main session dispatches separate user-ratification gate; per CLAUDE.md hard rule "Never modify PROJECT_CHARTER.md without explicit human revision with version bump" + "Never modify files in `agent-workspace/constitution/` without explicit human approval" | Trigger: § Charter-tier-surface item flagged + main session AskUserQuestion dispatch path |
| New harness/hook for VN-text-handling linting | Belongs to harness-stabilization sweep, NOT product session | Harness sweep trigger: 2+ recurrences of VN-text-handling defects across IMPL sessions (AP-23 promote-to-hook calculus) |
| Async migration of VN extraction pipeline | Sync interface mirrors today's `ClaimExtractionService.process` synchronous loop (`packages/domain/news/services/claim_extraction_service.py:53-69`); async deferred per overall stack discipline | Async trigger: Phase 3 production-throughput gate when VN extraction becomes >5% of session time |
| Multi-language extension (English / Chinese / etc.) | VN-only is the moat per Charter Principle 4 (Proprietary data moat); cross-locale extension is anti-moat without clear business case | Trigger: explicit user directive for multi-locale OR market expansion beyond VN |
| Real-time streaming sentiment (vs batch ingestion) | Phase E ships BATCH; streaming = Phase 3+ via Redis Streams (already in stack per CLAUDE.md but not wired for BC-5 yet) | Trigger: Phase 3 entry + Redis Streams wired for BC-5 |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):
- `agent-workspace/memory/.planner-stats.tsv` (header-only at S360 entry; L-S354-2 carry-forward — planner-feedback-loop.sh STILL did not auto-populate after S354/S357 first+second dogfood cycles; **COLD-START on task_class="vietnamese-nlp-plan" declared** AND COLD-START on planner-stats infrastructure)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read last 30 rows window; schema = `session_n,session_id,ts_utc,tokens_real,tools_used,subagents,failure_codes,wall_min`; NO `task_class` column — cannot key cleanly to "vietnamese-nlp-plan" precedent; only task_class precedent in repo is "crawler-adapter-impl" n=3 NDH+Vietstock+VietnamBiz)
- `agent-workspace/memory/dispatch.jsonl` (read last 30 rows offset=200; agent_type="unknown-agent" predominantly — schema-population gap in older dispatch rows; recent rows since S324 have agent_type="sandwich-verifier" / "sandwich-architect" / "sandwich-dev" populated; no agent_type="vietnamese-nlp-anything" precedent)
- `agent-workspace/memory/mistake-log.md` (last 60 LOC digest read; M-S357-1 inline-resolved UTC+7 timezone fix / M-S354-NONE clean / M-S347-NONE clean / M-S342-1 medium verifier-fixture-cleanup carry-forward / M-S341-1 low LOC-overstate carry-forward — **no VN-NLP-specific failure pattern history**)
- `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` § 5.4 + § 6.4.2 (Phase E master plan source)
- `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § I.1-I.5 (Theme I integration analysis — TradingAgents-CN pattern citation + VN cultural-anchor list)
- `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` § 3.5 + § 3.6 (CN sentiment lexicon weight dict + KOL platform list — VN parallel adaptation source)
- `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` § 2 + § 3 (per-perspective Pydantic signal contract + deterministic-then-LLM split for Buffett-style confidence rubric)
- `packages/domain/news/value_objects/sentiment.py` (existing Sentiment StrEnum 5-class; Rule 7 already shipped — Theme I scoring layer MUST satisfy)
- `packages/domain/news/models/extracted_claim.py` (existing ExtractedClaim invariants; Rule 6 grounding mandate; ≤500 chars excerpt cap; entity-grounding mandate)
- `packages/domain/news/models/news_article.py` (existing NewsArticle; `mentioned_tickers` field; Rule 8 anti-look-ahead invariant)
- `packages/domain/news/services/claim_extraction_service.py` (existing service; LlmExtractorProtocol contract — Theme I extractor may need to subclass OR coexist)
- `packages/infrastructure/news/claude_llm_extractor.py` (existing ClaudeLlmExtractor; Anthropic SDK adapter with system-prompt-enforced JSON contract; **NOTE: this still imports `anthropic` directly — see anthropic_api_to_subagent memory rule; Theme I extractor refactor MUST follow Claude Code subagent dispatch pattern**)
- `agent-workspace/constitution/financial-data-protocol.md` (Rule 6 + Rule 7 + Rule 16 — binding for Theme I)
- `agent-workspace/constitution/architecture.md` § BC-5 + § BC-6 + § BC-7 (3 BCs Theme I touches; per master plan § 5.4 "Coverage: BC-5 News Stream extractor pipeline + BC-6 Influence + BC-7 Crowd")
- `agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md` (predecessor plan reference; sub-track decomposition shape for follow-on per-theme plans)

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-plan` (NEW — no precedent in tracking logs; first VN-NLP-shaped work in StockForge)
- **sample_size**: **0** (COLD-START on this task_class; closest precedent is `crawler-adapter-impl` n=3 but adapter-shape is NOT comparable to NLP-substrate-shape — different files, different external libraries, different validation regime)
- **avg_wall_min observed**: N/A cold-start; **adopting boilerplate Phase 1b cold-start envelope** per agent-template L65 "Cold-start (per AQ-5): if `.planner-stats.tsv` sample_size<3 for current task_class, Phase 1b gracefully degrades to default 100-150K budget; flag in calibration summary as 'cold-start'"
- **avg tokens_real**: N/A cold-start; estimating per closest analog = `crawler-adapter-impl` n=3 actuals (Vietstock S354 ~34K Opus / VietnamBiz S357 ~Opus-similar) + +30% uplift for NLP-substrate novelty (library evaluation overhead + corpus design overhead absent in adapter work)
- **parallel_hit_rate**: N/A cold-start; THIS master plan declares parallel_with FOR DOWNSTREAM sub-plans per § E (E.1 → E.2 sequential; E.3 + E.4 may run parallel post-E.2 ship); follow-on per-theme plans declare per-sub-track parallel_with per plan-025 contract
- **parallel_savings_avg**: N/A cold-start
- **failure_mode frequency**: N/A cold-start; nearest analog `crawler-adapter-impl` shows IMPORTANT defects n=1-2 per cycle all INLINE-RESOLVABLE; Theme I may surface MORE defects per cycle because library-evaluation + corpus-curation introduce more decision points than adapter scaffolding
- **Adjustment to default budget**: This master plan = ~60-100K Opus PLAN authoring (cold-start envelope); each follow-on per-theme plan envelope: PLAN 50-80K + IMPL 100-150K + VERIFY 30-60K = **180-290K per theme × 4 themes = ~720-1160K cumulative Phase E budget**
- **Cold-start?**: **YES** (explicit declaration per agent-template + plan-025 DD-11 mandate; both `.planner-stats.tsv` infrastructure gap AND first VN-NLP-shaped work)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):
- This master plan authoring: **60-100K Opus PLAN target ceiling** (per dispatch brief Budget: "~60-100K Opus PLAN (phase entry larger than per-adapter plans)")
- Per-theme PLAN (S361/S363/S365/S367): 50-80K each (per CLAUDE.md § Session Types PLAN envelope) — calibration cold-start so use full envelope
- Per-theme IMPL (S362/S364/S366/S368): 100-150K Opus FOCUSED_IMPL each (cold-start defaults per plan-025 DD-6/DD-11) — Phase 1b for THOSE sessions inherits precedent from THIS plan + prior crawler-adapter-impl n=3 as nearest analog
- Per-theme VERIFY: 30-60K Opus AP-1 fresh-context each (per CLAUDE.md § Session Types VERIFY envelope)
- **Cumulative Phase E budget envelope: ~720-1160K Opus across ~12-16 sessions** (4 PLAN + 4-8 IMPL + 4 VERIFY)

**PARALLEL OPPORTUNITY** (architect declaration for downstream sub-plans):
- E.1 (tokenization) is foundational — must ship FIRST; blocks E.2/E.3/E.4 (they all depend on having a tokenizer)
- E.2 (sentiment lexicon) consumes E.1 output (tokens for keyword matching); blocks E.3 (claim extractor needs lexicon)
- E.3 (claim extraction wrapper) consumes E.1 + E.2 outputs
- E.4 (ticker resolver) is INDEPENDENT of E.1/E.2/E.3 in principle (could use existing whitespace-split tokens) BUT mature ticker resolver benefits from E.1 tokenization quality — RECOMMENDED parallel with E.3 post-E.2 ship
- **Recommended sequencing**: E.1 sequential → E.2 sequential → (E.3 + E.4 parallel)
- Sub-plans 029/030 sequential; sub-plans 031/032 parallel-eligible per main session orchestration
- Per plan-025 DD-5 3-parallel ceiling applies to dev dispatch within a single sub-plan; cross-sub-plan parallel dispatch follows the same calculus

---

## B. In-scope / Out-of-scope (master-plan-level)

### IN-scope (this MASTER PLAN ships)

- **This master-plan markdown** (~800-1200 LOC; 4 sub-theme decompositions + per-theme DD pre-answered + recommended session sequencing + ratification path)
- **§ Charter-tier-surface FLAG** (if Theme I surfaces invariant gaps; FLAGS only — does NOT amend charter/constitution)
- **§ Sequencing recommendation table** (sub-plans 029/030/031/032; budget envelopes; parallel-with dispatch markers)
- **§ Phase E → F-prime → G-prime → H-prime sequencing recommendation** per dispatch brief return-summary item 6
- **Phase 1b CONSUMED variant with COLD-START explicit** (per plan-025 DD-11 mandate + agent-template L65 cold-start path)
- **5-source-evidence chain** citing TradingAgents-CN + ai-hedge-fund + underthesea + supplement § I + master plan § 5.4
- **Observation file** at `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (per agent-template L207-210 mandate; ~150-250 LOC)

### OUT-of-scope (DEFERRED — explicit non-goals)

- **Sub-plan AUTHORING** (only DECOMPOSITION + RECOMMENDED SEQUENCING; the actual sub-plan 029 for E.1 will be authored by a separate sandwich-architect dispatch when main session calls /session-start PLAN at S361)
- **Production code** (this is master-plan authoring; CLAUDE.md § Session Types — never mix PLAN+IMPL)
- **Charter / constitution / human-workspace writes** (out of scope per CLAUDE.md hard rules)
- **AskUserQuestion gate FIRING** (master-plan recommends gates in § Charter-tier-surface; main session DECIDES whether to fire)
- **Library installation / dependency-add to pyproject.toml** (sub-plan 029 STEP 0 evaluates underthesea vs pyvi vs Claude API VN-mode; dep-add lives in sub-plan 029 IMPL)
- **Corpus collection / labelling** (sub-plan 030 designs corpus-collection STEP 0 + labelling protocol; OUT of this master plan)
- **Fine-tuning OR transformer model training** (deferred per § A.3; lexicon-only first per A-14 § 7.8)

---

## C. STEP 0 — VBW Live Verification (this MASTER PLAN — light-touch; per-theme plans run own STEP 0)

This master plan's STEP 0 is light-touch (the heavy STEP 0s are per-theme — sub-plans 029/030/031/032 each ship their own VBW live verification):

### Sub-step 0.1 — Existing VN extraction pipeline state audit (VBW — completed inline)

- ✅ `packages/domain/news/value_objects/sentiment.py` — Sentiment StrEnum 5-class shipped at S?? per Rule 7; **categorical contract already in place; Theme I MUST NOT bypass**
- ✅ `packages/domain/news/models/extracted_claim.py` — ExtractedClaim with Rule 6 grounding mandate + ≤500 char excerpt cap + entity-grounding mandate shipped; **invariants already in place**
- ✅ `packages/domain/news/models/news_article.py` — NewsArticle with Rule 8 anti-look-ahead + `mentioned_tickers` coarse-scan field shipped; **coarse-scan is what Theme I E.4 ticker resolver REPLACES with smarter resolution**
- ✅ `packages/infrastructure/news/claude_llm_extractor.py` — ClaudeLlmExtractor Anthropic-SDK adapter shipped; system prompt enforces JSON contract with 5-class sentiment + ticker/sector entity-grounding; **NOTE: this adapter still uses `anthropic` SDK directly at line 84 — Theme I E.3 refactor MUST follow `anthropic_api_to_subagent` memory rule (Claude Code subagent dispatch, NOT direct SDK)**
- ✅ `packages/domain/news/services/claim_extraction_service.py` — ClaimExtractionService with LlmExtractorProtocol + per-article LLM dispatch loop shipped; **Theme I E.3 may add a TokenizerPreprocessorProtocol wrapper port — see § D DD-7**
- ✅ All 4 Phase D Theme L crawler adapters shipped (CafeF + NDH + Vietstock + VietnamBiz); **NewsArticle output feeds Theme I extraction pipeline; no Theme I modifications to adapter code**

### Sub-step 0.2 — VN NLP library landscape audit (VBW — completed inline per dispatch brief reference)

- **underthesea** — Python VN NLP library; tokenization + POS + NER; pip-installable; MIT or Apache; commonly cited as state-of-art VN tokenizer; STEP 0 of sub-plan 029 will pip-install + smoke-test on CafeF corpus
- **pyvi** — alternative VN tokenizer; lighter-weight; GitHub stars lower than underthesea; STEP 0 of sub-plan 029 evaluates as fallback
- **PhoBERT / VinAI** — transformer-based VN sentiment models; HuggingFace hosted; require torch + transformers (heavy deps); DEFERRED per § A.3 lexicon-first
- **Claude API VN-mode** — already in stack (per ClaudeLlmExtractor); the system prompt at `claude_llm_extractor.py:55-75` explicitly addresses Vietnamese-language input; cost = per-article LLM call (~$0.01-0.10 per article depending on Sonnet vs Opus); **Theme I E.3 leverages Claude for claim INTERPRETATION not for tokenization OR sentiment SCORING** (Rule 16 — LLM never emits sentiment numeric)
- **TradingAgents-CN PATTERN** — `providers/china/akshare.py:1497-1611` deterministic lexicon scoring (rule-based, reproducible, normalized [-1,1]) per A-14 § 3.5; **direct transferable PATTERN; the Chinese keywords must be REPLACED with Vietnamese ones (NOT machine-translated; hand-curated by domain expert i.e. project owner OR fine-tuned via labelled corpus per Principle 8)**

### Sub-step 0.3 — Available VN financial-news corpus inventory (VBW — completed inline)

Per dispatch brief item 6 + Glob result:
- ✅ `data/raw/news/ndh/2026-05-16/` — 2 HTML samples from S344 NDH adapter smoke
- ✅ `data/raw/news/vietstock/2026-05-16/` — 2 HTML samples from S354 Vietstock adapter smoke
- ✅ `data/raw/news/vietnambiz/2026-05-16/` — 1 HTML sample from S357 VietnamBiz adapter smoke
- ❓ `data/raw/news/cafef/` — NOT FOUND via Glob (CafeF smoke may have written to a different path OR was excluded from git; sub-plan 029 STEP 0 verifies)
- **Total corpus available**: ~5 articles at S360 entry; **insufficient for n=200-500 labelled-corpus calibration per Principle 8 + supplement § I.3 step 4**
- **Corpus expansion needed**: sub-plan 029 STEP 0 includes "run 4 VN adapter CLIs in `--max-articles 50-100` mode each" to expand to ~200-400 articles before sub-plan 030 sentiment lexicon calibration begins
- **Charter-tier consideration**: I-S34 (robots.txt + reasonable rate limits) applies to corpus expansion CLI runs — each adapter already enforces its rate-limit profile (CafeF/NDH/Vietstock 2.0s; VietnamBiz 3.0s); corpus expansion = ~400 articles × 2.5s avg = ~17 min wall-clock per source = ~70 min total cross-source (acceptable per existing rate-limit budget)

### Sub-step 0.4 — Rule 16 surface audit for Theme I (BINDING per § Charter compliance)

Theme I introduces these candidate schema fields where Rule 16 (I-S1-1) applies:
- **Sentiment intensity score** (per A-14 § 3.5 pattern: float in [-1.0, 1.0] computed by lexicon-weight summation + normalization) — **Rule 16 satisfaction mode 2 (deterministic-pipeline echo)**: lexicon function is deterministic Python code; LLM never emits this score; if LLM-extractor reads the score and includes it in its prose interpretation, it MUST echo verbatim (EchoValidator can enforce later)
- **Token-coverage ratio** (per E.2 calibration: float in [0.0, 1.0] = how many tokens in article body match lexicon keywords) — **Rule 16 satisfaction mode 2**: computed deterministically by tokenizer + lexicon lookup; no LLM involvement
- **Ticker resolution confidence** (per E.4: float in [0.0, 1.0] = fuzzy-match score for "vinhomes" → "VHM") — **Rule 16 satisfaction mode 2**: fuzzy-match algorithm deterministic; no LLM involvement
- **Pump-anchor flag** (per E.3: bool — does article body contain ≥1 of "đội lái" / "đu đỉnh" / "bắt đáy" / etc.) — bool not numeric so Rule 16 N/A; categorical surrogate trivially satisfied

**Verdict**: All 4 candidate numeric fields satisfy Rule 16 via mode 2 deterministic-echo. **No mode 1 (categorical) needed** because sentiment categorical is ALREADY shipped at Sentiment StrEnum. **No mode 3 (calibration lookup) needed yet** because sentiment scoring is computed not looked up. **No mode 4 (NULL surrogate) needed** because all 4 fields have deterministic computation paths.

**Charter-tier-surface FLAG**: If sub-plan 030 surfaces a new schema field where Rule 16 mode 2 cannot apply (e.g. "subjective sentiment strength" that requires LLM judgment), that's a Charter-tier-surface FLAG event — sub-plan 030 STEP 0 STOP-AND-ASK clause triggers. **No FLAG at this master-plan level — Theme I as scoped above satisfies Rule 16 by construction.**

### Sub-step 0.5 — anthropic_api_to_subagent memory-rule check

Per `anthropic_api_to_subagent` memory rule: "For every `ANTHROPIC_API_KEY` / direct `anthropic` SDK call: refactor to Claude Code subagent dispatch (subscription billing, not API metered); systemic rule".

- ✅ Existing `claude_llm_extractor.py:84` uses `import anthropic` direct SDK call (LEGACY — needs refactor)
- **Theme I E.3 sub-plan SHOULD refactor `ClaudeLlmExtractor` to use Claude Code subagent dispatch pattern** (separate sub-plan; not THIS master-plan)
- **Carry-forward as RM in § J**: RM-MR-1 (memory-rule refactor surface) — sub-plan 031 (E.3) MUST decide refactor-vs-coexist OR explicitly defer with named trigger

### Sub-step 0.6 — Existing related-pattern grep audit

- ✅ `Grep underthesea|pyvi|phobert` returns 8 matches — ALL in agent-workspace documentation files (observations / master-plans / supplements); ZERO production code references; **clean baseline for sub-plan 029 to add first production use**
- ✅ `Grep vn_lexicon|vn_ticker|VnLexicon|TickerResolver|ticker_resolver|stock_name_resolver` returns 3 matches — ALL in agent-workspace research files; ZERO production code references; **clean baseline for sub-plan 030 + 032 to add first production use**
- ✅ `apps/extraction/sentiment/` directory does NOT exist yet — sub-plan 030 creates it
- ✅ `apps/_shared/entities/` directory does NOT exist yet — sub-plan 032 creates it
- ✅ `packages/infrastructure/nlp/` directory does NOT exist yet — sub-plan 029 creates it

### Sub-step 0.7 — STEP 0 summary write (this master plan)

All 6 sub-steps PASS. No STOP-AND-ASK triggered. Master plan proceeds to § D architecture decisions.

---

## D. Architecture Decisions (DD-1 through DD-10)

### DD-1: Phase E is a PHASE-MASTER-PLAN, NOT a single multi-sub-track FOCUSED_IMPL

**Decision**: Author this as a PHASE-MASTER-PLAN that decomposes Phase E into 4 follow-on per-theme PLAN+IMPL+VERIFY chains (sub-plans 029/030/031/032). Each sub-plan = own PLAN session (50-80K Opus) + own IMPL session (100-150K Opus FOCUSED_IMPL) + own VERIFY session (30-60K Opus AP-1).

**Rationale**:
- **CLAUDE.md hard rule**: "Never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)" — bundling 4 sub-themes + their IMPL into one session = high-risk mix
- **Precedent**: Wave 0 substrate = 5 W0-N sub-waves each = own PLAN+IMPL session (W0-1 plan-012 / W0-1b plan-013 / W0-2 plan-014 / W0-3+4+5 plan-018 bundled = ONE exception that proved bundling-multi-tracks is high-risk per S332 surface 9 technical issues); Phase D Theme L = 4 per-source sub-plans (plan-020 CafeF / plan-022 NDH / plan-026 Vietstock / plan-027 VietnamBiz) each = own PLAN+IMPL+VERIFY chain — **Phase E follows the same rhythm**
- **Per CLAUDE.md § Session Types budget envelopes**: a single MULTI-TASK IMPL = 150-250K; 4 sub-themes at 100-150K IMPL each = 400-600K cumulative IMPL = clearly exceeds MULTI-TASK ceiling
- **Phase 1b cold-start risk**: bundling cold-start work into one session amplifies the cold-start risk per L-S354-2; per-theme PLAN sessions let each theme calibrate INCREMENTALLY (n=0 → n=1 → n=2 → n=3 for `vietnamese-nlp-plan` task_class)

**Adversarial alternate considered**: Single MULTI-TASK IMPL S361 covering all 4 sub-themes → REJECTED per CLAUDE.md hard rule + budget envelope + Phase 1b cold-start risk amplification.

### DD-2: Sub-theme decomposition = 4 sub-themes (E.1-E.4) NOT collapsed (E.1+E.2+E.3+E.4)

**Decision**: Maintain 4 distinct sub-themes per master plan § 5.4 + supplement § I.3 enumeration:
- E.1 = Tokenization
- E.2 = Sentiment lexicon
- E.3 = Claim extraction wrapper
- E.4 = Ticker resolver

**Rationale**: Each sub-theme has DISTINCT (a) external library evaluation surface, (b) file scope, (c) test scope, (d) calibration regime. Collapsing them risks (a) library-evaluation paralysis (under-evaluating one library while over-evaluating another), (b) coordination_paths_exclusive overlap across sub-tracks within single dev session, (c) test-coverage dilution. Per Karpathy P3 surgical-changes + plan-025 DD-5 3-parallel ceiling — 4 sub-themes split across 4 sub-plans = clean.

**Adversarial alternate considered**: Collapse E.1 (tokenization) + E.2 (sentiment lexicon) into single sub-plan since lexicon CONSUMES tokenizer output → REJECTED (tokenizer library evaluation is its own decision with its own STEP 0 evidence requirements; lexicon design is its own decision with its own corpus calibration requirements; coupling adds risk without saving meaningful budget — sub-plan 029 still BLOCKS sub-plan 030 sequentially per § E sequencing).

### DD-3: Sub-plan 029 (E.1) = Tokenization library evaluation + adoption — Strategy "DEPENDENCY-EVAL"

**Decision**: Sub-plan 029 follows a DEPENDENCY-EVAL pattern (NEW pattern in StockForge, different from Strategy A direct-subclass / Strategy B WRAP of Phase D Theme L):
1. STEP 0 evaluates underthesea vs pyvi vs naive whitespace-regex on a corpus subset (~50 articles from existing CafeF/NDH/Vietstock/VietnamBiz raw HTML)
2. STEP 0.4 selects ONE library based on (a) tokenization quality on financial-text fixtures (3-5 hand-crafted test sentences), (b) install + import cost, (c) license (MIT/Apache/BSD acceptable; GPL3+ requires user ratification)
3. IMPL ships `packages/infrastructure/nlp/vn_tokenizer.py` wrapping the selected library behind a `VnTokenizerProtocol` port (defined in `packages/application/nlp/ports/vn_tokenizer_port.py`) so future swap is cheap
4. Default fallback if both libraries fail STEP 0 quality bar: ship whitespace-regex baseline with explicit "DEFAULT-LOW-QUALITY" docstring + FLAG for sub-plan 029-V2 retry

**Rationale**: Library choice is the single biggest decision for Theme I (per dispatch brief item 3). DEPENDENCY-EVAL pattern parallels how Phase D Theme L plan-020 STEP 0 evaluated crawl4ai vs Scrapling vs MediaCrawler. Port-wrapping (DDD tactical pattern per `.claude/skills/ddd-tactical-patterns/SKILL.md`) lets us swap implementation cheaply if PhoBERT-fallback becomes E.1-V2.

**Adversarial alternate considered**: Skip evaluation and adopt underthesea unconditionally (it's the most-cited library in observations) → REJECTED (Charter Principle 8 calibration over confidence — adopt based on empirical evidence not popularity; STEP 0 evaluation is cheap relative to wrong-choice rework cost).

### DD-4: Sub-plan 030 (E.2) = Sentiment lexicon — Strategy "LEXICON-PATTERN-PORT + CALIBRATE"

**Decision**: Sub-plan 030 follows the PATTERN-PORT + CALIBRATE pattern from supplement § I.3 step 2:
1. Port the TradingAgents-CN PATTERN (rule-based lexicon weight dict + normalization formula) at `tradingagents/dataflows/providers/china/akshare.py:1497-1611` per A-14 § 3.5 citation
2. REPLACE Chinese keywords with Vietnamese hand-curated initial set (~200-500 keywords per supplement § I.3 step 2.a): tăng / giảm / lên giá / xuống giá / đột phá / lao dốc / cổ phiếu nóng / sàn / trần / cảnh báo / đình chỉ / lỗ / lãi / etc.
3. Weight by intensity per CN pattern (1.0 extreme / 0.5 moderate / 0.2 mild) BUT with INITIAL weights as hypothesis only — calibrate via labelled corpus per Principle 8
4. **Add VN-specific cultural anchors** (per A-14 § 7.3 + supplement § I.3 step 2.c): "lái" (price-manipulation) / "đội lái" (pump-group) / "đu đỉnh" (FOMO at top) / "bắt đáy" (catch the bottom) — these have NO CN equivalent and are essential for VN F0 retail-culture context
5. Calibration loop: collect ~200-500 manually-tagged articles (project owner can label OR fine-tune via small labelling UI); cross-validate lexicon weights via held-out subset; **lexicon weights MUST be calibrated from data NOT intuition** per A-14 § 7.8 anti-pattern explicit veto
6. Output: `apps/extraction/sentiment/vn_lexicon.py` module + `apps/extraction/sentiment/test_vn_lexicon.py` unit tests + calibration cycle recipe documented in `agent-workspace/calibration/vn_sentiment_lexicon_v0.md`

**Rationale**: Per supplement § I.3 + A-14 § 3.5 + Charter Principle 8. Rule-based deterministic = Rule 16 mode 2 satisfaction. Calibration = Charter Principle 8 satisfaction. VN cultural anchors = Charter Principle 4 (Proprietary data moat — VN-specific is the moat).

**Adversarial alternate considered**: Skip lexicon and go straight to PhoBERT fine-tuned VN-financial-sentiment classifier → REJECTED (per § A.3 deferral — PhoBERT is heavier deps + harder Rule 16 compliance; lexicon-first is calibration-friendly + interpretable + cheap; PhoBERT is E.2-V2 if lexicon coverage <50% on held-out corpus).

### DD-5: Sub-plan 031 (E.3) = Claim extraction wrapper — Strategy "EXISTING-EXTRACTOR-AUGMENT"

**Decision**: Sub-plan 031 AUGMENTS existing `ClaudeLlmExtractor` rather than replacing it:
1. Add `tokenizer: VnTokenizerProtocol` injection to `ClaudeLlmExtractor` constructor (default = whitespace-regex baseline if E.1 not yet shipped; production injection = E.1's adopted library)
2. Preprocessing step BEFORE LLM call: tokenize article body via injected tokenizer; pass token-list as additional system-prompt context ("Tokens: VHM, dự, kiến, đạt, lợi, nhuận, ...")
3. Add `lexicon: VnLexiconProtocol` injection (default = empty lexicon if E.2 not yet shipped; production injection = E.2's calibrated lexicon)
4. Post-LLM step: lexicon-score the extracted claim text; **the LLM's categorical sentiment label** (already shipped per Rule 7) is the canonical sentiment; the lexicon-score is a NUMERIC SIGNAL added as a NEW ExtractedClaim field `lexicon_score: float` (Rule 16 mode 2 deterministic-echo)
5. Add `mentioned_pump_anchors: tuple[str, ...]` field to ExtractedClaim per § A.1 — populated by deterministic regex match against the VN cultural anchor list from E.2
6. **anthropic_api_to_subagent refactor IN-SCOPE for this sub-plan** per § C.0.5 + RM-MR-1: replace direct anthropic SDK call with Claude Code subagent dispatch pattern

**Rationale**: ExistingExtractor-AUGMENT preserves backwards-compatibility (existing tests + existing CLI ingest_news_* all continue to work with default-empty injections) while adding the Theme I value-add when full production injections wire in. Per Karpathy P3 surgical-changes.

**Adversarial alternate considered**: Create a NEW `VnClaudeExtractor` parallel to existing `ClaudeLlmExtractor` → REJECTED (duplicate-class maintenance burden; the AUGMENT path is cleaner per DDD tactical patterns + L-S345-3-style precedent "single helper with keyword-only flag" preferred).

### DD-6: Sub-plan 032 (E.4) = VN ticker resolver — Strategy "FRESH-MODULE + ALIAS-TABLE"

**Decision**: Sub-plan 032 ships a fresh `apps/_shared/entities/vn_ticker_resolver.py` module with:
1. Static alias table mapping Vietnamese company names (Vietnamese + English variants + lowercase / uppercase / diacritics-stripped variants) to canonical `Ticker` per UL glossary (`agent-workspace/ubiquitous-language/glossary.md`)
2. Fuzzy-match fallback via standard library `difflib.get_close_matches` (no new external dep) for partial matches
3. Resolution confidence float in [0.0, 1.0] = `difflib.SequenceMatcher.ratio()` (deterministic; Rule 16 mode 2 satisfied)
4. Used by `ClaudeLlmExtractor._build_claim` (`claude_llm_extractor.py:177-180`) to REPLACE the current 2-4 char uppercase filter — wider entity capture for "vinhomes" / "Công ty Cổ phần Vinhomes" etc.
5. Test fixtures: known VN30 universe tickers (~30 tickers per Phase 1 universe) + alias variants

**Rationale**: Per supplement § I.4 + A-14 § 7.7 anti-pattern explicit veto ("don't repeat the duplicated hard-coded English-only company-name lookups across ~6 files anti-pattern"). Centralizing via shared utility from day 1 = cleaner than retro-fixing later.

**Adversarial alternate considered**: Use spaCy / fuzzywuzzy / rapidfuzz as fuzzy-match library → REJECTED (difflib is stdlib; no new dep; sufficient for n≤30 VN30 universe; revisit trigger: when VN universe grows to n>200 tickers + spaCy NER outperforms alias-table empirically).

### DD-7: TokenizerPreprocessor port location = `packages/application/nlp/ports/`

**Decision**: New port for VnTokenizerProtocol lives at `packages/application/nlp/ports/vn_tokenizer_port.py`. Mirrors existing structure of `packages/application/news/ports/llm_extractor_port.py`. The infrastructure adapter (E.1 sub-plan 029 IMPL) lives at `packages/infrastructure/nlp/vn_tokenizer.py`.

**Rationale**: DDD tactical pattern + existing precedent (BC-5 News Stream already has `application/news/ports/` for LlmExtractorPort + CrawlerAdapter; NLP is a cross-BC capability so it gets its own `application/nlp/ports/` per architecture.md cross-BC discipline). Theme I is shared substrate across BC-5 + BC-6 + BC-7 (per master plan § 5.4 coverage statement), so the port lives in application layer accessible across BCs.

**Adversarial alternate considered**: Co-locate VnTokenizerProtocol in `packages/application/news/ports/` since BC-5 is the primary consumer → REJECTED (Theme I serves 3 BCs not just BC-5; cross-BC import would violate architecture.md "Never direct import between BCs"; `application/nlp/` is a NEW cross-BC capability namespace and is the correct location).

### DD-8: VN sentiment lexicon module location = `apps/extraction/sentiment/`

**Decision**: VN sentiment lexicon module lives at `apps/extraction/sentiment/vn_lexicon.py` per supplement § I.4 explicit recommendation.

**Rationale**: Per supplement § I.4 "VN sentiment lexicon module under `apps/extraction/sentiment/vn_lexicon.py`". The `apps/` namespace is for application-tier orchestration code (CLIs + extraction pipelines + adapters wiring) per architecture.md; lexicon is a domain-knowledge artifact consumed by extraction code so `apps/extraction/sentiment/` is the correct location (not `packages/domain/` because lexicon is application-tier knowledge not domain invariant).

**Adversarial alternate considered**: Put lexicon in `packages/domain/news/lexicons/vn_sentiment_lexicon.py` → REJECTED (lexicon is application-tier knowledge that can change per market regime / corpus update; domain layer is for invariants; per DDD tactical patterns "lexicons are reference data, not domain rules").

### DD-9: VN ticker resolver location = `apps/_shared/entities/`

**Decision**: VN ticker resolver lives at `apps/_shared/entities/vn_ticker_resolver.py` per supplement § I.4 explicit recommendation.

**Rationale**: Per supplement § I.4. `apps/_shared/` is the cross-app shared utility namespace (precedent: `apps/_shared/crawl/` shipped at Phase D Theme L containing RateLimiter / RobotsTxtManager / RawHtmlSink / SelectorChain). Ticker resolver is similar cross-app shared utility.

### DD-10: Calibration database location = `agent-workspace/calibration/`

**Decision**: Sentiment lexicon calibration data + ticker resolver alias table + labelled corpus pointers all land in `agent-workspace/calibration/` per CLAUDE.md Key References "Calibration data: `agent-workspace/calibration/`".

**Rationale**: Per CLAUDE.md hard rule "Confidence claims must trace to historical hit rate, not to model 'feeling certain'" — calibration data is the source-of-truth for Charter Principle 8 satisfaction; `agent-workspace/calibration/` is the canonical location per CLAUDE.md.

---

## E. Sub-plan decomposition (sub-plans 029/030/031/032 — sequencing + parallel_with per plan-025 contract)

### Sub-plan 029 — E.1 Tokenization library evaluation + adoption

- **plan_id**: 029-S361-phase-e-vn-tokenization (target dispatch S361)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S362 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S363 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [] (BLOCKS E.2 + E.3 + E.4)
- **blocks_on**: [] (root sub-plan)
- **coordination_paths_exclusive**: [packages/infrastructure/nlp/vn_tokenizer.py, packages/application/nlp/ports/vn_tokenizer_port.py, packages/infrastructure/nlp/test_vn_tokenizer.py, pyproject.toml (one-line dep add)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 25-40 min / VERIFY 8-12 min
- **STEP 0 evaluation surface**: underthesea vs pyvi vs naive whitespace-regex on ~50-article corpus subset (corpus expansion CLI runs ARE in sub-plan 029 IMPL pre-flight)
- **DoD floor**: ≥10 unit tests; mypy --strict + ruff + pytest green; tokenizer benchmark recorded in sub-plan 029 observation
- **ADR landing**: D-070 PROPOSED at IMPL tier (per severity-schema auto-ratifies on commit) — "VN Tokenizer Library Selection"
- **Charter-tier touch**: NONE (library selection is IMPL-tier ADR; not constitution mutation)

### Sub-plan 030 — E.2 Sentiment lexicon (PATTERN-PORT + CALIBRATE)

- **plan_id**: 030-S363-phase-e-vn-sentiment-lexicon (target dispatch S363 OR later — after sub-plan 029 VERIFY ships)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S364 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S365 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [] (BLOCKS E.3; can run parallel with E.4 once E.1 ships)
- **blocks_on**: [029-S361-phase-e-vn-tokenization]
- **coordination_paths_exclusive**: [apps/extraction/sentiment/vn_lexicon.py, apps/extraction/sentiment/test_vn_lexicon.py, agent-workspace/calibration/vn_sentiment_lexicon_v0.md, data/corpus/vn_financial_news_labelled/* (labelling artifacts; NOT committed binary; gitignored)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 30-50 min (corpus labelling + cross-validation cycle slower than scaffolding) / VERIFY 10-15 min
- **STEP 0 evaluation surface**: corpus expansion (already-shipped CLI dispatches); initial keyword set hand-curation; CN-pattern citation + adaptation
- **DoD floor**: ≥15 unit tests (lexicon scoring + edge cases + cultural anchors); mypy + ruff + pytest green; labelled corpus n≥200 articles; cross-validation accuracy ≥70% on held-out subset; Rule 16 mode 2 compliance grep-asserted; calibration recipe documented
- **ADR landing**: D-071 PROPOSED at IMPL tier — "VN Sentiment Lexicon v0 + Calibration Loop"
- **Charter-tier touch**: NONE if lexicon scoring is mode-2 deterministic-echo (default plan); FLAG-CHARTER-TIER if calibration surfaces gap (see § Charter-tier-surface)

### Sub-plan 031 — E.3 Claim extraction wrapper (AUGMENT existing)

- **plan_id**: 031-S365-phase-e-vn-claim-extraction (target dispatch S365 OR later — after sub-plan 030 VERIFY ships; can dispatch parallel with sub-plan 032 once dependencies satisfied)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S366 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S367 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [032-S367-phase-e-vn-ticker-resolver] (CAN run parallel post-E.2 ship; main session orchestrates via plan-025 DD-5 3-parallel-ceiling-architect-tier validated at 4-parallel S345)
- **blocks_on**: [029-S361-phase-e-vn-tokenization, 030-S363-phase-e-vn-sentiment-lexicon]
- **coordination_paths_exclusive**: [packages/infrastructure/news/claude_llm_extractor.py (AUGMENT not replace), packages/domain/news/models/extracted_claim.py (add lexicon_score + mentioned_pump_anchors fields), packages/domain/news/test_models.py, packages/infrastructure/news/test_adapters.py (extractor tests extended)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 30-45 min (anthropic_api_to_subagent refactor adds complexity) / VERIFY 10-15 min
- **STEP 0 evaluation surface**: existing ClaudeLlmExtractor end-to-end pipeline; anthropic_api_to_subagent refactor decision (refactor in this sub-plan OR defer to separate harness sub-plan)
- **DoD floor**: ≥10 NEW unit tests (preprocessing + lexicon hint + pump-anchor flag + Rule 16 mode-2 echo); mypy + ruff + pytest green; existing extractor tests STILL green (regression floor); CLI smoke runs on 4 VN sources verifies end-to-end pipeline
- **ADR landing**: D-072 PROPOSED at IMPL tier — "VN Claim Extraction Pipeline v1"
- **Charter-tier touch**: NONE expected; FLAG if anthropic_api_to_subagent refactor surfaces unanticipated charter-tier issue

### Sub-plan 032 — E.4 VN ticker resolver (FRESH MODULE)

- **plan_id**: 032-S367-phase-e-vn-ticker-resolver (target dispatch S367 OR parallel with 031 per § E.3 parallel_with declaration)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S368 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S369 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [031-S365-phase-e-vn-claim-extraction] (per § E.3 declaration)
- **blocks_on**: [029-S361-phase-e-vn-tokenization] (E.4 benefits from but does NOT strictly depend on E.2; E.4 alias table is independent of lexicon)
- **coordination_paths_exclusive**: [apps/_shared/entities/__init__.py (NEW), apps/_shared/entities/vn_ticker_resolver.py, apps/_shared/entities/test_vn_ticker_resolver.py, agent-workspace/ubiquitous-language/vn_ticker_aliases.md (alias-table source-of-truth doc)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 20-30 min (fuzzy-match logic + alias table population) / VERIFY 8-12 min
- **STEP 0 evaluation surface**: VN30 universe ticker list + alias variants (Vietnamese + English + diacritics-stripped); difflib evaluation on test fixtures
- **DoD floor**: ≥15 unit tests (exact match / case-insensitive / diacritics-stripped / fuzzy-match / unknown-ticker); mypy + ruff + pytest green; Rule 16 mode-2 satisfaction grep-asserted for resolution_confidence field
- **ADR landing**: D-073 PROPOSED at IMPL tier — "VN Ticker Resolver v0"
- **Charter-tier touch**: NONE (alias table is ubiquitous-language artifact, not constitution)

### Sub-plan sequencing summary

| Sub-plan | Type | Target session | parallel_with | blocks_on | Budget envelope |
|---|---|---|---|---|---|
| 029 (E.1 Tokenization) | PLAN+IMPL+VERIFY | S361/S362/S363 | [] | [] | ~180-290K cumulative |
| 030 (E.2 Sentiment lexicon) | PLAN+IMPL+VERIFY | S363/S364/S365 (after 029 verify) | [] | [029] | ~190-310K cumulative (corpus work adds budget) |
| 031 (E.3 Claim extraction) | PLAN+IMPL+VERIFY | S365/S366/S367 (after 030 verify) | [032] | [029, 030] | ~180-290K cumulative |
| 032 (E.4 Ticker resolver) | PLAN+IMPL+VERIFY | S367/S368/S369 (parallel with 031) | [031] | [029] | ~160-260K cumulative |

**Cumulative Phase E**: ~720-1150K Opus across ~12-16 sessions (4 PLAN + 4 IMPL + 4 VERIFY; parallel dispatch on 031+032 saves ~1-2 sessions wall-clock)

### Sub-track parallel_with field validation (per plan-025 contract DD-3)

Each sub-plan declares 3 mandatory fields per agent template L110-120:
- `parallel_with`: cross-sub-plan parallel-dispatch eligibility (architect-tier orchestration decision)
- `blocks_on`: hard dependencies between sub-plans
- `coordination_paths_exclusive`: per-sub-plan file scope; disjoint across parallel_with siblings

**Lint contract** (per plan-025 DD-4 — enforced at dispatch-time):
- 031 + 032 coordination_paths_exclusive sets MUST be disjoint when running parallel — verified above (031 touches `packages/infrastructure/news/**`; 032 touches `apps/_shared/entities/**` + `agent-workspace/ubiquitous-language/**`); disjoint ✓
- Total parallel_with cardinality across all sub-plans ≤ 3 per dispatch wave per plan-025 DD-5 — max wave = 2 (031+032 parallel) ≤ 3 ✓
- blocks_on forms cycle-free DAG: 029 → 030 → 031 || 032 (031+032 both depend on 029+030; no cycles) ✓

---

## F. Definition of Done (master-plan-level — ≥10 items)

DoD for THIS master-plan-authoring session (S360):

- [ ] **DC-MASTER-1** — `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` exists (this file)
- [ ] **DC-MASTER-2** — `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` exists (per agent-template L207-210 mandate)
- [ ] **DC-MASTER-3** — § A.4 Calibration summary (Phase 1b CONSUMED variant) populated with COLD-START declaration explicit per L-S354-2 + agent-template L65
- [ ] **DC-MASTER-4** — § D contains ≥10 DD architecture decisions all with rationale + adversarial alternates
- [ ] **DC-MASTER-5** — § E contains 4 sub-plan decompositions (029/030/031/032) each with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- [ ] **DC-MASTER-6** — § H contains AQ-1..AQ-10 pre-answered
- [ ] **DC-MASTER-7** — § I contains 5-source-evidence chain (TradingAgents-CN + ai-hedge-fund + underthesea + supplement § I + master plan § 5.4)
- [ ] **DC-MASTER-8** — § J contains ≥8 RM entries with mitigation
- [ ] **DC-MASTER-9** — § K Charter-tier-surface section enumerates any FLAGS (or explicitly states "NO CHARTER-TIER FLAGS at master-plan level")
- [ ] **DC-MASTER-10** — § L Plan-vs-Master-Plan decision rationale documented (DD-1 anchor)
- [ ] **DC-MASTER-11** — § M Phase E → F-prime → G-prime → H-prime sequencing recommendation per dispatch brief return-summary item 6
- [ ] **DC-MASTER-12** — 0 charter / 0 constitution / 0 production code (architect PLAN-only; tools: [Read, Glob, Grep, Write])

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why Phase E as PHASE-MASTER-PLAN not single multi-sub-track FOCUSED_IMPL?

**Answer**: Per DD-1. CLAUDE.md hard rule "Never mix PLAN and IMPL in same session"; budget envelope (4 sub-themes × 100-150K IMPL = 400-600K cumulative exceeds MULTI-TASK ceiling); Phase 1b cold-start risk amplification; Wave 0 + Phase D Theme L precedent for per-sub-wave PLAN+IMPL+VERIFY rhythm.

### AQ-2 — Why 4 sub-themes not collapsed?

**Answer**: Per DD-2. Each sub-theme has distinct external-library evaluation surface + file scope + test scope + calibration regime. Collapsing risks library-evaluation paralysis + coordination_paths_exclusive overlap + test-coverage dilution.

### AQ-3 — Why DEPENDENCY-EVAL pattern for sub-plan 029 not "just adopt underthesea"?

**Answer**: Per DD-3. Charter Principle 8 calibration over confidence — adopt based on empirical STEP 0 evidence not popularity. STEP 0 evaluation is cheap (~50 articles benchmark) relative to wrong-choice rework cost.

### AQ-4 — Why lexicon-first not PhoBERT fine-tune?

**Answer**: Per § A.3 + supplement § I.3 + A-14 § 7.8. Lexicon is rule-based deterministic = Rule 16 mode 2 satisfaction by construction; interpretable; cheap; PhoBERT-fallback is E.2-V2 if lexicon coverage <50% on held-out corpus per AP-7 named revisit trigger.

### AQ-5 — Why AUGMENT existing ClaudeLlmExtractor not parallel VnClaudeExtractor?

**Answer**: Per DD-5. AUGMENT preserves backward compat + reduces duplicate-class maintenance burden. Default-empty injections let existing CLI continue working unchanged.

### AQ-6 — Why anthropic_api_to_subagent refactor IN-SCOPE for sub-plan 031?

**Answer**: Per § C.0.5 + RM-MR-1. Existing ClaudeLlmExtractor at `claude_llm_extractor.py:84` violates memory rule by importing anthropic SDK directly; refactor is naturally bundled with sub-plan 031's E.3 augmentation work (touching same file). Alternative = defer to separate harness sub-plan, but that requires touching the same file twice = unnecessary churn.

### AQ-7 — STEP 0 finds underthesea AND pyvi both fail quality bar — what then?

**Answer**: Per DD-3 step 4. Ship whitespace-regex baseline with explicit "DEFAULT-LOW-QUALITY" docstring + FLAG for sub-plan 029-V2 retry. Phase E does NOT block; downstream sub-plans 030/031/032 use the baseline tokenizer; lexicon coverage + extractor quality may be suboptimal but functional.

### AQ-8 — Sub-plan 030 corpus labelling — who labels?

**Answer**: Sub-plan 030 STEP 0 surfaces this question explicitly. Options: (a) project owner manually labels n=200-500 articles, (b) LLM-bootstrap labelling (LLM scores; user spot-checks 5% subsample per Rule 6 sampling pattern), (c) defer calibration to E.2-V2 and ship lexicon with hypothesis-weights only with explicit "UNCALIBRATED-V0" docstring. Sub-plan 030 STEP 0 STOP-AND-ASK clause triggers if labelling source ambiguous; user picks at sub-plan 030 ratification gate.

### AQ-9 — Sub-plan 032 ticker resolver — what if alias table needs expansion mid-flight?

**Answer**: Alias table is sourced from `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (created by sub-plan 032 IMPL). Expansion = append-only edit to that file; recompile-by-test. Sub-plan 032 IMPL ships initial VN30 universe (~30 tickers + variants). Expansion to broader universe = E.4-V2 follow-on (revisit trigger: universe grows to n>100 OR an unresolved ticker surfaces in production extractor logs).

### AQ-10 — What if sub-plan 029 IMPL surfaces a charter-tier issue (e.g. underthesea license = GPL3+)?

**Answer**: STEP 0 of sub-plan 029 includes license check per DD-3 step 2 acceptance criteria (MIT/Apache/BSD acceptable; GPL3+ requires user ratification). If GPL3+ surfaces, sub-plan 029 STEP 0 STOP-AND-ASK clause triggers → main session dispatches AskUserQuestion for license ratification → user picks underthesea (accept GPL3+ implications) OR pyvi (different license) OR baseline (no library). Charter-tier-surface FLAG triggers AskUserQuestion path per § K + CLAUDE.md hard rule "User prompt overrides ALL defaults".

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (deep-dive obs) | Source 2 (integration proposal) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | Sub-plan 029 DEPENDENCY-EVAL pattern (DD-3) | `agent-workspace/memory/observations/master-planner-A-02-deepdive-crawl4ai.md` (library evaluation precedent) | supplement § I.3 step 1 "underthesea / pyvi / cli-tool comparison" | Charter Principle 8 (Calibration over confidence — empirical evaluation) | `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` § STEP 0 evaluated crawl4ai vs Scrapling vs MediaCrawler (NEW pattern precedent) | underthesea + pyvi (GitHub readme citation; sub-plan 029 STEP 0 reads docs) |
| 2 | Sub-plan 030 LEXICON-PATTERN-PORT (DD-4) | `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` § 3.5 (lines 157-173 — keyword weight dict + normalization formula) | supplement § I.3 step 2 (full recipe + cultural anchors) | I-S1 (NO LLM math) + Rule 16 mode 2 (deterministic-pipeline echo) + Charter Principle 8 (calibration) | `packages/domain/news/value_objects/sentiment.py:19-30` (existing categorical 5-class StrEnum — extends with numeric intensity score per Rule 16 mode 2) | TradingAgents-CN `providers/china/akshare.py:1497-1611` (rule-based lexicon scoring; reproducible; normalized [-1,1]) |
| 3 | Sub-plan 031 AUGMENT existing ClaudeLlmExtractor (DD-5) | `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` § 3 C3 (deterministic-sub-analysis → LLM-interpret split pattern) | supplement § I.3 step 3 (claim extraction recipe with I-S1-1 enforcement + Rule 6 grounding) | Rule 6 (LLM Output Provenance) + Rule 7 (sentiment categorical) + Rule 16 (numeric-field discipline) + I-S2 (citation discipline) | `packages/infrastructure/news/claude_llm_extractor.py` (existing extractor; AUGMENT path) | ai-hedge-fund `src/utils/llm.py` `call_llm` wrapper pattern (structured output + retry; transferable concept per A-01 § 3 C10) |
| 4 | Sub-plan 032 FRESH MODULE + ALIAS TABLE (DD-6) | A-14 § 7.7 anti-pattern explicit veto ("duplicated hard-coded English-only company-name lookups across ~6 files") | supplement § I.3 step 4 (VN entity recognition — centralize from start) | I-S22 (data lineage — canonical ticker as single source of truth) | `apps/_shared/crawl/` Phase D Theme L precedent (cross-app shared utility namespace) | Python stdlib `difflib.SequenceMatcher` (deterministic fuzzy-match; no new dep) |
| 5 | Phase E as PHASE-MASTER-PLAN (DD-1) | (master plan-level decision; no single deep-dive citation) | master plan § 6.4.2 (Phase E = 1 PLAN + 1-2 IMPL + 1 VERIFY) | CLAUDE.md hard rule "Never mix PLAN and IMPL in same session" + § Session Types budget envelopes | Wave 0 5 W0-N + Phase D Theme L 4 per-source = per-sub-wave + per-source PLAN+IMPL+VERIFY rhythm (n=9 precedent) | (master plan structural decision; pattern emerges from CLAUDE.md + stockforge session-typing) |

---

## J. Risks & Mitigation (RM1-RM12)

### RM1 — Cold-start budget over/under-estimation (LIKELY-MEDIUM)
**Risk**: Phase 1b cold-start declared per § A.4; per-theme PLAN+IMPL+VERIFY budget envelopes are boilerplate-derived not empirically-grounded. Sub-plan 029 may finish under budget OR over (e.g. underthesea install issues + Windows compatibility surface).
**Mitigation**: Each per-theme PLAN session re-runs Phase 1b with growing n (n=1 after sub-plan 029 closes; n=2 after sub-plan 030; etc.); cumulative Phase E budget envelope has 60% spread (720-1150K) to absorb variance.

### RM2 — Library STEP 0 evaluation paralysis (LIKELY-LOW; sub-plan 029 risk)
**Risk**: Sub-plan 029 STEP 0 spends excessive budget evaluating underthesea vs pyvi vs baseline; over-engineering.
**Mitigation**: Sub-plan 029 STEP 0 has hard 30-minute budget cap per evaluation; AQ-7 pre-answers "both fail quality bar" path (ship whitespace baseline + FLAG retry); architect bias = ship-soon + iterate-with-evidence (Karpathy P2 simplicity).

### RM3 — Corpus labelling bottleneck (LIKELY-MEDIUM; sub-plan 030 risk)
**Risk**: Sub-plan 030 calibration requires n=200-500 labelled corpus; labelling is project-owner manual work + may take wall-clock days NOT minutes.
**Mitigation**: AQ-8 pre-answers (a) project owner labels, (b) LLM-bootstrap with 5% spot-check, (c) defer with UNCALIBRATED-V0 docstring. Sub-plan 030 STEP 0 STOP-AND-ASK at labelling source ambiguity. Phase E does NOT block on n=500 — V0 ships at any n≥50 with explicit calibration-low warning.

### RM4 — Catastrophic mix pattern (CRITICAL-LOW; mitigated by DD-1)
**Risk**: Bundling 4 sub-themes into single MULTI-TASK IMPL = Session 4 catastrophic failure mode.
**Mitigation**: DD-1 explicitly rejects bundling; phase-master-plan rhythm + per-sub-plan PLAN+IMPL+VERIFY chains enforced.

### RM5 — Charter-tier surface mid-flight (LIKELY-LOW; mitigated by § K + AQ-10)
**Risk**: Sub-plan 029/030/031/032 may surface a charter-tier issue (license / new invariant need / Rule 16 mode tripwire).
**Mitigation**: § K Charter-tier-surface enumerates anticipated FLAGS; each sub-plan STEP 0 has STOP-AND-ASK clause for unanticipated FLAGS; main session dispatches AskUserQuestion gate per CLAUDE.md hard rule.

### RM6 — anthropic_api_to_subagent refactor scope creep (LIKELY-MEDIUM; sub-plan 031 risk)
**Risk**: Sub-plan 031 IMPL extends beyond E.3 scope due to anthropic refactor complexity (system prompt caching + structured output via subagent path).
**Mitigation**: AQ-6 pre-answers; sub-plan 031 dev sets explicit refactor scope envelope at STEP 0 commit; if scope balloons, refactor portion DEFERRED to separate harness sub-plan with NAMED RM-MR-1 trigger.

### RM7 — VN cultural anchor list incomplete (LIKELY-MEDIUM; sub-plan 030 risk)
**Risk**: Initial cultural anchor list (đội lái / đu đỉnh / bắt đáy) may miss important VN F0 culture terms (e.g. "phím hàng" / "bơm thổi" / regional dialects).
**Mitigation**: Sub-plan 030 IMPL ships an extension mechanism (append-only YAML or simple dict) for project owner to add cultural anchors mid-flight; revisit trigger = 3+ unresolved cultural references in production extractor logs (AP-23 promote-or-extend calculus).

### RM8 — Ticker alias table coverage gaps (LIKELY-LOW; sub-plan 032 risk)
**Risk**: VN30 universe = 30 tickers but news articles reference broader universe (~700 listed); alias table miss = ticker resolution fail.
**Mitigation**: AQ-9 pre-answers (E.4-V2 revisit trigger at n>100 tickers OR unresolved-ticker surface in production); difflib fuzzy-match fallback catches "close enough" cases; sub-plan 032 STEP 0 confirms scope = VN30-only-v0 + extension path.

### RM9 — Rule 16 mode 2 echo validation overhead (LIKELY-LOW; sub-plan 031 risk)
**Risk**: Adding EchoValidator to lexicon score → claim path adds runtime overhead + test complexity.
**Mitigation**: Sub-plan 031 IMPL ships EchoValidator OFF by default (mode 2 documented but not enforced at runtime); 5% verifier sampling via separate verifier agent path catches drift offline (per Rule 16 § Enforcement); revisit trigger = if drift surfaces, ship EchoValidator inline.

### RM10 — Theme I dependencies on Phase D Theme L still-evolving (LIKELY-LOW)
**Risk**: 4 VN crawler adapters are SHIPPED + VERIFIED but cross-adapter Protocol-typed-injection refactor (L-S354-1 1st-instance HOLD) is pending; Theme I extractor pipeline may need to adjust if cross-adapter refactor lands mid-Phase-E.
**Mitigation**: L-S354-1 is a harness session NOT a product session; Theme I depends on adapter PUBLIC API (CrawlerAdapter ABC contract; NewsArticle output) NOT internal injection shape; cross-adapter refactor is internal-only; Theme I unaffected. RM-cross-ref: L-S354-1 carry-forward.

### RM11 — Library license drift mid-flight (LIKELY-VERY-LOW; sub-plan 029 risk)
**Risk**: underthesea / pyvi license changes between STEP 0 evaluation and production deployment.
**Mitigation**: Sub-plan 029 IMPL ships license verification as part of D-070 ADR § License section (quarterly re-verify cycle per existing NOTICE precedent from Phase D Theme L Scrapling); revisit trigger = quarterly license-audit run finds drift.

### RM12 — Phase E budget overrun cumulative (LIKELY-MEDIUM)
**Risk**: 4 sub-plans × ~290K mid envelope = ~1160K cumulative; if all 4 land at high end of envelope + add 20% reserve = ~1400K = ~30% of typical session budget at multi-hour wall-clock.
**Mitigation**: Per plan-025 DD-5 architect-tier parallel-dispatch validated at 4-parallel; sub-plans 031+032 declared parallel_with eligible (§ E.3 + § E.4) so 2 sub-plans can run concurrently = ~25-30% wall-time reduction per plan-025 projection; main session orchestrates parallel dispatch.

---

## K. Charter-Tier-Surface FLAGS

Per dispatch brief: "If Theme I requires charter amendments (e.g., new I-S<N> invariant for sentiment scoring methodology; new Rule for VN-locale text handling), FLAG in plan § Charter-Tier-Surface section so main session can dispatch user ratification gate."

### K.1 Anticipated FLAGS at master-plan level (NONE — Theme I as scoped satisfies existing charter)

Reviewing § A scope against existing charter:
- ✅ Rule 16 (I-S1-1) — Theme I numeric fields all satisfy mode 2 (deterministic-pipeline echo) per § C.0.4 audit; no new mode needed
- ✅ Rule 7 (Sentiment Score Calibration) — Sentiment StrEnum 5-class already in place; Theme I scoring layer extends with intensity float that DOESN'T bypass categorical
- ✅ Rule 6 (LLM Output Provenance) — Theme I extractor preserves all grounding invariants
- ✅ I-S1 (NO LLM math) — lexicon-based deterministic scoring; LLM never emits sentiment numeric
- ✅ I-S2 (citation discipline) — every claim preserves source_url + as_of + extracted_at (existing)
- ✅ I-S20 (calibration over confidence) — lexicon weights calibrated from labelled corpus per sub-plan 030 DoD
- ✅ I-S22 (data lineage) — VN ticker resolver preserves resolution_method + resolution_confidence
- ✅ I-S34 (robots.txt + reasonable rate limits) — Theme I uses EXISTING Phase D Theme L crawler adapters; no new HTTP fetcher
- ✅ I-S35 (research-aid framing) — sentiment scores are SIGNALS not RECOMMENDATIONS; no single-action output

**VERDICT at master-plan level**: NO CHARTER-TIER FLAGS. Theme I as scoped satisfies all 11 charter principles + 35+ I-S<N> invariants by construction.

### K.2 Potential FLAGS at sub-plan level (anticipated; sub-plan STEP 0s handle)

The following are **anticipated** FLAGS that sub-plan STEP 0s should watch for and STOP-AND-ASK if surfaced:

**Sub-plan 029 (E.1 Tokenization)**:
- Library license = GPL3+ or other non-permissive → user ratification gate per AQ-10
- Library has runtime dep on torch/transformers > 500MB → resource constraint flag (not charter; user pick)

**Sub-plan 030 (E.2 Sentiment lexicon)**:
- Corpus labelling source = "LLM-bootstrap with 5% spot-check" → potential Rule 6 sampling exception (existing 5% sampling is for production claim extraction; lexicon-calibration sampling is meta-level) → may need new I-S<N> for calibration-meta sampling discipline
- Calibration accuracy <50% → potential Rule 7 amendment if 5-class categorical proves insufficient resolution for VN financial-text variance (highly unlikely but logged)
- Lexicon weight calibration via reinforcement learning rather than simple cross-validation → potentially I-S<N> for ML-calibration discipline (deferred per § A.3 deferral)

**Sub-plan 031 (E.3 Claim extraction)**:
- anthropic_api_to_subagent refactor surfaces dispatched-subagent JSON-contract-parsing issue → no charter touch; harness issue
- LLM-numeric drift surfaces (e.g. LLM emits confidence: 0.85 deviating from deterministic 0.79) → Rule 16 mode 2 EchoValidator enforcement decision → no charter touch (Rule 16 already accepts mode 2 with EchoValidator optional per § Enforcement runtime tier)
- Mentioned_pump_anchors field surfaces "interpretation creep" (LLM volunteers pump-anchor inference vs deterministic regex match) → I-S1 violation surface → FLAG mandatory if surfaced; sub-plan 031 STEP 0 STOP-AND-ASK

**Sub-plan 032 (E.4 Ticker resolver)**:
- Alias table surfaces ambiguous mappings (e.g. "VIN" → Vingroup vs Vinaconex vs ?) → I-S22 data lineage flag → resolver MUST return tuple of candidates with resolution_confidence; user-ratification needed for ambiguity handling policy → CANDIDATE CHARTER-TIER FLAG (NEW Rule 17 for entity-ambiguity-disambiguation discipline) — likelihood low

### K.3 Ratification path if FLAG fires mid-Phase-E

1. Sub-plan STEP 0 STOP-AND-ASK clause triggers → sub-plan author writes FLAG-FINDING-S<N>-<theme>.md to `human-workspace/notifications/`
2. Main session dispatches AskUserQuestion gate with options (typically: a=accept-with-mitigation / b=defer-with-named-trigger / c=block-Phase-E-pending-ratification)
3. User picks → ADR drafted at proposal/ tier → cool-down per severity-schema → constitution amendment landed by separate user-ratified PLAN+IMPL pair
4. Phase E sub-plan resumes after ADR ACCEPTED status confirmed

---

## L. Plan-vs-Master-Plan Decision Rationale

Per dispatch brief: "ARCHITECT DECISION: pick one approach with rationale."

**Decision**: **PHASE-MASTER-PLAN with 4 sub-plan decomposition** (NOT single multi-sub-track plan).

### L.1 Why PHASE-MASTER-PLAN

1. **CLAUDE.md hard rule**: "Never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)" — single-session PLAN+IMPL bundle of 4 sub-themes = violates rule
2. **Budget envelope arithmetic**: per CLAUDE.md § Session Types FOCUSED_IMPL = 100-150K; 4 sub-themes at 100-150K each = 400-600K cumulative IMPL alone, before PLAN authoring overhead; clearly exceeds MULTI-TASK ceiling (150-250K)
3. **Phase 1b cold-start risk amplification**: bundling cold-start work into one session loses incremental calibration feedback; per-theme PLAN sessions let calibration go n=0 → n=1 → n=2 → n=3 across the 4 sub-plans
4. **Wave 0 + Phase D Theme L precedent**: Wave 0 substrate = 5 W0-N each = own PLAN+IMPL session (with W0-3+4+5 plan-018 bundle = ONE exception that surfaced 9 technical issues at S332 = strong evidence bundling is high-risk); Phase D Theme L = 4 per-source sub-plans (plan-020/022/026/027) each = own PLAN+IMPL+VERIFY chain = n=9 sandwich rhythm precedent
5. **Architect-tier parallel-dispatch capacity**: per plan-025 DD-5 + S345 empirical 4-parallel validation = sub-plans 031+032 can run in parallel = wall-clock saving without bundling complexity

### L.2 Why NOT single multi-sub-track FOCUSED_IMPL

Considered but rejected:
- (a) Mix PLAN + IMPL violation per CLAUDE.md hard rule
- (b) Budget envelope exceeds MULTI-TASK ceiling
- (c) STEP 0 evaluation surfaces (library evaluation + corpus collection + alias-table population) each need own STEP 0 — bundling = 4 STEP 0s in one session = ambiguity + budget bloat
- (d) ADR landing tier discipline — 4 distinct ADRs (D-070/D-071/D-072/D-073) per master plan § E; bundling = single mega-ADR vs 4 distinct ADRs = ADR discoverability + future-revisit-trigger granularity lost
- (e) Verifier audit scope — bundling = 1 verifier session reviewing 4 sub-themes = high cognitive load + risk of missed defects; per-theme verifier session = each verifier focuses on 1 sub-theme

### L.3 Alternative considered: 2 sub-plan decomposition (E.1+E.2 bundle + E.3+E.4 bundle)

**Rejected**: E.1+E.2 bundle would mix tokenization library evaluation with lexicon design = mixed-decision-class; E.3+E.4 bundle would mix extractor augment with ticker resolver fresh module = different file-scope + different validation regime. Per Karpathy P3 surgical-changes + plan-025 DD-5 parallel-dispatch ceiling — 4 sub-plans is the right granularity.

---

## M. Phase E → F-prime → G-prime → H-prime Sequencing Recommendation

Per dispatch brief return-summary item 6 + master plan § 6.4.

### M.1 Critical-path analysis

| Phase | Theme | Critical-path dependency | Budget envelope | When to start |
|---|---|---|---|---|
| **E (current)** | I (Vietnamese NLP) | Depends on Phase D Theme L crawling output (4 VN adapters shipped) — UNBLOCKED at S358 close | ~720-1150K Opus across 12-16 sessions | NOW (S360 master-plan; S361 first sub-plan) |
| **F-prime (next)** | H (BC-8 multi-perspective primitives) | Independent of Theme I substrate; depends on Phase C Theme G ratification (already done D-065) | TBD per F-prime master-plan | **Can dispatch PARALLEL with Phase E after E.1 ships** (sub-plan 029 close) — architect-tier parallel-dispatch precedent (S345 4-parallel) supports this; F-prime authoring is independent file scope |
| **G-prime** | J (PDF + table extraction BC-2) | Phase 2 work; not on Phase 1 critical path; no dependency on Theme I | TBD per G-prime master-plan | DEFER to Phase 2 entry (after MVP gap closes) |
| **H-prime** | K (UX/Output — Streamlit dashboard polish) | Phase 2 work; not on Phase 1 critical path | TBD per H-prime master-plan | DEFER to Phase 2 dashboard work entry |

### M.2 Recommended sequencing

**Sequential Phase E ship**:
- S360 (now): Phase E master plan = this file
- S361/S362/S363: sub-plan 029 (E.1 Tokenization) PLAN+IMPL+VERIFY
- S363/S364/S365: sub-plan 030 (E.2 Sentiment lexicon) PLAN+IMPL+VERIFY
- S365/S366/S367: sub-plan 031 (E.3 Claim extraction) PLAN+IMPL+VERIFY
- S367/S368/S369: sub-plan 032 (E.4 Ticker resolver) PLAN+IMPL+VERIFY (PARALLEL with sub-plan 031 per § E declaration)
- S369 close: Phase E DONE

**Parallel Phase F-prime ship** (architect-tier parallel-dispatch):
- After sub-plan 029 VERIFY ships at S363: main session may dispatch Phase F-prime master-plan author in parallel with Phase E sub-plan 030 PLAN authoring
- F-prime master-plan author (S363' background dispatch) = independent file scope; no contention with Phase E

**Deferred Phase G-prime + H-prime**:
- G-prime triggers at Phase 2 entry (after Phase 1 MVP gap closes per master plan § 6.4.4)
- H-prime triggers at Phase 2 dashboard work entry per master plan § 6.4.5

### M.3 Total cumulative budget projection

- Phase E: ~720-1150K Opus / ~12-16 sessions wall-clock (with sub-plan 031+032 parallel = save ~1-2 sessions)
- Phase F-prime (parallel from S363+): TBD (estimated ~400-600K per master plan § 6.4.3)
- Phase G-prime + H-prime: deferred

**Wall-clock projection**: Phase E sequential = ~12-16 sessions × 1 turn each at full autonomous = ~12-16 turns; with sub-plan 031+032 parallel + F-prime parallel from S363 = ~10-12 turns total to Phase E+F-prime close.

---

## N. Coordination paths off-limits (during S361 sub-plan 029 PLAN authoring window)

When main session dispatches sub-plan 029 author at S361, main session SHOULD avoid (read-only or no-touch):
- `agent-workspace/session-plans/pending/029-S361-phase-e-vn-tokenization.md` (sub-plan author writes)
- `agent-workspace/memory/observations/sandwich-architect-S361-vn-tokenization-plan.md` (sub-plan author writes)

Coordination paths beyond S361 apply per-sub-plan and are documented in each sub-plan's own § Coordination paths section.

---

## P. Compliance attestation (master-plan authoring session S360)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work — L-S354-2 planner-stats infrastructure gap noted as carry-forward in § A.4; explicitly NOT fixed here per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol)
- AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED for first-instance HOLD; promotion-on-2nd-recurrence calculus respected)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = master plan + observation; main session dispatches sub-plan 029 author per § L sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing recommendation in § M is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-066 not touched (Phase D Theme L closed; Theme I CONSUMES adapter output without modification)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (master plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- I-S1 ✓ (this plan PROMOTES I-S1 satisfaction in Theme I implementation; does not violate)
- I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- I-S34 ✓ (Theme I uses existing 4 VN adapters; no new HTTP fetcher; HARD REJECT carried forward in binding_decisions)
- I-S35 ✓ (Theme I scope is research-aid signals not recommendations)
- Phase 1b COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate)
- 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)

---

**END OF MASTER PLAN 028-S360-PHASE-E-VIETNAMESE-NLP-ENTRY**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches sub-plan 029 author per § L sequencing.
