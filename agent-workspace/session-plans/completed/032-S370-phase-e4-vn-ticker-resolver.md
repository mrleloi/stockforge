---
plan_id: 032-S370-phase-e4-vn-ticker-resolver
target_session: S371 (dev IMPL session; THIS plan = S370 architect output)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S370; IMPL by sandwich-dev at S371; VERIFY by sandwich-verifier AP-1 at S372)
budget:
  - this PLAN session (S370 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (M-S360-2 empirical ratification carry-forward; sub-plans 030 + 031 architect runs validated upper-band Opus PLAN envelope at 2nd + 3rd opportunity; 4th opportunity here — note 3rd over-budget pattern emerging at +10% deferred to next sweep per dispatch brief)
  - sub-plan IMPL (S371 dev): ~100-150K Opus FOCUSED_IMPL per recalibrated table (n=3 vietnamese-nlp-impl precedent from S362 + S365 + S368; cold-start window now CLOSED at n≥3; sub-plan 032 IMPL projected to fit lower-band Opus envelope because fresh-module + alias-table scaffolding is structurally SIMPLER than transport-flip + AUGMENT-augment of sub-plan 031)
  - sub-plan VERIFY (S372 verifier): ~30-60K Opus AP-1 fresh-context
phase: E (Theme I — Vietnamese NLP entry; sub-theme E.4 VN Ticker Resolver — FOURTH AND FINAL of 4 sub-themes per plan-028 § E sequencing; Phase E DONE at this sub-plan close)
track: Wave 1 Theme I sub-theme E.4 — VN ticker resolver (FRESH MODULE + ALIAS TABLE) per parent plan-028 DD-6; fresh module `apps/_shared/entities/vn_ticker_resolver.py` + alias table `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` + stdlib difflib fuzzy-match (NO new external dep per parent DD-6); REFACTORS `ClaudeLlmExtractor._build_claim` ticker filter at claude_llm_extractor.py:238-241 (2-4 char uppercase filter → resolver-backed resolution per E.3 carry-forward dispatch brief item 5 + parent DD-6 step 4)
parent_plan: agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md (PHASE-MASTER-PLAN authored S360; THIS is the fourth + FINAL sub-plan per § E.4 + § L sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.4 + § 6.4.2
predecessor: 031-S367-phase-e3-claim-extraction-wrapper (sub-plan 031; SHIPPED S368 dev + VERIFIED S369 PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES; ADR D-072 PROPOSED; 1085/1085 tests; 0 mistakes; transport flip news-side SHIPPED + grep-verified; D-052 analysis-side cleanup DEFERRED to harness sweep per F3 finding; sub-plan 031 mv pending→completed authorized at S369)
successor: S371 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S372 sandwich-verifier AP-1 → **Phase E DONE attestation** per § N → Phase F-prime Theme H (BC-8 multi-perspective primitives) master-plan dispatch per § N + parent plan-028 § M.1 critical-path analysis
architect: S370 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase E FOURTH + FINAL sub-plan author per plan-028 § L sequencing + S369 verifier close + recalibrated PLAN budget table validation (4th opportunity per dispatch brief; cold-start window CLOSED at n=3 task_class=vietnamese-nlp-impl per L-S354-2 carry-forward)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED with n=3 vietnamese-nlp-impl precedent from S362 + S365 + S368 — task_class window now n=3 NO LONGER cold-start per agent-template L65 threshold; .planner-stats.tsv STILL header-only at S370 entry per L-S354-2 + L-S366-4 carry-forward but manual reading via current-execution.md + mistake-log + observations substitute provides n=3 empirical base)
executing_agent: N/A this PLAN session; S371 sandwich-dev FOCUSED_IMPL (after this sub-plan ratified) + S372 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310; do NOT include sync-grilling in S371 close ritual)"

depends_on:
  - "Parent master plan-028 § E.4 sub-plan contract (DD-6 FRESH-MODULE + ALIAS-TABLE strategy; coordination_paths_exclusive scoped to apps/_shared/entities/** + agent-workspace/ubiquitous-language/vn_ticker_aliases.md + apps/cli/resolve_vn_tickers.py + 1 surgical edit to packages/infrastructure/news/claude_llm_extractor.py for _build_claim filter refactor per parent DD-6 step 4 + § AQ-9 + dispatch brief item 5/7)"
  - "Sub-plan 029 SHIPPED + VERIFIED — pyvi==0.1.1 VnTokenizer + WhitespaceTokenizer + TextTokenizerPort Protocol — THIS sub-plan does NOT depend directly on tokenizer (resolver works on raw text); BUT recommended fixture: use VnTokenizer output to verify multi-syllable VN company-name (e.g. 'Công ty Cổ phần Vinhomes') resolution; OPTIONAL DI"
  - "Sub-plan 030 SHIPPED + VERIFY PENDING non-blocking (per dispatch brief constraint) — VnSentimentLexicon + VN_CULTURAL_ANCHORS + SentimentScore + VnLexiconPort — THIS sub-plan does NOT depend on lexicon; resolver is independent NLP capability per parent plan-028 § E sequencing (032 blocks_on=[029] only, NOT [030])"
  - "Sub-plan 031 SHIPPED + VERIFIED S369 PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES — ClaudeLlmExtractor AUGMENT + lexicon_score + mentioned_pump_anchors + transport flip (news-side) shipped at commit b6b3877; ExtractedClaim NEW fields available; ADR D-072 PROPOSED; THIS sub-plan EXTENDS the _build_claim path with resolver call (surgical edit per § STEP 0.3 + DD-5)"
  - "ADR D-070 PROPOSED (pyvi tokenizer selection; MIT license) + ADR D-071 PROPOSED (VN sentiment lexicon UNCALIBRATED-V0) + ADR D-072 PROPOSED (VN claim extraction wrapper AUGMENT) — all available as substrate; NONE blocking; ADR D-073 next slot for THIS sub-plan"
  - "Existing `packages/contracts/types/ticker.py` Ticker value object (full read 63 LOC; frozen+slots dataclass; symbol field; _TICKER_PATTERN `^[A-Z0-9]{3}$` enforces 3-character canonical form; InvalidTickerError on shape violation; uppercase normalization in __post_init__) — THIS sub-plan PRESERVES existing Ticker schema; resolver OUTPUTS Ticker instances; does NOT modify Ticker class"
  - "Existing `agent-workspace/ubiquitous-language/glossary.md` § Ticker entry (line 14-16) confirms canonical 3-character HOSE/HNX/UPCoM symbol convention; § VN30 entry (line 152-156) confirms Phase 1 thin-slice anchored on VN30 universe per Charter § First Sub-Scope — THIS sub-plan SEEDS alias table with VN30 universe initial set + extension path per parent AQ-9"
  - "Existing `packages/infrastructure/news/claude_llm_extractor.py:238-241` 2-4 char uppercase ticker filter (per S368 b6b3877 commit; unchanged from pre-E.3 baseline at this site) — THIS sub-plan REFACTORS this filter to call resolver per parent DD-6 step 4 + AQ-9 + dispatch brief item 5; verifier S369 risk-area 5 explicitly carries this scope to E.4"
  - "D-066 + REV-1/2/3 (CrawlerAdapter ABC contract; 4 VN adapters SHIPPED) — THIS sub-plan does NOT modify adapters; resolver is downstream NLP capability"
  - "D-061 § Decision item 4 (HARD REJECT Scrapling/patchright/playwright_stealth/fake-useragent/StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher; resolver is text-in/Ticker-out pure-function module); carries forward verifier grep-asserts"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain) — BINDING for every NEW file authored under this sub-plan; resolver is pure-function so deterministic-by-construction posture expected; STEP 0.7 grep-asserts; alias-table file has version metadata WITHOUT datetime.now() (use UTC string literal at write time)"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S371 dev commit boundary"
  - "D-062 (atomic-write-doctrine via tmp+os.replace) — N/A for resolver (no file writes in resolver path); BINDING for alias-table seeding if dev script generates/updates ubiquitous-language file (recommended path: hand-curate at IMPL time as static markdown; no runtime write)"
  - "D-064 (path-safety 5-invariant) — N/A this sub-plan (no new file-path code)"
  - "D-065 Rule 16 (numeric-field discipline) — THIS sub-plan EMITS resolution_confidence: float in [0.0, 1.0]; Rule 16 satisfaction MODE 2 (deterministic-pipeline echo) — confidence is computed by deterministic difflib.SequenceMatcher.ratio() arithmetic; LLM never invoked in resolution path; CRITICAL CHARTER-TIER COMPLIANCE — see § D DD-4 (Rule 16 mode-2 by construction) + § STEP 0.4 audit"
  - "D-069 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 4 (Proprietary data moat — VN ticker alias table + cultural-context resolution IS the moat per master plan § 5.4 + A-14 § 7.7 anti-pattern explicit veto against duplicated-English-only-lookups) + Principle 7 (Dogfood — S371 dev MUST resolve ≥5 real-text snippets containing VN30 ticker mentions in STEP 0 + D5 CLI smoke; cannot ship without dogfood) + Principle 8 (Calibration over confidence — difflib threshold + alias coverage traceable to empirical test fixtures NOT intuition; revisit trigger when n>100 tickers per AQ-9) + Principle 9 (NO LLM math — resolution is rule-based deterministic; Rule 16 mode 2 by construction; ZERO LLM invocation in resolver path) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — resolver is pure-function deterministic; LLM never invoked in resolution path; satisfied by construction"
  - "I-S2 (citation discipline) — alias table entries trace to (a) HOSE listing entry source (URL + as-of) OR (b) project-owner manual curation OR (c) UL glossary entry; alias-table markdown records source + as_of per entry block per UL glossary entry format precedent"
  - "I-S20 (calibration over confidence) — resolver test fixtures = empirical VN30 universe samples + ≥3 ambiguity edge cases (e.g. VIN-class); confidence floor recommendation traceable to test fixture pass rate not intuition"
  - "I-S22 (data lineage) — Resolution result records (a) resolution_method enum {EXACT, CASE_INSENSITIVE, DIACRITICS_STRIPPED, FUZZY, AMBIGUOUS, UNKNOWN} + (b) resolution_confidence float + (c) matched_alias original-form preserved + (d) alias_table_version string for audit trail"
  - "I-S34 (robots.txt + reasonable rate limits + HARD REJECT of patchright/playwright_stealth/fake-useragent/StealthyFetcher) — N/A this sub-plan (no new HTTP fetcher); CARRIES FORWARD verifier grep-asserts"
  - "I-S35 (research-aid framing) — resolver = transform utility; no recommendation surface; satisfied by construction"
  - "anthropic_api_to_subagent memory rule — N/A this sub-plan (resolver does NOT invoke LLM); CARRIES FORWARD; sub-plan 031 closed news-side at S368; D-052 analysis-side still DEFERRED per S369 verifier F3"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter discipline; Value Object discipline — Ticker preserved per existing schema; resolver = utility class NOT entity NOT aggregate per DD-1; mirror sub-plans 029 + 030 port/adapter pattern where applicable but DD-1 selects simpler class-not-Protocol per Karpathy P2)"
  - "skill .claude/skills/prompt-engineering/SKILL.md (No-LLM-Math pattern — confirms Rule 16 mode 2 IS the correct pattern when numeric output is required; resolution_confidence satisfies via deterministic SequenceMatcher.ratio())"

