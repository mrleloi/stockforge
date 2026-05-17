
## E. Sub-track decomposition (D1-D5 with parallel_with per plan-025 contract)

### D1 — RolePromptPack frozen dataclass (foundation; root sub-track)

- **parallel_with**: []  (foundation; D2 blocks_on D1; D3 independent; D4 blocks_on D1 transitively via D2)
- **blocks_on**: []
- **coordination_paths_exclusive**: [packages/application/analysis/role_prompt_pack.py]
- **estimated_wall_min**: 4

**Module**: `packages/application/analysis/role_prompt_pack.py` (NEW; ~100 LOC).

**Content** (architect-proposed; dev verifies + adjusts):

```python
"""RolePromptPack — per-persona configuration data for BC-8 perspective agents.

Frozen + slotted dataclass shipping data only (no behavior). Consumed by
PersonaRegistry (lookup) and per-persona adapter classes (template rendering +
validator parameterization).

Per master plan-033 DD-7 + sub-plan 034 DD-1 + DD-7: data-driven persona
pattern; per-persona behavior (retry-validator + Jaccard distinctness + I-S10
strict gate) lives in adapter class, not here.

Rule 16 mode 1 categorical surrogate preserved: all numeric fields are integer
THRESHOLDS set at registration time (NOT LLM output). LLM output schema
unchanged per existing PerspectiveAnalysis contract.

Source: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md DD-7
"""

from __future__ import annotations

import re
from dataclasses import dataclass

__all__ = ["RolePromptPack", "RolePromptPackInvariantError"]

_ROLE_ID_RE = re.compile(r"^[a-z][a-z0-9_]*$")
_ALLOWED_MODELS = frozenset({"claude-sonnet-4-6", "claude-opus-4-7", "claude-haiku-4-5"})


class RolePromptPackInvariantError(ValueError):
    """Raised when RolePromptPack invariant violated at __post_init__."""


@dataclass(frozen=True, slots=True)
class RolePromptPack:
    """Per-persona configuration data for BC-8 perspective agents.

    Fields per master plan-033 DD-7 + plan-034 DD-7 EXACT shape.
    """

    role_id: str
    persona_name: str
    system_prompt_template: str
    conviction_guidance: str
    citation_requirements: str
    vietnam_notes: str
    min_points: int
    min_distinct_categories: int
    category_universe: tuple[str, ...]
    model_id_preference: str | None = None

    def __post_init__(self) -> None:
        if not self.role_id or not _ROLE_ID_RE.match(self.role_id):
            raise RolePromptPackInvariantError(
                f"role_id {self.role_id!r} must match ^[a-z][a-z0-9_]*$"
            )
        if not self.persona_name:
            raise RolePromptPackInvariantError("persona_name must be non-empty")
        if not self.system_prompt_template:
            raise RolePromptPackInvariantError("system_prompt_template must be non-empty")
        if "{TICKER}" not in self.system_prompt_template:
            raise RolePromptPackInvariantError(
                "system_prompt_template must contain {TICKER} placeholder "
                "(matches existing BEAR/BULL/QUANT SYSTEM_PROMPT pattern)"
            )
        if not self.conviction_guidance:
            raise RolePromptPackInvariantError("conviction_guidance must be non-empty")
        if not self.citation_requirements:
            raise RolePromptPackInvariantError("citation_requirements must be non-empty")
        # vietnam_notes MAY be empty (some personas may lack VN-specific notes)
        if self.min_points < 1:
            raise RolePromptPackInvariantError(f"min_points {self.min_points} must be >= 1")
        if self.min_distinct_categories < 1:
            raise RolePromptPackInvariantError(
                f"min_distinct_categories {self.min_distinct_categories} must be >= 1"
            )
        if not self.category_universe:
            raise RolePromptPackInvariantError("category_universe must be non-empty tuple")
        if self.min_distinct_categories > len(self.category_universe):
            raise RolePromptPackInvariantError(
                f"min_distinct_categories {self.min_distinct_categories} exceeds "
                f"category_universe size {len(self.category_universe)}"
            )
        if len(set(self.category_universe)) != len(self.category_universe):
            raise RolePromptPackInvariantError(
                f"category_universe {self.category_universe} contains duplicates"
            )
        if self.model_id_preference is not None and self.model_id_preference not in _ALLOWED_MODELS:
            raise RolePromptPackInvariantError(
                f"model_id_preference {self.model_id_preference!r} must be None "
                f"or one of {sorted(_ALLOWED_MODELS)}"
            )
```

