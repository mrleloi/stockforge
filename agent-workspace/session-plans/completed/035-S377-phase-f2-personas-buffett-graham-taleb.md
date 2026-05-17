---
plan_id: 035-S377-phase-f2-personas-buffett-graham-taleb
target_session: S378 (dev IMPL session; THIS plan = S377 architect output)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S377; IMPL by sandwich-dev at S378; VERIFY by sandwich-verifier AP-1 at S379)
budget:
  - this PLAN session (S377 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (Phase 1b NARROW per n=1 multi-perspective-impl precedent S375)
  - sub-plan IMPL (S378 dev): ~100-150K Opus FOCUSED_IMPL per recalibrated table
  - sub-plan VERIFY (S379 verifier): ~30-60K Opus AP-1 fresh-context
phase: F-prime (Theme H — BC-8 Multi-Perspective Primitives; sub-theme F.2 first 3 personas BUFFETT + GRAHAM + TALEB — SECOND of 5 sub-tracks per master plan-033 § E sequencing)
track: Wave 1 Theme H sub-theme F.2 — First 3 persona-pack content + per-persona adapter classes (CONSUMES F.1 substrate: RolePromptPack + PersonaRegistry + transport-flip; preserves backward compat with existing BEAR/BULL/QUANT pipeline)
parent_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (PHASE-MASTER-PLAN authored S373; THIS is the second sub-plan per § E.2 + § N.2 sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.3 + § 6.4.3
predecessor: 034-S374-phase-f1-roleprompt-persona-transport (F.1 SHIPPED S375 + verified S376; D-074 ACCEPTED; D-052 § Implementation step 1 closed for BC-8 surface; THIS sub-plan satisfies § E.2 contract per DD-4 HYBRID RolePromptPack + per-persona adapter class shape)
successor: S379 sandwich-verifier AP-1 → sub-plan 036 (F.3 N-perspective use case extension) at S378+ per master plan-033 § E sequencing (036 blocks_on 035; sequential ship)
architect: S377 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase F-prime second sub-plan author per master plan-033 § E.2 + § N.2 sequencing
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED variant with NARROW PRECEDENT declared for task_class="multi-perspective-impl" — n=1 from S375 IMPL precedent only; narrow window for adapter+test_buffett/graham/taleb pattern proven against bear_agent.py D-054 retry-validator shape; novel portion = per-persona prompt template authoring + per-persona category_universe definition + Vietnam-relevance notes content + PerspectiveRole StrEnum extension OR role_id-routing decision in DD-1)
executing_agent: N/A this PLAN session; S378 sandwich-dev FOCUSED_IMPL (after this sub-plan ratified) + S379 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master plan-033 § E.2 sub-plan contract (BUFFETT + GRAHAM + TALEB persona pack content + per-persona adapter class + per-persona role-pack JSON + per-persona tests + ≥15 unit tests floor)"
  - "Master plan-033 § E.2 BLOCKS sub-plans 036/037/038 — F.2 personas are content/adapter prerequisites"
  - "D-074 ACCEPTED 2026-05-17 (BC-8 Transport Flip + RolePromptPack + PersonaRegistry SHIPPED S375 + verified S376; F.1 substrate consumed by THIS sub-plan)"
  - "D-052 ACCEPTED 2026-05-09 (anthropic SDK code-path removal — § Implementation step 1 CLOSED for BC-8 per D-074 plan-034 ship at S375; THIS sub-plan inherits the closed state — ZERO new `import anthropic`)"
  - "D-050 ACCEPTED 2026-05-09 CHARTER (anthropic→subagent SYSTEMIC; per CLAUDE.md user memory `anthropic_api_to_subagent`)"
  - "D-053 ACCEPTED (perspective adapter A2 retry-validator SHIPPED via BullPerspectiveAgent S? + cited at bull_agent.py)"
  - "D-054 ACCEPTED (retry-validator mirror for BEAR; max 3 attempts; re-prompt with error; cumulative cost; validation-exhausted WARNING — REFERENCE PATTERN for THIS sub-plan's 3 new personas)"
  - "D-059 (Python determinism contract — R1+R2+R4) BINDING for every NEW/MODIFIED file"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S378 dev commit boundary"
  - "D-062 (atomic-write-doctrine) — N/A this sub-plan (3 persona JSON files written ONCE at IMPL; no hot-reload)"
  - "D-064 (path-safety 5-invariant) — APPLIES via PersonaRegistry.load_from_json from F.1 substrate; persona JSON loading paths must respect"
  - "D-065 Rule 16 (numeric-field discipline) — BINDING; THIS sub-plan adds ZERO new LLM-emitted numeric fields; per-persona conviction_guidance text rubric enforces Rule 16 mode 1 categorical surrogate"
  - "D-066 (CrawlerAdapter ABC PROPOSED) — INFORMATIONAL precedent; THIS sub-plan does NOT introduce ABC for persona agents (DD-3 below = NO shared base class; duplicate per-persona class per Karpathy P3)"
  - "Charter v1.1 Principle 3 (Adversarial by Design — multi-perspective IS the moat) + Principle 7 (Dogfood) + Principle 8 (Calibration over confidence — V0 ships UNCALIBRATED per persona) + Principle 9 (NO LLM math — per-persona LLM emits ONLY categorical Conviction + reasoning + GroundedPoint tuple) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — F.2 ships per-persona prompt content; LLM-output path UNCHANGED (existing PerspectiveAnalysis schema); satisfied by construction"
  - "I-S1-1 + Rule 16 mode 1 (categorical surrogate via Conviction StrEnum STRONG/MODERATE/WEAK) — per-persona conviction_guidance text rubric INSTRUCTS LLM to pick categorical (NOT numeric 0-100 rubric per A-01 § 3 C9 Buffett confidence — REJECTED)"
  - "I-S2 (citation discipline) — each persona's citation_requirements text field embeds Rule 6 verbatim mandate (source_url + source_excerpt ≤500 chars)"
  - "I-S10 (bear case substantive ≥3 distinct evidence-grounded points across ≥3 distinct categories) — BEAR-specific; NOT directly applicable to BUFFETT/GRAHAM/TALEB but the structural shape ≥min_points across ≥min_distinct_categories is OPERATIONALIZED via per-persona RolePromptPack fields (min_points + min_distinct_categories + category_universe)"
  - "I-S11 (multi-perspective synthesis ≥2 minimum; ≥4 for high-confidence) — F.2 adds 3 new personas; combined with existing BEAR/BULL/QUANT = 6 personas registered; F.3 sub-plan generalizes use-case to consume N≥4"
  - "I-S22 (data lineage) — PerspectiveAnalysis.prompt_hash already records sha256[:16] per existing claude_llm_perspective_adapter.py; F.2 per-persona adapters preserve audit trail"
  - "I-S34 (HARD REJECT) — N/A this sub-plan (no new HTTP fetcher; claude CLI is local subprocess; VBW step 0.4 grep-asserts)"
  - "I-S35 (research-aid framing) — F.2 ships per-persona prompts that EXPLICITLY frame output as 'thesis exploration' NOT 'buy/sell' (DD-5 conviction_guidance pattern enforces; charter STOP-AND-ASK trigger if any persona prompt drafts surface buy/sell prose)"
  - "anthropic_api_to_subagent memory rule (user verbatim 2026-05-09; D-050 ACCEPTED CHARTER tier) — INHERITED CLOSED for BC-8 via D-074; THIS sub-plan introduces ZERO new `import anthropic`"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter pattern — per-persona agents are Adapter implementations of LLMPerspectivePort)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline; per-role timeout via _ROLE_TIMEOUT_OVERRIDES at subagent_transport.py:160)"

binding_decisions:
  - "PHASE 1b CONSUMED + NARROW PRECEDENT for task_class='multi-perspective-impl' — n=1 from S375 (F.1 IMPL ship; clean cycle per current-execution.md S375 row); novel portion = per-persona prompt template authoring + Vietnam-relevance notes content + per-persona category_universe definition (sub-component first-instance); directional confidence MEDIUM at n=1"
  - "DD-1 PERSPECTIVEROLE STRENUM EXTENDED with 3 new values (BUFFETT='buffett' + GRAHAM='graham' + TALEB='taleb') — NOT role_id-only routing; chosen for type-safety + existing PerspectiveRole signature consistency at validate_thesis_phase1.py + perspective_analysis.py + tests"
  - "DD-2 PER-PERSONA FILE NAMING CONVENTION = `<role_id>_agent.py` (buffett_agent.py + graham_agent.py + taleb_agent.py) parallel to existing bear_agent.py + bull_agent.py + quant_agent.py at packages/infrastructure/analysis/perspectives/ — Karpathy P3 surgical-changes + match existing convention"
  - "DD-3 SHARED BASE CLASS = NO (duplicate per-persona class per Karpathy P3; ABC/Mixin first-instance HOLD per AP-23) — 3 personas worth of duplication is acceptable; promote-to-shared trigger when ≥4 personas need refactor (V0=9 path or beyond)"
  - "DD-4 PER-PERSONA CATEGORY_UNIVERSE = persona-distinct lists per RolePromptPack DD-7 invariant 'min_distinct_categories ≤ len(category_universe)' — Buffett: {MOAT, MANAGEMENT, VALUATION, ROIC, BALANCE_SHEET, GROWTH} / Graham: {EARNINGS_STABILITY, BALANCE_SHEET_STRENGTH, DIVIDEND_RECORD, MARGIN_OF_SAFETY, NCAV, GRAHAM_NUMBER} / Taleb: {FRAGILITY, CONVEXITY, SKIN_IN_GAME, TAIL_RISK, VOLATILITY_REGIME, ANTIFRAGILITY}"
  - "DD-5 PER-PERSONA CONVICTION_GUIDANCE = explicit Rule 16 mode 1 categorical rubric — EXPLICITLY NO 90-100/70-89 numeric rubric per A-01 § 3 C9 REJECTION; LLM picks STRONG/MODERATE/WEAK categorical per spec criteria; ai-hedge-fund pattern PORTED not copied verbatim (LICENSE caveat A-01 § 6)"
  - "DD-6 PER-PERSONA VIETNAM_NOTES = persona-specific VN-market application — Buffett: VinGroup conglomerate moat + Vietnam consumer brand value (Vinamilk-class) / Graham: VN banking sector NCAV applicability + VN real estate balance-sheet complexity / Taleb: F0 retail-dominated market tail-risk + 'đội lái' pump-cluster fragility + USD/VND volatility regime"
  - "DD-7 MODEL_ID_PREFERENCE = claude-sonnet-4-6 for ALL 3 personas (Buffett + Graham + Taleb) per master plan-033 DD-12 cost-routing (value-investor reasoning ≠ Opus-class computational reasoning; QUANT remains only Opus persona); RolePromptPack.model_id_preference field set to 'claude-sonnet-4-6' explicitly (NOT None default — leaves auditable override trail)"
  - "DD-8 PER-PERSONA RETRY-VALIDATOR = MIRROR D-054 BearPerspectiveAgent shape exactly (3 attempts + re-prompt with validation error + cumulative cost + validation-exhausted WARNING + empty PerspectiveAnalysis on triple-fail; NOT silent) — per-persona _validate_<persona>_output enforces (a) valid JSON parse, (b) key_points list non-empty, (c) per-point category+as_of+text fields, (d) ≥min_points distinct categories from per-persona category_universe per RolePromptPack constraints"
  - "DD-9 EXISTING TEST PATTERN PARITY — each test_<persona>_agent.py mirrors test_bear_agent.py structure (12 test cases minimum; happy-path + retry-validator + invalid-JSON + missing-fields + insufficient-categories + LLM-exception); test naming TC-<role_id>-N per existing convention"
  - "DD-10 PERSONA JSON CONTENT AUTHORING = PATTERN-PORT NOT CODE-PORT per A-01 § 6 LICENSE caveat — architect READS ai-hedge-fund warren_buffett.py + ben_graham.py + nassim_taleb.py for design INSPIRATION ONLY; ZERO verbatim copy of LangChain template strings, Pydantic class definitions, or function bodies; LLM prompts AUTHORED FRESH from persona principles per existing bear_agent.py:41-77 inline-SYSTEM_PROMPT pattern adapted to per-persona content"
  - "DD-11 ADR D-075 PROPOSED-AT-IMPL — 'BC-8 First 3 Personality-Pack Adapters (Buffett/Graham/Taleb)' — records (a) PerspectiveRole enum extension + (b) per-persona file structure + (c) per-persona category_universe + (d) Vietnam-relevance evidence chain + (e) pattern-port-not-code-port LICENSE attestation"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names prerequisites + revisit trigger"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (per-persona JSON content authoring; per-persona category_universe definition); 2nd recurrence in sub-plans 037 V0=9 triggers promote-to-shared-base-class calculus"
  - "Karpathy P3 surgical-changes — this sub-plan adds ~450-550 LOC across 7 files (3 agents + 3 tests + 3 JSON + 1 ADR + 1 README append) within envelope"
  - "VBW protocol mandatory — S378 dev MUST READ bear_agent.py + bull_agent.py + role_prompt_pack.py + persona_registry.py + test_bear_agent.py + claude_llm_perspective_adapter.py + ai-hedge-fund warren_buffett.py + ben_graham.py + nassim_taleb.py + role-packs/README.md empirically"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; main commits per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S378-* is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire in S378 dev session NOT this S377 PLAN session)"
  - "no touching Phase E files — all 4 sub-themes shipped + verified"
  - "no Phase F sub-theme F.3/F.4/F.5 work in THIS sub-plan — separate sub-plans 036/037/038"
  - "no charter amendment SHIP from THIS plan"
  - "no anthropic SDK reintroduction — D-074 ACCEPTED CLOSED state for BC-8 surface preserved"
  - "no LangChain / LangGraph adoption — VBW per master plan-033 § A.3 deferral + A-01 § 7 R1 anti-pattern (LangChain wholesale dependency); per-persona adapters use existing claude_cli_transport from subagent_transport.py directly per F.1 substrate"
  - "no Pydantic per-persona signal class — LLM outputs JSON parsed via stdlib json (existing bear_agent.py:158-194 _validate_bear_output pattern) NOT Pydantic; Pydantic in interfaces layer only per architecture constraint"
  - "no per-persona historical hit-rate calibration — V0 ships UNCALIBRATED per master plan-033 § A.3 deferral + Charter Principle 8 (per-persona calibration is post-MVP with n≥50 thesis outcomes per persona threshold)"
  - "no harness/hook changes — this plan ships product persona content"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.4 grep-asserts no new HTTP fetcher"
  - "ai-hedge-fund LICENSE-file caveat A-01 § 6 ACKNOWLEDGED — pattern-port not code-port mandate enforced; per-persona JSON content AUTHORED FRESH from documented principles; ZERO verbatim string copy"
  - "If STEP 0 surfaces a charter-tier need (e.g. persona prompt drafts surface buy/sell prose despite I-S35; OR per-persona conviction_guidance surfaces numeric 90-100 rubric despite Rule 16 mode 1), FLAG in § M for main session AskUserQuestion ratification gate dispatch — NOT silent fix"