binding_decisions:
  - "PHASE 1b CONSUMED with n=3 vietnamese-nlp-impl precedent — task_class='vietnamese-nlp-impl' has n=3 samples from S362 (~159K Sonnet, ~39min, 1053/1053 tests, 0 mistakes per current-execution.md S362 row) + S365 (~150K Sonnet, ~39min, 1079/1079 tests, 0 mistakes per current-execution.md S365 row) + S368 (~Opus, AP-1 fresh-context, 1085/1085 tests, 0 mistakes per current-execution.md S368 row); variance window NARROW but n=3 reaches agent-template L65 threshold — cold-start window NOW CLOSED at task_class level; sub-plan 032 IMPL projected to fit LOWER-BAND envelope (90-130K Opus) because fresh-module + alias-table scaffolding is structurally SIMPLER than transport-flip + AUGMENT-augment of sub-plan 031"
  - "DD-1 FRESH-MODULE + ALIAS-TABLE STRATEGY per parent plan-028 DD-6 — NEW module `apps/_shared/entities/vn_ticker_resolver.py` (NOT modification of existing Ticker value object); NEW alias-table markdown at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (markdown source-of-truth; loaded at runtime via simple parser; NO runtime mutation per D-062 doctrine + Karpathy P2 simplicity)"
  - "DD-2 RESOLVER SHAPE = CONCRETE CLASS NOT PROTOCOL — per Karpathy P2 simplicity + plan-029 DD-1 precedent of TokenizerProtocol REJECTED for tokenizer (per L-S360-3 review) … actually plan-029 DD-1 SELECTED Protocol per mirror of LlmExtractorPort; reverse argument: resolver has ZERO swap requirement (no alternate library OR algorithm planned per AQ-9 difflib-only-v0); SINGLE concrete class `VnTickerResolver` with `resolve(mention: str) -> ResolutionResult` method; future Protocol-ification = AP-23 first-instance HOLD if second resolution backend (e.g. spaCy NER OR transformer) surfaces empirically per AQ-9 trigger n>200 tickers"
  - "DD-3 ALIAS TABLE STORAGE FORMAT = HAND-CURATED MARKDOWN at agent-workspace/ubiquitous-language/vn_ticker_aliases.md (NOT Python dict literal in source like sub-plan 030 lexicon) — RATIONALE: alias table is ubiquitous-language artifact (per UL glossary entry pattern) + project-owner curatable without Python knowledge + version-tracked via git + parseable via simple markdown reader; SUB-RATIONALE FOR DIVERGENCE FROM SUB-PLAN 030 DD-5: lexicon is keyword-WEIGHT scoring data (close to algorithm) → Python literal; alias-table is entity-mapping reference data (curated by domain experts) → markdown per UL pattern"
  - "DD-4 RESOLUTION_CONFIDENCE = difflib.SequenceMatcher.ratio() FLOAT IN [0.0, 1.0] per Rule 16 MODE 2 deterministic-pipeline echo — pure-function; deterministic across Python releases (per Python stdlib stability guarantee); ResolutionResult dataclass carries .resolution_confidence + .resolution_method enum + .matched_alias for I-S22 lineage"
  - "DD-5 _build_claim INTEGRATION = SURGICAL EDIT at claude_llm_extractor.py:238-241 — REPLACES current `t.isupper() and 2 <= len(t) <= 4` filter with resolver call; FOR EACH mentioned_tickers entry in raw LLM JSON: resolver.resolve(t) → if .resolution_method != UNKNOWN AND .resolution_confidence >= _MIN_CONFIDENCE_THRESHOLD: emit canonical Ticker; ELSE skip silently (current behavior on 2-4 char filter fail); ZERO ExtractedClaim schema change (mentioned_tickers tuple[Ticker, ...] preserved); resolver DI via ClaudeLlmExtractor constructor field default = None sentinel (when None, FALLBACK to current 2-4 char filter for backward compat); production wiring at apps/cli/ingest_news_* uses ClaudeLlmExtractor(ticker_resolver=VnTickerResolver()); _MIN_CONFIDENCE_THRESHOLD = 0.85 (architect default; revisit per AQ-7)"
  - "DD-6 AMBIGUITY POLICY = RETURN EXPLICIT AMBIGUOUS RESOLUTION_METHOD WITHOUT SILENT PICK — when difflib.get_close_matches returns ≥2 candidates within cutoff window (e.g. VIN → Vingroup VHM vs Vinaconex VCG with similar ratios), resolver returns ResolutionResult(resolution_method=AMBIGUOUS, candidates=tuple[Ticker, ...], resolution_confidence=0.0, matched_alias=mention); _build_claim treats AMBIGUOUS as 'skip' (matches current 2-4 char filter behavior of dropping unresolved); RATIONALE: silent-pick-on-ambiguity violates I-S22 data lineage + risks confirmation bias; explicit AMBIGUOUS surface in observation log preserves audit trail + lets future calibration cycle decide policy (no Rule 17 charter-tier escalation needed for v0 per § M)"
  - "DD-7 ALIAS TABLE INITIAL CONTENT = VN30 UNIVERSE ONLY per parent AQ-9 + Charter § First Sub-Scope thin-slice anchor — ~30 tickers × ~3-5 aliases each = ~100-150 alias entries v0; expansion path documented in alias-table file footer + ADR D-073 revisit triggers; OUT-of-scope: HNX-30 + UPCoM full universe (E.4-V2 trigger per AQ-9)"
  - "DD-8 DIFFLIB CUTOFF = 0.85 ARCHITECT DEFAULT — Python stdlib difflib.get_close_matches(cutoff=0.85, n=3); RATIONALE: 0.85 balances recall (catches 'vinhomes' → VHM at ratio ~0.86 on 'Vinhomes' canonical) vs precision (rejects 'vincomeBank' from being unintentionally resolved to VCB); EMPIRICAL test fixture in D3 validates this threshold against 15+ resolution test cases; revisit trigger = D5 CLI smoke run shows <70% recall OR >5% false-positive on real VN news corpus (RM5)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (e.g. NEW alias-table markdown parser shape; NEW DiacriticsStripper helper); 2nd recurrence triggers promote-to-skill calculus (anti-AP-23 cluster: ResolverProtocol-deferred-pre-emptively per DD-2 = first-instance HOLD for Protocol/ABC port; 2nd-instance trigger = sub-plan 032-V2 second backend)"
  - "Karpathy P3 surgical-changes — this sub-plan adds ≤500 LOC production code total across D1-D5 (resolver class ~200 LOC + alias-table-parser ~50 LOC + tests ~200 LOC + CLI smoke ~80 LOC + _build_claim edit ~+15 LOC = ~545 LOC ceiling; alias-table markdown ~250 LOC content NOT counted as production LOC per ubiquitous-language convention)"
  - "VBW protocol mandatory — S371 dev MUST READ claude_llm_extractor.py L219-282 (_build_claim function body) + existing Ticker value object + ExtractedClaim model empirically at S371 entry; cite file:line for every dependency claim per I-S2"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN+IMPL; THIS is sub-plan author session; production code lands in S371 dev IMPL)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S371-* is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire — Rule 17 ambiguity policy charter-tier OR HSX licensing OR alias-table source charter-tier; that write happens in S371 dev session NOT this S370 PLAN session)"
  - "no touching Phase D Theme L files — all 4 VN adapters + 6 primitives shipped + verified; this sub-plan does NOT touch adapters"
  - "no touching Phase E sub-plan 029 files — pyvi VnTokenizer + WhitespaceTokenizer + TextTokenizerPort SHIPPED at S362; this sub-plan does NOT depend on tokenizer per § AQ-1"
  - "no touching Phase E sub-plan 030 files — VnSentimentLexicon + VN_CULTURAL_ANCHORS + SentimentScore + VnLexiconPort SHIPPED at S365; this sub-plan does NOT depend on lexicon per § AQ-1"
  - "no touching Phase E sub-plan 031 files BEYOND the surgical edit at claude_llm_extractor.py:238-241 — ALL other claude_llm_extractor.py code unchanged (no test_adapters.py modification beyond new test cases for resolver integration; ExtractedClaim model UNCHANGED — mentioned_tickers tuple[Ticker, ...] preserved); D-052 analysis-side cleanup OUT-OF-SCOPE per S369 verifier F3 DEFERRED to harness sweep"
  - "no Phase F-prime / G-prime / H-prime work in THIS sub-plan — Phase E.4 is FINAL sub-plan of Phase E; Phase F-prime master-plan dispatch happens in main session POST-S372-verifier per § N + parent plan-028 § M"
  - "no charter amendment SHIP from THIS plan — IF Rule 17 ambiguity-disambiguation charter-tier issue surfaces (per § M CHARTER-TIER GATE), THIS plan FLAGS via human-workspace/notifications/STOP-FINDING-S371-rule-17-ambiguity-policy.md but DOES NOT amend charter; main session dispatches AskUserQuestion + ADR drafted separately per CLAUDE.md hard rule"
  - "no harness/hook changes — this plan ships product substrate (VN ticker resolver); surface any harness gaps in observation; do NOT fix here. L-S354-2 + L-S366-4 (.planner-stats.tsv auto-population gap) + L-S369-1 (ADR empirical_close_verify drift PROMOTE-NOW) all belong to next harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.6 grep-asserts no new HTTP fetcher OR HARD-REJECT artifact in dependencies (no new deps this sub-plan; resolver uses stdlib difflib + dataclasses + existing Ticker import)"
  - "no new external dependencies — pyproject.toml UNCHANGED (per parent DD-6 stdlib difflib only)"
  - "If STEP 0 surfaces a charter-tier need (Rule 17 ambiguity policy OR HSX listing as authoritative alias source license/reliability ratification OR new I-S<N> for entity-resolution discipline), FLAG in § CHARTER-TIER GATE for main session AskUserQuestion ratification gate dispatch"
---

# S370 — Phase E.4 Vietnamese Ticker Resolver sub-plan (FRESH-MODULE + ALIAS-TABLE — FOURTH + FINAL sub-plan of Phase E)

