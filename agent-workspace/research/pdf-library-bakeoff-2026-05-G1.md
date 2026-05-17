# PDF Table Extraction Library Bake-Off — Phase G.1 Empirical Report

**Session**: S394 (sandwich-dev FOCUSED_IMPL plan-041)
**Date**: 2026-05-17
**Status**: PARTIAL — real PDF sourcing blocked by network; re-run required

---

## Library-by-Library 4-Metric Grid

| Library | Metric 1 (accuracy) | Metric 2 (p50 wall-time) | Metric 3 (deps) | Metric 4 (license) |
|---------|---------------------|--------------------------|-----------------|---------------------|
| pdfplumber | PENDING-real-pdf | PENDING | PENDING | MIT (OK) |
| docling | PENDING-real-pdf | PENDING | PENDING | MIT (OK) |
| pypdf | PENDING-real-pdf | PENDING | PENDING | BSD-3-Clause (OK) |
| pymupdf | EXCLUDED | N/A | N/A | AGPL-3.0 (EXCLUDED) |

**Note**: Metric 1 (cell-content-exact-match accuracy) requires real VHM 2023 + HPG 2023 annual
report PDFs with manually-annotated ground-truth cells. These PDFs could not be downloaded during
S394 IMPL (network restrictions; HTTP 403 + SSL errors). See RM3 blocker documentation below.

---

## STEP 0.1 License Re-Verification (executed at S394 entry)

| Library | SPDX | Proprietary-compatible | Repository |
|---------|------|------------------------|------------|
| pdfplumber | MIT | YES | https://github.com/jsvine/pdfplumber |
| camelot-py | MIT | YES | https://github.com/camelot-dev/camelot |
| docling | MIT | YES | https://github.com/DS4SD/docling |
| pypdf | BSD-3-Clause | YES | https://github.com/py-pdf/pypdf |
| pymupdf | AGPL-3.0 | **NO** | https://github.com/pymupdf/PyMuPDF |

**STEP 0.1.b pymupdf license check**: pymupdf remains AGPL-3.0 as of 2026-05-17.
K.2.a Trigger A (license escalation) = **NOT FIRED**.

---

## K.2.a STOP-AND-ASK Trigger Evaluation

**Trigger A (pymupdf license escalation)**: NOT FIRED — pymupdf still AGPL-3.0.

**Trigger B (no-clear-winner pivot)**: CANNOT EVALUATE — real PDF gold-set required.

**Status**: K.2.a trigger evaluation PENDING real PDF provision.
Action required: see `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md`.

---

## RM3 Blocker — Gold-Set Sourcing

**Root cause**: Network restrictions blocked download of VHM 2023 + HPG 2023 annual report PDFs
from public Vietnamese IR websites during S394 IMPL session.

**Attempted URLs**:
- https://vinhomes.vn/sites/default/files/documents/BaoCaoThuongNien2023_VHM.pdf → HTTP 403
- https://static2.vietstock.vn/vietstock/2024/4/8/Vinhomes_BCTN_2023.pdf → HTTP 404
- https://ir.vinhomes.vn/wp-content/uploads/2024/03/Vinhomes-Annual-Report-2023.pdf → DNS fail
- https://www.hpg.vn/Data/Sites/1/media/investor-relations/annual-reports/2023/HPG-Annual-Report-2023.pdf → SSL error
- https://hpg.vn/Data/Sites/1/media/investor-relations/bao-cao-thuong-nien/hpg-bctn-2023.pdf → SSL error

**Current state**: Synthetic placeholder PDFs (690 bytes each, no real financial data) committed
at `tests/fixtures/pdf/` for structural/contract test purposes only.

**Mitigation path**: Human manually downloads real PDFs from VHM and HPG IR sections, commits
to `tests/fixtures/pdf/`, annotates `expected_cells_*.json`, and re-runs probe.

---

## Winner Ratification (PENDING)

**Winner**: PENDING-real-pdf-required

**Rationale for selection**: Cannot ratify without Metric 1 empirical scores from real PDFs.

