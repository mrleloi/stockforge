
## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why FROZEN DATACLASS for RolePromptPack not Protocol or ABC?

**Answer**: Per DD-1 + master plan-033 DD-7. RolePromptPack is data not behavior; Protocol is for adapter contracts requiring duck-typed behavior conformance (over-engineering); ABC implies subclass-based polymorphism (validator behavior owned by per-persona adapter class per DD-4 HYBRID); frozen dataclass + slots gives immutability + performance + matches existing domain value object precedent.

### AQ-2 — Why REUSE existing claude_cli_transport from subagent_transport.py not author new claude_cli_perspective_transport.py?

**Answer**: Per DD-4 architect-refinement of master plan-033 dispatch brief. STEP 0.1 VBW confirmed subagent_transport.claude_cli_transport ALREADY ships with EXACT matching signature (4-arg→3-tuple); D-052 § Implementation step 1 EXPLICITLY names this function as the target ("from the same-BC sibling module `subagent_transport.py` (no cross-BC import)"); authoring new file = Karpathy P3 violation + duplicates 150 LOC; reuse is the correct path. BC-5 has its own transport file because BC-5 signature DIFFERS (2-arg→str).

### AQ-3 — Why JSON LOADER not YAML LOADER in V0?

**Answer**: Per DD-2 + STEP 0.3. pyproject.toml audit (architect Grep) confirmed pyyaml NOT in dependencies. JSON loader uses stdlib `json` module (no new dep + no user ratification gate). YAML is cosmetic vs JSON; per Karpathy P2 simplicity + AP-7 named revisit trigger — add pyyaml if project-owner authors 3+ packs in JSON and reports friction.

### AQ-4 — Why DEFAULT TRANSPORT FLIPPED in this sub-plan vs separate harness sub-plan?

**Answer**: Per DD-5 + master plan-033 DD-5 + D-052 § Implementation step 1 EXPLICIT mandate (ACCEPTED 2026-05-09 but code NOT applied per S369 verifier F3 finding). THIS sub-plan IS the residual closure. Touching claude_llm_perspective_adapter.py twice (once for RolePromptPack consumer wiring later, once for transport flip now) = unnecessary churn; bundling = single coherent commit; THIS sub-plan closes the D-052 step 1 outstanding for 8 sessions (S370-S374 elapsed since ACCEPTED). Per Karpathy P3 — touch only what task requires, but if a touch is happening anyway, complete the residual.

### AQ-5 — Why DI graceful-degradation NOT required for PersonaRegistry?

**Answer**: PersonaRegistry has NO default state at construction (`__init__` starts with empty dict); explicit `register(pack)` calls populate at composition root. Unlike ClaudeLLMPerspectiveAdapter which has 3 fields with defaults (transport, model_override, role_model_overrides), PersonaRegistry has zero defaults — composition root MUST explicitly populate. Failure mode = `get(role_id)` raises KeyError with informative message listing registered role_ids; not silent default-fallback.

### AQ-6 — STEP 0.4 finds claude CLI substrate UNAVAILABLE — what then?

**Answer**: Per STEP 0.4 STOP-AND-ASK trigger (CHARTER-TIER). Write STOP-FINDING-S375-claude-cli-substrate-unavailable.md with 3 options: (a) install claude CLI in dev env then resume, (b) defer transport-flip to separate sub-plan + ship RolePromptPack+PersonaRegistry only, (c) retain anthropic SDK as default + escalate to CHARTER-TIER reversal of D-050 SYSTEMIC (HIGHLY UNLIKELY). Default architect-judgement: if claude CLI unavailable, ship RolePromptPack+PersonaRegistry (D1+D2+D4+D5) + flag D3 transport-flip as deferred-to-next-sub-plan (do NOT block all of F.1; RolePromptPack+PersonaRegistry are independently valuable).

### AQ-7 — What if S375 dev IMPL exceeds 150K Opus FOCUSED_IMPL ceiling?

**Answer**: Sub-plan 034 budget projection 105-160K typical per § A.4. If S375 dev empirically exceeds ceiling at ~130K with D4+D5 remaining, SPLIT trigger: dispatch fresh-context S375-bis covering only D5 (ADR D-074 + role-packs/README.md) + bookkeeping. NEVER mix PLAN+IMPL in split-recovery session. Estimated split point = after D3 transport-flip commits (D4 + D5 parallel-eligible per § E so can ship in separate ~30K session). Plan-034 PLAN authors with explicit SPLIT_TRIGGER clause in DoD floor: "MAY_SPLIT_IF_>130K_AT_D3_COMPLETE".

### AQ-8 — What if STEP 0.5 detects RolePromptPack non-determinism or PersonaRegistry race?

