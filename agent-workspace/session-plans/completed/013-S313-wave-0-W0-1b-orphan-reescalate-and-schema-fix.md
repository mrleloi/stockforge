---
plan_id: 013-S313-wave-0-W0-1b-orphan-reescalate-and-schema-fix
phase: 4 (Wave 0 substrate)
status: pending-execution
authored: 2026-05-14
authored_session: S312 (verifier surfaced 2 important defects)
authoring_agent: Claude Opus 4.7 (main session post-S312 verifier verdict)
executing_agent: sandwich-dev (background dispatch S312→S313)
binding_decisions:
  - D-058 Q-INT-10=A authorizes Wave 0 substrate (includes follow-up fixes)
predecessor_plan: agent-workspace/session-plans/completed/012-S311-wave-0-W0-1-fsm-impl.md
verifier_input: S312 sandwich-verifier verdict PASS-WITH-CONCERNS (returned 10:14 SEAST; agentId=a9d1a629277c72e17)
mode: FOCUSED_IMPL
estimated_envelope: 60-100K tokens (sub-wave; smaller than W0-1)
---

# Wave 0 W0-1b — Orphan Re-Escalation + TSV Schema last_transition_at fix

## Goal

Close 2 IMPORTANT defects flagged by S312 verifier that undermine L-S258-2 4th-instance URGENT closure claim:

1. **F1 — Single-shot escalation gap**: Currently orphan-detector emits HIGH severity row ONLY at the moment of IN_FLIGHT→ORPHANED transition. severity-classifier atomically rewrites `.severity-state.tsv` each Stop, so the HIGH row is purged. Next Stop: orphan-detector sees row already ORPHANED → no re-emit. Result: if user dismisses AskUserQuestion OR misses it, orphan goes silent forever. **This recreates the exact slip pattern that caused L-S258-2 (4 instances).**

2. **F2 — `detected_ts` as age proxy**: orphan-detector computes age from TSV col1 `detected_ts` (when row was first written), NOT from `last_transition_at`. Once W0-2/3/4 wires FSM state writers, a row that lived in IN_FLIGHT for hours before transitioning to OBSERVATION_WRITTEN will be **falsely orphaned within minutes** of the OBSERVATION_WRITTEN transition.

## Deliverables (acceptance criteria)

### D1 — Re-escalation: orphan-detector emits HIGH for already-ORPHANED rows
- **Edit**: `scripts/hooks/observation-orphan-detector.sh`
- **New behavior**: when scanning a row already in state ORPHANED, compute time since the last HIGH-severity emit for THAT artifact. If >Nh (default 6h, configurable via env `STOCKFORGE_ORPHAN_REESCALATE_HOURS`), emit a NEW HIGH severity row to `.severity-state.tsv`.
- **Tracking the last emit**: use marker file `agent-workspace/memory/.orphan-reescalate-<HASH>.last` per artifact (hash = sha of artifact path). Read mtime → compute hours-since.
- **Re-emit schedule** (defaults): 6h, 24h, 72h, then every 7d. Each emit updates the marker mtime. After 30 days no resolution → escalate to CRITICAL.
- **Tests** (extend `observation-orphan-detector-fire-test.sh`): add TC9 (already-ORPHANED row + marker absent → re-emit HIGH); TC10 (already-ORPHANED + marker <6h → skip); TC11 (already-ORPHANED + marker >30d → escalate to CRITICAL).

### D2 — TSV schema extension: col7 `last_transition_at`
- **Edit**: `packages/domain/observation_lifecycle/fsm.py`
- **New serialization**: TSV row schema becomes `detected_ts<TAB>...<TAB>state<TAB>last_transition_at`. Back-compat: 6-col rows (no col7) → default `last_transition_at = detected_ts` on first read; auto-upgraded on next state mutation.
- **Reader changes**: `is_orphan_candidate(threshold_minutes)` MUST use `last_transition_at`, not row mtime.
- **Writer changes**: any state transition writes new col7 = current ISO timestamp.
- **Edit**: `scripts/hooks/observation-orphan-detector.sh` — read col7 if present; fall back to col1 (detected_ts) if absent (back-compat).
- **Tests**: extend `test_fsm.py` with TC for (a) 6-col legacy → upgraded to 7-col with last_transition_at = detected_ts; (b) state transition updates col7 to current time; (c) `is_orphan_candidate` uses col7 not col1.

