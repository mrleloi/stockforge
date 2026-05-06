"""PumpPhaseClassifier — deterministic 5-state pump phase weighted scorer (BC-7).

DETERMINISTIC ONLY — ZERO LLM IMPORTS IN THIS MODULE.
Verifier grep gate: grep -r "anthropic|openai|claude_llm" packages/domain/crowd/services/ returns 0.

Per D-032 § (f) + spec § B.3 UC-3 lines 379-423:
  5-state classifier: PRE_PUMP / PUMP / DISTRIBUTION / DUMP / UNCERTAIN.

Scoring signals verbatim from spec § B.3 lines 386-422:
  PRE_PUMP:
    quiet_accumulation: price_change_30d < 0.10 AND volume_30d_avg_rising → +0.3
    kol_whispers_no_news: t3_kol_mentions_rising AND t2_news_silent → +0.3
  PUMP:
    volume_price_spike: price_5d_change > 0.20 AND volume_5d_avg/volume_30d_avg > 3 → +0.4
    fomo_active: t3_kol_mentions_peak AND t4_novice_post_share > 0.5 → +0.3
  DISTRIBUTION:
    volume_without_price: volume_5d_avg/volume_30d_avg > 2 AND abs(price_5d_change) < 0.05 → +0.4
    novice_fomo_dominant: t4_novice_post_share > 0.7 AND t4_coordination_score < 0.3 → +0.3
  DUMP:
    price_crash_volume_decline: price_5d_change < -0.15 AND volume_5d_avg_declining → +0.5

Confidence gate: if best_phase score < 0.4 → returns UNCERTAIN per spec line 418.
BR-9: if no historical_similar_cases → confidence capped at 0.6 per "novel pattern" framing.

I-10: ZERO framework dependency (pure Python + stdlib).
I-S1: NO LLM math. Weighted scoring uses only Python arithmetic on Python-computed inputs.
§ B.8 bootstrap test: same signals → identical (PumpPhase, confidence, contributions) result.

Source: specs/tier2-feature/003-crowd-sentiment-pump-detection.md § B.3 UC-3 lines 379-423.
ADR: agent-workspace/memory/decisions/032-S51-BC-7-architecture-crowd-sentiment.md (D-032 § f).
"""

from __future__ import annotations

from dataclasses import dataclass

from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects.pump_phase import PumpPhase

__all__ = [
    "PumpPhaseClassifier",
    "PumpPhaseClassifierConfig",
    "TickerSignals",
]

# Spec § B.3 lines 386-422 default weights (verbatim)
_DEFAULT_QUIET_ACCUMULATION_WEIGHT = 0.3
_DEFAULT_KOL_WHISPERS_WEIGHT = 0.3
_DEFAULT_VOLUME_PRICE_SPIKE_WEIGHT = 0.4
_DEFAULT_FOMO_ACTIVE_WEIGHT = 0.3
_DEFAULT_VOLUME_WITHOUT_PRICE_WEIGHT = 0.4
_DEFAULT_NOVICE_FOMO_WEIGHT = 0.3
_DEFAULT_PRICE_CRASH_WEIGHT = 0.5

# Spec § B.3 line 418: confidence gate
_CONFIDENCE_GATE = 0.4

# BR-9: novel pattern confidence cap
_BR9_NOVEL_PATTERN_CAP = 0.6