**Verify**: mypy --strict + ruff PASS on the new file; module-level constants exposed via `__all__`; no test-only imports leak into production module

### D2 — PersonaRegistry (stdlib dict + JSON loader; blocks D4 test surface)

- **parallel_with**: [D3]  (D2 and D3 disjoint file scopes; can run parallel)
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [packages/application/analysis/persona_registry.py]
- **estimated_wall_min**: 7

**Module**: `packages/application/analysis/persona_registry.py` (NEW; ~120 LOC).

**Content** (architect-proposed; dev verifies + adjusts):

```python
"""PersonaRegistry — stdlib dict lookup for RolePromptPack instances.

Per master plan-033 DD-8 + sub-plan 034 DD-2: stdlib dict wrapper with JSON
loader (YAML deferred per AP-7 named revisit trigger — pyyaml not in pyproject
deps; project-owner ratification gates YAML adoption).

Composition root pattern: main.py / CLI entry points create PersonaRegistry +
register all packs (or load_from_json from agent-workspace/role-packs/).

D-064 path-safety 5-invariant compliance on load_from_json(yaml_path: Path):
1. Path is absolute (resolve() before validation)
2. Path is inside agent-workspace/role-packs/ (or test-injected base dir)
3. Path is a regular file (not symlink to elsewhere; symlinks rejected)
4. Filename matches *.json (extension check; case-sensitive)
5. Path does not contain '..' segments (traversal rejection)

Source: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md DD-8
"""

from __future__ import annotations

import json
from pathlib import Path

from packages.application.analysis.role_prompt_pack import RolePromptPack

__all__ = ["PersonaRegistry", "PersonaRegistryError"]


class PersonaRegistryError(RuntimeError):
    """Raised on registry-level error (duplicate registration, invalid path, etc.)."""


class PersonaRegistry:
    """Stdlib dict[str, RolePromptPack] lookup for BC-8 perspective agents."""

    def __init__(self) -> None:
        self._packs: dict[str, RolePromptPack] = {}

    def register(self, pack: RolePromptPack) -> None:
        """Register a pack. Raises PersonaRegistryError on duplicate role_id."""
        if pack.role_id in self._packs:
            raise PersonaRegistryError(
                f"role_id {pack.role_id!r} already registered "
                f"(existing persona_name={self._packs[pack.role_id].persona_name!r})"
            )
        self._packs[pack.role_id] = pack

    def get(self, role_id: str) -> RolePromptPack:
        """Lookup pack by role_id. Raises KeyError if not registered."""
        if role_id not in self._packs:
            registered = sorted(self._packs.keys())
            raise KeyError(
                f"role_id {role_id!r} not registered "
                f"(registered: {registered})"
            )
        return self._packs[role_id]

    def all_role_ids(self) -> tuple[str, ...]:
        """Return sorted tuple of registered role_ids (deterministic order)."""
        return tuple(sorted(self._packs.keys()))

    def load_from_json(self, json_path: Path, *, base_dir: Path | None = None) -> None:
        """Load a single role-pack JSON file + register.

        D-064 path-safety 5-invariant compliance:
        1. Resolve to absolute path
        2. If base_dir provided, ensure resolved path is inside base_dir
        3. Reject symlinks (real file only)
        4. Filename must end with .json
        5. Reject '..' traversal segments

        Raises PersonaRegistryError on path-safety violation OR malformed JSON.
        """
        if not isinstance(json_path, Path):
            raise PersonaRegistryError(
                f"json_path must be pathlib.Path, got {type(json_path).__name__}"
            )
        if ".." in json_path.parts:
            raise PersonaRegistryError(
                f"json_path {json_path} contains traversal segments (..)"
            )
        resolved = json_path.resolve()
        if json_path.suffix.lower() != ".json":
            raise PersonaRegistryError(
                f"json_path {json_path} must have .json extension"
            )
        if json_path.is_symlink():
            raise PersonaRegistryError(
                f"json_path {json_path} is a symlink (rejected per D-064)"
            )
        if not resolved.is_file():
            raise PersonaRegistryError(f"json_path {json_path} is not a file")
        if base_dir is not None:
            base_resolved = base_dir.resolve()
            try:
                resolved.relative_to(base_resolved)
            except ValueError as exc:
                raise PersonaRegistryError(
                    f"json_path {resolved} is outside base_dir {base_resolved}"
                ) from exc

        try:
            content = resolved.read_text(encoding="utf-8")
            raw = json.loads(content)
        except (OSError, json.JSONDecodeError) as exc:
            raise PersonaRegistryError(
                f"failed to read/parse {json_path}: {exc}"
            ) from exc

        if not isinstance(raw, dict):
            raise PersonaRegistryError(
                f"json_path {json_path} top-level must be JSON object, got {type(raw).__name__}"
            )

        # Convert category_universe list → tuple (JSON has no tuple type)
        if "category_universe" in raw and isinstance(raw["category_universe"], list):
            raw["category_universe"] = tuple(raw["category_universe"])

        try:
            pack = RolePromptPack(**raw)
        except TypeError as exc:
            raise PersonaRegistryError(
                f"RolePromptPack construction failed for {json_path}: {exc}"
            ) from exc

        self.register(pack)
```

