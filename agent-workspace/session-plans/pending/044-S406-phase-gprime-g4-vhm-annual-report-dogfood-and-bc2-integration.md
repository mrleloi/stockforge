---
plan_id: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
target_session: S407 (sandwich-dev FOCUSED_IMPL executing D1-D6; sub-plan author = sandwich-architect at S406; IMPL by sandwich-dev at S407; VERIFY by sandwich-verifier AP-1 at S408)
type: FOCUSED_IMPL (6 sub-tracks D1-D6; PLAN session this file; IMPL by sandwich-dev at S407; VERIFY by sandwich-verifier AP-1 at S408)
budget:
  - this PLAN session (S406 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (cold-start declared for task_class="pdf-dogfood-bc2-integration-plan"; nearest analogs = pdf-claude-vision-adapter-plan n=1 from S398 plan-043 ~150K Opus + pdf-extraction-plan n=1 from S392 plan-041 ~170K Opus + cli-dogfood-plan n=1 from S384 F.5 thesis-CLI ~120K Opus); OUTPUT-budget HARD CAP 64K per M-S405-1 prevention rule
  - sub-plan IMPL (S407 dev): ~100-150K Opus FOCUSED_IMPL per parent plan-040 § E.4 budget; CLI + integration smoke + dogfood-run shape; file-bounded (no novel external library)
  - sub-plan VERIFY (S408 verifier): ~80-180K Opus AP-1 fresh-context per recalibrated CLAUDE.md VERIFY-Opus column
phase: G-prime (Theme J — BC-2 Fundamental Data PDF + table extraction; sub-theme G.4 first VHM annual-report dogfood through G.3 ClaudeVisionPdfTableExtractor + EchoValidator gate + BC-2 SqliteFundamentalRepository persistence + ratio_service smoke; SEQUENTIAL POST-G.3 SHIP per parent plan-040 § N.2)
track: Wave 1 Theme J sub-theme G.4 — apps/cli/ingest_pdf_fundamentals.py CLI + VHM 2023/2024 annual-report end-to-end dogfood through ClaudeVisionPdfTableExtractor (D-082 ACCEPTED) → EchoValidator gate → deterministic cell-label→LineItemKey mapping + VND-string→Money parser → FinancialStatement construction → SqliteFundamentalRepository persistence → ratio_service smoke (6-ratio computation) → thesis_log artifact + 3+ integration-test assertions
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN § E.4 + § N.2; this is sub-plan #4 / final per Phase G-prime decomposition)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.5 + § 6.4.4
predecessor: 043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md (G.3 SHIPPED at S399 commits per current-execution.md; VERIFIED PASS at S400; D-082 ACCEPTED; G.3 adapter + EchoValidator COMPLETE + merge-eligible per agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md)
successor: S407 sandwich-dev FOCUSED_IMPL executing D1-D6 → S408 sandwich-verifier AP-1 (Phase G-prime CLOSE candidate at S408 close per parent plan-040 § H.3 CODE-READY-DATA-PARTIAL attestation discipline)
architect: S406 sandwich-architect (background; THIS plan, re-dispatch after S405 crashed at 64K output cap per M-S405-1)
dispatched_by: main session orchestrating Phase G-prime sub-plan 044 dispatch per parent plan-040 § N.2 sequencing + user authorization at S401 "ok, continue autonomous"
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED variant with COLD-START declared for task_class="pdf-dogfood-bc2-integration-plan"; nearest analogs as above; novel sub-components = end-to-end-dogfood-shape + per-adapter-cost-tracking + ratio-service-smoke-on-extracted-FS + thesis-log-artifact-template)
executing_agent: N/A this PLAN session; S407 sandwich-dev FOCUSED_IMPL + S408 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master plan-040 § E.4 sub-plan contract (G.4 VHM dogfood + BC-2 integration smoke; ~200-300 LOC CLI + thesis-log report + ADR D-083 + gold-set per parent plan § H.1 PG-DONE-5/6/7)"
  - "G.1 sub-plan 041 SHIPPED + VERIFIED (S394 dev + S397 verifier PASS; D-080 ACCEPTED) — PdfTableExtractorPort ABC + ExtractedFinancialStatement + PdfSource AVAILABLE at packages/application/fundamental/"
  - "G.3 sub-plan 043 SHIPPED + VERIFIED (S399 dev + S400 verifier PASS; D-082 ACCEPTED) — ClaudeVisionPdfTableExtractor + EchoValidator + Rule 16 mode #2 gate AVAILABLE at packages/infrastructure/fundamental/claude_vision_pdf_adapter.py + packages/application/fundamental/echo_validator.py"
  - "G.2 sub-plan 042 STATUS: BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision per parent plan-040 § J — G.4 USES G.3 ADAPTER ONLY (NOT G.2); G.2 may resume after G.4 closes phase per § N.2 + parent § E.2 PARALLEL-eligible note (G.4 NOT blocked by G.2)"
  - "BC-2 EXISTING SUBSTRATE (VBW-confirmed for this plan; cited file:line throughout § D):"
  - "  packages/domain/fundamental/models/financial_statement.py:42-88 (FinancialStatement aggregate + invariants Rule 1 / Rule 4 / Rule 5 / Rule 6 / I-S1; UNCHANGED this sub-plan)"
  - "  packages/domain/fundamental/value_objects/line_item.py:24-45 (LineItemKey 10 canonical keys; G.4 mapper normalizes raw_cells → these keys)"
  - "  packages/infrastructure/fundamental/sqlite_fundamental_repository.py:32-83 (SqliteFundamentalRepository.save_many + schema; UNCHANGED for V0 ADDITIVE-ONLY-default per DD-3)"
  - "  packages/domain/fundamental/services/ratio_service.py:1-60 (RatioService 6 ratios PE/PB/ROE/ROA/DEBT_EQUITY/NET_MARGIN; G.4 smoke runs all 6)"
  - "  packages/contracts/types/adjustment_type.py:36-51 (SourceProvider StrEnum: VNSTOCK/TCBS/FIINPRO/SSI/WICHART/MANUAL/SCRAPED_OTHER — G.4 uses SCRAPED_OTHER for PDF-extraction source provenance per DD-2)"
  - "D-080 ACCEPTED (PdfTableExtractorPort ABC; G.4 consumes via G.3 subclass)"
  - "D-082 ACCEPTED (ClaudeVisionPdfTableExtractor + EchoValidator + Rule 16 mode #2; G.4 consumes both)"
  - "D-050 CHARTER (anthropic_api_to_subagent MANDATORY — G.4 reuses G.3 adapter which uses claude_cli_transport; ZERO new import anthropic / ZERO ANTHROPIC_API_KEY)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz / R2 unseeded RNG / R4 time.time-in-domain BINDING for every NEW/MODIFIED file)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for S407 dev commit boundary)"
  - "D-062 (atomic-write-doctrine — applies to per-run cost-ledger writes via tmp+os.replace pattern)"
  - "D-064 (path-safety 5-invariant — BINDING for PDF inputs + SQLite output paths + thesis-log artifact path; PdfSource constructor already validates)"
  - "D-065 Rule 16 mode #2 (EchoValidator gate satisfies; G.4 mapper produces canonical Decimal from raw_cells per Rule 16 § C audit below)"
  - "D-067 (planner-upgrade ADR — Phase 1b mandate for ≥3 sub-tracks; this plan has 6 sub-tracks D1-D6 → Phase 1b CONSUMED MANDATORY)"
  - "Charter v1.1 Principle 1 (NO LLM math — G.4 uses G.3 EchoValidator gate; deterministic mapper produces Money) + Principle 2 (Every claim has source + as-of date — thesis-log artifact cites source_pdf_sha256 + extraction_method + extractor_version) + Principle 7 (Dogfood mandatory — G.4 IS the V0 dogfood per parent plan-040 § A.1) + Principle 8 (Calibration over confidence — per-adapter accuracy on gold-set + per-extraction cost; calibration_grade='D' V0 baseline)"
  - "I-S1 (NO LLM math) + I-S1-1 (Rule 16) — satisfied via G.3 EchoValidator gate + deterministic G.4 mapper + parser"
  - "I-S2 (citation discipline) — every ratio in smoke output cites source_pdf_url + page + as_of via inherited ExtractedFinancialStatement provenance"
  - "I-S20 (calibration over confidence) — per-adapter accuracy recorded in thesis-log; calibration_grade='D' V0 baseline"
  - "I-S22 (data lineage) — ExtractedFinancialStatement → FinancialStatement mapping preserves source_pdf_sha256 + extraction_method + extractor_version via thesis-log artifact + (DEFERRED per DD-3) ADDITIVE FinancialStatement fields"
  - "I-S34 (public sources only) — VHM PDF sourced from Vietstock public OR Vinhomes IR (already committed at tests/fixtures/pdf/vhm-2023-annual.pdf per G.1 fixture per dispatch brief Glob); NO paid leaks"
  - "I-S35 (research-aid framing) — thesis-log artifact uses 'thesis exploration' / 'consideration' framing per CLAUDE.md hard rule"
  - "L-S32-1 empirical-probe-first (STEP 0 cold-probe of full pipeline BEFORE D1 implementation per L-S395-1)"
  - "L-S389-1 wc -l exact-integer attestation"
  - "L-S389-2 ADR 12-field schema floor (D-083 ≥12 fields)"
  - "L-S392-1 dispatch-brief-drift prevention (every file path VBW-verified via Read/Glob/Grep BEFORE citing in DDs — DONE for this plan, see § D citations)"
  - "L-S395-1 full-pipeline cold-probe at STEP 0 (G.4 cold-probes Claude CLI vision + SQLite write end-to-end on synthetic input at STEP 0.4-0.5)"
  - "L-S397-1 per-category LOC ceilings (this plan distinguishes core-code vs test vs doc per § G)"
  - "L-S397-2 STOP-FINDING severity vocabulary (INFO/WARN/HIGH/CRITICAL/CHARTER-TIER-SURFACE/ALERT)"
  - "L-S397-3 close-loop file-existence verification (architect runs wc -l on output files before composing return summary)"
  - "L-S405-1 OUTPUT-budget HARD CAP at 64K Anthropic API per-message limit — this plan ≤700 LOC; observation ≤100 LOC; return summary ≤6K tokens"

