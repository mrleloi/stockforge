---
plan_id: 033-S373-phase-fprime-multi-perspective-master-plan
target_session: S373 (THIS PLAN — Phase F-prime master plan authoring; sub-plans dispatched per § E sequencing in S374+)
type: PHASE-MASTER-PLAN (decomposes Phase F-prime into 5 follow-on per-sub-track PLAN+IMPL+VERIFY chains; NOT a single FOCUSED_IMPL plan per CLAUDE.md § Session Types "never mix PLAN+IMPL")
budget: master-plan authoring envelope ~150-230K Opus PLAN (THIS SESSION — architect; cold-start declared for task_class="multi-perspective-plan"); subsequent per-sub-track PLAN sessions ~50-80K each; per-sub-track IMPL sessions ~100-150K each; per-sub-track VERIFY ~30-60K each
phase: F-prime (Theme H — BC-8 Multi-Perspective Primitives; FIRST master-plan after Phase E Theme I FULLY DONE at S372 commit 8f68947 — 4/4 sub-themes E.1+E.2+E.3+E.4 shipped + verified per current-execution.md S365/S368/S371)
track: Wave 1 Theme H — Multi-perspective adversarial extension (BC-8 Analysis & Thesis personality-pack + aggregation; per master plan § 5.3 + § 6.4.3)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.3 + § 6.4.3 (Phase F-prime unlocks post-Phase E close; depends on Phase E E.3 ClaudeLlmExtractor transport-flip precedent per D-072)
predecessor: 032-S370-phase-e4-vn-ticker-resolver (E.4 VN ticker resolver shipped+verified S371-S372; Phase E Theme I FULLY DONE 4/4; commit 8f68947 the Phase E DONE attestation marker)
successor: TBD — per § E decomposition five follow-on per-sub-track plans 034/035/036/037/038 (tentatively S374/S376/S378/S381/S384 per-sub-track entry sessions; verifier sessions interleaved; sequencing per § J + § E)
architect: S373 sandwich-architect (background; this PHASE-MASTER-PLAN)
dispatched_by: main session orchestrating Phase F-prime entry per CLAUDE.md § Session Types phase-master-plan-first discipline + dispatch brief 2026-05-17 architect-decision = PHASE-MASTER-PLAN recommended
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **COLD-START declared** for task_class="multi-perspective-plan" per L-S354-2 + L-S366-4 + L-S369-1 cascade — no precedent in .planner-stats.tsv or sessions-rollup.tsv for multi-perspective-plan-shaped work; nearest analog vietnamese-nlp-plan n=1 from S360 master plan but persona-design/aggregation-shape is fundamentally different from NLP-substrate-shape)
executing_agent: N/A this session (architect); subsequent per-sub-track dispatches per § E
status: pending-execution (Phase F-prime master plan ratification path; main session reviews + dispatches first follow-on plan-034 per § E sequencing)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Phase E Theme I FULLY DONE (S372 commit 8f68947 verifier PASS); D-070 pyvi tokenizer + D-071 sentiment lexicon + D-072 claim-extraction-wrapper + D-073 ticker resolver all ACCEPTED — Phase F-prime CONSUMES E.3's ClaudeLlmExtractor transport-flip pattern as the design precedent for BC-8 perspective adapter transport-flip"
  - "D-051 + D-052 (anthropic→subagent transport flip + SDK dep removal; pre-existing ACCEPTED at S? but ONLY applied to BC-5 News via D-072 at S368; **BC-8 perspective adapter STILL imports anthropic at packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80** — Phase F-prime carries this refactor surface as RM-AS-1)"
  - "D-061 § Decision item 7 (Wave-1 integration ratification — Phase F-prime ratified for entry post-Phase E; Theme H deferred until E.3 transport-flip surfaced the migration pattern empirically)"
  - "D-065 (Theme G I-S1-1 Rule 16 numeric-field discipline — ACCEPTED 2026-05-16; BINDING for ANY new BC-8 perspective schema field; § Rule 16 § 'Fields explicitly subject to this rule' inventory at financial-data-protocol.md:443-456 EXPLICITLY names 'Future BC-8 output schemas to be created by Phase F-prime' — this plan is the implementation surface)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain are BINDING for every new file authored under Phase F-prime sub-plans)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for each sub-plan dev commit boundary)"
  - "D-062 (atomic-write-doctrine — BINDING for any role-prompt-pack YAML or persona registry writes via tmp+os.replace pattern)"
  - "D-064 (path-safety 5-invariant contract — BINDING for new file-path code in any Theme H sub-plan)"
  - "D-066 (CrawlerAdapter ABC — INFORMATIONAL precedent for ABC-vs-Protocol decision in DD-7 RolePromptPack contract shape)"
  - "D-067 (planner-upgrade ADR plan-025 — Phase 1b mandate for ≥3 sub-tracks — THIS plan is master-plan but each follow-on per-sub-track plan MUST consume Phase 1b at dispatch)"
  - "D-072 (VN claim extraction wrapper — AUGMENT existing extractor + anthropic→subagent default-flip + 2 new ExtractedClaim fields; SHIPPED S368; **DIRECTLY ANALOGOUS PRECEDENT** for BC-8 perspective-adapter transport-flip — see RM-AS-1 mitigation)"
  - "Charter v1.1 Principle 3 (Adversarial by Design — multi-perspective IS the moat per master plan § 4.1) + Principle 7 (Dogfood — each sub-plan dev MUST self-use the persona pack on a real VN ticker thesis) + Principle 8 (Calibration over confidence — per-persona calibration is post-MVP; cold-start V0 ships WITHOUT historical hit-rate per AP-7 named revisit trigger) + Principle 9 (NO LLM math — per-persona LLM emits ONLY signal+reasoning+evidence; numeric confidence comes from deterministic categorical-to-numeric mapping per Rule 16 mode 1 or 2) + Principle 11 (firing-test mandate for any hook shipped — N/A this plan, no hooks expected; product code only)"
  - "I-S1 (NO LLM math) + I-S1-1 (Rule 16 numeric-field discipline; BC-8 schemas explicitly in scope per Rule 16 § 'Fields explicitly subject') + I-S2 (citation discipline — every persona claim cites source_url + source_excerpt verbatim) + I-S10 (bear case substantive ≥3 distinct evidence-grounded points across ≥3 distinct categories — already enforced in Thesis aggregate per packages/domain/analysis/models/thesis.py:91-115) + I-S11 (multi-perspective synthesis ≥2 minimum; ≥4 for high-confidence — Phase F-prime expansion target N≥4 personas per V0) + I-S12 (Disagreement Surfaced, Not Resolved — already enforced in Synthesis aggregate per packages/domain/analysis/models/synthesis.py:89-100) + I-S20 (calibration over confidence — per-persona historical hit-rate is post-MVP; V0 ships with calibration_grade='D' per existing Thesis aggregate :84) + I-S22 (data lineage — each perspective traces to source claims + as-of date per GroundedPoint invariants packages/domain/analysis/value_objects/grounded_point.py:54-71) + I-S35 (research-aid framing — output is 'thesis exploration' per Recommendation enum INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE NOT buy/sell)"
  - "Rule 6 (LLM Output Provenance — every persona key_point preserves source_url + source_excerpt verbatim ≤500 char per GroundedPoint __post_init__) + Rule 7 (sentiment categorical 5-class StrEnum — already shipped at packages/domain/news/value_objects/sentiment.py; Theme H aggregation MUST NOT bypass) + Rule 16 (numeric-field discipline — confidence-like per-persona output uses mode 1 categorical surrogate via Conviction enum STRONG/MODERATE/WEAK per packages/domain/analysis/value_objects/conviction.py; aggregate confidence_level uses mode 2 deterministic-pipeline echo via existing recommendation_heuristic.confidence_from_synthesis pure function)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline — prompt caching for system prompt amortization; structured-output JSON contract; **especially the BP-S43b-1 per-role model override pattern + BP-S43b-2 prose-tolerant JSON extractor + BP-S43b-3 gatherer-wired deterministic compute per architecture.md:142-154**)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (port-and-adapter; aggregate-root invariants — Phase F-prime extends existing Thesis aggregate + adds new RolePromptPack / PersonaRegistry value-object pack)"
  - "specs/tier2-feature/004-multi-perspective-adversarial-agents.md (BC-8 spec — 6 perspectives target per A.2; current state ships 3 active (BEAR/BULL/QUANT) + 3 deferred stubs (MACRO/BEHAVIOR/MANAGER) per packages/domain/analysis/models/perspective_analysis.py:30-39; Phase F-prime EXPANDS via personality-pack pattern; spec A.2 already enumerates 6 perspective archetypes — Phase F-prime decides Vietnam-relevance subset for V0)"
  - "specs/tier2-feature/006-phase-2-track-F-thesis-pipeline.md (existing Phase 2 BC-8 pipeline spec — Phase F-prime EXTENDS rather than rewrites; honors AC-5 reproducibility + BR-1..BR-9)"

binding_decisions:
  - "PHASE-F-PRIME AS PHASE-MASTER-PLAN (NOT single multi-sub-track FOCUSED_IMPL) — per dispatch brief architect-decision + CLAUDE.md § Session Types 'never mix PLAN+IMPL'; precedent: plan-028 Phase E master-plan = 4 sub-themes per-PLAN+IMPL+VERIFY chain (sub-plans 029/030/031/032 SHIPPED); Phase F-prime = 5 sub-tracks following the same architectural rhythm"
  - "TASK-CLASS COLD-START DECLARED — Phase 1b Calibration summary for THIS master plan explicitly cites COLD-START on .planner-stats.tsv task_class='multi-perspective-plan' per L-S354-2 → L-S366-4 → L-S369-1 cascade carry-forward; planner-feedback-loop.sh bug STILL not fixed after 3 dogfood cycles (M-S360 / M-S363 / M-S366); nearest analog vietnamese-nlp-plan n=1 from S360 master plan inheritance — but persona-design + aggregation-shape are fundamentally different from NLP-substrate-shape"
  - "D-060 — agent MAY git commit (NOT push); each per-sub-track plan dev decides commit boundary independently"
  - "AP-23 promote-or-retire — applied to first-instance: any new persona role-prompt-pack template that ships unchanged after 3 dogfood cycles on different VN tickers is PROMOTE-NOW candidate (not refinement-of-rule); persona count expansion uses AP-7 named revisit trigger pattern"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item in this plan + sub-plans names (a) prerequisites + (b) revisit trigger; no naked deferrals"
  - "I-S1-1 BY-CONSTRUCTION posture for Theme H per-persona output — per-persona LLM emits ONLY (a) signal: categorical (existing Conviction STRONG/MODERATE/WEAK) + (b) reasoning: prose + (c) key_points: GroundedPoint tuple. **Aggregate confidence_level uses mode 2 deterministic-pipeline echo** via existing recommendation_heuristic.confidence_from_synthesis pure function (Recommendation→ConfidenceLevel deterministic map). NO per-persona LLM ever emits a numeric confidence integer per Rule 16 § 'satisfaction modes' (a)-(d)"
  - "VBW protocol mandatory — every sub-plan author must READ ai-hedge-fund src/agents/warren_buffett.py + ai-hedge-fund src/utils/analysts.py + TradingAgents agents/researchers/bull_researcher.py + INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md § H.3 verdict-and-mitigations empirically NOT memory; cite file:line for every architectural claim. **Existing BC-8 code is the primary VBW anchor** — read packages/domain/analysis/** + packages/application/analysis/** + packages/infrastructure/analysis/** before any new file proposed"
  - "Karpathy P3 surgical-changes — each sub-plan adds ≤500 LOC production code per sub-track; if a sub-track grows >500 LOC architect MUST split it further. **Theme H EXTENDS existing BC-8 code rather than replacing — preserves backward compat with Phase 2 spec 006 pipeline + AC-5 thesis_id reproducibility**"
  - "ISOLATED-THEN-AGGREGATE for V0 (per H.3 verdict-INVERSION analysis below) — see DD-3"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; this is master-plan authoring)"
  - "no commits in THIS plan-session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no touching Phase E Theme I files unless EXTENDING (e.g. apps/_shared/entities/vn_ticker_resolver.py is consumable infra — Theme H consumes it for VN-ticker-mention extraction in persona context-gathering)"
  - "no Theme G-prime / H-prime entry from THIS plan — those are independent Phase G-prime / H-prime master-plans per master plan § 6.4.4-6.4.5"
  - "no Charter amendment SHIP from THIS plan — IF Theme H surfaces a Rule-16 mode-tripwire OR new I-S<N> invariant, this plan FLAGS in § K for separate user-ratification gate; the FLAG is not the AMENDMENT"
  - "no harness/hook changes — this plan ships product substrate (Theme H multi-perspective); surface any harness gaps in observation; do NOT fix here. L-S354-2/L-S366-4/L-S369-1 planner-stats infrastructure gap belongs to a harness-stabilization sweep"
  - "every plan claim cites source file:line (per I-S2 + AOM + VBW protocol)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward IF Theme H introduces ANY new HTTP fetcher for persona-evidence gathering (currently EXTENDS existing Phase1DataGatherer which CONSUMES already-ingested data — no new fetcher expected; verify at each sub-plan STEP 0)"
  - "If Phase F-prime surfaces a charter-tier need (new I-S<N> invariant for persona-rotation methodology / new Rule for personality-pack vs role-class polymorphism / new mode in Rule 16 for per-persona confidence semantics), FLAG in § K for main session user-ratification gate dispatch"
  - "ai-hedge-fund LICENSE-file caveat per A-01 § 6 (LICENSE-file MISSING at root despite README.md:155-157 MIT claim) — Phase F-prime ADOPTS PATTERNS not code-copy lines verbatim per A-01 § 7 R8 mitigation; if any code-copy needed beyond pattern-port, sub-plan STEP 0 must STOP-AND-ASK with license-verification path"
---

# S373 — Phase F-prime Theme H BC-8 Multi-Perspective Entry (PHASE-MASTER-PLAN)

> **One-sentence intent**: Decompose Phase F-prime (Theme H — BC-8 Multi-Perspective Primitives EXTENSION) into 5 follow-on per-sub-track PLAN+IMPL+VERIFY chains covering (F.1) RolePromptPack + PersonaRegistry foundation + transport-flip migration parity with D-072, (F.2) personality-pack pattern ports for 3 first personas (Buffett / Graham / Taleb), (F.3) PortfolioManager-equivalent SynthesizePerspectivesUseCase extension to N≥4 personas, (F.4) expansion to V0 6-persona pack with Vietnam-relevance subset selection, (F.5) CLI smoke dogfood thesis on one VN ticker — each chain ≤1 PLAN + 1-2 IMPL + 1 VERIFY session — without mixing PLAN+IMPL in the same session (CLAUDE.md hard rule), without LLM-emitting numeric per-persona confidence (I-S1 + Rule 16), and without bundling all 6 personas + aggregation refactor + CLI dogfood into one session (Session 4 catastrophic mix anti-pattern).

---

## A. Goal & Scope

### A.1 Goal (verbatim from master plan + dispatch brief + Phase E precedent inheritance)