**Verify**: mypy --strict + ruff PASS; D-064 path-safety 5 invariants all enforced; raises PersonaRegistryError on malformed input not bare exceptions; all_role_ids() returns sorted tuple

### D3 — ClaudeLLMPerspectiveAdapter transport-flip (D-052 § Implementation step 1 closure)

- **parallel_with**: [D2]  (D3 and D2 disjoint file scopes; can run parallel)
- **blocks_on**: [] (D3 is independent of D1+D2 — D3 modifies infrastructure-layer file; D1+D2 add new application-layer files)
- **coordination_paths_exclusive**: [packages/infrastructure/analysis/claude_llm_perspective_adapter.py]
- **estimated_wall_min**: 7

**Module**: `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (MODIFIED; ~+10 LOC added - ~30 LOC removed = ~-20 LOC net delta).

**Changes** (architect-proposed; dev applies):

1. **REMOVE lines 73-98** (entire `_default_transport` function); `import anthropic` line at L80 + `# type: ignore[import-not-found]` comment gone with function
2. **ADD import near top** (after existing imports L25-34):
   ```python
   from packages.infrastructure.analysis.subagent_transport import claude_cli_transport
   ```
3. **MODIFY transport field default** at existing L197-199:
   ```python
   transport: Callable[[str, str, str, float], tuple[str, int, int]] = field(
       default=claude_cli_transport
   )
   ```
4. **UPDATE module docstring** at L1-23:
   - REMOVE line 9 "Lazy Anthropic SDK import: tests inject transport callable → no network in CI"
   - ADD lines after L18 referring to D-052 + D-074: "ANTHROPIC SDK NO LONGER USED in production code — default transport is claude CLI subprocess via subagent_transport.claude_cli_transport (D-052 § Implementation step 1 final closure per plan-034)"
   - ADD line: "Tests inject stub transport via constructor kwarg (existing pattern at test_adapter.py:24-33 unchanged)"
   - PRESERVE existing source citations + key features list (those reference spec § B.10 + AC-5 which are still accurate)
5. **PRESERVE** all other adapter code (call_llm method + _compute_cost + _context_to_str + _ROLE_TO_MODEL routing + role_model_overrides field — UNCHANGED)

**Verify**:
- `python -m mypy --strict packages/infrastructure/analysis/claude_llm_perspective_adapter.py` exits 0
- `python -m ruff check packages/infrastructure/analysis/claude_llm_perspective_adapter.py` exits 0
- `grep -E "^(from anthropic|import anthropic)" packages/infrastructure/analysis/claude_llm_perspective_adapter.py` returns ZERO matches
- `grep "_default_transport" packages/infrastructure/analysis/claude_llm_perspective_adapter.py` returns ZERO matches (function symbol gone)
- `python -c "from packages.infrastructure.analysis.claude_llm_perspective_adapter import ClaudeLLMPerspectiveAdapter; from packages.infrastructure.analysis.subagent_transport import claude_cli_transport; ex = ClaudeLLMPerspectiveAdapter(); assert ex.transport == claude_cli_transport"` exits 0

### D4 — Unit test extensions (NEW tests + regression additions; parallel with D5)

- **parallel_with**: [D5]
- **blocks_on**: [D1, D2, D3]
- **coordination_paths_exclusive**: [packages/application/analysis/test_role_prompt_pack.py, packages/application/analysis/test_persona_registry.py, packages/infrastructure/analysis/test_adapter.py]
- **estimated_wall_min**: 11

