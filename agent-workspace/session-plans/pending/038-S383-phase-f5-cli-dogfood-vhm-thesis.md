---
plan_id: 038-S383-phase-f5-cli-dogfood-vhm-thesis
target_session: S384 (sandwich-dev FOCUSED_IMPL; S385 sandwich-verifier AP-1 follows; S386 close-bookkeeping = Phase F-prime DONE attestation)
type: PLAN (sub-plan author = sandwich-architect; one of the 5 F-prime sub-plans per master plan-033 § E; THE FINAL sub-plan for Phase F-prime)
budget: ~150-230K Opus PLAN authoring envelope THIS session (architect; combined with plan-037 NO-OP per single dispatch); IMPL S384 100-150K FOCUSED_IMPL Opus (single session preferred; includes wall-clock dogfood run wait time per persona LLM call); VERIFY S385 30-60K Opus AP-1 fresh-context
phase: F-prime sub-track F.5 (CLI dogfood thesis on VHM — first end-to-end Wave 1 product validation; closes Phase F-prime)
track: Wave 1 Theme H — Multi-perspective adversarial extension (per master plan-033 § E.5)
parent_master_plan: agent-workspace/session-plans/pending/033-S373-phase-fprime-multi-perspective-master-plan.md § E.5 + DD-11 + § K.1.c + § E.4 PARALLEL-ELIGIBLE
predecessor: 036-S380-phase-f3-synthesize-perspectives-usecase (F.3 SHIPPED post-S382 remediation — dict[PerspectiveRole, LLMPerspectivePort] generalization + V0=6 wiring + 1208 tests; per current-execution S375/S378/S381-S382 close-bookkeeping)
predecessor_2: 037-S383-phase-f4-v0-9-expansion (F.4 NO-OP DEFERRAL; V0=6 default applies; PARALLEL-ELIGIBLE per master plan § E.4)
predecessor_3: 035-S377-phase-f2-personas-buffett-graham-taleb (F.2 SHIPPED — 3 persona adapters + JSON role-packs; ADR D-075 PROPOSED)
predecessor_4: 034-S374-phase-f1-rolepromptpack-and-transport-flip (F.1 SHIPPED — RolePromptPack + PersonaRegistry + BC-8 transport-flip; ADR D-074 PROPOSED)
successor_candidate: NONE (Phase F-prime DONE attestation at S386 close; next master-plan beat is Phase G-prime per master plan-033 § 6 — explicit Phase F-prime closure attestation contract per § M)
architect: S383 sandwich-architect (background; THIS plan-authoring session — combined with plan-037 NO-OP per single dispatch)
dispatched_by: main session orchestrating Phase F-prime per master plan § E sequencing (F.1 + F.2 + F.3 all SHIPPED + post-S382 remediation; F.4 NO-OP; F.5 final IMPL sub-track closes Phase F-prime)
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED per plan-025 DD-11 mandate; **n=3 multi-perspective-impl precedent declared** — S375 (F.1 IMPL) + S378 (F.2 IMPL) + S381 (F.3 IMPL); see § L)
executing_agent: N/A this session (architect); S384 sandwich-dev executes per § E sub-tracks D1-D5
status: pending-execution (Phase F-prime § E.5 sub-plan; main session reviews + dispatches S384 sandwich-dev FOCUSED_IMPL after this plan ratified; PARALLEL-ELIGIBLE with plan-037 NO-OP per master plan § E.4-5)

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward)"
  - "L-S382-1 HIGH PROMOTE-NOW HOLD — ctor-signature-change discipline gap. **MANDATORY for F.5 IMPL**: IF any ctor signature change ships in F.5 (e.g. CLI sub-command class, render-helper, persona-output collator), dev MUST `grep -rn '<ClassName>(' packages/ apps/ tests/` + update ALL call sites + RE-RUN full-project pytest scope (NOT sub-package scope) BEFORE commit. **See § D DD-4 for F.5-specific application + § J RM6 for mitigation chain**."

depends_on:
  - "F.1 SHIPPED (S375 + S376 verifier; ADR D-074 PROPOSED) — RolePromptPack + PersonaRegistry + BC-8 transport-flip; substrate for V0=6 dogfood"
  - "F.2 SHIPPED (S377 + S378 verifier; ADR D-075 PROPOSED) — 3 persona adapters at packages/infrastructure/analysis/perspectives/{buffett,graham,taleb}_agent.py + 3 V0 JSON role-packs at agent-workspace/role-packs/{buffett,graham,taleb}.json"
  - "F.3 SHIPPED (S381 + S382 verifier PASS-with-F1-F3-inline-fix; ADR D-076 ACCEPTED) — dict[PerspectiveRole, LLMPerspectivePort] generalization at packages/application/analysis/use_cases/validate_thesis_phase1.py:158-172 + composition root V0=6 wiring at apps/_shared/use_case_builder.py:179-225 + 1208 tests"
  - "F.4 NO-OP (S383 sub-plan 037; V0=6 default applies per master plan DD-2 + AQ-8) — F.5 dogfood runs on V0=6 personas; V0=9 expansion deferred per AP-7 named revisit triggers (one of which is F.5 dogfood empirical evidence — see plan-037 § B Trigger C)"
  - "Existing apps/cli/validate_thesis.py at apps/cli/validate_thesis.py:1-340 (340 LOC; click CLI for 3-perspective thesis analysis; PRE-EXISTING from S43a Track F per spec 006 § B.7 UC-2; supports --ticker + --as-of + --transport=anthropic|subagent + --mock-llm; F1 verifier S382 fix preserved — `_make_use_case` helper at test_validate_thesis.py:212-234 already updated to pass agents= dict kwarg per L-S382-1 inline remediation)"
  - "Existing apps/_shared/use_case_builder.build_use_case at apps/_shared/use_case_builder.py:63-128 (composition root; V0=6 wiring shipped at F.3; _build_subagent_agents at :179-225 wires BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB on ClaudeLLMPerspectiveAdapter + claude_cli_transport; per-role model override BULL→haiku per S43b-BULL fix)"
  - "Existing thesis-log directory at agent-workspace/memory/thesis-log/ + _template.md schema (F.5 dogfood output goes here per validate_thesis.py:74 default --output-dir)"
  - "Existing _render_thesis_md at apps/cli/validate_thesis.py:192-317 (markdown rendering for 3-perspective thesis; bear+bull+quant sections + trade-off matrix + disagreements + reasoning trace + I-S35 disclaimer footer; F.5 EXTENDS to V0=6 sections — see § D DD-3)"
  - "Existing SQLite database at data/stockforge.sqlite (referenced by build_use_case --db arg; SqliteThesisRepository persists Thesis aggregate; _SubagentDataGatherer reads bars+statements+ratios+news+claims for ticker as_of) — STEP 0.2 verifies VHM data presence"
  - "claude CLI substrate at C:/Users/PC/.local/bin/claude.exe v2.1.140 (per S375 close-bookkeeping VBW check; F.5 STEP 0.1 RE-VERIFIES alive + responsive — DOGFOOD requires live LLM substrate, not mock)"
  - "I-S1 (NO LLM math) BY-CONSTRUCTION PRESERVED — F.5 dogfood validates per-persona LLM emits ONLY categorical + reasoning + GroundedPoint; aggregation deterministic via Phase1Synthesizer; verifier S385 grep-confirms zero numeric prose emerge in VHM thesis output"
  - "I-S10 (bear case ≥3 distinct points + ≥3 categories) BY-CONSTRUCTION PRESERVED — F.5 dogfood thesis MUST satisfy I-S10 (Thesis._enforce_bear_case at thesis.py:91-115); IF BEAR perspective fails I-S10 on VHM real data → INCOMPLETE thesis returned (exit 2); F.5 verifier captures this as legitimate outcome"
  - "I-S12 (Disagreement Surfaced) BY-CONSTRUCTION PRESERVED — F.5 dogfood expected to surface ≥1 disagreement across 6 personas (statistically near-certain on VHM real news data); verifier S385 inspects explicit_disagreements non-empty"
  - "I-S35 (research-aid framing) BY-CONSTRUCTION PRESERVED — F.5 dogfood thesis MUST include _DISCLAIMER_MD at apps/cli/validate_thesis.py:46-53 footer + final_recommendation MUST be Recommendation enum (INVESTIGATE/WATCH/PASS/THESIS_CANDIDATE) NOT 'buy/sell' prose; STEP 0.5 STOP-AND-ASK if any persona emits 'buy/sell' prose in dogfood output"
  - "AC-5 reproducibility — F.5 verifier S385 SHOULD re-run dogfood once with identical inputs + verify thesis_id identical (deterministic per AC-5 STABLE-SORTED-BY-ROLE at validate_thesis_phase1.py:245-256); IF thesis_id differs → AC-5 regression"
  - "D-054 (retry-validator pattern — per-agent retry-validator) PRESERVED — each persona has 3-attempt retry-validator internal to adapter; F.5 dogfood may exercise retry per real LLM output quality variability"
  - "D-059 (Python determinism) BINDING — any new .py file in F.5 (CLI extension OR test file) MUST satisfy R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for sub-plan dev commit boundary"
  - "D-074 (BC-8 Transport Flip ACCEPTED at S375) + D-075 (BC-8 First 3 Personas ACCEPTED at S378) + D-076 (BC-8 N-Perspective Synthesizer ACCEPTED at S381) — F.5 CONSUMES all three"
  - "Charter Principle 7 (dogfood — internal use first) — F.5 IS THE DOGFOOD; Wave 1 MVP demonstration; one-ticker VHM focus per Charter Principle 4 Vietnam-specificity moat"
  - "Charter Principle 8 (calibration-over-confidence) — F.5 establishes V0 calibration BASELINE (n=1 dogfood; calibration_grade='D' per validate_thesis.py:52 Phase 2 default; post-MVP calibration mature via thesis outcomes feedback loop)"
  - "skill .claude/skills/claude-api/SKILL.md (LLM dispatch discipline) + skill .claude/skills/ddd-tactical-patterns/SKILL.md (Aggregate pattern — Thesis aggregate persisted via SqliteThesisRepository)"