Build the **personality-pack multi-perspective extension** that lets StockForge run thesis exploration with N≥4 personality-grounded LLM perspectives on a VN stock, where:
- **Each persona produces an isolated PerspectiveAnalysis** per the existing schema at `packages/domain/analysis/models/perspective_analysis.py:42-61` (frozen + slotted dataclass with `{role, key_points, overall_conviction, cost_usd, model_id, prompt_hash}`) — NO inter-persona messaging during generation (isolated-then-aggregate per H.3 inversion analysis below per DD-3)
- **Aggregation is deterministic code** via the existing Phase1Synthesizer + recommendation_heuristic pipeline at `packages/application/analysis/services/recommendation_heuristic.py:36-69` (extended to handle N>3 perspectives) — LLM never aggregates; LLM never produces aggregate numeric confidence
- **Per-persona confidence is categorical** via Conviction StrEnum (STRONG/MODERATE/WEAK) at `packages/domain/analysis/value_objects/conviction.py:?` (existing) — satisfies Rule 16 mode 1; LLM never echoes numeric confidence (Buffett 90-100 rubric per ai-hedge-fund `warren_buffett.py:788-794` is REJECTED as I-S1-1 anti-pattern; we use the categorical surrogate path instead per Rule 16 mode 1)
- **Per-persona transport** uses `make_claude_cli_news_transport()` factory (precedent D-072 + S368 sub-plan 031 IMPL) NOT direct anthropic SDK import — completes the BC-8 surface of the anthropic_api_to_subagent memory-rule + D-051 + D-052 transport flip that landed for BC-5 News at S368 but is STILL outstanding for BC-8 perspective adapter at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:80` `import anthropic`
- **Aggregate signal output** uses existing Synthesis aggregate + Recommendation enum (INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE per `packages/domain/analysis/value_objects/recommendation.py:?`) — NO new "buy/sell" surface, NO new "single 0-100 score" surface; I-S35 satisfied by-construction

### A.2 Scope (5 sub-tracks per master plan § 5.3 + § 6.4.3 + dispatch brief)

This phase ships:

1. **Sub-track F.1 — RolePromptPack + PersonaRegistry foundation + BC-8 transport-flip** (target: NEW `packages/application/analysis/role_prompt_pack.py` + NEW `packages/application/analysis/persona_registry.py` + EDIT `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` for transport-flip parity with D-072)
2. **Sub-track F.2 — First 3 personality-pack adapters (Buffett / Graham / Taleb)** (target: NEW `packages/infrastructure/analysis/perspectives/buffett_agent.py` + `graham_agent.py` + `taleb_agent.py` + role-prompt-pack YAML at `agent-workspace/role-packs/` per supplement § H.4 IMPL-slot bullet 1)
3. **Sub-track F.3 — PortfolioManager-equivalent SynthesizePerspectivesUseCase extension to N≥4** (target: EDIT `packages/application/analysis/use_cases/validate_thesis_phase1.py` to support N-persona orchestration + extend Phase1Synthesizer at `packages/infrastructure/analysis/phase1_synthesizer.py` for N≥4-perspective tradeoff matrix)
4. **Sub-track F.4 — V0 persona-pack expansion + Vietnam-relevance subset selection** (target: ratify persona count V0 N=6 vs ≥4 OR fewer per architect recommendation in DD-2; expand to 3 more personas if N=6 chosen — e.g. Munger / Lynch / VN-domain-specialist per Vietnam-relevance evidence chain in DD-2)
5. **Sub-track F.5 — CLI smoke + dogfood thesis on one VN ticker** (target: NEW `apps/cli/synthesize_vn_thesis.py` CLI; dogfood run on one project-owner-picked VN30 ticker — VHM or VIC or HPG — to capture per-persona output + aggregate Recommendation + cost-tracking + AC-5 reproducibility check)

Each sub-track = one downstream PLAN session (S374 / S376 / S378 / S381 / S384) authored by sandwich-architect + one IMPL session (S375 / S377 / S379-S380 / S382-S383 / S385) executed by sandwich-dev + one VERIFY session (sandwich-verifier AP-1) per the standard sandwich pattern.

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| Debate-style rebuttal-cycle perspectives | H.3 verdict was DEBATE WINS per I-S12 literal compliance, BUT Phase F-prime V0 INVERTS that verdict per DD-3 below — debate adds combinatorial token cost + non-determinism + AP-1 same-agent-self-review risk; isolated-then-aggregate matches existing BC-8 pipeline shape AND ai-hedge-fund A-01 § 5 empirical "isolated-then-aggregate" pattern (parallel fan-out at src/main.py:112-115; NO inter-agent messaging) | Debate trigger: V0 dogfood produces shallow disagreement on 3+ tickers (per-persona verdicts converge artificially without rebuttal); revisit Phase F-prime-V2 after V0 calibration cycle (~10 dogfood thesis runs) |
| Per-persona historical hit-rate calibration | Charter Principle 8 calibration over confidence — but persona pack is too new to have historical hit-rate; V0 ships with calibration_grade="D" per existing Thesis aggregate :84 | Calibration trigger: n≥50 thesis outcomes per-persona across 3+ months wall-clock — post-MVP |
| Streamlit dashboard surface for thesis output | Phase H-prime work per master plan § 6.4.5; not on Phase 1 critical path; CLI dogfood (F.5) sufficient for V0 | Streamlit trigger: Phase 2 dashboard work entry per master plan § 6.4.5 |
| 19-persona ai-hedge-fund full port | Charter Principle 7 (Dogfood — internal use first) — 19 personas is over-engineering for V0; pattern-port + Vietnam-relevance subset is correct V0 (per DD-2 persona count) | Full-19-port trigger: V0 dogfood demonstrates persona-pack value + project-owner adds 3+ new persona archetypes — Phase F-prime-V2 |
| Custom persona authoring CLI / persona-pack DSL | YAML role-prompt-pack at `agent-workspace/role-packs/` per supplement § H.4 IMPL-slot is V0 surface; no separate persona DSL | DSL trigger: project-owner authors 3+ custom personas via YAML edit-loop friction; then DSL design |
| LangGraph adoption for orchestration | Per supplement § H.4 "LangGraph adoption decision per L-S32-1 empirical probe" + A-01 § 7 R1 "LangChain/LangGraph wholesale dependency anti-pattern" — V0 uses existing asyncio.gather pattern at validate_thesis_phase1.py:221 | LangGraph trigger: N≥10 personas + ≥3 rebuttal-cycles needed (debate-style activation) — Phase F-prime-V3+ |
| Vietnam-domain-specialist persona handcrafted | DD-2 V0 persona count = ratification gate item; user may approve OR pick smaller subset; **the persona itself is in-scope for F.4 IF user picks V0=6** but the per-persona prompt template authoring is a F.4-internal decision not a separate sub-track | If user picks V0<6 in DD-2 charter-tier gate, defer VN-domain-specialist to V0-V2 |
| Charter amendment SHIP for any new I-S<N> invariant Theme H surfaces | If a new invariant needed (e.g. I-S<N>-1 for persona-rotation methodology), this plan FLAGS in § K; main session dispatches separate user-ratification gate per CLAUDE.md hard rule | Trigger: § K item flagged + main session AskUserQuestion dispatch path |
| New harness/hook for persona-template-linting | Belongs to harness-stabilization sweep, NOT product session | Harness sweep trigger: 2+ recurrences of persona-template-defect across IMPL sessions (AP-23 promote-to-hook calculus) |
| Async migration of perspective adapter pipeline | Already async per validate_thesis_phase1.py:221 asyncio.gather + LLMPerspectivePort.analyze() Protocol — no new async migration needed | N/A — pre-shipped |
| Multi-language extension (English / Chinese personas) | VN-only is the moat per Charter Principle 4 (Proprietary data moat); cross-locale extension is anti-moat without clear business case | Trigger: explicit user directive for multi-locale OR market expansion beyond VN |
| Real-time streaming persona output (vs batch dogfood) | V0 ships batch CLI per F.5; streaming = Phase 3+ via Redis Streams (already in stack per CLAUDE.md but not wired for BC-8 yet) | Trigger: Phase 3 entry + Redis Streams wired for BC-8 |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash):
- `agent-workspace/memory/.planner-stats.tsv` (header-only at S373 entry; L-S354-2 → L-S366-4 → L-S369-1 carry-forward cascade — planner-feedback-loop.sh STILL did not auto-populate after 3 dogfood cycles M-S360/M-S363/M-S366; **COLD-START on task_class="multi-perspective-plan" declared** AND COLD-START on planner-stats infrastructure)
- `agent-workspace/memory/self-awareness/sessions-rollup.tsv` (read last 30 rows window; schema = `session_n,session_id,ts_utc,tokens_real,tools_used,subagents,failure_codes,wall_min`; NO `task_class` column — cannot key cleanly to "multi-perspective-plan" precedent; only task_class precedent in repo is "crawler-adapter-impl" n=3 + "vietnamese-nlp-plan" n=1 from S360 master plan)
- `agent-workspace/memory/dispatch.jsonl` (read 5 rows offset=0; agent_type="unknown-agent" predominantly on older rows — schema-population gap; recent rows since S324 have agent_type="sandwich-verifier" / "sandwich-architect" / "sandwich-dev" populated; no agent_type="multi-perspective-anything" precedent)
- `agent-workspace/memory/current-execution.md` (full read 199 LOC; recent session context S365/S368/S371 sub-plan dispatches; Phase E DONE attestation at S372 commit 8f68947)
- `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` § 5.3 Theme H + § 6.4.3 Phase F-prime (offset 200-400 for § 4.1 ai-hedge-fund + § 4.13 TradingAgents + § 4.14 TradingAgents-CN FIT-HIGH evidence)
- `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § Theme H (offset 148-230; full H.1-H.5 + verdict-and-mitigations)
- `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` (full read 104 LOC; § 2-7 architecture + per-perspective Pydantic signal contract + deterministic-then-LLM split + Buffett confidence rubric + license caveat + R1-R10 anti-patterns)
- `packages/domain/analysis/models/perspective_analysis.py` (full read 62 LOC; existing PerspectiveAnalysis dataclass + PerspectiveRole 6-value StrEnum; BEAR/BULL/QUANT active + MACRO/BEHAVIOR/MANAGER deferred stubs per :36-39)
- `packages/domain/analysis/models/thesis.py` (full read 147 LOC; Thesis aggregate root + BearCaseInvariantError + ThesisStatus + _enforce_bear_case I-S10 invariant at :91-115)
- `packages/domain/analysis/models/synthesis.py` (full read 101 LOC; Synthesis aggregate + Confluence enum + Disagreement dataclass + SynthesisInvariantError I-S12 invariant at :89-100)
- `packages/domain/analysis/value_objects/grounded_point.py` (full read 72 LOC; GroundedPoint invariants source_url + source_excerpt + as_of + conviction + category)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (full read 290 LOC; existing 7-step pipeline use case + SharedContext dataclass + LLMPerspectivePort + Phase1Synthesizer Protocol + CostTrackerPort + ThesisRepository)
- `packages/application/analysis/ports/llm_perspective_port.py` (full read 53 LOC; existing LLMPerspectivePort Protocol)
- `packages/application/analysis/services/recommendation_heuristic.py` (read first 80 LOC; existing pure-deterministic Synthesis→Recommendation+ConfidenceLevel mapping; BR-7 Phase 1 heuristic)
- `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (read first 90 LOC + offset 170-290 for ClaudeLLMPerspectiveAdapter dataclass + transport field + role_model_overrides field; **existing direct `import anthropic` at line 80** = anthropic_api_to_subagent memory-rule violation surface still outstanding for BC-8)
- `packages/infrastructure/analysis/perspectives/bear_agent.py` (read first 300 LOC; existing BEAR persona implementation with retry-validator pattern + SYSTEM_PROMPT verbatim from spec § B.5.1 + Jaccard distinctness filter + _validate_bear_output I-S10 strict gate)
- `packages/infrastructure/news/claude_cli_news_transport.py` (read offset 90-170; existing `claude_cli_news_transport()` + `make_claude_cli_news_transport()` factory — **direct precedent for BC-8 transport-flip in F.1 sub-track**)
- `agent-workspace/constitution/financial-data-protocol.md` § Rule 16 (offset 358-477; full Rule 16 + 4 satisfaction modes + EchoValidator runtime tier + Rule 16 amended 2026-05-16 via D-065)
- `agent-workspace/constitution/architecture.md` § BC-8 (offset 82-100 + offset 130-180; BC-8 path packages/domain/analysis/ + LLM substrate boundary BP-S43b-1/2/3)
- `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` (read first 80 LOC; SPEC-2026-04-23-004 v1.0 approved; A.2 six perspectives enumerated; BR-1..BR-9 business rules + I-S10/I-S11/I-S12 cross-reference)
- `agent-workspace/session-plans/pending/028-S360-phase-e-vietnamese-nlp-entry.md` (predecessor master plan reference; PHASE-MASTER-PLAN shape; 4-sub-theme decomposition pattern)
- `agent-workspace/memory/decisions/072-vn-claim-extraction-wrapper.md` (D-072 ACCEPTED ADR; precedent for BC-8 transport-flip in F.1)
- `agent-workspace/memory/sessions/2026-05-17-session-371.md` (S371 Phase E.4 ticker resolver IMPL session log; Phase E DONE attestation surface)
- `agent-workspace/memory/observations/sandwich-architect-S360-phase-e-vietnamese-nlp-plan.md` (master-plan observation file precedent for THIS session's observation)
- `.claude/agents/sandwich-architect.md` (full read; architect template L42-65 Phase 1b mandate + L207-210 observation mandate)

**Calibration parameters extracted**:

- **task_class**: `multi-perspective-plan` (NEW — no precedent in tracking logs; first persona-design-shaped work in StockForge)
- **sample_size**: **0** (COLD-START on this task_class; closest precedents are `crawler-adapter-impl` n=3 and `vietnamese-nlp-plan` n=1 but persona-design + aggregation-shape are fundamentally different from both — different files, different external references, different validation regime: per-persona prompt template design + ai-hedge-fund pattern-port + Vietnam-relevance subset selection)
- **avg_wall_min observed**: N/A cold-start; **adopting recalibrated PLAN-Opus 150-230K budget per dispatch brief** for THIS master plan (cold-start declared); per-sub-track PLAN sessions inherit precedent from THIS plan after first sub-track ships
- **avg tokens_real**: N/A cold-start; estimating per closest analog cascade = `vietnamese-nlp-plan` n=1 ~80K (S360 master plan) + +50% uplift for multi-perspective novelty (5-sub-track decomposition + Vietnam-relevance evidence chain + role-prompt-pack pattern design + AC-5 reproducibility regression risk — broader decision-space than Phase E master plan)
- **parallel_hit_rate**: N/A cold-start; THIS master plan declares parallel_with FOR DOWNSTREAM sub-plans per § E (F.1 BLOCKS F.2/F.3/F.4/F.5; F.2 + F.3 sequential since F.3 extends use-case to consume F.2 personas; F.4 + F.5 may run parallel post-F.3 ship); follow-on per-sub-track plans declare per-sub-track parallel_with per plan-025 contract
- **parallel_savings_avg**: N/A cold-start
- **failure_mode frequency**: N/A cold-start; nearest analog `vietnamese-nlp-plan` n=1 shows 0 IMPORTANT defects per cycle but only n=1 sample; Theme H may surface MORE defects per cycle because (a) persona prompt template design has more decision points per persona than NLP-substrate-scaffolding, (b) AC-5 reproducibility regression risk per persona-pack rotation requires careful test design, (c) transport-flip migration for BC-8 perspective adapter touches existing test_adapter.py + test_bear_agent.py + test_quant_agent.py = regression-floor surface broader than D-072
- **Adjustment to default budget**: This master plan = ~150-230K Opus PLAN authoring (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus + dispatch brief target); each follow-on per-sub-track plan envelope: PLAN 50-80K + IMPL 100-150K + VERIFY 30-60K = **180-290K per sub-track × 5 sub-tracks = ~900-1450K cumulative Phase F-prime budget**
- **Cold-start?**: **YES** (explicit declaration per agent-template + plan-025 DD-11 mandate; both `.planner-stats.tsv` infrastructure gap AND first multi-perspective-shaped work)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail):
- This master plan authoring: **150-230K Opus PLAN target ceiling** (per dispatch brief Budget: "150-230K Opus PLAN per recalibrated CLAUDE.md (cold-start declared)")
- Per-sub-track PLAN (S374/S376/S378/S381/S384): 50-80K each (per CLAUDE.md § Session Types PLAN envelope) — calibration cold-start so use full envelope
- Per-sub-track IMPL (S375/S377/S379-S380/S382-S383/S385): 100-150K Opus FOCUSED_IMPL each (cold-start defaults per plan-025 DD-6/DD-11) — Phase 1b for THOSE sessions inherits precedent from THIS plan + prior crawler-adapter-impl n=3 + vietnamese-nlp-plan n=1 as nearest analogs
- F.3 may need 1-2 IMPL sessions (use-case extension + Phase1Synthesizer N-perspective rewrite); F.4 may need 1-2 IMPL sessions if V0=6 (3 more persona-adapter ports)
- Per-sub-track VERIFY: 30-60K Opus AP-1 fresh-context each (per CLAUDE.md § Session Types VERIFY envelope)
- **Cumulative Phase F-prime budget envelope: ~900-1450K Opus across ~15-19 sessions** (5 PLAN + 5-7 IMPL + 5 VERIFY)

**PARALLEL OPPORTUNITY** (architect declaration for downstream sub-plans):
- F.1 (RolePromptPack + transport-flip) is foundational — must ship FIRST; blocks F.2/F.3/F.4/F.5 (they all depend on having a transport-flipped adapter + RolePromptPack contract)
- F.2 (first 3 personas) consumes F.1 output (RolePromptPack ABC + transport); blocks F.3 (use case extension needs concrete personas to test N>3 path)
- F.3 (use case extension) consumes F.1 + F.2 outputs (orchestrates N-persona dispatch + Phase1Synthesizer N-perspective tradeoff matrix)
- F.4 (V0 expansion) is sequential POST-F.3 (needs use-case extension shipped before adding 3 more personas; without F.3, 3 more personas only "fit" if N=3+3=6 hardcoded — but F.3 mainstreams the N≥4 generalization)
- F.5 (CLI dogfood) is INDEPENDENT of F.4 in principle (could dogfood with 3-persona V0 immediately post-F.3) BUT mature V0 dogfood benefits from full 6-persona pack — RECOMMENDED parallel with F.4 post-F.3 ship
- **Recommended sequencing**: F.1 sequential → F.2 sequential → F.3 sequential → (F.4 + F.5 parallel)
- Sub-plans 034/035/036 sequential; sub-plans 037/038 parallel-eligible per main session orchestration
- Per plan-025 DD-5 3-parallel ceiling applies to dev dispatch within a single sub-plan; cross-sub-plan parallel dispatch follows the same calculus

---

## B. In-scope / Out-of-scope (master-plan-level)

### IN-scope (this MASTER PLAN ships)

- **This master-plan markdown** (~1000-1200 LOC; 5 sub-track decompositions + per-sub-track DD pre-answered + recommended session sequencing + ratification path)
- **§ K Charter-tier-surface FLAG** (if Theme H surfaces invariant gaps; FLAGS only — does NOT amend charter/constitution)
- **§ E Sequencing recommendation table** (sub-plans 034/035/036/037/038; budget envelopes; parallel-with dispatch markers)
- **§ N Phase F-prime → G-prime → H-prime sequencing recommendation** per dispatch brief return-summary item 7
- **Phase 1b CONSUMED variant with COLD-START explicit** (per plan-025 DD-11 mandate + agent-template L65 cold-start path; L-S354-2/L-S366-4/L-S369-1 cascade carry-forward)
- **5-source-evidence chain** citing ai-hedge-fund + TradingAgents + supplement § H + existing BC-8 code + Rule 16 D-065
- **Observation file** at `agent-workspace/memory/observations/sandwich-architect-S373-phase-fprime-master-plan.md` (per agent-template L207-210 mandate; ~200 LOC)

### OUT-of-scope (DEFERRED — explicit non-goals)

- **Sub-plan AUTHORING** (only DECOMPOSITION + RECOMMENDED SEQUENCING; the actual sub-plan 034 for F.1 will be authored by a separate sandwich-architect dispatch when main session calls /session-start PLAN at S374)
- **Production code** (this is master-plan authoring; CLAUDE.md § Session Types — never mix PLAN+IMPL)
- **Charter / constitution / human-workspace writes** (out of scope per CLAUDE.md hard rules)
- **AskUserQuestion gate FIRING** (master-plan recommends gates in § K; main session DECIDES whether to fire BUT this plan recommends NON-BLOCKING design per § K.4 ratification path)
- **Library installation / dependency-add to pyproject.toml** (sub-plan 034 STEP 0 evaluates whether RolePromptPack needs new dep — recommended NO; YAML for role packs uses stdlib + existing pyyaml IF pre-installed; otherwise stdlib json fallback)
- **Persona role-prompt-pack content authoring** (sub-plans 035/037 design + author the actual SYSTEM_PROMPT templates per persona; OUT of this master plan)
- **Fine-tuned PhoBERT / Vietnam-domain LLM personality model** (deferred per § A.3 deferral; lexicon + claude_cli_news_transport substrate sufficient for V0)

---

## C. STEP 0 — VBW Live Verification (this MASTER PLAN — light-touch; per-sub-track plans run own STEP 0)

This master plan's STEP 0 is light-touch (the heavy STEP 0s are per-sub-track — sub-plans 034/035/036/037/038 each ship their own VBW live verification):

### Sub-step 0.1 — Existing BC-8 pipeline state audit (VBW — completed inline)

- ✅ `packages/domain/analysis/models/perspective_analysis.py` — PerspectiveAnalysis dataclass + PerspectiveRole 6-value StrEnum shipped; BEAR/BULL/QUANT active + MACRO/BEHAVIOR/MANAGER deferred stubs per :36-39 (`deferred=True` on instances; empty key_points). **Theme H ACTIVATES the deferred stubs + adds personality-pack pattern on top**
- ✅ `packages/domain/analysis/models/thesis.py` — Thesis aggregate root with I-S10 _enforce_bear_case invariant at :91-115 (≥3 distinct points + ≥3 distinct categories) shipped; **Theme H MUST preserve this invariant for V0 personas; if personas other than BEAR also need cross-perspective invariants (e.g. quant ≥3 numbers backed by tool-calls per BR-7), F.3 sub-plan considers extension**
- ✅ `packages/domain/analysis/models/synthesis.py` — Synthesis with I-S12 SynthesisInvariantError at :89-100 (STRONG_CONSENSUS + non-empty disagreements = bug) shipped; **Theme H F.3 sub-plan EXTENDS Phase1Synthesizer to handle N>3 perspectives without bypassing I-S12 invariant**
- ✅ `packages/application/analysis/use_cases/validate_thesis_phase1.py` — ValidateThesisPhase1UseCase shipped with 7-step pipeline (gather→3 perspectives parallel→synthesize→heuristic→thesis→persist→event) per spec 006; **Theme H F.3 extends from N=3 hardcoded to N≥4 generalized**
- ✅ `packages/application/analysis/ports/llm_perspective_port.py` — LLMPerspectivePort Protocol shipped (`analyze(ticker, context, role) → PerspectiveAnalysis`); **Theme H F.1 considers extending OR mirroring this Protocol for RolePromptPack-driven personas; DD-4 below documents**
- ✅ `packages/application/analysis/services/recommendation_heuristic.py` — Pure deterministic Synthesis→Recommendation+ConfidenceLevel pipeline shipped; **Theme H F.3 verifies N>3 perspective path preserves all 4 decision-table cases (BR-3 disagreement override / STRONG_CONSENSUS / MIXED / DISAGREEMENT fallback)**
- ✅ `packages/infrastructure/analysis/perspectives/bear_agent.py` (+ bull_agent.py + quant_agent.py) — 3 existing perspective agents with retry-validator pattern per ADR D-054 + Jaccard distinctness filter + I-S10 strict gate at _validate_bear_output; **Theme H F.2 personality-pack adapters follow the SAME shape as bear_agent.py with role-prompt-pack delegation in lieu of verbatim SYSTEM_PROMPT inline**
- ✅ `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` — ClaudeLLMPerspectiveAdapter shipped; **STILL imports anthropic at line 80** (anthropic_api_to_subagent memory-rule violation surface) + role_model_overrides field per BP-S43b-1 already implemented at line 201; **F.1 transport-flip migration target**

### Sub-step 0.2 — ai-hedge-fund + TradingAgents pattern empirical audit (VBW — completed inline per dispatch brief reference)

- ✅ `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` — empirical FIT HIGH; 19 personas at `src/utils/analysts.py:25-178`; parallel fan-out at `src/main.py:112-115` NO inter-agent messaging; per-perspective Pydantic `{signal: bullish|bearish|neutral, confidence: int 0-100, reasoning: str}` per `warren_buffett.py:13-16`; Portfolio Manager sees only `{ticker: {agent_id: {sig, conf}}}` table per `portfolio_manager.py:160-175`; ANALYST_CONFIG dict registry pattern at `analysts.py:25-178` is the personality-pack-pattern primary source
- ✅ A-01 § 5 third bullet: "Recommendation: adopt this pattern as Wave-1 default for BC-8; defer debate-style until evidence shows ensemble underperforms" — **this is the WAVE-1 DEFAULT we are ratifying** (DD-3 below)
- ✅ A-01 § 6 LICENSE-file MISSING caveat: "Root LICENSE file is MISSING. Pattern-only adoption (C1, C2, C3, C9, C11, C12): no legal issue — patterns are not copyrightable. For code-port (C4, C5, C6, C7, C8, C13): HIGH RISK without clarified license. Recommendation: re-implement from scratch using the pattern documented here; do not copy file contents." — **Theme H sub-plans PATTERN-PORT NOT CODE-PORT**; ZERO verbatim copy of warren_buffett.py / analysts.py / portfolio_manager.py
- ✅ `agent-workspace/research/INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § H.3 verdict "DEBATE-STYLE WINS" — but with 5 mitigations; **DD-3 below INVERTS this verdict for V0** per AP-7 named revisit trigger + 3 strong reasons (existing-BC-8-shape + cost/determinism + AP-1 risk)
- ✅ A-01 § 3 C9 Buffett confidence rubric (90-100/70-89/50-69/30-49/10-29) is LLM-self-reported per A-01 § 5 second-to-last bullet — **REJECTED per I-S1-1 Rule 16 mode 1 categorical surrogate** (we use Conviction STRONG/MODERATE/WEAK enum instead of integer rubric)

