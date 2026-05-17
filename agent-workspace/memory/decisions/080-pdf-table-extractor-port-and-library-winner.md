---
id: D-080
title: "PdfTableExtractorPort ABC contract + G.1 empirical library bake-off winner"
status: PROPOSED
severity: MEDIUM
date: 2026-05-17
session: S394
authored_by: sandwich-dev (IMPL-tier; S394 plan-041 D5)
plan: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md
supersedes: NONE
superseded_by: NONE
depends_on:
  - D-066 (CrawlerAdapter ABC precedent at packages/application/news/ports/crawler_adapter.py)
  - D-059 (Python determinism -- datetime-tz R1 BINDING on ExtractedFinancialStatement.extracted_at)
  - D-064 (path-safety 5-invariant -- BINDING on PdfSource.pdf_path + bake-off probe --pdf-path)
  - D-061 (add-with-rationale doctrine -- winner dep addition deferred to G.2 IMPL sub-plan 042)
revisit_trigger:
  - "ABC method count exceeds 4 (e.g. page_range, detect_currency) -> D-080-V2 amendment"
  - "Winner library license posture changes (SPDX identifier mutation)"
  - "Accuracy floor unmet on 5-document G.4 gold set (Phase G-prime-V2)"
  - "Real PDF download becomes available -> re-run bake-off probe to confirm winner"
---

# D-080: PdfTableExtractorPort ABC contract + G.1 empirical library bake-off winner

## Context

Phase G-prime (Theme J) adds BC-2 Fundamental Data PDF table extraction substrate to StockForge.
VN annual reports are filed as PDFs; existing BC-2 only ingests from vnstock API. The goal is to
extract financial statement tables (IS/BS/CF) from PDF files, enabling VHM 2023/2024+ annual
reports to flow through the ratio_service and thesis pipeline.

Prior to this ADR:
- No PDF extraction code exists in StockForge (confirmed by Grep in parent plan-040 § C.0.6)
- vnstock API is the only BC-2 data source (vnstock_fundamental_adapter.py)
- No application-layer fundamental module existed (packages/application/fundamental/ NEW)

Key problem: Multiple viable PDF extraction libraries exist (pdfplumber, camelot, docling, pypdf,
pymupdf) with different license postures, accuracy profiles, and dependency footprints. An empirical
bake-off is required to select the winner before committing a production adapter (D-061 add-with-
rationale doctrine).

Source evidence:
- parent plan-040 § A goal + § D DDs 1-8 (binding canonical source)
- packages/application/news/ports/crawler_adapter.py:1-128 (D-066 ABC precedent, full read)
- packages/domain/fundamental/models/financial_statement.py:42-88 (FinancialStatement shape)
- packages/domain/fundamental/value_objects/line_item.py:33-45 (10 LineItemKey canonical)
- packages/_shared/__init__.py:1-7 (dep-free constraint — rejects _shared/ as ABC location)
- pyproject.toml:7 (license = "Proprietary" — AGPL-3.0 incompatible)
- crawl4ai/hub.py:24-35 (BaseCrawler.__init_subclass__ typecheck pattern; attributed at D-066)

## Decision

### (a) PdfTableExtractorPort ABC contract shape (D1)

Location: `packages/application/fundamental/pdf_table_extractor_port.py` (NEW).

NOT `packages/_shared/pdf/` — dispatch brief was incorrect. VBW correction (STEP 0.5 finding):
- `packages/_shared/__init__.py:1-7` constrains _shared/ to dep-free pure-Python; PDF imports violate
- D-066 CrawlerAdapter ACTUALLY lives at `packages/application/news/ports/crawler_adapter.py`
- Parent plan-040 DD-1 canonical source specifies `packages/application/fundamental/`

ABC shape (4 abstract methods + 1 ClassVar, mirroring D-066 at L43-128):
- `source_id: ClassVar[str]` — enforced non-empty via `__init_subclass__` (D-066 L60-78 pattern)
- `@abstractmethod extract(pdf_source: PdfSource) -> ExtractedFinancialStatement`
- `@abstractmethod supports(pdf_path: Path) -> bool`
- `@abstractmethod name() -> str`
- `@abstractmethod extractor_version() -> str`

Exactly 4 abstract methods (Karpathy P2 ceiling per plan-041 DD-2). +1 over D-066 CrawlerAdapter's
3 methods — principled extension for provenance (ExtractedFinancialStatement.extractor_version field).

