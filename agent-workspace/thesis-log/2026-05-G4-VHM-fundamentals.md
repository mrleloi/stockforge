---
ticker: VHM
as_of: 2026-05-17
source_pdf_sha256: <populated-at-live-LLM-run>
extraction_method: claude-vision v0.1.0
extractor_version: 0.1.0
total_cost_usd: <populated-at-live-LLM-run>
cells_extracted: <populated-at-live-LLM-run>
canonical_keys_present: [net_income, revenue, gross_profit, eps]
status: TEMPLATE-V0
dogfood_session: S407
plan: 044-S406-phase-gprime-g4-vhm-annual-report-dogfood-and-bc2-integration
phase: G-prime
calibration_grade: D
---

# G.4 VHM PDF Fundamentals Dogfood — Thesis-Log Artifact (TEMPLATE-V0)

> **Research aid, not financial advice (I-S35).** See disclaimer footer.
> This is a TEMPLATE-V0 artifact. Placeholders `<populated-at-live-LLM-run>`
> will be replaced when `apps/cli/ingest_pdf_fundamentals.py` is run against
> the real VHM 2023 annual-report PDF with live Claude vision (authorized per
> plan-044 § B "Live-LLM dogfood execution" revisit trigger).

---

## 1. Provenance

| Field | Value |
|---|---|
| Ticker | VHM |
| Source PDF URL | https://ir.vinhomes.vn/bao-cao-thuong-nien/2023 |
| Period End | 2023-12-31 |
| Filing Date | 2024-03-31 |
| Source PDF SHA-256 | `<populated-at-live-LLM-run>` |
| Extraction Method | claude-vision v0.1.0 (G.3 ClaudeVisionPdfTableExtractor) |
| Extractor Version | 0.1.0 |
| As-Of (extraction) | <populated-at-live-LLM-run> |
| SourceProvider | scraped_other (DD-2: SCRAPED_OTHER per adjustment_type.py:51) |
| Statement Type | IS (Income Statement; V0 IS-only per plan-044 § A) |
| Fixture Path | tests/fixtures/pdf/vhm-2023-annual.pdf |

---

## 2. Extracted Canonical Cells

> Values from EchoValidator-validated raw_cells → deterministic `_PDF_CELL_MAP` mapper.
> D-050 CHARTER: ZERO LLM math — all amounts from deterministic code.
> Format: VND (Billion VND per VHM annual report convention).

| Line Item Key | Amount (Billion VND) | Currency | Raw Label (VHM PDF) |
|---|---|---|---|
| revenue | `<populated-at-live-LLM-run>` | VND | Doanh thu thuần |
| gross_profit | `<populated-at-live-LLM-run>` | VND | Lợi nhuận gộp |
| net_income | `<populated-at-live-LLM-run>` | VND | Lợi nhuận sau thuế của cổ đông công ty mẹ |
| eps | `<populated-at-live-LLM-run>` | VND | Lãi cơ bản trên cổ phiếu |

> Mocked-smoke-only run: canned cells used in D5 integration tests:
> `Doanh thu thuần: 100.000` / `Lợi nhuận sau thuế: 50.000` /
> `Lợi nhuận gộp: 70.000` / `EPS: 1.500` (plan-044 § E.5 mock strategy).

---

## 3. Computed Ratios (RatioService Smoke)

> Formula audit citations from `packages/domain/fundamental/services/ratio_service.py`.
> Rule 16 mode #2: ratio formulas call deterministic Python — NO LLM math.

| Ratio | Value | Formula Audit Citation |
|---|---|---|
| net_margin | `<populated-at-live-LLM-run>` | net_income_ttm / revenue_ttm — White-Sondhi-Fried AUFS 3e §1.4 |

> IS-only V0 ratios: NET_MARGIN only (requires REVENUE + NET_INCOME from IS).
> ROE + ROA deferred (require TOTAL_EQUITY + TOTAL_ASSETS from BS; BS not in scope V0 per plan-044 § B).
> PE + EPS computed if EPS present from IS extraction (EPS available in _PDF_CELL_MAP).
>
> Mocked-smoke result: net_margin = 50000 / 100000 = 0.5 (50%) from canned values.

---

## 4. Cost Breakdown (per-call)

> Per-call telemetry from `adapter.call_records` (G.3 _CallRecord dataclass).
> DD-6: ZERO separate cost ledger V0; cost read from adapter.call_records directly.

| Call # | Cells Extracted | Input Tokens | Output Tokens | Cost USD | Wall ms |
|---|---|---|---|---|---|
| 1 | `<populated-at-live-LLM-run>` | `<populated-at-live-LLM-run>` | `<populated-at-live-LLM-run>` | `<populated-at-live-LLM-run>` | `<populated-at-live-LLM-run>` |
| **Total** | `<populated-at-live-LLM-run>` | — | — | `<populated-at-live-LLM-run>` | — |

> Mocked-smoke cost: $0.0000 (canned transport response; no real API call made in tests).
> Live-LLM cost estimate: ~$0.05-0.15 per call × 1-3 calls = ~$0.05-0.45 per run.
> Hard cap: --total-budget-usd=5.00 (DD-5 per plan-044 § A).

---

## 5. EchoValidator Pass-Rate

> Rule 16 mode #2: EchoValidator gate invoked inside G.3 `ClaudeVisionPdfTableExtractor.extract()`
> for every numeric cell per DD-4. If this artifact was written, ALL cells passed
> (EchoValidationError exits with code 2 before artifact is written).

- Cells validated: `<populated-at-live-LLM-run>` (live-LLM run) | 4 (mocked-smoke)
- EchoValidator mismatches: 0 (artifact written = all passed per Rule 16 mode #2)
- Pass-rate: 100% of validated cells

> Mocked-smoke note: canned transport returns pre-validated JSON; EchoValidator
> invoked and passed in `test_echo_validator_gate_invoked_transitively_pass` (D5 test).

---

## 6. Calibration Grade

- **Grade: D** (V0 baseline — no historical hit-rate data)
- Phase: G-prime CODE-READY-DATA-PENDING per parent plan-040 § H.3
- Revisit trigger: n≥20 extracted FS records + Charter Principle 8 calibration regime entry
- Per-adapter accuracy on 10 canonical cells: PENDING (live-LLM dogfood required)
- Gold-set fixture: `tests/fixtures/pdf/expected_cells_vhm.json` (PLACEHOLDER — annotation pending per RM3 note)

---

## 7. Schema Posture (DD-3 K.2.c ADDITIVE-ONLY-DEFAULT)

- **K.2.c flag: NOT-FIRED** — ZERO FinancialStatement schema migration V0
- Provenance preserved in: this artifact (extraction_method + extractor_version + source_pdf_sha256)
- Deferred fields (phase 2 entry): source_pdf_url, source_pdf_page, source_pdf_sha256, extraction_method, extractor_version, extracted_at
- Trigger for migration: BC-9 Outer-Loop consumer requires source_pdf_url/page in citation surface

---

> **Disclaimer (I-S35)**: This is a research aid, not financial advice.
> Decisions and responsibility are yours.
> Numbers come from deterministic code; narrative from LLM interpretation.
> Past performance does not predict future results.
> Calibration grade: D (Phase G-prime V0 — no calibration data yet;
> CODE-READY-DATA-PENDING per plan-044 § H.3).
