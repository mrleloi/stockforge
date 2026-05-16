---
plan_id: 029-S361-phase-e1-vn-tokenization
target_session: S362 (dev IMPL session; THIS plan = S361 architect output)
type: FOCUSED_IMPL (4 sub-tracks D1-D4; sub-plan author = sandwich-architect at S361; IMPL by sandwich-dev at S362; VERIFY by sandwich-verifier AP-1 at S363)
budget:
  - this PLAN session (S361 architect): ~50-80K Opus PLAN (per CLAUDE.md § Session Types PLAN envelope; cold-start absorbed by full envelope)
  - sub-plan IMPL (S362 dev): ~100-150K Opus FOCUSED_IMPL (cold-start defaults per plan-025 DD-6 + agent-template L65; nearest analog crawler-adapter-impl n=3 NOT comparable shape)
  - sub-plan VERIFY (S363 verifier): ~30-60K Opus AP-1 fresh-context
phase: E (Theme I — Vietnamese NLP entry; sub-theme E.1 Tokenization — FIRST of 4 sub-themes per plan-028 § E sequencing)
track: Wave 1 Theme I sub-theme E.1 — VN tokenization library evaluation + adoption + port (BC-5 News Stream + BC-6 Influence + BC-7 Crowd shared NLP substrate; per master plan § 5.4 + § 6.4.2 + plan-028 DD-3)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN authored S360; THIS is the first sub-plan per § E.1 + § L sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.4 + § 6.4.2
predecessor: 028-S360-phase-e-vietnamese-nlp-entry (master plan; pending-execution; THIS sub-plan satisfies its sub-plan 029 contract per § E.1 + DD-3 DEPENDENCY-EVAL pattern)
successor: S362 sandwich-dev FOCUSED_IMPL executing this plan D1-D4 → S363 sandwich-verifier AP-1 → sub-plan 030 E.2 sentiment lexicon at S363+ (per master plan § E sequencing; 030 blocks_on=[029])
architect: S361 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase E first sub-plan author per plan-028 § L sequencing + dispatch brief 2026-05-16
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED with COLD-START EXPLICIT for task_class="vietnamese-nlp-impl"; nearest analog crawler-adapter-impl n=3 NOT comparable shape per parent master plan § A.4)
executing_agent: N/A this PLAN session; S362 sandwich-dev FOCUSED_IMPL (after parent master plan + this sub-plan ratified) + S363 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT include sync-grilling in S362 close ritual)"

depends_on:
  - "Parent master plan-028 § E.1 sub-plan contract (DD-3 DEPENDENCY-EVAL strategy; coordination_paths_exclusive scoped to packages/infrastructure/nlp/** + packages/application/nlp/ports/** + one-line pyproject.toml dep add)"
  - "D-066 + REV-1 + REV-2 + REV-3 (CrawlerAdapter ABC contract; 4 VN adapters SHIPPED CafeF/NDH/Vietstock/VietnamBiz; THIS sub-plan CONSUMES their NewsArticle output as corpus substrate — STEP 0 reads body_excerpt fields from existing rows)"
  - "D-061 § Decision item 4 (HARD REJECT: Scrapling Cloudflare-solver / patchright / playwright_stealth / fake-useragent / StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher introduced; tokenizer is text-in/tokens-out pure-function adapter) but CARRIES FORWARD if a tokenizer lib pulls these in transitively (verifier grep-asserts post-install)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain) — BINDING for every NEW file authored under this sub-plan; tokenizer adapter is pure-function so deterministic-by-construction posture expected; STEP 0.7 grep-asserts"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S362 dev commit boundary"
  - "D-061 § Decision item 4 license discipline (BSD-3 verbatim attribution NOTICE precedent from S358 VietnamBiz F1 inline-remediation — see § DD-6 license posture)"
  - "D-062 (atomic-write-doctrine via tmp+os.replace) — N/A for tokenizer wrapper (no file writes in tokenizer path; test fixtures use synthetic inline strings); BINDING IF dev decides to persist tokenized corpus output (architect-recommendation: DO NOT persist tokenized output in this sub-plan; tokenization is a re-runnable transform)"
  - "D-064 (path-safety 5-invariant) — N/A this sub-plan (no new file-path code)"
  - "D-065 Rule 16 (numeric-field discipline) — THIS sub-plan emits ZERO LLM-numeric fields; tokenizer output = `list[str]` tokens deterministically computed by library + tests; Rule 16 satisfied by construction (no LLM in the tokenizer path)"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; THIS plan has 4 sub-tracks D1-D4 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VN tokenization quality IS the moat foundation) + Principle 7 (Dogfood — S362 dev MUST tokenize ≥5 real CafeF/NDH/Vietstock/VietnamBiz samples in STEP 0; cannot ship without dogfood) + Principle 8 (Calibration over confidence — library SELECTED via empirical STEP 0 evaluation NOT popularity; quality scores recorded in observation) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — tokenizer is pure-function deterministic; LLM never invoked in tokenizer path; satisfied by construction"
  - "I-S2 (citation discipline) — N/A this sub-plan (tokenizer transforms text; provenance flows through unchanged via downstream extractor)"
  - "I-S20 (calibration over confidence) — STEP 0 records empirical quality + perf + install scores for each candidate library; selection decision traces to evidence not intuition"
  - "I-S22 (data lineage) — tokenizer adapter records selected_library + lib_version in its dataclass (DD-2 mechanical recording)"
  - "I-S34 (robots.txt + reasonable rate limits + HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher) — STEP 0 verifies candidate library transitive deps do NOT pull in any of these; verifier grep-asserts at S363"
  - "I-S35 (research-aid framing) — tokenizer = transform utility; no recommendation surface; satisfied by construction"
  - "anthropic_api_to_subagent memory rule — N/A this sub-plan (tokenizer does NOT invoke LLM); CARRIES FORWARD to sub-plan 031 E.3 claim extraction wrapper per master plan AQ-6 + RM6"
  - "skill .claude/skills/crawler-reliability/SKILL.md (DEPENDENCY-EVAL pattern precedent — Adapter Storage Discipline § + library evaluation rhythm from plan-020 § STEP 0 evaluated crawl4ai/Scrapling/MediaCrawler before SELECTED crawl4ai+Scrapling combo; transferable rhythm even though crawler vs NLP libs are different shapes)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter discipline — TokenizerProtocol port + VnUnderthesea/VnPyvi/VnWhitespace adapter selected at runtime via DI)"

binding_decisions:
  - "PHASE 1b CONSUMED with COLD-START EXPLICIT — task_class='vietnamese-nlp-impl' has sample_size=0 in .planner-stats.tsv (header-only at S361 entry per parent master plan § A.4 L-S354-2 carry-forward); nearest analog crawler-adapter-impl n=3 NOT comparable shape (HTTP fetch + selector parsing vs library wrapper + text transform); architect honors Karpathy P1 calibration over confidence by explicit cold-start declaration NOT by manufacturing precedent"
  - "DD-2 LIBRARY SELECTION IS CONDITIONAL ON STEP 0.5 USER RATIFICATION — IF underthesea wins quality eval AND license = GPL-3.0 → STOP-AND-ASK gate fires (per § CHARTER-TIER GATE clause + plan-028 § K.2 + AQ-10); architect DOES NOT pre-decide library; STEP 0.3 + 0.4 + 0.5 produce empirical scorecard and user picks at gate"
  - "GPL-3.0 dependency adoption = CHARTER-TIER decision per § CHARTER-TIER GATE — re-licensing StockForge or accepting copyleft surface requires explicit user approval; 3 options enumerated for ratification (a/b/c per § CHARTER-TIER GATE)"
  - "DEPENDENCY-EVAL pattern per parent plan-028 DD-3 — empirical comparison on ≥50-article corpus subset before selecting library; default fallback = whitespace-regex baseline with DEFAULT-LOW-QUALITY docstring if ALL 3 candidates fail quality threshold (per parent plan AQ-7)"
  - "PORT-WRAPPING per DDD tactical patterns — selected library lives BEHIND TokenizerProtocol port at packages/application/nlp/ports/text_tokenizer_port.py; concrete adapter at packages/infrastructure/nlp/vn_tokenizer.py; future library swap is one-file change in infra (no consumer change)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (e.g. NEW VN-NLP test fixture style); 2nd recurrence triggers promote-to-skill calculus"
  - "Karpathy P3 surgical-changes — this sub-plan adds ≤500 LOC production code total across D1-D4 (port ~50 LOC + adapter ~150 LOC + tests ~250 LOC + CLI smoke harness ~50 LOC = ~500 LOC ceiling)"
  - "VBW protocol mandatory — S362 dev MUST READ candidate library source files (underthesea/pyvi readmes + LICENSE files) empirically before STEP 0.5 decision; cite file:line for every license claim"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN+IMPL; THIS is sub-plan author session; production code lands in S362 dev IMPL)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (master plan FLAG ratification path runs through main session AskUserQuestion only after STEP 0 surfaces a FLAG)"
  - "no touching Phase D Theme L files — all 4 VN adapters + 6 primitives shipped + verified; this sub-plan CONSUMES NewsArticle output, does NOT modify adapters"
  - "no Phase E sub-themes E.2/E.3/E.4 work in THIS sub-plan — those are sub-plans 030/031/032 (own PLAN+IMPL+VERIFY chains per master plan § E)"
  - "no charter amendment SHIP from THIS plan — IF GPL-3.0 license gate fires (per § CHARTER-TIER GATE), THIS plan FLAGS it via human-workspace/notifications/STOP-FINDING-S362-* but DOES NOT amend charter; main session dispatches AskUserQuestion + separate user-ratified ADR proposal"
  - "no harness/hook changes — this plan ships product substrate (VN tokenizer adapter); surface any harness gaps in observation; do NOT fix here. L-S354-2 (.planner-stats.tsv auto-population gap) belongs to next harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.6 grep-asserts no patchright/playwright_stealth/fake-useragent/StealthyFetcher in candidate libs' transitive deps (e.g. `pip show underthesea` + `pip show pyvi` after install in throwaway venv)"
  - "If STEP 0 surfaces a charter-tier need (GPL-3.0 / new I-S<N> for tokenizer determinism / new Rule for VN-locale text handling), FLAG in § CHARTER-TIER GATE for main session AskUserQuestion ratification gate dispatch"
---

# S361 — Phase E.1 Vietnamese Tokenization sub-plan (DEPENDENCY-EVAL — first sub-plan of Phase E)

> **One-sentence intent**: Empirically evaluate underthesea (Python VN NLP; GPL-3.0) vs pyvi (Python VN tokenizer; MIT) vs naive whitespace-regex (zero-dep baseline) on a ~50-article VN financial-news corpus, then ship the SELECTED library behind a `TextTokenizerPort` Protocol at `packages/application/nlp/ports/` with concrete adapter at `packages/infrastructure/nlp/vn_tokenizer.py` — without LLM in the tokenizer path (I-S1 by construction), without pre-deciding library (Charter Principle 8 calibration over confidence), and without silently accepting GPL-3.0 viral copyleft (CHARTER-TIER GATE STOP-AND-ASK if underthesea wins).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent plan-028 § E.1 + DD-3)

Build the **Vietnamese tokenizer layer** for StockForge that:

- **Replaces today's naive `coarse keyword scan`** at `packages/domain/news/models/news_article.py:38-42` ("coarse keyword scan performed at ingest time (CLI grep over title + excerpt against the UL universe)") with a **library-backed tokenizer** that segments VN text into syntactic word units (e.g. "cổ phiếu" = 1 token NOT 2; "thị_trường" = 1 token NOT 2; preserving multi-syllable VN words)
- **Lives behind a Protocol port** so future swap (e.g. PhoBERT fallback per parent plan AQ-4) is one-file change in infra
- **Selected by empirical evaluation** of 3 candidates (underthesea / pyvi / whitespace-baseline) on a ~50-article VN financial-news corpus subset — selection decision traces to scorecard NOT to library popularity
- **License-audited** before adoption — if SELECTED library = GPL-3.0 (viral copyleft), CHARTER-TIER GATE fires for user ratification BEFORE production-code commit

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — TextTokenizerPort Protocol at `packages/application/nlp/ports/text_tokenizer_port.py` (~50 LOC; foundation; blocks D2)
2. **Sub-track D2** — VnTokenizer concrete adapter at `packages/infrastructure/nlp/vn_tokenizer.py` (~150 LOC; uses SELECTED library from STEP 0.5; default whitespace-baseline fallback per AQ-7)
3. **Sub-track D3** — Unit tests at `packages/infrastructure/nlp/test_vn_tokenizer.py` (~250 LOC; ≥10 test cases; synthetic VN text fixtures inline; parallel with D4)
4. **Sub-track D4** — Integration smoke + CLI tokenizer harness at `apps/cli/tokenize_vn_text.py` (~80 LOC; reads NewsArticle rows from SQLite OR raw HTML files + dumps token lists; parallel with D3)
5. **Single-line pyproject.toml dep add** (optional — only if SELECTED library != whitespace-baseline; lands in D2)
6. **ADR D-070 PROPOSED** at IMPL tier (per severity-schema auto-ratifies on commit) — "VN Tokenizer Library Selection" — records library choice + version + license + STEP 0 scorecard + revisit triggers
7. **STEP 0 observation appended** to `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (NEW; records empirical scorecard for sub-plan 030 corpus reuse)
8. **Session log + observation file** per CLAUDE.md § Session Protocol End
9. **ZERO charter / constitution / human-workspace writes** (CHARTER-TIER GATE FLAG file at `human-workspace/notifications/STOP-FINDING-*` is the ONLY human-workspace write path AND only if GPL-3.0 trigger fires)
10. **ZERO new LLM-numeric schema fields** (Rule 16 by construction — tokenizer emits `list[str]` not numeric)
11. **ZERO new hooks** (mirror plan-020/022/026/027 — product substrate not harness rule-enforcement)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Sub-theme E.2 sentiment lexicon (rule-based + calibration loop) | Separate sub-plan 030; depends on this sub-plan's tokenizer for keyword matching | Sub-plan 030 dispatch after S363 verifier confirms E.1 ships |
| Sub-theme E.3 claim extraction wrapper (AUGMENT ClaudeLlmExtractor) | Separate sub-plan 031; depends on E.1 + E.2 outputs | Sub-plan 031 dispatch after S365 verifier confirms E.2 ships |
| Sub-theme E.4 VN ticker resolver (fuzzy-match + alias table) | Separate sub-plan 032; can run parallel with 031 post-E.2 | Sub-plan 032 dispatch after S365 (parallel with 031) per master plan § E |
| PhoBERT / transformer-based VN tokenization | Heavier deps (torch ≥500MB + transformers); lexicon-first per A-14 § 7.8 + parent AQ-4 | E.1-V2 trigger: STEP 0 quality scores show lexicon-style tokenization <70% accuracy on financial-domain test cases OR sub-plan 030/031 surfaces tokenization gaps |
| Custom-trained VN-financial-domain tokenizer (fine-tune underthesea/pyvi on VN financial corpus) | Out-of-scope per parent A.3; requires labelled corpus n≥500 + ML training infra | E.1-V3 trigger: only after E.1-V2 PhoBERT fallback insufficient AND n≥500 labelled corpus available |
| Async tokenizer interface | Tokenizer is pure-function CPU-bound; sync wrapper sufficient; async = unnecessary complexity | Async trigger: Phase 3 production-throughput gate when tokenization becomes >5% of session time |
| Multi-language tokenization (English / Chinese fallback) | VN-only is the moat per Charter Principle 4 | Trigger: explicit user directive for multi-locale OR market expansion |
| Tokenizer caching / memoization | Defer to E.3 consumer if needed; no premature optimization per Karpathy P2 | Trigger: E.3 IMPL surfaces measurable extractor latency attributable to repeated tokenization on same article body |
| Persisting tokenized corpus output to disk | Tokenization is re-runnable transform; persistence adds D-062 atomic-write surface + storage cost for marginal benefit | Trigger: E.2 sub-plan corpus labelling cycle proves repeated tokenization is the bottleneck |
| Tokenizer benchmark dashboard / CI gate | Premature for v0 ship; eval is recorded in observation file + ADR D-070; CI gate at PR-time = future Phase 3 work | Trigger: 2+ silent-tokenization-regression incidents surface (AP-23 promote-to-hook calculus) |
| Type stubs for selected library | underthesea/pyvi lack official type stubs; use `cast(str, ...)` + targeted `# type: ignore[no-any-return]` with comment OR vendor minimum stub at infra-only boundary (DD-6) | Trigger: mypy strict adoption blocked by Any in production import; n≥3 type:ignore needed for same lib triggers stub-vendoring |
| Tokenizer integration into existing ClaudeLlmExtractor system prompt | E.3 sub-plan 031 work per AUGMENT pattern (parent DD-5) | Sub-plan 031 dispatch |
| Tokenizer integration into existing `mentioned_tickers` coarse-scan | Separate concern (ticker resolution = E.4); coarse-scan refactor = E.4 sub-plan 032 RM | Sub-plan 032 IMPL touches `claude_llm_extractor.py:177-180` per parent DD-6 |
| Charter amendment SHIP for GPL-3.0 license posture (if triggered) | THIS plan FLAGS via STOP-FINDING file; main session ratifies via AskUserQuestion gate; ADR drafted separately per CLAUDE.md hard rule | Trigger: § CHARTER-TIER GATE STEP 0.5 STOP-AND-ASK fires |
| New harness hook for VN-text-determinism check (e.g. "tokenizer output must be deterministic across runs") | Belongs to harness-stabilization sweep IF a tokenizer-determinism defect surfaces; product session SHIPS the adapter not the hook | Harness trigger: 2+ silent tokenizer-output-drift incidents (AP-23 promote-to-hook) |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START EXPLICIT per L-S354-2 carry-forward)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 carry-forward — planner-feedback-loop.sh STILL header-only at S361 entry after parent S360 dogfood cycle did not populate)
2. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read first 50 rows; schema = `session_n,session_id,ts_utc,tokens_real,tools_used,subagents,failure_codes,wall_min`; lacks `task_class` column — cannot key cleanly to vietnamese-nlp-impl precedent)
3. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 important INLINE-RESOLVED UTC+7 VN timezone fix / M-S354-NONE clean / M-S347-NONE clean / M-S342-1 medium verifier-fixture-cleanup carry-forward / M-S341-1 low LOC-overstate carry-forward — **no VN-NLP-impl-specific failure pattern history**)
4. `agent-workspace/memory/current-execution.md` (first 100 LOC; INCIDENT+RECOVERY + BEHAVIORAL HOLD + Wave 0 substrate progress)
5. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; offset 1-200 + 200-500 + 500-720 — full read in 3 chunks per file size limit; §s A/B/C/D/E/F/G/H/J/K/L/M/N/P covering all sub-plan contracts)
6. `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (parent observation; full read 200 LOC; DD-1..DD-10 + Phase 1b reasoning trail + Charter-tier flags surfaced + lessons)
7. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (lines 246-267 read; underthesea + pyvi + cli-tool comparison + lexicon design references + Phase E 1 PLAN + 1-2 IMPL + 1 VERIFY scope)
8. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum — Theme I downstream contract)
9. `packages/domain/news/models/news_article.py` (full read 73 LOC; NewsArticle + Rule 8 + `mentioned_tickers` coarse-scan comment at L38-42 — replaced surface)
10. `packages/domain/news/services/claim_extraction_service.py` (full read 70 LOC; LlmExtractorProtocol contract — TokenizerProtocol design mirror)
11. `packages/infrastructure/news/claude_llm_extractor.py` (offset 1-100 read; ClaudeLlmExtractor system prompt VN-language explicit + anthropic SDK direct import at L84 carry-forward to E.3)
12. `packages/application/news/ports/llm_extractor_port.py` (full read 50 LOC; LlmExtractorPort Protocol shape — TokenizerProtocol mirrors)
13. `packages/application/news/ports/crawler_adapter.py` (offset 1-80 read; CrawlerAdapter ABC pattern reference + license header style)
14. `apps/_shared/crawl/__init__.py` (full read 24 LOC; crawl shared utility namespace pattern)
15. `apps/_shared/crawl/rate_limiter.py` (offset 1-50 read; per-file BSD-3-style attribution header + D-059 compliance comment pattern)
16. `packages/infrastructure/news/cafef_scraper.py` (offset 1-80 read; ScrapedArticle + body_text field — input shape for tokenizer)
17. `pyproject.toml` (full read 195 LOC; current dep stack confirms no underthesea/pyvi/torch/transformers currently pinned; license = "Proprietary"; Apache-2.0 / MIT / BSD-3 dep family expected for new adds)
18. `.claude/skills/crawler-reliability/SKILL.md` (offset 1-100 read; DEPENDENCY-EVAL pattern precedent — "Adapter Storage Discipline § promotes L-S345-3 n=3 instance threshold met"; STEP 0 evaluation rhythm transferable to library-eval shape)
19. `.claude/agents/sandwich-architect.md` (full read 250 LOC; Phase 1b template L42-65 cold-start path + L207-210 observation mandate + L110-120 sub-track 3 mandatory fields)
20. `agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md` (offset 1-150 + 700-900 read for sub-track decomposition format + DC schema reference)
21. `agent-workspace/session-plans/completed/026-S353-phase-d-vietstock-adapter.md` (offset 700-1000 read for D1-D5 sub-track parallel_with field examples)
22. `agent-workspace/constitution/architecture.md` (referenced via parent plan; BC-5 + BC-6 + BC-7 cross-BC discipline — application/nlp/ namespace is NEW per parent DD-7)
23. Glob `apps/_shared/**/*.py` (12 files confirmed; no nlp subdir yet — clean baseline for D2)
24. Glob `packages/application/**/*.py` (54 files confirmed; `application/news/ports/` + `application/crowd/ports/` + `application/influence/ports/` + `application/analysis/ports/` exist; `application/nlp/` is NEW namespace per DD-7)
25. Glob `data/raw/news/**/*.html` (5 article files confirmed: 2 NDH + 2 Vietstock + 1 VietnamBiz; CafeF NOT persisted — matches parent master plan § 0.3 inventory)
26. Glob `**/nlp/**` (0 matches confirmed — packages/infrastructure/nlp/ + packages/application/nlp/ both NEW directories per D2/D1)

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (NEW — no precedent in tracking logs; first VN-NLP-shaped IMPL work in StockForge)
- **sample_size**: **0** (COLD-START on this task_class; nearest analog `crawler-adapter-impl` n=3 NOT comparable shape — adapter = HTTP fetch + selector parsing + raw_html_sink wiring; tokenizer = library wrapper + text transform + no I/O)
- **avg_wall_min observed**: N/A cold-start; adopting boilerplate FOCUSED_IMPL envelope per agent-template L65 default 100-150K
- **avg tokens_real observed**: N/A cold-start; estimating per closest-shape-precedent = library-wrapper code in apps/_shared/crawl/* (e.g. rate_limiter ~140 LOC + tests ~200 LOC at apps/_shared/crawl/ shipped under W0-3 plan-018 bundle; similar shape adapter pattern with ~70K Sonnet observed)
- **parallel_hit_rate**: N/A cold-start (planner-stats header-only); THIS plan declares parallel_with at D3+D4 (after D1+D2 ship) per § E sub-track DAG; 2-parallel ≤ 3-ceiling per plan-025 DD-5
- **parallel_savings_avg**: N/A cold-start; nearest precedent plan-026 declared 3-parallel D3+D4+D5 with projected ~25-30% wall reduction (no empirical confirmation per L-S354-2)
- **failure_mode frequency**: N/A cold-start; nearest analog `crawler-adapter-impl` shows IMPORTANT defects n=1 per cycle all INLINE-RESOLVABLE; VN-NLP-impl may surface MORE defects per cycle (library-eval STEP 0 has multiple decision points: license, quality, perf, install cost — each independent failure surface)
- **Adjustment to default budget**: NONE (full 100-150K Opus FOCUSED_IMPL envelope honored for cold-start absorption); + ~5-10K reserve for STEP 0 STOP-AND-ASK file authoring IF GPL-3.0 trigger fires
- **Cold-start?**: **YES EXPLICIT** (per agent-template L65 + plan-025 DD-11 mandate; both `.planner-stats.tsv` infrastructure gap AND first VN-NLP-impl-shaped work)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S362 dev):
- S362 dev IMPL projection: **100-150K Opus FOCUSED_IMPL** (cold-start envelope; full default per agent-template L65)
- STEP 0 evaluation overhead: ~15-25K (library install + corpus sampling + quality scoring + license read — variable depending on STEP 0.5 outcome)
- D1 port: ~3-5K (≤50 LOC Protocol + docstring)
- D2 adapter: ~10-15K (≤150 LOC + selected-library import + D-059 compliance check)
- D3 tests: ~10-15K (≤10 cases × ~25 LOC each = ~250 LOC tests)
- D4 CLI smoke: ~5-10K (≤80 LOC click harness reading SQLite OR HTML files)
- ADR D-070 + observation + session log: ~10-15K
- STEP 0 STOP-AND-ASK file (CONDITIONAL on GPL-3.0 trigger): ~5-10K
- Reserve for inline F1-equivalent fixes (per crawler-adapter-impl n=3 pattern: 1 IMPORTANT defect per cycle): ~10-15K
- **Total projected dev budget envelope**: 60-100K typical; 100-130K with STEP 0.5 STOP-AND-ASK path; full 150K cap respected

**PARALLEL OPPORTUNITY** (architect declaration for downstream S362 dev):
- D1 (port) must serialize FIRST as foundation (~3 min wall)
- D2 (adapter) must wait for D1 (~12 min wall; library install in STEP 0 already absorbed)
- D3 (tests) + D4 (CLI smoke) can run in parallel post-D2 ship — disjoint file scopes per § E coordination_paths_exclusive (max(8, 5) = ~8 min)
- Sequential wall projection: 3 + 12 + 8 + 5 = ~28 min wall
- Parallel D3+D4 wall projection: 3 + 12 + 8 = ~23 min wall (~18% reduction)
- 2-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk

**WHY COLD-START IS HONORED HONESTLY**:
- L-S354-2 carry-forward (planner-stats infrastructure gap from S355 verifier) means NO empirical telemetry for ANY task_class is auto-populated; manual reading via sessions-rollup + dispatch.jsonl + mistake-log is the substitute path
- crawler-adapter-impl n=3 actuals (NDH ~31min Sonnet ~116K; Vietstock ~34min Opus ~34K; VietnamBiz ~36min Opus ~similar to Vietstock per S358 close) provide DIRECTIONAL confidence on adapter-shape work BUT tokenizer-wrapper shape is structurally different — using adapter-shape n=3 for tokenizer-shape n=0 = false-precedent (Charter Principle 8 violation)
- Architect declares: **honest cold-start n=0 with full envelope absorption** — sub-plan 030 + 031 + 032 inherit precedent from THIS sub-plan once S362 ships (n=0 → n=1 → n=2 → n=3 incremental calibration per parent plan L-S360-2)

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S362 dev)

### IN-scope (S362 dev MUST ship)

- TextTokenizerPort Protocol module + docstring (~50 LOC)
- VnTokenizer concrete adapter wrapping SELECTED library OR whitespace-baseline fallback (~150 LOC)
- Unit tests (≥10 test cases; synthetic VN text fixtures inline) (~250 LOC)
- CLI tokenize_vn_text.py harness for D4 integration smoke (~80 LOC)
- Single-line pyproject.toml dep add (CONDITIONAL — only if SELECTED lib != whitespace baseline)
- ADR D-070 PROPOSED at IMPL tier — records library choice + version + license + STEP 0 scorecard + 3 revisit triggers (per § ADR template below)
- STEP 0 scorecard appended to NEW `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (recordable evidence for sub-plan 030 corpus reuse)
- Session log + observation file
- Mistake-log digest entry (M-S362-N if mistakes; OR explicit "no mistakes" statement)
- Plan-029 moved `pending/` → `completed/` at S363 close (NOT at S362 close — verifier acceptance gates the move; matches plan-020/022/026/027 precedent)

### OUT-of-scope for S362 dev (DEFERRED — explicit non-goals)

- Sub-themes E.2/E.3/E.4 work (separate sub-plans 030/031/032)
- Tokenizer integration into ClaudeLlmExtractor (E.3 sub-plan 031 AUGMENT pattern)
- Tokenizer integration into NewsArticle.mentioned_tickers coarse-scan (E.4 sub-plan 032 ticker resolver consumes this surface)
- Caching / memoization (deferred per § A.3)
- PhoBERT fallback adapter (E.1-V2 per § A.3 trigger)
- Custom-trained VN-financial tokenizer (E.1-V3 per § A.3 trigger)
- Async tokenizer (deferred per § A.3)
- Type stubs vendoring (deferred per § A.3; n=3 type:ignore trigger)
- Tokenizer benchmark dashboard (deferred per § A.3)
- Multi-language tokenization (deferred per § A.3)
- Tokenizer-determinism check hook (deferred per § A.3; AP-23 2+ instance trigger)

---

## C. STEP 0 — BLOCKING DEPENDENCY EVALUATION (sub-step 0.1 through 0.7)

> **CRITICAL**: STEP 0 is BLOCKING — S362 dev MUST complete sub-steps 0.1-0.7 + (CONDITIONAL) 0.5-STOP-AND-ASK before writing ANY production code in D1-D4. This is the DEPENDENCY-EVAL pattern per parent plan-028 DD-3.

### Sub-step 0.1 — Re-read parent master plan + license gate clause (VBW empirical)

**Dev action**: Read these files at S362 entry (architect has done this for THIS plan; dev does fresh VBW read):
- `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` § DD-3 (lines ~271-281) + § K.2 (lines ~587-590) + AQ-7 (line ~482) + AQ-10 (line ~494) + § Out-of-scope item "Library license = GPL3+"
- THIS sub-plan-029 in full + parent master plan § E.1 sub-plan-029 row in § E sequencing table (line ~415)

**STOP-AND-ASK trigger**: NONE (foundational read; no decision yet)

**Acceptance**: Dev observation file cites parent plan-028 line numbers for DD-3 + K.2 + AQ-7 + AQ-10 verbatim quotes

### Sub-step 0.2 — Sample ~50 VN financial-news articles from existing corpus + EXPAND IF NEEDED

**Dev action**:
1. Glob `data/raw/news/**/*.html` to enumerate current corpus
   - **Expected baseline at S362 entry**: 5 files (2 NDH + 2 Vietstock + 1 VietnamBiz per architect Glob 2026-05-17; no CafeF persisted per parent master plan § 0.3)
2. **If corpus < 50 articles**: Run existing adapter CLIs in `--max-articles 12-15` mode each to expand corpus to ~50:
   ```bash
   python apps/cli/ingest_news_cafef.py --tickers VHM,FPT,HPG,VIC,MSN --max-articles 15 --skip-llm --output /tmp/corpus-expand-cafef.sqlite
   python apps/cli/ingest_news_ndh.py     --tickers VHM,FPT,HPG,VIC,MSN --max-articles 12 --skip-llm --output /tmp/corpus-expand-ndh.sqlite
   python apps/cli/ingest_news_vietstock.py --tickers VHM,FPT,HPG,VIC,MSN --max-articles 12 --skip-llm --output /tmp/corpus-expand-vietstock.sqlite
   python apps/cli/ingest_news_vietnambiz.py --tickers VHM,FPT,HPG,VIC,MSN --max-articles 12 --skip-llm --output /tmp/corpus-expand-vietnambiz.sqlite
   ```
   - 4 sources × ~12 articles = ~48 articles target
   - Wall-clock budget: ~12 articles × 4 sources × 2.5s avg rate-limit = ~120s per source = ~8 min total (within session budget)
   - Charter compliance: respects I-S34 rate limits already enforced by each adapter
3. Extract `body_text` per article (use existing `ScrapedArticle.body_text` field at `packages/infrastructure/news/cafef_scraper.py:50` — flow: HTML → BeautifulSoup → extract `<article>` body → `.get_text()`)

**STOP-AND-ASK trigger (a)**: Corpus expansion fails (e.g. CafeF rate-limit-block / 4 sources all 5xx → 30-min wall-clock budget exceeded) → write `human-workspace/notifications/STOP-FINDING-S362-corpus-expansion-failed.md` with (1) which sources failed, (2) what error patterns, (3) options for user pick: (a) defer E.1 IMPL pending Phase D adapter fix, (b) proceed with smaller n=5-15 corpus + flag in observation as "thin-evidence eval", (c) ask user to provide alternative corpus

**Acceptance**: ≥30 articles available for STEP 0.3 evaluation (n=30 minimum threshold per architect calibration-floor; full n=50 preferred but n=30 sufficient for directional comparison)

### Sub-step 0.3 — Run 3 candidate tokenizers + score on financial-terms reference list

**Dev action**:

1. **Install candidate libraries in throwaway venv** (do NOT touch project pyproject.toml until STEP 0.5 selection):
   ```bash
   python -m venv /tmp/vn-tokenizer-eval && source /tmp/vn-tokenizer-eval/bin/activate
   pip install underthesea==<latest> 2>&1 | tee /tmp/underthesea-install.log
   pip install pyvi==<latest> 2>&1 | tee /tmp/pyvi-install.log
   # whitespace-baseline = no install needed (Python stdlib `re.split`)
   ```

2. **Tokenize each article body via 3 candidates**:
   ```python
   from underthesea import word_tokenize as ut_tokenize
   from pyvi import ViTokenizer
   import re
   
   def whitespace_baseline(text: str) -> list[str]:
       # Split on whitespace + punctuation; preserve word chars + Vietnamese diacritics
       return [t for t in re.split(r'[\s\.,;:!?\(\)"\'\-]+', text) if t]
   
   for article_body in corpus:
       ut_tokens = ut_tokenize(article_body)            # underthesea
       pv_tokens = ViTokenizer.tokenize(article_body).split()  # pyvi
       ws_tokens = whitespace_baseline(article_body)    # baseline
   ```

3. **Quality scoring** — token coverage on VN financial reference-term list:
   - Reference list (~50 VN financial multi-syllable terms): `cổ phiếu`, `thị trường`, `doanh nghiệp`, `lợi nhuận`, `cổ đông`, `chứng khoán`, `niêm yết`, `kết quả kinh doanh`, `tăng trưởng`, `lao dốc`, `đột phá`, `nhà đầu tư`, `quỹ đầu tư`, `tài sản`, `lãi suất`, `tỷ giá`, `vốn hóa`, `tự doanh`, `khối ngoại`, `khối nội`, `phái sinh`, `cơ bản`, `kỹ thuật`, `phân tích`, `dự báo`, `kế hoạch`, `chiến lược`, `thâu tóm`, `sáp nhập`, `mua lại`, `bán ròng`, `mua ròng`, `đặt lệnh`, `khớp lệnh`, `dư mua`, `dư bán`, `giao dịch`, `phiên giao dịch`, `chỉ số`, `phục hồi`, `điều chỉnh`, `tích lũy`, `phân phối`, `đầu cơ`, `đầu tư dài hạn`, `cắt lỗ`, `chốt lời`, `đu đỉnh`, `bắt đáy`, `đội lái`
   - **Quality metric**: % of reference terms preserved as single token (NOT split into syllables) when present in article body
   - Example: "cổ phiếu" → underthesea/pyvi should emit `["cổ_phiếu"]` (1 token); whitespace-baseline emits `["cổ", "phiếu"]` (2 tokens) = scoring miss
   - Per-candidate score: (count of single-token-preserved references / count of reference terms present in body) × 100%
   - Per-candidate aggregate: average across corpus articles

4. **STOP-AND-ASK trigger (b)**: All 3 candidates score <30% on quality metric → "all fail quality threshold" path per AQ-7 → write `human-workspace/notifications/STOP-FINDING-S362-tokenizer-all-fail-quality.md` with scorecard + options for user pick: (a) ship whitespace-baseline with DEFAULT-LOW-QUALITY docstring + flag for E.1-V2 retry, (b) defer E.1 IMPL pending PhoBERT evaluation cycle (~separate harness session), (c) expand corpus to n=150 articles + re-run eval (suggests current n=30 is too small for differentiation)

5. **STOP-AND-ASK trigger (c)**: Corpus too small to differentiate (e.g. all 3 candidates score within ±5% spread) → architect-judgement "thin evidence" → write `human-workspace/notifications/STOP-FINDING-S362-corpus-too-small.md` recommending expansion to ~150 articles

**Acceptance**: Per-candidate quality score recorded in `agent-workspace/calibration/vn_tokenizer_eval_v0.md` scorecard table

### Sub-step 0.4 — Measure perf (wall-clock per 1000 tokens) + install cost (pip install wall-clock + disk MB)

**Dev action**:

1. **Perf benchmark** — tokenize 100-article concatenated body × 10 iterations; record wall-clock per candidate; normalize to "ms per 1000 tokens"
2. **Install cost** — record (a) `pip install <lib>` wall-clock seconds, (b) `du -sh /tmp/vn-tokenizer-eval/lib/python*/site-packages/<lib>*/` disk MB
3. **Transitive deps audit** — `pip show <lib>` + `pip list` after each install; verify ZERO of [`patchright`, `playwright_stealth`, `playwright-stealth`, `fake_useragent`, `fake-useragent`, `UndetectedAdapter`, `StealthyFetcher`, `_cloudflare_solver`] (I-S34 HARD REJECT carry-forward)

**STOP-AND-ASK trigger**: NONE (perf + install cost are factual measurements; no decision gate)

**Acceptance**: Per-candidate perf + install + transitive-dep table recorded in scorecard

### Sub-step 0.5 — License classification + CHARTER-TIER GATE STOP-AND-ASK (if underthesea wins)

**Dev action**:

1. **Read each candidate's LICENSE file verbatim** (VBW per AOM):
   - underthesea: typically published under **GPL-3.0** per PyPI metadata + GitHub repo `undertheseanlp/underthesea/LICENSE` — **DEV VERIFIES via `pip show underthesea | grep License` AND opens the actual LICENSE file from the installed package directory**
   - pyvi: published under **MIT** per PyPI metadata + GitHub repo `trungtv/pyvi` — DEV VERIFIES same way
   - whitespace-baseline: own code under StockForge "Proprietary" license per pyproject.toml:7

2. **Classification matrix**:
   - **MIT / BSD-3 / Apache-2.0**: PERMISSIVE — no Charter-tier gate; ADR D-070 records license; proceed to STEP 0.6
   - **GPL-3.0 / AGPL / SSPL / other COPYLEFT**: CHARTER-TIER GATE FIRES — viral copyleft surface; StockForge currently dep stack is permissive-only per pyproject.toml audit; adopting copyleft = re-licensing question

3. **CHARTER-TIER GATE STOP-AND-ASK protocol** (per parent plan AQ-10 + § K.2 + this plan § CHARTER-TIER GATE):
   IF SELECTED candidate (= highest STEP 0.3 quality score) carries copyleft license:
   - DO NOT proceed to D1 IMPL
   - DO NOT pre-decide license posture
   - Write `human-workspace/notifications/STOP-FINDING-S362-underthesea-gpl3-license-gate.md` with:
     ```markdown
     ---
     level: ALERT
     created_at: 2026-05-XXTXX:XX:XXZ
     status: pending-user-pick
     decision_class: CHARTER-TIER
     ---
     
     # STOP-AND-ASK — underthesea GPL-3.0 license gate (S362 sub-plan 029 STEP 0.5)
     
     ## Empirical findings
     - **Quality scorecard** (% reference terms preserved as single token; n=<NN> articles):
       | Candidate | Quality | Install cost | Disk MB | License |
       |---|---|---|---|---|
       | underthesea | XX% | YYs | ZZ MB | GPL-3.0 (viral copyleft) |
       | pyvi        | XX% | YYs | ZZ MB | MIT |
       | whitespace  | XX% | 0s  | 0 MB  | own (Proprietary stack) |
     
     ## License classification
     - **underthesea**: GPL-3.0 verified via `<pip show output>` + `<LICENSE file path>:line` verbatim quote
     - **Implication**: Any code that LINKS to GPL-3.0 must also be GPL-3.0 (FSF copyleft doctrine). StockForge currently distributable per pyproject.toml:7 = "Proprietary"; adding underthesea = re-licensing question.
     - **Even pattern-only PORT from GPL-3.0 lib requires careful audit** per D-061 § Item 4 license discipline + recent VietnamBiz S358 F1 BSD-3 attribution remediation precedent
     
     ## Options for user ratification
     
     (a) **ACCEPT GPL-3.0 dep** — install underthesea + re-license StockForge to GPL-3.0
         - Pro: highest tokenization quality per empirical eval
         - Con: viral copyleft surface; future commercial flexibility constrained; sister projects (orch-starter) inherit license question
         - Action: dev installs underthesea + pyproject.toml license field changes "Proprietary" → "GPL-3.0" + every file gets GPL-3.0 header
     
     (b) **PATTERN-ONLY port from underthesea** — observe underthesea's tokenization approach + re-implement from public algorithm description (NO LOC import) under StockForge own license
         - Pro: avoids GPL surface; keeps Apache-style flexibility
         - Con: high implementation cost; may not reach underthesea quality; pattern-only audit risk (D-061 § Item 4 + BSD-3 precedent — even reading source code can pollute clean-room if not careful)
         - Action: dev defers underthesea install + designs whitespace++ heuristic informed by published VN word-segmentation literature (not source code)
     
     (c) **USE pyvi instead** — adopt MIT-licensed alternative even if quality is X% lower
         - Pro: zero license risk; permissive MIT family matches StockForge dep stack
         - Con: potentially lower quality (per empirical scorecard); E.1-V2 fallback trigger more likely
         - Action: dev installs pyvi + proceeds to D1-D4 with pyvi adapter
     
     ## Recommended option (architect-judgement per Karpathy P2 simplicity)
     - **IF pyvi quality within 10% of underthesea**: Option (c) — simplicity + license safety wins over marginal quality gap
     - **IF underthesea wins by >10% AND project owner has commercial flexibility constraint**: Option (b) — invest in pattern-port for long-term flexibility
     - **IF underthesea wins by >10% AND project owner accepts GPL-3.0**: Option (a) — adopt + re-license
     
     Awaiting user pick before S362 dev proceeds to D1.
     ```
   - Wait for user pick via AskUserQuestion gate dispatched by main session
   - DO NOT proceed to D1 until user pick recorded in `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` § Authorization field

**STOP-AND-ASK trigger (CHARTER-TIER GATE)**: SELECTED library license ∈ {GPL-3.0, AGPL, SSPL, any copyleft} → FIRE per § CHARTER-TIER GATE clause + § C above

**Acceptance**: License classification recorded in scorecard; CHARTER-TIER GATE FLAG (if fired) written + user pick received before D1 IMPL starts

### Sub-step 0.6 — I-S34 HARD REJECT transitive-dep grep

**Dev action**:

```bash
# After SELECTED candidate installed (post-STEP 0.5 user ratification if needed):
source /tmp/vn-tokenizer-eval/bin/activate
pip list | grep -iE "patchright|playwright[-_]stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|cloudflare"
# Expected: ZERO matches
```

**STOP-AND-ASK trigger**: ≥1 HARD-REJECT transitive dep surfaces → write `human-workspace/notifications/STOP-FINDING-S362-tokenizer-i-s34-hardreject.md` + DEFER E.1 IMPL pending dep-resolution OR alternative library

**Acceptance**: Empty grep result recorded in observation file

### Sub-step 0.7 — D-059 determinism contract check

**Dev action**:

```bash
# Smoke-test tokenizer output determinism:
python -c "
from <selected_lib> import tokenize
out1 = tokenize('Cổ phiếu VHM tăng 5% trong phiên giao dịch hôm nay.')
out2 = tokenize('Cổ phiếu VHM tăng 5% trong phiên giao dịch hôm nay.')
assert out1 == out2, f'NON-DETERMINISTIC: {out1} != {out2}'
print('OK: tokenizer is deterministic across 2 runs')
"
```

**STOP-AND-ASK trigger**: Output differs across 2 calls → SELECTED library has non-deterministic backend → DEFER E.1 IMPL OR pick alternative (NDH/whitespace-baseline as fallback)

**Acceptance**: Determinism smoke recorded in observation file

---

## D. Architecture Decisions (DD-1 through DD-6)

### DD-1: TokenizerProtocol design = Protocol (NOT ABC)

**Decision**: New port at `packages/application/nlp/ports/text_tokenizer_port.py` uses `typing.Protocol` NOT `abc.ABC`. Mirrors existing `LlmExtractorPort` at `packages/application/news/ports/llm_extractor_port.py:28` precedent.

```python
from typing import Protocol

