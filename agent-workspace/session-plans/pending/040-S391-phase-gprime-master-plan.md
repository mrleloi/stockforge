---
plan_id: 040-S391-phase-gprime-master-plan
target_session: S391 (THIS PLAN — Phase G-prime master plan authoring; sub-plans dispatched per § N sequencing in S392+)
type: PHASE-MASTER-PLAN (decomposes Phase G-prime into 4 follow-on per-sub-track PLAN+IMPL+VERIFY chains; NOT a single FOCUSED_IMPL plan per CLAUDE.md § Session Types "never mix PLAN+IMPL")
budget: master-plan authoring envelope ~150-200K Opus PLAN (THIS SESSION — architect; cold-start declared for task_class="pdf-extraction-master-plan"); subsequent per-sub-track PLAN sessions ~50-80K each; per-sub-track IMPL sessions ~100-150K each; per-sub-track VERIFY ~30-60K each
phase: G-prime (Theme J — PDF + table extraction BC-2; pre-authorized PARALLEL with Phase F-prime per parent plan-033 § N table line "PARALLEL with Phase F-prime after sub-plan 034 close — architect-tier parallel-dispatch precedent S345 4-parallel supports this"; Phase F-prime CODE-DONE-DATA-PENDING at S386 per current-execution.md:166)
track: Wave 1 Theme J — PDF + table extraction for BC-2 Fundamental ingestion (target: PdfTableExtractorPort + 2-3 candidate adapters + first VHM annual-report dogfood)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.5 (Theme J definition) + § 6.4.4 (Phase G-prime slot) + agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § J (Theme J final architectural recommendation with 2 candidate adapters)
predecessor: 033-S373-phase-fprime-multi-perspective-master-plan § N parallel-dispatch authorization (Phase G-prime "Can dispatch PARALLEL with Phase F-prime after F.1 ships [sub-plan 034 close] — architect-tier parallel-dispatch precedent (S345 4-parallel) supports this; G-prime authoring is independent file scope"); Phase F-prime CODE-DONE-DATA-PENDING gate satisfied at S386 commit 90b27db; harness sweep N+1 SHIPPED at S390 commit e5f17cf
successor: TBD — per § N decomposition 4 follow-on per-sub-track plans 041/042/043/044 (tentatively S392/S395/S398/S401 per-sub-track entry sessions; verifier sessions interleaved; sequencing per § E + § N)
architect: S391 sandwich-architect (background; THIS PHASE-MASTER-PLAN)
dispatched_by: main session orchestrating Phase G-prime entry per parent plan-033 § N pre-authorized parallel-dispatch window; current-execution.md:160 "Next-turn priority: ... OR Phase G-prime architect dispatch (parallel-eligible per architect-design intent)"
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect / master-planner subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **COLD-START declared** for task_class="pdf-extraction-master-plan" per L-S354-2 + L-S366-4 + L-S369-1 cascade carry-forward — no precedent in .planner-stats.tsv or sessions-rollup.tsv for PDF/table-extraction-shaped work; nearest analog crawler-adapter-impl n=3 from S338/S344/S354 + vietnamese-nlp-plan n=1 from S360 but PDF presentation-layer-extraction-shape is fundamentally different from HTML-extraction-shape and NLP-substrate-shape)
executing_agent: N/A this session (architect); subsequent per-sub-track dispatches per § N
status: pending-execution (Phase G-prime master plan ratification path; main session reviews + dispatches first follow-on plan-041 per § N sequencing)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master-plan-033 § N parallel-dispatch authorization (Phase G-prime parallel-eligible window OPENED at sub-plan 034 close S376 commit; Phase F-prime CODE-DONE-DATA-PENDING at S386 commit 90b27db satisfies the gate)"
  - "Master plan 2026-05-15-wave-1-research-integration.md § 5.5 Theme J slot (1 PLAN; IMPL deferred to Phase 2 entry) — THIS plan EXTENDS to 4 sub-plans (PLAN + 2 IMPL + 1 dogfood) per the supplement § J empirical refinement that surfaced 2 candidate adapters needing per-adapter IMPL slots"
  - "Supplement § J final architectural recommendation (J.3: PdfTableExtractorPort + 2 candidate adapters: pure-Python pdfplumber+camelot for digital PDFs + LLM-assisted Claude vision for scanned PDFs; J.5: I-S1 audit — LLM extracts NUMBERS-AS-CHARACTERS (OCR), NOT compute/derive numbers; deterministic post-OCR validation gate)"
  - "Supplement § J.2 (crawl4ai PDFContentScrapingStrategy + NaivePDFProcessorStrategy at `C:/htdocs/research/crawl4ai/crawl4ai/processors/pdf/processor.py:1-100` — Strategy ABC + pypdf-based naive impl producing PDFProcessResult(metadata, pages, processing_time); NAIVE IMPL INSUFFICIENT FOR VN BROKER REPORTS — strategy shape is reusable, concrete impl is not)"
  - "D-061 § Decision item 6 (Theme J PLAN-only in Wave 1; IMPL deferred to Phase 2 entry — supplement § J refines this by surfacing the 2-adapter shootout; main session ratifies the IMPL-slot extension via Q-INT-2026-05-G-prime-1 in § K.1 OR overrides via NON-BLOCKING design)"
  - "D-065 (Theme G I-S1-1 Rule 16 numeric-field discipline — ACCEPTED 2026-05-16; BINDING for ANY new BC-2 schema field this phase introduces; § Rule 16 § 'Fields explicitly subject to this rule' inventory at financial-data-protocol.md:443-456 already names BC-8 schemas — Phase G-prime adds BC-2 FinancialStatement extraction provenance fields per DD-3 below)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain BINDING for every new file authored under Phase G-prime sub-plans)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for each sub-plan dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any PDF cache / extraction state writes via tmp+os.replace pattern)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code in any Theme J sub-plan; PDF source paths + extraction output paths use packages/_shared/path_safety.py helpers)"
  - "D-066 (CrawlerAdapter ABC ACCEPTED — INFORMATIONAL precedent for ABC-vs-Protocol decision in DD-1 PdfTableExtractorPort contract shape; same Strategy-ABC pattern + per-adapter optional-import gate)"
  - "D-067 (planner-upgrade ADR plan-025 — Phase 1b mandate for ≥3 sub-tracks — THIS plan is master-plan with 4 sub-plans; Phase 1b CONSUMED here AND mandatory in each follow-on per-sub-track plan)"
  - "L-S32-1 SKILL.md empirical-probe-first doctrine (.claude/skills/empirical-probe-first/SKILL.md — when master plan ladder includes ≥3 strategies, probe ALL viable strategies before commit; predecessor source_evidence may be stale on vendor APIs; PDF library landscape is fast-moving — sub-plan 041 G.1 empirical bake-off mandate flows from this skill)"
  - "Charter v1.1 Principle 1 (NO LLM math — PDF cells extracted via OCR = character recognition, NOT number derivation; deterministic post-OCR cell validation gate per supplement § J.5 + Rule 16 satisfaction mode #2) + Principle 2 (Every claim has source + as-of date — every extracted FS cell preserves source_pdf_url + source_pdf_page + as_of_filing_date + extraction_method + extractor_version per I-S2 + Rule 6 LLM Output Provenance EXTENDED to PDF substrate) + Principle 7 (Dogfood — sub-plan 044 G.4 ships first VHM annual-report extraction as concrete dogfood per Phase F-prime F.5 precedent) + Principle 8 (Calibration over confidence — per-adapter extraction accuracy MUST have empirical hit-rate measurement on ≥5-document gold set; cold-start V0 reports calibration_grade='D' UNTIL gold set accumulates) + Principle 11 (firing-test mandate IF a hook is shipped — N/A this plan, no hooks expected; product code only)"
  - "I-S1 (NO LLM math) + I-S1-1 (Rule 16 numeric-field discipline; BC-2 extraction provenance fields explicitly in scope per § C.0.4) + I-S2 (citation discipline — every extracted cell cites source_pdf_url + source_pdf_page + as_of_filing_date) + I-S20 (calibration over confidence — extraction accuracy traces to gold-set hit-rate not adapter 'feels confident') + I-S22 (data lineage — each extracted FinancialStatement traces to source PDF SHA256 + extractor_version + extracted_at) + I-S34 (public sources only + ToS compliance — VN company website FS + Vietstock public; NO paid leaks / NO insider channels / NO scraping bypass of paywalls) + I-S35 (research-aid framing — output is FinancialStatement ingestion not 'recommendation' surface)"
  - "Rule 1 (point-in-time integrity per financial-data-protocol.md; binding via FinancialStatement.__post_init__ at packages/domain/fundamental/models/financial_statement.py:63-88 — filing_date ≥ period_end + ingested_at.date() ≥ filing_date already enforced; PDF adapter MUST populate all 3 dates correctly) + Rule 4 (Source Attribution — every line_item preserves vendor key OR Vietnamese label per existing pattern at packages/infrastructure/fundamental/vnstock_fundamental_adapter.py:54-80) + Rule 5 (single currency per FinancialStatement enforced at :83-88) + Rule 6 (LLM Output Provenance EXTENDED — PDF page + extraction_method + extractor_version added to provenance chain) + Rule 16 (numeric-field discipline — extracted cell numeric values satisfy mode #2 deterministic-pipeline echo: OCR yields character-stream, parser yields Money, EchoValidator gates LLM-assisted adapter's claimed-vs-parsed value)"
  - "skill .claude/skills/empirical-probe-first/SKILL.md (G.1 library shootout MANDATE — probe ≥3 candidate adapters empirically before commit; per supplement § J.2 'No PDF-specific deep-dive source for VN broker reports — this is largely fresh IMPL work without major upstream port'; cold-start on VN-specific PDF landscape requires empirical probe)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (port-and-adapter; aggregate-root invariants — Phase G-prime adds PdfTableExtractorPort application-layer abstraction + per-adapter concrete implementations in infrastructure layer; FinancialStatement aggregate UNCHANGED — extraction surface is new but consumed-shape is existing)"
  - "skill .claude/skills/crawler-reliability/SKILL.md (Storage R2 layout + Selector Robustness fallback chain — PDF source URL fetcher MAY share R2 raw-storage pattern with BC-5 news + apply selector-fallback for company-website FS-listing pages where the PDF link selector drifts)"
  - "specs/tier1-strategic/001-four-tier-signal-architecture.md § B.1 (FinancialStatement existing thin slice at packages/domain/fundamental/models/financial_statement.py — Tier 1 Hard Data; Phase G-prime extends ingestion substrate WITHOUT new domain entity) + § A.2 line 137 (Vietstock public — financial reports (PDF + structured)) + § A.2 line 142 (FiinPro — comprehensive normalized fundamentals — Phase 2-3 deferred per existing plan)"
  - "packages/domain/fundamental/models/financial_statement.py (full read 108 LOC; FinancialStatement aggregate already ships with frozen+slotted dataclass + I-S1/I-S2/I-S5/I-S6/Rule 1/4/5/6 invariants enforced at :63-88; Phase G-prime EXTENDS via new adapter NOT new entity)"
  - "packages/infrastructure/fundamental/vnstock_fundamental_adapter.py (read first 80 LOC; existing vendor-key→canonical LineItemKey mapping pattern at :54-80; Phase G-prime PDF adapter MIRRORS this mapping pattern with PDF-cell-label→LineItemKey table)"
  - "packages/domain/fundamental/value_objects/line_item.py (full read 65 LOC; LineItemKey StrEnum 10 canonical keys for Phase 2 ratios; Phase G-prime adapter populates SAME keys — no domain extension needed for V0)"
  - "agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § J (offset 281-316; J.1 theme intent + J.2 contributing repos + J.3 architectural recommendation + J.4 Wave-1 IMPL slot + J.5 charter compliance flags) + § Theme L (offset 359+; HYBRID winner pattern as precedent for G-prime architecture)"
  - "agent-workspace/memory/observations/master-planner-A-02-deepdive-crawl4ai.md (full read 165+ LOC partial; § 1 Apache-2.0 + Attribution + § 2 patterns + § 3 C9 PDFContentScrapingStrategy)"
  - "C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py (full read 80 LOC partial; concrete REFERENCE pattern for pypdf+PyPDF2 fallback chain at :45-60; demonstrates SHA256 checkpoint + state.json dedupe + per-page text extraction shape — PATTERN ONLY not code-port per A-04 license posture)"
  - "C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_downloader.py (read first 40 LOC; SHA256-based dedupe + index.json checkpoint + retry-with-backoff for PDF source URL fetcher PATTERN — applicable to VN company-website FS PDF download substrate; ZERO code-port per A-04 AGPL+Commercial license blocker)"
  - "agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md (TEMPLATE for crawler-adapter Phase-D pattern — Port/ABC + first concrete adapter + ~150-200 LOC per implementation; Phase G-prime mirrors this PROVEN sandwich-architect shape)"
  - "agent-workspace/session-plans/completed/034-S374-phase-f1-roleprompt-persona-transport.md (TEMPLATE for Phase F-prime F.1 sub-plan structure — 5 sub-tracks D1-D5 with dependency graph + Phase 1b CONSUMED + COLD-START declared + RM table + DD inventory; THIS master plan mirrors that proven structure)"
  - "agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (PARENT — § N sequencing recommendation + § Phase F-prime → G-prime → H-prime sequencing recommendation table; cited line:line throughout § N below)"

