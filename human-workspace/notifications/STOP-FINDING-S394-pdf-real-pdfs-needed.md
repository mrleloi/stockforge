---
type: STOP-FINDING
session: S394
created_at: 2026-05-17T00:00:00Z
trigger: RM3-gold-set-sourcing-network-blocked
severity: HIGH
severity_note: "Normalized from IMPLEMENTATION-BLOCKER to HIGH per S397 verifier F4 + L-S397-2 promotion candidate; operational-blocker not charter-tier."
requires_human_decision: true
k2a_status: NOT-FIRED (K.2.a Trigger B cannot be evaluated without real PDFs)
---

# STOP-FINDING: Real PDF Gold-Set Required for Bake-Off Metric 1 Scoring

## Summary

During S394 IMPL, the bake-off probe (D3) was authored and tests (D4) were created,
but real VHM 2023 + HPG 2023 annual report PDFs could NOT be downloaded during the
session due to network restrictions (HTTP 403 + SSL errors from VN IR websites).

**Current state**: synthetic placeholder PDFs (690 bytes each) committed to
`tests/fixtures/pdf/` for structural/contract test purposes only.

**Blocker**: Without real PDFs, Metric 1 (cell-content-exact-match accuracy)
cannot be computed. K.2.a Trigger B (no-clear-winner pivot) cannot be evaluated.
Therefore, the bake-off winner-pick (which unblocks G.2 sub-plan 042) is PENDING.

## What IS complete (committed):

- D1: PdfTableExtractorPort ABC at `packages/application/fundamental/pdf_table_extractor_port.py`
- D2: ExtractedFinancialStatement + PdfSource dataclasses
- D3: Bake-off probe script at `apps/cli/bench/pdf_bake_off.py` (structurally complete; runnable once real PDFs available)
- D4: ABC contract tests (23/23 passing) + SHA256 manifest (placeholder)
- D5: ADR D-080 PROPOSED (winner field = PENDING-real-pdf-required)

## Required Human Action

**Option A (Recommended)**: Manually download real PDFs and commit them:
  1. Download VHM 2023 Annual Report from https://vinhomes.vn IR section
  2. Download HPG 2023 Annual Report from https://hpg.vn IR section
  3. Commit to `tests/fixtures/pdf/` (replacing placeholders)
  4. Update SHA256.txt manifest with real SHA256 values
  5. Manually annotate `expected_cells_vhm.json` + `expected_cells_hpg.json` with
     10 LineItemKey values per document (revenue, net_income, total_assets, etc.)
  6. Run bake-off probe: `python -m apps.cli.bench.pdf_bake_off --pdf-path tests/fixtures/pdf/vhm-2023-annual.pdf --expected-cells tests/fixtures/pdf/expected_cells_vhm.json --library all`
  7. Confirm K.2.a Trigger B status (proceed OR escalate)
  8. Update ADR D-080 winner field from PENDING to actual winner
  9. Dispatch sub-plan 042 (G.2 winner-adapter IMPL)

**Option B**: Git-LFS for large PDFs (if ~3-5 MB binaries not desired in main repo)

**Option C**: Skip bake-off empirical data — pick pdfplumber as default based on
  community evidence (FinceptTerminal cninfo_pdf precedent); document as calibration-grade D.

## Source Evidence
- plan-041 § C STEP 0.2.a: "IF unreachable, fall back to VN company website direct download"
- plan-041 DD-3: gold-set = 2 real public corporate annual report PDFs
- plan-041 RM3: mitigation = (a) public IR attribution + (b) STOP-AND-ASK if download fails
- Network failure log (S394 IMPL): HTTP 403 from vinhomes.vn + SSL error from hpg.vn
