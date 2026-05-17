---
observation_id: sandwich-architect-S392-g1-pdf-library-bakeoff
type: sandwich-architect-output
architect_agent_id: (this fresh-context dispatch; see dispatch.jsonl for ID)
created_at: 2026-05-17
plan_authored: agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md (single physical file ~720 LOC; equivalent to plan-039 size envelope per dispatch brief sub-plan-size discipline guidance)
target_session: S394 (sandwich-dev FOCUSED_IMPL executing D1-D5; per dispatch brief § J — S393 reserved for parallel data-corpus operational plan-045 IMPL)
verifier_session: S395 sandwich-verifier AP-1 (fresh-context post-S394 dev close)
phase_milestone: G.1 PdfTableExtractorPort ABC + empirical bake-off + ExtractedFinancialStatement intermediate dataclass — FIRST + SEQUENTIAL FIRST sub-plan of Phase G-prime master plan-040 (per § N.2 sequencing; blocks G.2 + G.3 + G.4)
sandwich_architect_has_no_Bash_tool: true (Read/Glob/Grep/Write only per agent template; main commits per D-060 + pre-dispatch-architect-commit-guard.sh)
phase_1b_self_calibration: CONSUMED with COLD-START DECLARED for task_class="pdf-extraction-plan"; nearest analogs crawler-adapter-plan n=1 (S337 plan-020 ~80K Sonnet) + multi-perspective-impl-plan n=1 (S374 plan-034 ~140K Opus); novel sub-components = empirical-probe-protocol authoring + 4-metric-harness design + library-license-matrix audit
plan_type: FOCUSED_IMPL sub-plan (5 sub-tracks D1-D5; first of 4 sub-plans per parent plan-040 § E decomposition)
parent_plan: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md (PHASE-MASTER-PLAN; sub-plan 041 satisfies its § E.1 contract per DD-1 ABC location + DD-2 ExtractedFinancialStatement + DD-3 provenance + DD-4 4-metric probe + DD-5 sequential-post-G.1 + DD-8 ADR D-080)
predecessor_sub_plans: [] (FIRST sub-plan of Phase G-prime; master plan-040 is the predecessor)
related_adrs: [D-066 ACCEPTED CrawlerAdapter ABC at packages/application/news/ports/crawler_adapter.py (INFORMATIONAL precedent for ABC pattern; same Strategy ABC + ClassVar + __init_subclass__ typecheck + 4 abstract methods extension per provenance need), D-059 (Python determinism — R1 datetime-tz BINDING for ExtractedFinancialStatement.extracted_at), D-061 (add-with-rationale doctrine — winner library addition deferred to G.2 IMPL), D-064 (path-safety 5-invariant — PdfSource.pdf_path + bake-off probe --pdf-path), D-080 PROPOSED-AT-IMPL via this plan D5]
---

# S392 sandwich-architect — Phase G.1 PdfTableExtractorPort ABC + Empirical Library Bake-Off sub-plan-041 authoring observation

## What was authored

Sub-plan 041 at `agent-workspace/session-plans/pending/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md` (single physical file ~720 LOC; equivalent to plan-039 size envelope per dispatch brief sub-plan-size discipline guidance "emulate plan-039 for sub-plan size discipline"). FOCUSED_IMPL sub-plan for Phase G-prime sub-theme G.1 — SEQUENTIAL FIRST sub-plan of Phase G-prime per master plan-040 § N.2 (blocks G.2 + G.3 + G.4). Decomposed into 5 sub-tracks D1-D5:

