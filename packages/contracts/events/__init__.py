"""Cross-BC events.

Phase 1 shipped position_value_computed (BC-9). Phase 2 S34 adds
financial_statement_filed (BC-2). Phase 2 S36 adds news_article_ingested +
extracted_claim_published (BC-5). Per architecture.md § Event Flow Phase 2:
synchronous in-process. Phase 3+ adds Redis Streams / Dramatiq for async.
Phase 3 BC-7 S52 adds coordinated_posting_detected + sentiment_snapshot_captured.
Phase 3 BC-7 S53 adds narrative_phase_changed + pump_phase_detected + counter_narrative_generated.
"""

from .coordinated_posting_detected import CoordinatedPostingDetected
from .counter_narrative_generated import CounterNarrativeGenerated
from .credibility_score_updated import CredibilityScoreUpdated
from .extracted_claim_published import ExtractedClaimPublished
from .financial_statement_filed import FinancialStatementFiled
from .narrative_phase_changed import NarrativePhaseChanged
from .news_article_ingested import NewsArticleIngested
from .outcome_review_completed import OutcomeReviewCompleted
from .position_value_computed import PositionValueComputed
from .pump_phase_detected import PumpPhaseDetected
from .sentiment_snapshot_captured import SentimentSnapshotCaptured
from .thesis_recorded import ThesisRecorded

__all__ = [
    "CoordinatedPostingDetected",
    "CounterNarrativeGenerated",
    "CredibilityScoreUpdated",
    "ExtractedClaimPublished",
    "FinancialStatementFiled",
    "NarrativePhaseChanged",
    "NewsArticleIngested",
    "OutcomeReviewCompleted",
    "PositionValueComputed",
    "PumpPhaseDetected",
    "SentimentSnapshotCaptured",
    "ThesisRecorded",
]