**Answer**: Per STEP 0.6 STOP-AND-ASK trigger (a). Write STOP-FINDING-S375-roleprompt-non-deterministic.md documenting which field differs + suspect cause. Default architect-judgement: RolePromptPack frozen+slots dataclass is deterministic by construction; PersonaRegistry stdlib dict insertion order is stable per Python 3.7+; if smoke fails, likely cause = test fixture using set() somewhere → fix inline.

### AQ-9 — Why NOT drop anthropic from pyproject.toml in this sub-plan (D-052 § Implementation step 3 deferral)?

**Answer**: Per § A.3 deferral + RM-AS-2 + D-052 § Implementation step 3 has its own verification surface (whole-repo grep + CI confirm-no-anthropic-imports + importlinter forbidden_modules update). Scope-narrowing — THIS sub-plan accomplishes D-052 § Implementation step 1 + step 4 satisfaction (zero `import anthropic` in BC-8 surface + regression test); dep-removal is hygiene (cleanup) with its own ADR scope. Separate D-052-V2 cleanup ADR is cleaner per AP-7 anti-vacuous-defer + Karpathy P3.

### AQ-10 — What if S376 verifier finds existing test_bear_agent or test_quant_agent break due to default transport change?

**Answer**: Per DD-5 + STEP 0.1 pre-check mitigation. Existing test_bear_agent.py + test_quant_agent.py use `transport=stub` constructor kwarg per architect VBW (Glob confirmed file exists; pattern matches test_adapter.py:24-33 _make_stub_transport). Explicit kwarg ALWAYS overrides default. If verifier finds breakage, root cause = test-fixture missing stub-transport OR test-fixture using `_default_transport` directly (forbidden import; would have been flagged at mypy/grep at DC-GATE-7). Default mitigation per RM2: dev fixes inline; if breakage extensive, fallback to keeping `_default_transport` as deprecation pointer + flip default to claude_cli_transport anyway (back-compat preserves tests; rule-compliance for default-path achieved).

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (parent master plan) | Source 2 (precedent sub-plan / D-072 ADR / S369 F3 finding) | Source 3 (charter invariant / Rule) | Source 4 (existing stockforge code precedent) | Source 5 (external pattern / memory rule / ai-hedge-fund A-01) |
|---|---|---|---|---|---|---|
| 1 | DD-1 RolePromptPack FROZEN DATACLASS (not Protocol/ABC) | master plan-033 DD-7 (lines 376-396) — explicit `@dataclass(frozen=True, slots=True)` mandate + 10-field shape | sub-plan 031 DD-3 ExtractedClaim NEW fields pattern (frozen+slots dataclass with __post_init__ validation; sub-plan 031 § D DD-3 lines 422-446) | I-S1 (NO LLM math) — RolePromptPack ships data not behavior; LLM-output schema unchanged + Rule 16 mode 1 categorical preservation | `packages/domain/analysis/value_objects/grounded_point.py:51-71` (existing frozen+slots dataclass with __post_init__) + `packages/domain/analysis/value_objects/conviction.py:17-22` (StrEnum precedent) | ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict (per A-01 § 3 C2 plugin-registry pattern) — DATA-DRIVEN persona definition (pattern-port not code-port per A-01 § 6 LICENSE caveat) |
| 2 | DD-2 PersonaRegistry STDLIB DICT + JSON LOADER | master plan-033 DD-8 (lines 400-416) — explicit stdlib dict + YAML loader + composition-root pattern; JSON fallback IF pyyaml absent | sub-plan 031 DD-7 EXISTING `claude_cli_news_transport.py` UNCHANGED (lines 583-595) — pattern of consuming already-shipped helper unchanged | Charter "user prompt overrides ALL defaults" + Karpathy P2 simplicity + AP-7 anti-vacuous-defer | `packages/infrastructure/news/sqlite_news_repository.py` (existing stdlib repository pattern; not dict but illustrates application-tier composition-root pattern) | ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict — direct precedent for stdlib dict registry |
| 3 | DD-5 BC-8 transport-flip default to claude_cli_transport (D-052 § Implementation step 1 final closure) | master plan-033 DD-5 (lines 344-358) — mirror D-072 strategy; D-052 § Implementation step 1 final execution | **S369 verifier F3 finding** (per dispatch brief) — D-052 ACCEPTED 2026-05-09 but step 1 NOT APPLIED (analysis adapter STILL has `import anthropic` at L80); plan-034 IS the residual closure + sub-plan 031 DD-2 BC-5 precedent | I-S1 + Charter Principle 9 (no LLM math) + `anthropic_api_to_subagent` memory-rule (per CLAUDE.md user memory; subscription-billing-not-API-metered) + L-S227-1 (NO ANTHROPIC_API_KEY in production code) | `packages/infrastructure/analysis/subagent_transport.py:144-222` (`claude_cli_transport` function ALREADY SHIPPED with matching 4-arg→3-tuple signature; D-052 explicit target) + `packages/infrastructure/news/claude_llm_extractor.py` (D-072 default-flip precedent shipped S368) | claude CLI invocation via subprocess.run pattern (BP-S43b-1/2/3 per architecture.md:142-154) |
| 4 | DD-7 RolePromptPack EXACT 10-field shape | master plan-033 DD-7 (lines 378-388) — verbatim 10-field shape | sub-plan 031 DD-3 NEW fields surgical addition pattern (`lexicon_score: float = 0.0` + `mentioned_pump_anchors: tuple[str, ...]` field-add with __post_init__ validation; sub-plan 031 D1) | I-S1 + Rule 16 mode 1 categorical surrogate (RolePromptPack fields are integer thresholds not LLM-emitted numeric) + I-S2 citation discipline (citation_requirements field embeds Rule 6 mandate) | `packages/infrastructure/analysis/perspectives/bear_agent.py:41-77` (SYSTEM_PROMPT format reference for system_prompt_template field; placeholder `{TICKER}` + `{AS_OF}` convention) + `packages/domain/analysis/models/perspective_analysis.py:30-39` (PerspectiveRole 6-value StrEnum — F.2 personas extend via RolePromptPack role_id string per DD-7) | ai-hedge-fund `src/agents/warren_buffett.py:13-16` Pydantic signal contract (REJECTED for direct port per LICENSE caveat; pattern-port reference for field shape design only) |
| 5 | DD-9 EXISTING subagent_transport.py UNCHANGED | master plan-033 DD-5 (lines 344-358) — adopt verbatim per D-052 explicit | sub-plan 031 DD-7 SAME pattern for BC-5 claude_cli_news_transport.py UNCHANGED (sub-plan 031 § D DD-7 lines 583-595) | Karpathy P3 surgical-changes + Cross-BC discipline (same-BC import only per D-052 § Implementation step 1 explicit "no cross-BC import") | `packages/infrastructure/analysis/subagent_transport.py:144-222` (ALREADY shipped 222 LOC; signature matches; consumed verbatim) | claude CLI substrate pattern documented at S43b probe `research/r-2026-05-01-claude-cli-substrate.md` (per subagent_transport.py module docstring L7-10) |