> **One-sentence intent**: Build a fresh `apps/_shared/entities/vn_ticker_resolver.py` module that resolves Vietnamese company-name mentions ("vinhomes" / "Vinhomes" / "Công ty Cổ phần Vinhomes" / "VHM") to canonical `Ticker("VHM")` via hand-curated VN30-universe alias table at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` + Python stdlib `difflib.get_close_matches` fuzzy fallback — without LLM in the resolution path (I-S1 + Rule 16 mode 2 by construction), without silent-pick on ambiguous mentions (DD-6 explicit AMBIGUOUS surface preserves I-S22 lineage; deferred Rule 17 charter-tier escalation), and without new external dependency (parent DD-6 stdlib-only mandate) — then REFACTOR `ClaudeLlmExtractor._build_claim` 2-4 char uppercase filter at claude_llm_extractor.py:238-241 to call resolver per parent DD-6 step 4 + AQ-9 + S369 verifier risk-area 5 carry-forward.

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent plan-028 § E.4 + DD-6 + AQ-9)

Build the **Vietnamese ticker-entity resolver layer** for StockForge that:

- **Centralizes VN ticker resolution** per A-14 § 7.7 anti-pattern explicit veto ("don't repeat the duplicated hard-coded English-only company-name lookups across ~6 files anti-pattern" — current StockForge has ad-hoc 2-4 char uppercase filter at claude_llm_extractor.py:238-241 which would miss "vinhomes" lowercase variant entirely)
- **Resolves Vietnamese name variants** to canonical Ticker per `packages/contracts/types/ticker.py` schema (3-character A-Z/0-9 uppercase): "vinhomes" / "Vinhomes" / "VINHOMES" / "Vin Homes" / "Công ty Cổ phần Vinhomes" / "CTCP Vinhomes" / "VHM" → all map to canonical `Ticker("VHM")`
- **Provides resolution audit trail** per I-S22 data lineage: ResolutionResult dataclass carries .resolution_method enum {EXACT, CASE_INSENSITIVE, DIACRITICS_STRIPPED, FUZZY, AMBIGUOUS, UNKNOWN} + .resolution_confidence float in [0.0, 1.0] + .matched_alias preserved + .alias_table_version string
- **Surfaces ambiguity explicitly** without silent-pick: VIN → if matches both VHM (Vinhomes) + VCG (Vinaconex) within cutoff window, returns ResolutionResult(resolution_method=AMBIGUOUS, candidates=tuple[Ticker, ...], resolution_confidence=0.0); _build_claim treats AMBIGUOUS as skip (matches current behavior for unresolved entries)
- **Satisfies Rule 16 mode 2 (deterministic-pipeline echo) by construction** — resolver is pure-function; difflib.SequenceMatcher.ratio() is deterministic; LLM is NOT in the resolution path
- **Satisfies I-S1 (NO LLM math) by construction** — all resolution is rule-based deterministic; LLM is NOT in the resolution path
- **Refactors `_build_claim` ticker filter** per parent DD-6 step 4 + S369 verifier risk-area 5 carry-forward — replaces 2-4 char uppercase filter at claude_llm_extractor.py:238-241 with resolver call; ExtractedClaim schema UNCHANGED (mentioned_tickers tuple[Ticker, ...] preserved); resolver DI via constructor; default = None sentinel → fallback to current 2-4 char filter for backward compat (zero existing-test regression)
- **Phase E DONE at this sub-plan close** — fourth + final sub-plan of Phase E; Phase F-prime master-plan dispatch unblocked

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — Alias-table markdown at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (~250 LOC markdown content; VN30 universe ~30 tickers × ~3-5 aliases each = ~100-150 entries; canonical-form headers per UL glossary entry pattern; foundation; blocks D2)
2. **Sub-track D2** — VnTickerResolver concrete class at `apps/_shared/entities/vn_ticker_resolver.py` (~200 LOC: ResolutionResult dataclass + ResolutionMethod enum + alias-table parser + resolve() method + difflib integration; blocks D3/D4/D5)
3. **Sub-track D3** — Unit tests at `apps/_shared/entities/test_vn_ticker_resolver.py` (~200 LOC; ≥15 test cases covering exact / case-insensitive / diacritics-stripped / fuzzy / ambiguous / unknown / VN cultural-name variants; parallel with D4)
4. **Sub-track D4** — Surgical edit to `packages/infrastructure/news/claude_llm_extractor.py:238-241` (+~15 LOC: ticker_resolver: VnTickerResolver | None constructor field + _build_claim filter refactor + 3 new test cases in test_adapters.py covering resolver-injected vs default-None backward-compat; parallel with D3)
5. **Sub-track D5** — Integration smoke + CLI ticker-resolve harness at `apps/cli/resolve_vn_tickers.py` (~80 LOC; reads NewsArticle rows OR raw text snippets from stdin/HTML files; dumps per-mention JSON including resolution_method + resolution_confidence + matched_alias + canonical_ticker; sequential after D2)
6. **ADR D-073 PROPOSED** at IMPL tier (per severity-schema auto-ratifies on commit) — "VN Ticker Resolver v0 + Alias Table" — records resolver design + alias-table source + difflib threshold + ambiguity policy + revisit triggers
7. **STEP 0 observation appended** to S371 dev observation file (records VBW reads + alias-table seeding decisions + DD-2 class-vs-Protocol rationale + corpus dogfood result on ≥5 real article snippets)
8. **`apps/_shared/entities/__init__.py` NEW** (~10 LOC; exports VnTickerResolver + ResolutionResult + ResolutionMethod for downstream consumers)
9. **Session log + observation file** per CLAUDE.md § Session Protocol End
10. **Mistake-log digest entry** (M-S371-N if mistakes; OR explicit "no mistakes" statement)
11. **ZERO charter / constitution writes** (STOP-FINDING file at `human-workspace/notifications/STOP-FINDING-S371-rule-17-ambiguity-policy.md` is the ONLY conditional human-workspace write path AND only if § M CHARTER-TIER GATE Rule 17 triggers fire — LIKELY-VERY-LOW per § M analysis)
12. **ZERO new LLM-numeric schema fields** (Rule 16 mode 2 by construction — resolution_confidence is internal-to-ResolutionResult NOT persisted on ExtractedClaim; ExtractedClaim schema UNCHANGED)
13. **ZERO new hooks** (mirror plan-020/022/026/027/029/030/031 — product substrate not harness rule-enforcement)
14. **ZERO new external dependencies** (per parent DD-6 stdlib difflib only; pyproject.toml UNCHANGED)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| **Phase F-prime Theme H** (BC-8 multi-perspective primitives) | Independent master-plan per parent plan-028 § M.1; depends on Phase C Theme G ratification (already done D-065); INDEPENDENT of Theme I output | Phase F-prime master-plan dispatch triggered by THIS sub-plan VERIFY close (S372) per § N + parent plan-028 § M.1 critical-path |
| **Phase G-prime + H-prime** (PDF + table extraction BC-2; UX/Output Streamlit polish) | Phase 2+ work per master plan § 6.4.4 + § 6.4.5; not on Phase 1 critical path | Phase 2 entry triggers (per parent master plan) |
| **HNX-30 + UPCoM full universe alias coverage** (E.4-V2) | VN30 is Phase 1 thin-slice anchor per Charter § First Sub-Scope + glossary § VN30 (line 154-156); broader universe expansion is empirical-driven per AQ-9 | E.4-V2 trigger: alias-table grows to n>100 tickers OR ≥3 unresolved ticker mentions surface in production extractor logs (per RM4 + AP-23 cluster) |
| **HSX listing as authoritative alias source** (license + reliability audit) | Hand-curated VN30 ubiquitous-language seed is sufficient for v0 (~30 tickers × 5 aliases manually curatable in ~2 hours); HSX scraping introduces license risk + brittleness; defer until corpus expansion mandates | HSX trigger: alias-table grows to n>100 tickers per E.4-V2 + automated update cycle becomes pain point |
| **spaCy NER / fuzzywuzzy / rapidfuzz fuzzy backends** | difflib stdlib is sufficient for n≤30 VN30 universe per parent DD-6; rejected for sub-plan 032-v0 per AP-7 + Karpathy P2 | spaCy / fuzzywuzzy trigger: VN universe grows to n>200 tickers + difflib threshold tuning fails empirical recall floor (per RM5) |
| **PhoBERT / transformer-based VN NER** (heavy ML resolution) | Heavier deps (torch + transformers ≥500MB); difflib + alias table is simpler + interpretable + cheap per Karpathy P2 | Transformer trigger: ONLY if spaCy NER fallback insufficient on financial-news subdomain (<70% accuracy) — far future per AQ-9 trigger chain |
| **Custom-trained VN-financial-domain NER** (fine-tune on VN corpus) | Requires labelled corpus n≥500 + ML training infra; v0 is hand-curated alias table | Custom NER trigger: ONLY if transformer fallback insufficient + n≥500 labelled NER corpus available |
| **Ticker resolution caching / memoization** | Defer per Karpathy P2 simplicity; difflib is O(n_aliases) which is sub-ms for n≤150 entries; latency dominated by LLM not resolver | Cache trigger: production-throughput Phase 3 gate when resolution becomes >5% of session time |
| **Persisting resolution audit trail to database** | ExtractedClaim already records mentioned_tickers (canonical Ticker); resolution_method / resolution_confidence audit trail lives transiently in ResolutionResult during extraction; persistence adds schema surface + storage cost | Persistence trigger: production audit query surfaces need for "why was this Ticker resolved this way" — defer to E.4-V2 ADR D-073 revisit cycle |
| **Async resolver interface** | Resolver is pure-function CPU-bound; sync wrapper sufficient | Async trigger: Phase 3 production-throughput gate when resolution becomes >5% of session time (highly unlikely for v0) |
| **Multi-language ticker resolution** (English / Chinese fallback) | VN-only is the moat per Charter Principle 4 | Trigger: explicit user directive for multi-locale OR market expansion |
| **Ticker resolution from raw article body text** (NER-style scanning) | Out-of-scope per parent DD-6 v0; resolver consumes LLM-emitted mentioned_tickers entries (each entry is a candidate string from LLM JSON); upstream body scanning is sub-plan 029 tokenizer + sub-plan 031 extractor responsibility | Body-scanning trigger: E.4-V2 if mentioned_tickers field proves under-populated by LLM relative to actual article mentions |
| **Charter amendment SHIP for Rule 17 entity-ambiguity-disambiguation policy** (if STEP 0.5 STOP-AND-ASK fires) | THIS plan FLAGS via STOP-FINDING file; main session ratifies via AskUserQuestion gate; ADR drafted separately per CLAUDE.md hard rule | Trigger: § M CHARTER-TIER GATE STEP 0.5 STOP-AND-ASK fires on Rule 17 user-veto / authoritative-source ratification need |
| **VnTickerResolver Protocol port** (port + adapter discipline) | Per DD-2 Karpathy P2 simplicity — single concrete class shipped; Protocol-ification = AP-23 first-instance HOLD; revisit when second backend surfaces empirically | Protocol trigger: spaCy NER / transformer backend candidate surfaces empirically per AQ-9 trigger n>200 tickers |
| **Negation handling at resolution level** (e.g. "không phải VHM" = NOT VHM) | Out-of-scope per parent DD-6; resolver resolves entity mentions agnostic of polarity; sentiment handling lives at sub-plan 030 lexicon (RM10 carry-forward there) | Negation trigger: sub-plan 030-V2 calibration cycle if systematic mis-tagging surfaces (per sub-plan 030 RM10) |
| **New harness hook for VN-ticker-resolution-determinism check** | Belongs to harness-stabilization sweep IF a resolver-determinism defect surfaces; product session SHIPS the module not the hook | Harness trigger: 2+ silent resolver-output-drift incidents (AP-23 promote-to-hook) |
| **D-052 analysis-side anthropic SDK cleanup** (sub-plan 031 verifier F3 carry-forward) | Pre-existing D-052 false empirical_close_verify + analysis adapter `import anthropic` still at line 80 — DEFERRED to harness sweep per S369 verifier explicit handoff item 1; NOT in this sub-plan scope | Harness sweep trigger: next harness-stabilization session; L-S369-1 PROMOTE-NOW (ADR empirical_close_verify drift detection) per S369 verifier |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; n=3 vietnamese-nlp-impl PRECEDENT from S362 + S365 + S368; cold-start window NOW CLOSED at task_class level)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `agent-workspace/memory/.planner-stats.tsv` (read entire file = 1 header line; CONFIRMED L-S354-2 + L-S366-4 carry-forward STILL — planner-feedback-loop.sh STILL has not auto-populated after S354/S357/S360/S361/S362/S363/S364/S365/S366/S367/S368/S369 dogfood cycles; auto-population infrastructure gap; manual reading via current-execution.md + mistake-log + observations substitute)
2. `agent-workspace/memory/current-execution.md` (offset 1-200 read; S368 sandwich-dev RETURN row L147-170 confirms vietnamese-nlp-impl n=3 precedent at sub-plan 031: Opus 4.7 FOCUSED_IMPL AP-1, 1085/1085 tests, 0 mistakes; S365 row L174-195 confirms n=2 at sub-plan 030: Sonnet 4.6 ~150K / ~39min / 1079/1079 / 0 mistakes; S362 row at ~L172-188 in older window confirms n=1 at sub-plan 029: Sonnet 4.6 ~159K / ~39min / 1053/1053 / 0 mistakes)
3. `agent-workspace/memory/mistake-log.md` (last 60 LOC digest; M-S357-1 INLINE-RESOLVED UTC+7 fix / M-S354-NONE / M-S342-1 medium / M-S341-1 low / S362+S365+S368 all clean per dev self-reports — **no vietnamese-nlp-impl-specific failure pattern history at any of the 3 dev cycles**; M-S360-2 carry-forward documents Opus PLAN budget recalibration empirical ratification; M-S365-1 carry-forward documents AP-1 fresh-context mandate per sub-plan 030 verifier S366)
4. `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (parent master plan; full read in 3 chunks offset 1-300 + 300-500 + 600-720 covering §s A/B/C/D/E/F/G/H/J/K/L/M/N/P; CONFIRMED sub-plan 032 § E.4 row + DD-6 FRESH-MODULE + ALIAS-TABLE + § K.2 anticipated FLAG ('alias table surfaces ambiguous mappings (e.g. "VIN" → Vingroup vs Vinaconex vs ?) → I-S22 data lineage flag → resolver MUST return tuple of candidates with resolution_confidence; user-ratification needed for ambiguity handling policy → CANDIDATE CHARTER-TIER FLAG (NEW Rule 17 for entity-ambiguity-disambiguation discipline) — likelihood low') + AQ-9 alias table expansion answer)
5. `agent-workspace/session-plans/completed/029-S361-phase-e1-vn-tokenization.md` (precedent sub-plan; offset 1-200 read for sub-plan template format mirror including A/B/C/D/E/F/G/H/I/J/K/L/M/N section structure)
6. `agent-workspace/session-plans/completed/030-S364-phase-e2-vn-sentiment-lexicon.md` (precedent sub-plan; offset 1-200 read for D1-D5 sub-track decomposition format + DoD template + § A.4 Phase 1b CONSUMED variant template)
7. `agent-workspace/session-plans/completed/031-S367-phase-e3-claim-extraction-wrapper.md` (precedent sub-plan; offset 1-200 read for AUGMENT pattern reference + § DD-6 ADR landing pattern + DI graceful-degradation reference)
8. `agent-workspace/memory/observations/sandwich-verifier-S369-vn-claim-extraction-verify.md` (precedent verifier observation; full read 85 LOC; CONFIRMED Phase E.3 → E.4 sequencing READY per § Verdicts (c); sub-plan 031 mv pending → completed AUTHORIZED; risk-area 5 — ticker-resolver refactor at _build_claim — explicitly carried to E.4 per § Dev handoff item 5)
9. `agent-workspace/memory/observations/sandwich-architect-S361-phase-e1-tokenization-plan.md` (precedent observation; offset 1-100 read; format reference for S370 observation file)
10. `agent-workspace/memory/decisions/070-vn-tokenizer-library.md` (ADR D-070; via grep; pyvi==0.1.1 selection + MIT license + revisit triggers; pyvi VnTokenizer instantiable confirmed via current-execution.md S362 row)
11. `agent-workspace/memory/decisions/071-vn-sentiment-lexicon.md` (ADR D-071; via grep; UNCALIBRATED-V0 + revisit triggers; VnSentimentLexicon instantiable confirmed via current-execution.md S365 row)
12. `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (ADR D-072; PROPOSED at S368; AUGMENT + transport flip news-side; D-073 next slot for THIS sub-plan)
13. `packages/contracts/types/ticker.py` (full read 63 LOC; Ticker frozen+slots dataclass + symbol field + _TICKER_PATTERN `^[A-Z0-9]{3}$` 3-character canonical enforcement + InvalidTickerError + uppercase normalization in __post_init__ — THIS sub-plan PRESERVES existing schema; resolver OUTPUTS Ticker instances; does NOT modify)
14. `packages/infrastructure/news/claude_llm_extractor.py` (full read in chunks: L1-120 + L150-220 + L220-290; ClaudeLlmExtractor dataclass + _build_claim function body at L219-282 + ticker filter at L238-241 `t.isupper() and 2 <= len(t) <= 4` — surgical edit target for D4; existing tokenizer DI + lexicon DI pattern at L116-130 + _compute_lexicon_artifacts at L192-210 — RESOLVER DI MIRRORS this pattern)
15. `packages/domain/news/models/extracted_claim.py` (full read 107 LOC; ExtractedClaim frozen+slots + Rule 6 invariants + lexicon_score + mentioned_pump_anchors per sub-plan 031 — UNCHANGED this sub-plan; mentioned_tickers tuple[Ticker, ...] preserved)
16. `agent-workspace/ubiquitous-language/glossary.md` (offset 1-100 + 150-210 read; § Ticker entry L14-16 confirms canonical 3-character HOSE/HNX/UPCoM uppercase convention; § VN30 entry L152-156 confirms Phase 1 thin-slice anchor per Charter § First Sub-Scope — THIS sub-plan SEEDS alias table with VN30 universe per DD-7; § Đội lái L86-88 confirms VN-specific cultural anchor pattern — alias-table follows similar source+as-of UL entry style; § Forbidden Terms L196-205 preserved — resolver outputs Tickers NOT "buy signals")
17. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme I (read via parent plan reference at parent § A.2 + § H source 4; supplement § I.4 mandates `apps/_shared/entities/vn_ticker_resolver.py` location + fuzzy match + alias table)
18. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md` § 7.7 (referenced via parent plan-028 § H source 4; anti-pattern explicit veto "don't repeat the duplicated hard-coded English-only company-name lookups across ~6 files" — direct architectural mandate for centralized resolver)
19. `agent-workspace/constitution/financial-data-protocol.md` Rule 16 (referenced via parent plan-028 § C.0.4 + existing extractor Rule 16 mode-2 satisfaction; CHARTER tier — resolution_confidence is mode 2 deterministic-pipeline echo)
20. `.claude/skills/ddd-tactical-patterns/SKILL.md` (referenced via parent plan + sub-plan 029/030/031 precedent; Value Object discipline confirms Ticker preserved; resolver as utility module NOT entity)
21. `.claude/agents/sandwich-architect.md` (offset 35-250 read; Phase 1b template L42-65 calibration path + L110-120 sub-track 3 mandatory fields + L207-210 observation mandate; recalibrated PLAN budget per M-S360-2)
22. `pyproject.toml` (full read 195 LOC; current dep stack confirms pyvi present per S362; ZERO new deps for this sub-plan per DD-6 stdlib-only mandate)
23. Glob `apps/_shared/**/*.py` — 12 files confirmed (use_case_builder.py + __init__.py + crawl/ subdir with 6 files including selector_chain.py + raw_html_sink.py + rate_limiter.py + robots_manager.py + tests); apps/_shared/entities/ subdir does NOT exist yet — clean baseline for D2 namespace creation
24. Glob `apps/_shared/entities/**` — 0 matches confirmed (NEW namespace per DD-1 + parent DD-9)
25. Glob `agent-workspace/memory/decisions/0*.md` — 60+ ADRs through D-072; D-073 next slot for this sub-plan
26. Glob `agent-workspace/ubiquitous-language/**` — confirms glossary.md exists; vn_ticker_aliases.md is NEW per D1
27. Grep `VnTickerResolver|vn_ticker_resolver|TickerResolver|ticker_resolver|alias_table|VN30 alias` across repo — 3 matches all in agent-workspace research/master-plan/supplement docs; ZERO production code references; clean baseline for D2
28. Grep `difflib|SequenceMatcher|get_close_matches` across repo — 0 matches in production code; clean baseline for stdlib adoption
29. Grep `^t\.isupper.*len\(t\)|2 <= len\(t\) <= 4` in packages/infrastructure/news/ — 1 match at claude_llm_extractor.py:240 (surgical edit target for D4 per parent DD-6 step 4)
30. Read `agent-workspace/memory/sessions/` last 3 files via existing context — S368 dev session log + S369 verifier session log + S370 main session log; n=3 dev cycle precedent confirmed clean

