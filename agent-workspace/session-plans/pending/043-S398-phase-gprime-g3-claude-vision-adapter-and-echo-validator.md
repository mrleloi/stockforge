---
plan_id: 043-S398-phase-gprime-g3-claude-vision-adapter-and-echo-validator
target_session: S399 (sandwich-dev FOCUSED_IMPL executing D1-D5; S396 in-flight per current-execution.md:139 for plan-045 continuation + BR-6 cap fix + ADR D-081; ZERO file scope overlap)
type: FOCUSED_IMPL (5 sub-tracks D1-D5; sub-plan author = sandwich-architect at S398; IMPL by sandwich-dev at S399; VERIFY by sandwich-verifier AP-1 at S400)
budget:
  - this PLAN session (S398 architect): ~150-230K Opus PLAN per recalibrated CLAUDE.md table (cold-start declared for task_class="pdf-claude-vision-adapter-plan"; nearest analogs pdf-extraction-plan n=1 from S392 plan-041 ~170K Opus + multi-perspective-impl-plan n=1 from S374 plan-034 ~140K Opus + bc-8-transport-flip-plan n=1 from S374 ~140K Opus; novel sub-components = vision-input-modality probe protocol + EchoValidator runtime invariant + per-call cost ceiling)
  - sub-plan IMPL (S399 dev): ~130-180K Opus FOCUSED_IMPL per parent plan-040 § E.3 budget ("G.3 IMPL may need 1-2 IMPL sessions (Claude vision substrate + EchoValidator + cell-validation gate is broader surface than G.2)"); LLM substrate novelty + EchoValidator novel + STEP 0 vision-input cold-probe
  - sub-plan VERIFY (S400 verifier): ~80-180K Opus AP-1 fresh-context per recalibrated CLAUDE.md VERIFY-Opus column
phase: G-prime (Theme J — BC-2 Fundamental Data PDF + table extraction; sub-theme G.3 Claude vision OCR-adapter + EchoValidator Rule 16 mode #2 deterministic-pipeline echo gate; PARALLEL-ELIGIBLE with G.2 sub-plan 042 per parent plan-040 § N.2 — disjoint adapter files)
track: Wave 1 Theme J sub-theme G.3 — ClaudeVisionPdfTableExtractor subclass of PdfTableExtractorPort + EchoValidator post-OCR cell-validation primitive (cell-content-exact-match against deterministic re-parse) + tests + ADR D-082 PROPOSED
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN; this is sub-plan #3 per § E.3 + § N.2 sequencing)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 5.5 + § 6.4.4
predecessor: 041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md (G.1 IMPL SHIPPED at S394 commits ec293fc + b9b38be; VERIFIED PASS at S397 per sandwich-verifier-S397-plan-041-g1-verify.md; ABC contract + ExtractedFinancialStatement + PdfSource COMPLETE + merge-eligible; D-080 ACCEPTED at S397)
successor: S399 sandwich-dev FOCUSED_IMPL executing this plan D1-D5 → S400 sandwich-verifier AP-1
architect: S398 sandwich-architect (background; THIS plan)
dispatched_by: main session orchestrating Phase G-prime sub-plan 043 dispatch per parent plan-040 § N.2 sequencing + S397 verifier handoff "G.3 sub-plan 043 (Claude vision adapter) dispatch UNBLOCKED — confirmed empirically. ABC contract has NO dependency on PDF file presence or bake-off winner library."
authored: 2026-05-17
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent; Phase 1b CONSUMED variant with COLD-START declared for task_class="pdf-claude-vision-adapter-plan" — no precedent in .planner-stats.tsv or sessions-rollup.tsv; nearest analogs = pdf-extraction-plan n=1 from S392 plan-041 (ABC + dataclass + bake-off probe shape) + multi-perspective-impl-plan n=1 from S374 plan-034 (claude_cli_transport substrate shape) + bc-8-transport-flip-plan n=1 from S374 (transport-flip adapter shape); novel sub-components = vision-input-modality probe protocol + EchoValidator runtime invariant authoring + per-call cost ceiling design + claude CLI vision-input feasibility cold-probe)
executing_agent: N/A this PLAN session; S399 sandwich-dev FOCUSED_IMPL + S400 sandwich-verifier AP-1
status: pending-execution

pre_flight_active:
  - "R1 destructive-command-guard.sh PreToolUse (per current-execution.md § INCIDENT + RECOVERY 2026-05-14)"
  - "R2 project-integrity-watchdog.sh Stop hook"
  - "R3 daily-backup.sh Stop hook"
  - "BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED (carry-forward from S310)"

depends_on:
  - "Parent master plan-040 § E.3 sub-plan contract (Claude vision adapter via claude_cli_transport substrate + EchoValidator post-OCR cell-validation gate per Rule 16 mode #2 + ADR D-082 PROPOSED + ≥20 unit tests)"
  - "G.1 sub-plan 041 SHIPPED + VERIFIED (S394 dev + S397 verifier PASS; D-080 ACCEPTED) — ABC contract + ExtractedFinancialStatement + PdfSource available at packages/application/fundamental/ for subclassing"
  - "D-066 ACCEPTED (CrawlerAdapter ABC at packages/application/news/ports/crawler_adapter.py:60-78 __init_subclass__ pattern — INFORMATIONAL precedent for ABC subclass-instantiation validation in V6 verifier smoke per S397 V7)"
  - "D-072 ACCEPTED BC-5 transport-flip precedent (claude_cli_transport substrate shipped at S375; SAME substrate function used here for vision dispatch path)"
  - "D-074 PROPOSED BC-8 transport-flip precedent (RolePromptPack Foundation; SAME claude_cli_transport reuse pattern; G.3 mirrors)"
  - "D-080 ACCEPTED (PdfTableExtractorPort ABC contract at packages/application/fundamental/pdf_table_extractor_port.py:93-185 — G.3 adapter MUST subclass this contract)"
  - "D-059 (Python determinism contract — R1 datetime-no-tz + R2 unseeded RNG + R4 time.time-in-domain BINDING for every NEW/MODIFIED file authored under this sub-plan; extracted_at field on ExtractedFinancialStatement MUST be tz-aware)"
  - "D-060 (commit-policy-agent-may-commit) — operational gate for S399 dev commit boundary"
  - "D-062 (atomic-write-doctrine) — applies to any per-call cost-ledger writes via tmp+os.replace pattern"
  - "D-064 (path-safety 5-invariant contract) — BINDING for ANY new file-path code in this sub-plan (PDF inputs + per-page image cache + per-call cost-ledger)"
  - "D-065 Rule 16 (numeric-field discipline; ACCEPTED 2026-05-16 via Q-INT-2026-05-6 ratification + S336 user pick) — BINDING for G.3 because Claude vision IS the LLM-output path that introduces numeric values to ExtractedFinancialStatement.raw_cells; satisfied via mode #2 deterministic-pipeline echo per financial-data-protocol.md:358-477 + parent plan-040 § C.0.4 audit + § C.0.5 anthropic_api_to_subagent memory-rule check"
  - "D-067 PROPOSED-AT-IMPL (planner-upgrade ADR plan-025 — Phase 1b mandate for ≥3 sub-tracks; THIS plan has 5 sub-tracks D1-D5 → Phase 1b CONSUMED variant MANDATORY per plan-025 DD-11)"
  - "Charter v1.1 Principle 1 (NO LLM math — Claude vision OCR is character-recognition NOT number-derivation; deterministic VND-string re-parser produces canonical Decimal; EchoValidator gates LLM-claimed-value vs deterministic-parsed-value) + Principle 2 (Every claim has source + as-of date — source_pdf_url + source_pdf_page + extraction_method + extractor_version + extracted_at preserved via inherited ExtractedFinancialStatement) + Principle 7 (Dogfood mandatory — G.3 dogfood is the V0 G.4 sub-plan 044 ship; G.3 ships substrate) + Principle 8 (Calibration over confidence — per-cell EchoValidator pass-rate IS the calibration substrate; cost-per-call recorded) + Principle 11 (firing-test mandate IF a hook is shipped — N/A this sub-plan; product substrate only; EchoValidator is application-layer primitive NOT a hook)"
  - "I-S1 (NO LLM math) — Claude vision OCR is character-recognition; deterministic VND-string parser produces Money; EchoValidator MANDATORY gate per Rule 16 mode #2"
  - "I-S1-1 (Rule 16 numeric-field discipline; ACCEPTED 2026-05-16 per D-065) — BINDING for G.3 cell numeric values; mode #2 deterministic-pipeline echo satisfied by-construction via EchoValidator runtime invariant per financial-data-protocol.md:396-402"
  - "I-S2 (citation discipline) — every G.3-extracted cell preserves source_pdf_url + source_pdf_page + extraction_method + extractor_version + as_of_filing_date via inherited ExtractedFinancialStatement contract"
  - "I-S20 (calibration over confidence) — per-cell EchoValidator pass-rate + per-extraction cost USD recorded in extraction telemetry; calibration_grade='D' V0 baseline; gold-set hit-rate accumulates at G.4 dogfood"
  - "I-S22 (data lineage) — ExtractedFinancialStatement provenance fields (extraction_method='claude-vision' + extractor_version semver) preserved per G.1 D2 dataclass contract"
  - "I-S34 (HARD REJECT — public sources only) — G.3 STEP 0 vision-input cold-probe uses synthetic minimal-PDF placeholder OR G.1 committed gold-set fixtures (tests/fixtures/pdf/*.pdf SHA256-manifested); NO paid-API leak channels"
  - "I-S35 (research-aid framing) — G.3 ships extraction substrate; output framing UNCHANGED"
  - "anthropic_api_to_subagent memory rule (D-050 CHARTER ACCEPTED 2026-05-09) — MANDATORY: ALL Claude API calls go through claude_cli_transport subagent dispatch at packages/infrastructure/analysis/subagent_transport.py:144-222; ZERO direct anthropic SDK use; ZERO ANTHROPIC_API_KEY env var; subscription billing not API metered"
  - "L-S32-1 empirical-probe-first skill (.claude/skills/empirical-probe-first/SKILL.md — MANDATORY for STEP 0 vision-input cold-probe; claude CLI vision-input feasibility is unverified per parent plan-040 § C.0.5 OPEN QUESTION; cold-probe BEFORE adapter implementation)"
  - "L-S395-1 full-pipeline cold-probe at STEP 0 (promoted from harness queue; operational-track plans MUST include full-pipeline cold-probe at STEP 0 to surface architectural blockers BEFORE bulk-test design) — APPLIES to G.3 vision-input cold-probe at STEP 0.X"
  - "L-S392-1 dispatch-brief-drift prevention rule (architect MUST VBW-verify every cited file path via Read/Glob/Grep; if asserting 'X exists at Y file:line', verify Y exists first)"
  - "L-S382-1 ctor-discipline (existing similar-class ctor patterns documented at STEP 0.X BEFORE adding ClaudeVisionPdfTableExtractor + EchoValidator classes; ctor-signature grep mandatory)"
  - "L-S389-1 wc -l exact-integer attestation discipline (drop ~ prefix; cite exact integers from wc -l)"
  - "L-S389-2 ADR 12-field schema floor (D-082 frontmatter MUST have ≥12 fields)"
  - "L-S397-1 plan LOC ceilings per-category (distinguish core-code vs docstring/test/fixture ceilings)"
  - "L-S397-2 STOP-FINDING severity vocabulary (HIGH / CRITICAL / CHARTER-TIER-SURFACE / ALERT — NOT ad-hoc terms like IMPLEMENTATION-BLOCKER)"
  - "L-S397-3 close-loop file-existence verification (architect verifies observation+session-log files exist on disk via wc -l before composing return summary)"
  - "skill .claude/skills/ddd-tactical-patterns/SKILL.md (Port + Adapter — G.3 adds infrastructure-layer adapter subclassing G.1 application-layer port; EchoValidator is application-layer primitive co-located with port per packages/application/fundamental/)"
  - "skill .claude/skills/empirical-probe-first/SKILL.md (vision-input feasibility cold-probe; if claude CLI lacks PDF/image input → K.2.b CHARTER-TIER FLAG fires)"

binding_decisions:
  - "PHASE 1b CONSUMED + COLD-START DECLARED for task_class='pdf-claude-vision-adapter-plan' — nearest analogs pdf-extraction-plan n=1 (S392 plan-041 ~170K Opus PLAN) + multi-perspective-impl-plan n=1 (S374 plan-034 ~140K Opus PLAN with claude_cli_transport substrate shape) + bc-8-transport-flip-plan n=1 (S374 plan-034 ~140K Opus PLAN with transport-flip adapter shape); directional confidence MEDIUM at n=1 per-analog × 3 analogs; PDF-claude-vision-adapter shape is novel (vision-input-modality probe + EchoValidator runtime invariant + per-call cost ceiling are not in any analog)"
  - "DD-1 claude_cli_transport substrate MANDATORY (per anthropic_api_to_subagent memory rule) — G.3 adapter MUST use claude_cli_transport from packages/infrastructure/analysis/subagent_transport.py:144-222 (proven substrate for text-input dispatch at S375 BC-5 + S378 BC-8); ZERO new import anthropic / ZERO ANTHROPIC_API_KEY env var (verifier grep-asserts at V3 charter compliance per S397 V3 pattern)"
  - "DD-2 vision-input shape CONDITIONAL on STEP 0.X cold-probe outcome — current claude_cli_transport signature is (model, system_prompt, user_message, temperature, role) — ALL strings + scalars; NO file/image attachment parameter; STEP 0.X cold-probe must determine (a) does `claude -p` CLI accept --input-file OR @file syntax OR image MIME-typed stdin? (b) if yes, what's the shape and cost behavior? (c) if no, what fallback per DD-5? K.2.b CHARTER-TIER FLAG fires IF probe reveals NO vision-input substrate exists"
  - "DD-3 EchoValidator location = packages/application/fundamental/echo_validator.py (same package as PdfTableExtractorPort ABC; NOT cross-BC shared) per parent plan-040 § E.3 D3 — application-layer primitive co-located with the port it serves; deferred to packages/_shared/ ONLY IF 2nd-instance reuse surfaces (AP-23 promote-on-2nd-recurrence calculus)"
  - "DD-4 Rule 16 mode #2 strictness = cell-by-cell echo with tolerance=0 exact-match on Decimal (NOT full-table-echo + NOT tolerance-band) — financial numbers are EXACT semantically (VND-billion amounts don't have measurement uncertainty); cell-level granularity preserves diagnostic information for which cell failed; mismatch is HARD ERROR (raise + abort) per financial-data-protocol.md:401-402; whitespace + comma-formatting normalized before comparison (NOT a tolerance — a canonical-form coercion)"
  - "DD-5 fallback path if vision-input infeasible = (a) STOP-AND-ASK fires per K.2.b CHARTER-TIER FLAG, (b) S399 dev writes STOP-FINDING-S399-claude-vision-input-infeasible.md per L-S397-2 severity-schema vocabulary (CHARTER-TIER-SURFACE), (c) options menu = (a) pivot to PNG-attachment-via-temp-file IF CLI supports image-MIME-stdin / (b) defer G.3 to V2 IF no CLI vision substrate AND G.4 dogfood proceeds with G.2-only / (c) extract images from PDF via pdfplumber.images + dispatch to claude CLI as base64 data-URI in user_message text (TEXT-substrate fallback; may not yield vision-quality OCR)"
  - "DD-6 per-call cost ceiling = 0.50 USD per extract() call (configurable via ClaudeVisionPdfTableExtractor.__init__(cost_ceiling_usd=Decimal('0.50'))) — VHM-style annual report has ~80-150 pages; G.3 IMPL targets statement-page subset (IS+BS+CF table-pages ≈ 5-15 pages per report); 10 cells per statement × 1 vision call per cell-batch = ~3-10 calls per extract; per-call cost ~$0.05-0.15 estimate → typical extract cost $0.30-0.50; ceiling prevents runaway; cost-ledger record per call for I-S20 calibration"
  - "DD-7 ADR D-082 PROPOSED-AT-IMPL records (a) ClaudeVisionPdfTableExtractor adapter class + (b) EchoValidator runtime invariant + (c) Rule 16 mode #2 satisfaction proof + (d) vision-input shape resolution per STEP 0.X probe outcome + (e) per-call cost ceiling + (f) STOP-AND-ASK CHARTER-TIER FLAG resolution IF K.2.b fired; 12-field schema floor per L-S389-2"
  - "DD-8 ZERO pyproject.toml dep addition THIS sub-plan — Claude CLI substrate is system-installed (claude executable on PATH); NO new Python package required for G.3 adapter; per-page image extraction via pdfplumber IS authorized IF DD-5 fallback (b) path chosen AND G.2 sub-plan 042 already ratified pdfplumber dep — coordination check at STEP 0.X (pdfplumber NOT YET added per current state because G.2 BLOCKED on real-PDF per RM3 STOP-FINDING-S394; G.3 MUST NOT add pdfplumber unilaterally — defer DD-5 fallback (b) until G.2 ratifies dep)"
  - "DD-9 test path convention = tests/unit/infrastructure/fundamental/ + tests/unit/application/fundamental/ per dispatch brief § F explicit (NEW directory convention; existing convention = tests-alongside-code at packages/application/fundamental/test_*.py per G.1 D4) — dispatch brief precedence per L-S392-1; coordination check at STEP 0.5.b documented; new convention sub-plan-introduces tests/unit/ tree"
  - "AP-7 anti-vacuous-defer — every Out-of-scope item names prerequisites + revisit trigger"
  - "AP-23 first-instance HOLD for any new pattern surfaced this session (EchoValidator pattern + vision-input adapter pattern + per-call cost-ledger pattern); 2nd recurrence triggers promote-to-skill calculus (parent plan-040 PCG-3 cell-validation-pattern candidate)"
  - "Karpathy P3 surgical-changes — this sub-plan adds ≤500 LOC core-code per L-S397-1 per-category ceilings: adapter ~250 + EchoValidator ~80 + tests ~250 + ADR ~180 = ~760 LOC total (core + tests + ADR); core production ~330 LOC well within ≤500 ceiling"
  - "Karpathy P2 simplicity — EchoValidator = ONE function (validate(...)) + ONE error class (EchoValidationError); ClaudeVisionPdfTableExtractor = subclass with 4 method implementations + ctor; no abstractions beyond what G.1 ABC requires"
  - "VBW protocol mandatory — S399 dev MUST READ existing packages/application/fundamental/** (G.1 ABC + dataclasses) + packages/infrastructure/analysis/subagent_transport.py (claude_cli_transport contract) + packages/infrastructure/analysis/claude_llm_perspective_adapter.py (transport-flip precedent shape) + agent-workspace/constitution/financial-data-protocol.md § Rule 16 (mode #2 spec) + parent plan-040 § E.3 + this sub-plan § D DDs empirically NOT memory; cite file:line for every architectural claim"
  - "L-S392-1 dispatch-brief-drift prevention — every file path cited in DDs VBW-confirmed via Read/Glob/Grep at PLAN authoring; STEP 0.X re-verification mandatory at S399 IMPL"