- D1 PdfTableExtractorPort ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NEW directory + NEW file; ~100 LOC; mirrors D-066 CrawlerAdapter shape with 4 abstract methods + `source_id` ClassVar + `__init_subclass__` typecheck)
- D2 ExtractedFinancialStatement + PdfSource value objects at `packages/application/fundamental/extracted_financial_statement.py` + `pdf_source.py` (NEW ~80 + ~40 LOC; frozen+slotted dataclasses; 6 provenance fields per parent plan-040 DD-3; D-059 R1 + D-064 path-safety BINDING)
- D3 Empirical bake-off probe at `apps/cli/bench/pdf_bake_off.py` + bake-off report at `agent-workspace/research/pdf-library-bakeoff-2026-05-G1.md` (NEW ~180 + ~300 LOC; 3-library probe — pdfplumber+camelot / docling / pypdf — × 2-document gold set with 4-metric grid: cell-content-exact-match accuracy + wall-time + dep-footprint + license; pymupdf AGPL-3.0 excluded; Claude vision deferred to G.3)
- D4 ABC contract tests + dataclass tests + gold-set fixtures at `packages/application/fundamental/test_*.py` (NEW ~180 LOC tests) + `tests/fixtures/pdf/{vhm,hpg}-2023-annual.pdf` (NEW directory + binary PDFs ~3-5 MB each) + `SHA256.txt` manifest + `expected_cells_{vhm,hpg}.json` (10 LineItemKey × ground-truth value/page/context each)
- D5 ADR D-080 PROPOSED at `agent-workspace/memory/decisions/080-pdf-table-extractor-port-and-library-winner.md` (NEW ~180 LOC; 12-field schema floor per L-S389-2 promotion; records ABC contract + intermediate dataclass + empirical winner + license posture + D-066 → D-080 chain)

**Plan stats** (architect-internal):
- Total LOC: ~720 (well-matched to plan-039 = ~720 LOC envelope per dispatch brief discipline guidance)
- 8 DD architecture decisions (DD-1..DD-8) all pre-answered with rationale + adversarial alternates explicitly rejected (Karpathy P1 think-before-coding)
- 5 sub-tracks D1-D5 in § E with DoD criteria + LOC ceiling + dependency graph + parallel-eligibility
- 33+ DoD criteria across § E + § G (≥25 floor satisfied)
- 6 RM entries (RM1..RM6) with mitigation including RM6 dispatch-brief-deviation meta-pattern
- 5-source-evidence chain per major DD (DD-1 cites parent plan-040 DD-1 + D-066 + STEP 0.5 VBW + packages/_shared/__init__.py constraint + DDD skill)
- STEP 0 STOP-AND-ASK trigger inventory carry-forward to S394 (K.2.a CONDITIONAL per parent plan-040 inheritance)
- § K coordination paths off-limits during S394 IMPL (explicit BINDING file scope)
- § L 6 promotion candidates (PCG-1..6 — ABC pattern + ExtractedX pattern + 4-metric harness + gold-set fixture pattern + VND-string parser + dispatch-brief-VBW pre-flight discipline)
- § N sequencing table covering S391-S404 (Phase G-prime full ship)
- § P compliance attestation grid (32 rows — all hard rules + memory rules + lessons + dispatch-brief deviation acknowledgment)

## Key architectural decisions (DD-1..DD-8 summary)