**Calibration parameters extracted**:

- **task_class**: `vietnamese-nlp-impl` (PRECEDENT n=3 from S362 + S365 + S368; sub-plan 032 IMPL inherits this precedent; cold-start window NOW CLOSED at task_class level per agent-template L65 threshold n≥3)
- **sample_size**: **3** (S362 Sonnet 159K/39min/1053/0; S365 Sonnet 150K/39min/1079/0; S368 Opus 4.7 fresh-context/1085/0 — all clean cycles per current-execution.md rows; sub-plan 032 IMPL projected to fit lower-band envelope because (a) FRESH MODULE + ALIAS TABLE is structurally simpler than transport-flip + AUGMENT-augment of sub-plan 031; (b) NO LLM dispatch; (c) NO complex DI graph beyond optional Ticker injection)
- **avg_wall_min observed**: ~39 min for S362+S365 (precision medium at n=2 for wall-min; S368 wall-min not telemetered per L-S354-2 carry-forward; directional avg ~39 min holds)
- **avg tokens_real observed**: ~155K Sonnet for S362+S365 (S362 159K + S365 150K mean; precision medium at n=2 for Sonnet tokens; S368 Opus tokens not precisely telemetered per L-S354-2 but within recalibrated envelope per current-execution.md S368 row)
- **parallel_hit_rate**: N/A precise (n=3; D3+D4 parallel declared in S362+S365+S368 plans; actual parallel-hit not telemetered per L-S354-2)
- **parallel_savings_avg**: N/A precise; THIS plan projects D3+D4 parallel (~5-10% wall reduction) similar to plan-029/030/031 projections
- **failure_mode frequency**: 0 mistakes per S362+S365+S368 triple samples (M-S362-NONE + M-S365-NONE + M-S368-NONE per dev self-reports — clean trio); n=3 directional clean; sub-plan 032 may surface MINOR defects on the _build_claim surgical edit (Ticker.value→Ticker.symbol-style discovery per S368 inline-fix precedent — risk LIKELY-LOW per RM3 below)
- **Adjustment to default budget**: NONE for resolver+tests portion (mirror S362+S365+S368 lower-band ~150K Opus); -10-20K possible swing for SIMPLER shape (fresh module + alias table scaffolding vs transport-flip + AUGMENT complexity of sub-plan 031); +5-10K reserve for STEP 0 STOP-AND-ASK file authoring IF Rule 17 triggers fire (RM5 LIKELY-VERY-LOW per § M analysis)
- **Cold-start?**: **NO for vietnamese-nlp-impl task-class** (n=3 precedent from S362+S365+S368 — cold-start window CLOSED per agent-template L65 threshold); **NO for FRESH MODULE shape** (sub-plan 029 D2+D3 + sub-plan 030 D2+D3 both shipped fresh-module patterns clean); **NO for ALIAS-TABLE shape** (similar to ubiquitous-language glossary extension + sub-plan 030 lexicon-dict in Python pattern; markdown variant per DD-3 rationale)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S371 dev):

- S371 dev IMPL projection: **100-150K Opus FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=3 precedent (S362+S365+S368 all within envelope; sub-plan 032 lower-band projection due to structurally simpler shape per DD-1 fresh module vs transport-flip+AUGMENT of 031) + 5-10K Opus reserve for STEP 0 STOP-AND-ASK file authoring IF Rule 17 triggers fire
- STEP 0 evaluation overhead: ~12-18K (alias-table source decision + VN30 universe seed + DI-injection-point audit + 3-5 article dogfood smoke — variable depending on STEP 0.5 outcome)
- D1 alias-table markdown: ~8-12K (~250 LOC hand-curated content; VN30 universe; ~30 tickers × ~3-5 aliases each)
- D2 VnTickerResolver class + ResolutionResult dataclass + ResolutionMethod enum + parser: ~25-35K (~200 LOC; difflib integration + diacritics-stripping helper + alias-table loader)
- D3 unit tests: ~15-22K (~200 LOC; ≥15 cases covering exact/case-insensitive/diacritics/fuzzy/ambiguous/unknown)
- D4 surgical _build_claim edit + 3 new test cases in test_adapters.py: ~10-15K (+~15 LOC production + ~50 LOC tests)
- D5 CLI smoke: ~8-12K (~80 LOC click harness reading stdin/HTML files + dumping JSON resolution output)
- ADR D-073 + observation + session log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL on Rule 17 gate; LIKELY-VERY-LOW): ~5-10K
- Reserve for inline F-fix per sub-plan 031 Ticker.value→Ticker.symbol-style discovery pattern: ~5-10K
- **Total projected dev budget envelope**: 90-130K typical; 110-150K with STEP 0.5 STOP-AND-ASK path; full 150K Opus cap respected per recalibrated table

**PARALLEL OPPORTUNITY** (architect declaration for downstream S371 dev):

- D1 (alias-table markdown) must serialize FIRST as foundation (~5-8 min wall; bulk is hand-curation per project-owner-knowledge)
- D2 (resolver class) must wait for D1 (~12-15 min wall; difflib integration + diacritics helper + parser)
- D3 (tests) + D4 (_build_claim surgical edit + 3 new test cases) can run in parallel post-D2 ship — disjoint file scopes per § E coordination_paths_exclusive (D3 = `apps/_shared/entities/test_vn_ticker_resolver.py`; D4 = `packages/infrastructure/news/claude_llm_extractor.py` + `packages/infrastructure/news/test_adapters.py` new test cases only); max(8, 7) = ~8 min wall
- D5 (CLI smoke) sequential after D2 (~5 min wall; reads existing NewsArticle SQLite OR HTML files + dumps JSON)
- Sequential wall projection: 6 + 13 + 8 + 7 + 5 = ~39 min wall
- Parallel D3+D4 wall projection: 6 + 13 + 8 + 5 = ~32 min wall (~18% reduction)
- 2-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S371 dev — references § A.2 + § A.3)

### IN-scope (S371 dev MUST ship) — references § A.2 items 1-14

- VnTickerResolver concrete class + ResolutionResult dataclass + ResolutionMethod enum (D2; ~200 LOC)
- Hand-curated alias-table markdown for VN30 universe (D1; ~250 LOC content)
- Unit tests covering ≥15 test cases (D3; ~200 LOC; exact/case-insensitive/diacritics/fuzzy/ambiguous/unknown/cultural-name variants)
- Surgical _build_claim edit (D4; ~+15 LOC production + ~50 LOC test extensions) — replaces 2-4 char uppercase filter with resolver call
- CLI smoke harness (D5; ~80 LOC; click + JSON output)
- ADR D-073 PROPOSED at IMPL tier (auto-ratifies on commit per severity-schema)
- apps/_shared/entities/__init__.py NEW namespace exports
- Session log + observation file + mistake-log digest per CLAUDE.md § Session Protocol End

### OUT-of-scope (DEFERRED — references § A.3 table 17 items)

See § A.3 table — 17 items with named revisit triggers per AP-7 anti-vacuous-defer.

---

## C. STEP 0 — VBW Live Verification (S371 dev MUST execute before D1)

### Sub-step 0.1 — Existing Ticker + ExtractedClaim + claude_llm_extractor state audit (VBW)

- ✅ READ `packages/contracts/types/ticker.py` — confirm Ticker frozen+slots dataclass + symbol field + 3-char enforcement + uppercase normalization; resolver OUTPUTS Ticker instances; NO modification
- ✅ READ `packages/domain/news/models/extracted_claim.py` — confirm mentioned_tickers tuple[Ticker, ...] preserved; NO schema change
- ✅ READ `packages/infrastructure/news/claude_llm_extractor.py:219-282` — confirm _build_claim signature + ticker filter at L238-241; surgical edit site identified
- ✅ READ `packages/infrastructure/news/claude_llm_extractor.py:116-130` — confirm existing tokenizer + lexicon DI field pattern (default WhitespaceTokenizer + lexicon=None sentinel); RESOLVER DI MIRRORS this pattern with default=None sentinel for backward-compat
- ✅ READ `agent-workspace/ubiquitous-language/glossary.md` § Ticker + § VN30 + § Forbidden Terms — confirm canonical 3-character HOSE/HNX/UPCoM convention + Phase 1 VN30 thin-slice anchor + research-aid framing
- ✅ Glob `apps/_shared/entities/**` — confirm directory does NOT exist; D2 creates namespace
- ✅ STOP-AND-ASK trigger if any of above fail empirical verification

### Sub-step 0.2 — Alias-table source decision (BLOCKING per dispatch brief CRITICAL Rule 17 gate)

**Question**: WHO authoritatively resolves alias table content for v0?

**Options per dispatch brief**:
- (a) Project owner manually curates alias DB (Vietnam-specific) — RECOMMENDED v0 path; project-owner-knowledge of VN30 universe ~2-hour curation; markdown source-of-truth lives at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (UL glossary extension pattern)
- (b) HSX listing as authoritative source — DEFER per § A.3 + AQ-9 (license + reliability audit out-of-scope v0)
- (c) Drop ambiguous tickers (skip silently) — REJECTED per DD-6 ambiguity-explicit-not-silent policy
- (d) NEW Rule 17 invariant requiring alias-table review process — CHARTER-TIER; defer per § M Rule 17 gate (LIKELY-VERY-LOW likelihood)

**Architect default for v0 (option a)**: project-owner manual curation at IMPL time via D1; alias-table is markdown source-of-truth; no runtime mutation; version-tracked via git.

**STOP-AND-ASK trigger**: If S371 dev STEP 0.2 cannot proceed with option (a) (e.g. project owner unavailable for curation OR demands HSX automation), dev writes `human-workspace/notifications/STOP-FINDING-S371-alias-table-source.md` with 3 options (a/b/d) for user pick.

### Sub-step 0.3 — Rule 17 CHARTER-TIER GATE consideration (per dispatch brief CRITICAL)

**Question**: Does ticker alias resolution require explicit Rule 17 (disambiguation policy for cases like VIN → Vingroup vs Vinaconex)?

**Analysis** (per § M CHARTER-TIER GATE detailed):
- Existing financial-data-protocol.md Rules 1-16 cover sentiment + numeric + provenance + LLM-math; ZERO existing rule for entity-ambiguity-disambiguation
- DD-6 ambiguity policy = AMBIGUOUS surface (explicit, not silent) — preserves I-S22 data lineage WITHOUT requiring new Rule 17
- _build_claim treats AMBIGUOUS as 'skip' (matches current 2-4 char filter behavior for unresolved entries) — no charter-tier behavioral change vs status quo
- LIKELIHOOD assessment: LIKELY-VERY-LOW that Rule 17 needs to ship for v0; existing I-S22 + Rule 16 mode 2 + AMBIGUOUS-explicit-surface covers the documented v0 scope

**STOP-AND-ASK trigger**: If S371 dev STEP 0.3 surfaces a case where AMBIGUOUS-explicit-surface is insufficient AND user requires a project-binding policy for ambiguity handling (e.g. "always prefer canonical-name-match over case-insensitive-match" OR "always emit ALL candidates to ExtractedClaim audit trail"), dev writes `human-workspace/notifications/STOP-FINDING-S371-rule-17-ambiguity-policy.md` with 4 options:
  - (a) DD-6 AMBIGUOUS-surface-then-skip preserved (no new charter rule)
  - (b) Rule 17 PROPOSED: "Entity-resolution ambiguity MUST surface via ResolutionResult.AMBIGUOUS without silent-pick; consumers (e.g. _build_claim) decide skip-vs-emit-all-candidates policy per use case"
  - (c) Rule 17 STRICTER: "Entity-resolution ambiguity MUST block downstream emission entirely; ExtractedClaim with ambiguous ticker mention is rejected at validation time"
  - (d) Defer to E.4-V2 calibration cycle after empirical ambiguity rate measured on real VN corpus

### Sub-step 0.4 — Rule 16 surface audit for resolver (BINDING per § Charter compliance)

Resolver introduces these candidate schema fields where Rule 16 applies:
- **resolution_confidence**: float in [0.0, 1.0] = difflib.SequenceMatcher.ratio() — **Rule 16 satisfaction MODE 2 (deterministic-pipeline echo)** — pure-function; deterministic across Python releases per stdlib stability guarantee; NO LLM in this path
- **resolution_method**: enum {EXACT, CASE_INSENSITIVE, DIACRITICS_STRIPPED, FUZZY, AMBIGUOUS, UNKNOWN} — categorical not numeric; Rule 16 N/A
- **candidates**: tuple[Ticker, ...] for AMBIGUOUS — Ticker objects per existing schema; Rule 16 N/A
- **matched_alias**: str (preserved input) — string not numeric; Rule 16 N/A

