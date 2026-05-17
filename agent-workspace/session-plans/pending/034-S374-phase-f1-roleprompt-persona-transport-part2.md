
## C. STEP 0 — BLOCKING DEPENDENCY EVALUATION (sub-steps 0.1 through 0.6)

> **CRITICAL**: STEP 0 is BLOCKING — S375 dev MUST complete sub-steps 0.1-0.6 + (CONDITIONAL) 0.6-STOP-AND-ASK before writing ANY production code in D1-D5. This mirrors the EXISTING-EXTRACTOR-AUGMENT pattern per parent plan-031 STEP 0 + master plan-033 § E.1 + plan-034 binding_decisions.

### Sub-step 0.1 — Audit existing ClaudeLLMPerspectiveAdapter location + API path (VBW empirical)

**Dev action**: Read these files at S375 entry (architect has done this for THIS plan; dev does fresh VBW read per AOM + AP-1 fresh-context):

- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (full read 264 LOC; CONFIRM module location + class shape + `_default_transport` function at L73-98 + `import anthropic` lazy-import inside function at L80 + `transport` field default at L197-199 `field(default=_default_transport)` + `_compute_cost` at L101-108 + `call_llm` at L204-264; modification target for D3 transport-flip)
- `packages/infrastructure/analysis/subagent_transport.py` (full read 222 LOC; CONFIRM drop-in replacement availability — `claude_cli_transport` function at L144-222 returns `(text, input_tokens, output_tokens)` 3-tuple matching ClaudeLLMPerspectiveAdapter.transport field 4-arg→3-tuple signature; ALREADY-SHIPPED per D-052 § Implementation step 1 explicit text "Set the dataclass `transport` default to `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC import)")
- `packages/infrastructure/analysis/test_adapter.py` (full read ≥100 LOC; CONFIRM _make_stub_transport pattern at L24-33 + existing test patterns at L54-100 — regression-floor surface for D3 transport-flip; verify ALL tests use constructor kwarg `transport=stub` pattern; verify NO tests rely on _default_transport directly)
- `packages/infrastructure/analysis/perspectives/test_bear_agent.py` + `test_quant_agent.py` (existence confirmed via Glob; verify ALL tests use constructor kwarg `transport=stub` pattern; regression-floor surface; D3 transport-flip MUST NOT break)
- `packages/infrastructure/analysis/perspectives/bear_agent.py` (offset 1-100 read; CONFIRM SYSTEM_PROMPT at L41-77 = template format reference for RolePromptPack.system_prompt_template content shape — placeholders {TICKER} + {AS_OF} convention preserved)
- `packages/domain/analysis/value_objects/conviction.py` (full read 22 LOC; CONFIRM Conviction StrEnum STRONG/MODERATE/WEAK — UNCHANGED this sub-plan)
- `packages/domain/analysis/models/perspective_analysis.py` (full read 62 LOC; CONFIRM PerspectiveAnalysis dataclass UNCHANGED this sub-plan)
- THIS sub-plan-034 in full + parent master plan-033 § E.1 sub-plan-034 row in § E sequencing + master plan DD-4/DD-5/DD-6/DD-7/DD-8 + § K.2 sub-plan 034 anticipated FLAGS (pyyaml dep + BC-8 transport-flip regression risk)
- ADR D-052 in full + D-050 + D-072 ACCEPTED status confirmation via Read tool

**STOP-AND-ASK trigger**: NONE (foundational read; no decision yet)

**Acceptance**: Dev observation file cites parent master plan-033 § E.1 row + DD-4 + DD-5 + DD-6 + DD-7 + DD-8 + § K.2 anticipated FLAGS verbatim quotes; cites D-052 § Implementation step 1 verbatim text quoted "Set the dataclass `transport` default to `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC import)"; cites file:line for `_default_transport` removal target + `import anthropic` removal target + `transport` field default change

### Sub-step 0.2 — Audit RolePromptPack contract shape (10-field dataclass per DD-7)

**Dev action**:

1. **Confirm new dataclass shape** matches master plan-033 DD-7 lines 378-388 EXACTLY:
   ```python
   @dataclass(frozen=True, slots=True)
   class RolePromptPack:
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
   ```
2. **Validate __post_init__ requirements**:
   - `role_id` MUST be non-empty + match `^[a-z][a-z0-9_]*$` regex (lookup-safe identifier)
   - `system_prompt_template` MUST be non-empty + contain `{TICKER}` placeholder (mirrors bear_agent.py:42 pattern)
   - `min_points` MUST be ≥1 (semantic floor)
   - `min_distinct_categories` MUST be ≥1 and ≤ len(category_universe)
   - `category_universe` MUST be non-empty tuple of unique strings
   - `model_id_preference` MUST be None OR one of `{claude-sonnet-4-6, claude-opus-4-7, claude-haiku-4-5}` (from claude_llm_perspective_adapter.py:41-43 model constants — STEP 0.1 confirms)
