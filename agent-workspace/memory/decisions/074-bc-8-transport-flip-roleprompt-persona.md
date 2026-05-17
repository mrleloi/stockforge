---
id: 074
title: BC-8 Transport Flip + RolePromptPack Foundation + PersonaRegistry (D-052 § Implementation step 1 final closure)
status: PROPOSED
date: 2026-05-17
authors: sandwich-dev S375
level: IMPL
supersedes: []
superseded_by: []
related:
  - "D-050 ACCEPTED 2026-05-09 anthropic→subagent SYSTEMIC"
  - "D-051 ACCEPTED 2026-05-09 news-extractor refactor"
  - "D-052 ACCEPTED 2026-05-09 anthropic SDK code-path removal — § Implementation step 1 FINAL EXECUTION via THIS ADR"
  - "D-072 ACCEPTED 2026-05-17 BC-5 transport-flip default-flip (S368)"
  - "D-066 PROPOSED CrawlerAdapter ABC (INFORMATIONAL precedent for ABC-vs-Protocol-vs-dataclass decision in DD-7)"

empirical_close_verify: |
  - ClaudeLLMPerspectiveAdapter instantiable post-flip + default transport == claude_cli_transport (DC-GATE-9 PASS)
  - ZERO 'import anthropic' / 'from anthropic' in packages/infrastructure/analysis/claude_llm_perspective_adapter.py (grep-asserted DC-GATE-7 PASS; TC test_no_anthropic_import_in_module_source PASS)
  - '_default_transport' symbol REMOVED from claude_llm_perspective_adapter.py (DC-GATE-8 PASS; TC test_default_transport_function_removed_from_module PASS)
  - mypy --strict + ruff + pytest on packages/infrastructure/analysis/ + packages/application/analysis/ exit 0
  - test_adapter.py 8 existing routing tests PASS unchanged + 4 new regression tests PASS
  - test_bear_agent.py 12 tests PASS unchanged (regression floor DC-REGRESSION-1)
  - test_quant_agent.py 10 tests PASS unchanged (regression floor DC-REGRESSION-2)
  - test_synthesizer.py 9 tests PASS unchanged (regression floor DC-REGRESSION-3)
  - test_phase1_data_gatherer.py 3 tests PASS unchanged (regression floor DC-REGRESSION-4)
  - RolePromptPack instantiable with 10-field shape per DD-7; 23 tests pass in test_role_prompt_pack.py
  - PersonaRegistry register+get+all_role_ids+load_from_json all functional; 14 tests pass (1 skipped Windows symlink)
  - D-052 spec compliance reaches 100% for BC-8 surface (was 0% per S369 verifier F3 finding — step 1 outstanding)
---

# D-074 — BC-8 Transport Flip + RolePromptPack Foundation + PersonaRegistry

## Decision

Three coordinated changes shipped as one IMPL bundle per plan-034 § E.1:

### (a) BC-8 Transport Flip — `packages/infrastructure/analysis/claude_llm_perspective_adapter.py`

REMOVE `_default_transport` function (was lines 73-98 in pre-S375 version) + `import anthropic`
lazy-import at L80. FLIP transport field default to `claude_cli_transport` from same-BC
sibling `subagent_transport.py` per D-052 § Implementation step 1 EXPLICIT text. Tests inject
stub via constructor kwarg (existing pattern; unchanged). Net delta: ~+10/-30 LOC.

```python
# Before (pre-S375):
transport: Callable[[str, str, str, float], tuple[str, int, int]] = field(
    default=_default_transport
)

# After (plan-034 D3):
from packages.infrastructure.analysis.subagent_transport import claude_cli_transport

transport: Callable[[str, str, str, float], tuple[str, int, int]] = field(
    default=claude_cli_transport
)
```

### (b) RolePromptPack NEW frozen dataclass — `packages/application/analysis/role_prompt_pack.py`