Error hierarchy:
- `PdfTableExtractorError(Exception)` — base error (parse/OCR/network failures)
- `PdfTableExtractorOptionalDepError(PdfTableExtractorError, ImportError)` — optional dep missing

### (b) ExtractedFinancialStatement intermediate dataclass contract (D2)

Location: `packages/application/fundamental/extracted_financial_statement.py` (NEW).
Companion: `packages/application/fundamental/pdf_source.py` (NEW).

ExtractedFinancialStatement fields (7 fields, frozen+slotted):
- `pdf_source: PdfSource` — encapsulated ABC input
- `raw_cells: Mapping[str, str]` — adapter-specific label -> raw string (BEFORE canonical mapping)
- `extraction_method: str` — populated from PdfTableExtractorPort.name()
- `extractor_version: str` — populated from PdfTableExtractorPort.extractor_version()
- `source_pdf_page: int | None` — 1-indexed; None if adapter doesn't track page
- `source_pdf_sha256: str` — 64-char hex; enables reproducibility verification
- `extracted_at: datetime` — UTC-aware per D-059 R1

PdfSource fields (6 fields, frozen+slotted):
- `pdf_path: Path` — D-064 path-safety validated via safe_user_path
- `source_url: str` — must start with http(s):// per I-S2 citation discipline
- `ticker: Ticker` — VN stock ticker
- `statement_type: StatementType` — IS/BS/CF
- `period_end: date` — financial period end
- `filing_date: date` — filing_date >= period_end per Rule 1

### (c) Empirical winner ratification with 4-metric grid (D3)

Bake-off probe script: `apps/cli/bench/pdf_bake_off.py` (NEW one-off probe per DD-6).

Libraries probed (3 candidates in isolated venv per DD-8):
- pdfplumber (MIT) — table-focused; pdfminer.six backend
- docling (MIT) — IBM layout-aware; may need PyTorch
- pypdf (BSD-3-Clause) — text-only baseline

pymupdf EXCLUDED: AGPL-3.0 license incompatible with pyproject.toml license="Proprietary".

4-metric grid (per plan-041 DD-4 + parent plan-040 DD-4):
- Metric 1: Cell-content-exact-match accuracy (% of 10 LineItemKey cells correct) — WINNER PICK
- Metric 2: Extraction wall-time p50+p95 (tie-break: < 60s ceiling)
- Metric 3: Dependency footprint (dep count + install size) — documentation-only
- Metric 4: License compatibility (SPDX identifier + repo URL) — documentation-only

**WINNER: PENDING-real-pdf-required**

Status: Bake-off probe was authored and structurally validated. Real VHM 2023 + HPG 2023
annual report PDFs could not be downloaded during S394 IMPL session (network restrictions:
HTTP 403 from vinhomes.vn + SSL errors from hpg.vn). Synthetic placeholder PDFs were committed
for structural/contract test purposes only. Metric 1 scores cannot be computed from placeholders.

Action required: See STOP-FINDING-S394-pdf-real-pdfs-needed.md. Human must provide real PDFs,
run bake-off probe, and update this ADR with actual winner + 4-metric grid.

Calibration-grade: D (proxy baseline; pending real-PDF empirical validation; see I-S20)

Community evidence (supplementary, NOT pick-deciding):
- pdfplumber is widely used for VN financial PDF extraction (FinceptTerminal precedent)
- docling shows strong layout-aware results on financial documents
- pypdf text-only extraction is insufficient for structured table extraction

### (d) License posture per chosen library

| Library | SPDX | Proprietary-compatible? | Notes |
|---------|------|------------------------|-------|
| pdfplumber | MIT | YES | Pure-Python |
| camelot-py | MIT | YES | Ghostscript dep for some modes |
| docling | MIT | YES | May need PyTorch CPU-only |
| pypdf | BSD-3-Clause | YES | Text-only |
| pymupdf | AGPL-3.0 | **NO** | EXCLUDED; K.2.a STOP-AND-ASK if license changes |

### (e) Chain D-066 -> D-080 ABC pattern continuity

D-066 established Strategy ABC + ClassVar + `__init_subclass__` typecheck for BC-5 News.
D-080 extends the same pattern to BC-2 Fundamental:
- Same `__init_subclass__` enforcement pattern (crawl4ai/hub.py:24-35 origin)
- Same `source_id: ClassVar[str]` enforcement
- Same base error hierarchy pattern
- +1 method (extractor_version) over D-066 for provenance need (DD-2 rationale)