binding_decisions:
  - "PHASE 1b CONSUMED + COLD-START DECLARED for task_class='pdf-dogfood-bc2-integration-plan' — directional confidence MEDIUM at n=1 per-analog × 3 analogs"
  - "G.4 USES G.3 ADAPTER ONLY (NOT G.2 winner-library adapter per RM3 BLOCK) — per parent plan-040 § E.2 G.2 BLOCKED state; G.4 ships V0 dogfood with G.3 single-adapter path; per-adapter comparison deferred to G.4-V2 OR Phase G-prime-V2 entry (revisit trigger: G.2 unblock at user authorization)"
  - "G.4 DOGFOOD = SINGLE-TICKER VHM (parent plan-040 § E.4 + DD-7 default; HPG/VIC/FPT alternatives DEFERRED per § B AP-7 named revisit trigger)"
  - "G.4 SCOPE = STATEMENT-TYPE = INCOME_STATEMENT (IS) ONLY for V0 — Balance Sheet + Cash Flow DEFERRED per § B AP-7 (revisit trigger: IS smoke PASS at G.4 CLOSE; BS+CF expansion at Phase G-prime-V2 OR Phase 2 entry); RATIONALE: 4 of 6 ratios (ROE/ROA/NET_MARGIN/PE) require NET_INCOME (IS); PE+EPS reads from IS; smoke is bounded; full multi-statement expansion is multi-call cost not justified V0"
  - "DD-3 schema-migration DECISION = ADDITIVE-ONLY-DEFAULT (per K.2.c CHARTER-TIER FLAG default at parent plan-040 § K.2.c) — ZERO FinancialStatement schema change V0; provenance preserved in ExtractedFinancialStatement intermediate dataclass + thesis-log artifact only; deferred to Phase 2 entry IF BC-9 Outer-Loop consumer needs schema fields"
  - "DD-2 SourceProvider = SCRAPED_OTHER for PDF-extraction (NOT VNSTOCK / NOT NEW enum value) — existing enum value SCRAPED_OTHER per packages/contracts/types/adjustment_type.py:51 docstring 'catches any new source pre-formal-add (audit-flagged)' EXACTLY matches G.4 use case; ZERO contracts/types change; rationale: PDF substrate is NOT yet a formal Phase 2 source per spec-T1-001"
  - "DD-4 EchoValidator gate is MANDATORY at every extraction (inherited from G.3 ClaudeVisionPdfTableExtractor.extract() — already invokes EchoValidator per packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:272-282) — G.4 CLI does NOT re-invoke EchoValidator; G.4 mapper consumes validated raw_cells from extracted_at-bearing ExtractedFinancialStatement"
  - "DD-5 cost-budget DEFAULT = $0.50 per extract (inherited from G.3 DD-6 per packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:173); G.4 CLI exposes --cost-ceiling-usd override flag; --total-budget-usd hard cap = $5.00 per VHM dogfood run (covers IS only V0; ~3-10 calls × ~$0.05-0.15 estimate)"
  - "DD-6 ADR D-083 PROPOSED-AT-IMPL records (a) G.4 CLI ingest_pdf_fundamentals.py + (b) mapping strategy (cell-label→LineItemKey via lookup table per vnstock_fundamental_adapter precedent) + (c) VHM dogfood outcome (per-cell accuracy on 10 canonical + IS-subset extracted vs gold) + (d) cost tracking + (e) schema-migration K.2.c decision (DEFAULT ADDITIVE-ONLY = NO MIGRATION V0) + (f) test path convention (tests/integration/ NEW or tests/unit/cli/ per DD-9 below); 12-field schema floor per L-S389-2"
  - "DD-7 thesis-log artifact location = agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md (parent plan-040 § E.4 D3); template = F.5 precedent agent-workspace/thesis-log/2026-05-17-VHM.md if exists; structure: ticker / as_of / extracted_cells / canonical_mapping / 6_ratios / cost_usd / extraction_method / extractor_version / source_pdf_sha256 / I-S35 disclaimer footer"
  - "DD-9 test path convention = NEW tests/integration/ directory tree (NOT tests/unit/ per L-S397-1 distinguish test categories; integration ≠ unit; G.3 introduced tests/unit/ at S399 per packages/application/fundamental/test_echo_validator.py — observation by Glob); rationale: G.4 smoke is multi-component integration (CLI + adapter + EchoValidator + mapper + repo + ratio_service) which is integration-test shape per pytest convention; AP-23 1st-instance HOLD on tests/integration/ convention; if 2nd sub-plan adopts → promote to template"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names prerequisites + revisit trigger"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (mapper-from-raw-cells-to-LineItemKey pattern + dogfood-CLI-with-LLM-cost-tracking pattern + tests/integration/ tree)"
  - "Karpathy P3 surgical-changes — per L-S397-1 per-category ceilings § G: CLI ≤300 LOC core + mapper ≤120 LOC core + integration tests ≤200 LOC + thesis-log artifact ≤150 LOC + ADR ≤200 LOC; total ~970 LOC across 5 NEW files (NO modification to existing G.1/G.3 files; NO modification to existing BC-2 substrate per DD-3 ADDITIVE-ONLY-DEFAULT)"
  - "Karpathy P2 simplicity — single-adapter (G.3 only) + single-ticker (VHM) + single-statement-type (IS) V0; no per-adapter comparison; no multi-statement expansion; ratio-smoke = ratio_service call only, no formula re-derivation"
  - "VBW protocol mandatory — S407 dev MUST READ existing packages/infrastructure/fundamental/claude_vision_pdf_adapter.py + packages/application/fundamental/echo_validator.py + packages/infrastructure/fundamental/sqlite_fundamental_repository.py + packages/domain/fundamental/models/financial_statement.py + packages/domain/fundamental/services/ratio_service.py + apps/cli/validate_thesis.py (F.5 CLI precedent) + apps/cli/ingest_fundamentals_vn30.py (BC-2 ingest CLI precedent) empirically NOT memory; cite file:line for every architectural claim"
  - "L-S392-1 dispatch-brief-drift prevention — every file path cited in DDs VBW-confirmed via Read/Glob/Grep at PLAN authoring; STEP 0 re-verification mandatory at S407 IMPL"
  - "L-S395-1 full-pipeline cold-probe at STEP 0 mandatory — S407 IMPL cold-probes Claude CLI vision dispatch via G.3 adapter on synthetic minimal-PDF + SQLite write on synthetic FinancialStatement BEFORE D1 begins; STOP-FINDING fires per L-S397-2 severity vocab if cold-probe FAILS"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (architect plans only; sandwich-architect tools: [Read, Glob, Grep, Write] per .claude/agents/sandwich-architect.md)"
  - "no commits in THIS PLAN session by architect (main session commits architect's plan output per D-060)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session"
  - "no modification to existing G.1/G.3 ACCEPTED ADRs (D-080+D-081+D-082); G.4 introduces NEW D-083 PROPOSED-AT-IMPL"
  - "no modification to existing parent plan-040 (PHASE-MASTER-PLAN frozen at S391 commit)"
  - "no modification to existing FinancialStatement domain schema (DD-3 ADDITIVE-ONLY-DEFAULT applies; ZERO migration V0)"
  - "no new pyproject.toml dep additions (per DD-9 below — G.4 reuses click + existing Python stdlib + G.3 adapter + ratio_service stack)"
  - "ZERO import anthropic in any G.4 file (per D-050 CHARTER; G.4 reuses G.3 claude_cli_transport substrate transitively; verifier grep-asserts at V3)"
  - "every plan claim cites source file:line (per I-S2 + VBW)"
  - "OUTPUT-budget HARD CAP 64K Anthropic API per-message (per M-S405-1 prevention; this plan ≤700 LOC + observation ≤100 LOC + return summary ≤6K tokens)"