binding_decisions:
  - "CLI DOGFOOD = EXTEND existing apps/cli/validate_thesis.py (NOT new CLI file) per master plan DD-11 architect-recommended pattern — `apps/cli/validate_thesis.py` already exists at 340 LOC; F.5 dogfood runs via `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of 2026-05-17`; D3 EXTENDS markdown renderer to V0=6 sections + dogfood-mode flag; alternate REJECTED (new `apps/cli/synthesize_vn_thesis.py` per master plan § E.5 wording is RE-INTERPRETED as 'extend existing' per architect-VBW that validate_thesis.py is V0=6-ready post-F.3 SHIP; master plan AQ-7 explicitly named the existing file as the CLI substrate)"
  - "DOGFOOD TICKER = VHM (Vinhomes) — per master plan DD-11 architect-recommended; alternates HPG/VIC/FPT pre-named in DD-11 for STEP 0.2 fallback; project-owner override permitted via STEP 0.2 STOP-AND-ASK if VHM data corpus stale (NON-BLOCKING; no Q-INT required per DD-11)"
  - "DOGFOOD MODE = LIVE LLM via claude CLI substrate (NOT --mock-llm) — F.5 IS THE DOGFOOD; mock mode defeats purpose; STEP 0.1 verifies claude CLI alive; STEP 0.4 verifies live API cost budget per Charter calibration (~$5 single-thesis test recommended; ENFORCED at use case scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:189 — Decimal('3.00') HARD CAP)"
  - "DOGFOOD OUTPUT = persisted thesis markdown at agent-workspace/memory/thesis-log/2026-05-17-VHM.md (default --output-dir per validate_thesis.py:74) + persisted Thesis aggregate via SqliteThesisRepository (data/stockforge.sqlite) — F.5 verifier inspects BOTH artifacts"
  - "PHASE F-PRIME DONE ATTESTATION CONTRACT — defined in § M; F.5 verifier S385 PASS verdict + S386 close-bookkeeping = Phase F-prime DONE → Wave 1 MVP ready; explicit attestation criteria per § M ≥10 items"
  - "V0=6 CALIBRATION BASELINE ESTABLISHMENT — F.5 dogfood establishes n=1 calibration BASELINE; calibration_grade='D' per validate_thesis.py:52 + thesis.py field default; post-MVP calibration mature via outcomes feedback loop (Charter Principle 8 calibration-over-confidence); n≥50 trigger named for calibration_grade promotion to A-B-C per master plan § A.3 row 2"
  - "L-S382-1 HIGH MANDATORY APPLICATION — F.5 IMPL ships markdown-rendering extensions + (potentially) new dogfood-mode flag + (potentially) new CLI sub-command for thesis-log indexing. **IF ANY ctor signature changes ship** (e.g. new MarkdownRenderer class param, new IndexBuilder helper), dev MUST `grep -rn '<ClassName>(' packages/ apps/ tests/` + update ALL call sites + RE-RUN full-project pytest scope BEFORE commit. § DD-4 documents F.5-specific application; § J RM6 documents mitigation chain"
  - "BACKWARD-COMPAT MANDATORY — F.5 EXTENDS validate_thesis.py; existing CLI invocations (`--ticker HPG --mock-llm` 3-perspective path) STILL work; existing test_validate_thesis.py tests STILL pass; existing _render_thesis_md call from validate_thesis.py:152 STILL works with backward-compat 3-persona thesis input; V0=6 path is ADDITIVE not REPLACEMENT"
  - "VBW protocol mandatory — every architect claim cites file:line; dev STEP 0 re-verifies before any edit"
  - "Karpathy P3 surgical-changes — F.5 IMPL ≤300 LOC delta total (CLI extension ≤100 LOC + markdown renderer extension ≤100 LOC + dogfood-specific tests ≤100 LOC); NOT >1000 LOC rewrite"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN+IMPL; architect tools: [Read, Glob, Grep, Write])"
  - "no commits in THIS plan-session by architect (sandwich-architect has no Bash; main commits architect's plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no F.1/F.2/F.3 file touches unless EXTENDING THEIR CALLERS — RolePromptPack/PersonaRegistry/{buffett,graham,taleb}_agent.py + validate_thesis_phase1.py + use_case_builder.py = ALL LEAF dependencies; F.5 IMPL only modifies apps/cli/validate_thesis.py + apps/cli/test_validate_thesis.py + thesis-log artifact + ADR D-078"
  - "no F.4 dispatch from THIS plan — F.4 sub-plan 037 NO-OP runs PARALLEL per master plan § E.4-5"
  - "no Charter amendment from THIS plan — Phase F-prime stays charter-coherent; FLAG only if dogfood reveals charter-tier issue (e.g. per-persona Recommendation drift to 'buy/sell' prose; I-S35 violation; STEP 0.5 STOP-AND-ASK)"
  - "no harness/hook changes — F.5 ships product substrate (CLI dogfood); surface any harness gaps in observation; do NOT fix here"
  - "every plan claim cites source file:line"
  - "actual files read via Read tool, not from memory (VBW protocol; this session read validate_thesis.py 1-340 via Read, use_case_builder.py 1-380 via Read, validate_thesis_phase1.py 1-300 via Read, master plan-033 via Grep)"
---

# S383 — Phase F.5 CLI Dogfood Thesis on VHM (PLAN)

> **One-sentence intent**: Extend the existing `apps/cli/validate_thesis.py` to render V0=6 perspective sections + produce one actual dogfood thesis on VHM (Vinhomes) via live `claude CLI` substrate, validating the full F.1+F.2+F.3 pipeline end-to-end and establishing the Phase F-prime DONE attestation that unlocks Wave 1 MVP.

---

## A. Goal & Scope

### A.1 Goal

Ship the **first end-to-end Wave 1 product validation** — one actual dogfood thesis on VHM ticker via live `claude CLI` substrate exercising V0=6 personas (BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB), producing:

- **Live dogfood execution**: `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of 2026-05-17` runs end-to-end through F.1 (RolePromptPack) + F.2 (3 new personas) + F.3 (N-persona dispatch + synthesis) + existing BC-1/2/5 data layers
- **Persisted thesis markdown**: `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` with V0=6 perspective sections (BEAR/BULL/QUANT + BUFFETT/GRAHAM/TALEB) + trade-off matrix + explicit disagreements + reasoning trace + I-S35 disclaimer footer
- **Persisted Thesis aggregate**: SqliteThesisRepository row at `data/stockforge.sqlite` with status=SUBMITTED (or INCOMPLETE if I-S10 bear-case insufficient) + final_recommendation enum + confidence_level enum + cost_usd ≤ Decimal('3.00')
- **V0 calibration baseline**: n=1 calibration BASELINE per Charter Principle 8 (calibration-over-confidence); calibration_grade='D' default per validate_thesis.py:52 Phase 2; n≥50 trigger named for calibration_grade promotion
- **Phase F-prime DONE attestation**: S385 verifier PASS + S386 close-bookkeeping marks Phase F-prime DONE → Wave 1 MVP ready (per § M Phase F-prime DONE attestation contract ≥10 items)

### A.2 In-scope (this sub-plan ships)

This sub-plan ships:

1. **D1 — `apps/cli/validate_thesis.py` `_render_thesis_md` extension** (target: EXTEND `apps/cli/validate_thesis.py:192-317` to render V0=6 perspective sections — adds BUFFETT/GRAHAM/TALEB sections after existing BEAR/BULL/QUANT sections; ~80-100 LOC delta; backward-compat with N=3 thesis input)

2. **D2 — Optional `--run-mode` CLI flag for dogfood metadata** (target: EXTEND `apps/cli/validate_thesis.py:56-96` click options to add `--run-mode=dogfood|smoke` flag default smoke; dogfood mode adds extra metadata to thesis markdown header — `dogfood: true` + `dogfood_session: S384` + `dogfood_ticker_rationale: VHM (Vinhomes; VN30 blue chip; per master plan DD-11)`; ~20-30 LOC delta)

3. **D3 — Live dogfood execution wall-clock run** (target: WALL-CLOCK EXECUTION `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of 2026-05-17 --run-mode dogfood` — produces actual thesis-log markdown + actual Thesis aggregate persisted; ~3-5 min wall-clock for 6 personas × ~30s/persona LLM calls; cost ≤ Decimal('3.00') HARD CAP per validate_thesis_phase1.py:189)

4. **D4 — Test additions for V0=6 markdown rendering** (target: EXTEND `apps/cli/test_validate_thesis.py` to add ≥5 NEW tests for `_render_thesis_md` V0=6 input cases — BUFFETT-section present + GRAHAM-section present + TALEB-section present + I-S35 disclaimer footer preserved + Recommendation enum NOT 'buy/sell' prose; backward-compat tests for N=3 input STILL pass; existing test count ≥30 preserved)

5. **D5 — ADR D-078 PROPOSED at IMPL tier** (target: NEW `agent-workspace/memory/decisions/078-bc-8-v0-dogfood-cli-vhm.md` ~150-200 LOC documenting Wave 1 MVP first dogfood + V0=6 calibration baseline + VHM ticker rationale + dogfood execution evidence chain + Phase F-prime DONE attestation cross-reference)