---

# S377 — Phase F.2 First 3 Persona-Pack Adapters (Buffett / Graham / Taleb) sub-plan (SECOND sub-plan of Phase F-prime)

> **One-sentence intent**: AUTHOR per-persona adapter classes + JSON content for the first 3 Vietnam-relevant personality-pack personas — (a) NEW `packages/infrastructure/analysis/perspectives/buffett_agent.py` (`BuffettPerspectiveAgent` mirroring `BearPerspectiveAgent` D-054 retry-validator shape with persona-specific `_validate_buffett_output` enforcing min_points/min_distinct_categories via the RolePromptPack instance) + (b) NEW `packages/infrastructure/analysis/perspectives/graham_agent.py` (`GrahamPerspectiveAgent` same shape) + (c) NEW `packages/infrastructure/analysis/perspectives/taleb_agent.py` (`TalebPerspectiveAgent` same shape) + (d) NEW `agent-workspace/role-packs/buffett.json` + `graham.json` + `taleb.json` (10-field RolePromptPack content with Vietnam-relevance notes per DD-6 + Rule 16 mode 1 conviction_guidance per DD-5) + (e) NEW per-persona test files (12+ TC each mirroring `test_bear_agent.py` shape) + (f) EXTEND `packages/domain/analysis/models/perspective_analysis.py` PerspectiveRole StrEnum to add `BUFFETT='buffett'` + `GRAHAM='graham'` + `TALEB='taleb'` values per DD-1 + (g) NEW `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` ADR PROPOSED at IMPL tier — without breaking existing `test_adapter.py` + `test_bear_agent.py` + `test_bull_agent.py` + `test_quant_agent.py` + `test_synthesizer.py` regression floor (composition root for new personas left UNWIRED in `validate_thesis_phase1.py` — F.3 sub-plan handles N-perspective dispatch; F.2 ships REGISTERED via PersonaRegistry only), without LLM-emitting per-persona numeric confidence (I-S1 + Rule 16 mode 1 categorical Conviction StrEnum), and without LangChain/LangGraph/Pydantic-per-persona-signal-class adoption (master plan-033 § A.3 deferrals).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent master plan-033 § E.2 + sub-plan-035 dispatch brief)

Ship the **first 3 Vietnam-relevant personality-pack persona adapters** that:

- **Consume RolePromptPack data primitives** from F.1 substrate (`packages/application/analysis/role_prompt_pack.py` 10-field frozen dataclass + `packages/application/analysis/persona_registry.py` stdlib dict + JSON loader) for per-persona configuration — the RolePromptPack instance is passed to the per-persona adapter constructor + read for `system_prompt_template` (with `{TICKER}` + `{AS_OF}` substitution per existing bear_agent.py:224 pattern) + `min_points` + `min_distinct_categories` + `category_universe` (all enforced by `_validate_<persona>_output` retry-validator gate)
- **Mirror D-054 BearPerspectiveAgent retry-validator pattern exactly** at `packages/infrastructure/analysis/perspectives/bear_agent.py:198-334` — `BuffettPerspectiveAgent` + `GrahamPerspectiveAgent` + `TalebPerspectiveAgent` each have `__init__(adapter, role_pack)` + `async def analyze(ticker, context, role)` + `async def _analyze_with_retry(prompt, context, ticker)` + module-level `_validate_<persona>_output(raw)` + `_parse_grounded_points(raw_points)` + `_filter_by_jaccard(points)` helpers (helpers MAY be re-implemented per persona OR imported from a `_shared.py` helper module per DD-3 — DECISION: per-persona re-implementation per Karpathy P3 + AP-23 first-instance HOLD on shared-base-class)
- **Author per-persona JSON content** at `agent-workspace/role-packs/buffett.json` + `graham.json` + `taleb.json` with EXACT 10 fields per RolePromptPack DD-7 + Rule 16 mode 1 conviction_guidance text rubric (NOT numeric 90-100 rubric per A-01 § 3 C9 REJECTION) + persona-distinct category_universe per DD-4 + Vietnam-relevance notes per DD-6
- **Extend PerspectiveRole StrEnum** at `packages/domain/analysis/models/perspective_analysis.py:30-39` to add 3 new values per DD-1 (`BUFFETT = "buffett"` + `GRAHAM = "graham"` + `TALEB = "taleb"`) — preserves type-safety + existing signature consistency
- **Preserve Rule 6 citation discipline** per persona — citation_requirements field embeds Rule 6 verbatim mandate; per-persona `_validate_<persona>_output` enforces `source_url` + `source_excerpt` present on each point (mirroring bear_agent.py:176-182 missing-field check)
- **Preserve AC-5 reproducibility** — per-persona adapters use existing ClaudeLLMPerspectiveAdapter (F.1 substrate; default transport flipped to claude_cli_transport per D-074); prompt_hash sha256[:16] computation UNCHANGED
- **Author ADR D-075 PROPOSED** at IMPL tier recording per-persona adapter shape + Vietnam-relevance evidence chain + pattern-port-not-code-port attestation + PerspectiveRole enum extension rationale

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — PerspectiveRole StrEnum extension at `packages/domain/analysis/models/perspective_analysis.py:30-39` (MODIFIED ~+3 LOC: 3 new enum values BUFFETT/GRAHAM/TALEB; foundation; blocks D2/D3/D4)
2. **Sub-track D2** — `BuffettPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/buffett_agent.py` (NEW ~210 LOC: class + retry-validator + helpers + module-level SYSTEM_PROMPT removed in favor of role_pack.system_prompt_template; mirrors bear_agent.py shape; parallel-eligible with D3+D4 post-D1 ship)
3. **Sub-track D3** — `GrahamPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/graham_agent.py` (NEW ~210 LOC: same shape as D2; parallel-eligible with D2+D4)
4. **Sub-track D4** — `TalebPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/taleb_agent.py` (NEW ~220 LOC: same shape as D2 + slight per-persona variation for tail-risk fragility category mapping; parallel-eligible with D2+D3)
5. **Sub-track D5** — Per-persona JSON content + tests + ADR + README append: (a) `agent-workspace/role-packs/buffett.json` (NEW ~45 LOC RolePromptPack 10-field JSON), (b) `graham.json` (NEW ~45 LOC), (c) `taleb.json` (NEW ~45 LOC), (d) `packages/infrastructure/analysis/perspectives/test_buffett_agent.py` (NEW ~280 LOC mirrors test_bear_agent.py shape; ≥12 TC), (e) `test_graham_agent.py` (NEW ~280 LOC; ≥12 TC), (f) `test_taleb_agent.py` (NEW ~280 LOC; ≥12 TC), (g) `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` ADR PROPOSED (~150 LOC), (h) `agent-workspace/role-packs/README.md` APPEND § 3 personas now populated (+~30 LOC)
6. **STEP 0 evaluation observation** appended to `agent-workspace/memory/observations/sandwich-dev-S378-bc-8-first-3-personas.md`
7. **Session log + observation file** per CLAUDE.md § Session Protocol End
8. **Mistake-log digest entry** (M-S378-N if mistakes; OR explicit "no mistakes" statement)
9. **ZERO charter / constitution writes**
10. **ZERO new LLM-numeric schema fields** (Rule 16 mode 1 categorical Conviction preserved per DD-5)
11. **ZERO new hooks** (mirror plan-020/022/026/027/029/030/031/034 — product substrate not harness rule-enforcement)
12. **ZERO new external dependencies** (uses already-shipped F.1 RolePromptPack + PersonaRegistry + subagent_transport + stdlib json; pyproject.toml UNCHANGED)
13. **ZERO composition-root wiring** at `packages/application/analysis/use_cases/validate_thesis_phase1.py` — N-persona dispatch belongs to F.3 sub-plan 036; F.2 only REGISTERS personas (via PersonaRegistry composition root in tests + future composition root in F.3); existing 3-persona pipeline UNCHANGED at use case level

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Sub-theme F.3 N-perspective use case extension to consume Buffett/Graham/Taleb personas | Separate sub-plan 036; F.3 BLOCKS_ON F.2 ship | Sub-plan 036 dispatch after S379 verifier PASS per master plan-033 § E.2 + § N.2 sequencing |
| Sub-theme F.4 V0 expansion to 6/9 personas (Munger/Lynch/VN_DOMAIN_SPECIALIST) | Separate sub-plan 037; CHARTER-TIER GATE per master plan § K.1.a non-blocking | Sub-plan 037 dispatch parallel with 038 post-F.3 ship; NO-OP IF V0=6 ratified |
| Sub-theme F.5 CLI dogfood thesis on one VN ticker | Separate sub-plan 038 | Sub-plan 038 dispatch parallel with 037 post-F.3 ship |
| Composition-root wiring for new personas at `validate_thesis_phase1.py` | F.2 ships per-persona ADAPTERS + REGISTERED via PersonaRegistry; F.3 sub-plan handles use case generalization (N-persona dispatch + Phase1Synthesizer extension); clean separation per Karpathy P3 | F.3 sub-plan 036 IMPL wires composition root at validate_thesis_phase1.py + extends Phase1Synthesizer |
| Per-persona historical hit-rate calibration | Charter Principle 8 + V0 ships UNCALIBRATED per master plan-033 § A.3; calibration_grade='D' per existing Thesis aggregate :84 | Calibration trigger: n≥50 thesis outcomes per persona across 3+ months wall-clock — post-MVP |
| Shared `_base_persona_agent.py` ABC OR Mixin per DD-3 | First-instance HOLD per AP-23; 3 personas worth of duplication acceptable per Karpathy P3; promote-to-shared trigger at ≥4 personas | Trigger: sub-plan 037 F.4 V0=9 ratification → 6 new persona files needed → AP-23 2nd instance promote-to-base-class calculus fires; refactor scope = own sub-plan 037-V2 |
| YAML format for role-packs (vs JSON V0) | DD-2 inherited from F.1 (pyyaml not in pyproject deps); JSON-only V0 per F.1 DD-2 | YAML trigger inherited from F.1 D-074 revisit trigger 2 (project-owner authors 3+ packs + reports edit-loop friction) |
| Per-persona dynamic temperature OR system_prompt-cache pre-warming | V0 uses claude_cli_transport which doesn't expose temperature flag (per subagent_transport.py:153-154) + V0 has no system prompt caching infrastructure | Trigger: F.5 CLI dogfood empirical cost overrun OR explicit project-owner request for per-persona temperature control |
| Per-persona Pydantic signal class (like ai-hedge-fund WarrenBuffettSignal) | Architecture rule: Pydantic in interfaces layer only; per-persona output validated via stdlib json + manual checks (existing bear_agent.py:158-194 pattern) | Trigger: V0-V2 if existing pattern surfaces empirical maintenance burden (rare — bear_agent.py has shipped stably for ≥6 months per existing convention) |
| Per-persona retry-attempt count override (different per persona) | V0 = uniform 3 attempts per D-054; Taleb may need MORE attempts due to tail-risk reasoning complexity; defer per AP-7 | Trigger: V0 dogfood produces ≥3 validation-exhausted events for any single persona across ≥10 thesis runs → tune per-persona attempts |
| Composition root for PersonaRegistry initialization in CLI/main entry | F.5 sub-plan 038 creates the CLI; composition root for PersonaRegistry init lives there (loads from `agent-workspace/role-packs/*.json` at startup) | F.5 sub-plan 038 IMPL ships composition root in `apps/cli/synthesize_vn_thesis.py` |
| Cross-persona conflict detection (Buffett bullish + Taleb bearish on same fragility signal) | Synthesis aggregate I-S12 invariant handles disagreement-surfaced-not-resolved at packages/domain/analysis/models/synthesis.py:89-100; cross-persona reasoning is F.3 use case work | F.3 sub-plan 036 generalizes Phase1Synthesizer to surface cross-persona disagreement deterministically |
| Persona-pack hot-reload at runtime | V0 ships static registration at composition root; PersonaRegistry has NO reload method (AP-23 first-instance HOLD inherited from F.1) | Trigger inherited from F.1 D-074 revisit trigger 3 (project-owner edits during live dogfood + asks for reload) — Phase F-prime-V2 |
| Vietnam-domain-specialist persona content | F.4 sub-plan 037 (V0=9 expansion) — VN_DOMAIN_SPECIALIST is RATIFICATION-GATED per master plan § K.1.a; F.2 ships only Buffett/Graham/Taleb | F.4 sub-plan 037 IMPL if user opts-in V0=9 via Q-INT-2026-05-F-prime-1 |
| Per-persona EchoValidator runtime enforcement | Persona output schema = existing PerspectiveAnalysis (no new numeric field); EchoValidator irrelevant for V0 | EchoValidator trigger inherited from F.1 D-074 revisit trigger (F.4-V2 surfaces new schema field) |
| Charter amendment SHIP for any new I-S<N> invariant F.2 surfaces | THIS plan FLAGS via STOP-FINDING file per § M; main session ratifies via AskUserQuestion gate | Trigger: § M CHARTER-TIER GATE STEP 0 STOP-AND-ASK fires |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; NARROW PRECEDENT declared for task_class="multi-perspective-impl" n=1 from S375)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; ~22 files cited; key 10 highlighted):

