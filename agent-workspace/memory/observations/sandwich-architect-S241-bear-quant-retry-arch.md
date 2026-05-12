---
observation_id: sandwich-architect-S241-bear-quant-retry-arch
type: architecture-plan
session: S241
phase: 4
track: A
created_at: 2026-05-10T~13:00:00Z
authoring_agent: Claude Opus 4.7 (sandwich-architect persona)
related_master_plan: agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md §S238 / R-P4-3
related_predecessor_observation: agent-workspace/memory/observations/track-A-S240-anti-flake-run2.md
related_decision_mirror: agent-workspace/memory/decisions/053-a2-retry-validator-promoted-production-default.md
related_lessons: [L-S240-1, L-S240-2, L-S240-3, L-S240-4, L-S240-5]
status: PLAN-COMPLETE-ready-for-S242-impl-dispatch
deliverable_acceptance_target:
  - file_exists: this path
  - sections_a_through_f: present
  - adr_d054_inline_or_canonical: present (inline draft below + canonical path agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md)
  - sandwich_dev_brief: concrete enough to execute without re-planning
  - empirical_probe_rationale: cited (L-S240-1 + master-plan R-P4-3 + asymmetry vs D-053)
  - production_code_changes: zero (PLAN session per CLAUDE.md § Session Types)
---

# S241 sandwich-architect — Bear/Quant Retry-Validator Symmetry Architecture

> Track A residue-fix architecture for L-S240-1 (parallel-fanout bear timeout cascade)
> + R-P4-3 risk realized (compounded retry latency causes parallel-fanout cascade timeout).
>
> Pattern: mirror D-053 A2 retry-validator from bull_agent.py to bear_agent.py + quant_agent.py
> with ONE strategic adjustment for I-S10 invariant preservation.

---

## (a) VBW source-state report

**VBW protocol applied** (per CLAUDE.md hard rule + L-S204-1 doctrine — all claims grounded by literal Read of source, not memory).

### Files probed (literal Read tool calls, not memory)

| File | Lines read | Key observation |
|---|---|---|
| `packages/infrastructure/analysis/perspectives/bull_agent.py` | 1-315 | A2 retry-validator FULL implementation: `_validate_bull_output()` lines 140-178 + `_analyze_with_retry()` lines 212-314; 3 attempts; explicit `bull_failure_mode=validation-exhausted` warning log line 301-306; cumulative cost accumulator across attempts |
| `packages/infrastructure/analysis/perspectives/bear_agent.py` | 1-184 | **SINGLE-SHOT path** lines 156-166: `call_llm` → `json.loads` (try/except → empty raw_points) → `_parse_grounded_points` → `_filter_by_jaccard`. NO retry layer. NO failure_mode telemetry. Silent-empty when JSON parse fails OR LLM raises (exception propagates up) |
| `packages/infrastructure/analysis/perspectives/quant_agent.py` | 1-163 | **SINGLE-SHOT path** lines 137-147: identical pattern to bear (call_llm → json.loads → silent-empty on exception). NO retry; NO `_validate_quant_output()` validator; NO failure_mode telemetry |
| `apps/_shared/use_case_builder.py` | 1-437 | `_build_subagent_agents` lines 146-190: BEAR + BULL + QUANT all wired on same `ClaudeLLMPerspectiveAdapter` w/ `claude_cli_transport`. BULL gets haiku override (line 180). Bear/Quant get default models (sonnet/opus). No per-role retry config |
| `apps/cli/validate_thesis.py` | 1-345 | Exit codes: 0=ok, 1=cost-cap, 2=BearCaseInvariantError OR INCOMPLETE w/ `bear_case_invariant_failed`/`bear_case_insufficient` gap, 3=transport=anthropic, 4=BuildError. Lines 149-151 catch direct `BearCaseInvariantError`; lines 175-181 catch INCOMPLETE-thesis gap variant |
| `packages/application/analysis/use_cases/validate_thesis_phase1.py` | 170-330 | `_run_pipeline` lines 204-293: `asyncio.gather(bear_t, bull_t, quant_t)` line 217 — **propagates first exception** (300s timeout from any role kills whole pipeline; no per-role try/except). `_retry_bear_if_needed` lines 295-329 retries ONLY on `<3 points/cats` content insufficiency, NOT on timeout/exception. Quant has NO retry at any layer |
| `packages/domain/analysis/models/thesis.py` | 1-160 | Thesis aggregate `_enforce_bear_case` lines 91-115: I-S10 invariant strictly enforced — `< 3 key_points` OR `< 3 distinct categories` raises `BearCaseInvariantError`. NO degraded-mode bypass currently |
| `packages/infrastructure/analysis/subagent_transport.py` | grep timeout | `_DEFAULT_TIMEOUT_SEC = 300` line 56; raises `SubagentSubstrateError(f"claude CLI timeout after {_DEFAULT_TIMEOUT_SEC}s")` line 170 |

### Architecture asymmetry (the gap L-S240-1 surfaced)

```
                          retry on JSON-fail   retry on timeout   failure_mode log
  bull_agent.py (D-053):       YES (3x)              YES               YES (validation-exhausted)
  bear_agent.py:               NO                    NO                NO (silent empty)
  quant_agent.py:              NO                    NO                NO (silent empty)

                                content-retry (use-case)   timeout-retry (use-case)
  bear pipeline:                YES (cap=1)                NO (asyncio.gather propagates)
  quant pipeline:               NO                          NO (asyncio.gather propagates)
  bull pipeline:                NO needed                  NO needed (agent-level retry covers)
```