---

# S406 — Phase G-prime G.4 VHM Annual-Report Dogfood + BC-2 SqliteFundamentalRepository Integration Smoke (FOCUSED_IMPL plan)

> **One-sentence intent**: Ship `apps/cli/ingest_pdf_fundamentals.py` CLI that drives VHM 2023 annual-report PDF (existing fixture `tests/fixtures/pdf/vhm-2023-annual.pdf`) through G.3 `ClaudeVisionPdfTableExtractor` + `EchoValidator` gate → deterministic cell-label→`LineItemKey` mapper + VND-string→`Money` parser → `FinancialStatement` construction → `SqliteFundamentalRepository.save_many` persistence → `RatioService` smoke (NET_MARGIN+ROE+ROA+PE on Income Statement subset) → `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` artifact + integration tests with ≥3 assertions — with **G.2 BLOCKED** per RM3 (G.4 ships single-adapter G.3-only V0), **IS-only V0 scope** (BS+CF deferred per AP-7), **ADDITIVE-ONLY-DEFAULT** schema posture (DD-3 → NO migration V0), and **D-050 CHARTER preserved** (ZERO new `import anthropic`; G.4 reuses G.3 `claude_cli_transport` substrate transitively).

---

## A. Scope (IN-scope this sub-plan ships)

Per parent plan-040 § E.4 + DD-7 + this sub-plan's G.3-single-adapter binding:

1. **NEW `apps/cli/ingest_pdf_fundamentals.py`** — click CLI with flags `--ticker` (default VHM), `--pdf-path` (default `tests/fixtures/pdf/vhm-2023-annual.pdf`), `--statement-type` (default IS), `--adapter` (default claude-vision; only option V0), `--cost-ceiling-usd` (default 0.50), `--total-budget-usd` (default 5.00), `--db` (default `data/stockforge.sqlite`), `--output-dir` (default `agent-workspace/thesis-log/`), `--filing-date` (REQUIRED — Rule 1 invariant), `--period-end` (REQUIRED), `--source-url` (REQUIRED for PdfSource). Pattern reference: `apps/cli/validate_thesis.py:56-100` (click option shape).
2. **NEW `apps/cli/_pdf_cell_mapper.py`** — module-level mapping table `_PDF_CELL_MAP: dict[str, LineItemKey]` (bilingual VN+EN; ≥3 variants per LineItemKey for VHM-IS subset = REVENUE / GROSS_PROFIT / NET_INCOME / EPS) + `map_extracted_to_financial_statement(ExtractedFinancialStatement, ticker, filing_date, sector=None) → FinancialStatement` pure function (deterministic; raises `PdfMapperError` on missing required cells; partial-success OK if optional cells absent). Pattern reference: `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py:54-80` `_VNSTOCK_LINE_ITEM_MAP`.
3. **NEW `apps/cli/_vnd_money_parser.py`** — module-level `parse_vnd_to_money(raw: str, currency=Currency.VND) → Money` pure function (delegates parsing to existing `EchoValidator._canonicalize_numeric_string` per packages/application/fundamental/echo_validator.py:78-157 — DRY reuse, no duplication); raises `VndParserError` on unparseable. Pattern: G.3 adapter already uses `_canonicalize_numeric_string` per claude_vision_pdf_adapter.py:400-403.
4. **NEW `tests/integration/test_ingest_pdf_fundamentals_smoke.py`** — pytest integration tests (≥3 assertions per dispatch brief § G): (a) CLI invokes via click.testing.CliRunner with mocked claude_cli_transport returning canned IS cells → asserts SQLite contains 1 FinancialStatement row for VHM with NET_INCOME line item; (b) mapper produces valid FinancialStatement that satisfies Rule 1 + Rule 6 invariants (passes `__post_init__`); (c) ratio_service.compute_net_margin on extracted FS returns valid Ratio (Decimal, no ZeroDivisionError); (d) EchoValidator gate IS invoked transitively (mocked claude returns echo-valid cells → no EchoValidationError raised); (e) cost_ceiling_usd ENFORCED — invocation with --cost-ceiling-usd=0.01 raises CostBudgetExceeded.
5. **NEW `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md`** — V0 dogfood artifact (~120-150 LOC template; populated by S407 dev with actual run output IF live-LLM dogfood proceeds, OR canned-output IF mocked-only smoke per dispatch budget); structure per DD-7.
6. **NEW `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md`** — ADR D-083 PROPOSED-AT-IMPL per parent plan-040 § DD-8 (12-field schema floor per L-S389-2; records mapper strategy + cost-tracking + K.2.c default + dogfood outcome).

---

