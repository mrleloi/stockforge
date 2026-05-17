---
plan_id: 031-S367-phase-e3-claim-extraction-wrapper
target_session: S368 (dev IMPL session; THIS plan = S367 architect output)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S367; IMPL by sandwich-dev at S368; VERIFY by sandwich-verifier AP-1 at S369)
budget:
  - this PLAN session (S367 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (M-S360-2 empirical ratification carry-forward; sub-plan 030 S364 architect run validated upper-band Opus PLAN envelope at 3rd opportunity)
  - sub-plan IMPL (S368 dev): ~100-150K Opus FOCUSED_IMPL per recalibrated table (sandwich-dev back on Opus per dispatch brief; n=2 vietnamese-nlp-impl precedent from S362 + S365 — both ~150-160K Sonnet within envelope; Opus may run faster but token cost similar)
  - sub-plan VERIFY (S369 verifier): ~30-60K Opus AP-1 fresh-context
phase: E (Theme I — Vietnamese NLP entry; sub-theme E.3 Claim Extraction Wrapper — THIRD of 4 sub-themes per plan-028 § E sequencing)
track: Wave 1 Theme I sub-theme E.3 — Claim extraction wrapper AUGMENT of existing ClaudeLlmExtractor (NOT parallel-class) per parent plan-028 DD-5 EXISTING-EXTRACTOR-AUGMENT strategy; bundles anthropic_api_to_subagent compliance (D-050 + memory rule) by flipping default transport from `_default_transport` to `make_claude_cli_news_transport()` factory; per master plan § 5.4 + § 6.4.2 + plan-028 DD-5 + AQ-6
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN authored S360; THIS is the third sub-plan per § E.3 + § L sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.4 + § 6.4.2
predecessor: 030-S364-phase-e2-vn-sentiment-lexicon (sub-plan 030; SHIPPED S365 dev + VERIFIED PENDING S366; ADR D-071 PROPOSED with UNCALIBRATED-V0 hypothesis weights; VN_CULTURAL_ANCHORS frozenset[str] of 8+ entries + SentimentScore dataclass + VnSentimentLexicon adapter all instantiable; calibration cycle deferred pending user pick on STEP 0.5 STOP-FINDING-S365-corpus-labelling-source.md per AQ-8 NON-BLOCKING for E.3)
successor: S368 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S369 sandwich-verifier AP-1 → sub-plan 032 E.4 ticker resolver at S369+ OR parallel with this per master plan § E sequencing 031+032 parallel_with declaration; 032 has NO blocks_on dependency on 031
architect: S367 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase E third sub-plan author per plan-028 § L sequencing + S365 dev close + recalibrated PLAN budget table validation (3rd opportunity per dispatch brief)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED with n=2 vietnamese-nlp-impl precedent from S362 + S365 — task_class window now n=2 narrow-but-growing per L-S354-2 .planner-stats.tsv carry-forward; sub-plan 031 IMPL projected to fit similar 100-150K envelope; Opus model swap from Sonnet may reduce wall but token cost similar)
executing_agent: N/A this PLAN session; S368 sandwich-dev FOCUSED_IMPL (after this sub-plan ratified) + S369 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT include sync-grilling in S368 close ritual)"

depends_on:
  - "Parent master plan-028 § E.3 sub-plan contract (DD-5 EXISTING-EXTRACTOR-AUGMENT strategy + AQ-6 anthropic_api_to_subagent IN-SCOPE answer + § K.2 sub-plan 031 anticipated FLAGS + RM-MR-1 carry-forward; coordination_paths_exclusive scoped to packages/infrastructure/news/claude_llm_extractor.py + packages/domain/news/models/extracted_claim.py + packages/infrastructure/news/test_adapters.py + new prompt_engineering.md update + ADR D-072)"
  - "Sub-plan 029 SHIPPED + VERIFIED — pyvi==0.1.1 VnTokenizer at packages.infrastructure.nlp.vn_tokenizer.VnTokenizer (instantiable) + WhitespaceTokenizer fallback + TextTokenizerPort Protocol — THIS sub-plan CONSUMES VnTokenizer as injected dependency per DI port pattern"
  - "Sub-plan 030 SHIPPED + (S366 VERIFY pending non-blocking per dispatch brief) — VnSentimentLexicon at apps.extraction.sentiment.vn_lexicon.VnSentimentLexicon (instantiable; UNCALIBRATED-V0) + VN_CULTURAL_ANCHORS frozenset[str] (8 mandatory anchors) + SentimentScore frozen dataclass + VnLexiconPort Protocol — THIS sub-plan CONSUMES VnSentimentLexicon as injected dependency + VN_CULTURAL_ANCHORS as deterministic-anchor source"
  - "ADR D-070 PROPOSED (pyvi tokenizer selection) + ADR D-071 PROPOSED (VN sentiment lexicon UNCALIBRATED-V0) — both available as DI substrate; STOP-FINDING-S365-corpus-labelling-source.md (sub-plan 030 STEP 0.5 STOP-AND-ASK) is NON-BLOCKING for E.3 per parent AQ-8 + dispatch brief constraint"
  - "ADR D-050 ACCEPTED (anthropic→subagent SYSTEMIC; 2026-05-09) + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09: 'no need anthropic api key, use claude code subagent (claude subscription) instead, for every anthropic api key') — THIS sub-plan BUNDLES news-extractor refactor (was deferred to D-051 follow-up per D-050 § Deferred); ships under D-050 systemic mandate without new ADR for the rule itself (new ADR D-072 records IMPLEMENTATION choice + transport-flip rationale only)"
  - "Existing infrastructure `packages/infrastructure/news/claude_cli_news_transport.py` (SHIPPED; 173 LOC; per D-050 § Deferred D-051) — provides `claude_cli_news_transport(system_prompt: str, body: str, *, model, timeout_sec) -> str` + `make_claude_cli_news_transport(*, model, timeout_sec) -> Callable[[str, str], str]` factory; drop-in replacement for `_default_transport` at claude_llm_extractor.py:80-99; THIS sub-plan FLIPS default + REMOVES `_default_transport` per D-050 + L-S227-1 + plan-008 G.1 deferral closure"
  - "D-066 + REV-1/2/3 (CrawlerAdapter ABC contract; 4 VN adapters SHIPPED) — THIS sub-plan CONSUMES NewsArticle output as input substrate via existing 4 CLIs; existing CLI wiring unchanged (default-flip is transport-level; CLI sees `ClaudeLlmExtractor()` with new default = subagent path)"
  - "D-061 § Decision item 4 (HARD REJECT Scrapling/patchright/playwright_stealth/fake-useragent/StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher; claude CLI subprocess is its own substrate per D-050; verifier grep-asserts post-IMPL)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain) — BINDING for every NEW/MODIFIED file; ExtractedClaim new fields lexicon_score + mentioned_pump_anchors are deterministic-by-construction (lexicon emits float deterministically; frozenset intersection is deterministic); D-059 R1 satisfied at existing ExtractorMetadata.extracted_at via clock injection (already shipped)"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S368 dev commit boundary"
  - "D-062 (atomic-write-doctrine via tmp+os.replace) — N/A for extractor (no file-path writes in extractor path; persistence happens via ClaimRepository = existing SqliteClaimRepository unchanged this sub-plan)"
  - "D-064 (path-safety 5-invariant) — N/A this sub-plan (no new file-path code)"
  - "D-065 Rule 16 (numeric-field discipline) — THIS sub-plan adds lexicon_score: float to ExtractedClaim; Rule 16 satisfaction MODE 2 (deterministic-pipeline echo from VnSentimentLexicon.score().numeric_score) — CRITICAL CHARTER-TIER COMPLIANCE — see § D DD-4 (Rule 16 mode-2 by construction) + § STEP 0.4 audit; LLM still emits categorical sentiment label (existing Rule 7 path; unchanged); LLM does NOT emit lexicon_score"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VN tokenization + sentiment + cultural anchors integrated into extraction surface IS the moat realization) + Principle 7 (Dogfood — S368 dev MUST run extractor on ≥3 real CafeF/NDH/Vietstock/VietnamBiz samples in STEP 0 + D5 CLI smoke; cannot ship without dogfood) + Principle 8 (Calibration over confidence — lexicon_score traceable to VnSentimentLexicon UNCALIBRATED-V0 with revisit trigger per ADR D-071; mentioned_pump_anchors traceable to VN_CULTURAL_ANCHORS frozenset; no LLM-self-reported confidence on these fields) + Principle 9 (NO LLM math — lexicon_score is rule-based deterministic per Rule 16 mode 2; mentioned_pump_anchors is deterministic frozenset intersection; LLM never emits either) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — lexicon_score path is LLM-FREE by construction (lexicon scoring is pure-function); mentioned_pump_anchors is deterministic regex/frozenset path (no LLM); LLM still emits claim_text + categorical sentiment per existing Rule 7 contract (unchanged); satisfied by construction — see § D DD-4 + STEP 0.4 audit"
  - "I-S2 (citation discipline) — every claim still carries source_text_excerpt (≤500 chars verbatim quote) per existing Rule 6 invariant on ExtractedClaim; new fields don't add citation surface; existing citation discipline unchanged"
  - "I-S20 (calibration over confidence) — lexicon_score traces to VnSentimentLexicon UNCALIBRATED-V0 (HYPOTHESIS weights per ADR D-071); calibration cycle deferred per AQ-8 NON-BLOCKING; revisit trigger via ADR D-071 trigger 2 (macro-F1 <70% on held-out subset); existing confidence_extracted unchanged"
  - "I-S22 (data lineage) — ExtractedClaim provenance unchanged for existing fields; new lexicon_score field carries provenance via VnSentimentLexicon.lexicon_version (UNCALIBRATED-V0 v0.HYPOTHESIS); new mentioned_pump_anchors field provenance traces to VN_CULTURAL_ANCHORS frozenset version (implicit via sub-plan 030 ADR D-071)"
  - "I-S34 (robots.txt + reasonable rate limits + HARD REJECT) — N/A this sub-plan (no new HTTP fetcher; claude CLI is local subprocess); CARRIES FORWARD verifier grep-asserts post-IMPL"
  - "I-S35 (research-aid framing) — lexicon_score is a SIGNAL not a RECOMMENDATION; mentioned_pump_anchors is an AUDIT-TRAIL flag not a RECOMMENDATION; categorical sentiment unchanged per existing Rule 7; satisfied by construction"
  - "anthropic_api_to_subagent memory rule (user verbatim 2026-05-09; D-050 ACCEPTED CHARTER tier) — THIS sub-plan IMPLEMENTS the rule for the news-extractor path (D-050 § Deferred D-051 closure); ZERO new `import anthropic` introduced; default transport flipped from `_default_transport` (anthropic SDK lazy import at line 84) to `make_claude_cli_news_transport()` factory (subprocess claude CLI bills against subscription); `_default_transport` function REMOVED per L-S227-1 + plan-008 G.1 + D-052 follow-up partial closure (anthropic dep removal from pyproject.toml left to D-052 separate cleanup ADR; THIS sub-plan removes only the local SDK-import code-path, not the package dep — narrows scope risk)"
  - "skill .claude/skills/prompt-engineering/SKILL.md (No-LLM-Math pattern + Validation Pre-Conditions + Anti-Patterns 'Ask LLM for ratios, percentages' — confirms Rule 16 mode 2 IS the correct pattern when numeric output is required per I-S1; lexicon_score satisfies pattern via deterministic-echo)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter discipline — VnSentimentLexicon + VnTokenizer injected via DI; mirror sub-plan 029 + 030 D1+D2 pattern)"

binding_decisions:
  - "PHASE 1b CONSUMED with n=2 vietnamese-nlp-impl precedent — task_class='vietnamese-nlp-impl' has n=2 samples from S362 (~159K Sonnet, ~39min, 1053/1053 tests, 0 mistakes) + S365 (~150K Sonnet, ~39min, 1079/1079 tests, 0 mistakes; both per current-execution.md rows); variance window narrow at n=2 but growing; sub-plan 031 IMPL projected to fit similar 100-150K envelope under Opus per dispatch brief recalibration; corpus-labelling cycle NOT in scope this sub-plan (different from sub-plan 030); claim-extraction-wrapper is structurally closer to S362 library-adopt shape than to S365 corpus-cycle shape — directional confidence MEDIUM at n=2"
  - "DD-1 EXISTING-EXTRACTOR-AUGMENT STRATEGY per parent plan-028 DD-5 — AUGMENT (NOT REPLACE) `packages/infrastructure/news/claude_llm_extractor.py` ClaudeLlmExtractor dataclass with (a) `tokenizer: TextTokenizerPort` field (default = WhitespaceTokenizer fallback per DI graceful degradation), (b) `lexicon: VnLexiconPort` field (default = None sentinel; lexicon scoring skipped if None), (c) new ExtractedClaim fields lexicon_score + mentioned_pump_anchors emitted by extractor adapter post-LLM call (NOT computed by LLM); ALL existing fields + invariants UNCHANGED (backward-compat ABI per L-S345-3 single-helper-with-keyword-only-flag precedent); existing tests at test_adapters.py:257-348 continue to PASS without modification (default params preserve existing behavior modulo transport flip)"
  - "DD-2 TRANSPORT DEFAULT FLIPPED per D-050 SYSTEMIC + memory rule + plan-008 G.1 deferral closure — `_default_transport` REMOVED from claude_llm_extractor.py; `transport: Callable[[str, str], str] = field(default_factory=make_claude_cli_news_transport)` replaces `transport: Callable[[str, str], str] = _default_transport`; tests inject stub transport via constructor kwarg (existing pattern at test_adapters.py:278); `import anthropic` line at claude_llm_extractor.py:84 REMOVED; ZERO new `import anthropic` in this sub-plan's file scope; verifier grep-asserts at S369"
  - "DD-3 ExtractedClaim NEW FIELDS = lexicon_score: float + mentioned_pump_anchors: tuple[str, ...] — both deterministic-by-construction per Rule 16 mode 2; default values = 0.0 + () empty tuple preserve backward-compat (existing tests construct ExtractedClaim without these fields = ok per dataclass field default); __post_init__ validates lexicon_score in [-1.0, 1.0] (mirrors SentimentScore.__post_init__ bounds check); mentioned_pump_anchors validated as tuple[str, ...] (mypy-strict catches)"
  - "DD-4 RULE 16 MODE 2 SATISFACTION FOR NEW FIELDS = DETERMINISTIC-PIPELINE ECHO per Rule 16 § Enforcement schema-time guidance — lexicon_score = VnSentimentLexicon.score(article.body_excerpt).numeric_score (deterministic dict-lookup + float arithmetic; NO LLM); mentioned_pump_anchors = tuple(sorted(VN_CULTURAL_ANCHORS & set(VnSentimentLexicon.score(article.body_excerpt).keyword_hits))) (deterministic frozenset intersection over keyword_hits audit trail; sorted for determinism); LLM is NOT in the path for these two numeric/structural fields; LLM remains in the path for claim_text + categorical sentiment (existing Rule 7 contract; UNCHANGED)"
  - "DD-5 TOKENIZER DI INTEGRATION = pre-LLM PREPROCESSING HINT (NOT input transform) per parent plan-028 DD-5 step 2 — tokenizer is OPTIONAL injection; if injected non-default (i.e. production VnTokenizer not WhitespaceTokenizer), extractor appends a hint line to the system prompt: 'VN-tokenized terms (preserve multi-syllable on quote): cổ_phiếu, thị_trường, ...' (LLM still reads original Vietnamese body_excerpt; tokens are HINT for excerpt verbatim-quote discipline; this is NOT data transformation = LLM sees real text); tokenizer hint is OPT-IN via constructor; default WhitespaceTokenizer = NO hint line added (avoids low-quality 0% hit-rate fallback contamination per plan-029 DD-2 quality data)"
  - "DD-6 ADR D-072 PROPOSED-AT-IMPL — 'VN Claim Extraction Wrapper AUGMENT + anthropic→subagent default-flip + ExtractedClaim 2 NEW fields' — records (a) augment vs parallel-class decision rationale (parent DD-5 precedent), (b) transport-flip rationale (D-050 closure of D-051), (c) new field semantics (Rule 16 mode 2 by construction), (d) DI graceful-degradation rationale (default WhitespaceTokenizer + lexicon=None); D-052 anthropic-dep removal explicitly NOT this sub-plan's scope (left to separate cleanup ADR per D-050 § Deferred); ADR D-072 explicitly cites D-050 + D-051 + D-052 chain"
  - "DD-7 EXISTING `claude_cli_news_transport.py` UNCHANGED — sub-plan 031 ADOPTS its factory + helper functions verbatim; ZERO modification to transport file (already-shipped infrastructure; verifier reads it READ-ONLY at S369); test_adapters.py existing extractor tests CONTINUE TO PASS unchanged (stub transport via constructor kwarg pattern at test_adapters.py:278-281)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (e.g. NEW prompt-hint-line pattern at DD-5); 2nd recurrence triggers promote-to-skill calculus"
  - "Karpathy P3 surgical-changes — this sub-plan modifies ≤300 LOC across 3 files (claude_llm_extractor.py +~80 LOC: 2 new fields + lexicon-scoring code + tokenizer-hint code + 1 import removal; extracted_claim.py +~30 LOC: 2 new fields + __post_init__ validation; test_adapters.py +~150 LOC: 6 new test cases) + adds 2 NEW files (ADR D-072 ~80 LOC; integration smoke CLI ~120 LOC); total delta ~480 LOC across 5 files; well within Karpathy P3 surgical envelope"
  - "VBW protocol mandatory — S368 dev MUST READ claude_cli_news_transport.py + vn_lexicon.py + vn_tokenizer.py + extracted_claim.py source files empirically at S368 entry; cite file:line for every dependency claim per I-S2"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN+IMPL; THIS is sub-plan author session; production code lands in S368 dev IMPL)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S368-* is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire; that write happens in S368 dev session NOT this S367 PLAN session)"
  - "no touching Phase D Theme L files — all 4 VN adapters + 6 primitives shipped + verified; this sub-plan CONSUMES NewsArticle output for extraction via existing 4 CLIs, does NOT modify adapters"
  - "no touching Phase E sub-plan 029 files — pyvi VnTokenizer + WhitespaceTokenizer + TextTokenizerPort SHIPPED at S362; this sub-plan IMPORTS them as DI dependencies, does NOT modify"
  - "no touching Phase E sub-plan 030 files — VnSentimentLexicon + VN_CULTURAL_ANCHORS + SentimentScore + VnLexiconPort SHIPPED at S365; this sub-plan IMPORTS them as DI dependencies, does NOT modify; STOP-FINDING-S365-corpus-labelling-source.md (sub-plan 030) is NON-BLOCKING for E.3 per AQ-8 — UNCALIBRATED-V0 lexicon is usable for hint emission"
  - "no Phase E sub-theme E.4 work in THIS sub-plan — separate sub-plan 032 (own PLAN+IMPL+VERIFY chain per master plan § E); E.4 may run parallel with this per § E.3+E.4 parallel_with declaration; ticker resolution refactor at claude_llm_extractor.py:177-180 is E.4 scope NOT E.3 scope per parent plan DD-6"
  - "no charter amendment SHIP from THIS plan — IF anthropic SDK retention surfaces as user-veto (e.g. claude CLI substrate unavailable in production runtime per D-050 § Edge cases), THIS plan FLAGS via human-workspace/notifications/STOP-FINDING-S368-anthropic-sdk-retention.md (CHARTER-TIER GATE per § M); main session dispatches AskUserQuestion + ADR drafted separately (would supersede D-050 partially) per CLAUDE.md hard rule"
  - "no D-052 anthropic-dep removal — THIS sub-plan REMOVES `import anthropic` from claude_llm_extractor.py:84 BUT DOES NOT drop `anthropic` from pyproject.toml dependencies (separate D-052 cleanup ADR scope per D-050 § Deferred); narrows scope risk"
  - "no harness/hook changes — this plan ships product substrate (claim extractor augment); surface any harness gaps in observation; do NOT fix here. L-S354-2 (.planner-stats.tsv auto-population gap) belongs to next harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.6 grep-asserts no new HTTP fetcher OR HARD-REJECT artifact in dependencies (no new deps expected this sub-plan; claude CLI substrate is local subprocess)"
  - "If STEP 0 surfaces a charter-tier need (anthropic SDK retention veto OR Rule 16 mode-2 tripwire on new field path OR I-S<N> for LLM-categorical-sentiment-vs-lexicon-score-divergence handling), FLAG in § CHARTER-TIER GATE for main session AskUserQuestion ratification gate dispatch"