**Empirical fail-mode chain under parallel-fanout (per S240 5-ticker run #2)**:

1. Parent dispatches 5 CLI subprocesses near-simultaneously (1 sync + 4 background).
2. Sonnet (bear) + opus (quant) saturate at backend → 300s `subprocess` timeout fires on bear OR quant.
3. `subagent_transport.py:170` raises `SubagentSubstrateError`.
4. Exception propagates through `bear_agent.analyze()` — NO try/except (vs bull which catches `Exception` at line 253-259 inside the retry loop).
5. `asyncio.gather(bear_t, bull_t, quant_t)` line 217 propagates the first exception → kills all 3 perspectives in flight.
6. CLI `validate_thesis.py` catches at line 149 → `sys.exit(2)` → SQLite write skipped.
7. Result: 2/5 tickers fail (S240); R-P4-3 risk realized.

**Critical insight**: the `_retry_bear_if_needed` use-case-level retry (validate_thesis_phase1.py:295-329) only handles **content insufficiency** (`<3 points/<3 cats`). It is BYPASSED entirely when the bear LLM call raises a timeout exception, because `asyncio.gather` propagates the exception before bear retry logic ever runs.

### Side-finding: D-053 file duplication (governance hygiene)

Two files at canonical D-053 path:
- `agent-workspace/memory/decisions/053-a2-retry-validator-promoted-production-default.md` (indexed in README — canonical)
- `agent-workspace/memory/decisions/053-S237-bull-A2-retry-validator-promote.md` (stale duplicate — NOT indexed)

Recommendation: dev-session in S242 should NOT touch this; flag as separate hygiene item for `decision-registry-deduper` audit. NOT in S241 scope.

### I-S10 charter wording (probed but not found in PROJECT_CHARTER.md or invariants.md by grep)

`I-S10` is referenced extensively in code comments + master-plan + observation files as "bear case ≥3 distinct points across ≥3 distinct categories", but `grep` of PROJECT_CHARTER.md and invariants.md returned no matches — likely the invariant lives under a different ID label or is encoded only in `thesis.py:_enforce_bear_case` (lines 91-115) as the de-facto specification.

**Implication**: any strategy that amends I-S10 semantics (B2/B3) requires either (a) finding+updating the canonical I-S10 wording (charter-tier change → user approval), or (b) adding a new sub-clause "I-S10b: timeout-degraded mode permitted with explicit `bear_failure_mode=insufficient-data` tag and ThesisStatus extension". This routes through CHARTER-tier or SCOPE-tier per CLAUDE.md hard rule "Never modify PROJECT_CHARTER.md without explicit human revision".

---

## (b) 5-strategy probe matrix (empirical-probe-first frame)

Per `.claude/skills/empirical-probe-first/SKILL.md` and L-S204-1 doctrine.

| Strategy | Approach summary | LOC est. | Cost impact (per thesis) | Effort (S242 LOC + tests) | Risk | I-S10 disposition | Charter alignment | Master-plan fit | AP-7 risk |
|---|---|---|---|---|---|---|---|---|---|
| **B1** Mirror A2 retry-validator on bear+quant | Add `_validate_bear_output` + `_analyze_with_retry` (3 attempts, JSON+structural validate, re-prompt with error, `failure_mode=validation-exhausted` log) to `bear_agent.py` AND `quant_agent.py`. Mirror D-053 exactly | ~120 LOC bear + ~80 LOC quant + ~150 LOC tests | Worst-case 3x bear LLM cost (sonnet ~$0.30 → ~$0.90) + 3x quant (opus ~$0.50 → ~$1.50). Combined w/ bull worst-case 3x ~$0.90 = ~$3.30/thesis. **BREACHES $3.00 BR-6 cap on triple-worst-case** | Medium (mirror existing pattern; ~9 unit tests + 3 LIVE smoke tickers) | LOW (well-trodden pattern; D-053 ratified) | PRESERVE hard (BearCaseInvariantError still raised on validation-exhausted) | I-S10 strict; I-40/BR-6 cost cap risked under triple-worst-case | EXACT fit master-plan R-P4-3 mitigation column ("escalate" → architectural fix) | **LOW** — addresses root cause directly |
| **B2** Fall-through-to-degraded-bear (no retry) | When bear empty/timeout, replace BearCaseInvariantError with new `ThesisStatus.DEGRADED` state + `bear_failure_mode=insufficient-data` tag. Persist thesis with 0-2 bear points + clear degraded marker | ~60 LOC thesis aggregate + ~40 LOC use case + new `ThesisStatus.DEGRADED` + ~120 LOC tests + I-S10 amendment ADR | Single-shot cost preserved (~$0.30 + ~$0.50 = ~$0.80/thesis); cheaper than baseline | Medium (touches domain aggregate; requires I-S10 sub-clause amendment) | **HIGH** — amends adversarial-by-default invariant; charter-tier risk; conflicts with CLAUDE.md hard rule "Adversarial by default. Any thesis output includes bear case explicitly" | AMEND I-S10 (sub-clause for degraded mode). Requires CHARTER/SCOPE tier user approval | DIRECTLY VIOLATES CLAUDE.md hard rule "Adversarial by default. Any thesis output includes bear case explicitly. Single-perspective output is anti-pattern" | Master-plan §S238 acceptance gate uses I-S10 strict; amendment needed | **MEDIUM** — masks problem if user permits weakened invariant; AP-7 risk if used as gate-greening shortcut |
| **B3** Hybrid — A2-retry FIRST, fall-through-degraded if exhausted | A2-mirror retry on bear/quant (B1); if all 3 attempts exhaust, emit `ThesisStatus.DEGRADED` w/ `bear_failure_mode=validation-exhausted` instead of raising BearCaseInvariantError. Two-tier graceful degradation | ~150 LOC bear + ~100 LOC quant + ~80 LOC thesis (DEGRADED state) + ~200 LOC tests + I-S10 amendment ADR | Worst-case identical to B1 (~$3.30/thesis); typical ≈ $0.80 (most attempts succeed first try) | High (combines B1+B2 surface; ~14 unit tests + 5 LIVE smoke) | MEDIUM-HIGH (amends I-S10; introduces 2 new states; complex tests) | AMEND I-S10 (sub-clause for retry-exhausted-degraded mode). Charter-tier risk | Same CLAUDE.md "adversarial-by-default" violation as B2 (just deferred to triple-fail tail) | Master-plan §S238 ratified for B1-class; B3 expansion needs §amendment | **LOW-MEDIUM** — addresses root cause AND tail; complex; tail-fall-through could become silent escape hatch |
| **B4** Sequence-runs cooling-period (operational only) | NO code change. Master-plan amendment: "≥10 min lapse between CLI dispatches; max 1 in flight at a time" | 0 LOC code; ~40 LOC master-plan amendment | Cost-neutral; same single-shot cost as today | Trivial (doc edit only) | LOW (no code risk) | I-S10 strict (no amendment) | Compatible | Master-plan §S239 currently 30-min lapse between RUNS; B4 adds intra-run sequencing | **HIGH (AP-7 RED FLAG)** — masks parallel-fanout problem without architecturally addressing single-run timeout fragility. L-S240-1 explicitly calls out this insufficiency: "ARCHITECTURE GAP: bear-quant should also have retry-validator". B4 alone = premature SC-greening (per L-S240-3 warning) |
| **B5** Asymmetric retry budget (bear=3 attempts, quant=2 attempts, lower per-role timeouts) | Mirror A2 on bear (full 3x, like B1); Quant gets ABBREVIATED retry (2 attempts max + lower per-call timeout 180s). Reduces cost worst-case while preserving root-cause fix | ~120 LOC bear (full B1) + ~70 LOC quant (lighter retry) + per-role timeout config in `subagent_transport.py` (~15 LOC) + ~140 LOC tests | Worst-case bear 3x ($0.90) + quant 2x ($1.00) + bull 3x ($0.90) = ~$2.80/thesis. Stays UNDER $3.00 cap | Medium-high (per-role timeout config is new surface; ~12 unit tests + 5 LIVE smoke) | LOW-MEDIUM (mirror pattern + per-role config; new but bounded) | PRESERVE hard (BearCaseInvariantError still raised; quant doesn't trigger I-S10 invariant — quant failure → separate `quant_failure_mode` field) | I-S10 strict; I-40/BR-6 cost cap RESPECTED under all worst-cases | Better fit than B1 for cost-cap-binding; master-plan R-P4-3 mitigation + Charter Principle 11 | **LOW** — addresses root cause WITH explicit cost-cap discipline; quant-specific lower budget is empirically justified (quant is interpretive-not-content-generative; less likely to need 3 retries) |

### Empirical citations (per L-S204-1)

- L-S240-1 ("ARCHITECTURE GAP: bear-quant should also have retry-validator OR fall-through-to-degraded-bear") — directly maps to B1/B3/B5 vs B2.
- L-S240-3 (gate amendment options) option (b) "Investigate root-cause bear timeout + retry architecture, then re-run after fix (Phase 4 backlog priority)" → B1/B5 fit; B4 alone matches option (c) "sequence runs with cooling period" but L-S240-3 already labels it insufficient as standalone.
- D-053 §Decision (A2 chosen-rationale): "Q-P4-1 lex sort result: A2 is the sole strategy above the 4/5 compliance threshold" — empirical precedent that retry-validator works for similar fail-mode class.
- Master-plan R-P4-3 row: "if compounded retry latency causes parallel-fanout cascade timeout, escalate" — already pre-authorized escalation to architectural fix; this is that escalation.
- Charter Principle 11 / BR-6 / I-40: $3/thesis cap binding. B1 worst-case $3.30 violates; B5 worst-case $2.80 respects → **B5 dominates B1 on Charter compliance**.
- AP-7 anti-pattern (performative SC ticking): B4 alone = "fire vacuous proposals" without root-cause fix. L-S240-1 explicitly calls B4 insufficient.
- AP-23 cheapest-by-RISK: prefer DEEPEN (B5 deepens existing D-053 pattern) > BROADEN (B3 introduces new ThesisStatus state) > ABANDON (B2/B4).

---

## (c) Recommendation + rationale

### Recommended strategy: **B5 (Asymmetric retry budget — bear full A2-mirror, quant abbreviated A2-mirror, per-role timeouts)**

### Rationale (empirical, not armchair)

1. **Addresses root cause** (per L-S240-1 + R-P4-3): mirrors D-053 A2 pattern symmetrically across bear+quant — the architectural-asymmetry gap surfaced in S240.
2. **Respects Charter Principle 11 / BR-6 / I-40 cost cap**: worst-case $2.80/thesis stays under $3.00 hard cap. B1 (full 3x on quant opus) breaches at $3.30 worst-case — empirically disqualified. (Quant is opus = $0.50/call typical vs bear sonnet $0.30/call typical; 3x on opus disproportionately expensive AND less effective since quant is interpretive-not-generative.)
3. **Preserves I-S10 strict**: BearCaseInvariantError still raised when bear has <3 distinct points after retry-exhaustion. NO charter amendment required. Aligns with CLAUDE.md hard rule "Adversarial by default. Any thesis output includes bear case explicitly".
4. **Mirrors ratified pattern (D-053)**: lowest implementation risk; well-trodden code path; D-053 has 11 unit tests + 1 LIVE smoke as precedent template.
5. **Quant abbreviation empirically justified**:
   - Quant is **interpretive** (reads pre-computed ratios) not **generative** (no novel reasoning needed). Per quant_agent.py SYSTEM_PROMPT: "You receive the numbers. You DO NOT compute." Validation-exhaustion is structurally less likely than bear (which must surface 3 distinct categorical risks).
   - 2-attempt budget + 180s per-call timeout (vs default 300s) yields max ~2*180 = 360s wall-clock vs current 300s single-shot — only 60s additional latency in worst-case while still providing ONE retry buffer.
   - Quant timeout-fail does NOT trip I-S10 (which only governs bear); it trips NO invariant. Quant can degrade to empty quant perspective without violating any charter rule.
6. **Anti-AP-7 disciplined**: does NOT mask parallel-fanout problem (vs B4 alone). Fixes it.
7. **Anti-AP-23 cheapest-by-RISK aligned**: DEEPENS D-053 pattern rather than BROADENING into new ThesisStatus.DEGRADED state (B2/B3).

### Why NOT each rejected strategy

- **B1 rejected** on Charter Principle 11 cost-cap violation under triple-worst-case. Otherwise structurally similar.
- **B2 rejected** on CLAUDE.md hard rule "Adversarial by default. Any thesis output includes bear case explicitly. Single-perspective output is anti-pattern" — degraded bear ≈ single-perspective in tail case. Charter-tier amendment risk + AP-7 risk ("masks problem"). If user later wants degraded-mode escape hatch, that's a separate SCOPE-tier decision, NOT bundled with B5.
- **B3 rejected** as superset of B2 — same charter-amendment risk + higher complexity. If B5 deployed and empirical evidence later shows triple-fail on bear is non-trivial frequency, B3 can be added as REV-1 amendment to D-054 (defer-then-revisit).
- **B4 rejected** as standalone (AP-7 RED FLAG per L-S240-3). However: B4 is **complementary** to B5 — recommend keeping the existing master-plan §S239 30-min inter-run lapse AND adding intra-run sequencing as a runbook note (NOT code change), so that B5 architectural fix has ample headroom to actually exercise its retry path. This complementary use of B4 is documented in the S242 dev brief below.

### Decision criterion (per L-S204-1)

Strategy chosen by lexicographic tuple: **(charter-compliance DESC, address-root-cause DESC, implementation-risk ASC, mirror-existing-pattern DESC)**:

| Strategy | Charter-comply | Root-cause | Impl-risk (low better) | Mirror-D053 |
|---|---|---|---|---|
| B1 | NO ($3.30 > $3.00) | YES | LOW | YES |
| B2 | NO (amends I-S10 / violates CLAUDE.md adversarial) | NO (masks) | MEDIUM | NO |
| B3 | NO (amends I-S10) | YES | HIGH | PARTIAL |
| B4 | YES | NO (AP-7) | TRIVIAL | N/A |
| **B5** | **YES** | **YES** | **LOW-MEDIUM** | **YES** |

B5 is the only strategy passing the first two filters (Charter + root-cause). Auto-pick fires.

---

## (d) ADR D-054 — DRAFT (inline)

> **Note to verifier**: this DRAFT is also written to canonical path `agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md` for ratification. README.md decision-registry index update queued for sandwich-verifier (NOT this PLAN session) — architect produces draft, verifier ratifies.

```yaml
---
id: D-054-bear-quant-retry-validator-symmetry
title: Bear/Quant retry-validator symmetry — close A2 architectural gap (B5 asymmetric budget)
date: 2026-05-10
status: PROPOSED
level: IMPL

author:
  - "Claude Opus 4.7 (sandwich-architect persona, S241)"

source_evidence:
  - path: agent-workspace/memory/observations/track-A-S240-anti-flake-run2.md
    quote: "ARCHITECTURE GAP: bear-quant should also have retry-validator OR fall-through-to-degraded-bear"
    section: "Lessons Surfaced — L-S240-1"
  - path: agent-workspace/memory/observations/track-A-S239-anti-flake-run1.md
    quote: "Bear/quant 300s timeout — surfaces as INCOMPLETE thesis exit code 2"
    section: "Pre-existing Caveats"
  - path: agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md
    quote: "if compounded retry latency causes parallel-fanout cascade timeout, escalate"
    section: "Risk Register R-P4-3"
  - path: agent-workspace/memory/decisions/053-a2-retry-validator-promoted-production-default.md
    quote: "A2 (retry-validator) WINS per Q-P4-1 AUTO-PICK lexicographic rule (compliance desc, cost asc)"
    section: "Decision"
  - path: packages/infrastructure/analysis/perspectives/bear_agent.py
    section: "lines 156-166 single-shot path — NO retry layer"
  - path: packages/infrastructure/analysis/perspectives/quant_agent.py
    section: "lines 137-147 single-shot path — NO retry layer"
  - path: packages/application/analysis/use_cases/validate_thesis_phase1.py
    section: "lines 217 asyncio.gather propagates first exception — bear/quant timeout kills pipeline"
  - path: PROJECT_CHARTER.md
    section: "Principle 11 § cost discipline + BR-6 / I-40 $3.00 per-thesis cap"

intent_classification:
  primary_intent: DECISION
  affects_charter: false
  affects_scope: false
  urgency: NORMAL
  complexity_score: 45

options_considered:
  - id: B1
    summary: "Mirror A2 retry-validator on bear+quant identically (3 attempts each)"
    pros:
      - "Exact mirror of D-053 ratified pattern"
      - "Lowest implementation risk"
    cons:
      - "Triple-worst-case cost ~$3.30/thesis BREACHES Charter Principle 11 / BR-6 / I-40 $3.00 cap"
      - "Quant 3x is wasteful — quant is interpretive-not-generative; less likely to need 3 retries"
  - id: B2
    summary: "Fall-through-to-degraded-bear (no retry; new ThesisStatus.DEGRADED state)"
    pros:
      - "Cost-neutral (single-shot preserved)"
      - "Persists thesis under timeout (no SQLite-skip)"
    cons:
      - "Amends I-S10 invariant (charter-tier risk)"
      - "Violates CLAUDE.md hard rule 'Adversarial by default. Single-perspective output is anti-pattern'"
      - "Masks root cause (AP-7 risk)"
  - id: B3
    summary: "Hybrid — A2-retry first, fall-through-degraded if retry exhausted"
    pros:
      - "Addresses root cause AND tail"
    cons:
      - "Combines B1+B2 surface (high complexity)"
      - "Same I-S10 amendment risk as B2 in tail"
  - id: B4
    summary: "Sequence-runs cooling-period (no code change; runbook only)"
    pros:
      - "Cost-neutral; trivial"
    cons:
      - "AP-7 RED FLAG: masks problem without fixing root cause (per L-S240-3)"
      - "L-S240-1 explicitly calls B4-alone insufficient"
  - id: B5
    summary: "Asymmetric retry budget: bear full A2-mirror (3 attempts) + quant abbreviated A2-mirror (2 attempts + 180s timeout) + per-role timeout config"
    pros:
      - "Addresses root cause (per L-S240-1 + R-P4-3 mitigation)"
      - "Respects Charter Principle 11 ($2.80 worst-case < $3.00 cap)"
      - "Preserves I-S10 strict (no charter amendment)"
      - "Mirrors ratified D-053 pattern (low implementation risk)"
      - "Quant abbreviation empirically justified (interpretive-not-generative)"
    cons:
      - "Adds per-role timeout config surface in subagent_transport.py (new surface, but bounded)"
      - "Quant 2-attempt cap might leave residual flake — accept; quant timeout doesn't trip I-S10"

chosen: B5
chosen_rationale: |
  Lexicographic decision rule (charter-compliance DESC, address-root-cause DESC,
  implementation-risk ASC, mirror-existing-pattern DESC):
  - B1, B2, B3 fail on Charter compliance (cost-cap breach OR I-S10 amendment)
  - B4 fails on root-cause (AP-7 RED FLAG)
  - B5 is the sole strategy passing both filters
  Auto-pick fires per Q-P4-1 AUTO-PICK rule (master-plan 008 §S237 precedent
  applied to bear/quant by symmetry — ratification deferred to sandwich-verifier
  S243 per AP-1 fresh-context same-plan-and-execute restriction).

approval_chain:
  - actor: agent
    action: PROPOSED
    at: 2026-05-10
    via: S241 sandwich-architect dispatch (this observation)
  - actor: sandwich-verifier (next)
    action: <pending>
    at: <pending>
    via: S243 sandwich-verifier dispatch (post-S242 IMPL session)

verified_by: []  # populated by sandwich-verifier S243 + S244 LIVE re-run

affects:
  charter: false
  spec_files:
    - specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md  # B.5.1 bear + B.5.3 quant adapter sections
  code_paths:
    - packages/infrastructure/analysis/perspectives/bear_agent.py
    - packages/infrastructure/analysis/perspectives/quant_agent.py
    - packages/infrastructure/analysis/perspectives/test_bear_agent.py  # NEW (mirror test_bull_agent.py)
    - packages/infrastructure/analysis/perspectives/test_quant_agent.py  # NEW
    - packages/infrastructure/analysis/subagent_transport.py  # per-role timeout config
  config_files: []
  other_decisions:
    - D-053  # mirrors A2 retry-validator pattern; depends on D-053 ACCEPTED

depends_on:
  - D-053  # bull A2 retry-validator pattern is the template
  - D-050  # subagent transport substrate
  - D-052  # anthropic SDK fully removed

supersedes: null
superseded_by: null

defer_cycles: 0
re_attempt_prereq: |
  N/A — decision PROPOSED; pending S242 IMPL + S243 sandwich-verifier ratification.

tags: ["phase-4", "track-A", "bear-role", "quant-role", "retry-validator", "i-s10", "i-40", "br-6", "production"]
---
```

### Key sections of D-054 ADR body

**Context**: Phase 4 Track A S240 anti-flake gate FAILED (2/5 PASS). R-P4-3 risk realized — bear/quant 300s timeout cascade is dominant fail-mode under parallel-fanout. Asymmetry: bull has D-053 A2 retry-validator + recovers; bear/quant single-shot → BearCaseInvariantError exit 2 → SQLite skip.

**Decision**: B5 — bear gets full 3-attempt A2-mirror; quant gets 2-attempt A2-mirror + 180s per-role timeout override. Per-role timeout config added to `subagent_transport.py`.

**What this means concretely**:
- `bear_agent.py` gains `_validate_bear_output` + `_analyze_with_retry` (mirror of bull, max 3 attempts, `bear_failure_mode=validation-exhausted` log on triple-fail)
- `quant_agent.py` gains `_validate_quant_output` + `_analyze_with_retry` (mirror but max 2 attempts, `quant_failure_mode=validation-exhausted` log on double-fail)
- `subagent_transport.py` gains `role_timeout_overrides: dict[PerspectiveRole, int]` parameter (quant=180s, bear/bull=300s default)
- `validate_thesis_phase1.py` `_retry_bear_if_needed` use-case-level retry **REMOVED** (now redundant with agent-level retry; cap=1 use-case retry was a band-aid for the architectural gap closed by D-054)

**What does NOT change**:
- I-S10 strict invariant preserved (`thesis.py:_enforce_bear_case` unchanged)
- ThesisStatus enum unchanged (NO new DEGRADED state)
- Bull A2 retry-validator (D-053) unchanged
- BearCaseInvariantError raised when bear validation-exhausts (3 attempts) AND post-retry bear still has <3 distinct points/cats
- Quant validation-exhausted does NOT trip any invariant (quant has no I-S* gate)

**Risks & Mitigations**:
| Risk | Likelihood | Mitigation |
|---|---|---|
| Quant 2-attempt cap leaves residual flake | Medium | Empirical S244 LIVE re-run measures quant failure_mode rate; if >1/5 in 2 runs, REV-1 amendment to bump quant to 3 attempts |
| Per-role timeout config introduces new substrate surface | Low | Bounded ~15 LOC; passes through claude_cli_transport unchanged |
| Bear 3-attempt cumulative wall-clock latency (3 * 300s = 900s worst-case) | Medium | Acceptable for autonomous use (no UI deadline); cost-cap binds before latency does |
| Cost-cap breach if bull AND bear AND quant ALL hit triple-attempt | Low | Worst-case math: bull 3x haiku ($0.30) + bear 3x sonnet ($0.90) + quant 2x opus ($1.00) = $2.20; safely under $3.00 |

**Open Questions**: None — decision is auto-pickable per Q-P4-1 AUTO-PICK rule (master-plan 008-S235 §S237 precedent extended by symmetry).

---

## (e) Sandwich-dev S242 dispatch brief

### Session type

**FOCUSED_IMPL** (1-3 tasks per CLAUDE.md § Session Types). Budget: 100-150K main-thread tokens.

### Pre-reads (≤6 LEAN brief per L-S43f-2)

1. `agent-workspace/memory/decisions/053-a2-retry-validator-promoted-production-default.md` — pattern template
2. `packages/infrastructure/analysis/perspectives/bull_agent.py` — full implementation to mirror
3. `packages/infrastructure/analysis/perspectives/test_bull_agent.py` — test template to mirror
4. `packages/infrastructure/analysis/perspectives/bear_agent.py` — current bear (to refactor)
5. `packages/infrastructure/analysis/perspectives/quant_agent.py` — current quant (to refactor)
6. THIS observation file (architect's plan)

### Files to CREATE

```
packages/infrastructure/analysis/perspectives/test_bear_agent.py     ~ 280 LOC (mirror test_bull_agent.py 275 LOC)
packages/infrastructure/analysis/perspectives/test_quant_agent.py    ~ 240 LOC (mirror test_bull_agent.py adapted to 2-attempt)
```

### Files to MODIFY

```
packages/infrastructure/analysis/perspectives/bear_agent.py
  CURRENT 184 LOC → TARGET ~310 LOC
  Changes:
    - Module docstring: append "Post-LLM validation: A2-mirror retry-validator (ADR D-054)"
    - Add `_validate_bear_output(raw: str) -> tuple[bool, str | None]` (mirror _validate_bull_output)
      Validation rules per I-S10:
        (a) valid JSON parse
        (b) top-level dict with 'key_points' list
        (c) each point has category + as_of + text|evidence|claim
        (d) NEW: ≥3 distinct categories across points (strict I-S10 gate-at-validate-time, fail-fast for retry)
    - Add `_analyze_with_retry()` method (mirror BullPerspectiveAgent._analyze_with_retry)
      Max 3 attempts; re-prompt with validation_error on retry; cumulative cost; explicit
      `bear_failure_mode=validation-exhausted` WARNING log on triple-fail
    - Refactor BearPerspectiveAgent.analyze() to delegate to _analyze_with_retry (mirror bull)
    - Wrap call_llm in try/except inside retry loop (mirror bull lines 253-259) so exceptions
      become validation_error rather than propagating to asyncio.gather

packages/infrastructure/analysis/perspectives/quant_agent.py
  CURRENT 163 LOC → TARGET ~240 LOC
  Changes:
    - Module docstring: append "Post-LLM validation: A2-mirror abbreviated retry (ADR D-054)"
    - Add `_validate_quant_output(raw: str) -> tuple[bool, str | None]` (mirror _validate_bull_output)
      Validation rules:
        (a) valid JSON parse
        (b) top-level dict with 'key_points' list
        (c) each point has category + as_of + text|evidence|claim
        (NO ≥3-distinct-cats gate — quant has no I-S* invariant)
    - Add `_analyze_with_retry()` method — abbreviated to MAX 2 attempts (vs bull/bear 3)
      Per-role timeout=180s passed to call_llm via context-or-kwarg (see subagent_transport.py change)
      Explicit `quant_failure_mode=validation-exhausted` WARNING log on double-fail
    - Refactor QuantPerspectiveAgent.analyze() to delegate to _analyze_with_retry
    - Wrap call_llm in try/except inside retry loop (mirror bull/bear pattern)

packages/infrastructure/analysis/subagent_transport.py
  Changes (~20 LOC):
    - Add module-level constant: _ROLE_TIMEOUT_OVERRIDES = {PerspectiveRole.QUANT: 180}
      (others default to _DEFAULT_TIMEOUT_SEC = 300)
    - claude_cli_transport function signature gains optional `role: PerspectiveRole | None = None`
      kwarg (default None for backward compatibility)
    - When role is in _ROLE_TIMEOUT_OVERRIDES, use that timeout; else _DEFAULT_TIMEOUT_SEC
    - Pass role through from ClaudeLLMPerspectiveAdapter.call_llm (which already takes role)

packages/infrastructure/analysis/claude_llm_perspective_adapter.py
  Changes (~5 LOC):
    - Pass `role` kwarg through to transport call (sandwich-dev VBW-probe to find current call site)

packages/application/analysis/use_cases/validate_thesis_phase1.py
  Changes (~30 LOC removed):
    - REMOVE _retry_bear_if_needed method (lines 295-329) — agent-level retry now covers
    - Update _run_pipeline to remove call to _retry_bear_if_needed (line 223-228)
    - Bear validation-exhausted now propagates via empty key_points → BearCaseInvariantError
      raised at Thesis aggregate __post_init__ → caught at line 266 → INCOMPLETE w/
      "bear_case_invariant_failed" gap (UNCHANGED CLI exit 2 path)
    - Update class docstring + constructor (remove bear_retry_count param)
    - Update tests in tests/application/test_validate_thesis_phase1.py to remove bear-retry-cap=1 cases
```

### Tests to ADD (per CLAUDE.md Quality Gates Tier-1)

`test_bear_agent.py` — mirror `test_bull_agent.py` structure:
- `test_validate_bear_output_json_parse_fail`
- `test_validate_bear_output_empty_key_points_fail`
- `test_validate_bear_output_missing_category_fail`
- `test_validate_bear_output_missing_as_of_fail`
- `test_validate_bear_output_lt_3_distinct_cats_fail`  (NEW — bear-specific I-S10 retry-validate)
- `test_validate_bear_output_valid_returns_true`
- `test_validate_bear_output_not_top_level_dict_fail`
- `test_analyze_with_retry_json_parse_fail_then_success`
- `test_analyze_with_retry_structural_fail_then_success`
- `test_analyze_with_retry_triple_fail_returns_empty_with_log`  (logs `bear_failure_mode=validation-exhausted`)
- `test_analyze_with_retry_reprompt_includes_error_excerpt`
- `test_analyze_with_retry_handles_llm_exception_as_validation_error`  (NEW — verifies timeout becomes validation_error, doesn't propagate)
- TARGET: 12 unit tests (vs 11 for bull, +1 for exception-handling)

`test_quant_agent.py` — mirror but abbreviated:
- `test_validate_quant_output_json_parse_fail`
- `test_validate_quant_output_empty_key_points_fail`
- `test_validate_quant_output_missing_category_fail`
- `test_validate_quant_output_missing_as_of_fail`
- `test_validate_quant_output_valid_returns_true`
- `test_validate_quant_output_not_top_level_dict_fail`
- `test_analyze_with_retry_max_2_attempts`  (NEW — verify abbreviated retry budget)
- `test_analyze_with_retry_double_fail_returns_empty_with_log`  (logs `quant_failure_mode=validation-exhausted`)
- `test_analyze_with_retry_handles_llm_exception_as_validation_error`
- `test_role_timeout_override_quant_uses_180s`  (NEW — verifies subagent_transport per-role config)
- TARGET: 10 unit tests

### Smoke command (post-mock-tests-green; LIVE)

```powershell
# 1-ticker LIVE smoke (mirror D-053 verified_by FPT smoke pattern)
cd C:\htdocs\stockforge
python -m apps.cli.validate_thesis --ticker FPT --no-mock-llm
# Expected: exit 0; bear ≥3 distinct cats; quant present; I-S10 PASS; cost <$3
sqlite3 data/stockforge.sqlite "SELECT thesis_id, ticker, status, gaps, cost_usd FROM theses WHERE ticker='FPT' ORDER BY created_at DESC LIMIT 1"
# Expected: status=submitted, gaps=[], cost_usd <3.00
```

### Acceptance criteria (S242 dev session close)

Mirror D-053's "11 unit tests + LIVE smoke I-S3 PASS" pattern:

1. ✅ All NEW unit tests pass: 12 bear + 10 quant = 22 unit tests minimum (vs 11 for bull D-053)
2. ✅ All EXISTING tests still pass (no regression in `tests/application/test_validate_thesis_phase1.py` after `_retry_bear_if_needed` removal)
3. ✅ `mypy --strict packages/infrastructure/analysis/perspectives/bear_agent.py packages/infrastructure/analysis/perspectives/quant_agent.py` green
4. ✅ `ruff check packages/infrastructure/analysis/perspectives/` green
5. ✅ LIVE 1-ticker smoke (FPT): exit 0; bear ≥3 distinct cats; quant present; thesis SUBMITTED + persisted; cost <$3
6. ✅ NO production code edits to bull_agent.py (D-053 unchanged)
7. ✅ NO charter / invariants.md edits (I-S10 strict preserved)
8. ✅ ADR D-054 status flipped from PROPOSED → ACCEPTED in canonical file (sandwich-dev appends ACCEPTED record per D-053 precedent §Acceptance Record)

### Anti-acceptance (S242 must NOT do)

- ❌ Edit thesis.py / ThesisStatus / I-S10 invariant
- ❌ Add `ThesisStatus.DEGRADED` (B2/B3 path explicitly rejected)
- ❌ Add cooling-period sleeps (B4 rejected as standalone; runbook-only complement noted in D-054 §Risks)
- ❌ Edit bull_agent.py / D-053 invariants
- ❌ Edit settings.json / hooks / charter
- ❌ git commit (CLAUDE.md hard rule — stage only)

### Post-S242 chain

- **S243** sandwich-verifier (fresh-context) ratifies D-054 + reviews S242 dev output (per AP-1 mandate)
- **S244** LIVE 5-ticker anti-flake re-run (mirror master-plan §S239 pattern, post-fix); SC-1 GREEN gate evaluation
- If S244 ≥4/5 BOTH runs (anti-flake gate), Track A closes per master-plan acceptance gate

### Token-budget guard

- S242 dev brief budget: 100-150K (FOCUSED_IMPL band)
- Subagent dispatch (sandwich-dev fresh-context per AP-1) takes its own ~80-120K
- Combined Phase 4 cost addition: ~250K main + ~100K imputed-LLM ($2-4 imputed) — within Phase 4 envelope ceiling

---

## (f) Phantom-dispatch parallel-concern note (L-S240-5; PRIORITY 7 governance)

**STATUS**: NOT in S241 scope. Parallel concern requiring SEPARATE subagent dispatch.

### Why split

L-S240-5 documents 3rd-instance recurrence of phantom CLI dispatches firing outside parent-session control. AP-23 promote-or-retire MANDATE long past (2nd-instance was already mandate). Per L-S240-5: "phantom dispatches are corrupting cost telemetry + SQLite UPSERT semantics + creating ghost rows" — and they BLOCK further dogfood runs (S244 LIVE re-run will be corrupted by phantom-dispatch echo unless RC-fixed first).

But: phantom-dispatch RC investigation is **orthogonal** to bear/quant retry architecture — different surface (governance / hook scripts / scheduled tasks vs LLM-perspective adapters). Bundling in S241 would violate Phase 4 master-plan §S237 single-session-single-objective discipline.

### Recommended dispatch (parallel-safe to S242)

**S241b OR S242b — drift-detector subagent OR general-purpose subagent (run_in_background SAFE)**

**Brief (lean, ≤6 pre-reads)**:
1. `agent-workspace/memory/dispatch.jsonl` — full audit (filter `validate_thesis` invocations across last 7 days)
2. `.claude/scheduled_tasks.lock` — current scheduled-task state
3. `scripts/hooks/` directory listing — Stop-hook + UserPromptSubmit + SessionStart + post-tool-use scripts that could fire CLI dispatches
4. `agent-workspace/memory/observations/track-A-S240-anti-flake-run2.md` § L-S240-5
5. `agent-workspace/memory/observations/track-A-S239-anti-flake-run1.md` § L-S239-4
6. M-S238-2 entry in `agent-workspace/memory/mistake-log.md`

**Acceptance criteria**:
- Identify originator(s) of 5+ phantom CLI dispatches in S240 (b30ko1l41 / bn9j76bbk / bs0k226qo / bmseq71w2 / b5uu8qebh)
- Categorize: (a) Stop-hook auto-dispatch / (b) scheduled-task / (c) parallel-session leakage / (d) pre-/clear queue residue / (e) external originator
- Recommend mitigation: kill-switch script OR hook amendment OR scheduled-task disable
- Output: `agent-workspace/memory/observations/phantom-dispatch-rc-investigation-S241b.md`

### Sequencing

- S241 (this session) → architect plan + D-054 DRAFT [DONE w/ this observation file]
- S241b (parallel, run_in_background SAFE) → phantom-dispatch RC investigation
- S242 (FOCUSED_IMPL) → D-054 implementation by sandwich-dev (depends on S241b ONLY for safe LIVE re-run later, NOT for D-054 code edits — code edits are phantom-dispatch-immune)
- S243 (VERIFY, fresh-context per AP-1) → ratify D-054 + S242 dev output
- S244 (LIVE re-run) → BLOCKED until S241b RC-fix applied (per L-S240-5 "phantom dispatches BLOCK further dogfood runs")

### Critical sequencing note

**S244 LIVE 5-ticker anti-flake re-run is BLOCKED until phantom-dispatch RC fix lands.** Therefore:
- S242 + S243 (D-054 IMPL + VERIFY) can proceed regardless of S241b outcome (no LIVE dependency).
- S244 must wait on S241b green.
- This means D-054 ratification ≠ Track A close. Track A close requires BOTH (D-054 ratified) AND (phantom-dispatch RC fixed) AND (S244 LIVE re-run ≥4/5 BOTH runs).

---

## Acceptance self-check (architect's pre-deliverable verify)

Per parent-session brief deliverable acceptance:

| Criterion | Status |
|---|---|
| 1. Observation file at canonical path with all 6 sections (a)-(f) | ✓ this file |
| 2. ADR DRAFT at canonical path with 12-field schema OR inline | ✓ inline above (§ d); canonical path = `agent-workspace/memory/decisions/054-bear-quant-retry-validator-symmetry.md` (sandwich-dev S242 will materialize the file or sandwich-verifier S243 will, per session-protocol — architect produced DRAFT, did not write canonical file to avoid premature D-054 promotion before verifier ratification per AP-1) |
| 3. Sandwich-dev brief concrete enough to execute without re-planning | ✓ § (e) — file paths, function names, test names, smoke command, acceptance criteria |
| 4. Strategy recommendation has explicit empirical-probe rationale | ✓ § (b) probe matrix + § (c) lex-rule citation |
| 5. No production code changes (PLAN session per CLAUDE.md) | ✓ — verifier should run `git status -s packages/` returning no `M` lines |

**Architect's confidence**: 0.85 (HIGH for IMPL-tier decision per Q&A A4 thresholds; auto-self-decidable; sandwich-verifier S243 ratification is the sanity backstop).

**Token-spend self-track**: ~52-58K main (within 50-80K PLAN envelope per CLAUDE.md § Session Types).

End of S241 sandwich-architect observation. Ready for S242 sandwich-dev IMPL dispatch.