---

## I. STEP 0 STOP-AND-ASK trigger inventory (5 documented; 1 CHARTER-TIER + 3 TACTICAL-TIER + 1 BLOCKING)

| Trigger ID | Sub-step | Condition | STOP-FINDING file path | User decision class |
|---|---|---|---|---|
| **(a) CHARTER-TIER GATE — claude CLI substrate unavailable** | 0.4 | `which claude` returns nothing OR `claude --version` fails in S375 dev env | `human-workspace/notifications/STOP-FINDING-S375-claude-cli-substrate-unavailable.md` | CHARTER-TIER (install / defer transport-flip / reverse D-050 SYSTEMIC) |
| **(b) TACTICAL-TIER — RolePromptPack/PersonaRegistry non-determinism** | 0.6 | Smoke output differs across 2 runs with same input | `human-workspace/notifications/STOP-FINDING-S375-roleprompt-non-deterministic.md` | TACTICAL-TIER (lock random state / inline-fix / escalate) |
| **(c) TACTICAL-TIER — regression-floor breakage** | 0.6 | Existing test_adapter.py OR test_bear_agent.py OR test_quant_agent.py breaks post-D3 | `human-workspace/notifications/STOP-FINDING-S375-regression-floor-break.md` | TACTICAL-TIER (inline-fix / revert transport-flip / escalate) |
| **(d) BLOCKING — import grep-assert fails** | 0.6 | Post-D3 `import anthropic` STILL present in claude_llm_perspective_adapter.py | `human-workspace/notifications/STOP-FINDING-S375-anthropic-import-leak.md` | BLOCKING (inline-fix removal mandatory; this IS the purpose of F.1) |
| **(e) TACTICAL-TIER — SPLIT trigger budget overrun** | post-D3 commit | S375 dev exceeds 130K Opus with D4+D5 remaining | inline session log only (no STOP-FINDING file) | TACTICAL (SPLIT to S375-bis fresh-context for D4+D5+bookkeeping; documented in plan-034 AQ-7) |