---

# S367 — Phase E.3 VN Claim Extraction Wrapper sub-plan (EXISTING-EXTRACTOR-AUGMENT — third sub-plan of Phase E)

> **One-sentence intent**: AUGMENT existing `packages/infrastructure/news/claude_llm_extractor.py` ClaudeLlmExtractor with (a) injected `tokenizer: TextTokenizerPort` (consumed from sub-plan 029) for pre-LLM tokenization-hint emission, (b) injected `lexicon: VnLexiconPort` (consumed from sub-plan 030) for post-LLM deterministic sentiment-scoring + cultural-anchor extraction, (c) two NEW ExtractedClaim fields `lexicon_score: float` + `mentioned_pump_anchors: tuple[str, ...]` (both Rule 16 mode 2 deterministic-pipeline echo; LLM never emits them), (d) DEFAULT TRANSPORT FLIPPED from `_default_transport` (anthropic SDK lazy import) to `make_claude_cli_news_transport()` factory (per D-050 SYSTEMIC + user memory rule `anthropic_api_to_subagent` + plan-008 G.1 deferral closure), (e) `_default_transport` function + `import anthropic` line REMOVED — without LLM in the new-field computation path (I-S1 + Rule 16 mode 2 by construction), without parallel-class duplication (DDD AUGMENT pattern), and without dropping `anthropic` from pyproject.toml deps (D-052 cleanup ADR separate scope per D-050 § Deferred).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent plan-028 § E.3 + DD-5 + AQ-6)

Build the **Vietnamese claim-extraction wrapper layer** for StockForge that:

- **Augments existing `ClaudeLlmExtractor`** (`packages/infrastructure/news/claude_llm_extractor.py`) per parent DD-5 EXISTING-EXTRACTOR-AUGMENT strategy — preserves backward-compat per L-S345-3 single-helper-with-keyword-only-flag precedent; existing 4 CLI ingest_news_* (cafef/ndh/vietstock/vietnambiz) continue to work with `ClaudeLlmExtractor()` no-arg construction
- **Injects sub-plan 029 VnTokenizer** via DI (default = WhitespaceTokenizer fallback per graceful degradation); used as pre-LLM tokenization HINT in system-prompt enrichment (NOT data transform — LLM still reads original Vietnamese body_excerpt)
- **Injects sub-plan 030 VnSentimentLexicon** via DI (default = None sentinel; lexicon-scoring SKIPPED if None); used post-LLM to compute deterministic `lexicon_score: float` per Rule 16 mode 2 and `mentioned_pump_anchors: tuple[str, ...]` per deterministic frozenset intersection over VN_CULTURAL_ANCHORS
- **Adds two NEW ExtractedClaim fields**: `lexicon_score: float` (default 0.0; range [-1.0, 1.0]; computed via VnSentimentLexicon.score().numeric_score) + `mentioned_pump_anchors: tuple[str, ...]` (default empty; computed via frozenset intersection of VN_CULTURAL_ANCHORS with keyword_hits)
- **FLIPS DEFAULT TRANSPORT** from `_default_transport` (anthropic SDK) to `make_claude_cli_news_transport()` factory per D-050 + memory rule + plan-008 G.1 deferral; **REMOVES** `_default_transport` function + `import anthropic` line; tests inject stub via constructor kwarg (existing pattern unchanged)
- **Satisfies Rule 16 mode 2 (deterministic-pipeline echo) by construction** for NEW numeric fields — LLM never emits lexicon_score or mentioned_pump_anchors; these are deterministic post-LLM computations from sub-plan 030 lexicon
- **Satisfies I-S1 (NO LLM math) by construction** for NEW fields — lexicon scoring is pure-function; frozenset intersection is pure-function; LLM is NOT in either path

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — ExtractedClaim NEW fields at `packages/domain/news/models/extracted_claim.py` (~+30 LOC: lexicon_score + mentioned_pump_anchors + __post_init__ validation; foundation; blocks D2/D3)
2. **Sub-track D2** — ClaudeLlmExtractor AUGMENT at `packages/infrastructure/news/claude_llm_extractor.py` (~+80 LOC: tokenizer DI + lexicon DI + transport flip + _default_transport removal + import anthropic removal + system-prompt hint line + post-LLM lexicon-scoring code; blocks D3/D4/D5)
3. **Sub-track D3** — Unit test extensions at `packages/infrastructure/news/test_adapters.py` (~+150 LOC: 6 new test cases covering new fields + DI patterns + transport-flip + backward-compat; parallel with D4)
4. **Sub-track D4** — ADR D-072 PROPOSED at `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (~80 LOC; records augment + transport-flip rationale + new field semantics + DI graceful-degradation; parallel with D3)
5. **Sub-track D5** — Integration smoke + CLI extract-and-score harness at `apps/cli/extract_vn_claims.py` (~120 LOC; reads NewsArticle from SQLite OR HTML files; runs FULL pipeline with VnTokenizer + VnSentimentLexicon DI; dumps per-claim JSON including lexicon_score + mentioned_pump_anchors; sequential after D2)
6. **STEP 0 evaluation observation** appended to `agent-workspace/memory/observations/sandwich-dev-S368-vn-claim-extraction-wrapper.md` (records VBW reads + DI-injection-point audit + transport-flip pre-check + corpus dogfood result)
7. **Session log + observation file** per CLAUDE.md § Session Protocol End
8. **Mistake-log digest entry** (M-S368-N if mistakes; OR explicit "no mistakes" statement)
9. **ZERO charter / constitution writes** (CHARTER-TIER GATE FLAG file at `human-workspace/notifications/STOP-FINDING-S368-*` is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire — anthropic SDK retention veto OR Rule 16 mode-2 tripwire)
10. **ZERO new LLM-numeric schema fields beyond lexicon_score + mentioned_pump_anchors** (Rule 16 mode 2 by construction; both computed deterministically; LLM doesn't emit either)
11. **ZERO new hooks** (mirror plan-020/022/026/027/029/030 — product substrate not harness rule-enforcement)
12. **ZERO new external dependencies** (uses already-shipped pyvi + claude CLI substrate + stdlib; pyproject.toml unchanged)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Sub-theme E.4 ticker resolver (fuzzy-match + alias table; refactor of claude_llm_extractor.py:177-180 2-4 char uppercase filter) | Separate sub-plan 032; can run parallel with this per master plan § E.3+E.4 parallel_with declaration | Sub-plan 032 dispatch after S366/S367 (parallel with this) per master plan § E |
| Drop `anthropic` from pyproject.toml dependencies (D-052 cleanup) | Separate cleanup ADR per D-050 § Deferred; narrows scope risk of this sub-plan; transport flip + import removal is the SYSTEMIC rule satisfaction; dep removal is hygiene | D-052 trigger: ZERO `import anthropic` across packages/ + apps/ confirmed by S369 verifier (this sub-plan ENSURES this for news-extractor path; analysis-extractor at packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80 already refactored per D-050 S227 close — verifier confirms holistic ZERO state) |
| LLM-generated mentioned_pump_anchors (LLM volunteers pump-anchor inference) | Per parent plan-028 § K.2 sub-plan 031 anticipated FLAG (b) — would violate I-S1; mentioned_pump_anchors is deterministic frozenset intersection ONLY per DD-4 | FLAG-mandatory if LLM output drift surfaces volunteer pump-anchor inference; sub-plan 031 STEP 0 STOP-AND-ASK template at § C STEP 0.4 |
| LLM-generated lexicon_score (LLM emits numeric_score directly) | Per Rule 16 mode 2 + parent plan-028 § K.2 sub-plan 031 anticipated FLAG (b) — would violate I-S1; lexicon_score is deterministic VnSentimentLexicon path ONLY per DD-4 | FLAG-mandatory if LLM output drift surfaces numeric sentiment emission; sub-plan 031 STEP 0 STOP-AND-ASK template at § C STEP 0.4 |
| EchoValidator runtime enforcement for lexicon_score (Rule 16 § Enforcement runtime tier) | Lexicon_score path is BEFORE LLM JSON parse (post-LLM-call deterministic computation); LLM doesn't see lexicon_score in input or output; EchoValidator only matters if LLM might emit a numeric_score that should match a deterministic source — not the case here per DD-4 | EchoValidator trigger: if downstream consumer (BC-7 Crowd) re-derives lexicon_score from claim_text via separate LLM call OR if Phase 2 dashboard surfaces lexicon_score drift |
| Lexicon-score caching per article body hash | Premature for v0 per Karpathy P2 simplicity; lexicon scoring is pure-function O(n_tokens) and fast (<1ms per article body); E.3 extraction-call latency dominated by LLM (~1-5 sec per article) not lexicon (<0.1% of total) | Cache trigger: production-throughput Phase 3 gate when lexicon repeated on same body becomes >5% of session time (highly unlikely for v0) |
| Tokenizer-output caching per article body | Similar to above; tokenization is sub-ms; not a v0 hot-path | Cache trigger: Phase 3 production-throughput gate |
| ExtractedClaim persistence schema migration (SQLite alter table for new fields) | Existing SqliteClaimRepository at packages/infrastructure/news/sqlite_news_repository.py handles serialization via existing pickle/json path; dataclass field defaults preserve backward-compat at deserialization (NULL old-row → default value); explicit schema migration unnecessary for v0 | Migration trigger: SQLite schema explicit validation (e.g. pyproject add of alembic) OR n≥10000 old rows requiring backfill |
| Multi-perspective claim extraction (per Charter principle 5 Adversarial-by-default) | Separate Phase F-prime Theme H (BC-8) sub-plan; THIS sub-plan handles single-perspective claim extraction (matches existing ClaudeLlmExtractor contract) | Phase F-prime master-plan dispatch (per master plan § 6.4.3); parallel with Phase E per dispatch-brief precedent |
| LLM model upgrade (Sonnet → Opus for higher-quality claim extraction) | Out-of-scope per Karpathy P2 simplicity; current `_DEFAULT_MODEL = "claude-sonnet-4-6"` honored; model upgrade is separate decision with own cost/quality trade-off analysis | Upgrade trigger: empirical eval surfaces ≥30% accuracy gap between Sonnet and Opus on VN claim extraction sample; user-ratified cost model adjustment |
| Prompt caching for system prompt (Anthropic prompt cache 10× cost reduction) | Existing extractor at claude_llm_extractor.py:1-11 mentions prompt-caching skill but does NOT implement at adapter; claude CLI substrate (claude_cli_news_transport.py) may or may not expose prompt caching — independent verification needed; defer to separate harness sub-plan | Caching trigger: production-throughput Phase 3 gate when token cost reduction >$0.05/article justifies engineering work |
| Streaming response handling for low-latency claim extraction | Existing extractor uses messages.create() blocking call; streaming requires API surface change at claude_cli_news_transport.py; not v0 scope | Streaming trigger: Phase 3 production-throughput gate when user-perceived latency >5s/article justifies engineering |
| Negation handling at lexicon-score level (e.g. "không phải tăng" = NOT a tăng signal) | Per sub-plan 030 RM10 deferral; v0 lexicon doesn't handle negation; sub-plan 031 INHERITS this gap (negation handling is sub-plan 030-V2 calibration cycle work, NOT extraction-wrapper work) | Negation trigger: v0.CALIBRATED iteration if calibration cycle reveals systematic negation misclassification per sub-plan 030 RM10 |
| New harness hook for ExtractedClaim-field-determinism check | Belongs to harness-stabilization sweep IF an extractor-determinism defect surfaces; product session SHIPS the augment not the hook | Harness trigger: 2+ silent extractor-output-drift incidents (AP-23 promote-to-hook) |
| Charter amendment SHIP for anthropic SDK retention reversal (if STEP 0.5 STOP-AND-ASK fires) | THIS plan FLAGS via STOP-FINDING file; main session ratifies via AskUserQuestion gate; ADR drafted separately per CLAUDE.md hard rule | Trigger: § CHARTER-TIER GATE STEP 0.5 STOP-AND-ASK fires on anthropic SDK retention veto (would supersede D-050 partially) |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; n=2 vietnamese-nlp-impl PRECEDENT from S362 + S365; cold-start window NARROW but EXISTING)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 + L-S366-4 carry-forward — planner-feedback-loop.sh STILL has not auto-populated after S354/S357/S360/S361/S362/S363/S364/S365 dogfood cycles; auto-population infrastructure gap; manual reading via current-execution.md + mistake-log + observations substitute)
2. `agent-workspace/memory/current-execution.md` (offset 1-200 read; S365 sandwich-dev RETURN row at L147-168 confirms vietnamese-nlp-impl n=2 precedent: S365 ~150K Sonnet over ~39 min, 1079/1079 tests, 0 mistakes per CHARTER-TIER GATE NON-BLOCKING path + S362 row at L172-188 confirms n=1 precedent: ~159K Sonnet over ~39 min, 1053/1053 tests, 0 mistakes)
3. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 INLINE-RESOLVED UTC+7 fix / M-S354-NONE / M-S342-1 medium / M-S341-1 low / **no vietnamese-nlp-impl-specific failure pattern history at S362+S365 — both clean**; M-S360-2 carry-forward documents Opus PLAN budget recalibration empirical ratification)
4. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; offset 1-400 + 400-720 read; §s A/B/C/D/E/F/G/H/J/K/L/M/N/P covering all sub-plan contracts; CONFIRMED sub-plan 031 § E.3 row + DD-5 EXISTING-EXTRACTOR-AUGMENT + § K.2 anticipated FLAGS for sub-plan 031 (a) JSON-contract issue + (b) LLM-numeric drift + (c) interpretation creep + AQ-6 anthropic_api_to_subagent IN-SCOPE answer + RM-MR-1 carry-forward)
5. `agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md` (precedent sub-plan; offset 1-300 + 1000-1100 read for D1-D4 structure + § L conditional next-step template; format reference for sub-plan 031 structure mirror)
6. `agent-workspace/session-plans/completed/030-S364-phase-e2-vn-sentiment-lexicon.md` (precedent sub-plan; offset 1-300 + 700-1300 + 1300-1550 read in 3 chunks per file size limit; D1-D5 structure + DoD template + AQ-1..AQ-10 + § H 5-source-evidence + § J RM + § K coordination + § L conditional + § M CHARTER-TIER GATE + § N attestation — full template for sub-plan 031 structure mirror)
7. `agent-workspace/memory/observations/sandwich-architect-S361-phase-e1-tokenization-plan.md` (precedent observation; offset 1-80 read; format reference for S367 observation file)
8. `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (ADR D-070; partial grep `pyvi==0.1.1` + MIT license + revisit triggers; pyvi VnTokenizer instantiable confirmed via current-execution.md S362 row)
9. `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (ADR D-071; via grep; UNCALIBRATED-V0 + revisit triggers; VnSentimentLexicon instantiable confirmed via current-execution.md S365 row)
10. `agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md` (full read 172 LOC; ADR D-050 ACCEPTED CHARTER 2026-05-09; § Implementation 4-file surgical edit shipped; § Deferred D-051 news-extractor refactor + D-052 SDK removal; § Follow-ups carry over to THIS sub-plan per AQ-6 + RM-MR-1 closure)
11. `~/.ccs/instances/nathanleewindy/projects/C--htdocs-stockforge/memory/anthropic_api_to_subagent.md` (full read 24 LOC; user memory rule verbatim 2026-05-09 "no need anthropic api key, use claude code subagent (claude subscription) instead, for every 'anthropic api key'"; SYSTEMIC rule)
12. `packages/infrastructure/news/claude_llm_extractor.py` (full read 226 LOC; ClaudeLlmExtractor dataclass + _default_transport at L80-99 + `import anthropic` at L84 + `transport` field at L112 + `_build_claim` at L159-218; modification target for D2 AUGMENT)
13. `packages/infrastructure/news/claude_cli_news_transport.py` (full read 173 LOC; claude_cli_news_transport function L96-155 + make_claude_cli_news_transport factory L158-173 — drop-in replacement for _default_transport per D-050 § Deferred D-051 closure; ALREADY-SHIPPED; consumed verbatim by D2 transport-flip)
14. `packages/domain/news/models/extracted_claim.py` (full read 83 LOC; ExtractedClaim frozen+slots dataclass + Rule 6 invariants + _MAX_EXCERPT_CHARS=500 + __post_init__ validation chain; modification target for D1 NEW FIELDS)
15. `packages/domain/news/value_objects/extractor_metadata.py` (full read 63 LOC; ExtractorMetadata frozen+slots + Rule 6 fields; UNCHANGED this sub-plan)
16. `packages/domain/news/value_objects/sentiment.py` (full read 31 LOC; Sentiment 5-class StrEnum; UNCHANGED this sub-plan; consumed via existing extractor parse path)
17. `packages/domain/news/services/claim_extraction_service.py` (full read 70 LOC; ClaimExtractionService + LlmExtractorProtocol Protocol — DI consumer of extractor at apps/cli/ingest_news_*.py; UNCHANGED this sub-plan; new ExtractedClaim fields flow through unchanged)
18. `packages/application/news/ports/llm_extractor_port.py` (full read 50 LOC; LlmExtractorPort Protocol — `extract(article: NewsArticle) -> list[ExtractedClaim]` signature; UNCHANGED this sub-plan — new fields are on ExtractedClaim domain model, not on port signature)
19. `packages/application/nlp/ports/text_tokenizer_port.py` (full read 51 LOC; TextTokenizerPort Protocol — `tokenize(text: str) -> list[str]`; consumed via DI at D2)
20. `packages/application/nlp/ports/vn_lexicon_port.py` (per current-execution.md S365 row D1 55 LOC; VnLexiconPort Protocol — `score(text: str) -> SentimentScore`; consumed via DI at D2)
21. `packages/application/nlp/ports/__init__.py` (full read 7 LOC; exports TextTokenizerPort + VnLexiconPort — both available for D2 import)
22. `packages/infrastructure/nlp/vn_tokenizer.py` (full read 148 LOC; VnTokenizer pyvi adapter + WhitespaceTokenizer fallback — DI source for D2)
23. `apps/extraction/sentiment/__init__.py` (full read 16 LOC; exports SentimentScore + VN_CULTURAL_ANCHORS + VN_SENTIMENT_LEXICON_VERSION + VnSentimentLexicon — DI source for D2)
24. `apps/extraction/sentiment/vn_lexicon.py` (partial via current-execution.md S365 row 494 LOC; VnSentimentLexicon + SentimentScore + VN_CULTURAL_ANCHORS frozenset — DI source for D2; full read deferred to S368 dev STEP 0.1 VBW)
25. `apps/extraction/sentiment/test_vn_lexicon.py` (offset 330-380 read; TC 23 + 24 + 25 + 26 audit patterns — confirms VnSentimentLexicon + VN_CULTURAL_ANCHORS instantiable + import path stable)
26. `packages/infrastructure/news/test_adapters.py` (offset 250-350 read; existing extractor tests at L257-348 — modification target for D3 test extensions; `_make_extractor` factory + `_vhm_article` fixture pattern; transport stub via `transport=lambda _system, _body: response` kwarg)
27. `apps/cli/ingest_news_cafef.py` (offset 155-245 read; `extractor = ClaudeLlmExtractor()` no-arg construction at L161 — DI default-path consumer; backward-compat surface; existing CLI continues to work unchanged with new default transport per DD-2)
28. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (lines 246-267 referenced via parent plan; sub-deliverables for E.3 — augment extractor + cultural anchors + lexicon hint integration; consistent with parent DD-5)
29. `.claude/skills/prompt-engineering/SKILL.md` (full read 139 LOC; § No-LLM-Math pattern + § Validation Pre-Conditions + § Anti-Patterns "Ask LLM for ratios, percentages, prices, ranks (I-S1)" — confirms Rule 16 mode 2 IS the correct pattern when numeric output is required; lexicon_score satisfies pattern via deterministic-echo; mentioned_pump_anchors satisfies via deterministic frozenset intersection)
30. `.claude/agents/sandwich-architect.md` (offset 35-130 read; Phase 1b template L42-65 calibration path + L110-120 sub-track 3 mandatory fields + L207-210 observation mandate; recalibrated PLAN budget per M-S360-2)
31. `agent-workspace/constitution/financial-data-protocol.md` Rule 16 (referenced via existing extractor docstring + ADR D-065 mode 2 deterministic-pipeline-echo authoritative spec; CHARTER tier)
32. Grep `import anthropic|from anthropic|ANTHROPIC_API_KEY` across repo — 30 matches; 1 production code site (claude_llm_extractor.py:84; removal target this sub-plan); 4 ingest CLI doc references (no production import); test_vn_lexicon.py:342 (verifier grep-pattern; PASSES post-D2); use_case_builder.py + apps/dashboard/pages docstrings (historical doc; not removed this sub-plan — separate hygiene sweep); pyproject.toml.tomli not touched
33. Glob `apps/extraction/**/*.py` — 4 files confirmed (sentiment + __init__ × 2 + test + cli pending); D5 adds cli/extract_vn_claims.py + may extend apps/extraction namespace if architect-judgement suggests; defer to dev IMPL
34. Glob `agent-workspace/memory/decisions/0*.md` — 60+ ADRs through D-071; D-072 next slot for this sub-plan
35. Grep `ClaudeLlmExtractor|claude_cli_news` across packages/ + apps/ — 16 matches all expected (1 module def + 1 transport module + 4 CLI consumers + 2 test files + 8 doc references); clean DI substrate

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (PRECEDENT n=2 from S362 + S365; sub-plan 031 IMPL inherits this precedent)
- **sample_size**: **2** (S362: ~159K Sonnet over ~39 min, 1053/1053 tests, 0 mistakes per current-execution.md L172-188; S365: ~150K Sonnet over ~39 min, 1079/1079 tests, 0 mistakes per current-execution.md L147-168; both clean cycles; narrow-variance window growing; sub-plan 031 IMPL projected to fit similar envelope under Opus per dispatch brief recalibration)
- **avg_wall_min observed**: ~39 min (S362+S365 both at 39 min; precision medium at n=2)
- **avg tokens_real observed**: ~155K Sonnet (S362 159K + S365 150K mean; precision medium at n=2)
- **parallel_hit_rate**: N/A precise (n=2; S362 had D3+D4 parallel projected per plan-029 § E; S365 had D3+D4 parallel projected per plan-030 § E; actual parallel-hit not telemetered per L-S354-2)
- **parallel_savings_avg**: N/A precise; THIS plan projects D3+D4 parallel (~5-10% wall reduction) similar to plan-029/030 projections
- **failure_mode frequency**: 0 mistakes per S362+S365 dual samples (M-S362-NONE + M-S365-NONE per dev self-report — clean cycles); n=2 directional clean; sub-plan 031 may surface defects via transport-flip path (new substrate at default; first production swap; risk MEDIUM per RM2 below)
- **Adjustment to default budget**: NONE for augment+tests portion (mirror S362+S365 ~150-160K); +10-20K Opus reserve for transport-flip smoke + STEP 0 anthropic-SDK-retention pre-check (CHARTER-TIER GATE risk LIKELY-VERY-LOW per RM2; non-firing default); -5-10K Opus possible swing if Opus completes faster than Sonnet at same token cost (n=2 was Sonnet; dispatch brief reverts to Opus)
- **Cold-start?**: **NO for vietnamese-nlp-impl task-class** (n=2 precedent from S362+S365 — variance window narrow but growing); **NO for AUGMENT-pattern shape** (S362+S365 both shipped clean adapter+tests; this sub-plan extends pattern with TRANSPORT-FLIP + 2 NEW FIELDS which is incremental); **YES for combined-augment-with-transport-flip shape** (sub-component novel; transport-flip never previously default-shipped per S227 D-050 § Deferred D-051 closure)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S368 dev):

- S368 dev IMPL projection: **100-150K Opus FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=2 precedent (S362+S365 ~150-160K Sonnet fit within envelope; Opus token cost similar to Sonnet but possibly less context-tokens needed) + 10-20K Opus reserve for STEP 0 STOP-AND-ASK file authoring IF anthropic-SDK-retention triggers fire
- STEP 0 evaluation overhead: ~15-25K (DI-injection-point audit + transport-flip pre-check + lexicon DI integration sketch + 3-5 article dogfood smoke — variable depending on STEP 0.4 + 0.5 outcomes)
- D1 ExtractedClaim NEW fields: ~5-8K (~+30 LOC + __post_init__ validation extension)
- D2 ClaudeLlmExtractor AUGMENT: ~25-40K (~+80 LOC: 2 DI fields + transport flip + 2 imports added + 1 import removed + system-prompt hint code + post-LLM lexicon-scoring code + post-LLM cultural-anchor extraction code)
- D3 unit test extensions: ~15-25K (~+150 LOC: 6 new test cases covering new fields + DI patterns + transport-flip + backward-compat default)
- D4 ADR D-072: ~8-12K (~80 LOC; records augment + transport-flip + new field semantics + DI graceful-degradation; cites D-050 chain)
- D5 CLI smoke: ~10-15K (~120 LOC click harness; full-pipeline integration; dumps JSON output)
- Observation + session log + mistake-log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL on anthropic-SDK-retention veto OR Rule 16 mode-2 tripwire): ~5-10K
- Reserve for inline F-fix per crawler-adapter-impl + vietnamese-nlp-impl pattern (1 IMPORTANT defect per cycle): ~10-15K
- **Total projected dev budget envelope**: 90-130K typical; 110-150K with STEP 0.5 STOP-AND-ASK path; full 150K Opus cap respected per recalibrated table

**PARALLEL OPPORTUNITY** (architect declaration for downstream S368 dev):

- D1 (ExtractedClaim NEW fields) must serialize FIRST as foundation (~3-5 min wall; small + adapter D2 imports the new field shape)
- D2 (ClaudeLlmExtractor AUGMENT) must wait for D1 (~15-20 min wall — augment is largest sub-track; transport-flip + DI + post-LLM computations bundled)
- D3 (tests) + D4 (ADR D-072) can run in parallel post-D2 ship — disjoint file scopes per § E coordination_paths_exclusive (max(8, 5) = ~8 min)
- D5 (CLI smoke) must wait for D2 + D1 (sequential after extractor ships; ~6 min wall — full-pipeline integration smoke)
- Sequential wall projection: 4 + 18 + 8 + 6 = ~36 min wall
- Parallel D3+D4 wall projection: 4 + 18 + 8 + 6 = ~36 min wall (parallel doesn't shorten critical path because D5 still serializes; ~5% reduction relative to fully-sequential D3 then D4)
- 2-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk

**WHY n=2 PRECEDENT IS HONORED HONESTLY**:

- L-S354-2 + L-S366-4 carry-forward (planner-stats infrastructure gap persists through 8 sessions) means NO empirical telemetry for ANY task_class is auto-populated; manual reading via current-execution.md S362+S365 rows + mistake-log + observations is the substitute path
- S362+S365 were both Sonnet 4.6 per close rows; this sub-plan recommends Opus for S368 dev per dispatch brief recalibration (Opus token cost similar to Sonnet; may complete faster but tokens similar)
- n=2 narrow-variance window means budget envelope is DIRECTIONALLY grounded but PRECISION-MEDIUM; sub-plan 031 may legitimately exceed S362+S365 budget IF transport-flip path surfaces unexpected substrate issues (claude CLI subprocess in unexpected environment) OR if STEP 0 surfaces an anthropic-SDK-retention CHARTER-TIER GATE that consumes 10-30K of debate budget
- AUGMENT shape is structurally close to S362+S365 (port + adapter + tests + CLI ship) BUT adds transport-flip (novel for default; first production swap) — using S362+S365 n=2 for sub-plan 031 shape is HIGH-FIT (the adapter-wiring + tests + CLI portions transfer cleanly; the transport-flip + 2-new-field portion is incremental within the n=2 envelope)
- Architect declares: **n=2 precedent honored for adapter-AUGMENT + tests + CLI portions; transport-flip flagged as INCREMENTAL within envelope per RM2 — sub-plan 032 inherits growing precedent (n=2 → n=3 → n=4 →) per parent plan-028 L-S360-2 incremental calibration mandate**

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S368 dev)

### IN-scope (S368 dev MUST ship)

- ExtractedClaim NEW fields (lexicon_score + mentioned_pump_anchors) + __post_init__ validation (~+30 LOC at `packages/domain/news/models/extracted_claim.py`)
- ClaudeLlmExtractor AUGMENT: tokenizer DI + lexicon DI + transport flip + _default_transport removal + import anthropic removal + system-prompt hint emission + post-LLM lexicon scoring + post-LLM cultural-anchor extraction (~+80 LOC at `packages/infrastructure/news/claude_llm_extractor.py`)
- Unit test extensions (6 new test cases; ~+150 LOC at `packages/infrastructure/news/test_adapters.py`)
- ADR D-072 PROPOSED at IMPL tier (~80 LOC at `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md`) — records augment + transport-flip rationale + new field semantics + DI graceful-degradation + 3 revisit triggers
- CLI extract_vn_claims.py harness for D5 integration smoke (~120 LOC at `apps/cli/extract_vn_claims.py`)
- STEP 0 observation appended to S368 dev observation file
- Session log + observation file
- Mistake-log digest entry (M-S368-N if mistakes; OR explicit "no mistakes" statement)
- Plan-031 moved `pending/` → `completed/` at S369 close (NOT at S368 close — verifier acceptance gates the move; matches plan-020/022/026/027/029/030 precedent)

### OUT-of-scope for S368 dev (DEFERRED — explicit non-goals)

- Sub-theme E.4 (ticker resolver) work — separate sub-plan 032; ticker resolution refactor at claude_llm_extractor.py:177-180 is E.4 scope per parent DD-6
- D-052 anthropic-dep removal from pyproject.toml — separate cleanup ADR per D-050 § Deferred (this sub-plan removes only the SDK-import line, not the package dep)
- LLM-generated lexicon_score OR mentioned_pump_anchors (deferred per § A.3 — would violate I-S1)
- EchoValidator runtime tier enforcement (deferred per § A.3)
- Lexicon-score / tokenizer-output caching (deferred per § A.3)
- ExtractedClaim persistence schema migration (deferred per § A.3 — backward-compat via dataclass field defaults)
- Multi-perspective claim extraction (Phase F-prime BC-8 scope)
- LLM model upgrade Sonnet→Opus (deferred per § A.3)
- Prompt caching at adapter (deferred per § A.3)
- Streaming response handling (deferred per § A.3)
- Negation handling at lexicon-score level (deferred per § A.3; sub-plan 030 RM10 carry-forward)
- ExtractedClaim-field-determinism check hook (deferred per § A.3; AP-23 2+ instance trigger)

---

## C. STEP 0 — BLOCKING DEPENDENCY EVALUATION (sub-step 0.1 through 0.5)

> **CRITICAL**: STEP 0 is BLOCKING — S368 dev MUST complete sub-steps 0.1-0.5 + (CONDITIONAL) 0.5-STOP-AND-ASK before writing ANY production code in D1-D5. This is the EXISTING-EXTRACTOR-AUGMENT pattern per parent plan-028 DD-5 + plan-031 binding_decisions.

### Sub-step 0.1 — Audit existing ClaudeLlmExtractor location + API path (VBW empirical)

**Dev action**: Read these files at S368 entry (architect has done this for THIS plan; dev does fresh VBW read per AOM + AP-1 fresh-context):

- `packages/infrastructure/news/claude_llm_extractor.py` (full read 226 LOC; CONFIRM module location + class shape + `_default_transport` at L80-99 + `import anthropic` at L84 + `transport` field default at L112 + `_build_claim` at L159-218; modification target for D2 AUGMENT)
- `packages/infrastructure/news/claude_cli_news_transport.py` (full read 173 LOC; CONFIRM drop-in replacement availability — `make_claude_cli_news_transport()` factory at L158-173 returns `Callable[[str, str], str]` matching ClaudeLlmExtractor.transport field signature; ALREADY-SHIPPED per D-050 § Deferred D-051)
- `packages/domain/news/models/extracted_claim.py` (full read 83 LOC; CONFIRM existing field shape + __post_init__ validation chain; modification target for D1 NEW FIELDS)
- `apps/extraction/sentiment/vn_lexicon.py` (full read estimated 494 LOC per current-execution.md S365 row; CONFIRM VnSentimentLexicon constructor signature `VnSentimentLexicon(tokenizer: TextTokenizerPort)` + `score(text: str) -> SentimentScore` + `VN_CULTURAL_ANCHORS: frozenset[str]` exported; DI source for D2)
- `packages/infrastructure/nlp/vn_tokenizer.py` (full read 148 LOC; CONFIRM VnTokenizer + WhitespaceTokenizer instantiable; DI source for D2)
- THIS sub-plan-031 in full + parent master plan § E.3 sub-plan-031 row in § E sequencing table (line ~418) + plan-028 DD-5 EXISTING-EXTRACTOR-AUGMENT recipe (line ~297-309) + AQ-6 anthropic_api_to_subagent answer (line ~478-480) + RM6 anthropic refactor scope creep (line ~534-536)

**STOP-AND-ASK trigger**: NONE (foundational read; no decision yet)

**Acceptance**: Dev observation file cites parent plan-028 line numbers for DD-5 + AQ-6 + RM6 verbatim quotes; cites plan-029 + plan-030 line numbers for DI substrate; cites D-050 + D-051 + D-052 chain for transport-flip rationale; cites file:line for `_default_transport` removal + `import anthropic` removal + `transport` field default change

### Sub-step 0.2 — Audit existing ExtractedClaim schema (add 2 new fields per DD-3)

**Dev action**:

1. **Read existing ExtractedClaim**: `packages/domain/news/models/extracted_claim.py` lines 40-83 — confirm field order + frozen+slots dataclass shape + __post_init__ validation chain (Rule 6 invariants: claim_id, article_id, source_url, claim_text, source_text_excerpt ≤500 chars, entity grounding tickers OR sectors)
2. **Confirm new field shape**:
   - `lexicon_score: float = 0.0` (default 0.0 = neutral / no scoring done; range [-1.0, 1.0] enforced via __post_init__; Rule 16 mode 2 deterministic-pipeline echo from VnSentimentLexicon.score().numeric_score)
   - `mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)` (default empty = no anchors detected / lexicon unavailable; deterministic frozenset intersection)
3. **Backward-compat check**: existing tests at test_adapters.py:284-348 construct ExtractedClaim via extractor (not direct); via extractor `_build_claim` at claude_llm_extractor.py:159-218 — new fields will be added at extractor.extract() call site per D2; existing tests pass new fields as defaults = backward-compat preserved
4. **Persistence-compat check**: SqliteClaimRepository serializes ExtractedClaim via existing path; dataclass field defaults preserve backward-compat at deserialization (NULL/missing old-row column → default value); explicit schema migration unnecessary for v0 per § A.3 deferral

**STOP-AND-ASK trigger**: NONE (schema additions are backward-compat by construction; defaults preserve existing behavior)

**Acceptance**: Dev observation file documents new field defaults + __post_init__ validation extension (mirrors SentimentScore.__post_init__ bounds check pattern at apps/extraction/sentiment/vn_lexicon.py SentimentScore)

### Sub-step 0.3 — Anthropic_api_to_subagent migration plan (D-050 closure for news-extractor path)

**Dev action**:

1. **Audit `import anthropic`**: grep `import anthropic|from anthropic` in `packages/infrastructure/news/claude_llm_extractor.py` — EXPECT 1 match at L84 (inside `_default_transport` function body lazy-import); CONFIRMED via architect Grep (this sub-plan REMOVES this match)
2. **Confirm drop-in replacement available**: `packages/infrastructure/news/claude_cli_news_transport.py` `make_claude_cli_news_transport()` factory returns `Callable[[str, str], str]` matching `ClaudeLlmExtractor.transport` field signature (CONFIRMED: claude_llm_extractor.py:112 `transport: Callable[[str, str], str] = _default_transport` + claude_cli_news_transport.py:158-173 factory returns matching closure)
3. **Plan transport-flip code-change** (D2 lands):
   - REMOVE `_default_transport` function (lines 80-99 entire function deleted)
   - REMOVE `import anthropic` line (was at line 84 inside removed function; gone with function)
   - CHANGE `transport: Callable[[str, str], str] = _default_transport` to `transport: Callable[[str, str], str] = field(default_factory=make_claude_cli_news_transport)`
   - ADD `from packages.infrastructure.news.claude_cli_news_transport import make_claude_cli_news_transport` import near top
4. **Existing CLI compat** (no CLI code change): apps/cli/ingest_news_*.py at L161/L210/L213/L206 use `extractor = ClaudeLlmExtractor()` — no-arg construction picks up new default per DI factory; backward-compat preserved at CLI surface
5. **Test compat** (no test signature change): test_adapters.py:277-281 `_make_extractor` factory uses `transport=lambda _system, _body: response` kwarg — explicit kwarg overrides default; all existing tests pass unchanged

**STOP-AND-ASK trigger (CHARTER-TIER GATE)**: IF claude CLI substrate unavailable in S368 dev environment (e.g. `which claude` returns nothing OR `claude --version` fails) → cannot smoke-test transport-flip → write `human-workspace/notifications/STOP-FINDING-S368-claude-cli-substrate-unavailable.md` documenting (1) env-check evidence, (2) options for user pick: (a) install claude CLI in dev env then resume, (b) defer transport-flip to separate sub-plan + ship augment-only (lexicon + tokenizer + new fields without flip), (c) retain anthropic SDK as default + escalate to CHARTER-TIER reversal of D-050 SYSTEMIC (HIGHLY UNLIKELY per user 2026-05-09 directive)

**Acceptance**: Dev observation file documents transport-flip code-change plan + env-check result (claude CLI version + path) + grep result (zero `import anthropic` in claude_llm_extractor.py post-D2 expected); existing CLI + test signatures confirmed unchanged

### Sub-step 0.4 — Rule 16 mode-2 by-construction audit for NEW fields (BINDING per § Charter compliance)

**Dev action**:

1. **Audit lexicon_score path for LLM invocation**:
   - In `packages/infrastructure/news/claude_llm_extractor.py` (post-D2 modification): grep `import anthropic|import openai|from anthropic|from openai|llm_extractor|claude_subagent` — expect ZERO matches in the file (transport flip removes the only `import anthropic`; lexicon scoring uses pure-function `VnSentimentLexicon.score()`)
   - In `_build_claim` post-LLM step (D2 NEW code): `lexicon_score = lexicon.score(article.body_excerpt).numeric_score if lexicon else 0.0` — pure function; deterministic; NO LLM
2. **Audit mentioned_pump_anchors path for LLM invocation**:
   - Same grep as above (covered)
   - In `_build_claim` post-LLM step (D2 NEW code): `mentioned_pump_anchors = tuple(sorted(VN_CULTURAL_ANCHORS & set(lexicon.score(article.body_excerpt).keyword_hits))) if lexicon else ()` — pure function deterministic frozenset intersection over sorted-tuple result; NO LLM
3. **Audit LLM JSON-output contract** for accidental volunteer numeric emission:
   - Existing system prompt at claude_llm_extractor.py:55-75 already enforces RULE 1 NO LLM MATH explicitly
   - Existing returned JSON contract at docstring L13-29 lists 8 fields: claim_text, source_text_excerpt, sentiment, mentioned_tickers, mentioned_sectors, key_phrases, tone_indicators, confidence — NONE include lexicon_score or mentioned_pump_anchors; LLM cannot volunteer these per system-prompt-enforced contract
   - D2 system-prompt UPDATE explicitly adds note: "lexicon_score and mentioned_pump_anchors are computed POST-LLM by deterministic code; do NOT include in your JSON output"
4. **Document Rule 16 mode-2 satisfaction inline** — at `packages/domain/news/models/extracted_claim.py` lexicon_score field docstring: `# I-S1 + Rule 16 mode 2: deterministic-pipeline echo of VnSentimentLexicon.score(body).numeric_score; LLM never emits this field`

