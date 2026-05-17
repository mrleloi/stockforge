---
plan_id: 034-S374-phase-f1-roleprompt-persona-transport
target_session: S375 (dev IMPL session; THIS plan = S374 architect output)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S374; IMPL by sandwich-dev at S375; VERIFY by sandwich-verifier AP-1 at S376)
budget:
  - this PLAN session (S374 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (cold-start declared for task_class="multi-perspective-impl"; nearest analog vietnamese-nlp-impl n=3 from S362+S365+S368 ALL clean cycles)
  - sub-plan IMPL (S375 dev): ~100-150K Opus FOCUSED_IMPL per recalibrated table
  - sub-plan VERIFY (S376 verifier): ~30-60K Opus AP-1 fresh-context
phase: F-prime (Theme H — BC-8 Multi-Perspective Primitives; sub-theme F.1 RolePromptPack + PersonaRegistry + BC-8 transport-flip — FIRST of 5 sub-tracks per master plan-033 § E sequencing)
track: Wave 1 Theme H sub-theme F.1 — RolePromptPack foundation (frozen dataclass) + PersonaRegistry (stdlib dict + JSON loader) + BC-8 transport-flip migration MIRROR D-072 strategy (closes residual D-052 cleanup for BC-8 analysis adapter — completes D-052 spec compliance to 100% for BC-8 surface)
parent_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md (PHASE-MASTER-PLAN authored S373; THIS is the first sub-plan per § E.1 + § N sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.3 + § 6.4.3
predecessor: 033-S373-phase-fprime-multi-perspective-master-plan (master plan ratifying Phase F-prime entry; THIS sub-plan satisfies § E.1 contract per DD-4 HYBRID RolePromptPack + DD-5 BC-8 transport-flip MIRROR D-072 strategy)
successor: S375 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S376 sandwich-verifier AP-1 → sub-plan 035 (F.2 First 3 personas) at S376+ per master plan-033 § E sequencing (035 blocks_on 034; sequential ship)
architect: S374 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase F-prime first sub-plan author per master plan-033 § E.1 + § N.2 sequencing
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED variant with COLD-START declared for task_class="multi-perspective-impl" — no precedent in .planner-stats.tsv or sessions-rollup.tsv; nearest analog vietnamese-nlp-impl n=3 from S362+S365+S368 ALL clean cycles ~150-160K Sonnet / ~39min each — adapter+tests+CLI portion transfers cleanly; novel portion = RolePromptPack frozen dataclass + PersonaRegistry stdlib dict + JSON loader + BC-8 transport-flip MIRROR D-072 (cold-start window NARROW on novel portion))
executing_agent: N/A this PLAN session; S375 sandwich-dev FOCUSED_IMPL (after this sub-plan ratified) + S376 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master plan-033 § E.1 sub-plan contract (DD-4 HYBRID RolePromptPack + per-persona adapter class + DD-5 BC-8 transport-flip MIRROR D-072 + DD-6 RolePromptPack location packages/application/analysis/ + DD-7 frozen dataclass shape + DD-8 PersonaRegistry stdlib dict + YAML loader)"
  - "Master plan-033 § E.1 BLOCKS sub-plans 035/036/037/038 — F.1 is foundational"
  - "D-050 ACCEPTED CHARTER 2026-05-09 (anthropic→subagent SYSTEMIC; per CLAUDE.md user memory `anthropic_api_to_subagent`)"
  - "D-051 ACCEPTED 2026-05-09 (news-extractor refactor; SHIPPED — analysis adapter STILL outstanding per RM-AS-1 mitigation target)"
  - "D-052 ACCEPTED 2026-05-09 (anthropic SDK code-path removal + pyproject dep drop; § Implementation step 1 EXPLICITLY targets packages/infrastructure/analysis/claude_llm_perspective_adapter.py _default_transport deletion + claude_cli_transport import; S369 verifier F3 surfaced this is NOT applied — analysis adapter STILL has `import anthropic` at L80; THIS sub-plan COMPLETES D-052 § Implementation step 1)"
  - "D-072 ACCEPTED 2026-05-17 (VN claim extraction wrapper transport-flip pattern for BC-5 news; SHIPPED S368 + verified S369; DIRECTLY ANALOGOUS PRECEDENT for BC-8 perspective-adapter transport-flip — DD-5 mirror)"
  - "D-054 + D-053 (perspective adapter A2 retry-validator symmetry; bear/bull/quant agents share pattern; F.1 must preserve their `transport=stub` injection at test_bear_agent.py + test_quant_agent.py)"
  - "D-059 (Python determinism contract — R1+R2+R4) BINDING for every NEW/MODIFIED file"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S375 dev commit boundary"
  - "D-062 (atomic-write-doctrine) — applies if PersonaRegistry hot-reload added (deferred)"
  - "D-064 (path-safety 5-invariant) — applies to PersonaRegistry.load_from_json(json_path: Path)"
  - "D-065 Rule 16 (numeric-field discipline) — N/A this sub-plan (RolePromptPack ships data not numeric fields; transport-flip preserves existing PerspectiveAnalysis schema)"
  - "D-066 (CrawlerAdapter ABC PROPOSED) — INFORMATIONAL precedent for ABC-vs-Protocol decision in DD-1"
  - "D-067 PROPOSED-AT-IMPL (planner-upgrade ADR; Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 3 (Adversarial by Design) + Principle 7 (Dogfood) + Principle 9 (NO LLM math) + Principle 11 (firing-test mandate IF a hook is shipped — NO new hook this bundle)"
  - "I-S1 (NO LLM math) — F.1 ships data-structure + transport-flip; LLM-output path UNCHANGED; satisfied by construction"
  - "I-S1-1 + Rule 16 mode 1 (categorical surrogate via Conviction StrEnum STRONG/MODERATE/WEAK) — UNCHANGED by F.1"
  - "I-S2 (citation discipline) — RolePromptPack.citation_requirements str field embeds per-persona Rule 6 verbatim mandate"
  - "I-S11 (multi-perspective synthesis ≥2 minimum; ≥4 for high-confidence) — F.1 preserves existing 3 active perspectives + provides foundation for F.2/F.4 expansion to N≥4"
  - "I-S22 (data lineage) — PerspectiveAnalysis.prompt_hash already records sha256[:16] per existing claude_llm_perspective_adapter.py:221; F.1 transport-flip preserves audit trail"
  - "I-S34 (HARD REJECT) — N/A this sub-plan (no new HTTP fetcher; claude CLI is local subprocess); CARRIES FORWARD verifier grep-asserts"
  - "I-S35 (research-aid framing) — F.1 ships data + infrastructure; output framing UNCHANGED"
  - "anthropic_api_to_subagent memory rule (user verbatim 2026-05-09; D-050 ACCEPTED CHARTER tier) — THIS sub-plan IMPLEMENTS the rule for the BC-8 perspective-adapter path (D-052 § Implementation step 1 FINAL execution); ZERO new `import anthropic` introduced; default transport flipped from `_default_transport` (anthropic SDK lazy import at line 80) to existing `claude_cli_transport` from `packages/infrastructure/analysis/subagent_transport.py:144` (per D-052 § Implementation step 1 explicit naming + same-BC import discipline)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter + Aggregate-root invariants)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline — claude CLI substrate per BP-S43b-1/2/3 architecture.md:142-154)"

binding_decisions:
  - "PHASE 1b CONSUMED + COLD-START DECLARED for task_class='multi-perspective-impl' — nearest analog vietnamese-nlp-impl n=3 from S362+S365+S368 ALL clean cycles (adapter+tests portion transfers cleanly); novel portion = RolePromptPack + PersonaRegistry + BC-8 transport-flip (sub-component novel); directional confidence MEDIUM at n=3 analog"
  - "DD-1 ROLEPROMPTPACK CONTRACT = FROZEN DATACLASS (NOT Protocol, NOT ABC) per master plan-033 DD-7"
  - "DD-2 PERSONAREGISTRY = STDLIB DICT + JSON LOADER per master plan-033 DD-8 (pyyaml NOT in deps per architect VBW Grep; JSON loader for V0; YAML deferred per AP-7 named revisit trigger)"
  - "DD-3 ROLEPROMPTPACK LOCATION = packages/application/analysis/ package-root per master plan-033 DD-6"
  - "DD-4 BC-8 TRANSPORT FLIP = REUSE existing claude_cli_transport from subagent_transport.py per D-052 § Implementation step 1 explicit (NOT new claude_cli_perspective_transport.py file — architect-refinement of master plan-033 dispatch brief which named such file; STEP 0.1 VBW confirms subagent_transport.py:144-222 already ships matching signature)"
  - "DD-5 TRANSPORT DEFAULT FLIPPED per D-052 § Implementation step 1 + D-050 SYSTEMIC + memory rule — `_default_transport` REMOVED from claude_llm_perspective_adapter.py; `transport: Callable = field(default=_default_transport)` at L197-199 replaced with `transport: Callable = field(default=claude_cli_transport)`; `import anthropic` line at L80 REMOVED; tests inject stub transport via constructor kwarg (existing pattern unchanged)"
  - "DD-6 CONVICTION ENUM PRESERVATION — existing Conviction StrEnum STRONG/MODERATE/WEAK UNCHANGED; RolePromptPack.conviction_guidance str field embeds per-persona rubric text instructing LLM how to pick categorical"
  - "DD-7 RolePromptPack EXACT FIELD SHAPE — 10 fields per master plan-033 DD-7 lines 378-388: role_id + persona_name + system_prompt_template + conviction_guidance + citation_requirements + vietnam_notes + min_points + min_distinct_categories + category_universe + model_id_preference"
  - "DD-8 ADR D-074 PROPOSED-AT-IMPL — 'BC-8 Transport Flip + RolePromptPack + PersonaRegistry Foundation' — records (a) D-052 § Implementation step 1 FINAL closure attestation + (b) RolePromptPack contract shape + (c) PersonaRegistry pattern + (d) D-050→D-051→D-052→D-072→D-074 chain"
  - "DD-9 EXISTING `subagent_transport.py` UNCHANGED — F.1 ADOPTS its claude_cli_transport function verbatim; ZERO modification (already-shipped infrastructure)"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names prerequisites + revisit trigger"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (RolePromptPack data-driven persona pattern; PersonaRegistry stdlib-dict pattern); 2nd recurrence in sub-plans 035-038 triggers promote-to-skill calculus"
  - "Karpathy P3 surgical-changes — this sub-plan modifies ≤500 LOC across 5 files; total delta ~330 LOC within Karpathy P3 envelope"
  - "VBW protocol mandatory — S375 dev MUST READ claude_llm_perspective_adapter.py + subagent_transport.py + bear_agent.py + perspective_analysis.py + conviction.py + master plan-033 + D-052 ADR empirically"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; main commits per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S375-* is the ONLY conditional human-workspace write path AND only if STEP 0 triggers fire in S375 dev session NOT this S374 PLAN session)"
  - "no touching Phase E files — all 4 sub-themes shipped + verified"
  - "no Phase F sub-theme F.2/F.3/F.4/F.5 work in THIS sub-plan — separate sub-plans 035/036/037/038"
  - "no charter amendment SHIP from THIS plan"
  - "no D-052 § Implementation step 3 anthropic-dep removal — THIS sub-plan REMOVES `import anthropic` from claude_llm_perspective_adapter.py:80 + REMOVES `_default_transport` function; D-052 step 3 (pyproject drop) deferred per RM-AS-2 carry-forward"
  - "no harness/hook changes — this plan ships product substrate (BC-8 RolePromptPack + PersonaRegistry + transport-flip); L-S354-2/L-S366-4/L-S369-1 planner-stats infrastructure gap belongs to next harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0.6 grep-asserts no new HTTP fetcher OR HARD-REJECT artifact"
  - "If STEP 0 surfaces a charter-tier need (claude CLI substrate veto OR Rule 16 mode-tripwire OR I-S<N> for persona-rotation methodology), FLAG in § CHARTER-TIER GATE for main session AskUserQuestion ratification gate dispatch"