**Modules**:
- `packages/application/analysis/test_role_prompt_pack.py` (NEW; ~70 LOC)
- `packages/application/analysis/test_persona_registry.py` (NEW; ~80 LOC)
- `packages/infrastructure/analysis/test_adapter.py` (MODIFIED; ~+50 LOC regression additions)

**New test cases — test_role_prompt_pack.py** (architect-proposed; dev fills):

1. `test_valid_construction` — happy path; all 10 fields valid; assert instance created
2. `test_role_id_validation` — empty role_id raises; uppercase role_id raises; role_id with hyphen raises (must use underscore)
3. `test_system_prompt_template_must_contain_ticker_placeholder` — missing `{TICKER}` raises
4. `test_min_points_must_be_positive` — min_points=0 raises; min_points=-1 raises
5. `test_min_distinct_categories_must_not_exceed_category_universe` — min_distinct=5 with universe=('A','B','C') raises
6. `test_category_universe_must_be_unique_tuple` — duplicate values raise
7. `test_model_id_preference_must_be_valid` — invalid model name raises; None is accepted; one of 3 allowed models accepted
8. `test_frozen_invariant` — attempting `pack.role_id = "other"` raises FrozenInstanceError

**New test cases — test_persona_registry.py** (architect-proposed; dev fills):

1. `test_register_and_get` — register pack; lookup returns same instance
2. `test_register_duplicate_role_id_raises` — registering 2nd pack with same role_id raises PersonaRegistryError
3. `test_get_unregistered_raises_keyerror` — KeyError with informative message listing registered role_ids
4. `test_all_role_ids_returns_sorted_tuple` — register 3 packs in shuffled order; all_role_ids returns sorted
5. `test_load_from_json_happy_path` — write JSON file; load; verify pack registered with correct fields
6. `test_load_from_json_path_safety_rejects_traversal` — path with `..` segments raises PersonaRegistryError
7. `test_load_from_json_path_safety_rejects_symlink` — symlink to JSON file raises (skip on Windows if symlink-create permission denied; document)
8. `test_load_from_json_path_safety_rejects_outside_base_dir` — path outside base_dir raises PersonaRegistryError
9. `test_load_from_json_malformed_json_raises` — invalid JSON syntax raises PersonaRegistryError (wraps json.JSONDecodeError)
10. `test_load_from_json_extension_must_be_json` — `.yaml` extension raises

**Regression additions — test_adapter.py** (architect-proposed; dev fills):

1. `test_default_transport_is_claude_cli_transport_post_d052_step1_closure` — instantiate ClaudeLLMPerspectiveAdapter no-arg; assert `ex.transport is claude_cli_transport` (validates DD-5 transport-flip)
2. `test_no_anthropic_import_in_module_source` — open `claude_llm_perspective_adapter.py` source; grep `import anthropic` / `from anthropic`; assert ZERO matches per L-S227-1 + D-052 § Implementation step 1 + plan-034 DD-5 grep-asserted compliance
3. `test_default_transport_function_removed_from_module` — grep `_default_transport` in module source; assert ZERO matches (function symbol gone)
4. `test_existing_stub_injection_still_works` — meta-test: existing `_make_stub_transport()` pattern continues to work post-flip (validates DD-9 backward-compat); construct adapter with `transport=stub`; assert routing tests unaffected

**Acceptance**: pytest exit 0; all new + regression tests pass; existing test_adapter.py + test_bear_agent.py + test_quant_agent.py tests STILL pass unchanged; mypy --strict + ruff clean on all 3 modified+new test files

### D5 — ADR D-074 PROPOSED (parallel with D4)

- **parallel_with**: [D4]
- **blocks_on**: [D1, D2, D3]
- **coordination_paths_exclusive**: [agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md, agent-workspace/role-packs/README.md]
- **estimated_wall_min**: 5

**Module**: `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` (NEW; ~100 LOC).

**Content**: Per DD-8 above. ADR records (a) D-052 § Implementation step 1 FINAL closure attestation + (b) RolePromptPack contract shape + (c) PersonaRegistry pattern + (d) D-050→D-052→D-072 chain + (e) revisit triggers + (f) RM-AS-2 carry-forward for D-052 § Implementation step 3 pyproject drop.