1. `agent-workspace/memory/.planner-stats.tsv` (header-only at S377 entry; L-S354-2 → L-S366-4 → L-S369-1 cascade carry-forward; **NARROW PRECEDENT on task_class="multi-perspective-impl" n=1** from S375 IMPL ship per current-execution.md S375 row clean cycle attestation)
2. `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (parent master plan; § E.2 sub-plan-035 contract + DD-2/DD-4/DD-12 + § K.2 anticipated FLAGS for F.2 = I-S35 buy/sell prose surface OR I-S1-1 numeric rubric surface)
3. `agent-workspace/session-plans/completed/034-S374-phase-f1-roleprompt-persona-transport.md` (predecessor F.1 sub-plan; direct template for THIS sub-plan structure mirror including § A/§ B/§ C/§ D/§ E/§ F/§ G/§ H/§ I/§ J/§ K/§ L/§ M/§ N/§ O cadence)
4. `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` (D-074 ACCEPTED; F.1 substrate consumed by THIS sub-plan; D-052 step 1 closure attestation + RolePromptPack contract + PersonaRegistry pattern + Rule 16 mode 1 satisfaction)
5. `packages/application/analysis/role_prompt_pack.py` (full read 103 LOC; RolePromptPack 10-field frozen dataclass + RolePromptPackInvariantError + 9 invariants; F.2 personas READ this contract)
6. `packages/application/analysis/persona_registry.py` (full read 157 LOC; PersonaRegistry stdlib dict + JSON loader + D-064 path-safety; F.2 personas LOADED via this registry in tests)
7. `packages/infrastructure/analysis/perspectives/bear_agent.py` (full read 335 LOC; D-054 retry-validator pattern + SYSTEM_PROMPT inline + Jaccard distinctness + _validate_bear_output I-S10 strict gate; **DIRECT TEMPLATE for THIS sub-plan's 3 new persona agents**)
8. `packages/infrastructure/analysis/perspectives/test_bear_agent.py` (read first 80 LOC; ≥12 TC pattern; test naming convention TC-bear-N; transport stub _CtxStub helper; **DIRECT TEMPLATE for THIS sub-plan's 3 new test files**)
9. `packages/domain/analysis/models/perspective_analysis.py` (full read 62 LOC; PerspectiveRole 6-value StrEnum; F.2 extends to 9 values per DD-1)
10. `C:/htdocs/research/ai-hedge-fund/src/agents/warren_buffett.py` (offset 1-100 + 760-827; class signature + ChatPromptTemplate.from_messages structure + 90-100 numeric rubric per A-01 § 3 C9 — **REJECTED per Rule 16 mode 1**; pattern-port not code-port per A-01 § 6 LICENSE caveat)

Additional files: `ai-hedge-fund/src/agents/ben_graham.py` (offset 1-100 + 294-340) + `ai-hedge-fund/src/agents/nassim_taleb.py` (offset 1-100 + 704-755) + `packages/infrastructure/analysis/subagent_transport.py` (offset 130-220 claude_cli_transport L144) + `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (offset 1-90 transport-flipped per D-074) + `agent-workspace/role-packs/README.md` (full read 62 LOC; V0 JSON format documented; § 3 personas authored by F.2) + `agent-workspace/memory/current-execution.md` (S377 row + Phase F-prime master plan ratification) + master plan supplement § H + spec 004 § A.2 + spec 006 § B.5.1-3 + agent-template L42-65 Phase 1b mandate + Phase E plan-031 (DIRECT PRECEDENT for BC-5 transport-flip per D-072) (~22 files total per § A.4 enumeration).

**Calibration parameters extracted**:

- **task_class**: `multi-perspective-impl` (n=1 NARROW PRECEDENT — S375 F.1 IMPL ship; clean cycle per current-execution.md attestation; nearest analog `vietnamese-nlp-impl` n=3 from S362+S365+S368 also clean cycles)
- **sample_size**: **1 for multi-perspective-impl** (S375 F.1 IMPL; ~115-160K Opus FOCUSED_IMPL actual envelope per F.1 plan budget derivation); **3 for nearest-analog vietnamese-nlp-impl** (S362+S365+S368 ~150-160K Sonnet / ~39min / 0 mistakes each)
- **avg_wall_min observed**: ~35-50 min projected for F.2 IMPL (3 persona files × ~15min + tests × ~10min/persona + JSON authoring × ~5min/persona + ADR + README; sequential D2+D3+D4 ~45min; parallel D2+D3+D4 post-D1 ship ~20min)
- **avg tokens_real observed**: ~115-150K Opus projected typical (n=1 narrow precedent extrapolated; novel portion = per-persona prompt content authoring adds ~15-25K reserve over F.1)
- **parallel_hit_rate**: PARALLEL declared D2+D3+D4 post-D1 ship (disjoint file scopes — 3 separate `<persona>_agent.py` files at packages/infrastructure/analysis/perspectives/); D5 parts (JSON + tests + ADR) can also run parallel
- **parallel_savings_avg**: estimated ~30-40% wall reduction from D2+D3+D4 parallel ship vs sequential
- **failure_mode frequency**: 0 mistakes per F.1 IMPL precedent (S375 clean cycle); novelty risk MEDIUM-LOW for F.2 IMPL because (a) 3 personas × same shape per D-054 pattern reduces per-persona novelty, (b) per-persona JSON content authoring is novel but bounded (10 fields × 3 personas = 30 content decisions max), (c) PerspectiveRole enum extension is trivial (3 LOC add)
- **Adjustment to default budget**: 100-150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md; +15-25K Opus reserve for per-persona prompt content authoring novelty + per-persona retry-validator semantic decisions (each persona has distinct category_universe → distinct _validate_<persona>_output semantics)
- **Cold-start?**: **NO for adapter-AUGMENT + tests + ADR shape** (transfers cleanly from S375 F.1 + S362-S365-S368 vietnamese-nlp-impl n=3); **PARTIAL-COLD-START for per-persona JSON content authoring** (sub-component novel; 30 content decisions × 3 personas = first instance of Vietnam-relevance content authoring at production tier); **NO for PerspectiveRole enum extension** (trivial)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S378 dev):

- S378 dev IMPL projection: **100-150K Opus FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=1 narrow precedent F.1 IMPL + n=3 nearest-analog vietnamese-nlp-impl
- STEP 0 evaluation overhead: ~10-20K
- D1 PerspectiveRole enum extension: ~3-5K
- D2 BuffettPerspectiveAgent: ~20-25K (210 LOC + retry-validator + _validate_buffett_output per-persona semantics)
- D3 GrahamPerspectiveAgent: ~20-25K (similar)
- D4 TalebPerspectiveAgent: ~25-30K (slight novelty for fragility category mapping)
- D5 JSON content + tests + ADR + README: ~30-40K (3 JSON × ~5K each + 3 test files × ~7K each + ADR 8K + README append 1K)
- Observation + session log + mistake-log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL): ~5-10K
- Reserve for inline F-fix: ~10-15K
- **Total projected dev budget envelope**: 125-180K typical; 135-195K with STEP 0 STOP-AND-ASK path; full 150K Opus cap respected (if work exceeds, SPLIT per AQ-7)

**PARALLEL OPPORTUNITY** (architect declaration for downstream S378 dev):

- D1 (PerspectiveRole enum extension) must serialize FIRST as foundation (~2 min wall)
- D2 (BuffettPerspectiveAgent) + D3 (GrahamPerspectiveAgent) + D4 (TalebPerspectiveAgent) CAN run PARALLEL post-D1 ship (~15 min wall each — disjoint file scopes; 3 separate `<persona>_agent.py` files)
- D5 components (3 JSON + 3 tests + ADR + README): JSON authoring blocked by their respective persona adapter signature (sequential within each persona D2/D3/D4); tests can run PARALLEL with JSON authoring post-D2/D3/D4 ship
- Sequential wall projection: 2 + 15 + 15 + 15 + 15 = ~62 min wall
- Parallel D2+D3+D4 + parallel D5 components wall projection: 2 + max(15, 15, 15) + max(10, 10, 8, 1) = ~27 min wall (~56% reduction)
- 3-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk
- Architect dispatches per-persona work to 3 parallel sandwich-dev sub-agents IF main session orchestrator chooses; OR single dev session executes sequentially per AP-23 first-instance HOLD (NO precedent for 3-parallel persona-pack dev dispatch yet)

**WHY NARROW PRECEDENT IS HONORED HONESTLY**:

- L-S354-2 + L-S366-4 + L-S369-1 carry-forward — planner-stats infrastructure gap persists; manual reading via master plan-033 + sub-plan 034 + current-execution.md + observations is substitute path
- n=1 narrow precedent S375 F.1 IMPL means budget envelope is DIRECTIONALLY grounded for adapter+test+ADR shape; per-persona JSON content authoring has NO precedent — first-instance risk MEDIUM (mitigated by tight bounding via DD-4/DD-5/DD-6 explicit content authoring guidance)
- S362+S365+S368 vietnamese-nlp-impl n=3 nearest-analog transfers cleanly for test+ADR portion; per-persona prompt authoring is novel-ish but mitigated by ai-hedge-fund pattern-port discipline (READ-ONLY reference per DD-10 + LICENSE caveat A-01 § 6)
- Architect declares: **NARROW PRECEDENT (n=1) on multi-perspective-impl task-class from S375; n=3 vietnamese-nlp-impl nearest-analog honored for tests+ADR portion; per-persona content authoring portion flagged as first-instance within envelope per RM2 — sub-plans 037/038 inherit growing precedent**

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S378 dev)

### IN-scope (S378 dev MUST ship)

- PerspectiveRole StrEnum extension at `packages/domain/analysis/models/perspective_analysis.py:30-39` with 3 new values BUFFETT/GRAHAM/TALEB (~+3 LOC)
- `BuffettPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/buffett_agent.py` (~210 LOC) with retry-validator mirroring D-054 BearPerspectiveAgent shape
- `GrahamPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/graham_agent.py` (~210 LOC) with retry-validator mirroring D-054
- `TalebPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/taleb_agent.py` (~220 LOC) with retry-validator mirroring D-054 + per-persona category_universe for tail-risk
- `agent-workspace/role-packs/buffett.json` (NEW ~45 LOC RolePromptPack 10-field JSON with Vietnam-relevance notes per DD-6 + Rule 16 mode 1 conviction_guidance per DD-5)
- `agent-workspace/role-packs/graham.json` (NEW ~45 LOC same shape)
- `agent-workspace/role-packs/taleb.json` (NEW ~45 LOC same shape)
- Unit tests: NEW `test_buffett_agent.py` (~280 LOC; ≥12 TC mirroring test_bear_agent.py) + NEW `test_graham_agent.py` (~280 LOC; ≥12 TC) + NEW `test_taleb_agent.py` (~280 LOC; ≥12 TC); total ~840 LOC test code + 36+ TC
- ADR D-075 PROPOSED at IMPL tier (~150 LOC at `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md`)
- README append (~30 LOC) at `agent-workspace/role-packs/README.md` § 3 documenting 3 personas now populated
- STEP 0 observation + Session log + observation file + Mistake-log digest entry
- Plan-035 moved `pending/` → `completed/` at S379 close (NOT at S378 close — verifier acceptance gates the move)

### OUT-of-scope for S378 dev (DEFERRED — explicit non-goals)

- Sub-theme F.3 N-perspective use case extension — separate sub-plan 036
- Sub-theme F.4 V0 expansion — separate sub-plan 037
- Sub-theme F.5 CLI dogfood — separate sub-plan 038
- Composition root for new personas at `validate_thesis_phase1.py` — F.3 work
- Per-persona historical hit-rate calibration — V0 UNCALIBRATED per master plan-033 § A.3
- Shared `_base_persona_agent.py` ABC OR Mixin — AP-23 first-instance HOLD per DD-3
- Per-persona Pydantic signal class — Pydantic in interfaces layer only per architecture constraint
- LangChain / LangGraph adoption — per master plan-033 § A.3 deferral + A-01 § 7 R1
- Persona-pack hot-reload — AP-23 first-instance HOLD inherited from F.1
- New harness hook for persona-prompt-linting — AP-23 2+ instance trigger
- YAML format for role-packs — inherited from F.1 D-074 revisit trigger 2
- VN_DOMAIN_SPECIALIST persona — F.4 sub-plan 037 (ratification-gated)

---

## C. STEP 0 — VBW Live Verification (BLOCKING — sub-steps 0.1-0.5)

S378 dev MUST execute STEP 0 BEFORE any production code write. Each sub-step has explicit pass criteria. If ANY sub-step surfaces a STOP-AND-ASK trigger, S378 dev MUST author `human-workspace/notifications/STOP-FINDING-S378-<sub-step>-<reason>.md` AND HALT pending main-session AskUserQuestion gate.

### Sub-step 0.1 — F.1 substrate availability + D-074 closure verification (BLOCKING)

S378 dev MUST verify:

- ✅ `packages/application/analysis/role_prompt_pack.py` exists + RolePromptPack class importable + 10-field shape per DD-7 matches D-074 attestation
- ✅ `packages/application/analysis/persona_registry.py` exists + PersonaRegistry class importable + `register/get/all_role_ids/load_from_json` 4 methods present
- ✅ `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` has ZERO `import anthropic` (Grep assertion; D-074 § Empirical close-verify L1 PASS confirmation)
- ✅ `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` has ZERO `_default_transport` symbol (Grep assertion; D-074 § Empirical close-verify L2 PASS confirmation)
- ✅ `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` default transport == `claude_cli_transport` from subagent_transport.py (Grep + Read assertion; D-074 § Empirical close-verify L1 PASS confirmation)
- ✅ existing `test_adapter.py` 12 tests pass (D-074 § Empirical close-verify L7 — regression-floor preserved)
- ✅ existing `test_bear_agent.py` 12 tests pass (D-074 § Empirical close-verify L7)
- ✅ existing `test_quant_agent.py` 10 tests pass (D-074 § Empirical close-verify L8)

**Pass criteria**: ALL 8 checks above pass. If ANY fail → STOP-AND-ASK: `STOP-FINDING-S378-0.1-f1-substrate-regression.md` with diff between expected and actual state.

**Estimated wall**: ~3-5 min (8 grep/read assertions + 3 test suite runs)

### Sub-step 0.2 — ai-hedge-fund persona reference READ (informational; no copy)

S378 dev SHALL READ (NOT COPY) the following 3 ai-hedge-fund persona reference files for pattern inspiration ONLY:

- `C:/htdocs/research/ai-hedge-fund/src/agents/warren_buffett.py` (offset 1-100 + 760-827 = class signature + ChatPromptTemplate structure + reasoning checklist)
- `C:/htdocs/research/ai-hedge-fund/src/agents/ben_graham.py` (offset 1-100 + 294-340 = class signature + ChatPromptTemplate + earnings/strength/valuation analysis pattern)
- `C:/htdocs/research/ai-hedge-fund/src/agents/nassim_taleb.py` (offset 1-100 + 704-755 = class signature + ChatPromptTemplate + antifragility/convexity/fragility/skin-in-game/volatility-regime checklist)

S378 dev MUST extract PRINCIPLES only (NOT verbatim string copy):

- **Buffett**: circle of competence + competitive moat + management quality + financial strength + valuation vs intrinsic value + long-term prospects → 6 categories → DD-4 category_universe MOAT/MANAGEMENT/VALUATION/ROIC/BALANCE_SHEET/GROWTH
- **Graham**: earnings stability + financial strength + Graham valuation (Graham Number / NCAV / margin of safety) → 6 categories → DD-4 category_universe EARNINGS_STABILITY/BALANCE_SHEET_STRENGTH/DIVIDEND_RECORD/MARGIN_OF_SAFETY/NCAV/GRAHAM_NUMBER
- **Taleb**: antifragility + tail risk + convexity + fragility + skin in the game + volatility regime → 6 categories → DD-4 category_universe FRAGILITY/CONVEXITY/SKIN_IN_GAME/TAIL_RISK/VOLATILITY_REGIME/ANTIFRAGILITY