---

# S374 — Phase F.1 RolePromptPack + PersonaRegistry + BC-8 Transport-Flip sub-plan (FIRST sub-plan of Phase F-prime)

> **One-sentence intent**: AUTHOR foundational application-layer data primitives — (a) NEW `packages/application/analysis/role_prompt_pack.py` frozen dataclass + (b) NEW `packages/application/analysis/persona_registry.py` stdlib dict + JSON loader (YAML deferred per pyproject.toml audit) + (c) FLIP `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` default transport from `_default_transport` (anthropic SDK lazy import at L80) to existing `claude_cli_transport` from `packages/infrastructure/analysis/subagent_transport.py:144` (D-052 § Implementation step 1 FINAL execution closure — was outstanding per S369 verifier F3 finding) + (d) REMOVE `_default_transport` function + `import anthropic` line from analysis adapter — without breaking existing test_adapter.py + test_bear_agent.py + test_quant_agent.py + test_synthesizer.py regression floor (stub transport via constructor kwarg pattern unchanged), without LLM-emitting per-persona numeric confidence (I-S1 + Rule 16 mode 1 categorical Conviction preserved), and without dropping anthropic from pyproject.toml (D-052 § Implementation step 3 deferred per scope-narrowing rationale; carry-forward RM-AS-2 named).

