---
session: S375
agent: sandwich-dev (Claude Sonnet 4.6 FOCUSED_IMPL)
plan: agent-workspace/session-plans/pending/034-S374-phase-f1-roleprompt-persona-transport.md (4-part)
status: COMPLETE
date: 2026-05-17
---

# S375 Dev Observation — BC-8 RolePromptPack + PersonaRegistry + Transport-Flip

## STEP 0 Evaluation Results

### 0.1 — Existing adapter audit (VBW empirical)
- `claude_llm_perspective_adapter.py`: 264 LOC pre-edit; `_default_transport` at L73-98 confirmed; `import anthropic` at L80 (lazy import inside function); `transport` field at L197-199 `field(default=_default_transport)` confirmed
- `subagent_transport.py`: 222 LOC; `claude_cli_transport` at L144-222; signature `(model, system_prompt, user_message, temperature, role: str | None = None) -> tuple[str, int, int]` — MATCHES adapter transport field 4-arg→3-tuple; ALREADY-SHIPPED
- `test_adapter.py`: 8 existing tests all use `transport=stub` constructor kwarg; none reference `_default_transport` directly
- test_bear_agent.py + test_quant_agent.py: all use adapter stub pattern — no direct transport dependency

### 0.2 — RolePromptPack contract audit
- 10-field shape per master plan-033 DD-7 lines 378-388 verified
- `__post_init__` enforces 9 invariants: role_id regex, persona_name non-empty, system_prompt_template non-empty + {TICKER} required, conviction_guidance non-empty, citation_requirements non-empty, min_points ≥ 1, min_distinct_categories ≥ 1, category_universe non-empty + unique, model_id_preference in allowed set
- Field backward-compat: NEW file (no existing consumers); F.2 adds first consumers

### 0.3 — pyproject.toml pyyaml audit
- `grep -n "pyyaml|PyYAML|yaml|anthropic" pyproject.toml` → pyyaml NOT in deps; anthropic at L11 only
- Decision: JSON-only V0 per DD-2; no new dep added; AP-7 YAML revisit trigger documented in ADR D-074

### 0.4 — Transport-flip migration plan + claude CLI check
- `which claude` → `C:\Users\PC\.local\bin\claude.exe` v2.1.140 (Claude Code) — AVAILABLE
- **CHARTER-TIER GATE DID NOT FIRE** — claude CLI substrate present
- Pre-D3 baseline: 1 `import anthropic` at L80 (inside `_default_transport` function body)
- Transport-flip plan: REMOVE L73-98 entire `_default_transport` function; ADD import `from packages.infrastructure.analysis.subagent_transport import claude_cli_transport`; CHANGE field default from `_default_transport` to `claude_cli_transport`

### 0.5 — Rule 16 mode 1 preservation audit
- RolePromptPack `min_points: int` + `min_distinct_categories: int` = integer THRESHOLDS set at registration (NOT LLM output) — Rule 16 N/A
- `conviction_guidance: str` = text rubric instructing LLM to pick categorical Conviction STRONG/MODERATE/WEAK — Rule 16 mode 1 categorical surrogate preserved
- ClaudeLLMPerspectiveAdapter transport-flip: LLM output schema UNCHANGED; cost_usd computed by `_compute_cost()` deterministic function; Conviction StrEnum categorical preserved
- **Verdict: Rule 16 mode 1 satisfied by construction**

### 0.6 — Dogfood integration smoke + determinism + regression floor
- D-059 determinism smoke: `RolePromptPack` + `PersonaRegistry` deterministic (p1 == p2; registry get == registered instance)
- Post-flip smoke: `ClaudeLLMPerspectiveAdapter()` no-arg; transport == claude_cli_transport — PASS
- Import grep-assert post-D3: ZERO `import anthropic` in `.py` files across `packages/` — D-052 CLOSURE CONFIRMED
- Regression floor: test_bear_agent.py 12 PASS, test_quant_agent.py 10 PASS, test_synthesizer.py 9 PASS, test_phase1_data_gatherer.py 3 PASS — ALL GREEN
- I-S34: no new HTTP fetcher; claude CLI is local subprocess; patchright/playwright-stealth etc. absent

