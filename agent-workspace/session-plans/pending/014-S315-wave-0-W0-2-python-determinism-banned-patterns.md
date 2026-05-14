---
plan_id: 014-S315-wave-0-W0-2-python-determinism-banned-patterns
phase: 4 (Wave 0 substrate sub-wave W0-2)
status: pending-execution
authored: 2026-05-14
authored_session: S314 (post-W0-1b verifier PASS verdict)
authoring_agent: Claude Opus 4.7 (main session post-S314 PASS)
executing_agent: sandwich-dev (background dispatch S314→S315)
binding_decisions:
  - D-058 Q-INT-10=A authorizes Wave 0 substrate (this is W0-2 of 5 sub-waves)
predecessor_plan: agent-workspace/session-plans/completed/013-S313-wave-0-W0-1b-orphan-reescalate-and-schema-fix.md (W0-1 + W0-1b ROBUSTLY CLOSED)
verifier_input: S314 sandwich-verifier verdict PASS (returned 10:25 SEAST; agentId=a29614856d33e0031)
mode: FOCUSED_IMPL
estimated_envelope: 80-120K tokens
---

# Wave 0 W0-2 — Python Determinism Banned-Patterns Enforcement (DST-style)

## Goal

Port nautilus_trader's DST (Deterministic Simulation Testing) banned-pattern enforcement doctrine to Python via `scripts/hooks/python-determinism-check.sh`. Promotes "determinism over flakiness" alongside existing Charter Principle 8 "calibration over confidence". Pairs with `drift-signals.md` DR-style audit.

## Source material

- **Deep-dive citation**: `agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md` §1.5 "DST doctrine — seed-replayable testing"
- **Upstream reference**: `C:/htdocs/research/nautilus_trader/docs/concepts/dst.md:140-180` (5-rule enforcement script)
- **Stockforge-Python adaptation**: same observation file §1.5 bullet list (4 banned patterns for Python primary stack)

## Deliverables (acceptance criteria)

### D1 — Deterministic-check hook
- **Path**: `scripts/hooks/python-determinism-check.sh` (NEW; ~150 LOC bash)
- **Trigger**: PostToolUse hook (after Edit/Write completes on `.py` file) + Stop hook (full-tree audit)
- **Scope**: Scan `packages/**/*.py` + `apps/**/*.py`
- **4 banned-pattern rules**:
  - **R1** `datetime.now()` without timezone arg → ERR ("use `datetime.now(timezone.utc)`")
  - **R2** `random.random()` / `random.randint()` / `secrets.token_*()` outside `if __name__ == "__main__"` or `test_*` cells → ERR ("use seeded-RNG per-test fixture")
  - **R3** Dict iteration order assumption — heuristic: `for k in <dict>:` followed by index-based logic OR `list(<dict>.keys())[0]` etc → WARN ("use OrderedDict if iteration order matters")
  - **R4** `time.time()` in `packages/domain/**` → ERR ("domain layer pure functions only; no clock access")
- **Severity emission**: violations land in `.severity-state.tsv` as HIGH severity (per `severity-schema.md` Layer 4 — code-quality violations)
- **Best-effort**: RC=0 always (never blocks Stop chain). WARN-only first instance; escalate to ERR after 3 sessions (per CLAUDE.md ritual demotion mirror: WARN→BLOCKING after 5 clean sessions to avoid false-positive churn).
- **Idempotency**: hour-bucket marker per file path (avoid re-flagging same file multiple times per session).

### D2 — Companion firing-test
- **Path**: `scripts/hooks/firing-tests/python-determinism-check-fire-test.sh` (NEW)
- **SPAWN-CONTEXT**: `positional-arg` (the hook reads file paths from stdin or args)
- **Test cases** (≥10 TC):
  - TC1: `datetime.now()` literal → R1 fires
  - TC2: `datetime.now(timezone.utc)` → no fire
  - TC3: `random.random()` in module-level code → R2 fires
  - TC4: `random.random()` inside `if __name__ == "__main__":` → no fire
  - TC5: `random.random()` in `test_*.py` test fixture → no fire
  - TC6: `secrets.token_urlsafe()` in app code → R2 fires
  - TC7: Dict iteration with index → R3 WARN
  - TC8: `time.time()` in `packages/domain/` → R4 fires
  - TC9: `time.time()` in `packages/infrastructure/` → no fire (allowed)
  - TC10: empty file / no Python content → no fire
  - TC11: legitimate code (no banned patterns) → 0 violations
  - TC12: file outside scan scope (e.g., `scripts/hooks/foo.py` if any) → not scanned

### D3 — ADR documenting determinism contract
- **Path**: `agent-workspace/memory/decisions/059-python-determinism-contract.md` (NEW; ADR-tier IMPL with charter alignment to Principle 8)
- **Content**:
  - What is guaranteed seed-reproducible (e.g., thesis ranking, calibration sort-order)
  - What is platform-scoped (e.g., float precision per platform — same as nautilus dst.md:332-334)
  - 4 banned patterns + rationale per rule
  - Reference to bash hook + firing-test
  - Compliance enforcement: WARN-only for 5 sessions; promote to BLOCKING after clean run
- **Charter alignment**: extends Principle 8 "calibration over confidence" with "determinism over flakiness"

### D4 — Wire into settings.json
- **Edit**: `.claude/settings.json` — add `python-determinism-check.sh` to:
  - PostToolUse chain (matcher: `Edit|Write|MultiEdit` for `.py` files; runs on-demand)
  - Stop chain (full audit; after `severity-classifier.sh` so violations land in state.tsv)

### D5 — DoD verification
- ✅ Firing-test 12/12 PASS
- ✅ Bash-hook-lint clean (Check 1-11 + lint of new hook itself)
- ✅ Live run on `packages/domain/observation_lifecycle/fsm.py` — should find 0 violations (FSM is pure)
- ✅ Live run on `scripts/` — should find 0 violations (bash, not Python)
- ✅ Smoke: synthesize Python file with all 4 banned patterns → verify all 4 violations detected
- ✅ ADR `059-python-determinism-contract.md` written
- ✅ Author session log `agent-workspace/memory/sessions/2026-05-14-session-315.md`
- ✅ NO commit per CLAUDE.md hard rule

## Out of scope (defer)

- **R3 sophistication**: heuristic only this session; full AST-based dict-order-dependency detection is a separate session (more reliable but more complex)
- **WARN→BLOCKING ratchet automation**: the WARN-after-5-clean-sessions mechanism is documented in ADR but not enforced by hook yet (manual decision at S320+)
- **W0-3/4/5 sub-waves**: separate sessions
- **Migration of existing code**: this session SHIPS the hook; remediation of existing violations is a separate cleanup pass (likely zero violations now since stockforge codebase is small)

## Hard constraints

1. NO LLM math (I-S1) — banned-pattern detection is deterministic regex/grep
2. bash + POSIX only for the hook (L-S11-1)
3. NO commit
4. NO charter/constitution edits (ADR is in `decisions/`, not `constitution/`)
5. Firing-test SPAWN-CONTEXT marker (L-S247-1)
6. Hour-bucket marker for idempotency (L-S108-1)
7. RC=0 always (best-effort)

## Provenance

- Q-INT-10=A ratification (D-058) authorizes Wave 0 substrate
- W0-1 + W0-1b ROBUSTLY CLOSED at S312 + S314 (verifier PASS at 10:25 SEAST)
- nautilus_trader DST doctrine source: deep-dive S259 §1.5
- User directive "run autonomous" (S310) + ongoing approval