**STOP-AND-ASK trigger (CHARTER-TIER GATE)**: IF post-D2 LLM-output drift surfaces volunteer lexicon_score or mentioned_pump_anchors emission in actual extraction call (D5 dogfood smoke detects via JSON parse including these fields) → FIRE STOP-AND-ASK with notification `human-workspace/notifications/STOP-FINDING-S368-rule-16-violation-llm-drift.md` documenting (1) which field, (2) which article triggered, (3) options: (a) tighten system prompt + re-test (preferred per Karpathy P2 simplicity), (b) ignore drift via deterministic-only construction at _build_claim (defense-in-depth; default behavior already does this — drift would be silently ignored), (c) escalate to CHARTER-TIER for new I-S<N> on LLM-output-field-discipline

**Acceptance**: Empty `import anthropic` grep result recorded; lexicon_score + mentioned_pump_anchors docstrings cite Rule 16 mode 2; system-prompt update verified verbatim in claude_llm_extractor.py source

### Sub-step 0.5 — Dogfood integration smoke (D5 CLI on ≥3 real articles) + I-S34 carry-forward

**Dev action** (POST-D5 ship; this is the integration-smoke acceptance gate):

1. **I-S34 HARD-REJECT carry-forward**: `pip list | grep -iE "patchright|playwright[-_]stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|cloudflare"` — expect ZERO matches (no new deps this sub-plan; claude CLI is local subprocess + pyvi already cleared)
2. **D-059 determinism smoke** (post-D2 + D5 ship; mirror sub-plan 029+030 STEP 0.7):
   ```bash
   # Smoke-test full extractor pipeline output determinism (stub-transport for reproducibility):
   python -c "
   from packages.infrastructure.news import ClaudeLlmExtractor
   from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer
   from apps.extraction.sentiment.vn_lexicon import VnSentimentLexicon
   from datetime import UTC, datetime
   from packages.domain.news.models import NewsArticle
   from packages.contracts import Ticker
   
   stub_response = '''{\"claims\":[{\"claim_text\":\"VHM tăng trần\",\"source_text_excerpt\":\"VHM tăng trần phiên này\",\"sentiment\":\"bullish\",\"mentioned_tickers\":[\"VHM\"],\"mentioned_sectors\":[],\"key_phrases\":[],\"tone_indicators\":[],\"confidence\":0.8}]}'''
   tokenizer = VnTokenizer()
   lexicon = VnSentimentLexicon(tokenizer=tokenizer)
   ex = ClaudeLlmExtractor(
       transport=lambda _s, _b: stub_response,
       clock=lambda: datetime(2026, 5, 17, 10, 0, tzinfo=UTC),
       tokenizer=tokenizer,
       lexicon=lexicon,
   )
   art = NewsArticle(
       article_id='a1', source='cafef', source_url='https://x',
       title='VHM tăng trần', body_excerpt='VHM tăng trần hôm nay; đội lái đẩy giá lên đỉnh.',
       published_at=datetime(2026, 5, 17, 9, 0, tzinfo=UTC),
       ingested_at=datetime(2026, 5, 17, 9, 5, tzinfo=UTC),
       mentioned_tickers=(Ticker('VHM'),),
   )
   c1 = ex.extract(art)
   c2 = ex.extract(art)
   assert c1 == c2, f'NON-DETERMINISTIC: {c1} != {c2}'
   print(f'OK: extractor pipeline is deterministic across 2 runs')
   print(f'  claim={c1[0].claim_text!r}, lexicon_score={c1[0].lexicon_score:.4f}, anchors={c1[0].mentioned_pump_anchors}')
   "
   ```
3. **Real-corpus dogfood** (POST-D5; live run): pick 3 articles from `data/raw/news/vietstock/2026-05-16/` OR any available corpus; run `python apps/cli/extract_vn_claims.py --input-html-dir <dir> --limit 3 --output /tmp/claims.json --summary` (transport flips silently to claude CLI substrate per D2 default); record per-article claim count + lexicon_score distribution + mentioned_pump_anchors distribution in session log
4. **Charter Principle 7 (Dogfood) satisfaction**: dev observation MUST record dogfood smoke + claim-extraction sample + lexicon-score + anchor extraction empirical result

**STOP-AND-ASK trigger (TACTICAL-TIER)**: 
- **(a) Determinism smoke fails** (extractor output differs across 2 calls) → write `human-workspace/notifications/STOP-FINDING-S368-extractor-non-deterministic.md` documenting (1) which field differs, (2) which DI substrate suspect (tokenizer / lexicon / transport); options: (a) lock random state, (b) defer transport-flip if claude CLI variance suspected, (c) escalate
- **(b) Dogfood smoke fails** (claude CLI subprocess fails OR extractor returns 0 claims for all 3 articles OR system-prompt-violation occurs e.g. LLM emits prose instead of JSON) → write `human-workspace/notifications/STOP-FINDING-S368-dogfood-extraction-failed.md` with diagnostics; options: (a) retry with mock LLM (`STOCKFORGE_MOCK_LLM=true`) for unit-test acceptance + flag dogfood gap, (b) defer transport-flip to separate sub-plan, (c) defer all of D5 to follow-on session

**Acceptance**: I-S34 grep clean + determinism smoke PASS + dogfood smoke records ≥3 articles processed + ≥1 claim extracted + at least 1 article with non-zero lexicon_score (validates lexicon DI works end-to-end)

---

## D. Architecture Decisions (DD-1 through DD-7)

### DD-1: EXISTING-EXTRACTOR-AUGMENT (NOT parallel VnClaudeExtractor class)

**Decision**: AUGMENT existing `packages/infrastructure/news/claude_llm_extractor.py` ClaudeLlmExtractor dataclass with 2 new DI fields (tokenizer + lexicon) + transport-flip + 2 new ExtractedClaim emission fields. NOT a parallel `VnClaudeExtractor` class.

```python
@dataclass
class ClaudeLlmExtractor:
    transport: Callable[[str, str], str] = field(default_factory=make_claude_cli_news_transport)  # CHANGED per DD-2
    clock: Callable[[], datetime] = field(default_factory=lambda: lambda: datetime.now(UTC))
    model: str = _DEFAULT_MODEL
    version: str = _DEFAULT_VERSION
    system_prompt: str = _SYSTEM_PROMPT  # may be augmented per DD-5
    tokenizer: TextTokenizerPort = field(default_factory=WhitespaceTokenizer)  # NEW DI per DD-5
    lexicon: VnLexiconPort | None = None  # NEW DI per DD-5; None=skip lexicon scoring
```

**Rationale**:
- Per parent plan-028 DD-5 + AQ-5 + L-S345-3 single-helper-with-keyword-only-flag precedent — AUGMENT preserves backward-compat (existing 4 CLI + existing tests + existing CLI consumers ALL continue to work with default no-arg `ClaudeLlmExtractor()`)
- Per Karpathy P3 surgical-changes — one file modified vs 2 files created; existing 226 LOC + ~80 LOC = ~306 LOC total adapter file (within Karpathy P3 envelope)
- Per DDD tactical patterns — single Adapter class with optional DI; concrete behavior swap via constructor

**Adversarial alternate considered**:
- (i) Parallel `VnClaudeExtractor` class → REJECTED (duplicate-class maintenance burden; existing 4 CLI would need to choose between extractors = scattered choice; per Karpathy P2 simplicity = one extractor + DI is cleaner)
- (ii) Subclass `class VnClaudeExtractor(ClaudeLlmExtractor)` → REJECTED (dataclass inheritance with new fields = mypy + dataclass-inheritance complexity per PEP 557 known gotchas; field default ordering issues; simpler to add fields to existing class with defaults)

### DD-2: Transport default FLIPPED from _default_transport to make_claude_cli_news_transport (D-050 closure)