@dataclass
class TickerSignals:
    """Input signals for PumpPhaseClassifier.

    All fields are Python-computed (I-S1: never from LLM).
    Tier annotations:
      t2 = Tier 2 (Market Structure / News)
      t3 = Tier 3 (KOL/Influence Network — BC-6)
      t4 = Tier 4 (Crowd Sentiment — BC-7)
    """

    # Price/volume signals (Tier 1 — BC-1 Market Data)
    price_change_30d: float             # 30-day price change ratio (e.g. 0.05 = +5%)
    price_5d_change: float              # 5-day price change ratio
    volume_30d_avg_rising: bool         # volume 30d trend rising
    volume_5d_avg_declining: bool       # volume 5d trend declining
    volume_5d_avg: float                # avg daily volume last 5d
    volume_30d_avg: float               # avg daily volume last 30d

    # News signals (Tier 2)
    t2_news_silent: bool                # no major news in lookback window

    # KOL/Influence signals (Tier 3 — BC-6)
    t3_kol_mentions_rising: bool        # KOL mentions trend rising
    t3_kol_mentions_peak: bool          # KOL mentions at local peak

    # Crowd signals (Tier 4 — BC-7)
    t4_novice_post_share: float         # fraction of posts from novice accounts
    t4_coordination_score: float        # from CoordinationDetector

    # Historical analog count (for BR-9)
    historical_similar_cases_count: int = 0  # from HistoricalAnalogFinder


@dataclass
class PumpPhaseClassifierConfig:
    """Tunable weights for PumpPhaseClassifier.

    Default values match spec § B.3 UC-3 lines 386-422 verbatim.
    Weight tuning deferred to Year 2 outer-loop activation per spec 005.
    """

    quiet_accumulation_weight: float = _DEFAULT_QUIET_ACCUMULATION_WEIGHT
    kol_whispers_weight: float = _DEFAULT_KOL_WHISPERS_WEIGHT
    volume_price_spike_weight: float = _DEFAULT_VOLUME_PRICE_SPIKE_WEIGHT
    fomo_active_weight: float = _DEFAULT_FOMO_ACTIVE_WEIGHT
    volume_without_price_weight: float = _DEFAULT_VOLUME_WITHOUT_PRICE_WEIGHT
    novice_fomo_weight: float = _DEFAULT_NOVICE_FOMO_WEIGHT
    price_crash_weight: float = _DEFAULT_PRICE_CRASH_WEIGHT
    confidence_gate: float = _CONFIDENCE_GATE
    novel_pattern_confidence_cap: float = _BR9_NOVEL_PATTERN_CAP

    # Signal thresholds (tunable)
    pre_pump_price_change_max: float = 0.10       # price_change_30d < threshold
    pump_price_spike_min: float = 0.20            # price_5d_change > threshold
    pump_volume_ratio_min: float = 3.0            # volume_5d / volume_30d > threshold
    pump_novice_share_min: float = 0.5            # t4_novice_post_share > threshold
    distribution_volume_ratio_min: float = 2.0   # volume_5d / volume_30d > threshold
    distribution_price_flat_max: float = 0.05    # abs(price_5d_change) < threshold
    distribution_novice_share_min: float = 0.7   # t4_novice_post_share > threshold
    distribution_low_coord_max: float = 0.3      # t4_coordination_score < threshold
    dump_price_crash_max: float = -0.15          # price_5d_change < threshold


