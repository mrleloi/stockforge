---
plan_id: 041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc
target_session: S394 (sandwich-dev FOCUSED_IMPL executing this plan D1-D5; S393 is parallel data-corpus operational plan-045 IMPL per parent plan-040 § N.2 + dispatch brief § J)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S392; IMPL by sandwich-dev at S394; VERIFY by sandwich-verifier AP-1 at S395 — note parent plan-040 § N.2 originally numbered S392/S393/S394 but dispatch brief § J reserves S393 for parallel plan-045 IMPL; sequencing renumbered to S392 PLAN / S394 IMPL / S395 VERIFY)
budget:
  - this PLAN session (S392 architect): ~150-200K Opus PLAN per recalibrated CLAUDE.md table (cold-start declared for task_class="pdf-extraction-plan"; nearest analog crawler-adapter-plan n=1 from S337 plan-020 ~80K Sonnet + multi-perspective-impl-plan n=1 from S374 ~140K Opus; +30-50% novelty reserve for empirical-probe protocol authoring + 4-metric harness + license-matrix audit)
  - sub-plan IMPL (S394 dev): ~150K Opus FOCUSED_IMPL (parent plan-040 § A.4 cites "G.1 IMPL may need extended budget ~150K for empirical probe execution"; ≥3 libraries × ≥1 VHM gold PDF + 4-metric report + ABC + intermediate dataclass + ADR)
  - sub-plan VERIFY (S395 verifier): ~80-140K Opus AP-1 fresh-context per recalibrated CLAUDE.md VERIFY-Opus column (80-180K)
phase: G-prime (Theme J — BC-2 Fundamental Data PDF + table extraction; sub-theme G.1 empirical library bake-off + PdfTableExtractorPort ABC contract design — FIRST + SEQUENTIAL FIRST sub-plan of Phase G-prime per master plan-040 § N.2; blocks G.2 + G.3 + G.4)
track: Wave 1 Theme J sub-theme G.1 — PdfTableExtractorPort ABC + ExtractedFinancialStatement intermediate dataclass + empirical bake-off report (`agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md`) ratifying winner library for downstream G.2 pure-Python adapter
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN authored S391; THIS is the first sub-plan per § E.1 + § N.2 sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.5 + § 6.4.4
predecessor: 040-S391-phase-gprime-master-plan (master plan ratifying Phase G-prime entry; THIS sub-plan satisfies its § E.1 contract per DD-1 ABC location + DD-2 ExtractedFinancialStatement intermediate dataclass + DD-3 provenance at application layer + DD-4 empirical probe protocol + DD-5 sequential-post-G.1 + DD-8 ADR D-080)
successor: S394 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S395 sandwich-verifier AP-1 → sub-plans 042 (G.2 pure-Python winner adapter) + 043 (G.3 Claude vision adapter) parallel-dispatch at S396 per parent plan-040 § N.2 sequencing (042 + 043 PARALLEL post-G.1 ship; 044 sequential POST-042+043)
architect: S392 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase G-prime entry per parent plan-040 § N.2 sequencing (current-execution.md routing pointing to plan-040 master ratification; sub-plan 041 = first downstream sub-plan author dispatch)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED variant with COLD-START declared for task_class="pdf-extraction-plan" — no precedent in .planner-stats.tsv or sessions-rollup.tsv; nearest analogs crawler-adapter-plan n=1 from S337 plan-020 + multi-perspective-impl-plan n=1 from S374 plan-034; PDF-extraction-plan novel portions = empirical-probe protocol authoring + 4-metric harness design + library-license-matrix audit)
executing_agent: N/A this PLAN session; S394 sandwich-dev FOCUSED_IMPL + S395 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master plan-040 § E.1 sub-plan contract (DD-1 ABC at packages/application/fundamental/ + DD-2 ExtractedFinancialStatement intermediate dataclass + DD-3 provenance at application layer + DD-4 4-metric empirical probe protocol + DD-5 sequential-post-G.1-ratification + DD-8 ADR D-080 PROPOSED at IMPL-tier)"
  - "Master plan-040 § E.1 BLOCKS sub-plans 042 (G.2) + 043 (G.3) + 044 (G.4) — G.1 is foundational; G.2 PLAN author cannot begin until G.1 IMPL ratifies empirical winner per DD-5"
  - "D-066 ACCEPTED 2026-05-?? (CrawlerAdapter ABC at packages/application/news/ports/crawler_adapter.py — INFORMATIONAL precedent for ABC-vs-Protocol decision per DD-1; same Strategy ABC pattern + __init_subclass__ runtime enforcement + per-adapter optional-import gate)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain BINDING for every NEW/MODIFIED file authored under this sub-plan)"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S394 dev commit boundary"
  - "D-062 (atomic-write-doctrine) — applies to bake-off probe state-cache writes if any (tmp+os.replace pattern)"
  - "D-064 (path-safety 5-invariant contract) — BINDING for ANY new file-path code in this sub-plan; bake-off probe consumes PDF source paths + writes report output path → uses packages/_shared/path_safety.py helpers (safe_user_path for PDF input + safe_run_dir for report output)"
  - "D-065 Rule 16 (numeric-field discipline) — N/A this sub-plan (G.1 ships ABC contract + intermediate dataclass + bake-off report; no new LLM-numeric fields introduced; cell-numeric Money fields covered at G.2 IMPL via mode #2 deterministic-pipeline echo per parent plan-040 § C.0.4 audit)"
  - "D-067 PROPOSED-AT-IMPL (planner-upgrade ADR plan-025 — Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 1 (NO LLM math — G.1 ships ABC contract; LLM-output path not introduced this sub-plan) + Principle 7 (Dogfood mandatory — G.4 dogfood is the V0 dogfood; G.1 ships substrate) + Principle 8 (Calibration over confidence — empirical bake-off IS the calibration substrate; ≥V0 floor per DD-4) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this sub-plan; product substrate only)"
  - "I-S1 (NO LLM math) — G.1 ships ABC + intermediate dataclass; no LLM-output path introduced; satisfied by construction"
  - "I-S2 (citation discipline) — bake-off report cites per-library license + repo + version per DD-4 metric 4"
  - "I-S20 (calibration over confidence) — bake-off report records empirical winner with 4-metric grid per DD-4; calibration_grade='D' V0 baseline for G.2/G.3 downstream"
  - "I-S22 (data lineage) — ExtractedFinancialStatement intermediate dataclass carries 6 provenance fields per parent plan-040 DD-2/DD-3"
  - "I-S34 (HARD REJECT — public sources only) — gold-set sourcing uses Vietstock public + VN company website only (NO paid-API leak channels per parent plan-040 binding decision)"
  - "I-S35 (research-aid framing) — G.1 ships data + infrastructure; output framing UNCHANGED"
  - "L-S32-1 empirical-probe-first skill (.claude/skills/empirical-probe-first/SKILL.md — MANDATORY for G.1 library shootout; PDF library landscape evolves fast; supplement § J.3 names pdfplumber+camelot+claude-vision but multiple candidates exist; G.1 IMPL MUST empirically probe ≥3 viable candidates on ≥1 VHM gold sample before adapter-port commit)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter — G.1 ships application-layer ABC + intermediate dataclass; infrastructure adapters defer to G.2/G.3 sub-plans)"
  - "skill .claude/skills/empirical-probe-first/SKILL.md (G.1 4-metric bake-off harness IS the probe-then-pick precedent — sub-plan template-shape codification per parent plan-040 § L PCG-5 promote candidate)"

binding_decisions:
  - "PHASE 1b CONSUMED + COLD-START DECLARED for task_class='pdf-extraction-plan' — nearest analog crawler-adapter-plan n=1 from S337 plan-020 (Theme L precedent) + multi-perspective-impl-plan n=1 from S374 plan-034 (5-sub-track template precedent); directional confidence MEDIUM at n=1 per-analog × 2 analogs; PDF-extraction sub-plan shape is novel (empirical bake-off protocol + 4-metric harness + library-license-matrix audit)"
  - "DD-1 PdfTableExtractorPort = ABC at packages/application/fundamental/pdf_table_extractor_port.py (PARENT plan-040 DD-1 verbatim; NOT packages/_shared/pdf/ per dispatch-brief deviation — VBW finding STEP 0.7 corrects dispatch brief: _shared/ is dep-free per packages/_shared/__init__.py; ABC for BC-2 lives in application layer per architecture.md BC-2 + D-066 CrawlerAdapter precedent which lives at packages/application/news/ports/crawler_adapter.py)"
  - "DD-2 ABC method surface = 4 abstract methods + 1 ClassVar (per parent plan-040 DD-1 + DD-2 + dispatch brief § D guidance ≤4 abstract methods Karpathy P2): extract(pdf_source: PdfSource) → ExtractedFinancialStatement + supports(pdf_path: Path) → bool + name() → str + extractor_version() → str; source_id ClassVar enforced non-empty at __init_subclass__ per D-066 CrawlerAdapter precedent (pattern adapted from crawl4ai/hub.py:24-35)"
  - "DD-3 Gold-set sourcing = 1 VHM 2023 annual report PDF + 1 HPG 2023 annual report PDF (2 documents minimum per dispatch brief § A guidance 'gold-set of 1-2 real VHM/HPG annual-report PDFs'); committed at tests/fixtures/pdf/ with SHA256.txt manifest; source = Vietstock public for canonical URL + commit-eligible per RM4 (public corporate annual reports are non-confidential disclosure-mandated artifacts)"
  - "DD-4 Winner-pick metric = cell-content-exact-match (NOT cell-count + NOT table-structure-match alone) — per parent plan-040 DD-4 metric 1 'Cell-extraction accuracy: % of 10 LineItemKey canonical cells correctly extracted vs manually-validated gold truth'; exact-match on canonical-cell numeric value (post-VND-string-parse) is the bar; cell-count is too lenient (false positives from spurious cells); structure-match is too strict (layout variability between adapters)"
  - "DD-5 Karpathy P3 surgical-scope discipline = ZERO touch to existing apps/crawlers/cafef_html_to_md.py (out of scope per parent plan-040 § A.3 + dispatch brief § B); BC-5 stays HTML-route per Phase D Theme L closed at S358; PDF substrate is BC-2-scoped this Phase per § A.3 deferral + § F.2 cross-pollination check"
  - "DD-6 Bake-off probe location = apps/cli/bench/pdf_bake_off.py (NEW directory + NEW one-off script); rationale apps/cli/ is already allow-listed for CLI substrate per existing 19 *.py CLI scripts at apps/cli/ + new sub-directory 'bench/' clearly signals one-off-probe NOT production; scripts/bench/ rejected because scripts/ contains hook substrate (scripts/hooks/) NOT product code; CLI substrate convention dominates"
  - "DD-7 ADR D-080 PROPOSED-AT-IMPL records (a) PdfTableExtractorPort ABC contract shape + (b) ExtractedFinancialStatement intermediate dataclass contract + (c) empirical winner ratification with 4-metric grid + (d) license posture per chosen library; 12-field schema floor per L-S389-2 harness sweep N+1 promotion; rationale + adversarial alternates documented per AOM ADR template"
  - "DD-8 ZERO pyproject.toml dep addition THIS sub-plan — bake-off probe installs ≥3 candidate libraries in ISOLATED venv (per parent plan-040 § E.1 dependencies clause 'pyproject.toml NOT modified at G.1; G.2 IMPL ratifies pyproject.toml dep addition for winner only'); preserves rollback path if all 3 candidates fail"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names prerequisites + revisit trigger"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (4-metric empirical bake-off harness pattern); 2nd recurrence in future library-choice sub-plan triggers promote-to-skill calculus (parent plan-040 PCG-5 candidate)"
  - "Karpathy P3 surgical-changes — this sub-plan adds ≤500 LOC across 5 files total: ABC ~100 LOC + dataclass ~80 LOC + bake-off probe ~150 LOC + tests ~80 LOC + ADR ~150 LOC + gold-set fixtures (binary PDFs, separate LOC count) = ~560 LOC code + binary PDFs (~3-5 MB total commit size acceptable)"
  - "Karpathy P2 simplicity — abstract method count ≤4 per dispatch brief § H RM4 anti-over-engineering; method surface chosen per DD-2 = 4 methods exactly (extract + supports + name + extractor_version)"
  - "VBW protocol mandatory — S394 dev MUST READ existing packages/domain/fundamental/** + packages/infrastructure/fundamental/vnstock_fundamental_adapter.py + packages/application/news/ports/crawler_adapter.py (D-066 precedent) + parent plan-040 § A + § D + ≥1 candidate library source (e.g. crawl4ai/processors/pdf/processor.py if accessible) empirically NOT memory; cite file:line for every architectural claim"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S394 is dev's)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main session commits this plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S394-* is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire in S394 dev session NOT this S392 PLAN session)"
  - "no touching Phase F-prime files (CODE-DONE-DATA-PENDING — separable operational data-corpus track unblocks F-prime later; Phase G-prime is parallel-eligible per parent plan-033 § N because file scope is disjoint — BC-2 fundamental vs BC-8 personas)"
  - "no touching existing PDF code (none exists per parent plan-040 § C.0.6 Grep audit; clean baseline)"
  - "no touching apps/crawlers/cafef_html_to_md.py (BC-5 stays HTML-route per DD-5 + parent plan-040 § A.3)"
  - "no G.2 winner-adapter IMPL work in THIS sub-plan (separate sub-plan 042 per parent plan-040 § E.2; G.2 BLOCKS_ON G.1 ship)"
  - "no G.3 Claude vision adapter work in THIS sub-plan (separate sub-plan 043 per parent plan-040 § E.3; G.3 BLOCKS_ON G.1 ship)"
  - "no G.4 BC-2 dogfood / SqliteFundamentalRepository integration work in THIS sub-plan (separate sub-plan 044 per parent plan-040 § E.4; G.4 BLOCKS_ON G.2 + G.3 ship)"
  - "no cleanup of any pre-existing PDF code (none exists per parent plan-040 § C.0.6 Grep audit; clean baseline)"
  - "no harness/hook changes — this plan ships product substrate (G.1 ABC + intermediate dataclass + bake-off probe + ADR); harness gaps surfaced go to next harness-stabilization sweep"
  - "no AskUserQuestion gate this PLAN session (per `full_autonomous_no_supervised` AskUserQuestion is for SCOPE/CHARTER only; § K.2.a charter-tier-surface trigger is CONDITIONAL on S394 dev STEP 0 empirical probe; this PLAN session has no charter/scope question)"
  - "every plan claim cites source file:line (per I-S2 + AOM + VBW protocol)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — gold-set sourcing uses Vietstock public + VN company website only"
  - "If S394 dev STEP 0 empirical probe surfaces a charter-tier need (pymupdf AGPL escalation OR no-clear-winner pivot), FLAG via § J K.2.a per parent plan-040 § K.2.a inheritance"
---

# S392 — Phase G.1 PdfTableExtractorPort ABC + Empirical Library Bake-Off sub-plan (FIRST sub-plan of Phase G-prime)

