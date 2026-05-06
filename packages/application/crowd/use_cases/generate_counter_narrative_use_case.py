"""GenerateCounterNarrativeUseCase — UC-4 per spec § B.3 (BC-7).

MANDATORY per BR-6 when bullish_ratio() > 0.8 on considered ticker.
Gates positive signal issuance per I-S13 (counter-narrative mandatory hot-stocks).

Orchestrates:
  1. HistoricalAnalogFinder → failing analogs (subsequent_return_12m < -0.10)
  2. NarrativeRepository.get_bullish_points_for() → bullish consensus
  3. Sector structural risks stub (IMPL-S53-3: BC-3 not wired Phase 3)
  4. CounterNarrativeGeneratorPort → LLM bear points (D-026 patterns)

Verifier grep gate: grep -r "anthropic|openai" packages/application/crowd/use_cases/generate_counter_narrative_use_case.py returns 0

I-S1: numerics come from Python; LLM outputs bear-point prose only.
I-S13: counter-narrative always generated when hot-stock threshold crossed.
BR-6: trigger when SentimentSnapshot.bullish_ratio() > 0.8.
BR-10: CounterNarrative bear_points must not name operators/individuals.

IMPL-S53-3 decision: sector_structural_risks stub returns empty list Phase 3.
  Full BC-3 Company Intelligence cross-BC wiring deferred to Phase 4.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-4.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § g).
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime

from packages.application.crowd.ports.counter_narrative_generator_port import (
    CounterNarrativeGeneratorPort,
)
from packages.application.crowd.ports.counter_narrative_repository_port import (
    CounterNarrativeRepositoryPort,
)
from packages.application.crowd.ports.historical_analog_finder_port import (
    HistoricalAnalog,
    HistoricalAnalogFinderPort,
)
from packages.application.crowd.ports.narrative_repository_port import NarrativeRepositoryPort
from packages.domain.crowd.counter_narrative import CounterNarrative

__all__ = ["CounterNarrativeGeneratedEvent", "GenerateCounterNarrativeUseCase"]

logger = logging.getLogger(__name__)

# BR-6: bullish_ratio threshold for mandatory counter-narrative trigger
_BR6_BULLISH_RATIO_THRESHOLD = 0.8

# D-032 § g: failing analog threshold (subsequent_return_12m < -0.10)
_FAILING_ANALOG_RETURN_THRESHOLD = -0.10


@dataclass(frozen=True)
class CounterNarrativeGeneratedEvent:
    """Event emitted after CounterNarrative is generated and persisted."""

    ticker: str
    trigger: str
    bear_points_count: int
    historical_analogs_count: int
    generated_at: datetime


@dataclass
class GenerateCounterNarrativeUseCase:
    """UC-4: Generate contrarian bear-point analysis when bullish consensus > 80%.

    BR-6 MANDATORY trigger: bullish_ratio() > 0.8.
    IMPL-S53-3: sector_structural_risks returns empty list Phase 3.
    Phase 4: wire to BC-3 Company Intelligence sector risk repo.

    Args:
        counter_narrative_repo: Repository for CounterNarrative aggregates.
        narrative_repo:         Repository for Narrative (bullish points source).
        analog_finder:          HistoricalAnalogFinder for failing analog matching.
        bear_point_generator:   CounterNarrativeGeneratorPort (LLM-backed).
        event_publisher:        Callable to publish events (injectable).
        clock:                  Injectable clock.
    """

    counter_narrative_repo: CounterNarrativeRepositoryPort
    narrative_repo: NarrativeRepositoryPort
    analog_finder: HistoricalAnalogFinderPort
    bear_point_generator: CounterNarrativeGeneratorPort
    event_publisher: Callable[[CounterNarrativeGeneratedEvent], None] = field(
        default_factory=lambda: lambda ev: None  # noqa: ARG005
    )
    clock: Callable[[], datetime] = field(
        default_factory=lambda: lambda: datetime.now(UTC)
    )

    def execute(
        self,
        ticker: str,
        bullish_ratio: float,
        trigger: str = "bullish_ratio_threshold_crossed",
    ) -> CounterNarrative | None:
        """Generate counter-narrative if bullish_ratio > 0.8 (BR-6 mandatory).

        Returns None if bullish_ratio <= threshold (no counter-narrative needed).

        Args:
            ticker:        Stock ticker symbol.
            bullish_ratio: From SentimentSnapshot.bullish_ratio() (Python-computed).
            trigger:       Description of what triggered the generation.
        """
        if bullish_ratio <= _BR6_BULLISH_RATIO_THRESHOLD:
            logger.debug(
                "generate_counter_narrative ticker=%s bullish_ratio=%.2f below threshold=%.2f — skipping",
                ticker,
                bullish_ratio,
                _BR6_BULLISH_RATIO_THRESHOLD,
            )
            return None

        # Gather bullish consensus from active narratives
        bullish_points = self.narrative_repo.get_bullish_points_for(ticker)

        # Find historical analogs
        setup_description = f"ticker={ticker} high_bullish_ratio={bullish_ratio:.2f}"
        analogs = self.analog_finder.find(
            ticker=ticker,
            setup_description=setup_description,
            top_k=5,
        )

        # Filter to failing analogs (subsequent_return_12m < -0.10) per D-032 § g
        failing_analogs: list[HistoricalAnalog] = [
            a for a in analogs
            if a.subsequent_return_12m < _FAILING_ANALOG_RETURN_THRESHOLD
        ]

        # IMPL-S53-3: sector_structural_risks stub — Phase 3 returns empty list
        # Phase 4 TODO: wire to BC-3 Company Intelligence cross-BC contract
        structural_risks: list[str] = []

        # LLM bear-point generation (D-026 BP-S43b-1/2/3; gatherer-wired inputs)
        bear_points = self.bear_point_generator.generate(
            ticker=ticker,
            bullish_consensus=bullish_points,
            failing_analogs=failing_analogs,
            structural_risks=structural_risks,
        )

        now = self.clock()
        counter = CounterNarrative(
            ticker=ticker,
            generated_at=now,
            trigger=trigger,
            bear_points=tuple(bear_points),
            historical_analogs=tuple(analogs),
            failing_analog_details=tuple(failing_analogs),
            bullish_consensus_summary=tuple(bullish_points),
        )

        self.counter_narrative_repo.save(counter)

        event = CounterNarrativeGeneratedEvent(
            ticker=ticker,
            trigger=trigger,
            bear_points_count=len(bear_points),
            historical_analogs_count=len(analogs),
            generated_at=now,
        )
        self.event_publisher(event)

        logger.info(
            "generate_counter_narrative ticker=%s bullish_ratio=%.2f "
            "bear_points=%d analogs=%d failing_analogs=%d structural_risks=%d",
            ticker,
            bullish_ratio,
            len(bear_points),
            len(analogs),
            len(failing_analogs),
            len(structural_risks),
        )

        return counter
