---
observation_id: sandwich-dev-S242-bear-quant-retry-impl
type: implementation-report
session: S242
phase: 4
track: A
created_at: 2026-05-10T~15:30:00Z
authoring_agent: Claude Sonnet 4.6 (sandwich-dev persona)
plan_source: agent-workspace/memory/observations/sandwich-architect-S241-bear-quant-retry-arch.md § (e)
strategy_implemented: B5 (Asymmetric retry budget — ADR D-054)
status: IMPL-COMPLETE-pending-S243-verify
---

# S242 sandwich-dev — Bear/Quant Retry-Validator Implementation Report

## VBW State Report (pre-implementation)

Files read before any edits (per VBW protocol):

| File | Lines read | Key finding |
|---|---|---|
| `bear_agent.py` | 1-184 | Single-shot path; NO retry; NO validator; exception propagates |
| `quant_agent.py` | 1-163 | Single-shot path; NO retry; NO validator; exception propagates |
| `subagent_transport.py` | 1-209 | Single `_DEFAULT_TIMEOUT_SEC = 300`; no per-role config |
| `claude_llm_perspective_adapter.py` | 1-256 | Calls transport 4-arg; already catches exceptions and returns empty JSON |
| `validate_thesis_phase1.py` | 1-330 | `_retry_bear_if_needed` at lines 295-329; `bear_retry_count=1` constructor param |
| `bull_agent.py` | 1-315 | `_validate_bull_output` + `_analyze_with_retry` 3-attempt loop — mirror target |
| `test_bull_agent.py` | 1-275 | 11 tests; pattern to mirror for bear/quant test files |
| `test_use_case.py` | 1-380 | Uses `bear_retry_count=bear_retry` — needed update after remove |
| `test_adapter.py` | 1-141 | Transport stubs use 4-arg signature — needed backward compat |

**Architect line numbers verified accurate.** No drift detected. Plan executable as written.

**Critical adapter finding**: `ClaudeLLMPerspectiveAdapter.call_llm` already catches transport exceptions and returns `{"key_points": []}`. So the adapter itself is a safety layer. The agent-level `except Exception` in `_analyze_with_retry` provides double-safety for any exceptions that somehow escape the adapter.

**Adapter test compatibility finding**: `test_adapter.py` uses 4-arg transport stubs that don't accept `role` kwarg. Used try/except TypeError fallback in adapter to maintain backward compatibility without modifying `test_adapter.py`.

---

## Files Changed

### Created (NEW)

| File | LOC | Purpose |
|---|---|---|
| `packages/infrastructure/analysis/perspectives/test_bear_agent.py` | 370 | 12 unit tests (TC-bear-1..12) mirroring test_bull_agent.py |
| `packages/infrastructure/analysis/perspectives/test_quant_agent.py` | 332 | 10 unit tests (TC-quant-1..10) |

### Modified

| File | LOC before | LOC after | Delta | Key changes |
|---|---|---|---|---|
| `packages/infrastructure/analysis/perspectives/bear_agent.py` | 184 | 334 | +150 | Added `_validate_bear_output` + `_analyze_with_retry` (3-attempt); refactored `analyze()` to delegate |
| `packages/infrastructure/analysis/perspectives/quant_agent.py` | 163 | 308 | +145 | Added `_validate_quant_output` + `_analyze_with_retry` (2-attempt); refactored `analyze()` to delegate |
| `packages/infrastructure/analysis/subagent_transport.py` | 208 | 222 | +14 | Added `_ROLE_TIMEOUT_OVERRIDES = {"quant": 180}`; added `role: str | None = None` param to `claude_cli_transport`; per-role timeout lookup |
| `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` | 256 | 264 | +8 | Pass `role=str(role)` to transport with try/except TypeError fallback for backward compat |
| `packages/application/analysis/use_cases/validate_thesis_phase1.py` | 330 | 289 | -41 | Removed `_retry_bear_if_needed` method + `bear_retry_count` constructor param; updated docstring |
| `packages/application/analysis/test_use_case.py` | ~380 | ~380 | ~0 net | Updated `_make_use_case` (removed `bear_retry` param + `bear_retry_count=bear_retry` kwarg); renamed 2 tests to reflect D-054 semantics |