| DD | Decision | Pre-decided or ARCHITECT-REFINEMENT? |
|---|---|---|
| **DD-1** | **PdfTableExtractorPort = ABC at `packages/application/fundamental/pdf_table_extractor_port.py` (NOT `packages/_shared/pdf/` per dispatch brief)** | **ARCHITECT VBW CORRECTION** per STEP 0.5 finding — dispatch brief was wrong (cited non-existent `packages/_shared/crawl/crawler_adapter.py`; actual D-066 location is `packages/application/news/ports/crawler_adapter.py`; `packages/_shared/__init__.py:1-7` requires dep-free pure Python which PDF libs violate); parent plan-040 DD-1 is canonical source per dispatch brief precedence ("read parent plan-040 § D first") |
| **DD-2** | **ABC = 4 abstract methods + 1 ClassVar (extract + supports + name + extractor_version + source_id)** | ARCHITECT-REFINEMENT of dispatch brief § D guidance — dispatch brief said "≤4 abstract methods Karpathy P2" + "extract + supports + name minimum"; this DD-2 sets exactly 4 methods at ceiling, adding extractor_version for ExtractedFinancialStatement provenance (DD-3 cascade); +1 over D-066 CrawlerAdapter's 3 methods for principled provenance reason |
| **DD-3** | **Gold-set = 2 real public corporate annual reports (VHM 2023 + HPG 2023; commit-eligible per I-S34)** | PRE-DECIDED per parent plan-040 DD-3 + dispatch brief § A guidance "1-2 real VHM/HPG annual-report PDFs"; chose 2 (upper end of range) for cross-sector generalization signal — VHM real-estate (complex BS) + HPG steel (simpler IS) — informs G.2 cell-label-map design |
| **DD-4** | **Winner-pick metric = cell-content-exact-match (NOT cell-count + NOT table-structure-match alone)** | ARCHITECT-REFINEMENT of dispatch brief § D guidance — dispatch brief listed 3 candidate metric definitions; this DD-4 picks cell-content-exact-match because cell-count too lenient (false positives) + structure-match too strict (layout variability OK if values right); enables Rule 16 mode #2 satisfaction by-construction |
| **DD-5** | **Karpathy P3 surgical-scope = ZERO touch to `apps/crawlers/cafef_html_to_md.py` (BC-5 stays HTML-route)** | PRE-DECIDED per dispatch brief § D + parent plan-040 § A.3 + § F.2; AP-7 named revisit trigger captured in § L PCG-1 promote candidate |
| **DD-6** | **Bake-off probe location = `apps/cli/bench/pdf_bake_off.py` (NEW sub-directory; NOT scripts/bench/)** | ARCHITECT-REFINEMENT per Glob confirmation — dispatch brief left this open ("document in plan whether it lives in apps/cli/ or scripts/bench/"); apps/cli/ chosen because (a) 19 existing CLI scripts establish convention, (b) scripts/ contains hook substrate not product code, (c) NEW bench/ sub-directory clearly signals one-off probe NOT production CLI |
| **DD-7** | **ADR D-080 PROPOSED-AT-IMPL records ABC + intermediate dataclass + empirical winner + license posture (12-field schema floor per L-S389-2)** | PRE-DECIDED per parent plan-040 DD-8 + L-S389-2 harness sweep N+1 promotion + AOM ADR template + dispatch brief mandate "ADR D-080 PROPOSED at IMPL-tier" |
| **DD-8** | **ZERO pyproject.toml dep addition THIS sub-plan — bake-off probe in ISOLATED venv** | PRE-DECIDED per parent plan-040 § E.1 dependencies clause + RM1 rollback path preservation; G.2 IMPL D3 ratifies winner dep addition per D-061 add-with-rationale doctrine |

**Single most important callout**: **DD-1 + STEP 0.5 + RM6 are the dispatch-brief VBW correction** — dispatch brief named `packages/_shared/pdf/pdf_table_extractor_port.py` location + `packages/_shared/crawl/crawler_adapter.py` D-066 precedent reference. Both were WRONG per VBW Read + Glob:
- `packages/_shared/__init__.py:1-7` constrains _shared/ to dep-free pure-Python (PDF library imports violate)
- `packages/_shared/crawl/crawler_adapter.py` does NOT exist (Glob 0 matches)
- Actual D-066 location: `packages/application/news/ports/crawler_adapter.py` (Glob confirmed 128 LOC)
- Parent plan-040 DD-1 canonical source per dispatch brief precedence rule ("read parent plan-040 § D first") specifies `packages/application/fundamental/pdf_table_extractor_port.py`
This VBW correction is documented in DD-1 rationale + STEP 0.5 finding + RM6 mitigation + § P compliance attestation. Meta-pattern surfaced as PCG-6 promote candidate (architect-dispatch-brief VBW pre-flight discipline).