---

> **PLAN STRUCTURE**: This sub-plan is split across 4 files for output-token efficiency:
> - **THIS FILE** (`034-S374-phase-f1-roleprompt-persona-transport.md`) — frontmatter + § A (Goal & Scope) + § B (In/Out-of-scope)
> - **`034-S374-phase-f1-roleprompt-persona-transport-part2.md`** — § C (STEP 0 BLOCKING) + § D (DD-1..DD-9 Architecture Decisions)
> - **`034-S374-phase-f1-roleprompt-persona-transport-part3.md`** — § E (D1-D5 Sub-track decomposition) + § F (DoD ≥25 items)
> - **`034-S374-phase-f1-roleprompt-persona-transport-part4.md`** — § G (AQ-1..AQ-10) + § H (5-source-evidence) + § I (STOP-AND-ASK inventory) + § J (RM1-RM10) + § K (Coordination paths) + § L (Conditional next-step) + § M (CHARTER-TIER GATE clause) + § N (D-052 cleanup attestation) + § O (Compliance attestation)
>
> S375 dev MUST READ all 4 parts at session entry. Plan-034 is one logical artifact across 4 physical files for output-token-limit pragmatism.

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent master plan-033 § E.1 + DD-4 + DD-5)

Build the **multi-perspective foundation layer** for StockForge that:

- **Defines RolePromptPack** as a frozen dataclass at `packages/application/analysis/role_prompt_pack.py` with exact field shape per master plan-033 DD-7: `role_id: str` + `persona_name: str` + `system_prompt_template: str` + `conviction_guidance: str` + `citation_requirements: str` + `vietnam_notes: str` + `min_points: int` + `min_distinct_categories: int` + `category_universe: tuple[str, ...]` + `model_id_preference: str | None` — immutable post-construction; data-only (no behavior); lookup key = `role_id`
- **Provides PersonaRegistry** as thin wrapper around `dict[str, RolePromptPack]` at `packages/application/analysis/persona_registry.py` with methods `get(role_id) → RolePromptPack` (raises KeyError) + `register(pack) → None` + `all_role_ids() → tuple[str, ...]` + `load_from_json(json_path: Path) → None` (JSON loader for V0; YAML deferred per DD-2 STEP 0.3 audit + AP-7 named revisit trigger; D-064 path-safety 5-invariant compliance)
- **Flips BC-8 transport-flip default** at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:197-199` from `transport: Callable = field(default=_default_transport)` to `transport: Callable = field(default=claude_cli_transport)` per D-052 § Implementation step 1 explicit
- **Removes `_default_transport` function + `import anthropic` line** from claude_llm_perspective_adapter.py per D-052 § Implementation step 1 explicit + L-S227-1 (NO ANTHROPIC_API_KEY in production code); CLOSES residual D-052 cleanup → D-052 spec compliance reaches 100% for BC-8 surface (was 0% per S369 verifier F3 finding)
- **Preserves existing test injection pattern** — test_adapter.py:24-33 `_make_stub_transport()` injects `transport=stub` via constructor kwarg; this pattern works identically post-flip (no test signature change); test_bear_agent.py + test_quant_agent.py continue to work unchanged
- **Preserves Rule 16 mode 1 categorical Conviction discipline** — Conviction StrEnum STRONG/MODERATE/WEAK at conviction.py:17-22 UNCHANGED; RolePromptPack.conviction_guidance is text-only rubric instructing LLM to pick categorical
- **Preserves Rule 6 citation discipline** — RolePromptPack.citation_requirements text-only field embeds per-persona ≤500 char + source_url + source_excerpt mandate
- **Preserves AC-5 reproducibility** — existing prompt_hash sha256[:16] computation at claude_llm_perspective_adapter.py:221 UNCHANGED; transport-flip preserves audit trail

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — RolePromptPack frozen dataclass at `packages/application/analysis/role_prompt_pack.py` (NEW ~100 LOC: 10-field @dataclass(frozen=True, slots=True) + __post_init__ validation + module docstring; foundation; blocks D2/D3/D4/D5)
2. **Sub-track D2** — PersonaRegistry at `packages/application/analysis/persona_registry.py` (NEW ~120 LOC: stdlib dict wrapper + get/register/all_role_ids/load_from_json methods + D-064 path-safety validation; blocks D5)
3. **Sub-track D3** — ClaudeLLMPerspectiveAdapter transport-flip at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (MODIFIED ~+10/-30 LOC: import anthropic removal + _default_transport function removal + transport field default flip to claude_cli_transport + import from subagent_transport.py + docstring update + L-S227-1 compliance comment; blocks D5)
4. **Sub-track D4** — Unit tests at `packages/application/analysis/test_role_prompt_pack.py` (NEW) + `packages/application/analysis/test_persona_registry.py` (NEW) + regression additions to `packages/infrastructure/analysis/test_adapter.py` (MODIFIED ~+50 LOC: 4 regression tests for transport-flip + import-grep-assert; parallel with D5)
5. **Sub-track D5** — ADR D-074 PROPOSED at `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md` (~100 LOC; records (a) D-052 § Implementation step 1 FINAL closure attestation + (b) RolePromptPack contract shape + (c) PersonaRegistry pattern + (d) per master plan-033 DD-8 explicit ADR landing) + `agent-workspace/role-packs/README.md` placeholder
6. **STEP 0 evaluation observation** appended to `agent-workspace/memory/observations/sandwich-dev-S375-bc-8-roleprompt-transport-flip.md`
7. **Session log + observation file** per CLAUDE.md § Session Protocol End
8. **Mistake-log digest entry** (M-S375-N if mistakes; OR explicit "no mistakes" statement)
9. **ZERO charter / constitution writes**
10. **ZERO new LLM-numeric schema fields** (Rule 16 mode 1 categorical Conviction preserved)
11. **ZERO new hooks** (mirror plan-020/022/026/027/029/030/031 — product substrate not harness rule-enforcement)
12. **ZERO new external dependencies** (uses already-shipped subagent_transport.claude_cli_transport + stdlib json; pyyaml deferred per AP-7 named revisit trigger; pyproject.toml unchanged)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Sub-theme F.2 first 3 personality-pack adapters (Buffett/Graham/Taleb) | Separate sub-plan 035; F.1 is foundation; F.2 BLOCKS_ON F.1 ship | Sub-plan 035 dispatch after S376 verifier PASS per master plan-033 § E.1 + § N.2 sequencing |
| Sub-theme F.3 N-perspective use case extension | Separate sub-plan 036; F.3 BLOCKS_ON F.2 ship | Sub-plan 036 dispatch after sub-plan 035 verifier PASS |
| Sub-theme F.4 V0 expansion to 6/9 personas (Munger/Lynch/VN_DOMAIN_SPECIALIST) | Separate sub-plan 037; NON-BLOCKING CHARTER-TIER GATE per master plan-033 K.1.a | Sub-plan 037 dispatch parallel with 038 post-F.3 ship; NO-OP IF V0=6 ratified |
| Sub-theme F.5 CLI dogfood thesis on one VN ticker | Separate sub-plan 038; F.5 ships CLI not F.1 | Sub-plan 038 dispatch parallel with 037 post-F.3 ship |
| Per-persona role-prompt-pack JSON CONTENT authoring (buffett.json / graham.json / taleb.json) | F.1 ships RolePromptPack DATACLASS + PersonaRegistry; F.2 authors CONTENT per persona; clean separation of substrate-vs-content per Karpathy P3 surgical-changes | F.2 sub-plan IMPL authors per-persona content per master plan-033 § E.2 |
| Drop `anthropic` from pyproject.toml dependencies (D-052 § Implementation step 3) | Separate cleanup ADR per scope-narrowing rationale; RM-AS-2 carry-forward | D-052-V2 cleanup trigger: ZERO `import anthropic` confirmed across packages/ + apps/ by S376 verifier; D-052-V2 drops pyproject dep + updates importlinter contracts |
| YAML format for role-packs (vs JSON V0) | DD-2 STEP 0.3 audit: pyproject.toml HAS NO pyyaml dep currently; V0 ships JSON loader to avoid scope-creep; YAML is cosmetic vs JSON | YAML adoption trigger: project-owner authors 3+ persona packs in JSON and reports friction (manual escaping of multi-line system_prompt_template strings) → add pyyaml dep via separate sub-plan |
| ChannelManager-style persona-rotation methodology | Out-of-scope; V0 ships static PersonaRegistry; rotation is V0-V2 if needed | Rotation trigger: V0 dogfood produces shallow disagreement on 3+ tickers (per master plan-033 DD-3 AP-7 revisit trigger for DEBATE-V2) |
| Per-persona historical hit-rate calibration | Per master plan-033 § A.3 deferral; ships with calibration_grade='D' | Calibration trigger: n≥50 thesis outcomes per-persona across 3+ months — post-MVP |
| New harness hook for RolePromptPack-field-determinism check | Belongs to harness-stabilization sweep IF an instance-equality defect surfaces | Harness trigger: 2+ silent RolePromptPack-mutation incidents (AP-23 promote-to-hook) |
| EchoValidator runtime enforcement for RolePromptPack data | RolePromptPack ships data; no numeric field where echo validation applies | EchoValidator trigger: F.4 surfaces new schema field requiring LLM/deterministic match — Phase F-prime-V2 |
| Persona-rotation hot-reload / dynamic registry mutation | V0 ships static registration at composition root; AP-23 first-instance HOLD | Hot-reload trigger: project-owner edits persona pack content during live dogfood session and asks for reload — Phase F-prime-V2 |
| Charter amendment SHIP for any new I-S<N> invariant Theme H surfaces | THIS plan FLAGS via STOP-FINDING file; main session ratifies via AskUserQuestion gate | Trigger: § CHARTER-TIER GATE STEP 0 STOP-AND-ASK fires |
| RolePromptPack inheritance hierarchy (BasePersonaPack + ValuePersonaPack + TailRiskPersonaPack) | Per master plan-033 DD-7 — over-abstraction for V0; data dict suffices | Trigger: F.4-V2 with N=20+ personas and ≥3 shared rubric clusters |
| Persona-pack DSL for non-developer persona authoring | Per master plan-033 § A.3 deferral; JSON edit-loop sufficient for V0 | DSL trigger: project-owner authors 3+ custom personas via edit-loop friction; Phase F-prime-V2 |
| Async RolePromptPack loader for large per-persona prompt templates | V0 ships sync load; per-persona templates are <10KB each; async unnecessary | Async trigger: per-persona template >100KB OR N≥50 personas with startup latency >2s |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared for task_class="multi-perspective-impl"; nearest analog vietnamese-nlp-impl n=3)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 35 files cited; key 10 highlighted):

1. `agent-workspace/memory/.planner-stats.tsv` (header-only at S374 entry; L-S354-2 → L-S366-4 → L-S369-1 cascade carry-forward — planner-feedback-loop.sh STILL did not auto-populate after 10+ dogfood cycles; **COLD-START on task_class="multi-perspective-impl" declared** AND COLD-START on planner-stats infrastructure)
2. `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` (parent master plan; § E.1 sub-plan-034 contract + DD-4/DD-5/DD-6/DD-7/DD-8 + § K.2 anticipated FLAGS)
3. `agent-workspace/session-plans/completed/031-S367-phase-e3-claim-extraction-wrapper.md` (precedent sub-plan for BC-5 transport-flip; DIRECT TEMPLATE for THIS sub-plan structure mirror)
4. `agent-workspace/memory/decisions/050-S227-anthropic-to-subagent-systemic.md` (D-050 CHARTER ACCEPTED; SYSTEMIC mandate)
5. `agent-workspace/memory/decisions/052-S229-anthropic-sdk-codepath-full-removal.md` (D-052 ACCEPTED; § Implementation step 1 EXPLICITLY targets claude_llm_perspective_adapter.py)
6. `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (D-072 ACCEPTED; DIRECT TEMPLATE for BC-8 transport-flip pattern mirror; CLI substrate pattern proven)
7. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (full read 264 LOC; modification target for D3)
8. `packages/infrastructure/analysis/subagent_transport.py` (full read 222 LOC; claude_cli_transport L144-222 — ALREADY-SHIPPED drop-in)
9. `packages/infrastructure/analysis/test_adapter.py` (full read 100 LOC partial; _make_stub_transport L24-33 — regression-floor)
10. `pyproject.toml` (offset 1-50 + Grep `pyyaml|yaml|anthropic` confirmed; anthropic>=0.40.0 STILL at L11; pyyaml NOT in deps)