**Community evidence (supplementary, NOT pick-deciding)**:
- pdfplumber is widely referenced for financial PDF extraction in open-source VN finance tools
- FinceptTerminal cninfo_pdf_text_extractor.py:45-60 uses pypdf as text-only baseline
- docling shows strong layout-aware parsing of financial tables in IBM's own benchmarks

**Expected winner hypothesis** (pre-empirical; to be validated):
- pdfplumber + camelot most likely wins on structured digital PDFs (VHM/HPG are digital)
- docling likely wins on complex layout + OCR-mixed PDFs
- pypdf will score lowest (text-only, no table structure) unless VN PDFs have tab-delimited text

---

## Adversarial Alternates Rejected

**pymupdf (AGPL-3.0)**:
- Rejected: AGPL-3.0 incompatible with pyproject.toml license="Proprietary"
- Revisit trigger: K.2.a STOP-AND-ASK if license changes to BSD/MIT/Apache

**unstructured**:
- Rejected: heavy dep stack (similar to crawl4ai wholesale-port concern; A-02 § 5)
- Revisit trigger: If all 3 primary candidates fail accuracy gate (<70%)

**Claude vision API direct (not via claude CLI substrate)**:
- Rejected: anthropic_api_to_subagent memory rule violation
- Proper path: G.3 sub-plan 043 via claude CLI substrate (D-072 BC-5 precedent)

---

## AP-7 Named Revisit Triggers per Non-Winner

| Library | Current status | Revisit trigger |
|---------|---------------|-----------------|
| pymupdf | EXCLUDED (AGPL-3.0) | License changes to BSD/MIT/Apache AND score > winner by >=10 pp |
| docling | PENDING-eval | Re-run after real PDFs available; LIKELY revisit at Phase G-prime-V2 if broker-report PDFs surface accuracy drift |
| pypdf | PENDING-eval | Re-run after real PDFs available; if table-structure scores low -> deprioritize |
| pdfplumber | PENDING-eval | Re-run after real PDFs available |

---

## Probe Reproducibility Instructions

Once real PDFs are available:

```bash
# Step 1: Set up isolated venv (per DD-8 -- NOT in stockforge pyproject.toml)
python -m venv .venv-pdf-bakeoff
.venv-pdf-bakeoff/Scripts/activate  # Windows
# source .venv-pdf-bakeoff/bin/activate  # Linux/Mac

# Step 2: Install all 3 candidate libraries
pip install pdfplumber camelot-py docling pypdf

# Step 3: Add PDF fixtures (manually downloaded real annual reports)
# Replace tests/fixtures/pdf/vhm-2023-annual.pdf with real VHM 2023 Annual Report
# Replace tests/fixtures/pdf/hpg-2023-annual.pdf with real HPG 2023 Annual Report
# Update tests/fixtures/pdf/SHA256.txt with real SHA256 values
# Annotate tests/fixtures/pdf/expected_cells_vhm.json + expected_cells_hpg.json

# Step 4: Run probe against both gold-set PDFs
python -m apps.cli.bench.pdf_bake_off \
    --pdf-path tests/fixtures/pdf/vhm-2023-annual.pdf \
    --expected-cells tests/fixtures/pdf/expected_cells_vhm.json \
    --library all --runs 3

python -m apps.cli.bench.pdf_bake_off \
    --pdf-path tests/fixtures/pdf/hpg-2023-annual.pdf \
    --expected-cells tests/fixtures/pdf/expected_cells_hpg.json \
    --library all --runs 3

# Step 5: Review SUMMARY table + K.2.a evaluation output
# Step 6: Update ADR D-080 winner field if K.2.a NOT fired
# Step 7: Dispatch G.2 sub-plan 042 with winner library
```

---

## Source Evidence

1. `agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md` § D3 + § C STEP 0
2. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` § D DD-4 (4-metric grid)
3. `apps/cli/bench/pdf_bake_off.py` (probe script; authored S394)
4. `tests/fixtures/pdf/SHA256.txt` (manifest; placeholder state documented)
5. `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md` (RM3 blocker)
6. PyPI license records (accessed S394 2026-05-17): pdfplumber MIT / docling MIT / pypdf BSD-3-Clause / pymupdf AGPL-3.0
7. `packages/domain/fundamental/value_objects/line_item.py:33-45` (10 LineItemKey = scoring basis)