**Decision**: REMOVE `_default_transport` function entirely. REMOVE `import anthropic` line (was inside _default_transport function body lazy-import; gone with function). REMOVE `# type: ignore[import-not-found]` comment on that import. CHANGE `transport` field default from `= _default_transport` to `= field(default_factory=make_claude_cli_news_transport)`. ADD `from packages.infrastructure.news.claude_cli_news_transport import make_claude_cli_news_transport` import near top.

**Rationale**:
- Per D-050 SYSTEMIC + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09) — every direct anthropic SDK call MUST refactor to subagent dispatch; news-extractor was deferred to D-051 per D-050 § Deferred; THIS sub-plan closes D-051 deferral
- Per plan-008 G.1 (master plan-008 line 410) — "Remove `import anthropic` from `claude_llm_extractor.py:84`" — explicit deletion target; THIS sub-plan satisfies
- Per L-S227-1 + plan-011 (line 83 + 240) — "0 `import anthropic` hits in `packages/` and `apps/` (excluding `tests/`)" — verifier S369 grep-asserts ZERO matches for news-extractor surface (analysis-extractor already at zero per S227 D-050 close)
- Drop-in replacement available at `make_claude_cli_news_transport()` factory (already-shipped per D-050 § Deferred D-051); signature matches existing `_default_transport` (str, str) → str; constructor field-default change is mechanically simple
- D-052 anthropic-dep removal from pyproject.toml — separate cleanup ADR per D-050 § Deferred; narrows scope risk of THIS sub-plan; transport flip + import removal is the SYSTEMIC rule satisfaction; dep removal is hygiene

**Adversarial alternate considered**:
- (i) Keep `_default_transport` + add `transport: Callable = _default_transport_legacy_DEPRECATED_2026_05_17` deprecation pointer + flip default at later sub-plan → REJECTED (delays D-050 closure; D-050 is CHARTER tier ACCEPTED with explicit deferral pointer to "D-051 follow-up"; THIS sub-plan IS D-051 closure)
- (ii) Add new field `transport_backend: Literal["anthropic","subagent"] = "subagent"` instead of direct callable swap → REJECTED (adds Literal complexity; existing tests already work via callable kwarg; cleaner to keep callable type)
- (iii) Block on D-052 dep removal also in this sub-plan → REJECTED (scope creep; D-052 explicitly deferred per D-050 § Follow-ups; separate cleanup ADR is appropriate)

### DD-3: ExtractedClaim NEW fields = lexicon_score (float) + mentioned_pump_anchors (tuple[str, ...])

**Decision**: Add 2 fields to `packages/domain/news/models/extracted_claim.py` ExtractedClaim frozen+slots dataclass:

```python
@dataclass(frozen=True, slots=True)
class ExtractedClaim:
    # ... existing fields unchanged ...
    key_phrases: tuple[str, ...] = field(default_factory=tuple)
    tone_indicators: tuple[str, ...] = field(default_factory=tuple)
    # NEW per plan-031 DD-3:
    lexicon_score: float = 0.0  # I-S1 + Rule 16 mode 2 deterministic-pipeline echo
    mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)  # deterministic frozenset intersection
```

**Rationale**:
- Per parent plan-028 DD-5 step 4 + 5 — `lexicon_score: float` + `mentioned_pump_anchors: tuple[str, ...]` ARE the value-add fields for Theme I E.3
- Per Rule 16 mode 2 — `lexicon_score` is deterministic-pipeline echo from VnSentimentLexicon.score().numeric_score; bounds enforced at __post_init__ matching SentimentScore.__post_init__ pattern
- Per Karpathy P3 surgical-changes — defaults preserve backward-compat (existing tests construct ExtractedClaim with old fields only = ok per dataclass field defaults)
- Per Charter Principle 4 (Proprietary data moat) — VN-cultural-anchor extraction IS the moat per parent DD-5 step 5

**Adversarial alternate considered**:
- (i) Add fields to ExtractorMetadata (provenance bundle) → REJECTED (lexicon_score is per-CLAIM not per-EXTRACTION-event; mentioned_pump_anchors is per-CLAIM; ExtractorMetadata is per-extraction provenance not per-claim payload; wrong abstraction)
- (ii) Add a separate `ClaimEnrichment` sidecar dataclass → REJECTED (extra wrapper; downstream consumer would need to unwrap; field defaults preserve backward-compat better via direct addition)
- (iii) Add only lexicon_score; defer mentioned_pump_anchors to E.4 ticker resolver → REJECTED (mentioned_pump_anchors is cultural-anchor extraction not ticker resolution; logical scope = E.3 lexicon-driven cultural-anchor surface; per parent DD-5 step 5)

### DD-4: Rule 16 mode 2 satisfaction = DETERMINISTIC-PIPELINE ECHO (lexicon_score + mentioned_pump_anchors)

**Decision**: Both new numeric/structural fields satisfy Rule 16 mode 2 (deterministic-pipeline echo) BY CONSTRUCTION:

```python
def _build_claim(self, raw: object, *, article: NewsArticle, ordinal: int, extracted_at: datetime, prompt_hash: str) -> ExtractedClaim | None:
    # ... existing parse + invariant checks unchanged ...
    
    # NEW per plan-031 DD-4 — deterministic post-LLM computation
    if self.lexicon is not None:
        score = self.lexicon.score(article.body_excerpt)
        lexicon_score = score.numeric_score  # I-S1 + Rule 16 mode 2: deterministic echo
        mentioned_pump_anchors = tuple(sorted(VN_CULTURAL_ANCHORS & set(score.keyword_hits)))  # deterministic intersection
    else:
        lexicon_score = 0.0
        mentioned_pump_anchors = ()
    
    return ExtractedClaim(
        # ... existing fields ...
        lexicon_score=lexicon_score,
        mentioned_pump_anchors=mentioned_pump_anchors,
    )
```

**Rationale**:
- Per constitution `financial-data-protocol.md` Rule 16 mode 2 — "deterministic-pipeline echo" path satisfies Rule 16 when numeric output comes from a deterministic computation BEFORE OR AFTER the LLM call, not FROM the LLM itself
- Per I-S1 (NO LLM math) — `lexicon.score()` is pure-function; `VN_CULTURAL_ANCHORS & set(...)` is pure-function; no LLM in either path
- Per parent plan-028 DD-5 step 4 — explicitly says "the LLM's categorical sentiment label (already shipped per Rule 7) is the canonical sentiment; the lexicon-score is a NUMERIC SIGNAL added as a NEW ExtractedClaim field `lexicon_score: float` (Rule 16 mode 2 deterministic-echo)"
- LLM still emits `sentiment: Sentiment` (5-class categorical) per Rule 7 (UNCHANGED); LLM does NOT emit `lexicon_score` or `mentioned_pump_anchors` per system-prompt update at DD-5
- Sorted-tuple result for mentioned_pump_anchors ensures determinism (frozenset & set returns unordered; sorted() enforces ordering)

**Adversarial alternate considered**:
- (i) LLM emits lexicon_score directly (free-text → numeric) → REJECTED (violates I-S1 + Rule 16 mode 1; defeats purpose of having deterministic VnSentimentLexicon)
- (ii) EchoValidator runtime tier enforcement (Rule 16 § Enforcement runtime) → DEFERRED per § A.3 (lexicon_score is computed POST-LLM so EchoValidator-style match between LLM-emitted and deterministic-derived doesn't apply; EchoValidator is for the LLM-emits-numeric-that-should-match-deterministic-source case which this sub-plan deliberately avoids per DD-4)

### DD-5: Tokenizer DI = PRE-LLM PROMPT HINT (NOT body transformation)

**Decision**: Tokenizer is OPTIONAL injection. When non-default (production VnTokenizer; not WhitespaceTokenizer fallback), extractor appends a HINT LINE to the system prompt:

```python
def _build_system_prompt(self) -> str:
    base = self.system_prompt
    if isinstance(self.tokenizer, VnTokenizer):  # only add hint if non-fallback
        # Hint line; LLM still reads original Vietnamese body_excerpt
        return base + "\n\nHINT: Vietnamese multi-syllable terms are joined with underscore in your tokenization context (e.g. 'cổ_phiếu', 'thị_trường'). When quoting `source_text_excerpt` verbatim, preserve the original Vietnamese spacing (no underscores) from the article body."
    return base
```

LLM still reads the ORIGINAL Vietnamese `article.body_excerpt` (NOT tokenized). The hint is for the LLM to know that `cổ phiếu` is one semantic unit (not two) when extracting `source_text_excerpt` verbatim quotes. This is NOT data transformation — input data to LLM is unchanged.

**Rationale**:
- Per parent plan-028 DD-5 step 2 — "Preprocessing step BEFORE LLM call: tokenize article body via injected tokenizer; pass token-list as additional system-prompt context"
- BUT per architect-judgement (this plan refinement): passing tokenized body as input data risks LLM emitting tokenized form in `source_text_excerpt` (violates Rule 6 verbatim quote discipline); SAFER approach = pass tokens as HINT for excerpt-formation discipline, LLM still reads original body
- Per L-S345-3 single-helper-with-keyword-only-flag precedent — tokenizer DI as OPT-IN (only non-fallback triggers hint); default WhitespaceTokenizer = no hint = no behavior change from current extractor (backward-compat)
- Per Karpathy P2 simplicity — hint-line approach is 2 lines of code; full-tokenization-as-context would be 20+ lines + Rule 6 compliance reasoning

**Adversarial alternate considered**:
- (i) Pass full tokenized body as additional context block (LLM reads both original + tokenized) → REJECTED (risk of LLM confusing tokenized form for verbatim quote; Rule 6 violation surface; per Karpathy P2 simplicity = simpler is better)
- (ii) Skip tokenizer hint entirely; rely on LLM's native Vietnamese tokenization (Claude is multilingual) → REJECTED (defeats purpose of VnTokenizer DI; if Claude's native tokenization were sufficient, sub-plan 029 would have been unnecessary)
- (iii) Apply tokenizer hint always (also for WhitespaceTokenizer fallback) → REJECTED (WhitespaceTokenizer fallback has 0% quality on multi-syllable VN per plan-029 STEP 0; emitting a hint based on low-quality tokens = noise; better to skip hint for fallback)

### DD-6: ADR D-072 PROPOSED-AT-IMPL — VN Claim Extraction Wrapper AUGMENT + transport flip + 2 NEW fields

**Decision**: D4 sub-track ships `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` at IMPL tier (per severity-schema auto-ratifies on commit; D-072 next ADR slot after D-071):

```markdown
---
id: 072
title: VN Claim Extraction Wrapper — AUGMENT existing extractor + anthropic→subagent default-flip + 2 new ExtractedClaim fields
status: PROPOSED
date: 2026-05-XX
authors: sandwich-dev S368
level: IMPL
supersedes: []
superseded-by: []
related: [D-050 ACCEPTED 2026-05-09 anthropic→subagent SYSTEMIC, D-051 deferred news-extractor refactor (closed by THIS ADR), D-052 deferred SDK dep removal (still deferred per § A.3), D-070 pyvi tokenizer, D-071 VN sentiment lexicon]
empirical_close_verify: |
  - ClaudeLlmExtractor instantiable with new DI signature + extract() returns ExtractedClaim with new fields
  - mypy --strict + ruff + pytest on packages/infrastructure/news/ exit 0
  - test_adapters.py existing 4+ tests PASS unchanged + 6 new tests PASS
  - ZERO `import anthropic` in packages/infrastructure/news/claude_llm_extractor.py post-D2 (grep-asserted)
  - Drop-in transport make_claude_cli_news_transport() factory consumed verbatim from claude_cli_news_transport.py (UNCHANGED)
  - STEP 0 dogfood smoke records ≥3 articles processed via D5 CLI with claude CLI substrate
  - DC-FILE-1 through DC-FILE-N all PASS per plan-031 § F
---

## Decision

ClaudeLlmExtractor AUGMENTED in-place per parent plan-028 DD-5 EXISTING-EXTRACTOR-AUGMENT strategy: (a) 2 NEW DI fields tokenizer + lexicon (default = WhitespaceTokenizer fallback + None); (b) DEFAULT TRANSPORT FLIPPED to make_claude_cli_news_transport() factory per D-050 SYSTEMIC + user memory rule; (c) `_default_transport` function + `import anthropic` line REMOVED; (d) 2 NEW ExtractedClaim fields lexicon_score + mentioned_pump_anchors emitted by extractor post-LLM (Rule 16 mode 2 deterministic-pipeline echo by construction).

## Pattern source

Sub-plan 029 (D-070 pyvi VnTokenizer) + sub-plan 030 (D-071 VN sentiment lexicon UNCALIBRATED-V0) — DI substrate consumed verbatim; THIS sub-plan integrates both into existing claim extraction surface.

D-050 SYSTEMIC mandate + user memory rule (verbatim 2026-05-09) — news-extractor refactor was deferred to D-051; THIS ADR closes D-051 by flipping default + removing SDK-import. D-052 (anthropic dep removal from pyproject.toml) explicitly NOT in scope — separate cleanup ADR per D-050 § Deferred.

## DI graceful-degradation

- Default: `ClaudeLlmExtractor()` no-arg construction = tokenizer=WhitespaceTokenizer + lexicon=None + transport=make_claude_cli_news_transport() = lexicon_score=0.0 + mentioned_pump_anchors=() + claude CLI substrate
- Production wire-up: `ClaudeLlmExtractor(tokenizer=VnTokenizer(), lexicon=VnSentimentLexicon(tokenizer=VnTokenizer()))` = lexicon scoring active
- Tests: `ClaudeLlmExtractor(transport=stub_lambda)` = stub LLM substrate

## Rule 16 mode 2 satisfaction (by construction)

- `lexicon_score: float` is `lexicon.score(article.body_excerpt).numeric_score` (deterministic dict-lookup + arithmetic; NO LLM)
- `mentioned_pump_anchors: tuple[str, ...]` is `tuple(sorted(VN_CULTURAL_ANCHORS & set(lexicon.score(body).keyword_hits)))` (deterministic frozenset intersection over sorted-tuple result; NO LLM)
- LLM still emits sentiment (5-class categorical per Rule 7 UNCHANGED); LLM does NOT emit lexicon_score or mentioned_pump_anchors per system-prompt update

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. claude CLI substrate unavailable in production runtime → revert to anthropic SDK transport via constructor kwarg (D-050 § Edge cases path); CHARTER-TIER consideration if widespread
2. LLM-output drift surfaces volunteer lexicon_score or mentioned_pump_anchors emission → tighten system prompt (preferred) OR escalate to new I-S<N>
3. Lexicon coverage <50% on production extraction (i.e. lexicon_score = 0.0 for >70% of claims) → triggers sub-plan 030-V2 calibration cycle per ADR D-071 revisit trigger 1

## Risks

- RM1: claude CLI subprocess unavailable in test/CI env → mitigated via test stub-transport (existing pattern at test_adapters.py:278-281)
- RM2: lexicon coverage on real corpus unknown until calibration cycle ships → ADR D-071 revisit trigger 1 monitors
- RM3: System prompt update adds tokens to every call → minor cost increase (~5 tokens/call); negligible at v0 throughput

## Source

- plan-031 § D DD-1 through DD-7
- agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md (D-050)
- packages/infrastructure/news/claude_llm_extractor.py (modification target)
- packages/infrastructure/news/claude_cli_news_transport.py (consumed verbatim per D-051 closure)
- packages/domain/news/models/extracted_claim.py (NEW fields)
- agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (parent plan-028 DD-5 + AQ-6 + § K.2 anticipated FLAGS)
```

**Rationale**:
- Per Karpathy P3 surgical-changes — ADR D-072 records the AUGMENT decision + transport-flip rationale in one place; future readers see the chain D-050 → D-051 deferred → D-072 closes
- Per AP-7 anti-vacuous-defer — explicit revisit triggers named for each risk
- Per severity-schema — IMPL tier auto-ratifies on commit; main session commits this sub-plan's IMPL output

### DD-7: Existing claude_cli_news_transport.py UNCHANGED (already-shipped infrastructure)

**Decision**: NO modification to `packages/infrastructure/news/claude_cli_news_transport.py`. THIS sub-plan ADOPTS the factory + helper functions verbatim. Verifier reads READ-ONLY at S369.

**Rationale**:
- File already-shipped per D-050 § Deferred D-051 (architect verified via Read tool 173 LOC + grep `make_claude_cli_news_transport`)
- Signature match confirmed: `Callable[[str, str], str]` matches existing `ClaudeLlmExtractor.transport` field type
- Per Karpathy P3 surgical-changes — touch only what task requires; transport file ALREADY satisfies the SYSTEMIC rule for news-extractor surface; no modification needed
- If transport-flip surfaces an unanticipated bug at claude_cli_news_transport.py path (e.g. JSON envelope parse fails), STOP-FINDING-S368-claude-cli-substrate-bug.md fires; bug fix is SEPARATE sub-plan scope (this sub-plan is consumer not provider of transport)

**Adversarial alternate considered**:
- (i) Inline the make_claude_cli_news_transport logic into claude_llm_extractor.py → REJECTED (violates separation of concerns; transport file exists for this exact reason per D-050 architecture)

---