## Phase 1b self-calibration (CONSUMED variant; COLD-START DECLARED for task_class="pdf-extraction-plan"; nearest analogs crawler-adapter-plan n=1 + multi-perspective-impl-plan n=1)

**Source files read** (VBW empirical, ALL via Read tool — architect has no Bash; 18+ files cited in plan § A.4):

Highlights:
1. `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md` (parent master plan; offset 1-300 + 300-600 + 600-824 — full § A goal + § C STEP 0 + § D DDs 1-8 + § E sub-track decomposition + § G 3-source-evidence chain + § J risks + § K K.2 surfaces + § L promotion candidates + § N sequencing + § P compliance attestation)
2. `agent-workspace/session-plans/completed/039-S387-harness-stabilization-sweep-N1.md` (sub-plan template shape reference; first 200 LOC; § A-N standard structure for plan-shape mirror)
3. `agent-workspace/session-plans/completed/034-S374-phase-f1-roleprompt-persona-transport.md` (5-sub-track FOCUSED_IMPL precedent; first 200 LOC; direct template for shape)
4. `packages/application/news/ports/crawler_adapter.py` (full 128 LOC; D-066 ACTUAL location + EXACT ABC pattern — source_id ClassVar + __init_subclass__ typecheck at L60-78 + 3 abstract methods at L80-127 + crawl4ai/hub.py:24-35 NOTICE attribution at L1-3 + L63-66)
5. `packages/domain/fundamental/models/financial_statement.py` (full 108 LOC; FinancialStatement aggregate at L42-88 with frozen+slotted + Mapping[str, Money] line_items + Rule 1/4/5/6 invariants in __post_init__:63-88)
6. `packages/domain/fundamental/value_objects/line_item.py` (full 65 LOC; LineItemKey StrEnum 10 canonical keys at L33-45 + line_item_required_for_ratio table)
7. `packages/infrastructure/fundamental/vnstock_fundamental_adapter.py` (first 120 LOC; vendor-key→canonical mapping at _VNSTOCK_LINE_ITEM_MAP L58-90 — bilingual VN+EN labels; G.2 IMPL MIRRORS pattern)
8. `packages/_shared/__init__.py` (full 7 LOC; constraint "dep-free no framework imports — pure Python only" — STEP 0.5 evidence for DD-1 dispatch-brief correction)
9. `packages/_shared/path_safety.py` (first 50 LOC; safe_user_path + safe_document_path D-064 helpers — D2 PdfSource + D3 bake-off probe consume)
10. `pyproject.toml` (first 60 LOC + parent plan-040 § A.4 entry 12 confirms ZERO PDF lib dep currently)
11. `agent-workspace/memory/observations/sandwich-architect-S387-harness-sweep-N1-plan.md` (first 100 LOC; recent architect observation template; ~85K Opus budget actual)
12. `agent-workspace/memory/observations/sandwich-architect-S374-phase-f1-plan.md` (first 80 LOC; F.1 sub-plan precedent observation; ~140K Opus budget actual)

Additional reads: Glob packages/application/fundamental/**/*.py (confirmed directory does NOT exist) / Glob packages/infrastructure/fundamental/**/*.py (4 files exist) / Glob apps/cli/**/*.py (19 CLI scripts; bench/ NEW) / Glob scripts/bench/**/* (NONE) / Glob tests/fixtures/**/* (NONE) / Glob tests/unit/**/* (NONE — convention = tests-alongside-code) / Glob agent-workspace/memory/decisions/0{75,76,77,78,79}*.md (highest = D-079; D-080 next per DD-7) / Glob agent-workspace/session-plans/pending/041*.md (NONE — plan-041 number available)