Additional files: bear_agent.py + perspective_analysis.py + conviction.py + llm_perspective_port.py + claude_cli_news_transport.py + master plan supplement + ai-hedge-fund deep-dive obs + architecture.md BC-8 + Rule 16 + spec 004 + spec 006 + plan-031 + sub-plan 029/030 precedents + agent template (35 files total per § A.4 enumeration).

**Calibration parameters extracted**:

- **task_class**: `multi-perspective-impl` (NEW — no precedent in tracking logs; first persona-design-shaped work in StockForge IMPL; nearest analog `vietnamese-nlp-impl` n=3 from S362+S365+S368)
- **sample_size**: **0 for multi-perspective-impl** (COLD-START on this task_class); **3 for nearest-analog vietnamese-nlp-impl** (S362+S365+S368 all clean cycles ~150-160K Sonnet / ~39min / 0 mistakes each)
- **avg_wall_min observed**: N/A precise cold-start; nearest-analog ~39 min consistent across n=3
- **avg tokens_real observed**: N/A precise cold-start; nearest-analog ~155K Sonnet mean across n=3
- **parallel_hit_rate**: N/A cold-start; THIS plan declares D4+D5 parallel-eligible (disjoint file scopes)
- **parallel_savings_avg**: N/A cold-start; estimated 5-10% wall reduction from D2+D3 + D4+D5 parallel
- **failure_mode frequency**: 0 mistakes per nearest-analog n=3 (vietnamese-nlp-impl ALL CLEAN); novelty risk MEDIUM for multi-perspective-impl shape because (a) RolePromptPack is first data-driven persona pattern, (b) PersonaRegistry has D-064 path-safety surface, (c) BC-8 transport-flip touches 3 test files for regression-floor (BC-5 D-072 touched 1 — broader surface)
- **Adjustment to default budget**: +20-30K Opus reserve over nearest-analog ~155K = ~175-185K projected typical; full 150K cap IS the cap per recalibrated CLAUDE.md FOCUSED_IMPL envelope (S375 dev should split if work exceeds; named SPLIT trigger in AQ-7); +10-20K Opus reserve for STEP 0 STOP-AND-ASK file authoring IF claude CLI substrate veto fires
- **Cold-start?**: **YES for multi-perspective-impl task-class**; **NO for adapter-AUGMENT + tests + ADR shape** (transfers cleanly from vietnamese-nlp-impl n=3); **PARTIAL-COLD-START for RolePromptPack + PersonaRegistry shape** (sub-component novel); **NO for transport-flip shape** (D-072 BC-5 precedent S368)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S375 dev):