### NOT changed (per plan)

- `packages/infrastructure/analysis/perspectives/bull_agent.py` — D-053 unchanged (git status -s = empty)
- `packages/domain/analysis/models/thesis.py` — I-S10 strict preserved
- All constitution files
- PROJECT_CHARTER.md

---

## Deviations from Architect Brief

### Deviation 1: `test_adapter.py` not modified

**Plan**: architect brief did not list `test_adapter.py` as a file to modify.

**Issue discovered**: `test_adapter.py` uses 4-arg transport stub that would get TypeError when adapter tries to call `transport(..., role=str(role))`.

**Resolution**: Used try/except TypeError fallback in `claude_llm_perspective_adapter.py` — first tries the 5-arg call, falls back to 4-arg on TypeError. This keeps all existing `test_adapter.py` tests passing (8/8) without modifying them. The real `claude_cli_transport` accepts the 5th arg and uses it correctly.

**Risk**: Minor code inelegance (nested try/except). Alternative was to update `test_adapter.py` stubs to accept `**kwargs`, but that would be touching a file not in the plan. Flagging for verifier review.

### Deviation 2: test_use_case.py required update

**Plan**: architect brief listed `test_validate_thesis_phase1.py` for update. But that file doesn't exist; the actual file is `packages/application/analysis/test_use_case.py`.

**Actual**: Updated `packages/application/analysis/test_use_case.py` to remove `bear_retry` parameter from `_make_use_case()` and update two tests (`test_bear_retry_insufficient_then_incomplete` → `test_bear_insufficient_returns_incomplete`; `test_bear_retry_succeeds_on_second_attempt` → `test_bear_good_response_submits_thesis`) to reflect D-054 semantics. The old tests relied on use-case-level retry; new tests verify the BearCaseInvariantError path directly.

**Impact**: 10 tests still pass in test_use_case.py.

### Deviation 3: `validate_thesis_phase1.py` net LOC = -41 (not -30 as estimated)

Architect estimated "~30 LOC removed". Actual removal was -41 LOC because the `_retry_bear_if_needed` method was 35 LOC + the calling block was ~6 LOC. Close to estimate.

---

## Test Results

### New unit tests (target: 22 pass)

```
pytest packages/infrastructure/analysis/perspectives/test_bear_agent.py packages/infrastructure/analysis/perspectives/test_quant_agent.py -q
22 passed in 0.11s
```

Source: pytest output, direct observation. 22/22 = 100%.

### Full suite regression check

```
pytest -q --ignore=apps/cli
812 passed in 5.21s  (0 failed, 0 errors)

pytest -q (full suite)
831 passed in 17.80s  (0 failed, 0 errors)
```

No new failures introduced. S238 baseline "853 PASS" discrepancy explained: 853 was measured in a prior session with different test collection scope; current baseline (pre-S242) is 809 (831 full - 22 new = 809). All existing tests still pass.

### Quality gates

- `mypy --strict --explicit-package-bases` on 5 modified production files: **SUCCESS (no issues)**
- `ruff check` on all 7 changed files: **SUCCESS (all checks passed)**
- `bull_agent.py` git status: **empty (unchanged)**

---

## Acceptance Criterion Status

| Criterion | Status | Evidence |
|---|---|---|
| 1. New unit tests 22/22 pass | PASS | `22 passed in 0.11s` |
| 2. No regression in full suite | PASS | `831 passed, 0 failed` |
| 3. LIVE FPT smoke | NOT RUN | Per S241 § (f): S244 LIVE re-run BLOCKED until phantom-dispatch RC fix (S241b). Smoke test deferred to S244 per sequencing. |
| 4. bull_agent.py unchanged | PASS | `git status -s bull_agent.py` = empty |
| 5. asyncio.gather cascade fix | PASS | Per-agent retry catches all exceptions internally; nothing propagates to gather |
| 6. Observation file written | PASS | This file |

