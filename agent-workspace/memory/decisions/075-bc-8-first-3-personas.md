---
id: D-075
title: BC-8 First 3 Personality-Pack Adapters (Buffett / Graham / Taleb)
status: proposed
severity: feature
tier: impl
proposed_by: sandwich-dev S378
proposed_at: 2026-05-17
ratified_by: ~pending S379 sandwich-verifier
ratified_at: ~pending
supersedes: ~
superseded_by: ~
parent: D-074 (BC-8 Transport Flip + RolePromptPack + PersonaRegistry — F.1 substrate)
successor: D-076 (F.3 N-perspective use case extension — sub-plan 036; blocks_on D-075)
source_plan: agent-workspace/session-plans/pending/035-S377-phase-f2-personas-buffett-graham-taleb.md
---

# D-075: BC-8 First 3 Personality-Pack Adapters (Buffett / Graham / Taleb)

## Context

Phase F-prime (Theme H — BC-8 Multi-Perspective Primitives) shipped F.1 substrate via D-074 (S375 IMPL + S376 verified ACCEPTED):
- `RolePromptPack` frozen dataclass (10-field; `packages/application/analysis/role_prompt_pack.py`)
- `PersonaRegistry` stdlib dict + JSON loader (`packages/application/analysis/persona_registry.py`)
- Transport flip to `claude_cli_transport` (D-052 § Implementation step 1 closed for BC-8)
- `role-packs/README.md` V0 format documentation

F.2 sub-plan 035 ships the first 3 Vietnam-relevant persona-pack adapters consuming the F.1 substrate, extending the PerspectiveRole StrEnum, and authoring per-persona JSON content.

## Decision

### (a) PerspectiveRole StrEnum extension (DD-1)

Extended `packages/domain/analysis/models/perspective_analysis.py` PerspectiveRole StrEnum with 3 new active values:

```python
BUFFETT = "buffett"   # Warren Buffett value/quality/moat
GRAHAM = "graham"     # Benjamin Graham deep-value/margin-of-safety
TALEB = "taleb"       # Nassim Taleb antifragility/tail-risk/convexity
```

Rationale: type-safety preservation + existing `PerspectiveAnalysis.role: PerspectiveRole` signature consistency.
Rejected: role_id-only routing (would require PerspectiveAnalysis.role: str type widening — breaking change).
Rejected: mapping to existing MACRO/BEHAVIOR/MANAGER deferred stubs (semantically wrong; future Phase 3 personas would conflict).

### (b) Per-persona file naming convention (DD-2)

3 new adapter files at `packages/infrastructure/analysis/perspectives/`:
- `buffett_agent.py` — `BuffettPerspectiveAgent`
- `graham_agent.py` — `GrahamPerspectiveAgent`
- `taleb_agent.py` — `TalebPerspectiveAgent`

Convention mirrors existing `bear_agent.py` / `bull_agent.py` / `quant_agent.py`.

### (c) NO shared base class (DD-3) — AP-23 first-instance HOLD

Per-persona adapter classes re-implement `_validate_<persona>_output` + `_parse_grounded_points` + `_filter_by_jaccard` + `_analyze_with_retry` individually. No `_base_persona_agent.py` ABC or Mixin.

Rationale: 3-persona duplication (~210 LOC x 3 = ~630 LOC; ~60% identical skeleton) is acceptable per Karpathy P3 for V0. Shared-base promotion trigger: sub-plan 037 F.4 V0=9 ratification (AP-23 2nd instance).

### (d) Per-persona category_universe (DD-4)

Each persona's `category_universe` is a distinct 6-element tuple:

- **Buffett**: `("MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH")`
- **Graham**: `("EARNINGS_STABILITY", "BALANCE_SHEET_STRENGTH", "DIVIDEND_RECORD", "MARGIN_OF_SAFETY", "NCAV", "GRAHAM_NUMBER")`
- **Taleb**: `("FRAGILITY", "CONVEXITY", "SKIN_IN_GAME", "TAIL_RISK", "VOLATILITY_REGIME", "ANTIFRAGILITY")`