3. **Confirm field shape backward-compat**: RolePromptPack is NEW — no existing code consumes it; F.2 sub-plan adds first consumers (per-persona adapters); F.1 ships substrate only

**STOP-AND-ASK trigger**: NONE (NEW schema; no backward-compat surface)

**Acceptance**: Dev observation file documents 10-field shape verbatim + __post_init__ rules + import statements needed (typing imports for `tuple[str, ...] | None`); test_role_prompt_pack.py covers all 6 invariant rules

### Sub-step 0.3 — pyproject.toml pyyaml audit (DD-2 JSON-vs-YAML fallback decision)

**Dev action**:

1. **Read pyproject.toml** lines 1-200 to find current `dependencies` list
2. **Grep pyyaml/PyYAML/yaml** — architect VBW confirmed pyyaml NOT in deps (only entries: `pydantic`, etc. — no yaml)
3. **Decision per DD-2 + master plan-033 DD-8 fallback path**: SHIP JSON loader for V0
   - Implement `PersonaRegistry.load_from_json(json_path: Path) → None` using stdlib `json` module
   - DO NOT add pyyaml to pyproject.toml dependencies (would require user ratification per anti-vacuous-defer)
   - Document AP-7 named revisit trigger in ADR D-074: "YAML adoption trigger = project-owner authors 3+ persona packs in JSON and reports friction (manual escaping of multi-line system_prompt_template strings) → add pyyaml dep via separate sub-plan with explicit user ratification"
4. **JSON format design**: per-persona role-pack file at `agent-workspace/role-packs/<role_id>.json` with shape:
   ```json
   {
     "role_id": "buffett",
     "persona_name": "Warren Buffett (value + quality + moat)",
     "system_prompt_template": "You are a value investor analyzing {TICKER} as of {AS_OF}. ...",
     "conviction_guidance": "STRONG = clear moat ≥3 categories; MODERATE = mixed; WEAK = single-category",
     "citation_requirements": "Every claim cites source_url + source_excerpt ≤500 chars verbatim",
     "vietnam_notes": "VHM is VinGroup-affiliated; consider related-party transaction risk...",
     "min_points": 3,
     "min_distinct_categories": 3,
     "category_universe": ["MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH"],
     "model_id_preference": "claude-sonnet-4-6"
   }
   ```

**STOP-AND-ASK trigger**: NONE (architect-decided JSON-only V0; not a charter flag; pyyaml absence already audited)

**Acceptance**: Dev observation documents pyyaml audit result + JSON format design + AP-7 named revisit trigger added to ADR D-074

### Sub-step 0.4 — Anthropic→subagent transport-flip migration plan (D-052 § Implementation step 1 closure)

**Dev action**:

1. **Audit `import anthropic`**: grep `import anthropic|from anthropic` in `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` — EXPECT 1 match at L80 (inside `_default_transport` function body lazy-import); CONFIRMED via architect Grep
2. **Confirm drop-in replacement available**: `packages/infrastructure/analysis/subagent_transport.py` `claude_cli_transport` function at L144-222 returns `(text, input_tokens, output_tokens)` 3-tuple matching `ClaudeLLMPerspectiveAdapter.transport` field signature (CONFIRMED: 4-arg `(model, system_prompt, user_message, temperature)` → 3-tuple matches existing _default_transport)
3. **Plan transport-flip code-change** (D3 lands):
   - REMOVE `_default_transport` function (lines 73-98 entire function deleted)
   - REMOVE `import anthropic` line (was at line 80 inside removed function; gone with function)
   - REMOVE `# type: ignore[import-not-found]` comment on that import (was at L80; gone with function)
   - CHANGE `transport: Callable[...] = field(default=_default_transport)` at L197-199 to `transport: Callable[...] = field(default=claude_cli_transport)` (no `default_factory` needed — claude_cli_transport is a top-level function reference, not a closure-producing factory)
   - ADD `from packages.infrastructure.analysis.subagent_transport import claude_cli_transport` import near top (after existing imports L25-34)
   - UPDATE module docstring at L1-23 to reflect:
     - "ANTHROPIC SDK NO LONGER USED — default transport is claude CLI subprocess per D-050 + D-052 § Implementation step 1"
     - "D-052 spec compliance reaches 100% upon this commit (was 75% per S369 verifier F3 finding — step 1 outstanding)"
     - Remove "Lazy Anthropic SDK import: tests inject transport callable → no network in CI" (no longer accurate; tests still inject but for different reason)
4. **Existing tests compat** (no test signature change): test_adapter.py + test_bear_agent.py + test_quant_agent.py all use `transport=stub` constructor kwarg — explicit kwarg overrides default; all existing tests pass unchanged