6. **D6 — Phase F-prime DONE attestation evidence collection** (target: collected by S385 verifier — verifier S385 inspects: thesis markdown (V0=6 sections present + I-S35 disclaimer + Recommendation enum), Thesis aggregate (status SUBMITTED OR legitimate INCOMPLETE + cost_usd ≤ Decimal('3.00')), 6-persona LLM call cost breakdown, AC-5 reproducibility re-run (optional; SHOULD if budget allows); produces Phase F-prime DONE attestation report per § M)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| KOL ingestion (Vietnamese stock pundit Telegram/Facebook ingestion) | Phase 3.5 work per Charter; not Wave 1 MVP critical path; F.5 dogfood uses existing CafeF/NDH/Vietstock/VietnamBiz news corpus (Phase D NDH SHIPPED + remaining adapters pending) | Phase 3.5 entry per master plan § A.3 |
| Pump detection (đội lái signal extraction) | Phase 4 work per Charter; not Wave 1 MVP critical path; F.5 dogfood uses TALEB persona's tail-risk lens as V0 surrogate for pump-risk surface | Phase 4 entry per master plan § A.3 |
| Multi-ticker dogfood batch (HPG + VIC + FPT + ... simultaneous dogfood) | Karpathy P2 simplicity-first; one-ticker focus reduces V0 complexity; allows F.5 verifier to focus on per-persona output quality on one well-known case | Trigger: F.5 verifier PASS + project-owner directive for multi-ticker dogfood OR Phase 2 dashboard wiring (Streamlit) needs multi-ticker showcase |
| Streamlit dashboard rendering of V0=6 thesis | Phase H-prime work per master plan § 6.4.5; F.5 CLI dogfood is V0 sufficient | Phase H-prime entry per master plan § 6.4.5 |
| V0=9 expansion (Munger + Lynch + VN_DOMAIN_SPECIALIST) | Plan-037 NO-OP per master plan DD-2 V0=6 default; explicit revisit triggers in plan-037 § B (Trigger A/B/C — Trigger C is THIS F.5 dogfood empirical evidence path) | See plan-037 § B Trigger A/B/C |
| Per-persona calibration_grade in PerspectiveAnalysis | Charter Principle 8 calibration-over-confidence — per-persona calibration is post-MVP; V0 ships with calibration_grade='D' on Thesis aggregate (existing field at thesis.py default) | Calibration trigger: n≥50 thesis outcomes per-persona across 3+ months wall-clock — post-MVP per master plan § A.3 row 2 |
| Live API budget enforcement beyond Decimal('3.00') HARD CAP | Existing scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:189 is sufficient for V0; F.5 dogfood empirical cost feeds future budget tuning | F.5 dogfood empirical cost > Decimal('2.50') triggers F.5-V2 budget tightening study |
| AC-5 reproducibility re-run (deterministic thesis_id verification) | Optional; SHOULD if budget allows in S385 verifier; not BLOCKING for Phase F-prime DONE | F.5 verifier S385 STEP per § F DC-VERIFY-5 IF budget allows |
| New CLI sub-command for thesis-log indexing | Karpathy P2 simplicity-first; existing thesis-log directory is markdown-flat-file; indexing is post-MVP | Trigger: 50+ thesis-log entries OR project-owner directive for indexing CLI |
| Outer-loop calibration database scaffolding | Charter Principle 8 — calibration database is post-MVP; F.5 dogfood is BASELINE n=1; future calibration loop entry triggers DB schema authoring | Trigger: n≥10 dogfood theses + project-owner directive for outer-loop calibration DB |
| Per-persona retry-validator stress test on VHM | Existing per-agent retry-validator (D-054 B5 — 3 attempts) is per-attempt unit-test covered; F.5 dogfood NATURALLY exercises retry per real LLM output variability; not separate stress test | Trigger: F.5 dogfood reveals >50% retry rate on any persona → F.5-V2 retry tuning |

### A.4 NOT in scope (out-of-Phase-F-prime-entirely; reference only)

- ADR D-077 NEVER WRITTEN (reserved for hypothetical V0=9 expansion future-plan per plan-037 § E sub-track table)
- Phase G-prime Theme G ratification cycle (next master-plan beat per master plan-033 § 6)
- Phase H-prime Streamlit dashboard
- Phase I-prime Vietnamese NLP polish
- Wave 2+ ratification beats per master plan § A.4

---

## B. In-scope / Out-of-scope summary

**IN-scope (this plan ships)**:
- Existing CLI extension (validate_thesis.py D1+D2 ~100-130 LOC delta)
- Live dogfood execution on VHM (D3 wall-clock)
- Test additions for V0=6 markdown (D4 ≥5 new tests)
- ADR D-078 PROPOSED (D5 ~150-200 LOC)
- Phase F-prime DONE attestation evidence (D6 collected by S385 verifier)

**OUT-of-scope**:
- KOL ingestion + pump detection (Phase 3.5/4 per master plan)
- Multi-ticker batch dogfood (P2 simplicity)
- Streamlit dashboard (Phase H-prime)
- V0=9 expansion (plan-037 NO-OP per master plan DD-2)
- Per-persona calibration mechanism (post-MVP per Charter Principle 8)

---

## C. STEP 0 — BLOCKING gates (executed by S384 dev BEFORE any edit)

### STEP 0.1 — claude CLI substrate availability check (BLOCKING)

**Verify**: `claude --version` returns version string (per S375 close-bookkeeping VBW: v2.1.140 at `C:/Users/PC/.local/bin/claude.exe` confirmed alive)

**Empirical check**: `where claude` (Windows) OR `which claude` (POSIX) returns path; `claude --version` returns version string; `claude --help` returns help text.

**STOP-AND-ASK trigger**: IF claude CLI not found OR --version fails OR --help fails → emit STOP-AND-ASK to project owner with options: (a) install claude CLI per https://docs.claude.com/en/docs/claude-code/installation, (b) defer F.5 IMPL pending claude CLI install, (c) fallback to --mock-llm mode (DEFEATS dogfood purpose; emergency-only)

### STEP 0.2 — VHM ticker resolution + data availability check (BLOCKING)

**Verify**: VHM data presence in `data/stockforge.sqlite`:
- BC-1 bars: `SELECT COUNT(*) FROM bars WHERE ticker='VHM' AND date >= date('2025-05-17')` returns ≥30 rows (≥30 trading days last year)
- BC-2 financial statements: `SELECT COUNT(*) FROM financial_statements WHERE ticker='VHM'` returns ≥1 row (≥latest 1 statement)
- BC-5 news: `SELECT COUNT(*) FROM news WHERE 'VHM' = ANY(string_to_array(tickers_mentioned, ',')) AND published_at >= date('2026-02-17')` returns ≥5 rows (≥5 news items last 90 days)

**Empirical check**: dev runs sqlite3 query via Bash `sqlite3 data/stockforge.sqlite "SELECT COUNT(*) FROM bars WHERE ticker='VHM' AND date >= date('2025-05-17')"` + similar for statements + news

**STOP-AND-ASK trigger**: IF any of bars<30 OR statements<1 OR news<5 → emit STOP-AND-ASK to project owner with options per master plan AQ-9: (a) corpus refresh via existing CafeF/NDH/Vietstock/VietnamBiz adapter CLIs (~10-15 min wall-clock per source), (b) switch to alternate ticker per master plan DD-11 fallback (HPG/VIC/FPT), (c) defer F.5 IMPL pending corpus expansion; NON-BLOCKING choice per master plan AQ-9

### STEP 0.3 — Existing CLI surface verification (BLOCKING)

**Verify**: `apps/cli/validate_thesis.py` exists at 340 LOC + `apps/cli/test_validate_thesis.py` exists + S382 F1 inline-fix preserved (_make_use_case at test_validate_thesis.py:212-234 uses `agents=` dict kwarg)

**Empirical check**: dev runs `python apps/cli/validate_thesis.py --help` (returns CLI help; no import errors) + `python -m pytest apps/cli/test_validate_thesis.py -v` (returns all PASS; ≥1 test per branch)

**STOP-AND-ASK trigger**: IF CLI import errors OR test_validate_thesis.py has failures → emit STOP-AND-ASK with options: (a) inspect + fix import/test gap inline (preserves F.5 IMPL session), (b) defer F.5 IMPL pending separate CLI repair session

### STEP 0.4 — Live API budget check (BLOCKING)

**Verify**: validate_thesis_phase1.py:189 scoped_budget(limit_usd=Decimal('3.00')) ENFORCES hard cap; F.5 dogfood EXPECTED cost ~$1.50-2.50 for 6 personas (Sonnet 5 personas × ~$0.20-0.40/call + Opus QUANT × ~$0.40-0.80/call + Synthesizer deterministic Python free)

**Empirical check**: dev confirms scoped_budget hard cap unchanged at validate_thesis_phase1.py:189 + per-role model routing per use_case_builder.py:217 (BULL→haiku-4-5 per S43b fix; BEAR/BULL/QUANT default per claude_llm_perspective_adapter.py _ROLE_TO_MODEL; BUFFETT/GRAHAM/TALEB fall through to _DEFAULT_MODEL Opus per F.3 plan-036 DD-9 deferral)

**STOP-AND-ASK trigger**: IF expected cost > Decimal('2.50') OR project owner expresses cost concern → emit STOP-AND-ASK with options: (a) tighten budget cap to Decimal('2.00') for dogfood (edit validate_thesis_phase1.py:189 inline), (b) downgrade BUFFETT/GRAHAM/TALEB to Sonnet via role_model_overrides (edit use_case_builder.py:217 to add BUFFETT/GRAHAM/TALEB→sonnet), (c) proceed with default budget (recommended unless concern)

### STEP 0.5 — STOP-AND-ASK aggregator + charter-tier flag evaluation (BLOCKING)

**Aggregate**: If any of STEP 0.1-0.4 triggered STOP-AND-ASK → main session fires AskUserQuestion bundle covering all 4 STEP 0 items per Q&A bundling mega-bundle pattern (per user pref); proceed only when all 4 cleared.

**Charter-tier flag evaluation** (master plan § K.1.c + § K.2):
- IF dogfood output `final_recommendation` is 'buy' OR 'sell' prose phrasing (NOT Recommendation enum) → I-S35 violation surface; CHARTER-TIER FLAG mandatory; STEP 0.5 STOP-AND-ASK fires with options per master plan § K.1.c
- IF dogfood output `confidence_level` is '0.85' numeric prose (NOT HIGH/MEDIUM/LOW enum) → I-S1-1 Rule 16 violation surface; CHARTER-TIER FLAG mandatory; STEP 0.5 STOP-AND-ASK fires
- IF dogfood output any persona emits numeric prose like 'approximately 15%' or 'roughly 8' → I-S1 NO-LLM-MATH violation surface; CHARTER-TIER FLAG mandatory; STEP 0.5 STOP-AND-ASK fires

**Verification**: STEP 0.5 evaluation surface authored in S385 verifier brief; verifier S385 inspects dogfood output empirically and flags any I-S35/I-S1-1/I-S1 violation per master plan § K protocol

---

## D. Decision Documentation (DD-1 through DD-7)

### DD-1: CLI dogfood = EXTEND existing validate_thesis.py NOT new file