> **One-sentence intent**: AUTHOR foundational application-layer PDF-extraction primitives — (a) NEW `packages/application/fundamental/pdf_table_extractor_port.py` ABC with 4 abstract methods + `source_id` ClassVar runtime-enforced via `__init_subclass__` (D-066 CrawlerAdapter precedent) + (b) NEW `packages/application/fundamental/extracted_financial_statement.py` intermediate dataclass (6 provenance fields per parent plan-040 DD-3) + (c) NEW one-off empirical bake-off probe script at `apps/cli/bench/pdf_bake_off.py` running ≥3 candidate libraries (pdfplumber+camelot / docling / pypdf) against ≥1 VHM 2023 annual report gold-sample PDF + ≥1 HPG 2023 gold-sample with 4-metric grid (cell-content-exact-match accuracy / wall-time / dep footprint / license) + (d) NEW `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` empirical report ratifying winner library + (e) NEW `tests/fixtures/pdf/` gold-set with SHA256.txt manifest + (f) ADR D-080 PROPOSED at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` — without committing to a specific library in PLAN-tier (DD-8 isolated-venv probe), without modifying existing vnstock_fundamental_adapter.py (Karpathy P3 backward-compat preservation), without LLM-emitting any numeric field (I-S1 + Rule 16; G.1 has no LLM output path), and without bundling G.2 winner-adapter IMPL OR G.3 Claude vision adapter OR G.4 dogfood (clean separation per parent plan-040 § E sub-track decomposition).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent master plan-040 § E.1 + dispatch brief § A)

Build the **G.1 PdfTableExtractorPort ABC contract + empirical bake-off substrate** for StockForge BC-2 PDF table extraction, where:

- **PdfTableExtractorPort** is an ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW file in NEW directory) with **4 abstract methods + 1 ClassVar**:
  - `source_id: ClassVar[str]` — enforced non-empty at `__init_subclass__` (per D-066 CrawlerAdapter precedent at `packages/application/news/ports/crawler_adapter.py:60-78`; pattern adapted from crawl4ai/hub.py:24-35 BaseCrawler.__init_subclass__)
  - `@abstractmethod extract(pdf_source: PdfSource) → ExtractedFinancialStatement` — primary extraction method
  - `@abstractmethod supports(pdf_path: Path) → bool` — pre-check whether this adapter can handle a given PDF (e.g. scanned vs digital)
  - `@abstractmethod name() → str` — adapter human-readable name (e.g. "pdfplumber+camelot v0.10.0")
  - `@abstractmethod extractor_version() → str` — semver string for ExtractedFinancialStatement.extractor_version provenance field
- **ExtractedFinancialStatement** is an intermediate dataclass at `packages/application/fundamental/extracted_financial_statement.py` (NEW) per parent plan-040 DD-2/DD-3: frozen + slotted dataclass with 6 provenance fields (`source_pdf_url`, `source_pdf_page`, `source_pdf_sha256`, `extraction_method`, `extractor_version`, `extracted_at`) + `raw_cells: Mapping[str, str]` + `ticker: Ticker` + `statement_type: StatementType` + `period_end: date` + `filing_date: date` — bundles raw extracted cells BEFORE deterministic mapping to canonical `FinancialStatement.line_items: Mapping[str, Money]` (mapping happens in G.2/G.3 adapters)
- **Empirical bake-off probe script** at `apps/cli/bench/pdf_bake_off.py` (NEW; one-off probe per DD-6) runs ≥3 candidate libraries (per parent plan-040 § C.0.2 + DD-4 + dispatch brief § C STEP 0.2 + L-S32-1 empirical-probe-first skill):
  - **Library #1**: pdfplumber (MIT) + camelot-py (MIT) — supplement § J.3 primary candidate
  - **Library #2**: docling (MIT) — modern IBM open-source layout-aware alternative
  - **Library #3**: pypdf (BSD-3-Clause) — text-only baseline; FinceptTerminal cninfo_pdf_text_extractor.py:45-60 precedent
  - **Excluded**: pymupdf (AGPL-3.0 license blocker per parent plan-040 § C.0.2 + RM-G-2; STEP 0.1.b verifies still excluded) + Claude vision (deferred to dedicated G.3 sub-plan per parent plan-040 § E.3 + DD-6 BC-8 transport-flip mirror)
- **4-metric grid** per parent plan-040 DD-4 + dispatch brief § D guidance (DD-4 cell-content-exact-match per architect refinement):
  - **Metric 1 — Cell-content-exact-match accuracy**: % of 10 LineItemKey canonical cells (REVENUE / GROSS_PROFIT / NET_INCOME / EPS / SHARES_OUTSTANDING / TOTAL_ASSETS / TOTAL_EQUITY / TOTAL_LIABILITIES / BOOK_VALUE_PER_SHARE / OPERATING_CASH_FLOW per `packages/domain/fundamental/value_objects/line_item.py:33-45`) where extracted-cell-numeric-value (post-VND-string-parse) exact-matches manually-validated gold truth on the VHM + HPG gold samples
  - **Metric 2 — Extraction wall-time**: seconds per VHM annual report (typically 80-150 pages); reported as p50 + p95 across N=3 runs
  - **Metric 3 — Dependency footprint**: # transitive deps added to isolated probe venv + total install size in MB
  - **Metric 4 — License compatibility**: pyproject.toml license-claim alignment (stockforge="Proprietary" per `pyproject.toml:7`); library license string + repo URL + spdx-identifier cited
- **Bake-off report** at `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (NEW; ~250-350 LOC empirical report) with structure: § Library-by-library 4-metric table / § Winner ratification with rationale / § Adversarial alternates rejected with rationale (Karpathy P1 explicit) / § AP-7 named revisit triggers per non-winner / § STOP-AND-ASK trigger record (IF K.2.a fires)
- **Gold-set fixtures** at `tests/fixtures/pdf/` (NEW directory + NEW SHA256.txt manifest):
  - `vhm-2023-annual.pdf` (1 VHM annual report; ~3-5 MB; Vietstock public source URL captured in SHA256.txt as comment)
  - `hpg-2023-annual.pdf` (1 HPG annual report; ~3-5 MB; Vietstock public source URL captured in SHA256.txt as comment)
  - `expected_cells_vhm.json` (per-document expected-cell JSON manifest: maps each of 10 LineItemKey to expected numeric value at period_end + page-number + cell-context for manual-validation traceability)
  - `expected_cells_hpg.json` (same shape for HPG)