### Sub-step 0.3 — Available role-prompt-pack pattern + license audit (VBW — completed inline)

- ai-hedge-fund pattern-source: per-persona file (warren_buffett.py / charlie_munger.py / etc.) with verbatim inline SYSTEM_PROMPT + verbatim Pydantic signal class + verbatim call_llm wrapper — **THIS IS ROLE-CLASS-POLYMORPHISM PATTERN** (each persona = own file + own class + own prompt)
- StockForge existing pattern (bear_agent.py + bull_agent.py + quant_agent.py): SAME role-class-polymorphism pattern with SYSTEM_PROMPT inline at file top per spec § B.5.1/B.5.2/B.5.3
- **DD-4 below decides RolePromptPack-DATA-DRIVEN-PATTERN (NEW for V0) vs ROLE-CLASS-POLYMORPHISM (existing ai-hedge-fund + existing BC-8) trade-off**; recommendation = HYBRID (one base PersonaAgent class + per-persona RolePromptPack data instance — keeps backward-compat with bear_agent/bull_agent/quant_agent while opening door to N personas via data-only addition)
- License audit per D-061 § Item 4 + A-01 § 6: ai-hedge-fund LICENSE-file MISSING; pattern-only adoption safe; no code-copy lines verbatim from any ai-hedge-fund file in Theme H sub-plans (architect explicit veto)

### Sub-step 0.4 — Rule 16 surface audit for Theme H (BINDING per § Charter compliance per D-065)

Theme H introduces these candidate schema fields where Rule 16 (I-S1-1) applies:

- **Per-persona overall_conviction** (existing field at `perspective_analysis.py:57` `overall_conviction: Conviction`) — **Rule 16 satisfaction mode 1 (categorical surrogate)**: Conviction StrEnum STRONG/MODERATE/WEAK; LLM picks category; deterministic code maps to numeric if needed downstream; no LLM-emitted integer
- **Per-persona cost_usd** (existing field at `perspective_analysis.py:58` `cost_usd: Decimal`) — **Rule 16 satisfaction mode 2 (deterministic-pipeline echo)**: cost computed by `_compute_cost(model, input_tokens, output_tokens)` deterministic function per `claude_llm_perspective_adapter.py:?`; LLM never echoes cost; never produces cost value
- **Per-persona key_points GroundedPoint.conviction** (existing field at `grounded_point.py:51` `conviction: Conviction`) — **Rule 16 satisfaction mode 1 (categorical surrogate)**: SAME pattern as overall_conviction
- **Aggregate confidence_level on Thesis** (existing field at `thesis.py:81` `confidence_level: ConfidenceLevel | None`) — **Rule 16 satisfaction mode 2 (deterministic-pipeline echo)**: `confidence_from_synthesis(synthesis)` pure function at `recommendation_heuristic.py:72-80`; no LLM involvement
- **NEW: Per-persona calibration_grade (POSSIBLE F.4 extension)** — defer; not in V0 scope; if added in F.4-V2, satisfaction mode 3 (calibration-database lookup keyed on extractor_version + persona_id)
- **Aggregate final_recommendation on Thesis** (existing field at `thesis.py:80` `final_recommendation: Recommendation | None`) — Recommendation StrEnum INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE; **Rule 16 N/A (enum not numeric)** — categorically by-design satisfies I-S35

**Verdict**: All Theme H candidate numeric fields satisfy Rule 16 via mode 1 (categorical surrogate via Conviction enum) or mode 2 (deterministic-pipeline echo via recommendation_heuristic pure functions). **No mode 3 (calibration lookup) needed yet** because per-persona calibration is post-MVP. **No mode 4 (NULL surrogate) needed** because all fields have deterministic computation paths.

**Charter-tier-surface FLAG**: If F.4 sub-plan surfaces a new schema field where Rule 16 mode 1+2 cannot apply (e.g. "persona-rotation weight" as numeric float for cross-persona aggregation), that's a Charter-tier-surface FLAG event — F.4 STEP 0 STOP-AND-ASK clause triggers. **No FLAG at this master-plan level — Theme H as scoped satisfies Rule 16 by construction.**

### Sub-step 0.5 — anthropic_api_to_subagent memory-rule check for BC-8

Per `anthropic_api_to_subagent` memory rule: "For every `ANTHROPIC_API_KEY` / direct `anthropic` SDK call: refactor to Claude Code subagent dispatch (subscription billing, not API metered); systemic rule".

- ✅ Existing `claude_llm_perspective_adapter.py:80` uses `import anthropic` direct SDK call inside `_default_transport()` function (LEGACY — Phase F-prime F.1 sub-plan refactor surface; **D-051/D-052 ratified the policy + D-072 applied it to BC-5 News; F.1 applies it to BC-8 Perspective**)
- **F.1 sub-plan MUST refactor `_default_transport` → `make_claude_cli_news_transport()` equivalent factory** OR create a parallel `make_claude_cli_perspective_transport()` factory if signature differs; DD-5 below documents
- **Carry-forward as RM in § J**: RM-AS-1 (anthropic→subagent memory-rule refactor surface for BC-8) — F.1 sub-plan MUST decide migration path + commit to backward-compat strategy for existing test_adapter.py + test_bear_agent.py + test_quant_agent.py

### Sub-step 0.6 — Existing related-pattern grep audit

- ✅ `Grep RolePromptPack|PersonaRegistry|personality_pack|persona_pack` (production code) returns 0 matches — **clean baseline for F.1 to add first production use**
- ✅ `Grep warren_buffett|graham|charlie_munger|peter_lynch|nassim_taleb` (production code) returns 0 matches — **clean baseline for F.2/F.4 to add first production use**
- ✅ `packages/application/analysis/` directory exists (already has ports/use_cases/services subdirectories) — F.1 sub-plan adds new `role_prompt_pack.py` + `persona_registry.py` modules at package root (parallel to use_cases/services subdirectories)
- ✅ `packages/infrastructure/analysis/perspectives/` directory exists with 3 active agents (bear/bull/quant) + 2 test files (test_bear_agent.py + test_quant_agent.py); F.2 adds 3 new persona files (buffett_agent.py + graham_agent.py + taleb_agent.py) parallel to existing
- ✅ `agent-workspace/role-packs/` directory does NOT exist yet — F.1 OR F.2 creates it for YAML role-prompt-pack content (per supplement § H.4 IMPL-slot)
- ✅ `apps/cli/synthesize_vn_thesis.py` does NOT exist yet — F.5 creates it; pattern reference = `apps/cli/extract_vn_claims.py` shipped at S368 + `apps/cli/score_vn_sentiment.py` shipped at S365 + `apps/cli/resolve_vn_tickers.py` shipped at S371 (3 CLI precedents from Phase E)

### Sub-step 0.7 — STEP 0 summary write (this master plan)

All 6 sub-steps PASS. No STOP-AND-ASK triggered at master-plan level. **3 charter-tier-surface FLAGS surfaced at sub-plan level** (see § K.2) — main session DECIDES whether to fire AskUserQuestion gate; this plan's RECOMMENDATION is NON-BLOCKING design path (architect-recommended default chosen per DD-2/DD-3/DD-4; sub-plan STEP 0s STOP-AND-ASK if architect-recommended default proves wrong empirically).

---

## D. Architecture Decisions (DD-1 through DD-12)

### DD-1: Phase F-prime is a PHASE-MASTER-PLAN, NOT a single multi-sub-track FOCUSED_IMPL