**Decision**: F.5 IMPL extends existing `apps/cli/validate_thesis.py` (340 LOC); does NOT create new `apps/cli/synthesize_vn_thesis.py` as suggested by master plan § E.5 wording.

**Rationale**:
1. validate_thesis.py is V0=6-ready post-F.3 SHIP (use_case_builder._build_subagent_agents at apps/_shared/use_case_builder.py:179-225 wires all 6 personas; `_make_use_case` test helper at test_validate_thesis.py:212-234 passes agents= dict per S382 F1 inline-fix)
2. Master plan AQ-7 ("CLI dogfood reveals VHM data gap") explicitly named the EXISTING CLI as the substrate (`apps/cli/validate_thesis.py`)
3. Karpathy P2 simplicity-first: one CLI = lower mental model; click already supports --ticker + --as-of + --transport=subagent + --output-dir for dogfood UX needs
4. Markdown renderer at validate_thesis.py:192-317 needs V0=6 extension (D1) regardless; new CLI duplicates rendering logic = AP violation

**Adversarial alternate considered**: NEW `apps/cli/synthesize_vn_thesis.py` (per master plan § E.5 literal wording) — REJECTED because (a) duplicates 90% of validate_thesis.py CLI shell + markdown renderer logic, (b) creates two thesis-CLI entry points with risk of drift, (c) V0=6 is already wired in validate_thesis.py via build_use_case post-F.3, (d) master plan AQ-7 references EXISTING CLI as substrate.

**Source**: master plan-033 § E.5 + AQ-7; F.3 plan-036 D3 SHIPPED V0=6 composition root; apps/cli/validate_thesis.py:107-145 build_use_case integration

### DD-2: Dogfood ticker = VHM (architect-recommended per master plan DD-11)

**Decision**: F.5 dogfood runs on VHM (Vinhomes) ticker per master plan DD-11 architect recommendation.

**VHM rationale** (per master plan DD-11):
- VN30 blue-chip; not micro-cap (avoids "delisted company" data gap risk)
- VinGroup-affiliated (cross-holding moat discussion already in BUFFETT.json vietnam_notes → tests persona-specific Vietnam relevance)
- Real estate sector (well-represented in NDH + Vietstock + VietnamBiz coverage)
- Sufficient news corpus from Phase E.2 lexicon dogfood (existing CafeF/NDH/Vietstock/VietnamBiz coverage)
- Project-owner-familiar (frequently discussed in VN financial press)

**Adversarial alternate considered**: HPG (Hoa Phat Group steel; per master plan DD-11 alternate) — DEFERRED to fallback only (per STEP 0.2 STOP-AND-ASK option (b) IF VHM data gap surfaces). Other alternates: VIC (parent of VHM; over-correlated with VHM), FPT (tech sector; less Vietnam-specific moat discussion than VHM).

**NON-BLOCKING design**: Project owner can override VHM pick at STEP 0.2 STOP-AND-ASK WITHOUT triggering Q-INT (no charter implication per master plan DD-11).

**Source**: master plan-033 DD-11 + § E.5

### DD-3: Markdown renderer extension = ADDITIVE V0=6 sections (BUFFETT/GRAHAM/TALEB after BEAR/BULL/QUANT)

**Decision**: `_render_thesis_md` at apps/cli/validate_thesis.py:192-317 EXTENDED to render 3 NEW sections (BUFFETT/GRAHAM/TALEB) ADDITIVELY after existing BEAR/BULL/QUANT sections; backward-compat with N=3 thesis input preserved (BUFFETT/GRAHAM/TALEB sections skipped if perspective not present).

**Section ordering** (per stable-sorted-by-role per AC-5 STABLE-SORTED-BY-ROLE design at validate_thesis_phase1.py:245):
1. BEAR (existing; I-S10 first per bear-case primacy)
2. BULL (existing; symmetric to BEAR)
3. QUANT (existing; per BR-2 numbers-from-code)
4. BUFFETT (NEW; value+quality+moat)
5. GRAHAM (NEW; deep-value+margin-of-safety)
6. TALEB (NEW; antifragility+tail-risk+convexity)
7. Trade-off matrix (existing)
8. Explicit disagreements (existing; I-S12; may show ≥1 disagreement across 6 personas)
9. Reasoning trace (existing)
10. I-S35 disclaimer footer (existing; PRESERVED unchanged per binding decision)

**Pattern for new sections** (mirrors existing BEAR section at validate_thesis.py:243-253):
```
## {PERSONA_NAME} Case ({category_hint_per_persona})

1. **{key_point.text}** -- source: [{source_url}]({source_url}), as-of: {as_of}, conviction: {conviction}
   > {source_excerpt}
```

**Backward-compat**: If `_find_persp(thesis, "buffett")` returns None (N=3 thesis), section renders "_No buffett perspective available._\n" stub OR skipped entirely per dev preference; existing N=3 thesis CLI invocations STILL work.

**Source**: F.3 plan-036 D2 SHIPPED Phase1Synthesizer N-persona aggregation; validate_thesis.py:192-317 existing renderer

### DD-4: L-S382-1 carry-forward — F.5 ctor-signature-change discipline mandatory

**Decision**: IF F.5 IMPL adds NEW class (e.g. `MarkdownRendererV6`, `DogfoodSessionMetadata`, `ThesisLogIndexer`) WITH public ctor signature → dev MUST `grep -rn '<ClassName>(' packages/ apps/ tests/` + update ALL call sites + RE-RUN full-project pytest scope (NOT sub-package scope) BEFORE commit. Per agent-notes.md L-S360-1/L-S360-2/L-S365-1/L-S327-1 PROMOTE-NOW cluster (L-S382-1 + L-S382-2 HOLD at HIGH severity).

**F.5-specific application**:
- Most likely ctor-class introduction: `MarkdownRendererV6` if dev factors out V0=6 rendering into separate class (vs inline functions per existing pattern at validate_thesis.py:192-317). Architect RECOMMENDS preserving existing inline-function pattern (no new class; ~80-100 LOC inline extension at :192-317; mirrors existing pattern; ZERO ctor risk).
- Less likely: `DogfoodSessionMetadata` dataclass for --run-mode=dogfood metadata. If introduced as @dataclass, ctor is auto-generated; CALLERS must be grep'd if used outside _render_thesis_md.
- Least likely: `ThesisLogIndexer` for indexing — OUT-OF-SCOPE per § A.3 deferred list; should NOT ship in F.5.

**Verification at end of D1+D2+D3+D4**: dev runs `grep -rn '<NewClassName>(' packages/ apps/` for ANY new class introduced + updates ALL call sites + runs `python -m pytest -q` (full-project scope) + reports test count delta in commit message (e.g. "1208→1213 pass; 0 regressions").

**Source**: agent-notes.md L-S360-cluster + mistake-log.md M-S381-1 + M-S381-2 (L-S382-1+L-S382-2 HIGH HOLD); plan-036 binding_decisions § ctor change discipline

### DD-5: V0 calibration baseline = n=1 dogfood; calibration_grade='D' default

**Decision**: F.5 dogfood establishes V0 calibration BASELINE n=1; calibration_grade='D' (per validate_thesis.py:52 Phase 2 default + thesis.py field default per spec 006); post-MVP calibration mature via outcomes feedback loop per Charter Principle 8.

**Rationale**:
- Charter Principle 8 calibration-over-confidence: confidence claims MUST trace to historical hit rate; n=1 dogfood is BASELINE (insufficient for calibration_grade A-B-C; default D is correct per spec)
- F.5 verifier S385 inspects thesis.calibration_grade='D' present in thesis markdown (per validate_thesis.py:52 disclaimer + thesis.py field default)
- Post-MVP calibration trigger named: n≥50 thesis outcomes per-persona across 3+ months wall-clock → calibration_grade promotion via outcomes feedback loop (out-of-scope here; Phase 3+ work)

**Calibration baseline artifact**: dogfood thesis markdown at `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` IS the n=1 baseline; ADR D-078 documents this as V0 calibration BASELINE.

**Source**: Charter Principle 8 (calibration-over-confidence); master plan-033 § A.3 row 2 (calibration trigger); apps/cli/validate_thesis.py:52 disclaimer footer

### DD-6: Dogfood output destination = agent-workspace/memory/thesis-log/ (per existing CLI default)

**Decision**: F.5 dogfood thesis markdown writes to `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` per existing validate_thesis.py:74 `--output-dir` default; Thesis aggregate persists to `data/stockforge.sqlite` per existing SqliteThesisRepository wiring; no NEW destination paths.

**Rationale**: Charter `agent-workspace/CLAUDE.md` § Subdirectories table: `memory/thesis-log/` = "Stock-domain thesis exploration entries. Read-only for IMPL sessions. Append + revisited per calibration"; existing _template.md schema applies; F.5 ADDS one append entry; provenance trail intact.

**Naming convention** (per existing validate_thesis.py:151): `{as_of}-{ticker_upper}.md` = `2026-05-17-VHM.md`.

**Existing thesis-log entries** (per S43-DOGFOOD): pre-existing dogfood entries from S43b live in this directory; F.5 adds 2026-05-17-VHM as latest entry.

**Source**: validate_thesis.py:74 + :151 + agent-workspace/CLAUDE.md § Subdirectories

### DD-7: Run-mode metadata = optional --run-mode flag default smoke; dogfood adds extra header

**Decision**: NEW optional click flag `--run-mode=dogfood|smoke` (default smoke) at validate_thesis.py click options ~:56-96; dogfood mode adds 3 extra YAML frontmatter fields to thesis markdown header:
- `dogfood: true`
- `dogfood_session: S384`
- `dogfood_ticker_rationale: "VHM (Vinhomes; VN30 blue chip; per master plan DD-11)"`

**Rationale**: Provenance trail; F.5 verifier S385 can grep for `dogfood: true` in thesis markdown to identify dogfood vs smoke entries; future calibration outcomes feedback loop can filter to dogfood entries only.

**Backward-compat**: smoke mode = default = existing behavior unchanged (no extra frontmatter); existing tests STILL pass.

**Source**: F.5 architect design; not master-plan-mandated; SUFFICIENT for V0 provenance

---

## E. Sub-track decomposition (D1-D5)

### D1 — Markdown renderer V0=6 extension (~80-100 LOC delta)