10 fields per master plan-033 DD-7 (role_id, persona_name, system_prompt_template,
conviction_guidance, citation_requirements, vietnam_notes, min_points,
min_distinct_categories, category_universe, model_id_preference). Data only; behavior lives
in per-persona adapter class (F.2 sub-plan ships those). `__post_init__` enforces 9 invariants
via `RolePromptPackInvariantError`.

### (c) PersonaRegistry NEW — `packages/application/analysis/persona_registry.py`

Stdlib `dict[str, RolePromptPack]` wrapper. Methods: `register(pack)`, `get(role_id)`,
`all_role_ids()`, `load_from_json(json_path, base_dir)`. D-064 path-safety 5-invariant
compliance on `load_from_json`. YAML deferred (pyyaml not in pyproject; AP-7 named revisit
trigger). `all_role_ids()` returns sorted tuple for determinism (D-059 R2).

---

## Pattern source

- ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict — direct precedent for
  PersonaRegistry stdlib dict pattern (pattern-port only; LICENSE-file caveat per A-01 § 6)
- StockForge `packages/infrastructure/analysis/perspectives/bear_agent.py:41-77` SYSTEM_PROMPT
  inline template — reference for RolePromptPack.system_prompt_template content format
- D-072 ACCEPTED 2026-05-17 — BC-5 news transport-flip MIRROR for BC-8 (this ADR)
- D-052 § Implementation step 1 EXPLICIT — "Set the dataclass `transport` default to
  `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC
  import)"

---

## D-052 spec compliance attestation (100% for BC-8 surface upon this commit)

D-052 ACCEPTED 2026-05-09 enumerated 4 implementation steps:

| Step | Target | Status pre-S375 | Status post-S375 |
|---|---|---|---|
| 1 | Delete `_default_transport` + `import anthropic` from `claude_llm_perspective_adapter.py` + set transport default to `claude_cli_transport` | NOT APPLIED (S369 verifier F3) | **APPLIED via plan-034 D3** |
| 2 | Delete `_default_transport` stub from `claude_llm_extractor.py` | APPLIED (D-051 / D-072) | APPLIED (UNCHANGED this plan) |
| 3 | Remove `anthropic>=0.40.0` from `pyproject.toml` dependencies | NOT APPLIED | DEFERRED per RM-AS-2 (separate D-052-V2 cleanup ADR scope) |
| 4 | Replace NotImplementedError-deprecation test with regression test asserting (a) `_default_transport` symbol gone (b) no anthropic import | APPLIED for BC-5 (D-051/D-072); NOT APPLIED for BC-8 | **APPLIED for BC-8 via plan-034 D4** (test_adapter.py: `test_no_anthropic_import_in_module_source` + `test_default_transport_function_removed_from_module`) |

**Net D-052 spec compliance after this plan-034 ships**: Steps 1+2+4 complete for BC-8 surface;
step 3 (pyproject drop) deferred per RM-AS-2 scope-narrowing.

---

## Rule 16 mode 1 satisfaction (by construction)

- RolePromptPack ships data only; no numeric LLM emission surface
- `min_points: int` + `min_distinct_categories: int` are integer thresholds set at registration
  time (NOT LLM output)
- `conviction_guidance: str` is text rubric instructing LLM to pick categorical Conviction enum
  STRONG/MODERATE/WEAK (mode 1 categorical surrogate per Rule 16 + I-S1)
- LLM output schema UNCHANGED per existing PerspectiveAnalysis contract; Conviction StrEnum
  preserved per existing `conviction.py:17-22`

---

## DI graceful-degradation

| Construction | transport | Use case |
|---|---|---|
| `ClaudeLLMPerspectiveAdapter()` no-arg | `claude_cli_transport` (CLI subprocess) | Production composition root |
| `ClaudeLLMPerspectiveAdapter(transport=stub)` | injected stub callable | Tests (existing pattern unchanged) |
| `ClaudeLLMPerspectiveAdapter(model_override="...")` | `claude_cli_transport` with model override | Per-thesis model pinning |

PersonaRegistry has no graceful-degradation; explicit registration is required (mirrors
composition root pattern at `validate_thesis_phase1.py:153-171`).

---

## DD-1: RolePromptPack = FROZEN DATACLASS (not Protocol, not ABC)

RolePromptPack is `@dataclass(frozen=True, slots=True)` — NOT Protocol, NOT ABC.

**Rationale**: RolePromptPack is data not behavior; Protocol is for adapter contracts requiring
duck-typed behavior conformance (over-engineering for data-only class); ABC implies
subclass-based polymorphism (validator behavior owned by per-persona adapter class per DD-4
HYBRID master plan-033 — different design problem). D-066 CrawlerAdapter ABC pattern is
INFORMATIONAL not binding — different design problem (per-source behavior overrides vs
RolePromptPack no-per-persona-behavior-overrides). Data dict suffices per Karpathy P2.

## DD-4: Transport-flip = REUSE existing claude_cli_transport (not new file)

F.1 ADOPTS existing `claude_cli_transport` from `subagent_transport.py:144-222` verbatim.
No new `claude_cli_perspective_transport.py` file authored.

**Rationale**: D-052 § Implementation step 1 EXPLICITLY names `claude_cli_transport` from
`subagent_transport.py` as the target ("from the same-BC sibling module `subagent_transport.py`
(no cross-BC import)"). Creating new file = Karpathy P3 violation (duplicates 150 LOC). BC-8
signature matches existing `claude_cli_transport` 4-arg→3-tuple; BC-5 has own transport file
because BC-5 signature DIFFERS (2-arg→str).

---

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. **claude CLI substrate unavailable in production runtime** → revert to stub transport via
   constructor kwarg (D-050 § Edge cases path); CHARTER-TIER consideration if widespread
   deployment without claude CLI available

2. **YAML adoption trigger** (3+ persona packs in JSON + project-owner reports edit-loop friction)
   → add pyyaml dep via separate sub-plan with explicit user ratification; PersonaRegistry adds
   `load_from_yaml(yaml_path)` method mirroring `load_from_json`

3. **PersonaRegistry hot-reload trigger** (project-owner edits persona pack during live dogfood
   and asks for reload) → add `reload(role_id)` method + atomic-swap via D-062 atomic-write
   doctrine; Phase F-prime-V2

---

## Carry-forward risks

- **RM-AS-2** — D-052 § Implementation step 3 pyproject drop NOT applied this plan; `anthropic`
  remains in `pyproject.toml` dependencies; separate D-052-V2 cleanup ADR scope; verifier S376
  acknowledges as known-deferred not defect

---

## Files modified

- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` — D3: transport flip +
  `_default_transport` removal + `import anthropic` removal + docstring update
- `packages/application/analysis/role_prompt_pack.py` — D1: NEW frozen dataclass (10 fields per
  DD-7 + `__post_init__` validation + `RolePromptPackInvariantError`)
- `packages/application/analysis/persona_registry.py` — D2: NEW stdlib dict wrapper + JSON loader
  + D-064 path-safety + `PersonaRegistryError`
- `packages/application/analysis/test_role_prompt_pack.py` — D4: NEW 23 test cases
- `packages/application/analysis/test_persona_registry.py` — D4: NEW 15 test cases (14 pass + 1 skipped Windows symlink)
- `packages/infrastructure/analysis/test_adapter.py` — D4: 4 regression additions
- `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` — THIS file (D5)
- `agent-workspace/role-packs/README.md` — D5: NEW placeholder

---

## Source

- plan-034 (S374 architect) § D DD-1 through DD-9 + § E D1-D5
- master plan-033 (S373 architect) § E.1 + DD-4 + DD-5 + DD-6 + DD-7 + DD-8 + § K.2
- D-052 ACCEPTED 2026-05-09 § Implementation step 1
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (modification target)
- `packages/infrastructure/analysis/subagent_transport.py` (consumed verbatim; DD-9 UNCHANGED)