- S375 dev IMPL projection: **100-150K Opus FOCUSED_IMPL** per recalibrated CLAUDE.md table + n=3 nearest-analog precedent; +20-30K novelty reserve + 10-20K STEP 0 STOP-AND-ASK reserve
- STEP 0 evaluation overhead: ~15-25K
- D1 RolePromptPack frozen dataclass: ~10-15K
- D2 PersonaRegistry: ~15-20K
- D3 ClaudeLLMPerspectiveAdapter transport-flip: ~15-25K
- D4 unit test extensions: ~20-30K
- D5 ADR D-074: ~10-15K
- Observation + session log + mistake-log: ~10-15K
- STOP-AND-ASK file (CONDITIONAL): ~5-10K
- Reserve for inline F-fix: ~10-15K
- **Total projected dev budget envelope**: 105-160K typical; 115-175K with STEP 0 STOP-AND-ASK path; full 150K Opus cap respected (if work exceeds, SPLIT per AQ-7)

**PARALLEL OPPORTUNITY** (architect declaration for downstream S375 dev):

- D1 (RolePromptPack dataclass) must serialize FIRST as foundation (~4 min wall)
- D2 (PersonaRegistry) waits for D1 (~7 min wall)
- D3 (ClaudeLLMPerspectiveAdapter transport-flip) can run PARALLEL with D2 (~7 min wall — disjoint file scopes; D2 = packages/application/analysis/, D3 = packages/infrastructure/analysis/)
- D4 (tests) + D5 (ADR D-074) can run PARALLEL post-D2 + D3 ship (~11 min wall — disjoint file scopes)
- Sequential wall projection: 4 + 7 + 7 + 11 = ~29 min wall
- Parallel D2+D3 + parallel D4+D5 wall projection: 4 + max(7, 7) + max(11, 11) = ~22 min wall (~24% reduction)
- 2-parallel within 3-ceiling per plan-025 DD-5; no parallel-dispatch risk