**Target**: `apps/cli/validate_thesis.py:192-317` `_render_thesis_md` function

**Changes**:
- ADD `_find_persp(thesis, "buffett")` / `_find_persp(thesis, "graham")` / `_find_persp(thesis, "taleb")` calls at appropriate insertion point (after QUANT section ~:273)
- ADD 3 NEW sections mirroring existing BEAR section pattern at :243-253 (per DD-3 section ordering)
- Each new section ~25-30 LOC: header + for-loop over key_points + source_url + as_of + conviction + source_excerpt blockquote
- Backward-compat: skip section if persp returns None (N=3 thesis input still renders cleanly)

**Verification at end of D1**:
- mypy --strict CLEAN on validate_thesis.py
- ruff CLEAN
- existing test_validate_thesis.py tests STILL pass (backward-compat)

**LOC delta**: ~80-100 LOC (3 sections × ~25-30 LOC + ~5-10 LOC for stable iteration order)

### D2 — Optional --run-mode CLI flag for dogfood metadata (~20-30 LOC delta)

**Target**: `apps/cli/validate_thesis.py:56-96` click options block + `_render_thesis_md` header construction at :202-219

**Changes**:
- ADD `@click.option('--run-mode', type=click.Choice(['smoke', 'dogfood'], case_sensitive=False), default='smoke', help='Provenance mode: smoke (default) or dogfood (adds metadata)')` to click options
- THREAD `run_mode: str` param through `main(...)` signature
- EXTEND `_render_thesis_md(thesis, ..., run_mode='smoke')` signature optional kwarg
- IF run_mode='dogfood': ADD 3 YAML frontmatter lines at :209 (after `real_thesis: false`):
  ```
  f"dogfood: true",
  f"dogfood_session: S384",
  f'dogfood_ticker_rationale: "VHM (Vinhomes; VN30 blue chip; per master plan DD-11)"',
  ```

**Verification at end of D2**:
- mypy --strict CLEAN
- ruff CLEAN
- `python apps/cli/validate_thesis.py --help` shows new --run-mode option
- existing test_validate_thesis.py tests STILL pass (default smoke mode unchanged)

**LOC delta**: ~20-30 LOC (click option + signature threading + conditional frontmatter)

### D3 — Live dogfood execution wall-clock run (no code; execution artifact)

**Target**: WALL-CLOCK EXECUTION (Bash) `python apps/cli/validate_thesis.py --ticker VHM --transport subagent --as-of 2026-05-17 --run-mode dogfood`

**Pre-conditions** (verified by STEP 0):
- claude CLI alive (STEP 0.1)
- VHM data corpus available (STEP 0.2)
- CLI surface healthy (STEP 0.3)
- Live API budget cleared (STEP 0.4)
- STOP-AND-ASK aggregator cleared (STEP 0.5)

**Execution**:
- dev runs CLI in Bash; ~3-5 min wall-clock (6 personas × ~30s/persona LLM calls; some concurrency via asyncio.gather)
- Expected outcome: thesis markdown written to `agent-workspace/memory/thesis-log/2026-05-17-VHM.md`; Thesis aggregate persisted to `data/stockforge.sqlite`; CLI exit 0 (SUBMITTED) OR exit 1 (cost cap) OR exit 2 (bear case insufficient)

**Failure handling**:
- Exit 1 (cost cap exceeded): STOP-AND-ASK to project owner; (a) tighten budget cap, (b) downgrade personas to Sonnet, (c) defer F.5 IMPL
- Exit 2 (bear case insufficient on real VHM data): LEGITIMATE outcome; verifier S385 captures as legitimate INCOMPLETE; Phase F-prime DONE attestation per § M still achievable (V0 pipeline validated end-to-end even if I-S10 not satisfied this single run)
- Exit 3/4 (DOGFOOD gate / missing API key): STEP 0.1 should have caught — if surfaced here, dev re-runs STEP 0.1

**Verification at end of D3**:
- thesis markdown file exists at expected path
- thesis markdown contains V0=6 sections (BEAR/BULL/QUANT/BUFFETT/GRAHAM/TALEB)
- thesis markdown contains I-S35 disclaimer footer
- thesis markdown contains Recommendation enum value (NOT 'buy/sell' prose)
- Thesis aggregate persisted to sqlite (sqlite3 query confirms row present)

**LOC delta**: 0 (execution artifact; produces thesis markdown ~200-400 LOC AS DATA not code)

### D4 — Test additions for V0=6 markdown rendering (≥5 NEW tests; ~80-100 LOC)

**Target**: `apps/cli/test_validate_thesis.py` (existing test file; preserves backward-compat tests)

**NEW tests** (≥5):
- **TC-RENDER-V6-1**: `test_render_v6_includes_buffett_section` — input V0=6 thesis; render output contains "## BUFFETT" or "## Buffett" section header
- **TC-RENDER-V6-2**: `test_render_v6_includes_graham_section` — input V0=6 thesis; render output contains "## GRAHAM" or "## Graham" section header
- **TC-RENDER-V6-3**: `test_render_v6_includes_taleb_section` — input V0=6 thesis; render output contains "## TALEB" or "## Taleb" section header
- **TC-RENDER-V6-4**: `test_render_v6_preserves_is35_disclaimer_footer` — input V0=6 thesis; render output contains `_DISCLAIMER_MD` content (research aid / Calibration grade D / not financial advice)
- **TC-RENDER-V6-5**: `test_render_v6_recommendation_is_enum_not_prose` — input V0=6 thesis; render output contains "recommendation: investigate" or "watch" or "pass" or "thesis_candidate" (Recommendation enum value); MUST NOT contain "buy" or "sell" prose (I-S35 by-construction check)

**Optional additional tests**:
- **TC-RENDER-V6-6**: `test_render_v6_run_mode_dogfood_adds_metadata` — input V0=6 thesis + run_mode='dogfood'; render output contains `dogfood: true` frontmatter
- **TC-RENDER-V6-7**: `test_render_v6_run_mode_smoke_default_no_metadata` — input V0=6 thesis + run_mode='smoke' (default); render output does NOT contain `dogfood: true` frontmatter
- **TC-RENDER-V6-8**: `test_render_v3_backward_compat_still_works` — input N=3 thesis (existing pattern); render output contains BEAR/BULL/QUANT sections + does NOT contain BUFFETT/GRAHAM/TALEB sections (clean skip)

**Verification at end of D4**:
- mypy --strict CLEAN
- ruff CLEAN
- pytest test_validate_thesis.py: existing tests (≥30 per S382 1208 total) + ≥5 NEW = ≥35 total PASS
- full-project pytest scope (per L-S382-1 mandate): 1208+5 = 1213 total PASS; 0 regressions

**LOC delta**: ~80-100 LOC (5+ new tests × ~15-20 LOC + new fixtures for V0=6 thesis construction)

### D5 — ADR D-078 PROPOSED at IMPL tier (~150-200 LOC new ADR file)

**Target**: NEW `agent-workspace/memory/decisions/078-bc-8-v0-dogfood-cli-vhm.md`

**Content** (~150-200 LOC sections):
- **Frontmatter**: 12-field standard ADR schema (decision_id=D-078, status=PROPOSED, supersedes=[], superseded_by=[], related_to=[D-074, D-075, D-076, master plan-033, plan-037, plan-038], proposed_at=2026-05-17, ratified_at=null per IMPL-tier ADR auto-ratify on commit per severity-schema)
- **Context**: F.5 sub-plan ships first end-to-end Wave 1 product validation — live dogfood thesis on VHM via V0=6 personas through F.1+F.2+F.3 pipeline; establishes Phase F-prime DONE attestation that unlocks Wave 1 MVP
- **Decision**:
  1. CLI dogfood = EXTEND existing apps/cli/validate_thesis.py (DD-1) NOT new CLI file
  2. Dogfood ticker = VHM per architect-recommended (DD-2); alternates HPG/VIC/FPT pre-named
  3. Markdown renderer V0=6 extension = ADDITIVE 3 sections after existing 3 (DD-3); backward-compat preserved
  4. L-S382-1 ctor-signature-change discipline applied (DD-4); architect RECOMMENDS preserving existing inline-function pattern (NO new class) to avoid ctor risk
  5. V0 calibration baseline n=1; calibration_grade='D' default per Charter Principle 8 (DD-5)
  6. Dogfood output destination = agent-workspace/memory/thesis-log/ per existing CLI default (DD-6)
  7. Run-mode metadata = optional --run-mode flag (DD-7); dogfood mode adds 3 frontmatter fields
- **Consequences**:
  - + Validates F.1+F.2+F.3 pipeline end-to-end on real VHM data + real LLM substrate (dogfood)
  - + Establishes Phase F-prime DONE attestation (§ M ≥10 items)
  - + Establishes V0 calibration BASELINE (n=1; calibration_grade='D')
  - + Unlocks Wave 1 MVP gate (§ M)
  - - Single-ticker dogfood; multi-ticker batch deferred per § A.3 (Trigger named)
  - - No KOL / pump detection (Phase 3.5/4 per Charter)
  - - V0=9 expansion deferred per plan-037 NO-OP (Trigger A/B/C named in plan-037 § B)
- **Compliance attestation**: 0 charter / 0 constitution / production-behavior changes ADDITIVE (V0=6 markdown extension preserves backward-compat with N=3 path); D-060 ✓ (commit by dev; no push); D-074/D-075/D-076 IMPL-tier ADRs honored; master plan-033 § E.5 DoD floor satisfied; Phase F-prime DONE attestation per § M satisfied

**Verification at end of D5**:
- ADR file exists at correct path
- Frontmatter parses (12 fields per schema)
- Cross-references to D-074/D-075/D-076/master plan-033/plan-037/plan-038 valid
- Phase F-prime DONE attestation contract per § M referenced

**LOC delta**: ~150-200 LOC new file

### Sub-track sequencing summary (S384 IMPL ordering)

