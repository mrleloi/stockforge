"""ExtractionStrategy picker — encapsulates S47 empirical probe outcome.

Chooses the LLM model configuration for KOL recommendation extraction based
on the S47 empirical probe results.

--- PROBE MATRIX (S47 entry; ACTUAL RESULTS 2026-05-05) ---

Mandatory per L-S32-1 + master-plan § R-P3-1 HIGH: before writing the extractor,
invoke `empirical-probe-first` skill to test ≥3 strategies on Vietnamese KOL
transcripts.

IMPL-S47-N: 10-fixture probe run at S47 session entry (reconciled from sub-plan
'5+ fixtures' vs success criteria '50-fixture set'; expand to 50 in Phase 4
KOL dogfood per task brief). Precision ≥0.85 on 10-fixture set is acceptable
signal per task brief.

IMPL-S47-5 (vendor drift): claude-haiku-3-5 is NOT available on this Claude Code
subscription (HTTP 404). Substituted claude-haiku-4-5 per empirical probe —
matches _HAIKU_MODEL constant already used in claude_llm_perspective_adapter.py.

+----------+---------------------------------+-----------+-----------+--------+---------+
| Strategy | Model(s)                        | Precision | Recall    | Cost   | Verdict |
+----------+---------------------------------+-----------+-----------+--------+---------+
| S1 Opus  | claude-opus-4-7                 | 0.889     | 0.889     | $1.03  | PASS    |
| S2 Sonnet| claude-sonnet-4-6               | 0.889     | 0.889     | $0.33  | PASS    |
| S3 Hybrid| claude-haiku-4-5 (filter)       | 1.000     | 0.889     | ~$0.27 | PASS    |
|          | + claude-sonnet-4-6 (extract)   |           |           |        | WINNER  |
+----------+---------------------------------+-----------+-----------+--------+---------+

Chosen: S3 (Haiku-4-5 prefilter + Sonnet extract) — rationale:
- Best precision (1.0 vs 0.889 for S1/S2): Haiku correctly eliminated all FPs
  (educational content, past recommendation references).
- Cheapest of passing strategies (~$0.27 vs $0.33 vs $1.03).
- Preference order per empirical-probe-first skill: S3 > S2 > S1 (cheapest + precision).
- Probe matrix: data/track-H-probe/probe-matrix.json
- Coverage report: data/track-H-probe/coverage-S47.md

Rollback condition: If live calibration (S49) shows precision < 0.85 on actual
Vietnamese KOL transcripts, escalate to SCOPE Q&A bundle per D-027 § Rollback path.

Source: agent-workspace/session-plans/pending/008-S45-track-G-H-I-impl-sub-plan.md § S47.
ADR: agent-workspace/memory/decisions/027-S45-BC-6-architecture-influence-network.md (D-027 § d).
Probe: data/track-H-probe/probe-matrix.json (S47 2026-05-05).
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

__all__ = [
    "ExtractionStrategy",
    "ExtractionStrategyConfig",
    "pick_extraction_strategy",
]

# Model IDs — match architecture.md § LLM stack.
_SONNET_MODEL = "claude-sonnet-4-6"
_OPUS_MODEL = "claude-opus-4-7"
_HAIKU_MODEL = "claude-haiku-4-5"


class ExtractionStrategy(StrEnum):
    """Named extraction strategies tested in the S47 probe matrix."""

    S1_OPUS = "s1_opus"
    S2_SONNET = "s2_sonnet"
    S3_HAIKU_SONNET = "s3_haiku_sonnet"


@dataclass(frozen=True, slots=True)
class ExtractionStrategyConfig:
    """Configuration for the chosen extraction strategy.

    Fields:
        strategy:           Which probe strategy was selected.
        primary_model:      Model used for the main extraction call.
        prefilter_model:    Model used for the Haiku prefilter step (S3 only).
                            None for single-model strategies (S1, S2).
        temperature:        Pinned to 0.0 for reproducibility (AC-5).
        max_output_tokens:  Safety cap for output length.
        rationale:          Human-readable rationale (stored in audit log).
    """

    strategy: ExtractionStrategy
    primary_model: str
    prefilter_model: str | None
    temperature: float
    max_output_tokens: int
    rationale: str


# S47 chosen strategy config — update when probe data is available.
_S2_SONNET_CONFIG = ExtractionStrategyConfig(
    strategy=ExtractionStrategy.S2_SONNET,
    primary_model=_SONNET_MODEL,
    prefilter_model=None,
    temperature=0.0,
    max_output_tokens=2048,
    rationale=(
        "S47 probe result: precision=0.889 recall=0.889 cost=$0.33. "
        "PASS but not chosen — S3 hybrid wins on precision (1.0) and cost (~$0.27). "
        "Use as fallback if Haiku prefilter substrate unavailable."
    ),
)

_S1_OPUS_CONFIG = ExtractionStrategyConfig(
    strategy=ExtractionStrategy.S1_OPUS,
    primary_model=_OPUS_MODEL,
    prefilter_model=None,
    temperature=0.0,
    max_output_tokens=2048,
    rationale="Highest precision; use when extraction quality is critical (post-probe).",
)

_S3_HYBRID_CONFIG = ExtractionStrategyConfig(
    strategy=ExtractionStrategy.S3_HAIKU_SONNET,
    primary_model=_SONNET_MODEL,
    prefilter_model=_HAIKU_MODEL,
    temperature=0.0,
    max_output_tokens=2048,
    rationale=(
        "S47 PROBE WINNER (2026-05-05): precision=1.0 recall=0.889 cost=~$0.27. "
        "Haiku-4-5 prefilter eliminated all FPs (educational content, past-rec references). "
        "IMPL-S47-5: claude-haiku-3-5 not available (HTTP 404); substituted claude-haiku-4-5. "
        "Probe matrix: data/track-H-probe/probe-matrix.json."
    ),
)

_STRATEGY_CONFIGS: dict[ExtractionStrategy, ExtractionStrategyConfig] = {
    ExtractionStrategy.S1_OPUS: _S1_OPUS_CONFIG,
    ExtractionStrategy.S2_SONNET: _S2_SONNET_CONFIG,
    ExtractionStrategy.S3_HAIKU_SONNET: _S3_HYBRID_CONFIG,
}

# The current active strategy (S47 empirical probe winner: S3 Haiku+Sonnet).
# Probe date: 2026-05-05. Probe matrix: data/track-H-probe/probe-matrix.json.
_ACTIVE_STRATEGY = ExtractionStrategy.S3_HAIKU_SONNET


def pick_extraction_strategy(
    override: ExtractionStrategy | None = None,
) -> ExtractionStrategyConfig:
    """Return the ExtractionStrategyConfig for the given strategy.

    Args:
        override: Force a specific strategy (used in tests or manual overrides).
                  If None, returns the S47-chosen default (_ACTIVE_STRATEGY).

    Returns:
        ExtractionStrategyConfig with model IDs, temperature, and rationale.

    Usage:
        config = pick_extraction_strategy()
        # config.primary_model == "claude-sonnet-4-6"

        # Override for testing Opus:
        config = pick_extraction_strategy(ExtractionStrategy.S1_OPUS)
    """
    strategy = override if override is not None else _ACTIVE_STRATEGY
    return _STRATEGY_CONFIGS[strategy]