**WHY COLD-START + NEAREST-ANALOG IS HONORED HONESTLY**:

- L-S354-2 + L-S366-4 + L-S369-1 carry-forward — planner-stats infrastructure gap persists; manual reading via master plan-033 + current-execution.md + observations is substitute path
- S362+S365+S368 were ALL Sonnet 4.6; this sub-plan recommends Opus for S375 dev per master plan-033 § A.4
- n=3 nearest-analog precedent means budget envelope is DIRECTIONALLY grounded but PRECISION-MEDIUM for the adapter+tests portion; the novel portion (RolePromptPack + PersonaRegistry) has NO precedent — first-instance risk MEDIUM
- AUGMENT-with-transport-flip shape was proven for BC-5 at S368 (D-072 IMPL); BC-8 mirrors but touches MORE test files (3 vs 1) — RM3 documents
- Architect declares: **COLD-START on multi-perspective-impl task-class; n=3 vietnamese-nlp-impl nearest-analog honored for adapter+tests+ADR portion; RolePromptPack + PersonaRegistry portion flagged as first-instance within envelope per RM2 — sub-plans 035-038 inherit growing precedent**

---

## B. In-scope / Out-of-scope (FOCUSED_IMPL-level for S375 dev)

### IN-scope (S375 dev MUST ship)

