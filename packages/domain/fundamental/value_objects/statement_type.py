"""StatementType — VN financial-statement category enum.

Per spec-T1-001 § B.1 FinancialStatement schema: three statement classes
recognised by VAS (Vietnamese Accounting Standards) corresponding to IFRS
counterparts. Phase 2 thin slice covers all three; Phase 3 may extend with
NOTES (notes-to-statements) when claim extraction wants line-item context
beyond the headline numbers.

`str` mixin renders the lowercase token in JSON / TSV serialization, matching
AdjustmentType / SourceProvider precedent in packages/contracts/types/.
"""

from __future__ import annotations

from enum import StrEnum

__all__ = ["StatementType"]


class StatementType(StrEnum):
    """Filing class for a FinancialStatement.

    IS = Income Statement / Báo cáo kết quả kinh doanh
    BS = Balance Sheet    / Bảng cân đối kế toán
    CF = Cash Flow        / Báo cáo lưu chuyển tiền tệ
    """

    IS = "is"
    BS = "bs"
    CF = "cf"