**Verdict**: Only resolution_confidence is Rule 16-sensitive; mode 2 satisfaction by construction. **NO Charter-tier-surface FLAG at sub-plan-032 level** for Rule 16 — same posture as sub-plan 030 (lexicon score) + sub-plan 031 (lexicon_score field).

### Sub-step 0.5 — Existing related-pattern grep audit

- ✅ Grep `VnTickerResolver|ticker_resolver|TickerResolver|alias_table|VN30 alias` across repo — 3 matches in agent-workspace docs only; ZERO production code references; clean baseline
- ✅ Grep `difflib|SequenceMatcher|get_close_matches` across repo — 0 matches in production code; clean baseline for stdlib adoption
- ✅ Grep `^t\.isupper.*len\(t\)|2 <= len\(t\) <= 4` in packages/infrastructure/news/ — 1 match at claude_llm_extractor.py:240; surgical edit target confirmed

### Sub-step 0.6 — I-S34 carry-forward grep check

- ✅ Grep for `patchright|playwright_stealth|fake-useragent|StealthyFetcher` in resolver-adjacent code — ZERO matches expected (resolver is text-in/Ticker-out; no HTTP fetcher); verifier S372 grep-asserts post-IMPL

### Sub-step 0.7 — D-059 determinism check on planned files

- Resolver class: pure-function deterministic by construction (difflib.SequenceMatcher is deterministic per Python stdlib stability guarantee); D-059 R1+R2+R4 satisfied
- Alias-table markdown: hand-curated; version metadata uses UTC string literal (NOT datetime.now()); D-059 R1 satisfied
- ResolutionResult dataclass: frozen+slots; no mutable state; deterministic-by-construction

### Sub-step 0.8 — Dogfood on real corpus (Principle 7 mandate per parent plan-028 binding_decision)

S371 dev MUST resolve ≥5 ticker mentions from real CafeF/NDH/Vietstock/VietnamBiz article snippets (3 from D5 CLI smoke run on existing `data/raw/news/**/*.html` corpus + 2 hand-crafted from observation of actual VN30 cultural names per glossary § VN30); record results in observation file. Cannot ship without dogfood pass.

### Sub-step 0.9 — STEP 0 summary write

All 8 sub-steps PASS → proceed to D1. If STOP-AND-ASK fires at 0.2 OR 0.3, write STOP-FINDING file then HALT for main session AskUserQuestion gate.

---

## D. Architecture Decisions (DD-1 through DD-8 + adversarial alternates)

### DD-1: FRESH MODULE + ALIAS TABLE strategy (per parent plan-028 DD-6)

**Decision**: NEW module `apps/_shared/entities/vn_ticker_resolver.py` (NOT modification of existing Ticker value object at packages/contracts/types/ticker.py); NEW alias table at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (markdown source-of-truth); NEW CLI smoke harness at `apps/cli/resolve_vn_tickers.py`.

**Rationale**: Per parent plan-028 DD-6 + supplement § I.4 + A-14 § 7.7 anti-pattern explicit veto. Centralizing via shared utility from day 1 is cleaner than retro-fixing later. Ticker value object is invariant data type (3-char A-Z/0-9 canonical form per glossary § Ticker); resolver is application-tier capability (transforms variant text → canonical Ticker); separation-of-concerns per DDD tactical patterns.

**Adversarial alternate considered**: Extend Ticker value object with `Ticker.from_text(mention: str)` classmethod factory — REJECTED (Ticker is a value object representing a canonical 3-char symbol; adding fuzzy-match + alias-table dependency to value object violates Single Responsibility + brings VN-specific NLP into the contracts/ layer which should remain framework-agnostic; resolver belongs in apps/_shared/entities/ per architecture.md cross-app shared utility namespace + parent DD-9).

### DD-2: RESOLVER SHAPE = CONCRETE CLASS NOT PROTOCOL

**Decision**: Single concrete class `VnTickerResolver` with `resolve(mention: str) -> ResolutionResult` method. NO Protocol port at this v0 ship.

**Rationale**: Per Karpathy P2 simplicity. Resolver has ZERO swap requirement for v0 (no alternate library OR algorithm planned per AQ-9 difflib-only-v0). Sub-plan 029 selected Protocol for TokenizerProtocol because tokenizer had a documented swap path (underthesea vs pyvi vs WhitespaceTokenizer fallback per DD-2 of sub-plan 029). Resolver has no such documented swap path until E.4-V2 trigger fires (n>200 tickers OR spaCy NER candidate surfaces per AQ-9). Protocol-ification = AP-23 first-instance HOLD — promote when second backend surfaces empirically.

**Adversarial alternate considered**: Ship `VnTickerResolverProtocol` Port + `VnTickerResolver` concrete adapter mirroring sub-plans 029+030 pattern → REJECTED (premature abstraction per Karpathy P2; no swap requirement documented for v0; consumers (current = ClaudeLlmExtractor only) inject via concrete-type field; AP-23 first-instance HOLD discipline applies).

### DD-3: ALIAS TABLE STORAGE FORMAT = HAND-CURATED MARKDOWN (NOT Python dict literal)