**Dispatch brief implicit triggers**: master plan-033 § K.2 sub-plan 034 anticipated 2 FLAGS — (i) pyyaml dep gap (handled at STEP 0.3 architect-decision JSON fallback; NOT a runtime trigger), (ii) BC-8 transport-flip regression risk (becomes trigger (c) regression-floor break + trigger (d) import grep-assert). **Architect adds** triggers (a) CHARTER-TIER + (b) determinism + (e) SPLIT per AP-7 anti-vacuous-defer + Karpathy P1 think-before-coding (surface all failure modes upfront).

---

## J. Risks & Mitigation (RM1-RM10)

### RM1 — Cold-start budget over/under-estimation (LIKELY-MEDIUM; mitigated by nearest-analog n=3)

**Risk**: Phase 1b COLD-START on `multi-perspective-impl` task_class; nearest-analog `vietnamese-nlp-impl` n=3 (S362+S365+S368 ~155K Sonnet each) provides directional but not precise budget bounds; S375 dev may finish under 105K Opus OR exceed 160K (e.g. STEP 0 STOP-AND-ASK adds 10-30K depending on which triggers fire).

**Mitigation**: Full 100-150K Opus envelope honored per recalibrated CLAUDE.md table; sub-plans 035-038 inherit growing precedent (n=0 → n=1 → n=2 → n=3 → n=4 for multi-perspective-impl). Worst case: STOP-AND-ASK budget consumed → re-dispatch S375 dev after user gate clears + SPLIT per AQ-7 IF ceiling exceeded mid-IMPL.

### RM2 — RolePromptPack/PersonaRegistry first-instance design defect (LIKELY-LOW)

**Risk**: First production use of data-driven persona pattern; DD-7 EXACT shape may surface field-shape gap discovered only when F.2 sub-plan ships per-persona content (e.g. need version field for hot-reload).

**Mitigation**: Per DD-7 — 10 fields cover full V0 surface per master plan-033 architect rationale; if gap surfaces in F.2, plan-034 amended via supersession ADR per AP-7. AP-23 first-instance HOLD applied — second-recurrence in sub-plans 035-038 triggers promote-to-skill calculus.

### RM3 — BC-8 transport-flip regression in test_bear_agent/test_quant_agent (LIKELY-LOW; mitigated by stub-injection pattern)

**Risk**: D3 transport-flip touches default-path for ALL existing perspective adapter consumers; test_bear_agent.py + test_quant_agent.py + test_synthesizer.py rely on adapter behavior; regression possible.

**Mitigation**: Per DD-5 + DD-9 — existing tests use `transport=stub` constructor kwarg pattern (verified at STEP 0.1); explicit kwarg overrides default; tests should pass unchanged. Verifier S376 confirms via DC-REGRESSION-1/2/3 (pytest exit 0 on all 4 perspective test files). If breakage detected, STOP-AND-ASK trigger (c) fires + inline-fix.

### RM-AS-2 — D-052 § Implementation step 3 pyproject drop carry-forward (LIKELY-EXPECTED; LIKELY-LOW concern)

**Risk**: D-052 enumerated 4 implementation steps; THIS sub-plan executes step 1 (transport flip) + step 4 (regression test) for BC-8 surface; step 3 (anthropic-dep drop from pyproject.toml) NOT executed; user may consider this incomplete D-052 compliance.

**Mitigation**: Per AQ-9 + § A.3 — scope-narrowing rationale; D-052-V2 cleanup ADR scope explicitly separate; this sub-plan satisfies D-052 step 1 + step 4 SYSTEMIC rule for IMPORT path (zero `import anthropic` in BC-8); dep removal is hygiene with its own verification surface. Verifier S376 acknowledges D-052 step 3 still deferred; not a defect of this sub-plan.

### RM5 — Charter-tier surface mid-flight (LIKELY-LOW; mitigated by § K + NON-BLOCKING design)

**Risk**: Sub-plan 034 IMPL may surface a charter-tier issue (e.g. per-persona LLM emits buy/sell prose bypassing Recommendation enum → I-S35 violation; OR per-persona confidence rubric surfaces I-S1-1 Rule 16 mode-tripwire).

**Mitigation**: § K Charter-tier-surface section + master plan-033 § K verdict — F.1 surface has NO CHARTER-TIER FLAGS (ships data + transport-flip not new LLM-output schema); STEP 0 STOP-AND-ASK clauses cover unanticipated FLAGS; main session dispatches AskUserQuestion gate per CLAUDE.md hard rule.

### RM6 — Catastrophic mix pattern (CRITICAL-LOW; mitigated by sub-plan structure)

**Risk**: Bundling D1-D5 + their tests + ADR into single MULTI-TASK IMPL = potential Session 4 catastrophic failure mode.

**Mitigation**: 5 sub-tracks with disjoint file scopes + parallel-eligible pairs (D2+D3, D4+D5); FOCUSED_IMPL envelope respected; SPLIT trigger AQ-7 documented for >130K mid-IMPL. Sub-plan 034 IS the right granularity per master plan-033 DD-1.

