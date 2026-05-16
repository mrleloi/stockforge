"""BC-5 News infrastructure adapters."""

from .cafef_scraper import CafeFScraper, ScrapedArticle
from .claude_llm_extractor import ClaudeLlmExtractor
from .crawler_adapters import CafeFAdapter, NDHAdapter, VietnamBizAdapter, VietstockAdapter
from .sqlite_news_repository import SqliteClaimRepository, SqliteNewsRepository

__all__ = [
    "CafeFAdapter",
    "CafeFScraper",
    "ClaudeLlmExtractor",
    "NDHAdapter",
    "VietnamBizAdapter",
    "VietstockAdapter",
    "ScrapedArticle",
    "SqliteClaimRepository",
    "SqliteNewsRepository",
]