| D-N | Target | LOC delta | Verification gate | Estimated wall-min |
|---|---|---|---|---|
| D1 | validate_thesis.py | ~80-100 | mypy + ruff + existing tests pass | 10-15 |
| D2 | validate_thesis.py (additional) | ~20-30 | mypy + ruff + CLI help shows --run-mode | 5-8 |
| D3 | WALL-CLOCK EXECUTION (no code) | 0 (data) | thesis markdown + sqlite row produced | 3-7 (LLM latency) |
| D4 | test_validate_thesis.py | ~80-100 | pytest ≥35 + full-project scope ≥1213 | 15-20 |
| D5 | 078-*.md ADR | ~150-200 | manual file-exists + frontmatter parse | 5-10 |
| **TOTAL** | 3 files modified + 1 new + 1 execution | ~330-430 LOC code + ~200-400 LOC thesis data | All gates GREEN | **38-60 min** |

**Architect recommendation**: SEQUENTIAL D1 → D2 → D4 → D3 → D5 for safest ordering. Dev MUST NOT skip D4 (test additions) before D3 (live execution) — if D4 surfaces a renderer bug, dev fixes BEFORE wasting $1.50-2.50 live API budget on D3 dogfood run. D5 ADR can be written after D3 execution to include actual cost + actual outcome (SUBMITTED/INCOMPLETE) in ADR body.

---

## F. Definition of Done (sub-plan-level ≥25 items)

### PLAN-tier (S383 sandwich-architect THIS session)
- [ ] **DC-PLAN-1** — This plan file exists at `agent-workspace/session-plans/pending/038-S383-phase-f5-cli-dogfood-vhm-thesis.md` (~800-1100 LOC)
- [ ] **DC-PLAN-2** — Phase F-prime DONE attestation contract documented per § M ≥10 items
- [ ] **DC-PLAN-3** — STEP 0 BLOCKING gates ≥5 documented (0.1-0.5) per § C
- [ ] **DC-PLAN-4** — DD-1 through DD-7 documented with architect-VBW evidence chain
- [ ] **DC-PLAN-5** — Sub-track decomposition D1-D5 documented per § E
- [ ] **DC-PLAN-6** — Risk matrix RM1-RM7 documented per § I
- [ ] **DC-PLAN-7** — 5-source evidence chain documented per § H
- [ ] **DC-PLAN-8** — Coordination paths documented per § J
- [ ] **DC-PLAN-9** — Budget envelope documented per § K
- [ ] **DC-PLAN-10** — Phase 1b calibration n=3 precedent declared per § L
- [ ] **DC-PLAN-11** — L-S382-1 carry-forward MANDATORY applied per § DD-4 + § J RM6
- [ ] **DC-PLAN-12** — Shared observation file at `agent-workspace/memory/observations/sandwich-architect-S383-phase-f4-f5-plans.md` covers both plans (~200 LOC)

### IMPL-tier (S384 sandwich-dev FOCUSED_IMPL)
- [ ] **DC-IMPL-1** — D1 markdown renderer V0=6 extension shipped at validate_thesis.py:192-317; ~80-100 LOC delta; mypy + ruff CLEAN
- [ ] **DC-IMPL-2** — D2 --run-mode flag shipped at validate_thesis.py:56-96 click options + signature threading; ~20-30 LOC delta
- [ ] **DC-IMPL-3** — D4 test additions ≥5 NEW tests in test_validate_thesis.py; pytest ≥35 + full-project ≥1213 + ZERO regressions
- [ ] **DC-IMPL-4** — D3 live dogfood execution: thesis markdown written at agent-workspace/memory/thesis-log/2026-05-17-VHM.md (or alternate per STEP 0.2 outcome) + Thesis aggregate persisted to data/stockforge.sqlite + CLI exit 0 (SUBMITTED) OR legitimate exit 2 (INCOMPLETE per I-S10 bear-case insufficient on real VHM data; verifier captures as legitimate)
- [ ] **DC-IMPL-5** — D5 ADR D-078 PROPOSED at `agent-workspace/memory/decisions/078-bc-8-v0-dogfood-cli-vhm.md` ~150-200 LOC; 12-field frontmatter; cross-references valid
- [ ] **DC-IMPL-6** — Dogfood thesis markdown V0=6 sections present (BUFFETT/GRAHAM/TALEB) + I-S35 disclaimer footer preserved + Recommendation enum (NOT 'buy/sell' prose)
- [ ] **DC-IMPL-7** — Dogfood cost ≤ Decimal('3.00') per scoped_budget(limit_usd=Decimal('3.00')) at validate_thesis_phase1.py:189 HARD CAP enforced
- [ ] **DC-IMPL-8** — L-S382-1 MANDATORY: IF any ctor signature change introduced, grep-all-callers + full-project pytest scope re-run + commit message attests test count delta
- [ ] **DC-IMPL-9** — S384 dev observation at `agent-workspace/memory/observations/sandwich-dev-S384-phase-f5-cli-dogfood-impl.md` per template
- [ ] **DC-IMPL-10** — wc -l counts reported for all modified/new files per L-S345-1 honesty-promotion-at-n=3

### VERIFY-tier (S385 sandwich-verifier AP-1)
- [ ] **DC-VERIFY-1** — S385 verifier dispatch AP-1 fresh-context Opus ~30-60K VERIFY budget
- [ ] **DC-VERIFY-2** — Verifier inspects thesis markdown at agent-workspace/memory/thesis-log/2026-05-17-VHM.md: V0=6 sections present + I-S35 disclaimer + Recommendation enum (NOT 'buy/sell' prose) + dogfood: true frontmatter
- [ ] **DC-VERIFY-3** — Verifier inspects Thesis aggregate at data/stockforge.sqlite: status=SUBMITTED OR legitimate INCOMPLETE + cost_usd ≤ Decimal('3.00') + final_recommendation enum + confidence_level enum
- [ ] **DC-VERIFY-4** — Verifier inspects per-persona cost breakdown: total cost = sum(per-persona cost); per-persona cost reasonable (Sonnet personas ~$0.20-0.40; Opus QUANT ~$0.40-0.80); BUFFETT/GRAHAM/TALEB cost transparency
- [ ] **DC-VERIFY-5** — OPTIONAL: AC-5 reproducibility re-run: re-run dogfood once with identical inputs (--ticker VHM --as-of 2026-05-17); verify thesis_id identical (deterministic per AC-5 STABLE-SORTED-BY-ROLE)
- [ ] **DC-VERIFY-6** — Verifier inspects I-S10/I-S12/I-S35/AC-5 invariants empirically per § C STEP 0.5 charter-tier flag protocol; ZERO I-S1 NO-LLM-MATH violations (no 'approximately X%' / 'roughly X' / '~X%' prose in persona key_points)
- [ ] **DC-VERIFY-7** — Verifier produces Phase F-prime DONE attestation report per § M ≥10 items
- [ ] **DC-VERIFY-8** — Verifier observation at `agent-workspace/memory/observations/sandwich-verifier-S385-phase-f5-cli-dogfood-verify.md` per template

### Close-bookkeeping-tier (S386)
- [ ] **DC-CLOSE-1** — Plan-038 moved `pending/` → `completed/` per DC-BOOK-4 protocol
- [ ] **DC-CLOSE-2** — Plan-037 (F.4 NO-OP) ALSO moved `pending/` → `completed/` per parallel-eligible bundled-close pattern
- [ ] **DC-CLOSE-3** — current-execution.md updated with S383-S386 row + Phase F-prime DONE marker + Wave 1 MVP gate cleared
- [ ] **DC-CLOSE-4** — latest.md updated as S386 CLOSE handoff (Phase F-prime DONE; next master-plan beat = Phase G-prime)
- [ ] **DC-CLOSE-5** — mistake-log.md digest +0 or +N new entries per mistake catalog
- [ ] **DC-CLOSE-6** — agent-notes.md digest +0 or +N new learned rules per L-S<N>-<M> entries
- [ ] **DC-CLOSE-7** — Phase F-prime DONE attestation evidence collected + cross-referenced in ADR D-078 + observation files

---

## G. AQ-1 through AQ-10 (anticipated questions)

### AQ-1 — Why dogfood VHM and not HPG/VIC/FPT?

**Answer**: Per master plan DD-11 architect recommendation. VHM = VinGroup conglomerate moat discussion (already in buffett.json vietnam_notes); VN30 blue-chip (avoids delisted-company data gap); real-estate sector (rich news corpus from CafeF/NDH/Vietstock/VietnamBiz Phase E.2 lexicon dogfood); project-owner-familiar. HPG/VIC/FPT are PRE-NAMED fallbacks per STEP 0.2 STOP-AND-ASK option (b) if VHM data gap surfaces.

### AQ-2 — Why extend existing CLI vs new file?

**Answer**: Per DD-1. validate_thesis.py is V0=6-ready post-F.3 SHIP; master plan AQ-7 explicitly named the existing CLI as substrate; Karpathy P2 simplicity-first; new CLI would duplicate 90% of click + markdown logic.

### AQ-3 — What happens if VHM dogfood returns INCOMPLETE (bear case insufficient)?

**Answer**: LEGITIMATE outcome per I-S10 by-construction enforcement. Verifier S385 captures as legitimate; Phase F-prime DONE attestation per § M still achievable (V0 pipeline validated end-to-end even if I-S10 not satisfied this single run). The thesis markdown documents the INCOMPLETE outcome with `gaps: ["bear_case_invariant_failed"]` per validate_thesis.py:177; this IS the system working correctly per Charter Principle 6 (adversarial by default).

### AQ-4 — What happens if dogfood cost exceeds Decimal('3.00')?

**Answer**: Per validate_thesis_phase1.py:189 scoped_budget HARD CAP, CostBudgetExceeded raised; use case returns Thesis.incomplete(gaps=['cost_budget_exceeded']); CLI exits 1. STEP 0.4 should have caught this; if it didn't, dev STOP-AND-ASKs project owner per § C STEP 0.4 options.

### AQ-5 — Does F.5 need an ANTHROPIC_API_KEY?

**Answer**: NO. F.5 uses --transport=subagent (claude CLI subscription substrate) per use_case_builder.py:179-225 wiring. ANTHROPIC_API_KEY path is BLOCKED per BuildError at use_case_builder.py:239-246 (S43a-DOGFOOD gate). claude CLI uses parent Claude Code OAuth subscription per S375 close-bookkeeping VBW (v2.1.140 at C:/Users/PC/.local/bin/claude.exe confirmed alive).

### AQ-6 — What if claude CLI hangs or times out?

