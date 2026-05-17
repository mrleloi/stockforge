"""apps/extraction/sentiment — VN sentiment lexicon scoring (Phase E.2)."""

from .vn_lexicon import (
    VN_CULTURAL_ANCHORS,
    VN_SENTIMENT_LEXICON_VERSION,
    SentimentScore,
    VnSentimentLexicon,
)

__all__ = [
    "SentimentScore",
    "VN_CULTURAL_ANCHORS",
    "VN_SENTIMENT_LEXICON_VERSION",
    "VnSentimentLexicon",
]
