"""BC-7 Crowd Sentiment domain package — public surface.

Exports the primary aggregates and value object namespace.
Domain layer has ZERO framework dependencies (I-10).
"""

from packages.domain.crowd.counter_narrative import CounterNarrative
from packages.domain.crowd.labeled_pump import LabeledPump
from packages.domain.crowd.narrative import Narrative
from packages.domain.crowd.phase_transition import PhaseTransition
from packages.domain.crowd.pump_detection import PumpDetection
from packages.domain.crowd.raw_post import RawPost
from packages.domain.crowd.sentiment_snapshot import SentimentSnapshot
from packages.domain.crowd.signal_contribution import SignalContribution
from packages.domain.crowd.value_objects import (
    DetectionId,
    NarrativeId,
    NarrativePhase,
    PumpAction,
    PumpPhase,
    Sentiment,
    SnapshotId,
    Window,
)

__all__ = [
    "CounterNarrative",
    "DetectionId",
    "LabeledPump",
    "Narrative",
    "NarrativeId",
    "NarrativePhase",
    "PhaseTransition",
    "PumpAction",
    "PumpDetection",
    "PumpPhase",
    "RawPost",
    "Sentiment",
    "SentimentSnapshot",
    "SignalContribution",
    "SnapshotId",
    "Window",
]