**Decision**: Author this as a PHASE-MASTER-PLAN that decomposes Phase F-prime into 5 follow-on per-sub-track PLAN+IMPL+VERIFY chains (sub-plans 034/035/036/037/038). Each sub-plan = own PLAN session (50-80K Opus) + own IMPL session (100-150K Opus FOCUSED_IMPL) + own VERIFY session (30-60K Opus AP-1).

**Rationale**:
- **CLAUDE.md hard rule**: "Never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)" — bundling 5 sub-tracks + their IMPL into one session = high-risk mix
- **Precedent**: Phase E plan-028 master-plan = 4 sub-themes per-PLAN+IMPL+VERIFY chain (sub-plans 029/030/031/032 ALL SHIPPED); Phase D Theme L = 4 per-source sub-plans (plan-020/022/026/027) each = own PLAN+IMPL+VERIFY chain — **Phase F-prime follows the same rhythm with 5 sub-tracks**
- **Per CLAUDE.md § Session Types budget envelopes**: a single MULTI-TASK IMPL = 150-250K; 5 sub-tracks at 100-150K IMPL each = 500-750K cumulative IMPL = clearly exceeds MULTI-TASK ceiling
- **Phase 1b cold-start risk**: bundling cold-start work into one session amplifies the cold-start risk per L-S354-2 cascade; per-sub-track PLAN sessions let each sub-track calibrate INCREMENTALLY (n=0 → n=1 → n=2 → n=3 → n=4 for `multi-perspective-plan` task_class)

**Adversarial alternate considered**: Single MULTI-TASK IMPL S374 covering all 5 sub-tracks → REJECTED per CLAUDE.md hard rule + budget envelope + Phase 1b cold-start risk amplification.

### DD-2: V0 persona count = ratification-gated (architect recommends N=6) — NON-BLOCKING design

**Decision**: V0 persona count is gated through a NON-BLOCKING design pattern:
- **Architect-recommended default V0=6**: BEAR + BULL + QUANT (existing 3 active) + BUFFETT + GRAHAM + TALEB (3 new in F.2)
- F.4 sub-plan IMPL adds 3 MORE personas (CHARLIE_MUNGER + PETER_LYNCH + VN_DOMAIN_SPECIALIST) ONLY if user RATIFIES V0=6+3=9 expansion path
- **NON-BLOCKING design**: Phase F-prime proceeds with V0=6 by default UNLESS user explicit opt-in to V0=9 via NON-BLOCKING Q-INT-2026-05-F-prime-1 (see § K.1)
- Spec 004 § A.2 enumerates 6 perspective archetypes (Bear / Bull / Quant / Macro / Behavior / Manager) — the 3 existing + 3 deferred-stub map 1:1 to spec; F.2 personality-pack pattern ADDS Buffett / Graham / Taleb as alternative axis (personality-grounded vs role-grounded)

**Vietnam-relevance evidence chain for V0=6 personas**:
- **BUFFETT** (value investor, quality + moat focus): VN domestic value plays exist (VHM long-term holds; VIC conglomerate moat); fits VN30 universe blue-chip subset; **HIGH-relevance V0**
- **GRAHAM** (deep value, margin of safety, balance-sheet-focused): VN banking sector exposure + VinGroup-class conglomerates with complex balance sheets; **HIGH-relevance V0**
- **TALEB** (antifragility, tail-risk, kurtosis): VN F0 retail-dominated market is high-tail-risk regime; "đội lái" pump-cluster phenomena = textbook tail-risk surface; **VERY-HIGH-relevance V0** (per A-01 § 3 C13 cite + A-14 retail-culture cite)
- **MUNGER** (mental-model latticework, anti-fragile thinking adjacency): partial overlap with TALEB; lower urgency for V0
- **LYNCH** (peter-lynch growth-at-reasonable-price, retail-investor-friendly): VN consumer brand exposure + bottom-up stock-picking culture aligns; HIGH-relevance for V0-V2
- **VN_DOMAIN_SPECIALIST** (custom — VN-specific market microstructure: ATO/ATC, T+2.5 settlement, sàn tiering, room ngoại, đội lái): UNIQUELY VN; NO foreign-fund parallel; **mandatory-eventually but V0-V2 OK** (existing BEHAVIOR perspective stub at packages/domain/analysis/models/perspective_analysis.py:38 can absorb in V0 via prompt-pack content)

**Rationale**: V0=6 maintains decision granularity (each persona is one prompt-pack + one adapter file ≤500 LOC per Karpathy P3) without over-engineering; Vietnam-relevance subset preserves Charter Principle 4 moat; expansion to N=9 is V0-V2 deferral with named user-ratification trigger.

**Adversarial alternate considered**: V0=4 (BEAR + BULL + QUANT + BUFFETT only) — MORE conservative — REJECTED because (a) Spec 004 A.2 enumerates 6 archetypes, V0=4 leaves spec gap, (b) GRAHAM + TALEB add distinct value-investor + tail-risk perspectives that BEAR alone cannot cover, (c) F.4 sub-plan loses scope justification if V0=4 (no expansion to anchor on).

**Adversarial alternate considered**: V0=19 (full ai-hedge-fund port) — REJECTED per Charter Principle 7 dogfood-first + A-01 § 5 caveats + Karpathy P2 simplicity; pattern-port + Vietnam-relevance subset is correct V0.

### DD-3: V0 aggregation strategy = ISOLATED-THEN-AGGREGATE (INVERTS H.3 supplement verdict per AP-7 named revisit trigger)

**Decision**: V0 ships ISOLATED-THEN-AGGREGATE aggregation pattern (per A-01 § 5 third-bullet "Wave-1 default") — NOT debate-style (which H.3 supplement recommends as principled fit for I-S12 literal compliance). H.3 verdict is **REVISITED at Phase F-prime-V2** per AP-7 named revisit trigger after V0 dogfood demonstrates shallow-disagreement on 3+ tickers.

**Three strong reasons for V0 INVERSION**:

1. **Existing BC-8 shape is isolated-then-aggregate** — packages/application/analysis/use_cases/validate_thesis_phase1.py:221 `asyncio.gather(bear_t, bull_t, quant_t)` is the existing parallel fan-out pattern + Phase1Synthesizer deterministic aggregation at recommendation_heuristic.py:36-69. **Theme H EXTENDS rather than rewrites — preserves backward-compat with Phase 2 spec 006 AC-5 reproducibility + existing test_use_case.py + test_synthesizer.py regression-floor**. Debate-style would REWRITE this orchestration shape end-to-end.
2. **Per H.3 trade-off table (lines 180-190)**: debate-style wins ONLY on "I-S12 literal compliance" (1 of 9 properties); isolated wins on cost/latency/determinism/AP-1-risk (4 of 9 properties); per-row score isolated > debate
3. **AP-1 mitigation simpler with isolated** — debate-style requires "fresh-context judge subagent" per H.3 mitigation #3 to mitigate AP-1; isolated has NO inter-agent messaging so AP-1 risk is structurally zero. V0 simplicity > Phase F-prime-V2 sophistication.

**H.3 verdict-and-mitigation #5 actually supports V0 isolated**: "First adapt ai-hedge-fund's per-perspective dataclass + plugin registry pattern (A-01 § 3 C1+C2) — {signal, confidence, reasoning} + ANALYST_CONFIG dict — as the substrate for each debate participant. **Debate participants are still individually-isolated for their own reasoning step**; what's shared is the cross-rebuttal in subsequent rounds." — V0 ships the SUBSTRATE (per-perspective dataclass + plugin registry) that DEBATE-V2 would build on top.

**AP-7 named revisit trigger** for DEBATE-V2: After V0 dogfood produces (i) shallow disagreement on 3+ different VN tickers (per-persona verdicts converge artificially WITHOUT rebuttal cycle) OR (ii) V0 dogfood produces excessive false-WATCH outputs where user empirically prefers DISAGREEMENT-marked output, dispatch Phase F-prime-V2 PLAN session with DEBATE-pattern decomposition.

**Rationale**: Karpathy P2 simplicity-first + Karpathy P3 surgical-changes-preserves-backward-compat + AP-7 anti-vacuous-defer (the revisit trigger IS named, not "later"); A-01 § 5 third-bullet WAVE-1 DEFAULT is explicit.

**Adversarial alternate considered**: Debate-style V0 per H.3 verdict — REJECTED per 3 strong reasons above + H.3 itself flags "Adversarial alternate kept on shelf: if Wave-1 IMPL empirically shows debate-style cost (quadratic token growth) exceeds value, fall back to isolated-then-aggregate (ai-hedge-fund pattern)". **We START at the fallback and earn debate-V2 with V0 evidence.**

### DD-4: V0 persona pattern = HYBRID (RolePromptPack data-driven + thin per-persona adapter class)

**Decision**: V0 uses a HYBRID pattern combining:
- **Data-driven RolePromptPack** (NEW for V0; design = dataclass + YAML loader) at `packages/application/analysis/role_prompt_pack.py` defining `RolePromptPack(role_id, persona_name, system_prompt_template, conviction_guidance, citation_requirements, vietnam_notes, ...)` immutable dataclass + `PersonaRegistry` lookup at `packages/application/analysis/persona_registry.py`
- **Thin per-persona adapter class** in `packages/infrastructure/analysis/perspectives/` (parallels existing bear_agent.py / bull_agent.py / quant_agent.py file-per-role structure) that delegates SYSTEM_PROMPT to RolePromptPack lookup + preserves existing retry-validator pattern from ADR D-054 + Jaccard distinctness filter

**Why HYBRID not pure-data-driven**:
- **Per-persona retry-validator semantics differ** — bear_agent.py has `_validate_bear_output` I-S10 strict gate (≥3 distinct categories) at lines 145-195 that is BEAR-specific; quant_agent.py has different validation (numeric-tool-call-grounding) per BR-7; buffett_agent.py V0 needs (a) moat-grounding gate, (b) per-category enforcement different from BEAR's
- Pure-data-driven would require generic validation framework = over-engineering; thin per-persona class lets each adapter own its validator while sharing SYSTEM_PROMPT template via RolePromptPack
- **Backward-compat with existing bear_agent/bull_agent/quant_agent** — these don't need refactor for V0; they can incrementally adopt RolePromptPack (e.g. bear_agent.py SYSTEM_PROMPT at L41-77 migrated to RolePromptPack in F.2 sub-plan OR deferred to F.4-V2)

**Why HYBRID not pure-class-polymorphism (ai-hedge-fund style)**:
- ai-hedge-fund's `warren_buffett.py` is 826 LOC with ~750 LOC deterministic Python math + inline SYSTEM_PROMPT — over Karpathy P3 ≤500 LOC ceiling; V0 personas should be ~150-300 LOC each (delegating SYSTEM_PROMPT to RolePromptPack and reusing base retry-validator infrastructure)
- Pure class-polymorphism without shared substrate = duplicate retry-validator logic per persona = test-burden inflation

**Rationale**: Per A-01 § 3 C2 (plugin registry pattern) + A-01 § 3 C1 (per-perspective signal contract) + existing BC-8 file-per-role precedent + Karpathy P3 surgical + DDD tactical patterns (data-driven configuration in application layer; behavior in infrastructure adapter).

**Adversarial alternate considered**: Pure-data-driven (one BasePersonaAgent class + RolePromptPack data-only addition for new personas) — REJECTED per per-persona validator semantics differ above.

**Adversarial alternate considered**: Pure-class-polymorphism (no RolePromptPack; just N persona files like bear_agent.py) — REJECTED per N>6 personas without shared substrate = duplicate code + harder cross-persona changes (e.g. updating Vietnam-notes section across 6+ files).

### DD-5: BC-8 transport-flip migration = mirror D-072 strategy (transport: Callable default-flip to claude_cli_news_transport-equivalent)

**Decision**: Sub-plan 034 (F.1) ships BC-8 transport-flip with this strategy:
1. **Audit existing `claude_llm_perspective_adapter.py` transport signature** — `(model: str, system_prompt: str, user_message: str, temperature: float) → (text: str, in_tok: int, out_tok: int)` (4-arg → 3-tuple); compare with `claude_cli_news_transport(system_prompt, body, *, model, timeout_sec) → str` (2-arg → str) — **signatures DIFFER**
2. **Author NEW `make_claude_cli_perspective_transport()` factory** at `packages/infrastructure/analysis/claude_cli_perspective_transport.py` (NEW file mirroring `packages/infrastructure/news/claude_cli_news_transport.py:96-156`) that wraps `claude` CLI invocation but returns 3-tuple (text, in_tok, out_tok) matching existing perspective adapter contract; reuses subprocess invocation pattern verbatim + SubagentSubstrateError + JSON envelope parsing
3. **Default-flip `ClaudeLLMPerspectiveAdapter.transport` field** at `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:197-199` from `_default_transport` (which imports anthropic) to `field(default_factory=make_claude_cli_perspective_transport)` — exactly mirrors D-072 D.2 default-flip pattern
4. **REMOVE `_default_transport()` function + `import anthropic` line at :80** — exactly mirrors D-072 D.2 REMOVED clauses
5. **Preserve test-injection pattern** — test_adapter.py + test_bear_agent.py + test_quant_agent.py STILL inject stub transport via constructor kwarg (existing pattern; D-072 confirmed this works for BC-5; BC-8 should work identically)
6. **Regression floor MANDATORY** — all existing perspective adapter tests + bear_agent/bull_agent/quant_agent tests PASS unchanged

**Rationale**: Direct mirror of D-072 sub-plan 031 IMPL pattern that SHIPPED at S368 + verified at S369; precedent reduces architect+dev cognitive load + minimizes regression risk via proven migration shape.

**Adversarial alternate considered**: Adapt existing `claude_cli_news_transport()` factory directly via signature-shim adapter — REJECTED (signature mismatch + token-count returns DIFFER; news transport returns str only, perspective adapter needs 3-tuple; cleaner to author parallel factory than shim existing).

**Adversarial alternate considered**: Defer BC-8 transport-flip to separate harness sub-plan — REJECTED (F.1 introduces new RolePromptPack contract THROUGH the adapter; bundling transport-flip avoids touching adapter twice).

### DD-6: RolePromptPack location = `packages/application/analysis/` package-root (NOT subdirectory)

**Decision**: RolePromptPack + PersonaRegistry live at `packages/application/analysis/role_prompt_pack.py` + `packages/application/analysis/persona_registry.py` (package root, parallel to existing ports/use_cases/services subdirectories).

**Rationale**:
- **They are NOT ports** — ports define infrastructure-adapter contracts; RolePromptPack is data-content (system prompt template strings + persona metadata); doesn't belong in `ports/` subdir
- **They are NOT use cases** — use cases orchestrate; RolePromptPack is consumed BY use cases; doesn't belong in `use_cases/` subdir
- **They are NOT services** — services are stateless logic; RolePromptPack is data definition; thin overlap but distinction = RolePromptPack ships immutable persona DEFINITIONS; services CONSUME RolePromptPack to derive behavior
- **Package-root parallels DDD tactical "factory" pattern** — `PersonaRegistry.get(role_id) → RolePromptPack` is factory-shape lookup
- **Precedent**: `packages/application/news/` has port + use_cases + commands + queries at package root level (see `packages/application/news/ports/llm_extractor_port.py` package layout)

**Adversarial alternate considered**: `packages/application/analysis/personas/role_prompt_pack.py` (new personas/ subdir) — REJECTED (over-folder-ing; only 2 files for V0 = subdir-overhead > clarity gain; if persona count balloons to N=10+ with N files, then create personas/ subdir at F.4-V2 trigger).

**Adversarial alternate considered**: `packages/domain/analysis/value_objects/role_prompt_pack.py` (domain layer) — REJECTED (RolePromptPack is application-tier configuration data; domain layer is for invariants; per architecture.md cross-BC discipline + I-S1 charter rule "domain layer has ZERO framework dependency" — application-tier is correct location).

### DD-7: RolePromptPack contract shape = frozen dataclass (NOT Protocol + NOT ABC)