hard_rules_acknowledged:
  - "no production code in THIS PLAN session (CLAUDE.md § Session Types — never mix PLAN + IMPL; this plan is architect's; S399 is dev's)"
  - "no commits in THIS PLAN session by architect (sandwich-architect has tools: [Read, Glob, Grep, Write]; no Bash; main session commits this plan output per D-060 + pre-dispatch-architect-commit-guard.sh hook)"
  - "no charter / no constitution / no human-workspace writes in THIS PLAN session (STOP-AND-ASK file at human-workspace/notifications/STOP-FINDING-S399-* is the ONLY conditional human-workspace write path AND only if STEP 0.X triggers fire in S399 dev session NOT this S398 PLAN session)"
  - "no touching Phase F-prime files (current-execution.md:139 confirms Phase F-prime CODE-DONE-DATA-PENDING; ZERO collision per file scope: BC-2 fundamental vs BC-8 personas)"
  - "no touching S396 in-flight file scope (per dispatch brief: packages/application/analysis/use_cases/validate_thesis_phase1.py + apps/cli/validate_thesis* + data/stockforge.sqlite + agent-workspace/memory/thesis-log/2026-05-17-* + agent-workspace/memory/decisions/081-* + agent-workspace/memory/cost-ledger.tsv + agent-workspace/session-plans/pending/045-* or completed/045-*)"
  - "no touching existing G.1 ABC contract (D-080 ACCEPTED immutable except via supersession — packages/application/fundamental/pdf_table_extractor_port.py + pdf_source.py + extracted_financial_statement.py UNCHANGED)"
  - "no touching G.2 territory (packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py reserved for sub-plan 042; G.2 BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision; G.3 adapter file path is DISTINCT: pdf_claude_vision_fundamental_adapter.py)"
  - "no G.4 BC-2 dogfood / SqliteFundamentalRepository integration work in THIS sub-plan (separate sub-plan 044; G.4 BLOCKS_ON G.2 + G.3 ship per parent plan-040 § E.4)"
  - "no Anthropic SDK import (anthropic_api_to_subagent memory rule MANDATORY — claude_cli_transport substrate only; ZERO import anthropic across all G.3 files)"
  - "no ANTHROPIC_API_KEY env var (subscription billing only via claude CLI substrate)"
  - "no cleanup of any pre-existing PDF code (G.1 substrate is current; no cleanup work)"
  - "no harness/hook changes — this plan ships product substrate (G.3 adapter + EchoValidator + tests + ADR); harness gaps surfaced go to next harness-stabilization sweep"
  - "no AskUserQuestion gate this PLAN session (per `full_autonomous_no_supervised` — AskUserQuestion is for SCOPE/CHARTER only; § J K.2.b charter-tier-surface trigger is CONDITIONAL on S399 dev STEP 0.X cold-probe; this PLAN session has no charter/scope question)"
  - "every plan claim cites source file:line (per I-S2 + AOM + VBW protocol)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "I-S34 carries forward — STEP 0 vision-input cold-probe uses synthetic minimal-PDF OR existing G.1 committed fixtures; no paid leak channels"
  - "If S399 dev STEP 0.X vision-input cold-probe surfaces NO vision substrate exists (CLI lacks --input-file / image-MIME-stdin / @file syntax for claude -p), FLAG via § J K.2.b per parent plan-040 § K.2.b inheritance + write STOP-FINDING using standard severity-schema vocabulary per L-S397-2 (CHARTER-TIER-SURFACE)"
  - "L-S389-1 wc -l exact-integer attestation discipline — drop ~ prefix in all LOC citations; cite exact integers from wc -l"
  - "L-S395-1 full-pipeline cold-probe at STEP 0 — STEP 0.X executes single-page vision call + EchoValidator + ExtractedFinancialStatement assembly BEFORE bulk test design; surfaces architectural blockers empirically"
---

# S398 — Phase G.3 ClaudeVisionPdfTableExtractor + EchoValidator Rule 16 mode #2 gate sub-plan (THIRD sub-plan of Phase G-prime)

> **One-sentence intent**: AUTHOR LLM-assisted PDF extraction substrate — (a) NEW `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` ClaudeVisionPdfTableExtractor subclass of PdfTableExtractorPort using existing `claude_cli_transport` substrate (NO direct anthropic SDK) for vision-based OCR of VN PDF financial tables + (b) NEW `packages/application/fundamental/echo_validator.py` EchoValidator runtime invariant primitive enforcing Rule 16 mode #2 deterministic-pipeline echo (cell-by-cell exact-match of LLM-claimed-value vs deterministic-re-parsed-value with tolerance=0; HARD ERROR on mismatch per financial-data-protocol.md:401-402) + (c) NEW STEP 0.X vision-input feasibility cold-probe (per L-S395-1 full-pipeline cold-probe discipline) that empirically determines whether claude CLI substrate supports PDF/image input via subprocess.run (--input-file / @file / image-MIME-stdin) BEFORE bulk adapter implementation + (d) NEW unit tests at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` + `tests/unit/application/fundamental/test_echo_validator.py` (≥20 tests covering subclass-instantiation + EchoValidator pass/fail invariants + mocked claude CLI subprocess output) + (e) ADR D-082 PROPOSED at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (12-field schema floor; records adapter contract + EchoValidator semantics + Rule 16 mode #2 satisfaction proof + vision-input shape resolution + per-call cost ceiling + K.2.b CHARTER-TIER FLAG resolution IF fired) — without modifying existing G.1 ABC contract (D-080 ACCEPTED immutable per supersession discipline), without touching G.2 territory (G.2 BLOCKED on RM3 STOP-FINDING-S394 real-PDF), without LLM-deriving derived-numeric-values (I-S1 binding; LLM does OCR character-recognition only), without bundling G.4 dogfood (separate sub-plan 044).

---

## A. Goal & Scope

### A.1 Goal (verbatim from parent master plan-040 § E.3 + dispatch brief)

Build the **G.3 ClaudeVisionPdfTableExtractor adapter + EchoValidator Rule 16 mode #2 gate** for StockForge BC-2 PDF table extraction, where:

- **ClaudeVisionPdfTableExtractor** is an infrastructure-layer adapter at `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW file in existing `packages/infrastructure/fundamental/` directory; adjacent to existing `vnstock_fundamental_adapter.py` + future G.2 pdf adapter):
  - Subclasses `PdfTableExtractorPort` from `packages/application/fundamental/pdf_table_extractor_port.py:93-185` (D-080 ACCEPTED contract; immutable)
  - Implements all 4 abstract methods: `extract(pdf_source) → ExtractedFinancialStatement` + `supports(pdf_path) → bool` + `name() → str` + `extractor_version() → str`
  - Declares `source_id: ClassVar[str] = "claude-vision"` (enforced non-empty by `__init_subclass__` typecheck at `pdf_table_extractor_port.py:111-131`)
  - Uses **existing `claude_cli_transport`** from `packages/infrastructure/analysis/subagent_transport.py:144-222` (D-072 BC-5 + D-074 BC-8 transport-flip precedents; subscription billing per anthropic_api_to_subagent memory rule)
  - Per-call cost ceiling = `Decimal("0.50")` USD configurable via ctor; cost-ledger record per call for I-S20 calibration
- **EchoValidator** is an application-layer primitive at `packages/application/fundamental/echo_validator.py` (NEW; ~80 LOC):
  - Single function `EchoValidator.validate(llm_value: str, deterministic_value: Decimal, *, cell_label: str) → None` per financial-data-protocol.md:432 spec
  - Canonical-form coercion BEFORE comparison: strip whitespace + normalize thousand-separator (Vietnamese "." OR US ",") + strip parentheses-negative wrapping + handle Triệu-đồng/Tỷ-đồng unit suffixes
  - Tolerance = 0 (exact match on Decimal); mismatch raises `EchoValidationError(cell_label, llm_value, deterministic_value)` HARD ERROR per Rule 16 mode #2 spec at financial-data-protocol.md:401-402 "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"
- **STEP 0.X vision-input feasibility cold-probe** (per L-S395-1 full-pipeline cold-probe discipline): S399 dev executes minimal vision-input probe BEFORE bulk adapter implementation:
  - Probe 1: `claude -p --model claude-sonnet-4-6 --help` → check for `--input-file` / `--image` / `--attachment` / `--file` flags
  - Probe 2: `echo "what is in this image?" | claude -p --model claude-sonnet-4-6` with `--input-file path/to/test.png` (try variants `@path/to/test.png` syntax in user_message)
  - Probe 3: synthetic minimal-PDF test (1-page; 1 financial table; 3 cells) → full ClaudeVisionPdfTableExtractor.extract() round-trip → EchoValidator pass on 3 cells → ExtractedFinancialStatement assembly
  - If ALL 3 probes fail → K.2.b CHARTER-TIER FLAG fires (vision substrate infeasible); DD-5 fallback path activated
- **vision-input shape resolution**: DD-2 conditional — depends on STEP 0.X outcome; possible resolutions:
  - Resolution A: `claude -p` supports `--input-file <path>` flag → adapter pipes PDF page rendered to PNG via deterministic page-to-image conversion + passes path
  - Resolution B: `claude -p` supports `@<path>` in user_message → adapter constructs user_message with `@<png_path>` token
  - Resolution C: `claude -p` supports image-MIME stdin → adapter pipes base64-encoded PNG via stdin
  - Resolution D: NONE of A/B/C work → DD-5 fallback (pivot to PNG-via-base64-text-substrate OR defer G.3 to V2)
- **Per-page PDF→PNG conversion** is a deterministic substrate need (depends on STEP 0.X resolution); for V0 use Python stdlib + system tooling availability check (e.g. `pdfinfo` / `pdftoppm` ghostscript-bundled with camelot if G.2 ratifies pdfplumber+camelot dep; else IF DD-5 fallback (b) chosen, defer to STEP 0.X resolution); STEP 0.X probe surfaces whether PDF→PNG can be done WITHOUT adding new pyproject.toml dep
- **Unit tests** at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW; ~150-200 LOC; ≥15 test cases with mocked subprocess.run for claude_cli_transport per existing pattern at `packages/infrastructure/analysis/test_subagent_transport.py:1-80`) + `tests/unit/application/fundamental/test_echo_validator.py` (NEW; ~100-150 LOC; ≥10 test cases for EchoValidator canonical-form coercion + tolerance=0 + HARD ERROR semantics)
- **Test fixtures**: REUSE `tests/fixtures/pdf/` SHA256.txt + expected_cells_*.json from S394 plan-041 D4 (synthetic placeholders OR real PDFs if RM3 STOP-FINDING-S394 resolved by S399 dispatch time); STEP 0.X probe synthetic minimal-PDF generated in-test if needed (per existing pattern at `packages/application/fundamental/test_extracted_financial_statement.py:93-100` minimal-PDF fixture)
- **ADR D-082 PROPOSED** at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (NEW; ~180 LOC) per parent plan-040 DD-8 + L-S389-2 12-field schema floor; D-082 = next-free ADR number after D-080 (G.1 ACCEPTED) + D-081 (S396 BR-6 cost cap recalibration; reserved per current-execution.md:150)

### A.2 In-scope (this sub-plan ships)

1. **Sub-track D1** — ClaudeVisionPdfTableExtractor adapter at `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW file in existing directory; ~250 LOC core code: subclass PdfTableExtractorPort + 4 method implementations + ctor with cost_ceiling_usd + per-call cost-ledger write + claude_cli_transport invocation + ExtractedFinancialStatement assembly with extraction_method='claude-vision'; foundation; blocks D4 tests)
2. **Sub-track D2** — EchoValidator at `packages/application/fundamental/echo_validator.py` (NEW ~80 LOC core code: single `validate()` static method + canonical-form coercion helper functions + `EchoValidationError` exception class; per Rule 16 mode #2 spec at financial-data-protocol.md:432; blocks D1 ClaudeVisionPdfTableExtractor calls into validate())
3. **Sub-track D3** — STEP 0.X vision-input feasibility cold-probe execution + STEP 0.X resolution write-up (per L-S395-1 full-pipeline cold-probe discipline; ~30-40 min wall-time DOMINANT; if K.2.b fires → STOP-FINDING + S399 dev pauses pending main session ratification)
4. **Sub-track D4** — Unit tests at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (~150-200 LOC; ≥15 test cases) + `tests/unit/application/fundamental/test_echo_validator.py` (~100-150 LOC; ≥10 test cases) — NEW directories `tests/unit/infrastructure/fundamental/` + `tests/unit/application/fundamental/` (created by D4); STEP 0.X probe outcome may revise test mock shape
5. **Sub-track D5** — ADR D-082 PROPOSED at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (NEW; ~180 LOC; 12-field schema floor; records adapter contract + EchoValidator semantics + Rule 16 mode #2 satisfaction proof + vision-input shape resolution per STEP 0.X + per-call cost ceiling + K.2.b CHARTER-TIER FLAG resolution IF fired)
6. **STEP 0 evaluation observation** appended to `agent-workspace/memory/observations/sandwich-dev-S399-g3-claude-vision-adapter.md`
7. **Session log + observation file** per CLAUDE.md § Session Protocol End
8. **Mistake-log digest entry** (M-S399-N if mistakes; OR explicit "no mistakes this session" statement per CLAUDE.md § Session Protocol End step 6)
9. **ZERO charter / constitution writes**
10. **ZERO direct anthropic SDK imports** (anthropic_api_to_subagent memory rule MANDATORY)
11. **ZERO new hooks** (product substrate; harness sweep is separate per CLAUDE.md hard rule)
12. **ZERO new pyproject.toml deps** (claude CLI is system-installed; no new Python package required)
13. **ZERO touch to G.1 ABC contract** (D-080 ACCEPTED immutable per supersession discipline)
14. **ZERO touch to G.2 territory** (G.2 reserved for sub-plan 042; BLOCKED on RM3)
15. **ZERO touch to existing FinancialStatement domain entity** (per parent plan-040 DD-2/DD-3 backward-compat)

### A.3 Out-of-scope (DEFERRED — explicit non-goals with named revisit triggers per AP-7)

| Deferred item | Why deferred | Revisit trigger |
|---|---|---|
| **G.2 pure-Python winner adapter IMPL** (concrete adapter using G.1-ratified winner library + cell-label normalization + VND-string parser) | Separate sub-plan 042; G.2 BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision; G.3 (THIS plan) is PARALLEL-eligible per parent plan-040 § N.2 — disjoint adapter files | Sub-plan 042 dispatch after RM3 resolution (human downloads real VHM 2023 + HPG 2023 + annotates expected_cells_*.json) |
| **G.4 BC-2 SqliteFundamentalRepository integration dogfood** (VHM annual-report end-to-end through both G.2 + G.3 adapters → SqliteFundamentalRepository persistence → ratio_service smoke-test) | Separate sub-plan 044; G.4 BLOCKS_ON G.2 + G.3 ship per parent plan-040 § E.4 | Sub-plan 044 dispatch after both 042 + 043 verifier PASS |
| **EchoValidator mode #1 categorical surrogate path** (per financial-data-protocol.md:390-394) | Mode #1 is for confidence-like fields with Enum/Literal boundary; G.3 numeric cell values use mode #2 deterministic-pipeline echo per parent plan-040 § C.0.4 audit; mode #1 path is for future BC-6 KOL adapter OR Phase 3 confidence calibration | Mode #1 trigger: future LLM call site that returns categorical confidence (BC-6 KOL recommendation parser OR Phase 3 calibration database lookup) |
| **EchoValidator mode #3 calibration-database lookup** (per financial-data-protocol.md:403-408) | Mode #3 is for confidence values sourced from agent-workspace/calibration/; not applicable to PDF cell numeric values (mode #2 is correct) | Mode #3 trigger: BC-6 KOL recommendation extraction adds extraction_confidence field per Rule 9 + I-S20 |
| **EchoValidator mode #4 NULL surrogate** (per financial-data-protocol.md:410-413) | Mode #4 is for Optional[T] fields where LLM produces None; not applicable here (raw_cells values are always non-None when extracted; mode #2 is correct) | Mode #4 trigger: G.3 adapter encounters cell where deterministic value cannot be computed (e.g. OCR fails completely on a cell) → ExtractedFinancialStatement.raw_cells omits the key entirely (mode #4 by omission semantic; not by None field) |
| **Multi-currency support** (USD-reported FS or VND/USD bilingual tables) | V0 = VND only per parent plan-040 § A.3 deferral | Multi-currency trigger: project-owner adds non-VND-reporting ticker to universe |
| **Scanned-PDF OCR fallback via tesseract+vie.traineddata** | Out of V0 scope per parent plan-040 § A.3 deferral; G.3 Claude vision handles scanned PDFs IF claude CLI vision substrate exists; tesseract fallback adds new system dep | Scanned-PDF trigger: Claude vision fails on ≥2 scanned PDFs in G.4 gold set AND user authorizes tesseract install |
| **PdfTableExtractorRegistry centralized adapter dispatcher** | Per parent plan-040 § A.3 — not on Phase 1 critical path; G.4 dogfood CLI dispatches to G.2 OR G.3 via direct construction + `supports(pdf)` ABC pre-check | Registry trigger: ≥3 PDF adapters shipped (currently 2 planned: G.2 + G.3); revisit at Phase G-prime-V2 |
| **OCR-confidence per-cell field** (numeric float for OCR fidelity) | Would violate Rule 16 (LLM-emitting numeric without mode #2 echo path); per parent plan-040 § C.0.4 audit — defer to mode #1 categorical surrogate (Conviction-equivalent StrEnum) IF surfaced | OCR-confidence trigger: G.4 dogfood reveals per-cell confidence variance helps downstream calibration → ExtractedFinancialStatement V2 adds extraction_confidence: Conviction StrEnum field; mode #1 satisfaction |
| **Per-page parallel vision calls** (concurrent claude CLI invocations for cost-throughput) | V0 ships sequential per-page calls (single subprocess.run loop); parallelization is per-adapter detail; defer to G.4 dogfood IF cost-runaway surfaces | Parallel trigger: G.4 dogfood VHM annual report extraction wall-time > 5 min OR cost > $1.00 per ticker |
| **Vision-call streaming output** (incremental token streaming for UX feedback) | V0 ships request-response only; streaming is UX feature for Phase H-prime dashboard | Streaming trigger: Phase H-prime Streamlit dashboard surface needs progress indicator |
| **PROMPT_HASH audit-trail for vision calls** (per claude_llm_perspective_adapter:9-12 prompt_hash pattern) | DEFER to G.3-V2 IF auditable reproducibility surfaces as need; V0 records extracted_at + extractor_version + source_pdf_sha256 which together identify reproduction context | Prompt-hash trigger: G.4 dogfood thesis-pipeline citation surface needs per-call prompt reproducibility per Charter Principle 2 |
| **EchoValidator promotion to packages/_shared/ (cross-BC primitive)** | Per AP-23 1st-instance HOLD — EchoValidator is single-instance G.3; promotion calculus fires at 2nd-BC reuse (BC-5 News claim extraction OR BC-6 KOL recommendation parser) | Promotion trigger: 2nd-BC use of EchoValidator → factor to packages/_shared/echo_validator.py per parent plan-040 § L PCG-3 candidate |
| **anthropic dep drop from pyproject.toml (D-052 § Implementation step 3)** | Out of scope per Phase G-prime carry-forward; separate D-052-V2 cleanup ADR after all transport-flips complete | D-052-V2 trigger: ZERO `import anthropic` confirmed across packages/ + apps/ AFTER all Phase F-prime + Phase G-prime adapters ship |
| **Per-page image cache** (memoization of PDF page → PNG conversion across re-runs) | V0 ships in-memory only (no disk cache); per parent plan-040 § A.3 cache discipline deferral | Cache trigger: G.4 dogfood repeat-runs surface cost-from-recompute pattern |
| **Cost cap escalation via AskUserQuestion when cost_ceiling_usd exceeded** | DD-6 cost ceiling raises CostBudgetExceeded; main session decides whether to retry with higher cap; NO AskUserQuestion gate in adapter (per `full_autonomous_no_supervised`) | Cost-cap escalation trigger: 2nd occurrence of cost_ceiling_usd exceeded across G.4 dogfood runs → revisit DD-6 default in D-082-V2 |
| **Charter amendment SHIP for any new I-S<N> invariant Theme J surfaces** | THIS plan FLAGS via STOP-FINDING file path IF K.2.b fires; main session ratifies via AskUserQuestion gate ONLY IF S399 dev STEP 0.X surfaces charter-tier need (vision-input infeasibility) | Trigger: § J K.2.b STOP-AND-ASK fires in S399 IMPL session (claude CLI vision-input substrate infeasible) |
| **New harness hook for vision-call cost-runaway detection** | Belongs to harness-stabilization sweep IF cost-runaway incidents surface (AP-23 promote-to-hook calculus) | Harness trigger: 2+ vision-call cost-runaway incidents across G.3 + G.4 dogfood + future Phase 3 calibration runs |

### A.4 Calibration summary (Phase 1b — CONSUMED variant; COLD-START declared for task_class="pdf-claude-vision-adapter-plan"; nearest analogs pdf-extraction-plan n=1 + multi-perspective-impl-plan n=1 + bc-8-transport-flip-plan n=1)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 20+ files cited; key 12 highlighted):

1. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` (parent master plan; § A goal + § C.0.4 Rule 16 audit + § C.0.5 anthropic_api_to_subagent + § D DDs 1-8 + § E.3 G.3 sub-track contract + § N sequencing — read offsets 1-300 + 300-600)
2. `agent-workspace/session-plans/completed/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md` (G.1 sub-plan template shape reference + DD-1 ABC location + § F.1 file scope pattern + § P attestation grid — read offsets 1-300 + 300-700 + 700-1097)
3. `packages/application/fundamental/pdf_table_extractor_port.py` (full 185 LOC; D-080 ACCEPTED ABC contract; 4 abstract methods + source_id ClassVar + __init_subclass__ typecheck at :111-131; ClaudeVisionPdfTableExtractor MUST subclass + implement all 4)
4. `packages/application/fundamental/pdf_source.py` (full 87 LOC; PdfSource value object input to extract(); D-064 path-safety + Rule 1 invariant; G.3 adapter consumes via extract(pdf_source))
5. `packages/application/fundamental/extracted_financial_statement.py` (full 117 LOC; ExtractedFinancialStatement return type; 7 fields with provenance; G.3 adapter populates extraction_method='claude-vision' + extractor_version semver + source_pdf_page + source_pdf_sha256 + extracted_at tz-aware D-059 R1)
6. `packages/infrastructure/analysis/subagent_transport.py` (full 222 LOC; claude_cli_transport signature at :144 — (model, system_prompt, user_message, temperature, role) ALL strings + scalars; subprocess.run with `claude -p --model <model> --output-format json --disable-slash-commands --system-prompt <system>` + stdin=user_message; CURRENT SIGNATURE HAS NO FILE/IMAGE PARAMETER — STEP 0.X cold-probe must surface vision-input shape)
7. `packages/infrastructure/analysis/claude_llm_perspective_adapter.py` (first 100 LOC; D-072 BC-5 + D-074 BC-8 transport-flip precedent; ZERO `import anthropic` in production code path per :5-8; claude_cli_transport imported at :41; SAME pattern G.3 mirrors)
8. `packages/infrastructure/analysis/test_subagent_transport.py` (first 80 LOC; mocked subprocess.run pattern via unittest.mock.patch at :10-11 + _fake_run helper at :50-58; G.3 test_claude_vision_pdf_adapter.py MIRRORS this mock pattern)
9. `agent-workspace/constitution/financial-data-protocol.md` § Rule 16 (offset 358-477; full Rule 16 + 4 satisfaction modes; mode #2 deterministic-pipeline echo at :396-402 — "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"; EchoValidator.validate(llm_value, deterministic_value, tolerance=...) referenced at :432; "Application-layer use cases that invoke an LLM and consume a numeric output field validate the LLM-echoed value against the upstream deterministic-pipeline computation")
10. `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (full 220 LOC; D-080 ACCEPTED at S397 per acceptance_basis line 10; ABC contract immutable except via supersession per consequences at :198-205; G.3 sub-plan 043 dispatch UNBLOCKED per :202)
11. `agent-workspace/memory/observations/sandwich-dev-S394-g1-pdf-library-bakeoff-impl.md` (full 230 LOC; G.1 IMPL outcomes + RM3 BLOCKER + ABC contract method count = 4 confirmed; G.3 adapter MUST subclass + implement all 4)
12. `agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md` (full 120 LOC; V3 charter compliance pattern + V6 integration smoke = "Constructed _Stub(PdfTableExtractorPort) programmatically: subclass with source_id + 4 methods instantiates OK" — G.3 ClaudeVisionPdfTableExtractor MUST pass same V6 subclass-instantiation smoke at S400 verifier; V8 ADR D-080 quality = 15 fields ≥12 floor)

Additional reads: `Glob packages/infrastructure/fundamental/*.py` (confirmed 4 files: vnstock adapter + sqlite repo + test_adapters + __init__; claude_vision_pdf_adapter.py NEW) / `Glob packages/application/fundamental/*.py` (confirmed 5 files post-G.1: __init__ + ABC + 2 dataclasses + 2 tests; echo_validator.py NEW) / `Glob tests/unit/**/*.py` (NONE — convention currently = tests-alongside-code per packages/application/fundamental/test_*.py; THIS sub-plan adds tests/unit/ subdirectory per dispatch brief § F explicit; coordination check at STEP 0.X re: existing convention vs new tests/unit/ path) / `Glob tests/fixtures/pdf/*` (5 files exist per S394 D4: vhm-2023-annual.pdf + hpg-2023-annual.pdf synthetic + SHA256.txt + expected_cells_{vhm,hpg}.json; REUSE for G.3 STEP 0.X if vision-input shape allows synthetic PDF) / `Glob agent-workspace/memory/decisions/08{0,1,2}*.md` (D-080 ACCEPTED + D-081 reserved by S396 + D-082 next-free) / `Grep "import anthropic"` (5 results in legacy claude_llm_perspective_adapter.py imports — pyproject.toml still has anthropic dep at :42 per parent plan-040 § A.4 entry 12; per D-052 transport-flip carry-forward) / `Glob agent-workspace/session-plans/pending/04{3,4}*.md` (NONE — plan-043 + plan-044 numbers available per dispatch brief; 042 BLOCKED + 045 reserved by S393)

**Calibration parameters extracted**:

- **task_class**: `pdf-claude-vision-adapter-plan` (NEW — no precedent in tracking logs; first vision-input PDF adapter in StockForge; nearest analogs are pdf-extraction-plan n=1 from S392 plan-041 (same Phase G-prime substrate; ABC subclass pattern) + multi-perspective-impl-plan n=1 from S374 plan-034 (claude_cli_transport substrate consumption shape) + bc-8-transport-flip-plan n=1 from S374 (transport-flip adapter shape via claude_cli_transport))
- **sample_size**: **0 for pdf-claude-vision-adapter-plan** (COLD-START); **1 for pdf-extraction-plan** (S392 plan-041 ~170K Opus PLAN at ~45 min based on S392 observation) + **1 for multi-perspective-impl-plan** (S374 plan-034 ~140K Opus PLAN) + **1 for bc-8-transport-flip-plan** (S374 plan-034 ~140K Opus PLAN; transport-flip + adapter shape)
- **avg_wall_min observed**: N/A precise cold-start; nearest-analog pdf-extraction-plan ~45 min Opus S392; nearest-analog multi-perspective-impl-plan ~50 min Opus S374; estimating THIS PLAN at ~45-60 min Opus with vision-input cold-probe novelty
- **avg tokens_real observed**: N/A precise cold-start; nearest-analog pdf-extraction-plan ~170K Opus S392; nearest-analog multi-perspective-impl-plan ~140K Opus S374; estimating THIS PLAN at ~160-200K Opus (mid-band; +20-40K over pdf-extraction-plan for vision-input cold-probe protocol authoring + EchoValidator runtime invariant + per-call cost ceiling)
- **parallel_hit_rate**: N/A cold-start; THIS plan declares D2 sequential-before-D1 (EchoValidator must exist before ClaudeVisionPdfTableExtractor calls into validate()); D3 cold-probe sequential-before-D1 (vision-input shape resolution drives D1 implementation); D4 + D5-skeleton parallel-eligible with D1 (disjoint file scopes)
- **parallel_savings_avg**: N/A cold-start; estimated 5-10% wall reduction from D4+D5 parallel with D1
- **failure_mode frequency**: 0 mistakes per nearest-analog pdf-extraction-plan n=1 (S392 clean) + 0 mistakes per nearest-analog multi-perspective-impl-plan n=1 (S374 clean per S375 dev close); novelty risk MEDIUM-HIGH for pdf-claude-vision-adapter-plan shape because (a) vision-input cold-probe is novel (no prior claude CLI vision-input substrate use in StockForge), (b) EchoValidator runtime invariant is novel (no prior LLM-numeric-field gate beyond Rule 6 sampling at packages/contracts/events/), (c) per-call cost ceiling pattern is novel for adapters (existing CostBudgetExceeded is use-case-tier per validate_thesis_phase1.py:189; G.3 ceiling is adapter-tier), (d) tests/unit/ directory creation is novel (convention currently tests-alongside-code; coordination check at STEP 0.X)
- **Adjustment to default budget**: +20-40K Opus reserve over nearest-analog ~140-170K for novelty = ~180-220K projected typical THIS PLAN; S399 IMPL inherits parent plan-040 § E.3 estimate ~130-180K Opus FOCUSED_IMPL (extended for vision-input cold-probe + EchoValidator novelty)
- **Cold-start?**: **YES for pdf-claude-vision-adapter-plan task-class**; **NO for ABC subclass shape** (transfers cleanly from G.1 sub-plan 041 + D-066 CrawlerAdapter precedent); **NO for claude_cli_transport substrate consumption** (transfers from D-072 BC-5 + D-074 BC-8 transport-flip precedents); **YES for vision-input-modality cold-probe** (no prior); **YES for EchoValidator runtime invariant** (no prior LLM-numeric gate primitive); **YES for per-call cost-ledger pattern at adapter tier** (use-case-tier CostBudgetExceeded exists but adapter-tier ceiling is new)

**PLAN BUDGET DERIVATION** (Phase 1b reasoning trail for downstream S399 dev):

- S399 dev IMPL projection: **130-180K Opus FOCUSED_IMPL** per parent plan-040 § E.3 + recalibrated CLAUDE.md table (extended for vision-input cold-probe + EchoValidator novelty)
- STEP 0 evaluation overhead in S399: ~20-30K (cold-probe + L-S395-1 full-pipeline cold-probe + 3-probe sequence)
- D1 ClaudeVisionPdfTableExtractor adapter: ~30-40K
- D2 EchoValidator: ~15-20K
- D3 STEP 0.X cold-probe execution + write-up: ~30-40K (DOMINANT — empirical probe novelty; depends on claude CLI behavior)
- D4 Unit tests (D1 + D2 + STEP 0.X-resolution mock shape): ~25-35K
- D5 ADR D-082 PROPOSED + STOP-FINDING file IF K.2.b fired: ~15-25K
- Observation + session log + mistake-log: ~10-15K
- Reserve for inline F-fix: ~10-15K
- **Total projected dev budget envelope**: 155-220K typical; 165-230K with K.2.b STOP-AND-ASK path; ≤180K Opus FOCUSED_IMPL target if work tracks lower estimate; if work exceeds → SPLIT trigger per § G LOC ceiling per STEP

**PARALLEL OPPORTUNITY** (architect declaration for downstream S399 dev):

- D3 (STEP 0.X vision-input cold-probe) must serialize FIRST as foundation (~10-15 min wall; determines D1 implementation shape)
- D2 (EchoValidator) waits for D3 outcome NO (EchoValidator semantics independent of vision-input shape); D2 may run PARALLEL with D3 cold-probe execution (~5-10 min wall)
- D1 (ClaudeVisionPdfTableExtractor) waits for D3 outcome (vision-input shape resolution drives D1 implementation) + D2 (extract() invokes EchoValidator.validate()) (~10-15 min wall)
- D4 (tests) waits for D1 + D2 (tests import both); D4 mock shape depends on D3 cold-probe outcome (~10 min wall)
- D5 (ADR D-082) waits for all of D1-D4 (records adapter contract + EchoValidator semantics + STEP 0.X resolution + per-call cost ceiling) (~10 min wall)
- **Recommended sequencing**: D3 cold-probe + D2 EchoValidator (parallel) → D1 ClaudeVisionPdfTableExtractor → D4 tests → D5 ADR
- Per plan-025 DD-5 3-parallel ceiling: D3 + D2 = 2-parallel within ceiling

---

## B. In-scope / Out-of-scope (sub-plan-level)

### B.1 In-scope (this SUB-PLAN ships per § A.2 enumeration)

See § A.2 (items 1-15 above).

### B.2 What this sub-plan is NOT (explicitly OUT-OF-SCOPE per dispatch brief § B)

This sub-plan is **NOT**:

1. **G.2 pure-Python winner adapter IMPL** (sub-plan 042; BLOCKED on RM3 STOP-FINDING-S394 real-PDF provision) — adapter at `packages/infrastructure/fundamental/pdf_<winner>_fundamental_adapter.py` (DISTINCT file from G.3 adapter); cell-label normalization table; VND-string parser canonical version; pyproject.toml dep addition for winner library
2. **G.4 BC-2 SqliteFundamentalRepository integration dogfood** (sub-plan 044) — `apps/cli/ingest_pdf_fundamentals.py` CLI + VHM 2023/2024 end-to-end through BOTH G.2 + G.3 adapters → SqliteFundamentalRepository persistence → ratio_service smoke
3. **EchoValidator mode #1 categorical surrogate path** — separate path for confidence-like fields with Enum boundary; G.3 numeric cell values use mode #2 ONLY
4. **Modification of G.1 ABC contract** (D-080 ACCEPTED immutable per supersession discipline) — `packages/application/fundamental/pdf_table_extractor_port.py` + `pdf_source.py` + `extracted_financial_statement.py` UNCHANGED
5. **Modification of vnstock_fundamental_adapter.py** — UNCHANGED per Karpathy P3 backward-compat preservation
6. **Modification of FinancialStatement domain entity** — UNCHANGED per parent plan-040 DD-2/DD-3
7. **Modification of any BC-1/BC-3/BC-4/BC-5/BC-6/BC-7/BC-8/BC-9 file** — Phase G-prime is BC-2 scoped per parent plan-040 § F.3
8. **Modification of S396 in-flight file scope** — explicit OFF-LIMITS per dispatch brief hard-rules: `packages/application/analysis/use_cases/validate_thesis_phase1.py` + `apps/cli/validate_thesis*` + `data/stockforge.sqlite` + `agent-workspace/memory/thesis-log/2026-05-17-*` + `agent-workspace/memory/decisions/081-*` + `agent-workspace/memory/cost-ledger.tsv` + `agent-workspace/session-plans/pending/045-*` or `completed/045-*`
9. **Charter or constitution amendments** — out per CLAUDE.md hard rule; § J K.2.b STOP-AND-ASK fires CONDITIONAL on S399 dev STEP 0.X empirical probe outcome
10. **Pyproject.toml dep addition for any library** — claude CLI is system-installed; NO new Python package required; DD-8 binding (NO unilateral pdfplumber addition for DD-5 fallback path — defer to G.2 ratification)
11. **Direct anthropic SDK import or ANTHROPIC_API_KEY env var use** — anthropic_api_to_subagent memory rule MANDATORY; claude_cli_transport ONLY
12. **PROMPT_HASH audit-trail for vision calls** — DEFER per § A.3; V0 records extracted_at + extractor_version + source_pdf_sha256 sufficient for V0 reproducibility
13. **Per-page parallel vision calls** — V0 sequential per § A.3
14. **PdfTableExtractorRegistry centralized dispatcher** — DEFER per § A.3
15. **Real PDF fixture provision** — RM3 STOP-FINDING-S394 is G.2 blocker; G.3 STEP 0.X cold-probe uses synthetic minimal-PDF OR existing G.1 placeholder fixtures; G.3 implementation does NOT depend on RM3 resolution per S397 verifier handoff "G.3 sub-plan 043 dispatch UNBLOCKED — confirmed empirically. ABC contract has NO dependency on PDF file presence"

---

## C. STEP 0 — VBW Live Verification (this SUB-PLAN — applies to S399 dev session)

### Sub-step 0.1 — claude_cli_transport API surface re-verification (per L-S392-1 dispatch-brief-drift prevention + L-S395-1 full-pipeline cold-probe)

**Trigger**: S399 dev session entry; before ANY ClaudeVisionPdfTableExtractor implementation.

**Probes**:

- **STEP 0.1.a — claude_cli_transport signature re-verification**: S399 dev re-reads `packages/infrastructure/analysis/subagent_transport.py:144-222` and confirms current signature is `claude_cli_transport(model, system_prompt, user_message, temperature, role=None) -> tuple[str, int, int]`; confirms `subprocess.run` invocation pattern at `:172-182` uses `input=user_message` (stdin pipe); confirms ZERO file/image attachment parameter exists in current signature
- **STEP 0.1.b — anthropic SDK import grep**: `Grep "import anthropic" packages/infrastructure/fundamental/` → expect 0 matches BEFORE G.3 adapter authoring; verifier at V3 charter compliance re-runs this grep on G.3 directory at S400 PASS gate
- **STEP 0.1.c — claude CLI executable presence**: `claude --version` or `which claude` (Windows: `where.exe claude`) → confirms claude CLI on PATH; mirrors precedent at subagent_transport.py:186 FileNotFoundError handling

### Sub-step 0.2 — Rule 16 mode #2 spec re-verification (per VBW protocol)

**Trigger**: S399 dev session entry; before EchoValidator implementation.

**Probes**:

- **STEP 0.2.a — Rule 16 mode #2 deterministic-pipeline echo re-read**: S399 dev re-reads `agent-workspace/constitution/financial-data-protocol.md:396-402` and confirms (a) "computed by deterministic code (a non-LLM Python function operating on verified inputs)" + (b) "LLM is permitted only to **echo** that computed value back inside its structured output" + (c) "Echo validation is mandatory: the post-LLM step asserts the LLM-echoed value equals (or matches within tolerance) the upstream computed value" + (d) "Mismatch is a HARD ERROR (raise + abort; never silently coerce)"
- **STEP 0.2.b — EchoValidator interface citation re-read**: S399 dev re-reads `agent-workspace/constitution/financial-data-protocol.md:432` and confirms canonical interface signature is `EchoValidator.validate(llm_value, deterministic_value, tolerance=...)`; G.3 implementation MAY adjust signature per DD-4 (tolerance=0 binding; cell_label kwarg added for diagnostic; HARD ERROR exception class added)

### Sub-step 0.3 — G.1 ABC contract immutability re-verification (per D-080 ACCEPTED supersession discipline)

**Trigger**: S399 dev session entry; before D1 ClaudeVisionPdfTableExtractor subclass authoring.

**Probes**:

- **STEP 0.3.a — PdfTableExtractorPort ABC re-read**: S399 dev re-reads `packages/application/fundamental/pdf_table_extractor_port.py:93-185` and confirms (a) 4 abstract methods (extract + supports + name + extractor_version), (b) source_id ClassVar at :109, (c) `__init_subclass__` typecheck at :111-131; ClaudeVisionPdfTableExtractor MUST satisfy all
- **STEP 0.3.b — ExtractedFinancialStatement re-read**: S399 dev re-reads `packages/application/fundamental/extracted_financial_statement.py:43-117` and confirms 7 fields with `__post_init__` invariants; ClaudeVisionPdfTableExtractor MUST populate all 7 correctly (extraction_method='claude-vision' + extractor_version semver + source_pdf_page 1-indexed or None + source_pdf_sha256 64-hex + extracted_at tz-aware D-059 R1 + raw_cells non-empty + pdf_source from input)
- **STEP 0.3.c — PdfSource re-read**: S399 dev re-reads `packages/application/fundamental/pdf_source.py:39-87` and confirms input type for extract() method; D-064 path-safety enforced at :64-72

### Sub-step 0.4 — STEP 0.X vision-input feasibility cold-probe (per L-S395-1 full-pipeline cold-probe — DOMINANT per § A.4 PARALLEL OPPORTUNITY)

**Trigger**: S399 dev session entry; AFTER STEP 0.1-0.3 but BEFORE D1 ClaudeVisionPdfTableExtractor authoring; NOT a one-off probe — surfaces architectural blocker EMPIRICALLY before bulk implementation.

**3-probe sequence per § A.1 STEP 0.X**:

- **Probe 1 — claude -p --help flag scan**: `claude -p --help` (or `claude --help`) → grep output for `--input-file` / `--image` / `--attachment` / `--file` / `--input` / `image` / `pdf` keywords; record exact `claude -p --help` output verbatim in observation
  - Expected outcomes: (i) flag exists → Resolution A path; (ii) no flag mentioned → continue to Probe 2
- **Probe 2 — `@<path>` syntax test in user_message**: `echo "describe the image at @<absolute_path>/test.png" | claude -p --model claude-sonnet-4-6 --output-format json` (with test.png = synthetic 1-page PNG containing simple test text) → check JSON envelope `result` field for evidence the image was processed (model references image content) vs treated as literal text
  - Expected outcomes: (i) image content referenced → Resolution B path; (ii) literal-text response → continue to Probe 3
- **Probe 3 — base64 data-URI in user_message**: `cat test.png | base64 | xargs -I {} echo "describe this image: data:image/png;base64,{}" | claude -p --model claude-sonnet-4-6 --output-format json` → check JSON envelope `result` field for evidence base64 was interpreted as image (likely NOT — but probe confirms)
  - Expected outcomes: (i) base64 interpreted → Resolution C path (TEXT-substrate but vision-quality OCR; cost is text-tokens); (ii) literal-string response → ALL probes failed → K.2.b CHARTER-TIER FLAG fires per § J

**STEP 0.X full-pipeline cold-probe (per L-S395-1)** — if Probe 1/2/3 yields ANY positive resolution (A/B/C):
- Construct synthetic minimal 1-page PDF with 1 financial table containing 3 cells (e.g. "Doanh thu thuần: 1.234.567" + "Lợi nhuận: 234.567" + "EPS: 12.34")
- Render PDF page → PNG via available system tool (`pdftoppm` if installed; else use synthetic PNG directly bypassing PDF→PNG step)
- Construct ClaudeVisionPdfTableExtractor minimal-shape probe call via chosen Resolution path
- Invoke claude_cli_transport with vision-input shape per resolution
- Parse response → 3 raw cell values
- Invoke EchoValidator.validate() on each cell (deterministic VND-string re-parse + exact-match against LLM-claimed-value)
- Assemble ExtractedFinancialStatement with extraction_method='claude-vision' + extractor_version='0.0.1-probe'
- Confirm full round-trip works WITHOUT exception → STEP 0.X resolution RATIFIED; D1 implementation proceeds with chosen Resolution A/B/C

**STOP-AND-ASK trigger evaluation** — if Probe 1/2/3 ALL fail AND DD-5 fallback (b)/(c) infeasible:
- S399 dev writes `human-workspace/notifications/STOP-FINDING-S399-claude-vision-input-infeasible.md` per L-S397-2 severity-schema vocabulary:
  - `severity: CHARTER-TIER-SURFACE` (standard vocabulary per L-S397-2; NOT ad-hoc terms like IMPLEMENTATION-BLOCKER per S397 F4 finding)
  - `requires_human_decision: true`
  - Documents Probe 1/2/3 exact commands + outputs + failure modes
  - Options menu per DD-5 fallback path:
    - (a) PIVOT to PNG-via-base64-text-substrate (Resolution C even if quality low)
    - (b) DEFER G.3 to V2; G.4 dogfood proceeds with G.2-only IF G.2 ratifies winner
    - (c) AMEND anthropic_api_to_subagent memory rule scope (CHARTER-TIER — user gate required)
- S399 dev PAUSES pending main session ratification per autonomous_continue_no_self_pause carve-out (CHARTER-TIER gates ARE one of the carve-outs)

### Sub-step 0.5 — Existing fixtures + test-path convention re-verification (per L-S392-1)

**Trigger**: S399 dev session entry; before D4 test authoring.

**Probes**:

- **STEP 0.5.a — tests/fixtures/pdf/ inventory**: `Glob tests/fixtures/pdf/*` → confirms 5 files exist per S394 D4 (vhm-2023-annual.pdf + hpg-2023-annual.pdf synthetic placeholders + SHA256.txt + expected_cells_vhm.json + expected_cells_hpg.json); REUSE for G.3 STEP 0.X synthetic minimal-PDF IF vision-input shape allows path-attachment (note: synthetic placeholders are 690 bytes each per S394 observation; insufficient for real OCR but sufficient for vision-input-shape testing)
- **STEP 0.5.b — tests/unit/ directory convention check**: `Glob tests/unit/**/*.py` → expect 0 results (no tests/unit/ exists currently; convention = tests-alongside-code per packages/application/fundamental/test_*.py); dispatch brief § F specifies tests/unit/infrastructure/fundamental/ + tests/unit/application/fundamental/ paths — coordination check:
  - **Option A**: follow dispatch brief explicit paths (tests/unit/*) → adds NEW directory convention; minor but new path discipline
  - **Option B**: follow existing convention (tests-alongside-code) → tests at packages/infrastructure/fundamental/test_claude_vision_pdf_adapter.py + packages/application/fundamental/test_echo_validator.py
  - **Recommendation (DD)**: Follow dispatch brief explicit paths per L-S392-1 ("if dispatch brief asserts file path X, verify; if path doesn't exist + brief asserts NEW path → architect ratifies in DD"); architect ratifies Option A in DD-9 (added per coordination check)
- **STEP 0.5.c — coordination check with S396 in-flight**: `Glob agent-workspace/memory/decisions/081*.md` → confirms D-081 reserved (br-6-cost-cap-empirical-recalibration; per current-execution.md:150 S396 ADR); D-082 is next-free per dispatch brief; STEP 0.5.c also re-verifies S396 file scope does NOT overlap with G.3 (per dispatch brief explicit OFF-LIMITS list)

### Sub-step 0.6 — pre-flight active-rules re-check (carry-forward from S397 + S392 PLAN sessions)

- ✅ R1 destructive-command-guard.sh PreToolUse — ACTIVE
- ✅ R2 project-integrity-watchdog.sh Stop hook — ACTIVE
- ✅ R3 daily-backup.sh Stop hook — ACTIVE
- ✅ BEHAVIORAL HOLD § (1) — SYNC-GRILLING + ROUTINE-IDLE close ritual SUSPENDED — CARRY-FORWARD HONORED

### Sub-step 0.7 — STEP 0 summary (this sub-plan PLAN session)

All 6 sub-steps PASS at S398 PLAN authoring (subset that PLAN session can execute via Read/Glob/Grep). STEP 0.1 + STEP 0.4 carry-forward to S399 dev session for execution (requires `subprocess.run` claude CLI invocation; cannot execute via Read/Glob/Grep alone). No STOP-AND-ASK triggered at PLAN-tier. 1 charter-tier-surface FLAG carry-forward to S399 IMPL session (K.2.b — claude CLI vision-input infeasibility CONDITIONAL on STEP 0.4 cold-probe outcome).

---

## D. Architecture Decisions (DD-1 through DD-9)

### DD-1: ClaudeVisionPdfTableExtractor uses claude_cli_transport substrate (MANDATORY per anthropic_api_to_subagent memory rule)

**Decision**: G.3 adapter MUST use **existing `claude_cli_transport`** from `packages/infrastructure/analysis/subagent_transport.py:144-222`. ZERO `import anthropic` in any G.3 file. ZERO `ANTHROPIC_API_KEY` env var reference.

**Rationale**:
- **anthropic_api_to_subagent memory rule MANDATORY** (D-050 CHARTER ACCEPTED 2026-05-09): "For every `ANTHROPIC_API_KEY` / direct `anthropic` SDK call: refactor to Claude Code subagent dispatch (subscription billing, not API metered); systemic rule"
- **D-072 BC-5 + D-074 BC-8 transport-flip precedents**: claude_cli_transport substrate shipped at S375 (D-072 BC-5) + S378 (D-074 BC-8); SAME substrate function used for vision dispatch path; pattern proven across 2 BCs already
- **Subscription billing**: claude_cli_transport bills against Claude Code subscription (parent OAuth/keychain per subagent_transport.py:4-6); NO separate API budget required
- **Verifier grep-asserts**: S400 verifier at V3 charter compliance re-runs `Grep "import anthropic" packages/infrastructure/fundamental/` (per S397 V3 pattern); MUST return 0 matches in G.3 directory

**Adversarial alternate considered**: Direct anthropic SDK vision call → REJECTED per memory rule (D-050) + D-052/D-053 cascade. If claude CLI vision-input proves infeasible (STEP 0.4 K.2.b CHARTER-TIER FLAG fires), DD-5 fallback path is NOT "use direct anthropic SDK" — it's STOP-AND-ASK for charter amendment OR defer G.3 to V2.

### DD-2: Vision-input shape CONDITIONAL on STEP 0.4 cold-probe outcome (per L-S395-1 full-pipeline cold-probe)

**Decision**: Vision-input shape is **conditional** — depends on STEP 0.4 probe outcome:
- **Resolution A** (claude -p supports `--input-file <path>`): adapter renders PDF page → PNG to tempfile + passes path
- **Resolution B** (claude -p supports `@<path>` in user_message): adapter constructs user_message string with `@<png_path>` token
- **Resolution C** (claude -p supports image-MIME stdin): adapter pipes base64-encoded PNG via stdin
- **Resolution D** (NONE of A/B/C work): DD-5 fallback activates; K.2.b CHARTER-TIER FLAG fires

**Rationale**:
- **L-S392-1 dispatch-brief-drift prevention**: VBW found CURRENT claude_cli_transport signature is `(model, system_prompt, user_message, temperature, role)` — ALL strings/scalars; NO file/image parameter exists; PLAN cannot pre-commit to Resolution A vs B vs C without empirical evidence
- **L-S395-1 full-pipeline cold-probe at STEP 0**: STEP 0.4 executes single-page vision call + EchoValidator + dataclass assembly BEFORE bulk test design; surfaces architectural blockers empirically (per L-S395-1 promoted from harness queue)
- **claude_cli_transport may need extension**: IF Resolution A chosen, claude_cli_transport signature may need NEW kwargs (e.g. `input_file: Path | None = None`); G.3 IMPL evaluates whether extension needed OR whether direct subprocess.run with custom claude CLI args bypassing claude_cli_transport entirely is the right path (preserves DD-1 ZERO-anthropic-SDK discipline even if claude_cli_transport interface extension deferred)
- **NON-BLOCKING design**: STEP 0.4 cold-probe enables empirical answer; PLAN doesn't speculate

**Adversarial alternate considered**: Pre-commit to Resolution A → REJECTED — claude CLI version may not support --input-file flag; cold-probe is the empirical answer per L-S395-1

### DD-3: EchoValidator location = packages/application/fundamental/echo_validator.py (NOT cross-BC shared)

**Decision**: EchoValidator lives at `packages/application/fundamental/echo_validator.py` (NEW; ~80 LOC core code). Same package as PdfTableExtractorPort ABC + ExtractedFinancialStatement. NOT under `packages/_shared/`.

**Rationale**:
- **Parent plan-040 § E.3 D3 verbatim**: "NEW `packages/application/fundamental/echo_validator.py` (~60-80 LOC; per Rule 16 mode #2 spec)"
- **Application-layer primitive co-located with port**: EchoValidator is consumed by ClaudeVisionPdfTableExtractor which subclasses PdfTableExtractorPort; co-location reduces cross-package import complexity
- **Karpathy P3 surgical-scope**: 1st-instance EchoValidator; cross-BC promotion deferred per AP-23 promote-on-2nd-recurrence calculus
- **`packages/_shared/` constraint**: `packages/_shared/__init__.py:1-7` requires dep-free pure-Python; EchoValidator IS pure-Python (Decimal + str manipulation only); WOULD be eligible for _shared/ IF 2nd-BC use surfaces (e.g. BC-5 News claim extraction OR BC-6 KOL recommendation parser)
- **AP-23 1st-instance HOLD**: EchoValidator is single-instance G.3; promotion calculus fires at 2nd-BC reuse per parent plan-040 § L PCG-3 candidate

**Adversarial alternate considered**: `packages/_shared/echo_validator.py` (cross-BC primitive) → REJECTED at 1st-instance (AP-23); revisit at 2nd-BC reuse

### DD-4: Rule 16 mode #2 strictness = cell-by-cell echo with tolerance=0 exact-match on Decimal

**Decision**: EchoValidator enforces **cell-by-cell** echo (NOT full-table-echo) with **tolerance=0 exact-match on Decimal** (NOT tolerance-band). Mismatch raises `EchoValidationError` HARD ERROR per Rule 16 mode #2 spec at financial-data-protocol.md:401-402.

**Canonical-form coercion BEFORE comparison** (NOT a tolerance — a coercion):
- Strip whitespace
- Normalize thousand-separator (Vietnamese "." OR US "," → empty string)
- Strip parentheses-negative wrapping ("(1.234)" → "-1.234")
- Handle Triệu-đồng (×1_000_000) / Tỷ-đồng (×1_000_000_000) unit suffixes per RM-G-4 (parent plan-040)

**Rationale**:
- **Financial-data-protocol.md:401-402 verbatim**: "Mismatch is a HARD ERROR (raise + abort; never silently coerce)" — tolerance-band would silently coerce within tolerance; tolerance=0 enforces strict invariant
- **Financial numbers are EXACT semantically**: VND-billion amounts don't have measurement uncertainty (vs scientific data where ε-tolerance is appropriate)
- **Cell-level granularity preserves diagnostic information**: when validation fails, error message names the SPECIFIC cell that failed (e.g. `EchoValidationError(cell_label='REVENUE', llm='1234567', deterministic=Decimal('1234568'))`)
- **Canonical-form coercion ≠ tolerance**: stripping whitespace + normalizing thousand-separator is BIJECTION on the underlying numeric value; tolerance=0 is enforced AFTER canonicalization

**Adversarial alternate considered**: Tolerance-band match (e.g. 0.1% tolerance) → REJECTED — silent error tolerance masks adapter bugs; financial-data-protocol.md:401 verbatim "never silently coerce"

**Adversarial alternate considered**: Full-table-echo (validate full ExtractedFinancialStatement at once) → REJECTED — loses cell-level diagnostic; harder to debug which cell failed

### DD-5: Fallback path if vision-input infeasible (K.2.b CHARTER-TIER FLAG triggered)

**Decision**: IF STEP 0.4 Probe 1/2/3 ALL fail, S399 dev writes STOP-FINDING per L-S397-2 severity-schema vocabulary (`severity: CHARTER-TIER-SURFACE`) with options menu:
- **Option (a)**: PIVOT to PNG-via-base64-text-substrate (Resolution C even if quality low) — preserves DD-1 ZERO-anthropic-SDK; cost is text-token cost which is well-understood
- **Option (b)**: DEFER G.3 to V2; G.4 dogfood proceeds with G.2-only IF G.2 ratifies winner (G.2 currently BLOCKED on RM3 real-PDF)
- **Option (c)**: AMEND anthropic_api_to_subagent memory rule scope (CHARTER-TIER — user gate required); WOULD allow direct anthropic SDK vision API call IF user accepts metered billing for vision-OCR

**Rationale**:
- **Karpathy P1 think-before-coding**: pre-author fallback options BEFORE empirical probe; main session can ratify quickly if K.2.b fires
- **L-S397-2 severity-schema vocabulary**: STOP-FINDING uses CHARTER-TIER-SURFACE (NOT ad-hoc IMPLEMENTATION-BLOCKER per S397 F4 finding)
- **Cost-budget for vision calls** (DD-6 cost ceiling): even Resolution A/B/C cost estimate (~$0.05-0.15 per call × ~3-10 calls per extract = $0.30-0.50 typical extract cost; ceiling 0.50 USD per extract)
- **NON-BLOCKING design**: PLAN doesn't speculate which fallback wins; main session decides per CHARTER-tier gate

**Adversarial alternate considered**: Pre-commit to Option (a) Resolution C → REJECTED — quality concern (base64-text-substrate may NOT yield vision-quality OCR); main session should pick per K.2.b ratification

### DD-6: Per-call cost ceiling = Decimal("0.50") USD configurable via ctor

**Decision**: ClaudeVisionPdfTableExtractor accepts `cost_ceiling_usd: Decimal = Decimal("0.50")` via ctor; per-call cost-ledger record per claude_cli_transport invocation; raises `CostBudgetExceeded` when ceiling exceeded.

**Rationale**:
- **VHM-style annual report scope**: ~80-150 pages typical; G.3 targets statement-page subset (IS+BS+CF ≈ 5-15 pages per report)
- **Per-call cost estimate**: 10 cells per statement × 1 vision call per cell-batch = ~3-10 calls per extract; per-call cost ~$0.05-0.15 (Sonnet vision rate estimate; Opus higher); typical extract cost $0.30-0.50
- **Ceiling = 0.50 USD per extract default**: prevents runaway in pathological cases (e.g. claude vision misinterprets and emits very long response); configurable via ctor for higher-cost extracts (G.4 dogfood may raise to 1.00 USD per VHM ticker)
- **Cost-ledger record per call for I-S20 calibration**: each call writes (extract_id, page_num, cells_extracted, cost_usd, wall_time_ms) row to in-memory ledger; ExtractedFinancialStatement.extraction_method='claude-vision' enables downstream querying
- **DD-6 ≠ S396 BR-6 cost cap** (validate_thesis_phase1.py:189 use-case-tier cap) — G.3 is adapter-tier per-call ceiling; orthogonal to use-case-tier cap

**Adversarial alternate considered**: NO ceiling (caller responsibility) → REJECTED — adapter-tier ceiling is principled safety net; caller may not know per-call cost estimate

**Adversarial alternate considered**: Ceiling = 1.00 USD default → REJECTED — too lenient for V0; 0.50 USD is conservative + configurable

### DD-7: ADR D-082 PROPOSED-AT-IMPL records adapter contract + EchoValidator semantics + Rule 16 mode #2 proof + vision-input resolution + cost ceiling + K.2.b resolution

**Decision**: ADR D-082 PROPOSED at `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` per parent plan-040 DD-8; ~180 LOC; 12-field schema floor per L-S389-2.

**ADR D-082 records**:
- (a) ClaudeVisionPdfTableExtractor adapter class contract (subclass PdfTableExtractorPort + 4 method implementations + source_id='claude-vision')
- (b) EchoValidator runtime invariant contract (tolerance=0 + canonical-form coercion + EchoValidationError HARD ERROR semantics)
- (c) Rule 16 mode #2 satisfaction proof (deterministic-pipeline echo: Claude vision → raw text → deterministic VND-string parser → Decimal → EchoValidator.validate(llm_value, deterministic_value) → ExtractedFinancialStatement.raw_cells)
- (d) Vision-input shape resolution per STEP 0.4 probe outcome (Resolution A/B/C/D)
- (e) Per-call cost ceiling (DD-6 default + configuration semantics)
- (f) STOP-AND-ASK CHARTER-TIER FLAG resolution IF K.2.b fired (records main session pick from Options (a)/(b)/(c))
- (g) Chain D-080 → D-082 ABC subclass pattern continuity
- (h) Adversarial alternates rejected with rationale (per DD-1..DD-9 above)
- (i) AP-7 named revisit triggers per deferral
- (j) Source-evidence cite chain (≥3 source files per claim per I-S2)
- (k) Severity = MEDIUM (IMPL-tier; AUTO-ACCEPT at session close per severity-schema; no CHARTER cool-down)
- (l) Supersedes / depends_on / superseded_by fields per 12-field schema

**Rationale**:
- **Parent plan-040 DD-8 verbatim**: "Each sub-plan IMPL author creates own PROPOSED ADR at IMPL-tier; specifically G.3 IMPL → ADR D-082 PROPOSED"
- **L-S389-2 12-field schema floor** from harness sweep N+1 S389: each ADR uses 12-field minimum schema
- **D-082 number** per dispatch brief: D-080 ACCEPTED (G.1) + D-081 reserved by S396 (per current-execution.md:150) + D-082 next-free

**Adversarial alternate considered**: Defer ADR to G.4 IMPL → REJECTED per parent plan-040 DD-8 explicit "G.3 IMPL → ADR D-082 PROPOSED"

### DD-8: ZERO pyproject.toml dep addition THIS sub-plan — claude CLI is system-installed; pdfplumber deferred to G.2 ratification

**Decision**: NO new pyproject.toml dep added by G.3. Claude CLI substrate is system-installed (claude executable on PATH). PDF→PNG conversion (if needed for Resolution A/B):
- Prefer system tooling (e.g. `pdftoppm` from poppler-utils if installed; STEP 0.4 cold-probe checks `which pdftoppm`)
- DO NOT unilaterally add pdfplumber to pyproject.toml — G.2 sub-plan 042 has ratification authority for pdfplumber dep addition per parent plan-040 § E.2 D3 + D-061 add-with-rationale doctrine
- IF system tooling unavailable AND G.2 has NOT yet ratified pdfplumber → DD-5 fallback (b) DEFER G.3 to V2

**Rationale**:
- **Parent plan-040 § E.3 verbatim**: "~250-350 LOC including tests; NO new external dep — uses existing claude CLI substrate"
- **G.2 ratification authority**: G.2 sub-plan 042 D3 ratifies pyproject.toml dep addition for winner library per D-061 + parent plan-040 § E.2; G.3 must NOT preempt
- **Karpathy P2 simplicity**: no speculative dep addition; defer to empirical need

**Adversarial alternate considered**: Add pdfplumber to pyproject.toml at G.3 → REJECTED per parent plan-040 § E.2 G.2-ratification-authority; cross-sub-plan coordination violation

### DD-9: Test path convention = tests/unit/infrastructure/fundamental/ + tests/unit/application/fundamental/ (NEW directory convention per dispatch brief)

**Decision**: Tests live at `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` + `tests/unit/application/fundamental/test_echo_validator.py` per dispatch brief § F explicit. NEW directory tree `tests/unit/` introduced by this sub-plan.

**Rationale**:
- **Dispatch brief § F explicit**: "tests `tests/unit/application/fundamental/test_echo_validator.py` + `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW)"
- **L-S392-1 dispatch-brief precedence**: dispatch brief asserts specific NEW paths; architect ratifies via DD per L-S392-1 doctrine
- **Coordination check vs existing convention**: existing pattern at `packages/application/fundamental/test_pdf_table_extractor_port.py` is tests-alongside-code; THIS sub-plan introduces `tests/unit/` tree for G.3; future sub-plans (G.2 042 + G.4 044) decide whether to follow new convention OR stay with tests-alongside-code; not a binding cross-sub-plan precedent

**Adversarial alternate considered**: Tests-alongside-code (Option B per STEP 0.5.b) → REJECTED per dispatch brief § F explicit; L-S392-1 dispatch-brief precedence

---

## E. Sub-track decomposition (D1-D5)

### E.1 Sub-track D1 — ClaudeVisionPdfTableExtractor adapter

**File**: `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW file in existing directory; ~250 LOC core code; LOC ceiling ≤300 per L-S397-1 core-code category)

**Tasks**:

1. Author class `ClaudeVisionPdfTableExtractor(PdfTableExtractorPort)` with:
   - `source_id: ClassVar[str] = "claude-vision"` (enforced non-empty by PdfTableExtractorPort.__init_subclass__ at :111-131)
   - `__init__(self, *, cost_ceiling_usd: Decimal = Decimal("0.50"), model: str = "claude-sonnet-4-6")` ctor with per-call cost ceiling + model selection
   - `extract(self, pdf_source: PdfSource) -> ExtractedFinancialStatement` — primary method:
     - Determine target pages (V0 = all pages; G.4 may restrict to IS+BS+CF subset)
     - For each page: render PDF page → PNG (per STEP 0.4 Resolution A/B/C path)
     - Invoke `claude_cli_transport(model, system_prompt=<vision-OCR-prompt>, user_message=<image-MIME or path>, temperature=0.0)` per chosen Resolution
     - Parse response → raw_cells dict (adapter-specific label → raw string)
     - Compute deterministic re-parsed Decimal value per cell via inline VND-string parser (minimal version; G.2 ships canonical)
     - Invoke `EchoValidator.validate(llm_value, deterministic_value, cell_label=<label>)` per cell — raises EchoValidationError HARD ERROR on mismatch
     - Track per-call cost from claude_cli_transport return tuple (input_tokens, output_tokens); compute cost_usd via _compute_cost (mirror claude_llm_perspective_adapter.py:80-87 pattern)
     - Raise `CostBudgetExceeded` if cumulative cost exceeds cost_ceiling_usd
     - Construct ExtractedFinancialStatement with extraction_method="claude-vision" + extractor_version=<semver from D2> + source_pdf_page + source_pdf_sha256 + extracted_at=datetime.now(UTC) (D-059 R1 tz-aware)
   - `supports(self, pdf_path: Path) -> bool` — return True for any .pdf file path (G.3 attempts vision OCR on all PDFs; failure surfaces as PdfTableExtractorError; does NOT pre-discriminate digital vs scanned)
   - `name(self) -> str` — return f"claude-vision v{self.extractor_version()}"
   - `extractor_version(self) -> str` — return "0.1.0" semver constant
2. Module docstring with: (a) anthropic_api_to_subagent memory-rule citation + (b) D-080 ACCEPTED ABC contract reference + (c) D-072 BC-5 + D-074 BC-8 transport-flip precedent reference + (d) MUST/MUST NOT clauses (MUST: subclass PdfTableExtractorPort / use claude_cli_transport only / invoke EchoValidator.validate per cell; MUST NOT: import anthropic / use ANTHROPIC_API_KEY / silently coerce LLM-claimed-value vs deterministic per Rule 16 mode #2)
3. Type hints: `from __future__ import annotations`; `from decimal import Decimal`; `from datetime import UTC, datetime`; `from typing import ClassVar`; `from pathlib import Path`; `from packages.application.fundamental.pdf_table_extractor_port import PdfTableExtractorPort`; `from packages.application.fundamental.pdf_source import PdfSource`; `from packages.application.fundamental.extracted_financial_statement import ExtractedFinancialStatement`; `from packages.application.fundamental.echo_validator import EchoValidator`; `from packages.infrastructure.analysis.subagent_transport import claude_cli_transport`

**Verify**: mypy --strict green + ruff clean + ABC subclass-instantiation OK (D4 V6 smoke per S397 V6 pattern)

**LOC ceiling**: ≤300 core code (per L-S397-1 distinguish core vs docstring); target ~250

**DoD**:
- [ ] File exists at exact path
- [ ] ClaudeVisionPdfTableExtractor subclasses PdfTableExtractorPort cleanly (no TypeError at class-definition; source_id non-empty)
- [ ] 4 abstract methods implemented (extract + supports + name + extractor_version)
- [ ] ZERO `import anthropic` in this file (verifier grep-asserts at V3)
- [ ] ZERO `ANTHROPIC_API_KEY` reference (verifier grep-asserts at V3)
- [ ] claude_cli_transport imported + invoked per STEP 0.4 chosen Resolution
- [ ] EchoValidator.validate invoked per cell (raises EchoValidationError on mismatch)
- [ ] cost_ceiling_usd ctor kwarg with Decimal("0.50") default
- [ ] mypy --strict green
- [ ] ruff clean

**Blocks**: D4 tests (test imports adapter); D5 ADR D-082 records this contract

**Depends on**: D2 (EchoValidator must exist before D1 extract() invokes validate()); D3 (STEP 0.4 cold-probe outcome drives D1 implementation shape — Resolution A/B/C)

### E.2 Sub-track D2 — EchoValidator + EchoValidationError

**File**: `packages/application/fundamental/echo_validator.py` (NEW; ~80 LOC core code; LOC ceiling ≤120 per L-S397-1)

**Tasks**:

1. Author `EchoValidationError(ValueError)` exception class:
   - Fields: `cell_label: str` + `llm_value: str` + `deterministic_value: Decimal`
   - `__init__` formats message as `f"EchoValidator mismatch on cell {cell_label!r}: LLM-claimed {llm_value!r} != deterministic {deterministic_value} (Rule 16 mode #2 HARD ERROR per financial-data-protocol.md:401-402)"`
2. Author `EchoValidator` class with single classmethod `validate(cls, llm_value: str, deterministic_value: Decimal, *, cell_label: str) -> None`:
   - Helper function `_canonicalize_numeric_string(raw: str) -> Decimal`:
     - Strip leading/trailing whitespace
     - Detect parentheses-negative wrapping (e.g. "(1.234)" → "-1.234"); strip parens + prepend "-"
     - Detect Triệu-đồng suffix (case-insensitive; e.g. "1.234 Triệu đồng" → Decimal("1.234") * Decimal("1_000_000"))
     - Detect Tỷ-đồng suffix (e.g. "1.234 Tỷ đồng" → Decimal("1.234") * Decimal("1_000_000_000"))
     - Normalize thousand-separator: Vietnamese "." OR US "," → empty string (per RM-G-4 parent plan-040 Vietnamese-locale parser)
     - Return Decimal(canonicalized_string)
   - `validate()` body:
     - Coerce `llm_value` via `_canonicalize_numeric_string()` → `llm_decimal`
     - Compare `llm_decimal == deterministic_value` (exact-match; tolerance=0)
     - If mismatch → raise `EchoValidationError(cell_label, llm_value, deterministic_value)` HARD ERROR per Rule 16 mode #2 spec at financial-data-protocol.md:401-402
     - If match → return None (success)
3. Module docstring with: (a) Rule 16 mode #2 spec citation at financial-data-protocol.md:396-402 + (b) parent plan-040 § E.3 D3 + (c) MUST/MUST NOT clauses (MUST: tolerance=0 exact-match / HARD ERROR on mismatch; MUST NOT: silently coerce / tolerance-band match)
4. Type hints: `from __future__ import annotations`; `from decimal import Decimal`

**Verify**: mypy --strict green + ruff clean + 10+ unit tests per D4 (tolerance=0 + canonical-form coercion + HARD ERROR)

**LOC ceiling**: ≤120 core code; target ~80

**DoD**:
- [ ] File exists at exact path
- [ ] EchoValidator.validate(llm_value, deterministic_value, cell_label) signature matches Rule 16 mode #2 spec contract
- [ ] tolerance=0 exact-match enforced (NOT tolerance-band)
- [ ] EchoValidationError raised HARD ERROR on mismatch (raise + abort per financial-data-protocol.md:401-402)
- [ ] Canonical-form coercion handles whitespace + parens-negative + Triệu/Tỷ-đồng + thousand-separator
- [ ] mypy --strict green
- [ ] ruff clean

**Blocks**: D1 ClaudeVisionPdfTableExtractor extract() invokes EchoValidator.validate()

**Depends on**: NONE (independent of D3 STEP 0.4 cold-probe outcome; EchoValidator semantics are vision-input-shape agnostic)

### E.3 Sub-track D3 — STEP 0.X vision-input feasibility cold-probe execution + write-up

**Files**: NO new file (cold-probe execution + write-up to observation `agent-workspace/memory/observations/sandwich-dev-S399-g3-claude-vision-adapter.md` STEP 0 section); IF K.2.b fires → also writes `human-workspace/notifications/STOP-FINDING-S399-claude-vision-input-infeasible.md`

**Tasks**:

1. Execute STEP 0.4 3-probe sequence per § C.0.4:
   - Probe 1: `claude -p --help` → grep for vision-input flags
   - Probe 2: `@<path>` syntax test with synthetic test.png
   - Probe 3: base64 data-URI test
2. Execute STEP 0.4 full-pipeline cold-probe (per L-S395-1):
   - Construct synthetic minimal 1-page PDF with 3 cells
   - Render PDF page → PNG (if Resolution A or B path)
   - Invoke ClaudeVisionPdfTableExtractor MINIMAL-SHAPE probe call (NOT D1 full implementation; just enough to validate round-trip works)
   - Invoke EchoValidator.validate on each cell
   - Assemble ExtractedFinancialStatement
3. Document outcome in observation STEP 0 section:
   - Probe 1/2/3 exact commands + outputs (verbatim verbatim subprocess.run output snippets)
   - Resolution A/B/C/D ratification with rationale
   - K.2.b CHARTER-TIER FLAG status (NOT-FIRED if any Resolution works; FIRED if all probes fail)
4. IF K.2.b fires → write STOP-FINDING per L-S397-2 severity-schema vocabulary:
   - File: `human-workspace/notifications/STOP-FINDING-S399-claude-vision-input-infeasible.md`
   - Frontmatter: `severity: CHARTER-TIER-SURFACE` + `requires_human_decision: true`
   - Body: Probe outputs + DD-5 fallback options menu
   - S399 dev PAUSES pending main session ratification per autonomous_continue_no_self_pause carve-out

**Verify**: STEP 0.X observation section is complete + verifier at S400 V10 K.2.b non-firing attestation (or K.2.b fired-with-correct-STOP-FINDING attestation)

**LOC ceiling**: N/A (no new file; observation write-up only)

**DoD**:
- [ ] STEP 0.4 Probes 1/2/3 executed + outputs recorded
- [ ] Resolution A/B/C/D ratified in observation
- [ ] Full-pipeline cold-probe round-trip executed (if any Resolution A/B/C works)
- [ ] K.2.b CHARTER-TIER FLAG status documented (NOT-FIRED or FIRED-with-STOP-FINDING)
- [ ] IF FIRED → STOP-FINDING file exists with CHARTER-TIER-SURFACE severity vocabulary per L-S397-2

**Blocks**: D1 (Resolution drives D1 implementation shape); D4 (mock shape depends on Resolution); D5 (ADR D-082 records resolution)

**Depends on**: STEP 0.1-0.3 (transport API surface + Rule 16 spec + ABC contract re-verification)

### E.4 Sub-track D4 — Unit tests at tests/unit/{infrastructure,application}/fundamental/

**Files**:
- `tests/unit/infrastructure/fundamental/__init__.py` (NEW ~1 LOC empty)
- `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` (NEW ~150-200 LOC; ≥15 test cases)
- `tests/unit/application/fundamental/__init__.py` (NEW ~1 LOC empty)
- `tests/unit/application/fundamental/test_echo_validator.py` (NEW ~100-150 LOC; ≥10 test cases)

**Tasks**:

1. Author `test_claude_vision_pdf_adapter.py` (≥15 test cases):
   - Test: ClaudeVisionPdfTableExtractor subclass-instantiation OK (source_id='claude-vision'; 4 methods implemented; V6 smoke per S397 V6 pattern)
   - Test: source_id ClassVar = "claude-vision" enforced
   - Test: supports() returns True for .pdf paths
   - Test: name() returns expected format
   - Test: extractor_version() returns semver string
   - Test: extract() invokes claude_cli_transport (mocked via unittest.mock.patch per packages/infrastructure/analysis/test_subagent_transport.py:10-11 pattern)
   - Test: extract() invokes EchoValidator.validate per cell
   - Test: extract() returns ExtractedFinancialStatement with extraction_method='claude-vision'
   - Test: extract() raises CostBudgetExceeded when cost > cost_ceiling_usd
   - Test: extract() raises EchoValidationError when LLM-claimed != deterministic-parsed
   - Test: extract() populates extracted_at tz-aware (D-059 R1)
   - Test: extract() populates source_pdf_sha256 from PdfSource
   - Test: extract() populates raw_cells non-empty
   - Test: ZERO `import anthropic` in adapter module (assert via importlib + ast.parse)
   - Test: ctor accepts custom cost_ceiling_usd + model (configurable)
2. Author `test_echo_validator.py` (≥10 test cases):
   - Test: validate() returns None on exact-match (e.g. "1234567" + Decimal("1234567"))
   - Test: validate() raises EchoValidationError on mismatch (e.g. "1234567" + Decimal("1234568"))
   - Test: validate() handles whitespace coercion ("  1234567  " == Decimal("1234567"))
   - Test: validate() handles Vietnamese thousand-separator ("1.234.567" == Decimal("1234567"))
   - Test: validate() handles US thousand-separator ("1,234,567" == Decimal("1234567"))
   - Test: validate() handles parens-negative ("(1234)" == Decimal("-1234"))
   - Test: validate() handles Triệu-đồng suffix ("1.234 Triệu đồng" == Decimal("1234000000"))
   - Test: validate() handles Tỷ-đồng suffix ("1.234 Tỷ đồng" == Decimal("1234000000000"))
   - Test: EchoValidationError exposes cell_label + llm_value + deterministic_value fields
   - Test: tolerance=0 enforced (no tolerance-band; e.g. "1234567" vs Decimal("1234567.01") raises)
3. Test fixture strategy: REUSE `tests/fixtures/pdf/` from S394 D4 IF synthetic placeholder PDFs suffice for D1 mock test; ELSE generate minimal-PDF in-test per `packages/application/fundamental/test_extracted_financial_statement.py:93-100` pattern

**Verify**: pytest tests/unit/ passes ALL tests (target ≥25 test cases combined); mypy --strict green; ruff clean

**LOC ceiling**: ≤250 tests combined (per L-S397-1 distinguish test category); target ~200; ≥25 test cases minimum

**Firing tests budget**: N/A (no new hooks shipped this sub-plan; product substrate only)

**DoD**:
- [ ] Both test files exist + pytest green (≥25 test cases pass)
- [ ] ZERO regressions on existing pytest baseline (1127 PASS + 1 skip per S394 dev observation)
- [ ] Mocked subprocess.run pattern per existing test_subagent_transport.py
- [ ] mypy --strict green on test files
- [ ] ruff clean
- [ ] tests/unit/ new directory created with __init__.py files

**Blocks**: D5 ADR D-082 records test coverage

**Depends on**: D1 (test imports ClaudeVisionPdfTableExtractor); D2 (test imports EchoValidator); D3 (test mock shape depends on STEP 0.4 Resolution)

### E.5 Sub-track D5 — ADR D-082 PROPOSED + wc -l attestation + dispatch handoff

**Files**:
- `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` (NEW ~180 LOC)

**Tasks**:

1. Author ADR D-082 per parent plan-040 DD-8 + L-S389-2 12-field schema floor:
   - id: D-082
   - title: "PdfTableExtractorPort Claude vision adapter + EchoValidator Rule 16 mode #2 gate"
   - status: PROPOSED (AUTO-ACCEPT at S399 close per severity-schema; no CHARTER cool-down unless K.2.b fired with CHARTER-tier resolution)
   - severity: MEDIUM (IMPL-tier; or CHARTER-TIER-SURFACE if K.2.b fired and Option (c) charter-amendment chosen)
   - date: 2026-05-?? (S399 IMPL session date)
   - context: cite parent plan-040 § E.3 + this sub-plan § D DDs + D-080 ACCEPTED ABC contract + D-072 BC-5 + D-074 BC-8 transport-flip precedents
   - decision: cite DD-1 claude_cli_transport substrate + DD-2 vision-input shape resolution per STEP 0.4 + DD-3 EchoValidator location + DD-4 tolerance=0 + DD-5 fallback path + DD-6 per-call cost ceiling + DD-7 ADR landing + DD-8 zero-pyproject-dep + DD-9 test path convention
   - rationale: cite anthropic_api_to_subagent memory rule + Rule 16 mode #2 spec + L-S395-1 full-pipeline cold-probe + Karpathy P2/P3 + parent plan-040 binding decisions
   - alternatives_considered: cite adversarial alternates rejected per DD-1..DD-9 above
   - consequences: cite (a) G.4 sub-plan 044 dispatch consumes G.3 adapter + (b) cross-BC EchoValidator promotion DEFERRED per AP-23 1st-instance HOLD + (c) DD-5 fallback resolution IF K.2.b fired
   - source_evidence: ≥3 citations per claim (e.g. financial-data-protocol.md:396-402, subagent_transport.py:144-222, pdf_table_extractor_port.py:93-185)
   - depends_on: D-080 (ABC contract) + D-072 (BC-5 transport-flip) + D-074 (BC-8 transport-flip) + D-065 (Rule 16 numeric discipline) + D-059 (Python determinism) + D-050 (anthropic_api_to_subagent CHARTER)
   - supersedes: NONE (new ADR)
   - superseded_by: NONE (active)
   - revisit_trigger: per AP-7 named: (a) claude CLI vision-input flag deprecated → ADR D-082-V2 + (b) per-call cost ceiling exceeded ≥2× in G.4 → DD-6 raise + (c) EchoValidator 2nd-BC reuse → promote to packages/_shared/ + (d) Rule 16 mode #2 tolerance discipline challenged by edge case
2. wc -l attestation per L-S389-1 exact-integer discipline: record exact LOC for each new file at session end in observation (drop ~ prefix)
3. Dispatch handoff: observation file at `agent-workspace/memory/observations/sandwich-dev-S399-g3-claude-vision-adapter.md` summarizes (a) D1-D5 DoD per § F + (b) STEP 0.4 Resolution outcome + (c) K.2.b CHARTER-TIER FLAG status (NOT-FIRED OR FIRED-with-STOP-FINDING) + (d) G.4 sub-plan 044 dispatch-ready signal for main session post-S400 verifier PASS

**Verify**: ADR file lints + ≥12 fields present + ≥3 source_evidence cites per claim

**LOC ceiling**: ≤220 ADR; target ~180

**DoD**:
- [ ] ADR D-082 exists at exact path
- [ ] ≥12-field schema satisfied
- [ ] ≥3 source_evidence cites per major claim
- [ ] AP-7 revisit_triggers named
- [ ] Observation file written with wc -l attestation per L-S389-1
- [ ] Session log written per CLAUDE.md § Session Protocol End

**Blocks**: NONE (D5 is terminal in DAG; final ratification)

**Depends on**: D1 + D2 + D3 + D4 (records all sub-track outcomes)

---

## F. File scope (BINDING — S399 IMPL session is AUTHORIZED to touch only these files)

### F.1 NEW files (G.3 IMPL D1-D5 creates these)

| Path | Owner | LOC budget (core / total) | Sub-track |
|---|---|---|---|
| `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` | NEW | ~250 core / ≤300 total | D1 |
| `packages/application/fundamental/echo_validator.py` | NEW | ~80 core / ≤120 total | D2 |
| `tests/unit/infrastructure/fundamental/__init__.py` | NEW | ~1 LOC empty | D4 |
| `tests/unit/infrastructure/fundamental/test_claude_vision_pdf_adapter.py` | NEW | ~150-200 tests / ≤250 total | D4 |
| `tests/unit/application/fundamental/__init__.py` | NEW | ~1 LOC empty | D4 |
| `tests/unit/application/fundamental/test_echo_validator.py` | NEW | ~100-150 tests / ≤180 total | D4 |
| `agent-workspace/memory/decisions/082-pdf-claude-vision-adapter-and-echo-validator.md` | NEW | ~180 ADR / ≤220 total | D5 |
| `agent-workspace/memory/observations/sandwich-dev-S399-g3-claude-vision-adapter.md` | NEW (observation per session-protocol) | ~150 / ≤200 total | D5 |
| `agent-workspace/memory/sessions/2026-05-??-session-399.md` | NEW (session log per CLAUDE.md § Session Protocol End) | ~80 / ≤100 total | D5 |
| `human-workspace/notifications/STOP-FINDING-S399-claude-vision-input-infeasible.md` | CONDITIONAL (only if K.2.b fires per § J) | ~80 / ≤100 total | D3 |
| `agent-workspace/memory/.planner-stats.tsv` | APPEND-ONLY (per planner-feedback-loop.sh post-harness-sweep S388 D1) | +1 row | (auto via hook) |

**Total NEW production LOC (core code)**: ~330 (well within Karpathy P3 ≤500 LOC ceiling per parent plan-040 binding-decision; ADR + observation + session log + tests = orchestration overhead per L-S397-1 per-category ceilings)

**Total NEW LOC (all files combined)**: ~960 typical (matches plan-041 ~720 LOC envelope per dispatch brief discipline guidance "emulate plan-041 for sub-plan size/shape discipline" — within +/- 30% envelope)

### F.2 MODIFIED files (NONE — this sub-plan adds NEW substrate; ZERO touch to existing)

- ZERO touch to `packages/domain/fundamental/**`
- ZERO touch to `packages/application/fundamental/pdf_table_extractor_port.py` (D-080 ACCEPTED immutable)
- ZERO touch to `packages/application/fundamental/pdf_source.py` (D-080 ACCEPTED immutable)
- ZERO touch to `packages/application/fundamental/extracted_financial_statement.py` (D-080 ACCEPTED immutable)
- ZERO touch to `packages/application/fundamental/__init__.py` (UNCHANGED; G.3 may need to update __all__ to export EchoValidator + EchoValidationError IF cross-module import discipline requires; defer to S399 dev judgment)
- ZERO touch to `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (UNCHANGED per Karpathy P3 backward-compat)
- ZERO touch to `packages/infrastructure/fundamental/sqlite_fundamental_repository.py` (UNCHANGED; G.4 integrates)
- ZERO touch to `packages/infrastructure/analysis/subagent_transport.py` (existing claude_cli_transport substrate; G.3 consumes UNCHANGED)
- ZERO touch to `packages/application/news/**` (D-066 CrawlerAdapter source pattern reference; not modified)
- ZERO touch to `packages/_shared/**` (DD-3 + DD-8 — _shared not used; pdfplumber dep deferred to G.2)
- ZERO touch to `apps/cli/**` (existing 19+ CLI scripts UNCHANGED; no new CLI in G.3; G.4 sub-plan adds ingest_pdf_fundamentals.py)
- ZERO touch to `apps/cli/bench/**` (G.1 bake-off probe UNCHANGED)
- ZERO touch to `apps/crawlers/cafef_html_to_md.py` (BC-5 stays HTML-route per parent plan-040 DD-5)
- ZERO touch to any other BC (BC-1 / BC-3 / BC-4 / BC-5 / BC-6 / BC-7 / BC-8 / BC-9 per parent plan-040 § F.3)
- ZERO touch to `pyproject.toml` (per DD-8 — claude CLI is system-installed; no new Python dep)
- ZERO touch to `PROJECT_CHARTER.md` (hard rule)
- ZERO touch to `agent-workspace/constitution/**` (hard rule)
- ZERO touch to S396 in-flight file scope per dispatch brief explicit OFF-LIMITS list
- ZERO touch to `tests/fixtures/pdf/**` (REUSE G.1 fixtures READ-ONLY; do NOT modify SHA256.txt or expected_cells)
- ZERO touch to `packages/application/fundamental/test_*.py` (G.1 D4 tests UNCHANGED; new tests live at tests/unit/* per DD-9)
- ZERO touch to `human-workspace/**` EXCEPT conditional `human-workspace/notifications/STOP-FINDING-S399-*.md` IF K.2.b fires

### F.3 ADDITIONS allowed (per harness state-marker writes per planner-feedback-loop.sh D1 promotion at S388)

- `agent-workspace/memory/.planner-stats.tsv` — APPEND ROW (auto via hook per S388 D1 promotion); not a manual touch

---

## G. Sub-track DoDs (measurable per-STEP criteria) + LOC ceilings per category (per L-S397-1)

### G.1 Per-sub-track DoD criteria

**D1 DoD**: see § E.1 DoD checklist (10 criteria including ZERO anthropic import + claude_cli_transport invocation + EchoValidator.validate per cell + cost_ceiling_usd ctor)

**D2 DoD**: see § E.2 DoD checklist (7 criteria including tolerance=0 + HARD ERROR semantics + canonical-form coercion)

**D3 DoD**: see § E.3 DoD checklist (5 criteria including STEP 0.4 Probes executed + Resolution ratified + K.2.b status documented)

**D4 DoD**: see § E.4 DoD checklist (6 criteria including ≥25 test cases + zero regression + ZERO `import anthropic` assertion)

**D5 DoD**: see § E.5 DoD checklist (6 criteria including ≥12-field schema + observation with wc -l attestation)

### G.2 pytest count budget

- D4 minimum: ≥25 test cases combined (≥15 ClaudeVisionPdfTableExtractor + ≥10 EchoValidator)
- Existing pytest count baseline at S398 PLAN authoring: 1127 PASS + 1 skip (per S394 dev observation)
- S399 dev runs `pytest --collect-only -q | tail -1` at session entry; records baseline; final count = baseline + ≥25 minimum = ≥1152 (pre-S396 baseline; S396 may have added tests)
- pytest must pass at session end (per Charter Principle 11 + Tier 1 deterministic gate)

### G.3 Firing-test budget

- NEW hooks: 0 (this sub-plan ships product substrate ONLY per parent plan-040 hard_rules "no harness/hook changes")
- Firing-test mandate per Charter Principle 11 IF a hook is shipped: N/A
- Firing-test budget: 0

### G.4 LOC ceiling per STEP (per L-S397-1 distinguish core code vs docstring vs test vs fixture vs ADR)

- D1 core code: ≤300 LOC (target ~250); docstring overhead allowed +50-80 LOC; total file ≤380
- D2 core code: ≤120 LOC (target ~80); docstring overhead allowed +30-50 LOC; total file ≤170
- D3 cold-probe: N/A (no new file; observation write-up only)
- D4 test code: ≤250 LOC combined (target ~200); ≥25 test cases
- D5 ADR: ≤220 LOC (target ~180)
- **Total NEW core code** (D1 + D2): ~330 well within Karpathy P3 ≤500 LOC ceiling per parent plan-040 binding-decision

### G.5 Drift discipline (L-S389-1 + L-S397-1 carry-forward)

Per L-S389-1 wc -l exact-integer attestation discipline + L-S397-1 per-category ceiling promote candidate:

- S399 dev records EXACT integer LOC per new file at session end (`wc -l` per file; drop ~ prefix per L-S389-1)
- Records in observation under "Files created + LOC" section
- LOC overage vs § G.4 ceiling per-category = FLAG in observation; defer to verifier S400 to assess Karpathy P3 surgical-scope discipline + L-S397-1 per-category ceiling discipline
- ≤5% LOC overage acceptable per-category; >5% triggers SPLIT-or-justify discussion (cite L-S397-1 distinguishing core vs docstring vs test rationale)

---

## H. Risks + Mitigations (RM1 through RM5; per dispatch brief § H)

### H.1 RM1 — K.2.b CHARTER-TIER FLAG fires (claude CLI vision-input infeasibility)

- **Likelihood**: MEDIUM-HIGH (parent plan-040 § C.0.5 OPEN QUESTION explicitly named this; current claude_cli_transport signature has NO file/image parameter per STEP 0.1.a VBW finding)
- **Impact**: HIGH (G.3 sub-plan blocks; G.4 dogfood may need to proceed G.2-only IF G.2 ratifies winner)
- **Mitigation**:
  - **Mitigation 1**: STEP 0.4 cold-probe EMPIRICALLY surfaces infeasibility BEFORE bulk implementation (per L-S395-1 full-pipeline cold-probe doctrine); detects K.2.b at STEP 0 vs at D1 implementation surprise
  - **Mitigation 2**: DD-5 pre-authored fallback path with 3 options (PNG-via-base64-text-substrate / DEFER G.3 to V2 / CHARTER amend memory rule scope) — main session can ratify quickly via K.2.b STOP-AND-ASK
  - **Mitigation 3**: STOP-FINDING uses L-S397-2 severity-schema vocabulary (CHARTER-TIER-SURFACE; NOT ad-hoc IMPLEMENTATION-BLOCKER per S397 F4 finding); standard severity routing applies
  - **Mitigation 4**: ADR D-082 records K.2.b resolution per AP-7 named revisit trigger (claude CLI vision flag added in future → re-enable G.3)

### H.2 RM2 — claude_cli_transport API surface changed since S375/S378

- **Likelihood**: LOW-MEDIUM (subagent_transport.py shipped S375 + ratified at D-072 BC-5; D-074 BC-8 added per-role timeout override at S378 per :62-64; no major signature change since)
- **Impact**: MEDIUM (G.3 adapter implementation breaks if signature drifted)
- **Mitigation**:
  - **Mitigation 1**: STEP 0.1.a re-verification at S399 dev session entry confirms current signature `(model, system_prompt, user_message, temperature, role=None) -> tuple[str, int, int]` matches expectation
  - **Mitigation 2**: D1 adapter implementation uses keyword arguments (NOT positional) for forward compat
  - **Mitigation 3**: D4 tests use unittest.mock.patch on `claude_cli_transport` (NOT `subprocess.run`) — mock at adapter interface boundary; tests fail loudly if signature changed

### H.3 RM3 — EchoValidator over-strict false-positive (Rule 16 mode #2 may reject valid LLM outputs due to formatting noise)

- **Likelihood**: HIGH (LLM output may include extra commas, decimal formatting variants, or whitespace not captured by canonical-form coercion)
- **Impact**: MEDIUM (false-positive aborts extraction; surfaces as PdfTableExtractorError; user-visible failure)
- **Mitigation**:
  - **Mitigation 1**: DD-4 canonical-form coercion comprehensively handles known VN-locale variants (whitespace + parens-negative + Vietnamese "." OR US "," thousand-separator + Triệu/Tỷ-đồng unit suffixes per RM-G-4 parent plan-040 Vietnamese-locale parser)
  - **Mitigation 2**: D4 tests include ≥10 EchoValidator unit tests covering edge cases (parens-negative + Triệu-đồng + multiple thousand-separator styles + leading/trailing whitespace)
  - **Mitigation 3**: IF G.4 dogfood surfaces false-positive pattern → AP-7 revisit trigger named in ADR D-082 (extend canonical-form coercion via D-082-V2 amendment; do NOT relax tolerance from 0)
  - **Mitigation 4**: EchoValidationError message includes `llm_value` + `deterministic_value` + `cell_label` for diagnostic; user can adjust adapter prompt OR add canonical-form rule

### H.4 RM4 — Cost-budget for Claude vision calls (per-page = 1 vision request; gold-set 2 PDFs × ~50 pages = ~100 calls)

- **Likelihood**: HIGH (VHM annual report ~80-150 pages; G.3 targets statement-page subset ~5-15 pages; per-call cost $0.05-0.15; gold-set 2 docs × 10 cells/doc × 1 call/cell = ~20 calls per gold-set run)
- **Impact**: MEDIUM (G.3 IMPL session cost; G.4 dogfood cost runaway risk)
- **Mitigation**:
  - **Mitigation 1**: DD-6 per-call cost ceiling Decimal("0.50") USD default raises CostBudgetExceeded; configurable via ctor
  - **Mitigation 2**: G.3 STEP 0.X cold-probe uses MINIMAL synthetic 1-page PDF (3 cells) → ~3 vision calls ~$0.45; total STEP 0.X cost < $1.00
  - **Mitigation 3**: G.3 D4 tests use MOCKED subprocess.run (unittest.mock.patch per test_subagent_transport.py:10-11) — ZERO real claude CLI calls in test suite; D4 is cost-free
  - **Mitigation 4**: G.4 sub-plan 044 dogfood budget envelope ~$5-10 per ticker per parent plan-040 RM-G-7 mitigation; defer real cost to G.4 dogfood not G.3 IMPL
  - **Mitigation 5**: ADR D-082 records actual STEP 0.X cost + per-call cost estimate for I-S20 calibration baseline

### H.5 RM5 — Phase G-prime IMPL-only-class-additions discipline (per L-S382-1 STEP 0.X ctor-signature grep)

- **Likelihood**: LOW (DD-1 + DD-2 + DD-3 pre-specify exact class shapes; no surprise ctor patterns expected)
- **Impact**: LOW-MEDIUM (ctor pattern drift could create maintenance burden if 2nd-instance later)
- **Mitigation**:
  - **Mitigation 1**: STEP 0.X ctor-signature grep BEFORE adding ClaudeVisionPdfTableExtractor + EchoValidator classes (per L-S382-1 ctor-discipline) — S399 dev runs `Grep "class .+\(PdfTableExtractorPort\)" packages/` and `Grep "class .+Validator" packages/` at session entry; documents existing similar-class ctor patterns
  - **Mitigation 2**: DD-1 ClaudeVisionPdfTableExtractor.__init__(*, cost_ceiling_usd=Decimal("0.50"), model="claude-sonnet-4-6") uses keyword-only args (per Python best practice); mirrors claude_llm_perspective_adapter ctor shape per :32-37 dataclass pattern
  - **Mitigation 3**: DD-3 EchoValidator is classmethod (no instance state); avoids ctor-discipline question entirely
  - **Mitigation 4**: ADR D-082 records ctor pattern for AP-23 1st-instance HOLD discipline

---

## J. K.2 charter-tier surface entries (per dispatch brief § J — plan-040 K.2.b trigger inheritance)

Per parent plan-040 § K.2 inheritance: this sub-plan INHERITS K.2.b CONDITIONAL trigger; main session DECIDES via AskUserQuestion if surface as decision-blocker.

### J.1 NON-BLOCKING design recommendation (default)

This sub-plan's RECOMMENDATION: **NON-BLOCKING Phase G.3 entry**. Architect-recommended defaults chosen per DD-1/DD-2/DD-3/DD-4/DD-5/DD-6/DD-7/DD-8/DD-9. STEP 0.X STOP-AND-ASK clauses fire ONLY IF empirical evidence (STEP 0.4 cold-probe) contradicts architect-recommended defaults.

Sub-plan 043 PROCEEDS to S399 IMPL dispatch without user gate IF AND ONLY IF main session reviews this plan + accepts the 9 DDs.

### J.2 K.2.b inheritance — Claude CLI substrate vision-input feasibility (parent plan-040 § K.2.b verbatim)

Per parent plan-040 § K.2.b (trigger inheritance):

- **Trigger**: S399 dev STEP 0.4 vision-input cold-probe (per § C.0.4 3-probe sequence) reveals claude CLI substrate does NOT support PDF/image input (Probe 1 + Probe 2 + Probe 3 ALL fail) AND G.3 cannot proceed via DD-5 fallback paths (a)/(b)/(c)
- **Charter-tier-surface**: anthropic_api_to_subagent memory-rule scope question — "does the rule mandate ONLY text input substrate OR also vision substrate; if claude CLI lacks vision, does direct Anthropic SDK vision call become a permitted exception?"
- **Default if NOT fired**: G.3 ships claude CLI substrate; vision-input feasibility VERIFIED at STEP 0.4 cold-probe with Resolution A/B/C
- **Pre-stated condition for AskUserQuestion gate fire**:
  - Trigger: Probe 1 (claude -p --help) shows NO vision flags AND Probe 2 (@-syntax) treated as literal text AND Probe 3 (base64 data-URI) treated as literal string → ALL fail
  - DD-5 fallback (a) PIVOT to PNG-via-base64-text-substrate may be Resolution C IF Probe 3 succeeds even partially — IF partial success → no K.2.b fire; proceed with Resolution C path
  - K.2.b fires ONLY IF ALL 3 probes truly fail + DD-5 fallback (a)/(b) infeasible → Option (c) CHARTER amend required
- **Main session decision path**: AskUserQuestion gate Q-INT-2026-05-G-prime-2 fires IF triggered; options menu per DD-5

### J.3 Ratification path (this sub-plan)

Main session reviews + ratifies via standard parent plan-040 § K.4 path:
1. Read this sub-plan markdown
2. Verify § J FLAGS understood; NO blocking unless triggered by S399 dev STEP 0.X empirical probe
3. Commit this plan via D-060 + pre-dispatch-architect-commit-guard.sh hook
4. Dispatch S399 sandwich-dev FOCUSED_IMPL per § N sequencing
5. S399 dev STEP 0.4 fires K.2.b IF empirical probe contradicts architect-recommended default
6. IF K.2.b fires → S399 dev writes STOP-FINDING file at `human-workspace/notifications/STOP-FINDING-S399-claude-vision-input-infeasible.md` per parent plan-040 § K.2.b path + L-S397-2 severity-schema vocabulary; main session fires AskUserQuestion gate Q-INT-2026-05-G-prime-2

---

## K. Coordination paths off-limits during S399 IMPL

Per dispatch brief § F BINDING file scope + L-S345-1 surgical-scope discipline + dispatch brief explicit OFF-LIMITS list:

### K.1 OFF-LIMITS file paths (S399 IMPL session MUST NOT touch)

- `packages/domain/**` (BC-2 + all other domain UNCHANGED; G.3 adapter is application/infrastructure-layer)
- `packages/application/fundamental/pdf_table_extractor_port.py` + `pdf_source.py` + `extracted_financial_statement.py` (D-080 ACCEPTED immutable; G.3 subclasses ABC + consumes dataclasses but does NOT modify)
- `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` + `sqlite_fundamental_repository.py` (UNCHANGED per Karpathy P3 backward-compat)
- `packages/infrastructure/analysis/subagent_transport.py` (existing claude_cli_transport substrate; G.3 consumes UNCHANGED; IF Resolution A requires substrate extension, defer to D-082-V2)
- `packages/application/news/**` (D-066 CrawlerAdapter reference only; NOT modified)
- `packages/_shared/**` (DD-3 + DD-8 — _shared not used)
- `apps/cli/*.py` (existing 19+ CLI scripts UNCHANGED)
- `apps/cli/bench/**` (G.1 bake-off probe UNCHANGED)
- `apps/crawlers/cafef_html_to_md.py` (BC-5 stays HTML-route per parent plan-040 DD-5)
- Any other BC: BC-1 / BC-3 / BC-4 / BC-5 / BC-6 / BC-7 / BC-8 / BC-9
- `pyproject.toml` (per DD-8 — claude CLI is system-installed; no new dep)
- `PROJECT_CHARTER.md` (hard rule)
- `agent-workspace/constitution/**` (hard rule)
- `agent-workspace/master-plans/**` (parent plan-040 UNCHANGED; this sub-plan REFERENCES not modifies)
- `agent-workspace/session-plans/pending/040-*.md` (parent plan UNCHANGED)
- `agent-workspace/session-plans/completed/041-*.md` (G.1 sub-plan UNCHANGED)
- `agent-workspace/session-plans/pending/042-*.md` (G.2 sub-plan reserved — NONE exists yet; BLOCKED on RM3)
- `agent-workspace/session-plans/pending/044-*.md` (G.4 sub-plan reserved — NONE exists yet; BLOCKED on G.2 + G.3)
- `agent-workspace/session-plans/pending/045-*.md` + `completed/045-*.md` (S396 in-flight data-corpus operational plan — per dispatch brief explicit OFF-LIMITS)
- `agent-workspace/memory/decisions/080-*.md` (D-080 ACCEPTED; immutable)
- `agent-workspace/memory/decisions/081-*.md` (D-081 reserved by S396 — per dispatch brief explicit OFF-LIMITS)
- `packages/application/analysis/use_cases/validate_thesis_phase1.py` (S396 in-flight — per dispatch brief explicit OFF-LIMITS)
- `apps/cli/validate_thesis*.py` (S396 in-flight — per dispatch brief explicit OFF-LIMITS)
- `data/stockforge.sqlite` (S396 in-flight — per dispatch brief explicit OFF-LIMITS)
- `agent-workspace/memory/thesis-log/2026-05-17-*.md` (S396 in-flight — per dispatch brief explicit OFF-LIMITS)
- `agent-workspace/memory/cost-ledger.tsv` (S396 in-flight — per dispatch brief explicit OFF-LIMITS)
- `tests/fixtures/pdf/**` (REUSE G.1 fixtures READ-ONLY; do NOT modify SHA256.txt or expected_cells_*.json)

### K.2 PARALLEL-eligible files (S399 dev MAY touch in parallel with D3 per § A.4 PARALLEL OPPORTUNITY)

- D3 cold-probe (sequential first; produces Resolution A/B/C/D)
- D2 EchoValidator (parallel with D3 cold-probe; independent of Resolution)
- D1 ClaudeVisionPdfTableExtractor (sequential after D3 + D2)
- D4 tests (sequential after D1 + D2; mock shape depends on D3 Resolution)
- D5 ADR D-082 + observation (sequential after D1-D4; final ratification)

### K.3 SHARED-WRITE coordination (none expected)

No 2-way write collision risk — G.3 sub-plan adds NEW substrate (DISTINCT file paths from G.2 + G.4 + S396 in-flight); ZERO existing-file modification.

---

## L. Promotion candidates (per AP-7 pre-flag pattern; capture-now, evaluate at sub-plan close)

Per parent plan-040 § L pattern + AP-23 promote-or-retire calculus:

| Candidate | Source | Promotion-readiness criterion | Notes |
|---|---|---|---|
| **PCG-1**: EchoValidator runtime invariant primitive (Rule 16 mode #2 implementation) | D2 EchoValidator | If reused for ANY LLM-claimed-numeric-value gate (BC-5 News claim extraction + BC-6 KOL recommendation parser) | LIKELY 2nd-BC promote — parent plan-040 § L PCG-3 candidate; AP-23 1st-instance HOLD applied THIS sub-plan |
| **PCG-2**: vision-input-modality cold-probe protocol (3-probe sequence + full-pipeline cold-probe per L-S395-1) | D3 STEP 0.4 cold-probe | If reused for ANY future LLM-substrate-modality probe (e.g. audio input / video input / multi-image batch) | DEFER per AP-23 1st-instance HOLD; revisit if 2nd-substrate-modality probe surfaces |
| **PCG-3**: per-call cost-ledger pattern at adapter tier (Decimal-precision cost tracking per LLM invocation) | D1 ClaudeVisionPdfTableExtractor cost ceiling | If reused at G.2 (pure-Python adapter has no LLM cost; N/A) OR Phase 3 calibration adapter | DEFER per AP-23 1st-instance HOLD; not all adapters need cost ledger |
| **PCG-4**: tests/unit/ directory convention (NEW per DD-9 dispatch brief) | D4 test paths | If 2nd sub-plan adopts tests/unit/ convention (e.g. G.2 042 OR G.4 044 follows) | DEFER per AP-23 1st-instance HOLD; if 2nd sub-plan adopts → promote to cross-sub-plan template; if 2nd sub-plan stays with tests-alongside-code → retire convention |
| **PCG-5**: Rule 16 mode #2 satisfaction-by-construction proof pattern in ADR | D5 ADR D-082 mode #2 satisfaction proof section | If reused in future LLM-numeric-field ADR (BC-5 News claim extraction ADR; BC-6 KOL ADR) | LIKELY promote on 2nd-instance — formalize Rule 16 satisfaction proof template |
| **PCG-6**: CHARTER-TIER-SURFACE STOP-FINDING severity vocabulary (per L-S397-2 promote candidate from S397 verifier) | D3 STOP-FINDING IF K.2.b fires | If 2nd-instance STOP-FINDING uses standard severity-schema vocabulary | THIS sub-plan is 2nd-instance per L-S397-2 promote candidate IF K.2.b fires AND STOP-FINDING uses CHARTER-TIER-SURFACE → promote-to-template |

Sub-plan 043 STEP 5.5 (per harness sweep N+1 D6 promotion at S388) captures additional promotion candidates surfaced at S399 IMPL time. AP-23 calculus applies at sub-plan close (S400 verifier session).

---

## N. Sub-plan dispatch sequencing (per dispatch brief § N)

### N.1 What S396 (in-flight) data-corpus operational plan-045 IMPL is INDEPENDENT of

Per dispatch brief explicit OFF-LIMITS list + current-execution.md:139:

- S396 sandwich-dev executes plan-045 continuation + BR-6 cost cap fix (Option A path; raise $3 → $6) + new ADR D-081 documenting empirical $4.24 evidence + VHM re-run + optional HPG/VIC/FPT re-runs
- S396 file scope: `packages/application/analysis/use_cases/validate_thesis_phase1.py` + `apps/cli/validate_thesis*` + `data/stockforge.sqlite` + `agent-workspace/memory/thesis-log/2026-05-17-*` + `agent-workspace/memory/decisions/081-*` + `agent-workspace/memory/cost-ledger.tsv` + `agent-workspace/session-plans/pending/045-*` or `completed/045-*`
- ZERO file scope overlap with G.3 (THIS plan-043): G.3 = `packages/infrastructure/fundamental/claude_vision_pdf_adapter.py` (NEW; DISTINCT from validate_thesis_phase1.py) + `packages/application/fundamental/echo_validator.py` (NEW; DISTINCT from analysis layer) + `tests/unit/{infrastructure,application}/fundamental/` (NEW; DISTINCT from S396 paths) + ADR D-082 (DISTINCT from D-081)
- Main session can orchestrate S398 (THIS PLAN; sandwich-architect) + S396 (sandwich-dev in-flight) as 2-parallel dispatch per plan-025 DD-5 3-parallel ceiling

### N.2 What S399 sandwich-dev for plan-043 IMPL NEEDS

S399 dispatch pre-requisites:

1. **plan-043 PLAN authored + committed**: main session commits THIS plan via D-060 + pre-dispatch-architect-commit-guard.sh hook post-S398 architect output
2. **Pre-dispatch guard satisfied**: plan-043 commit (parent_plan = plan-040; sub_plan_id = 043; matches commit-guard schema)
3. **STEP 0.X STOP-AND-ASK NOT fired in S398 PLAN session**: confirmed at S398 close (no charter-tier surface FLAG triggered at PLAN-tier; only CONDITIONAL K.2.b inheritance carry-forward to S399 IMPL)
4. **G.1 sub-plan 041 SHIPPED + VERIFIED**: confirmed at S397 (ABC contract + dataclasses + D-080 ACCEPTED + merge-eligible per S397 verifier PASS)
5. **claude CLI executable on PATH**: STEP 0.1.c verifies at S399 dev session entry (claude --version)

### N.3 What G.4 unblock contract looks like (post-S400 verifier PASS)

Per parent plan-040 § N.2 + § E.4:

- **G.4 (sub-plan 044) unblock contract**: BOTH G.2 + G.3 adapters shipped + verified; G.4 CLI `apps/cli/ingest_pdf_fundamentals.py` dispatches to both via `supports(pdf) → bool` ABC pre-check + measures per-adapter accuracy on 5-document gold set (expanded from G.1's 2-document baseline)
- **G.3 contribution to G.4 unblock**: ClaudeVisionPdfTableExtractor.extract() works end-to-end on synthetic minimal-PDF via STEP 0.X cold-probe (proven at D3 ratified); G.4 dogfood will exercise on real PDFs (RM3 STOP-FINDING-S394 resolution required for real-PDF G.4; G.3 STEP 0.X-proven synthetic-PDF works does NOT require RM3 resolution)
- **G.2 contribution to G.4 unblock**: G.2 BLOCKED on RM3; G.4 may proceed G.2-INCOMPLETE (G.3-only) IF user authorizes per K.2.a inheritance OR may DEFER G.4 until G.2 unblocks per parent plan-040 § E.4 explicit "BOTH G.2 + G.3 ship"

### N.4 Sequencing summary

Per parent plan-040 § N.2 + dispatch brief § N + current state:

| Session | Plan | Type | Pre-requisite | Parallel-eligible with |
|---|---|---|---|---|
| S391 (DONE) | plan-040 | PHASE-MASTER-PLAN | Parent plan-033 § N parallel-dispatch authorization | Phase F-prime data-corpus track |
| S392 (DONE) | plan-041 | SUB-PLAN PLAN | plan-040 § N.2 sequencing | S393 (parallel plan-045 PLAN) |
| S393 (DONE) | plan-045 | OPERATIONAL PLAN | Phase F-prime CODE-DONE-DATA-PENDING + user-auth real-API budget | S392 (parallel plan-041 PLAN) |
| S394 (DONE) | plan-041 | SUB-PLAN IMPL | plan-041 PLAN committed | NONE |
| S395 (DONE) | plan-045 | OPERATIONAL IMPL | plan-045 PLAN committed; PARTIAL per cost-blocker | S394 (parallel; disjoint file scope) |
| S397 (DONE) | plan-041 G.1 | VERIFY | S394 close; PASS per S397 verifier | NONE |
| S396 (IN-FLIGHT) | plan-045 continuation | OPERATIONAL IMPL | S395 PARTIAL + user Q1=A BR-6 cap raise | S398 (THIS PLAN; disjoint file scope per § N.1) |
| **S398 (THIS PLAN)** | **plan-043** | **SUB-PLAN PLAN** | **S397 verifier PASS (G.3 dispatch UNBLOCKED)** | **S396 (in-flight; disjoint file scope per dispatch brief)** |
| S399 | plan-043 | SUB-PLAN IMPL | plan-043 PLAN committed | NONE expected (G.2 042 BLOCKED on RM3; if RM3 resolves AND G.2 PLAN dispatched in parallel, G.2 + G.3 IMPL CAN run parallel per parent plan-040 § N.2 N.4) |
| S400 | (verifier dispatch on S399 output) | VERIFY | S399 close | NONE |
| TBD (post-RM3 resolution) | plan-042 | SUB-PLAN PLAN | RM3 STOP-FINDING-S394 resolution (human downloads real VHM + HPG PDFs + annotates expected_cells_*.json) | PARALLEL with S398 OR sequential per main session orchestration |
| TBD | plan-042 | SUB-PLAN IMPL | plan-042 PLAN committed; G.1 bake-off re-runs with real PDFs to ratify winner | NONE expected |
| TBD | (verifier) | VERIFY | plan-042 IMPL close | NONE |
| TBD | plan-044 (G.4) | SUB-PLAN PLAN | BOTH plan-042 + plan-043 VERIFY PASS | NONE |
| TBD | plan-044 | SUB-PLAN IMPL | plan-044 PLAN committed | NONE |
| TBD | (verifier) | VERIFY | plan-044 close | NONE |
| TBD close | (close-bookkeeping) | CLOSE | Phase G-prime DoD attestation | NONE |

---

## P. Compliance attestation (sub-plan authoring session S398)

- harness_priority_one ✓ (no harness gap surfaced THIS session that overrides product work; harness sweep N+1 S388 commit 78089ba already SHIPPED + LIVE per current-execution.md:147; this sub-plan inherits the now-live `.planner-stats.tsv` writer auto-population)
- AP-1 ✓ (architect dispatched fresh-context per dispatch brief; main session ratifies output)
- AP-5 ✓ (re-read all binding sources at session entry per VBW protocol; 20+ source files cited inline per § A.4)
- AP-7 ✓ (every DEFER decision in § A.3 + § H + § L names prerequisites + revisit triggers — no naked deferrals)
- AP-23 ✓ (no refinement-of-rule iterations this session; new patterns FLAGGED as PCG-1..6 for promote-or-retire calculus at sub-plan close; 1st-instance HOLD applied per EchoValidator + cold-probe protocol + per-call cost-ledger + tests/unit convention)
- autonomous_continue_no_self_pause ✓ (architect ships sub-plan authoring complete; no self-pause)
- dont_self_pause_at_session_boundary ✓ (architect output = sub-plan + observation; main session commits + dispatches S399 dev per § N sequencing — no self-pause)
- stop_offering_routing_branches ✓ (sequencing in § N is structural advice not user-action menu)
- D-060 ✓ (architect has no Bash tool; main session commits this plan file per D-060 + pre-dispatch-architect-commit-guard.sh hook)
- D-050 ✓ (anthropic_api_to_subagent CHARTER memory rule — DD-1 binding; ZERO `import anthropic` mandate for G.3 directory)
- D-059 BINDING for S399 IMPL per § F.1 (R1 datetime-tz on extracted_at field at ExtractedFinancialStatement assembly)
- D-064 BINDING for S399 IMPL per § F.1 (path-safety on per-page image cache IF Resolution A path chosen)
- D-065 BINDING for S399 IMPL per DD-4 (Rule 16 mode #2 deterministic-pipeline echo satisfied via EchoValidator runtime invariant)
- D-066 INFORMATIONAL precedent ✓ (CrawlerAdapter ABC pattern; same Strategy ABC subclass-instantiation discipline)
- D-072 INFORMATIONAL precedent ✓ (BC-5 transport-flip; claude_cli_transport substrate; G.3 mirrors)
- D-074 INFORMATIONAL precedent ✓ (BC-8 transport-flip; RolePromptPack Foundation; G.3 mirrors)
- D-080 BINDING ✓ (G.1 ABC contract immutable; G.3 subclasses + consumes but does NOT modify)
- 0 charter writes ✓ (PROJECT_CHARTER.md untouched)
- 0 constitution writes ✓ (`agent-workspace/constitution/**` untouched)
- 0 human-workspace writes ✓ (sub-plan output to `agent-workspace/session-plans/pending/` only; observation to `agent-workspace/memory/observations/` only; STOP-FINDING write is CONDITIONAL at S399 IMPL not this PLAN session)
- 0 production code ✓ (architect PLAN-only per agent-template L21 "Never writes production code. Only plans.")
- 0 pyproject.toml writes ✓ (DD-8 — claude CLI is system-installed; no new dep)
- 0 import anthropic ✓ (DD-1 anthropic_api_to_subagent memory rule MANDATORY; verifier grep-asserts at V3)
- I-S1 ✓ (Claude vision OCR is character-recognition NOT number-derivation per Rule 16 mode #2 audit; deterministic VND-string parser produces Decimal; EchoValidator gates)
- I-S1-1 (Rule 16) ✓ (BINDING for G.3 per DD-4; mode #2 deterministic-pipeline echo satisfied by-construction via EchoValidator runtime invariant)
- I-S2 ✓ (every plan claim cites source file:line per § A.4 + § H source-evidence)
- I-S20 ✓ (per-cell EchoValidator pass-rate + per-extraction cost USD recorded in extraction telemetry; calibration_grade='D' V0 baseline)
- I-S22 ✓ (data lineage extended via ExtractedFinancialStatement provenance fields preserved per G.1 D2 dataclass contract; extraction_method='claude-vision' + extractor_version semver added)
- I-S34 ✓ (STEP 0 cold-probe uses synthetic minimal-PDF OR existing G.1 committed fixtures; no paid leak channels)
- I-S35 ✓ (G.3 ships extraction substrate; output framing UNCHANGED — research-aid; no buy/sell surface)
- Phase 1b CONSUMED + COLD-START explicit per § A.4 (per agent-template L65 + plan-025 DD-11 mandate; planner-stats infrastructure live post-S388 D1 promotion; cold-start declared on new task_class="pdf-claude-vision-adapter-plan")
- 5-source-evidence chain per § D DDs (DD-1 cites anthropic_api_to_subagent memory rule + D-072 + D-074 + subagent_transport.py:144-222 + claude_llm_perspective_adapter.py:5-8; DD-2 cites STEP 0.1.a VBW + L-S395-1 + L-S392-1; DD-3 cites parent plan-040 § E.3 D3 + AP-23 + packages/_shared/__init__.py:1-7; DD-4 cites financial-data-protocol.md:396-402 + :432 + RM-G-4 parent plan-040; etc.)
- L-S32-1 empirical-probe-first SKILL doctrine ACKNOWLEDGED in DD-2 + § C STEP 0.4 + § E STEP 3 ✓
- L-S395-1 full-pipeline cold-probe at STEP 0 ACKNOWLEDGED in § C STEP 0.4 + DD-2 ✓
- L-S392-1 dispatch-brief-drift prevention ACKNOWLEDGED in DD-2 + STEP 0.1.a + § A.4 source-file VBW empirical reads ✓
- L-S382-1 ctor-discipline ACKNOWLEDGED in RM5 + STEP 0.X ctor-signature grep mandate ✓
- L-S389-1 wc -l exact-integer attestation ACKNOWLEDGED in § G.5 + DoD checklists ✓
- L-S389-2 ADR 12-field schema floor ACKNOWLEDGED in DD-7 + D5 ADR D-082 ✓
- L-S397-1 plan LOC ceilings per-category ACKNOWLEDGED in § G.4 + § G.5 distinguish core vs docstring vs test ✓
- L-S397-2 STOP-FINDING severity vocabulary ACKNOWLEDGED in DD-5 + § J K.2.b + § C STEP 0.4 STOP-AND-ASK ✓
- L-S397-3 close-loop file-existence verification ACKNOWLEDGED in § E.5 wc -l attestation mandate ✓
- anthropic_api_to_subagent memory rule MANDATORY ACKNOWLEDGED in DD-1 + § C STEP 0.1.b + § D + hard_rules_acknowledged ✓
- Phase F-prime CODE-DONE-DATA-PENDING attestation S386 90b27db acknowledged in § N.1 (parallel-dispatch gate satisfied) ✓
- Plan-040 § N.2 sequencing followed ✓ (S398 = THIS plan; S399 IMPL = D1-D5 sub-track decomposition; S400 = verifier per AP-1 fresh-context)
- S396 in-flight file scope OFF-LIMITS per dispatch brief acknowledged in § B.2 + § K.1 + § N.1 ✓
- Phase 1 sub-plan FOCUSED_IMPL anti-pattern (Session 4 catastrophic mix) avoided — sub-plan 043 is PLAN-only; S399 IMPL is separate session ✓
- Sub-plan size discipline (per dispatch brief: model on plan-041 ~720 LOC) — this sub-plan target ~900-1000 LOC; +25-40% over plan-041 due to (a) 9 DDs vs plan-041 8 DDs (+DD-9 test path convention), (b) ADR D-082 detail expansion, (c) per-call cost ceiling design depth, (d) DD-2 vision-input shape conditional resolution paths require more depth than DD-1 ABC location ✓

---

**END OF SUB-PLAN 043-S398-PHASE-GPRIME-G3-CLAUDE-VISION-ADAPTER-AND-ECHO-VALIDATOR**

> Plan file ends at this line. Architect output complete. Main session reviews + commits + dispatches S399 sandwich-dev FOCUSED_IMPL per § N.2 sequencing.
