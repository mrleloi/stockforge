"""BC-5 News entities."""

from .extracted_claim import ExtractedClaim, ExtractedClaimInvariantError
from .news_article import NewsArticle, NewsArticleInvariantError

__all__ = [
    "ExtractedClaim",
    "ExtractedClaimInvariantError",
    "NewsArticle",
    "NewsArticleInvariantError",
]
