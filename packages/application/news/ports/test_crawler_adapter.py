"""Tests for CrawlerAdapter ABC + CrawlerRegistry (plan 020 DC-D1-4).

Covers:
1. Abstract methods cannot be instantiated directly.
2. Subclass missing source_id raises TypeError at class-creation time.
3. Subclass with empty source_id raises TypeError.
4. Subclass with valid source_id instantiates.
5. Registry register accepts adapter, get returns it by source_id.
6. Registry get unknown raises KeyError.
7. Registry register duplicate source_id raises.
8. Registry list_sources returns sorted list.
"""

from __future__ import annotations

from collections.abc import Iterable

import pytest

from packages.application.news.ports.crawler_adapter import CrawlerAdapter
from packages.application.news.ports.crawler_registry import CrawlerRegistry
from packages.contracts import Ticker
from packages.domain.news.models import NewsArticle
from packages.infrastructure.news.cafef_scraper import ScrapedArticle

# ---------------------------------------------------------------------------
# Concrete test adapter (valid)
# ---------------------------------------------------------------------------


class _ValidAdapter(CrawlerAdapter):
    source_id = "test_source"

    def discover(self, _listing_path: str, _max_articles: int = 50) -> list[str]:
        return []

    def fetch_and_parse(self, _url: str) -> ScrapedArticle | None:
        return None

    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
    ) -> NewsArticle:
        raise NotImplementedError


class _AnotherAdapter(CrawlerAdapter):
    source_id = "another_source"

    def discover(self, _listing_path: str, _max_articles: int = 50) -> list[str]:
        return []

    def fetch_and_parse(self, _url: str) -> ScrapedArticle | None:
        return None

    def to_news_article(
        self,
        scraped: ScrapedArticle,
        ticker_universe: Iterable[Ticker],
    ) -> NewsArticle:
        raise NotImplementedError


# ---------------------------------------------------------------------------
# Test 1: Abstract methods cannot be instantiated directly
# ---------------------------------------------------------------------------


def test_crawler_adapter_cannot_be_instantiated_directly() -> None:
    """CrawlerAdapter ABC cannot be instantiated — abstract methods block it."""
    # We need to bypass __init_subclass__ by checking TypeError on instantiation
    # of a concrete but incomplete subclass.
    # Actually, the ABC itself raises TypeError on any direct instantiation attempt:
    # Note: we patch source_id to avoid __init_subclass__ TypeError first.
    # The simplest test: creating a subclass that is abstract (no implementation).

    # We can't define a class with missing source_id without triggering __init_subclass__,
    # so instead we test that _ValidAdapter (concrete) can be instantiated but
    # a class missing abstract method implementation cannot.
    with pytest.raises(TypeError, match="Can't instantiate abstract class"):
        # type: ignore[abstract]
        CrawlerAdapter()  # type: ignore[abstract]


# ---------------------------------------------------------------------------
# Test 2: Subclass missing source_id raises TypeError at class-creation time
# ---------------------------------------------------------------------------


def test_subclass_missing_source_id_raises_type_error_at_definition() -> None:
    """A subclass that declares no source_id raises TypeError at class-definition time."""
    with pytest.raises(TypeError, match="must declare a non-empty source_id"):

        class _MissingId(CrawlerAdapter):  # TypeError fires here
            def discover(self, _listing_path: str, _max_articles: int = 50) -> list[str]:
                return []

            def fetch_and_parse(self, _url: str) -> ScrapedArticle | None:
                return None

            def to_news_article(
                self,
                scraped: ScrapedArticle,
                ticker_universe: Iterable[Ticker],
            ) -> NewsArticle:
                raise NotImplementedError


# ---------------------------------------------------------------------------
# Test 3: Subclass with empty source_id raises TypeError
# ---------------------------------------------------------------------------


def test_subclass_with_empty_source_id_raises_type_error() -> None:
    """A subclass with source_id = '' raises TypeError at class-definition time."""
    with pytest.raises(TypeError, match="must declare a non-empty source_id"):

        class _EmptyId(CrawlerAdapter):
            source_id = "   "  # whitespace-only also rejected via .strip()

            def discover(self, _listing_path: str, _max_articles: int = 50) -> list[str]:
                return []

            def fetch_and_parse(self, _url: str) -> ScrapedArticle | None:
                return None

            def to_news_article(
                self,
                scraped: ScrapedArticle,
                ticker_universe: Iterable[Ticker],
            ) -> NewsArticle:
                raise NotImplementedError


# ---------------------------------------------------------------------------
# Test 4: Subclass with valid source_id instantiates successfully
# ---------------------------------------------------------------------------


def test_subclass_with_valid_source_id_instantiates() -> None:
    """A subclass with a non-empty source_id instantiates without error."""
    adapter = _ValidAdapter()
    assert adapter.source_id == "test_source"


# ---------------------------------------------------------------------------
# Test 5: Registry register + get by source_id
# ---------------------------------------------------------------------------


def test_registry_register_and_get_by_source_id() -> None:
    """Registering an adapter allows retrieval by source_id."""
    registry = CrawlerRegistry()
    adapter = _ValidAdapter()
    registry.register(adapter)
    result = registry.get("test_source")
    assert result is adapter


# ---------------------------------------------------------------------------
# Test 6: Registry get unknown raises KeyError
# ---------------------------------------------------------------------------


def test_registry_get_unknown_raises_key_error() -> None:
    """Getting an unregistered source_id raises KeyError."""
    registry = CrawlerRegistry()
    with pytest.raises(KeyError, match="No adapter registered for source_id"):
        registry.get("nonexistent_source")


# ---------------------------------------------------------------------------
# Test 7: Registry register duplicate raises ValueError
# ---------------------------------------------------------------------------


def test_registry_register_duplicate_source_id_raises() -> None:
    """Registering a second adapter with the same source_id raises ValueError."""
    registry = CrawlerRegistry()
    registry.register(_ValidAdapter())
    with pytest.raises(ValueError, match="already registered"):
        registry.register(_ValidAdapter())


# ---------------------------------------------------------------------------
# Test 8: Registry list_sources returns sorted list
# ---------------------------------------------------------------------------


def test_registry_list_sources_returns_sorted() -> None:
    """list_sources returns alphabetically sorted source_id list."""
    registry = CrawlerRegistry()
    registry.register(_AnotherAdapter())
    registry.register(_ValidAdapter())
    sources = registry.list_sources()
    assert sources == ["another_source", "test_source"]


# ---------------------------------------------------------------------------
# Additional: empty registry list_sources
# ---------------------------------------------------------------------------


def test_registry_list_sources_empty() -> None:
    """list_sources returns empty list when no adapters are registered."""
    registry = CrawlerRegistry()
    assert registry.list_sources() == []


# ---------------------------------------------------------------------------
# Additional: source_id attribute accessible on class and instance
# ---------------------------------------------------------------------------


def test_source_id_accessible_on_class_and_instance() -> None:
    """source_id is accessible both as class attribute and instance attribute."""
    assert _ValidAdapter.source_id == "test_source"
    assert _ValidAdapter().source_id == "test_source"
