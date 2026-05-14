---
plan_id: 012-S311-wave-0-W0-1-fsm-impl
phase: 4 (Wave 0 substrate)
status: pending-execution
authored: 2026-05-14
authored_session: S310 (post-Q-INT-10=A ratification + harness severity system ship)
authoring_agent: Claude Opus 4.7 (main session author; lean brief per L-S43f-2)
executing_agent: sandwich-dev (background dispatch S310→S311)
binding_decisions:
  - D-058 (Q-INT mega-bundle ratification; Q-INT-10=A authorizes Wave 0 substrate)
binding_specs:
  - (none — substrate work, no new public BC spec)
binding_charter:
  - PROJECT_CHARTER.md § Core Principles (no LLM math; deterministic risk)
  - agent-workspace/constitution/architecture.md (domain layer zero framework dependency — Python dataclass for FSM domain object)
  - agent-workspace/constitution/severity-schema.md (NEW from S310 — sidecar-orphan = HIGH severity by classification)
source_materials_must_read:
  - agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md (320 LOC; 8-state FSM spec details)
  - scripts/hooks/session-start-scan-unattested-observations.sh (existing scan; integration point)
  - scripts/hooks/pre-checkpoint-close-verifier.sh (close verifier; second integration point)
  - agent-workspace/memory/.unattested-observations.tsv (current sidecar tracking format)
mode: FOCUSED_IMPL
estimated_envelope: 150-300K tokens (single FOCUSED_IMPL or split 2 sessions if scope creeps)
---

# Wave 0 W0-1 — Nautilus 8-State Observation-Lifecycle FSM IMPL

## Goal

Ship a deterministic 8-state lifecycle FSM for subagent observations to **close L-S258-2 sidecar-orphan 4th-instance URGENT** (Q-INT-10=A ratified pickup).

**Problem being solved**: Subagent dispatches produce observation files (`agent-workspace/memory/observations/*.md`) plus sidecar attestation rows in `.unattested-observations.tsv`. When a dispatch fails mid-flight (timeout, /clear, network), the observation file lingers WITHOUT closing the sidecar row → orphan. Manual rectification has been needed 4+ times (L-S258-2 instances). nautilus_trader's 8-state lifecycle FSM pattern (battle-tested at production trading scale) provides a clean primitive: each observation transitions through deterministic states with explicit transition guards, and orphans are recoverable via state inspection.

## Deliverables (acceptance criteria)

### D1 — FSM domain module
- **Path**: `packages/domain/observation_lifecycle/fsm.py` (NEW; pure Python dataclass + enum; ZERO framework dependency per architecture.md)
- **States** (8): per source nautilus observation file §3 — `INITIALIZED / DISPATCHED / IN_FLIGHT / OBSERVATION_WRITTEN / SIDECAR_ATTESTED / RECTIFIED / ORPHANED / RESOLVED`
- **Transitions**: only legal transitions allowed; illegal raises `IllegalTransitionError`. Adopt nautilus's explicit transition-table pattern (not dict-of-dict; use `frozenset[tuple[State, State]]`).
- **Persistence**: state stored in `.unattested-observations.tsv` extended schema — add `state` column at end (back-compat: missing column → default `SIDECAR_ATTESTED` for legacy rows).
- **Tests**: `packages/domain/observation_lifecycle/test_fsm.py` (pytest) — minimum 12 unit tests covering: each state's legal transitions, each illegal transition raises, dataclass equality, state serialization round-trip.