## E. Sub-track decomposition (D1-D5 with parallel_with per plan-025 contract)

### D1 — ExtractedClaim NEW fields (foundation; root sub-track)

- **parallel_with**: []  (foundation; D2 blocks_on D1; D3 blocks_on D1 transitively via D2)
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/domain/news/models/extracted_claim.py]
- **estimated_wall_min**: 4

**Module**: `packages/domain/news/models/extracted_claim.py` (MODIFIED; ~+30 LOC).

**Content** (architect-proposed; dev verifies + adjusts):

```python
# Add to existing ExtractedClaim dataclass (preserve all existing fields):

@dataclass(frozen=True, slots=True)
class ExtractedClaim:
    # ... existing fields unchanged (claim_id through tone_indicators) ...
    
    # NEW per plan-031 DD-3 + DD-4 (Rule 16 mode 2 deterministic-pipeline echo)
    lexicon_score: float = 0.0
    """I-S1 + Rule 16 mode 2: deterministic-pipeline echo of
    VnSentimentLexicon.score(article.body_excerpt).numeric_score.
    Default 0.0 = neutral / no lexicon scoring performed.
    Range enforced via __post_init__ to [-1.0, 1.0].
    LLM never emits this field per Rule 1 NO LLM MATH (system-prompt-enforced).
    """
    
    mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)
    """I-S1 + deterministic frozenset intersection: tuple(sorted(
    VN_CULTURAL_ANCHORS & set(VnSentimentLexicon.score(body).keyword_hits))).
    Default empty = no anchors detected OR lexicon unavailable.
    Sorted for deterministic output order.
    LLM never emits this field per Rule 1 NO LLM MATH (system-prompt-enforced).
    """

    def __post_init__(self) -> None:
        # ... existing validation chain unchanged ...
        
        # NEW per plan-031 DD-3 — Rule 16 mode 2 bounds enforcement
        if not -1.0 <= self.lexicon_score <= 1.0:
            raise ExtractedClaimInvariantError(
                f"lexicon_score {self.lexicon_score} not in [-1.0, 1.0] "
                f"(Rule 16 mode 2 range violation; mirrors SentimentScore bounds)"
            )
```

**Verify**: mypy --strict + ruff PASS on the modified file; existing test_adapters.py extractor tests at L284-348 still PASS (defaults preserve backward-compat)

### D2 — ClaudeLlmExtractor AUGMENT (largest sub-track; blocks D3/D4/D5)

- **parallel_with**: []  (D3 + D4 block_on D2; D5 blocks_on D2)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/infrastructure/news/claude_llm_extractor.py]
- **estimated_wall_min**: 18

**Module**: `packages/infrastructure/news/claude_llm_extractor.py` (MODIFIED; ~+80 LOC net delta: ~+100 LOC added - ~20 LOC removed for _default_transport function + import).

**Changes** (architect-proposed; dev applies):

1. **REMOVE lines 80-99** (entire `_default_transport` function); `import anthropic` line at L84 gone with function
2. **ADD import near top** (after existing imports):
   ```python
   from packages.application.nlp.ports import TextTokenizerPort, VnLexiconPort
   from packages.infrastructure.news.claude_cli_news_transport import (
       make_claude_cli_news_transport,
   )
   from packages.infrastructure.nlp.vn_tokenizer import VnTokenizer, WhitespaceTokenizer
   from apps.extraction.sentiment.vn_lexicon import VN_CULTURAL_ANCHORS
   ```
3. **MODIFY transport field default** at existing L112:
   ```python
   transport: Callable[[str, str], str] = field(
       default_factory=make_claude_cli_news_transport
   )
   ```
4. **ADD new DI fields** (after model + version + system_prompt fields):
   ```python
   tokenizer: TextTokenizerPort = field(default_factory=WhitespaceTokenizer)
   lexicon: VnLexiconPort | None = None
   ```
5. **ADD system-prompt augmentation** (called per-extract to optionally add hint):
   ```python
   def _build_effective_system_prompt(self) -> str:
       """Append VN-tokenization hint to system prompt if non-fallback tokenizer injected."""
       if isinstance(self.tokenizer, VnTokenizer):
           return self.system_prompt + (
               "\n\nHINT: Vietnamese multi-syllable terms are joined with underscore "
               "in your tokenization context (e.g. 'cổ_phiếu', 'thị_trường'). "
               "When quoting `source_text_excerpt` verbatim, preserve the original "
               "Vietnamese spacing (no underscores) from the article body."
           )
       return self.system_prompt
   ```
6. **MODIFY extract()** to use _build_effective_system_prompt + pass article through to _build_claim:
   ```python
   def extract(self, article: NewsArticle) -> list[ExtractedClaim]:
       body = self._build_user_message(article)
       effective_prompt = self._build_effective_system_prompt()
       try:
           raw = self.transport(effective_prompt, body)
       except Exception:
           return []
       # ... existing JSON parse + claim building unchanged ...
       prompt_hash = hashlib.sha256(effective_prompt.encode("utf-8")).hexdigest()[:16]
       # NEW per DD-4 — compute lexicon score ONCE per article (cached across claims):
       lexicon_artifacts = self._compute_lexicon_artifacts(article)
       extracted_at = self.clock()
       out: list[ExtractedClaim] = []
       for ordinal, raw_claim in enumerate(raw_claims):
           claim = self._build_claim(
               raw_claim, article=article, ordinal=ordinal,
               extracted_at=extracted_at, prompt_hash=prompt_hash,
               lexicon_artifacts=lexicon_artifacts,
           )
           if claim is not None:
               out.append(claim)
       return out
   ```
7. **ADD _compute_lexicon_artifacts**:
   ```python
   def _compute_lexicon_artifacts(self, article: NewsArticle) -> tuple[float, tuple[str, ...]]:
       """Deterministic post-LLM lexicon scoring per Rule 16 mode 2.
       
       Returns (lexicon_score, mentioned_pump_anchors). NO LLM in this path.
       """
       if self.lexicon is None:
           return 0.0, ()
       score = self.lexicon.score(article.body_excerpt)
       lexicon_score = score.numeric_score
       mentioned_anchors = tuple(sorted(VN_CULTURAL_ANCHORS & set(score.keyword_hits)))
       return lexicon_score, mentioned_anchors
   ```
8. **MODIFY _build_claim signature + body** to accept + use lexicon_artifacts:
   ```python
   def _build_claim(
       self, raw: object, *, article: NewsArticle, ordinal: int,
       extracted_at: datetime, prompt_hash: str,
       lexicon_artifacts: tuple[float, tuple[str, ...]],
   ) -> ExtractedClaim | None:
       # ... existing parse + invariant checks unchanged ...
       
       lexicon_score, mentioned_pump_anchors = lexicon_artifacts
       
       try:
           return ExtractedClaim(
               # ... existing fields unchanged ...
               key_phrases=key_phrases,
               tone_indicators=tone_indicators,
               # NEW per DD-3:
               lexicon_score=lexicon_score,
               mentioned_pump_anchors=mentioned_pump_anchors,
           )
       except ValueError:
           return None
   ```
9. **UPDATE module docstring** at L1-35 to reflect:
   - "ANTHROPIC SDK NO LONGER USED — default transport is claude CLI subprocess per D-050 + D-072"
   - "OPTIONAL DI: tokenizer (TextTokenizerPort) + lexicon (VnLexiconPort | None) per plan-031 DD-1 + DD-5"
   - "NEW ExtractedClaim fields: lexicon_score (Rule 16 mode 2 deterministic echo) + mentioned_pump_anchors (deterministic frozenset intersection)"
10. **UPDATE system prompt** (_SYSTEM_PROMPT at L55-75) to add note:
    ```
    NOTE: The fields `lexicon_score` and `mentioned_pump_anchors` are computed
    POST-LLM by deterministic code (NOT by you). DO NOT include these in your
    JSON output. Only include the 8 documented fields.
    ```

**Verify**: 
- `python -m mypy --strict packages/infrastructure/news/claude_llm_extractor.py` exits 0
- `python -m ruff check packages/infrastructure/news/claude_llm_extractor.py` exits 0
- `grep -E "^(from anthropic|import anthropic)" packages/infrastructure/news/claude_llm_extractor.py` returns ZERO matches
- `python -c "from packages.infrastructure.news import ClaudeLlmExtractor; ex = ClaudeLlmExtractor(transport=lambda s,b:'{}', lexicon=None); print(type(ex).__name__)"` exits 0

### D3 — Unit test extensions (6 new test cases; parallel with D4)

- **parallel_with**: [D4]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [packages/infrastructure/news/test_adapters.py]
- **estimated_wall_min**: 8

**Module**: `packages/infrastructure/news/test_adapters.py` (MODIFIED; ~+150 LOC; 6 new test cases).

**New test cases** (architect-proposed; dev fills):

1. `test_extractor_emits_lexicon_score_when_lexicon_injected` — instantiate `ClaudeLlmExtractor(transport=stub, tokenizer=VnTokenizer(), lexicon=VnSentimentLexicon(tokenizer=VnTokenizer()))`; extract claims from article with text containing tier-1 lexicon hits ("tăng_trần"); assert claim.lexicon_score > 0.0
2. `test_extractor_emits_mentioned_pump_anchors_when_anchor_in_body` — text contains "đội lái"; assert claim.mentioned_pump_anchors contains "đội_lái" (sorted tuple form)
3. `test_extractor_emits_zero_lexicon_score_when_lexicon_None` — `ClaudeLlmExtractor(transport=stub, lexicon=None)` (default); assert claim.lexicon_score == 0.0 + claim.mentioned_pump_anchors == ()
4. `test_extractor_existing_tests_still_pass_with_default_construction` — meta-test: assert no-arg `ClaudeLlmExtractor()` no longer requires `_default_transport` / `anthropic` import; default uses `make_claude_cli_news_transport` factory (mock the subprocess via monkeypatch on `subprocess.run` to avoid live call); assert extractor.extract() returns [] gracefully on subprocess failure
5. `test_extractor_no_anthropic_import_in_module_source` — open `claude_llm_extractor.py` source; grep `import anthropic` / `from anthropic`; assert ZERO matches per Rule 16 mode 2 + D-050 SYSTEMIC + plan-031 DD-2 grep-asserted compliance
6. `test_extractor_lexicon_score_deterministic_across_runs` — instantiate with stub transport; call extractor.extract(article) twice with identical inputs; assert ExtractedClaim.lexicon_score identical across calls (D-059 R2 compliance smoke)

**Acceptance**: pytest exit 0; 6 new cases pass; existing 4+ tests at L284-348 still pass unchanged; mypy --strict + ruff clean

### D4 — ADR D-072 PROPOSED (parallel with D3)

- **parallel_with**: [D3]
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md]
- **estimated_wall_min**: 5

**Module**: `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (NEW; ~80 LOC).

**Content**: Per DD-6 above. ADR records AUGMENT + transport-flip + new field semantics + DI graceful-degradation + 3 revisit triggers.

**Acceptance**: ADR file exists; cites D-050 + D-051 + D-052 chain + D-070 + D-071 DI substrate; lists `level: IMPL`; verifier S369 confirms ADR exists at expected path with PROPOSED status

### D5 — Integration smoke + CLI extract-and-score harness (sequential after D2)

- **parallel_with**: []
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/cli/extract_vn_claims.py]
- **estimated_wall_min**: 6

**Module**: `apps/cli/extract_vn_claims.py` (NEW; ~120 LOC click harness).

**Functionality**:
- `--input-sqlite <path>`: read NewsArticle rows; run FULL pipeline (extract + lexicon scoring); emit per-claim JSON
- `--input-html-dir <path>`: read .html files; parse via BeautifulSoup; build synthetic NewsArticle; run pipeline
- `--limit <N>`: cap articles processed (default 5)
- `--output <path>`: write JSON report `{article_id, claim_id, claim_text, sentiment, lexicon_score, mentioned_pump_anchors, mentioned_tickers}` per claim
- `--summary`: print to stdout: total articles processed + total claims extracted + lexicon_score distribution + mentioned_pump_anchors distribution + category distribution
- `--use-lexicon / --no-lexicon`: enable/disable lexicon injection (default enabled; disabled = simulates pre-E.2 backward-compat path)
- `--stub-transport`: use deterministic stub transport instead of claude CLI (for env without claude CLI; CI-friendly)

**Wire-up**:
```python
tokenizer = VnTokenizer()  # production pyvi
lexicon = VnSentimentLexicon(tokenizer=tokenizer) if use_lexicon else None
extractor = ClaudeLlmExtractor(
    tokenizer=tokenizer,
    lexicon=lexicon,
    transport=stub_transport if stub_transport_flag else make_claude_cli_news_transport(),
)
```

**CLI smoke at S368 close** (live verification — manual; recorded in session log):

```bash
python apps/cli/extract_vn_claims.py \
  --input-html-dir data/raw/news/vietstock/2026-05-16/ \
  --limit 3 \
  --output /tmp/extract-smoke.json \
  --summary \
  --use-lexicon \
  --stub-transport 2>&1 | tee /tmp/extract-smoke.log
```

Record in session log:
- Selected tokenizer + lexicon version + transport mode
- Total articles processed (expected: 2-3 for Vietstock 2026-05-16 dir if available)
- Total claims extracted + per-article distribution
- lexicon_score range (min/max/mean/median across claims)
- mentioned_pump_anchors count per claim (if anchors present in body)
- Verify deterministic across 2 runs with stub-transport (`diff /tmp/extract-smoke-1.json /tmp/extract-smoke-2.json` → empty)
- Category distribution sanity-check

**Acceptance**: CLI runs without exception; JSON output well-formed; smoke log captured; lexicon_score + mentioned_pump_anchors visible in output (or zero/empty if articles don't contain lexicon entries — still acceptable; validates pipeline shape not content)

---

## F. Definition of Done (DoD ≥25 items)

Aggregated across STEP 0 + D1-D5 + ADR + bookkeeping; verifier S369 confirms each empirically.

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/domain/news/models/extracted_claim.py` modified per D1 (2 NEW fields + __post_init__ extension)
- [ ] **DC-FILE-2** — `packages/infrastructure/news/claude_llm_extractor.py` modified per D2 (transport flip + DI fields + augment + import removal)
- [ ] **DC-FILE-3** — `packages/infrastructure/news/test_adapters.py` modified per D3 (6 new test cases)
- [ ] **DC-FILE-4** — `apps/cli/extract_vn_claims.py` exists (per D5)
- [ ] **DC-FILE-5** — `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` exists (per D4 ADR landing)
- [ ] **DC-FILE-6** — `agent-workspace/memory/sessions/2026-05-XX-session-368.md` exists (per CLAUDE.md § Session Protocol End)
- [ ] **DC-FILE-7** — `agent-workspace/memory/observations/sandwich-dev-S368-vn-claim-extraction-wrapper.md` exists (per Track 6)

### Implementation contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — ExtractedClaim has new fields `lexicon_score: float = 0.0` + `mentioned_pump_anchors: tuple[str, ...] = field(default_factory=tuple)` per DD-3
- [ ] **DC-IMPL-2** — ExtractedClaim.__post_init__ enforces lexicon_score in [-1.0, 1.0] per DD-3 + Rule 16 mode 2 bounds
- [ ] **DC-IMPL-3** — ClaudeLlmExtractor has new DI fields `tokenizer: TextTokenizerPort = WhitespaceTokenizer` + `lexicon: VnLexiconPort | None = None` per DD-1 + DD-5
- [ ] **DC-IMPL-4** — ClaudeLlmExtractor.transport field default = `field(default_factory=make_claude_cli_news_transport)` per DD-2
- [ ] **DC-IMPL-5** — `_default_transport` function REMOVED from claude_llm_extractor.py per DD-2 + D-050 closure
- [ ] **DC-IMPL-6** — `import anthropic` line REMOVED from claude_llm_extractor.py per DD-2 + L-S227-1
- [ ] **DC-IMPL-7** — `_build_effective_system_prompt` method exists + appends hint ONLY when tokenizer is VnTokenizer (NOT WhitespaceTokenizer fallback) per DD-5
- [ ] **DC-IMPL-8** — `_compute_lexicon_artifacts` method exists + returns (lexicon_score, mentioned_pump_anchors) tuple deterministically per DD-4
- [ ] **DC-IMPL-9** — mentioned_pump_anchors is sorted tuple (deterministic order) per DD-4 frozenset-intersection-with-sorted-result
- [ ] **DC-IMPL-10** — System prompt updated to instruct LLM NOT to emit lexicon_score / mentioned_pump_anchors per DD-4 + STEP 0.4

### STEP 0 compliance DC (DC-STEP0-N)