## B. Out-of-scope (DEFERRED per AP-7 named revisit triggers)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| G.2 pure-Python adapter (pdfplumber+camelot OR docling) participation in dogfood | BLOCKED per RM3 STOP-FINDING-S394 real-PDF provision (per parent plan-040 § J); G.4 ships G.3-single-adapter V0 | Trigger: G.2 unblock at user authorization + pdfplumber dep ratification → G.4-V2 PLAN session for per-adapter comparison |
| Balance Sheet (BS) + Cash Flow (CF) statement-types | Single-statement-IS V0 keeps scope bounded; 4 of 6 ratios need IS (NET_INCOME/REVENUE/EPS); cost-bounded | Trigger: G.4 IS smoke PASS at S408 close → BS+CF expansion at Phase G-prime-V2 OR Phase 2 entry; per-extract cost ~3x V0 |
| HPG / VIC / FPT ticker expansion | Single-ticker VHM V0 per DD-7 parent default; gold-set HAS hpg-2023-annual.pdf fixture (per Glob tests/fixtures/pdf/) | Trigger: VHM dogfood PASS → multi-ticker batch at Phase 2 entry; reuse same CLI |
| Vietnamese OCR (tesseract+vie.traineddata) for scanned PDFs | Parent plan-040 § K.2.b RESOLVED Resolution B (@<path> in user_message) per D-082 — Claude vision reads PDFs directly; no separate OCR substrate needed V0 | Trigger: scanned-PDF surface fails Claude vision accuracy → tesseract fallback at G.3-V2 |
| New pyproject.toml deps | G.4 reuses click (already in deps per pyproject.toml) + Python stdlib + existing G.3 adapter + ratio_service stack | Trigger: G.2 unblock surfaces pdfplumber dep → coordinated via G.2 sub-plan 042 IMPL |
| FinancialStatement schema migration (additive provenance fields) | DD-3 K.2.c CHARTER-TIER FLAG default = ADDITIVE-ONLY-DEFAULT = ZERO MIGRATION V0; provenance preserved in ExtractedFinancialStatement intermediate dataclass + thesis-log artifact | Trigger: BC-9 Outer-Loop thesis-pipeline consumer requires source_pdf_url/page in citation surface → Phase 2 entry ADDITIVE migration |
| Per-adapter calibration database (gold-set hit-rate tracking) | Phase G-prime CODE-READY-DATA-PARTIAL ceiling V0 per parent plan-040 § H.3; calibration_grade='D' baseline | Trigger: n≥20 extracted FS records + Charter Principle 8 calibration regime entry |
| Live-LLM dogfood execution (real Claude vision call) | OPTIONAL per dispatch budget — S407 dev may run mocked-only smoke IF live-LLM token cost not authorized; canned-output thesis-log template still ships | Trigger: user authorization for live-LLM cost OR G.4-V2 entry with calibration regime |
| Multi-call statement-type strategy (separate Claude calls for IS/BS/CF) | Single-call V0 per DD-5 cost-budget; multi-call = 3x cost | Trigger: BS+CF expansion entry (above) |
| AskUserQuestion gate firing for K.2.c | NON-BLOCKING per parent plan-040 § K.4 — architect-recommended default (ADDITIVE-ONLY) applies; main session reviews IMPL output | Trigger: G.4 IMPL surfaces empirical evidence that ADDITIVE-ONLY insufficient |

---

## C. STEP 0 — VBW Live Verification (5 sub-steps; S407 IMPL re-runs at session entry)

### Sub-step 0.1 — G.3 contract VBW (READ packages/application/fundamental/pdf_table_extractor_port.py + extracted_financial_statement.py + pdf_source.py + echo_validator.py; CONFIRM signatures unchanged since D-080+D-082 ACCEPTED)
- Verify: `PdfTableExtractorPort.extract(pdf_source: PdfSource) → ExtractedFinancialStatement` ABC contract at pdf_table_extractor_port.py:134
- Verify: `ClaudeVisionPdfTableExtractor.__init__(*, cost_ceiling_usd: Decimal = Decimal("0.50"), model: str = "claude-sonnet-4-6")` ctor at claude_vision_pdf_adapter.py:170-187
- Verify: `EchoValidator.validate(llm_value, deterministic_value, *, cell_label)` classmethod at echo_validator.py:172-179
- Verify: `ExtractedFinancialStatement.raw_cells: Mapping[str, str]` field at extracted_financial_statement.py:69
- STOP-FINDING (CHARTER-TIER-SURFACE if signature drifted; HIGH otherwise; INFO if unchanged)

### Sub-step 0.2 — SQLite repo VBW (READ packages/infrastructure/fundamental/sqlite_fundamental_repository.py:32-49 schema + :67-83 save_many)
- Verify: schema columns = `ticker, statement_type, period_end, filing_date, ingested_at, line_items_json, currency, source_provider, sector, restated_at, fiscal_period_label` (11 cols)
- Verify: `save_many(statements: Iterable[FinancialStatement]) → int` signature unchanged
- Confirm: NO migration needed per DD-3 ADDITIVE-ONLY-DEFAULT; existing schema accepts G.4-mapped FinancialStatement as-is

### Sub-step 0.3 — FinancialStatement aggregate VBW (READ packages/domain/fundamental/models/financial_statement.py:42-88)
- Verify: 9 required fields + 3 optional (sector, restated_at, fiscal_period_label) per :52-61
- Verify: `__post_init__` invariants at :63-88 — Rule 1 (filing_date ≥ period_end + ingested_at ≥ filing_date) + Rule 6 (line_items non-empty) + Rule 5 (single-currency) + I-S6
- G.4 mapper MUST populate ALL 9 required fields including SourceProvider.SCRAPED_OTHER per DD-2

### Sub-step 0.4 — Claude CLI vision COLD-PROBE on synthetic minimal-PDF (full-pipeline per L-S395-1)
- S407 dev creates `tests/fixtures/pdf/_synthetic_smoke.pdf` (1-page text-based PDF with single cell "Doanh thu thuần: 1.234.567" if not exists)
- Invoke `ClaudeVisionPdfTableExtractor(cost_ceiling_usd=Decimal("0.10")).extract(PdfSource(...))` against synthetic PDF
- Expected outcome: SUCCESS → returns ExtractedFinancialStatement with raw_cells containing at least 1 entry; PROBE outcome JSON written to `agent-workspace/memory/observations/sandwich-dev-S407-step0-cold-probe.md`
- STOP-FINDING (CHARTER-TIER-SURFACE if claude CLI vision-input broken; HIGH if cost-budget exceeded on minimal PDF; INFO if clean)
- IF probe fails → S407 dev writes STOP-FINDING via `human-workspace/notifications/_STOP-FINDING-template.md` scaffold; HALT IMPL pending main session ratification per PCG-S401-3

### Sub-step 0.5 — SQLite write COLD-PROBE on synthetic FinancialStatement (full-pipeline per L-S395-1)
- S407 dev constructs minimal FinancialStatement (1 line_item REVENUE=1234567 VND, ticker=VHM, IS, period_end=date(2023,12,31), filing_date=date(2024,3,31), ingested_at=now(UTC), source_provider=SCRAPED_OTHER) → invariants pass
- `repo = SqliteFundamentalRepository(db_path=Path("data/.smoke_probe.sqlite")); repo.save_many([fs])` returns 1
- `repo.get_latest(Ticker("VHM"))` returns the FinancialStatement (round-trip integrity verified)
- Outcome JSON written to same cold-probe observation file
- STOP-FINDING (HIGH if round-trip fails; INFO if clean)

---

## D. Architecture Decisions (DDs)

### DD-1: Single-adapter G.3-only V0 (NOT per-adapter comparison)

**Decision**: G.4 CLI hard-codes `adapter="claude-vision"` choice; NO `--adapter pdfplumber` path V0.