### RM7 — Plan ratification ambiguity if main session dispatches sub-plan 035 in parallel (LIKELY-LOW)

**Risk**: Master plan-033 § E.1 declares sub-plan 035 BLOCKS_ON 034; if main session prematurely dispatches sub-plan 035 author before 034 verifier PASS, F.2 personas may consume incomplete RolePromptPack contract.

**Mitigation**: Per master plan-033 § E sequencing + § N.2 — 034 sequential before 035; main session orchestrates via plan-025 DD-5 + dispatch.jsonl coordination; sub-plan 035 STEP 0 verifies RolePromptPack shape at S377 entry (cannot proceed if D-074 PROPOSED missing).

### RM8 — PersonaRegistry concurrent-modification race (LIKELY-VERY-LOW)

**Risk**: PersonaRegistry.register() called from multiple composition roots concurrently could race; JSON loader at startup could partial-read.

**Mitigation**: Per DD-2 — PersonaRegistry.register() is composition-root pattern (called once at startup before any LLM dispatch); not designed for runtime mutation; JSON loader uses stdlib json.loads (atomic read into memory before parse); read-only post-registration.

### RM9 — pyproject.toml audit miss (LIKELY-VERY-LOW)

**Risk**: STEP 0.3 might miss pyyaml in a different toml section (e.g. dev-dependencies or optional-dependencies); JSON loader ships unnecessarily; YAML loader would have been viable.

**Mitigation**: STEP 0.3 grep MUST cover full pyproject.toml not just main dependencies block; architect VBW confirmed only `anthropic>=0.40.0` at L11 + `anthropic` at L169 (test importlinter forbidden_modules); no pyyaml anywhere. If pyyaml DOES exist in dev-dependencies, that doesn't affect production dep surface but architect-recommended JSON loader still applies (consistent with V0 simplicity).

### RM10 — D-066 ABC precedent mis-application (LIKELY-LOW)

**Risk**: Verifier (sandwich-verifier fresh-context) may flag DD-1 dataclass choice as architecturally inconsistent with D-066 CrawlerAdapter ABC pattern; "why dataclass for personas but ABC for crawlers?"

**Mitigation**: DD-1 rationale documents D-066 INFORMATIONAL-not-binding precedent — different design problem (CrawlerAdapter has per-source behavior overrides; RolePromptPack has NO per-persona behavior overrides); ABC vs dataclass is right tool for each job per DDD tactical patterns; master plan-033 DD-7 explicit on this rationale.

---

## K. Coordination paths off-limits (during S375 dev session window)

When main session dispatches S375 dev sub-plan IMPL, main session SHOULD avoid (read-only or no-touch) the following paths to prevent file-collision:

- `packages/application/analysis/role_prompt_pack.py` (D1 dev writes)
- `packages/application/analysis/persona_registry.py` (D2 dev writes)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (D3 dev modifies)
- `packages/application/analysis/test_role_prompt_pack.py` (D4 dev writes)
- `packages/application/analysis/test_persona_registry.py` (D4 dev writes)
- `packages/infrastructure/analysis/test_adapter.py` (D4 dev modifies)
- `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` (D5 ADR writes)
- `agent-workspace/role-packs/README.md` (D5 placeholder writes)
- `agent-workspace/memory/sessions/2026-05-XX-session-375.md` (dev session log)
- `agent-workspace/memory/observations/sandwich-dev-S375-bc-8-roleprompt-transport-flip.md` (dev observation)
- `human-workspace/notifications/STOP-FINDING-S375-*.md` (CONDITIONAL dev writes IF STOP-AND-ASK fires)

When main session dispatches S376 verifier (AP-1 fresh-context post-S375 dev close), main session SHOULD avoid:

- `agent-workspace/memory/observations/sandwich-verifier-S376-bc-8-roleprompt-transport-flip-verify.md` (verifier writes)

Coordination paths NOT touched by THIS sub-plan (READ-ONLY guarantee):
- `packages/infrastructure/analysis/subagent_transport.py` (already-shipped per DD-9; verifier reads READ-ONLY)
- `packages/infrastructure/analysis/perspectives/bear_agent.py` (READ-ONLY; F.2 sub-plan modifies if needed)
- `packages/infrastructure/analysis/perspectives/bull_agent.py` + `quant_agent.py` (READ-ONLY)
- `packages/infrastructure/analysis/perspectives/test_bear_agent.py` + `test_quant_agent.py` (READ-ONLY; regression-floor surface; DC-REGRESSION-1/2/3 verifies pass)
- `packages/infrastructure/analysis/test_synthesizer.py` + `test_phase1_data_gatherer.py` (READ-ONLY; DC-REGRESSION-3/4)
- `packages/domain/analysis/**` (READ-ONLY; F.1 does NOT modify domain layer)
- `packages/application/analysis/ports/llm_perspective_port.py` (READ-ONLY; port signature unchanged; F.3 may extend)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (READ-ONLY; F.3 sub-plan extends)
- `pyproject.toml` (NO dep changes per RM-AS-2 + AQ-9; D-052-V2 separate scope)
- `agent-workspace/constitution/**` (READ-ONLY per hard rules)

