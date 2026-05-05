"""Cross-BC events.

Phase 1 shipped position_value_computed (BC-9). Phase 2 S34 adds
financial_statement_filed (BC-2). Phase 2 S36 adds news_article_ingested +
extracted_claim_published (BC-5). Per architecture.md § Event Flow Phase 2:
synchronous in-process. Phase 3+ adds Redis Streams / Dramatiq for async.
"""

from .extracted_claim_published import ExtractedClaimPublished
from .financial_statement_filed import FinancialStatementFiled
from .news_article_ingested import NewsArticleIngested
from .position_value_computed import PositionValueComputed
from .thesis_recorded import ThesisRecorded

__all__ = [
    "ExtractedClaimPublished",
    "FinancialStatementFiled",
    "NewsArticleIngested",
    "PositionValueComputed",
    "ThesisRecorded",
]