class PumpPhaseClassifier:
    """Deterministic multi-signal pump phase classifier.

    I-S1: DETERMINISTIC pure-Python. NO LLM.
    § B.8 bootstrap test: run same signals twice → identical result tuple.
    BR-9: no historical matches → confidence capped at novel_pattern_confidence_cap.
    """

    def __init__(
        self,
        config: PumpPhaseClassifierConfig | None = None,
    ) -> None:
        self.config = config if config is not None else PumpPhaseClassifierConfig()

    def classify(
        self,
        signals: TickerSignals,
    ) -> tuple[PumpPhase, float, list[SignalContribution]]:
        """Return (phase, confidence, contributions).

        Returns (UNCERTAIN, score, contributions) if score < confidence_gate.
        BR-9: if no historical analogs, caps confidence at novel_pattern_confidence_cap.

        I-S1: pure Python arithmetic; no randomness; deterministic.
        """
        cfg = self.config
        scores: dict[PumpPhase, float] = {phase: 0.0 for phase in PumpPhase}
        contributions: list[SignalContribution] = []

        # Compute volume ratio safely (avoid division by zero)
        volume_ratio = (
            signals.volume_5d_avg / signals.volume_30d_avg
            if signals.volume_30d_avg > 0
            else 0.0
        )

        # PRE_PUMP signals (accumulation without news)
        if signals.price_change_30d < cfg.pre_pump_price_change_max and signals.volume_30d_avg_rising:
            w = cfg.quiet_accumulation_weight
            scores[PumpPhase.PRE_PUMP] += w
            contributions.append(
                SignalContribution(
                    signal_name="quiet_accumulation",
                    signal_value=float(signals.volume_30d_avg_rising),
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.PRE_PUMP,
                )
            )

        if signals.t3_kol_mentions_rising and signals.t2_news_silent:
            w = cfg.kol_whispers_weight
            scores[PumpPhase.PRE_PUMP] += w
            contributions.append(
                SignalContribution(
                    signal_name="kol_whispers_no_news",
                    signal_value=float(signals.t3_kol_mentions_rising and signals.t2_news_silent),
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.PRE_PUMP,
                )
            )

        # PUMP signals (spike + narrative)
        if (
            signals.price_5d_change > cfg.pump_price_spike_min
            and volume_ratio > cfg.pump_volume_ratio_min
        ):
            w = cfg.volume_price_spike_weight
            scores[PumpPhase.PUMP] += w
            contributions.append(
                SignalContribution(
                    signal_name="volume_price_spike",
                    signal_value=min(1.0, volume_ratio / cfg.pump_volume_ratio_min),
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.PUMP,
                )
            )

        if signals.t3_kol_mentions_peak and signals.t4_novice_post_share > cfg.pump_novice_share_min:
            w = cfg.fomo_active_weight
            scores[PumpPhase.PUMP] += w
            contributions.append(
                SignalContribution(
                    signal_name="fomo_active",
                    signal_value=signals.t4_novice_post_share,
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.PUMP,
                )
            )

        # DISTRIBUTION signals (high volume, price stalling)
        if (
            volume_ratio > cfg.distribution_volume_ratio_min
            and abs(signals.price_5d_change) < cfg.distribution_price_flat_max
        ):
            w = cfg.volume_without_price_weight
            scores[PumpPhase.DISTRIBUTION] += w
            contributions.append(
                SignalContribution(
                    signal_name="volume_without_price",
                    signal_value=min(1.0, volume_ratio / cfg.distribution_volume_ratio_min),
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.DISTRIBUTION,
                )
            )

        if (
            signals.t4_novice_post_share > cfg.distribution_novice_share_min
            and signals.t4_coordination_score < cfg.distribution_low_coord_max
        ):
            w = cfg.novice_fomo_weight
            scores[PumpPhase.DISTRIBUTION] += w
            contributions.append(
                SignalContribution(
                    signal_name="novice_fomo_dominant",
                    signal_value=signals.t4_novice_post_share,
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.DISTRIBUTION,
                )
            )

        # DUMP signals
        if signals.price_5d_change < cfg.dump_price_crash_max and signals.volume_5d_avg_declining:
            w = cfg.price_crash_weight
            scores[PumpPhase.DUMP] += w
            contributions.append(
                SignalContribution(
                    signal_name="price_crash_volume_decline",
                    signal_value=abs(signals.price_5d_change),
                    weight=w,
                    contribution=w,
                    phase=PumpPhase.DUMP,
                )
            )

        # Pick highest scoring phase
        best_phase_item = max(scores.items(), key=lambda x: x[1])
        best_phase, best_score = best_phase_item

        # Confidence gate per spec § B.3 line 418
        if best_score < cfg.confidence_gate:
            return PumpPhase.UNCERTAIN, best_score, contributions

        # BR-9: cap confidence if no historical analogs
        confidence = best_score
        if signals.historical_similar_cases_count == 0:
            confidence = min(confidence, cfg.novel_pattern_confidence_cap)

        # Return only contributions for winning phase
        winning_contributions = [c for c in contributions if c.phase == best_phase]
        return best_phase, confidence, winning_contributions