**Answer**: Per S43b-BULL fix at use_case_builder.py:217 (BULL→haiku-4-5 to avoid 300s CLI timeout deterministic hang). Per ADR D-051/D-052 subagent_transport has timeout handling; per per-agent retry-validator (D-054 B5; 3 attempts). If hang/timeout persists, dev STOP-AND-ASKs project owner with options: (a) downgrade additional personas to Haiku, (b) retry with smaller corpus, (c) defer F.5 IMPL pending CLI investigation.

### AQ-7 — Why is calibration_grade='D' default for V0?

**Answer**: Per Charter Principle 8 (calibration-over-confidence) + spec 006: calibration_grade A-B-C requires ≥50 thesis outcomes per persona across 3+ months wall-clock; n=1 dogfood is BASELINE; 'D' = "Phase 2 — no calibration data yet, BR-7" per validate_thesis.py:52 disclaimer. Post-MVP calibration mature via outcomes feedback loop (out-of-scope; Phase 3+ work per master plan § A.3 row 2).

### AQ-8 — What if dogfood persona emits 'buy/sell' prose or numeric prose?

**Answer**: Per § C STEP 0.5 CHARTER-TIER FLAG protocol. (a) 'buy/sell' prose = I-S35 violation surface → MANDATORY STOP-AND-ASK + main session fires AskUserQuestion ratification gate per master plan § K.1.c options; (b) numeric prose like 'approximately 15%' = I-S1 NO-LLM-MATH violation surface → MANDATORY STOP-AND-ASK + master plan § K.2 protocol. Verifier S385 grep-confirms ZERO of these in dogfood output as part of DC-VERIFY-6.

### AQ-9 — What if Phase F-prime DONE attestation fails (S385 PASS-WITH-CONCERNS)?

**Answer**: PASS-WITH-CONCERNS is acceptable outcome per S378/S381/S382 precedent — main session applies inline F1/F2 remediation per verifier mandate (NOT self-review per AP-1; applying-per-verifier-mandate is the authorized pattern). Phase F-prime DONE attestation per § M lists ≥10 attestation criteria; if any FAIL → main session decides between (a) inline remediation in same turn, (b) F.5-V2 follow-up sub-plan, (c) Wave 1 MVP gate held until remediation lands. PASS = Phase F-prime DONE → Wave 1 MVP ready.

### AQ-10 — When does Phase G-prime start?

**Answer**: After S386 close-bookkeeping marks Phase F-prime DONE + Wave 1 MVP gate cleared per § M attestation. Phase G-prime = next master-plan beat per master plan-033 § 6 (Theme G charter amendment was DONE 2026-05-16; Phase G-prime in master plan § 6 refers to next charter-tier work — see master plan § 6 for exact Phase G-prime scope; out-of-scope for THIS plan).

---

## H. 5-source evidence chain (F.5 architect decisions)

1. **Master plan-033 § E.5** (parent plan): `5. Sub-track F.5 — CLI smoke + dogfood thesis on one VN ticker (target: NEW apps/cli/synthesize_vn_thesis.py CLI; dogfood run on one project-owner-picked VN30 ticker — VHM or VIC or HPG — to capture per-persona output + aggregate Recommendation + cost-tracking + AC-5 reproducibility check)` — F.5 SCOPE; architect RE-INTERPRETED 'NEW apps/cli/synthesize_vn_thesis.py' as 'EXTEND existing apps/cli/validate_thesis.py' per DD-1 + master plan AQ-7 reference to existing CLI

2. **Master plan-033 DD-11** (`F.5 CLI dogfood ticker = project-owner-pick (architect recommends VHM)`): full architect rationale for VHM choice; HPG/VIC/FPT alternates pre-named; NON-BLOCKING design (project owner can override at STEP 0.2 WITHOUT Q-INT)

3. **Master plan-033 § K.1.c + § K.2** (CHARTER-TIER FLAG protocols): K.1.c references VHM dogfood per-persona Recommendation drift to 'buy/sell' prose → I-S35 violation MANDATORY FLAG; § K.2 references VHM dogfood per-persona confidence_level '0.85' prose → I-S1-1 violation MANDATORY FLAG; STEP 0.5 protocol per § C

4. **F.3 SHIPPED ARTIFACTS** (per current-execution.md S381 close-bookkeeping + S382 verifier remediation): dict[PerspectiveRole, LLMPerspectivePort] generalization at validate_thesis_phase1.py:158-172 PROVED N-persona path works; apps/_shared/use_case_builder.py:179-225 V0=6 wiring SHIPPED; 1208 tests; **L-S382-1 PROMOTE-NOW carry-forward**: ctor-signature-change discipline gap (M-S381-1 + M-S381-2 + L-S382-1+L-S382-2 HOLD per mistake-log.md + agent-notes.md L-S360-cluster)

5. **VBW empirical reads** (this session, S383): apps/cli/validate_thesis.py 1-340 LOC structure confirmed (Read tool); apps/_shared/use_case_builder.py 1-380 LOC structure confirmed (Read tool); packages/application/analysis/use_cases/validate_thesis_phase1.py 1-300 LOC structure confirmed (Read tool); agent-workspace/role-packs/{buffett,graham,taleb}.json existence confirmed (Glob tool); claude CLI v2.1.140 confirmed alive per S375 close-bookkeeping

---

## I. Risk Matrix (RM1-RM7)

### RM1 — VHM data corpus stale (LIKELY-MEDIUM)

**Risk**: F.5 wall-clock dogfood on VHM surfaces insufficient recent VHM news (last refresh date unknown at S383 architect-tier).

**Mitigation**: STEP 0.2 BLOCKING gate verifies VHM data corpus presence (≥30 bars + ≥1 statement + ≥5 news); if any gap, STEP 0.2 STOP-AND-ASK fires with options per master plan AQ-9: (a) corpus refresh via existing adapter CLIs (~10-15 min wall-clock per source), (b) switch to alternate ticker (HPG/VIC/FPT pre-named), (c) defer F.5 IMPL.

### RM2 — Dogfood cost exceeds Decimal('3.00') HARD CAP (LIKELY-LOW)

**Risk**: 6 personas × per-persona cost exceeds $3.00 due to per-call Opus pricing on BUFFETT/GRAHAM/TALEB (defaults to Opus per F.3 plan-036 DD-9 deferral of _ROLE_TO_MODEL extension).

**Mitigation**: STEP 0.4 BLOCKING gate verifies expected cost ≤ $2.50; if higher, options: (a) tighten budget cap inline, (b) downgrade BUFFETT/GRAHAM/TALEB to Sonnet via role_model_overrides at use_case_builder.py:217, (c) proceed with default (recommended). HARD CAP at validate_thesis_phase1.py:189 prevents overshoot regardless.

### RM3 — Dogfood persona emits 'buy/sell' prose (LIKELY-LOW)

**Risk**: One of 6 personas emits Recommendation prose like 'buy' or 'sell' (NOT Recommendation enum) violating I-S35 framing.