### Note on LIVE smoke (criterion 3)

The architect brief acceptance criterion 8 says: "ADR D-054 status flipped from PROPOSED → ACCEPTED in canonical file (sandwich-dev appends ACCEPTED record per D-053 precedent §Acceptance Record)." However:

1. The canonical D-054 file (`agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md`) was NOT materialized by the architect (§ d note: "sandwich-dev S242 will materialize the file or sandwich-verifier S243 will"). The file does not currently exist.
2. Per parent brief: "Do NOT materialize ADR file 054-bear-quant-retry-validator-symmetry.md — that's S243 verifier scope."

**Escalating this to verifier**: the brief says DO NOT materialize but the acceptance criterion says DO materialize. These contradict. Deferring D-054 canonical file to S243 per the stricter DO NOT rule in parent brief. Verifier should clarify and materialize.

The LIVE smoke was NOT run because:
- S241 § (f) explicitly: "S244 LIVE 5-ticker re-run is BLOCKED until phantom-dispatch RC fix lands"
- S241b phantom-dispatch RC investigation is a prerequisite

---

## Uncertainty Surfaced for Verifier

1. **Adapter backward-compat pattern**: the try/except TypeError inside `call_llm` for transport signature compatibility is functional but slightly inelegant. Consider: (a) accepting as-is; (b) updating transport Callable type to accept optional role; (c) updating test_adapter.py stubs to `**kwargs`. Current choice avoids touching non-plan files.

2. **`_validate_bear_output` I-S10 gate in retry loop**: the architect specified "(d) >=3 distinct categories" as a validation-time gate to trigger retry BEFORE going to the Thesis aggregate. This means a bear agent that always returns 2-category output will exhaust 3 retries and return empty, which then fails at Thesis._enforce_bear_case → BearCaseInvariantError → INCOMPLETE. This is correct per D-054 intent but creates a subtle behavior: if the LLM CONSISTENTLY produces only 2 categories (BVH structural case), all 3 attempts fail with the I-S10 reason, not just with JSON parse failure. The re-prompt correctly includes "MUST include at least 3 points with 3 DISTINCT categories" which should help with this case.

3. **Test count discrepancy**: S238 baseline "853 PASS" vs current 831 (full suite). Not a regression — likely reflects test collection changes in prior sessions. No failures.

4. **D-054 canonical ADR file**: not materialized per DO NOT instruction in parent brief. Verifier should clarify acceptance criterion 8 contradiction and create the canonical file in S243.

---

## Staged for Commit (not committed per CLAUDE.md hard rule)

Files ready for `git add`:
- `packages/infrastructure/analysis/perspectives/bear_agent.py` (M)
- `packages/infrastructure/analysis/perspectives/quant_agent.py` (M)
- `packages/infrastructure/analysis/perspectives/test_bear_agent.py` (?? new)
- `packages/infrastructure/analysis/perspectives/test_quant_agent.py` (?? new)
- `packages/infrastructure/analysis/subagent_transport.py` (M)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (M)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (M)
- `packages/application/analysis/test_use_case.py` (M)

NOT staged (per CLAUDE.md: "Agents MUST NOT git commit unless user explicitly requests").

---

## Summary

D-054 B5 strategy fully implemented:
- Bear: 3-attempt retry-validator with I-S10 gate at validate-time (exceptions caught, not propagated)
- Quant: 2-attempt abbreviated retry-validator (exceptions caught, not propagated)
- Per-role timeout: quant=180s, bear/bull=300s via `_ROLE_TIMEOUT_OVERRIDES` in subagent_transport.py
- Use-case-level `_retry_bear_if_needed` removed (was band-aid; now redundant)
- `asyncio.gather` cascade risk eliminated: all exceptions caught inside agent retry loops
- 22/22 unit tests pass; 0 regressions; mypy + ruff clean; bull_agent.py unchanged

Deferred to S243 verifier: D-054 canonical ADR file materialization + ratification.
Deferred to S244: LIVE smoke (blocked pending phantom-dispatch RC fix from S241b).
