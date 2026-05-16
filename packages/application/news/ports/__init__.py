"""BC-5 News application ports."""

from .crawler_adapter import CrawlerAdapter
from .crawler_registry import CrawlerRegistry
from .llm_extractor_port import LlmExtractorPort

__all__ = ["CrawlerAdapter", "CrawlerRegistry", "LlmExtractorPort"]