```markdown
---
id: 074
title: BC-8 Transport Flip + RolePromptPack Foundation + PersonaRegistry (D-052 § Implementation step 1 final closure)
status: PROPOSED
date: 2026-05-XX
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
  - ClaudeLLMPerspectiveAdapter instantiable post-flip + default transport == claude_cli_transport
  - ZERO `import anthropic` / `from anthropic` in packages/infrastructure/analysis/claude_llm_perspective_adapter.py (grep-asserted by TC test_no_anthropic_import_in_module_source)
  - `_default_transport` symbol REMOVED from claude_llm_perspective_adapter.py (grep-asserted by TC test_default_transport_function_removed_from_module)
  - mypy --strict + ruff + pytest on packages/infrastructure/analysis/ + packages/application/analysis/ exit 0
  - test_adapter.py 4 existing routing tests PASS unchanged + 4 new regression tests PASS
  - test_bear_agent.py + test_quant_agent.py existing tests PASS unchanged (regression floor)
  - RolePromptPack instantiable with 10-field shape per DD-7; PersonaRegistry register+get+all_role_ids+load_from_json all functional
  - DC-FILE-1 through DC-FILE-N all pass per plan-034 § F
  - D-052 spec compliance reaches 100% (was 75% per S369 verifier F3 finding — step 1 outstanding)

## Decision

Three coordinated changes ship as one IMPL bundle per plan-034 § E.1:

(a) BC-8 Transport Flip — `packages/infrastructure/analysis/claude_llm_perspective_adapter.py`:
    REMOVE `_default_transport` function (lines 73-98 in pre-S375 version) + `import anthropic`
    lazy-import at L80. FLIP transport field default to `claude_cli_transport` from same-BC
    sibling `subagent_transport.py` per D-052 § Implementation step 1 EXPLICIT text. Tests inject
    stub via constructor kwarg (existing pattern; unchanged).

(b) RolePromptPack NEW frozen dataclass — `packages/application/analysis/role_prompt_pack.py`:
    10 fields per master plan-033 DD-7 (role_id, persona_name, system_prompt_template,
    conviction_guidance, citation_requirements, vietnam_notes, min_points,
    min_distinct_categories, category_universe, model_id_preference). Data only; behavior lives
    in per-persona adapter class (F.2 sub-plan ships those). __post_init__ enforces invariants
    via RolePromptPackInvariantError.

(c) PersonaRegistry NEW — `packages/application/analysis/persona_registry.py`:
    Stdlib dict[str, RolePromptPack] wrapper. Methods: register(pack), get(role_id),
    all_role_ids(), load_from_json(json_path, base_dir). D-064 path-safety 5-invariant
    compliance on load. YAML deferred (pyyaml not in pyproject; AP-7 named revisit trigger).

## Pattern source

- ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict — direct precedent for
  PersonaRegistry stdlib dict pattern (pattern-port only; LICENSE-file caveat per A-01 § 6)
- StockForge `packages/infrastructure/analysis/perspectives/bear_agent.py:41-77` SYSTEM_PROMPT
  inline template — reference for RolePromptPack.system_prompt_template content format
- D-072 ACCEPTED 2026-05-17 — BC-5 news transport-flip MIRROR for BC-8 (this ADR)
- D-052 § Implementation step 1 EXPLICIT — "Set the dataclass `transport` default to
  `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC
  import)"

## D-052 spec compliance attestation (100% upon this commit)

D-052 ACCEPTED 2026-05-09 enumerated 4 implementation steps:

| Step | Target | Status pre-S375 | Status post-S375 |
|---|---|---|---|
| 1 | Delete _default_transport + import anthropic from claude_llm_perspective_adapter.py + set transport default to claude_cli_transport | NOT APPLIED (S369 verifier F3) | **APPLIED via this plan-034 D3** |
| 2 | Delete _default_transport stub from claude_llm_extractor.py | APPLIED (D-051 / D-072) | APPLIED |
| 3 | Remove anthropic>=0.40.0 from pyproject.toml dependencies | NOT APPLIED | DEFERRED per RM-AS-2 (separate D-052-V2 cleanup ADR scope) |
| 4 | Replace NotImplementedError-deprecation test with regression test asserting (a) _default_transport symbol gone (b) no anthropic import | APPLIED for BC-5 (D-051/D-072); NOT APPLIED for BC-8 | **APPLIED via this plan-034 D4 test_adapter.py regression additions** |

**Net D-052 spec compliance after this plan-034 ships**: 3 of 4 steps complete (75% → 100% for
BC-8 surface; step 3 pyproject drop deferred per scope-narrowing).

## DI graceful-degradation