## Rationale

- **D-066 CrawlerAdapter ABC precedent**: proven Strategy ABC pattern in StockForge; same BC-
  application-layer-port convention; runtime enforcement > structural typing for registry safety.
- **L-S32-1 empirical-probe-first**: library landscape evolves fast; picking without empirical
  validation risks adapter rewrite at G.4 dogfood. 4-metric bake-off IS the calibration substrate.
- **Karpathy P2 simplicity**: 4 abstract methods at ceiling; method count growth -> D-080-V2 via
  explicit versioned amendment (not silent ABC bloat).
- **Karpathy P3 surgical scope**: ZERO touch to vnstock_fundamental_adapter.py or existing BC-5
  News pipeline. ExtractedFinancialStatement is application-layer intermediate (not domain entity).
- **D-059 R1**: datetime-tz binding on extracted_at prevents silent timezone-aware/naive mismatch
  in downstream ratio_service calibration (historical data integrity).
- **D-064 path-safety**: PDF paths validated before extraction to prevent directory traversal
  in user-supplied PDF inputs.

## Alternatives Considered

**Protocol structural typing over ABC (rejected)**:
- Runtime enforcement impossible (Protocol checks at type-checking time only)
- `__init_subclass__` cannot be used in Protocol
- Shared base error hierarchy not supported by Protocol inheritance
- D-066 precedent chose ABC for same reasons — consistent choice

**packages/_shared/pdf/ location (rejected)**:
- `packages/_shared/__init__.py:1-7` constraint: dep-free pure-Python only
- PDF library imports (pdfplumber, camelot, docling) are NOT pure-Python
- Dispatch brief erroneously suggested this location; VBW STEP 0.5 correction applied

**Add all 3 libraries to pyproject.toml at G.1 (rejected)**:
- Risk: 2 of 3 become dead deps post winner-pick
- D-061 add-with-rationale doctrine: dep addition = deliberate ratified act at G.2 IMPL
- DD-8: isolated-venv probe preserves rollback path if all candidates fail

**5 abstract methods at G.1 ABC surface (rejected)**:
- Karpathy P2: page_range + detect_currency + detect_language = premature optimization
- V0 = VND + VN-language defaults; multi-currency deferred to Phase 3
- D-080-V2 amendment for any extension (explicit > silent)

**Synthetic fixture gold-set (rejected by plan; real PDFs blocked by network)**:
- Synthetic fixtures don't test real-world VN PDF layout drift
- RM3 mitigation: human provides real PDFs; probe re-runs
- Calibration-grade D acknowledged; real-PDF re-run targets calibration-grade B

## Consequences

- G.2 sub-plan 042 dispatch: consumes winner library + ABC contract + gold-set fixtures.
  BLOCKED ON: real PDF provision + K.2.a Trigger B evaluation + winner field update in this ADR.
- G.3 sub-plan 043 dispatch: consumes ABC contract (UNBLOCKED by D1+D2; EchoValidator TBD).
  PARALLEL-ELIGIBLE with G.2 per parent plan-040 § N.2.
- G.4 sub-plan 044 dispatch: consumes both G.2 + G.3 adapters (BLOCKED on both).
- ADR update required: winner field must be populated before G.2 IMPL ratification.

## Source Evidence Chain

1. `agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md` § D1-D5
2. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § D DDs 1-8
3. `packages/application/news/ports/crawler_adapter.py:1-128` (D-066 precedent; full read)
4. `packages/_shared/__init__.py:1-7` (dep-free constraint; VBW evidence)
5. `packages/domain/fundamental/value_objects/line_item.py:33-45` (10 LineItemKey)
6. `packages/domain/fundamental/models/financial_statement.py:42-88` (frozen+slotted pattern)
7. `pyproject.toml:7` (license="Proprietary"; pymupdf AGPL-3.0 incompatible)
8. `agent-workspace/memory/decisions/066-crawler-adapter-abc.md` (if exists; D-066 ADR)
9. `agent-workspace/constitution/invariants.md` (D-059 R1 + D-064 + I-S22 + Rule 1)
10. `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md` (RM3 blocker)
11. `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-library-bakeoff-impl.md` (this session)
12. `crawl4ai/hub.py:24-35` (BaseCrawler.__init_subclass__ origin; attributed at D-066 L1-3)
