---
id: D-054-bear-quant-retry-validator-symmetry
title: Bear/Quant retry-validator symmetry B5 asymmetric budget
date: 2026-05-10
status: ACCEPTED
level: IMPL

author:
  - Claude Opus 4.7 sandwich-architect S241
  - Claude Sonnet 4.6 sandwich-dev S242
  - Claude Opus 4.7 sandwich-verifier S243

source_evidence:
  - path: agent-workspace/memory/observations/track-A-S240-anti-flake-run2.md
    section: L-S240-1
  - path: agent-workspace/memory/observations/sandwich-architect-S241-bear-quant-retry-arch.md
    section: probe matrix and B5 recommendation
  - path: agent-workspace/memory/observations/sandwich-dev-S242-bear-quant-retry-impl.md
    section: Files Changed; Test Results; Deviations
  - path: agent-workspace/memory/observations/sandwich-verifier-S243-d054-ratification.md
    section: Adversarial review and verdict
  - path: packages/infrastructure/analysis/perspectives/bear_agent.py
    section: lines 145-334 _validate_bear_output and _analyze_with_retry
  - path: packages/infrastructure/analysis/perspectives/quant_agent.py
    section: lines 129-308 _validate_quant_output and _analyze_with_retry max 2 attempts
  - path: packages/infrastructure/analysis/subagent_transport.py
    section: lines 56-64 _ROLE_TIMEOUT_OVERRIDES quant 180s
  - path: packages/application/analysis/use_cases/validate_thesis_phase1.py
    section: _retry_bear_if_needed REMOVED; asyncio.gather safe
  - path: PROJECT_CHARTER.md
    section: Principle 11 cost discipline plus BR-6 and I-40 cap

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 45

options_considered:
  - id: B1
    summary: Mirror A2 retry-validator on bear and quant identically (3 attempts each)
    pros: [Exact mirror of D-053, Lowest impl risk]
    cons: [Triple-worst-case 3.30 USD breaches Principle 11, Quant 3x wasteful]
  - id: B2
    summary: Fall-through degraded bear with new ThesisStatus.DEGRADED
    pros: [Cost-neutral]
    cons: [Amends I-S10, Violates adversarial-by-default, AP-7 RED FLAG]
  - id: B3
    summary: Hybrid A2-retry then fall-through degraded if exhausted
    pros: [Addresses root cause and tail]
    cons: [High complexity, Same I-S10 amendment risk in tail]
  - id: B4
    summary: Sequence-runs cooling period (runbook only)
    pros: [Trivial]
    cons: [AP-7 RED FLAG, L-S240-1 calls insufficient]
  - id: B5
    summary: Asymmetric retry (bear 3x; quant 2x + 180s timeout; per-role config)
    pros: [Addresses root cause, Respects cost cap, Preserves I-S10, Mirrors D-053, Quant abbreviation justified]
    cons: [New per-role config surface, Quant 2-cap residual flake risk]

chosen: B5
chosen_rationale: |
  Lexicographic (charter-comply DESC, root-cause DESC, impl-risk ASC, mirror-D053 DESC):
  B1/B2/B3 fail charter; B4 fails root-cause (AP-7).
  B5 is sole strategy passing both filters. Auto-pick fires per Q-P4-1.

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-10
    via: S241 sandwich-architect dispatch
  - actor: agent
    action: IMPLEMENTED
    at: 2026-05-10
    via: S242 sandwich-dev dispatch
  - actor: agent
    action: ACCEPTED
    at: 2026-05-10
    via: S243 sandwich-verifier fresh-context ratification per AP-1

verified_by:
  - mechanism: sandwich-verifier
    at: 2026-05-10
    result: PASS
    notes: 22/22 unit + 831/831 full PASS; mypy strict + ruff CLEAN; bull unchanged; I-S10 preserved; 3 deviations all PASS
  - mechanism: smoke-test
    at: PENDING-S244
    result: PENDING
    notes: 5-ticker LIVE anti-flake re-run gated on phantom-dispatch lock GREEN pre-flight

affects:
  charter: false
  spec_files:
    - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md
  code_paths:
    - packages/infrastructure/analysis/perspectives/bear_agent.py
    - packages/infrastructure/analysis/perspectives/quant_agent.py
    - packages/infrastructure/analysis/perspectives/test_bear_agent.py
    - packages/infrastructure/analysis/perspectives/test_quant_agent.py
    - packages/infrastructure/analysis/subagent_transport.py
    - packages/infrastructure/analysis/claude_llm_perspective_adapter.py
    - packages/application/analysis/use_cases/validate_thesis_phase1.py
    - packages/application/analysis/test_use_case.py
  config_files: []
  other_decisions: [D-053]