S378 dev MUST add per-persona Vietnam-relevance notes per DD-6 (Buffett VinGroup conglomerate moat + Vinamilk-class consumer brand value / Graham VN banking NCAV + VN real estate balance-sheet complexity / Taleb F0 retail tail-risk + 'đội lái' pump-cluster fragility + USD/VND volatility regime).

S378 dev MUST NOT:
- Copy ChatPromptTemplate.from_messages structures verbatim
- Copy Pydantic signal class definitions
- Copy `call_llm` wrapper function bodies
- Copy 90-100 numeric confidence rubrics (REJECTED per Rule 16 mode 1)

**Pass criteria**: Architect-extracted principles list documented in observation; ZERO verbatim string copy attested (grep S378 IMPL output files for any 50+ char substring match against ai-hedge-fund source files).

**STOP-AND-ASK trigger**: If S378 dev struggles to author Vietnam-relevance notes for any persona (e.g. cannot ground TALEB tail-risk in any verifiable VN-specific phenomenon) → `STOP-FINDING-S378-0.2-vietnam-relevance-weak.md` with named alternatives (e.g. replace TALEB with different persona OR adjust Vietnam-relevance to be aspirational rather than empirical).

**Estimated wall**: ~10-15 min (3 file reads × ~3 min each + principle extraction + Vietnam-relevance content authoring)

### Sub-step 0.3 — V0 persona-pack JSON shape conformance check (BLOCKING)

S378 dev SHALL READ `packages/application/analysis/role_prompt_pack.py` 9 invariants enforced by `__post_init__` and confirm each of 3 persona JSON files (to be authored in D5) will PASS all 9:

1. `role_id` matches `^[a-z][a-z0-9_]*$` regex (lowercase identifier; underscore not hyphen) — 'buffett'/'graham'/'taleb' all PASS
2. `persona_name` non-empty — PASS (DD-1 above provides full names)
3. `system_prompt_template` non-empty AND contains `{TICKER}` placeholder — PASS (architect-authored per persona)
4. `conviction_guidance` non-empty — PASS (DD-5)
5. `citation_requirements` non-empty — PASS (DD-5 + Rule 6 embedding)
6. `min_points >= 1` — PASS (≥3 per persona per spec § B.5.1 mirror)
7. `min_distinct_categories >= 1` — PASS (≥3 per persona)
8. `category_universe` non-empty AND unique strings AND `min_distinct_categories <= len(category_universe)` — PASS (6 categories per persona per DD-4; 3 ≤ 6)
9. `model_id_preference` is None OR in {'claude-sonnet-4-6', 'claude-opus-4-7', 'claude-haiku-4-5'} — PASS ('claude-sonnet-4-6' per DD-7)

**Pass criteria**: All 9 invariants confirmed PASS for all 3 personas per DD-4/DD-5/DD-6/DD-7 explicit content authoring guidance.

**STOP-AND-ASK trigger**: If any invariant violation surfaced during JSON authoring → `STOP-FINDING-S378-0.3-rolepromptpack-invariant-violation-<persona>.md` with offending field + DD reference; HALT pending architect refinement.

**Estimated wall**: ~3-5 min (9 invariants × 3 personas = 27 confirmations)

### Sub-step 0.4 — Vietnam-relevance audit per persona (BLOCKING per § A.2 dispatch brief)

S378 dev SHALL CONFIRM per-persona Vietnam-relevance is SUBSTANTIVE (not boilerplate) per master plan-033 DD-2 evidence chain:

- **Buffett** (value investor, quality + moat focus): Vietnam-relevance = VinGroup conglomerate moat exposure + Vietnam consumer brand value (Vinamilk-class / Masan-class durable consumer); evidence chain: master plan-033 DD-2 line 293 "HIGH-relevance V0"; per-persona vietnam_notes MUST cite at least 1 specific VN30 ticker + 1 specific moat-type
- **Graham** (deep value, margin of safety, balance-sheet-focused): Vietnam-relevance = VN banking sector NCAV applicability + VN real estate (e.g. Vinhomes complex balance sheets); evidence chain: master plan-033 DD-2 line 294 "HIGH-relevance V0"; per-persona vietnam_notes MUST cite at least 1 specific VN banking sector consideration + 1 specific balance-sheet-complexity caveat
- **Taleb** (antifragility, tail-risk, kurtosis): Vietnam-relevance = F0 retail-dominated market high-tail-risk regime + "đội lái" pump-cluster phenomena + USD/VND volatility regime; evidence chain: master plan-033 DD-2 line 295 "VERY-HIGH-relevance V0" + A-01 § 3 C13 + A-14 retail-culture cite; per-persona vietnam_notes MUST cite "đội lái" pump-cluster as textbook tail-risk surface + USD/VND volatility consideration

**Pass criteria**: Each persona vietnam_notes contains ≥150 chars + cites ≥2 distinct VN-specific phenomena from above lists.

**STOP-AND-ASK trigger** (PER DISPATCH BRIEF § C.0.4 EXPLICIT): If any persona's Vietnam-relevance proves WEAK during empirical authoring (e.g. all 3 personas' vietnam_notes are <100 chars OR none cite specific VN tickers OR all reduce to generic "Vietnam emerging market" boilerplate) → `STOP-FINDING-S378-0.4-vietnam-relevance-too-weak-<persona>.md` with options: (a) replace persona with stronger VN-relevance alternative (e.g. swap TALEB for MICHAEL_BURRY housing-bubble or PETER_LYNCH consumer-bottom-up); (b) accept weak vietnam_notes for V0 with named revisit trigger; (c) defer F.2 ship pending more VN domain research.

**Estimated wall**: ~5-10 min (3 personas × ~2 min Vietnam-relevance content authoring + audit)

### Sub-step 0.5 — Existing related-pattern grep audit (BLOCKING regression-floor)

S378 dev SHALL grep production code to confirm:

- ✅ `Grep BuffettPerspectiveAgent|GrahamPerspectiveAgent|TalebPerspectiveAgent` (production code) returns 0 matches — clean baseline for D2/D3/D4 to add first production use
- ✅ `Grep buffett_agent|graham_agent|taleb_agent` (filesystem) returns 0 matches at `packages/infrastructure/analysis/perspectives/` — clean baseline
- ✅ `Grep BUFFETT|GRAHAM|TALEB` (production code at `packages/domain/analysis/models/perspective_analysis.py` PerspectiveRole) returns 0 matches — clean baseline for D1 enum extension
- ✅ `Grep import anthropic|from anthropic` in `packages/infrastructure/analysis/perspectives/` returns 0 matches — D-074 closure preserved
- ✅ existing `bear_agent.py` + `bull_agent.py` + `quant_agent.py` files exist + unchanged at line counts {bear:335, bull:?, quant:?} (regression-floor)
- ✅ `agent-workspace/role-packs/` directory exists (per D-074 § Files modified — README placeholder shipped at F.1) — D5 can populate JSON files

**Pass criteria**: All 6 grep/glob checks PASS.

**STOP-AND-ASK trigger**: If existing perspective files show drift from D-074 attestation state (e.g. anthropic import re-introduced) → `STOP-FINDING-S378-0.5-d074-regression.md` with diff.

**Estimated wall**: ~3-5 min

### Sub-step 0.6 — STEP 0 summary write (per IMPL session protocol)

Append STEP 0 sub-steps 0.1-0.5 PASS/FAIL summary to observation file `agent-workspace/memory/observations/sandwich-dev-S378-bc-8-first-3-personas.md` BEFORE proceeding to D1 IMPL.

If any STEP 0 sub-step FAILED → HALT + STOP-AND-ASK file path as named in respective sub-step.

**Pass criteria**: Observation file STEP 0 summary populated with 6 sub-step verdicts.

---

## D. Architecture Decisions (DD-1 through DD-11)

### DD-1: PerspectiveRole StrEnum EXTENDED with BUFFETT/GRAHAM/TALEB (NOT role_id-only routing)

**Decision**: Extend `PerspectiveRole` StrEnum at `packages/domain/analysis/models/perspective_analysis.py:30-39` to add 3 new values:

```python
class PerspectiveRole(StrEnum):
    BEAR = "bear"
    BULL = "bull"
    QUANT = "quant"
    # Phase 3 stubs (deferred)
    MACRO = "macro"
    BEHAVIOR = "behavior"
    MANAGER = "manager"
    # F.2 plan-035 additions (active personas)
    BUFFETT = "buffett"
    GRAHAM = "graham"
    TALEB = "taleb"
```

**Rationale**:
- **Type-safety**: existing `PerspectiveAnalysis.role: PerspectiveRole` field at `perspective_analysis.py:55` is StrEnum-typed; adding new values preserves type-safety vs role_id-only routing (which would require runtime str validation everywhere)
- **Signature consistency**: existing per-persona adapters use `role=PerspectiveRole.BEAR` literal at `bear_agent.py:272+306+328` (3 sites); new persona adapters mirror with `role=PerspectiveRole.BUFFETT` etc.
- **Existing tests**: `test_bear_agent.py:244+264+289+323+360` use `PerspectiveRole.BEAR` literal; F.2 new tests mirror with `PerspectiveRole.BUFFETT` etc.
- **Use case dispatch (F.3)**: `validate_thesis_phase1.py:221` `asyncio.gather(bear_t, bull_t, quant_t)` dispatches by typed role; F.3 generalizes but needs typed enum to lookup persona adapters
- **PersonaRegistry decoupling**: `PersonaRegistry.get(role_id)` uses str key (role_id) → RolePromptPack lookup; the role_id ('buffett' lowercase) is independent of PerspectiveRole.BUFFETT enum value ('buffett'); they HAPPEN to match but are conceptually different (role_id = registry key for data lookup; PerspectiveRole = type-safe perspective identifier)

**Adversarial alternate considered #1**: Role_id-only routing (NO PerspectiveRole extension) → REJECTED — would require `PerspectiveAnalysis.role: str` type widening (breaking change to existing schema; would invalidate ~10 PerspectiveRole-typed call sites)

**Adversarial alternate considered #2**: Map BUFFETT/GRAHAM/TALEB to existing MACRO/BEHAVIOR/MANAGER deferred stubs (reuse enum slots) → REJECTED — semantically wrong (Buffett ≠ Macro; Graham ≠ Behavior; Taleb ≠ Manager); breaks downstream consumer assumption about deferred-stub semantics; future MACRO/BEHAVIOR/MANAGER personas would conflict

**Mitigation**: Sub-plan 037 F.4 V0=9 expansion may add MUNGER/LYNCH/VN_DOMAIN_SPECIALIST values; PerspectiveRole enum grows linearly with V0=N persona count — acceptable per Karpathy P2 (3 + 6 = 9 enum values manageable)

### DD-2: PER-PERSONA FILE NAMING CONVENTION = `<role_id>_agent.py`

**Decision**: Each new persona ships as a single `.py` file at `packages/infrastructure/analysis/perspectives/<role_id>_agent.py`:

- `buffett_agent.py` (parallel to existing `bear_agent.py`)
- `graham_agent.py` (parallel to existing `bull_agent.py`)
- `taleb_agent.py` (parallel to existing `quant_agent.py`)

**Rationale**:
- **Match existing convention**: `bear_agent.py` + `bull_agent.py` + `quant_agent.py` already established at `packages/infrastructure/analysis/perspectives/`
- **Karpathy P3 surgical-changes**: 3 new files + 3 modified files (1 enum + 2 tests if F.3 wiring path needed, which is OUT-OF-SCOPE here) — minimal blast radius
- **Glob discoverability**: future glob `packages/infrastructure/analysis/perspectives/*_agent.py` returns all 6 personas (3 existing + 3 new) — clean enumeration for F.3 composition root
- **Test parity**: each test file mirrors `test_bear_agent.py` shape; test files glob `test_*_agent.py` returns all 6 test files (3 existing + 3 new)

**Adversarial alternate considered #1**: Single `personas.py` file containing all 3 classes → REJECTED — file size would exceed ~500 LOC; merge-conflict surface widens; per-persona test files cannot import per-persona class cleanly

**Adversarial alternate considered #2**: Subfolder `perspectives/personas/buffett.py` etc. → REJECTED — over-engineering for V0; existing `perspectives/*.py` flat structure works fine for 3-9 personas

### DD-3: NO SHARED BASE CLASS (`_base_persona_agent.py` ABC OR Mixin) — first-instance HOLD per AP-23

**Decision**: Each of 3 new persona adapters re-implements `_validate_<persona>_output` + `_parse_grounded_points` + `_filter_by_jaccard` + `_analyze_with_retry` per Karpathy P3 surgical-changes; NO shared `_base_persona_agent.py` ABC OR Mixin authored this sub-plan.

**Rationale**:
- **AP-23 first-instance HOLD**: 3 personas is FIRST instance of multi-persona-pattern; shared-base abstraction is 2nd-instance-promote-trigger per AP-23 (e.g. sub-plan 037 F.4 V0=9 ratification → 6 additional personas → AP-23 2nd instance promote-to-base-class calculus fires)
- **Karpathy P3 surgical-changes**: shared-base would require refactoring existing bear_agent.py + bull_agent.py + quant_agent.py to consume the base (creates blast radius outside F.2 scope; violates clean separation)
- **Per-persona validation semantics differ**: Buffett _validate_buffett_output checks for `moat`-grounded category + `valuation` numeric reference (from deterministic tool, not LLM-emitted); Graham checks for `margin_of_safety` numeric reference + `current_ratio` numeric reference; Taleb checks for `fragility`-grounded category + `convexity` evidence — generic base class would over-abstract OR require per-subclass override of validation hook = no abstraction win
- **3-persona duplication is manageable**: ~210 LOC × 3 = ~630 LOC total; ~60% of code is identical _parse_grounded_points + _filter_by_jaccard + _analyze_with_retry skeleton; ~40% is persona-specific; refactor at 4+ personas is sensible

**Adversarial alternate considered #1**: Shared `_BasePersonaAgent` ABC at `packages/infrastructure/analysis/perspectives/_base_persona_agent.py` with abstract `_validate_persona_output(raw, role_pack) -> tuple[bool, str | None]` + concrete `_analyze_with_retry` + `_parse_grounded_points` + `_filter_by_jaccard` shared → REJECTED for V0 per AP-23 first-instance HOLD; ACCEPTABLE for sub-plan 037-V2 refactor

**Adversarial alternate considered #2**: Mixin `_RetryValidatorMixin` providing `_analyze_with_retry` only → REJECTED — same first-instance HOLD reasoning; partial-mixin overhead not justified for V0

**Promote-or-retire trigger** (AP-23): If sub-plan 037 V0=9 ratification fires AND adds 3+ more persona adapters → SCHEDULE refactor sub-plan 037-V2 dispatching shared-base-class extraction OR continue per-persona duplication if 9 personas remain manageable