---

## L. Conditional next-step (post-user-ratification of CHARTER-TIER GATE IF applicable)

### L.1 IF STEP 0.4 CHARTER-TIER GATE did NOT fire (most likely path)

- S375 dev proceeds STEP 0 → D1 → D2 + D3 (parallel) → D4 + D5 (parallel) → close
- S376 verifier AP-1 dispatch
- S376 close: plan-034 mv `pending/` → `completed/`
- S376+ main session dispatches sub-plan 035 architect (F.2 first 3 personas) per master plan-033 § E sequencing
- POSSIBLE PARALLEL POST-S376: sub-plan 035 architect dispatched fresh-context per AP-1; Phase G-prime master-plan author may dispatch in parallel per master plan-033 § N.2

### L.2 IF STEP 0.4 CHARTER-TIER GATE FIRED (claude CLI substrate unavailable)

- S375 dev pauses at STEP 0.4 STOP-AND-ASK
- Main session dispatches AskUserQuestion gate → user picks (a) install / (b) defer transport-flip / (c) reverse D-050
- IF (a): dev resumes STEP 0 → D1-D5 standard path
- IF (b): dev skips transport-flip (D3 partial); ships RolePromptPack + PersonaRegistry + ADR D-074 only (D1+D2+D4-partial+D5-modified); D-052 § Implementation step 1 closure deferred to separate sub-plan
- IF (c): MAJOR architectural rollback; dev pauses entire sub-plan + separate ADR drafted to supersede D-050 partially; sub-plan 034 may be entirely re-scoped

### L.3 IF STEP 0.6 TACTICAL-TIER (c) FIRED (regression-floor break)

- S375 dev pauses at STEP 0.6 STOP-AND-ASK
- Applies architect-recommended default per AQ-10 — inline-fix the test breakage (root cause likely test-fixture stub-transport pattern)
- If inline-fix unclear → defer transport-flip (D3 partial revert) + ship RolePromptPack + PersonaRegistry only
- Records outcome in dev observation + STOP-FINDING file

### L.4 IF STEP 0.6 BLOCKING (d) FIRED (import grep-assert fails post-D3)

- S375 dev MUST inline-fix immediately (this IS the entire purpose of F.1)
- Re-run STEP 0.6 grep until ZERO matches confirmed
- If 3 retries fail → emergency escalate to main session for architect-tier ratification

### L.5 IF AQ-7 SPLIT TRIGGER fires (>130K Opus mid-IMPL)

- S375 dev commits D1+D2+D3 (transport-flip closure is highest-priority)
- Dispatch fresh-context S375-bis sandwich-dev for D4+D5+bookkeeping (~30K envelope)
- Sub-plan 034 NOT marked complete until S375-bis verified at S376

---

## M. CHARTER-TIER GATE clause (canonical reference for sub-plan 034 anticipated flags)

> **MANDATORY STEP 0 STOP-AND-ASK on Claude CLI Substrate Availability** (per dispatch brief flag + AQ-6 + STEP 0.4 trigger): If `which claude` returns nothing OR `claude --version` fails in S375 dev env, S375 dev MUST:
> 1. STOP at STEP 0.4 conclusion (D3 IMPL block on transport-flip portion)
> 2. Write `human-workspace/notifications/STOP-FINDING-S375-claude-cli-substrate-unavailable.md`
> 3. Continue with RolePromptPack + PersonaRegistry only path (D1 + D2 + D4-partial + D5-modified) AS-IF Phase A separate; flag D-052 § Implementation step 1 closure as deferred
> 4. OR pause entire sub-plan pending user gate ratification (architect-judgement: prefer (3) ship RolePromptPack+PersonaRegistry partial; D-052 § step 1 closure cycle restartable)
> 5. Record user pick (if received) in ADR D-074 § Authorization field
> 6. Proceed per § L.2 depending on user pick

> **NON-BLOCKING — pyyaml dep gap** (master plan-033 § K.2 anticipated FLAG): NON-BLOCKING per architect-decision at STEP 0.3; JSON loader ships for V0; pyyaml deferred per AP-7 named revisit trigger; NO STOP-AND-ASK fires for this FLAG.

