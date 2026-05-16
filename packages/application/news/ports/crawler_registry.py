"""CrawlerRegistry — instance-scoped registry of CrawlerAdapter implementations.

Refactored from crawl4ai CrawlerHub (hub.py:37-69) which uses a class-level
``_crawlers: Dict[str, Type[BaseCrawler]]`` dict — a global mutable state that
leaks between test cases (A-02 § 7 anti-pattern flag). This implementation is
instance-scoped: each CLI run or test constructs a fresh registry.

Design decision: DD-5 (plan 020-S337) — instance-scoped beats module-level
singleton because tests can construct fresh registries without monkey-patching.

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § DD-5
        crawl4ai/hub.py:37-69 (CrawlerHub — global-state anti-pattern, refactored)
        agent-workspace/constitution/architecture.md § BC-5
"""

from __future__ import annotations

from packages.application.news.ports.crawler_adapter import CrawlerAdapter

__all__ = ["CrawlerRegistry"]


class CrawlerRegistry:
    """Instance-scoped registry of CrawlerAdapter implementations.

    Usage::

        registry = CrawlerRegistry()
        registry.register(CafeFAdapter(...))
        adapter = registry.get("cafef")  # CrawlerAdapter instance
        adapter.discover("/thi-truong.chn")

    Unlike crawl4ai's global CrawlerHub, this registry is instance-scoped:
    tests construct fresh instances; no inter-test state leak.
    """

    def __init__(self) -> None:
        self._adapters: dict[str, CrawlerAdapter] = {}

    def register(self, adapter: CrawlerAdapter) -> None:
        """Register an adapter under its source_id.

        Args:
            adapter: A CrawlerAdapter instance. Must have a non-empty source_id
                     (enforced by CrawlerAdapter.__init_subclass__ at class-definition).

        Raises:
            ValueError: If an adapter with the same source_id is already registered.
                        Silent override is explicitly rejected — duplicate registration
                        is a programming error, not a runtime condition.
        """
        source_id = adapter.source_id
        if source_id in self._adapters:
            raise ValueError(
                f"Adapter for source_id={source_id!r} is already registered. "
                f"Duplicate registration is a programming error. "
                f"Use a fresh CrawlerRegistry() per run."
            )
        self._adapters[source_id] = adapter

    def get(self, source_id: str) -> CrawlerAdapter:
        """Return the registered adapter for the given source_id.

        Args:
            source_id: The unique source identifier (e.g. ``"cafef"``).

        Returns:
            The registered CrawlerAdapter instance.

        Raises:
            KeyError: If no adapter is registered for source_id.
        """
        try:
            return self._adapters[source_id]
        except KeyError:
            raise KeyError(
                f"No adapter registered for source_id={source_id!r}. "
                f"Registered sources: {sorted(self._adapters)}"
            ) from None

    def list_sources(self) -> list[str]:
        """Return sorted list of registered source_ids.

        Returns:
            Alphabetically sorted list of source_id strings.
        """
        return sorted(self._adapters)