binding_decisions:
  - "PHASE-G-PRIME AS PHASE-MASTER-PLAN (NOT single multi-sub-track FOCUSED_IMPL) — per CLAUDE.md § Session Types 'never mix PLAN+IMPL'; precedent: plan-033 Phase F-prime master-plan = 5 sub-plans per-PLAN+IMPL+VERIFY chain (sub-plans 034/035/036/037/038 SHIPPED + closed at S386); Phase G-prime = 4 sub-tracks following the same architectural rhythm (one fewer because no equivalent of F.4 V0-expansion + F.5 dogfood-separate; G.4 IS the dogfood)"
  - "TASK-CLASS COLD-START DECLARED — Phase 1b Calibration summary for THIS master plan explicitly cites COLD-START on .planner-stats.tsv task_class='pdf-extraction-master-plan' per L-S354-2 → L-S366-4 → L-S369-1 cascade carry-forward; planner-feedback-loop.sh promotion D1 from harness sweep N+1 (S388 commit 78089ba) NOW LIVE per current-execution.md:147 — Phase G-prime sub-plans will SEE the .planner-stats.tsv populated after this master plan ships, but THIS plan still cold-starts on the task_class"
  - "D-060 — agent MAY git commit (NOT push); each per-sub-track plan dev decides commit boundary independently"
  - "AP-23 promote-or-retire — applied to first-instance: any new PDF-extraction-pattern (e.g. cell-label-normalization-table per-source) that ships unchanged after 3 dogfood cycles on different VN tickers' annual reports is PROMOTE-NOW candidate (not refinement-of-rule); adapter count expansion uses AP-7 named revisit trigger pattern"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item in this plan + sub-plans names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "L-S32-1 empirical-probe-first MANDATE for G.1 — PDF library landscape evolves fast; supplement § J names only pdfplumber+camelot+Claude-vision but multiple library candidates exist (pdfplumber/pypdf/pymupdf/camelot/tabula/unstructured/docling/azure-doc-intelligence-equivalent); G.1 sub-plan MUST empirically probe ≥3 viable candidates on ≥1 VHM PDF gold sample before adapter-port commit (skill .claude/skills/empirical-probe-first/SKILL.md applies)"
  - "I-S1 BY-CONSTRUCTION for Theme J extraction surface — PDF adapter pipeline: (a) fetch PDF binary, (b) OCR/parse to cell-text string, (c) deterministic cell-label→LineItemKey mapping (lookup table pattern per vnstock_fundamental_adapter.py:54-80 precedent), (d) deterministic VND-string→Decimal parser (digits + Vietnamese thousand-separator handling), (e) Money construction with currency=VND; NO LLM ever computes/derives a number — LLM-assisted adapter (G.3) uses Claude vision OCR (character recognition) with EchoValidator post-OCR cell-validation gate per Rule 16 mode #2"
  - "VBW protocol mandatory — every sub-plan author must READ existing packages/domain/fundamental/** + packages/infrastructure/fundamental/vnstock_fundamental_adapter.py + supplement § J + ≥1 candidate library source (e.g. crawl4ai/processors/pdf/processor.py) empirically NOT memory; cite file:line for every architectural claim"
  - "Karpathy P3 surgical-changes — each sub-plan adds ≤500 LOC production code per sub-track; if a sub-track grows >500 LOC architect MUST split it further. **Theme J EXTENDS existing BC-2 substrate rather than replacing — preserves backward compat with vnstock_fundamental_adapter.py + existing 6-ratio formulas + existing 10 LineItemKey canonical keys**"
  - "ISOLATED-ADAPTERS-THEN-PORT-ABSTRACTION pattern for V0 (per DD-1 below) — empirical-probe-first finds the winner BEFORE committing to a single ABC shape; not all 3 candidate adapters will become production code, only the empirically best 1-2 will ship"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; this is master-plan authoring)"
  - "no commits in THIS plan-session by architect (sandwich-architect/master-planner has tools: [Read, Glob, Grep, Write]; no Bash; main session commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching Phase F-prime files (CODE-DONE-DATA-PENDING — separable operational data-corpus track unblocks F-prime later; Phase G-prime is parallel-eligible per parent plan-033 § N because file scope is disjoint — BC-2 fundamental adapters vs BC-8 personas)"
  - "no Theme H-prime / charter amendment SHIP from THIS plan — H-prime is independent master-plan per master plan § 6.4.5; any I-S<N>-tier surface gets FLAGGED in § K for separate user-ratification gate dispatch"
  - "no harness/hook changes — this plan ships product substrate (Theme J PDF + table extraction); surface any harness gaps in observation; do NOT fix here. L-S354-2/L-S366-4/L-S369-1 planner-stats cascade already PROMOTED in harness sweep N+1 S388 commit 78089ba; Phase G-prime sub-plans inherit the now-live infrastructure"
  - "every plan claim cites source file:line (per I-S2 + AOM + VBW protocol)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward at G.2 + G.3 IMPL — PDF source URL fetcher MUST use public sources only (VN company website FS + Vietstock public); NO paid-API leak channels; verify in each sub-plan STEP 0"
  - "If Phase G-prime surfaces a charter-tier need (new I-S<N> invariant for OCR-derived-cell semantics / new Rule for extractor-version provenance schema / new Rule 16 mode for OCR-character-recognition vs LLM-cell-derivation), FLAG in § K for main session user-ratification gate dispatch"
  - "Phase G-prime does NOT include BC-5 News re-architecture (Phase D Theme L SHIPPED at S338-S358 — out of surgical scope per P3) NOR BC-1 OHLCV refactor (existing market_data infrastructure unchanged)"
  - "ZERO new external dependencies in THIS plan — sub-plan 041 G.1 empirical bake-off evaluates candidates AND ratifies pyproject.toml dep addition at IMPL time (G.2/G.3) under D-061-style add-with-rationale doctrine; THIS master plan does NOT commit any specific library yet"
  - "FinceptTerminal cninfo_pdf_*.py PATTERN-PORT NOT CODE-PORT per A-04 license posture (AGPL + Commercial; pattern extraction safe, code-copy unsafe) — pattern adoption marked explicitly in DD-2 below"
---

# S391 — Phase G-prime Theme J BC-2 PDF + Table Extraction Entry (PHASE-MASTER-PLAN)

> **One-sentence intent**: Decompose Phase G-prime (Theme J — PDF + table extraction for BC-2 Fundamental Data) into 4 follow-on per-sub-track PLAN+IMPL+VERIFY chains covering (G.1) empirical library bake-off + PdfTableExtractorPort ABC contract design, (G.2) pure-Python adapter (winner of G.1 empirical probe; pdfplumber+camelot OR pymupdf OR docling), (G.3) LLM-assisted adapter (Claude vision OCR + EchoValidator post-OCR cell-validation gate per Rule 16 mode #2), (G.4) first VHM annual-report dogfood end-to-end through BC-2 SqliteFundamentalRepository — each chain ≤1 PLAN + 1-2 IMPL + 1 VERIFY session — without mixing PLAN+IMPL in the same session (CLAUDE.md hard rule), without LLM-deriving numeric cell values (I-S1 + Rule 16), and without bundling all 3 adapter candidates + BC-2 integration + VHM dogfood into one session (Session 4 catastrophic mix anti-pattern).

---

## A. Goal & Scope

### A.1 Goal (verbatim from supplement § J + parent plan-033 § N inheritance)

Build the **BC-2 Fundamental Data PDF + table extraction substrate** that lets StockForge ingest Vietnamese financial statements (FS) from PDF sources (VN company websites + Vietstock public) into the existing `FinancialStatement` aggregate at `packages/domain/fundamental/models/financial_statement.py:42-88`, where:

- **PdfTableExtractorPort** is an application-layer ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW) with signature `extract(pdf_source: PdfSource) → ExtractedFinancialStatement` — Strategy ABC pattern per supplement § J.3 + crawl4ai PDFContentScrapingStrategy precedent at `C:/htdocs/research/crawl4ai/crawl4ai/processors/pdf/processor.py:1-100` (PATTERN-PORT not CODE-PORT; Apache-2.0 + Attribution clause)
- **Per-adapter optional-import gate at construction** (mirror existing vnstock_fundamental_adapter pattern at `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` + crawl4ai Strategy ABC precedent) — pdfplumber/camelot/pymupdf are heavy deps; importable adapters surface explicit missing-dep errors at instantiation
- **Cell-label normalization** uses lookup-table pattern per `vnstock_fundamental_adapter.py:54-80` precedent — PDF cell text "Doanh thu thuần" → canonical `LineItemKey.REVENUE`; same VN/EN dual-language map; same fail-on-missing semantics
- **Deterministic VND-string parser** (digits + Vietnamese thousand-separator handling) produces `Money(amount=Decimal, currency=VND)` — NO LLM ever computes/derives a number; LLM-assisted adapter (G.3) uses Claude vision for character-recognition OCR ONLY, then deterministic cell-validation gate per Rule 16 mode #2
- **Provenance chain extended for PDF**: each extracted FinancialStatement preserves `source_pdf_url + source_pdf_page + source_pdf_sha256 + extraction_method + extractor_version + as_of_filing_date + extracted_at` — satisfies I-S2 + Rule 4 + Rule 6 + Rule 22 EXTENDED to PDF substrate
- **First VHM annual-report dogfood** ships at G.4 — concrete extraction of VHM 2024 annual report (or 2023 if 2024 not published; user-pickable in G.4 STEP 0) → SqliteFundamentalRepository persistence → ratio_service smoke-test (ROE + Debt/Equity + Net Margin computed from extracted line items) — analogous to Phase F-prime F.5 CLI dogfood pattern shipped at S384

### A.2 Scope (4 sub-tracks per supplement § J refinement + parent plan-033 § N)

This phase ships:

1. **Sub-track G.1 — Empirical library bake-off + PdfTableExtractorPort ABC contract design** (target: NEW `packages/application/fundamental/pdf_table_extractor_port.py` ABC + NEW `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` empirical-probe-first report comparing ≥3 candidate libraries on ≥1 VHM gold-sample PDF; PLAN session decides empirical probe protocol; IMPL session runs probe + ratifies winner)
2. **Sub-track G.2 — Pure-Python adapter (winner of G.1)** (target: NEW `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` + cell-label normalization table + VND-string parser + tests on ≥3 gold-sample PDFs; ~200-300 LOC including tests; pyproject.toml adds winner-library dep with attribution + rationale per D-061 add-with-rationale doctrine)
3. **Sub-track G.3 — LLM-assisted adapter (Claude vision OCR + EchoValidator gate)** (target: NEW `packages/infrastructure/fundamental/pdf_claude_vision_fundamental_adapter.py` + Claude CLI substrate dispatch per `subagent_transport.claude_cli_transport` pattern shipped at S375 per D-072 BC-5 precedent; EchoValidator post-OCR cell-validation gate per Rule 16 mode #2; ~250-350 LOC including tests; NO new external dep — uses existing claude CLI substrate)
4. **Sub-track G.4 — First VHM annual-report dogfood + BC-2 SqliteFundamentalRepository integration smoke** (target: NEW `apps/cli/ingest_pdf_fundamentals.py` CLI; dogfood run on VHM 2023/2024 annual report — capture per-adapter extraction accuracy + cost-tracking + 6-ratio downstream computation + write `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md`; ~200-300 LOC including tests; pattern reference = `apps/cli/validate_thesis.py` (F.5 dogfood shipped S384) + `apps/cli/extract_vn_claims.py` (E.3 dogfood shipped S368))

Each sub-track = one downstream PLAN session (S392 / S395 / S398 / S401) authored by sandwich-architect + one IMPL session (S393 / S396 / S399 / S402) executed by sandwich-dev + one VERIFY session (sandwich-verifier AP-1) per the standard sandwich pattern.

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| **Annual** frequency expansion of vnstock_fundamental_adapter | vnstock adapter currently ships QUARTERLY only per :15-17 docstring; ANNUAL expansion is separate scope from PDF substrate; PDF source is the PRIMARY annual-report channel anyway | Annual trigger: VHM dogfood G.4 surfaces that vnstock quarterly-only insufficient for 5-year percentile_service backfill; revisit at Phase 2 percentile-service entry |
| Multi-language PDF (Vietnamese + English bilingual reports) | V0 ships VN-language only; most VN listed companies publish bilingual but VN is canonical; English-translation is downstream | Bilingual trigger: dogfood G.4 reveals VHM publishes English-only translations for certain line items → add EN→VN canonical map in same lookup table |
| OCR for scanned/older PDFs (pre-2020 VN broker reports) | G.3 Claude vision adapter handles SOME scanned PDFs but full historical backfill is large-scope; V0 focuses 2022-2024 annual reports which are mostly digital PDFs | Scanned trigger: project-owner requests pre-2020 backfill; revisit at Phase 2 historical-data-backfill entry |
| Streamlit dashboard for PDF extraction provenance browsing | Phase H-prime work per master plan § 6.4.5; not on Phase 1 critical path; CLI dogfood (G.4) sufficient for V0 | Dashboard trigger: Phase H-prime entry |
| Per-source adapter configuration DSL (CSS/XPath-equivalent for PDF table cells) | YAML-based cell-label-map at `agent-workspace/role-packs/`-equivalent for V0; per-source mapping is in adapter code; DSL is over-engineering for ≤5 sources | DSL trigger: ≥5 distinct VN sources with conflicting cell-label conventions surfaces |
| Real-time PDF ingestion pipeline (Redis Streams / Prefect schedule) | V0 ships batch CLI per G.4; streaming + scheduling = Phase 2 operational layer | Streaming trigger: Phase 2 entry + Prefect schedule wired for BC-2 |
| Per-adapter calibration database (gold-set hit-rate tracking) | Charter Principle 8 calibration over confidence — but PDF adapter is too new to have historical hit-rate; V0 ships with calibration_grade='D' per existing pattern; ≥5-document gold set established in G.4 dogfood is V0 cap | Calibration trigger: n≥20 extracted FS records across 3+ tickers + manual gold-truth validation per Charter Principle 8 |
| Broker-report (BCTC) ingestion as PDF source variant | V0 focuses ANNUAL_REPORT statement_type; broker reports = different document shape (narrative + tables interleaved + analyst commentary); separate adapter | Broker-report trigger: project-owner requests SSI/HSC/VNDirect broker PDF ingestion; revisit Phase 2 |
| Charter amendment SHIP for any new I-S<N> invariant Theme J surfaces | If a new invariant needed (e.g. I-S<N> for OCR-derived-cell semantics or extractor_version provenance), this plan FLAGS in § K; main session dispatches separate user-ratification gate per CLAUDE.md hard rule | Trigger: § K item flagged + main session AskUserQuestion dispatch path |
| New harness/hook for PDF-extraction-cell-determinism check | Belongs to harness-stabilization sweep, NOT product session | Harness sweep trigger: 2+ recurrences of cell-extraction-defect across IMPL sessions (AP-23 promote-to-hook calculus) |
| FiinPro normalized-fundamentals adapter (paid API) | Per spec § A.2 line 142 "FiinPro — comprehensive normalized fundamentals — Phase 2-3 if budget"; deferred per existing roadmap | FiinPro trigger: Phase 2-3 entry + user-authorization for paid-API budget |
| Multi-currency FS (USD-reported FS from foreign-listed VN equities) | Existing FinancialStatement enforces single-currency at :83-88; VN-domestic FS = VND; foreign-listed expansion = Phase 3+ | Multi-currency trigger: project-owner adds non-VND-reporting ticker to universe |
| AzureDocumentIntelligence (or equivalent paid cloud OCR) | Paid service; supplement § J names "azure-doc-intelligence-equivalent" as candidate but V0 stays free/local; Claude vision (G.3) covers paid-but-low-cost path via existing claude CLI substrate | Cloud-OCR trigger: pure-Python (G.2) + Claude vision (G.3) both fail accuracy gate (<90% on gold set) AND user authorizes paid-cloud spend |
| Generic PDF→Markdown converter (vs FS-specific extractor) | V0 ships FS-specific extractor with cell-label normalization; generic PDF→MD is BC-5 News scope if at all (research notes); separate from BC-2 Fundamental | Generic-PDF trigger: BC-5 News surfaces PDF research-note ingestion need; revisit as BC-5 adapter extension |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):

