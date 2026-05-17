---
type: sandwich-verifier-observation
session: S397
dispatched_by: main session at S395 close
agent_id: ac54d2608aedad015
plan_verified: agent-workspace/session-plans/completed/041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md
predecessor_dev: a01ea2a003622c0b3 (S394 sandwich-dev; commits ec293fc + b9b38be)
verdict: PASS
merge_eligible: true
critical_count: 0
important_count: 4
minor_count: 3
promotion_candidates: 2
authored_at: 2026-05-17T15:30:00Z
note: |
  Content sourced verbatim from S397 verifier task-notification result text
  (verifier returned report inline but skipped on-disk write per dispatch brief mandate;
  main session persisted to disk for AP-1 audit-trail integrity; see M-S397-1 in mistake-log).
---

# S397 Sandwich-Verifier Report — Plan-041 G.1 PdfTableExtractorPort ABC + Library Bake-Off IMPL

## Files Reviewed

- Plan: `C:\htdocs\stockforge\agent-workspace\session-plans\completed\041-S392-phase-gprime-g1-pdf-library-bakeoff-and-port-abc.md`
- Dev observation: `C:\htdocs\stockforge\agent-workspace\memory\observations\sandwich-dev-S394-g1-pdf-library-bakeoff-impl.md`
- STOP-FINDING: `C:\htdocs\stockforge\human-workspace\notifications\STOP-FINDING-S394-pdf-real-pdfs-needed.md`
- ADR D-080: `C:\htdocs\stockforge\agent-workspace\memory\decisions\080-pdf-table-extractor-port-and-library-winner.md`
- Bake-off report: `C:\htdocs\stockforge\agent-workspace\research\pdf-library-bakeoff-2026-05-G1.md`
- Production code: `packages\application\fundamental\pdf_table_extractor_port.py` (185 LOC), `pdf_source.py` (87 LOC), `extracted_financial_statement.py` (117 LOC), `__init__.py` (13 LOC)
- Probe: `apps\cli\bench\pdf_bake_off.py` (785 LOC), `apps\cli\bench\__init__.py` (11 LOC)
- Tests: `packages\application\fundamental\test_pdf_table_extractor_port.py` (177 LOC; 8 tests), `test_extracted_financial_statement.py` (399 LOC; 15 tests)
- Fixtures: `tests\fixtures\pdf\` (SHA256.txt + expected_cells_vhm.json + expected_cells_hpg.json + 2 synthetic placeholder PDFs 690 bytes each)
- D-066 precedent: `packages\application\news\ports\crawler_adapter.py` (128 LOC; mirrored exactly)
- Session log: `agent-workspace\memory\sessions\2026-05-17-session-394.md`
- pyproject.toml diff (commit `ec293fc`): +8 effective LOC mypy override only

---

## V1-V10 Grid Outcomes

| # | Check | Outcome | Evidence |
|---|-------|---------|----------|
| **V1** | Acceptance criteria per plan-041 § E DoDs (D1-D5) | **PASS** | D1 ABC at exact path 185 LOC (ceiling 120 OVER but doc-heavy); 4 abstract methods + ClassVar at `pdf_table_extractor_port.py:109,133,151,168,177`; `__init_subclass__` typecheck at `:111-131` mirrors D-066 `:60-78` exactly. D2 dataclasses at exact paths with all 6+7 fields + invariants enforced. D3 probe + report at exact paths. D4 23 tests collected (8 ABC + 15 dataclass) — matches dev claim. D5 ADR D-080 PROPOSED with 15 fields (≥12 floor). Gold-set 5 files committed. |
| **V2** | Dev handoff notes | **PASS** | pyproject.toml diff confirms +9 lines (+8 content + 1 blank context) override-only at `:107-115` (NOT dep addition; honors DD-8). D1+D2 are independently importable + subclass-instantiable (V6 smoke confirmed). G.3 sub-plan 043 dispatch-eligible: ABC contract has no dependency on PDF file presence; only consumes the `PdfSource → ExtractedFinancialStatement` contract. |
| **V3** | Charter compliance | **PASS** | I-S1 (NO LLM math): ZERO `import anthropic` in `packages/application/fundamental/` and `apps/cli/bench/`; all parsing is deterministic Python (Grep). I-S2 (source+as_of): PdfSource enforces `source_url.startswith(("http://","https://"))` at `pdf_source.py:75-79`; ExtractedFinancialStatement carries `source_pdf_sha256` + `extracted_at` (tz-aware D-059 R1). Karpathy P2: ABC method count = exactly 4 (ceiling). Karpathy P3: zero touch confirmed via `git diff ec293fc^ ec293fc -- apps/crawlers/cafef_html_to_md.py` (empty). Charter Principle 8 calibration: bake-off Metric 1 = cell-content-exact-match coded at `pdf_bake_off.py:329-403` (deterministic). |
| **V4** | Architecture boundaries | **PASS** | ABC path = `packages/application/fundamental/` per parent plan-040 DD-1 (NOT `packages/_shared/pdf/` — VBW correction documented in plan-041 STEP 0.5 + DD-1 + RM6 + ADR D-080 `:58-62`). `git diff --stat ec293fc^ ec293fc` confirms ZERO touch to `packages/domain/`, `packages/infrastructure/fundamental/`, `packages/_shared/`, `packages/application/news/`, other 8 BCs, `apps/crawlers/`, existing `apps/cli/*.py`. |
| **V5** | Regression check | **PASS-WITH-NUANCE** | pytest: independently re-ran `python -m pytest packages/` → **1127 passed / 1 skipped / 0 failed** (matches dev claim exactly; skip = pre-existing Windows symlink). mypy --strict on canonical project invocation `python -m mypy --strict -p packages.application.fundamental -p apps.cli.bench` → **Success: no issues found in 8 source files**. ruff `python -m ruff check packages/application/fundamental/ apps/cli/bench/` → **All checks passed!** See IMPORTANT F1 below re: path-based vs module-based mypy invocation. |
| **V6** | Integration smoke | **PASS** | `python -m apps.cli.bench.pdf_bake_off --help` exits 0 with full argparse help. Constructed `_Stub(PdfTableExtractorPort)` programmatically: subclass with `source_id` + 4 methods instantiates OK; empty `source_id` rejects with correct TypeError. |
| **V7** | ctor-discipline + zero-new-prod-classes audit | **PASS** | NEW classes ARE expected per plan (ABC + 2 dataclasses + 2 error classes); patterns match D-066 precedent verbatim (`crawler_adapter.py:55-78` vs `pdf_table_extractor_port.py:93-131`). Frozen+slotted dataclass pattern mirrors `packages/domain/fundamental/models/financial_statement.py` shape per `extracted_financial_statement.py:43-66`. M-S392-1 dispatch-brief deviation documented correctly in plan-041 STEP 0.5 + DD-1 + RM6 + ADR D-080 alternatives. |
| **V8** | ADR D-080 quality | **PASS** | 15 fields present (≥12 L-S389-2 floor per dev arithmetic + verified independently); status: PROPOSED (correct — IMPL-tier auto-ratifies on PASS verdict); winner: PENDING-real-pdf-required explicitly stated at `ADR:116-126`; source_evidence chain has 12 cites including STOP-FINDING-S394 (`:215`), plan-041 (`:206`), parent plan-040 (`:207`), crawl4ai (`:217`). |
| **V9** | STOP-FINDING-S394 quality | **PASS-WITH-CONCERNS** | Human action items enumerated as Option A (recommended; 9 ordered steps) / B (git-LFS) / C (community-evidence skip). Network failure root cause cited in bake-off report `:55-60` (5 specific URLs + HTTP 403/SSL/DNS error codes). `severity: IMPLEMENTATION-BLOCKER` + `requires_human_decision: true` set. See IMPORTANT F4 below re: severity-schema vocabulary alignment. |
| **V10** | K.2.a non-firing attestation | **PASS** | Trigger A (license escalation) correctly documented N/A in bake-off report `:34-35` (pymupdf still AGPL-3.0). Trigger B (no-clear-winner) correctly documented PENDING-cannot-evaluate at `:43-46` (max(scores)=0% from placeholder annotation `null` values is FALSE-POSITIVE per dev observation `:99`). K.2.a STOP-AND-ASK fire NOT required this turn — CONFIRMED correct decision. |

---

## Findings

### CRITICAL: NONE

### IMPORTANT (4)

**F1 — mypy invocation pattern inconsistency**: Path-based mypy (`python -m mypy --strict apps/cli/bench/pdf_bake_off.py`) surfaces 9 `[unused-ignore]` errors at probe `:218, :257, :258, :296, :735, :736, :738, :769, :770` because the `[[tool.mypy.overrides]] module=["apps.cli.bench.pdf_bake_off"]` block (pyproject.toml `:107-115`) ONLY matches MODULE-NAME invocation, not PATH invocation. Canonical project invocation (`-p apps.cli.bench`) works clean. Dev's "mypy --strict PASS" claim is true under canonical invocation but technically misleading because the `# type: ignore[no-untyped-call]` comments are dead code when the override applies. **Action**: borderline; recommend tracking for cleanup. Evidence: `apps/cli/bench/pdf_bake_off.py:218,257,258,296,735,736,738,769,770`.

**F2 — Path-based mypy on packages/ surfaces a pre-existing "Source file found twice" error**: `python -m mypy --strict packages/` fails on `application/fundamental/pdf_source.py` (and other files) due to dual module name resolution. This is a **pre-existing project-wide ambiguity** — `git log ec293fc^..HEAD -- packages/observability/transcript_cache.py` returning empty confirms S394 did NOT introduce this. NOT blocking S394 merge; recommend follow-up harness ADR to standardize on `-p packages.*` invocation form or add `[tool.mypy] explicit_package_bases = true` to pyproject.toml. Out of scope for plan-041; defer to next harness sweep.

**F3 — LOC ceiling overruns documented but never triaged**: Dev's own LOC table (observation `:175-191`) self-flags 7 files OVER ceiling: `pdf_table_extractor_port.py` 185 vs 120 (+54%), `pdf_source.py` 87 vs 60 (+45%), `extracted_financial_statement.py` 117 vs 100 (+17%), `test_pdf_table_extractor_port.py` 177 vs 100 (+77%), `test_extracted_financial_statement.py` 399 vs 100 (+299%!), `pdf_bake_off.py` 785 vs 220 (+257%!). Plan-041 § G.5 says "&gt;5% overage triggers SPLIT-or-justify discussion". Dev's justification is "DOC-HEAVY" (docstrings) and "12 vs 8 tests" / "15 tests + fixture" / "full probe impl". This is plausible; core CODE LOC counts cited (~70+40+60) are within ceiling. **Action**: Accept dev's "DOC-HEAVY" justification as merge-eligible; propose **L-S397-1 promotion candidate** to formalize "core code LOC" vs "total LOC" distinction for plan ceilings.

**F4 — STOP-FINDING severity vocabulary deviation**: STOP-FINDING-S394 frontmatter uses `severity: IMPLEMENTATION-BLOCKER` — NOT in standard severity-schema vocabulary (INFO / WARN / HIGH / CRITICAL / CHARTER-TIER-SURFACE / ALERT). Bake-off probe's `write_stop_finding()` at `pdf_bake_off.py:494-510` uses `severity: CHARTER-TIER-SURFACE` for hypothetical K.2.a-triggered STOP-FINDING — DIFFERENT from this STOP-FINDING-S394's `IMPLEMENTATION-BLOCKER`. Vocabulary inconsistent within same plan's outputs. **Action**: NOT blocking merge; recommend main session normalize to `severity: HIGH` (operational blocker, not charter-tier; doesn't gate human-CRITICAL decision).

### MINOR (3)

**F5** — Session log frontmatter at `agent-workspace/memory/sessions/2026-05-17-session-394.md:6` says `model: Claude Opus 4.7 (claude-sonnet-4-6 actual)` — dev was actually Sonnet 4.6 despite "full opus" 2026-05-17 directive. Documentation artifact; output quality is high regardless. Recommend dispatch.jsonl audit for routing drift, but no remediation needed for plan-041 IMPL.

**F6** — `pdf_bake_off.py:560-590` `validate_paths()` function MUTATES `os.environ["STOCKFORGE_ALLOWED_FILE_ROOTS"]` to add `tests/fixtures/pdf/` at runtime. This is a deliberate D-064 path-safety convenience for the probe, but it's a side-effect that could pollute env in long-running processes. Acceptable for one-off probe; document if reused.

**F7** — D-066 CrawlerAdapter ABC mentioned at `packages/application/news/ports/crawler_adapter.py:60-78` but no ADR file exists at `agent-workspace/memory/decisions/066-*.md` (ADR D-080 sources it at `:213` "if exists"). The D-066 reference is INFORMATIONAL precedent only, not a binding citation requirement. Not blocking.

---

## Verdict

**PASS** — merge-eligible.

Plan-041 IMPL delivered all 5 sub-tracks (D1-D5) per plan § E DoDs:
- D1 ABC contract: ARCHITECTURALLY SOUND (mirrors D-066 precedent exactly, 4-method ceiling, `__init_subclass__` typecheck verified working).
- D2 dataclasses: INVARIANT-COMPLETE (frozen+slotted, all post_init checks present + tested).
- D3 probe: STRUCTURALLY COMPLETE (CLI works, 4-metric harness coded, K.2.a evaluation logic correct; empirical run PENDING real PDFs per RM3 — correctly NOT escalated to K.2.a fire because synthetic-fixture 0% scores are not genuine no-clear-winner signal per dev observation `:99`).
- D4 tests: 23/23 PASS (8 ABC + 15 dataclass; behavior-testing not implementation-coupling; uses real PdfSource + ExtractedFinancialStatement domain objects via `_make_pdf_source`/`_make_efs` helpers at `test_extracted_financial_statement.py:56-83`; gold-set SHA256 manifest test at `:361-399`).
- D5 ADR D-080: 15-field schema satisfied; PROPOSED (correct status); winner: PENDING-real-pdf-required (correctly deferred).

All 17 hard rules from plan-041 frontmatter and § F.2 ZERO-TOUCH file scope verified empirically. STOP-FINDING properly authored at the conditional path per § J K.2.a inheritance. G.2 sub-plan 042 dispatch correctly BLOCKED on real PDF provision; G.3 sub-plan 043 dispatch correctly UNBLOCKED (consumes only ABC contract per D1).

---

## Attestation-Log Row

```
2026-05-17T15:30:00Z	sandwich-verifier-S397-plan-041-g1-verify	NA	NA	NA	PASS
```

---

## Promotion Candidates Surfaced (AP-23 + Charter Principle 8 calibration)

**L-S397-1 LOW (1st instance)**: **Plan LOC ceilings should distinguish "core code" from "total LOC including docstrings/tests/fixtures"**. Dev's observation table self-flagged 7 over-ceiling files but core-code LOC fit ceiling. Plan § G.4 conflates code+docstring+test LOC into single ceiling, then § G.5 says "&gt;5% overage triggers SPLIT-or-justify discussion" — creates noise for doc-heavy files. AP-7 trigger: if 2nd instance in next 5 sessions, promote to plan-template requiring per-category LOC ceilings. 1st-instance HOLD per AP-23.

**L-S397-2 LOW (1st instance)**: **STOP-FINDING severity vocabulary needs canonical normalization**. STOP-FINDING-S394 uses `IMPLEMENTATION-BLOCKER` (ad-hoc); bake-off probe `write_stop_finding()` uses `CHARTER-TIER-SURFACE` (also ad-hoc in this context). Standard severity-schema is INFO/WARN/HIGH/ALERT/CRITICAL. AP-7 trigger: if 2nd severity-vocabulary deviation in next 5 sessions, promote to STOP-FINDING template with frozen severity enum. 1st-instance HOLD.

---

## Handoff Notes for Main Session

1. **Commit timing**: D1+D2+D3+D4+D5 are all merge-eligible per PASS verdict. ADR D-080 status flip PROPOSED → ACCEPTED is APPROVED (IMPL-tier auto-ratifies per severity-schema).
2. **G.3 sub-plan 043 (Claude vision adapter) dispatch**: **UNBLOCKED** — confirmed empirically. ABC contract at `pdf_table_extractor_port.py:93-185` consumes only `PdfSource → ExtractedFinancialStatement` types and has NO dependency on PDF file presence or bake-off winner library.
3. **G.2 sub-plan 042 (pure-Python winner adapter) dispatch**: **BLOCKED** per RM3. Human action required per STOP-FINDING-S394 Option A.
4. **K.2.a STOP-AND-ASK fire**: NOT REQUIRED this turn.
5. **Promotion-cycle-trigger HARD-BLOCK queue**: 6 candidates total (L-S389-1+L-S389-2+L-S392-1+L-S395-1+L-S397-1+L-S397-2); below 8-cumulative HARD-BLOCK threshold.
6. **Cleanup deferrals** (NOT blocking merge): F1 (9 unreachable type-ignores in probe); F2 (project-wide mypy "source file twice" pre-existing); F4 (STOP-FINDING severity vocab inline-fix).