**Calibration parameters extracted**:
- **task_class**: `pdf-extraction-plan` (NEW — no precedent in tracking logs)
- **sample_size**: **0 for pdf-extraction-plan** (COLD-START); **1 for crawler-adapter-plan** (S337 plan-020 ~80K Sonnet at ~30 min) + **1 for multi-perspective-impl-plan** (S374 plan-034 ~140K Opus at ~50 min based on observation)
- **Cold-start?**: **YES for pdf-extraction-plan task-class**; **NO for ABC+intermediate-dataclass shape** (transfers cleanly from D-066); **PARTIAL-COLD-START for bake-off-probe + 4-metric-harness + library-license-matrix-audit**; **NO for ADR landing shape** (D-080 mirrors D-066 shape)
- **Adjustment to default budget**: +30-50K Opus reserve over nearest-analog ~85-140K for novelty = ~120-170K projected typical THIS PLAN; S394 IMPL inherits parent plan-040 § A.4 estimate ~150K Opus FOCUSED_IMPL

## Companion-output dispatch brief satisfaction

Per dispatch brief § Companion output — this observation summarizes:

### (a) Sub-plan LOC + STEP count
- **LOC**: ~720 (well-matched to plan-039 = ~720 LOC envelope per dispatch brief discipline guidance)
- **STEP count**: 5 sub-tracks (D1-D5) + 7 STEP 0 sub-steps (0.1-0.7) + 6 DDs (DD-1..DD-8) + 6 RMs (RM1..RM6) + 6 PCG promote candidates (PCG-1..6)
- Single physical file (NOT 4-file split like plan-034 — within output token budget; ~720 LOC fits)

### (b) Gold-set sourcing decision
- **DD-3 decision**: 2 real public corporate annual report PDFs at `tests/fixtures/pdf/`:
  - `vhm-2023-annual.pdf` (Vinhomes 2023; ~3-5 MB; source = Vietstock public OR vinhomes.vn IR)
  - `hpg-2023-annual.pdf` (Hoa Phat Group 2023; ~3-5 MB; source = Vietstock public OR hpg.vn IR)