### DD-4: PER-PERSONA CATEGORY_UNIVERSE = persona-distinct 6-element tuples

**Decision**: Each persona's `category_universe` field is a persona-distinct 6-element tuple per RolePromptPack DD-7 invariant (`min_distinct_categories <= len(category_universe)`):

- **Buffett**: `("MOAT", "MANAGEMENT", "VALUATION", "ROIC", "BALANCE_SHEET", "GROWTH")` (6 categories per ai-hedge-fund warren_buffett.py:775-781 reasoning checklist — circle of competence + moat + management + financial strength + valuation + long-term prospects → translated to category-system per StockForge convention)
- **Graham**: `("EARNINGS_STABILITY", "BALANCE_SHEET_STRENGTH", "DIVIDEND_RECORD", "MARGIN_OF_SAFETY", "NCAV", "GRAHAM_NUMBER")` (6 categories per ai-hedge-fund ben_graham.py:46-54 analysis pattern — earnings stability + strength + valuation; plus Graham-specific categories margin-of-safety + NCAV + Graham Number per ben_graham.py:298-310 reasoning checklist)
- **Taleb**: `("FRAGILITY", "CONVEXITY", "SKIN_IN_GAME", "TAIL_RISK", "VOLATILITY_REGIME", "ANTIFRAGILITY")` (6 categories per ai-hedge-fund nassim_taleb.py:710-716 reasoning checklist — antifragility + tail risk + convexity + fragility + skin in the game + volatility regime; direct port of principles, NOT verbatim string copy per LICENSE caveat)

`min_distinct_categories = 3` for all 3 personas (mirrors I-S10 BEAR substantive bear case ≥3 categories floor); `min_points = 3` for all 3 personas.

**Rationale**:
- **Persona-distinct categories**: Each persona's analytical framework is fundamentally different (Buffett = quality/moat; Graham = quantitative-conservative; Taleb = tail-risk/asymmetry); shared category list would lose per-persona analytical signal
- **6 categories per persona**: matches existing BEAR `{FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}` 6-category pattern at bear_agent.py:59-60; provides headroom for `min_distinct_categories = 3` without forcing exhaustive coverage
- **Direct mapping to ai-hedge-fund reasoning checklists**: per-persona Vietnam-relevance preserved while pattern-port (NOT code-port per A-01 § 6) honors design discipline

**Adversarial alternate considered #1**: Shared 12-category union universe across all 3 personas → REJECTED — loses per-persona signal; each persona ought to focus on its analytical strengths

**Adversarial alternate considered #2**: 9-category universe per persona (more headroom) → REJECTED — diminishing returns; 6 categories suffice for min_distinct_categories=3 with 2× headroom

### DD-5: PER-PERSONA CONVICTION_GUIDANCE = explicit Rule 16 mode 1 categorical rubric

**Decision**: Each persona's `conviction_guidance` field is a TEXT-ONLY rubric INSTRUCTING the LLM to pick categorical `Conviction.STRONG / MODERATE / WEAK` per persona-specific criteria. NO numeric 0-100 rubric; NO float confidence; NO integer confidence — those are A-01 § 3 C9 patterns REJECTED per Rule 16 mode 1 (per master plan-033 DD-2 line 326-327 + § Sub-step 0.4 explicit).

**Per-persona conviction_guidance template**:

- **Buffett**: "STRONG = clear durable moat AND attractive valuation AND high ROIC consistency >=5y; MODERATE = decent moat OR fair valuation OR mixed ROIC; WEAK = single-category strength OR unfit circle of competence. Pick categorical based on accumulated category-level evidence — do NOT emit numeric percentage."
- **Graham**: "STRONG = clear margin of safety (price < 2/3 Graham Number) AND current_ratio >= 2.0 AND consistent earnings 5y+; MODERATE = decent margin OR moderate balance-sheet strength OR sporadic earnings; WEAK = no margin of safety OR weak balance sheet OR speculative earnings. Pick categorical — do NOT emit numeric percentage."
- **Taleb**: "STRONG = clearly antifragile (benefits from disorder) AND convex payoff AND skin in the game; MODERATE = low fragility OR moderate convexity; WEAK = fragile (high leverage / thin margins) OR dangerous low-vol regime OR no skin in the game. Pick categorical — do NOT emit numeric percentage."

**Rationale**:
- **Rule 16 mode 1 categorical surrogate compliance**: per existing Conviction StrEnum STRONG/MODERATE/WEAK at conviction.py:17-22; LLM picks category; deterministic code maps to numeric if needed downstream; no LLM-emitted integer
- **A-01 § 3 C9 Buffett 90-100 rubric REJECTED**: ai-hedge-fund warren_buffett.py:788-794 confidence scale rubric is LLM-self-reported per A-01 § 5 second-to-last bullet — REJECTED per I-S1-1 Rule 16
- **Explicit "do NOT emit numeric percentage" instruction**: defensive against LLM volunteering numeric confidence despite categorical mandate; mirrors bear_agent.py:53-56 "Forbidden phrasings" pattern at SYSTEM_PROMPT

**Charter STOP-AND-ASK trigger**: If per-persona prompt drafts surface numeric 90-100 rubric DESPITE Rule 16 mode 1 explicit → STOP-FINDING-S378-0.4-numeric-rubric-leak-<persona>.md with offending text + Rule 16 reference

### DD-6: PER-PERSONA VIETNAM_NOTES = persona-specific VN-market application content

**Decision**: Each persona's `vietnam_notes` field contains ≥150 chars of VN-specific application content per master plan-033 DD-2 evidence chain (§ A.4 sub-step 0.4 audit):

- **Buffett vietnam_notes**: "VinGroup conglomerate moat (VIC + VHM + VRE; cross-holding complexity → moat fragility risk vs durable). Vinamilk (VNM) durable consumer brand value moat (>50y dairy leadership). MWG (Mobile World) retail distribution moat (>3000 stores). Banking sector moat = state-protected oligopoly (VCB / BID / TCB). HPG steel moat = scale advantage in regional market. Beware VN-specific 'cross-holding' moat = governance-fragility tradeoff. Apply circle of competence: avoid speculative sectors (small-cap pump stocks / unprofitable startups)."
- **Graham vietnam_notes**: "VN banking sector NCAV applicability LIMITED (banks rarely trade below NCAV in VN; price-to-book floors at 1.0x historically). VN real estate (Vinhomes / Khang Dien / Novaland) balance-sheet complexity = land bank revaluation + cash-conversion-cycle long; Graham margin-of-safety harder to compute without VN-specific land valuation expertise. Current ratio 2.0 threshold often unmet in VN industrial sector due to short-term financing reliance; relax to 1.5 with explicit caveat. Graham Number calculation requires VN-adjusted EPS (no IFRS earnings smoothing for many VN companies). Dividend records < 5y for many VN30 tickers (HSX listings since 2007); apply Graham 5y rule with relaxation to ≥3y for VN30."
- **Taleb vietnam_notes**: "VN F0 retail-dominated market (>85% retail volume per HOSE statistics) = high-tail-risk regime; daily price limit ±7% (UPCoM ±15%) is volatility-clamping but masks true tail risk. 'Đội lái' (coordinated retail pump-cluster phenomenon — see VC1/SHB historical pumps) = textbook fragility / fat-tail surface. USD/VND volatility regime = managed peg ±5% per SBV → low historical vol BUT one-shot devaluation risk (1997 Asian crisis precedent / 2008-2011 progressive devaluation) = classic Taleb 'turkey problem'. Insider trading disclosure compliance weaker than developed markets = skin-in-the-game signal less reliable; weight insider trades data with VN-specific cynicism. Vietnam macro convexity = export-led growth vulnerable to USD strength / China slowdown / trade-war asymmetry."

**Rationale**:
- **Vietnam-relevance evidence chain per master plan-033 DD-2**: Buffett HIGH / Graham HIGH / Taleb VERY-HIGH per architect-tier ratification
- **Persona-specific VN application**: each persona's analytical framework mapped to VN-specific phenomena (Buffett = VN moat structures; Graham = VN balance-sheet nuance; Taleb = VN retail-dominated tail-risk)
- **≥150 char minimum**: substantive content threshold; if author cannot reach 150 chars empirically → STOP-AND-ASK trigger per § C.0.4 explicit dispatch brief

**STOP-AND-ASK trigger**: If any persona's vietnam_notes proves WEAK (<100 chars OR only generic "Vietnam emerging market" boilerplate) during empirical authoring → `STOP-FINDING-S378-0.4-vietnam-relevance-too-weak-<persona>.md` per § C.0.4

### DD-7: MODEL_ID_PREFERENCE = 'claude-sonnet-4-6' for ALL 3 personas

**Decision**: Each persona's `model_id_preference` field is set to `'claude-sonnet-4-6'` explicitly per master plan-033 DD-12 (value-investor reasoning ≠ Opus-class computational reasoning; QUANT remains only Opus persona).

**Rationale**:
- **Cost-routing per master plan DD-12**: BEAR / BULL / BUFFETT / GRAHAM / TALEB → Sonnet (~$3/MTok in + $15/MTok out); QUANT → Opus (~$15+$75/MTok) due to computational reasoning load
- **Explicit value (NOT None default)**: even though None defaults to existing ROUTE_TO_MODEL map at claude_llm_perspective_adapter.py:65-69, setting explicit value leaves auditable per-persona override trail in JSON
- **Auditable**: composition root inspecting `PersonaRegistry.all_role_ids()` + iterating pack.model_id_preference can produce per-persona model report for cost-analysis

**Adversarial alternate considered**: None default (delegate to ROUTE_TO_MODEL) → ACCEPTABLE alternative; chose explicit value for audit-trail benefit

### DD-8: PER-PERSONA RETRY-VALIDATOR = MIRROR D-054 BearPerspectiveAgent shape exactly

**Decision**: Each persona's adapter class mirrors `BearPerspectiveAgent` shape at `bear_agent.py:198-334` exactly:

```python
class BuffettPerspectiveAgent:
    """Concrete BUFFETT perspective agent.
    
    Mirrors BearPerspectiveAgent D-054 retry-validator pattern.
    """
    
    def __init__(self, adapter: object, role_pack: RolePromptPack) -> None:
        self._adapter = adapter
        self._role_pack = role_pack
    
    async def analyze(
        self, ticker: Ticker, context: object, _role: PerspectiveRole
    ) -> PerspectiveAnalysis:
        as_of_str = str(getattr(context, "as_of", ""))
        prompt = self._role_pack.system_prompt_template.replace(
            "{TICKER}", ticker.symbol
        ).replace("{AS_OF}", as_of_str)
        return await self._analyze_with_retry(prompt=prompt, context=context, ticker=ticker)
    
    async def _analyze_with_retry(
        self, prompt: str, context: object, ticker: Ticker
    ) -> PerspectiveAnalysis:
        # ... mirror bear_agent.py:233-334 with per-persona _validate_buffett_output
        pass
```