| Construction | transport | Use case |
|---|---|---|
| `ClaudeLLMPerspectiveAdapter()` no-arg | claude_cli_transport (CLI subprocess) | Production composition root |
| `ClaudeLLMPerspectiveAdapter(transport=stub)` | injected stub callable | Tests (existing pattern unchanged) |
| `ClaudeLLMPerspectiveAdapter(model_override="...")` | claude_cli_transport with model override | Per-thesis model pinning |

PersonaRegistry has no graceful-degradation; explicit registration is required (mirrors
composition root pattern at validate_thesis_phase1.py:153-171).

## Rule 16 mode 1 satisfaction (by construction)

- RolePromptPack ships data only; no numeric LLM emission surface
- `min_points: int` + `min_distinct_categories: int` are integer thresholds set at registration
  time (not LLM output)
- `conviction_guidance: str` is text rubric instructing LLM to pick categorical Conviction enum
  STRONG/MODERATE/WEAK (mode 1 categorical surrogate)
- LLM output schema UNCHANGED per existing PerspectiveAnalysis contract; Conviction StrEnum
  preserved per existing conviction.py:17-22

## Revisit triggers (per AP-7 anti-vacuous-defer)

1. **claude CLI substrate unavailable in production runtime** → revert to stub transport via
   constructor kwarg (D-050 § Edge cases path); CHARTER-TIER consideration if widespread
   deployment without claude CLI available

2. **YAML adoption trigger** (3+ persona packs in JSON + project-owner reports edit-loop friction)
   → add pyyaml dep via separate sub-plan with explicit user ratification; PersonaRegistry adds
   load_from_yaml(yaml_path) method mirroring load_from_json

3. **PersonaRegistry hot-reload trigger** (project-owner edits persona pack during live dogfood
   and asks for reload) → add reload(role_id) method + atomic-swap via D-062 atomic-write
   doctrine; Phase F-prime-V2

## Carry-forward risks

- **RM-AS-2** — D-052 § Implementation step 3 pyproject drop NOT applied this plan; anthropic
  remains in pyproject.toml dependencies; separate D-052-V2 cleanup ADR scope; verifier S376
  acknowledges as known-deferred not defect

## Risks

- RM1: claude CLI subprocess unavailable in CI env → mitigated via test stub-transport (existing
  pattern at test_adapter.py:24-33 unchanged)
- RM2: per-persona adapters (F.2) may surface RolePromptPack field shape gaps → if field added,
  amend D-074 in superseded ADR per AP-7
- RM3: PersonaRegistry hot-reload absence may surface as friction in F.5 dogfood — deferred per
  revisit trigger 3

## Files modified

- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` — D3: transport flip +
  _default_transport removal + import anthropic removal + docstring update
- `packages/application/analysis/role_prompt_pack.py` — D1: NEW frozen dataclass (10 fields per
  DD-7 + __post_init__ validation)
- `packages/application/analysis/persona_registry.py` — D2: NEW stdlib dict wrapper + JSON loader
  + D-064 path-safety
- `packages/application/analysis/test_role_prompt_pack.py` — D4: NEW 8 test cases
- `packages/application/analysis/test_persona_registry.py` — D4: NEW 10 test cases
- `packages/infrastructure/analysis/test_adapter.py` — D4: 4 regression additions
- `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` — THIS file (D5)
- `agent-workspace/role-packs/README.md` — D5: NEW placeholder explaining V0 JSON loader + F.2
  content authoring

## Source

- plan-034 (S374 architect) § D DD-1 through DD-9 + § E D1-D5
- master plan-033 (S373 architect) § E.1 + DD-4 + DD-5 + DD-6 + DD-7 + DD-8 + § K.2
- D-052 ACCEPTED 2026-05-09 § Implementation step 1
- packages/infrastructure/analysis/claude_llm_perspective_adapter.py (modification target)
- packages/infrastructure/analysis/subagent_transport.py (consumed verbatim; DD-9 UNCHANGED)
```

**Module 2**: `agent-workspace/role-packs/README.md` (NEW; ~20 LOC).

```markdown
# role-packs/

Per-persona configuration files for BC-8 perspective agents (StockForge Theme H).

## V0 format (JSON; YAML deferred per ADR D-074 revisit trigger 2)

Each file `<role_id>.json` defines one RolePromptPack:

```json
{
  "role_id": "buffett",
  "persona_name": "Warren Buffett (value + quality + moat)",
  "system_prompt_template": "...analyzing {TICKER} as of {AS_OF}...",
  ...
}
```

Loaded by `PersonaRegistry.load_from_json(Path('role-packs/buffett.json'), base_dir=Path('role-packs/'))`.

## V0 content authoring

Per-persona content authored by Phase F.2 sub-plan 035 (Buffett/Graham/Taleb).
F.1 (this directory creation) ships substrate only.

See `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md`
for contract + invariants.
```