> **NON-BLOCKING — BC-8 transport-flip regression risk** (master plan-033 § K.2 anticipated FLAG): NON-BLOCKING per architect-judgement at STEP 0.1 verified stub-injection pattern at test_adapter.py:24-33; if regression actually fires, STOP-AND-ASK trigger (c) at STEP 0.6 activates; main session ratifies inline-fix path.

> DO NOT silently retain anthropic SDK as default per D-050 SYSTEMIC + D-052 § Implementation step 1. DO NOT silently leave _default_transport function in production code. DO NOT proceed without grep-assert ZERO `import anthropic` post-D3 (BLOCKING per trigger (d)).

---

## N. D-052 cleanup completion attestation contract (per dispatch brief item 7 + master plan-033 § N.2)

### N.1 D-052 spec compliance audit (pre-S375 → post-S375)

| D-052 § Implementation step | Target | Status pre-S375 (S369 verifier F3 finding) | Status post-S375 dev commit |
|---|---|---|---|
| **1** | Delete `_default_transport` + `import anthropic` from `claude_llm_perspective_adapter.py` + set transport default to `claude_cli_transport` from `subagent_transport.py` | **NOT APPLIED** (S369 verifier F3 finding; analysis adapter STILL has `import anthropic` at L80; `_default_transport` function still present L73-98; transport field default L197-199 still `field(default=_default_transport)`) | **APPLIED via this plan-034 D3** — verifier S376 grep-asserts ZERO `import anthropic` + ZERO `_default_transport` references + transport == claude_cli_transport |
| **2** | Delete `_default_transport` stub from `claude_llm_extractor.py` | APPLIED (D-051 / D-072 shipped 2026-05-09 / S368) | APPLIED (UNCHANGED this plan) |
| **3** | Remove `anthropic>=0.40.0` from `pyproject.toml` dependencies | **NOT APPLIED** (still at L11 per architect VBW Grep) | **DEFERRED per RM-AS-2** (separate D-052-V2 cleanup ADR scope; named revisit trigger documented) |
| **4** | Replace NotImplementedError-deprecation test with regression test asserting (a) `_default_transport` symbol gone (b) no anthropic import | APPLIED for BC-5 (D-051/D-072); **NOT APPLIED for BC-8** | **APPLIED for BC-8 via this plan-034 D4** — `test_no_anthropic_import_in_module_source` + `test_default_transport_function_removed_from_module` regression tests added to test_adapter.py |

### N.2 D-052 spec compliance percentage (BC-8 surface)

- **Pre-S375**: 50% (steps 2+4 partially applied for BC-5 only; BC-8 surface = 0/2 = 0%)
- **Post-S375 dev commit**: 75% for full D-052 (steps 1+2+4 complete; step 3 deferred) → **100% for BC-8 surface specifically** (steps 1+4 complete for BC-8; steps 2+3 are BC-5+repo-wide scope)
- **D-052-V2 trigger**: step 3 pyproject drop + importlinter forbidden_modules update; estimated separate ~30K Opus PLAN+IMPL+VERIFY cycle in next harness hygiene sweep

### N.3 Phase F-prime sub-plan dispatch sequencing post-S376

Per master plan-033 § E + § N.2 sequencing:

| Plan | Type | Target session | parallel_with | blocks_on | Status post-S376 verifier PASS |
|---|---|---|---|---|---|
| 034 (F.1 RolePromptPack + transport-flip) — THIS PLAN | PLAN+IMPL+VERIFY | S374/S375/S376 | [] | [] | **READY** for S376 close + mv to completed/ |
| 035 (F.2 First 3 personas Buffett/Graham/Taleb) | PLAN+IMPL+VERIFY | S376/S377/S378 (sequential after 034 verify) | [] | [034] | UNBLOCKED post-S376 |
| 036 (F.3 N-persona use case extension) | PLAN+IMPL+VERIFY | S378/S379-S380/S381 (sequential after 035 verify) | [] | [034, 035] | BLOCKED on 035 |
| 037 (F.4 V0 expansion to V0=9 IF ratified) | PLAN+IMPL+VERIFY (or NO-OP) | S381/S382-S383/S384 (parallel with 038) | [038] | [034, 035, 036] | BLOCKED on 036 |
| 038 (F.5 CLI dogfood) | PLAN+IMPL+VERIFY | S384/S385/S386 (parallel with 037) | [037] | [034, 035, 036] | BLOCKED on 036 |

### N.4 Phase F-prime → G-prime parallel opportunity (master plan-033 § N.2)

After sub-plan 034 VERIFY ships at S376, main session MAY dispatch Phase G-prime master-plan author (BC-2 PDF + table extraction) in parallel with Phase F-prime sub-plan 035 PLAN authoring per plan-025 DD-5 architect-tier parallel-dispatch precedent. G-prime authoring is independent file scope; no contention with Phase F-prime.