Per-persona `_validate_<persona>_output(raw)` mirrors `bear_agent.py:_validate_bear_output` at L145-195 with persona-specific:
- `min_points` check (reads `role_pack.min_points`; e.g. ≥3 for Buffett)
- `min_distinct_categories` check (reads `role_pack.min_distinct_categories`; e.g. ≥3)
- `category_universe` membership check (reads `role_pack.category_universe`; each point's category MUST be in this tuple)

**Rationale**:
- **D-054 proven shape**: 3-attempt retry-validator + re-prompt with error + cumulative cost + validation-exhausted WARNING + empty PerspectiveAnalysis on triple-fail is shipped + stable for BEAR/BULL since ADR D-053/D-054
- **Per-persona category_universe enforcement**: ensures LLM-output category fits persona-specific framework (Buffett's MOAT/MANAGEMENT/etc. — not arbitrary string); fail-fast for retry
- **Parameterization via role_pack**: RolePromptPack passed to constructor → per-persona `_validate_<persona>_output` reads `self._role_pack` for category_universe + min_points + min_distinct_categories (parameterization avoids hardcoding limits in adapter code)

**Adversarial alternate considered**: Single attempt + fail-fast (no retry) → REJECTED — LLM validation failure rate empirically ~5-15% per attempt (per D-054 + D-053 ratification context); retry-validator hardens against transient LLM hiccups

### DD-9: EXISTING TEST PATTERN PARITY — `test_<persona>_agent.py` mirrors `test_bear_agent.py`

**Decision**: Each new test file mirrors `test_bear_agent.py` shape at ≥12 test cases per persona:

- TC-<persona>-1: `_validate_<persona>_output`: JSON parse fail → (False, reason)
- TC-<persona>-2: empty key_points list → (False, reason)
- TC-<persona>-3: missing 'category' field → (False, reason)
- TC-<persona>-4: missing 'as_of' field → (False, reason)
- TC-<persona>-5: <`min_distinct_categories` distinct → (False, reason)
- TC-<persona>-6: valid output with ≥`min_distinct_categories` distinct cats → (True, None)
- TC-<persona>-7: top-level not dict → (False, reason)
- TC-<persona>-8: category not in `role_pack.category_universe` → (False, reason) [NEW per-persona check]
- TC-<persona>-9: `_analyze_with_retry`: 1st JSON parse fail then success → returns valid output
- TC-<persona>-10: `_analyze_with_retry`: 1st structural fail then success → returns valid output
- TC-<persona>-11: `_analyze_with_retry`: triple fail → empty PerspectiveAnalysis + exhausted log
- TC-<persona>-12: `_analyze_with_retry`: re-prompt on attempt 2+ includes validation error excerpt

Plus optional TC-<persona>-13: LLM exception becomes validation_error (not propagated) [mirrors TC-bear-12]

**Rationale**:
- **Test naming convention parity**: existing `test_bear_agent.py:1-15` documents TC-bear-N convention; F.2 mirrors with TC-buffett-N / TC-graham-N / TC-taleb-N
- **Coverage floor 12 TC**: ensures each persona's retry-validator + per-persona category_universe check + happy-path + edge-cases all covered
- **No subprocess / no network**: all transport calls stubbed per test_bear_agent.py:17 attestation

**DoD floor per § F**: ≥36 NEW TC across 3 personas (3 × 12 = 36); existing tests still PASS (regression-floor)

### DD-10: PERSONA JSON CONTENT AUTHORING = PATTERN-PORT NOT CODE-PORT per A-01 § 6 LICENSE caveat

**Decision**: All per-persona prompt template + reasoning checklist + conviction guidance content is AUTHORED FRESH from documented principles (Buffett's writings + Graham's "Intelligent Investor" + Taleb's "Antifragile") via architect-extracted principles list in § C.0.2.

ZERO verbatim string copy from ai-hedge-fund source files. Specifically:
- NO copy of `ChatPromptTemplate.from_messages([...])` content from warren_buffett.py:769-809 / ben_graham.py:294-340 / nassim_taleb.py:704-755
- NO copy of Pydantic signal class definitions (e.g. WarrenBuffettSignal)
- NO copy of `call_llm()` wrapper function bodies
- NO copy of 90-100 / 70-89 / 50-69 / 30-49 / 10-29 confidence rubric percentages

**Verification mechanism**:
- S378 dev MUST grep for any 50+ char substring match between authored persona JSON content (system_prompt_template + conviction_guidance fields) and ai-hedge-fund source files at C:/htdocs/research/ai-hedge-fund/src/agents/<persona>.py
- If any substring match >50 chars → STOP-AND-ASK + re-author with persona-specific paraphrase
- S378 verifier S379 RE-RUNS this grep as DC-VERIFY-3 gate

**Rationale**:
- **A-01 § 6 LICENSE caveat**: ai-hedge-fund root LICENSE-file MISSING; pattern-only adoption safe; code-copy HIGH RISK; recommendation = re-implement from scratch using pattern; do NOT copy file contents
- **Pattern-port is principles**: Buffett's circle of competence + moat + management + financial strength + valuation + long-term — these are public-domain investment principles; ai-hedge-fund is a particular operationalization; F.2 ships an INDEPENDENT operationalization grounded in same principles
- **Audit trail**: ADR D-075 § Pattern source explicitly attests pattern-port not code-port per A-01 § 6 + ai-hedge-fund LICENSE caveat

### DD-11: ADR D-075 PROPOSED-AT-IMPL — 'BC-8 First 3 Personality-Pack Adapters (Buffett/Graham/Taleb)'

**Decision**: NEW ADR at `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` PROPOSED at IMPL tier (per severity-schema auto-ratifies on commit) recording:

- **Decision**: (a) PerspectiveRole enum extension per DD-1 + (b) per-persona file naming convention per DD-2 + (c) NO shared base class per DD-3 + (d) per-persona category_universe per DD-4 + (e) per-persona conviction_guidance text rubric per DD-5 + (f) per-persona vietnam_notes content per DD-6 + (g) model_id_preference 'claude-sonnet-4-6' per DD-7 + (h) D-054 retry-validator mirror per DD-8 + (i) pattern-port not code-port LICENSE attestation per DD-10
- **Pattern source**: ai-hedge-fund warren_buffett.py + ben_graham.py + nassim_taleb.py (READ-ONLY pattern inspiration; LICENSE caveat A-01 § 6) + StockForge bear_agent.py D-054 retry-validator
- **Empirical close-verify** template (S378 dev populates at IMPL commit time):
  - L1: 3 persona JSON files load via PersonaRegistry.load_from_json successfully + register OK
  - L2: 3 persona adapter classes instantiate via `<Persona>PerspectiveAgent(adapter, role_pack)` 
  - L3: per-persona `_validate_<persona>_output` validates happy-path + rejects invalid (3 personas × 6+ edge cases)
  - L4: per-persona `_analyze_with_retry` runs 3-attempt loop correctly (stub LLM with fail+fail+success path)
  - L5: PerspectiveRole.BUFFETT / GRAHAM / TALEB enum values accessible
  - L6: existing 12+ tests in test_bear_agent.py + test_quant_agent.py + test_adapter.py + test_synthesizer.py STILL PASS (regression floor)
  - L7: ≥36 NEW tests across test_buffett/graham/taleb_agent.py PASS
  - L8: mypy --strict + ruff + pytest exit 0 on packages/infrastructure/analysis/perspectives/ + packages/application/analysis/
  - L9: grep `import anthropic|from anthropic` in packages/infrastructure/analysis/perspectives/*_agent.py returns 0 (D-074 preservation)
  - L10: grep for 50+ char substring match between F.2 JSON content and ai-hedge-fund source returns 0 (DD-10 pattern-port attestation)

**Rationale**:
- **ADR landing tier discipline**: IMPL-tier ADR per master plan-033 § E.2 ADR landing line "D-075 PROPOSED at IMPL tier"
- **Empirical close-verify**: dev populates at commit; verifier S379 RE-RUNS the 10 checks as gate suite (mirrors D-074 § Empirical close-verify pattern)

---

## E. Sub-track decomposition (D1-D5 with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract)

### D1 — PerspectiveRole StrEnum extension (BLOCKING for D2+D3+D4)

- **type**: IMPL (dev surgical edit)
- **parallel_with**: [] (foundation)
- **blocks_on**: [] (root)
- **coordination_paths_exclusive**: [`packages/domain/analysis/models/perspective_analysis.py`]
- **estimated_wall_min**: ~2-5 min
- **DoD**:
  - [ ] D1.1 `PerspectiveRole` StrEnum has 9 values: BEAR/BULL/QUANT/MACRO/BEHAVIOR/MANAGER/**BUFFETT**/**GRAHAM**/**TALEB** (3 new values added at lines 38-40 after existing MANAGER per logical grouping; OR appended at end — dev decision)
  - [ ] D1.2 `PerspectiveRole.BUFFETT.value == "buffett"` (lowercase per existing convention; matches role_id in JSON files)
  - [ ] D1.3 `PerspectiveRole.GRAHAM.value == "graham"`
  - [ ] D1.4 `PerspectiveRole.TALEB.value == "taleb"`
  - [ ] D1.5 mypy --strict exit 0 + existing test_synthesizer.py + test_use_case.py STILL PASS (regression floor)

**Code stub** (for dev reference):

```python
class PerspectiveRole(StrEnum):
    BEAR = "bear"
    BULL = "bull"
    QUANT = "quant"
    MACRO = "macro"
    BEHAVIOR = "behavior"
    MANAGER = "manager"
    BUFFETT = "buffett"  # F.2 plan-035
    GRAHAM = "graham"    # F.2 plan-035
    TALEB = "taleb"      # F.2 plan-035
```

### D2 — `BuffettPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/buffett_agent.py`

- **type**: IMPL (dev new file)
- **parallel_with**: [D3, D4] (disjoint file scope; all 3 persona adapters mutually independent post-D1 ship)
- **blocks_on**: [D1] (PerspectiveRole.BUFFETT must exist)
- **coordination_paths_exclusive**: [`packages/infrastructure/analysis/perspectives/buffett_agent.py`]
- **estimated_wall_min**: ~15-20 min
- **DoD**:
  - [ ] D2.1 `BuffettPerspectiveAgent` class at `packages/infrastructure/analysis/perspectives/buffett_agent.py:?` with `__init__(adapter, role_pack)` signature per DD-8
  - [ ] D2.2 `async def analyze(ticker, context, _role) -> PerspectiveAnalysis` mirrors bear_agent.py:213-231 shape
  - [ ] D2.3 `async def _analyze_with_retry(prompt, context, ticker) -> PerspectiveAnalysis` mirrors bear_agent.py:233-334 with 3-attempt loop + cumulative cost + validation-exhausted WARNING
  - [ ] D2.4 `_validate_buffett_output(raw, role_pack)` enforces (a) valid JSON, (b) non-empty key_points list, (c) per-point category+as_of+text fields, (d) ≥role_pack.min_distinct_categories distinct categories from role_pack.category_universe (NEW per-persona check vs bear's hardcoded categories)
  - [ ] D2.5 `_parse_grounded_points(raw_points)` + `_filter_by_jaccard(points)` helpers (re-implemented per DD-3 NO shared base class)
  - [ ] D2.6 module-level `__all__ = ["BuffettPerspectiveAgent"]` (SYSTEM_PROMPT REMOVED from module-level vs bear_agent.py:36; system_prompt_template lives in role_pack JSON per DD-5/DD-10)
  - [ ] D2.7 mypy --strict + ruff + pytest exit 0

### D3 — `GrahamPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/graham_agent.py`

- **type**: IMPL (dev new file)
- **parallel_with**: [D2, D4]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [`packages/infrastructure/analysis/perspectives/graham_agent.py`]
- **estimated_wall_min**: ~15-20 min
- **DoD**: mirror D2.1-D2.7 with GRAHAM persona

### D4 — `TalebPerspectiveAgent` at `packages/infrastructure/analysis/perspectives/taleb_agent.py`

- **type**: IMPL (dev new file)
- **parallel_with**: [D2, D3]
- **blocks_on**: [D1]
- **coordination_paths_exclusive**: [`packages/infrastructure/analysis/perspectives/taleb_agent.py`]
- **estimated_wall_min**: ~15-20 min (slight novelty for fragility category mapping)
- **DoD**: mirror D2.1-D2.7 with TALEB persona

### D5 — JSON content + tests + ADR + README append (parallel components post-D2/D3/D4 ship)

- **type**: IMPL (multi-component)
- **parallel_with**: [] (single sub-track; internal components parallel-eligible)
- **blocks_on**: [D2, D3, D4] (tests need persona classes; JSON shape needs RolePromptPack adapter signature)
- **coordination_paths_exclusive**: [
    `agent-workspace/role-packs/buffett.json`,
    `agent-workspace/role-packs/graham.json`,
    `agent-workspace/role-packs/taleb.json`,
    `packages/infrastructure/analysis/perspectives/test_buffett_agent.py`,
    `packages/infrastructure/analysis/perspectives/test_graham_agent.py`,
    `packages/infrastructure/analysis/perspectives/test_taleb_agent.py`,
    `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md`,
    `agent-workspace/role-packs/README.md` (APPEND only)
  ]
- **estimated_wall_min**: ~20-30 min (JSON authoring + 3 test files + ADR + README append)
- **DoD**:
  - [ ] D5.1 `agent-workspace/role-packs/buffett.json` exists + 10 fields per RolePromptPack DD-7 + loadable via `PersonaRegistry.load_from_json(Path("agent-workspace/role-packs/buffett.json"), base_dir=Path("agent-workspace/role-packs/"))`
  - [ ] D5.2 `agent-workspace/role-packs/graham.json` exists + 10 fields + loadable
  - [ ] D5.3 `agent-workspace/role-packs/taleb.json` exists + 10 fields + loadable
  - [ ] D5.4 `test_buffett_agent.py` has ≥12 TC mirroring test_bear_agent.py shape per DD-9
  - [ ] D5.5 `test_graham_agent.py` has ≥12 TC
  - [ ] D5.6 `test_taleb_agent.py` has ≥12 TC
  - [ ] D5.7 ADR D-075 PROPOSED with frontmatter + Decision + Pattern source + Empirical close-verify + Revisit triggers + Files modified
  - [ ] D5.8 README at `agent-workspace/role-packs/README.md` § 3 personas appended (~30 LOC documenting buffett/graham/taleb packs now populated; references ADR D-075)
  - [ ] D5.9 Per-persona JSON conviction_guidance does NOT contain "%" character OR "0-100" OR "90-100" (Rule 16 mode 1 categorical enforcement; grep assertion)
  - [ ] D5.10 mypy + ruff + pytest exit 0 across all 3 new test files + ADR markdown unchanged

---

## F. Definition of Done (S378 dev) — ≥22 items

DoD for S378 IMPL session:

### File creation (10 items)
- [ ] **DC-FILE-1** `packages/domain/analysis/models/perspective_analysis.py` extended with 3 new enum values per D1.1
- [ ] **DC-FILE-2** `packages/infrastructure/analysis/perspectives/buffett_agent.py` exists per D2.1 (~210 LOC)
- [ ] **DC-FILE-3** `packages/infrastructure/analysis/perspectives/graham_agent.py` exists per D3 (~210 LOC)
- [ ] **DC-FILE-4** `packages/infrastructure/analysis/perspectives/taleb_agent.py` exists per D4 (~220 LOC)
- [ ] **DC-FILE-5** `agent-workspace/role-packs/buffett.json` exists per D5.1 (~45 LOC)
- [ ] **DC-FILE-6** `agent-workspace/role-packs/graham.json` exists per D5.2 (~45 LOC)
- [ ] **DC-FILE-7** `agent-workspace/role-packs/taleb.json` exists per D5.3 (~45 LOC)
- [ ] **DC-FILE-8** `packages/infrastructure/analysis/perspectives/test_buffett_agent.py` exists per D5.4 (~280 LOC + ≥12 TC)
- [ ] **DC-FILE-9** `packages/infrastructure/analysis/perspectives/test_graham_agent.py` exists per D5.5 (~280 LOC + ≥12 TC)
- [ ] **DC-FILE-10** `packages/infrastructure/analysis/perspectives/test_taleb_agent.py` exists per D5.6 (~280 LOC + ≥12 TC)

### ADR + README (2 items)
- [ ] **DC-DOC-1** `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` PROPOSED per D5.7
- [ ] **DC-DOC-2** `agent-workspace/role-packs/README.md` § 3 personas appended per D5.8

### Gates (8 items)
- [ ] **DC-GATE-1** mypy --strict exit 0 on packages/infrastructure/analysis/perspectives/ + packages/application/analysis/ + packages/domain/analysis/models/
- [ ] **DC-GATE-2** ruff exit 0 on same scope
- [ ] **DC-GATE-3** pytest exit 0 on packages/infrastructure/analysis/perspectives/test_buffett_agent.py + test_graham_agent.py + test_taleb_agent.py (≥36 TC across 3 files)
- [ ] **DC-GATE-4** Existing test_bear_agent.py (12 TC) + test_quant_agent.py (10 TC) STILL PASS unchanged (regression floor)
- [ ] **DC-GATE-5** Existing test_adapter.py (12 TC) + test_synthesizer.py (9 TC) + test_use_case.py + test_phase1_data_gatherer.py STILL PASS unchanged
- [ ] **DC-GATE-6** Grep `import anthropic|from anthropic` in packages/infrastructure/analysis/perspectives/*_agent.py returns 0 (D-074 preservation)
- [ ] **DC-GATE-7** Grep `%` OR `0-100` OR `90-100` in role-packs/buffett.json / graham.json / taleb.json `conviction_guidance` field returns 0 (Rule 16 mode 1 enforcement per D5.9)
- [ ] **DC-GATE-8** Grep for 50+ char substring match between F.2 JSON content (system_prompt_template + conviction_guidance fields) and ai-hedge-fund source at C:/htdocs/research/ai-hedge-fund/src/agents/<persona>.py returns 0 (DD-10 pattern-port attestation)

### STEP 0 (5 items per § C)
- [ ] **DC-STEP0-1** Sub-step 0.1 F.1 substrate availability checks PASS (8 checks)
- [ ] **DC-STEP0-2** Sub-step 0.2 ai-hedge-fund reference READ + principles extracted; ZERO verbatim copy attested
- [ ] **DC-STEP0-3** Sub-step 0.3 V0 JSON shape conformance (9 invariants × 3 personas)
- [ ] **DC-STEP0-4** Sub-step 0.4 Vietnam-relevance audit (≥150 chars × 3 personas)
- [ ] **DC-STEP0-5** Sub-step 0.5 grep audit (6 checks)
- [ ] **DC-STEP0-6** Sub-step 0.6 STEP 0 summary written to observation file

### Bookkeeping (5 items)
- [ ] **DC-BOOK-1** Session log `agent-workspace/memory/sessions/2026-05-NN-session-378.md` written
- [ ] **DC-BOOK-2** Observation `agent-workspace/memory/observations/sandwich-dev-S378-bc-8-first-3-personas.md` written
- [ ] **DC-BOOK-3** Mistake-log digest entry OR "no mistakes" explicit
- [ ] **DC-BOOK-4** current-execution.md updated with S377-S378 row (architect PLAN ship + dev IMPL ship)
- [ ] **DC-BOOK-5** Plan-035 MOVED from `pending/` to `completed/` at S379 close (NOT at S378 close — verifier acceptance gates the move)

### Charter compliance (4 items)
- [ ] **DC-CHARTER-1** 0 charter writes (PROJECT_CHARTER.md untouched)
- [ ] **DC-CHARTER-2** 0 constitution writes (agent-workspace/constitution/** untouched)
- [ ] **DC-CHARTER-3** 0 human-workspace writes (except STOP-FINDING-S378-* IF STEP 0 triggers fire — conditional path)
- [ ] **DC-CHARTER-4** I-S1 + I-S1-1 (Rule 16 mode 1) + I-S2 + I-S11 + I-S22 + I-S35 all preserved by construction (per D-074 substrate + DD-1 through DD-10)

**Total**: 34 distinct DoD items (10 file + 2 doc + 8 gate + 6 step0 + 5 book + 4 charter; ≥22 floor satisfied)

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why MIRROR D-054 BearPerspectiveAgent shape exactly vs author novel persona-pack pattern?

**Answer**: Per DD-8. D-054 retry-validator shape is shipped + stable + tested (12 TC for BEAR + 10 TC for QUANT); 3 attempts + re-prompt with error + cumulative cost + validation-exhausted WARNING + empty PerspectiveAnalysis on triple-fail is empirically proven for ~6 months. Novelty would invite untested failure modes. Pattern parity also enables future shared-base-class refactor in sub-plan 037-V2 if AP-23 2nd-instance trigger fires.

### AQ-2 — Why per-persona category_universe vs unified 12-category union?

**Answer**: Per DD-4. Each persona's analytical framework is fundamentally different (Buffett quality/moat vs Graham quantitative-conservative vs Taleb tail-risk/asymmetry); unified category would lose per-persona signal. 6 categories per persona with `min_distinct_categories = 3` provides 2× headroom without forcing exhaustive coverage. Direct mapping to ai-hedge-fund reasoning checklists preserves pattern-port discipline.

### AQ-3 — Why NO shared `_base_persona_agent.py` ABC OR Mixin?

**Answer**: Per DD-3 + AP-23 first-instance HOLD. 3 personas worth of duplication (~210 LOC × 3 = ~630 LOC total; ~60% identical skeleton) is manageable. Shared-base would require refactoring existing bear_agent.py + bull_agent.py + quant_agent.py (blast radius outside F.2 scope; violates Karpathy P3 surgical-changes). Promote-to-shared-base trigger fires at AP-23 2nd instance (sub-plan 037 V0=9 ratification adding 3+ more personas = 6+ persona files → shared-base refactor sub-plan 037-V2).

### AQ-4 — Why PerspectiveRole enum extension vs role_id-only routing?

**Answer**: Per DD-1. Type-safety preservation; existing PerspectiveAnalysis.role: PerspectiveRole field at perspective_analysis.py:55 is StrEnum-typed; role_id-only would require type widening (breaking change to ~10 call sites). PersonaRegistry.get(role_id) uses str key (conceptually decoupled from PerspectiveRole enum; happens to match string values). Sub-plan 037 V0=9 expansion adds MUNGER/LYNCH/VN_DOMAIN_SPECIALIST values cleanly.

### AQ-5 — Why 'claude-sonnet-4-6' for all 3 personas vs per-persona model variation?

**Answer**: Per DD-7 + master plan-033 DD-12. Value-investor reasoning (Buffett/Graham/Taleb) ≠ Opus-class computational reasoning (QUANT). Sonnet sufficient for qualitative reasoning per A-01 § 3 C9 Buffett pattern. Cost-routing: 5 Sonnet personas + 1 Opus (QUANT) keeps per-thesis cost within budget (~$30/MTok cumulative input cost for V0=6 estimate). Per-persona model variation deferred to F.4-V2 IF F.5 dogfood surfaces empirical evidence (e.g. Taleb consistently produces shallow reasoning at Sonnet → upgrade to Opus for tail-risk persona).

### AQ-6 — STEP 0 finds Vietnam-relevance WEAK for one persona — what then?

**Answer**: Per § C.0.4 explicit STOP-AND-ASK trigger. Author `human-workspace/notifications/STOP-FINDING-S378-0.4-vietnam-relevance-too-weak-<persona>.md` with named options: (a) swap persona with stronger VN-relevance alternative (e.g. MICHAEL_BURRY housing-bubble for Vietnam real estate context); (b) accept weak vietnam_notes for V0 with named revisit trigger; (c) defer F.2 ship pending more VN domain research. Main session decides via AskUserQuestion gate.

### AQ-7 — S378 dev work exceeds 150K Opus FOCUSED_IMPL cap — when to SPLIT?

**Answer**: SPLIT trigger fires if cumulative tokens exceed 145K at start of D5 (tests authoring). SPLIT path: (a) commit D1+D2+D3+D4 + ADR D-075 partial state to git via D-060; (b) dispatch fresh-context S379-dev for D5 (JSON authoring + tests + README append + final ADR completion); (c) S380 sandwich-verifier AP-1 reviews S378+S379 cumulative output. Architect notes: 3-parallel D2+D3+D4 dispatch via fresh-context sub-agents could reduce wall time but each sub-agent counts ~30-40K tokens (would total ~120K parallel + ~50K main = 170K; SPLIT preferred).

### AQ-8 — F.3 sub-plan 036 has dependency on F.2 personas — what's the boundary?

**Answer**: F.2 ships per-persona ADAPTERS + REGISTERED via PersonaRegistry (in tests + future composition root). F.3 ships use case + Phase1Synthesizer generalization to dispatch N≥4 personas. Boundary: F.2 ships `BuffettPerspectiveAgent` class + `buffett.json` content; F.3 wires `PersonaRegistry.load_from_json` calls at composition root + `asyncio.gather(buffett_t, graham_t, taleb_t, bear_t, bull_t, quant_t)` in `validate_thesis_phase1.py`. F.2 explicitly OUT-OF-SCOPE for composition-root wiring per § A.2 item 13.

### AQ-9 — What if Vietnam-relevance audit reveals VHM/VIC/specific ticker references are misleading?

**Answer**: vietnam_notes content is ASPIRATIONAL guidance for the LLM (per-persona prompt context), not authoritative VN domain assertion. If specific ticker references prove misleading (e.g. claim "VinGroup moat = durable" when post-hoc analysis shows cross-holding fragility), update via VL-V2 refinement sub-plan (e.g. F.5 dogfood empirical evidence → vietnam_notes content update). V0 ships best-effort content with explicit "VN domain expertise is V0 limited" caveat in ADR D-075.

### AQ-10 — What if F.2 prompt drafts surface LLM emitting buy/sell prose despite I-S35 mandate?

**Answer**: Per § M CHARTER-TIER GATE clause. STEP 0 STOP-AND-ASK trigger fires (`STOP-FINDING-S378-0.4-i-s35-buysell-leak-<persona>.md`); HALT pending main-session AskUserQuestion gate. Mitigation: per-persona conviction_guidance text rubric per DD-5 EXPLICITLY says "Pick categorical — do NOT emit numeric percentage" but does NOT explicitly forbid buy/sell prose; ADR D-075 § Empirical close-verify L11 (added at IMPL): grep persona output for "buy"|"sell"|"recommendation" text → if positive → re-prompt with I-S35 reminder. Charter implication: NONE (Recommendation enum already operationalizes I-S35 at Thesis aggregate level; per-persona output is reasoning + key_points, not final recommendation).

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (architect plan) | Source 2 (master plan-033) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | PerspectiveRole enum extension per DD-1 | THIS plan § D DD-1 (3 new enum values BUFFETT/GRAHAM/TALEB) | master plan-033 § E.2 sub-plan 035 contract line 503 ("First 3 personality-pack adapters Buffett/Graham/Taleb") + DD-2 V0=6 line 286 | I-S11 (multi-perspective synthesis ≥2 minimum) — F.2 + existing 3 active = 6 personas | `packages/domain/analysis/models/perspective_analysis.py:30-39` PerspectiveRole 6-value StrEnum (pattern for extension) | (none — no external precedent for enum-driven persona dispatch; ai-hedge-fund uses dict registry instead per analysts.py:25-178) |
| 2 | D-054 retry-validator MIRROR per DD-8 | THIS plan § D DD-8 (per-persona retry-validator mirrors bear_agent shape exactly) | master plan-033 § E.2 sub-plan 035 DoD floor line 513 ("retry-validator tests + Jaccard distinctness + I-S10-or-equivalent category-distinctness gate") | I-S10 (bear case substantive ≥3 distinct categories) generalized to per-persona min_distinct_categories invariant | `packages/infrastructure/analysis/perspectives/bear_agent.py:198-334` BearPerspectiveAgent class + retry-validator + helpers | D-054 ACCEPTED ADR (referenced via bear_agent.py:6-14 docstring; A2-mirror pattern from D-053 BullPerspectiveAgent) |
| 3 | Rule 16 mode 1 conviction_guidance per DD-5 | THIS plan § D DD-5 (per-persona text rubric instructing categorical pick; explicit "do NOT emit numeric percentage") | master plan-033 § C.0.4 Rule 16 surface audit + DD-2 line 326 ("Buffett 90-100 rubric per A-01 § 3 C9 REJECTED") | I-S1 (NO LLM math) + I-S1-1 + Rule 16 mode 1 (categorical surrogate via Conviction StrEnum at conviction.py:17-22) | `packages/domain/analysis/value_objects/conviction.py:17-22` Conviction StrEnum STRONG/MODERATE/WEAK + bear_agent.py:62 "Each bear point declares conviction in {STRONG, MODERATE, WEAK}" SYSTEM_PROMPT enforcement | A-01 § 3 C9 Buffett confidence rubric 90-100/70-89/etc. (REJECTED per Rule 16 mode 1 in this sub-plan; pattern documented but not adopted) |
| 4 | Pattern-port not code-port per DD-10 + LICENSE caveat | THIS plan § D DD-10 (50+ char substring match verification gate; architect-extracted principles list in § C.0.2) | master plan-033 hard_rules_acknowledged line "ai-hedge-fund LICENSE-file caveat per A-01 § 6" + § C.0.3 "ZERO verbatim copy of warren_buffett.py / analysts.py / portfolio_manager.py" | D-061 § Item 4 (license-audit discipline for external pattern adoption) | F.1 plan-034 § hard_rules_acknowledged "ai-hedge-fund LICENSE-file caveat per A-01 § 6" — pattern carries forward | A-01 § 6 LICENSE-file MISSING attestation: "Pattern-only adoption (C1, C2, C3, C9, C11, C12): no legal issue ... Recommendation: re-implement from scratch using the pattern documented here; do not copy file contents" |
| 5 | Per-persona category_universe per DD-4 | THIS plan § D DD-4 (Buffett 6-cat / Graham 6-cat / Taleb 6-cat persona-distinct lists) | master plan-033 DD-2 line 292-295 Vietnam-relevance evidence chain per persona | I-S10 (bear case ≥3 distinct categories) generalized to per-persona min_distinct_categories via RolePromptPack | `packages/infrastructure/analysis/perspectives/bear_agent.py:59-60` SYSTEM_PROMPT BEAR categories `{FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}` (6-cat pattern precedent) | ai-hedge-fund warren_buffett.py:775-781 + ben_graham.py:298-310 + nassim_taleb.py:710-716 reasoning checklists (pattern-port, NOT verbatim copy per DD-10) |

---

## I. STEP 0 STOP-AND-ASK trigger inventory (5 documented)

S378 dev MUST author `human-workspace/notifications/STOP-FINDING-S378-<sub-step>-<reason>.md` IF any of the following triggers fires, AND HALT pending main-session AskUserQuestion gate:

### CHARTER-TIER triggers (1)

- **§ M trigger** (CHARTER-TIER): If F.2 prompt drafts surface LLM emitting "buy" / "sell" / "recommendation" prose despite I-S35 mandate → STOP-FINDING-S378-0.4-i-s35-buysell-leak-<persona>.md + HALT

### TACTICAL-TIER triggers (4)

- **§ C.0.1 trigger** (BLOCKING): F.1 substrate regression — D-074 attestation state drift (e.g. `import anthropic` re-introduced; existing perspective tests fail) → STOP-FINDING-S378-0.1-f1-substrate-regression.md + HALT

- **§ C.0.2 trigger** (CONDITIONAL): Vietnam-relevance weak for any persona (cannot ground in any verifiable VN-specific phenomenon) → STOP-FINDING-S378-0.2-vietnam-relevance-weak-<persona>.md + HALT pending architect refinement OR persona swap

- **§ C.0.3 trigger** (BLOCKING): RolePromptPack invariant violation during JSON authoring (any of 9 invariants per `__post_init__` fails) → STOP-FINDING-S378-0.3-rolepromptpack-invariant-violation-<persona>.md + HALT pending JSON content fix

- **§ C.0.4 trigger** (BLOCKING per dispatch brief explicit): If any persona's Vietnam-relevance proves WEAK during empirical authoring (vietnam_notes <100 chars OR generic "Vietnam emerging market" boilerplate) → STOP-FINDING-S378-0.4-vietnam-relevance-too-weak-<persona>.md with named options (a) swap persona / (b) accept weak with revisit trigger / (c) defer F.2 ship + HALT

---

## J. Risks & Mitigation (RM1-RM10 + RM-AS-2 carry-forward from F.1)

### RM1 — Per-persona prompt template authoring quality variance (LIKELY-MEDIUM)
**Risk**: Buffett/Graham/Taleb prompt template authoring quality may vary; per-persona retry-validator semantics may not satisfy on all 3.
**Mitigation**: DD-5 per-persona conviction_guidance explicit Rule 16 mode 1 rubric; DD-4 per-persona category_universe explicit 6-element tuple; DD-6 Vietnam-relevance ≥150 char floor with STOP-AND-ASK trigger; DD-8 per-persona _validate_<persona>_output enforces RolePromptPack invariants programmatically (fail-fast for retry).

### RM2 — Per-persona JSON content authoring first-instance risk (LIKELY-MEDIUM; AP-23 first-instance HOLD)
**Risk**: 30 content decisions × 3 personas = first-instance authoring without precedent; risk of inconsistent quality across personas.
**Mitigation**: ai-hedge-fund pattern-port discipline (READ-ONLY reference per DD-10); architect-extracted principles list in § C.0.2 documents per-persona decision input; DD-4/DD-5/DD-6 explicit content authoring guidance constrains decision space; AP-23 2nd-instance trigger at sub-plan 037 V0=9 ratification fires shared-base-class refactor calculus.

### RM3 — D-074 substrate regression (LIKELY-LOW; STEP 0.1 mitigated)
**Risk**: F.2 dev introduces `import anthropic` OR mutates `_default_transport` OR otherwise breaks D-074 attestation state.
**Mitigation**: § C.0.1 BLOCKING checks 8 attestation criteria + § C.0.5 grep audit + DC-GATE-6 grep assertion + DC-GATE-7+8 ai-hedge-fund pattern-port verification.

### RM4 — Catastrophic mix pattern (CRITICAL-LOW; mitigated by sub-plan structure)
**Risk**: Bundling F.2 + F.3 work in single session = Session 4 catastrophic failure mode.
**Mitigation**: This sub-plan EXPLICITLY OUT-OF-SCOPES F.3 work (§ A.3 deferral table + § A.2 item 13); composition root wiring left for sub-plan 036.

### RM5 — Existing BC-8 test regression (LIKELY-MEDIUM; DC-GATE-4+5 mitigated)
**Risk**: F.2 modifications to PerspectiveRole enum may surface test regression in existing test_bear_agent / test_bull_agent / test_quant_agent / test_synthesizer / test_use_case files.
**Mitigation**: D1 only ADDS new enum values (NO existing value modification); existing PerspectiveRole.BEAR/BULL/QUANT references unchanged; regression-floor TC count enforced (DC-GATE-4+5).

### RM6 — Per-persona LLM emits buy/sell prose despite Rule 16 + I-S35 (LIKELY-LOW; § M + DD-5 explicit mitigation)
**Risk**: LLM (especially Sonnet) may volunteer buy/sell recommendation prose despite categorical conviction_guidance mandate.
**Mitigation**: DD-5 conviction_guidance explicit "Pick categorical — do NOT emit numeric percentage" + D-075 § Empirical close-verify L11 grep persona output for "buy"|"sell"|"recommendation" → re-prompt with I-S35 reminder; § M CHARTER-TIER GATE trigger if surface.

### RM7 — Per-persona cost budget overrun (LIKELY-LOW; DD-7 mitigated)
**Risk**: 3 new Sonnet personas × thesis = additional ~$15-30 input cost per thesis (depends on system_prompt_template length + key_points retry overhead).
**Mitigation**: DD-7 model_id_preference 'claude-sonnet-4-6' (cheapest reasoning-capable model); F.5 dogfood empirically measures + F.4-V2 budget adjustment if needed; per-persona model override via existing role_model_overrides at claude_llm_perspective_adapter.py:201 path.

### RM8 — ai-hedge-fund pattern-port verification false-positive (LIKELY-LOW; DC-GATE-8 mitigated)
**Risk**: Grep 50+ char substring match may flag legitimate common phrases (e.g. "circle of competence" appears in both Buffett documentation and any Buffett-derived prompt).
**Mitigation**: 50-char threshold is intentionally HIGH (typical English phrase ≤30 chars); if false-positive surfaces, architect ratifies as common-domain-vocabulary (NOT verbatim code copy); ADR D-075 documents specific common phrases that flag.

### RM9 — Per-persona retry-validator empty-output flood (LIKELY-LOW; DD-8 + bear precedent mitigated)
**Risk**: Per-persona LLM repeatedly fails validation → 3 attempts × 3 personas = up to 9 LLM calls per thesis with no useful output.
**Mitigation**: D-054 BEAR has shipped stably for ~6 months with empirical ~5-15% per-attempt fail rate (cumulative ~0.1-0.4% triple-fail rate per persona); empty PerspectiveAnalysis on triple-fail is honest signal NOT silent failure (validation-exhausted WARNING logged); downstream Synthesis handles empty perspectives gracefully via existing I-S12 disagreement-surfaced-not-resolved logic.

### RM10 — Persona-pack JSON content drift over time (LIKELY-MEDIUM; deferred AP-7)
**Risk**: Per-persona JSON content (system_prompt_template + conviction_guidance + vietnam_notes) may drift over time as Vietnam market structure evolves; no auto-refresh mechanism.
**Mitigation**: V0 ships static JSON content; explicit revisit trigger per AP-7 named in ADR D-075 (Phase F-prime-V2 / quarterly refresh / project-owner-driven update via direct JSON edit); F.5 dogfood empirically tests V0 content; F.4 V0=9 expansion adds VN_DOMAIN_SPECIALIST per master plan § K.1.a.

### RM-AS-2 — D-052 § Implementation step 3 pyproject drop carry-forward (LIKELY-NONE this plan)
**Risk**: F.1 deferred D-052 step 3 pyproject anthropic dep removal; carries forward.
**Mitigation**: F.2 introduces ZERO new anthropic dependency surface; D-052-V2 cleanup ADR remains separate scope; verifier S379 acknowledges as known-deferred not defect (inherited from F.1 D-074).

---

## K. Coordination paths (off-limits during S378 IMPL session)

When main session dispatches S378 dev IMPL, the following paths are EXCLUSIVELY owned by S378 dev (main session SHOULD NOT touch concurrently):

**S378 dev exclusive write paths**:
- `packages/domain/analysis/models/perspective_analysis.py` (D1 enum extension)
- `packages/infrastructure/analysis/perspectives/buffett_agent.py` (D2 NEW)
- `packages/infrastructure/analysis/perspectives/graham_agent.py` (D3 NEW)
- `packages/infrastructure/analysis/perspectives/taleb_agent.py` (D4 NEW)
- `agent-workspace/role-packs/buffett.json` (D5.1 NEW)
- `agent-workspace/role-packs/graham.json` (D5.2 NEW)
- `agent-workspace/role-packs/taleb.json` (D5.3 NEW)
- `packages/infrastructure/analysis/perspectives/test_buffett_agent.py` (D5.4 NEW)
- `packages/infrastructure/analysis/perspectives/test_graham_agent.py` (D5.5 NEW)
- `packages/infrastructure/analysis/perspectives/test_taleb_agent.py` (D5.6 NEW)
- `agent-workspace/memory/decisions/075-bc-8-first-3-personas.md` (D5.7 NEW)
- `agent-workspace/role-packs/README.md` (D5.8 APPEND only — main session may READ but not WRITE)
- `agent-workspace/memory/observations/sandwich-dev-S378-bc-8-first-3-personas.md` (S378 observation)
- `agent-workspace/memory/sessions/2026-05-NN-session-378.md` (session log)
- `human-workspace/notifications/STOP-FINDING-S378-*.md` (CONDITIONAL — only if STEP 0 triggers fire)

**Main session may write/edit**:
- `agent-workspace/memory/current-execution.md` (S377-S378 row updates)
- `agent-workspace/memory/mistake-log.md` (digest entry append)
- `agent-workspace/memory/checkpoints/latest.md` (handoff state)
- `human-workspace/notifications/latest.md` (handoff)

If main session needs to TOUCH any S378-exclusive path (e.g. urgent harness fix in same file), main session dispatches a coordination subagent OR waits for S378 dev return.

---

## L. Conditional next-step branches (L.1-L.5)

Per dispatch brief AP-7 anti-vacuous-defer + autonomous-full mode, the architect names explicit next-step branches based on S378 dev outcome:

### L.1 — S378 dev returns PASS (no defects; all DoD ✓)

Main session:
1. Commit S378 dev output via `git add` + `git commit` per D-060 (architect has no Bash; main session commits S378 dev's output AND this plan-035's frontmatter ratification)
2. Dispatch S379 sandwich-verifier AP-1 fresh-context for adversarial review
3. Plan-035 stays in `pending/` until S379 verifier PASS

### L.2 — S378 dev returns PASS-WITH-CONCERNS (minor defects; merge-eligible)

Main session:
1. Apply F1+F2 minor remediation INLINE per verifier mandate (NOT self-review per AP-1)
2. Commit S378 dev output + remediation
3. Dispatch S379 sandwich-verifier AP-1 anyway (defense-in-depth)

### L.3 — S378 dev returns BLOCKED (STEP 0 STOP-AND-ASK triggered)

Main session:
1. Read `human-workspace/notifications/STOP-FINDING-S378-*.md` file authored by S378 dev
2. Author AskUserQuestion bundle item per § M CHARTER-TIER GATE
3. User picks → ADR drafted at proposal/ tier (if charter-tier) OR architect refinement (if tactical-tier)
4. Resume S378 IMPL after option ratified

### L.4 — S378 dev returns FAILED (critical defects; non-merge-eligible)

Main session:
1. Read S378 dev observation file for defect inventory
2. Dispatch S379 RECOVERY sub-plan author OR revert S378 commits via git revert
3. Reassess F.2 sub-plan scope (may split into sub-plan 035a + 035b per AQ-7)

### L.5 — S378 dev SPLIT (cumulative tokens >145K mid-IMPL per AQ-7)

Main session:
1. S378 dev commits D1+D2+D3+D4 + ADR D-075 partial state via D-060
2. Dispatch S379-dev fresh-context for D5 (JSON authoring + tests + README append + ADR completion)
3. S380 sandwich-verifier AP-1 reviews S378+S379 cumulative output

---

## M. CHARTER-TIER GATE clause (LIKELY-NONE per master plan — 0 BLOCKING expected)

Per master plan-033 § K.2 sub-plan 035 row:

> Sub-plan 035 (F.2 First 3 personas):
> - BUFFETT/GRAHAM/TALEB per-persona prompt template surfaces "interpretation creep" (LLM volunteers buy/sell prose bypassing Recommendation enum) → I-S35 violation surface → FLAG mandatory if surfaced; sub-plan 035 STEP 0 STOP-AND-ASK
> - TALEB tail-risk prompt template requires numeric VaR-output → I-S1-1 violation surface; refactor to deterministic-pipeline echo (VaR computed by code, persona interprets) → no charter touch (Rule 16 mode 2 already operationalized)

**This sub-plan's CHARTER-TIER GATE clause**:

THIS sub-plan EXPECTS 0 CHARTER-TIER BLOCKING flags during S378 IMPL execution because:
- DD-5 conviction_guidance text rubric EXPLICITLY instructs categorical pick (Rule 16 mode 1 enforcement via prompt content)
- DD-1 PerspectiveRole enum extension preserves I-S35 by-construction (Recommendation enum at Thesis aggregate level unchanged)
- DD-10 pattern-port discipline avoids verbatim copy of A-01 § 3 C9 90-100 numeric rubric

**Mandatory STOP-AND-ASK trigger if surfaced**:
- TC-<persona>-N test surfaces LLM emitting "buy" / "sell" / "recommend" prose despite categorical instructions → § I trigger fires (`STOP-FINDING-S378-0.4-i-s35-buysell-leak-<persona>.md`); HALT pending AskUserQuestion gate
- TC-<persona>-N test surfaces LLM emitting numeric 0-100 percentage despite Rule 16 mode 1 instructions → § I trigger fires (`STOP-FINDING-S378-0.4-numeric-rubric-leak-<persona>.md`); HALT

**Mitigation if surfaced**: per-persona prompt template refinement (re-prompt with stronger Rule 16 mode 1 / I-S35 reminder); ADR D-075 documents per-persona refinement iteration; sub-plan 035-V2 may be authored if refinement requires architect-tier scope work.

---

## N. Compliance attestation (S377 PLAN authoring session)

- harness_priority_one ✓ (no harness gap surfaced THIS session; L-S354-2/L-S366-4/L-S369-1 planner-stats carry-forward noted in § A.4)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 22 source files read inline)
- AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations this session; shared-base-class FLAGGED for first-instance HOLD per DD-3; promotion-on-2nd-recurrence calculus respected for sub-plan 037 V0=9 path)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = plan + observation; main session dispatches S378 dev IMPL per § N sequencing)
- stop_offering_routing_branches ✓ (L.1-L.5 conditional next-step branches in § L are STRUCTURAL advice based on S378 dev OUTCOME — not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-074 not modified (F.1 ACCEPTED state preserved; F.2 INHERITS closed BC-8 substrate)
- D-052 not modified (§ Implementation step 1 CLOSED via D-074; F.2 introduces ZERO new anthropic surface)
- D-066 not touched (CrawlerAdapter ABC INFORMATIONAL precedent; DD-3 chose NO shared base class for F.2 per AP-23 first-instance HOLD)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (agent-workspace/constitution/** untouched)
- 0 human-workspace writes ✓ (plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING file is CONDITIONAL S378 path NOT S377)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- I-S1 ✓ (this plan PROMOTES I-S1 satisfaction in Theme H F.2 implementation per DD-5; does not violate)
- I-S1-1 (Rule 16) ✓ (per § C.0.3 + DD-5 conviction_guidance text rubric mode 1 categorical; explicit "do NOT emit numeric percentage" instruction)
- I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain + VBW source file enumeration in § A.4)
- I-S10 ✓ (BEAR-specific invariant preserved; per-persona min_distinct_categories generalization via RolePromptPack)
- I-S11 ✓ (F.2 + existing 3 active = 6 personas registered; ≥4 high-confidence threshold satisfied)
- I-S22 ✓ (per-persona PerspectiveAnalysis.prompt_hash preserved per existing adapter)
- I-S35 ✓ (per-persona output is reasoning + key_points NOT buy/sell; Recommendation enum at Thesis aggregate level unchanged; § M CHARTER-TIER GATE clause mandatory if surfaced)
- Phase 1b NARROW PRECEDENT explicit per § A.4 (n=1 multi-perspective-impl from S375)
- 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- ai-hedge-fund LICENSE-file caveat A-01 § 6 ACKNOWLEDGED + pattern-port not code-port mandate per DD-10 ✓
- F.1 substrate (RolePromptPack + PersonaRegistry + transport-flip) CONSUMED per § C.0.1 BLOCKING checks
- DC-GATE-6/7/8 grep verification gates documented for S378 dev attestation
- 34 DoD items per § F enumerated (≥22 floor satisfied)

---

**END OF PLAN 035-S377-PHASE-F2-PERSONAS-BUFFETT-GRAHAM-TALEB**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches S378 sandwich-dev FOCUSED_IMPL per § E sequencing.
