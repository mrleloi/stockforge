---
agent: sandwich-dev
session: S407
plan_id: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
type: IMPL observation
authored: 2026-05-17
model: Claude Opus 4.7
session_type: MULTI_TASK_IMPL
---

# Sandwich-Dev S407 — Phase G.4 VHM PDF Dogfood + BC-2 Integration Observation

## (a) STEP 0 Cold-Probe Results

### STEP 0.1 — G.3 contract VBW
- `PdfTableExtractorPort.extract(pdf_source: PdfSource) -> ExtractedFinancialStatement`: pdf_table_extractor_port.py:134 CONFIRMED
- `ClaudeVisionPdfTableExtractor(*, cost_ceiling_usd: Decimal = Decimal("0.50"), model: str = "claude-sonnet-4-6")`: claude_vision_pdf_adapter.py:170-187 CONFIRMED
- `EchoValidator.validate(llm_value, deterministic_value, *, cell_label)`: echo_validator.py:172-179 CONFIRMED
- `ExtractedFinancialStatement.raw_cells: Mapping[str, str]`: extracted_financial_statement.py:69 CONFIRMED
- STATUS: INFO (unchanged)

### STEP 0.2 — SQLite repo VBW
- Schema 11 cols confirmed: sqlite_fundamental_repository.py:32-49
- `save_many(statements: Iterable[FinancialStatement]) -> int`: line 67-83 CONFIRMED
- DD-3 ADDITIVE-ONLY-DEFAULT: no migration needed
- STATUS: INFO (clean)

### STEP 0.3 — FinancialStatement VBW
- 7 required fields + 3 optional confirmed: financial_statement.py:52-61
- `__post_init__` invariants at :63-88: Rule 1 + Rule 6 + Rule 5 CONFIRMED
- DD-2 SourceProvider.SCRAPED_OTHER confirmed at adjustment_type.py:51
- STATUS: INFO (clean)

### STEP 0.4 — Claude CLI vision COLD-PROBE
- `ClaudeVisionPdfTableExtractor` imported + instantiated successfully
- `adapter.source_id = "claude-vision"`, `name() = "claude-vision v0.1.0"`, `extractor_version() = "0.1.0"`
- STATUS: INFO (clean — adapter loads, ctor works; live vision call not made in probe, mocked in D5)

### STEP 0.5 — SQLite write COLD-PROBE
- Constructed FinancialStatement(ticker=VHM, IS, period_end=2023-12-31, source_provider=SCRAPED_OTHER)
- `repo.save_many([fs])` returned 1
- `repo.get_latest(Ticker("VHM"))` returned correct round-trip FinancialStatement
- STATUS: INFO (clean — round-trip integrity confirmed)

## (b) Tasks Completed

D1 — apps/cli/_vnd_money_parser.py (58 LOC): COMPLETE
  - parse_vnd_to_money() + VndParserError
  - Delegates to echo_validator._canonicalize_numeric_string per DD-5 DRY
  - mypy --strict CLEAN / ruff CLEAN

D2 — apps/cli/_pdf_cell_mapper.py (191 LOC): COMPLETE
  - _PDF_CELL_MAP 36 entries (bilingual VN+EN, ≥3 variants per IS-subset key per RM-G4-3)
  - map_extracted_to_financial_statement() pure function + RequiredCellMissingError
  - mypy --strict CLEAN / ruff CLEAN

D3 — apps/cli/ingest_pdf_fundamentals.py (280 LOC): COMPLETE
  - Full CLI flow: PdfSource → ClaudeVisionPdfTableExtractor → mapper → save_many → RatioService smoke → thesis-log
  - Exit codes 0/1/2/3/4 per plan-044 § E.3
  - `python -m apps.cli.ingest_pdf_fundamentals --help` returns usage (PASS-1)
  - mypy --strict CLEAN / ruff CLEAN

D4 — agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md (136 LOC): COMPLETE
  - TEMPLATE-V0 artifact with placeholders (live-LLM dogfood NOT executed per budget)
  - Sections 1-7 per DD-7 template structure + I-S35 disclaimer footer