- [ ] **DC-STEP0-1** — Dev observation cites parent plan-028 § DD-5 + AQ-6 + § K.2 line numbers verbatim (per STEP 0.1)
- [ ] **DC-STEP0-2** — ExtractedClaim schema audit recorded (per STEP 0.2) — 2 new field shapes documented + backward-compat confirmed
- [ ] **DC-STEP0-3** — Anthropic→subagent migration plan recorded (per STEP 0.3) — claude CLI availability env-check result + transport-flip code-change plan + grep-baseline (1 import anthropic at L84 to be removed)
- [ ] **DC-STEP0-4** — Rule 16 mode-2 by-construction audit recorded (per STEP 0.4) — grep `import anthropic` returns ZERO in post-D2 claude_llm_extractor.py + lexicon_score + mentioned_pump_anchors docstrings cite Rule 16 mode 2
- [ ] **DC-STEP0-5** — Dogfood integration smoke + I-S34 + D-059 recorded (per STEP 0.5) — determinism PASS + I-S34 grep clean + ≥3 articles processed + ≥1 claim extracted via D5 CLI

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/infrastructure/news/ packages/domain/news/ apps/cli/extract_vn_claims.py` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/infrastructure/news/ packages/domain/news/ apps/cli/extract_vn_claims.py` exits 0
- [ ] **DC-GATE-3** — `python -m pytest packages/infrastructure/news/test_adapters.py -q` exits 0; 6 new test cases pass; existing tests still pass
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count = STEP 0 baseline (~1079 from S365) + ≥6; ZERO regression
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression; no new firing-test expected)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on new/modified files (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — Charter compliance grep — `grep -rE "^(from anthropic|import anthropic)" packages/infrastructure/news/` returns ZERO matches per Rule 16 + L-S227-1 + D-050 + plan-031 DD-2
- [ ] **DC-GATE-8** — `python -c "from packages.infrastructure.news import ClaudeLlmExtractor; ex = ClaudeLlmExtractor(transport=lambda s,b:'{}'); print(type(ex).__name__)"` exits 0 (default no-arg construction works)

### CLI smoke DC (DC-SMOKE-N)

- [ ] **DC-SMOKE-1** — Manual CLI smoke executed against `data/raw/news/vietstock/2026-05-16/` (or any available corpus) via `extract_vn_claims.py --stub-transport`; recorded in session log with N articles processed + N claims extracted + lexicon_score distribution sample
- [ ] **DC-SMOKE-2** — Smoke produced JSON output at `/tmp/extract-smoke.json` with well-formed per-claim rows including lexicon_score + mentioned_pump_anchors fields
- [ ] **DC-SMOKE-3** — Determinism smoke — `diff` of two consecutive smoke runs with `--stub-transport` returns empty (validates extractor pipeline is deterministic across runs per D-059 R2)

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-368.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase E sub-plan 031 row reflects E.3 Claim Extraction Wrapper SHIPPED at S368; next-action = S369 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S368-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/031-S367-phase-e3-claim-extraction-wrapper.md` → `completed/031-S367-phase-e3-claim-extraction-wrapper.md` at S369 close (NOT at S368 close — verifier acceptance gates the move per plan-020/022/026/027/029/030 precedent)
- [ ] **DC-BOOK-5** — ADR D-072 PROPOSED status reflected in `agent-workspace/memory/decisions/README.md` index

### Total DoD count: 33 items (≥25 floor satisfied; 7 file + 10 impl + 5 STEP 0 + 8 gates + 3 smoke + 5 bookkeeping = 38; some overlap so counted as 33 distinct items)

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why AUGMENT existing ClaudeLlmExtractor not parallel VnClaudeExtractor?

**Answer**: Per DD-1 + parent plan-028 DD-5 + AQ-5 + L-S345-3 single-helper-with-keyword-only-flag precedent. AUGMENT preserves backward-compat for existing 4 CLI + existing tests; per Karpathy P3 surgical-changes (one file + DI defaults vs duplicate class).

### AQ-2 — Why FLIP transport default to claude CLI in this sub-plan vs separate harness sub-plan?

**Answer**: Per DD-2 + parent plan-028 AQ-6 + D-050 § Deferred D-051 closure mandate. Refactoring extractor file twice (once for E.3 augment, once for transport flip) = unnecessary churn; bundling = single coherent commit; D-051 was explicitly deferred to "follow-up" per D-050 § Deferred; this sub-plan IS the follow-up. Per Karpathy P3 surgical-changes — touch only what task requires, but if a touch is happening anyway, complete the work.

### AQ-3 — Why DI graceful-degradation (default WhitespaceTokenizer + lexicon=None) vs require production injection?

**Answer**: Per DD-1 + Karpathy P3 surgical-changes + backward-compat preservation. Existing 4 CLI use `ClaudeLlmExtractor()` no-arg construction; requiring production injection would BREAK existing CLI. DI defaults preserve existing behavior modulo transport flip (which is documented at DD-2 + D-050 closure).

### AQ-4 — Why Rule 16 mode 2 (deterministic-pipeline echo) for lexicon_score not LLM-emitted numeric?

**Answer**: Per DD-4 + I-S1 (NO LLM math) + Rule 16 charter binding + parent plan-028 DD-5 step 4 explicit. LLM emits categorical sentiment per Rule 7 (unchanged); LLM does NOT emit numeric_score. Lexicon_score is post-LLM deterministic computation via `VnSentimentLexicon.score().numeric_score` (already proven deterministic per sub-plan 030 STEP 0.7 smoke). This is THE Rule 16 mode 2 pattern.

### AQ-5 — Why tokenizer DI as PROMPT HINT not data transformation?

**Answer**: Per DD-5 + Karpathy P2 simplicity + Rule 6 (verbatim quote discipline) preservation. Passing tokenized body as input data risks LLM emitting tokenized form in `source_text_excerpt` violating Rule 6 verbatim quote; safer = hint LLM about tokenization context, LLM still reads original body. Per L-S345-3 single-helper-with-keyword-only-flag precedent — opt-in via tokenizer type-check (only VnTokenizer triggers hint; WhitespaceTokenizer fallback = no hint = no behavior change).

### AQ-6 — What if STEP 0.3 surfaces claude CLI substrate unavailable in dev env?

**Answer**: Per STEP 0.3 STOP-AND-ASK trigger. Write STOP-FINDING-S368-claude-cli-substrate-unavailable.md with 3 options for user pick: (a) install claude CLI in dev env then resume, (b) defer transport-flip to separate sub-plan + ship augment-only, (c) retain anthropic SDK as default + escalate to CHARTER-TIER reversal of D-050 SYSTEMIC. Default (architect-judgement): if claude CLI unavailable, ship augment portion + flag D-051 closure as deferred-to-next-sub-plan (do NOT block all of E.3 on claude CLI; lexicon + tokenizer + new fields still valuable).

### AQ-7 — What if STEP 0.4 detects LLM-output drift volunteering lexicon_score or mentioned_pump_anchors?

**Answer**: Per STEP 0.4 STOP-AND-ASK trigger. Write STOP-FINDING-S368-rule-16-violation-llm-drift.md with options: (a) tighten system prompt + re-test (preferred per Karpathy P2 simplicity), (b) ignore drift via deterministic-only construction at _build_claim (defense-in-depth; default behavior already does this — drift would be silently ignored), (c) escalate to CHARTER-TIER for new I-S<N> on LLM-output-field-discipline. Default (architect-judgement): apply (a) tighten prompt; verifier S369 confirms via grep + integration smoke.

### AQ-8 — What if STEP 0.5 dogfood smoke fails (claude CLI subprocess error OR zero claims extracted)?

**Answer**: Per STEP 0.5 STOP-AND-ASK trigger (b). Write STOP-FINDING-S368-dogfood-extraction-failed.md with diagnostics; options: (a) retry with mock LLM + flag dogfood gap, (b) defer transport-flip to separate sub-plan, (c) defer all of D5 to follow-on session. Default (architect-judgement): apply (a) mock LLM acceptance + dogfood gap flag IF claude CLI subprocess fails; apply (b) IF system-prompt-violation surfaces and quick fix unclear.

### AQ-9 — Why NOT drop anthropic from pyproject.toml in this sub-plan (D-052 deferral)?

**Answer**: Per § A.3 deferral + D-050 § Deferred D-052 explicit. Scope-narrowing — THIS sub-plan accomplishes the SYSTEMIC rule satisfaction (zero `import anthropic` in news-extractor surface); dep-removal is hygiene (cleanup) with its own verification surface (whole-repo grep across packages/ + apps/; package-lock-file update; CI confirm-no-anthropic-imports). Separate D-052 cleanup ADR is cleaner per AP-7 anti-vacuous-defer + Karpathy P3.

### AQ-10 — What if S369 verifier finds existing tests break due to default transport change?

**Answer**: Per DD-2 mitigation. Existing tests at test_adapters.py:277-281 use `transport=lambda _system, _body: response` kwarg — explicit kwarg ALWAYS overrides default. Test signatures unchanged. If verifier finds breakage, root cause is likely test-fixture missing stub-transport OR test-fixture using `_default_transport` directly (forbidden import; would have been flagged at mypy/grep). Default mitigation per RM2: dev fixes inline; if breakage extensive, fallback to keeping `_default_transport` as deprecation pointer + flip default to factory anyway (back-compat preserves tests; rule-compliance for default-path achieved).

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (parent plan) | Source 2 (master-planner deepdive / D-050 ADR) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external pattern / memory rule) |
|---|---|---|---|---|---|---|
| 1 | DD-1 EXISTING-EXTRACTOR-AUGMENT (not parallel class) | parent plan-028 § DD-5 (lines ~297-309) + AQ-5 + § E.3 row (line ~384-396) | n/a (decision is DDD tactical pattern internal to stockforge) | Karpathy P3 surgical-changes + Charter "Cross-BC communication via contracts only" + DDD Adapter discipline | `packages/infrastructure/news/claude_llm_extractor.py:103` (existing ClaudeLlmExtractor dataclass) + L-S345-3 single-helper-with-keyword-only-flag precedent | `typing.Protocol` PEP 544 (DI surface) |
| 2 | DD-2 Transport default FLIPPED to make_claude_cli_news_transport | parent plan-028 § AQ-6 (lines ~478-480) + § DD-5 step 6 (line ~305) + RM6 (lines ~534-536) | `agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md` (ACCEPTED CHARTER 2026-05-09; § Deferred D-051 news-extractor refactor explicit) | Charter "user prompt overrides ALL defaults" + Charter Principle 8 calibration over confidence + D-050 SYSTEMIC binding | `packages/infrastructure/news/claude_cli_news_transport.py:158-173` (make_claude_cli_news_transport factory ALREADY SHIPPED per D-050 § Deferred D-051) + `packages/infrastructure/analysis/subagent_transport.py` (S43b precedent) | user memory rule `anthropic_api_to_subagent.md` (verbatim 2026-05-09 "no need anthropic api key, use claude code subagent (claude subscription) instead, for every 'anthropic api key'"; SYSTEMIC) |
| 3 | DD-3 ExtractedClaim NEW fields (lexicon_score + mentioned_pump_anchors) | parent plan-028 § DD-5 step 4 + 5 (lines ~303-304) — explicit `lexicon_score: float (Rule 16 mode 2)` + `mentioned_pump_anchors: tuple[str, ...]` field-add mandate | n/a | Charter Principle 4 (Proprietary data moat — VN cultural-anchor extraction IS the moat) + Rule 16 mode 2 deterministic-pipeline-echo authoritative spec + Rule 7 categorical sentiment (UNCHANGED) | `packages/domain/news/models/extracted_claim.py:40-83` (existing ExtractedClaim frozen+slots dataclass + Rule 6 invariants chain) | `apps/extraction/sentiment/vn_lexicon.py` SentimentScore.__post_init__ bounds-check pattern (mirrored for lexicon_score bounds enforcement) |
| 4 | DD-4 Rule 16 mode 2 satisfaction by-construction (deterministic-pipeline echo) | parent plan-028 § DD-5 step 4 (line ~303) explicit "the lexicon-score is a NUMERIC SIGNAL added as a NEW ExtractedClaim field `lexicon_score: float` (Rule 16 mode 2 deterministic-echo)" + § K.2 sub-plan 031 anticipated FLAG (b) + (c) | n/a (Rule 16 mode 2 is constitution-level not master-planner deepdive) | Charter financial-data-protocol.md Rule 16 § Enforcement schema-time + § Enforcement runtime tier (EchoValidator optional) + I-S1 NO LLM math + I-S20 calibration over confidence | `apps/extraction/sentiment/vn_lexicon.py` VnSentimentLexicon.score() pure-function path (deterministic per sub-plan 030 STEP 0.7 smoke) | Skill `.claude/skills/prompt-engineering/SKILL.md` § No-LLM-Math pattern explicit ("Numbers flow IN as facts; the LLM never produces a number absent from its input") |
| 5 | DD-5 Tokenizer DI as PROMPT HINT not body transformation | parent plan-028 § DD-5 step 2 (line ~301) — "Preprocessing step BEFORE LLM call: tokenize article body via injected tokenizer; pass token-list as additional system-prompt context" — architect-refinement: HINT vs INPUT-DATA distinction | n/a | Rule 6 (source_text_excerpt verbatim quote discipline ≤500 chars) + Karpathy P2 simplicity + I-S2 citation discipline | `packages/infrastructure/news/claude_llm_extractor.py:55-75` (existing _SYSTEM_PROMPT) + `packages/infrastructure/nlp/vn_tokenizer.py:96-148` (VnTokenizer adapter) + L-S345-3 single-helper-with-keyword-only-flag precedent | n/a (architect-judgement refinement of parent DD-5 step 2; documented adversarial alternates considered) |

---

## I. STEP 0 STOP-AND-ASK trigger inventory (4 documented; 2 CHARTER-TIER + 2 TACTICAL-TIER)

| Trigger ID | Sub-step | Condition | STOP-FINDING file path | User decision class |
|---|---|---|---|---|
| **(a) CHARTER-TIER GATE — claude CLI substrate unavailable** | 0.3 | `which claude` returns nothing OR `claude --version` fails in S368 dev env | `human-workspace/notifications/STOP-FINDING-S368-claude-cli-substrate-unavailable.md` | CHARTER-TIER (install / defer transport-flip / reverse D-050 SYSTEMIC) |
| **(b) CHARTER-TIER GATE — Rule 16 mode-2 violation (LLM volunteers lexicon_score or mentioned_pump_anchors)** | 0.4 | Post-D2 integration smoke detects LLM-output JSON contains lexicon_score or mentioned_pump_anchors field | `human-workspace/notifications/STOP-FINDING-S368-rule-16-violation-llm-drift.md` | CHARTER-TIER (tighten prompt / ignore via deterministic-only construction / new I-S<N>) |
| **(c) TACTICAL-TIER — extractor pipeline non-determinism** | 0.5 | Extractor output differs across 2 calls with same input + stub transport | `human-workspace/notifications/STOP-FINDING-S368-extractor-non-deterministic.md` | TACTICAL-TIER (lock random state / defer transport-flip / escalate) |
| **(d) TACTICAL-TIER — dogfood extraction failure** | 0.5 | Claude CLI subprocess fails OR extractor returns 0 claims for all 3 articles OR system-prompt-violation surfaces (LLM emits prose instead of JSON) | `human-workspace/notifications/STOP-FINDING-S368-dogfood-extraction-failed.md` | TACTICAL-TIER (mock LLM + flag dogfood gap / defer transport-flip / defer D5) |

**Dispatch brief specified 2 triggers (a) anthropic SDK retention rejection AND existing extractor entanglement (b)**. **Architect splits/refines to 4 triggers**: trigger (a) becomes CHARTER-TIER claude CLI substrate unavailable (the inverse case — claude CLI not available means anthropic SDK might be temporarily retained); architect adds (b) Rule 16 mode-2 violation per parent § K.2 anticipated FLAG; architect adds (c) + (d) per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding (surface all failure modes upfront, not after they fire).

---

## J. Risks & Mitigation (RM1-RM8)

### RM1 — Cold-start budget over/under-estimation (LIKELY-LOW; n=2 precedent narrows variance)

**Risk**: Phase 1b at n=2 (S362+S365 precedent) provides directional but not precise budget bounds; S368 dev may finish under 90K Opus OR exceed 130K (e.g. STEP 0 STOP-AND-ASK adds 10-30K depending on which triggers fire).

**Mitigation**: Full 100-150K Opus envelope honored per recalibrated CLAUDE.md table; sub-plan 032 inherits growing precedent (n=2 → n=3 → n=4 → ...). Worst case: STOP-AND-ASK budget consumed → re-dispatch S368 dev after user gate clears.

### RM2 — Claude CLI substrate unavailable in dev env (LIKELY-LOW; LIKELY-MEDIUM in CI)

**Risk**: STEP 0.3 may find claude CLI not installed OR not on PATH in S368 dev env; transport flip would fail to smoke-test; CI environments (if any) typically don't have claude CLI installed.

**Mitigation**: Per AQ-6 + STEP 0.3 STOP-AND-ASK trigger (a). Test substrate already covered via stub-transport pattern at test_adapters.py:278-281 (existing pattern; tests don't need live claude CLI); production live path is gated by STEP 0.5 dogfood smoke (degrades to mock LLM if claude CLI unavailable). Worst case: transport flip ships at code-level (default-factory points to make_claude_cli_news_transport); live verification deferred via flag.

### RM3 — LLM-output drift surfaces volunteer lexicon_score or mentioned_pump_anchors (LIKELY-VERY-LOW)

**Risk**: Despite system-prompt update at DD-4 + STEP 0.4 explicit instruction "DO NOT include these in your JSON output", LLM may volunteer these fields (rare but possible per prior LLM behavior observations).

**Mitigation**: Per DD-4 defense-in-depth — even IF LLM volunteers these fields, `_build_claim` only reads documented field names from raw dict; LLM-volunteered lexicon_score / mentioned_pump_anchors fields are silently ignored at parse time; deterministic post-LLM computation overrides. Per STEP 0.4 STOP-AND-ASK trigger (b) — if drift detected via D5 smoke JSON inspection, dev tightens prompt + re-tests; CHARTER-TIER escalation only if drift persists after prompt-tightening.

### RM4 — ExtractedClaim backward-compat break (LIKELY-VERY-LOW)

**Risk**: Existing tests at test_adapters.py:284-348 construct ExtractedClaim implicitly via extractor.extract(); new fields are passed at D2 _build_claim call; default field values preserve construction validity. Risk = field-ordering or __post_init__ change accidentally rejects existing test fixtures.

**Mitigation**: Per DD-3 — field defaults preserve backward-compat by construction (dataclass field defaults work even if older code doesn't pass new fields); __post_init__ extension only adds NEW validation for lexicon_score bounds (doesn't change existing validation); existing tests should pass unchanged. Verifier S369 explicitly confirms via DC-GATE-4 (pytest exit 0 with new + existing tests).

### RM5 — Anthropic SDK still importable via pyproject.toml dep (LIKELY-EXPECTED; LIKELY-LOW concern)

**Risk**: D-052 deferred per § A.3 + D-050 § Deferred — `anthropic` package remains in pyproject.toml deps even after this sub-plan; user may consider this incomplete D-050 compliance.

**Mitigation**: Per AQ-9 — scope-narrowing rationale; D-052 cleanup ADR scope explicitly separate; this sub-plan satisfies the SYSTEMIC rule for IMPORT path (zero `import anthropic` in news-extractor); dep removal is hygiene with its own verification surface. Verifier S369 acknowledges D-052 still deferred; not a defect of this sub-plan.

### RM6 — Test stub patterns may need refresh for new DI fields (LIKELY-LOW)

**Risk**: New DI fields (tokenizer + lexicon) on ClaudeLlmExtractor mean some test cases may need explicit lexicon=None / tokenizer=WhitespaceTokenizer specifications to lock test behavior; if not, default factory call (make_claude_cli_news_transport in default test runs) may invoke claude CLI subprocess.

**Mitigation**: Per D3 test extensions test 4 — meta-test confirms no-arg `ClaudeLlmExtractor()` falls back gracefully; new tests explicitly inject tokenizer + lexicon as needed; existing tests at test_adapters.py:277-281 pass transport kwarg explicitly (no behavior change). Default factory in test context = make_claude_cli_news_transport which only fails if claude CLI subprocess fails — tests don't invoke .extract() without stub-transport.

### RM7 — Lexicon coverage on production extraction unknown (LIKELY-MEDIUM; sub-plan 030 carry-forward)

**Risk**: Sub-plan 030 ships UNCALIBRATED-V0 (HYPOTHESIS weights); production extraction may have most articles classified as lexicon_score = 0.0 (no matching keywords); ADR D-071 revisit trigger 1 monitors but won't trigger from THIS sub-plan's IMPL surface.

**Mitigation**: Per ADR D-072 § Revisit trigger 3 explicit — "Lexicon coverage <50% on production extraction → triggers sub-plan 030-V2 calibration cycle per ADR D-071 revisit trigger 1". D5 CLI smoke records lexicon_score distribution; if all-zero, dev observation flags as "lexicon-coverage-zero" alert for next session.

### RM8 — System prompt token bloat (LIKELY-VERY-LOW)

**Risk**: System prompt update adds ~5-10 tokens per call (note about lexicon_score / mentioned_pump_anchors NOT being LLM-emitted); tokenizer hint adds ~30 tokens IF VnTokenizer injected (production wire-up); minor cost increase per call.

**Mitigation**: Negligible at v0 throughput (~$0.0001 per call extra; sub-cent per article). Prompt caching deferred per § A.3; if caching matters at Phase 3 production, cached system prompt absorbs token cost.

---

## K. Coordination paths off-limits (during S368 dev session window)

When main session dispatches S368 dev sub-plan IMPL, main session SHOULD avoid (read-only or no-touch) the following paths to prevent file-collision:

- `packages/domain/news/models/extracted_claim.py` (D1 dev modifies)
- `packages/infrastructure/news/claude_llm_extractor.py` (D2 dev modifies)
- `packages/infrastructure/news/test_adapters.py` (D3 dev modifies)
- `apps/cli/extract_vn_claims.py` (D5 dev writes)
- `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (D4 ADR writes)
- `agent-workspace/memory/sessions/2026-05-XX-session-368.md` (dev session log)
- `agent-workspace/memory/observations/sandwich-dev-S368-vn-claim-extraction-wrapper.md` (dev observation)
- `human-workspace/notifications/STOP-FINDING-S368-*.md` (CONDITIONAL dev writes IF STOP-AND-ASK fires)

When main session dispatches S369 verifier (AP-1 fresh-context post-S368 dev close), main session SHOULD avoid:

- `agent-workspace/memory/observations/sandwich-verifier-S369-vn-claim-extraction-wrapper-verify.md` (verifier writes)

Coordination paths NOT touched by THIS sub-plan (READ-ONLY guarantee):
- `packages/infrastructure/news/claude_cli_news_transport.py` (already-shipped per DD-7; verifier reads READ-ONLY)
- `packages/application/nlp/ports/text_tokenizer_port.py` (sub-plan 029 D1; READ-ONLY)
- `packages/application/nlp/ports/vn_lexicon_port.py` (sub-plan 030 D1; READ-ONLY)
- `packages/infrastructure/nlp/vn_tokenizer.py` (sub-plan 029 D2; READ-ONLY)
- `apps/extraction/sentiment/vn_lexicon.py` (sub-plan 030 D2; READ-ONLY)
- `apps/extraction/sentiment/__init__.py` (sub-plan 030 namespace marker; READ-ONLY)
- `pyproject.toml` (NO dep changes per RM5 + AQ-9; D-052 separate scope)
- `apps/cli/ingest_news_*.py` (4 CLIs; READ-ONLY per DD-1 backward-compat)
- `packages/domain/news/services/claim_extraction_service.py` (READ-ONLY; consumer of new ExtractedClaim shape)
- `packages/application/news/ports/llm_extractor_port.py` (READ-ONLY; port signature unchanged)

---

## L. Conditional next-step (post-user-ratification of CHARTER-TIER GATE IF applicable)

### L.1 IF STEP 0.3 + STEP 0.4 + STEP 0.5 CHARTER-TIER GATES did NOT fire (most likely path)

- S368 dev proceeds STEP 0 → D1 → D2 → D3 + D4 (parallel) → D5 → close
- S369 verifier AP-1 dispatch
- S369 close: plan-031 mv `pending/` → `completed/`
- S369+ main session dispatches sub-plan 032 architect (E.4 ticker resolver) per parent master plan § E sequencing
- POSSIBLE PARALLEL: sub-plan 032 architect dispatch already in flight per master plan § E.3+E.4 parallel_with declaration; if 032 was dispatched parallel with 031 at S367, both could ship at S369

### L.2 IF STEP 0.3 CHARTER-TIER GATE FIRED (claude CLI substrate unavailable)

- S368 dev pauses at STEP 0.3 STOP-AND-ASK
- Main session dispatches AskUserQuestion gate → user picks (a) install / (b) defer transport-flip / (c) reverse D-050
- IF (a): dev resumes STEP 0 → D1-D5 standard path
- IF (b): dev skips transport-flip (D2 partial); ships augment + new fields + tests only; D-051 closure deferred to separate sub-plan
- IF (c): MAJOR architectural rollback; dev pauses entire sub-plan + separate ADR drafted to supersede D-050 partially; sub-plan 031 may be entirely re-scoped

### L.3 IF STEP 0.4 CHARTER-TIER GATE FIRED (Rule 16 mode-2 LLM drift)

- S368 dev pauses at STEP 0.4 STOP-AND-ASK
- Main session dispatches AskUserQuestion gate → user picks (a) tighten prompt / (b) ignore drift / (c) new I-S<N>
- IF (a): dev tightens prompt + retests; STEP 0.4 acceptance re-verified; proceeds D1-D5
- IF (b): dev proceeds D1-D5 with deterministic-only construction (default behavior already does this); STEP 0.4 acceptance recorded as "drift-ignored-per-user-pick"; D-072 ADR § Risks adds RM3-bis
- IF (c): new I-S<N> drafted + ratified via separate user-ratified PLAN+IMPL pair; sub-plan 031 IMPL may proceed with deterministic-only construction in interim

### L.4 IF STEP 0.5 TACTICAL-TIER (c) or (d) FIRED (non-determinism OR dogfood failure)

- Dev applies architect-recommended default per AQ-8 (mock LLM + flag dogfood gap OR defer transport-flip OR defer D5)
- Records outcome in dev observation file + STOP-FINDING file
- E.3 augment portion (D1 + D2 partial + D3 + D4) STILL ships; D5 partial-or-deferred
- S369 verifier confirms acceptance per modified DoD (verifier reads STOP-FINDING + adjusts acceptance criteria accordingly)

---

## M. CHARTER-TIER GATE clause (canonical reference for sub-plan 031 anticipated flags)

> **MANDATORY STEP 0 STOP-AND-ASK on Claude CLI Substrate Availability** (per dispatch brief flag (a) + AQ-6 + STEP 0.3 trigger): If `which claude` returns nothing OR `claude --version` fails in S368 dev env, S368 dev MUST:
> 1. STOP at STEP 0.3 conclusion (D2 IMPL block on transport-flip portion)
> 2. Write `human-workspace/notifications/STOP-FINDING-S368-claude-cli-substrate-unavailable.md`
> 3. Continue with augment-only path (D1 + D2 sans transport-flip + D3 + D4) AS-IF Phase A separate; flag D-051 closure as deferred
> 4. OR pause entire sub-plan pending user gate ratification (architect-judgement: prefer (3) ship augment partial; D-051 closure cycle restartable)
> 5. Record user pick (if received) in ADR D-072 § Authorization field
> 6. Proceed per § L.2 depending on user pick

> **MANDATORY STEP 0 STOP-AND-ASK on Rule 16 mode-2 LLM-Output Drift** (per dispatch brief flag (b) + parent plan-028 § K.2 sub-plan 031 anticipated FLAG (b) + STEP 0.4 trigger): If post-D2 dogfood smoke surfaces LLM volunteering lexicon_score or mentioned_pump_anchors in JSON output (Rule 16 mode-2 violation surface), S368 dev MUST:
> 1. STOP at STEP 0.4 conclusion (D2 IMPL block pending fix)
> 2. Write `human-workspace/notifications/STOP-FINDING-S368-rule-16-violation-llm-drift.md` documenting (1) which field, (2) which article triggered, (3) frequency
> 3. DEFAULT: apply (a) tighten system prompt + re-test; if successful, proceed D1-D5; if persistent, escalate to user gate
> 4. If gate fires: main session dispatches AskUserQuestion → proceed per § L.3 user pick

> **MANDATORY STEP 0 STOP-AND-ASK on Corpus-Labelling Source CARRY-FORWARD** (sub-plan 030 STOP-FINDING-S365-corpus-labelling-source.md): NON-BLOCKING for E.3 per parent AQ-8 + dispatch brief constraint — UNCALIBRATED-V0 lexicon is usable for hint emission; calibration cycle is data-only update post-user-pick at sub-plan 030-V2 (NOT sub-plan 031 work). NO additional STOP-AND-ASK in sub-plan 031 for this flag.

> DO NOT silently retain anthropic SDK as default per D-050 SYSTEMIC. DO NOT silently violate Rule 16 mode 2 for new fields. DO NOT block IMPL on corpus-labelling source pick (sub-plan 030 flag is NON-BLOCKING for E.3 per AQ-8).

---

## N. Compliance attestation (architect S367 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; L-S354-2 + L-S366-4 planner-stats infrastructure gap noted in Phase 1b § A.4 carry-forward; explicitly NOT fixed here per § hard_rules)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- [x] AP-5 ✓ (re-read all binding sources at session entry per VBW protocol — 35 files cited in § A.4 — covering parent plan-028 + sub-plans 029/030 + ADR D-050 + memory rule + existing extractor + existing transport substrate + ExtractedClaim + lexicon + tokenizer + skill prompt-engineering + architect template)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; 13 OOS items each with revisit trigger)
- [x] AP-23 ✓ (no refinement-of-rule iterations this session; any new patterns surfaced get first-instance HOLD per binding_decisions; e.g. tokenizer-prompt-hint pattern at DD-5 is NEW; if 2nd instance arises in sub-plan 032+, promote calculus triggers)
- [x] autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- [x] dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session dispatches S368 dev per parent plan-028 § L sequencing — no self-pause)
- [x] stop_offering_routing_branches ✓ (§ L next-step is structural sequencing not user-action menu)
- [x] D-060 ✓ (architect has no Bash tool; main session commits this sub-plan + observation per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- [x] D-066 not touched (Phase D Theme L closed; Theme I CONSUMES adapter output without modification)
- [x] D-070 honored (sub-plan 029 pyvi VnTokenizer consumed via DI; not modified)
- [x] D-071 honored (sub-plan 030 VnSentimentLexicon + VN_CULTURAL_ANCHORS consumed via DI; not modified; UNCALIBRATED-V0 acceptable per AQ-8 NON-BLOCKING)
- [x] D-050 honored + ADVANCED — THIS plan CLOSES D-051 deferral per parent AQ-6 + RM6 + plan-008 G.1; DD-2 + DD-6 explicit; D-052 still deferred per RM5 + AQ-9 (scope-narrowing)
- [x] memory rule `anthropic_api_to_subagent` honored — IMPLEMENTED for news-extractor path per DD-2; ZERO new `import anthropic` introduced; default transport flipped per SYSTEMIC mandate
- [x] 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- [x] 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- [x] 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is dev-S368 conditional write not architect-S367 write)
- [x] 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- [x] I-S1 ✓ (this plan PROMOTES I-S1 satisfaction — lexicon_score + mentioned_pump_anchors are LLM-FREE by construction per DD-4)
- [x] I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- [x] I-S20 ✓ (calibration over confidence — lexicon_score traceable to VnSentimentLexicon UNCALIBRATED-V0 + revisit trigger via ADR D-071 trigger 2)
- [x] I-S34 ✓ (STEP 0.5 enforces HARD REJECT carry-forward; no new HTTP fetcher this sub-plan; claude CLI is local subprocess)
- [x] I-S35 ✓ (lexicon_score = signal NOT recommendation; mentioned_pump_anchors = audit-trail flag NOT recommendation; categorical sentiment unchanged per Rule 7)
- [x] Rule 7 ✓ (Sentiment 5-class StrEnum unchanged; LLM still emits categorical per existing contract)
- [x] Rule 16 mode 2 ✓ (lexicon_score + mentioned_pump_anchors are deterministic-pipeline echo by construction; STEP 0.4 + DC-GATE-7 enforce)
- [x] Rule 6 ✓ (source_text_excerpt verbatim quote discipline unchanged; tokenizer hint at DD-5 explicit-instructs LLM to preserve original spacing)
- [x] Principle 4 ✓ (VN-cultural-anchor extraction realized via mentioned_pump_anchors = proprietary moat surface)
- [x] Principle 7 ✓ (Dogfood mandated in D5 CLI smoke on real corpus + STEP 0.5)
- [x] Principle 8 ✓ (lexicon_score traceable to UNCALIBRATED-V0 + revisit trigger; no hand-tuning past v0)
- [x] Principle 9 ✓ (NO LLM math — DD-4 + STEP 0.4 enforce; ADR D-072 explicit)
- [x] Phase 1b CONSUMED + n=2 vietnamese-nlp-impl precedent per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; cold-start window narrow but growing)
- [x] 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- [x] CHARTER-TIER GATE clause documented per § M (canonical reference for S368 dev — 2 CHARTER-TIER triggers: (a) claude CLI substrate + (b) Rule 16 mode-2 LLM drift + corpus-labelling carry-forward NON-BLOCKING per AQ-8)
- [x] D1-D5 sub-tracks declare 3 mandatory fields (parallel_with / blocks_on / coordination_paths_exclusive / estimated_wall_min) per plan-025 contract
- [x] Recalibrated PLAN budget per CLAUDE.md table (150-230K Opus PLAN) — this dispatch validates 3rd opportunity per M-S360-2 ratification
- [x] anthropic_api_to_subagent rule MANDATORY per user memory + D-050 ADR (S227) — IMPLEMENTED for news-extractor path per DD-2 + DD-6 + ADR D-072 § Decision

---

**END OF SUB-PLAN 031-S367-PHASE-E3-CLAIM-EXTRACTION-WRAPPER**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S368 sandwich-dev FOCUSED_IMPL per parent plan-028 § L sequencing post-ratification of THIS sub-plan.