### D2 — Integration hook (orphan detector)
- **Path**: `scripts/hooks/observation-orphan-detector.sh` (NEW)
- **Trigger**: Stop hook (late chain, after severity-classifier)
- **Behavior**: Scan `.unattested-observations.tsv`; for each row in state `IN_FLIGHT` or `OBSERVATION_WRITTEN` with mtime >30min: transition to `ORPHANED` state + emit row to `.severity-state.tsv` as HIGH severity (per `severity-schema.md` Layer 4 — sidecar staleness).
- **Best-effort**: RC=0 always; never breaks Stop chain.
- **Companion firing-test**: `scripts/hooks/firing-tests/observation-orphan-detector-fire-test.sh` — 5+ TC: empty tsv / 1 fresh IN_FLIGHT / 1 stale IN_FLIGHT → ORPHANED transition / illegal-transition guard / state column back-compat with legacy rows.

### D3 — Update existing scanner to use FSM
- **Edit**: `scripts/hooks/session-start-scan-unattested-observations.sh` — instead of bare row count, classify per-state and only ALERT for `ORPHANED` state (not `SIDECAR_ATTESTED` legitimate-pending).
- **Edit**: `scripts/hooks/pre-checkpoint-close-verifier.sh` — refuse close if any row in `OBSERVATION_WRITTEN` state for current session (forces transition to `SIDECAR_ATTESTED` first).

### D4 — Acceptance verification (DoD)
- ✅ `pytest packages/domain/observation_lifecycle/` → all green
- ✅ `mypy --strict packages/domain/observation_lifecycle/` → clean
- ✅ `ruff check packages/domain/observation_lifecycle/` → clean
- ✅ Firing-tests `observation-orphan-detector-fire-test.sh` → all PASS
- ✅ Smoke run: synthesize 3 orphan rows in tsv → run orphan-detector → verify .severity-state.tsv gets 3 HIGH rows
- ✅ Legacy `.unattested-observations.tsv` rows without state column → read as `SIDECAR_ATTESTED` default (no migration script needed)
- ✅ NO production-code edits outside the 4 deliverable files (D1-D3 paths)
- ✅ NO commit per CLAUDE.md hard rule
- ✅ Author session log `agent-workspace/memory/sessions/2026-05-14-session-311.md` with file list + test results + L-S258-2 closure note

## Out of scope (DEFER)

- W0-2 nautilus DST-style banned-pattern enforcement (separate session)
- W0-3 TradingAgents atomic temp-file-replace doctrine (separate session)
- W0-4 HTML-comment separator pattern (separate session)
- W0-5 Vibe-Trading path-safety quad (separate session)
- Migration of historical orphan rows to new state column (back-compat default covers it)
- charter v1.2 amendment for FSM-as-binding (defer until Wave 0 substrate proves; consolidated promote-rule cycle picks up at S320+)

## Hard constraints (per CLAUDE.md + memories)

1. **NO LLM math** (I-S1) — FSM state transitions are deterministic; no LLM judgment in transition logic
2. **Pure Python dataclass** — no Pydantic / FastAPI / Streamlit in domain layer (architecture.md hard rule)
3. **NO commit** — agent stages changes; user reviews + commits
4. **0 charter edits** — no PROJECT_CHARTER.md / constitution/ writes (severity-schema.md was already shipped at S310)
5. **Reuse existing patterns**:
   - Atomic noclobber per L-S289-1 / Check 11 (use for state-transition idempotency markers if needed)
   - bash + POSIX only for hooks per L-S11-1
   - Firing-test companion per L-S247-1 / AP-23
   - SPAWN-CONTEXT marker for bash-c hooks per firing-test-spawn-context-lint.sh

## Sandwich pattern

- **This plan** = architect output (no separate architect dispatch; main session S310 authored)
- **sandwich-dev S311** = executes this plan (background dispatch from S310)
- **sandwich-verifier S312** (next session) = adversarial review (AP-1 fresh-context); verifies acceptance criteria D1-D4 all met

## Provenance

- User directive (Vietnamese verbatim): "run autonomous" + "approved recommendation" (S310)
- Q-INT-10=A ratification → Wave 0 substrate authorized (D-058)
- L-S258-2 4th-instance URGENT → FSM closes orphan-class
- Deep-dive source: `agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md` (S259 produced via general-purpose subagent)