**Decision**: RolePromptPack is a `@dataclass(frozen=True, slots=True)` with these fields (NOT a Protocol, NOT an ABC):
- `role_id: str` (unique key for PersonaRegistry lookup; e.g. "buffett" / "graham" / "taleb")
- `persona_name: str` (human-readable; e.g. "Warren Buffett (value + quality + moat)")
- `system_prompt_template: str` (verbatim SYSTEM_PROMPT with `{TICKER}` + `{AS_OF}` placeholders)
- `conviction_guidance: str` (per-persona rubric instructing LLM how to pick STRONG/MODERATE/WEAK Conviction enum per category)
- `citation_requirements: str` (per-persona Rule 6 grounding mandate; can mirror BEAR's verbatim ≤500 char + source_url + source_excerpt format)
- `vietnam_notes: str` (per-persona VN context — "VHM is VinGroup-affiliated"; "đội lái" pump-signal awareness; etc.)
- `min_points: int` (per-persona minimum key_points count; e.g. BEAR ≥3 per I-S10 / BULL ≥3 per analogy)
- `min_distinct_categories: int` (per-persona minimum distinct GroundedPoint.category count; ≥3 for BEAR)
- `category_universe: tuple[str, ...]` (per-persona allowed BearCategory enum-like values; e.g. BEAR uses {FUNDAMENTAL, STRUCTURAL, VALUATION, COMPETITIVE, GOVERNANCE, MACRO}; BUFFETT might use {MOAT, MANAGEMENT, VALUATION, ROIC, BALANCE_SHEET, GROWTH})
- `model_id_preference: str | None` (per-persona LLM model override; None = use existing _ROLE_TO_MODEL[role] default)

**Rationale**:
- **Frozen dataclass = data definition** — matches domain value object precedent (GroundedPoint, Conviction, Recommendation, etc.); immutable + slotted for performance
- **NOT Protocol** — Protocol is for adapter contracts; RolePromptPack is data not behavior
- **NOT ABC** — ABC implies inheritance (PersonaRegistry would lookup by subclass); data class with role_id key is cleaner lookup pattern
- **D-066 precedent (CrawlerAdapter ABC)** — D-066 chose ABC for CrawlerAdapter because CrawlerAdapter has behavior + crawler-source-specific overrides; RolePromptPack has NO behavior overrides per persona (validator behavior lives in the adapter class)
- Per A-01 § 3 C2: ai-hedge-fund's ANALYST_CONFIG dict at analysts.py:25-178 is ALSO data-only `{key: {display_name, description, investing_style, agent_func, type, order}}` — direct precedent

**Adversarial alternate considered**: Protocol with `get_system_prompt()` + `get_validation_gate()` methods — REJECTED (over-abstraction for V0; data dict suffices).

**Adversarial alternate considered**: ABC with abstract `_validate_output()` method — REJECTED (per DD-4 HYBRID rationale: per-persona validator lives in the adapter class, not in RolePromptPack data).

### DD-8: PersonaRegistry lookup mechanism = stdlib dict + YAML loader (NO new dep)

**Decision**: PersonaRegistry is a thin wrapper around `dict[str, RolePromptPack]` with:
- `get(role_id: str) → RolePromptPack` (raises KeyError if not registered)
- `register(pack: RolePromptPack) → None` (registers at startup; called during module-load OR composition-root via PersonaRegistry constructor with all packs)
- `all_role_ids() → tuple[str, ...]` (introspection for CLI enumeration + tests)
- `load_from_yaml(yaml_path: Path) → None` (loads from `agent-workspace/role-packs/*.yaml` files via stdlib + already-installed pyyaml IF present; otherwise stdlib json fallback path with explicit warning)

**Rationale**:
- **stdlib dict** = simplest possible registry; A-01 § 3 C2 ANALYST_CONFIG is also dict-typed
- **YAML loader** = supplement § H.4 IMPL-slot recommends YAML format for role packs ("Maps `agents/utils/agent_states.py:7-43` TypedDicts to stockforge `packages/domain/synthesis/` value-objects (dataclass, NOT Pydantic — domain layer rule)")
- **NO new dep** — pyproject.toml audit at sub-plan 034 STEP 0 confirms pyyaml availability; if not present, fallback to JSON (less human-friendly but works)
- **Composition root pattern** — main.py / CLI entry points create PersonaRegistry instance + register all packs; mirrors existing ClaudeLLMPerspectiveAdapter composition pattern at validate_thesis_phase1.py:153-171

**Adversarial alternate considered**: Auto-discovery via `pkgutil.walk_packages('role_packs')` — REJECTED (over-engineering for V0; explicit registry is clearer + testable).

**Adversarial alternate considered**: Database table (SQLite) — REJECTED (premature optimization for V0; YAML files are git-versioned + human-editable).

### DD-9: Per-persona adapter location = mirror existing `packages/infrastructure/analysis/perspectives/`

**Decision**: F.2 personality-pack adapters (buffett_agent.py / graham_agent.py / taleb_agent.py) live at `packages/infrastructure/analysis/perspectives/` mirroring existing 3-active-agent layout (bear_agent.py / bull_agent.py / quant_agent.py).

**Rationale**:
- **Existing precedent** — bear/bull/quant adapters already at `packages/infrastructure/analysis/perspectives/`; consistency principle
- **One file per persona** mirrors ai-hedge-fund pattern `src/agents/warren_buffett.py` etc. + StockForge existing pattern
- **Adapter inherits or delegates to common base** — F.2 sub-plan considers whether to introduce `BasePersonaAgent` class at `perspectives/_base_persona_agent.py` for shared retry-validator + Jaccard logic OR keep per-persona file standalone (duplicate the ~150 LOC retry loop); architect leans toward shared base IF code duplication exceeds 100 LOC per persona, otherwise standalone (Karpathy P2)

**Adversarial alternate considered**: `packages/infrastructure/analysis/personas/buffett_agent.py` (new personas/ subdir) — REJECTED (existing perspectives/ has BEAR/BULL/QUANT already; new personas live alongside, not in separate subdir; AVOID file-relocation churn).

### DD-10: F.3 SynthesizePerspectivesUseCase extension strategy = EXTEND existing ValidateThesisPhase1UseCase (NOT new use case)

**Decision**: F.3 sub-plan EXTENDS existing `ValidateThesisPhase1UseCase` rather than creating a new use case:
1. **Refactor 3-perspective hardcoded asyncio.gather at validate_thesis_phase1.py:218-221** to generalized N-perspective dispatch: accept `agents: dict[str, LLMPerspectivePort]` (where key = role_id) instead of hardcoded bear_agent/bull_agent/quant_agent dependencies
2. **Refactor 3-perspective tuple at :226** `(bear_p, bull_p, quant_p)` to generalized `tuple(PerspectiveAnalysis, ...)` with len N
3. **Extend Phase1Synthesizer** at `packages/infrastructure/analysis/phase1_synthesizer.py` to handle N-perspective tradeoff matrix:
   - Bear-vs-Bull disagreement detection generalizes to "any-pair disagreement" across N personas
   - Confluence calculation generalizes to "majority categorical" or "weighted-by-conviction" (architect leans MAJORITY-CATEGORICAL per Karpathy P2 simplicity; weighted-by-conviction is a F.3-V2 refinement)
4. **Preserve I-S10 bear-case invariant** — Thesis._enforce_bear_case at thesis.py:91-115 STILL requires BEAR perspective + ≥3 distinct points + ≥3 distinct categories; N≥4 personas extends this with BEAR-still-present invariant
5. **Preserve I-S12 disagreement invariant** — Synthesis.__post_init__ at synthesis.py:89-100 STILL forbids STRONG_CONSENSUS with non-empty disagreements; N-persona path computes any-pair-disagreement-detected → DISAGREEMENT confluence
6. **AC-5 reproducibility regression** — thesis_id at validate_thesis_phase1.py:127-139 currently uses combined_prompt = ":".join(p.prompt_hash for p in perspectives) — already supports N>3 perspectives by construction; **regression-test that thesis_id is deterministic per (model, N-persona prompt hashes, ticker, as_of, data_md5) tuple**

**Rationale**:
- Karpathy P3 surgical-changes — extend rather than replace
- AC-5 reproducibility regression risk mitigated via test coverage in F.3 sub-plan
- Backward-compat with existing test_use_case.py + test_synthesizer.py preserved

**Adversarial alternate considered**: Author NEW `SynthesizePerspectivesUseCase` parallel to ValidateThesisPhase1UseCase — REJECTED (duplicate orchestration logic; F.3 ships ONE use case that handles 3+N personas via dict-typed agents param; existing 3-persona call sites construct dict {BEAR: bear_agent, BULL: bull_agent, QUANT: quant_agent}; new 6-persona call sites construct dict with 6 entries).

### DD-11: F.5 CLI dogfood ticker = project-owner-pick (architect recommends VHM)

**Decision**: F.5 sub-plan CLI dogfood runs on ONE project-owner-picked VN30 ticker. **Architect recommendation: VHM (Vinhomes)**.

**VHM rationale**:
- Already in alias table at `agent-workspace/ubiquitous-language/vn_ticker_aliases.md` (shipped S371 Phase E.4) — ticker resolution path tested
- VinGroup conglomerate complexity = good stress test for multi-perspective (BUFFETT moat angle + GRAHAM balance-sheet complexity + TALEB tail-risk of related-party transactions exposure)
- Vietnamese-language news coverage extensive (CafeF + NDH + Vietstock + VietnamBiz all covered VHM in 2024-2025 corpus per Phase E.2 lexicon dogfood)
- HIGH familiarity for project owner (per memory user.md indicates VN market expertise)

**Alternate tickers considered**:
- HPG (Hoa Phat steel): industrial; QUANT-heavy; less BUFFETT/GRAHAM angle
- VIC (Vingroup parent): too-conglomerate; complexity may overwhelm V0
- FPT: tech; less Vietnam-specific anchor surface

**Non-blocking design**: Project owner can override VHM pick at F.5 sub-plan STEP 0 STOP-AND-ASK clause WITHOUT triggering Q-INT (no charter implication).

**Rationale**: Charter Principle 7 dogfood-first; one-ticker focus reduces V0 complexity (Karpathy P2); allows F.5 verifier to focus on per-persona output quality + AC-5 reproducibility + aggregate Recommendation correctness on one well-known case.

### DD-12: Per-persona LLM model preference = existing _ROLE_TO_MODEL routing (Sonnet for BEAR/BULL/+new value-investors; Opus for QUANT/Synthesizer)

**Decision**: V0 persona-pack model routing follows existing `_ROLE_TO_MODEL` map at `claude_llm_perspective_adapter.py:65-69`:
- BEAR / BULL / BUFFETT / GRAHAM / TALEB → claude-sonnet-4-6 ($3/MTok in + $15/MTok out)
- QUANT / [synthesizer use case] → claude-opus-4-7 ($15/MTok in + $75/MTok out)
- RolePromptPack.model_id_preference allows per-persona override (e.g. TALEB might prefer Opus for tail-risk reasoning depth — defer to F.4 user pick)

**Rationale**:
- Existing BC-8 routing already differentiates cost-sensitive (Sonnet) vs reasoning-heavy (Opus) — Theme H new personas slot into existing matrix
- BUFFETT/GRAHAM are value-investor perspectives = predominantly qualitative reasoning = Sonnet-class capability sufficient
- QUANT is numeric/computational reasoning = Opus-class capability justified
- Cost-control: 6 personas × Sonnet ≈ 6 × ($3+$15)/MTok = $108/MTok cumulative; 6 personas × Opus ≈ $540/MTok = 5× more expensive; V0 keeps Sonnet for value personas + Opus only for QUANT preserves cost profile
- Cost budget at validate_thesis_phase1.py:187 scoped_budget(limit_usd=Decimal("3.00")) per thesis; with 6 personas + Synthesizer + retry overhead, budget tightness considered; F.5 dogfood empirical cost = decision input for F.4-V2 budget adjustment

**Adversarial alternate considered**: All-Opus V0 — REJECTED (5× cost increase without empirical justification; Sonnet sufficient for value-investor reasoning per A-01 § 3 C9 Buffett confidence rubric not requiring Opus-class reasoning).

**Adversarial alternate considered**: All-Haiku V0 — REJECTED (Haiku may underperform on complex multi-category bear-case construction; existing role_model_overrides path at :201 allows per-call Haiku override if cost spike empirically observed, but V0 default is Sonnet).

---

## E. Sub-plan decomposition (sub-plans 034/035/036/037/038 — sequencing + parallel_with per plan-025 contract)

### Sub-plan 034 — F.1 RolePromptPack + PersonaRegistry foundation + BC-8 transport-flip

- **plan_id**: 034-S374-phase-fprime-rolepromptpack-and-transport-flip (target dispatch S374)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S375 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S376 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [] (BLOCKS F.2 + F.3 + F.4 + F.5)
- **blocks_on**: [] (root sub-plan)
- **coordination_paths_exclusive**: [packages/application/analysis/role_prompt_pack.py (NEW), packages/application/analysis/persona_registry.py (NEW), packages/infrastructure/analysis/claude_cli_perspective_transport.py (NEW), packages/infrastructure/analysis/claude_llm_perspective_adapter.py (EDIT — default-flip + remove import anthropic), packages/application/analysis/test_role_prompt_pack.py (NEW), packages/application/analysis/test_persona_registry.py (NEW), packages/infrastructure/analysis/test_adapter.py (REGRESSION — add transport-flip TC)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 30-45 min (transport-flip migration + new contracts) / VERIFY 10-15 min
- **STEP 0 evaluation surface**: pyyaml availability check; existing transport signature audit; ai-hedge-fund ANALYST_CONFIG pattern read for design inspiration (READ-ONLY; no copy)
- **DoD floor**: ≥15 unit tests (RolePromptPack frozen invariants + PersonaRegistry lookup edges + transport-flip regression); mypy --strict + ruff + pytest green; existing perspective adapter tests STILL pass (regression floor); grep-assert ZERO `import anthropic` in BC-8 production code
- **ADR landing**: D-074 PROPOSED at IMPL tier (per severity-schema auto-ratifies on commit) — "BC-8 Transport Flip + RolePromptPack Foundation"
- **Charter-tier touch**: NONE (data structures + transport migration; no constitution mutation)

### Sub-plan 035 — F.2 First 3 personality-pack adapters (Buffett / Graham / Taleb)

- **plan_id**: 035-S376-phase-fprime-first-3-personas (target dispatch S376 OR later — after sub-plan 034 VERIFY ships)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S377 (sandwich-dev FOCUSED_IMPL ~100-150K) + VERIFY S378 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [] (BLOCKS F.3; F.4 may run parallel post-F.3)
- **blocks_on**: [034-S374-phase-fprime-rolepromptpack-and-transport-flip]
- **coordination_paths_exclusive**: [packages/infrastructure/analysis/perspectives/buffett_agent.py (NEW), graham_agent.py (NEW), taleb_agent.py (NEW), packages/infrastructure/analysis/perspectives/_base_persona_agent.py (NEW IF F.2 decides shared base — DD-9), agent-workspace/role-packs/buffett.yaml + graham.yaml + taleb.yaml (NEW), packages/infrastructure/analysis/perspectives/test_buffett_agent.py + test_graham_agent.py + test_taleb_agent.py (NEW)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 35-50 min (3 personas × ~150 LOC each + per-persona role-pack YAML authoring + per-persona retry-validator tests) / VERIFY 12-18 min
- **STEP 0 evaluation surface**: per-persona prompt template design + Vietnam-notes content authoring + per-persona category_universe definition; sandwich-architect can dogfood role-prompt-pack draft against ai-hedge-fund warren_buffett.py (READ-ONLY) for pattern inspiration
- **DoD floor**: ≥15 unit tests (3 personas × ≥5 tests each — happy-path + retry-validator + Jaccard distinctness + I-S10-or-equivalent category-distinctness gate + invalid-LLM-output handling); mypy + ruff + pytest green; per-persona dogfood smoke (architect-internal; pre-F.5) verifies per-persona JSON contract compliance
- **ADR landing**: D-075 PROPOSED at IMPL tier — "BC-8 First 3 Personality-Pack Adapters (Buffett/Graham/Taleb)"
- **Charter-tier touch**: NONE expected; FLAG if per-persona prompt template surfaces unanticipated charter-tier issue (e.g. persona LLM emits buy/sell directly bypassing Recommendation enum — I-S35 violation surface; sub-plan 035 STEP 0 STOP-AND-ASK)

### Sub-plan 036 — F.3 SynthesizePerspectivesUseCase extension to N≥4 personas

- **plan_id**: 036-S378-phase-fprime-synthesize-N-personas (target dispatch S378 OR later — after sub-plan 035 VERIFY ships)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S379-S380 (sandwich-dev FOCUSED_IMPL ~100-150K; may need 2 sessions for Phase1Synthesizer N-perspective rewrite + ValidateThesisPhase1UseCase generalization + AC-5 regression test coverage) + VERIFY S381 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [] (BLOCKS F.4 + F.5)
- **blocks_on**: [034-S374-phase-fprime-rolepromptpack-and-transport-flip, 035-S376-phase-fprime-first-3-personas]
- **coordination_paths_exclusive**: [packages/application/analysis/use_cases/validate_thesis_phase1.py (REFACTOR — N-persona dispatch generalization), packages/infrastructure/analysis/phase1_synthesizer.py (EDIT — N-perspective tradeoff matrix), packages/application/analysis/test_use_case.py (REGRESSION + N=6 path), packages/infrastructure/analysis/test_synthesizer.py (REGRESSION + N=6 path)]
- **estimated_wall_min**: PLAN 10-15 min (more architectural decisions: N>3 dispatch shape + N-perspective synthesizer extension + AC-5 regression coverage) / IMPL 40-60 min (refactor + tests across 4 files) / VERIFY 15-20 min (regression-heavy)
- **STEP 0 evaluation surface**: existing 3-persona pipeline test coverage audit (test_use_case.py + test_synthesizer.py count + scenarios); F.3 sub-plan decides whether N-generalization is dict-typed agents param OR sequence-typed agents tuple param; AC-5 thesis_id regression strategy
- **DoD floor**: ≥15 NEW unit tests (N=4 + N=5 + N=6 paths; mixed-confluence + all-disagreement + STRONG_CONSENSUS scenarios; AC-5 reproducibility under N-persona rotation); mypy + ruff + pytest green; existing 3-persona tests STILL pass (regression floor); thesis_id deterministic per (model, prompt_hashes, ticker, as_of, data_md5) tuple under N-persona path
- **ADR landing**: D-076 PROPOSED at IMPL tier — "BC-8 N-Perspective Synthesizer + Use Case Generalization (V0=6)"
- **Charter-tier touch**: NONE expected; FLAG if Phase1Synthesizer N-perspective confluence calculation requires new I-S<N> invariant (e.g. "majority-categorical formal definition" or "weighted-by-conviction" rule) — sub-plan 036 STEP 0 STOP-AND-ASK

### Sub-plan 037 — F.4 V0 persona-pack expansion to 6 personas + Vietnam-relevance subset

- **plan_id**: 037-S381-phase-fprime-v0-expansion (target dispatch S381 OR parallel with sub-plan 038 per § E.5 declaration)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S382-S383 (sandwich-dev FOCUSED_IMPL ~100-150K; may need 2 sessions for 3 more persona adapters + per-persona role-packs + per-persona retry-validators + Vietnam-domain-specialist prompt content authoring) + VERIFY S384 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [038-S384-phase-fprime-cli-dogfood] (CAN run parallel post-F.3 ship; main session orchestrates via plan-025 DD-5 3-parallel-ceiling-architect-tier validated at 4-parallel S345; **NON-BLOCKING CHARTER-TIER GATE**: F.4 STEP 0 checks Q-INT-2026-05-F-prime-1 user decision OR uses architect-recommended V0=6 default if user did not opt-in; sub-plan 037 IMPL adds Munger + Lynch + VN_DOMAIN_SPECIALIST ONLY if V0=9 ratified; if V0=6 confirmed, F.4 is no-op + plan moves to completed/)
- **blocks_on**: [034, 035, 036]
- **coordination_paths_exclusive**: [packages/infrastructure/analysis/perspectives/munger_agent.py + lynch_agent.py + vn_domain_specialist_agent.py (NEW IF V0=9), agent-workspace/role-packs/munger.yaml + lynch.yaml + vn_domain_specialist.yaml (NEW IF V0=9), test_munger_agent.py + test_lynch_agent.py + test_vn_domain_specialist_agent.py (NEW IF V0=9)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 30-45 min (3 personas same pattern as F.2) / VERIFY 10-15 min — IF V0=6 NO-OP, all of these collapse to ~5 min no-op + completed/ move
- **STEP 0 evaluation surface**: Q-INT-2026-05-F-prime-1 user-pick check; per-persona prompt template authoring per F.2 pattern; VN_DOMAIN_SPECIALIST per-category list (ATO/ATC microstructure, T+2.5 settlement, sàn tiering, room ngoại, đội lái cultural anchor)
- **DoD floor**: IF V0=9 ratified — ≥15 unit tests (3 personas × ≥5 tests each); mypy + ruff + pytest green; PersonaRegistry.all_role_ids() returns 9 entries; OR IF V0=6 confirmed — no new tests; plan-037 marked NO-OP-DEFERRED in completed/ with revisit-trigger named
- **ADR landing**: D-077 PROPOSED at IMPL tier IF V0=9 — "BC-8 V0 Persona-Pack V0=9 Expansion" OR NO ADR if V0=6 confirmed
- **Charter-tier touch**: NONE expected; F.4 PLAN itself is CHARTER-TIER GATE wrapped in NON-BLOCKING design

### Sub-plan 038 — F.5 CLI dogfood thesis on one VN ticker

- **plan_id**: 038-S384-phase-fprime-cli-dogfood (target dispatch S384 OR parallel with sub-plan 037 per § E.4 declaration)
- **type**: PLAN (sub-plan author = sandwich-architect; budget ~50-80K Opus)
- **followed-by**: IMPL S385 (sandwich-dev FOCUSED_IMPL ~100-150K; includes wall-clock dogfood run on VHM) + VERIFY S386 (sandwich-verifier AP-1 ~30-60K)
- **parallel_with**: [037-S381-phase-fprime-v0-expansion] (per § E.4 declaration)
- **blocks_on**: [034, 035, 036] (E.4 benefits from but does NOT strictly require F.4; F.5 CLI can dogfood with 3-persona V0 post-F.3 ship — but F.5 DOES need F.3 N-persona generalization to test N>3 path)
- **coordination_paths_exclusive**: [apps/cli/synthesize_vn_thesis.py (NEW), apps/cli/test_synthesize_vn_thesis.py (NEW), agent-workspace/memory/thesis-log/2026-05-NN-S385-vhm-dogfood.md (dogfood artifact — append; not committed at architect-tier; dev decision per project owner)]
- **estimated_wall_min**: PLAN 8-12 min / IMPL 30-50 min (CLI design + wall-clock dogfood run wait time per persona LLM call; 6 personas × ~30s/persona ≈ 3min CLI run time + post-analysis) / VERIFY 10-15 min (verifier examines persona output quality + AC-5 reproducibility + aggregate Recommendation correctness)
- **STEP 0 evaluation surface**: VHM ticker confirmation (DD-11 architect-recommended; project owner can override); data corpus availability for VHM (existing CafeF + NDH + Vietstock + VietnamBiz coverage); CLI output format design (JSON-and-markdown thesis-log format)
- **DoD floor**: ≥10 unit tests (CLI argparse + JSON output schema + happy-path + cost-budget-exceeded + ticker-resolution-failure); mypy + ruff + pytest green; wall-clock dogfood run on VHM produces (a) 6 per-persona PerspectiveAnalysis with non-empty key_points (or graceful-degradation per persona), (b) Synthesis with Confluence assessment, (c) final Recommendation + ConfidenceLevel, (d) AC-5 thesis_id reproducibility verified by running CLI twice + comparing hash, (e) per-persona cost recorded + within budget
- **ADR landing**: D-078 PROPOSED at IMPL tier — "BC-8 V0 Dogfood CLI + One-Ticker Smoke (VHM)"
- **Charter-tier touch**: NONE (CLI tooling + dogfood); FLAG only if dogfood reveals charter-tier issue (e.g. per-persona Recommendation drift to "buy/sell" prose phrasing despite Recommendation enum constraint — I-S35 sub-plan 038 STEP 0 STOP-AND-ASK)

### Sub-plan sequencing summary

| Sub-plan | Type | Target session | parallel_with | blocks_on | Budget envelope |
|---|---|---|---|---|---|
| 034 (F.1 RolePromptPack + transport-flip) | PLAN+IMPL+VERIFY | S374/S375/S376 | [] | [] | ~180-290K cumulative |
| 035 (F.2 First 3 personas) | PLAN+IMPL+VERIFY | S376/S377/S378 (after 034 verify) | [] | [034] | ~190-310K cumulative |
| 036 (F.3 N-persona use case extension) | PLAN+IMPL+VERIFY | S378/S379-S380/S381 (after 035 verify; IMPL may span 2 sessions) | [] | [034, 035] | ~210-340K cumulative |
| 037 (F.4 V0 expansion to V0=9 IF ratified) | PLAN+IMPL+VERIFY (or NO-OP) | S381/S382-S383/S384 (parallel with 038) | [038] | [034, 035, 036] | ~190-310K cumulative IF V0=9; ~20K NO-OP IF V0=6 |
| 038 (F.5 CLI dogfood) | PLAN+IMPL+VERIFY | S384/S385/S386 (parallel with 037) | [037] | [034, 035, 036] | ~170-260K cumulative |

**Cumulative Phase F-prime**: ~940-1510K Opus across ~15-19 sessions (5 PLAN + 5-7 IMPL + 5 VERIFY; parallel dispatch on 037+038 saves ~1-2 sessions wall-clock)

### Sub-track parallel_with field validation (per plan-025 contract DD-3)

Each sub-plan declares 3 mandatory fields per agent template L110-120:
- `parallel_with`: cross-sub-plan parallel-dispatch eligibility (architect-tier orchestration decision)
- `blocks_on`: hard dependencies between sub-plans
- `coordination_paths_exclusive`: per-sub-plan file scope; disjoint across parallel_with siblings

**Lint contract** (per plan-025 DD-4 — enforced at dispatch-time):
- 037 + 038 coordination_paths_exclusive sets MUST be disjoint when running parallel — verified: 037 touches `packages/infrastructure/analysis/perspectives/munger_agent.py + lynch_agent.py + vn_domain_specialist_agent.py + agent-workspace/role-packs/*.yaml`; 038 touches `apps/cli/synthesize_vn_thesis.py + agent-workspace/memory/thesis-log/**`; disjoint ✓
- Total parallel_with cardinality across all sub-plans ≤ 3 per dispatch wave per plan-025 DD-5 — max wave = 2 (037+038 parallel) ≤ 3 ✓
- blocks_on forms cycle-free DAG: 034 → 035 → 036 → 037 || 038 (037+038 both depend on 034+035+036; 037 also reads its NON-BLOCKING decision from Q-INT-2026-05-F-prime-1; no cycles) ✓

---

## F. Definition of Done (master-plan-level — ≥20 items)

DoD for THIS master-plan-authoring session (S373):

- [ ] **DC-MASTER-1** — `agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md` exists (this file)
- [ ] **DC-MASTER-2** — `agent-workspace/memory/observations/sandwich-architect-S373-phase-fprime-master-plan.md` exists (per agent-template L207-210 mandate)
- [ ] **DC-MASTER-3** — § A.4 Calibration summary (Phase 1b CONSUMED variant) populated with COLD-START declaration explicit per L-S354-2 → L-S366-4 → L-S369-1 cascade + agent-template L65
- [ ] **DC-MASTER-4** — § D contains ≥12 DD architecture decisions all with rationale + adversarial alternates
- [ ] **DC-MASTER-5** — § E contains 5 sub-plan decompositions (034/035/036/037/038) each with parallel_with + blocks_on + coordination_paths_exclusive + estimated_wall_min per plan-025 contract
- [ ] **DC-MASTER-6** — § G contains AQ-1..AQ-10 pre-answered
- [ ] **DC-MASTER-7** — § H contains 5-source-evidence chain (ai-hedge-fund A-01 + TradingAgents A-13 + supplement § H + existing BC-8 code + Rule 16 D-065)
- [ ] **DC-MASTER-8** — § J contains ≥10 RM entries with mitigation
- [ ] **DC-MASTER-9** — § K Charter-tier-surface section enumerates anticipated FLAGS (or explicitly states "NO CHARTER-TIER FLAGS at master-plan level") + NON-BLOCKING design rationale
- [ ] **DC-MASTER-10** — § L Plan-vs-Master-Plan decision rationale documented (DD-1 anchor)
- [ ] **DC-MASTER-11** — § M Coordination paths off-limits during S374 sub-plan 034 PLAN authoring window enumerated
- [ ] **DC-MASTER-12** — § N Phase F-prime → G-prime → H-prime sequencing recommendation per dispatch brief return-summary item 7
- [ ] **DC-MASTER-13** — 0 charter / 0 constitution / 0 production code (architect PLAN-only; tools: [Read, Glob, Grep, Write])
- [ ] **DC-MASTER-14** — Phase E DONE attestation acknowledgment (S372 commit 8f68947 verifier PASS) recorded in § N.1 critical-path analysis row
- [ ] **DC-MASTER-15** — VBW protocol satisfied via ≥20 source files read at master-plan authoring time per § A.4 enumeration
- [ ] **DC-MASTER-16** — Existing BC-8 code state audit completed in § C.0.1 (all existing files cited + Phase F-prime extension surface mapped)
- [ ] **DC-MASTER-17** — anthropic_api_to_subagent memory-rule for BC-8 transport-flip surface noted in § C.0.5 + RM-AS-1 + DD-5 (carry-forward mitigation)
- [ ] **DC-MASTER-18** — Rule 16 (I-S1-1) surface audit completed in § C.0.4 with explicit per-field satisfaction-mode determination
- [ ] **DC-MASTER-19** — ai-hedge-fund LICENSE-file caveat A-01 § 6 acknowledged in hard_rules_acknowledged + § C.0.3 (pattern-port not code-port)
- [ ] **DC-MASTER-20** — § P compliance attestation populated (≥15 items)
- [ ] **DC-MASTER-21** — DD-3 V0 isolated-vs-debate verdict-INVERSION rationale documented with named AP-7 revisit trigger
- [ ] **DC-MASTER-22** — DD-2 V0 persona count (V0=6 architect-default + V0=9 ratification-gated NON-BLOCKING) documented with Vietnam-relevance evidence chain
- [ ] **DC-MASTER-23** — DD-4 HYBRID RolePromptPack data + per-persona adapter class rationale documented vs pure-data-driven OR pure-class-polymorphism alternatives

---

## G. Architecture Questions (AQ-1..AQ-10) — pre-answered

### AQ-1 — Why Phase F-prime as PHASE-MASTER-PLAN not single multi-sub-track FOCUSED_IMPL?

**Answer**: Per DD-1. CLAUDE.md hard rule "Never mix PLAN and IMPL in same session"; budget envelope (5 sub-tracks × 100-150K IMPL = 500-750K cumulative exceeds MULTI-TASK ceiling); Phase 1b cold-start risk amplification; Phase E plan-028 precedent for per-sub-theme PLAN+IMPL+VERIFY rhythm (4 sub-plans all SHIPPED + verified).

### AQ-2 — Why V0=6 personas not V0=4 or V0=19?

**Answer**: Per DD-2. V0=6 = existing 3 active (BEAR/BULL/QUANT) + 3 new in F.2 (BUFFETT/GRAHAM/TALEB). V0=4 leaves Spec 004 A.2 gap + loses F.4 expansion anchor + GRAHAM/TALEB add distinct perspectives BEAR alone cannot cover. V0=19 (ai-hedge-fund full port) violates Charter Principle 7 dogfood-first + Karpathy P2 simplicity + over-engineering for V0. Vietnam-relevance evidence chain for each V0=6 persona documented in DD-2.

### AQ-3 — Why ISOLATED-THEN-AGGREGATE V0 if H.3 supplement says DEBATE wins?

**Answer**: Per DD-3. V0 INVERTS H.3 verdict per 3 strong reasons (existing-BC-8-shape preservation + cost/determinism/AP-1-risk per H.3 trade-off table 4-of-9 properties + simpler V0 with AP-7 named revisit trigger for DEBATE-V2 after V0 dogfood evidence). H.3 mitigation #5 explicitly supports V0 isolated as substrate for DEBATE-V2.

### AQ-4 — Why HYBRID RolePromptPack + per-persona adapter class not pure-data-driven?

**Answer**: Per DD-4. Per-persona retry-validator semantics DIFFER (BEAR ≥3 distinct categories; QUANT numeric-tool-call-grounding; BUFFETT moat-grounding) — pure-data-driven would require generic validation framework = over-engineering; HYBRID lets RolePromptPack ship data while adapter ships persona-specific validator logic.

### AQ-5 — Why mirror D-072 strategy for BC-8 transport-flip not adapt existing news transport?

**Answer**: Per DD-5. Signature DIFFERS (news transport returns str only; perspective adapter needs 3-tuple text+in_tok+out_tok); cleaner to author parallel factory than shim existing; D-072 migration shape proven at S368 + verified S369 = minimizes regression risk.

### AQ-6 — STEP 0 finds pyyaml NOT installed — what then?

**Answer**: Per DD-8 step (d). Fallback to stdlib `json` loader for role-packs (less human-friendly but works); architect emits explicit warning + RolePromptPack YAML loader becomes JSON loader; revisit trigger = if YAML-vs-JSON friction surfaces, add pyyaml dep via separate sub-plan with user ratification per anti-vacuous-defer.

### AQ-7 — Sub-plan 036 F.3 IMPL needs 2 sessions — when to split vs bundle?

**Answer**: Sub-plan 036 PLAN authors per CLAUDE.md MULTI-TASK budget envelope (150-250K); if N-perspective Phase1Synthesizer rewrite + ValidateThesisPhase1UseCase generalization + AC-5 regression test coverage exceeds 4 hours wall-clock at IMPL time, sub-plan 036 dev SHOULD split via fresh-context dispatch S380 covering only the regression-test surface; sub-plan 036 PLAN authors with explicit "MAY_SPLIT_IF_>4H" clause in DoD.

### AQ-8 — Sub-plan 037 V0=6 confirmed → F.4 NO-OP — what happens to plan-037?

**Answer**: Per DD-2 NON-BLOCKING design. Plan-037 PLAN session writes ≤200 LOC PLAN file documenting V0=6 confirmation + NO-OP rationale + revisit trigger named (project-owner adds 3+ custom personas via direct YAML edit OR explicit re-ratification request); plan-037 marked NO-OP-DEFERRED status; moved to completed/ with brief observation; F.4 budget envelope ~20K not 200K.

### AQ-9 — F.5 dogfood reveals VHM data gap (e.g. no recent news) — what then?

**Answer**: Sub-plan 038 STEP 0 verifies VHM data corpus availability BEFORE dispatching IMPL; if data gap surfaces, STEP 0 STOP-AND-ASK options: (a) corpus refresh via existing CafeF/NDH/Vietstock/VietnamBiz adapter CLIs (~10-15 min wall-clock per source), (b) switch to alternate ticker (DD-11 alternates HPG/VIC/FPT), (c) defer F.5 IMPL pending corpus expansion. NON-BLOCKING choice; project-owner picks.

### AQ-10 — What if F.3 IMPL surfaces I-S12 invariant violation (Phase1Synthesizer N-perspective rewrite breaks STRONG_CONSENSUS+disagreements check)?

**Answer**: Sub-plan 036 STEP 0 mandates regression coverage of Synthesis._enforce_disagreement_consistency at synthesis.py:89-100 across N=3 (existing) + N=4 + N=5 + N=6 paths; if F.3 IMPL surfaces invariant violation, sub-plan 036 dev MUST fix inline (NOT defer) before commit; if multiple iterations fail, escalate via sub-plan 036 STEP 0 STOP-AND-ASK to architect-tier sub-plan refinement (rare; existing tests should catch).

---

## H. 5-source-evidence chain

| # | Decision | Source 1 (deep-dive obs) | Source 2 (integration proposal) | Source 3 (charter invariant) | Source 4 (existing stockforge code precedent) | Source 5 (external library / pattern) |
|---|---|---|---|---|---|---|
| 1 | V0 ISOLATED-THEN-AGGREGATE (DD-3 INVERTS H.3) | `agent-workspace/memory/observations/master-planner-A-01-deepdive-ai-hedge-fund.md` § 5 third bullet "isolated-then-aggregate EMPIRICALLY CONFIRMED; recommendation: adopt this pattern as Wave-1 default for BC-8; defer debate-style until evidence shows ensemble underperforms" | `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` § H.3 trade-off table (lines 180-190; isolated wins 4-of-9 properties; mitigation #5 explicit support for V0 isolated substrate) | I-S12 "Disagreement Surfaced, Not Resolved" — existing Synthesis aggregate _enforce check at packages/domain/analysis/models/synthesis.py:89-100 satisfies I-S12 without debate-cycle | `packages/application/analysis/use_cases/validate_thesis_phase1.py:221` `asyncio.gather(bear_t, bull_t, quant_t)` existing parallel fan-out pattern | ai-hedge-fund `src/main.py:112-115` parallel fan-out NO inter-agent messaging |
| 2 | HYBRID RolePromptPack + per-persona adapter class (DD-4) | A-01 § 3 C1+C2 (per-perspective signal contract + plugin registry pattern) | supplement § H.4 IMPL-slot "Maps agents/utils/agent_states.py:7-43 TypedDicts to stockforge packages/domain/synthesis/ value-objects (dataclass, NOT Pydantic — domain layer rule)" | I-S1 (NO LLM math; per-persona LLM emits ONLY categorical + reasoning + GroundedPoint tuple) + Rule 16 mode 1 categorical surrogate via Conviction StrEnum | `packages/infrastructure/analysis/perspectives/bear_agent.py:198-300` retry-validator pattern + SYSTEM_PROMPT inline + Jaccard distinctness — F.2 personas mirror this shape with RolePromptPack delegation | ai-hedge-fund `src/utils/analysts.py:25-178` ANALYST_CONFIG dict + `src/agents/warren_buffett.py:13-16` Pydantic signal contract (pattern-port not code-port per A-01 § 6 LICENSE caveat) |
| 3 | BC-8 transport-flip mirror D-072 (DD-5) | (architect-tier decision; no single deep-dive citation) | D-061 § Item 7 Wave-1 integration; D-051 + D-052 transport-flip policy ratification | I-S1 + Charter Principle 9 (no LLM math) + `anthropic_api_to_subagent` memory-rule (per CLAUDE.md user.md persistence; subscription-billing-not-API-metered) | `packages/infrastructure/news/claude_cli_news_transport.py:96-156` `claude_cli_news_transport()` + `make_claude_cli_news_transport()` factory shipped at S? + `packages/infrastructure/news/claude_llm_extractor.py` D-072 default-flip at S368 | claude CLI invocation via subprocess.run pattern (BP-S43b-1/2/3 per architecture.md:142-154) |
| 4 | V0=6 persona count + Vietnam-relevance subset (DD-2) | A-01 § 2-3 (19 personas inventory; per-persona archetype description) | supplement § H.4 (Phase F-prime IMPL-slot extends to ≥4 perspectives) | I-S11 (≥2 minimum; ≥4 for high-confidence) + Charter Principle 4 (Proprietary data moat — VN-specific persona is moat) | `packages/domain/analysis/models/perspective_analysis.py:30-39` existing 6-value PerspectiveRole StrEnum (BEAR/BULL/QUANT active + MACRO/BEHAVIOR/MANAGER deferred stubs) | `specs/tier2-feature/004-multi-perspective-adversarial-agents.md` § A.2 (6 perspective archetypes enumerated as approved spec) |
| 5 | Phase F-prime as PHASE-MASTER-PLAN (DD-1) | (master plan-level decision; no single deep-dive citation) | master plan § 6.4.3 (Phase F-prime = 1 PLAN + 1-2 IMPL + 1 VERIFY) | CLAUDE.md hard rule "Never mix PLAN and IMPL in same session" + § Session Types budget envelopes | Phase E plan-028 master plan precedent (4 sub-themes per-PLAN+IMPL+VERIFY all SHIPPED 029/030/031/032; verified S366/S369/S372) | (master plan structural decision; pattern emerges from CLAUDE.md + stockforge session-typing) |

---

## J. Risks & Mitigation (RM1-RM12)

### RM1 — Cold-start budget over/under-estimation (LIKELY-MEDIUM)
**Risk**: Phase 1b cold-start declared per § A.4; per-sub-track PLAN+IMPL+VERIFY budget envelopes are boilerplate-derived not empirically-grounded. Sub-plan 034 may finish under budget OR over (e.g. transport-flip migration surfaces unforeseen test regression).
**Mitigation**: Each per-sub-track PLAN session re-runs Phase 1b with growing n (n=1 after sub-plan 034 closes; n=2 after sub-plan 035; etc.); cumulative Phase F-prime budget envelope has ~60% spread (940-1510K) to absorb variance.

### RM2 — Charter-tier surface mid-flight (LIKELY-LOW; mitigated by § K + NON-BLOCKING design)
**Risk**: Sub-plan 034/035/036/037/038 may surface a charter-tier issue (per-persona LLM emits buy/sell prose bypassing Recommendation enum → I-S35 violation; OR per-persona confidence rubric surfaces I-S1-1 Rule 16 mode-tripwire).
**Mitigation**: § K Charter-tier-surface enumerates anticipated FLAGS; each sub-plan STEP 0 has STOP-AND-ASK clause for unanticipated FLAGS; main session dispatches AskUserQuestion gate per CLAUDE.md hard rule.

### RM-AS-1 — anthropic_api_to_subagent BC-8 refactor scope creep (LIKELY-MEDIUM; sub-plan 034 risk)
**Risk**: Sub-plan 034 F.1 IMPL extends beyond RolePromptPack foundation due to BC-8 transport-flip complexity (new claude_cli_perspective_transport factory + signature adaptation + 3-tuple return + cost-tracking integration); may cascade into test_bear_agent/test_bull_agent/test_quant_agent regression cleanup.
**Mitigation**: DD-5 mirror-D-072 strategy is proven migration shape; sub-plan 034 dev sets explicit refactor scope envelope at STEP 0; if scope balloons, refactor portion DEFERRED to separate harness sub-plan with NAMED RM-AS-1 revisit trigger.

### RM3 — Per-persona prompt template authoring quality variance (LIKELY-MEDIUM; sub-plan 035 risk)
**Risk**: First 3 personas (Buffett/Graham/Taleb) prompt template authoring quality may vary; per-persona retry-validator semantics may not satisfy I-S10-or-equivalent on all 3.
**Mitigation**: Sub-plan 035 STEP 0 authors prompt template DRAFTS for review BEFORE IMPL commit + dogfood smoke per-persona on architect-internal dummy data (pre-F.5 dogfood); revisit trigger = if any V0 persona produces <50% valid LLM outputs in F.5 dogfood, F.5-V2 retry with refined template.

### RM4 — Catastrophic mix pattern (CRITICAL-LOW; mitigated by DD-1)
**Risk**: Bundling 5 sub-tracks into single MULTI-TASK IMPL = Session 4 catastrophic failure mode.
**Mitigation**: DD-1 explicitly rejects bundling; phase-master-plan rhythm + per-sub-plan PLAN+IMPL+VERIFY chains enforced.

### RM5 — Existing BC-8 test regression (LIKELY-MEDIUM; sub-plan 036 risk)
**Risk**: F.3 ValidateThesisPhase1UseCase + Phase1Synthesizer N-perspective generalization may break existing 3-persona path; AC-5 thesis_id reproducibility may regress.
**Mitigation**: Sub-plan 036 STEP 0 mandates regression coverage of test_use_case.py + test_synthesizer.py + AC-5 thesis_id deterministic-per-tuple validation; sub-plan 036 IMPL DoD floor = existing tests STILL pass; sub-plan 036 PLAN allocates 2 IMPL sessions IF complexity warrants.

### RM6 — H.3 supplement verdict inversion criticism (LIKELY-LOW)
**Risk**: Verifier (sandwich-verifier dispatched fresh-context) may flag DD-3 V0-INVERTS-H.3 verdict as architecturally unsound; user may push back on "defying the integration proposal".
**Mitigation**: DD-3 rationale documents 3 strong reasons + cites H.3 mitigation #5 (which EXPLICITLY supports V0 isolated as DEBATE-V2 substrate) + AP-7 named revisit trigger for DEBATE-V2 after V0 dogfood evidence; this is the "earn the verdict with evidence" pattern, not abandonment of H.3 principle.

### RM7 — Per-persona cost budget overrun (LIKELY-MEDIUM; sub-plan 038 risk)
**Risk**: V0=6 personas × per-thesis ($3.00 limit at validate_thesis_phase1.py:187) may exceed budget; F.5 dogfood on VHM may surface CostBudgetExceeded → Thesis.incomplete() repeatedly.
**Mitigation**: DD-12 V0 persona model routing keeps 5 personas on Sonnet + only QUANT on Opus = cumulative ≈ 5×$3+1×$15 = ~$30/MTok cumulative input cost; F.5 dogfood empirically measures + F.4-V2 budget adjustment if needed; per-persona role_model_overrides allows on-the-fly Haiku downgrade for cost-sensitive personas per BP-S43b-1.

### RM8 — Persona-pack registry concurrent-modification race (LIKELY-VERY-LOW; sub-plan 034 risk)
**Risk**: PersonaRegistry.register() called from multiple composition roots concurrently could race; YAML loader at startup could partial-read.
**Mitigation**: PersonaRegistry register() is composition-root pattern (called once at startup before any LLM dispatch); not designed for runtime mutation; YAML loader uses atomic-write doctrine D-062 for any writes; reads are read-only.

### RM9 — Rule 16 mode 1 categorical surrogate insufficient for downstream consumers (LIKELY-LOW; sub-plan 036 risk)
**Risk**: Downstream BC-9 portfolio sizing or Tier 3 calibration may need numeric confidence per persona for weighted aggregation; categorical Conviction may lose information.
**Mitigation**: Sub-plan 036 F.3 generalization preserves Conviction per persona + computes deterministic weighted-mean for aggregate ConfidenceLevel mapping (Rule 16 mode 2); per-persona numeric weights are computed-not-emitted (no LLM involvement); BC-9 downstream consumes confidence_level (existing field) not per-persona numeric.

### RM10 — VHM dogfood data corpus stale (LIKELY-LOW; sub-plan 038 risk)
**Risk**: F.5 wall-clock dogfood on VHM may surface insufficient recent VHM news in corpus (last refresh date unknown at S373 architect-tier).
**Mitigation**: Sub-plan 038 STEP 0 verifies VHM data corpus freshness (via Glob check on `data/raw/news/*/2026-05-*/` + VHM-keyword grep); if stale, sub-plan 038 IMPL pre-flight includes 4-source corpus refresh CLI runs (~10-15 min wall-clock per source) before thesis run.

### RM11 — V0=9 expansion ratification ambiguity (LIKELY-LOW; sub-plan 037 risk)
**Risk**: User may not respond to Q-INT-2026-05-F-prime-1 timely; sub-plan 037 launch ambiguous.
**Mitigation**: NON-BLOCKING design per § K.4 — F.4 PLAN session defaults to V0=6-CONFIRMED-NO-OP unless explicit user opt-in via Q-INT bundle answer; F.4 IMPL skipped if NO-OP; Phase F-prime proceeds with V0=6.

### RM12 — Phase F-prime budget overrun cumulative (LIKELY-MEDIUM)
**Risk**: 5 sub-plans × ~290K mid envelope = ~1450K cumulative; if all 5 land at high end + add 20% reserve = ~1740K = ~35% of typical session budget at multi-hour wall-clock.
**Mitigation**: Per plan-025 DD-5 architect-tier parallel-dispatch validated at 4-parallel; sub-plans 037+038 declared parallel_with eligible (§ E.5 + § E.4) so 2 sub-plans can run concurrently = ~25-30% wall-time reduction per plan-025 projection; main session orchestrates parallel dispatch.

---

## K. Charter-Tier-Surface FLAGS

Per dispatch brief: "ANTICIPATED CHARTER-TIER FLAGS" + "Charter-tier flags + NON-BLOCKING design vs BLOCKING (which require user ratification)".

### K.1 Anticipated FLAGS at master-plan level (3 NON-BLOCKING flags surfaced; architect-recommended defaults chosen)

Reviewing § A scope + § D DD decisions against existing charter:

**FLAG K.1.a — V0 persona count V0=6 (architect-default) vs V0=9 ratification gate**:
- Architect recommends V0=6 (existing 3 active + 3 new in F.2: BUFFETT/GRAHAM/TALEB)
- Sub-plan 037 F.4 expansion to V0=9 (MUNGER/LYNCH/VN_DOMAIN_SPECIALIST) is GATE-conditional
- **NON-BLOCKING design**: Phase F-prime proceeds with V0=6 default UNLESS user opt-in to V0=9 via Q-INT-2026-05-F-prime-1
- **NO charter implication** — persona count is implementation-tier design; not invariant
- Ratification path optional: main session MAY fire Q-INT bundle item; sub-plan 037 STEP 0 reads response if present; if absent, NO-OP

**FLAG K.1.b — V0 aggregation strategy ISOLATED-THEN-AGGREGATE (architect-default, INVERTS H.3) vs DEBATE-STYLE**:
- DD-3 INVERTS H.3 supplement verdict; ratification optional
- Architect-recommended default V0 = isolated; AP-7 named revisit trigger for DEBATE-V2 after V0 dogfood
- **NON-BLOCKING design**: Phase F-prime proceeds with V0 isolated; user MAY override via Q-INT-2026-05-F-prime-2 (if fired)
- **NO charter implication** — I-S12 satisfied by-construction either way (existing Synthesis invariant)
- Ratification path optional: main session MAY fire Q-INT bundle item

**FLAG K.1.c — Per-persona confidence rubric: categorical-surrogate (architect-default per Rule 16 mode 1) vs numeric-rubric**:
- DD-4 + Rule 16 satisfaction mode 1 architect-default = Conviction StrEnum (STRONG/MODERATE/WEAK)
- Buffett-style 90-100/70-89/etc. numeric rubric per A-01 § 3 C9 REJECTED per I-S1-1 Rule 16
- **NON-BLOCKING design**: Phase F-prime ships categorical surrogate by default; charter ALREADY ratified D-065 Rule 16; no new ratification needed
- **NO charter implication** — Rule 16 already operationalizes I-S1-1; categorical is one of the 4 satisfaction modes
- Ratification path: NONE needed (already operationalized via D-065)

**Master-plan-level VERDICT**: NO CHARTER-TIER BLOCKING FLAGS. All 3 anticipated flags use NON-BLOCKING design with architect-recommended defaults; Phase F-prime proceeds without explicit user-ratification gate.

### K.2 Potential FLAGS at sub-plan level (anticipated; sub-plan STEP 0s handle)

The following are **anticipated** FLAGS that sub-plan STEP 0s should watch for and STOP-AND-ASK if surfaced:

**Sub-plan 034 (F.1 RolePromptPack + transport-flip)**:
- pyyaml dep not installed → DD-8 fallback to stdlib json; explicit warning; NOT a charter flag
- BC-8 transport-flip surfaces regression in test_bear_agent/test_bull_agent/test_quant_agent → harness gap; sub-plan 034 dev fixes inline OR defers to F.1-V2; NOT a charter flag

**Sub-plan 035 (F.2 First 3 personas)**:
- BUFFETT/GRAHAM/TALEB per-persona prompt template surfaces "interpretation creep" (LLM volunteers buy/sell prose bypassing Recommendation enum) → I-S35 violation surface → FLAG mandatory if surfaced; sub-plan 035 STEP 0 STOP-AND-ASK
- TALEB tail-risk prompt template requires numeric VaR-output → I-S1-1 violation surface; refactor to deterministic-pipeline echo (VaR computed by code, persona interprets) → no charter touch (Rule 16 mode 2 already operationalized)

**Sub-plan 036 (F.3 N-persona use case extension)**:
- Phase1Synthesizer N-perspective confluence calculation surfaces ambiguity (e.g. 3-3 tie across STRONG_CONSENSUS vote with mixed verdicts) → architect-tier sub-plan refinement OR new I-S<N> invariant for "tie-breaker" rule → CANDIDATE CHARTER-TIER FLAG (sub-plan 036 STEP 0 STOP-AND-ASK)

**Sub-plan 037 (F.4 V0 expansion)**:
- VN_DOMAIN_SPECIALIST prompt template surfaces VN-specific Rule (e.g. T+2.5 settlement rule must be encoded as deterministic check vs LLM-emitted check) → potential I-S<N>-1 for VN-microstructure handling → CANDIDATE CHARTER-TIER FLAG; sub-plan 037 STEP 0 STOP-AND-ASK

**Sub-plan 038 (F.5 CLI dogfood)**:
- VHM dogfood Recommendation output is "buy" prose phrasing (not THESIS_CANDIDATE enum) → I-S35 violation surface; FLAG mandatory if surfaced; sub-plan 038 STEP 0 STOP-AND-ASK
- VHM dogfood aggregate confidence_level "0.85" prose phrasing (not HIGH/MEDIUM/LOW enum) → I-S1-1 Rule 16 violation surface; FLAG mandatory if surfaced; sub-plan 038 STEP 0 STOP-AND-ASK

### K.3 Ratification path if FLAG fires mid-Phase-F-prime

1. Sub-plan STEP 0 STOP-AND-ASK clause triggers → sub-plan author writes FLAG-FINDING-S<N>-<sub-track>.md to `human-workspace/notifications/`
2. Main session dispatches AskUserQuestion gate with options (typically: a=accept-with-mitigation / b=defer-with-named-trigger / c=block-Phase-F-prime-pending-ratification)
3. User picks → ADR drafted at proposal/ tier → cool-down per severity-schema → constitution amendment landed by separate user-ratified PLAN+IMPL pair
4. Phase F-prime sub-plan resumes after ADR ACCEPTED status confirmed

### K.4 NON-BLOCKING design preference (Phase F-prime architect default)

Per Charter principle that "User prompt overrides ALL defaults" — Phase F-prime defaults to architect-recommended choices for K.1.a/b/c flags WITHOUT firing AskUserQuestion at master-plan-tier. Rationale:
- Architect rationale is documented + traceable (DD-2/DD-3/DD-4 with explicit AP-7 revisit triggers)
- AskUserQuestion bundle would accumulate 3 items WITHOUT urgency (project-owner can review at any time + override via direct chat)
- AP-23 anti-LLM-Guardian — don't surface flags performatively when default is empirically defensible
- Phase F-prime CAN proceed in autonomous-full mode without ratification cycle if architect-recommended defaults hold

Main session decision: MAY fire Q-INT bundle at any time to ratify K.1.a/b/c; sub-plan STEP 0 reads ratification state if present; if absent, default applies.

---

## L. Plan-vs-Master-Plan Decision Rationale

Per dispatch brief: "ARCHITECT DECISION: pick one approach with rationale."

**Decision**: **PHASE-MASTER-PLAN with 5 sub-plan decomposition** (NOT single multi-sub-track plan).

### L.1 Why PHASE-MASTER-PLAN

1. **CLAUDE.md hard rule**: "Never mix PLAN and IMPL in same session. (Session 4 catastrophic failure mode.)" — single-session PLAN+IMPL bundle of 5 sub-tracks = violates rule
2. **Budget envelope arithmetic**: per CLAUDE.md § Session Types FOCUSED_IMPL = 100-150K; 5 sub-tracks at 100-150K each = 500-750K cumulative IMPL alone, before PLAN authoring overhead; clearly exceeds MULTI-TASK ceiling (150-250K)
3. **Phase 1b cold-start risk amplification**: bundling cold-start work into one session loses incremental calibration feedback; per-sub-track PLAN sessions let calibration go n=0 → n=1 → n=2 → n=3 → n=4 across the 5 sub-plans
4. **Phase E plan-028 precedent**: Phase E 4 sub-themes per-PLAN+IMPL+VERIFY all SHIPPED + verified (S366/S369/S372) — strong precedent for per-sub-track rhythm
5. **Existing BC-8 backward-compat preservation**: 5 sub-tracks with INDIVIDUAL verifier sessions = better defect-catch per session vs bundled regression flood

### L.2 Why NOT single multi-sub-track FOCUSED_IMPL

Considered but rejected:
- (a) Mix PLAN + IMPL violation per CLAUDE.md hard rule
- (b) Budget envelope exceeds MULTI-TASK ceiling
- (c) STEP 0 evaluation surfaces (transport-flip migration + 3-persona prompt template authoring + use case extension + V0 expansion + CLI dogfood) each need own STEP 0 — bundling = 5 STEP 0s in one session = ambiguity + budget bloat
- (d) ADR landing tier discipline — 5 distinct ADRs (D-074/D-075/D-076/D-077/D-078) per master plan § E; bundling = single mega-ADR vs 5 distinct ADRs = ADR discoverability + future-revisit-trigger granularity lost
- (e) Verifier audit scope — bundling = 1 verifier session reviewing 5 sub-tracks = high cognitive load + risk of missed defects; per-sub-track verifier session = each verifier focuses on 1 sub-track

### L.3 Alternative considered: 3 sub-plan decomposition (F.1 + F.2+F.3 + F.4+F.5)

**Rejected**: F.2+F.3 bundle would mix prompt template authoring with use case generalization = mixed-decision-class; F.4+F.5 bundle would mix V0 expansion with dogfood = different STOP-AND-ASK surfaces. Per Karpathy P3 surgical-changes + plan-025 DD-5 parallel-dispatch ceiling — 5 sub-plans is the right granularity.

---

## M. Coordination paths off-limits (during S374 sub-plan 034 PLAN authoring window)

When main session dispatches sub-plan 034 author at S374, main session SHOULD avoid (read-only or no-touch):
- `agent-workspace/session-plans/pending/034-S374-phase-fprime-rolepromptpack-and-transport-flip.md` (sub-plan author writes)
- `agent-workspace/memory/observations/sandwich-architect-S374-rolepromptpack-and-transport-flip-plan.md` (sub-plan author writes)

Coordination paths beyond S374 apply per-sub-plan and are documented in each sub-plan's own § Coordination paths section.

---

## N. Phase F-prime → G-prime → H-prime Sequencing Recommendation

Per dispatch brief return-summary item 7 + master plan § 6.4.

### N.1 Critical-path analysis

| Phase | Theme | Critical-path dependency | Budget envelope | When to start |
|---|---|---|---|---|
| **E (closed at S372 commit 8f68947)** | I (Vietnamese NLP) | Phase D Theme L crawling — DONE | ~720-1150K Opus across 12-16 sessions actual | DONE — Phase E.1+E.2+E.3+E.4 all shipped + verified |
| **F-prime (current)** | H (BC-8 Multi-Perspective) | Independent of Theme I VN-NLP substrate; depends on Phase C Theme G D-065 ratification — DONE 2026-05-16 | ~940-1510K Opus across 15-19 sessions | NOW (S373 master-plan; S374 first sub-plan) |
| **G-prime (next)** | J (PDF + table extraction BC-2) | Phase 2 work; not on Phase 1 critical path; no dependency on Theme H | TBD per G-prime master-plan | **Can dispatch PARALLEL with Phase F-prime after F.1 ships** (sub-plan 034 close) — architect-tier parallel-dispatch precedent (S345 4-parallel) supports this; G-prime authoring is independent file scope |
| **H-prime** | K (UX/Output — Streamlit dashboard polish) | Phase 2 work; not on Phase 1 critical path | TBD per H-prime master-plan | DEFER to Phase 2 dashboard work entry |

### N.2 Recommended sequencing

**Sequential Phase F-prime ship**:
- S373 (now): Phase F-prime master plan = this file
- S374/S375/S376: sub-plan 034 (F.1 RolePromptPack + transport-flip) PLAN+IMPL+VERIFY
- S376/S377/S378: sub-plan 035 (F.2 First 3 personas) PLAN+IMPL+VERIFY
- S378/S379-S380/S381: sub-plan 036 (F.3 N-persona use case extension) PLAN+IMPL+VERIFY (IMPL may span 2 sessions)
- S381/S382-S383/S384: sub-plan 037 (F.4 V0 expansion) PLAN+IMPL+VERIFY (PARALLEL with sub-plan 038; NO-OP IF V0=6 confirmed)
- S384/S385/S386: sub-plan 038 (F.5 CLI dogfood) PLAN+IMPL+VERIFY (PARALLEL with sub-plan 037)
- S386 close: Phase F-prime DONE

**Parallel Phase G-prime ship** (architect-tier parallel-dispatch):
- After sub-plan 034 VERIFY ships at S376: main session may dispatch Phase G-prime master-plan author in parallel with Phase F-prime sub-plan 035 PLAN authoring
- G-prime master-plan author (S376' background dispatch) = independent file scope; no contention with Phase F-prime

**Deferred Phase H-prime**:
- H-prime triggers at Phase 2 dashboard work entry per master plan § 6.4.5

### N.3 Total cumulative budget projection

- Phase F-prime: ~940-1510K Opus / ~15-19 sessions wall-clock (with sub-plan 037+038 parallel = save ~1-2 sessions; if V0=6 NO-OP, save ~2-3 sessions)
- Phase G-prime (parallel from S376+): TBD (estimated ~400-600K per master plan § 6.4.4)
- Phase H-prime: deferred

**Wall-clock projection**: Phase F-prime sequential = ~15-19 sessions × 1 turn each at full autonomous = ~15-19 turns; with sub-plan 037+038 parallel + G-prime parallel from S376 + V0=6 NO-OP = ~12-15 turns total to Phase F-prime+G-prime close.

### N.4 Phase E DONE attestation acknowledgment

**Phase E Theme I (Vietnamese NLP) FULLY DONE at S372 commit 8f68947** — sandwich-verifier PASS verified all 4 sub-themes (E.1 pyvi tokenizer / E.2 sentiment lexicon UNCALIBRATED-V0 / E.3 claim extraction wrapper + transport flip / E.4 ticker resolver) shipped + tested + ADRs D-070/D-071/D-072/D-073 ACCEPTED. **This unblocks Phase F-prime entry** per master plan § 6.4 sequencing.

Phase E DONE state is the prerequisite for THIS plan; the dispatch brief explicitly cites S372 8f68947 as the unblock event.

---

## P. Compliance attestation (master-plan authoring session S373)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work — L-S354-2/L-S366-4/L-S369-1 planner-stats infrastructure gap noted as carry-forward in § A.4; explicitly NOT fixed here per § hard_rules)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 25+ source files read inline)
- AP-7 ✓ (every DEFER decision in § A.3 + § J names prerequisites + revisit triggers — no naked deferrals; AP-7 named revisit trigger explicitly cited in DD-3 for DEBATE-V2)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED for first-instance HOLD; promotion-on-2nd-recurrence calculus respected; H.3 verdict-INVERSION is empirical-evidence-driven decision NOT refinement-of-rule)
- autonomous_continue_no_self_pause ✓ (architect ships PLAN-authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = master plan + observation; main session dispatches sub-plan 034 author per § N sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing recommendation in § N is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-072 not touched (Phase E.3 closed; Theme H mirrors strategy without modifying D-072 ADR text)
- D-066 not touched (Phase D Theme L closed; Theme H INFORMATIONAL precedent for ABC-vs-Protocol decision in DD-7)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (master plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- I-S1 ✓ (this plan PROMOTES I-S1 satisfaction in Theme H implementation per DD-4 + DD-12; does not violate)
- I-S1-1 (Rule 16) ✓ (per § C.0.4 audit; mode 1 + mode 2 satisfaction by-construction for all candidate fields)
- I-S2 ✓ (every plan claim cites source file:line per § H 5-source-evidence chain + VBW source file enumeration in § A.4)
- I-S10 ✓ (existing Thesis.bear-case invariant preserved; F.3 sub-plan generalization preserves invariant)
- I-S11 ✓ (V0=6 personas ≥4 high-confidence threshold satisfied)
- I-S12 ✓ (existing Synthesis disagreement invariant preserved; isolated aggregation per DD-3 preserves I-S12 via existing recommendation_heuristic deterministic disagreement-override)
- I-S35 ✓ (Theme H output = THESIS_CANDIDATE / INVESTIGATE / WATCH / PASS enum; NO buy/sell surface)
- Phase 1b COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; L-S354-2/L-S366-4/L-S369-1 cascade)
- 5-source-evidence chain populated per § H (5 distinct decisions with 5 sources each = 25 citations)
- ai-hedge-fund LICENSE-file caveat A-01 § 6 ACKNOWLEDGED + pattern-port not code-port mandate ✓
- anthropic_api_to_subagent memory-rule BC-8 surface flagged in § C.0.5 + DD-5 + RM-AS-1 ✓
- Phase E DONE attestation S372 8f68947 acknowledged in § N.1 + § N.4 ✓

---

**END OF MASTER PLAN 033-S373-PHASE-FPRIME-MULTI-PERSPECTIVE-MASTER-PLAN**

> Plan file ends at this line. Architect output complete. Main session reviews + dispatches sub-plan 034 author per § N sequencing.