- **Rationale**: 2-document corpus (upper end of dispatch brief's "1-2 real" range) gives within-VN cross-sector generalization signal — VHM real-estate (complex BS) vs HPG steel (simpler IS) informs G.2 cell-label-map design
- **Commit-eligibility**: VN listed-company annual reports are PUBLIC disclosure-mandated artifacts under SSC regulations; commit-eligible per I-S34; ~6-10 MB total acceptable
- **Synthetic fixtures REJECTED**: fails to test real-world VN layout drift; predictive value for G.4 dogfood = nil
- **5-document G.1 corpus REJECTED**: per parent plan-040 DD-4 — over-engineering for V0 winner-pick; 5-doc expansion is G.4 dogfood scope

### (c) ABC method surface chosen
- **DD-2 decision**: 4 abstract methods + 1 `source_id` ClassVar
  - `extract(pdf_source: PdfSource) → ExtractedFinancialStatement` (primary)
  - `supports(pdf_path: Path) → bool` (adapter-routing pre-check)
  - `name() → str` (human-readable adapter identifier; feeds provenance)
  - `extractor_version() → str` (semver; feeds provenance)
  - `source_id: ClassVar[str]` (enforced non-empty at `__init_subclass__` per D-066 precedent)
- **Karpathy P2 ceiling**: exactly 4 methods at the ceiling per dispatch brief § H RM4 anti-over-engineering
- **+1 over D-066 CrawlerAdapter's 3 methods**: principled extension for provenance need (CrawlerAdapter doesn't track extractor_version because BC-5 ScrapedArticle shape doesn't include that field)
- **5-method extensions rejected**: page_range (deferred to D-080-V2), detect_currency (V0 = VND default), detect_language (V0 = VN default), OCR-fallback flag (per-adapter detail)

### (d) RM count + top 3 risks
- **RM count**: 6 risks documented (RM1..RM6)
- **Top 3 risks by impact**:
  - **RM1 (HIGH impact, MEDIUM likelihood)** — No-clear-winner empirical pivot: mitigation chain = (a) D3 defines no-clear-winner threshold = max(scores)<70% AND no library ≥10pp above next-best, (b) IF triggers → STOP-AND-ASK fires per K.2.a, (c) ADR records escalation + main session AskUserQuestion gate
  - **RM3 (HIGH impact IF triggered, LOW likelihood)** — Gold-set licensing / commit-eligibility for VHM + HPG annual reports: mitigation = (a) Vietstock public OR VN company IR website explicit attribution in SHA256.txt, (b) PUBLIC disclosure-mandated artifacts per SSC, (c) IF project-owner objects → STOP-AND-ASK options menu (git-lfs / .gitignored cache / separate test data repo)
  - **RM2 (MEDIUM impact, MEDIUM likelihood)** — docling pip install fails on Windows: mitigation = (a) STEP 0.2.c install probe FIRST (riskiest of 3), (b) 2-way bake-off still produces winner-pick if docling fails, (c) specific known issues documented (torch CPU-only flavor + tesseract-ocr Windows installer)

### (e) K.2.a charter-tier-surface trigger condition pre-stated
- **K.2.a inherited from parent plan-040** per § J.2 verbatim
- **Trigger A (license escalation)**: G.1 IMPL STEP 0.1.b re-verification reveals pymupdf license CHANGED to BSD/MIT/Apache (currently AGPL-3.0 excluded) AND pymupdf Metric 1 score > best non-pymupdf by ≥10 percentage points
- **Trigger B (no-clear-winner pivot)**: max(pdfplumber, docling, pypdf) Metric 1 score < 70 percentage points AND no library is ≥10 pp above the others
- **Default if NOT fired (NON-BLOCKING design path per parent plan-040 K.1)**: G.1 winner = whichever of pdfplumber+camelot OR docling OR pypdf scores highest on Metric 1 (Metric 2 < 60s tie-break; Metric 3 + Metric 4 documentation-only NOT pick-deciding)
- **Main session decision path IF fired**: AskUserQuestion gate Q-INT-2026-05-G-prime-1 fires; S394 dev writes `human-workspace/notifications/STOP-FINDING-S394-*.md` per parent plan-040 § K.2.a path

### (f) Parallel-dispatch compatibility with S393 plan-045
- **COMPATIBLE per parent plan-040 § N.4** — plan-041 PLAN (S392 architect) + plan-045 IMPL (S393 dev) are parallel-dispatchable because:
  - **File-scope disjoint**: plan-041 G.1 scope = NEW `packages/application/fundamental/` + NEW `apps/cli/bench/` + NEW `tests/fixtures/pdf/` + NEW ADR D-080 + bake-off report. Plan-045 data-corpus operational scope = existing BC-5 News crawlers + existing BC-1 OHLCV + existing BC-2 vnstock-existing-adapter (vnstock_fundamental_adapter.py)
  - **ZERO touch overlap**: plan-041 explicitly OFF-LIMITS for vnstock_fundamental_adapter.py per § K.1 BINDING file scope; plan-041 OFF-LIMITS for BC-5 News per § K.1 + DD-5 surgical-scope
  - **Cross-phase parallel-dispatch authorized per parent plan-033 § N + parent plan-040 § N.4** — Phase G-prime sub-plans CAN run parallel with Phase F-prime data-corpus operational track
  - **2-parallel dispatch within plan-025 DD-5 3-parallel ceiling**: S392 architect (THIS) + S393 dev = 2-parallel; well within ceiling

## Karpathy P1 explicit pushback on dispatch brief

Per Karpathy P1 think-before-coding doctrine + L-S385-3 "pushback when simpler approach exists":

### Dispatch-brief deviation #1 (ARCHITECT VBW CORRECTION)
- **Dispatch brief said**: "PdfTableExtractorPort ABC in `packages/_shared/pdf/pdf_table_extractor_port.py`"
- **Architect VBW finding**: `packages/_shared/__init__.py:1-7` constraint = dep-free pure Python; PDF library imports violate
- **Architect VBW finding**: dispatch brief cited `packages/_shared/crawl/crawler_adapter.py` — does NOT exist (Glob 0 matches); actual D-066 location is `packages/application/news/ports/crawler_adapter.py`
- **Resolution**: PdfTableExtractorPort at `packages/application/fundamental/pdf_table_extractor_port.py` per parent plan-040 DD-1 canonical source (dispatch brief precedence rule: "read parent plan-040 § D first")
- **Documented in**: DD-1 + STEP 0.5 + RM6 + § P compliance attestation

### Dispatch-brief deviation #2 (ARCHITECT REFINEMENT)
- **Dispatch brief said**: "ABC method surface ≤4; extract + supports + name minimum; consider page-range parameter, OCR-fallback flag"
- **Architect refinement**: chose exactly 4 methods at Karpathy P2 ceiling = extract + supports + name + extractor_version (NOT 3-method minimum); rejected page-range (deferred to D-080-V2 per § A.3) + OCR-fallback flag (per-adapter detail)
- **Rationale**: extractor_version is principled +1 for provenance need (ExtractedFinancialStatement.extractor_version field) NOT speculative — meets the provenance contract per parent plan-040 DD-3
- **Documented in**: DD-2 + RM4

### Sequencing renumbered per dispatch brief § J
- **Parent plan-040 § N.2 said**: S392/S393/S394 for plan-041 PLAN+IMPL+VERIFY
- **Dispatch brief § J said**: S393 reserved for parallel plan-045 IMPL
- **Architect resolution**: renumbered to S392 PLAN / S394 IMPL / S395 VERIFY (S393 = parallel plan-045 IMPL)
- **Documented in**: target_session frontmatter field + § N.4 sequencing table

## Out-of-scope items captured in sub-plan § A.3

24 deferred items with named revisit triggers per AP-7 (no naked deferrals). Key items:
- G.2 winner-adapter IMPL (separate sub-plan 042)
- G.3 Claude vision adapter (separate sub-plan 043)
- G.4 BC-2 dogfood (separate sub-plan 044)
- Cleanup of any pre-existing PDF code (NONE exists per parent plan-040 § C.0.6 audit)
- pymupdf as G.1 probe candidate (AGPL-3.0 blocker; K.2.a STOP-AND-ASK trigger)
- unstructured library (heavy dep stack rejected)
- Claude vision API direct (anthropic_api_to_subagent memory rule violation; use claude CLI substrate)
- ABC method extension to ≥5 methods (defer to D-080-V2)
- pyproject.toml dep addition for ANY library (per DD-8 isolated-venv probe)
- 5-document gold set in G.1 (deferred to G.4 D6)
- + 14 more per § A.3 table

## Promotion candidates captured (PCG-1..6)

| PCG | Pattern | Promotion-readiness | Notes |
|---|---|---|---|
| PCG-1 | PdfTableExtractorPort ABC pattern (4-method + ClassVar + __init_subclass__) | If reused for G.2 + G.3 unchanged | LIKELY 2nd-instance promote at G.3 close |
| PCG-2 | ExtractedFinancialStatement intermediate dataclass pattern | If reused for G.3 (BC-5 ExtractedClaim already-promoted precedent) | ALREADY-promoted at BC-5; G.1 extends to BC-2 |
| PCG-3 | 4-metric empirical bake-off harness | If reused for ANY future library-choice sub-plan | DEFER per parent plan-040 § L PCG-5 |
| PCG-4 | Gold-set fixture pattern (SHA256 manifest + expected-cells JSON) | If reused for BC-5 News calibration OR BC-6 KOL gold set | LIKELY promote — Charter Principle 8 operationalization |
| PCG-5 | Minimal inline VND-string parser (within bake-off probe) | If reused at G.2 | LIKELY promote at G.2 close per parent plan-040 § L PCG-2 |
| PCG-6 | Architect-dispatch-brief VBW pre-flight discipline | If 2nd instance of dispatch-brief path-error fires | DEFER per AP-23 1st-instance HOLD; RM6 1st-instance documented |

## What I did NOT do

Per dispatch brief hard rules + agent template L21:
- Did NOT write any production code (architect PLAN-only)
- Did NOT modify PROJECT_CHARTER.md
- Did NOT modify any agent-workspace/constitution/** file
- Did NOT modify existing plans in pending/ or completed/ (parent plan-040 UNCHANGED; only REFERENCED)
- Did NOT modify plan-040 master plan (parent reference only)
- Did NOT commit (per D-060 + architect-has-no-Bash + pre-dispatch-architect-commit-guard.sh — main session commits this plan)
- Did NOT push (D-060 hard rule — agents MUST NOT push)
- Did NOT call /master-plan or any Skill (per Q-2.1 = B — skills only in SUPERVISED mode; this is autonomous-full mode per CLAUDE.md user memory)
- Did NOT pick the library winner in the PLAN (that's S394 IMPL empirical work; PLAN authors the bake-off protocol per dispatch brief explicit)
- Did NOT reuse plan numbers 040-044 (reserved by parent plan-040 § N; used 041 only per dispatch brief mandate)
- Did NOT write to human-workspace/** (STEP 0 STOP-AND-ASK is S394 dev conditional path; PLAN session has no charter/scope question)

## Recommendation for main session next-turn action

Per parent plan-040 § N.2 + dispatch brief § N:

1. **Commit plan-041 + observation** per D-060 + pre-dispatch-architect-commit-guard.sh hook (single commit recommended; commit message format = "S392: Phase G-prime G.1 PdfTableExtractorPort ABC + empirical library bake-off sub-plan-041 PLAN authored by sandwich-architect")
2. **Dispatch S394 sandwich-dev FOCUSED_IMPL** post-commit per § N.2 sequencing (Opus per all-14-agents-on-Opus user directive; 150K FOCUSED_IMPL budget per parent plan-040 § A.4 + recalibrated CLAUDE.md table)
3. **Optionally dispatch S393 sandwich-dev plan-045 IMPL in parallel** per § N.1 + parent plan-040 § N.4 (2-parallel within plan-025 DD-5 3-parallel ceiling; ZERO file-scope collision per § N.1)
4. **Schedule S395 sandwich-verifier AP-1** post-S394 dev close (Opus per all-14-agents-on-Opus; 80-140K VERIFY budget per recalibrated CLAUDE.md Opus column)
5. **Phase G-prime DoD gate**: G.1 close = sub-plans 042 + 043 dispatch-ready; G.2 + G.3 PARALLEL-dispatchable per parent plan-040 § N.2

## Estimated budget for S394 dev session

Per parent plan-040 § A.4 PLAN BUDGET DERIVATION + this plan § A.4 PLAN BUDGET DERIVATION:

- **Projected typical**: 135-185K Opus FOCUSED_IMPL
- **With STEP 0 STOP-AND-ASK path**: 145-195K Opus FOCUSED_IMPL
- **Hard cap**: 150K Opus FOCUSED_IMPL per recalibrated CLAUDE.md table (if work exceeds → SPLIT trigger per § G LOC ceiling per STEP)
- **Per-sub-track**: D1 ~15-20K / D2 ~15-20K / D3 ~50-70K DOMINANT (empirical probe novelty) / D4 ~15-25K / D5 ~15-25K + overheads ~50K

## Architect-internal token usage (THIS PLAN session)

- **Budget**: 150-200K Opus PLAN target (cold-start envelope per recalibrated CLAUDE.md PLAN-Opus 150-230K column)
- **Estimated actual**: ~140-170K Opus (mid-band; +30-50% over crawler-adapter-plan nearest-analog for empirical-probe novelty)
- **Within envelope**: YES

---

**END OF S392 OBSERVATION**

> Architect output complete. Main session reviews + commits + dispatches S394 dev per § N sequencing.