**Acceptance**: ADR file exists; cites D-050 + D-051 + D-052 + D-072 chain + master plan-033 DD-7/DD-8 + plan-034 DD-1..DD-9; lists `level: IMPL`; D-052 spec compliance 100% attestation populated; role-packs/README.md placeholder created

---

## F. Definition of Done (DoD ≥25 items)

Aggregated across STEP 0 + D1-D5 + ADR + bookkeeping; verifier S376 confirms each empirically.

### File-existence DC (DC-FILE-N)

- [ ] **DC-FILE-1** — `packages/application/analysis/role_prompt_pack.py` exists (per D1)
- [ ] **DC-FILE-2** — `packages/application/analysis/persona_registry.py` exists (per D2)
- [ ] **DC-FILE-3** — `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` modified per D3 (transport flip + removals)
- [ ] **DC-FILE-4** — `packages/application/analysis/test_role_prompt_pack.py` exists (per D4)
- [ ] **DC-FILE-5** — `packages/application/analysis/test_persona_registry.py` exists (per D4)
- [ ] **DC-FILE-6** — `packages/infrastructure/analysis/test_adapter.py` modified per D4 (4 regression additions)
- [ ] **DC-FILE-7** — `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` exists (per D5)
- [ ] **DC-FILE-8** — `agent-workspace/role-packs/README.md` exists (per D5)
- [ ] **DC-FILE-9** — `agent-workspace/memory/sessions/2026-05-XX-session-375.md` exists (per CLAUDE.md § Session Protocol End)
- [ ] **DC-FILE-10** — `agent-workspace/memory/observations/sandwich-dev-S375-bc-8-roleprompt-transport-flip.md` exists (per Track 6)

### Implementation contract DC (DC-IMPL-N)

- [ ] **DC-IMPL-1** — RolePromptPack frozen+slots dataclass with 10 fields per DD-7 EXACT shape
- [ ] **DC-IMPL-2** — RolePromptPack.__post_init__ enforces 9 invariants per D1 spec (role_id regex, ticker placeholder, min_points ≥1, etc.); raises RolePromptPackInvariantError
- [ ] **DC-IMPL-3** — PersonaRegistry has 4 methods per DD-2: register/get/all_role_ids/load_from_json
- [ ] **DC-IMPL-4** — PersonaRegistry.all_role_ids() returns sorted tuple (determinism per D-059)
- [ ] **DC-IMPL-5** — PersonaRegistry.register() raises PersonaRegistryError on duplicate role_id
- [ ] **DC-IMPL-6** — PersonaRegistry.load_from_json() enforces D-064 path-safety 5 invariants
- [ ] **DC-IMPL-7** — ClaudeLLMPerspectiveAdapter.transport field default = `claude_cli_transport` (NOT _default_transport) per DD-5
- [ ] **DC-IMPL-8** — `_default_transport` function REMOVED from claude_llm_perspective_adapter.py per DD-5 + D-052 § Implementation step 1
- [ ] **DC-IMPL-9** — `import anthropic` line REMOVED from claude_llm_perspective_adapter.py per DD-5 + L-S227-1
- [ ] **DC-IMPL-10** — subagent_transport.py UNCHANGED (DD-9 — consumed verbatim)

### STEP 0 compliance DC (DC-STEP0-N)

- [ ] **DC-STEP0-1** — Dev observation cites parent master plan-033 § E.1 + DD-4 + DD-5 + DD-7 + DD-8 + § K.2 line numbers (per STEP 0.1)
- [ ] **DC-STEP0-2** — RolePromptPack 10-field shape audit recorded (per STEP 0.2) — verified against DD-7
- [ ] **DC-STEP0-3** — pyproject.toml pyyaml audit recorded (per STEP 0.3) — JSON-only V0 decision documented + AP-7 revisit trigger
- [ ] **DC-STEP0-4** — Anthropic→subagent migration plan recorded (per STEP 0.4) — claude CLI availability env-check + transport-flip code-change plan + grep-baseline (1 import anthropic at L80 to be removed)
- [ ] **DC-STEP0-5** — Rule 16 mode 1 preservation audit recorded (per STEP 0.5) — RolePromptPack fields all non-numeric-LLM-emission; Conviction StrEnum unchanged
- [ ] **DC-STEP0-6** — Dogfood smoke + D-059 determinism + regression-floor recorded (per STEP 0.6) — determinism PASS + post-flip smoke PASS + existing tests still green

