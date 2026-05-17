"""BC-2 Fundamental Data — application layer ports.

This package contains application-layer ABC ports and intermediate value objects
for the BC-2 Fundamental Data bounded context.

Phase G-prime sub-plan 041 (S394 IMPL):
- PdfTableExtractorPort — Strategy ABC for per-library PDF table extractors
- PdfSource — value object encapsulating ABC input (PDF path + provenance)
- ExtractedFinancialStatement — intermediate dataclass (raw cells + provenance)

Source: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md § D1
        agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md
"""
