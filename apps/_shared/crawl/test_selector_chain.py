"""Tests for SelectorChain (plan 020 DC-D2-3).

Covers (≥6 per spec):
1. First strategy hit — returns immediately.
2. Fallback through chain — skips None, returns second.
3. All-fail returns None + logs warning.
4. Counter is accurate (num_strategies_tried).
5. Label is recorded in return.
6. Empty chain → None.
"""

from __future__ import annotations

import logging

import pytest

from apps._shared.crawl.selector_chain import SelectorChain


def test_selector_chain_first_strategy_hit() -> None:
    """When the first strategy succeeds, result is returned immediately."""
    calls: list[int] = []

    def s1() -> str | None:
        calls.append(1)
        return "found"

    def s2() -> str | None:
        calls.append(2)
        return "fallback"

    chain: SelectorChain[str] = SelectorChain(strategies=[s1, s2], label="test")
    result, tried = chain.apply()
    assert result == "found"
    assert tried == 1
    assert calls == [1]  # s2 was never called


def test_selector_chain_fallback_through() -> None:
    """When first strategy returns None, second strategy is tried."""
    chain: SelectorChain[str] = SelectorChain(
        strategies=[lambda: None, lambda: "fallback"],
        label="body_container",
    )
    result, tried = chain.apply()
    assert result == "fallback"
    assert tried == 2


def test_selector_chain_all_fail_returns_none() -> None:
    """When all strategies return None, result is None."""
    chain: SelectorChain[str] = SelectorChain(
        strategies=[lambda: None, lambda: None, lambda: None],
        label="missing_selector",
    )
    result, tried = chain.apply()
    assert result is None
    assert tried == 3


def test_selector_chain_counter_is_accurate() -> None:
    """num_strategies_tried exactly counts how many strategies were attempted."""
    chain: SelectorChain[str] = SelectorChain(
        strategies=[lambda: None, lambda: None, lambda: "hit"],
        label="counter_test",
    )
    result, tried = chain.apply()
    assert result == "hit"
    assert tried == 3  # tried all three: 1 + 2 failed, 3 hit


def test_selector_chain_label_is_accessible() -> None:
    """The label attribute is stored and accessible."""
    chain: SelectorChain[str] = SelectorChain(
        strategies=[lambda: "x"],
        label="my_selector",
    )
    assert chain.label == "my_selector"
    result, _ = chain.apply()
    assert result == "x"


def test_selector_chain_empty_chain_returns_none() -> None:
    """An empty strategies list returns (None, 0)."""
    chain: SelectorChain[str] = SelectorChain(strategies=[], label="empty")
    result, tried = chain.apply()
    assert result is None
    assert tried == 0


def test_selector_chain_exception_in_strategy_is_skipped() -> None:
    """If a strategy raises an exception, it is caught and the next is tried."""

    def broken() -> str | None:
        raise RuntimeError("selector error")

    chain: SelectorChain[str] = SelectorChain(
        strategies=[broken, lambda: "recovered"],
        label="exception_chain",
    )
    result, tried = chain.apply()
    assert result == "recovered"
    assert tried == 2


def test_selector_chain_logs_warning_on_all_fail(caplog: pytest.LogCaptureFixture) -> None:
    """A WARNING is logged when all strategies fail."""
    chain: SelectorChain[str] = SelectorChain(
        strategies=[lambda: None],
        label="warn_me",
    )
    with caplog.at_level(logging.WARNING, logger="apps._shared.crawl.selector_chain"):
        result, _ = chain.apply()
    assert result is None
    assert any("all" in msg.lower() and "fail" in msg.lower() for msg in caplog.messages)
