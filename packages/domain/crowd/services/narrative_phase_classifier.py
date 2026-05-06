"""NarrativePhaseClassifier — deterministic 7-state narrative phase machine (BC-7).

DETERMINISTIC ONLY — ZERO LLM IMPORTS IN THIS MODULE.
Verifier grep gate: grep -r "anthropic|openai|claude_llm" packages/domain/crowd/services/ returns 0.

Per D-032 § (e) + spec § B.3 UC-2 lines 301-333:
  7-phase machine: INCUBATION → EMERGING → MAINSTREAM → SATURATION → EXHAUSTION → REVERSAL → DEAD.

Rule verbatim from spec § B.3 lines 301-333:
  INCUBATION:   avg_mentions_per_day < 5 AND unique_sources < 3
  EMERGING:     velocity_trend == "ACCELERATING" AND major_source_share < 0.2
  MAINSTREAM:   major_source_share >= 0.3 AND kol_mention_count >= 3
  SATURATION:   MAINSTREAM context AND bullish_ratio >= 0.8 AND new_unique_posters_trend == "DECELERATING"
  EXHAUSTION:   avg_mentions_per_day >= 20 AND velocity_trend == "DECELERATING"
  REVERSAL:     counter_narrative_velocity > velocity * 0.3
  DEAD:         avg_mentions_per_day < 1

Thresholds tunable via NarrativePhaseClassifierConfig dataclass.
Default values match spec § B.3 verbatim; tuning deferred to Year 2 outer-loop activation per spec 005.

I-10: ZERO framework dependency (pure Python + stdlib).
I-S1: NO LLM math. All inputs are Python-computed NarrativeMetrics.
§ B.8 bootstrap test: same metrics → identical classification (pure-Python determinism guaranteed).

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-2 lines 301-333.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § e).
"""

from __future__ import annotations

from dataclasses import dataclass

from packages.domain.crowd.value_objects.narrative_phase import NarrativePhase

__all__ = [
    "NarrativeMetrics",
    "NarrativePhaseClassifier",
    "NarrativePhaseClassifierConfig",
]

# Spec § B.3 UC-2 lines 301-333 default threshold values
_DEFAULT_INCUBATION_MAX_MENTIONS = 5.0        # avg_mentions_per_day < 5
_DEFAULT_INCUBATION_MAX_SOURCES = 3           # unique_sources < 3
_DEFAULT_EMERGING_MAX_SOURCE_SHARE = 0.2     # major_source_share < 0.2
_DEFAULT_MAINSTREAM_MIN_SOURCE_SHARE = 0.3   # major_source_share >= 0.3
_DEFAULT_MAINSTREAM_MIN_KOL = 3              # kol_mention_count >= 3
_DEFAULT_SATURATION_BULLISH_RATIO = 0.8      # bullish_ratio >= 0.8
_DEFAULT_EXHAUSTION_MIN_MENTIONS = 20.0      # avg_mentions_per_day >= 20
_DEFAULT_REVERSAL_COUNTER_VELOCITY_FRACTION = 0.3  # counter_narrative_velocity > velocity * 0.3
_DEFAULT_DEAD_MAX_MENTIONS = 1.0             # avg_mentions_per_day < 1


@dataclass
class NarrativeMetrics:
    """Input metrics for NarrativePhaseClassifier.

    All fields are Python-computed (I-S1: never from LLM).
    Computed from recent SentimentSnapshot + crowd data aggregation.
    """

    avg_mentions_per_day: float
    unique_sources: int
    velocity_trend: str               # "ACCELERATING" | "DECELERATING" | "STABLE"
    major_source_share: float         # fraction of mentions from major news/broker
    kol_mention_count: int
    bullish_ratio: float              # from SentimentSnapshot.bullish_ratio()
    new_unique_posters_trend: str     # "ACCELERATING" | "DECELERATING" | "STABLE"
    velocity: float                   # current posts/hour
    counter_narrative_velocity: float  # counter-posts per hour


@dataclass
class NarrativePhaseClassifierConfig:
    """Tunable thresholds for NarrativePhaseClassifier.

    Default values match spec § B.3 UC-2 lines 301-333 verbatim.
    Weight tuning deferred to Year 2 outer-loop activation per spec 005.
    """

    incubation_max_mentions: float = _DEFAULT_INCUBATION_MAX_MENTIONS
    incubation_max_sources: int = _DEFAULT_INCUBATION_MAX_SOURCES
    emerging_max_source_share: float = _DEFAULT_EMERGING_MAX_SOURCE_SHARE
    mainstream_min_source_share: float = _DEFAULT_MAINSTREAM_MIN_SOURCE_SHARE
    mainstream_min_kol: int = _DEFAULT_MAINSTREAM_MIN_KOL
    saturation_bullish_ratio: float = _DEFAULT_SATURATION_BULLISH_RATIO
    exhaustion_min_mentions: float = _DEFAULT_EXHAUSTION_MIN_MENTIONS
    reversal_counter_velocity_fraction: float = _DEFAULT_REVERSAL_COUNTER_VELOCITY_FRACTION
    dead_max_mentions: float = _DEFAULT_DEAD_MAX_MENTIONS


class NarrativePhaseClassifier:
    """Deterministic 7-state narrative phase machine.

    I-S1: DETERMINISTIC pure-Python. NO LLM.
    § B.8 bootstrap test: run same metrics twice → identical NarrativePhase result.
    """

    def __init__(
        self,
        config: NarrativePhaseClassifierConfig | None = None,
    ) -> None:
        self.config = config if config is not None else NarrativePhaseClassifierConfig()

    def classify(
        self, metrics: NarrativeMetrics, current: NarrativePhase
    ) -> NarrativePhase:
        """Return the NarrativePhase best matching current metrics.

        Rules verbatim from spec § B.3 UC-2 lines 301-333.
        Returns `current` when no rule matches (no phase change).

        I-S1: pure Python; no randomness; deterministic for same inputs.
        """
        cfg = self.config

        # INCUBATION: low mentions, isolated sources
        if (
            metrics.avg_mentions_per_day < cfg.incubation_max_mentions
            and metrics.unique_sources < cfg.incubation_max_sources
        ):
            return NarrativePhase.INCUBATION

        # EMERGING: mentions rising fast, still <20% from major sources
        if (
            metrics.velocity_trend == "ACCELERATING"
            and metrics.major_source_share < cfg.emerging_max_source_share
        ):
            return NarrativePhase.EMERGING

        # MAINSTREAM: major news + broker coverage + KOL attention
        # Distinguish MAINSTREAM vs SATURATION
        if (
            metrics.major_source_share >= cfg.mainstream_min_source_share
            and metrics.kol_mention_count >= cfg.mainstream_min_kol
        ):
            if (
                metrics.bullish_ratio >= cfg.saturation_bullish_ratio
                and metrics.new_unique_posters_trend == "DECELERATING"
            ):
                return NarrativePhase.SATURATION
            return NarrativePhase.MAINSTREAM

        # EXHAUSTION: high mentions but declining velocity
        if (
            metrics.avg_mentions_per_day >= cfg.exhaustion_min_mentions
            and metrics.velocity_trend == "DECELERATING"
        ):
            return NarrativePhase.EXHAUSTION

        # REVERSAL: counter-narratives emerging
        if metrics.counter_narrative_velocity > metrics.velocity * cfg.reversal_counter_velocity_fraction:
            return NarrativePhase.REVERSAL

        # DEAD: almost no mentions
        if metrics.avg_mentions_per_day < cfg.dead_max_mentions:
            return NarrativePhase.DEAD

        # No rule matched — no phase change
        return current