1. `agent-workspace/memory/.planner-stats.tsv` (per L-S354-2 → L-S366-4 → L-S369-1 cascade NOW PROMOTED via harness sweep N+1 S388 D1 per current-execution.md:147; .planner-stats.tsv writer auto-populates per 14-col schema; **HOWEVER** task_class="pdf-extraction-master-plan" is NEW — no precedent rows; **COLD-START on task_class declared** — sub-plans 041-044 will populate the first rows)
2. `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read last 30 rows; schema = `session_n,session_id,ts_utc,tokens_real,tools_used,subagents,failure_codes,wall_min`; nearest analog crawler-adapter-impl n=3 from S338+S344+S354 + vietnamese-nlp-plan n=1 from S360 master plan)
3. `agent-workspace/memory/current-execution.md` (full read top section + S386 + S390 + S383-S386 close + harness sweep N+1 SHIPPED narrative for parent plan-033 § N gate-satisfaction context)
4. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` § 5.5 Theme J (offset 478-498) + § 6.4.4 Phase G-prime slot (offset 588-590)
5. `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme J (offset 281-316; full J.1-J.5)
6. `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` (read offset 160-185 for C9 PDFContentScrapingStrategy candidate)
7. `agent-workspace/memory/observations/master-planner-A-02-deepdive-crawl4ai.md` (full read partial; § 1-3 patterns + C9 PDF strategy)
8. `packages/domain/fundamental/README.md` (full read 22 LOC; BC-2 responsibility + aggregates + storage + sources + LLM-role=NONE)
9. `packages/domain/fundamental/models/financial_statement.py` (full read 108 LOC; FinancialStatement aggregate + invariants at :63-88)
10. `packages/domain/fundamental/value_objects/line_item.py` (full read 65 LOC; LineItemKey StrEnum 10 canonical keys + line_item_required_for_ratio table)
11. `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (read first 80 LOC; vendor-key→canonical mapping pattern + Finance fetcher Protocol)
12. `pyproject.toml` (full read 197 LOC; ZERO PDF lib dep currently — pdfplumber/camelot/pymupdf/pypdf/docling/unstructured all NOT present; only PDF-adjacent dep is playwright>=1.47.0 which has playwright.async_api.Page.pdf() but that's PAGE→PDF not PDF→DATA)
13. `agent-workspace/constitution/financial-data-protocol.md` § Rule 16 (offset 358-477; full Rule 16 + 4 satisfaction modes; mode #2 deterministic-pipeline echo applies to G.3 LLM-assisted adapter — OCR yields character-stream, parser yields Money, EchoValidator gates LLM-claimed-vs-parsed value)
14. `agent-workspace/constitution/architecture.md` § BC-2 (offset 46-50; path packages/domain/fundamental/ + aggregates + storage)
15. `specs/tier1-strategic/001-four-tier-signal-architecture.md` (read first 20 grep-window; Vietstock public + FiinPro source lines :137 + :142)
16. `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py` (full read 80 LOC partial; concrete pattern for pypdf+PyPDF2 fallback + SHA256 checkpoint + state.json dedupe + per-page text extraction shape; PATTERN ONLY not code-port per A-04 AGPL+Commercial license)
17. `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_downloader.py` (read first 40 LOC; SHA256-based dedupe + index.json checkpoint + retry-with-backoff pattern for PDF source URL fetcher)
18. `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` (first 120 LOC; TEMPLATE for crawler-adapter Phase-D pattern — Port/ABC + first concrete adapter + ~150-200 LOC per impl)
19. `agent-workspace/session-plans/completed/034-S374-phase-f1-roleprompt-persona-transport.md` (first 200 LOC; TEMPLATE for Phase F-prime F.1 sub-plan structure — 5 sub-tracks + Phase 1b CONSUMED + COLD-START + RM table + DD inventory; THIS master plan mirrors structure)
20. `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (PARENT — § N sequencing recommendation cited file:line throughout)
21. `agent-workspace/memory/agent-notes.md` grep "L-S32-1" (empirical-probe-first lesson origin at S32 + skill promotion at S43e + cite to current-execution-archive.md:265 + :866-867)
22. `.claude/agents/sandwich-architect.md` (read L1-80 for template + Phase 1b mandate L42-65 + observation mandate L207-210)
23. `Glob` packages/**/fundamental*/** (confirmed BC-2 substrate exists; 4 services + 3 value objects + 1 model + 2 repositories + 1 adapter)
24. `Grep` PDF|pdf libraries in C:\htdocs\research (confirmed 22 files mention candidates; FinceptTerminal cninfo_pdf_*.py + crawl4ai PDFContentScrapingStrategy are the 2 patterns; tabula/pdf2docx/pdfminer/paddleocr/tesseract/EasyOCR/VietOCR NOT found in any reference repo — clean baseline for G.1 empirical probe)

**Calibration parameters extracted**:

- **task_class**: `pdf-extraction-master-plan` (NEW — no precedent in tracking logs; first PDF-substrate-shaped work in StockForge)
- **sample_size**: **0** (COLD-START on this task_class); closest precedents are `crawler-adapter-impl` n=3 (S338/S344/S354 all clean cycles ~150K Sonnet each) and `vietnamese-nlp-plan` n=1 from S360 master plan — but PDF-extraction is fundamentally different: (a) external library landscape evaluation > single-vendor adapter port, (b) cell-text→Money parser is novel pattern, (c) Claude vision OCR substrate is novel (G.3), (d) gold-set calibration regime is novel (no Phase F-prime persona analog)
- **avg_wall_min observed**: N/A precise cold-start; estimating per closest analog cascade = `vietnamese-nlp-plan` n=1 ~80K (S360 master plan) + `crawler-adapter-impl` n=3 ~150K mean (S338/S344/S354) = master plan ~80-100K target; sub-plan IMPL ~150-180K target with novelty reserve
- **avg tokens_real**: N/A cold-start; THIS master plan estimating 150-200K Opus PLAN per recalibrated CLAUDE.md table; +30% over nearest analog (vietnamese-nlp-plan n=1) due to (a) 4-sub-track decomposition vs 4-sub-theme NLP, (b) empirical bake-off evaluation adds reading load, (c) PDF library + license matrix evaluation, (d) cross-BC coordination check (BC-5 News + BC-9 Outer-Loop)
- **parallel_hit_rate**: N/A cold-start; THIS master plan declares parallel_with FOR DOWNSTREAM sub-plans per § N (G.1 BLOCKS G.2 + G.3; G.2 + G.3 may run parallel post-G.1 ship; G.4 sequential POST-G.2 AND G.3)
- **parallel_savings_avg**: N/A cold-start
- **failure_mode frequency**: N/A cold-start; nearest analog crawler-adapter-impl n=3 shows 0 IMPORTANT defects per cycle (S338/S344/S354 ALL clean); Theme J may surface MORE defects per cycle because (a) PDF-cell extraction has more failure modes per cycle than HTML-CSS-selector extraction (visual layout vs structural), (b) Claude vision OCR-validation gate is novel (no D-072 BC-5 precedent for vision-modality), (c) gold-set construction is itself a novel artifact (no precedent in Phase E or Phase F-prime), (d) VND-string parser has Vietnamese-locale edge cases (thousand-separator "." vs decimal "," — opposite of US locale)
- **Adjustment to default budget**: This master plan = ~150-200K Opus PLAN authoring (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus); each follow-on per-sub-track plan envelope: PLAN 50-80K + IMPL 100-150K + VERIFY 30-60K = **180-290K per sub-track × 4 sub-tracks = ~720-1160K cumulative Phase G-prime budget** (per parent plan-033 § 6.4.4 estimate of ~400-600K — THIS plan refines upward to 720-1160K due to G.3 LLM-vision novelty + gold-set construction overhead)
- **Cold-start?**: **YES** (explicit declaration per agent-template + plan-025 DD-11 mandate; both `.planner-stats.tsv` infrastructure-just-promoted-but-no-rows-yet AND first PDF-extraction-shaped work)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):

- This master plan authoring: **150-200K Opus PLAN target ceiling** (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus 150-230K column; aim for upper-middle of envelope)
- Per-sub-track PLAN (S392/S395/S398/S401): 50-80K each (per CLAUDE.md § Session Types PLAN envelope) — calibration cold-start so use full envelope
- Per-sub-track IMPL (S393/S396/S399/S402): 100-150K Opus FOCUSED_IMPL each (cold-start defaults per plan-025 DD-6/DD-11) — Phase 1b for THOSE sessions inherits precedent from THIS plan + prior crawler-adapter-impl n=3 + vietnamese-nlp-impl n=3 as nearest analogs
- G.1 IMPL may need extended budget (~150K) for empirical probe execution (≥3 libraries × ≥1 VHM gold PDF + report)
- G.3 IMPL may need 1-2 IMPL sessions (Claude vision substrate + EchoValidator + cell-validation gate is broader surface than G.2)
- G.4 dogfood IMPL is bounded by single-ticker scope per F.5 precedent (~100K)
- Per-sub-track VERIFY: 30-60K Opus AP-1 fresh-context each (per CLAUDE.md § Session Types VERIFY envelope)
- **Cumulative Phase G-prime budget envelope: ~720-1160K Opus across ~12-16 sessions** (4 PLAN + 4-6 IMPL + 4 VERIFY)

**PARALLEL OPPORTUNITY** (architect declaration for downstream sub-plans):

- G.1 (empirical bake-off + PdfTableExtractorPort ABC) is foundational — must ship FIRST; blocks G.2/G.3/G.4 (they all depend on having a ratified winner from the empirical probe AND the ABC contract shape)
- G.2 (pure-Python winner adapter) consumes G.1 output (winner library + ABC); blocks G.4 (dogfood needs at least one adapter)
- G.3 (Claude vision adapter) consumes G.1 output (ABC + EchoValidator pattern); may run PARALLEL with G.2 (disjoint file scope — different adapter files + different test files)
- G.4 (VHM dogfood) is SEQUENTIAL POST-G.2 AND G.3 (needs both adapters shipped to run side-by-side comparison; reports per-adapter accuracy + cost on the gold sample)
- **Recommended sequencing**: G.1 sequential → (G.2 + G.3 parallel) → G.4 sequential
- Sub-plans 041 sequential; sub-plans 042/043 parallel-eligible per main session orchestration; sub-plan 044 sequential
- Per plan-025 DD-5 3-parallel ceiling applies to dev dispatch within a single sub-plan; cross-sub-plan parallel dispatch (G.2 + G.3) is 2-parallel and well within ceiling

---

## B. In-scope / Out-of-scope (master-plan-level)

### IN-scope (this MASTER PLAN ships)

- **This master-plan markdown** (~900-1100 LOC; 4 sub-track decompositions + per-sub-track DD pre-answered + recommended session sequencing + ratification path)
- **§ K Charter-tier-surface FLAG** (if Theme J surfaces invariant gaps; FLAGS only — does NOT amend charter/constitution)
- **§ E + § N Sequencing recommendation table** (sub-plans 041/042/043/044; budget envelopes; parallel-with dispatch markers)
- **§ N Phase G-prime → H-prime sequencing recommendation** per parent plan-033 § N table line "H-prime — DEFER to Phase 2 dashboard work entry"
- **Phase 1b CONSUMED variant with COLD-START explicit** (per plan-025 DD-11 mandate + agent-template L65 cold-start path)
- **3-source-evidence chain per library candidate** citing crawl4ai PDFContentScrapingStrategy + FinceptTerminal cninfo_pdf_*.py + general PDF-library knowledge (pdfplumber/camelot/pymupdf/pypdf/docling/unstructured)
- **Cross-BC coordination check** § F (BC-5 News + BC-9 Outer-Loop consumer audit)
- **Observation file** at `agent-workspace/memory/observations/master-planner-S391-phase-gprime-master-plan.md` (per agent-template L207-210 mandate; ~200 LOC)

### OUT-of-scope (DEFERRED — explicit non-goals)

- **Sub-plan AUTHORING** (only DECOMPOSITION + RECOMMENDED SEQUENCING; the actual sub-plan 041 for G.1 will be authored by a separate sandwich-architect dispatch when main session calls /session-start PLAN at S392)
- **Production code** (this is master-plan authoring; CLAUDE.md § Session Types — never mix PLAN+IMPL)
- **Library installation / dependency-add to pyproject.toml** (sub-plan 042 G.2 IMPL adds winner library + 043 G.3 IMPL adds claude-vision-related deps IF needed; THIS master plan recommends but does NOT commit to specific library)
- **Empirical probe execution** (G.1 IMPL runs the probe; THIS master plan only specifies probe protocol)
- **Gold-set construction** (G.1 PLAN identifies 5-document gold-set candidates from VHM/HPG/VIC/FPT corpus; G.1 IMPL OR G.4 IMPL constructs the gold-set; THIS master plan recommends ≥5-document target without prescribing exact docs)
- **Charter / constitution / human-workspace writes** (out of scope per CLAUDE.md hard rules)
- **AskUserQuestion gate FIRING** (master-plan recommends gates in § K; main session DECIDES whether to fire; BUT this plan recommends NON-BLOCKING design per § K.4 ratification path)
- **BC-2 SqliteFundamentalRepository schema changes** (G.4 IMPL evaluates IF new provenance fields require schema migration; THIS master plan recommends ADDITIVE-ONLY migration if any)

---

## C. STEP 0 — VBW Live Verification (this MASTER PLAN — light-touch; per-sub-track plans run own STEP 0)

This master plan's STEP 0 is light-touch (the heavy STEP 0s are per-sub-track — sub-plans 041/042/043/044 each ship their own VBW live verification):

### Sub-step 0.1 — Existing BC-2 substrate audit (VBW — completed inline)

- ✅ `packages/domain/fundamental/models/financial_statement.py` — FinancialStatement aggregate root with Rule 1 + Rule 4 + Rule 5 + Rule 6 + I-S1 invariants enforced at :63-88; frozen+slotted dataclass + Mapping[str, Money] line_items + sector/restated_at/fiscal_period_label optional fields; **Phase G-prime ADAPTERS POPULATE this aggregate — no domain extension needed for V0**
- ✅ `packages/domain/fundamental/value_objects/line_item.py` — LineItemKey StrEnum 10 canonical keys (REVENUE/GROSS_PROFIT/NET_INCOME/EPS/SHARES_OUTSTANDING/TOTAL_ASSETS/TOTAL_EQUITY/TOTAL_LIABILITIES/BOOK_VALUE_PER_SHARE/OPERATING_CASH_FLOW) + `line_item_required_for_ratio` table for 6 ratios (PE/PB/ROE/ROA/DEBT_EQUITY/NET_MARGIN); **Phase G-prime adapters NORMALIZE PDF cell labels to these same 10 keys; ratio_service downstream UNCHANGED**
- ✅ `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (first 80 LOC) — vendor-key→canonical mapping pattern at `_VNSTOCK_LINE_ITEM_MAP` :54-80; bilingual (VN + EN) labels; Finance fetcher Protocol injection; **Phase G-prime PDF adapter MIRRORS this mapping pattern with PDF-cell-text-label → LineItemKey table**
- ✅ `packages/infrastructure/fundamental/sqlite_fundamental_repository.py` — Glob confirmed exists; G.4 dogfood persists extracted FinancialStatement here; **no schema change expected for V0** (additive provenance fields evaluated at G.4 IMPL STEP 0)
- ✅ `packages/domain/fundamental/services/{ratio,percentile,peer}_service.py` — 3 deterministic services; ratio_service formulas computed from extracted line_items; **Phase G-prime extraction surfaces fold into these UNCHANGED**
- ✅ `packages/domain/fundamental/repositories/fundamental_repository.py` — Repository abstract port; G.4 dogfood uses existing SqliteFundamentalRepository; **no port change expected for V0**

### Sub-step 0.2 — Candidate library matrix audit (VBW — completed inline per L-S32-1 empirical-probe-first doctrine)

Library candidates surveyed (≥3 minimum per L-S32-1 + supplement § J refinement):

| Candidate | Strength | License | StockForge fit | Source-evidence |
|---|---|---|---|---|
| **pdfplumber + camelot** (supplement § J.3 candidate 1) | Best digital-PDF table extraction; camelot uses Ghostscript for stream/lattice modes | MIT (pdfplumber) + MIT (camelot-py) | Best for VN listed-company company-website FS PDFs (mostly digital, born-from-Word/Excel) | supplement § J.3 line 298; supplement § J.5 line 312 |
| **pymupdf** (NEW candidate this audit) | Fast pure-Python; rich layout analysis; good for text + simple tables | AGPL-3.0 (commercial license needed for proprietary use; stockforge IS proprietary per pyproject.toml:7 license="Proprietary") | **LICENSE BLOCKER** for stockforge proprietary use — RM-G-2 evaluate at G.1 STEP 0 license probe; AGPL-3.0 viral risk | repo metadata; pyproject.toml:7 stockforge license claim |
| **pypdf** (FinceptTerminal cninfo precedent) | Pure Python text extraction; widely used; PyPDF2 legacy fork | BSD-3-Clause (clean) | Best for text-only PDF substrate; weaker for complex tables; PATTERN already used at `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py:45-60` (pypdf+PyPDF2 fallback) | FinceptTerminal cninfo script :45-60 |
| **docling** (NEW candidate this audit; recent IBM open-source) | Layout-aware extraction with PDF + DOCX + PPTX support; markdown output; built-in OCR | MIT | Modern alternative to pdfplumber+camelot; layout-aware; **VN-specific gap not yet surveyed** — G.1 empirical probe target | repo metadata (github.com/DS4SD/docling) per master-planner general knowledge |
| **unstructured** (NEW candidate this audit) | Multi-format extraction (PDF + HTML + EPUB + etc.); Hi-Res mode for tables; built-in OCR via tesseract | Apache-2.0 | Heavy dep stack (similar concern to crawl4ai per A-02 § 5 wholesale-port-low fit); MAY work for VN PDFs but bloat risk | repo metadata (github.com/Unstructured-IO/unstructured) per master-planner general knowledge |
| **crawl4ai PDFContentScrapingStrategy + NaivePDFProcessorStrategy** (supplement § J.2 cited) | Strategy ABC shape reusable; pypdf-based naive impl | Apache-2.0 + Attribution clause (NOTICE mandatory per crawl4ai LICENSE:54-67) | **STRATEGY SHAPE ONLY** per A-02 § 3 C9 + supplement § J.5 — naive impl INSUFFICIENT for VN broker PDFs | A-02 § 3 C9 cite; supplement § J.2 line 289 + § J.5 line 313 |
| **Claude vision API (via existing claude CLI substrate)** (supplement § J.3 candidate 2) | OCR + structured-output for scanned PDFs; LLM does character-recognition NOT number-derivation per I-S1 audit; EchoValidator post-OCR cell-validation gate per Rule 16 mode #2 | Anthropic ToS (existing substrate) | Best for scanned/older VN PDFs that pure-Python adapters fail; PER-CELL cost adds up; ratify cost ceiling at G.3 STEP 0 | supplement § J.3 line 299 + § J.5 line 311 |
| **AzureDocumentIntelligence-equivalent (paid cloud OCR)** | Industry-standard; very high accuracy for tables; cell-level layout | Paid (PASS — deferred per § A.3 "AzureDocumentIntelligence" item) | Out of V0 scope per cost discipline | supplement § J.3 implicit; this audit makes explicit |

**G.1 empirical bake-off targets** (sub-plan 041 PLAN authors final probe protocol; recommend at minimum):
1. **pdfplumber + camelot** (supplement § J.3 candidate 1 — MIT clean; pure-Python; best-known table extraction)
2. **docling** (modern alternative; MIT clean; layout-aware; new market entrant)
3. **pypdf** (text-only baseline; BSD-3 clean; FinceptTerminal precedent shows works)
4. **Claude vision OCR** (G.3 surface; deferred to dedicated G.3 sub-plan due to LLM-substrate novelty — NOT IN G.1 probe scope)

**Charter-tier-surface FLAG**: If G.1 empirical probe surfaces that pymupdf is materially better than pdfplumber+camelot on VN-specific PDFs AND project-owner accepts AGPL-3.0 license risk for proprietary stockforge use, that's a Charter-tier-surface FLAG event — G.1 STEP 0 STOP-AND-ASK clause triggers per § K.

### Sub-step 0.3 — VN-specific PDF source landscape audit (VBW — completed inline)

VN listed-company FS PDF sources (per spec § A.2 + supplement § J.1):

- **VN company websites** (VHM = vinhomes.vn ir.vinhomes.com; VIC = vingroup.net; HPG = hpg.vn; FPT = fpt.com.vn) — direct PDF download; URL pattern varies per company (no canonical schema); requires per-company URL-pattern adapter OR centralized scraper for "annual-report" link discovery
- **Vietstock public** (finance.vietstock.vn /vi-quan-tri/?company=<ticker>) — aggregated FS PDFs; uniform URL pattern; **G.4 dogfood candidate primary source**
- **SBV (State Bank of Vietnam)** — bank-only FS for banking sector; out of V0 scope per single-ticker dogfood
- **CafeF/NDH article-linked PDFs** — secondary path; not primary V0 channel

**Vietnamese-language characteristics**:
- VND amounts often presented as integer thousands or millions (e.g. "1.234.567" = 1,234,567 VND with "." as thousand separator OPPOSITE of US locale)
- Some FS use "Triệu đồng" (million VND) or "Tỷ đồng" (billion VND) as table unit-header; VND-string parser MUST handle unit scaling
- Bilingual VN/EN tables common in larger companies (VHM/VIC/FPT) — adapter MUST handle either
- "Doanh thu thuần" (Net revenue) vs "Doanh thu bán hàng" (Sales revenue) — granularity drift between companies; canonical normalization needed
- Negative numbers may use parentheses notation "(1.234)" — common accounting convention; parser handles

**VN-OCR-language-specific gap** (per dispatch brief reference): for scanned PDFs (older annual reports), tesseract OCR has tesseract-lang Vietnamese pack (`vie.traineddata`) but quality on financial tables is uneven; Claude vision (G.3) likely outperforms tesseract on scanned VN financial tables but PER-CELL cost; **G.3 STEP 0 evaluates whether tesseract+vie viable as cost-floor fallback**.

### Sub-step 0.4 — Rule 16 surface audit for Theme J (BINDING per § Charter compliance per D-065)

Theme J introduces these candidate schema fields where Rule 16 (I-S1-1) applies:

- **Extracted line_item Money.amount** (existing field; Money is `Decimal + Currency`) — **Rule 16 satisfaction mode #2 (deterministic-pipeline echo)**: pure-Python adapter (G.2) parses cell text via deterministic VND-string parser → Money; LLM-assisted adapter (G.3) Claude vision yields character-stream → deterministic parser → Money + EchoValidator gates LLM-claimed-value vs parsed value (LLM never emits Decimal directly)
- **FinancialStatement.line_items dict** (existing field; `Mapping[str, Money]`) — Rule 16 N/A per-key (StrEnum) + per-value satisfies mode #2
- **NEW: extraction_method field (G.1 ABC contract addition)** — String/StrEnum identifying which adapter produced the extraction (e.g. "pdfplumber+camelot" / "docling" / "claude-vision"); **Rule 16 N/A (categorical/enum)** — by-construction
- **NEW: extractor_version field (G.1 ABC contract addition)** — Version string for adapter version (e.g. "0.1.0"); **Rule 16 N/A (version string not numeric semantic field)**
- **NEW: source_pdf_page field (G.1 ABC contract addition)** — int page number where cell originated; **Rule 16 satisfaction mode #2** (deterministic from PDF reader page index; LLM never emits)
- **NEW: source_pdf_sha256 field (G.1 ABC contract addition)** — SHA256 hex string of source PDF; **Rule 16 N/A (hash string not numeric semantic field)**
- **NEW: extraction_confidence field (POSSIBLE G.3 extension)** — defer; not in V0 scope; if added in G.3-V2 OR G.4-V2, satisfaction mode #1 (categorical surrogate per Rule 7 STRONGLY_HIGH/HIGH/MEDIUM/LOW/STRONGLY_LOW StrEnum)

**Verdict**: All Theme J candidate numeric fields satisfy Rule 16 via mode #2 (deterministic-pipeline echo via VND-string parser pure function) or mode #1 (categorical surrogate via Conviction-equivalent StrEnum for confidence) or are N/A (non-numeric categorical/version/hash). **No mode #3 (calibration lookup) needed yet** because per-extraction calibration is post-MVP (deferred per § A.3). **No mode #4 (NULL surrogate) needed** because all fields have deterministic computation paths.

**Charter-tier-surface FLAG**: If G.3 sub-plan surfaces a NEW schema field where Rule 16 mode #1+#2 cannot apply (e.g. "OCR-character-recognition-fidelity-score" as numeric float that LLM derives), that's a Charter-tier-surface FLAG event — G.3 STEP 0 STOP-AND-ASK clause triggers per § K. **No FLAG at this master-plan level — Theme J as scoped satisfies Rule 16 by construction.**

### Sub-step 0.5 — anthropic_api_to_subagent memory-rule check for G.3

Per `anthropic_api_to_subagent` memory rule: "For every `ANTHROPIC_API_KEY` / direct `anthropic` SDK call: refactor to Claude Code subagent dispatch (subscription billing, not API metered); systemic rule".

- ✅ G.3 Claude vision adapter MUST use existing `claude_cli_transport` from `packages/infrastructure/analysis/subagent_transport.py:144-222` (transport-flip pattern shipped at S375 per D-072 BC-5 precedent; PROVEN substrate for vision dispatch path via Read tool image-input modality)
- ✅ ZERO new `import anthropic` introduced in any G.3 file (verifier grep-asserts)
- ⚠️ **OPEN QUESTION**: Does claude CLI substrate support PDF image attachment via Read-tool image input? **G.3 STEP 0 empirical probe required** — if claude CLI lacks vision input, G.3 may need to fall back to direct claude.ai web UI screenshot path OR Anthropic API (which would violate memory rule); **FLAG IN § K**

### Sub-step 0.6 — Existing related-pattern grep audit

- ✅ `Grep PdfTableExtractor|PdfSource|pdf_table_extractor|pdf_fundamental` (production code) returns 0 matches — **clean baseline for G.1 to add first production use**
- ✅ `Grep pdfplumber|camelot|pymupdf|pypdf|docling|unstructured` (production code) returns 0 matches in stockforge (only in research repos) — **clean baseline for G.2 to add first production use**
- ✅ `packages/application/fundamental/` directory does NOT exist yet — G.1 sub-plan creates it for PdfTableExtractorPort ABC (analog to packages/application/analysis/ + packages/application/news/)
- ✅ `packages/infrastructure/fundamental/` directory exists with 1 vendor adapter (vnstock); G.2 + G.3 add 2 new PDF adapters parallel to existing
- ✅ `apps/cli/ingest_pdf_fundamentals.py` does NOT exist yet — G.4 creates it; pattern reference = `apps/cli/validate_thesis.py` (F.5 shipped S384) + `apps/cli/extract_vn_claims.py` (E.3 shipped S368) + `apps/cli/ingest_news_cafef.py` (D Theme L shipped S338)
- ✅ `agent-workspace/research/pdf-library-bakeoff-*.md` does NOT exist yet — G.1 IMPL creates the bake-off report (analog to existing `agent-workspace/research/INTEGRATION_PROPOSAL_*.md` shape)
- ✅ `tests/fixtures/pdf-gold-set/` does NOT exist yet — G.1 IMPL OR G.4 IMPL constructs (5-document gold-set target: VHM 2023 annual / HPG 2023 annual / VIC 2023 annual / FPT 2023 annual / 1 scanned older sample for G.3)

### Sub-step 0.7 — STEP 0 summary write (this master plan)

All 6 sub-steps PASS. No STOP-AND-ASK triggered at master-plan level. **3 charter-tier-surface FLAGS surfaced at sub-plan level** (see § K.2: G.1 license escalation if pymupdf-AGPL-3.0 chosen / G.3 claude-CLI-vision-input feasibility / G.4 schema-migration-for-provenance-fields). Main session DECIDES whether to fire AskUserQuestion gate; this plan's RECOMMENDATION is NON-BLOCKING design path (architect-recommended default chosen per DD-2/DD-3; sub-plan STEP 0s STOP-AND-ASK if architect-recommended default proves wrong empirically).

---

## D. Architecture Decisions (DD-1 through DD-8)

### DD-1: PdfTableExtractorPort = ABC at packages/application/fundamental/ (NOT Protocol, NOT dataclass)

**Decision**: PdfTableExtractorPort is an **ABC (abstract base class)** with abstract method `extract(pdf_source: PdfSource) → ExtractedFinancialStatement`, located at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW file in new directory).

**Rationale**:
- **D-066 precedent**: CrawlerAdapter shipped as ABC at S338 per `agent-workspace/session-plans/completed/020-S337-phase-d-theme-l-crawling-adapter.md` § DD-1; same Strategy ABC + per-adapter optional-import gate pattern works for BC-2 PDF
- **crawl4ai PDFContentScrapingStrategy precedent**: per `C:/htdocs/research/crawl4ai/crawl4ai/processors/pdf/processor.py:1-100` (Strategy ABC + naive impl); A-02 § 3 C9 cite + supplement § J.2 line 289 — strategy shape reusable
- **vnstock_fundamental_adapter parallel**: per `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py:42-46` — existing Finance fetcher Protocol; PDF adapter can use Protocol for fetcher injection BUT ABC for the extractor itself (clearer is-a relationship for multi-adapter polymorphism)
- **DDD Port + Adapter doctrine** per `.claude/skills/ddd-tactical-patterns/SKILL.md` — application layer owns the port; infrastructure layer owns the adapters

**Adversarial alternate considered**: Protocol structural typing → REJECTED because (a) ABC `@abstractmethod` provides runtime enforcement that Protocol cannot, (b) shared base behavior (e.g. SHA256 source-hashing) lives cleanly in ABC, (c) error hierarchy via `PdfTableExtractorError` base class works better with ABC inheritance.

### DD-2: ExtractedFinancialStatement = NEW intermediate dataclass (NOT direct FinancialStatement construction)

**Decision**: G.1 introduces a **NEW intermediate dataclass** `ExtractedFinancialStatement` at `packages/application/fundamental/extracted_financial_statement.py` (NEW) that bundles raw extracted cells + provenance + adapter-specific metadata BEFORE deterministic mapping to canonical `FinancialStatement` domain entity. Use case (G.4 CLI dogfood) drives the mapping with explicit validation.

**Rationale**:
- **Karpathy P3 surgical-changes**: do NOT modify `packages/domain/fundamental/models/financial_statement.py` for V0 (existing invariants at :63-88 are sound); add upstream intermediate layer instead
- **Provenance chain capture**: `ExtractedFinancialStatement` carries `extraction_method + extractor_version + source_pdf_page + source_pdf_sha256 + raw_cells: Mapping[str, str]` BEFORE deterministic mapping to `FinancialStatement.line_items: Mapping[str, Money]` — preserves full audit trail even if mapping fails
- **Per-adapter polymorphism without domain pollution**: each adapter (G.2 pdfplumber+camelot / G.3 Claude vision) populates ExtractedFinancialStatement; deterministic mapping step (cell-label normalization + VND-string parser + Money construction) is shared application-layer logic
- **Backwards-compat preservation**: existing `VnstockFundamentalAdapter` UNCHANGED; existing `SqliteFundamentalRepository` UNCHANGED; existing 6-ratio formulas UNCHANGED — all consume the same `FinancialStatement` aggregate

**Adversarial alternate considered**: Direct FinancialStatement construction in adapters (mirror vnstock_fundamental_adapter shape) → REJECTED because (a) loses provenance capture for failed mapping cases, (b) couples extraction-specific metadata (extractor_version, source_pdf_page) to domain entity, (c) two PDF adapters duplicate cell-text-to-Money logic.

### DD-3: Provenance fields added at ExtractedFinancialStatement layer (NOT FinancialStatement domain)

**Decision**: New provenance fields (`source_pdf_url`, `source_pdf_page`, `source_pdf_sha256`, `extraction_method`, `extractor_version`, `extracted_at`) live on `ExtractedFinancialStatement` intermediate dataclass at application layer — **NOT** on the existing `FinancialStatement` domain aggregate. **Optional**: G.4 IMPL evaluates whether ADDITIVE provenance fields on FinancialStatement (with default=None for backward compat) help downstream thesis-pipeline citation discipline; deferred to G.4 STEP 0 decision.

**Rationale**:
- **Domain purity per architecture.md**: FinancialStatement domain entity stays clean; provenance is application-layer concern; existing entity has minimal field set per Karpathy P3
- **Backward compat**: vnstock adapter doesn't carry PDF-specific provenance; adding to domain entity forces vnstock adapter to carry irrelevant fields OR use None defaults
- **G.4 deferred decision**: thesis-pipeline (BC-9 Outer-Loop) downstream consumer MAY need provenance baked into FinancialStatement for citation surface; defer to G.4 IMPL STEP 0 empirical decision

**Rule 16 satisfaction**: All 6 new fields satisfy Rule 16 per § C.0.4 audit (mode #2 deterministic / mode #1 categorical / N/A non-numeric).

**Adversarial alternate considered**: Provenance on FinancialStatement domain entity directly → REJECTED for backward-compat + domain-purity reasons.

### DD-4: G.1 empirical probe protocol = 3 candidates × 1 VHM gold sample × 4 metrics

**Decision**: G.1 PLAN sub-plan specifies empirical probe protocol = run **≥3 candidate libraries** (pdfplumber+camelot, docling, pypdf — baseline; Claude vision deferred to G.3 dedicated sub-plan) against **1 VHM 2023 annual report gold sample** (project-owner picks specific PDF URL at G.1 STEP 0; recommend Vietstock public source for canonical URL) and report **4 metrics**:

1. **Cell-extraction accuracy**: % of 10 LineItemKey canonical cells correctly extracted (REVENUE/NET_INCOME/TOTAL_ASSETS/TOTAL_EQUITY/TOTAL_LIABILITIES/EPS/SHARES_OUTSTANDING/GROSS_PROFIT/BOOK_VALUE_PER_SHARE/OPERATING_CASH_FLOW) vs manually-validated gold truth
2. **Extraction wall-time**: seconds to process 1 VHM annual report (typically 80-150 pages)
3. **Dependency footprint**: # transitive deps added to pyproject.toml + total install size
4. **License compatibility**: pyproject.toml license-claim alignment (stockforge="Proprietary" per :7; library license must allow proprietary use)

**Rationale**:
- **L-S32-1 empirical-probe-first**: PDF library landscape is fast-moving + VN-specific PDF shape not surveyed in any reference repo → empirical probe mandatory
- **Karpathy P2 simplicity**: 1 gold sample sufficient for V0 winner-pick decision; gold-set expansion to 5 docs happens at G.4 dogfood
- **4 metrics span quality + cost + risk axes**: prevents single-metric tunnel vision

**Adversarial alternate considered**: 5-document gold-set in G.1 → REJECTED per Karpathy P3 — over-engineering for V0; G.4 dogfood is the appropriate 5-doc gate.

### DD-5: G.2 pure-Python winner sequencing = sequential POST-G.1 ratification

**Decision**: G.2 sub-plan author CANNOT begin until G.1 IMPL ratifies the empirical winner. G.2 PLAN session author reads `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` G.1 IMPL output + selects winner per ratified protocol.

**Rationale**:
- **L-S32-1 + Karpathy P1 think-before-coding**: empirical probe result drives G.2 implementation choice; pre-committing to pdfplumber+camelot in this master plan would violate L-S32-1
- **Reduce wasted IMPL work**: empirical winner may NOT be supplement § J.3's pdfplumber+camelot recommendation (docling may win); pre-committing risks throw-away work
- **NON-BLOCKING design**: if G.1 empirical probe produces NO clear winner (e.g. all 3 candidates score <70% accuracy), G.1 IMPL STOP-AND-ASK fires; main session ratifies pivot via Q-INT-2026-05-G-prime-2

**Adversarial alternate considered**: G.2 PLAN parallel with G.1 IMPL → REJECTED per L-S32-1 + Karpathy P1 reasoning above.

### DD-6: G.3 Claude vision adapter = MIRROR D-072 BC-5 transport-flip pattern

**Decision**: G.3 LLM-assisted adapter uses **existing claude CLI substrate** at `packages/infrastructure/analysis/subagent_transport.py:144-222` (claude_cli_transport function shipped at S375 per D-072 BC-5 transport-flip precedent + Phase F-prime F.1 BC-8 transport-flip precedent at S378). NO new `import anthropic`; NO new Anthropic SDK direct call.

**Rationale**:
- **anthropic_api_to_subagent memory rule** (D-050 CHARTER ACCEPTED 2026-05-09): subscription billing not API metered; SYSTEMIC mandate
- **D-072 BC-5 + D-074 BC-8 precedents**: claude CLI substrate proven for text-input dispatch; vision-input via Read tool image attachment likely works (G.3 STEP 0 empirical probe required per § C.0.5 OPEN QUESTION)
- **EchoValidator post-OCR cell-validation gate per Rule 16 mode #2**: Claude vision yields character-stream OCR; deterministic parser produces Money; LLM-claimed-value (if any) gates via `EchoValidator.validate(llm_value, deterministic_value, tolerance=...)` per financial-data-protocol.md Rule 16 mode #2

**Adversarial alternate considered**: Direct anthropic SDK call for vision API → REJECTED per memory rule + D-050/D-051/D-052 cascade.

### DD-7: G.4 dogfood ticker = VHM (defaults; project-owner pickable at G.4 STEP 0)

**Decision**: G.4 CLI dogfood defaults to **VHM 2023 annual report** (or 2024 if published by G.4 dispatch time). Project-owner can pick alternative VN30 ticker at G.4 STEP 0 (HPG / VIC / FPT recommended alternatives per Phase F-prime F.5 corpus pattern).

**Rationale**:
- **Phase F-prime F.5 precedent**: F.5 dogfood used VHM per `agent-workspace/thesis-log/2026-05-17-VHM.md` shipped S384; SAME ticker simplifies cross-phase data-corpus alignment
- **VHM PDF availability**: Vinhomes IR website + Vietstock public both have VHM annual report — well-documented availability
- **VHM domain complexity**: real-estate conglomerate has rich BS (multiple subsidiaries) + complex IS (sales-of-inventory accounting) + non-trivial cash-flow (development-investment) — exercise adapter on non-trivial document

**Adversarial alternate considered**: HPG (steel; simpler IS) → ACCEPTABLE alternate per project-owner STEP 0 pick; this DD-7 is a default not a hard binding.

### DD-8: ADR landing tier = 1 PROPOSED ADR per sub-plan at IMPL time (NOT this master plan)

**Decision**: Each sub-plan IMPL author creates own PROPOSED ADR at IMPL-tier; specifically:
- **G.1 IMPL → ADR D-080 PROPOSED** at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (records ABC contract + empirical winner ratification)
- **G.2 IMPL → ADR D-081 PROPOSED** at `agent-workspace/memory/decisions/081-pdf-pure-python-adapter-<winner>.md` (records pyproject.toml dep + cell-label-map + VND-string parser)
- **G.3 IMPL → ADR D-082 PROPOSED** at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echovalidator.md` (records claude CLI substrate vision-input feasibility + EchoValidator gate semantics + cost-tracking per-extraction)
- **G.4 IMPL → ADR D-083 PROPOSED** at `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc-2-integration.md` (records VHM dogfood outcome + gold-set construction + downstream ratio-service smoke validation)

**Rationale**:
- **Append-only ADR doctrine per DD-8 (parent plan-033 DD-8)**: do NOT modify existing ADRs; propose NEW ones at sub-plan IMPL time
- **IMPL-tier auto-ratifies per severity-schema**: PROPOSED → ACCEPTED at session close commit; no cool-down for IMPL-tier (CHARTER-tier requires 48h)
- **Schema floor ≥12 fields per L-S389-2 promote candidate** (from harness sweep N+1 S389): each ADR uses 12-field minimum schema

**Adversarial alternate considered**: Single ADR D-080 covering all 4 sub-plans → REJECTED per ADR discoverability + future-revisit-trigger granularity loss.

---

## E. Sub-track decomposition

### E.1 Sub-track G.1 — Empirical library bake-off + PdfTableExtractorPort ABC contract design

**Sub-plan**: `agent-workspace/session-plans/pending/041-S392-phase-g1-pdf-extractor-port-and-bakeoff.md`

**Goal**: Ship PdfTableExtractorPort ABC + ExtractedFinancialStatement intermediate dataclass + empirical bake-off report (`agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md`) ratifying winner library for G.2 pure-Python adapter implementation.

**Tasks** (5 sub-tracks expected at sub-plan author time):
1. D1: NEW `packages/application/fundamental/pdf_table_extractor_port.py` ABC (~80-100 LOC; ABC + abstract extract method + base error hierarchy + per-adapter optional-import-error subclass)
2. D2: NEW `packages/application/fundamental/extracted_financial_statement.py` intermediate dataclass (~60-80 LOC; frozen+slotted + 6 provenance fields per DD-3)
3. D3: G.1 IMPL empirical probe execution — install 3 candidate libraries in isolated venv, run each against 1 VHM gold-sample PDF, capture 4 metrics per DD-4, write `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (~200-300 LOC empirical report)
4. D4: NEW `packages/application/fundamental/test_pdf_table_extractor_port.py` unit tests on ABC contract (~80 LOC; test concrete-subclass instantiation; test error hierarchy)
5. D5: ADR D-080 PROPOSED at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (~150 LOC; ≥12 fields + ≥3 source_evidence cites)

**Budget**: PLAN ~50-80K Opus + IMPL ~150K Opus (empirical probe overhead) + VERIFY ~30-60K Opus

**Sequencing**: SEQUENTIAL FIRST — blocks G.2 + G.3 + G.4

**Dependencies**: G.1 IMPL requires Python venv with 3 candidate libraries installed; pyproject.toml NOT modified at G.1 (libraries installed in isolated probe venv; G.2 IMPL ratifies pyproject.toml dep addition for winner only)

### E.2 Sub-track G.2 — Pure-Python adapter (winner of G.1)

**Sub-plan**: `agent-workspace/session-plans/pending/042-S395-phase-g2-pdf-pure-python-adapter.md`

**Goal**: Ship `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` (concrete implementation of PdfTableExtractorPort ABC using G.1-ratified winner library) + cell-label normalization table + VND-string parser + tests.

**Tasks** (5 sub-tracks expected at sub-plan author time):
1. D1: NEW `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` (~200-300 LOC; ABC subclass; vendor-key→canonical LineItemKey mapping; VND-string parser; ExtractedFinancialStatement construction)
2. D2: NEW `packages/infrastructure/fundamental/test_pdf_<winner>_adapter.py` (~150-200 LOC; tests on G.1 gold-sample VHM PDF fixture)
3. D3: pyproject.toml dep addition for winner library (with attribution comment + rationale per D-061 doctrine)
4. D4: ADR D-081 PROPOSED at `agent-workspace/memory/decisions/081-pdf-pure-python-adapter-<winner>.md` (~150 LOC)
5. D5: NEW `tests/fixtures/pdf-gold-set/vhm-2023-annual.pdf` + SHA256 manifest at `tests/fixtures/pdf-gold-set/SHA256.txt`

**Budget**: PLAN ~50-80K Opus + IMPL ~120-150K Opus + VERIFY ~30-60K Opus

**Sequencing**: SEQUENTIAL POST-G.1 SHIP; PARALLEL-ELIGIBLE with G.3 (disjoint adapter files)

**Parallel-eligible with**: G.3 (disjoint files: `pdf_<winner>_fundamental_adapter.py` vs `pdf_claude_vision_fundamental_adapter.py`)

### E.3 Sub-track G.3 — LLM-assisted Claude vision adapter + EchoValidator gate

**Sub-plan**: `agent-workspace/session-plans/pending/043-S398-phase-g3-pdf-claude-vision-adapter.md`

**Goal**: Ship `packages/infrastructure/fundamental/pdf_claude_vision_fundamental_adapter.py` (LLM-assisted Claude vision OCR adapter using existing claude CLI substrate per D-074 BC-8 transport precedent) + EchoValidator post-OCR cell-validation gate per Rule 16 mode #2 + tests.

**Tasks** (5-6 sub-tracks expected at sub-plan author time):
1. D1: G.3 STEP 0 empirical probe — Verify claude CLI substrate supports PDF/image input (per § C.0.5 OPEN QUESTION); if NO, STOP-AND-ASK fires per K.2.b
2. D2: NEW `packages/infrastructure/fundamental/pdf_claude_vision_fundamental_adapter.py` (~250-350 LOC; ABC subclass; claude CLI subprocess invocation; per-cell OCR; EchoValidator gate)
3. D3: NEW `packages/application/fundamental/echo_validator.py` (~60-80 LOC; per Rule 16 mode #2 spec; tolerance-based validation; raise + abort on mismatch)
4. D4: NEW `packages/infrastructure/fundamental/test_pdf_claude_vision_adapter.py` (~150-200 LOC; tests with mocked claude CLI subprocess output)
5. D5: ADR D-082 PROPOSED at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echovalidator.md` (~180 LOC)
6. D6: NEW `tests/fixtures/pdf-gold-set/scanned-sample.pdf` + SHA256 manifest update

**Budget**: PLAN ~50-80K Opus + IMPL ~130-180K Opus (LLM substrate novelty + EchoValidator novel) + VERIFY ~30-60K Opus

**Sequencing**: SEQUENTIAL POST-G.1 SHIP; PARALLEL-ELIGIBLE with G.2

**Parallel-eligible with**: G.2

**Open question carry-forward**: claude CLI vision-input feasibility (§ C.0.5; § K.2.b)

### E.4 Sub-track G.4 — VHM annual-report dogfood + BC-2 integration smoke

**Sub-plan**: `agent-workspace/session-plans/pending/044-S401-phase-g4-vhm-pdf-dogfood-bc-2-integration.md`

**Goal**: Ship `apps/cli/ingest_pdf_fundamentals.py` CLI + first VHM 2023/2024 annual-report dogfood through both G.2 + G.3 adapters → SqliteFundamentalRepository persistence → ratio_service smoke-test (6-ratio computation on extracted line items) → `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` report.

**Tasks** (6 sub-tracks expected at sub-plan author time):
1. D1: NEW `apps/cli/ingest_pdf_fundamentals.py` (~200-300 LOC; click CLI; --adapter pdfplumber|claude-vision flag; --ticker arg; --pdf-url arg; ratio_service smoke output)
2. D2: G.4 STEP 0 schema-migration evaluation — does FinancialStatement need ADDITIVE provenance fields per DD-3 deferred decision? If YES, additive migration via SqliteFundamentalRepository extension + ADR D-083 records decision
3. D3: VHM 2023 annual-report dogfood run — capture per-adapter accuracy on 10 canonical line items + cost-tracking (G.3 LLM cost) + wall-time + write `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` (~100-150 LOC report)
4. D4: NEW `apps/cli/test_ingest_pdf_fundamentals.py` (~150 LOC; integration tests with G.2 fixture + G.3 mocked claude output)
5. D5: ADR D-083 PROPOSED at `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc-2-integration.md` (~150-200 LOC; records dogfood outcome + gold-set state + schema-migration decision + per-adapter accuracy)
6. D6: NEW gold-set expansion to 5 documents at `tests/fixtures/pdf-gold-set/` (VHM 2023 / HPG 2023 / VIC 2023 / FPT 2023 / 1 scanned sample) + per-document expected-cells JSON

**Budget**: PLAN ~50-80K Opus + IMPL ~120-150K Opus + VERIFY ~30-60K Opus

**Sequencing**: SEQUENTIAL POST-G.2 + G.3 SHIP

**Phase G-prime DoD attestation** (per § H below): G.4 close = Phase G-prime DONE candidate; verifier checks all 4 sub-plans' DoD passed; ratio_service smoke produces valid 6-ratio output for VHM from extracted FS

---

## F. Cross-BC coordination (other bounded contexts that consume Phase G-prime output)

### F.1 BC-9 Outer-Loop (thesis-pipeline) consumer audit

**Status**: BC-9 Outer-Loop consumes BC-2 FinancialStatement via existing `Phase1DataGatherer` pattern (see `packages/application/analysis/use_cases/validate_thesis_phase1.py:?` per F.3 precedent at S380). Phase G-prime PDF adapter output flows into the SAME aggregate (FinancialStatement) so BC-9 consumer needs NO change for V0.

**Provenance carry-forward**: thesis_log artifacts (per F.5 precedent at S384) cite FinancialStatement.source_provider; if G.4 ratifies ADDITIVE provenance fields on FinancialStatement (per DD-3 deferred decision), thesis_log citation surface extends to include source_pdf_url + source_pdf_page automatically.

**No cross-BC contract change needed for V0.**

### F.2 BC-5 News Stream cross-pollination check

**Status**: BC-5 News Stream consumes article PDF research notes (broker reports per supplement § L line 363 + Phase D Theme L scope). PDF adapter pattern from Phase G-prime POTENTIALLY reusable for BC-5 research-note PDF ingestion.

**Recommended scope discipline**: V0 keeps adapters BC-2-scoped (FinancialStatement-shaped output); BC-5 research-note PDF reuse is **explicit OUT-of-scope per § A.3** (revisit trigger: BC-5 explicitly requests PDF research-note adapter). If reuse opportunity surfaces at G.4 dogfood, capture as promote-candidate in observation (per § L below).

### F.3 BC-1 Market Data + BC-3 Company Intelligence + BC-4 Macro non-coupling

**Status**: NONE of BC-1/BC-3/BC-4 consume PDF substrate currently. Phase G-prime does NOT touch any of these BCs. Independence preserved per `pyproject.toml:179-197` import-linter Bounded contexts independence contract.

---

## G. Reference corpus (≥3 candidate libraries with source-evidence)

Per L-S32-1 empirical-probe-first doctrine + dispatch brief mandate "cite source-evidence chain ≥3 reference repos":

### G.1 Library #1: pdfplumber + camelot (supplement § J.3 candidate 1)

- **Repository**: github.com/jsvine/pdfplumber + github.com/atlanhq/camelot (per master-planner general knowledge; cited in supplement § J.3 line 298)
- **License**: MIT (pdfplumber) + MIT (camelot-py)
- **Source-evidence chain**:
  - supplement § J.3 line 298: "Pure-Python adapter — pdfplumber + camelot for text + table extraction. Best for digital PDFs (most VN listed companies' company-website FS)"
  - supplement § J.5 line 312: I-S2 charter-compliance — "Every extracted FS cell preserves source_url + as_of_date + page_number + extraction_method (pdfplumber / camelot / claude-vision)"
  - parent plan-033 § N table line 873: Phase G-prime budget ~400-600K estimate

### G.2 Library #2: docling (NEW candidate this audit)

- **Repository**: github.com/DS4SD/docling (per master-planner general knowledge; recent IBM open-source release)
- **License**: MIT (clean for stockforge proprietary use)
- **Source-evidence chain**:
  - Master-planner general knowledge: IBM open-sourced docling 2024-2025 as modern alternative to pdfplumber+camelot; layout-aware extraction; markdown output; built-in OCR via tesseract
  - **NO direct citation in supplement § J** — surfaced by THIS master plan as alternative for L-S32-1 empirical probe; G.1 IMPL ratifies via empirical comparison
  - StockForge VBW gap: NO reference repo in `C:/htdocs/research/` uses docling — empirical probe is the only way to validate fit

### G.3 Library #3: pypdf (FinceptTerminal precedent + supplement § J.2 cited)

- **Repository**: github.com/py-pdf/pypdf (BSD-3-Clause)
- **License**: BSD-3-Clause (clean)
- **Source-evidence chain**:
  - `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py:45-60` — `_load_reader()` tries pypdf first, falls back to PyPDF2; PATTERN-PROVEN in production-grade FinceptTerminal codebase
  - supplement § J.2 line 289: crawl4ai `NaivePDFProcessorStrategy` uses pypdf-based implementation (at `crawl4ai/processors/pdf/processor.py:1-100`) — but per supplement § J.5 line 313 "Naive impl insufficient for VN broker reports"
  - **Verdict for empirical probe**: pypdf likely WEAK for tables (its strength is text-only extraction); included in G.1 empirical baseline to quantify table-extraction-quality gap vs pdfplumber+camelot OR docling

### G.4 Library #4-7 (NOT in G.1 probe; documented for completeness + deferral)

| Library | Why NOT in G.1 probe | Deferral revisit trigger |
|---|---|---|
| **pymupdf** | AGPL-3.0 license blocker for stockforge proprietary use (pyproject.toml:7) | Reconsider if project-owner accepts AGPL-3.0 commercial-license cost OR stockforge license changes |
| **unstructured** | Heavy dep stack (similar to crawl4ai per A-02 § 5 wholesale-port-low fit); MAY work but bloat risk | Reconsider if G.1 winner (pdfplumber+camelot OR docling) fails accuracy gate (<70%) |
| **Claude vision API direct** | Memory-rule violation (anthropic_api_to_subagent); use existing claude CLI substrate instead | G.3 sub-plan IMPLEMENTS the claude CLI substrate path |
| **AzureDocumentIntelligence / AWS Textract / GCP Vision** | Paid cloud services; out of V0 scope per cost discipline + § A.3 deferral | Cost-justification trigger: pure-Python + claude vision both fail (<90% accuracy on gold set) AND user authorizes paid cloud spend |

### G.5 Reference-repo precedent: FinceptTerminal cninfo_pdf_*.py pattern (PATTERN-PORT only)

- `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py` (80 LOC partial read):
  - Pattern 1: `_load_reader()` at :45-60 — pypdf → PyPDF2 fallback chain for runtime library availability
  - Pattern 2: SHA256-based dedupe checkpoint (`_sha256_file()` at :34-42 + state.json checkpoint at :63-75)
  - Pattern 3: Per-page text extraction loop with state preservation
  - **License posture**: FinceptTerminal = AGPL + Commercial; ZERO code-port; **pattern-port only** per A-04 license posture
- `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_downloader.py` (40 LOC partial read):
  - Pattern 1: SHA256-based dedupe + index.json checkpoint
  - Pattern 2: Retry-with-backoff for PDF source URL fetcher
  - **License posture**: SAME as above; pattern-only

---

## H. DoD criteria (Phase G-prime close attestation; measurable per Charter Principle 8)

Per parent plan-033 § Phase-DoD pattern + Charter Principle 8 calibration-over-confidence:

### H.1 Phase G-prime DoD grid (PG-DONE-1..10)

- **PG-DONE-1**: PdfTableExtractorPort ABC shipped at `packages/application/fundamental/pdf_table_extractor_port.py` + ExtractedFinancialStatement at `extracted_financial_statement.py`; mypy --strict + ruff clean
- **PG-DONE-2**: G.1 empirical bake-off report `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` shipped with ≥3 candidate libraries × 4 metrics × 1 gold sample empirical data; winner ratified
- **PG-DONE-3**: Pure-Python adapter (G.2 winner) shipped at `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py`; pyproject.toml dep added with rationale; ≥80% accuracy on 5-document gold set
- **PG-DONE-4**: Claude vision adapter (G.3) shipped at `packages/infrastructure/fundamental/pdf_claude_vision_fundamental_adapter.py`; EchoValidator gate at `echo_validator.py`; per-extraction cost tracked
- **PG-DONE-5**: VHM annual-report dogfood (G.4) run end-to-end; thesis_log artifact `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` shipped; ≥8/10 canonical line items extracted per G.2 OR G.3 adapter
- **PG-DONE-6**: SqliteFundamentalRepository persists VHM FinancialStatement extracted from PDF; ratio_service computes 6 ratios (PE / PB / ROE / ROA / DEBT_EQUITY / NET_MARGIN) without error
- **PG-DONE-7**: 5-document gold-set established at `tests/fixtures/pdf-gold-set/` with SHA256 manifest; per-document expected-cells JSON
- **PG-DONE-8**: Charter compliance — I-S1 (NO LLM math: vision OCR is character-recognition; deterministic parser produces Money) + I-S2 (every extracted cell cites source_pdf_url + page + as_of) + I-S20 (calibration_grade='D' V0; gold-set extraction accuracy recorded per adapter) + I-S35 (research-aid framing preserved)
- **PG-DONE-9**: All 4 sub-plans 041/042/043/044 mv pending → completed; 4 PROPOSED ADRs (D-080/D-081/D-082/D-083) authored + AUTO-ACCEPTED at IMPL-tier per severity-schema
- **PG-DONE-10**: Phase G-prime CLOSE row prepended to current-execution.md; observation file per master-planner mandate; mistake-log digest update OR explicit "no mistakes this phase"

### H.2 Per-adapter accuracy floor (Charter Principle 8 calibration measurement)

- **G.2 pure-Python adapter**: ≥80% canonical-cell extraction accuracy on 5-document gold set (V0 floor; ≥90% target post-V0)
- **G.3 Claude vision adapter**: ≥85% canonical-cell extraction accuracy on 5-document gold set; per-cell cost ≤$0.10 average
- **Combined-adapter accuracy ceiling**: if EITHER G.2 OR G.3 hits ≥90% on a given cell, that cell counts as successful extraction (G.4 dogfood reports combined ceiling for V0 production-readiness assessment)
- **Below-floor remediation path**: if Phase G-prime CLOSE empirical accuracy < V0 floor on 2+ adapters, schedule Phase G-prime-V2 PLAN session for tuning (cell-label-map expansion + parser-edge-case handling); do NOT block Phase G-prime CLOSE on V0 floor failure — capture as Phase G-prime-V2 follow-up per AP-7 named revisit trigger

### H.3 Phase G-prime CLOSE = CODE-READY attestation pattern (per Phase F-prime precedent)

Per L-S385-2 attestation-vocabulary discipline promoted at S388 harness sweep N+1:
- **CODE-READY-V0**: all 4 sub-plans SHIPPED + verified; adapters operational; dogfood ran successfully on VHM; ratio_service smoke PASS
- **CODE-READY-DATA-PARTIAL**: V0 above + 5-document gold set established; per-adapter accuracy ≥V0 floor on 1+ documents (V0 minimum)
- **CODE-DONE-DATA-PENDING-CALIBRATION**: V0 above + ≥V0 floor on all 5 gold-set documents; per-adapter calibration_grade='D' baseline (calibration database = post-MVP per § A.3 deferral)

Phase G-prime DONE attestation = **CODE-READY-DATA-PARTIAL** minimum (per L-S385-2); upgrade to CODE-DONE-DATA-PENDING-CALIBRATION as G.4 gold-set construction completes.

---

## J. Risks + Mitigations (RM-G-1 through RM-G-8)

### RM-G-1: G.1 empirical probe finds NO clear winner (all 3 candidates <70% accuracy)

- **Likelihood**: MEDIUM (VN-specific PDFs are not surveyed in any candidate library's test corpus)
- **Impact**: HIGH (G.2 pure-Python adapter has no clear winner; pivot needed)
- **Mitigation**: G.1 IMPL STOP-AND-ASK fires per § K.2.a; main session ratifies pivot path via Q-INT-2026-05-G-prime-2 (options: expand probe to 5 documents + extended libraries / accept current best with named limitation / pivot to Claude vision G.3 as primary winner with pure-Python deferred / cancel Phase G-prime + revisit at Phase 2)

### RM-G-2: pymupdf license escalation (AGPL-3.0 viral for stockforge proprietary)

- **Likelihood**: LOW (G.1 probe excludes pymupdf per § C.0.2 license matrix)
- **Impact**: HIGH (if pymupdf chosen, stockforge proprietary license at risk)
- **Mitigation**: G.1 STEP 0 license probe excludes pymupdf BEFORE empirical comparison; flag explicit in § C.0.2 + § K.2.a

### RM-G-3: Claude CLI substrate does NOT support PDF/image input (G.3 STOP-AND-ASK)

- **Likelihood**: MEDIUM-HIGH (claude CLI Read-tool image input is unverified per § C.0.5 OPEN QUESTION)
- **Impact**: HIGH (G.3 sub-plan blocks if claude CLI lacks vision)
- **Mitigation**: G.3 STEP 0 empirical probe BEFORE adapter implementation; STOP-AND-ASK fires per § K.2.b; pivot options: (a) tesseract OCR + vie.traineddata fallback / (b) extract images from PDF via pdfplumber.images + dispatch to claude CLI as PNG attachment / (c) defer G.3 to V2 if no CLI vision substrate; G.4 dogfood proceeds with G.2-only

### RM-G-4: VN-locale VND-string parser edge cases (parentheses-negative + dot-thousand-separator)

- **Likelihood**: HIGH (Vietnamese locale opposite-of-US conventions + accounting parenthesis-negative + unit-header "Triệu đồng" scaling)
- **Impact**: MEDIUM (parser bugs produce wrong Money.amount; downstream ratio_service computes wrong ratios silently)
- **Mitigation**: G.2 IMPL D1 includes ≥20 unit-test edge cases (positive integer / negative parenthesis / dot-separator / Triệu-đồng-unit / Tỷ-đồng-unit / em-dash placeholder / typo-resistant); G.4 dogfood VHM expected-cells JSON validates end-to-end

### RM-G-5: Vietstock public source URL pattern instability (G.4 dogfood ticker URL drift)

- **Likelihood**: LOW (Vietstock public is stable mainstream source per supplement § J.1)
- **Impact**: MEDIUM (G.4 dogfood needs reliable PDF URL for reproducibility)
- **Mitigation**: G.4 PLAN STEP 0 captures VHM 2023 PDF URL + SHA256 manifest into `tests/fixtures/pdf-gold-set/SHA256.txt`; downloaded once + checked-in (small file ~3-5MB acceptable per repo size)

### RM-G-6: Cell-label normalization drift between companies (VHM uses different label than HPG)

- **Likelihood**: HIGH (per § C.0.3 audit, "Doanh thu thuần" vs "Doanh thu bán hàng" granularity drift)
- **Impact**: MEDIUM (cell-label map needs per-company variants OR canonical-form normalization layer)
- **Mitigation**: G.2 IMPL D1 cell-label map includes ≥3 Vietnamese variants per LineItemKey + ≥3 English variants (bilingual report support); G.4 dogfood expansion to 5-document gold set exercises drift; AP-7 named revisit trigger for per-company variant DSL if >5 variants per key surfaces

### RM-G-7: G.3 cost runaway (Claude vision per-cell cost × 10 cells × N pages)

- **Likelihood**: MEDIUM (typical VHM annual report = 80-150 pages; per-cell vision OCR may cost $0.50-$2.00 per page)
- **Impact**: MEDIUM (dogfood cost may exceed user expectations; calibration_grade='D' V0 cap helps)
- **Mitigation**: G.3 PLAN STEP 0 ratifies per-extraction cost ceiling (~$5-10 per VHM annual report); G.3 IMPL implements page-targeting (extract only IS+BS+CF table-pages via deterministic page-classification BEFORE LLM dispatch); G.4 dogfood tracks actual cost vs budget; STOP-AND-ASK if cost runs > 2× budget per § K.2.b

### RM-G-8: Parallel-dispatch coordination collision (G.2 + G.3 touching same test fixture)

- **Likelihood**: LOW (G.2 + G.3 have disjoint adapter files; shared `tests/fixtures/pdf-gold-set/` is read-only)
- **Impact**: LOW (test fixture additions are append-only; SHA256.txt manifest is the only write-shared file)
- **Mitigation**: SHA256.txt is final-aggregation file; G.2 OR G.3 (whichever ships second) appends fixture rows; main session orchestrator detects collision via pre-commit-hook + rebases (or G.2 sub-plan ships fixture first per main session sequencing decision)

---

## K. Charter-tier-surface FLAGS (sub-plan-level; main session decides whether to fire AskUserQuestion gate)

Per parent plan-033 § K pattern: this master plan SURFACES potential charter-tier-surface gate triggers without FIRING; main session DECIDES via AskUserQuestion if any surface as decision-blockers.

### K.1 NON-BLOCKING design recommendation (default)

This plan's RECOMMENDATION: **NON-BLOCKING Phase G-prime entry**. Architect-recommended defaults chosen per DD-1/DD-2/DD-3/DD-4/DD-5/DD-6/DD-7/DD-8. Sub-plan STEP 0 STOP-AND-ASK clauses fire ONLY IF empirical evidence contradicts architect-recommended defaults.

Phase G-prime PROCEEDS to sub-plan 041 dispatch without user gate IF AND ONLY IF main session reviews this master plan + accepts the 8 DDs.

### K.2 Charter-tier-surface candidates (sub-plan-level STOP-AND-ASK triggers)

#### K.2.a — pymupdf AGPL-3.0 license escalation OR no-clear-winner empirical pivot

- **Trigger**: G.1 IMPL empirical probe reveals (a) pymupdf significantly better than pdfplumber+camelot+docling+pypdf on VN PDFs AND project-owner WOULD accept AGPL-3.0 commercial license, OR (b) ALL 3 baseline candidates score <70% on canonical-cell extraction
- **Charter-tier-surface**: license posture decision (stockforge license="Proprietary" per pyproject.toml:7 vs AGPL-3.0-viral) OR Phase scope pivot (V0 retargeting)
- **Default if NOT fired**: G.1 winner = whichever of pdfplumber+camelot OR docling OR pypdf scores highest on 4 metrics
- **Main session decision path**: AskUserQuestion gate Q-INT-2026-05-G-prime-1 IF triggered

#### K.2.b — Claude CLI substrate vision-input feasibility

- **Trigger**: G.3 STEP 0 empirical probe reveals claude CLI substrate does NOT support PDF/image input (per § C.0.5 OPEN QUESTION) AND G.3 cannot proceed via fallback paths in RM-G-3
- **Charter-tier-surface**: anthropic_api_to_subagent memory-rule scope question (does the rule mandate ONLY text input substrate OR also vision substrate; if claude CLI lacks vision, does direct Anthropic SDK vision call become a permitted exception?)
- **Default if NOT fired**: G.3 ships claude CLI substrate; vision-input feasibility VERIFIED at G.3 STEP 0
- **Main session decision path**: AskUserQuestion gate Q-INT-2026-05-G-prime-2 IF triggered

#### K.2.c — G.4 schema-migration for FinancialStatement provenance fields

- **Trigger**: G.4 STEP 0 empirical decision per DD-3 deferred — does FinancialStatement domain entity NEED ADDITIVE provenance fields for thesis-pipeline citation surface?
- **Charter-tier-surface**: domain-entity-shape question (additive vs application-layer-only)
- **Default if NOT fired**: ADDITIVE-ONLY migration to FinancialStatement (default=None for all new fields; backward compat preserved); existing vnstock adapter unaffected
- **Main session decision path**: NO AskUserQuestion needed (architect-recommended default per DD-3 + Karpathy P3); main session reviews G.4 IMPL output

### K.3 Charter-tier candidates FLAGGED but NOT raised

- I-S<N> new invariant for OCR-derived-cell semantics — N/A this phase (Rule 16 mode #2 covers); revisit at Phase G-prime-V2 if vision substrate produces consistent provenance gap
- New Rule for extractor-version provenance schema — N/A this phase (additive field per DD-3 covers); revisit at Phase 2 if BC-2 schema evolves significantly
- New Rule 16 mode for OCR-character-recognition vs LLM-cell-derivation — N/A this phase (existing mode #2 deterministic-pipeline echo covers); revisit if G.3 surfaces edge case where LLM derives derived-cell values (defer to G.3 STEP 0 evaluation)

### K.4 Ratification path (this master plan)

Main session reviews + ratifies via standard plan-027/plan-033 path:
1. Read this master plan markdown
2. Verify § K FLAGS understood; NO blocking unless triggered by sub-plan STEP 0 empirical probe
3. Dispatch sub-plan 041 author (sandwich-architect at S392) per § N.2 sequencing
4. Sub-plan 041 STEP 0 fires K.2.a IF empirical probe contradicts architect-recommended default

---

## L. Promotion candidates (per AP-7 pre-flag pattern; capture-now, evaluate-at-Phase-close)

Per parent plan-033 § promotion candidate pattern + AP-23 promote-or-retire calculus:

| Candidate | Source | Promotion-readiness criterion | Notes |
|---|---|---|---|
| **PCG-1**: PDF cell-label normalization table pattern (cell text → LineItemKey) | DD-2 + G.2 IMPL pattern | If used unchanged across G.2 + G.3 + G.4 + BC-5 research-note re-use surface (Phase 2) | LIKELY promote at G.4 close; mirror vnstock_fundamental_adapter._VNSTOCK_LINE_ITEM_MAP precedent |
| **PCG-2**: VND-string parser (Vietnamese-locale + parentheses-negative + Triệu/Tỷ-đồng unit scaling) | RM-G-4 + G.2 D1 unit tests | If reused in BC-1 OHLCV adapter OR BC-3 Company Intelligence shareholder-amount parser | LIKELY promote — Vietnamese-locale numeric parsing is cross-BC utility |
| **PCG-3**: EchoValidator post-LLM cell-validation pattern (Rule 16 mode #2 implementation) | DD-6 + G.3 IMPL D3 | If reused for ANY LLM-claimed-numeric-value gate (BC-5 News claim extraction + BC-6 KOL recommendation parser) | LIKELY promote — Rule 16 mode #2 implementation primitive |
| **PCG-4**: SHA256-based PDF source dedupe + checkpoint pattern (FinceptTerminal cninfo precedent port) | G.5 reference + G.2/G.3 D3 | If reused for BC-5 News PDF research-note ingestion | DEFER promote — single-instance V0; promote on 2nd reuse |
| **PCG-5**: empirical-probe-first sub-plan structure (G.1 = probe-then-pick precedent) | L-S32-1 + DD-4 + sub-plan 041 | If reused for ANY future library-choice sub-plan (e.g. BC-1 backtesting framework choice; BC-5 News HTML→Markdown choice — already shipped at Phase D) | DEFER promote — needs 2nd-instance to validate sub-plan template; L-S32-1 skill already exists, just needs sub-plan-shape codification |
| **PCG-6**: ExtractedX intermediate dataclass pattern (per-adapter polymorphism without domain pollution) | DD-2 | If reused for BC-5 News ExtractedClaim (already exists per F.3 precedent) + BC-6 KOL ExtractedRecommendation | ALREADY promote — pattern is in production at BC-5 since S368; G.1 extends to BC-2; this is reuse not novel |
| **PCG-7**: Gold-set fixture pattern for empirical calibration (`tests/fixtures/pdf-gold-set/` + SHA256 manifest + per-document expected-cells JSON) | G.4 D6 | If reused for BC-5 News calibration gold set OR BC-6 KOL recommendation gold set | LIKELY promote — Charter Principle 8 calibration over confidence operationalization primitive |

Sub-plans 041/042/043/044 STEP 5.5 (per harness sweep N+1 D6 promotion at S388) capture additional promotion candidates surfaced at IMPL time. AP-23 calculus applies at Phase G-prime close (G.4 verifier session).

---

## N. Phase G-prime → H-prime sequencing recommendation

Per parent plan-033 § N table line "H-prime — DEFER to Phase 2 dashboard work entry" + master plan § 6.4.5:

### N.1 Critical-path analysis

| Phase | Theme | Critical-path dependency | Budget envelope | When to start |
|---|---|---|---|---|
| **F-prime (CODE-DONE-DATA-PENDING at S386)** | H (BC-8 Multi-Perspective) | Data-corpus ingestion (operational track; separable per architect-design intent) | DONE-CODE; data corpus PENDING per S386 attestation | DATA: user-authorization gate per Charter Principle 7 for real API budget commitment (current-execution.md:185) |
| **G-prime (this plan; current)** | J (PDF + table extraction BC-2) | Independent of Phase F-prime (no contention per file scope: BC-2 fundamental vs BC-8 personas); parent plan-033 § N authorizes PARALLEL dispatch | ~720-1160K Opus across 12-16 sessions per § A.4 refined estimate | NOW (S391 master-plan; S392 first sub-plan) |
| **H-prime (next)** | K (UX/Output — Streamlit dashboard polish) | Phase 2 work; not on Phase 1 critical path; supplement § K.4 — "Wave-1 IMPL = NONE in Theme K" + master plan § 6.4.5 deferral; consumer of BC-2 + BC-8 outputs once both Phase F-prime + Phase G-prime DONE | TBD per H-prime master-plan (Phase 2 entry estimate ~200-400K) | DEFER to Phase 2 dashboard work entry per master plan § 6.4.5 |

### N.2 Recommended sequencing

**Sequential Phase G-prime ship**:
- S391 (now): Phase G-prime master plan = this file
- S392/S393/S394: sub-plan 041 (G.1 empirical bake-off + PdfTableExtractorPort ABC) PLAN+IMPL+VERIFY
- S395/S396/S397: sub-plan 042 (G.2 pure-Python winner adapter) PLAN+IMPL+VERIFY (PARALLEL with sub-plan 043)
- S398/S399/S400: sub-plan 043 (G.3 Claude vision adapter + EchoValidator) PLAN+IMPL+VERIFY (PARALLEL with sub-plan 042)
- S401/S402/S403: sub-plan 044 (G.4 VHM dogfood + BC-2 integration) PLAN+IMPL+VERIFY (sequential POST-G.2+G.3 ship)
- S403 close: Phase G-prime DONE (CODE-READY-DATA-PARTIAL minimum per L-S385-2 attestation discipline)

**Parallel dispatch within Phase G-prime**:
- After sub-plan 041 VERIFY ships at S394: main session may dispatch sub-plans 042 + 043 PLAN authors in parallel (architect-tier parallel-dispatch precedent S345 4-parallel supports 2-parallel; well within plan-025 DD-5 3-parallel ceiling)
- After 042 + 043 VERIFY both ship: sub-plan 044 PLAN author sequential

**Cross-phase parallel dispatch** (per parent plan-033 § N authorization):
- Phase G-prime sub-plans 041-044 can run PARALLEL with Phase F-prime data-corpus ingestion operational track (separable per architect-design intent; current-execution.md:185-186 line "Data-corpus ingestion track — operational step requiring real API budget")
- Phase F-prime data-corpus ingestion does NOT touch BC-2 fundamental adapter files (touches BC-5 news + BC-1 OHLCV + BC-2 vnstock-existing-adapter only); ZERO collision

**Deferred Phase H-prime**:
- H-prime triggers at Phase 2 dashboard work entry per master plan § 6.4.5
- Dashboard CONSUMES Phase G-prime BC-2 output + Phase F-prime BC-8 personas output; H-prime entry blocks on BOTH Phase F-prime DATA-CORPUS-DONE + Phase G-prime DONE

### N.3 Total cumulative budget projection

- Phase G-prime: ~720-1160K Opus / ~12-16 sessions wall-clock (with sub-plan 042+043 parallel = save ~2-3 sessions)
- Phase F-prime data-corpus ingestion: parallel-dispatchable; operational rather than IMPL; budget TBD per user-authorization gate
- Phase H-prime: deferred to Phase 2 entry

**Wall-clock projection**: Phase G-prime sequential = ~12-16 sessions × 1 turn each at full autonomous = ~12-16 turns; with sub-plan 042+043 parallel = ~10-14 turns total to Phase G-prime close.

### N.4 Phase F-prime CODE-DONE-DATA-PENDING attestation acknowledgment

**Phase F-prime CODE-DONE-DATA-PENDING at S386 commit 90b27db** per current-execution.md:166-189 — sandwich-verifier PASS-WITH-CONCERNS verified F.5 dogfood (S385 commit `af485e0b6430e2b36`); ADR D-078 ACCEPTED. **This satisfies parent plan-033 § N parallel-dispatch authorization gate** ("PARALLEL with Phase F-prime after sub-plan 034 close" — sub-plan 034 closed at S376; Phase F-prime entire phase reached CODE-DONE at S386 — gate satisfied with margin).

Phase G-prime entry per THIS master plan is therefore authorized without further user-ratification gate; main session reviews + dispatches sub-plan 041 author per § N.2 sequencing.

---

## P. Compliance attestation (master-plan authoring session S391)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work — L-S354-2/L-S366-4/L-S369-1 planner-stats infrastructure cascade already PROMOTED + LIVE via S388 harness sweep N+1 commit 78089ba per current-execution.md:147; this plan inherits the now-live `.planner-stats.tsv` writer)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 24+ source files read inline per § A.4)
- AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; AP-7 named revisit triggers explicitly cited in PCG-4 + PCG-5)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED as PCG-1..7 for promote-or-retire calculus at Phase G-prime close; promotion-on-2nd-recurrence calculus respected)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = master plan + observation; main session dispatches sub-plan 041 author per § N sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing recommendation in § N is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-066 not touched (Phase D Theme L closed; Theme J INFORMATIONAL precedent for ABC-vs-Protocol decision in DD-1)
- D-072 not touched (Phase E.3 closed; Theme J mirrors transport-flip strategy without modifying D-072 ADR text — G.3 reuses claude_cli_transport substrate per DD-6)
- D-074 not touched (Phase F.1 closed; G.3 mirrors transport-flip pattern per DD-6 without modifying D-074 ADR text)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (master plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- I-S1 ✓ (this plan PROMOTES I-S1 satisfaction in Theme J implementation per DD-4 + DD-6; does not violate; LLM-vision substrate is OCR character-recognition not number-derivation per Rule 16 audit § C.0.4)
- I-S1-1 (Rule 16) ✓ (per § C.0.4 audit; mode #2 deterministic-pipeline echo for cell numeric values + mode #1 categorical surrogate for optional confidence field by-construction)
- I-S2 ✓ (every plan claim cites source file:line per § A.4 + § G 3-source-evidence chain)
- I-S20 ✓ (per-adapter calibration measurement target ≥V0 floor on 5-document gold set per § H.2)
- I-S22 ✓ (data lineage extended via ExtractedFinancialStatement provenance fields per DD-3)
- I-S34 ✓ (public sources only: VN company website FS + Vietstock public; no paid leak channels)
- I-S35 ✓ (Theme J output = FinancialStatement ingestion to BC-2 → BC-9 thesis pipeline; NO buy/sell surface introduced)
- Phase 1b COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; L-S354-2/L-S366-4/L-S369-1 cascade NOW PROMOTED via S388; cold-start declared on new task_class="pdf-extraction-master-plan" only)
- 3-source-evidence chain populated per § G (3 candidate libraries with cited source-evidence; +1 reference repo pattern FinceptTerminal cninfo precedent for completeness)
- FinceptTerminal AGPL+Commercial license caveat A-04 § 5 ACKNOWLEDGED + pattern-port not code-port mandate ✓
- crawl4ai Apache-2.0 + Attribution clause A-02 LICENSE:54-67 ACKNOWLEDGED (G.1 pattern-port from PDFContentScrapingStrategy if pdfplumber+camelot OR docling winner)
- anthropic_api_to_subagent memory-rule G.3 surface flagged in § C.0.5 + DD-6 + RM-G-3 ✓
- L-S32-1 empirical-probe-first SKILL doctrine ACKNOWLEDGED in DD-4 + § C.0.2 + § G + § PCG-5 ✓
- Phase F-prime CODE-DONE-DATA-PENDING attestation S386 90b27db acknowledged in § N.4 (parallel-dispatch gate satisfied) ✓
- Phase 1 sub-plan FOCUSED_IMPL anti-pattern (Session 4 catastrophic mix) avoided — Phase G-prime decomposed into 4 sub-plans not bundled into 1 ✓

---

**END OF MASTER PLAN 040-S391-PHASE-GPRIME-MASTER-PLAN**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches sub-plan 041 author per § N sequencing.
