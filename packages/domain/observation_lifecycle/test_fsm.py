"""Tests for observation_lifecycle.fsm — 8-state FSM unit tests.

Covers per D1 spec:
    - Each state's legal transitions
    - Illegal transition raises IllegalTransitionError
    - Dataclass equality
    - State serialization round-trip
    - Terminal state guard
    - Orphan candidate detection
    - Legacy back-compat (missing state column)

Covers per D2 spec (W0-1b col7 extension):
    - 6-col legacy row deserialized → last_transition_at defaults to detected_ts
    - State transition updates col7 (last_transition_at) to current time
    - is_orphan_candidate() uses col7 (last_transition_at), NOT col1 (detected_ts)
    - to_tsv_row() serializes 7-column row with last_transition_at
    - from_tsv_row() round-trip round-trips 7-col correctly
    - 5-col pre-W0-1 rows handled gracefully

Minimum 12 tests required (D1). This module now has ≥50 (D6 gate for W0-1b).
"""

from __future__ import annotations

from datetime import UTC, datetime, timedelta

import pytest

from packages.domain.observation_lifecycle.fsm import (
    ACTIVE_STATES,
    LEGACY_DEFAULT_STATE,
    LEGAL_TRANSITIONS,
    TERMINAL_STATES,
    IllegalTransitionError,
    ObservationLifecycle,
    State,
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _lifecycle(
    state: State = State.INITIALIZED,
    basename: str = "test-obs",
    session: str = "S311",
) -> ObservationLifecycle:
    lc = ObservationLifecycle(
        observation_basename=basename,
        session_id=session,
        current_state=state,
    )
    return lc


# ---------------------------------------------------------------------------
# TC-1: State enum values — 8 states, correct string values
# ---------------------------------------------------------------------------

class TestStateEnum:
    def test_eight_states_defined(self) -> None:
        assert len(State) == 8

    def test_state_values_match_names(self) -> None:
        for s in State:
            assert s.value == s.name

    def test_state_is_str(self) -> None:
        # State inherits str — can use in string comparisons directly
        assert State.INITIALIZED.value == "INITIALIZED"
        assert State.ORPHANED.value == "ORPHANED"


# ---------------------------------------------------------------------------
# TC-2: LEGAL_TRANSITIONS — forward happy-path
# ---------------------------------------------------------------------------

class TestLegalTransitions:
    def test_initialized_to_dispatched(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        lc.transition(State.DISPATCHED)
        assert lc.current_state == State.DISPATCHED

    def test_dispatched_to_in_flight(self) -> None:
        lc = _lifecycle(State.DISPATCHED)
        lc.transition(State.IN_FLIGHT)
        assert lc.current_state == State.IN_FLIGHT

    def test_in_flight_to_observation_written(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT)
        lc.transition(State.OBSERVATION_WRITTEN)
        assert lc.current_state == State.OBSERVATION_WRITTEN

    def test_observation_written_to_sidecar_attested(self) -> None:
        lc = _lifecycle(State.OBSERVATION_WRITTEN)
        lc.transition(State.SIDECAR_ATTESTED)
        assert lc.current_state == State.SIDECAR_ATTESTED

    def test_full_happy_path_sequence(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        lc.transition(State.DISPATCHED)
        lc.transition(State.IN_FLIGHT)
        lc.transition(State.OBSERVATION_WRITTEN)
        lc.transition(State.SIDECAR_ATTESTED)
        assert lc.current_state == State.SIDECAR_ATTESTED

    def test_in_flight_to_orphaned(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT)
        lc.transition(State.ORPHANED)
        assert lc.current_state == State.ORPHANED

    def test_observation_written_to_orphaned(self) -> None:
        lc = _lifecycle(State.OBSERVATION_WRITTEN)
        lc.transition(State.ORPHANED)
        assert lc.current_state == State.ORPHANED

    def test_orphaned_to_rectified(self) -> None:
        lc = _lifecycle(State.ORPHANED)
        lc.transition(State.RECTIFIED)
        assert lc.current_state == State.RECTIFIED

    def test_orphaned_to_resolved(self) -> None:
        lc = _lifecycle(State.ORPHANED)
        lc.transition(State.RESOLVED)
        assert lc.current_state == State.RESOLVED

    def test_rectified_to_resolved(self) -> None:
        lc = _lifecycle(State.RECTIFIED)
        lc.transition(State.RESOLVED)
        assert lc.current_state == State.RESOLVED

    def test_initialized_to_in_flight_fast_path(self) -> None:
        """Fast-path: dispatch + start are atomic."""
        lc = _lifecycle(State.INITIALIZED)
        lc.transition(State.IN_FLIGHT)
        assert lc.current_state == State.IN_FLIGHT


# ---------------------------------------------------------------------------
# TC-3: Illegal transitions — must raise IllegalTransitionError
# ---------------------------------------------------------------------------

class TestIllegalTransitions:
    def test_initialized_to_sidecar_attested_illegal(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        with pytest.raises(IllegalTransitionError) as exc_info:
            lc.transition(State.SIDECAR_ATTESTED)
        assert "INITIALIZED" in str(exc_info.value)
        assert "SIDECAR_ATTESTED" in str(exc_info.value)

    def test_initialized_to_orphaned_illegal(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        with pytest.raises(IllegalTransitionError):
            lc.transition(State.ORPHANED)

    def test_sidecar_attested_is_terminal(self) -> None:
        """No transition out of terminal SIDECAR_ATTESTED."""
        lc = _lifecycle(State.SIDECAR_ATTESTED)
        with pytest.raises(IllegalTransitionError) as exc_info:
            lc.transition(State.RESOLVED)
        assert "terminal" in str(exc_info.value)

    def test_resolved_is_terminal(self) -> None:
        lc = _lifecycle(State.RESOLVED)
        with pytest.raises(IllegalTransitionError) as exc_info:
            lc.transition(State.RECTIFIED)
        assert "terminal" in str(exc_info.value)

    def test_observation_written_to_dispatched_illegal(self) -> None:
        """No backward transition."""
        lc = _lifecycle(State.OBSERVATION_WRITTEN)
        with pytest.raises(IllegalTransitionError):
            lc.transition(State.DISPATCHED)

    def test_orphaned_to_in_flight_illegal(self) -> None:
        """Cannot return to ACTIVE from ORPHANED."""
        lc = _lifecycle(State.ORPHANED)
        with pytest.raises(IllegalTransitionError):
            lc.transition(State.IN_FLIGHT)

    def test_illegal_transition_preserves_state(self) -> None:
        """State unchanged after failed transition."""
        lc = _lifecycle(State.INITIALIZED)
        with pytest.raises(IllegalTransitionError):
            lc.transition(State.RESOLVED)
        assert lc.current_state == State.INITIALIZED

    def test_illegal_transition_error_attributes(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT)
        with pytest.raises(IllegalTransitionError) as exc_info:
            lc.transition(State.INITIALIZED)
        err = exc_info.value
        assert err.from_state == State.IN_FLIGHT
        assert err.to_state == State.INITIALIZED


# ---------------------------------------------------------------------------
# TC-4: Dataclass equality
# ---------------------------------------------------------------------------

class TestDataclassEquality:
    def test_equal_lifecycles(self) -> None:
        lc1 = _lifecycle(State.IN_FLIGHT, "obs-a", "S100")
        lc2 = _lifecycle(State.IN_FLIGHT, "obs-a", "S100")
        assert lc1 == lc2

    def test_different_state_not_equal(self) -> None:
        lc1 = _lifecycle(State.IN_FLIGHT, "obs-a", "S100")
        lc2 = _lifecycle(State.ORPHANED, "obs-a", "S100")
        assert lc1 != lc2

    def test_different_basename_not_equal(self) -> None:
        lc1 = _lifecycle(State.IN_FLIGHT, "obs-a", "S100")
        lc2 = _lifecycle(State.IN_FLIGHT, "obs-b", "S100")
        assert lc1 != lc2

    def test_not_equal_to_other_type(self) -> None:
        lc = _lifecycle()
        assert lc.__eq__("not-a-lifecycle") is NotImplemented


# ---------------------------------------------------------------------------
# TC-5: State serialization round-trip
# ---------------------------------------------------------------------------

class TestSerializationRoundTrip:
    def test_serialize_state_returns_value(self) -> None:
        lc = _lifecycle(State.ORPHANED)
        assert lc.serialize_state() == "ORPHANED"

    def test_deserialize_known_state(self) -> None:
        for state in State:
            result = ObservationLifecycle.deserialize_state(state.value)
            assert result == state

    def test_deserialize_empty_string_returns_default(self) -> None:
        result = ObservationLifecycle.deserialize_state("")
        assert result == LEGACY_DEFAULT_STATE

    def test_deserialize_whitespace_returns_default(self) -> None:
        result = ObservationLifecycle.deserialize_state("   ")
        assert result == LEGACY_DEFAULT_STATE

    def test_deserialize_unknown_value_returns_default(self) -> None:
        result = ObservationLifecycle.deserialize_state("RUNNING")
        assert result == LEGACY_DEFAULT_STATE

    def test_legacy_default_is_sidecar_attested(self) -> None:
        assert LEGACY_DEFAULT_STATE == State.SIDECAR_ATTESTED

    def test_round_trip_serialize_deserialize(self) -> None:
        for state in State:
            lc = _lifecycle(state)
            serialized = lc.serialize_state()
            deserialized = ObservationLifecycle.deserialize_state(serialized)
            assert deserialized == state


# ---------------------------------------------------------------------------
# TC-6: Orphan candidate detection
# ---------------------------------------------------------------------------

class TestOrphanCandidateDetection:
    def test_in_flight_stale_is_orphan_candidate(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT)
        # Simulate last_transition_at 31 minutes ago
        stale_ts = datetime.now(UTC) - timedelta(minutes=31)
        lc.last_transition_at = stale_ts
        assert lc.is_orphan_candidate(datetime.now(UTC), threshold_minutes=30)

    def test_in_flight_fresh_not_orphan_candidate(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT)
        # Just transitioned — default last_transition_at is now
        assert not lc.is_orphan_candidate(datetime.now(UTC), threshold_minutes=30)

    def test_observation_written_stale_is_orphan_candidate(self) -> None:
        lc = _lifecycle(State.OBSERVATION_WRITTEN)
        stale_ts = datetime.now(UTC) - timedelta(hours=2)
        lc.last_transition_at = stale_ts
        assert lc.is_orphan_candidate(datetime.now(UTC), threshold_minutes=30)

    def test_orphaned_state_not_orphan_candidate(self) -> None:
        """Already ORPHANED → not a new candidate."""
        lc = _lifecycle(State.ORPHANED)
        stale_ts = datetime.now(UTC) - timedelta(hours=2)
        lc.last_transition_at = stale_ts
        assert not lc.is_orphan_candidate(datetime.now(UTC))

    def test_sidecar_attested_not_orphan_candidate(self) -> None:
        lc = _lifecycle(State.SIDECAR_ATTESTED)
        stale_ts = datetime.now(UTC) - timedelta(hours=2)
        lc.last_transition_at = stale_ts
        assert not lc.is_orphan_candidate(datetime.now(UTC))

    def test_initialized_not_orphan_candidate(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        stale_ts = datetime.now(UTC) - timedelta(hours=2)
        lc.last_transition_at = stale_ts
        assert not lc.is_orphan_candidate(datetime.now(UTC))


# ---------------------------------------------------------------------------
# TC-7: LEGAL_TRANSITIONS frozenset invariants
# ---------------------------------------------------------------------------

class TestTransitionTable:
    def test_legal_transitions_is_frozenset(self) -> None:
        assert isinstance(LEGAL_TRANSITIONS, frozenset)

    def test_terminal_states_are_frozenset(self) -> None:
        assert isinstance(TERMINAL_STATES, frozenset)

    def test_active_states_subset_of_all_states(self) -> None:
        for s in ACTIVE_STATES:
            assert s in State

    def test_terminal_states_subset_of_all_states(self) -> None:
        for s in TERMINAL_STATES:
            assert s in State

    def test_no_self_transitions_in_table(self) -> None:
        """A state should never transition to itself."""
        for from_s, to_s in LEGAL_TRANSITIONS:
            assert from_s != to_s, f"Self-transition found: {from_s}"

    def test_transition_count_expected_range(self) -> None:
        """Sanity: we defined 12 transitions in the table (frozenset deduplicates)."""
        assert len(LEGAL_TRANSITIONS) == 12


# ---------------------------------------------------------------------------
# TC-8: last_transition_at updated on transition
# ---------------------------------------------------------------------------

class TestTransitionTimestamp:
    def test_last_transition_at_updated(self) -> None:
        lc = _lifecycle(State.INITIALIZED)
        before = lc.last_transition_at
        lc.transition(State.DISPATCHED)
        assert lc.last_transition_at >= before

    def test_repr_includes_state(self) -> None:
        lc = _lifecycle(State.IN_FLIGHT, "my-obs", "S999")
        r = repr(lc)
        assert "IN_FLIGHT" in r
        assert "my-obs" in r


# ---------------------------------------------------------------------------
# TC-9: D2 (W0-1b) — 7-col TSV schema: to_tsv_row / from_tsv_row / col7 behavior
# ---------------------------------------------------------------------------

class TestCol7TsvSchema:
    """Col7 last_transition_at — D2 acceptance tests.

    Three required behaviors per plan:
      (a) 6-col legacy row → last_transition_at defaults to detected_ts
      (b) state transition updates col7 to current time
      (c) is_orphan_candidate uses col7 not col1
    Plus additional coverage for to_tsv_row, from_tsv_row, 5-col, 7-col round-trip.
    """

    def test_6col_legacy_from_tsv_last_transition_defaults_to_detected_ts(self) -> None:
        """(a) 6-col row: col7 absent → last_transition_at == detected_ts (back-compat)."""
        # 6-col row: no last_transition_at column
        row = "2026-05-10T08:00:00Z\tS300\tobs-legacy.md\t0\t0\tIN_FLIGHT"
        lc = ObservationLifecycle.from_tsv_row(row)
        # col7 should default to detected_ts (col1)
        assert lc.last_transition_at == lc.created_at
        assert lc.last_transition_at.year == 2026
        assert lc.last_transition_at.hour == 8

    def test_state_transition_updates_col7_last_transition_at(self) -> None:
        """(b) After transition(), last_transition_at is updated to current time."""
        before = datetime.now(UTC)
        lc = _lifecycle(State.IN_FLIGHT)
        # Force last_transition_at to a known old time to verify it changes
        old_ts = before - timedelta(hours=1)
        lc.last_transition_at = old_ts
        lc.transition(State.OBSERVATION_WRITTEN)
        # last_transition_at must now be >= before (i.e. after the transition call)
        assert lc.last_transition_at >= before
        assert lc.last_transition_at > old_ts

    def test_is_orphan_candidate_uses_col7_not_col1(self) -> None:
        """(c) is_orphan_candidate() uses last_transition_at (col7), not created_at (col1).

        Scenario: created_at is 2 hours old (would be orphan if col1 used),
        but last_transition_at is 5 minutes old (NOT orphan if col7 used correctly).
        """
        now = datetime.now(UTC)
        lc = ObservationLifecycle(
            observation_basename="obs-age-proxy-test.md",
            session_id="S313",
            current_state=State.IN_FLIGHT,
            created_at=now - timedelta(hours=2),       # col1: 2h old — would orphan if used
            last_transition_at=now - timedelta(minutes=5),  # col7: 5min old — NOT orphan
        )
        # With 30-min threshold: col7 is only 5min old → NOT an orphan candidate
        assert not lc.is_orphan_candidate(now, threshold_minutes=30)

    def test_is_orphan_candidate_stale_col7_triggers(self) -> None:
        """col7 stale (>30min) → orphan candidate, even if col1 is recent."""
        now = datetime.now(UTC)
        lc = ObservationLifecycle(
            observation_basename="obs-stale-col7.md",
            session_id="S313",
            current_state=State.IN_FLIGHT,
            created_at=now - timedelta(minutes=5),     # col1: fresh
            last_transition_at=now - timedelta(hours=1),  # col7: 1h stale → orphan
        )
        assert lc.is_orphan_candidate(now, threshold_minutes=30)

    def test_to_tsv_row_produces_7_columns(self) -> None:
        """to_tsv_row() serializes exactly 7 tab-separated columns."""
        lc = _lifecycle(State.IN_FLIGHT)
        row = lc.to_tsv_row(marker_present=0, log_row_present=1)
        cols = row.split("\t")
        assert len(cols) == 7

    def test_to_tsv_row_col7_is_last_transition_at(self) -> None:
        """col7 in serialized row equals the ISO repr of last_transition_at."""
        now = datetime.now(UTC)
        lc = ObservationLifecycle(
            observation_basename="obs-col7-check.md",
            session_id="S313",
            current_state=State.OBSERVATION_WRITTEN,
            created_at=now - timedelta(hours=1),
            last_transition_at=now,
        )
        row = lc.to_tsv_row()
        cols = row.split("\t")
        expected_col7 = now.strftime("%Y-%m-%dT%H:%M:%SZ")
        assert cols[6] == expected_col7

    def test_from_tsv_row_7col_round_trip(self) -> None:
        """7-col row deserializes correctly: all fields including col7."""
        row = "2026-05-14T10:00:00Z\tS313\tobs-roundtrip.md\t1\t0\tORPHANED\t2026-05-14T12:00:00Z"
        lc = ObservationLifecycle.from_tsv_row(row)
        assert lc.observation_basename == "obs-roundtrip.md"
        assert lc.session_id == "S313"
        assert lc.current_state == State.ORPHANED
        # col1 → created_at
        assert lc.created_at.hour == 10
        # col7 → last_transition_at (different from created_at)
        assert lc.last_transition_at.hour == 12

    def test_from_tsv_row_5col_pre_w0_1_graceful(self) -> None:
        """5-col pre-W0-1 row: state defaults to SIDECAR_ATTESTED, col7 to col1."""
        row = "2026-04-01T06:00:00Z\tS100\tobs-ancient.md\t1\t1"
        lc = ObservationLifecycle.from_tsv_row(row)
        assert lc.current_state == State.SIDECAR_ATTESTED  # default
        assert lc.last_transition_at == lc.created_at      # col7 defaults to col1

    def test_from_tsv_row_fewer_than_5_cols_raises(self) -> None:
        """Row with < 5 cols is malformed — raises ValueError."""
        row = "2026-01-01T00:00:00Z\tS100\tobs.md"
        with pytest.raises(ValueError):
            ObservationLifecycle.from_tsv_row(row)

    def test_to_tsv_row_col1_immutable_after_transition(self) -> None:
        """col1 (detected_ts / created_at) must NOT change after state transition."""
        now = datetime.now(UTC)
        created = now - timedelta(hours=2)
        lc = ObservationLifecycle(
            observation_basename="obs-immutable-col1.md",
            session_id="S313",
            current_state=State.IN_FLIGHT,
            created_at=created,
            last_transition_at=created,
        )
        lc.transition(State.ORPHANED)
        row = lc.to_tsv_row()
        cols = row.split("\t")
        # col1 must equal original created_at (not updated by transition)
        expected_col1 = created.strftime("%Y-%m-%dT%H:%M:%SZ")
        assert cols[0] == expected_col1
        # col7 must be different (updated by transition to current time)
        assert cols[6] != cols[0]

    def test_to_and_from_tsv_row_full_round_trip(self) -> None:
        """to_tsv_row() then from_tsv_row() preserves all fields."""
        created = datetime(2026, 5, 14, 8, 0, 0, tzinfo=UTC)
        last_t = datetime(2026, 5, 14, 10, 30, 0, tzinfo=UTC)
        lc_orig = ObservationLifecycle(
            observation_basename="obs-full-rt.md",
            session_id="S313",
            current_state=State.OBSERVATION_WRITTEN,
            created_at=created,
            last_transition_at=last_t,
        )
        row = lc_orig.to_tsv_row(marker_present=1, log_row_present=0)
        lc_rt = ObservationLifecycle.from_tsv_row(row)
        assert lc_rt.observation_basename == lc_orig.observation_basename
        assert lc_rt.session_id == lc_orig.session_id
        assert lc_rt.current_state == lc_orig.current_state
        assert lc_rt.created_at == lc_orig.created_at
        assert lc_rt.last_transition_at == lc_orig.last_transition_at