- **PdfSource** value object — lightweight frozen dataclass at `packages/application/fundamental/pdf_source.py` (NEW; ~40 LOC) with fields `pdf_path: Path + source_url: str + ticker: Ticker + statement_type: StatementType + period_end: date + filing_date: date`; encapsulates ABC input to avoid 6-positional-arg method signature
- **ABC contract tests** at `packages/application/fundamental/test_pdf_table_extractor_port.py` (NEW; ~80-100 LOC); test cases per dispatch brief § E STEP 3:
  - `__init_subclass__` enforces non-empty `source_id` ClassVar at class-definition time (mirror crawl4ai/hub.py:24-35 typecheck pattern)
  - Abstract method signature contract (can't instantiate without all 4 abstract methods implemented)
  - ExtractedFinancialStatement frozen-dataclass immutability + post_init validation
- **ADR D-080 PROPOSED** at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (NEW; ~150-200 LOC) per parent plan-040 DD-8 + L-S389-2 12-field schema floor

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — PdfTableExtractorPort ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW directory + NEW file; ~100 LOC: ABC + 4 abstract methods + `source_id` ClassVar + `__init_subclass__` typecheck + base error hierarchy + module docstring with crawl4ai attribution per D-066 precedent; foundation; blocks D2/D3/D4/D5)
2. **Sub-track D2** — ExtractedFinancialStatement + PdfSource value objects at `packages/application/fundamental/extracted_financial_statement.py` + `packages/application/fundamental/pdf_source.py` (NEW ~80 + ~40 LOC: 2 frozen+slotted dataclasses + __post_init__ validation + provenance field requirements; D-059 Python determinism BINDING; D-064 path-safety BINDING for PdfSource.pdf_path; blocks D3)
3. **Sub-track D3** — Empirical bake-off probe script at `apps/cli/bench/pdf_bake_off.py` (NEW directory + NEW file; ~150-200 LOC: argparse CLI + 3-library probe loop + 4-metric harness + JSON report writer + isolated-venv install instructions in module docstring; D-064 path-safety BINDING for PDF path inputs; reads gold-set from tests/fixtures/pdf/; writes bake-off report to agent-workspace/research/)
4. **Sub-track D4** — ABC contract tests at `packages/application/fundamental/test_pdf_table_extractor_port.py` + ExtractedFinancialStatement + PdfSource tests at `packages/application/fundamental/test_extracted_financial_statement.py` (NEW ~80-100 LOC each; pytest; test cases per § E STEP 3 below; +1 gold-set SHA256 manifest test that asserts fixture file presence + SHA256 match)
5. **Sub-track D5** — ADR D-080 PROPOSED at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (NEW; ~150-200 LOC; 12-field schema floor; records (a) ABC contract shape + (b) ExtractedFinancialStatement contract + (c) empirical winner ratification with 4-metric grid + (d) license posture + (e) chain D-066 → D-080 ABC pattern; rationale + adversarial alternates documented) + companion bake-off report `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (~250-350 LOC; per § A.1 structure)
6. **Gold-set fixtures**: `tests/fixtures/pdf/vhm-2023-annual.pdf` + `tests/fixtures/pdf/hpg-2023-annual.pdf` + `tests/fixtures/pdf/SHA256.txt` + `tests/fixtures/pdf/expected_cells_vhm.json` + `tests/fixtures/pdf/expected_cells_hpg.json` — bundled with D4
7. **STEP 0 evaluation observation** appended to `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-extractor-port-bakeoff.md`
8. **Session log + observation file** per CLAUDE.md § Session Protocol End
9. **Mistake-log digest entry** (M-S394-N if mistakes; OR explicit "no mistakes this session" statement per CLAUDE.md § Session Protocol End step 6)
10. **ZERO charter / constitution writes**
11. **ZERO new LLM-numeric schema fields** (Rule 16 N/A per parent plan-040 § C.0.4 audit — G.1 has no LLM output path; G.3 introduces it)
12. **ZERO new hooks** (product substrate; harness sweep is separate per CLAUDE.md hard rule "no harness/hook changes")
13. **ZERO new pyproject.toml deps** (DD-8 — isolated-venv probe at G.1 IMPL; G.2 IMPL ratifies winner dep addition)
14. **ZERO touch to existing vnstock_fundamental_adapter.py** (Karpathy P3 backward-compat preservation per parent plan-040 § A.1)
15. **ZERO touch to existing FinancialStatement domain entity** (per parent plan-040 DD-2; ExtractedFinancialStatement is intermediate dataclass at application layer, NOT domain)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| **G.2 pure-Python winner adapter IMPL** (concrete adapter using winner library + cell-label normalization map + VND-string parser + Money construction) | Separate sub-plan 042; G.2 BLOCKS_ON G.1 ship (winner library + ABC contract must exist before adapter can subclass) per parent plan-040 § E.2 + DD-5 sequential-post-G.1 | Sub-plan 042 dispatch after S395 verifier PASS per parent plan-040 § N.2 sequencing |
| **G.3 Claude vision adapter IMPL** (LLM-assisted OCR adapter via claude CLI substrate + EchoValidator post-OCR cell-validation gate per Rule 16 mode #2) | Separate sub-plan 043; G.3 BLOCKS_ON G.1 ship (ABC contract must exist before adapter can subclass) + claude CLI vision-input feasibility probe deferred to G.3 STEP 0 per parent plan-040 § C.0.5 + DD-6 BC-8 transport-flip mirror | Sub-plan 043 dispatch parallel with 042 post-S395 verifier PASS per parent plan-040 § N.2 |
| **G.4 BC-2 SqliteFundamentalRepository integration dogfood** (VHM annual-report end-to-end through both G.2 + G.3 adapters → SqliteFundamentalRepository persistence → ratio_service smoke-test + thesis_log artifact) | Separate sub-plan 044; G.4 BLOCKS_ON G.2 + G.3 ship per parent plan-040 § E.4 sequential-post-G.2-AND-G.3 | Sub-plan 044 dispatch after both 042 + 043 verifier PASS per parent plan-040 § N.2 |
| **Cleanup of any pre-existing PDF code** | NONE exists per parent plan-040 § C.0.6 Grep audit (`Grep pdfplumber\|camelot\|pymupdf\|pypdf\|docling\|unstructured` returns 0 matches in production code); clean baseline | N/A — no pre-existing code to clean up |
| **pymupdf as G.1 probe candidate** | AGPL-3.0 license blocker for stockforge proprietary use (pyproject.toml:7 license="Proprietary"); excluded per parent plan-040 § C.0.2 license matrix + RM-G-2 | Reconsider IF project-owner accepts AGPL-3.0 commercial-license cost OR stockforge license changes — fires K.2.a STOP-AND-ASK trigger |
| **unstructured library as G.1 probe candidate** | Heavy dep stack (similar concern to crawl4ai per A-02 § 5 wholesale-port-low fit); excluded per parent plan-040 § C.0.2 + § G.4 deferral | Reconsider IF G.1 winner (pdfplumber+camelot OR docling OR pypdf) fails accuracy gate (<70% on gold samples) — fires K.2.a STOP-AND-ASK trigger |
| **Claude vision API direct (not via claude CLI substrate)** | anthropic_api_to_subagent memory rule violation per parent plan-040 § C.0.5 + DD-6 + RM-G-3; use existing claude_cli_transport substrate at packages/infrastructure/analysis/subagent_transport.py:144-222 (D-072 BC-5 precedent S375; F.1 BC-8 precedent S375) | G.3 sub-plan 043 IMPLEMENTS the claude CLI substrate path per parent plan-040 § E.3 + DD-6 |
| **AzureDocumentIntelligence / AWS Textract / GCP Vision** (paid cloud OCR) | Paid services; out of V0 scope per cost discipline + parent plan-040 § A.3 deferral | Cost-justification trigger: pure-Python (G.2) + claude vision (G.3) both fail accuracy gate (<90% on 5-document gold set) AND user authorizes paid-cloud spend |
| **Extension of 4-metric grid to ≥6 metrics** (e.g. memory footprint / max-pages-supported / OCR-mode availability) | Karpathy P2 simplicity — 4 metrics span quality + cost + risk axes per parent plan-040 DD-4 rationale; ≥6 metrics is over-engineering for V0 | Metric expansion trigger: G.4 dogfood surfaces metric blind spot (e.g. memory OOM on 200-page report) → add metric in Phase G-prime-V2 |
| **5-document gold set in G.1** | Per parent plan-040 DD-4 — 2 documents (VHM + HPG) sufficient for V0 winner-pick; 5-document expansion happens at G.4 dogfood per parent plan-040 § E.4 D6 | Sub-plan 044 G.4 IMPL D6 expands gold set to 5 documents (VHM + HPG + VIC + FPT + 1 scanned sample) |
| **Per-document expected-cells JSON for non-gold-set docs** | V0 ships 2-document gold set only (VHM + HPG); per-document JSON is per-gold-set-doc not all-docs | Expansion trigger: G.4 IMPL adds 3 more docs to gold set + corresponding expected_cells_*.json |
| **Bake-off probe automation in CI** | apps/cli/bench/pdf_bake_off.py is one-off probe per DD-6; CI integration is post-MVP harness work | CI trigger: G.4 dogfood surfaces silent winner-library regression risk → add nightly bake-off gate; harness-sweep work not product session |
| **ABC method extension to ≥5 methods** (e.g. detect_currency / detect_language / page_range_for_statement) | Karpathy P2 — 4 method surface sufficient for V0 per dispatch brief § H RM4 anti-over-engineering | Extension trigger: G.2 OR G.3 IMPL surfaces method-gap requiring ABC extension → ADR D-080-V2 amendment |
| **OCR-fallback flag in extract() method** | V0 ships pure-extract path; OCR-fallback is per-adapter implementation detail (G.3 Claude vision IS the OCR path; G.2 pdfplumber may have internal OCR via tesseract but that's adapter-internal) | OCR-flag trigger: G.4 dogfood surfaces need for caller-controlled OCR-mode toggle |
| **Page-range parameter in extract() method** | V0 ships full-PDF extract; page-range targeting deferred to G.3 cost-optimization (page-classification BEFORE LLM dispatch per parent plan-040 RM-G-7 mitigation) | Page-range trigger: G.3 IMPL surfaces cost-runaway requiring page-targeting → ABC extension via D-080-V2 |
| **Per-source adapter configuration DSL** (YAML cell-label-map per source) | Per parent plan-040 § A.3 deferral; YAML-based cell-label-map is over-engineering for ≤5 sources | DSL trigger: ≥5 distinct VN sources with conflicting cell-label conventions surfaces |
| **anthropic dep drop from pyproject.toml (D-052 § Implementation step 3)** | Out of scope per Phase G-prime — Phase F-prime + Phase G-prime carry-forward; separate D-052-V2 cleanup ADR after all transport-flips complete | D-052-V2 trigger: ZERO `import anthropic` confirmed across packages/ + apps/ AFTER all Phase F-prime + Phase G-prime adapters ship |
| **pyproject.toml dep addition for ANY library** | Per DD-8 isolated-venv probe; G.2 IMPL ratifies winner dep addition per parent plan-040 § E.2 D3 | G.2 sub-plan 042 IMPL D3 adds winner library to pyproject.toml with attribution + rationale per D-061 add-with-rationale doctrine |
| **Tests outside packages/application/fundamental/test_*.py** | tests/unit/ directory does NOT exist (Glob confirmed STEP 0.4); existing convention = tests-alongside-code per packages/_shared/test_path_safety.py precedent; gold-set fixtures at tests/fixtures/pdf/ is NEW directory accepted because PDF binary blobs cannot live alongside code | Convention change trigger: project-owner directs tests/unit/ standardization sweep — separate cross-cutting refactor |
| **STOP-AND-ASK file authoring in S392 PLAN session** | STEP 0 STOP-AND-ASK is S394 dev session responsibility; PLAN session has no charter/scope question per `full_autonomous_no_supervised` | STEP 0 STOP-AND-ASK trigger fires only in S394 IMPL session per § C STEP 0.1.b empirical license probe + § C STEP 0.2 no-clear-winner pivot |
| **New harness hook for PDF-extraction cell-determinism check** | Belongs to harness-stabilization sweep IF a silent cell-determinism defect surfaces (Karpathy P2 — no premature hook) | Harness trigger: 2+ silent PDF-cell-determinism incidents (AP-23 promote-to-hook calculus) |
| **EchoValidator runtime enforcement** | G.1 has no LLM output path; EchoValidator is G.3 sub-plan deliverable per parent plan-040 § E.3 D3 | EchoValidator trigger: G.3 IMPL ships EchoValidator at `packages/application/fundamental/echo_validator.py` per parent plan-040 § E.3 D3 |
| **Charter amendment SHIP for any new I-S<N> invariant Theme J surfaces** | THIS plan FLAGS via STOP-FINDING file path; main session ratifies via AskUserQuestion gate ONLY IF S394 dev STEP 0 surfaces charter-tier need | Trigger: § J K.2.a STOP-AND-ASK fires in S394 IMPL session (license escalation OR no-clear-winner pivot) |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared for task_class="pdf-extraction-plan"; nearest analog crawler-adapter-plan n=1 + multi-perspective-impl-plan n=1)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 18+ files cited; key 12 highlighted):

1. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` (parent master plan; § A goal + § D DDs 1-8 + § E sub-track decomposition + § G 3-source-evidence chain + § N sequencing + § K K.2 surfaces — read offsets 1-300 + 300-600 + 600-824)
2. `agent-workspace/session-plans/completed/039-S387-harness-stabilization-sweep-N1.md` (sub-plan template shape reference; offset 1-200; § A-N standard structure)
3. `agent-workspace/session-plans/completed/034-S374-phase-f1-roleprompt-persona-transport.md` (5-sub-track FOCUSED_IMPL precedent — direct shape mirror; offset 1-200)
4. `packages/application/news/ports/crawler_adapter.py` (full read 128 LOC; D-066 CrawlerAdapter ABC EXACT PATTERN — `source_id` ClassVar + `__init_subclass__` typecheck at L60-78 + 3 abstract methods at L80-127 + crawl4ai/hub.py:24-35 attribution at L1-3 + L63-66; THIS sub-plan's ABC mirrors this shape with 4 methods instead of 3)
5. `packages/domain/fundamental/models/financial_statement.py` (full read 108 LOC; FinancialStatement aggregate at L42-88 with frozen+slotted dataclass + Mapping[str, Money] line_items + __post_init__ Rule 1 + Rule 4 + Rule 5 + Rule 6 + I-S1 invariants; ExtractedFinancialStatement MIRRORS this shape with provenance-field extension)
6. `packages/domain/fundamental/value_objects/line_item.py` (full read 65 LOC; LineItemKey StrEnum 10 canonical keys at L33-45 + line_item_required_for_ratio table at L48-64; G.1 ABC contract honors these 10 keys via D4 expected_cells_*.json fixture)
7. `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (first 120 LOC; vendor-key→canonical mapping pattern at `_VNSTOCK_LINE_ITEM_MAP` L58-90 (bilingual VN+EN labels); G.2 IMPL MIRRORS this pattern; THIS sub-plan does NOT touch vnstock adapter per DD-15 + § A.2 item 14)
8. `packages/_shared/__init__.py` (full read 7 LOC; "_shared/ dep-free no framework imports — pure Python only" constraint; STEP 0.7 finding: dispatch brief's `packages/_shared/pdf/` location violates this constraint because PDF library imports are NOT pure-Python; corrected per DD-1)
9. `packages/_shared/path_safety.py` (offset 1-50; safe_user_path + safe_document_path helpers per D-064 5-invariant contract; D2 PdfSource + D3 bake-off probe use safe_user_path for PDF input path validation)
10. `pyproject.toml` (offset 1-60 + parent plan-040 § A.4 entry 12 confirms ZERO PDF lib dep currently — pdfplumber/camelot/pymupdf/pypdf/docling/unstructured all NOT present; only PDF-adjacent dep is playwright>=1.47.0 at L42 which has page.pdf() but that's PAGE→PDF not PDF→DATA; D3 isolated-venv probe NO pyproject.toml modification per DD-8)
11. `agent-workspace/memory/observations/sandwich-architect-S387-harness-sweep-N1-plan.md` (offset 1-100; recent architect observation template; ~85K Opus budget actual per prior plan; nearest data point for THIS plan's wall-clock + token estimate)
12. `agent-workspace/memory/observations/sandwich-architect-S374-phase-f1-plan.md` (offset 1-80; F.1 sub-plan precedent observation; ~140K Opus budget actual)

Additional reads: `Glob packages/application/fundamental/**/*.py` (confirmed NEW directory — does NOT exist; G.1 creates) / `Glob packages/infrastructure/fundamental/**/*.py` (4 files exist: vnstock adapter + sqlite repo + test_adapters + __init__) / `Glob apps/cli/**/*.py` (19 CLI scripts; apps/cli/bench/ NEW sub-directory) / `Glob scripts/bench/**/*` (NONE — confirmed scripts/ contains hooks not bench code; DD-6 picks apps/cli/bench/) / `Glob tests/fixtures/**/*` (NONE — confirmed NEW directory) / `Glob tests/unit/**/*` (NONE — confirmed convention = tests-alongside-code) / `Glob agent-workspace/memory/decisions/0{75,76,77,78,79}*.md` (highest ADR = D-079; D-080 next per DD-7) / `Glob agent-workspace/session-plans/pending/041*.md` (NONE — plan-041 number available)

**Calibration parameters extracted**:

- **task_class**: `pdf-extraction-plan` (NEW — no precedent in tracking logs; first PDF-substrate-shaped sub-plan in StockForge; nearest analogs `crawler-adapter-plan` n=1 from S337 plan-020 + `multi-perspective-impl-plan` n=1 from S374 plan-034)
- **sample_size**: **0 for pdf-extraction-plan** (COLD-START on this task_class); **1 for crawler-adapter-plan** (S337 plan-020 ~80K Sonnet at ~30 min) + **1 for multi-perspective-impl-plan** (S374 plan-034 ~140K Opus at ~50 min based on S374 observation)
- **avg_wall_min observed**: N/A precise cold-start; nearest-analog crawler-adapter-plan ~30 min Sonnet S337; nearest-analog multi-perspective-impl-plan ~50 min Opus S374; estimating THIS PLAN at ~40-60 min Opus with PDF-empirical-probe novelty
- **avg tokens_real observed**: N/A precise cold-start; nearest-analog ~85K Opus (S387 harness sweep plan-039 architect observation), ~140K Opus (S374 F.1 plan-034); estimating THIS PLAN at ~120-170K Opus (mid-band; +30-50% over crawler-adapter-plan for novelty)
- **parallel_hit_rate**: N/A cold-start; THIS plan declares D2 + D3 sequential-after-D1; D4 + D5 parallel-eligible with D3 (disjoint file scopes — D3 = apps/cli/bench/, D4 = packages/application/fundamental/test_*, D5 = agent-workspace/memory/decisions/ + agent-workspace/research/)
- **parallel_savings_avg**: N/A cold-start; estimated 5-10% wall reduction from D4+D5 parallel with D3
- **failure_mode frequency**: 0 mistakes per nearest-analog crawler-adapter-plan n=1 (S337 clean) + 0 mistakes per nearest-analog multi-perspective-impl-plan n=1 (S374 clean per S375 dev close); novelty risk MEDIUM for pdf-extraction-plan shape because (a) empirical bake-off harness is novel (no prior probe-then-pick sub-plan in StockForge), (b) gold-set construction is novel (no prior PDF-fixture in repo), (c) 4-metric grid harness is novel (no prior multi-metric library comparison), (d) library-license-matrix audit is novel (no prior license-posture-per-library check)
- **Adjustment to default budget**: +30-50K Opus reserve over nearest-analog ~85-140K for novelty = ~150-200K projected typical THIS PLAN; sub-plan IMPL S394 inherits parent plan-040 § A.4 estimate ~150K Opus FOCUSED_IMPL (extended for empirical probe execution)
- **Cold-start?**: **YES for pdf-extraction-plan task-class**; **NO for ABC+intermediate-dataclass shape** (transfers cleanly from D-066 CrawlerAdapter at packages/application/news/ports/crawler_adapter.py); **PARTIAL-COLD-START for bake-off-probe + 4-metric-harness + library-license-matrix-audit** (novel sub-component); **NO for ADR landing shape** (D-080 mirrors D-066 ADR shape)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S394 dev):

- S394 dev IMPL projection: **150K Opus FOCUSED_IMPL** per parent plan-040 § A.4 + recalibrated CLAUDE.md table (extended for empirical probe execution)
- STEP 0 evaluation overhead in S394: ~15-25K
- D1 PdfTableExtractorPort ABC: ~15-20K
- D2 ExtractedFinancialStatement + PdfSource dataclasses: ~15-20K
- D3 Empirical bake-off probe + 3-library install + report writing: ~50-70K (DOMINANT — empirical probe is novel substrate)
- D4 ABC contract tests + dataclass tests + gold-set SHA256 manifest test: ~15-25K
- D5 ADR D-080 PROPOSED + bake-off report draft synthesis: ~15-25K
- Observation + session log + mistake-log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL per K.2.a): ~5-10K
- Reserve for inline F-fix: ~10-15K
- **Total projected dev budget envelope**: 135-185K typical; 145-195K with STEP 0 STOP-AND-ASK path; 150K Opus FOCUSED_IMPL cap respected if work tracks lower estimate; if work exceeds → SPLIT trigger per dispatch brief § G LOC ceiling per STEP

**PARALLEL OPPORTUNITY** (architect declaration for downstream S394 dev):

- D1 (PdfTableExtractorPort ABC) must serialize FIRST as foundation (~5 min wall)
- D2 (ExtractedFinancialStatement + PdfSource) waits for D1 (`extract` method signature consumes both) (~5 min wall)
- D3 (empirical bake-off probe) waits for D2 (probe writes ExtractedFinancialStatement-shaped output) (~30-40 min wall — DOMINANT)
- D4 (ABC contract tests + dataclass tests + fixture manifest test) can run PARALLEL with D3 (disjoint file scopes — D4 = packages/application/fundamental/test_*, D3 = apps/cli/bench/) (~10 min wall)
- D5 (ADR D-080 + bake-off report) can run PARALLEL with D3 (D5 synthesizes D3 results AFTER D3 completes but ADR-draft skeleton can be authored in parallel) (~10 min wall)
- **Recommended sequencing**: D1 → D2 → (D3 + D4 + D5-skeleton parallel) → D5-final-synthesis post-D3
- Per plan-025 DD-5 3-parallel ceiling: D3 + D4 + D5-skeleton = 3-parallel within ceiling

---

## B. In-scope / Out-of-scope (sub-plan-level)

### B.1 In-scope (this SUB-PLAN ships per § A.2 enumeration)

See § A.2 (items 1-15 above).

### B.2 What this sub-plan is NOT (explicitly OUT-OF-SCOPE per dispatch brief § B)

This sub-plan is **NOT**:

1. **G.2 winner-adapter IMPL** — concrete adapter (using G.1-ratified winner library) at `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` + cell-label normalization table + VND-string parser + tests + pyproject.toml dep addition is OUT-OF-SCOPE; separate sub-plan 042 per parent plan-040 § E.2; G.2 BLOCKS_ON G.1 ship per DD-5 sequential-post-G.1-ratification
2. **G.3 Claude vision adapter** — LLM-assisted OCR adapter at `packages/infrastructure/fundamental/pdf_claude_vision_fundamental_adapter.py` + EchoValidator post-OCR cell-validation gate at `packages/application/fundamental/echo_validator.py` + claude CLI substrate vision-input probe + tests is OUT-OF-SCOPE; separate sub-plan 043 per parent plan-040 § E.3; G.3 BLOCKS_ON G.1 ship
3. **G.4 BC-2 integration dogfood** — `apps/cli/ingest_pdf_fundamentals.py` CLI + first VHM 2023/2024 annual-report end-to-end through both G.2 + G.3 adapters → SqliteFundamentalRepository persistence → ratio_service smoke-test (6-ratio computation) → `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` report + 5-document gold-set expansion is OUT-OF-SCOPE; separate sub-plan 044 per parent plan-040 § E.4; G.4 BLOCKS_ON G.2 + G.3 ship
4. **Cleanup of any pre-existing PDF code** — NONE exists per parent plan-040 § C.0.6 + STEP 0.4 Grep audit (`Grep pdfplumber\|camelot\|pymupdf\|pypdf\|docling\|unstructured` returns 0 production matches); clean baseline; no cleanup work
5. **Modification of vnstock_fundamental_adapter.py** — UNCHANGED per Karpathy P3 backward-compat preservation; THIS sub-plan adds NEW substrate, does NOT modify existing
6. **Modification of FinancialStatement domain entity** — UNCHANGED per parent plan-040 DD-2/DD-3; ExtractedFinancialStatement is intermediate dataclass at application layer (NOT domain extension)
7. **Modification of any BC-1/BC-3/BC-4/BC-5/BC-6/BC-7/BC-8/BC-9 file** — Phase G-prime is BC-2 scoped per parent plan-040 § F.3; ZERO cross-BC contention
8. **Charter or constitution amendments** — out per CLAUDE.md hard rule; § J K.2.a STOP-AND-ASK fires CONDITIONAL on empirical probe outcome
9. **Pyproject.toml dep addition for any library** — DD-8 isolated-venv probe at G.1; G.2 IMPL ratifies winner dep addition per parent plan-040 § E.2 D3
10. **Library winner pick in PLAN session** — per dispatch brief "Do NOT pick the library winner in the PLAN (that's IMPL-session empirical work; PLAN authors the bake-off protocol)"; PLAN authors PROTOCOL; IMPL EXECUTES and ratifies

---

## C. STEP 0 — VBW Live Verification (this SUB-PLAN — applies to S394 dev session)

### Sub-step 0.1 — Library license matrix probe (empirical re-verification at S394 IMPL session entry)

**Trigger**: S394 dev session entry; before ANY library install in isolated probe venv.

**Probes**:

- **STEP 0.1.a — License posture re-verification per library**: For each of 3 candidate libraries, S394 dev confirms current license string + repo URL + spdx-identifier via:
  - pdfplumber: `pip show pdfplumber 2>/dev/null` or PyPI page (expect MIT)
  - camelot-py: `pip show camelot-py 2>/dev/null` or PyPI page (expect MIT)
  - docling: `pip show docling 2>/dev/null` or PyPI page (expect MIT)
  - pypdf: `pip show pypdf 2>/dev/null` or PyPI page (expect BSD-3-Clause)
  - Record findings in bake-off report § License-Compatibility table
- **STEP 0.1.b — pymupdf AGPL-3.0 exclusion re-verification (parent plan-040 K.2.a NON-BLOCKING entry)**: S394 dev confirms pymupdf license is STILL AGPL-3.0 (per PyPI lookup); IF license has changed to BSD/MIT/Apache, FLAG via § J K.2.a STOP-AND-ASK (CHARTER-tier surface — license posture decision affects probe scope); ELSE proceed with pymupdf-excluded probe per DD-8 + parent plan-040 § C.0.2 license matrix
- **STEP 0.1.c — Verify no charter-tier license-pivot triggered**: If all 4 candidates (pdfplumber + camelot + docling + pypdf) remain MIT/BSD/Apache-clean for proprietary use → PROCEED with empirical probe per § E STEP 2. IF any candidate license has changed to AGPL/GPL/SSPL → STOP-AND-ASK fires per § J K.2.a

### Sub-step 0.2 — Empirical probe protocol re-verification (per L-S32-1 empirical-probe-first SKILL)

**Trigger**: S394 dev session entry; before bake-off probe execution.

**Probes**:

- **STEP 0.2.a — Gold-set sourcing verification**: Confirm VHM 2023 annual report PDF reachable at Vietstock public URL (per parent plan-040 § C.0.3); confirm HPG 2023 annual report PDF reachable at Vietstock public URL; IF unreachable, fall back to VN company website direct download (`vinhomes.vn` for VHM; `hpg.vn` for HPG); commit-eligible per RM4 (public corporate annual reports are non-confidential disclosure-mandated artifacts; ~3-5 MB each)
- **STEP 0.2.b — Gold-set ground-truth annotation verification**: For each gold-set PDF, manually identify 10 LineItemKey canonical cell values at period_end (REVENUE / NET_INCOME / TOTAL_ASSETS / etc per `packages/domain/fundamental/value_objects/line_item.py:33-45`) + page number + cell context; record in `expected_cells_vhm.json` + `expected_cells_hpg.json`; this IS the manual-validation gold truth for Metric 1 cell-content-exact-match scoring
- **STEP 0.2.c — Isolated-venv probe verification**: Confirm 3 candidate libraries install cleanly in isolated venv (e.g. `python -m venv .venv-pdf-bakeoff && .venv-pdf-bakeoff/bin/activate && pip install pdfplumber camelot-py docling pypdf`); record install size + transitive dep count per library (Metric 3); IF any library fails to install on Windows (RM2 docling-Windows risk), FLAG via § J STEP 0 stop-and-ask path or document failure mode in bake-off report

### Sub-step 0.3 — Existing BC-2 substrate audit (carry-forward from parent plan-040 § C.0.1)

**Confirmation** (re-verified per VBW protocol at S392 PLAN authoring; S394 dev re-verifies):

- `packages/domain/fundamental/models/financial_statement.py` (FinancialStatement aggregate L42-88; UNCHANGED THIS sub-plan)
- `packages/domain/fundamental/value_objects/line_item.py` (LineItemKey StrEnum L33-45; ExtractedFinancialStatement honors these 10 canonical keys via D4 expected_cells_*.json)
- `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (`_VNSTOCK_LINE_ITEM_MAP` L58-90; UNCHANGED THIS sub-plan; G.2 IMPL MIRRORS pattern at sub-plan 042)
- `packages/application/fundamental/` directory does NOT exist (Glob confirmed at PLAN authoring; G.1 IMPL D1 creates)
- `apps/cli/bench/` directory does NOT exist (Glob confirmed at PLAN authoring; G.1 IMPL D3 creates)
- `tests/fixtures/pdf/` directory does NOT exist (Glob confirmed at PLAN authoring; G.1 IMPL D4 creates)

### Sub-step 0.4 — D-066 CrawlerAdapter ABC precedent inspection (BINDING template for DD-1)

**Read EXACT pattern** at S394 dev session entry:

- `packages/application/news/ports/crawler_adapter.py` (full 128 LOC):
  - L1-3: crawl4ai/hub.py:24-35 attribution comment (NOTICE per Apache-2.0 + Attribution clause)
  - L4-22: module docstring with design decisions cited per plan 020 + architecture.md § BC-5
  - L26-28: `ABC` + `abstractmethod` + `ClassVar` imports
  - L43-58: class definition with `source_id: ClassVar[str]` + docstring with MUST/MUST NOT clauses
  - L60-78: `__init_subclass__` typecheck enforcing non-empty `source_id` ClassVar at class-definition time
  - L80-127: 3 `@abstractmethod` method signatures (`discover`, `fetch_and_parse`, `to_news_article`)
- **PdfTableExtractorPort mirrors this shape EXACTLY** with 4 methods instead of 3 + same `source_id` ClassVar pattern + same `__init_subclass__` typecheck + similar docstring MUST/MUST NOT clauses (e.g. "MUST NOT: emit new LLM-numeric fields per Rule 16 / D-065")

### Sub-step 0.5 — VBW correction of dispatch brief (architect finding documented in DD-1)

**Dispatch brief said**: "PdfTableExtractorPort ABC in `packages/_shared/pdf/pdf_table_extractor_port.py` with `__init_subclass__` guard + abstract methods (model on `packages/_shared/crawl/crawler_adapter.py` from D-066 CrawlerAdapter ABC contract precedent)"

**VBW finding** (S392 architect Read + Glob):

- `packages/_shared/__init__.py` constraint at L1-7: "_shared/ dep-free no framework imports — pure Python only"
- `packages/_shared/crawl/crawler_adapter.py` does NOT exist (Glob returned 0 matches)
- Actual D-066 CrawlerAdapter location: `packages/application/news/ports/crawler_adapter.py` (Glob confirmed at L128 LOC)
- Parent plan-040 DD-1 (binding canonical source per dispatch brief "read parent plan-040 § D first"): "PdfTableExtractorPort is an ABC ... located at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW file in new directory)"

**Resolution**: PdfTableExtractorPort ABC location = **`packages/application/fundamental/pdf_table_extractor_port.py`** per parent plan-040 DD-1 verbatim (NOT `packages/_shared/pdf/`); rationale = (a) `_shared/` is dep-free constraint violated by PDF library imports, (b) D-066 precedent ACTUALLY lives at `packages/application/news/ports/`, (c) parent plan-040 DD-1 is binding canonical source per dispatch brief precedence rule. Dispatch-brief deviation documented in DD-1 below + § P compliance attestation.

### Sub-step 0.6 — pre-flight active-rules re-check (carry-forward from S391 PLAN session)

- ✅ R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14) — ACTIVE
- ✅ R2 project-integrity-watchdog.sh Stop hook — ACTIVE
- ✅ R3 daily-backup.sh Stop hook — ACTIVE
- ✅ BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED — CARRY-FORWARD HONORED