---

## O. Compliance attestation (architect S374 PLAN-authoring session)

- [x] harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; L-S354-2 + L-S366-4 + L-S369-1 planner-stats infrastructure gap noted in Phase 1b § A.4 carry-forward; explicitly NOT fixed here per § hard_rules)
- [x] AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- [x] AP-5 ✓ (re-read all binding sources at session entry per VBW protocol — 35 files cited in § A.4 — covering parent master plan-033 + precedent sub-plan 031 + ADR D-050 + D-052 + D-072 + user memory rule + existing perspective adapter + subagent_transport + bear_agent + perspective_analysis + conviction + LLMPerspectivePort + claude_cli_news_transport + spec 004 + spec 006 + master plan + supplement + ai-hedge-fund deep-dive + architecture.md BC-8 + financial-data-protocol Rule 16 + pyproject.toml audit + agent template)
- [x] AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; 14 OOS items each with revisit trigger)
- [x] AP-23 ✓ (no refinement-of-rule iterations this session; any new patterns surfaced get first-instance HOLD per binding_decisions; e.g. RolePromptPack data-driven persona pattern at DD-1 is NEW first-instance; PersonaRegistry stdlib dict pattern at DD-2 is NEW first-instance; if 2nd instance arises in sub-plans 035-038, promote calculus triggers)
- [x] autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- [x] dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session dispatches S375 dev per master plan-033 § N.2 sequencing — no self-pause)
- [x] stop_offering_routing_branches ✓ (§ L next-step is conditional branching documentation NOT user-action menu)
- [x] D-060 ✓ (architect has no Bash tool; main session commits this sub-plan + observation per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- [x] D-052 honored + ADVANCED — THIS plan CLOSES D-052 § Implementation step 1 outstanding for BC-8 surface per DD-5 + DD-8 + § N attestation; D-052 spec compliance reaches 100% for BC-8 upon S375 dev commit (was 0% per S369 verifier F3 finding)
- [x] D-072 honored — BC-5 transport-flip MIRROR adopted exactly per DD-5; same pattern shape for BC-8
- [x] D-066 acknowledged INFORMATIONAL not binding per DD-1 + RM10 — different design problem (per-source behavior overrides) vs RolePromptPack (no per-persona behavior overrides)
- [x] D-070 + D-071 acknowledged — Phase E Theme I DONE; F.1 does NOT touch Phase E files
- [x] memory rule `anthropic_api_to_subagent` honored — IMPLEMENTED for BC-8 perspective-adapter path per DD-5; ZERO new `import anthropic` introduced; default transport flipped per SYSTEMIC mandate
- [x] 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- [x] 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- [x] 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is dev-S375 conditional write not architect-S374 write)
- [x] 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- [x] I-S1 ✓ (this plan PRESERVES I-S1 satisfaction — RolePromptPack ships data not LLM-output schema; Conviction StrEnum categorical preserved per DD-6)
- [x] I-S1-1 + Rule 16 mode 1 ✓ (RolePromptPack fields all non-numeric-LLM-emission; LLM-output schema UNCHANGED)
- [x] I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain)
- [x] I-S34 ✓ (STEP 0.6 enforces HARD REJECT carry-forward; no new HTTP fetcher this sub-plan; claude CLI is local subprocess)
- [x] I-S35 ✓ (F.1 ships data + transport-flip; output framing unchanged; existing Recommendation enum preserved)
- [x] Phase 1b CONSUMED + COLD-START DECLARED for task_class="multi-perspective-impl" + nearest-analog vietnamese-nlp-impl n=3 honored per § A.4 (per agent-template L65 + plan-025 DD-11 mandate)
- [x] 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- [x] CHARTER-TIER GATE clause documented per § M (1 CHARTER-TIER trigger + 2 NON-BLOCKING flags + 1 BLOCKING trigger)
- [x] D1-D5 sub-tracks declare 4 mandatory fields (parallel_with / blocks_on / coordination_paths_exclusive / estimated_wall_min) per plan-025 contract
- [x] Recalibrated PLAN budget per CLAUDE.md table (150-230K Opus PLAN) — this dispatch validates 4th opportunity per M-S360-2 ratification
- [x] D-052 § Implementation step 1 final closure path documented per § N attestation contract — main session ratifies via S375 dev commit + S376 verifier PASS

---

**END OF SUB-PLAN 034-S374-PHASE-F1-ROLEPROMPT-PERSONA-TRANSPORT**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S375 sandwich-dev FOCUSED_IMPL per master plan-033 § N.2 sequencing post-ratification of THIS sub-plan.