**STOP-AND-ASK trigger (CHARTER-TIER GATE)**: IF claude CLI substrate unavailable in S375 dev environment (e.g. `which claude` returns nothing OR `claude --version` fails) → cannot smoke-test transport-flip → write `human-workspace/notifications/STOP-FINDING-S375-claude-cli-substrate-unavailable.md` documenting (1) env-check evidence, (2) options for user pick: (a) install claude CLI in dev env then resume, (b) defer transport-flip to separate sub-plan + ship RolePromptPack+PersonaRegistry only, (c) retain anthropic SDK as default + escalate to CHARTER-TIER reversal of D-050 SYSTEMIC (HIGHLY UNLIKELY per user 2026-05-09 directive)

**Acceptance**: Dev observation documents transport-flip code-change plan + env-check result (claude CLI version + path) + grep result (zero `import anthropic` in claude_llm_perspective_adapter.py post-D3 expected); existing test signatures confirmed unchanged

### Sub-step 0.5 — Rule 16 mode 1 categorical preservation audit (BINDING per § Charter compliance)

**Dev action**:

1. **Audit RolePromptPack fields for numeric LLM emission risk**:
   - `min_points: int` + `min_distinct_categories: int` are integer THRESHOLDS NOT LLM output — set by RolePromptPack registration, NOT emitted by LLM
   - `model_id_preference: str | None` is configuration string NOT numeric — safe per Rule 16 N/A (enum-like)
   - `system_prompt_template: str` is text template — RolePromptPack does NOT execute; consumer adapter renders + sends to LLM
   - `conviction_guidance: str` is text rubric instructing LLM to pick categorical Conviction (STRONG/MODERATE/WEAK) — does NOT instruct LLM to emit numeric
   - **Verdict**: ALL RolePromptPack fields satisfy Rule 16 by construction (no numeric LLM emission surface)
2. **Audit ClaudeLLMPerspectiveAdapter post-flip for accidental numeric LLM emission**:
   - Existing call_llm at L204-264 returns `(raw_text, cost_usd, model, prompt_hash)` — cost_usd is Decimal computed by `_compute_cost(model, input_tokens, output_tokens)` deterministic function per L101-108 (Rule 16 mode 2 deterministic-pipeline echo); prompt_hash is sha256 (Rule 16 N/A)
   - Existing LLM JSON contract returns `{key_points: []}` — bear/bull/quant agents parse GroundedPoint with Conviction StrEnum (categorical) + category (str) + text + source_url + source_excerpt (no numeric)
   - **Verdict**: ClaudeLLMPerspectiveAdapter transport-flip preserves Rule 16 compliance by construction (no schema change; transport implementation swap only)
3. **Document Rule 16 compliance inline** at RolePromptPack module docstring: "RolePromptPack ships PERSONA CONFIGURATION DATA. All numeric fields are integer THRESHOLDS set at registration time (NOT LLM output); LLM output schema unchanged per Rule 16 mode 1 categorical Conviction preserved"

**STOP-AND-ASK trigger**: NONE (Rule 16 satisfied by construction; F.1 does NOT modify LLM output schema)

**Acceptance**: RolePromptPack module docstring cites Rule 16 mode 1 preservation; ADR D-074 § Rule 16 mode 1 satisfaction by construction section populated

### Sub-step 0.6 — Dogfood integration smoke + D-059 determinism + I-S34 carry-forward

**Dev action** (POST-D5 ship; this is the integration-smoke acceptance gate):

1. **I-S34 HARD-REJECT carry-forward**: `pip list | grep -iE "patchright|playwright[-_]stealth|fake[-_]useragent|UndetectedAdapter|StealthyFetcher|cloudflare"` — expect ZERO matches (no new deps this sub-plan; claude CLI is local subprocess + subagent_transport.py already-shipped)
2. **D-059 determinism smoke** (post-D1+D2 ship; mirror sub-plan 029+030+031 pattern):
   ```bash
   # Smoke-test RolePromptPack equality + PersonaRegistry determinism:
   python -c "
   from packages.application.analysis.role_prompt_pack import RolePromptPack
   from packages.application.analysis.persona_registry import PersonaRegistry
   
   p1 = RolePromptPack(
       role_id='test', persona_name='Test', system_prompt_template='Analyzing {TICKER} as of {AS_OF}',
       conviction_guidance='guide', citation_requirements='cite', vietnam_notes='vn',
       min_points=3, min_distinct_categories=3, category_universe=('A', 'B', 'C'),
       model_id_preference=None,
   )
   p2 = RolePromptPack(
       role_id='test', persona_name='Test', system_prompt_template='Analyzing {TICKER} as of {AS_OF}',
       conviction_guidance='guide', citation_requirements='cite', vietnam_notes='vn',
       min_points=3, min_distinct_categories=3, category_universe=('A', 'B', 'C'),
       model_id_preference=None,
   )
   assert p1 == p2, f'NON-DETERMINISTIC: {p1} != {p2}'
   
   reg = PersonaRegistry()
   reg.register(p1)
   assert reg.get('test') == p1
   assert reg.all_role_ids() == ('test',)
   print('OK: RolePromptPack + PersonaRegistry are deterministic')
   "
   ```
