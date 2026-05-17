---
observation_id: master-planner-S391-phase-gprime-master-plan
session: S391
agent: master-planner (sandwich-architect tier; Opus 4.7 PLAN session)
date: 2026-05-17
plan_artifact: agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md
return_summary_for: main session dispatching Phase G-prime entry per parent plan-033 § N parallel-dispatch authorization
---

# Master-planner return summary — Phase G-prime master plan author S391

## (a) Sub-plan count + budget envelope

**4 sub-plans decomposed** (sequential 041 → parallel 042+043 → sequential 044):

| Sub-plan | Slot | Theme | Type | Budget envelope (Opus) | Wall-time est |
|---|---|---|---|---|---|
| 041 | G.1 | Empirical library bake-off + PdfTableExtractorPort ABC contract design | PLAN+IMPL+VERIFY | 50-80K + 150K + 30-60K = 230-290K | ~3 turns |
| 042 | G.2 | Pure-Python adapter (winner of G.1) | PLAN+IMPL+VERIFY | 50-80K + 120-150K + 30-60K = 200-290K | ~3 turns |
| 043 | G.3 | LLM-assisted Claude vision adapter + EchoValidator gate (Rule 16 mode #2) | PLAN+IMPL+VERIFY | 50-80K + 130-180K + 30-60K = 210-320K | ~3 turns |
| 044 | G.4 | VHM annual-report dogfood + BC-2 SqliteFundamentalRepository integration smoke | PLAN+IMPL+VERIFY | 50-80K + 120-150K + 30-60K = 200-290K | ~3 turns |

**Cumulative Phase G-prime budget envelope**: **~720-1160K Opus across 12-16 sessions** (4 PLAN + 4-6 IMPL + 4 VERIFY; estimate revised UPWARD from parent plan-033 § 6.4.4 ~400-600K due to G.3 LLM-vision novelty + gold-set construction overhead + empirical probe execution overhead in G.1).

**Wall-time with 042+043 parallel**: ~10-14 turns total (saves 2-3 turns vs sequential).

## (b) Reference-repo source-evidence chain (≥3 candidate libraries per L-S32-1 mandate)

3 candidate libraries surveyed + 4 deferred (license/scope blocker) + 1 reference-repo pattern (PATTERN-PORT only):

1. **pdfplumber + camelot** (supplement § J.3 line 298; MIT + MIT clean; best digital-PDF table extraction)
2. **docling** (master-planner general knowledge; MIT clean; recent IBM open-source layout-aware; NEW candidate this audit — not in supplement § J)
3. **pypdf** (`C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py:45-60` + supplement § J.2 line 289; BSD-3 clean; FinceptTerminal-precedent + crawl4ai-NaivePDFProcessorStrategy uses; text-only baseline)

**Deferred candidates** (G.1 probe excludes):
- pymupdf — AGPL-3.0 license blocker for stockforge proprietary use (pyproject.toml:7 license="Proprietary"); revisit if project-owner accepts AGPL-3.0 commercial license
- unstructured — heavy dep stack bloat risk per A-02 § 5; revisit if G.1 winner fails accuracy gate
- Claude vision API direct — memory-rule anthropic_api_to_subagent violation; use existing claude CLI substrate (G.3) instead
- AzureDocumentIntelligence / AWS Textract / GCP Vision — paid cloud services; out of V0 scope per cost discipline + § A.3 deferral

**Reference-repo PATTERN-PORT** (NOT code-port per A-04 AGPL+Commercial license):
- `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_text_extractor.py:45-60` (`_load_reader()` pypdf→PyPDF2 fallback chain + SHA256 dedupe + state.json checkpoint patterns)
- `C:/htdocs/research/FinceptTerminal/fincept-qt/scripts/cninfo_pdf_downloader.py` (SHA256-based dedupe + index.json checkpoint + retry-with-backoff for PDF source URL fetcher)
- `C:/htdocs/research/crawl4ai/crawl4ai/processors/pdf/processor.py:1-100` per A-02 § 3 C9 (PDFContentScrapingStrategy ABC shape — Apache-2.0 + Attribution clause; pattern-port if winner chosen)

## (c) Charter-tier questions surfaced (NON-BLOCKING design recommendation)

**This master plan RECOMMENDS NON-BLOCKING entry** — sub-plans proceed to dispatch without user gate UNLESS sub-plan STEP 0 empirical probe contradicts architect-recommended defaults. The following 3 charter-tier-surface triggers are pre-armed for sub-plan-level STOP-AND-ASK firing:

### K.2.a — pymupdf AGPL-3.0 license escalation OR no-clear-winner empirical pivot
- **Trigger**: G.1 IMPL empirical probe reveals (a) pymupdf significantly better than baseline 3 candidates AND project-owner WOULD accept AGPL-3.0, OR (b) ALL 3 baseline candidates score <70% on canonical-cell accuracy
- **Charter-tier-surface**: license posture decision (Proprietary vs AGPL-3.0-viral) OR Phase scope pivot
- **Default if NOT fired**: G.1 winner = highest-scoring among pdfplumber+camelot OR docling OR pypdf
- **Q-INT bundle**: Q-INT-2026-05-G-prime-1 IF triggered

### K.2.b — Claude CLI substrate vision-input feasibility
- **Trigger**: G.3 STEP 0 empirical probe reveals claude CLI substrate does NOT support PDF/image input (per § C.0.5 OPEN QUESTION) AND G.3 cannot proceed via fallback paths (tesseract+vie / extract images to PNG then dispatch / defer G.3 to V2)
- **Charter-tier-surface**: anthropic_api_to_subagent memory-rule scope question (text-only mandate vs text+vision)
- **Default if NOT fired**: G.3 ships claude CLI substrate; vision feasibility VERIFIED at G.3 STEP 0
- **Q-INT bundle**: Q-INT-2026-05-G-prime-2 IF triggered

### K.2.c — G.4 schema-migration for FinancialStatement provenance fields
- **Trigger**: G.4 STEP 0 empirical decision per DD-3 deferred — does FinancialStatement domain entity NEED ADDITIVE provenance fields for thesis-pipeline citation surface?
- **Charter-tier-surface**: domain-entity-shape question (additive vs application-layer-only at ExtractedFinancialStatement)
- **Default if NOT fired**: ADDITIVE-ONLY migration (default=None for all new fields; backward compat preserved); architect-recommended default per Karpathy P3
- **NO AskUserQuestion needed**: main session reviews G.4 IMPL output; default proceeds without gate

## (d) Parallel-dispatch eligibility window

Per parent plan-033 § N parallel-dispatch authorization:

- **Phase G-prime master-plan dispatch**: AUTHORIZED NOW per parent plan-033 § N table line "Phase G-prime ... Can dispatch PARALLEL with Phase F-prime after F.1 ships [sub-plan 034 close] — architect-tier parallel-dispatch precedent (S345 4-parallel) supports this"; gate satisfied with margin — Phase F-prime reached CODE-DONE-DATA-PENDING at S386 commit 90b27db (entire phase code-shipped vs sub-plan 034 close gate per parent authorization)
- **Sub-plans 041 sequential**: blocks G.2/G.3/G.4 (foundational ABC + empirical winner needed)
- **Sub-plans 042 + 043 PARALLEL-ELIGIBLE** post-041 ship: disjoint adapter files + disjoint test files; only shared SHA256.txt manifest (final-aggregation pattern); 2-parallel well within plan-025 DD-5 3-parallel ceiling
- **Sub-plan 044 SEQUENTIAL POST-G.2 AND G.3 ship**: dogfood needs both adapters for side-by-side comparison

**Cross-phase parallel dispatch with Phase F-prime data-corpus ingestion operational track**: AUTHORIZED per parent plan-033 § N (file scope disjoint: BC-2 fundamental adapters vs BC-5 news + BC-1 OHLCV + BC-2 vnstock-existing-adapter). Phase F-prime data-corpus = operational rather than IMPL (separable per architect-design intent per current-execution.md:185-186).

## Next-action handoff to main session

1. Read master plan file at `agent-workspace/session-plans/pending/040-S391-phase-gprime-master-plan.md`
2. Review 8 DD inventory (DD-1 through DD-8) + 8 RM table (RM-G-1 through RM-G-8) + 3 K.2 charter-tier-surface triggers
3. Verify NON-BLOCKING entry acceptable; NO AskUserQuestion gate fired at master-plan-tier (architect-recommended defaults chosen)
4. **Dispatch sub-plan 041 author** (sandwich-architect at S392) per § N.2 sequencing for G.1 empirical bake-off + PdfTableExtractorPort ABC design
5. Sub-plan 041 STEP 0 fires K.2.a STOP-AND-ASK IF empirical probe contradicts architect-recommended default (pdfplumber+camelot OR docling OR pypdf winner)
6. Commit this master plan + observation file per D-060 + pre-dispatch-architect-commit-guard.sh hook

## Files written this session (paths absolute per cwd convention)

- `C:\htdocs\stockforge\agent-workspace\session-plans\pending\040-S391-phase-gprime-master-plan.md` (~900 LOC master plan)
- `C:\htdocs\stockforge\agent-workspace\memory\observations\master-planner-S391-phase-gprime-master-plan.md` (THIS observation file)

## Compliance attestation (S391 master-plan authoring)

- 0 production code ✓ (PLAN-only)
- 0 commits ✓ (architect has no Bash; main commits per D-060)
- 0 charter / constitution / human-workspace writes ✓
- AP-1 ✓ (fresh-context dispatch; main ratifies)
- AP-7 ✓ (every defer names prereq + revisit trigger; PCG-4 + PCG-5 explicit AP-7 named revisit)
- VBW protocol ✓ (24+ source files Read tool empirical; cited file:line for every architectural claim)
- L-S32-1 empirical-probe-first MANDATE ✓ (G.1 = empirical bake-off; 3 candidate libraries with cited source-evidence)
- Phase 1b CONSUMED with COLD-START declared ✓ (task_class="pdf-extraction-master-plan" NEW; nearest analog crawler-adapter-impl n=3 + vietnamese-nlp-plan n=1)
- anthropic_api_to_subagent memory-rule ✓ (G.3 DD-6 mandates claude CLI substrate; ZERO new `import anthropic`)
- Phase F-prime CODE-DONE-DATA-PENDING gate ACKNOWLEDGED per § N.4 (parent plan-033 § N parallel-dispatch authorization satisfied with margin)