class TextTokenizerPort(Protocol):
    """Tokenize VN text into syntactic word units."""
    def tokenize(self, text: str) -> list[str]:
        """Return ordered list of token strings (multi-syllable VN words preserved)."""
        ...
```

**Rationale**:
- Per Karpathy P2 simplicity — Protocol = structural typing; no runtime base-class machinery needed for a 1-method port
- Per DDD tactical patterns — Protocol is preferred for "duck typing under mypy --strict" path; existing LlmExtractorPort uses Protocol (precedent at `llm_extractor_port.py:28`)
- ABC `__init_subclass__` machinery only needed if runtime contract validation required (per CrawlerAdapter at `crawler_adapter.py:60-78` source_id ClassVar enforcement); tokenizer has no such requirement

**Adversarial alternate considered**: ABC with `@abstractmethod` → REJECTED (Protocol is lighter; no need for inheritance gate; mypy --strict catches missing methods at adapter import time)

### DD-2: Library selection = CONDITIONAL on STEP 0.5 user ratification (NOT pre-decided)

**Decision**: Architect DOES NOT pre-decide library. STEP 0.3-0.5 produce empirical scorecard; STEP 0.5 license classification determines if CHARTER-TIER GATE fires; user picks (a)/(b)/(c) per § C STEP 0.5 STOP-AND-ASK clause.

**Rationale**:
- Per Charter Principle 8 calibration over confidence — selection traces to evidence not popularity
- Per CHARTER-TIER GATE clause + parent plan AQ-10 — GPL-3.0 adoption is user-ratification decision NOT architect-decision
- Per Karpathy P1 think-before-coding — architect surfaces tradeoffs; user decides license posture

**Adversarial alternate considered**:
- (i) Pre-decide pyvi for license safety → REJECTED (forecloses on quality eval; ignores empirical evidence)
- (ii) Pre-decide underthesea for quality popularity → REJECTED (Charter Principle 8 + GPL-3.0 charter-tier surface)
- (iii) Pre-decide whitespace-baseline for simplicity → REJECTED (Karpathy P2 simplicity should ground in evidence not assumption; tokenization quality directly affects downstream E.2/E.3/E.4 sub-plan budget)

### DD-3: Tokenizer integration point = `apps/_shared/nlp/tokenizer.py` vs `packages/infrastructure/nlp/vn_tokenizer.py` — PICK packages/infrastructure/nlp/

**Decision**: Concrete adapter at `packages/infrastructure/nlp/vn_tokenizer.py` (NEW module + NEW `__init__.py`). Port at `packages/application/nlp/ports/text_tokenizer_port.py` (NEW namespace).

NOT `apps/_shared/nlp/tokenizer.py` (alternative considered).

**Rationale**:
- Parent plan-028 DD-7 mandates `application/nlp/ports/` for cross-BC capability (Theme I serves BC-5 + BC-6 + BC-7)
- Concrete adapters mirror existing `packages/infrastructure/news/claude_llm_extractor.py` precedent (infra adapter for application port)
- `apps/_shared/crawl/` precedent is for cross-app shared utilities (RateLimiter / RobotsTxtManager) that are infra-tier orchestration helpers; tokenizer is a CORE adapter behind a port (different layer concern)
- VN ticker resolver (sub-plan 032) lives at `apps/_shared/entities/` per parent DD-9 — that IS apps-tier shared utility; tokenizer is infra-tier behind port per DDD layered architecture

**Adversarial alternate considered**: Co-locate adapter at `apps/_shared/nlp/tokenizer.py` to match crawl/ precedent → REJECTED (parent DD-7 explicit; layer discipline mandates infra for port-backed adapter)

### DD-4: Test fixture strategy = synthetic VN text inline (NOT real corpus snapshot)

**Decision**: Test fixtures at `packages/infrastructure/nlp/test_vn_tokenizer.py` use SYNTHETIC inline VN text strings (architect-curated; ~10 short fixtures covering multi-syllable words + diacritics + edge cases). Real-corpus tokenization happens in D4 CLI smoke (NOT in unit tests).

**Rationale**:
- Mirror Phase D Theme L adapter test pattern (e.g. `test_vietstock_adapter.py` synthetic `_SYNTHETIC_VIETSTOCK_ARTICLE_HTML` fixtures at plan-026 D3)
- Real corpus snapshot in unit tests = .html files in repo = storage bloat + git-LFS surface + per-file BSD-3-style attribution risk (per VietnamBiz F1 inline-remediation precedent at S358)
- Synthetic fixtures are deterministic + auditable + small (each ~50-100 chars); cover quality scenarios (multi-syllable word preservation; diacritics; punctuation; mixed VN/English)
- Real-corpus eval = STEP 0 evidence + D4 CLI smoke (one-shot run; results in observation NOT in test suite)

**Adversarial alternate considered**: Save 1-3 real corpus articles gitignored at `data/fixtures/vn_tokenizer/*.html` → REJECTED (gitignored fixtures = non-reproducible tests; CI cannot run; defeats purpose of test fixtures)

### DD-5: Caching / memoization = DEFER to E.3 consumer (no premature optimization)

**Decision**: VnTokenizer is pure-function wrapper; NO internal cache. If E.3 sub-plan 031 surfaces measurable repeated-tokenization-on-same-body latency, E.3 IMPL adds memoization at consumer layer (NOT at tokenizer-adapter layer).

**Rationale**: Karpathy P2 simplicity; premature optimization anti-pattern per master plan Out-of-scope item; tokenizer is CPU-bound and modern VN tokenizers (underthesea/pyvi) typically process article bodies in <100ms (perf-bound by article length not by repeated calls)

**Adversarial alternate considered**: Add LRU cache `@functools.lru_cache(maxsize=128)` on tokenize method → REJECTED (premature; adds memory pressure; complicates determinism testing in D3)

### DD-6: Type stubs strategy = `cast(list[str], ...)` + targeted `# type: ignore[no-any-return]` with comment OR vendor minimal stub

**Decision**: SELECTED library likely lacks official type stubs (underthesea + pyvi both ship without .pyi files per PyPI inspection). VnTokenizer adapter handles this via:

```python
def tokenize(self, text: str) -> list[str]:
    raw = self._lib_tokenize(text)  # type: ignore[no-any-return]  # underthesea/pyvi lacks stubs; runtime returns list[str] per docstring
    return cast(list[str], raw)
```

IF mypy --strict surfaces ≥3 type:ignore in this adapter → vendor minimal stub at `packages/infrastructure/nlp/<lib>_stubs.pyi` (~10 LOC stub covering the 1-2 methods we use); this is the AP-23 n=3 trigger for stub-vendoring (matches type:ignore promote-to-stub calculus surfaced repeatedly in adapter code)

**Rationale**: Per mypy --strict + `disallow_any_explicit=true` (pyproject.toml:95); `cast(list[str], ...)` + targeted type:ignore is the minimum-friction path; stub-vendoring is heavier infra carried by AP-23 n=3 trigger

**Adversarial alternate considered**:
- (i) Use `Any`-typed return + propagate → REJECTED (pyproject.toml `disallow_any_explicit=true` blocks this)
- (ii) Vendor stub upfront → REJECTED (premature; mypy may accept cast + type:ignore for n=1-2 instances)
- (iii) Add lib to `[[tool.mypy.overrides]]` `ignore_missing_imports = true` → REJECTED (silences too broadly; loses type safety on other-lib-method calls)

---

## E. Sub-track decomposition (D1-D4 with parallel_with per plan-025 contract)

### D1 — TextTokenizerPort Protocol (foundation; root sub-track)

- **parallel_with**: []  (foundation; D2 blocks_on D1)
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/application/nlp/__init__.py, packages/application/nlp/ports/__init__.py, packages/application/nlp/ports/text_tokenizer_port.py]
- **estimated_wall_min**: 3

**Module**: `packages/application/nlp/ports/text_tokenizer_port.py` (NEW; ~50 LOC).

**Content** (architect-proposed; dev verifies + adjusts):

```python
"""TextTokenizerPort — abstract port for VN text tokenization.

Per architecture.md § Ports & Adapters + parent plan-028 DD-7: NLP is a
cross-BC capability (BC-5 News Stream + BC-6 Influence + BC-7 Crowd all
consume tokenized VN text), so the port lives in application/nlp/ (NEW
namespace) accessible across BCs. Concrete adapters live in
packages/infrastructure/nlp/.

Source: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md
         § DD-7 (cross-BC NLP port location);
         agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
         § DD-1 (Protocol vs ABC).
"""

from __future__ import annotations

from typing import Protocol

__all__ = ["TextTokenizerPort"]


class TextTokenizerPort(Protocol):
    """Tokenize VN text into syntactic word units.

    Implementations MUST:
    - Be deterministic — same input string ⇒ same output token list (D-059 R2
      compliance; verifier grep-asserts determinism smoke).
    - Return [] for empty / whitespace-only input (NOT raise).
    - Preserve multi-syllable VN words as single tokens where the underlying
      library supports it (e.g. "cổ phiếu" → "cổ_phiếu" OR "cổ phiếu" as
      ONE element; specific separator chosen by adapter at IMPL time).

    Implementations MAY:
    - Strip punctuation / normalize whitespace at their discretion.
    - Cap input text length at a sensible upper bound (e.g. 100K chars) and
      return [] for over-long inputs (callers shall check token list length).
    """

    def tokenize(self, text: str) -> list[str]:
        """Return ordered list of token strings for `text`."""
        ...
```

Also create `packages/application/nlp/__init__.py` (empty package marker, ~3 LOC) + `packages/application/nlp/ports/__init__.py` (exports TextTokenizerPort, ~5 LOC).

**Verify**: mypy --strict + ruff PASS on the 3 new files

### D2 — VnTokenizer concrete adapter

- **parallel_with**: []  (D3 + D4 block_on D2)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/nlp/__init__.py, packages/infrastructure/nlp/vn_tokenizer.py, pyproject.toml (one-line dep add if SELECTED != whitespace), agent-workspace/memory/decisions/070-vn-tokenizer-library.md]
- **estimated_wall_min**: 12

**Module**: `packages/infrastructure/nlp/vn_tokenizer.py` (NEW; ~150 LOC).

**Skeleton** (architect-proposed; dev fills SELECTED library import + tokenize call after STEP 0.5):

```python
"""VnTokenizer — concrete TextTokenizerPort adapter using <SELECTED_LIB>.

<SELECTED_LIB> selected via STEP 0.3-0.5 empirical evaluation on ~30-50
article VN financial-news corpus. License classification per STEP 0.5
recorded in ADR D-070.

D-059 compliance:
- R1 (datetime-no-tz): N/A — tokenizer is pure text transform; no datetime.
- R2 (unseeded RNG): N/A — tokenizer is deterministic per Protocol contract;
  verifier smoke at S363 confirms.
- R4 (time.time-in-domain): N/A — infrastructure adapter, not domain.

I-S34 HARD REJECT compliance: STEP 0.6 verified <SELECTED_LIB> has ZERO
transitive deps in [patchright, playwright_stealth, fake-useragent,
UndetectedAdapter, StealthyFetcher, cloudflare-solver]; verifier re-grep
at S363.

Source: agent-workspace/session-plans/pending/029-S361-phase-e1-vn-tokenization.md
         § D2 + DD-2 (SELECTED library = <SELECTED_LIB> per STEP 0.5);
         agent-workspace/memory/decisions/070-vn-tokenizer-library.md
         (ADR records selection rationale + revisit triggers).
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass
from typing import cast

__all__ = ["VnTokenizer", "WhitespaceTokenizer"]

_log = logging.getLogger(__name__)

# CONDITIONAL: import SELECTED_LIB at module level OR lazy in __post_init__
# Architect-recommendation: LAZY import in __post_init__ so test suite doesn't
# require SELECTED_LIB to be installed (test fixtures use WhitespaceTokenizer
# OR mock).


_VN_DIACRITIC_CHARS = (
    "àáảãạâầấẩẫậăằắẳẵặ"
    "èéẻẽẹêềếểễệ"
    "ìíỉĩị"
    "òóỏõọôồốổỗộơờớởỡợ"
    "ùúủũụưừứửữự"
    "ỳýỷỹỵđ"
    "ÀÁẢÃẠÂẦẤẨẪẬĂẰẮẲẴẶ"
    "ÈÉẺẼẸÊỀẾỂỄỆ"
    "ÌÍỈĨỊ"
    "ÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ"
    "ÙÚỦŨỤƯỪỨỬỮỰ"
    "ỲÝỶỸỴĐ"
)

_WHITESPACE_TOKEN_RE = re.compile(
    rf"[^\w{_VN_DIACRITIC_CHARS}]+"
)


@dataclass(frozen=True, slots=True)
class WhitespaceTokenizer:
    """Naive whitespace+punctuation tokenizer. Zero-dependency baseline.

    Used as default fallback per AQ-7 if SELECTED library install fails OR
    all 3 candidates score <30% quality threshold per STEP 0.3.

    Does NOT preserve multi-syllable VN words (per design — that's why we
    have a SELECTED library; this is the LOW-QUALITY fallback).
    """

    selected_library: str = "whitespace-baseline-v0"

    def tokenize(self, text: str) -> list[str]:
        if not text or not text.strip():
            return []
        return [t for t in _WHITESPACE_TOKEN_RE.split(text) if t]


@dataclass
class VnTokenizer:
    """VN tokenizer wrapping <SELECTED_LIB> behind TextTokenizerPort.

    Constructor takes no arguments; SELECTED_LIB is imported lazily on first
    tokenize() call. Tests use WhitespaceTokenizer to avoid SELECTED_LIB
    install requirement.
    """

    selected_library: str = "<SELECTED_LIB>"  # filled at IMPL per STEP 0.5

    def __post_init__(self) -> None:
        self._tokenize_fn: object | None = None  # lazy-loaded

    def tokenize(self, text: str) -> list[str]:
        if not text or not text.strip():
            return []
        if self._tokenize_fn is None:
            self._load_lib()
        # DEV FILLS at IMPL: actual library call shape
        # Example (underthesea):
        #   from underthesea import word_tokenize
        #   raw = word_tokenize(text)  # type: ignore[no-any-return]
        #   return cast(list[str], raw)
        # Example (pyvi):
        #   from pyvi import ViTokenizer
        #   raw_str = ViTokenizer.tokenize(text)  # type: ignore[no-any-return]
        #   return cast(str, raw_str).split()
        raise NotImplementedError("STEP 0.5 dev fills this method")

    def _load_lib(self) -> None:
        """Lazy import of SELECTED_LIB. Caches reference for reuse."""
        # DEV FILLS at IMPL:
        # try:
        #     import <selected_lib>
        #     self._tokenize_fn = <selected_lib>.<tokenize_method>
        # except ImportError as e:
        #     raise RuntimeError(
        #         f"VnTokenizer requires <selected_lib>; install via "
        #         f"`pip install {self.selected_library}`. Underlying: {e}"
        #     ) from e
        raise NotImplementedError("STEP 0.5 dev fills this method")
```

**ADR D-070 PROPOSED** at `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (NEW; per CLAUDE.md ADR template):

```markdown
---
id: 070
title: VN Tokenizer Library Selection
status: PROPOSED at IMPL tier (auto-ratifies per severity-schema on commit; user-ratification REQUIRED if STEP 0.5 CHARTER-TIER GATE fired)
date: 2026-05-XX
authors: sandwich-dev S362
supersedes: []
superseded-by: []
empirical_close_verify: |
  - VnTokenizer class instantiable + tokenize() returns deterministic list[str] on synthetic VN text
  - mypy --strict + ruff + pytest on packages/infrastructure/nlp/ exit 0
  - STEP 0 scorecard recorded at agent-workspace/calibration/vn_tokenizer_eval_v0.md
  - License classification recorded inline below
---

## Decision

SELECTED library = <DEV FILLS post-STEP 0.5>; license = <DEV FILLS>; selection rationale traces to STEP 0 empirical scorecard.

## Empirical scorecard (STEP 0.3-0.4)

| Candidate | Quality % | Perf ms/1000 tokens | Install MB | License | Selected? |
|---|---|---|---|---|---|
| underthesea | XX% | YY | ZZ | GPL-3.0 | <YES/NO> |
| pyvi | XX% | YY | ZZ | MIT | <YES/NO> |
| whitespace baseline | XX% | YY | 0 | own | <YES/NO> |

## CHARTER-TIER GATE outcome (STEP 0.5)

<DEV FILLS — one of:>
- "NOT FIRED — SELECTED candidate is MIT/Apache/BSD permissive; no user ratification needed"
- "FIRED — user picked option (a/b/c) per notification STOP-FINDING-S362-underthesea-gpl3-license-gate.md → <decision recorded>"

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. SELECTED library quality <50% on sub-plan 030 held-out corpus eval (n=200+) → E.1-V2 PhoBERT fallback evaluation
2. SELECTED library transitive-dep update introduces I-S34 HARD REJECT artifact → emergency unpin + revert to whitespace-baseline
3. SELECTED library license changes (quarterly re-verify cycle per NOTICE precedent) → CHARTER-TIER re-gate

## Risks

- RM1: <SELECTED_LIB> abandonment (no maintenance) → AP-7 trigger 2 above
- RM2: tokenizer-output drift across <SELECTED_LIB> versions → pin exact version in pyproject.toml
```

**Verify**: ADR D-070 file exists; mypy --strict + ruff PASS

### D3 — Unit tests (≥10 test cases; parallel with D4)

- **parallel_with**: [D4]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [packages/infrastructure/nlp/test_vn_tokenizer.py]
- **estimated_wall_min**: 8

**Module**: `packages/infrastructure/nlp/test_vn_tokenizer.py` (NEW; ~250 LOC; ≥10 test cases).

**Test cases (target ≥10)**:

1. `test_whitespace_tokenizer_basic_vn_text` — `WhitespaceTokenizer().tokenize("Cổ phiếu VHM tăng 5%")` returns `["Cổ", "phiếu", "VHM", "tăng", "5"]`
2. `test_whitespace_tokenizer_empty_string_returns_empty_list` — `WhitespaceTokenizer().tokenize("")` returns `[]` (NOT raises)
3. `test_whitespace_tokenizer_whitespace_only_returns_empty_list` — `WhitespaceTokenizer().tokenize("   \n\t  ")` returns `[]`
4. `test_whitespace_tokenizer_preserves_diacritics` — `WhitespaceTokenizer().tokenize("đu đỉnh bắt đáy")` returns `["đu", "đỉnh", "bắt", "đáy"]` (NOT stripped to "du dinh bat day")
5. `test_whitespace_tokenizer_strips_punctuation` — `WhitespaceTokenizer().tokenize("Hôm nay, VHM giảm 2%.")` returns `["Hôm", "nay", "VHM", "giảm", "2"]`
6. `test_whitespace_tokenizer_deterministic_across_runs` — call `tokenize(text)` twice; assert outputs identical (D-059 R2 compliance smoke)
7. `test_vn_tokenizer_preserves_multi_syllable_vn_words` — `VnTokenizer().tokenize("cổ phiếu thị trường")` returns at minimum 2 tokens (depending on SELECTED library this may be `["cổ_phiếu", "thị_trường"]` OR `["cổ phiếu", "thị trường"]` — test asserts len < 4 vs whitespace which would give 4); skip if SELECTED == whitespace-baseline
8. `test_vn_tokenizer_handles_mixed_vn_english` — `VnTokenizer().tokenize("VHM tăng 5% trong Q1 2026")` returns ordered list containing `"VHM"` (uppercase preserved) + `"tăng"` + diacritics preserved
9. `test_vn_tokenizer_returns_list_str_typing` — assert isinstance(tokens, list) and all(isinstance(t, str) for t in tokens) (Protocol contract validation)
10. `test_vn_tokenizer_satisfies_text_tokenizer_port_protocol` — duck-type check via `assert hasattr(VnTokenizer(), "tokenize")` AND mypy structural typing test passes (one-liner: `_: TextTokenizerPort = VnTokenizer()`)
11. `test_vn_tokenizer_handles_long_input_gracefully` — `VnTokenizer().tokenize("VHM " * 10000)` returns list (not raises); cap behavior optional per port Protocol
12. `test_vn_tokenizer_logs_warning_on_lib_load_failure` — mock-patch SELECTED_LIB import to ImportError; assert VnTokenizer raises RuntimeError with install hint (CONDITIONAL — only if SELECTED != whitespace-baseline)

**Synthetic fixtures (architect-proposed; inline strings):**

```python
_SYNTHETIC_VN_FINANCIAL_TEXT = (
    "Cổ phiếu VHM tăng 5% trong phiên giao dịch hôm nay. "
    "Thị trường chứng khoán Việt Nam đang trong giai đoạn tích lũy. "
    "Nhà đầu tư khối ngoại bán ròng 200 tỷ đồng."
)

_SYNTHETIC_VN_PUMP_ANCHOR_TEXT = (
    "Đội lái đẩy giá cổ phiếu MSN lên mức trần. "
    "Cảnh báo: nhà đầu tư mới có thể đu đỉnh."
)

_SYNTHETIC_MIXED_VN_EN = "VHM Q1 2026 lợi nhuận đạt 1.5 trillion VND."
```

**Acceptance**: pytest exit 0; ≥10 cases pass; mypy --strict + ruff clean

### D4 — Integration smoke + CLI tokenizer harness (parallel with D3)

- **parallel_with**: [D3]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/cli/tokenize_vn_text.py, agent-workspace/calibration/vn_tokenizer_eval_v0.md]
- **estimated_wall_min**: 5

**Module**: `apps/cli/tokenize_vn_text.py` (NEW; ~80 LOC click harness).

**Functionality**:
- `--input-sqlite <path>`: read NewsArticle rows; tokenize body_excerpt; emit token list + count per article
- `--input-html-dir <path>`: read all .html files in dir; tokenize body_text (via BeautifulSoup parse); emit token list + count per file
- `--limit <N>`: cap articles processed (default 10)
- `--output <path>`: write JSON report `{article_id, token_count, sample_tokens: first_50_tokens, lib_used}` per row
- `--summary`: print to stdout: total articles processed + avg token count + perf ms-per-article

**CLI smoke at S362 close** (live verification — manual; recorded in session log):

```bash
python apps/cli/tokenize_vn_text.py \
  --input-html-dir data/raw/news/vietstock/2026-05-16/ \
  --limit 5 \
  --output /tmp/tokenize-smoke.json \
  --summary 2>&1 | tee /tmp/tokenize-smoke.log
```

Record in session log:
- Selected library + version used
- Total articles processed (expected: 2 for Vietstock 2026-05-16 dir; OR 5 if pointed at data/raw/news/ root)
- Per-article token count + perf ms
- Verify deterministic across 2 runs (`diff /tmp/tokenize-smoke-1.json /tmp/tokenize-smoke-2.json` → empty)
- Sample first 10 tokens from each article (sanity-check VN multi-syllable preservation if SELECTED != whitespace)

**STEP 0 scorecard write to `agent-workspace/calibration/vn_tokenizer_eval_v0.md`** (NEW file; ~80 LOC):

```markdown
# VN Tokenizer Library Evaluation v0 — STEP 0 scorecard (S362)

> Empirical scorecard from sub-plan 029-S361-phase-e1-vn-tokenization STEP 0.
> Source: S362 dev observation + ADR D-070.
> Re-eval trigger: per ADR D-070 revisit trigger 1 (sub-plan 030 held-out corpus <50% quality)

## Corpus

- N=<NN> articles sampled from data/raw/news/<sources>/<dates>/
- Source distribution: CafeF=<a> / NDH=<b> / Vietstock=<c> / VietnamBiz=<d>

## Reference financial-term list (50 terms)

<verbatim list from STEP 0.3>

## Per-candidate scorecard

| Candidate | Quality % | Perf ms/1000 tokens | Install MB | License | Selected? |
|---|---|---|---|---|---|
| underthesea | XX% | YY | ZZ | GPL-3.0 | <Y/N> |
| pyvi | XX% | YY | ZZ | MIT | <Y/N> |
| whitespace baseline | XX% | YY | 0 | own | <Y/N> |

## Selection decision

<DEV FILLS — citing STEP 0.5 user pick if CHARTER-TIER GATE fired, OR per-candidate Pareto front otherwise>

## Re-use for sub-plan 030

This scorecard is the corpus baseline for sub-plan 030 sentiment lexicon calibration. Sub-plan 030 expands n=200-500 + adds labelling layer.
```

**Acceptance**: CLI runs without exception; JSON output well-formed; smoke log captured; scorecard file written

---

## F. Definition of Done (DoD ≥25 items)

Aggregated across STEP 0 + D1-D4 + ADR + bookkeeping; verifier S363 confirms each empirically.

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/application/nlp/__init__.py` exists (NEW namespace marker)
- [ ] **DC-FILE-2** — `packages/application/nlp/ports/__init__.py` exists (exports `TextTokenizerPort`)
- [ ] **DC-FILE-3** — `packages/application/nlp/ports/text_tokenizer_port.py` exists (per D1)
- [ ] **DC-FILE-4** — `packages/infrastructure/nlp/__init__.py` exists (NEW namespace marker; exports `VnTokenizer` + `WhitespaceTokenizer`)
- [ ] **DC-FILE-5** — `packages/infrastructure/nlp/vn_tokenizer.py` exists (per D2)
- [ ] **DC-FILE-6** — `packages/infrastructure/nlp/test_vn_tokenizer.py` exists (per D3)
- [ ] **DC-FILE-7** — `apps/cli/tokenize_vn_text.py` exists (per D4)
- [ ] **DC-FILE-8** — `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` exists (per D2 ADR landing)
- [ ] **DC-FILE-9** — `agent-workspace/calibration/vn_tokenizer_eval_v0.md` exists (per D4 STEP 0 scorecard write)
- [ ] **DC-FILE-10** — `agent-workspace/memory/sessions/2026-05-XX-session-362.md` exists (per CLAUDE.md § Session Protocol End)
- [ ] **DC-FILE-11** — `agent-workspace/memory/observations/sandwich-dev-S362-vn-tokenizer.md` exists (per Track 6)

### Implementation contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — `TextTokenizerPort` is `typing.Protocol` (NOT `abc.ABC`) per DD-1
- [ ] **DC-IMPL-2** — `TextTokenizerPort.tokenize` signature is `(self, text: str) -> list[str]` (Protocol contract)
- [ ] **DC-IMPL-3** — `VnTokenizer.tokenize` returns `list[str]` empirically (D3 test 9 asserts)
- [ ] **DC-IMPL-4** — `WhitespaceTokenizer` exists as fallback per AQ-7 (DEFAULT-LOW-QUALITY docstring present)
- [ ] **DC-IMPL-5** — `VnTokenizer.__post_init__` does NOT import SELECTED_LIB at class body (lazy-load on first tokenize call per DD-6)
- [ ] **DC-IMPL-6** — `VnTokenizer` selected_library field matches ADR D-070 § Decision line

### STEP 0 compliance DC (DC-STEP0-N)

- [ ] **DC-STEP0-1** — Dev observation cites parent plan-028 § DD-3 + K.2 + AQ-7 + AQ-10 line numbers verbatim (per STEP 0.1)
- [ ] **DC-STEP0-2** — Corpus inventory ≥30 articles recorded in scorecard (per STEP 0.2)
- [ ] **DC-STEP0-3** — Per-candidate quality scores recorded in scorecard (per STEP 0.3) — 3 rows minimum
- [ ] **DC-STEP0-4** — Per-candidate perf + install MB recorded in scorecard (per STEP 0.4)
- [ ] **DC-STEP0-5** — License classification recorded in scorecard + ADR D-070 (per STEP 0.5)
- [ ] **DC-STEP0-6** — IF GPL-3.0 trigger fired: `human-workspace/notifications/STOP-FINDING-S362-underthesea-gpl3-license-gate.md` exists AND user pick recorded in ADR D-070 § Authorization (per § CHARTER-TIER GATE)
- [ ] **DC-STEP0-7** — I-S34 HARD-REJECT transitive-dep grep result recorded (per STEP 0.6) — zero matches expected
- [ ] **DC-STEP0-8** — D-059 determinism smoke recorded (per STEP 0.7) — output identical across 2 runs

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/application/nlp/ packages/infrastructure/nlp/ apps/cli/tokenize_vn_text.py` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/application/nlp/ packages/infrastructure/nlp/ apps/cli/tokenize_vn_text.py` exits 0
- [ ] **DC-GATE-3** — `python -m pytest packages/infrastructure/nlp/test_vn_tokenizer.py -q` exits 0; ≥10 test cases pass
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0 baseline + ≥10; ZERO regression on baseline
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression; no new firing-test expected)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on new files (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — Charter compliance grep — ZERO `import anthropic` / `import openai` / direct LLM SDK call in `packages/application/nlp/` OR `packages/infrastructure/nlp/` (tokenizer is LLM-free by construction)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke executed against `data/raw/news/vietstock/2026-05-16/` (or any available corpus); recorded in session log with N articles processed + total token count + perf ms
- [ ] **DC-SMOKE-2** — Smoke produced JSON output at `/tmp/tokenize-smoke.json` with well-formed per-article rows
- [ ] **DC-SMOKE-3** — Determinism smoke — `diff` of two consecutive smoke runs returns empty (validates tokenizer is deterministic across runs per D-059 R2)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-362.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase E sub-plan 029 row reflects E.1 Tokenization SHIPPED at S362; next-action = S363 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S362-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/029-S361-phase-e1-vn-tokenization.md` → `completed/029-S361-phase-e1-vn-tokenization.md` at S363 close (NOT at S362 close — verifier acceptance gates the move per plan-020/022/026/027 precedent)
- [ ] **DC-BOOK-5** — ADR D-070 PROPOSED status reflected in `agent-workspace/memory/decisions/README.md` index

### Total DoD count: 33 items (≥25 floor satisfied)

---

## G. Architecture Questions (AQ-1..AQ-8) — pre-answered

### AQ-1 — Why DEPENDENCY-EVAL pattern not "just adopt underthesea"?

**Answer**: Per parent plan-028 AQ-3 + Charter Principle 8 calibration over confidence — adopt based on empirical STEP 0 evidence not popularity. STEP 0 evaluation is cheap (~50-article benchmark + 30 min wall) relative to wrong-choice rework cost (e.g. adopting GPL-3.0 then having to re-license OR pattern-port later). Plus underthesea's GPL-3.0 license is itself a CHARTER-TIER consideration that user MUST decide — architect cannot pre-decide.

### AQ-2 — Why Protocol not ABC for TokenizerProtocol?

**Answer**: Per DD-1. Protocol is lighter; no runtime base-class machinery needed for a 1-method port; existing `LlmExtractorPort` at `packages/application/news/ports/llm_extractor_port.py:28` uses Protocol — same precedent. ABC's `__init_subclass__` only needed for runtime contract validation (per CrawlerAdapter's `source_id` ClassVar enforcement); tokenizer has no such requirement.

### AQ-3 — Why packages/infrastructure/nlp/ not apps/_shared/nlp/?

**Answer**: Per DD-3 + parent plan DD-7. Theme I = cross-BC capability (BC-5 + BC-6 + BC-7); cross-BC port lives at `packages/application/nlp/ports/` per DDD architecture; concrete adapter behind port lives at infra `packages/infrastructure/nlp/`. `apps/_shared/` precedent is for cross-app shared utilities (RateLimiter / RobotsTxtManager) that are infra-tier orchestration helpers — different layer concern. VN ticker resolver (sub-plan 032) lives at `apps/_shared/entities/` because alias-table lookup IS apps-tier shared utility; tokenizer is infra adapter behind a port.

### AQ-4 — STEP 0 finds underthesea AND pyvi both score <30% — what then?

**Answer**: Per AQ-7 (parent plan) + DD-2. Ship WhitespaceTokenizer (D2 fallback) with DEFAULT-LOW-QUALITY docstring + flag for E.1-V2 retry. Phase E does NOT block; downstream sub-plans 030/031/032 use the baseline tokenizer; lexicon coverage + extractor quality may be suboptimal but functional. STOP-AND-ASK trigger (b) per § C STEP 0.3 fires for user awareness.

### AQ-5 — STEP 0 finds SELECTED library has I-S34 HARD-REJECT transitive dep — what then?

**Answer**: Per STEP 0.6 STOP-AND-ASK. Write `STOP-FINDING-S362-tokenizer-i-s34-hardreject.md`; DEFER E.1 IMPL pending (a) dep-resolution upstream (file issue with SELECTED library maintainers) OR (b) pick next-best candidate per scorecard OR (c) WhitespaceTokenizer fallback. Main session dispatches AskUserQuestion gate.

### AQ-6 — STEP 0 finds SELECTED library is non-deterministic — what then?

**Answer**: Per STEP 0.7 STOP-AND-ASK. Determinism is D-059 R2 BINDING + Protocol contract requirement. Non-determinism = library has either (a) hidden random seed bug OR (b) thread-state mutation. DEFER E.1 IMPL pending root-cause investigation OR pick next-best deterministic candidate. STOP-FINDING file written.

### AQ-7 — Why no caching/memoization in v0?

**Answer**: Per DD-5 + Karpathy P2 simplicity. Tokenizer is pure-function CPU-bound; modern VN tokenizers process article bodies in <100ms; premature optimization anti-pattern. If E.3 sub-plan 031 surfaces measurable repeated-tokenization latency, E.3 IMPL adds memoization at consumer layer (NOT at tokenizer-adapter layer).

### AQ-8 — Why test fixtures inline synthetic not gitignored real corpus?

**Answer**: Per DD-4. Real corpus in tests = .html files in repo = storage bloat + git-LFS surface + per-file BSD-3-style attribution risk (per S358 VietnamBiz F1 inline-remediation precedent). Synthetic inline = deterministic + auditable + small (each ~50-100 chars); cover quality scenarios. Real-corpus eval lives in STEP 0 observation file + D4 CLI smoke (one-shot run; results in observation NOT in test suite). Gitignored fixtures = non-reproducible tests = CI cannot run = defeats purpose.

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (parent plan) | Source 2 (supplement) | Source 3 (charter invariant) | Source 4 (existing stockforge code) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | DD-1 Protocol over ABC | parent plan-028 (sub-plan template ref) | n/a | DDD tactical pattern (Karpathy P2 simplicity) | `packages/application/news/ports/llm_extractor_port.py:28` (Protocol precedent for 1-method port) | `typing.Protocol` PEP 544 |
| 2 | DD-2 CONDITIONAL library selection | parent plan-028 § DD-3 (DEPENDENCY-EVAL pattern at sub-plan PLAN level) + AQ-10 (license ratification) | research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § Theme I line 249 (underthesea/pyvi/cli-tool comparison) | Charter Principle 8 (calibration over confidence) + I-S20 (calibration over confidence) | `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` § STEP 0 evaluated crawl4ai vs Scrapling vs MediaCrawler (DEPENDENCY-EVAL precedent at plan level) | underthesea GitHub repo `undertheseanlp/underthesea` README + LICENSE; pyvi GitHub repo `trungtv/pyvi` README + LICENSE (STEP 0.5 reads verbatim) |
| 3 | DD-3 packages/infrastructure/nlp adapter location | parent plan-028 § DD-7 (cross-BC `application/nlp/ports/`) + DD-9 (`apps/_shared/entities/` for ticker resolver — different layer concern) | n/a | DDD layered architecture per `agent-workspace/constitution/architecture.md` BC discipline | `packages/infrastructure/news/claude_llm_extractor.py` (infra adapter behind application port precedent) + `apps/_shared/crawl/__init__.py` (apps-tier shared utility for orchestration helpers — different concern) | DDD tactical patterns skill `.claude/skills/ddd-tactical-patterns/SKILL.md` (Port + Adapter discipline) |
| 4 | DD-4 synthetic inline fixtures over gitignored corpus | parent plan-028 § D4 (test fixture strategy alignment) | n/a | I-S2 citation discipline (reproducibility) + Karpathy P2 simplicity | `packages/infrastructure/news/crawler_adapters/test_vietstock_adapter.py` (synthetic `_SYNTHETIC_VIETSTOCK_ARTICLE_HTML` fixtures precedent from plan-026 D3) | crawler-reliability skill § VBW for Scrapers (synthetic fixture style) |
| 5 | DD-6 type-stubs strategy (`cast` + `type:ignore` first; vendor stub at n=3) | parent plan-028 (mypy strict mandate) | n/a | mypy strict per `pyproject.toml:90-103` (disallow_any_explicit=true) | `apps/_shared/crawl/rate_limiter.py` (D-059 compliance comment pattern) + existing adapter code using `type: ignore[no-any-return]` precedent | mypy docs `disallow_any_explicit` semantics + `cast` PEP 484 |

---

## I. STEP 0 STOP-AND-ASK trigger inventory (3 documented per dispatch brief)

Per dispatch brief § STEP 0 BLOCKING:

| Trigger ID | Sub-step | Condition | STOP-FINDING file path | User decision class |
|---|---|---|---|---|
| **(a) CHARTER-TIER GATE** | 0.5 | SELECTED library license is GPL-3.0 / AGPL / SSPL / any copyleft | `human-workspace/notifications/STOP-FINDING-S362-underthesea-gpl3-license-gate.md` | CHARTER-TIER (re-license OR pattern-port OR alternative lib pick) |
| **(b) all-fail-quality-threshold** | 0.3 | All 3 candidates score <30% on quality metric | `human-workspace/notifications/STOP-FINDING-S362-tokenizer-all-fail-quality.md` | SCOPE-TIER (ship WhitespaceTokenizer fallback OR defer for PhoBERT cycle OR expand corpus) |
| **(c) corpus-too-small** | 0.3 | All 3 candidates score within ±5% (insufficient differentiation) | `human-workspace/notifications/STOP-FINDING-S362-corpus-too-small.md` | TACTICAL-TIER (expand corpus to ~150 articles + re-run) |
| **(d) I-S34 HARD-REJECT transitive dep** | 0.6 | ≥1 of [patchright/playwright_stealth/fake_useragent/StealthyFetcher/cloudflare-solver] in transitive deps | `human-workspace/notifications/STOP-FINDING-S362-tokenizer-i-s34-hardreject.md` | TACTICAL-TIER (alternative lib OR defer) |
| **(e) non-determinism** | 0.7 | Tokenizer output differs across 2 calls on same input | `human-workspace/notifications/STOP-FINDING-S362-tokenizer-non-deterministic.md` | TACTICAL-TIER (alternative lib OR defer) |
| **(f) corpus-expansion-failed** | 0.2 | Adapter CLIs fail to expand corpus to n≥30 (30-min budget exceeded) | `human-workspace/notifications/STOP-FINDING-S362-corpus-expansion-failed.md` | TACTICAL-TIER (defer OR thin-evidence proceed OR alternative corpus) |

**Dispatch brief specified 3 triggers**: (a) CHARTER-TIER GATE, (b) all-fail-quality-threshold, (c) corpus-too-small. **Architect adds 3 additional triggers**: (d) I-S34 + (e) determinism + (f) corpus-expansion — per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding (surface all failure modes upfront, not after they fire).

---

## J. Risks & Mitigation (RM1-RM8)

### RM1 — Cold-start budget over/under-estimation (LIKELY-MEDIUM)
**Risk**: Phase 1b cold-start at sample_size=0 means budget envelope is boilerplate-derived not empirically grounded; S362 dev may finish under 60K OR exceed 130K (e.g. STEP 0 STOP-AND-ASK adds 10-30K depending on which triggers fire + how many gate cycles).
**Mitigation**: Full 100-150K envelope honored for cold-start absorption; sub-plans 030/031/032 inherit precedent from THIS sub-plan post-S362 ship (n=0 → n=1 incremental calibration per parent plan L-S360-2). Worst case: STOP-AND-ASK budget consumed → re-dispatch S362 dev after user gate clears.

### RM2 — STEP 0 evaluation paralysis (LIKELY-LOW)
**Risk**: S362 dev spends excessive budget on STEP 0 library evaluation (e.g. exploring 5+ candidates instead of 3; benchmarking with overengineered metrics).
**Mitigation**: STEP 0 has hard 30-min wall-clock budget cap per sub-step; AQ-4 pre-answers "both fail quality bar" path (ship WhitespaceTokenizer + flag); architect bias = ship-soon + iterate-with-evidence (Karpathy P2 simplicity); 3 candidates max enforced.

### RM3 — CHARTER-TIER GATE FIRES + user delay blocks S362 (LIKELY-MEDIUM if underthesea wins quality)
**Risk**: Empirical eval shows underthesea wins (GPL-3.0); STOP-AND-ASK fires; user-pick latency unknown (could be minutes OR hours); S362 dev waits.
**Mitigation**: Architect recommends pyvi as default if quality gap ≤10% per § C STEP 0.5 recommendation; this minimizes gate-firing rate. IF gate fires, dev pauses cleanly; main session dispatches AskUserQuestion + cooperates with user to resolve same-turn; ADR D-070 § Authorization records user pick. Worst case: gate stalls → S362 dev exits cleanly + re-dispatched after user pick recorded.

### RM4 — I-S34 HARD-REJECT transitive dep surfaces (LIKELY-VERY-LOW)
**Risk**: underthesea or pyvi pulls in patchright/StealthyFetcher transitively (extremely unlikely — these are NLP libs not crawlers, but worth checking).
**Mitigation**: STEP 0.6 grep enforces; STOP-AND-ASK trigger (d) fires if hit; pattern matches Phase D Theme L I-S34 audit discipline.

### RM5 — Non-determinism in SELECTED library (LIKELY-VERY-LOW)
**Risk**: SELECTED library has hidden random seed (e.g. neural backend with unseeded torch RNG); tokenizer output drifts across runs.
**Mitigation**: STEP 0.7 smoke catches; STOP-AND-ASK trigger (e); SELECTED lib must satisfy D-059 R2 by construction (else fallback to alternative or WhitespaceTokenizer).

### RM6 — mypy --strict surfaces Any leakage from SELECTED library (LIKELY-MEDIUM)
**Risk**: SELECTED library lacks type stubs; mypy emits `no-any-return` errors; dev forced into `# type: ignore` chain that may bloat to n>3.
**Mitigation**: DD-6 documents 2-step approach (cast + targeted type:ignore at n=1-2; vendor minimal stub at n≥3). Dev monitors type:ignore count; promotes to stub vendoring if threshold hit.

### RM7 — Library install failure on Windows (LIKELY-LOW; per CLAUDE.md env note)
**Risk**: Project runs on Windows 11 (per env header); underthesea/pyvi may have linux-only build deps (e.g. cython compile on install).
**Mitigation**: STEP 0.4 install-cost benchmark surfaces; if Windows install fails, document in scorecard + fallback to alternative; WhitespaceTokenizer fallback always works.

### RM8 — Test fixtures fail to exercise SELECTED library multi-syllable preservation (LIKELY-LOW)
**Risk**: Test 7 (`test_vn_tokenizer_preserves_multi_syllable_vn_words`) is the KEY test for library quality; if synthetic fixtures are weak, test may pass even when library is bad.
**Mitigation**: Test 7 uses architect-curated VN financial-term fixtures (cổ phiếu / thị trường / lợi nhuận) directly from STEP 0.3 reference list; assertion is `len(tokens) < 4` for input "cổ phiếu thị trường" (4 if whitespace splits; ≤3 if library preserves any compound word); fixture is intentional + auditable.

---

## K. Coordination paths off-limits (during S362 dev session window)

When main session dispatches S362 dev sub-plan IMPL, main session SHOULD avoid (read-only or no-touch) the following paths to prevent file-collision:

- `packages/application/nlp/**` (D1 dev writes)
- `packages/infrastructure/nlp/**` (D2 + D3 dev writes)
- `apps/cli/tokenize_vn_text.py` (D4 dev writes)
- `pyproject.toml` (D2 single-line dep add — coordination via dep-add file boundary)
- `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (D2 ADR writes)
- `agent-workspace/calibration/vn_tokenizer_eval_v0.md` (D4 STEP 0 scorecard writes)
- `agent-workspace/memory/sessions/2026-05-XX-session-362.md` (dev session log)
- `agent-workspace/memory/observations/sandwich-dev-S362-vn-tokenizer.md` (dev observation)
- `human-workspace/notifications/STOP-FINDING-S362-*.md` (CONDITIONAL dev writes IF STOP-AND-ASK fires)

When main session dispatches S363 verifier (AP-1 fresh-context post-S362 dev close), main session SHOULD avoid:
- `agent-workspace/memory/observations/sandwich-verifier-S363-vn-tokenizer-verify.md` (verifier writes)

---

## L. Conditional next-step (post-user-ratification of GPL-3.0 gate IF applicable)

### L.1 IF CHARTER-TIER GATE did NOT fire (SELECTED = pyvi MIT OR WhitespaceTokenizer)

- S362 dev proceeds STEP 0 → D1 → D2 → D3 + D4 (parallel) → close
- S363 verifier AP-1 dispatch
- S363 close: plan-029 mv `pending/` → `completed/`
- S363+ main session dispatches sub-plan 030 architect (E.2 sentiment lexicon) per parent master plan § E sequencing

### L.2 IF CHARTER-TIER GATE FIRED + user picked option (a) ACCEPT GPL-3.0

- S362 dev pauses at STEP 0.5 STOP-AND-ASK
- Main session dispatches AskUserQuestion gate → user pick (a) recorded
- ADR drafted at `proposal/` tier amending pyproject.toml license field + adding per-file GPL-3.0 header pattern (separate user-ratified PLAN+IMPL pair per CLAUDE.md hard rule)
- AFTER charter-amendment PLAN+IMPL pair lands → S362 dev re-dispatched OR resumes; proceeds D1-D4 with underthesea adoption
- Note: This is significant scope expansion (every file in StockForge gets new license header); may warrant separate Phase E.1-prime sub-plan for license-migration work

### L.3 IF CHARTER-TIER GATE FIRED + user picked option (b) PATTERN-ONLY port from underthesea

- S362 dev pauses; this option is HIGH-EFFORT (re-implement VN word segmentation algorithm from public literature WITHOUT reading GPL-3.0 source code)
- Recommended: defer E.1 IMPL pending separate research session to identify suitable pattern-port source (e.g. published academic papers on VN word segmentation; non-GPL reference implementations)
- Re-dispatch S362 dev with pattern-port plan after research session ships

### L.4 IF CHARTER-TIER GATE FIRED + user picked option (c) USE pyvi instead

- S362 dev resumes STEP 0 → D1-D4 with pyvi adoption (already-evaluated alternative; quality score recorded; ADR D-070 § Decision reflects pyvi pick)
- Most likely path per § C STEP 0.5 architect recommendation
- S363 verifier + plan move + sub-plan 030 dispatch per § L.1 timeline

---

## M. CHARTER-TIER GATE clause (canonical reference)

> **MANDATORY STEP 0 STOP-AND-ASK**: If underthesea (or any other candidate) outperforms alternatives in STEP 0.3 empirical eval AND its license = GPL-3.0 / AGPL / SSPL / any viral copyleft, S362 dev MUST:
> 1. STOP at STEP 0.5 conclusion (do NOT proceed to D1 IMPL)
> 2. Write `human-workspace/notifications/STOP-FINDING-S362-underthesea-gpl3-license-gate.md` (template at § C STEP 0.5 above)
> 3. Wait for user pick via main-session AskUserQuestion gate
> 4. Record user pick in ADR D-070 § Authorization
> 5. Proceed per § L.2 / L.3 / L.4 depending on user pick
>
> DO NOT pre-decide license posture. DO NOT silently adopt GPL-3.0 dep without user ratification per CLAUDE.md hard rule "Never modify PROJECT_CHARTER.md without explicit human revision with version bump" — pyproject.toml license field IS a charter-tier identity surface.

---

## N. Compliance attestation (architect S361 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; L-S354-2 planner-stats infrastructure gap noted in Phase 1b § A.4 carry-forward; explicitly NOT fixed here per § hard_rules)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- [x] AP-5 ✓ (re-read all binding sources at session entry per VBW protocol — 26 files cited in § A.4)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals)
- [x] AP-23 ✓ (no refinement-of-rule iterations this session; any new patterns surfaced get first-instance HOLD per binding_decisions)
- [x] autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- [x] dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session dispatches S362 dev per parent plan-028 § L sequencing — no self-pause)
- [x] stop_offering_routing_branches ✓ (§ L next-step is structural sequencing not user-action menu)
- [x] D-060 ✓ (architect has no Bash tool; main session commits this sub-plan + observation per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- [x] D-066 not touched (Phase D Theme L closed; Theme I CONSUMES adapter output without modification)
- [x] 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- [x] 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- [x] 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is dev-S362 conditional write not architect-S361 write)
- [x] 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- [x] I-S1 ✓ (this plan PROMOTES I-S1 satisfaction — tokenizer is LLM-free by construction)
- [x] I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- [x] I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward)
- [x] I-S35 ✓ (tokenizer = transform utility; no recommendation surface)
- [x] Phase 1b CONSUMED + COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate)
- [x] 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- [x] CHARTER-TIER GATE clause documented per § M (canonical reference for S362 dev)
- [x] D1-D4 sub-tracks declare 3 mandatory fields (parallel_with / blocks_on / coordination_paths_exclusive / estimated_wall_min) per plan-025 contract

---

**END OF SUB-PLAN 029-S361-PHASE-E1-VN-TOKENIZATION**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S362 sandwich-dev FOCUSED_IMPL per parent plan-028 § L sequencing post-ratification of THIS sub-plan.