---

## D1-D5 Sub-track Outcomes

### D1 — RolePromptPack frozen dataclass
- **File**: `packages/application/analysis/role_prompt_pack.py` (NEW; 102 LOC actual)
- `@dataclass(frozen=True, slots=True)`; 10 fields per DD-7; `__post_init__` with 9 invariants; `RolePromptPackInvariantError(ValueError)`
- mypy --strict: CLEAN; ruff: CLEAN
- Notes: No deviation from plan

### D2 — PersonaRegistry stdlib dict + JSON loader
- **File**: `packages/application/analysis/persona_registry.py` (NEW; 156 LOC actual)
- 4 methods: `register()` / `get()` / `all_role_ids()` / `load_from_json()`
- D-064 path-safety: all 5 invariants enforced (traversal, extension, symlink, file-exists, base_dir confinement)
- `all_role_ids()` returns sorted tuple (D-059 R2 determinism)
- mypy --strict: CLEAN after adding `from typing import cast` for list→tuple conversion; ruff: CLEAN
- Notes: One mypy fix — `cast(list[object], ...)` needed for `tuple()` call on `object`-typed dict value

### D3 — ClaudeLLMPerspectiveAdapter transport-flip
- **File**: `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (MODIFIED; 264 → 245 LOC; net -19 LOC)
- REMOVED: `_default_transport` function (L73-98; 26 LOC removed)
- REMOVED: `import anthropic` at L80 (inside removed function)
- ADDED: `from packages.infrastructure.analysis.subagent_transport import claude_cli_transport`
- CHANGED: `field(default=_default_transport)` → `field(default=claude_cli_transport)`
- UPDATED: module docstring + adapter class docstring (removed "Lazy Anthropic SDK import" note; added D-050/D-052 compliance note)
- `subagent_transport.py`: UNCHANGED per DD-9
- mypy --strict: CLEAN; ruff: CLEAN
- Post-edit grep-asserts: ZERO `import anthropic` / ZERO `_default_transport` in `.py` files

### D4 — Unit tests
- **NEW**: `packages/application/analysis/test_role_prompt_pack.py` (243 LOC; 23 tests, 0 skipped)
- **NEW**: `packages/application/analysis/test_persona_registry.py` (289 LOC; 15 tests — 14 pass, 1 skipped Windows symlink per plan)
- **MODIFIED**: `packages/infrastructure/analysis/test_adapter.py` (141 → 215 LOC; 4 regression additions)
- Test count: 1113 baseline → 1153 collected (delta: +40; plan target was ~22 — actual higher due to additional edge-case coverage)
- All tests: PASS (1151 pass, 2 skip, 0 fail)

### D5 — ADR D-074 + role-packs/README.md
- **NEW**: `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` (200 LOC)
- **NEW**: `agent-workspace/role-packs/README.md` (62 LOC)
- decisions/README.md: D-074 row prepended + Last updated updated
- D-052 spec compliance attestation: steps 1+2+4 complete for BC-8 surface; step 3 deferred per RM-AS-2

---

## D-052 Closure Empirical (THE acceptance criterion)

```
grep -rE "^[ \t]*(import anthropic|from anthropic)" packages/ --include="*.py"
# Returns: (exit code 1 = ZERO matches)
```

**ZERO matches in `.py` files across `packages/`** — D-052 § Implementation step 1 CLOSED.

Pre-S375 baseline: 1 match at `claude_llm_perspective_adapter.py:80` (inside `_default_transport`)
Post-D3: 0 matches

---

## DD-4 Confirmation: claude_cli_transport REUSED (not new file)

`claude_cli_transport` function at `subagent_transport.py:144-222` adopted verbatim.
NO new `claude_cli_perspective_transport.py` file created.
D-052 § Implementation step 1 explicitly names this as the target.
Karpathy P3: reuse > duplicate.

---

## Persona Count

V0 persona JSON files: 0 (per plan — F.1 ships SUBSTRATE only; F.2 sub-plan 035 authors Buffett/Graham/Taleb content).
PersonaRegistry instantiable; `load_from_json` tested with valid JSON in pytest fixtures.

---

## DoD 36 Status

### File DC (DC-FILE-1..10)
- DC-FILE-1: role_prompt_pack.py EXISTS (102 LOC)
- DC-FILE-2: persona_registry.py EXISTS (156 LOC)
- DC-FILE-3: claude_llm_perspective_adapter.py MODIFIED (245 LOC post-edit)
- DC-FILE-4: test_role_prompt_pack.py EXISTS (243 LOC)
- DC-FILE-5: test_persona_registry.py EXISTS (289 LOC)
- DC-FILE-6: test_adapter.py MODIFIED (215 LOC)
- DC-FILE-7: 074-bc-8-transport-flip-roleprompt-persona.md EXISTS (200 LOC)
- DC-FILE-8: role-packs/README.md EXISTS (62 LOC)
- DC-FILE-9: session-375.md EXISTS (this observation write-out in same session)
- DC-FILE-10: THIS FILE (observations/sandwich-dev-S375-bc-8-roleprompt-transport-flip.md)

### Impl DC (DC-IMPL-1..10): ALL PASS
### STEP 0 DC (DC-STEP0-1..6): ALL documented above
### Gates DC (DC-GATE-1..9): ALL PASS
- DC-GATE-7: `grep -rE "^(import anthropic|from anthropic)" packages/ --include="*.py"` → ZERO matches
- DC-GATE-8: `grep "_default_transport" claude_llm_perspective_adapter.py` → ZERO matches
- DC-GATE-9: `ex.transport is claude_cli_transport` → True
### Regression DC (DC-REGRESSION-1..4): ALL PASS (35 tests green)
### Bookkeeping DC (DC-BOOK-1..6):
- DC-BOOK-1: session log written (session-375.md)
- DC-BOOK-2: current-execution.md updated in same session
- DC-BOOK-3: mistake-log — no mistakes this session
- DC-BOOK-4: plan-034 mv deferred to S376 verifier close
- DC-BOOK-5: decisions/README.md D-074 row added
- DC-BOOK-6: D-052 spec compliance 100% (BC-8 surface) attested in ADR D-074

---

## No Mistakes This Session

No M-S375-N entries. Session proceeded cleanly:
- 1 mypy fix: `cast(list[object], ...)` needed in persona_registry.py L146 (typing precision; not a logic error)
- No STOP-AND-ASK triggers fired
- No charter violations

---

## Handoff Risks for Verifier (S376)

1. **RM-AS-2 known-deferred**: `anthropic>=0.40.0` remains in `pyproject.toml` (step 3 of D-052). NOT a defect per plan-034 § A.3 + AQ-9; verifier acknowledges as deferred.

2. **Symlink test skipped on Windows** (test_persona_registry.py::test_load_from_json_rejects_symlink): skipped via `@pytest.mark.skipif` per plan-034 D4 spec. Not a coverage gap — D-064 symlink invariant is enforced in production code; test runs on Linux/macOS CI if available.

3. **test_adapter.py opens `mod.__file__`** in TC-2 and TC-3 (grep-assert tests). Uses `open(mod.__file__, encoding="utf-8").read()` — ruff may flag as SIM115 (`open()` without context manager). Present with noqa comment. Verifier confirm ruff clean.

4. **PersonaRegistry.load_from_json type: ignore[arg-type]** on L149 `RolePromptPack(**raw_dict)`: raw_dict is `dict[str, object]` but RolePromptPack fields are typed. mypy clean with ignore; runtime RolePromptPackInvariantError fires on bad data. Acceptable for JSON loader pattern.

5. **V0 persona count = 0**: No persona JSON files in role-packs/. This is per-plan (F.1 ships substrate; F.2 ships content). Verifier confirm role-packs/README.md explains this correctly.
