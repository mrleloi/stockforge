"""SelectorChain — fallback-chain helper per crawler-reliability skill.

No port — fresh implementation of the pattern documented in
.claude/skills/crawler-reliability/SKILL.md § Selector Robustness:
    "try multiple strategies, return first non-empty result, log warning if all
    fail and return None. Don't raise — partial output beats whole-pipeline halt."

Applies the docstring from plan 020 § Sub-track D2 SelectorChain shape.

D-059 compliance:
- R1 (datetime-no-tz): no datetime usage.
- R2 (unseeded RNG): no RNG usage.
- R4 (time.time-in-domain): no time.time.

Source: plan 020-S337-phase-d-theme-l-crawling-adapter.md § Sub-track D2
        .claude/skills/crawler-reliability/SKILL.md § Selector Robustness
"""

from __future__ import annotations

import logging
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Generic, TypeVar

__all__ = ["SelectorChain"]

T = TypeVar("T")

_log = logging.getLogger(__name__)


@dataclass(frozen=True, slots=True)
class SelectorChain(Generic[T]):
    """Apply each strategy in order; return first non-None result.

    Counts strategy attempts for shape-metrics emit (deferred to Phase 3
    calibration data per plan 020 § Out-of-scope item 12; currently logged only).

    Usage::

        chain: SelectorChain[Tag | None] = SelectorChain(
            strategies=[
                lambda: soup.find("div", class_="detail-content"),
                lambda: soup.find("div", class_="contentdetail"),
                lambda: soup.find("article"),
            ],
            label="body_container",
        )
        result, n_tried = chain.apply()
        if result is None:
            # all strategies failed — caller handles None (L-S28-1 degrade gracefully)
            ...

    Type parameter ``T`` is the result type (e.g. ``Tag | NavigableString`` from
    BeautifulSoup, or ``str``). Strategies return ``T | None``; first non-None wins.

    Note on SelectorChain[T] fields: ``strategies`` is a Sequence of callables
    and ``label`` is a str — no numeric fields. Rule 16 N/A.
    """

    strategies: Sequence[Callable[[], T | None]]
    """Ordered list of selector callables. Each returns T or None."""

    label: str = "(unnamed)"
    """Human-readable label for logging. Used in warning messages when all fail."""

    def apply(self) -> tuple[T | None, int]:
        """Run strategies in order; return (first non-None result, strategies tried).

        Returns:
            A 2-tuple:
            - result: First non-None value returned by any strategy, or None if all failed.
            - num_strategies_tried: Number of strategies executed (1 if first hit,
              len(strategies) if all failed or all returned None).

        Logs a WARNING if all strategies fail (result is None) per skill doctrine:
        "partial output beats whole-pipeline halt".

        Note: ``num_strategies_tried`` is an internal counter — not an LLM-emitted
        field. Rule 16 scope per plan 020 § Schema discipline: internal infra
        counters are out-of-scope.
        """
        tried = 0
        for strategy in self.strategies:
            tried += 1
            try:
                result = strategy()
            except Exception as exc:
                _log.debug(
                    "selector_chain: label=%r strategy #%d raised %s",
                    self.label, tried, exc,
                )
                continue
            if result is not None:
                _log.debug(
                    "selector_chain: label=%r hit on strategy #%d", self.label, tried
                )
                return result, tried

        _log.warning(
            "selector_chain: label=%r all %d strategies failed — returning None",
            self.label, tried,
        )
        return None, tried