`min_distinct_categories = 3` and `min_points = 3` for all 3 personas.

Per-persona `_validate_<persona>_output` enforces category membership: each point's `category` must be in the persona's `role_pack.category_universe` (new per-persona check vs. bear_agent.py hardcoded list).

### (e) Per-persona conviction_guidance text rubric (DD-5)

Rule 16 mode 1 categorical surrogate: all 3 personas use conviction_guidance text instructing the LLM to pick `STRONG / MODERATE / WEAK` categorically.

**NO numeric 0-100 rubric**: ai-hedge-fund warren_buffett.py 90-100/70-89/50-69 confidence scale (A-01 § 3 C9) REJECTED per I-S1-1 Rule 16 mode 1.

Explicit instruction in each persona's system_prompt_template: "Pick categorical -- do NOT emit numeric percentage."

### (f) Per-persona vietnam_notes content (DD-6)

Each JSON role-pack includes ≥150 chars of Vietnam-specific application guidance:

- **Buffett**: VinGroup cross-holding moat fragility tradeoff; Vinamilk (VNM) >50y dairy leadership; MWG retail distribution moat >3000 stores; VCB/BID/TCB banking oligopoly; HPG steel scale advantage; circle of competence vs. VN pump stocks.
- **Graham**: VN banking NCAV applicability LIMITED (price-to-book floors); VN real estate (VHM/KDH/NVL) complex balance sheets; current ratio threshold relaxed to 1.5 with caveat; Graham Number VN-adjusted EPS caveat; dividend record ≥3y relaxation for VN30.
- **Taleb**: VN F0 retail >85% HOSE volume = high-tail-risk regime; daily price limit ±7% masks true tail risk; 'đội lái' pump-cluster textbook fragility; USD/VND managed peg = turkey problem; insider trading disclosure reliability caveat.

### (g) Model ID preference (DD-7)

`model_id_preference = "claude-sonnet-4-6"` explicitly set in all 3 persona JSON files.
Rationale: value-investor reasoning does not require Opus-class computational reasoning. QUANT remains the only Opus persona per master plan-033 DD-12 cost-routing.

### (h) Retry-validator shape (DD-8)

Each persona adapter mirrors BearPerspectiveAgent D-054 pattern (`bear_agent.py:198-334`) exactly:
- `__init__(adapter, role_pack: RolePromptPack)` signature
- `async def analyze(ticker, context, _role) -> PerspectiveAnalysis`
- 3-attempt retry loop with cumulative cost accumulation
- Re-prompt on attempt 2+ includes validation error excerpt
- `validation-exhausted` WARNING log on triple-fail (NOT silent)
- Returns empty PerspectiveAnalysis on triple-fail (not exception propagation)

### (i) Pattern-port not code-port — LICENSE attestation (DD-10)

All per-persona JSON content (system_prompt_template, conviction_guidance, vietnam_notes) authored FRESH from documented investment principles. ZERO verbatim copy from ai-hedge-fund warren_buffett.py / ben_graham.py / nassim_taleb.py.

Verification: `grep` for any 50+ character substring match between authored JSON content and ai-hedge-fund source files returned 0 matches (DD-10 grep gate verified at S378 IMPL commit time).

Pattern source: ai-hedge-fund persona files read for PRINCIPLES ONLY (circle of competence + moat + management / earnings stability + balance sheet + margin of safety / antifragility + tail risk + convexity). Independent operationalization in StockForge.

## JSON role-pack files shipped

- `agent-workspace/role-packs/buffett.json` (role_id='buffett'; 10 fields; category_universe 6 Buffett categories)
- `agent-workspace/role-packs/graham.json` (role_id='graham'; 10 fields; category_universe 6 Graham categories)
- `agent-workspace/role-packs/taleb.json` (role_id='taleb'; 10 fields; category_universe 6 Taleb categories)

## Vietnam-relevance verdict

Per master plan-033 DD-2 evidence chain (architect-tier ratification):
- Buffett: HIGH-relevance V0 (VinGroup moat structure; Vinamilk consumer brand; banking oligopoly)
- Graham: HIGH-relevance V0 with VN-specific caveats (NCAV limited; balance-sheet complexity; threshold relaxations)
- Taleb: VERY-HIGH-relevance V0 (F0 retail tail-risk; 'đội lái' fragility; USD/VND turkey problem)