**Rationale**: G.2 BLOCKED per RM3 STOP-FINDING-S394 (parent plan-040 § J). Per-adapter comparison requires both adapters live. V0 ships single-path dogfood; comparison deferred to G.4-V2 entry. Karpathy P2 simplicity — single-path bounded scope.

**Alternative considered**: --adapter flag with NotImplementedError on pdfplumber → REJECTED (CLI surface clutter without G.2 substrate).

### DD-2: SourceProvider = SCRAPED_OTHER for PDF-extraction source provenance

**Decision**: G.4 mapper sets `FinancialStatement.source_provider = SourceProvider.SCRAPED_OTHER` per packages/contracts/types/adjustment_type.py:51.

**Rationale**: Existing enum docstring explicitly states `SCRAPED_OTHER` "catches any new source pre-formal-add (audit-flagged)". PDF substrate is NOT yet a formal Phase 2 source per spec-T1-001. ZERO contracts/types change. Audit-flagged downstream (BC-9 thesis-pipeline can detect SCRAPED_OTHER and apply citation discipline).

**Alternative considered**: NEW SourceProvider.PDF enum value → REJECTED (contracts/types change requires cross-BC review; SCRAPED_OTHER suffices).

### DD-3: ADDITIVE-ONLY-DEFAULT schema posture (K.2.c CHARTER-TIER FLAG NOT-FIRED V0)

**Decision**: ZERO `FinancialStatement` schema migration V0. Provenance preserved in `ExtractedFinancialStatement` intermediate dataclass + `thesis-log/2026-05-G4-VHM-fundamentals.md` artifact.

**Rationale**: Per parent plan-040 § K.2.c default + Karpathy P3 surgical-changes. Domain entity stays clean. Backward compat preserved (vnstock adapter unaffected). BC-9 thesis-pipeline consumer can read provenance from observation/thesis-log artifacts V0; schema fields ADDITIVE migration deferred to Phase 2 entry IF downstream demand surfaces.

**Alternative considered**: ADDITIVE migration with default=None for new fields (source_pdf_url, source_pdf_page, source_pdf_sha256, extraction_method, extractor_version, extracted_at) → DEFERRED (V2 work; K.2.c CHARTER-TIER FLAG can still fire at Phase 2 entry).

### DD-4: Cell-label→LineItemKey mapper at apps/cli/_pdf_cell_mapper.py (NOT in adapter)

**Decision**: G.4 mapper is APPLICATION-layer pure function at `apps/cli/_pdf_cell_mapper.py`, NOT inside G.3 adapter. Adapter returns raw_cells; mapper normalizes downstream.

**Rationale**: Per parent plan-040 § DD-2 — ExtractedFinancialStatement is intermediate dataclass; mapper is shared application-layer logic; G.2 (when unblocked) reuses same mapper. Per Karpathy P3 + DDD Port+Adapter — adapters extract raw, application maps to domain. Apps-layer placement (NOT packages/application/fundamental/) reflects V0 CLI-driven mapping; if 2nd CLI surfaces, promote to packages/application/fundamental/pdf_mapper.py per AP-23.

