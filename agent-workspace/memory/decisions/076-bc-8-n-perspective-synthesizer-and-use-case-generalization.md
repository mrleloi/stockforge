---
decision_id: D-076
title: "BC-8 N-Perspective Synthesizer and ValidateThesisPhase1UseCase Generalization"
status: ACCEPTED
type: architecture
proposed_at: 2026-05-17
ratified_at: null
proposed_by: sandwich-dev (S381 IMPL; plan-036 D5)
supersedes: []
superseded_by: []
related_to:
  - D-054  # retry-validator pattern (agent-level; F.3 preserves)
  - D-059  # Python determinism contract (R2 dict order; DD-2 defense-in-depth)
  - D-060  # commit-policy-agent-may-commit
  - D-074  # BC-8 Transport Flip + RolePromptPack Foundation (F.1)
  - D-075  # BC-8 First 3 Personality-Pack Adapters (F.2)
source_plan: agent-workspace/session-plans/pending/036-S380-phase-f3-synthesize-perspectives-usecase.md
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md
session_impl: S381
session_verify: S382 (pending)
---

# D-076 — BC-8 N-Perspective Synthesizer and ValidateThesisPhase1UseCase Generalization

## Context

Phase F.3 ships the N-perspective aggregation pipeline combining V0=6 personas
(BEAR/BULL/QUANT from S43 + BUFFETT/GRAHAM/TALEB from F.2/S378) into a single
Synthesis aggregate + Recommendation + ConfidenceLevel.

The existing pipeline (validate_thesis_phase1.py + phase1_synthesizer.py) was
hardcoded for 3 personas (BEAR/BULL/QUANT). F.3 generalises to N≥4 personas via:
- dict[PerspectiveRole, LLMPerspectivePort] dispatch shape
- role-aware Phase1Synthesizer pairwise disagreement detection
- MAJORITY-CATEGORICAL scoring with QUANT-favoured preserved
- backward-compat composition root (use_case_builder.py V0=6 wiring)

This ADR documents the F.3 architectural decisions (DD-1 through DD-10 from plan-036)
and their rationale, adversarial alternates, and compliance attestation.

## Decisions

### Decision 1: N-persona dispatch shape = dict[PerspectiveRole, LLMPerspectivePort]

`ValidateThesisPhase1UseCase.__init__` now accepts `agents: dict[PerspectiveRole, LLMPerspectivePort]`
(single param replacing bear_agent+bull_agent+quant_agent 3-param signature).

**Rationale:**
- Role-keyed lookup matches existing `_ROLE_TO_MODEL: dict[PerspectiveRole, str]` pattern
  at `claude_llm_perspective_adapter.py:72-76` — semantic consistency
- Allows N>3 personas via dict entry addition without ctor signature churn
- Self-documenting: `agents[PerspectiveRole.BEAR].analyze(...)` clearer than positional
- AC-5 reproducibility preserved via DD-2 STABLE-SORTED-BY-ROLE combined_prompt construction
- Backward-compat at composition root: `apps/_shared/use_case_builder.py` constructs
  `{BEAR: bear, BULL: bull, QUANT: quant, BUFFETT: buffett, GRAHAM: graham, TALEB: taleb}`

**Adversarial alternate REJECTED:** `agents: tuple[LLMPerspectivePort, ...]` (sequence)
— positional convention brittle; BEAR-at-position-0 assumption breaks on reorder.

**Adversarial alternate REJECTED:** `agents: PersonaRegistry` (registry directly)
— PersonaRegistry holds RolePromptPack DATA not LLMPerspectivePort INSTANCES;
mixes data-layer with adapter-layer concerns.

### Decision 2: AC-5 reproducibility via STABLE-SORTED-BY-ROLE combined_prompt

At `validate_thesis_phase1.py:244-245`, combined_prompt construction:
```python
sorted_perspectives = sorted(perspectives, key=lambda p: p.role.value)
combined_prompt = ":".join(p.prompt_hash for p in sorted_perspectives)
```

**Rationale:**
- Defense-in-depth vs D-059 R2 (dict order non-determinism): explicit alphabetic sort
  guarantees deterministic combined_prompt regardless of asyncio.gather completion order
- PerspectiveRole.value lexicographic sort: "bear" < "buffett" < "bull" < "graham"
  < "macro" < "manager" < "quant" < "taleb" — stable canonical ordering