depends_on: [D-053, D-050, D-052]
supersedes: null
superseded_by: null
defer_cycles: 0
re_attempt_prereq: |
  N/A -- ACCEPTED 2026-05-10 (S243 verifier ratification).

tags: [phase-4, track-A, bear-role, quant-role, retry-validator, i-s10, i-40, br-6, production]
---

# Decision 054 -- Bear/Quant Retry-Validator Symmetry (B5 Asymmetric Budget)

## Context

Phase 4 Track A S240 anti-flake gate FAILED (2/5 PASS). R-P4-3 risk realized -- bear/quant 300s timeout cascade is dominant fail-mode under parallel-fanout. Bull has D-053 A2 retry-validator and recovers; bear/quant single-shot path raises BearCaseInvariantError exit 2 SQLite skip.

L-S240-1 root cause chain: bear/quant single-shot raises SubagentSubstrateError on 300s timeout; asyncio.gather propagates first exception; kills all 3 perspectives. The use-case _retry_bear_if_needed band-aid only handled content insufficiency, NEVER timeout, because gather propagates first.

## Decision

B5 -- bear gets full 3-attempt A2-mirror; quant gets 2-attempt A2-mirror plus 180s per-role timeout. Per-role timeout config added to subagent_transport.py. Use-case _retry_bear_if_needed REMOVED.

### What this means concretely

- bear_agent.py: _validate_bear_output (4-rule including I-S10 ge-3 distinct categories) + _analyze_with_retry (max 3 attempts; exceptions caught inside loop)
- quant_agent.py: _validate_quant_output (3-rule; NO ge-3-cat gate) + _analyze_with_retry (max 2 attempts)
- subagent_transport.py: _ROLE_TIMEOUT_OVERRIDES with quant 180s + role kwarg on claude_cli_transport
- claude_llm_perspective_adapter.py: passes role to transport with try/except TypeError fallback for backward-compat
- validate_thesis_phase1.py: _retry_bear_if_needed REMOVED (-41 LOC); bear_retry_count param REMOVED; asyncio.gather safe because all exceptions caught inside agent retry loops

### What does NOT change

- I-S10 strict invariant preserved (thesis.py:_enforce_bear_case unchanged)
- ThesisStatus enum unchanged (NO new DEGRADED state)
- Bull A2 retry-validator (D-053) unchanged
- BearCaseInvariantError still raised when bear exhausts and post-retry has lt 3 distinct points/cats
- Quant validation-exhausted does NOT trip any invariant

## Why

1. Charter Principle 11 / BR-6 / I-40 cost cap: B5 worst-case under 3.00 USD; B1 breaches at 3.30.
2. CLAUDE.md hard rule Adversarial by default: B5 preserves bear ge-3 distinct cats strictly; B2/B3 violate.
3. L-S240-1 root cause fix: exceptions caught inside retry loops eliminate asyncio.gather cascade.
4. AP-7 anti-pattern discipline: addresses root cause (vs B4 which masks).
5. AP-23 cheapest-by-RISK: DEEPENS D-053 pattern rather than BROADENING.

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Quant 2-attempt cap residual flake | Medium | S244 LIVE measures; if gt 1/5 in 2 runs, REV-1 bumps quant to 3 |
| Per-role timeout config new substrate surface | Low | Bounded 14 LOC; backward-compat via TypeError fallback |
| Bear 3-attempt cumulative wall-clock 900s worst-case | Medium | Acceptable for autonomous use; cost-cap binds first |
| Adapter TypeError fallback inelegance | Low | Functional; mypy + ruff clean; refactor acceptable later |

## Open Questions

None -- auto-pickable per Q-P4-1 lexicographic AUTO-PICK rule.

## Acceptance Record

- 2026-05-10: PROPOSED by Claude Opus 4.7 (sandwich-architect S241) via observation file
- 2026-05-10: IMPLEMENTED by Claude Sonnet 4.6 (sandwich-dev S242) -- 8 files staged; 22/22 unit + 831/831 full PASS; mypy strict + ruff CLEAN
- 2026-05-10: ACCEPTED by Claude Opus 4.7 (sandwich-verifier S243) -- fresh-context empirical close-verify per AP-1; verdict ACCEPTED with no defects (3 dev-flagged deviations all PASS); LIVE smoke gated to S244