**Mitigation**: I-S35 by-construction enforced via Recommendation enum at packages/domain/analysis/recommendation.py (per existing pattern); per-persona system_prompt at agent-workspace/role-packs/*.json explicitly says "thesis exploration -- not buy/sell recommendation" + "Frame all conclusions as considerations, not predictions"; STEP 0.5 CHARTER-TIER FLAG protocol catches if surfaced. Empirical mitigation: F.5 verifier S385 inspects thesis markdown for 'buy'/'sell' prose tokens.

### RM4 — Dogfood persona emits numeric prose (I-S1 NO-LLM-MATH violation) (LIKELY-LOW)

**Risk**: One of 6 personas emits numeric prose like "approximately 15%" or "roughly 8" violating I-S1 NO-LLM-MATH.

**Mitigation**: Per-persona system_prompt at agent-workspace/role-packs/*.json explicitly says "NO LLM MATH. You NEVER produce a numeric value in your prose. If you need a ratio, percentage, growth rate, or any number -- cite the deterministic tool output verbatim." Forbidden phrasings enumerated. STEP 0.5 CHARTER-TIER FLAG protocol catches if surfaced. Empirical mitigation: F.5 verifier S385 grep-confirms ZERO 'approximately'/'roughly'/'~'/'about' tokens in persona key_points.

### RM5 — claude CLI timeout on dogfood persona call (LIKELY-MEDIUM)

**Risk**: BUFFETT/GRAHAM/TALEB persona LLM call exceeds 300s CLI timeout (per S43b-BULL fix precedent at use_case_builder.py:217 documenting deterministic 300s hang on BULL Sonnet call).

**Mitigation**: Per-agent retry-validator (D-054 B5; 3 attempts) handles transient failure. If persistent hang, dev STOP-AND-ASKs per AQ-6 options. As BACKUP: pre-emptive downgrade of BUFFETT/GRAHAM/TALEB to Haiku via role_model_overrides at STEP 0.4 STOP-AND-ASK option (b).

### RM6 — L-S382-1 ctor-signature-change discipline gap recurs (LIKELY-LOW; carry-forward)

**Risk**: F.5 dev introduces NEW class with public ctor (e.g. MarkdownRendererV6) without grep-all-callers + full-project pytest scope re-run; recreates M-S381-1 slip pattern.

**Mitigation**: Per § DD-4 MANDATORY application; architect RECOMMENDS preserving existing inline-function pattern at validate_thesis.py:192-317 (NO new class) to avoid ctor risk by-construction; if dev departs from architect recommendation, MUST grep + full-project pytest. § F DC-IMPL-8 verifier-tier check.

### RM7 — Phase F-prime DONE attestation evidence incomplete (LIKELY-LOW)

**Risk**: S385 verifier discovers Phase F-prime DONE attestation per § M ≥10 items has any gap (e.g. AC-5 reproducibility re-run optional skipped + cost budget tight).

**Mitigation**: § M attestation contract clearly distinguishes BLOCKING vs OPTIONAL items; verifier S385 captures gaps; main session decides between (a) inline remediation, (b) F.5-V2 sub-plan, (c) Wave 1 MVP gate held. PASS-WITH-CONCERNS is acceptable outcome per AQ-9 + S378/S381/S382 precedent.

---

## J. Coordination paths

**Coordination paths exclusive (S384 dev session)**:
- `apps/cli/validate_thesis.py` (EXTEND D1+D2)
- `apps/cli/test_validate_thesis.py` (EXTEND D4)
- `agent-workspace/memory/decisions/078-bc-8-v0-dogfood-cli-vhm.md` (NEW D5)
- `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` (NEW D3 wall-clock output; or alternate per STEP 0.2)
- `data/stockforge.sqlite` (NEW row D3 wall-clock; Thesis aggregate persisted via SqliteThesisRepository)
- `agent-workspace/memory/observations/sandwich-dev-S384-phase-f5-cli-dogfood-impl.md` (NEW dev observation)

**Main session avoids these paths during S384 IMPL** (per coordination_paths_exclusive declaration).

**Coordination paths SHARED (verifier-readable)**:
- All F.5 artifacts above (verifier S385 needs read access for V0=6 section inspection + thesis aggregate inspection + cost breakdown + AC-5 reproducibility re-run)

---

## K. Budget (FOCUSED_IMPL-Opus 100-150K per recalibrated CLAUDE.md)

**Authoring envelope THIS session (S383 architect)**: ~150-230K Opus PLAN (combined with plan-037 NO-OP per single dispatch per dispatch brief). This plan-038 portion ≈ 130-180K of authoring budget.

**IMPL envelope (S384 sandwich-dev)**: 100-150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md PLAN-Opus table. Single session preferred; includes wall-clock dogfood run wait time per persona LLM call (~3-7 min ambient LLM latency; dev session keeps context alive).

**VERIFY envelope (S385 sandwich-verifier)**: 30-60K Opus AP-1 fresh-context per recalibrated CLAUDE.md VERIFY-Opus table.

**Combined Phase F-prime DONE budget**: F.5 IMPL+VERIFY ~130-210K + F.4 NO-OP ~20K = ~150-230K to close Phase F-prime.

**Live API budget**: Decimal('3.00') HARD CAP per validate_thesis_phase1.py:189 scoped_budget; expected actual cost ~$1.50-2.50 per dogfood run (Sonnet 5 personas × ~$0.20-0.40/call + Opus QUANT × ~$0.40-0.80/call).

---

## L. Phase 1b Calibration (n=3 multi-perspective-impl precedent declared)

**task_class**: multi-perspective-impl (sandwich-dev declaring IMPL for multi-perspective expansion work; S384 IMPL inherits this task_class)

**Phase 1b precedent**: n=3 (per dispatch brief constraint "Phase 1b MANDATORY")

**Precedent observations** (multi-perspective-impl class):
1. **S375 (F.1 IMPL)** — sandwich-dev Sonnet authored RolePromptPack + PersonaRegistry + BC-8 transport-flip; D-052 § Implementation step 1 CLOSED for BC-8; 23+14 tests; 1153 total; CLEAN PASS at S376 verifier
2. **S378 (F.2 IMPL)** — sandwich-dev Sonnet authored 3 persona adapters (BUFFETT/GRAHAM/TALEB) + 3 JSON role-packs + 15+ tests; 1190 total; PASS-WITH-CONCERNS at S378 verifier (F2 BSD-3-Clause copyright header drift inline-remediated)
3. **S381 (F.3 IMPL)** — sandwich-dev Sonnet authored dict[PerspectiveRole, LLMPerspectivePort] generalization + Phase1Synthesizer N-persona extension + composition root V0=6 wiring + 18+ tests; 1210 collected; **M-S381-1 + M-S381-2 inline-remediated by main per L-S382-1 PROMOTE-NOW HIGH** (ctor-signature-change discipline gap; 4 pytest + 4 mypy failures → 1208 passed post-fix)

**S384 (F.5 IMPL) — TARGET session**: 4th instance multi-perspective-impl; n=3 precedent SATISFIED; calibration band ~100-150K FOCUSED_IMPL Opus per recalibrated CLAUDE.md.

**Empirical confidence**: HIGH for D1+D2+D4+D5 (mature pattern from F.1+F.2+F.3); MEDIUM for D3 wall-clock dogfood (first live LLM substrate exercise of V0=6 pipeline; unknown empirical cost + unknown empirical retry rate + unknown empirical persona output quality variability). RM1-RM7 covers known risks.

**L-S382-1 carry-forward HIGH PROMOTE-NOW**: F.5 dev MUST apply ctor-signature-change discipline (per § DD-4 + § J RM6 + § F DC-IMPL-8). Architect recommends NO new class to avoid risk by-construction.

**Phase 1b artifact** (per plan-025 DD-11 mandate): this § L declaration captures n=3 multi-perspective-impl precedent satisfied; plan-037 § L shares the same n=3 declaration.

---

## M. Phase F-prime DONE attestation contract (≥10 items)

**This is the LAST sub-plan of Phase F-prime; § M defines what "Wave 1 MVP ready" means.**

Phase F-prime is DONE when ALL of the following attestation items are satisfied (verified by S385 verifier; reported in S385 observation; main session updates current-execution.md + latest.md at S386 close):

### Attestation items (BLOCKING for Phase F-prime DONE)

- [ ] **PFP-DONE-1 (Substrate)** — F.1 SHIPPED + VERIFIED (RolePromptPack frozen dataclass at packages/application/analysis/role_prompt_pack.py:33-103 + PersonaRegistry at packages/application/analysis/persona_registry.py:39-156 + BC-8 transport-flip default to claude_cli_transport per claude_llm_perspective_adapter.py); ADR D-074 PROPOSED+ACCEPTED
- [ ] **PFP-DONE-2 (Personas)** — F.2 SHIPPED + VERIFIED (3 persona adapters at packages/infrastructure/analysis/perspectives/{buffett,graham,taleb}_agent.py + 3 V0 JSON role-packs at agent-workspace/role-packs/{buffett,graham,taleb}.json + PerspectiveRole +3 BUFFETT/GRAHAM/TALEB); ADR D-075 PROPOSED+ACCEPTED
- [ ] **PFP-DONE-3 (N-perspective dispatch)** — F.3 SHIPPED + VERIFIED (dict[PerspectiveRole, LLMPerspectivePort] generalization at validate_thesis_phase1.py:158-172 + Phase1Synthesizer N-persona extension + composition root V0=6 wiring at use_case_builder.py:179-225 + 1208 tests + F1+F3 inline-remediated per S382); ADR D-076 PROPOSED+ACCEPTED
- [ ] **PFP-DONE-4 (V0=6 ratification)** — V0=6 default applies per plan-037 NO-OP (per master plan DD-2 + AQ-8); V0=9 expansion deferred per plan-037 § B Trigger A/B/C named (per AP-7 anti-vacuous-defer)
- [ ] **PFP-DONE-5 (CLI dogfood end-to-end)** — F.5 SHIPPED + VERIFIED per THIS plan (D1+D2+D3+D4+D5 all PASS per § F DC-IMPL-1 through DC-IMPL-10); ADR D-078 PROPOSED
- [ ] **PFP-DONE-6 (Dogfood thesis artifact)** — `agent-workspace/memory/thesis-log/2026-05-17-VHM.md` exists with V0=6 sections + I-S35 disclaimer + Recommendation enum (NOT 'buy/sell' prose) + dogfood: true frontmatter (per § F DC-VERIFY-2)
- [ ] **PFP-DONE-7 (Thesis aggregate persisted)** — `data/stockforge.sqlite` contains Thesis aggregate row with status=SUBMITTED OR legitimate INCOMPLETE (per AQ-3) + cost_usd ≤ Decimal('3.00') + final_recommendation enum + confidence_level enum (per § F DC-VERIFY-3)
- [ ] **PFP-DONE-8 (Invariants empirically validated)** — I-S1 (NO LLM math: ZERO numeric prose in persona key_points) + I-S10 (bear case present + ≥3 distinct points OR legitimate INCOMPLETE) + I-S12 (disagreement preserved if surfaced) + I-S35 (research-aid framing; Recommendation enum) all empirically validated by S385 verifier (per § F DC-VERIFY-6)
- [ ] **PFP-DONE-9 (V0 calibration baseline)** — n=1 dogfood baseline established; calibration_grade='D' default per Charter Principle 8; n≥50 post-MVP calibration trigger named in ADR D-078 (per § DD-5)
- [ ] **PFP-DONE-10 (Phase F-prime closure bookkeeping)** — Plan-037 + Plan-038 both moved `pending/` → `completed/` per DC-CLOSE-1+DC-CLOSE-2; current-execution.md updated with Phase F-prime DONE marker; latest.md updated as S386 CLOSE handoff; Wave 1 MVP gate cleared (per § F DC-CLOSE-3+DC-CLOSE-4)

### Attestation items (OPTIONAL; nice-to-have)

- [ ] **PFP-DONE-O1 (AC-5 reproducibility re-run)** — Verifier S385 re-runs dogfood once with identical inputs; thesis_id identical (per § F DC-VERIFY-5; budget-permitting)
- [ ] **PFP-DONE-O2 (Per-persona cost breakdown)** — Verifier S385 captures per-persona cost breakdown for ADR D-078 evidence + future F.4-V2 budget tuning input (per § F DC-VERIFY-4)
- [ ] **PFP-DONE-O3 (Persona output quality observations)** — Verifier S385 captures qualitative observations on each persona's output quality (richness, Vietnam-relevance, evidence specificity) for plan-037 § B Trigger C empirical evidence chain

### Wave 1 MVP gate definition

**Wave 1 MVP is READY when ALL 10 BLOCKING attestation items above are PASS.** This unlocks:
- Phase G-prime entry per master plan-033 § 6 (next master-plan beat)
- Production dogfood loop (additional thesis runs on additional tickers per project-owner decision)
- Calibration outcomes feedback loop initialization (post-MVP per Charter Principle 8)

**Wave 1 MVP NOT ready** if any BLOCKING item FAIL → main session decides between (a) inline remediation in same turn, (b) F.5-V2 follow-up sub-plan, (c) Phase F-prime hold until remediation lands. Per AQ-9 PASS-WITH-CONCERNS is acceptable as long as ≥10 BLOCKING items eventually clear.

---

**End of plan-038 (F.5 CLI dogfood VHM thesis)**.

Approx LOC: ~1000 (within 800-1100 budget per dispatch brief).