3. **ClaudeLLMPerspectiveAdapter post-flip smoke**:
   ```bash
   python -c "
   from packages.infrastructure.analysis.claude_llm_perspective_adapter import ClaudeLLMPerspectiveAdapter
   # Verify no import anthropic at module level:
   import packages.infrastructure.analysis.claude_llm_perspective_adapter as mod
   src = open(mod.__file__, encoding='utf-8').read()
   assert 'import anthropic' not in src and 'from anthropic' not in src, 'ANTHROPIC IMPORT LEAK'
   assert '_default_transport' not in src, 'STALE FUNCTION'
   # Verify default constructor uses claude_cli_transport:
   ex = ClaudeLLMPerspectiveAdapter()
   from packages.infrastructure.analysis.subagent_transport import claude_cli_transport
   assert ex.transport == claude_cli_transport, f'TRANSPORT NOT FLIPPED: {ex.transport}'
   print('OK: claude_llm_perspective_adapter has zero anthropic + transport flipped to claude_cli_transport')
   "
   ```
4. **Regression-floor smoke** (existing tests still pass):
   ```bash
   python -m pytest packages/infrastructure/analysis/test_adapter.py \
                    packages/infrastructure/analysis/perspectives/test_bear_agent.py \
                    packages/infrastructure/analysis/perspectives/test_quant_agent.py \
                    packages/infrastructure/analysis/test_synthesizer.py \
                    -q
   ```
   Expect: ALL existing tests PASS (regression floor); failure = STOP-AND-ASK CHARTER-TIER trigger (test signature surprise)
5. **Charter Principle 7 (Dogfood) satisfaction**: dev observation MUST record dogfood smoke + RolePromptPack registration + PersonaRegistry lookup + transport-flip empirical result

**STOP-AND-ASK trigger (TACTICAL-TIER)**:
- **(a) Determinism smoke fails** (RolePromptPack/PersonaRegistry outputs differ across runs) → write `human-workspace/notifications/STOP-FINDING-S375-roleprompt-non-deterministic.md` documenting which field differs + suspect cause; options: (a) lock random state, (b) defer YAML loader if json parse variance suspected (unlikely), (c) escalate
- **(b) Regression smoke fails** (existing test_adapter.py or test_bear_agent.py or test_quant_agent.py breaks) → write `human-workspace/notifications/STOP-FINDING-S375-regression-floor-break.md` with diagnostics; options: (a) inline-fix the test breakage (preferred if root cause clear), (b) revert transport-flip + ship RolePromptPack+PersonaRegistry only, (c) escalate
- **(c) Import grep-assert fails** (post-D3 `import anthropic` STILL present) → write `human-workspace/notifications/STOP-FINDING-S375-anthropic-import-leak.md` with line:col; options: (a) inline-fix removal, (b) D-052 § Implementation step 1 closure SHIPPED only on inline-fix (this is the entire purpose of F.1)

**Acceptance**: I-S34 grep clean + determinism smoke PASS + post-flip smoke PASS + regression smoke PASS (existing tests still green); ZERO `import anthropic` in claude_llm_perspective_adapter.py confirmed via post-D3 grep-assert

---

## D. Architecture Decisions (DD-1 through DD-9)

### DD-1: RolePromptPack contract shape = FROZEN DATACLASS (NOT Protocol + NOT ABC)

**Decision**: RolePromptPack is a `@dataclass(frozen=True, slots=True)` with 10 fields per master plan-033 DD-7 — NOT a Protocol, NOT an ABC.

```python
@dataclass(frozen=True, slots=True)
class RolePromptPack:
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
```

**Rationale**:
- Per master plan-033 DD-7 explicit rationale — RolePromptPack is data definition; matches existing domain value object precedent (GroundedPoint at grounded_point.py, Conviction at conviction.py, Recommendation enum); immutable + slotted for performance
- **NOT Protocol** — Protocol is for adapter contracts requiring duck-typed behavior conformance; RolePromptPack has no behavior methods (just data); typing.Protocol over-engineering
- **NOT ABC** — ABC implies subclass-based polymorphism (PersonaRegistry would lookup by subclass); data class with role_id key string is cleaner lookup pattern + matches ai-hedge-fund ANALYST_CONFIG dict precedent per master plan-033 § C.0.2 + DD-7 rationale
- **D-066 precedent (CrawlerAdapter ABC) ANALYZED + REJECTED** — D-066 chose ABC for CrawlerAdapter because CrawlerAdapter has crawler-source-specific behavior overrides per subclass (CafefAdapter, NDHAdapter, VietstockAdapter, VietnamBizAdapter); RolePromptPack has NO behavior overrides per persona — validator behavior lives in the per-persona adapter class per DD-4 HYBRID master plan-033 — different design problem, different solution

