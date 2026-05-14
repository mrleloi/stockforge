---
id: D-059-python-determinism-contract
title: Python Determinism Contract — DST-style banned-pattern enforcement
date: 2026-05-14
status: PROPOSED
level: IMPL

author:
  - "Claude Sonnet 4.6 (sandwich-dev S315)"

source_evidence:
  - path: agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md
    section: "§1.5 DST (Deterministic Simulation Testing) doctrine — seed-replayable testing"
    quote: "stockforge already has pre-commit hooks under scripts/hooks/; adopt DST-style banned-pattern grep"
  - path: agent-workspace/session-plans/pending/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md
    section: "Deliverables D3"
  - path: agent-workspace/constitution/severity-schema.md
    section: "§2 Mapping — code-quality violations land as HIGH"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 20

options_considered:
  - id: A
    summary: "Bash hook with 4 banned-pattern regex rules (DST-style)"
    pros:
      - "Zero new tooling — bash + POSIX grep"
      - "Phase 0 portability (L-S11-1)"
      - "Directly portable from nautilus_trader dst.md:140-180"
    cons:
      - "R3 (dict iteration) is heuristic-only; full AST analysis more accurate"
      - "R2 (__main__ detection) is awk heuristic, not AST-precise"
  - id: B
    summary: "Python AST-based checker (pyflakes extension or custom)"
    pros:
      - "Precise: handles nested scopes, conditional imports"
    cons:
      - "Requires python invocation in hook (violates L-S11-1 Phase 0 portability)"
      - "More complex; defer to Phase 1+"

chosen: A
chosen_rationale: |
  Option A matches L-S11-1 (bash + POSIX only for hooks), Phase 0 scope (~150 LOC), and
  directly ports the nautilus_trader DST doctrine. R3 AST precision is explicitly deferred
  (per plan out-of-scope) — heuristic coverage is sufficient for current stockforge Python
  corpus which is small and well-typed. Option B is appropriate post-Phase-0.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-14
    via: "S315 sandwich-dev dispatch (014-S315 plan)"

verified_by:
  - mechanism: firing-test
    at: 2026-05-14
    result: PASS

affects:
  charter: false
  spec_files: []
  code_paths:
    - "packages/**/*.py"
    - "apps/**/*.py"
  config_files:
    - ".claude/settings.json"
  other_decisions:
    - "D-058 (Q-INT-10=A — Wave 0 substrate authorization)"

depends_on:
  - "D-058"

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: "N/A"

tags: ["phase-0", "wave-0", "harness", "determinism", "DST", "python", "W0-2"]
---

# Decision 059 — Python Determinism Contract (DST-style)

## Context

StockForge is Python-primary. Non-deterministic code paths (wall-clock access, unseeded RNG,
dict iteration order assumptions) create flaky test results and corrupt calibration signals.
The nautilus_trader project enforces determinism via a static `check-dst-conventions.sh`
pre-commit hook (dst.md:140-180). This decision ports that doctrine to the Python-primary
stockforge stack.

Charter Principle 8 "calibration over confidence" depends on reproducibility: if a thesis
ranking changes on re-run due to RNG or dict ordering, the calibration signal is invalid.

Source citation: `agent-workspace/memory/observations/general-purpose-S259-deepdive-nautilus_trader.md §1.5`.

## What is Guaranteed Seed-Reproducible

The following MUST produce bitwise-identical output on identical inputs, on the same platform:

1. **Thesis ranking order** — all sorting keys must be deterministic (no `random.*`, no hash-randomized dict iteration).
2. **Calibration metric computation** — any `percentile_service`, `ratio_service`, or signal-scoring function.
3. **Domain entity construction** — `Bar`, `FinancialStatement`, `Position`, `ExtractedClaim` value objects must not call wall-clock at construction time.
4. **Test fixture teardown order** — test suite must not depend on dict iteration order for cleanup.

## What is Platform-Scoped (Not Guaranteed Cross-Platform)

Per nautilus_trader dst.md:332-334 equivalent:

- **Float precision**: Python `float` is IEEE-754 64-bit on all stockforge-supported platforms; no cross-platform divergence expected for current use cases.
- **Filesystem sort order**: `os.listdir()` / `glob.glob()` ordering is OS-dependent. Sort explicitly before iterating.
- **Locale-dependent string collation**: not used in stockforge domain layer.

## The 4 Banned Patterns

### R1 — `datetime.now()` without timezone

**Banned in**: `packages/**/*.py`, `apps/**/*.py`
**Violation severity**: ERR (HIGH)