## Empirical close-verify (S378 dev; S379 verifier re-runs)

- **L1**: 3 persona JSON files load via `PersonaRegistry.load_from_json` successfully + register OK
- **L2**: 3 persona adapter classes instantiate via `<Persona>PerspectiveAgent(adapter, role_pack)` without error
- **L3**: per-persona `_validate_<persona>_output` validates happy-path + rejects invalid (3 personas x 8 edge cases each = TC-{persona}-1 through TC-{persona}-8)
- **L4**: per-persona `_analyze_with_retry` runs 3-attempt loop correctly (stub LLM — TC-{persona}-9 through TC-{persona}-13)
- **L5**: `PerspectiveRole.BUFFETT / GRAHAM / TALEB` enum values accessible; `.value` == `"buffett"` / `"graham"` / `"taleb"`
- **L6**: existing 34 tests in test_bear_agent.py + test_quant_agent.py + test_adapter.py STILL PASS (regression floor at S378 IMPL)
- **L7**: 39 NEW tests across test_buffett/graham/taleb_agent.py PASS (13 TC each)
- **L8**: mypy --strict --explicit-package-bases + ruff + pytest exit 0 on packages/infrastructure/analysis/perspectives/ + packages/application/analysis/
- **L9**: grep `import anthropic|from anthropic` in `packages/infrastructure/analysis/perspectives/*_agent.py` returns 0 matches (D-074 preservation)
- **L10**: grep for 50+ char substring match between F.2 JSON content and ai-hedge-fund source returns 0 matches (DD-10 pattern-port attestation VERIFIED)

## Consequences

- F.2 ships 3 persona adapters REGISTERED via PersonaRegistry only; composition-root wiring at `validate_thesis_phase1.py` deferred to F.3 sub-plan 036 (N-perspective use case extension)
- Existing BEAR/BULL/QUANT 3-persona pipeline at use case level UNCHANGED
- PerspectiveRole StrEnum now has 9 values (6 existing + 3 new F.2 additions)
- Per-persona V0 ships UNCALIBRATED per master plan-033 § A.3 + Charter Principle 8; calibration trigger = n≥50 thesis outcomes per persona post-MVP

## Revisit triggers

1. F.3 sub-plan 036 dispatched after S379 PASS: composition-root wiring + N-persona dispatch generalization
2. F.4 sub-plan 037 V0=9 ratification: shared-base-class AP-23 2nd-instance calculus + 3 additional personas (Munger / Lynch / VN_DOMAIN_SPECIALIST)
3. V0 dogfood produces ≥3 validation-exhausted events for any single persona across ≥10 thesis runs: tune per-persona retry count
4. Per-persona calibration: n≥50 thesis outcomes per persona across 3+ months wall-clock; Vietnam-relevance notes V1 refresh

## Files modified

| File | Change |
|---|---|
| `packages/domain/analysis/models/perspective_analysis.py` | +3 enum values (BUFFETT, GRAHAM, TALEB) |
| `packages/infrastructure/analysis/perspectives/buffett_agent.py` | NEW |
| `packages/infrastructure/analysis/perspectives/graham_agent.py` | NEW |
| `packages/infrastructure/analysis/perspectives/taleb_agent.py` | NEW |
| `packages/infrastructure/analysis/perspectives/test_buffett_agent.py` | NEW (13 TC) |
| `packages/infrastructure/analysis/perspectives/test_graham_agent.py` | NEW (13 TC) |
| `packages/infrastructure/analysis/perspectives/test_taleb_agent.py` | NEW (13 TC) |
| `agent-workspace/role-packs/buffett.json` | NEW |
| `agent-workspace/role-packs/graham.json` | NEW |
| `agent-workspace/role-packs/taleb.json` | NEW |
| `agent-workspace/role-packs/README.md` | APPEND (§ Personas authored by F.2) |
| `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` | NEW (this ADR) |
