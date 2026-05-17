---
observation_id: sandwich-architect-S398-g3-claude-vision-adapter
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md
target_session: S399 (sandwich-dev FOCUSED_IMPL executing D1-D5; S396 in-flight per current-execution.md:139 for plan-045 continuation + BR-6 cap fix + ADR D-081; ZERO file scope overlap)
verifier_session: S400 sandwich-verifier AP-1 (fresh-context post-S399 dev close)
phase_milestone: G.3 Claude vision adapter + EchoValidator Rule 16 mode #2 gate — THIRD sub-plan of Phase G-prime master plan-040 (per § E.3 + § N.2 sequencing; PARALLEL-ELIGIBLE with G.2 sub-plan 042 — disjoint adapter files; G.2 BLOCKED on RM3 STOP-FINDING-S394 real-PDF)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START DECLARED for task_class="pdf-claude-vision-adapter-plan"; nearest analogs pdf-extraction-plan n=1 (S392 plan-041 ~170K Opus PLAN) + multi-perspective-impl-plan n=1 (S374 plan-034 ~140K Opus PLAN) + bc-8-transport-flip-plan n=1 (S374 plan-034 ~140K Opus PLAN); novel sub-components = vision-input-modality probe protocol + EchoValidator runtime invariant authoring + per-call cost ceiling design + tests/unit/ directory convention
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; third of 4 sub-plans per parent plan-040 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN; sub-plan 043 satisfies its § E.3 contract per DD-1 claude_cli_transport substrate + DD-2 vision-input shape STEP-0.4-cold-probe + DD-3 EchoValidator location + DD-4 Rule 16 mode #2 tolerance=0 + DD-5 K.2.b fallback path + DD-6 per-call cost ceiling + DD-7 ADR D-082 + DD-8 zero-pyproject-dep + DD-9 tests/unit/ convention)
predecessor_sub_plans: [041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md (G.1 SHIPPED at S394 + VERIFIED PASS at S397; D-080 ACCEPTED — ABC contract + ExtractedFinancialStatement + PdfSource available for subclassing)]
related_adrs: [D-080 ACCEPTED (PdfTableExtractorPort ABC at packages/application/fundamental/pdf_table_extractor_port.py:93-185; BINDING G.3 subclass contract), D-072 ACCEPTED (BC-5 claude_cli_transport precedent at S375 — same substrate G.3 reuses), D-074 PROPOSED (BC-8 RolePromptPack Foundation at S378 — same transport-flip pattern G.3 mirrors), D-050 CHARTER (anthropic_api_to_subagent memory rule MANDATORY — DD-1 ZERO-anthropic-SDK binding), D-065 (Rule 16 numeric-field discipline ACCEPTED 2026-05-16; BINDING for G.3 EchoValidator runtime invariant via mode #2 deterministic-pipeline echo), D-059 (Python determinism — R1 datetime-tz BINDING for extracted_at on ExtractedFinancialStatement assembly), D-064 (path-safety 5-invariant — BINDING for per-page image cache IF Resolution A path chosen), D-082 PROPOSED-AT-IMPL via this plan D5]
---

# S398 sandwich-architect — Phase G.3 ClaudeVisionPdfTableExtractor + EchoValidator sub-plan-043 authoring observation

## What was authored

Sub-plan 043 at `agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md` (single physical file; LOC 1051 per wc -l close-loop verification per L-S397-3; +45% over plan-041 ~720 LOC envelope due to (a) 9 DDs vs plan-041 8 DDs adding DD-9 test path convention, (b) DD-2 vision-input shape conditional resolution paths require A/B/C/D enumeration depth, (c) DD-5 fallback path with 3 sub-options menu, (d) DD-6 per-call cost ceiling design depth + cost-estimate arithmetic, (e) ADR D-082 detail expansion across 12-field schema). FOCUSED_IMPL sub-plan for Phase G-prime sub-theme G.3 — THIRD sub-plan of Phase G-prime per master plan-040 § N.2 (PARALLEL-ELIGIBLE with G.2 sub-plan 042; G.2 BLOCKED on RM3). Decomposed into 5 sub-tracks D1-D5:

- D1 ClaudeVisionPdfTableExtractor adapter at `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW file in existing directory; ~250 LOC core code; subclass PdfTableExtractorPort + 4 method implementations + ctor with cost_ceiling_usd + claude_cli_transport invocation + EchoValidator.validate per cell)
- D2 EchoValidator at `packages/application/fundamental/echo_validator.py` (NEW ~80 LOC core code; single classmethod validate() + canonical-form coercion + EchoValidationError HARD ERROR per Rule 16 mode #2)
- D3 STEP 0.X vision-input feasibility cold-probe (per L-S395-1 full-pipeline cold-probe; 3-probe sequence + minimal-PDF round-trip; ~30-40 min wall-time DOMINANT; if K.2.b fires → STOP-FINDING per L-S397-2 severity vocabulary CHARTER-TIER-SURFACE)
- D4 Unit tests at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW ~150-200 LOC ≥15 tests) + `tests/unit/application/fundamental/test_echo_validator.py` (NEW ~100-150 LOC ≥10 tests) — NEW directory convention per DD-9
- D5 ADR D-082 PROPOSED at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (NEW ~180 LOC; 12-field schema floor per L-S389-2; records adapter contract + EchoValidator semantics + Rule 16 mode #2 satisfaction proof + STEP 0.4 vision-input shape resolution + per-call cost ceiling + K.2.b resolution IF fired)

**Plan stats** (architect-internal; exact wc -l per L-S389-1):
- Total LOC: 1051 (single physical file; +45% over plan-041 ~720 LOC envelope due to 9 DDs vs 8 + DD-2/DD-5/DD-6 depth + ADR detail expansion)
- 9 DD architecture decisions (DD-1..DD-9) all pre-answered with rationale + adversarial alternates explicitly rejected (Karpathy P1 think-before-coding)
- 5 sub-tracks D1-D5 in § E with DoD criteria + LOC ceiling per-category (L-S397-1) + dependency graph + parallel-eligibility
- 34+ DoD criteria across § E + § G (≥25 floor satisfied; D1=10 + D2=7 + D3=5 + D4=6 + D5=6 = 34)
- 5 RM entries (RM1..RM5) with mitigation including RM1 K.2.b CHARTER-TIER FLAG empirical-probe-first mitigation
- 5-source-evidence chain per major DD (DD-1 cites anthropic_api_to_subagent + D-072 + D-074 + subagent_transport.py:144-222 + claude_llm_perspective_adapter.py:5-8)
- STEP 0.4 STOP-AND-ASK trigger inventory carry-forward to S399 (K.2.b CONDITIONAL per parent plan-040 § K.2.b inheritance + DD-5 fallback path)
- § K coordination paths off-limits during S399 IMPL (explicit BINDING file scope + S396 in-flight OFF-LIMITS list per dispatch brief)
- § L 6 promotion candidates (PCG-1..6 — EchoValidator + cold-probe protocol + per-call cost-ledger + tests/unit convention + Rule 16 satisfaction proof pattern + CHARTER-TIER-SURFACE STOP-FINDING vocabulary)
- § N sequencing table covering S391-TBD (Phase G-prime full ship; sub-plan 044 G.4 BLOCKS on G.2 042 ratification per parent plan-040 § E.4)
- § P compliance attestation grid (40+ rows — all hard rules + memory rules + lessons + anthropic_api_to_subagent MANDATORY + dispatch brief OFF-LIMITS acknowledgment)

## Key architectural decisions (DD-1..DD-9 summary)

| DD | Decision | Pre-decided or ARCHITECT-REFINEMENT? |
|---|---|---|
| **DD-1** | **claude_cli_transport substrate MANDATORY (per anthropic_api_to_subagent memory rule); ZERO `import anthropic`** | PRE-DECIDED per memory rule + D-050 CHARTER + dispatch brief explicit; binding ZERO-anthropic-SDK discipline; verifier grep-asserts at V3 |
| **DD-2** | **Vision-input shape CONDITIONAL on STEP 0.4 cold-probe outcome (Resolution A/B/C/D)** | **ARCHITECT REFINEMENT** per VBW finding — current claude_cli_transport signature has NO file/image parameter (STEP 0.1.a finding); PLAN cannot pre-commit; cold-probe is empirical answer per L-S395-1 full-pipeline cold-probe doctrine |
| **DD-3** | **EchoValidator at packages/application/fundamental/echo_validator.py (same package as ABC; NOT cross-BC _shared/)** | PRE-DECIDED per parent plan-040 § E.3 D3 verbatim; AP-23 1st-instance HOLD; cross-BC promotion deferred per 2nd-BC reuse trigger |
| **DD-4** | **Rule 16 mode #2 strictness = cell-by-cell echo with tolerance=0 exact-match on Decimal + canonical-form coercion** | **ARCHITECT REFINEMENT** per dispatch brief § H RM3 ("tolerance design") — chose tolerance=0 (not tolerance-band) because financial-data-protocol.md:401 verbatim "Mismatch is a HARD ERROR ... never silently coerce"; canonical-form coercion handles whitespace/parens/Vietnamese-locale thousand-separator/Triệu-Tỷ-đồng (NOT a tolerance) |
| **DD-5** | **Fallback path if vision-input infeasible = 3-option menu (PIVOT-to-base64 / DEFER-G.3 / CHARTER-amend); STOP-FINDING uses L-S397-2 CHARTER-TIER-SURFACE vocabulary** | **ARCHITECT REFINEMENT** per dispatch brief § D DD-5 guidance — pre-authored 3 fallback options vs single fallback; uses L-S397-2 severity-schema vocabulary (NOT ad-hoc IMPLEMENTATION-BLOCKER per S397 F4 finding) |
| **DD-6** | **Per-call cost ceiling Decimal("0.50") USD default configurable via ctor** | **ARCHITECT-NEW** per dispatch brief § H RM4 mandate; novel pattern at adapter-tier (existing CostBudgetExceeded is use-case-tier at validate_thesis_phase1.py:189; G.3 adapter-tier ceiling is orthogonal); cost-estimate arithmetic ~$0.05-0.15 per call × ~3-10 calls/extract = $0.30-0.50 typical extract cost |
| **DD-7** | **ADR D-082 PROPOSED-AT-IMPL records 9 sections (a-l) + 12-field schema floor per L-S389-2** | PRE-DECIDED per parent plan-040 DD-8 + L-S389-2 promote candidate from S389 + dispatch brief mandate "ADR D-082 PROPOSED" |
| **DD-8** | **ZERO pyproject.toml dep addition THIS sub-plan; claude CLI is system-installed; pdfplumber dep DEFERRED to G.2 ratification authority** | PRE-DECIDED per parent plan-040 § E.3 explicit "NO new external dep — uses existing claude CLI substrate" + D-061 add-with-rationale doctrine + G.2 ratification authority |
| **DD-9** | **Test path convention = tests/unit/infrastructure/fundamental/ + tests/unit/application/fundamental/ (NEW directory tree)** | **ARCHITECT-NEW** per dispatch brief § F explicit; coordination check at STEP 0.5.b (existing convention = tests-alongside-code per packages/application/fundamental/test_*.py); L-S392-1 dispatch-brief precedence; AP-23 1st-instance HOLD (if 2nd sub-plan adopts → promote; else retire) |

**Top 3 design decisions** (most architect-leverage):

1. **DD-2 vision-input shape CONDITIONAL on STEP 0.4 cold-probe**: THE critical empirical gate; current claude_cli_transport at subagent_transport.py:144 has signature `(model, system_prompt, user_message, temperature, role=None)` with ZERO file/image parameter — PLAN cannot pre-commit to Resolution A (--input-file) vs B (@-syntax) vs C (base64-MIME stdin) vs D (no vision substrate); STEP 0.4 cold-probe surfaces architectural blocker EMPIRICALLY per L-S395-1 full-pipeline cold-probe doctrine BEFORE bulk D1 implementation; if probe fires K.2.b → DD-5 fallback path activates with 3 pre-authored options menu
2. **DD-4 Rule 16 mode #2 tolerance=0 + canonical-form coercion (NOT tolerance-band)**: financial-data-protocol.md:401-402 verbatim "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"; tolerance-band would silently coerce within band — semantic violation of charter; cell-by-cell granularity preserves diagnostic information (which specific cell failed); canonical-form coercion (whitespace + parens-negative + Vietnamese "." OR US "," thousand-separator + Triệu/Tỷ-đồng unit suffixes per RM-G-4 parent plan-040) is BIJECTION on underlying numeric value (NOT a tolerance — a coercion)
3. **DD-1 anthropic_api_to_subagent MANDATORY (ZERO anthropic SDK)**: D-050 CHARTER memory rule binding; G.3 adapter MUST use existing claude_cli_transport at subagent_transport.py:144-222 (proven substrate at D-072 BC-5 + D-074 BC-8 transport-flip precedents; subscription billing); verifier at S400 V3 charter compliance re-runs `Grep "import anthropic" packages/infrastructure/fundamental/` MUST return 0 matches in G.3 directory; if STEP 0.4 cold-probe reveals NO vision substrate → DD-5 fallback Option (c) CHARTER amend memory rule scope is the only path to direct anthropic SDK use (requires user gate)

## K.2.b CHARTER-TIER FLAG status

**Status at PLAN authoring**: NOT-TRIGGERED at S398 PLAN-tier (PLAN session has no charter/scope question; cold-probe execution is S399 IMPL responsibility).

**Carry-forward to S399 IMPL**: CONDITIONAL TRIGGER per § J K.2.b. Trigger fires IF AND ONLY IF S399 dev STEP 0.4 vision-input cold-probe Probe 1 + Probe 2 + Probe 3 ALL fail (claude CLI lacks --input-file / @-syntax / image-MIME stdin substrate) AND DD-5 fallback (a)/(b) infeasible (Option (a) PNG-via-base64-text-substrate would surface in Probe 3 partial success; Option (b) DEFER-G.3-to-V2 is always feasible administratively).

**Likelihood estimate**: MEDIUM-HIGH per parent plan-040 § C.0.5 OPEN QUESTION explicit + STEP 0.1.a VBW finding that current claude_cli_transport signature has NO file/image parameter.

**Pre-authored STOP-FINDING template**: per L-S397-2 severity-schema vocabulary CHARTER-TIER-SURFACE (NOT ad-hoc IMPLEMENTATION-BLOCKER per S397 F4 finding); Options menu per DD-5 with 3 sub-options:
- (a) PIVOT to PNG-via-base64-text-substrate (Resolution C even if quality low)
- (b) DEFER G.3 to V2; G.4 dogfood proceeds with G.2-only IF G.2 ratifies winner
- (c) AMEND anthropic_api_to_subagent memory rule scope (CHARTER-TIER — user gate required)

**Main session decision path IF fired**: AskUserQuestion gate Q-INT-2026-05-G-prime-2 per parent plan-040 § K.2.b ratification path; S399 dev PAUSES pending main session ratification per autonomous_continue_no_self_pause carve-out.

## Source-evidence chain (per L-S392-1 VBW-confirmed file:line citations)

All file:line citations in plan-043 DDs and § A.4 calibration are VBW-confirmed empirically via Read/Glob/Grep at S398 PLAN authoring; key 12 source files cited inline:

1. `packages/infrastructure/analysis/subagent_transport.py:144-222` — claude_cli_transport signature + subprocess.run pattern; confirmed via full Read (222 LOC); ZERO file/image attachment parameter in current signature
2. `agent-workspace/constitution/financial-data-protocol.md:358-477` — Rule 16 + 4 satisfaction modes; mode #2 deterministic-pipeline echo at :396-402 + EchoValidator.validate(...) interface citation at :432; confirmed via Read offset 350-477
3. `packages/application/fundamental/pdf_table_extractor_port.py:93-185` — D-080 ACCEPTED ABC contract; 4 abstract methods + source_id ClassVar at :109 + `__init_subclass__` typecheck at :111-131; confirmed via full Read (185 LOC)
4. `packages/application/fundamental/pdf_source.py:39-87` — PdfSource value object; confirmed via full Read (87 LOC); D-064 path-safety at :64-72
5. `packages/application/fundamental/extracted_financial_statement.py:43-117` — ExtractedFinancialStatement; confirmed via full Read (117 LOC); 7 fields + __post_init__ invariants at :76-117
6. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py:5-8` — anthropic_api_to_subagent precedent ("ANTHROPIC SDK NO LONGER USED in production code"); confirmed via Read first 100 LOC; claude_cli_transport imported at :41
7. `packages/infrastructure/analysis/test_subagent_transport.py:10-11` — unittest.mock.patch pattern for mocked subprocess.run; confirmed via Read first 80 LOC; G.3 D4 test mock shape MIRRORS
8. `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` — D-080 ACCEPTED at S397 per acceptance_basis line 10; ABC contract immutable per consequences at :198-205; G.3 dispatch UNBLOCKED per :202; confirmed via full Read (220 LOC)
9. `agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md` — V3 charter compliance pattern + V6 integration smoke + V8 ADR quality 15 fields ≥12 floor; confirmed via full Read (120 LOC)
10. `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-library-bakeoff-impl.md` — G.1 IMPL outcomes + RM3 BLOCKER + ABC contract 4-method count + L-S389-1 wc -l attestation pattern; confirmed via full Read (230 LOC)
11. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` — parent master plan § E.3 G.3 sub-track contract + § C.0.4 Rule 16 audit + § C.0.5 anthropic_api_to_subagent memory-rule check; confirmed via Read offset 1-300 + 300-600
12. `agent-workspace/session-plans/completed/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md` — G.1 sub-plan template shape reference (~1097 LOC); confirmed via Read offset 1-300 + 300-700 + 700-1097

Additional confirmations: `Glob packages/infrastructure/fundamental/*.py` (4 files exist — claude_vision_pdf_adapter.py is NEW), `Glob packages/application/fundamental/*.py` (5 files post-G.1 — echo_validator.py is NEW), `Glob tests/unit/**/*.py` (0 results — tests/unit/ tree NEW per DD-9), `Glob tests/fixtures/pdf/*` (5 files exist per S394 D4 — REUSE READ-ONLY), `Glob agent-workspace/memory/decisions/08{0,1,2}*.md` (D-080 ACCEPTED + D-081 reserved by S396 per current-execution.md:150 + D-082 next-free), `Grep "import anthropic"` confirms only legacy `claude_llm_perspective_adapter.py` imports (per D-052 transport-flip carry-forward).

## Parallel-dispatch compatibility with S396 + future G.2/G.4

**COMPATIBLE with S396 in-flight per dispatch brief explicit OFF-LIMITS list + current-execution.md:139**:
- S396 file scope: `packages/application/analysis/use_cases/validate_thesis_phase1.py` + `apps/cli/validate_thesis*` + `data/stockforge.sqlite` + `agent-workspace/memory/thesis-log/2026-05-17-*` + `agent-workspace/memory/decisions/081-*` + `agent-workspace/memory/cost-ledger.tsv` + `agent-workspace/session-plans/{pending,completed}/045-*`
- G.3 (plan-043) file scope: `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` + `packages/application/fundamental/echo_validator.py` + `tests/unit/{infrastructure,application}/fundamental/*` + ADR D-082 + observation + session-log
- **ZERO file scope overlap confirmed**: G.3 BC-2 fundamental adapter vs S396 BC-9 analysis use-case + BC-1 data + thesis-log; disjoint
- Main session orchestrating S398 (THIS PLAN; sandwich-architect) + S396 (sandwich-dev in-flight) as 2-parallel dispatch per plan-025 DD-5 3-parallel ceiling

**PARALLEL-ELIGIBLE with future G.2 sub-plan 042 per parent plan-040 § N.2**:
- G.2 file scope: `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` (DISTINCT file from G.3 pdf_claude_vision_fundamental_adapter.py per parent plan-040 § E.2/E.3 file naming convention)
- G.2 BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision (current state per current-execution.md:151); G.2 dispatch will UNBLOCK after human downloads real VHM 2023 + HPG 2023 + annotates expected_cells_*.json
- IF RM3 resolves DURING S399 IMPL → main session can dispatch G.2 PLAN (sub-plan 042) in parallel with S400 verifier on G.3
- IF RM3 resolves AFTER S400 verifier → sequential G.2 dispatch path

**SEQUENTIAL with future G.4 sub-plan 044 per parent plan-040 § E.4**:
- G.4 BLOCKS on BOTH G.2 + G.3 ship per parent plan-040 § E.4 explicit "G.4 SEQUENTIAL POST-G.2 + G.3 ship"
- G.4 sub-plan dispatch after BOTH plan-042 + plan-043 VERIFY PASS

## Expected IMPL-session budget per CLAUDE.md table

Per parent plan-040 § E.3 + recalibrated CLAUDE.md Opus FOCUSED_IMPL column:

- **S399 dev IMPL projection**: 130-180K Opus FOCUSED_IMPL (extended for vision-input cold-probe novelty + EchoValidator runtime invariant novelty + per-call cost ceiling design novelty)
- **STEP 0 evaluation overhead**: ~20-30K (STEP 0.4 cold-probe 3-probe sequence + full-pipeline cold-probe per L-S395-1)
- **D1 ClaudeVisionPdfTableExtractor adapter**: ~30-40K
- **D2 EchoValidator**: ~15-20K
- **D3 STEP 0.X cold-probe execution + write-up**: ~30-40K (DOMINANT — empirical probe novelty; depends on claude CLI behavior)
- **D4 Unit tests**: ~25-35K (≥25 test cases combined)
- **D5 ADR D-082 PROPOSED + STOP-FINDING IF K.2.b**: ~15-25K
- **Observation + session log + mistake-log**: ~10-15K
- **Reserve for inline F-fix**: ~10-15K
- **Total projected dev budget envelope**: 155-220K typical; 165-230K with K.2.b STOP-AND-ASK path; ≤180K Opus FOCUSED_IMPL target if work tracks lower estimate

## Karpathy P1 explicit pushback on dispatch brief

Per Karpathy P1 think-before-coding doctrine + L-S385-3 "pushback when simpler approach exists":

### Dispatch-brief refinement #1 (ARCHITECT REFINEMENT)
- **Dispatch brief said**: "DD-2 vision-input shape (PDF page rendered to image vs PDF-direct-input — depends on K.2.b probe)"
- **Architect refinement**: enumerated 4 Resolution paths (A: --input-file / B: @-syntax / C: base64-MIME stdin / D: NONE → DD-5 fallback) with explicit pre-authored STEP 0.4 3-probe sequence to empirically determine; cold-probe BEFORE bulk implementation per L-S395-1
- **Rationale**: claude_cli_transport current signature has NO file/image parameter (STEP 0.1.a VBW finding); PLAN cannot pre-commit to single Resolution without empirical evidence; 3-probe sequence covers all known CLI conventions
- **Documented in**: DD-2 + § C STEP 0.4 + § E.3 D3

### Dispatch-brief refinement #2 (ARCHITECT REFINEMENT)
- **Dispatch brief said**: "DD-4 Rule 16 mode #2 strictness (cell-by-cell echo vs full-table-echo vs partial-cell-tolerance)"
- **Architect refinement**: chose cell-by-cell echo with tolerance=0 exact-match (NOT full-table-echo + NOT tolerance-band/partial-cell-tolerance) + canonical-form coercion (NOT a tolerance — a bijection)
- **Rationale**: financial-data-protocol.md:401-402 verbatim "Mismatch is a HARD ERROR (raise + abort; never silently coerce)" — tolerance-band silently coerces within band = charter violation; cell-by-cell preserves diagnostic granularity
- **Documented in**: DD-4 + § E.2 D2 EchoValidator implementation tasks

### Dispatch-brief refinement #3 (ARCHITECT-NEW)
- **Dispatch brief said**: "DD-5 fallback path if vision-input infeasible (text-OCR-then-Claude vs defer-to-G.2-winner-adapter)"
- **Architect refinement**: pre-authored 3-option fallback menu (PIVOT to PNG-via-base64-text-substrate / DEFER G.3 to V2 / CHARTER amend memory rule scope) with L-S397-2 severity-schema vocabulary CHARTER-TIER-SURFACE — main session can ratify quickly via K.2.b STOP-AND-ASK
- **Rationale**: dispatch brief's text-OCR-then-Claude is NOT a Claude-vision substrate (it's tesseract OCR text → Claude text-input which is a different architectural path; parent plan-040 § A.3 deferred tesseract); defer-to-G.2-winner-adapter is Option (b) DEFER G.3 to V2; added Option (a) base64-text-substrate (preserves DD-1 ZERO-anthropic-SDK) + Option (c) CHARTER amend (only path to direct anthropic SDK use)
- **Documented in**: DD-5 + § J K.2.b + § C STEP 0.4 STOP-AND-ASK

### Dispatch-brief addition #4 (ARCHITECT-NEW DD-9)
- **Dispatch brief said**: "tests `tests/unit/application/fundamental/test_echo_validator.py` + `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW)"
- **Architect addition**: explicit DD-9 ratifying NEW directory convention `tests/unit/` tree (existing convention = tests-alongside-code per packages/application/fundamental/test_*.py per G.1 D4); coordination check at STEP 0.5.b documents existing convention vs new path; L-S392-1 dispatch-brief precedence applied
- **Rationale**: dispatch brief asserts specific NEW paths; architect ratifies via DD per L-S392-1 doctrine; AP-23 1st-instance HOLD on tests/unit/ convention (if 2nd sub-plan adopts → promote to template; else retire)
- **Documented in**: DD-9 + § C STEP 0.5.b + § L PCG-4 promotion candidate

## Out-of-scope items captured in sub-plan § A.3

18 deferred items with named revisit triggers per AP-7 (no naked deferrals). Key items:
- G.2 pure-Python winner adapter IMPL (separate sub-plan 042; BLOCKED on RM3)
- G.4 BC-2 dogfood (separate sub-plan 044; BLOCKS on G.2 + G.3)
- EchoValidator mode #1 categorical surrogate (BC-6 KOL future)
- EchoValidator mode #3 calibration-database lookup (BC-6 KOL future)
- EchoValidator mode #4 NULL surrogate (mode #4 by omission semantic)
- Multi-currency support (Phase 3+)
- Scanned-PDF tesseract fallback (Phase G-prime-V2)
- PdfTableExtractorRegistry centralized dispatcher (Phase G-prime-V2 if ≥3 adapters)
- OCR-confidence per-cell field (mode #1 categorical surrogate if needed)
- Per-page parallel vision calls (G.4 dogfood if cost-runaway)
- Vision-call streaming output (Phase H-prime dashboard)
- PROMPT_HASH audit-trail (G.3-V2 if Charter Principle 2 reproducibility surfaces)
- EchoValidator promotion to packages/_shared/ (2nd-BC reuse trigger)
- anthropic dep drop (D-052-V2 after all transport-flips complete)
- Per-page image cache (G.4 dogfood repeat-run pattern)
- Cost cap escalation via AskUserQuestion (2nd-occurrence DD-6 revisit)
- Charter amendment SHIP (K.2.b trigger)
- Harness hook for cost-runaway detection (AP-23 promote-to-hook if 2+ incidents)

## Promotion candidates captured (PCG-1..6)

| PCG | Pattern | Promotion-readiness | Notes |
|---|---|---|---|
| PCG-1 | EchoValidator runtime invariant primitive (Rule 16 mode #2 implementation) | If reused for ANY LLM-claimed-numeric-value gate (BC-5 + BC-6) | LIKELY 2nd-BC promote — parent plan-040 § L PCG-3 candidate; AP-23 1st-instance HOLD THIS sub-plan |
| PCG-2 | vision-input-modality cold-probe protocol (3-probe + full-pipeline cold-probe per L-S395-1) | If reused for any future LLM-substrate-modality probe | DEFER per AP-23 1st-instance HOLD |
| PCG-3 | Per-call cost-ledger pattern at adapter tier (Decimal-precision cost tracking) | If reused at Phase 3 calibration adapter | DEFER per AP-23 1st-instance HOLD |
| PCG-4 | tests/unit/ directory convention (NEW per DD-9) | If 2nd sub-plan adopts (G.2 042 OR G.4 044) | DEFER per AP-23 1st-instance HOLD; if 2nd adopts → promote; else retire |
| PCG-5 | Rule 16 mode #2 satisfaction-by-construction proof pattern in ADR | If reused in future LLM-numeric-field ADR (BC-5 + BC-6) | LIKELY 2nd-instance promote — formalize template |
| PCG-6 | CHARTER-TIER-SURFACE STOP-FINDING severity vocabulary (per L-S397-2 promote candidate from S397 verifier) | THIS sub-plan is 2nd-instance per L-S397-2 IF K.2.b fires AND STOP-FINDING uses CHARTER-TIER-SURFACE | LIKELY promote-on-2nd-instance |

## What I did NOT do

Per dispatch brief hard rules + agent template L21:
- Did NOT write any production code (architect PLAN-only)
- Did NOT modify PROJECT_CHARTER.md
- Did NOT modify any agent-workspace/constitution/** file
- Did NOT modify existing plans 040-042 + 044+ (parent + sibling references only)
- Did NOT modify D-080 ADR (G.1 ACCEPTED state preserved)
- Did NOT pick the Claude vision input shape definitively (DD-2 conditional on STEP 0.4 cold-probe outcome per VBW protocol + L-S392-1)
- Did NOT commit (per D-060 + architect-has-no-Bash + pre-dispatch-architect-commit-guard.sh — main session commits this plan)
- Did NOT push (D-060 hard rule — agents MUST NOT push)
- Did NOT call /master-plan or any Skill (per Q-2.1 = B — skills only in SUPERVISED mode; this is autonomous-full mode per CLAUDE.md user memory)
- Did NOT reuse plan numbers 040-042 + 044+ (045 reserved by S393; used 043 only per dispatch brief mandate)
- Did NOT touch S396 in-flight file scope (per dispatch brief explicit OFF-LIMITS list)
- Did NOT write to human-workspace/** (STEP 0.4 STOP-AND-ASK is S399 dev conditional path; PLAN session has no charter/scope question)
- Did NOT execute STEP 0.4 cold-probe at PLAN-tier (requires subprocess.run claude CLI invocation; architect has Read/Glob/Grep/Write only; cold-probe execution defers to S399 IMPL session)

## CLOSE-LOOP file-existence verification (per L-S397-3)

**Plan file**: `wc -l agent-workspace/session-plans/pending/043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator.md` = 1051 LOC (exact integer per L-S389-1; drop ~ prefix discipline)

**Observation file** (this file): `wc -l agent-workspace/memory/observations/sandwich-architect-S398-g3-claude-vision-adapter.md` = TBD-at-write-end (architect cannot execute wc -l with no Bash; main session OR S400 verifier confirms post-write per L-S397-3 close-loop verification mandate; architect's best estimate via mental line count ~280-310 LOC; final integer to be confirmed by verifier)

**Note on L-S397-3 architect-tool-gap**: sandwich-architect tools = [Read, Glob, Grep, Write] per agent template; NO Bash. Cannot self-execute `wc -l` for own observation file. Best-effort: architect estimates LOC via mental count; main session OR S400 verifier confirms via wc -l post-write. THIS observation declares estimate ~280-310 LOC; per L-S397-3 close-loop discipline, main session is requested to confirm exact integer via wc -l post-architect-output and amend this section IF discrepancy >5%.

## Recommendation for main session next-turn action

Per parent plan-040 § N.2 + dispatch brief § N:

1. **Commit plan-043 + observation** per D-060 + pre-dispatch-architect-commit-guard.sh hook (single commit recommended; commit message format = "S398: Phase G-prime G.3 Claude vision adapter + EchoValidator sub-plan-043 PLAN authored by sandwich-architect (background; ~6-7min/Opus PLAN 150-230K window)")
2. **Dispatch S399 sandwich-dev FOCUSED_IMPL** post-commit per § N.2 sequencing (Opus per all-14-agents-on-Opus user directive; 130-180K FOCUSED_IMPL budget per parent plan-040 § E.3 + recalibrated CLAUDE.md table; extended for vision-input cold-probe + EchoValidator novelty)
3. **Schedule S400 sandwich-verifier AP-1** post-S399 dev close (Opus per all-14-agents-on-Opus; 80-180K VERIFY budget per recalibrated CLAUDE.md Opus column)
4. **K.2.b CHARTER-TIER ratification path**: IF S399 dev STEP 0.4 cold-probe fires K.2.b → main session reviews STOP-FINDING-S399 at `human-workspace/notifications/` + dispatches AskUserQuestion gate Q-INT-2026-05-G-prime-2 per parent plan-040 § K.2.b ratification path; options menu per DD-5 (a/b/c)
5. **Phase G-prime DoD gate**: G.3 close (S400 verifier PASS) + G.2 ratification (sub-plan 042 BLOCKED on RM3 STOP-FINDING-S394 resolution — separate path) → G.4 sub-plan 044 dispatch-ready

## Architect-internal token usage (THIS PLAN session)

- **Budget**: 150-230K Opus PLAN target (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus 150-230K column)
- **Estimated actual**: ~180-220K Opus (mid-band; +30-50K over plan-041 ~170K for DD-2 vision-input shape conditional resolution depth + DD-5 fallback path menu + DD-6 per-call cost ceiling design + DD-9 test path convention addition; +50K reserve for STEP 0.X cold-probe protocol authoring novelty)
- **Within envelope**: YES per 150-230K Opus PLAN target

---

**END OF S398 OBSERVATION**

> Architect output complete. Main session reviews + commits + dispatches S399 dev per § N sequencing.