**Decision**: Alias table lives at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` as hand-curated markdown source-of-truth. D2 ships a simple markdown parser that loads the table at runtime (or import-time module-level constant).

**Rationale**:
- Alias table is ubiquitous-language artifact (extends UL glossary entry pattern at `agent-workspace/ubiquitous-language/glossary.md` § Ticker + § VN30); project-owner curatable WITHOUT Python knowledge
- Version-tracked via git; per-entry source + as-of metadata per UL glossary entry format precedent
- Parseable via simple stdlib markdown reader (lightweight Python regex parser; no external markdown library needed)
- SUB-RATIONALE FOR DIVERGENCE FROM SUB-PLAN 030 DD-5: lexicon is keyword-WEIGHT scoring data (close to algorithm) → Python dict literal in source; alias-table is entity-mapping reference data (curated by domain experts) → markdown per UL pattern

**Adversarial alternate considered**: Python dict literal in `vn_ticker_resolver.py` source like sub-plan 030's `VN_LEXICON` constant → REJECTED (alias table is curated by domain experts not Python developers; markdown is more accessible for project-owner edits; git-diff-friendly review).

### DD-4: RULE 16 MODE 2 SATISFACTION FOR RESOLUTION_CONFIDENCE

**Decision**: `resolution_confidence: float` in [0.0, 1.0] is computed via `difflib.SequenceMatcher(None, a, b).ratio()` — pure-function deterministic per Python stdlib stability guarantee. LLM is NEVER invoked in the resolution path.

**Rationale**: Per Rule 16 mode 2 (deterministic-pipeline echo) — schema-time guidance for numeric fields. LLM never emits resolution_confidence. ResolutionResult is INTERNAL to the resolver call path; resolution_confidence does NOT persist on ExtractedClaim (which means no EchoValidator runtime tier needed; verifier-tier sampling lives offline if drift surfaces).

**Adversarial alternate considered**: Persist resolution_confidence on ExtractedClaim as a new field → REJECTED (resolution audit trail is transient per § A.3 OUT-of-scope; persistence adds D-062 atomic-write surface + storage cost for marginal benefit; revisit at E.4-V2 if production audit query surfaces need).

### DD-5: _build_claim INTEGRATION = SURGICAL EDIT with DI graceful degradation

**Decision**: Edit `packages/infrastructure/news/claude_llm_extractor.py:238-241` to call resolver. Specifically:
1. ADD `ticker_resolver: VnTickerResolver | None = None` field to `ClaudeLlmExtractor` dataclass (default None → fallback to current 2-4 char filter for backward-compat)
2. REPLACE current filter `t.isupper() and 2 <= len(t) <= 4` with: if `self.ticker_resolver is None`: keep current 2-4 char filter (backward-compat); ELSE: for each `t` in raw mentioned_tickers: `result = self.ticker_resolver.resolve(t)`; if `result.resolution_method != UNKNOWN AND result.resolution_method != AMBIGUOUS AND result.resolution_confidence >= _MIN_CONFIDENCE_THRESHOLD` (= 0.85 per DD-8): emit `result.canonical_ticker`; ELSE skip silently
3. Production wiring at `apps/cli/ingest_news_*.py` uses `ClaudeLlmExtractor(ticker_resolver=VnTickerResolver())`
4. ZERO ExtractedClaim schema change — `mentioned_tickers: tuple[Ticker, ...]` preserved

**Rationale**: Per parent plan-028 DD-6 step 4 + AQ-9 + S369 verifier risk-area 5 carry-forward (explicit dispatch handoff). Surgical Karpathy P3 edit. DI default=None preserves existing test_adapters.py:257-348 + sub-plan 031 test cases (zero regression). Backward-compat is critical because sub-plan 031 shipped 1085/1085 tests at commit b6b3877; this sub-plan MUST preserve that pass rate.

**Adversarial alternate considered**: Replace 2-4 char filter unconditionally (no DI default=None fallback) → REJECTED (breaks backward-compat; existing test_adapters.py fixtures use `Ticker("VHM")` direct construction expectations which the resolver-injected path would satisfy via alias-table lookup; without alias-table seeded in tests, fallback to current filter is the right default; backward-compat per L-S345-3 single-helper-with-keyword-only-flag precedent).

### DD-6: AMBIGUITY POLICY = EXPLICIT AMBIGUOUS RETURN, NO SILENT PICK

**Decision**: When `difflib.get_close_matches(mention, aliases, n=3, cutoff=0.85)` returns ≥2 candidates within cutoff window AND no exact-match wins, resolver returns `ResolutionResult(resolution_method=AMBIGUOUS, candidates=tuple[Ticker, ...], resolution_confidence=0.0, matched_alias=mention, canonical_ticker=None)`. `_build_claim` treats AMBIGUOUS as 'skip' (matches current 2-4 char filter behavior for unresolved entries).

**Rationale**: Per dispatch brief CRITICAL Rule 17 gate analysis + § STEP 0.3. Silent-pick-on-ambiguity violates I-S22 data lineage + risks confirmation bias (e.g. VIN silently resolved to VHM because alphabetical sort favors V*H over V*C). Explicit AMBIGUOUS surface in observation log preserves audit trail + lets future calibration cycle decide policy. No Rule 17 charter-tier escalation needed for v0 per § M CHARTER-TIER GATE analysis.

**Adversarial alternate considered**: Silent-pick highest-ratio candidate → REJECTED (confirmation bias; I-S22 violation). Persist all candidates on ExtractedClaim → REJECTED (DD-4 deferral to E.4-V2 for persistence). Block downstream emission entirely (raise exception) → REJECTED (over-strict; matches AMBIGUOUS skip-pattern via _build_claim is consistent with current 2-4 char filter behavior for unresolved entries).

### DD-7: ALIAS TABLE INITIAL CONTENT = VN30 UNIVERSE ONLY (per parent AQ-9)

**Decision**: D1 seeds alias-table with VN30 universe only (~30 tickers per Charter § First Sub-Scope thin-slice anchor + glossary § VN30 entry). Each ticker gets ~3-5 aliases:
- Canonical 3-char symbol (e.g. "VHM")
- Lowercase variant ("vhm")
- Vietnamese full company name ("Vinhomes")
- Vietnamese formal name ("Công ty Cổ phần Vinhomes")
- Vietnamese abbreviated ("CTCP Vinhomes")
- Diacritics-stripped variant where applicable
- English variant where commonly used

Expansion path documented in alias-table footer + ADR D-073 revisit triggers.

**Rationale**: Per parent AQ-9 (VN30-only-v0 + extension path). Charter § First Sub-Scope thin-slice anchor. Hand-curatable in ~2 hours by project owner per dispatch brief CRITICAL option (a). E.4-V2 expansion trigger: alias-table grows to n>100 OR ≥3 unresolved production mentions surface.

**Adversarial alternate considered**: Seed with full HNX-30 + UPCoM universe (~150-200 tickers) → REJECTED per parent AQ-9 + § A.3 (premature scope expansion; v0 thin-slice anchor); seed with single-ticker test fixture only (no production aliases) → REJECTED (defeats Charter Principle 4 moat realization for v0 dogfood).

### DD-8: DIFFLIB CUTOFF = 0.85 ARCHITECT DEFAULT

**Decision**: `difflib.get_close_matches(cutoff=0.85, n=3)` for fuzzy fallback after exact + case-insensitive + diacritics-stripped match attempts fail.

**Rationale**: 0.85 balances recall (catches "vinhomes" → "Vinhomes" canonical at ratio ~0.86) vs precision (rejects "vincomeBank" from being unintentionally resolved to "VCB" via SequenceMatcher coincidence). EMPIRICAL test fixture in D3 validates this threshold against 15+ resolution test cases. Revisit trigger: D5 CLI smoke run shows <70% recall OR >5% false-positive on real VN news corpus (RM5).

**Adversarial alternate considered**: cutoff=0.6 (Python stdlib default) → REJECTED (too permissive; false-positive risk too high); cutoff=0.95 (very strict) → REJECTED (insufficient recall on common Vietnamese variants with diacritics drift).

---

## E. Sub-track Decomposition (D1-D5; per parent plan-028 DD-decomposition rhythm + plan-025 contract)

### D1: Hand-curate alias-table markdown for VN30 universe

- **parallel_with**: [] (foundation; D2 + D3 + D4 + D5 all depend on D1 alias-table existence)
- **blocks_on**: [] (root sub-track)
- **coordination_paths_exclusive**: [agent-workspace/ubiquitous-language/vn_ticker_aliases.md]
- **estimated_wall_min**: 6-8 min (hand-curation of ~30 tickers × ~3-5 aliases via project-owner knowledge of VN30 universe + glossary cross-reference)

**Scope**: Create NEW file `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` with VN30 universe seed (~30 tickers × ~3-5 aliases = ~100-150 entries) following UL glossary entry format pattern. Each entry block:
```markdown
### VHM
**Canonical ticker**: VHM
**Aliases**: vhm, Vinhomes, vinhomes, VINHOMES, Công ty Cổ phần Vinhomes, CTCP Vinhomes, Vin Homes
**Source**: HOSE listing (https://www.hsx.vn/Modules/Listed/Web/SymbolView?sym_idx=178) | **As-of**: 2026-05-17 | **BC**: BC-1
```

**Footer section**: Expansion-trigger documentation + revisit-trigger reference to ADR D-073 + AQ-9 path to E.4-V2.

### D2: VnTickerResolver concrete class + ResolutionResult dataclass + ResolutionMethod enum + alias-table parser

- **parallel_with**: [] (blocks D3 + D4 + D5)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [apps/_shared/entities/__init__.py, apps/_shared/entities/vn_ticker_resolver.py]
- **estimated_wall_min**: 12-15 min

**Scope**: Create NEW directory `apps/_shared/entities/` + NEW files:

**`apps/_shared/entities/__init__.py`** (~10 LOC):
```python
"""apps/_shared/entities — cross-app shared entity-resolution utilities."""
from apps._shared.entities.vn_ticker_resolver import (
    ResolutionMethod,
    ResolutionResult,
    VnTickerResolver,
)
__all__ = ["ResolutionMethod", "ResolutionResult", "VnTickerResolver"]
```

**`apps/_shared/entities/vn_ticker_resolver.py`** (~200 LOC):
- License header + module docstring citing parent plan-028 DD-6 + sub-plan-032 DD-1 + ADR D-073
- D-059 compliance comment
- `ResolutionMethod(StrEnum)` — 6 members: EXACT, CASE_INSENSITIVE, DIACRITICS_STRIPPED, FUZZY, AMBIGUOUS, UNKNOWN
- `ResolutionResult(frozen+slots dataclass)` — fields: `canonical_ticker: Ticker | None`, `resolution_method: ResolutionMethod`, `resolution_confidence: float` (in [0.0, 1.0], validated in __post_init__ mirroring SentimentScore pattern), `matched_alias: str`, `candidates: tuple[Ticker, ...]` (non-empty only when resolution_method=AMBIGUOUS), `alias_table_version: str`
- `_strip_diacritics(text: str) -> str` — stdlib unicodedata.normalize('NFD', text) + filter combining marks
- `_parse_alias_table(content: str) -> dict[str, Ticker]` — markdown regex parser; returns {alias_lowercase: Ticker}; canonical alias maps to canonical Ticker
- `VnTickerResolver(class)`:
  - `__init__(self, alias_table_path: Path | None = None)` — default = `agent-workspace/ubiquitous-language/vn_ticker_aliases.md`
  - `_aliases: dict[str, Ticker]` (loaded at construction time from markdown)
  - `_alias_table_version: str` (loaded from markdown header)
  - `_canonical_set: frozenset[str]` (canonical aliases for exact-match precedence)
  - `resolve(self, mention: str) -> ResolutionResult` — multi-stage resolution per DD-4 + DD-6:
    1. EXACT match (canonical 3-char Ticker pattern + alias-table lookup) → confidence=1.0
    2. CASE_INSENSITIVE match (mention.lower() in self._aliases) → confidence=1.0
    3. DIACRITICS_STRIPPED match (_strip_diacritics(mention.lower()) in stripped-alias-set) → confidence=0.95
    4. FUZZY match via difflib.get_close_matches(cutoff=0.85, n=3) → confidence = max SequenceMatcher.ratio() of best candidate
    5. AMBIGUOUS if multiple candidates within cutoff window AND no exact/case-insensitive/diacritics-stripped wins → resolution_confidence=0.0, candidates populated
    6. UNKNOWN if no match → confidence=0.0, canonical_ticker=None
- Module-level `_MIN_CONFIDENCE_THRESHOLD = 0.85` — exported as resolver default; consumers override per use case

### D3: Unit tests for VnTickerResolver

- **parallel_with**: [D4] (disjoint file scope: D3 = `apps/_shared/entities/test_vn_ticker_resolver.py`; D4 = `packages/infrastructure/news/`)
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/_shared/entities/test_vn_ticker_resolver.py]
- **estimated_wall_min**: 7-8 min

**Scope**: Create NEW file `apps/_shared/entities/test_vn_ticker_resolver.py` (~200 LOC) with ≥15 test cases:

| TC | Description | Expected ResolutionMethod | Expected confidence range |
|---|---|---|---|
| TC1 | EXACT canonical (`"VHM"`) | EXACT | 1.0 |
| TC2 | CASE_INSENSITIVE lowercase (`"vhm"`) | CASE_INSENSITIVE | 1.0 |
| TC3 | CASE_INSENSITIVE full name (`"Vinhomes"`) | CASE_INSENSITIVE | 1.0 |
| TC4 | CASE_INSENSITIVE Vietnamese formal (`"Công ty Cổ phần Vinhomes"`) | CASE_INSENSITIVE | 1.0 |
| TC5 | DIACRITICS_STRIPPED (`"Cong ty Co phan Vinhomes"`) | DIACRITICS_STRIPPED | 0.95 |
| TC6 | FUZZY typo (`"Vinhmoes"` 1-char swap) | FUZZY | 0.85-0.99 |
| TC7 | FUZZY spacing variant (`"Vin Homes"`) | FUZZY OR CASE_INSENSITIVE depending on alias-seeded | 0.85-1.0 |
| TC8 | AMBIGUOUS VIN-class (`"VIN"`) — multi-candidate fuzzy hit | AMBIGUOUS | 0.0 (candidates populated) |
| TC9 | UNKNOWN bogus mention (`"NotARealCompany"`) | UNKNOWN | 0.0 |
| TC10 | UNKNOWN too-short (`"V"`) | UNKNOWN | 0.0 |
| TC11 | UNKNOWN empty string (`""`) | UNKNOWN | 0.0 (handles edge case gracefully) |
| TC12 | EXACT precedence over FUZZY (`"FPT"` should EXACT-match even if other 3-char close matches exist) | EXACT | 1.0 |
| TC13 | Verify Ticker.symbol is canonical 3-char per ticker.py contract for ALL resolved canonical_ticker outputs | (each emits valid Ticker) | (validates schema preservation) |
| TC14 | Verify ResolutionResult is frozen (mutation raises) | N/A | N/A |
| TC15 | Verify alias_table_version preserved in result | (every result.alias_table_version matches loaded version) | N/A |
| TC16 | Verify cultural-name pattern resolves (`"vinhomes"` lowercase) — explicit dispatch-brief example | CASE_INSENSITIVE | 1.0 |
| TC17 | Verify difflib threshold (`"viz"` 2-char similarity but below cutoff) | UNKNOWN | 0.0 |
| TC18 (optional) | Verify diacritics edge case (mixed-case Vietnamese with mixed diacritics) | DIACRITICS_STRIPPED OR CASE_INSENSITIVE | 0.95-1.0 |

### D4: Surgical _build_claim edit + 3 new test cases in test_adapters.py

- **parallel_with**: [D3] (disjoint file scope: D4 = `packages/infrastructure/news/claude_llm_extractor.py` + `packages/infrastructure/news/test_adapters.py`; D3 = `apps/_shared/entities/`)
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [packages/infrastructure/news/claude_llm_extractor.py (surgical edit only at L238-241 + dataclass field add), packages/infrastructure/news/test_adapters.py (3 new test cases only)]
- **estimated_wall_min**: 6-8 min

**Scope** (per DD-5):

**Edit `packages/infrastructure/news/claude_llm_extractor.py`**:
1. ADD import: `from apps._shared.entities.vn_ticker_resolver import ResolutionMethod, VnTickerResolver` (after existing apps.extraction.sentiment import line)
2. ADD module-level constant: `_MIN_RESOLVER_CONFIDENCE_THRESHOLD = 0.85` (architect default per DD-8)
3. ADD dataclass field to `ClaudeLlmExtractor` (mirror existing tokenizer + lexicon DI pattern at L116-130):
   ```python
   ticker_resolver: VnTickerResolver | None = None
   ```
4. REPLACE filter logic at L238-241 — preserve overall tickers tuple build but route through resolver when injected:
   ```python
   raw_tickers = raw.get("mentioned_tickers", [])
   if self.ticker_resolver is None:
       # Backward-compat default: 2-4 char uppercase filter (existing behavior pre-E.4)
       tickers = tuple(
           Ticker(str(t)) for t in raw_tickers
           if isinstance(t, str) and t.isupper() and 2 <= len(t) <= 4
       )
   else:
       # E.4 resolver-injected path per plan-032 DD-5
       resolved: list[Ticker] = []
       for t in raw_tickers:
           if not isinstance(t, str):
               continue
           result = self.ticker_resolver.resolve(t)
           if (
               result.canonical_ticker is not None
               and result.resolution_method != ResolutionMethod.UNKNOWN
               and result.resolution_method != ResolutionMethod.AMBIGUOUS
               and result.resolution_confidence >= _MIN_RESOLVER_CONFIDENCE_THRESHOLD
           ):
               resolved.append(result.canonical_ticker)
       tickers = tuple(resolved)
   ```

**Add 3 new test cases to `packages/infrastructure/news/test_adapters.py`** (~+50 LOC):
- TC-D4-1: Existing test (no resolver injected, default None) preserves 2-4 char filter behavior (regression floor)
- TC-D4-2: Resolver-injected path resolves "vinhomes" lowercase mention → emits Ticker("VHM") in mentioned_tickers
- TC-D4-3: Resolver-injected path skips AMBIGUOUS mention (e.g. "VIN") silently — claim still emitted IF other valid tickers OR sectors present, else dropped per existing entity-grounding rule

### D5: Integration smoke + CLI ticker-resolve harness

- **parallel_with**: [] (sequential after D2)
- **blocks_on**: [D2]
- **coordination_paths_exclusive**: [apps/cli/resolve_vn_tickers.py]
- **estimated_wall_min**: 4-5 min

**Scope**: Create NEW file `apps/cli/resolve_vn_tickers.py` (~80 LOC):
- click CLI with subcommands `--from-stdin` (read mention per line) + `--from-html-dir <path>` (scan article body excerpts via existing data/raw/news/**/*.html or via SqliteNewsRepository)
- For each mention OR scanned candidate string: invoke `VnTickerResolver().resolve(mention)`; dump JSON line `{mention, resolution_method, resolution_confidence, canonical_ticker, matched_alias, candidates}`
- Exit code 0 always (smoke harness; no business assertion); stderr summary stats (total mentions / EXACT count / FUZZY count / AMBIGUOUS count / UNKNOWN count)
- Honors Principle 7 dogfood mandate: must run on ≥5 real-text snippets per § STEP 0.8

---

## F. Definition of Done (DC-1..DC-N; ≥25 items per plan-025 floor)

DoD for THIS sub-plan IMPL session (S371):

- [ ] **DC-1** — D1: `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` exists with VN30 universe seed (~30 tickers × ~3-5 aliases)
- [ ] **DC-2** — D1: Alias-table file uses UL glossary entry pattern (Canonical ticker + Aliases + Source URL + As-of + BC)
- [ ] **DC-3** — D1: Alias-table file footer documents E.4-V2 expansion trigger + ADR D-073 reference
- [ ] **DC-4** — D2: `apps/_shared/entities/__init__.py` exists with VnTickerResolver + ResolutionResult + ResolutionMethod exports
- [ ] **DC-5** — D2: `apps/_shared/entities/vn_ticker_resolver.py` exists (~200 LOC; license header + module docstring cites plan-032 DD-1 + ADR D-073)
- [ ] **DC-6** — D2: `ResolutionMethod(StrEnum)` has all 6 members: EXACT, CASE_INSENSITIVE, DIACRITICS_STRIPPED, FUZZY, AMBIGUOUS, UNKNOWN
- [ ] **DC-7** — D2: `ResolutionResult` dataclass is frozen+slots with required fields per DD-2
- [ ] **DC-8** — D2: `VnTickerResolver.resolve()` honors 6-stage resolution per DD-4 + DD-6
- [ ] **DC-9** — D2: difflib.get_close_matches(cutoff=0.85, n=3) per DD-8 (verifier grep-asserts cutoff value)
- [ ] **DC-10** — D2: Rule 16 mode 2 satisfied for resolution_confidence (pure-function; no LLM in resolver path)
- [ ] **DC-11** — D2: D-059 R1+R2+R4 compliance (no datetime.now() / no unseeded random / no time.time() in domain)
- [ ] **DC-12** — D2: I-S34 grep-clean (no patchright/playwright_stealth/fake-useragent/StealthyFetcher introduced)
- [ ] **DC-13** — D2: alias_table_version field preserved per I-S22 lineage
- [ ] **DC-14** — D3: `apps/_shared/entities/test_vn_ticker_resolver.py` exists with ≥15 test cases per § E D3 TC1-TC17 table
- [ ] **DC-15** — D3: Cultural-name pattern test TC16 passes (`"vinhomes"` lowercase → Ticker("VHM"))
- [ ] **DC-16** — D3: AMBIGUOUS test TC8 passes (VIN-class returns AMBIGUOUS without silent pick)
- [ ] **DC-17** — D3: All 15+ tests PASS under pytest
- [ ] **DC-18** — D4: `packages/infrastructure/news/claude_llm_extractor.py` ticker_resolver field added with default=None
- [ ] **DC-19** — D4: _build_claim filter refactored per DD-5; backward-compat path preserved when ticker_resolver=None
- [ ] **DC-20** — D4: 3 new test cases (TC-D4-1/2/3) added to test_adapters.py; ALL PASS
- [ ] **DC-21** — D4: Existing test_adapters.py extractor tests CONTINUE TO PASS (regression floor; 1085+/1085+ post-S368 baseline preserved)
- [ ] **DC-22** — D5: `apps/cli/resolve_vn_tickers.py` exists (~80 LOC)
- [ ] **DC-23** — D5: CLI smoke run on ≥5 real-text snippets passes (Principle 7 dogfood mandate per § STEP 0.8); results recorded in observation file
- [ ] **DC-24** — ADR D-073 PROPOSED at `agent-workspace/memory/decisions/073-vn-ticker-resolver.md` (~100 LOC; records resolver design + alias-table source + difflib threshold + ambiguity policy + revisit triggers)
- [ ] **DC-25** — Observation file at `agent-workspace/memory/observations/sandwich-dev-S371-vn-ticker-resolver.md` (~150-200 LOC; records VBW reads + STEP 0 results + dogfood smoke + alias-table seeding decisions + S371 self-report)
- [ ] **DC-26** — Session log at `agent-workspace/memory/sessions/2026-05-17-session-371.md` per CLAUDE.md § Session Protocol End
- [ ] **DC-27** — Mistake-log digest entry (M-S371-N if mistakes; OR explicit "no mistakes" statement)
- [ ] **DC-28** — Gates: mypy --strict PASS / ruff PASS / pytest 1100+/1100+ PASS (1085 baseline + 15 D3 + 3 D4 = 18 new = 1103+; 0 regressions)
- [ ] **DC-29** — Charter compliance: 0 charter writes / 0 constitution writes / 0 human-workspace writes UNLESS § M CHARTER-TIER GATE Rule 17 STOP-AND-ASK fires
- [ ] **DC-30** — Rule 16 mode 2 verifier grep-clean (resolution_confidence pure-function; no LLM in resolver path)
- [ ] **DC-31** — I-S1 + I-S2 + I-S22 + I-S34 + I-S35 satisfied by construction
- [ ] **DC-32** — D-060 commit boundary respected (dev MAY commit; dev MUST NOT push)
- [ ] **DC-33** — Phase E DONE attestation surface in S371 close section per § N

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Does resolver depend on sub-plan 029 tokenizer or sub-plan 030 lexicon?

**Answer**: NO STRICT DEPENDENCY. Resolver works on raw text input (mention strings from LLM JSON `mentioned_tickers` field). OPTIONAL fixture in D3 can use VnTokenizer output to verify multi-syllable VN company-name resolution (e.g. "Công_ty_Cổ_phần_Vinhomes" tokenized), but resolver itself does NOT inject tokenizer. Per parent plan-028 § E sub-plan 032 `blocks_on=[029]` notes "E.4 benefits from but does NOT strictly depend on E.2; E.4 alias table is independent of lexicon".

### AQ-2 — Should ResolutionResult.resolution_confidence persist on ExtractedClaim?

**Answer**: NO for v0. Persistence deferred per § A.3 OUT-of-scope (adds D-062 atomic-write + storage cost; resolution audit trail is transient during extraction). Revisit at E.4-V2 if production audit query surfaces need. Per DD-4.

### AQ-3 — What if difflib cutoff = 0.85 proves wrong on real corpus?

**Answer**: D5 CLI smoke run measures recall + false-positive rate on real VN news corpus. If recall <70% OR false-positive >5%, ADR D-073 revisit trigger fires; cutoff tuned in subsequent calibration cycle. Per DD-8 + RM5.

### AQ-4 — Why class not Protocol for VnTickerResolver?

**Answer**: Per DD-2. Karpathy P2 simplicity; no swap requirement for v0; Protocol-ification = AP-23 first-instance HOLD pending second backend (spaCy NER / transformer) per AQ-9 trigger.

### AQ-5 — What if alias-table file load fails at runtime?

**Answer**: Resolver `__init__` raises FileNotFoundError if alias_table_path does not exist; raises ValueError if markdown parser cannot parse. Consumers (ClaudeLlmExtractor) MUST handle construction errors at app startup; default DI `ticker_resolver=None` preserves backward-compat for cases where resolver construction fails / is intentionally skipped.

### AQ-6 — Why _MIN_CONFIDENCE_THRESHOLD = 0.85?

**Answer**: Per DD-8. Empirical balance: 0.85 catches diacritics-stripped + minor typo variants ("Vinhmoes" → VHM at ratio ~0.86) while rejecting nonsense matches ("vincomeBank" → VCB at ratio ~0.6). D3 TC6+TC7+TC17 test fixtures validate this threshold. Revisit trigger via D5 CLI smoke metrics.

### AQ-7 — What if alias-table needs expansion mid-flight?

**Answer**: Per parent AQ-9. Alias table is markdown source-of-truth at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md`; expansion = append-only edit; recompile-by-test (resolver reloads on next instantiation). v0 ships VN30 universe; expansion to broader universe = E.4-V2 follow-on (revisit trigger: alias-table grows to n>100 OR unresolved-ticker surfaces in production).

### AQ-8 — Does sub-plan 032 ship the resolver into existing CLI ingest_news_*?

**Answer**: NO for v0 production wiring change. D4 surgical edit ADDS the ticker_resolver field with default=None; CLI ingest_news_* continues to call `ClaudeLlmExtractor()` no-arg (no production wiring change). Future production wiring at apps/cli/ingest_news_*.py = separate ADR-tracked decision when alias-table coverage validates against real corpus. Reduces risk of v0 alias-table gaps silently dropping previously-emitted tickers.

### AQ-9 — Why VN30 only, not broader universe?

**Answer**: Per parent AQ-9 + Charter § First Sub-Scope thin-slice anchor + glossary § VN30. Hand-curatable in ~2 hours by project owner. Broader universe (HNX-30 + UPCoM full) = E.4-V2 trigger. Per DD-7.

### AQ-10 — What if Rule 17 ambiguity policy gate fires?

**Answer**: Per § M CHARTER-TIER GATE + STEP 0.3. LIKELY-VERY-LOW likelihood because DD-6 AMBIGUOUS-explicit-surface posture preserves I-S22 data lineage without requiring new charter rule. If gate fires (e.g. user demands stricter "block downstream entirely" policy), dev writes STOP-FINDING file with 4 options (a/b/c/d per § STEP 0.3); main session dispatches AskUserQuestion; ADR drafted separately; sub-plan 032 IMPL pauses cleanly.

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (parent plan E.4 + DD) | Source 2 (Phase E precedent sub-plan) | Source 3 (existing stockforge code / contract) | Source 4 (Python stdlib / library) | Source 5 (skill / pattern) |
|---|---|---|---|---|---|---|
| 1 | DD-1 FRESH MODULE + ALIAS TABLE | parent plan-028 § E.4 + DD-6 (canonical decomposition source) | sub-plan 029 D2 fresh-module pattern at packages/infrastructure/nlp/vn_tokenizer.py (precedent) | packages/contracts/types/ticker.py:36-62 (Ticker preserved schema target) | Python stdlib `unicodedata.normalize` (diacritics handling) | .claude/skills/ddd-tactical-patterns/SKILL.md (Value Object discipline + Adapter pattern) |
| 2 | DD-2 CONCRETE CLASS not Protocol | parent plan-028 § E.4 + AQ-9 (no swap requirement for v0) | sub-plan 029 DD-1 selected Protocol because of documented swap path (underthesea/pyvi/fallback); inverse argument applies here | (no existing resolver Protocol in stockforge — clean baseline confirmed via Grep) | Python concrete class semantics (no Protocol overhead) | Karpathy P2 simplicity (constitution / karpathy-principles.md) + AP-23 first-instance HOLD discipline |
| 3 | DD-3 MARKDOWN alias table | parent plan-028 § E.4 (alias table mention; format not specified) | sub-plan 030 DD-5 Python dict literal pattern (inverse for lexicon; rationale for divergence documented in DD-3) | agent-workspace/ubiquitous-language/glossary.md § Ticker + § VN30 (UL entry pattern) | Python stdlib `re` (markdown parser) | UL glossary precedent (curatable-by-domain-experts pattern; per AOM ubiquitous-language section) |
| 4 | DD-6 AMBIGUOUS-explicit-surface | parent plan-028 § K.2 anticipated FLAG for sub-plan 032 + AQ-9 | sub-plan 030 cultural-anchor extraction precedent (deterministic frozenset intersection; no silent-pick) | constitution/invariants.md I-S22 (data lineage discipline) | Python stdlib difflib.get_close_matches (cutoff parameter) | Charter Principle 8 (calibration over confidence — empirical AMBIGUOUS rate measurable in E.4-V2) |
| 5 | DD-5 surgical _build_claim edit | parent plan-028 § E.4 + DD-6 step 4 + dispatch brief item 5 + S369 verifier risk-area 5 | sub-plan 031 DD-1 AUGMENT precedent (existing-extractor-augment-not-replace pattern) | packages/infrastructure/news/claude_llm_extractor.py:238-241 (surgical edit target; current 2-4 char filter) | Python `isinstance` + dataclass field default = None (DI graceful degradation pattern) | L-S345-3 single-helper-with-keyword-only-flag precedent (backward-compat via default arg) |

---

## J. Risks & Mitigation (RM1-RM10)

### RM1 — VN30 alias-table coverage gap on first dev cycle (LIKELY-MEDIUM)
**Risk**: D1 hand-curated VN30 alias set may miss common cultural variants (e.g. "Hòa Phát" vs "Hoà Phát" diacritics edge); D5 CLI smoke surfaces gap.
**Mitigation**: D3 TC18 explicit diacritics edge case; D5 smoke run is dogfood checkpoint; gap → add aliases to markdown (append-only); revisit trigger via AQ-7 + RM4.

### RM2 — Rule 17 charter-tier surface mid-flight (LIKELY-VERY-LOW)
**Risk**: Sub-plan 032 STEP 0.3 surfaces a case where AMBIGUOUS-explicit-surface is insufficient per dispatch brief CRITICAL.
**Mitigation**: § M CHARTER-TIER GATE pre-answered with 4 options (a/b/c/d); STOP-AND-ASK file template at human-workspace/notifications/STOP-FINDING-S371-rule-17-ambiguity-policy.md; main session dispatches AskUserQuestion; ADR drafted separately; sub-plan 032 IMPL pauses cleanly.

### RM3 — Surgical _build_claim edit causes existing test regression (LIKELY-LOW; mitigated by DD-5 DI default=None)
**Risk**: D4 _build_claim edit breaks existing test_adapters.py:257-348 fixtures that use Ticker("VHM") construction expectations.
**Mitigation**: DD-5 DI default=None preserves backward-compat; existing tests inject NO ticker_resolver kwarg = fallback to 2-4 char filter = current behavior; 1085/1085 post-S368 baseline preserved; TC-D4-1 validates this.

### RM4 — Alias-table version drift mid-flight (LIKELY-LOW)
**Risk**: Alias-table markdown edited mid-Phase-F without bumping version metadata → resolver picks up new aliases without observability.
**Mitigation**: ADR D-073 § Operational specifies version-bump-on-edit discipline; alias_table_version field preserved in ResolutionResult per DD-2 + I-S22; revisit trigger if 2+ silent-version-drift incidents.

### RM5 — difflib cutoff = 0.85 wrong on real corpus (LIKELY-MEDIUM)
**Risk**: D5 CLI smoke surfaces <70% recall OR >5% false-positive on real VN news corpus → cutoff tuning needed.
**Mitigation**: ADR D-073 revisit trigger documents threshold tuning path; D5 records empirical metrics in observation; if surfaced mid-flight, S371 dev can adjust cutoff inline (architect-default 0.85 is hypothesis NOT mandate).

### RM6 — Ticker.symbol access pattern discovery (LIKELY-LOW; mitigated by VBW STEP 0.1)
**Risk**: S368 dev surfaced Ticker.value → Ticker.symbol fix per current-execution.md S368 row; S371 dev may surface similar attribute-access discovery on Ticker schema.
**Mitigation**: STEP 0.1 mandates full read of `packages/contracts/types/ticker.py`; D3 TC13 explicit validation of Ticker.symbol canonical 3-char output; verifier S372 grep-asserts Ticker construction usage.

### RM7 — apps/_shared/entities/__init__.py + namespace creation risk (LIKELY-LOW)
**Risk**: Creating new namespace directory may surface mypy --explicit-package-bases issues (per S369 verifier F2 carry-forward — mypy duplicate-module-name infra issue).
**Mitigation**: STEP 0 confirms apps/_shared/entities/ does NOT exist; D2 creates with __init__.py mirroring existing apps/_shared/crawl/ pattern; mypy individual-file PASS continues to work even if multi-dir invocation has pre-existing issues per S369 F2 (NOT a sub-plan 032 regression).

### RM8 — Alias-table markdown parser edge case (LIKELY-LOW)
**Risk**: Hand-curated markdown may have edge-case formatting (extra whitespace; trailing comma; unicode quotation marks) that simple regex parser misses.
**Mitigation**: D2 parser uses lenient stdlib regex; D3 TC15 validates parsed alias_table_version; D5 smoke surfaces silent-parse-fail; D1 markdown follows UL glossary entry format strictly (verifier S372 spot-checks format compliance).

### RM9 — Sub-plan 031 transport flip + sub-plan 032 _build_claim edit interaction (LIKELY-VERY-LOW)
**Risk**: D4 edits same file (claude_llm_extractor.py) where sub-plan 031 transport flip + lexicon DI shipped at S368; surface uncovered interaction.
**Mitigation**: STEP 0.1 reads current claude_llm_extractor.py state empirically; DD-5 surgical edit at L238-241 ONLY (not near transport at L116-130 NOR lexicon DI at L192-210); verifier S369 confirmed claude_llm_extractor.py at 289 LOC post-S368 = stable baseline; surgical Karpathy P3 edit ≤+15 LOC.

### RM10 — Phase E DONE attestation regression (LIKELY-VERY-LOW)
**Risk**: Sub-plan 032 ships but inadvertently breaks sub-plan 029/030/031 verifier-confirmed shipped state (e.g. accidental Ticker schema drift, alias-table file location collision with existing UL glossary entry).
**Mitigation**: STEP 0.1 + STEP 0.5 grep-clean confirms no collision; D3 + D4 test fixtures preserve existing extractor/lexicon/tokenizer DI graph; verifier S372 explicitly attests Phase E DONE status per § N (regression scope = full E.1-E.4 chain validation).

---

## K. Coordination paths off-limits (during S371 IMPL window)

When main session dispatches S371 dev FOCUSED_IMPL, main session SHOULD avoid (read-only or no-touch):

- `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (D1 writes)
- `apps/_shared/entities/__init__.py` (D2 writes)
- `apps/_shared/entities/vn_ticker_resolver.py` (D2 writes)
- `apps/_shared/entities/test_vn_ticker_resolver.py` (D3 writes)
- `packages/infrastructure/news/claude_llm_extractor.py` (D4 surgical edit)
- `packages/infrastructure/news/test_adapters.py` (D4 3 new test cases only — main session may read other test cases READ-ONLY)
- `apps/cli/resolve_vn_tickers.py` (D5 writes)
- `agent-workspace/memory/decisions/073-vn-ticker-resolver.md` (ADR D-073 writes)
- `agent-workspace/memory/observations/sandwich-dev-S371-vn-ticker-resolver.md` (dev observation writes)
- `agent-workspace/memory/sessions/2026-05-17-session-371.md` (dev session log writes)
- `human-workspace/notifications/STOP-FINDING-S371-*` (conditional; only if § M CHARTER-TIER GATE triggers fire)

Coordination paths beyond S371 IMPL apply per S372 verifier session and are documented at that verifier observation.

---

## L. Conditional next-step

After S371 dev IMPL completes:

- **L.1 (CLEAN PATH; LIKELY-HIGH)**: All 33 DoD PASS + 0 STOP-AND-ASK triggers + dogfood smoke green → main session dispatches S372 sandwich-verifier (AP-1 fresh-context; ~30-60K Opus VERIFY budget) → upon PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES → plan mv pending → completed + Phase E DONE attestation per § N + Phase F-prime master-plan dispatch unblocked
- **L.2 (CHARTER-TIER GATE PATH; LIKELY-VERY-LOW)**: STEP 0.3 Rule 17 trigger fires → dev writes STOP-FINDING-S371-rule-17-ambiguity-policy.md + HALTS → main session dispatches AskUserQuestion gate with 4 options (a/b/c/d per § STEP 0.3 + § M) → user picks → ADR drafted separately → S371 IMPL re-dispatched post-gate per user pick
- **L.3 (DOGFOOD-FAIL PATH; LIKELY-LOW)**: D5 smoke reveals <70% recall on real corpus → architect-default cutoff 0.85 retained for v0 ship WITH explicit "EMPIRICAL-RECALL-LOW-V0" comment in resolver class docstring + ADR D-073 revisit-trigger fires for E.4-V2 cycle → main session may dispatch tuning sub-session OR ship-as-is per Charter Principle 8 (calibration cycle continues)
- **L.4 (REGRESSION PATH; LIKELY-VERY-LOW)**: D4 surgical edit causes existing test_adapters.py regression → dev INLINE-RESOLVES per VBW STEP 0 + commits hot-fix + re-runs gates → upon green proceed to L.1

---

## M. CHARTER-TIER GATE clause (Rule 17 anticipated flag — LIKELY-VERY-LOW)

Per dispatch brief CRITICAL Rule 17 considerations + parent plan-028 § K.2 anticipated FLAG for sub-plan 032.

### M.1 Anticipated FLAG: Rule 17 entity-ambiguity-disambiguation policy

**Question**: Does ticker alias resolution require explicit Rule 17 (disambiguation policy for cases like VIN → Vingroup vs Vinaconex)?

**Analysis** (per § STEP 0.3 detailed):

- ✅ Existing financial-data-protocol.md Rules 1-16 cover sentiment + numeric + provenance + LLM-math; ZERO existing rule for entity-ambiguity-disambiguation
- ✅ DD-6 ambiguity policy = AMBIGUOUS-explicit-surface (not silent-pick) — preserves I-S22 data lineage WITHOUT new Rule 17
- ✅ _build_claim treats AMBIGUOUS as 'skip' (matches current 2-4 char filter behavior for unresolved entries) — no charter-tier behavioral change vs status quo
- ✅ ResolutionResult.candidates: tuple[Ticker, ...] preserves audit trail when AMBIGUOUS occurs — verifier sampling can inspect via observation log
- **LIKELIHOOD assessment: LIKELY-VERY-LOW** that Rule 17 needs to ship for v0; existing I-S22 + Rule 16 mode 2 + AMBIGUOUS-explicit-surface covers documented v0 scope

### M.2 STOP-AND-ASK trigger template

If S371 dev STEP 0.3 surfaces a case where AMBIGUOUS-explicit-surface is insufficient AND user requires a project-binding policy, dev writes `human-workspace/notifications/STOP-FINDING-S371-rule-17-ambiguity-policy.md`:

```markdown
---
finding_id: STOP-FINDING-S371-rule-17-ambiguity-policy
severity: CHARTER-TIER (potential I-S<N> introduction)
status: pending-user-ratification
authored_by: sandwich-dev S371 (background agent)
authored_at: 2026-05-17
---

# Rule 17 Ambiguity Policy — STOP-AND-ASK

## Context
[Describe ambiguity case that surfaced — e.g. VIN-class mention or other empirical edge case]

## Options for user ratification

- **(a)** DD-6 AMBIGUOUS-explicit-surface preserved (no new charter rule; sub-plan 032 IMPL ships as planned with skip-on-AMBIGUOUS in _build_claim)
- **(b)** **Rule 17 PROPOSED (PERMISSIVE)**: "Entity-resolution ambiguity MUST surface via ResolutionResult.AMBIGUOUS without silent-pick; consumers decide skip-vs-emit-all-candidates policy per use case"
- **(c)** **Rule 17 PROPOSED (STRICT)**: "Entity-resolution ambiguity MUST block downstream emission entirely; ExtractedClaim with ambiguous ticker mention is rejected at validation time"
- **(d)** Defer to E.4-V2 calibration cycle after empirical ambiguity rate measured on real VN corpus
```

### M.3 Ratification path if FLAG fires

1. S371 dev STEP 0.3 STOP-AND-ASK fires → writes STOP-FINDING file → HALTS sub-plan 032 IMPL
2. Main session detects file via existing watchdog → dispatches AskUserQuestion gate with 4 options
3. User picks (a/b/c/d) → if (b) or (c): ADR drafted at proposal/ tier → cool-down per severity-schema → constitution amendment landed by separate user-ratified PLAN+IMPL pair
4. Sub-plan 032 IMPL re-dispatched post-gate per user pick — adjusts ambiguity-handling per ratified policy

### M.4 Alias-table-source charter-tier consideration (separate from Rule 17)

Per dispatch brief CRITICAL alias-table-source options:
- (a) Project owner manually curates — IS the v0 default per § STEP 0.2 + DD-7 (no charter-tier issue)
- (b) HSX listing as authoritative source — DEFER per § A.3 (license + reliability audit out-of-scope v0; NOT a charter-tier issue per se but would become one if E.4-V2 HSX scraping pulls in license-restricted content)
- (c) Drop ambiguous tickers silently — REJECTED per DD-6 (no charter-tier issue; just architectural rejection)
- (d) NEW Rule 17 invariant — § M.1 above (LIKELY-VERY-LOW)

**No alias-table-source charter-tier FLAG at v0** — option (a) IS the default per § STEP 0.2 architect-decision.

---

## N. Phase E DONE attestation + Phase F-prime entry recommendation

### N.1 Phase E DONE attestation contract

After S372 sandwich-verifier returns PASS-WITH-CONCERNS / MERGE-ELIGIBLE: YES on sub-plan 032 (per L.1 CLEAN PATH), main session SHALL:

1. **Move sub-plan 032 to completed/**: `git mv agent-workspace/session-plans/pending/032-S370-phase-e4-vn-ticker-resolver.md agent-workspace/session-plans/completed/`
2. **Verify full Phase E chain ship state**:
   - ✅ sub-plan 029 E.1 Tokenization (SHIPPED S362 + VERIFIED S363; D-070 PROPOSED; pyvi==0.1.1)
   - ✅ sub-plan 030 E.2 Sentiment Lexicon (SHIPPED S365 + VERIFIED S366; D-071 PROPOSED; UNCALIBRATED-V0)
   - ✅ sub-plan 031 E.3 Claim Extraction Wrapper (SHIPPED S368 + VERIFIED S369 PASS-WITH-CONCERNS / MERGE-ELIGIBLE; D-072 PROPOSED; transport flip news-side)
   - ✅ sub-plan 032 E.4 VN Ticker Resolver (SHIPPED S371 + VERIFIED S372; D-073 PROPOSED; VN30 universe v0)
3. **Append Phase E DONE row to current-execution.md** documenting:
   - Phase E ship date + 4 sub-plan completion summary + 4 ADR PROPOSED references
   - Cumulative Phase E budget actual vs envelope projection (per parent plan ~720-1150K projection)
   - n=4 vietnamese-nlp-impl task_class precedent for future Phase F-prime / G-prime planning
   - Carry-forward harness anomalies (.planner-stats.tsv L-S354-2 + L-S366-4 + L-S369-1 D-052 cleanup)
4. **Update agent-workspace/memory/project.md** Phase Goals Tracker if Phase E phase status was tracked there (per CLAUDE.md § End Session step 7 + phase-status-coherence.sh enforcement)

### N.2 Phase F-prime entry recommendation

Per parent plan-028 § M.1 critical-path analysis:
- **Phase F-prime Theme H (BC-8 multi-perspective primitives)** is INDEPENDENT of Theme I substrate; depends on Phase C Theme G ratification (already done D-065)
- **Phase F-prime master-plan dispatch UNBLOCKED at sub-plan 032 VERIFY close** per § E sequencing
- **Recommended next session**: S373+ main session dispatches sandwich-architect for Phase F-prime PHASE-MASTER-PLAN (mirrors plan-028 architectural rhythm; budget envelope per recalibrated CLAUDE.md ~150-230K Opus PLAN; cold-start declared for task_class="multi-perspective-plan")
- **Phase F-prime entry-point dispatch brief template**: cite parent master plan § 6.4.3 + Phase E DONE attestation + Charter Principle 5 (Adversarial-by-default) + I-S10 (Bear Case mandatory) — provides authoring substrate for master-planner-A-01-deepdive-ai-hedge-fund § C9 Buffett-rubric tier mapping pattern

### N.3 Cumulative Phase E ship metrics (project-into-future per § N.1.3 contract)

Pre-S371 ship projection (architect estimate for S371 close):
- **Cumulative Phase E budget actual**: ~520-700K Opus across 9 sessions (S360 master + S361/362/363 E.1 + S364/365/366 E.2 + S367/368/369 E.3 + S370/371/372 E.4) — **WITHIN parent projection 720-1150K** because n=3 vietnamese-nlp-impl precedent fit lower-band envelope per § A.4 calibration
- **Total tests**: ~1103+/1103+ post-S371 (1085 post-S368 + 15 D3 + 3 D4)
- **Total ADRs PROPOSED**: D-070 + D-071 + D-072 + D-073 (4 ADRs; severity-schema auto-ratifies on commit)
- **Total production files shipped**: ~12-15 NEW + ~3-5 MODIFIED across Phase E
- **0 charter writes / 0 constitution writes**: maintained across entire Phase E (modulo conditional STOP-FINDING files per § M which are human-workspace not charter)

---

## P. Compliance attestation (sub-plan author session S370)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work — L-S354-2 + L-S366-4 + L-S369-1 carry-forward as harness-sweep candidates; explicitly NOT fixed here per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 30 source files read empirically)
- AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; 17 OUT-of-scope items + 10 RMs all with named triggers)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED for first-instance HOLD; promotion-on-2nd-recurrence calculus respected; DD-2 ResolverProtocol-deferral = first-instance HOLD)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session dispatches S371 dev per § L sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing recommendation in § L is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-066 not touched (Phase D Theme L closed; Theme I-E.4 consumes adapter output without modification)
- D-070 + D-071 + D-072 not touched (sub-plans 029/030/031 SHIPPED + VERIFIED; sub-plan 032 IMPORTS dependencies via DI only)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is CONDITIONAL S371 dev write per § M)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- I-S1 ✓ (this plan PROMOTES I-S1 satisfaction in resolver implementation; does not violate)
- I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- I-S22 ✓ (resolver ResolutionResult preserves resolution_method + resolution_confidence + matched_alias + alias_table_version per data lineage discipline)
- I-S34 ✓ (no new HTTP fetcher; HARD REJECT carried forward in binding_decisions + STEP 0.6)
- I-S35 ✓ (resolver = transform utility not recommendation; research-aid framing preserved)
- Phase 1b CONSUMED variant per § A.4 (n=3 vietnamese-nlp-impl precedent; cold-start window CLOSED per agent-template L65 threshold)
- 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- Rule 17 charter-tier-surface gate documented per § M (LIKELY-VERY-LOW likelihood; STOP-AND-ASK template ready)
- Phase E DONE attestation contract documented per § N (Phase F-prime entry recommendation included)
- 8 DD architecture decisions (DD-1..DD-8) all with rationale + adversarial alternates
- 5 sub-tracks D1-D5 with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- 33 DC DoD items (≥25 floor satisfied per plan-025)
- 10 AQ pre-answered (AQ-1..AQ-10)
- 10 RM entries with mitigation (RM1..RM10)

---

**END OF SUB-PLAN 032-S370-PHASE-E4-VN-TICKER-RESOLVER**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches sub-plan 032 IMPL dev at S371 per § L sequencing. Upon S372 verifier PASS → Phase E DONE attestation per § N + Phase F-prime master-plan dispatch unblocked.