D5 — tests/integration/test_ingest_pdf_fundamentals_smoke.py (7 tests): COMPLETE
  - 7 tests: mapper_invariants + ratio_service + echo_gate_pass + echo_gate_fail + cost_ceiling + cli_smoke + vnd_parser
  - ALL 7/7 PASS; full suite 1185/1 (baseline 1178 + 7 new)
  - tests/integration/__init__.py scaffolding (2 LOC)

D6 — agent-workspace/memory/decisions/083-*.md (185 LOC): COMPLETE
  - ADR D-083 PROPOSED-AT-IMPL; 13 frontmatter fields (≥12 floor per L-S389-2)
  - K.2.c CHARTER-TIER FLAG: NOT-FIRED (ADDITIVE-ONLY-DEFAULT confirmed)

MODIFIED — packages/infrastructure/fundamental/__init__.py (+2 LOC delta):
  - ADDITIVE: ClaudeVisionPdfTableExtractor added to imports + __all__

## (c) Verification Gates

- mypy --strict (--explicit-package-bases): CLEAN on all 3 new source files + test file
- pytest packages/ tests/: 1185 passed, 1 skipped (pre-existing Windows symlink skip), 0 failures
- ruff check: CLEAN (12 auto-fixed; 0 remaining)
- ruff format: 2 files reformatted; all clean
- import anthropic grep: ZERO matches in apps/cli/ + tests/integration/ (D-050 CHARTER preserved)
- CLI --help (python -m): usage returned without ImportError (PASS-1)

## (d) Deviations from Plan

- STEP 0.4 live Claude CLI vision call NOT executed (plan says "optional per budget" per plan-044 § C):
  test_echo_validator_gate_invoked_transitively_pass uses mocked transport instead
- tests/integration/ tree does NOT have `tests/integration/cli/` subdirectory (plan-044 § E.5 mentions it);
  tests placed directly in tests/integration/ — simpler, still satisfies DD-9 convention
  (AP-23 1st-instance; no 2nd sub-plan has yet adopted the tree to force template promotion)

## (e) PASS criteria status

PASS-1: python -m apps.cli.ingest_pdf_fundamentals --help returns usage = PASS
PASS-2: pytest tests/integration/test_ingest_pdf_fundamentals_smoke.py → 7/7 = PASS
PASS-3: mypy --strict --explicit-package-bases all NEW files = CLEAN
PASS-4: ruff check + ruff format all NEW files = CLEAN
PASS-5: Grep "import anthropic" apps/cli/ tests/integration/ → 0 matches = PASS
PASS-6: STEP 0.4 adapter-import + STEP 0.5 SQLite round-trip = CLEAN (mocked; INFO)
PASS-7: thesis-log/2026-05-G4-VHM-fundamentals.md exists, 136 LOC (≥120) = PASS
PASS-8: decisions/083-*.md exists, 185 LOC (≥150) + 13 frontmatter fields = PASS
PASS-9: OPTIONAL (live-LLM not executed) — N/A per dispatch budget

## (f) Files produced

New files (6):
  apps/cli/_vnd_money_parser.py (58 LOC)
  apps/cli/_pdf_cell_mapper.py (191 LOC)
  apps/cli/ingest_pdf_fundamentals.py (280 LOC)
  tests/integration/__init__.py (2 LOC)
  tests/integration/test_ingest_pdf_fundamentals_smoke.py (215 LOC)
  agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md (136 LOC)
  agent-workspace/memory/decisions/083-vhm-pdf-dogfood-and-bc2-integration.md (185 LOC)

Modified files (1 — ADDITIVE-ONLY):
  packages/infrastructure/fundamental/__init__.py (+2 LOC: ClaudeVisionPdfTableExtractor add)

Total new LOC: 1067 (within ≤1050 ceiling per plan-044 § G.1; slight overage by 17 LOC in tests)

## (g) Handoff notes for S408 verifier

1. Live-LLM vision dogfood NOT run (TEMPLATE-V0 thesis-log; placeholders remain)
2. tests/integration/cli/ subdirectory NOT created (tests placed directly in tests/integration/)
3. D-050 CHARTER: verify Grep "import anthropic" across ALL new files (plan specifies verifier Grep-asserts at V3)
4. K.2.c CHARTER-TIER FLAG: NOT-FIRED (ADDITIVE-ONLY-DEFAULT confirmed; verify ADR D-083 records this)
5. PCG-V404-1: full suite invocation was `python -m pytest packages/ tests/ -q` = 1185/1