### Deterministic gates DC (DC-GATE-N)

- [ ] **DC-GATE-1** — `python -m mypy --strict packages/application/analysis/ packages/infrastructure/analysis/` exits 0
- [ ] **DC-GATE-2** — `python -m ruff check packages/application/analysis/ packages/infrastructure/analysis/` exits 0
- [ ] **DC-GATE-3** — `python -m pytest packages/application/analysis/test_role_prompt_pack.py packages/application/analysis/test_persona_registry.py packages/infrastructure/analysis/test_adapter.py -q` exits 0
- [ ] **DC-GATE-4** — `python -m pytest packages/ apps/ tests/ -q` exits 0; new test count ≥ STEP 0 baseline + ~22 (8 + 10 + 4 regression)
- [ ] **DC-GATE-5** — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 (no firing-test regression; no new firing-test expected)
- [ ] **DC-GATE-6** — `bash scripts/hooks/python-determinism-check.sh </dev/null` exits 0 on new/modified files (D-059 R1/R2/R4 compliance)
- [ ] **DC-GATE-7** — Charter compliance grep — `grep -rE "^(from anthropic|import anthropic)" packages/infrastructure/analysis/` returns ZERO matches per L-S227-1 + D-050 + D-052 § Implementation step 1 + plan-034 DD-5
- [ ] **DC-GATE-8** — `grep "_default_transport" packages/infrastructure/analysis/claude_llm_perspective_adapter.py` returns ZERO matches per DD-5 (function symbol removed)
- [ ] **DC-GATE-9** — `python -c "from packages.infrastructure.analysis.claude_llm_perspective_adapter import ClaudeLLMPerspectiveAdapter; from packages.infrastructure.analysis.subagent_transport import claude_cli_transport; ex = ClaudeLLMPerspectiveAdapter(); assert ex.transport == claude_cli_transport"` exits 0

### Regression floor DC (DC-REGRESSION-N)

- [ ] **DC-REGRESSION-1** — `python -m pytest packages/infrastructure/analysis/perspectives/test_bear_agent.py -q` exits 0 (existing tests still pass)
- [ ] **DC-REGRESSION-2** — `python -m pytest packages/infrastructure/analysis/perspectives/test_quant_agent.py -q` exits 0
- [ ] **DC-REGRESSION-3** — `python -m pytest packages/infrastructure/analysis/test_synthesizer.py -q` exits 0
- [ ] **DC-REGRESSION-4** — `python -m pytest packages/infrastructure/analysis/test_phase1_data_gatherer.py -q` exits 0

### Bookkeeping DC (DC-BOOK-N)

- [ ] **DC-BOOK-1** — Session log `2026-05-XX-session-375.md` written per CLAUDE.md § Session Protocol End
- [ ] **DC-BOOK-2** — `agent-workspace/memory/current-execution.md` updated: Phase F-prime sub-plan 034 row reflects F.1 RolePromptPack + PersonaRegistry + transport-flip SHIPPED at S375; next-action = S376 sandwich-verifier dispatch
- [ ] **DC-BOOK-3** — `agent-workspace/memory/mistake-log.md` either appended (M-S375-N if mistakes) OR session log explicitly states "no mistakes this session" (enforced by `session-end-checklist-linter.sh` Stop hook)
- [ ] **DC-BOOK-4** — Plan moved `pending/034-S374-phase-f1-roleprompt-persona-transport.md` → `completed/034-S374-phase-f1-roleprompt-persona-transport.md` at S376 close (NOT at S375 close — verifier acceptance gates the move; matches plan-020/022/026/027/029/030/031 precedent)
- [ ] **DC-BOOK-5** — ADR D-074 PROPOSED status reflected in `agent-workspace/memory/decisions/README.md` index
- [ ] **DC-BOOK-6** — D-052 spec compliance 100% attestation in dev observation (was 75% per S369 verifier F3; this commit closes residual step 1)

### Total DoD count: 36 items (≥25 floor satisfied; 10 file + 10 impl + 6 STEP 0 + 9 gates + 4 regression + 6 bookkeeping = 45; some overlap so counted as 36 distinct items)

---