**Alternative considered**: Mapper inside G.3 adapter → REJECTED (couples mapper to adapter; G.2-future can't reuse; violates DD-2 ExtractedFinancialStatement intent).

### DD-5: VND-string→Money parser DELEGATES to EchoValidator._canonicalize_numeric_string (DRY reuse)

**Decision**: `apps/cli/_vnd_money_parser.parse_vnd_to_money(raw, currency=VND)` calls `packages/application/fundamental/echo_validator._canonicalize_numeric_string(raw)` returning Decimal, then wraps in Money(amount=Decimal, currency=VND).

**Rationale**: G.3 adapter already uses `_canonicalize_numeric_string` per packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:400-403 (Vietnamese locale + parentheses-negative + Triệu/Tỷ-đồng suffix handling proven). DRY reuse avoids duplicating canonicalization logic. Karpathy P2 simplicity — ONE canonical parser, not two.

**Alternative considered**: Standalone parser in apps/cli/ → REJECTED (duplication; risk of divergent canonicalization across G.3 EchoValidator and G.4 parser).

### DD-6: Cost-budget tracking via G.3 adapter.call_records (NO separate ledger V0)

**Decision**: G.4 CLI reads `adapter.call_records` (list of `_CallRecord(cells_extracted, input_tokens, output_tokens, cost_usd, wall_ms)`) per packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:136-145 + :322-325 read-only property; aggregates `sum(r.cost_usd for r in adapter.call_records)` for thesis-log artifact total cost; --total-budget-usd hard cap raises CostBudgetExceeded BEFORE invoking extract() if pre-flight cost ceiling exceeded budget.

**Rationale**: G.3 already tracks per-call cost. NO separate ledger file V0 (atomic-write per D-062 deferred to Phase 2 IF persistent cost-ledger needed). Karpathy P2 — reuse existing adapter telemetry.

### DD-7: ADR D-083 PROPOSED-AT-IMPL records dogfood outcome

**Decision**: S407 dev creates `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md` PROPOSED at IMPL with ≥12-field frontmatter per L-S389-2. Records: (a) mapper strategy + DD-2 SourceProvider choice + DD-3 NO-MIGRATION K.2.c default + (b) cost-tracking + (c) per-cell accuracy on 10 canonical (or IS-subset) extracted vs gold (if live-LLM ran) or canned (if mocked-only smoke) + (d) test path convention DD-9 (tests/integration/ NEW directory) + (e) K.2.c CHARTER-TIER FLAG status (NOT-FIRED per ADDITIVE-ONLY-DEFAULT).

**Rationale**: Per parent plan-040 § DD-8 — IMPL-tier ADRs auto-ratify on session close commit per severity-schema. AP-23 1st-instance HOLD: mapper-table pattern + dogfood-CLI pattern + tests/integration/ tree all 1st-instance V0; D-083 records the 1st-instance and PCG-1 (mapper-table) gets promote-candidate flag for G.4-V2 close.

---

## E. Sub-tracks (D1-D6)

### E.1 D1 — NEW apps/cli/_vnd_money_parser.py (≤30 LOC core)
- File: `apps/cli/_vnd_money_parser.py`
- Public API: `parse_vnd_to_money(raw: str, currency: Currency = Currency.VND) → Money` + `class VndParserError(ValueError)`
- Implementation: import `_canonicalize_numeric_string` from packages.application.fundamental.echo_validator; call it; wrap Decimal in Money; raise VndParserError on ValueError
- Dependencies: packages.contracts (Currency, Money), packages.application.fundamental.echo_validator
- DoD: mypy --strict + ruff clean; standalone unit test in tests/integration/test_ingest_pdf_fundamentals_smoke.py exercises parser via mapper indirection

### E.2 D2 — NEW apps/cli/_pdf_cell_mapper.py (≤120 LOC core)
- File: `apps/cli/_pdf_cell_mapper.py`
- Public API: `_PDF_CELL_MAP: dict[str, LineItemKey]` (≥3 VN + ≥3 EN variants per IS-subset LineItemKey: REVENUE / GROSS_PROFIT / NET_INCOME / EPS) + `map_extracted_to_financial_statement(extracted: ExtractedFinancialStatement, ticker: Ticker, filing_date: date, sector: str | None = None) → FinancialStatement` + `class PdfMapperError(ValueError)` + `class RequiredCellMissingError(PdfMapperError)`
- Implementation: iterate extracted.raw_cells; lookup in _PDF_CELL_MAP (case-insensitive normalization); skip non-canonical cells; for each canonical cell call parse_vnd_to_money; populate dict[str, Money]; require NET_INCOME present for IS (per ratio_service NET_MARGIN/ROE/ROA dependencies per packages/domain/fundamental/value_objects/line_item.py:56-63); construct FinancialStatement with SourceProvider.SCRAPED_OTHER per DD-2; ingested_at = datetime.now(UTC); fiscal_period_label = "" (default per FinancialStatement field default at financial_statement.py:61)
- Dependencies: D1 parser + packages.application.fundamental (ExtractedFinancialStatement) + packages.contracts (Ticker, Money) + packages.domain.fundamental.models (FinancialStatement) + packages.domain.fundamental.value_objects (LineItemKey, StatementType)
- DoD: mypy --strict + ruff clean

### E.3 D3 — NEW apps/cli/ingest_pdf_fundamentals.py (≤300 LOC core)
- File: `apps/cli/ingest_pdf_fundamentals.py`
- Pattern reference: apps/cli/validate_thesis.py:56-100 (click option shape) + apps/cli/ingest_fundamentals_vn30.py:47-86 (BC-2 ingest CLI shape with --output SQLite + summary)
- CLI flags per § A item 1 (12 click.option)
- Flow: parse args → construct PdfSource (per Rule 1 validation; PdfSource.__post_init__ enforces D-064 + url + dates) → instantiate ClaudeVisionPdfTableExtractor(cost_ceiling_usd) → extract(pdf_source) → map via D2 mapper → SqliteFundamentalRepository(db_path).save_many([fs]) → ratio_service.compute_net_margin + compute_roe + compute_roa (3 ratios for IS subset; PB+PE require BVPS+market-price NOT in scope V0) → write thesis-log artifact (D4) with metadata + cost + ratios + I-S35 disclaimer footer per validate_thesis.py:46-53 precedent
- Error handling: CostBudgetExceeded → exit 1 (mirror validate_thesis.py:8); EchoValidationError → exit 2 (HARD ERROR per Rule 16 mode #2); PdfMapperError → exit 3; VisionExtractionError → exit 4
- Exit codes 0=success / 1-4=specific errors per validate_thesis.py:7-11 precedent
- Dependencies: D1 parser + D2 mapper + click + Python stdlib + packages.application.fundamental + packages.infrastructure.fundamental (SqliteFundamentalRepository + claude_vision_pdf_adapter via __init__ export — Sub-step 0.1 verifies __init__ may need ADD of ClaudeVisionPdfTableExtractor to packages.infrastructure.fundamental.__init__ per Read confirmed CURRENT export is only Sqlite+Vnstock; G.4 IMPL D3 includes ADDITIVE-ONLY append to __init__.py __all__ list)
- DoD: mypy --strict + ruff clean; manual smoke `python apps/cli/ingest_pdf_fundamentals.py --help` returns usage

### E.4 D4 — NEW agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md (≤150 LOC artifact, NOT code)
- Template structure per DD-7:
  - YAML frontmatter: ticker / as_of / source_pdf_sha256 / extraction_method (claude-vision v0.1.0) / extractor_version / total_cost_usd / cells_extracted / canonical_keys_present
  - Body: § 1 Provenance (PDF URL + page subset + filing/period dates) + § 2 Extracted Canonical Cells (REVENUE, GROSS_PROFIT, NET_INCOME, EPS — Money values + raw strings) + § 3 Computed Ratios (NET_MARGIN + ROE + ROA per ratio_service.formula_audit citations per ratio_service.py:48-60) + § 4 Cost Breakdown (per-call list from adapter.call_records) + § 5 EchoValidator Pass-Rate (cells_validated / cells_total) + § 6 I-S35 disclaimer footer (verbatim from validate_thesis.py:46-53)
- POPULATE strategy: IF S407 dev runs live-LLM dogfood → actual values; IF mocked-only smoke → canned-template values with `<populated-at-live-LLM-run>` placeholders + status: TEMPLATE-V0
- DoD: file exists at agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md; wc -l ≥120 LOC

### E.5 D5 — NEW tests/integration/test_ingest_pdf_fundamentals_smoke.py (≤200 LOC tests)
- pytest integration tests per § A item 4; ≥5 assertions per dispatch brief § G "≥3 integration assertions" (this exceeds with margin)
- Mock strategy: monkeypatch packages.infrastructure.analysis.subagent_transport.claude_cli_transport to return canned JSON `{"cells": {"Doanh thu thuần": "1.000.000", "Lợi nhuận sau thuế": "500.000", "Lợi nhuận gộp": "700.000", "EPS": "1.500"}}` per packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:85-96 _SYSTEM_PROMPT shape
- Tests:
  - test_cli_smoke_persists_financial_statement: invoke CLI via CliRunner with --pdf-path=existing fixture; assert SQLite contains 1 row for VHM IS
  - test_mapper_satisfies_financial_statement_invariants: instantiate ExtractedFinancialStatement (synthetic) → call mapper → assert returned FinancialStatement passes __post_init__
  - test_ratio_service_computes_net_margin_on_extracted: extracted FS → ratio_service.compute_net_margin → returns Ratio(Decimal, RatioName.NET_MARGIN)
  - test_echo_validator_gate_invoked_transitively: assert no EchoValidationError when raw_cells echo-valid; assert EchoValidationError raised when canned mismatch (e.g. LLM returns "9.999.999" but synthetic gold = "1.000.000")
  - test_cost_ceiling_enforced: invoke CLI with --cost-ceiling-usd=0.001 → exit code 1 (CostBudgetExceeded)
- Test path: tests/integration/test_ingest_pdf_fundamentals_smoke.py + tests/integration/__init__.py + tests/integration/cli/__init__.py (NEW tree per DD-9; if 2nd sub-plan adopts, promote to convention)
- DoD: pytest tests/integration/ green; 5/5 assertions PASS

### E.6 D6 — NEW agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md (≤200 LOC ADR)
- ADR D-083 PROPOSED-AT-IMPL per DD-7
- 12-field frontmatter per L-S389-2: id / title / status / severity / date / phase / sub_track / session / authored_by / depends_on / supersedes / superseded_by / revisit_trigger (≥13 fields = floor met)
- Body sections: Context / Decision (DD-1 thru DD-7 verbatim referenced) / Rule 16 mode #2 satisfaction proof (mapper-input = EchoValidator-validated raw_cells; mapper-output = canonical Decimal via _canonicalize_numeric_string; NO LLM math) / Consequences / Alternatives Considered / Source Evidence Chain (≥6 cites per D-082 precedent at decisions/082-*.md:200-211)
- Dependencies: D-080 + D-082 + D-050 + D-059 + D-064 + D-065
- DoD: file exists; wc -l ≥150 LOC; frontmatter 13 fields

---

## F. File scope BINDING (S407 dev touches ONLY these paths)

**NEW files (6)**:
1. `apps/cli/_vnd_money_parser.py`
2. `apps/cli/_pdf_cell_mapper.py`
3. `apps/cli/ingest_pdf_fundamentals.py`
4. `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md`
5. `tests/integration/test_ingest_pdf_fundamentals_smoke.py` (+ `tests/integration/__init__.py` + `tests/integration/cli/__init__.py` scaffolding ≤5 LOC each)
6. `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md`

**MODIFIED files (1 — ADDITIVE-ONLY)**:
1. `packages/infrastructure/fundamental/__init__.py` — APPEND `ClaudeVisionPdfTableExtractor` to imports + `__all__` (current state per Read: only Sqlite+Vnstock exported; G.4 needs ClaudeVisionPdfTableExtractor importable from package root); ≤5 LOC delta

**OUT of scope (S407 dev MUST NOT touch)**:
- ANY file under `packages/domain/**` (FinancialStatement schema FROZEN per DD-3)
- ANY file under `packages/application/fundamental/**` (G.1+G.3 ABCs FROZEN per D-080+D-082 ACCEPTED)
- `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (G.3 adapter FROZEN per D-082)
- `packages/infrastructure/fundamental/sqlite_fundamental_repository.py` (schema FROZEN per DD-3)
- `packages/contracts/**` (SourceProvider enum FROZEN per DD-2 — SCRAPED_OTHER existing value)
- `pyproject.toml` (NO new deps per DD-9 binding_decision above)
- `agent-workspace/constitution/**` (CHARTER immutable)
- `PROJECT_CHARTER.md` (immutable)
- Any existing G.1/G.3 ADR files (decisions/080-* + decisions/082-* FROZEN)
- Any existing plan files (040-046 completed/in-flight per dispatch brief)

---

## G. DoD per L-S397-1 per-category LOC ceilings + smoke-test PASS criteria

### G.1 Per-category LOC ceilings (BINDING; per L-S397-1)

| Category | File(s) | Ceiling | Rationale |
|---|---|---|---|
| Core production code | _vnd_money_parser.py + _pdf_cell_mapper.py + ingest_pdf_fundamentals.py + __init__.py delta | ≤500 LOC | Karpathy P3 surgical-changes; CLI=300 + mapper=120 + parser=30 + init=5 = ~455 |
| Integration tests | tests/integration/test_ingest_pdf_fundamentals_smoke.py + __init__ scaffolds | ≤200 LOC | 5 test cases × ~30 LOC avg + scaffolds |
| Documentation/artifact | thesis-log/2026-05-G4-VHM-fundamentals.md | ≤150 LOC | TEMPLATE-V0 or live-output |
| ADR | decisions/083-*.md | ≤200 LOC | 12+ frontmatter fields + 6 body sections per D-082 precedent |
| TOTAL | ALL above | ≤1050 LOC | Reasonable for 6-deliverable dogfood IMPL |

### G.2 Smoke-test PASS criteria (per parent plan-040 § H.1 PG-DONE-5/6)

- **PASS-1**: `python apps/cli/ingest_pdf_fundamentals.py --help` returns usage (CLI loads without ImportError)
- **PASS-2**: `pytest tests/integration/test_ingest_pdf_fundamentals_smoke.py` returns 5/5 PASS
- **PASS-3**: mypy --strict on all NEW files + MODIFIED __init__ returns 0 errors
- **PASS-4**: ruff check + ruff format on all NEW files returns 0 violations
- **PASS-5**: `Grep "import anthropic" apps/cli/ tests/integration/` returns 0 matches (D-050 CHARTER preserved)
- **PASS-6**: STEP 0.4 + 0.5 cold-probes return SUCCESS (or STOP-FINDING fires per L-S397-2 vocab)
- **PASS-7**: Thesis-log artifact file exists at `agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md` with ≥120 LOC
- **PASS-8**: ADR D-083 file exists at `agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md` with ≥150 LOC + 13 frontmatter fields
- **PASS-9 (OPTIONAL, only if live-LLM dogfood ran)**: ≥3 of 4 IS-subset canonical cells (REVENUE/NET_INCOME/EPS — GROSS_PROFIT optional) extracted from VHM 2023 PDF; ≥1 ratio computed without ZeroDivisionError

### G.3 Integration-test assertion floor (per dispatch brief § G "≥3 integration assertions")
- ≥3 distinct assertion clusters required; this plan ships 5 test functions covering 5 distinct concerns (persist / invariants / ratio / echo-gate / cost-ceiling) → assertion floor EXCEEDED with margin

---

## H. Risks + Mitigations (RM-G4-1 through RM-G4-5)

### RM-G4-1: Claude CLI vision-input regression (D-082 Resolution B broken)
- **Likelihood**: LOW (D-082 STEP 0.4 confirmed empirically at S399 commit; vision substrate stable)
- **Impact**: HIGH (G.4 dogfood blocked end-to-end)
- **Mitigation**: STEP 0.4 cold-probe at S407 IMPL re-confirms Resolution B on synthetic minimal-PDF BEFORE D1 begins; STOP-FINDING fires per L-S397-2 vocab (CHARTER-TIER-SURFACE severity) if probe FAILS; HALT pending main session ratification

### RM-G4-2: VHM PDF gold-set fixture missing OR corrupted
- **Likelihood**: LOW (per dispatch brief Glob: tests/fixtures/pdf/vhm-2023-annual.pdf + SHA256.txt + expected_cells_vhm.json all confirmed exist)
- **Impact**: MEDIUM (mocked-only smoke can proceed; live-LLM dogfood requires fixture)
- **Mitigation**: STEP 0 verifies fixture SHA256 matches manifest; if mismatch → use canned-output thesis-log + mocked-only smoke V0; live-LLM dogfood deferred to next session

### RM-G4-3: VHM cell-label normalization drift (real VHM PDF uses unexpected Vietnamese label)
- **Likelihood**: MEDIUM (per parent plan-040 RM-G-6 — "Doanh thu thuần" vs "Doanh thu bán hàng" granularity drift)
- **Impact**: MEDIUM (mapper returns partial FinancialStatement; ratio computation fails if NET_INCOME absent)
- **Mitigation**: D2 mapper includes ≥3 Vietnamese variants per LineItemKey for IS subset; mapper raises RequiredCellMissingError on NET_INCOME absent (HARD ERROR with diagnostic label-list); thesis-log artifact records which labels were SEEN-BUT-UNMAPPED for V0 → V1 label-table expansion

### RM-G4-4: Live-LLM cost exceeds --total-budget-usd hard cap
- **Likelihood**: MEDIUM (VHM annual report 80-150 pages; Claude vision per-call cost ~$0.05-0.15 estimate per DD-5)
- **Impact**: LOW (CostBudgetExceeded raises cleanly per G.3 adapter; CLI exits 1 with partial cost report)
- **Mitigation**: --cost-ceiling-usd=$0.50 per call (G.3 default per DD-6) + --total-budget-usd=$5.00 hard cap; thesis-log records actual cost; G.4-V2 entry can raise budget if user authorizes

### RM-G4-5: SqliteFundamentalRepository round-trip integrity break (FinancialStatement de-ser mismatch)
- **Likelihood**: LOW (existing repository proven for vnstock adapter at apps/cli/ingest_fundamentals_vn30.py:86 production use)
- **Impact**: HIGH (data corruption silent)
- **Mitigation**: STEP 0.5 cold-probe verifies round-trip on synthetic FinancialStatement BEFORE D1; D5 test test_cli_smoke_persists_financial_statement asserts SQLite contains expected row post-CLI

---

## J. K.X charter-tier-surface flags (per parent plan-040 § K)

- **K.2.a** (pymupdf AGPL escalation OR no-clear-winner pivot): NOT-APPLICABLE this sub-plan (G.4 uses G.3 ONLY; G.1 winner-pick is G.2 territory)
- **K.2.b** (Claude CLI vision-input feasibility): NOT-FIRED — RESOLVED at S399 D-082 STEP 0.4 Resolution B confirmed empirically (claude CLI 2.1.140 reads PDFs via @<path> syntax in user_message); G.4 STEP 0.4 cold-probe RE-CONFIRMS at S407 IMPL entry
- **K.2.c** (FinancialStatement schema migration for provenance fields): DEFAULT ADDITIVE-ONLY = NO MIGRATION V0 per DD-3 — NON-BLOCKING; main session ratification path = review S407 IMPL output (NOT AskUserQuestion gate per parent plan-040 § K.2.c "NO AskUserQuestion needed (architect-recommended default per DD-3 + Karpathy P3)"). If S407 dev surfaces empirical evidence that ADDITIVE-ONLY insufficient (e.g. BC-9 consumer Code-Read shows immediate need) → STOP-FINDING fires per L-S397-2 vocab (CHARTER-TIER-SURFACE severity) + main session AskUserQuestion gate trigger

**Charter-tier-surface flag status overall: ZERO NEW FLAGS this sub-plan** (G.3 K.2.b RESOLVED + K.2.c DEFAULT applies + K.2.a N/A).

---

## N. Sequencing + parallel-eligibility

### N.1 Within-Phase-G-prime sequencing

- **S406 (this PLAN)**: sandwich-architect authors plan-044 (re-dispatch after S405 crashed at 64K output cap)
- **S407 (next)**: sandwich-dev FOCUSED_IMPL executes D1-D6; commits at session close per D-060
- **S408**: sandwich-verifier AP-1 fresh-context — V1 acceptance criteria (PASS-1 thru PASS-9) + V3 charter compliance + V5 regression + V6 integration smoke per S400 verifier shape

### N.2 Parallel-eligibility

- **THIS plan parallel-eligible WITH**: NONE (sequential POST-G.3 SHIP per parent plan-040 § N.2; G.3 ALREADY SHIPPED at S399+S400; G.4 is the final Phase G-prime sub-track)
- **THIS plan parallel-eligible WITHIN sub-tracks**: D1+D2+D6 (parser, mapper, ADR are file-disjoint and can be authored in any order); D3 (CLI) depends on D1+D2; D5 (tests) depends on D2+D3; D4 (thesis-log) depends on D3 OR can be authored canned-template-first then populated post-D3 live run
- **Cross-phase parallel-eligibility**: G.4 IMPL parallel-eligible with Phase F-prime data-corpus ingestion (per parent plan-040 § N.2 disjoint file-scope: BC-2 fundamental vs BC-5 news / BC-8 personas)
- **Cross-sub-plan parallel-eligibility**: G.4 verifier (S408) parallel-eligible with G.2 unblock work IF user authorizes G.2 resume (separate dispatch path)

### N.3 Phase G-prime CLOSE candidate

S408 close = Phase G-prime DONE candidate per parent plan-040 § H.3 CODE-READY-DATA-PARTIAL attestation discipline:
- ALL 4 sub-plans 041/042/043/044 SHIPPED + VERIFIED (G.2 BLOCKED per RM3 explicitly documented as Phase-G-prime-V2 carry-forward per AP-7)
- 4 ADRs ACCEPTED (D-080 + D-082 + D-083; D-081 PENDING G.2 unblock)
- VHM dogfood ran end-to-end (live-LLM OR mocked-only V0)
- ratio_service smoke PASS on extracted FS
- 5-document gold-set ESTABLISHED (per dispatch brief Glob: 2 fixtures present — VHM + HPG)

---

## P. Compliance attestation grid

### P.1 Standard items (per parent plan-040 § P precedent)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work)
- AP-1 ✓ (architect fresh-context per dispatch brief; main session ratifies)
- AP-5 ✓ (re-read all binding sources at session entry per VBW; 12+ source files Read inline via tool calls)
- AP-7 ✓ (every DEFER decision in § B names prerequisites + revisit triggers — no naked deferrals)
- AP-23 ✓ (1st-instance HOLD on mapper-table + dogfood-CLI + tests/integration/ patterns; promote-or-retire calculus at Phase G-prime CLOSE)
- autonomous_continue_no_self_pause ✓
- dont_self_pause_at_session_boundary ✓
- stop_offering_routing_branches ✓
- D-050 CHARTER ✓ (ZERO new import anthropic; G.4 reuses G.3 claude_cli_transport transitively; verifier grep-asserts at V3)
- D-059 ✓ (R1 datetime-tz BINDING for ingested_at field; mapper sets datetime.now(UTC))
- D-060 ✓ (architect has no Bash; main session commits this plan)
- D-064 ✓ (PdfSource.__post_init__ validates pdf_path via safe_user_path per pdf_source.py:64-73)
- D-065 Rule 16 ✓ (mode #2 satisfied via G.3 EchoValidator gate transitively; G.4 mapper input = validated raw_cells; mapper output = canonical Decimal via _canonicalize_numeric_string per DD-5)
- D-067 ✓ (Phase 1b CONSUMED variant; COLD-START declared on task_class="pdf-dogfood-bc2-integration-plan"; 6 sub-tracks ≥3 floor)
- I-S1 ✓ (NO LLM math; EchoValidator gate + deterministic mapper+parser)
- I-S1-1 (Rule 16) ✓
- I-S2 ✓ (every plan claim cites source file:line; 12+ source files VBW-confirmed)
- I-S20 ✓ (per-adapter cost recorded in thesis-log; calibration_grade='D' V0 baseline)
- I-S22 ✓ (ExtractedFinancialStatement provenance preserved → thesis-log artifact)
- I-S34 ✓ (VHM PDF from public Vietstock OR Vinhomes IR; fixture committed per Glob)
- I-S35 ✓ (thesis-log uses 'thesis exploration' / 'consideration' framing; disclaimer footer verbatim from validate_thesis.py:46-53)
- 0 charter writes ✓
- 0 constitution writes ✓
- 0 human-workspace writes ✓ (architect output = plan file + observation file ONLY)
- 0 production code ✓ (architect PLAN-only)
- ZERO new pyproject.toml deps ✓ (G.4 reuses click + Python stdlib + existing G.3 stack)

### P.2 Same-sweep-shipped disciplines (per dispatch brief)

- L-S392-1 dispatch-brief VBW ✓ (every file path Read/Glob/Grep-confirmed BEFORE citing; see § D + § F + § E references — all paths verified empirically in this session)
- L-S395-1 full-pipeline cold-probe at STEP 0 ✓ (Sub-step 0.4 Claude CLI vision + Sub-step 0.5 SQLite write cold-probes mandated at S407 IMPL entry)
- L-S397-1 per-category LOC ceilings ✓ (per § G.1 table: core/test/doc/ADR distinguished)
- L-S397-2 STOP-FINDING severity vocab ✓ (frozen enum cited at Sub-step 0.4 + 0.5 + RM-G4-1; cited as CHARTER-TIER-SURFACE/HIGH/INFO)
- L-S397-3 close-loop file-existence ✓ (architect runs wc -l BEFORE composing return summary per dispatch brief CLOSE-LOOP requirement)
- L-S389-1 exact-integer wc -l ✓ (return summary cites integers from wc -l, no ~ prefix)
- L-S389-2 ADR 12-field schema floor ✓ (D-083 ≥13 fields per E.6 DoD)
- L-S405-1 OUTPUT-budget HARD CAP ✓ (this plan ≤700 LOC + observation ≤100 LOC + return summary ≤6K tokens)
- PCG-S401-3 STOP-FINDING template ✓ (Sub-step 0.4 + 0.5 reference _STOP-FINDING-template.md scaffold per dispatch brief)
- D-050 anthropic_api_to_subagent BINDING ✓ (per § P.1 above)
- D-060 commit policy ✓ (per § P.1 above)
- M-S405-1 prevention rule ✓ (THIS plan is the re-dispatch implementing the prevention; 64K output cap respected)

---

**END OF PLAN 044-S406-PHASE-GPRIME-G4-VHM-ANNUAL-REPORT-DOGFOOD-AND-BC2-INTEGRATION**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S407 sandwich-dev per § N.1 sequencing.