### Sub-step 0.7 — STEP 0 summary (this sub-plan PLAN session)

All 6 sub-steps PASS at S392 PLAN authoring (subset that PLAN session can execute via Read/Glob/Grep). STEP 0.1 + STEP 0.2 carry-forward to S394 dev session for execution (requires `pip` install in isolated venv + manual gold-truth annotation). No STOP-AND-ASK triggered at PLAN-tier. 1 charter-tier-surface FLAG carry-forward to S394 IMPL session (K.2.a — license escalation OR no-clear-winner pivot CONDITIONAL).

---

## D. Architecture Decisions (DD-1 through DD-8)

### DD-1: PdfTableExtractorPort = ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NOT `packages/_shared/pdf/`)

**Decision**: PdfTableExtractorPort is an **ABC (abstract base class)** at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW file in NEW directory `packages/application/fundamental/`).

**Rationale**:
- **Parent plan-040 DD-1 binding** (canonical source per dispatch brief "read parent plan-040 § D first"): "PdfTableExtractorPort is an **ABC (abstract base class)** ... located at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW file in new directory)"
- **D-066 CrawlerAdapter ACTUAL location precedent**: `packages/application/news/ports/crawler_adapter.py` (NOT `packages/_shared/crawl/` as dispatch brief claimed — VBW correction per STEP 0.5); same BC-application-layer-port convention applies to BC-2
- **`packages/_shared/` constraint violation**: `packages/_shared/__init__.py:1-7` states "dep-free no framework imports — pure Python only"; PDF library imports (pdfplumber, camelot, docling, pypdf) are framework-equivalent third-party deps → cannot live under `_shared/`
- **DDD Port + Adapter doctrine per `.claude/skills/ddd-tactical-patterns/SKILL.md`**: application layer owns the port; infrastructure layer owns the adapters; BC-2 application layer = `packages/application/fundamental/` (NEW)
- **ABC over Protocol structural typing**: ABC `@abstractmethod` provides runtime enforcement that Protocol cannot; `__init_subclass__` typecheck (per D-066 precedent at L60-78) prevents subclass registration without required ClassVar — Protocol cannot do this at definition time
- **Shared base error hierarchy**: ABC enables `PdfTableExtractorError(Exception)` base class for shared error semantics across adapters; Protocol cannot inherit shared exception types

**Adversarial alternate considered**: Protocol structural typing → REJECTED per parent plan-040 DD-1 reasoning (runtime enforcement + shared base behavior + error hierarchy advantages); D-066 CrawlerAdapter ABC precedent confirms ABC choice was correct for analogous BC-5 News surface.

**Adversarial alternate considered**: `packages/_shared/pdf/` per dispatch brief → REJECTED per VBW STEP 0.5 finding (constraint violation + dispatch brief had incorrect D-066 location claim).

**Dispatch-brief deviation acknowledgment**: Dispatch brief specified `packages/_shared/pdf/` location; this DD-1 deviates per VBW STEP 0.5 + parent plan-040 DD-1 canonical source precedence. Deviation documented in § P compliance attestation.

### DD-2: ABC method surface = 4 abstract methods + 1 `source_id` ClassVar (NOT ≤3 per dispatch brief minimum + NOT ≥5)

**Decision**: PdfTableExtractorPort has **4 abstract methods** + **1 ClassVar**:

```python
class PdfTableExtractorPort(ABC):
    source_id: ClassVar[str]  # enforced non-empty via __init_subclass__

    def __init_subclass__(cls, **kwargs: object) -> None:
        super().__init_subclass__(**kwargs)
        if not getattr(cls, "source_id", "").strip():
            raise TypeError(
                f"{cls.__name__} must declare a non-empty source_id ClassVar "
                f"(e.g. source_id = \"pdfplumber+camelot\"). "
                f"Pattern: crawl4ai/hub.py:24-35 + packages/application/news/ports/crawler_adapter.py:60-78."
            )

    @abstractmethod
    def extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement:
        """Extract financial statement cells from a PDF source.
        Raises PdfTableExtractorError on extraction failure (network, parse, OCR)."""

    @abstractmethod
    def supports(self, pdf_path: Path) -> bool:
        """Return True iff this adapter can handle the given PDF file
        (e.g. scanned vs digital; PDF version compatibility).
        Used for pre-check before extract() to enable adapter-routing."""

    @abstractmethod
    def name(self) -> str:
        """Human-readable adapter identifier (e.g. 'pdfplumber+camelot v0.10.0').
        Used in ExtractedFinancialStatement.extraction_method provenance field."""

    @abstractmethod
    def extractor_version(self) -> str:
        """Semver string for this adapter version (e.g. '0.1.0').
        Used in ExtractedFinancialStatement.extractor_version provenance field."""
```

**Rationale**:
- **Karpathy P2 simplicity** per dispatch brief § H RM4: abstract method count ≤4; this DD-2 = exactly 4 methods at the ceiling
- **Parent plan-040 DD-1 + DD-3**: `extract` is primary; `name` + `extractor_version` are provenance feeders for ExtractedFinancialStatement (DD-3); `supports` enables future adapter-routing (e.g. G.4 dogfood CLI dispatches to G.2 OR G.3 based on `supports(pdf)` pre-check)
- **D-066 CrawlerAdapter precedent**: 3 abstract methods (discover + fetch_and_parse + to_news_article); PDF adapter needs +1 for `extractor_version` provenance (CrawlerAdapter doesn't emit provenance because BC-5 News ScrapedArticle shape doesn't include extractor_version field)
- **`source_id` ClassVar per D-066 precedent at L58 + L60-78 `__init_subclass__` typecheck**: runtime-enforced contract for registry keying (e.g. future PdfTableExtractorRegistry analogous to CrawlerRegistry); also pattern adapted from crawl4ai/hub.py:24-35 BaseCrawler

**Adversarial alternates considered**:
- **`extract` + `name` only (2 methods, simpler)**: REJECTED — loses adapter-routing capability (`supports`) AND loses provenance versioning (`extractor_version`); 2 methods insufficient for G.4 dogfood polymorphism
- **+ `page_range(pdf, statement_type) → tuple[int, int]` (5 methods)**: REJECTED per § A.3 deferral — page-range targeting deferred to G.3 cost-optimization (RM-G-7 mitigation at IMPL); ABC extension via D-080-V2 if needed
- **+ `detect_currency(pdf) → Currency` + `detect_language(pdf) → str` (6 methods)**: REJECTED per Karpathy P2 — over-engineering for V0 (VN PDFs are VND + VN-language by default; multi-currency/multi-language deferred to Phase 3+ per parent plan-040 § A.3)
- **OCR-fallback flag in extract() (e.g. `extract(pdf, *, ocr_mode='auto' | 'force' | 'never')`)**: REJECTED per § A.3 deferral — OCR-fallback is per-adapter implementation detail (G.3 Claude vision IS the OCR path)

### DD-3: Gold-set sourcing = 2 real VHM + HPG 2023 annual report PDFs (NOT synthetic fixtures + NOT 1-document baseline)

**Decision**: Gold-set = **2 real public corporate annual report PDFs**:
- `tests/fixtures/pdf/vhm-2023-annual.pdf` (Vinhomes 2023 annual report; ~3-5 MB; source = Vietstock public OR vinhomes.vn IR)
- `tests/fixtures/pdf/hpg-2023-annual.pdf` (Hoa Phat Group 2023 annual report; ~3-5 MB; source = Vietstock public OR hpg.vn IR)

**Rationale**:
- **Dispatch brief § A guidance**: "gold-set of 1-2 real VHM/HPG annual-report PDFs at known file paths for ground-truth comparison"; 2 documents = upper end of dispatch brief range (better signal-to-noise than 1)
- **Parent plan-040 DD-4 rationale**: "1 gold sample sufficient for V0 winner-pick decision; gold-set expansion to 5 docs happens at G.4 dogfood"; THIS sub-plan ships 2 (one more than parent baseline) because (a) 2-document corpus shows whether winner generalizes (within-VN-listed-company class), (b) HPG complements VHM well — HPG = steel sector (simpler IS) vs VHM = real-estate conglomerate (complex BS with subsidiaries); cross-sector signal informs G.2 cell-label-map design at sub-plan 042
- **I-S34 public sources only**: VN listed-company annual reports are PUBLIC disclosure-mandated artifacts per SSC (State Securities Commission of Vietnam) regulations; commit-eligible (no licensing concern); ~3-5 MB binary commits acceptable per repo size discipline
- **Real PDFs over synthetic fixtures**: synthetic fixtures (e.g. handcrafted minimal PDF) test the adapter's parser but NOT its ability to handle real-world VN PDF layout drift (multi-column layouts, footnotes interleaved with tables, scanned-vs-digital mixed pages); real PDFs exercise these failure modes which are what V0 winner-pick must handle