- Backward-compat confirmed: for N=3 (BEAR/BULL/QUANT), sorted order = ("bear","bull","quant")
  which INCIDENTALLY matches prior implicit dispatch order — no existing thesis_id changes

**Adversarial alternate REJECTED:** PerspectiveRole enum declaration order
— couples thesis_id to enum-declaration-order; silent breakage if enum reordered.

### Decision 3: Phase1Synthesizer N-perspective aggregation = MAJORITY-CATEGORICAL

Phase1Synthesizer V0 ships:
- Pairwise disagreement detection via `itertools.combinations(all_with_buckets, 2)` across ALL N personas
- QUANT-favoured dimension scoring preserved (QUANT verdict wins if QUANT has evidence)
- Majority-categorical across all N personas when QUANT absent (tie → NEUTRAL)
- Catalysts from BULL only; risks from BEAR only (canonical attribution preserved)

**Rationale:**
- Karpathy P2 simplicity-first: categorical-majority is simplest aggregation
- A-01 § 5 third bullet ISOLATED-THEN-AGGREGATE as Wave-1 default
- I-S1-1 by-construction: categorical aggregation = no LLM math anywhere
- F.3-V2 refinement trigger: weighted-by-conviction IF V0 dogfood (F.5) reveals
  MAJORITY-CATEGORICAL produces empirically-poor confluence on 3+ VN tickers

**Adversarial alternate REJECTED (V0):** Weighted-by-conviction with numeric weights
— premature optimization; calibration question; F.3-V2 if dogfood motivates.

### Decision 4: I-S10 BEAR-presence preserved at Thesis layer (NOT re-enforced at synthesizer)

`Thesis._enforce_bear_case` at `thesis.py:91-115` UNCHANGED. Phase1Synthesizer does NOT
re-enforce BEAR-presence. F.3 N-persona path passes through Thesis aggregate; if BEAR
missing → BearCaseInvariantError → use case catches → Thesis.incomplete(). DRY.

**Adversarial alternate REJECTED:** Add BEAR-presence check in `_run_pipeline`
— redundant with existing Thesis._enforce_bear_case; violates DRY.

### Decision 5: I-S12 disagreement extension = PAIRWISE across N-perspectives

Per-dim disagreement detection extended from BEAR-vs-BULL only to ALL-PAIRS via
`itertools.combinations(all_with_buckets, 2)`. Existing detection rules unchanged:
- verdict kind: opposing STRONG/WEAK extremes
- narrative kind (P3 extension, VF-5): STRONG vs engaged-NEUTRAL on same dim

Disagreement.bear_verdict / Disagreement.bull_verdict FIELD NAMES RETAINED for
backward-compat (values represent any pairwise p1/p2 verdicts; note clarifies semantics).

**Adversarial alternate REJECTED for F.3 V0:** Rename to left_verdict/right_verdict
— cross-layer rename = broader regression; Karpathy P3 surgical-changes; F.3-V2 candidate.

### Decision 6: Per-persona cost accumulation via sum comprehension

```python
budget.add(sum((p.cost_usd for p in perspectives), Decimal("0")))
```
Replaces hardcoded `bear_p.cost_usd + bull_p.cost_usd + quant_p.cost_usd` with
N-persona-agnostic sum. `start=Decimal("0")` required for type correctness.

### Decision 7: Composition root V0=6 wiring via PersonaRegistry helpers

Two new helpers in `apps/_shared/use_case_builder.py`:
- `_load_persona_registry()`: loads buffett/graham/taleb V0 JSON packs
- `_build_persona_agents(adapter, registry)`: constructs BUFFETT/GRAHAM/TALEB agents

`_build_subagent_agents()` and `_build_mock_agents()` return type changed from
`tuple[object, object, object]` to `dict[object, object]` (V0=6 entries).

Path safety per D-064: `PersonaRegistry.load_from_json()` enforces 5-invariant
(no traversal, .json ext, no symlink, real file, base_dir confinement).

### Decision 8: AC-5 regression-test design = same-input-twice + cross-N-persona-rotation

Plan-036 DD-8 test scenarios implemented:
- TC-USE-CASE-4: N=6 same input twice → same thesis_id
- TC-USE-CASE-5: N=6 shuffled dict insertion order → same thesis_id (STABLE-SORTED validation)
- TC-USE-CASE-8: N=3 vs N=6 same ticker/data → different thesis_id (by-design roster difference)

### Decision 9: V0=6 persona-model routing asymmetry FLAGGED but NOT fixed in F.3

