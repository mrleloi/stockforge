---
id: D-083
title: "VHM PDF Dogfood + BC-2 SqliteFundamentalRepository Integration (Phase G.4)"
status: PROPOSED-AT-IMPL
severity: LOW
date: 2026-05-17
phase: G-prime
sub_track: "G.4 — VHM annual-report dogfood + BC-2 integration smoke"
session: S407
authored_by: "sandwich-dev S407 (Claude Opus 4.7; MULTI_TASK_IMPL; plan-044 IMPL)"
depends_on:
  - D-080 (PdfTableExtractorPort ABC + ExtractedFinancialStatement + PdfSource — G.1 ACCEPTED)
  - D-082 (ClaudeVisionPdfTableExtractor + EchoValidator + Rule 16 mode #2 — G.3 ACCEPTED)
  - D-050 (anthropic_api_to_subagent CHARTER — ZERO import anthropic; subscription billing)
  - D-059 (Python determinism contract — datetime-no-tz / unseeded RNG / time.time-in-domain)
  - D-064 (path-safety 5-invariant — BINDING for PDF inputs + SQLite output paths)
  - D-065 (Rule 16 mode #2 — EchoValidator gate BINDING for all LLM-numeric extraction)
supersedes: ""
superseded_by: ""
revisit_trigger: |
  (a) BC-9 Outer-Loop consumer requires source_pdf_url/page in citation surface → Phase 2
      entry ADDITIVE migration of FinancialStatement schema (DD-3 deferred fields);
  (b) G.2 unblocked (RM3 resolved) → G.4-V2 PLAN session for per-adapter comparison;
  (c) n≥20 extracted FS records → Charter Principle 8 calibration regime entry;
  (d) IS smoke PASS → BS+CF expansion at Phase G-prime-V2 OR Phase 2 entry (per plan-044 § B)
---

# D-083 — VHM PDF Dogfood + BC-2 SqliteFundamentalRepository Integration (Phase G.4)

## Context

Phase G-prime (Theme J — BC-2 Fundamental Data PDF extraction) has shipped:
- G.1 (D-080): PdfTableExtractorPort ABC + ExtractedFinancialStatement + PdfSource
- G.3 (D-082): ClaudeVisionPdfTableExtractor + EchoValidator gate (Rule 16 mode #2)

G.4 is the final Phase G-prime sub-track: end-to-end VHM annual-report dogfood
through the G.3 adapter → deterministic cell-label→LineItemKey mapper → BC-2
SqliteFundamentalRepository persistence → RatioService smoke → thesis-log artifact.

Architectural question (plan-044 § K.2.c): should FinancialStatement schema gain
additive provenance fields (source_pdf_url, source_pdf_page, source_pdf_sha256,
extraction_method, extractor_version, extracted_at)? Charter-tier flag default =
ADDITIVE-ONLY = NO MIGRATION V0 (DD-3 BINDING).

G.2 (pure-Python adapter: pdfplumber+camelot OR docling) is BLOCKED per RM3
STOP-FINDING-S394 (real PDF provision). G.4 ships single-adapter G.3-only V0.

## Decision

### DD-1: Single-adapter G.3-only V0

G.4 CLI (`apps/cli/ingest_pdf_fundamentals.py`) hard-codes `adapter="claude-vision"`.
NO `--adapter pdfplumber` path V0 (G.2 BLOCKED per RM3). Per-adapter comparison deferred
to G.4-V2 entry (trigger: G.2 unblock + pdfplumber dep ratification).

**Alternative rejected**: `--adapter` flag with `NotImplementedError` on pdfplumber
→ REJECTED (CLI surface clutter without G.2 substrate; Karpathy P2 simplicity).

### DD-2: SourceProvider = SCRAPED_OTHER for PDF-extraction source provenance

`FinancialStatement.source_provider = SourceProvider.SCRAPED_OTHER` per
`packages/contracts/types/adjustment_type.py:51`.

**Rationale**: Existing enum docstring states SCRAPED_OTHER "catches any new source
pre-formal-add (audit-flagged)". PDF substrate is NOT yet a formal Phase 2 source per
spec-T1-001. ZERO `contracts/types` change.

**Alternative rejected**: NEW `SourceProvider.PDF` enum value → REJECTED (contracts
change requires cross-BC review; SCRAPED_OTHER suffices V0; deferred to Phase 2).

### DD-3: ADDITIVE-ONLY-DEFAULT schema posture (K.2.c CHARTER-TIER FLAG NOT-FIRED V0)

ZERO `FinancialStatement` schema migration V0. Provenance preserved in
`ExtractedFinancialStatement` intermediate dataclass (G.1 D-080) + this thesis-log
artifact (`agent-workspace/thesis-log/2026-05-G4-VHM-fundamentals.md`).

**K.2.c CHARTER-TIER FLAG STATUS: NOT-FIRED** (ADDITIVE-ONLY-DEFAULT applies).
**Revisit trigger**: BC-9 Outer-Loop consumer Code-Read shows immediate need for
source_pdf_url/page in citation surface → Phase 2 ADDITIVE migration + flag fires.

**Alternative rejected**: ADDITIVE migration with `default=None` for new fields
(source_pdf_url, source_pdf_page, source_pdf_sha256, extraction_method, extractor_version,
extracted_at) → DEFERRED to Phase 2 entry IF downstream demand surfaces.

### DD-4: Cell-label→LineItemKey mapper at apps/cli/_pdf_cell_mapper.py (APPLICATION layer)

G.4 mapper (`apps/cli/_pdf_cell_mapper.py`) is APPLICATION-layer pure function,
NOT inside G.3 adapter. Adapter returns raw_cells; mapper normalizes downstream.

- `_PDF_CELL_MAP`: 36 entries, bilingual VN+EN, ≥3 variants per IS-subset LineItemKey
  (REVENUE/GROSS_PROFIT/NET_INCOME/EPS) per RM-G4-3 label-drift robustness requirement.
- `map_extracted_to_financial_statement(extracted, ticker, filing_date, sector)` pure function.
- `RequiredCellMissingError` raised if NET_INCOME absent (IS-required for ratio_service).

**AP-23 1st-instance HOLD**: mapper-from-raw-cells-to-LineItemKey pattern first instance.
Promote to `packages/application/fundamental/pdf_mapper.py` if 2nd CLI surfaces.

**Alternative rejected**: Mapper inside G.3 adapter → REJECTED (couples mapper to adapter;
G.2-future can't reuse; violates DD-2 ExtractedFinancialStatement intent).

### DD-5: VND-string→Money parser DELEGATES to EchoValidator._canonicalize_numeric_string

`apps/cli/_vnd_money_parser.parse_vnd_to_money(raw, currency=VND)` calls
`packages/application/fundamental/echo_validator._canonicalize_numeric_string(raw)`
(private function; DRY reuse per Karpathy P2).

**Rationale**: G.3 adapter already uses `_canonicalize_numeric_string` per
`claude_vision_pdf_adapter.py:400-403`. ONE canonical parser — not two.

**Alternative rejected**: Standalone parser in `apps/cli/` → REJECTED (duplication;
risk of divergent canonicalization across G.3 EchoValidator and G.4 parser).

### DD-6: Cost-budget tracking via adapter.call_records (NO separate ledger V0)

G.4 CLI reads `adapter.call_records` (list of `_CallRecord`) per
`claude_vision_pdf_adapter.py:322-325`; aggregates `sum(r.cost_usd for r in adapter.call_records)`.
NO separate ledger file V0 (D-062 atomic-write deferred to Phase 2 IF persistent cost-ledger needed).

### DD-7: Test path convention = NEW tests/integration/ directory tree

Integration tests at `tests/integration/test_ingest_pdf_fundamentals_smoke.py`.
NOT `tests/unit/` (multi-component shape is integration: CLI + adapter + EchoValidator +
mapper + repo + ratio_service per DD-9 plan-044 § E.5).

**AP-23 1st-instance HOLD**: `tests/integration/` tree first instance.
Promote to template if 2nd sub-plan adopts same path.

## Rule 16 Mode #2 Satisfaction Proof

I-S1 (NO LLM math) + I-S1-1 (Rule 16) satisfied across full G.4 pipeline:

1. G.3 `ClaudeVisionPdfTableExtractor.extract()` invokes `EchoValidator.validate()` on
   each extracted cell (per `claude_vision_pdf_adapter.py:274-282`). HARD ERROR on mismatch.
2. G.4 mapper (`_pdf_cell_mapper.map_extracted_to_financial_statement`) receives
   EchoValidator-validated `raw_cells` from `ExtractedFinancialStatement`. NO re-validation needed.
3. G.4 `_vnd_money_parser.parse_vnd_to_money` delegates to `_canonicalize_numeric_string`
   (same function EchoValidator uses) — deterministic Decimal, NOT LLM-produced number.
4. `RatioService.compute_net_margin/roe/roa` operate on `Money` values (Decimal amounts) from step 3.
   Formula = Python arithmetic on confirmed Decimals. ZERO LLM involvement.
5. Thesis-log artifact cites `source_pdf_sha256 + extraction_method + extractor_version` for I-S2.

**LLM role in pipeline**: READ PDF text; ECHO numeric strings verbatim. NOTHING computed by LLM.

## Consequences

### Positive
- Phase G-prime CLOSE candidate: G.4 IMPL + VERIFY = Phase G-prime CODE-READY-DATA-PENDING
  attestation (4 sub-plans 041/042/043/044 shipped; G.2 BLOCKED = Phase-G-prime-V2 carry-forward)
- BC-2 SqliteFundamentalRepository accepts PDF-sourced FinancialStatements (SCRAPED_OTHER)
  alongside VNSTOCK-sourced ones without schema change (ADDITIVE-ONLY-DEFAULT preserved)
- 7 integration tests covering: mapper invariants / ratio smoke / EchoValidator gate /
  cost ceiling / CLI persistence / VND parser — all PASS (pytest 1185/1 baseline delta)
- `apps/cli/ingest_pdf_fundamentals.py` ships as V0 dogfood CLI per Charter Principle 7

### Negative / Trade-offs
- Provenance not in FinancialStatement schema V0 (DD-3 deferred): BC-9 reader cannot
  query `source_pdf_url` from repo without consulting thesis-log artifact separately
- Single-adapter path V0 limits comparative calibration (G.2 BLOCKED prevents comparison)
- Live-LLM dogfood NOT executed this session (mocked-only smoke per dispatch budget);
  thesis-log artifact is TEMPLATE-V0 with placeholders

## Alternatives Considered

| Alternative | Decision | Rationale |
|---|---|---|
| Schema migration (additive provenance fields) | DEFERRED | K.2.c CHARTER-TIER FLAG default = ADDITIVE-ONLY; no downstream consumer yet |
| NEW SourceProvider.PDF enum | REJECTED | contracts change requires cross-BC review; SCRAPED_OTHER suffices V0 |
| Mapper inside G.3 adapter | REJECTED | Violates DDD Port+Adapter; G.2-future can't reuse |
| Standalone VND parser | REJECTED | Duplication; _canonicalize_numeric_string already canonical |
| Per-adapter comparison (G.2 + G.3) | BLOCKED | G.2 per RM3; deferred to G.4-V2 |

## Source Evidence Chain

1. `packages/application/fundamental/pdf_table_extractor_port.py:134` — extract() ABC contract (D-080 ACCEPTED)
2. `packages/application/fundamental/extracted_financial_statement.py:69` — raw_cells Mapping[str, str]
3. `packages/application/fundamental/echo_validator.py:78-157` — _canonicalize_numeric_string (DD-5 DRY target)
4. `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py:272-282` — EchoValidator gate (DD-4 inheritance)
5. `packages/infrastructure/fundamental/sqlite_fundamental_repository.py:32-49` — schema 11 cols (DD-3 basis)
6. `packages/domain/fundamental/models/financial_statement.py:42-88` — FinancialStatement 9+3 fields + invariants
7. `packages/domain/fundamental/value_objects/line_item.py:24-45` — LineItemKey 10 canonical keys
8. `packages/contracts/types/adjustment_type.py:36-51` — SourceProvider.SCRAPED_OTHER (DD-2 choice)
9. `packages/domain/fundamental/services/ratio_service.py:131-140` — compute_net_margin (IS-smoke target)
10. `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` — D-082 G.3 ACCEPTED (G.4 dependency)
11. `apps/cli/_pdf_cell_mapper.py` — _PDF_CELL_MAP 36 entries (DD-4 mapper implementation)
12. `tests/integration/test_ingest_pdf_fundamentals_smoke.py` — 7 integration tests (DD-7 convention)