- RolePromptPack frozen dataclass with 10 fields per DD-7 + __post_init__ validation (~100 LOC at `packages/application/analysis/role_prompt_pack.py`)
- PersonaRegistry stdlib dict + JSON loader + D-064 path-safety + 4 methods (~120 LOC at `packages/application/analysis/persona_registry.py`)
- ClaudeLLMPerspectiveAdapter transport-flip + _default_transport removal + import anthropic removal + docstring update (~+10/-30 LOC at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py`)
- Unit tests (NEW test_role_prompt_pack.py ~70 LOC + NEW test_persona_registry.py ~80 LOC + REGRESSION test_adapter.py additions ~50 LOC; total ~200 LOC test code)
- ADR D-074 PROPOSED at IMPL tier (~100 LOC at `agent-workspace/memory/decisions/074-bc-8-transport-flip-roleprompt-persona.md`)
- Empty `agent-workspace/role-packs/` directory + placeholder `README.md` (~20 LOC)
- STEP 0 observation + Session log + observation file + Mistake-log digest entry
- Plan-034 moved `pending/` → `completed/` at S376 close (NOT at S375 close — verifier acceptance gates the move)

### OUT-of-scope for S375 dev (DEFERRED — explicit non-goals)

- Sub-theme F.2 first 3 personas work — separate sub-plan 035
- Sub-theme F.3 N-perspective use case extension — separate sub-plan 036
- Sub-theme F.4 V0 expansion — separate sub-plan 037
- Sub-theme F.5 CLI dogfood — separate sub-plan 038
- D-052 § Implementation step 3 anthropic-dep removal from pyproject.toml — RM-AS-2 carry-forward
- YAML format for role-packs — JSON-only V0 per DD-2 STEP 0.3 pyyaml audit + AP-7 named revisit trigger
- ChannelManager-style persona-rotation methodology
- EchoValidator runtime tier enforcement
- Persona-rotation hot-reload
- New harness hook for RolePromptPack-field-determinism check (AP-23 2+ instance trigger)

---

> **Continue plan-034 reading at `034-S374-phase-f1-roleprompt-persona-transport-part2.md`** for § C (STEP 0 BLOCKING DEPENDENCY EVALUATION sub-steps 0.1-0.6 with STOP-AND-ASK triggers) + § D (DD-1..DD-9 Architecture Decisions with rationale + adversarial alternates).
>
> Then `-part3.md` for § E (D1-D5 Sub-track decomposition with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract; complete code stubs for each sub-track) + § F (DoD ≥25 items: 10 file + 10 impl + 6 STEP 0 + 9 gates + 4 regression + 6 bookkeeping = 36 distinct items).
>
> Then `-part4.md` for § G (AQ-1..AQ-10 pre-answered) + § H (5-source-evidence chain with 5 decisions × 5 sources = 25 citations) + § I (STEP 0 STOP-AND-ASK trigger inventory: 5 documented — 1 CHARTER-TIER + 3 TACTICAL-TIER + 1 BLOCKING) + § J (RM1-RM10 + RM-AS-2 carry-forward) + § K (Coordination paths off-limits) + § L (Conditional next-step branches L.1-L.5) + § M (CHARTER-TIER GATE clause canonical reference) + § N (D-052 cleanup completion attestation contract — spec compliance 0% → 100% for BC-8 surface) + § O (Compliance attestation).