### D3 — F3 minor cosmetic: inline-document RECTIFIED → RESOLVED-only rationale
- **Edit**: `packages/domain/observation_lifecycle/fsm.py:64-85`
- Add a docstring comment block above `LEGAL_TRANSITIONS`:
  ```python
  # Note: RECTIFIED → RESOLVED only (NOT RECTIFIED → SIDECAR_ATTESTED).
  # Recovery flow must visibly terminate at RESOLVED so audit trail shows
  # human-rectified vs happy-path-attested as distinct outcomes.
  # See S312 verifier V2.1 for full rationale.
  ```

### D4 — F4 firing-test gap: empty CLAUDE_SESSION_ID path
- **Edit**: `scripts/hooks/firing-tests/observation-orphan-detector-fire-test.sh` (or create new dedicated firing-test for pre-checkpoint-close-verifier)
- Add TC: empty `CLAUDE_SESSION_ID` env → pre-checkpoint-close-verifier skips gracefully (RC=0, no false block).

### D5 — F5 cosmetic: correct dev's handoff note #5 in session-311 log
- **Edit**: `agent-workspace/memory/sessions/2026-05-14-session-311.md`
- Find dev's handoff note #5 (about severity-classifier ordering) and append correction: "**S312 verifier correction**: empirical test confirmed escalation-engine DOES pick up appended rows in same Stop chain. The original concern is moot. The actual concern is single-shot escalation (see V2.3-b in S312 verifier report → addressed in W0-1b D1)."

### D6 — DoD verification
- ✅ `pytest packages/domain/observation_lifecycle/` → all green (≥50 tests now)
- ✅ `mypy --strict packages/domain/observation_lifecycle/` → clean
- ✅ `ruff check packages/domain/observation_lifecycle/` → clean
- ✅ Firing-test `observation-orphan-detector-fire-test.sh` → all PASS (≥11 TC now)
- ✅ Smoke: synthesize ORPHANED row >6h since last emit → orphan-detector → new HIGH row emitted; <6h since last emit → no re-emit
- ✅ Back-compat: 6-col rows (W0-1 era) and 5-col rows (pre-W0-1) both handled
- ✅ Author session log `agent-workspace/memory/sessions/2026-05-14-session-313.md`
- ✅ NO commit per CLAUDE.md hard rule

## Out of scope (defer to later)

- F3 (cosmetic): see D3 above (IS in scope, low-cost cosmetic)
- W0-2/3/4/5 substrate items (separate sub-waves; not blocked by W0-1b)
- L-S312-1/2/3 lesson promotion (handled by main session, not dev)
- Charter v1.2 amendment for FSM-as-binding (defer)

## Hard constraints

1. NO LLM math (I-S1)
2. Pure Python dataclass in domain layer
3. NO commit
4. NO charter/constitution edits
5. bash + POSIX only for hooks (L-S11-1)
6. Firing-test SPAWN-CONTEXT marker (L-S247-1)
7. Atomic noclobber for any marker writes (L-S289-1 / Check 11)

## Provenance

- S312 verifier report (returned 10:14 SEAST; agentId=a9d1a629277c72e17): F1 + F2 + F3 + F4 + F5 from §Defects summary
- L-S312-1 promotion candidate: "Single-shot escalation pattern is brittle for never-resolving orphans" — D1 addresses this directly
- L-S312-3 promotion candidate: "Age proxies from immutable timestamps create false-flag risk" — D2 addresses this directly
- User directive "run autonomous" + "approved recommendation" (S310): authorizes this follow-up