`_ROLE_TO_MODEL` at `claude_llm_perspective_adapter.py:72-76` not extended with
BUFFETT/GRAHAM/TALEB entries. New personas fall through to `_DEFAULT_MODEL = _OPUS_MODEL`.

Cost impact: BUFFETT/GRAHAM/TALEB run on Opus instead of Sonnet preference in
role-pack JSON (`model_id_preference: "claude-sonnet-4-6"`). F.5 dogfood will
measure cost-impact empirically.

F.4 or F.3-V2 trigger: if F.5 dogfood reveals cost-profile unacceptable, add
3 `_ROLE_TO_MODEL` entries (≤5 LOC delta).

### Decision 10: No new charter-tier invariants introduced

F.3 EXTENDS existing invariant enforcement:
- I-S10 at Thesis._enforce_bear_case (preserved, not moved)
- I-S12 at Synthesis.__post_init__ (preserved, pairwise extended)
- I-S1/I-S1-1 by-construction (synthesizer = pure deterministic Python)
- I-S35 by-construction (Recommendation enum INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE)

## Consequences

**Positive:**
- Extensible to V0=9 (F.4) without ctor signature churn (dict entry addition)
- Backward-compat with existing 3-persona path (composition root + test fixtures)
- AC-5 deterministic-per-tuple preserved under N-persona path via STABLE-SORTED-BY-ROLE
- I-S10/I-S12/I-S35 invariants preserved by-construction
- Pairwise disagreement detection scales to N personas via itertools.combinations O(N²)
  (negligible vs LLM call latency for V0=6; 15 pairs × 4 dims = 60 detections)

**Negative:**
- Disagreement field names (bear_verdict/bull_verdict) misleading for N-persona path
  (acknowledged trade-off; F.3-V2 rename to left_verdict/right_verdict)
- V0=6 cost-profile risk if BUFFETT/GRAHAM/TALEB run on Opus default
  (5× cost vs Sonnet; monitored at F.5 dogfood; F.4/F.3-V2 fix trigger)
- F.3-V2 candidates: weighted-by-conviction confluence + tie-breaker rule + Disagreement field rename

## DD-10 Compliance Attestation (pattern-port NOT code-port)

Per master plan-033 DD-10 + F.2 plan-035 carry-forward:

- ai-hedge-fund `portfolio_manager.py:160-175` role-keyed aggregation table PATTERN
  adopted but RE-IMPLEMENTED with stockforge primitives:
  - ai-hedge-fund: `{ticker: {agent_id: {signal: str, confidence: int}}}` (Pydantic)
  - stockforge: `tuple[PerspectiveAnalysis, ...]` where each `.role` is PerspectiveRole enum
    (RICHER: GroundedPoints + Conviction StrEnum + cost tracking + prompt_hash for AC-5)
- 50+ char substring grep gate: PASS (zero verbatim code-copy from portfolio_manager.py)
- ai-hedge-fund `src/main.py:112-115` parallel fan-out PATTERN adopted:
  - ai-hedge-fund: LangGraph StateGraph with Annotated[list, operator.add] merge reducer
  - stockforge: `asyncio.gather(*tasks)` (existing pattern; F.3 generalises from N=3 to N)

## Charter Compliance

- 0 charter / 0 constitution changes in F.3 IMPL
- D-060 compliance: commits by sandwich-dev; no push
- D-074/D-075 IMPL-tier ADRs honored as substrate
- master plan-033 § E.3 DoD floor preserved (≥18 new unit tests; 27 DoD items)
- VBW protocol: all 6 modified files read before edit; every claim cites file:line
- Karpathy P3 surgical-changes: ≤30 LOC delta validate_thesis_phase1.py;
  ≤80 LOC delta phase1_synthesizer.py; ≤50 LOC delta use_case_builder.py

## F.3-V2 Deferred Items

| Item | Trigger |
|---|---|
| Disagreement field rename (bear_verdict→left_verdict; bull_verdict→right_verdict) | F.5 dogfood reveals field semantics confusing in output |
| Weighted-by-conviction confluence calculation | F.5 dogfood reveals MAJORITY-CATEGORICAL poor on 3+ VN tickers |
| _ROLE_TO_MODEL extension for BUFFETT/GRAHAM/TALEB | F.5 dogfood cost-profile unacceptable |
| Tie-breaker invariant rule (3-3 tie → new I-S<N>?) | F.5 dogfood reveals NEUTRAL tie-default empirically poor |
