"""Observation lifecycle FSM — 8-state deterministic state machine for subagent observations.

Implements the nautilus_trader Actor lifecycle FSM pattern (adapted for stockforge
sidecar observation tracking). Source: general-purpose-S259-deepdive-nautilus_trader.md §1.9
and architecture.md:344-403.

States (8):
    INITIALIZED         — observation row created, dispatch not yet confirmed
    DISPATCHED          — subagent dispatch confirmed in dispatch.jsonl
    IN_FLIGHT           — subagent is running (mtime advancing, no completion marker)
    OBSERVATION_WRITTEN — observation .md file written by subagent
    SIDECAR_ATTESTED    — sidecar row attested in attestation-log.tsv (terminal-happy)
    RECTIFIED           — manually rectified after orphan (terminal-recovery)
    ORPHANED            — stuck IN_FLIGHT or OBSERVATION_WRITTEN for >30min (requires rectification)
    RESOLVED            — orphan resolved by human or automated rectifier (terminal-final)

Transition table (frozenset of (from_state, to_state) tuples):
    Only listed pairs are legal. All other transitions raise IllegalTransitionError.

TSV schema (7 columns as of W0-1b):
    col1: detected_ts        — ISO-8601 UTC timestamp when row was first written (IMMUTABLE)
    col2: session_id         — session that created the observation
    col3: observation_basename — filename of the observation .md
    col4: marker_present     — 0/1 boolean (sidecar marker file exists)
    col5: log_row_present    — 0/1 boolean (attestation-log.tsv row exists)
    col6: state              — FSM state value (State enum string)
    col7: last_transition_at — ISO-8601 UTC of most recent state transition
                               Back-compat: legacy 6-col rows default col7 = col1 (detected_ts)
                               on first read; auto-upgraded to 7-col on next state mutation.

Age proxy rule (F2 fix — W0-1b):
    Orphan age MUST be computed from col7 (last_transition_at), NOT col1 (detected_ts).
    Using col1 as age proxy causes false orphan-flags when a row spends time in
    a non-ACTIVE state before reaching IN_FLIGHT/OBSERVATION_WRITTEN.
    is_orphan_candidate() uses self.last_transition_at (col7) deterministically.

Hard constraints enforced:
    - Pure Python dataclass + enum (ZERO framework dependency — architecture.md hard rule)
    - No Pydantic, no FastAPI, no Streamlit
    - No LLM math — all state transitions are deterministic guard-based
    - I-S1 (no LLM math): transition guards are pure code

Source: 012-S311-wave-0-W0-1-fsm-impl.md D1
W0-1b fix: 013-S313-wave-0-W0-1b-orphan-reescalate-and-schema-fix.md D2+D3
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime
from enum import StrEnum

__all__ = [
    "IllegalTransitionError",
    "ObservationLifecycle",
    "State",
    "LEGAL_TRANSITIONS",
]


class State(StrEnum):
    """8-state lifecycle for subagent observations.

    StrEnum (Python 3.11+) allows direct TSV serialization/deserialization:
    State.INITIALIZED.value == "INITIALIZED" for clean TSV round-trip.
    """

    INITIALIZED = "INITIALIZED"
    DISPATCHED = "DISPATCHED"
    IN_FLIGHT = "IN_FLIGHT"
    OBSERVATION_WRITTEN = "OBSERVATION_WRITTEN"
    SIDECAR_ATTESTED = "SIDECAR_ATTESTED"
    RECTIFIED = "RECTIFIED"
    ORPHANED = "ORPHANED"
    RESOLVED = "RESOLVED"


# Note: RECTIFIED → RESOLVED only (NOT RECTIFIED → SIDECAR_ATTESTED).
# Recovery flow must visibly terminate at RESOLVED so audit trail shows
# human-rectified vs happy-path-attested as distinct outcomes.
# See S312 verifier V2.1 for full rationale.
#
# Legal transition table.
# frozenset of (from_state, to_state) pairs — explicit enumeration per D1 spec.
# "Not dict-of-dict" per plan; frozenset gives O(1) membership test.
LEGAL_TRANSITIONS: frozenset[tuple[State, State]] = frozenset(
    {
        # Happy path forward
        (State.INITIALIZED, State.DISPATCHED),
        (State.DISPATCHED, State.IN_FLIGHT),
        (State.IN_FLIGHT, State.OBSERVATION_WRITTEN),
        (State.OBSERVATION_WRITTEN, State.SIDECAR_ATTESTED),
        # Orphan detection paths (from stale IN_FLIGHT or OBSERVATION_WRITTEN)
        (State.IN_FLIGHT, State.ORPHANED),
        (State.OBSERVATION_WRITTEN, State.ORPHANED),
        # Recovery paths
        (State.ORPHANED, State.RECTIFIED),
        (State.ORPHANED, State.RESOLVED),
        (State.RECTIFIED, State.RESOLVED),
        # Fast-path: dispatch directly to in-flight (when dispatch + start are atomic)
        (State.INITIALIZED, State.IN_FLIGHT),
        # Edge: observation written without separate in-flight tracking
        (State.DISPATCHED, State.OBSERVATION_WRITTEN),
        # Edge: dispatched directly attested (short-circuit for simple subagents)
        (State.DISPATCHED, State.SIDECAR_ATTESTED),
    }
)

# Terminal states — no further transitions allowed from these
TERMINAL_STATES: frozenset[State] = frozenset(
    {
        State.SIDECAR_ATTESTED,
        State.RESOLVED,
    }
)

# States that indicate active in-flight work (used by orphan detector)
ACTIVE_STATES: frozenset[State] = frozenset(
    {
        State.IN_FLIGHT,
        State.OBSERVATION_WRITTEN,
    }
)

# Default state for legacy rows missing the state column (back-compat per D1 spec)
LEGACY_DEFAULT_STATE: State = State.SIDECAR_ATTESTED


class IllegalTransitionError(ValueError):
    """Raised when an illegal FSM state transition is attempted.

    Provides from_state, to_state, and context in the error message.
    """

    def __init__(self, from_state: State, to_state: State, context: str = "") -> None:
        self.from_state = from_state
        self.to_state = to_state
        detail = f"Illegal transition {from_state.value} -> {to_state.value}"
        if context:
            detail = f"{detail} ({context})"
        super().__init__(detail)


@dataclass
class ObservationLifecycle:
    """Mutable lifecycle tracker for a single subagent observation.

    Carries state + metadata. Validates transitions against LEGAL_TRANSITIONS.
    Serialized to/from TSV as the `state` column in .unattested-observations.tsv.

    Not frozen (state transitions mutate current_state). One instance per
    observation row.
    """

    observation_basename: str
    session_id: str
    current_state: State = field(default=State.INITIALIZED)
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    last_transition_at: datetime = field(default_factory=lambda: datetime.now(UTC))

    def transition(self, to_state: State) -> None:
        """Attempt a state transition. Raises IllegalTransitionError if not legal.

        Updates current_state and last_transition_at on success.
        Pure deterministic guard — no LLM judgment (I-S1).
        """
        pair = (self.current_state, to_state)
        if self.current_state in TERMINAL_STATES:
            raise IllegalTransitionError(
                self.current_state,
                to_state,
                context=f"already in terminal state {self.current_state.value}",
            )
        if pair not in LEGAL_TRANSITIONS:
            raise IllegalTransitionError(self.current_state, to_state)
        self.current_state = to_state
        self.last_transition_at = datetime.now(UTC)

    def is_orphan_candidate(self, now: datetime, threshold_minutes: int = 30) -> bool:
        """True if current state is ACTIVE and last transition > threshold_minutes ago.

        Used by orphan-detector hook to identify stale rows.
        Deterministic code only — no LLM judgment (I-S1).
        """
        if self.current_state not in ACTIVE_STATES:
            return False
        elapsed = (now - self.last_transition_at).total_seconds()
        return elapsed > (threshold_minutes * 60)

    def serialize_state(self) -> str:
        """Return the state value string for TSV persistence."""
        return self.current_state.value

    @classmethod
    def deserialize_state(cls, value: str) -> State:
        """Parse TSV state column. Missing/unknown value → LEGACY_DEFAULT_STATE.

        Back-compat: legacy rows without state column pass empty string or
        'SIDECAR_ATTESTED'; both resolve to SIDECAR_ATTESTED (no migration needed).
        """
        if not value or not value.strip():
            return LEGACY_DEFAULT_STATE
        try:
            return State(value.strip())
        except ValueError:
            return LEGACY_DEFAULT_STATE

    def to_tsv_row(
        self,
        marker_present: int = 0,
        log_row_present: int = 0,
    ) -> str:
        """Serialize to 7-column TSV row string (no trailing newline).

        Schema (W0-1b col7 extension):
            detected_ts TAB session_id TAB observation_basename TAB
            marker_present TAB log_row_present TAB state TAB last_transition_at

        Uses created_at for col1 (detected_ts) — immutable first-write timestamp.
        Uses last_transition_at for col7 — updated on every state mutation.
        """
        return "\t".join(
            [
                self.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"),
                self.session_id,
                self.observation_basename,
                str(marker_present),
                str(log_row_present),
                self.current_state.value,
                self.last_transition_at.strftime("%Y-%m-%dT%H:%M:%SZ"),
            ]
        )

    @classmethod
    def from_tsv_row(cls, row: str) -> ObservationLifecycle:
        """Deserialize from TSV row string (6-col or 7-col).

        Back-compat rules (D2 spec):
            - 6-col legacy rows: col7 (last_transition_at) defaults to col1 (detected_ts)
            - 5-col pre-W0-1 rows: col6 (state) defaults to SIDECAR_ATTESTED;
              col7 defaults to col1
            - col7 auto-upgraded to current ISO timestamp on next state mutation
              (transition() updates self.last_transition_at = datetime.now(UTC))

        Raises ValueError if row has < 5 columns or detected_ts cannot be parsed.
        """
        cols = row.split("\t")
        if len(cols) < 5:
            raise ValueError(f"TSV row has fewer than 5 columns: {row!r}")

        # col1: detected_ts (immutable — stored as created_at)
        detected_ts_str = cols[0].strip()
        try:
            created_at = datetime.fromisoformat(
                detected_ts_str.replace("Z", "+00:00")
            )
        except ValueError:
            # Unparseable timestamp — use epoch as safe fallback
            created_at = datetime(1970, 1, 1, tzinfo=UTC)

        session_id = cols[1].strip()
        observation_basename = cols[2].strip()
        # cols[3] = marker_present, cols[4] = log_row_present (not stored in object)

        # col6: state — default SIDECAR_ATTESTED for 5-col rows
        raw_state = cols[5].strip() if len(cols) >= 6 else ""
        state = cls.deserialize_state(raw_state)

        # col7: last_transition_at — default to detected_ts for 6-col rows (back-compat)
        if len(cols) >= 7 and cols[6].strip():
            try:
                last_transition_at = datetime.fromisoformat(
                    cols[6].strip().replace("Z", "+00:00")
                )
            except ValueError:
                last_transition_at = created_at
        else:
            # Back-compat: 6-col row → use detected_ts as age proxy until next mutation
            last_transition_at = created_at

        return cls(
            observation_basename=observation_basename,
            session_id=session_id,
            current_state=state,
            created_at=created_at,
            last_transition_at=last_transition_at,
        )

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, ObservationLifecycle):
            return NotImplemented
        return (
            self.observation_basename == other.observation_basename
            and self.session_id == other.session_id
            and self.current_state == other.current_state
        )

    def __repr__(self) -> str:
        return (
            f"ObservationLifecycle("
            f"basename={self.observation_basename!r}, "
            f"session={self.session_id!r}, "
            f"state={self.current_state.value!r})"
        )