**Adversarial alternate considered**:
- (i) Protocol with `get_system_prompt()` + `get_validation_gate()` methods → REJECTED (over-abstraction for V0; data dict suffices; consumer adapter renders template by string substitution; validator behavior owned by adapter not RolePromptPack)
- (ii) ABC with abstract `_validate_output()` method → REJECTED (per DD-4 HYBRID rationale in master plan-033: per-persona validator lives in the adapter class, not in RolePromptPack data; mixing data + behavior violates SRP)
- (iii) TypedDict instead of dataclass → REJECTED (TypedDict doesn't enforce immutability + lacks __post_init__ validation hook for invariant enforcement)

### DD-2: PersonaRegistry mechanism = STDLIB DICT + JSON LOADER (no new dep; YAML deferred)

**Decision**: PersonaRegistry is a thin wrapper around `dict[str, RolePromptPack]` with these methods per master plan-033 DD-8:

```python
class PersonaRegistry:
    def __init__(self) -> None:
        self._packs: dict[str, RolePromptPack] = {}
    
    def register(self, pack: RolePromptPack) -> None:
        if pack.role_id in self._packs:
            raise ValueError(f"role_id {pack.role_id!r} already registered")
        self._packs[pack.role_id] = pack
    
    def get(self, role_id: str) -> RolePromptPack:
        if role_id not in self._packs:
            raise KeyError(f"role_id {role_id!r} not registered")
        return self._packs[role_id]
    
    def all_role_ids(self) -> tuple[str, ...]:
        return tuple(sorted(self._packs.keys()))
    
    def load_from_json(self, json_path: Path) -> None:
        # D-064 path-safety 5-invariant compliance per STEP 0.3
        ...
```

**Rationale**:
- **stdlib dict** = simplest possible registry; A-01 § 3 C2 ANALYST_CONFIG is also dict-typed; matches master plan-033 DD-8 exact pattern
- **JSON loader for V0** per DD-2 STEP 0.3 audit — pyproject.toml HAS NO pyyaml dep currently (architect VBW Grep confirmed); JSON loader uses stdlib `json` module (no new dep)
- **YAML deferred** per AP-7 named revisit trigger — if project-owner authors 3+ persona packs in JSON and reports friction (manual escaping of multi-line system_prompt_template strings), add pyyaml dep via separate sub-plan with explicit user ratification
- **Composition root pattern** — main.py / CLI entry points create PersonaRegistry instance + register all packs (or load from JSON directory); mirrors existing ClaudeLLMPerspectiveAdapter composition pattern at validate_thesis_phase1.py:153-171
- **all_role_ids() returns sorted tuple** for determinism (matches D-059 R2 unseeded RNG discipline; dict insertion order may vary across pyenv versions; sorted ensures stable output)
- **register() raises on duplicate role_id** (defensive; catches typo in persona-pack content authoring; alternative = silent overwrite was rejected per Karpathy P3 surgical-changes — fail-fast)

**Adversarial alternate considered**:
- (i) Auto-discovery via `pkgutil.walk_packages('role_packs')` — REJECTED (over-engineering for V0; explicit registry is clearer + testable; matches master plan-033 DD-8)
- (ii) Database table (SQLite) — REJECTED (premature optimization for V0; JSON/YAML files are git-versioned + human-editable)
- (iii) Pure-data module-load (e.g. `BUFFETT_PACK = RolePromptPack(...)` at module top-level) — REJECTED (cannot dynamically register new personas at composition root; harder to test in isolation; YAML/JSON loader is required for F.4 V0 expansion path)

### DD-3: RolePromptPack location = `packages/application/analysis/` package-root (NOT subdirectory)

**Decision**: RolePromptPack + PersonaRegistry live at `packages/application/analysis/role_prompt_pack.py` + `packages/application/analysis/persona_registry.py` (package root, parallel to existing ports/use_cases/services subdirectories).

**Rationale**: Per master plan-033 DD-6 verbatim:
- **They are NOT ports** — ports define infrastructure-adapter contracts; RolePromptPack is data-content (system prompt template strings + persona metadata); doesn't belong in `ports/` subdir
- **They are NOT use cases** — use cases orchestrate; RolePromptPack is consumed BY use cases; doesn't belong in `use_cases/` subdir
- **They are NOT services** — services are stateless logic; RolePromptPack is data definition; thin overlap but distinction = RolePromptPack ships immutable persona DEFINITIONS; services CONSUME RolePromptPack to derive behavior
- **Package-root parallels DDD tactical "factory" pattern** — `PersonaRegistry.get(role_id) → RolePromptPack` is factory-shape lookup
- **Precedent**: `packages/application/news/` has port + use_cases + commands + queries at package root level (analogous layout)

**Adversarial alternate considered**:
- (i) `packages/application/analysis/personas/role_prompt_pack.py` (new personas/ subdir) — REJECTED per master plan-033 DD-6 (over-folder-ing; only 2 files for V0 = subdir-overhead > clarity gain; if persona count balloons to N=10+ with N files, create personas/ subdir at F.4-V2 trigger)
- (ii) `packages/domain/analysis/value_objects/role_prompt_pack.py` (domain layer) — REJECTED per master plan-033 DD-6 (RolePromptPack is application-tier configuration data; domain layer is for invariants per I-S1 charter rule "domain layer has ZERO framework dependency" — application-tier is correct location)

### DD-4: BC-8 transport-flip strategy = REUSE existing claude_cli_transport from subagent_transport.py (NOT new factory file)

**Decision**: F.1 transport-flip ADOPTS existing `claude_cli_transport` function at `packages/infrastructure/analysis/subagent_transport.py:144-222` verbatim. F.1 does NOT author a new `claude_cli_perspective_transport.py` file (architect-refinement of master plan-033 dispatch brief which named such a file).

**Architect-refinement rationale**:
- **Per VBW empirical read at STEP 0.1**: `packages/infrastructure/analysis/subagent_transport.py` ALREADY ships `claude_cli_transport` with EXACT signature matching ClaudeLLMPerspectiveAdapter.transport field — `(model, system_prompt, user_message, temperature, role: str | None = None) → tuple[str, int, int]` matches 4-arg→3-tuple
- **Per D-052 § Implementation step 1 verbatim** (architect VBW read): "Set the dataclass `transport` default to `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC import)" — D-052 EXPLICITLY names `claude_cli_transport` from `subagent_transport.py` as the target; new file would diverge from D-052 spec
- **Karpathy P3 surgical-changes**: reusing existing file = ~0 LOC new in infrastructure layer; new file = ~150 LOC duplicating subagent_transport.py functionality (subprocess + JSON envelope + token aggregation + _unwrap_fence) — strict P3 violation
- **Karpathy P2 simplicity**: one transport function for BC-8 is simpler than two parallel functions; tests easier; cognitive load lower
- **BC-5 news has different signature** (`(system_prompt, body) → str` 2-arg→str at claude_cli_news_transport.py:96-156) — that's why BC-5 has its own transport file; BC-8 doesn't need a new file because subagent_transport.py already has the matching signature

**Adversarial alternate considered**:
- (i) Author new `packages/infrastructure/analysis/claude_cli_perspective_transport.py` mirroring claude_cli_news_transport.py shape — REJECTED per architect-refinement above (duplicates subagent_transport.py; D-052 spec says reuse existing)
- (ii) Move claude_cli_transport from subagent_transport.py to a new claude_cli_perspective_transport.py for naming consistency with BC-5 — REJECTED (file-rename churn; existing imports in tests would break; preserves NOTHING worth the cost)
- (iii) Sub-plan 034 ADDS a make_claude_cli_perspective_transport factory closure (similar to BC-5 pattern) wrapping claude_cli_transport — CONSIDERED + REJECTED (not needed; claude_cli_transport is already a top-level function reference usable directly as `field(default=claude_cli_transport)`; factory pattern only matters when caller needs to override model/timeout per dataclass attributes — BC-8 adapter resolves model via _ROLE_TO_MODEL at call time, not at construct time)

### DD-5: Transport default FLIPPED from _default_transport to claude_cli_transport (D-052 § Implementation step 1 FINAL closure)

**Decision**: REMOVE `_default_transport` function entirely from `claude_llm_perspective_adapter.py:73-98`. REMOVE `import anthropic` line at L80 (inside removed function body lazy-import). REMOVE `# type: ignore[import-not-found]` comment at L80. CHANGE `transport` field at L197-199 default from `field(default=_default_transport)` to `field(default=claude_cli_transport)`. ADD `from packages.infrastructure.analysis.subagent_transport import claude_cli_transport` import near top (after existing imports L25-34).

**Rationale**:
- Per D-052 § Implementation step 1 verbatim (ACCEPTED 2026-05-09 but code NOT applied per S369 verifier F3 finding): "`packages/infrastructure/analysis/claude_llm_perspective_adapter.py`: delete the `_default_transport` function (was a real anthropic SDK call, not a deprecation stub — D-050 only flipped the use_case_builder default). Set the dataclass `transport` default to `claude_cli_transport` from the same-BC sibling module `subagent_transport.py` (no cross-BC import)."
- Per L-S227-1 + plan-011 (line 83 + 240) — "0 `import anthropic` hits in `packages/` and `apps/` (excluding `tests/`)" — verifier S376 grep-asserts ZERO matches for BC-8 surface; BC-5 already at zero per D-072 closure
- Per D-050 SYSTEMIC + user memory rule `anthropic_api_to_subagent` (verbatim 2026-05-09) — every direct anthropic SDK call MUST refactor to subagent dispatch; THIS sub-plan closes the LAST REMAINING production-code instance
- D-052 spec compliance reaches 100% upon S375 dev commit (was 75% per S369 verifier F3 finding — step 1 outstanding; steps 2+3+4 already addressed per D-052 ADR text but step 1 code change NOT applied)
- Drop-in replacement confirmed at STEP 0.1 (subagent_transport.py:144-222 ALREADY shipped; signature matches)
- D-052 § Implementation step 3 (anthropic-dep removal from pyproject.toml) — separate cleanup ADR per scope-narrowing rationale; narrows scope risk of THIS sub-plan; transport flip + import removal is the SYSTEMIC rule satisfaction; dep removal is hygiene (RM-AS-2 carry-forward)

**Adversarial alternate considered**:
- (i) Keep `_default_transport` + add deprecation pointer + flip default at later sub-plan → REJECTED (delays D-052 spec compliance; D-052 is ACCEPTED CHARTER with explicit step 1 mandate; THIS sub-plan IS step 1 final execution)
- (ii) Use lambda wrapper `field(default_factory=lambda: claude_cli_transport)` instead of direct function reference → REJECTED (unnecessary indirection; claude_cli_transport is already a top-level function reference; direct assignment is cleaner)
- (iii) Block on D-052 § Implementation step 3 pyproject drop also in this sub-plan → REJECTED (scope creep; D-052 step 3 has separate verification surface; RM-AS-2 carry-forward documented)

### DD-6: Conviction enum preservation (NO numeric per-persona confidence)

**Decision**: Existing Conviction StrEnum STRONG/MODERATE/WEAK at `packages/domain/analysis/value_objects/conviction.py:17-22` UNCHANGED. RolePromptPack.conviction_guidance is text-only rubric (str field) — embeds per-persona guidance instructing LLM how to PICK categorical Conviction enum value (e.g. "STRONG = clear evidence across ≥3 distinct categories; MODERATE = mixed evidence; WEAK = single-category or uncertain").

**Rationale**:
- Per I-S1 (NO LLM math) + Rule 16 mode 1 categorical surrogate satisfaction
- Per master plan-033 DD-7 + § A.1 explicit: "Per-persona confidence is categorical via Conviction StrEnum (STRONG/MODERATE/WEAK)... satisfies Rule 16 mode 1; LLM never echoes numeric confidence (Buffett 90-100 rubric per ai-hedge-fund `warren_buffett.py:788-794` is REJECTED as I-S1-1 anti-pattern; we use the categorical surrogate path instead per Rule 16 mode 1)"
- LLM still emits Conviction categorical per existing PerspectiveAnalysis schema (UNCHANGED); LLM does NOT emit numeric confidence — RolePromptPack.conviction_guidance text instructs LLM to follow categorical discipline

**Adversarial alternate considered**:
- (i) Add `conviction_numeric_threshold: float` field to RolePromptPack for downstream weighted aggregation — REJECTED (violates I-S1-1 Rule 16 mode 1; per-persona numeric weighting is F.3 sub-plan scope via deterministic Phase1Synthesizer mapping NOT per-persona LLM emission)
- (ii) Replace Conviction StrEnum with `conviction_int: int` (0-100) field on PerspectiveAnalysis — REJECTED (Buffett 90-100 rubric anti-pattern per master plan-033 § A.1 explicit; would require I-S1-1 charter amendment)

### DD-7: RolePromptPack exact field shape (per master plan-033 DD-7)

**Decision**: RolePromptPack ships EXACTLY 10 fields per master plan-033 DD-7 (no extensions; no omissions):

| Field | Type | Purpose | Validation |
|---|---|---|---|
| `role_id` | `str` | Unique lookup key | Non-empty + `^[a-z][a-z0-9_]*$` regex (lowercase identifier) |
| `persona_name` | `str` | Human-readable name | Non-empty |
| `system_prompt_template` | `str` | LLM system prompt with placeholders | Non-empty + must contain `{TICKER}` placeholder |
| `conviction_guidance` | `str` | Rubric for picking Conviction | Non-empty |
| `citation_requirements` | `str` | Rule 6 grounding mandate | Non-empty |
| `vietnam_notes` | `str` | Per-persona VN context | May be empty (some personas may lack VN-specific notes) |
| `min_points` | `int` | Min key_points count | ≥1 |
| `min_distinct_categories` | `int` | Min distinct GroundedPoint.category | ≥1 and ≤ len(category_universe) |
| `category_universe` | `tuple[str, ...]` | Allowed category values | Non-empty tuple of unique strings |
| `model_id_preference` | `str \| None` | Per-persona model override | None OR one of `{claude-sonnet-4-6, claude-opus-4-7, claude-haiku-4-5}` |

**Placeholder convention**: `{TICKER}` + `{AS_OF}` (matches existing BEAR/BULL/QUANT SYSTEM_PROMPT pattern at bear_agent.py:42-44). Per-persona adapter renders template by string substitution at call time (not at registration time).

**Rationale**:
- Per master plan-033 DD-7 EXACT shape — no architect re-design at sub-plan level (master plan ratified)
- 10 fields cover the full V0 surface (lookup + display + LLM prompt + per-persona discipline + per-persona model routing)
- Frozen dataclass invariants enforced via __post_init__ — early failure on malformed registration prevents downstream LLM dispatch errors

**Adversarial alternate considered**:
- (i) Add `version: str` field for per-pack version tracking — DEFERRED (per § A.3 OOS — version tracking is hygiene; if PersonaRegistry hot-reload introduced, add then)
- (ii) Add `tags: tuple[str, ...]` field for cross-persona grouping (e.g. "value", "tail-risk") — DEFERRED (per AP-7 named revisit trigger; add if F.4 V0 expansion surfaces grouping need)
- (iii) Make `category_universe` a frozenset instead of tuple — REJECTED (tuple preserves order for display + matches existing GroundedPoint.category practice; frozenset loses ordering)

### DD-8: ADR D-074 PROPOSED-AT-IMPL — BC-8 Transport Flip + RolePromptPack + PersonaRegistry Foundation

**Decision**: D5 sub-track ships `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` at IMPL tier (per severity-schema auto-ratifies on commit; D-074 next ADR slot after D-073):

ADR records:
- (a) D-052 § Implementation step 1 FINAL closure attestation — BC-8 perspective-adapter transport-flipped; D-052 spec compliance 100% (was 75% per S369 verifier F3 finding)
- (b) RolePromptPack contract shape per DD-7 (10-field frozen dataclass)
- (c) PersonaRegistry pattern per DD-2 (stdlib dict + JSON loader; YAML deferred per AP-7 named revisit trigger)
- (d) D-052 chain attestation: D-050 SYSTEMIC → D-051 BC-5 transport → D-052 § step 1 BC-8 transport (THIS sub-plan) → D-072 BC-5 default-flip (S368)
- (e) Revisit triggers (per AP-7 anti-vacuous-defer): (1) claude CLI substrate unavailable in production, (2) YAML adoption trigger (3+ personas + JSON friction), (3) PersonaRegistry hot-reload trigger
- (f) Files modified + D-052 § Implementation step 3 (pyproject drop) carry-forward as RM-AS-2

**Rationale**:
- Per Karpathy P3 surgical-changes — ADR D-074 records the foundation decision + transport-flip rationale in one place; future readers see the chain D-050 → D-052 → D-072 → D-074 → (V0=6 ratification when applicable)
- Per AP-7 anti-vacuous-defer — explicit revisit triggers named for each risk
- Per severity-schema — IMPL tier auto-ratifies on commit; main session commits this sub-plan's IMPL output
- D-074 cites master plan-033 DD-7 + DD-8 + DD-5 + § N.4 Phase E DONE attestation

### DD-9: Existing subagent_transport.py UNCHANGED (already-shipped infrastructure)

**Decision**: NO modification to `packages/infrastructure/analysis/subagent_transport.py`. THIS sub-plan ADOPTS the `claude_cli_transport` function verbatim. Verifier reads READ-ONLY at S376.

**Rationale**:
- File already-shipped per D-052 § Implementation step 1 reference; architect VBW Read confirmed 222 LOC + claude_cli_transport at L144-222 + SubagentSubstrateError at L67 + _unwrap_fence + _extract_first_json_object helpers
- Signature match confirmed: 4-arg `(model, system_prompt, user_message, temperature, role)` → 3-tuple `(text, in_tok, out_tok)` matches existing `ClaudeLLMPerspectiveAdapter.transport` field 4-arg→3-tuple signature
- Per Karpathy P3 surgical-changes — touch only what task requires; subagent_transport.py ALREADY satisfies the SYSTEMIC rule for BC-8 surface; no modification needed
- If transport-flip surfaces an unanticipated bug at subagent_transport.py path (e.g. claude CLI subprocess fails on macOS-only flag), STOP-FINDING-S375-subagent-transport-bug.md fires; bug fix is SEPARATE sub-plan scope (this sub-plan is consumer not provider of transport)

**Adversarial alternate considered**:
- (i) Inline the claude_cli_transport logic into claude_llm_perspective_adapter.py → REJECTED (violates separation of concerns; transport file exists for this exact reason per D-052 + D-050 architecture)

---