**Adversarial alternate considered**: 1-document baseline (VHM only) → REJECTED — generalization signal is weak with N=1; risk that empirical winner overfits to single-document idiosyncrasies (e.g. VHM's specific table layout convention).

**Adversarial alternate considered**: 5-document corpus in G.1 → REJECTED per parent plan-040 DD-4 — over-engineering for V0 winner-pick (5-doc expansion is G.4 dogfood scope); manual gold-truth annotation cost scales linearly with doc count (~30 min per doc for 10 canonical cells × 3 statements = 30 cells annotation).

**Adversarial alternate considered**: Synthetic minimal PDF fixtures → REJECTED — fails to test real-world VN layout drift; G.1 winner-pick on synthetic fixtures has no predictive value for G.4 dogfood accuracy.

### DD-4: Winner-pick metric = cell-content-exact-match (NOT cell-count + NOT table-structure-match alone)

**Decision**: Metric 1 (cell-extraction accuracy) = **cell-content-exact-match** scoring:

- For each of 10 LineItemKey canonical cells in `expected_cells_<ticker>.json`:
  - Adapter extracts cell value (raw string from PDF)
  - Deterministic VND-string parser (G.2 substrate; G.1 probe uses minimal inline parser) yields Decimal
  - Compared exact-match against expected Decimal value
  - Match = score 1.0; Mismatch = score 0.0; Missing = score 0.0
- Final accuracy = (sum of matches) / 10 cells × 100%
- Reported per-document + averaged across 2-document gold set

**Rationale**:
- **Parent plan-040 DD-4 metric 1 verbatim**: "Cell-extraction accuracy: % of 10 LineItemKey canonical cells correctly extracted ... vs manually-validated gold truth"
- **Cell-count is too lenient**: counts any extracted cell, even if value wrong (false positives from spurious cells)
- **Table-structure-match is too strict**: penalizes adapters that extract correct cell values but in different table layouts (layout-variability is fine if values are correct)
- **Decimal exact-match enables I-S1 / Rule 16 mode #2 by-construction**: parsed Money values must match gold truth EXACTLY post-VND-string-parse; any LLM-derived approximation (NA THIS sub-plan but downstream at G.3) would fail this metric — by-construction Rule 16 mode #2 satisfaction

**Adversarial alternate considered**: Tolerance-band match (e.g. within 0.1% tolerance) → REJECTED — financial numbers are EXACT semantically (VND-billion amounts don't have measurement uncertainty); tolerance-band introduces silent error tolerance that masks adapter bugs.

**Adversarial alternate considered**: Pairwise cell-comparison metric (Jaccard on extracted vs expected sets) → REJECTED — masks ordering / positional information; 10 LineItemKey canonical positional mapping IS the contract.

### DD-5: Karpathy P3 surgical-scope discipline = ZERO touch to `apps/crawlers/cafef_html_to_md.py`

**Decision**: Per dispatch brief § D DD-5, BC-5 News crawler `apps/crawlers/cafef_html_to_md.py` (and analogous BC-5 PDF research-note ingestion surface) is OUT-OF-SCOPE; BC-5 stays HTML-route per Phase D Theme L closed at S358.

**Rationale**:
- **Karpathy P3 surgical-scope**: Phase G-prime is BC-2 (Fundamental Data) scoped per parent plan-040 § F.3; BC-5 News cross-pollination is EXPLICIT deferral per parent plan-040 § F.2 + § A.3
- **Backward compat preservation**: existing BC-5 News pipeline (Phase D Theme L SHIPPED at S338-S358 per parent plan-033 § N table) is operational; modifying for PDF reuse risks regression
- **AP-7 named revisit trigger**: IF BC-5 News explicitly requests PDF research-note adapter (e.g. broker reports per supplement § L line 363), THEN sub-plan 044-V2 OR new BC-5 sub-plan extends PdfTableExtractorPort substrate to BC-5; promote candidate PCG-1 at parent plan-040 § L captures pattern reuse
- **Cross-BC import discipline**: pyproject.toml:179-197 import-linter Bounded contexts independence contract forbids cross-BC direct imports; BC-2 PdfTableExtractorPort lives at `packages/application/fundamental/`; reuse-by-BC-5 would require shared upper-layer port at packages/_shared/pdf/ (rejected per DD-1 reasoning) OR per-BC port duplication (acceptable per BC isolation)

**Adversarial alternate considered**: Apply PdfTableExtractorPort to BC-5 cafef PDF research-note path → REJECTED — Karpathy P3 surgical-scope violation; PDF research-note ingestion is hypothetical (not yet requested); refactor-on-2nd-instance is the doctrine (PCG-1 at parent plan-040 § L LIKELY promote at G.4 close per AP-7).

### DD-6: Bake-off probe location = `apps/cli/bench/pdf_bake_off.py` (NOT scripts/bench/)

**Decision**: One-off empirical bake-off probe script lives at `apps/cli/bench/pdf_bake_off.py` (NEW sub-directory `apps/cli/bench/` + NEW one-off script).

**Rationale**:
- **Existing apps/cli/ convention dominates**: 19 CLI scripts already at `apps/cli/` (ingest_*.py, validate_thesis.py, extract_vn_claims.py, etc. per Glob); apps/cli/ is the established CLI substrate; NEW sub-directory `apps/cli/bench/` clearly signals "benchmark / one-off probe NOT production-CLI"
- **scripts/bench/ rejected**: `scripts/` contains hook substrate (`scripts/hooks/`) NOT product CLI code; Glob confirmed NO scripts/bench/ exists; using scripts/ for product code violates existing convention boundary
- **One-off probe NOT production CLI**: this script is for G.1 empirical bake-off only; sub-directory placement signals lifecycle (not "part of regular CLI fleet")
- **Permission allow-listing precedent**: `apps/cli/` is already allow-listed per `.claude/settings.json` (Edit + Write); apps/cli/bench/ inherits permissions

**Adversarial alternate considered**: `scripts/bench/pdf_bake_off.py` → REJECTED — scripts/ is hook substrate convention; mixing product code with hook code violates separation
**Adversarial alternate considered**: `agent-workspace/research/pdf_bake_off.py` → REJECTED — agent-workspace/research/ is for research reports/notes (MD files), not executable Python
**Adversarial alternate considered**: `packages/infrastructure/fundamental/bench_pdf_bake_off.py` → REJECTED — bench code is NOT production adapter; pollutes infrastructure layer with one-off probe

### DD-7: ADR D-080 PROPOSED-AT-IMPL records (a) ABC contract + (b) intermediate dataclass + (c) empirical winner + (d) license posture

**Decision**: ADR D-080 PROPOSED at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` per parent plan-040 DD-8; ~150-200 LOC; 12-field schema floor per L-S389-2 harness sweep N+1 promotion.

**ADR D-080 records**:
- (a) PdfTableExtractorPort ABC contract shape (4 methods + ClassVar; mirror D-066 CrawlerAdapter pattern)
- (b) ExtractedFinancialStatement intermediate dataclass contract (6 provenance fields + raw_cells + ticker/statement_type/period_end/filing_date)
- (c) Empirical winner ratification with 4-metric grid (per § E STEP 2 D3 bake-off probe output)
- (d) License posture per chosen library (winner license string + repo URL + spdx-identifier from STEP 0.1.a)
- (e) Chain D-066 → D-080 ABC pattern continuity (Strategy ABC + ClassVar + `__init_subclass__` typecheck)
- (f) Adversarial alternates rejected with rationale (per DD-1/DD-2/DD-3/DD-4/DD-5/DD-6/DD-8 above)
- (g) AP-7 named revisit triggers per deferral
- (h) Source-evidence cite chain (≥3 source files per claim per I-S2)
- (i) Severity = MEDIUM (IMPL-tier; AUTO-ACCEPT at session close per severity-schema; no CHARTER cool-down)
- (j) Supersedes / depends_on / superseded_by fields per 12-field schema

**Rationale**:
- **Parent plan-040 DD-8 verbatim**: "Each sub-plan IMPL author creates own PROPOSED ADR at IMPL-tier; specifically G.1 IMPL → ADR D-080 PROPOSED"
- **L-S389-2 12-field schema floor** from harness sweep N+1 S389 (per dispatch brief): each ADR uses 12-field minimum schema
- **IMPL-tier auto-ratifies per severity-schema**: PROPOSED → ACCEPTED at session close commit; no cool-down for IMPL-tier (CHARTER-tier requires 48h)
- **Append-only ADR doctrine per parent plan-040 DD-8**: NEW ADR D-080 not modification of existing
- **Highest-existing ADR is D-079** (Glob confirmed at STEP 0.3); D-080 next available number per sequential ADR convention

**Adversarial alternate considered**: Defer ADR to G.2/G.3/G.4 IMPL session → REJECTED per parent plan-040 DD-8 explicit "G.1 IMPL → ADR D-080 PROPOSED"; deferral loses architecture-traceability + future-revisit-trigger granularity

### DD-8: ZERO pyproject.toml dep addition THIS sub-plan — bake-off probe in isolated venv

**Decision**: G.1 IMPL D3 bake-off probe installs ≥3 candidate libraries (pdfplumber + camelot-py + docling + pypdf) in an **isolated venv** (`.venv-pdf-bakeoff` per STEP 0.2.c naming) — NOT in stockforge pyproject.toml.

**Rationale**:
- **Parent plan-040 § E.1 dependencies clause verbatim**: "pyproject.toml NOT modified at G.1; G.2 IMPL ratifies pyproject.toml dep addition for winner only"
- **Rollback path preservation**: if all 3 candidates fail accuracy gate (<70% per RM-G-1), pyproject.toml has no rollback needed
- **Isolated environment safety**: 3 candidate library transitive deps + ghostscript (camelot dep) = potentially 50-80+ deps; isolating prevents stockforge dep-tree pollution
- **Winner-pick deferred to G.2 IMPL**: G.2 IMPL D3 adds winner library with attribution + rationale per D-061 add-with-rationale doctrine (Python determinism contract step 1)

**Adversarial alternate considered**: Add all 3 candidates to pyproject.toml at G.1 → REJECTED — risk that 2 of 3 candidates become dead deps after winner-pick; dependency hygiene anti-pattern

**Adversarial alternate considered**: Add winner library at G.1 close → REJECTED per parent plan-040 § E.1 explicit; cleaner separation of probe-tier vs ratification-tier (G.2 IMPL is the ratification slot)

---

## E. Sub-track decomposition (D1-D5)

### E.1 Sub-track D1 — PdfTableExtractorPort ABC

**File**: `packages/application/fundamental/pdf_table_extractor_port.py` (NEW directory + NEW file; ~100 LOC)

**Tasks**:

1. Create directory `packages/application/fundamental/` + `packages/application/fundamental/__init__.py` (~5 LOC; module docstring "BC-2 Fundamental Data — application layer ports")
2. Author `pdf_table_extractor_port.py` mirroring D-066 CrawlerAdapter shape (4 methods + ClassVar + `__init_subclass__` typecheck per DD-2)
3. Author module-level error hierarchy: `PdfTableExtractorError(Exception)` base + `PdfTableExtractorOptionalDepError(PdfTableExtractorError, ImportError)` for per-adapter optional-import gate (mirror crawl4ai Strategy ABC + per-adapter optional-import pattern per parent plan-040 § A.1)
4. Module docstring with: (a) crawl4ai/hub.py:24-35 attribution per Apache-2.0 + Attribution clause (NOTICE per `/NOTICE` repo root) + (b) D-066 CrawlerAdapter precedent cite + (c) parent plan-040 DD-1/DD-2 cite + (d) MUST/MUST NOT clauses (MUST: declare non-empty `source_id` ClassVar / implement 4 abstract methods; MUST NOT: emit LLM-numeric fields per Rule 16 / D-065 — N/A THIS layer but inherited from Rule 16 mode #2)
5. Type hints: `from __future__ import annotations` per D-059; `from abc import ABC, abstractmethod`; `from typing import ClassVar, TYPE_CHECKING`; `from pathlib import Path`; `if TYPE_CHECKING: from packages.application.fundamental.extracted_financial_statement import ExtractedFinancialStatement; from packages.application.fundamental.pdf_source import PdfSource` (lazy import to break potential cycle; D-066 precedent at L33-38 uses same pattern)

**Verify**: mypy --strict green on new file + ruff clean + ABC cannot be instantiated (test in D4)

**LOC ceiling**: ≤120 LOC (target ~100)

**DoD**:
- [ ] File exists at exact path
- [ ] `__init_subclass__` raises TypeError on empty `source_id` (firing-test in D4)
- [ ] 4 abstract methods present + each raises `NotImplementedError` when not overridden (Python ABC default behavior)
- [ ] crawl4ai/hub.py:24-35 NOTICE attribution at file top (per D-066 L1-3 precedent)
- [ ] Module-level error hierarchy defined
- [ ] mypy --strict green
- [ ] ruff clean

**Blocks**: D2 (`extract` method signature consumes ExtractedFinancialStatement + PdfSource); D3 (bake-off probe imports ABC for type-check of probe-adapters); D4 (tests import ABC); D5 (ADR D-080 records this contract)

### E.2 Sub-track D2 — ExtractedFinancialStatement + PdfSource value objects

**Files**:
- `packages/application/fundamental/extracted_financial_statement.py` (NEW ~80 LOC)
- `packages/application/fundamental/pdf_source.py` (NEW ~40 LOC)

**Tasks**:

1. Author `pdf_source.py`:
   - `@dataclass(frozen=True, slots=True)` per F.1 RolePromptPack precedent
   - Fields: `pdf_path: Path` + `source_url: str` + `ticker: Ticker` + `statement_type: StatementType` + `period_end: date` + `filing_date: date`
   - `__post_init__` validation: D-064 path-safety via `safe_user_path(self.pdf_path, root=Path("tests/fixtures/pdf"))` (or env-overridable root) + `source_url` startswith("http"); + `filing_date >= period_end` (mirror FinancialStatement.__post_init__:69-73 Rule 1 invariant)
   - Module docstring cites parent plan-040 DD-2/DD-3 + D-064 + Rule 1 binding
2. Author `extracted_financial_statement.py`:
   - `@dataclass(frozen=True, slots=True)`
   - Fields: `pdf_source: PdfSource` + `raw_cells: Mapping[str, str]` (raw extracted cell-text BEFORE deterministic mapping; key = adapter-specific cell-id; value = raw extracted string) + `extraction_method: str` (e.g. "pdfplumber+camelot") + `extractor_version: str` (semver) + `source_pdf_page: int | None` (None for adapters that don't track per-cell pages) + `source_pdf_sha256: str` (hex string) + `extracted_at: datetime` (UTC-aware per D-059 R1)
   - `__post_init__` validation: `raw_cells` non-empty + `source_pdf_sha256` matches sha256 regex `^[0-9a-f]{64}$` + `extracted_at.tzinfo is not None` (D-059 R1) + `extraction_method` non-empty + `extractor_version` non-empty + `source_pdf_page is None or source_pdf_page >= 1`
   - Module docstring cites parent plan-040 DD-2/DD-3 + I-S22 data lineage + Rule 6 provenance extended for PDF substrate
3. Test in D4 (separate)

**Verify**: mypy --strict green on both files + ruff clean + frozen-dataclass immutability test (D4) + path-safety enforcement test (D4)

**LOC ceiling**: ≤140 LOC combined (target ~120)

**DoD**:
- [ ] Both files exist at exact paths
- [ ] PdfSource frozen + slotted + 6 fields + path-safety + Rule 1 invariant
- [ ] ExtractedFinancialStatement frozen + slotted + 7 fields + post_init validation
- [ ] D-059 R1 datetime-tz enforced on `extracted_at`
- [ ] D-064 path-safety enforced on PdfSource.pdf_path
- [ ] mypy --strict green
- [ ] ruff clean

**Blocks**: D3 (bake-off probe writes ExtractedFinancialStatement-shaped output); D5 (ADR D-080 records this contract)

**Depends on**: D1 (PdfSource is referenced in ABC `extract` method signature; ExtractedFinancialStatement is ABC return type)

### E.3 Sub-track D3 — Empirical bake-off probe script + bake-off report

**Files**:
- `apps/cli/bench/__init__.py` (NEW ~3 LOC; module docstring "One-off benchmark probes — NOT production CLI")
- `apps/cli/bench/pdf_bake_off.py` (NEW ~150-200 LOC; one-off probe per DD-6)
- `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (NEW ~250-350 LOC empirical report per § A.1 structure)

**Tasks**:

1. Author `apps/cli/bench/pdf_bake_off.py`:
   - Argparse CLI: `--pdf-path PATH` (required; gold-set fixture path) + `--library {pdfplumber,docling,pypdf,all}` (default `all`) + `--output PATH` (JSON report output; default writes to agent-workspace/research/pdf-library-bakeoff-2026-05-G1-raw.json) + `--expected-cells PATH` (required; expected_cells JSON path) + `--runs N` (default 3; for p50/p95 wall-time)
   - For each library:
     - Probe install verification (per STEP 0.2.c)
     - Wall-time measurement (N runs; record p50 + p95 per Metric 2)
     - Cell extraction: invoke library to extract tables → flatten to `dict[label, raw_string]` adapter-specific
     - Minimal inline VND-string parser (D2 substrate; final parser at G.2; this minimal version handles `1.234.567` dot-separator + parenthesis-negative + Triệu/Tỷ-đồng unit scaling per RM4 lessons; reused at G.2 IMPL)
     - Cell-content-exact-match scoring per Metric 1 against `expected_cells_*.json`
     - Record JSON metric row: `{library, score, p50_wall_ms, p95_wall_ms, install_size_mb, transitive_dep_count, license, spdx, repo_url}`
   - Aggregate report write: pretty-print metric table + winner selection (highest Metric 1 with Metric 2 < 60s ceiling tie-break; Metric 3 + Metric 4 documentation-only NOT pick-deciding) + STOP-AND-ASK trigger evaluation
2. Author `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md`:
   - § Library-by-library 4-metric table (per STEP 2 of D3 probe execution)
   - § Winner ratification with rationale (cite metric scores)
   - § Adversarial alternates rejected with rationale (Karpathy P1 explicit; cite why non-winner not chosen)
   - § AP-7 named revisit triggers per non-winner (e.g. "docling LIKELY revisit at Phase G-prime-V2 IF accuracy drift surfaces on broker-report PDFs")
   - § STOP-AND-ASK trigger record (IF K.2.a fired)
   - § Source-evidence chain: pdfplumber repo + camelot repo + docling repo + pypdf repo + PyPI license verification
   - § Probe reproducibility instructions: isolated venv setup + 3 library install + `python -m apps.cli.bench.pdf_bake_off --pdf-path tests/fixtures/pdf/vhm-2023-annual.pdf --expected-cells tests/fixtures/pdf/expected_cells_vhm.json --library all`

**Verify**: probe runs to completion on both VHM + HPG gold-set without uncaught exception; JSON report parses; bake-off report markdown lints

**LOC ceiling**: ≤220 LOC for probe script + ≤400 LOC for bake-off report

**DoD**:
- [ ] apps/cli/bench/__init__.py + pdf_bake_off.py exist at exact paths
- [ ] Probe runs successfully on 2-document gold set (VHM + HPG)
- [ ] 4-metric table populated with empirical data (NOT placeholder)
- [ ] Winner selection ratified with rationale
- [ ] STOP-AND-ASK trigger evaluation recorded (PROCEED OR ESCALATE per K.2.a)
- [ ] Isolated venv setup instructions in module docstring (per STEP 0.2.c)
- [ ] D-064 path-safety enforced on --pdf-path + --expected-cells input
- [ ] bake-off report at agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md exists with all 7 sections

**Blocks**: D5 (ADR D-080 records empirical winner from this output); G.2 sub-plan 042 PLAN (consumes winner library + 4-metric grid)

**Depends on**: D2 (writes ExtractedFinancialStatement-shaped output); gold-set fixtures (per D4 deliverable)

**Parallel-eligible with**: D4, D5-skeleton (disjoint file scopes per § A.4 PARALLEL OPPORTUNITY)

### E.4 Sub-track D4 — ABC contract tests + dataclass tests + gold-set fixtures

**Files**:
- `packages/application/fundamental/test_pdf_table_extractor_port.py` (NEW ~80-100 LOC)
- `packages/application/fundamental/test_extracted_financial_statement.py` (NEW ~80-100 LOC)
- `tests/fixtures/pdf/` (NEW directory)
- `tests/fixtures/pdf/vhm-2023-annual.pdf` (NEW binary ~3-5 MB)
- `tests/fixtures/pdf/hpg-2023-annual.pdf` (NEW binary ~3-5 MB)
- `tests/fixtures/pdf/SHA256.txt` (NEW ~10 LOC: per-file SHA256 hex + source URL comment + commit date)
- `tests/fixtures/pdf/expected_cells_vhm.json` (NEW ~50 LOC: 10 LineItemKey × {value, page, context})
- `tests/fixtures/pdf/expected_cells_hpg.json` (NEW ~50 LOC; same shape)

**Tasks**:

1. Author `test_pdf_table_extractor_port.py`:
   - Test: `__init_subclass__` raises TypeError on empty `source_id` (firing-test per D-066 precedent at packages/application/news/ports/crawler_adapter.py test analog)
   - Test: `__init_subclass__` raises TypeError on missing `source_id` ClassVar
   - Test: Cannot instantiate PdfTableExtractorPort directly (abstract methods not implemented)
   - Test: Subclass with all 4 abstract methods + `source_id` instantiates successfully
   - Test: PdfTableExtractorError + PdfTableExtractorOptionalDepError hierarchy
2. Author `test_extracted_financial_statement.py`:
   - Test: PdfSource frozen-dataclass immutability (raises FrozenInstanceError on field reassignment)
   - Test: PdfSource path-safety enforcement (raises ValueError on path outside allowed roots)
   - Test: PdfSource Rule 1 invariant (filing_date < period_end raises)
   - Test: ExtractedFinancialStatement frozen-dataclass immutability
   - Test: ExtractedFinancialStatement raw_cells non-empty enforced
   - Test: ExtractedFinancialStatement sha256 regex enforced
   - Test: ExtractedFinancialStatement extracted_at tz-aware (D-059 R1)
   - Test: Gold-set fixture SHA256 match assertion (reads tests/fixtures/pdf/SHA256.txt + verifies each fixture file SHA256 matches manifest)
3. Manually annotate gold-set:
   - Open VHM 2023 annual report PDF → identify 10 canonical line-item cells (REVENUE / NET_INCOME / TOTAL_ASSETS / etc per LineItemKey:33-45) at period_end 2023-12-31 → record `{value: Decimal, page: int, context: str}` in expected_cells_vhm.json
   - Same for HPG 2023 annual report → expected_cells_hpg.json
4. Compute SHA256 for both PDF files + record in SHA256.txt manifest with source URL comments

**Verify**: pytest packages/application/fundamental/test_*.py passes all tests; gold-set fixture SHA256 manifest matches actual file SHA256s

**LOC ceiling**: ≤220 LOC for tests + ≤120 LOC for JSON fixtures + binary PDFs ~6-10 MB

**Firing tests budget**: NO new hooks shipped this sub-plan; firing-test mandate per Charter Principle 11 N/A; product-substrate-only

**DoD**:
- [ ] Both test files exist + pytest green (all tests pass)
- [ ] Gold-set 2 PDFs committed at tests/fixtures/pdf/
- [ ] SHA256.txt manifest matches actual file hashes
- [ ] expected_cells_*.json with 10 LineItemKey × {value, page, context} per fixture
- [ ] mypy --strict green on test files
- [ ] ruff clean

**Blocks**: D3 (probe reads gold-set fixtures); D5 (ADR D-080 records test coverage)

**Depends on**: D1 (test imports PdfTableExtractorPort); D2 (test imports ExtractedFinancialStatement + PdfSource)

**Parallel-eligible with**: D3, D5-skeleton (disjoint file scopes)

### E.5 Sub-track D5 — ADR D-080 PROPOSED + wc -l attestation + dispatch handoff

**Files**:
- `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (NEW ~150-200 LOC)

**Tasks**:

1. Author ADR D-080 per parent plan-040 DD-8 + L-S389-2 12-field schema floor:
   - id: D-080
   - title: "PdfTableExtractorPort ABC contract + G.1 empirical library bake-off winner"
   - status: PROPOSED (AUTO-ACCEPT at S394 close per severity-schema; no CHARTER cool-down)
   - severity: MEDIUM (IMPL-tier)
   - date: 2026-05-?? (S394 IMPL session date)
   - context: cite parent plan-040 § A goal + § D DDs + § E.1 sub-plan contract + dispatch brief § A
   - decision: cite DD-1 ABC location + DD-2 4-method surface + DD-3 gold-set sourcing + DD-4 cell-content-exact-match + DD-5 surgical-scope + DD-6 bake-off probe location + DD-7 ADR landing + DD-8 isolated-venv probe
   - rationale: cite D-066 CrawlerAdapter precedent + L-S32-1 empirical-probe-first + Karpathy P2/P3 + parent plan-040 binding decisions
   - alternatives_considered: cite adversarial alternates rejected per DD-1..DD-8 above
   - consequences: cite (a) G.2 sub-plan 042 dispatch consumes winner + ABC + (b) G.3 sub-plan 043 dispatch consumes ABC + (c) G.4 sub-plan 044 dispatch consumes both adapters
   - source_evidence: ≥3 citations per claim (e.g. parent plan-040:NNN, D-066 ADR, crawl4ai/hub.py:24-35, F.1 RolePromptPack precedent, D-072 BC-5 transport-flip)
   - depends_on: D-066 (CrawlerAdapter ABC precedent) + D-059 (Python determinism) + D-064 (path-safety) + D-061 (add-with-rationale doctrine)
   - supersedes: NONE (new ADR)
   - superseded_by: NONE (active)
   - revisit_trigger: per AP-7 named: (a) ABC method count exceeds 4 (D-080-V2) + (b) winner library license posture changes + (c) accuracy floor unmet on 5-document G.4 gold set (Phase G-prime-V2)
2. wc -l attestation per L-S385-1 promotion (sandwich-dev.md template per harness sweep N+1 D7): record exact LOC for each new file at session end in observation
3. Dispatch handoff: observation file at `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-extractor-port-bakeoff.md` summarizes (a) D1-D5 DoD per § F + (b) empirical winner from D3 bake-off report + (c) charter-tier surface FLAG status (PROCEEDED OR ESCALATED per K.2.a) + (d) sub-plans 042 + 043 dispatch-ready signal for main session post-S395 verifier PASS

**Verify**: ADR file lints + 12 fields present + ≥3 source_evidence cites per claim

**LOC ceiling**: ≤220 LOC for ADR (target ~180)

**DoD**:
- [ ] ADR D-080 exists at exact path
- [ ] 12-field schema satisfied
- [ ] ≥3 source_evidence cites per major claim
- [ ] AP-7 revisit_triggers named per non-winner
- [ ] Observation file written
- [ ] wc -l attestation recorded for each new file

**Blocks**: NONE (D5 is terminal in DAG; final ratification)

**Depends on**: D1 + D2 + D3 + D4 (all sub-tracks complete; D5 records the result)

**Parallel-eligible with**: D3 + D4 (D5-skeleton can be authored in parallel with D3/D4; D5-final-synthesis blocks on D3 winner-pick output)

---

## F. File scope (BINDING — S394 IMPL session is AUTHORIZED to touch only these files)

Per dispatch brief § F — exact file paths the IMPL session is authorized to touch:

### F.1 NEW files (G.1 IMPL D1-D5 creates these)

| Path | Owner | LOC budget | Sub-track |
|---|---|---|---|
| `packages/application/fundamental/__init__.py` | NEW | ~5 | D1 |
| `packages/application/fundamental/pdf_table_extractor_port.py` | NEW | ~100 | D1 |
| `packages/application/fundamental/pdf_source.py` | NEW | ~40 | D2 |
| `packages/application/fundamental/extracted_financial_statement.py` | NEW | ~80 | D2 |
| `packages/application/fundamental/test_pdf_table_extractor_port.py` | NEW | ~100 | D4 |
| `packages/application/fundamental/test_extracted_financial_statement.py` | NEW | ~100 | D4 |
| `apps/cli/bench/__init__.py` | NEW | ~3 | D3 |
| `apps/cli/bench/pdf_bake_off.py` | NEW | ~180 | D3 |
| `tests/fixtures/pdf/vhm-2023-annual.pdf` | NEW (binary) | ~3-5 MB | D4 |
| `tests/fixtures/pdf/hpg-2023-annual.pdf` | NEW (binary) | ~3-5 MB | D4 |
| `tests/fixtures/pdf/SHA256.txt` | NEW | ~10 | D4 |
| `tests/fixtures/pdf/expected_cells_vhm.json` | NEW | ~50 | D4 |
| `tests/fixtures/pdf/expected_cells_hpg.json` | NEW | ~50 | D4 |
| `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` | NEW | ~300 | D3 |
| `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` | NEW | ~180 | D5 |
| `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-extractor-port-bakeoff.md` | NEW (observation per session-protocol) | ~120 | D5 |
| `agent-workspace/memory/sessions/2026-05-??-session-394.md` | NEW (session log per CLAUDE.md § Session Protocol End) | ~60 | D5 |
| `agent-workspace/memory/.planner-stats.tsv` | APPEND-ONLY (per planner-feedback-loop.sh post-harness-sweep S388 D1) | +1 row | (auto via hook) |

**Total NEW production LOC**: ~640 (well within Karpathy P3 ≤500 LOC ceiling per parent plan-040 binding-decision; ADR + observation + session log = orchestration overhead not production code)

### F.2 MODIFIED files (NONE — this sub-plan adds NEW substrate; ZERO touch to existing)

- ZERO touch to `packages/domain/fundamental/**`
- ZERO touch to `packages/infrastructure/fundamental/**` (vnstock_fundamental_adapter.py UNCHANGED; sqlite_fundamental_repository.py UNCHANGED)
- ZERO touch to `packages/application/news/**` (D-066 CrawlerAdapter source pattern reference; not modified)
- ZERO touch to `packages/_shared/**` (constraint violation per DD-1)
- ZERO touch to `apps/cli/*.py` (existing 19 CLI scripts UNCHANGED; bench/ is NEW sub-directory)
- ZERO touch to `apps/crawlers/cafef_html_to_md.py` (per DD-5 BC-5 stays HTML-route)
- ZERO touch to any other BC (BC-1 / BC-3 / BC-4 / BC-5 / BC-6 / BC-7 / BC-8 / BC-9 — per parent plan-040 § F.3 BC-2 scoped)
- ZERO touch to `pyproject.toml` (per DD-8 isolated-venv probe)
- ZERO touch to `PROJECT_CHARTER.md` (hard rule)
- ZERO touch to `agent-workspace/constitution/**` (hard rule)
- ZERO touch to `human-workspace/**` EXCEPT conditional `human-workspace/notifications/STOP-FINDING-S394-*.md` if K.2.a STOP-AND-ASK fires

### F.3 ADDITIONS allowed (per harness state-marker writes per planner-feedback-loop.sh D1 promotion at S388)

- `agent-workspace/memory/.planner-stats.tsv` — APPEND ROW (auto via hook per S388 D1 promotion); not a manual touch

---

## G. Sub-track DoDs (measurable per-STEP criteria)

Per dispatch brief § G — measurable per-STEP DoD + pytest count budget + firing-test budget + LOC ceiling per STEP (lessons from L-S345-1 drift discipline).

### G.1 Per-sub-track DoD criteria

**D1 DoD**:
- [ ] `packages/application/fundamental/__init__.py` exists (~5 LOC; module docstring)
- [ ] `packages/application/fundamental/pdf_table_extractor_port.py` exists (~100 LOC; LOC ceiling ≤120)
- [ ] `__init_subclass__` raises TypeError on empty `source_id` (firing-test in D4)
- [ ] 4 `@abstractmethod` decorators present (extract + supports + name + extractor_version)
- [ ] PdfTableExtractorError + PdfTableExtractorOptionalDepError exception hierarchy
- [ ] crawl4ai/hub.py:24-35 NOTICE attribution at file top
- [ ] mypy --strict green
- [ ] ruff clean
- [ ] LOC actual ≤120 (wc -l attestation in D5)

**D2 DoD**:
- [ ] `packages/application/fundamental/pdf_source.py` exists (~40 LOC; LOC ceiling ≤60)
- [ ] `packages/application/fundamental/extracted_financial_statement.py` exists (~80 LOC; LOC ceiling ≤100)
- [ ] PdfSource frozen + slotted + 6 fields + path-safety via safe_user_path + Rule 1 invariant
- [ ] ExtractedFinancialStatement frozen + slotted + 7 fields + sha256 regex + extracted_at tz-aware
- [ ] D-059 R1 datetime-tz enforced on extracted_at
- [ ] D-064 path-safety enforced on PdfSource.pdf_path
- [ ] mypy --strict green
- [ ] ruff clean
- [ ] LOC actual ≤160 combined (wc -l attestation in D5)

**D3 DoD**:
- [ ] `apps/cli/bench/__init__.py` exists (~3 LOC)
- [ ] `apps/cli/bench/pdf_bake_off.py` exists (~180 LOC; LOC ceiling ≤220)
- [ ] Probe runs successfully on VHM + HPG gold set (no uncaught exception)
- [ ] 4-metric table populated with empirical data per library
- [ ] Winner selection ratified with rationale (cite metric scores)
- [ ] STOP-AND-ASK trigger evaluation recorded (PROCEED OR ESCALATE per K.2.a)
- [ ] Isolated venv setup in module docstring
- [ ] D-064 path-safety enforced on --pdf-path + --expected-cells
- [ ] `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` exists with all 7 sections (per § E.3 task 2)
- [ ] LOC actual probe ≤220 + report ≤400 (wc -l attestation in D5)

**D4 DoD**:
- [ ] `packages/application/fundamental/test_pdf_table_extractor_port.py` exists (5+ test cases per § E.4 task 1)
- [ ] `packages/application/fundamental/test_extracted_financial_statement.py` exists (8+ test cases per § E.4 task 2)
- [ ] pytest packages/application/fundamental/test_*.py passes ALL tests (target ≥13 test cases)
- [ ] `tests/fixtures/pdf/vhm-2023-annual.pdf` committed (~3-5 MB)
- [ ] `tests/fixtures/pdf/hpg-2023-annual.pdf` committed (~3-5 MB)
- [ ] `tests/fixtures/pdf/SHA256.txt` manifest matches actual file hashes
- [ ] `tests/fixtures/pdf/expected_cells_vhm.json` with 10 LineItemKey entries (per § E.4 task 3)
- [ ] `tests/fixtures/pdf/expected_cells_hpg.json` with 10 LineItemKey entries
- [ ] mypy --strict green on test files
- [ ] ruff clean

**D5 DoD**:
- [ ] `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` exists (~180 LOC; LOC ceiling ≤220)
- [ ] ADR D-080 12-field schema satisfied (id + title + status + severity + date + context + decision + rationale + alternatives_considered + consequences + source_evidence + depends_on + supersedes + superseded_by + revisit_trigger = 15 fields actual; ≥12 floor satisfied)
- [ ] ≥3 source_evidence cites per major claim (per I-S2)
- [ ] AP-7 revisit_triggers named per non-winner library
- [ ] `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-extractor-port-bakeoff.md` exists with wc -l attestation per L-S385-1
- [ ] `agent-workspace/memory/sessions/2026-05-??-session-394.md` exists per CLAUDE.md § Session Protocol End

### G.2 pytest count budget

- D4 minimum: 13 test cases (5 ABC contract + 8 dataclass validation)
- Existing pytest count baseline at S392 PLAN authoring: TBD (S394 dev runs `pytest --collect-only -q | tail -1` at session entry; records baseline; final count = baseline + 13 minimum)
- pytest must pass at session end (per Charter Principle 11 + Tier 1 deterministic gate)

### G.3 Firing-test budget

- NEW hooks: 0 (this sub-plan ships product substrate ONLY per parent plan-040 hard_rules "no harness/hook changes")
- Firing-test mandate per Charter Principle 11 IF a hook is shipped: N/A
- Firing-test budget: 0

### G.4 LOC ceiling per STEP

- D1: ≤120 LOC (target ~100)
- D2: ≤160 LOC combined (target ~120)
- D3: ≤220 LOC probe + ≤400 LOC report (target ~180 probe + ~300 report)
- D4: ≤220 LOC tests + ≤120 LOC fixtures + binary PDFs (target ~180 tests + ~110 fixtures)
- D5: ≤220 LOC ADR (target ~180)
- **Total new code (excluding ADR + binary fixtures + report MD)**: ~640 LOC actual / ~720 LOC ceiling

### G.5 Drift discipline (L-S345-1 carry-forward)

Per L-S345-1 promotion at harness sweep N+1 S388 D7 (sandwich-dev.md template wc -l exact-at-end discipline):

- S394 dev records exact LOC per new file at session end (`wc -l` per file)
- Records in observation under "Files created + LOC" section
- Any LOC overage vs § G.4 ceiling = FLAG in observation; defer to verifier S395 to assess Karpathy P3 surgical-scope discipline
- ≤5% LOC overage acceptable; >5% triggers SPLIT-or-justify discussion

---

## H. Risks + Mitigations (RM1 through RM5; per dispatch brief § H)

### H.1 RM1 — No-clear-winner empirical pivot (multi-adapter fallback chain needed)

- **Likelihood**: MEDIUM (parent plan-040 RM-G-1 estimate; VN-specific PDFs not surveyed in any candidate library's test corpus; supplement § J.5 line 313 cites "Naive impl insufficient for VN broker reports")
- **Impact**: HIGH (G.2 pure-Python adapter has no clear winner; downstream sub-plans block)
- **Mitigation**:
  - **Mitigation 1**: D3 bake-off probe defines no-clear-winner threshold = NO library scores ≥70% on Metric 1 cell-content-exact-match AND no library is ≥10 percentage-points above the next-best
  - **Mitigation 2**: IF no-clear-winner triggers → § J K.2.a STOP-AND-ASK fires; S394 dev writes `human-workspace/notifications/STOP-FINDING-S394-no-clear-winner.md` with options menu: (a) expand probe to 5-document G.4-anticipated gold set / (b) accept multi-adapter fallback chain (G.2 ships TWO adapters per parent plan-040 § E.2 multi-impl) / (c) pivot to Claude vision G.3 as primary winner with pure-Python deferred / (d) cancel Phase G-prime + revisit at Phase 2
  - **Mitigation 3**: Bake-off report records the no-clear-winner state explicitly + cites all 3 adapter scores; ADR D-080 PROPOSED records the K.2.a escalation; main session AskUserQuestion gate per K.4 ratification path

### H.2 RM2 — docling pip install fails on Windows (parent plan-040 § C.0.2 mentioned as modern alternative; install path unverified on Windows)

- **Likelihood**: MEDIUM (docling is recent IBM open-source; multi-modal stack may have OS-specific deps; STOCKFORGE primary OS = Windows 11 per env metadata "OS Version: Windows 11 Pro 10.0.26100"; pip install on Windows has historical issues with C-extension deps)
- **Impact**: MEDIUM (loss of 1 of 3 probe candidates; reduces winner-pick signal from 3-way to 2-way)
- **Specific known issues to verify at STEP 0.2.c**:
  - docling has `pillow >= 10.4.0` + `transformers` + `torch` deps — torch on Windows pip install requires CUDA matching or CPU-only flavor (`pip install torch --index-url https://download.pytorch.org/whl/cpu` may be needed)
  - docling's OCR backend (tesseract) is system-installed, not pip-installed → may need `tesseract-ocr` Windows installer separately
- **Mitigation**:
  - **Mitigation 1**: STEP 0.2.c isolated-venv probe attempts docling install FIRST (riskiest of 3 candidates); IF install fails on Windows, document failure mode in bake-off report § Library-by-library 4-metric table with score=0 + reason=install-failure
  - **Mitigation 2**: 2-way bake-off (pdfplumber+camelot vs pypdf) still produces winner-pick if docling install fails; degraded-signal NOT no-signal
  - **Mitigation 3**: IF only 1 library installs successfully (catastrophic install failure on 2/3) → § J K.2.a STOP-AND-ASK escalates; main session ratifies pivot

### H.3 RM3 — Gold-set licensing / commit-eligibility for VHM + HPG annual reports

- **Likelihood**: LOW (VN listed companies are mandated to publish annual reports under SSC regulations; reports are explicitly PUBLIC disclosure)
- **Impact**: HIGH IF triggered (cannot commit PDFs → cannot reproduce empirical probe)
- **Mitigation**:
  - **Mitigation 1**: Source URLs in tests/fixtures/pdf/SHA256.txt explicitly cite Vietstock public OR VN company IR website (both PUBLIC sources per I-S34); NO scraping bypass of paywalls
  - **Mitigation 2**: Commit each PDF with explicit attribution comment in SHA256.txt header: "Source: <URL> — public annual report disclosure under SSC regulations; reproduced for benchmark fixture; original copyright remains with publishing company"
  - **Mitigation 3**: IF project-owner objects to PDF commit (size concern OR legal preference) → S394 STEP 0 STOP-AND-ASK options: (a) use git-lfs for binary PDFs / (b) move fixtures to .gitignored local cache + add download script / (c) bundle PDFs in a separate non-public test data repo

### H.4 RM4 — ABC over-engineering (Karpathy P2 simplicity violated by ≥5 abstract methods)

- **Likelihood**: LOW (DD-2 chose exactly 4 methods at Karpathy P2 ceiling; architect-time discipline already applied)
- **Impact**: MEDIUM IF triggered (adapter authoring complexity at G.2 + G.3 + future PDF adapters; ABC contract becomes harder to satisfy)
- **Mitigation**:
  - **Mitigation 1**: DD-2 enforces 4-method ceiling per Karpathy P2; if S394 dev surfaces NEED for 5th method (e.g. page_range for cost-targeting), defer to D-080-V2 amendment per § A.3 ABC method extension trigger
  - **Mitigation 2**: D-066 CrawlerAdapter precedent has 3 methods (one fewer); PdfTableExtractorPort has +1 for `extractor_version` provenance — extension is principled (provenance need) not speculative
  - **Mitigation 3**: ADR D-080 records 4-method choice + adversarial alternates rejected (DD-2 rationale); future ABC extension requires explicit ADR D-080-V2 amendment with justification

### H.5 RM5 — Hidden-state-from-probe (each adapter must be stateless OR explicitly document state model)

- **Likelihood**: MEDIUM (pdfplumber + camelot are stateless per documented API; docling may carry parser-state between calls; pypdf is stateless)
- **Impact**: MEDIUM (probe results non-reproducible if adapters carry hidden state across calls)
- **Mitigation**:
  - **Mitigation 1**: D3 bake-off probe re-instantiates each adapter per gold-set document (NO adapter reuse across documents); ensures stateless probe surface
  - **Mitigation 2**: ABC contract DOES NOT declare adapters stateless (cannot enforce via ABC); BUT contract docstring requires "Adapters MUST be safely re-instantiable per extract() call; MAY cache parser state internally but MUST NOT leak state across PdfSource instances"
  - **Mitigation 3**: D4 contract test for stateless-ness: instantiate adapter → call extract(pdf1) → call extract(pdf2) → assert state has NOT leaked from pdf1 to pdf2 (parametric test on minimal subclass)
  - **Mitigation 4**: Bake-off report § Adapter-state-model documents per-adapter state behavior + WARNINGS for stateful adapters (potential ARMv8 reproducibility risk)

### H.6 RM6 — Architect dispatch brief deviation (already documented in DD-1 + STEP 0.5)

- **Likelihood**: HIGH (already triggered — dispatch brief said `packages/_shared/pdf/` + cited non-existent `packages/_shared/crawl/crawler_adapter.py`)
- **Impact**: LOW (resolved via VBW correction; parent plan-040 DD-1 is canonical source per dispatch brief precedence rule)
- **Mitigation**:
  - **Mitigation 1**: DD-1 + STEP 0.5 + § P compliance attestation explicitly document the deviation + rationale + canonical source resolution
  - **Mitigation 2**: This RM6 surfaces a meta-pattern for future architect dispatches: dispatch brief paths SHOULD be VBW-verified against actual codebase before plan authoring; AP-7 named revisit trigger if 2nd instance fires → architect-dispatch template VBW pre-flight discipline

---

## J. K.2 charter-tier surface entries (per dispatch brief § J — plan-040 K.2.a trigger inheritance)

Per parent plan-040 § K.2 inheritance: this sub-plan INHERITS K.2.a CONDITIONAL trigger; main session DECIDES via AskUserQuestion if surface as decision-blocker.

### J.1 NON-BLOCKING design recommendation (default)

This sub-plan's RECOMMENDATION: **NON-BLOCKING Phase G.1 entry**. Architect-recommended defaults chosen per DD-1/DD-2/DD-3/DD-4/DD-5/DD-6/DD-7/DD-8. STEP 0 STOP-AND-ASK clauses fire ONLY IF empirical evidence contradicts architect-recommended defaults.

Sub-plan 041 PROCEEDS to S394 IMPL dispatch without user gate IF AND ONLY IF main session reviews this plan + accepts the 8 DDs.

### J.2 K.2.a inheritance — pymupdf AGPL-3.0 escalation OR no-clear-winner empirical pivot

Per parent plan-040 § K.2.a (trigger inheritance):

- **Trigger A**: G.1 IMPL empirical probe (STEP 0.1.b re-verification) reveals pymupdf license has CHANGED to BSD/MIT/Apache (currently AGPL-3.0 excluded) AND pymupdf significantly better than pdfplumber+camelot+docling+pypdf on VN PDFs in the 4-metric grid
- **Trigger B**: ALL 3 baseline candidates score <70% on Metric 1 cell-content-exact-match accuracy (no-clear-winner per RM1)
- **Charter-tier-surface**: license posture decision (stockforge license="Proprietary" per pyproject.toml:7 vs AGPL-3.0-viral) OR Phase scope pivot (V0 retargeting)
- **Default if NOT fired**: G.1 winner = whichever of pdfplumber+camelot OR docling OR pypdf scores highest on Metric 1 (Metric 2 < 60s tie-break; Metric 3 + Metric 4 documentation-only)
- **Pre-stated condition for AskUserQuestion gate fire**:
  - Trigger A: pymupdf license string verified MIT/BSD/Apache via STEP 0.1.b PyPI lookup AND Metric 1 score > best non-pymupdf by ≥10 percentage points
  - Trigger B: max(pdfplumber, docling, pypdf) Metric 1 score < 70 percentage points AND no library is ≥10 pp above the others
- **Main session decision path**: AskUserQuestion gate Q-INT-2026-05-G-prime-1 fires IF Trigger A OR Trigger B

### J.3 Ratification path (this sub-plan)

Main session reviews + ratifies via standard parent plan-040 § K.4 path:
1. Read this sub-plan markdown
2. Verify § J FLAGS understood; NO blocking unless triggered by S394 dev STEP 0 empirical probe
3. Commit this plan via D-060 + pre-dispatch-architect-commit-guard.sh hook
4. Dispatch S394 sandwich-dev FOCUSED_IMPL per § N.2 sequencing
5. S394 dev STEP 0.1.b + STEP 0.2 fire K.2.a IF empirical probe contradicts architect-recommended default
6. IF K.2.a fires → S394 dev writes STOP-FINDING file at `human-workspace/notifications/STOP-FINDING-S394-*.md` per parent plan-040 § K.2.a path; main session fires AskUserQuestion gate Q-INT-2026-05-G-prime-1

---

## K. Coordination paths off-limits during S394 IMPL

Per dispatch brief § F BINDING file scope + L-S345-1 surgical-scope discipline:

### K.1 OFF-LIMITS file paths (S394 IMPL session MUST NOT touch)

- `packages/domain/**` (BC-2 + all other domain UNCHANGED; ExtractedFinancialStatement is application-layer NOT domain)
- `packages/infrastructure/fundamental/**` (vnstock_fundamental_adapter.py + sqlite_fundamental_repository.py UNCHANGED; G.2 sub-plan 042 adds new PDF adapter in this directory)
- `packages/application/news/**` (D-066 CrawlerAdapter reference only; NOT modified)
- `packages/_shared/**` (constraint violation per DD-1)
- `apps/cli/*.py` (existing 19 CLI scripts UNCHANGED; only NEW apps/cli/bench/ sub-directory added)
- `apps/crawlers/cafef_html_to_md.py` (per DD-5 BC-5 stays HTML-route)
- Any other BC: BC-1 / BC-3 / BC-4 / BC-5 / BC-6 / BC-7 / BC-8 / BC-9
- `pyproject.toml` (per DD-8 isolated-venv probe)
- `PROJECT_CHARTER.md` (hard rule)
- `agent-workspace/constitution/**` (hard rule)
- `agent-workspace/master-plans/**` (parent plan-040 UNCHANGED; this sub-plan REFERENCES not modifies)
- `agent-workspace/session-plans/pending/040-*.md` (parent plan UNCHANGED)
- `agent-workspace/session-plans/completed/**` (historical; not modified)

### K.2 PARALLEL-eligible files (S394 dev MAY touch in parallel with D3 per § A.4 PARALLEL OPPORTUNITY)

- D1 (sequential first)
- D2 (sequential after D1)
- D3 (sequential after D2; DOMINANT)
- D4 + D5-skeleton (parallel-eligible with D3; disjoint file scopes per Glob)

### K.3 SHARED-WRITE coordination (none expected)

No 2-way write collision risk — G.1 sub-plan adds NEW substrate; ZERO existing-file modification.

---

## L. Promotion candidates (per AP-7 pre-flag pattern; capture-now, evaluate at sub-plan close)

Per parent plan-040 § L pattern + AP-23 promote-or-retire calculus:

| Candidate | Source | Promotion-readiness criterion | Notes |
|---|---|---|---|
| **PCG-1**: PdfTableExtractorPort ABC pattern (4-method + ClassVar + `__init_subclass__` typecheck) | D1 ABC contract | If reused for G.2 + G.3 adapters unchanged | LIKELY 2nd-instance promote at G.3 close (parent plan-040 § L PCG-6 ExtractedX pattern analog) |
| **PCG-2**: ExtractedFinancialStatement intermediate dataclass pattern (per-adapter polymorphism without domain pollution) | D2 dataclass | If reused for G.3 Claude vision adapter (already-promoted pattern per parent plan-040 § L PCG-6 — BC-5 ExtractedClaim precedent) | ALREADY-promoted at BC-5; G.1 extends to BC-2 = 2nd-BC use; promote-confirmation at G.3 close |
| **PCG-3**: 4-metric empirical bake-off harness (cell-content-exact-match + wall-time + dep-footprint + license) | D3 probe + report | If reused for ANY future library-choice sub-plan | DEFER per parent plan-040 § L PCG-5 (empirical-probe-first sub-plan structure) — needs 2nd-instance to validate sub-plan template; L-S32-1 skill exists, sub-plan-shape codification deferred |
| **PCG-4**: Gold-set fixture pattern for empirical calibration (tests/fixtures/pdf/ + SHA256 manifest + per-document expected-cells JSON) | D4 fixtures | If reused for BC-5 News calibration gold set OR BC-6 KOL recommendation gold set (parent plan-040 § L PCG-7) | LIKELY promote — Charter Principle 8 calibration over confidence operationalization primitive |
| **PCG-5**: Minimal inline VND-string parser (within bake-off probe; final parser at G.2) | D3 probe substrate | If reused at G.2 + parent plan-040 § L PCG-2 confirms cross-BC reuse | LIKELY promote at G.2 close — Vietnamese-locale numeric parsing is cross-BC utility per parent plan-040 § L PCG-2 |
| **PCG-6**: Architect-dispatch-brief VBW pre-flight discipline | RM6 + STEP 0.5 dispatch-brief deviation | If 2nd instance of dispatch-brief path-error fires → architect-template VBW pre-flight discipline ADR | DEFER per AP-23 1st-instance HOLD; RM6 1st-instance documented; 2nd instance triggers promote-to-template-discipline |

Sub-plan 041 STEP 5.5 (per harness sweep N+1 D6 promotion at S388) captures additional promotion candidates surfaced at S394 IMPL time. AP-23 calculus applies at sub-plan close (S395 verifier session).

---

## N. Sub-plan dispatch sequencing (per dispatch brief § N)

### N.1 What S393 (parallel) data-corpus operational plan-045 IMPL is INDEPENDENT of

Per dispatch brief § N + parent plan-040 § N.4:

- S393 sandwich-dev executes operational data-corpus ingestion track (Phase F-prime CODE-DONE-DATA-PENDING from S386; user-authorized real-API-budget commitment per Charter Principle 7)
- S393 file scope: BC-5 News (existing crawlers) + BC-1 OHLCV (existing market_data adapter) + BC-2 vnstock-existing-adapter (vnstock_fundamental_adapter.py) — ZERO overlap with G.1 file scope (G.1 = NEW packages/application/fundamental/ + NEW apps/cli/bench/ + NEW tests/fixtures/pdf/)
- S393 plan-045 is independent of plan-041 per parent plan-040 § N.4 parallel-dispatch authorization (Phase G-prime sub-plans CAN run PARALLEL with Phase F-prime data-corpus ingestion operational track; ZERO collision per file scope)
- Main session orchestrates S392 (THIS PLAN; sandwich-architect) + S393 (sandwich-dev plan-045 IMPL) as 2-parallel dispatch per plan-025 DD-5 3-parallel ceiling

### N.2 What S394 sandwich-dev for plan-041 IMPL NEEDS

S394 dispatch pre-requisites:

1. **plan-041 PLAN authored + committed**: main session commits THIS plan via D-060 + pre-dispatch-architect-commit-guard.sh hook post-S392 architect output
2. **Pre-dispatch guard satisfied**: plan-041 commit (parent_plan = plan-040; sub_plan_id = 041; matches commit-guard schema)
3. **STEP 0 STOP-AND-ASK NOT fired in S392 PLAN session**: confirmed at S392 close (no charter-tier surface FLAG triggered at PLAN-tier; only CONDITIONAL K.2.a inheritance carry-forward to S394 IMPL)
4. **Phase G-prime parallel-dispatch gate still satisfied**: Phase F-prime CODE-DONE-DATA-PENDING at S386 commit 90b27db (parent plan-040 § N.4 attestation) — Phase G-prime authorized

### N.3 What G.2/G.3/G.4 unblock contracts look like (post-S395 verifier PASS)

Per parent plan-040 § N.2 + § E.2/E.3/E.4:

- **G.2 (sub-plan 042) unblock contract**: G.1 ratified winner library exists in `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` § Winner ratification with rationale; PdfTableExtractorPort ABC exists at `packages/application/fundamental/pdf_table_extractor_port.py`; ExtractedFinancialStatement exists at `packages/application/fundamental/extracted_financial_statement.py`; G.2 PLAN author imports winner library + subclasses PdfTableExtractorPort + populates ExtractedFinancialStatement
- **G.3 (sub-plan 043) unblock contract**: PdfTableExtractorPort ABC exists; ExtractedFinancialStatement exists; G.3 PLAN author subclasses ABC for Claude vision adapter; claude CLI substrate vision-input feasibility probed at G.3 STEP 0; EchoValidator gate authored as separate file
- **G.4 (sub-plan 044) unblock contract**: BOTH G.2 + G.3 adapters shipped + verified; G.4 CLI dispatches to both via `supports(pdf) → bool` ABC pre-check + measures per-adapter accuracy on 5-document gold set (expanded from G.1's 2-document baseline)

### N.4 Sequencing summary

Per parent plan-040 § N.2 + dispatch brief § J:

| Session | Plan | Type | Pre-requisite | Parallel-eligible with |
|---|---|---|---|---|
| S391 (DONE) | plan-040 | PHASE-MASTER-PLAN | Parent plan-033 § N parallel-dispatch authorization | Phase F-prime data-corpus track |
| **S392 (THIS PLAN)** | **plan-041** | **SUB-PLAN PLAN** | **plan-040 § N.2 sequencing + plan-040 committed at b2e8b62** | **S393 (plan-045 IMPL — disjoint file scope per § N.1)** |
| S393 (parallel with S392) | plan-045 | IMPL | Phase F-prime CODE-DONE-DATA-PENDING + user-auth real-API budget | S392 (plan-041 PLAN — disjoint file scope) |
| S394 | plan-041 | SUB-PLAN IMPL | plan-041 PLAN committed | NONE (disjoint candidates unblocked post-S395) |
| S395 | (verifier dispatch on S394 output) | VERIFY | S394 close | NONE |
| S396 + S397 | plan-042 (G.2) + plan-043 (G.3) | SUB-PLAN PLAN | S395 verifier PASS | PARALLEL pair (parent plan-040 § N.2) |
| S398 + S399 | plan-042 + plan-043 | SUB-PLAN IMPL | corresponding PLAN committed | PARALLEL pair |
| S400 + S401 | (verifier dispatches) | VERIFY | corresponding IMPL close | NONE |
| S402 | plan-044 (G.4) | SUB-PLAN PLAN | BOTH 042 + 043 VERIFY PASS | NONE |
| S403 | plan-044 | SUB-PLAN IMPL | plan-044 PLAN committed | NONE |
| S404 | (verifier) | VERIFY | S403 close | NONE |
| S404 close | (close-bookkeeping) | CLOSE | Phase G-prime DoD attestation | NONE |

---

## P. Compliance attestation (sub-plan authoring session S392)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; harness sweep N+1 S388 commit 78089ba already SHIPPED + LIVE per current-execution.md:147; this sub-plan inherits the now-live `.planner-stats.tsv` writer auto-population)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 18+ source files cited inline per § A.4)
- AP-7 ✓ (every DEFER decision in § A.3 + § H + § L names prerequisites + revisit triggers — no naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED as PCG-1..6 for promote-or-retire calculus at sub-plan close; 1st-instance HOLD applied; promotion-on-2nd-recurrence calculus respected)
- autonomous_continue_no_self_pause ✓ (architect ships sub-plan authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session commits + dispatches S394 dev per § N sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing in § N is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-059 BINDING for S394 IMPL per § F.1 (R1 datetime-tz on extracted_at field at ExtractedFinancialStatement)
- D-064 BINDING for S394 IMPL per § F.1 (path-safety on PdfSource.pdf_path + bake-off probe --pdf-path)
- D-066 INFORMATIONAL precedent ✓ (CrawlerAdapter ABC at packages/application/news/ports/crawler_adapter.py; same Strategy ABC + ClassVar + `__init_subclass__` typecheck pattern)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- 0 pyproject.toml writes ✓ (DD-8 isolated-venv probe; G.2 IMPL ratifies winner dep addition)
- I-S1 ✓ (this sub-plan ships ABC + intermediate dataclass + bake-off probe; no LLM-output path introduced; G.3 sub-plan introduces it with Rule 16 mode #2 satisfaction)
- I-S1-1 (Rule 16) ✓ (N/A this sub-plan per parent plan-040 § C.0.4 audit — G.1 has no LLM-numeric fields; mode #2 deterministic-pipeline echo for cell numeric values covered at G.2 IMPL)
- I-S2 ✓ (every plan claim cites source file:line per § A.4 + § H source-evidence)
- I-S20 ✓ (bake-off report records empirical winner with 4-metric grid; calibration_grade='D' V0 baseline for G.2/G.3)
- I-S22 ✓ (data lineage extended via ExtractedFinancialStatement 6 provenance fields per parent plan-040 DD-3)
- I-S34 ✓ (gold-set sourcing uses Vietstock public + VN company website only per RM3; no paid leak channels)
- I-S35 ✓ (Theme J output = FinancialStatement ingestion to BC-2 → BC-9 thesis pipeline; NO buy/sell surface introduced)
- Phase 1b CONSUMED + COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; planner-stats infrastructure live post-S388 D1 promotion; cold-start declared on new task_class="pdf-extraction-plan" only)
- 5-source-evidence chain per § D DDs (DD-1 cites parent plan-040 DD-1 + D-066 + STEP 0.5 VBW + `packages/_shared/__init__.py` + DDD skill; DD-2 cites parent plan-040 DD-1 + D-066 + crawl4ai/hub.py + Karpathy P2 + dispatch brief § H RM4; etc.)
- L-S32-1 empirical-probe-first SKILL doctrine ACKNOWLEDGED in DD-4 + § C STEP 0.2 + § E STEP 3 ✓
- crawl4ai Apache-2.0 + Attribution clause ACKNOWLEDGED in D1 NOTICE attribution mandate ✓
- Dispatch-brief deviation acknowledgment ✓ (DD-1 + STEP 0.5 + RM6 — `packages/_shared/pdf/` location corrected to `packages/application/fundamental/` per parent plan-040 DD-1 canonical source precedence + VBW STEP 0.5 finding)
- Sub-plan size discipline (per dispatch brief: emulate plan-039 for sub-plan size discipline) ✓ — this sub-plan = ~720 LOC; plan-039 = ~720 LOC; equivalent envelope respected
- Phase F-prime CODE-DONE-DATA-PENDING attestation S386 90b27db acknowledged in § N.1 + N.4 (parallel-dispatch gate satisfied) ✓
- Plan-040 § N.2 sequencing followed ✓ (S392 = THIS plan; S394 IMPL = D1-D5 sub-track decomposition; S395 = verifier per AP-1 fresh-context)
- Phase 1 sub-plan FOCUSED_IMPL anti-pattern (Session 4 catastrophic mix) avoided — sub-plan 041 is PLAN-only; S394 IMPL is separate session ✓

---

**END OF SUB-PLAN 041-S392-PHASE-GPRIME-G1-PDF-LIBRARY-BAKEOFF-AND-PORT-ABC**

> Plan file ends at this line. Architect output complete. Main session reviews + commits + dispatches S394 sandwich-dev FOCUSED_IMPL per § N.2 sequencing.