```python
# BANNED
ts = datetime.now()

# ALLOWED
from datetime import timezone
ts = datetime.now(timezone.utc)
```

**Rationale**: `datetime.now()` returns local-time without timezone info. On different machines
or DST transitions, the same code returns different values. Stockforge uses ISO-8601 UTC
throughout (per `r-2026-05-13-trading-infra-cluster.md:43`).

### R2 — Unseeded RNG outside `__main__` or test files

**Banned in**: `packages/**/*.py`, `apps/**/*.py` (not in test fixtures or `__main__` blocks)
**Violation severity**: ERR (HIGH)

Patterns banned:
- `random.random()`
- `random.randint()`
- `random.choice()`, `random.shuffle()`, `random.sample()`
- `secrets.token_urlsafe()`, `secrets.token_hex()`, `secrets.token_bytes()`

**Allowed contexts**:
- Inside `if __name__ == "__main__":` blocks (scripts, not test-path)
- Inside `test_*.py` / `*_test.py` files (test fixtures may use explicit seeds)

**Rationale**: Unseeded RNG makes thesis-ranking and calibration non-reproducible. Monte Carlo
simulations must be seeded explicitly (per test fixture contract) so results can be replayed.

### R3 — Dict iteration order assumption (heuristic)

**Detected in**: `packages/**/*.py`, `apps/**/*.py`
**Violation severity**: WARN (HIGH-escalatable)

```python
# WARN: index assumption on dict keys
first_key = list(d.keys())[0]

# PREFERRED: explicit OrderedDict or sorted()
from collections import OrderedDict
od = OrderedDict(d)
first_key = next(iter(od))
```

**Rationale**: Although Python 3.7+ guarantees insertion-order for `dict`, code that extracts
elements by index from `dict.keys()` may be porting assumptions from older code or from
contexts where dict construction order is uncertain (e.g., merged dicts from API responses).
Explicit `OrderedDict` documents the intent; `sorted()` makes the order reproducible even
across insertion orders.

**Note**: This is a heuristic regex scan only. Full AST-based detection is deferred to Phase 1+
(per plan 014-S315 out-of-scope). False negatives exist for complex index patterns.

### R4 — `time.time()` in `packages/domain/**`

**Banned in**: `packages/domain/**/*.py` only
**Violation severity**: ERR (HIGH)

```python
# BANNED in domain layer
import time
epoch = time.time()

# ALLOWED: infrastructure layer may call time.time() for polling/latency
# packages/infrastructure/market_data/poller.py — OK
```

**Rationale**: Domain layer = pure functions per DDD invariant (CLAUDE.md hard rule: "Domain
layer has ZERO framework dependency"). Wall-clock access makes domain functions stateful and
non-testable without time mocking. `time.time()` in infrastructure is allowed (polling loops,
cache TTL computation).

## Enforcement

**Hook**: `scripts/hooks/python-determinism-check.sh`
- PostToolUse trigger: scans edited `.py` file when Edit/Write targets `packages/**/*.py` or `apps/**/*.py`
- Stop trigger: full tree audit of `packages/**/*.py` + `apps/**/*.py`
- RC=0 always (best-effort; never blocks Stop chain)
- Idempotency: hour-bucket marker per file (L-S108-1)
- Atomic marker writes (L-S289-1)

**Firing-test**: `scripts/hooks/firing-tests/python-determinism-check-fire-test.sh` (12 TC)

**Severity**: violations emit HIGH to `.session-hooks.log` and write a notification file
(ALERT keyword) for `severity-classifier.sh` → `escalation-engine.sh` chain.

## WARN→BLOCKING Ratchet (future)

Per plan, WARN-only for current session. The ratchet to BLOCKING is NOT automated yet:

- WARN-only: first 5 clean sessions after ship (S315-S320)
- Promote to BLOCKING: manual decision at S320+ once false-positive rate assessed
- Mechanism to automate: count clean sessions via marker file; hook switches severity_level
  from WARN to ERR after threshold (deferred per plan out-of-scope)

## Charter Alignment

- Extends Charter Principle 8 "calibration over confidence" with **"determinism over flakiness"**
- Supports I-S1 (NO LLM math): deterministic code = verifiable inputs; flaky code = unverifiable
- Pairs with `drift-signals.md` DR-style audit (DR class for new violations)
- Reference: nautilus_trader dst.md:140-180 (5-rule static enforcement) adapted for Python

## Acceptance Record

- **2026-05-14**: PROPOSED by Claude Sonnet 4.6 (sandwich-dev S315)
